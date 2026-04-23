#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/prereq-check.sh — Story 2.10
#
# FR5 prerequisite check: Docker runtime + Claude Code auth + gh auth.
# Runs on every host-side shim invocation (`pnpm devbox:*`, `pnpm ralph:*`)
# at pre-flight + as a standalone verb (`pnpm devbox:prereq:check`). Fails
# fast with pointer-error stderr messages if any of the three prerequisites
# is missing, so Ralph cannot execute autonomously in a broken environment.
#
# Tiers:
#   --tier1  Docker runtime only (used by every `pnpm devbox:*` shim + by
#            `pnpm claude` + `pnpm gh:auth` to keep auth-establishing verbs
#            usable even with no tokens present).
#   --tier2  Docker + Claude + gh (default; used by `pnpm ralph:build` +
#            `pnpm ralph:plan` + standalone invocation).
#
# Exit codes (Story 2.6 uniform schema, extended):
#   0   all checks pass (silent).
#   2   one or more tokens missing (composite pointer list emitted, Claude
#       before gh; AC 5 + SC-5 no-partial-bypass; tier2 only). Also returned
#       for unknown-arg usage errors.
#   8   docker runtime unreachable (install-pointer emitted:
#       https://docs.docker.com/desktop/install/; tier1 + tier2).
#   12  other docker-daemon error (volume-inspect crash, alpine pull
#       failure under fail-closed egress; propagated via docker's exit).
#
# Token-probe image (SC-4 + SC-7): `alpine:3.19` — pinned here, in
# docs/invariants/devbox-prereq-check.md § Alpine probe image, and in
# packages/devbox/README.md § Prerequisite check. All three must update in
# lockstep (manifest contentHash binds the doc; source + README are
# convention-enforced).
#
# Token-probe paths (SC-3):
#   Claude: /home/dev/.claude/.credentials.json (upstream
#           @anthropic-ai/claude-code@2.1.116 post-OAuth write path).
#   gh:     /home/dev/.config/gh/hosts.yml (upstream gh CLI default).
#
# Existence only — no content validity check (SC-15); expired tokens
# surface downstream at actual `claude`/`gh` invocation time.
# ---------------------------------------------------------------------------
set -euo pipefail

# Story 2.6 AI-8 + AI-12 + Story 2.7/2.8/2.9 SC-8/SC-10 defensive posture.
# Operator-shell COMPOSE_PROJECT_NAME export would redirect volume-name
# derivation away from INV-devbox-homedev-named-volume's
# `keel-devbox_keel_home_dev` path.
unset COMPOSE_PROJECT_NAME

VOLUME_NAME="${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}_keel_home_dev"
PROBE_IMAGE="alpine:3.19"  # SC-7: manually version-tracked; Renovate docker regex-manager deferred.

log() { printf '[prereq-check] %s\n' "$*" >&2; }

# Arg parsing — accept --tier1 or --tier2 (default --tier2).
tier="tier2"
case "${1:-}" in
  --tier1) tier="tier1" ;;
  --tier2|"") tier="tier2" ;;
  *) log "usage: $(basename "$0") [--tier1|--tier2]"; exit 2 ;;
esac

# -------- Tier 1: Docker runtime reachable --------
# Tighter `--format '{{.ServerVersion}}'` variant per Story 2.7/2.8/2.9
# inheritance chain — avoids the bare `docker info`'s verbose stdout.
if ! docker info --format '{{.ServerVersion}}' >/dev/null 2>&1; then
  log "docker unreachable — is the daemon running?"
  log "install Docker Desktop: https://docs.docker.com/desktop/install/"
  exit 8
fi

if [[ "${tier}" == "tier1" ]]; then
  exit 0
fi

# -------- Tier 2: Claude + gh tokens --------
#
# Fresh-fork first-run semantics (AC 5): if the named volume does not exist
# yet (operator has not run `pnpm devbox:start` for the first time), treat
# both tokens as missing. We do NOT invoke `docker run -v` against a
# non-existent volume because Docker would auto-create an empty volume as a
# side-effect — unwanted at pre-flight time.
volume_present=0
rc=0
docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1 || rc=$?
case "${rc}" in
  0) volume_present=1 ;;
  1) volume_present=0 ;;
  *) log "docker daemon error during volume inspect (rc=${rc})"; exit 12 ;;
esac

claude_present=0
gh_present=0

if [[ "${volume_present}" -eq 1 ]]; then
  # Read-only mount of the named volume into a throwaway alpine probe.
  # `test -e <path>` returns 0 iff the path exists; rc=1 iff the probed
  # path is missing (token not yet written). Any other rc is a docker-
  # daemon / image-pull / exec failure and MUST surface as exit 12 rather
  # than silently collapse to "not authed" — operator remediation for a
  # daemon crash is different from remediation for a missing token.
  rc=0
  docker run --rm -v "${VOLUME_NAME}":/vol:ro "${PROBE_IMAGE}" \
      test -e /vol/.claude/.credentials.json >/dev/null 2>&1 || rc=$?
  case "${rc}" in
    0) claude_present=1 ;;
    1) claude_present=0 ;;
    *) log "docker daemon error during Claude token probe (rc=${rc})"; exit 12 ;;
  esac
  rc=0
  docker run --rm -v "${VOLUME_NAME}":/vol:ro "${PROBE_IMAGE}" \
      test -e /vol/.config/gh/hosts.yml >/dev/null 2>&1 || rc=$?
  case "${rc}" in
    0) gh_present=1 ;;
    1) gh_present=0 ;;
    *) log "docker daemon error during gh token probe (rc=${rc})"; exit 12 ;;
  esac
fi

# Aggregate findings into a composite stderr message (AC 5 + SC-5), Claude
# before gh per Stories 2.8 → 2.9 landing order.
missing=0
if [[ "${claude_present}" -eq 0 ]]; then
  log "Claude Code not authed — run 'pnpm claude' first"
  missing=1
fi
if [[ "${gh_present}" -eq 0 ]]; then
  log "gh CLI not authed — run 'pnpm gh:auth' first"
  missing=1
fi

if [[ "${missing}" -eq 1 ]]; then
  exit 2
fi

exit 0
