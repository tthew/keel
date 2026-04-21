/**
 * Design-token emitter for @keel/ui (Story 1.12, amended by Story 1.13).
 *
 * Reads packages/ui/tokens.json (Story 1.11 Direction A source; INV-tokens-source)
 * and deterministically emits three byte-stable artefacts per the Story 1.12 AC
 * contract and FR67-adapted purity contract:
 *
 *   - packages/ui/src/tokens.css        — web CSS custom properties
 *                                         (:root base + [data-theme="dark"] overlay)
 *   - packages/ui/tailwind.preset.ts    — Tailwind v4 preset (keelTailwindPreset)
 *   - packages/devbox/tui/theme.py      — Textual Python theme (SimpleNamespace)
 *
 * Purity guarantees (AC 6): no network; reads only tokens.json; writes only the
 * three target paths; no Date.now()/new Date()/hrtime() calls; no RNG; no
 * process.env.KEEL_* reads. The sole time-adjacent value — the provenance-header
 * source-file SHA — is resolved deterministically from committed git state
 * (with a content-hash fallback for uncommitted/untracked source).
 *
 * Invocation (AC 1):  pnpm --filter @keel/ui generate-tokens
 * --check mode   (Story 1.13 AC 3): pnpm --filter @keel/ui generate-tokens -- --check
 *   → re-emits to in-memory buffers and byte-compares against committed output
 *     paths; exits 0 silent on match, exits 1 with structured JSON diff on
 *     divergence; writes nothing.
 *
 * DTCG alias strategy: FLATTEN-AT-EMIT (§ AC 3 carve-out). {color.accent.500}
 * resolves at emit time to the leaf OKLCH literal; outputs carry resolved
 * values, not var() chains. Cycles are detected via DFS + in-progress-set and
 * fail loudly with a structured error naming the cycle edges. The in-progress
 * set is mutated (add on descent, delete on return) so sibling branches of a
 * diamond-DAG alias graph (A → {B, C}; B, C → D) resolve without false-positive
 * cycle detection (Story 1.13 AC 3 carve-out — absorbs Story 1.12 CR defer #6).
 *
 * Source-SHA resolver: uses `git log -1 --format=%h --abbrev=12 -- <path>` to
 * resolve the file's latest commit SHA. On failure, returns a TAGGED fallback
 * so CI pipelines can grep the provenance header (Story 1.13 AC 3 carve-out —
 * absorbs Story 1.12 CR defers #4 and #5):
 *   - `git-unavailable-<content-sha256[:16]>` when git binary is missing (ENOENT)
 *   - `stderr-error-<content-sha256[:16]>`    when git exits non-zero with stderr
 *   - `uncommitted-<content-sha256[:16]>`     when the file is untracked (empty stdout)
 *   - `<12-hex-sha>`                          on success (no prefix)
 * The resolver runs ONCE in main() and its result is threaded through the three
 * emit stages as a parameter (single spawn per run).
 */

import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const EMITTER_VERSION = '1.0.0';

const EMITTER_FILE = fileURLToPath(import.meta.url);
const EMITTER_DIR = path.dirname(EMITTER_FILE);
// packages/ui/scripts/ → packages/ui/ → packages/ → repo-root
const REPO_ROOT = path.resolve(EMITTER_DIR, '..', '..', '..');

const SOURCE_REL = 'packages/ui/tokens.json';
const SOURCE_ABS = path.join(REPO_ROOT, SOURCE_REL);
const CSS_ABS = path.join(REPO_ROOT, 'packages/ui/src/tokens.css');
const TAILWIND_ABS = path.join(REPO_ROOT, 'packages/ui/tailwind.preset.ts');
const PY_ABS = path.join(REPO_ROOT, 'packages/devbox/tui/theme.py');

type Leaf = { $type: string; $value: string; $description?: string };
type TokenTree = { [k: string]: TokenTree | Leaf | unknown };

function isLeaf(node: unknown): node is Leaf {
  return (
    typeof node === 'object' &&
    node !== null &&
    '$type' in node &&
    '$value' in node &&
    typeof (node as { $value: unknown }).$value === 'string'
  );
}

