#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/egress-log-tailer.sh — Story 2.3 (AC 3, SC-3/4/15/16)
#
# Background tailer launched from start-egress.sh via `nohup … &`. Tails
# dnsmasq's native log file (/var/log/dnsmasq.log) and re-emits each DNS
# query/response as a JSONL record to /workspace/logs/egress-queries.jsonl
# per the SC-3 stable schema (consumed by Epic 4 FR37 security-evidence).
#
# Output schema (SC-3 verbatim — DO NOT reorder fields):
#   {"timestamp":"<ISO8601Z>","query":"<domain>","type":"<DNS-type>",
#    "result":"<allow|block|nxdomain|servfail|parse-error>",
#    "upstream":"<ip-or-null>","client":"<source-ip>"}
#
# Rotation (SC-4): when the active JSONL exceeds 50 MB, rotate inline —
# close fd, rename to `.1.tmp`, gzip to `.1.gz`, shift older `.N.gz` → `.N+1.gz`
# dropping anything beyond `.5.gz`, reopen a fresh file. Rotation runs in the
# emitter itself (no cron, no logrotate daemon) per SC-4.
# ---------------------------------------------------------------------------
set -euo pipefail

DNSMASQ_LOG="/var/log/dnsmasq.log"
JSONL_OUT="/workspace/logs/egress-queries.jsonl"
ROTATE_BYTES=$((50 * 1024 * 1024))  # 50 MB, SC-4
MAX_GENERATIONS=5                    # .1.gz .. .5.gz, SC-4

log() { printf 'egress-log-tailer: %s\n' "$*" >&2; }

mkdir -p "$(dirname "${JSONL_OUT}")"
touch "${JSONL_OUT}"
chmod 0644 "${JSONL_OUT}"

# Ensure dnsmasq's log exists so `tail -F` does not race start-up. dnsmasq
# creates the file lazily on first query — pre-create so tail can attach.
touch "${DNSMASQ_LOG}"

# --- ISO8601 UTC with millisecond precision -------------------------------
# GNU date supports %3N (milliseconds) on Ubuntu 24.04 coreutils.
iso_now() { date -u +'%Y-%m-%dT%H:%M:%S.%3NZ'; }

# --- Rotation (SC-4) ------------------------------------------------------
rotate_if_needed() {
	local size
	# `stat -c %s` is GNU coreutils on Ubuntu 24.04. Guard missing-file case.
	if ! size="$(stat -c '%s' "${JSONL_OUT}" 2>/dev/null)"; then
		return 0
	fi
	if (( size < ROTATE_BYTES )); then
		return 0
	fi

	log "rotating ${JSONL_OUT} at ${size} bytes (threshold ${ROTATE_BYTES})"

	# Shift .N.gz → .N+1.gz from the highest generation downward. Drop the
	# oldest (.MAX_GENERATIONS.gz+) first.
	local i
	for (( i = MAX_GENERATIONS; i >= 1; i-- )); do
		local src="${JSONL_OUT}.${i}.gz"
		local dst="${JSONL_OUT}.$((i + 1)).gz"
		if [[ -f "${src}" ]]; then
			if (( i == MAX_GENERATIONS )); then
				rm -f "${src}"
			else
				mv -f "${src}" "${dst}"
			fi
		fi
	done

	# Release the open fd so rename is atomic against readers (SC-16). The
	# main loop reopens the fd below after rotation completes.
	exec 3>&-
	mv -f "${JSONL_OUT}" "${JSONL_OUT}.1.tmp"
	gzip -f "${JSONL_OUT}.1.tmp"
	mv -f "${JSONL_OUT}.1.tmp.gz" "${JSONL_OUT}.1.gz"
	touch "${JSONL_OUT}"
	chmod 0644 "${JSONL_OUT}"
	exec 3>>"${JSONL_OUT}"
}

# --- JSON string escape ---------------------------------------------------
# Domain, IP, and DNS-type values are ASCII-safe by protocol. Backslash +
# double-quote escaping covers every realistic input; tab/newline/control
# chars (which would only appear in a malformed parse-error `raw` payload)
# are stripped via `tr -d` so the resulting JSON stays single-line valid.
json_escape() {
	local s="$1"
	s="${s//\\/\\\\}"
	s="${s//\"/\\\"}"
	# Drop every ASCII control char (0x00-0x1F + 0x7F) so the final line
	# cannot break JSONL framing or inject a literal newline.
	s="$(printf '%s' "${s}" | LC_ALL=C tr -d '\000-\037\177')"
	printf '%s' "${s}"
}

