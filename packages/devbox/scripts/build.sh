#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/build.sh — Story 2.6 (AC 2)
#
# Build the keel-devbox image via docker compose (cache-friendly). Operator
# invokes as `pnpm devbox:build` from the repo root. Companion: rebuild.sh
# (same semantics + `--no-cache`).
#
# Exit codes (SC-5 uniform across devbox CLI family):
#   0   success — image built (or already cached).
#   8   docker runtime unreachable (`docker info` failed).
#   *   docker/compose build error (propagated verbatim).
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${DEVBOX_DIR}/docker-compose.yml"

log() { printf 'build: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Subsumes the former inline `docker info` probe; emits install-pointer on
# exit 8. No token gating here — image build does not need tokens.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

log "docker compose build devbox (cached)"
exec docker compose -f "${COMPOSE_FILE}" build devbox
