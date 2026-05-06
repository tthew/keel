# Issue #240 — Worktree-portability for `INV-git-hooks-preservation`

**Status:** design approved 2026-05-06
**Issue:** https://github.com/tthew/keel/issues/240
**Scope:** single PR
**Owner:** TBD (Story 2.17 follow-up, Epic 04 / Security)

## Problem

Two related worktree-portability bugs in keel's git-hook handling stack make `INV-git-hooks-preservation` (Story 2.17 SECURITY-CRITICAL gate) impossible to satisfy from a worktree commit, training operators (and AI sub-agents) to bypass the substrate-authoritative bypass-resistance contract via `git commit --no-verify` or `SKIP=keel-invariants-check`.

### Bug #1 — `sync-gate.ts` hardcodes `<repoRoot>/.git/hooks`

`packages/keel-invariants/src/sync-gate.ts:188` resolves the hooks directory as `resolve(repoRoot, '.git/hooks')`. In a worktree, `<worktree>/.git` is a gitlink file (`gitdir: <commondir>/worktrees/<name>`), not a directory — so `<worktree>/.git/hooks` is a non-existent path. Every enumerated hook in `EXPECTED_HOOKS` (commit-msg, pre-commit) renders as `<MISSING>`, the names-and-shebangs hash diverges from the recorded `contentHash`, and drift fires unconditionally.

### Bug #2 — `prek install` from a worktree corrupts the shared hooks dir for all checkouts

`package.json:44` runs `prek install` in every `pnpm install` (npm `prepare` lifecycle). From a worktree, `prek install` writes to `<commondir>/.git/hooks/` (correct location — worktrees share commondir) but bakes the **worktree-local** `node_modules/.../prek` absolute path into the hook body. After worktree cleanup, the absolute path is stale; the hook falls back to PATH `prek` (which fails on hosts without global prek installed). Two worktrees racing `pnpm install` overwrite each other.

**Operational impact:** any worktree's `pnpm install` mutates the shared hook with a transient path. Verified at design time: `/workspace/keel/.git/hooks/pre-commit` literally contains `PREK="/workspace/keel/.claude/worktrees/agent-a9340743/..."` — a path to a worktree that no longer exists.

### Bug #3 (consequence)

Sub-agents committing from worktrees face a fail-closed `keel-invariants-check`. They resort to `--no-verify` (full pre-commit bypass) or `SKIP=keel-invariants-check` (granular bypass) to land docs-only commits. Both undermine the SECURITY-CRITICAL gate. PR #238 + PR #239 (referenced in issue #240) demonstrate this in production.

## Out of scope

- Honoring `git config core.hooksPath` (not currently set anywhere in keel; no requirement).
- Addressing the names-and-shebangs vs byte-content hashing gap flagged in the issue ("an attacker who edits a hook body without changing shebang or name is invisible to the gate"). This is a separate invariant-design discussion, not a portability fix.
- Cleaning up the stale `pre-commit` body currently on disk in `/workspace/keel/.git/hooks/`. Once Bug #2 is fixed, the next `pnpm install` from main rewrites it correctly. No active cleanup needed.

## Solution overview

Six coordinated edits — sync-gate resolver fix, prepare-lifecycle guard, a new substrate invariant covering the new guard script, refresh of the existing prepare-lifecycle invariant's `contentHash`, regression test, and a brief doc subsection:

| # | Change | File | L1-protected? |
|---|---|---|---|
| 1 | Replace hardcoded hooks-dir path with `git rev-parse --git-common-dir` resolver | `packages/keel-invariants/src/sync-gate.ts` | **yes** |
| 2 | Extract `prepare` lifecycle to a node script that skips when not in main checkout | `package.json` (root) + new `scripts/prepare-prek.mjs` | partial (1) |
| 3 | Add new invariant `INV-prek-prepare-worktree-guard` covering `scripts/prepare-prek.mjs` | `packages/keel-invariants/src/invariants.manifest.ts` + `INVARIANTS.md` | **yes** |
| 3a | Append `INV-prek-prepare-worktree-guard` to `EXPECTED_INVARIANT_IDS` snapshot | `packages/keel-invariants/src/sync-gate.ts` | **yes** |
| 4 | Refresh `INV-prek-prepare-lifecycle.contentHash` (whole-file `package.json` hash changes) | `packages/keel-invariants/src/invariants.manifest.ts` | **yes** |
| 5 | Regression test: real `git worktree` fixture | `packages/keel-invariants/src/__tests__/sync-gate.test.ts` | no |
| 6 | Document the resolver pattern for future hook-walking invariants | `docs/invariants/claude-hook-denylist.md` | no |

