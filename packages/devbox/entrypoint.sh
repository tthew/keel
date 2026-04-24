#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/entrypoint.sh — Story 2.1 scope
#
# Narrowed surface (AC 2, AC 2-entrypoint-narrow). Every toolchain install
# MUST happen at image-build time (Dockerfile); this script contains:
#
#   1. workspace ownership chown (landed at Story 2.5 — default owner is
#      dev:dev; best-effort under cap_drop: [ALL] without CAP_CHOWN per
#      docs/invariants/devbox-hardening.md § Capability bounding set);
#   2. named-volume directory bring-up for /home/dev/.claude/ and
#      /home/dev/.config/gh/ so Stories 2.8 / 2.9 OAuth mounts succeed on
#      first boot even when the named volume is empty;
#   3. service keepalive via `exec "$@"` (compose CMD defaults to
#      `sleep infinity`).
#
# Forbidden at runtime (Story 2.1 AC 2): no invocations of apt / npm / pip /
# uv / pipe-to-sh installers. The Task 7 structural check enforces this with
# a grep against the committed file — keep every install at image-build time.
#
# Hardening, egress policy, healthcheck, and OAuth token materialisation land
# in Stories 2.3 / 2.4 / 2.5 / 2.8 / 2.9 / 2.13 respectively.
# ---------------------------------------------------------------------------
set -euo pipefail

# Default owner is dev:dev (Story 2.5 non-root posture per AC 1 + SC-7).
# Operator may override via KEEL_DEVBOX_WORKSPACE_OWNER for fork-specific
# UID-alignment workflows (e.g. enterprise AD-synced UIDs matching host
# ownership). The chown calls below are best-effort under cap_drop: [ALL] —
# without CAP_CHOWN in the bounding set, chown fails at runtime even under
# sudo. The calls REMAIN: failure-tolerant via stderr capture + continue
# (SC-5 expected-failure-under-hardened-posture); harmless no-ops on most
# hosts where bind-mount UID passthrough already aligns /workspace with
# dev UID 1000; useful when the container runs privileged for debugging
# (`docker run --privileged`).
WORKSPACE_OWNER="${KEEL_DEVBOX_WORKSPACE_OWNER:-dev:dev}"

# Validate WORKSPACE_OWNER shape before passing to chown.
#
# CR AI-5 (iter-133): the env-var is operator-settable via `.envrc` /
# compose `environment:` / `docker run -e`. Without validation a value like
# `--reference=/etc/shadow` would be re-parsed by chown as a flag and could
# mirror arbitrary file ownership onto /workspace. Accept only the canonical
# `user:group` shape with POSIX-portable characters. `chown --` on every
# call is belt-and-braces: terminates option parsing so even if the regex is
# relaxed in the future, `-`-prefixed owners cannot be re-interpreted as
# flags. Trust boundary here is low (operator writes their own `.envrc`),
# but defence in depth costs nothing.
#
# CR AR-2 (iter-140): widen the character class to accept POSIX-valid
# usernames with `.` (dotted like `first.last`) or `+` (AD/LDAP-mapped like
# `dev+ops`). AI-5's original `[A-Za-z0-9_-]+` under-cut the class relative
# to the injection it was defending against, so any enterprise-fork operator
# with an AD-synced username got `exit 2` on every container boot with no
# README mention of the accepted shape. The revised anchor `[A-Za-z_]` as
# the first character of each half still rejects leading digits (POSIX
# username SHALL begin with alpha or `_`) AND leading `-` (preserves the
# option-parse-injection defence); the tail class `[A-Za-z0-9_.+-]*` adds
# `.` and `+` to cover the enterprise-convention extensions. `chown --`
# remains belt-and-braces even under the widened shape.
if [[ ! "${WORKSPACE_OWNER}" =~ ^[A-Za-z_][A-Za-z0-9_.+-]*:[A-Za-z_][A-Za-z0-9_.+-]*$ ]]; then
  echo "entrypoint.sh: invalid KEEL_DEVBOX_WORKSPACE_OWNER='${WORKSPACE_OWNER}'" \
    "(expected 'user:group' with POSIX-valid chars [A-Za-z_][A-Za-z0-9_.+-]*); refusing chown" >&2
  exit 2
fi

