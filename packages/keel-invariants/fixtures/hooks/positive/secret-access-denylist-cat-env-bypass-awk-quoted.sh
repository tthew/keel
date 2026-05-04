#!/usr/bin/env bash
# D-38 (PR #230 FIX-1) regression — `awk '{print}' ".env"` (reader-verb with
# leading-arg + double-quoted filename) MUST block. Pre-FIX-1: anchored case-glob
# `awk*.env|awk*.env.*` failed to match because the trailing `"` defeats the
# end-of-string anchor.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block 'awk leading-arg + quoted-trailing' \
  "$(payload_bash $'awk \'{print}\' ".env"')" \
  "secret-access-denylist" "cat-env-file"
