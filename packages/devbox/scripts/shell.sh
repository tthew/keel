#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/shell.sh — Story 2.6 (AC 5)
#
# Open an interactive login shell as the `dev` user in the running container,
# starting at /workspace. Forwards extra args to bash (`pnpm devbox:shell -c
# 'whoami'` is valid for non-interactive verification).
#
# Exit codes (SC-5):
#   0   clean shell exit (or forwarded command rc).
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first.
#   *   docker exec error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

log() { printf 'shell: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
	log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
	exit 9
fi

if [[ $# -gt 0 ]]; then
	# Non-interactive forwarded command (e.g., `pnpm devbox:shell -c 'id'`).
	exec docker exec -i --user dev -w /workspace "${CONTAINER_NAME}" bash -l "$@"
fi

exec docker exec -it --user dev -w /workspace "${CONTAINER_NAME}" bash -l
