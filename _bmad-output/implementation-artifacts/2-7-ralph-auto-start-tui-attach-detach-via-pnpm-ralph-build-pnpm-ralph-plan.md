# Story 2.7: Ralph auto-start + TUI attach/detach via `pnpm ralph:build` / `pnpm ralph:plan`

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want `pnpm ralph:build` and `pnpm ralph:plan` to check container state, auto-start the devbox if needed, and attach the Textual TUI with `Ctrl+P Ctrl+Q` detach preserving the running loop,
So that I can invoke Ralph without manual container lifecycle management (FR2).

## Acceptance Criteria

1. **Auto-start on stopped container.** Given the devbox is not running, when I run `pnpm ralph:build`, then the command invokes `pnpm devbox:start` (from Story 2.6) internally and waits for the container to become healthy before attaching.

2. **Skip-start on running container.** Given the devbox is already running, when I run `pnpm ralph:build` or `pnpm ralph:plan`, then the command skips the start step and attaches directly.

3. **Ctrl+P Ctrl+Q detach preserves loop.** Given the TUI is attached inside the container (Textual-based, consuming `packages/devbox/tui/theme.py` from Story 1.12), when I press `Ctrl+P Ctrl+Q`, then I detach from the container and the Ralph loop continues running inside. (Story 2.7 scope is the `docker attach --detach-keys='ctrl-p,ctrl-q'` envelope; the in-container TUI process itself is Epic 3's scope — see § Scope clarifications SC-2.)

4. **Re-attach preserves state.** Given a detached Ralph loop is running, when I re-attach via `pnpm devbox:attach` (or re-invoking `pnpm ralph:build`), then the TUI state is preserved (scroll position, current iteration) and no state is lost. (Story 2.7 ships the re-attach envelope. TUI-state-preservation inside the Textual app is Epic 3's delivery — see § Scope clarifications SC-2.)

5. **Mode routing.** Given build mode vs plan mode, when `pnpm ralph:build` invokes the loop, then the harness (Epic 3) reads `.ralph/PROMPT_build.md` and `pnpm ralph:plan` reads `.ralph/PROMPT_plan.md`; this Epic 2 story only ensures the invocation path. Prompt-file semantics land in Epic 3. (Story 2.7 ships two distinct host-side verbs that each pass a mode signal the in-container harness can consume — see § Mode routing.)

## Tasks / Subtasks

- [ ] **Task 1: Author `packages/devbox/scripts/ralph-build-host.sh`** (AC 1, AC 2, AC 3, AC 5)
  - [ ] Shebang + `set -euo pipefail` + `unset COMPOSE_PROJECT_NAME` (Story 2.6 AI-8/AI-12 pattern).
  - [ ] Script banner: purpose (FR2 invocation path for build mode), dual-ref (Story 2.7 AC 1–5 + Story 2.6 `<verb>-host.sh` pattern), exit-code contract.
  - [ ] `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`; `CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"`.
  - [ ] Pre-flight 1 — docker daemon: `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log "docker unreachable"; exit 8; }`.
  - [ ] Auto-start branch — `status="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"`; `if [[ "${status}" != "running" ]]; then log "container not running; invoking pnpm devbox:start"; "${SCRIPT_DIR}/start.sh" || exit $?; fi` (satisfies AC 1).
  - [ ] Skip-start branch — when `status == "running"`, log `"container already running; attaching directly"` and proceed to attach (satisfies AC 2).
  - [ ] Mode signal — export `KEEL_RALPH_MODE=build` (env var consumed by Epic 3's in-container Ralph runtime to select `.ralph/PROMPT_build.md`). See § Mode routing.
  - [ ] Attach — `log "attaching to ${CONTAINER_NAME} (detach: Ctrl+P Ctrl+Q)"` then `exec docker attach --detach-keys='ctrl-p,ctrl-q' "${CONTAINER_NAME}"` (interactive-only; no TTY-detect gate per Story 2.6 AR-10 — attach IS the AC).
  - [ ] Exit-code schema: `0` clean detach, `8` docker unreachable, `9` container not running (post-auto-start fallback should never hit; emitted if `start.sh` succeeded but container exited between inspect + attach), `10` image not built (propagated from `start.sh` exit 10), `11` healthcheck timeout (propagated from `start.sh` exit 11), `*` docker attach error (propagated).

- [ ] **Task 2: Author `packages/devbox/scripts/ralph-plan-host.sh`** (AC 1, AC 2, AC 3, AC 5)
  - [ ] Structural mirror of Task 1 with `KEEL_RALPH_MODE=plan`.
  - [ ] Identical banner + pre-flight + auto-start + attach sequence; only the mode signal + log strings differ.
  - [ ] Dev-agent guardrail: DO NOT refactor the two scripts into a shared `_lib.sh` yet — Story 2.6 AR-19 flagged library-extraction as a deferred refactor candidate across the full script set (will be triggered at ≥10-script-duplication threshold; this story brings the total to 15 scripts under `packages/devbox/scripts/`). Story 2.7 writes the two scripts verbatim duplicated; `_lib.sh` extraction is a separate future story.

- [ ] **Task 3: Root `package.json` pnpm wiring** (AC 1, AC 2, AC 5 — operator-surface discoverability)
  - [ ] Add two entries to `scripts` in lifecycle order:
    ```json
    "ralph:build": "./packages/devbox/scripts/ralph-build-host.sh",
    "ralph:plan": "./packages/devbox/scripts/ralph-plan-host.sh",
    ```
  - [ ] Insertion point — AFTER `"devbox:env:check"` entry and BEFORE `"prepare"` (Story 2.6 precedent: devbox block ordering; ralph block is the logical next group).
  - [ ] Smoke: `pnpm run` lists `ralph:build` + `ralph:plan` alongside the 13 `devbox:*` verbs.

- [ ] **Task 4: Operator documentation in `packages/devbox/README.md`** (AC 1, AC 2, AC 3, AC 4, AC 5 — operator comprehension)
  - [ ] Append new H3 `### Ralph loop (Story 2.7)` section AFTER existing `### Host-side CLI (Story 2.6)` H3.
  - [ ] Content: (a) quick-start `pnpm ralph:build` + `pnpm ralph:plan` command examples; (b) auto-start-if-needed contract (AC 1–2); (c) Ctrl+P Ctrl+Q detach affordance + `pnpm devbox:attach` re-attach (AC 3–4); (d) mode-routing note — build mode reads `.ralph/PROMPT_build.md`, plan mode reads `.ralph/PROMPT_plan.md`, prompt-file semantics are Epic 3 scope; (e) exit-code reference (0/8/9/10/11 shared with Story 2.6 schema); (f) a one-line cross-ref to `AGENTS.md § Ralph loop` for agent-facing guidance.
  - [ ] Tone: mirror Story 2.6's `### Host-side CLI` section's voice; terse, operator-grade, command-first.

- [ ] **Task 5: Agent documentation in `AGENTS.md`** (AC 1, AC 2, AC 5 — agent operational contract)
  - [ ] Append new H3 `### Ralph loop (Story 2.7)` section AFTER existing `### Host-side CLI (Story 2.6)` H3 under § Devbox iteration environment.
  - [ ] Content: (a) wrapper-pattern pointer — `ralph-build-host.sh` + `ralph-plan-host.sh` as the canonical shims; NEVER invoke `docker attach` or `ralph.py` directly from agent contexts (FR1 non-toggle-able invariant extension); (b) mode-signal contract — `KEEL_RALPH_MODE=build|plan` env var propagated to the in-container Ralph runtime (Epic 3 consumer); (c) exit-code passthrough contract (Story 2.6 schema preserved); (d) scope carve-out — Story 2.7 ships invocation path; in-container Ralph TUI + prompt-file semantics land in Epic 3.
  - [ ] Tone: mirror Story 2.6's AGENTS.md contribution — operational-truth + terse cross-refs, no narration of implementation.

- [ ] **Task 6: Iteration-env-safe smoke tests** (AC 1, AC 2, AC 5 verification within backend-B constraints)
  - [ ] Smoke 1 — `bash -n packages/devbox/scripts/ralph-build-host.sh packages/devbox/scripts/ralph-plan-host.sh` (syntax parse under bash 5.x).
  - [ ] Smoke 2 — `pnpm run 2>&1 | grep -E '^ +(ralph:build|ralph:plan)'` → two matches (pnpm wiring verified).
  - [ ] Smoke 3 — stub-docker harness (workspace-based per iter-212 LESSON — place stub `docker` under `<workspace>/.ralph-smoke/shim/` NOT `/tmp/` because tmpfs noexec): verify `ralph-build-host.sh` exits 8 when `docker info` fails (stub returns non-zero on `info`) + exits propagating `start.sh` exit code when the container is not running + issues `docker attach --detach-keys='ctrl-p,ctrl-q' keel-devbox` as the final exec line. See Story 2.6 `env-check.sh` smokes for the harness pattern.
  - [ ] Smoke 4 — mode-signal check: under stub-docker, confirm `KEEL_RALPH_MODE=build` is exported by `ralph-build-host.sh` before the `docker attach` line (via `env | grep KEEL_RALPH_MODE` captured pre-exec under a `set -x`-instrumented re-run).
  - [ ] Clean up `.ralph-smoke/` on exit (`trap 'rm -rf .ralph-smoke/' EXIT`).
  - [ ] **Deferred to operator workstation:** AC 3 (live Ctrl+P Ctrl+Q detach preserving a running Ralph loop) + AC 4 (re-attach preserves TUI state) — these require an in-container Ralph TUI process as PID 1 (or equivalent long-running Textual app), which Epic 3 delivers. Under the current `CMD: [sleep, infinity]` container, AC 3's "loop continues running inside" reduces to "container continues running after detach" (verifiable — container stays `running` state post-detach) but AC 4's TUI-state-preservation is trivially satisfied by `sleep infinity` (no state). Full AC 3/4 verification deferred to Epic 3 delivery + M4-Pro operator workstation smoke per Story 2.5 iter-187 + Story 2.6 iter-201/204/216/219 precedent.

- [ ] **Task 7: Change Log + sprint-status housekeeping** (lifecycle bookkeeping)
  - [ ] Story file § Change Log — v1.0 "Initial draft; dev-ready" entry.
  - [ ] Sprint-status update is handled by the `/bmad-create-story` workflow's step 6 automation (not a dev-story task).
  - [ ] Dev-story iteration upkeep: when this story lands, update `RALPH.md § Lessons` with the ralph-host shim pattern (if the TTY-detect decision for attach shims evolves post-Story-2.6 AR-10) + `AGENTS.md § Ralph loop` cross-refs.

## Dev Notes

### Scope clarifications (SC-1..SC-16)

**SC-1 — Story 2.6 host-side CLI is the composable substrate.** Story 2.7 composes on Story 2.6's `pnpm devbox:start` (auto-start), `pnpm devbox:attach` (re-attach primitive), `packages/devbox/scripts/start.sh` + `attach.sh` (callable sub-routines from ralph-*-host.sh via `SCRIPT_DIR/start.sh`), and the uniform exit-code schema (codes 0/8/9/10/11). ralph-*-host.sh does NOT re-implement start-poll-healthcheck — it delegates to `start.sh` via `exec` or direct sub-invocation. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes; architecture.md:991-1004]

**SC-2 — In-container Ralph TUI process is Epic 3's scope.** Story 2.7's AC 3 and AC 4 reference a Textual-based TUI consuming `packages/devbox/tui/theme.py`. The Textual TUI process itself (the long-running Ralph harness that reads `.ralph/PROMPT_build.md` / `PROMPT_plan.md`, invokes `claude -p`, renders kanban + log panels + context-meter footer, preserves state across attach/detach) lives in Epic 3 (FR7 Ralph loop mechanics). Story 2.7 ships the HOST-SIDE ATTACH ENVELOPE ONLY: the `docker attach --detach-keys='ctrl-p,ctrl-q'` invocation that connects the operator terminal to the container's PID 1 stdio. Under the current `CMD: [sleep, infinity]` container, `docker attach` connects to a quiescent sleep process — AC 3 reduces to "container continues running after detach" (verifiable — container stays `running`) and AC 4 reduces to "no state to lose" (trivially satisfied by the quiescent process). Full TUI-state verification happens at Epic 3 delivery time when the in-container Ralph runtime is materialized. [Source: epics.md:1411-1415 "this Epic 2 story only ensures the invocation path; prompt-file semantics land in Epic 3"; prd.md:477 "Ralph itself is a Python Textual TUI running inside the devbox"; architecture.md:79 "Ralph's internal Python Textual TUI is orchestration-only (runs inside devbox), not a user-facing 1.0 surface"]

**SC-3 — File placement under `packages/devbox/scripts/` (not `packages/ralph/`).** Two options were considered: (a) `packages/devbox/scripts/ralph-*-host.sh` co-located with the 13 Story 2.6 scripts; (b) new `packages/ralph/scripts/` directory. Architecture.md:991-1004 shows the scripts tree under `packages/devbox/scripts/` without a `packages/ralph/` sibling; epics.md architecture reference naming convention is `<verb>-host.sh` at `packages/devbox/scripts/`. Story 2.7 chooses (a) — place alongside devbox scripts — because: (i) the scripts ARE docker/compose-orchestration operations at heart (pre-flight docker check, container-state inspect, start-if-needed, attach); (ii) co-location preserves the `ls packages/devbox/scripts/` discovery path; (iii) avoids creating a new `packages/` entry for only 2 files (YAGNI); (iv) follows Story 2.6 `<verb>-host.sh` naming verbatim. Downstream stories that introduce per-package ralph-owned scripts (Story 2.17 bypass-resistance, Epic 3 in-container Ralph) MAY introduce `packages/ralph/` at that time. [Source: architecture.md:991-1004 scripts tree; Story 2.6 iter-201 placement precedent]

**SC-4 — `<verb>-host.sh` naming convention is mandatory.** `ralph-build-host.sh` and `ralph-plan-host.sh` (not `ralph-build.sh` / `ralph-plan.sh`) — the `-host` suffix disambiguates host-side shims from potential future in-container primitives, matching Story 2.6's `monitor-host.sh` + `whitelist-host.sh` precedent (verified Acceptance Auditor ZERO-FINDING across 3 CR passes at iter-204 / iter-216 / iter-219). [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-15; RALPH.md § Signposts `<verb>-host.sh` shim naming]

**SC-5 — Mode signal via `KEEL_RALPH_MODE` env var (not CLI arg).** Story 2.7's two wrappers differ only in the mode they signal to the in-container harness. Options: (a) exported env var `KEEL_RALPH_MODE=build|plan`; (b) `docker attach` argument (no — attach doesn't accept runtime args); (c) filesystem sentinel `.ralph/.mode` (no — brittle under worktree resolution); (d) script-name inference (Epic 3 greps `/proc/1/cmdline` — brittle). Choose (a): `export KEEL_RALPH_MODE=build` (or `plan`) before the `docker attach` line. Epic 3's in-container Ralph runtime reads this env var at startup to select `.ralph/PROMPT_build.md` vs `.ralph/PROMPT_plan.md`. Compose's `env_file: ../../.envrc` (docker-compose.yml:57) means env vars set by the host wrapper at attach-time are NOT automatically propagated to the already-running container process — the in-container Ralph runtime must poll the env var at its own startup. For the initial attach (AC 1 auto-start path), the env var is available in the compose-exec env. For re-attach to an already-running container (AC 2 skip-start path), the env var is consumed only if Epic 3's in-container runtime re-reads it on each attach OR if the operator's initial `ralph:build`/`ralph:plan` invocation seeded it. Story 2.7 exports the env var + documents the contract; Epic 3 is responsible for consuming. If Epic 3 decides a different mode-signaling mechanism is preferable (e.g., a file sentinel or a systemd-style service file), this SC is the amendment point. [Source: epics.md:1411-1415; Story 2.6 COMPOSE env-var plumbing precedent]

**SC-6 — `docker attach --detach-keys='ctrl-p,ctrl-q'` is pinned explicitly.** `docker attach` defaults to `Ctrl+P Ctrl+Q` for detach already, but Story 2.6 AC 6 + `attach.sh:39` pinned `--detach-keys='ctrl-p,ctrl-q'` EXPLICITLY to guard against future docker-default changes. Story 2.7 ralph-*-host.sh scripts apply the same pin for identical reasons. Do NOT rely on docker's default. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-6; attach.sh:39]

**SC-7 — `tty: true` + `stdin_open: true` in `docker-compose.yml` are prerequisite.** The Ctrl+P Ctrl+Q escape sequence requires the container to have an allocated PTY + stdin attached. These flags are already set in `packages/devbox/docker-compose.yml` (devbox service entry, Story 2.5 hardening). Story 2.7 does NOT modify compose — it RELIES on these flags. [Source: docker-compose.yml lines 158-159 (verified at /workspace/ralph-bmad/.claude/worktrees/ralph/packages/devbox/docker-compose.yml)]

**SC-8 — No TTY-detect gate on `docker attach` (interactive-only semantic).** Story 2.6 AI-10 (iter-214) introduced the `if [[ -t 0 ]]; then tty_flag="-it"; else tty_flag="-i"; fi` pattern for `docker exec` shims that MUST remain scriptable (CI / hooks / `ssh host pnpm devbox:<verb>`). `docker attach` is different: attach IS the operator-interactive AC (AC 1 + AC 2). There is no sensible non-TTY attach semantic — attach to a TTY-allocated container from a non-TTY caller would produce a blocked terminal with no input/output path. Story 2.7 follows `attach.sh:39`'s hardcoded approach (no TTY-flag — `docker attach` allocates its own TTY as requested by the container's `tty: true` setting). CI/scripted callers that want headless Ralph invocation are out of scope for Story 2.7 (future: `--no-tui` flag per PRD `:524-525` out-of-scope note). [Source: Story 2.6 AR-10 scope — shell.sh/attach.sh can keep hardcoded -it; interactive IS the AC; RALPH.md § Lessons TTY-detect carry-forward]

**SC-9 — Auto-start delegates to `start.sh` via sub-invocation, not re-implementation.** `ralph-build-host.sh`'s auto-start branch calls `"${SCRIPT_DIR}/start.sh"` directly (not `pnpm devbox:start`) to avoid: (a) a second pnpm invocation adding ~300ms of startup overhead; (b) a second-level shell that complicates exit-code passthrough; (c) recursion risk if pnpm scripts are overridden in `.pnpmrc` or similar. Direct sub-invocation preserves exit-code passthrough (`|| exit $?` pattern) and matches the Story 2.6 precedent of `restart.sh` calling `stop.sh` + `start.sh` directly. AC 1's "invokes `pnpm devbox:start` (from Story 2.6) internally" is satisfied — the wrapper invokes the Story 2.6 primitive; the pnpm-verb-vs-direct-script distinction is an implementation detail. [Source: restart.sh sub-invocation pattern at packages/devbox/scripts/restart.sh; Story 2.6 § Dev Notes on restart composition]

**SC-10 — `unset COMPOSE_PROJECT_NAME` at top of each ralph-*-host.sh.** Story 2.6 AI-8 (iter-212) + AI-12 (iter-217) established that every host-side script that invokes `docker` or `docker compose` MUST unset `COMPOSE_PROJECT_NAME` immediately after `set -euo pipefail` to prevent operator-shell overrides from re-routing volume/container/network paths away from the compose-file-pinned identity. Story 2.7's wrappers DO invoke `docker attach` directly (not `docker compose attach` — there is no such command) but the sub-invoked `start.sh` calls `docker compose up`. Unset at the top defensively, even if the current wrapper's own docker commands don't need it — any future refactor that adds a `docker compose ps`-based check would inherit the protection. [Source: Story 2.6 iter-212 AI-8 + iter-217 AI-12; RALPH.md § Lessons iter-212 `unset` wins over runtime-discovery]

**SC-11 — Container name derivation via `${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}`.** Story 2.2 parameterized the container name via `.envrc`; Story 2.6's scripts use the same `${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}` fallback pattern. Story 2.7 mirrors this exactly. Do NOT hardcode `keel-devbox` — multi-fork / worktree scenarios override the name via `.envrc`. [Source: Story 2.2 envrc parameterisation; Story 2.6 scripts container-name handling]

**SC-12 — Exit-code schema is inherited from Story 2.6, not extended.** Story 2.7 adds NO new exit codes — ralph-*-host.sh uses the Story 2.6 schema unchanged: `0` success, `2` usage error (unused in 2.7 — neither wrapper accepts args at 1.0), `8` docker unreachable, `9` container not running (rare post-auto-start; only if container exits between inspect + attach), `10` image not built (propagated from `start.sh`), `11` healthcheck timeout (propagated from `start.sh`), `*` docker error (propagated from `docker attach`). Any future need for a ralph-specific exit code (e.g., "in-container Ralph runtime not found" when Epic 3 lands) is a downstream amendment. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-5 uniform exit-code schema]

