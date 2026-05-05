#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/codex-auth-host.sh
#
# Codex auth-establishing path. Mirrors gh-auth-host.sh: runs `codex login`
# inside the running devbox container as UID 1000 (`dev` user) so the
# operator can complete OpenAI's "Sign in with ChatGPT" / API-key OAuth
# flow once. Auth payload persists at /home/dev/.codex/auth.json inside
# the `keel_home_dev` named volume (Story 2.5 substrate; NFR10). Subsequent
# `pnpm codex` invocations reuse the persisted token without re-auth.
#
# `--dangerously-bypass-approvals-and-sandbox` is INTENTIONALLY OMITTED
# here — `codex login` is the auth subcommand, not the agent loop, and
# does not accept the bypass flag. For normal (post-auth) codex use, route
# through `pnpm codex` (codex-host.sh) which prepends the bypass flag.
#
# Args passthrough: additional flags reach `codex login` verbatim, e.g.
# `pnpm codex:auth --api-key sk-...` for non-OAuth API-key configurations.
#
# Exit codes (Story 2.6 uniform schema):
#   0   clean exit (auth complete, or codex's own clean exit).
#   2   usage error (unused at 1.0 — wrapper delegates arg validation to codex).
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first (no auto-start
#       per SC-4; auth is a one-off, not a loop-entry gesture).
#   12  bind-mount source mismatch — run `pnpm devbox:restart` (iter-239).
#   *   codex or docker exec error (propagated — including codex non-zero
#       on OAuth timeout / cancellation).
# ---------------------------------------------------------------------------
set -euo pipefail

# Story 2.6 AI-8 + AI-12 + Story 2.7 SC-10 + Story 2.8 SC-8: unset
# COMPOSE_PROJECT_NAME defensively to pin compose identity to
# docker-compose.yml's `name: keel-devbox`. Operator-shell override
# would redirect volume paths away from INV-devbox-homedev-named-volume.
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"
# shellcheck source=lib/check-mount-source.sh
source "${SCRIPT_DIR}/lib/check-mount-source.sh"

log() { printf '[codex-auth] %s\n' "$*" >&2; }

# Pre-flight 1: Tier 1 prereq-check (Docker runtime reachable). Tier 1 (not
# Tier 2): this IS the auth-establishing verb for Codex CLI — Tier 2 would
# be circular. Mirrors claude-host.sh / gh-auth-host.sh.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

# Pre-flight 2: container is running. No auto-start — auth is a one-off
# operator gesture (SC-4; mirror claude-host.sh + gh-auth-host.sh).
state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
  log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
  exit 9
fi

# Pre-flight 3: bind-mount source matches current main repo. Exits 12 on
# mismatch with a `pnpm devbox:restart` hint.
check_mount_source

# `--device-auth` is the load-bearing default for the no-args path: the
# devbox container has no browser AND no localhost-callback listener path
# back to the host's browser, so codex's default OAuth flow short-circuits
# with `On a remote or headless machine? Use 'codex login --device-auth'
# instead.` and exits non-zero. Device-auth prints a short URL + code that
# the operator visits on the host browser, completing OAuth out-of-band;
# the resulting token persists at /home/dev/.codex/auth.json the same way
# the browser-callback path would. Inject it only on the no-args path so
# the API-key passthrough (`pnpm codex:auth --api-key sk-...`) the line-17
# comment promises stays intact — operators passing flags are taking
# explicit control of the codex login subcommand surface.
log "invoking codex login --device-auth inside ${CONTAINER_NAME} (visit the printed URL on the host browser; auth persists at /home/dev/.codex/)"
# No signal trapping — docker exec forwards signals to codex's PID inside
# the container (Story 2.1 iter-144; Story 2.7 v1.1 PATCH 3).
if [[ $# -eq 0 ]]; then
  exec docker exec -it --user dev -w "${CONTAINER_WORKDIR}" \
    -e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" \
    "${CONTAINER_NAME}" codex login --device-auth
else
  exec docker exec -it --user dev -w "${CONTAINER_WORKDIR}" \
    -e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" \
    "${CONTAINER_NAME}" codex login "$@"
fi
