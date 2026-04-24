#!/usr/bin/env bash
# Replays every fixture under positive/ + negative/. Exits nonzero on first FAIL,
# prints PASS/FAIL line per fixture. Intended for impl-time smoke runs + future-Ralph
# re-exercise of block-secret-access.sh without re-authoring probe scripts.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

fixtures=()
for d in positive negative; do
  while IFS= read -r -d '' f; do
    fixtures+=("$f")
  done < <(find "$HERE/$d" -maxdepth 1 -type f -name '*.sh' -print0 | sort -z)
done

total=${#fixtures[@]}
passed=0
failed=0
for f in "${fixtures[@]}"; do
  if bash "$f"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
  fi
done

printf '\nSUMMARY: %d passed / %d failed / %d total\n' "$passed" "$failed" "$total"
[ "$failed" -eq 0 ]
