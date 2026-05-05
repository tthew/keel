import { describe, test, expect } from 'vitest';
import { invariants } from '../invariants.manifest.js';

describe('INV-fr14i-ci-workflow-presence (Story 1.20)', () => {
  const entry = invariants.find((i) => i.id === 'INV-fr14i-ci-workflow-presence');

  test('entry exists in manifest', () => {
    expect(entry).toBeDefined();
  });

  test('sourcePath is .github/workflows/ci.yml', () => {
    expect(entry?.sourcePath).toBe('.github/workflows/ci.yml');
  });

  test('whole-file hashScope (no hashScope field)', () => {
    expect(entry?.hashScope).toBeUndefined();
  });

  test('anchors array contains the canonical id', () => {
    expect(entry?.anchors).toEqual(['INV-fr14i-ci-workflow-presence']);
  });

  test('contentHash matches /^[0-9a-f]{64}$/', () => {
    expect(entry?.contentHash).toMatch(/^[0-9a-f]{64}$/);
  });
});
