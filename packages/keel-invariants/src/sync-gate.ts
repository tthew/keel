import { resolve } from 'node:path';
import { execFileSync } from 'node:child_process';
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

let cachedHooksDir: { repoRoot: string; hooksDir: string } | null = null;

export function resolveCommonHooksDir(repoRoot: string): string {
  if (cachedHooksDir && cachedHooksDir.repoRoot === repoRoot) {
    return cachedHooksDir.hooksDir;
  }
  // Strip git-discovery env vars so a wrapper exporting them cannot redirect
  // git rev-parse --git-common-dir to a different repository identity.
  // GIT_DIR/GIT_COMMON_DIR/GIT_WORK_TREE override repo discovery directly;
  // GIT_CEILING_DIRECTORIES halts upward discovery.
  const gitEnv = { ...process.env };
  delete gitEnv.GIT_DIR;
  delete gitEnv.GIT_COMMON_DIR;
  delete gitEnv.GIT_WORK_TREE;
  delete gitEnv.GIT_CEILING_DIRECTORIES;
  let hooksDir: string;
  try {
    const commonDir = execFileSync('git', ['rev-parse', '--git-common-dir'], {
      cwd: repoRoot,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
      env: gitEnv,
    }).trim();
    // commonDir may be relative ('.git') from main or absolute from a worktree.
    hooksDir = resolve(repoRoot, commonDir, 'hooks');
  } catch (error) {
    // git rev-parse exits 128 when cwd is not in a git repo (test fixtures,
    // fresh-clone pre-init). Any other failure — ENOENT for missing git on
    // PATH, EACCES on .git/ — indicates a broken environment that should
    // surface as a real error, not silently fall back to a stale path.
    const err = error as NodeJS.ErrnoException & { status?: number };
    if (err.status !== 128) {
      throw err;
    }
    hooksDir = resolve(repoRoot, '.git/hooks');
  }
  cachedHooksDir = { repoRoot, hooksDir };
  return hooksDir;
}

export type DriftKind =
  | 'added-to-source-only'
  | 'removed-from-source-only'
  | 'content-hash-mismatch'
  | 'removed-from-docs-only'
  | 'expected-id-missing'
  | 'byte-parity-mismatch'
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

// FIX-3 (PR #230 review-fix-arc) — out-of-band fail-closed snapshot of stable
// IDs that MUST appear in invariants.manifest.ts. Closes the bypass class
// where dropping BOTH a manifest entry AND its INVARIANTS.md anchor in the
// same commit silently passes the symmetric drift checks (both for-loops in
// runSyncGate skip absent items, so the protection silently disappears).
//
// Maintenance contract: when a new invariant is legitimately added, append
// its ID here in the same commit that adds the manifest entry. When a
// legitimate deprecation/replacement happens (rare; AMEND path against
// docs/invariants/), remove the ID here in the same commit. Editing this
// file is denied to in-session AI agents by the L1 install-boundary hook
// (.claude/hooks/block-secret-access.sh — see l1_path_re), so any change
// to this snapshot must transit human review.

// WONTFIX (PR #230 R4-Inv-I07) — anchor-range pointer-mutation residual.
// An out-of-session PR could retarget the :start/:end marker pair below to
// a no-op range with matching contentHash and bypass this check. Pre-
// existing structural limit of the anchor-range hashScope layer (applies to
// every anchor-range entry, not novel to this entry). Mitigated by L1-
// protection of invariants.manifest.ts (in-session AI agent edits denied
// per .claude/hooks/block-secret-access.sh l1_path_re) plus human PR
// review at the git layer. Do NOT attempt schema-level shape-pin; would
// require AST parsing of TS source declarations and would reject every
// legitimate marker-rename during evolution.
// INV-keel-invariants-sync-gate-snapshots:start — see invariants.manifest.ts entry
export const EXPECTED_INVARIANT_IDS: readonly string[] = [
  'INV-tsconfig-base',
  'INV-eslint-shared',
  'INV-prettier-shared',
  'INV-commitlint-shared',
  'INV-eslint-import-boundary',
  'INV-prek-pre-commit-config',
  'INV-prek-prepare-lifecycle',
  'INV-prek-prepare-worktree-guard',
  'INV-prek-commit-msg-config',
  'INV-no-verify-bypass',
  'INV-ralph-halt-path-resolution',
  'INV-ralph-halt-reason-enum',
  'INV-tokens-schema-contract',
  'INV-tokens-semantic-rationale',
  'INV-tokens-source',
  'INV-tokens-emitter',
  'INV-tokens-schema-validate',
  'INV-tokens-contrast-check',
  'INV-tokens-sync-gate',
  'INV-release-please-config',
  'INV-release-please-manifest',
  'INV-release-please-rationale',
  'INV-deps-version-pinning',
  'INV-renovate-rationale',
  'INV-fork-extension-rationale',
  'INV-fork-invariants-scaffold',
  'INV-devbox-dind-available',
  'INV-devbox-egress-contract',
  'INV-devbox-homedev-named-volume',
  'INV-devbox-mode',
  'INV-devbox-prereq-check',
  'INV-devbox-ssh',
  'INV-devbox-healthcheck',
  'INV-devbox-legacy-branch-retention',
  'INV-gitignored-secret-commit-deny',
  'INV-claude-hook-secret-denylist',
  'INV-claude-hook-secret-denylist-doc',
  'INV-claude-settings-deny-rules',
  'INV-claude-settings-seed',
  'INV-claude-hook-secret-denylist-seed',
  'INV-git-hooks-preservation-enumeration',
  'INV-git-hooks-preservation',
  'INV-package-test-coverage-floor',
  'INV-fr14i-ci-workflow-presence',
  'INV-keel-invariants-sync-gate-snapshots',
] as const;

