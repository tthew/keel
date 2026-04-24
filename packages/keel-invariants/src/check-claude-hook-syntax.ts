#!/usr/bin/env node
/**
 * Story 2.17 Task 12 — pre-install syntax check for `.claude/hooks/*.sh`.
 *
 * Codifies iter-305 NOVEL LESSON: Claude Code 2.1.116 empirically treats
 * `hooks.PreToolUse` block-parse-failure as block-with-stdout-suppression (contrary to upstream
 * docs suggesting 'fail-open'). A syntax-error in the registered hook bricks
 * Bash/Read/Edit/Write/Grep/Glob tool surfaces, and recovery requires a Monitor-based Python
 * escape-hatch. This gate refuses any commit where any `.claude/hooks/*.sh` fails the
 * shebang-appropriate `-n` parse check.
 *
 * Dispatch: shebang → interpreter.
 *   `#!/usr/bin/env bash` or `#!/bin/bash` → `bash -n`
 *   `#!/bin/sh` or `#!/usr/bin/env sh` → `bash -n` AND `dash -n` (dash is the strict POSIX check)
 *   other / missing → `bash -n` (conservative default)
 *
 * A dash-incompatible hook with a bash shebang is by-design (e.g. uses `[[`, `=~`). A
 * bash-incompatible hook with a sh shebang is always a bug — catch at this gate.
 */
import { readdir, readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const execFileAsync = promisify(execFile);

interface SyntaxFailure {
  file: string;
  checker: 'bash' | 'dash';
  stderr: string;
}

async function firstLine(file: string): Promise<string> {
  try {
    const content = await readFile(file, 'utf-8');
    const nl = content.indexOf('\n');
    return nl === -1 ? content : content.slice(0, nl);
  } catch {
    return '';
  }
}

function checkersFor(shebang: string): readonly ('bash' | 'dash')[] {
  if (/\b(bash)\b/.test(shebang)) return ['bash'];
  if (/\b(sh)\b/.test(shebang)) return ['bash', 'dash'];
  return ['bash'];
}

async function checkOne(checker: 'bash' | 'dash', file: string): Promise<SyntaxFailure | null> {
  try {
    await execFileAsync(checker, ['-n', file], { maxBuffer: 1024 * 1024 });
    return null;
  } catch (err: unknown) {
    const e = err as { stderr?: string; message?: string };
    return {
      file,
      checker,
      stderr: (e.stderr || e.message || 'unknown error').trim(),
    };
  }
}

async function main(): Promise<void> {
  const repoRoot = resolve(import.meta.dirname, '../../..');
  const hooksDir = resolve(repoRoot, '.claude/hooks');
  let entries: string[];
  try {
    entries = await readdir(hooksDir);
  } catch {
    // No .claude/hooks/ → nothing to check. Silent success.
    return;
  }
  const shFiles = entries
    .filter((name) => name.endsWith('.sh'))
    .map((name) => resolve(hooksDir, name));

  const failures: SyntaxFailure[] = [];
  for (const file of shFiles) {
    const shebang = await firstLine(file);
    const checkers = checkersFor(shebang);
    for (const checker of checkers) {
      const failure = await checkOne(checker, file);
      if (failure) failures.push(failure);
    }
  }

  if (failures.length > 0) {
    process.stderr.write(
      `check-claude-hook-syntax: ${failures.length} syntax failure(s) in .claude/hooks/*.sh\n`,
    );
    for (const { file, checker, stderr } of failures) {
      process.stderr.write(`  ${checker} -n ${file}:\n    ${stderr}\n`);
    }
    process.stderr.write(
      'A syntax-error in a registered Claude Code PreToolUse hook bricks tool surfaces.\n' +
        'Fix the hook script before committing (iter-305 NOVEL LESSON).\n',
    );
    process.exit(1);
  }
}

await main();
