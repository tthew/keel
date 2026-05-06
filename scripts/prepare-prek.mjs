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
import { realpathSync } from 'node:fs';

// Strip git-discovery env vars so a wrapper that exports them cannot redirect
// `git rev-parse --git-common-dir` to a different repository identity.
// GIT_DIR/GIT_COMMON_DIR/GIT_WORK_TREE override repo discovery directly;
// GIT_CEILING_DIRECTORIES halts upward discovery.
const gitEnv = { ...process.env };
delete gitEnv.GIT_DIR;
delete gitEnv.GIT_COMMON_DIR;
delete gitEnv.GIT_WORK_TREE;
delete gitEnv.GIT_CEILING_DIRECTORIES;

let commonDir;
try {
  commonDir = execFileSync('git', ['rev-parse', '--git-common-dir'], {
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'ignore'],
    env: gitEnv,
  }).trim();
} catch {
  // Not a git repo (e.g. tarball install). Skip.
  process.exit(0);
}

// Canonicalize both sides via realpath so a symlinked working tree (macOS
// /var → /private/var, or any operator-introduced symlink) does not produce
// two distinct spellings of the same directory that compare unequal under a
// plain path.resolve(). realpath operates on files just as well as directories
// (a worktree's .git is a regular gitlink file, not a directory).
let resolvedCommon, mainCommon;
try {
  resolvedCommon = realpathSync(commonDir);
  mainCommon = realpathSync('.git');
} catch (err) {
  // git rev-parse just succeeded so .git should exist; if either side cannot
  // be canonicalized we are in indeterminate state. Fail closed (skip) rather
  // than risk overwriting shared hook bodies with worktree-local paths.
  console.log(
    `[prepare-prek] skipping: cannot canonicalize git paths (${err.code ?? err.message}).`,
  );
  process.exit(0);
}

if (resolvedCommon !== mainCommon) {
  // Worktree (or non-standard layout). Skip — the main checkout owns the hook bodies.
  console.log(`[prepare-prek] skipping: not in main checkout (commondir=${resolvedCommon}).`);
  process.exit(0);
}

const result = spawnSync('prek', ['install', '-t', 'pre-commit', '-t', 'commit-msg'], {
  stdio: 'inherit',
});
// `result.status === null` when the child terminated abnormally — either
// `result.error` (spawn failure: ENOENT, EACCES) or `result.signal` (killed).
// Without these branches, `null ?? 0` would silently exit 0 and the caller
// would believe `prek install` succeeded while no hooks were installed.
if (result.error) {
  console.error(
    `[prepare-prek] failed to spawn prek: ${result.error.message}. Install prek before running pnpm install (https://github.com/j178/prek).`,
  );
  process.exit(1);
}
if (result.signal) {
  console.error(`[prepare-prek] prek terminated by signal ${result.signal}.`);
  process.exit(1);
}
// Defensive default to 1 (failure) — every abnormal exit is now caught above,
// so this branch should be unreachable, but defaulting to non-zero avoids any
// future Node API change that surfaces another null-status path as success.
process.exit(result.status ?? 1);
