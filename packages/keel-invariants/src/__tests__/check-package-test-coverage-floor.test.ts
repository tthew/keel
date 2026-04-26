// Story 1.19 Task 8.3 / AC5 — Integration test for the NEW
// check-package-test-coverage-floor.ts enforcer (NFR1a substrate-side gate).
// RED-PHASE SCAFFOLD per /bmad-testarch-atdd: each `it.skip()` asserts the EXPECTED CLI
// contract per Story 1.19 Subtask 8.1 (NDJSON wire format; one stderr line per offending
// package). The enforcer source DOES NOT EXIST yet — Task 8.1 authors it; this scaffold
// pre-defines the contract. Activation by /bmad-dev-story per Subtask 8.3.
//
// Strategy A inherited from Subtask 4.2 (locked at SM-validate iter-371 per SC-5): copy
// compiled enforcer into a tmpdir + populate `{tmp}/packages/<name>/src/...` fixtures,
// then `execFile node ...` against the relocated dist. EXEMPT_LIST = {keel-templates,
// devbox} per AC5 + NFR1a + PRD line 1068; `keel-invariants` itself is NOT exempt at
// end-of-story (this story IS its backfill).
import { describe, it, expect } from 'vitest';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { mkdtemp, mkdir, writeFile, copyFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';

const execFileAsync = promisify(execFile);
const sourceDist = resolve(import.meta.dirname, '../../dist/check-package-test-coverage-floor.js');

interface FixturePackage {
  name: string;
  files: { path: string; body: string }[];
}

async function buildFixture(pkgs: FixturePackage[]): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), 'keel-cov-floor-'));
  const distDir = join(root, 'packages', 'keel-invariants', 'dist');
  await mkdir(distDir, { recursive: true });
  await copyFile(sourceDist, join(distDir, 'check-package-test-coverage-floor.js'));
  for (const pkg of pkgs) {
    const pkgDir = join(root, 'packages', pkg.name);
    for (const file of pkg.files) {
      const filePath = join(pkgDir, file.path);
      await mkdir(resolve(filePath, '..'), { recursive: true });
      await writeFile(filePath, file.body);
    }
  }
  return join(distDir, 'check-package-test-coverage-floor.js');
}

