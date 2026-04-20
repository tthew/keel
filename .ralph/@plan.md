# Implementation Plan

## NOW

- [ ] Fix C/4 [HIGH + MEDIUM] — count drift "three smokes" → "five smokes" + "AC 1+4+7 only" → "AC 1+2+4+5+7" across ~13 sites (single mechanical prose-swap; narrow-scope per iter-11 discipline does NOT apply here — the semantic is one coherent change, splitting fragments it). Target inventory:
  - spec:120 (trailing "AC 1 / AC 4 / AC 7 fully covered at the shell-invocation level" — iter-11 patched opening "five" but left closing AC-list stale → internal self-contradiction)
  - spec:149 ("three smoke tests materially cover 4 of 7 ACs end-to-end; remaining 3 are schema-level" → post-iter-8 reality: 5 smokes cover 5 of 7 ACs; AC-3 + AC-6 remain schema/structural)
  - trace md:307 + 349 + 436 + 465 + 526 + 555 + 583 + 614 (8 sites with "three" / "3 runtime smoke tests" / "AC-1 + AC-4 + AC-7 end-to-end")
  - coverage-matrix.json:160 + e2e-trace-summary.json:73 (2 sites with "Task 5 shell-invocation smoke tests already cover AC-1 + AC-4 + AC-7 end-to-end")
  - gate-decision.json:12 (rationale: "Task 5's three shell-invocation smoke tests exercised AC 1 + AC 4 + AC 7 end-to-end … AC 2 / AC 3 / AC 5 realised schema-level" — AC-2 + AC-5 now end-to-end post-iter-8; only AC-3 remains schema+structural). Pure prose — zero code changes. ~medium

## QUEUE (Story 1.9 — CR iter-14 re-run surfaced 3 fix tasks + 4 defers; stays `fixes-pending` until QUEUE empties → re-run CR)

- [ ] Re-run `/bmad-code-review (args: "2")` CR adversarial triage against post-Fix-A/B/C diff. Expected outcome per FR14n matrix row 10: zero Blind Hunter findings → `fixes-pending → sm-verified → done` (single-transition edge). If new findings surface, queue fix tasks; stay `fixes-pending`. ~medium

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7 through iter-16)

