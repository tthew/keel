# Implementation Plan

## NOW

- [ ] Story 1.7 iter-17 — CR fix #2/2 prose miscount — `s/Seven invariants/Nine invariants/` at `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:148` so prose matches enumeration (9 IDs) and closing `(Count: 9.)`. Tick the matching `[ ]` Review-Findings ledger item to `[x]` in the SAME commit (per iter-15 gotcha). ~small

## QUEUE (Story 1.7 — fixes-pending → sm-verified → done → PR transition)

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

## DONE (Story 1.7 iter-16)

- [x] **CR fix #1/2 (iter-15 finding) — md YAML qualifier restore.** Restored `automated` (AC-1/2 + AC-3 bullets) and `hard` (AC-5 bullet) at `_bmad-output/test-artifacts/traceability/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:479-482` so all four `recommendations:` bullets read verbatim across the trace triplet (md YAML + `1-7-coverage-matrix.json:128/134/143` + `1-7-e2e-trace-summary.json:73/79/88`). Pre-fix md YAML had dropped `coverage`-vs-`automated coverage` and `enforcement`-vs-`hard enforcement` distinctions that semantically matter (Story 1.7's manual Prettier coverage for AC-4 + soft-warn RS6 carve-out per gate-decision rationale). Per iter-15 gotcha (`RALPH.md`), ticked the matching `[ ]` ledger item at `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:217` to `[x]` with verbatim post-fix line content in the SAME commit, avoiding redundant CR MEDIUM flag in the next re-review. Story State remains `fixes-pending` until QUEUE empties (1 fix left + CR re-run) → confirm zero findings → `sm-verified → done`. **Carry-forward:** fix #2/2 (story-file:148 `Seven → Nine`) is next NOW — one-word edit + ledger tick at story-file:218. Then CR re-run, then PR Draft→Open transition + EPIC_DONE. ~3 iterations remaining.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 CR-re-re-review-fixes-pending; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** fixes-pending
