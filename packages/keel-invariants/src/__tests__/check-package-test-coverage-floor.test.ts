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
        files: [{ path: 'src/index.ts', body: 'export const x = 1;\n' }],
      },
    ]);
    const { stdout, stderr } = await execFileAsync('node', [cli]);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
  });

  it('red: non-exempt package missing coverage exits 1; stderr is NDJSON {status: violation, package, message}', async () => {
    const cli = await buildFixture([
      {
        name: 'bar',
        files: [{ path: 'src/index.ts', body: 'export const x = 1;\n' }],
      },
    ]);
    await expect(execFileAsync('node', [cli])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(
        /coverage-floor-violation: no \*\.test\.ts under packages\/bar\/src\//,
      ),
    });
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

  // CR-1 DEFER-5 fold-in (iter-378): `*.test.ts` inside a `node_modules/` (or
  // `dist`, `coverage`, `.next`, `.turbo`) subtree under `src/` MUST NOT count.
  it('red: *.test.ts inside src/node_modules/ does NOT count (DEFER-5 traversal exclusion)', async () => {
    const cli = await buildFixture([
      {
        name: 'qux',
        files: [
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
