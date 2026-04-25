#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/whitelist.sh — Story 2.4 (AC 1–5)
#
# User-facing CLI for the devbox egress allow-list. Four subcommands per
# architecture.md § Devbox Package Tree (l.1002, "add/remove/list/sync —
# single tool, FR1a") and PRD § CLI-Tool Surface (l.493):
#
#   whitelist.sh sync               — recompose + validate + atomic-reload
#   whitelist.sh add <domain>       — append <domain> to whitelist.local.txt
#                                     (atomic, mutation-locked) + sync
#   whitelist.sh remove <domain>    — strip <domain> from whitelist.local.txt
#                                     (atomic, mutation-locked) + sync
#   whitelist.sh list               — print composed state with source prefix
#
# Consumes Story 2.3's `reload-egress.sh` primitive without modification —
# Story 2.4 is the first downstream caller validating SC-17's first-boot-safety
# inheritance contract. Composition byte-identical to start-egress.sh's
# compose_whitelist() (SC-14 dual-composer contract; Task 7.4 smoke verifies).
#
# Exit codes (SC-11):
#   0  success
#   2  usage error / domain-syntax validation failure (AC 3 fail-closed)
#   3  whitelist source file unreadable
#   4  mutation flock unavailable within 10s (AC 4 concurrency)
#   5  reload-egress.sh: nft -f transaction failed (passthrough)
#   6  reload-egress.sh: render / marker-validation failure (passthrough)
#   7  reload-egress.sh: dnsmasq SIGHUP failed (passthrough)
#
# Fail-closed discipline (AC 3 + Dev Notes § Fail-closed discipline):
#   - validation failure ⇒ NO reload-egress.sh invocation; previous policy stays active
#   - file-read failure ⇒ NO reload; same posture
#   - reload-egress.sh failure ⇒ exit code propagated; previous policy stays active
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WHITELIST_DEFAULT="${DEVBOX_DIR}/whitelist.default.txt"
WHITELIST_FRAGMENTS_DIR="${DEVBOX_DIR}/whitelist"
WHITELIST_LOCAL="${DEVBOX_DIR}/whitelist.local.txt"
COMPOSED_WHITELIST="/run/keel-whitelist.composed.txt"
PREVIOUS_COMPOSED="/run/keel-whitelist.previous.txt"
MUTATE_LOCK="/run/keel-whitelist-mutate.lock"
RELOAD_SCRIPT="${SCRIPT_DIR}/reload-egress.sh"

# SC-5: strict LDH (letter-digit-hyphen) per-label regex + RFC 1035 total-length bound.
# Rejects underscores, leading/trailing hyphens, empty labels, slashes, embedded whitespace,
# zero-width Unicode. IDN deferred to post-1.0 (operators pre-punycode-encode).
# Known limitations (SC-5): all-numeric TLDs (RFC 3696 §2) NOT enforced; trailing-dot
# FQDNs rejected (operators MUST use bare-name form). Both failure modes are benign
# under fail-closed posture (mis-parsed entry is ignored, never matched).
DOMAIN_REGEX='^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
DOMAIN_MAX_LEN=253

log() { printf 'whitelist: %s\n' "$*" >&2; }

usage() {
	cat >&2 <<'EOF'
usage: whitelist.sh <subcommand> [args]
  sync               Recompose + validate + atomic-reload (no mutation)
  add <domain>       Append <domain> to whitelist.local.txt + sync
  remove <domain>    Strip <domain> from whitelist.local.txt + sync
  list               Print composed state with source prefix (D / F:<name> / L)

Exit codes:
  0  success
  2  usage / domain-syntax validation failure
  3  whitelist file unreadable
  4  mutation lock unavailable within 10s
  5–7  propagated from reload-egress.sh (nft / render / dnsmasq)
EOF
}

# Resolve a path relative to DEVBOX_DIR for operator-readable error messages
# (SC-6: "<file>:<lineno>: …" with file path relative to packages/devbox/).
relpath_devbox() {
	local abs="$1"
	printf '%s' "${abs#${DEVBOX_DIR}/}"
}

