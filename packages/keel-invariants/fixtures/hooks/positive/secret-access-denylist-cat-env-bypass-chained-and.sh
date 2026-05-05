#!/usr/bin/env bash
# D-38 (PR #230 FIX-1) regression — `cat .env && true` (chained) MUST block.
# Pre-FIX-1: anchored case-glob did not tolerate trailing ` && true`.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block 'cat .env && true (chained)' "$(payload_bash 'cat .env && true')" "secret-access-denylist" "cat-env-file"
