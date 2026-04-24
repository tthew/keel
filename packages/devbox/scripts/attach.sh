#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/attach.sh — Story 2.6 (AC 6)
#
# Attach to the container's PID 1 stdio. Used by Story 2.7 to observe the
# Ralph TUI running inside the devbox. `Ctrl+P Ctrl+Q` detaches without
# killing the container (docker default, pinned explicitly via
# --detach-keys to guard against future docker-default changes).
#
# Exit codes (SC-5):
#   0   clean detach.
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first.
#   *   docker attach error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

# AI-8 (Story 2.6 CR iter-212): operator-shell COMPOSE_PROJECT_NAME export
# would redirect compose's project identity away from `name: keel-devbox` and
# break the `keel-devbox_keel_home_dev` volume path (INV-devbox-homedev-named-volume).
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve main repo + mode-specific state (Story 2.11: per-fork vs shared via
# KEEL_DEVBOX_SHARED). Without mode resolution, attach under shared mode would
# target `keel-devbox` (per-fork default) instead of `keel-devbox-shared`.
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"

log() { printf 'attach: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Subsumes the former inline `docker info` probe.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
	log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
	exit 9
fi

log "attaching to ${CONTAINER_NAME} (detach: Ctrl+P Ctrl+Q)"
exec docker attach --detach-keys='ctrl-p,ctrl-q' "${CONTAINER_NAME}"
