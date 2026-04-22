# Story 2.8: Claude Code OAuth via `pnpm claude`

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want `pnpm claude` to trigger the Claude Code browser OAuth flow surfaced to my host terminal, with tokens persisted in the named Docker volume at `/home/dev/.claude/`,
So that I authenticate once per devbox and the token survives container restarts (FR3 Claude side).

## Acceptance Criteria

1. **OAuth flow surfaced to host terminal.** Given a fresh devbox, when I run `pnpm claude`, then the command invokes `claude` inside the container and the OAuth URL is surfaced to my host terminal and following the URL in a host browser completes the flow.

2. **Token persisted in named volume.** Given the flow completes, when tokens are stored, then they persist at `/home/dev/.claude/` inside the named volume from Story 2.5 and the token file is never bind-mounted to the host filesystem.

3. **Token survives restart.** Given a subsequent `pnpm devbox:restart` or `pnpm devbox:stop && start`, when I run any Claude Code invocation, then the existing token is reused (no re-auth required).

4. **Re-auth on expiry is self-serve.** Given the token is expired or revoked, when Ralph or a manual `claude` invocation runs, then the failure surfaces a clear re-auth pointer and `pnpm claude` can be re-run to refresh the token without affecting other devbox state.

5. **Volume-delete clears token (NFR10 fresh-fork behaviour).** Given a `pnpm devbox:clean` with volume-deletion confirmed, when I next run the devbox, then tokens are gone and `pnpm claude` must be re-run (expected per NFR10 / fresh-fork behaviour).

## Tasks / Subtasks