function readSource(): TokenTree {
  const raw = fs.readFileSync(SOURCE_ABS, 'utf-8');
  return JSON.parse(raw) as TokenTree;
}

function resolveSourceSha(): string {
  const content = fs.readFileSync(SOURCE_ABS, 'utf-8');
  const contentSha = createHash('sha256').update(content).digest('hex').slice(0, 16);
  try {
    const sha = execFileSync('git', ['log', '-1', '--format=%h', '--abbrev=12', '--', SOURCE_REL], {
      cwd: REPO_ROOT,
      encoding: 'utf-8',
      stdio: ['ignore', 'pipe', 'pipe'],
    }).trim();
    if (sha.length > 0) return sha;
    // git returned empty stdout — file is untracked
    return `uncommitted-${contentSha}`;
  } catch (err) {
    const e = err as NodeJS.ErrnoException & { stderr?: Buffer | string };
    if (e.code === 'ENOENT') {
      return `git-unavailable-${contentSha}`;
    }
    const stderr = typeof e.stderr === 'string' ? e.stderr : (e.stderr?.toString('utf-8') ?? '');
    if (stderr.trim().length > 0) {
      return `stderr-error-${contentSha}`;
    }
    return `uncommitted-${contentSha}`;
  }
}

function getBaseTree(source: TokenTree): TokenTree {
  const out: TokenTree = {};
  for (const [key, val] of Object.entries(source)) {
    if (key.startsWith('$')) continue;
    out[key] = val;
  }
  return out;
}

function getDarkOverlay(source: TokenTree): TokenTree | undefined {
  const modes = (source as { $modes?: unknown }).$modes;
  if (!modes || typeof modes !== 'object') return undefined;
  const dark = (modes as { dark?: unknown }).dark;
  if (!dark || typeof dark !== 'object') return undefined;
  return dark as TokenTree;
}

type LeafEntry = { path: string[]; leaf: Leaf };

function walkLeaves(tree: TokenTree, pathSoFar: string[] = []): LeafEntry[] {
  const out: LeafEntry[] = [];
  for (const [key, node] of Object.entries(tree)) {
    if (key.startsWith('$')) continue;
    const newPath = [...pathSoFar, key];
    if (isLeaf(node)) {
      out.push({ path: newPath, leaf: node });
    } else if (typeof node === 'object' && node !== null) {
      out.push(...walkLeaves(node as TokenTree, newPath));
    }
  }
  return out;
}

/**
 * Resolve a token $value literal, flattening {alias.path} references by DFS
 * walk of the source tree. Fails loudly on cycle or missing target.
 *
 * Cycle detection uses a MUTATED in-progress set keyed by the canonical alias
 * path being resolved at each recursion level: add before descent, delete after
 * return. This correctly handles diamond-DAG alias graphs (e.g. A → B, A → C,
 * B → D, C → D) — the sibling B and C resolutions each complete + clean up
 * their entry before the parent re-enters the resolver for its next sibling.
 * Per Story 1.13 § AC 3 carve-out (absorbs Story 1.12 CR defer #6).
 *
 * Aliases are always resolved against the base tree (pre-overlay); the Story
 * 1.11 tokens.json dark overlay only references base tokens.
 */
function resolveValue(val: string, source: TokenTree, inProgress: Set<string> = new Set()): string {
  const m = val.match(/^\{(.+)\}$/);
  if (!m) return val;
  const aliasPath = m[1];
  if (inProgress.has(aliasPath)) {
    const cycle = [...inProgress, aliasPath].join(' → ');
    throw new Error(`alias cycle detected: ${cycle}`);
  }
  const segments = aliasPath.split('.');
  let node: unknown = source;
  for (const seg of segments) {
    if (typeof node !== 'object' || node === null || !(seg in (node as Record<string, unknown>))) {
      throw new Error(`alias target not found: {${aliasPath}}`);
    }
    node = (node as Record<string, unknown>)[seg];
  }
  if (!isLeaf(node)) {
    throw new Error(`alias target is not a leaf token: {${aliasPath}}`);
  }
  inProgress.add(aliasPath);
  try {
    return resolveValue(node.$value, source, inProgress);
  } finally {
    inProgress.delete(aliasPath);
  }
}

