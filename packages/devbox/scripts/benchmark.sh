#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/benchmark.sh — NFR2 cold/warm start measurement.
#
# Referenced by Story 2.1 Task 5 + AC 4. Writes an append-only entry to
# `packages/devbox/README.md § Benchmarks` honouring the modelled-baseline
# honesty posture at architecture.md § NFR28b (lines 264-270) — single-run
# values are labelled as modelled, not a reproducible envelope.
#
# Usage:
#   packages/devbox/scripts/benchmark.sh [--skip-cold] [--allow-broad-prune]
#
# Flags:
#   --skip-cold           Skip the destructive cold pass; run warm-only.
#                         Safe under both backends (see Backend contract below).
#   --allow-broad-prune   Override the backend-B safety guard (caller accepts
#                         that the blast radius of `docker system prune -af
#                         --volumes` escapes the iteration container and
#                         destroys host-level Docker state including unrelated
#                         projects). Ignored under backend A — full prune is
#                         already self-contained there.
#
# Invocation discipline:
#   - Run from the repo root so the compose file's `env_file: ../../.envrc`
#     resolves correctly.
#
# Backend contract (docs/invariants/devbox-dind.md § Backend contract):
#   A. True Docker-in-Docker (isolated daemon). Broad prune is self-contained.
#   B. Host socket-passthrough. Broad prune destroys host state — including
#      unrelated projects. Refused by default; see --allow-broad-prune.
#
# NFR2 budgets (Apple-Silicon M4-Pro baseline):
#   - Cold start : ≤ 300 s (5 min).
#   - Warm start : ≤  30 s.
#
# Escalation rules per AC 4 scope clarification:
#   - delta ≤ 20% over budget : record in README as modelled baseline and
#     move on (single-run variance envelope).
#   - 20% < delta ≤ 2× : retry twice and record the median.
#   - delta > 2× : escalate to `.ralph/@plan.md § BLOCKED` with a
#     cc-devbox-comparison note.
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${DEVBOX_DIR}/docker-compose.yml"
README_FILE="${DEVBOX_DIR}/README.md"

SKIP_COLD=0
ALLOW_BROAD_PRUNE=0
for arg in "$@"; do
  case "$arg" in
    --skip-cold) SKIP_COLD=1 ;;
    --allow-broad-prune) ALLOW_BROAD_PRUNE=1 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

command -v docker >/dev/null 2>&1 || {
  echo "docker not on PATH — NFR2 measurement requires Docker" >&2
  exit 127
}

detect_backend() {
  local daemon_name
  daemon_name="$(docker info --format '{{.Name}}' 2>/dev/null || true)"
  case "$daemon_name" in
    docker-desktop|*-docker-desktop|moby|linuxkit-*)
      echo B
      return
      ;;
  esac
  if [[ -f /.dockerenv ]]; then
    local host
    host="$(hostname 2>/dev/null || echo unknown)"
    if [[ "$daemon_name" != "$host" && -n "$daemon_name" ]]; then
      echo B
      return
    fi
  fi
  echo A
}

BACKEND="$(detect_backend)"

if [[ $SKIP_COLD -eq 0 && "$BACKEND" = "B" && $ALLOW_BROAD_PRUNE -eq 0 ]]; then
  cat >&2 <<EOF
REFUSING destructive cold pass: backend B (host socket-passthrough) detected.

The cold pass runs 'docker system prune -af --volumes', which under backend B
destroys every container/image/volume on the HOST daemon — including unrelated
projects. See docs/invariants/devbox-dind.md § Safety rule.

Options:
  - Warm-only (safe):  $(basename "$0") --skip-cold
  - Override (you accept the host-level blast radius):
                       $(basename "$0") --allow-broad-prune
  - Run natively on an M4-Pro host (AC 4 authoritative path).
EOF
  exit 2
fi

run_date="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
host_uname="$(uname -a)"
docker_version="$(docker --version)"
compose_version="$(docker compose version --short 2>/dev/null || echo unknown)"

if [[ $SKIP_COLD -eq 0 ]]; then
  echo "→ cold start: docker system prune -af --volumes (backend=$BACKEND)"
  docker system prune -af --volumes >/dev/null
  cold_start_ts="$(date +%s)"
  docker compose -f "${COMPOSE_FILE}" up --build -d
  cold_end_ts="$(date +%s)"
  cold_seconds=$(( cold_end_ts - cold_start_ts ))
  docker compose -f "${COMPOSE_FILE}" down >/dev/null
else
  cold_seconds="skipped"
fi

echo "→ warm start: docker compose down && up -d (backend=$BACKEND)"
docker compose -f "${COMPOSE_FILE}" down >/dev/null 2>&1 || true
warm_start_ts="$(date +%s)"
docker compose -f "${COMPOSE_FILE}" up -d
warm_end_ts="$(date +%s)"
warm_seconds=$(( warm_end_ts - warm_start_ts ))
docker compose -f "${COMPOSE_FILE}" down >/dev/null

{
  echo ""
  echo "### Run $run_date"
  echo ""
  echo "- Host: \`$host_uname\`"
  echo "- Docker: \`$docker_version\`"
  echo "- Compose: \`$compose_version\`"
  echo "- Backend: \`$BACKEND\` (A=isolated DinD; B=host socket-passthrough)"
  echo "- Cold start: **${cold_seconds}s** (NFR2 budget: ≤ 300s)"
  echo "- Warm start: **${warm_seconds}s** (NFR2 budget: ≤ 30s)"
  echo "- Flag: \`host: DinD (cc-devbox, backend=${BACKEND}) — modelled indicative baseline; AC 4 authoritative run still owed on M4-Pro per scope clarification\`"
} >> "${README_FILE}"

echo "→ wrote results to ${README_FILE}"