- [ ] **Task 1: Author `packages/devbox/scripts/claude-host.sh`** (AC 1, AC 4)
  - [ ] Shebang `#!/usr/bin/env bash` + banner header (purpose = FR3 Claude-side invocation path; dual-ref Story 2.8 AC 1–5 + Story 2.6 `<verb>-host.sh` pattern + Story 2.7 `ralph-build-host.sh` interactive-exec precedent; exit-code contract).
  - [ ] `set -euo pipefail`.
  - [ ] `unset COMPOSE_PROJECT_NAME` — Story 2.6 AI-8/AI-12 + Story 2.7 SC-10 defensive-posture precedent. Protects `keel-devbox_keel_home_dev` named-volume identity under operator-shell overrides (INV-devbox-homedev-named-volume).
  - [ ] `CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"`. **Do NOT set `SCRIPT_DIR`** — SC-4 pins no-auto-start, so there is no `"${SCRIPT_DIR}/start.sh"` sub-invoke (contrast Story 2.7's ralph-build-host.sh:29+46 which DOES use SCRIPT_DIR for the sub-invoke). Unused variables in the shim invite cargo-culting at future amendment time.
  - [ ] Pre-flight 1 — docker daemon reachable: `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log "docker unreachable — is the daemon running?"; exit 8; }`.
  - [ ] Pre-flight 2 — container state inspect: `state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"`. If `state != "running"` → log `"container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"` and exit 9 (NO auto-start per SC-4; follow shell.sh + attach.sh precedent).
  - [ ] `log "invoking claude inside ${CONTAINER_NAME} (first run: complete OAuth in host browser; token persists at /home/dev/.claude/)"`.
  - [ ] `exec docker exec -it --user dev -w /workspace "${CONTAINER_NAME}" claude "$@"` (interactive-only; no TTY-detect gate per SC-6 — interactive IS the AC, following Story 2.7 SC-8 for attach.sh + shell.sh interactive-by-contract verbs; args-passthrough via `"$@"` per SC-9 for `pnpm claude --version` / `pnpm claude -p "…"` composition).
  - [ ] Exit-code schema: `0` clean exit or operator-cancelled OAuth (claude exit 0), `2` usage error (unused at 1.0 — wrapper accepts any claude args without its own validation), `8` docker unreachable, `9` container not running (exit before ever touching claude), `*` claude/exec error propagated unchanged (exit 1 from claude + any docker exec networking error).
  - [ ] `chmod +x` at creation.

- [ ] **Task 2: Root `package.json` pnpm wiring** (AC 1 — operator-surface discoverability)
  - [ ] Add one entry to `scripts`: `"claude": "./packages/devbox/scripts/claude-host.sh"`.
  - [ ] Insertion point — AFTER the `"ralph:plan"` entry (line 36 at Story 2.7 landing) and BEFORE `"prepare"` (Story 2.7 precedent: ralph block ordering; claude is the logical next auth-class group preceding the Story 2.9 `gh:auth` verb in the next story).
  - [ ] Verb form deliberate: **top-level `claude` (no colon), not `claude:auth` or `devbox:claude`** — per architecture.md:489 verbatim CLI-tool-surface table row + epics.md:1426 AC 1 language verbatim. The no-colon form signals a first-class operator-authentication verb, not a devbox-lifecycle sub-verb. Story 2.9's `gh:auth` variance (uses colon) is epics.md-pinned separately — do NOT try to homogenize.
  - [ ] Smoke: `pnpm run 2>&1 | grep -E '^ +claude$'` → 1 match (pnpm wiring verified; regex ensures match is the verb alone, not `claude:*` subverbs that don't exist at 1.0).

- [ ] **Task 3: Operator documentation in `packages/devbox/README.md`** (AC 1, AC 2, AC 3, AC 4, AC 5 — operator comprehension)
  - [ ] Append a new H2 `## Claude Code authentication (Story 2.8)` section AFTER the existing `## Ralph loop (Story 2.7)` H2 (sibling placement at the same outline level — verified iter-223 landed `## Ralph loop` at `packages/devbox/README.md:505`; the new section appends AFTER it and BEFORE `## cc-devbox upstream provenance`). NOT a nested H3 under Story 2.7's section.
  - [ ] **DO NOT modify the existing `## Host-side CLI (Story 2.6)` or `## Ralph loop (Story 2.7)` sections** — append a NEW sibling section only. Rewriting prior stories' sections is scope-creep (SC-17).
  - [ ] Content: (a) quick-start `pnpm claude` command; (b) first-run OAuth flow — "follow the URL printed to your terminal in a host browser; paste the code back if prompted; token saves to `/home/dev/.claude/` inside the `keel_home_dev` named volume" (AC 1 + AC 2); (c) persistence contract — "token survives `pnpm devbox:restart` / `pnpm devbox:stop && start`; re-running `pnpm claude` on an authed devbox is a no-op (claude detects existing token)" (AC 3); (d) re-auth path — "if claude reports 'not authenticated' or Ralph's pre-push gate surfaces an auth failure, re-run `pnpm claude` — OAuth re-triggers in the same flow" (AC 4); (e) volume-delete reset — "`pnpm devbox:clean --with-volumes` wipes `/home/dev/.claude/` along with `keel_home_dev`; expected per NFR10 fresh-fork behaviour; re-run `pnpm claude` to re-seed" (AC 5); (f) pre-flight expectation — "run `pnpm devbox:start` first; `pnpm claude` fails-closed with exit 9 if the container is not running (no auto-start — auth is a one-off; contrast `pnpm ralph:build` which auto-starts per Story 2.7)"; (g) exit-code reference — `0` / `8` / `9` / `*` (SC-5 schema); (h) a one-line cross-ref to `AGENTS.md § Claude Code authentication` for agent-facing guidance.
  - [ ] Tone: mirror Story 2.6's `## Host-side CLI` + Story 2.7's `## Ralph loop` section voices; terse, operator-grade, command-first.

- [ ] **Task 4: Agent documentation in `AGENTS.md`** (AC 1, AC 3, AC 4 — agent operational contract)
  - [ ] Append new H3 `### Claude Code authentication (Story 2.8)` section AFTER the existing `### Ralph loop (Story 2.7)` H3 under § Devbox iteration environment (verified iter-223 landed H3 at `AGENTS.md:114`; the new section appends AFTER it).
  - [ ] **DO NOT modify the existing `### Host-side CLI (Story 2.6)` or `### Ralph loop (Story 2.7)` sections** — append a NEW sibling H3 only (SC-17).
  - [ ] Content: (a) wrapper-pattern pointer — `claude-host.sh` as the canonical shim; NEVER invoke `docker exec … claude` directly from agent contexts (FR1 non-toggle-able invariant extension from Story 2.6's 13-verb + Story 2.7's 2-verb surface → 16-verb surface total at Story 2.8 landing); (b) token-persistence contract — `/home/dev/.claude/` lives in `keel_home_dev` named volume (Story 2.5 substrate; NFR10); agents MUST NOT attempt to bind-mount, copy, or otherwise surface token files outside the named volume; (c) re-auth pointer — if Ralph's `gh push`-adjacent tooling reports a Claude Code auth failure, queue `pnpm claude` as a fix task (operator-interactive); agents SHOULD NOT attempt automated re-auth; (d) scope carve-out — Story 2.8 ships the host-side invocation envelope only; upstream Claude Code CLI (bundled at Dockerfile:119, pinned `@anthropic-ai/claude-code@2.1.116`) owns the OAuth flow + token file format.
  - [ ] Tone: mirror Story 2.6's + Story 2.7's AGENTS.md contributions — operational-truth + terse cross-refs, no narration of implementation.

- [ ] **Task 5: Iteration-env-safe smoke tests** (AC 1 verification within backend-B constraints)
  - [ ] Smoke 1 — `bash -n packages/devbox/scripts/claude-host.sh` (syntax parse under bash 5.x).
  - [ ] Smoke 2 — `pnpm run 2>&1 | grep -E '^ +claude$'` → 1 match (pnpm wiring verified; no accidental namespace pollution).
  - [ ] Smoke 3 — stub-docker harness (workspace-based per Story 2.7 iter-223 LESSON — place stub `docker` under `<workspace>/.ralph-smoke/shim/` NOT `/tmp/` because tmpfs noexec). Reuse Story 2.7 harness-setup pattern verbatim; adapt `STUB_DOCKER_MODE` scenarios:
    - **3a** — `STUB_DOCKER_MODE=info-fail` → `docker info` returns non-zero → `claude-host.sh` exits 8 + logs `[claude] docker unreachable — is the daemon running?`.
    - **3b** — `STUB_DOCKER_MODE=not-running` → `docker info` OK + `docker inspect` returns `stopped` → exits 9 + logs `container 'keel-devbox' is not running — run 'pnpm devbox:start' first`.
    - **3c** — `STUB_DOCKER_MODE=running` → `docker info` OK + `docker inspect` returns `running` → final exec line is `docker exec -it --user dev -w /workspace keel-devbox claude` + exit 0 (stub claude returns 0).
    - **3d** — args-passthrough: `STUB_DOCKER_MODE=running` invoked as `claude-host.sh --version` → stub-docker captures `exec -it --user dev -w /workspace keel-devbox claude --version` (the `--version` arg reaches claude verbatim).
  - [ ] Smoke 4 — no-TTY-gate verification: confirm the `exec docker exec -it` line has NO conditional TTY flag (`[[ -t 0 ]]` branch absent per SC-6; attach-class interactive verbs do NOT adopt Story 2.6 AR-10 TTY-detect pattern). `grep -c 'tty_flag\|-t 0' packages/devbox/scripts/claude-host.sh` → 0 matches.
  - [ ] Clean up `.ralph-smoke/` on close via explicit `rm -rf .ralph-smoke/` in final assertion call — NOT via `trap ... EXIT` in setup (Story 2.7 iter-223 LESSON: each Bash tool call is a separate shell process; EXIT-trap-at-setup does NOT survive cross-call). Applies to every multi-call stub-harness smoke.
  - [ ] **Deferred to operator workstation:** Live Claude Code OAuth flow (URL surface + host-browser paste + actual token write under `/home/dev/.claude/`) requires: (i) live `@anthropic-ai/claude-code@2.1.116` reaching Anthropic's OAuth endpoint (egress whitelist covers `api.anthropic.com` + `console.anthropic.com` per Story 2.3/2.4 substrate); (ii) host browser for URL completion; (iii) M4-Pro native Docker Desktop for TTY + stdin_open reliability under `docker exec -it`. cc-devbox backend-B (iteration env) cannot safely exercise interactive OAuth against Anthropic without polluting operator credentials. Full AC 1/2/3/4/5 live-flow verification deferred to M4-Pro operator workstation per Story 2.4 SC-17 + Story 2.5 iter-187 + Story 2.6 iter-201/204/216/219 + Story 2.7 iter-223 precedent cluster.

- [ ] **Task 6: Change Log + sprint-status housekeeping** (lifecycle bookkeeping)
  - [ ] Story file § Change Log — v1.0 "Initial draft; dev-ready" entry.
  - [ ] Sprint-status update is handled by the `/bmad-create-story` workflow's step 6 automation (not a dev-story task). Downstream: dev-story workflow Step 4 flips `ready-for-dev → in-progress` at implementation start; Step 9 flips `in-progress → review` at implementation close.
  - [ ] Dev-story iteration upkeep: when this story lands, update `RALPH.md § Lessons` with the Story 2.8 host-shim pattern if any new lessons surface (OAuth-adjacent patterns, args-passthrough behaviours, stub-harness extensions) + `AGENTS.md § Claude Code authentication` cross-refs. NO new RALPH.md lesson is expected at draft time — the full pattern stack (shim template, exit codes, SC-17 read-only, ATDD skip, trace WAIVED, CR ZERO-PATCH forecast) is inherited from Story 2.6 + 2.7 verbatim.

## Dev Notes

### Scope clarifications (SC-1..SC-17)

**SC-1 — Story 2.6 + 2.7 host-side CLI is the composable substrate.** Story 2.8 composes on Story 2.6's 13-verb host-side surface + Story 2.7's 2-verb ralph auto-start pair, extending the canonical `pnpm <verb>` entry-point contract by one more verb. `claude-host.sh` reuses Story 2.6's shell.sh + attach.sh docker-exec/attach interactive pattern (not Story 2.7's docker-attach-with-auto-start pattern — auto-start is NOT appropriate for one-off auth, per SC-4). The wrapper does NOT re-implement docker-daemon-detection or container-state-check — it duplicates **Story 2.7's ralph-wrappers** pre-flight boilerplate verbatim (Story 2.7 iter-223 tightened Story 2.6's bare `docker info >/dev/null 2>&1` to `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1`, catching reachable-but-broken-daemon states where ServerVersion is missing from server info output; Story 2.8 inherits the tighter variant per Story 2.7 ralph-build-host.sh:36). Boilerplate duplication is per Story 2.6 AR-19 + Story 2.7 SC-14 `_lib.sh` deferral. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-1..SC-17; 2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md § Dev Notes SC-1; packages/devbox/scripts/ralph-build-host.sh:36]

**SC-2 — Upstream Claude Code CLI (Anthropic-owned) owns the OAuth flow semantics.** AC 1's "OAuth URL surfaced" + AC 4's "re-auth pointer on expiry" describe behaviors of the `@anthropic-ai/claude-code@2.1.116` binary baked at Dockerfile:119. Story 2.8 ships the host-side invocation envelope: `docker exec -it --user dev -w /workspace keel-devbox claude`. The envelope connects operator stdin/stdout/stderr to claude's stdin/stdout/stderr; claude's OAuth device-code flow prints the URL to stdout (operator reads), opens URL in host browser, operator completes OAuth, returns control to claude — claude writes the token file under `/home/dev/.claude/`. Story 2.8 MUST NOT: (a) re-implement or shell-out around claude's auth subcommand; (b) parse claude's stdout for URL-extraction; (c) intercept or rewrite the token file. The wrapper is a pass-through. If the upstream CLI's auth flow changes (e.g., Anthropic moves from device-code to PKCE with local callback server), the wrapper does not need to change — the container's port-publication contract (compose lines 109-113: 127.0.0.1:3000 + 3001 + 6006 + 24679) does not include an OAuth-callback port because device-code flow does not need one at 1.0. [Source: packages/devbox/Dockerfile:111-120 claude-code install; architecture.md:506 "First `pnpm claude` invocation per devbox triggers OAuth; the URL is surfaced to the host; user completes OAuth in host browser; session persists in the container volume"]

