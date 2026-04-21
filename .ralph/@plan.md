# Implementation Plan

## NOW

- [ ] `/bmad-testarch-trace (args: "yolo")` — FR14n row 5 `in-dev → traced`. Expected outcome: **WAIVED-with-substrate-evidence** per the Epic-1-substrate ATDD-skip → trace-WAIVED precedent chain (Stories 1.7 iter-5 / 1.8 iter-5 / 1.9 iter-6 / 1.10 iter-46 / 1.11 iter-57 / 1.12 iter-64 / 1.13 iter-71 = SEVEN-cumulative WAIVED). Story 1.14 follows at EIGHTH cumulative. Task 7 six-smoke bundle (static JSON parse, single-bundled shape, config-manifest key-parity, manifest-version parity, manifest-load, sync-gate clean — all observed PASS at iter-77) is the substrate backstop; adversarial Wave-2 coverage delegated to CR (iter-80). 4 ACs (2/3/4/5) describe downstream Story 13.5 consumer behaviour explicitly carved out of Story 1.14 scope. Artefacts expected under `_bmad-output/test-artifacts/traceability/1-14-*` (matrix / coverage / summary / gate-decision). Zero coverage gaps anticipated as fix tasks (matches Story 1.7..1.13 cumulative precedent).

## QUEUE (Story 1.14 — release-please monorepo config)

_(empty — trace / SM / CR fix tasks will be re-seeded only if findings emerge at iter-78 / iter-79 / iter-80.)_

## BLOCKED

_(none)_

## DONE (current story/phase only)