# Per-invocation temp file for chown stderr capture.
#
# CR AR-2 (iter-140): replaces AI-5's hard-coded `/tmp/chown.err` with a
# process-unique `mktemp -t chown.XXXXXX` path. AI-5's literal path races
# under concurrent entrypoint invocations — Story 2.11 shared-workspace
# mode OR back-to-back `docker compose run --rm` on the same host clobber
# each other's stderr captures and each other's cleanup `rm`. mktemp
# returns a unique path per invocation so parallel runs cannot interfere.
# Per-block `rm -f "${chown_err}"` preserves happy-path cleanup; a
# mid-script kill before `exec` leaks a ~0-byte tmpfile which is tolerable
# because the name is unique and `/tmp` is cleared at boot.
chown_err="$(mktemp -t chown.XXXXXX)"

# Workspace mount — the compose bind maps the host main repo to
# /workspace/${KEEL_DEVBOX_REPO_NAME} (default `ralph-bmad`). The
# container-side path mirrors the host directory layout so worktrees
# appear as /workspace/<repo>/.claude/worktrees/<X>. KEEL_DEVBOX_REPO_NAME
# is propagated into the container via docker-compose.yml § environment;
# default fallback keeps the script viable when invoked outside compose
# (e.g. `docker run keel-devbox:local` for image probing).
#
# Ensure the mount root is traversable even when the host bind arrives
# with a different ownership (common on macOS + Apple Silicon Docker
# Desktop).
#
# CR AI-5 (iter-133): replaces the iter-99 blanket `|| true` with narrower
# handling — capture chown's stderr, re-emit on failure to the container's
# stderr (visible in `docker compose logs`), then continue. Preserves the
# best-effort posture (the bind mount itself is the source of truth for
# host-side ownership on backend B) while making unexpected failures
# diagnosable instead of silently swallowed.
WORKSPACE_PATH="/workspace/${KEEL_DEVBOX_REPO_NAME:-ralph-bmad}"

if [[ -d "${WORKSPACE_PATH}" ]]; then
  if ! chown -- "${WORKSPACE_OWNER}" "${WORKSPACE_PATH}" 2>"${chown_err}"; then
    cat "${chown_err}" >&2 || true
  fi
  rm -f "${chown_err}"
fi

# Named-volume directory bring-up — Stories 2.8 / 2.9 materialise the OAuth
# token payloads into these paths via compose-level named volumes. The dirs
# are pre-created by the Dockerfile; re-asserting here is idempotent and
# safe when the volume arrives empty on first boot.
for dir in /home/dev/.claude /home/dev/.config/gh; do
  if [[ ! -d "${dir}" ]]; then
    mkdir -p "${dir}"
  fi
  if ! chown -- "${WORKSPACE_OWNER}" "${dir}" 2>"${chown_err}"; then
    cat "${chown_err}" >&2 || true
  fi
  rm -f "${chown_err}"
done

# Story 2.3: fail-closed egress policy (dnsmasq + nftables). Hard-fail if init
# fails so the container cannot run without an active policy (NFR6; see
# docs/invariants/devbox-egress.md § Intent). The script is bind-mounted via
# the workspace mount so edits propagate without a rebuild.
if [ -x "${WORKSPACE_PATH}/packages/devbox/scripts/start-egress.sh" ]; then
  "${WORKSPACE_PATH}/packages/devbox/scripts/start-egress.sh"
else
  echo "entrypoint: FATAL: start-egress.sh not executable at ${WORKSPACE_PATH}/packages/devbox/scripts/; fail-closed posture requires egress init" >&2
  exit 1
fi

