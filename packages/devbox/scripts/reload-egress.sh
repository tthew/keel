#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/reload-egress.sh — Story 2.3 (AC 4, SC-5, SC-8)
#
# Atomic reload primitive for the two egress layers (dnsmasq + nftables).
# Single arg: a path to the composed whitelist file (one domain per line,
# comments + blanks already stripped by the caller — start-egress.sh or the
# future Story 2.4 whitelist.sh sync CLI).
#
#   reload-egress.sh <composed-whitelist-path>
#
# Exit codes:
#   0  success
#   2  missing/invalid arguments
#   3  whitelist path unreadable
#   4  flock unavailable within 10s (concurrent reload in flight)
#   5  `nft -f` transaction failed — previous ruleset stays active (kernel
#      rollback); dnsmasq config is NOT reloaded (atomicity preserved).
#   6  dnsmasq config render failed before apply
#   7  dnsmasq SIGHUP failed (fallible seam per SC-5 residual risk — new
#      nftables active, dnsmasq on old config; operator may manually restart).
#
# Mechanism (SC-5 verbatim):
#   1. flock -x /run/keel-egress.lock
#   2. render nftables ruleset into tempfile (marker block replaced with
#      resolved ipv4 / ipv6 accept rules)
#   3. `nft -f <tempfile>` — kernel atomic transaction
#   4. render dnsmasq config into /etc/dnsmasq.conf (marker block replaced
#      with per-domain `server=` directives forwarding to
#      ${KEEL_DEVBOX_DNS_UPSTREAM:-1.1.1.1})
#   5. kill -HUP <dnsmasq-pid> (fallback: pkill -HUP dnsmasq)
#   6. release flock on exit
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
NFT_TEMPLATE="${DEVBOX_DIR}/nftables/egress.nft"
DNSMASQ_TEMPLATE="${DEVBOX_DIR}/dnsmasq/dnsmasq.conf"
LOCK_FILE="/run/keel-egress.lock"
DNSMASQ_PID_FILE="/run/dnsmasq.pid"
DNSMASQ_CONF="/etc/dnsmasq.conf"
DNSMASQ_RUNDIR="/var/run/dnsmasq"
UPSTREAM_RESOLVER="${KEEL_DEVBOX_DNS_UPSTREAM:-1.1.1.1}"

log() { printf 'reload-egress: %s\n' "$*" >&2; }

# --- Marker-validation preflight (AR-6 + AR-7 guardrail) ------------------
# Assert each template's awk-substitution marker block is present with the
# expected count AND balanced START/END pairs BEFORE the awk substitution
# runs. If a template loses a marker (dev-edit typo), duplicates one, or the
# pair is unbalanced, the awk `in_marker` state machine silently produces a
# broken rendered file — the reload exits 0 while the allow-list region is
# either blanked (dnsmasq forwards every domain via address=/#/ fallback, or
# nftables ships without the resolved accept rules) or stuffed with the
# wrong block type (ipv4 rules into the ipv6 chain, server= directives into
# the nftables ruleset). Both failure modes are invisible at reload time.
# Preflight with an explicit per-marker count catches the imbalance at
# exit 6 (pre-apply render failure) with a diagnostic naming the template +
# marker-name + expected vs. found counts. Pattern
# `^[[:space:]]*# <marker>_{START,END}` mirrors the awk regex exactly so
# preflight and substitution agree on what counts as a marker — a
# non-anchored grep would false-match the documentation references in the
# template header comments. AR-7 parameterises the marker name so the
# nftables template (which now carries chain-scoped `KEEL_EGRESS_V4_MARKER`
# + `KEEL_EGRESS_V6_MARKER`) and the dnsmasq template (still using
# `KEEL_EGRESS_ALLOWLIST_MARKER`) share one validator.
validate_markers() {
	local template="$1" expected="$2" label="$3" marker="$4"
	local start_count end_count
	start_count="$(grep -c "^[[:space:]]*# ${marker}_START" "${template}" || true)"
	end_count="$(grep -c "^[[:space:]]*# ${marker}_END" "${template}" || true)"
	if [[ "${start_count}" -ne "${expected}" ]] || [[ "${end_count}" -ne "${expected}" ]] || [[ "${start_count}" -ne "${end_count}" ]]; then
		log "ERROR: ${label} template marker imbalance: ${template} (marker=${marker})"
		log "  expected: ${expected} START / ${expected} END"
		log "  found:    ${start_count} START / ${end_count} END"
		log "  silent awk substitution would corrupt the allow-list region — aborting reload"
		exit 6
	fi
}

