# Story 1.3: ESLint `no-restricted-imports` import-boundary rules

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want ESLint `no-restricted-imports` rules layered on the Story 1.2 shared flat config that enforce `@keel/<pkg>`-only imports across package boundaries,
so that compile-time package boundaries cannot be violated by relative-path end-runs, `@keel/<pkg>/internal/*` deep imports, or self-imports via the `@keel/<own>` alias (FR34).

## Acceptance Criteria

1. **Given** a file in `packages/<A>/src/` that attempts to import via a relative path crossing a package `src/` boundary (e.g. `../../<B>/src/foo` or `../../../apps/web/src/…`),
   **When** `pnpm lint` runs inside `<A>`,
   **Then** ESLint reports `no-restricted-imports` against that source line
   **And** the rule message names the `@keel/<B>` alias as the required replacement.

2. **Given** a file anywhere in the workspace that imports `@keel/<B>/internal` or `@keel/<B>/internal/<anything>`,
   **When** `pnpm lint` runs in that package,
   **Then** ESLint rejects the import
   **And** the rule message explains that `@keel/<pkg>/internal/*` subpaths are forbidden across packages (public surface is `src/index.ts` only).

3. **Given** a file inside `packages/<A>/src/` (or `apps/web/src/`) that imports `@keel/<A>` or `@keel/<A>/…` — i.e. a self-import via the alias,
   **When** `pnpm lint` runs in `<A>`,
   **Then** ESLint rejects the self-import
   **And** the rule message instructs "use a relative path within the same package" and names the self-package (`<A>`).

4. **Given** the boundary rules run alongside TypeScript project references (Story 1.1) and the shared flat config (Story 1.2),
   **When** both `pnpm -w typecheck` and `pnpm -w lint` execute,
   **Then** lint catches string-based violations (AC 1–3) and TS project-refs catch graph-level ones — belt-and-braces
   **And** `pnpm -w typecheck` remains 16/16 green with `>>> FULL TURBO` on cache-warm second runs (no typecheck regression from the config shape change).

5. **Given** all 16 workspace members (`apps/web` + 15 packages) now consume a package-scoped ESLint config,
   **When** `pnpm -w lint` runs at repo root via `turbo run lint`,
   **Then** every member exits 0 on its current clean `src/index.ts` contents (no false-positives on well-formed code)
   **And** the commitlint gate `pnpm exec commitlint --from origin/main --to HEAD` remains exit 0.

## Tasks / Subtasks

