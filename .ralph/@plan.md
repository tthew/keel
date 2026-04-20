# Implementation Plan

## NOW

- [ ] `/bmad-code-review (args: "2")` — FR14n row 9 `sm-verified → done` (or `sm-verified → fixes-pending` if action items surface). Pre-selects "Create action items" via args=2. **CR-round budget**: 1-3 rounds per iter-7 contract-only-single-pass hypothesis + iter-52 halving-to-zero-at-round-2 trajectory for contract-populator stories (Story 1.10 landed ZERO-PATCH at round 2 after single CR-1 PATCH at round 1). **Potential CR findings (pre-staged defenses):** (a) root-provenance-block skip rationale — Blind Hunter may flag as missing AC 1 DTCG ratification; defense = per-leaf `$description`s (accent.400/500/600/fg + motion/density dials) + Debug Log + commit trailer + Change Log v1.2 = sufficient provenance capture; story AC 1 requires schema validation (met), not a specific provenance form; (b) dark-mode `surface.inset` vs `surface.default` 5pp L delta (neutral.900 vs neutral.950) — may flag as too-subtle separation; defense = shadow-machinery is Story 1.12 emitter scope, not source; (c) font-family array-vs-string deferral — pre-documented in `deferred-work.md` + story § AC 1 carve-out + Change Log v1.2; (d) status.fg not remapped in dark mode — story Task 1 mandates ("keep `fg` values equal across modes"); schema-compliant via `sparseColorStatusVariant`.

## QUEUE (Story 1.11 — design-token source, Direction A baseline with motion + density scales)

_(none — `sm-verified → done` is the terminal FR14n hop for this story; if CR surfaces action items, they land here at the TOP per adversarial-triage default)_

## BLOCKED

_(none)_

## DONE (Story 1.11 SM-verified + carry-forward context)

