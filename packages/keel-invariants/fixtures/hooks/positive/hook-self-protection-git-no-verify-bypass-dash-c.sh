#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block "git -c x=y commit --no-verify (D-16 -c pre-arg)" "$(payload_bash "git -c core.hooksPath=/tmp commit -m m --no-verify")" "hook-self-protection" "git-no-verify-bypass"
