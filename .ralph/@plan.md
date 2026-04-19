# Implementation Plan

## NOW

- [ ] Story 1.1 Task 2: Author `tsconfig.base.json` at repo root (strict, composite, bundler moduleResolution, `@keel/<pkg>` paths for all 15 workspace members, `noEmit: true`) ~medium

## QUEUE (Keel Epic 1 — Story 1.1: remaining tasks)

1. [ ] Story 1.1 Task 3: Author `turbo.json` with `build`/`typecheck`/`test`/`lint` tasks (content-hash caching default; no `bench`) — also author root `tsconfig.json` solution file referencing all 15 package tsconfigs
2. [ ] Story 1.1 Task 4: Scaffold 14 package shells under `packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui, keel-invariants, devbox, keel-generator, keel-templates}` + `packages/create-keel-app` (package.json, tsconfig.json, src/index.ts, README.md each)
3. [ ] Story 1.1 Task 5: Scaffold `apps/web` as empty shell (package.json, tsconfig.json, src/index.ts)
4. [ ] Story 1.1 Task 6: Run `pnpm install`; capture `pnpm -r list --depth -1 --json` evidence
5. [ ] Story 1.1 Task 7: Run `pnpm -w typecheck` twice; capture cache-hit evidence
6. [ ] Story 1.1 Task 8: Verify file-structure invariants (`git ls-files | grep __tests__` = 0, no `lib/` inside packages)
7. [ ] Monitor PR #217 CI — queue fix tasks for any failures
8. [ ] Transition PR #217 Draft→Open — final CI gate (only after all 8 tasks complete)

## BLOCKED

_(none)_

## DONE (Story 1.1 mini-epic)

- [x] Reconciled IP after user merge of PR #216; branch switched to `feat/story-1-1-monorepo-scaffold` off `origin/main`
- [x] Story 1.1 spec written to `_bmad-output/implementation-artifacts/1-1-monorepo-scaffold-typescript-project-references.md`
- [x] sprint-status.yaml updated: epic-1 → in-progress; 1-1 → ready-for-dev; last_updated bumped
- [x] PR #217 opened (Draft) — `docs(story): create Story 1.1 spec`; no CI checks registered on branch
- [x] **Task 1:** Root scaffold — `package.json` (keel, private, pnpm@10.29.2, node >=20 <21, turbo/typescript pinned, scripts delegate to turbo), `pnpm-workspace.yaml` (apps/*, packages/*), `.nvmrc` (20), `.editorconfig` (UTF-8, LF, 2-space, final newline), `.gitignore` updated (`.env*` + `!.env.example` exception)

## Context

- **Phase:** 4-implementation (Story 1.1 in flight, 7 tasks remaining)
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants
- **Epic Branch:** `feat/story-1-1-monorepo-scaffold`
- **Story:** 1.1 — Monorepo scaffold + TypeScript project references
- **Story File:** `_bmad-output/implementation-artifacts/1-1-monorepo-scaffold-typescript-project-references.md`
- **PR:** #217 (Draft) — stays Draft until all 8 tasks + CI clear
