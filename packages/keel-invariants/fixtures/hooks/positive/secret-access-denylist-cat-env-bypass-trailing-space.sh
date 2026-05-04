#!/usr/bin/env bash
# D-38 (PR #230 FIX-1) regression — `cat .env ` (trailing whitespace) MUST block.
# Pre-FIX-1: anchored case-glob did not tolerate trailing ` `.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block 'cat .env (trailing space)' "$(payload_bash 'cat .env ')" "secret-access-denylist" "cat-env-file"
