import { readFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';

export { invariants } from './invariants.manifest.js';
export type { Invariant } from './invariants.manifest.js';

export async function readSourceFile(absPath: string): Promise<string> {
  return readFile(absPath, 'utf-8');
}

export function computeSha256(content: string): string {
  return createHash('sha256').update(content).digest('hex');
}
