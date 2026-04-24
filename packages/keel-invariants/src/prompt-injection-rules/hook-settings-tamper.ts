/**
 * Story 2.17 Task 5 — S4 prompt-injection scan rules for hook/settings tampering.
 *
 * Three high-severity rules per AC 3:
 *   - s4-claude-hooks-tamper: additions/modifications under `.claude/hooks/**`
 *     or `.claude/settings[.*.local].json`, EXCEPT fork-extension slot edits
 *     when the scanner provides structural-diff augmentation.
 *   - s4-git-hooks-tamper: additions/modifications under `.git/hooks/**`. Note:
 *     `.git/` is typically not in the diff — Epic 4 consumes this rule via a
 *     pre-commit-time git-hook walk, not diff-based scanning.
 *   - s4-skip-permissions-injection: `--dangerously-skip-permissions` substring
 *     in added lines, outside the known-safe paths enumerated at 1.0.
 *
 * Findings conform to `scans.prompt_injection.findings[]` per architecture.md
 * § S3 Per-iteration security-evidence schema. Severity `high` contributes to
 * `scans.prompt_injection.severity_max` and (via Epic 4 FR36 threshold) to
 * `halt_required = true` — Story 2.17 EMITS findings; Epic 4 CONSUMES + decides.
 *
 * The pre-commit scanner BINARY that invokes these rules is Epic 4 Story 4.x
 * scope (not Story 2.17). Task 5 authors the rule modules; Epic 4 wires them.
 */

export type Severity = 'none' | 'low' | 'medium' | 'high' | 'critical';

export interface Finding {
  rule_id: string;
  severity: Severity;
  path: string;
  line_range: [number, number];
  diff_preview: string;
}

/**
 * One side of a per-file diff, consumed by rules.
 *
 * `jsonPathsChanged`: OPTIONAL structural-diff augmentation the scanner MAY
 * provide for JSON files. When present, `s4-claude-hooks-tamper` uses it to
 * distinguish substrate-authoritative edits from fork-extension slot edits
 * (forks MAY extend `.hooks.PostToolUse` / `.hooks.UserPromptSubmit` /
 * `.permissions.allow`; Story 2.15 honour-system). When absent, the rule
 * fires on any addition under the guarded path (fail-closed default).
 */
export interface DiffHunk {
  path: string;
  addedLines: ReadonlyArray<{ lineNumber: number; content: string }>;
  jsonPathsChanged?: ReadonlyArray<string>;
}

export interface Rule {
  id: string;
  severity: Severity;
  test(hunk: DiffHunk): Finding | null;
}

const CLAUDE_HOOK_OR_SETTINGS_RE =
  /^\.claude\/(hooks\/.+|settings\.json|settings\.local\.json|settings\.[^/]+\.json)$/;

const GIT_HOOKS_RE = /^\.git\/hooks\/.+$/;

/**
 * JSON path prefixes that correspond to fork-extension slots (forks MAY add
 * entries here). Substrate-authoritative sub-trees (`.hooks.PreToolUse`,
 * `.permissions.deny`) are deliberately absent — edits to those fire the rule.
 */
const FORK_EXTENSION_PATH_PREFIXES: readonly string[] = [
  'permissions.allow',
  'hooks.PostToolUse',
  'hooks.UserPromptSubmit',
  'hooks.Notification',
  'hooks.SessionStart',
  'hooks.Stop',
  'hooks.SubagentStop',
];

/**
 * Files where `--dangerously-skip-permissions` legitimately appears in 1.0.
 * Story spec (Task 5.3) names the first five; the remainder are repo-surface
 * where the string quotes documentation/rule-source-code — flagging them would
 * be false-positive. Epic 4 scanner MAY tighten if new exemptions arise.
 */
const SKIP_PERMS_SAFE_FILE_REGEXES: readonly RegExp[] = [
  /^packages\/devbox\/scripts\//,
  /^packages\/keel-invariants\/src\/prompt-injection-rules\//,
  /^\.ralph\/PROMPT_.+\.md$/,
  /^AGENTS\.md$/,
  /^CLAUDE\.md$/,
  /^RALPH\.md$/,
  /^INVARIANTS\.md$/,
  /^docs\/ralph\.md$/,
  /^docs\/invariants\//,
  /^_bmad-output\//,
  /^README\.md$/,
  /^\.ralph-tools\.example\.json$/,
  /^ralph\.py$/,
];

const SKIP_PERMS_NEEDLE = '--dangerously-skip-permissions';

function lineRange(
  lines: ReadonlyArray<{ lineNumber: number; content: string }>,
): [number, number] {
  const first = lines[0];
  const last = lines[lines.length - 1];
  if (!first || !last) return [0, 0];
  return [first.lineNumber, last.lineNumber];
}

function preview(lines: ReadonlyArray<{ lineNumber: number; content: string }>, limit = 5): string {
  return lines
    .slice(0, limit)
    .map((l) => `+${l.content}`)
    .join('\n');
}

function isForkExtensionPath(jsonPath: string): boolean {
  for (const prefix of FORK_EXTENSION_PATH_PREFIXES) {
    if (jsonPath === prefix) return true;
    if (jsonPath.startsWith(`${prefix}.`)) return true;
    if (jsonPath.startsWith(`${prefix}[`)) return true;
  }
  return false;
}

export const s4ClaudeHooksTamper: Rule = {
  id: 's4-claude-hooks-tamper',
  severity: 'high',
  test(hunk) {
    if (!CLAUDE_HOOK_OR_SETTINGS_RE.test(hunk.path)) return null;
    if (hunk.addedLines.length === 0) return null;
    if (hunk.jsonPathsChanged && hunk.jsonPathsChanged.length > 0) {
      if (hunk.jsonPathsChanged.every(isForkExtensionPath)) return null;
    }
    return {
      rule_id: 's4-claude-hooks-tamper',
      severity: 'high',
      path: hunk.path,
      line_range: lineRange(hunk.addedLines),
      diff_preview: preview(hunk.addedLines),
    };
  },
};

export const s4GitHooksTamper: Rule = {
  id: 's4-git-hooks-tamper',
  severity: 'high',
  test(hunk) {
    if (!GIT_HOOKS_RE.test(hunk.path)) return null;
    if (hunk.addedLines.length === 0) return null;
    return {
      rule_id: 's4-git-hooks-tamper',
      severity: 'high',
      path: hunk.path,
      line_range: lineRange(hunk.addedLines),
      diff_preview: preview(hunk.addedLines),
    };
  },
};

export const s4SkipPermissionsInjection: Rule = {
  id: 's4-skip-permissions-injection',
  severity: 'high',
  test(hunk) {
    if (SKIP_PERMS_SAFE_FILE_REGEXES.some((re) => re.test(hunk.path))) return null;
    const hits = hunk.addedLines.filter((l) => l.content.includes(SKIP_PERMS_NEEDLE));
    if (hits.length === 0) return null;
    return {
      rule_id: 's4-skip-permissions-injection',
      severity: 'high',
      path: hunk.path,
      line_range: lineRange(hits),
      diff_preview: preview(hits),
    };
  },
};

export const s4HookSettingsTamperRules: readonly Rule[] = [
  s4ClaudeHooksTamper,
  s4GitHooksTamper,
  s4SkipPermissionsInjection,
];
