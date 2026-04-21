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

# Validate WORKSPACE_OWNER shape before passing to chown.
#
# CR AI-5 (iter-133): the env-var is operator-settable via `.envrc` /
# compose `environment:` / `docker run -e`. Without validation a value like
# `--reference=/etc/shadow` would be re-parsed by chown as a flag and could
# mirror arbitrary file ownership onto /workspace. Accept only the canonical
# `user:group` shape with POSIX-portable characters. `chown --` on every
# call is belt-and-braces: terminates option parsing so even if the regex is
# relaxed in the future, `-`-prefixed owners cannot be re-interpreted as
# flags. Trust boundary here is low (operator writes their own `.envrc`),
# but defence in depth costs nothing.
if [[ ! "${WORKSPACE_OWNER}" =~ ^[A-Za-z0-9_-]+:[A-Za-z0-9_-]+$ ]]; then
  echo "entrypoint.sh: invalid KEEL_DEVBOX_WORKSPACE_OWNER='${WORKSPACE_OWNER}'" \
    "(expected 'user:group' with [A-Za-z0-9_-]+); refusing chown" >&2
  exit 2
fi

# Workspace mount — the compose bind maps the monorepo root to /workspace.
# Ensure the directory is traversable even when the host mount arrives with
# a different ownership (common on macOS + Apple Silicon Docker Desktop).
#
# CR AI-5 (iter-133): replaces the iter-99 blanket `|| true` with narrower
# handling — capture chown's stderr, re-emit on failure to the container's
# stderr (visible in `docker compose logs`), then continue. Preserves the
# best-effort posture (the bind mount itself is the source of truth for
# host-side ownership on backend B) while making unexpected failures
# diagnosable instead of silently swallowed.
if [[ -d /workspace ]]; then
  if ! chown -- "${WORKSPACE_OWNER}" /workspace 2>/tmp/chown.err; then
    cat /tmp/chown.err >&2 || true
  fi
  rm -f /tmp/chown.err
fi

# Named-volume directory bring-up — Stories 2.8 / 2.9 materialise the OAuth
# token payloads into these paths via compose-level named volumes. The dirs
# are pre-created by the Dockerfile; re-asserting here is idempotent and
# safe when the volume arrives empty on first boot.
for dir in /home/dev/.claude /home/dev/.config/gh; do
  if [[ ! -d "${dir}" ]]; then
    mkdir -p "${dir}"
  fi
  if ! chown -- "${WORKSPACE_OWNER}" "${dir}" 2>/tmp/chown.err; then
    cat /tmp/chown.err >&2 || true
  fi
  rm -f /tmp/chown.err
done

# Hand off to the compose CMD (defaults to `sleep infinity`). Using `exec`
# preserves PID 1 for the supplied process so docker-compose signals
# (SIGTERM / SIGINT) land on the service, not on bash.
#
# CR AI-5 (iter-133): empty-CMD fallback. `docker run keel-devbox:local`
# without a CMD (operator probing the image) AND a compose service that
# somehow reaches the entrypoint without a command would previously hit
# `exec "$@"` with zero arguments — bash interprets `exec` with no command
# as a no-op that returns to the caller, and because this is the last line
# of the script `set -e` would let the container exit cleanly but with no
# keepalive. Guard the empty case so the container stays alive for
# iteration work. The compose file's CMD (`sleep infinity`) is the primary
# path; this fallback is defence against direct `docker run` probing.
if [ "$#" -eq 0 ]; then
  exec sleep infinity
else
  exec "$@"
fi
