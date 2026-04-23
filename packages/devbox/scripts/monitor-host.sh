#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/monitor-host.sh — Story 2.6 (AC 7, SC-15)
#
# Host-side shim around the Story 2.3 in-container JSONL egress-log tailer
# (`packages/devbox/scripts/monitor.sh`). PRD § CLI-Tool Surface (prd.md:494)
# + architecture § Devbox Package Tree (architecture.md:1003) pin the
# semantic: `pnpm devbox:monitor` is the FR1a JSONL DNS-event tail, NOT a
# `docker stats`-style cpu/memory view. Epics AC 7's "cpu/memory/network"
# phrasing is historical drift from the PRD; PRD is authoritative.
#
# Exit codes (SC-5):
#   0   clean detach (SIGINT from tail -F).
#   3   in-container primitive missing from the host-side repo checkout.
#       `monitor.sh` is bind-mounted from `packages/devbox/scripts/` (not
#       baked into the image); `docker compose build` does NOT restore a
#       missing repo file. Restore via `git checkout
#       packages/devbox/scripts/monitor.sh` or re-clone.
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first.
#   12  bind-mount source mismatch — run `pnpm devbox:restart` (iter-239).
#   *   docker exec / tail error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

# AI-8 (Story 2.6 CR iter-212): operator-shell COMPOSE_PROJECT_NAME export
# would redirect compose's project identity away from `name: keel-devbox` and
# break the `keel-devbox_keel_home_dev` volume path (INV-devbox-homedev-named-volume).
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
# shellcheck source=lib/check-mount-source.sh
source "${SCRIPT_DIR}/lib/check-mount-source.sh"

log() { printf 'monitor: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
	log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
	exit 9
fi

check_mount_source

# Pre-flight: in-container primitive present on host filesystem. `monitor.sh`
# is bind-mounted into the container via the workspace mount — a rebuild
# (`pnpm devbox:build`) does NOT restore it; `git checkout` does.
if [[ ! -f "${DEVBOX_DIR}/scripts/monitor.sh" ]]; then
	log "monitor.sh missing from packages/devbox/scripts/ — restore via 'git checkout packages/devbox/scripts/monitor.sh'"
	exit 3
fi

# AI-10 (Story 2.6 CR iter-214): TTY-detect stdin before passing `-t` to
# `docker exec`. Hardcoded `-it` fails under non-TTY callers (CI runners,
# `pnpm devbox:monitor | tee run.log`, subprocess invocation) with "the
# input device is not a TTY". `-i` keeps stdin attached either way; `-t`
# is added only when a real terminal is present. tail -F (inside monitor.sh)
# ignores SIGWINCH cleanly in either posture.
if [[ -t 0 ]]; then
	tty_flag="-it"
else
	tty_flag="-i"
fi
# Pass KEEL_DEVBOX_REPO_NAME so monitor.sh can resolve JSONL_OUT correctly
# without depending on the container's compose-injected env (defensive
# parity with the other host wrappers).
exec docker exec "${tty_flag}" \
	-e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" \
	"${CONTAINER_NAME}" "/workspace/${REPO_NAME}/packages/devbox/scripts/monitor.sh" "$@"
