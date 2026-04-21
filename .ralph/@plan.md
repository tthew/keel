# Implementation Plan

## NOW

- [ ] `/bmad-code-review (args: "2")` — FR14n row 9 `sm-verified → done` (or `sm-verified → fixes-pending` if findings promote). Expected outcome: **FOURTH cumulative ZERO-PATCH CR precedent** (Stories 1.11 iter-59 + 1.12 iter-66 + 1.13 iter-73 + 1.14 iter-80) for contract-only / contract-populator / data-only / gate-authoring / configuration-surface substrate stories; forecast 5–8 DEFER action items (lower complexity surface than 10-13-DEFER gate-authoring stories). Adversarial three-layer fan-out: Blind Hunter (diff-only) + Edge Case Hunter (diff + repo-read) + Acceptance Auditor (AC-verification). Pre-selects "Create action items" per args "2". Any CR finding queues as QUEUE fix task at TOP with (file, line, requested change); adversarial triage is the default per `⊗ EVERY CR action item becomes a QUEUE fix task unless IP records defer: <reason> per item`. At iter-80 close: if zero non-deferred findings → Story State `sm-verified → done`; Story 1.14 complete → next per § Halt rule is `/bmad-create-story` for Story 1.15 (Epic 1 still has 1.15 + 1.16 before EPIC_DONE halt).

## QUEUE (Story 1.14 — release-please monorepo config)

_(empty — CR fix tasks will be re-seeded only if non-DEFER findings emerge at iter-80.)_

## BLOCKED

_(none)_

## DONE (current story/phase only)

