#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/stop.sh — Story 2.6 (AC 4)
#
# Halt the keel-devbox container without destroying state. Uses `docker
# compose stop` (NOT `down`) so the container object remains for a fast
# subsequent `start`. The `keel_home_dev` named volume (NFR10) is naturally
# preserved — stop does not touch volumes.
#
# Exit codes (SC-5):
#   0   success (stopped or already stopped).
#   8   docker runtime unreachable.
#   *   docker/compose error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

# AI-8 (Story 2.6 CR iter-212): operator-shell COMPOSE_PROJECT_NAME export
# would redirect compose's project identity away from `name: keel-devbox` and
# break the `keel-devbox_keel_home_dev` volume path (INV-devbox-homedev-named-volume).
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${DEVBOX_DIR}/docker-compose.yml"

# Resolve main repo + mode-specific state (Story 2.11: per-fork vs shared via
# KEEL_DEVBOX_SHARED). Without mode resolution, `docker compose stop` under
# shared mode would target `keel-devbox` (per-fork default) and silently skip
# the `keel-devbox-shared` project — a correctness regression.
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
resolve_ssh_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"
# shellcheck source=lib/compose-args.sh
source "${SCRIPT_DIR}/lib/compose-args.sh"
resolve_compose_args

log() { printf 'stop: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Subsumes the former inline `docker info` probe.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

log "docker compose stop devbox (keel_home_dev preserved)"
exec docker compose "${COMPOSE_ARGS[@]}" stop devbox
