// Story 1.19 Task 6 / AC3 — Programmatic integration test for runSyncGate covering each of
// the four canonical drift classes (added-to-source-only / removed-from-source-only /
// removed-from-docs-only / content-hash-mismatch) per epics.md:1225 + SC-3.
// RED-PHASE SCAFFOLD per /bmad-testarch-atdd: each `it.skip()` asserts the EXPECTED
// DriftReport shape per `sync-gate.ts:21-34`. Activation by /bmad-dev-story per Subtask 6.5.
//
// Strategy A locked at SM-validate iter-371 per SC-5 (Subtask 6.2): use `vi.mock(...)` per-
// test to override the `invariants` export from manifest-reader.js. Each test creates a
// fresh `mkdtemp` containing INVARIANTS.md + (optionally) a fixture source file.
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { mkdtemp, mkdir, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { createHash } from 'node:crypto';

beforeEach(() => {
  vi.resetModules();
});

async function makeRepoRoot(invariantsMdContent: string): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), 'keel-syncgate-'));
  await writeFile(join(root, 'INVARIANTS.md'), invariantsMdContent);
  return root;
}

describe('runSyncGate four drift classes (Story 1.19 AC3 RED-phase)', () => {
  it('added-to-source-only: manifest entry exists, INVARIANTS.md has no anchor', async () => {
    const root = await makeRepoRoot('# INVARIANTS\n');
    await writeFile(join(root, 'src.ts'), 'const x = 1;\n');
    const hash = createHash('sha256').update('const x = 1;\n').digest('hex');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return {
        ...real,
        invariants: [
          {
            id: 'INV-test-fixture',
            description: 'fixture',
            sourcePath: 'src.ts',
            contentHash: hash,
            anchors: ['INV-test-fixture'],
          },
        ],
      };
    });
    const { runSyncGate } = await import('../sync-gate.js');
    const report = await runSyncGate(root);
    expect(report.status).toBe('drift');
    expect(report.drifts).toContainEqual(
      expect.objectContaining({ kind: 'added-to-source-only', id: 'INV-test-fixture' }),
    );
    await rm(root, { recursive: true, force: true });
  });

  it('removed-from-source-only: INVARIANTS.md has anchor, sourcePath is missing on disk', async () => {
    const root = await makeRepoRoot('# INVARIANTS\n- **`INV-removed`** — gone from source.\n');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return {
        ...real,
        invariants: [
          {
            id: 'INV-removed',
            description: 'fixture',
            sourcePath: 'nonexistent/path.ts',
            contentHash: 'a'.repeat(64),
            anchors: ['INV-removed'],
          },
        ],
      };
    });
    const { runSyncGate } = await import('../sync-gate.js');
    const report = await runSyncGate(root);
    expect(report.status).toBe('drift');
    expect(report.drifts).toContainEqual(
      expect.objectContaining({
        kind: 'removed-from-source-only',
        id: 'INV-removed',
        sourcePath: 'nonexistent/path.ts',
      }),
    );
    await rm(root, { recursive: true, force: true });
  });

  it('removed-from-docs-only: INVARIANTS.md has orphan anchor, manifest is empty', async () => {
    const root = await makeRepoRoot('# INVARIANTS\n- **`INV-orphan-doc`** — orphan.\n');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return { ...real, invariants: [] };
    });
    const { runSyncGate } = await import('../sync-gate.js');
    const report = await runSyncGate(root);
    expect(report.status).toBe('drift');
    expect(report.drifts).toContainEqual(
      expect.objectContaining({ kind: 'removed-from-docs-only', anchor: 'INV-orphan-doc' }),
    );
    await rm(root, { recursive: true, force: true });
  });

  it('content-hash-mismatch: source file content does not match manifest contentHash', async () => {
    const root = await makeRepoRoot('# INVARIANTS\n- **`INV-hash-drift`** — drift.\n');
    await writeFile(join(root, 'src.ts'), 'actual content\n');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return {
        ...real,
        invariants: [
          {
            id: 'INV-hash-drift',
            description: 'fixture',
            sourcePath: 'src.ts',
            contentHash: 'a'.repeat(64),
            anchors: ['INV-hash-drift'],
          },
        ],
      };
    });
    const { runSyncGate } = await import('../sync-gate.js');
    const report = await runSyncGate(root);
    expect(report.status).toBe('drift');
    expect(report.drifts).toContainEqual(
      expect.objectContaining({
        kind: 'content-hash-mismatch',
        id: 'INV-hash-drift',
        expectedHash: 'a'.repeat(64),
      }),
    );
    await rm(root, { recursive: true, force: true });
  });

  it('clean baseline: aligned manifest + docs + source produces no canonical drift kinds', async () => {
    const body = 'aligned content\n';
    const root = await makeRepoRoot('# INVARIANTS\n- **`INV-aligned-fixture`** — aligned.\n');
    await writeFile(join(root, 'src.ts'), body);
    const hash = createHash('sha256').update(body).digest('hex');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return {
        ...real,
        invariants: [
          {
            id: 'INV-aligned-fixture',
            description: 'fixture',
            sourcePath: 'src.ts',
            contentHash: hash,
            anchors: ['INV-aligned-fixture'],
          },
        ],
      };
    });
    const { runSyncGate } = await import('../sync-gate.js');
    const report = await runSyncGate(root);
    // The mocked manifest deliberately doesn't include the real
    // EXPECTED_INVARIANT_IDS snapshot (FIX-3) or the BYTE_PARITY_PAIRS
    // substrate↔seed files (FIX-4) — the dedicated cases below cover those
    // bypass classes. Filter those out to verify the four canonical drift
    // classes are absent for an aligned manifest+docs+source.
    const canonical = report.drifts.filter(
      (d) => d.kind !== 'expected-id-missing' && d.kind !== 'byte-parity-mismatch',
    );
    expect(canonical).toEqual([]);
    await rm(root, { recursive: true, force: true });
  });

  it('expected-id-missing: dropping a manifest entry while EXPECTED_INVARIANT_IDS retains its ID fires fail-closed drift', async () => {
    // FIX-3 (PR #230 review-fix-arc) — out-of-band fail-closed snapshot
    // defends against the drop+anchor-remove bypass. An attacker who removes
    // BOTH a manifest entry AND its INVARIANTS.md anchor in a single commit
    // silently passes the symmetric drift checks (both for-loops in
    // runSyncGate skip absent items). The EXPECTED_INVARIANT_IDS snapshot
    // (in L1-protected sync-gate.ts) closes that bypass: any expected ID
    // absent from the manifest fires `expected-id-missing` drift.
    const root = await makeRepoRoot('# INVARIANTS\n');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return { ...real, invariants: [] };
    });
    const { runSyncGate, EXPECTED_INVARIANT_IDS } = await import('../sync-gate.js');
    const report = await runSyncGate(root);
    expect(report.status).toBe('drift');
    expect(EXPECTED_INVARIANT_IDS.length).toBeGreaterThan(0);
    for (const id of EXPECTED_INVARIANT_IDS) {
      expect(report.drifts).toContainEqual(
        expect.objectContaining({ kind: 'expected-id-missing', id }),
      );
    }
    await rm(root, { recursive: true, force: true });
  });

  it('byte-parity-mismatch: substrate ↔ seed pair files differ in content (lockstep-hash bypass class)', async () => {
    // FIX-4 (PR #230 review-fix-arc) — out-of-band byte-parity check defends
    // against the lockstep-hash bypass. An attacker who mutates BOTH the
    // substrate (.claude/...) AND its seed
    // (packages/keel-templates/src/seeds/.claude/...) in lockstep with new
    // matching contentHash entries silently slips both per-file gates. The
    // BYTE_PARITY_PAIRS snapshot (in L1-protected sync-gate.ts) closes that
    // bypass: any pair whose disk content differs fires `byte-parity-mismatch`
    // drift regardless of manifest contentHash agreement.
    const root = await makeRepoRoot('# INVARIANTS\n');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return { ...real, invariants: [] };
    });
    const { runSyncGate, BYTE_PARITY_PAIRS } = await import('../sync-gate.js');
    expect(BYTE_PARITY_PAIRS.length).toBeGreaterThan(0);
    // Stage every pair under the temp root with deliberately divergent content
    // — this exercises the differ branch (not the missing-file branch) and
    // asserts every registered pair fires drift.
    for (const pair of BYTE_PARITY_PAIRS) {
      const aAbs = join(root, pair.a);
      const bAbs = join(root, pair.b);
      await mkdir(dirname(aAbs), { recursive: true });
      await mkdir(dirname(bAbs), { recursive: true });
      await writeFile(aAbs, 'substrate-bytes\n');
      await writeFile(bAbs, 'seed-bytes-differ\n');
    }
    const report = await runSyncGate(root);
    expect(report.status).toBe('drift');
    for (const pair of BYTE_PARITY_PAIRS) {
      expect(report.drifts).toContainEqual(
        expect.objectContaining({
          kind: 'byte-parity-mismatch',
          sourcePath: pair.a,
        }),
      );
    }
    await rm(root, { recursive: true, force: true });
  });

  it('byte-parity-mismatch: missing pair member fires drift with detail surfacing absent path', async () => {
    // FIX-4 missing-file branch — staging the `a` member but omitting `b`
    // (or vice versa) must fire drift; readSourceFile rejects, the sync-gate
    // catches and emits a single `byte-parity-mismatch` per pair with detail
    // listing the missing path(s).
    const root = await makeRepoRoot('# INVARIANTS\n');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return { ...real, invariants: [] };
    });
    const { runSyncGate, BYTE_PARITY_PAIRS } = await import('../sync-gate.js');
    expect(BYTE_PARITY_PAIRS.length).toBeGreaterThan(0);
    // Stage only the `a` member of each pair; omit the `b` member to trigger
    // the missing-file branch.
    for (const pair of BYTE_PARITY_PAIRS) {
      const aAbs = join(root, pair.a);
      await mkdir(dirname(aAbs), { recursive: true });
      await writeFile(aAbs, 'substrate-bytes\n');
    }
    const report = await runSyncGate(root);
    expect(report.status).toBe('drift');
    for (const pair of BYTE_PARITY_PAIRS) {
      expect(report.drifts).toContainEqual(
        expect.objectContaining({
          kind: 'byte-parity-mismatch',
          sourcePath: pair.a,
          detail: expect.stringContaining('missing'),
        }),
      );
    }
    await rm(root, { recursive: true, force: true });
  });

  it('byte-parity clean: substrate ↔ seed pair files identical produces no byte-parity drift', async () => {
    // FIX-4 positive control — when both pair members exist with identical
    // content, no `byte-parity-mismatch` drift fires. The other canonical
    // drift kinds (mocked-empty manifest scenario) and the FIX-3
    // expected-id-missing IDs are filtered out so the assertion isolates the
    // byte-parity check.
    const root = await makeRepoRoot('# INVARIANTS\n');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return { ...real, invariants: [] };
    });
    const { runSyncGate, BYTE_PARITY_PAIRS } = await import('../sync-gate.js');
    expect(BYTE_PARITY_PAIRS.length).toBeGreaterThan(0);
    const matchingBody = 'identical-bytes\n';
    for (const pair of BYTE_PARITY_PAIRS) {
      const aAbs = join(root, pair.a);
      const bAbs = join(root, pair.b);
      await mkdir(dirname(aAbs), { recursive: true });
      await mkdir(dirname(bAbs), { recursive: true });
      await writeFile(aAbs, matchingBody);
      await writeFile(bAbs, matchingBody);
    }
    const report = await runSyncGate(root);
    const byteParityDrifts = report.drifts.filter((d) => d.kind === 'byte-parity-mismatch');
    expect(byteParityDrifts).toEqual([]);
    await rm(root, { recursive: true, force: true });
  });
});

