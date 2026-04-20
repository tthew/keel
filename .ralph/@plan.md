# Implementation Plan

## NOW

- [ ] Story State `fixes-pending` → Re-run `/bmad-code-review (args: "2")` — confirm iter-18 MEDIUM finding cleared post-iter-19 fix; expect `fixes-pending → sm-verified → done` on zero new findings OR another fix cycle on any new finding. ~medium

## QUEUE (Story 1.7 — fixes-pending → sm-verified → done → PR transition)

- [ ] Story State `done` → Transition PR #224 Draft→Open — rewrite title/body for full spec+iter-1+iter-2+iter-3+Tasks-1-3+trace+SM-review+CR commit range; EPIC_DONE halt (mini-epic convention, 7th story-implementation precedent).

## BLOCKED

_(none)_

## Deferred (CR iter-7 + iter-12 + iter-15 + iter-18 — recorded per `defer: <reason>` rule)

- `1-7-gate-decision.json` lacks structured `waiver: {reason, approver, expiry, remediation_due}` sub-object; `rationale` prose present; structured waiver block IS present in `1-7-e2e-trace-summary.json` — **defer: trace-skill schema concern, not Story 1.7 scope; waiver-bearing file exists in the pair**.
- `architecture.md:891` shows idealised `packages/keel-invariants/src/` layout; on-disk is `packages/keel-invariants/` at package root (no `src/` parent for config files) — **defer: pre-existing architecture-doc gap predating Story 1.7; Story 1.8's manifest import will reconcile**.
- Trace md YAML `recommendations:` bullets are flat strings lacking `priority:` + `requirements:` sub-keys present in the two sibling JSON objects — **defer: structural projection concern, not wording drift; Story 1.9 FR43 sync-gate scope per Edge Case Hunter self-dismissal**.
- `_bmad-output/test-artifacts/traceability/1-7-e2e-trace-summary.json:10` pins `"source_sha": "7b39060"` to the Task 3 authoring commit, not regenerated on post-CR-fix iterations — **defer: intentional static anchor per iter-10/11/13/14 precedent; Story 1.9 sync-gate will reconcile content-hash drift if any**.
- Story-file Task 1 + Task 2 instructional-skeleton promotion-rule tables (`_bmad-output/implementation-artifacts/1-7-...md:240-245` + `:294-299`) carry a 48-char-wide second column vs the 47-char-wide Prettier-normalised column in the four live files (`INVARIANTS.md:11-16` / `AGENTS.md:15-20` / `CLAUDE.md:59-64` / `RALPH.md:17-22`) — **defer: sealed-story-file documentary drift (story dev-story at iter-4 sealed the skeleton; Prettier rewrote live files at Task 2's `pnpm format` pass); no enforcement loop reads instructional skeletons; AC-2's verbatim contract is about the four LIVE files' mutual-identity (PASS per iter-7/12/15/18 Auditor), not skeleton-vs-live identity**.

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artefact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-19)

- [x] **CR iter-18 fix #1/1 — restored `automated` qualifier in trace md YAML `waiver.reason` at line 513; ticked matching story-file Review-Findings ledger entry to `[x]` with `**Resolved iter-19 (fix #1/1):**` sentence in SAME commit per iter-15 bookkeeping gotcha.** Two-edit iteration: (1) `_bmad-output/test-artifacts/traceability/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:513` — `s/per-AC coverage deferred/per-AC automated coverage deferred/` so YAML now reads `reason: 'Documentation-artefact story; per-AC automated coverage deferred to Stories 1.8 / 1.9 + Epic 3 per § Scope Carve-Out + § Testing Standards'`, character-verbatim match with sibling JSON `1-7-e2e-trace-summary.json:105` modulo YAML single-quote vs JSON double-quote. (2) `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:221` — flipped `[ ]` → `[x]` on the `[Review-iter-18][Patch]` ledger entry and appended `**Resolved iter-19 (fix #1/1):**` resolved-sentence per iter-15 gotcha (resolved-sentence + `[x]`-tick + code edit in SAME commit). **Signpost discharge:** iter-15 "survey adjacent fields in SAME YAML block" rule now fully discharged across four sibling-wording drift classes — `expiry` (iter-13), AC-4 missing entry (iter-14), `automated`/`hard` qualifiers on `recommendations:` bullets (iter-16), `automated` qualifier on `waiver.reason` (iter-19). **Carry-forward:** iter-20 is CR re-re-re-re-review (`/bmad-code-review (args: "2")`) on the post-iter-18+iter-19 diff to confirm `fixes-pending → sm-verified → done` on zero new findings (or another fix cycle on any new finding); iter-21 is PR Draft→Open + EPIC_DONE halt. ~2 iterations remaining (if CR clean).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 CR-re-re-re-review-fixes-pending; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** fixes-pending
