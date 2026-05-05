#!/usr/bin/env bash
# D-38 (PR #230 FIX-1) regression — `cat ".env"` (double-quoted filename) MUST block.
# Pre-FIX-1: anchored case-glob `cat*.env|cat*.env.*|cat*/.env|cat*/.env.*` failed to
# match because the trailing `"` is not in the anchored suffix set.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block 'cat ".env" (double-quoted)' "$(payload_bash 'cat ".env"')" "secret-access-denylist" "cat-env-file"