describe('resolveCommonHooksDir worktree portability (issue #240)', () => {
  it('resolves to <commondir>/hooks when invoked from a worktree off a real git repo', async () => {
    const { execFileSync } = await import('node:child_process');
    const { resolve: resolvePath } = await import('node:path');

    const root = await mkdtemp(join(tmpdir(), 'keel-syncgate-wt-'));
    try {
      execFileSync('git', ['init', '-q'], { cwd: root });
      // Git 2.28+ supports `--initial-branch=main` directly. Use the
      // 2.5-compatible two-step form so the test floor matches the runtime
      // floor (sync-gate only requires `--git-common-dir` from Git 2.5+).
      execFileSync('git', ['symbolic-ref', 'HEAD', 'refs/heads/main'], { cwd: root });
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

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const { resolveCommonHooksDir } = (await import('../sync-gate.js')) as any;

      // From main checkout: <root>/.git/hooks.
      expect(resolveCommonHooksDir(root)).toBe(resolvePath(root, '.git', 'hooks'));
      // From worktree: STILL <root>/.git/hooks (NOT <wtRoot>/.git/hooks which is
      // a non-existent path under the gitlink file).
      expect(resolveCommonHooksDir(wtRoot)).toBe(resolvePath(root, '.git', 'hooks'));

      execFileSync('git', ['worktree', 'remove', '--force', wtRoot], { cwd: root });
    } finally {
      await rm(root, { recursive: true, force: true });
    }
  });

  it('falls back to <repoRoot>/.git/hooks when not in a git repo (test fixture safety)', async () => {
    const { resolve: resolvePath } = await import('node:path');
    const root = await mkdtemp(join(tmpdir(), 'keel-syncgate-nogit-'));
    try {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const { resolveCommonHooksDir } = (await import('../sync-gate.js')) as any;
      expect(resolveCommonHooksDir(root)).toBe(resolvePath(root, '.git', 'hooks'));
    } finally {
      await rm(root, { recursive: true, force: true });
    }
  });
});