**SC-3 — File placement under `packages/devbox/scripts/` (not `packages/ralph/` or a new `packages/auth/`).** Options considered: (a) `packages/devbox/scripts/claude-host.sh` co-located with 15 other host-side shims; (b) new `packages/auth/scripts/` for auth-class verbs (anticipating Story 2.9 `gh:auth` as a sibling); (c) new top-level `auth/claude.sh`. Choose (a) — co-locate with existing Story 2.6 + 2.7 shims — because: (i) the script IS a docker-exec orchestration operation at heart (pre-flight docker check, container-state inspect, exec into container); (ii) co-location preserves the `ls packages/devbox/scripts/` discovery path (15 host-side shims at Story 2.7 landing [13 Story 2.6 + 2 Story 2.7] → 16 after Story 2.8 lands; matches SC-14 accounting); (iii) avoids creating a new `packages/` entry for 1 file (YAGNI); (iv) Story 2.9's `gh:auth` wrapper will follow the same placement → `packages/devbox/scripts/gh-auth-host.sh`, NOT `packages/auth/`. A future auth-package refactor (post-Epic 2, post-Story-2.17 close-out) MAY pivot, but deferred by YAGNI at 1.0. [Source: Story 2.6 iter-201 placement precedent; Story 2.7 SC-3; packages/devbox/scripts/ directory listing at 2026-04-22]

**SC-4 — No auto-start; fail-closed exit 9 if container is not running.** Story 2.7's `ralph-build-host.sh` + `ralph-plan-host.sh` added auto-start (SC-1) because the ralph verb is a "loop start" gesture — operators expect the loop-entry wrapper to bring up its execution environment. Story 2.8's `pnpm claude` is NOT a loop-entry gesture — it is a one-off operator-authentication verb, run at most a handful of times in a devbox's lifetime. Auto-start would: (a) mask operator intent ("I want to authenticate" ≠ "I want to boot a new devbox"); (b) add a ~30-60s first-invocation delay that surprises operators; (c) break the shell.sh + attach.sh exit-9 precedent that operators are familiar with. Story 2.8 follows the `docker exec`-based verb precedent (shell.sh:32-35 + attach.sh:32-36) of fail-closed exit 9 with the pointer message `run 'pnpm devbox:start' first`. If a future story introduces a Growth-tier auto-start-for-auth flag, it is a downstream amendment; at 1.0, the posture is fail-closed. [Source: packages/devbox/scripts/shell.sh:32-35; packages/devbox/scripts/attach.sh:32-36; Story 2.7 SC-1 contrast — ralph auto-start is the OPPOSITE posture and that is deliberate]

**SC-5 — Exit-code schema is inherited from Story 2.6, not extended.** Story 2.8 adds NO new exit codes — claude-host.sh uses the Story 2.6 schema unchanged: `0` success, `2` usage error (unused at 1.0 — wrapper accepts any claude args without its own validation), `8` docker unreachable, `9` container not running, `*` docker-exec or claude error propagated. Notably, the ralph-wrapper-only codes `10` (image not built) + `11` (healthcheck timeout) are NOT applicable to Story 2.8 — those emerge only from a sub-invoked `start.sh`, which claude-host.sh does NOT sub-invoke (per SC-4 no-auto-start). Any future need for a claude-specific exit code (e.g., "token write failed" when an expanded wrapper inspects post-exec state) is a downstream amendment; at 1.0, the envelope is a thin pass-through with the same schema as shell.sh. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-5 uniform exit-code schema; 2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md § Dev Notes SC-12]