**SC-13 — `--help` not required at 1.0 (Story 2.6 AR-18 deferral applies).** Story 2.6 deferred per-script `--help` flag handling as AR-18. Story 2.7 inherits the deferral: ralph-*-host.sh scripts accept NO arguments and emit NO `--help` surface at 1.0. Operators discover via `pnpm run` listing + README.md § Ralph loop. If AR-18 is picked up in a future story, Story 2.7's scripts join the rollout. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Deferred AR-18]

**SC-14 — `_lib.sh` refactor deferred to dedicated story.** Story 2.6 AR-19 flagged library-extraction opportunity across 8 scripts duplicating `docker info` + `docker inspect` pre-flight boilerplate. Story 2.7 brings the total to 15 scripts under `packages/devbox/scripts/` (13 Story 2.6 + 2 Story 2.7). Dev-agent guardrail: do NOT extract `_lib.sh` as part of Story 2.7 implementation — duplicate the pre-flight boilerplate between the two new ralph-*-host.sh scripts and across from Story 2.6's scripts. The refactor is a separate future story (likely post-Story-2.10 prereq-check or post-Story-2.17 Epic 2 close-out) that consolidates ALL 15 scripts in one atomic change. Premature extraction in Story 2.7 would drift substrate without the downstream-story amortization. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Deferred AR-19]

