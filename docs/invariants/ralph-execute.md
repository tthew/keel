# Invariant — Ralph Execute-Phase Contract

**Scope:** every Ralph iteration on any Keel-forked repo.
**Status:** non-toggle-able. Fork-to-remove.
**Machine-enforced in:** `.ralph/PROMPT_build.md` (seeded from `packages/keel-templates/PROMPT_build.template.md`); `ralph.py` loop controller; CI path-based gate routing.
**Normative spec:** `_bmad-output/planning-artifacts/prd.md` § Agent Workflow Contracts (FR14f–FR14k).

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
- **dev-story budget rule.** `/bmad-dev-story` on stories with ≥ 3 tasks: reject and decompose per-iteration.
- **Commit before push.** Iteration work commits locally; pre-push failures leave committed work for the next iteration.
- **IP discipline.** Fix tasks enter QUEUE at the TOP (priority stack, not FIFO). Keep IP under 50 lines — prune done.
- **Gate order.** Pre-push quality gate (local tests) → pre-push CI gate (no in-progress PR checks) → push.

## PR-lifecycle decision matrix

See `_bmad-output/planning-artifacts/prd.md` § Agent Workflow Contracts → PR-lifecycle decision matrix for the full six-row table.

Three non-toggle-able anti-constraints:

- ⊗ Never mark EPIC_DONE while PR is Draft.
- ⊗ Never transition Draft → Open until all implementation tasks (including queued CI fixes) are complete.
- ⊗ Never address PR review feedback while PR is Draft.

## Halt schema

`.ralph/halt` is a JSON file: `{"reason": "<enum>", "epic": <N|null>, "pr": "<url|null>"}`.

Closed reason enum at 1.0:

- `EPIC_DONE` — epic shipped; stop.
- `AWAIT_MERGE` — PR open, CI green, waiting on human merge.
- `BUDGET_EXHAUSTED` — crossed the 25K buffer floor mid-iteration (NFR4b).
- `CI_BLOCKED` — pre-push CI gate blocks progress until human intervention (FR14i).
- `SECURITY_CRITICAL` — critical-severity security finding halted the loop (NFR18).

## Fork enforcement

Forks that replace the runtime (`ralph.py`) honour the halt schema + decision matrix or fork-and-diverge. The matrix is shipped in `packages/keel-templates/PROMPT_build.template.md`; re-scaffolding a fresh fork recovers the canonical version.
