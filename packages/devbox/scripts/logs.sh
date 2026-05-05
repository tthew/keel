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

# AI-8 (Story 2.6 CR iter-212): operator-shell COMPOSE_PROJECT_NAME export
# would redirect compose's project identity away from `name: keel-devbox` and
# break the `keel-devbox_keel_home_dev` volume path (INV-devbox-homedev-named-volume).
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${DEVBOX_DIR}/docker-compose.yml"

# Resolve main repo + mode-specific state (Story 2.11: per-fork vs shared via
# KEEL_DEVBOX_SHARED). Without mode resolution, `docker compose logs` under
# shared mode would target `keel-devbox` (per-fork default) and silently return
# no output — operator confusion.
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
resolve_ssh_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"
# shellcheck source=lib/compose-args.sh
source "${SCRIPT_DIR}/lib/compose-args.sh"
resolve_compose_args

log() { printf 'logs: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Subsumes the former inline `docker info` probe.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

if [[ $# -eq 0 ]]; then
	exec docker compose "${COMPOSE_ARGS[@]}" logs -f --tail=100 devbox
fi

exec docker compose "${COMPOSE_ARGS[@]}" logs "$@" devbox
