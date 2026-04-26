// Story 1.19 Task 4 / AC2 — CLI integration test for check-nfr5a-minimum.
// RED-PHASE SCAFFOLD per /bmad-testarch-atdd: each `it.skip()` asserts the EXPECTED CLI
// contract per substrate ledger (`check-nfr5a-minimum.ts:42-44` single-line JSON stderr
// shape; SC-2 AS-SHIPPED). Activation (remove `.skip`) by /bmad-dev-story per Subtask 4.4.
//
// Strategy A (locked at SM-validate iter-371 per SC-5): copy compiled enforcer into a tmpdir
// at `{tmp}/packages/keel-invariants/dist/check-nfr5a-minimum.js`, populate
// `{tmp}/.claude/settings.json` per case, then `execFile node ...` against the relocated
// dist. The enforcer's REPO_ROOT resolution (`path.resolve(DIR, '..', '..', '..')`) lands
// on `{tmp}` by construction, so the fixture settings.json is read.
import { describe, it, expect } from 'vitest';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { mkdtemp, mkdir, writeFile, copyFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';

const execFileAsync = promisify(execFile);
const sourceDist = resolve(import.meta.dirname, '../../dist/check-nfr5a-minimum.js');

async function buildFixture(settings: unknown): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), 'keel-nfr5a-'));
  const distDir = join(root, 'packages', 'keel-invariants', 'dist');
  await mkdir(distDir, { recursive: true });
  await copyFile(sourceDist, join(distDir, 'check-nfr5a-minimum.js'));
  const claudeDir = join(root, '.claude');
  await mkdir(claudeDir, { recursive: true });
  await writeFile(join(claudeDir, 'settings.json'), JSON.stringify(settings));
  return join(distDir, 'check-nfr5a-minimum.js');
}

describe('check-nfr5a-minimum CLI (Story 1.19 AC2 RED-phase)', () => {
  it.skip('exits 0 when settings.json carries 13 deny + 6 allow (substrate baseline)', async () => {
    const cli = await buildFixture({
      permissions: {
        deny: Array.from({ length: 13 }, (_, i) => ({ tool: `Deny${i}` })),
        allow: Array.from({ length: 6 }, (_, i) => ({ tool: `Allow${i}` })),
      },
    });
    const { stdout, stderr } = await execFileAsync('node', [cli]);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
  });

  it.skip('exits 1 with deny-min violation; stderr is single-line JSON {status: violation, ...} citing 13', async () => {
    const cli = await buildFixture({
      permissions: {
        deny: Array.from({ length: 12 }, (_, i) => ({ tool: `Deny${i}` })),
        allow: Array.from({ length: 6 }, (_, i) => ({ tool: `Allow${i}` })),
      },
    });
    await expect(execFileAsync('node', [cli])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(/"status":"violation".*"message":".*13/),
    });
  });

  it.skip('exits 1 with allow-min violation; stderr is single-line JSON citing the lower bound', async () => {
    const cli = await buildFixture({
      permissions: {
        deny: Array.from({ length: 13 }, (_, i) => ({ tool: `Deny${i}` })),
        allow: Array.from({ length: 5 }, (_, i) => ({ tool: `Allow${i}` })),
      },
    });
    await expect(execFileAsync('node', [cli])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(/"status":"violation".*allow/),
    });
  });

  it.skip('exits 1 when .permissions.deny is missing/not-array; stderr cites missing-or-not-an-array', async () => {
    const cli = await buildFixture({
      permissions: {
        allow: Array.from({ length: 6 }, (_, i) => ({ tool: `Allow${i}` })),
      },
    });
    await expect(execFileAsync('node', [cli])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(/missing or not an array/),
    });
  });
});
