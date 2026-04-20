# Implementation Plan

## NOW

- [ ] Fix #1/1 (iter-18 finding) — restore `automated` qualifier in trace md YAML `waiver.reason` at line 513 from `'per-AC coverage deferred'` to `'per-AC automated coverage deferred'`, matching sibling JSON `1-7-e2e-trace-summary.json:105`; tick matching `[ ]` Review-Findings ledger entry to `[x]` with `**Resolved iter-19 (fix #1/1):**` sentence in SAME commit per iter-15 bookkeeping gotcha. ~small

## QUEUE (Story 1.7 — fixes-pending → sm-verified → done → PR transition)

- [ ] Story State `fixes-pending` → Re-run `/bmad-code-review (args: "2")` — confirm iter-18 MEDIUM finding cleared; expect `fixes-pending → sm-verified → done` on zero new findings OR another fix cycle on any new finding. ~medium
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

## DONE (Story 1.7 iter-18)

- [x] **CR re-re-re-review — `/bmad-code-review (args: "2")` three-layer fan-out on POST-iter-16+iter-17 diff; 1 NEW patch finding queued + 1 new defer + 2 dismissed; Story State stays `fixes-pending`.** Ralph-hosted fan-out per iter-7/12/15 precedent: `/tmp/story-1-7-review-diff-iter18.txt` (1301 lines, 10 files, `.ralph/@plan.md` + `.ralph/logs/` excluded per scoped-diff discipline) → three parallel `Agent` calls (Blind Hunter as bmad-agent-architect diff-only, Edge Case Hunter as bmad-tea diff+project-read, Acceptance Auditor as bmad-agent-dev diff+spec). **Acceptance Auditor: APPROVED** (all 5 ACs PASS post-iter-16+iter-17; fixes touched trace-md:479/480/482 + story-file:148 only — zero knowledge-file diff). **Bookkeeping ledger check: PASS** — iter-16 resolved entry at line 217 with `[x]` + `**Resolved iter-16 (fix #1/2):**` sentence; iter-17 resolved entry at line 218 with `[x]` + `**Resolved iter-17 (fix #2/2):**` sentence (iter-15 gotcha compliance carried through). **Edge MEDIUM finding:** trace md YAML `waiver.reason` at line 513 reads `'per-AC coverage deferred'` but sibling JSON `1-7-e2e-trace-summary.json:105` reads `'per-AC automated coverage deferred'` — same drift class as iter-12 #1/2 and iter-15 #1/2 (sibling wording not surveyed); iter-16's qualifier-restore scope stopped at `recommendations:` bullets (lines 479/480/482) and did not extend outward to the adjacent `waiver.reason` field in the SAME md YAML block. Semantically load-bearing: Story 1.7 has *manual* Prettier coverage for AC-4, so `per-AC coverage deferred` overstates the deferral scope; `automated` is the correct narrowing. **Blind 3 LOW signals triaged:** (a) trace-md:829 citing AGENTS.md `(lines 15-20)` — dismissed as Blind diff-hunk line-number false positive (Auditor verified AGENTS.md table is at 15-20 exactly); (b) story-file Task 1/Task 2 skeleton tables' 48-char column-width vs landed 47-char — deferred as sealed-story-file documentary drift (AC-2 contract is about live-file mutual identity, not skeleton-vs-live identity); (c) `sprint-status.yaml last_updated: 2026-04-20 CR-iter-7 UTC` frozen across iter-8..iter-17 — dismissed as intentional static-anchor pattern matching `source_sha: 7b39060` (bumps only on `fixes-pending → done` transition per Story 1.5 precedent). **Carry-forward rule (third cumulative iter-15-signpost extension):** when fixing sibling-wording drift in field X of a YAML block, survey not just sibling JSONs for field X but ALSO adjacent fields X-1/X+1 etc. in the SAME md YAML block for the same drift class — iter-16's scope was too narrow; `waiver.reason` sits two sub-blocks after `recommendations:` in the same YAML fence and carried the identical `per-AC coverage` / `per-AC automated coverage` qualifier drop. Triage persisted into story-file Review Findings (iter-18 preamble + 1 new `[ ]` Patch entry + 1 new `[x]` Defer entry) + IP § Deferred (new cosmetic-skeleton defer entry). Story State `fixes-pending` unchanged; QUEUE now 2 items (fix + CR re-run). **Carry-forward:** iter-19 is the fix + bookkeeping `[x]`-tick + resolved-sentence in SAME commit (iter-15 gotcha); iter-20 is CR re-re-re-re-review; iter-21 is PR Draft→Open + EPIC_DONE halt. ~3 iterations remaining.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 CR-re-re-re-review-fixes-pending; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** fixes-pending
