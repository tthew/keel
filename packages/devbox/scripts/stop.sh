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

log() { printf 'stop: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

log "docker compose stop devbox (keel_home_dev preserved)"
exec docker compose -f "${COMPOSE_FILE}" stop devbox
