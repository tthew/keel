#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/rebuild.sh — Story 2.6 (AC 2)
#
# Rebuild the keel-devbox image from scratch (`--no-cache`). Used after a
# Dockerfile edit or to recover from layer corruption. Operator invokes as
# `pnpm devbox:rebuild` from the repo root.
#
# Backend-B discipline (docs/invariants/devbox-dind.md): `--no-cache`
# invalidates only the keel-devbox service cache. It does NOT prune unrelated
# host images, so no broad-prune guard is required here (contrast clean.sh).
#
# Exit codes (SC-5):
#   0   success.
#   8   docker runtime unreachable.
#   *   docker/compose build error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${DEVBOX_DIR}/docker-compose.yml"

# Resolve main repo + mode-specific state (Story 2.11: per-fork vs shared via
# KEEL_DEVBOX_SHARED). Mirrors build.sh rationale — compose `name:`
# interpolation + downstream mode consistency.
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"

log() { printf 'rebuild: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Subsumes the former inline `docker info` probe; emits install-pointer on
# exit 8. No token gating here — image rebuild does not need tokens.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

log "docker compose build --no-cache devbox (fresh)"
exec docker compose -f "${COMPOSE_FILE}" build --no-cache devbox