- [x] iter-7: `/bmad-code-review (args: "2")` Ralph-hosted three-layer fan-out — 6 patches + 10 defers + 3 dismissed. CRITICAL: `ANCHOR_REGEX` uppercase-class bug reproduced by Edge Case Hunter + Acceptance Auditor.
- [x] iter-8 through iter-13: 6 CR fix patches landed — (1) CRITICAL `ANCHOR_REGEX` uppercase→lowercase + symmetric `added-to-source-only` emitter + 2 new Task-5 smokes + spec echoes; (2) HIGH spec line 41 stdout→stderr; (3) HIGH count 7→8 sourcePath files; (4) HIGH count 2→5 runtime smokes (narrow-scope per iter-11); (5) MEDIUM trace-bundle line citations re-anchored (31 edits); (6) MEDIUM Dev Agent Record AC 2 status prose upgraded schema→end-to-end.
- [x] iter-14: `/bmad-code-review (args: "2")` CR RE-RUN — 3-layer Ralph-hosted fan-out against post-fix diff. Verdicts: Blind Hunter NEW_FINDINGS (3 HIGH trace residue + 1 MEDIUM spec self-contradiction → queued as Fix A/B/C); Edge Case Hunter MINOR_ONLY (4 LOWs → defers); Acceptance Auditor PASS (all 7 AC with live repros). Impl CLEAN; trace-narrative STALE. **New pattern established: trace-bundle semantic-drift from impl-upgrade.**
- [x] iter-15: Fix A/4 [HIGH] landing — stale UPPERCASE regex echo swap at 2 trace-bundle sites. `[A-Z][A-Z0-9-]+` → `INV-[a-z0-9]+(?:-[a-z0-9]+)+` at trace md:141 + coverage-matrix.json:69. JSON schema validation PASS. Pure prose — zero code changes.
- [x] **iter-16: Fix B/4 [HIGH] landing — stale "Not exercised in smoke" AC-5 framing refreshed at 3 sites.** Edited trace md:143 (AC-5 mapping bullet) + trace md:260 (Happy-Path-Only: "two P1 branches" → "one P1 branch (AC-3)") + coverage-matrix.json:69 substrate_verification tail. AC-5 claim flipped from "Not exercised in smoke" → "Exercised via iter-8 Task-5 docs-side orphan-anchor smoke (append `INV-fake-orphan` → exit 1 + `removed-from-docs-only`; revert; byte-identical restore)" per spec line 143 authoritative phrasing. AC-3 "not exercised in smoke" equivalents deliberately left untouched (iter-8 did NOT add an AC-3 smoke; only AC-2 + AC-5). coverage-matrix.json `coverage: NONE` + `tests: []` + `scope_notes: "Baseline now clean → AC 5 branch not actively triggered"` deliberately NOT flipped — those track test-runner-hosted coverage (still zero at Story 1.9; Story 1.16 backfills) and canonical/steady-state framing respectively. JSON re-validated clean. Pure prose — zero code changes. Story State: remains `fixes-pending` (Fix C + CR re-run still in QUEUE).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — iter-14 CR re-run surfaced 3 fix patches; Fix A + B landed iter-15/16; Fix C + CR re-run remaining)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on NEXT CR re-run zero-findings outcome per matrix row 9 single-transition edge.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-16 Fix B executed narrow-scope per iter-11 discipline.** Three edit sites, one semantic upgrade (AC-5 "not exercised" → "exercised via iter-8 smoke"). Did NOT extend to AC-3 equivalents (iter-8 did not add an AC-3 smoke) and did NOT flip coverage-matrix.json AC-5 `coverage: NONE`/`tests: []` — those are test-runner-hosted coverage fields, orthogonal to substrate-evidence. scope_notes line 70 also deliberately untouched (the "baseline clean" claim reads as canonical/steady-state, not post-iter-8 test state).
- **Fix B semantic:** iter-8's Task-5 smoke for AC-5 (append `INV-fake-orphan` anchor → exit 1 + `removed-from-docs-only`; revert; byte-identical restore) IS substrate-level evidence that the AC-5 drift branch works end-to-end, not just structurally. The trace bundle's "Not exercised in smoke" boilerplate was authored pre-iter-8 and never refreshed when iter-8 added the smoke — exactly the trace-bundle-semantic-drift-from-impl-upgrade pattern established iter-14.
- **Fix C scope is ~13 target sites across 5 artefacts** — single mechanical prose-swap like iter-10's 6-site swap + iter-12's 31-site re-anchor. Do NOT split into Fix C1/C2/C3 by artefact — the underlying change is one semantic ("post-iter-8 reality: 5 smokes covering AC 1+2+4+5+7 end-to-end; only AC-3 + AC-6 remain schema/structural"), and splitting would fragment a single coherent edit across iterations. Broad-scope is the right call here per iter-14's "bias toward broad-scope when the literal swap is mechanical AND all target sites are grep-enumerable" rule.
- **Fix C phrasing targets to standardise:**
  - cardinality: "three" / "3" smoke tests → "five" / "5" smoke tests
  - AC-coverage enumeration: "AC 1 + AC 4 + AC 7" / "AC-1 + AC-4 + AC-7" → "AC 1 + AC 2 + AC 4 + AC 5 + AC 7" / "AC-1 + AC-2 + AC-4 + AC-5 + AC-7"
  - schema-vs-end-to-end split: "AC 2 / AC 3 / AC 5 realised schema-level" → "AC 3 remains schema/structural; AC 6 remains CLI-contract-only"
- **Issue Tracking:** Story 1.9 issue number still unset at iter-16. Parent Epic 1 issue **#9** — `Refs #9` only.
