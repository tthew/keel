#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/restart.sh — Story 2.6 (AC 4)
#
# stop.sh + start.sh in sequence. If stop fails, abort before start. Propagate
# start's exit code (0 on healthy, 10/11/8 etc. per start.sh).
#
# Between stop + start, poll the OLD container's .State.Status until it has
# actually reached `exited` (or the container object has been removed) before
# invoking start.sh. `docker compose stop` returns when SIGTERM has been
# delivered + grace has elapsed — NOT when the container has reached `exited`.
# On a slow daemon the container may still be transitioning through
# `removing`/`running` when stop.sh returns, and start.sh's own poll
# (start.sh:74-89) would then match `running` against the DOOMED old container
# and declare `started` prematurely. Poll is bounded by
# KEEL_DEVBOX_RESTART_STOP_POLL_TIMEOUT_S (default 10s); on timeout, proceed
# to start.sh regardless — start.sh has its own 120s healthcheck bound.
#
# Exit codes (SC-5):
#   inherited from stop.sh (first) then start.sh (second).
# ---------------------------------------------------------------------------
set -euo pipefail

# AI-8 (Story 2.6 CR iter-212): operator-shell COMPOSE_PROJECT_NAME export
# would redirect compose's project identity away from `name: keel-devbox` and
# break the `keel-devbox_keel_home_dev` volume path (INV-devbox-homedev-named-volume).
# Subprocesses (stop.sh, start.sh) each `unset` defensively too; this block
# covers restart.sh's own env so any direct compose calls added later are safe.
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOP_POLL_TIMEOUT_S="${KEEL_DEVBOX_RESTART_STOP_POLL_TIMEOUT_S:-10}"

# Resolve main repo + mode-specific state (Story 2.11: per-fork vs shared via
# KEEL_DEVBOX_SHARED). Transitive delegates stop.sh + start.sh each invoke
# the resolver independently; prepend here for fail-fast inspect consistency
# on the OLD-container exit-poll below.
# shellcheck source=lib/main-repo-resolver.sh
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"

log() { printf 'restart: %s\n' "$*" >&2; }

# Pre-flight: Story 2.10 Tier 1 prereq-check (Docker runtime reachable).
# restart.sh has no inline `docker info` of its own — it transitively
# delegates reachability to stop.sh + start.sh (both of which carry the
# prereq-check wire-in after Story 2.10). Explicit prepend here is for
# fail-fast visibility (operator gets the install-URL pointer BEFORE
# stop.sh's own prereq-check surfaces the same result).
"${SCRIPT_DIR}/prereq-check.sh" --tier1

log "invoking stop.sh"
"${SCRIPT_DIR}/stop.sh"

# AI-11 (Story 2.6 CR iter-215): wait for the OLD container to actually reach
# `exited` (or disappear) before start.sh runs. `docker compose stop` returns
# after SIGTERM + grace, not after the daemon finishes transitioning the
# container. Without this poll, start.sh's own state-machine can match
# `running`/`removing` on the doomed container and return rc 0 against a
# container about to die. `docker inspect` returns empty + non-zero when the
# object no longer exists — we treat that as equivalent to `exited` (compose
# has garbage-collected it). By this point `docker info` has already been
# validated upstream (stop.sh:28), so an inspect failure here is overwhelmingly
# "container gone", not a daemon outage.
log "waiting for '${CONTAINER_NAME}' to exit (timeout ${STOP_POLL_TIMEOUT_S}s)"
stop_deadline=$(( $(date +%s) + STOP_POLL_TIMEOUT_S ))
while true; do
	now=$(date +%s)
	if [[ ${now} -ge ${stop_deadline} ]]; then
		log "timed out waiting for exit — proceeding to start.sh anyway"
		break
	fi

	status="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
	case "${status}" in
		exited|dead)
			log "container is '${status}' — ready for start.sh"
			break
			;;
		"")
			log "container object gone — ready for start.sh"
			break
			;;
		*)
			sleep 0.5
			;;
	esac
done

log "invoking start.sh"
exec "${SCRIPT_DIR}/start.sh"
