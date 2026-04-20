# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story` — picks next open story from sprint-status (Story 1.10 — design-token schema, semantic + rationale contract). Story State `_(no story)_` → `drafted` per FR14n matrix row 1. ~medium

## QUEUE (Story 1.10 — design-token schema, semantic + rationale contract)

_(empty — Story 1.10 lifecycle starts with `/bmad-create-story` at iter-42; subsequent QUEUE items per FR14n matrix populate as state advances drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done)_

## BLOCKED

_(none)_

## DONE (Story 1.9 — iter-41 closing)

- [x] iter-41: `/bmad-code-review (args: "2")` CR re-run #7 ZERO-OUT — 3 raw findings (1 MEDIUM + 2 LOW from Blind Hunter; Edge Case Hunter PASS; Acceptance Auditor PASS with 9 positive checks). Triage: **0 PATCH + 0 DEFER + 3 DISMISS** — all single-layer Blind-Hunter-only findings without two-layer convergence per iter-36 doctrine. BH1 (trace.md:105 sentence-fragment grammar in compound-subject Gaps bullet) DISMISS — bulleted enumeration tolerates fragment syntax + Acceptance Auditor verified semantic preservation. BH2 (trace.md:112 vs :205 near-verbatim duplication after Fix T) DISMISS — Fix T's explicit intent per iter-39 RALPH was template-prefix symmetry; flagging symmetry as duplication inverts the fix rationale. BH3 (three noun-phrase orderings of schema-refine across coverage-matrix.json:39 + trace.md:105 + coverage-matrix.json:41) DISMISS — Blind Hunter itself flagged as "not a contradiction"; three framings serve three structural roles (JSON body prose / trace § Gaps enumeration / JSON one-liner classifier); Edge Case Hunter confirmed Fix R closed SIBLING-FIELD-PARALLEL within AC-2. **FR14n state transition `fixes-pending → sm-verified → done` per matrix row 10 single-transition edge.** Story file Status flipped from `review` → `done`. Sprint-status synced (`1-9-…: review → done` + last_updated bumped). Story-file Review Findings (iter-41 CR re-run #7) section appended preserving iter-18/21/24/30/36 audit trail per iter-30 paper-trail rule; iter-36 Fix R/S/T/U checkboxes flipped `[ ]` → `[x]` en-masse per iter-36 DONE convention. **Halving hypothesis FULLY DISCHARGED at round 7** — fix-count trajectory 4 → 2 → 2 → 5 → 5 → 30 raw / 4 PATCH → 3 raw / 0 PATCH bottoms out. Five-class residue-family catalogue stable (added class-5 single-layer-stylistic-overreach handled inline by iter-36 convergence doctrine — not a new carry-forward rule). PR #226 stays Draft per PROMPT_build.md step 5c (EPIC_DONE = end of Epic 1 stories 1.10–1.16). Pure prose across all artefact edits — zero code changes; quality gates not re-run (no TS/JS touched).

- [x] iter-37..iter-40: Fix R + Fix S + Fix T + Fix U all landed per SIBLING-VOCABULARY-CLUSTER carry-forward rule (iter-36 lesson). Fix R (coverage-matrix.json:39 backstop→complement). Fix S (trace.md runner-hosted ×3 → test-runner-hosted at :175/:236/:484). Fix T (trace.md:112+:205 AC-3 template-prefix symmetry). Fix U (trace.md:105+:145 AC-2/AC-5 backstop-vocabulary reframe with "load-bearing complement" + "complements the substrate evidence" + "per § Testing Standards" citation). All pure prose; zero substantive-claim change.

- [x] iter-7..iter-36: 6 initial CR-fix patches (iter-7..iter-13) + CR rounds #1–#6 (iter-14/18/21/24/30/36) + 21 fix patches (A through U). Five residue classes identified across 6 rounds. Full per-iteration history in git log + RALPH.md Signposts.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.9 done; 1.10–1.16 backlog → 7 more stories × full FR14n lifecycle remaining before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** _(no story)_ — Story 1.9 closed at iter-41; iter-42 selects 1.10 via `/bmad-create-story`
- **Story File:** _n/a_ — Story 1.10 file authored at iter-42 by `/bmad-create-story`
- **Story State:** _(no story)_ — FR14n matrix row 1 baseline; first action MUST be `/bmad-create-story`
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Story 1.9 closed at iter-41 after 7 CR re-runs + 21 fix patches.** Closure pattern stable: SIBLING-VOCABULARY-CLUSTER carry-forward rule (iter-36) plus the four-layer carry-forward enumeration (iter-22 sibling-artefact / iter-24 SYMMETRIC-AC-PARALLEL / iter-30 SIBLING-FIELD-PARALLEL / iter-36 broader-corpus-vocabulary-propagation) closed all open residue classes within 4 fixes (R/S/T/U). Round 7 surfaced only single-layer stylistic findings (3 raw, 0 actionable) — the iter-36 two-layer convergence doctrine handled triage inline.
- **Carry-forward catalogue for Story 1.10+ trace-bundle CR work:** apply the four-layer enumeration when authoring/refreshing trace artefacts: (1) grep all sibling sites in same artefact family; (2) grep symmetric AC in same field-type; (3) grep sibling fields in same AC scope; (4) grep broader-corpus vocabulary occurrences of the changed literal. Combined with iter-36 DEFER-heavy triage doctrine + two-layer-convergence-gates-PATCH-promotion rule, this should bound any future story's CR loop to 1–3 rounds rather than 7. Per RALPH.md Lessons + Decisions, contract-only / data-only stories trend single-pass (Stories 1.3–1.6 + 1.8); behaviour-introducing stories (1.7 docs prose + 1.9 sync-gate) trend multi-pass — Story 1.10 (design-token schema contract) likely trends single-pass per the contract-only / data-only pattern.
- **Story 1.10 prep — design-token schema, semantic + rationale contract.** Per Epic 1 sprint-status: 7 backlog stories remain (1.10–1.16). Story 1.10 is the first design-token story (schema-side, contract-only — analogous to Story 1.8's invariants.manifest.ts contract role); 1.11 is source-direction-A baseline (token-data); 1.12 is emitter pipeline (web CSS + Tailwind preset + TUI theme); 1.13 is token quality gates (schema validation + WCAG AA contrast + source/output sync); 1.14 release-please monorepo config; 1.15 renovate config; 1.16 fork-extension config + test-runner landing (test-runner pre-condition for backfilling Story 1.9's deferred unit/integration tests).
- **Issue Tracking:** Story 1.10 issue number unset at iter-41. Parent Epic 1 issue **#9** — `Refs #9` only.
