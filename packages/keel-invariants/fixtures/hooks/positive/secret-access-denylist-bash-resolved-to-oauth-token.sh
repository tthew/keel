#!/usr/bin/env bash
# FIX-2 (PR #230 review-fix-arc): Bash-arm symlink-deref must mirror Read-arm D-22
# `readlink -f` resolution. Builds a /tmp symlink targeting /home/dev/.claude/, runs
# `cat /tmp/<symlink>` through the hook, asserts block. Without FIX-2 the literal-text
# case-globs only see the symlink path (in /tmp, not a secret dir) and approve.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"

# Build target inside the oauth-dir denylist scope. mkdir -p is idempotent in test env.
HOMEDIR_ANCHOR="/home/$(id -un)"
SECRET_ROOT="$HOMEDIR_ANCHOR/.claude"
mkdir -p "$SECRET_ROOT" 2>/dev/null || true
target="$SECRET_ROOT/fix2-fixture-target-$$.testfile"
printf 'fixture-bytes\n' > "$target"

symlink="/tmp/fix2-fixture-symlink-$$"
rm -f "$symlink"
ln -s "$target" "$symlink"

status=0
expect_block "Bash cat <symlink-to-/home/dev/.claude/...> (FIX-2 token-scan + readlink -f)" \
  "$(payload_bash "cat $symlink")" \
  "secret-access-denylist" "bash-resolved-to-oauth-token" || status=$?

# Cleanup — symlink + target.
rm -f "$symlink" "$target"
exit "$status"
