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
    // EXPECTED_INVARIANT_IDS snapshot (the FIX-3 dedicated case below covers
    // that bypass class). Filter those out to verify the four canonical drift
    // classes are absent for an aligned manifest+docs+source.
    const canonical = report.drifts.filter((d) => d.kind !== 'expected-id-missing');
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
});
