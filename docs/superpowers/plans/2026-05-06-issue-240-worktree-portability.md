# Issue #240 Worktree-Portability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix two related worktree-portability bugs in keel's git-hook handling stack so `INV-git-hooks-preservation` passes from a worktree commit, eliminating operator pressure to bypass the SECURITY-CRITICAL gate via `--no-verify` or `SKIP=keel-invariants-check`.

**Architecture:** (1) Replace hardcoded `<repoRoot>/.git/hooks` path in `sync-gate.ts` with a `git rev-parse --git-common-dir`-based resolver. (2) Delegate the npm `prepare` lifecycle to a new `scripts/prepare-prek.mjs` that no-ops from worktrees so worktree-local PREK absolute paths can't corrupt the shared `<commondir>/hooks/` bodies. (3) Register the new guard script as a substrate invariant so future PRs cannot silently weaken it.

**Tech Stack:** TypeScript (workspace + ESLint + Prettier), Vitest (testing), pnpm + Turborepo (monorepo), prek (pre-commit framework), Node 20.x ESM.

**Spec:** `docs/superpowers/specs/2026-05-06-issue-240-worktree-portability-design.md`

---

## L1-Protection Constraint (CRITICAL — read before starting)

The `.claude/hooks/block-secret-access.sh` install-boundary hook denies in-session AI-agent edits to:

- `packages/keel-invariants/src/sync-gate.ts`
- `packages/keel-invariants/src/invariants.manifest.ts`

Tasks 8 and 9 in this plan are **HUMAN CHECKPOINTS** — the implementing agent **cannot** apply these diffs and must escalate to the user. Every other task is in-session-doable.

The plan is sequenced so all in-session work lands first, then a single human checkpoint handles all L1-protected edits in one batch, then in-session verification + PR finalization completes.

---

## File Structure

| File | Status | Responsibility |
|---|---|---|
| `scripts/prepare-prek.mjs` | **NEW** | npm `prepare` delegate: runs `prek install` only from main checkout, skips from worktrees. |
| `package.json` | Modify (`prepare` script value, line ~44) | Switch `prepare` to delegate to the new mjs. |
| `INVARIANTS.md` | Modify (insert anchor under "prek pre-commit config" section) | Human-readable index — add `INV-prek-prepare-worktree-guard` anchor. |
| `docs/invariants/claude-hook-denylist.md` | Modify (append subsection) | Doc the worktree-portability resolver pattern for future invariant authors. |
| `packages/keel-invariants/src/__tests__/sync-gate.test.ts` | Modify (append `describe`) | Regression test for `resolveCommonHooksDir`. |
| `packages/keel-invariants/src/sync-gate.ts` | **L1 — HUMAN ONLY** (Task 8) | Add + export `resolveCommonHooksDir` helper, replace line 188, append to `EXPECTED_INVARIANT_IDS`. |
| `packages/keel-invariants/src/invariants.manifest.ts` | **L1 — HUMAN ONLY** (Task 9) | Add new `INV-prek-prepare-worktree-guard` entry, refresh `INV-prek-prepare-lifecycle.contentHash`. |

---

## Task 1: Branch + scaffold

**Files:**
- (no files yet — this is the worktree/branch setup task)

- [ ] **Step 1: Confirm baseline state**

Run from main repo working tree:

```bash
git status
git rev-parse --abbrev-ref HEAD
```

Expected: clean tree (or only the in-progress design + plan docs from the brainstorming session). Branch is `main` or `docs/issue-240-worktree-portability-spec` (the spec branch — that's fine, we'll branch from there or from main).

- [ ] **Step 2: Create implementation branch**

```bash
git checkout main
git pull --ff-only
git checkout -b fix/issue-240-worktree-portability
```

- [ ] **Step 3: Confirm working pre-commit baseline**

```bash
pnpm install
pnpm --filter @keel/keel-invariants build
pnpm keel-invariants:check
```

Expected: all exit 0, no drift.

If `keel-invariants:check` fails on `INV-git-hooks-preservation` with `git-hook-missing` (this can happen if a stale worktree previously corrupted `.git/hooks/pre-commit`), run `pnpm install` from the main checkout once more — the existing `prek install` rewrites the hooks correctly when invoked from the main checkout. Then re-run `keel-invariants:check`.

If still failing, halt and surface the issue — the bug-fix branch must start from a clean baseline.

---

## Task 2: Write the regression test (RED)

**Files:**
- Modify: `packages/keel-invariants/src/__tests__/sync-gate.test.ts` (append new `describe` block at end)

