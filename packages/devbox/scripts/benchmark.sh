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
#   packages/devbox/scripts/benchmark.sh [--skip-cold]
#
# Invocation discipline:
#   - Run from the repo root so the compose file's `env_file: ../../.envrc`
#     resolves correctly.
#   - Cold pass prunes ALL images + volumes via `docker system prune -af
#     --volumes`. Do NOT run on a workstation with other unrelated Docker
#     state you want to keep.
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
for arg in "$@"; do
  case "$arg" in
    --skip-cold) SKIP_COLD=1 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

command -v docker >/dev/null 2>&1 || {
  echo "docker not on PATH — NFR2 measurement requires Docker" >&2
  exit 127
}

run_date="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
host_uname="$(uname -a)"
docker_version="$(docker --version)"
compose_version="$(docker compose version --short 2>/dev/null || echo unknown)"

# Cold pass — prune everything, then `up --build`.
if [[ $SKIP_COLD -eq 0 ]]; then
  echo "→ cold start: docker system prune -af --volumes"
  docker system prune -af --volumes >/dev/null
  cold_start_ts="$(date +%s)"
  docker compose -f "${COMPOSE_FILE}" up --build -d
  cold_end_ts="$(date +%s)"
  cold_seconds=$(( cold_end_ts - cold_start_ts ))
  docker compose -f "${COMPOSE_FILE}" down >/dev/null
else
  cold_seconds="skipped"
fi

# Warm pass — image is built, volumes persist, just `down && up`.
echo "→ warm start: docker compose down && up -d"
docker compose -f "${COMPOSE_FILE}" down >/dev/null 2>&1 || true
warm_start_ts="$(date +%s)"
docker compose -f "${COMPOSE_FILE}" up -d
warm_end_ts="$(date +%s)"
warm_seconds=$(( warm_end_ts - warm_start_ts ))
docker compose -f "${COMPOSE_FILE}" down >/dev/null

# Append to README § Benchmarks as a new row.
{
  echo ""
  echo "### Run $run_date"
  echo ""
  echo "- Host: \`$host_uname\`"
  echo "- Docker: \`$docker_version\`"
  echo "- Compose: \`$compose_version\`"
  echo "- Cold start: **${cold_seconds}s** (NFR2 budget: ≤ 300s)"
  echo "- Warm start: **${warm_seconds}s** (NFR2 budget: ≤ 30s)"
} >> "${README_FILE}"

echo "→ wrote results to ${README_FILE}"
