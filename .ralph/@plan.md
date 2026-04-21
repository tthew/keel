# Implementation Plan

## NOW

- [ ] `/bmad-create-story` — pick up Story 1.13 (design-token quality gates: schema validation + WCAG AA contrast + source-output sync gate) from sprint-status backlog; FR14n matrix row 1 `_(no story) → drafted`. Carry forward: (a) seven preventative audit layers (iter-53/54/56/59 + iter-60 Layer-7 gamut opt-out); (b) Story 1.12 compound-ZERO-PATCH doctrine — Story 1.13 is the canonical absorber for 7 of the 10 iter-66 CR defers (source-SHA resolver literal amendment per AA1; Task 6 prettier exclusion prose per AA2; sync-gate nomenclature alignment per AA3; resolveSourceSha 4x-per-run hoist; resolveSourceSha silent-fallback observability; walkLeaves schema-validation-fast-fail; parseInt breakpoint regex pin). Draft at iter-60 discipline level: enumerate every deferred-work absorption target at drafting time; pin every multi-choice dev decision to eliminate dev-time divergence (gate-emission format, schema-validation error shape, WCAG contrast math anchor, sync-gate invocation verb). Story 1.11 + 1.12 CR defers inventory: `deferred-work.md` lines 55-99 (Story 1.11: dark-mode status.fg, light-mode info/warning contrast, text/border.accent fail, surface-slot collapse, OKLCH gamut) + lines 101-110 (Story 1.12: all 10 CR defers above). Sizing forecast: ~45-55K (gate-authoring story; similar drafting scope to Story 1.12 iter-60 at ~45K — schema validation + contrast gate + sync gate = 3 gate surfaces with per-surface Tasks). Pre-flight: CI check + IP update + commit + push.

## QUEUE (Story 1.13 — design-token quality gates)

- [ ] `/bmad-create-story (args: "review")` — FR14n row 2 `drafted → validated`; target ≤2 in-place PATCHes matching Story 1.10/1.11/1.12 pre-dev SM precedent.
- [ ] `/bmad-testarch-atdd` — FR14n row 3 `validated → atdd-scaffolded`; SEVENTH cumulative ATDD-skip CANDIDATE per Story 1.7-1.12 precedent if ground-(c) hybrid variant-(ii)+(iii) clause holds; else ATDD scaffold if Story 1.13 introduces runtime probes.
- [ ] `/bmad-dev-story (args: "{story_file_path}")` — FR14n row 4 `atdd-scaffolded → in-dev`; single-pass candidate per Story 1.12 iter-63 precedent under preventative-audit pre-resolution.
- [ ] `/bmad-testarch-trace (args: "yolo")` — FR14n row 5 `in-dev → traced`; SEVENTH WAIVED CANDIDATE; structural inheritance from Story 1.12 applies if AC count ≤ 6.
- [ ] `/bmad-create-story (args: "review")` post-dev — FR14n row 7 `traced → sm-verified`; ZERO-PATCH CANDIDATE (third compound precedent) per iter-58/iter-65 doctrine.
- [ ] `/bmad-code-review (args: "2")` — FR14n row 9 `sm-verified → done`; ZERO-PATCH + 8-12 DEFER forecast per Story 1.12 iter-66 emitter/gate-class scaling (range-tracking AC count × logic-layer complexity).

## BLOCKED

_(none)_

## DONE (Story 1.12 closed at iter-66 done; 7-iteration floor trajectory held exactly)