**SC-15 — Prompt-file reading happens inside the container, not in the wrapper.** AC 5 says "`pnpm ralph:build` invokes the loop, then the harness (Epic 3) reads `.ralph/PROMPT_build.md`." The ralph-*-host.sh WRAPPER does NOT read, parse, or load `PROMPT_*.md`. Its only job is to signal the mode (KEEL_RALPH_MODE) and attach the operator terminal. The in-container Ralph runtime (Epic 3) reads the prompt file. Story 2.7 MUST NOT: (a) `cat .ralph/PROMPT_*.md` in the wrapper; (b) pass prompt-file contents via stdin to `docker attach`; (c) parse or template the prompt file host-side. [Source: epics.md:1411-1415 AC 5 scope clause]

**SC-16 — Worktree / `RALPH_BASE_DIR` contract is NOT Story 2.7's concern.** `ralph.py`'s worktree-aware halt-path resolution (`INV-ralph-halt-path-resolution`) is a Ralph-runtime contract (Epic 3). Story 2.7's wrappers do NOT invoke `ralph.py` — they `docker attach` to the container. The in-container Ralph runtime (when it exists per Epic 3) is responsible for resolving `.ralph/halt`, `.ralph/@plan.md`, etc. against the worktree path. The ralph-*-host.sh wrappers MAY optionally export `RALPH_WORKTREE` env var if the operator's shell has it set (e.g., via direnv), but at 1.0 the wrappers do NOT add worktree-handling logic. This SC closes a potential scope-creep vector. [Source: INV-ralph-halt-path-resolution; docs/invariants/ralph-execute.md § Path Resolution]

