// Story 1.19 Task 5 / AC2 — CLI integration test for check-claude-hook-syntax.
// RED-PHASE SCAFFOLD per /bmad-testarch-atdd: each `it.skip()` asserts the EXPECTED CLI
// contract per substrate ledger (`check-claude-hook-syntax.ts:88-97` prose stderr shape;
// SC-2 AS-SHIPPED). Activation (remove `.skip`) by /bmad-dev-story per Subtask 5.4.
//
// Strategy A inherited from Subtask 4.2 (locked at SM-validate iter-371 per SC-5): copy
// compiled enforcer into a tmpdir at `{tmp}/packages/keel-invariants/dist/`, populate
// `{tmp}/.claude/hooks/<fixture>.sh`, then `execFile node ...` against the relocated dist.
import { describe, it, expect } from 'vitest';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { mkdtemp, mkdir, writeFile, copyFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';

const execFileAsync = promisify(execFile);
const sourceDist = resolve(import.meta.dirname, '../../dist/check-claude-hook-syntax.js');

async function buildFixture(hooks: { name: string; body: string }[]): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), 'keel-hook-syntax-'));
  const distDir = join(root, 'packages', 'keel-invariants', 'dist');
  await mkdir(distDir, { recursive: true });
  await copyFile(sourceDist, join(distDir, 'check-claude-hook-syntax.js'));
  const hooksDir = join(root, '.claude', 'hooks');
  await mkdir(hooksDir, { recursive: true });
  for (const hook of hooks) {
    await writeFile(join(hooksDir, hook.name), hook.body, { mode: 0o755 });
  }
  return join(distDir, 'check-claude-hook-syntax.js');
}

describe('check-claude-hook-syntax CLI (Story 1.19 AC2 RED-phase)', () => {
  it('exits 0 for bash-shebang script with valid syntax', async () => {
    const cli = await buildFixture([
      { name: 'ok-bash.sh', body: '#!/usr/bin/env bash\necho ok\n' },
    ]);
    const { stdout, stderr } = await execFileAsync('node', [cli]);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
  });

  it('exits 0 for sh-shebang script that passes both bash AND dash', async () => {
    const cli = await buildFixture([{ name: 'ok-sh.sh', body: '#!/bin/sh\necho ok\n' }]);
    const { stdout, stderr } = await execFileAsync('node', [cli]);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
  });

  it('exits 1 for bash-shebang script with if-fi mismatch; stderr cites syntax failures', async () => {
    const cli = await buildFixture([
      { name: 'broken-bash.sh', body: '#!/bin/bash\nif true\necho oops\n' },
    ]);
    await expect(execFileAsync('node', [cli])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(/syntax failure\(s\) in \.claude\/hooks\/\*\.sh/),
    });
  });

  it('exits 1 for sh-shebang script using bashism here-string `<<<` (fails dash)', async () => {
    const cli = await buildFixture([{ name: 'bashism-sh.sh', body: '#!/bin/sh\ncat <<< "x"\n' }]);
    await expect(execFileAsync('node', [cli])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(/syntax failure\(s\) in \.claude\/hooks\/\*\.sh/),
    });
  });
});
