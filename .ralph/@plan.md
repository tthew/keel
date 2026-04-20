# Implementation Plan

## NOW

- [ ] Fix E/2 [LOW] — single-line edit at `_bmad-output/test-artifacts/traceability/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md:319`. Drop the ` + AC-5 (removed-from-docs)` fragment and retighten pronoun so the Long-term-Actions recommendation reads: "Story 1.16 can backfill smoke tests for AC-3 (removed-from-source) alongside unit coverage, closing the AC-3 structural-only posture at 1.9." Surgical prose-only edit; zero code changes. ~small

## QUEUE (Story 1.9 — CR iter-18 fixes; Fix E LOW next; then CR re-run #3)

- [ ] Re-run `/bmad-code-review (args: "2")` CR adversarial triage against post-Fix-D+E diff. Expected outcome per FR14n matrix row 10 single-transition edge: zero findings across all 3 layers → `fixes-pending → sm-verified → done`. If new findings surface, queue fix tasks; stay `fixes-pending`.

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7 through iter-19)

- [x] iter-7: `/bmad-code-review (args: "2")` Ralph-hosted three-layer fan-out — 6 patches + 10 defers + 3 dismissed. CRITICAL: `ANCHOR_REGEX` uppercase-class bug reproduced by Edge Case Hunter + Acceptance Auditor.
- [x] iter-8 through iter-13: 6 CR fix patches landed — (1) CRITICAL `ANCHOR_REGEX` uppercase→lowercase + symmetric `added-to-source-only` emitter + 2 new Task-5 smokes + spec echoes; (2) HIGH spec line 41 stdout→stderr; (3) HIGH count 7→8 sourcePath files; (4) HIGH count 2→5 runtime smokes (narrow-scope per iter-11); (5) MEDIUM trace-bundle line citations re-anchored (31 edits); (6) MEDIUM Dev Agent Record AC 2 status prose upgraded schema→end-to-end.
- [x] iter-14: `/bmad-code-review (args: "2")` CR RE-RUN #1 — 3-layer fan-out against post-iter-8..13 fix diff. Blind Hunter NEW_FINDINGS (3 HIGH trace residue + 1 MEDIUM spec self-contradiction → queued as Fix A/B/C); Edge Case Hunter MINOR_ONLY (4 LOWs → defers); Acceptance Auditor PASS. Impl CLEAN; trace-narrative STALE. **New pattern established: trace-bundle semantic-drift from impl-upgrade.**
- [x] iter-15: Fix A/4 [HIGH] landing — stale UPPERCASE regex echo swap at 2 trace-bundle sites.
- [x] iter-16: Fix B/4 [HIGH] landing — stale "Not exercised in smoke" AC-5 framing refreshed at 3 sites.
- [x] iter-17: Fix C/4 [HIGH + MEDIUM] landing — broad-scope prose swap across 14+ sites (cardinality 3→5 + AC enumeration {1,4,7}→{1,2,4,5,7}).
- [x] iter-18: `/bmad-code-review (args: "2")` CR RE-RUN #2 — 3-layer fan-out against post-Fix-A/B/C diff (`5a984e0..HEAD`, 192 lines across 5 artefacts). Verdicts: Blind Hunter PASS; Acceptance Auditor PASS; Edge Case Hunter NEW_FINDINGS (1 MEDIUM Fix D + 1 LOW Fix E). Same semantic-drift-from-impl-upgrade class as Fix C.
- [x] **iter-19: Fix D/2 [MEDIUM] landing — broad-scope literal swap at 6 steady-state-recommendation sites.** Replaced `AC-2 / AC-3 / AC-5 structural branches` → `AC-3 structural + AC-6 CLI-contract-only branches` at trace.md:311 / :477 / :523 / :560 (4 via `replace_all`) + coverage-matrix.json:175 + e2e-trace-summary.json:88. Post-edit verification: 0 residual grep hits for the stale phrase; 6 hits for the canonical replacement; both JSONs re-parse clean. Pure prose edit; zero code changes. Reconciles the carve-out Ralph flagged at iter-17 ("recommendation prose is steady-state, not coverage framing") — Edge Case Hunter's iter-18 catch was correct.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — iter-18 CR re-run #2 surfaced 2 fix patches; Fix D landed at iter-19; Fix E LOW queued for NOW)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on NEXT CR re-run (iter-21 or later) zero-findings outcome per matrix row 10 single-transition edge.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-19 closed the 6-site Fix D scope from iter-18 Edge Case Hunter.** Canonical replacement applied at all 6 sites: `AC-3 structural + AC-6 CLI-contract-only branches` — consistent with iter-8 Fix B (AC-2 + AC-5 promoted end-to-end smoke-exercised) and Fix C (cardinality 3→5, AC enumeration {1,4,7}→{1,2,4,5,7}). The structural residuals post-Fix-B/C are exactly AC-3 (removed-from-source-only, schema-level only) + AC-6 (CLI contract, exit-code / stdout / stderr framing only). Recommendation prose now reflects steady-state posture.
- **Fix E scope — single-line surgical delete at trace.md:319.** Drop the ` + AC-5 (removed-from-docs)` fragment (AC-5 is already end-to-end smoke-exercised per iter-8 Fix B — Story 1.16 doesn't need to backfill it) AND tighten `the structural-only posture` → `the AC-3 structural-only posture` so the pronoun references a specific AC rather than a vague residue class. After Fix E lands, all Edge Case Hunter iter-18 findings are addressed.
- **CR re-run #3 expectation (iter-21):** Blind Hunter PASS (continues — no falsifiable claims in trivial prose deltas); Acceptance Auditor PASS (continues — AC-mapping unchanged, only recommendation prose refined); Edge Case Hunter PASS (target — the last 6+1 semantic-drift sites are now cleaned). On all-three PASS → FR14n matrix row 10 single-transition edge fires: `fixes-pending → sm-verified → done`.
- **Pattern — two CR re-runs, same semantic-drift-from-impl-upgrade class — likely terminator after iter-21.** iter-14 found Fix A/B/C (trace-narrative stale post-iter-8..13 impl upgrade); iter-18 found Fix D/E (residuals Fix C missed). Each fix round halved the remaining surface. Third CR re-run should find zero drift unless Ralph introduces new derivative sites — and this iteration touched only the already-flagged 6 sites.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-19. Parent Epic 1 issue **#9** — `Refs #9` only.
