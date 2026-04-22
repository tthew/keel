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

CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

log() { printf 'attach: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
	log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
	exit 9
fi

log "attaching to ${CONTAINER_NAME} (detach: Ctrl+P Ctrl+Q)"
exec docker attach --detach-keys='ctrl-p,ctrl-q' "${CONTAINER_NAME}"
