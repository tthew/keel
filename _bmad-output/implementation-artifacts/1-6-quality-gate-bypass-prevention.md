# Story 1.6: Quality-gate bypass prevention

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a substrate maintainer,
I want a machine check that rejects any configuration change disabling or circumventing the prek quality gates,
so that a one-line config edit cannot turn off substrate teeth (FR32).

## Acceptance Criteria

1. **Given** the prek config at repo root (`.pre-commit-config.yaml`, Story 1.4) and the `keel-invariants` package (Story 1.2),
   **When** a PR removes or disables any pre-commit or commit-msg hook entry,
   **Then** the pre-merge invariant-sync-gate (Story 1.9) detects the drift and fails pre-merge,
   **And** the PR cannot be merged without a source-level fork (explicit `keel-invariants` package change with matching `invariants.manifest.ts` update).
   **Story 1.6 scope carve-out:** AC 1 is architecturally satisfied by Story 1.6's manifest-entry contract declaration + Story 1.9's runtime sync-gate. Story 1.6 itself does NOT deliver the sync-gate (Story 1.9's scope) or the manifest exporter (Story 1.8's scope). Story 1.6 ships the lint-rule piece (AC 2) + a documented forward-reference for the manifest entries AC 1 and AC 3 + AC 4 require. Full end-to-end verification lands when Stories 1.8 + 1.9 ship. See Project Structure Notes § Scope Carve-Out.

2. **Given** a PR introduces `--no-verify` (or another hook-bypass token like `--dangerously-skip-permissions`) as a string literal in any committed JS/TS/JSX source file,
   **When** the Story 1.4 pre-commit `lint` hook runs against the staged diff (workspace `pnpm -w lint` via prek),
   **Then** the ESLint rule `keel-invariants/no-verify-bypass` flags the literal and the `lint` step exits non-zero with the exact rule-id + `'git commit --no-verify' is forbidden in committed scripts` message,
   **And** `git commit` aborts without landing.

3. **Given** a PR modifies `.husky/`, `.prek/`, or hook-installation directories to point away from the shared `packages/keel-invariants/` configs,
   **When** pre-merge runs,
   **Then** the deviation is detected via the `invariants.manifest.ts` content-hash check (Story 1.8 contract; Story 1.9 runtime),
   **And** the PR is rejected with a drift-report message naming the removed/edited invariant ID.
   **Story 1.6 scope carve-out:** same deferral as AC 1.

4. **Given** Tthew explicitly forks a substrate invariant,
   **When** they change the `packages/keel-invariants/` source AND update `invariants.manifest.ts` (Story 1.8) AND update the corresponding `INVARIANTS.md` anchor (Story 1.7) together in the same PR,
   **Then** the sync gate passes — this is the intended "source-level fork" path (PRD FR32; architecture.md § Pattern-violation handling "Forks that disagree with a pattern fork `packages/keel-invariants/` (source-layer change, not config toggle)").
   **Story 1.6 scope carve-out:** same deferral as AC 1.

5. **Given** the ESLint rule `keel-invariants/no-verify-bypass` is registered in the shared config (`packages/keel-invariants/eslint.config.keel-invariants.js`) and exported under the `keel-invariants` plugin namespace,
   **When** `pnpm exec prek run --all-files lint` is invoked manually,
   **Then** the lint step exits 0 on the committed clean tree (no bypass strings present) — parity with the git-hook path confirmed (same ESLint invocation, same config, same outcomes),
   **And** the full quality-gate set (`pnpm -w typecheck` + `pnpm -w lint` + `pnpm format:check` + `pnpm exec commitlint --from origin/main --to HEAD`) remains green across the branch at Task 3.

## Tasks / Subtasks

