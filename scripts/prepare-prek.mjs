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
