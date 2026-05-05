#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block "No-tool-name payload with /proc/1234/environ (D-34 fail-secure)" "$(payload_notool '{"p":"/proc/1234/environ"}')" "secret-access-denylist" "unknown-tool-raw-proc-pid"