### File placement + pnpm wiring

**New files (2):**
- `packages/devbox/scripts/ralph-build-host.sh` (host-side wrapper, mode=build)
- `packages/devbox/scripts/ralph-plan-host.sh` (host-side wrapper, mode=plan)

**Modified files (3):**
- Root `package.json` — add `ralph:build` + `ralph:plan` scripts (after `devbox:env:check`, before `prepare`).
- `packages/devbox/README.md` — append `### Ralph loop (Story 2.7)` H3 (after existing `### Host-side CLI (Story 2.6)` H3).
- `AGENTS.md` — append `### Ralph loop (Story 2.7)` H3 (after existing `### Host-side CLI (Story 2.6)` H3 under § Devbox iteration environment).

**Unchanged (critical — do NOT touch):**
- `packages/devbox/docker-compose.yml` (tty + stdin_open + cap_drop/add + named volume + tmpfs — Story 2.5 substrate; the `tty: true` + `stdin_open: true` lines already enable Ctrl+P Ctrl+Q).
- `packages/devbox/Dockerfile` (ENTRYPOINT + CMD — Story 2.5 substrate).
- `packages/devbox/entrypoint.sh` (chown + egress init + exec CMD — Story 2.3 substrate).
- `packages/devbox/scripts/attach.sh` (Story 2.6; Story 2.7 does NOT call it directly but OPERATORS can still use `pnpm devbox:attach` for re-attach per AC 4; the ralph-*-host.sh is a SECOND entry point to attach, not a replacement).
- `packages/devbox/scripts/start.sh` (Story 2.6; Story 2.7 sub-invokes it but does not modify).
- `packages/devbox/tui/theme.py` (Story 1.12 artifact; consumed by Epic 3's in-container TUI).
- `ralph.py` at repo root (host-side Textual TUI; Story 2.7 does NOT touch; Epic 3 is the scope owner for ralph.py evolution including potential in-container migration).
- `packages/keel-invariants/src/invariants.manifest.ts` (no new invariant in Story 2.7 — all contracts compose on existing `INV-devbox-dind-available`, `INV-devbox-egress-contract`, `INV-devbox-homedev-named-volume`, `INV-ralph-halt-path-resolution`, `INV-ralph-halt-reason-enum`).

### Shim structure template (applies verbatim to both ralph-build-host.sh + ralph-plan-host.sh)

```bash
#!/usr/bin/env bash
#
# Story 2.7 host-side wrapper — Ralph <MODE> mode
#
# Purpose: FR2 invocation path. Auto-starts the devbox if not running, then
# attaches the operator terminal to the container's PID 1 stdio via
# `docker attach --detach-keys='ctrl-p,ctrl-q'`. The in-container Ralph
# runtime (Epic 3) consumes KEEL_RALPH_MODE to select PROMPT_<mode>.md.
#
# Ctrl+P Ctrl+Q detaches without killing the container (docker default,
# pinned explicitly via --detach-keys to guard against future
# docker-default changes; Story 2.6 attach.sh:39 precedent).
#
# Exit codes (Story 2.6 uniform schema):
#   0   clean detach.
#   8   docker runtime unreachable.
#   9   container not running (post-auto-start fallback only).
#   10  image not built (propagated from start.sh).
#   11  healthcheck timeout (propagated from start.sh).
#   *   docker attach error (propagated).

set -euo pipefail

# Story 2.6 AI-8 + AI-12: unset COMPOSE_PROJECT_NAME to pin compose identity
# to docker-compose.yml's 'name: keel-devbox'. Operator-shell override would
# redirect volume paths away from INV-devbox-homedev-named-volume.
unset COMPOSE_PROJECT_NAME

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"
RALPH_MODE="build"  # <<< PLAN variant: change to "plan"

log() { printf '[ralph:%s] %s\n' "${RALPH_MODE}" "$*" >&2; }

# Pre-flight: docker daemon reachable (exit 8 per Story 2.6 schema).
if ! docker info --format '{{.ServerVersion}}' >/dev/null 2>&1; then
  log "docker unreachable — is the daemon running?"
  exit 8
fi

# State inspect: container running? (Auto-start if not.)
status="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"

if [[ "${status}" != "running" ]]; then
  log "container '${CONTAINER_NAME}' not running; invoking start.sh (auto-start per AC 1)"
  "${SCRIPT_DIR}/start.sh" || exit $?
else
  log "container '${CONTAINER_NAME}' already running; attaching directly (AC 2 skip-start)"
fi

# Mode signal: Epic 3's in-container Ralph runtime reads KEEL_RALPH_MODE
# at startup to select .ralph/PROMPT_<mode>.md.
export KEEL_RALPH_MODE="${RALPH_MODE}"

log "attaching to ${CONTAINER_NAME} (mode: ${RALPH_MODE}; detach: Ctrl+P Ctrl+Q)"
exec docker attach --detach-keys='ctrl-p,ctrl-q' "${CONTAINER_NAME}"
```

The `plan` variant differs ONLY in `RALPH_MODE="plan"` (and the banner's MODE token). No shared-library extraction (SC-14 defers `_lib.sh` refactor).

### Mode routing (AC 5 details)

Story 2.7 ships two host-side verbs that each set `KEEL_RALPH_MODE=build|plan` before `docker attach`. Epic 3's in-container Ralph runtime (currently un-materialised; `CMD: [sleep, infinity]`) is expected to:

1. Read `KEEL_RALPH_MODE` from its startup env (compose propagates env to PID 1 when the container starts; `docker attach` itself does NOT inject env into a running process, but the compose-exec env has already seeded it).
2. Select `.ralph/PROMPT_build.md` if `KEEL_RALPH_MODE=build`, `.ralph/PROMPT_plan.md` if `KEEL_RALPH_MODE=plan`.
3. Fall back to a sensible default (e.g., `build`) if the env var is unset (e.g., direct `pnpm devbox:shell` invocation that bypasses the ralph wrappers).

For re-attach (AC 4 — `pnpm devbox:attach` or re-invoking `pnpm ralph:build`), the env var is NOT re-injected into the running process — but the in-container Ralph runtime already committed to a mode at startup, so re-attach preserves the mode implicitly. If the operator runs `pnpm ralph:plan` AFTER having started the container via `pnpm ralph:build`, the container is still running in build mode; `pnpm ralph:plan` attaches to the same process — NO mode switch happens. This is intentional: mode is a container-lifecycle attribute (one mode per container-run), not a per-attach attribute. Operators who want to switch modes: `pnpm devbox:stop && pnpm ralph:plan`. This behavior is documented in README.md § Ralph loop per Task 4.

### Story 1.12 theme.py consumption (AC 3 anchor)

`packages/devbox/tui/theme.py` exists as an autogenerated Textual theme module (Story 1.12). It exports `theme` as a `SimpleNamespace` with nested attributes: `theme.colors.*` (47 OKLCH tokens; status/severity/state semantic vocabulary), `theme.type.*` (8 font sizes), `theme.font.*` (sans/mono stacks), `theme.space.*` (13-stop scale), `theme.radius.*`, `theme.motion.*`, `theme.density.*`, `theme.breakpoint.*`, and `theme.dark.colors.*` overlay. Snake_case token identifiers (`theme.colors.status_success_fg`) per the Story 1.12 Dev Notes cross-runtime contract.

Story 2.7 does NOT consume `theme.py` directly — AC 3's "consuming `packages/devbox/tui/theme.py` from Story 1.12" is a contract clause naming the file that Epic 3's in-container Ralph runtime will import at startup. Story 2.7 ensures the attach envelope exists; the in-container Textual app (Epic 3) imports `theme` from `packages/devbox/tui/theme.py` and applies it to Textual widgets. Verification deferred to Epic 3 delivery.

### Testing Standards

**ATDD skip (FR14n matrix row 3 — seventeenth cumulative precedent).** Story 2.7 inherits Story 2.6's ATDD-skip rationale with a NEW ground variant: **"downstream-epic-owns-behavior-under-test"**. Three-ground conjunction for Story 2.7:

- **Ground (a) — Substrate-verification covers AC 1, AC 2, AC 5 at iteration-env-safe layer.** Task 6 smoke tests exercise: (a-i) auto-start branch via stub-docker returning non-running status (AC 1); (a-ii) skip-start branch via stub-docker returning running status (AC 2); (a-iii) pnpm wiring discovery via `pnpm run` listing (AC 5 half — the two verbs exist); (a-iv) mode signal via `env | grep KEEL_RALPH_MODE` under `set -x`-instrumented re-run (AC 5 half — mode routing works). These are shell-level smokes, not runtime-probe tests — but they deterministically verify the wrapper's control-flow paths.

- **Ground (b) — No test runner wired at substrate level yet.** Story 1.16 (CI pipeline) delivers the runner; until then, red-phase Vitest/Jest/Playwright scaffolds have nowhere to run. Bare "no runner" is insufficient per Story 1.8 guardrail — it MUST combine with ground (a) or (c).

- **Ground (c) — Downstream-epic-owns-behavior-under-test for AC 3 + AC 4.** AC 3's "Ralph loop continues running inside" and AC 4's "TUI state is preserved (scroll position, current iteration)" both reference behaviors of the in-container Ralph TUI process that Epic 3 delivers. Under current `CMD: [sleep, infinity]`, AC 3 reduces to "container continues running after detach" (trivially verifiable; quiescent sleep is unaffected by `docker attach`/detach) and AC 4 reduces to "no state to preserve" (trivially satisfied by the quiescent process). Full AC 3/4 verification happens at Epic 3 delivery time when the Textual TUI process materializes. Story 2.7's spec § Testing Standards affirmatively declares this delegation per the Story 1.9 "spec-declared-CR-substitution" variant + the Story 1.12 "downstream-story-covers-integration" variant; Story 2.7 combines both — "downstream-EPIC-covers-integration" is the natural generalization when the scope boundary is an epic-level carve-out (Epic 2 ships invocation path; Epic 3 ships loop mechanics).

**Trace WAIVED expected at `/bmad-testarch-trace` gate.** 5 ACs total: AC 1/2/5 covered by Task 6 iteration-env-safe smokes (3/5 = 60% automated coverage); AC 3/4 delegated to Epic 3 + operator-workstation smoke (2/5 = 40% deferred). Trace verdict: WAIVED with rationale "3 of 5 ACs substrate-smoked at shell level; 2 of 5 ACs require Epic 3's in-container Ralph TUI delivery for material verification." Following the Story 2.6 iter-202 WAIVED precedent verbatim.

**CR adversarial backstop applies.** The /bmad-code-review (args: "2") Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out exercises AC 3/4 at the design-contract layer (verifying the wrapper's scope carve-out is coherent + the attach envelope semantics are sound) even though runtime probes are Epic-3-deferred. Story 2.7 CR forecast: fewer PATCH than Story 2.6 (13 total drains) because (a) 15% the impl surface (2 scripts vs 13); (b) 90% the contracts are composition on Story 2.6 patterns that already survived 3 CR passes; (c) novel surface is narrow (mode routing + scope carve-out). Forecast: 2–4 PATCH opener + 0–1 PATCH closure re-run (well inside Story 2.1's 3-story ZERO-PATCH precedent at round 2). Dense SC pinning (16 SCs at draft time) should amortize downstream per the Story 2.6 iter-219 LESSON "dense SC pinning → clean Auditor finding through multiple CR passes."

**Live lifecycle smokes operator-workstation-deferred.** AC 3's "Ralph loop continues running inside" + AC 4's "TUI state is preserved" require: (i) Epic 3 in-container Ralph TUI materialized; (ii) M4-Pro native Docker Desktop (backend-A with full TTY + stdin_open semantics); (iii) operator-manual Ctrl+P Ctrl+Q keypress + visual verification of scroll + iteration state. cc-devbox backend-B (iteration env) cannot safely exercise `docker attach` against cap-dropped containers in ways that preserve host docker state (Story 2.5 iter-187 + Story 2.6 iter-201/204/216/219 precedent). Operator smoke + Epic 3 delivery handle AC 3/4 verification together.

### Substrate contracts preserved (do NOT modify)

Story 2.7 composes on top of the following substrate contracts. Any change to these is OUT OF SCOPE for Story 2.7 and requires a dedicated FR44 AMEND path:

- **Story 2.1 substrate** — `packages/devbox/Dockerfile`, the devbox image bake, the `/usr/local/bin/entrypoint.sh` ENTRYPOINT + `["sleep", "infinity"]` CMD.
- **Story 2.2 substrate** — `.envrc` parameterization (including `KEEL_DEVBOX_CONTAINER_NAME` that Story 2.7's wrappers read).
- **Story 2.3 substrate** — `packages/devbox/scripts/start-egress.sh` + `reload-egress.sh`, dnsmasq + nftables, `INV-devbox-egress-contract`.
- **Story 2.4 substrate** — `packages/devbox/scripts/whitelist.sh` (in-container primitive) + `whitelist.default.txt` + per-category fragments.
- **Story 2.5 substrate** — Non-root `dev` user + cap_drop/cap_add + no-new-privileges + tmpfs noexec + named volume `keel_home_dev` + `INV-devbox-homedev-named-volume`.
- **Story 2.6 substrate** — All 13 `pnpm devbox:*` verbs + their host-side shim patterns + uniform exit-code schema. Story 2.7's wrappers COMPOSE on these primitives (via sub-invocation of `start.sh`) and MIRROR the shim pattern (via `ralph-build-host.sh` + `ralph-plan-host.sh` naming). Zero modifications to Story 2.6 scripts.
- **Story 1.12 substrate** — `packages/devbox/tui/theme.py` autogenerated Textual theme (consumed by Epic 3's in-container TUI, NOT by Story 2.7's wrappers).
- **Invariant registry** — No new invariant entries in `packages/keel-invariants/src/invariants.manifest.ts`. All Story 2.7 contracts compose on existing invariants.

### Project Structure Notes

**Alignment with architecture.md scripts tree (lines 991-1004):** The architecture tree pre-Story-2.6 listed 11 scripts under `packages/devbox/scripts/`. Story 2.6 landed 13 scripts. Story 2.7 brings the total to 15 (adding `ralph-build-host.sh` + `ralph-plan-host.sh`). The architecture tree does NOT explicitly enumerate `ralph-*-host.sh` names — this is an epics-vs-architecture scope extension, not drift. Following Story 2.6 iter-201's precedent (13-script landing extending the pre-decomposition 11-script tree), Story 2.7 continues the convention at `packages/devbox/scripts/` without requiring an architecture-document amendment. A future substrate cleanup (Epic 1 retrospective or Story 2.17 close-out) may reconcile the architecture tree to enumerate all 15 scripts.

**Variance with PRD `:477` — "users attach to it via `pnpm ralph:*` but never invoke Python directly on the host":** PRD posits the end-state where the Ralph TUI runs inside the devbox, with `pnpm ralph:*` as the sole attach surface. Current ralph.py (at repo root) is HOST-SIDE. Story 2.7 does NOT migrate ralph.py into the container (that's Epic 3's scope). This variance is intentional scope-deferred and SC-2 pins the Epic-2-vs-Epic-3 boundary explicitly. Tracking: the variance closes at Epic 3 delivery when the in-container Ralph runtime materializes; at that point ralph.py either (a) moves into the container as an image-layer file, or (b) is superseded by a new in-container runtime that reads `KEEL_RALPH_MODE`. Story 2.7 keeps the current repo-root `ralph.py` undisturbed.

**No invariants.manifest.ts updates:** Story 2.7 introduces no new machine-enforced contract (unlike Story 2.3/2.4/2.5 which each added an `INV-devbox-*` entry). The scope is a composition on existing invariants (`INV-devbox-dind-available`, `INV-devbox-homedev-named-volume`, `INV-ralph-halt-path-resolution`, `INV-ralph-halt-reason-enum`). Sync-gate (Story 1.9) passes without change.

### References

- Source story AC: [Source: _bmad-output/planning-artifacts/epics.md:1384-1415]
- FR2 verbatim: [Source: _bmad-output/planning-artifacts/prd.md:928]
- FR2-adjacent CLI-tool surface contract: [Source: _bmad-output/planning-artifacts/prd.md:477-492]
- Ralph TUI-inside-devbox assumption: [Source: _bmad-output/planning-artifacts/prd.md:477; architecture.md:79]
- Ralph orchestration model + path resolution: [Source: _bmad-output/planning-artifacts/architecture.md:79-440]
- Scripts tree convention: [Source: _bmad-output/planning-artifacts/architecture.md:991-1004]
- Textual theme.py contract: [Source: _bmad-output/planning-artifacts/architecture.md:242, 693-698, 1220; _bmad-output/implementation-artifacts/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md AC 5 + Dev Notes]
- Story 2.6 uniform exit-code schema: [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-5]
- Story 2.6 `<verb>-host.sh` naming convention: [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-2, SC-15, SC-16]
- Story 2.6 FR1 non-toggle-able invariant (NEVER call docker directly): [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-1]
- Story 2.6 `unset COMPOSE_PROJECT_NAME` pattern: [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Change Log v1.x AI-8 + AI-12]
- Story 2.6 `attach.sh` detach-keys pinning: [Source: packages/devbox/scripts/attach.sh:39]
- Story 2.6 TTY-detect gate (NOT applied to attach — AR-10): [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Review Findings AI-10 + AR-10]
- Story 2.6 `_lib.sh` refactor deferral: [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Review Findings AR-19]
- Story 2.6 `--help` rollout deferral: [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Review Findings AR-18]
- docker-compose.yml tty + stdin_open + named volume: [Source: packages/devbox/docker-compose.yml lines 46-172]
- Dockerfile ENTRYPOINT + CMD: [Source: packages/devbox/Dockerfile lines 287-295]
- entrypoint.sh PID 1 startup sequence: [Source: packages/devbox/entrypoint.sh lines 1-141]
- UX design-spec TUI detach expectations: [Source: _bmad-output/planning-artifacts/ux-design-specification.md:93, 102, 227, 568, 699-710, 843]
- INV-ralph-halt-path-resolution (NOT Story 2.7's concern — Epic 3): [Source: INVARIANTS.md line 46; docs/invariants/ralph-execute.md § Path Resolution]
- INV-ralph-halt-reason-enum (NOT Story 2.7's concern — Ralph runtime): [Source: INVARIANTS.md line 47; docs/invariants/ralph-execute.md § Halt schema]
- INV-devbox-dind-available (Story 2.7 prereq): [Source: INVARIANTS.md line 94; docs/invariants/devbox-dind.md]
- INV-devbox-egress-contract (Story 2.7 unchanged): [Source: INVARIANTS.md line 100; docs/invariants/devbox-egress.md]
- INV-devbox-homedev-named-volume (Story 2.7 unchanged): [Source: INVARIANTS.md line 106; docs/invariants/devbox-hardening.md]

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

## Change Log

- v1.0 (2026-04-22) — Initial draft. 5 ACs + 7 tasks + 16 SCs. Scope carve-out pinned at SC-2 (Epic 2 ships invocation path; in-container Ralph TUI + prompt-file semantics are Epic 3). File placement under `packages/devbox/scripts/` per SC-3 (co-located with Story 2.6 scripts; no new `packages/ralph/`). Mode routing via `KEEL_RALPH_MODE` env var per SC-5. `_lib.sh` refactor explicitly deferred per SC-14 (carries AR-19 from Story 2.6). ATDD skip + trace WAIVED forecast per FR14n matrix row 3 — seventeenth cumulative precedent; new ground-(c) variant "downstream-epic-owns-behavior-under-test" extending Story 1.9's spec-declared-CR-substitution + Story 1.12's downstream-story-covers-integration. CR forecast: 2–4 PATCH opener + 0–1 closure re-run (narrow novel surface; 90% composition on Story 2.6 patterns).