- [ ] **Step 1: Add regression test block to sync-gate.test.ts**

Append the following at the end of the file (after the closing `});` of the existing `describe`):

```ts
describe('resolveCommonHooksDir worktree portability (issue #240)', () => {
  it('resolves to <commondir>/hooks when invoked from a worktree off a real git repo', async () => {
    const { execFileSync } = await import('node:child_process');
    const { resolve: resolvePath } = await import('node:path');

    const root = await mkdtemp(join(tmpdir(), 'keel-syncgate-wt-'));
    try {
      execFileSync('git', ['init', '-q', '--initial-branch=main'], { cwd: root });
      execFileSync('git', ['config', 'user.email', 'test@example.com'], { cwd: root });
      execFileSync('git', ['config', 'user.name', 'test'], { cwd: root });
      execFileSync('git', ['config', 'commit.gpgsign', 'false'], { cwd: root });
      await writeFile(join(root, 'README.md'), '# fixture\n');
      execFileSync('git', ['add', 'README.md'], { cwd: root });
      execFileSync('git', ['commit', '-q', '-m', 'init'], { cwd: root });

      const wtRoot = join(root, 'wt');
      execFileSync('git', ['worktree', 'add', '-q', '-b', 'test/worktree', wtRoot], {
        cwd: root,
      });

      const { resolveCommonHooksDir } = await import('../sync-gate.js');

      // From main checkout: <root>/.git/hooks.
      expect(resolveCommonHooksDir(root)).toBe(resolvePath(root, '.git', 'hooks'));
      // From worktree: STILL <root>/.git/hooks (NOT <wtRoot>/.git/hooks which is
      // a non-existent path under the gitlink file).
      expect(resolveCommonHooksDir(wtRoot)).toBe(resolvePath(root, '.git', 'hooks'));

      execFileSync('git', ['worktree', 'remove', '--force', wtRoot], { cwd: root });
    } finally {
      await rm(root, { recursive: true, force: true });
    }
  });

  it('falls back to <repoRoot>/.git/hooks when not in a git repo (test fixture safety)', async () => {
    const { resolve: resolvePath } = await import('node:path');
    const root = await mkdtemp(join(tmpdir(), 'keel-syncgate-nogit-'));
    try {
      const { resolveCommonHooksDir } = await import('../sync-gate.js');
      expect(resolveCommonHooksDir(root)).toBe(resolvePath(root, '.git', 'hooks'));
    } finally {
      await rm(root, { recursive: true, force: true });
    }
  });
});
```

(All required imports — `mkdtemp`, `writeFile`, `rm`, `tmpdir`, `join`, `describe`, `it`, `expect`, `vi`, `beforeEach` — are already present at the top of the file. Do not add new top-level imports.)

- [ ] **Step 2: Build the keel-invariants package**

```bash
pnpm --filter @keel/keel-invariants build
```

