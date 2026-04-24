# INV-devbox-mode

Per-fork vs shared devbox mode contract (Story 2.11). `KEEL_DEVBOX_SHARED` in
`.envrc` branches compose project name, container name, bind source, and
named-volume name between two modes. The per-fork mode is the substrate
default; shared mode is an opt-in operator escape hatch for N=1 dogfood.

The authoritative resolution site is the
`resolve_mode_specific_state()` function in
`packages/devbox/scripts/lib/main-repo-resolver.sh`; every host-side shim
under `packages/devbox/scripts/*.sh` sources it and invokes
`resolve_main_repo_and_workdir` → `resolve_mode_specific_state` at
pre-flight.

## Mode signal

`KEEL_DEVBOX_SHARED` is read from the process env (set by `.envrc` via
direnv). Normalisation rules:

- The value is lowercased (`tr '[:upper:]' '[:lower:]'`).
- Exactly the literal string `"true"` routes to shared mode.
- Any other value (`false`, `0`, `no`, empty, unset, `yeah`, etc.)
  defaults to per-fork mode.
- Operator typos `TRUE`, `True`, `true` all route to shared (case-fold).
- Fail-closed posture: unrecognised values silently fall back to the safe
  per-fork mode rather than erroring out. Operators wanting shared mode
  MUST set `KEEL_DEVBOX_SHARED=true` literally.

## Per-fork mode contract

Default posture when `KEEL_DEVBOX_SHARED` is unset or not `"true"`.

- **Compose project name:** `keel-devbox` (compose-file top-level `name:`
  resolves to `${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}` via
  interpolation).
- **Container name:** `keel-devbox` (or `KEEL_DEVBOX_CONTAINER_NAME`
  operator override per Story 2.1 per-fork collision path).
- **Named volume:** `keel-devbox_keel_home_dev` (fully-qualified =
  `${KEEL_DEVBOX_COMPOSE_PROJECT}_keel_home_dev`).
- **Bind source:** fork root (`<host>/<fork>`) — `KEEL_DEVBOX_WORKSPACE`
  exports to `MAIN_REPO` which resolves via `git rev-parse --show-toplevel`.
- **Bind target:** `/workspace/<fork-basename>` — container-side path
  mirrors host directory layout per iter-239 mount-path mirroring.

Two forks running per-fork mode cannot share state. A second
`pnpm devbox:start` from fork B while fork A's container is running
triggers a Compose "container name already in use" collision unless fork B
sets `KEEL_DEVBOX_CONTAINER_NAME` in its own `.envrc`.

## Shared mode contract

Opt-in posture when `KEEL_DEVBOX_SHARED=true`.

- **Compose project name:** `keel-devbox-shared` (HARDCODED; operator's
  `KEEL_DEVBOX_COMPOSE_PROJECT` setting is intentionally ignored — shared
  mode is opinionated).
- **Container name:** `keel-devbox-shared` (HARDCODED; operator's
  `KEEL_DEVBOX_CONTAINER_NAME` override is INTENTIONALLY IGNORED). AC 2
  requires fork A and fork B to attach to the SAME container; an
  operator-specific override would silently break that. The override path
  is gated at per-fork mode only.
