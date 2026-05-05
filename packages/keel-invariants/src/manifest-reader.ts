import { readFile, readdir } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';

export { invariants } from './invariants.manifest.js';
export type { Invariant, HashScope } from './invariants.manifest.js';

const execFileAsync = promisify(execFile);

export async function readSourceFile(absPath: string): Promise<string> {
  return readFile(absPath, 'utf-8');
}

export function computeSha256(content: string): string {
  return createHash('sha256').update(content).digest('hex');
}

export async function computeSubtreeHash(absFilePath: string, jqFilter: string): Promise<string> {
  const { stdout } = await execFileAsync('jq', ['-c', jqFilter, absFilePath], {
    maxBuffer: 10 * 1024 * 1024,
  });
  return computeSha256(stdout);
}

export async function computeAnchorRangeHash(
  absFilePath: string,
  startMarker: string,
  endMarker: string,
): Promise<string> {
  const content = await readSourceFile(absFilePath);
  const startIdx = content.indexOf(startMarker);
  if (startIdx === -1) {
    throw new Error(`anchor-range startMarker not found in ${absFilePath}: ${startMarker}`);
  }
  const endSearchFrom = startIdx + startMarker.length;
  const endIdx = content.indexOf(endMarker, endSearchFrom);
  if (endIdx === -1) {
    throw new Error(`anchor-range endMarker not found in ${absFilePath}: ${endMarker}`);
  }
  const region = content.slice(startIdx, endIdx + endMarker.length);
  return computeSha256(region);
}

export interface ExpectedHook {
  readonly name: string;
  readonly shebangPattern: RegExp;
}

export interface NamesAndShebangsResult {
  readonly hash: string;
  readonly missing: readonly string[];
  readonly shebangMismatches: readonly { name: string; actual: string }[];
}

// Canonical form: sort entries by name, render each as `${name}\t${shebang-line}`, join with '\n',
// terminating newline. Missing files render as `${name}\t<MISSING>`. Shebang mismatches do not
// change the hash body (hash captures actual shebang text) but are surfaced separately so the
// sync-gate can emit a dedicated drift reason.
export async function computeNamesAndShebangsHash(
  absHooksDir: string,
  expected: readonly ExpectedHook[],
): Promise<NamesAndShebangsResult> {
  const sortedExpected = [...expected].sort((a, b) => a.name.localeCompare(b.name));
  const lines: string[] = [];
  const missing: string[] = [];
  const shebangMismatches: { name: string; actual: string }[] = [];
  for (const entry of sortedExpected) {
    const hookPath = join(absHooksDir, entry.name);
    let shebang = '<MISSING>';
    try {
      const content = await readSourceFile(hookPath);
      const firstNewline = content.indexOf('\n');
      shebang = firstNewline === -1 ? content : content.slice(0, firstNewline);
      if (!entry.shebangPattern.test(shebang)) {
        shebangMismatches.push({ name: entry.name, actual: shebang });
      }
    } catch {
      missing.push(entry.name);
    }
    lines.push(`${entry.name}\t${shebang}`);
  }
  return {
    hash: computeSha256(lines.join('\n') + '\n'),
    missing,
    shebangMismatches,
  };
}

// Load `EXPECTED_HOOKS` from an enumerator module. Enumerator exports
// `readonly { name: string; shebangPattern: RegExp }[]`.
// Convention (Story 2.17 Dev Notes § sourcePath semantics): enumeratorPath points at the TS
// source file (acts as the drift-protection anchor). At runtime we load from the compiled dist
// artefact — the .ts → .js / src/ → dist/ translation is the minimum needed to make Node's
// dynamic import work against a TypeScript-authored enumerator. Non-.ts paths import as-is.
export async function loadExpectedHooks(
  absEnumeratorPath: string,
): Promise<readonly ExpectedHook[]> {
  const loadPath = absEnumeratorPath.endsWith('.ts')
    ? absEnumeratorPath.replace(/\/src\//, '/dist/').replace(/\.ts$/, '.js')
    : absEnumeratorPath;
  const moduleUrl = pathToFileURL(loadPath).href;
  const mod = (await import(moduleUrl)) as { EXPECTED_HOOKS?: readonly ExpectedHook[] };
  if (!mod.EXPECTED_HOOKS || !Array.isArray(mod.EXPECTED_HOOKS)) {
    throw new Error(`enumerator ${absEnumeratorPath} missing EXPECTED_HOOKS export`);
  }
  return mod.EXPECTED_HOOKS;
}

// Lightweight wrapper to discover git-hooks directory when walker cannot assume cwd is repo-root.
export async function listDirIfExists(absPath: string): Promise<string[]> {
  try {
    return await readdir(absPath);
  } catch {
    return [];
  }
}
