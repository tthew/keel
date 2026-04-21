# Invariant — Ralph Execute-Phase Contract

**Scope:** every Ralph iteration on any Keel-forked repo.
**Status:** non-toggle-able. Fork-to-remove.
**Machine-enforced in:** `.ralph/PROMPT_build.md` (seeded from `packages/keel-templates/PROMPT_build.template.md`); `ralph.py` loop controller; CI path-based gate routing.
**Normative spec:** `_bmad-output/planning-artifacts/prd.md` § Agent Workflow Contracts (FR14f–FR14k, FR14n).

## The contract

Every iteration follows a fixed spine:

**orient → one task → commit → update IP → pre-push quality gate → pre-push CI gate → push → exit**

## Orient phase

Eight ordered, non-skippable steps executed before any work:

1. Read current epic/story from `_bmad-output/planning-artifacts/epics/`.
2. Read `.ralph/@plan.md` (NOW / QUEUE / BLOCKED / DONE / Context).
3. Read knowledge files: `AGENTS.md`, `CLAUDE.md`, `RALPH.md`.
4. Detect BMad phase via `_bmad/_config/bmad-help.csv`; respect blocking gates.
5. Search application source with Sonnet subagents (≤ 1 Sonnet subagent for any build/test/lint command — FR14c backpressure).
6. Verify budget headroom per NFR4b (≥ 25K remaining; decompose if XL ≥ 60K; exit on context-exhaustion signals).
7. Read native Claude Code task list — in-flight tasks are crash-journal signals.
8. If PR exists, check `gh pr checks` — any in-progress/pending routes to CI monitoring (FR14i pre-push gate).

## Execute rules

- **One task per iteration.** Compound NOW tasks ("do X AND Y") are rejected at orient and decomposed into NOW + QUEUE.
- **One BMad-workflow invocation = one full iteration.** Never chain workflows.
- **dev-story invocation.** `/bmad-dev-story` runs as a single-iteration workflow in a fresh context window regardless of task count. Story-cycle sequencing is governed by FR14n (see § Story-lifecycle decision matrix).
- **Commit before push.** Iteration work commits locally; pre-push failures leave committed work for the next iteration.
- **IP discipline.** Fix tasks enter QUEUE at the TOP (priority stack, not FIFO). Keep IP under 50 lines — prune done.
- **Gate order.** Pre-push quality gate (local tests) → pre-push CI gate (no in-progress PR checks) → push.

## PR-lifecycle decision matrix

See `_bmad-output/planning-artifacts/prd.md` § Agent Workflow Contracts → PR-lifecycle decision matrix for the full six-row table.

Three non-toggle-able anti-constraints:

- ⊗ Never mark EPIC_DONE while PR is Draft.
- ⊗ Never transition Draft → Open until all implementation tasks (including queued CI fixes) are complete.
- ⊗ Never address PR review feedback while PR is Draft.

## Story-lifecycle decision matrix

Every story moves through a pinned eleven-state lifecycle that binds the BMad story-cycle skills into a deterministic pipeline. `Story State` lives in `.ralph/@plan.md § Context` and is read at Orient step 2. Gate ordering is **coverage (trace) → requirements (SM review) → quality (CR) → done**. Normative spec: FR14n. Full matrix in `_bmad-output/planning-artifacts/prd.md` § Agent Workflow Contracts → Story-lifecycle decision matrix.

State → NOW task mapping (abridged):

| Story State           | Next skill                                                        |
|-----------------------|-------------------------------------------------------------------|
| _(no story)_          | `/bmad-create-story`                                              |
| `drafted`             | `/bmad-create-story (args: "review")` — pre-dev                   |
| `validated`           | `/bmad-testarch-atdd` (or skip with IP rationale)                 |
| `atdd-scaffolded`     | `/bmad-dev-story (args: "{story_file_path}")`                     |
| `in-dev`              | `/bmad-testarch-trace (args: "yolo")` — coverage gate             |
| `trace-fixes-pending` | Top QUEUE fix task (add missing AC test)                          |
| `traced`              | `/bmad-create-story (args: "review")` — post-dev SM verification  |
| `sm-fixes-pending`    | Top QUEUE fix task (satisfy unmet AC)                             |
| `sm-verified`         | `/bmad-code-review (args: "2")`                                   |
| `fixes-pending`       | Top QUEUE fix task (one CR action item per iter)                  |
| `done`                | Next story in current epic; if epic has no more open stories → § Cross-epic transition (auto-advance if PR merged + next epic in backlog; else `EPIC_DONE`/`ALL_EPICS_DONE` halt) |

