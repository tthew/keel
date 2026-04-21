# Implementation Plan

## NOW

- [ ] `/bmad-create-story (args: "review")` — FR14n row 7 `traced → sm-verified` post-dev SM requirements-satisfaction verification. Expected outcome: **FOURTH cumulative ZERO-PATCH post-dev SM precedent** (Stories 1.11 iter-58 + 1.12 iter-65 + 1.13 iter-72 + 1.14 iter-79). Independent fresh-context Sonnet Explore subagent verifier audits all 6 ACs against the committed implementation + live filesystem state: AC 1 (config + manifest shape — 4 smokes already PASS at iter-78 trace re-verify; AC satisfied), AC 2/3/4/5 (downstream Story 13.5 consumer — scope carve-out pre-affirmed by spec; SM verifier confirms substrate pins `bump-minor-pre-major:true`/`bump-patch-for-minor-pre-major:true`/intrinsic-breaking-parse/`include-v-in-tag:true`), AC 6 (3 new manifest entries + 3 new INVARIANTS.md anchors + `docs/invariants/release.md` verbatim architecture.md:1342 pointer + commit-type→semver mapping table — smokes 5+6 PASS at iter-78). Zero residual sm-review findings expected (all L1–L7 preventative audit layers held ZERO-PATCH at iter-77 dev-story; iter-75 pre-dev SM caught all residuals at the 2-PATCH precedent). Any unmet AC finding queues as QUEUE fix task at TOP.

## QUEUE (Story 1.14 — release-please monorepo config)

_(empty — post-dev SM fix tasks will be re-seeded only if findings emerge at iter-79; CR fix tasks at iter-80.)_

## BLOCKED

_(none)_

## DONE (current story/phase only)