# --- Emit one JSONL record ------------------------------------------------
emit_record() {
	local ts="$1" query="$2" qtype="$3" result="$4" upstream="$5" client="$6"
	local q_esc qt_esc r_esc
	q_esc="$(json_escape "${query}")"
	qt_esc="$(json_escape "${qtype}")"
	r_esc="$(json_escape "${result}")"
	local upstream_json="null"
	if [[ -n "${upstream}" && "${upstream}" != "null" ]]; then
		upstream_json="\"$(json_escape "${upstream}")\""
	fi
	local client_json="null"
	if [[ -n "${client}" ]]; then
		client_json="\"$(json_escape "${client}")\""
	fi
	printf '{"timestamp":"%s","query":"%s","type":"%s","result":"%s","upstream":%s,"client":%s}\n' \
		"${ts}" "${q_esc}" "${qt_esc}" "${r_esc}" "${upstream_json}" "${client_json}" >&3
}

# --- Emit parse-error record ----------------------------------------------
emit_parse_error() {
	local ts raw_esc
	ts="$(iso_now)"
	raw_esc="$(json_escape "$1")"
	printf '{"timestamp":"%s","query":"","type":"","result":"parse-error","upstream":null,"client":null,"raw":"%s"}\n' \
		"${ts}" "${raw_esc}" >&3
}

# --- Parse a dnsmasq log line ---------------------------------------------
# dnsmasq log line examples (log-queries=extra):
#   Apr 21 12:34:56 dnsmasq[42]: query[A] api.anthropic.com from 127.0.0.1
#   Apr 21 12:34:56 dnsmasq[42]: forwarded api.anthropic.com to 1.1.1.1
#   Apr 21 12:34:56 dnsmasq[42]: reply api.anthropic.com is 160.79.104.10
#   Apr 21 12:34:56 dnsmasq[42]: config api.anthropic.com is NXDOMAIN
#   Apr 21 12:34:56 dnsmasq[42]: config blocked.example is 0.0.0.0
parse_and_emit() {
	local line="$1"
	local ts; ts="$(iso_now)"

	# query[<type>] <domain> from <client>
	if [[ "${line}" =~ query\[([^]]+)\]\ ([^\ ]+)\ from\ ([^\ ]+) ]]; then
		emit_record "${ts}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[1]}" "allow" "" "${BASH_REMATCH[3]}"
		rotate_if_needed
		return 0
	fi

	# forwarded <domain> to <upstream>
	if [[ "${line}" =~ forwarded\ ([^\ ]+)\ to\ ([^\ ]+) ]]; then
		emit_record "${ts}" "${BASH_REMATCH[1]}" "A" "allow" "${BASH_REMATCH[2]}" ""
		rotate_if_needed
		return 0
	fi

	# config <domain> is <NXDOMAIN|0.0.0.0|::>
	if [[ "${line}" =~ config\ ([^\ ]+)\ is\ (.+)$ ]]; then
		local domain="${BASH_REMATCH[1]}" answer="${BASH_REMATCH[2]}"
		local result="nxdomain"
		case "${answer}" in
			NXDOMAIN)       result="nxdomain" ;;
			0.0.0.0|::)     result="block" ;;
			*)              result="allow" ;;
		esac
		emit_record "${ts}" "${domain}" "A" "${result}" "" ""
		rotate_if_needed
		return 0
	fi

	# reply <domain> is <answer>
	if [[ "${line}" =~ reply\ ([^\ ]+)\ is\ (.+)$ ]]; then
		local domain="${BASH_REMATCH[1]}" answer="${BASH_REMATCH[2]}"
		local result="allow"
		if [[ "${answer}" == "NXDOMAIN" ]]; then
			result="nxdomain"
		fi
		emit_record "${ts}" "${domain}" "A" "${result}" "" ""
		rotate_if_needed
		return 0
	fi

	# Non-query line (startup banner, config reload, etc.) — skip silently.
	# Only emit parse-error for lines that look like a query but failed to
	# match any regex above.
	if [[ "${line}" =~ dnsmasq\[ ]] && { [[ "${line}" =~ query|forwarded|reply|config ]]; }; then
		emit_parse_error "${line}"
		rotate_if_needed
	fi
}

# --- Signal handling ------------------------------------------------------
shutdown() {
	log "shutting down"
	exec 3>&-
	exit 0
}
trap shutdown TERM INT

# --- Main loop ------------------------------------------------------------
# Open the output fd on #3 for cheap append-append without reopening on each
# line. `tail -F -n 0` follows the dnsmasq log from the current end; `-F`
# handles rotation by dnsmasq itself (rare — we rotate downstream, not here).
exec 3>>"${JSONL_OUT}"
log "started — tailing ${DNSMASQ_LOG} → ${JSONL_OUT}"

tail -F -n 0 "${DNSMASQ_LOG}" 2>/dev/null | while IFS= read -r line; do
	parse_and_emit "${line}"
done