- [x] iter-66: **`/bmad-code-review (args: "2")` final CR gate; FR14n state `sm-verified → done` per matrix row 9.** **ZERO-PATCH + 10 DEFER first-round outcome — Story 1.12 THIRD cumulative ZERO-PATCH CR precedent** (matches Story 1.10 iter-52 RE-RUN + Story 1.11 iter-59 first-round exactly). Three-layer adversarial review on commit `c14b6df` code surface (Ralph-bookkeeping excluded; 898-line code surface at `.ralph/tmp/story-1-12-cr-diff.patch`): Blind Hunter 21 findings diff-only; Edge Case Hunter 55+ JSON path-enumeration findings; Acceptance Auditor 3 spec deviations (AA1 source-SHA resolver literal; AA2 `.prettierignore` Task 6 bypass; AA3 manifest description paraphrase). Triage: 0 PATCH / 0 DECISION-NEEDED / **10 DEFER** / 26 DISMISS. All 10 defers in `deferred-work.md` under heading `## Deferred from: code review of 1-12-token-emitter-pipeline... (2026-04-21)`: (1) AA1 source-SHA resolver literal → Story 1.13 spec amendment (ZERO-PATCH doctrine per iter-65 precedent); (2) AA2 `.prettierignore` Task 6 bypass → Story 1.13 Task 6 prose amendment; (3) AA3 manifest description paraphrase → Story 1.13 sync-gate nomenclature; (4) BH#2+EH resolveSourceSha 4× per run (TOCTOU+perf) → Story 1.13 reliability; (5) BH#1+EH(5-vector) resolveSourceSha silent fallback → Story 1.13 observability; (6) BH#4+EH alias-cycle diamond-DAG false-positive → Story 1.13 test harness; (7) BH#5+EH walkLeaves drops non-leaf non-object → Story 1.13 schema validation; (8) BH#7+EH REPO_ROOT brittle → reliability follow-up / Epic 3; (9) BH#9+EH parseInt breakpoint garbage → Story 1.13 schema validation; (10) BH#19+EH fontSize hardcoded lineHeight 1.5 → Epic 7 Story 7-1 / Epic 3 Story 3-X. Story file v1.4 Change Log row appended + `### Review Findings` subsection with 10 `- [x] [Review][Defer]` bullets + 26-item dismissed-as-noise list. Sprint-status `last_updated: 2026-04-21 Story-1-12-CR-done UTC` (both sites). **Compound-ZERO-PATCH discipline held across all 6 FR14n post-drafting gates for Story 1.12**: drafted (iter-60) → validated (iter-61 2 PATCHes, 1 DEFER) → atdd-scaffolded (iter-62 skip) → in-dev (iter-63 single-pass) → traced (iter-64 WAIVED) → sm-verified (iter-65 ZERO-PATCH) → done (iter-66 ZERO-PATCH + 10 DEFER). **Story 1.12 complete.** Next iter-67 runs `/bmad-create-story` for Story 1.13 — FR14n matrix row 1 `_(no story) → drafted`.
- [x] iter-65: `/bmad-create-story (args: "review")` post-dev SM ZERO-PATCH pass; `traced → sm-verified`. Second cumulative ZERO-PATCH SM (Story 1.11 iter-58 + Story 1.12 iter-65). Pre-flagged iter-64 AA1 source-SHA resolver deviation resolved ZERO-PATCH via iter-58 doctrine three-prong (structurally-impossible-literal + fully-documented + does-not-violate-prose). Story file v1.3 row.
- [x] iter-64: `/bmad-testarch-trace (args: "yolo")` WAIVED; `in-dev → traced`. SIXTH cumulative WAIVED (Stories 1.7-1.12). Structural inheritance from Story 1.11 at ~90% saving (4-AC→6-AC scale). Hybrid ground-(c) variant-(ii)+(iii) holds at trace-WAIVED gate (as at ATDD-skip iter-62).
- [x] iter-63: `/bmad-dev-story` single-pass; `atdd-scaffolded → in-dev`; BMad `ready-for-dev → done` direct-jump. 6/6 ACs + 6/6 Tasks. Emitter 274 lines; three byte-stable outputs (CSS 118 / Tailwind 119 / Python 135) + sibling `__init__.py`. INV-tokens-emitter registered (13→14). Two determinism smokes PASS. Source-SHA resolver command correction documented.
- [x] iter-62: `/bmad-testarch-atdd` SIXTH cumulative ATDD-skip; `validated → atdd-scaffolded`. Three-ground conjunction satisfied.
- [x] iter-61: `/bmad-create-story (args: "review")` pre-dev; `drafted → validated`. 2 in-place PATCHes + 1 DEFER.
- [x] iter-60: `/bmad-create-story` drafted; `_(no story) → drafted`. 6 ACs + 6 Tasks; seven preventative-audit layers pre-applied.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.12 done; 1.13–1.16 backlog → 4 more stories × full FR14n lifecycle remaining before EPIC_DONE halt)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** _(no story — Story 1.12 closed at iter-66 done; Story 1.13 pending drafting at iter-67)_
- **Story File:** n/a
- **Story State:** _(no story)_ — FR14n matrix row 1 pending at iter-67 `/bmad-create-story` for Story 1.13.
- **GitHub Issue:** Story 1.12 at **#36** (closes on PR #226 merge at EPIC_DONE). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt). Story 1.13 issue TBD at iter-67 drafting.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE after stories 1.13–1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.12 7-iteration floor held exactly**: iter-60 drafted → iter-61 validated → iter-62 atdd-scaffolded → iter-63 in-dev → iter-64 traced → iter-65 sm-verified → iter-66 done = 7 iters (matches Story 1.11 iter-53..iter-59). Triple-compound discipline: 3rd cumulative ZERO-PATCH CR (Stories 1.10/1.11/1.12), 2nd cumulative ZERO-PATCH SM (Stories 1.11/1.12), 6th cumulative WAIVED trace (Stories 1.7-1.12), 6th cumulative ATDD-skip (Stories 1.7-1.12). Compound-ZERO-PATCH across 6 FR14n post-drafting gates for Story 1.12 (drafted→validated→atdd-scaffolded→in-dev→traced→sm-verified→done) — preventative-audit discipline returns linearly across gates.
- **Carry-forward rules INTO Story 1.13 + downstream (iter-67+) — COMPOUNDING PRIOR ART:**
  - **Seven preventative audit layers** (iter-53/54/56/59 + iter-60 L7). Pre-apply at Story 1.13 drafting.
  - **Story 1.11/1.12 ZERO-PATCH discipline doctrine** (iter-58 + iter-59 + iter-65 + iter-66 REPLICATED): "structurally impossible + fully documented + does not violate AC text = ACCEPT"; applies at SM, CR, and (iter-66 NEW insight) at command-literal vs command-intent disputes. Three-prong test scales to SM AND CR gates when pre-staged defenses match.
  - **Multi-layer-corroborated authoring-choice findings are DEFER, not PATCH** (iter-59 + iter-66 REPLICATED at 10-DEFER ceiling). When ECH/BH flags an authoring decision that the story-task text mandates, route to downstream gate story via DEFER with concrete carry-to target — do NOT inline retune. Applies to Story 1.13+ CR triage.
  - **Single-layer BH/EH findings default DISMISS unless corroborated** (iter-36 + iter-52 + iter-59 + iter-66 REPLICATED at 26 dismisses). Holds across populator + emitter stories. Apply to Story 1.13+ CR triage.
  - **Structural trace inheritance ~90% savings** (iter-46 + iter-57 + iter-64 REPLICATED; scales 4-AC → 6-AC with no cost tax). Re-apply at Story 1.13+ trace.
  - **Scoped-build optimisation** (iter-51 + iter-56 + iter-63): after manifest mutation, run `pnpm --filter @keel/keel-invariants build` before `pnpm keel-invariants:check`.
  - **Drift-smoke revert patterns** (iter-45 new-untracked + iter-56 tracked-uncommitted + iter-63 tokens.json `git checkout --`).
  - **Ground-(c) hybrid variant-(ii)+(iii) unlocks BOTH ATDD-skip AND trace-WAIVED** for substrate+tooling stories with runtime-probe deferral + spec-declared CR-substitution clause.
  - **Compound-ZERO-PATCH achievable under 5 conditions** (iter-66 NEW): (a) seven preventative-audit layers pre-applied; (b) pre-dev SM ≤2 PATCHes; (c) single-pass dev zero scope deviations; (d) trace landed clean; (e) CR defenses pre-documented at dev time for pre-staged AA findings. Apply at Story 1.13+.
  - **CR "5-10 DEFER" target is AC-count × logic-layer scaled** (iter-66 NEW): populator ≈5 DEFER; emitter/gate ≈8-12 DEFER. Use at Story 1.13+ CR forecast.
  - **`/bmad-code-review (args: "2")` arg "2" = "Leave as action items"**; when all findings are defer/dismiss, step-04 clean-review shortcut → § 6 sprint-status-update → done. arg "2" is vacuous in ZERO-PATCH case but required to force the non-interactive branch.
