# Implementation Plan

## NOW

- [ ] Story 1.2 Task 2 — Install shared-config devDeps (eslint v9, @eslint/js, typescript-eslint v8, globals, prettier v3, @commitlint/cli v19, @commitlint/config-conventional v19) in `packages/keel-invariants` + root; `pnpm install` green ~medium

## QUEUE (Story 1.2 mini-epic — implementation tasks)

- [ ] Story 1.2 Task 3 — Author `eslint.config.keel-invariants.js` (flat config, ESM, @eslint/js + typescript-eslint recommended, composable for Story 1.3) + `./eslint` subpath export
- [ ] Story 1.2 Task 4 — Author `prettier.config.keel-invariants.js` (keel house style) + `./prettier` subpath export + root `.prettierignore`
- [ ] Story 1.2 Task 5 — Author `commitlint.config.keel-invariants.js` (extends `@commitlint/config-conventional`) + `./commitlint` subpath export
- [ ] Story 1.2 Task 6 — Wire consumers: root `eslint.config.js` / `prettier.config.js` / `commitlint.config.js` shims + 16 × per-package `eslint.config.js` + `lint`/`format`/`format:check` scripts
- [ ] Story 1.2 Task 7 — Verify all gates: `pnpm install` / `pnpm -w typecheck` (FULL TURBO) / `pnpm -w lint` (FULL TURBO) / `pnpm format:check` / `pnpm exec commitlint --from origin/main --to HEAD`
- [ ] Transition PR #218 Draft→Open — final CI gate (after Task 7 green)

## BLOCKED

_(none)_

## DONE (Story 1.2 mini-epic)

- [x] Reconciled IP + branch after user merge of PR #217 (main now `4bf11af Merge pull request #217`); created fresh branch `feat/story-1-2-keel-invariants-shared-configs` off `origin/main`
- [x] Story 1.2 spec authored at `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`
- [x] `sprint-status.yaml`: Story 1.1 → `done`, Story 1.2 → `ready-for-dev`, last_updated 2026-04-19 21:45 UTC
- [x] Pushed initial commit (c0509a5 `docs(story): create Story 1.2 spec …`) + Draft PR #218 opened targeting `main` (pre-existing at iteration start)
- [x] **Story 1.2 Task 1** — Relocated `tsconfig.base.json` → `packages/keel-invariants/` (paths rewritten to `../<pkg>/src/index.ts` + `../../apps/web/src/index.ts`); `packages/keel-invariants/tsconfig.json` self-extends `./tsconfig.base.json`; added `"./tsconfig": "./tsconfig.base.json"` subpath export to `packages/keel-invariants/package.json`; 15 consumer `tsconfig.json` files updated to `extends: "@keel/keel-invariants/tsconfig"`; **variance:** added `@keel/keel-invariants: workspace:*` devDep to 15 consumer `package.json` files (TS6053 fix — see RALPH.md Lessons 2026-04-19). `pnpm -w typecheck` green first run (16/16, 2.515s); `>>> FULL TURBO` second run (16/16 cached, 216ms).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress; Story 1.1 shipped via PR #217)
- **Epic Branch:** `feat/story-1-2-keel-invariants-shared-configs`
- **Story:** 1.2 — `packages/keel-invariants` bootstrap + shared ESLint/Prettier/commitlint configs
- **Story File:** `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`
- **PR:** #218 Draft (statusCheckRollup=[] — no CI workflows registered yet per RALPH.md 2026-04-19 gotcha)