function makeProvenanceHeader(style: 'css' | 'ts' | 'py', sha: string): string {
  const body = [
    'AUTOGENERATED from packages/ui/tokens.json — DO NOT EDIT.',
    `Source file commit SHA: ${sha}`,
    `Emitter: packages/ui/scripts/generate-tokens.ts @ v${EMITTER_VERSION}`,
    'Regenerate via: pnpm --filter @keel/ui generate-tokens',
  ];
  if (style === 'css') {
    return ['/*', ...body.map((l) => ` * ${l}`), ' */'].join('\n');
  }
  if (style === 'ts') {
    return body.map((l) => `// ${l}`).join('\n');
  }
  return body.map((l) => `# ${l}`).join('\n');
}

function writeOutput(outPath: string, content: string): void {
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, content, 'utf-8');
}

// ─── CSS emitter (§ Task 2) ────────────────────────────────────────────────

function emitCss(source: TokenTree, sha: string): string {
  const header = makeProvenanceHeader('css', sha);
  const base = getBaseTree(source);
  const dark = getDarkOverlay(source);

  const lines: string[] = [header, '', ':root {'];
  for (const { path: p, leaf } of walkLeaves(base)) {
    const varName = '--' + p.join('-');
    const resolved = resolveValue(leaf.$value, source);
    lines.push(`  ${varName}: ${resolved};`);
  }
  lines.push('}');

  if (dark) {
    lines.push('');
    lines.push('[data-theme="dark"] {');
    for (const { path: p, leaf } of walkLeaves(dark)) {
      const varName = '--' + p.join('-');
      const resolved = resolveValue(leaf.$value, source);
      lines.push(`  ${varName}: ${resolved};`);
    }
    lines.push('}');
  }

  return lines.join('\n') + '\n';
}

// ─── Tailwind preset emitter (§ Task 3) ────────────────────────────────────

function emitTailwind(source: TokenTree, sha: string): string {
  const header = makeProvenanceHeader('ts', sha);
  const base = getBaseTree(source);

  const colors: Array<[string, string]> = [];
  const fontSize: Array<[string, string]> = [];
  const fontFamily: Array<[string, string]> = [];
  const spacing: Array<[string, string]> = [];
  const borderRadius: Array<[string, string]> = [];
  const transitionDuration: Array<[string, string]> = [];
  const motionScale: Array<[string, number]> = [];
  const densityScale: Array<[string, number]> = [];
  const screens: Array<[string, string]> = [];

  for (const { path: p, leaf } of walkLeaves(base)) {
    const group = p[0];
    const rest = p.slice(1);
    const key = rest.join('-');
    const resolved = resolveValue(leaf.$value, source);
    switch (group) {
      case 'color':
        colors.push([key, resolved]);
        break;
      case 'type':
        fontSize.push([key, resolved]);
        break;
      case 'font':
        fontFamily.push([key, resolved]);
        break;
      case 'space':
        spacing.push([key, resolved]);
        break;
      case 'radius':
        borderRadius.push([key, resolved]);
        break;
      case 'motion':
        if (leaf.$type === 'number') motionScale.push([key, Number(resolved)]);
        else transitionDuration.push([key, resolved]);
        break;
      case 'density':
        densityScale.push([key, Number(resolved)]);
        break;
      case 'breakpoint':
        screens.push([key, resolved]);
        break;
      default:
        throw new Error(`unknown top-level group: ${group}`);
    }
  }

  const q = (s: string): string => JSON.stringify(s);
  const lines: string[] = [header, ''];
  lines.push('export const keelTailwindPreset = {');
  lines.push('  theme: {');
  lines.push('    extend: {');

  const emitStringMap = (label: string, entries: Array<[string, string]>): void => {
    lines.push(`      ${label}: {`);
    for (const [k, v] of entries) lines.push(`        ${q(k)}: ${q(v)},`);
    lines.push('      },');
  };
  const emitFontSize = (entries: Array<[string, string]>): void => {
    lines.push('      fontSize: {');
    for (const [k, v] of entries) {
      lines.push(`        ${q(k)}: [${q(v)}, { lineHeight: ${q('1.5')} }],`);
    }
    lines.push('      },');
  };
  const emitNumberMap = (label: string, entries: Array<[string, number]>): void => {
    lines.push(`      ${label}: {`);
    for (const [k, v] of entries) lines.push(`        ${q(k)}: ${v},`);
    lines.push('      },');
  };

  emitStringMap('colors', colors);
  emitFontSize(fontSize);
  emitStringMap('fontFamily', fontFamily);
  emitStringMap('spacing', spacing);
  emitStringMap('borderRadius', borderRadius);
  emitStringMap('transitionDuration', transitionDuration);
  emitNumberMap('motionScale', motionScale);
  emitNumberMap('densityScale', densityScale);
  emitStringMap('screens', screens);

  lines.push('    },');
  lines.push('  },');
  lines.push('} as const;');

  return lines.join('\n') + '\n';
}