(1) `package.json` is whole-file-hashed by `INV-prek-prepare-lifecycle` so every edit to it is gated by the sync-gate, but it is not L1-write-blocked at the in-session-hook layer. `scripts/prepare-prek.mjs` is a new file — once registered, it becomes L1-protected too via the new invariant.

## Detailed changes

### 1. `packages/keel-invariants/src/sync-gate.ts` — common-dir resolver

Add at top of file (after imports, before `EXPECTED_INVARIANT_IDS`). Note `export` — the regression test imports it directly:

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

Replace `sync-gate.ts:188`:

```ts
// before
const hooksDir = resolve(repoRoot, '.git/hooks');

// after
const hooksDir = resolveCommonHooksDir(repoRoot);
```

**Rationale for `execFileSync` (not `execSync`):** `repoRoot` arrives from `check.ts` via `resolve(import.meta.dirname, '../../..')` — internal-only, but `execFileSync` is the safer default and the project already uses `execFileSync` in `main-repo-resolver.sh`-equivalent flows. No metacharacter shell-quoting concerns.

**Rationale for cache:** `runSyncGate` is invoked once per pre-commit. Today only one invariant uses `names-and-shebangs` scope, but the cache makes future additions free. The cache key is `repoRoot` so test fixtures with distinct temp roots don't share state.

### 2. `package.json` + `scripts/prepare-prek.mjs` — worktree-skip guard

**New file `scripts/prepare-prek.mjs`:**

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

**`package.json:44`:**

```json
// before
"prepare": "prek install -t pre-commit -t commit-msg"

// after
"prepare": "node scripts/prepare-prek.mjs"
```

The script keeps a non-zero exit on prek failure (so prepare still fails loudly when prek itself errors in the main checkout) but exits 0 cleanly from worktrees.

### 3. New invariant — `INV-prek-prepare-worktree-guard`

Add to `packages/keel-invariants/src/invariants.manifest.ts` (alphabetically positioned alongside other prek entries, ~line 144):

```ts
{
  id: 'INV-prek-prepare-worktree-guard',
  description:
    'Root npm `prepare` lifecycle is delegated to scripts/prepare-prek.mjs which runs `prek install -t pre-commit -t commit-msg` ONLY when `git rev-parse --git-common-dir` resolves to <cwd>/.git (the main checkout). From a worktree the script no-ops, preventing worktree-local PREK absolute-path bake-ins from corrupting the shared <commondir>/.git/hooks/ bodies. Whole-file SHA-256 of scripts/prepare-prek.mjs pins the contract; legitimate edits are AMEND-path. Issue #240 (PR #240-fix).',
  sourcePath: 'scripts/prepare-prek.mjs',
  contentHash: '<computed-at-impl-time>',
  anchors: ['INV-prek-prepare-worktree-guard'],
},
```

Add to `EXPECTED_INVARIANT_IDS` snapshot in `sync-gate.ts:65-110` (preserve alphabetical clustering — adjacent to `INV-prek-prepare-lifecycle`):

```ts
'INV-prek-prepare-lifecycle',
'INV-prek-prepare-worktree-guard',  // new
```

Add anchor to `INVARIANTS.md` under the existing "prek pre-commit config (Story 1.4)" section:

```md
- **`INV-prek-prepare-worktree-guard`** — `scripts/prepare-prek.mjs` gates `prek install` to the main checkout only; from a worktree the prepare script no-ops to prevent shared-hook-body corruption (issue #240). Source: `scripts/prepare-prek.mjs`.
```