Eight non-toggle-able anti-constraints:

- ⊗ Never skip states — absent `Story State` forces `/bmad-create-story`.
- ⊗ Never invoke `/bmad-dev-story` outside `atdd-scaffolded` without an IP-recorded skip rationale.
- ⊗ Never invoke `/bmad-testarch-trace` outside `in-dev`.
- ⊗ Never invoke `/bmad-create-story (args: "review")` post-dev outside `traced`.
- ⊗ Never invoke `/bmad-code-review` outside `sm-verified`.
- ⊗ Never mark `done` with un-addressed fix tasks in QUEUE (any origin: trace, SM, or CR).
- ⊗ Every trace coverage gap and SM-review unmet-AC finding becomes a QUEUE fix task unless IP records `defer: <reason>`.
- ⊗ Every CR action item becomes a QUEUE fix task unless IP records `defer: <reason>`.

## Halt schema

`.ralph/halt` is a JSON file: `{"reason": "<enum>", "epic": <N|null>, "pr": "<url|null>"}`.

Closed reason enum at 1.0:

- `EPIC_DONE` — current epic shipped; PR pending human merge. Single-pass halt — on re-entry after merge, FR14n's § Cross-epic transition auto-advances to the next epic (no re-halt loop).
- `ALL_EPICS_DONE` — every epic in sprint-status is done; terminal. `ralph.py` skips the GH project epic transition (no epic to close). `{epic:null, pr:null}`.
- `AWAIT_MERGE` — PR open, CI green, waiting on human merge.
- `BUDGET_EXHAUSTED` — crossed the 25K buffer floor mid-iteration (NFR4b).
- `CI_BLOCKED` — pre-push CI gate blocks progress until human intervention (FR14i).
- `SECURITY_CRITICAL` — critical-severity security finding halted the loop (NFR18).
- `RALPH_STAGE_REGRESSION` — Ralph safe-set L1 stage-upgrade bootstrap-validation failed (FR14m + NFR4c).

**Autonomy constraint (non-toggle-able, anchor: INV-ralph-halt-reason-enum).** Every reason is bounded — either self-resolving (`EPIC_DONE` via § Cross-epic transition on re-entry; `AWAIT_MERGE` via merge; `ALL_EPICS_DONE` is terminal) or triggered by a concrete external condition (budget/CI/security/stage regression). No reason blocks on open-ended human input. Ralph does NOT invoke `AskUserQuestion` from the runtime loop. When state is inconsistent and the decision tree cannot produce an unambiguous action, Ralph falls back to an existing bounded reason (typically `EPIC_DONE` with a diagnostic `note` field) rather than introducing a new waiting state. A hypothetical `AWAITING_USER` reason was explicitly rejected on autonomy grounds in the 2026-04-21 amendment.

## Cross-epic transition (FR14n amendment, 2026-04-21)

When `Story State = done` AND sprint-status has no more open stories in the current epic, the Story-lifecycle matrix routes through a cross-epic transition before halting. Build-mode Ralph:

