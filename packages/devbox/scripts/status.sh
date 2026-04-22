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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${DEVBOX_DIR}/docker-compose.yml"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

log() { printf 'status: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

if ! docker inspect "${CONTAINER_NAME}" >/dev/null 2>&1; then
	log "container '${CONTAINER_NAME}' does not exist — run 'pnpm devbox:start' first"
	exit 9
fi

docker compose -f "${COMPOSE_FILE}" ps devbox || true

health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}(no healthcheck configured){{end}}' "${CONTAINER_NAME}" 2>/dev/null || echo "(inspect failed)")"
state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || echo "unknown")"

printf 'state:       %s\n' "${state}"
printf 'healthcheck: %s\n' "${health}"
