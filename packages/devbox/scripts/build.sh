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

# Resolve main repo + mode-specific state (Story 2.11: per-fork vs shared via
# KEEL_DEVBOX_SHARED). build.sh does not inspect the container by name, but
# `docker compose build` reads the top-level `name:` from compose — we export
# KEEL_DEVBOX_COMPOSE_PROJECT + KEEL_DEVBOX_CONTAINER_NAME so downstream
# `pnpm devbox:start` invocations from the same shell inherit consistent mode.
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
resolve_ssh_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"

log() { printf 'build: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Subsumes the former inline `docker info` probe; emits install-pointer on
# exit 8. No token gating here — image build does not need tokens.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

log "docker compose build devbox (cached)"
exec docker compose -f "${COMPOSE_FILE}" ${KEEL_DEVBOX_COMPOSE_FILE_SSH:+-f "${KEEL_DEVBOX_COMPOSE_FILE_SSH}"} build devbox
