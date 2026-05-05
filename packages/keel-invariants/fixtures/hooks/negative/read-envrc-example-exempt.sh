#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_approve "Read /tmp/dev.envrc.example (D-17 exemption)" "$(payload_read "/tmp/dev.envrc.example")"
