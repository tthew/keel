#!/usr/bin/env node
/**
 * Story 1.19 Task 8 — NFR1a coverage-floor gate (`INV-package-test-coverage-floor`).
 * Asserts every workspace package with a `src/` subdir has ≥ 1 `*.test.ts` file under
 * `src/` (recursive). Pre-bootstrap exempt list: `keel-templates`, `devbox` (per
 * NFR1a; backfilled by Story 1.21).
 *
 * Wire format: NDJSON to stderr, one line per offending package
 * `{"status":"violation","package":"<name>","message":"coverage-floor-violation: no *.test.ts under packages/<name>/src/"}`.
 * Invocation: `pnpm keel-invariants:package-test-coverage-floor`. Standalone CLI;
 * NOT invoked transitively by `runSyncGate`.
 */

import { readdir, stat } from 'node:fs/promises';
import path from 'node:path';

const FILE = path.resolve(import.meta.dirname, 'check-package-test-coverage-floor.js');
const DIR = path.dirname(FILE);
// packages/keel-invariants/dist/ → packages/keel-invariants/ → packages/ → repo-root
const REPO_ROOT = path.resolve(DIR, '..', '..', '..');
const PACKAGES_DIR = path.join(REPO_ROOT, 'packages');

const EXEMPT_LIST = new Set(['keel-templates', 'devbox']);

interface Violation {
  package: string;
  message: string;
}

async function isDir(absPath: string): Promise<boolean> {
  try {
    const s = await stat(absPath);
    return s.isDirectory();
  } catch {
    return false;
  }
}

// CR-1 (iter-378): `withFileTypes` + `.isFile()` guard closes the directory-named-`*.test.ts`
// false-positive class. DEFER-5 fold-in: skip matches whose ancestor walk crosses
// `node_modules` / `dist` / `coverage` / `.next` / `.turbo` (generated or dependency trees).
const SKIP_DIR_NAMES = new Set(['node_modules', 'dist', 'coverage', '.next', '.turbo']);

async function hasTestFile(srcDir: string): Promise<boolean> {
  const entries = await readdir(srcDir, { recursive: true, withFileTypes: true });
  for (const entry of entries) {
    if (!entry.isFile()) continue;
    if (!entry.name.endsWith('.test.ts')) continue;
    const parent = entry.parentPath ?? srcDir;
    const segments = path.relative(srcDir, parent).split(path.sep).filter(Boolean);
    if (segments.some((s) => SKIP_DIR_NAMES.has(s))) continue;
    return true;
  }
  return false;
}

async function main(): Promise<void> {
  let pkgs: string[];
  try {
    pkgs = await readdir(PACKAGES_DIR);
  } catch {
    process.exit(0);
  }
  pkgs.sort();
  const violations: Violation[] = [];
  for (const pkg of pkgs) {
    const pkgDir = path.join(PACKAGES_DIR, pkg);
    if (!(await isDir(pkgDir))) continue;
    const srcDir = path.join(pkgDir, 'src');
    if (!(await isDir(srcDir))) continue;
    if (EXEMPT_LIST.has(pkg)) continue;
    if (!(await hasTestFile(srcDir))) {
      violations.push({
        package: pkg,
        message: `coverage-floor-violation: no *.test.ts under packages/${pkg}/src/`,
      });
    }
  }
  if (violations.length === 0) {
    process.exit(0);
  }
  for (const v of violations) {
    process.stderr.write(`${JSON.stringify({ status: 'violation', ...v })}\n`);
  }
  process.exit(1);
}

await main();