// ─── TUI Python theme.py emitter (§ Task 4) ────────────────────────────────

/**
 * Python identifier transform for DTCG path segments:
 *   - hyphens → underscores per-segment (state.in-progress → state.in_progress)
 *   - digit-letter prefix swap (2xl → xl2) so the joined slug doesn't start
 *     with a digit when a single-segment path is emitted
 *   - after joining with `_`, if result still starts with a digit, prefix `_`
 *     (space.0 → 0 → _0) — valid Python identifier
 * See § AC 5 scope carve-out.
 */
function toPythonSlug(segments: string[]): string {
  const transformed = segments.map((seg) => {
    const deHyphenated = seg.replace(/-/g, '_');
    const m = deHyphenated.match(/^(\d+)([A-Za-z][A-Za-z0-9_]*)$/);
    if (m) return m[2] + m[1];
    return deHyphenated;
  });
  let joined = transformed.join('_');
  if (/^\d/.test(joined)) joined = '_' + joined;
  return joined;
}

function pyGroupName(group: string): string {
  return group === 'color' ? 'colors' : group;
}

type PyEntry = { slug: string; value: string | number };

function collectPyGroups(tree: TokenTree, source: TokenTree): Record<string, PyEntry[]> {
  const groups: Record<string, PyEntry[]> = {};
  for (const { path: p, leaf } of walkLeaves(tree)) {
    const group = p[0];
    const rest = p.slice(1);
    const resolved = resolveValue(leaf.$value, source);
    let value: string | number;
    if (leaf.$type === 'number') {
      value = Number(resolved);
    } else if (group === 'breakpoint') {
      // § AC 5 carve-out: emit breakpoint px values as bare int
      value = parseInt(resolved.replace(/px$/, ''), 10);
    } else {
      value = resolved;
    }
    const pyg = pyGroupName(group);
    if (!groups[pyg]) groups[pyg] = [];
    groups[pyg].push({ slug: toPythonSlug(rest), value });
  }
  return groups;
}

function emitPython(source: TokenTree, sha: string): string {
  const header = makeProvenanceHeader('py', sha);
  const base = getBaseTree(source);
  const dark = getDarkOverlay(source);

  const baseGroups = collectPyGroups(base, source);
  const darkGroups = dark ? collectPyGroups(dark, source) : {};

  const lines: string[] = [header, ''];
  lines.push('from types import SimpleNamespace');
  lines.push('');
  lines.push('theme = SimpleNamespace(');
  for (const [group, entries] of Object.entries(baseGroups)) {
    lines.push(`    ${group}=SimpleNamespace(`);
    for (const { slug, value } of entries) {
      const pyVal = typeof value === 'number' ? String(value) : JSON.stringify(value);
      lines.push(`        ${slug}=${pyVal},`);
    }
    lines.push('    ),');
  }
  if (Object.keys(darkGroups).length > 0) {
    lines.push('    dark=SimpleNamespace(');
    for (const [group, entries] of Object.entries(darkGroups)) {
      lines.push(`        ${group}=SimpleNamespace(`);
      for (const { slug, value } of entries) {
        const pyVal = typeof value === 'number' ? String(value) : JSON.stringify(value);
        lines.push(`            ${slug}=${pyVal},`);
      }
      lines.push('        ),');
    }
    lines.push('    ),');
  }
  lines.push(')');

  return lines.join('\n') + '\n';
}

// ─── --check mode (Story 1.13 § AC 3) ──────────────────────────────────────