# --- Argument validation --------------------------------------------------
if [[ $# -ne 1 ]]; then
	log "usage: reload-egress.sh <composed-whitelist-path>"
	exit 2
fi
whitelist_path="$1"
if [[ ! -r "${whitelist_path}" ]]; then
	log "ERROR: whitelist path not readable: ${whitelist_path}"
	exit 3
fi
if [[ ! -r "${NFT_TEMPLATE}" ]]; then
	log "ERROR: nftables template missing: ${NFT_TEMPLATE}"
	exit 6
fi
if [[ ! -r "${DNSMASQ_TEMPLATE}" ]]; then
	log "ERROR: dnsmasq template missing: ${DNSMASQ_TEMPLATE}"
	exit 6
fi

# --- Acquire flock (SC-5 step 1) ------------------------------------------
# Open the lock file on fd 200; `flock -x -w 10` waits up to 10s before
# giving up. Trap releases the lock on exit (fd close = unlock) and also
# clears the tempfile we render the nftables ruleset into.
exec 200>"${LOCK_FILE}"
if ! flock -x -w 10 200; then
	log "ERROR: could not acquire ${LOCK_FILE} within 10s — concurrent reload in flight?"
	exit 4
fi

cleanup_files=()

cleanup() {
	local f
	for f in "${cleanup_files[@]:-}"; do
		[[ -n "${f}" && -e "${f}" ]] && rm -f "${f}" || true
	done
}
trap cleanup EXIT

# --- Load whitelist domains -----------------------------------------------
mapfile -t domains < <(awk 'NF { print }' "${whitelist_path}")
domain_count="${#domains[@]}"
log "composing rules for ${domain_count} domain(s); upstream=${UPSTREAM_RESOLVER}"

# --- Bootstrap detection + resolver selection -----------------------------
# Historical posture (pre-hardening): temporarily rewrite /etc/resolv.conf to
# route getent via ${UPSTREAM_RESOLVER} when dnsmasq isn't up yet, then trap-
# restore the 127.0.0.1 pin on exit. Under Story 2.5's USER dev +
# cap_drop: [ALL] (CAP_DAC_OVERRIDE stripped), dev cannot write the root-
# owned /etc/resolv.conf bind-mount → the detour failed EACCES and every
# domain was marked "resolution failed" (fail-closed default → nothing in
# the allow-list → container was unreachable).
#
# Hardened posture: bypass /etc/resolv.conf entirely for bootstrap. `dig
# @${UPSTREAM_RESOLVER} +short A/AAAA` accepts an explicit server and does
# NOT read resolv.conf, so it resolves successfully under USER dev without
# needing to mutate root-owned files. Once dnsmasq is running (subsequent
# reloads), fall back to getent which goes through /etc/resolv.conf →
# 127.0.0.1 → dnsmasq → upstream (SC-13 pin remains intact because Docker's
# compose-time `dns: [127.0.0.1]` injection is now the load-bearing mechanism
# instead of the in-script write). `dnsutils` (the bind9-dnsutils package
# shipping dig) is already installed in the base Dockerfile apt list, so no
# additional tooling required.
dnsmasq_running=0
if [[ -s "${DNSMASQ_PID_FILE}" ]]; then
	dnsmasq_pid_probe="$(cat "${DNSMASQ_PID_FILE}" 2>/dev/null || true)"
	if [[ -n "${dnsmasq_pid_probe}" ]] && kill -0 "${dnsmasq_pid_probe}" 2>/dev/null; then
		dnsmasq_running=1
	fi
fi

# Resolver wrappers. When dnsmasq is up → getent (SC-13 resolv.conf pin
# applies). When dnsmasq is down (first-boot) → dig with explicit upstream
# (bypasses resolv.conf).
resolve_ipv4() {
	local d="$1"
	if [[ "${dnsmasq_running}" -eq 1 ]]; then
		getent ahostsv4 "${d}" 2>/dev/null | awk '{print $1}'
	else
		dig +short +tries=2 +time=3 "@${UPSTREAM_RESOLVER}" A "${d}" 2>/dev/null \
			| awk '/^[0-9.]+$/ {print}'
	fi
}
resolve_ipv6() {
	local d="$1"
	if [[ "${dnsmasq_running}" -eq 1 ]]; then
		getent ahostsv6 "${d}" 2>/dev/null | awk '{print $1}'
	else
		dig +short +tries=2 +time=3 "@${UPSTREAM_RESOLVER}" AAAA "${d}" 2>/dev/null \
			| awk '/^[0-9a-fA-F:]+$/ {print}'
	fi
}

# --- Resolve domains → IPv4/IPv6 allow-rules ------------------------------
# Uses resolve_ipv4 / resolve_ipv6 wrappers above. Failure = empty stdout →
# no accept rule emitted → fail-closed default blocks traffic.
nft_ipv4_rules=""
nft_ipv6_rules=""

for domain in "${domains[@]}"; do
	ipv4_raw="$(resolve_ipv4 "${domain}")"
	if [[ -n "${ipv4_raw}" ]]; then
		ipv4s="$(printf '%s' "${ipv4_raw}" | LC_ALL=C sort -u)"
		while IFS= read -r ip; do
			[[ -z "${ip}" ]] && continue
			nft_ipv4_rules+="		ip daddr ${ip} accept"$'\n'
		done <<< "${ipv4s}"
	else
		log "WARN: ipv4 resolution failed for ${domain}; no accept rule emitted (fail-closed default applies)"
	fi
	ipv6_raw="$(resolve_ipv6 "${domain}")"
	if [[ -n "${ipv6_raw}" ]]; then
		ipv6s="$(printf '%s' "${ipv6_raw}" | LC_ALL=C sort -u)"
		while IFS= read -r ip6; do
			[[ -z "${ip6}" ]] && continue
			nft_ipv6_rules+="		ip6 daddr ${ip6} accept"$'\n'
		done <<< "${ipv6s}"
	else
		log "WARN: ipv6 resolution failed for ${domain}; no accept rule emitted (fail-closed default applies)"
	fi
done

# --- Whitelist the upstream resolver IP itself ----------------------------
# dnsmasq forwards every whitelisted-domain query to ${UPSTREAM_RESOLVER}:53,
# but dnsmasq's outbound packet to the resolver is matched against the same
# `output_v4` / `output_v6` chain — so without an explicit accept for the
# resolver IP, the whole DNS path breaks and the script's per-domain
# resolution loop above is moot (every getent / dig query downstream of the
# first reload returns NXDOMAIN). Detect IPv4 vs IPv6 by shape (presence of
# `:`) and inject the rule into the correct chain.
if [[ "${UPSTREAM_RESOLVER}" == *:* ]]; then
	nft_ipv6_rules+="		ip6 daddr ${UPSTREAM_RESOLVER} accept"$'\n'
else
	nft_ipv4_rules+="		ip daddr ${UPSTREAM_RESOLVER} accept"$'\n'
fi

ipv4_rule_count="$(printf '%s' "${nft_ipv4_rules}" | grep -c '^' || true)"
ipv6_rule_count="$(printf '%s' "${nft_ipv6_rules}" | grep -c '^' || true)"

# --- Render nftables ruleset (SC-5 step 2) --------------------------------
# Chain-scoped markers (AR-7): each chain carries its own marker pair,
# expected 1 START / 1 END per chain. Validating each marker-name
# independently decouples the render from chain-declaration order — re-ordering
# output_v4 / output_v6, adding a third chain, or renaming a chain header no
# longer silently mis-routes the awk substitution. Each validate_markers call
# fails exit 6 before the awk runs if its marker is absent or unbalanced.
validate_markers "${NFT_TEMPLATE}" 1 "nftables v4" "KEEL_EGRESS_V4_MARKER"
validate_markers "${NFT_TEMPLATE}" 1 "nftables v6" "KEEL_EGRESS_V6_MARKER"

nft_rendered="$(mktemp -t keel-egress.nft.XXXXXX)"
cleanup_files+=("${nft_rendered}")

# Per-chain marker match: each START line selects its own family's rule
# block to inject. No `chain` state variable — the marker name itself
# disambiguates, so chain declaration order is irrelevant to correctness.
awk -v ipv4_rules="${nft_ipv4_rules}" -v ipv6_rules="${nft_ipv6_rules}" '
	/^[[:space:]]*# KEEL_EGRESS_V4_MARKER_START/ {
		in_marker = 1
		print
		printf "%s", ipv4_rules
		next
	}
	/^[[:space:]]*# KEEL_EGRESS_V4_MARKER_END/ {
		in_marker = 0
		print
		next
	}
	/^[[:space:]]*# KEEL_EGRESS_V6_MARKER_START/ {
		in_marker = 1
		print
		printf "%s", ipv6_rules
		next
	}
	/^[[:space:]]*# KEEL_EGRESS_V6_MARKER_END/ {
		in_marker = 0
		print
		next
	}
	in_marker == 1 { next }
	{ print }
