#!/usr/bin/env bash
#
# Story 2.7 host-side wrapper — Ralph build mode
#
# Purpose: FR2 invocation path. Auto-starts the devbox if not running, then
# launches the Ralph TUI inside the container via `docker exec -it … uv
# run ralph.py build`. Story 2.7's original `docker attach` design assumed
# Epic 3's in-container Ralph runtime ran as PID 1 — until Epic 3 lands,
# PID 1 is `gosu dev sleep infinity` (the keepalive) and `docker attach`
# would block on a sleeping process. `docker exec` runs ralph in an
# operator-tty subprocess; SIGINT (Ctrl+C) terminates ralph cleanly while
# the container keeps running for subsequent invocations.
#
# Extra arguments are passed through to ralph.py (e.g. `pnpm ralph:build
# --iterations 5`, `pnpm ralph:build --worktree X`).
#
# Exit codes (Story 2.6 uniform schema):
#   0   ralph.py exited cleanly (loop completed or operator interrupted).
#   8   docker runtime unreachable.
#   9   container not running (post-auto-start fallback only).
#   10  image not built (propagated from start.sh).
#   11  healthcheck timeout (propagated from start.sh).
#   12  bind-mount source mismatch — run `pnpm devbox:restart` (iter-239).
#   *   docker exec or ralph.py exit code (propagated).

set -euo pipefail

# Story 2.6 AI-8 + AI-12: unset COMPOSE_PROJECT_NAME to pin compose identity
# to docker-compose.yml's 'name: keel-devbox'. Operator-shell override would
# redirect volume paths away from INV-devbox-homedev-named-volume.
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"
RALPH_MODE="build"

# Resolve MAIN_REPO + REPO_NAME + CONTAINER_WORKDIR (iter-239 mount-path
# mirroring): ralph.py inherits the worktree-aware cwd via -w, so its
# `--worktree X` / `_main_repo_root()` resolution lands the correct
# .ralph/ directory automatically.
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
# shellcheck source=lib/check-mount-source.sh
source "${SCRIPT_DIR}/lib/check-mount-source.sh"

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
  log "container '${CONTAINER_NAME}' already running; launching ralph directly (AC 2 skip-start)"
fi

# Pre-flight: bind-mount source matches current main repo. Exits 12 on
# mismatch with a `pnpm devbox:restart` hint.
check_mount_source

# Mode signal: Epic 3's in-container Ralph runtime will read KEEL_RALPH_MODE
# to select .ralph/PROMPT_<mode>.md. Passed via `docker exec -e` so the
# variable lands in the ralph.py process environment (NOT the container's
# global env, which docker exec cannot mutate after container start).
log "launching ralph TUI in ${CONTAINER_NAME} (mode: ${RALPH_MODE}; cwd ${CONTAINER_WORKDIR}; Ctrl+C to exit)"
# No signal trapping — docker exec -it forwards SIGINT/SIGTERM directly
# to ralph.py. Defensive trap handlers would break passthrough.
exec docker exec -it --user dev -w "${CONTAINER_WORKDIR}" \
  -e "KEEL_RALPH_MODE=${RALPH_MODE}" \
  -e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" \
  "${CONTAINER_NAME}" uv run ralph.py "${RALPH_MODE}" "$@"
