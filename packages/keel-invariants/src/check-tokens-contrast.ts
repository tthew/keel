#!/usr/bin/env node
/**
 * Story 1.13 — WCAG AA contrast gate.
 *
 * Reads packages/ui/tokens.json, resolves every semantic pair (text × surface,
 * border × surface, status.fg × status.bg, severity × surface, state × surface,
 * accent × surface) in light + dark overlay modes, computes gamut-mapped
 * OKLCH→sRGB contrast ratios per WCAG 2.1 § 1.4.3 / 1.4.11, and exits non-zero
 * with a structured JSON report on stderr if any pair under-shoots its
 * threshold (4.5 for normal text, 3.0 for UI components / large text).
 *
 * Invocation: pnpm keel-invariants:tokens-contrast.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { contrastRatio, parseOklch } from './color-math.js';

const FILE = fileURLToPath(import.meta.url);
const DIR = path.dirname(FILE);
// packages/keel-invariants/{dist,src}/ → packages/keel-invariants/ → packages/ → repo-root
const REPO_ROOT = path.resolve(DIR, '..', '..', '..');
const TOKENS_PATH = path.join(REPO_ROOT, 'packages/ui/tokens.json');

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

function lookupNode(tree: TokenTree | undefined, segments: string[]): unknown {
  if (!tree) return undefined;
  let node: unknown = tree;
  for (const seg of segments) {
    if (typeof node !== 'object' || node === null || !(seg in (node as Record<string, unknown>))) {
      return undefined;
    }
    node = (node as Record<string, unknown>)[seg];
  }
  return node;
}

function resolveAgainstBase(
  value: string,
  base: TokenTree,
  inProgress: Set<string> = new Set(),
): string {
  const m = value.match(/^\{(.+)\}$/);
  if (!m || m[1] === undefined) return value;
  const aliasPath: string = m[1];
  if (inProgress.has(aliasPath)) {
    throw new Error(`alias cycle detected: ${[...inProgress, aliasPath].join(' → ')}`);
  }
  const node = lookupNode(base, aliasPath.split('.'));
  if (!isLeaf(node)) {
    throw new Error(`alias target not a leaf: {${aliasPath}}`);
  }
  inProgress.add(aliasPath);
  try {
    return resolveAgainstBase(node.$value, base, inProgress);
  } finally {
    inProgress.delete(aliasPath);
  }
}

function getBase(source: TokenTree): TokenTree {
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

function resolveTokenInMode(source: TokenTree, dotPath: string, mode: 'light' | 'dark'): string {
  const segments = dotPath.split('.');
  const base = getBase(source);
  const overlay = mode === 'dark' ? getDarkOverlay(source) : undefined;
  const overlayNode = overlay ? lookupNode(overlay, segments) : undefined;
  const node = isLeaf(overlayNode) ? overlayNode : lookupNode(base, segments);
  if (!isLeaf(node)) {
    throw new Error(`token not found or not a leaf in mode ${mode}: ${dotPath}`);
  }
  return resolveAgainstBase(node.$value, base);
}

type Pair = {
  fg: string;
  bg: string;
  mode: 'light' | 'dark';
  threshold: number;
  label: string;
};

const PAIRS: Pair[] = [
  // text × surface (light)
  {
    fg: 'color.text.primary',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'text.primary × surface.default',
  },
  {
    fg: 'color.text.primary',
    bg: 'color.surface.raised',
    mode: 'light',
    threshold: 4.5,
    label: 'text.primary × surface.raised',
  },
  {
    fg: 'color.text.primary',
    bg: 'color.surface.inset',
    mode: 'light',
    threshold: 4.5,
    label: 'text.primary × surface.inset',
  },
  {
    fg: 'color.text.primary',
    bg: 'color.surface.overlay',
    mode: 'light',
    threshold: 4.5,
    label: 'text.primary × surface.overlay',
  },
  {
    fg: 'color.text.secondary',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'text.secondary × surface.default',
  },
  {
    fg: 'color.text.secondary',
    bg: 'color.surface.raised',
    mode: 'light',
    threshold: 4.5,
    label: 'text.secondary × surface.raised',
  },
  {
    fg: 'color.text.accent',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'text.accent × surface.default',
  },
  {
    fg: 'color.text.accent',
    bg: 'color.surface.raised',
    mode: 'light',
    threshold: 4.5,
    label: 'text.accent × surface.raised',
  },

  // text × surface (dark)
  {
    fg: 'color.text.primary',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] text.primary × surface.default',
  },
  {
    fg: 'color.text.primary',
    bg: 'color.surface.raised',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] text.primary × surface.raised',
  },
  {
    fg: 'color.text.primary',
    bg: 'color.surface.inset',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] text.primary × surface.inset',
  },
  {
    fg: 'color.text.primary',
    bg: 'color.surface.overlay',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] text.primary × surface.overlay',
  },
  {
    fg: 'color.text.secondary',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] text.secondary × surface.default',
  },
  {
    fg: 'color.text.secondary',
    bg: 'color.surface.raised',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] text.secondary × surface.raised',
  },
  {
    fg: 'color.text.accent',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] text.accent × surface.default',
  },
  {
    fg: 'color.text.accent',
    bg: 'color.surface.raised',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] text.accent × surface.raised',
  },

  // border.accent × surface (threshold 3.0 — focus-indicator is a UI component per WCAG 1.4.11)
  // border.default pairs are intentionally omitted: decorative separator between same-family
  // surfaces, not a WCAG-1.4.11 "user interface component". Separator visibility is carried by
  // the chosen neutral-ramp gradient, not by a quantitative contrast threshold.
  {
    fg: 'color.border.accent',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 3.0,
    label: 'border.accent × surface.default',
  },
  {
    fg: 'color.border.accent',
    bg: 'color.surface.raised',
    mode: 'light',
    threshold: 3.0,
    label: 'border.accent × surface.raised',
  },
  {
    fg: 'color.border.accent',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 3.0,
    label: '[dark] border.accent × surface.default',
  },
  {
    fg: 'color.border.accent',
    bg: 'color.surface.raised',
    mode: 'dark',
    threshold: 3.0,
    label: '[dark] border.accent × surface.raised',
  },

  // status.fg × status.bg (light + dark) — threshold 4.5
  {
    fg: 'color.status.info.fg',
    bg: 'color.status.info.bg',
    mode: 'light',
    threshold: 4.5,
    label: 'status.info.fg × status.info.bg',
  },
  {
    fg: 'color.status.success.fg',
    bg: 'color.status.success.bg',
    mode: 'light',
    threshold: 4.5,
    label: 'status.success.fg × status.success.bg',
  },
  {
    fg: 'color.status.warning.fg',
    bg: 'color.status.warning.bg',
    mode: 'light',
    threshold: 4.5,
    label: 'status.warning.fg × status.warning.bg',
  },
  {
    fg: 'color.status.error.fg',
    bg: 'color.status.error.bg',
    mode: 'light',
    threshold: 4.5,
    label: 'status.error.fg × status.error.bg',
  },
  {
    fg: 'color.status.critical.fg',
    bg: 'color.status.critical.bg',
    mode: 'light',
    threshold: 4.5,
    label: 'status.critical.fg × status.critical.bg',
  },
  {
    fg: 'color.status.info.fg',
    bg: 'color.status.info.bg',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] status.info.fg × status.info.bg',
  },
  {
    fg: 'color.status.success.fg',
    bg: 'color.status.success.bg',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] status.success.fg × status.success.bg',
  },
  {
    fg: 'color.status.warning.fg',
    bg: 'color.status.warning.bg',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] status.warning.fg × status.warning.bg',
  },
  {
    fg: 'color.status.error.fg',
    bg: 'color.status.error.bg',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] status.error.fg × status.error.bg',
  },
  {
    fg: 'color.status.critical.fg',
    bg: 'color.status.critical.bg',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] status.critical.fg × status.critical.bg',
  },

  // severity × surface.default (light + dark) — threshold 4.5 (severity badges render as normal text)
  {
    fg: 'color.severity.low',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'severity.low × surface.default',
  },
  {
    fg: 'color.severity.medium',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'severity.medium × surface.default',
  },
  {
    fg: 'color.severity.high',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'severity.high × surface.default',
  },
  {
    fg: 'color.severity.critical',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'severity.critical × surface.default',
  },
  {
    fg: 'color.severity.low',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] severity.low × surface.default',
  },
  {
    fg: 'color.severity.medium',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] severity.medium × surface.default',
  },
  {
    fg: 'color.severity.high',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] severity.high × surface.default',
  },
  {
    fg: 'color.severity.critical',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] severity.critical × surface.default',
  },

  // state × surface.default (light + dark) — threshold 4.5
  {
    fg: 'color.state.pending',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'state.pending × surface.default',
  },
  {
    fg: 'color.state.in-progress',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'state.in-progress × surface.default',
  },
  {
    fg: 'color.state.blocked',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'state.blocked × surface.default',
  },
  {
    fg: 'color.state.done',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 4.5,
    label: 'state.done × surface.default',
  },
  {
    fg: 'color.state.pending',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] state.pending × surface.default',
  },
  {
    fg: 'color.state.in-progress',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] state.in-progress × surface.default',
  },
  {
    fg: 'color.state.blocked',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] state.blocked × surface.default',
  },
  {
    fg: 'color.state.done',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 4.5,
    label: '[dark] state.done × surface.default',
  },

  // accent × surface (threshold 3.0 — non-text UI component)
  {
    fg: 'color.accent.default',
    bg: 'color.surface.default',
    mode: 'light',
    threshold: 3.0,
    label: 'accent.default × surface.default',
  },
  {
    fg: 'color.accent.default',
    bg: 'color.surface.raised',
    mode: 'light',
    threshold: 3.0,
    label: 'accent.default × surface.raised',
  },
  {
    fg: 'color.accent.default',
    bg: 'color.surface.default',
    mode: 'dark',
    threshold: 3.0,
    label: '[dark] accent.default × surface.default',
  },
  {
    fg: 'color.accent.default',
    bg: 'color.surface.raised',
    mode: 'dark',
    threshold: 3.0,
    label: '[dark] accent.default × surface.raised',
  },
];

type Finding = {
  pair: string;
  mode: 'light' | 'dark';
  fg: string;
  bg: string;
  fgHex: string;
  bgHex: string;
  ratio: number;
  threshold: number;
  delta: number;
};

function round2(n: number): number {
  return Math.round(n * 100) / 100;
}

function checkContrast(source: TokenTree): Finding[] {
  const findings: Finding[] = [];
  for (const pair of PAIRS) {
    const fgOklch = resolveTokenInMode(source, pair.fg, pair.mode);
    const bgOklch = resolveTokenInMode(source, pair.bg, pair.mode);
    if (!parseOklch(fgOklch)) {
      findings.push({
        pair: pair.label,
        mode: pair.mode,
        fg: fgOklch,
        bg: bgOklch,
        fgHex: '',
        bgHex: '',
        ratio: 0,
        threshold: pair.threshold,
        delta: -pair.threshold,
      });
      continue;
    }
    if (!parseOklch(bgOklch)) {
      findings.push({
        pair: pair.label,
        mode: pair.mode,
        fg: fgOklch,
        bg: bgOklch,
        fgHex: '',
        bgHex: '',
        ratio: 0,
        threshold: pair.threshold,
        delta: -pair.threshold,
      });
      continue;
    }
    const { ratio, fgHex, bgHex } = contrastRatio(fgOklch, bgOklch);
    if (ratio < pair.threshold) {
      findings.push({
        pair: pair.label,
        mode: pair.mode,
        fg: fgOklch,
        bg: bgOklch,
        fgHex,
        bgHex,
        ratio: round2(ratio),
        threshold: pair.threshold,
        delta: round2(ratio - pair.threshold),
      });
    }
  }
  return findings;
}

try {
  const raw = fs.readFileSync(TOKENS_PATH, 'utf-8');
  const source = JSON.parse(raw) as TokenTree;
  const findings = checkContrast(source);
  if (findings.length > 0) {
    process.stderr.write(`${JSON.stringify({ status: 'violation', findings }, null, 2)}\n`);
    process.exit(1);
  }
  process.exit(0);
} catch (err) {
  const message = err instanceof Error ? err.message : String(err);
  process.stderr.write(`${JSON.stringify({ status: 'error', message })}\n`);
  process.exit(1);
}
