#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/start-egress.sh — Story 2.3 (AC 1, AC 2, AC 5)
#
# Invoked exactly once from packages/devbox/entrypoint.sh at container boot,
# AFTER the Story 2.1 workspace chown + OAuth volume bring-up and BEFORE the
# compose CMD `exec` (SC-11). Bootstraps the fail-closed egress posture:
#
#   1. Ensure /workspace/logs + /run are writable (SC-17).
#   2. Pin /etc/resolv.conf to 127.0.0.1 only (SC-13) — closes upstream
#      cc-devbox's fail-open 8.8.8.8 fallback.
#   3. Compose the static baseline whitelist (whitelist.default.txt +
#      whitelist/*.txt fragments + whitelist.local.txt if present) into
#      /run/keel-whitelist.composed.txt (SC-8; Story 2.4 SC-4 + SC-14
#      dual-composer byte-identity with whitelist.sh compose_whitelist_into).
#   4. Invoke reload-egress.sh for the first-time atomic rule + config apply.
#   5. Launch egress-log-tailer.sh in background for JSONL emission.
#   6. Verify dnsmasq is serving on 127.0.0.1:53 — fail-hard exit 1 if not.
#
# Fail-closed contract: any init failure exits non-zero; entrypoint.sh
# re-raises and the container dies rather than run without egress policy.
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WHITELIST_DEFAULT="${DEVBOX_DIR}/whitelist.default.txt"
WHITELIST_FRAGMENTS_DIR="${DEVBOX_DIR}/whitelist"
WHITELIST_LOCAL="${DEVBOX_DIR}/whitelist.local.txt"
COMPOSED_WHITELIST="/run/keel-whitelist.composed.txt"
TAILER_PID_FILE="/run/keel-egress-tailer.pid"
DNSMASQ_PID_FILE="/run/dnsmasq.pid"

log() { printf 'start-egress: %s\n' "$*" >&2; }

# --- Step 1: directory bring-up (SC-17) -----------------------------------
mkdir -p /workspace/logs
mkdir -p /run
# /var/log exists in the base image; re-assert for dnsmasq log-facility.
mkdir -p /var/log

# --- Step 2: pin /etc/resolv.conf to 127.0.0.1 only (SC-13) ---------------
# Two-tier posture: prefer Docker's compose-time `dns: [127.0.0.1]` injection
# (docker-compose.yml § services.devbox.dns) so /etc/resolv.conf already says
# `nameserver 127.0.0.1` BEFORE the entrypoint runs. This sidesteps the EACCES
# collision under Story 2.5's USER dev + `cap_drop: [ALL]` (CAP_DAC_OVERRIDE
# stripped → non-root cannot write root-owned bind-mounts). When the daemon
# already wrote the canonical line, the in-script write becomes a no-op and we
# continue. When it has NOT (operator overrode `dns:`, fork-time
# hardened posture, or running under `docker run` without compose), attempt the
# write — succeeds under root postures, surfaces FATAL with actionable
# diagnostics under hardened postures.
#
# `options edns0 single-request-reopen` is the legacy second line that the
# pre-compose-dns posture wrote alongside `nameserver 127.0.0.1`; we preserve
# the verify-only path because Docker's `dns:` injection writes only the
# nameserver line. Operators retuning to a non-loopback resolver lose the
# `options` tweaks until they restore the in-script write path.
canonical_resolver='nameserver 127.0.0.1'
current_resolver="$(awk '/^nameserver[[:space:]]/ {print; exit}' /etc/resolv.conf 2>/dev/null || true)"
if [[ "${current_resolver}" == "${canonical_resolver}" ]]; then
	log "/etc/resolv.conf already pinned to 127.0.0.1 (compose dns: injection)"
elif resolv_err=$( { printf 'nameserver 127.0.0.1\noptions edns0 single-request-reopen\n' > /etc/resolv.conf; } 2>&1 ); then
	chmod 0644 /etc/resolv.conf 2>/dev/null || true
	log "pinned /etc/resolv.conf to 127.0.0.1"
