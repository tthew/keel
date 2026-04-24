#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block "Grep path=/home/dev/.claude/sub (D-20 Glob-parity; case-glob requires trailing content)" "$(payload_grep "TODO" "/home/dev/.claude/sub")" "secret-access-denylist" "grep-glob-path-oauth"
