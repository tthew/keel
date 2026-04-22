#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/restart.sh — Story 2.6 (AC 4)
#
# stop.sh + start.sh in sequence. If stop fails, abort before start. Propagate
# start's exit code (0 on healthy, 10/11/8 etc. per start.sh).
#
# Exit codes (SC-5):
#   inherited from stop.sh (first) then start.sh (second).
# ---------------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf 'restart: %s\n' "$*" >&2; }

log "invoking stop.sh"
"${SCRIPT_DIR}/stop.sh"

log "invoking start.sh"
exec "${SCRIPT_DIR}/start.sh"