else
	# Distinguish chattr +i (operator-set) from other write failures so the
	# operator gets an actionable remediation, not a generic errno.
	if lsattr /etc/resolv.conf 2>/dev/null | head -n1 | awk '{print $1}' | grep -q 'i'; then
		log "FATAL: /etc/resolv.conf has immutable attribute set (chattr +i); clear with 'chattr -i /etc/resolv.conf' before container restart"
	else
		log "FATAL: cannot write /etc/resolv.conf — ${resolv_err:-unknown error}; ensure docker-compose.yml has 'dns: [127.0.0.1]' so the daemon pre-pins the resolver before the hardened entrypoint runs"
	fi
	exit 1
fi

# --- Step 3: compose the baseline whitelist (SC-8) ------------------------
# Concatenate default + every *.txt fragment in deterministic sorted order.
# Strip blank lines and #-prefixed comments; preserve domain literals only.
: > "${COMPOSED_WHITELIST}"
chmod 0644 "${COMPOSED_WHITELIST}"

compose_whitelist() {
	{
		if [[ -r "${WHITELIST_DEFAULT}" ]]; then
			cat "${WHITELIST_DEFAULT}"
		fi
		if [[ -d "${WHITELIST_FRAGMENTS_DIR}" ]]; then
			# Enumerate fragments via find(1) + mapfile, NOT an unquoted
			# `$(printf | sort)` over shell-glob output. The old form
			# word-split on IFS ($' \t\n'), so a fragment filename containing
			# whitespace (e.g. `team A.txt`) would split into two tokens
			# (`team` + `A.txt`) and each mis-named token would fall through
			# the `[[ -r ]]` guard silently — fragment data missing from the
			# composed whitelist with no diagnostic. find -print emits one
			# literal line per file; mapfile -t assigns one line per array
			# element; "${fragments[@]}" re-expands each name as a single
			# argument with embedded whitespace intact. -maxdepth 1 -type f
			# scopes to regular files in this directory (no recursion; skips
			# subdirs and any dir-typed symlinks). LC_ALL=C on sort keeps
			# stable cross-locale ordering. Empty directory yields an empty
			# array; the for-loop is a safe no-op under bash 4.4+.
			local fragment
			local -a fragments=()
			mapfile -t fragments < <(LC_ALL=C find "${WHITELIST_FRAGMENTS_DIR}" -maxdepth 1 -type f -name '*.txt' -print | sort)
			for fragment in "${fragments[@]}"; do
				[[ -r "${fragment}" ]] || continue
				cat "${fragment}"
			done
		fi
		# Story 2.4 SC-4: per-fork override composed last, additive-only.
		# The override CANNOT remove substrate domains (final sort -u dedupes;
		# fail-closed default + IPv4/IPv6 parity unchanged). File is gitignored
		# (SC-3); absent by default; present when operator has invoked
		# `whitelist.sh add <domain>` at least once or pre-placed via fork
		# scaffolding. SC-14 byte-identity contract: this composition stage MUST
		# match whitelist.sh's compose_whitelist_into exactly.
		if [[ -r "${WHITELIST_LOCAL}" ]]; then
			cat "${WHITELIST_LOCAL}"
		fi
	} \
		| sed -E 's/#.*$//' \
		| awk 'NF { gsub(/[[:space:]]+$/, ""); gsub(/^[[:space:]]+/, ""); if (length($0) > 0) print }' \
		| LC_ALL=C sort -u \
		> "${COMPOSED_WHITELIST}"
}

compose_whitelist

domain_count="$(wc -l < "${COMPOSED_WHITELIST}" | tr -d ' ')"
if [[ "${domain_count}" -eq 0 ]]; then
	# Fail-closed default still applies — dnsmasq + nftables will refuse every
	# outbound hostname. Do not fail the init (operator may want a lockdown
	# posture); log a warning so the condition is diagnosable.
	log "WARNING: composed whitelist is empty — fail-closed will block every egress"
