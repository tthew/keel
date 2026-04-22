#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/whitelist-host.sh — Story 2.6 (AC 9, SC-16)
#
# Host-side shim around the Story 2.4 in-container whitelist CLI
# (`packages/devbox/scripts/whitelist.sh`). Thin passthrough — all argument
# validation + subcommand dispatch lives in the in-container primitive
# (avoids dual-source-of-truth drift).
#
# Exit codes (SC-5):
#   0/2/3/4/5/6/7  propagated verbatim from whitelist.sh.
#   8              docker runtime unreachable.
#   9              container not running — run `pnpm devbox:start` first.
# ---------------------------------------------------------------------------
set -euo pipefail

# AI-8 (Story 2.6 CR iter-212): operator-shell COMPOSE_PROJECT_NAME export
# would redirect compose's project identity away from `name: keel-devbox` and
# break the `keel-devbox_keel_home_dev` volume path (INV-devbox-homedev-named-volume).
unset COMPOSE_PROJECT_NAME

CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

log() { printf 'whitelist: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
	log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
	exit 9
fi

# AI-9 (Story 2.6 CR iter-213): `--user dev` pin matches shell.sh:39,42.
# Image default USER is dev (Story 2.5 Dockerfile), so today this is an
# explicit-pin not a posture change; guards against a fork's
# docker-compose.override.yml flipping `user: root` and causing whitelist
# mutations to write /run/keel-whitelist-mutate.lock + whitelist.local.txt
# with root ownership — a subsequent `dev`-user mutation would then fail.
exec docker exec -it --user dev "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/whitelist.sh "$@"