- [x] **Task 1: Author `keel-invariants/no-verify-bypass` ESLint rule + register in shared config** (AC: 2, 5)
  - [ ] Create `packages/keel-invariants/src/eslint-rules/no-verify-bypass.js` (ESM `.js`, matching the project's established module format — variance from architecture.md line 908 which envisioned `.cjs`; the rest of `keel-invariants` is ESM, so `.js` keeps the package uniform). Rule shape:
    ```js
    // Flags hook-bypass tokens (e.g. --no-verify, --dangerously-skip-permissions)
    // appearing as string literals or template-literal quasis in committed JS/TS.
    // Complements the Story 1.9 sync-gate which detects hook-dir tampering at pre-merge.
    const BYPASS_PATTERNS = [
      { pattern: /(?<![\w-])--no-verify(?![\w-])/, name: '--no-verify' },
      {
        pattern: /(?<![\w-])--dangerously-skip-permissions(?![\w-])/,
        name: '--dangerously-skip-permissions',
      },
    ];

    const rule = {
      meta: {
        type: 'problem',
        docs: {
          description:
            'Disallow hook-bypass tokens in committed scripts (FR32; Story 1.6).',
          recommended: true,
        },
        schema: [],
        messages: {
          bypass:
            "'{{token}}' is a hook-bypass token and is forbidden in committed scripts (FR32; Story 1.6). If you need to fork the substrate, change packages/keel-invariants/ at source and update invariants.manifest.ts + INVARIANTS.md together.",
        },
      },
      create(context) {
        function check(node, value) {
          if (typeof value !== 'string') return;
          for (const { pattern, name } of BYPASS_PATTERNS) {
            if (pattern.test(value)) {
              context.report({ node, messageId: 'bypass', data: { token: name } });
              return;
            }
          }
        }
        return {
          Literal(node) {
            check(node, node.value);
          },
          TemplateElement(node) {
            check(node, node.value && node.value.cooked);
          },
        };
      },
    };

    export default rule;
    ```
    **Why the lookbehind / lookahead `(?<![\w-])…(?![\w-])`?** To avoid false positives on substrings like `--no-verify-ssl` (an openssl flag, not a git flag) or `no-verify` as part of a longer identifier. The boundary excludes alphanumerics + hyphens, so the token must stand alone. Modern V8 (Node 20) supports lookbehind natively — no Babel required. [Source: ECMAScript 2018 RegExp features.]
    **Why `TemplateElement` not `TemplateLiteral`?** Template-literal quasi nodes (`TemplateElement`) hold the string segments between `${}` substitutions; visiting the parent `TemplateLiteral` gives you the whole thing but its `.value` isn't what ESLint's AST models. Visiting each `TemplateElement.value.cooked` catches static bypass strings inside templates like `` exec(`git commit --no-verify`) ``. [Source: ESTree spec § TemplateElement.]
    **Why `type: 'problem'` not `'suggestion'`?** Bypass tokens represent a correctness-level invariant violation (substrate teeth disabled), not a style preference. `'problem'` signals to ESLint consumers that this is non-negotiable. [Source: ESLint rule meta docs.]
  - [ ] Create `packages/keel-invariants/src/eslint-rules/index.js` — ESM plugin aggregator:
    ```js
    import noVerifyBypass from './no-verify-bypass.js';

    export const keelInvariants = {
      meta: { name: 'keel-invariants', version: '0.0.0' },
      rules: {
        'no-verify-bypass': noVerifyBypass,
      },
    };

    export default keelInvariants;
    ```
    **Why a plugin aggregator?** ESLint flat config's `plugins:` key expects a `{ rules: {...} }` object keyed by plugin name. Packaging the rule behind a single plugin object (a) matches ESLint 9's canonical shape, (b) scales to multiple rules without restructuring imports later, and (c) namespaces rule IDs as `keel-invariants/<rule-id>` (no collisions with third-party plugins). [Source: ESLint Flat Config § Configuring Plugins.]
  - [ ] Edit `packages/keel-invariants/eslint.config.keel-invariants.js`. Three changes:
    1. At the top, alongside existing imports, add:
       ```js
       import { keelInvariants } from './src/eslint-rules/index.js';
       ```
    2. Inside `sharedBase`, append a new config block after the existing `no-restricted-imports` block and BEFORE the closing `]`:
       ```js
       {
         files: ['**/*.{ts,tsx,js,jsx,mjs,cjs}'],
         plugins: { 'keel-invariants': keelInvariants },
         rules: {
           'keel-invariants/no-verify-bypass': 'error',
         },
       },
       {
         // Self-exclusion: the rule's own definition and test fixtures
         // must be allowed to contain the bypass-token string literally.
         // Use files-scoped rule override rather than a blanket `ignores:`
         // to keep other lint rules (no-restricted-imports, tseslint, etc.)
         // active on the rule source.
         files: [
           'packages/keel-invariants/src/eslint-rules/**',
           'packages/keel-invariants/test/**',
         ],
         rules: {
           'keel-invariants/no-verify-bypass': 'off',
         },
       },
       ```
    3. Apply the identical two blocks inside the `forPackage(ownName)` return array (after its `no-restricted-imports` override and before the closing `]`). The per-package override chain already duplicates `sharedBase`; matching the registration in both code paths ensures the rule fires regardless of whether a package consumes `sharedBase` directly or via `forPackage()`.
    **Why register in BOTH `sharedBase` and `forPackage()`?** Story 1.3 Task 2 migrated every per-package `eslint.config.js` to call `forPackage('<name>')`. `forPackage` returns `[...sharedBase, <override>]` — the spread copies the array contents, so the new rule-registration block IS carried along automatically if placed in `sharedBase`. But: `forPackage`'s own override block re-declares `rules:`, which in flat-config merges rather than replaces (when the later block doesn't specify the rule at all, the earlier registration stands). Registering in both paths is defense-in-depth against future refactors that might change `forPackage` to omit rules already set in `sharedBase`. Zero runtime cost — ESLint de-duplicates.
  - [ ] Export the plugin as a subpath from `@keel/keel-invariants` so consumers outside this package (e.g. downstream forks) can register the rule without a deep relative import. Edit `packages/keel-invariants/package.json` `exports`:
    ```json
    "./eslint-plugin": "./src/eslint-rules/index.js"
    ```
    Place AFTER the existing `./commitlint` export. **Why expose under a subpath?** Architecture.md §559–563 pins "Only `src/index.ts` exports anything from a package." `eslint-rules/index.js` is declared as a separate export explicitly for ESLint plugin consumers — the flat-config pattern expects to import the plugin object by name. Subpath-exporting is the narrow-window way to surface this without polluting `src/index.ts`. [Source: architecture.md § Public surface enforcement; `package.json` exports in Story 1.2 Task 5.]
  - [ ] **Self-verification probe (dev loop, not committed):**
    ```bash
    # Probe 1: rule flags a string literal containing --no-verify.
    cat > /tmp/s16-probe-bad.ts <<'EOF'
    export const cmd = 'git commit --no-verify -m "bypass"';
    EOF
    pnpm exec eslint --stdin --stdin-filename=packages/audit/src/probe.ts < /tmp/s16-probe-bad.ts
    echo "exit=$?"   # expect non-zero; output contains `keel-invariants/no-verify-bypass`.

    # Probe 2: rule ignores the same token inside a comment.
    cat > /tmp/s16-probe-comment.ts <<'EOF'
    // The flag --no-verify is forbidden in committed scripts.
    export const ok = true;
    EOF
    pnpm exec eslint --stdin --stdin-filename=packages/audit/src/probe.ts < /tmp/s16-probe-comment.ts
    echo "exit=$?"   # expect 0; comments are not `Literal` nodes.

    # Probe 3: rule allows a non-bypass substring (--no-verify-ssl).
    cat > /tmp/s16-probe-boundary.ts <<'EOF'
    export const openssl = 'openssl --no-verify-ssl connect example.com:443';
    EOF
    pnpm exec eslint --stdin --stdin-filename=packages/audit/src/probe.ts < /tmp/s16-probe-boundary.ts
    echo "exit=$?"   # expect 0; lookbehind/lookahead boundary excludes `-ssl` suffix.
    ```
    If any probe misbehaves, fix the rule regex or AST visitor BEFORE Task 2. Do NOT commit probe fixtures.
  - [ ] Quality gates:
    - `pnpm -w typecheck` — expect FULL TURBO 16/16. The change touches only `.js` files in `keel-invariants` (not TS), `eslint.config.keel-invariants.js`, and `package.json` exports. None of these are `tsc` inputs, so the TS build graph's cache survives. **Contrast with Story 1.4 Task 1** where a new devDep invalidated the cache; Story 1.6 Task 1 adds no devDeps, only new source files in a non-TS tree.
    - `pnpm -w lint` — the lint step now includes the new rule across the whole workspace. Expect exit 0 (clean tree contains no bypass strings). NOT FULL TURBO: adding a rule is a lint-config change, which invalidates every package's lint cache. One-time cold run.
    - `pnpm format:check` — exit 0. Prettier formats JS files per the shared config; Prettier 3.8.3's defaults handle the new files with no manual intervention required.
    - `pnpm exec commitlint --from origin/main --to HEAD --verbose` — 0/0 across existing branch commits (spec commit only at this point).
  - [ ] Commit: `feat(invariants): Story 1.6 Task 1 — add keel-invariants/no-verify-bypass ESLint rule`. Include IP + RALPH.md upkeep in the same commit per step 3a of the build prompt.

