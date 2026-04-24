/**
 * Story 2.17 Task 5.5 — unit tests for S4 prompt-injection rules.
 *
 * 3 positive matches (one per rule) + 2 negative (unrelated file + fork-extension
 * slot under `.claude/settings.json`) + bonus sweep across all known-safe paths
 * for s4-skip-permissions-injection.
 *
 * Run via `node --test packages/keel-invariants/dist/prompt-injection-rules/*.test.js`
 * after `pnpm --filter @keel/keel-invariants build`.
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';

import {
  s4ClaudeHooksTamper,
  s4GitHooksTamper,
  s4SkipPermissionsInjection,
  type DiffHunk,
} from './hook-settings-tamper.js';

const line = (lineNumber: number, content: string) => ({ lineNumber, content });

test('positive: s4-claude-hooks-tamper fires on addition under .claude/hooks/', () => {
  const hunk: DiffHunk = {
    path: '.claude/hooks/block-secret-access.sh',
    addedLines: [line(42, "echo 'tampered'"), line(43, 'exit 0')],
  };
  const finding = s4ClaudeHooksTamper.test(hunk);
  assert.ok(finding, 'expected finding');
  assert.equal(finding.rule_id, 's4-claude-hooks-tamper');
  assert.equal(finding.severity, 'high');
  assert.equal(finding.path, '.claude/hooks/block-secret-access.sh');
  assert.deepEqual(finding.line_range, [42, 43]);
  assert.match(finding.diff_preview, /\+exit 0/);
});

test('positive: s4-claude-hooks-tamper fires on substrate-authoritative edit (no jsonPathsChanged)', () => {
  const hunk: DiffHunk = {
    path: '.claude/settings.json',
    addedLines: [line(4, '      "Bash(cat /etc/passwd)"')],
  };
  const finding = s4ClaudeHooksTamper.test(hunk);
  assert.ok(finding, 'expected finding (no structural-diff augmentation → fail-closed)');
  assert.equal(finding.rule_id, 's4-claude-hooks-tamper');
});

test('positive: s4-git-hooks-tamper fires on .git/hooks/ addition', () => {
  const hunk: DiffHunk = {
    path: '.git/hooks/pre-commit',
    addedLines: [line(1, '#!/bin/sh'), line(2, 'exit 0')],
  };
  const finding = s4GitHooksTamper.test(hunk);
  assert.ok(finding, 'expected finding');
  assert.equal(finding.rule_id, 's4-git-hooks-tamper');
  assert.equal(finding.severity, 'high');
  assert.equal(finding.path, '.git/hooks/pre-commit');
  assert.deepEqual(finding.line_range, [1, 2]);
});

test('positive: s4-skip-permissions-injection fires outside known-safe paths', () => {
  const hunk: DiffHunk = {
    path: 'apps/web/src/runner.ts',
    addedLines: [
      line(10, 'const safe = true;'),
      line(11, "const cmd = 'claude --dangerously-skip-permissions';"),
    ],
  };
  const finding = s4SkipPermissionsInjection.test(hunk);
  assert.ok(finding, 'expected finding');
  assert.equal(finding.rule_id, 's4-skip-permissions-injection');
  assert.equal(finding.severity, 'high');
  assert.deepEqual(finding.line_range, [11, 11]);
});

test('negative: s4-claude-hooks-tamper ignores unrelated files', () => {
  const hunk: DiffHunk = {
    path: 'apps/web/src/main.ts',
    addedLines: [line(10, 'console.log("hello");')],
  };
  assert.equal(s4ClaudeHooksTamper.test(hunk), null);
  assert.equal(s4GitHooksTamper.test(hunk), null);
});

test('negative: s4-claude-hooks-tamper does NOT fire on fork-extension slot .hooks.PostToolUse edit', () => {
  const hunk: DiffHunk = {
    path: '.claude/settings.json',
    addedLines: [
      line(120, '    "PostToolUse": ['),
      line(
        121,
        '      { "matcher": "Write", "hooks": [{"type": "command", "command": ".claude/hooks/block-secret-access.fork.sh"}] }',
      ),
      line(122, '    ],'),
    ],
    jsonPathsChanged: ['hooks.PostToolUse', 'hooks.PostToolUse[0]'],
  };
  assert.equal(s4ClaudeHooksTamper.test(hunk), null);
});

test('negative: s4-skip-permissions-injection respects all known-safe paths', () => {
  const safePaths = [
    'packages/devbox/scripts/run.sh',
    'packages/keel-invariants/src/prompt-injection-rules/hook-settings-tamper.ts',
    '.ralph/PROMPT_build.md',
    'AGENTS.md',
    'CLAUDE.md',
    'RALPH.md',
    'INVARIANTS.md',
    'docs/ralph.md',
    'docs/invariants/claude-hook-denylist.md',
    '_bmad-output/planning-artifacts/architecture.md',
    'README.md',
  ];
  for (const path of safePaths) {
    const hunk: DiffHunk = {
      path,
      addedLines: [line(5, '... --dangerously-skip-permissions ...')],
    };
    assert.equal(
      s4SkipPermissionsInjection.test(hunk),
      null,
      `expected null for known-safe path ${path}`,
    );
  }
});