- [x] iter-75: **FR14n row 2 `drafted → validated` via `/bmad-create-story (args: "review")`.** Pre-dev SM review landed **2 PATCH** (third cumulative ≤2 PATCH precedent). PATCH 1 (L5 residual): systemic packages-count off-by-one corrected across 12 sites (17 workspace / 16 packages/* / 18-key map / 18 entries → 16 / 15 / 17 / 17). PATCH 2 (§ References citation drift): architecture.md § 1.0 distribution line 532 wrong; corrected to § Technical Constraints & Dependencies line 80. Task 7 smokes now expect 17 (would otherwise have THROWN on dev-story). L1/L2/L3/L6/L7 layers: clean.
- [x] iter-76: **FR14n row 3 `validated → atdd-scaffolded` via hybrid ground-(c) variant-(ii)+(iii) ATDD-skip clause.** EIGHTH cumulative Epic 1 ATDD-skip precedent (Stories 1.7 iter-2 / 1.8 iter-3 / 1.9 iter-4 / 1.10 iter-44 / 1.11 iter-55 / 1.12 iter-62 / 1.13 iter-69 → 1.14 iter-76). Skill `/bmad-testarch-atdd` NOT invoked. Single in-situ PATCH `seventh → eighth` at 3 sites. Sprint-status unchanged. No code changes.
- [x] iter-77: **FR14n row 4 `atdd-scaffolded → in-dev` via `/bmad-dev-story` SINGLE-PASS.** Configuration-surface delivery per IP forecast held verbatim: 3 NEW files (`.github/release-please-config.json` + `.github/.release-please-manifest.json` + `docs/invariants/release.md`) + 2 MODIFIED (`packages/keel-invariants/src/invariants.manifest.ts` +3 entries at end-of-raw, `INVARIANTS.md` +1 new H3 `### Release management (Story 1.14)` + 3 column-0 anchor bullets). Zero runtime code; zero test runner invoked (ATDD skip held). sha256 hashes pinned in manifest (config=`bd7a6c6c…`, manifest=`4df2aacf…`, rationale=`c37ac2a8…`) and verified byte-identical to on-disk shasum. All 6 Task-7 substrate smokes PASS: static JSON parse (both files), single-bundled-mode shape (`17 packages`), config-manifest key-parity (`17 entries`), manifest-version parity (`17 entries all 0.0.0`), manifest-load (`20 invariants` post-`pnpm --filter @keel/keel-invariants build`), sync-gate clean (0.63s / 2s budget = 69% margin). Full quality-gate suite PASS: `pnpm typecheck` FULL-TURBO cache hit, `pnpm lint` FULL-TURBO cache hit, `pnpm format:check` Prettier clean, `pnpm keel-invariants:check-all` (sync-gate + tokens-sync both exit 0). Sprint-status: `1-14-…: ready-for-dev → in-progress → review`. Seven preventative audit layers L1–L7 held ZERO-PATCH at dev-story time. **NEW Gotcha captured to RALPH.md** (manifest-build staleness): editing `invariants.manifest.ts` requires `pnpm --filter @keel/keel-invariants build` before `pnpm keel-invariants:check` sees the new entries — the check reads `dist/check.js` which imports the compiled manifest, not the TS source.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.13 done; 1.14 in-dev; 1.15 + 1.16 backlog — 2 more stories × full FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** 1.14 — release-please monorepo config (single-bundled mode). Key: `1-14-release-please-monorepo-config-single-bundled-mode`.
- **Story File:** `_bmad-output/implementation-artifacts/1-14-release-please-monorepo-config-single-bundled-mode.md`.
- **Story State:** `in-dev` — FR14n matrix row 5 next at iter-78 (`/bmad-testarch-trace (args: "yolo")`; forecast WAIVED-with-substrate-evidence).
- **GitHub Issue:** Story 1.14 at **#38** (OPEN). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.14 + 1.15 + 1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.14 forecast updated post-iter-77.** Single-pass dev-story held; zero partial completion; zero residual Task work. Trajectory for iter-78..iter-80: trace WAIVED-with-substrate-evidence (iter-78, state `in-dev → traced`), post-dev SM review ZERO-PATCH-target (iter-79, state `traced → sm-verified`), CR ZERO-PATCH + 5-8 DEFER (iter-80, state `sm-verified → done`). 7-iteration `drafted → done` target on track (iter-74..iter-80 inclusive).
- **Carry-forward rules INTO iter-78 `/bmad-testarch-trace (args: "yolo")`:**
  - 6 ACs total; AC 1 + AC 6 exercised by Task 7 smokes at substrate level (PASS); AC 2/3/4/5 describe downstream Story-13.5 consumer behaviour explicitly carved out.
  - Expected trace outcome: **WAIVED-with-substrate-evidence** (EIGHTH cumulative Epic 1 ATDD-skip → trace-WAIVED chain). Rationale: 4 P2 ACs, 0% automated coverage (no test runner), substrate smokes are the backstop, adversarial Wave-2 delegated to CR.
  - Zero coverage gaps expected as fix tasks (matches Stories 1.7..1.13 cumulative precedent). If gaps emerge, queue fix tasks at TOP per § Story Lifecycle Decision Matrix row 5.
  - Expected artefacts: `_bmad-output/test-artifacts/traceability/1-14-*` (matrix / coverage / summary / gate-decision — four files per Story 1.13 iter-71 pattern).
  - Quality-gate suite rerun expected (substrate verification, no new functionality): `pnpm typecheck && pnpm lint && pnpm format:check && pnpm keel-invariants:check-all` — all expected PASS.
- **L5c candidate confirmed (post-Epic-1 retrospective).** The iter-74 drafting carried "seventh" from Story 1.13 drafting without incrementing; iter-75 pre-dev SM review didn't catch it either. iter-76 spec-level ATDD commit caught + fixed it as a v1.2 PATCH. L5c — "increment-not-carry-over sequence counts" — belongs as a new sub-layer of L5 in the seven-layer audit checklist, DISTINCT from L5a (cross-file line-number staleness) and L5b (cross-file collection cardinality). Not retrofitted to IP Lessons here; defer to Epic 1 retrospective.
- **Story 1.14 NOT absorbing** (route elsewhere):
  - Story 13.5 `.github/workflows/release-please.yml` — Epic 13 scope (AC 5 carve-out).
  - Story 1.15 `.github/renovate.json` — Epic 1 Story 1.15 scope.
  - Story 1.16 fork-extension pattern — Epic 1 Story 1.16 scope; Story 1.14 only notes the fork-extension pointer in `docs/invariants/release.md` § Fork extension.
- **Issue Tracking carry-forward.** Story 1.14 at **#38** OPEN; parent Epic 1 at **#9** OPEN. iter-77 commit trailer uses `Refs #38`.
