# Implementation Plan

## NOW

- [ ] Transition PR #218 Draft→Open — final CI gate (PR has no CI workflows registered yet per RALPH.md 2026-04-19 gotcha — WIP-only Draft → flip triggers WIP-green; EPIC_DONE halt on Open+clean+no-reviews) ~small

## QUEUE (Story 1.2 mini-epic — implementation tasks)

_(empty — next iteration halts EPIC_DONE after Draft→Open transition)_

## BLOCKED

_(none)_

## DONE (Story 1.2 mini-epic)

- [x] Reconciled IP + branch after user merge of PR #217 (main now `4bf11af Merge pull request #217`); created fresh branch `feat/story-1-2-keel-invariants-shared-configs` off `origin/main`
- [x] Story 1.2 spec authored at `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`
- [x] `sprint-status.yaml`: Story 1.1 → `done`, Story 1.2 → `ready-for-dev`, last_updated 2026-04-19 21:45 UTC
- [x] Pushed initial commit (c0509a5 `docs(story): create Story 1.2 spec …`) + Draft PR #218 opened targeting `main` (pre-existing at iteration start)
- [x] **Story 1.2 Task 1** — Relocated `tsconfig.base.json` → `packages/keel-invariants/`; 15 consumer tsconfigs `extends: "@keel/keel-invariants/tsconfig"`; 15 × `@keel/keel-invariants: workspace:*` devDep additions (TS6053 fix). `pnpm -w typecheck` 16/16 `>>> FULL TURBO` 216ms.
- [x] **Story 1.2 Task 2** — Installed shared-config devDeps at keel-invariants + root: `eslint@10.2.1`, `@eslint/js@10.0.1`, `typescript-eslint@8.58.2`, `globals@17.5.0`, `prettier@3.8.3`, `@commitlint/cli@20.5.0`, `@commitlint/config-conventional@20.5.0`. Current-stable versions (v10/v20) — story's `pnpm info` override directive. 172 packages added.
- [x] **Story 1.2 Task 3** — `packages/keel-invariants/eslint.config.keel-invariants.js` (6-entry flat-config array: ignores + js-recommended scoped to JS + 3× tseslint-recommended scoped to TS + globals layer) + `./eslint` subpath export. Composability for Story 1.3 preserved.
- [x] **Story 1.2 Task 4** — `packages/keel-invariants/prettier.config.keel-invariants.js` (9-key keel house style) + `./prettier` subpath export + root `.prettierignore` (12 entries).
- [x] **Story 1.2 Task 5** — `packages/keel-invariants/commitlint.config.keel-invariants.js` (extends config-conventional + 3-rule overrides: `subject-case: [0]`, `header-max-length: [2, always, 120]`, `body-max-line-length: [0]` aligned to Ralph's commit style) + `./commitlint` subpath export.
- [x] **Story 1.2 Task 6** — Wired consumers: 3 root shims (`eslint.config.js` / `prettier.config.js` / `commitlint.config.js`) + 16 × per-member `eslint.config.js` + `"lint": "eslint ."` script across 16 members + root `format` / `format:check` scripts. Two preempted landmines: root `"type": "module"` (missing from Story 1.1) + root `@keel/keel-invariants: workspace:*` devDep (required for root-shim bare-specifier resolution). All gates green; `pnpm format:check` legitimately failed on 3 pre-existing markdown files (deferred to Task 7).
- [x] **Story 1.2 Task 7** — Verification + one-shot format-fix. All gates green: `pnpm install` 770ms (lockfile unchanged); `pnpm -w typecheck` 16/16 `>>> FULL TURBO` 165ms (cache already warm from Task 6); `pnpm -w lint` 16/16 `>>> FULL TURBO` 143ms; `pnpm format` on `AGENTS.md` / `CLAUDE.md` / `README.md` — 36/36 diff (pure table-cell column-width reflow, zero content edits); `pnpm format:check` now `All matched files use Prettier code style!` exit 0; `pnpm exec commitlint --from origin/main --to HEAD` → 0 problems 0 warnings across 6 commits; `git ls-files` confirms only `packages/keel-invariants/tsconfig.base.json`, no `.generated.` files. Story spec `Status: ready-for-dev` → `done`; Task 7 [x] with full evidence in Debug Log / Completion Notes / File List.
- [x] Sprint-status bookkeeping — `sprint-status.yaml`: Story 1.2 `ready-for-dev` → `done`; `last_updated` 21:45 → 22:00 UTC (monotonic bump; wall-clock shows 20:03 UTC but prior iteration used 21:45, so preserved forward motion). Landing BEFORE PR transition per RALPH.md Lessons 2026-04-19 "Post-halt bookkeeping commits can orphan from main" — this commit is now part of PR #218 diff before the Draft→Open flip.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress; Story 1.1 shipped via PR #217)
- **Epic Branch:** `feat/story-1-2-keel-invariants-shared-configs`
- **Story:** 1.2 — `packages/keel-invariants` bootstrap + shared ESLint/Prettier/commitlint configs — **IMPLEMENTATION COMPLETE; bookkeeping + PR transition remain**
- **Story File:** `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`
- **PR:** #218 Draft (statusCheckRollup=[] — no CI workflows registered yet per RALPH.md 2026-04-19 gotcha)
