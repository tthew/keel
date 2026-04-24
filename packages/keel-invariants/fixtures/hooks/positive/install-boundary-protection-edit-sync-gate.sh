#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block "Edit packages/keel-invariants/src/sync-gate.ts" "$(payload_edit "packages/keel-invariants/src/sync-gate.ts")" "install-boundary-protection" "install-boundary-file"
