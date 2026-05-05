#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block "Write packages/keel-invariants/src/prompt-injection-rules/x.ts" "$(payload_write "packages/keel-invariants/src/prompt-injection-rules/new-rule.ts")" "install-boundary-protection" "install-boundary-file"
