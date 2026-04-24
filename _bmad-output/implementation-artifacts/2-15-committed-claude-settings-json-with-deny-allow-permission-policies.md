# Story 2.15: Committed `.claude/settings.json` with deny/allow permission policies

Status: ready-for-dev

<!-- Note: Validation is optional. Run `/bmad-create-story (args: "review")` for pre-dev quality check before `/bmad-testarch-atdd` / `/bmad-dev-story`. -->

## Story

As Tthew (substrate maintainer codifying the NFR5a in-session secret-access barrier),
I want a committed `.claude/settings.json` at the repo root declaring `permissions.deny` rules for secret paths + `permissions.allow` rules for common dev commands, alongside AGENTS.md/CLAUDE.md documentation of the fork-operator honour system (local overrides extend, never weaken substrate) and a fresh-fork seed in `packages/keel-templates/`,
So that Claude Code sessions (both interactive `claude` and Ralph's `claude -p` subprocess) inherit a hardened default permission policy on fresh-fork clone — no opt-in per user — closing NFR5a's in-session defense FOR THE PERMISSION-PROMPT-ENABLED PATH (Ralph's `--dangerously-skip-permissions` path is defended by Story 2.16's PreToolUse hooks; this story pins the permission-layer defense against interactive Claude sessions + any subagent path that runs with permissions intact).

## Acceptance Criteria

1. **Committed `.claude/settings.json` exists at repo root and is tracked in git with Claude-Code-shaped schema.** Given a fresh clone of `feat/epic-2-packaged-devbox` (or any branch post-Story-2.15 landing), when I open the repo root, then `.claude/settings.json` exists at `{project-root}/.claude/settings.json`, is tracked in git (`git ls-files .claude/settings.json` returns it), and its JSON schema matches Claude Code's official settings schema (top-level keys drawn from `permissions`, `hooks`, `env`, `model`, `apiKeyHelper`, `cleanupPeriodDays` — Story 2.15 scope populates `permissions` only; `hooks` is Story 2.16; other keys stay unset). The file parses as valid JSON (`python3 -m json.tool < .claude/settings.json` exits 0). The file is UTF-8 without BOM, 2-space indented, with a trailing newline.

2. **`permissions.deny` block lists substrate-minimum 13 deny rules.** Given the committed `.claude/settings.json`, when I read `permissions.deny`, then the array contains — at minimum — the 13 Story-2.15-pinned rules verbatim: `Read(.envrc*)`, `Read(**/.env*)`, `Read(.secrets*)`, `Read(/home/dev/.claude/**)`, `Read(/home/dev/.config/gh/**)`, `Bash(env)`, `Bash(env:*)`, `Bash(printenv*)`, `Bash(cat .envrc*)`, `Bash(cat **/.env*)`, `Bash(cat /proc/*/environ*)`, `Grep(**/.env*)`, `Glob(**/.env*)`. Entries are canonical Claude Code permission-rule strings (tool-name prefix + parenthesised argument pattern; `*` wildcard; `**` recursive glob per Claude Code's permission-matching semantics). Additional deny rules beyond the 13-minimum MAY be added at substrate author's discretion (e.g. `Read(~/.ssh/**)`, `Read(~/.aws/credentials)`) and MUST NOT be removed by forks.

3. **`permissions.allow` block lists common dev commands as a positive allowlist.** Given the committed `.claude/settings.json`, when I read `permissions.allow`, then the array contains — at minimum — the 6 Story-2.15-pinned rules: `Bash(pnpm *)`, `Bash(git status)`, `Bash(git diff*)`, `Bash(git log*)`, `Bash(ls *)`, `Bash(tsc *)`. These reduce permission prompts for read-only or safe-idempotent dev commands. Additional allow rules MAY be added (e.g. `Bash(pnpm test*)`, `Bash(pnpm lint*)`) but MUST NOT shadow a deny rule (Claude Code's `deny` always wins over `allow` per its permission-resolution semantics — the honour system AC below documents this).

4. **`.claude/settings.local.json` is user-specific + gitignored; AGENTS.md + CLAUDE.md document the fork-operator honour system.** Given `.gitignore`, when I `git check-ignore .claude/settings.local.json`, then the file is ignored (already at `.gitignore:20` — no change required). Given `AGENTS.md`, when I read § Claude Code settings policy (Story 2.15), then it documents: (a) committed `.claude/settings.json` is authoritative for the substrate's deny/allow baseline, (b) `.claude/settings.local.json` is a user-specific override that extends but MUST NOT weaken the substrate (by Claude Code's permission-resolution semantics `deny` always wins — a local `allow` entry for a substrate-denied pattern is silently ignored), (c) the honour system: fork operators SHOULD NOT remove or rewrite deny rules in their fork's committed `.claude/settings.json` (substrate-wins via `docs/invariants/fork.md § Precedence`), (d) lint-flagged-where-detectable: Story 2.17 introduces the content-hash + S4 scan gating (out of Story 2.15 scope — forward pointer). Given `CLAUDE.md`, when I read its Claude-Code-specifics bullet list, then the existing `.claude/settings.local.json` bullet is updated to also reference the new committed `.claude/settings.json` counterpart.

5. **Permission-prompt-enabled session rejects denied tool calls with a deny-rule pointer.** Given a Claude session WITHOUT `--dangerously-skip-permissions` (interactive `claude` on host or in devbox; any subagent path where the permission layer is active), when Claude attempts a denied tool call (e.g. `Read .envrc`), then Claude Code's permission layer blocks the call before tool execution and surfaces a deny-rule pointer in the session UI (the exact UI string is upstream Claude Code CLI's concern; Story 2.15 only guarantees the RULE triggers — verification is via `claude` invocation against a small fixture; behavioural verification deferred to operator smoke per iter-286-style "operator-workstation-deferred live-smoke" precedent, with the unit signal being "rule is present in committed JSON" per AC 2).

6. **Ralph `--dangerously-skip-permissions` path — permissions layer bypassed, Story 2.16 hook catches it (forward-ref AC).** Given a Ralph session invoking `claude -p --dangerously-skip-permissions` (the default Ralph runtime path per NFR5 + `.ralph/PROMPT_*.md`), when Claude attempts a denied tool call, then the permissions layer IS bypassed as designed (permission rules are advisory for `-p --dangerously-skip-permissions` paths per upstream Claude Code contract) BUT the Story 2.16 PreToolUse hook at `.claude/hooks/block-secret-access.sh` catches it AND NFR5a holds because hooks are the Ralph-path defense. **Story 2.15 scope NOTE:** this AC is a forward-ref — Story 2.15 does NOT ship the hook script or the `hooks` block registration; Story 2.16 ships both. Story 2.15's responsibility here is to (a) not break the precondition (do not register an empty/broken `hooks` block that would shadow Story 2.16's later add), (b) document the forward-ref in Task 3's AGENTS.md text so operators reading Story 2.15's standalone landing understand the Ralph-path defense is partially TODO until Story 2.16.

