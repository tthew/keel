import { resolve } from 'node:path';
import { invariants, readSourceFile, computeSha256 } from './manifest-reader.js';

export type DriftKind =
  | 'added-to-source-only'
  | 'removed-from-source-only'
  | 'content-hash-mismatch'
  | 'removed-from-docs-only';

export interface Drift {
  kind: DriftKind;
  id?: string;
  sourcePath?: string;
  expectedHash?: string;
  actualHash?: string;
  anchor?: string;
}

export interface DriftReport {
  status: 'clean' | 'drift';
  drifts: Drift[];
}

const ANCHOR_REGEX = /^-\s+\*\*`([A-Z][A-Z0-9-]+)`\*\*/gm;

export async function readAnchors(repoRoot: string): Promise<Set<string>> {
  const content = await readSourceFile(resolve(repoRoot, 'INVARIANTS.md'));
  const anchors = new Set<string>();
  for (const match of content.matchAll(ANCHOR_REGEX)) {
    const id = match[1];
    if (id) anchors.add(id);
  }
  return anchors;
}

export async function runSyncGate(repoRoot: string): Promise<DriftReport> {
  const drifts: Drift[] = [];
  const anchors = await readAnchors(repoRoot);
  const manifestIds = new Set<string>();

  const uniqueSourcePaths = new Set<string>();
  for (const entry of invariants) {
    manifestIds.add(entry.id);
    uniqueSourcePaths.add(entry.sourcePath);
  }

  const sourceHashes = new Map<string, string | null>();
  await Promise.all(
    [...uniqueSourcePaths].map(async (sourcePath) => {
      try {
        const content = await readSourceFile(resolve(repoRoot, sourcePath));
        sourceHashes.set(sourcePath, computeSha256(content));
      } catch {
        sourceHashes.set(sourcePath, null);
      }
    }),
  );

  for (const entry of invariants) {
    const actualHash = sourceHashes.get(entry.sourcePath);
    if (actualHash === null) {
      drifts.push({
        kind: 'removed-from-source-only',
        id: entry.id,
        sourcePath: entry.sourcePath,
      });
      continue;
    }
    if (actualHash !== entry.contentHash) {
      drifts.push({
        kind: 'content-hash-mismatch',
        id: entry.id,
        sourcePath: entry.sourcePath,
        expectedHash: entry.contentHash,
        actualHash,
      });
    }
  }

  for (const anchor of anchors) {
    if (!manifestIds.has(anchor)) {
      drifts.push({
        kind: 'removed-from-docs-only',
        anchor,
      });
    }
  }

  return {
    status: drifts.length === 0 ? 'clean' : 'drift',
    drifts,
  };
}
