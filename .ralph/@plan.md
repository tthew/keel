# Implementation Plan

## NOW

- [ ] Story 1.7 iter-16 — CR fix #1/2 md YAML qualifier drop — restore `automated` (AC-1/2, AC-3 bullets) and `hard` (AC-5 bullet) in `_bmad-output/test-artifacts/traceability/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:479-482` so the `recommendations:` list matches sibling JSONs verbatim ~small

## QUEUE (Story 1.7 — fixes-pending → sm-verified → done → PR transition)

- [ ] Story 1.7 iter-17 — CR fix #2/2 prose miscount — `s/Seven invariants/Nine invariants/` at `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:148` so prose matches enumeration (9 IDs) and closing `(Count: 9.)`. Tick the matching `[ ]` Review-Findings ledger item to `[x]` in the SAME commit (per iter-15 gotcha).
- [ ] Story State `fixes-pending` → Re-run `/bmad-code-review (args: "2")` — confirm iter-15 findings cleared (fix #1/2 qualifier drop + fix #2/2 Seven→Nine); expect `fixes-pending → sm-verified → done` on zero findings OR another `fixes-pending` cycle on any new finding.
- [ ] Story State `done` → Transition PR #224 Draft→Open — rewrite title/body for full spec+iter-1+iter-2+iter-3+Tasks-1-3+trace+SM-review+CR commit range; EPIC_DONE halt (mini-epic convention, 7th story-implementation precedent).

## BLOCKED

_(none)_

## Deferred (CR iter-7 + iter-12 + iter-15 — recorded per `defer: <reason>` rule)

- `1-7-gate-decision.json` lacks structured `waiver: {reason, approver, expiry, remediation_due}` sub-object; `rationale` prose present; structured waiver block IS present in `1-7-e2e-trace-summary.json` — **defer: trace-skill schema concern, not Story 1.7 scope; waiver-bearing file exists in the pair**.
- `architecture.md:891` shows idealised `packages/keel-invariants/src/` layout; on-disk is `packages/keel-invariants/` at package root (no `src/` parent for config files) — **defer: pre-existing architecture-doc gap predating Story 1.7; Story 1.8's manifest import will reconcile**.
- Trace md YAML `recommendations:` bullets are flat strings lacking `priority:` + `requirements:` sub-keys present in the two sibling JSON objects — **defer: structural projection concern, not wording drift; Story 1.9 FR43 sync-gate scope per Edge Case Hunter self-dismissal**.
- `_bmad-output/test-artifacts/traceability/1-7-e2e-trace-summary.json:10` pins `"source_sha": "7b39060"` to the Task 3 authoring commit, not regenerated on post-CR-fix iterations — **defer: intentional static anchor per iter-10/11/13/14 precedent; Story 1.9 sync-gate will reconcile content-hash drift if any**.

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artefact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-15)

- [x] **CR re-re-review via `/bmad-code-review (args: "2")` — Ralph-hosted three-layer fan-out on POST-iter-13/14-fix diff.** Scoped diff written to `/tmp/story-1-7-review-diff-iter15.txt` (1239 lines; excluded `.ralph/@plan.md` + logs + `RALPH.md`), three parallel Agent subagents (Blind Hunter as bmad-agent-architect diff-only; Edge Case Hunter as bmad-tea diff+project-read; Acceptance Auditor as bmad-agent-dev diff+spec). **Result:** Acceptance Auditor APPROVED (all 5 ACs unchanged); iter-13 JSON waiver-expiry fix + iter-14 md YAML AC-4 insertion both CONFIRMED verbatim across sibling triplet. Blind + Edge surfaced 2 NEW patch findings: (a) MEDIUM — md YAML `recommendations:` bullets at trace-md lines 479/480/482 drop qualifiers (`automated` for AC-1/2 + AC-3; `hard` for AC-5) that BOTH sibling JSONs retain — same drift-class as iter-12 #1/2, pre-existing gap not introduced by iter-14; (b) LOW — story-file:148 reads "Seven invariants" but enumerates 9 IDs and closes with `(Count: 9.)` — pre-existing prose miscount from skeleton authoring. 0 new defers (plus 2 new defers recorded above for structure + source_sha). 4 dismissals with evidence: sprint-status + story-file `Status: in-progress` are expected lifecycle states pending `fixes-pending → done` (will flip at Draft→Open transition per Story 1.5 precedent); `source_sha: 7b39060` is intentionally static per iter-10/11/13/14 precedent; md YAML's flat-string bullets vs JSON's priority/requirements objects is a structural projection not a wording drift (Edge Case self-deferred to Story 1.9 FR43 scope). **Also performed iter-13/14 bookkeeping catchup:** ticked story-file:213 `[x]` with iter-13 resolution note + story-file:214 `[x]` with iter-14 resolution note, closing the gap Blind Hunter flagged as MEDIUM. Extended story-file § Review Findings with iter-15 re-review preamble + 2 new `[ ]` patch lines. Both fix tasks queued to TOP of QUEUE per FR14n matrix row 10. Story State remains `fixes-pending` until QUEUE empties → re-run CR → confirm zero findings → `sm-verified → done`. **Carry-forward:** fix #1/2 (md YAML qualifier restore) is next NOW — 3 line edits in one YAML block. Fix #2/2 (Seven→Nine) is one-word edit + matching ledger tick. Then one more CR re-run iteration, then PR transition. ~4 iterations remaining to EPIC_DONE halt (fix#1, fix#2, CR-confirm, PR-transition). **New gotcha landed in RALPH.md:** fix iterations MUST `[x]`-tick their resolved ledger item in the same commit to avoid redundant CR MEDIUM flags.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 CR-re-re-review-fixes-pending; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** fixes-pending
