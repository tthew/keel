# Implementation Plan

## NOW

- [ ] `/bmad-create-story` — FR14n matrix `_(no story) → drafted` for Story 1.12 (token emitter pipeline — web CSS + Tailwind preset + TUI theme). Consumes Story 1.11 iter-56 `packages/ui/tokens.json` + iter-58 SM-verification + iter-59 defers (deferred-work.md § Deferred from: code review of story-1.11). Anticipated preventative audits at drafting time (apply iter-54 five-layer + iter-56 sixth-layer sequence): (1) stable-IDs for emitter-stage boundaries (web CSS / Tailwind preset / TUI theme output formats); (2) Task-enumeration-vs-consumer-requirement diff — every surface that Stories 7/12/Epic-3 TUI consumption will read must map to at least one emitter output; (3) sprint-status transition wording (direct-jump `backlog → done` precedent); (4) internal-consistency drift (prose descriptor vs machine-readable value on same line); (5) cross-file line-number staleness; (6) schema-permission diff on emitter ADDITIONS (not just source-leaf REQUIRED coverage — iter-56 lesson); (7) [NEW CANDIDATE] gamut-mapping surface check (per iter-59 DEFER #5 — emitter may absorb gamut-map responsibility). **Budget projection:** medium (~40-50K — emitter-story drafts have broader scope than populator-story drafts; 3 output format surfaces × substrate coverage; plus iter-59 DEFER #4 surface-differentiation shadow-machinery scope that 1.12 emitter absorbs).

## QUEUE (Story 1.12 — token emitter pipeline)

- [ ] `/bmad-create-story (args: "review")` — FR14n row 2 pre-dev SM review for Story 1.12 `drafted → validated`. Apply all 7 preventative audits from NOW at drafting → carry-forward SM findings into in-place fixes per Story 1.8/1.9/1.10/1.11 precedent.
- [ ] `/bmad-testarch-atdd` — FR14n row 3 `validated → atdd-scaffolded`. Sixth cumulative ATDD-skip EXPECTED if Story 1.12 emitter is contract-only/output-only (test runner still absent). If test-framework setup is part of Story 1.12 scope, then ATDD becomes non-skip (precedent break).
- [ ] `/bmad-dev-story (args: "{story_file_path}")` — FR14n row 4 `atdd-scaffolded → in-dev`. Projected single-pass (if scoped narrowly) OR multi-pass with `in-dev (partial)` if emitter covers all 3 output surfaces (web CSS + Tailwind preset + TUI theme) — assess at drafting time + IP re-queue policy per iter-56 lesson.
- [ ] `/bmad-testarch-trace (args: "yolo")` — FR14n row 5 `in-dev → traced`. Sixth WAIVED precedent is CANDIDATE but not guaranteed — emitter stories have rendering/output surfaces that may warrant real test coverage (breaks the contract-only/populator-only WAIVED pattern). Assess at trace time.
- [ ] `/bmad-create-story (args: "review")` — FR14n row 7 post-dev SM `traced → sm-verified`. Target: ZERO-PATCH first-round pass per iter-58 precedent (preventative-audit + pre-dev SM compounding).
- [ ] `/bmad-code-review (args: "2")` — FR14n row 9 `sm-verified → done` (or `fixes-pending`). Target: ZERO-PATCH / 5-DEFER class outcome per iter-59 precedent if story is substrate-only; allow PATCH iterations if emitter has real code paths with edge cases.

## BLOCKED

_(none)_

## DONE (Story 1.11 complete — FR14n lifecycle 7 iterations exactly)

- [x] iter-59: **`/bmad-code-review (args: "2")` final CR gate; FR14n state `sm-verified → done` per matrix row 9.** Three-layer adversarial review: Blind Hunter (18 findings) + Edge Case Hunter (16 findings with computed WCAG ratios) + Acceptance Auditor (0 spec deviations, 4/4 AC MET, 4/4 Task MET). Triage via iter-36 + iter-52 two-layer convergence doctrine: **0 PATCH, 0 DECISION-NEEDED, 5 DEFER, 17 DISMISS**. All 5 defers are WCAG-AA contrast or sRGB-gamut concerns landing in `deferred-work.md § Deferred from: code review of story-1.11` with concrete Story 1.12 (emitter shadow-machinery + gamut-mapping) + Story 1.13 (WCAG-AA contrast gate + dark-mode `status.fg` remaps + light-mode `status.info/warning` hue retune + `text.accent`/`border.accent` dark-mode handling) carry-to. All 3 IP-staged pre-dev CR triage defenses held at review time. **Story 1.11 closes at exactly 7 iterations**: iter-53 drafted → iter-54 validated → iter-55 atdd-scaffolded → iter-56 in-dev → iter-57 traced → iter-58 sm-verified → iter-59 done. Story file Change Log v1.4 row + Review Findings section appended. Deferred-work.md new section + 5 bullets.
- [x] iter-58: `/bmad-create-story` review post-dev SM verification; FR14n `traced → sm-verified` per matrix row 7. ZERO-PATCH first-round pass.
- [x] iter-57: `/bmad-testarch-trace yolo` GATE=WAIVED; FR14n `in-dev → traced` per matrix row 5. Fifth cumulative WAIVED precedent.
- [x] iter-56: `/bmad-dev-story` implementation landed; FR14n `atdd-scaffolded → in-dev`. Single-pass. `packages/ui/tokens.json` DTCG source 106 leaves; `INV-tokens-source` manifest entry (13th); INVARIANTS.md § Design-token source (Story 1.11). Two sync-gate smokes verified.
- [x] iter-55: `/bmad-testarch-atdd` HALT at preflight prerequisite gate; FR14n `validated → atdd-scaffolded`. Fifth cumulative ATDD-skip.
- [x] iter-54: `/bmad-create-story` review pre-dev SM; FR14n `drafted → validated`. SM-1 + SM-2 applied in-place.
- [x] iter-53: `/bmad-create-story` drafted Story 1.11 file (#35).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.11 done; 1.12–1.16 backlog → 5 more stories × full FR14n lifecycle remaining before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** _(no story — Story 1.11 complete at iter-59; next story draft in iter-60 NOW)_
- **Story File:** _(n/a until iter-60 drafting)_
- **Story State:** _(no story)_ — FR14n matrix row "no story" → next iter-60 runs `/bmad-create-story` to transition to `drafted` for Story 1.12.
- **GitHub Issue:** Story 1.11 closed at `done` status (issue #35 OPEN — closes on PR merge at EPIC_DONE); parent Epic 1 tracked at **#9** (OPEN — closes at EPIC_DONE halt). Story 1.12 GitHub issue to be created by `/bmad-create-story` at iter-60.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE after stories 1.12–1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.11 7-iteration lifecycle achieved exactly (iter-53 → iter-59).** Comparative substrate-story trajectories:
  - Story 1.7 (INVARIANTS.md knowledge file): ~10 iters with multiple CR rounds
  - Story 1.8 (invariants.manifest.ts contract): ~7 iters with ZERO-PATCH SM + 6 DEFER CR
  - Story 1.9 (sync-gate runtime): ~11 iters with 2 CR re-runs (RERUN #4 + RERUN #6 for residue extraction)
  - Story 1.10 (tokens schema): ~12 iters with 2 SM rounds + 2 CR rounds (halving-to-zero trajectory)
  - **Story 1.11 (tokens source populator): 7 iters — MINIMUM FLOOR achieved via preventative-audit discipline + ZERO-PATCH SM + ZERO-PATCH CR (5 DEFER, 0 PATCH)**
- **Carry-forward rules INTO Story 1.12 (emitter) drafting — COMPOUNDING PRIOR ART:**
  - **Preventative audit discipline (7 audit layers now codified).** iter-53 three-point (stable-IDs / task-vs-schema / sprint-status wording) + iter-54 two additions (internal-consistency drift / cross-file line staleness) + iter-56 sixth (schema-permission diff on story-mandated ADDITIONS) + iter-59 seventh CANDIDATE (gamut-mapping surface check for emitter stories). Apply at Story 1.12 drafting.
  - **ZERO-PATCH discipline doctrine** (iter-58 + iter-59): "structurally impossible + fully documented + does not violate AC text = ACCEPT"; applies equally at SM and CR; compounds through the FR14n lifecycle.
  - **Multi-layer-corroborated authoring-choice findings are DEFER, not PATCH (iter-59 lesson).** When ECH flags an authoring decision that the story-task text explicitly mandates, route to the downstream gate story via DEFER with concrete carry-to target — do NOT inline retune.
  - **Single-layer BH findings default DISMISS unless corroborated (iter-36 + iter-52).** Holds through iter-59: 17 single-layer BH findings DISMISSED; 0 BH PATCHes applied to Story 1.11.
  - **Structural trace inheritance ~90% reasoning-cost savings (iter-46 + iter-57).** Re-apply to Story 1.12 trace iter when that story reaches `in-dev → traced`.
- **Story 1.12 emitter + Story 1.13 contrast-gate DEFER absorption roadmap** (from iter-59 deferred-work.md entries):
  - Story 1.12 emitter owns: (1) surface slot differentiation via shadow-machinery tokens (inner-shadow for inset, drop-shadow for raised, elevation-shadow for overlay) OR a shadow token group appended to tokens.json; (2) optional gamut-check + fallback-to-in-gamut-neighbour on sRGB emit for status.warning/error/critical.fg OKLCH leaves with slightly-negative linear-RGB components.
  - Story 1.13 contrast-gate owns: (1) dark-mode `status.<X>.fg` remap (or accept fg-inheritance with AA-failure signalling); (2) light-mode `status.info` (230) + `status.warning` (75) L retune within ±15° hue for 4.5:1 compliance; (3) `text.accent` + `border.accent` dark-mode handling (add dark-mode text.accent/border.accent remap OR retune accent.500 L upward OR emit text.accent as raised-surface-only with fallback).
- **Issue Tracking carry-forward.** Parent Epic 1 at **#9** OPEN (never `Closes`; Ralph transitions at EPIC_DONE halt). Story 1.11 at **#35** OPEN (closes on PR merge at EPIC_DONE). Story 1.12 GitHub issue to be created by `/bmad-create-story` at iter-60. iter-59 commit trailer: `Refs #35`.
