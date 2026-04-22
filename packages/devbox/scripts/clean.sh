#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/clean.sh — Story 2.6 (AC 4, SC-11)
#
# Three-tier clean behavior; named volume `keel_home_dev` is preserved by
# default (NFR10). Destructive tiers gate on explicit operator confirmation
# AND backend-B acknowledgement (backend B = host socket-passthrough; a bare
# `docker compose down --volumes` would destroy a host-shared volume).
#
# Usage:
#   clean.sh                         — compose down + remove local image;
#                                      volume keel_home_dev preserved.
#   clean.sh --with-volumes          — same, plus volume destruction. Prompts
#                                      y/N; `--yes` auto-confirms; backend-B
#                                      additionally requires `--force-backend-b`.
#   clean.sh --allow-broad-prune     — RESERVED; rejected at 1.0 (SC-11).
#
# Exit codes (SC-5):
#   0   success.
#   2   usage / refused backend-B volume destruction without --force-backend-b.
#   8   docker runtime unreachable.
#   *   docker/compose error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

# AI-12 (Story 2.6 CR closure iter-217): operator-shell COMPOSE_PROJECT_NAME
# export would redirect `docker compose down` at lines 113 + 140 away from the
# canonical `name: keel-devbox` project label. Two collateral hazards (see
# deferred-work.md § AR-20 iter-216 re-triage): (a) `--volumes` would target
# `${CPN}_keel_home_dev` rather than the INV-devbox-homedev-named-volume-pinned
# `keel-devbox_keel_home_dev`, silently leaving the real volume intact; (b)
# `--remove-orphans` would remove any `${CPN}`-labelled container as collateral
# damage against unrelated host projects (acute under backend B). Mirrors the
# AI-8 iter-212 uniform `unset` pattern applied across start/stop/restart/
# shell/attach/status/logs/monitor-host/whitelist-host.
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${DEVBOX_DIR}/docker-compose.yml"

log() { printf 'clean: %s\n' "$*" >&2; }

usage() {
	cat >&2 <<'EOF'
usage: clean.sh [--with-volumes] [--yes] [--force-backend-b] [--allow-broad-prune]

Default: compose down + remove local image 'keel-devbox:local'; named volume
'keel_home_dev' (NFR10) preserved. Safe under either backend (DinD or host
socket-passthrough) per docs/invariants/devbox-dind.md § Backend contract.

Flags:
  --with-volumes       Also destroy the keel_home_dev named volume. Prompts
                       y/N (or `--yes` to auto-confirm). Under backend B,
                       additionally requires `--force-backend-b` to prevent
                       accidental destruction of a host-shared volume.
  --yes                Auto-confirm --with-volumes prompt (CI-only path).
  --force-backend-b    Acknowledge backend-B blast radius of --with-volumes.
  --allow-broad-prune  RESERVED at 1.0; no-op (scoped cleanup is the default).
EOF
}

# Flag parsing.
WITH_VOLUMES=0
AUTO_YES=0
FORCE_BACKEND_B=0
ALLOW_BROAD_PRUNE=0
while [[ $# -gt 0 ]]; do
	case "$1" in
		--with-volumes) WITH_VOLUMES=1 ;;
		--yes|-y) AUTO_YES=1 ;;
		--force-backend-b) FORCE_BACKEND_B=1 ;;
		--allow-broad-prune) ALLOW_BROAD_PRUNE=1 ;;
		-h|--help) usage; exit 0 ;;
		*) log "unknown flag: $1"; usage; exit 2 ;;
	esac
	shift
done

if [[ ${ALLOW_BROAD_PRUNE} -eq 1 ]]; then
	log "--allow-broad-prune is reserved; scoped cleanup is the 1.0 default — see devbox-dind.md § Backend contract"
	# Accept flag as no-op per SC-11.
fi

if ! docker info >/dev/null 2>&1; then
	log "docker unreachable — is the daemon running?"
	exit 8
fi

# Backend detection (mirrors benchmark.sh § detect_backend per
# devbox-dind.md:47). Fail-safe posture: when we cannot reliably prove
# backend A, default B so destructive --with-volumes gates on explicit
# --force-backend-b. The /.dockerenv → B arm IS over-inclusive for true
# DinD (backend A) containers — that's intentional; true-DinD operators
# accept one extra flag rather than let a Docker-Desktop-host operator
# lose unrelated volumes on a silent probe failure. See AI-4 (Story 2.6
# CR iter-204) + docs/invariants/devbox-dind.md § Safety rule.
detect_backend() {
	local daemon_name
	daemon_name="$(docker info --format '{{.Name}}' 2>/dev/null || true)"
	# Empty probe output → the `--format` call failed transiently between
	# the `docker info` reachability check above (line 73) and here.
	# Pre-AI-4 the case-statement fell through, `/.dockerenv` was absent
	# on a native host, and we defaulted to A — the LESS-protective branch
	# on a backend-B box. Fail-safe to B instead.
	if [[ -z "${daemon_name}" ]]; then echo B; return; fi
	# Well-known host-level identifiers → backend B.
	case "${daemon_name}" in
		docker-desktop|*-docker-desktop|moby|linuxkit-*) echo B; return ;;
	esac
	# Inside a container (/.dockerenv present): we cannot reliably
	# distinguish an isolated nested dockerd (true backend A) from a
	# host-socket passthrough (backend B) by this signal alone. Fail-safe
	# to B; true-DinD operators override with --force-backend-b (same
	# posture as benchmark.sh's --allow-broad-prune).
	if [[ -f /.dockerenv ]]; then echo B; return; fi
	# Native host, daemon_name set to non-well-known identifier (pure
	# dockerd, lima, nerdctl, etc.) — backend A.
	echo A
}
BACKEND="$(detect_backend)"

if [[ ${WITH_VOLUMES} -eq 0 ]]; then
	log "docker compose down --rmi local --remove-orphans (volume keel_home_dev preserved)"
	exec docker compose -f "${COMPOSE_FILE}" down --rmi local --remove-orphans
fi

# --with-volumes path: guard rails (SC-11).
if [[ "${BACKEND}" == "B" && ${FORCE_BACKEND_B} -eq 0 ]]; then
	log "backend B detected — volume destruction requires --force-backend-b acknowledgement"
	log "reason: backend B shares the host docker daemon; destroying keel_home_dev may surprise"
	exit 2
fi

if [[ ${AUTO_YES} -eq 0 ]]; then
	printf 'clean: this will DESTROY the keel_home_dev named volume (Claude Code + gh tokens LOST). Continue? [y/N] ' >&2
	# Under `set -euo pipefail`, a bare `read -r answer` with closed stdin
	# (non-TTY CI, EOF here-doc) returns non-zero → errexit aborts BEFORE the
	# `case` arm below can print the friendly "aborted — no-op" message. Handle
	# EOF explicitly so the abort path is reachable and exit 0 is preserved.
	if ! IFS= read -r answer; then
		log "no input — aborting (stdin closed / non-interactive); use --yes to auto-confirm"
		exit 0
	fi
	case "${answer}" in
		y|Y|yes|YES) ;;
		*) log "aborted — no-op"; exit 0 ;;
	esac
fi

log "docker compose down --rmi local --volumes --remove-orphans (DESTRUCTIVE)"
exec docker compose -f "${COMPOSE_FILE}" down --rmi local --volumes --remove-orphans
