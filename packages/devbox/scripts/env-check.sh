#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/env-check.sh — Story 2.6 (AC 8, SC-14, AR-11)
#
# Validate that the repo-root `.envrc` exists AND every required
# `KEEL_DEVBOX_*` variable is present. Shape-validates tmpfs-size knobs
# (AR-11 absorption): `KEEL_DEVBOX_TMPFS_TMP_MB` +
# `KEEL_DEVBOX_TMPFS_VARTMP_MB` + `KEEL_DEVBOX_TMPFS_LOGS_MB` must be strictly
# positive integers (no units, no zero).
#
# Names-only, never values (architecture.md:335,1004 secrets discipline):
# stdout/stderr lines name the offending variable; a shape-violation stderr
# line MAY include the numeric value (not a credential class). No var
# matching `*_TOKEN|*_SECRET|*_KEY|*_PASSWORD` has its value echoed
# (defensive; no such vars exist in the KEEL_DEVBOX_* set at 1.0).
#
# Repo-root resolution (AI-5 iter-204 CR): three-tier fallback so symlinked
# invocations, vendored-at-depth forks (`vendor/keel/packages/devbox/…`),
# and future `packages/devbox/cli/` reorgs resolve `.envrc` correctly
# instead of hardcoding "two levels up from `packages/devbox/`". Honours an
# explicit `KEEL_DEVBOX_REPO_ROOT` envvar override (unconditional operator
# escape hatch), then `git rev-parse --show-toplevel` (authoritative when
# `.git` is present — substrate checkouts, forks, worktrees, submodules),
# then the historical `${DEVBOX_DIR}/../..` arithmetic (tarball-extracted
# forks where `.git` is absent). Error log at exit 3 cites the override
# knob so operators can correct a bad auto-detect without editing code.
#
# Exit codes (SC-5):
#   0   every required var present + every shape-validated var passes.
#   2   missing var(s) or shape violation(s).
#   3   .envrc not readable at repo root.
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Three-tier repo-root resolver (AI-5): override → git → historical fallback.
if [[ -n "${KEEL_DEVBOX_REPO_ROOT:-}" ]]; then
	REPO_ROOT="${KEEL_DEVBOX_REPO_ROOT}"
elif REPO_ROOT="$(git -C "${DEVBOX_DIR}" rev-parse --show-toplevel 2>/dev/null)"; then
	: # resolved via git
else
	REPO_ROOT="$(cd "${DEVBOX_DIR}/../.." && pwd)"
fi
ENVRC_PATH="${REPO_ROOT}/.envrc"

log() { printf 'env-check: %s\n' "$*" >&2; }

# Required vars: union of `.envrc.example`'s active (uncommented) knobs at
# 2026-04-22 HEAD (Story 2.2 + Story 2.5 + Story 2.3 contract). Commented
# defaults (`KEEL_DEVBOX_CONTAINER_NAME`, `KEEL_DEVBOX_WORKSPACE`) and the
# Story 2.6-introduced `KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S` are
# optional — scripts default these via bash `${VAR:-default}` expansion.
REQUIRED_VARS=(
	KEEL_DEVBOX_ARCH
	KEEL_DEVBOX_CPUS
	KEEL_DEVBOX_MEMORY_GB
	KEEL_DEVBOX_SHM_GB
	KEEL_DEVBOX_NOFILE
	KEEL_DEVBOX_TMPFS_TMP_MB
	KEEL_DEVBOX_TMPFS_VARTMP_MB
	KEEL_DEVBOX_TMPFS_LOGS_MB
	KEEL_DEVBOX_PORT_WEB
	KEEL_DEVBOX_PORT_API
	KEEL_DEVBOX_PORT_STORYBOOK
	KEEL_DEVBOX_PORT_VITE_HMR
	KEEL_DEVBOX_SSH
	KEEL_DEVBOX_SHARED
	KEEL_DEVBOX_DNS_UPSTREAM
)

# Vars requiring positive-integer shape (no units, no zero). AR-11.
SHAPE_POSITIVE_INT=(
	KEEL_DEVBOX_TMPFS_TMP_MB
	KEEL_DEVBOX_TMPFS_VARTMP_MB
	KEEL_DEVBOX_TMPFS_LOGS_MB
)

if [[ ! -r "${ENVRC_PATH}" ]]; then
	log ".envrc not found at ${ENVRC_PATH} — run 'direnv allow' or copy 'packages/devbox/.envrc.example' to '.envrc' at the repo root (override auto-detected root via KEEL_DEVBOX_REPO_ROOT if resolved path is wrong for your layout)"
	exit 3
