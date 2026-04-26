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
import { mkdtemp, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
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
  it.skip('added-to-source-only: manifest entry exists, INVARIANTS.md has no anchor', async () => {
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

  it.skip('removed-from-source-only: INVARIANTS.md has anchor, sourcePath is missing on disk', async () => {
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

  it.skip('removed-from-docs-only: INVARIANTS.md has orphan anchor, manifest is empty', async () => {
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

  it.skip('content-hash-mismatch: source file content does not match manifest contentHash', async () => {
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

  it.skip('clean baseline: aligned manifest + docs + source returns status: clean', async () => {
    const body = 'aligned content\n';
    const root = await makeRepoRoot('# INVARIANTS\n- **`INV-aligned`** — aligned.\n');
    await writeFile(join(root, 'src.ts'), body);
    const hash = createHash('sha256').update(body).digest('hex');
    vi.doMock('../manifest-reader.js', async () => {
      const real =
        await vi.importActual<typeof import('../manifest-reader.js')>('../manifest-reader.js');
      return {
        ...real,
        invariants: [
          {
            id: 'INV-aligned',
            description: 'fixture',
            sourcePath: 'src.ts',
            contentHash: hash,
            anchors: ['INV-aligned'],
          },
        ],
      };
    });
    const { runSyncGate } = await import('../sync-gate.js');
    const report = await runSyncGate(root);
    expect(report.status).toBe('clean');
    expect(report.drifts).toEqual([]);
    await rm(root, { recursive: true, force: true });
  });
});
