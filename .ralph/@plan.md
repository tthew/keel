# Implementation Plan

## NOW

- [ ] Story 1.2 Task 5 — Author `commitlint.config.keel-invariants.js` (extends `@commitlint/config-conventional`) + `./commitlint` subpath export ~small

## QUEUE (Story 1.2 mini-epic — implementation tasks)

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
- [x] **Story 1.2 Task 2** — Installed shared-config devDeps in `packages/keel-invariants/package.json` and root `package.json`: `eslint@10.2.1`, `@eslint/js@10.0.1`, `typescript-eslint@8.58.2`, `globals@17.5.0`, `prettier@3.8.3`, `@commitlint/cli@20.5.0`, `@commitlint/config-conventional@20.5.0`. **Variance from spec text:** story subtasks named "v9 line" for eslint + "v19 line" for commitlint; `pnpm info` at install time reported v10/v20 as current stable. Went with current stable per story's "choose whatever `pnpm info` reports" directive — compat verified (typescript-eslint v8 accepts eslint ^8/^9/^10; @eslint/js v10 requires eslint ^10). `pnpm install` exit 0 (172 pkgs added, 3m 9.7s — registry was slow, not a config issue). `pnpm -w typecheck` remained green: 16/16 first run (1.48s), `>>> FULL TURBO` 16/16 cached second run (168ms). No config files authored yet (Tasks 3–5).
- [x] **Story 1.2 Task 3** — Authored `packages/keel-invariants/eslint.config.keel-invariants.js` (ESM, 6-entry flat-config array: ignores → @eslint/js recommended scoped to `**/*.{js,jsx,mjs,cjs}` → 3× typescript-eslint recommended scoped to `**/*.{ts,tsx}` via `.map(c => ({...c, files: ...}))` → globals.node + globals.browser layer scoped to all matched files). Added `"./eslint": "./eslint.config.keel-invariants.js"` to package `exports`. **No `no-restricted-imports`** — composability for Story 1.3 preserved (Story 1.3 appends a layer to the array). Smoke-tests: `pnpm install` (587ms, lockfile unchanged); `node -e "import('@keel/keel-invariants/eslint')"` from `packages/audit/` resolves the subpath (default = 6-entry array, 64 JS rules + 23+23 TS rules + globals); `pnpm --filter @keel/keel-invariants exec eslint --config eslint.config.keel-invariants.js src/index.ts` exit 0; `pnpm -w typecheck` 16/16 first run (1.63s) → 16/16 cached `>>> FULL TURBO` (187ms). `src/index.ts` left as `export {};` per spec.
- [x] **Story 1.2 Task 4** — Authored `packages/keel-invariants/prettier.config.keel-invariants.js` (ESM default-export, 9-key Keel house style: `printWidth:100`, `tabWidth:2`, `useTabs:false`, `semi:true`, `singleQuote:true`, `trailingComma:'all'`, `bracketSpacing:true`, `arrowParens:'always'`, `endOfLine:'lf'`). Added `"./prettier": "./prettier.config.keel-invariants.js"` to package `exports` (after `./eslint`). Created root `.prettierignore` (12 entries covering `dist/`, `node_modules/`, `.turbo/`, `*.tsbuildinfo`, `pnpm-lock.yaml`, `_bmad/`, `_bmad-output/`, `.claude/`, `docs/`, `.ralph/`, `*.py`, `uv.lock`). Smoke-tests: `pnpm install` (540ms, lockfile unchanged); `node -e "import('@keel/keel-invariants/prettier')"` from `packages/audit/` resolves to a 9-key object with expected values; `pnpm exec prettier --config packages/keel-invariants/prettier.config.keel-invariants.js --check packages/keel-invariants/prettier.config.keel-invariants.js` exit 0 ("All matched files use Prettier code style!"); `pnpm -w typecheck` 16/16 first run (1.368s) → 16/16 cached `>>> FULL TURBO` (187ms). **Carry-forward gotcha for Task 6:** `prettier --write` without an explicit `--config` uses prettier DEFAULTS (double quotes, no trailing comma), which mangled the config file on first run; fixed by reformatting with `--config packages/keel-invariants/prettier.config.keel-invariants.js --write`. This happens because auto-discovery from `cwd=repo-root` finds no `prettier.config.js` until Task 6 creates the root shim. Task 6's `prettier.config.js` re-export → `pnpm format:check` / `pnpm format` will then self-format this file under keel style.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress; Story 1.1 shipped via PR #217)
- **Epic Branch:** `feat/story-1-2-keel-invariants-shared-configs`
- **Story:** 1.2 — `packages/keel-invariants` bootstrap + shared ESLint/Prettier/commitlint configs
- **Story File:** `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`
- **PR:** #218 Draft (statusCheckRollup=[] — no CI workflows registered yet per RALPH.md 2026-04-19 gotcha)
