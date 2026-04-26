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
import { existsSync } from 'node:fs';
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
  } catch (e) {
    // CR-2 (iter-379): only ENOENT (no `packages/` dir) silently exits 0.
    // EACCES / EIO / ENOTDIR / EMFILE etc. surface as NDJSON error + exit 1
    // so genuine I/O failures don't masquerade as "no violations".
    if ((e as NodeJS.ErrnoException).code === 'ENOENT') {
      process.exit(0);
    }
    // CR-4 (iter-381): `process.exit(1)` immediately after a stderr write can
    // race the stdio drain on piped-stderr CI containers (and any non-TTY
    // stderr where Node treats writes as async). Set `process.exitCode` and
    // return so the event loop drains naturally — `await main()` resolves and
    // Node exits with the recorded code.
    process.stderr.write(`${JSON.stringify({ status: 'error', message: String(e) })}\n`);
    process.exitCode = 1;
    return;
  }
  pkgs.sort();
  const violations: Violation[] = [];
  for (const pkg of pkgs) {
    const pkgDir = path.join(PACKAGES_DIR, pkg);
    if (!(await isDir(pkgDir))) continue;
    // CR-3 (iter-380): only directories with a `package.json` are pnpm workspace
    // members. Without this guard, transient siblings under `packages/` (e.g.
    // `node_modules/.cache/...`, vendored fixtures, dist outputs) get treated as
    // packages and produce spurious coverage-floor violations.
    if (!existsSync(path.join(pkgDir, 'package.json'))) continue;
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
  // CR-4 (iter-381): see catch-block above — `process.exitCode = 1; return;`
  // lets stderr drain before exit. Critical here because every violation is a
  // separate stderr.write and the loop may emit several lines per run.
  process.exitCode = 1;
}

// CR-5 (iter-382): top-level `await main()` rejection bypassed the in-`main`
// catch-frame's NDJSON-emit + exit-1 contract — pre-CR-5, any synchronous throw
// or unawaited rejection escaping `main` (e.g. inner `readdir(srcDir, {recursive:true})`
// hitting ELOOP/EIO/EMFILE; future code-path that throws after the outer-readdir
// catch frame closes) surfaced as Node's `UnhandledPromiseRejection` trace on
// stderr — non-NDJSON, so CI consumers parsing per-line JSON would mis-key on
// the trace text. Wrap with `.catch` so any escapee still produces NDJSON
// `{status:'error',message}` on stderr + exit 1, preserving the wire-format
// guarantee. Uses `process.exitCode` (no `process.exit`) to avoid the stderr-
// flush race documented in CR-4.
await main().catch((e: unknown) => {
  process.stderr.write(`${JSON.stringify({ status: 'error', message: String(e) })}\n`);
  process.exitCode = 1;
});