7. **Fresh-fork template path: `packages/keel-templates/` ships the seed `.claude/settings.json`.** Given `packages/keel-templates/src/seeds/.claude/settings.json`, when a fresh `create-keel-app` (Epic 15a Story 15a.4 consumer) runs, then it materialises the seed at the new fork's repo root as `.claude/settings.json` — no manual setup is required by the fork operator. The seed IS the exact same file content as the substrate's `.claude/settings.json` at Story 2.15 landing (byte-identical at the substrate's own `--from=main` bootstrap path; forks diverge via their own commits post-scaffolding). Story 2.15 owns the seed file's authoring; Story 15a.4 owns the `create-keel-app` wiring that copies `packages/keel-templates/src/seeds/**` into the new fork's working tree.

## Tasks / Subtasks

- [ ] **Task 1: Author committed `.claude/settings.json` at repo root** (AC 1, AC 2, AC 3)
  - [ ] **Insertion point.** Create a NEW file at `{project-root}/.claude/settings.json`. The `.claude/` directory already exists (contains `agents/`, `skills/`, `worktrees/`, `settings.local.json` — see `.claude/` listing at Story 2.15 orient). `settings.json` must be a NEW tracked file; do NOT co-locate rules inside `settings.local.json` (which is gitignored per `.gitignore:20` and user-specific per CLAUDE.md:74).
  - [ ] **File content (copy-ready; NO placeholders).** Write the following JSON verbatim. The file uses 2-space indentation, Claude-Code-canonical `permissions.deny` / `permissions.allow` array-of-strings shape per Claude Code CLI @2.1.116 (baked at `packages/devbox/Dockerfile:121`; upstream reference: Claude Code settings documentation):
    ```json
    {
      "permissions": {
        "deny": [
          "Read(.envrc*)",
          "Read(**/.env*)",
          "Read(.secrets*)",
          "Read(/home/dev/.claude/**)",
          "Read(/home/dev/.config/gh/**)",
          "Bash(env)",
          "Bash(env:*)",
          "Bash(printenv*)",
          "Bash(cat .envrc*)",
          "Bash(cat **/.env*)",
          "Bash(cat /proc/*/environ*)",
          "Grep(**/.env*)",
          "Glob(**/.env*)"
        ],
        "allow": [
          "Bash(pnpm *)",
          "Bash(git status)",
          "Bash(git diff*)",
          "Bash(git log*)",
          "Bash(ls *)",
          "Bash(tsc *)"
        ]
      }
    }
    ```
  - [ ] **Schema-shape rationale.** Deliberately omit `hooks`, `env`, `model`, `apiKeyHelper`, `cleanupPeriodDays`, and all other Claude Code settings keys. Story 2.15 scope is `permissions` only; Story 2.16 appends a `hooks` top-level key alongside `permissions` when it registers PreToolUse hooks. Authoring an empty `"hooks": {}` or `"hooks": []` at Story 2.15 would risk shadowing Story 2.16's later add (Claude Code's settings merge semantics may treat an explicit empty as "hooks-disabled" vs omitted-means-default). Omit the key entirely.
  - [ ] **Deny rule rationale.** The 13 rules close NFR5a's minimum deny coverage: `Read(.envrc*)` + `Read(**/.env*)` + `Read(.secrets*)` deny environment-file reads; `Read(/home/dev/.claude/**)` + `Read(/home/dev/.config/gh/**)` deny OAuth-token reads (Story 2.8 + Story 2.9 token-persistence paths; these paths are inside the `keel_home_dev` named volume per Story 2.5 substrate); `Bash(env)` + `Bash(env:*)` + `Bash(printenv*)` deny env-dump idioms; `Bash(cat .envrc*)` + `Bash(cat **/.env*)` + `Bash(cat /proc/*/environ*)` deny direct secret-file cat-idioms; `Grep(**/.env*)` + `Glob(**/.env*)` deny secret-file discovery via the Grep/Glob tools. **Glob semantics** (critical — Claude Code's permission-rule patterns use shell-glob syntax): `.envrc*` matches `.envrc` + `.envrc.local` + `.envrc.example`; `**/.env*` matches `.env`, `.env.local`, `.env.production`, `path/to/.env` at any depth; `.secrets*` matches `.secrets` + `.secrets.example` (the `.example` file is a COMMITTED template per `INV-gitignored-secret-commit-deny` — not a secret; the deny rule trades a small false-positive against a larger true-positive surface, which is the correct posture for NFR5a). **Preservation constraint:** do NOT reorder the 13 entries in Task 1 (ordering is insignificant for Claude Code's deny resolution — first-match semantics do not apply to deny; ALL denies evaluated — but stable ordering aids diff-review at future amendments).
  - [ ] **Allow rule rationale.** The 6 rules reduce permission prompts for common dev commands in interactive `claude` sessions where the permission layer is active: `Bash(pnpm *)` covers the 18+ `pnpm devbox:*` / `pnpm ralph:*` / `pnpm claude` / `pnpm gh:auth` / `pnpm keel-invariants:*` shims; `Bash(git status)` + `Bash(git diff*)` + `Bash(git log*)` cover the Ralph orient sequence (PROMPT_build.md steps 0c / 0h); `Bash(ls *)` covers common directory inspection; `Bash(tsc *)` covers type-check invocation. **Allow is additive; deny wins.** Per Claude Code's permission-resolution semantics (documented in the upstream settings docs), when a pattern matches BOTH an allow rule AND a deny rule, `deny` wins. So `Bash(cat .envrc*)` staying denied even though `Bash(pnpm *)` is allowed is trivially correct; the allow rule only reduces prompts for explicitly-allowed patterns. Forks MUST NOT attempt to "bypass" a substrate deny via a more-specific allow — it won't work, and attempting to do so signals a fork misunderstanding per the AGENTS.md honour system (Task 3).
  - [ ] **File verification gates** (pre-commit, per Story 2.1's `INV-gitignored-secret-commit-deny` SC gate — verify at landing):
    - `python3 -m json.tool < .claude/settings.json >/dev/null` exits 0 (JSON parse).
    - `jq -r '.permissions.deny | length' .claude/settings.json` returns `>= 13` (minimum deny coverage).
    - `jq -r '.permissions.allow | length' .claude/settings.json` returns `>= 6` (minimum allow coverage).
    - `git check-ignore .claude/settings.json` returns non-zero (i.e. file is NOT ignored — tracked — this is the inverse of `.claude/settings.local.json` which IS ignored per `.gitignore:20`).
    - `git ls-files .claude/settings.json` returns the file post-`git add`.

- [ ] **Task 2: Verify `.gitignore` posture** (AC 4 — verification only; no edit expected)
  - [ ] **Existing entry check.** `grep -n '^\.claude' .gitignore` returns `.claude/settings.local.json` (at `.gitignore:20`) + `.claude/worktrees/` (at `.gitignore:21`). Confirm `.claude/settings.json` is NOT ignored (it should not match either pattern — `settings.json` != `settings.local.json`; `.claude/` not a directory-level ignore).
  - [ ] **No-edit guardrail.** Task 2 is verification-only. Do NOT add `.claude/settings.json` to `.gitignore` (it would be counterproductive — the file MUST be tracked per AC 1). Do NOT remove or modify the existing `.claude/settings.local.json` or `.claude/worktrees/` entries (they are Story 1.7 / Story 2.5 prior-substrate concerns and out of Story 2.15 scope).
  - [ ] **Verification gate.** `git check-ignore -v .claude/settings.json` exits 1 (not ignored); `git check-ignore -v .claude/settings.local.json` exits 0 with pattern `.gitignore:20:.claude/settings.local.json	.claude/settings.local.json`.

- [ ] **Task 3: `AGENTS.md` § Claude Code settings policy (Story 2.15) — fork-operator honour system** (AC 4, AC 6 forward-ref documentation)
  - [ ] **Insertion point.** Append a NEW H3 `### Claude Code settings policy (Story 2.15)` at the end of `AGENTS.md`'s § Devbox iteration environment block — AFTER the existing `### Legacy-devbox branch retention (Story 2.14)` H3 (which currently ends at `AGENTS.md:209`) and BEFORE the existing `## Ralph loop` H2 (at `AGENTS.md:211`). SC-15 sibling-append discipline applies: do NOT modify existing H3 sections `### Per-fork whitelist override (Story 2.4)` through `### Legacy-devbox branch retention (Story 2.14)` — append the NEW H3 as a sibling only.
  - [ ] **Content.** Author approximately 8-12 bullets covering:
    - (a) **What this is.** One paragraph intro: "`.claude/settings.json` at the repo root is the committed Claude Code permission policy (Story 2.15 substrate; per NFR5a in-session secret-access barrier). It ships a `permissions.deny` baseline for secret-path reads + env-dump idioms + token-path reads, plus a `permissions.allow` positive list for common dev commands. Machine-enforced contract: the file is tracked in git + required to exist; Story 2.17 adds a content-hash backstop via `INV-claude-hook-secret-denylist` (not yet landed — forward-ref)."
    - (b) **Authoritative baseline + fork extension.** "Fork operators MAY extend the deny list (add fork-specific secret paths: e.g. `Read(fork-specific-secret.yaml)`) and MAY extend the allow list (add fork-specific dev commands: e.g. `Bash(cargo *)`). Forks MUST NOT remove or rewrite a substrate-owned deny rule — substrate-wins via `docs/invariants/fork.md § Precedence`. Growth-tier forks that want to codify fork-specific deny rules in `INVARIANTS.fork.md` follow the pattern at `docs/invariants/fork.md § INVARIANTS.fork.md scaffold`."
    - (c) **Local-override file.** "`.claude/settings.local.json` is a user-specific override (gitignored at `.gitignore:20`). Operators MAY maintain personal preferences there — e.g. additional allow rules for local-tooling commands. The local file merges with the committed file per Claude Code's precedence rules; however, **Claude Code's permission resolution is `deny-wins-over-allow`** — a local `allow` for a pattern that matches a committed `deny` is silently ignored. Operators MUST NOT attempt to weaken the substrate deny list locally; doing so reveals a misunderstanding of the resolution semantics rather than achieving a bypass. Honour system — lint-flagged where detectable per Story 2.17's bypass-resistance surface (forward-ref)."
    - (d) **Ralph-path defense limitation (AC 6 forward-ref).** "The `permissions.deny` baseline is the permission-layer defense — it applies to interactive `claude` sessions + any subagent path with permissions intact. **Ralph's runtime path (`claude -p --dangerously-skip-permissions` per NFR5) BYPASSES the permissions layer by design** — settings.json alone does NOT defend Ralph iterations. Story 2.16's PreToolUse hook at `.claude/hooks/block-secret-access.sh` catches denied tool calls regardless of permission mode (per NFR5a), completing the Ralph-path defense. Until Story 2.16 lands, Ralph iterations rely on the devbox sandbox's egress controls + the operator's manual review of iteration diffs to catch secret-exfiltration attempts."
    - (e) **Precedence with hooks (forward-ref to Story 2.16).** "When Story 2.16 lands, the `hooks.PreToolUse` block registers with entries for `Bash`, `Read`, `Grep`, `Glob` — each invokes `.claude/hooks/block-secret-access.sh`. The hook composes ON TOP of `permissions.deny`: for the permission-prompt-enabled path both layers fire (hook first, then permission layer — a rejected hook blocks before permission check); for the `--dangerously-skip-permissions` path only the hook fires. Until Story 2.16 lands, the `hooks` key is absent from the committed JSON — do NOT pre-emptively register an empty `hooks` block at Story 2.15 (Claude Code's settings-merge semantics may treat an explicit empty as 'disabled' which would shadow Story 2.16's later add)."
    - (f) **Settings-tampering bypass-resistance (forward-ref to Story 2.17).** "Tampering with `.claude/settings.json` or `.claude/hooks/**` from inside a Claude session is denied by Story 2.16's hook self-protection rules (Edit/Write on `.claude/settings*.json` + Bash mutations against those paths). Story 2.17 adds the git-layer backstop: `INV-claude-hook-secret-denylist` manifest content-hash covers `.claude/settings.json` + `.claude/hooks/**`; out-of-band tampering (e.g. edits that evade the in-session hook) fails the pre-merge invariant sync gate (Story 1.9 substrate). Story 2.15's baseline settings.json becomes the content-hashed substrate-authoritative baseline at Story 2.17 landing."
    - (g) **Halt-escalation pointer (forward-ref).** "Story 2.16 + Epic 3 Story 3.7 wire the `SECURITY_CRITICAL` halt escalation: N=3 hook-self-protection blocks per Ralph iteration write a halt sentinel `{\"reason\":\"SECURITY_CRITICAL\", ...}` per the closed halt-reason enum (`INV-ralph-halt-reason-enum`; PRD FR14k). Agents inheriting downstream scope MUST NOT retry silently past the halt or invent a new halt reason."
    - (h) **Cross-reference:** "§ Container hardening (Story 2.5) for the `keel_home_dev` named volume that hosts OAuth tokens; § Claude Code authentication (Story 2.8) + § gh CLI authentication (Story 2.9) for the deny-list-covered token paths; `docs/invariants/fork.md` for the substrate-wins precedence + amendment-vs-fork decision tree; `packages/devbox/README.md § Claude Code settings policy (Story 2.15)` (operator-facing quick-start — Task 5)."
  - [ ] **SC-15 sibling-append discipline.** DO NOT modify existing `### Per-fork whitelist override (Story 2.4)` through `### Legacy-devbox branch retention (Story 2.14)` H3 sections — append the NEW H3 as a sibling only. Do NOT touch `## Ralph loop` H2 below. The pattern mirrors Stories 2.6 / 2.11 / 2.12 / 2.13 / 2.14 landings.

- [ ] **Task 4: `CLAUDE.md` Claude-Code-specifics bullet touch** (AC 4)
  - [ ] **Insertion point.** `CLAUDE.md:74` currently reads `- **Don't touch `.claude/settings.local.json`** — it's user-specific and gitignored.`. Update this bullet to reference the committed counterpart AND add a new sibling bullet referencing the committed file. Resulting two bullets (replace the existing line with these two):
    ```markdown
    - **Committed settings at `.claude/settings.json`** — tracked permission policy (`permissions.deny` + `permissions.allow`) per NFR5a. See `AGENTS.md § Claude Code settings policy (Story 2.15)` for the fork-extension honour system. Don't edit to weaken the deny list — Story 2.17's content-hash sync-gate will flag tampering once landed.
    - **Don't touch `.claude/settings.local.json`** — it's user-specific and gitignored. Local allow rules extend but cannot weaken committed deny rules (see AGENTS.md H3 for resolution semantics).
    ```
  - [ ] **Scope.** Do NOT edit other CLAUDE.md sections (knowledge-file contract table, promotion rules, etc.). This is a targeted two-bullet update only.

- [ ] **Task 5: `packages/devbox/README.md` operator-facing pointer** (AC 4 visibility)
  - [ ] **Insertion point.** Append a NEW H2 `## Claude Code settings policy (Story 2.15)` AFTER the existing `## Legacy-devbox branch retention (Story 2.14)` H2 (at the current README tail — verify position via `grep -n '^## ' packages/devbox/README.md | tail -5`) and BEFORE the existing `## cc-devbox upstream provenance` H2 (Stories 2.11 / 2.12 / 2.13 / 2.14 established this sibling-append position). SC-15 sibling-append discipline applies: do NOT edit existing H2 sections.
  - [ ] **Content.** Brief, operator-facing (~30-50 lines). Shape:
    - (a) One paragraph: "`.claude/settings.json` at the repo root ships the substrate-authoritative Claude Code permission policy (Story 2.15). The committed file declares `permissions.deny` baseline for secret paths + env-dump idioms + token paths, plus `permissions.allow` positive-list for common dev commands. Fork operators extend via the honour system (see `AGENTS.md § Claude Code settings policy`); they MAY add deny/allow rules but MUST NOT remove or weaken substrate-owned deny rules."
    - (b) Quick-start: how to view the policy (`cat .claude/settings.json | jq .permissions`), how to extend with fork-specific rules (edit `.claude/settings.json` directly + AMEND path via `docs/invariants/fork.md § Amendment-vs-fork decision` if adding substrate-level rules), and the user-override path (edit `.claude/settings.local.json` — gitignored — for personal preferences).
    - (c) Ralph-path caveat: "Ralph iterations run `claude -p --dangerously-skip-permissions` per NFR5 — settings.json is advisory for that path. Story 2.16's PreToolUse hook at `.claude/hooks/block-secret-access.sh` (not yet landed) completes the Ralph-path defense. Until Story 2.16 lands, Ralph's secret-access defense is the devbox sandbox egress controls + operator diff review."
    - (d) Pointer: "Machine-enforced contract arrives at Story 2.17's content-hash backstop (`INV-claude-hook-secret-denylist` covers `.claude/settings.json` + `.claude/hooks/**`). See `AGENTS.md § Claude Code settings policy (Story 2.15)` for the full fork-extension contract."
  - [ ] **SC-15 sibling-append discipline.** DO NOT modify existing `## Host-side CLI (Story 2.6)` through `## Legacy-devbox branch retention (Story 2.14)` H2 sections.

- [ ] **Task 6: `packages/keel-templates/` seed authoring for fresh-fork template path** (AC 7 — Epic 15a Story 15a.4 consumer)
  - [ ] **Seed file path.** Create `packages/keel-templates/src/seeds/.claude/settings.json` — a NEW directory tree inside the existing `packages/keel-templates/` package. The `src/seeds/` convention is Story 15a.4's consumer contract: `create-keel-app` copies `packages/keel-templates/src/seeds/**` verbatim into the new fork's working tree, preserving the file tree shape relative to `src/seeds/`.
  - [ ] **Seed content.** BYTE-IDENTICAL copy of the substrate's `.claude/settings.json` authored in Task 1. The seed IS the substrate baseline; forks diverge via their own commits post-scaffolding. If Story 2.15 or a later substrate amendment edits `.claude/settings.json`, the seed MUST be re-synced in lockstep — a substrate edit without a seed edit is a regression caught by Story 1.9's sync-gate once Story 2.17 registers the content-hash invariant (forward-ref). At Story 2.15 landing there is NO machine-enforced lockstep; the substrate-seed sync relies on (a) operator discipline, (b) Story 2.17's content-hash gate covering BOTH paths.
  - [ ] **Seed authoring recipe.** At landing:
    ```bash
    mkdir -p packages/keel-templates/src/seeds/.claude
    cp .claude/settings.json packages/keel-templates/src/seeds/.claude/settings.json
    # Verify byte-identical
    diff .claude/settings.json packages/keel-templates/src/seeds/.claude/settings.json && echo "OK: seed matches substrate"
    ```
  - [ ] **`packages/keel-templates/README.md` update.** The existing README (at `packages/keel-templates/README.md`) is currently a 5-line stub: `# @keel/keel-templates` + `Page-template library.` + `Empty shell in Story 1.1 — populated in Epic 12.`. Story 2.15 is the first substrate producer of seeded assets into `src/seeds/`, so Task 6's README edit must (a) replace the "populated in Epic 12" sentence (now inaccurate — seeding begins at Story 2.15, not Epic 12) with a short paragraph framing the package as the consumer contract for substrate-authored seeds, AND (b) create a NEW seeded-assets list (the list does not yet exist) with a single bullet: "- `src/seeds/.claude/settings.json` — Story 2.15 committed Claude Code permission policy (deny/allow baseline per NFR5a). `create-keel-app` (Story 15a.4) materialises this at fresh-fork repo root." Future seed-producers (Story 2.16 hooks, Story 3.3 PROMPT templates) append sibling bullets; SC-15 sibling-append discipline applies.
  - [ ] **`packages/keel-templates/package.json` passthrough.** No `package.json` edit expected — the `src/seeds/` tree is filesystem-level, not a programmatic export. Consumer (`create-keel-app` Story 15a.4) reaches into `packages/keel-templates/src/seeds/` via the pnpm workspace + fs-level copy. Verify at landing: `ls packages/keel-templates/src/seeds/.claude/` returns `settings.json`.

### Review Findings (post-dev / CR)

_(Populated by `/bmad-create-story (args: "review")` post-dev SM + `/bmad-code-review (args: "2")` CR iterations per § Story Lifecycle Decision Matrix.)_

## Dev Notes

### Architecture & invariant context

Story 2.15 lands the first artifact of the **Claude-Code-host-concerns block** (Stories 2.15-2.17) within Epic 2. This block pivots Epic 2 from devbox-substrate-runtime concerns (Stories 2.1-2.13 — egress, hardening, host-side shims, healthcheck) and devbox-policy concerns (Story 2.14 — legacy-branch retention) to **in-session Claude Code permission-layer concerns**:

- **Story 2.15 (this story)** — committed `.claude/settings.json` deny/allow baseline. Permission-layer defense for interactive + permissions-intact subagent paths. No hooks, no manifest entry, no halt-threshold wiring.
- **Story 2.16** — PreToolUse hook scripts at `.claude/hooks/block-secret-access.sh` + `hooks` block registration in `.claude/settings.json` + `INV-claude-hook-secret-denylist` manifest entry + N=3 halt-threshold wiring. Covers the Ralph `--dangerously-skip-permissions` path.
- **Story 2.17** — bypass-resistance: content-hash manifest entry covers `.claude/settings.json` + `.claude/hooks/**` + `.git/hooks/**` (pre-merge sync-gate); S4 prompt-injection scan flags on hook/settings-path diffs (Epic 4's pre-commit scanner tier); cumulative Epic 2 DEFER-queue close-out pass.

Story 2.15's role in this block: **ship the baseline JSON + docs + seed**; do NOT pre-emptively land downstream concerns (hooks, manifest, halt-wire, S4 rules). Scope boundaries below.

### Scope boundaries — what Story 2.15 does NOT ship

The following are deliberately deferred per the Stories 2.15-2.17 division of labour:

1. **Hook scripts.** `.claude/hooks/block-secret-access.sh` — Story 2.16 Task 1.
2. **`hooks` block in `.claude/settings.json`.** Story 2.16 Task 2 appends a top-level `hooks` key alongside the `permissions` key from Story 2.15.
3. **Manifest entry `INV-claude-hook-secret-denylist`.** Story 2.16 / Story 2.17 co-owns (Story 2.16 registers the initial entry covering hooks + settings together; Story 2.17 expands coverage to `.git/hooks/**`).
4. **`INVARIANTS.md` H3 + anchor bullet.** Story 2.16 / 2.17 lands the INVARIANTS.md surface concurrent with the manifest entry.
5. **`docs/invariants/claude-hook-denylist.md`.** Story 2.16 authors the canonical invariant doc; Story 2.15 does NOT pre-create it.
6. **Ralph halt wiring for `SECURITY_CRITICAL`.** Story 2.16 + Epic 3 Story 3.7 co-own.
7. **S4 prompt-injection scan rules.** Epic 4 scanner + Story 2.17 rule additions.
8. **Content-hash bypass-resistance.** Story 2.17.

Story 2.15 landing therefore produces:

- `.claude/settings.json` (new tracked file)
- `packages/keel-templates/src/seeds/.claude/settings.json` (new seed, byte-identical)
- `AGENTS.md § Claude Code settings policy (Story 2.15)` H3 (new append)
- `CLAUDE.md:74` bullet update (targeted two-bullet edit)
- `packages/devbox/README.md § Claude Code settings policy (Story 2.15)` H2 (new append)
- `packages/keel-templates/README.md` seed-list bullet (one-line append)

### NFR5a mapping

NFR5a (PRD `:1075`) enumerates the minimum-coverage requirements for the in-session secret-access barrier:

- **Read-path deny:** `.envrc`, `.env*`, `~/.ssh/**`, `~/.aws/credentials`, `~/.config/gh/**`, known host secret paths.
- **Bash-command deny:** secret-dump idioms (`printenv | grep`, `cat ~/.*`, bare `env`, `echo $<SECRET_VAR>`).
- **Write-path deny:** `.claude/settings*.json`, `.claude/hooks/**`, `.git/hooks/**` (per NFR5b).

Story 2.15's AC 2 (13-entry `permissions.deny`) maps to the Read + Bash axes of NFR5a's coverage. The Write-path axis (Edit/Write denials on settings/hook/git-hook paths) is Story 2.16's hook-based defense (settings.json's `permissions.deny` cannot express Write-path denials with the same granularity as a PreToolUse hook reading tool-call JSON from stdin — hook-based defense is the right tool for Write-path patterns).

**Gap against strict NFR5a minimum:** Story 2.15's 13-entry deny list does NOT include `Read(~/.ssh/**)` or `Read(~/.aws/credentials)`. These are operator-workstation secrets that live outside the devbox (NFR10 forbids host `.ssh/` bind-mount; `.aws/credentials` is not mounted by substrate compose). Inside the devbox, the devbox sandbox + the `keel_home_dev` named-volume isolation make these read-denies no-ops (the paths don't resolve to anything sensitive inside the container).

**Decision — DEFER to Story 2.17 bypass-resistance close-out** (pinned pre-dev SM per iter-296): the two entries (`Read(~/.ssh/**)` + `Read(~/.aws/credentials)`) are NOT added at Story 2.15 landing. Rationale: (a) substrate-internal posture is the no-op case as described above — adding entries that resolve to nothing is decorative at best; (b) Story 2.17 scope already owns "bypass-resistance + expanded coverage" for the deny/hook substrate, including the `.git/hooks/**` expansion — operator-workstation-guard extensions belong in the same scope gate; (c) forks that DO bind-mount host `.ssh/` or `.aws/` (against substrate advice) can self-amend via the AMEND path at `docs/invariants/fork.md § Amendment-vs-fork decision tree` — operator-layer opt-in is the correct mechanism, not pre-emptive substrate inclusion. AC 2's "at minimum" phrasing remains in place; Story 2.17 may revisit add-or-keep-deferred at SC-17 close-out reconciliation. The dev agent MUST NOT add these entries at Story 2.15 dev-story landing — doing so would scope-creep into Story 2.17's bypass-resistance surface.

### Claude Code CLI version pin

`@anthropic-ai/claude-code@2.1.116` is baked at `packages/devbox/Dockerfile:121`. The permission-rule schema (array of tool-pattern strings, `deny` + `allow` keys under `permissions`) is stable across Claude Code 2.x per upstream release notes. Story 2.15's JSON shape is forward-compatible with 2.1.x and should be validated at Story 2.16 landing if upstream bumps the Claude Code version (cross-ref: Dockerfile lockstep — iter-123 bake; Renovate-tracked per Story 1.15's apt + npm manager config).

