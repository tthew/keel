#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/claude-host.sh — Story 2.8
#
# FR3 Claude-side invocation path. Runs `claude` inside the running devbox
# container as UID 1000 (`dev` user) with the operator terminal attached
# interactively. First invocation triggers the Claude Code OAuth flow: the
# URL surfaces on stdout, operator opens URL in a host browser, optionally
# pastes a code, token persists at /home/dev/.claude/ inside the
# `keel_home_dev` named volume (Story 2.5 substrate; NFR10).
#
# Subsequent invocations (token already present) are no-ops at the auth
# layer — claude detects existing token and proceeds to its default
# interactive session (or to args-passed behaviour, e.g. `pnpm claude
# --version`, `pnpm claude -p "hello"`).
#
# Exit codes (Story 2.6 uniform schema):
#   0   clean exit (auth complete, or claude's own clean exit).
#   2   usage error (unused at 1.0 — wrapper delegates arg validation to claude).
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first (no auto-start
#       per SC-4; auth is a one-off, not a loop-entry gesture).
#   *   claude or docker exec error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

# Story 2.6 AI-8 + AI-12 + Story 2.7 SC-10: unset COMPOSE_PROJECT_NAME
# defensively to pin compose identity to docker-compose.yml's `name:
# keel-devbox`. Operator-shell override would redirect volume paths away
# from INV-devbox-homedev-named-volume.
unset COMPOSE_PROJECT_NAME

# SC-4 no-auto-start → no sub-invoke of start.sh → no need for SCRIPT_DIR
# (contrast Story 2.7 ralph-build-host.sh:29+46 which DOES set + use it).
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

log() { printf '[claude] %s\n' "$*" >&2; }

# Pre-flight 1: docker daemon reachable (exit 8 per Story 2.6 schema).
if ! docker info --format '{{.ServerVersion}}' >/dev/null 2>&1; then
  log "docker unreachable — is the daemon running?"
  exit 8
fi

# Pre-flight 2: container is running. No auto-start — auth is a one-off
# operator gesture, not a loop-entry gesture (SC-4; contrast
# ralph-build-host.sh which DOES auto-start per Story 2.7 SC-1).
state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
  log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
  exit 9
fi

log "invoking claude inside ${CONTAINER_NAME} (first run: complete OAuth in host browser; token persists at /home/dev/.claude/)"
# No signal trapping — docker exec forwards SIGINT/SIGTERM/SIGPIPE to
# claude's PID inside the container. Defensive trap handlers would break
# passthrough (Story 2.1 iter-144 SIGPIPE precedent; Story 2.7 v1.1 PATCH 3).
exec docker exec -it --user dev -w /workspace "${CONTAINER_NAME}" claude "$@"