- **Story 1.13 DEFER absorption roadmap (from iter-59 + iter-66 deferred-work.md):**
  - AA1 source-SHA resolver literal: amend Story 1.12 § AC 1 carve-out literal command to `git log` intent-matching form at Story 1.13 drafting time.
  - AA2 `.prettierignore` Task 6 bypass: amend Story 1.12 Task 6 prose to exclude emitted outputs + document emitter-owns-byte-form contract clause.
  - AA3 manifest description paraphrase: formalise sync-gate invocation nomenclature (`--check` vs `re-run + diff`) + align `invariants.manifest.ts:155`.
  - BH+EH resolveSourceSha 4× per run: hoist SHA resolution to `main`; pass through as param.
  - BH+EH resolveSourceSha silent fallback: distinguish `uncommitted` vs `git-missing` vs `stderr-error` in provenance header.
  - BH+EH alias-cycle diamond-DAG: add synthetic diamond-DAG fixture; key `visited` on resolved-leaf identity.
  - BH+EH walkLeaves non-leaf drop: schema-validate tokens.json before emitter runs.
  - BH+EH parseInt breakpoint: regex-pin breakpoint `$value` to `/^\d+px$/`.
  - Dark-mode `status.*.fg` / light-mode info/warning / text/border.accent: Story 1.13 WCAG AA contrast gate scope (iter-59 defers).
  - OKLCH out-of-gamut: Story 1.13 contrast gate — gamut-map before AA math (iter-59 defer).
- **Story 1.13 NOT absorbing (route elsewhere):**
  - BH+EH REPO_ROOT brittle → reliability follow-up story OR Epic 3 (`packages/ralph` install-boundary scope).
  - BH+EH fontSize hardcoded lineHeight 1.5 → Epic 7 Story 7-1 (consumer) OR Epic 3 Story 3-X.
  - Shadow-machinery (iter-59 defer #4): Story 1.12 OUT OF SCOPE per § AC 6 carve-out; new Story-1.17-TBD or Epic 7 follow-up.
  - Gamut-mapping (iter-59 defer #5): Story 1.12 OPT-OUT default; re-DEFER at Story 1.13 contrast gate drafting.
- **Issue Tracking carry-forward.** Parent Epic 1 at **#9** OPEN (never `Closes`; Ralph transitions at EPIC_DONE halt). Story 1.12 at **#36** OPEN (closes on PR merge at EPIC_DONE). Story 1.13 issue TBD at iter-67 drafting. iter-66 commit trailer uses `Refs #9` (parent-epic fallback; `RALPH_ISSUE_NUMBER` env var likely still unset per ralph.py IP-Context-Story parse-lag — Story 1.12 was already `sm-verified` at iter-66 start but IP Context Story field still reads Story 1.12 so ralph.py may or may not resolve the issue).