- [x] iter-58: **`/bmad-create-story (args: "review")` post-dev SM verification; FR14n state `traced → sm-verified` per matrix row 7.** ZERO-PATCH first-round pass. All 4 ACs verified MET against implementation (re-ran ajv schema validate + sha256sum + pnpm keel-invariants:check + typecheck/lint/format:check — all green). Three IP-staged anticipated findings held their carve-out defenses: (a) root-provenance-block variance accepted per AC 1 scope (AC requires schema validation, not provenance format); (b) dark-mode `surface.inset` 5pp delta accepted per Story 1.12 emitter-scope boundary; (c) font-family string form accepted per deferred-work.md prior art. Change Log v1.3 row appended to story file. Zero scope changes, zero AC/Task restructure, zero in-place fixes. **Carry-forward hypothesis validated:** iter-53 three-point preventative audit + iter-54 pre-dev SM (2 in-place fixes) + iter-56 clean single-pass dev + iter-57 trace WAIVED = cumulative rigour landed a first-round-pass post-dev SM. Story 1.12+ contract-populator stories should replicate the audit-early pattern.
- [x] iter-57: `/bmad-testarch-trace (args: "yolo")` GATE=WAIVED; FR14n state `in-dev → traced` per matrix row 5. Fifth cumulative WAIVED precedent (Stories 1.7/1.8/1.9/1.10/1.11). Authored 4 trace artefacts with ~90% reasoning savings via Story 1.10 structural inheritance.
- [x] iter-56: `/bmad-dev-story` implementation landed; FR14n state `atdd-scaffolded → in-dev`. Single-pass. `packages/ui/tokens.json` DTCG source 106 leaves; `INV-tokens-source` manifest entry (13th); INVARIANTS.md § Design-token source (Story 1.11). Two sync-gate smokes verified end-to-end.
- [x] iter-55: `/bmad-testarch-atdd` HALT at preflight prerequisite gate; FR14n state `validated → atdd-scaffolded`. Fifth cumulative ATDD-skip application.
- [x] iter-54: `/bmad-create-story (args: "review")` pre-dev SM review; FR14n state `drafted → validated`. SM-1 + SM-2 applied in-place.
- [x] iter-53: `/bmad-create-story` drafted Story 1.11 file. (#35).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.10 done; 1.11 sm-verified + next-up for `/bmad-code-review (args: "2")` CR gate; 1.12–1.16 backlog → 5 more stories × full FR14n lifecycle remaining after 1.11 closes before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** Story 1.11 — Design-token source, Direction A baseline with motion + density scales
- **Story File:** `_bmad-output/implementation-artifacts/1-11-design-token-source-direction-a-baseline-with-motion-density-scales.md`
- **Story State:** `sm-verified` — FR14n matrix row 7 (`traced → sm-verified`) landed at iter-58 via `/bmad-create-story (args: "review")` ZERO-PATCH first-round pass; next iter-59 runs `/bmad-code-review (args: "2")` for row 9 `sm-verified → done` (or `sm-verified → fixes-pending`).
- **GitHub Issue:** Story 1.11 tracked at **#35** (OPEN); parent Epic 1 tracked at **#9** (OPEN).
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE after stories 1.11–1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.11 sizing actuals vs projection.** iter-57 projected `iter-58 sm-verified (small ~10K review + optional inline fix)` — CONFIRMED (ZERO-PATCH pass, review-only; no inline fixes needed). Updated trajectory: iter-53 drafted → iter-54 validated → iter-55 atdd-scaffolded → iter-56 in-dev → iter-57 traced → **iter-58 sm-verified (done, ZERO-PATCH)** → iter-59 CR-done = **7 iterations** (floor held exactly; contract-populator/data-only stories can achieve 7-iter FR14n lifecycle when iter-53 preventative audit + iter-54 pre-dev SM pay disciplined forward rigour).
- **Iter-58 Lessons — captured as RALPH.md iter-58 Signpost candidates:**
  - **Preventative audit + pre-dev SM compound to ZERO-PATCH post-dev SM review.** The iter-53 three-point audit (stable-IDs / task-enumeration-vs-schema-enumeration / sprint-status-transition-wording) + iter-54 pre-dev SM (2 in-place fixes: hue 230 reconcile + line-137 off-by-one) + iter-56 clean single-pass dev + iter-57 WAIVED trace — this cumulative discipline landed a first-round-pass post-dev SM with no in-place fixes. For Story 1.12+ contract-populator stories (emitter / schema-validation-gate / contrast-gate), replicate the audit-early pattern at drafting iter to compound into ZERO-PATCH SM.
  - **Story-task-vs-schema-conflict gracefully absorbed at post-dev SM.** The root-provenance-block conflict (story Task 1 subtask 2 directive vs Story 1.10 schema `additionalProperties: false` at root) that iter-54 pre-dev SM missed did NOT block iter-58 post-dev SM — because dev documented the variance (per-leaf `$description`s + Debug Log + commit trailer + Change Log v1.2) AND because AC 1 required schema validation (met), not a specific provenance format. **Doctrine: a story task variance that's structurally impossible AND fully documented AND does not violate the AC text = accept at SM review.** Record this as a carry-forward for future schema-constrained populator stories.
- **Carry-forward rules INTO Story 1.11 CR layer** (iter-52 + iter-53 + iter-54 + iter-56 + iter-57 + iter-58):
  - **Two-layer CR convergence doctrine** (iter-36 + iter-52): single-layer Blind-Hunter findings are default DISMISS unless corroborated. Apply aggressively at Story 1.11's iter-59 CR triage iteration.
  - **CR triage defenses pre-staged in IP NOW Notes above** — at iter-59 CR time, lean on: (a) root-provenance skip rationale = Debug Log + commit trailer + Change Log + per-leaf `$description` = sufficient; (b) dark-mode surface.inset 5pp delta = Story 1.12 emitter scope; (c) font-family string-vs-array = deferred-work.md prior art; (d) status.fg not remapped in dark mode = story Task 1 mandate + schema-compliant via sparseColorStatusVariant.
  - **Preventative audits discipline carry-forward to next story (Story 1.12+):** replicate at drafting iter to compound forward-rigour into ZERO-PATCH SM outcomes.
- **Next iteration (iter-59) expected outcome:** `/bmad-code-review (args: "2")` runs in a fresh context window for final CR gate (FR14n matrix row 9). Expected trajectory based on Story 1.10 precedent: round 1 = 0-1 single-layer findings → triage convergent PATCHes inline → round 2 = ZERO-PATCH → `done`. If multi-layer corroborated findings surface, budget 1-2 fix iterations then re-run CR. Budget: small (~20-30K — CR fan-out via Opus subagents + triage + inline fixes if any; ZERO-PATCH path = ~15K).
- **Issue Tracking:** Story 1.11 tracked at GitHub issue **#35** (OPEN at iter-58 time). `Refs #35` in iter-58 commit trailer. `Closes #35` deferred to PR body when PR #226 transitions Draft→Open at EPIC_DONE halt. Parent Epic 1 issue **#9** — `Refs #9` optional; never `Closes` it.
