# Implementation Plan

## NOW

- [ ] Transition PR #217 Draft→Open — final CI gate (all 8 Story 1.1 tasks complete) ~small

## QUEUE (Keel Epic 1 — Story 1.1: remaining tasks)

_(empty — Tasks 1–8 all done; only the PR transition + EPIC_DONE halt remain)_

## BLOCKED

_(none)_

## DONE (Story 1.1 mini-epic)

- [x] Reconciled IP after user merge of PR #216; branch switched to `feat/story-1-1-monorepo-scaffold` off `origin/main`
- [x] Story 1.1 spec written to `_bmad-output/implementation-artifacts/1-1-monorepo-scaffold-typescript-project-references.md`
- [x] sprint-status.yaml updated: epic-1 → in-progress; 1-1 → ready-for-dev; last_updated bumped
- [x] PR #217 opened (Draft) — `docs(story): create Story 1.1 spec`; no CI checks registered on branch
- [x] **Task 1:** Root scaffold — `package.json` (keel, private, pnpm@10.29.2, node >=20 <21, turbo/typescript pinned, scripts delegate to turbo), `pnpm-workspace.yaml` (apps/*, packages/*), `.nvmrc` (20), `.editorconfig` (UTF-8, LF, 2-space, final newline), `.gitignore` updated (`.env*` + `!.env.example` exception)
- [x] **Task 2:** `tsconfig.base.json` at repo root — strict, composite, declaration + declarationMap + sourceMap, `moduleResolution: bundler`, `module: ESNext`, `target: ES2022`, `noUncheckedIndexedAccess`, `isolatedModules`, `noEmit: true`, + `paths` for 15 workspace members (14 business packages + `@keel/web`). `@keel/create-keel-app` intentionally excluded (CLI bootstrap, not imported as a library)
- [x] **Task 3:** `turbo.json` (turbo 2.x `tasks` schema — `build`/`typecheck`/`test`/`lint`, content-hash caching default, no `bench`) + root `tsconfig.json` solution file with `files: []` and 16 `references` (14 business packages + create-keel-app + apps/web)
- [x] **Task 4:** Scaffolded 15 package shells — each with `package.json` (`@keel/<pkg>`, private, type:module, main/types/exports pointing at dist/, scripts `build: "tsc -b"` + `typecheck: "tsc -b --noEmit"`), `tsconfig.json` (extends base, `composite:true`, `noEmit:false` override, `outDir:"./dist"`, `rootDir:"./src"`, `include:["src/**/*"]`, `references:[]`), `src/index.ts` (`export {};`), `README.md` (one-line role description per architecture line 72). 14 business packages (db, contracts, config, core, billing, email, jobs, flags, audit, ui, keel-invariants, devbox, keel-generator, keel-templates) + create-keel-app = 60 files. No `__tests__/`, no `lib/`, no ESLint/Prettier configs (deferred to Stories 1.2/1.3). devbox is empty shell only — full absorption in Epic 2.
- [x] **Task 5:** Scaffolded `apps/web` shell — `apps/web/{package.json (@keel/web, private, type:module, main/types/exports → dist/, build + typecheck scripts), tsconfig.json (extends base, composite:true, noEmit:false, outDir/rootDir/include), src/index.ts ("export {};"), README.md}`. Pattern identical to business packages. Root `tsconfig.json` references and `tsconfig.base.json` paths already wired in Tasks 2–3.
- [x] **Task 6:** `pnpm install` exit 0 (43.8s, no warnings about missing workspace members). `pnpm -r list --depth -1 --json` enumerates 17 projects = 1 root (`keel`) + 16 workspace members (`@keel/web` + 14 business packages + `@keel/create-keel-app`). `pnpm-lock.yaml` generated and committed.
- [x] **Task 7:** `pnpm -w typecheck` green + turbo cache. First run: 16/16 successful, 0 cached, 2.002s. Second run: 16/16 cached, 244ms, `>>> FULL TURBO`. Initial run surfaced `TS5090: Non-relative paths are not allowed when 'baseUrl' is not set` — fixed by prefixing each `paths` value in `tsconfig.base.json` with `./` (chose relative-path fix over setting `baseUrl: "."` to keep bare-import resolution independent of paths).
- [x] **Task 8:** Five structural invariants verified — `git ls-files | grep -c __tests__` = 0; `git ls-files 'packages/*/lib/**'` empty; every package+app has `src/index.ts` (16/16); all `packages/*` dirnames kebab-case; all `package.json` names `@keel/<kebab-case>`. Evidence captured in story Debug Log References → Task 8. No file changes — verification only.

## Context

- **Phase:** 4-implementation (Story 1.1 — all 8 tasks DONE; PR transition pending)
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants
- **Epic Branch:** `feat/story-1-1-monorepo-scaffold`
- **Story:** 1.1 — Monorepo scaffold + TypeScript project references
- **Story File:** `_bmad-output/implementation-artifacts/1-1-monorepo-scaffold-typescript-project-references.md`
- **PR:** #217 (Draft) — ready to transition Draft→Open next iteration. No `.github/workflows/` yet, so `statusCheckRollup: []` (WIP-app only); push directly.
