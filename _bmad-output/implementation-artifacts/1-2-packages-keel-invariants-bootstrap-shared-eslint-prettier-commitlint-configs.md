# Story 1.2: `packages/keel-invariants` bootstrap + shared ESLint/Prettier/commitlint configs

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want a versioned `packages/keel-invariants/` package exporting shared ESLint (flat config), Prettier, commitlint, and tsconfig-base configurations,
so that every downstream package consumes one canonical ruleset and drift cannot hide (FR41).

## Acceptance Criteria

1. **Given** the Story 1.1 scaffold,
   **When** `packages/keel-invariants/` is populated with `src/index.ts` (minimal re-exports), config files (`eslint.config.keel-invariants.js`, `prettier.config.keel-invariants.js`, `commitlint.config.keel-invariants.js`), and `tsconfig.base.json` physically relocated from the repo root,
   **Then** the package publishes these configs under stable named subpath exports (`@keel/keel-invariants/eslint`, `@keel/keel-invariants/prettier`, `@keel/keel-invariants/commitlint`, `@keel/keel-invariants/tsconfig`)
   **And** the `exports` field in `package.json` resolves each config via its subpath.

2. **Given** the shared configs,
   **When** another workspace package's `eslint.config.js` imports and extends `@keel/keel-invariants/eslint` (re-export / spread),
   **Then** `pnpm lint` in that package runs using the shared rules
   **And** removing the re-export changes lint behaviour detectably (proves the canonical config is actually in use; closes the "appears-but-isn't" gap that Story 1.6 bypass-prevention further hardens).

3. **Given** the package is present and all 16 workspace members (15 packages + `apps/web`) carry their own `eslint.config.js` that re-exports `@keel/keel-invariants/eslint` plus a `"lint": "eslint ."` script,
   **When** a developer runs `pnpm lint` at the root,
   **Then** every package lints against the canonical ruleset with exit 0
   **And** the lint config resolves in both ESM (via `type: "module"`) and TypeScript contexts (including `*.ts` + `*.tsx` linting via `typescript-eslint`).

4. **Given** `tsconfig.base.json` has been moved from repo root to `packages/keel-invariants/tsconfig.base.json`,
   **When** every per-package `tsconfig.json` updates its `extends` to `"@keel/keel-invariants/tsconfig"` (subpath export) and `packages/keel-invariants/tsconfig.json` extends `"./tsconfig.base.json"` (local),
   **Then** `pnpm -w typecheck` remains green across all 16 packages
   **And** a second run shows `>>> FULL TURBO` (cache still hits; no output shape change).

5. **Given** the shared Prettier config and a root `prettier.config.js` that re-exports `@keel/keel-invariants/prettier`,
   **When** a developer runs `pnpm format:check` at the root,
   **Then** all committed files pass Prettier verification with exit 0
   **And** running `pnpm format` (write-mode) is a no-op on a clean tree (idempotent).

6. **Given** the shared commitlint config and a root `commitlint.config.js` that re-exports `@keel/keel-invariants/commitlint`,
   **When** `pnpm exec commitlint --from HEAD~1 --to HEAD --verbose` runs against the current branch's latest commit,
   **Then** commitlint validates successfully (every Story 1.2 commit conforms to conventional-commit format, which is already a Ralph invariant — the config just machine-enforces it).
   **Note:** The `commit-msg` prek hook that invokes commitlint on every `git commit` is Story 1.5 scope — Story 1.2 establishes the shared config only.

## Tasks / Subtasks

- [x] **Task 1: Relocate `tsconfig.base.json` into `packages/keel-invariants/` + expose via subpath export** (AC: 1, 4)
  - [x] `git mv tsconfig.base.json packages/keel-invariants/tsconfig.base.json`.
  - [x] Update `packages/keel-invariants/tsconfig.base.json` `paths` values: each was `"./packages/<pkg>/src/index.ts"` relative to repo root; after the move, the file lives two directories deeper, so each path must become `"../<pkg>/src/index.ts"` relative to the new file location. `@keel/web` → `"../../apps/web/src/index.ts"`.
  - [x] Update `packages/keel-invariants/tsconfig.json` `extends` from `"../../tsconfig.base.json"` to `"./tsconfig.base.json"` (self-extend; co-located).
  - [x] Update the remaining 15 per-package `tsconfig.json` `extends` fields to `"@keel/keel-invariants/tsconfig"`. Files: `apps/web/tsconfig.json` + `packages/{audit,billing,config,contracts,core,create-keel-app,db,devbox,email,flags,jobs,keel-generator,keel-templates,ui}/tsconfig.json`.
  - [x] Root `tsconfig.json` solution file references unchanged — all 16 references valid.
  - [x] Added `"./tsconfig": "./tsconfig.base.json"` to `packages/keel-invariants/package.json` `exports`.
  - [x] **Variance — not in original subtasks:** added `"@keel/keel-invariants": "workspace:*"` to `devDependencies` of all 15 consuming packages (apps/web + 14 packages). Required because TS's `extends` with a bare specifier goes through Node module resolution, which only creates `node_modules/@keel/keel-invariants` symlinks for packages that declare it as a dependency. Without this, typecheck fails with `TS6053: File '@keel/keel-invariants/tsconfig' not found.`. Story Dev Notes line 157 assumed the symlink would exist; pnpm's default behavior doesn't hoist un-depended workspace packages.
  - [x] `pnpm install` → Done in 501ms, 17 workspace projects. `node_modules/@keel/keel-invariants` symlinks created under each consumer.
  - [x] `pnpm -w typecheck` → first run: `Tasks: 16 successful, 16 total / Cached: 0 cached, 16 total / Time: 2.515s`.
  - [x] `pnpm -w typecheck` → second run: `Tasks: 16 successful, 16 total / Cached: 16 cached, 16 total / Time: 216ms >>> FULL TURBO`.
  - [x] **Did NOT** add any eslint/prettier/commitlint deps — those land in Task 2.

