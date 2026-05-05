#!/usr/bin/env bash
# D-38 (PR #230 FIX-1) regression — `python3 -c '...".env"...'` (interpreter
# string-literal) MUST block. Pre-FIX-1: anchored case-glob `python3*-[ec]*.env*`
# expected `.env` at end of command, not embedded inside an interpreter source string.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block 'python3 -c stringlit' \
  "$(payload_bash $'python3 -c \'print(open(".env").read())\'')" \
  "secret-access-denylist" "cat-env-file"
