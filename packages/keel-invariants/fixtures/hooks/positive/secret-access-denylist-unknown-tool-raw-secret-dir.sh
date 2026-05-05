#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block "No-tool-name payload with /home/dev/.claude/ (D-34 fail-secure)" "$(payload_notool '{"path":"/home/dev/.claude/x"}')" "secret-access-denylist" "unknown-tool-raw-secret-dir"