- [ ] **Task 1: Extend shared ESLint config with universal `no-restricted-imports` rules + `forPackage(ownName)` factory** (AC: 1, 2, 3)
  - [ ] Edit `packages/keel-invariants/eslint.config.keel-invariants.js`. Preserve the existing 6-entry array (Task 3 of Story 1.2 composability contract). Append a 7th entry with universal rules (AC 1 + 2) and add a NAMED export `forPackage(ownName)` that layers the self-import rule (AC 3).
  - [ ] The universal 7th entry applies to `**/*.{ts,tsx,js,jsx,mjs,cjs}` and declares:
    ```js
    {
      files: ['**/*.{ts,tsx,js,jsx,mjs,cjs}'],
      rules: {
        'no-restricted-imports': ['error', {
          patterns: [
            // AC 1: block relative paths that cross any package src/ boundary.
            // Matches imports whose specifier path climbs into a sibling `packages/*/src/**` or `apps/*/src/**`.
            {
              group: ['**/packages/*/src', '**/packages/*/src/**', '**/apps/*/src', '**/apps/*/src/**'],
              message: 'No relative imports crossing a package src/ boundary. Use the @keel/<pkg> alias for cross-package imports (architecture.md § Public surface enforcement).',
            },
            // AC 2: block deep @keel/<pkg>/internal/* imports across packages.
            // Public surface of every keel package is src/index.ts only.
            {
              group: ['@keel/*/internal', '@keel/*/internal/**'],
              message: '@keel/<pkg>/internal/* is forbidden across packages. Public surface is src/index.ts only (architecture.md § Public surface enforcement).',
            },
          ],
        }],
      },
    }
    ```
  - [ ] Add a named export `forPackage(ownName)` at the bottom of the file. It returns a NEW array composed of the shared base array spread + an 8th entry with a per-package self-import rule (AC 3). The 8th entry uses the SAME `no-restricted-imports` rule shape but adds an extra pattern:
    ```js
    export function forPackage(ownName) {
      return [
        ...sharedBase, // the 7-entry default export from above
        {
          files: ['**/*.{ts,tsx,js,jsx,mjs,cjs}'],
          rules: {
            'no-restricted-imports': ['error', {
              patterns: [
                // Repeat AC 1 + 2 patterns so this block is self-contained.
                { group: ['**/packages/*/src', '**/packages/*/src/**', '**/apps/*/src', '**/apps/*/src/**'], message: 'No relative imports crossing a package src/ boundary. Use the @keel/<pkg> alias.' },
                { group: ['@keel/*/internal', '@keel/*/internal/**'], message: '@keel/<pkg>/internal/* is forbidden across packages. Public surface is src/index.ts only.' },
                // AC 3: self-import via alias is a code smell — refer to relative paths.
                { group: [`@keel/${ownName}`, `@keel/${ownName}/**`], message: `Self-import: use a relative path within the same package ('${ownName}'), not the @keel/${ownName} alias.` },
              ],
            }],
          },
        },
      ];
    }
    ```
    **Why repeat patterns?** ESLint's `no-restricted-imports` rule is NOT additive across flat-config entries — the LAST entry that declares the rule wins entirely (shallow-merge semantics on rule options). To keep AC 1 + 2 active under `forPackage(...)`, the 8th entry must repeat them. Ref: <https://eslint.org/docs/latest/use/configure/rules#disabling-inline-configuration-comments> and flat-config rule-merge semantics. A sanity check: the default export (used by any consumer that doesn't call `forPackage`) still enforces AC 1 + 2; `forPackage` extends with AC 3 on top.
  - [ ] Preserve existing imports (`@eslint/js`, `typescript-eslint`, `globals`) and the 6-entry base. Only append. Keep the module as an ESM file (package has `type: module`). The default export stays the 7-entry array.
  - [ ] Verify `packages/keel-invariants/package.json` `exports` still has `"./eslint": "./eslint.config.keel-invariants.js"` — no change needed; consumers already import from `@keel/keel-invariants/eslint`. The `forPackage` named export is reachable from the same subpath: `import { forPackage } from '@keel/keel-invariants/eslint'`.
  - [ ] No new devDeps. Everything needed is already installed (Task 2 of Story 1.2).
  - [ ] **Self-verification probe (dev loop — not committed):** from `packages/audit/` run:
    ```bash
    node -e "import('@keel/keel-invariants/eslint').then(m => console.log('default-len=' + m.default.length + ' forPackage-type=' + typeof m.forPackage))"
    ```
    Expect: `default-len=7 forPackage-type=function`.
  - [ ] Run `pnpm -w typecheck` — still 16/16 `>>> FULL TURBO` (package.json exports unchanged, config file is an input for the `lint` task only, not `typecheck`).
  - [ ] Run `pnpm -w lint` — 16/16 green, 0 errors/warnings. Empty `src/index.ts` files have nothing to import — this confirms the rules don't fire false-positives on clean code.
  - [ ] Commit per Ralph convention: `feat(invariants): Story 1.3 Task 1 — extend shared ESLint with no-restricted-imports + forPackage factory`. IP + RALPH.md upkeep in the same commit.

- [ ] **Task 2: Migrate all 16 per-package `eslint.config.js` files to `forPackage(<name>)`** (AC: 1, 2, 3, 5)
  - [ ] Each of the 16 files currently reads:
    ```js
    import shared from '@keel/keel-invariants/eslint';
    export default shared;
    ```
    After this task, each file reads:
    ```js
    import { forPackage } from '@keel/keel-invariants/eslint';
    export default forPackage('<own-name>');
    ```
    where `<own-name>` is the suffix after `@keel/` in the package's own `package.json` `name` field.
  - [ ] Mapping (exhaustive, one line per file):
    - `apps/web/eslint.config.js` → `forPackage('web')` (name = `@keel/web`).
    - `packages/audit/eslint.config.js` → `forPackage('audit')`.
    - `packages/billing/eslint.config.js` → `forPackage('billing')`.
    - `packages/config/eslint.config.js` → `forPackage('config')`.
    - `packages/contracts/eslint.config.js` → `forPackage('contracts')`.
    - `packages/core/eslint.config.js` → `forPackage('core')`.
    - `packages/create-keel-app/eslint.config.js` → `forPackage('create-keel-app')`.
    - `packages/db/eslint.config.js` → `forPackage('db')`.
    - `packages/devbox/eslint.config.js` → `forPackage('devbox')`.
    - `packages/email/eslint.config.js` → `forPackage('email')`.
    - `packages/flags/eslint.config.js` → `forPackage('flags')`.
    - `packages/jobs/eslint.config.js` → `forPackage('jobs')`.
    - `packages/keel-generator/eslint.config.js` → `forPackage('keel-generator')`.
    - `packages/keel-invariants/eslint.config.js` → `forPackage('keel-invariants')`.
    - `packages/keel-templates/eslint.config.js` → `forPackage('keel-templates')`.
    - `packages/ui/eslint.config.js` → `forPackage('ui')`.
  - [ ] Root `eslint.config.js` shim: **leave unchanged** (2-line default re-export of the 7-entry shared base). `eslint .` from root, if ever invoked directly, lints only repo-root `.js`/`.cjs` files (not per-package `src/`). Per-package configs run under `turbo run lint` from each member's own cwd, which picks up the local `eslint.config.js`. The root shim is effectively the "catch-all for stray repo-root scripts" — no self-package identity required.
  - [ ] Verify `packages/<pkg>/package.json` still declares `@keel/keel-invariants` as a devDep (added in Story 1.2 Task 1). The subpath import `@keel/keel-invariants/eslint` only resolves if pnpm has symlinked the package into the consumer's `node_modules/` — which it does only for declared deps. This precondition is already met for all 16 members by Story 1.2 Task 1 + Task 6; no `package.json` edits needed here. **Verify** with `ls packages/audit/node_modules/@keel/` (expect symlink to `keel-invariants`). If absent for any member, add `"@keel/keel-invariants": "workspace:*"` to its `devDependencies` and re-run `pnpm install`.
  - [ ] Run `pnpm -w lint` — expect 16/16 green. Empty `src/index.ts` everywhere → no import statements → no rule can fire. The config LOADS successfully is the verification here (any import/export typo in the 16 edits would blow up `forPackage is not a function` immediately).
  - [ ] Commit: `feat(invariants): Story 1.3 Task 2 — wire 16 per-package eslint.config.js to forPackage(<name>)`.

- [ ] **Task 3: ATDD smoke probes proving each AC fires** (AC: 1, 2, 3)
  - [ ] These probes are one-shot verifications using `eslint --stdin`. They produce NO committed fixture files. Each probe pipes synthetic source through ESLint against a specific package's config and grep's the output for the expected rule-id + message.
  - [ ] **AC 1 probe (cross-package relative import):** from `packages/audit/`:
    ```bash
    echo "import foo from '../../contracts/src/index.ts';" | pnpm exec eslint --stdin --stdin-filename src/ac1-probe.ts --no-warn-ignored 2>&1 | tee /tmp/ac1.out
    ```
    Expect stdout to contain: `no-restricted-imports` + "No relative imports crossing a package src/ boundary". Expect exit code 1.
  - [ ] **AC 2 probe (internal/* import):** from `packages/audit/`:
    ```bash
    echo "import { x } from '@keel/contracts/internal/foo';" | pnpm exec eslint --stdin --stdin-filename src/ac2-probe.ts --no-warn-ignored 2>&1 | tee /tmp/ac2.out
    ```
    Expect `no-restricted-imports` + "@keel/<pkg>/internal/* is forbidden across packages". Exit 1.
  - [ ] **AC 3 probe (self-import via alias):** from `packages/audit/`:
    ```bash
    echo "import { x } from '@keel/audit';" | pnpm exec eslint --stdin --stdin-filename src/ac3-probe.ts --no-warn-ignored 2>&1 | tee /tmp/ac3.out
    ```
    Expect `no-restricted-imports` + "Self-import: use a relative path" + the literal string `'audit'`. Exit 1.
  - [ ] **AC 3 probe (apps/web self-import):** from `apps/web/`:
    ```bash
    echo "import { x } from '@keel/web';" | pnpm exec eslint --stdin --stdin-filename src/ac3-web-probe.ts --no-warn-ignored 2>&1 | tee /tmp/ac3-web.out
    ```
    Expect same shape as above with `'web'` as the self-package name.
  - [ ] **Negative probe (allowed import):** from `packages/audit/`:
    ```bash
    echo "import { x } from '@keel/contracts';" | pnpm exec eslint --stdin --stdin-filename src/ok-probe.ts --no-warn-ignored 2>&1
    ```
    Expect exit 0 (no errors — importing another package's public surface via alias is legal).
  - [ ] Capture every probe's output in the story's Debug Log References when Task 3 lands. If ANY probe produces unexpected output, fix the rule (loop back to Task 1).
  - [ ] **No commits at this step's verification loop** — probes are ephemeral. The Task 3 commit carries only the Debug Log entries documenting the probe evidence: `feat(invariants): Story 1.3 Task 3 — ATDD smoke probes verify boundary rules fire`.
  - [ ] **ATDD red-phase note:** this story's red phase is the expectation that probes AC 1 / AC 2 / AC 3 produce non-zero exit codes with the correct error signatures BEFORE Task 1's rules land. Since Task 1 + 2 precede Task 3 in the implementation order, the red phase was implicit during the Task 1 dev loop (before adding the rule, the probe exits 0). Do not add any `*.probe.ts` files to the repo.

- [ ] **Task 4: Full quality-gate verification + sprint-status update** (AC: 4, 5)
  - [ ] `pnpm install` — expect `Already up to date` / no lockfile churn (no new deps added by this story).
  - [ ] `pnpm -w typecheck` — expect 16/16 `>>> FULL TURBO` on second run. First run MAY invalidate cache if any source file was (however briefly) touched, but Tasks 1–3 only edit `eslint.config.js` files and one `.keel-invariants.js` config — none of these are TypeScript compiler inputs. Cache warm.
  - [ ] `pnpm -w lint` — expect 16/16 green on first AND second run. Cache warmth depends on whether turbo's `lint` task has cache inputs declared; Story 1.1's `turbo.json` will dictate. Whether cached or not, exit 0 is the pass criterion.
  - [ ] `pnpm format:check` — expect exit 0 (Story 1.2 normalized repo-root markdown; no new files in Story 1.3 aside from edits to existing JS configs, which should already match keel Prettier style).
  - [ ] `pnpm exec commitlint --from origin/main --to HEAD --verbose` — expect 0/0 across all branch commits (Story 1.3 commits follow the same `feat(invariants): Story 1.3 Task N — …` shape that passed for Story 1.2).
  - [ ] Update `_bmad-output/implementation-artifacts/sprint-status.yaml`: flip `1-3-eslint-no-restricted-imports-import-boundary-rules` from `ready-for-dev` → `done`, bump `last_updated`. **Land this before** the PR Draft→Open transition to avoid orphan bookkeeping commits (RALPH.md Lessons 2026-04-19 "Post-halt bookkeeping commits can orphan from main"; Story 1.2 applied this preemptively).
  - [ ] Commit: `feat(invariants): Story 1.3 Task 4 — all quality gates green + sprint-status bump` (or, if the sprint-status update is a separate commit per IP preference, split: first `feat(invariants): Task 4 — quality gates green`, then `chore(sprint): Story 1.3 done — sprint-status bump`).

## Dev Notes

### Relevant architecture patterns and constraints

**`packages/keel-invariants/` IS the hardwired-rules home.** Story 1.2 established the subpath-export mechanism (`./eslint`, `./prettier`, `./commitlint`, `./tsconfig`); Story 1.3 pours content INTO the `./eslint` export. The `no-restricted-imports` rule is substrate-layer truth — it cannot be turned off at a config edit because Story 1.6's bypass-prevention gate detects config divergence from `keel-invariants` and fails pre-merge. [Source: architecture.md lines 85–93 (three-layer invariant pattern), 561–563 (public surface enforcement), 842 (machine-enforced layer); epics.md Story 1.6 AC lines 803–828.]

**Belt-and-braces with TS project references.** AC 4 is not cosmetic — it's the architectural contract. Lint catches string-based violations at the source-line level (e.g. a literal `'../../contracts/src/foo'` in source); TS project refs catch graph-level violations (e.g. trying to import a symbol that isn't part of `@keel/contracts`'s declared `references` in `tsconfig.json`). Either fails means the PR fails; both must stay green for legal code. [Source: architecture.md lines 561–563, 689–690.]

**Flat-config composability.** Story 1.2 Task 3 preserved the array shape so Story 1.3 could append without rewriting. This story appends ONE universal entry (the 7th) at the end of the default export, and introduces `forPackage(name)` as a factory that composes that 7-entry base + one per-package entry on top. Consumers swap `import shared from '@keel/keel-invariants/eslint'` → `import { forPackage } from '@keel/keel-invariants/eslint'; export default forPackage('<name>')`. The `/eslint` subpath stays the same; the import shape per-consumer changes from default-import to named-import. [Source: Story 1.2 Dev Notes lines 143–150 "composable" contract; eslint docs on flat config rule-merge semantics.]

**`no-restricted-imports` LAST-WINS semantics.** ESLint's rule-merge behaviour under flat config is "the last config entry's `rules[<id>]` wins" — it does NOT concatenate `patterns` arrays across entries. The 8th entry in `forPackage(...)` therefore MUST repeat AC 1 + 2 patterns alongside the AC 3 self-import pattern, otherwise calling `forPackage(...)` would inadvertently narrow the rule to self-import-only. This is not a bug; it's flat-config semantics. [Source: <https://eslint.org/docs/latest/use/configure/rules> "Configuring rules" — later rule configs fully replace earlier ones for the same rule ID.]

**Relative-path pattern matching.** The `patterns` array's `group` entries use glob-like matchers against the import specifier string. `'**/packages/*/src'` matches specifiers like `'../../packages/contracts/src'` AND `'../contracts/src'` (the `**/` prefix allows any leading segment count). Likewise for `**/apps/*/src`. This is intentionally permissive to catch all climb-out-of-pkg-src variants. [Source: ESLint `no-restricted-imports` docs; minimatch/glob pattern semantics.]

**`apps/web` is the only `apps/*` member at 1.0.** AC 1's `'**/apps/*/src'` pattern is future-proof in case additional apps land (e.g. `apps/admin`); today it protects only `apps/web`. The rule is one line of config for many-apps-if-ever.

### Source tree components to touch

**Modified (Task 1):**
- `packages/keel-invariants/eslint.config.keel-invariants.js` — append 7th array entry + add `forPackage(name)` named export.

**Modified (Task 2):**
- 16 × `<member>/eslint.config.js` — swap `import shared … export default shared;` for `import { forPackage } … export default forPackage('<name>');`.
  - `apps/web/eslint.config.js`.
  - `packages/{audit, billing, config, contracts, core, create-keel-app, db, devbox, email, flags, jobs, keel-generator, keel-invariants, keel-templates, ui}/eslint.config.js`.

**Modified (Task 4):**
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — flip `1-3-…` row to `done`; bump `last_updated`.

**Unchanged across the story:** root `eslint.config.js` (stays as 2-line default re-export of the 7-entry shared base); `packages/keel-invariants/package.json` `exports` (the `./eslint` subpath already points at the right file; `forPackage` is reachable via the same subpath as a named export); all `tsconfig.json` files (TS project refs don't shift for this story); any `src/*.ts` file (this is pure config work); `turbo.json`, `pnpm-workspace.yaml`, `pnpm-lock.yaml`.

### Testing standards summary

**No unit / integration `.test.ts` files land in Story 1.3.** Like Story 1.2, the test surface IS the quality gates. Verification evidence is captured via ephemeral `eslint --stdin` smoke probes (Task 3) whose outputs land in the story's Debug Log References.

**ATDD red phase** is implicit in the Task 1 dev loop: BEFORE the rule ships, the probes for AC 1 / AC 2 / AC 3 all exit 0 (no rule → no violation). After Task 1, each probe exits 1 with the expected message. The red→green transition is the proof the rule fires. Do not commit any `*.probe.ts` fixture files.

**Turbo cache expectations** (Story 1.2 lesson carry-forward): Task 4's typecheck gate should be `>>> FULL TURBO` on its first invocation if no TypeScript compiler input has changed between Story 1.2 Task 7 (ending cache state) and Story 1.3 Task 4. Since Story 1.3 only edits `.js` config files and `sprint-status.yaml`, no TS inputs move → cache stays warm. Lint cache MAY or MAY NOT be warm — depends on whether `turbo.json` declares the eslint config files as lint-task inputs. Either way, the 16/16 exit-0 is the gate; cache warmth is observational.

### Project Structure Notes

**Alignment with unified project structure:**

- ✅ All new logic lives in `packages/keel-invariants/eslint.config.keel-invariants.js` — the machine-enforced invariants home. No new files outside keel-invariants other than 16 two-line edits of already-existing per-member configs.
- ✅ Subpath-export mechanism (Story 1.2) unchanged; same `/eslint` subpath now exports BOTH a default config array AND a named factory.
- ✅ No `__tests__/` folders. No persistent probe fixtures. No new devDeps.
- ✅ Per-package config overlays are the canonical flat-config composition pattern for member-specific behaviour.

**Detected conflicts or variances:**

- **Variance — no committed ATDD fixtures.** Story 1.2 established "verification by command evidence" for infra stories. Story 1.3 follows the same pattern. If Epic 1 later wants persistent import-boundary tests (e.g. as part of `invariants:check`), that's Story 1.9 sync-gate scope, not 1.3.
- **Variance — `no-restricted-imports` LAST-WINS forces pattern repetition in `forPackage`.** Might look like duplication, but it's the correct ESLint flat-config idiom for this rule. Alternatives (merging via function composition or using a custom rule) introduce avoidable complexity. The 8th entry is self-contained — any future story that adds another universal pattern MUST update BOTH the 7th entry AND the `forPackage` body. Ref Task 1 subtask for the exact call-out.
- **Variance — root `eslint.config.js` stays a default re-export.** No self-package identity exists at repo root; the root is not a workspace member. `eslint .` from root, if run directly, lints only repo-root `.js`/`.cjs` files against the 7-entry base (AC 1 + 2 active; AC 3 not applicable). Member-level `eslint.config.js` files take precedence when `eslint .` is invoked from a member directory (which is what `turbo run lint` does).
- **Variance — `packages/create-keel-app` gets the same treatment.** It's a published CLI (consumed via `npx`), but it's still a workspace member with its own `eslint.config.js` (Story 1.2 Task 6 planted one). The self-import rule for it (`forPackage('create-keel-app')`) is defensive — it prevents the CLI's source from accidentally depending on its own public surface via `@keel/create-keel-app`. Harmless; no boundary case needed.

### Previous Story Intelligence (from Story 1.2)

**Files / patterns Story 1.3 builds on:**
- `packages/keel-invariants/eslint.config.keel-invariants.js` — the 6-entry flat-config base. Task 1 appends a 7th entry and adds a named export.
- `packages/keel-invariants/package.json` `exports` field — `./eslint` already points at the above file. No export-field change needed for `forPackage` named export to be reachable.
- 16 × `<member>/eslint.config.js` — Story 1.2 Task 6 planted these as 2-line default re-exports. Story 1.3 Task 2 rewrites them in place to use `forPackage(<name>)`.
- `<member>/package.json` devDep on `@keel/keel-invariants: workspace:*` — Story 1.2 Task 1 added this to all 15 consumers (apps/web + 14 business packages; keel-invariants itself doesn't depend on itself). This is the precondition that makes `import … from '@keel/keel-invariants/eslint'` resolvable; no Story 1.3 change needed.
- Root `package.json` `"@keel/keel-invariants": "workspace:*"` devDep — Story 1.2 Task 6 added this. Needed for the root `eslint.config.js` shim to resolve. Still needed for Story 1.3 (root shim is unchanged).
- Turbo `lint` task pipeline — Story 1.1's `turbo.json` wired it; Story 1.2 Task 6 populated `scripts.lint` on all 16 members. Nothing to change.

**Landmines Story 1.2 hit (RALPH.md Lessons 2026-04-19) that could recur:**

- **Turbo cache sensitivity to exports edits.** Story 1.2 Task 3 observed `package.json` `exports` edits invalidate the typecheck cache (package.json is a turbo input). Story 1.3 does NOT edit `packages/keel-invariants/package.json` `exports` — only edits the `.js` config file body. Cache should stay warm through Task 1 → Task 4. If you find yourself editing `exports`, expect one-time cache invalidation.
- **Prettier auto-discovery walks up.** Once Story 1.2 Task 6 planted `prettier.config.js` at repo root, `prettier --write` with no `--config` flag auto-finds keel style. Story 1.3 edits `.js` files; `pnpm format:check` on them should be zero-noise. If a `--write` run ever reports changes, double-check you didn't accidentally mix quote styles mid-edit (Keel house style is `singleQuote: true`).
- **ESM `import` at repo root requires `"type": "module"`.** Set in root `package.json` by Story 1.2 Task 6. Don't remove. The per-package configs rely on the same `type: module` declaration in each member's `package.json` (Story 1.1 set these per-member).
- **PR metadata drift for multi-commit story PRs.** Story 1.1 + 1.2 both had to rewrite PR title/body before `gh pr ready`. Story 1.3 will too (expect ~5 commits: spec + Tasks 1–4 + optional sprint-status split). Per RALPH.md Lessons "Multi-commit story PRs drift PR metadata from reality": before `gh pr ready`, re-read `git log origin/main..HEAD --oneline` and rewrite the PR body to cover all commits.
- **Post-halt bookkeeping orphan risk.** Sprint-status update MUST land before `gh pr ready`. Apply pre-emptively per Story 1.2's precedent — same commit as Task 4 or a separate `chore(sprint):` commit pushed before the transition iteration.
- **Commitlint subject-case / header-length rules.** Story 1.2 Task 5 authored the keel commitlint config with `subject-case: [0]` + `header-max-length: [2, 'always', 120]` + `body-max-line-length: [0]`. Story 1.3 commit messages conforming to `feat(invariants): Story 1.3 Task N — <summary>` will pass comfortably (≤100 chars typical).

**Testing approaches validated in Story 1.2 that Story 1.3 inherits:**
- `pnpm -w typecheck` twice → `>>> FULL TURBO` on second run = the cache-hit assertion.
- `pnpm exec commitlint --from origin/main --to HEAD --verbose` → 0/0 across all branch commits = the commit-gate assertion.
- `pnpm format:check` → exit 0 on clean tree = the format gate.
- Subpath-resolution probe via `node -e "import('@keel/...')"` from a consuming package's cwd = the "subpath actually resolves" assertion.

### Git Intelligence Summary (recent patterns)

Last commits on `feat/story-1-2-keel-invariants-shared-configs` (merged via PR #218 as commit `784fbd0`):
- `a60e3b4 chore(ralph): Story 1.2 EPIC_DONE — PR #218 flipped to Open, clean+no-reviews+no-checks`
- `4143b5d chore(sprint): Story 1.2 done — sprint-status bump before PR transition`
- `44f6172 feat(invariants): Story 1.2 Task 7 — all quality gates green + format-fix 3 pre-existing markdown files`
- `dacd044 feat(invariants): Story 1.2 Task 6 — wire consumers: root shims + 16 per-pkg eslint configs + lint/format scripts`
- `7de1784 feat(invariants): Story 1.2 Task 5 — shared commitlint config + ./commitlint subpath export`

Convention: `feat(invariants): Story X.Y Task N — <summary>`. Story 1.3 commits follow the same scope (`invariants`, since the edits are entirely under `packages/keel-invariants/` + per-package eslint configs that consume its output). Preserve one task per commit.

### Latest Technical Information

- **ESLint `no-restricted-imports` rule — current docs:** patterns with `group` arrays accept minimatch-style globs against the import specifier. Messages are attached per-pattern. [Source: <https://eslint.org/docs/latest/rules/no-restricted-imports>]
- **Flat-config rule merge semantics:** later entries overwrite earlier entries for the SAME rule ID. No array-merge of `patterns` across entries. Confirmed by reading `typescript-eslint` v8 release notes and `eslint` v10 docs on config resolution.
- **`eslint --stdin --stdin-filename`:** the filename supplied to `--stdin-filename` determines which `files:` scoping applies. Use `src/<name>.ts` to match the `files: ['**/*.{ts,tsx}']` scoping on tseslint config entries. Add `--no-warn-ignored` to suppress "file is ignored" warnings that fire when stdin-filename happens to match an `ignores:` pattern.
- **No pinned-version upgrades in this story.** All devDeps set by Story 1.2 Task 2 (eslint@10.2.1, typescript-eslint@8.58.2, etc.) stay at their current pins. No `pnpm install` changes expected.

