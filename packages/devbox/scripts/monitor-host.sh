#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/monitor-host.sh — Story 2.6 (AC 7, SC-15)
#
# Host-side shim around the Story 2.3 in-container JSONL egress-log tailer
# (`packages/devbox/scripts/monitor.sh`). PRD § CLI-Tool Surface (prd.md:494)
# + architecture § Devbox Package Tree (architecture.md:1003) pin the
# semantic: `pnpm devbox:monitor` is the FR1a JSONL DNS-event tail, NOT a
# `docker stats`-style cpu/memory view. Epics AC 7's "cpu/memory/network"
# phrasing is historical drift from the PRD; PRD is authoritative.
#
# Exit codes (SC-5):
#   0   clean detach (SIGINT from tail -F).
#   3   in-container primitive missing — rebuild via `pnpm devbox:build`.
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first.
#   *   docker exec / tail error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

log() { printf 'monitor: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
	log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
	exit 9
fi

# Pre-flight: in-container primitive present on host filesystem (bind-mounted
# via the workspace mount).
if [[ ! -f "${DEVBOX_DIR}/scripts/monitor.sh" ]]; then
	log "in-container primitive 'monitor.sh' missing — rebuild via 'pnpm devbox:build'"
	exit 3
fi

exec docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/monitor.sh "$@"
