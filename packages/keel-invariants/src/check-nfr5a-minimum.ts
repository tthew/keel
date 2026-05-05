#!/usr/bin/env node
/**
 * Story 2.17 Task 11.2 — NFR5a deny-list minimum-entry gate (D-8 SC-17 close-out).
 *
 * Asserts `.claude/settings.json` `.permissions.deny` contains ≥13 entries AND
 * `.permissions.allow` contains ≥6 entries — the lower bounds pinned by Story
 * 2.15 AC 2 (13 deny + 6 allow seeded from NFR5a Read + Bash axes).
 *
 * Complementary to the sub-tree contentHash entry `INV-claude-settings-deny-rules`
 * which catches EDITS to the substrate-authoritative sub-tree. This minimum-entry
 * gate catches REMOVALS from forks: fork operators MAY extend (append deny /
 * allow rules) but MUST NOT remove the substrate baseline. The sub-tree hash
 * alone cannot detect removals once a fork has diverged; the numeric lower bound
 * does.
 *
 * Invocation: `pnpm keel-invariants:nfr5a-minimum`. Pre-commit wiring fires when
 * `.claude/settings.json` is staged (see `.pre-commit-config.yaml`).
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const FILE = fileURLToPath(import.meta.url);
const DIR = path.dirname(FILE);
// packages/keel-invariants/{dist,src}/ → packages/keel-invariants/ → packages/ → repo-root
const REPO_ROOT = path.resolve(DIR, '..', '..', '..');
const SETTINGS_PATH = path.join(REPO_ROOT, '.claude/settings.json');

const DENY_MIN = 13;
const ALLOW_MIN = 6;

interface Settings {
  permissions?: {
    deny?: unknown;
    allow?: unknown;
  };
}

function fail(message: string): never {
  process.stderr.write(
    `${JSON.stringify({ status: 'violation', path: SETTINGS_PATH, message })}\n`,
  );
  process.exit(1);
}

try {
  const raw = fs.readFileSync(SETTINGS_PATH, 'utf-8');
  const parsed = JSON.parse(raw) as Settings;

  if (!parsed.permissions || typeof parsed.permissions !== 'object') {
    fail('.permissions is missing or not an object');
  }

  const deny = parsed.permissions.deny;
  const allow = parsed.permissions.allow;

  if (!Array.isArray(deny)) {
    fail('.permissions.deny is missing or not an array');
  }
  if (!Array.isArray(allow)) {
    fail('.permissions.allow is missing or not an array');
  }

  if (deny.length < DENY_MIN) {
    fail(
      `.permissions.deny has ${deny.length} entries; NFR5a minimum is ${DENY_MIN} ` +
        `(Story 2.15 AC 2). Forks MAY extend but MUST NOT remove substrate deny rules.`,
    );
  }
  if (allow.length < ALLOW_MIN) {
    fail(
      `.permissions.allow has ${allow.length} entries; NFR5a minimum is ${ALLOW_MIN} ` +
        `(Story 2.15 AC 2). Forks MAY extend but MUST NOT remove substrate allow rules.`,
    );
  }

  process.exit(0);
} catch (err) {
  if (err instanceof Error && 'code' in err && (err as NodeJS.ErrnoException).code === 'ENOENT') {
    fail(`.claude/settings.json not found`);
  }
  const message = err instanceof Error ? err.message : String(err);
  process.stderr.write(`${JSON.stringify({ status: 'error', path: SETTINGS_PATH, message })}\n`);
  process.exit(1);
}
