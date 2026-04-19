# Story 1.5: Conventional-commit enforcement via commitlint + prek

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want commitlint running via prek on every commit using the shared config from Story 1.2,
so that agent and human commits alike follow conventional-commit format — a non-negotiable substrate invariant (FR14).

## Acceptance Criteria

1. **Given** the prek stack from Story 1.4 and the repo-root `.pre-commit-config.yaml`,
   **When** a 4th local hook entry `id: commitlint` with `stages: [commit-msg]` invoking `pnpm exec commitlint --edit` is declared and the root `prepare` script installs the commit-msg shim (`prek install -t pre-commit -t commit-msg`),
   **Then** every subsequent `git commit` in a fresh clone (post-`pnpm install`) fires both the pre-commit hook (Story 1.4: typecheck + lint + format-check) AND the commit-msg hook (commitlint against `@keel/keel-invariants/commitlint` via the root `commitlint.config.js` shim from Story 1.2).

2. **Given** a commit message `fix: resolve edge case in token emitter` on a clean tree,
   **When** `git commit -m 'fix: resolve edge case in token emitter'` runs,
   **Then** the pre-commit hook passes, the commit-msg hook's `commitlint` step exits 0, and the commit lands.

3. **Given** a commit message `Fixed stuff` on the same clean tree,
   **When** `git commit -m 'Fixed stuff'` runs,
   **Then** the pre-commit hook passes, the commit-msg hook's `commitlint` step exits non-zero with output explaining the missing `<type>(<scope>): <subject>` convention (standard `@commitlint/config-conventional` rule-id messages — e.g. `type-empty`, `subject-empty`),
   **And** the commit does not land (`git log -1` unchanged).

4. **Given** a commit authored by Ralph (agent) vs. a human,
   **When** each is created via `git commit` (interactive, `-m`, or any front-end),
   **Then** both pass or fail by the same rules — the commit-msg hook at `.git/hooks/commit-msg` fires unconditionally regardless of committer identity, with no agent-specific bypass.
   (Devbox-vs-host parity — the second half of epic AC 4 — is structurally implied: the hook lives in `.git/hooks/` and fires in any environment with working `prek` + `commitlint`. Devbox arrives in Epic 2; this story does not probe the devbox path. Story 1.6 separately prevents `--no-verify` / bypass circumvention.)

5. **Given** the `commitlint` hook is declared in `.pre-commit-config.yaml` under the same `repo: local` block as the 3 pre-commit hooks,
   **When** `pnpm exec prek run --stage commit-msg --files /tmp/<msg-file> commitlint` is invoked manually with a test fixture,
   **Then** the hook executes via prek's runner with the same `pnpm exec commitlint --edit` entrypoint as the git-hook path — parity confirmed (same config, same command, same outcomes),
   **And** the full quality-gate set (`pnpm -w typecheck` + `pnpm -w lint` + `pnpm format:check` + `pnpm exec commitlint --from origin/main --to HEAD --verbose` + `pnpm exec prek run --all-files`) remains green across the branch at Task 3.

## Tasks / Subtasks

