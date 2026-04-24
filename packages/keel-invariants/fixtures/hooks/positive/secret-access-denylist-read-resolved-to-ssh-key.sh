#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block "Read /home/dev/.ssh/id_ed25519 (D-22 resolved-path dominance)" "$(payload_read "/home/dev/.ssh/id_ed25519")" "secret-access-denylist" "read-resolved-to-ssh-key"