# --- Compose primitive (SC-4 + SC-14 dual-composer contract) --------------
# Concatenates default + fragments-sorted + per-fork override (if present),
# strips comments + blanks, dedupes via sort -u, writes to <dest>. MUST
# produce byte-identical output to start-egress.sh's compose_whitelist() for
# the same input files. Task 7.4 parity smoke verifies.
#
# Story 2.18 SC-11: also emits a parallel `${dest}.classification` sidecar
# mapping `domain<TAB>type` (type ∈ {rotating, static}) — every domain
# originating from a `*-rotating.txt` fragment is `rotating`; everything
# else (default + non-rotating fragments + per-fork override) is `static`.
# On collision across rotating + non-rotating sources, rotating wins
# (most-permissive class for population safety). The sidecar MUST be
# byte-identical across this composer + start-egress.sh's compose_whitelist()
# — extends the SC-14 dual-composer parity contract.
compose_whitelist_into() {
	local dest="$1"
	# Build a typed-stream tempfile (`<domain><TAB><type>` records) by walking
	# the same source files as the existing composer, tagging each line with
	# its source-derived type. We then derive BOTH outputs from this stream:
	#   - composed whitelist (domain-only, deduped + sorted) → ${dest}
	#   - classification sidecar (domain<TAB>type) → ${dest}.classification
	# Per-source-type rules per Story 2.18 SC-2:
	#   - whitelist.default.txt → static
	#   - whitelist/*.txt fragments: filename suffix `-rotating.txt` → rotating; else static
	#   - whitelist.local.txt (per-fork override) → static
	local typed
	typed="$(mktemp -t keel-egress.typed.XXXXXX)"
	{
		if [[ -r "${WHITELIST_DEFAULT}" ]]; then
			sed -E 's/#.*$//' "${WHITELIST_DEFAULT}" \
				| awk 'NF { gsub(/[[:space:]]+$/, ""); gsub(/^[[:space:]]+/, ""); if (length($0) > 0) print $0 "\tstatic" }'
		fi
		if [[ -d "${WHITELIST_FRAGMENTS_DIR}" ]]; then
			# Whitespace-safe enumeration via find + mapfile (matches
			# start-egress.sh:88 iter-170 AR-9 drain pattern). Empty
			# directory yields an empty array; for-loop is a safe no-op.
			local fragment
			local -a fragments=()
			mapfile -t fragments < <(LC_ALL=C find "${WHITELIST_FRAGMENTS_DIR}" -maxdepth 1 -type f -name '*.txt' -print | sort)
			for fragment in "${fragments[@]}"; do
				[[ -r "${fragment}" ]] || continue
				local frag_type=static
				case "${fragment}" in
					*-rotating.txt) frag_type=rotating ;;
				esac
				sed -E 's/#.*$//' "${fragment}" \
					| awk -v t="${frag_type}" 'NF { gsub(/[[:space:]]+$/, ""); gsub(/^[[:space:]]+/, ""); if (length($0) > 0) print $0 "\t" t }'
			done
		fi
		# SC-4: per-fork override composed last; additive-only — final sort -u dedupes.
		if [[ -r "${WHITELIST_LOCAL}" ]]; then
			sed -E 's/#.*$//' "${WHITELIST_LOCAL}" \
				| awk 'NF { gsub(/[[:space:]]+$/, ""); gsub(/^[[:space:]]+/, ""); if (length($0) > 0) print $0 "\tstatic" }'
		fi
	} > "${typed}"
	# Composed whitelist: project to domain column, dedupe, sort.
	cut -f1 < "${typed}" | LC_ALL=C sort -u > "${dest}"
	# Classification sidecar (Story 2.18 SC-11): per-domain max(type) where
	# rotating > static (collision rule), then `LC_ALL=C sort -u` for byte
	# identity across composers.
	awk -F'\t' '
		{ c[$1] = ($2 == "rotating" || c[$1] == "rotating") ? "rotating" : "static" }
		END { for (d in c) print d "\t" c[d] }
	' "${typed}" | LC_ALL=C sort -u > "${dest}.classification"
	chmod 0644 "${dest}.classification"
	rm -f "${typed}"
}

