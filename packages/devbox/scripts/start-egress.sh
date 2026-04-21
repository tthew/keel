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
#      whitelist/*.txt fragments) into /run/keel-whitelist.composed.txt (SC-8).
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
COMPOSED_WHITELIST="/run/keel-whitelist.composed.txt"
TAILER_PID_FILE="/run/keel-egress-tailer.pid"

log() { printf 'start-egress: %s\n' "$*" >&2; }

# --- Step 1: directory bring-up (SC-17) -----------------------------------
mkdir -p /workspace/logs
mkdir -p /run
# /var/log exists in the base image; re-assert for dnsmasq log-facility.
mkdir -p /var/log

# --- Step 2: pin /etc/resolv.conf to 127.0.0.1 only (SC-13) ---------------
# Overwrite /etc/resolv.conf in place. Docker bind-mounts /etc/resolv.conf by
# default, so `mv tempfile /etc/resolv.conf` (rename(2)) fails "Device or
# resource busy" — rename cannot replace a bind-mount target. A direct
# truncate-and-write via `>` updates the existing inode, which works
# uniformly for regular files, symlinks, and bind-mounted files. The ~60-byte
# payload is far under PIPE_BUF, so the single write(2) is kernel-atomic — no
# half-written-resolver race window.
if ! resolv_err=$( { printf 'nameserver 127.0.0.1\noptions edns0 single-request-reopen\n' > /etc/resolv.conf; } 2>&1 ); then
	# Distinguish chattr +i (operator-set) from other write failures so the
	# operator gets an actionable remediation, not a generic errno.
	if lsattr /etc/resolv.conf 2>/dev/null | head -n1 | awk '{print $1}' | grep -q 'i'; then
		log "FATAL: /etc/resolv.conf has immutable attribute set (chattr +i); clear with 'chattr -i /etc/resolv.conf' before container restart"
	else
		log "FATAL: cannot write /etc/resolv.conf — ${resolv_err:-unknown error}"
	fi
	exit 1
fi
chmod 0644 /etc/resolv.conf
log "pinned /etc/resolv.conf to 127.0.0.1"

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
			# LC_ALL=C sort for stable cross-locale ordering; nullglob so an empty
			# directory does not leak the literal pattern as a file name.
			local fragment
			shopt -s nullglob
			for fragment in $(printf '%s\n' "${WHITELIST_FRAGMENTS_DIR}"/*.txt | LC_ALL=C sort); do
				[[ -r "${fragment}" ]] || continue
				cat "${fragment}"
			done
			shopt -u nullglob
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
dnsmasq_up=0
for attempt in 1 2 3 4 5; do
	if pgrep -x dnsmasq >/dev/null 2>&1; then
		dnsmasq_up=1
		break
	fi
	sleep 1
done

if [[ "${dnsmasq_up}" -ne 1 ]]; then
	log "FATAL: dnsmasq not running after 5s — egress policy is not active"
	exit 1
fi

log "ready (domains=${domain_count}, tailer_pid=${tailer_pid})"