fi

# --- Step 4: first atomic reload (AC 4, SC-5) -----------------------------
"${SCRIPT_DIR}/reload-egress.sh" "${COMPOSED_WHITELIST}"

# --- Step 5: launch JSONL tailer in background (SC-15) --------------------
# Replace any stale tailer from a previous container life (pid file left
# behind on hard-kill); `kill -0` probes without signalling.
if [[ -f "${TAILER_PID_FILE}" ]]; then
	old_pid="$(cat "${TAILER_PID_FILE}" 2>/dev/null || true)"
	if [[ -n "${old_pid}" ]] && kill -0 "${old_pid}" 2>/dev/null; then
		kill -TERM "${old_pid}" || true
	fi
	rm -f "${TAILER_PID_FILE}"
fi

nohup "${SCRIPT_DIR}/egress-log-tailer.sh" >/dev/null 2>&1 &
tailer_pid="$!"
printf '%s\n' "${tailer_pid}" > "${TAILER_PID_FILE}"
log "egress-log-tailer.sh launched (pid=${tailer_pid})"

# --- Step 6: verify dnsmasq is serving (AC 5 fail-closed guard) -----------
# Positive-serving liveness probe. Replaces the former `pgrep -x dnsmasq`
# process-table match which passed for any process named "dnsmasq" regardless
# of whether the daemon actually bound its listening socket — a dnsmasq that
# crashed mid-init or wedged before dropping privileges would escape. Two
# gates, both MUST pass within 5s:
#
#   (a) Pidfile non-empty AND pid is alive (`[ -d /proc/<pid> ]`). Verifies
#       dnsmasq started cleanly enough to write its pidfile; pgrep-x caught
#       process presence but not pidfile integrity. The historical `kill -0`
#       form was replaced because dnsmasq drops to user `nobody` after
#       binding :53, and the probe runs as root under cap_drop: [ALL] which
#       strips CAP_KILL — `kill -0 <nobody-pid>` returns EPERM and the probe
#       false-negatives. `/proc/<pid>` directory existence is UID-agnostic
#       and does not require any capability.
#   (b) 127.0.0.1:53 accepts TCP connects. Confirms dnsmasq bound its
#       listening socket per dnsmasq.conf's `listen-address=127.0.0.1,::1`
#       + `bind-interfaces` + `port=53` directives — this is the SC-13
#       fail-closed resolver-reachability contract. Uses bash's /dev/tcp
#       builtin (no external tool), capped by `timeout 1` per attempt.
#
# Stronger `getent ahostsv4 <whitelisted-domain>` probing was rejected: it
# couples liveness to upstream DNS reachability (a legitimately-orthogonal
# failure mode) and turns transient upstream outages into false-negative
# container-start failures with misleading diagnostics.
dnsmasq_up=0
for attempt in 1 2 3 4 5; do
	dnsmasq_probe_pid=""
	if [[ -s "${DNSMASQ_PID_FILE}" ]]; then
		dnsmasq_probe_pid="$(cat "${DNSMASQ_PID_FILE}" 2>/dev/null || true)"
	fi
	if [[ -n "${dnsmasq_probe_pid}" ]] \
		&& [[ -d "/proc/${dnsmasq_probe_pid}" ]] \
		&& timeout 1 bash -c '</dev/tcp/127.0.0.1/53' 2>/dev/null; then
		dnsmasq_up=1
		break
	fi
	sleep 1
done

if [[ "${dnsmasq_up}" -ne 1 ]]; then
	log "FATAL: dnsmasq liveness probe failed after 5s (pidfile=${DNSMASQ_PID_FILE} missing/stale OR 127.0.0.1:53 not accepting TCP) — egress policy is not active"
	exit 1
fi

log "ready (domains=${domain_count}, tailer_pid=${tailer_pid})"