- [ ] **Task 1: Add the `commitlint` commit-msg hook to `.pre-commit-config.yaml` + update `prepare` to install both hook types** (AC: 1, 5)
  - [ ] Edit `.pre-commit-config.yaml` at repo root. Append a 4th hook entry inside the existing `repo: local` block. Exact shape:
    ```yaml
        - id: commitlint
          name: commitlint (conventional commits)
          entry: pnpm exec commitlint --edit
          language: system
          stages: [commit-msg]
    ```
    **Why `stages: [commit-msg]`?** The default stage list is `[pre-commit]`; commit-msg hooks MUST declare the stage explicitly or they'd run at pre-commit time (where they'd silently no-op since there's no commit message yet). [Source: pre-commit docs § stages.]
    **Why `entry: pnpm exec commitlint --edit` (default `pass_filenames: true`)?** For commit-msg stage hooks, pre-commit/prek automatically pass the commit-message file path as the last positional argument. `--edit` tells commitlint "read the commit message from the file named by the next positional arg, not stdin." The final invocation prek makes is `pnpm exec commitlint --edit <path-to-COMMIT_EDITMSG>` — exactly what commitlint's commit-msg-hook canonical pattern specifies. [Source: `commitlint --help`; `@commitlint/cli` § Hooks.] **Do NOT set `pass_filenames: false`** — that would strip the file path, forcing commitlint to fall back to `./.git/COMMIT_EDITMSG`, which is fragile under git worktrees where `.git` is a pointer file.
    **Why NOT `language: node`?** Same reasoning as Story 1.4's three existing hooks — `language: system` delegates to the shell's `PATH`, which `pnpm exec` already resolves correctly against `node_modules/.bin/`. No second node environment needed.
  - [ ] Edit root `package.json` scripts. Change `"prepare": "prek install"` → `"prepare": "prek install -t pre-commit -t commit-msg"`. **Why explicit hook-type flags?** `prek install` with no `-t` defaults to `pre-commit` only — the commit-msg shim is NOT installed without the explicit flag. Passing both keeps the pre-commit shim installed (idempotent re-install) AND installs the commit-msg shim. [Source: `prek install --help`; verified 2026-04-19.]
  - [ ] Run `pnpm install` to exercise `prepare`. Expect two files afterward in the MAIN repo's `.git/hooks/` (shared across worktrees per Story 1.4 note): `.git/hooks/pre-commit` (from Story 1.4) and the new `.git/hooks/commit-msg`. Verify:
    ```bash
    ls -la /workspace/ralph-bmad/.git/hooks/commit-msg
    head -5 /workspace/ralph-bmad/.git/hooks/commit-msg
    ```
    Expect the file to be executable and to be a short shell script that invokes `prek hook-impl --hook-type=commit-msg ... "$@"` (the `$@` passes the commit-msg file path through). Prek's hook script may contain a worktree-specific absolute path to the `prek` binary with a `PATH` fallback — same pattern as the pre-commit shim. Idempotent: re-running `pnpm install` overwrites with no change.
  - [ ] **Self-verification probe (dev loop, not committed):**
    ```bash
    # Valid message fixture via prek's runner (commitlint subpath resolution check)
    echo 'fix: smoke test' > /tmp/msg-ok.txt
    pnpm exec prek run --stage commit-msg --files /tmp/msg-ok.txt commitlint 2>&1
    echo "valid-exit=$?"   # expect 0

    # Invalid message fixture
    echo 'Fixed stuff' > /tmp/msg-bad.txt
    pnpm exec prek run --stage commit-msg --files /tmp/msg-bad.txt commitlint 2>&1
    echo "invalid-exit=$?" # expect non-zero
    ```
    This confirms: (a) the hook id resolves, (b) commitlint loads `commitlint.config.js` → `@keel/keel-invariants/commitlint` → `@commitlint/config-conventional` + keel rule overrides (Story 1.2 Task 5: `subject-case: [0]`, `header-max-length: 120`, `body-max-line-length: [0]`), (c) valid/invalid fixtures behave as AC 2/3 predict. Do NOT commit the fixture files.
  - [ ] Quality gates:
    - `pnpm -w typecheck` — expect FULL TURBO (16/16 cached). The change in this task touches only `package.json` (one script edit, no devDep change) and `.pre-commit-config.yaml` (one hook entry added). Neither is a typecheck input; cache survives. **Contrast with Story 1.4 Task 1** where `package.json` added a devDep and was turbo-cache-safe — here the edit is even smaller (one script field). Same property.
    - `pnpm -w lint` — same reasoning, FULL TURBO.
    - `pnpm format:check` — exit 0. The YAML insertion must preserve Prettier-compatible shape (2-space indent, continuing the existing `hooks:` list). Root `package.json` edit stays JSON-valid with trailing newline.
    - `pnpm exec commitlint --from origin/main --to HEAD --verbose` — 0/0 across existing branch commits (spec commit + iteration-1 bootkeeping; both follow `docs(story):` / `chore(ralph):` conventional form).
  - [ ] Commit: `feat(invariants): Story 1.5 Task 1 — wire commit-msg hook + prepare installs commit-msg shim`. Include IP + RALPH.md upkeep in the same commit per step 3a of the build prompt.

