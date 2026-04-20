# Implementation Plan

## NOW

- [ ] Fix D/2 [MEDIUM] — broad-scope literal swap at 6 sites. Replace the stale phrase `AC-2 / AC-3 / AC-5 structural branches` with `AC-3 structural + AC-6 CLI-contract-only branches` (or `AC-3 structural-only + AC-6 CLI-contract-only residuals` at variance sites) so the 6 stakeholder/recommendation sites stop asserting AC-2 + AC-5 as structural after Fix B + Fix C already promoted them to end-to-end smoke-exercised. Sites: `_bmad-output/test-artifacts/traceability/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md:311`, `:477`, `:523`, `:560`; `_bmad-output/test-artifacts/traceability/1-9-coverage-matrix.json:175`; `_bmad-output/test-artifacts/traceability/1-9-e2e-trace-summary.json:88`. All JSON re-validate after edit. Pure prose — zero code changes. ~medium

## QUEUE (Story 1.9 — CR iter-18 re-run surfaced 2 fix tasks; Fix D MEDIUM is NOW; Fix E LOW next; then CR re-run #3)

- [ ] Fix E/2 [LOW] — single-line edit at `_bmad-output/test-artifacts/traceability/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md:319`. Drop the ` + AC-5 (removed-from-docs)` fragment so the Long-term-Actions recommendation reads "Story 1.16 can backfill smoke tests for AC-3 (removed-from-source) alongside unit coverage, closing the AC-3 structural-only posture at 1.9" (AC-5 is already end-to-end per spec:143 + iter-8 Fix B).
- [ ] Re-run `/bmad-code-review (args: "2")` CR adversarial triage against post-Fix-D+E diff. Expected outcome per FR14n matrix row 10 single-transition edge: zero findings across all 3 layers → `fixes-pending → sm-verified → done`. If new findings surface, queue fix tasks; stay `fixes-pending`.

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7 through iter-18)

- [x] iter-7: `/bmad-code-review (args: "2")` Ralph-hosted three-layer fan-out — 6 patches + 10 defers + 3 dismissed. CRITICAL: `ANCHOR_REGEX` uppercase-class bug reproduced by Edge Case Hunter + Acceptance Auditor.
- [x] iter-8 through iter-13: 6 CR fix patches landed — (1) CRITICAL `ANCHOR_REGEX` uppercase→lowercase + symmetric `added-to-source-only` emitter + 2 new Task-5 smokes + spec echoes; (2) HIGH spec line 41 stdout→stderr; (3) HIGH count 7→8 sourcePath files; (4) HIGH count 2→5 runtime smokes (narrow-scope per iter-11); (5) MEDIUM trace-bundle line citations re-anchored (31 edits); (6) MEDIUM Dev Agent Record AC 2 status prose upgraded schema→end-to-end.
- [x] iter-14: `/bmad-code-review (args: "2")` CR RE-RUN #1 — 3-layer fan-out against post-iter-8..13 fix diff. Blind Hunter NEW_FINDINGS (3 HIGH trace residue + 1 MEDIUM spec self-contradiction → queued as Fix A/B/C); Edge Case Hunter MINOR_ONLY (4 LOWs → defers); Acceptance Auditor PASS. Impl CLEAN; trace-narrative STALE. **New pattern established: trace-bundle semantic-drift from impl-upgrade.**
- [x] iter-15: Fix A/4 [HIGH] landing — stale UPPERCASE regex echo swap at 2 trace-bundle sites.
- [x] iter-16: Fix B/4 [HIGH] landing — stale "Not exercised in smoke" AC-5 framing refreshed at 3 sites.
- [x] iter-17: Fix C/4 [HIGH + MEDIUM] landing — broad-scope prose swap across 14+ sites (cardinality 3→5 + AC enumeration {1,4,7}→{1,2,4,5,7}).
- [x] **iter-18: `/bmad-code-review (args: "2")` CR RE-RUN #2 — 3-layer fan-out against post-Fix-A/B/C diff (`5a984e0..HEAD`, 192 lines across 5 artefacts).** Verdicts: Blind Hunter PASS (no falsifiable claims in 192-line diff — Fix A/B/C all applied correctly and consistently); Acceptance Auditor PASS (all 7 ACs consistent between spec Dev Agent Record and diff trace-narrative); Edge Case Hunter NEW_FINDINGS (1 MEDIUM + 1 LOW — Fix C missed 6 sites using the stale "AC-2 / AC-3 / AC-5 structural branches" phrasing → queued as Fix D; plus 1 stale "AC-5 backfill for Story 1.16" clause at trace.md:319 → queued as Fix E). Same semantic-drift-from-impl-upgrade class as Fix C; both literal broad-scope-or-narrow swaps. Review Findings section appended to story file per skill step-04 section 2 (option 2 "Leave as action items" pre-selected by `args: "2"`).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — iter-18 CR re-run #2 surfaced 2 fix patches; Fix D MEDIUM + Fix E LOW queued)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on NEXT CR re-run (iter-21 or later) zero-findings outcome per matrix row 10 single-transition edge.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-18 CR re-run found exactly what Ralph warned about iter-17.** iter-17 IP Notes: "Fix C carve-outs deliberately left untouched: ... coverage-matrix.json AC-5 `coverage: NONE` / `tests: []` / line-70 scope_notes — those track test-runner-hosted coverage (still zero at Story 1.9; Story 1.16 backfills) and canonical/steady-state framing respectively." Edge Case Hunter correctly identified that the "adversarial triage is the agreed backstop for AC-2 / AC-3 / AC-5 structural branches" line **is** steady-state recommendation prose (it lives in § Short-term Actions + § Stakeholder Communication + coverage-matrix `recommendations[]` + trace-summary `recommendations[]`), not test-runner-coverage framing. Those 6 sites should have been part of Fix C's broad-scope swap. Fix D reconciles the missed scope.
- **Fix D scope note — 6 sites, not 7.** Edge Case Hunter's intro said "7 steady-state sites" but the numbered list enumerated 6. Independent grep confirms 6 surviving sites with the exact phrase `AC-2 / AC-3 / AC-5 structural branches` — Fix D targets exactly those 6. trace.md:440 is a CORRECT Dev-Agent-Record-style AC-5 citation (post-Fix-B) and is NOT a target.
- **Fix E scope note — 1 site, surgical delete.** `trace.md:319` is the only site with "Story 1.16 can backfill smoke tests for AC-3 (removed-from-source) + AC-5 (removed-from-docs) ... closing the structural-only posture at 1.9". trace.md:440 is again correct (AC-5 now exercised end-to-end; the line describes what iter-8 smoke did, not what Story 1.16 needs to backfill). Surgical ` + AC-5 (removed-from-docs)` fragment drop + "the structural-only posture" → "the AC-3 structural-only posture" pronoun-specificity tighten.
- **CR re-run expectation after Fix D + Fix E land (iter-21 or later):** all three layers should return clean. Blind Hunter already PASS at iter-18; Acceptance Auditor already PASS at iter-18; Edge Case Hunter needs the last 6+1 sites cleaned. After that, FR14n matrix row 10 single-transition edge fires: `fixes-pending → sm-verified → done`.
- **Pattern now spans iter-14 + iter-18 (two CR re-runs, same drift class):** "semantic drift from impl-upgrade" is self-similar — each round of fixes can miss derivative sites that were authored before the upgrade and never refreshed. Fix A/B/C fixed most sites; Fix D/E fix the last steady-state recommendation sites. Next CR re-run should be the terminator.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-18. Parent Epic 1 issue **#9** — `Refs #9` only.