**SC-6 — No TTY-detect gate on `docker exec`; interactive-only semantic.** Story 2.6 AI-10 (iter-214) introduced the `if [[ -t 0 ]]; then tty_flag="-it"; else tty_flag="-i"; fi` pattern for `docker exec` shims that MUST remain scriptable (CI / hooks / `ssh host pnpm devbox:<verb>`). `pnpm claude` is different: the OAuth flow is intrinsically operator-interactive (URL must surface to a real terminal; operator must open URL in a host browser; claude may prompt for a pasted code depending on the Anthropic flow variant at time-of-use). There is no sensible non-TTY claude-first-auth semantic — a non-TTY `pnpm claude` invocation would at best hang waiting for input that cannot arrive, at worst silently fail. Story 2.8 follows the shell.sh:42 + attach.sh:39 interactive-by-contract precedent (hardcoded `-it`; no TTY-flag branching). CI/scripted callers that want headless Claude Code (e.g., Ralph's autonomous `claude -p "…"` subprocess invocations) reach claude via `ralph.py` or `docker exec`-adjacent runtime paths, NOT via `pnpm claude` — Story 2.8's scope is the one-off OAuth seeding, not the loop-time invocation. [Source: packages/devbox/scripts/shell.sh:42 (hardcoded `-it` for interactive-login-shell); packages/devbox/scripts/attach.sh:39 (hardcoded `attach`); Story 2.7 SC-8 "attach IS the AC" parallel]

**SC-7 — `tty: true` + `stdin_open: true` in `docker-compose.yml` are prerequisite.** The interactive OAuth flow requires the container to have an allocated PTY + stdin attached. These flags are already set in `packages/devbox/docker-compose.yml:158-159` (devbox service entry, Story 2.5 hardening). Story 2.8 does NOT modify compose — it RELIES on these flags. Under `docker exec -it`, docker allocates a NEW PTY for the exec session (independent from PID 1's), so the compose flags primarily affect PID 1's behaviour not the exec session — but the compose flags remain pinned for Story 2.7 + 2.8 + Story 2.9 attach/exec class semantics. [Source: packages/devbox/docker-compose.yml:158-159; Story 2.7 SC-7]

**SC-8 — `unset COMPOSE_PROJECT_NAME` at top of the script.** Story 2.6 AI-8 (iter-212) + AI-12 (iter-217) established that every host-side script that invokes `docker` MUST unset `COMPOSE_PROJECT_NAME` immediately after `set -euo pipefail`. Story 2.8's wrapper DOES invoke `docker` (info + inspect + exec). Even though the wrapper does NOT call `docker compose`, the defensive `unset` protects against any future refactor that adds a `docker compose ps`-based check. Cost is 1 line; benefit is uniform substrate posture. [Source: Story 2.6 iter-212 AI-8 + iter-217 AI-12; Story 2.7 SC-10]

**SC-9 — Args passthrough to `claude` via `"$@"`.** `pnpm claude` with no args is the default OAuth-seeding gesture. But operators should also be able to compose: `pnpm claude --version` (smoke test), `pnpm claude -p "hello"` (one-shot prompt with an already-seeded token), `pnpm claude auth logout` (explicit logout if claude CLI supports it at a given version). The wrapper passes `"$@"` to `docker exec … claude "$@"` so pnpm-operator composition works end-to-end. Contrast Story 2.7 `ralph-build-host.sh` which does NOT pass args (the wrapper accepts NO operator args — mode is baked into the wrapper name). [Source: shell.sh:39 precedent — `exec docker exec -i --user dev -w /workspace "${CONTAINER_NAME}" bash -l "$@"`; Story 2.6 AC 5 `pnpm devbox:shell -c 'whoami'` composability]

**SC-10 — No signal trapping on claude-host.sh.** `docker exec` natively forwards SIGINT/SIGTERM/SIGPIPE to the exec target (claude's PID inside the container). Defensive trap handlers in the wrapper would BREAK passthrough — e.g., a `trap '...' INT` would consume Ctrl-C at the wrapper layer instead of forwarding it to claude, which may be waiting on stdin during the OAuth code-paste prompt. Story 2.1 iter-144 SIGPIPE precedent + Story 2.7 PATCH 3 "no-signal-trap" comment carry forward. The shim template codifies this with a `# No signal trapping — docker exec forwards signals to claude PID 1 of the exec.` comment before the `exec` line. [Source: Story 2.1 iter-144; Story 2.7 v1.1 PATCH 3]

**SC-11 — Container name derivation via `${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}`.** Story 2.2 parameterised the container name via `.envrc`; Story 2.6's scripts use the same `${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}` fallback pattern. Story 2.7's wrappers inherited this. Story 2.8 mirrors exactly. Do NOT hardcode `keel-devbox` — multi-fork / worktree scenarios override the name via `.envrc`. [Source: Story 2.2 envrc parameterisation; Story 2.6 scripts container-name handling; Story 2.7 SC-11]

**SC-12 — No `docker-compose.yml` edits in Story 2.8.** The compose file at line 156 carries a `TODO(Story 2.8 / 2.9): named-volume mounts for OAuth tokens.` comment. This TODO is **stale** — Story 2.5 already landed the `keel_home_dev` named volume at `/home/dev` (compose lines 90-92 + `volumes:` top-level at lines 170-171), which subsumes `/home/dev/.claude/` AND `/home/dev/.config/gh/` persistence under a single mount. Story 2.8 does NOT need to add a second named-volume mount nested at `/home/dev/.claude/` — that would actually break the Story 2.5 contract (nested named volumes under a parent named volume have surprising semantics). The TODO comment's removal is a separate substrate tidy that is DEFER'd to Story 2.17 Epic 2 close-out or a standalone polish pass; **no tracking entry in `_bmad-output/implementation-artifacts/deferred-work.md` is required** — the compose:156 comment is self-documenting and Story 2.8's "do nothing" posture creates no deferred artifact to track (deferred-work.md scope is CR-surfaced findings, per its § header at line 3). Story 2.8's wrapper relies on the Story 2.5 substrate exactly as-is. [Source: packages/devbox/docker-compose.yml:86-92 + 170-171 named-volume substrate; Story 2.5 § Dev Notes named-volume contract; Story 2.7 § File placement § Unchanged list pattern; deferred-work.md § header line 3 scope]

**SC-13 — Dockerfile placeholder directory `/home/dev/.claude/` is load-bearing.** Dockerfile:251-252 pre-creates `/home/dev/.claude/` with `chmod 0755` + chowns to `dev:dev` (via the blanket `chown -R dev:dev /home/dev` at Dockerfile:270). Under Story 2.5's named-volume auto-init semantics (docker populates an empty volume from the image layer), this pre-creation ensures `/home/dev/.claude/` exists + is writable by UID 1000 on first boot without requiring entrypoint.sh runtime chown. claude-host.sh MUST NOT `mkdir` or `chmod` `/home/dev/.claude/` in the wrapper — the Dockerfile owns that lifecycle, and runtime chown under `cap_drop: [ALL]` (which strips CAP_CHOWN) would fail silently anyway. [Source: packages/devbox/Dockerfile:251-252 placeholder create; Dockerfile:268-270 dev-user + blanket chown; Story 2.5 § Dev Notes "runtime chown best-effort" at AGENTS.md:100]

**SC-14 — `_lib.sh` refactor deferred to dedicated story.** Story 2.6 AR-19 flagged library-extraction opportunity across 8 scripts duplicating `docker info` + `docker inspect` pre-flight boilerplate; Story 2.7 SC-14 deferred it again as the count grew to 15 host-side shims (13 Story 2.6 + 2 Story 2.7). Story 2.8 adds 1 more shim → 16 total. Dev-agent guardrail: do NOT extract `_lib.sh` as part of Story 2.8 implementation — duplicate the pre-flight boilerplate from Story 2.6's shell.sh + attach.sh verbatim. Premature extraction in Story 2.8 would drift substrate without the downstream-story amortization (Stories 2.9 + 2.10 + 2.13 add more shims; the `_lib.sh` lift happens in a single post-Story-2.17 atomic refactor). [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Deferred AR-19; 2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md SC-14]

**SC-15 — No token-file inspection or manipulation in the wrapper.** Post-exec the token file at `/home/dev/.claude/<file>` is claude's property — its path, format, permissions, and rotation semantics are upstream Anthropic contract. Story 2.8's wrapper MUST NOT: (a) `ls /home/dev/.claude/` post-exec to "verify" token write; (b) `cat` or parse the token file; (c) attempt backup/copy of the token file. AC 2's "tokens persist at `/home/dev/.claude/`" is verified by the Story 2.5 named-volume substrate + Docker's volume persistence semantics, NOT by the wrapper. If the upstream CLI changes the token filename or moves it under `/home/dev/.config/claude/` or similar, the wrapper does NOT need to change — the named-volume mount covers `/home/dev/*` wildcard. [Source: architecture.md:506; Story 2.7 SC-15 parallel "no PROMPT file read"]

**SC-16 — `--help` not required at 1.0 (Story 2.6 AR-18 deferral applies).** Story 2.6 deferred per-script `--help` flag handling as AR-18. Story 2.7 inherited the deferral (SC-13). Story 2.8 inherits it too: claude-host.sh does NOT intercept `--help` — any `pnpm claude --help` invocation passes through to `claude --help` via SC-9 args-passthrough, which is the right semantic (claude CLI's own help is more authoritative than a wrapper's help). If AR-18 is picked up in a future substrate cleanup story, Story 2.8's script joins the rollout. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Deferred AR-18; Story 2.7 SC-13]

**SC-17 — Task 3 + Task 4 append NEW sibling sections; do NOT modify existing Story 2.6 or Story 2.7 sections.** `packages/devbox/README.md` hosts `## Host-side CLI (Story 2.6)` (H2) at line 410 + `## Ralph loop (Story 2.7)` (H2) at line 505; `AGENTS.md` hosts `### Host-side CLI (Story 2.6)` (H3) at line 104 + `### Ralph loop (Story 2.7)` (H3) at line 114 under § Devbox iteration environment. Story 2.8 appends a new `## Claude Code authentication (Story 2.8)` (H2 sibling in README) and a new `### Claude Code authentication (Story 2.8)` (H3 sibling in AGENTS.md). **The existing Story 2.6 + 2.7 sections are READ-ONLY for Story 2.8** — dev-agent MUST NOT rewrite, reorder, merge, or re-number them. Any observed drift in the Story 2.6 + 2.7 sections is an FR44 AMEND path, not a Story 2.8 change. This SC closes the scope-creep vector surfaced at Story 2.7 PATCH 4 + carried forward. [Source: packages/devbox/README.md:410 + 505; AGENTS.md:104 + 114; Story 2.7 SC-17]

### File placement + pnpm wiring

**New files (1):**
- `packages/devbox/scripts/claude-host.sh` (host-side wrapper, top-level `pnpm claude` verb).

**Modified files (3):**
- Root `package.json` — add `claude` script (after `ralph:plan`, before `prepare`).
- `packages/devbox/README.md` — append `## Claude Code authentication (Story 2.8)` H2 sibling (after existing `## Ralph loop (Story 2.7)` H2 at line 505).
- `AGENTS.md` — append `### Claude Code authentication (Story 2.8)` H3 sibling (after existing `### Ralph loop (Story 2.7)` H3 at line 114, under § Devbox iteration environment).

**Unchanged (critical — do NOT touch):**
- `packages/devbox/docker-compose.yml` (tty + stdin_open + cap_drop/add + named volume + tmpfs — Story 2.5 substrate; the `/home/dev` named-volume mount at lines 90-92 + top-level `keel_home_dev` at lines 170-171 already subsume `/home/dev/.claude/` persistence; SC-12 pins NO compose edits in Story 2.8; the stale `TODO(Story 2.8 / 2.9)` comment at line 156 is deferred to a separate tidy).
- `packages/devbox/Dockerfile` (ENTRYPOINT + CMD + dev-user + `/home/dev/.claude/` placeholder + `@anthropic-ai/claude-code@2.1.116` install — Story 2.5 + Story 2.1 substrate).
- `packages/devbox/entrypoint.sh` (chown + egress init + exec CMD — Story 2.3 substrate).
- `packages/devbox/scripts/shell.sh`, `packages/devbox/scripts/attach.sh` (Story 2.6; Story 2.8 MIRRORS their patterns but does NOT modify them).
- `packages/devbox/scripts/start.sh`, `packages/devbox/scripts/ralph-build-host.sh`, `packages/devbox/scripts/ralph-plan-host.sh` (Story 2.6 + 2.7; Story 2.8 does NOT sub-invoke them — SC-4 no-auto-start — and does NOT modify them).
- `packages/devbox/tui/theme.py` (Story 1.12 artifact; not relevant to Story 2.8).
- `ralph.py` at repo root (host-side Textual TUI; Story 2.8 does NOT touch; Ralph's own `claude -p` invocations reach claude via ralph.py's subprocess path, NOT via `pnpm claude` — operator-seeding vs loop-time are separate paths).
- `packages/keel-invariants/src/invariants.manifest.ts` (no new invariant in Story 2.8 — all contracts compose on existing `INV-devbox-dind-available`, `INV-devbox-homedev-named-volume`, `INV-devbox-egress-contract`).

### Shim structure template (applies verbatim to claude-host.sh)

```bash
#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/claude-host.sh — Story 2.8
#
# FR3 Claude-side invocation path. Runs `claude` inside the running devbox
# container as UID 1000 (`dev` user) with the operator terminal attached
# interactively. First invocation triggers the Claude Code OAuth flow: the
# URL surfaces on stdout, operator opens URL in a host browser, optionally
# pastes a code, token persists at /home/dev/.claude/ inside the
# `keel_home_dev` named volume (Story 2.5 substrate; NFR10).
#
# Subsequent invocations (token already present) are no-ops at the auth
# layer — claude detects existing token and proceeds to its default
# interactive session (or to args-passed behaviour, e.g. `pnpm claude
# --version`, `pnpm claude -p "hello"`).
#
# Exit codes (Story 2.6 uniform schema):
#   0   clean exit (auth complete, or claude's own clean exit).
#   2   usage error (unused at 1.0 — wrapper delegates arg validation to claude).
#   8   docker runtime unreachable.
#   9   container not running — run `pnpm devbox:start` first (no auto-start
#       per SC-4; auth is a one-off, not a loop-entry gesture).
#   *   claude or docker exec error (propagated).
# ---------------------------------------------------------------------------
set -euo pipefail

# Story 2.6 AI-8 + AI-12 + Story 2.7 SC-10: unset COMPOSE_PROJECT_NAME
# defensively to pin compose identity to docker-compose.yml's `name:
# keel-devbox`. Operator-shell override would redirect volume paths away
# from INV-devbox-homedev-named-volume.
unset COMPOSE_PROJECT_NAME

# SC-4 no-auto-start → no sub-invoke of start.sh → no need for SCRIPT_DIR
# (contrast Story 2.7 ralph-build-host.sh:29+46 which DOES set + use it).
CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"

log() { printf '[claude] %s\n' "$*" >&2; }

# Pre-flight 1: docker daemon reachable (exit 8 per Story 2.6 schema).
if ! docker info --format '{{.ServerVersion}}' >/dev/null 2>&1; then
  log "docker unreachable — is the daemon running?"
  exit 8
fi

# Pre-flight 2: container is running. No auto-start — auth is a one-off
# operator gesture, not a loop-entry gesture (SC-4; contrast
# ralph-build-host.sh which DOES auto-start per Story 2.7 SC-1).
state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"
if [[ "${state}" != "running" ]]; then
  log "container '${CONTAINER_NAME}' is not running — run 'pnpm devbox:start' first"
  exit 9
fi

log "invoking claude inside ${CONTAINER_NAME} (first run: complete OAuth in host browser; token persists at /home/dev/.claude/)"
# No signal trapping — docker exec forwards SIGINT/SIGTERM/SIGPIPE to
# claude's PID inside the container. Defensive trap handlers would break
# passthrough (Story 2.1 iter-144 SIGPIPE precedent; Story 2.7 v1.1 PATCH 3).
exec docker exec -it --user dev -w /workspace "${CONTAINER_NAME}" claude "$@"
```

Structural ancestors: shell.sh (Story 2.6; docker exec -it interactive) + attach.sh (Story 2.6; fail-closed exit 9). Divergences from shell.sh: no trailing `if [[ $# -gt 0 ]]` branch for non-interactive forwarded commands — claude-host.sh treats all invocations as interactive (SC-6 no-TTY-gate; SC-9 args passthrough goes through `-it` unconditionally; `claude --version` still works under `-it` because claude's output is not buffered in a way that breaks under PTY allocation).

### OAuth flow mechanics (AC 1 + AC 2 + AC 3 + AC 4 anchor)

Claude Code's authentication (at `@anthropic-ai/claude-code@2.1.116` as baked in Dockerfile:119) uses a device-code-style OAuth flow:

1. `claude` invoked with no existing token → prints a URL + device code to stdout.
2. Operator reads URL from terminal (already surfaced via `docker exec -it` stdin/stdout connection).
3. Operator opens URL in host browser, completes Anthropic OAuth, enters device code on the OAuth confirmation page.
4. `claude` polls Anthropic's token endpoint until OAuth confirmation completes.
5. `claude` writes token file under `/home/dev/.claude/` (exact filename is upstream-owned; typically `~/.claude/.credentials.json` or similar — substrate does NOT depend on the exact filename per SC-15).
6. `claude` proceeds to its default next action (interactive session, or args-driven behaviour like `--version` immediate-exit).

Port-publication note: the device-code flow does NOT require a host-reachable callback server inside the container. Anthropic's OAuth endpoint handles the code-exchange server-side. Compose's port list (lines 109-113: 3000 / 3001 / 6006 / 24679) does NOT need extension for Story 2.8. If Anthropic pivots from device-code to PKCE-with-local-callback, that is a future amendment at that time (either publish a loopback port + update compose, or run a `socat` / `ssh -L`-adjacent port-forward from the host — both out of scope for 1.0).

Token persistence across restarts (AC 3): `/home/dev/.claude/` is under `/home/dev`, which is mounted from the `keel_home_dev` named volume (compose lines 90-92 + 170-171; Story 2.5 substrate). Named volumes survive container stop/start/restart; they are destroyed only on explicit `docker volume rm` or `pnpm devbox:clean --with-volumes` (AC 5).

Re-auth on expiry (AC 4): when an expired/revoked token is loaded, claude's own token-refresh or explicit-reauth behaviour (upstream-owned — typically emits a pointer message like `Please authenticate again`) surfaces to operator stdout via the same `docker exec -it` pipeline. Operator runs `pnpm claude` again → OAuth flow repeats → new token overwrites old. No wrapper-side state tracking required.

### Testing Standards

**ATDD skip (FR14n matrix row 3 — eighteenth cumulative precedent).** Story 2.8 inherits the FR14n three-ground conjunction with a NEW ground-(c) variant: **"external-service-owns-behavior-under-test"**. Three-ground conjunction for Story 2.8:

- **Ground (a) — Substrate-verification covers AC 1 (invocation envelope) at iteration-env-safe layer.** Task 5 smoke tests exercise: (a-i) syntax parse + pnpm wiring (Smoke 1 + 2); (a-ii) pre-flight branches via stub-docker (Smoke 3a info-fail → exit 8; Smoke 3b not-running → exit 9); (a-iii) final-exec-line assembly via stub-docker (Smoke 3c running → `docker exec -it --user dev -w /workspace keel-devbox claude` captured verbatim); (a-iv) args passthrough (Smoke 3d `--version` arg reaches claude). These are shell-level smokes, not runtime-probe tests — but they deterministically verify the wrapper's control-flow paths + invocation envelope.

- **Ground (b) — No test runner wired at substrate level yet.** Story 1.16 (CI pipeline) delivers the runner; until then, red-phase Vitest/Jest/Playwright scaffolds have nowhere to run. Bare "no runner" is insufficient per Story 1.8 guardrail — it MUST combine with ground (a) or (c).

- **Ground (c) — External-service-owns-behavior-under-test for AC 1 (OAuth URL + completion) + AC 2 (token file write) + AC 3 (token reuse) + AC 4 (re-auth) + AC 5 (volume-delete clears token).** AC 1's OAuth URL surface + AC 2's token file write are behaviors of the `@anthropic-ai/claude-code@2.1.116` CLI binary (Anthropic-owned) + Anthropic's OAuth endpoint (external service). AC 3 + AC 5 are behaviors of Docker's named-volume persistence (already verified at Story 2.5 substrate; not in Story 2.8's scope to re-verify). AC 4 is a behavior of claude's token-refresh logic (upstream-owned). Story 2.8's wrapper can ONLY verify: (i) the invocation envelope is correctly assembled; (ii) the pre-flight guards are correct; (iii) args passthrough works. Full AC verification requires: (α) live claude binary reaching Anthropic's OAuth endpoint (egress whitelist covers it per Story 2.3/2.4); (β) host browser for URL completion; (γ) M4-Pro native Docker Desktop for reliable `docker exec -it` TTY + stdin_open. This is a NEW ground-(c) variant extending Story 2.7's "downstream-epic-owns-behavior-under-test" (Epic-3-scope) with a sibling "external-service-owns-behavior-under-test" (upstream-CLI + external-endpoint-scope) covering the authentication-flow class of stories (Story 2.8 Claude + Story 2.9 gh).

**Trace WAIVED expected at `/bmad-testarch-trace` gate.** 5 ACs total: AC 1 partially covered by Task 5 iteration-env-safe smokes (invocation envelope verified; OAuth endpoint behaviour deferred to operator workstation). AC 2 / AC 3 / AC 4 / AC 5 entirely deferred to external-service behaviour + Docker named-volume substrate (Story 2.5). Deterministic coverage: 0.2/5 = 4% automated (wrapper envelope only); 4.8/5 = 96% external-owned. Trace verdict: WAIVED with rationale "Story 2.8 wrapper envelope substrate-smoked; OAuth flow + token persistence + re-auth + volume-delete behaviours owned by upstream `@anthropic-ai/claude-code` CLI + Docker named-volume substrate (Story 2.5); operator-workstation smoke covers live flow." Following the Story 2.6 iter-202 + Story 2.7 iter-224 WAIVED precedent; this is the EIGHTEENTH cumulative trace-WAIVED precedent + NINETEENTH ATDD-skip-trace-WAIVED pairing.

**CR adversarial backstop applies.** The `/bmad-code-review (args: "2")` Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out exercises AC 2/3/4/5 at the design-contract layer (verifying the wrapper's scope carve-out is coherent + the token-persistence contract is correctly composed on Story 2.5 substrate + the re-auth path is correctly delegated to upstream) even though runtime probes are external-service-deferred. Story 2.8 CR forecast: **1–3 PATCH opener + 0 closure re-run** (narrower novel surface than Story 2.7 — 1 script vs 2; 100% of patterns are composition on Story 2.6 + 2.7; novel surface is solely the SC-2/SC-4/SC-12/SC-15 scope carve-outs around upstream CLI + Story 2.5 substrate + OAuth semantics). Dense SC pinning (17 SCs at draft time — same density as Story 2.7 post-PATCH) should amortize downstream per the Story 2.6 iter-219 LESSON + Story 2.7 iter-226 LESSON "dense pre-dev SM PATCH + dense SC pinning → one-pass ZERO-PATCH CR closure." Story 2.7 achieved first one-pass ZERO-PATCH at iter-226; Story 2.8 is a candidate for the SECOND one-pass ZERO-PATCH precedent given its narrower novel surface.

**Live OAuth flow operator-workstation-deferred.** AC 1's "OAuth URL surfaced to my host terminal" + AC 2's "tokens stored at /home/dev/.claude/" + AC 3's "token reused across restart" + AC 4's "re-auth on expiry" + AC 5's "tokens gone after volume-delete" require: (i) live `@anthropic-ai/claude-code@2.1.116` reaching Anthropic's OAuth endpoint (egress whitelist covers `api.anthropic.com` + `console.anthropic.com`); (ii) a host browser for URL completion + device-code entry; (iii) M4-Pro native Docker Desktop for reliable `docker exec -it` TTY + stdin_open under cap-dropped containers; (iv) an operator willing to bind a real Anthropic account to the test devbox. cc-devbox backend-B (iteration env) cannot safely exercise interactive OAuth without polluting operator credentials. Operator smoke + eventual Epic 3 + Epic 4 integration (Ralph's push-gate claude auth check + security-evidence surface) handle live verification together.

### Substrate contracts preserved (do NOT modify)

Story 2.8 composes on top of the following substrate contracts. Any change to these is OUT OF SCOPE for Story 2.8 and requires a dedicated FR44 AMEND path:

- **Story 2.1 substrate** — `packages/devbox/Dockerfile` (including line 119 `@anthropic-ai/claude-code@2.1.116` install + lines 251-252 `/home/dev/.claude/` placeholder create), `packages/devbox/docker-compose.yml` base shape, `/usr/local/bin/entrypoint.sh`, `CMD: ["sleep", "infinity"]`.
- **Story 2.2 substrate** — `.envrc` parameterization (including `KEEL_DEVBOX_CONTAINER_NAME` that Story 2.8's wrapper reads via `${...:-keel-devbox}`).
- **Story 2.3 substrate** — Egress policy including `api.anthropic.com` + `console.anthropic.com` whitelist entries (Story 2.8's OAuth flow depends on these being reachable). `INV-devbox-egress-contract` unchanged.
- **Story 2.4 substrate** — Whitelist source-of-truth; Story 2.8 does NOT modify any `whitelist.*.txt` file; Anthropic domains already in substrate whitelist.
- **Story 2.5 substrate** — Non-root `dev` user (UID 1000) + `cap_drop: [ALL]` + three-cap narrow list + `no-new-privileges` + tmpfs noexec + **named volume `keel_home_dev` for `/home/dev`** (load-bearing for AC 2 + AC 3 + AC 5) + `INV-devbox-homedev-named-volume`. Story 2.8 RELIES on this substrate contract; does NOT modify.
- **Story 2.6 substrate** — All 13 `pnpm devbox:*` verbs + their host-side shim patterns + uniform exit-code schema (`0`/`2`/`8`/`9`/`10`/`11`/`*`) + `<verb>-host.sh` naming convention. Story 2.8's wrapper COMPOSES on these primitives (pattern-mirror shell.sh + attach.sh) and MIRRORS the shim naming (`claude-host.sh`). Zero modifications to Story 2.6 scripts.
- **Story 2.7 substrate** — 2-verb ralph surface (`ralph:build` + `ralph:plan`) + ralph-*-host.sh auto-start pattern + `KEEL_RALPH_MODE` env-var mode-signal contract. Story 2.8 does NOT modify or reuse Story 2.7's auto-start logic (SC-4 explicit no-auto-start posture). Zero modifications to Story 2.7 scripts.
- **Story 1.12 substrate** — `packages/devbox/tui/theme.py` autogenerated Textual theme (consumed by Epic 3's in-container TUI, NOT by Story 2.8's wrapper).
- **Invariant registry** — No new invariant entries in `packages/keel-invariants/src/invariants.manifest.ts`. All Story 2.8 contracts compose on existing invariants (`INV-devbox-dind-available`, `INV-devbox-egress-contract`, `INV-devbox-homedev-named-volume`).

### Project Structure Notes

**Alignment with architecture.md scripts tree (lines 991-1004):** The architecture tree enumerates a subset of scripts under `packages/devbox/scripts/` without full bottom-to-top coverage — Story 2.6 landed 13 host-side verbs/shims extending that enumeration; Story 2.7 landed 2 more (`ralph-build-host.sh` + `ralph-plan-host.sh`); Stories 2.3/2.4 also landed 6 in-container primitives under the same directory (see SC-14 accounting). At Story 2.8 draft time (2026-04-22) the directory holds 21 scripts total (13 Story 2.6 + 2 Story 2.7 + 6 Story 2.3/2.4 in-container); Story 2.8 adds 1 more host-side shim (`claude-host.sh`), bringing the directory to 22 and the host-side-shim subset (Story 2.6 + 2.7 + 2.8) to 16. The architecture tree does NOT explicitly enumerate `claude-host.sh` — this is an epics-vs-architecture scope extension, not drift. Following Story 2.6 iter-201 + Story 2.7 iter-223 precedent (shim-count extension without architecture-document amendment), Story 2.8 continues the convention. A future substrate cleanup (Epic 1 retrospective or Story 2.17 close-out) may reconcile the architecture tree to enumerate all scripts.

**Alignment with PRD `:489` — `pnpm claude` verb form:** PRD architecture.md:489 table row pins `pnpm claude` (top-level verb, no colon) as "Interactive Claude Code session inside devbox; first-run triggers OAuth." Story 2.8's Task 2 wires the verb verbatim — NO `devbox:claude` or `auth:claude` variant. Story 2.9's `gh:auth` variance (colon form) is a separate epics.md-pinned decision and is NOT homogenized with `pnpm claude` — the asymmetry is intentional (PRD authoritative).

**Variance with `docker-compose.yml:156` stale TODO:** Compose line 156 reads `# TODO(Story 2.8 / 2.9): named-volume mounts for OAuth tokens.` This TODO pre-dates Story 2.5 landing the `/home/dev` named-volume mount at compose lines 90-92 — which subsumes the Stories 2.8 + 2.9 token-mount requirement. The TODO is now stale. SC-12 pins the "no compose edits in Story 2.8" posture; the stale TODO removal is deferred to Story 2.17 Epic 2 close-out or a standalone polish pass. **No tracking entry in `deferred-work.md` is required** — Story 2.8's deliberate no-op on compose:156 creates no new deferred artifact, and the TODO comment is already self-documenting (the `Story 2.8 / 2.9` token inside it makes the carry-forward discoverable via `grep 'TODO.*Story 2\.' packages/devbox/docker-compose.yml` from any future polish iteration). Dev-agent MUST NOT remove the TODO as part of Story 2.8 (scope-creep per SC-17 spirit).

**No invariants.manifest.ts updates:** Story 2.8 introduces no new machine-enforced contract. The scope is a composition on existing invariants (`INV-devbox-dind-available`, `INV-devbox-egress-contract`, `INV-devbox-homedev-named-volume`). Sync-gate (Story 1.9) passes without change.

### Previous-story intelligence (Story 2.7 iter-226 ZERO-PATCH one-pass CR closure)

Story 2.7 closed at iter-226 with a **ONE-PASS ZERO-PATCH CR closure** — the first cumulative one-pass ZERO-PATCH outcome in the project (Story 2.6 iter-219 required 3 CR passes + 13 AI drains to reach ZERO-PATCH). Root cause: iter-221 pre-dev SM review surfaced + patched 5 findings (PATCH 1 H2/H3 correction; PATCH 2 script-count accounting; PATCH 3 exit-9 emission + no-signal-trap comment; PATCH 4 SC-17 read-only guardrails; PATCH 5 mode-lifecycle gotcha). These PATCHes tightened the spec to zero-latitude-for-drift; iter-223 implementation landed verbatim; iter-225 post-dev SM verified ZERO-PATCH; iter-226 CR ZERO-PATCH one-pass.

**LESSON carry-forward for Story 2.8:** Dense pre-dev SM PATCHes (target: ≥5) → verbatim spec-template implementation → reliable one-pass ZERO-PATCH CR closure. Story 2.8 ships 17 SCs at draft time (matching Story 2.7's post-PATCH 17-SC density). Story 2.8's pre-dev SM review at `/bmad-create-story (args: "review")` gate is the critical upstream for one-pass CR outcome — if SM PATCH density falls below 3, SM review is under-engaged relative to the pattern.

**LESSON carry-forward on stub-docker harness:** Story 2.7 iter-223 surfaced the `trap 'rm -rf <dir>' EXIT` in setup caveat — each Bash tool call is a separate shell process, so EXIT traps do NOT survive cross-call. Pattern: create stub WITHOUT trap; explicit `rm -rf` in final assertion call. Task 5 smoke-3 codifies this explicitly. Applies to all future stub-harness smokes in Stories 2.9 + 2.10 + 2.13.

**LESSON carry-forward on TTY-detect gate:** Story 2.7 SC-8 pinned "no TTY-detect gate on interactive-by-contract verbs (attach IS the AC)." Story 2.8 inherits via SC-6: "no TTY-detect gate on claude-exec (OAuth flow IS the AC)." The TTY-detect pattern (AR-10 from Story 2.6 iter-214) applies ONLY to `docker exec` verbs that must remain scriptable (shell.sh with `-c` args); it does NOT apply to attach-class or OAuth-class interactive-by-contract verbs.

### Git intelligence (recent substrate history)

Recent commits (last 5 on `feat/epic-2-packaged-devbox`):
1. `82f3979 docs(story-2-7): iter-226 — CR closure ZERO-PATCH one-pass, sm-verified → done` — Story 2.7 reached `done` with 0 PATCH findings.
2. `5898879 docs(story-2-7): iter-225 — post-dev SM verified, traced → sm-verified, ZERO-PATCH` — Story 2.7 post-dev SM also ZERO-PATCH.
3. `89ae8d0 docs(story-2-7): iter-224 — trace WAIVED, in-dev → traced, 17th cumulative precedent` — Story 2.7 trace gate.
4. `098aa41 feat(devbox): iter-223 — Story 2.7 impl landed, ralph:build/ralph:plan wrappers + auto-start + attach envelope` — Story 2.7 implementation (files landed: 2 new scripts + package.json + README.md H2 + AGENTS.md H3).
5. `1c15182 docs(story-2-7): iter-222 — FR14n ATDD-skip applied, validated → atdd-scaffolded` — Story 2.7 ATDD gate.

**Actionable pattern extraction:**
- Commit messages use scope `feat(devbox)` for implementation-landing iters + `docs(story-2-N)` for all other lifecycle iters (drafted / validated / atdd-scaffolded / traced / sm-verified / done).
- Iteration numbers monotonically increase across story boundaries — Story 2.7 spanned iter-220..226; Story 2.8 begins iter-227.
- Each lifecycle gate gets its own iter + commit (no bundling). Matches Ralph guardrail 5 "one task per iteration."
- File set per gate is minimal — trace gate writes artefacts under `_bmad-output/test-artifacts/traceability/`; SM review updates story file only; CR gate writes Deferred bullets into `deferred-work.md` + story file § Review Findings + Change Log bump.

### References

- Source story AC: [Source: _bmad-output/planning-artifacts/epics.md:1417-1447]
- FR3 verbatim: [Source: _bmad-output/planning-artifacts/prd.md:929]
- NFR10 verbatim (named-volume token persistence): [Source: _bmad-output/planning-artifacts/prd.md:1082]
- FR1 non-toggle-able pnpm surface (applies to Story 2.8): [Source: _bmad-output/planning-artifacts/architecture.md:74]
- CLI tool surface table `pnpm claude` row: [Source: _bmad-output/planning-artifacts/architecture.md:489]
- One-time auth prerequisites inside devbox: [Source: _bmad-output/planning-artifacts/architecture.md:75, :506; _bmad-output/planning-artifacts/epics.md:1157]
- Claude Code CLI install (`@anthropic-ai/claude-code@2.1.116` pinned): [Source: packages/devbox/Dockerfile:111-120]
- `/home/dev/.claude/` placeholder create: [Source: packages/devbox/Dockerfile:246-252]
- Non-root `dev` user (UID/GID 1000): [Source: packages/devbox/Dockerfile:255-270; Story 2.5 iter-187 § Dev Notes]
- Named volume `keel_home_dev` at `/home/dev`: [Source: packages/devbox/docker-compose.yml:86-92, :170-171; Story 2.5 § Dev Notes named-volume contract]
- Compose `tty: true` + `stdin_open: true`: [Source: packages/devbox/docker-compose.yml:158-159]
- Story 2.6 uniform exit-code schema: [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-5]
- Story 2.6 `<verb>-host.sh` naming convention: [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-2, SC-15, SC-16]
- Story 2.6 shell.sh interactive-exec template: [Source: packages/devbox/scripts/shell.sh:1-43]
- Story 2.6 attach.sh fail-closed exit-9 precedent: [Source: packages/devbox/scripts/attach.sh:32-36]
- Story 2.6 `unset COMPOSE_PROJECT_NAME` AI-8/AI-12 pattern: [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Change Log; packages/devbox/scripts/shell.sh:17-20]
- Story 2.6 TTY-detect gate (AR-10; NOT applied to interactive-by-contract verbs): [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Review Findings AI-10 + AR-10]
- Story 2.6 `_lib.sh` refactor deferral (AR-19): [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Review Findings AR-19]
- Story 2.6 `--help` rollout deferral (AR-18): [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Review Findings AR-18]
- Story 2.7 FR1 non-toggle-able invariant extension + Epic-3 scope carve-out pattern: [Source: _bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md § Dev Notes SC-1, SC-2]
- Story 2.7 dense SC pinning → ZERO-PATCH CR closure LESSON: [Source: _bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md § Change Log v1.5 + v1.6]
- Story 2.7 stub-docker harness template + trap-EXIT caveat: [Source: _bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md § Dev Agent Record + Change Log v1.3]
- Story 2.7 ATDD-skip FR14n matrix row 3 with ground-(c) variant: [Source: _bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md § Testing Standards]
- INV-devbox-dind-available (Story 2.8 prereq): [Source: INVARIANTS.md line 94; docs/invariants/devbox-dind.md]
- INV-devbox-egress-contract (Story 2.8 unchanged; Anthropic domains already whitelisted): [Source: INVARIANTS.md line 100; docs/invariants/devbox-egress.md]
- INV-devbox-homedev-named-volume (Story 2.8 RELIES ON — load-bearing for AC 2/3/5): [Source: INVARIANTS.md line 106; docs/invariants/devbox-hardening.md]
- Story 2.5 named-volume substrate detail: [Source: _bmad-output/implementation-artifacts/2-5-container-hardening-non-root-user-capabilities-tmpfs-noexec-named-volume.md § Dev Notes]

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List

## Change Log

- v1.1 (2026-04-22) — **Pre-dev SM review (iter-228) — `drafted → validated`.** Four PATCHes applied from adversarial triage (Blind Hunter + Edge Case Hunter fan-out): **(1)** SC-1 pre-flight attribution corrected — Story 2.8 inherits Story 2.7's `docker info --format '{{.ServerVersion}}'` tighter variant (ralph-build-host.sh:36 precedent), NOT Story 2.6's bare `docker info >/dev/null 2>&1` form; wording "duplicates Story 2.6's pre-flight boilerplate verbatim" was imprecise and is now corrected to "duplicates Story 2.7's ralph-wrappers pre-flight boilerplate verbatim" with rationale for the tightening (catches reachable-but-broken-daemon states). **(2)** Task 1 + template SCRIPT_DIR removal — SC-4's no-auto-start posture means no `"${SCRIPT_DIR}/start.sh"` sub-invoke, so `SCRIPT_DIR` is dead code in Story 2.8. Story 2.7's ralph wrappers DO use it (ralph-build-host.sh:29+46 for the sub-invoke) — Story 2.8 deliberately does NOT inherit that variable. Removing it prevents cargo-culting at future amendment time. Template + Task 1 updated to omit `SCRIPT_DIR` with an explanatory comment. **(3)** SC-3 host-side-shim count off-by-1 — "16 other host-side shims" → "15 other host-side shims"; "16 shims at Story 2.7 landing → 17 at Story 2.8 landing" → "15 host-side shims at Story 2.7 landing [13 Story 2.6 + 2 Story 2.7] → 16 after Story 2.8 lands". SC-14's accounting at line 104 had the correct numbers (15 → 16); SC-3 drifted. Reconciled. Adds explicit "matches SC-14 accounting" cross-ref + citation of directory listing at 2026-04-22. **(4)** SC-12 + Project Structure Notes phantom-deferred-work reference removed — the draft claimed a `deferred-work.md § Deferred from: Story 2.8 draft iter-227` tracking entry for the stale compose:156 TODO, but (a) the entry was never written (iter-227 committed without touching deferred-work.md), (b) deferred-work.md's § header line 3 scopes entries to CR-triage-surfaced items, not inaction-under-SC posture, (c) the TODO itself is self-documenting (`grep 'TODO.*Story 2\.' packages/devbox/docker-compose.yml` discovers it from any polish iteration). Replaced the forward-reference with the correct "no tracking entry required — TODO is self-documenting; deferred-work.md is CR-only scope" phrasing. **LESSON:** Even under a dense-SC-pinning draft pattern (17 SCs), pre-dev SM adversarial triage surfaces enough PATCHes to justify the SM-review gate (Story 2.7 iter-221 precedent: 5 PATCHes; Story 2.8 iter-228: 4 PATCHes). **Story State** `drafted → validated`; sprint-status UNCHANGED per iter-156 + iter-221 precedent (pre-dev SM gate does not flip sprint-status). **Forecast carry-forward:** 4 PATCHes at iter-228 + verbatim-spec implementation (iter-229+n) → post-dev SM ZERO-PATCH at trace gate → CR ZERO-PATCH forecast (1–3 PATCH opener + 0 closure; candidate for SECOND one-pass ZERO-PATCH precedent per Story 2.7 iter-226 first-precedent). If iter-229+n dev-story drifts from v1.1 spec, post-dev SM PATCH density will exceed ZERO — indicator of spec-implementation divergence.

- v1.0 (2026-04-22) — Initial draft. 5 ACs + 6 tasks + 17 SCs. Scope carve-outs pinned: SC-2 upstream Claude Code CLI + Anthropic OAuth endpoint own auth flow semantics; SC-4 no-auto-start (fail-closed exit 9; contrast Story 2.7's auto-start ralph wrappers); SC-12 no compose edits (Story 2.5 substrate already provides `/home/dev` named-volume mount subsuming `/home/dev/.claude/` persistence); SC-15 wrapper does NOT inspect/parse token file; SC-17 read-only posture on Story 2.6 + 2.7 README + AGENTS.md sections. File placement under `packages/devbox/scripts/claude-host.sh` per SC-3 (co-located with Story 2.6 + 2.7 shims; `<verb>-host.sh` naming mandated by Story 2.7 SC-4). `_lib.sh` refactor explicitly deferred per SC-14 (carries AR-19 from Story 2.6 + SC-14 from Story 2.7). ATDD skip + trace WAIVED forecast per FR14n matrix row 3 — eighteenth cumulative precedent; new ground-(c) variant "external-service-owns-behavior-under-test" extending Story 2.7's "downstream-epic-owns-behavior-under-test" (Epic-3-scope) with sibling for upstream-CLI + external-endpoint-scope auth-flow class (Story 2.8 Claude + Story 2.9 gh). CR forecast: 1–3 PATCH opener + 0 closure re-run (narrower novel surface than Story 2.7; candidate for SECOND one-pass ZERO-PATCH precedent given dense SC pinning + 100% composition on Story 2.6 + 2.7 patterns + single-script impl surface). Draft density target: 17 SCs matches Story 2.7 post-PATCH density; pre-dev SM review at next iter expected to generate 3+ PATCHes to maintain the pattern.