- [x] iter-76: **FR14n row 3 `validated → atdd-scaffolded` via hybrid ground-(c) variant-(ii)+(iii) ATDD-skip clause.** EIGHTH cumulative Epic 1 ATDD-skip precedent (Stories 1.7 iter-2 / 1.8 iter-3 / 1.9 iter-4 / 1.10 iter-44 / 1.11 iter-55 / 1.12 iter-62 / 1.13 iter-69 → 1.14 iter-76). Skill `/bmad-testarch-atdd` NOT invoked. Single in-situ PATCH `seventh → eighth` at 3 sites. Sprint-status unchanged. No code changes.
- [x] iter-77: **FR14n row 4 `atdd-scaffolded → in-dev` via `/bmad-dev-story` SINGLE-PASS.** Configuration-surface delivery per IP forecast held verbatim: 3 NEW files (`.github/release-please-config.json` + `.github/.release-please-manifest.json` + `docs/invariants/release.md`) + 2 MODIFIED (`packages/keel-invariants/src/invariants.manifest.ts` +3 entries at end-of-raw, `INVARIANTS.md` +1 new H3 `### Release management (Story 1.14)` + 3 column-0 anchor bullets). Zero runtime code; zero test runner invoked (ATDD skip held). sha256 hashes pinned in manifest (config=`bd7a6c6c…`, manifest=`4df2aacf…`, rationale=`c37ac2a8…`). All 6 Task-7 substrate smokes PASS. Full quality-gate suite PASS. Seven preventative audit layers L1–L7 held ZERO-PATCH at dev-story time. **NEW Gotcha captured to RALPH.md** (manifest-build staleness): editing `invariants.manifest.ts` requires `pnpm --filter @keel/keel-invariants build` before `pnpm keel-invariants:check` sees the new entries.
- [x] iter-78: **FR14n row 5 `in-dev → traced` via `/bmad-testarch-trace (args: "yolo")`.** EIGHTH cumulative WAIVED precedent (Stories 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14). Four trace artefacts authored under `_bmad-output/test-artifacts/traceability/1-14-*` (coverage-matrix + e2e-trace-summary + gate-decision + full `.md` trace report). All 6 Task-7 substrate smokes re-verified LIVE at iter-78 with byte-identical outputs to iter-77 record: smoke 1 static JSON parse; smoke 2 `OK: single-bundled mode; 17 packages`; smoke 3 `OK: config-manifest key parity; 17 entries`; smoke 4 `OK: manifest-version parity across 17 entries`; smoke 5 `OK: 20 invariants` post-build; smoke 6 `pnpm keel-invariants:check-all` exit 0 silent (~2.9s). sha256 re-verification: all three pinned values byte-identical. AC 1 + AC 6 substrate-verified at CLI-exit-code level; AC 2/3/4/5 scope-carved to Story 13.5 downstream per § AC 5. Adversarial coverage delegated to iter-80 CR. No inline fixes needed (Story 1.14 does not touch the emitter; iter-71 SHA-drift class cannot recur). Story v1.4 Change Log row appended.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.13 done; 1.14 traced; 1.15 + 1.16 backlog — 2 more stories × full FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** 1.14 — release-please monorepo config (single-bundled mode). Key: `1-14-release-please-monorepo-config-single-bundled-mode`.
- **Story File:** `_bmad-output/implementation-artifacts/1-14-release-please-monorepo-config-single-bundled-mode.md`.
- **Story State:** `traced` — FR14n matrix row 7 next at iter-79 (`/bmad-create-story (args: "review")`; forecast FOURTH cumulative ZERO-PATCH post-dev SM).
- **GitHub Issue:** Story 1.14 at **#38** (OPEN). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.14 + 1.15 + 1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.14 forecast updated post-iter-78.** Trace gate held verbatim to iter-77 IP forecast: WAIVED-with-substrate-evidence; zero coverage gaps; 6 ACs all accounted for (AC 1 + AC 6 substrate-verified via smokes at CLI-exit-code level; AC 2/3/4/5 downstream Story-13.5 scope-carved). Trajectory for iter-79..iter-80: post-dev SM ZERO-PATCH-target (iter-79, state `traced → sm-verified`), CR ZERO-PATCH + 5–8 DEFER (iter-80, state `sm-verified → done`). 7-iteration `drafted → done` target on track (iter-74..iter-80 inclusive).
- **Carry-forward rules INTO iter-79 `/bmad-create-story (args: "review")` post-dev SM:**
  - SM verifier is an independent fresh-context Sonnet Explore subagent per Stories 1.11/1.12/1.13 iter-58/65/72 precedent.
  - Audits each of 6 ACs against live filesystem state + commit history + manifest entries + INVARIANTS.md anchor regex + sync-gate clean.
  - Expected: zero residual unmet-AC findings (all L1–L7 preventative audit layers held at iter-77 dev; iter-75 pre-dev SM caught residuals at 2-PATCH).
  - If a finding emerges, queue as QUEUE fix task at TOP with (AC id, what's missing in impl); re-run SM after fix.
  - AC 2/3/4/5 are scope-carved — SM verifier should affirm the carve-out language is self-consistent across the spec + substrate, not attempt to verify downstream Story 13.5 runtime.
- **Post-iter-78 state snapshot (for iter-79 verifier orientation):**
  - Committed files: 3 NEW (release-please-config.json, .release-please-manifest.json, release.md), 2 MODIFIED (invariants.manifest.ts, INVARIANTS.md), plus trace artefacts.
  - sha256s: config=`bd7a6c6c1aac702548bb512c0610633fcd84e630586ab91ad2bc78b577239318`; manifest=`4df2aacf54a9849e8e550377c5915cec6efe155b33834b200a6e0c81aedc42e8`; rationale=`c37ac2a89cc14d965f15cf2fe5a7695f0c9c0d1536e704d447f7b0a636ea547c`.
  - Manifest entry count: 20 (17 pre-Story-1.14 + 3 new).
  - `pnpm keel-invariants:check-all` exit 0 silent (verified live at iter-78).
- **Story 1.14 NOT absorbing** (route elsewhere):
  - Story 13.5 `.github/workflows/release-please.yml` — Epic 13 scope (AC 5 carve-out).
  - Story 1.15 `.github/renovate.json` — Epic 1 Story 1.15 scope.
  - Story 1.16 fork-extension pattern — Epic 1 Story 1.16 scope; Story 1.14 only notes the fork-extension pointer in `docs/invariants/release.md` § Fork extension.
- **Issue Tracking carry-forward.** Story 1.14 at **#38** OPEN; parent Epic 1 at **#9** OPEN. iter-78 commit trailer uses `Refs #38`.