Expected: build succeeds (TypeScript check passes; the new test references `resolveCommonHooksDir` from `../sync-gate.js` but only at runtime inside the test, so the build doesn't fail).

- [ ] **Step 3: Run the new test — verify it fails for the right reason**

```bash
pnpm --filter @keel/keel-invariants test sync-gate
```

Expected: the two new tests fail. The failure messages should reference `resolveCommonHooksDir` being `undefined` (or an import-binding error). All other existing tests in the file continue to pass.

If the failure is a different error (e.g. `git: command not found`, missing test imports), fix the test setup before proceeding — the RED phase only proves what we want to prove if the failure mode is the missing helper.

- [ ] **Step 4: Commit the RED test**

```bash
git add packages/keel-invariants/src/__tests__/sync-gate.test.ts
git commit -m "$(cat <<'EOF'
test(keel-invariants): regression test for resolveCommonHooksDir worktree portability

RED-phase test for issue #240 — proves resolveCommonHooksDir returns the
common-dir-based hooks path from both main checkout and worktree, falling
back to <repoRoot>/.git/hooks when not in a git repo.

Currently fails: the helper does not exist yet. Will go GREEN once
sync-gate.ts exports resolveCommonHooksDir (Task 8, L1-protected — human).
EOF
)"
```

---

## Task 3: Create `scripts/prepare-prek.mjs`

**Files:**
- Create: `scripts/prepare-prek.mjs`

- [ ] **Step 1: Write the script**

Create `scripts/prepare-prek.mjs` with this exact content:

```js
#!/usr/bin/env node
// Run `prek install` only when invoked from the main repo checkout, not from
// a worktree. From a worktree, `prek install` would overwrite the shared
// .git/hooks/<name> bodies with a worktree-local PREK absolute path, which
// becomes stale on worktree cleanup and races between concurrent worktrees.
//
// The contract: if `git rev-parse --git-common-dir` resolves to <cwd>/.git,
// we are in the main checkout — install. Otherwise we are in a worktree (or
// outside a git repo entirely) — skip.
//
// This script is registered as `INV-prek-prepare-worktree-guard` (whole-file
// SHA-256). Editing it requires AMEND-path mechanics: refresh the manifest
// contentHash + INVARIANTS.md anchor in the same PR.

import { execFileSync, spawnSync } from 'node:child_process';
import { resolve } from 'node:path';

let commonDir;
try {
  commonDir = execFileSync('git', ['rev-parse', '--git-common-dir'], {
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'ignore'],
  }).trim();
} catch {
  // Not a git repo (e.g. tarball install). Skip.
  process.exit(0);
}

const resolvedCommon = resolve(commonDir);
const mainCommon = resolve('.git');

if (resolvedCommon !== mainCommon) {
  // Worktree (or non-standard layout). Skip — the main checkout owns the hook bodies.
  console.log(`[prepare-prek] skipping: not in main checkout (commondir=${resolvedCommon}).`);
  process.exit(0);
}

const result = spawnSync('prek', ['install', '-t', 'pre-commit', '-t', 'commit-msg'], {
  stdio: 'inherit',
});
process.exit(result.status ?? 0);
```

- [ ] **Step 2: Mark the script executable**

```bash
chmod +x scripts/prepare-prek.mjs
```

- [ ] **Step 3: Manually verify behavior from main checkout**

```bash
node scripts/prepare-prek.mjs
```

Expected: prints prek's install output (something like `prek installed at .git/hooks/pre-commit` and `commit-msg`), exits 0.

- [ ] **Step 4: Manually verify behavior from a worktree**

```bash
git worktree add /tmp/keel-verify-prepare-prek -b chore/verify-prepare-prek main
cd /tmp/keel-verify-prepare-prek
node scripts/prepare-prek.mjs
echo "exit code: $?"
cd -
git worktree remove --force /tmp/keel-verify-prepare-prek
git branch -D chore/verify-prepare-prek
```

Expected: the script prints `[prepare-prek] skipping: not in main checkout (commondir=/workspace/keel/.git).` and exits 0. (The path may differ on your host but must point at the main repo's `.git/`, not the worktree's.)

If the script does NOT skip (i.e. it tries to run `prek install` from the worktree), there is a bug — investigate before continuing. The most likely cause is path normalization differences between `resolve('.git')` and `resolve(commonDir)` on the host platform; the fix is to compare normalized canonical paths via `realpath`.

---

## Task 4: Wire `package.json` to delegate `prepare`

**Files:**
- Modify: `package.json` (line ~44, the `prepare` entry under `scripts`)

- [ ] **Step 1: Edit `package.json`**

Replace the `"prepare"` script value:

```diff
-    "prepare": "prek install -t pre-commit -t commit-msg"
+    "prepare": "node scripts/prepare-prek.mjs"
```

- [ ] **Step 2: Verify the edit by re-running `pnpm install`**

```bash
pnpm install
```

Expected: pnpm install runs normally; the `prepare` lifecycle now invokes `node scripts/prepare-prek.mjs` which prints prek's normal install output (since we're in the main checkout) and completes cleanly.

- [ ] **Step 3: Verify the shared hooks dir was rewritten correctly**

```bash
grep PREK= /workspace/keel/.git/hooks/pre-commit
```

Expected: shows a line like `PREK="/workspace/keel/node_modules/.pnpm/@j178+prek@0.3.9/.../prek"` — pointing at the **main** checkout's `node_modules/`, not a worktree's. (Pre-fix, this might have been pointing at a now-defunct `.claude/worktrees/agent-*` path; the main-checkout `pnpm install` fixes it.)

- [ ] **Step 4: Compute the SHA-256 of the new files (needed by the human in Task 9)**

```bash
sha256sum scripts/prepare-prek.mjs package.json
```

Note both hashes. Save them somewhere visible to the user (echo them as part of the PR draft body, or just paste them into the chat). **The human in Task 9 needs these values verbatim** — they cannot run this command from inside their L1-protected diff workflow if it's an out-of-session script.

- [ ] **Step 5: Commit prepare-prek + package.json together**

