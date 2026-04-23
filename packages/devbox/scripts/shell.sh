#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/shell.sh — Story 2.6 (AC 5)
#
# Open an interactive login shell as the `dev` user in the running container,
# starting at the path that mirrors the operator's host cwd (iter-239
# mount-path mirroring: cwd /Users/.../<repo>/<sub> → container
# /workspace/<repo>/<sub>). Forwards extra args to bash (`pnpm devbox:shell
# -c 'whoami'` is valid for non-interactive verification).
#
# Exit codes (SC-5):
#   0   clean shell exit (or forwarded command rc).
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first.
#   12  bind-mount source mismatch — run `pnpm devbox:restart` (iter-239).
#   *   docker exec error (propagated).
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

log() { printf 'shell: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Subsumes the former inline `docker info` probe.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
	log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
	exit 9
fi

check_mount_source

if [[ $# -gt 0 ]]; then
	# Non-interactive forwarded command (e.g., `pnpm devbox:shell -c 'id'`).
	exec docker exec -i --user dev -w "${CONTAINER_WORKDIR}" \
		-e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" \
		"${CONTAINER_NAME}" bash -l "$@"
fi

exec docker exec -it --user dev -w "${CONTAINER_WORKDIR}" \
	-e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" \
	"${CONTAINER_NAME}" bash -l
