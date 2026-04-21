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
#   packages/devbox/scripts/benchmark.sh [--skip-cold] [--allow-broad-prune] [--help|-h]
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
#   --help, -h            Print a scripted Usage block to stdout and exit 0.
#                         Runs before the docker / daemon reachability probes
#                         so operators can read Usage on a host without Docker.
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

# --help|-h handling (iter-143 CR-re-run AR-5 = iter-138 findings F30 / E19).
# Operators asking for usage previously fell through to the unknown-arg
# `exit 2` branch; that contradicted the AI-4 UX-bundle posture (clear
# operator guidance before a destructive-prune refusal can fire). The
# function prints a scripted subset of the Usage + Flags block at the top
# of this file; duplicating the content here (rather than sed-slicing the
# comment block at runtime) keeps the header block the single source of
# truth for human readers while letting the runtime output stay
# independent of comment parsing. Runs BEFORE the `command -v docker` and
# `docker info` probes below so `--help` works on a host with no Docker
# installed (the only flag path that does not require a reachable daemon).
print_usage() {
  cat <<EOF
Usage:
  $(basename "$0") [--skip-cold] [--allow-broad-prune] [--help|-h]

Flags:
  --skip-cold           Skip the destructive cold pass; run warm-only.
                        Safe under both backends.
  --allow-broad-prune   Override the backend-B safety guard (caller
                        accepts the host-level blast radius of
                        'docker system prune -af --volumes'). Ignored
                        under backend A — the full prune is already
                        self-contained there.
  --help, -h            Print this Usage block to stdout and exit 0.

Backend contract (docs/invariants/devbox-dind.md § Backend contract):
  A. True Docker-in-Docker (isolated daemon). Broad prune is self-contained.
  B. Host socket-passthrough. Broad prune destroys host state — refused
     by default; --allow-broad-prune opts in.

NFR2 budgets (Apple-Silicon M4-Pro baseline):
  Cold start : <= 300 s (5 min).
  Warm start : <=  30 s.
EOF
}

SKIP_COLD=0
ALLOW_BROAD_PRUNE=0
for arg in "$@"; do
  case "$arg" in
    --skip-cold) SKIP_COLD=1 ;;
    --allow-broad-prune) ALLOW_BROAD_PRUNE=1 ;;
    --help|-h) print_usage; exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

# --skip-cold bypasses the destructive pass that --allow-broad-prune exists
# to authorise, so the two flags are mutually useless in combination. Warn
# rather than silently dropping either — callers who supplied both almost
# certainly misunderstood one of them (most likely --skip-cold was added
# after the iter-122 backend-B safety gate without noticing that it makes
# --allow-broad-prune inert). Continue warm-only regardless.
if [[ $SKIP_COLD -eq 1 && $ALLOW_BROAD_PRUNE -eq 1 ]]; then
  echo "warning: --skip-cold + --allow-broad-prune are mutually useless — --skip-cold bypasses the destructive pass that --allow-broad-prune authorises. Continuing warm-only; --allow-broad-prune has no effect." >&2
fi

command -v docker >/dev/null 2>&1 || {
  echo "docker not on PATH — NFR2 measurement requires Docker" >&2
  exit 127
}

# Daemon reachability probe: having `docker` on PATH is necessary but not
# sufficient — the daemon may be stopped (Docker Desktop not running), the
# socket may be unreachable (passthrough not mounted), or DOCKER_HOST may
# point at a dead endpoint. Fail fast with 127 before `detect_backend()`
# runs, otherwise the case-statement probe silently degrades to the
# fail-safe-B branch and the caller wastes a cold+warm invocation on a
# destructive-prune refusal they could have avoided up front.
docker info >/dev/null 2>&1 || {
  echo "docker daemon unreachable (command available but 'docker info' failed)" >&2
  echo "Check: Docker Desktop running? socket accessible? DOCKER_HOST set correctly?" >&2
  exit 127
}

