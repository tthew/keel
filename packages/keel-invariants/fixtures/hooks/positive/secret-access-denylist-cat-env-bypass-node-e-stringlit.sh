#!/usr/bin/env bash
# D-38 (PR #230 FIX-1) regression — `node -e '...".env"...'` (interpreter
# string-literal) MUST block. Pre-FIX-1: anchored case-glob expected `.env` at
# end of command, not embedded inside JS source.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block 'node -e stringlit' \
  "$(payload_bash $'node -e \'require("fs").readFileSync(".env")\'')" \
  "secret-access-denylist" "cat-env-file"