# Story 2.12: opt-in sshd. KEEL_DEVBOX_SSH is normalised on the host by
# resolve_ssh_state() before container start; here we honour the
# container-side env var (propagated via docker-compose.yml § environment
# by Task 4). Case-sensitive "true" match mirrors Story 2.11 shared-mode
# entrypoint posture — normalisation already done host-side.
if [[ "${KEEL_DEVBOX_SSH:-false}" == "true" ]]; then
  # Pre-creation runs as root (pre-gosu). Use gosu to create the tree
  # with dev:dev ownership from t=0 so the subsequent keygen + sshd both
  # run as dev without relying on CAP_CHOWN (Story 2.5 hardening).
  gosu dev mkdir -p /home/dev/.ssh/host_keys
  # Idempotent perm enforcement EVERY boot (not gated on existence).
  # The named volume may have been inspected from host OR pre-populated
  # with stray perms on upgrade; sshd's StrictModes (default yes) rejects
  # any parent dir more permissive than 0700, silently. Enforce.
  # gosu dev: chmod needs CAP_FOWNER when invoked by root against files
  # owned by a different UID; Story 2.5 cap_drop:[ALL] strips CAP_FOWNER,
  # so root chmod here EPERMs + set -e aborts the entrypoint before
  # keygen. dev owns these files (created via gosu dev mkdir at L141),
  # so gosu dev chmod satisfies DAC without needing CAP_FOWNER.
  gosu dev chmod 0700 /home/dev/.ssh /home/dev/.ssh/host_keys
  # Atomic host-key generation: a mid-keygen container kill leaves a
  # partial keypair which sshd refuses. Generate BOTH keys into a
  # scratch dir then atomically mv into place. Guard on BOTH algorithms'
  # final filenames — if either is missing, regenerate both.
  if [[ ! -f /home/dev/.ssh/host_keys/ssh_host_ed25519_key ]] \
     || [[ ! -f /home/dev/.ssh/host_keys/ssh_host_rsa_key ]]; then
    gosu dev rm -rf /home/dev/.ssh/host_keys.tmp
    gosu dev mkdir -p /home/dev/.ssh/host_keys.tmp
    gosu dev ssh-keygen -q -t ed25519 -f /home/dev/.ssh/host_keys.tmp/ssh_host_ed25519_key -N "" < /dev/null
    gosu dev ssh-keygen -q -t rsa -b 4096 -f /home/dev/.ssh/host_keys.tmp/ssh_host_rsa_key -N "" < /dev/null
    gosu dev mv -T /home/dev/.ssh/host_keys.tmp /home/dev/.ssh/host_keys
  fi
  # Touch authorized_keys with 0600 every boot (idempotent). Empty file
  # = no inbound auth; operator appends pubkeys via Task 6 flow (AC 5).
  [[ -f /home/dev/.ssh/authorized_keys ]] || gosu dev touch /home/dev/.ssh/authorized_keys
  # gosu dev: see chmod 0700 comment above — CAP_FOWNER is dropped, dev
  # owns authorized_keys (touched via gosu dev), so gosu dev chmod is the
  # DAC-satisfying path.
  gosu dev chmod 0600 /home/dev/.ssh/authorized_keys
  # Launch sshd as dev (port 2222 > 1024; NET_BIND_SERVICE not needed).
  # -D = foreground; backgrounded with `&` because PID 1 is the `exec
  # gosu dev "$@"` handoff below. Liveness verified post-spawn so a
  # silent sshd startup failure does NOT leave the entrypoint proceeding
  # with an un-started sshd + operator seeing port 2222 published +
  # connections refusing (§ Dev Notes § Liveness verification contract).
  gosu dev /usr/sbin/sshd -D -e 2>>/var/log/sshd.log &
  SSHD_PID="$!"
  sleep 0.5
  if ! kill -0 "${SSHD_PID}" 2>/dev/null; then
    echo "entrypoint: sshd failed to start; tail /var/log/sshd.log:" >&2
    tail -n 20 /var/log/sshd.log >&2 || true
    echo "entrypoint: sshd startup failure is NON-FATAL under Story 2.12 SC-10 (background process; PID 1 remains the exec handoff). Operator: pnpm devbox:logs keel-devbox + investigate." >&2
  fi
fi

# Hand off to the compose CMD (defaults to `sleep infinity`). Using `exec`
# preserves PID 1 for the supplied process so docker-compose signals
# (SIGTERM / SIGINT) land on the service, not on bash.
#
# The entrypoint runs as root per docker-compose.yml `user: "0:0"` override
# so that Story 2.3's privileged init (nftables rule load via nft, dnsmasq
# launch on :53, /etc/resolv.conf pin, /run writes) executes with the
# cap_add bounding set in the effective capability set. The operator-facing
# CMD must run as the non-privileged `dev` user to honour Story 2.5 SC-1.
# gosu (installed in the Dockerfile apt layer) invokes setuid()/setgid()
# syscalls directly — NOT via a setuid binary — so no-new-privileges=1 does
# NOT mask the transition. CAP_SETUID + CAP_SETGID in cap_add are what
# actually authorise the syscalls under cap_drop: [ALL].
#
# Docker ≥19.03 ambient-cap propagation was the original Story 2.5 plan
# (USER dev at image level + Docker auto-propagates cap_add to ambient set).
# Empirically this does NOT work under no-new-privileges=1 on Docker 29.2 +
# linux/arm64: CapAmb=0x0 for dev, so dev's nft + dnsmasq invocations fail
# EPERM. The "init-as-root, run-as-dev" pattern here is the corrective.
#
# CR AI-5 (iter-133) empty-CMD fallback preserved: direct `docker run
# keel-devbox:local` with no CMD must still drop to dev and stay alive.
if [ "$#" -eq 0 ]; then
  exec gosu dev sleep infinity
else
  exec gosu dev "$@"
fi
