# Implementation Plan

## NOW

- [ ] Push initial commit + open Draft PR targeting `main` (first push on new branch) ~small

## QUEUE (Story 1.2 mini-epic — implementation tasks)

- [ ] Monitor PR CI — queue fix tasks for any failures (no `.github/workflows/` yet; effectively no-op per RALPH.md 2026-04-19 gotcha; WIP-only check on Draft PR skipped)
- [ ] Story 1.2 Task 1 — Relocate `tsconfig.base.json` → `packages/keel-invariants/tsconfig.base.json`; fix paths; update 15 per-package `extends` → `@keel/keel-invariants/tsconfig`; verify typecheck FULL TURBO
- [ ] Story 1.2 Task 2 — Install shared-config devDeps (eslint v9, @eslint/js, typescript-eslint v8, globals, prettier v3, @commitlint/cli v19, @commitlint/config-conventional v19) in keel-invariants + root; `pnpm install` green
- [ ] Story 1.2 Task 3 — Author `eslint.config.keel-invariants.js` (flat config, ESM, @eslint/js + typescript-eslint recommended, composable for Story 1.3) + `./eslint` subpath export
- [ ] Story 1.2 Task 4 — Author `prettier.config.keel-invariants.js` (keel house style) + `./prettier` subpath export + `.prettierignore`
- [ ] Story 1.2 Task 5 — Author `commitlint.config.keel-invariants.js` (extends `@commitlint/config-conventional`) + `./commitlint` subpath export
- [ ] Story 1.2 Task 6 — Wire consumers: root `eslint.config.js` / `prettier.config.js` / `commitlint.config.js` shims + 16 × per-package `eslint.config.js` + `lint`/`format`/`format:check` scripts
- [ ] Story 1.2 Task 7 — Verify all gates: `pnpm install` / `pnpm -w typecheck` (FULL TURBO) / `pnpm -w lint` (FULL TURBO) / `pnpm format:check` / `pnpm exec commitlint --from origin/main --to HEAD`
- [ ] Transition PR Draft→Open — final CI gate (after Task 7 green)

## BLOCKED

_(none)_

## DONE (Story 1.2 mini-epic)

- [x] Reconciled IP + branch after user merge of PR #217 (main now `4bf11af Merge pull request #217`); created fresh branch `feat/story-1-2-keel-invariants-shared-configs` off `origin/main`
- [x] Story 1.2 spec authored at `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md` (7-task decomposition, comprehensive Dev Notes, AC 1–6 per epics.md lines 698–719)
- [x] `sprint-status.yaml`: Story 1.1 corrected `ready-for-dev → done` (the `e8a158f` update never landed on main — merge used `96142bc` as second parent); Story 1.2 `backlog → ready-for-dev`; `last_updated` bumped to 2026-04-19 21:45 UTC

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress; Story 1.1 shipped via PR #217 merged 4bf11af; 14 stories remain after 1.2)
- **Epic Branch:** `feat/story-1-2-keel-invariants-shared-configs` (new, off merged `origin/main`)
- **Story:** 1.2 — `packages/keel-invariants` bootstrap + shared ESLint/Prettier/commitlint configs
- **Story File:** `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`
- **PR:** none yet (Draft PR opens after this iteration's push)
