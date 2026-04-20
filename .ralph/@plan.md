# Implementation Plan

## NOW

- [ ] Fix F (MEDIUM) — single-line literal swap at `_bmad-output/test-artifacts/traceability/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md:591`: waiver.reason YAML leaf `Substrate verification strong: 7 gates green + 3 end-to-end smoke tests` → `Substrate verification strong: 7 gates green + 5 end-to-end smoke tests`. Before editing, grep `3 end-to-end smoke tests` / `3 .*smoke` / `three .*smoke` across the entire `_bmad-output/test-artifacts/traceability/1-9-*` bundle + story file + gate-decision.json + coverage-matrix.json + e2e-trace-summary.json to enumerate ALL surviving sites (iter-17 Fix C missed this one; do not repeat a narrow-scope miss). ~small

## QUEUE (Story 1.9 — CR re-run #3 outcome: 2 new MEDIUM + 1 dismissed; Fix F + Fix G + CR re-run #4)

- [ ] Fix G (MEDIUM) — `trace.md:506` Mandatory Remediation bullet: drop ` + AC-5` from `...structural test for AC-3 + AC-5 branches that are not exercised in 1.9 smoke` so the bullet reads `...structural test for AC-3 branches that are not exercised in 1.9 smoke`. Same derivative-drift class as Fix E; AC-5 is end-to-end-exercised per iter-8 Fix B (spec:143 + trace.md:141/:260/:319 + coverage-matrix.json:69). Before editing, grep `AC-3 \+ AC-5` / `AC-3 .*AC-5 .*not exercised` / `AC-3 .*AC-5 .*structural` across the entire trace bundle + spec to enumerate ALL surviving sites (Fix E's iter-18 grep pattern missed this one; do not repeat a narrow-scope miss). ~small
- [ ] CR re-run #4: `/bmad-code-review (args: "2")` adversarial triage against post-Fix-F+G diff. Expected outcome per FR14n matrix row 10 single-transition edge: zero findings across all 3 layers → `fixes-pending → sm-verified → done`. If new findings surface (fifth round), queue fix tasks and stay `fixes-pending`. ~large

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7 through iter-21)

