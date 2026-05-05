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

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# NEW gate for env-check.sh — no inline `docker info` existed previously
# (env-check validated .envrc only). AC 5 "any `pnpm devbox:*` command"
# fails fast with the Docker install-URL pointer before env-check's own
# .envrc parse runs. Exit-code schema extends: env-check's own 2/3 remain;
# 8 (docker unreachable) is now emitted via prereq-check.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

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

# Vars requiring IPv4 / IPv6 literal shape (PR #230 Round-3 R3-Devbox-D01).
# Mirrors the case-pattern gate enforced in reload-egress.sh § Shape gate
# (defense-in-depth — env-check is the operator-side fail-fast; reload-
# egress.sh is the runtime fail-closed). Class `[0-9a-fA-F:.]` admits IPv4
# (digits + dots), IPv6 (hex digits + colons), and zero-compressed IPv6
# (`::1`). Excludes whitespace, newline, `=`, `/`, `#`, brackets, ports —
# any of which would inject awk-meta into reload-egress.sh's per-domain
# `server=/<d>/<resolver>` render OR break the awk -v assignment shape.
SHAPE_IP_LITERAL=(
	KEEL_DEVBOX_DNS_UPSTREAM
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
	# AI-13 iter-218 CR: strip leading `export` keyword + ANY following
	# whitespace (tab, space, multi-space). The prior `${stripped#export }`
	# single-literal-space strip missed tab-separated (`export<TAB>FOO=1`,
	# editor tab-completion) and multi-space (`export  FOO=1`, prettier /
	# tidy-formatter) variants; the subsequent `^KEEL_DEVBOX_[A-Z0-9_]+=`
	# prefix-match regex then failed and the variable was silently skipped
	# — reported as `missing` despite being present and well-formed.
	# Guarded by `=~ ^export[[:space:]]` so bare (non-export-prefixed)
	# lines are left untouched.
	if [[ "${stripped}" =~ ^export[[:space:]] ]]; then
		stripped="${stripped#export}"
		stripped="${stripped#"${stripped%%[![:space:]]*}"}"
	fi
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

for v in "${SHAPE_IP_LITERAL[@]}"; do
	if [[ -n "${parsed[${v}]+x}" ]]; then
		val="${parsed[${v}]}"
		case "${val}" in
			""|*[!0-9a-fA-F:.]*)
				# Use printf %q to render newlines / control bytes safely.
				safe_val="$(printf '%q' "${val}")"
				shape_violations+=("${v}=${safe_val} — expected IPv4 / IPv6 literal (digits, hex, '.', ':' only)")
				;;
		esac
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

# Story 2.11 AC 3: orphaned cross-mode container probe. After baseline
# validation passes, reconcile process env with parsed .envrc (authoritative
# signal is the file content — operator's `direnv allow` may lag a fresh
# `.envrc` edit), invoke the resolver to derive KEEL_DEVBOX_COMPOSE_PROJECT +
# the current container name, then probe the OTHER-mode's container. If
# present, emit a single stderr warning line pointing at `pnpm devbox:clean`.
# Warning-only posture — exit code unchanged (SC-5).
export KEEL_DEVBOX_SHARED="${parsed[KEEL_DEVBOX_SHARED]:-false}"
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"

if [[ "${parsed[KEEL_DEVBOX_SHARED]}" == "true" ]]; then
	OTHER_MODE="per-fork"
	OTHER_CONTAINER="keel-devbox"
	OTHER_BOOL="false"
else
	OTHER_MODE="shared"
	OTHER_CONTAINER="keel-devbox-shared"
	OTHER_BOOL="true"
fi

# Capture-rc pattern per Story 2.10 PATCH-1 LESSON (`set -e` + `if cmd; then`
# rc-suppression). rc=0 → container exists; rc=1 → absent; rc>1 → daemon
# error (Tier 1 prereq-check already cleared basic reachability — treat as
# transient, silently skip the warning rather than fail the command).
rc=0
docker inspect "${OTHER_CONTAINER}" >/dev/null 2>&1 || rc=$?
case "${rc}" in
	0)
		# Three-site verbatim lockstep: env-check.sh emit (here) +
		# `docs/invariants/devbox-mode.md § Mid-use flip warning` +
		# `packages/devbox/README.md § Per-fork vs shared mode § Mid-use flip`.
		log "warning: orphaned ${OTHER_MODE}-mode container '${OTHER_CONTAINER}' detected from a previous KEEL_DEVBOX_SHARED=${OTHER_BOOL} session; run 'pnpm devbox:clean' (after re-flipping .envrc to KEEL_DEVBOX_SHARED=${OTHER_BOOL} if needed) or 'docker rm -f ${OTHER_CONTAINER}' to remove it. See packages/devbox/README.md § Per-fork vs shared mode § Mid-use flip."
		;;
	1) : ;;
	*) : ;;
esac

exit 0
