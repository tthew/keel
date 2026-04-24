#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/status.sh — Story 2.6 (AC 7)
#
# Print container state + healthcheck status. Status-reporting is not itself
# an error — a stopped container exits 0 with a `stopped` line. The only
# error path is when the container object doesn't exist at all (pre-first-
# start) — that exits 9.
#
# Exit codes (SC-5):
#   0   reported successfully (including stopped container).
#   8   docker runtime unreachable.
#   9   container object does not exist (run `pnpm devbox:start` first).
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
# KEEL_DEVBOX_SHARED). Without mode resolution, `docker inspect` + `docker
# compose ps` under shared mode would target the wrong project/container — a
# correctness regression on mode-flipped operator shells.
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
resolve_ssh_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"

log() { printf 'status: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Subsumes the former inline `docker info` probe.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

if ! docker inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
	log "container '${CONTAINER_NAME}' does not exist — run 'pnpm devbox:start' first"
	exit 9
fi

docker compose -f "${COMPOSE_FILE}" ${KEEL_DEVBOX_COMPOSE_FILE_SSH:+-f "${KEEL_DEVBOX_COMPOSE_FILE_SSH}"} ps devbox || true

health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}(no healthcheck configured){{end}}' "${CONTAINER_NAME}" 2>/dev/null || echo "(inspect failed)")"
state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || echo "unknown")"

printf 'state:       %s\n' "${state}"
printf 'healthcheck: %s\n' "${health}"