- [x] iter-7: `/bmad-code-review (args: "2")` Ralph-hosted three-layer fan-out — 6 patches + 10 defers + 3 dismissed. CRITICAL: `ANCHOR_REGEX` uppercase-class bug reproduced by Edge Case Hunter + Acceptance Auditor.
- [x] iter-8 through iter-13: 6 CR fix patches landed — (1) CRITICAL `ANCHOR_REGEX` uppercase→lowercase + symmetric `added-to-source-only` emitter + 2 new Task-5 smokes + spec echoes; (2) HIGH spec line 41 stdout→stderr; (3) HIGH count 7→8 sourcePath files; (4) HIGH count 2→5 runtime smokes (narrow-scope per iter-11); (5) MEDIUM trace-bundle line citations re-anchored (31 edits); (6) MEDIUM Dev Agent Record AC 2 status prose upgraded schema→end-to-end.
- [x] iter-14: `/bmad-code-review (args: "2")` CR RE-RUN #1 — 3-layer fan-out against post-iter-8..13 fix diff. Blind Hunter NEW_FINDINGS (3 HIGH trace residue + 1 MEDIUM spec self-contradiction → queued as Fix A/B/C); Edge Case Hunter MINOR_ONLY (4 LOWs → defers); Acceptance Auditor PASS. Impl CLEAN; trace-narrative STALE. **New pattern established: trace-bundle semantic-drift from impl-upgrade.**
- [x] iter-15: Fix A/4 [HIGH] landing — stale UPPERCASE regex echo swap at 2 trace-bundle sites.
- [x] iter-16: Fix B/4 [HIGH] landing — stale "Not exercised in smoke" AC-5 framing refreshed at 3 sites.
- [x] iter-17: Fix C/4 [HIGH + MEDIUM] landing — broad-scope prose swap across 14+ sites (cardinality 3→5 + AC enumeration {1,4,7}→{1,2,4,5,7}).
- [x] iter-18: `/bmad-code-review (args: "2")` CR RE-RUN #2 — 3-layer fan-out against post-Fix-A/B/C diff (`5a984e0..HEAD`, 192 lines across 5 artefacts). Verdicts: Blind Hunter PASS; Acceptance Auditor PASS; Edge Case Hunter NEW_FINDINGS (1 MEDIUM Fix D + 1 LOW Fix E). Same semantic-drift-from-impl-upgrade class as Fix C.
- [x] iter-19: Fix D/2 [MEDIUM] landing — broad-scope literal swap at 6 steady-state-recommendation sites. Replaced `AC-2 / AC-3 / AC-5 structural branches` → `AC-3 structural + AC-6 CLI-contract-only branches` at trace.md:311 / :477 / :523 / :560 + coverage-matrix.json:175 + e2e-trace-summary.json:88. Recommendation prose now reflects steady-state posture.
- [x] iter-20: Fix E/2 [LOW] landing — single-line surgical prose edit at trace.md:319. Dropped the ` + AC-5 (removed-from-docs)` fragment + retargeted pronoun `the structural-only posture` → `the AC-3 structural-only posture`.
- [x] **iter-21: `/bmad-code-review (args: "2")` CR RE-RUN #3 — 3-layer fan-out against post-Fix-D+E diff (`5a984e0..HEAD`, 352 lines across 7 artefacts, 5 substantive Story-1.9 artefacts).** Verdicts: **Blind Hunter NEW_FINDINGS** (1 MEDIUM — RALPH.md iter-18 journal ordinal "eighth cumulative confirmation" vs 9-item enumeration; **dismissed** because iter-14 pre-existing entry uses same tacit convention — consistent +1 ordinal increment per CR run across 1.7 + 1.8 + 1.9 series; parseable by any future Ralph). **Acceptance Auditor PASS** (all 6 Fix D sites + Fix E refinement verified spec-aligned against Dev Agent Record AC matrix: AC-2 + AC-5 end-to-end per spec:151/:154, AC-3 structural-only per spec:152, AC-6 CLI-contract-only per spec:155 + carve-out spec:41). **Edge Case Hunter NEW_FINDINGS** (2 MEDIUM — Fix F + Fix G, both derivative-drift residues missed by iter-18's grep sweep). **Fourth-round semantic-drift residue pattern:** iter-14 found Fix A/B/C (3+1=4 items); iter-18 found Fix D/E (1+1=2 items); iter-21 found Fix F/G (2 MEDIUM + 1 dismissed). Surface halving roughly sustains but terminator iteration requires an exhaustive forward-grep on NEW vocabulary after each fix lands, not just on the pattern that triggered it.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — iter-21 CR re-run #3 surfaced Fix F/G; 7 more stories 1.10–1.16 remain in Epic 1 before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on NEXT CR re-run (#4 at iter-24 after Fix F + Fix G land) zero-findings outcome per matrix row 10 single-transition edge.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-21 CR re-run #3 DID NOT zero-out.** Story 1.9 stays `fixes-pending`. Two MEDIUM findings queued as Fix F + Fix G; one LOW dismissed (RALPH.md journal ordinal convention). Sprint-status + story-file Status unchanged (`review`).
- **Pattern — three CR re-runs (iter-14, iter-18, iter-21) all found semantic-drift-from-impl-upgrade residue.** iter-14: 4 items (Fix A/B/C broad-scope at ~14 sites). iter-18: 2 items (Fix D broad-scope 6 sites + Fix E single-line). iter-21: 2 MEDIUM items (Fix F single-line cardinality + Fix G single-line semantic). Each round surfaces derivative sites that were authored pre-upgrade in the same conceptual lexicon but use VOCABULARY VARIANTS that the prior grep sweep did not anticipate. The "terminator iteration" requires a forward-grep on the NEW vocabulary AFTER the fix lands, not on the old pattern that triggered it. For Fix F + Fix G carry-forward rule: grep the NEW literal target (`5 end-to-end smoke tests` / `AC-3 structural-only`) across the bundle to verify uniqueness and completeness before committing.
- **Fix F specifics (MEDIUM):** Site `trace.md:591` in § PHASE 2 quality-gate YAML block, `waiver.reason` leaf. The stale `3 end-to-end smoke tests` cardinal directly contradicts adjacent line 585 (`5 runtime smoke tests`) inside the same gate-decision artefact. iter-17 Fix C's 14-site sweep (cardinality `three`→`five` + `3`→`5`) missed this YAML-embedded leaf because the pattern was inside indented YAML inside a fenced Markdown code-block.
- **Fix G specifics (MEDIUM):** Site `trace.md:506` § Mandatory Remediation bullet. The claim `AC-3 + AC-5 branches that are not exercised in 1.9 smoke` is false for AC-5 post-iter-8 Fix B (AC-5 is end-to-end via docs-side orphan-anchor smoke per spec:143). Fix E at iter-20 addressed the `AC-3 + AC-5 ... backfill` variant at trace.md:319 but the `AC-3 + AC-5 ... not exercised` variant at trace.md:506 is a parallel derivative the grep missed.
- **Post-iter-21 EPIC-done readiness UNCHANGED.** Even after Fix F + Fix G + CR re-run #4 zero-out, Story 1.9 is only the first Epic-1 story in review. Sprint-status shows stories 1.10–1.16 still `backlog` (7 more stories → create-story → ... → done each). EPIC_DONE halt is many iterations away; PR #226 stays Draft.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-21. Parent Epic 1 issue **#9** — `Refs #9` only.
