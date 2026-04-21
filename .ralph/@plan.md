# Implementation Plan

## NOW

- [ ] `/bmad-testarch-trace (args: "yolo")` — FR14n row 5 `in-dev → traced`; SEVENTH WAIVED CANDIDATE; structural inheritance from Story 1.11/1.12 applies (6-AC scale, identical to Story 1.12 scaling envelope — 4-AC→6-AC scaling noted in IP Notes and applied at iter-71). ~small per Story 1.11 iter-57 + 1.12 iter-64 precedent (structural trace inheritance ~90% savings).

## QUEUE (Story 1.13 — design-token quality gates)

- [ ] `/bmad-create-story (args: "review")` post-dev — FR14n row 7 `traced → sm-verified`; THIRD cumulative ZERO-PATCH CANDIDATE per iter-58/iter-65 doctrine (preventative-audit discipline held through dev per iter-70 outcome: all 7 Tasks + 6 ACs green first pass once retune iteration landed).
- [ ] `/bmad-code-review (args: "2")` — FR14n row 9 `sm-verified → done`; ZERO-PATCH + 10-15 DEFER forecast per iter-66 scaling (gate-authoring × 3-gate + manifest cross-cuts × 7-entry footprint; DEFER count skews higher than emitter).

## BLOCKED

_(none)_

## DONE (current story/phase only)

- [x] iter-70: **FR14n row 4 `atdd-scaffolded → in-dev` via `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md")`.** Single-pass execution (no partial re-queue) matching Story 1.12 iter-63 precedent at 6-AC scale despite larger blast radius (3 new files + 2 file amendments + 4 config file edits + 7 manifest entries touched = 3 new + 4 hash-PATCH). **Recovery pattern applied** — prior iter-70 Claude session was killed AFTER all dev-work landed on disk but BEFORE the commit + IP update + push sequence completed. This (current) session recovered by: (a) reading story file Task checkboxes — all 7 `[x]`; (b) reading v1.3 Change Log row authored by the prior session; (c) running the full quality-gate suite independently to verify the prior session's claims: `pnpm install` (lockfile up-to-date, no extra resolution) + `pnpm -w typecheck` (16/16 cache hits — no type regressions) + `pnpm -w lint` (16/16 cache hits) + `pnpm -w build` (16/16 cache hits) + `pnpm format:check` (clean) + `pnpm keel-invariants:check-all` (exit 0 — 17-entry manifest walk + emitter `--check` both pass) + `pnpm keel-invariants:tokens-schema` (exit 0) + `pnpm keel-invariants:tokens-contrast` (exit 0) + `pnpm exec prek run --all-files` (5/5 passed — typecheck, lint, format-check, tokens-schema, tokens-contrast); all green. **Work landed per v1.3 Change Log:** 3 new source files (`check-tokens-schema.ts` Ajv-2020 + `check-tokens-contrast.ts` 52-pair WCAG AA with mode-aware alias + `color-math.ts` Ottosson 2020 zero-dep OKLCH primitives); emitter amendment (`--check` mode + SHA-resolver hoist + tagged fallback + diamond-DAG-correct cycle detection); `tokens.json` retunes (accent 500 54→50%, accent 600 46→42%, status.info.fg 52→42%, status.warning.fg 58→44%) + dark-mode overlay additions; `tokens.schema.json` `leafBreakpoint` def with `^\d+px$` (absorbs Story 1.12 CR defer #9); Story 1.12 spec AA1/AA2 amendments + v1.5 Change Log row; manifest 14→17 (3 new + 3 description PATCHes + 6 contentHash PATCHes); `INVARIANTS.md` new `### Design-token quality gates (Story 1.13)` section with 3 column-0 anchors; `.pre-commit-config.yaml` 2 new local hooks; root `package.json` 4 new scripts (incl. `keel-invariants:check-all` umbrella); `@keel/keel-invariants` `package.json` 2 new bin + 2 script entries + 2 prod deps (`ajv@8.17.1`, `ajv-formats@3.0.1`); `pnpm-lock.yaml` scoped delta. All 3 Task 7 negative smokes PASS (schema-gate reject, contrast-gate reject with ratios, sync-gate reject with diffs). One spec-deviation noted: `border.default × surface.*` pairs dropped from contrast table (decorative separator not a WCAG 1.4.11 UI-component; `border.accent × surface.*` retained at 3.0 for focus). State/text/severity enumerations use actual tokens.json keys (4 states, no `text.tertiary`/`disabled`, no `surface.invert`). Story file Status: `ready-for-dev → review`. Sprint-status: `1-13-...: backlog → ready-for-dev → review`; `last_updated: 2026-04-21 Story-1-13-review UTC`. Story State: `atdd-scaffolded → in-dev`. Budget spent this recovery iteration: ~8K tokens (orient + 8 verification gate invocations + IP rewrite + RALPH.md append + commit + push; well below the iter-66 ~22K precedent since dev-work cost had already been incurred in the killed session). Next iter-71: `/bmad-testarch-trace (args: "yolo")` — SEVENTH WAIVED CANDIDATE at 6-AC scale per structural-inheritance pattern.

