# Implementation Plan

## NOW

- [ ] CR fix J/5 [MEDIUM]: `trace.md:216-220` § High Priority Gaps AC-5 entry — rewrite 5-line entry in parallel to AC-4 post-Fix-B form (lines 210-214) so AC-5 entry reads SUBSTRATE_VERIFIED end-to-end via iter-8 Task-5 docs-side orphan-anchor smoke. Fix B's narrow AC-5 scope (trace.md:143 / :260 / coverage-matrix:69) never extended to this § HP Gaps parallel. ~small

## QUEUE (Story 1.9 — CR re-run #4 outcome processed: Fix H + I landed; 2 MEDIUM + 1 LOW patches remain; Story State stays `fixes-pending`)

- [ ] CR fix K/5 [MEDIUM]: `coverage-matrix.json:39` AC-2 substrate_verification leaf — refresh to parallel AC-5 leaf at :69 (Fix B refreshed AC-5 only; AC-2 substrate_verification leaf still reads stale "Structural (not exercised in smoke — substrate has 0 live addition drift)"). ~small
- [ ] CR fix L/5 [LOW]: `trace.md:190` § High Priority Gaps preamble cardinal — replace "the five primary drift-detection ACs are uncovered by automated tests" with "four (AC-1, AC-2, AC-4, AC-5) are SUBSTRATE_VERIFIED end-to-end via Task 5 smoke tests but remain uncovered by automated runner-hosted tests; the fifth (AC-3) is structural-only" (logically depends on Fix J landing so the refreshed enumeration matches the preamble). ~small
- [ ] CR re-run #5: `/bmad-code-review (args: "2")` adversarial triage against post-Fix-H/I/J/K/L diff. Expected outcome per FR14n matrix row 10 single-transition edge: zero findings across all 3 layers → `fixes-pending → sm-verified → done`. If new findings surface (sixth round), queue fix tasks and stay `fixes-pending`. ~large

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7 through iter-26)