### 4. Refresh `INV-prek-prepare-lifecycle.contentHash`

`packages/keel-invariants/src/invariants.manifest.ts:138-144` is a whole-file `package.json` hash. Changing the `prepare` script from `prek install ...` to `node scripts/prepare-prek.mjs` mutates the file → new `contentHash` required.

Procedure (the implementer will run this):
1. Make the `package.json` edit + add the new invariant entry.
2. `pnpm --filter @keel/keel-invariants build`
3. `pnpm keel-invariants:check` → fails with `content-hash-mismatch` for `INV-prek-prepare-lifecycle` AND `expected-id-missing` for `INV-prek-prepare-worktree-guard` (until the new entry's hash is computed).
4. Copy the `actualHash` from drift output into the `INV-prek-prepare-lifecycle.contentHash` field.
5. Compute `scripts/prepare-prek.mjs` SHA-256 (e.g. `sha256sum scripts/prepare-prek.mjs`) → fill the new invariant's `contentHash`.
6. Re-run `pnpm keel-invariants:check` → clean.

### 5. Regression test — `packages/keel-invariants/src/__tests__/sync-gate.test.ts`

A focused unit test of `resolveCommonHooksDir` is sufficient to prove the bug is fixed: the helper is a pure path-resolution function whose only failure mode (the original bug) is mishandling the gitlink-file-vs-directory distinction. The rest of the sync-gate code path is unchanged.

A full `runSyncGate(wtRoot)` integration test was considered and rejected: `loadExpectedHooks` resolves enumerator paths via `src/*.ts` → `dist/*.js` rewrite (`manifest-reader.ts:101-104`), so the fixture would need a built `dist/` mirror inside the temp worktree — fixture overhead disproportionate to the assurance gained.

New test block at the end of `sync-gate.test.ts`:

```ts
describe('resolveCommonHooksDir worktree portability (issue #240)', () => {
  it('resolves to <commondir>/hooks when invoked from a worktree off a real git repo', async () => {
    const { execFileSync } = await import('node:child_process');
    const { resolve: resolvePath } = await import('node:path');

    const root = await mkdtemp(join(tmpdir(), 'keel-syncgate-wt-'));
    try {
      // Initialize a git repo at root with one commit so worktree add works.
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

      // Invoking from main checkout — points at <root>/.git/hooks.
      expect(resolveCommonHooksDir(root)).toBe(resolvePath(root, '.git', 'hooks'));
      // Invoking from worktree — STILL points at <root>/.git/hooks (NOT <wtRoot>/.git/hooks
      // which would be a non-existent path under the gitlink file).
      expect(resolveCommonHooksDir(wtRoot)).toBe(resolvePath(root, '.git', 'hooks'));

      execFileSync('git', ['worktree', 'remove', '--force', wtRoot], { cwd: root });
    } finally {
      await rm(root, { recursive: true, force: true });
    }
  });

  it('falls back to <repoRoot>/.git/hooks when not in a git repo (test fixture safety)', async () => {
    const root = await mkdtemp(join(tmpdir(), 'keel-syncgate-nogit-'));
    try {
      const { resolve: resolvePath } = await import('node:path');
      const { resolveCommonHooksDir } = await import('../sync-gate.js');
      // No `git init` — execFileSync throws → fallback path used.
      expect(resolveCommonHooksDir(root)).toBe(resolvePath(root, '.git', 'hooks'));
    } finally {
      await rm(root, { recursive: true, force: true });
    }
  });
});
```

Note: each `it` uses its own `mkdtemp` root so the per-call cache (`cachedHooksDir`) doesn't leak between tests. The cache key is `repoRoot`, so distinct temp roots are independent.

Adds ~0.5–1s to the test suite (two `mkdtemp` + one real `git init` + one real `git worktree add`). Acceptable.

### 6. Documentation — `docs/invariants/claude-hook-denylist.md`

Add a brief subsection (3-5 sentences) titled "**Worktree-portability resolver pattern**" explaining: the `.git/hooks/` directory lives in `<commondir>` (the main repo's `.git/`), not in `<worktree>/.git/` (which is a gitlink file). Future invariant authors writing hook-walking checks should resolve via `git rev-parse --git-common-dir` and `resolve(repoRoot, commonDir, 'hooks')`, not `resolve(repoRoot, '.git/hooks')`. Cross-reference `sync-gate.ts:resolveCommonHooksDir` as the canonical example.

## Sequencing constraints / human-in-loop checkpoints

The L1 install-boundary hook (`.claude/hooks/block-secret-access.sh`) denies in-session AI-agent edits to:

- `packages/keel-invariants/src/sync-gate.ts`
- `packages/keel-invariants/src/invariants.manifest.ts`

Three of the seven changes above touch these files (sync-gate fix, EXPECTED_INVARIANT_IDS append, manifest entry add + contentHash refresh). The implementing agent **cannot land these edits autonomously** — the human user must apply the diffs, or the implementing agent must escalate via review. The non-L1-protected work (new `scripts/prepare-prek.mjs`, `package.json` edit, regression test, doc subsection) can be done in-session.

Recommended sequencing:
1. Implementing agent: write the new `scripts/prepare-prek.mjs`, edit `package.json`, write the regression test (currently fails), write the doc subsection.
2. Implementing agent: open a draft PR with the in-session work + a clearly-marked "BLOCKED ON HUMAN: L1 edits" checklist itemizing the four diffs needed in `sync-gate.ts` + `invariants.manifest.ts`.
3. Human: applies the L1-protected diffs (or runs an out-of-session tool that does), computes the two `contentHash` values, commits.
4. Implementing agent: re-runs `pnpm keel-invariants:check` to confirm clean, marks PR ready.

## Verification plan (acceptance criteria)

The PR is done when all of the following pass:

1. `pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check` from main repo → exit 0, no drift.
2. From a fresh worktree:
   ```bash
   git worktree add /tmp/keel-verify-240 -b chore/verify-240 main
   cd /tmp/keel-verify-240
   pnpm install
   pnpm --filter @keel/keel-invariants build
   pnpm keel-invariants:check
   ```
   → exit 0, no drift. (Pre-fix: fires `git-hook-missing` + `content-hash-mismatch` for `INV-git-hooks-preservation`.)
3. Confirm `<commondir>/.git/hooks/pre-commit` was NOT overwritten by the worktree's `pnpm install`:
   ```bash
   grep PREK= /workspace/keel/.git/hooks/pre-commit
   ```
   → still references the main checkout's prek path (or unchanged from prior state if the prepare guard now skips entirely).
4. `pnpm --filter @keel/keel-invariants test` → all tests pass, including the new worktree-portability test.
5. From the verify worktree, edit a file and commit without `--no-verify` and without `SKIP=keel-invariants-check`:
   ```bash
   echo "test" >> README.md
   git add README.md
   git commit -m "chore: verify worktree commit"
   ```
   → succeeds (pre-commit gate runs `keel-invariants-check` cleanly).
6. Cleanup: `git worktree remove --force /tmp/keel-verify-240`.

## Risks / known unknowns

- **`prek` not on PATH after the fix:** if a host runs `pnpm install` from main but `prek` itself isn't installed, `spawnSync('prek', ...)` returns an exec failure. Same behavior as today's inline `prek install ...` invocation — no regression.
- **`git rev-parse` not available:** unlikely on developer hosts (git is a hard prerequisite). The script catches and exits 0 (skip) which is correct behavior for tarball-install scenarios. The sync-gate falls back to `resolve(repoRoot, '.git/hooks')` which preserves existing test fixture behavior.
- **`scripts/` already contains `bootstrap-bmad-agents.py` + `tests/`** — adding `prepare-prek.mjs` alongside is a clean fit; no naming collision.
- **`contentHash` for `scripts/prepare-prek.mjs`** must be computed at implementation time (not pre-computed in this spec) since the exact bytes of the script may shift slightly during code-review tightening.