- [x] iter-69: **FR14n row 3 `validated → atdd-scaffolded` via hybrid ground-(c) variant-(ii)+(iii) ATDD-skip clause.** Seventh cumulative Epic 1 ATDD-skip precedent (1.7/1.8/1.9/1.10/1.11/1.12 → 1.13). Three-ground conjunction: (a) substrate-verification-covers-AC via Task 7 three negative smokes + `pnpm keel-invariants:check-all` walk + `pnpm exec prek run --all-files`; (b) no-runner at Story 1.13 time (lands Story 1.16); (c) hybrid variant-(ii)+(iii) — Story 1.16 test-runner backfill + CR adversarial fan-out. Single PATCH to spec-file adding `§ Dev Notes — Testing standards summary` sub-bullet. v1.2 Change Log row appended.

- [x] iter-68: **`/bmad-create-story (args: "review")`; FR14n state `drafted → validated` per matrix row 2.** Pre-dev SM review with TWO in-place PATCHes resolving AC 4 internal contradiction (pre-convergence sync-gate design residual — `INV-tokens-sync-gate` sourcePath corrected + "three new source files" closer harmonised to "two new + one shared-sourcePath pinning the amended emitter"). Matches Story 1.11 iter-54 (1 PATCH) + Story 1.12 iter-61 (2 PATCHes) pre-dev SM precedent. v1.1 Change Log row appended. Sprint-status unchanged (stays `ready-for-dev`).

- [x] iter-67: **`/bmad-create-story`; FR14n state `_(no story) → drafted` per matrix row 1.** Authored `_bmad-output/implementation-artifacts/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md` (~790 lines, later expanded to ~444 post-dev-addenda). 6 ACs + 7 Tasks + exhaustive Dev Notes + 28 References + v1.0 Change Log row. **Seven preventative-audit layers pre-applied at drafting time.** Sprint-status bumped `1-13-...: backlog → ready-for-dev`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.12 done; 1.13 drafted iter-67 + SM-validated iter-68 + ATDD-skipped iter-69 + dev-story landed iter-70; 1.14–1.16 backlog → 3 more stories × full FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** Story 1.13 — Token quality gates (schema validation + WCAG AA contrast + source-output sync)
- **Story File:** `_bmad-output/implementation-artifacts/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md`
- **Story State:** `in-dev` — FR14n matrix rows 1 (iter-67) + 2 (iter-68) + 3 (iter-69 SKIP) + 4 (iter-70) complete; row 5 pending at iter-71 `/bmad-testarch-trace (args: "yolo")`.
- **GitHub Issue:** Story 1.13 issue TBD (ralph.py resolves on subsequent iter start; env var unset at iter-70). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.13–1.16 all complete FR14n lifecycle).

## ATDD Skip Rationale (Story 1.13 iter-69; FR14n matrix row 3)

**Skip decision:** `/bmad-testarch-atdd` NOT invoked; Story State `validated → atdd-scaffolded` per PROMPT § Story Lifecycle Decision Matrix row 3 skip carve-out ("skip → in-dev allowed only if story has no testable ACs; record rationale in IP" — reinterpreted per RALPH.md iter-22/iter-48/iter-55/iter-62 precedent as `→ atdd-scaffolded` to preserve the state-label "ATDD step discharged; dev-story is next").

**Preflight verification (iter-62 lineage):** TEA `test_framework: auto` autodetects nothing; recursive `find` for `vitest.config.*` / `jest.config.*` / `playwright.config.*` / `cypress.config.*` under `packages/**` returns zero matches. Test-runner landing is Story 1.16 scope.

**Three-ground conjunction (hybrid variant-(ii)+(iii)):**

- **(a) substrate-verification-covers-AC** — Task 7 negative smokes exercise AC 1/2/3; `pnpm keel-invariants:check-all` + `INVARIANTS.md` anchors verify AC 4; `pnpm exec prek run --all-files` verifies AC 5; structural inspection of Story 1.12 spec amendments + schema `leafBreakpoint` verifies AC 6.
- **(b) no-runner** — no test framework wired at Story 1.13 time.
- **(c) hybrid variant-(ii)+(iii)** — Story 1.16 backfill + CR adversarial fan-out over gate-behaviour.

