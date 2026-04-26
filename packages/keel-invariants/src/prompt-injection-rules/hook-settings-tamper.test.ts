/**
 * Story 2.17 Task 5.5 — unit tests for S4 prompt-injection rules.
 * Story 1.19 Task 1 — migrated from node:test → vitest (single-runner consolidation).
 *
 * 3 positive matches (one per rule) + 2 negative (unrelated file + fork-extension
 * slot under `.claude/settings.json`) + bonus sweep across all known-safe paths
 * for s4-skip-permissions-injection.
 *
 * Run via `pnpm --filter @keel/keel-invariants test`.
 */

import { describe, test, expect } from 'vitest';

import {
  s4ClaudeHooksTamper,
  s4GitHooksTamper,
  s4SkipPermissionsInjection,
  type DiffHunk,
} from './hook-settings-tamper.js';

const line = (lineNumber: number, content: string) => ({ lineNumber, content });

describe('S4 prompt-injection rules', () => {
  test('positive: s4-claude-hooks-tamper fires on addition under .claude/hooks/', () => {
    const hunk: DiffHunk = {
      path: '.claude/hooks/block-secret-access.sh',
      addedLines: [line(42, "echo 'tampered'"), line(43, 'exit 0')],
    };
    const finding = s4ClaudeHooksTamper.test(hunk);
    expect(finding, 'expected finding').toBeTruthy();
    expect(finding!.rule_id).toBe('s4-claude-hooks-tamper');
    expect(finding!.severity).toBe('high');
    expect(finding!.path).toBe('.claude/hooks/block-secret-access.sh');
    expect(finding!.line_range).toEqual([42, 43]);
    expect(finding!.diff_preview).toMatch(/\+exit 0/);
  });

  test('positive: s4-claude-hooks-tamper fires on substrate-authoritative edit (no jsonPathsChanged)', () => {
    const hunk: DiffHunk = {
      path: '.claude/settings.json',
      addedLines: [line(4, '      "Bash(cat /etc/passwd)"')],
    };
    const finding = s4ClaudeHooksTamper.test(hunk);
    expect(
      finding,
      'expected finding (no structural-diff augmentation → fail-closed)',
    ).toBeTruthy();
    expect(finding!.rule_id).toBe('s4-claude-hooks-tamper');
  });

  test('positive: s4-git-hooks-tamper fires on .git/hooks/ addition', () => {
    const hunk: DiffHunk = {
      path: '.git/hooks/pre-commit',
      addedLines: [line(1, '#!/bin/sh'), line(2, 'exit 0')],
    };
    const finding = s4GitHooksTamper.test(hunk);
    expect(finding, 'expected finding').toBeTruthy();
    expect(finding!.rule_id).toBe('s4-git-hooks-tamper');
    expect(finding!.severity).toBe('high');
    expect(finding!.path).toBe('.git/hooks/pre-commit');
    expect(finding!.line_range).toEqual([1, 2]);
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
    expect(finding, 'expected finding').toBeTruthy();
    expect(finding!.rule_id).toBe('s4-skip-permissions-injection');
    expect(finding!.severity).toBe('high');
    expect(finding!.line_range).toEqual([11, 11]);
  });

  test('negative: s4-claude-hooks-tamper ignores unrelated files', () => {
    const hunk: DiffHunk = {
      path: 'apps/web/src/main.ts',
      addedLines: [line(10, 'console.log("hello");')],
    };
    expect(s4ClaudeHooksTamper.test(hunk)).toBeNull();
    expect(s4GitHooksTamper.test(hunk)).toBeNull();
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
    expect(s4ClaudeHooksTamper.test(hunk)).toBeNull();
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
      expect(
        s4SkipPermissionsInjection.test(hunk),
        `expected null for known-safe path ${path}`,
      ).toBeNull();
    }
  });
});