- **REPO_NAME:** parent-dir basename, HARDCODED to `$(basename $(dirname
  $MAIN_REPO))` regardless of operator `KEEL_DEVBOX_REPO_NAME` (INTENTIONALLY
  IGNORED in shared mode). AC 2 requires fork A and fork B to resolve to
  the SAME `/workspace/<parent>/` bind target; a per-fork `KEEL_DEVBOX_REPO_NAME`
  override would silently produce divergent container paths (second fork's
  `docker exec -w` would hit ENOENT against the first fork's bind target).
  The override path is gated at per-fork mode only. Posture extends SC-4's
  `KEEL_DEVBOX_CONTAINER_NAME` opinionation consistently (iter-261 PATCH-1).
- **Named volume:** `keel-devbox-shared_keel_home_dev`.
- **Bind source:** PARENT directory of the fork root (matches upstream
  cc-devbox's `/Users/tthew/Development:/workspace:delegated` pattern per
  architecture.md:547).
- **Bind target:** `/workspace/<parent-basename>` — producing
  `/workspace/Development/{ralph-bmad,fork-A,fork-B}/` in the container.

Fork B's `pnpm devbox:start` detects the existing `keel-devbox-shared`
container via `docker inspect` and becomes a no-op health-poll. Both forks
share state through the single container + single named volume.

### Shared-mode bind scope (security posture)

Shared mode binds the PARENT directory of the fork root — ANY other
project under that parent becomes container-visible. This is BY DESIGN
(matches upstream cc-devbox's `/Users/tthew/Development` pattern; N=1
dogfood). Fork operators MUST understand that shared mode extends the
bind source's blast radius beyond the fork root.

## Resolver contract

`packages/devbox/scripts/lib/main-repo-resolver.sh §
resolve_mode_specific_state()` is the single resolution site. Every
host-side shim under `packages/devbox/scripts/*.sh` invokes it AFTER
`resolve_main_repo_and_workdir` and BEFORE any downstream `docker
inspect` / `docker compose` / `docker exec` / `docker rm` / `docker logs`
call.

Invocation sequence:

```
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_main_repo_and_workdir
resolve_mode_specific_state
export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"
```

The resolver exports:

- `KEEL_DEVBOX_COMPOSE_PROJECT` (`keel-devbox` or `keel-devbox-shared`).
- `KEEL_DEVBOX_CONTAINER_NAME_RESOLVED` (same two values).
- Mode-adjusted `WORKTREE_ROOT` / `MAIN_REPO` / `REPO_NAME` /
  `CONTAINER_WORKDIR` (shared mode flips to the parent directory).

Reversal of the two-step sequence (`resolve_mode_specific_state` before
`resolve_main_repo_and_workdir`) is invalid — the shared-mode flip
depends on `MAIN_REPO` having been computed first. Every shim pins the
order.

## Concurrency decision (AC 4)

Shared mode's concurrency posture is **single-operator-at-a-time by
convention, NOT by Docker enforcement**.

- The container runs exactly ONE Ralph TUI process at a time (one `CMD`
  PID 1).
- Docker permits multiple concurrent `docker attach` clients against the
  same running container; they share stdin/stdout, producing
  **interleaved TUI input and output corruption** (NOT an automatic
  detach-the-first behaviour).
- Operators MUST coordinate out-of-band (one Ralph operator at a time).
- Non-Ralph operations (`pnpm devbox:shell`, `pnpm claude`,
  `pnpm gh:auth`) use `docker exec` which spawns independent PIDs; those
  ARE parallel-safe across forks. Each fork's exec session lands at its
  own `/workspace/<parent>/<fork>/` path per `CONTAINER_WORKDIR` resolver.

Conflicting writes to `/home/dev/` are avoided by design:

- Claude OAuth token: single-writer-multi-reader (one `pnpm claude` at a
  time; subsequent reads share the same token).
- gh OAuth token: same posture.
- Bash history: append-only.
- Claude Code's `CLAUDE_CODE_TASK_LIST_ID` scopes per-exec-session
  (independent task lists across concurrent exec sessions).

Operators needing TRUE parallel Ralph across forks MUST revert to
per-fork mode (each fork gets its own container + its own TUI PID 1 —
the default posture).

Dev-agent guardrail: do NOT implement a
"second-attach-auto-detaches-first" feature — Docker does not expose
that semantic; shared mode's concurrency story is convention-first, not
machinery-first.

## Mid-use flip warning

When an operator flips `KEEL_DEVBOX_SHARED` from `false` to `true` (or
`true` to `false`) mid-use while a container from the PRIOR mode still
exists on the host daemon, `pnpm devbox:env:check` probes the
OTHER-mode's container via `docker inspect` and emits a single stderr
warning pointing at `pnpm devbox:clean`.

Warning-only posture: the warning DOES NOT alter the exit code. The
existing env-check exit schema (0 all pass, 2 missing var / shape
violation, 3 `.envrc` unreadable, 8 docker unreachable via Story 2.10
prereq-check) is preserved.

Three-site lockstep: the exact warning strings below are pinned here +
MUST appear verbatim in `packages/devbox/scripts/env-check.sh` (emit
site) + `packages/devbox/README.md § Per-fork vs shared mode § Mid-use
flip`. Drift hazard per Story 2.10 DEFER-4 — convention-enforced at 1.0.

**Case A — current mode is shared; orphan is per-fork-mode container:**

```
env-check: warning: orphaned per-fork-mode container 'keel-devbox' detected from a previous KEEL_DEVBOX_SHARED=false session; run 'pnpm devbox:clean' (after re-flipping .envrc to KEEL_DEVBOX_SHARED=false if needed) or 'docker rm -f keel-devbox' to remove it. See packages/devbox/README.md § Per-fork vs shared mode § Mid-use flip.
```

**Case B — current mode is per-fork; orphan is shared-mode container:**

```
env-check: warning: orphaned shared-mode container 'keel-devbox-shared' detected from a previous KEEL_DEVBOX_SHARED=true session; run 'pnpm devbox:clean' (after re-flipping .envrc to KEEL_DEVBOX_SHARED=true if needed) or 'docker rm -f keel-devbox-shared' to remove it. See packages/devbox/README.md § Per-fork vs shared mode § Mid-use flip.
```

Operator remediation flow:

1. Optionally re-flip `.envrc` to the orphan's mode.
2. Run `pnpm devbox:clean` to tear down the orphan (the named volume is
   preserved by default; `--with-volumes` scopes to the current mode's
   volume only — the OTHER mode's state is untouched).
3. Re-flip `.envrc` back to the desired mode.
4. Re-run `pnpm devbox:start`.

Named-volume persistence is intentional — the old OAuth tokens may be
needed if the operator re-flips again. Two modes = two separate named
volumes = two separate OAuth-token stores; no cross-mode sharing.

## Named volume relationship to INV-devbox-homedev-named-volume

Story 2.5's `INV-devbox-homedev-named-volume` pins the UNQUALIFIED
volume name `keel_home_dev` (the substrate-authoritative contract).
Story 2.11 does NOT relax that invariant — the unqualified name is
unchanged; only the compose-project prefix varies.

Fully-qualified volume name:
`${KEEL_DEVBOX_COMPOSE_PROJECT}_keel_home_dev` resolves to:

- `keel-devbox_keel_home_dev` (per-fork mode, default)
- `keel-devbox-shared_keel_home_dev` (shared mode)

Two modes = two separate volumes. OAuth tokens do NOT cross modes.
Operator switching modes re-auths (expected — AC 3's orphan warning
surfaces the flip).

## Invariant stability

- **Substrate default:** per-fork mode. Shared mode is an opt-in
  operator escape hatch.
- **Forks MAY NOT remove or re-default the per-fork mode.** Substrate
  default preservation per `docs/invariants/fork.md § Amendment-vs-fork
  decision tree` (Story 1.16).
- **Fork-level Growth-tier `INVARIANTS.fork.md` rules MAY add fork-
  specific mode constraints** (e.g., "disable shared mode for compliance
  reasons") but MAY NOT weaken substrate defaults. The per-fork-mode
  default is substrate-authoritative; fork rules compose additively on
  top.
- **Operator `KEEL_DEVBOX_CONTAINER_NAME` + `KEEL_DEVBOX_REPO_NAME` overrides:**
  both preserved in per-fork mode; both intentionally ignored in shared
  mode (opinionated — shared mode REQUIRES a hardcoded container name AND
  a hardcoded REPO_NAME for AC 2; a per-fork override of either would
  silently break cross-fork container-attach or produce divergent
  `/workspace/<parent>/` bind targets).
- **Exit-code schema:** unchanged. Story 2.6's uniform schema
  (`0`/`2`/`3`/`8`/`9`/`10`/`11`/`12`) + Story 2.10's Tier 1/Tier 2
  additions apply as-is; the orphan warning is stderr-only.
- **Compose-config single-source:** `KEEL_DEVBOX_COMPOSE_PROJECT` is
  set by the resolver; consumed by compose's top-level `name:` key; consumed
  by `prereq-check.sh`'s `VOLUME_NAME` derivation. Three sites, one source.
