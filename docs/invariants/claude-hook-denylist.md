# Claude PreToolUse hooks for secret-file denylist (Story 2.16)

## INV-claude-hook-secret-denylist

Machine-enforced contract for the in-session Claude Code PreToolUse hook that denies secret-file access and hook/settings-self-mutation regardless of permission mode. Closes NFR5a (in-session secret-access barrier) + NFR5b (bypass-resistance — permission-layer + hook-layer composition) for the Ralph runtime path (`claude -p --dangerously-skip-permissions`), which bypasses the permission layer shipped by Story 2.15.

### Substrate contract

**Hook script** at `.claude/hooks/block-secret-access.sh` (POSIX-sh + jq; `chmod 0755`; no setuid; runs as the Claude Code session's UID — UID 1000 `dev` inside the devbox per Story 2.5 hardening):

- Reads a JSON tool-call object from stdin with at minimum `tool_name` + `tool_input` fields per upstream Claude Code hook schema (`@anthropic-ai/claude-code@2.1.116` baked at `packages/devbox/Dockerfile:121`).
- Parses with `jq` (baked at devbox image per `packages/devbox/Dockerfile:48`).
- Emits `{"decision":"block","reason":"<rule-id>","match":"<matched-pattern>"}` on stdout for deny-matches, `{"decision":"approve"}` for approvals, and exits 0 always (non-zero = hook error per Claude Code contract; fails open — blocking via stdout-JSON is mandatory).

**Registration** in `.claude/settings.json` `hooks.PreToolUse[]` array — six matchers (`Bash`, `Read`, `Edit`, `Write`, `Grep`, `Glob`), each invoking the single hook script. Additive to Story 2.15's `permissions` block — `permissions` content stays byte-identical (no reorder, no add, no remove at Story 2.16 scope).

**Two denylists** pinned:

1. **`secret-access-denylist`** (rule-id):
   - **Bash commands:** `env`/`export`/`set` (bare argv; env-dump idioms); `printenv*`; `cat *.envrc*` / `cat */.envrc*` (absorbs prefix variants `cat .envrc`, `cat ./.envrc`, `cat /workspace/.envrc`, `cat /home/dev/.envrc.local` — D-3 prefix-anchor gap mitigated at hook layer); `cat *.secrets*` / `cat */.secrets*`; `cat *.env` / `cat *.env.*` / `cat */.env` / `cat */.env.*`; `cat */home/dev/.claude/*` / `cat */home/dev/.config/gh/*` (absorbs D-6 Bash-cat parity gap); `cat */proc/*/environ*`.
   - **Read paths:** `/home/dev/.claude/**`, `/home/dev/.config/gh/**`, `**/.envrc*`, `**/.env*` (recursive — absorbs D-1 root-anchor asymmetry), `**/.secrets*`, `/proc/*/environ`. EXEMPT: `*.envrc.example`, `*.secrets.example`, `*.env.example` (schema companions; substrate convention per `INV-gitignored-secret-commit-deny`).
   - **Grep / Glob patterns:** `*.env*`, `*.envrc*`, `*.secrets*` (matches literal-asterisk-containing pattern strings + substring-bearing variants). Grep `path` argument also checked against OAuth-token paths (`/home/dev/.claude/**`, `/home/dev/.config/gh/**`).

2. **`hook-self-protection`** (rule-id):
   - **Edit / Write paths:** `.claude/settings.json`, `.claude/settings.local.json`, `.claude/hooks/**`, `.git/hooks/**` (absolute or repo-relative).
   - **Bash commands mutating those paths:** `rm`, `mv`, `chmod`, `tee`, `sed -i`, `echo >` redirect, `cp` — all variants against `.claude/settings*`, `.claude/hooks/*`, `.git/hooks/*`.
   - **Bash git-gate bypass commands:** any command containing `--no-verify` substring (`git commit --no-verify`, `git push --no-verify`) — composes with `INV-no-verify-bypass` ESLint rule (source-checked-in patterns) at the in-session runtime layer.

### Decision-shape contract

Every block writes stdout JSON `{"decision":"block","reason":"<rule-id>","match":"<matched-pattern>"}` where:

- `<rule-id>` ∈ {`secret-access-denylist`, `hook-self-protection`, `install-boundary-protection`} — the closed rule-id enum (three members post-Story-2.17 Task 7; `install-boundary-protection` denies Ralph-authored edits against `packages/keel-invariants/src/{invariants.manifest.ts,sync-gate.ts,manifest-reader.ts,prek-hook-manifest.ts,prompt-injection-rules/**}`).
- `<matched-pattern>` is a short human-readable identifier (e.g. `cat-envrc-file`, `hook-script-file`, `git-no-verify-bypass`) — NEVER the full tool-call argv (args may contain secrets that would be exfiltrated via the hook's own log channel).

Every approval writes stdout JSON `{"decision":"approve"}` (or empty stdout — both honoured by upstream).

The script exits 0 always. Claude Code's PreToolUse contract treats non-zero exit as "hook error" which fails OPEN — blocking via stdout-JSON is mandatory; exit-code-as-block does NOT work.

### JSONL query log schema

Every `block` decision appends one JSONL line to `${RALPH_BASE_DIR}/logs/<iter-id>/blocked-tool-calls.jsonl` when invoked inside a Ralph iteration (env vars `RALPH_BASE_DIR` + `RALPH_ITER_ID` both set). Outside a Ralph iteration (either env var unset), the JSONL append is skipped — the hook still blocks, logging is Ralph-scoped.

Schema (stable; Epic 4 FR37 consumer contract):

```json
{
  "timestamp": "<ISO8601 UTC; e.g. 2026-04-24T13:37:15Z>",
  "iteration_id": "<RALPH_ITER_ID value or 'unknown'>",
  "tool": "<tool_name from stdin: Bash|Read|Edit|Write|Grep|Glob>",
  "args_redacted": "<redacted argv summary — '<redacted>' literal at 1.0; stable across versions>",
  "rule_id": "<secret-access-denylist|hook-self-protection|install-boundary-protection>",
  "match": "<short identifier of the specific rule that fired>"
}
```

The log directory is created with `mkdir -p` if absent. Append is atomic for line lengths < `PIPE_BUF` (4096 bytes on Linux per `man 7 pipe`); JSONL lines stay well under the limit (~200 bytes typical). No flock needed; concurrent hook invocations append safely.

**Epic 4 consumer (FR37; Story 4.13):** each line propagates into `security-evidence.json` under `scans.hook_denials[]`; `severity_max` escalates to `high` if N ≥ 3 blocks occurred per iteration.

### Halt-threshold pin

`.ralph/config.toml [hooks].self_protection_halt_threshold = 3` — number of `hook-self-protection` rule-id blocks per Ralph iteration that triggers a `SECURITY_CRITICAL` halt.

**Consumer:** Epic 3 Story 3.7 (in-loop pre-push gate) reads the threshold, counts `hook-self-protection` entries in `${RALPH_BASE_DIR}/logs/<iter-id>/blocked-tool-calls.jsonl`, and writes `${RALPH_BASE_DIR}/halt` with:

```json
{"reason":"SECURITY_CRITICAL","iteration_id":"<id>","rule_id":"hook-self-protection","block_count":<N>}
```

per the closed halt-reason enum (`INV-ralph-halt-reason-enum`; PRD FR14k + NFR33a). Story 2.16 ships the threshold value + config-file location only; Story 3.7 wires the halt-write logic.

**Key-name contract (Story 2.17 D-32 cross-check).** The config-file key name `[hooks].self_protection_halt_threshold` is substrate-pinned — renaming requires an AMEND-path PR touching (1) `.ralph/config.toml` header comment + pinned key, (2) this doc § Halt-threshold pin, (3) Epic 3 Story 3.7 consumer code once landed. A fork MAY NOT redefine the key name (substrate-wins per `docs/invariants/fork.md § Precedence`); fork-specific halt thresholds on sibling rules MUST use a distinct key (e.g. `fork_rule_halt_threshold`) in the `[hooks]` table. Spelling at 1.0: `self_protection_halt_threshold` (underscore-separated; Story 2.17 iter-325 re-verified against `.ralph/config.toml` substrate file).

**Range contract (Story 2.17 D-23 absorption).** Valid integer range `1..=100`; out-of-range, non-integer, or missing values MUST be treated by the consumer (Epic 3 Story 3.7) as the default `3` plus a stderr warning (`[ralph] self_protection_halt_threshold out of range or invalid; falling back to 3`). Consumer-side validation lives in Story 3.7; Story 2.17 pins the contract at the doc + `.ralph/config.toml` header-comment layer.

### Source files

Substrate:

- `.claude/hooks/block-secret-access.sh` — the hook script.
- `.claude/settings.json` — `hooks.PreToolUse` block registration (alongside Story 2.15's `permissions`).
- `.ralph/config.toml` — `[hooks].self_protection_halt_threshold` pin.

Seeds (Epic 15a Story 15a.4 consumer):

- `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh` — byte-identical copy of substrate hook.
- `packages/keel-templates/src/seeds/.claude/settings.json` — byte-identical copy of substrate settings.

Doc + anchor:

- `docs/invariants/claude-hook-denylist.md` (this file) — `contentHash`-bound source (Story 1.9 sync-gate).
- `INVARIANTS.md § Claude PreToolUse hooks (Story 2.16)` H3 — human-readable anchor + bullet pointing at this doc.
- `packages/keel-invariants/src/invariants.manifest.ts` — five manifest entries binding the hook script + this doc + `.claude/settings.json` sub-tree + `.git/hooks/` enumeration + `.git/hooks/` names+shebangs hash (Story 2.17 split + additions; 39 entries total).

### Fork extension

Forks MAY add fork-specific deny patterns by authoring `.claude/hooks/block-secret-access.fork.sh` at the fork root (substrate at Story 2.16 landing does NOT ship this file — operator opts in; executable `chmod 0755`; reads stdin payload from the substrate hook).

- **Invocation.** The substrate hook invokes the fork hook AS A LAST STEP after the substrate denylist clears: `if [ -x .claude/hooks/block-secret-access.fork.sh ]; then printf '%s' "$payload" | .claude/hooks/block-secret-access.fork.sh; exit $?; fi`. The fork hook receives the same stdin payload as the substrate hook.
- **Precedence.** Forks MAY BLOCK additional patterns the substrate allows. Forks CANNOT UNBLOCK substrate-denied patterns — the fork hook is only reached when the substrate said `approve`. Substrate-wins per `docs/invariants/fork.md § Precedence`.

**AMEND path (substrate edits).** If a fork needs a substrate-wide change (e.g. "all forks should remove a substrate-deny rule that causes false positives"), open a PR with **7-site AMEND coordination**:

1. Substrate `.claude/hooks/block-secret-access.sh`
2. Substrate `.claude/settings.json` `hooks.PreToolUse` block (if matcher set changes)
3. `docs/invariants/claude-hook-denylist.md` (this file)
4. `packages/keel-invariants/src/invariants.manifest.ts` `contentHash`
5. `INVARIANTS.md` H3 anchor + bullet
6. `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh` seed
7. `packages/keel-templates/src/seeds/.claude/settings.json` seed

Sites (1) + (2) + (3) + (6) + (7) form the 5-site byte-identity lockstep (substrate ↔ seed coherence); sites (4) + (5) are the coordinated metadata sites (manifest `contentHash` moves when (3) changes; INVARIANTS.md anchor bullet reflects (3) narrative). Substrate-internal cross-refs at `AGENTS.md § Claude PreToolUse hooks (Story 2.16)` H3 + `CLAUDE.md` bullet + `packages/devbox/README.md § Claude PreToolUse hooks (Story 2.16)` H2 may also need updates if the change is operator-visible.

### Dependencies

- **bash** — script shebang `#!/usr/bin/env bash`. Baked at `packages/devbox/Dockerfile:36-37`.
- **jq** — JSON parsing of the stdin tool-call payload. Baked at `packages/devbox/Dockerfile:48`.

POSIX-sh-only (no `jq`) fallback is OUT OF SCOPE for Story 2.16 at 1.0. Forks that remove `jq` (against substrate convention) self-amend via the AMEND path.

### Pre-install discipline (iter-305 NOVEL LESSON; Story 2.17 Task 12)

Claude Code 2.1.116 empirically treats `hooks.PreToolUse` block-parse-failure as **block-with-stdout-suppression** (contrary to upstream docs suggesting "fail-open"). A syntax error in the registered hook bricks the `Bash`/`Read`/`Edit`/`Write`/`Grep`/`Glob` tool surfaces. Recovery requires a Monitor-based Python escape-hatch (observed at Story 2.16 iter-305 incident — hook self-immolation rendered a running agent unable to invoke Bash-backed tools until the hook was re-parsed cleanly).

**Pre-install `bash -n` dispatch is MANDATORY** before committing any `.claude/hooks/*.sh` change. Machine-enforcement: `packages/keel-invariants/src/check-claude-hook-syntax.ts` (wired via `pnpm keel-invariants:claude-hook-syntax` in `.pre-commit-config.yaml`) shells out to `bash -n` (and conditionally `dash -n`) against every file under `.claude/hooks/`.

**Shebang-aware dispatch (Story 2.17 Task 12.1 NOVEL FINDING).** The substrate hook at `.claude/hooks/block-secret-access.sh` uses `#!/usr/bin/env bash` with bash-specific constructs (`[[ ... ]]`, `=~` regex-match) that `dash -n` intentionally rejects. A blanket `bash -n && dash -n` on the bash hook would force a POSIX-sh rewrite — out-of-scope for the hook's bypass-resistance ACs. The gate therefore **dispatches on shebang**:

| First line of `.claude/hooks/<name>.sh`         | Syntax checks run                                     |
| ----------------------------------------------- | ----------------------------------------------------- |
| `#!/usr/bin/env bash` / `#!/bin/bash`           | `bash -n` only                                        |
| `#!/usr/bin/env sh` / `#!/bin/sh`               | `bash -n` + `dash -n` (strict POSIX compliance check) |
| Missing / other (e.g. `#!/usr/bin/env python`)  | `bash -n` only (conservative default)                 |

Extension rule: a fork-authored `.claude/hooks/block-secret-access.fork.sh` with `#!/bin/sh` shebang IS held to the strict `dash -n` bar — forks that want dash-rejected constructs author with `#!/usr/bin/env bash` shebang instead. The dispatch preserves the spirit of iter-305's "catch syntax errors before registration" lesson without requiring substrate-hook POSIX-rewrite.

### Story 2.17 git-layer backstop (landed incrementally)

Story 2.17 expands the content-hash surface from "this invariant doc only" (the Story 2.16 baseline) to **three substrate artefacts + one invariant-doc sibling**. The Story 1.9 pre-merge sync-gate walks every entry; out-of-band tampering (edits that evade the in-session hook via a non-Claude editor, a race, or a novel bypass) fails the gate.

| Manifest entry                             | `sourcePath`                                                 | `hashScope`                                                                                      |
| ------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| `INV-claude-hook-secret-denylist`          | `.claude/hooks/block-secret-access.sh`                       | absent (whole-file sha256)                                                                       |
| `INV-claude-hook-secret-denylist-doc`      | `docs/invariants/claude-hook-denylist.md` (this file)        | absent (whole-file sha256)                                                                       |
| `INV-claude-settings-deny-rules`           | `.claude/settings.json`                                      | `jq-subtree` over `{deny: .permissions.deny \| sort, hooks: .hooks.PreToolUse \| sort_by(.matcher)}` |
| `INV-git-hooks-preservation-enumeration`   | `packages/keel-invariants/src/prek-hook-manifest.ts`         | absent (whole-file sha256 of the `EXPECTED_HOOKS` enumerator)                                    |
| `INV-git-hooks-preservation`               | `packages/keel-invariants/src/prek-hook-manifest.ts`         | `names-and-shebangs` (walks `.git/hooks/` for each enumerated name, hashes `sort(name\tshebang)`)|

The former-Story-2.16 entry `INV-claude-hook-secret-denylist` previously pointed at this invariant doc; Story 2.17 **repoints** it to the hook script itself (the substrate enforcement layer — the thing a bypass attempt would actually mutate) and adds `INV-claude-hook-secret-denylist-doc` to preserve the invariant-doc drift protection. Option B (repoint + split) per Story 2.17 Task 4.1 rationale; the ID-continuity + git-blame lineage of the existing entry is preserved.

The `jq-subtree` filter covers BOTH substrate-authoritative sub-trees of `.claude/settings.json`: `.permissions.deny[]` (Story 2.15 NFR5a baseline — forks MAY NOT weaken) AND `.hooks.PreToolUse[]` (hook registration — nulling disables Story 2.16's hook firing entirely). Canonicalisation via `sort` + `sort_by(.matcher)` normalises authoring-order drift; `// []` defaults preserve the hash contract if a fork accidentally removes either key. Fork-additive edits to `.permissions.allow`, `.hooks.PostToolUse`, `.hooks.UserPromptSubmit` do NOT change the hash.

The `names-and-shebangs` variant exists because `.git/hooks/` is regenerated by `prek install` on fresh clone and the byte-bodies drift across prek upgrades + `.pre-commit-config.yaml` changes. Hashing `sort(name\tshebang-line)` over the enumerated hook set (`commit-msg` + `pre-commit` at Story 2.17 landing) pins the contract "these hooks exist AND their shebangs conform to pattern" without binding to byte-level drift. Missing hooks emit `git-hook-missing` drift; shebang-pattern mismatches emit `git-hook-shebang-mismatch`.

### L1 install-boundary rule (Story 2.17 Task 7)

Story 2.17 Task 7 adds a third closed-enum rule-id `install-boundary-protection` that denies Ralph-authored edits against `packages/keel-invariants/src/**` — the L1 substrate that houses the manifest + sync-gate + hash helpers + prek-hook-manifest + S4 prompt-injection rules. The rule protects the enforcement-layer code itself so an in-session Ralph cannot weaken the bypass-resistance machinery that Story 1.9 rides on.

**Protected subset at 1.0** (repo-relative paths):

- `packages/keel-invariants/src/invariants.manifest.ts` — the manifest itself.
- `packages/keel-invariants/src/sync-gate.ts` — the pre-merge walker.
- `packages/keel-invariants/src/manifest-reader.ts` — hash helpers consumed by the walker.
- `packages/keel-invariants/src/prek-hook-manifest.ts` — the `EXPECTED_HOOKS` enumerator backing `INV-git-hooks-preservation` + `INV-git-hooks-preservation-enumeration`.
- `packages/keel-invariants/src/prompt-injection-rules/**` — the S4 rules folder (Epic 4 consumer; see § S4 prompt-injection scan rules below).

**Hook implementation.** Shared regex hoisted above the Edit|Write / Bash case dispatch:

```bash
l1_path_re='packages/keel-invariants/src/(invariants\.manifest\.ts|sync-gate\.ts|manifest-reader\.ts|prek-hook-manifest\.ts|prompt-injection-rules/)'
```

- **Edit|Write|MultiEdit|NotebookEdit arm** — if `$file_path` matches `$l1_path_re`, fires `{"decision":"block","reason":"install-boundary-protection","match":"install-boundary-file"}`.
- **Bash arm** — path-presence gate short-circuits non-L1 invocations; when an L1 path appears in `$bash_command` or the wrapper-stripped `$normalized` form:
  - word-boundary-anchored mutation verbs (`rm`, `mv`, `chmod`, `tee`, `cp`, `truncate`, `dd`) → match `mutation-verb-against-l1`.
  - `sed -i` / `sed --in-place` → match `sed-i-against-l1`.
  - `echo ... >` redirect → match `echo-redirect-against-l1`.
  - `find ... -delete` → match `find-delete-against-l1`.

**Three-layer install-boundary contract.** The L1 rule is the in-session leg of a three-layer defense:

1. **In-session hook (this rule).** Denies Edit|Write|MultiEdit|NotebookEdit + select Bash mutations against L1 paths regardless of permission mode. Runs on every Ralph iteration.
2. **Git-layer manifest contentHash drift detection (Story 1.9 sync-gate).** Every L1 source file participates in a manifest entry (`INV-tokens-schema-validate`, `INV-tokens-contrast-check`, `INV-no-verify-bypass`, etc. anchor entries ride the same `packages/keel-invariants/src/**` surface). Out-of-band edits that evade the hook via a non-Claude editor, a race, or a novel bypass fail the pre-merge gate. See § Story 2.17 git-layer backstop.
3. **S4 prompt-injection scan (Epic 4 Story 4.x consumer).** The pre-commit scanner tier detects additions/modifications to `.claude/hooks/**` + `.claude/settings*.json` + `.git/hooks/**` + `--dangerously-skip-permissions` injection patterns. See § S4 prompt-injection scan rules.

**Self-recursion orthogonality.** The L1 rule is orthogonal to `hook-self-protection`: the hook script itself at `.claude/hooks/block-secret-access.sh` is still protected by `hook-self-protection`/`hook-script-file` (Story 2.16 rule preserved unchanged). L1 adds protection for the `packages/keel-invariants/src/**` enforcement substrate that the manifest + sync-gate ride on. An attempt to edit the hook itself hits `hook-self-protection`; an attempt to edit the manifest hits `install-boundary-protection`. Empirically verified at iter-315 smoke 12 (`Write` with `file_path=.claude/hooks/block-secret-access.sh` still blocks with `hook-self-protection`/`hook-script-file`).

**Substrate-maintenance loophole.** A `python3 -c 'open(path,"w").write(...)'` invocation from Bash is NOT matched by the L1 mutation-verb list (the regex enumerates `rm|mv|chmod|tee|cp|truncate|dd` + `sed -i` + `echo >` + `find -delete`; it does NOT list `python3` or other interpreter-stdin writers). This is a deliberate scope-carve-out for substrate-maintenance paths — e.g. atomic-replace-then-chmod of a manifest `contentHash` refresh during story work; see § Fresh-fork seed contract below for the exec-bit preservation rationale. The manifest content-hash backstop (layer 2) + S4 scan (layer 3) cover the loophole; a Ralph that mutates L1 files via `python3` still trips drift at sync-gate time and tamper-findings at pre-commit scan time. Documented in § Limitations below.

### S4 prompt-injection scan rules (Story 2.17 Task 5)

Story 2.17 Task 5 authors three prompt-injection scan rules at `packages/keel-invariants/src/prompt-injection-rules/` that surface tamper attempts against the Story 2.15 + 2.16 + 2.17 substrate at pre-commit scan time. Epic 4's FR40 scanner binary consumes the rules; pre-commit wiring is **NOT** Story 2.17 scope (Epic 4 Story 4.x owns the scanner binary).

**Three rules (all severity `high`):**

1. **`s4-claude-hooks-tamper`** — diff regex matching additions/modifications to paths `^\.claude/hooks/.*` OR `^\.claude/settings\.json$` OR `^\.claude/settings\.local\.json$`. Catches any commit that mutates the substrate hook surface or the substrate-authoritative settings file.
2. **`s4-git-hooks-tamper`** — diff regex matching `^\.git/hooks/.*`. Catches any commit that attempts to land content under `.git/hooks/` (typically NOT in the diff under normal operation — prek regenerates on install — so any diff-layer match is suspicious). Scan-tier complement to `INV-git-hooks-preservation` which uses a post-install `names-and-shebangs` walker.
3. **`s4-skip-permissions-injection`** — string match for `--dangerously-skip-permissions` in any newly-added or modified file OUTSIDE the known-safe paths (`packages/devbox/scripts/`, `.ralph/PROMPT_*.md`, `AGENTS.md` + `CLAUDE.md` quoted regions, `docs/ralph.md`). Catches prompt-injection attempts that plant the bypass token in source code where it can be eval'd at runtime.

**Finding shape** (conforms to `scans.prompt_injection.findings[]` per `architecture.md:202-220` S3 security-evidence shape):

```json
{
  "rule_id": "s4-claude-hooks-tamper",
  "severity": "high",
  "path": "<repo-relative path of the modified file>",
  "line_range": "<start-end>",
  "diff_preview": "<≤8-line summary of the diff>"
}
```

**Severity escalation.** Any rule firing at `high` severity sets `scans.prompt_injection.severity_max = "high"` → `overall_severity_max = "high"` in the aggregate security-evidence output. Epic 4's FR36 threshold gate CONSUMES the aggregate; the scan EMITS findings only (the halt-write lives in Epic 4, not in this rule set).

**Epic 4 consumer contract.** The rules live at `packages/keel-invariants/src/prompt-injection-rules/hook-settings-tamper.ts` exported as a typed module. Epic 4 Story 4.x wires them into the pre-commit scanner binary (Epic 4 FR40 / `architecture.md:222`). Unit tests at `prompt-injection-rules/hook-settings-tamper.test.ts` (three positive matches — one per rule — plus two negative — benign change to unrelated file + benign change to fork-extension slot `.hooks.PostToolUse`) assert the regex contracts without depending on the scanner binary. Fork-extension edits to `.hooks.PostToolUse[]` / `.hooks.UserPromptSubmit[]` / `.permissions.allow[]` do NOT fire `s4-claude-hooks-tamper` (the diff regex targets the `.claude/settings.json` path, not allow-list or fork-slot content; the settings-layer drift detection for substrate-authoritative sub-trees is Story 1.9 sync-gate `INV-claude-settings-deny-rules` via `jq-subtree` hashScope — see § Story 2.17 git-layer backstop).

### Fresh-fork seed contract (Story 2.17 Task 14 / D-36)

The substrate hook at `.claude/hooks/block-secret-access.sh` is byte-identical to the seed at `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh` (Story 2.17 Task 14 lockstep); `INV-claude-hook-secret-denylist` (substrate contentHash) plus Task 11.1's seed-byte-identity gate (manifest-entry approach per Task 11.1 rationale) cover the substrate ↔ seed coherence at Story 1.9 + pre-commit layers respectively. `create-keel-app` (Epic 15a Story 15a.4) materialises the seed tree into a fresh fork — the hook MUST emerge **executable** for the Claude Code `PreToolUse` contract to fire.

**Exec-bit preservation (D-36).** `create-keel-app` MUST invoke `tar --preserve-permissions` (or equivalent mode-preservation flag per archiver choice — `cp --preserve=mode`, `tar -xp`, `cp -a`) when extracting the seed tree. A naïve copy that drops the `0755` bit produces a hook that Claude Code silently skips: `PreToolUse` hook-script execute failure is treated as "hook error" by upstream → fails OPEN per contract → Story 2.16's deny-rule wall is entirely absent in the fresh fork. Story 2.17 pins the contract; Epic 15a Story 15a.4 implements the `--preserve-permissions` flag on the `create-keel-app` scaffolder.

**Byte-identity lockstep (5 sites).** Mirrors § Fork extension § AMEND path site numbering:

| # | Site                                                                       | Scope                              |
| - | -------------------------------------------------------------------------- | ---------------------------------- |
| 1 | `.claude/hooks/block-secret-access.sh`                                     | substrate                          |
| 2 | `.claude/settings.json`                                                    | substrate                          |
| 3 | `.ralph/config.toml` (halt-threshold pin)                                  | substrate                          |
| 4 | `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh`   | seed (byte-identical to 1)         |
| 5 | `packages/keel-templates/src/seeds/.claude/settings.json`                  | seed (byte-identical to 2)         |

Any AMEND-path edit to sites 1 + 2 MUST re-sync sites 4 + 5 in the same PR; drift between substrate and seed is caught by the manifest-entry approach (substrate contentHash refresh without seed refresh trips the substrate-seed parity gate).

**Exec-bit preservation limitation.** Git tracks the `0755` bit on tracked files by default (`core.fileMode = true`); a fresh clone under a POSIX filesystem preserves the bit automatically. Fresh-fork materialisation via `create-keel-app` is the edge case: the seed is a git-tracked file (bit preserved in the seed's checkout), but when the fork scaffold is materialised the archiver choice governs. Archivers that drop permissions (e.g. `unzip` without `-X`, `cp` without `--preserve=mode`, `tar` without `--preserve-permissions`) break the hook; `tar -xp` and `cp -a` preserve. Epic 15a Story 15a.4 owns the contract; Story 2.17 pins the doc.

**Fork-hook exec-bit parity.** The same `0755` requirement applies to any fork-authored `.claude/hooks/block-secret-access.fork.sh` — the substrate hook invocation at § Fork extension uses the `-x` test (`[ -x .claude/hooks/block-secret-access.fork.sh ]`), which returns false on non-executable files. Forks authoring the fork-hook MUST set the exec bit (`chmod 0755`) at author time; `create-keel-app --include-fork-invariants` (Epic 15a AC 4; downstream fork-extension flag) inherits the same `--preserve-permissions` discipline.

### Limitations + scope-carve-outs

- **Anchor-delimited `hooks.PreToolUse` region in `.claude/settings.json` — delivered by Story 2.17 via `jq-subtree` sub-tree hashing.** See § Story 2.17 git-layer backstop table above.
- **S4 prompt-injection scan rules for `.claude/hooks/**` + `.claude/settings*.json` + `.git/hooks/**` + `--dangerously-skip-permissions` injection — delivered by Story 2.17 Task 5 (three rules authored at `packages/keel-invariants/src/prompt-injection-rules/`; see § S4 prompt-injection scan rules above).** Epic 4 Story 4.x consumer binary (pre-commit scanner tier wiring + `security-evidence.json` aggregation) deferred — Story 2.17 ships the rule set + finding-shape contract only.
- **Grep content-search — scope carve-out; Epic 4 S4 scanner responsibility (Story 2.17 D-33 absorption).** The filename-substring denylist catches `Grep pattern=<anything> path=/home/dev/.claude/**` (path matched against the OAuth-token denylist) and Glob patterns containing `.env*` / `.secrets*` / `.envrc*` substrings. It does NOT catch CONTENT-based secret searches like `Grep pattern='SECRET_KEY=' path=/workspace/**` where the match target is file *content*, not file *name*. Content-based detection requires pattern-analysis heuristics (entropy check + regex-family match against common secret-token shapes) that are out of scope for the in-session `PreToolUse` hook at 1.0 — the hook operates on tool-call argv pre-execution; it does not peek into file content. Forward-link: Epic 4 Story 4.x S4 scanner tier is the correct surface for content-search secret defence — at pre-commit scan time the scanner walks the diff + scans file content against a pattern library and emits findings into `scans.secret_leakage.findings[]`. Story 2.17 pins the carve-out at the doc layer; Epic 4 owns the delivery.
- **Halt-write logic — deferred to Epic 3 Story 3.7.** The in-loop pre-push gate reads the JSONL + counts + writes `${RALPH_BASE_DIR}/halt` with `SECURITY_CRITICAL`. Story 2.16 ships the threshold value + JSONL schema (the contract Story 3.7 inherits).
- **Epic 4 FR37 security-evidence consumer — deferred to Story 4.13.** Consumes JSONL → `scans.hook_denials[]`. Story 2.16 ships the JSONL schema (the contract Story 4.13 inherits).
- **Iteration-id env-var standard — deferred to Epic 3.** Epic 3 standardises `RALPH_ITER_ID` env var propagation. Story 2.16 reads `${RALPH_ITER_ID:-unknown}` and tolerates absence (logs as `iteration_id: "unknown"`).
- **`.git/hooks/**` content-hash — delivered by Story 2.17 via `names-and-shebangs` hashing.** `INV-git-hooks-preservation` references `packages/keel-invariants/src/prek-hook-manifest.ts` (the enumerator file); the gate walks `.git/hooks/<name>` for each enumerated hook and hashes `sort(name\tshebang)`.
- **Live `claude` subprocess smoke-tests — operator-workstation-deferred.** Behavioural verification of "hook actually fires from inside a `claude` session blocking a real tool call" requires a live `claude` subprocess against a fixture repo. Story 2.16 ships impl-time fixture-fixture smokes (Task 1 verification gates) which exercise the hook script in isolation; the in-session integration is operator-smoke-class per the Story 2.13/2.15 live-smokes precedent.
- **Operator-workstation secrets not in scope.** `Read(~/.ssh/**)` + `Read(~/.aws/credentials)` are operator-workstation paths that live outside the devbox (NFR10 forbids host `.ssh/` bind-mount; `.aws/credentials` is not mounted by substrate compose). Inside the devbox, the sandbox + `keel_home_dev` named-volume isolation make those read-denies no-ops. Deferred to Story 2.17 bypass-resistance close-out (operators who DO bind-mount host `.ssh/` or `.aws/` against substrate advice self-amend).

### Cross-reference

- § Claude Code settings policy (Story 2.15) at `AGENTS.md` H3 — the permissions-layer baseline this hook composes on top of.
- § Container hardening (Story 2.5) at `AGENTS.md` H3 — the `keel_home_dev` named volume that hosts OAuth tokens (substrate contract for `cat /home/dev/.claude/**` + `cat /home/dev/.config/gh/**` rules).
- `docs/invariants/fork.md` — substrate-wins precedence + amendment-vs-fork decision tree.
- `packages/devbox/README.md § Claude PreToolUse hooks (Story 2.16)` — operator-facing quick-start.
- `INV-ralph-halt-reason-enum` at `INVARIANTS.md § Ralph loop contracts` — the closed halt-reason enum the Story 3.7 halt-write participates in.
- `INV-gitignored-secret-commit-deny` at `INVARIANTS.md` — the schema-companion EXEMPT convention (`.envrc.example`, `.secrets.example`, `.env.example`).
- `INV-no-verify-bypass` at `INVARIANTS.md` — the source-checked-in `--no-verify` / `--dangerously-skip-permissions` lint composing with the hook's in-session runtime block.
