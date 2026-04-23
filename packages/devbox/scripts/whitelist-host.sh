#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/whitelist-host.sh — Story 2.6 (AC 9, SC-16)
#
# Host-side shim around the Story 2.4 in-container whitelist CLI
# (`packages/devbox/scripts/whitelist.sh`). Thin passthrough — all argument
# validation + subcommand dispatch lives in the in-container primitive
# (avoids dual-source-of-truth drift).
#
# Exit codes (SC-5):
#   0/2/3/4/5/6/7  propagated verbatim from whitelist.sh.
#   8              docker runtime unreachable.
#   9              container not running — run `pnpm devbox:start` first.
#   12             bind-mount source mismatch — run `pnpm devbox:restart` (iter-239).
# ---------------------------------------------------------------------------
set -euo pipefail

# AI-8 (Story 2.6 CR iter-212): operator-shell COMPOSE_PROJECT_NAME export
# would redirect compose's project identity away from `name: keel-devbox` and
# break the `keel-devbox_keel_home_dev` volume path (INV-devbox-homedev-named-volume).
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
# shellcheck source=lib/check-mount-source.sh
source "${SCRIPT_DIR}/lib/check-mount-source.sh"

log() { printf 'whitelist: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Subsumes the former inline `docker info` probe.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
	log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
	exit 9
fi

check_mount_source

# AI-9 (Story 2.6 CR iter-213): `--user dev` pin matches shell.sh:39,42.
# Image default USER is dev (Story 2.5 Dockerfile), so today this is an
# explicit-pin not a posture change; guards against a fork's
# docker-compose.override.yml flipping `user: root` and causing whitelist
# mutations to write /run/keel-whitelist-mutate.lock + whitelist.local.txt
# with root ownership — a subsequent `dev`-user mutation would then fail.
#
# AI-10 (Story 2.6 CR iter-214): TTY-detect stdin before passing `-t` to
# `docker exec`. Hardcoded `-it` fails under non-TTY callers (CI runners,
# pre-commit hooks, `sh -c '...'`, `ssh host pnpm devbox:whitelist list`)
# with "the input device is not a TTY". `-i` keeps stdin attached either
# way; `-t` is added only when a real terminal is present.
if [[ -t 0 ]]; then
	tty_flag="-it"
else
	tty_flag="-i"
fi
exec docker exec "${tty_flag}" --user dev \
	-e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" \
	"${CONTAINER_NAME}" "/workspace/${REPO_NAME}/packages/devbox/scripts/whitelist.sh" "$@"
