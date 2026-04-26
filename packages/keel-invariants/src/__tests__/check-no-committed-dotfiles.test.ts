// Story 1.19 Task 3 / AC2 — CLI integration test for check-no-committed-dotfiles.
// RED-PHASE SCAFFOLD per /bmad-testarch-atdd: each `it.skip()` asserts the EXPECTED CLI
// contract per substrate ledger (`check-no-committed-dotfiles.ts:35-38` prose-line stderr
// shape; SC-2 AS-SHIPPED). Activation (remove `.skip`) by /bmad-dev-story per Subtask 3.3.
//
// Build precondition: `pnpm --filter @keel/keel-invariants build` must run before activation
// so dist/check-no-committed-dotfiles.js exists (turbo `dependsOn: ["^build"]`).
import { describe, it, expect } from 'vitest';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { resolve } from 'node:path';

const execFileAsync = promisify(execFile);
const cliPath = resolve(import.meta.dirname, '../../dist/check-no-committed-dotfiles.js');

describe('check-no-committed-dotfiles CLI (Story 1.19 AC2 RED-phase)', () => {
  it('exits 0 with no staged files (vacuous green path)', async () => {
    const { stdout, stderr } = await execFileAsync('node', [cliPath]);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
  });

  it('exits 0 with compliant staged file paths (incl. .envrc.example schema-companion)', async () => {
    const { stdout, stderr } = await execFileAsync('node', [
      cliPath,
      'src/foo.ts',
      'package.json',
      '.envrc.example',
    ]);
    expect(stdout).toBe('');
    expect(stderr).toBe('');
  });

  it('exits 1 with .envrc in staged files; stderr matches Refusing-to-commit prose', async () => {
    await expect(execFileAsync('node', [cliPath, '.envrc'])).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(/Refusing to commit gitignored secret file: \.envrc/),
    });
  });

  it('exits 1 with .claude/settings.local.json in staged files; stderr names the offender', async () => {
    await expect(
      execFileAsync('node', [cliPath, '.claude/settings.local.json']),
    ).rejects.toMatchObject({
      code: 1,
      stderr: expect.stringMatching(/\.claude\/settings\.local\.json/),
    });
  });
});