- [x] **Task 2: Install shared-config devDependencies in `packages/keel-invariants/`** (AC: 1, 2, 3, 5, 6)
  - [x] Added the following to `packages/keel-invariants/package.json` `devDependencies` (pinned exact-patch per Story 1.1's established convention — `typescript@5.7.3` / `turbo@2.3.3` style, i.e. plain pinned version with no `^`/`~`; satisfies architecture I7 "no major-wildcarding"):
    - `eslint@10.2.1` — current stable line (flat config native; legacy eslintrc removed in v10).
    - `@eslint/js@10.0.1` — matches eslint major; peerDep `eslint: ^10.0.0`.
    - `typescript-eslint@8.58.2` — v8 line, peerDep `eslint: ^8.57.0 || ^9.0.0 || ^10.0.0` confirms forward-compat with eslint v10.
    - `globals@17.5.0` — current stable.
    - `prettier@3.8.3` — current stable v3 line.
    - `@commitlint/cli@20.5.0` — current stable line.
    - `@commitlint/config-conventional@20.5.0` — matches `@commitlint/cli`.
  - [x] **Variance from original subtask text.** Subtasks prescribed "v9 line" for `eslint` / `@eslint/js` and "v19 line" for commitlint — those were the current stables when the spec was authored. At install time, `pnpm info` reported `eslint@10.2.1`, `@eslint/js@10.0.1`, `@commitlint/cli@20.5.0`, `@commitlint/config-conventional@20.5.0` as current stable. Story's "choose whatever `pnpm info <pkg> version` reports at run time" directive overrides the specific-major text — went with current stable. Ecosystem compat verified via peer-deps (see above). This is a knock-on for Story 1.3 scope reading: any "v9 ESLint" references in downstream story docs refer to flat-config-native ESLint (v9+); Story 1.3's `no-restricted-imports` composability is unaffected by the v9→v10 ecosystem bump (flat-config shape is identical).
  - [x] Added the same 7 devDeps to root `{repo-root}/package.json` `devDependencies` alongside existing `turbo@2.3.3` + `typescript@5.7.3` so root scripts (`pnpm lint`, `pnpm format:check`, `pnpm exec commitlint ...`) resolve binaries from root `node_modules/.bin/`.
  - [x] `pnpm install` from repo root — exit 0. `Done in 3m 9.7s using pnpm v10.29.2`. 172 new packages added across the dep tree. Registry was unusually slow (multiple `WARN Tarball download average speed 15 KiB/s` messages) — not a repo/config issue, transient network condition. `pnpm-lock.yaml` regenerated; diff staged for commit.
  - [x] **Did NOT** author any config files — those land in Tasks 3–5 per spec.
  - [x] Quality-gate check: `pnpm -w typecheck` first run post-install = 16/16 successful (1.48s, no cache hits — expected, since `pnpm-lock.yaml` is a turbo input); second run = `>>> FULL TURBO` 16/16 cached (168ms). No typecheck regression from the devDep additions.

- [ ] **Task 3: Author shared ESLint flat config + `./eslint` subpath export** (AC: 1, 2, 3)
  - [ ] Create `packages/keel-invariants/eslint.config.keel-invariants.js` (ESM, `.js` extension since `packages/keel-invariants/package.json` has `type: "module"`).
  - [ ] Import `@eslint/js` recommended config and `typescript-eslint` recommended config; spread them in a flat-config array.
  - [ ] Scan targets: `**/*.{ts,tsx,js,jsx,mjs,cjs}`. Use `typescript-eslint.configs.recommended` for `*.ts` / `*.tsx` files and `@eslint/js.configs.recommended` for `*.js` / `*.jsx` / `*.mjs` / `*.cjs` files.
  - [ ] Add `globals.node` + `globals.browser` as needed in `languageOptions.globals`.
  - [ ] Add an `ignores` entry covering: `**/dist/**`, `**/node_modules/**`, `**/.turbo/**`, `**/*.tsbuildinfo`, `**/pnpm-lock.yaml`, `_bmad/**`, `_bmad-output/**`, `.claude/**`, `docs/**`, `.ralph/**`, `ralph.py`, `pyproject.toml`, `uv.lock`. Those are outside the TS/JS workspace.
  - [ ] Export as default (`export default [ ... ]`).
  - [ ] **Do NOT** add `no-restricted-imports` rules in this story — those land in Story 1.3. Keep the flat-config array composable so Story 1.3 can append a restricted-imports layer without rewriting the base.
  - [ ] Add to `packages/keel-invariants/package.json` `exports`: `"./eslint": "./eslint.config.keel-invariants.js"`.
  - [ ] Update `packages/keel-invariants/src/index.ts` to re-export nothing from the configs (configs are consumed via subpath `@keel/keel-invariants/<subpath>`, not the main entry). Leave `export {};` as-is unless a type is needed.

- [ ] **Task 4: Author shared Prettier config + `./prettier` subpath export** (AC: 1, 5)
  - [ ] Create `packages/keel-invariants/prettier.config.keel-invariants.js` (ESM, default-export a config object).
  - [ ] Keel house style (modest choices — the important thing is CONSISTENCY, not bikeshedding): `printWidth: 100`, `tabWidth: 2`, `useTabs: false`, `semi: true`, `singleQuote: true`, `trailingComma: "all"`, `bracketSpacing: true`, `arrowParens: "always"`, `endOfLine: "lf"` (matches `.editorconfig`).
  - [ ] Add to `packages/keel-invariants/package.json` `exports`: `"./prettier": "./prettier.config.keel-invariants.js"`.
  - [ ] Create a root-level `.prettierignore` file (since Prettier honours `.prettierignore` separately from the config) covering the same dirs as the ESLint ignores: `**/dist/`, `**/node_modules/`, `**/.turbo/`, `**/*.tsbuildinfo`, `pnpm-lock.yaml`, `_bmad/`, `_bmad-output/`, `.claude/`, `docs/`, `.ralph/`, `*.py`, `uv.lock`. Keep paths relative to repo root.

- [ ] **Task 5: Author shared commitlint config + `./commitlint` subpath export** (AC: 1, 6)
  - [ ] Create `packages/keel-invariants/commitlint.config.keel-invariants.js` (ESM, default-export). Extend `@commitlint/config-conventional`:
    ```js
    import conventional from '@commitlint/config-conventional';
    export default {
      extends: ['@commitlint/config-conventional'],
      rules: {
        // allow-list Keel's conventional-commit scope pattern: chore/*, feat/*, fix/*, docs/* type prefixes, plus any scope.
        // No customisation needed at 1.0 beyond the conventional base; leave rules empty for forward-compat.
      },
    };
    ```
    Import is for readability — the `extends` field is what `@commitlint/cli` actually consumes at runtime.
  - [ ] Add to `packages/keel-invariants/package.json` `exports`: `"./commitlint": "./commitlint.config.keel-invariants.js"`.

- [ ] **Task 6: Wire consumers — root configs + per-package ESLint configs + package.json scripts** (AC: 2, 3, 5, 6)
  - [ ] Create `eslint.config.js` at repo root (ESM, `type: "module"` in root `package.json`):
    ```js
    import shared from '@keel/keel-invariants/eslint';
    export default shared;
    ```
  - [ ] Create `prettier.config.js` at repo root:
    ```js
    import shared from '@keel/keel-invariants/prettier';
    export default shared;
    ```
  - [ ] Create `commitlint.config.js` at repo root:
    ```js
    import shared from '@keel/keel-invariants/commitlint';
    export default shared;
    ```
  - [ ] Create `eslint.config.js` in each of the **16** workspace members: `apps/web/` + `packages/{audit,billing,config,contracts,core,create-keel-app,db,devbox,email,flags,jobs,keel-generator,keel-invariants,keel-templates,ui}/`. Each file is the same 2-line ESM re-export:
    ```js
    import shared from '@keel/keel-invariants/eslint';
    export default shared;
    ```
    (Yes, `packages/keel-invariants/` gets one too — it lints itself with the config it exports, which is the simplest consistent rule.)
  - [ ] Add `"lint": "eslint ."` to each of the 16 workspace members' `package.json` `scripts` block. Turbo will orchestrate these via `turbo run lint` (task already defined in Story 1.1's `turbo.json` Task 3 — no turbo.json change needed).
  - [ ] Add to root `package.json` `scripts`:
    - `"lint": "turbo run lint"` (verify it already exists from Story 1.1; leave as-is if so).
    - `"format": "prettier --write ."`
    - `"format:check": "prettier --check ."`
  - [ ] Root-level `package.json` must have `"type": "module"` confirmed (it should from Story 1.1) — the `.js` re-export files assume ESM.