- [x] iter-7..iter-13: `/bmad-code-review (args: "2")` initial Ralph-hosted three-layer fan-out + 6 patches landed (CRITICAL `ANCHOR_REGEX` uppercase→lowercase + symmetric `added-to-source-only` emitter + 2 new Task-5 smokes + spec echoes; HIGH spec line 41 stdout→stderr; HIGH count 7→8 sourcePath files; HIGH count 2→5 runtime smokes; MEDIUM trace-bundle line citations re-anchored at 31 sites; MEDIUM Dev Agent Record AC-2 status prose upgraded schema→end-to-end).
- [x] iter-14: CR RE-RUN #1 — Blind Hunter NEW_FINDINGS (3 HIGH + 1 MEDIUM → Fix A/B/C queued); Edge Case Hunter MINOR_ONLY (defers); Acceptance Auditor PASS. **New pattern: trace-bundle semantic-drift from impl-upgrade.**
- [x] iter-15..iter-17: Fix A/B/C landed (HIGH regex echo swap; HIGH AC-5 framing at 3 sites; HIGH+MEDIUM cardinality 3→5 + AC enumeration {1,4,7}→{1,2,4,5,7} at 14+ sites).
- [x] iter-18: CR RE-RUN #2 — Blind Hunter PASS; Acceptance Auditor PASS; Edge Case Hunter NEW_FINDINGS (1 MEDIUM Fix D + 1 LOW Fix E).
- [x] iter-19..iter-20: Fix D/E landed (broad-scope literal swap at 6 steady-state-recommendation sites; single-line prose refinement at trace.md:319).
- [x] iter-21: CR RE-RUN #3 — Blind Hunter dismissed (ordinal drift consistent with prior convention); Acceptance Auditor PASS; Edge Case Hunter NEW_FINDINGS (2 MEDIUM Fix F + G). **Fourth-round halving hypothesis: iter-14 4 items → iter-18 2 → iter-21 2 (matches).**
- [x] iter-22..iter-23: Fix F/G landed (single-line YAML waiver.reason smoke-count 3→5; single-line AC-5 drop from remediation bullet).
- [x] iter-24: CR RE-RUN #4 — Blind Hunter PASS; Acceptance Auditor PASS + 1 MEDIUM out-of-scope (trace.md:103 AC-2 substrate_verification); Edge Case Hunter NEW_FINDINGS (3 MEDIUM + 1 LOW). **Fifth-round halving FALSIFIED (iter-24 5 items).** Root cause: Fix B's intentional narrow scope (iter-11 decision, 3 AC-5 sites only) left symmetric AC-2 substrate upgrade + § HP Gaps parallel enumerations UNDONE — SYMMETRIC-AC-PARALLEL drift, a new class. **New carry-forward rule: before committing any fix that refreshes an AC-specific framing, audit SYMMETRIC AC's enumeration across the same artefact and flag remaining asymmetry as co-located fix — do not wait for next CR round.**
- [x] iter-25: Fix H/5 [MEDIUM] — trace.md:103 AC-2 Substrate verification bullet 3 rewritten parallel to AC-5 form; stale "not exercised in smoke because baseline has 0 live addition drift" replaced with iter-8 Task-5 manifest-side missing-anchor smoke evidence.
- [x] iter-26: Fix I/5 [MEDIUM] — trace.md:198-202 § HP Gaps AC-2 entry rewritten parallel to AC-4 post-Fix-B form (lines 210-214); stale "schema-level via InvariantsSchema.superRefine id-uniqueness + anchor-walker branch" replaced with "SUBSTRATE_VERIFIED end-to-end via iter-8 Task 5 manifest-side missing-anchor smoke". Pre-edit grep verified stale phrase unique (single site); post-edit grep confirms new vocabulary unique; symmetric-AC audit: AC-5 § HP Gaps parallel queued as Fix J (next iter) + preamble cardinal queued as Fix L — all symmetric residues enumerated in plan. Fix I checkbox flipped `[ ] → [x]` in story-file Review Findings iter-24 block. Pure prose — zero code changes.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — iter-26 Fix I landed; Fix J/K/L remain; 7 more stories 1.10–1.16 remain in Epic 1 before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on NEXT CR re-run #5 (at iter-30 earliest: iter-26 Fix I [done] + iter-27 Fix J + iter-28 Fix K + iter-29 Fix L + iter-30 CR re-run #5) zero-findings outcome per matrix row 10 single-transition edge.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-26 Fix I landing — symmetric-AC audit discharged.** Fix I's AC-2 § HP Gaps rewrite is parallel to Fix H's AC-2 substrate_verification bullet (iter-25) and to AC-4's § HP Gaps entry (trace.md:210-214 post-Fix-B form). The SYMMETRIC AC is AC-5 at § HP Gaps (lines 216-220) — already queued as Fix J. The preamble cardinal at line 190 (depending on Fix J landing) is Fix L. Coverage-matrix AC-2 leaf (:39) is Fix K. All symmetric-AC residues enumerated in current QUEUE; no hidden symmetric parallels discovered by this iteration's grep sweep. Carry-forward rule discharged for Fix I class.
- **Pattern holding — five CR re-runs span (iter-14 + 18 + 21 + 24 + anticipated 30).** Fix counts: 4, 2, 2, 5, ?. Halving hypothesis falsified at round 4 (iter-24 5 items). Expected outcome at CR re-run #5 (iter-30): zero findings if all symmetric-AC residues in Fix H/I/J/K/L scope are exhaustive (Fix I iter-26 audit says yes). Residual risk: sixth-round semantic-drift vocabulary mutation in the NEW vocabulary introduced by Fix H/I/J/K (e.g. "iter-8 Task-5 manifest-side missing-anchor smoke" / "iter-8 Task-5 docs-side orphan-anchor smoke") — monitored by Blind Hunter in iter-30 CR re-run.
- **Fix J/K/L specifics:** Fix J at trace.md:216-220 (§ HP Gaps AC-5 entry, 5 lines, parallel to AC-4 form lines 210-214). Fix K at coverage-matrix.json:39 (AC-2 substrate_verification JSON leaf, parallel to AC-5 leaf at :69). Fix L at trace.md:190 (§ HP Gaps preamble cardinal — logically depends on Fix J landing so enumeration matches preamble).
- **Post-iter-26 EPIC-done readiness UNCHANGED.** Even after all remaining fixes + CR re-run #5 zero-out, Story 1.9 is only the first Epic-1 story in review. Sprint-status shows stories 1.10–1.16 still `backlog` (7 more stories × full FR14n lifecycle). EPIC_DONE halt is many iterations away; PR #226 stays Draft.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-26. Parent Epic 1 issue **#9** — `Refs #9` only.
