# Implementation Plan

## NOW

- [ ] `/bmad-testarch-atdd` — FR14n row 3 `validated → atdd-scaffolded`. Expected ATDD-SKIP per § Testing Standards hybrid ground-(c) variant-(ii)+(iii) (no test runner; substrate verification covers AC 1 + AC 6; adversarial-CR substitution covers AC 2/3/4/5 downstream-consumer behaviour). Seventh cumulative ATDD-skip precedent after Stories 1.7-1.13.

## QUEUE (Story 1.14 — release-please monorepo config)

_(empty — fix tasks will be re-seeded only if trace or CR emit findings.)_

## BLOCKED

_(none)_

## DONE (current story/phase only)

- [x] iter-74: **FR14n row 1 `_(no story) → drafted` via `/bmad-create-story`.** Story 1.14 (`release-please monorepo config — single-bundled mode`) picked from sprint-status + drafted. 6 ACs + 7 Tasks + seven preventative audit layers pre-applied per iter-67/73 compound-ZERO-PATCH carry-forward. Three new invariants registered: `INV-release-please-config` + `INV-release-please-manifest` + `INV-release-please-rationale`; manifest grows 17 → 20. Scope carve-outs pinned: Story 13.5 workflow is downstream; architecture.md source-tree drift resolved in favor of epic AC; Task 6 explicit no-op protects hash-cascade. Hybrid ground-(c) variant-(ii)+(iii) ATDD-skip pre-staged in § Testing Standards (seventh precedent). sprint-status: `1-14-...: backlog → ready-for-dev`. Story State: `_(no story) → drafted`.
- [x] iter-75: **FR14n row 2 `drafted → validated` via `/bmad-create-story (args: "review")`.** Pre-dev SM review landed **2 PATCH** (matches Story 1.11/1.12/1.13 iter-54/61/68 ≤2 PATCH precedent — THIRD cumulative 2-PATCH SM review in the carry-forward). **PATCH 1 (L5 residual — count drift):** story narrative claimed 17 workspace packages / 16 `packages/*` / 18-key `packages:` map / 18 manifest entries; actual repo has **16 workspace members** (1 apps/web + 15 packages/*) / **17-key** `packages:` map (16 members + root `.`) / **17 manifest entries**. Corrected across 12 sites: User Story (1), AC 1 text + scope carve-out (2), Task 1 header + verification (2), Task 2 shape + cross-verify (2), Task 4 both invariant descriptions (2), Task 5 both anchor bullets (2), Task 7 both smoke commands (2), Dev Notes L4 + L5 layer claims (2) — total 15 line edits. **Task 7 smoke commands would have THROWN on dev-story execution** (`expected 18 packages; got 17`) — NOW correctly pinned at 17 so the smokes will pass. **PATCH 2 (§ References citation drift):** story cited architecture.md § 1.0 distribution at line 532 — actual line 532 is a § Naming conventions / markdown-docs bullet; the "no npm publish at 1.0" claim lives at architecture.md:80 inside § Technical Constraints & Dependencies. Corrected at both Dev Notes reference + § References line. L1/L2/L3/L6/L7 layers: no residuals. § Change Log v1.1 row added. Story State: `drafted → validated`. Budget: ~60K (orient ~8K + story read ~20K + 3 parallel verification subagents ~12K + patch + IP + RALPH.md ~20K).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.13 done; 1.14 validated; 1.15 + 1.16 backlog — 2 more stories × full FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** 1.14 — release-please monorepo config (single-bundled mode). Key: `1-14-release-please-monorepo-config-single-bundled-mode`.
- **Story File:** `_bmad-output/implementation-artifacts/1-14-release-please-monorepo-config-single-bundled-mode.md`.
- **Story State:** `validated` — FR14n matrix row 3 next at iter-76 (`/bmad-testarch-atdd` expected ATDD-SKIP per § Testing Standards).
- **GitHub Issue:** Story 1.14 at **#38** (OPEN). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.14 + 1.15 + 1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.14 forecast updated post-iter-75.** Pre-dev SM review landed ≤2 PATCH target (third cumulative 2-PATCH SM review). Preventative audit layers L1-L3 + L6-L7 held clean; L4 + L5 had residual count-drift that PATCH 1 corrected. Trajectory for iter-76..iter-80: ATDD-SKIP ceremony (iter-76, state `validated → atdd-scaffolded`), single-pass dev-story (iter-77, state `atdd-scaffolded → in-dev`), trace WAIVED-with-substrate-evidence (iter-78, state `in-dev → traced`), post-dev SM review ZERO-PATCH-target (iter-79, state `traced → sm-verified`), CR ZERO-PATCH + 5-8 DEFER (iter-80, state `sm-verified → done`). 7-iteration `drafted → done` target holds.
- **Carry-forward rules INTO iter-76 `/bmad-testarch-atdd`:**
  - Expected HALT at Step 1.2 test-framework preflight (no `vitest.config.*` / `jest.config.*` / `playwright.config.*` anywhere in tree — Story 1.16 scope). Record the HALT as the ATDD-SKIP realization; update IP + sprint-status; state flips to `atdd-scaffolded`.
  - § Testing Standards already carries the hybrid ground-(c) variant-(ii)+(iii) rationale verbatim — no new IP text needed; just pointer to § Testing Standards.
- **L5 enhancement candidate for post-retrospective RALPH.md Lessons.** The iter-75 count drift was a GENUINE L5 residual that the L5 layer's own "mental-check" claim explicitly asserted was held at drafting time — BUT the mental-check miscounted packages (16 claimed; 15 actual). This is evidence that mental-counting is not a reliable L5 substitute for an actual `ls -d apps/*/ packages/*/ | wc -l` run during drafting. Post-Epic-1 retrospective candidate: promote an **L5b — verify-with-shell-command-not-mental-count** sub-layer to RALPH.md Lessons.
- **Story 1.14 NOT absorbing** (route elsewhere):
  - Story 13.5 `.github/workflows/release-please.yml` — Epic 13 scope (AC 5 carve-out).
  - Story 1.15 `.github/renovate.json` — Epic 1 Story 1.15 scope.
  - Story 1.16 fork-extension pattern — Epic 1 Story 1.16 scope; Story 1.14 only notes the fork-extension pointer in `docs/invariants/release.md` § Fork extension.
- **Issue Tracking carry-forward.** Story 1.14 at **#38** OPEN; parent Epic 1 at **#9** OPEN. iter-75 commit trailer uses `Refs #38` (story issue now resolved by ralph.py this iteration).