fi

# Parse .envrc: map `KEEL_DEVBOX_<NAME>=<value>` (with optional `export `
# prefix). Value may be double-quoted, single-quoted, or bare. Presence is
# checked irrespective of emptiness — operators may explicitly set `X=` to
# signal "present but empty" (e.g., `KEEL_DEVBOX_DNS_UPSTREAM=`).
declare -A parsed
while IFS= read -r line; do
	# AI-7 iter-211 CR: strip trailing CR from CRLF line endings before any
	# downstream parse step. A Windows-edited or WSL-piped `.envrc` ends every
	# line with `\r`; the trailing-whitespace strip at the end of this loop
	# relies on `[:space:]` membership, which is locale-dependent for `\r`
	# (present in POSIX C/en_US isspace(), but exotic locale configurations
	# may omit it — then `KEEL_DEVBOX_TMPFS_TMP_MB=64\r` reaches the shape
	# regex with an invisible trailing CR and fails as `'64' — expected
	# positive integer` with the `\r` un-renderable in log output). Stripping
	# here (line-level, before quoting-aware extraction) is a strict superset
	# of the IP-prescribed `value`-level strip: it handles bare values,
	# quoted values, and shape-validated values uniformly in one site.
	line="${line%$'\r'}"
	# Strip leading whitespace.
	stripped="${line#"${line%%[![:space:]]*}"}"
	# Skip blank + comments.
	[[ -z "${stripped}" || "${stripped}" =~ ^# ]] && continue
	# Strip leading `export`.
	stripped="${stripped#export }"
	# Require KEEL_DEVBOX_ prefix.
	[[ "${stripped}" =~ ^KEEL_DEVBOX_[A-Z0-9_]+= ]] || continue
	name="${stripped%%=*}"
	value="${stripped#*=}"
	# Value-parse preserving quoting context (AI-6 iter-210 CR): if the
	# value is quoted, the quoted content is authoritative — do NOT strip
	# `#` inside it. Operators MAY intentionally embed a literal `#` in a
	# quoted value (e.g. `KEEL_DEVBOX_DNS_UPSTREAM="1.1.1.1 # primary"`
	# where the trailing `# primary` is part of the value, not a shell
	# comment). Only bare values get inline-comment stripping. The prior
	# "strip quotes first, then `%% #*`" order dropped quoted-internal
	# content after the first ` #` substring.
	first_char="${value:0:1}"
	if [[ "${first_char}" == '"' || "${first_char}" == "'" ]]; then
		# Quoted: capture content up to the FIRST matching close-quote
		# (`%%${qc}*` longest-trailing-match strips from the earliest
		# close-quote onwards). Any trailing ` # comment` after the
		# closing quote is discarded — that's a real comment.
		rest="${value:1}"
		value="${rest%%${first_char}*}"
	else
		# Bare: strip inline trailing comment (after whitespace).
		value="${value%% #*}"
	fi
	# Strip trailing whitespace.
	value="${value%"${value##*[![:space:]]}"}"
	parsed["${name}"]="${value}"
done < "${ENVRC_PATH}"

missing=()
for v in "${REQUIRED_VARS[@]}"; do
	if [[ -z "${parsed[${v}]+x}" ]]; then
		missing+=("${v}")
	fi
done

shape_violations=()
for v in "${SHAPE_POSITIVE_INT[@]}"; do
	# Only shape-check if present (absence is already reported as missing).
	if [[ -n "${parsed[${v}]+x}" ]]; then
		val="${parsed[${v}]}"
		if ! [[ "${val}" =~ ^[1-9][0-9]*$ ]]; then
			shape_violations+=("${v}='${val}' — expected positive integer MB count (no units)")
		fi
	fi
done

present_count=$(( ${#REQUIRED_VARS[@]} - ${#missing[@]} ))
printf 'env-check: %d of %d required vars present; %d value-shape violations\n' \
	"${present_count}" "${#REQUIRED_VARS[@]}" "${#shape_violations[@]}"

if [[ ${#missing[@]} -gt 0 ]]; then
	log "missing required vars:"
	for v in "${missing[@]}"; do log "  - ${v}"; done
fi

if [[ ${#shape_violations[@]} -gt 0 ]]; then
	log "value-shape violations:"
	for v in "${shape_violations[@]}"; do log "  - ${v}"; done
fi

if [[ ${#missing[@]} -gt 0 || ${#shape_violations[@]} -gt 0 ]]; then
	log "seed from 'packages/devbox/.envrc.example' — copy to '.envrc' at repo root and 'direnv allow'"
	exit 2
fi

exit 0