```bash
git add scripts/prepare-prek.mjs package.json
git commit -m "$(cat <<'EOF'
fix(prek): skip prepare-lifecycle prek install from worktrees (issue #240)

Replaces the inline `prek install` in package.json's prepare script with
a node delegate at scripts/prepare-prek.mjs that no-ops when invoked from
a worktree (commondir != cwd/.git). Prevents worktree-local PREK absolute
paths from corrupting the shared <commondir>/hooks/ bodies and racing
between concurrent worktrees.

Per spec section 2 (issue-240-worktree-portability-design.md). The new
script is registered as INV-prek-prepare-worktree-guard in a follow-up
human-applied edit (Task 9, L1-protected).
EOF
)"
```

---

## Task 5: Update `INVARIANTS.md` with the new anchor

**Files:**
- Modify: `INVARIANTS.md` (insert under the "prek pre-commit config (Story 1.4)" section)

- [ ] **Step 1: Locate the insertion point**

Open `INVARIANTS.md` and find the section heading `### prek pre-commit config (Story 1.4)`. Inside that section, after the existing `INV-prek-prepare-lifecycle` bullet, insert the new anchor.

- [ ] **Step 2: Add the new anchor**

Apply this insertion (the line numbers will be near 33-35 of `INVARIANTS.md` but may have drifted; locate by content):

```diff
 - **`INV-prek-prepare-lifecycle`** — root `package.json` `prepare` script installs `prek` shims for both `pre-commit` and `commit-msg` stages via `prek install -t pre-commit -t commit-msg`. Source: `{repo-root}/package.json` (`scripts.prepare`).
+- **`INV-prek-prepare-worktree-guard`** — `scripts/prepare-prek.mjs` gates `prek install` to the main checkout only; from a worktree the prepare script no-ops to prevent shared-hook-body corruption (issue #240). Source: `scripts/prepare-prek.mjs`.
```

Note: also update the `INV-prek-prepare-lifecycle` description if it now references the new script — but the existing description is still accurate (the prepare script DOES still ultimately invoke `prek install -t pre-commit -t commit-msg`, just via a delegate). Leave it as-is.

- [ ] **Step 3: Verify the intermediate drift state**

```bash
pnpm --filter @keel/keel-invariants build
pnpm keel-invariants:check
```

