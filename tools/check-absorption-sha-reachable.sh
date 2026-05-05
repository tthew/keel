#!/usr/bin/env bash
# Story 2.1 absorption-SHA reachability pre-commit gate (Story 2.14 PR #230 review iter-13).
#
# docs/invariants/devbox-legacy-branch-retention.md § Triage path pins commit
# 5278738 as the bisect anchor for any packages/devbox/ regression introduced
# post-absorption. The SHA is load-bearing for incident-response triage; if it
# is ever rebased / GC'd (e.g. during a Story 15b rewrite-history cut), the
# canary-then-bisect recipe silently breaks at the moment operators most need
# it. This gate fails-closed on absorption SHA unreachability.
#
# Reference: PR #230 discussion_r3143866586.

set -euo pipefail

ABSORPTION_SHA="5278738"

if ! git rev-parse --verify --quiet "${ABSORPTION_SHA}^{commit}" >/dev/null; then
  printf '✗ absorption-sha-reachable: docs/invariants/devbox-legacy-branch-retention.md absorption SHA %s unreachable\n' \
    "$ABSORPTION_SHA" >&2
  printf '  The triage path § Why bisect from %s anchor is broken — git bisect HEAD %s -- packages/devbox/ will fail.\n' \
    "$ABSORPTION_SHA" "$ABSORPTION_SHA" >&2
  printf '  If the anchor was deliberately rebased (e.g. Story 15b rewrite-history cut), AMEND the recipe to point at the new SHA in lockstep.\n' >&2
  exit 1
fi