- [x] iter-77: **FR14n row 4 `atdd-scaffolded → in-dev` via `/bmad-dev-story` SINGLE-PASS.** Configuration-surface delivery per IP forecast held verbatim: 3 NEW files (`.github/release-please-config.json` + `.github/.release-please-manifest.json` + `docs/invariants/release.md`) + 2 MODIFIED (`packages/keel-invariants/src/invariants.manifest.ts` +3 entries at end-of-raw, `INVARIANTS.md` +1 new H3 `### Release management (Story 1.14)` + 3 column-0 anchor bullets). Zero runtime code; zero test runner invoked (ATDD skip held). sha256 hashes pinned in manifest (config=`bd7a6c6c…`, manifest=`4df2aacf…`, rationale=`c37ac2a8…`). All 6 Task-7 substrate smokes PASS. Full quality-gate suite PASS. Seven preventative audit layers L1–L7 held ZERO-PATCH at dev-story time. **NEW Gotcha captured to RALPH.md** (manifest-build staleness): editing `invariants.manifest.ts` requires `pnpm --filter @keel/keel-invariants build` before `pnpm keel-invariants:check` sees the new entries.
- [x] iter-78: **FR14n row 5 `in-dev → traced` via `/bmad-testarch-trace (args: "yolo")`.** EIGHTH cumulative WAIVED precedent (Stories 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14). Four trace artefacts authored under `_bmad-output/test-artifacts/traceability/1-14-*` (coverage-matrix + e2e-trace-summary + gate-decision + full `.md` trace report). All 6 Task-7 substrate smokes re-verified LIVE at iter-78 with byte-identical outputs to iter-77 record. sha256 re-verification: all three pinned values byte-identical. AC 1 + AC 6 substrate-verified at CLI-exit-code level; AC 2/3/4/5 scope-carved to Story 13.5 downstream per § AC 5. Adversarial coverage delegated to iter-80 CR. Story v1.4 Change Log row appended.
- [x] iter-79: **FR14n row 7 `traced → sm-verified` via `/bmad-create-story (args: "review")` post-dev SM.** FOURTH cumulative ZERO-PATCH post-dev SM precedent (Stories 1.11 iter-58 + 1.12 iter-65 + 1.13 iter-72 + 1.14 iter-79). Independent fresh-context Sonnet Explore subagent audited all 6 ACs against committed implementation + live filesystem state. **All 6 ACs MET / SCOPE-CARVED:** AC 1 MET (config + manifest shape; 17-key parity + `0.0.0` × 16); AC 2/3/4/5 MET / SCOPE-CARVED per AC 5 carve-out (substrate pins all 4 pre-requisites; downstream Story 13.5 runtime out of scope by construction); AC 6 MET (all 7 required sections in `docs/invariants/release.md` + verbatim architecture.md:1342 quote + 3 manifest entries with correct shape + 3 INVARIANTS.md anchors + 3 contentHash byte-identical to `sha256sum` live). All seven preventative audit layers L1–L7 held at SM time. Zero residual unmet-AC findings. Two non-blocking verifier observations for iter-80 CR (both already by-design, not findings). Zero PATCHes applied; single v1.5 Change Log row on Story 1.14 spec. Next iter-80: `/bmad-code-review (args: "2")` CR.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.13 done; 1.14 sm-verified; 1.15 + 1.16 backlog — 2 more stories × full FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** 1.14 — release-please monorepo config (single-bundled mode). Key: `1-14-release-please-monorepo-config-single-bundled-mode`.
- **Story File:** `_bmad-output/implementation-artifacts/1-14-release-please-monorepo-config-single-bundled-mode.md`.
- **Story State:** `sm-verified` — FR14n matrix row 9 next at iter-80 (`/bmad-code-review (args: "2")`; forecast FOURTH cumulative ZERO-PATCH + 5–8 DEFER).
- **GitHub Issue:** Story 1.14 at **#38** (OPEN). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.14 + 1.15 + 1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.14 forecast updated post-iter-79.** Post-dev SM held verbatim to iter-78 IP forecast: ZERO-PATCH across all 6 ACs with independent fresh-context Sonnet verifier; zero residual findings. Trajectory for iter-80: CR ZERO-PATCH + 5–8 DEFER target per configuration-surface substrate scale (Stories 1.11–1.13 ran 5–13 DEFER at CR; configuration-surface is at the lower end). 7-iteration `drafted → done` target on track (iter-74..iter-80 inclusive).
- **Carry-forward rules INTO iter-80 `/bmad-code-review (args: "2")` CR:**
  - Three-layer adversarial fan-out — Blind Hunter (diff-only), Edge Case Hunter (diff + repo-read), Acceptance Auditor (AC-verification).
  - args "2" pre-selects "Create action items" — findings default to QUEUE fix tasks unless IP records `defer: <reason>`.
  - Expected surface: 5–8 DEFER action items (lower-complexity configuration-surface; vs 10-13 at gate-authoring Stories 1.11/1.12/1.13).
  - No cascade scope — CR reads diff of iter-77 dev-story commit + the sm-review ZERO-PATCH context.
  - Two non-blocking iter-79 verifier observations to watch-for at CR (both are by-design, not findings):
    1. Story 13.5 workflow-author pinning `.github/`-prefixed `config-file` + `manifest-file` action inputs (already stated in `release.md` § Consumption).
    2. Future whitespace/formatting changes to the 3 substrate files require a Story 1.9 sync-gate hash-update run (by-design behaviour).
  - If CR emits findings, queue as QUEUE fix task at TOP with (file, line, requested change); re-run `/bmad-code-review` after fixes to confirm `done`.
- **Post-iter-79 state snapshot (for iter-80 CR orientation):**
  - Committed files: 3 NEW (release-please-config.json, .release-please-manifest.json, release.md), 2 MODIFIED (invariants.manifest.ts, INVARIANTS.md), plus trace artefacts + Story spec v1.5 Change Log row.
  - sha256s: config=`bd7a6c6c1aac702548bb512c0610633fcd84e630586ab91ad2bc78b577239318`; manifest=`4df2aacf54a9849e8e550377c5915cec6efe155b33834b200a6e0c81aedc42e8`; rationale=`c37ac2a89cc14d965f15cf2fe5a7695f0c9c0d1536e704d447f7b0a636ea547c`.
  - Manifest entry count: 20 (17 pre-Story-1.14 + 3 new).
  - `pnpm keel-invariants:check-all` exit 0 silent (verified live at iter-78; no changes since).
- **Story 1.14 NOT absorbing** (route elsewhere):
  - Story 13.5 `.github/workflows/release-please.yml` — Epic 13 scope (AC 5 carve-out).
  - Story 1.15 `.github/renovate.json` — Epic 1 Story 1.15 scope.
  - Story 1.16 fork-extension pattern — Epic 1 Story 1.16 scope; Story 1.14 only notes the fork-extension pointer in `docs/invariants/release.md` § Fork extension.
- **Issue Tracking carry-forward.** Story 1.14 at **#38** OPEN; parent Epic 1 at **#9** OPEN. iter-79 commit trailer uses `Refs #38`.
