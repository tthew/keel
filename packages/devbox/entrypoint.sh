#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/entrypoint.sh — Story 2.1 scope
#
# Narrowed surface (AC 2, AC 2-entrypoint-narrow). Every toolchain install
# MUST happen at image-build time (Dockerfile); this script contains:
#
#   1. workspace ownership chown (Story 2.5 replaces the root placeholder
#      with a non-root `dev` user);
#   2. named-volume directory bring-up for /home/dev/.claude/ and
#      /home/dev/.config/gh/ so Stories 2.8 / 2.9 OAuth mounts succeed on
#      first boot even when the named volume is empty;
#   3. service keepalive via `exec "$@"` (compose CMD defaults to
#      `sleep infinity`).
#
# Forbidden at runtime (Story 2.1 AC 2): no invocations of apt / npm / pip /
# uv / pipe-to-sh installers. The Task 7 structural check enforces this with
# a grep against the committed file — keep every install at image-build time.
#
# Hardening, egress policy, healthcheck, and OAuth token materialisation land
# in Stories 2.3 / 2.4 / 2.5 / 2.8 / 2.9 / 2.13 respectively.
# ---------------------------------------------------------------------------
set -euo pipefail

# TODO(Story 2.5): replace `root:root` with the non-root `dev:dev` user.
WORKSPACE_OWNER="${KEEL_DEVBOX_WORKSPACE_OWNER:-root:root}"

# Workspace mount — the compose bind maps the monorepo root to /workspace.
# Ensure the directory is traversable even when the host mount arrives with
# a different ownership (common on macOS + Apple Silicon Docker Desktop).
if [[ -d /workspace ]]; then
  chown "${WORKSPACE_OWNER}" /workspace || true
fi

# Named-volume directory bring-up — Stories 2.8 / 2.9 materialise the OAuth
# token payloads into these paths via compose-level named volumes. The dirs
# are pre-created by the Dockerfile; re-asserting here is idempotent and
# safe when the volume arrives empty on first boot.
for dir in /home/dev/.claude /home/dev/.config/gh; do
  if [[ ! -d "${dir}" ]]; then
    mkdir -p "${dir}"
  fi
  chown "${WORKSPACE_OWNER}" "${dir}" || true
done

# Hand off to the compose CMD (defaults to `sleep infinity`). Using `exec`
# preserves PID 1 for the supplied process so docker-compose signals
# (SIGTERM / SIGINT) land on the service, not on bash.
exec "$@"
