// Story 1.19 Task 7 / AC4 — Zod schema rejection coverage for InvariantSchema +
// InvariantsSchema per `invariants.manifest.ts:35-87`.
// RED-PHASE SCAFFOLD per /bmad-testarch-atdd: each `it.skip()` asserts the EXPECTED
// safeParse rejection (`success === false` + usable `error.issues[]`). Activation
// (remove `.skip`) by /bmad-dev-story per Subtask 7.4.
//
// AC4 reinterpretation lock (SC-2, SM-validate iter-371): "non-existent sourcePath" maps
// to "sourcePath SHAPE violation" — Zod stops at string shape; filesystem existence is
// covered by AC3's `removed-from-source-only` drift fixture.
import { describe, it, expect } from 'vitest';

const baseEntry = {
  id: 'INV-x-y',
  description: 'fixture',
  sourcePath: 'a/b.ts',
  contentHash: 'a'.repeat(64),
  anchors: ['INV-x-y'],
};

describe('InvariantSchema rejections (Story 1.19 AC4 RED-phase)', () => {
  it.skip('rejects bad ID format: BadID, INV-UPPER, inv-lower, INV-singleton, INV-bad_underscore', async () => {
    const { InvariantSchema } = await import('../invariants.manifest.js');
    for (const bad of ['BadID', 'INV-UPPER', 'inv-lower', 'INV-singleton', 'INV-bad_underscore']) {
      const result = InvariantSchema.safeParse({ ...baseEntry, id: bad });
      expect(result.success, `id "${bad}" should be rejected`).toBe(false);
    }
  });

  it.skip('rejects entry missing required field (description / id / sourcePath / contentHash / anchors)', async () => {
    const { InvariantSchema } = await import('../invariants.manifest.js');
    for (const field of ['description', 'id', 'sourcePath', 'contentHash', 'anchors']) {
      const partial = { ...baseEntry } as Record<string, unknown>;
      delete partial[field];
      const result = InvariantSchema.safeParse(partial);
      expect(result.success, `missing "${field}" should be rejected`).toBe(false);
    }
  });

  it.skip('rejects contentHash regex violations (length, uppercase hex, non-hex char)', async () => {
    const { InvariantSchema } = await import('../invariants.manifest.js');
    const bad = ['short', 'a'.repeat(63), 'a'.repeat(65), 'A'.repeat(64), 'g'.repeat(64)];
    for (const contentHash of bad) {
      const result = InvariantSchema.safeParse({ ...baseEntry, contentHash });
      expect(result.success, `contentHash "${contentHash}" should be rejected`).toBe(false);
    }
  });

  it.skip('rejects empty anchors array (z.array(...).min(1))', async () => {
    const { InvariantSchema } = await import('../invariants.manifest.js');
    const result = InvariantSchema.safeParse({ ...baseEntry, anchors: [] });
    expect(result.success).toBe(false);
  });

  it.skip('rejects sourcePath SHAPE violations (absolute, traversal, backslash)', async () => {
    const { InvariantSchema } = await import('../invariants.manifest.js');
    const bad = ['/abs/path.ts', '../traversal.ts', 'back\\slash.ts'];
    for (const sourcePath of bad) {
      const result = InvariantSchema.safeParse({ ...baseEntry, sourcePath });
      expect(result.success, `sourcePath "${sourcePath}" should be rejected`).toBe(false);
    }
  });

  it.skip('superRefine: rejects array containing duplicate ids', async () => {
    const { InvariantsSchema } = await import('../invariants.manifest.js');
    const dup = [
      { ...baseEntry, id: 'INV-dup-id' },
      { ...baseEntry, id: 'INV-dup-id', sourcePath: 'a/c.ts' },
    ];
    const result = InvariantsSchema.safeParse(dup);
    expect(result.success).toBe(false);
    expect(JSON.stringify(result)).toMatch(/duplicate invariant id: INV-dup-id/);
  });
});