// FIX-4 (PR #230 review-fix-arc) — out-of-band fail-closed snapshot of
// substrate↔seed file pairs that MUST be byte-identical. Closes the bypass
// class where substrate (`.claude/...`) and its seed
// (`packages/keel-templates/src/seeds/.claude/...`) carry independent
// contentHash entries in invariants.manifest.ts: an attacker who mutates
// BOTH files in lockstep with new (matching) hashes silently slips both
// per-file gates. The sync-gate reads each pair from disk and compares
// SHA-256 at audit time, so the substrate↔seed equivalence is enforced at
// the gate, not on the (mutable) manifest.
//
// Maintenance contract: when a new substrate↔seed pair is legitimately
// added, append it here in the same commit that registers both manifest
// entries. The L1 install-boundary hook denies in-session AI agent edits
// of this file, so any change must transit human review (same protection
// model as EXPECTED_INVARIANT_IDS above).
export const BYTE_PARITY_PAIRS: readonly {
  readonly a: string;
  readonly b: string;
  readonly reason: string;
}[] = [
  {
    a: '.claude/hooks/block-secret-access.sh',
    b: 'packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh',
    reason:
      'INV-claude-hook-secret-denylist substrate ↔ INV-claude-hook-secret-denylist-seed must be byte-identical (Story 2.16 substrate, fork-seed parity).',
  },
] as const;
// INV-keel-invariants-sync-gate-snapshots:end

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
    const hooksDir = resolveCommonHooksDir(repoRoot);
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

  // FIX-3 — out-of-band fail-closed snapshot. Any EXPECTED_INVARIANT_IDS entry
  // missing from the manifest fires drift even if the corresponding
  // INVARIANTS.md anchor was also dropped. Defends against drop+anchor-remove
  // bypass class.
  for (const expectedId of EXPECTED_INVARIANT_IDS) {
    if (!manifestIds.has(expectedId)) {
      drifts.push({
        kind: 'expected-id-missing',
        id: expectedId,
      });
    }
  }

  // FIX-4 — out-of-band byte-parity check for substrate↔seed pairs. Defends
  // against the lockstep-hash-update bypass class: even if both manifest
  // contentHash entries are mutated to match each other, the sync-gate
  // reads both files and compares SHA-256 directly. Mismatch (or either
  // file missing) fires `byte-parity-mismatch` drift.
  for (const pair of BYTE_PARITY_PAIRS) {
    const aAbs = resolve(repoRoot, pair.a);
    const bAbs = resolve(repoRoot, pair.b);
    let aContent: string | null = null;
    let bContent: string | null = null;
    try {
      aContent = await readSourceFile(aAbs);
    } catch {
      /* missing — handled below */
    }
    try {
      bContent = await readSourceFile(bAbs);
    } catch {
      /* missing — handled below */
    }
    const missing: string[] = [];
    if (aContent === null) missing.push(pair.a);
    if (bContent === null) missing.push(pair.b);
    if (missing.length > 0) {
      drifts.push({
        kind: 'byte-parity-mismatch',
        sourcePath: pair.a,
        detail: `${pair.a} ↔ ${pair.b}: missing ${missing.join(' + ')} — ${pair.reason}`,
      });
      continue;
    }
    const aHash = computeSha256(aContent as string);
    const bHash = computeSha256(bContent as string);
    if (aHash !== bHash) {
      drifts.push({
        kind: 'byte-parity-mismatch',
        sourcePath: pair.a,
        expectedHash: aHash,
        actualHash: bHash,
        detail: `${pair.a} ↔ ${pair.b}: ${aHash} vs ${bHash} — ${pair.reason}`,
      });
    }
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
