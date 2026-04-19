# Story 1.4: Pre-commit quality gates via prek (type-check, lint, format)

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want prek-managed pre-commit hooks that run TypeScript type-check, ESLint, and Prettier on every commit,
so that no local commit lands with a type error, lint error, or unformatted file (FR28).

## Acceptance Criteria

1. **Given** a fresh clone and `pnpm install`,
   **When** the pnpm `prepare` lifecycle script runs after dependency install,
   **Then** `prek install` writes an executable `.git/hooks/pre-commit` script that invokes prek's hook runner against the repo-root `.pre-commit-config.yaml`
   **And** subsequent `git commit` invocations exercise the hook automatically (no manual wiring required).

2. **Given** a file with a TypeScript compiler error is staged,
   **When** `git commit` runs,
   **Then** the pre-commit hook's `typecheck` step (`pnpm -w typecheck`) exits non-zero surfacing the `tsc` error
   **And** `git commit` aborts without landing the commit.

3. **Given** a file with an ESLint error is staged (e.g. a cross-package relative import that Story 1.3 AC 1 rejects),
   **When** `git commit` runs,
   **Then** the pre-commit hook's `lint` step (`pnpm -w lint`) exits non-zero surfacing the `eslint` error
   **And** `git commit` aborts without landing the commit.

4. **Given** an unformatted file is staged (double quotes in a `singleQuote: true`-required TS file, or missing trailing comma),
   **When** `git commit` runs,
   **Then** the pre-commit hook's `format-check` step (`pnpm -w format:check`) exits non-zero surfacing the Prettier diff
   **And** `git commit` aborts without landing the commit.

5. **Given** a clean commit (no type error, no lint error, Prettier-conformant),
   **When** `git commit` runs,
   **Then** all three hook steps exit zero, the hook exits zero, and the commit lands normally
   **And** on cache-warm re-runs, the combined typecheck + lint + format-check time stays well under the 10 s pre-commit budget (architecture.md § CI pyramid — pre-commit ≤10 s, typically ≤1 s with FULL TURBO cache).

6. **Given** the three local hooks are declared in `.pre-commit-config.yaml` at repo root as `language: system` hooks invoking `pnpm -w typecheck`, `pnpm -w lint`, `pnpm -w format:check` respectively,
   **When** `pnpm exec prek run --all-files` is invoked manually,
   **Then** all three hooks execute via prek's runner (parity with the git-hook path — same config, same commands)
   **And** the full-quality-gate set (`pnpm -w typecheck` + `pnpm -w lint` + `pnpm format:check` + `pnpm exec commitlint --from origin/main --to HEAD`) remains green across the branch at Task 3.

## Tasks / Subtasks

- [x] **Task 1: Pin `@j178/prek`, author `.pre-commit-config.yaml`, wire the `prepare` lifecycle script** (AC: 1, 6)
  - [x] Add `@j178/prek@0.3.9` to root `package.json` `devDependencies` (alongside existing `eslint`, `prettier`, etc.). Confirmed current stable via `pnpm info @j178/prek version` → `0.3.9`. Pin exact (no `^`/`~`) per Story 1.1/1.2 convention.
  - [x] Run `pnpm install` to fetch the package. Expect `node_modules/@j178/prek/` and `node_modules/.bin/prek` to exist. Verify `pnpm exec prek --version` prints `0.3.9`.
  - [x] Create `.pre-commit-config.yaml` at repo root with exactly three local hooks, all `language: system`, `pass_filenames: false`, `always_run: true` (workspace-level commands are invariant under which files are staged — the hook exists to gate the whole tree):
    ```yaml
    # Pre-commit quality gates (Story 1.4).
    # Runs under @j178/prek — drop-in pre-commit framework reimplementation.
    # Hook budget: ≤10 s total (pre-commit tier per architecture.md § CI pyramid).
    # Cache-warm runs typically stay under 1 s via turbo FULL TURBO.
    repos:
      - repo: local
        hooks:
          - id: typecheck
            name: TypeScript type-check (workspace)
            entry: pnpm -w typecheck
            language: system
            pass_filenames: false
            always_run: true
          - id: lint
            name: ESLint (workspace)
            entry: pnpm -w lint
            language: system
            pass_filenames: false
            always_run: true
          - id: format-check
            name: Prettier format:check (workspace)
            entry: pnpm -w format:check
            language: system
            pass_filenames: false
            always_run: true
    ```
    **Why `language: system`?** The three commands are pnpm-script invocations that already orchestrate their own tooling (turbo + tsc, turbo + eslint, prettier). Using `language: node` or similar would force prek to provision its own language environment — redundant and slower. `system` delegates to the current shell's `PATH`, which in any `pnpm` command context includes `node_modules/.bin/`.
    **Why `pass_filenames: false` + `always_run: true`?** The hooks run workspace-level commands (turbo + prettier walk their own inputs). Passing per-file filenames would either be ignored or confuse the downstream tools. `always_run: true` means the hook fires even when no matching files are staged — critical because commits can touch non-code files (markdown, YAML, config) and we still want the gate to pass before landing. Cache-warm FULL TURBO on no-op commits stays negligible.
  - [x] Add a `prepare` lifecycle script to root `package.json`: `"prepare": "prek install"`. **Why `prepare`, not `postinstall`?** `prepare` is the Husky-established convention for git-hook installation — it runs after `pnpm install` completes AND is the script most users expect for hook setup. `postinstall` also works but carries a side effect when the package is a consumed dep (irrelevant here — keel is unpublished, but the convention stands). The `prepare` script runs once, on first `pnpm install` and on every subsequent install. `prek install` is idempotent — running twice is a no-op after the first.
  - [x] Run `pnpm install` a second time to exercise `prepare`. Expect `.git/hooks/pre-commit` to be written (or updated) by prek. Inspect the file:
    ```bash
    cat .git/hooks/pre-commit | head -20
    ls -la .git/hooks/pre-commit       # must be executable
    ```
    Expect the file to be a shell script that invokes prek's hook runner (implementation detail — whatever prek writes, it must be executable and must locate the `prek` binary at commit-time). **Worktree note:** this Ralph iteration runs inside `.claude/worktrees/ralph/`; in a git worktree, `.git` is a file pointing at `<repo>/.git/worktrees/<name>/`. `prek install` respects `core.hooksPath` and per-worktree hooks, per the prek docs. If hooks end up in the main repo's `.git/hooks/` (shared across worktrees) that's still correct — the hook fires on any `git commit` in any worktree.
  - [x] **Self-verification probe (dev loop, not committed):** `pnpm exec prek run --all-files typecheck` should invoke the typecheck step directly via prek's runner and exit 0 (tree is currently clean after Story 1.3). Likewise `pnpm exec prek run --all-files lint` → exit 0, and `pnpm exec prek run --all-files format-check` → exit 0. This confirms the config loads and each hook ID resolves.
  - [x] Quality gates:
    - `pnpm -w typecheck` — FULL TURBO (16/16 cached) assuming no TS input moved. The change in this task touches only `package.json` (devDep add) and a new `.pre-commit-config.yaml` — neither is a typecheck input; cache should survive.
    - `pnpm -w lint` — similarly FULL TURBO; `.pre-commit-config.yaml` is not a lint input.
    - `pnpm format:check` — exit 0. The new YAML file must conform to Prettier's YAML formatter (quoted strings consistent, indent 2).
    - `pnpm exec commitlint --from origin/main --to HEAD --verbose` — 0/0 across existing branch commits (spec commit only at this point).
  - [x] Commit: `feat(invariants): Story 1.4 Task 1 — wire prek pre-commit config + prepare script`. Include IP + RALPH.md upkeep in the same commit per Ralph's knowledge-file contract (step 3a of the build prompt).

