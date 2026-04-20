# Implementation Plan

## NOW

- [ ] Story State `fixes-pending` → CR re-review iter-12 fix #1/2: Normalise `1-7-e2e-trace-summary.json:107` waiver `expiry` from `"On Story 1.9 sync-gate landing"` → `"deferred (expires when Story 1.9 sync-gate lands)"` to match iter-11 canonical md YAML form; run quality-gate bundle ~small

## QUEUE (Story 1.7 — CR re-review iter-12 fixes + re-run + PR transition)

- [ ] Story State `fixes-pending` → CR re-review iter-12 fix #2/2: Add AC-4 recommendation line to trace md YAML `recommendations:` list at lines 478-481 (`- 'Accept manual + Prettier review for AC-4; no planned automated coverage'`) to match sibling JSONs ~small
- [ ] Story State `fixes-pending` → Re-run `/bmad-code-review (args: "2")` — confirm iter-12 re-review findings cleared; Story State `fixes-pending → sm-verified → done` (no new findings) OR `fixes-pending` again (any new finding queues a fresh fix) ~medium
- [ ] Story State `done` → Transition PR #224 Draft→Open — rewrite title/body for full spec+iter-1+iter-2+iter-3+Tasks-1-3+trace+SM-review+CR commit range; EPIC_DONE halt (mini-epic convention, 7th story-implementation precedent)

## BLOCKED

_(none)_

## Deferred (CR iter-7 + iter-12 — recorded per `defer: <reason>` rule)

- `1-7-gate-decision.json` lacks structured `waiver: {reason, approver, expiry, remediation_due}` sub-object; `rationale` prose present; structured waiver block IS present in `1-7-e2e-trace-summary.json` — **defer: trace-skill schema concern, not Story 1.7 scope; waiver-bearing file exists in the pair**.
- `architecture.md:891` shows idealised `packages/keel-invariants/src/` layout; on-disk is `packages/keel-invariants/` at package root (no `src/` parent for config files) — **defer: pre-existing architecture-doc gap predating Story 1.7; Story 1.8's manifest import will reconcile**.

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artefact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-12)

- [x] **CR re-review via `/bmad-code-review (args: "2")` — Ralph-hosted three-layer fan-out on POST-FIX diff.** Followed iter-7's invocation pattern: scoped diff written to `/tmp/story-1-7-review-diff.txt` (1289 lines; excluded `.ralph/@plan.md` + logs), three parallel Agent subagents (Blind Hunter as bmad-agent-architect diff-only; Edge Case Hunter as bmad-tea diff+project-read; Acceptance Auditor as bmad-agent-dev diff+spec). **Result:** Acceptance Auditor APPROVED (all 5 ACs still PASS post-fix — iter-8/9/10/11 fixes did not regress any AC). Blind + Edge surfaced 2 NEW patch findings: (a) MEDIUM — waiver `expiry` in `1-7-e2e-trace-summary.json:107` still reads `"On Story 1.9 sync-gate landing"` while iter-11 canonicalised md YAML to `'deferred (expires when Story 1.9 sync-gate lands)'` — sibling JSON was out of scope of iter-11's md-only fix, now requires cross-artefact normalisation; (b) LOW — trace md YAML `recommendations:` at lines 478-481 enumerates only 3 items (AC-1/2, AC-3, AC-5) and omits AC-4 ("Accept manual + Prettier review for AC-4") while both sibling JSONs (`coverage-matrix.json:125-146`, `e2e-trace-summary.json:70-91`) include 4 entries. 0 new defers. 3 dismissals with evidence: sprint-status/story-file `in-progress` status is the expected lifecycle state per FR14n matrix row 10 (flip-back to `done` happens only after ALL findings clear, per iter-7 signpost); `forPackage()` "adds" vs "replaces" verb-wording nuance is semantically equivalent — the name-based anchor is drift-resistant regardless (ESLint last-match-wins means the forPackage override's no-restricted-imports replaces sharedBase's but the pattern-set end-state is identical; "adds AC 3's self-import pattern" accurately describes the net coverage even though the mechanism is replacement not layering); `line 141` § Testing Standards citation verified current (iter-7+ edits were appended to Dev Agent Record at file end, lines 1-141 unchanged — confirmed by re-reading story file lines 138-141). Both patches queued to TOP of QUEUE as fix #1/2 and #2/2 per FR14n matrix row 10. Story file § Review Findings extended with 2 new `[ ]` items + preamble paragraph for iter-12 triage. Story State remains `fixes-pending` until QUEUE empties → re-run CR → confirm zero findings → `sm-verified → done`. **Carry-forward:** fix #1/2 is next NOW — trivial single-line JSON string flip. Fix #2/2 adds one YAML line. Then one more CR re-run iteration, then PR transition. Estimated ~4 iterations remaining to EPIC_DONE halt (fix#1, fix#2, CR-confirm, PR-transition).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 CR-re-review-fixes-pending; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** fixes-pending