detect_backend() {
  local daemon_name
  daemon_name="$(docker info --format '{{.Name}}' 2>/dev/null || true)"
  # Well-known host-level identifiers → backend B (Docker Desktop, Moby VM, LinuxKit).
  case "$daemon_name" in
    docker-desktop|*-docker-desktop|moby|linuxkit-*)
      echo B
      return
      ;;
  esac
  # Fail-safe inside a container: default B. We cannot reliably prove an
  # isolated daemon from within /.dockerenv — empty daemon_name (probe failed)
  # and daemon_name == $(hostname) are BOTH ambiguous signals (the daemon could
  # be a nested isolated dockerd OR a socket-passthrough whose .Name happens to
  # coincide). The prior fall-through to `echo A` on those cases made a
  # destructive-prune misdetection the DEFAULT — directly contrary to the
  # § Safety rule "when in doubt, refuse destructive" at
  # docs/invariants/devbox-dind.md. Callers who KNOW they are on an isolated
  # nested daemon use --allow-broad-prune.
  if [[ -f /.dockerenv ]]; then
    echo B
    return
  fi
  # No /.dockerenv — native-host execution; no container boundary for a broad
  # prune to escape. Backend A is the correct default here.
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

# Trap-completeness bundle (iter-139 CR AR-1 = iter-138 findings F1 +
# F27 + F28). Three defects the iter-132 AI-4 trap did not cover:
#   (a) INT + TERM shared exit 130 — conflated SIGINT (operator ^C,
#       signum 2 → POSIX 128+2 = 130) with SIGTERM (supervisor /
#       orchestrator stop, signum 15 → POSIX 128+15 = 143), so any
#       caller reading `$?` to distinguish the two got a false match;
#   (b) HUP + QUIT unhandled — a closed terminal (SIGHUP, 128+1 = 129)
#       or Ctrl-\\ (SIGQUIT, 128+3 = 131) mid-run bypassed the
#       `docker compose down` cleanup and left stray compose stack /
#       containers / networks behind;
#   (c) ERR path uncovered — `set -e` on a failed `docker compose
#       build` or `up` (e.g. the iter-124 backend-B bind-mount denial)
#       exited without firing the trap, leaking half-created image +
#       container + network state to the host until the next
#       `docker system prune`.
# Fix: move cleanup to an EXIT trap that fires on ANY exit path —
# signal-triggered, `set -e`-triggered, or normal end-of-script — and
# keep the per-signal traps as thin wrappers that call `exit N` with
# the signal-specific POSIX code. When the per-signal trap calls
# `exit N`, the EXIT trap fires next with `$? == N`, so the script's
# final exit status matches the signal (bash does not re-enter the
# EXIT trap during its own execution). `cleanup_on_exit` captures
# `$?` into a local BEFORE running `docker compose down` so a
# post-teardown failure (guarded by `|| true`) cannot clobber the
# original exit code the trap was summoned to propagate, and the
# explicit `exit "$exit_code"` at the tail ensures the status
# survives in bash variants where the EXIT trap's last-command
# status would otherwise leak through.
cleanup_on_exit() {
  local exit_code=$?
  docker compose -f "${COMPOSE_FILE}" down >/dev/null 2>&1 || true
  exit "$exit_code"
}
trap cleanup_on_exit EXIT
trap 'exit 130' INT   # SIGINT  (signum 2  → 128+2)
trap 'exit 143' TERM  # SIGTERM (signum 15 → 128+15)
trap 'exit 129' HUP   # SIGHUP  (signum 1  → 128+1)
trap 'exit 131' QUIT  # SIGQUIT (signum 3  → 128+3)

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

# Flag text branches on backend classification per the iter-128 CR AI-4
# finding: backend A (no /.dockerenv; detect_backend only asserts A on a
# true native host) IS the AC 4 authoritative path on an M4-Pro operator
# workstation — the prior unconditional "DinD (cc-devbox) modelled
# indicative baseline" text mis-labelled authoritative runs. Backend B
# (host socket-passthrough or nested container daemon) remains modelled
# indicative per architecture.md § NFR28b (lines 264-270) until the
# authoritative M4-Pro native run is recorded.
if [[ "$BACKEND" = "A" ]]; then
  flag_label="host: native (backend=A) — AC 4 authoritative if uname matches M4-Pro baseline; single-run values remain modelled per architecture.md § NFR28b"
else
  flag_label="host: DinD (cc-devbox, backend=${BACKEND}) — modelled indicative baseline; AC 4 authoritative run still owed on M4-Pro per scope clarification"
fi

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
  echo "- Flag: \`${flag_label}\`"
} >> "${README_FILE}"

echo "→ wrote results to ${README_FILE}"
