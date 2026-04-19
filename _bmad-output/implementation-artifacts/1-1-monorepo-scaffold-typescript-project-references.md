# Story 1.1: Monorepo scaffold + TypeScript project references

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want a hand-authored 14-package pnpm + Turborepo monorepo with working TypeScript project references,
so that `pnpm install` runs green, package builds are cacheable, and I have a typed substrate to extend.

## Acceptance Criteria

1. **Given** a fresh clone of the Keel repo,
   **When** I run `pnpm install` from the root,
   **Then** the install completes without errors
   **And** workspace resolution finds `apps/web` and `packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui, keel-invariants, devbox, keel-generator, keel-templates}` + `create-keel-app`.

2. **Given** the scaffold,
   **When** I inspect `pnpm-workspace.yaml`, `turbo.json`, and `tsconfig.base.json`,
   **Then** each file is hand-authored (not emitted by `create-turbo`)
   **And** `tsconfig.base.json` defines the `@keel/<pkg>` path alias for every workspace package
   **And** each package has its own `tsconfig.json` extending the base with `composite: true` + `references` entries for its dependencies.

3. **Given** the project-references graph,
   **When** I run `pnpm -w typecheck` (`tsc -b`),
   **Then** the build succeeds and Turborepo caches the result
   **And** a second invocation hits the cache with no rebuilds.

4. **Given** the file-structure invariants,
   **When** a linter walks the tree,
   **Then** sources live under `src/`, exports are `src/index.ts`-only, tests are colocated, and no top-level `__tests__/` exists
   **And** naming obeys kebab-case files, PascalCase components, camelCase TS symbols, snake_case DB singular.

## Tasks / Subtasks

- [ ] **Task 1: Root monorepo scaffold** (AC: 1, 2)
  - [ ] Author `package.json` at repo root with `name: "keel"`, `private: true`, `packageManager` pinned to a specific pnpm version, `engines.node` at `>=20 <21`, and root scripts: `typecheck`, `build`, `test`, `lint` that delegate to `turbo run <task>`.
  - [ ] Author `pnpm-workspace.yaml` listing `apps/*`, `packages/*` (and nothing else — `docs/` stays outside the workspace).
  - [ ] Author `.nvmrc` with `20` (Node 20 LTS — per architecture line 781).
  - [ ] Author `.gitignore` covering `node_modules/`, `.turbo/`, `dist/`, `*.tsbuildinfo`, `coverage/`, `.env*` (except `.env.example`).
  - [ ] Author `.editorconfig` (UTF-8, LF, 2-space indent, final newline, trim trailing whitespace).
  - [ ] Do NOT add commitlint, release-please, renovate, prek, or ESLint configs in this story — those land in Stories 1.2–1.5, 1.14, 1.15.

- [ ] **Task 2: Author `tsconfig.base.json`** (AC: 2)
  - [ ] Place at repo root (not inside `packages/keel-invariants/` yet — that move lands in Story 1.2 per architecture line 1240).
  - [ ] Enable `compilerOptions`: `strict: true`, `composite: true`, `declaration: true`, `declarationMap: true`, `sourceMap: true`, `moduleResolution: "bundler"` (TanStack Start-compatible), `module: "ESNext"`, `target: "ES2022"`, `lib: ["ES2022"]`, `esModuleInterop: true`, `skipLibCheck: true`, `forceConsistentCasingInFileNames: true`, `noUncheckedIndexedAccess: true`, `isolatedModules: true`.
  - [ ] Define `paths` for every workspace package under the `@keel/<pkg>` alias, mapping to each package's `src/index.ts`. Example: `"@keel/core": ["packages/core/src/index.ts"]`. Include all 14 packages + `apps/web` (if exported).
  - [ ] Emit no files from the base itself (`noEmit: true` at base; each package overrides with per-package `outDir`).

- [ ] **Task 3: Author `turbo.json`** (AC: 3)
  - [ ] Define tasks: `build` (dependsOn: `^build`, outputs: `dist/**`, `*.tsbuildinfo`), `typecheck` (dependsOn: `^typecheck`, outputs: `*.tsbuildinfo`), `test` (dependsOn: `^build`), `lint` (no deps).
  - [ ] Content-hash caching is the default — no explicit `cache: false` anywhere.
  - [ ] Do NOT add `bench` here; it lands with the bench runner in a later story.