- [x] **Task 2: ATDD smoke probes proving each failure-mode AC fires + clean-commit AC 5 + prek-runner parity AC 6** (AC: 2, 3, 4, 5, 6)
  - [x] These probes create temporary bad-state files in the worktree, attempt `git commit` (which must abort), then clean up. They produce NO committed artefacts beyond Debug Log entries capturing each probe's output. Every probe runs in sequence; each cleans up before the next.
  - [x] **AC 2 probe (TypeScript error aborts commit):**
    ```bash
    # Write a TS-error file inside a package that typecheck covers.
    cat > packages/audit/src/__ac2-probe.ts <<'EOF'
    // Deliberate type error — probe for Story 1.4 AC 2.
    const n: number = 'not a number';
    export default n;
    EOF
    git add packages/audit/src/__ac2-probe.ts
    # Attempt commit — expect hook to abort.
    git commit -m 'probe: AC 2 type-error' 2>&1 | tee /tmp/ac2.out
    echo "exit=$?"
    # Clean up regardless of outcome.
    git reset HEAD packages/audit/src/__ac2-probe.ts 2>/dev/null || true
    rm -f packages/audit/src/__ac2-probe.ts
    ```
    Expect: non-zero exit from `git commit`; `/tmp/ac2.out` contains `typecheck` hook name + a `TS` error code (e.g. `TS2322` "Type 'string' is not assignable to type 'number'"). No commit on the branch (`git log -1` unchanged).
  - [x] **AC 3 probe (ESLint error aborts commit):**
    ```bash
    cat > packages/audit/src/__ac3-probe.ts <<'EOF'
    // Deliberate cross-package relative import — Story 1.3 AC 1 forbids this.
    import foo from '../../contracts/src/index.ts';
    export default foo;
    EOF
    git add packages/audit/src/__ac3-probe.ts
    git commit -m 'probe: AC 3 lint-error' 2>&1 | tee /tmp/ac3.out
    echo "exit=$?"
    git reset HEAD packages/audit/src/__ac3-probe.ts 2>/dev/null || true
    rm -f packages/audit/src/__ac3-probe.ts
    ```
    Expect: non-zero exit; `/tmp/ac3.out` contains `lint` hook name + `no-restricted-imports` + "No relative imports crossing a package src/ boundary". No commit on the branch.
  - [x] **AC 4 probe (Prettier diff aborts commit):**
    ```bash
    # Write a TS file with double quotes (keel style is singleQuote: true).
    cat > packages/audit/src/__ac4-probe.ts <<'EOF'
    export const greeting = "hello world";
    EOF
    git add packages/audit/src/__ac4-probe.ts
    git commit -m 'probe: AC 4 format-diff' 2>&1 | tee /tmp/ac4.out
    echo "exit=$?"
    git reset HEAD packages/audit/src/__ac4-probe.ts 2>/dev/null || true
    rm -f packages/audit/src/__ac4-probe.ts
    ```
    Expect: non-zero exit; `/tmp/ac4.out` contains `format-check` hook name + Prettier's "Code style issues found" or equivalent. No commit on the branch.
  - [x] **AC 5 probe (clean commit lands):** Create a tiny, type-safe, lint-safe, format-safe file (e.g. a single-line comment in markdown or a trivial empty-body `export {}` in a TS file that's already a no-op index). Commit it:
    ```bash
    echo "" >> RALPH.md     # trivial idempotent trailing newline (existing file, still format-safe)
    git add RALPH.md
    git commit -m 'probe: AC 5 clean-commit'
    # Clean up the probe commit via reset; we don't want a throwaway commit on the branch.
    git reset --mixed HEAD~1
    git checkout -- RALPH.md
    ```
    Expect: `git commit` exits 0. The hook ran (all three steps green), commit lands, then we roll back the probe commit to keep the branch clean for Task 3. **Important:** `git reset --mixed HEAD~1` DOES NOT re-run hooks; it just unwinds the HEAD pointer. The branch is restored to its pre-probe state.
  - [x] **AC 6 probe (prek-runner parity):**
    ```bash
    pnpm exec prek run --all-files typecheck 2>&1 | tee /tmp/ac6-typecheck.out
    echo "typecheck-exit=$?"
    pnpm exec prek run --all-files lint 2>&1 | tee /tmp/ac6-lint.out
    echo "lint-exit=$?"
    pnpm exec prek run --all-files format-check 2>&1 | tee /tmp/ac6-format-check.out
    echo "format-check-exit=$?"
    ```
    Expect each exits 0 on the post-AC-5-cleanup tree (which is identical to the post-Task-1 tree). This proves the hook identifiers resolve and prek's runner path matches git's hook path (same command, same tree, same outcome).
  - [x] Capture every probe's output in Debug Log References when Task 2 lands. If ANY probe produces unexpected output (e.g. AC 2 probe succeeds instead of failing, or AC 5 probe fails), **loop back to Task 1** and fix the config. Document any such loop-back in Completion Notes List.
  - [x] Commit: `feat(invariants): Story 1.4 Task 2 — ATDD smoke probes verify prek hooks fire + parity`.

- [x] **Task 3: Full quality-gate verification + sprint-status update** (AC: 5, 6)
  - [x] `pnpm install` — expect `Already up to date` / no lockfile churn (no new deps added by this task).
  - [x] `pnpm -w typecheck` — expect 16/16 `>>> FULL TURBO` on FIRST call of this iteration (no TS inputs changed between Task 2 and Task 3 — probe files from Task 2 were deleted before the commit, so the committed tree is the Task 1 state + Debug Log updates). Cache warm.
  - [x] `pnpm -w lint` — expect 16/16 `>>> FULL TURBO`. Same reasoning.
  - [x] `pnpm format:check` — `All matched files use Prettier code style!` exit 0.
  - [x] `pnpm exec commitlint --from origin/main --to HEAD --verbose` — 0 problems / 0 warnings across branch commits (spec + Task 1 + Task 2 = 3 commits, all `feat(invariants): Story 1.4 Task N — …` or `docs(story):` shape).
  - [x] `pnpm exec prek run --all-files` — run all three hooks in sequence via prek's runner. Expect all three exit 0. This is the end-to-end re-verification that the committed config + committed devDep + committed prepare script produce a working prek hook.
  - [x] Update `_bmad-output/implementation-artifacts/sprint-status.yaml`: flip `1-4-pre-commit-quality-gates-via-prek-type-check-lint-format` from `ready-for-dev` → `done`; bump `last_updated`. Land this BEFORE the PR Draft→Open transition to avoid orphan bookkeeping commits (RALPH.md Lessons 2026-04-19 "Post-halt bookkeeping commits can orphan from main"; Story 1.2/1.3 precedents).
  - [x] Commit: `feat(invariants): Story 1.4 Task 3 — all quality gates green + sprint-status bump`.

## Dev Notes

### Relevant architecture patterns and constraints

**Pre-commit is Tier 1 of the decomposed CI pyramid.** Architecture.md §77 and §145 pin a ≤10 s budget for pre-commit; Story 1.4 ships the tier. The three gates land here (typecheck, lint, format); later stories (1.5 commitlint hook, 1.6 bypass prevention, 1.8/1.9 manifest + sync gate, then Epic 4 S4 prompt-injection scanner) layer on. The hook configuration is the minimum-viable-substrate, not the final shape. [Source: architecture.md lines 77, 145, 679.]

**`packages/keel-invariants/` is the canonical config home; the repo-root `.pre-commit-config.yaml` is the active consumer.** Story 1.2 established shared configs for ESLint / Prettier / commitlint / TS under `packages/keel-invariants/` with subpath exports. Story 1.4 intentionally plants the prek config at repo root (NOT as a subpath export), because prek's config is consumed natively by the tool itself — prek looks for `.pre-commit-config.yaml` in the repo root. A copy in `packages/keel-invariants/` would be drift-by-design (two config sources → divergence). Story 1.8's manifest will content-hash the repo-root file so Story 1.6's bypass-prevention gate detects unauthorised edits. [Source: architecture.md lines 802 (envisioned `.prek/hooks.yaml`), 894 (envisioned `prek-hooks.yaml` reference); see Variance note below for why we deviate from those paths.]

**Local hooks over upstream repos.** `.pre-commit-config.yaml` supports two patterns: `repo: <git-url>` (fetch hooks from a third-party repo) and `repo: local` (invoke a shell command). We use `repo: local` for all three because the commands (`pnpm -w typecheck` / `pnpm -w lint` / `pnpm -w format:check`) already exist as pnpm scripts wired in Story 1.1 (`typecheck`, `lint` via turbo) and Story 1.2 (`format:check`). A third-party hooks repo would add a dep and duplicate our pnpm scripts. Local hooks keep the single source of truth — when those pnpm scripts change, the hooks follow automatically. [Source: pre-commit docs on local hooks; Story 1.1 `turbo.json` + Story 1.2 Task 6 root-script wiring.]

**`language: system` vs `language: node`.** `language: node` would provision a dedicated node environment inside prek's cache and run the entry there. `language: system` delegates to the shell, using the caller's `PATH`. Our pnpm scripts already orchestrate their own node runtime (via `node_modules/.bin` resolution), so layering prek's own node provisioning on top is dead weight. `system` is the simplest path that works. [Source: pre-commit docs — "local hooks with language: system".]

**`@j178/prek` vs upstream `pre-commit`.** Prek is a Rust reimplementation of the pre-commit framework, fully compatible with `.pre-commit-config.yaml`. We pin prek via pnpm devDep (`@j178/prek@0.3.9`) rather than installing pre-commit via pip/uv because: (a) pnpm is already the package manager for the repo — no second manager needed; (b) prek is faster than pre-commit on every benchmark (startup + hook dispatch); (c) architecture.md explicitly names prek in the hardwired stack (lines 71, 145, 162, 655, 679). [Source: architecture.md § Hardwired stack; WebFetch of github.com/j178/prek README.]

**`prepare` lifecycle hook is the Husky-established convention.** Every npm/pnpm-based git-hook tool (Husky, Lefthook's node wrapper, pre-commit's npm variant) uses `prepare` because it runs AFTER `pnpm install` but BEFORE publish (a harmless side effect on unpublished packages like keel). Using `postinstall` would also work but carries the quirk that it runs when keel is consumed as a dep (irrelevant for an unpublished root, but convention wins). [Source: npm docs § scripts; Husky's published convention.]

### Source tree components to touch

**Added (Task 1):**
- `.pre-commit-config.yaml` — repo-root active config; 3 local hooks under a single `repo: local` block. Formatted per Prettier YAML defaults (2-space indent, double-quoted strings where required — though bare strings everywhere here — trailing newline).

**Modified (Task 1):**
- `package.json` (root) — add `"@j178/prek": "0.3.9"` to `devDependencies`; add `"prepare": "prek install"` to `scripts`. Preserve existing field order.
- `pnpm-lock.yaml` — updated by `pnpm install` to record `@j178/prek@0.3.9` and its transitive deps. Committed.

**Created by `prek install` (NOT committed — git-ignored or outside the worktree):**
- `.git/hooks/pre-commit` — prek's auto-generated shell script. Regenerated by `prek install`. Not committed (`.git/` is never tracked). Each fresh clone re-runs `prepare` and re-creates the file.

**Modified (Task 3):**
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — flip `1-4-pre-commit-quality-gates-via-prek-type-check-lint-format` from `ready-for-dev` → `done`; bump `last_updated`.

**Unchanged across the story:** every per-package `eslint.config.js` (Story 1.3); every per-package `tsconfig.json` (Story 1.1); `packages/keel-invariants/{eslint,prettier,commitlint}.config.keel-invariants.js` (Story 1.2); every `src/*.ts` file (this is pure tooling config); `turbo.json`; `pnpm-workspace.yaml`; root `eslint.config.js` / `prettier.config.js` / `commitlint.config.js` shims.

### Testing standards summary

**No unit / integration `.test.ts` files land in Story 1.4.** Like Stories 1.2 and 1.3, the test surface IS the quality gates themselves. Verification evidence is captured via ephemeral Task 2 probes (create bad-state file → stage → attempt commit → assert failure → clean up) whose outputs land in the story's Debug Log References.

**ATDD red phase** is implicit in the Task 1 dev loop: BEFORE the hooks are wired (`prepare` hasn't run, `.pre-commit-config.yaml` absent), `git commit` on a staged TS-error file succeeds (no hook → no gate). After Task 1, the same commit attempt fails at the hook. The red→green transition is the proof the hook fires. Do NOT commit any `__ac*-probe.ts` files — every Task 2 probe cleans up its temp files before moving on.

**Budget expectations.** Pre-commit tier budget is ≤10 s per architecture.md §77. With turbo cache FULL TURBO on both typecheck and lint (Story 1.2/1.3 confirmed property on verification-only iterations), a clean-commit hook run is typically ≤1 s. Cold runs (post-`turbo prune` or first-time-after-clone) can reach several seconds — still within budget. Story 1.4 does NOT add a cold-run benchmark gate; that's in scope for Story 1.13 (token quality gates) or Epic 3 NFR28b work.

### Project Structure Notes

**Alignment with unified project structure:**

- ✅ Pre-commit config lives at repo root (`.pre-commit-config.yaml`) — the path prek expects natively. No subpath gymnastics.
- ✅ Three gates (typecheck, lint, format) cleanly compose the existing pnpm scripts from Story 1.1 + 1.2. Single source of truth for each tool's behaviour.
- ✅ `@j178/prek` pinned at root per Story 1.1/1.2 devDep-pin convention (exact version, no range).
- ✅ `prepare` lifecycle hook fires automatically on `pnpm install`; no manual `prek install` step required by fork operators.

**Detected conflicts or variances:**

- **Variance — config path differs from architecture.md.** Architecture.md line 802 envisioned `.prek/hooks.yaml`; line 894 envisioned `packages/keel-invariants/src/prek-hooks.yaml` as the "reference hook graph". Story 1.4 instead plants `.pre-commit-config.yaml` at repo root because: (a) prek reads that path natively — any custom path requires explicit `--config` flags on every invocation, breaking the `prek install` convenience; (b) there's no import/extends mechanism in `.pre-commit-config.yaml`, so a "reference copy" in keel-invariants would be pure duplication, not a subpath export. Story 1.8's `invariants.manifest.ts` will content-hash the repo-root file to anchor it as the manifested invariant; Story 1.6's bypass-prevention gate detects unauthorised edits via that hash. Net: the architecture intent (centralised enforcement + drift detection) is preserved; only the file path deviates.
- **Variance — no copy in `packages/keel-invariants/`.** Same reasoning as above. The single-source-of-truth for the hook config is the repo-root file; Story 1.8 catalogues it as an invariant via manifest entry, not via file duplication.
- **Variance — `always_run: true` on all three hooks.** Pre-commit hooks commonly use `files:` patterns to scope per-file. Here, every hook is workspace-level (turbo + prettier walk the full tree), so scoping per-file would either be ignored or cause missed gates when a commit touches only non-code files. `always_run: true` ensures the full gate fires on every commit regardless of file types touched. Cache-warm FULL TURBO on no-op commits is negligible.
- **Variance — `pnpm -w format:check` used in the hook even though `format:check` is a root-level Prettier script (not turbo-orchestrated).** `pnpm -w <script>` works for any root script regardless of whether it's turbo-orchestrated. The `-w` flag just locates the workspace root before running the script — the script itself does whatever pnpm's `run` command would do. This keeps the hook commands uniform in shape (`pnpm -w <foo>`) and means the hook works when invoked from any cwd (git can invoke hooks from subdirectories depending on where the commit was run).

### Previous Story Intelligence (from Story 1.3)

**Files / patterns Story 1.4 builds on:**
- Root `package.json` — already has `type: module` (Story 1.2 Task 6), `devDependencies` for eslint/prettier/commitlint/turbo/typescript (Stories 1.1, 1.2), and root scripts `typecheck` / `lint` / `format` / `format:check` (Stories 1.1, 1.2 Task 6). Story 1.4 appends one devDep + one script.
- Root `eslint.config.js` / `prettier.config.js` / `commitlint.config.js` shims (Story 1.2 Task 6) — the hooks' `pnpm -w lint` / `pnpm format:check` invocations hit these. Hooks don't touch them directly.
- Per-package ESLint configs using `forPackage('<name>')` (Story 1.3 Task 2) — the AC 3 probe relies on `@keel/contracts/internal/…` or cross-package relative imports being rejected. Story 1.4's AC 3 probe uses the cross-package relative-import variant (proven to fire in Story 1.3 Task 3 probe evidence).
- Turbo `typecheck` + `lint` tasks from `turbo.json` (Story 1.1). Not modified here.
- `pnpm-lock.yaml` — updated by `pnpm install` when `@j178/prek` is added. Committed per Story 1.1 convention (lockfile is source-controlled).

**Landmines Stories 1.2 + 1.3 hit (RALPH.md Lessons 2026-04-19) that could recur:**

- **Turbo cache sensitivity to `package.json` edits.** `package.json` is a turbo input for most tasks. Adding `@j178/prek` to `devDependencies` invalidates the typecheck + lint caches on first run of Task 1. Expected one-time cold run; subsequent runs warm. This is not a bug — it's the turbo contract.
- **Prettier YAML formatting.** `.pre-commit-config.yaml` is a new YAML file; Prettier will format it on `pnpm format`. Author it with Prettier-compatible style from the start (2-space indent, no trailing whitespace, trailing newline) to avoid a Task-1 format-fix commit. If `pnpm format:check` fails on the new file, run `pnpm format` once and commit the normalised version.
- **ESM `import` at repo root requires `"type": "module"`.** Root `package.json` already has this (Story 1.2 Task 6). Story 1.4 doesn't author new JS files; no risk.
- **PR metadata drift for multi-commit story PRs.** Story 1.1 + 1.2 + 1.3 all had to rewrite PR title/body before `gh pr ready`. Story 1.4 expect ~4 commits (spec + Tasks 1–3). Per RALPH.md Lessons "Multi-commit story PRs drift PR metadata from reality": before `gh pr ready`, re-read `git log origin/main..HEAD --oneline` and rewrite the PR body to cover all commits.
- **Post-halt bookkeeping orphan risk.** Sprint-status update MUST land before `gh pr ready`. Apply pre-emptively per Story 1.2/1.3 precedents — same commit as Task 3 or a separate `chore(sprint):` commit pushed before the transition iteration.
- **Commitlint subject-case / header-length rules.** Story 1.2 Task 5 authored the keel commitlint config. `feat(invariants): Story 1.4 Task N — <summary>` passes comfortably (≤100 chars typical).
- **Pre-commit hook self-enforcement starting at Task 1 Commit.** Once `.git/hooks/pre-commit` exists (after Task 1's `pnpm install`), every subsequent `git commit` in this branch (Task 2, Task 3, sprint-status, IP upkeep) must pass all three gates. This is a feature, not a bug — the story's own commits prove the hook works. But it means any accidental bad state (unformatted YAML, committed probe file with type error) aborts the commit. The answer is to keep the tree clean between commits — exactly what Ralph does anyway.

**Testing approaches validated in Story 1.3 that Story 1.4 inherits:**
- `pnpm -w typecheck` twice → `>>> FULL TURBO` on second run = the cache-hit assertion.
- `pnpm -w lint` twice → same pattern.
- `pnpm exec commitlint --from origin/main --to HEAD --verbose` → 0/0 across all branch commits = the commit-gate assertion.
- `pnpm format:check` → exit 0 on clean tree = the format gate.
- Probe-via-`eslint --stdin` style (Story 1.3 Task 3) extended here to `git commit` probes with temp files + cleanup (Story 1.4 Task 2).

### Git Intelligence Summary (recent patterns)

Last commits on `feat/story-1-3-eslint-no-restricted-imports-import-boundary-rules` (merged via PR #219 as commit `40507d9`):
- `45e3133 chore(ralph): Story 1.3 complete — IP + RALPH.md reflect Draft→Open transition`
- `e0e8f3c feat(invariants): Story 1.3 Task 4 — all quality gates green + sprint-status bump`
- `691ea80 feat(invariants): Story 1.3 Task 3 — ATDD smoke probes + broaden AC 1 patterns`
- `759a6fb feat(invariants): Story 1.3 Task 2 — wire 16 per-package eslint.config.js to forPackage(<name>)`
- `a2def5d feat(invariants): Story 1.3 Task 1 — extend shared ESLint with no-restricted-imports + forPackage factory`

Convention: `feat(invariants): Story X.Y Task N — <summary>`. Story 1.4 commits follow the same scope (`invariants`, since the hook gates defend substrate invariants — type safety, import boundaries, format discipline — authored in `packages/keel-invariants/` by Stories 1.1–1.3). Preserve one task per commit.

### Latest Technical Information

- **`@j178/prek@0.3.9`** — current stable. Verified via `pnpm info @j178/prek version` on 2026-04-19. No version upgrade scheduled for this story.
- **`.pre-commit-config.yaml` schema** — pre-commit format, same as upstream (`repos: [ { repo: local, hooks: [...] } ]`). Prek also supports native `prek.toml` via `prek util yaml-to-toml`; Story 1.4 uses YAML for compatibility + broad tooling familiarity. Migration to TOML is a harmless future option (Story 1.6+ if it ever becomes relevant). [Source: <https://github.com/j178/prek>.]
- **`prek install` behaviour** — writes `.git/hooks/pre-commit` (or updates it if pre-existing) with a shell wrapper that invokes `prek run` against the committed config. Respects `core.hooksPath` for monorepo worktrees. Idempotent. [Source: prek README; WebFetch 2026-04-19.]
- **No pinned-version upgrades in this story** — eslint@10.2.1, prettier@3.8.3, typescript@5.7.3, turbo@2.3.3 stay at their current pins. Only adds `@j178/prek@0.3.9`.

### References

- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.4, lines 746–775] — Story 1.4 AC (authoritative scope; 5 ACs mirrored here with one expanded AC 6 for prek-runner parity evidence).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.5, lines 777–801] — Story 1.5 AC (next story: commitlint hook via prek; builds on this story's `.pre-commit-config.yaml`).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.6, lines 803–828] — Bypass-prevention scope. Story 1.4 plants the hook; Story 1.6 detects edits that would remove or disable it.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#CI-pyramid, lines 77, 145] — 5-tier CI pyramid with pre-commit ≤10 s budget; prek named in hardwired stack.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Pre-commit-hooks, lines 679] — "Pre-commit (≤10s): prek + commitlint + ESLint + TypeScript changed-files + prompt-injection regex (S4) + bare-string + ARIA lint + token-drift check." Story 1.4 lands the first three (typecheck, ESLint, commitlint deferred to Story 1.5; S4 + bare-string + ARIA + token-drift land in later stories).
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Hardwired-stack, line 71] — prek listed alongside Turborepo, pnpm, commitlint, release-please.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Folder-layout, lines 802, 894] — envisioned `.prek/hooks.yaml` + `packages/keel-invariants/src/prek-hooks.yaml`. Story 1.4 variances (documented in Project Structure Notes) deviate to `.pre-commit-config.yaml` at repo root.
- [Source: `_bmad-output/planning-artifacts/prd.md`#FR28] — System enforces type-safe TypeScript with no `any` leakage across boundaries; pre-commit is one of the enforcement points.
- [Source: `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`] — Story 1.2 established shared configs + subpath-export mechanism.
- [Source: `_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`] — Story 1.3 established `forPackage('<name>')` migration + ATDD probe convention for Epic 1.
- [Source: `RALPH.md`#Signposts-2026-04-19] — Story 1.3 SHIPPED; all Story 1.2/1.3 landmines apply here.
- [Source: <https://github.com/j178/prek>] — prek README; installation + config schema + `prek install` behaviour.
- [Source: <https://pre-commit.com/#pre-commit-configyaml---hooks>] — pre-commit docs on local hooks + `language: system` + `always_run`.

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (1M context) via Ralph build loop; one task per iteration across three implementation iterations (Tasks 1 → 2 → 3).

### Debug Log References

**Task 2 (2026-04-19) — ATDD smoke probes; all 5 ACs (2/3/4/5/6) green.** Every probe ran against the Task-1 tree at branch tip `3450924`. After each probe the tree was restored to that tip (`git status` clean, `git log --oneline origin/main..HEAD` identical across probes).

- **AC 2 probe — TypeScript error aborts commit.** File: `packages/audit/src/__ac2-probe.ts` with `const n: number = 'not a number';`. `git commit` exit = 1. Relevant hook lines:

  ```
  TypeScript type-check (workspace)........................................Failed
  - hook id: typecheck
  - exit code: 1
  @keel/audit:typecheck: src/__ac2-probe.ts(1,7): error TS2322: Type 'string' is not assignable to type 'number'.
  ESLint (workspace).......................................................Passed
  Prettier format:check (workspace)........................................Passed
  ```

  Turbo run: `15 successful, 16 total; Cached: 15 cached, 16 total; Failed: @keel/audit#typecheck`. The ESLint and Prettier hooks still ran (prek runs all hooks even after one fails and aggregates pass/fail); commit aborted because typecheck hook failed. Post-probe: `__ac2-probe.ts` removed, no commit on branch. [Source: `/tmp/ac2.out`.]

- **AC 3 probe — ESLint error aborts commit.** File: `packages/audit/src/__ac3-probe.ts` with `import foo from '../../contracts/src/index.ts';`. `git commit` exit = 1. Relevant lint-hook lines:

  ```
  ESLint (workspace).......................................................Failed
  @keel/audit:lint: /workspace/ralph-bmad/.claude/worktrees/ralph/packages/audit/src/__ac3-probe.ts
  @keel/audit:lint:   1:1  error  '../../contracts/src/index.ts' import is restricted from being used by a pattern. No relative imports crossing a package src/ boundary. Use the @keel/<pkg> alias for cross-package imports (architecture.md § Public surface enforcement)  no-restricted-imports
  @keel/audit:lint: ✖ 1 problem (1 error, 0 warnings)
  Prettier format:check (workspace)........................................Passed
  ```

  Side-effect observation: `TypeScript type-check (workspace)` also Failed in this probe because `packages/contracts/src/index.ts` has no default export (Story 1.1 left the file empty); the default-import specifier forces a TS2613 / TS2306. Both gates catching the same bad code is defense-in-depth, not a spec drift — AC 3 requires the **lint** hook to fire on cross-package relative imports, which it did, with the exact `no-restricted-imports` rule-id + message from Story 1.3 Task 1. Post-probe: `__ac3-probe.ts` removed, no commit on branch. [Source: `/tmp/ac3.out`.]

- **AC 4 probe — Prettier diff aborts commit.** File: `packages/audit/src/__ac4-probe.ts` with `export const greeting = "hello world";` (double-quote violates keel `singleQuote: true`). `git commit` exit = 1. Relevant hook lines:

  ```
  TypeScript type-check (workspace)........................................Passed
  ESLint (workspace).......................................................Passed
  Prettier format:check (workspace)........................................Failed
  [warn] packages/audit/src/__ac4-probe.ts
  [warn] Code style issues found in the above file. Run Prettier with --write to fix.
  ```

  Only Prettier fires (typecheck + lint accept the file — double quotes are ESLint-neutral without a stylistic rule). This is the expected isolation: format-check alone catches the style drift. Post-probe: `__ac4-probe.ts` removed, no commit on branch. [Source: `/tmp/ac4.out`.]

- **AC 5 probe — clean commit lands.** File: `_bmad-output/__ac5-probe.txt` containing a one-line marker (path under `_bmad-output/` is in `.prettierignore`; text file is not a typecheck or lint input). `git commit` exit = 0. Relevant hook lines:

  ```
  TypeScript type-check (workspace)........................................Passed
  ESLint (workspace).......................................................Passed
  Prettier format:check (workspace)........................................Passed
  [feat/story-1-4-pre-commit-quality-gates-via-prek-type-check-lint-format 01e835d] probe: AC 5 clean-commit
   create mode 100644 _bmad-output/__ac5-probe.txt
  ```

  Probe commit `01e835d` landed; rolled back via `git reset --hard HEAD~1`. Branch tip `3450924`, worktree clean, probe file absent. [Source: `/tmp/ac5.out`.]

- **AC 6 probe — prek-runner parity.** All three hooks invoked directly through prek's runner against the Task-1 tree:

  ```
  pnpm exec prek run --all-files typecheck     → exit 0 → "TypeScript type-check (workspace)...Passed"
  pnpm exec prek run --all-files lint          → exit 0 → "ESLint (workspace)...Passed"
  pnpm exec prek run --all-files format-check  → exit 0 → "Prettier format:check (workspace)...Passed"
  ```

  Same three commands the git-hook path invokes, same tree, same exit codes — parity confirmed. [Source: `/tmp/ac6-typecheck.out`, `/tmp/ac6-lint.out`, `/tmp/ac6-format-check.out`.]

**No Task-1 loop-back was required** — every probe behaved exactly as AC spec predicted (modulo the AC 3 typecheck side-effect documented above, which is an extra gate firing, not an AC failure).

**Task 3 (2026-04-19) — full quality-gate verification + sprint-status bump; all gates FULL TURBO on first call.**

- `pnpm install` → `Lockfile is up to date, resolution step is skipped` / `Already up to date`; `prepare` re-ran `prek install` (idempotent — hook already at `/workspace/ralph-bmad/.git/hooks/pre-commit` from Task 1). `Done in 627ms`.
- `pnpm -w typecheck` → `Tasks: 16 successful, 16 total; Cached: 16 cached, 16 total; Time: 136ms >>> FULL TURBO`.
- `pnpm -w lint` → `Tasks: 16 successful, 16 total; Cached: 16 cached, 16 total; Time: 114ms >>> FULL TURBO`.
- `pnpm format:check` → `All matched files use Prettier code style!` exit 0.
- `pnpm exec commitlint --from origin/main --to HEAD --verbose` → `found 0 problems, 0 warnings` across 4 branch commits (`docs(story):` spec + `chore(ralph):` IP + `feat(invariants): Story 1.4 Task 1` + `feat(invariants): Story 1.4 Task 2`).
- `pnpm exec prek run --all-files` → all three hooks `Passed` (TypeScript type-check (workspace), ESLint (workspace), Prettier format:check (workspace)); exit 0. Same three commands the git-hook path invokes, same tree, same outcomes — parity re-confirmed end-to-end.

Turbo cache handoff from Task 2 → Task 3 was clean: Task 2 committed only the story spec markdown file (not a typecheck / ESLint / format input — `_bmad-output/` under `.prettierignore`), so every gate hit `>>> FULL TURBO` on its first invocation of this verification iteration. Matches the property observed in Story 1.2 Task 7 and Story 1.3 Task 4 — verification-only iterations are essentially zero-cost from a cache-warming perspective.

### Completion Notes List

- **Task 2 AC 5 probe path variance.** Spec subtask suggested `echo "" >> RALPH.md` as the clean-commit probe target. Used `_bmad-output/__ac5-probe.txt` instead because appending `""` + newline to a file that already ends with `\n` produces `...\n\n`, which Prettier-markdown normalises to a single trailing newline — the `format-check` gate would then report a style diff on `RALPH.md` and abort the clean-commit probe, contaminating the AC 5 assertion. The replacement path is in `.prettierignore` (line 7: `_bmad-output/`), is not a typecheck input, is not an ESLint input — guaranteed-safe for all three gates. Rewind via `git reset --hard HEAD~1` removed the commit AND the probe file in one step. AC 5 semantic intent preserved (prove that all three hooks pass and a commit lands on a clean tree); only the probe vehicle differs from spec text.
- **Task 2 AC 3 probe side-effect.** The cross-package relative-import specifier (`'../../contracts/src/index.ts'`) fails both the `lint` hook (Story 1.3 AC 1 `no-restricted-imports`) and the `typecheck` hook (no default export at the target — Story 1.1 shipped empty `src/index.ts` files). Two gates catching the same violation is defense-in-depth, not a spec deviation — AC 3 requires that the **lint** hook fire on cross-package relative imports, which it did with the expected `no-restricted-imports` rule-id + "No relative imports crossing a package src/ boundary" message. Noted for Task 3 context: the AC 3 probe output is not a minimal failure demonstration; it's a both-gates-catch scenario.
- **Task 3 sprint-status bump landed BEFORE Draft→Open transition.** Per Story 1.2 + 1.3 precedent (RALPH.md Lessons 2026-04-19 "Post-halt bookkeeping commits can orphan from main"), the sprint-status update is part of Task 3's commit rather than a separate post-transition `chore(sprint):` bump. Eliminates the orphan-risk window where a user merges the PR between the Task-3 push and a separate sprint-status push. Matches Stories 1.2/1.3 execution shape.

### File List

**Task 1 commit (`3450924`):**

- Added: `.pre-commit-config.yaml` (repo root; 3 local hooks — `typecheck` / `lint` / `format-check`; all `language: system`, `pass_filenames: false`, `always_run: true`).
- Modified: `package.json` (root) — `"@j178/prek": "0.3.9"` added to `devDependencies`; `"prepare": "prek install"` added to `scripts`.
- Modified: `pnpm-lock.yaml` — `+309` lines to record `@j178/prek@0.3.9` + transitives.
- Untracked (not committed — prek writes to `.git/hooks/`): `/workspace/ralph-bmad/.git/hooks/pre-commit` — prek-generated shell wrapper invoking `prek hook-impl`.

**Task 2 commit (`aa6cbb7`):**

- Modified: `_bmad-output/implementation-artifacts/1-4-pre-commit-quality-gates-via-prek-type-check-lint-format.md` — populate Debug Log References + Completion Notes + File List; flip Task 2 subtasks `[ ]` → `[x]`.
- Created then removed (probe artefacts, not committed): `packages/audit/src/__ac2-probe.ts` / `__ac3-probe.ts` / `__ac4-probe.ts` + `_bmad-output/__ac5-probe.txt`. Every probe cleaned up before the next starts.

**Task 3 commit (this commit):**

- Modified: `_bmad-output/implementation-artifacts/sprint-status.yaml` — `1-4-pre-commit-quality-gates-via-prek-type-check-lint-format: ready-for-dev → done`; `last_updated: 2026-04-19 21:07 UTC`.
- Modified: `_bmad-output/implementation-artifacts/1-4-pre-commit-quality-gates-via-prek-type-check-lint-format.md` — `Status: ready-for-dev → done`; flip Task 1 + Task 3 subtasks `[ ]` → `[x]`; append Task 3 Debug Log + Completion Note; consolidate File List.
- Modified: `.ralph/@plan.md` — Task 3 → DONE; NOW = PR Draft→Open transition.
- Modified: `RALPH.md` — append Task 3 signpost (verification-only iteration, all gates FULL TURBO, sprint-status bump co-landed per Story 1.2/1.3 precedent).

**Unchanged across the story:** every per-package `eslint.config.js` (Story 1.3); every per-package `tsconfig.json` (Story 1.1); `packages/keel-invariants/{eslint,prettier,commitlint}.config.keel-invariants.js` (Story 1.2); every `src/*.ts` file (pure tooling story); `turbo.json`; `pnpm-workspace.yaml`; root `eslint.config.js` / `prettier.config.js` / `commitlint.config.js` shims; `.prettierignore`.
