#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block "find packages/keel-invariants/src/invariants.manifest.ts -delete (L1 regex requires specific filename)" "$(payload_bash "find packages/keel-invariants/src/invariants.manifest.ts -delete")" "install-boundary-protection" "find-delete-against-l1"