- [ ] **Task 4: Scaffold 14 package shells** (AC: 1, 2, 4)
  - [ ] For each of `packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui, keel-invariants, devbox, keel-generator, keel-templates}` and `packages/create-keel-app`, create:
    - [ ] `package.json` with `name: "@keel/<pkg>"` (kebab-case), `version: "0.0.0"`, `private: true`, `type: "module"`, `main: "./dist/index.js"`, `types: "./dist/index.d.ts"`, `exports: { ".": { "types": "./dist/index.d.ts", "default": "./dist/index.js" } }`, `scripts.build: "tsc -b"`, `scripts.typecheck: "tsc -b --noEmit"`.
    - [ ] `src/index.ts` with a single export line (e.g. `export {};` for placeholder). NO `__tests__/` folder, NO `lib/`, NO `tests/`.
    - [ ] `tsconfig.json` extending `../../tsconfig.base.json`, with `compilerOptions.outDir: "./dist"`, `compilerOptions.rootDir: "./src"`, `include: ["src/**/*"]`, and `references` entries pointing to any `@keel/<pkg>` dependency this package imports (for Task 4 the set is empty — no cross-package imports yet).
    - [ ] `README.md` with one-line role description sourced from architecture line 72 (e.g. `# @keel/core`).
  - [ ] **Do NOT** add `packages/devbox` with real content — leave it as an empty shell (`src/index.ts` + package metadata). The full devbox absorption is Epic 2 scope (see sprint-status `2-1` onwards).
  - [ ] **Do NOT** add ESLint configs, Prettier configs, or design-token source files — those land in Stories 1.2 and 1.10 respectively.

- [ ] **Task 5: Scaffold `apps/web`** (AC: 1, 2, 4)
  - [ ] Create `apps/web/package.json` with `name: "@keel/web"`, `private: true`, `type: "module"`, `scripts.typecheck: "tsc -b --noEmit"`.
  - [ ] Create `apps/web/src/index.ts` as a placeholder (`export {};`).
  - [ ] Create `apps/web/tsconfig.json` extending base with `composite: true`.
  - [ ] **Do NOT** run `pnpm create @tanstack/start@latest apps/web` in this story. Per the epics.md AC #2, the scaffold must be hand-authored, and the TanStack Start wiring (Vite + Router + Tailwind v4) is not a Story 1.1 deliverable. Architecture line 1395 mentions this command in the broader "First Implementation Priority" narrative, but that narrative spans Stories 1.1–1.16; Story 1.1's AC is the monorepo skeleton only. Flag this as a deferred item in the dev notes of the dev-story iteration and surface to the user so TanStack scaffolding lands in its own PR.

- [x] **Task 6: Verify `pnpm install` green** (AC: 1)
  - [x] Run `pnpm install` from repo root. Must complete with exit 0 and no warnings about missing workspace members.
  - [x] `pnpm -r list --depth -1 --json` should enumerate all 15 workspace members (14 packages + `apps/web`). Capture as evidence in the dev record.

- [ ] **Task 7: Verify `pnpm -w typecheck` green + Turborepo cache hit** (AC: 3)
  - [ ] Run `pnpm -w typecheck` — all packages type-check, exit 0.
  - [ ] Run it again immediately — Turborepo MUST report `>>> FULL TURBO` (or equivalent "100% cache hits"). If not, investigate `turbo.json` outputs + `inputs` globs.
  - [ ] Capture both runs' final-line output in the dev record.

