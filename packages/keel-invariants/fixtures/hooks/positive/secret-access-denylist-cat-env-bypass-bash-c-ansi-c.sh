#!/usr/bin/env bash
# D-38 (PR #230 FIX-1) regression — `bash -c $'cat .env'` (ANSI-C wrapper)
# MUST block. Coverage continuity test for D-37 wrapper-strip arm: post-FIX-1
# the strip still produces `cat .env` which matches the new env_file_re.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
expect_block 'bash -c ANSI-C wrapper' \
  "$(payload_bash $'bash -c $\'cat .env\'')" \
  "secret-access-denylist" "cat-env-file"