### References

- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.3, lines 721–744] — Story 1.3 AC (authoritative scope; four ACs mirrored here with one expanded AC 5 for full-workspace lint evidence).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.2, lines 698–719] — Story 1.2 AC (what this story builds on: shared config surface + composable array shape).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.6, lines 803–828] — Bypass-prevention scope. Story 1.3 hardwires the rule; Story 1.6 detects edits that would remove it.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Public-surface-enforcement, lines 559–563] — only `src/index.ts` exports; `@keel/<pkg>/internal/*` rejected; no relative imports crossing src/ boundary. AC 1 + 2 + 3 map directly.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#All-AI-agents-MUST, lines 685–695] — "Import across packages via `@keel/<pkg>` alias, never relative paths crossing `src/`" + "Export only via `src/index.ts`; internal paths via `@keel/<pkg>/internal/*` are ESLint-forbidden".
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Three-layer-invariant-pattern, lines 85–93] — why these rules belong in keel-invariants (Layer 1 machine-enforced).
- [Source: `_bmad-output/planning-artifacts/architecture.md`#File-Organisation-Patterns-enforcement-guidelines, lines 677–697] — "Pattern violation handling: violations fail CI. No manual suppression. Forks that disagree with a pattern fork `packages/keel-invariants/`".
- [Source: `_bmad-output/planning-artifacts/prd.md`#FR34, line 960] — System can enforce import boundaries at compile time via ESLint `no-restricted-imports` + TypeScript project references.
- [Source: `_bmad-output/planning-artifacts/prd.md`#FR41, line 973] — System can ship a versioned invariants package consumed by lint gate across all substrate and product code.
- [Source: `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`] — previous story; every variance + landmine from Story 1.2 applies as carry-forward for Story 1.3.
- [Source: `RALPH.md`#Signposts-2026-04-19] — "Story 1.2 SHIPPED"; "shared-config composability for Story 1.3 preserved — append `no-restricted-imports` as a 7th entry, no rewrite"; the commitlint + prettier + PR-metadata landmine lessons.
- [Source: ESLint docs `no-restricted-imports` — <https://eslint.org/docs/latest/rules/no-restricted-imports>] — `patterns` + `group` + `message` option shape.
- [Source: ESLint flat config docs — <https://eslint.org/docs/latest/use/configure/configuration-files>] — rule-merge last-wins semantics.

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (via Ralph build loop — one task per iteration).

### Debug Log References

**Task 3 (2026-04-19) — ATDD smoke probes captured after Task 1 pattern broadening.**

Initial probe run revealed AC 1 pattern gap: the spec's `'**/packages/*/src/**'` group requires the literal string "packages" in the import specifier, but the realistic relative form `'../../contracts/src/index.ts'` (2-up from `packages/audit/src/`) has no such segment — AC 1 did NOT fire. Per Task 3 directive "If ANY probe produces unexpected output, fix the rule (loop back to Task 1)", broadened the AC 1 `group` in BOTH the 7th entry and `forPackage`'s 8th entry to add six depth-prefixed patterns: `../../**/src`, `../../**/src/**`, `../../../**/src`, `../../../**/src/**`, `../../../../**/src`, `../../../../**/src/**`. These catch 2-up / 3-up / 4-up relative specifiers reaching any `src/` segment while not touching intra-package `./foo` or test-adjacent `../src/foo` (1-up) — minimum 2-up guards cross-boundary intent. Kept the original `**/packages/*/src/**` + `**/apps/*/src/**` patterns as defense-in-depth for absolute-ish forms (rare but harmless).

Probe evidence (all captured post-fix):

**AC 1** — `packages/audit/` cwd, stdin `import foo from '../../contracts/src/index.ts';`, stdin-filename `src/ac1-probe.ts`:
```
error  '../../contracts/src/index.ts' import is restricted from being used by a pattern.
       No relative imports crossing a package src/ boundary. Use the @keel/<pkg> alias …  no-restricted-imports
```
Exit 1. ✓

**AC 2** — `packages/audit/` cwd, stdin `import { x } from '@keel/contracts/internal/foo';`:
```
error  '@keel/contracts/internal/foo' import is restricted from being used by a pattern.
       @keel/<pkg>/internal/* is forbidden across packages. Public surface is src/index.ts only …  no-restricted-imports
```
Exit 1. ✓

**AC 3** — `packages/audit/` cwd, stdin `import { x } from '@keel/audit';`:
```
error  '@keel/audit' import is restricted from being used by a pattern.
       Self-import: use a relative path within the same package ('audit'), not the @keel/audit alias  no-restricted-imports
```
Exit 1, message contains literal `'audit'`. ✓

**AC 3 (apps/web self-import)** — `apps/web/` cwd, stdin `import { x } from '@keel/web';`:
```
error  '@keel/web' import is restricted from being used by a pattern.
       Self-import: use a relative path within the same package ('web'), not the @keel/web alias  no-restricted-imports
```
Exit 1, message contains literal `'web'`. ✓

**Negative (allowed cross-package alias)** — `packages/audit/` cwd, stdin `import '@keel/contracts';` (side-effect-only form to avoid `@typescript-eslint/no-unused-vars` noise that triggered on named-import variants). Exit 0. No `no-restricted-imports` errors. ✓

No probe fixtures committed; every probe produced via shell heredoc + `eslint --stdin`. The initial red-phase evidence is preserved as "AC 1 probe pre-fix exited 1 only due to `no-unused-vars`; `no-restricted-imports` did NOT fire" — this is the gap that drove the pattern broadening.

**Quality gates post-Task-3:**
- `pnpm -w lint` → 16/16 successful, 0 cached, 6.955s cold (cache invalidated by the config-file edit).
- `pnpm -w typecheck` → 16/16 successful, 0 cached, 1.488s cold.
- `pnpm format:check` → `All matched files use Prettier code style!` exit 0.
- `pnpm exec commitlint --from origin/main --to HEAD --verbose` → 0 problems / 0 warnings across 4 branch commits.

### Completion Notes List

_(to be populated on Task 4 completion — one line per variance from the spec, cite file + reason)_

### File List

_(to be populated on completion — enumerate every created / modified file across Tasks 1–4)_