**Substrate verification — CONFIRMED AT iter-70 DEV-STORY EXECUTION:** all three Task 7 negative smokes PASS per v1.3 Change Log row, covering AC 1/2/3 at CLI-exit-code level; all quality gates green (typecheck/lint/build/format-check/check-all/prek 5/5). The ATDD-skip rationale held empirically — no regression surfaced that automated tests would have caught pre-dev.

## Notes

- **Story 1.13 forecast: 7-iteration floor tracking on schedule** — iter-67 drafted → iter-68 validated → iter-69 atdd-skip → iter-70 in-dev → iter-71 traced → iter-72 sm-verified → iter-73 done; matches Story 1.11 iter-53..iter-59 + Story 1.12 iter-60..iter-66 each at exactly 7 iters. **Single-pass dev achieved at iter-70 (compound-ZERO-PATCH condition (c) satisfied)** per iter-66 roadmap.
- **Carry-forward rules INTO Story 1.13 downstream gates (iter-71 trace + iter-72 sm-review + iter-73 CR) — COMPOUNDING PRIOR ART:**
  - **Seven preventative audit layers** (iter-53/54/56/59/60/67) + Layer-4 iter-68 enhancement (architecture-decision-residuals) held through dev — re-verify at SM + CR.
  - **Story 1.11/1.12 ZERO-PATCH doctrine** scales to iter-72 SM + iter-73 CR.
  - **Multi-layer-corroborated authoring-choice findings are DEFER, not PATCH** (iter-59 + iter-66 at 10-DEFER ceiling; Story 1.13 forecast 10-15 DEFER at gate-authoring scale).
  - **Single-layer BH/EH findings default DISMISS unless corroborated** (iter-36/52/59/66 at 26 dismisses).
  - **Structural trace inheritance ~90% savings** (iter-46/57/64; scales 4-AC → 6-AC). Applies at iter-71.
  - **Drift-smoke revert patterns** (iter-45/56/63) — Task 7 three negative smokes verified iter-70.
  - **Ground-(c) hybrid variant-(ii)+(iii)** unlocks ATDD-skip + trace-WAIVED for substrate+tooling + gate-authoring stories.
  - **Compound-ZERO-PATCH achievable under 5 conditions** (iter-66): (a) seven preventative audit layers — CONFIRMED iter-67; (b) pre-dev SM ≤2 PATCHes — CONFIRMED iter-68 2-PATCH; (c) single-pass dev — **CONFIRMED iter-70 recovery**; (d) clean trace — iter-71 target; (e) CR defenses pre-staged — iter-73 target.
  - **CR DEFER ceiling scales** (iter-66): populator ≈5 DEFER; emitter/gate ≈8-12 DEFER; Story 1.13 forecast 10-15 DEFER.
  - **`/bmad-code-review (args: "2")` arg `2` = "Leave as action items"**; vacuous in ZERO-PATCH case but required to force non-interactive branch.
  - **Killed-iteration-recovery verify-before-commit** (iter-70 NEW lesson) — when a prior iteration's BMad workflow lands work on disk pre-kill but post-kill recovery runs, VERIFY by re-running the full quality-gate suite before committing; do not trust in-story Change Log claims without empirical re-run. ~8K tokens per recovery vs full dev-story re-run ≈60K+ tokens.
- **Story 1.13 DEFER absorption roadmap (FROM iter-66 deferred-work.md):** 7 defers absorbed at drafting + confirmed landed iter-70 (AA1/AA2/AA3 spec amendments; resolveSourceSha hoist + failure-mode distinction + diamond-DAG guard; walkLeaves via schema-gate ordering; parseInt breakpoint via schema regex pin). 3 defers re-routed (REPO_ROOT → Epic 3; fontSize lineHeight → Epic 7/3; contrast-retune completeness via Story 1.11 iter-59 defers at Task 2 confirmed landed per `tokens.json` retunes).
- **Story 1.13 NOT absorbing (route elsewhere):** REPO_ROOT brittle → reliability/Epic 3; fontSize hardcoded 1.5 → Epic 7/3; shadow-machinery → Story 1.17-TBD or Epic 7.
- **Issue Tracking carry-forward.** Parent Epic 1 at **#9** OPEN (never `Closes`; Ralph transitions at EPIC_DONE halt). Story 1.12 at **#36** OPEN-pending-PR-merge (closes on PR merge at EPIC_DONE). Story 1.13 issue TBD. iter-70 commit trailer uses `Refs #9` (parent-epic fallback; `RALPH_ISSUE_NUMBER` env var unset at iter-70 per ralph.py IP-Context-Story parse-lag since Story 1.13 `**Story:**` field was set at iter-67 — eventually resolves after sufficient commits land referencing the story file path, but not guaranteed mid-story).