- [x] **Task 2: ATDD probes — valid code passes (AC 5), bypass-string code rejects (AC 2), prek-runner parity (AC 5)** (AC: 2, 5)
  - [ ] Each probe stages a trivial file, attempts `git commit`, observes outcome, cleans up. Every probe's tree state matches the Task-1 tip before AND after. The probes exercise the real git-hook path (not `prek run`) so evidence covers git → `.git/hooks/pre-commit` → prek → ESLint end-to-end.
  - [ ] **AC 2 probe — bypass-string in TS source aborts commit.**
    ```bash
    # Write a TS file with --no-verify in a string literal inside a package
    # the workspace lints (packages/audit is a good target — Story 1.4 used it).
    cat > packages/audit/src/__s16-ac2-probe.ts <<'EOF'
    // Story 1.6 Task 2 AC 2 probe — delete on cleanup.
    export const cmd = 'git commit --no-verify -m "intentional-bypass"';
    EOF
    git add packages/audit/src/__s16-ac2-probe.ts
    git commit -m 'probe: AC 2 no-verify-bypass' 2>&1 | tee /tmp/s16-ac2.out
    echo "exit=${PIPESTATUS[0]}"   # expect non-zero (git, not tee)
    git log -1 --oneline           # expect unchanged (still at Task-1 tip)
    # Clean up staged probe file (commit didn't land).
    git reset HEAD packages/audit/src/__s16-ac2-probe.ts
    rm -f packages/audit/src/__s16-ac2-probe.ts
    ```
    Expect: `git commit` exits 1; `/tmp/s16-ac2.out` shows `typecheck` Passed, `lint` Failed with `keel-invariants/no-verify-bypass` rule-id + the exact `'--no-verify' is a hook-bypass token and is forbidden in committed scripts` message; `format-check` Passed; commit-msg stage not reached (pre-commit already failed). No commit on branch.
  - [ ] **AC 2 follow-up probe — template literal with bypass token also aborts.**
    ```bash
    cat > packages/audit/src/__s16-ac2b-probe.ts <<'EOF'
    // Story 1.6 Task 2 AC 2b probe — template-literal variant.
    const flag = 'no-verify';
    export const cmd = `git commit --${flag}`;   // NOT flagged (dynamic)
    export const cmd2 = `git commit --no-verify`;  // FLAGGED (static)
    EOF
    git add packages/audit/src/__s16-ac2b-probe.ts
    git commit -m 'probe: AC 2b template-literal bypass' 2>&1 | tee /tmp/s16-ac2b.out
    echo "exit=${PIPESTATUS[0]}"   # expect non-zero
    git reset HEAD packages/audit/src/__s16-ac2b-probe.ts
    rm -f packages/audit/src/__s16-ac2b-probe.ts
    ```
    Expect: lint hook fires on `cmd2` (static `--no-verify` in a template quasi); lint does NOT fire on `cmd` (the literal substring after `--` is assembled dynamically, AST visitor can't see the concatenated value — documented rule limitation). The single violation is enough to abort the commit.
  - [ ] **Negative probe — bypass token inside a comment does NOT abort.**
    ```bash
    cat > packages/audit/src/__s16-neg-probe.ts <<'EOF'
    // Story 1.6 negative probe — --no-verify in a comment is intentional
    // (e.g. explaining why a bypass is forbidden) and must not flag.
    export const ok = true;
    EOF
    git add packages/audit/src/__s16-neg-probe.ts
    git commit -m 'chore: AC 2 negative probe — comment allowed' 2>&1 | tee /tmp/s16-neg.out
    echo "exit=${PIPESTATUS[0]}"   # expect 0 (commit lands)
    # Roll back — we don't want this commit on the branch either.
    git reset --hard HEAD~1
    [ ! -f packages/audit/src/__s16-neg-probe.ts ] && echo 'neg probe clean'
    ```
    Expect: all 3 pre-commit hook steps Passed; commit-msg hook Passed (`chore:` is a valid conventional-commit type); commit lands on branch; `git reset --hard HEAD~1` rolls back tip + file.
  - [ ] **AC 5 probe — prek-runner parity confirms same rule fires via direct prek invocation.**
    ```bash
    # Recreate the AC 2 probe file, BUT stage it so prek can see it.
    cat > packages/audit/src/__s16-ac5-probe.ts <<'EOF'
    export const cmd = 'git commit --no-verify -m probe';
    EOF
    git add packages/audit/src/__s16-ac5-probe.ts
    pnpm exec prek run --all-files lint 2>&1 | tee /tmp/s16-ac5.out
    echo "lint-exit=${PIPESTATUS[0]}"   # expect non-zero
    git reset HEAD packages/audit/src/__s16-ac5-probe.ts
    rm -f packages/audit/src/__s16-ac5-probe.ts

    # Also exercise the clean-tree lint parity (after probe cleanup).
    pnpm exec prek run --all-files lint 2>&1 | tee /tmp/s16-ac5-clean.out
    echo "lint-exit-clean=${PIPESTATUS[0]}"   # expect 0
    ```
    Expect: dirty-tree `prek run --all-files lint` exits non-zero with the `keel-invariants/no-verify-bypass` rule-id + message. Clean-tree re-run exits 0 — proving parity with the git-hook path (same `pnpm -w lint` entrypoint, same ESLint invocation, same outcomes).
  - [ ] Capture each probe's output in Debug Log References. If the AC 2 probe unexpectedly succeeds, **loop back to Task 1** — either the rule isn't registered (check `eslint.config.keel-invariants.js` imports) or the `files:` pattern excludes `packages/audit/src/**` (check the glob). Document any loop-back in Completion Notes List.
  - [ ] Post-probe tree check: `git status` clean; `git log --oneline origin/main..HEAD` unchanged from pre-probe count; `ls packages/audit/src/__s16-*-probe.ts 2>/dev/null` empty.
  - [ ] Quality gates (defensive re-run after probe cleanup):
    - `pnpm -w typecheck` — FULL TURBO (no TS inputs touched).
    - `pnpm -w lint` — expect FULL TURBO on this second invocation (Task 1's cold-lint-run warmed the cache; Task 2's probes never landed as commits, so the committed TS source is unchanged from Task 1 tip).
    - `pnpm format:check` — exit 0.
    - `pnpm exec commitlint --from origin/main --to HEAD` — 0/0 across all branch commits (spec + iter-1 bookkeeping + Task 1 = 3 commits).
  - [ ] Commit: `feat(invariants): Story 1.6 Task 2 — ATDD probes verify no-verify-bypass fires + negative cases pass`.

- [x] **Task 3: Full quality-gate verification + sprint-status bump** (AC: 5)
  - [x] `pnpm install` — expect `Lockfile is up to date`; `prepare` re-runs `prek install -t pre-commit -t commit-msg` idempotently (both shims already in place from Stories 1.4/1.5).
  - [x] `pnpm -w typecheck` — expect 16/16 `>>> FULL TURBO` on FIRST call (no TS inputs moved across Tasks 1/2).
  - [x] `pnpm -w lint` — expect 16/16 `>>> FULL TURBO` on FIRST call (Task 1's rule-registration triggered a single cold run; Task 2 didn't touch lint inputs; the committed tree's lint cache is warm end-to-end).
  - [x] `pnpm format:check` — `All matched files use Prettier code style!` exit 0.
  - [x] `pnpm exec commitlint --from origin/main --to HEAD --verbose` — 0 problems / 0 warnings across all branch commits (spec + iter-1 bookkeeping + Task 1 + Task 2; all `feat(invariants):` / `chore(ralph):` / `docs(story):` conventional form). **Actual:** 0 problems across all 4 commits; 1 warning (`footer-leading-blank`) on the iter-1 bookkeeping commit `a4b3be2` — commitlint exits 0 on warnings, pre-push gate passes; documentary variance.
  - [x] `pnpm exec prek run --all-files` — all 3 pre-commit-stage hooks Passed (TypeScript type-check / ESLint / Prettier format:check). Commit-msg stage parity already proven in Task 1's self-verification + Task 2's probes.
  - [x] Update `_bmad-output/implementation-artifacts/sprint-status.yaml`: flip `1-6-quality-gate-bypass-prevention: ready-for-dev → done`; bump `last_updated`. Co-land in this commit per Stories 1.2/1.3/1.4/1.5 orphan-prevention precedent.
  - [x] Commit: `feat(invariants): Story 1.6 Task 3 — all quality gates green + sprint-status bump`.

## Dev Notes

### Relevant architecture patterns and constraints

**Bypass prevention is one layer in a three-layer defense.** The full FR32 defense composes three concerns: (1) source-script lint rule catches bypass tokens in committed JS/TS (this story's scope), (2) invariant-sync-gate detects hook-dir tampering at pre-merge (Stories 1.8 + 1.9's scope), (3) hook self-protection denies runtime Edit/Write against `.claude/hooks/**` / `.git/hooks/**` (NFR5b; Epic 2 Story 2.16/2.17's scope). Story 1.6 delivers layer 1 only. Layers 2 and 3 are called out in each AC's scope carve-out. [Source: prd.md:958 FR32; prd.md:1038 NFR5b; architecture.md:697 "source-layer change, not config toggle".]

**ESLint custom rules live in `packages/keel-invariants/src/eslint-rules/`.** This follows the architecture.md:908 pattern (existing precedent is `stable-test-id.cjs`, though that rule has not yet shipped as of Story 1.5). Story 1.6 is the FIRST ESLint custom rule authored in this repo. Variance from architecture.md:908: rule file is `.js` (ESM), not `.cjs` — the rest of `keel-invariants` is ESM, and the shared `eslint.config.keel-invariants.js` uses `import/export` natively. Keeping the rule in the same module format avoids an ESM/CJS interop wrinkle at import time. [Source: packages/keel-invariants/package.json `"type": "module"` equivalent implicit via `"main": "./dist/index.js"` + ESM config files; architecture.md:908 documents `.cjs` as the envisioned file extension but not as a hard requirement.]

**Plugin shape uses `meta: { name, version }`.** ESLint 9's flat config plugins declare a `meta` object so ESLint can surface plugin identity in diagnostics. The plugin version is `0.0.0` here (matches `packages/keel-invariants/package.json` version) — harmless, and easy to bump when the invariant set evolves. [Source: ESLint Flat Config Plugins docs; `@typescript-eslint/eslint-plugin` precedent.]

**Rule scope is `Literal` + `TemplateElement` nodes.** The rule visits string-literal AST nodes and template-literal quasi nodes. It does NOT visit `CallExpression`, `Identifier`, `JSXAttribute`, etc. — we don't want to flag a variable named `noVerify` (which might be a flag-wiring helper, perfectly legitimate) or a JSX prop `<Component noVerify />` (domain-specific, not a bypass). The rule's job is: if the literal STRING form of `--no-verify` appears in source, it's almost certainly a shell command being assembled. Comment nodes are outside the ESLint AST visitor's path by default — comments are their own token class. [Source: ESLint ESTree spec § Literal + TemplateElement; ESLint AST selectors docs.]

**Word-boundary regex prevents false positives on hyphenated suffixes.** `--no-verify-ssl` is an openssl flag (legitimate); `--no-verifyall` would be some unrelated hypothetical flag. The `(?<![\w-])…(?![\w-])` boundary requires the token to end at a word-boundary OR at a non-hyphen character. Modern V8 (Node 20) supports lookbehind without flags. [Source: MDN RegExp § Lookbehind; Node 20 V8 RegExp support.]

### Source tree components to touch

**Added (Task 1):**
- `packages/keel-invariants/src/eslint-rules/no-verify-bypass.js` — the rule itself (~40 LoC ESM).
- `packages/keel-invariants/src/eslint-rules/index.js` — plugin aggregator (~10 LoC ESM).

**Modified (Task 1):**
- `packages/keel-invariants/eslint.config.keel-invariants.js` — add import, add 2 new config blocks in `sharedBase`, add matching 2 blocks in `forPackage()`'s return array.
- `packages/keel-invariants/package.json` — add `./eslint-plugin` subpath to `exports` (one new key-value line).

**Created by `prek install` (NOT committed — `.git/` is not tracked):**
- No new hook shims. Stories 1.4 + 1.5 already installed `.git/hooks/pre-commit` + `.git/hooks/commit-msg`. Task 1's `pnpm install` re-runs `prek install` idempotently; no new files land.

**Modified (Task 3):**
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — flip `1-6-quality-gate-bypass-prevention: ready-for-dev → done`; bump `last_updated`.

**Unchanged across the story:** every per-package `eslint.config.js` (Story 1.3 authored `forPackage()` call; no file-level change required because registering the rule in `sharedBase` + `forPackage()` cascades automatically); every `tsconfig.json`; every `src/*.ts` file outside the new `eslint-rules/` directory; `turbo.json`; `pnpm-workspace.yaml`; `.pre-commit-config.yaml` (Story 1.4 + 1.5 composition is unchanged — this story adds NO new hook; it extends an existing one); `commitlint.config.keel-invariants.js`; `prettier.config.keel-invariants.js`; root `eslint.config.js` / `prettier.config.js` / `commitlint.config.js` shims.

### Testing standards summary

**No unit / integration `.test.ts` files land in Story 1.6.** Consistent with Stories 1.2/1.3/1.4/1.5 — the test surface IS the quality gates themselves, plus ATDD probes firing real `git commit` against valid/invalid fixtures. Verification evidence lands in Debug Log References. A dedicated `RuleTester`-based Vitest test would require adding Vitest as a devDep to `keel-invariants` and wiring a `test` script — deferred to a future tooling-consolidation story (likely Epic 3 or a joint Story-1.8/1.9 test-harness task).

**ATDD red phase is implicit in Task 1's self-verification.** BEFORE the rule is registered in `eslint.config.keel-invariants.js` (Task 1 not yet committed), `pnpm -w lint` on a file containing `'git commit --no-verify'` passes — no rule → no gate. After Task 1, the same file fails lint. The red→green transition is the proof. Task 2 exercises this deliberately via AC 2 probes.

**Budget expectations.** The rule performs `RegExp.test` against string-literal AST node values — O(n) over string literals in the staged diff, constant per-literal. On a clean tree, it adds <10ms to `pnpm -w lint` (16 packages, FULL TURBO baseline). On a dirty tree where the rule fires, ESLint's early-exit on first match minimises overhead. Well within the pre-commit ≤10s budget (architecture.md §77; PRD NFR1).

### Project Structure Notes

**Alignment with unified project structure:**
- ✅ Rule source lives at `packages/keel-invariants/src/eslint-rules/` — matches architecture.md:908's envisioned path.
- ✅ Plugin aggregator exported via subpath `@keel/keel-invariants/eslint-plugin` — consistent with Story 1.2's subpath-export pattern for `./eslint`, `./prettier`, `./commitlint`.
- ✅ Rule IDs namespaced as `keel-invariants/<rule-id>` — no collision with third-party plugins.
- ✅ Self-exclusion via file-scoped rule override — keeps other rules active on the rule source (tseslint's recommended rules, `no-restricted-imports`).

**Detected conflicts or variances:**
- **Variance — rule file extension is `.js` (ESM), not `.cjs`.** Architecture.md:908 envisioned `.cjs` (CommonJS). The rest of `keel-invariants` is ESM (package.json `"main": "./dist/index.js"`; shared config uses `import`/`export`). Using `.cjs` for the rule alone would require a special ESM↔CJS interop dance in the shared config. `.js` ESM keeps the package uniform. No runtime cost — ESLint 9 supports both.
- **Variance — self-exclusion via `rules: { 'keel-invariants/no-verify-bypass': 'off' }` on the rule's own paths, not a blanket `ignores:` block.** A blanket `ignores:` would disable ALL lint on the rule's own files — losing tseslint and `no-restricted-imports` coverage on `eslint-rules/*`. The file-scoped rule override preserves every other rule while allowing the bypass-token literal to exist in the rule's own definition and tests.
- **Scope Carve-Out — AC 1, AC 3, AC 4 forward-reference Stories 1.8 + 1.9.** Story 1.6 delivers the lint-rule piece (AC 2) in full. AC 1 requires the sync-gate detection of hook removal — but the sync-gate is Story 1.9's deliverable, and the manifest it reads is Story 1.8's. AC 3 likewise requires the manifest-driven detection of hook-dir tampering. AC 4 requires the three-file "source-level fork" ceremony (source + `invariants.manifest.ts` + `INVARIANTS.md`), but `invariants.manifest.ts` doesn't exist yet (Story 1.8) and `INVARIANTS.md` doesn't exist yet (Story 1.7). Full end-to-end verification of AC 1/3/4 lands when Stories 1.7/1.8/1.9 ship. The story-spec author acknowledges this sequencing: Stories 1.6–1.9 are a jointly-delivered invariants-substrate quartet, and Story 1.6 makes sense as a standalone checkpoint because AC 2 (the lint rule) IS a concrete piece of FR32 that can be independently tested today. Noted for dev-story: do NOT attempt to implement the manifest or sync-gate within this story's iteration — that's story-creep. [Source: epics.md:859–923 Stories 1.8 + 1.9 own the manifest and sync-gate.]
- **Scope Carve-Out — shell/YAML/JSON bypass-string coverage deferred.** The ESLint rule covers JS/TS/JSX/MJS/CJS. Shell scripts, YAML CI configs, and JSON/TOML files are not in ESLint's path. Architecture.md:679 names a separate "prompt-injection regex (S4)" as a pre-commit gate — that gate is the right home for non-JS bypass-string coverage. Story 1.6 does NOT extend to that scope. Document as a known limitation in the rule's docstring. [Source: architecture.md:679 pre-commit tier composition; FR40 prompt-injection scan for agent-context-loader files.]
- **Variance — `--dangerously-skip-permissions` is covered by the same rule, not a separate rule.** Architecture.md:221 mentions a `packages/keel-invariants/src/prompt-injection-rules/diff-patterns.ts` rule that detects `--dangerously-skip-permissions` outside `packages/devbox`. That rule does NOT yet exist. Story 1.6 piggy-backs on the `no-verify-bypass` rule's `BYPASS_PATTERNS` array to also catch `--dangerously-skip-permissions` because (a) the detection logic is identical, (b) the rule's message already names both tokens, (c) the `diff-patterns.ts` rule is a future story's deliverable with a broader prompt-injection scope. If that future story redesigns `--dangerously-skip-permissions` detection (e.g. with a `packages/devbox` exception), the Story 1.6 rule should be updated then. Noted.
- **Variance — self-exclusion path includes `packages/keel-invariants/test/` even though the directory does not yet exist.** Declaring the exclusion ahead of time is cheap and correct — ESLint tolerates missing files in `files:` globs (the block's `files:` pattern simply matches zero files today). When Story 1.8 or a later story introduces `packages/keel-invariants/test/` for rule-regression tests, the exclusion is already in place.

### Previous Story Intelligence (from Stories 1.2–1.5)

**Files / patterns Story 1.6 builds on:**
- `packages/keel-invariants/eslint.config.keel-invariants.js` (Story 1.2 Task 5; Story 1.3 Task 1 extended with `no-restricted-imports` + `forPackage()` factory) — Story 1.6 appends new config blocks in both `sharedBase` and `forPackage()`. No restructure.
- `packages/keel-invariants/package.json` `exports` (Story 1.2 Task 5) — Story 1.6 adds one new subpath (`./eslint-plugin`). Existing exports unchanged.
- `packages/audit/` (Story 1.1) — used as the ATDD probe target (same as Story 1.4 Task 2's AC 2/3/4 probes). No change to the package itself.
- `.pre-commit-config.yaml` (Story 1.4 + 1.5 composition of 4 hooks) — unchanged. The `lint` hook at line 16 invokes `pnpm -w lint` which now includes the new rule via ESLint's automatic rule-discovery through the shared config.
- `.git/hooks/pre-commit` + `.git/hooks/commit-msg` shims — Story 1.5 installed both via `prek install -t pre-commit -t commit-msg`. Story 1.6 does not reinstall; the existing shims run the new rule transparently (they invoke `prek run` against the config, which runs `pnpm -w lint`, which picks up the new rule from the shared config — chain verified at Task 1's self-verification).

**Landmines Stories 1.2–1.5 hit (RALPH.md Lessons 2026-04-19) that could recur:**
- **Turbo cache sensitivity to lint-config edits.** Adding a new ESLint rule to the shared config IS a lint-input change. Story 1.6 Task 1 WILL invalidate the lint cache on first run — expect NOT-FULL-TURBO on Task 1's quality-gate `pnpm -w lint`. Task 2's second invocation and Task 3's verification-only invocation should both return to FULL TURBO (the committed tree's cache warms on first post-Task-1 run). [Source: RALPH.md Lessons 2026-04-19 "Turbo cache sensitivity to package.json edits"; adapted to eslint.config edits.]
- **Multi-commit story PRs drift PR metadata from reality.** Story 1.6 expects ~4 commits (spec + iter-1 bookkeeping + Tasks 1–3). Before `gh pr ready`, rewrite PR title/body per Stories 1.1–1.5 precedent (RALPH.md "Multi-commit story PRs drift PR metadata from reality" — 5× confirmed as load-bearing).
- **Post-halt bookkeeping orphan risk.** Land sprint-status update in Task 3's commit, not a separate post-transition `chore(sprint):` bump. Stories 1.2/1.3/1.4/1.5 all applied this pre-emptively. Story 1.6 follows suit.
- **Commitlint subject-case / header-length rules.** Story 1.2 Task 5 authored the keel commitlint config (`subject-case: [0]`, `header-max-length: 120`). `feat(invariants): Story 1.6 Task N — <summary>` fits comfortably (≤90 chars typical).
- **Pre-commit hook self-enforcement.** Since Story 1.4, every `git commit` on any branch in this repo exercises typecheck + lint + format-check. Story 1.6's own Task 1 commit will fire the new lint rule against itself — if the self-exclusion config is wrong, the rule flags its own source and the Task 1 commit fails. Task 1's self-verification probe MUST confirm the self-exclusion works BEFORE attempting `git commit`. If the probe finds the rule firing on `eslint-rules/*`, fix the self-exclusion config before committing.
- **Worktree + prek idempotence.** Story 1.4/1.5 confirmed: `pnpm install` in a worktree re-runs `prek install` idempotently; shims stay at MAIN-repo `.git/hooks/` and fire from any worktree. Story 1.6 inherits this without new handling.

**Testing approaches validated that Story 1.6 inherits:**
- `git commit` with a temp file + `git reset --hard HEAD~1` or `git reset HEAD <file> && rm -f <file>` to roll back clean (Stories 1.4/1.5 Task 2 pattern).
- `pnpm exec eslint --stdin --stdin-filename=<path>` for fast rule-verification without touching the file tree (Story 1.3 Task 3 pattern — especially useful for Task 1's self-verification because it bypasses the staging area).
- `${PIPESTATUS[0]}` for capturing `git commit`'s exit through a `tee` pipe (Story 1.5 Completion Notes observation — the vanilla `$?` after a pipe reports `tee`'s success, not git's).
- Probe paths under `packages/audit/src/` (Story 1.4 Task 2 AC 3 precedent) — ensures the probe files are in ESLint's scope. Alternative `_bmad-output/*.txt` paths (Story 1.5 probes) are ignored by ESLint, so they DON'T work for lint-rule probes — use TypeScript paths.

### Git Intelligence Summary (recent patterns)

Last commits on `feat/story-1-5-conventional-commit-enforcement-via-commitlint-prek` (merged via PR #221 as commit `297402c`):
- `774d4ba chore(ralph): Story 1.5 halt path-correction — signal ralph.py from main repo`
- `edbb176 chore(ralph): Story 1.5 AWAIT_MERGE marker — defensive halt reinforcement`
- `818be97 chore(ralph): Story 1.5 Draft→Open bookkeeping — IP + RALPH.md`
- `f821df0 feat(invariants): Story 1.5 Task 3 — all quality gates green + sprint-status bump`
- `6e0a6af feat(invariants): Story 1.5 Task 2 — ATDD probes verify commit-msg hook fires + rejects non-conventional messages`
- `0092d2b feat(invariants): Story 1.5 Task 1 — wire commit-msg hook + prepare installs commit-msg shim`

Convention: `feat(invariants): Story X.Y Task N — <summary>`. Story 1.6 follows the same scope (`invariants`, since this story authors a rule INSIDE `packages/keel-invariants/`). One task per commit.

### Latest Technical Information

- **ESLint 10.2.1** — current pinned version (see `packages/keel-invariants/package.json` devDep). Supports flat config natively, includes plugin `meta` key support since 8.56+. No upgrade required. [Source: packages/keel-invariants/package.json line 26.]
- **typescript-eslint 8.58.2** — current pinned version. No direct interaction with the new rule — it lives in its own plugin namespace. [Source: packages/keel-invariants/package.json line 27.]
- **Node 20 LTS** — supported by `.nvmrc` (architecture.md:780). Lookbehind regex `(?<!...)` is natively supported by V8 on Node 18+. No polyfill needed.
- **`@j178/prek@0.3.9`** — pinned by Story 1.4; unchanged. The `prek run --all-files lint` invocation is the standard ESLint entrypoint; no new flags needed for the rule to fire.
- **No new devDeps.** Story 1.6 adds NO new packages. It uses the ESLint API surface already provided by the pinned versions. Zero lockfile churn.

### References

- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.6, lines 803–827] — Story 1.6 AC (authoritative scope; 4 ACs mirrored here with one expanded AC 5 for prek-runner parity evidence).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.7, lines 829–857] — Story 1.7 (INVARIANTS.md + AGENTS.md + CLAUDE.md + RALPH.md at repo root; scope-carve-out cross-reference).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.8, lines 859–885] — Story 1.8 (`invariants.manifest.ts` contract; scope-carve-out cross-reference).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.9, lines 887–923] — Story 1.9 (sync-gate runtime; scope-carve-out cross-reference).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.2, lines 698–719] — Story 1.2 (keel-invariants package bootstrap + `forPackage()` factory foundation).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.3, lines 721–744] — Story 1.3 (`no-restricted-imports` via `forPackage()` — precedent for shared-config rule registration).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.4, lines 746–775] — Story 1.4 (prek hooks + `.pre-commit-config.yaml` at repo root — the gates this story defends).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.5, lines 777–801] — Story 1.5 (commit-msg hook — one of the hooks this story's AC 1 tracks).
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Pre-commit-hooks, line 679] — "Pre-commit (≤10s): prek + commitlint + ESLint + TypeScript changed-files + prompt-injection regex (S4) + bare-string + ARIA lint + token-drift check." Story 1.6 extends the ESLint piece with one new rule.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Pattern-violation-handling, line 697] — "Forks that disagree with a pattern fork `packages/keel-invariants/` (source-layer change, not config toggle)." The canonical statement of the source-level fork pattern.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Eslint-rules, line 908] — envisioned `eslint-rules/*.cjs` path; Story 1.6 variances to `.js` ESM.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Invariants-package, line 886] — `packages/keel-invariants/` as the authoritative invariants home.
- [Source: `_bmad-output/planning-artifacts/prd.md`#FR32, line 958] — "System can prevent quality-gate bypass via configuration; removal requires a source-level fork."
- [Source: `_bmad-output/planning-artifacts/prd.md`#NFR5, line 1036] — `--dangerously-skip-permissions` bypass requires a source-level fork.
- [Source: `_bmad-output/planning-artifacts/prd.md`#NFR5b, line 1038] — hook self-protection (NOT this story's scope; Epic 2 Story 2.17).
- [Source: `_bmad-output/planning-artifacts/prd.md`#FR43, line 975] — sync-gate between machine-enforced layer + agent-readable layer (Stories 1.8 + 1.9).
- [Source: `_bmad-output/planning-artifacts/prd.md`#NFR27, line 1074] — fail-closed posture on all quality gates.
- [Source: `_bmad-output/planning-artifacts/prd.md`#Innovation-area-4, line 392] — "Non-toggle-able quality gates + forkability. Four-layer gates cannot be disabled via config. To remove a gate, fork."
- [Source: `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`] — Story 1.2 established shared configs + `./eslint` / `./prettier` / `./commitlint` subpath exports; Story 1.6 adds the `./eslint-plugin` subpath alongside.
- [Source: `_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`] — Story 1.3 established `forPackage('<name>')` rule-registration pattern; Story 1.6 uses it.
- [Source: `_bmad-output/implementation-artifacts/1-4-pre-commit-quality-gates-via-prek-type-check-lint-format.md`] — Story 1.4 established `.pre-commit-config.yaml` at repo root + prek install convention; Story 1.6 extends a hook it composed.
- [Source: `_bmad-output/implementation-artifacts/1-5-conventional-commit-enforcement-via-commitlint-prek.md`] — Story 1.5 established commit-msg hook + ATDD probe pattern for git-commit-level tests.
- [Source: `RALPH.md`#Signposts-2026-04-19] — Stories 1.1–1.5 landmines; all apply here.
- [Source: <https://eslint.org/docs/latest/extend/custom-rules>] — ESLint custom rule authoring reference.
- [Source: <https://eslint.org/docs/latest/use/configure/plugins>] — ESLint flat-config plugin registration.

## Dev Agent Record

### Agent Model Used

Claude Opus 4.7 (1M context) — `claude-opus-4-7[1m]`.

### Debug Log References

**Task 3 — verification-only iteration (2026-04-20):**

```
$ pnpm install
Scope: all 17 workspace projects
Lockfile is up to date, resolution step is skipped
Already up to date
. prepare$ prek install -t pre-commit -t commit-msg
. prepare: prek installed at `/workspace/ralph-bmad/.git/hooks/pre-commit`
. prepare: prek installed at `/workspace/ralph-bmad/.git/hooks/commit-msg`
. prepare: Done
Done in 754ms using pnpm v10.29.2

$ pnpm -w typecheck
…
 Tasks:    16 successful, 16 total
Cached:    16 cached, 16 total
  Time:    135ms >>> FULL TURBO

$ pnpm -w lint
…
 Tasks:    16 successful, 16 total
Cached:    16 cached, 16 total
  Time:    159ms >>> FULL TURBO

$ pnpm format:check
> prettier --check .
Checking formatting...
All matched files use Prettier code style!

$ pnpm exec commitlint --from origin/main --to HEAD --verbose
⧗   input: feat(invariants): Story 1.6 Task 2 — …
✔   found 0 problems, 0 warnings
⧗   input: feat(invariants): Story 1.6 Task 1 — …
✔   found 0 problems, 0 warnings
⧗   input: chore(ralph): Story 1.6 iteration 1 — IP reflects Draft PR #222 creation
⚠   footer must have leading blank line [footer-leading-blank]
⚠   found 0 problems, 1 warnings
⧗   input: docs(story): Story 1.6 spec — quality-gate bypass prevention (spec only — Draft)
✔   found 0 problems, 0 warnings
EXIT=0

$ pnpm exec prek run --all-files
TypeScript type-check (workspace)........................................Passed
ESLint (workspace).......................................................Passed
Prettier format:check (workspace)........................................Passed
EXIT=0
```

**Evidence interpretation.** Typecheck + lint both hit FULL TURBO on FIRST invocation as predicted (prior task's commit `44ef6c0` touched no turbo inputs — the `_bmad-output/` + `RALPH.md` + `.ralph/@plan.md` edits are under `.prettierignore` and not declared inputs for any turbo task). Format:check clean. Commitlint exits 0 on the whole branch; the single `footer-leading-blank` warning on the iter-1 commit is non-blocking (commitlint's default posture for this rule is `warn`). `prek run --all-files` re-confirms git-hook path parity end-to-end for the 3 pre-commit-stage hooks.

### Completion Notes List

**Task 3 summary.** Verification-only iteration shipped green. All ACs covered end-to-end:

- **AC 2** — proven by Task 1's self-verify probes (string literal) + Task 2's AC 2 probe (real `git commit`, `packages/audit/src/__s16-ac2-probe.ts`) + Task 2's AC 2b probe (template-literal static + dynamic quasi discrimination) + Task 2's negative probe (comment allowed).
- **AC 5** — proven by Task 2's prek-runner parity probe (`prek run --all-files lint` on dirty tree → non-zero; clean-tree re-run → exit 0) + Task 3's clean-tree `prek run --all-files` → all 3 hooks Passed + commitlint exits 0 across all 4 branch commits.
- **AC 1 / AC 3 / AC 4** — scope carve-out (Stories 1.7/1.8/1.9 ship the manifest + sync-gate + three-file ceremony this story architecturally depends on). Story 1.6 forward-references these with `**Story 1.6 scope carve-out:**` lines under each affected AC + a dedicated Project Structure Notes section. Ships in full when the invariants-substrate quartet (1.6–1.9) is complete.

**Documentary variance — commitlint `footer-leading-blank` warning on iter-1 commit.** The Task 3 spec subtask said "0 problems / 0 warnings"; actual is 0 problems / 1 warning on commit `a4b3be2` (`chore(ralph): Story 1.6 iteration 1 — IP reflects Draft PR #222 creation`). The commit's trailing `PR #222 state: {…}` line reads to commitlint as a footer-key candidate but lacks the blank-line separator above. The `footer-leading-blank` rule is set to `warn` severity in `@commitlint/config-conventional` (not configured to error in the keel override), so commitlint exits 0 and the pre-push gate passes. Not amended because:

1. Amending would rewrite the iter-1 commit's SHA and force-push the branch, cascading into PR #222's commit history.
2. The warning is informational, not blocking.
3. Future Ralph bookkeeping commits can preempt the same warning by inserting a blank line before any trailing `<key>: <value>` block. Noted in RALPH.md 2026-04-20 for carry-forward.

**Defensive posture — did NOT amend.** Never force-push `main` per AGENTS.md Git conventions; the analogous posture is to avoid rewriting shared branch history for non-blocking issues.

**Sprint-status bump co-landed.** Sixth consecutive story-implementation mini-epic (1.1 + 1.2 + 1.3 + 1.4 + 1.5 + 1.6) where the sprint-status bump lands inside the verification task's commit, BEFORE Draft→Open — preemptive-orphan-prevention precedent now load-bearing.

**FULL TURBO observation — sixth confirmation.** Verification-only iterations hit FULL TURBO on first invocation because the prior task's commit edited only `_bmad-output/` + `.ralph/` + `RALPH.md` + `.md` docs — none declared inputs for turbo's typecheck/lint tasks. Zero-cost from a cache-warming perspective.

### File List

**Modified (Task 3):**

- `_bmad-output/implementation-artifacts/sprint-status.yaml` — `1-6-quality-gate-bypass-prevention: ready-for-dev → done`; `last_updated: 2026-04-20 Task-3 UTC`.
- `_bmad-output/implementation-artifacts/1-6-quality-gate-bypass-prevention.md` — `Status: ready-for-dev → done`; Task 1/2/3 all checked `[x]`; all Task 3 subtask checkboxes `[x]`; populated `Agent Model Used` / `Debug Log References` / `Completion Notes List` / `File List`.
- `RALPH.md` — Signposts 2026-04-20 entry added for Task 3 completion (FULL TURBO evidence, 6-mini-epic confirmation, `footer-leading-blank` carry-forward).
- `.ralph/@plan.md` — NOW flipped to "Transition PR Draft→Open — final CI gate"; Task 3 added to DONE; Context updated.

**Added / Modified across Story 1.6 (spec + iter-1 + Tasks 1–3):**

- `packages/keel-invariants/src/eslint-rules/no-verify-bypass.js` (new, Task 1) — the rule.
- `packages/keel-invariants/src/eslint-rules/index.js` (new, Task 1) — plugin aggregator.
- `packages/keel-invariants/eslint.config.keel-invariants.js` (modified, Task 1) — import plugin; register rule in `sharedBase` + `forPackage()`; file-scoped self-exclusion.
- `packages/keel-invariants/package.json` (modified, Task 1) — `./eslint-plugin` subpath export.
- `_bmad-output/implementation-artifacts/1-6-quality-gate-bypass-prevention.md` (new, spec) — this file.
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (modified, spec iter-1 + Task 3) — `1-6 → ready-for-dev → done`.
- `RALPH.md` (modified, spec iter-1 + Tasks 1/2/3) — signposts + lessons + gotchas for each iteration.
- `.ralph/@plan.md` (modified each iteration) — state carrying.

## Test Debt (post-Story-1.21 audit)

See [test-debt.md § Story 1-6](./test-debt.md#story-1-6) for the post-Story-1.21 audit catalogue entry — back-fill effort/risk class + carry-to target.
