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

- `<rule-id>` ∈ {`secret-access-denylist`, `hook-self-protection`} — the closed rule-id enum.
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
  "rule_id": "<secret-access-denylist|hook-self-protection>",
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

### Limitations + scope-carve-outs

- **Anchor-delimited `hooks.PreToolUse` region in `.claude/settings.json` — delivered by Story 2.17 via `jq-subtree` sub-tree hashing.** See § Story 2.17 git-layer backstop table above.
- **S4 prompt-injection scan rules for `.claude/hooks/**` + `.claude/settings*.json` diffs — deferred to Epic 4 + Story 2.17.** Pre-commit scanner tier wiring.
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
