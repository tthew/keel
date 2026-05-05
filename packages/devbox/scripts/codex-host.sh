#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/codex-host.sh
#
# Codex-side invocation path (mirrors claude-host.sh). Runs `codex` inside
# the running devbox container as UID 1000 (`dev` user) with the operator
# terminal attached interactively. First invocation triggers the OpenAI
# "Sign in with ChatGPT" OAuth flow; the auth payload persists at
# /home/dev/.codex/auth.json inside the `keel_home_dev` named volume
# (Story 2.5 substrate; NFR10).
#
# Subsequent invocations (auth already present) reuse the persisted token
# and proceed to codex's default interactive REPL (or to args-passed
# behaviour, e.g. `pnpm codex --version`, `pnpm codex exec "hello"`).
#
# `--dangerously-bypass-approvals-and-sandbox` is hard-coded as the FIRST
# argument so codex parses it as a top-level flag before any subcommand
# the operator passes via "$@". The flag suppresses approval prompts and
# disables the codex-side sandbox — consistent with running inside the
# devbox where the egress whitelist + cap_drop posture already provide the
# isolation contract. Operators wanting the un-bypassed posture invoke
# `codex` directly via `pnpm devbox:shell` instead of this wrapper.
#
# For explicit re-auth (`codex login`), use `pnpm codex:auth` —
# codex-auth-host.sh routes around this flag because `codex login` does
# not accept it.
#
# Exit codes (Story 2.6 uniform schema):
#   0   clean exit (auth complete, or codex's own clean exit).
#   2   usage error (unused at 1.0 — wrapper delegates arg validation to codex).
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first (no auto-start
#       per SC-4; auth is a one-off, not a loop-entry gesture).
#   12  bind-mount source mismatch — run `pnpm devbox:restart` (iter-239).
#   *   codex or docker exec error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

# Story 2.6 AI-8 + AI-12 + Story 2.7 SC-10: unset COMPOSE_PROJECT_NAME
# defensively to pin compose identity to docker-compose.yml's `name:
# keel-devbox`. Operator-shell override would redirect volume paths away
# from INV-devbox-homedev-named-volume.
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

log() { printf '[codex] %s\n' "$*" >&2; }

# Pre-flight 1: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# Tier 1 (not Tier 2): `pnpm codex` IS the auth-establishing verb for
# Codex CLI on first run — Tier 2 would be circular (require the token
# we're about to create). Mirrors claude-host.sh / gh-auth-host.sh.
"${SCRIPT_DIR}/prereq-check.sh" --tier1

# Pre-flight 2: container is running. No auto-start — auth is a one-off
# operator gesture, not a loop-entry gesture (SC-4; mirror claude-host.sh
# and gh-auth-host.sh posture).
state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
  log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
  exit 9
fi

# Pre-flight 3: bind-mount source matches current main repo. Exits 12 on
# mismatch with a `pnpm devbox:restart` hint.
check_mount_source

log "invoking codex inside ${CONTAINER_NAME} (first run: complete OpenAI sign-in flow; auth persists at /home/dev/.codex/)"
# No signal trapping — docker exec forwards SIGINT/SIGTERM/SIGPIPE to
# codex's PID inside the container (Story 2.1 iter-144 SIGPIPE precedent;
# Story 2.7 v1.1 PATCH 3; Story 2.8 SC-10).
exec docker exec -it --user dev -w "${CONTAINER_WORKDIR}" \
  -e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" \
  "${CONTAINER_NAME}" codex --dangerously-bypass-approvals-and-sandbox "$@"