describe('check-package-test-coverage-floor CLI (Story 1.19 AC5 RED-phase)', () => {
  it('green: covered package (≥1 *.test.ts under src/) exits 0 with empty stderr', async () => {
    const cli = await buildFixture([
      {
        name: 'foo',
        files: [
          { path: 'package.json', body: '{"name":"foo"}\n' },
          { path: 'src/index.ts', body: 'export const x = 1;\n' },
          { path: 'src/foo.test.ts', body: "import {} from 'vitest';\n" },
        ],
      },
    ]);
    const { stdout, stderr } = await execFileAsync('node', [cli]);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
  });

  it('green: exempt package (devbox) without coverage exits 0 (EXEMPT_LIST recognised)', async () => {
    const cli = await buildFixture([
      {
        name: 'devbox',
        files: [
          { path: 'package.json', body: '{"name":"devbox"}\n' },
          { path: 'src/index.ts', body: 'export const x = 1;\n' },
        ],
      },
    ]);
    const { stdout, stderr } = await execFileAsync('node', [cli]);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
  });

  // CR-8 (iter-385): the AC5 red-path assertion previously substring-matched the
  // human-prose `message` value via `expect.stringMatching`, so a refactor that
  // dropped the JSON envelope or renamed `status`/`package` would have escaped
  // detection. Tighten by capturing the rejection once, then `JSON.parse` the
  // last NDJSON line and assert the structured `{status, package, message}`
  // shape per Subtask 8.1 wire-format contract.
  it('red: non-exempt package missing coverage exits 1; stderr is NDJSON {status: violation, package, message}', async () => {
    const cli = await buildFixture([
      {
        name: 'bar',
        files: [
          { path: 'package.json', body: '{"name":"bar"}\n' },
          { path: 'src/index.ts', body: 'export const x = 1;\n' },
        ],
      },
    ]);
    const err = await execFileAsync('node', [cli]).then(
      () => {
        throw new Error('expected CLI to reject with exit 1');
      },
      (e: { code?: number; stderr?: string }) => e,
    );
    expect(err.code).toBe(1);
    const lastLine = (err.stderr ?? '').trim().split('\n').pop() ?? '';
    const parsed = JSON.parse(lastLine) as {
      status: string;
      package: string;
      message: string;
    };
    expect(parsed).toMatchObject({ status: 'violation', package: 'bar' });
    expect(parsed.message).toMatch(
      /coverage-floor-violation: no \*\.test\.ts under packages\/bar\/src\//,
    );
  });

  // CR-1 (iter-378) regression: directory whose name ends in `.test.ts` MUST NOT
  // satisfy the floor. Pre-fix `readdir(... { recursive: true })` returned string[]
  // including directory paths; `entry.endsWith('.test.ts')` matched a directory entry
  // as if it were a file. Post-fix uses `withFileTypes` + `.isFile()`.
  it('red: directory whose name ends in ".test.ts" does NOT count as a test file (CR-1 isFile guard)', async () => {
    const cli = await buildFixture([
      {
        name: 'baz',
        files: [
          { path: 'package.json', body: '{"name":"baz"}\n' },
          { path: 'src/index.ts', body: 'export const x = 1;\n' },
          // A directory entry whose name ends in `.test.ts` — buildFixture creates
          // the parent dir as a side-effect of writing the placeholder file inside.
          { path: 'src/sub.test.ts/keep.txt', body: '' },
        ],
      },
    ]);
    await expect(execFileAsync('node', [cli])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(
        /coverage-floor-violation: no \*\.test\.ts under packages\/baz\/src\//,
      ),
    });
  });

  // CR-2 (iter-379) regression: non-ENOENT readdir(PACKAGES_DIR) failures (EACCES,
  // EIO, ENOTDIR, EMFILE…) MUST NOT masquerade as "no violations". Pre-fix the
  // catch-all silently exited 0; post-fix only ENOENT is swallowed, everything else
  // surfaces as NDJSON {status:'error',message} on stderr + exit 1. Synthesised by
  // staging `packages/` as a regular FILE (readdir → ENOTDIR), portable across
  // root/non-root test environments where chmod-based EACCES is not enforceable.
  it('red: non-ENOENT readdir error surfaces NDJSON {status:error} + exit 1 (CR-2)', async () => {
    // Stage CLI under a SIBLING tree so REPO_ROOT resolves to {root} but
    // {root}/packages is free for us to clobber as a file.
    const root = await mkdtemp(join(tmpdir(), 'keel-cov-floor-cr2-'));
    const distDir = join(root, 'sibling', 'keel-invariants', 'dist');
    await mkdir(distDir, { recursive: true });
    const cli = join(distDir, 'check-package-test-coverage-floor.js');
    await copyFile(sourceDist, cli);
    await writeFile(join(root, 'packages'), 'not-a-directory');
    await expect(execFileAsync('node', [cli])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(/"status":"error"/),
    });
  });

  // CR-3 (iter-380) regression: a directory under `packages/` lacking
  // `package.json` is NOT a pnpm workspace member (transient
  // `node_modules/.cache/...`, vendored fixtures, dist outputs) and MUST be
  // silently skipped — no stderr, exit 0. Pre-fix the loop treated any sub-dir
  // of `packages/` with a `src/` subtree as a workspace package, producing
  // spurious violations. Discriminator vs the bar/baz/qux red tests: identical
  // src/ shape, only difference is the absence of `package.json`.
  it('green: directory without package.json is silently skipped (CR-3 workspace-member guard)', async () => {
    const cli = await buildFixture([
      {
        name: 'not-a-package',
        files: [{ path: 'src/index.ts', body: 'export const x = 1;\n' }],
      },
    ]);
    const { stdout, stderr } = await execFileAsync('node', [cli]);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
  });

  // CR-1 DEFER-5 fold-in (iter-378): `*.test.ts` inside a `node_modules/` (or
  // `dist`, `coverage`, `.next`, `.turbo`) subtree under `src/` MUST NOT count.
  it('red: *.test.ts inside src/node_modules/ does NOT count (DEFER-5 traversal exclusion)', async () => {
    const cli = await buildFixture([
      {
        name: 'qux',
        files: [
          { path: 'package.json', body: '{"name":"qux"}\n' },
          { path: 'src/index.ts', body: 'export const x = 1;\n' },
          { path: 'src/node_modules/somepkg/foo.test.ts', body: '' },
        ],
      },
    ]);
    await expect(execFileAsync('node', [cli])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(
        /coverage-floor-violation: no \*\.test\.ts under packages\/qux\/src\//,
      ),
    });
  });
});