- [ ] **Task 7: Verify all quality gates green + turbo cache intact** (AC: 3, 4, 5, 6)
  - [ ] `pnpm install` — exit 0, no resolution warnings. Capture final line.
  - [ ] `pnpm -w typecheck` — first run completes green across 16 packages; second run reports `>>> FULL TURBO` (16/16 cached). Capture both final lines.
  - [ ] `pnpm -w lint` — first run completes green across 16 packages (the shared config on empty `src/index.ts` files should produce zero errors/warnings); second run MUST also report `>>> FULL TURBO`. If any warnings fire, fix the config — do not suppress files.
  - [ ] `pnpm format:check` — exit 0 across the full committed tree. If it fails, run `pnpm format` once, review the diff, commit, and re-run until green. **Do not** add files to `.prettierignore` to mask failures unless they're genuinely outside the TS/JS workspace (Python, YAML, lockfiles, etc.).
  - [ ] `pnpm exec commitlint --from origin/main --to HEAD` — validates every commit on this branch conforms to conventional-commit format. Exit 0 required. (Ralph's existing commit-message discipline from Story 1.1 already satisfies this; the check confirms the shared config works, not that the commits suddenly need to comply.)
  - [ ] Run `git ls-files '*.generated.*' 'tsconfig.base.json'` at repo root — should show only `packages/keel-invariants/tsconfig.base.json`. Zero matches for `.generated.` (those don't land until Epic 1.9+).
  - [ ] Capture all evidence (command transcripts) in Debug Log References. This task is VERIFICATION only — no source edits permitted here. If a gate fails, reopen the appropriate earlier Task, fix, commit, then re-run.

## Dev Notes

### Relevant architecture patterns and constraints

**`packages/keel-invariants/` is the canonical hardwired-rules home.** Every shared lint/format/commit/tsconfig rule lives here and every downstream package consumes via subpath export. This is **Layer 1** of the three-layer invariant pattern (architecture lines 85–93): machine-enforced. Layers 2 (agent-readable `INVARIANTS.md`) + 3 (documentation) come in later stories (1.7, 1.8–1.9).
[Source: architecture.md lines 85–93 (three-layer invariant pattern), 842 (machine-enforced layer), 461 (PRD: hardwired vs generated distinction)]

**Subpath exports are the MECHANISM.** Consumers write `import shared from '@keel/keel-invariants/eslint'` — not a relative path, not a deep import. The `exports` field in `package.json` maps each subpath to its source file. No TypeScript types here — all config files are plain JS with default exports (tooling's de-facto interop pattern).

**`no-restricted-imports` rules are Story 1.3 scope, NOT 1.2.** Epic 1 decomposes the boundary-rule work into two stories:
- 1.2 — shared config PLUMBING (this story). Establishes the export mechanism + minimal recommended rules.
- 1.3 — shared config CONTENT for boundaries. Layers `no-restricted-imports` rules on top of the 1.2 base to forbid cross-package relative imports and `@keel/<pkg>/internal/*` deep paths.

Keep the flat-config array shape **composable** (array spread / append) so Story 1.3 can append a restricted-imports layer without rewriting the base. [Source: epics.md Story 1.3 AC, lines 721–744]

**TypeScript extends via subpath export.** TS 5.x honours the `exports` field on `extends` when the value is a bare specifier like `"@keel/keel-invariants/tsconfig"`. This works because pnpm workspace symlinks make `@keel/keel-invariants` resolvable from any package's directory during tsc's module resolution. Verified pattern — no `baseUrl` change needed. [Source: TypeScript 5.0+ release notes on package-exports in `extends`]

**File-structure invariants carry over from Story 1.1.** No `__tests__/`, no `lib/` split, no deep exports beyond what's declared in `package.json` `exports`. Each config file lives at the package root (not under `src/`) because they ship as JS (not TypeScript) and are consumed directly. [Source: architecture.md lines 1244, 557]

**Versioning is exact-minor (I7).** Pin each devDep to its exact-minor in both `packages/keel-invariants/package.json` AND root `package.json`. Patch releases are allowed via pnpm's default range. No `^`, no `~` with major-wildcarding. Implementation-time picks specific versions available at install. [Source: architecture.md lines 342–350 (I7 pinning contract)]

**Root-level dev deps vs keel-invariants dev deps.** Put each linter binary in BOTH locations:
- `packages/keel-invariants/package.json` — because the package's own config files transitively require them (e.g. the eslint flat config imports `@eslint/js`).
- `{repo-root}/package.json` — because root scripts (`pnpm lint` via turbo, `pnpm format:check`, `pnpm exec commitlint`) need the binaries resolvable from `node_modules/.bin/`.
pnpm's default behaviour dedupes into a single `node_modules/.pnpm` store, so there's no duplication cost.

### Source tree components to touch

**Moved (Task 1):**
- `tsconfig.base.json` → `packages/keel-invariants/tsconfig.base.json` (via `git mv` to preserve history).

**Modified (Task 1):**
- `packages/keel-invariants/tsconfig.base.json` — path values updated to be relative to the new location (see subtask for math).
- `packages/keel-invariants/tsconfig.json` — `extends` updated to `"./tsconfig.base.json"`.
- `apps/web/tsconfig.json` + `packages/{14 others}/tsconfig.json` — `extends` updated to `"@keel/keel-invariants/tsconfig"`. Total: 15 files.

**Modified (Task 2):**
- `packages/keel-invariants/package.json` — devDeps added (`eslint`, `@eslint/js`, `typescript-eslint`, `globals`, `prettier`, `@commitlint/cli`, `@commitlint/config-conventional`).
- `{repo-root}/package.json` — same devDeps added (duplicate pin for root scripts).
- `pnpm-lock.yaml` — regenerated by `pnpm install`.

**Created (Task 3):**
- `packages/keel-invariants/eslint.config.keel-invariants.js`.

**Modified (Task 3):**
- `packages/keel-invariants/package.json` `exports` — add `"./eslint"` subpath.

**Created (Task 4):**
- `packages/keel-invariants/prettier.config.keel-invariants.js`.
- `{repo-root}/.prettierignore`.

**Modified (Task 4):**
- `packages/keel-invariants/package.json` `exports` — add `"./prettier"` subpath.

**Created (Task 5):**
- `packages/keel-invariants/commitlint.config.keel-invariants.js`.

**Modified (Task 5):**
- `packages/keel-invariants/package.json` `exports` — add `"./commitlint"` subpath.

**Created (Task 6):**
- `{repo-root}/eslint.config.js` (re-export root shim).
- `{repo-root}/prettier.config.js` (re-export root shim).
- `{repo-root}/commitlint.config.js` (re-export root shim).
- 16 × `<member>/eslint.config.js` (one per workspace member — re-export shims).

**Modified (Task 6):**
- 16 × `<member>/package.json` — add `"lint": "eslint ."` script.
- `{repo-root}/package.json` — add `format`, `format:check` scripts (lint already wired in Story 1.1).

**Unchanged across the story:** `pnpm-workspace.yaml`, `turbo.json` (lint task already defined), root `tsconfig.json` (solution file), `.nvmrc`, `.editorconfig`, `.gitignore`, every package's `src/index.ts`.

### Testing standards summary

**No unit / integration tests land in Story 1.2.** This is infrastructure scaffolding — the test surface is the CI quality gates (typecheck + lint + format:check + commitlint) run in Task 7. No `*.test.ts` files should be written.

**Verification by command evidence (Task 7):** every gate produces a deterministic exit-0 or exit-non-zero signal; capture the final-line output of each run in Debug Log References. Vitest installation is deferred to a later story (Story 1.4-ish, bundled with prek hooks), per Story 1.1 Dev Notes line 163.

**ATDD red phase for this story is EMPTY.** The quality gates are the "tests" — they're run, not authored. If a future story wants red-phase tests for invariants (e.g., "`pnpm lint` should fail when a boundary is violated"), it lands in Story 1.3 or later.

### Project Structure Notes

**Alignment with unified project structure (paths, modules, naming):**

- ✅ `packages/keel-invariants/` hosts the shared configs + tsconfig-base — matches architecture lines 461, 842, 1240.
- ✅ Subpath exports match architecture's `exports`-only rule (no deep internal imports from consumers).
- ✅ `tsconfig.base.json` location matches architecture line 1240 post-move (`extends keel-invariants/tsconfig.base.json`).
- ✅ ESLint flat config (ESM `.js`) matches the project's `type: "module"` posture across the workspace.
- ✅ Commit-message compliance already established by Ralph — commitlint config enforces what was already the norm.

**Detected conflicts or variances (with rationale):**

- **Variance — scope is narrower than the epic text implies.** The epic subtitle "packages/keel-invariants bootstrap" could be read as "populate every keel-invariants subdir architecture line 1422 lists" (`schemas/`, `semgrep-rules/`, `eslint-rules/`, `prompt-injection-rules/`). That's NOT this story's scope — those subdirs land in Stories 1.8 (invariants manifest), 1.10+ (design tokens), and later epics (semgrep rules in Epic 4, prompt-injection rules in Epic 6 or wherever agent-safety lands). Story 1.2's scope is the four shared configs only (eslint + prettier + commitlint + tsconfig). The epics.md AC is the authoritative scope — it enumerates exactly these four configs + exports — so when architecture-vs-epic conflicts appear, epic wins. [Rule: carry-forward from Story 1.1 Dev Notes variance pattern.]
- **Variance — `commit-msg` hook NOT registered in Story 1.2.** Architecture line 1239 lists `.prek/hooks.yaml` as a root config file; epics.md Story 1.5 AC (lines 777–818) explicitly pins "`commit-msg` hook invoking commitlint" to Story 1.5. Story 1.2 ships the commitlint CONFIG only, no hook. The root `commitlint.config.js` re-export makes `pnpm exec commitlint ...` work standalone (AC 6); Story 1.5 wires the hook.
- **Variance — ESLint boundary rules deferred to Story 1.3.** As noted in Dev Notes above; epics.md Story 1.3 (lines 721–744) is the dedicated home for `no-restricted-imports` + `@keel/<B>/internal/*` rejection rules. Story 1.2 must keep the flat-config composable so Story 1.3 can append cleanly.
- **Variance — tsconfig path values require careful mental verification after move.** Story 1.1 fixed TS5090 by prefixing each `paths` value with `./` (RALPH.md lesson 2026-04-19). After moving `tsconfig.base.json` two directories deeper, every path reference now needs to walk UP via `../` + DOWN into the target package. Get this wrong and `pnpm -w typecheck` will fail with module-resolution errors, NOT TS5090. Count dots carefully: `packages/keel-invariants/tsconfig.base.json` → `../audit/src/index.ts` resolves to `packages/audit/src/index.ts` ✓. `../../apps/web/src/index.ts` resolves to `apps/web/src/index.ts` ✓. Every package that isn't `apps/web` uses the `../<pkg>/src/index.ts` pattern; `apps/web` uses `../../apps/web/src/index.ts`.

### Previous Story Intelligence (from Story 1.1)

**Files created / modified in Story 1.1 that Story 1.2 builds on:**
- `{repo-root}/{package.json, pnpm-workspace.yaml, turbo.json, tsconfig.json, tsconfig.base.json, .nvmrc, .editorconfig, .gitignore}`.
- 16 × `<member>/{package.json, tsconfig.json, src/index.ts, README.md}`.
- `pnpm-lock.yaml`.

**Patterns established in Story 1.1 that Story 1.2 follows:**
- `type: "module"` everywhere (ESM).
- Exact-minor version pins (I7 contract).
- `composite: true` + `noEmit: false` override per-package tsconfig.
- Turbo task pipeline runs `typecheck`, `build`, `test`, `lint` (lint task exists but has no content until this story).
- One source of truth for rules, consumed via subpath / named import (not copy-paste).

**Landmines Story 1.1 hit (RALPH.md lessons):**
- **TS5090 with bare `paths` values.** After moving `tsconfig.base.json`, re-verify `paths` values still start with `./` or `../` (relative). TS 5.0+ demands this when `baseUrl` is absent. The `../<pkg>/src/index.ts` pattern is still relative — safe.
- **Multi-commit story PRs drift metadata.** When the PR transitions Draft → Open at the end of Story 1.2, re-read the PR title/body and rewrite to cover all task commits. Don't rely on the initial `docs(story):` body.

**Testing approaches validated in Story 1.1:**
- `pnpm -w typecheck` twice → `>>> FULL TURBO` on second run is the cache-hit assertion.
- `git ls-files` + grep for structural invariants works without an automated linter.
- `pnpm -r list --depth -1 --json` enumerates workspace members deterministically.

### Git Intelligence Summary (recent patterns)

Last commits on feat/story-1-1-monorepo-scaffold (merged via PR #217):
- `e8a158f chore(sprint): Story 1.1 done …` — local-only, did NOT reach `main` (merge used `96142bc` as second parent). Sprint-status.yaml on main still shows `1-1 → ready-for-dev` and needs to be corrected to `done` as part of this iteration's bookkeeping.
- `96142bc feat(scaffold): Story 1.1 Task 8 — structural invariants verified`.
- `00d7396 feat(scaffold): Story 1.1 Task 7 — pnpm -w typecheck green + FULL TURBO cache`.
- `e456008 feat(scaffold): Story 1.1 Task 6 — pnpm install green + lockfile`.

Convention observed: `feat(scaffold): Story X.Y Task N — <one-line summary>`. Story 1.2 commits should follow `feat(invariants): Story 1.2 Task N — <summary>` (scope = `invariants`, since the affected package is `keel-invariants`). Keep one task per commit.

### Latest Technical Information

- **ESLint v9 flat config** is the current mainline (v9 released Apr 2024, flat config default). Legacy `.eslintrc` is deprecated. No migration path needed — this is greenfield config.
- **`typescript-eslint` v8** is the rename of the older split packages (`@typescript-eslint/{parser,eslint-plugin}`) into a single dependency. Use `import tseslint from 'typescript-eslint'` and spread `tseslint.configs.recommended` in the flat array.
- **Prettier v3** is stable; no breaking changes worth flagging for a greenfield config. v3 default for `trailingComma` changed to `"all"` — matches Keel house style here, so no override needed.
- **commitlint v19** default `extends: ['@commitlint/config-conventional']` exactly captures Ralph's existing commit discipline. No rule overrides needed at 1.0.

### References

- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.2, lines 698–719] — Story AC (authoritative scope).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.3, lines 721–744] — Story 1.3 boundary-rule scope (what Story 1.2 must NOT include).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.5, lines 777–818] — Story 1.5 commit-msg hook scope (what Story 1.2's commitlint config enables but does not wire).
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Three-layer-invariant-pattern, lines 85–93] — why keel-invariants is the hardwired-rules home.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Machine-enforced-layer, line 842] — keel-invariants as Layer 1.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#File-Organisation-Patterns, lines 1237–1244] — per-package tsconfig extends keel-invariants/tsconfig.base.json.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Version-Pinning-I7, lines 342–350] — exact-minor pins for linter/formatter deps.
- [Source: `_bmad-output/planning-artifacts/prd.md`#FR41, section "FR41–FR45 (Invariants)", lines 842, 848, 153–154, 529, 580, 842] — hardwired vs generated distinction; ESLint + TS project refs enforce boundaries.
- [Source: `_bmad-output/planning-artifacts/prd.md`#I7, architecture.md lines 342–350] — exact-minor pinning contract.
- [Source: `_bmad-output/implementation-artifacts/1-1-monorepo-scaffold-typescript-project-references.md`] — previous-story intelligence (variances, TS5090 fix, file layout).
- [Source: `RALPH.md`#Signposts 2026-04-19] — "Story 1.2 will move `tsconfig.base.json` INTO `packages/keel-invariants/`" + tsconfig `./` prefix lesson.

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (via Ralph build loop — one task per iteration).

### Debug Log References

**Task 1 (2026-04-19):**
- `pnpm install` → `Done in 501ms using pnpm v10.29.2` (after the 15 `@keel/keel-invariants: workspace:*` devDep additions — `@keel/keel-invariants` symlink materialised under each consumer's `node_modules/@keel/`).
- `pnpm -w typecheck` (1st) → `Tasks: 16 successful, 16 total / Cached: 0 cached, 16 total / Time: 2.515s`.
- `pnpm -w typecheck` (2nd) → `Tasks: 16 successful, 16 total / Cached: 16 cached, 16 total / Time: 216ms >>> FULL TURBO`.
- TS6053 regression checkpoint: first typecheck attempt (before the devDep additions) produced `tsconfig.json(2,14): error TS6053: File '@keel/keel-invariants/tsconfig' not found.` in every consuming package. Fixed by declaring `@keel/keel-invariants: workspace:*` as a devDep per consumer so pnpm would symlink the package into `node_modules/@keel/`.

**Task 2 (2026-04-19):**
- Version selection (`pnpm info <pkg> version` at install time): `eslint=10.2.1`, `@eslint/js=10.0.1`, `typescript-eslint=8.58.2`, `globals=17.5.0`, `prettier=3.8.3`, `@commitlint/cli=20.5.0`, `@commitlint/config-conventional=20.5.0`.
- Compat verification (`pnpm info <pkg> peerDependencies`): `typescript-eslint@8.58.2.peerDeps.eslint = ^8.57.0 || ^9.0.0 || ^10.0.0`; `@eslint/js@10.0.1.peerDeps.eslint = ^10.0.0`; `eslint@10.2.1.engines.node = ^20.19.0 || ^22.13.0 || >=24`; host node `v20.20.0` satisfies.
- `pnpm install` → `Done in 3m 9.7s using pnpm v10.29.2` — exit 0. Added 172 packages. Final output lines:
  ```
  devDependencies:
  + @commitlint/cli 20.5.0
  + @commitlint/config-conventional 20.5.0
  + @eslint/js 10.0.1
  + eslint 10.2.1
  + globals 17.5.0
  + prettier 3.8.3
  + typescript-eslint 8.58.2
  ```
- `pnpm -w typecheck` (1st, post-install) → `Tasks: 16 successful, 16 total / Cached: 0 cached, 16 total / Time: 1.48s` (cache invalidated by `pnpm-lock.yaml` change — expected).
- `pnpm -w typecheck` (2nd) → `Tasks: 16 successful, 16 total / Cached: 16 cached, 16 total / Time: 168ms >>> FULL TURBO`.

### Completion Notes List

**Task 1 — Relocation + subpath export (2026-04-19):**
- Zero source edits; only config plumbing.
- **Variance applied:** added `@keel/keel-invariants: workspace:*` as `devDependencies` to 15 consuming packages (apps/web + packages/{audit,billing,config,contracts,core,create-keel-app,db,devbox,email,flags,jobs,keel-generator,keel-templates,ui}). This was NOT in the original subtask list but is required for `extends: "@keel/keel-invariants/tsconfig"` to resolve through Node module resolution. Documented in RALPH.md Lessons 2026-04-19 so future subpath-export stories don't hit the same TS6053 wall. Downstream impact: Story 1.3 (boundary rules) and any other keel-invariants consumer stories need this devDep on day 1.
- Turbo cache invalidated on first typecheck run (expected: tsconfig path inputs changed). Second run hit FULL TURBO as specified in AC 4.
- Subpath export `"./tsconfig": "./tsconfig.base.json"` in `packages/keel-invariants/package.json` is the mechanism per AC 1.
- All TS5090 lessons from Story 1.1 preserved: `paths` values remain relative (`../<pkg>/src/index.ts`, `../../apps/web/src/index.ts`) — no `baseUrl` added.

**Task 2 — Shared-config devDeps install (2026-04-19):**
- **Ecosystem-version variance.** Story subtask text prescribed "v9 line" for eslint / @eslint/js and "v19 line" for commitlint. At install time (2026-04-19), `pnpm info` reported v10.2.1 / v10.0.1 / v20.5.0 respectively as current stable. Story spec's fallback directive ("choose whatever `pnpm info <pkg> version` reports at run time") takes priority — went with current stable. Peer-dep compat confirmed: `typescript-eslint@8.58.2` accepts ESLint v8/v9/v10; `@eslint/js@10.0.1` requires ESLint ^10. No break in the flat-config shape between v9 and v10 (legacy eslintrc was removed; flat-config API identical), so Story 1.3 composability directive is preserved.
- **Pinning style.** Chose plain pinned patch versions (`eslint@10.2.1`, not `^10.2.1` / `~10.2.1`) — matches Story 1.1's `typescript@5.7.3` / `turbo@2.3.3` convention. Story spec says "exact-minor per I7" + "no `^`, no `~` with major-wildcarding"; the strictest interpretation consistent with Story 1.1's established pattern is plain pinned versions. Patch bumps require intentional lockfile update via a future dependency-maintenance task — not automatic.
- **Duplicate pinning.** Same 7 devDeps declared in BOTH `packages/keel-invariants/package.json` AND root `package.json` per spec. pnpm's default behavior dedupes into a single `node_modules/.pnpm` store — zero disk/install overhead; the duplication is purely declarative (root needs the binary path for `pnpm exec commitlint` / `pnpm format:check`; keel-invariants needs it for config-file `import` statements authored in Tasks 3–5).
- **Install-time note.** 3m 9.7s install (typical: ~20s). Registry was unusually slow — repeated `WARN Tarball download average speed … below 50 KiB/s` messages. Not a repo/config concern; would resolve on a second run. No retry performed since exit code was 0.
- No typecheck regression post-install: 16/16 green, FULL TURBO cache intact.

### File List

**Task 1 (2026-04-19):**
- Moved: `tsconfig.base.json` → `packages/keel-invariants/tsconfig.base.json` (via `git mv`; paths rewritten to `../<pkg>/src/index.ts` and `../../apps/web/src/index.ts`).
- Modified: `packages/keel-invariants/tsconfig.json` (extends → `./tsconfig.base.json`).
- Modified: `packages/keel-invariants/package.json` (added `"./tsconfig"` subpath export).
- Modified: `apps/web/tsconfig.json` + 14 × `packages/<pkg>/tsconfig.json` (extends → `@keel/keel-invariants/tsconfig`). 15 files total.
- Modified: `apps/web/package.json` + 14 × `packages/<pkg>/package.json` (added `devDependencies: { "@keel/keel-invariants": "workspace:*" }`). 15 files total. **Variance from original subtask list** — see Completion Notes.
- Unchanged: root `tsconfig.json`, `pnpm-lock.yaml` (workspace symlinks created without lockfile churn), `pnpm-workspace.yaml`, `turbo.json`, all `src/index.ts`.

**Task 2 (2026-04-19):**
- Modified: `packages/keel-invariants/package.json` — added 7 devDeps (`eslint@10.2.1`, `@eslint/js@10.0.1`, `typescript-eslint@8.58.2`, `globals@17.5.0`, `prettier@3.8.3`, `@commitlint/cli@20.5.0`, `@commitlint/config-conventional@20.5.0`).
- Modified: `package.json` (repo root) — added the same 7 devDeps alongside existing `turbo@2.3.3` + `typescript@5.7.3`.
- Modified: `pnpm-lock.yaml` — regenerated by `pnpm install`; 172 new packages in the dep tree.
- Unchanged: every `<member>/package.json` except keel-invariants (per-package consumers get their own lint deps wiring in Task 6); no tsconfig changes; no config-file authoring (that's Tasks 3–5).
