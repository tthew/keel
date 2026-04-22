#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/logs.sh — Story 2.6 (AC 7)
#
# Tail container logs via `docker compose logs`. Default: follow-mode with a
# 100-line backlog. Flags forwarded to compose verbatim — operators pass
# `--no-follow` / `--tail=<N>` / `--since <ts>` etc.
#
# Exit codes (SC-5):
#   0   clean detach (SIGINT in follow mode; `--no-follow` complete).
#   8   docker runtime unreachable.
#   *   docker/compose error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${DEVBOX_DIR}/docker-compose.yml"

log() { printf 'logs: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

if [[ $# -eq 0 ]]; then
	exec docker compose -f "${COMPOSE_FILE}" logs -f --tail=100 devbox
fi

exec docker compose -f "${COMPOSE_FILE}" logs "$@" devbox
