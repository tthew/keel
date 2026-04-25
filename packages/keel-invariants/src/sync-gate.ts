import { resolve } from 'node:path';
import type { Invariant } from './invariants.manifest.js';
import {
  invariants,
  readSourceFile,
  computeSha256,
  computeSubtreeHash,
  computeAnchorRangeHash,
  computeNamesAndShebangsHash,
  loadExpectedHooks,
} from './manifest-reader.js';

export type DriftKind =
  | 'added-to-source-only'
  | 'removed-from-source-only'
  | 'content-hash-mismatch'
  | 'removed-from-docs-only'
  | 'git-hook-missing'
  | 'git-hook-shebang-mismatch';

export interface Drift {
  kind: DriftKind;
  id?: string;
  sourcePath?: string;
  expectedHash?: string;
  actualHash?: string;
  anchor?: string;
  detail?: string;
}

export interface DriftReport {
  status: 'clean' | 'drift';
  drifts: Drift[];
}

const ANCHOR_REGEX = /^-\s+\*\*`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)`\*\*/gm;

export async function readAnchors(repoRoot: string): Promise<Set<string>> {
  const content = await readSourceFile(resolve(repoRoot, 'INVARIANTS.md'));
  const anchors = new Set<string>();
  for (const match of content.matchAll(ANCHOR_REGEX)) {
    const id = match[1];
    if (id) anchors.add(id);
  }
  return anchors;
}

interface HashResult {
  kind: 'hash';
  hash: string;
}

interface ReadErrorResult {
  kind: 'read-error';
}

interface NamesAndShebangsErrorResult {
  kind: 'names-and-shebangs';
  hash: string;
  missing: readonly string[];
  shebangMismatches: readonly { name: string; actual: string }[];
}

type EntryHashResult = HashResult | ReadErrorResult | NamesAndShebangsErrorResult;

async function computeEntryHash(repoRoot: string, entry: Invariant): Promise<EntryHashResult> {
  const sourceAbs = resolve(repoRoot, entry.sourcePath);
  const scope = entry.hashScope;
  try {
    if (!scope) {
      const content = await readSourceFile(sourceAbs);
      return { kind: 'hash', hash: computeSha256(content) };
    }
    if (scope.kind === 'jq-subtree') {
      const hash = await computeSubtreeHash(sourceAbs, scope.filter);
      return { kind: 'hash', hash };
    }
    if (scope.kind === 'anchor-range') {
      const hash = await computeAnchorRangeHash(sourceAbs, scope.startMarker, scope.endMarker);
      return { kind: 'hash', hash };
    }
    // names-and-shebangs: enumerator file read; hook directory (.git/hooks/) walked.
    const enumeratorAbs = resolve(repoRoot, scope.enumeratorPath);
    const expected = await loadExpectedHooks(enumeratorAbs);
    const hooksDir = resolve(repoRoot, '.git/hooks');
    const { hash, missing, shebangMismatches } = await computeNamesAndShebangsHash(
      hooksDir,
      expected,
    );
    if (missing.length > 0 || shebangMismatches.length > 0) {
      return { kind: 'names-and-shebangs', hash, missing, shebangMismatches };
    }
    return { kind: 'hash', hash };
  } catch {
    return { kind: 'read-error' };
  }
}

export async function runSyncGate(repoRoot: string): Promise<DriftReport> {
  const drifts: Drift[] = [];
  const anchors = await readAnchors(repoRoot);
  const manifestIds = new Set<string>();
  for (const entry of invariants) {
    manifestIds.add(entry.id);
  }

  // Compute one hash per entry (entries may share sourcePath but have distinct hashScopes).
  const entryResults = await Promise.all(
    invariants.map(async (entry) => ({ entry, result: await computeEntryHash(repoRoot, entry) })),
  );

  for (const { entry, result } of entryResults) {
    if (!anchors.has(entry.id)) {
      drifts.push({
        kind: 'added-to-source-only',
        id: entry.id,
        sourcePath: entry.sourcePath,
      });
    }
    if (result.kind === 'read-error') {
      drifts.push({
        kind: 'removed-from-source-only',
        id: entry.id,
        sourcePath: entry.sourcePath,
      });
      continue;
    }
    if (result.kind === 'names-and-shebangs') {
      for (const name of result.missing) {
        drifts.push({
          kind: 'git-hook-missing',
          id: entry.id,
          sourcePath: entry.sourcePath,
          detail: name,
        });
      }
      for (const { name, actual } of result.shebangMismatches) {
        drifts.push({
          kind: 'git-hook-shebang-mismatch',
          id: entry.id,
          sourcePath: entry.sourcePath,
          detail: `${name}: ${actual}`,
        });
      }
      // Fall through to hash comparison using result.hash.
    }
    const actualHash = result.hash;
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
