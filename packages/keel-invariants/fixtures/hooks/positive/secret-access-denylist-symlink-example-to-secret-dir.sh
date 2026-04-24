#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
# D-22 guard: Read-arm *.envrc.example exemption must deny when the resolved symlink
# target lands inside a secret directory. Build a throwaway symlink in /tmp, exercise
# the hook, clean up. Expected: block with match=symlink-example-to-secret-dir.
decoy="/tmp/fixture-decoy.envrc.example"
rm -f "$decoy"
ln -s /home/dev/.claude/x "$decoy"
# Keep the symlink live across the hook invocation so readlink -f resolves it.
payload="$(payload_read "$decoy")"
status=0
expect_block "Read decoy.envrc.example -> /home/dev/.claude/" "$payload" \
  "secret-access-denylist" "symlink-example-to-secret-dir" || status=$?
rm -f "$decoy"
exit "$status"

