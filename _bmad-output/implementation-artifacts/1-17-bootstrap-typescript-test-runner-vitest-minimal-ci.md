# Story 1.17: Bootstrap TypeScript test runner (Vitest) + minimal CI workflow

Status: review

## Story

As a substrate operator who needs Ralph's pre-push CI gate (FR14i) to be non-vacuous and `Required tests:` (FR14a) to reference real files,
I want Vitest installed at the workspace root, pinned per I7, with one smoke test wiring `packages/keel-invariants/` and a `.github/workflows/ci.yml` running `pnpm turbo run test lint typecheck`,
So that every subsequent Ralph iteration can validate behaviour against running tests rather than against vacuous "no checks reported" CI passes (FR14o; closes the architecture.md:154 deferral; resolves issue #233 for the TS runtime).

## Acceptance Criteria

**AC1 — `pnpm test` discovers and runs the smoke test on a fresh devbox checkout.**

**Given** a fresh devbox checkout of `feat/epic-2-packaged-devbox` post-Story 1.17,
**When** I run `pnpm install --frozen-lockfile && pnpm test`,
**Then** Vitest discovers and runs `packages/keel-invariants/src/__tests__/smoke.test.ts`
**And** the smoke test passes
**And** the exit code is 0.

**AC2 — Vitest is pinned exactly per I7 + Story 1.9 sync-gate stays green.**

**Given** the Vitest pin in `packages/config/package.json` and `pnpm.overrides` in root `package.json`,
**When** Story 1.9's sync-gate runs (`pnpm keel-invariants:check`),
**Then** the existing `INV-deps-version-pinning` manifest row remains green (no drift introduced by the new dependency, per epics.md:1156)
**And** the I7 exact-version policy holds for Vitest + transitive deps (no `^` / `~` ranges in any Vitest-related entry).

**AC3 — `.github/workflows/ci.yml` exists and runs the canonical `pnpm turbo run test lint typecheck` invocation.**

**Given** the `.github/workflows/ci.yml` workflow,
**When** a PR is opened against `main` OR a commit is pushed to `main`,
**Then** a single `node` job runs `pnpm install --frozen-lockfile && pnpm turbo run test lint typecheck` on Node 20
**And** the workflow YAML is syntactically valid (`actionlint .github/workflows/ci.yml` exits 0 per Subtask 10.4; falls back to GH Actions ingestion-side validation post-push if `actionlint` is unavailable in the iter env).

(Diverges from epics.md:1161's "the workflow is marked as a required check on `main`" clause per SC-6: branch-protection / required-check configuration is GitHub UI-side + admin-scope. This story SHIPS the workflow file. FR14i activation + `INV-fr14i-ci-workflow-presence` invariant registration land in Story 1.20.)

**AC4 — `turbo.json` `test` task declares the cache fidelity contract.**

**Given** the `turbo.json` `test` task,
**When** `pnpm test` runs,
**Then** the task uses `dependsOn: ["^build"]` (build prerequisites resolve first; pre-existing condition holds)
**And** declares `outputs: ["coverage/**"]` so future coverage producers integrate cleanly with Turbo's remote-cache fingerprinting.

**AC5 — CLAUDE.md common-commands table documents `pnpm test` + AGENTS.md gets a `## Testing` section.**

**Given** the CLAUDE.md `## Common commands` table at lines 11–22,
**When** I open CLAUDE.md after Story 1.17 lands,
**Then** the table has a row documenting `pnpm test` (Vitest workspace-wide entry point)
**And** AGENTS.md carries a new top-level `## Testing` section inserted between the existing `## How to work here` block (ends line 41) and `## Project conventions` (starts line 43) with a one-paragraph pointer at `pnpm test` (Vitest) + a forward-pointer that `uv run pytest` lands in Story 1.18 (placement locked here at SM-validate per substrate probe — AGENTS.md has no top-level commands table, so a dedicated short section is the cleanest insertion point per SC-10).

## Tasks / Subtasks

(Authored at `/bmad-create-story` time per FR14n § Story Lifecycle. Forecast 11 tasks / ~25 subtasks per Story 2.18 narrow-substrate-extension precedent. Listed here as scaffolding for the next iteration's `/bmad-create-story (args: "review")` SM-validate gate.)

- [x] **Task 1 — Pin Vitest exactly per I7 in `packages/config/` + root `pnpm.overrides` + `packages/keel-invariants/`.** (AC: 2)
  - [x] Subtask 1.1: Resolve the exact Vitest 3.x version literal at dev-story time via `pnpm view vitest@^3 version --json | tail -1` (latest stable 3.x patch compatible with Node 20 per root `package.json:6-8` `engines.node ">=20 <21"`). Pin the resolved literal exactly (no `^` / `~` / `>=`) in `packages/config/package.json` devDependencies. Record the resolved version in Dev Agent Record § Completion Notes BEFORE commit so post-dev SM can verify the pin.
  - [x] Subtask 1.2: Add `pnpm.overrides` block to root `package.json` as a top-level field immediately after the `devDependencies` block, before the closing `}`: `"pnpm": { "overrides": { "vitest": "<resolved-3.x-version>" } }`. The override locks transitive resolution per I7's "exact versions … to prevent transitive drift" pattern (epics.md:306 I7 cross-ref + architecture.md:390 I7 normative).
  - [x] Subtask 1.3: Add `"vitest": "<resolved-3.x-version>"` to `packages/keel-invariants/package.json` devDependencies (lines 44–53 are the current devDep block; insert in alphabetical order between `@types/node` and `eslint`). The package needs vitest locally so `pnpm --filter @keel/keel-invariants test` resolves the binary directly.
  - [x] Subtask 1.4: Regenerate `pnpm-lock.yaml`: `pnpm install`. Verify the lockfile resolves Vitest + every transitive dep with no workspace-link placeholder (`grep -E "vitest:.*link:" pnpm-lock.yaml` returns zero hits — `link:` indicates an unresolved workspace pointer and would defeat the I7 pin); then run `pnpm install --frozen-lockfile` to confirm deterministic resolution. Commit `pnpm-lock.yaml` alongside the `package.json` edits.

- [x] **Task 2 — Create root `vitest.workspace.ts` discovering per-package configs.** (AC: 1)
  Verification of this file is end-to-end via Subtask 10.1 (`pnpm test`); a pre-build ESM-import smoke is invalid because the source is TS.
  - [x] Subtask 2.1: Create `vitest.workspace.ts` at the worktree root using the Vitest 3.x workspace API: `import { defineWorkspace } from 'vitest/config'; export default defineWorkspace(['packages/*/vitest.config.ts']);`. `defineWorkspace` is the canonical 3.x export for workspace mode — confirm against the resolved version's docs at install time (Vitest 4.x is expected to migrate to a `projects` field on root `defineConfig`; if the resolution surfaces a 3.x patch where `defineWorkspace` is removed, halt + flag in Completion Notes for a course-correction). The glob picks up every workspace package that ships a `vitest.config.ts` (Story 1.19 will add more; Story 1.17 only adds one).

- [x] **Task 3 — Create `packages/keel-invariants/vitest.config.ts`.** (AC: 1)
  - [x] Subtask 3.1: Use `defineConfig` from `vitest/config` with `test: { environment: 'node', include: ['src/**/*.test.ts'], exclude: ['**/dist/**', '**/node_modules/**', '**/prompt-injection-rules/*.test.ts'] }`.
  - [x] Subtask 3.2: Add inline comment on the `prompt-injection-rules/*.test.ts` exclude line: `// node:test legacy file (Story 1.6 / 2.16 substrate); migrated to vitest in Story 1.19 keel-invariants backfill — exclude until then to avoid double-discovery + node:test API conflict with vitest`.

- [x] **Task 4 — Create smoke test at `packages/keel-invariants/src/__tests__/smoke.test.ts`.** (AC: 1)
  - [x] Subtask 4.1: Create the `__tests__/` directory if absent. Smoke target locked at SM-validate via substrate probe: `readSourceFile` exported from `packages/keel-invariants/src/manifest-reader.ts:13` (a pure async function that takes an absPath and returns file content; safe to import — no I/O at module load). Author a single `describe` block with one `it` asserting the export is callable: `import { describe, it, expect } from 'vitest'; import { readSourceFile } from '../manifest-reader.js'; describe('keel-invariants smoke', () => { it('module loads + readSourceFile export is callable', () => { expect(typeof readSourceFile).toBe('function'); }); });`. Fallback only if `readSourceFile` is removed before dev-story-time: pick the next pure exported function from `manifest-reader.ts` (e.g., `computeSha256`).
  - [x] Subtask 4.2: Resolve the import path / extension per `packages/keel-invariants/tsconfig.json` `moduleResolution`. The package is `"type": "module"` (`packages/keel-invariants/package.json:5`), so the `.js` suffix on a `.ts` source import (`'../manifest-reader.js'`) is required for ESM.
  - [x] Subtask 4.3: Verify the smoke test passes locally before commit: `pnpm --filter @keel/keel-invariants test`.

- [x] **Task 5 — Replace `packages/keel-invariants/package.json` `test` script with `vitest run`.** (AC: 1, 4)
  - [x] Subtask 5.1: Edit `packages/keel-invariants/package.json:31`: replace `"test": "node --test dist/prompt-injection-rules/hook-settings-tamper.test.js"` with `"test": "vitest run"`. Pre-edit literal byte-anchor: `"test": "node --test dist/prompt-injection-rules/hook-settings-tamper.test.js",`. The `vitest run` form (not `vitest`) ensures non-watch mode for CI + turbo cache stability.
  - [x] Subtask 5.2: Confirm no other `package.json` script depends on the old node-test invocation: `rg -n 'node --test' --glob '**/package.json'` from worktree root MUST return zero hits after the edit in 5.1.

- [x] **Task 6 — Extend `turbo.json` `test` task with `outputs`.** (AC: 4)
  - [x] Subtask 6.1: Edit `turbo.json:12-14` — add `"outputs": ["coverage/**"]` to the existing `test` block. Pre-edit shape: `"test": { "dependsOn": ["^build"] }`. Post-edit shape: `"test": { "dependsOn": ["^build"], "outputs": ["coverage/**"] }`. Preserve the `dependsOn` value byte-identically.

- [x] **Task 7 — Create `.github/workflows/ci.yml` with the minimal `node` job.** (AC: 3)
  - [x] Subtask 7.1: Create directory `.github/workflows/` (currently absent per substrate verification — `.github/` exists with `release-please` config + `renovate.json` at the root level, but no `workflows/` subdirectory).
  - [x] Subtask 7.2: Author `ci.yml` with: `name: ci`; `on: { pull_request: { branches: [main] }, push: { branches: [main] } }`; one job `node` with `runs-on: ubuntu-latest`; steps in this exact order — (1) `actions/checkout@v4`, (2) `pnpm/action-setup@v4` (with `version: 10.29.2` matching root `package.json:5` packageManager) — MUST come before setup-node so `cache: pnpm` finds the binary, (3) `actions/setup-node@v4` (with `node-version: 20` + `cache: pnpm`), (4) `pnpm install --frozen-lockfile`, (5) `pnpm turbo run test lint typecheck`. Pin all GitHub Action versions per I7 using `@v4` major-pin for first-party actions (no community actions are required for this story; if any are added later, exact-SHA pin them).
  - [x] Subtask 7.3: Branch protection ("required check on main") is GH-UI / admin-scope and out of substrate. Story 1.17 SHIPS the workflow file; FR14i activation + `INV-fr14i-ci-workflow-presence` invariant registration land in Story 1.20.

- [x] **Task 8 — Update CLAUDE.md `## Common commands` table with `pnpm test` row.** (AC: 5)
  - [x] Subtask 8.1: Edit `CLAUDE.md` `## Common commands` table at lines 15–22 (current shape per substrate verification): the table has no separate footer row — line 22 (`| Stop the Ralph loop | …`) IS the last table row, with prose at line 23+. Append the new row `| Run all tests | \`pnpm test\` |` immediately after line 22, preserving the blank line before the prose paragraph at line 24. Maintain alignment via prettier-friendly spacing.
  - [x] Subtask 8.2: Add adjacent rows `| Run typecheck | \`pnpm typecheck\` |` and `| Run lint | \`pnpm lint\` |` (these scripts exist in root `package.json:10,13`; the table currently lacks them and AC5 + downstream Story 1.20 invariant audits benefit from documenting all three quality-gate commands together — locked at SM-validate, no longer "optional").

- [x] **Task 9 — Update AGENTS.md with a top-level `## Testing` section.** (AC: 5)
  - [x] Subtask 9.1: Insert a new top-level `## Testing` section between the existing `## How to work here` block (ends at line 41 — the numbered list ending with item 5 "Don't invent skills.") and `## Project conventions` (starts line 43). Substrate probe at SM-validate confirmed AGENTS.md has no top-level commands table, so a dedicated short section is the cleanest insertion point. Section content: a one-paragraph pointer at `pnpm test` (Vitest, workspace-wide; same entry point documented in CLAUDE.md § Common commands per AC5) + a forward pointer that `uv run pytest` arrives with Story 1.18 (Python runtime). Cross-reference `architecture.md § M0 substrate developer-productivity floor` (lines 198–241) for the canonical rationale.
  - [x] Subtask 9.2: Verify the new section preserves `prettier --write` idempotence by running prettier on AGENTS.md before commit.

- [x] **Task 10 — Iter-env smoke validation.** (AC: 1, 2, 3, 4, 5)
  - [x] Subtask 10.1: `pnpm install --frozen-lockfile && pnpm test` produces exit code 0 in the iteration environment + the smoke test is reported in vitest output. Capture the vitest reporter line as evidence in Dev Agent Record § Completion Notes.
  - [x] Subtask 10.2: `pnpm keel-invariants:check` (Story 1.9 sync-gate) exits 0 — no manifest drift introduced. The newly-added Vitest dep does NOT yet have a manifest entry (`INV-vitest-pin` is OUT OF SCOPE — Story 1.17 only pins via package.json + lockfile + pnpm.overrides; manifest registration of the I7-pin contract is a Story 1.21 / Epic 13 follow-up). **Note (PARTIAL):** `INV-prek-prepare-lifecycle` content-hash refresh applied in lockstep with the `package.json` `pnpm.overrides` edit (per RALPH.md iter-344 gotcha). Three pre-existing `INV-git-hooks-preservation` drifts on `feat/epic-2-packaged-devbox` head (per RALPH.md iter-358 gotcha — runtime resolves `<worktree>/.git/hooks` which is empty in the worktree case; hooks live at `core.hooksPath`) remain — out of scope for Story 1.17 per the gotcha's "Address before Story 1.20 close-out" guidance. AC2's `INV-deps-version-pinning` row is green (not in drift list).
  - [x] Subtask 10.3: `pnpm typecheck && pnpm lint` exit 0 (catches new vitest config TS errors + ESLint errors against the new smoke test file).
  - [x] Subtask 10.4: GitHub Actions workflow YAML syntax check — `actionlint` not available in iter env; falls back to GH ingestion-side validation post-push per AC3.

- [x] **Task 11 — Sprint-status flip + Change Log v1.0 (lifecycle hygiene at story creation).** (no direct AC — process; executed at `/bmad-create-story` iter-356 — DO NOT re-execute at dev-story time)
  - [x] Subtask 11.1: Sprint-status flip `1-17-bootstrap-typescript-test-runner-vitest-minimal-ci: backlog → ready-for-dev` landed at `/bmad-create-story` iter-356 (skill-handled per `workflow.md` step 6).
  - [x] Subtask 11.2: Change Log v1.0 entry landed at iter-356 (see § Change Log).
  - [ ] Subtask 11.3 (informational, no dev-story action): subsequent versions follow Story 2.18 precedent — v1.1 pre-dev SM-validate, v1.2 ATDD-skip-or-scaffold, v1.3 dev-story landing, v1.4 trace, v1.5 post-dev SM, v1.6+ CR.

## Dev Notes

### Scope clarifications (pinned at draft, MUST be honored — not re-negotiable without Change Log entry)

- **SC-1: Story 1.17 is BOOTSTRAP, not coverage.** Vitest is INSTALLED + ONE smoke test wires `packages/keel-invariants/`. Per-rule + per-enforcer + sync-gate-CLI integration tests are deferred to Story 1.19 (`keel-invariants` backfill) per SCP § 4.6 D2 sequencing. The smoke test exists ONLY to satisfy AC1 + the FR14n § ground-(a) substrate-verification clause for ATDD-skip — it is NOT a stand-in for Story 1.19's adversarial test pass.
- **SC-2: Vitest 3.x exact-pin via `packages/config` + root `pnpm.overrides` per I7.** No `^` / `~` / `>=` ranges anywhere in the Vitest entry chain. Architecture.md:1520 names `apps/web` + `packages/config` as the I7 pin sites; `apps/web` does not exist at this story scope (Epic 9 territory), so `packages/config` carries the pin alone, plus root `pnpm.overrides` for transitive lock. Root `pnpm.overrides` is added as a top-level field in `package.json` after the `devDependencies` block, before the closing brace (Subtask 1.2 carries the literal placement). The exact 3.x patch version is resolved at dev-story time via `pnpm view vitest@^3 version --json | tail -1` and recorded in Completion Notes (Subtask 1.1).
- **SC-3: Existing `node:test` legacy file is EXCLUDED, not migrated.** `packages/keel-invariants/src/prompt-injection-rules/hook-settings-tamper.test.ts` (the only existing `*.test.ts` file in the worktree, originally invoked via `package.json:31` `"test": "node --test dist/..."`) is excluded from vitest discovery via `vitest.config.ts` `exclude` glob. Migration to vitest API lands in Story 1.19. The legacy `node --test` invocation script is REMOVED in Subtask 5.1 — the file remains on disk but is no longer executed by `pnpm test`. The Story 2.16 / 2.17 hook-protection contract is unaffected (the file is documentation of the hook-tamper rule shape, not the enforcer itself).
- **SC-4: Smoke test target = `readSourceFile` exported from `packages/keel-invariants/src/manifest-reader.ts:13`.** Locked at SM-validate via substrate probe — pure async function, no I/O at module load (`check.ts` reads disk on import and is therefore avoided). Fallback only if `readSourceFile` is removed before dev-story-time: pick the next pure exported function from `manifest-reader.ts` (e.g., `computeSha256` at `:17`). Subtask 4.2 confirms the import path uses the `.js` suffix (the package is `"type": "module"` per `package.json:5`).
- **SC-5: CI workflow scope = `node` job ONLY.** The `python` job (running `uv run pytest` per FR14o) lands in Story 1.18 (Bootstrap Python test runner under uv). Story 1.17's `ci.yml` is the workflow file's first version; Story 1.18 EXTENDS it with the `python` job (additive YAML edit, no rewrite).
- **SC-6: Branch protection / required-check configuration is OUT OF SCOPE.** Story 1.17 ships the workflow file; FR14i activation (workflow file presence registered in `invariants.manifest.ts` as `INV-fr14i-ci-workflow-presence`) lands in Story 1.20 per SCP § 4.6 D3. Marking the workflow as a required check in GH branch protection is a separate UI / admin operation, not a substrate file edit.
- **SC-7: Coverage producer is FORWARD-COMPAT only.** `turbo.json` declares `outputs: ["coverage/**"]` for cache fingerprinting, but Story 1.17 does NOT install `@vitest/coverage-v8` and does NOT enable coverage reporting. Coverage enablement is a Story 1.19 sub-decision (the backfill story may turn it on; Story 1.21 audit may codify a coverage-floor invariant). The `outputs` declaration is preparatory.
- **SC-8: No new INV-* invariants registered.** Story 1.17 does NOT register `INV-vitest-pin`, `INV-package-test-coverage-floor`, or `INV-fr14i-ci-workflow-presence` in `packages/keel-invariants/src/invariants.manifest.ts`. Each of those is a separate story (1.19 / 1.20 / 1.21 per SCP § 4.6). Day-1 manifest registration here would flap the Story 1.9 sync-gate against in-flight stories per SCP § Artifact Conflicts.
- **SC-9: `pnpm.overrides` is the I7 lock site, not `packages/config`.** `packages/config/package.json` declares vitest as a devDep (so the package itself can use vitest if needed); root `pnpm.overrides` is what LOCKS the transitive resolution per I7. Both are required: declaration ≠ override.
- **SC-10: AGENTS.md / CLAUDE.md update strategy.** CLAUDE.md table edit is required (AC5). AGENTS.md placement locked at SM-validate: insert a new `## Testing` top-level section between `## How to work here` (ends line 41) and `## Project conventions` (starts line 43). Substrate probe confirms AGENTS.md has no top-level commands table, so a dedicated short section is the cleanest insertion point. Avoid duplicating prose between the two files; the AGENTS.md form is a brief pointer that says "Run `pnpm test` (Vitest, workspace-wide); `uv run pytest` arrives in Story 1.18" + cross-references `architecture.md § M0` for the canonical rationale.
- **SC-11: pnpm + Node version pin honoured.** Root `package.json:5` pins `pnpm@10.29.2`; root `package.json:6-8` pins `node ">=20 <21"`. Story 1.17 MUST NOT change either. The CI workflow (`ci.yml`) MUST use the same versions: `pnpm/action-setup@v4` with `version: 10.29.2` + `actions/setup-node@v4` with `node-version: 20`.

### Forecast — fix-chain envelope

Per RALPH.md iter-286 lifecycle PATCH forecast bands:
- **Pre-dev SM-validate** (`drafted → validated`): 0–3 PATCHes (course-correction-author origin per RALPH.md iter-348; substrate citations should verify cleanly because substrate-verification was performed at /bmad-create-story time per RALPH.md iter-347 — drift class shouldn't recur). Forecast 1–2 PATCH at SM gate (typical for narrow-substrate-extension stories).
- **ATDD** (`validated → atdd-scaffolded`): SKIP via FR14n § ground-(a) substrate-verification covers AC. Smoke test IS the bootstrap red-phase per AC1; per FR14n § ATDD-skip ground-(b) sunset (2026-04-25 amendment per issue #233), this story can no longer cite ground (b) "no test runner" (because Story 1.17 IS the test runner). Cite ground-(a) only.
- **Dev-story** (`atdd-scaffolded → in-dev`): single iter expected (substrate-extension class per RALPH.md iter-344 counter-example; 11 tasks / ~25 subtasks; mostly additive edits, no rewrites). Risk: legacy `node:test` file exclusion glob mis-pattern (Subtask 3.1) tripping up vitest's discovery.
- **Trace** (`in-dev → traced`): WAIVED expected (PARTIAL ACs; substrate-verifies-AC ground per ATDD-skip rationale). Story 1.17 IS the test infrastructure being verified; trace cycle has no external test corpus to enforce. 0 fix-task QUEUE entries forecast.
- **Post-dev SM** (`traced → sm-verified`): 1–4 PATCH at gate per RALPH.md iter-352 narrow-substrate-extension empirical (vs forecast envelope 0–3). Likely class: downstream-reference debt from Task simplifications during dev-story.
- **CR** (`sm-verified → done`): 0–2 PATCH inline-bundle-close per RALPH.md iter-342 end-of-(re-opened-)epic narrow-band recipe. Story 1.17 is mid-arc (Stories 1.18/1.19/1.20/1.21 follow); inline-bundle-close still applies if PATCH band stays narrow + no decision_needed.
- **Cumulative pre-merge PATCH band:** 2–11 across the lifecycle (vs Story 2.18's 21 cumulative — Story 1.17 is significantly narrower scope: substrate-extension, no algorithmic rewrite, no multi-site hook-surface lockstep, no manifest registration).

### Substrate verification ledger (RALPH.md iter-347 mandate)

Each Task's file/symbol/marker target was probed at create-story time. Findings:

| Target | File | Status | Drift |
| --- | --- | --- | --- |
| Vitest pin site (`packages/config/package.json`) | `packages/config/package.json` | EXISTS (22 lines; devDep block at lines 19–21, currently only `@keel/keel-invariants: workspace:*`) | none |
| Root `pnpm.overrides` block | `package.json` | ABSENT (no `pnpm` field anywhere; devDeps at lines 44–56) | none — story creates |
| Root `vitest.workspace.ts` | `vitest.workspace.ts` | ABSENT (expected; story creates) | none |
| Existing `turbo.json` `test` task | `turbo.json:12-14` | EXISTS (`{"dependsOn": ["^build"]}` shape; needs `outputs` extension) | none — story extends |
| `packages/keel-invariants/src/__tests__/` | (directory) | ABSENT (`src/` has only `eslint-rules/` + `prompt-injection-rules/` subdirs) | none — story creates |
| `packages/keel-invariants/vitest.config.ts` | (file) | ABSENT (expected; story creates) | none |
| `packages/keel-invariants/package.json` test script | `packages/keel-invariants/package.json:31` | EXISTS (`"test": "node --test dist/prompt-injection-rules/hook-settings-tamper.test.js"` — legacy node:test invocation; story replaces). devDep block at lines 44–53 (NOT 39–48 as drafted; verified at SM-validate); dependencies block at lines 39–43 sits between scripts (lines 27–38) and devDeps. | none — story replaces in Subtask 5.1; story inserts vitest in devDep block (lines 44–53) per Subtask 1.3 |
| Existing legacy test file | `packages/keel-invariants/src/prompt-injection-rules/hook-settings-tamper.test.ts` | EXISTS (the only `*.test.ts` in worktree; uses `node:test` API) | EXCLUDED via vitest config per SC-3, NOT migrated (Story 1.19) |
| `.github/workflows/` directory | (directory) | ABSENT (only `.github/.release-please-manifest.json` + `.release-please-config.json` + `renovate.json` exist at root `.github/`) | none — story creates |
| Pre-existing `release-please.yml` workflow | (none) | ABSENT (SCP § 1 names `release-please.yml` at `.github/workflows/`; actual path is root `.github/`. `renovate.json5` cited; actual is `renovate.json`.) | **SCP drift noted; no scope impact** — story creates first workflow file regardless of pre-existing state |
| `pnpm-workspace.yaml` | `pnpm-workspace.yaml` | EXISTS (`packages: [apps/*, packages/*]`) | none |
| Root `package.json:12` `"test": "turbo run test"` | `package.json:12` | EXISTS verbatim per SCP claim | none |
| `packageManager` pin | `package.json:5` | EXISTS (`"pnpm@10.29.2"`) | none |
| `engines.node` pin | `package.json:6-8` | EXISTS (`"node": ">=20 <21"`) | none |
| Story 1.9 sync-gate entry point | `packages/keel-invariants/src/check.ts` (root invocation: `package.json:16` → `pnpm --filter @keel/keel-invariants check` → `keel-invariants/package.json:32` → `node dist/check.js`) | EXISTS | none |
| I7 policy definition | `_bmad-output/planning-artifacts/architecture.md:390` ("Version pinning at M0 … Vitest exact minor … pnpm.overrides") + `epics.md:306` (cross-ref). Note: architecture.md:306 is **I1 hosting**, NOT I7 — earlier draft of Subtask 1.2 mis-cited; corrected at SM-validate. | DEFINED externally, cited from PRD § FR14o | none |
| CLAUDE.md `## Common commands` table | `CLAUDE.md:11-22` | EXISTS (6 rows; shape verified) | none — story extends |
| AGENTS.md commands table | (varies) | Substrate verification reports AGENTS.md does NOT have a top-level commands table; placement is dev-story-decided per SC-10 | dev-story discretion |

Mismatches surfaced at substrate verification: **1 minor SCP drift** (release-please file path described differently in SCP than actual layout) — does NOT affect Story 1.17 scope per the table above.

### Project Structure Notes

Aligns with `architecture.md § Complete Project Directory Structure` (lines 876+). New file additions:

- `vitest.workspace.ts` (root; new) — workspace-level vitest config aggregator.
- `packages/keel-invariants/vitest.config.ts` (new) — per-package vitest config with `node:test`-legacy exclude glob.
- `packages/keel-invariants/src/__tests__/smoke.test.ts` (new) — bootstrap smoke covering one exported surface.
- `.github/workflows/ci.yml` (new) — minimal CI workflow with `node` job.

Modified files:

- `packages/config/package.json` (+1 devDep line: vitest pin)
- `package.json` (+`pnpm.overrides` block; +potential CLAUDE.md / AGENTS.md doc-only edits via separate sub-tasks)
- `pnpm-lock.yaml` (regenerated for vitest + transitive deps)
- `packages/keel-invariants/package.json` (+1 devDep line: vitest pin; replace `test` script value byte-anchor)
- `turbo.json` (+`outputs` field on existing `test` task)
- `CLAUDE.md` (+1–3 table rows under § Common commands)
- `AGENTS.md` (+test-runner pointer, placement per SC-10)

No conflicts with `pnpm-workspace.yaml` (`packages: [apps/*, packages/*]` already covers `packages/keel-invariants` + `packages/config`).

### References

- [Source: `_bmad-output/planning-artifacts/sprint-change-proposal-issue-233.md` § Section 4.6 Story 1.17 + § Section 4.1 PRD FR14o + § Section 4.2 Architecture amendments]
- [Source: `_bmad-output/planning-artifacts/epics.md:1140-1170` Story 1.17 user-story + AC blocks]
- [Source: `_bmad-output/planning-artifacts/prd.md:969` FR14o (Test runner mandate) — normative]
- [Source: `_bmad-output/planning-artifacts/prd.md:948` FR14a manifest-real-files clause amendment]
- [Source: `_bmad-output/planning-artifacts/prd.md:959` FR14i pre-bootstrap-degradation amendment]
- [Source: `_bmad-output/planning-artifacts/prd.md:968` FR14n ATDD-skip ground-(b) sunset amendment]
- [Source: `_bmad-output/planning-artifacts/prd.md:1068` NFR1a (Test coverage floor) — context for Story 1.19 follow-up]
- [Source: `_bmad-output/planning-artifacts/architecture.md:198-241` § M0 substrate developer-productivity floor — TS runtime substrate sub-section]
- [Source: `_bmad-output/planning-artifacts/architecture.md:154` Testing Framework decision (replacement of prior deferral)]
- [Source: `_bmad-output/planning-artifacts/architecture.md:390` I7 (Version pinning at M0) — Vitest exact minor + pnpm.overrides]
- [Source: `_bmad-output/planning-artifacts/architecture.md:1520` "Pin Vitest exact version (I7) in apps/web + packages/config package.json"]
- [Source: `package.json:5` packageManager pin (`pnpm@10.29.2`)]
- [Source: `package.json:6-8` Node engines pin (`>=20 <21`)]
- [Source: `package.json:12` existing `"test": "turbo run test"` script]
- [Source: `turbo.json:12-14` existing `test` task definition]
- [Source: `packages/config/package.json` Vitest pin site (22-line file; devDep block at 19-21)]
- [Source: `packages/keel-invariants/package.json:31` legacy `node --test` script (replaced by Subtask 5.1)]
- [Source: `pnpm-workspace.yaml` workspace globs]
- [Source: `CLAUDE.md:11-22` § Common commands table]
- [Source: `RALPH.md` iter-286 lifecycle PATCH forecast bands; iter-344 substrate-extension class; iter-347 substrate-verification mandate; iter-348 course-correction-author origin yield; iter-352 narrow-substrate-extension SM yield]

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (1M context) — Ralph build-mode iter-359; `/bmad-dev-story` invocation per FR14n § Story Lifecycle row `atdd-scaffolded → in-dev`.

### Debug Log References

- `pnpm view vitest@^3 version --json | tail -1` → resolved Vitest 3.x latest stable = **3.2.4**.
- `pnpm install` → 45 packages added; `prepare` hook installed prek shims at `/workspace/ralph-bmad/.git/hooks/{pre-commit,commit-msg}` (worktrees share the common git dir).
- `grep -E "vitest:.*link:" pnpm-lock.yaml` → 0 hits (Subtask 1.4 deterministic-resolution check).
- `pnpm install --frozen-lockfile` → 0 exit (lockfile pin verified).
- `pnpm test` (Subtask 10.1 evidence): vitest reporter line — `RUN  v3.2.4 /workspace/ralph-bmad/.claude/worktrees/test-env/packages/keel-invariants` → `✓ src/__tests__/smoke.test.ts (1 test) 1ms` → `Test Files  1 passed (1)` / `Tests  1 passed (1)`.
- `pnpm keel-invariants:check` → see Completion Notes § Sync-gate posture.
- `pnpm typecheck` → 16 packages green.
- `pnpm lint` → 16 packages green.
- `pnpm format:check` → "All matched files use Prettier code style!" (Subtask 9.2 idempotence + repo-wide check).
- `rg -n 'node --test' --glob '**/package.json'` → 0 hits post Subtask 5.1 edit.

### Completion Notes List

- **Vitest version pinned**: `3.2.4` (latest stable 3.x at iter-359 dev-story-time). Pinned in `packages/config/package.json:21`, `packages/keel-invariants/package.json:53`, and root `package.json` `pnpm.overrides.vitest` (top-level `pnpm` field, post-devDependencies).
- **Workspace API**: `defineWorkspace` from `vitest/config` is the canonical 3.x export (verified against vitest 3.2.4 — Vitest 4.x migrates to `projects` field on root `defineConfig` per Subtask 2.1 pre-flight note; not relevant at 3.2.4).
- **Smoke target**: `readSourceFile` from `manifest-reader.ts:13` (verified extant; pure async, no I/O at module load — safe import). `expect(typeof readSourceFile).toBe('function')` pattern.
- **Legacy node:test exclusion**: `**/prompt-injection-rules/*.test.ts` excluded from vitest discovery via `packages/keel-invariants/vitest.config.ts`. The legacy file remains on disk; migration to vitest API is Story 1.19 territory per SC-3.
- **Sync-gate posture (AC2 + Subtask 10.2)**: `INV-deps-version-pinning` row remains green (not in drift list). `INV-prek-prepare-lifecycle` content-hash refreshed in lockstep with the `package.json` `pnpm.overrides` edit (whole-file hashScope; old `e410d9ca…` → new `74237244…`) — this is the substrate-sourcePath co-edit pattern from RALPH.md iter-344 gotcha. **Three pre-existing `INV-git-hooks-preservation` drifts** persist on `feat/epic-2-packaged-devbox` head (RALPH.md iter-358 gotcha): two `git-hook-missing` (commit-msg, pre-commit) + one `content-hash-mismatch` (expected `cb27263d…` actual `42a42b16…`). Root cause: sync-gate's `resolve(repoRoot, '.git/hooks')` resolves to `<worktree>/.git/hooks` which doesn't exist in worktree mode — actual hooks live at `core.hooksPath = /workspace/ralph-bmad/.git/hooks` (the common git dir). Pre-existing per RALPH.md iter-358 ("NOT introduced by Story 1.17 reopen-arc commits") + explicitly out of scope per the gotcha's "Address before Story 1.20 close-out" guidance. AC2 satisfied (the AC's specific check is `INV-deps-version-pinning` — green).
- **CI workflow scope**: Story 1.17 ships `.github/workflows/ci.yml` with the `node` job. The `python` job lands additively in Story 1.18 per SC-5. Branch protection / required-check is GH-UI / admin-scope per SC-6 (out of substrate). FR14i activation + `INV-fr14i-ci-workflow-presence` registration land in Story 1.20.
- **CLAUDE.md**: 3 rows added to `## Common commands` table (`pnpm test`, `pnpm typecheck`, `pnpm lint`). Prettier idempotent.
- **AGENTS.md**: New top-level `## Testing` section inserted between `## How to work here` (line 41) and `## Project conventions` (now starting at line 47 post-edit). One-paragraph pointer at `pnpm test` + forward pointer to `uv run pytest` (Story 1.18) + cross-reference `architecture.md § M0 substrate developer-productivity floor`. Prettier idempotent.
- **`actionlint` unavailable**: iter-env doesn't ship `actionlint`; falls back to GH ingestion-side validation per AC3 spec + Subtask 10.4.
- **No INV-* invariant registration**: `INV-vitest-pin`, `INV-package-test-coverage-floor`, `INV-fr14i-ci-workflow-presence` all OUT OF SCOPE per SC-8 — registered in Stories 1.19/1.20/1.21 respectively.

### File List

**Modified**:
- `package.json` — added top-level `pnpm.overrides.vitest: "3.2.4"` block.
- `packages/config/package.json` — added `vitest: "3.2.4"` to devDependencies.
- `packages/keel-invariants/package.json` — added `vitest: "3.2.4"` to devDependencies; replaced `test` script (`node --test dist/...` → `vitest run`).
- `packages/keel-invariants/src/invariants.manifest.ts` — refreshed `INV-prek-prepare-lifecycle` `contentHash` (`e410d9ca…` → `74237244…`) in lockstep with `package.json` substrate-sourcePath edit.
- `pnpm-lock.yaml` — regenerated (45 packages added for vitest + transitive deps).
- `turbo.json` — added `outputs: ["coverage/**"]` to `test` task block.
- `CLAUDE.md` — appended 3 rows (`pnpm test`, `pnpm typecheck`, `pnpm lint`) to `## Common commands` table.
- `AGENTS.md` — inserted new top-level `## Testing` section between `## How to work here` and `## Project conventions`.
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — story row `1-17-…: ready-for-dev → review`; `last_updated` bumped + history entry appended.
- `_bmad-output/implementation-artifacts/1-17-bootstrap-typescript-test-runner-vitest-minimal-ci.md` — Tasks 1–10 + their subtasks marked `[x]`; Status `ready-for-dev → review`; Dev Agent Record + File List + Change Log v1.3 filled.

**Created**:
- `vitest.workspace.ts` (worktree root) — 3-line workspace aggregator.
- `packages/keel-invariants/vitest.config.ts` — per-package config with `node:test`-legacy exclude glob + inline rationale comment.
- `packages/keel-invariants/src/__tests__/smoke.test.ts` — single-test smoke covering `readSourceFile` callability.
- `.github/workflows/ci.yml` — first CI workflow (single `node` job; `pnpm install --frozen-lockfile` + `pnpm turbo run test lint typecheck`; pnpm 10.29.2 + Node 20 pinned per SC-11).

## Change Log

- **v1.0** (2026-04-25, iter-1) — Story created via `/bmad-create-story` autonomous discovery from sprint-status.yaml first-backlog row (`1-17-bootstrap-typescript-test-runner-vitest-minimal-ci`); FR14n state transition `_(no story) → drafted`; sprint-status row `backlog → ready-for-dev`. Substrate verification per RALPH.md iter-347 against Story 1.17 SCP-provisional Tasks: 1 SCP-side drift surfaced (`.github/workflows/release-please.yml` cited but actually doesn't exist; release-please configs are at root `.github/` level, not in `workflows/` subdir) — drift recorded in § Substrate verification ledger; does NOT affect Story 1.17 scope. 11 Tasks / ~25 subtasks scaffolded. SC-1 through SC-11 pinned. Forecast envelope: 2–11 cumulative pre-merge PATCH (vs Story 2.18's 21 — narrower scope). ATDD-skip forecast: ground-(a) substrate-verification (smoke test IS the bootstrap red-phase per AC1; FR14n § ground-(b) sunset post-this-story per issue #233 amendment).
- **v1.1** (2026-04-25, iter-357) — Pre-dev SM-validate via `/bmad-create-story (args: "review")`; FR14n state transition `drafted → validated`. Two-subagent review per RALPH.md iter-235 narrow-surface pattern (technical-correctness + prose-density); 7 MUST-FIX + 9 SHOULD-FIX applied at gate; NITs + LLM-OPTs deferred. **MUST-FIX patches:** (1) AC2 — name `INV-deps-version-pinning` per epics.md:1156; (2) AC3 — actionlint Then-clause + epics.md:1161 divergence note per SC-6; (3) AC5 + Subtask 9.1 + SC-10 — AGENTS.md placement locked to new `## Testing` section between line 41 and line 43 (substrate probe at SM-validate); (4) Subtask 1.1 + SC-2 — Vitest version resolution rule pinned (`pnpm view vitest@^3 version --json | tail -1`) + Completion-Notes capture; (5) Subtask 1.2 — citation fix `architecture.md:306 → epics.md:306` (architecture.md:306 is I1, not I7); (6) Subtask 1.3 + ledger — devDep block line range `39–48 → 44–53`; (7) Subtask 2.1 + delete dead-weight Subtask 2.2; Subtask 4.1 + SC-4 — smoke target locked to `readSourceFile` from `manifest-reader.ts:13`. **SHOULD-FIX patches:** Subtask 5.2 exact `rg` command, Subtask 7.2 step ordering, Subtask 8.1 footer anchor, Subtask 8.2 lock-decision (no longer "optional"), Subtask 1.4 `link:` placeholder check explicit, Task 11 marked `[x]` (process work executed at `/bmad-create-story`), substrate-ledger row 10 collapsed, ledger row I7-policy-definition annotated. Course-correction-author origin yield (7 MUST-FIX) consistent with RALPH.md iter-348 Story 2.18 SM-validate (9 PATCHes at gate from same author class); above forecast envelope (1–4) but explainable via course-correction author class. Cumulative pre-merge PATCH count Story 1.17 lifecycle to date: 16 (vs Story 2.18 lifecycle 21).
- **v1.3** (2026-04-25, iter-359) — Dev-story landing via `/bmad-dev-story`; FR14n state transition `atdd-scaffolded → in-dev → review` (single iter per substrate-extension class per RALPH.md iter-344 counter-example). All Tasks 1–10 + 25 subtasks marked `[x]` (Task 11 was already done at iter-356 create-story time). **Vitest 3.2.4 pinned** at three sites + root `pnpm.overrides`; lockfile regenerated; `--frozen-lockfile` clean; `link:` placeholder check 0 hits. **Smoke test** at `packages/keel-invariants/src/__tests__/smoke.test.ts` discovered + passes (`✓ src/__tests__/smoke.test.ts (1 test) 1ms`; vitest reporter `RUN v3.2.4`). **Iter-env smoke matrix** (Subtasks 10.1/10.2/10.3/10.4): `pnpm test` GREEN; `pnpm typecheck` GREEN; `pnpm lint` GREEN; `pnpm format:check` GREEN; `actionlint` unavailable → GH ingestion-side validation per AC3. **Sync-gate** (Subtask 10.2): `INV-deps-version-pinning` GREEN (AC2 satisfied); `INV-prek-prepare-lifecycle` contentHash refreshed in lockstep with `package.json` substrate-sourcePath edit (RALPH.md iter-344 gotcha pattern); 3 pre-existing `INV-git-hooks-preservation` drifts persist (RALPH.md iter-358 gotcha — out of scope; address before Story 1.20 close-out). **Doc edits**: 3 CLAUDE.md `## Common commands` rows; new AGENTS.md `## Testing` section. CI workflow `.github/workflows/ci.yml` shipped (first workflow file; `node` job only; `python` job is Story 1.18 additive). Sprint-status `1-17-…: ready-for-dev → review`; `last_updated` bumped to iter-359. Cumulative pre-merge PATCH count Story 1.17 lifecycle to date: 16 (no new PATCHes at dev-story landing — single-iter clean landing per substrate-extension forecast). Change Log v1.3 filed.
- **v1.2** (2026-04-25, iter-358) — ATDD-skipped via FR14n § ground-(a) substrate-verification (no `/bmad-testarch-atdd` invocation). FR14n state transition `validated → atdd-scaffolded`. **Skip rationale:** every AC is substrate-verifiable upon Task landing — AC1 (smoke-test discovery) + AC2 (I7 pin presence + sync-gate green) + AC3 (`.github/workflows/ci.yml` exists + actionlint) + AC4 (`turbo.json` `outputs` field) + AC5 (CLAUDE.md row + AGENTS.md `## Testing` section). Per AC1's literal wording, the smoke test produced by Tasks 4 / 9 IS the bootstrap red-phase test that ATDD would otherwise scaffold; invoking `/bmad-testarch-atdd` would either duplicate Task 4.1's deliverable or scaffold an abstract test that doesn't match the bootstrap context. **Ground citation:** (a) only per IP § NOW directive — ground (b) "no test runner at substrate" SUNSETS post-this-story per PRD FR14n § ATDD-skip ground-(b) sunset clause (issue #233 amendment), and citing (b) for the story that DESTROYS (b) would be incoherent; ground (c)-(iii) "spec-declared-CR-substitution" is a natural cross-reference (AC1 spec literally declares the smoke-test red-phase substitution) but per iter-297 multi-ground discipline the bare-(a) form is sufficient because Story 1.17's substrate-verification is unusually strong (every AC ↔ substrate file 1:1). Sprint-status unchanged (ATDD-skip is Ralph-internal per FR14n). 0 fix-task QUEUE entries → direct promotion to `atdd-scaffolded`. **Cumulative ATDD-skip counter:** 29th cumulative Epic ATDD-skip / 1st Epic-1-reopen-arc / 2nd course-correction-origin (Story 2.18 iter-349 was the first; Story 1.17 is the first to deprecate ground (b) under the sunset clause). Cumulative pre-merge PATCH count Story 1.17 lifecycle to date: 16 (unchanged — ATDD-skip applies no patches). Next NOW = `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-17-bootstrap-typescript-test-runner-vitest-minimal-ci.md")` (`atdd-scaffolded → in-dev`).
- **v1.4** (2026-04-25, iter-360) — Trace landed via `/bmad-testarch-trace (args: "yolo")`. FR14n state transition `in-dev → traced`. **Gate WAIVED** with hybrid grounds (a) substrate-verification + (c) variant-(ii)+(iii) per IP § NOW forecast: every AC ↔ substrate file 1:1; AC1 FULL via `smoke.test.ts:5` (iter-env vitest 3.2.4 reporter `✓ src/__tests__/smoke.test.ts (1 test) 1ms`); AC2 PARTIAL (sync-gate `INV-deps-version-pinning` GREEN; `INV-vitest-pin` manifest registration deferred to Story 1.21 per SC-8); AC3 PARTIAL (substrate-verifies; `actionlint` unavailable in iter env, GH ingestion-side validation deferred to PR base-flip-to-main per SC-6); AC4 PARTIAL (forward-compat coverage placeholder per SC-7); AC5 PARTIAL (substrate prettier-idempotent; no automated prose-quality assertion). Coverage stats: 1/5 FULL (20%); P0 50% (1/2 FULL — AC1 only); P1 0%; P2 0%. **Deterministic FAIL → WAIVED** per structural-artefact rationale: Story 1.17 IS the test runner being authored, no pre-existing corpus to enforce coverage. **Cumulative trace-WAIVED counter:** 29th cumulative + 1st Epic-1-reopen-arc + 2nd course-correction-origin (Story 2.18 iter-351 was the first course-correction-origin trace-WAIVED). 0 fix-task QUEUE entries → direct promotion to `traced`. **Residual risks:** `INV-vitest-pin` registration (Story 1.21), `actionlint` behavioural half (deferred to GH ingestion at PR base-flip), pre-existing 3× `INV-git-hooks-preservation` drifts (RALPH.md iter-358 gotcha; address before Story 1.20). Trace artefacts emitted: `_bmad-output/test-artifacts/traceability/1-17-bootstrap-typescript-test-runner-vitest-minimal-ci.md` + `1-17-e2e-trace-summary.json` + `1-17-gate-decision.json`. Sprint-status unchanged (trace is Ralph-internal per FR14n). Cumulative pre-merge PATCH count Story 1.17 lifecycle to date: 16 (unchanged — WAIVED applies no patches). Next NOW = `/bmad-create-story (args: "review")` (`traced → sm-verified`); forecast 1–4 PATCH per RALPH.md iter-352 narrow-substrate-extension envelope.
