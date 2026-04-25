import { describe, it, expect } from 'vitest';
import { readSourceFile } from '../manifest-reader.js';

describe('keel-invariants smoke', () => {
  it('module loads + readSourceFile export is callable', () => {
    expect(typeof readSourceFile).toBe('function');
  });
});
