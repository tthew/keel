#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/monitor.sh — Story 2.3 (AC 3 observability)
#
# Operator-facing live tail of the JSONL egress query log. Intentionally
# minimal — no filter args, no format flags (those are Story 2.4/2.6 scope).
# Story 2.6 wraps this as `pnpm devbox:egress:monitor`.
#
# Usage (inside or outside the container):
#   docker exec -it keel-devbox /workspace/packages/devbox/scripts/monitor.sh
# ---------------------------------------------------------------------------
set -euo pipefail

JSONL_OUT="/workspace/logs/egress-queries.jsonl"

if [[ ! -f "${JSONL_OUT}" ]]; then
	printf 'monitor: waiting for %s to appear…\n' "${JSONL_OUT}" >&2
	# Fall through to tail -F; it re-attaches once the file is created.
fi

exec tail -Fn0 "${JSONL_OUT}" | jq -c --unbuffered '.'
