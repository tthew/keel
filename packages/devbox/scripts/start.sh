#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/start.sh — Story 2.6 (AC 3)
#
# Bring up the keel-devbox container via docker compose + poll healthcheck to
# a healthy state before returning. Consumes Story 2.13's healthcheck (wired
# into docker-compose.yml by that later story); Story 2.6 ships a
# stub-friendly poll that also accepts bare `running` when no healthcheck is
# configured yet (pre-Story-2.13 posture).
#
# Optional env-check pre-flight: runs env-check.sh unless operator sets
# `KEEL_DEVBOX_START_SKIP_ENV_CHECK=true` (CI/alternate-env-injection escape).
#
# Exit codes (SC-5):
#   0   container reached healthy / running within timeout.
#   2   env-check.sh rejected the current .envrc (propagated).
#   3   env-check.sh source unreadable (propagated).
#   8   docker runtime unreachable (`docker info` failed).
#   10  image not built (run `pnpm devbox:build` first).
#   11  startup polling failed. Three sub-cases, same code (SC-5 keeps the exit
#       set flat):
#         (a) healthcheck timeout (line 65-68) — container left running for
#             debug via 'pnpm devbox:logs';
#         (b) container 'unhealthy' (line 84-87) — still running; logs hint
#             applies;
#         (c) container entered fatal state 'exited|dead|removing|paused'
#             (line 88-91) — NOT running; 'pnpm devbox:logs' may still print
#             last output before exit but the "left running" promise does not
#             apply. Operator hint is state-aware (AI-2, iter-206).
#   *   docker compose up error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

# AI-8 (Story 2.6 CR iter-212): operator-shell COMPOSE_PROJECT_NAME export
# would redirect compose's project identity away from `name: keel-devbox` and
# break the `keel-devbox_keel_home_dev` volume path (INV-devbox-homedev-named-volume).
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${DEVBOX_DIR}/docker-compose.yml"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"
IMAGE_TAG="${KEEL_DEVBOX_IMAGE_TAG:-keel-devbox:local}"
HEALTHCHECK_TIMEOUT_S="${KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S:-120}"

log() { printf 'start: %s\n' "$*" >&2; }

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

if ! docker image inspect "${IMAGE_TAG}" >/dev/null 2>&1; then
	log "image '${IMAGE_TAG}' not built — run 'pnpm devbox:build'"
	exit 10
fi

# Optional env-check pre-flight (SC-14 fail-closed hook).
if [[ "${KEEL_DEVBOX_START_SKIP_ENV_CHECK:-false}" != "true" ]]; then
	if [[ -x "${SCRIPT_DIR}/env-check.sh" ]]; then
		log "env-check pre-flight"
		rc=0
		"${SCRIPT_DIR}/env-check.sh" || rc=$?
		if [[ ${rc} -ne 0 ]]; then
			log "env-check failed (exit ${rc}) — set KEEL_DEVBOX_START_SKIP_ENV_CHECK=true to bypass"
			exit "${rc}"
		fi
	fi
fi

log "docker compose up -d devbox"
docker compose -f "${COMPOSE_FILE}" up -d devbox

log "polling healthcheck (timeout ${HEALTHCHECK_TIMEOUT_S}s)"
deadline=$(( $(date +%s) + HEALTHCHECK_TIMEOUT_S ))
grace_deadline=$(( $(date +%s) + 30 ))
while true; do
	now=$(date +%s)
	if [[ ${now} -ge ${deadline} ]]; then
		log "container failed to reach healthy state within ${HEALTHCHECK_TIMEOUT_S}s — check 'pnpm devbox:logs'"
		exit 11
	fi

	# Prefer docker inspect .State.Health.Status; fall back to .State.Status.
	health="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "${CONTAINER_NAME}" 2>/dev/null || true)"

	case "${health}" in
		healthy|running)
			log "started (container ${CONTAINER_NAME}, state=${health})"
			exit 0
			;;
		starting)
			# Allow `starting` only within the 30s grace window.
			if [[ ${now} -gt ${grace_deadline} ]]; then
				log "container still 'starting' past 30s grace — continuing to poll until ${HEALTHCHECK_TIMEOUT_S}s deadline"
			fi
			;;
		unhealthy)
			# Container is still running — healthcheck probe is failing.
			# 'pnpm devbox:logs' gives live output; docstring's "left running
			# for debugging" promise holds.
			log "container 'unhealthy' (still running) — check 'pnpm devbox:logs' for failing healthcheck"
			exit 11
			;;
		exited|dead|removing|paused)
			# Container is NOT running. Docker retains logs for 'exited'
			# containers (daemon-config-dependent for 'removing'); be honest
			# that the "left running for debugging" promise from the docstring
			# does not apply here.
			log "container entered fatal state '${health}' (not running) — 'pnpm devbox:logs' may show last output before exit"
			exit 11
			;;
		"")
			log "inspect returned empty state — retrying"
			;;
		*)
			# Unknown state — log and keep polling.
			log "unrecognised state '${health}' — retrying"
			;;
	esac

	sleep 2
done
