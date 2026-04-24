#!/usr/bin/env python3
"""Generate block-secret-access.sh replay fixtures for Story 2.17 Task 15.1.

Each fixture sources _lib.sh and issues a single expect_block / expect_approve
assertion. Positive fixtures cover every rule-id / match-token pair visible in
.claude/hooks/block-secret-access.sh at iter-331 baseline. Negative fixtures
lock in D-35 word-boundary + D-17 example-exemption + normal-dev FP-avoidance.
"""
import os
import stat
from pathlib import Path

REPO = Path(__file__).resolve().parents[4]
BASE = REPO / "packages/keel-invariants/fixtures/hooks"
POS = BASE / "positive"
NEG = BASE / "negative"

HEADER = """#!/usr/bin/env bash
# Auto-generated for Story 2.17 Task 15.1 (bash-fixture persistence).
# Exercises block-secret-access.sh for a single (rule-id, match) or FP-avoidance case.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../_lib.sh
source "$HERE/../_lib.sh"
"""

def write_fixture(subdir: Path, name: str, body: str) -> Path:
    path = subdir / f"{name}.sh"
    path.write_text(HEADER + body + "\n")
    mode = path.stat().st_mode
    path.chmod(mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    return path

# -------------------------------------------------------------- positive fixtures

# Each entry: (name, label, payload_expr, rule_id, match_token)
POSITIVE = [
    # ---- secret-access-denylist: Bash readers against secret dirs ----
    (
        "secret-access-denylist-cat-oauth-token",
        "cat /home/dev/.claude/.credentials.json",
        'payload_bash "cat /home/dev/.claude/.credentials.json"',
        "secret-access-denylist",
        "cat-oauth-token",
    ),
    (
        "secret-access-denylist-cat-ssh-key",
        "cat /home/dev/.ssh/id_rsa",
        'payload_bash "cat /home/dev/.ssh/id_rsa"',
        "secret-access-denylist",
        "cat-ssh-key",
    ),
    (
        "secret-access-denylist-cat-envrc-file",
        "cat /tmp/.envrc",
        'payload_bash "cat /tmp/.envrc"',
        "secret-access-denylist",
        "cat-envrc-file",
    ),
    (
        "secret-access-denylist-cat-secrets-file",
        "cat /tmp/.secrets",
        'payload_bash "cat /tmp/.secrets"',
        "secret-access-denylist",
        "cat-secrets-file",
    ),
    (
        "secret-access-denylist-cat-env-file",
        "cat /tmp/.env",
        'payload_bash "cat /tmp/.env"',
        "secret-access-denylist",
        "cat-env-file",
    ),
    (
        "secret-access-denylist-cat-proc-environ",
        "cat /proc/self/environ",
        'payload_bash "cat /proc/self/environ"',
        "secret-access-denylist",
        "cat-proc-environ",
    ),
    # ---- secret-access-denylist: env dump + printenv ----
    (
        "secret-access-denylist-env-dump-bare",
        "env",
        'payload_bash "env"',
        "secret-access-denylist",
        "env-dump-bare",
    ),
    (
        "secret-access-denylist-printenv-idiom",
        "printenv PATH",
        'payload_bash "printenv PATH"',
        "secret-access-denylist",
        "printenv-idiom",
    ),
    (
        "secret-access-denylist-export-bare",
        "export -p (hits env-dump-bare via D-13)",
        'payload_bash "export -p"',
        "secret-access-denylist",
        "env-dump-bare",
    ),
    # ---- secret-access-denylist: Read-tool secret paths ----
    # Note: D-22 resolves file_path via readlink -f FIRST (hook lines 36-38), then checks
    # resolved_file_path against the secret-dir globs BEFORE the direct-path case. In the
    # devbox runtime where /home/dev/.claude/ physically exists, readlink canonicalises to
    # the same path — so the D-22 resolved-branch tokens (`read-resolved-to-*`) fire first,
    # and the direct-path tokens (`read-oauth-token`, `read-ssh-key`, `read-proc-environ`)
    # are unreachable. Fixtures align to the reachable reality. See README § Dominance notes.
    (
        "secret-access-denylist-read-resolved-to-oauth-token",
        "Read /home/dev/.claude/.credentials.json (D-22 resolved-path dominance)",
        'payload_read "/home/dev/.claude/.credentials.json"',
        "secret-access-denylist",
        "read-resolved-to-oauth-token",
    ),
    (
        "secret-access-denylist-read-oauth-token-tilde",
        "Read ~/.claude/.credentials.json (D-28 tilde-form)",
        'payload_read "~/.claude/.credentials.json"',
        "secret-access-denylist",
        "read-oauth-token-tilde",
    ),
    (
        "secret-access-denylist-read-resolved-to-ssh-key",
        "Read /home/dev/.ssh/id_ed25519 (D-22 resolved-path dominance)",
        'payload_read "/home/dev/.ssh/id_ed25519"',
        "secret-access-denylist",
        "read-resolved-to-ssh-key",
    ),
    (
        "secret-access-denylist-read-resolved-to-proc-environ",
        "Read /proc/self/environ (D-22 resolved + D-31 /proc surface)",
        'payload_read "/proc/self/environ"',
        "secret-access-denylist",
        "read-resolved-to-proc-environ",
    ),
    (
        "secret-access-denylist-read-envrc-file",
        "Read /home/dev/project/.envrc",
        'payload_read "/home/dev/project/.envrc"',
        "secret-access-denylist",
        "read-envrc-file",
    ),
    (
        "secret-access-denylist-read-env-file",
        "Read /home/dev/project/.env",
        'payload_read "/home/dev/project/.env"',
        "secret-access-denylist",
        "read-env-file",
    ),
    (
        "secret-access-denylist-read-secrets-file",
        "Read /home/dev/project/.secrets",
        'payload_read "/home/dev/project/.secrets"',
        "secret-access-denylist",
        "read-secrets-file",
    ),
    (
        "secret-access-denylist-read-secret-file-id-rsa",
        "Read id_rsa (D-30)",
        'payload_read "id_rsa"',
        "secret-access-denylist",
        "read-secret-file",
    ),
    (
        "secret-access-denylist-read-secret-file-credentials-json",
        "Read credentials.json (D-30)",
        'payload_read "credentials.json"',
        "secret-access-denylist",
        "read-secret-file",
    ),
    # ---- secret-access-denylist: Grep/Glob ----
    (
        "secret-access-denylist-grep-glob-secret-pattern",
        "Grep pattern=.env (D-18)",
        'payload_grep ".env"',
        "secret-access-denylist",
        "grep-glob-secret-pattern",
    ),
    (
        "secret-access-denylist-grep-glob-path-oauth",
        "Grep path=/home/dev/.claude/sub (D-20 Glob-parity; case-glob requires trailing content)",
        'payload_grep "TODO" "/home/dev/.claude/sub"',
        "secret-access-denylist",
        "grep-glob-path-oauth",
    ),
    (
        "secret-access-denylist-glob-secret-pattern",
        "Glob pattern=**/.envrc",
        'payload_glob "**/.envrc"',
        "secret-access-denylist",
        "grep-glob-secret-pattern",
    ),
    # ---- unknown-tool fallback (D-34) ----
    # The hook sets tool_name="__unknown__" when jq-parse fails OR tool_name field is
    # empty/missing (hook lines 12-16). A non-empty non-recognised tool_name (e.g. "Bogus")
    # falls through all case arms and reaches default approve — NOT the __unknown__ branch.
    # Fixtures use payload_notool to omit tool_name, triggering the fail-secure fallback.
    (
        "secret-access-denylist-unknown-tool-raw-secret-dir",
        "No-tool-name payload with /home/dev/.claude/ (D-34 fail-secure)",
        'payload_notool \'{"path":"/home/dev/.claude/x"}\'',
        "secret-access-denylist",
        "unknown-tool-raw-secret-dir",
    ),
    (
        "secret-access-denylist-unknown-tool-raw-proc-kernel",
        "No-tool-name payload with /proc/kcore (D-34 fail-secure)",
        'payload_notool \'{"p":"/proc/kcore"}\'',
        "secret-access-denylist",
        "unknown-tool-raw-proc-kernel",
    ),
    (
        "secret-access-denylist-unknown-tool-raw-proc-pid",
        "No-tool-name payload with /proc/1234/environ (D-34 fail-secure)",
        'payload_notool \'{"p":"/proc/1234/environ"}\'',
        "secret-access-denylist",
        "unknown-tool-raw-proc-pid",
    ),
    # ---- hook-self-protection: Edit/Write against settings / hooks / .git/hooks ----
    (
        "hook-self-protection-settings-file",
        "Edit .claude/settings.json",
        'payload_edit ".claude/settings.json"',
        "hook-self-protection",
        "settings-file",
    ),
    (
        "hook-self-protection-settings-local-file",
        "Edit .claude/settings.local.json (Task 8.4)",
        'payload_edit ".claude/settings.local.json"',
        "hook-self-protection",
        "settings-file",
    ),
    (
        "hook-self-protection-settings-forward-compat-file",
        "Edit .claude/settings.prod.json (Task 8.4 forward-compat)",
        'payload_edit ".claude/settings.prod.json"',
        "hook-self-protection",
        "settings-file",
    ),
    (
        "hook-self-protection-hook-script-file",
        "Edit .claude/hooks/block-secret-access.sh",
        'payload_edit ".claude/hooks/block-secret-access.sh"',
        "hook-self-protection",
        "hook-script-file",
    ),
    (
        "hook-self-protection-git-hook-file",
        "Edit .git/hooks/pre-commit",
        'payload_edit ".git/hooks/pre-commit"',
        "hook-self-protection",
        "git-hook-file",
    ),
    (
        "hook-self-protection-multiedit-settings",
        "MultiEdit .claude/settings.json (D-25)",
        'payload_multiedit ".claude/settings.json"',
        "hook-self-protection",
        "settings-file",
    ),
    (
        "hook-self-protection-notebookedit-settings",
        "NotebookEdit .claude/settings.json (D-25)",
        'payload_notebookedit ".claude/settings.json"',
        "hook-self-protection",
        "settings-file",
    ),
    (
        "hook-self-protection-write-hook-script",
        "Write .claude/hooks/fork.sh",
        'payload_write ".claude/hooks/fork.sh"',
        "hook-self-protection",
        "hook-script-file",
    ),
    # ---- hook-self-protection: Bash --no-verify ----
    (
        "hook-self-protection-git-no-verify-bypass",
        "git commit --no-verify",
        'payload_bash "git commit -m msg --no-verify"',
        "hook-self-protection",
        "git-no-verify-bypass",
    ),
    (
        "hook-self-protection-git-no-verify-bypass-env-prefix",
        "A=1 git commit --no-verify (D-16 env-prefix)",
        'payload_bash "A=1 B=2 git commit -m m --no-verify"',
        "hook-self-protection",
        "git-no-verify-bypass",
    ),
    (
        "hook-self-protection-git-no-verify-bypass-dash-c",
        "git -c x=y commit --no-verify (D-16 -c pre-arg)",
        'payload_bash "git -c core.hooksPath=/tmp commit -m m --no-verify"',
        "hook-self-protection",
        "git-no-verify-bypass",
    ),
    # ---- hook-self-protection: Bash mutation verbs against protected paths ----
    (
        "hook-self-protection-rm-against-protected",
        "rm .claude/settings.json (D-14 verb)",
        'payload_bash "rm .claude/settings.json"',
        "hook-self-protection",
        "rm-against-protected",
    ),
    (
        "hook-self-protection-mv-against-protected",
        "mv .claude/hooks/x /tmp/y",
        'payload_bash "mv .claude/hooks/block-secret-access.sh /tmp/y"',
        "hook-self-protection",
        "mv-against-protected",
    ),
    (
        "hook-self-protection-chmod-against-protected",
        "chmod 000 .git/hooks/pre-commit",
        'payload_bash "chmod 000 .git/hooks/pre-commit"',
        "hook-self-protection",
        "chmod-against-protected",
    ),
    (
        "hook-self-protection-tee-against-protected",
        "tee .claude/settings.json < /tmp/x",
        'payload_bash "tee .claude/settings.json"',
        "hook-self-protection",
        "tee-against-protected",
    ),
    (
        "hook-self-protection-sed-i-against-protected",
        "sed -i s/x/y/ .claude/settings.json",
        'payload_bash "sed -i s/x/y/ .claude/settings.json"',
        "hook-self-protection",
        "sed-i-against-protected",
    ),
    (
        "hook-self-protection-echo-redirect-against-protected",
        "echo foo > .claude/hooks/x (D-14)",
        'payload_bash "echo foo > .claude/hooks/x.sh"',
        "hook-self-protection",
        "echo-redirect-against-protected",
    ),
    (
        "hook-self-protection-cp-against-protected",
        "cp /tmp/x .claude/settings.json",
        'payload_bash "cp /tmp/x .claude/settings.json"',
        "hook-self-protection",
        "cp-against-protected",
    ),
    (
        "hook-self-protection-truncate-against-protected",
        "truncate -s 0 .claude/settings.json",
        'payload_bash "truncate -s 0 .claude/settings.json"',
        "hook-self-protection",
        "truncate-against-protected",
    ),
    (
        "hook-self-protection-dd-against-protected",
        "dd if=/dev/null of=.claude/settings.json",
        'payload_bash "dd if=/dev/null of=.claude/settings.json"',
        "hook-self-protection",
        "dd-against-protected",
    ),
    (
        "hook-self-protection-find-delete-against-protected",
        "find .claude/hooks -delete",
        'payload_bash "find .claude/hooks -delete"',
        "hook-self-protection",
        "find-delete-against-protected",
    ),
    # ---- hook-self-protection: wrapper-stripped (sudo + bash -c) ----
    (
        "hook-self-protection-sudo-rm-against-protected",
        "sudo rm .claude/settings.json (D-15 wrapper strip)",
        'payload_bash "sudo rm .claude/settings.json"',
        "hook-self-protection",
        "rm-against-protected",
    ),
    (
        "hook-self-protection-bash-c-rm-against-protected",
        "bash -c 'rm .claude/settings.json' (D-15 wrapper strip)",
        r'''payload_bash "bash -c 'rm .claude/settings.json'"''',
        "hook-self-protection",
        "rm-against-protected",
    ),
    # ---- install-boundary-protection (Task 7) ----
    (
        "install-boundary-protection-edit-manifest",
        "Edit packages/keel-invariants/src/invariants.manifest.ts",
        'payload_edit "packages/keel-invariants/src/invariants.manifest.ts"',
        "install-boundary-protection",
        "install-boundary-file",
    ),
    (
        "install-boundary-protection-edit-sync-gate",
        "Edit packages/keel-invariants/src/sync-gate.ts",
        'payload_edit "packages/keel-invariants/src/sync-gate.ts"',
        "install-boundary-protection",
        "install-boundary-file",
    ),
    (
        "install-boundary-protection-write-prompt-injection-rule",
        "Write packages/keel-invariants/src/prompt-injection-rules/x.ts",
        'payload_write "packages/keel-invariants/src/prompt-injection-rules/new-rule.ts"',
        "install-boundary-protection",
        "install-boundary-file",
    ),
    (
        "install-boundary-protection-mutation-verb-against-l1",
        "rm packages/keel-invariants/src/invariants.manifest.ts",
        'payload_bash "rm packages/keel-invariants/src/invariants.manifest.ts"',
        "install-boundary-protection",
        "mutation-verb-against-l1",
    ),
    (
        "install-boundary-protection-sed-i-against-l1",
        "sed -i s/x/y/ packages/keel-invariants/src/invariants.manifest.ts",
        'payload_bash "sed -i s/x/y/ packages/keel-invariants/src/invariants.manifest.ts"',
        "install-boundary-protection",
        "sed-i-against-l1",
    ),
    (
        "install-boundary-protection-echo-redirect-against-l1",
        "echo x > packages/keel-invariants/src/sync-gate.ts",
        'payload_bash "echo x > packages/keel-invariants/src/sync-gate.ts"',
        "install-boundary-protection",
        "echo-redirect-against-l1",
    ),
    (
        "install-boundary-protection-find-delete-against-l1",
        "find packages/keel-invariants/src/invariants.manifest.ts -delete (L1 regex requires specific filename)",
        'payload_bash "find packages/keel-invariants/src/invariants.manifest.ts -delete"',
        "install-boundary-protection",
        "find-delete-against-l1",
    ),
]

NEGATIVE = [
    # ---- D-35: word-boundary for mutation verbs ----
    (
        "rmdir-not-rm-against-protected",
        "rmdir .claude/settings (FP-avoid: rm* case-glob fix, D-35)",
        'payload_bash "rmdir .claude/settings"',
    ),
    (
        "cpio-not-cp-against-protected",
        "cpio -ov < .claude/settings.json (FP-avoid: cp* case-glob fix, D-35)",
        'payload_bash "cpio -ov"',
    ),
    (
        "ddrescue-not-dd-against-protected",
        "ddrescue /dev/sda /dev/sdb (FP-avoid: dd* case-glob fix, D-35)",
        'payload_bash "ddrescue /dev/sda /dev/sdb"',
    ),
    # ---- D-13: env|export|set word-boundary ----
    (
        "envsubst-not-env-dump-bare",
        "envsubst < template (FP-avoid: env* case, D-13)",
        'payload_bash "envsubst < template.yaml"',
    ),
    (
        "setup-sh-not-set-dump",
        "bash setup.sh (FP-avoid: set* case, D-13 + D-15 wrapper strip)",
        'payload_bash "bash setup.sh"',
    ),
    (
        "exportfs-not-export",
        "exportfs -ra (FP-avoid: export* case, D-13)",
        'payload_bash "exportfs -ra"',
    ),
    # ---- D-17: *.envrc.example exemption ----
    (
        "read-envrc-example-exempt",
        "Read /tmp/dev.envrc.example (D-17 exemption)",
        'payload_read "/tmp/dev.envrc.example"',
    ),
    (
        "cat-envrc-example-exempt",
        "cat /tmp/dev.envrc.example (D-17 Bash exemption)",
        'payload_bash "cat /tmp/dev.envrc.example"',
    ),
    (
        "read-env-example-exempt",
        "Read /tmp/sample.env.example (D-17 exemption)",
        'payload_read "/tmp/sample.env.example"',
    ),
    (
        "read-secrets-example-exempt",
        "Read /tmp/sample.secrets.example (D-17 exemption)",
        'payload_read "/tmp/sample.secrets.example"',
    ),
    # ---- Grep/Glob D-18 carve-out for .example ----
    (
        "grep-envrc-example-carveout",
        "Grep pattern=*.envrc.example (D-18 carve-out)",
        'payload_grep "*.envrc.example"',
    ),
    # ---- D-18 narrow patterns (broad TODO grep is approve) ----
    (
        "grep-vanilla-todo",
        "Grep pattern=TODO (not a secret-file pattern)",
        'payload_grep "TODO"',
    ),
    # ---- Normal dev: safe Bash / Edit / Read ----
    (
        "safe-bash-ls",
        "ls -la (safe)",
        'payload_bash "ls -la"',
    ),
    (
        "safe-edit-readme",
        "Edit README.md (safe)",
        'payload_edit "README.md"',
    ),
    (
        "safe-read-package-json",
        "Read package.json (safe)",
        'payload_read "package.json"',
    ),
    (
        "safe-write-tmp",
        "Write /tmp/scratch.txt (safe)",
        'payload_write "/tmp/scratch.txt"',
    ),
    # ---- Normal dev: edit non-L1 package file (FP-avoid install-boundary over-reach) ----
    (
        "safe-edit-non-l1-package",
        "Edit packages/keel-invariants/README.md (not under src/, outside L1)",
        'payload_edit "packages/keel-invariants/README.md"',
    ),
    (
        "safe-edit-fixture",
        "Edit packages/keel-invariants/fixtures/hooks/run-all.sh (fixtures outside L1)",
        'payload_edit "packages/keel-invariants/fixtures/hooks/run-all.sh"',
    ),
    # ---- Normal dev: benign git commit (no --no-verify) ----
    (
        "safe-git-commit-no-bypass",
        "git commit -m msg (no --no-verify)",
        'payload_bash "git commit -m refactor"',
    ),
]


# Standalone fixture bodies (multi-statement setups that don't fit the one-liner pattern).
STANDALONE_POSITIVE = [
    (
        "secret-access-denylist-symlink-example-to-secret-dir",
        """# D-22 guard: Read-arm *.envrc.example exemption must deny when the resolved symlink
# target lands inside a secret directory. Build a throwaway symlink in /tmp, exercise
# the hook, clean up. Expected: block with match=symlink-example-to-secret-dir.
decoy="/tmp/fixture-decoy.envrc.example"
rm -f "$decoy"
ln -s /home/dev/.claude/x "$decoy"
# Keep the symlink live across the hook invocation so readlink -f resolves it.
payload="$(payload_read "$decoy")"
status=0
expect_block "Read decoy.envrc.example -> /home/dev/.claude/" "$payload" \\
  "secret-access-denylist" "symlink-example-to-secret-dir" || status=$?
rm -f "$decoy"
exit "$status"
""",
    ),
]


def main() -> None:
    # Wipe any prior fixtures from this directory to ensure deterministic output.
    for d in (POS, NEG):
        d.mkdir(parents=True, exist_ok=True)
        for p in d.glob("*.sh"):
            p.unlink()

    for name, label, payload, rule, match in POSITIVE:
        body = f'expect_block "{label}" "$({payload})" "{rule}" "{match}"'
        write_fixture(POS, name, body)

    for name, body in STANDALONE_POSITIVE:
        write_fixture(POS, name, body)

    for name, label, payload in NEGATIVE:
        body = f'expect_approve "{label}" "$({payload})"'
        write_fixture(NEG, name, body)

    pos_n = len(list(POS.glob("*.sh")))
    neg_n = len(list(NEG.glob("*.sh")))
    print(f"wrote {pos_n} positive + {neg_n} negative = {pos_n + neg_n} fixtures")


if __name__ == "__main__":
    main()
