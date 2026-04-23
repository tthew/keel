#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/gh-auth-host.sh — Story 2.9
#
# FR3 gh-side invocation path. Runs `gh auth login` inside the running devbox
# container as UID 1000 (`dev` user) with the operator terminal attached
# interactively. First invocation triggers the GitHub OAuth flow: the
# URL + one-time code surface on stdout, operator opens URL in a host
# browser, pastes the code, token persists at /home/dev/.config/gh/ inside
# the `keel_home_dev` named volume (Story 2.5 substrate; NFR10). Ralph
# subsequently uses the token for `gh push` / `gh pr view` / `gh pr checks`
# inside the container without re-auth.
#
# Args passthrough: additional flags reach `gh auth login` verbatim, e.g.
# `pnpm gh:auth --web`, `pnpm gh:auth --hostname github.com`,
# `pnpm gh:auth --scopes "repo,workflow"`. Args to other `gh` subcommands
# are NOT supported — the wrapper is scoped to `auth login`; operators
# wanting generic `gh` composition should use `pnpm devbox:shell` then
# invoke `gh` inside the shell.
#
# Exit codes (Story 2.6 uniform schema):
#   0   clean exit (auth complete, or gh's own clean exit).
#   2   usage error (unused at 1.0 — wrapper delegates arg validation to gh).
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first (no auto-start
#       per SC-4; auth is a one-off, not a loop-entry gesture).
#   12  bind-mount source mismatch — run `pnpm devbox:restart` (iter-239).
#   *   gh or docker exec error (propagated — including gh non-zero on
#       OAuth timeout / cancellation / GitHub rate-limit).
# ---------------------------------------------------------------------------
set -euo pipefail

# Story 2.6 AI-8 + AI-12 + Story 2.7 SC-10 + Story 2.8 SC-8: unset
# COMPOSE_PROJECT_NAME defensively to pin compose identity to
# docker-compose.yml's `name: keel-devbox`. Operator-shell override
# would redirect volume paths away from INV-devbox-homedev-named-volume.
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

# Resolve MAIN_REPO + REPO_NAME + CONTAINER_WORKDIR (iter-239 mount-path
# mirroring).
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
# shellcheck source=lib/check-mount-source.sh
source "${SCRIPT_DIR}/lib/check-mount-source.sh"

log() { printf '[gh-auth] %s\n' "$*" >&2; }

# Pre-flight 1: docker daemon reachable (exit 8 per Story 2.6 schema;
# tighter `--format '{{.ServerVersion}}'` variant per Story 2.7 + 2.8
# inheritance chain).
if ! docker info --format '{{.ServerVersion}}' >/dev/null 2>&1; then
  log "docker unreachable — is the daemon running?"
  exit 8
fi

# Pre-flight 2: container is running. No auto-start — auth is a one-off
# operator gesture, not a loop-entry gesture (SC-4; contrast
# ralph-build-host.sh which DOES auto-start per Story 2.7 SC-1; mirror
# claude-host.sh posture).
state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
  log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
  exit 9
fi

# Pre-flight 3: bind-mount source matches current main repo. Exits 12 on
# mismatch with a `pnpm devbox:restart` hint.
check_mount_source

log "invoking gh auth login inside ${CONTAINER_NAME} (first run: complete OAuth in host browser; token persists at /home/dev/.config/gh/)"
# No signal trapping — docker exec forwards SIGINT/SIGTERM/SIGPIPE to
# gh's PID inside the container. Defensive trap handlers would break
# passthrough (Story 2.1 iter-144 SIGPIPE precedent; Story 2.7 v1.1
# PATCH 3; Story 2.8 SC-10).
exec docker exec -it --user dev -w "${CONTAINER_WORKDIR}" \
  -e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" \
  "${CONTAINER_NAME}" gh auth login "$@"
