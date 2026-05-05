#!/usr/bin/env bash
# Probe-domain three-site lockstep pre-commit gate (Story 2.13 PR #230 review iter-10).
#
# packages/devbox/docker-compose.yml carries the operational dnsmasq probe domain on
# its healthcheck line. docs/invariants/devbox-healthcheck.md and packages/devbox/README.md
# § Healthcheck mirror that literal in narrative form. The three sites must stay in
# lockstep — diverging silently rots the docs without breaking runtime.
#
# This gate extracts the probe domain from the compose healthcheck and asserts the
# literal appears in both companion docs. Cheap (three small file reads); always_run
# so deletions of either companion site fail-closed.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
compose="${repo_root}/packages/devbox/docker-compose.yml"
companions=(
  "${repo_root}/docs/invariants/devbox-healthcheck.md"
  "${repo_root}/packages/devbox/README.md"
)

probe="$(
  grep -E -m1 'dig @127\.0\.0\.1 -p 53 \+short \+time=3 \+tries=1 [^[:space:]]+' "$compose" \
    | sed -E 's/.*dig @127\.0\.0\.1 -p 53 \+short \+time=3 \+tries=1 ([^[:space:]]+).*/\1/'
)"

if [[ -z "$probe" ]]; then
  printf '✗ probe-domain-lockstep: failed to extract probe domain from %s\n' \
    "$compose" >&2
  printf '  expected line shape: dig @127.0.0.1 -p 53 +short +time=3 +tries=1 <domain>\n' >&2
  exit 1
fi

fail=0
for f in "${companions[@]}"; do
  if [[ ! -f "$f" ]]; then
    printf '✗ probe-domain-lockstep: companion site missing: %s\n' "$f" >&2
    fail=1
    continue
  fi
  if ! grep -qF -- "$probe" "$f"; then
    printf '✗ probe-domain-lockstep: probe %s missing from %s (lockstep with packages/devbox/docker-compose.yml healthcheck)\n' \
      "$probe" "$f" >&2
    fail=1
  fi
done

exit "$fail"