' "${NFT_TEMPLATE}" > "${nft_rendered}"

# --- Apply nftables atomically (SC-5 step 3) ------------------------------
# `nft -f` is a single kernel atomic transaction. If it fails, the previous
# ruleset stays active; we abort before touching dnsmasq so atomicity holds.
if ! nft -f "${nft_rendered}" 2>&1; then
	log "ERROR: nft -f failed; previous ruleset stays active"
	exit 5
fi

# --- Render dnsmasq config (SC-5 step 4) ----------------------------------
# Expected 1 START / 1 END (single server= block inserted into dnsmasq.conf).
# Marker name stays `KEEL_EGRESS_ALLOWLIST_MARKER` (unchanged by AR-7 — AR-7
# only renames the nftables per-chain markers; dnsmasq has a single allow-list
# region so chain-scoping doesn't apply).
validate_markers "${DNSMASQ_TEMPLATE}" 1 "dnsmasq" "KEEL_EGRESS_ALLOWLIST_MARKER"

dnsmasq_rendered="$(mktemp -t keel-egress.dnsmasq.XXXXXX)"
cleanup_files+=("${dnsmasq_rendered}")

dnsmasq_server_block=""
for domain in "${domains[@]}"; do
	dnsmasq_server_block+="server=/${domain}/${UPSTREAM_RESOLVER}"$'\n'