1. Reads the current epic's PR number from `.ralph/@plan.md § Context` (`**PR:** #N`).
2. Queries actual PR state via `gh pr view <N> --json state,mergedAt` — `gh` is source of truth, not the § Context text.
3. Branches:
   - **MERGED (or no PR recorded) AND sprint-status has a next epic with a backlog first story `(N+1).1`** → queues `/bmad-create-story` for the next epic's first story as NOW; updates § Context (`Epic=N+1`, `Story=(N+1).1`, `Story State=_(no story)_`, `PR: n/a`); commits, pushes, exits. **No halt, no mode switch.** The iteration stays in build-mode; one task per iteration is preserved (create-story is the single task).
   - **PR state in {OPEN, DRAFT, CLOSED-unmerged}** → writes `EPIC_DONE` halt. Next invocation re-evaluates from step 1 — after human merge, branch (a) fires and advances.
   - **Sprint-status has no next epic** → writes `ALL_EPICS_DONE` halt (terminal).
   - **State inconsistent** (missing sprint-status rows, `gh pr view` failure, § Context conflicts with sprint-status) → writes `EPIC_DONE` with a diagnostic `note` field describing the inconsistency; exits. Autonomy guardrail: no `AskUserQuestion`, no new waiting halt reason.

This branch closes the Epic 1 iter-95..iter-97 re-halt loop where Ralph correctly halted at epic close but re-halted on every subsequent build-mode invocation because the matrix had no cross-epic advance path.

## Path Resolution

`ralph.py` (and any fork-replacement runtime) MUST resolve `.ralph/halt`, `.ralph/@plan.md`, `.ralph/PROMPT_*.md`, and `.ralph/logs/` to a single deterministic absolute directory that agrees between orchestrator and agent (`claude -p --worktree X`).

**Algorithm:**

- If `--worktree <name>` is set: resolve against the main repo root derived from `git rev-parse --git-common-dir` (cwd-invariant) — `ralph_base = <main_repo>/.claude/worktrees/<name>/.ralph`.
- Else: `ralph_base = <cwd>/.ralph` (single-checkout fallback).

`git rev-parse --git-common-dir` is the canonical cwd-invariant pointer: it returns the main repo's `.git/` whether the orchestrator runs from the main repo or from inside a worktree. Its parent is the main repo root, so the worktree-relative `.ralph/` path is identical across invocation modes.

**Env contract (normative).** The orchestrator MUST export `RALPH_BASE_DIR` (absolute path) into the subprocess env alongside `CLAUDE_CODE_TASK_LIST_ID` and the `RALPH_ISSUE_*` vars. Agents MUST address the halt sentinel, plan file, and PROMPT files via one of:

- `$RALPH_BASE_DIR/halt`, `$RALPH_BASE_DIR/@plan.md`, etc.
- Relative `.ralph/halt`, `.ralph/@plan.md`, etc. — which coincide with `$RALPH_BASE_DIR` when the agent cwd is the worktree (the default under `--worktree`).

Agents MUST NOT use hardcoded main-repo absolute paths (`/workspace/<repo>/.ralph/halt` or similar). That rule was a historical workaround for a cwd-relative halt-detection bug in the orchestrator; the bug is now fixed and the rule is load-bearing-wrong. The 2026-04-20 Story 1.7 iter-22..28 re-entry cascade is the reference incident.

**Startup banner (advisory).** The orchestrator SHOULD log `Ralph base: <abs> (cwd: <abs>)` as the first line of every session log so resolver mismatches surface immediately.

**Defensive dual-path halt read (transitional).** During the post-fix migration window — while cached agent prompts may still carry the pre-fix rule — the orchestrator SHOULD also check `<cwd>/.ralph/halt` as a fallback. If the fallback fires, log a warning naming both paths, migrate the file to `$RALPH_BASE_DIR/halt`, and halt. Remove the fallback at the next Keel major release.

## Fork enforcement

Forks that replace the runtime (`ralph.py`) honour the halt schema (closed 7-reason enum + autonomy constraint) + decision matrix (story-lifecycle + cross-epic transition) + **path-resolution contract** (all three are normative), or fork-and-diverge. The matrix, cross-epic branch, and path-resolution algorithm are shipped in `packages/keel-templates/PROMPT_build.template.md`; re-scaffolding a fresh fork recovers the canonical versions. The autonomy constraint is registered as `INV-ralph-halt-reason-enum` in the invariants manifest — Story 1.9 sync-gate drift-detects any fork that introduces a human-input-blocking halt reason.