# --- Validation primitive (SC-5 + SC-6) -----------------------------------
# Iterates each source file (default + every fragment + override-if-present);
# per non-blank non-comment line, applies LDH regex + 253-char length bound.
# Collects ALL errors before returning 2 (operator sees the full list, not just
# the first failure). File path in stderr is DEVBOX_DIR-relative per SC-6.
validate_sources() {
	local -i error_count=0
	local file fragment lineno line stripped rel
	local -a sources=()

	if [[ -r "${WHITELIST_DEFAULT}" ]]; then
		sources+=("${WHITELIST_DEFAULT}")
	elif [[ -e "${WHITELIST_DEFAULT}" ]]; then
		log "ERROR: whitelist.default.txt exists but is unreadable: ${WHITELIST_DEFAULT}"
		exit 3
	fi

	if [[ -d "${WHITELIST_FRAGMENTS_DIR}" ]]; then
		local -a fragments=()
		mapfile -t fragments < <(LC_ALL=C find "${WHITELIST_FRAGMENTS_DIR}" -maxdepth 1 -type f -name '*.txt' -print | sort)
		for fragment in "${fragments[@]}"; do
			if [[ -r "${fragment}" ]]; then
				sources+=("${fragment}")
			else
				log "ERROR: whitelist fragment exists but is unreadable: ${fragment}"
				exit 3
			fi
		done
	fi

	if [[ -e "${WHITELIST_LOCAL}" ]]; then
		if [[ -r "${WHITELIST_LOCAL}" ]]; then
			sources+=("${WHITELIST_LOCAL}")
		else
			log "ERROR: whitelist.local.txt exists but is unreadable: ${WHITELIST_LOCAL}"
			exit 3
		fi
	fi

	for file in "${sources[@]}"; do
		rel="$(relpath_devbox "${file}")"
		lineno=0
		while IFS= read -r line || [[ -n "${line}" ]]; do
			lineno=$((lineno + 1))
			# Strip inline comments, then trim whitespace (mirrors compose pipeline).
			stripped="${line%%#*}"
			stripped="${stripped#"${stripped%%[![:space:]]*}"}"
			stripped="${stripped%"${stripped##*[![:space:]]}"}"
			[[ -z "${stripped}" ]] && continue
			if [[ "${#stripped}" -gt "${DOMAIN_MAX_LEN}" ]] || ! [[ "${stripped}" =~ ${DOMAIN_REGEX} ]]; then
				printf "%s:%d: invalid domain syntax: '%s'\n" "${rel}" "${lineno}" "${stripped}" >&2
				error_count=$((error_count + 1))
			fi
		done < "${file}"
	done

	[[ ${error_count} -eq 0 ]]
}

# Validate a single domain literal (used by add/remove fast-fail before lock).
validate_domain() {
	local domain="$1"
	if [[ "${#domain}" -gt "${DOMAIN_MAX_LEN}" ]] || ! [[ "${domain}" =~ ${DOMAIN_REGEX} ]]; then
		printf "invalid domain syntax: '%s'\n" "${domain}" >&2
		exit 2
	fi
}

ensure_run_dir() {
	mkdir -p /run
}

# --- sync ------------------------------------------------------------------
cmd_sync() {
	if [[ $# -ne 0 ]]; then
		usage
		exit 2
	fi

	ensure_run_dir

	local tempfile
	tempfile="$(mktemp /run/keel-whitelist-sync.XXXXXX)"
	# shellcheck disable=SC2064
	trap "rm -f '${tempfile}'" EXIT

	# Validate first; SC-6 fail-closed — no reload on validation failure.
	if ! validate_sources; then
		log "ERROR: domain-syntax validation failed; previous policy stays active"
		exit 2
	fi

	compose_whitelist_into "${tempfile}"

	# SC-7 diff: compare PREVIOUS_COMPOSED against tempfile BEFORE applying.
	local raw_diff additions removals added_count removed_count
	additions=""
	removals=""
	if [[ -r "${PREVIOUS_COMPOSED}" ]]; then
		# diff exits 1 when files differ; that's expected, capture-and-continue.
		raw_diff="$(diff --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format='' "${PREVIOUS_COMPOSED}" "${tempfile}" || true)"
		if [[ -n "${raw_diff}" ]]; then
			# GNU diff emits hunks in file-position order, producing per-label
			# sorted but interleaved +/- lines for two pre-sorted inputs.
			# SC-7 mandates +-group-then--group, each alphabetical: post-process.
			additions="$(printf '%s\n' "${raw_diff}" | grep '^+' | LC_ALL=C sort || true)"
			removals="$(printf '%s\n' "${raw_diff}" | grep '^-' | LC_ALL=C sort || true)"
		fi
	else
		# First-sync-after-boot (SC-18): no previous snapshot → every line is +.
		additions="$(awk 'NF { print "+" $0 }' "${tempfile}" | LC_ALL=C sort)"
	fi

	if [[ -z "${additions}" ]]; then
		added_count=0
	else
		added_count="$(printf '%s\n' "${additions}" | grep -c '^+' || true)"
	fi
	if [[ -z "${removals}" ]]; then
		removed_count=0
	else
		removed_count="$(printf '%s\n' "${removals}" | grep -c '^-' || true)"
	fi

	# Atomic swap onto canonical composed-whitelist path (SC-9 same-fs rename).
	mv "${tempfile}" "${COMPOSED_WHITELIST}"
	chmod 0644 "${COMPOSED_WHITELIST}"
	# Tempfile consumed; clear the trap.
	trap - EXIT

	# Invoke reload primitive — propagate exit codes 5/6/7 verbatim (SC-11).
	# On non-zero, do NOT update PREVIOUS_COMPOSED — the next sync should
	# diff against the still-previous state (policy didn't actually change).
	local reload_rc=0
	"${RELOAD_SCRIPT}" "${COMPOSED_WHITELIST}" || reload_rc=$?
	if [[ ${reload_rc} -ne 0 ]]; then
		log "ERROR: reload-egress.sh exited ${reload_rc}; previous policy stays active"
		exit ${reload_rc}
	fi

	# Snapshot for the next diff (SC-18).
	cp -f "${COMPOSED_WHITELIST}" "${PREVIOUS_COMPOSED}"
	chmod 0644 "${PREVIOUS_COMPOSED}"

	# SC-7 stdout summary.
	local domain_count
	domain_count="$(wc -l < "${COMPOSED_WHITELIST}" | tr -d ' ')"
	printf 'whitelist sync: %s domains active\n' "${domain_count}"
	if [[ -n "${additions}" ]]; then
		printf '%s\n' "${additions}"
	fi
	if [[ -n "${removals}" ]]; then
		printf '%s\n' "${removals}"
	fi
	printf '(%s added, %s removed)\n' "${added_count}" "${removed_count}"
}

# --- add -------------------------------------------------------------------
cmd_add() {
	if [[ $# -ne 1 ]]; then
		usage
		exit 2
	fi
	local domain="$1"
	# SC-5 fast-fail before acquiring the mutation lock.
	validate_domain "${domain}"

	ensure_run_dir

	# SC-8 mutation lock on fd 201 (avoids reload-egress.sh fd-200 collision).
	exec 201>"${MUTATE_LOCK}"
	if ! flock -x -w 10 201; then
		log "ERROR: mutation lock unavailable within 10s"
		exit 4
	fi

	# Idempotent add: if already present, log + release + invoke sync.
	if [[ -f "${WHITELIST_LOCAL}" ]] && grep -Fxq -- "${domain}" "${WHITELIST_LOCAL}"; then
		log "domain '${domain}' already present in whitelist.local.txt; no-op"
		exec 201>&-
		cmd_sync
		return $?
	fi

	# Atomic append: write tempfile adjacent to target, mv onto target (SC-9).
	local tempfile
	tempfile="$(mktemp "${WHITELIST_LOCAL}.XXXXXX.tmp")"
	# shellcheck disable=SC2064
	trap "rm -f '${tempfile}'" EXIT

	{
		if [[ -f "${WHITELIST_LOCAL}" ]]; then
			# $(cat …) strips trailing newlines; printf re-adds one for
			# clean newline discipline regardless of hand-edit state.
			local existing
			existing="$(cat "${WHITELIST_LOCAL}")"
			if [[ -n "${existing}" ]]; then
				printf '%s\n' "${existing}"
			fi
		fi
		printf '%s\n' "${domain}"
	} > "${tempfile}"

	mv "${tempfile}" "${WHITELIST_LOCAL}"
	chmod 0644 "${WHITELIST_LOCAL}"
	trap - EXIT

	# Release mutation lock BEFORE sync so reload-egress.sh's flock acquires
	# cleanly (SC-8 nested-lock-deadlock avoidance).
	exec 201>&-

	cmd_sync
}

# --- remove ----------------------------------------------------------------
cmd_remove() {
	if [[ $# -ne 1 ]]; then
		usage
		exit 2
	fi
	local domain="$1"
	validate_domain "${domain}"

	ensure_run_dir

	exec 201>"${MUTATE_LOCK}"
	if ! flock -x -w 10 201; then
		log "ERROR: mutation lock unavailable within 10s"
		exit 4
	fi

	# SC-9 non-existent-target semantics: no-op success.
	if [[ ! -f "${WHITELIST_LOCAL}" ]]; then
		log "whitelist.local.txt does not exist; nothing to remove"
		exec 201>&-
		exit 0
	fi

	# Subtask 5.5 substrate-source protection (SC-1 + SC-5):
	# warn operator that the override CANNOT shrink the substrate baseline.
	# Match comment-stripped + whitespace-trimmed substrate domains so commented
	# lines don't yield false positives and padded entries still match.
	local -a substrate_files=()
	[[ -r "${WHITELIST_DEFAULT}" ]] && substrate_files+=("${WHITELIST_DEFAULT}")
	if [[ -d "${WHITELIST_FRAGMENTS_DIR}" ]]; then
		local -a fragments=()
		mapfile -t fragments < <(LC_ALL=C find "${WHITELIST_FRAGMENTS_DIR}" -maxdepth 1 -type f -name '*.txt' -print | sort)
		local f
		for f in "${fragments[@]}"; do
			[[ -r "$f" ]] && substrate_files+=("$f")
		done
	fi
	if [[ ${#substrate_files[@]} -gt 0 ]]; then
		if sed -E 's/#.*$//' "${substrate_files[@]}" \
			| awk 'NF { gsub(/[[:space:]]+$/, ""); gsub(/^[[:space:]]+/, ""); if (length($0) > 0) print }' \
			| grep -Fxq -- "${domain}"
		then
			log "WARNING: '${domain}' is a substrate baseline / category-fragment domain; remove requires source-level PR (FR44 AMEND path). whitelist.local.txt override has no effect on substrate domains."
			exec 201>&-
			exit 2
		fi
	fi

	# Idempotent remove: if not present, log + release + exit 0 (no sync needed).
	if ! grep -Fxq -- "${domain}" "${WHITELIST_LOCAL}"; then
		log "domain '${domain}' not present in whitelist.local.txt; no-op"
		exec 201>&-
		exit 0
	fi

	local tempfile
	tempfile="$(mktemp "${WHITELIST_LOCAL}.XXXXXX.tmp")"
	# shellcheck disable=SC2064
	trap "rm -f '${tempfile}'" EXIT

	# `grep -Fxv` exits 1 if every line matched (file becomes empty); accept that.
	# rc≥2 means real I/O error (e.g. unreadable target) — fail-loud exit 3 per SC-11,
	# not silent truncation. Matches the exit-3 posture of check_readable at lines 128-151.
	local rc=0
	grep -Fxv -- "${domain}" "${WHITELIST_LOCAL}" > "${tempfile}" || rc=$?
	if (( rc > 1 )); then
		log "ERROR: grep -Fxv failed reading ${WHITELIST_LOCAL} (rc=${rc})"
		exec 201>&-
		exit 3
	fi
	mv "${tempfile}" "${WHITELIST_LOCAL}"
	chmod 0644 "${WHITELIST_LOCAL}"
	trap - EXIT

	exec 201>&-

	cmd_sync
}

# --- list ------------------------------------------------------------------
# SC-10: composed state with source-prefix attribution
#   D            = whitelist.default.txt
#   F:<name>     = whitelist/<name>.txt fragment
#   L            = whitelist.local.txt per-fork override
# When same domain appears in multiple sources, FIRST-encountered wins
# (default → fragments-sorted → override) to match sort -u semantics.
cmd_list() {
	if [[ $# -ne 0 ]]; then
		usage
		exit 2
	fi

	declare -A source_of
	local line name fragment

	if [[ -r "${WHITELIST_DEFAULT}" ]]; then
		while IFS= read -r line; do
			[[ -n "${source_of[$line]+x}" ]] && continue
			source_of["$line"]="D"
		done < <(sed -E 's/#.*$//' "${WHITELIST_DEFAULT}" \
			| awk 'NF { gsub(/[[:space:]]+$/, ""); gsub(/^[[:space:]]+/, ""); if (length($0) > 0) print }')
	fi

	if [[ -d "${WHITELIST_FRAGMENTS_DIR}" ]]; then
		local -a fragments=()
		mapfile -t fragments < <(LC_ALL=C find "${WHITELIST_FRAGMENTS_DIR}" -maxdepth 1 -type f -name '*.txt' -print | sort)
		for fragment in "${fragments[@]}"; do
			[[ -r "${fragment}" ]] || continue
			name="$(basename "${fragment}" .txt)"
			while IFS= read -r line; do
				[[ -n "${source_of[$line]+x}" ]] && continue
				source_of["$line"]="F:${name}"
			done < <(sed -E 's/#.*$//' "${fragment}" \
				| awk 'NF { gsub(/[[:space:]]+$/, ""); gsub(/^[[:space:]]+/, ""); if (length($0) > 0) print }')
		done
	fi

	if [[ -r "${WHITELIST_LOCAL}" ]]; then
		while IFS= read -r line; do
			[[ -n "${source_of[$line]+x}" ]] && continue
			source_of["$line"]="L"
		done < <(sed -E 's/#.*$//' "${WHITELIST_LOCAL}" \
			| awk 'NF { gsub(/[[:space:]]+$/, ""); gsub(/^[[:space:]]+/, ""); if (length($0) > 0) print }')
	fi

	# Sort by domain alphabetically; emit `<prefix>  <domain>` (two-space sep).
	local domain
	if [[ ${#source_of[@]} -gt 0 ]]; then
		while IFS= read -r domain; do
			printf '%s  %s\n' "${source_of[$domain]}" "${domain}"
		done < <(printf '%s\n' "${!source_of[@]}" | LC_ALL=C sort)
	fi
}

# --- main dispatcher -------------------------------------------------------
# Guarded so the script is sourceable (Task 7.4 dual-composer parity harness
# sources whitelist.sh to invoke compose_whitelist_into without firing the
# usage-and-exit branch).
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	if [[ $# -eq 0 ]]; then
		usage
		exit 2
	fi

	subcommand="$1"
	shift
	case "${subcommand}" in
		sync)   cmd_sync "$@" ;;
		add)    cmd_add "$@" ;;
		remove) cmd_remove "$@" ;;
		list)   cmd_list "$@" ;;
		*)
			usage
			exit 2
			;;
	esac
fi