- [ ] **Task 8: Verify file-structure invariants** (AC: 4)
  - [ ] Manually verify (no automated ESLint yet — that's Story 1.3): every package has `src/index.ts`, no `__tests__/` folders at any level, no `lib/` folders inside packages, no `tests/` folders inside packages.
  - [ ] Use `git ls-files` with grep patterns to confirm: `git ls-files | grep '__tests__' | wc -l` must be `0`. `git ls-files 'packages/*/lib/**'` must be empty.
  - [ ] Confirm naming: all `packages/*` directory names are kebab-case; all `package.json` `name` fields are `@keel/<kebab-case>`.

## Dev Notes

### Relevant architecture patterns and constraints

**Starter template decision: hand-author, NOT `create-turbo`.**
`create-turbo` is explicitly rejected — its default scaffold ships Next.js + Changesets + `apps/docs`, all of which conflict with PRD-pinned choices (TanStack Start, release-please, 14-package topology without a docs app). Hand-authoring is faster than 50%+ remove-and-replace. [Source: architecture.md#Starter-Template-Evaluation, lines 104–107]

**Hybrid scaffold approach: `@tanstack/cli` for `apps/web` is the eventual path, but OUT OF SCOPE for Story 1.1.** Story 1.1 delivers the monorepo skeleton; `apps/web` lands as an empty shell awaiting TanStack Start wiring in a subsequent story/PR. [Source: architecture.md#Selected-Starter, line 109; cross-reference epics.md Story 1.1 AC (narrower scope)]

**14-package topology** (non-negotiable, PRD-pinned):
- `apps/web` — TanStack Start app (shell only in Story 1.1; real scaffold later).
- `packages/db` — Prisma schema, RLS policies (deferred to later epic).
- `packages/contracts` — tRPC router contracts (deferred).
- `packages/config` — Zod env schemas, Vitest version pinning (content deferred to Story 1.4+).
- `packages/core` — domain logic.
- `packages/billing` — Paddle adapter (Epic 10).
- `packages/email` — Resend adapter.
- `packages/jobs` — pg-boss workers.
- `packages/flags` — feature-flag evaluation (Epic 11).
- `packages/audit` — audit-log writer.
- `packages/ui` — shadcn primitives + design-token consumers (Epic 7).
- `packages/keel-invariants` — ESLint/Prettier/commitlint configs, design tokens, invariants manifest. **Scaffolded empty in Story 1.1; populated across Stories 1.2, 1.8–1.9, 1.10–1.13.**
- `packages/devbox` — Docker devbox absorbed from `cc-devbox`. **Empty shell in Story 1.1; full absorption in Epic 2.**
- `packages/keel-generator` — `keel.config.ts` → generated-artefact pipeline (deferred epic).
- `packages/keel-templates` — page-template library (Epic 12).
- `packages/create-keel-app` — bootstrap CLI (Epic 15a).

[Source: architecture.md line 72, line 156, line 1208]

**TypeScript project references contract:**
- `tsconfig.base.json` at repo root defines `compilerOptions.paths` for every `@keel/<pkg>`.
- Every package's `tsconfig.json` extends the base and sets `composite: true`, `outDir: "./dist"`, `rootDir: "./src"`.
- Per-package `references` lists only the `@keel/<pkg>` dependencies actually imported by that package. Story 1.1 leaves these empty (no cross-package imports yet); later stories add references as dependencies emerge.
- Root-level `tsconfig.json` acts as the solution file with `references` pointing at every package — this is what `tsc -b` walks.
- `@keel/<pkg>` is the ONLY cross-package import form. Relative imports crossing `src/` boundaries are ESLint-forbidden (rule lands in Story 1.3). Imports from `@keel/<pkg>/internal/*` are forbidden (same rule). [Source: architecture.md lines 561–563, 689–690]

**Exports contract: `src/index.ts` only.** Each package's `package.json` `main`/`types`/`exports` must point at `./dist/index.js` + `./dist/index.d.ts` — no sub-path exports. No `lib/` vs `src/` split inside packages. No top-level `__tests__/`. [Source: architecture.md lines 1244, 557]

**Turborepo caching contract.** Pipeline defined at root `turbo.json`:
- `build` — per-package (respects TS project refs)
- `typecheck` — per-package
- `test` — per-package (tier-gated by CI caller — comes in Story 1.4)
- `lint` — per-package + root (Story 1.2/1.3)

Parallelism uses pnpm's graph awareness; caching is content-hash-based. [Source: architecture.md lines 1263–1271]

**Version pinning (partial in Story 1.1):**
- Node 20 LTS via `.nvmrc`. [Source: architecture.md line 781]
- pnpm version pinned via `packageManager` field in root `package.json`. Use the current stable pnpm at the time of implementation (e.g. `pnpm@9.15.x`); exact patch is implementation-time detail.
- TypeScript: pin exact minor in root `package.json` devDependencies (e.g. `typescript: "5.5.x"`).
- Turbo: pin exact minor (e.g. `turbo: "2.x.y"`).
- **Do NOT pin Vitest or OpenTelemetry in Story 1.1** — per I7 (architecture line 344), those pins live in `packages/config` + `pnpm.overrides`. Landing them without the testing/OTel infrastructure is premature.
- **Do NOT add `pnpm.overrides` in Story 1.1** — overrides are scoped by `packages/config` and land when Vitest/OTel enter in later stories.

[Source: architecture.md lines 342–350]

### Source tree components to touch

**New files (repo root):**
- `package.json`
- `pnpm-workspace.yaml`
- `turbo.json`
- `tsconfig.json` (solution file referencing all packages)
- `tsconfig.base.json`
- `.nvmrc`
- `.gitignore` (extend existing if present)
- `.editorconfig`

**New files (per package, ×15):**
- `apps/web/{package.json, tsconfig.json, src/index.ts, README.md}`
- `packages/<pkg>/{package.json, tsconfig.json, src/index.ts, README.md}` for each of the 14 packages.

**Existing files to respect (do NOT move or delete in this story):**
- `_bmad/`, `_bmad-output/`, `.claude/`, `docs/`, `RALPH.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `ralph.py`, `.ralph/`, `pyproject.toml`, `uv.lock`. These are not part of the pnpm workspace.

### Testing standards summary

**No test framework lands in Story 1.1.** Vitest selection is architecture-pinned but its setup lands in a later story (Story 1.4-ish, or wherever I7 pinning converges with test wiring). Story 1.1's "testing" is limited to:

- Running `pnpm install` and asserting exit 0 (Task 6).
- Running `pnpm -w typecheck` twice and asserting cache hit (Task 7).
- Manual `git ls-files` grep for structural anti-patterns (Task 8).

No `*.test.ts` files should be written in Story 1.1.

**Test colocation rules for FUTURE stories** (infrastructure only here): unit `<source>.test.ts`, integration `<source>.integration.test.ts`, E2E `apps/web/e2e/*.e2e.test.ts`. Colocate next to source; never create top-level `__tests__/`. [Source: architecture.md lines 509–510, 555–556, 1248–1251]

### Project Structure Notes

**Alignment with unified project structure (paths, modules, naming):**

- ✅ 14-package topology matches PRD pin + architecture line 72.
- ✅ `@keel/<pkg>` alias matches architecture line 562.
- ✅ `src/index.ts`-only exports matches architecture line 1244.
- ✅ File naming (kebab-case for files, PascalCase for React components) matches architecture lines 506–512.
- ✅ Root configuration set matches architecture line 1239, minus the configs that land in later stories (`commitlint.config.js`, `release-please-config.json`, `keel.config.ts`, `.envrc.example`, `.secrets.example`, `.prek/hooks.yaml`, `.github/renovate.json`). This story explicitly scopes to `package.json`, `tsconfig.json`, `tsconfig.base.json`, `turbo.json`, `pnpm-workspace.yaml`, `.nvmrc`, `.gitignore`, `.editorconfig`.

**Detected conflicts or variances (with rationale):**

- **Variance — `apps/web` TanStack Start scaffold deferred.** Architecture line 1395 lists `pnpm create @tanstack/start@latest apps/web` as step 2 of the "First Implementation Priority" narrative. Epics.md Story 1.1 AC is narrower — it only requires `apps/web` as a workspace member. The narrow AC wins; `apps/web` ships as an empty shell in Story 1.1. The TanStack Start scaffold needs its own story (not yet in Epic 1's 16 stories — may need a course-correction in a later iteration or lives in a later epic). **Action for dev-story:** scaffold `apps/web` as an empty shell, flag the TanStack scaffold gap in Completion Notes so the PM can allocate a story.
- **Variance — `packages/keel-invariants` scaffolded empty.** Architecture line 1422 seeds subdirs (`schemas/`, `semgrep-rules/`, `eslint-rules/`, `prompt-injection-rules/`). Those subdirs and seed files land in Stories 1.2 (ESLint/Prettier/commitlint) + 1.8 (invariants manifest) + 1.9 (sync-gate runtime) + 1.10+ (design tokens). Story 1.1 ships only `package.json`, `src/index.ts`, `tsconfig.json`, `README.md`.
- **Variance — `tsconfig.base.json` lives at repo root in Story 1.1.** Architecture line 1240 says "`tsconfig.json` (extends `keel-invariants/tsconfig.base.json`)". The move to `packages/keel-invariants/tsconfig.base.json` lands in Story 1.2 once `packages/keel-invariants/` has real content. For Story 1.1, keeping the file at repo root keeps the dep graph acyclic (no package's `tsconfig.json` extends another package's file before that package exists meaningfully).

### References

- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.1, lines 669–696] — Story AC (authoritative scope).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1, lines 634–665] — Epic 1 NFR / Implementation notes (broader context — cross-reference only; Story 1.1 scope is narrower).
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Tech-Stack, lines 71, 148, 150–152] — hardwired stack + TypeScript + Vite + Tailwind + Turborepo.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Starter-Template-Evaluation, lines 104–109] — `create-turbo` rejection rationale.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Monorepo-Structure, lines 72, 100, 156] — 14-package topology.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#TS-Project-References, lines 561–563, 689–690, 1208, 1240, 1244] — `@keel/<pkg>` alias + exports contract + `src/index.ts`-only rule.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Naming, lines 486–512, 557, 687] — naming + file-structure conventions.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Turborepo-Pipeline, lines 1263–1271] — task pipeline.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Root-Files, line 1239] — full root config inventory (Story 1.1 ships a subset).
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Version-Pinning-I7, lines 342–350] — what to pin vs. defer.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#First-Implementation-Priority, lines 1395–1442] — broader M0 narrative (spans multiple stories; Story 1.1 is narrower).
- [Source: `_bmad-output/planning-artifacts/prd.md`#FR14-FR45, lines 908, 954–977] — Functional Requirements Epic 1 covers (FR14, FR28, FR31, FR32, FR34, FR41–FR45). Story 1.1 directly advances FR34 (compile-time import boundaries — partial; ESLint side lands in Story 1.3).

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (via Ralph build loop — one task per iteration).

### Debug Log References

**Task 6 — `pnpm install` + workspace enumeration (2026-04-19):**

```
$ pnpm install
Scope: all 17 workspace projects
…
devDependencies:
+ turbo 2.3.3 (2.7.4 is available)
+ typescript 5.7.3 (5.9.3 is available)

Done in 43.8s using pnpm v10.29.2
```

Exit 0. No warnings about missing workspace members. pnpm-lock.yaml generated at repo root and committed.

```
$ pnpm -r list --depth -1 --json
# 17 projects total: 1 root (keel) + 16 workspace members:
#   @keel/web                (apps/web)
#   @keel/audit, @keel/billing, @keel/config, @keel/contracts,
#   @keel/core, @keel/create-keel-app, @keel/db, @keel/devbox,
#   @keel/email, @keel/flags, @keel/jobs, @keel/keel-generator,
#   @keel/keel-invariants, @keel/keel-templates, @keel/ui
```

Note: Task 6 subtask text mentions "15 workspace members (14 packages + apps/web)", but the actual AC-enumerated set in AC 1 is `apps/web + packages/{14 business} + create-keel-app` = **16 workspace members**. `create-keel-app` was scaffolded in Task 4 alongside the 14 business packages, so it appears in `pnpm -r list` too. All 16 are present; AC 1 satisfied.

### Completion Notes List

- **Versions pinned (root `package.json`):** `pnpm@10.29.2` (packageManager), Node `>=20 <21` (actual: v20.20.0 via `.nvmrc`), `typescript@5.7.3`, `turbo@2.3.3`. Minor upgrades available (pnpm 10.33.0, typescript 5.9.3, turbo 2.7.4) — deferred, per I7 exact-minor pinning.
- **Task 6 evidence:** `pnpm install` exit 0 in 43.8s; `pnpm -r list --depth -1 --json` enumerates 16 workspace members + root. See Debug Log References.
- **Task 7 evidence (deferred):** `pnpm -w typecheck` cache-hit evidence to be captured in Task 7 iteration.
- **TanStack Start scaffold gap:** `apps/web` shipped as an empty shell (`src/index.ts = "export {};"`). The `pnpm create @tanstack/start@latest apps/web` invocation from architecture.md §First-Implementation-Priority (line 1395) is OUT OF SCOPE for Story 1.1 per the narrower epics.md AC. Flagged to PM for course-correction (new story or later epic).

### File List

**Created (Task 1):** `package.json`, `pnpm-workspace.yaml`, `.nvmrc`, `.editorconfig`; extended `.gitignore`.
**Created (Task 2):** `tsconfig.base.json`.
**Created (Task 3):** `turbo.json`, `tsconfig.json` (solution file).
**Created (Task 4):** 15 × `packages/<pkg>/{package.json, tsconfig.json, src/index.ts, README.md}` (60 files).
**Created (Task 5):** `apps/web/{package.json, tsconfig.json, src/index.ts, README.md}`.
**Created (Task 6):** `pnpm-lock.yaml` (generated by `pnpm install`, committed).
