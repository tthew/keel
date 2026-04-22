#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/whitelist-host.sh — Story 2.6 (AC 9, SC-16)
#
# Host-side shim around the Story 2.4 in-container whitelist CLI
# (`packages/devbox/scripts/whitelist.sh`). Thin passthrough — all argument
# validation + subcommand dispatch lives in the in-container primitive
# (avoids dual-source-of-truth drift).
#
# Exit codes (SC-5):
#   0/2/3/4/5/6/7  propagated verbatim from whitelist.sh.
#   8              docker runtime unreachable.
#   9              container not running — run `pnpm devbox:start` first.
# ---------------------------------------------------------------------------
set -euo pipefail

CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

log() { printf 'whitelist: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
	log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
	exit 9
fi

exec docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/whitelist.sh "$@"
