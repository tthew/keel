# Implementation Plan

## NOW

- [ ] Re-run `/bmad-code-review (args: "2")` CR adversarial triage against post-Fix-D+E diff (`5a984e0..HEAD` — 5 artefacts touched across iter-15..20). Expected outcome per FR14n matrix row 10 single-transition edge: zero findings across all 3 layers → `fixes-pending → sm-verified → done`. If new findings surface, queue fix tasks and stay `fixes-pending`. ~large

## QUEUE (Story 1.9 — CR re-run #3; then EPIC_DONE halt if zero-findings)

_(empty — CR re-run #3 outcome determines next steps)_

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7 through iter-20)

- [x] iter-7: `/bmad-code-review (args: "2")` Ralph-hosted three-layer fan-out — 6 patches + 10 defers + 3 dismissed. CRITICAL: `ANCHOR_REGEX` uppercase-class bug reproduced by Edge Case Hunter + Acceptance Auditor.
- [x] iter-8 through iter-13: 6 CR fix patches landed — (1) CRITICAL `ANCHOR_REGEX` uppercase→lowercase + symmetric `added-to-source-only` emitter + 2 new Task-5 smokes + spec echoes; (2) HIGH spec line 41 stdout→stderr; (3) HIGH count 7→8 sourcePath files; (4) HIGH count 2→5 runtime smokes (narrow-scope per iter-11); (5) MEDIUM trace-bundle line citations re-anchored (31 edits); (6) MEDIUM Dev Agent Record AC 2 status prose upgraded schema→end-to-end.
- [x] iter-14: `/bmad-code-review (args: "2")` CR RE-RUN #1 — 3-layer fan-out against post-iter-8..13 fix diff. Blind Hunter NEW_FINDINGS (3 HIGH trace residue + 1 MEDIUM spec self-contradiction → queued as Fix A/B/C); Edge Case Hunter MINOR_ONLY (4 LOWs → defers); Acceptance Auditor PASS. Impl CLEAN; trace-narrative STALE. **New pattern established: trace-bundle semantic-drift from impl-upgrade.**
- [x] iter-15: Fix A/4 [HIGH] landing — stale UPPERCASE regex echo swap at 2 trace-bundle sites.
- [x] iter-16: Fix B/4 [HIGH] landing — stale "Not exercised in smoke" AC-5 framing refreshed at 3 sites.
- [x] iter-17: Fix C/4 [HIGH + MEDIUM] landing — broad-scope prose swap across 14+ sites (cardinality 3→5 + AC enumeration {1,4,7}→{1,2,4,5,7}).
- [x] iter-18: `/bmad-code-review (args: "2")` CR RE-RUN #2 — 3-layer fan-out against post-Fix-A/B/C diff (`5a984e0..HEAD`, 192 lines across 5 artefacts). Verdicts: Blind Hunter PASS; Acceptance Auditor PASS; Edge Case Hunter NEW_FINDINGS (1 MEDIUM Fix D + 1 LOW Fix E). Same semantic-drift-from-impl-upgrade class as Fix C.
- [x] iter-19: Fix D/2 [MEDIUM] landing — broad-scope literal swap at 6 steady-state-recommendation sites. Replaced `AC-2 / AC-3 / AC-5 structural branches` → `AC-3 structural + AC-6 CLI-contract-only branches` at trace.md:311 / :477 / :523 / :560 + coverage-matrix.json:175 + e2e-trace-summary.json:88. Recommendation prose now reflects steady-state posture.
- [x] **iter-20: Fix E/2 [LOW] landing — single-line surgical prose edit at trace.md:319.** Dropped the ` + AC-5 (removed-from-docs)` fragment (AC-5 is already end-to-end smoke-exercised per iter-8 Fix B) and tightened `the structural-only posture` → `the AC-3 structural-only posture` so the pronoun references a specific AC. Post-edit verification: grep confirms zero residual occurrences of the stale phrasing in recommendation prose (line 440 `AC-5 (removed-from-docs)` is canonical iter-8 smoke description, not in scope). Zero code changes. All Edge Case Hunter iter-18 findings now addressed.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — iter-18 CR re-run #2 surfaced Fix D/E; both landed at iter-19/iter-20)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on NEXT CR re-run (iter-21) zero-findings outcome per matrix row 10 single-transition edge.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-20 closed Fix E LOW (final iter-18 Edge Case Hunter finding).** All iter-18 findings now resolved: Fix D at iter-19 swapped 6 steady-state-recommendation sites; Fix E at iter-20 refined the Long-term-Actions recommendation to (a) stop implying AC-5 needs smoke backfill (it's already end-to-end smoke-exercised per iter-8 Fix B) and (b) tie the vague pronoun "the structural-only posture" to its specific referent "the AC-3 structural-only posture".
- **CR re-run #3 expectation (iter-21):** Blind Hunter PASS (continues — no falsifiable claims in trivial prose deltas); Acceptance Auditor PASS (continues — AC-mapping unchanged, only recommendation prose refined); Edge Case Hunter PASS (target — the last 6+1 semantic-drift sites from iter-18 are now cleaned). On all-three PASS → FR14n matrix row 10 single-transition edge fires: `fixes-pending → sm-verified → done` and Story 1.9 completes the lifecycle.
- **Pattern — two CR re-runs (iter-14, iter-18) both found semantic-drift-from-impl-upgrade residue; third CR re-run should terminate.** Each round halved the remaining surface: iter-14 found Fix A/B/C (trace-narrative stale post-iter-8..13 impl upgrade); iter-18 found Fix D/E (residuals Fix C missed); iter-20 touched only the already-flagged site + refactored pronoun — no new derivative surface introduced.
- **Post-iter-20 EPIC-done readiness.** If iter-21 CR re-run #3 returns zero findings across all 3 layers, Story 1.9 closes. Sprint-status needs to be checked for remaining open stories in Epic 1; if none remain, EPIC_DONE halt fires per PROMPT_build.md "Transition PR Draft→Open — final CI gate" path.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-20. Parent Epic 1 issue **#9** — `Refs #9` only.
