#!/usr/bin/env bash
#
# Story 2.7 host-side wrapper — Ralph plan mode
#
# Purpose: FR2 invocation path. Auto-starts the devbox if not running, then
# attaches the operator terminal to the container's PID 1 stdio via
# `docker attach --detach-keys='ctrl-p,ctrl-q'`. The in-container Ralph
# runtime (Epic 3) consumes KEEL_RALPH_MODE to select PROMPT_<mode>.md.
#
# Ctrl+P Ctrl+Q detaches without killing the container (docker default,
# pinned explicitly via --detach-keys to guard against future
# docker-default changes; Story 2.6 attach.sh:39 precedent).
#
# Exit codes (Story 2.6 uniform schema):
#   0   clean detach.
#   8   docker runtime unreachable.
#   9   container not running (post-auto-start fallback only).
#   10  image not built (propagated from start.sh).
#   11  healthcheck timeout (propagated from start.sh).
#   *   docker attach error (propagated).

set -euo pipefail

# Story 2.6 AI-8 + AI-12: unset COMPOSE_PROJECT_NAME to pin compose identity
# to docker-compose.yml's 'name: keel-devbox'. Operator-shell override would
# redirect volume paths away from INV-devbox-homedev-named-volume.
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"
RALPH_MODE="plan"

log() { printf '[ralph:%s] %s\n' "${RALPH_MODE}" "$*" >&2; }

# Pre-flight: docker daemon reachable (exit 8 per Story 2.6 schema).
if ! docker info --format '{{.ServerVersion}}' >/dev/null 2>&1; then
  log "docker unreachable — is the daemon running?"
  exit 8
fi

# State inspect: container running? (Auto-start if not.)
status="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"

if [[ "${status}" != "running" ]]; then
  log "container '${CONTAINER_NAME}' not running; invoking start.sh (auto-start per AC 1)"
  "${SCRIPT_DIR}/start.sh" || exit $?
  # Rare race: start.sh returned 0 but the container exited between
  # its success and our re-inspect. Emit exit 9 per Story 2.6 schema.
  status="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
  if [[ "${status}" != "running" ]]; then
    log "container not running after start.sh succeeded (check 'pnpm devbox:logs')"
    exit 9
  fi
else
  log "container '${CONTAINER_NAME}' already running; attaching directly (AC 2 skip-start)"
fi

# Mode signal: Epic 3's in-container Ralph runtime reads KEEL_RALPH_MODE
# at startup to select .ralph/PROMPT_<mode>.md.
export KEEL_RALPH_MODE="${RALPH_MODE}"

log "attaching to ${CONTAINER_NAME} (mode: ${RALPH_MODE}; detach: Ctrl+P Ctrl+Q)"
# No signal trapping — docker attach passes SIGINT/SIGTERM/SIGPIPE
# directly to PID 1. Defensive trap handlers would break passthrough.
exec docker attach --detach-keys='ctrl-p,ctrl-q' "${CONTAINER_NAME}"