**Schema reference.** Claude Code's settings schema is documented at the upstream CLI's settings doc page (reachable via `claude --help` in-container, or online at Claude Code's canonical docs URL). Story 2.15 does NOT commit a local JSON schema file — the permission-rule subset is narrow + stable enough that a local schema would over-specify (and Story 2.17's content-hash backstop provides the immutability guarantee). Dev MAY optionally cite the upstream schema URL in a JSON comment (note: strict JSON does not allow comments — if citing, use a top-level `"$schema"` field pointing at the upstream URL IF that URL is stable and publicly resolvable, else omit).

### Fork-extension precedence (docs/invariants/fork.md)

Story 1.16 landed the substrate-wins precedence + amendment-vs-fork decision tree. Story 2.15's settings.json inherits this precedence model:

- **FORK path** — fork-specific deny/allow rules (e.g. `Read(fork-specific-secret.yaml)`, `Bash(cargo *)`) go into the fork's committed `.claude/settings.json`. Forks MAY NOT remove substrate-owned deny rules; Story 2.17's content-hash gate catches tampering.
- **AMEND path** — if a fork needs a substrate-wide change (e.g. "all forks should deny `Read(id_ed25519*)`"), open a PR against `packages/keel-invariants/` + `INVARIANTS.md` + the substrate `.claude/settings.json` + the `packages/keel-templates/src/seeds/.claude/settings.json` seed (lockstep) + the manifest entry (Story 2.16+) + AGENTS.md anchor bullet.
- **DEFER path** — premature or speculative rules log to `_bmad-output/implementation-artifacts/deferred-work.md` (Story 2.17 SC-17 close-out absorbs).

