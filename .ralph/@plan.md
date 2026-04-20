# Implementation Plan

## NOW

- [ ] CR fix L/5 [LOW]: `trace.md:190` § High Priority Gaps preamble cardinal — replace "the five primary drift-detection ACs are uncovered by automated tests" with "four (AC-1, AC-2, AC-4, AC-5) are SUBSTRATE_VERIFIED end-to-end via Task 5 smoke tests but remain uncovered by automated runner-hosted tests; the fifth (AC-3) is structural-only" (Fix J landed so the refreshed enumeration now matches the preamble target). ~small

## QUEUE (Story 1.9 — CR re-run #4 outcome processed: Fix H + I + J + K landed; Fix L LOW + CR re-run #5 remain; Story State stays `fixes-pending`)

- [ ] CR re-run #5: `/bmad-code-review (args: "2")` adversarial triage against post-Fix-H/I/J/K/L diff. Expected outcome per FR14n matrix row 10 single-transition edge: zero findings across all 3 layers → `fixes-pending → sm-verified → done`. If new findings surface (sixth round), queue fix tasks and stay `fixes-pending`. ~large

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7 through iter-28)

- [x] iter-7..iter-13: `/bmad-code-review (args: "2")` initial Ralph-hosted three-layer fan-out + 6 patches landed (CRITICAL `ANCHOR_REGEX` uppercase→lowercase + symmetric `added-to-source-only` emitter + 2 new Task-5 smokes + spec echoes; HIGH spec line 41 stdout→stderr; HIGH count 7→8 sourcePath files; HIGH count 2→5 runtime smokes; MEDIUM trace-bundle line citations re-anchored at 31 sites; MEDIUM Dev Agent Record AC-2 status prose upgraded schema→end-to-end).
- [x] iter-14: CR RE-RUN #1 — Blind Hunter NEW_FINDINGS (3 HIGH + 1 MEDIUM → Fix A/B/C queued); Edge Case Hunter MINOR_ONLY (defers); Acceptance Auditor PASS. **New pattern: trace-bundle semantic-drift from impl-upgrade.**
- [x] iter-15..iter-17: Fix A/B/C landed (HIGH regex echo swap; HIGH AC-5 framing at 3 sites; HIGH+MEDIUM cardinality 3→5 + AC enumeration {1,4,7}→{1,2,4,5,7} at 14+ sites).
- [x] iter-18: CR RE-RUN #2 — Blind Hunter PASS; Acceptance Auditor PASS; Edge Case Hunter NEW_FINDINGS (1 MEDIUM Fix D + 1 LOW Fix E).
- [x] iter-19..iter-20: Fix D/E landed (broad-scope literal swap at 6 steady-state-recommendation sites; single-line prose refinement at trace.md:319).
- [x] iter-21: CR RE-RUN #3 — Blind Hunter dismissed (ordinal drift consistent with prior convention); Acceptance Auditor PASS; Edge Case Hunter NEW_FINDINGS (2 MEDIUM Fix F + G). **Fourth-round halving hypothesis: iter-14 4 items → iter-18 2 → iter-21 2 (matches).**
- [x] iter-22..iter-23: Fix F/G landed (single-line YAML waiver.reason smoke-count 3→5; single-line AC-5 drop from remediation bullet).
- [x] iter-24: CR RE-RUN #4 — Blind Hunter PASS; Acceptance Auditor PASS + 1 MEDIUM out-of-scope (trace.md:103 AC-2 substrate_verification); Edge Case Hunter NEW_FINDINGS (3 MEDIUM + 1 LOW). **Fifth-round halving FALSIFIED (iter-24 5 items).** Root cause: Fix B's intentional narrow scope (iter-11 decision, 3 AC-5 sites only) left symmetric AC-2 substrate upgrade + § HP Gaps parallel enumerations UNDONE — SYMMETRIC-AC-PARALLEL drift, a new class. **New carry-forward rule: before committing any fix that refreshes an AC-specific framing, audit SYMMETRIC AC's enumeration across the same artefact and flag remaining asymmetry as co-located fix — do not wait for next CR round.**
- [x] iter-25: Fix H/5 [MEDIUM] — trace.md:103 AC-2 Substrate verification bullet 3 rewritten parallel to AC-5 form; stale "not exercised in smoke because baseline has 0 live addition drift" replaced with iter-8 Task-5 manifest-side missing-anchor smoke evidence.
- [x] iter-26: Fix I/5 [MEDIUM] — trace.md:198-202 § HP Gaps AC-2 entry rewritten parallel to AC-4 post-Fix-B form (lines 210-214); stale "schema-level via InvariantsSchema.superRefine id-uniqueness + anchor-walker branch" replaced with "SUBSTRATE_VERIFIED end-to-end via iter-8 Task 5 manifest-side missing-anchor smoke".
- [x] iter-27: Fix J/5 [MEDIUM] — trace.md:216-220 § HP Gaps AC-5 entry rewritten parallel to AC-4 post-Fix-B form and AC-2 post-Fix-I form; stale "structural only (anchor-walker → no-matching-manifest-row → `removed-from-docs-only`)" + "adversarial CR (Blind Hunter) is the 1.9 backstop" replaced with "SUBSTRATE_VERIFIED end-to-end via iter-8 Task 5 docs-side orphan-anchor smoke".
- [x] iter-28: Fix K/5 [MEDIUM] — coverage-matrix.json:39 AC-2 substrate_verification leaf rewritten parallel to AC-5 leaf at :69; stale "Schema-level via InvariantsSchema.superRefine id-uniqueness refine … Structural (not exercised in smoke — substrate has 0 live addition drift)" replaced with "End-to-end via iter-8 Task-5 manifest-side missing-anchor smoke (delete `INV-commitlint-shared` anchor line from `INVARIANTS.md` → exit 1 + `added-to-source-only` with sourcePath; revert; byte-identical restore) per story file line 180. Anchor-walker enumerates INVARIANTS.md anchors via `/^-\\s+\\*\\*\\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\\`\\*\\*/gm` regex (story file lines 52, 127). Manifest-row-without-anchor branch is the symmetric case. Schema-level backstop: InvariantsSchema.superRefine id-uniqueness refine (Story 1.9 Task 3, story file line 75). All 10 manifest rows have matching anchors post-Task-2; AC-2 anchor-side branch verified by ephemeral `INV-commitlint-shared` anchor deletion in the smoke." Pre-edit grep verified stale phrase `substrate has 0 live addition drift` unique to the AC-2 leaf; post-edit grep confirms zero residue across traceability/*. JSON structural validation via `python3 -c json.load` — PASS. Fix K checkbox flipped `[ ] → [x]` in story-file Review Findings iter-24 block (line 135). Pure prose — zero code changes.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — iter-28 Fix K landed; Fix L + CR re-run #5 remain; 7 more stories 1.10–1.16 remain in Epic 1 before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on NEXT CR re-run #5 (at iter-30 earliest: iter-28 Fix K [done] + iter-29 Fix L + iter-30 CR re-run #5) zero-findings outcome per matrix row 10 single-transition edge.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-28 Fix K landing — symmetric-AC audit discharged for coverage-matrix.json AC-2 substrate_verification leaf.** Fix K's rewrite closes the last symmetric-AC residue in the JSON trace-bundle sibling (Fix B refreshed AC-5 leaf :69; AC-2 leaf :39 was the symmetric counterpart). Post-edit grep of `substrate has 0 live addition drift` across `_bmad-output/test-artifacts/traceability/*` returns zero hits — residue fully purged from the traceability bundle. Grep of new vocabulary `manifest-side missing-anchor smoke` now returns 4 sites (trace.md:103 Fix H; trace.md:199 Fix I; trace.md:349 pre-iter-8 dev log; coverage-matrix.json:39 Fix K) — all intentional, all parallel. Remaining residual asymmetry: trace.md:190 § HP Gaps preamble cardinal "the five … ACs are uncovered" (Fix L — NOW). AC-3 stays structural-only by design per spec:152.
- **Pattern holding — five CR re-runs span (iter-14 + 18 + 21 + 24 + anticipated 30).** Fix counts: 4, 2, 2, 5, ?. Halving hypothesis falsified at round 4 (iter-24 5 items). Expected outcome at CR re-run #5 (iter-30): zero findings if all symmetric-AC residues in Fix H/I/J/K/L scope are exhaustive (iter-26 + iter-27 + iter-28 audits say yes for Fix I/J/K classes). Residual risk for CR re-run #5: (a) sixth-round semantic-drift vocabulary mutation in the NEW vocabulary introduced by Fix H/I/J/K (e.g. "iter-8 Task-5 manifest-side missing-anchor smoke"); (b) coverage-matrix.json level_notes at line 41 (`"schema + structural; adversarial CR pass is agreed backstop"`) and line 71 (`"structural"`) — both carry stale categorisations that Fix B/H/I/J/K intentionally scope-deferred — Blind Hunter / Edge Case Hunter may surface as sixth-round findings.
- **Fix L specifics:** Fix L at trace.md:190 (§ HP Gaps preamble cardinal — logical-dependency on Fix J landing satisfied as of iter-27; logical-dependency on Fix K landing satisfied as of iter-28).
- **Post-iter-28 EPIC-done readiness UNCHANGED.** Even after Fix L + CR re-run #5 zero-out, Story 1.9 is only the first Epic-1 story in review. Sprint-status shows stories 1.10–1.16 still `backlog` (7 more stories × full FR14n lifecycle). EPIC_DONE halt is many iterations away; PR #226 stays Draft.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-28. Parent Epic 1 issue **#9** — `Refs #9` only.
