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

Every story moves through a pinned seven-state lifecycle that binds the BMad story-cycle skills into a deterministic pipeline. `Story State` lives in `.ralph/@plan.md § Context` and is read at Orient step 2. Normative spec: FR14n. Full matrix in `_bmad-output/planning-artifacts/prd.md` § Agent Workflow Contracts → Story-lifecycle decision matrix.

State → NOW task mapping (abridged):

| Story State       | Next skill                                          |
|-------------------|-----------------------------------------------------|
| _(no story)_      | `/bmad-create-story`                                |
| `drafted`         | `/bmad-create-story (args: "review")`               |
| `validated`       | `/bmad-testarch-atdd` (or skip with IP rationale)   |
| `atdd-scaffolded` | `/bmad-dev-story (args: "{story_file_path}")`       |
| `in-dev`          | `/bmad-code-review (args: "2")`                     |
| `fixes-pending`   | Top QUEUE fix task (one CR action item per iter)    |
| `done`            | Next story or EPIC_DONE halt                        |

Four non-toggle-able anti-constraints:

- ⊗ Never skip states — absent `Story State` forces `/bmad-create-story`.
- ⊗ Never invoke `/bmad-dev-story` outside `atdd-scaffolded` without an IP-recorded skip rationale.
- ⊗ Never mark `done` with un-addressed CR action items in QUEUE.
- ⊗ Every CR action item becomes a QUEUE fix task unless IP records `defer: <reason>`.

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