Expected: drift fires with `removed-from-docs-only` for `INV-prek-prepare-worktree-guard` (the anchor exists but no manifest entry yet) AND `content-hash-mismatch` for `INV-prek-prepare-lifecycle` (package.json changed in Task 4 but contentHash hasn't been refreshed). **This is the correct intermediate state** — both fixes land via the human's manifest edits in Task 9.

**DO NOT commit INVARIANTS.md yet.** A commit attempt right now would be rejected by the pre-commit drift gate, and bypassing with `--no-verify` is exactly the operator-pressure pattern issue #240 is fixing.

- [ ] **Step 4: Stage the change but defer the commit**

```bash
git add INVARIANTS.md
git status
```

Expected: `INVARIANTS.md` shows as staged. Leave it staged. The Task 9 commit will bundle this together with the L1-protected manifest edits, producing one coherent commit where INVARIANTS.md anchor + manifest entry land in lockstep.

---

## Task 6: Add doc subsection to `docs/invariants/claude-hook-denylist.md`

**Files:**
- Modify: `docs/invariants/claude-hook-denylist.md` (append a subsection)

- [ ] **Step 1: Read the current end of the file to find the insertion point**

```bash
tail -20 /workspace/keel/docs/invariants/claude-hook-denylist.md
```

Note the existing section structure to choose a good insertion point. The new subsection should sit after any existing "patterns" or "implementation notes" sections, near the end of the file.

- [ ] **Step 2: Append the new subsection**

Append at end of file (literal content — the outer fence below is quadruple-tick to escape the inner triple-tick code block; copy only the inner content, not the outer fence):

````markdown

## Worktree-portability resolver pattern (issue #240)

The `.git/hooks/` directory lives in `<commondir>` (the main repo's `.git/`), **not** in `<worktree>/.git/` (which is a gitlink file pointing at `<commondir>/worktrees/<name>/`, not a directory). Future invariant authors writing hook-walking checks must resolve the hooks path via:

```ts
import { execFileSync } from 'node:child_process';
import { resolve } from 'node:path';

const commonDir = execFileSync('git', ['rev-parse', '--git-common-dir'], {
  cwd: repoRoot,
  encoding: 'utf8',
}).trim();
const hooksDir = resolve(repoRoot, commonDir, 'hooks');
```

**Do NOT** write `resolve(repoRoot, '.git/hooks')` — that path is a non-existent file when `repoRoot` is a worktree. Pre-fix, this caused `INV-git-hooks-preservation` to false-positive `git-hook-missing` for every enumerated hook in `EXPECTED_HOOKS` from any worktree commit, training operators to bypass the SECURITY-CRITICAL gate.

The canonical implementation is `resolveCommonHooksDir` in `packages/keel-invariants/src/sync-gate.ts`. The fallback to `<repoRoot>/.git/hooks` (when `git rev-parse` throws — e.g. test fixtures with `mkdtemp` but no `git init`) is intentional: it preserves the behavior existing test fixtures rely on.
````

- [ ] **Step 3: Commit the doc update**

```bash
git add docs/invariants/claude-hook-denylist.md
git commit -m "$(cat <<'EOF'
docs(invariants): document worktree-portability resolver pattern (issue #240)

Adds a subsection explaining that hook-walking invariant checks must use
`git rev-parse --git-common-dir` instead of `<repoRoot>/.git/hooks`, since
worktree `.git` is a gitlink file (not a directory). Cross-references the
canonical implementation in sync-gate.ts:resolveCommonHooksDir.
EOF
)"
```

---

## Task 7: Verify in-session work is complete

**Files:**
- (no edits — verification step)

- [ ] **Step 1: Diff against main to confirm the in-session change set**

```bash
git log main..HEAD --oneline
git diff main..HEAD --stat
```

Expected commits (in order):
1. `test(keel-invariants): regression test for resolveCommonHooksDir...`
2. `fix(prek): skip prepare-lifecycle prek install from worktrees...`
3. `docs(invariants): document worktree-portability resolver pattern...`

Plus one staged-but-uncommitted file:
- `INVARIANTS.md` (added by Task 5 Step 4; will be bundled into the human's Task 9 commit so the new anchor + new manifest entry land atomically).

Files touched (none of which are L1-protected):
- `packages/keel-invariants/src/__tests__/sync-gate.test.ts`
- `scripts/prepare-prek.mjs`
- `package.json`
- `INVARIANTS.md` (staged)
- `docs/invariants/claude-hook-denylist.md`

- [ ] **Step 2: Confirm the regression test still RED (it should — Task 8 has not run yet)**

```bash
pnpm --filter @keel/keel-invariants test sync-gate
```

Expected: the two new tests fail with `resolveCommonHooksDir is undefined` (or import-binding error). All other tests pass.

- [ ] **Step 3: Capture state for human handoff**

Write a temporary note (no need to commit) summarizing for the user:

```
Hashes for human checkpoint (Task 9):
- scripts/prepare-prek.mjs SHA-256: <value from Task 4 Step 4>
- package.json SHA-256:             <value from Task 4 Step 4>

Pending L1-protected diffs (Task 8 + Task 9):
- packages/keel-invariants/src/sync-gate.ts        (Task 8)
- packages/keel-invariants/src/invariants.manifest.ts (Task 9)
```

---

## Task 8: HUMAN CHECKPOINT — apply L1-protected `sync-gate.ts` edits

**Files:**
- Modify (HUMAN ONLY — L1 install-boundary): `packages/keel-invariants/src/sync-gate.ts`

The implementing agent **STOPS HERE** and surfaces the diffs below to the user. The agent **must not** attempt to apply these edits — the L1 hook will block the Edit/Write tool, and any attempt will count as adversarial.

- [ ] **Step 1: Insert the resolver helper near the top of `sync-gate.ts`**

After the existing imports (line 1-11) and before the `export type DriftKind = ...` declaration, insert:

```ts
import { execFileSync } from 'node:child_process';

let cachedHooksDir: { repoRoot: string; hooksDir: string } | null = null;

export function resolveCommonHooksDir(repoRoot: string): string {
  if (cachedHooksDir && cachedHooksDir.repoRoot === repoRoot) {
    return cachedHooksDir.hooksDir;
  }
  let hooksDir: string;
  try {
    const commonDir = execFileSync('git', ['rev-parse', '--git-common-dir'], {
      cwd: repoRoot,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    }).trim();
    // commonDir may be relative ('.git') from main or absolute from a worktree.
    hooksDir = resolve(repoRoot, commonDir, 'hooks');
  } catch {
    // Not a git repo (test fixtures, fresh-clone pre-init). Fall back to the
    // pre-fix path so existing test fixtures that mock-mkdir <root>/.git/hooks
    // continue to work.
    hooksDir = resolve(repoRoot, '.git/hooks');
  }
  cachedHooksDir = { repoRoot, hooksDir };
  return hooksDir;
}
```

(The `resolve` import on line 1 is already present and re-used.)

- [ ] **Step 2: Replace the hardcoded path at line 188**

```diff
     // names-and-shebangs: enumerator file read; hook directory walked.
     const enumeratorAbs = resolve(repoRoot, scope.enumeratorPath);
     const expected = await loadExpectedHooks(enumeratorAbs);
-    const hooksDir = resolve(repoRoot, '.git/hooks');
+    const hooksDir = resolveCommonHooksDir(repoRoot);
     const { hash, missing, shebangMismatches } = await computeNamesAndShebangsHash(
       hooksDir,
       expected,
     );
```

- [ ] **Step 3: Append `INV-prek-prepare-worktree-guard` to `EXPECTED_INVARIANT_IDS`**

In the `EXPECTED_INVARIANT_IDS` array (currently lines 65-110), insert immediately after `'INV-prek-prepare-lifecycle',`:

```diff
   'INV-prek-pre-commit-config',
   'INV-prek-prepare-lifecycle',
+  'INV-prek-prepare-worktree-guard',
   'INV-prek-commit-msg-config',
```

- [ ] **Step 4: Build the package and confirm TypeScript types are happy**

```bash
pnpm --filter @keel/keel-invariants build
```

Expected: build succeeds with no TS errors.

(The user — not the agent — runs this command, since the user is the one applying the edits in this checkpoint.)

---

## Task 9: HUMAN CHECKPOINT — apply L1-protected `invariants.manifest.ts` edits

**Files:**
- Modify (HUMAN ONLY — L1 install-boundary): `packages/keel-invariants/src/invariants.manifest.ts`

- [ ] **Step 1: Add the new `INV-prek-prepare-worktree-guard` entry**

Locate the existing `INV-prek-prepare-lifecycle` entry (currently lines 137-144). Immediately after its closing `},`, insert:

```ts
  {
    id: 'INV-prek-prepare-worktree-guard',
    description:
      'Root npm `prepare` lifecycle is delegated to scripts/prepare-prek.mjs which runs `prek install -t pre-commit -t commit-msg` ONLY when `git rev-parse --git-common-dir` resolves to <cwd>/.git (the main checkout). From a worktree the script no-ops, preventing worktree-local PREK absolute-path bake-ins from corrupting the shared <commondir>/.git/hooks/ bodies. Whole-file SHA-256 of scripts/prepare-prek.mjs pins the contract; legitimate edits are AMEND-path. Issue #240.',
    sourcePath: 'scripts/prepare-prek.mjs',
    contentHash: '<paste-the-sha256-from-task-4-step-4>',
    anchors: ['INV-prek-prepare-worktree-guard'],
  },
```

Replace `<paste-the-sha256-from-task-4-step-4>` with the actual `sha256sum scripts/prepare-prek.mjs` output captured in Task 4 Step 4.

- [ ] **Step 2: Refresh the `INV-prek-prepare-lifecycle` contentHash**

In the existing entry at line ~138-144:

```diff
   {
     id: 'INV-prek-prepare-lifecycle',
     description:
       'Root package.json prepare script installs prek shims for both pre-commit and commit-msg stages via prek install -t pre-commit -t commit-msg.',
     sourcePath: 'package.json',
-    contentHash: '9d490e2188d39b06389faee84af84dd81185f9a455a04bac291a1155a7556c5b',
+    contentHash: '<paste-the-sha256-of-package.json-from-task-4-step-4>',
     anchors: ['INV-prek-prepare-lifecycle'],
   },
```

Replace `<paste-...>` with the `sha256sum package.json` output captured in Task 4 Step 4.

(The description is unchanged — the `prepare` script *still* installs prek shims, just via a delegate. The behavioral contract this invariant pins is unchanged.)

- [ ] **Step 3: Build the package and run the drift gate**

```bash
pnpm --filter @keel/keel-invariants build
pnpm keel-invariants:check
```

Expected: exit 0, no drift.

If drift fires on `INV-prek-prepare-lifecycle` with `content-hash-mismatch`: the package.json contents drifted between Task 4 Step 4 (when the hash was captured) and now. Re-run `sha256sum package.json` and update the manifest entry with the new hash.

If drift fires on `INV-prek-prepare-worktree-guard` with `content-hash-mismatch` or `removed-from-source-only`: same diagnosis for `scripts/prepare-prek.mjs`.

- [ ] **Step 4: Stage all L1-protected edits + the deferred INVARIANTS.md**

```bash
git add packages/keel-invariants/src/sync-gate.ts \
        packages/keel-invariants/src/invariants.manifest.ts \
        INVARIANTS.md
git status
```

Expected: three files staged. (The agent staged INVARIANTS.md in Task 5 Step 4 but deliberately did not commit it — this is the moment to bundle it with the L1 edits so the new anchor and the new manifest entry land atomically.)

- [ ] **Step 5: Commit the L1-protected edits**

```bash
git commit -m "$(cat <<'EOF'
fix(keel-invariants): worktree-portable hooks-dir resolver + new substrate invariant (issue #240)

L1-PROTECTED EDIT (sync-gate.ts + invariants.manifest.ts).

Two coordinated changes that together close issue #240:

1. Add `resolveCommonHooksDir` to sync-gate.ts and replace the hardcoded
   `<repoRoot>/.git/hooks` path with a `git rev-parse --git-common-dir`-
   based resolver. From a worktree, `<worktree>/.git` is a gitlink file
   (not a directory), so the pre-fix path was non-existent and every
   enumerated hook rendered as `<MISSING>` — firing `git-hook-missing`
   drift unconditionally and training operators to bypass via
   `git commit --no-verify` or `SKIP=keel-invariants-check`. Fallback
   to the pre-fix path is preserved for non-git test fixtures.

2. Register `INV-prek-prepare-worktree-guard` covering the new
   scripts/prepare-prek.mjs (Task 3-4 in-session work). Whole-file
   SHA-256 contract; AMEND-path edits. Refresh
   INV-prek-prepare-lifecycle.contentHash to match the post-fix
   package.json (the prepare script value changed but the underlying
   prek-install contract is unchanged).

Per docs/superpowers/specs/2026-05-06-issue-240-worktree-portability-design.md
sections 1, 3, 4. Pairs with the in-session work in
docs/superpowers/plans/2026-05-06-issue-240-worktree-portability.md
Tasks 2-6.
EOF
)"
```

---

## Task 10: GREEN — verify the regression test now passes

**Files:**
- (no edits — verification)

The implementing agent resumes here after the human commits Task 8 + 9.

- [ ] **Step 1: Pull the human's commit if needed**

If the agent and human are working in different sessions/checkouts, sync:

```bash
git status
git log -3 --oneline
```

Expected: latest commit is `fix(keel-invariants): worktree-portable hooks-dir resolver...` from Task 9.

- [ ] **Step 2: Build + run the new test**

```bash
pnpm --filter @keel/keel-invariants build
pnpm --filter @keel/keel-invariants test sync-gate
```

Expected: ALL tests pass, including the two from Task 2:
- `resolveCommonHooksDir worktree portability (issue #240) > resolves to <commondir>/hooks when invoked from a worktree off a real git repo`
- `resolveCommonHooksDir worktree portability (issue #240) > falls back to <repoRoot>/.git/hooks when not in a git repo (test fixture safety)`

If the worktree test fails: the resolver helper is mis-implemented (most likely the path-resolution logic confused an absolute commonDir with a relative one). Re-read Task 8 Step 1 against the actual sync-gate.ts contents and fix.

- [ ] **Step 3: Run the full keel-invariants test suite**

```bash
pnpm --filter @keel/keel-invariants test
```

Expected: all tests pass.

- [ ] **Step 4: Run the drift gate**

```bash
pnpm keel-invariants:check
```

Expected: exit 0, no drift.

---

## Task 11: End-to-end verification — worktree commit succeeds without bypass

**Files:**
- (no edits — acceptance verification matching spec § Verification plan)

- [ ] **Step 1: Create a fresh worktree off the fix branch**

```bash
git worktree add /tmp/keel-verify-240 -b chore/verify-240 fix/issue-240-worktree-portability
cd /tmp/keel-verify-240
```

- [ ] **Step 2: pnpm install — verify the prepare guard skips**

```bash
pnpm install
```

Expected output includes `[prepare-prek] skipping: not in main checkout (commondir=...)`. The `<commondir>` value is the main repo's `.git/`, not the worktree's.

- [ ] **Step 3: Build + run the drift gate from the worktree**

```bash
pnpm --filter @keel/keel-invariants build
pnpm keel-invariants:check
```

Expected: exit 0, no drift. (Pre-fix this fired `git-hook-missing` + `content-hash-mismatch` for `INV-git-hooks-preservation`.)

- [ ] **Step 4: Verify the shared hooks dir was NOT overwritten**

```bash
grep PREK= /workspace/keel/.git/hooks/pre-commit
```

Expected: still references the main checkout's `node_modules/`, NOT a `/tmp/keel-verify-240/...` path. (Pre-fix, the worktree's `pnpm install` would have rewritten this with a stale path.)

- [ ] **Step 5: Commit from the worktree without `--no-verify`**

```bash
echo "test" >> README.md
git add README.md
git commit -m "chore: verify worktree commit (issue #240)"
```

Expected: succeeds. The pre-commit hook runs `keel-invariants-check` which exits 0 (no drift). No `--no-verify` and no `SKIP=keel-invariants-check` used.

- [ ] **Step 6: Cleanup**

```bash
cd /workspace/keel
git worktree remove --force /tmp/keel-verify-240
git branch -D chore/verify-240
```

(The verification commit itself is discarded — we don't want it landing on the fix branch.)

---

## Task 12: Open the PR

**Files:**
- (no edits)

- [ ] **Step 1: Push the branch**

```bash
git push -u origin fix/issue-240-worktree-portability
```

- [ ] **Step 2: Open the PR via gh**

```bash
gh pr create --title "fix(keel-invariants): worktree-portable INV-git-hooks-preservation (closes #240)" --body "$(cat <<'EOF'
## Summary

- Replaces hardcoded `<repoRoot>/.git/hooks` path in sync-gate.ts with a `git rev-parse --git-common-dir`-based resolver, fixing false-positive `git-hook-missing` drift from worktree commits.
- Delegates `package.json` prepare lifecycle to a new `scripts/prepare-prek.mjs` that no-ops from worktrees, eliminating worktree-local PREK absolute paths from corrupting the shared `<commondir>/hooks/` bodies.
- Registers the new guard script as `INV-prek-prepare-worktree-guard` (substrate invariant); refreshes `INV-prek-prepare-lifecycle.contentHash` to match the post-fix package.json.

Closes #240. Spec: `docs/superpowers/specs/2026-05-06-issue-240-worktree-portability-design.md`. Plan: `docs/superpowers/plans/2026-05-06-issue-240-worktree-portability.md`.

## Test plan

- [x] `pnpm --filter @keel/keel-invariants test` — all tests pass, including new `resolveCommonHooksDir` regression tests
- [x] `pnpm keel-invariants:check` — exit 0, no drift, from main checkout
- [x] `pnpm keel-invariants:check` from a fresh worktree — exit 0, no drift (pre-fix this fired `git-hook-missing`)
- [x] `pnpm install` from a worktree — `prepare-prek` skips with log line, shared `.git/hooks/pre-commit` body NOT overwritten
- [x] `git commit` from a worktree without `--no-verify` and without `SKIP=keel-invariants-check` — succeeds

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 3: Confirm CI passes**

Wait for CI (typecheck, lint, test, drift gate). All expected to pass since the in-session local verification was clean.

If CI fails: surface the failure to the user and halt — do NOT push fix-up commits autonomously without first understanding the failure.

---

## Self-Review Notes (writing-plans skill)

**Spec coverage:** Each spec section maps to a task:
- Spec § 1 (sync-gate.ts) → Task 8 (human L1) + Task 2 (test)
- Spec § 2 (package.json + scripts/prepare-prek.mjs) → Task 3 + Task 4
- Spec § 3 (new invariant) → Task 5 (anchor) + Task 9 (manifest, human L1)
- Spec § 4 (contentHash refresh) → Task 9 step 2
- Spec § 5 (regression test) → Task 2 + Task 10
- Spec § 6 (docs) → Task 6
- Spec § Sequencing constraints → Task 8 + Task 9 (HUMAN CHECKPOINT framing)
- Spec § Verification plan → Task 11 (matches all 6 acceptance steps)

**Placeholder scan:** `<computed-at-impl-time>` placeholder in spec § 3 is resolved by Task 4 Step 4 + Task 9 Step 1 (paste-the-sha256). Two `<paste-...>` placeholders in Task 9 are intentionally human-fillable — they reference values captured earlier in the same plan. No vague TODOs.

**Type consistency:** `resolveCommonHooksDir(repoRoot: string): string` — same signature in Task 2 (test) and Task 8 (impl). `cachedHooksDir` typed identically. `INV-prek-prepare-worktree-guard` ID identical across Tasks 5, 8 step 3, 9 step 1.

**Sequencing note:** INVARIANTS.md is staged but uncommitted at the end of Task 5 (the intermediate drift state would reject a commit, and bypassing with `--no-verify` would defeat the purpose of the fix). The Task 9 commit bundles INVARIANTS.md anchor + manifest entry into a single atomic commit owned by the human. This is the cleanest sequencing the L1 constraint allows.
