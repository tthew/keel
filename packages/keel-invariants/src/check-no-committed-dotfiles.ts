#!/usr/bin/env node
/**
 * Story 2.2 — Gitignored-secret commit-deny gate (INV-gitignored-secret-commit-deny).
 * Story 2.17 Task 8.2 — extended with .claude/settings.local.json operator-override
 * refusal (AC 7; NFR5a operator-honour baseline).
 *
 * Refuses additions of .envrc, .envrc.local, .secrets, and .claude/settings.local.json
 * at any path. Committed schema companions (.envrc.example, .secrets.example) are
 * exempt via anchored regex end-match. Invoked via prek with pass_filenames: true,
 * so `process.argv.slice(2)` carries the staged filenames.
 */

interface DenylistEntry {
  pattern: RegExp;
  name: string;
}

const denylist: DenylistEntry[] = [
  { pattern: /^(.+\/)?\.envrc$/, name: '.envrc' },
  { pattern: /^(.+\/)?\.envrc\.local$/, name: '.envrc.local' },
  { pattern: /^(.+\/)?\.secrets$/, name: '.secrets' },
  { pattern: /^(.+\/)?\.claude\/settings\.local\.json$/, name: '.claude/settings.local.json' },
];

const stagedFiles = process.argv.slice(2);
const violations = stagedFiles.flatMap((file) => {
  for (const { pattern, name } of denylist) {
    if (pattern.test(file)) return [{ file, matched: name }];
  }
  return [];
});

if (violations.length > 0) {
  for (const { file, matched } of violations) {
    process.stderr.write(
      `Refusing to commit gitignored secret file: ${file} (matches ${matched}).\n` +
        `  See Story 2.2 AC 5 + packages/devbox/.envrc.example / packages/devbox/.secrets.example for the committed schema.\n`,
    );
  }
  process.exit(1);
}
process.exit(0);
