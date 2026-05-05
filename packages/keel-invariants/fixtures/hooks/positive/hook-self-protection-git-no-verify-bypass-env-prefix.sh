#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block "A=1 git commit --no-verify (D-16 env-prefix)" "$(payload_bash "A=1 B=2 git commit -m m --no-verify")" "hook-self-protection" "git-no-verify-bypass"