- [ ] **Task 2: ATDD smoke probes — valid commit accepts (AC 2), invalid commit rejects (AC 3), author-parity note (AC 4)** (AC: 2, 3, 4)
  - [ ] These probes exercise the real git-hook path (not `prek run`) so the evidence covers git → `.git/hooks/commit-msg` → prek → commitlint end-to-end. Each probe stages a trivial change, attempts `git commit -m '…'`, observes the outcome, cleans up. Every probe's tree state matches the Task-1 tip before AND after.
  - [ ] **AC 2 probe — valid conventional message lands.**
    ```bash
    # Create a probe-safe artefact (path under .prettierignore, not a TS/lint input).
    echo 'Story 1.5 Task 2 AC 2 probe — delete on cleanup.' > _bmad-output/__ac2-probe.txt
    git add _bmad-output/__ac2-probe.txt
    git commit -m 'fix: resolve edge case in token emitter' 2>&1 | tee /tmp/s15-ac2.out
    echo "exit=$?"   # expect 0
    git log -1 --oneline
    # Roll back — we don't want the throwaway commit on the branch.
    git reset --hard HEAD~1
    # Probe file is removed by the reset. Verify:
    [ ! -f _bmad-output/__ac2-probe.txt ] && echo 'AC 2 probe clean'
    ```
    Expect: `git commit` exits 0; `/tmp/s15-ac2.out` shows all 3 pre-commit hook steps (`typecheck` / `lint` / `format-check`) and the commit-msg step (`commitlint`) all `Passed`; the commit lands; `git reset --hard HEAD~1` restores to branch tip. **Important:** `git reset --hard` removes the probe commit AND the probe file in one step — safer than `--mixed` here because the file only existed for this probe.
  - [ ] **AC 3 probe — invalid message rejects.**
    ```bash
    echo 'Story 1.5 Task 2 AC 3 probe — delete on cleanup.' > _bmad-output/__ac3-probe.txt
    git add _bmad-output/__ac3-probe.txt
    git commit -m 'Fixed stuff' 2>&1 | tee /tmp/s15-ac3.out
    echo "exit=$?"   # expect non-zero
    git log -1 --oneline   # expect unchanged (still at Task-1 tip)
    # Clean up staged probe file (commit didn't land, so no reset needed).
    git reset HEAD _bmad-output/__ac3-probe.txt
    rm -f _bmad-output/__ac3-probe.txt
    ```
    Expect: `git commit` exits 1; `/tmp/s15-ac3.out` shows all 3 pre-commit hooks `Passed` (message quality is independent of source state), then the `commitlint` commit-msg hook `Failed` with output referencing `type-empty` and/or `subject-empty` from `@commitlint/config-conventional`. Message contains `<type>(<scope>): <subject>` convention hint (commitlint's default error shape includes the `type-empty` message "type may not be empty"). No commit on branch.
  - [ ] **AC 4 probe — author-parity note.** No active probe runs in this step; AC 4 is structural. The Task-1 + Task-2 commits on this branch (made by Ralph via `git commit`) AND any user's own commits would both hit the same `.git/hooks/commit-msg` shim — git invokes `.git/hooks/commit-msg` with no conditionals on committer identity, user name, or environment. The hook exercises the same commitlint config, same rules, same exit criteria for everyone. Record this logical argument in Debug Log References when Task 2 lands. **Devbox-path half** (epic AC 4 second clause: "whether commits originate inside the devbox or on the host") cannot be probed — Epic 2 delivers the devbox. Structural-only note for this story.
  - [ ] Capture each probe's output in Debug Log References. If AC 2 or AC 3 probe produces unexpected output, **loop back to Task 1** (hook wiring issue). Document any loop-back in Completion Notes List.
  - [ ] Post-probe tree check: `git status` clean; `git log --oneline origin/main..HEAD` unchanged from pre-probe count; `ls _bmad-output/__ac*-probe.txt 2>/dev/null` empty.
  - [ ] Quality gates (defensive re-run after probe cleanup):
    - `pnpm -w typecheck` — FULL TURBO (no inputs touched).
    - `pnpm -w lint` — FULL TURBO.
    - `pnpm format:check` — exit 0.
    - `pnpm exec commitlint --from origin/main --to HEAD` — 0/0 across all branch commits.
  - [ ] Commit: `feat(invariants): Story 1.5 Task 2 — ATDD probes verify commit-msg hook fires + rejects non-conventional messages`.

- [ ] **Task 3: Full quality-gate verification + sprint-status bump** (AC: 5)
  - [ ] `pnpm install` — expect `Lockfile is up to date`; `prepare` re-runs idempotently (hooks already in place).
  - [ ] `pnpm -w typecheck` — expect 16/16 `>>> FULL TURBO` on FIRST call (no TS inputs moved across Tasks 1/2).
  - [ ] `pnpm -w lint` — expect 16/16 `>>> FULL TURBO` on FIRST call.
  - [ ] `pnpm format:check` — `All matched files use Prettier code style!` exit 0.
  - [ ] `pnpm exec commitlint --from origin/main --to HEAD --verbose` — 0 problems / 0 warnings across all branch commits (spec + iteration-1 bookkeeping + Task 1 + Task 2 = 4 commits).
  - [ ] `pnpm exec prek run --all-files` — runs the 3 pre-commit hooks against the tree; expect all 3 `Passed`. The commit-msg hook is NOT run by `--all-files` (it's a different stage) — parity for commit-msg was confirmed in Task 1's self-verification probe + Task 2's AC 2/3 probes via real `git commit`. No additional commit-msg probe needed here.
  - [ ] Update `_bmad-output/implementation-artifacts/sprint-status.yaml`: flip `1-5-conventional-commit-enforcement-via-commitlint-prek: ready-for-dev → done`; bump `last_updated`. Land this BEFORE the PR Draft→Open transition — prevents the orphan-bookkeeping risk documented in RALPH.md Lessons 2026-04-19 "Post-halt bookkeeping commits can orphan from main" (Stories 1.2/1.3/1.4 precedents).
  - [ ] Commit: `feat(invariants): Story 1.5 Task 3 — all quality gates green + sprint-status bump`.

## Dev Notes

### Relevant architecture patterns and constraints

**Pre-commit Tier 1 composition — commit-msg is the companion stage to pre-commit.** Story 1.4 landed 3 pre-commit-stage hooks (typecheck / lint / format-check). Story 1.5 adds the 4th hook at a different stage (`commit-msg`). Both run on every `git commit`; the only difference is the trigger point (pre-commit runs first against staged files, commit-msg runs after with the composed message). Architecture.md §679 names `commitlint` in the pre-commit-tier stack alongside prek + ESLint + TypeScript; this story wires the commitlint piece via prek's commit-msg stage. [Source: architecture.md lines 77, 679; pre-commit docs § hooks for commit-msg stage.]

**Single `.pre-commit-config.yaml`; single `repo: local` block.** Adding a 4th hook entry to the existing config block is the minimum-diff change. No new config files; no subpath-export in `packages/keel-invariants/`. The root `commitlint.config.js` shim (Story 1.2 Task 6) already routes to `@keel/keel-invariants/commitlint` which exports the keel rules on top of `@commitlint/config-conventional`. Commitlint auto-discovers `commitlint.config.js` at repo root — no config flag needed in the hook entry. [Source: `_bmad-output/implementation-artifacts/1-2-…-shared-eslint-prettier-commitlint-configs.md` § Task 5/6; `@commitlint/cli` § configuration resolution.]

**`prek install -t pre-commit -t commit-msg` vs. post-install hook.** Prek's install command writes one git shim per hook type. Default install is pre-commit only. Passing both `-t` flags installs both shims in a single invocation — idempotent (re-running is a no-op after the first install). The alternative (`prek install --hook-type pre-commit && prek install --hook-type commit-msg`) is two process invocations; both flags in one call is cleaner. [Source: `prek install --help`; verified 2026-04-19.]

**`--edit` + default `pass_filenames` for commit-msg hooks.** Pre-commit framework auto-passes the commit-msg file path as the last positional argument to commit-msg-stage hooks. `--edit` is commitlint's flag for "read the message from a file, not stdin." Together, `entry: pnpm exec commitlint --edit` + `pass_filenames: true` (the default, not declared in the hook entry) yields `pnpm exec commitlint --edit <path>` at hook invocation time. The alternative `entry: pnpm exec commitlint --edit $1` with manual `$1` referencing would only work in a shell-invoked context — prek doesn't expand `$1`, and over-specifying is fragile. Trust the framework's default. [Source: commitlint § CLI; pre-commit.com § supported hooks commit-msg.]

**No new devDeps.** `@commitlint/cli@20.5.0` + `@commitlint/config-conventional@20.5.0` + `@j178/prek@0.3.9` were pinned in Stories 1.2 and 1.4 respectively. This story reuses all three — only wiring changes.

### Source tree components to touch

**Modified (Task 1):**
- `.pre-commit-config.yaml` — append 4th hook entry `id: commitlint` with `stages: [commit-msg]`. Same `repo: local` block; no new `repos:` entry.
- `package.json` (root) — one-line script edit: `"prepare": "prek install -t pre-commit -t commit-msg"`. Preserve JSON shape / trailing newline.

**Created by `prek install` (NOT committed — `.git/` is not tracked):**
- `.git/hooks/commit-msg` — prek-generated shell wrapper. Regenerated on every `pnpm install`. Fresh clones re-create via `prepare`.

**Modified (Task 3):**
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — flip `1-5-conventional-commit-enforcement-via-commitlint-prek: ready-for-dev → done`; bump `last_updated`.

**Unchanged across the story:** every per-package `eslint.config.js` (Story 1.3); every per-package `tsconfig.json` (Story 1.1); `packages/keel-invariants/{eslint,prettier,commitlint,tsconfig}.*` (Story 1.2); every `src/*.ts` file; `turbo.json`; `pnpm-workspace.yaml`; root `eslint.config.js` / `prettier.config.js` / `commitlint.config.js` / `.prettierignore` (all from Story 1.2 Task 6).

### Testing standards summary

**No unit / integration `.test.ts` files land in Story 1.5.** Consistent with Stories 1.2 / 1.3 / 1.4 — the test surface IS the quality gates themselves, plus ATDD probes that fire real `git commit` against valid/invalid messages. Verification evidence lands in Debug Log References.

**ATDD red phase is implicit in the Task 1 dev loop.** BEFORE the commit-msg hook is wired (Task 1 not yet committed), `git commit -m 'Fixed stuff'` succeeds (no hook → no gate). After Task 1, the same invalid commit attempt fails at the commit-msg stage. The red→green transition is the proof. Task 2 exercises this deliberately via AC 3 probe.

**Budget expectations.** Commitlint on a single commit message is sub-100ms (in-process node parse; no subprocesses, no file I/O beyond the message file). Adding commit-msg to the pre-commit tier budget (≤10 s per architecture.md §77) is negligible — the pre-commit hooks (typecheck + lint + format-check at ≤1 s FULL TURBO) remain the dominant term.

### Project Structure Notes

**Alignment with unified project structure:**
- ✅ Hook entry colocated with existing `repo: local` hooks in repo-root `.pre-commit-config.yaml` — no fragmentation.
- ✅ Commitlint config resolution flows through Story 1.2's established chain: `commitlint.config.js` (root shim) → `@keel/keel-invariants/commitlint` → `@commitlint/config-conventional` + keel rule overrides. Single source of truth preserved.
- ✅ `prepare` lifecycle script continues to be the hook-installation entrypoint; no new install step for fork operators.

**Detected conflicts or variances:**
- **Variance (inherited from Story 1.4) — config lives at repo root, not at `.prek/hooks.yaml` or `packages/keel-invariants/src/prek-hooks.yaml` as architecture.md lines 802/894 envisioned.** Story 1.4 established this variance; Story 1.5 simply extends the same root file. Story 1.8's manifest will anchor the file via content hash; Story 1.6's bypass-prevention gate detects unauthorised edits.
- **Variance — AC 4 devbox-parity half is structurally-only.** Epic AC 4 says "enforcement holds whether commits originate inside the devbox or on the host." The devbox is Epic 2 scope (backlog). Story 1.5 proves agent-vs-human parity via the hook's unconditional invocation; devbox-inside parity is structurally implied (git's hook dispatch is environment-agnostic) and will be re-verified when the devbox lands. Not a spec deviation — a scope deferral documented here.
- **Variance — AC 5 (prek-runner parity) is a stronger form than AC 6 of Story 1.4.** Story 1.4 AC 6 ran `pnpm exec prek run --all-files <id>` (pre-commit stage default). Commit-msg hooks aren't covered by `--all-files` — that flag iterates repo files, but commit-msg needs a single message file. Story 1.5 AC 5's probe uses `prek run --stage commit-msg --files /tmp/<msg-file> commitlint` instead, which is the stage-specific equivalent. Same evidence spirit (same hook, same config, direct runner invocation vs. git invocation), different flag.

### Previous Story Intelligence (from Stories 1.1–1.4)

**Files / patterns Story 1.5 builds on:**
- `.pre-commit-config.yaml` (Story 1.4 Task 1) — extends the `hooks:` list with one new entry. No shape change to the file's top-level structure.
- Root `package.json` `prepare` script (Story 1.4 Task 1) — extends from `prek install` to `prek install -t pre-commit -t commit-msg`. No devDep changes.
- Root `commitlint.config.js` shim (Story 1.2 Task 6) — unchanged; the commit-msg hook invokes `pnpm exec commitlint` which auto-discovers this file.
- `packages/keel-invariants/commitlint.config.keel-invariants.js` (Story 1.2 Task 5) — unchanged; 3-key rule overrides remain (`subject-case: [0]`, `header-max-length: [2, always, 120]`, `body-max-line-length: [0]`).
- Prek install semantics (Story 1.4 Task 1 carry-forward note in RALPH.md) — git-worktrees share hooks via MAIN repo's `.git/hooks/`; prek writes absolute paths with PATH fallback. Story 1.5's commit-msg shim inherits this behaviour.

**Landmines Stories 1.2–1.4 hit (RALPH.md Lessons 2026-04-19) that could recur:**
- **Commitlint rule defaults can break Ralph's commit style.** Fixed in Story 1.2 Task 5 via 3-key rule overrides. Already vetted: all Story 1.1–1.4 commit messages pass current config. Task 1's own commit (`feat(invariants): Story 1.5 Task 1 — …`) fits comfortably under the 120-char header cap. [Source: `packages/keel-invariants/commitlint.config.keel-invariants.js`.]
- **Multi-commit story PRs drift PR metadata from reality.** Story 1.5 expects ~5 commits (spec + iter-1 bookkeeping + Tasks 1–3). Before `gh pr ready`, rewrite PR title/body per Stories 1.1–1.4 precedent (RALPH.md "Multi-commit story PRs drift PR metadata from reality" — 4× confirmed as load-bearing).
- **Post-halt bookkeeping orphan risk.** Land sprint-status update in Task 3's commit, not a separate post-transition `chore(sprint):` bump. Stories 1.2/1.3/1.4 all applied this pre-emptively. Story 1.5 follows suit.
- **Worktree-specific absolute paths in prek shims.** Prek's hook scripts bake in an absolute path to the current worktree's `node_modules/.pnpm/.../prek` binary, with `PATH` fallback. If another worktree runs `pnpm install`, the path is overwritten — still functionally correct because of the PATH fallback. Benign for Story 1.5 just like for Story 1.4.
- **Turbo cache sensitivity to `package.json` edits.** This story's `package.json` edit is strictly the `prepare` script value, not a dependency change. `package.json` itself IS a turbo input for most tasks, so in principle the cache could invalidate. **Observation from Story 1.4 Task 1 RALPH.md note:** turbo's typecheck + lint task inputs declare `**/*.ts`, `**/*.tsx`, `tsconfig*.json`, `eslint.config.*` — but `package.json` may or may not be declared depending on the task shape (Story 1.4 observed cache SURVIVING a `package.json` devDep add). If cache invalidates here, a cold run is the one-time cost; subsequent runs warm. Not a blocker; note the observation in Task 1's Debug Log if the first run isn't FULL TURBO.

**Testing approaches validated that Story 1.5 inherits:**
- `git commit` with a temp file + `--hard` reset to roll back clean (Story 1.4 Task 2 AC 5 probe).
- `prek run --stage <stage> --files <file> <id>` for stage-specific probing (commit-msg equivalent of `prek run --all-files <id>`).
- Probe paths under `.prettierignore` (`_bmad-output/*.txt`) to avoid false-positive format-check failures.
- `pnpm exec commitlint --from origin/main --to HEAD` as the repeat branch-history validator.

### Git Intelligence Summary (recent patterns)

Last commits on `feat/story-1-4-pre-commit-quality-gates-via-prek-type-check-lint-format` (merged via PR #220 as commit `8efa65b`):
- `a7717a2 chore(ralph): Story 1.4 SHIPPED — PR #220 Draft→Open, EPIC_DONE halt`
- `c8880f4 feat(invariants): Story 1.4 Task 3 — all quality gates green + sprint-status bump`
- `aa6cbb7 feat(invariants): Story 1.4 Task 2 — ATDD smoke probes verify prek hooks fire + parity`
- `3450924 feat(invariants): Story 1.4 Task 1 — wire prek pre-commit config + prepare script`
- `26be581 chore(ralph): Story 1.4 iteration 1 — IP reflects Draft PR #220 creation`

Convention: `feat(invariants): Story X.Y Task N — <summary>`. Story 1.5 follows the same scope (`invariants`, since the commit-msg hook gates a substrate invariant — conventional-commit format — authored in `packages/keel-invariants/` by Story 1.2). One task per commit.

### Latest Technical Information

- **`@j178/prek@0.3.9`** — current stable. Reused from Story 1.4; no version change. `prek install -t <hook-type>` supported in this version. `prek run --stage <stage> --files <file>` supported too. [Source: `prek install --help`; `prek run --help`; verified 2026-04-19.]
- **`@commitlint/cli@20.5.0` + `@commitlint/config-conventional@20.5.0`** — pinned in Story 1.2 Task 2. Reused; no change. `commitlint --edit <file>` is the commit-msg-hook canonical flag combo. [Source: `commitlint --help`.]
- **`.pre-commit-config.yaml` stages field** — pre-commit v3+ introduced the `stages:` array on hooks. Prek supports this identically. Default if omitted: `[pre-commit]`. [Source: pre-commit.com § stages.]

### References

- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.5, lines 777–801] — Story 1.5 AC (authoritative scope; 4 ACs mirrored here with one expanded AC 5 for prek-runner parity evidence).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.4, lines 746–775] — Story 1.4 scope (immediately prior; prek stack this story extends).
- [Source: `_bmad-output/planning-artifacts/epics.md`#Epic-1-Story-1.6, lines 803–828] — Bypass-prevention scope (next story; consumes this story's hook as part of the manifested invariant set).
- [Source: `_bmad-output/planning-artifacts/architecture.md`#CI-pyramid, lines 77, 145] — 5-tier CI pyramid with pre-commit ≤10 s; commitlint named in Tier 1.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Pre-commit-hooks, line 679] — "Pre-commit (≤10s): prek + commitlint + ESLint + TypeScript changed-files + prompt-injection regex (S4) + bare-string + ARIA lint + token-drift check." Story 1.5 lands the commitlint piece.
- [Source: `_bmad-output/planning-artifacts/architecture.md`#Hardwired-stack, line 71] — prek + commitlint in the pinned stack.
- [Source: `_bmad-output/planning-artifacts/prd.md`#FR14] — Machine-enforced conventional-commit discipline as a substrate invariant.
- [Source: `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`] — Story 1.2 established commitlint config + subpath export + root shim.
- [Source: `_bmad-output/implementation-artifacts/1-4-pre-commit-quality-gates-via-prek-type-check-lint-format.md`] — Story 1.4 established prek stack + `.pre-commit-config.yaml` at repo root + `prepare: prek install` convention.
- [Source: `RALPH.md`#Signposts-2026-04-19] — Story 1.4 SHIPPED; all Stories 1.1–1.4 landmines apply here.
- [Source: <https://github.com/j178/prek>] — prek README; `install -t <hook-type>` + `run --stage <stage>` semantics.
- [Source: <https://pre-commit.com/#pre-commit-configyaml---hooks>] — pre-commit docs § hooks § stages § commit-msg.
- [Source: <https://commitlint.js.org/#/reference-cli>] — commitlint CLI `--edit` flag + commit-msg hook pattern.

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (1M context) via Ralph build loop; one task per iteration across three implementation iterations (Tasks 1 → 2 → 3).

### Debug Log References

_(populated during Tasks 1 / 2 / 3 as each lands)_

### Completion Notes List

_(populated during Tasks 1 / 2 / 3 as each lands)_

### File List

_(populated during Tasks 1 / 2 / 3 as each lands)_