type CheckDiff = {
  path: string;
  firstDiffByte: number;
  excerpt: string;
};

function firstDiffByteOffset(a: string, b: string): number {
  const len = Math.min(a.length, b.length);
  for (let i = 0; i < len; i++) {
    if (a.charCodeAt(i) !== b.charCodeAt(i)) return i;
  }
  return len;
}

function unifiedDiffExcerpt(
  expected: string,
  actual: string,
  firstDiffByte: number,
  maxLines: number,
): string {
  const lineStart = expected.lastIndexOf('\n', Math.max(0, firstDiffByte - 1)) + 1;
  const expLines = expected.slice(lineStart).split('\n');
  const actLines = actual.slice(lineStart).split('\n');
  const out: string[] = [];
  const cap = maxLines;
  let i = 0;
  while (i < Math.max(expLines.length, actLines.length) && out.length < cap) {
    const e = expLines[i];
    const a = actLines[i];
    if (e === a) {
      out.push(` ${e ?? ''}`);
    } else {
      if (e !== undefined) out.push(`-${e}`);
      if (out.length >= cap) break;
      if (a !== undefined) out.push(`+${a}`);
    }
    i++;
  }
  return out.slice(0, cap).join('\n');
}

function runCheck(
  source: TokenTree,
  sha: string,
): { status: 'clean' | 'drift'; diffs: CheckDiff[] } {
  const targets: Array<{ path: string; abs: string; content: string }> = [
    { path: 'packages/ui/src/tokens.css', abs: CSS_ABS, content: emitCss(source, sha) },
    {
      path: 'packages/ui/tailwind.preset.ts',
      abs: TAILWIND_ABS,
      content: emitTailwind(source, sha),
    },
    { path: 'packages/devbox/tui/theme.py', abs: PY_ABS, content: emitPython(source, sha) },
  ];
  const diffs: CheckDiff[] = [];
  for (const t of targets) {
    let committed: string;
    try {
      committed = fs.readFileSync(t.abs, 'utf-8');
    } catch {
      diffs.push({ path: t.path, firstDiffByte: 0, excerpt: '<output file missing>' });
      continue;
    }
    if (committed === t.content) continue;
    const firstDiffByte = firstDiffByteOffset(committed, t.content);
    diffs.push({
      path: t.path,
      firstDiffByte,
      excerpt: unifiedDiffExcerpt(committed, t.content, firstDiffByte, 5),
    });
  }
  return { status: diffs.length === 0 ? 'clean' : 'drift', diffs };
}

// ─── Main orchestrator (§ Task 1) ──────────────────────────────────────────

function main(): void {
  const args = process.argv.slice(2);
  const checkMode = args.includes('--check');
  const source = readSource();
  const sha = resolveSourceSha();

  if (checkMode) {
    const report = runCheck(source, sha);
    if (report.status === 'drift') {
      process.stderr.write(
        `${JSON.stringify({ status: 'violation', diffs: report.diffs }, null, 2)}\n`,
      );
      process.exit(1);
    }
    process.exit(0);
  }

  writeOutput(CSS_ABS, emitCss(source, sha));
  writeOutput(TAILWIND_ABS, emitTailwind(source, sha));
  writeOutput(PY_ABS, emitPython(source, sha));

  // Write sibling __init__.py so Python can treat packages/devbox/tui as a
  // package (optional per § Task 4 — emit the empty file for regularity).
  const initPath = path.join(REPO_ROOT, 'packages/devbox/tui/__init__.py');
  if (!fs.existsSync(initPath)) {
    fs.writeFileSync(initPath, '', 'utf-8');
  }

  const leafCount = walkLeaves(getBaseTree(source)).length;
  process.stdout.write(
    `emitted ${leafCount} tokens to 3 targets: packages/ui/src/tokens.css, packages/ui/tailwind.preset.ts, packages/devbox/tui/theme.py (source: ${sha}, emitter: ${EMITTER_VERSION})\n`,
  );
}

try {
  main();
} catch (err) {
  const message = err instanceof Error ? err.message : String(err);
  process.stderr.write(`[generate-tokens] error: ${message}\n`);
  process.exit(1);
}
