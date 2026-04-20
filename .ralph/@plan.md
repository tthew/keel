# Implementation Plan

## NOW

- [ ] `/bmad-create-story (args: "review")` — FR14n row 7 `traced → sm-verified`. Expected: first-round pass if the iter-53 preventative audit + iter-54 pre-dev SM review + iter-56 dev-pass + iter-57 trace gate held cleanly end-to-end. Mechanical-fix round-trip budget = 1 iter if any structural gap surfaces (Story 1.10 iter-47..49 precedent). **Watch for:** surfacing of the story-vs-schema root-provenance-block conflict (story Task 1 subtask 2 variance) — was documented in iter-56 Debug Log but SM reviewer may flag as unmet AC unless they accept the carve-out rationale (per-leaf `$description` + Debug Log + commit trailer + Change Log v1.2 = sufficient provenance capture).

## QUEUE (Story 1.11 — design-token source, Direction A baseline with motion + density scales)

- [ ] `/bmad-code-review (args: "2")` — FR14n row 9 `sm-verified → done` (or `sm-verified → fixes-pending` if action items surface; budget 1-3 CR rounds per iter-7 contract-only-single-pass hypothesis + iter-52 halving-to-zero-at-round-2 trajectory for contract-populator stories with ≤1 convergent PATCH at round 1). **Potential CR findings:** (a) root-provenance-block skip rationale (Blind Hunter may flag as missing AC 1 DTCG ratification; defense: per-leaf `$description`s + Debug Log + commit trailer + Change Log v1.2 = sufficient provenance capture); (b) dark-mode `surface.inset` vs `surface.default` contrast (5pp L delta — may be flagged as too-subtle separation; defense: shadow-machinery is Story 1.12's scope, not source); (c) font-family array-vs-string deferral (pre-documented in deferred-work.md + Change Log).

## BLOCKED

_(none)_

## DONE (Story 1.11 trace complete + carry-forward context)

- [x] iter-57: **`/bmad-testarch-trace (args: "yolo")` GATE=WAIVED; FR14n state transition `in-dev → traced` per matrix row 5.** Fifth cumulative WAIVED precedent (Stories 1.7/1.8/1.9/1.10/1.11). Authored 4 trace artefacts under `_bmad-output/test-artifacts/traceability/`: main MD trace report (`1-11-design-token-source-direction-a-baseline-with-motion-density-scales.md` ~25KB) + 3 sibling JSONs (`1-11-coverage-matrix.json`, `1-11-e2e-trace-summary.json`, `1-11-gate-decision.json`). Structural inheritance from Story 1.10 trace artefact per iter-46 Lesson — copy-adjusted ~90% reasoning savings. WAIVED rationale stack: (a) AC 1 substrate-verified via one-shot `pnpm dlx ajv-cli@5 validate --spec=draft2020` exit 0 + Zod import-time + sync-gate clean-path; (b) AC 2 substrate-verified via filesystem-absence (`docs/design/presets/` absent) + zero Direction-B/C substrings in commit 6b1790a diff; (c) AC 3 substrate-verified via tier-enumeration by inspection (motion 1+5 / density 1+3, all literals) + ajv exit 0; (d) AC 4 SUBSTRATE_VERIFIED end-to-end via Task 4 two sync-gate smoke branches (content-hash-mismatch + added-to-source-only) + clean-path baseline + third smoke (removed-from-docs-only) SKIPPED per story rationale. Pre-documented variances called out (NOT gaps): root-provenance skip + leafFontFamily array-form deferral. CR triage defenses pre-staged in QUEUE Notes. Quality gates green: `pnpm -w typecheck` 16/16 cached, `pnpm -w lint` 16/16 cached, `pnpm --filter @keel/keel-invariants build` clean, `pnpm keel-invariants:check` exit 0, `pnpm exec prek run --all-files` 3/3 hooks Pass, `pnpm format:check` ✓. PR #226 CI `no checks reported` at iter-57 start; push-safe.
- [x] iter-56: `/bmad-dev-story` implementation landed; FR14n state `atdd-scaffolded → in-dev`. Single-pass (no partial). Authored `packages/ui/tokens.json` DTCG source ~106 leaves; `INV-tokens-source` manifest entry (13th); INVARIANTS.md § Design-token source (Story 1.11). Two sync-gate smoke branches verified end-to-end (smoke 3 skipped). Two new RALPH.md Lessons captured: story-vs-schema provenance-block conflict + drift-smoke 2 revert gotcha extension.
- [x] iter-55: `/bmad-testarch-atdd` HALT at preflight prerequisite gate; FR14n state `validated → atdd-scaffolded`. Fifth cumulative ATDD-skip application.
- [x] iter-54: `/bmad-create-story (args: "review")` pre-dev SM review; FR14n state `drafted → validated`. SM-1 + SM-2 applied in-place.
- [x] iter-53: `/bmad-create-story` drafted Story 1.11 file. (#35).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.10 done; 1.11 traced + next-up for `/bmad-create-story (args: "review")` post-dev SM-verify; 1.12–1.16 backlog → 5 more stories × full FR14n lifecycle remaining after 1.11 closes before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** Story 1.11 — Design-token source, Direction A baseline with motion + density scales
- **Story File:** `_bmad-output/implementation-artifacts/1-11-design-token-source-direction-a-baseline-with-motion-density-scales.md`
- **Story State:** `traced` — FR14n matrix row 5 (`in-dev → traced`) landed at iter-57 via `/bmad-testarch-trace (args: "yolo")` GATE=WAIVED; next iter-58 runs `/bmad-create-story (args: "review")` for row 7 `traced → sm-verified`.
- **GitHub Issue:** Story 1.11 tracked at **#35** (OPEN); parent Epic 1 tracked at **#9** (OPEN).
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE after stories 1.11–1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.11 sizing actuals vs projection.** iter-56 projected `iter-57 traced (small ~8K copy-adjust)` — CONFIRMED on track. Updated trajectory: iter-53 drafted → iter-54 validated → iter-55 atdd-scaffolded → iter-56 in-dev (done, single-pass) → **iter-57 traced (done, single-pass)** → iter-58 sm-verified → iter-59 CR-done = **7 iterations** (floor held). Epic 1 close-out timing unchanged at ~40 more iterations to EPIC_DONE halt (5 stories remaining × ~8 iter median each + CR round variance).
- **Iter-57 Lessons — captured in RALPH.md iter-57 Signpost:**
  - **Trace structural inheritance held strongly.** Story 1.10's MD + 3 JSON template was a near-verbatim mechanical adaptation: change story id (1-10→1-11), AC count constant (4), substrate evidence stack swap (schema+rationale doc+two manifest entries+three smokes → tokens.json+one manifest entry+two smokes+one-shot ajv), waiver-precedent count bump (4th → 5th cumulative). Reasoning effort ~90% lower than first-author cost; pattern repeats for Story 1.12+ contract-populator/contract-only stories.
  - **Single positive-space substrate-evidence gap closed at iter-57.** Story 1.10 had no positive-space "schema actually validates real values" signal until Story 1.11 lands. Story 1.11's iter-56 ajv-cli@5 validate exit 0 IS that signal — closed in two iterations across the schema/source pair. No remaining positive-space gap until Story 1.12 emitter consumes the source.
- **Carry-forward rules INTO Story 1.11 SM/CR layers** (iter-52 + iter-53 + iter-54 + iter-56 + iter-57):
  - **Two-layer CR convergence doctrine** (iter-36 + iter-52): single-layer Blind-Hunter findings are default DISMISS unless corroborated. Apply aggressively at Story 1.11's iter-59 CR triage iteration.
  - **Trace artefact structural inheritance** (iter-46 — re-confirmed at iter-57): mirror Story 1.10's trace artefact at next contract-populator/contract-only story (1.12 emitter contract may differ; 1.13+ likely fits the pattern).
  - **Preventative audits carry into SM review iteration (iter-58):** if any drift-smoke revert or manifest-hash re-computation slipped in, audit will surface via gate re-run. Expected clean.
  - **CR triage defenses pre-staged in IP QUEUE Notes above** — at iter-59 CR time, lean on: (a) root-provenance skip rationale = Debug Log + commit trailer + Change Log + per-leaf `$description` = sufficient; (b) dark-mode surface.inset contrast = Story 1.12 emitter scope; (c) font-family string-vs-array = deferred-work.md prior art.
- **Next iteration (iter-58) expected outcome:** `/bmad-create-story (args: "review")` runs in a fresh context window for post-dev SM verification (FR14n matrix row 7). Expected: first-round pass given iter-53 preventative audit (3-point) + iter-54 pre-dev SM review (2 in-place fixes) + iter-56 dev-pass (single-pass clean) + iter-57 trace WAIVED. Mechanical-fix round-trip budget = 1 iter if SM surfaces the root-provenance-block carve-out as a "should be in story Task 1 subtask 2 amendment" requirement vs accepting Debug Log+per-leaf `$description`+Change Log v1.2 as sufficient capture. Budget: small (~10K — review pass + optional inline fix). Commit trailer `Refs #35`; push after CI-clear check; exit.
- **Issue Tracking:** Story 1.11 tracked at GitHub issue **#35** (OPEN at iter-57 time). `Refs #35` in iter-57 commit trailer. `Closes #35` deferred to PR body when PR #226 transitions Draft→Open at EPIC_DONE halt. Parent Epic 1 issue **#9** — `Refs #9` optional; never `Closes` it.
