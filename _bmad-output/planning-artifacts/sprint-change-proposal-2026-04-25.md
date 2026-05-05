# Sprint Change Proposal — Ralph doc-budget enforcement (issue #231)

- **Date:** 2026-04-25
- **Trigger:** [Issue #231](https://github.com/tthew/ralph-bmad/issues/231) — `RALPH.md` + `.ralph/@plan.md` doc-budget enforcement gap
- **Scope:** Moderate
- **Urgency:** High (do-not-defer; defect probability ≈ 1.0; compounds monotonically)
- **Mode:** Incremental
- **Target branch for delivery:** `feat/epic-2-packaged-devbox` (stacks on PR #230)
- **Authoring skill:** `/bmad-correct-course` (auto mode)

---

## Section 1 — Issue Summary

Ralph's two state-carrying knowledge files have grown past the orient budget:

| File                       | Lines | Words      | Bytes              | Notes                                                            |
| -------------------------- | ----- | ---------- | ------------------ | ---------------------------------------------------------------- |
| `RALPH.md`                 | 279   | **61,343** | **462,181 (~451 KiB)** | Exceeds Claude Code's 256 KiB single-read cap                    |
| `.ralph/@plan.md`          | 40    | 688        | 5,182              | Line-cap passes; one DONE bullet is a 500-word paragraph        |
| `.ralph/PROMPT_build.md`   | 248   | 3,660      | 24,811             | The prompt is itself a victim of the same pattern                |
| `.ralph/PROMPT_plan.md`    | 112   | 642        | 4,532              |                                                                  |

`RALPH.md` alone tokenizes to ~60–80K tokens — **50–70% of the per-iteration ~117K-token execution budget** before Ralph reads any source file. Existing enforcement is text-only, advisory, and gameable: line-count guardrails pass while prose density bloats unbounded; `RALPH.md:5` self-admits `"hard lint enforcement lands in Epic 3 per RS6 — until then, discipline is self-policed"`.

**Failure mode.** Single-axis "Moderate" risk classification has been repeatedly used to defer this; the issue body raised the urgency dimension (probability ≈ 1.0; blast radius = every future Ralph iteration; compounds every iteration). Risk classification on this proposal is therefore **Moderate scope / High urgency** — do-not-defer.

**Discovery.** Surfaced via `/bmad-party-mode` 4-agent roundtable on 2026-04-24 (Paige / Winston / Amelia / Murat — three consensus rounds), captured in issue #231 with grep-verified evidence and file-line citations.

---

## Section 2 — Impact Analysis

### Epic Impact

| Epic | Status | Impact |
| --- | --- | --- |
| Epic 1 | DONE (PR #226) | None — invariants manifest already exists; will receive `INV-ralph-doc-budget` registration *after* Phase 2 + 10 clean iterations land. No retroactive change. |
| Epic 2 | DONE (PR #230, awaiting merge) | **Hosting branch** — this proposal lands on top of `feat/epic-2-packaged-devbox` so it ships in the same merge window. No Epic-2 spec changes. |
| **Epic 3** | **Backlog (target)** | **Primary impact.** Receives one new story (3.34); Stories 3.15 / 3.22 / 3.23 receive narrow AC additions cross-referencing 3.34. |
| Epics 4–17 | Backlog | None |

**Net Epic 3 story count:** 33 → **34**. No re-numbering required (3.34 appended after existing 3.33; sprint-status.yaml gets one new key under `epic-3:`).

### Story Impact

| Story | Existing scope | Change |
| --- | --- | --- |
| **NEW Story 3.34** — Ralph doc-budget orient-gate + pre-commit gate | — | Single-source-of-truth threshold constants, `_build_doc_budget_block()` mirroring `_build_issue_tracking_block()`, `RALPH_DOC_BUDGET_ENFORCE` + `RALPH_DOC_BUDGET_OVERRIDE` env vars, `.githooks/pre-commit-ralph-budget`, two-criteria gating on Phase 2 ship (≥ 20 healthy iters, P90 ≥ 30% below cap, soft-gate FP < 5%) |
| Story 3.15 (per-iteration context meter) | `.ralph/logs/<iter-id>/context-meter.json` | **Phase 0 absorbed.** Add AC for `$RALPH_BASE_DIR/logs/sizes.jsonl` per-iteration footer with `{iter, ts, ralph_md_bytes, ralph_md_lines, plan_md_bytes, plan_md_lines, signpost_word_counts[], done_entry_word_counts[], orient_phase_tokens, line_delta_from_prev}` schema. Pure measurement — no gate. |
| Story 3.22 (knowledge-file upkeep — FR14j warn-on-no-update) | Pre-commit warning when no knowledge file changed | Add cross-reference: doc-budget enforcement (Story 3.34) is the structural counterpart to upkeep (Story 3.22) — upkeep ensures *something* gets written; budget ensures *not too much*. Same pre-commit hook chain. No AC change to 3.22 itself. |
| Story 3.23 (L3 lint guardrails — `tools/lint-knowledge-files.ts`) | RALPH.md size cap 500 lines, H1 stability, etc. | **Coordination clause added.** RALPH.md size cap (500 lines) and Story 3.34's byte/line/per-bullet caps consume the **same threshold constants**. Story 3.23's AC for "RALPH.md exceeds 500 lines" extends to "RALPH.md exceeds the byte / line / per-bullet thresholds defined alongside Story 3.34." Single source of truth — not parallel implementations. |

### Artifact Conflicts

| Artifact | Conflict | Resolution |
| --- | --- | --- |
| **PRD** `_bmad-output/planning-artifacts/prd.md` § FR14j | Current FR14j frames upkeep only; silent on byte/line bloat or runtime gates | **AMEND FR14j** with an additive clause naming `RALPH_DOC_BUDGET_ENFORCE`/`RALPH_DOC_BUDGET_OVERRIDE` env vars and the warn → halt cutover criteria. No new FR. |
| PRD § Knowledge-file upkeep contract (lines 760–770) | Same — names AGENTS/CLAUDE/RALPH but not the budget surface | One-line addition under the contract paragraph pointing to Story 3.34. |
| PRD § FR14m / RS6 | Frames "context-window-poisoning mitigation" generically; doc-budget is the operational instance | Add cross-reference; no spec change to FR14m. |
| **Architecture** `_bmad-output/planning-artifacts/architecture.md` § R4 (Knowledge-file upkeep contract) | Mirrors PRD FR14j; no env-var table | **Extend R4** with a `RALPH_DOC_BUDGET_ENFORCE` / `RALPH_DOC_BUDGET_OVERRIDE` contract paragraph + telemetry pointer to `sizes.jsonl`. |
| Architecture § R7 (Path-Resolution Contract) | Already names `$RALPH_BASE_DIR`; doc-budget gate uses the same env-var pattern | Add a one-line "see also" reference to the new R4 paragraph; no path-resolution change. |
| **Epics** `_bmad-output/planning-artifacts/epics.md` Epic 3 | 33 stories; no doc-budget story | **Append Story 3.34** after Story 3.33; thread cross-references into 3.15 / 3.22 / 3.23 (narrow AC additions only). |
| **Sprint status** `_bmad-output/implementation-artifacts/sprint-status.yaml` | Has Epic-3 entries 3-1..3-33 | **Append** `3-34-ralph-doc-budget-orient-gate-pre-commit-gate: backlog`. |
| `RALPH.md`, `.ralph/PROMPT_build.md`, `.ralph/PROMPT_plan.md` | Self-admittedly unenforced; line citations in #231 | **Out of scope** for this proposal — these land in the implementation iterations of Story 3.34 and the post-amendment one-shot RALPH.md prune. |
| `INVARIANTS.md` + `packages/keel-invariants/src/invariants.manifest.ts` | No `INV-ralph-doc-budget` row | **Out of scope** for this proposal — registration is gated on Phase 2 + 10 clean iterations per Story 3.34 AC. Not a Day-1 manifest entry (would flap the Story 1.9 sync-gate). |

### Technical Impact

- **No code shipped by this proposal.** Spec deltas only. Story 3.34 will be drafted/validated/atdd-scaffolded/dev'd through the normal Ralph lifecycle when Epic 3 starts.
- **Implementation footprint** (forecast for Story 3.34, recorded for handoff fidelity):
  - `ralph.py` — new `_build_doc_budget_block(env)` ~30 lines mirroring `_build_issue_tracking_block` at `ralph.py:1622`; new env-var injection alongside `:1639,1761`; new `git config core.hooksPath .githooks` near `:141`.
  - `.githooks/pre-commit-ralph-budget` — new file (~50 lines bash); reads same threshold constants as the orient-gate.
  - `$RALPH_BASE_DIR/logs/sizes.jsonl` — gitignored telemetry file (Phase 0 / Story 3.15 absorption).
  - `RALPH.md` one-shot prune — pre-condition for Phase 2 in `warn` mode (otherwise hook fires on every commit).
- **Risk classification** (per Story 3.34 internal): blast radius is limited to Ralph's own loop hygiene; failure mode is "false-positive flake on knowledge-file edits" caught by the < 5% FP precondition.

---

## Section 3 — Recommended Approach

### Path forward: **Option 1 — Direct Adjustment**

| Option | Viability | Why |
| --- | --- | --- |
| **1. Direct Adjustment** (amend FR14j + insert Story 3.34 + cross-ref 3.15/3.22/3.23) | **VIABLE — selected** | Fits within existing Epic 3 boundary; zero re-numbering; preserves Phase 0/1/2 architectural primacy ("Phase 1 is PRIMARY; Phase 2 is belt-and-braces") consensus from the 4-agent roundtable. |
| 2. Potential Rollback | Not viable | Nothing has shipped to roll back; Epic 3 is fully in backlog. |
| 3. PRD MVP Review | Not viable / not warranted | This is a Ralph-loop-hygiene change, not an MVP scope change. Keel 1.0 MVP is unaffected; FR14j is unchanged in spirit (additive clause only). |

### Rationale for Option 1

- **Effort:** Low. Spec deltas only — five files (PRD, architecture.md, epics.md, sprint-status.yaml, this proposal). One Story 3.34 implementation lands later under normal Ralph loop.
- **Risk:** Low. Additive amendments to FR14j and Story-3.15/3.22/3.23 ACs; new Story 3.34 is purely append; no dependency reshuffling.
- **Timeline:** No M-stage shift. Epic 3 remains in current sequencing (post-Epic 2). Phase 0 instrumentation is the only piece that ships *during* Story 3.15 implementation; Phase 1 + 2 ship in Story 3.34.
- **Sustainability:** Single-source-of-truth threshold constants prevent the "two divergent doc-budget implementations" failure mode. Per the roundtable's architectural primacy declaration: future readers cannot drop Phase 1 once Phase 2 lands; both are documented as complementary.
- **Stakeholder alignment:** Issue #231 was authored as input *for* this skill; the deliberation already happened (Paige / Winston / Amelia / Murat consensus). This proposal is the BMad-artefact realisation of that consensus.

### Trade-offs explicitly considered

- **Splitting Phase 1 + Phase 2 across multiple stories** (3.22 + 3.23 + new 3.34): rejected. The phases share threshold constants, env-var state machine, and the `_build_doc_budget_block` injection point. Splitting fragments the single-source-of-truth design that the roundtable converged on. Single new Story 3.34 owns both phases.
- **Phase 0 as a dedicated 3.34a story**: rejected. Phase 0 is pure measurement (logging to `sizes.jsonl`); it ships zero gate. Story 3.15 already owns per-iteration JSON-on-disk telemetry; adding `sizes.jsonl` there is one AC, not a new story.
- **Cross-referencing into Story 3.8 (`@plan.md` schema)** instead of touching 3.34: rejected. Story 3.8 governs schema *shape* (NOW/QUEUE/BLOCKED/DONE/Context); doc-budget is *size enforcement against the schema-shaped content*. Different concerns.
- **Day-1 invariants manifest registration** (`INV-ralph-doc-budget` in `INVARIANTS.md` + `packages/keel-invariants/src/invariants.manifest.ts`): rejected. Per Amelia's roundtable note — Day-1 registration would flap the Story 1.9 sync-gate during the calibration window. Registration is conditional on Phase 2 + 10 clean iterations (Story 3.34 AC).

---

## Section 4 — Detailed Change Proposals

### 4.1 — PRD amendment

**Artifact:** `_bmad-output/planning-artifacts/prd.md`
**Section:** Functional Requirements → Autonomous Agent Loop → FR14j (line 958) + § Knowledge-file upkeep contract (lines 760–770)

**FR14j — additive clause:**

```
OLD (line 958, FR14j):
- **FR14j (Knowledge-file upkeep contract)**: Agent can maintain three audience-scoped
  knowledge files (`RALPH.md` private journal, `AGENTS.md` shared operational, `CLAUDE.md`
  Claude-Code-specific) with pinned promotion rules. Iterations that produce non-obvious
  learnings update at least one file and commit the change alongside the work. Promotion
  rule: learnings applying to every agent go to `AGENTS.md`; Claude-Code-specific
  behaviour goes to `CLAUDE.md`; Ralph-flavoured notes stay in `RALPH.md`. Normative
  spec: § Agent Workflow Contracts → Knowledge-file upkeep contract.

NEW (line 958, FR14j with additive clause):
- **FR14j (Knowledge-file upkeep contract)**: Agent can maintain three audience-scoped
  knowledge files (`RALPH.md` private journal, `AGENTS.md` shared operational, `CLAUDE.md`
  Claude-Code-specific) with pinned promotion rules. Iterations that produce non-obvious
  learnings update at least one file and commit the change alongside the work. Promotion
  rule: learnings applying to every agent go to `AGENTS.md`; Claude-Code-specific
  behaviour goes to `CLAUDE.md`; Ralph-flavoured notes stay in `RALPH.md`. **Doc-budget
  enforcement (2026-04-25 amendment per issue #231):** knowledge files and `.ralph/@plan.md`
  carry numeric size guardrails (bytes, lines, per-bullet words) consumed by a single
  source of truth — Phase 1 orient-gate (PRIMARY defense; soft warn injected into the
  loaded `PROMPT_build.md`) and Phase 2 pre-commit hook (belt-and-braces; numeric
  double-bound, ungameable by prose density). Both phases consume the same threshold
  constants; the env var `RALPH_DOC_BUDGET_ENFORCE = off | warn-in-prompt | halt-in-prompt`
  selects the consumer; emergency override via `RALPH_DOC_BUDGET_OVERRIDE=<bytes>`. Phase 1
  ships first; Phase 2 gates on (a) ≥ 20 healthy iterations recorded in `$RALPH_BASE_DIR/logs/sizes.jsonl`,
  (b) P90 ≥ 30% below the proposed hard cap, (c) Phase-1 false-positive rate < 5%. Story 3.34
  in Epic 3 owns the implementation; Story 3.15 owns the telemetry instrumentation.
  Future readers MUST treat Phase 1 and Phase 2 as complementary — not escalating —
  and MUST NOT drop Phase 1 as redundant once Phase 2 lands. Normative spec:
  § Agent Workflow Contracts → Knowledge-file upkeep contract.
```

**§ Knowledge-file upkeep contract — additive paragraph (after line 770):**

```
NEW PARAGRAPH (insert after line 770, before § Crash-journal contract):

**Doc-budget enforcement.** Knowledge files and `.ralph/@plan.md` are size-bounded
mechanically, not advisory: a single threshold-constants block governs (a) a soft
orient-gate injected into `PROMPT_build.md` by `ralph.py` at iteration start
(`_build_doc_budget_block()`) and (b) a numeric pre-commit hook
(`.githooks/pre-commit-ralph-budget`). The env var `RALPH_DOC_BUDGET_ENFORCE`
selects the active consumer (`off` | `warn-in-prompt` | `halt-in-prompt`); the env
var `RALPH_DOC_BUDGET_OVERRIDE=<bytes>` is the documented emergency-merge path.
Telemetry in `$RALPH_BASE_DIR/logs/sizes.jsonl` (gitignored) records per-iteration
sizes for empirical threshold tuning. Phase rollout is described in FR14j;
Epic 3 Story 3.34 is the implementation; Story 3.15 owns the telemetry shape.
Decay rule: every `RALPH.md` bullet carries an `<!-- iter:N -->` HTML comment;
bullets older than 30 iterations are pruner-deletable. Per-section FIFO caps
(§ Signposts ≤ 20, § Lessons ≤ 15, § Gotchas ≤ 10) are structurally
ungameable. Rationale and full rejected-alternatives list: issue #231.
```

**Rationale.** The amendment is additive (no behavioural change to any other FR), pins the architectural primacy of Phase 1 ("PRIMARY defense"), records the two-criteria precondition for Phase 2 to ship, and binds story ownership without fragmenting the implementation across multiple stories.

---

### 4.2 — Architecture amendment

**Artifact:** `_bmad-output/planning-artifacts/architecture.md`
**Section:** § Ralph Loop Contracts (architecture-owned implementation) → R4. Knowledge-file upkeep contract (line ~419)

**Extend R4 with the following appended paragraphs:**

```
NEW (append to R4, after current text):

**Doc-budget enforcement (issue #231 amendment, 2026-04-25).** R4 extends to size-bounding
the three knowledge files plus `.ralph/@plan.md` mechanically. Two complementary surfaces
share a single threshold-constants block:

- **Phase 1 — soft orient-gate (PRIMARY defense).** `ralph.py` adds
  `_build_doc_budget_block(env)` mirroring the pattern at `_build_issue_tracking_block()`
  (`ralph.py:1622`). On threshold trip, a `## PRUNE-FIRST (advisory)` block is injected
  into the loaded `PROMPT_build.md` before agent invocation. This is upstream of the ~80K
  orient read; the only intervention that prevents bloat from being read in the first place.
- **Phase 2 — pre-commit gate (belt-and-braces).** `.githooks/pre-commit-ralph-budget`
  enforces a numeric double-bound (bytes AND lines) ungameable by prose density. Wired via
  `git config core.hooksPath .githooks` in `ralph.py` startup (alongside the
  `RALPH_BASE_DIR` export at `ralph.py:141`). Both phases read the SAME threshold constants.

**Env-var contract (extends R7's environment-variable surface).** Two new vars:

| Variable                       | Values                                | Purpose                                                |
| ------------------------------ | ------------------------------------- | ------------------------------------------------------ |
| `RALPH_DOC_BUDGET_ENFORCE`     | `off` \| `warn-in-prompt` \| `halt-in-prompt` | Selects Phase-1 / Phase-2 active consumer; default `warn-in-prompt` |
| `RALPH_DOC_BUDGET_OVERRIDE`    | `<int bytes>`                         | Emergency-merge override for Phase 2 hook              |

**Telemetry — `sizes.jsonl`.** `$RALPH_BASE_DIR/logs/sizes.jsonl` (gitignored, schema in
Story 3.15) records one JSON line per iteration:

```
{
  "iter": <int>,
  "ts": "<ISO8601>",
  "ralph_md_bytes": <int>,
  "ralph_md_lines": <int>,
  "plan_md_bytes": <int>,
  "plan_md_lines": <int>,
  "signpost_word_counts": [<int>, ...],
  "done_entry_word_counts": [<int>, ...],
  "orient_phase_tokens": <int>,
  "line_delta_from_prev": <int>
}
```

The last two fields are leading + lagging indicators for the post-ship monitoring
described in Story 3.34's threshold-tuning AC. Retention: untrimmed at 1.0; rotation
policy is a future per-fork concern, not substrate.

**Phase 2 ship preconditions (architecture-binding, NOT advisory).** Phase 2 MUST NOT
move from `warn` to `halt` until ALL of:

1. ≥ 20 HEALTHY iterations recorded in `sizes.jsonl`.
2. P90 of recorded sizes is ≥ 30% below the proposed hard cap (prevents calibrating
   to a too-loose budget).
3. Phase-1 soft-gate false-positive rate < 5% on healthy-baseline replay (prevents the
   "Ralph learns padding patterns under the cap" flakiness trap).

Failing any precondition keeps Phase 2 off; threshold iteration uses the telemetry data.
This sequencing is architectural, not optional — see § R6 (flake measurement layer)
precedent for the "ship measurement at 1.0; ship enforcement after empirical baseline"
pattern.

**Affects:** `ralph.py` (`_build_doc_budget_block`, env-var injection, hooksPath
registration), `.githooks/pre-commit-ralph-budget`, `$RALPH_BASE_DIR/logs/sizes.jsonl`,
`packages/keel-invariants/src/invariants.manifest.ts` (`INV-ralph-doc-budget` registered
ONLY after Phase 2 + 10 clean iterations), `INVARIANTS.md` (new
`### Ralph loop hygiene` section + anchor bullet at the same milestone), Story 3.15
(telemetry — Phase 0 absorption), Story 3.22 (cross-ref), Story 3.23 (threshold-constants
coordination), **new Story 3.34** (implementation owner).
```

**Rationale.** R4 is the existing home for knowledge-file contracts; the amendment keeps the architectural primacy declaration ("Phase 1 is PRIMARY") visible to any future architecture reader, pins the env-var contract alongside the existing `RALPH_BASE_DIR` from R7, and binds the Phase-2 preconditions architecturally so they cannot be relaxed in implementation iterations without an architecture amendment.

---

### 4.3 — Epics amendment

**Artifact:** `_bmad-output/planning-artifacts/epics.md`
**Section:** Epic 3 — append after Story 3.33

**INSERT new Story 3.34** (full text):

```
##### Story 3.34: Ralph doc-budget enforcement (orient-gate + pre-commit gate)

As a substrate maintainer,
I want a single-source-of-truth doc-budget enforcement chain — Phase 1 soft orient-gate
(PRIMARY defense; injected into PROMPT_build.md by ralph.py) and Phase 2 pre-commit hook
(belt-and-braces; numeric double-bound) — both consuming the same threshold constants and
selectable via `RALPH_DOC_BUDGET_ENFORCE`, with an emergency `RALPH_DOC_BUDGET_OVERRIDE`
escape hatch,
So that `RALPH.md` and `.ralph/@plan.md` cannot silently inflate past the per-iteration
orient budget — preserving Ralph loop reliability monotonically (FR14j amendment per
issue #231).

**Acceptance Criteria:**

**Given** `ralph.py` has the `_build_issue_tracking_block()` pattern at `:1622`,
**When** I read the harness,
**Then** a parallel `_build_doc_budget_block(env)` function exists, invoked from the
same env-injection site (`:1639,1761`)
**And** it reads `RALPH.md`, `.ralph/@plan.md`, `.ralph/PROMPT_build.md`, `.ralph/PROMPT_plan.md`
sizes (bytes + lines + per-bullet words)
**And** trips when ANY of the threshold tuple is exceeded.

**Given** `RALPH_DOC_BUDGET_ENFORCE=warn-in-prompt` (default),
**When** the threshold is tripped,
**Then** a `## PRUNE-FIRST (advisory)` block is injected into the loaded
`PROMPT_build.md` before the agent invocation
**And** the block names the offending file + which dimension(s) tripped + the
target reduction.

**Given** `RALPH_DOC_BUDGET_ENFORCE=halt-in-prompt` AND Phase 2 preconditions met,
**When** the threshold is tripped,
**Then** the block converts to a halt directive
**And** the pre-commit hook is active.

**Given** `RALPH_DOC_BUDGET_ENFORCE=off`,
**When** the function runs,
**Then** no injection; pre-commit hook is bypassed.

**Given** `.githooks/pre-commit-ralph-budget` exists,
**When** the orchestrator starts,
**Then** `git config core.hooksPath .githooks` is registered alongside the
`RALPH_BASE_DIR` export near `ralph.py:141`
**And** the registration emits a one-line confirmation to the session log
**And** missing registration is a loud failure, not a silent no-op (`uv run ralph.py`
exits non-zero if registration fails).

**Given** the pre-commit hook fires,
**When** byte AND line counts are read,
**Then** the hook reads the SAME threshold constants as `_build_doc_budget_block`
(no parallel implementation)
**And** the hook is ungameable by prose density (numeric double-bound).

**Given** `RALPH_DOC_BUDGET_OVERRIDE=<bytes>` is set,
**When** the pre-commit hook runs,
**Then** the override is honoured for the current commit only
**And** the override usage is logged to `$RALPH_BASE_DIR/logs/budget-overrides.jsonl`
with the commit SHA, ISO8601 timestamp, and the override value.

**Given** the rubric-by-example replaces prose rules in `PROMPT_build.md` step 3a,
**When** I read the prompt,
**Then** three exemplar entries (1 Lesson / 1 Gotcha / 1 Decision, ≤ 12 words before
commit-SHA / PR pointer) demonstrate the target shape
**And** the IP DONE template tightens to `- [iter-N] <verb> <object> — <sha7> (PR #N)`
with a 12-word hard cap before the pointer
**And** Guardrail 8 in `PROMPT_build.md` extends to name `RALPH.md` (currently
mentions `AGENTS.md` only).

**Given** `RALPH.md` bullets carry `<!-- iter:N -->` decay markers,
**When** the pruner runs,
**Then** bullets where `current_iter − N > 30` are deletable per pure age rule
**And** per-section FIFO caps (§ Signposts ≤ 20, § Lessons ≤ 15, § Gotchas ≤ 10)
are documented as structural caps (not LLM-judged).

**Given** Phase 2 ship preconditions,
**When** the operator promotes `RALPH_DOC_BUDGET_ENFORCE` from `warn-in-prompt` to
`halt-in-prompt`,
**Then** ALL THREE preconditions MUST hold:
- ≥ 20 HEALTHY iterations recorded in `$RALPH_BASE_DIR/logs/sizes.jsonl`
- P90 of recorded sizes ≥ 30% below the proposed hard cap
- Phase-1 soft-gate false-positive rate < 5% on healthy-baseline replay
**And** the promotion PR records all three values inline; missing any → Phase 2 stays off.

**Given** Phase 2 has been active for ≥ 10 consecutive iterations with zero hook fires,
**When** the operator opens the manifest registration PR,
**Then** `INV-ralph-doc-budget` is added to `packages/keel-invariants/src/invariants.manifest.ts`
**And** a new `### Ralph loop hygiene` section + anchor bullet are added to `INVARIANTS.md`
**And** Story 1.9's sync-gate validates the manifest ↔ INVARIANTS.md drift on the same PR
**And** Day-1 registration is explicitly REJECTED (would flap the sync-gate during
calibration; precedent: Story 3.14 / FR14a3 contract-at-1.0-enforcement-at-1.x).

**Given** a one-shot RALPH.md prune is the precondition for Phase 2 to ship in
`warn-in-prompt` mode without firing on every commit,
**When** the prune iteration runs,
**Then** `RALPH.md` is reduced to under the proposed hard cap before
`RALPH_DOC_BUDGET_ENFORCE=warn-in-prompt` defaults are merged
**And** the pruned content is NOT archived to a new file (per Paige's roundtable
rejection: archives become the next bloat vector; git log is the archive).

**Given** the implementation rejects alternatives explicitly,
**When** I read the story,
**Then** the rejected-alternatives list (archive files, YAML frontmatter scoring,
LLM-as-judge filtering, in-prompt forbidden-words lists, periodic retro mode,
separate `PRUNE_RUBRIC.md` file) is recorded in the story body for future
re-readers — explicit rejection prevents zombie-resurrection.

**Implementation refs:** `ralph.py:141` (hooksPath registration site), `ralph.py:1622`
(injection-block pattern to mirror), `ralph.py:1639,1669,1761,1763` (env-var injection
sites), `packages/keel-invariants/src/invariants.manifest.ts` (deferred manifest entry),
`INVARIANTS.md` (deferred anchor bullet).

**Out of scope:** Phase 0 telemetry instrumentation (`sizes.jsonl` schema + writer) is
absorbed by Story 3.15 — same JSON-on-disk site, same per-iteration write cadence.
Cross-references in Story 3.22 (FR14j upkeep) and Story 3.23 (L3 lint guardrails)
acknowledge this story but do not duplicate implementation.
```

**INSERT cross-references in Story 3.15 ACs** (existing Story 3.15 — Per-iteration context meter, line ~2340):

```
APPEND TO STORY 3.15 ACs (Phase 0 absorption):

**Given** `$RALPH_BASE_DIR/logs/sizes.jsonl` is the doc-budget telemetry sibling of
`context-meter.json` (issue #231 / Story 3.34 Phase 0),
**When** the iteration footer runs,
**Then** `sizes.jsonl` is appended with one JSON line per iteration matching the
schema:
```
{iter, ts, ralph_md_bytes, ralph_md_lines, plan_md_bytes, plan_md_lines,
 signpost_word_counts[], done_entry_word_counts[], orient_phase_tokens,
 line_delta_from_prev}
```
**And** the file is gitignored
**And** `orient_phase_tokens` + `line_delta_from_prev` are leading + lagging
indicators for the threshold-tuning logic in Story 3.34
**And** the writer is the SAME footer that emits `context-meter.json` — no
separate write site.

**Given** the schema is invariant,
**When** Story 1.8 tracks it,
**Then** `INV-ralph-sizes-log-schema` is registered alongside
`INV-ralph-context-meter-schema`.
```

**INSERT cross-reference clauses in Stories 3.22 and 3.23** (narrow additions only):

```
APPEND TO STORY 3.22 ACs (after the existing AC block):

**Given** Story 3.34 ships the orient-gate + pre-commit hook for size enforcement,
**When** I read the upkeep contract,
**Then** Story 3.22 (warn-on-no-update) and Story 3.34 (warn-on-bloat) are
acknowledged as complementary — upkeep ensures *something* is written; budget
ensures *not too much*
**And** both hooks share the `.githooks/` directory (single hooksPath).

APPEND TO STORY 3.23 ACs (after the existing AC block):

**Given** Story 3.34 introduces a single threshold-constants block,
**When** `tools/lint-knowledge-files.ts` enforces RALPH.md size,
**Then** the linter reads the SAME constants as Story 3.34's `_build_doc_budget_block`
and `.githooks/pre-commit-ralph-budget` (no parallel byte/line definitions)
**And** the existing 500-line cap migrates to the threshold constants with the new
byte/per-bullet dimensions
**And** the linter's "RALPH.md exceeds 500 lines" message is rephrased to "RALPH.md
exceeds the doc-budget threshold" pointing to issue #231 / Story 3.34's rationale.
```

---

### 4.4 — Sprint status amendment

**Artifact:** `_bmad-output/implementation-artifacts/sprint-status.yaml`
**Section:** `epic-3:` block — append after `3-33-default-textual-tui-chrome-epic-7-re-theme-seam`

```
APPEND BEFORE `epic-3-retrospective` line:
  3-34-ralph-doc-budget-orient-gate-pre-commit-gate: backlog
```

---

## Section 5 — Implementation Handoff

### Scope classification: **Moderate**

Per `/bmad-correct-course` workflow:

| Classification | Triggers | Handoff |
| --- | --- | --- |
| Minor | Direct implementation by Dev | — |
| **Moderate** | **Backlog reorganisation needed** | **Product Owner / Dev coordination** |
| Major | Fundamental replan | PM / Architect |

This proposal touches: PRD (FR14j amendment), architecture (R4 extension), epics (new Story 3.34 + cross-refs), sprint-status (new entry). No PRD MVP scope shift; no architecture pattern reset; no FR rewrites — additive amendments only.

### Recipients & responsibilities

| Recipient | Responsibility | Deliverable |
| --- | --- | --- |
| **PM (John) — async** | Spot-check FR14j amendment language is consistent with the rest of FR14a–n style. Lightweight; no PRD re-validation cycle required (additive clause only). | Read this proposal § 4.1; confirm or comment. |
| **Architect (Winston) — async** | Spot-check R4 extension consistency with R7 env-var pattern + R6 measurement-before-enforcement precedent. | Read this proposal § 4.2; confirm or comment. |
| **PO / Dev orchestration** | Apply the four spec deltas (§§ 4.1–4.4) on the worktree branch; commit; push; open PR vs `feat/epic-2-packaged-devbox`. | Spec edits + PR. |
| **Story 3.34 future ownership** | When Epic 3 starts, Story 3.34 enters the normal Ralph lifecycle (drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done). | Standard story execution under Epic 3 build mode. |
| **One-shot RALPH.md prune** | A separate iteration *post-merge* of this proposal: trim `RALPH.md` to under the proposed hard cap before `RALPH_DOC_BUDGET_ENFORCE=warn-in-prompt` defaults to active. Not folded into this PR — keeps spec change reviewable in isolation. | Follow-up iteration, separate commit, same Epic-2 branch lineage or main. |

### Success criteria

- ✅ This proposal lands on `feat/epic-2-packaged-devbox` via a new branch + PR; bench review passes.
- ✅ Spec deltas in §§ 4.1–4.4 applied verbatim — single source of truth preserved.
- ✅ FR14j amendment names Phase 1 / Phase 2 architectural primacy and the two-criteria precondition.
- ✅ Story 3.34 is appended (not split) to keep `_build_doc_budget_block` + hook + threshold constants in one implementation envelope.
- ✅ Stories 3.15 / 3.22 / 3.23 receive narrow cross-reference additions only — no scope drift.
- ✅ INVARIANTS.md and `packages/keel-invariants/src/invariants.manifest.ts` are NOT touched by this proposal — registration is gated on Phase 2 + 10 clean iterations per Story 3.34's deferred-registration AC.
- ✅ One-shot RALPH.md prune is staged as a follow-up iteration, not bundled.

### Out-of-scope reminders (do not let scope creep here)

- Authoring `_build_doc_budget_block(env)` Python code → Story 3.34 implementation iteration.
- Editing `.ralph/PROMPT_build.md` step 3a rubric-by-example, Guardrail 8, IP DONE template → Story 3.34 implementation iteration.
- Editing `RALPH.md` content for the one-shot prune → separate follow-up iteration.
- Registering `INV-ralph-doc-budget` in the invariants manifest → deferred per Story 3.34 AC.

---

## Section 6 — Mid-flight scope correction (user-driven, 2026-04-25)

**User pushback:** "Why is the work scoped to epic3? We need it NOW."

The original proposal deferred the implementation to Story 3.34 in Epic 3 backlog. This was the wrong cut: defect probability on the gap is ≈1.0 and compounds every iteration; pushing the implementation behind 33 prior Epic-3 stories means the gate doesn't bite for weeks/months while bloat keeps accumulating. The course correction itself was being course-corrected.

### Pivot

**Implementation lands NOW**, on `chore/course-correct-doc-budget-231`, in the same PR as this proposal:

- `ralph.py` — `_build_doc_budget_block(env)` mirroring `_build_issue_tracking_block()`; env vars `RALPH_DOC_BUDGET_ENFORCE` (default `warn-in-prompt`) + `RALPH_DOC_BUDGET_OVERRIDE`; `_write_sizes_telemetry()` emits `$RALPH_BASE_DIR/logs/sizes.jsonl` per-iteration footer (Phase 0).
- `.githooks/doc-budget.json` — SSOT thresholds (`max_bytes` + `max_lines` per file); shared verbatim by `ralph.py` and the hook script — no parallel implementation.
- `tools/check-ralph-doc-budget.sh` — Phase 2 hook (warn-only at default; halt-blocking when `RALPH_DOC_BUDGET_ENFORCE=halt-in-prompt`).
- `.pre-commit-config.yaml` — new `ralph-doc-budget` hook entry (chosen over `core.hooksPath .githooks` because the repo already runs prek for pre-commit; bypassing prek with `core.hooksPath` would silently disable the existing typecheck/lint/format/keel-invariants gates — strictly worse).

Architectural primacy preserved: Phase 1 orient-gate is PRIMARY (upstream of orient read); Phase 2 hook is belt-and-braces. Phase 2 promotion to `halt-in-prompt` mode (and manifest registration of `INV-ralph-doc-budget`) genuinely still gates on data: ≥ 20 healthy iters in `sizes.jsonl`, P90 ≥ 30% below cap, FP < 5%. That's not Epic-3 sequencing — that's empirical preconditions, which is what the architecture R6 (flake measurement layer) precedent calls for.

### Spec delta revisions (applied to §§ 4.1–4.4 above)

- **PRD FR14j** — replaced "Story 3.34 in Epic 3 owns the implementation" with "Implementation lands on the same branch as this PRD edit".
- **Architecture R4** — replaced `.githooks/pre-commit-ralph-budget` (git-native hook) with `tools/check-ralph-doc-budget.sh` wired as a `.pre-commit-config.yaml` entry — concrete environment match. Threshold SSOT path moved to `.githooks/doc-budget.json` (read-only data file, no hook script there).
- **Sprint status** — `3-34-ralph-doc-budget-orient-gate-pre-commit-gate: backlog` flipped to `: done`.

### What still ships in a follow-up

- **One-shot RALPH.md prune.** RALPH.md is ~1.15 MB on this branch (633 lines). Phase 1 default `warn-in-prompt` will fire on every iteration until pruned. The prune is its own focused iteration (delete bullets where `current_iter − N > 30`; per-section FIFO caps; not in this PR's scope per "/bmad-correct-course owns spec, not RALPH.md content" boundary).
- **Phase 2 promotion** to `halt-in-prompt` — gates on the empirical preconditions; happens after ≥20 healthy iters with the gate active in `warn-in-prompt`.
- **Manifest registration** — `INV-ralph-doc-budget` enters `packages/keel-invariants/src/invariants.manifest.ts` + `INVARIANTS.md` after Phase 2 promotion + 10 clean iterations.

### Concrete actions (this session)

1. ✅ Apply spec deltas to `prd.md`, `architecture.md`, `epics.md`, `sprint-status.yaml`.
2. ✅ Add `.githooks/doc-budget.json` (SSOT).
3. ✅ Add `tools/check-ralph-doc-budget.sh` (smoke-tested all three modes).
4. ✅ Wire hook into `.pre-commit-config.yaml`.
5. ✅ Add `_build_doc_budget_block()` + `_write_sizes_telemetry()` to `ralph.py`; wire env injection at iteration start, telemetry at iteration end.
6. ⏭ Commit on `chore/course-correct-doc-budget-231`.
7. ⏭ Push branch.
8. ⏭ Open PR vs `feat/epic-2-packaged-devbox` (stacks with PR #230).

Workflow complete (with mid-flight pivot to ship-NOW).