### Previous story intelligence (Story 2.14 → Story 2.15)

Story 2.14 closed at iter-294 CR with bundled PATCH-2 close (sm-verified → done in one iter; P1 bisect-shorthand three-site lockstep + P2 cherry-pick category-count three-site lockstep). Lessons carried forward to Story 2.15:

- **Three-site-lockstep discipline** (iter-279 D-5 precedent reinforced at iter-281 + iter-294): whenever substrate content appears in MORE than one authoritative location (AGENTS.md + invariant doc + README + manifest description), edits MUST update all sites in lockstep. Story 2.15 has this shape: `.claude/settings.json` content appears at (a) substrate root `.claude/settings.json`, (b) `packages/keel-templates/src/seeds/.claude/settings.json`. Substrate-seed lockstep is a **two-site** case; Task 6 requires byte-identical copy + `diff` gate. No three-site-lockstep hazard yet (Story 2.17 will add a content-hash constraint as the third site, but at Story 2.15 landing there are only two).
- **SC-15 sibling-append discipline** (Stories 2.6 / 2.11 / 2.12 / 2.13 / 2.14): new H2/H3 sections APPEND as siblings; existing sections MUST NOT be edited. Story 2.15 appends H3 to AGENTS.md + H2 to packages/devbox/README.md + updates two bullets in CLAUDE.md (a targeted edit, not a new section — consistent with Story 2.13's bullet touch pattern at READMEs). Do NOT "tidy" prior story sections under cover of Story 2.15 landing.
- **No hook-bypass on `main`** (Story 1.6 `INV-no-verify-bypass`; Story 2.14's scope-guardrail at `2-14-…:77-80`): Story 2.15 commits land on `main`'s PR branch `feat/epic-2-packaged-devbox` — `git commit --no-verify` is FORBIDDEN. If prek hooks flag the new `.claude/settings.json` as a secret-pattern false-positive (unlikely; the file is JSON with no env-var-value content), debug and fix rather than bypass. If a legitimate lint conflict emerges, document it and DEFER to Story 2.17 SC-17 close-out (e.g. "ESLint doesn't lint JSON — no expected conflict").
- **Forecast band** (iter-286 NOVEL LESSON; Story 2.14 closed at 8 cumulative PATCH within the 6-10 forecast band for narrow-diff doc-heavy stories): Story 2.15 is **narrower than 2.14** (one JSON + one seed + three doc touches, vs 2.14's four-task invariant-doc + four doc touches + branch materialization). Forecast band: **3-6 cumulative PATCH** across pre-dev SM + dev-story + post-dev SM + CR. Zero-PATCH is plausible for the JSON portion (deny/allow rules are verbatim from epics.md AC 2/3 — minimal authoring judgment); the doc touches are the PATCH-susceptible surface (AGENTS.md section length + cross-ref density + the CLAUDE.md two-bullet wording).
- **Sprint-status row transition** (Stories 2.11 / 2.12 / 2.13 / 2.14 pattern): sprint-status row `2-15-…: backlog` → `ready-for-dev` at Step 6 of this skill; `ready-for-dev → in-progress` at `/bmad-testarch-atdd` landing (or `/bmad-dev-story` if ATDD skipped per narrower-grounds precedent — more below); `in-progress → review` at dev-story completion; `review → done` at CR PATCH-closure.

### ATDD-applicability predicate (forward-ref to Story State `validated`)

Story 2.15 is a **configuration + documentation story** — no executable code path, no runtime behaviour to assert via Vitest/Playwright unit tests. Red-phase ATDD scaffolds per `/bmad-testarch-atdd` would need to target:
- JSON-schema-validity assertions (Ajv or `python3 -m json.tool`) — trivially pass once Task 1 writes the file.
- `git ls-files` / `git check-ignore` shell assertions — filesystem-level gates, not runtime-code gates.
- Claude Code CLI permission-rule assertions — require a live `claude` subprocess exercising the rules against a fixture repo, which is **operator-workstation-deferred** per the Story 2.13 live-smokes-deferred precedent (AC 5's deny-rule-pointer behavioural verification is operator-smoke-class, not unit-class).

**Likely ATDD-skip trajectory:** the Story-Lifecycle state transition `validated → atdd-scaffolded` may reduce to `validated → (ATDD-skip-documented) → in-dev` per iter-292's NOVEL-LESSON narrower-grounds trace-WAIVED precedent (Story 2.14 applied grounds-(ii)+(iii) from the 24-precedent chain; Story 2.15 may apply grounds-(ii) — "configuration-only delta, no executable logic branch" — as a single-ground waive narrower than even 2.14). Final decision belongs to the `/bmad-testarch-atdd` invocation; the pre-dev SM should flag this in `.ralph/@plan.md § ATDD Red Phase` as `_(none — ATDD-skip grounds-(ii): configuration-only delta)_` if the waiver holds. If the dev agent wants a red-phase gate, the minimum viable scaffold is a JSON-schema assertion in `packages/keel-invariants/src/check-claude-settings.ts` — this is INSIDE Story 2.17's bypass-resistance scope, not 2.15, so pre-emptively scaffolding at 2.15 would scope-creep.

### Testing standards summary

Story 2.15's verification surface is **filesystem + JSON-shape**, not runtime behaviour:

- **Task 1 verification:** `python3 -m json.tool < .claude/settings.json >/dev/null` (JSON parse); `jq .permissions.deny | length` ≥ 13; `jq .permissions.allow | length` ≥ 6. Run locally at dev-story landing.
- **Task 2 verification:** `git check-ignore .claude/settings.json` exits 1 (not ignored); `git check-ignore .claude/settings.local.json` exits 0 (ignored).
- **Task 3-5 verification:** rendered Markdown — `grep -c '^### Claude Code settings policy (Story 2.15)' AGENTS.md` = 1; `grep -c '^## Claude Code settings policy (Story 2.15)' packages/devbox/README.md` = 1.
- **Task 6 verification:** `diff .claude/settings.json packages/keel-templates/src/seeds/.claude/settings.json` exits 0 (byte-identical).
- **CR-stage verification:** the Acceptance Auditor reviewer (three-layer fan-out pattern per iter-271/iter-277/iter-294) verifies each AC maps to an artefact — an AC-to-artefact traceability matrix is the expected output.

No pre-commit gate additions at Story 2.15. The prek pipeline (Story 1.4 `.pre-commit-config.yaml` 3-hook setup + Story 1.5 commitlint 4th hook) continues to cover type-check + lint + format + commit-msg on the prose/metadata deltas; the new `.claude/settings.json` JSON is not in any TypeScript project so typecheck / lint / format don't apply (JSON formatting is not covered by the current prek config — Story 2.17 may or may not add a JSON-format gate in its close-out scope; out of Story 2.15 scope).

### Project Structure Notes

- **New files** (Story 2.15 creates):
  - `.claude/settings.json` — repo root; tracked; 13-entry deny + 6-entry allow.
  - `packages/keel-templates/src/seeds/.claude/settings.json` — byte-identical seed for Epic 15a Story 15a.4 consumer.
- **Modified files** (Story 2.15 edits):
  - `AGENTS.md` — append H3 `### Claude Code settings policy (Story 2.15)` after § Legacy-devbox branch retention H3 (before § Ralph loop H2). ~80-120 lines.
  - `CLAUDE.md` — update line 74 (replace one bullet with two siblings).
  - `packages/devbox/README.md` — append H2 `## Claude Code settings policy (Story 2.15)` after § Legacy-devbox branch retention H2 (before § cc-devbox upstream provenance H2). ~30-50 lines.
  - `packages/keel-templates/README.md` — append one bullet to the seeded-assets list (create list if absent).
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` — flip `2-15-…: backlog` → `ready-for-dev` at skill Step 6 (this is `/bmad-create-story`'s own change; noted for dev-story orient completeness).
- **Alignment with project structure:** the `.claude/` directory convention (Claude Code settings + hooks + skills + worktrees co-located) is Story 1.7 Claude Code baseline — Story 2.15 extends it, does not re-orient it. The `packages/keel-templates/src/seeds/` sub-tree convention is Story 15a.4 consumer contract — Story 2.15 is the first substrate producer of seed files into this sub-tree (prior seeds: `packages/keel-templates/src/PROMPT_*.template.md` per Story 3.3 forecast, not yet landed). Task 6 therefore establishes the `src/seeds/` directory scaffolding for downstream substrate-producer stories to extend (Story 2.16 + 2.17 MAY add hook scripts under `src/seeds/.claude/hooks/`).
- **No conflicts detected.** `.claude/settings.json` does not collide with the existing `.claude/settings.local.json` (different filename; Claude Code merges both per its precedence rules). `packages/keel-templates/src/seeds/` does not conflict with `src/index.ts` (separate subdirectory; the existing `index.ts` is a placeholder — `export {};` — awaiting substrate-produced seeds to consume + type-export).
- **Variance:** none. The approach aligns with every prior Story 2.x landing pattern (SC-15 sibling-append discipline; keel-templates consumer contract; NFR5a in-session barrier).

### References

- [Source: `_bmad-output/planning-artifacts/epics.md:1629-1668`] — Story 2.15 user story + 7 BDD-formatted ACs (verbatim source; Story file re-organises into the 13-deny + 6-allow + 4 AC-extension form for dev-agent tractability).
- [Source: `_bmad-output/planning-artifacts/prd.md:1075`] — NFR5a: Claude Code hook + settings deny-rule barrier substrate contract; pins minimum deny coverage (`.envrc`, `.env*`, `~/.ssh/**`, `~/.aws/credentials`, `~/.config/gh/**`, secret-dump idioms, Write-path). Story 2.15 AC 2 implements the Read + Bash axes of this minimum.
- [Source: `_bmad-output/planning-artifacts/prd.md:1076`] — NFR5b: hook + settings bypass-resistance contract (Story 2.17 forward-ref for git-layer backstop + S4 scan + N=3 halt).
- [Source: `_bmad-output/planning-artifacts/prd.md:832`] — PRD § Security-by-Default → Substrate-level controls "In-session Claude Code hook + settings deny-rule barrier" bullet; cross-refs NFR5a/5b + `INV-claude-hook-secret-denylist` sync-gate entry.
- [Source: `_bmad-output/planning-artifacts/prd.md:104`] — PRD § Execution Environment two-layer security-boundary narrative (devbox outer + Claude hook inner; NFR5a + NFR5b cross-links).
- [Source: `_bmad-output/planning-artifacts/prd.md:910`] — PRD § Invariants Coverage table "Claude Code hook + settings secret-access denylist" row (Story 2.16 + Story 2.17 forward-ref for manifest entry).
- [Source: `_bmad-output/planning-artifacts/epics.md:1165`] — Epic 2 § NFR5a implementation notes listing the Story 2.15 `.claude/settings.json` deny/allow axes + Story 2.16 hook-based axes.
- [Source: `_bmad-output/planning-artifacts/epics.md:1670-1720`] — Story 2.16 full AC set (forward-ref; dev-agent understands downstream scope).
- [Source: `_bmad-output/planning-artifacts/epics.md:1722-1773`] — Story 2.17 full AC set (forward-ref; Story 2.17's manifest entry + INVARIANTS.md H3 + sync-gate coverage).
- [Source: `_bmad-output/planning-artifacts/epics.md:6214-6230`] — Story 15a.4 (`packages/keel-templates/` consumer seeding) — Story 2.15 Task 6's contract counterpart.
- [Source: `docs/invariants/fork.md § Precedence`] — substrate-wins precedence model; AGENTS.md Task 3 honour-system bullets cite this.
- [Source: `docs/invariants/fork.md § Amendment-vs-fork decision tree`] — fork/amend/defer path for when a fork disagrees with substrate `.claude/settings.json` rules.
- [Source: `AGENTS.md:56-63`] — promotion rules (applies to every AI agent → `AGENTS.md`). Task 3 AGENTS.md H3 is the correct placement per these rules (Claude Code settings apply to every AI agent via the permission layer).
- [Source: `CLAUDE.md:74`] — existing `.claude/settings.local.json` bullet; Task 4 replaces with two-bullet expanded form.
- [Source: `_bmad-output/implementation-artifacts/2-14-legacy-devbox-branch-retention-policy.md`] — SC-15 sibling-append discipline; three-site-lockstep; bundled PATCH-close precedent for narrow-diff doc-heavy stories; iter-286 NOVEL LESSON forecast band; cumulative DEFER queue (47 pending at iter-294; absorbs Story 2.15 accruals into Story 2.17 SC-17 close-out).
- [Source: `_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md`] — live-smoke operator-workstation-deferred precedent; ACs requiring runtime exercise (Story 2.15 AC 5 deny-rule pointer surfacing) defer to operator smoke class, not unit gate.
- [Source: `packages/devbox/Dockerfile:121`] — `@anthropic-ai/claude-code@2.1.116` pinned install; Claude Code settings schema at this version.
- [Source: `.gitignore:20`] — existing `.claude/settings.local.json` ignore entry; Story 2.15 Task 2 verification-only (no edit).
- [Source: `packages/keel-invariants/src/invariants.manifest.ts`] — 34 manifest entries at Story 2.14 close; Story 2.15 does NOT land a new entry (Story 2.16 / 2.17 land `INV-claude-hook-secret-denylist` with expanded coverage).
- [Source: `INVARIANTS.md:20-152`] — invariants index shape; Story 2.15 does NOT append an H3 (Story 2.16 / 2.17 own the append).
- [Source: `_bmad-output/implementation-artifacts/deferred-work.md`] — cumulative Epic-2 DEFER queue sink; Story 2.15 DEFERs from pre-dev SM + CR append here; Story 2.17 SC-17 close-out reconciles.
- [Source: `_bmad-output/implementation-artifacts/sprint-status.yaml`] — Story 2.15 row `2-15-committed-claude-settings-json-with-deny-allow-permission-policies: backlog` → `ready-for-dev` at Step 6.

## Dev Agent Record

### Agent Model Used

_(Dev agent fills at `/bmad-dev-story` landing — e.g. `claude-opus-4-7`, `claude-sonnet-4-6`.)_

### Debug Log References

_(Dev agent fills — commit SHA pointers, log-file references under `.ralph/logs/<iter-id>/`, etc.)_

### Completion Notes List

_(Dev agent fills — one bullet per landed Task with the key decision/finding. SC-15 discipline notes, NFR5a coverage extension decisions (`~/.ssh/**`, `~/.aws/credentials` add-vs-defer), seed-lockstep verification result, AGENTS.md H3 length final count, any prek-hook interaction notes.)_

### File List

_(Dev agent fills — exhaustive list of files created + modified. Expected surface:)_

- `.claude/settings.json` (NEW)
- `packages/keel-templates/src/seeds/.claude/settings.json` (NEW)
- `AGENTS.md` (MODIFIED — H3 append)
- `CLAUDE.md` (MODIFIED — bullet update)
- `packages/devbox/README.md` (MODIFIED — H2 append)
- `packages/keel-templates/README.md` (MODIFIED — bullet append)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (MODIFIED — row flip, via `/bmad-create-story` Step 6)
- `_bmad-output/implementation-artifacts/2-15-committed-claude-settings-json-with-deny-allow-permission-policies.md` (THIS FILE — NEW, via `/bmad-create-story`)