done

awk -v server_block="${dnsmasq_server_block}" '
	/^[[:space:]]*# KEEL_EGRESS_ALLOWLIST_MARKER_START/ {
		in_marker = 1
		print
		printf "%s", server_block
		next
	}
	/^[[:space:]]*# KEEL_EGRESS_ALLOWLIST_MARKER_END/ {
		in_marker = 0
		print
		next
	}
	in_marker == 1 { next }
	{ print }
' "${DNSMASQ_TEMPLATE}" > "${dnsmasq_rendered}"

# Atomic swap: render to tempfile, then mv into place so a mid-write crash
# can't leave /etc/dnsmasq.conf half-written.
mv "${dnsmasq_rendered}" "${DNSMASQ_CONF}"
chmod 0644 "${DNSMASQ_CONF}"
# Tempfile has been consumed; remove from cleanup list via explicit-loop
# rebuild. `${cleanup_files[@]/${dnsmasq_rendered}}` blanks the matched
# element to "" rather than removing it — leaves an empty-string entry that
# the EXIT trap then `rm -f ""`'s. Harmless in practice (the `-n "${f}"`
# guard in cleanup() short-circuits the empty), but obscures the invariant
# that cleanup_files holds only live tempfiles. Explicit rebuild removes
# the element outright so the array content matches its semantic meaning.
new_cleanup=()
for f in "${cleanup_files[@]}"; do
	[[ "$f" != "${dnsmasq_rendered}" ]] && new_cleanup+=("$f")
done
cleanup_files=("${new_cleanup[@]}")

# Ensure dnsmasq's runtime dir exists before first-start / HUP.
mkdir -p "${DNSMASQ_RUNDIR}"
chown nobody:nogroup "${DNSMASQ_RUNDIR}" 2>/dev/null || true

# --- Reload or start dnsmasq (SC-5 step 5) --------------------------------
# If dnsmasq is already running (indicated by pidfile with live pid), SIGHUP
# re-reads config without restart. Otherwise start it fresh against the new
# config — first-time call from start-egress.sh takes this path.
dnsmasq_pid=""
if [[ -f "${DNSMASQ_PID_FILE}" ]]; then
	dnsmasq_pid="$(cat "${DNSMASQ_PID_FILE}" 2>/dev/null || true)"
	if [[ -n "${dnsmasq_pid}" ]] && ! kill -0 "${dnsmasq_pid}" 2>/dev/null; then
		dnsmasq_pid=""  # stale pidfile
	fi
fi

if [[ -n "${dnsmasq_pid}" ]]; then
	if ! kill -HUP "${dnsmasq_pid}" 2>/dev/null; then
		# Fallback: pkill -HUP by name (pidfile may have drifted).
		if ! pkill -HUP dnsmasq 2>/dev/null; then
			log "ERROR: kill -HUP ${dnsmasq_pid} failed and pkill -HUP dnsmasq failed; dnsmasq may be on stale config"
			exit 7
		fi
	fi
	log "reload ok: ${domain_count} domains, ${ipv4_rule_count} ipv4 rules, ${ipv6_rule_count} ipv6 rules (SIGHUP)"
else
	# First-time start. dnsmasq's config pins pid-file=/run/dnsmasq.pid.
	if ! dnsmasq --conf-file="${DNSMASQ_CONF}" 2>&1; then
		log "ERROR: dnsmasq failed to start against ${DNSMASQ_CONF}"
		exit 7
	fi
	log "reload ok: ${domain_count} domains, ${ipv4_rule_count} ipv4 rules, ${ipv6_rule_count} ipv6 rules (fresh start)"
fi
