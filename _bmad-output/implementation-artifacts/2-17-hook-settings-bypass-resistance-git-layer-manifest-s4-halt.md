# Story 2.17: Hook + settings bypass-resistance (git-layer + manifest + S4 + halt)

Status: ready-for-dev

<!-- lifecycle: drafted (iter-309) → validated → atdd-scaffolded → in-dev → traced → sm-verified → done. FINAL story of Epic 2 (16/17 done pre-2.17; 17/17 at 2.17 `done`). Scope-inherent absorbs the 83-DEFER Epic-2 close-out backlog: 25 from Story 2.16 iter-308 CR (D-12..D-36) + 8 carry-forward from Story 2.15 CR (D-2/D-4/D-5/D-7/D-8/D-9/D-10/D-11 — D-1/D-3/D-6 already mitigated at Story 2.16 hook layer) + 3 SC-17 close-out candidates from Story 2.16 iter-306 trace (byte-identity diff lint + NFR5a minimum-entry gate + `hooks` key precondition lint) + 47 earlier carry-forward from Stories 1.8–1.16 + 2.1–2.14 (doc-drift / citation-lockstep / recipe polish — triage in Task 17). -->

## Story

As a substrate maintainer,
I want the Claude hook + `.claude/settings.json` barrier protected at the git-layer (invariants manifest + pre-merge sync-gate + S4 prompt-injection scan + Ralph halt threshold), not just in-session,
so that even if the in-session hook self-protection is somehow circumvented (novel Claude bypass, race condition, hook-script bug), the tampering cannot land in a commit or survive across iterations (NFR5b).

## Acceptance Criteria

**Given** the invariants manifest from Story 1.8,
**When** I inspect it,
**Then** entries exist for each bypass-surface file:

- `INV-claude-hook-secret-denylist` → `.claude/hooks/block-secret-access.sh`
- `INV-claude-settings-deny-rules` → `.claude/settings.json` (with an anchor-delimited region containing the non-toggle-able substrate deny rules)
- `INV-git-hooks-preservation` → `.git/hooks/*` (the prek-installed hooks; tracked indirectly via `packages/keel-invariants/src/prek-hook-manifest.ts` which enumerates the expected hook names and shebang patterns)

**And** each entry carries a `contentHash` scoped to the protected region (allowing fork-specific additions outside anchors without triggering drift).

**Given** Story 1.9's sync-gate,
**When** a PR modifies any of those files within protected regions,
**Then** the sync-gate runs on pre-merge and fails with `content-hash-mismatch` naming the specific invariant ID
**And** the PR cannot be merged without a source-level fork of `packages/keel-invariants/` (per Story 1.6 bypass-prevention pattern).

**Given** the S4 prompt-injection scan from Epic 4,
**When** a commit diff touches `.claude/settings*.json`, `.claude/hooks/**`, or `.git/hooks/**`,
**Then** the scan emits a structured finding (severity: `high`) in `security-evidence.json` under `scans.prompt_injection.findings[]`
**And** the commit is blocked at pre-commit per FR36 severity-threshold
**And** Ralph iteration halts with `reason: "SECURITY_CRITICAL"` (Epic 4 feeds the halt decision).

**Given** the Ralph iteration-level halt logic,
**When** in-session hook-self-protection blocks accumulate (rule-id `hook-self-protection`) at N=3 default per `.ralph/config.toml`,
**Then** the halt-logic writes `.ralph/halt` with `reason: "SECURITY_CRITICAL"` + bypass-attempt context
**And** the next iteration refuses to start until Tthew reviews `blocked-tool-calls.jsonl`.

**Given** a fork operator with a legitimate need to modify the denylist (e.g., removing a rule that causes false positives),
**When** they change `packages/keel-invariants/src/`-level source + update `invariants.manifest.ts` content-hash + update `INVARIANTS.md` anchor + author a signed conventional commit with `feat!:` + PR to `packages/keel-invariants/`,
**Then** the sync-gate passes because source + manifest + docs are in sync
**And** this is the ONLY path to weakening the substrate denylist (requires deliberate intent, git history, and human review).

**Given** Ralph is NOT permitted to author that modification under Epic 3's RS1 3-layer safe-set,
**When** Ralph's PreToolUse hook intercepts an attempted `packages/keel-invariants/src/` edit that touches denylist sources,
**Then** the edit is blocked (L1 install-boundary protection)
**And** only a human committer can authorise the change.

**Given** the `.claude/settings.local.json` user-override path,
**When** a PR attempts to commit `.claude/settings.local.json`,
**Then** the pre-commit gate rejects it (file is gitignored)
**And** the hook self-protection (Story 2.16) blocks in-session creation of the file via Write/Edit.

**Given** CI visibility into bypass attempts,
**When** hook-denial events land in `security-evidence.json`,
**Then** a dedicated dashboard panel (or nightly report — Epic 14 research corpus terrain) surfaces the event count trend
**And** an unusually high bypass-attempt rate is a leading signal of Claude-prompt-injection attack or Ralph regression worth investigating.

## Tasks / Subtasks

- [ ] **Task 1 — Extend `packages/keel-invariants/` manifest schema + sync-gate walker for region-scoped content-hashing (AC 1/2).**
  - [ ] 1.1 Extend `src/invariants.manifest.ts` `InvariantSchema` with an optional `hashScope` field:
    - Default (field absent): whole-file sha256 (back-compatible with all 35 existing entries).
    - `{ kind: 'jq-subtree', filter: string }`: pipe file through `jq -c <filter>` then sha256 the canonical output (for `.claude/settings.json` `.hooks.PreToolUse` sub-tree).
    - `{ kind: 'anchor-range', startMarker: string, endMarker: string }`: extract content between markers (inclusive), sha256 (reserved for future non-JSON files with HTML-comment anchors).
    - `{ kind: 'names-and-shebangs', enumeratorPath: string }`: walk `.git/hooks/` and hash `sort(hook-name + "\t" + first-line-of-file)` over names listed in `enumeratorPath`'s `EXPECTED_HOOKS` export (for `.git/hooks/*` preservation without hashing prek-generated byte-bodies that drift across prek upgrades).
  - [ ] 1.2 Extend `src/sync-gate.ts` walker: branch on `entry.hashScope.kind` before computing hash; fall through to whole-file when `hashScope` absent (back-compat invariant — all 35 existing entries continue RED/GREEN identically).
  - [ ] 1.3 Add `src/manifest-reader.ts` helpers: `computeSubtreeHash(filePath, jqFilter)`, `computeAnchorRangeHash(filePath, start, end)`, `computeNamesAndShebangsHash(gitHooksDir, expectedNames)`. Each returns lowercase 64-hex.
  - [ ] 1.4 Unit tests at `src/sync-gate.test.ts`: one per `hashScope.kind` × two outcomes (clean + drift) = 8 tests. Tests MUST NOT touch real `.claude/settings.json` or `.git/hooks/` — use tmpdir fixtures.
  - [ ] 1.5 Rebuild `pnpm --filter @keel/keel-invariants build`; run `pnpm keel-invariants:check-all`; confirm all 35 pre-existing entries still clean.

- [ ] **Task 2 — Introduce anchor convention in `.claude/settings.json` for substrate-owned `hooks.PreToolUse` region (AC 1).**
  - [ ] 2.1 Decision: **sub-tree hashing via `jq-subtree` hashScope.** Rationale — strict JSON forbids comments; adding a `$schema` key or synthetic `_substrate_anchor` key would perturb Claude Code's settings parser; the sub-tree-hash approach binds the manifest to `.hooks.PreToolUse` while leaving `.permissions` and `.hooks.PostToolUse` (fork-extension slot) free. Alternative rejected: reading `.claude/settings.json` whole-file would fail the sync-gate whenever a fork adjusts the allow-list.
  - [ ] 2.2 Register new manifest entry `INV-claude-settings-deny-rules` with `sourcePath: '.claude/settings.json'` + `hashScope: { kind: 'jq-subtree', filter: '.hooks.PreToolUse | sort_by(.matcher)' }`. Filter chosen to normalise matcher-ordering drift (Claude Code preserves authoring order but the normative contract is the set of matcher + hook entries).
  - [ ] 2.3 Document the fork-extension slot in `AGENTS.md` § Claude Code settings policy + `AGENTS.md` § Claude PreToolUse hooks (Story 2.16) + `packages/devbox/README.md` § Claude Code settings policy (Story 2.15): forks MAY add `.hooks.PostToolUse[]` / `.hooks.UserPromptSubmit[]` entries WITHOUT triggering the content-hash (only `.hooks.PreToolUse` is substrate-authoritative).
  - [ ] 2.4 Compute the initial `contentHash` for the current `.claude/settings.json` `.hooks.PreToolUse` sub-tree and paste into manifest. Record in Completion Notes.

- [ ] **Task 3 — Create `packages/keel-invariants/src/prek-hook-manifest.ts` enumerating prek-installed hooks (AC 1).**
  - [ ] 3.1 Author `prek-hook-manifest.ts` exporting `export const EXPECTED_HOOKS: readonly { name: string; shebangPattern: RegExp }[]` = at minimum `commit-msg` + `pre-commit` (derive exact set from current `.git/hooks/` contents — 479-byte `commit-msg` + 479-byte `pre-commit`). Shebang pattern is a conservative regex (e.g. `/^#!\/.*\/env\s+(python|sh|bash)/` or the exact prek-emitted shebang — verify by reading one of the installed hooks via `packages/keel-invariants/` subprocess at Task 3.1 time).
  - [ ] 3.2 Register new manifest entry `INV-git-hooks-preservation` with `sourcePath: 'packages/keel-invariants/src/prek-hook-manifest.ts'` + `hashScope: { kind: 'names-and-shebangs', enumeratorPath: 'packages/keel-invariants/src/prek-hook-manifest.ts' }`. The gate walker reads `EXPECTED_HOOKS`, iterates `.git/hooks/<name>` for each, extracts the first line, sha256 over `sort(name + "\t" + shebang-line)` joined by newlines. This captures the contract "the expected hook names exist AND their shebangs match the pattern" without binding to the byte-body (which drifts across prek upgrades + `.pre-commit-config.yaml` changes).
  - [ ] 3.3 Sibling contentHash: whole-file sha256 of `prek-hook-manifest.ts` itself is ALSO registered — this catches out-of-band edits to the enumeration file (e.g. a PR that removes `pre-commit` from `EXPECTED_HOOKS` to relax the preservation contract). Two manifest entries: `INV-git-hooks-preservation-enumeration` (file-level sha256 of `prek-hook-manifest.ts`) + `INV-git-hooks-preservation` (names+shebangs over `.git/hooks/` per 3.2).
  - [ ] 3.4 Unit tests at `prek-hook-manifest.test.ts` verifying at least `commit-msg` + `pre-commit` are present in `EXPECTED_HOOKS`.

- [ ] **Task 4 — Add three new manifest entries + reassign existing entry (AC 1/2).**
  - [ ] 4.1 Determine existing-entry reassignment policy. Per epics.md:1733 literal reading, `INV-claude-hook-secret-denylist` sourcePath becomes `.claude/hooks/block-secret-access.sh` (file-level sha256). Story 2.16 currently points it at `docs/invariants/claude-hook-denylist.md` (invariant doc). **Reconciliation decision: RETAIN the existing entry as `INV-claude-hook-secret-denylist-doc` (invariant-doc sha256) AND ADD a new entry `INV-claude-hook-secret-denylist` (file-level sha256 of the hook script).** Rationale: the invariant doc remains the human-readable contract and must be drift-protected; the script is the substrate enforcement layer and must ALSO be drift-protected. Both concerns are first-class. The renaming preserves the epics.md:1733 literal-reading ID for the hook-script binding while introducing the `-doc` suffix pattern for contract-documentation entries (sibling pattern available for future stories).
  - [ ] 4.2 Sibling rename needed for `docs/invariants/claude-hook-denylist.md` references in:
    - `INVARIANTS.md:138-142` Story 2.16 H3 bullet — keep ID as `INV-claude-hook-secret-denylist` referring to hook script; add sibling bullet `INV-claude-hook-secret-denylist-doc` referring to invariant doc. (Alternative: split the Story 2.16 H3 into two bullets under the same H3, preserving one-H3-per-story SC-15 sibling-append discipline.)
    - `packages/keel-invariants/src/invariants.manifest.ts:324` entry description + sourcePath + contentHash.
  - [ ] 4.3 Compute four new contentHashes:
    - `INV-claude-hook-secret-denylist-doc` (whole-file sha256 of `docs/invariants/claude-hook-denylist.md`) — should equal current `85f8a539c0850f1c52ed825c6a8a904d72c6d42c0c7a87eb9f14617bc51cd7e1` unless the invariant doc is amended at Task 14.
    - `INV-claude-hook-secret-denylist` (whole-file sha256 of `.claude/hooks/block-secret-access.sh` AFTER Task 10 amendments). Compute last in sequence.
    - `INV-claude-settings-deny-rules` (sub-tree hash of `.claude/settings.json` `.hooks.PreToolUse | sort_by(.matcher)` AFTER Task 10 amendments).
    - `INV-git-hooks-preservation-enumeration` (whole-file sha256 of `prek-hook-manifest.ts` after Task 3 creation) + `INV-git-hooks-preservation` (names+shebangs hash of `.git/hooks/` per EXPECTED_HOOKS).
  - [ ] 4.4 Manifest total after Story 2.17: **35 + 4 = 39 entries** (35 pre-existing + `INV-claude-hook-secret-denylist-doc` rename-split + `INV-claude-settings-deny-rules` + `INV-git-hooks-preservation-enumeration` + `INV-git-hooks-preservation`).
  - [ ] 4.5 Rebuild + sync-gate silent-success (`pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check-all`).

- [ ] **Task 5 — Author S4 prompt-injection scan rules at `packages/keel-invariants/src/prompt-injection-rules/` (AC 3).**
  - [ ] 5.1 Create directory `packages/keel-invariants/src/prompt-injection-rules/` if not present. Verify by Glob before creating.
  - [ ] 5.2 Author `prompt-injection-rules/hook-settings-tamper.ts` (or `.json` + loader — pick the per-Epic-4-tier convention at implementation time; Story 4.x design decision. If Epic 4 deliverable does not yet exist at Story 2.17 landing, author as TypeScript regex-rules exported from a typed module for Epic 4 to wire into the pre-commit scanner later).
  - [ ] 5.3 Rules authored (three per AC 3):
    - **Rule `s4-claude-hooks-tamper`** (severity: `high`): diff regex matching additions/modifications in paths `^\.claude/hooks/.*` OR `^\.claude/settings\.json$` OR `^\.claude/settings\.local\.json$`. Emits finding `{ rule_id, severity, path, line_range, diff_preview }`.
    - **Rule `s4-git-hooks-tamper`** (severity: `high`): diff regex matching `^\.git/hooks/.*` (rare — `.git/` is typically not in the diff; scan via git-hook inspection at pre-commit time, not diff-based; implementation subtlety noted).
    - **Rule `s4-skip-permissions-injection`** (severity: `high`): string match for `--dangerously-skip-permissions` in any newly-added/modified file OUTSIDE the known-safe paths (`packages/devbox/scripts/`, `.ralph/PROMPT_*.md`, `AGENTS.md` quoted regions, `CLAUDE.md` quoted regions, `docs/ralph.md`). Emits finding with severity `high`.
  - [ ] 5.4 Each rule emits a finding conforming to `scans.prompt_injection.findings[]` schema per architecture.md:202-220 (S3 security-evidence shape). Severity `high` → `scans.prompt_injection.severity_max = "high"` → `overall_severity_max = "high"` → `halt_required = true` if FR36 threshold at `high` (pinned via Epic 4 FR36 threshold default). The scan EMITS findings; Epic 4's FR36 threshold gate CONSUMES them and decides halt.
  - [ ] 5.5 Unit tests at `prompt-injection-rules/hook-settings-tamper.test.ts`: 3 positive matches (one per rule) + 2 negative (benign change to unrelated file, benign change to fork-extension slot `.hooks.PostToolUse`). ALL tests run at `pnpm --filter @keel/keel-invariants test`.
  - [ ] 5.6 Epic 4 forward-link: document in `docs/invariants/claude-hook-denylist.md` § S4 prompt-injection scan rules that these rules live at `packages/keel-invariants/src/prompt-injection-rules/` and are consumed by Epic 4's pre-commit scanner (FR40 / architecture.md:222); pre-commit wiring is **NOT** Story 2.17 scope (Epic 4 owns the scanner binary).

- [ ] **Task 6 — Pin Ralph halt-threshold + consumer contract for Epic 3 Story 3.7 (AC 4).**
  - [ ] 6.1 Verify `.ralph/config.toml` `[hooks].self_protection_halt_threshold = 3` (Story 2.16 pinned this). Amend if missing or wrong value. Document the key-name contract in `docs/invariants/claude-hook-denylist.md` § Halt-threshold-pin § Consumer contract.
  - [ ] 6.2 Amend invariant doc § Halt-threshold schema:
    - Consumer (Epic 3 Story 3.7) reads `.ralph/config.toml` `[hooks].self_protection_halt_threshold` (integer; default 3 if key absent; valid range `1..=100`; out-of-range or non-integer → consumer treats as default + emits warning to stderr — Story 2.16 D-23 absorption).
    - Per-iteration walker: read `${RALPH_BASE_DIR}/logs/<iter-id>/blocked-tool-calls.jsonl`; count lines where `rule_id == "hook-self-protection"`; if count ≥ threshold, write `${RALPH_BASE_DIR}/halt` with `{"reason":"SECURITY_CRITICAL","iteration_id":"<id>","rule_id":"hook-self-protection","block_count":<N>,"threshold":<T>}`. Halt reason MUST be `SECURITY_CRITICAL` per PRD FR14k closed enum (prd.md:959).
    - Halt schema: `reason: "SECURITY_CRITICAL" | "EPIC_DONE" | "ALL_EPICS_DONE" | "AWAIT_MERGE" | "BUDGET_EXHAUSTED" | "CI_BLOCKED" | "RALPH_STAGE_REGRESSION"` per FR14k. Epic 3 MUST NOT invent a new reason.
  - [ ] 6.3 Task 6 does NOT implement the halt-write (that is Story 3.7 scope). It pins the CONTRACT so Story 3.7 is unambiguous. Add a `docs/invariants/ralph-execute.md` § Halt-threshold consumer reference pointing at the Story 2.17 pinning — or, if `ralph-execute.md` does not exist at Story 2.17 landing, note as a forward-ref in `docs/invariants/claude-hook-denylist.md` for Story 3.7 to pull.

- [ ] **Task 7 — Add L1 install-boundary hook rule (AC 6).**
  - [ ] 7.1 Extend `.claude/hooks/block-secret-access.sh` hook-self-protection section with a NEW rule matching Edit/Write on `packages/keel-invariants/src/` paths that touch denylist-sources. Protected subset at 1.0:
    - `packages/keel-invariants/src/invariants.manifest.ts` (the manifest itself — any Ralph-authored change denied)
    - `packages/keel-invariants/src/sync-gate.ts` (the enforcement)
    - `packages/keel-invariants/src/manifest-reader.ts` (hash helpers)
    - `packages/keel-invariants/src/prompt-injection-rules/**` (S4 rules)
    - `packages/keel-invariants/src/prek-hook-manifest.ts` (Story 2.17 NEW)
  - [ ] 7.2 New rule-id `install-boundary-protection` (third closed-enum rule-id alongside `secret-access-denylist` + `hook-self-protection`). Update invariant doc § Rule-IDs; update `docs/invariants/claude-hook-denylist.md` § Decision shape to enumerate three rule-IDs.
  - [ ] 7.3 Bash bypass coverage per D-14 / D-15 / D-16 discipline: deny `rm`, `mv`, `chmod`, `tee`, `sed -i`, `echo >`, `cp`, `truncate`, `dd`, `find -delete` against the protected paths + wrapper bypasses (`bash -c`, `sudo`, `/usr/bin/*`, `\cmd`, `xargs`, `eval`, `python -c`, `node -e`, `perl -e`). AC 6 explicitly cites Story 1.6 bypass-prevention pattern.
  - [ ] 7.4 Self-protection recursion: the NEW hook rule ALSO denies edits to `.claude/hooks/block-secret-access.sh` itself (already covered by Story 2.16 hook-self-protection pattern — verify + document the recursion at invariant doc § L1 install-boundary § Self-recursion).
  - [ ] 7.5 Impl-time smoke (bash fixture executing hook against mock payloads, per Story 2.16 § Task 1 12-smoke posture): add 5 smokes — one per protected path prefix × (allow-case + deny-case). ALL smokes must exit 0 for allow-cases (hook approves) + exit 2 for deny-cases (hook blocks) per Claude Code PreToolUse contract.
  - [ ] 7.6 Pre-install discipline (iter-305 NOVEL LESSON): run `bash -n .claude/hooks/block-secret-access.sh && dash -n .claude/hooks/block-secret-access.sh` BEFORE re-registering. If syntax error, Monitor escape-hatch (per iter-305 incident recovery: `uv run python -c '<parsing script>'` bypasses the hooked tool surface).

- [ ] **Task 8 — `.claude/settings.local.json` pre-commit rejection + hook self-protection (AC 7).**
  - [ ] 8.1 Verify `.claude/settings.local.json` is gitignored — check `.gitignore:20` (Story 2.15 Dev Notes cite this line). If missing, add the pattern.
  - [ ] 8.2 Extend Story 1.7's `check-no-committed-dotfiles.ts` (or equivalent pre-commit invariant: find the actual script via `Grep '.envrc' packages/keel-invariants/src/`) to ALSO refuse `.claude/settings.local.json` additions. Same pattern as the existing `.envrc` + `.secrets` refusal. Add one test fixture.
  - [ ] 8.3 Verify Story 2.16 hook already covers in-session creation: `.claude/settings.json` pattern matches `.claude/settings*.json` glob in Edit/Write path; confirm `.local` suffix is covered. If the Story 2.16 regex is `.claude/settings\.json$` (exact), amend to `.claude/settings(\.local)?\.json$` OR `.claude/settings.json*` glob. Empirical test: send a mock Write payload with `file_path: ".claude/settings.local.json"` and confirm `decision: block`, `reason: "hook-self-protection"`.
  - [ ] 8.4 Sibling coverage — enumeration of settings file patterns to block in-session: `.claude/settings.json`, `.claude/settings.local.json`, `.claude/settings.*.json` (forward-compat reserved for future Claude Code variants). Document in invariant doc § Hook-self-protection § Settings-file patterns.

- [ ] **Task 9 — CI visibility contract stub for Epic 14 (AC 8).**
  - [ ] 9.1 Add to `docs/invariants/claude-hook-denylist.md` § CI visibility contract (forward-link to Epic 14): "Hook-denial events land in `security-evidence.json` under `scans.hook_denials[]` (Epic 4 consumer; pinned at Story 2.16 AC 8). An Epic 14 dashboard panel (or nightly report — research corpus terrain) surfaces event-count trend. Unusually high bypass-attempt rate is a leading signal of Claude-prompt-injection attack or Ralph regression."
  - [ ] 9.2 Pin event-count trend contract: panel/report aggregates `hook_denials[]` by `iteration_id` over a rolling window (e.g. last 100 iterations). Baseline at 1.0 is "zero hook-denial events per iteration in healthy Ralph operation". Any non-zero count is a human-review trigger.
  - [ ] 9.3 Epic 14 ownership: Story 2.17 does NOT implement the dashboard; it PINS the CONTRACT so Epic 14 is unambiguous. No code delivered at Task 9.

- [ ] **Task 10 — Absorb Story 2.16 iter-308 CR DEFERs D-12..D-36 + Story 2.15 carry-forward D-2/D-4/D-5/D-7/D-8/D-9/D-10/D-11 at hook + settings + sync-gate layers.**
  - [ ] 10.1 Hook-layer rule-expansion (absorbing D-12..D-36):
    - **D-12** (cat-only bypass): extend Bash reader patterns to `(cat|less|tail|head|bat|xxd|od|strings|grep|awk|sed|cp|dd)*<secret-path>*` via alternation. Also `(node|python|python3|perl|ruby|php) -e *<secret-path>*` interpreted-stdin readers. Anchor with word-boundary to avoid D-35 false-positives.
    - **D-13** (`env|export|set` exact-match): change `env)` exact case to `env*)` suffix-glob; same for `export*` / `set*`. Deny `env | ...`, `env -0`, `export -p`, `set -o posix`.
    - **D-14** (hook-self-protection coverage asymmetry): canonicalise — for each Bash mutation verb, deny across ALL three target classes (`.claude/settings*.json`, `.claude/hooks/**`, `.git/hooks/**`). Verbs: `rm`, `mv`, `chmod`, `tee`, `sed -i`, `echo >`, `cp`, `truncate`, `dd`, `find -delete`.
    - **D-15** (wrapper-command bypass): add denial of wrapper prefixes before Bash verbs — `bash -c`, `sh -c`, `sudo`, `/usr/bin/`, `/bin/`, `\<verb>`, `env VAR=1`, `xargs`, `eval`, interpreted-stdin. Known limitation: denylist-over-allowlist remains design-level risk; document as "defense-in-depth, not sole defense" — Story 2.17 sibling content-hash + S4 scan layers close the residual gap.
    - **D-16** (`--no-verify` regex narrow): broaden from `^git[[:space:]]+(commit|push)` to `^(([A-Z_]+=\S+[[:space:]]+)*)?(/usr/bin/|/bin/)?git([[:space:]]+-[cCp]\s+\S+)*[[:space:]]+(commit|push|merge|rebase|am|pull|cherry-pick|revert)[[:space:]].*--no-verify`. Also deny `bash -c '* git * --no-verify *'` wrapper.
    - **D-17** (Read/Bash exemption asymmetry): canonicalise — schema-companion exemption (`*.envrc.example`, `*.secrets.example`, `*.env.example`) applies to Read AND Bash `cat` readers. Glob patterns updated to carve out `*.example` paths.
    - **D-18** (Glob over-block): refine Glob patterns to exclude `*.example`, `docs/*env*`, `packages/**/.environment/**` false-positive directories. Pattern: `**/.env[!a-zA-Z]*` (excludes `.envrc.example` via negated char class).
    - **D-19** (case-sensitivity bypass): add `shopt -s nocasematch` at hook start (ONLY for pattern-matching section; restore before JSON emit). Matches `.ENV`, `.Envrc`, `.SECRETS`.
    - **D-20** (Glob `path` arg): read `.path` from tool JSON (previously only `.pattern` was read). If `path` starts with `/home/dev/.claude/` or `/home/dev/.config/gh/`, deny.
    - **D-21** (JSONL printf injection): switch `printf '%s' "$payload" | jq` pipeline to `jq -n --arg ts "$timestamp" --arg iter "$RALPH_ITER_ID" --arg tool "$tool_name" --arg args "$args_redacted" --arg rule "$rule_id" --arg match "$matched" '{timestamp: $ts, iteration_id: $iter, tool: $tool, args_redacted: $args, rule_id: $rule, match: $match}'`. Eliminates injection via `"`/`\`/newline in `iter` or `match`.
    - **D-22** (symlink + exemption bypass): resolve symlinks via `readlink -f` before applying exemption check. If resolved path points into `/home/dev/.claude/` or `/home/dev/.config/gh/`, deny regardless of file-name suffix.
    - **D-23** (config.toml threshold validator): document in `.ralph/config.toml` header comment: "`self_protection_halt_threshold`: integer 1–100; values outside this range treated as default 3 + stderr warning". Consumer-side validation lives in Epic 3 Story 3.7 (forward-ref). Story 2.17 pins the CONTRACT in invariant doc § Halt-threshold schema.
    - **D-24** (JSONL log-append silent drop): remove `2>/dev/null || true` from the `jq ... >> blocked-tool-calls.jsonl` line. If append fails, allow the failure to surface to stderr; hook still emits `decision: block` on stdout. Alternative: `|| { echo "[block-secret-access] JSONL write failed: $?" >&2; }` — emits audit trail to stderr but does NOT break the block decision. Pick the latter to preserve the block contract.
    - **D-25** (MultiEdit + NotebookEdit matchers): add two matchers to `.claude/settings.json` `hooks.PreToolUse` — `{ matcher: "MultiEdit", hooks: [...] }` + `{ matcher: "NotebookEdit", hooks: [...] }`. Both invoke the same `.claude/hooks/block-secret-access.sh`. Sub-tree hash in Task 2.2 absorbs the new matchers naturally.
    - **D-26** (fork-hook cwd dependence): replace `.claude/hooks/block-secret-access.fork.sh` with `"$(dirname "${BASH_SOURCE[0]}")/block-secret-access.fork.sh"`. Anchor to the substrate hook's own directory.
    - **D-27** (fork-hook exit-code contract): parse fork hook's stdout as JSON; validate `{decision, reason, match}` shape; if fork hook emits invalid JSON OR non-zero exit, substrate hook FAILS CLOSED (emits its own `{"decision":"block","reason":"fork-hook-contract-violation","match":""}` rather than blindly propagating).
    - **D-28** (tilde expansion bypass): add tilde-form patterns to Read + Bash `cat` denylists — `~/.claude/*`, `~/.config/gh/*`, `~/.ssh/*`. Hook sees pre-expansion text; tilde-form is Claude Code convention in some agent paths.
    - **D-29** (manifest contentHash scope): ABSORBED by Task 4 (the whole Story 2.17 invariant — 3 sub-tree/names-and-shebangs/file-level hashes cover hook script + settings.json hooks region + git hooks).
    - **D-30** (Read-path secret-file gap): add deny patterns for `id_rsa`, `id_ed25519`, `id_ecdsa`, `*.pem`, `*.key`, `credentials.json`, `.pgpass`, `.npmrc` (auth-token variant), `.pypirc`, `*.p12`, `*.crt`, `*.pfx`. Sibling to Story 2.15 D-10.
    - **D-31** (/proc surface narrow): expand deny patterns — `/proc/*/cmdline`, `/proc/*/status`, `/proc/*/auxv`, `/proc/kcore`, `/proc/kmem`, `/proc/self/*`, `/proc/[0-9]*/*`.
    - **D-32** (config.toml key-name contract): add `.ralph/config.toml` parse-time assertion in Epic 3 Story 3.7 (forward-ref). Story 2.17 pins the key-name `[hooks].self_protection_halt_threshold` in invariant doc § Halt-threshold schema with a warning that rename requires AMEND path.
    - **D-33** (Grep content-search): scope carve-out — document in invariant doc § Limitations that Grep content-search (`Grep 'SECRET_KEY=' /workspace/**`) is NOT covered by the filename-substring denylist. Claude Code's Grep tool reports pattern + path + optional output-mode; content-based defense would require pattern-analysis heuristics. DEFERRED to Epic 4 S4 scanner tier — document forward-link.
    - **D-34** (jq silent fail-open): wrap jq calls with `jq -r '...' || { echo "[block-secret-access] jq parse failed" >&2; echo 'unknown'; }`. Default to `unknown` tool name + proceed with full denylist scan (fail-secure: unknown tool gets full surface scan instead of early-approve).
    - **D-35** (unanchored case-glob false-positives): anchor patterns with word-boundary — `rm)|rm[[:space:]]|rm$` instead of bare `rm*`. Applies across all Bash verbs.
    - **D-36** (seed exec-bit preservation): document in `docs/invariants/claude-hook-denylist.md` § Fresh-fork seed contract that `create-keel-app` (Epic 15a Story 15a.4) MUST `tar --preserve-permissions` when materialising the seed hook (otherwise the hook is unexecutable in the fresh fork). Epic 15a implements; Story 2.17 pins the contract.
  - [ ] 10.2 Story 2.15 carry-forward (D-2/D-4/D-5/D-7/D-8/D-9/D-10/D-11):
    - **D-2** (Bash `cat **/.env*` misses bare-root `cat .env`): permissions-layer patch to `.claude/settings.json` `permissions.deny` — add `Bash(cat .env)` + `Bash(cat .env*)` + `Bash(cat .env.*)`. Absorbed at hook layer already via D-12 expansion (`cat*.env|cat*.env.*`).
    - **D-4** (allow-rule glob form inconsistency): canonicalise `permissions.allow` to `Bash(<verb> *)` form consistently — amend to `Bash(git diff *)` (add space) + `Bash(git log *)` (add space) + `Bash(git status)` stays exact.
    - **D-5** (`Bash(env:*)` non-functional): remove `Bash(env:*)` from permissions.deny (colon-literal vs space-argv); superseded by hook-layer D-13 (`env*` suffix glob).
    - **D-7** (`Bash(ls *)` metadata leak): add invariant doc § Limitations note: `ls -la /home/dev/.claude/` leaks directory metadata (mtime, owner, file sizes); Bash allow-rule `Bash(ls *)` cannot exclude specific paths without permissions-layer negation syntax (not supported by Claude Code at 2.1.116). Residual — accept at 1.0. Future: if Claude Code adds negative-allow syntax, Story 2.17 successor can tighten.
    - **D-8** (`Bash(git log*)` allows `git log -p --all`): remove `Bash(git log*)` from `.claude/settings.json` permissions.allow. Replace with explicit subset: `Bash(git log)`, `Bash(git log --oneline)`, `Bash(git log --oneline *)`, `Bash(git log -n *)`. Common `git log` invocations covered; `-p` / `--patch` excluded.
    - **D-9** (README NFR5a gap doc symmetry): add `packages/devbox/README.md` § Claude Code settings policy (Story 2.15) paragraph mirroring `AGENTS.md:222` on `~/.ssh/**` + `~/.aws/credentials` substrate-internal no-op rationale.
    - **D-10** (secret-file patterns): addressed at hook layer via D-30 expansion. Permissions-layer patch parallel: add `Read(id_rsa)`, `Read(id_ed25519)`, `Read(*.pem)`, `Read(*.key)`, `Read(credentials.json)`, `Read(.pgpass)`, `Read(.npmrc)`, `Read(*.p12)`, `Read(*.crt)`, `Read(*.pfx)` to `.claude/settings.json` permissions.deny.
    - **D-11** (AGENTS.md:199 "Amendment-vs-fork decision" missing "tree"): citation-lockstep fix — find + replace `Amendment-vs-fork decision` → `Amendment-vs-fork decision tree` across all docs referencing the `docs/invariants/fork.md` anchor. Sibling to Story 2.13/2.14 citation-lockstep DEFERs.

- [ ] **Task 11 — Absorb Story 2.16 iter-306 trace SC-17 close-out candidates D-7 / D-8 / D-9.**
  - [ ] 11.1 **D-7 (substrate-to-seed byte-identity diff lint):** author `packages/keel-invariants/src/check-seed-byte-identity.ts` — walks `packages/keel-templates/src/seeds/.claude/` and asserts each file matches its substrate counterpart byte-for-byte. Pre-commit wiring in `.pre-commit-config.yaml` via `pnpm keel-invariants:seed-byte-identity`. Unit test at `check-seed-byte-identity.test.ts`. SUBSUMED by Story 2.17's sync-gate content-hash approach for substrate files — seed content-hashes can be registered as manifest entries (`INV-claude-settings-seed` + `INV-claude-hook-secret-denylist-seed`) pointing at seed files with the same contentHash as substrate. Pick whichever lint is simpler; prefer manifest-entry approach to reuse Story 1.9 infrastructure.
  - [ ] 11.2 **D-8 (NFR5a deny-list minimum-entry gate):** author `packages/keel-invariants/src/check-nfr5a-minimum.ts` asserting `.claude/settings.json` `.permissions.deny` contains ≥13 entries AND `.permissions.allow` contains ≥6 entries (lower bounds per Story 2.15 AC 2). Pre-commit wiring via `pnpm keel-invariants:nfr5a-minimum`. Complementary to sub-tree contentHash (which catches EDITS to substrate-authoritative sub-tree; minimum-entry gate catches REMOVALS from forks).
  - [ ] 11.3 **D-9 (`hooks` key precondition preservation lint):** subsumed by `INV-claude-settings-deny-rules` contentHash via Task 2 (sub-tree hash of `.hooks.PreToolUse | sort_by(.matcher)` guarantees `.hooks.PreToolUse` key exists AND its substrate matchers are preserved — removal or mutation flips the hash). No separate lint needed.

- [ ] **Task 12 — Pre-install `bash -n` + `dash -n` discipline codification (iter-305 NOVEL LESSON).**
  - [ ] 12.1 Add pre-commit invariant `check-claude-hook-syntax.ts` that runs `bash -n .claude/hooks/*.sh && dash -n .claude/hooks/*.sh` against every file in `.claude/hooks/`. Fails pre-commit on syntax error. Pre-commit wiring via `pnpm keel-invariants:claude-hook-syntax`.
  - [ ] 12.2 Document in invariant doc § Pre-install discipline: "Claude Code 2.1.116 empirically treats `hooks.PreToolUse` block-parse-failure as block-with-stdout-suppression (contrary to upstream docs suggesting 'fail-open'). A syntax-error in the registered hook bricks Bash/Read/Edit/Write/Grep/Glob tool surfaces. Recovery requires a Monitor-based Python escape-hatch. Pre-install `bash -n` + `dash -n` discipline is MANDATORY before committing any `.claude/hooks/*.sh` change." Reference iter-305 incident.
  - [ ] 12.3 Unit test at `check-claude-hook-syntax.test.ts` with a deliberately-malformed fixture + assertion that pre-commit fails.

- [ ] **Task 13 — Sibling-append docs updates across AGENTS.md / CLAUDE.md / INVARIANTS.md / packages/devbox/README.md.**
  - [ ] 13.1 **AGENTS.md:** append new H3 `### Hook + settings bypass-resistance (Story 2.17)` AFTER the Story 2.16 H3 (`AGENTS.md:225`). SC-15 sibling-append discipline. Content:
    - Git-layer backstop: INV-claude-settings-deny-rules + INV-claude-hook-secret-denylist + INV-git-hooks-preservation + INV-git-hooks-preservation-enumeration + INV-claude-hook-secret-denylist-doc — all covered by Story 1.9 sync-gate.
    - S4 prompt-injection scan rules at `packages/keel-invariants/src/prompt-injection-rules/` (Epic 4 consumer).
    - Halt-threshold pin: N=3 hook-self-protection blocks → `SECURITY_CRITICAL` halt (Epic 3 Story 3.7 consumer).
    - L1 install-boundary protection: third closed-enum rule-id `install-boundary-protection` denies Ralph-authored edits to `packages/keel-invariants/src/**`.
    - `.claude/settings.local.json` pre-commit rejection + hook self-protection extension.
    - Fork-extension honour: forks MAY add `.hooks.PostToolUse[]` + allow-list entries + `.claude/hooks/block-secret-access.fork.sh`; MAY NOT modify substrate-authoritative sub-tree.
    - Epic 14 forward-link: CI visibility dashboard panel trend-of-hook-denial-events.
    - Pre-install `bash -n` + `dash -n` discipline (iter-305 NOVEL LESSON).
    - Cross-ref: § Claude Code settings policy (Story 2.15) + § Claude PreToolUse hooks (Story 2.16) + `INV-claude-settings-deny-rules` + `INV-claude-hook-secret-denylist` + `INV-git-hooks-preservation`.
  - [ ] 13.2 **CLAUDE.md:** append a new sibling bullet after the existing Story 2.16 bullet (currently at `CLAUDE.md:76`). Pattern follows Story 2.16 bullet.
  - [ ] 13.3 **INVARIANTS.md:** append new H3 `### Hook + settings bypass-resistance (Story 2.17)` AFTER the Story 2.16 H3 (`:138-142`). Four new bullets: `INV-claude-settings-deny-rules`, `INV-git-hooks-preservation`, `INV-git-hooks-preservation-enumeration`, `INV-claude-hook-secret-denylist-doc`. The existing `INV-claude-hook-secret-denylist` bullet stays under Story 2.16 H3 (repoint its description — sourcePath updated to hook script; cite change in Story 2.17 H3 bullet "... extends Story 2.16's `INV-claude-hook-secret-denylist` sourcePath from the invariant doc to the hook script itself").
  - [ ] 13.4 **packages/devbox/README.md:** append new H2 `## Hook + settings bypass-resistance (Story 2.17)` AFTER the Story 2.16 H2. Operator-facing walkthrough of the git-layer backstop + fork-extension path + CI visibility forward-link.
  - [ ] 13.5 **docs/invariants/claude-hook-denylist.md:** AMEND existing Story 2.16 invariant doc to:
    - Add § Git-layer bypass-resistance describing the 3-entry contentHash contract.
    - Add § S4 prompt-injection scan rules describing the three rules + severity.
    - Add § L1 install-boundary rule describing the third rule-id + protected paths.
    - Add § Halt-threshold schema describing the config.toml key + consumer contract + fail-closed range.
    - Add § Limitations enumerating D-33 (Grep content-search), D-7/D-8/D-15 residual gaps.
    - Add § Pre-install discipline (iter-305 NOVEL LESSON) + § Fresh-fork seed contract (D-36).
    - Update SHA will differ after amendment — lockstep with manifest contentHash for `INV-claude-hook-secret-denylist-doc`.

- [ ] **Task 14 — Seed lockstep (substrate ↔ seed byte-identity).**
  - [ ] 14.1 After Task 10 (hook script edits) + Task 2 (settings sub-tree expansion) land, copy substrate `.claude/hooks/block-secret-access.sh` → `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh` verbatim. Diff must be empty.
  - [ ] 14.2 After Task 2 + Task 10.2 (D-2/D-4/D-5/D-8/D-10/D-11/D-25 permissions.allow/deny edits) land, copy substrate `.claude/settings.json` → `packages/keel-templates/src/seeds/.claude/settings.json` verbatim. Diff must be empty.
  - [ ] 14.3 Run `pnpm keel-invariants:seed-byte-identity` (if Task 11.1 lands) — must pass. If Task 11.1 chose the manifest-entry approach instead of standalone lint, the sync-gate sub-tree + file-level hashes cover byte-identity.
  - [ ] 14.4 Amend `packages/keel-templates/README.md` seeded-assets bullet to include "Story 2.15+2.16+2.17" (the existing bullet reads "Story 2.15+2.16" from Story 2.16 close).

- [ ] **Task 15 — Smokes + sync-gate + pre-commit end-to-end verification.**
  - [ ] 15.1 Hook impl-time smokes (fixture-based, per Story 2.16 Task 1 posture): expand from 14 smokes to cover new rules — D-12..D-36 positive + negative cases, L1 install-boundary (Task 7), Settings.local.json (Task 8.3). Target: ≥25 impl-time smokes all GREEN.
  - [ ] 15.2 Sync-gate silent-success (`pnpm keel-invariants:check-all` — reads 39 manifest entries, 4 new `hashScope` entries exercise the new walker branches, all clean).
  - [ ] 15.3 Pre-commit local run: `pre-commit run --all-files` — NFR5a minimum-entry gate passes, seed-byte-identity passes, claude-hook-syntax passes, no-committed-dotfiles passes, S4 scan unit-tests pass.
  - [ ] 15.4 `pnpm --filter @keel/keel-invariants test` — all unit tests pass (sync-gate x8, prek-hook-manifest x1, prompt-injection-rules x5, check-nfr5a-minimum x2, check-claude-hook-syntax x2).
  - [ ] 15.5 Document each smoke + test in Completion Notes with count + summary. No live smokes against DinD backend B (operator-workstation-deferred per Story 2.5 posture).

- [ ] **Task 16 — SC-17 Epic-2 close-out audit (absorb remaining applicable DEFERs; document carry-forwards).**
  - [ ] 16.1 Re-read `deferred-work.md` in full. Audit the 47 Epic-1 (Stories 1.8-1.16) + early-Epic-2 (Stories 2.1-2.14) DEFERs. Categorise each:
    - **Absorb-in-2.17:** any DEFER whose fix is a one-line citation-lockstep + touches files already edited by Story 2.17 (AGENTS.md, CLAUDE.md, INVARIANTS.md, packages/devbox/README.md, docs/invariants/*). Apply inline.
    - **Defer-to-Epic-3+:** any DEFER requiring substrate code change to files OUTSIDE Story 2.17's touch set. Keep in `deferred-work.md`; annotate with reason `(SC-17 triage 2026-04-24 / iter-309: out-of-touch-set; defer to <next Story owning that file>)`.
    - **Obsolete:** any DEFER whose context has moved (e.g. the file was renamed/deleted in a subsequent story). Remove from `deferred-work.md` with rationale `(obsolete: <what happened>)`.
  - [ ] 16.2 Target absorption count: 15-25 DEFERs absorbed in this task (citation-lockstep class). Remainder carry forward.
  - [ ] 16.3 Update `deferred-work.md` § Story 2.17 section: list absorbed + deferred + obsolete with final counts. Record cumulative Epic-2 DEFER balance at close: **target < 30 remaining** (from 83 entry count; 36 substrate-absorbed via Tasks 10-11 + 15-25 polish-absorbed via Task 16 + 0-N carry-forward).
  - [ ] 16.4 Close with a commit note: "Epic 2 SC-17 close-out: absorbed <N> substrate + <M> polish + carry-forward <K>; Epic 2 DEFER queue at close = <K>".

- [ ] **Task 17 — Story file completion + sprint-status flip.**
  - [ ] 17.1 Fill in Dev Agent Record § Completion Notes with per-AC evidence + per-Task completion + File List + Change Log row.
  - [ ] 17.2 Update sprint-status.yaml: `2-17-hook-settings-bypass-resistance-git-layer-manifest-s4-halt: review` (not `done` — dev-story emits `review` status per Story Lifecycle Decision Matrix; `done` flips at CR landing).
  - [ ] 17.3 Do NOT mark Story 2.17 `done` here. Subsequent Ralph iterations run `/bmad-testarch-atdd` (validated → atdd-scaffolded) → `/bmad-testarch-trace` (in-dev → traced) → `/bmad-create-story (args: "review")` (traced → sm-verified) → `/bmad-code-review (args: "2")` (sm-verified → done) per Story Lifecycle Decision Matrix.

## Dev Notes

### Scope boundaries (what Story 2.17 OWNS vs. DEFERS)

1. **OWNS — Manifest + sync-gate infrastructure:** schema extension for `hashScope` (sub-tree / anchor-range / names-and-shebangs); sync-gate walker multi-mode branching; back-compat preservation of all 35 pre-existing entries at whole-file mode. (Task 1.)
2. **OWNS — Three-entry bypass-resistance manifest contract per AC 1/2:** `INV-claude-hook-secret-denylist` (hook script), `INV-claude-settings-deny-rules` (settings sub-tree), `INV-git-hooks-preservation` (.git/hooks via names+shebangs). Plus `INV-git-hooks-preservation-enumeration` (enumeration-file protection) + `INV-claude-hook-secret-denylist-doc` (invariant-doc protection; the former `INV-claude-hook-secret-denylist` sourcePath re-targeted via split). Net: +4 manifest entries; 35 → 39. (Tasks 2, 3, 4.)
3. **OWNS — Pre-merge sync-gate integration:** Story 1.9's `sync-gate.ts` walker extended; all five new entries drift-tested. (Task 1.2, Task 15.2.)
4. **OWNS — S4 prompt-injection rule authoring:** three rules (`s4-claude-hooks-tamper`, `s4-git-hooks-tamper`, `s4-skip-permissions-injection`) at `packages/keel-invariants/src/prompt-injection-rules/` emitting findings to `scans.prompt_injection.findings[]`. DEFERS — the Epic 4 S4 scanner BINARY + pre-commit wiring is Epic 4 Story 4.x scope. (Task 5.)
5. **OWNS — Halt-threshold consumer contract pin:** N=3 `hook-self-protection` blocks; `.ralph/config.toml [hooks].self_protection_halt_threshold`; halt-write JSON schema; reason enum bounded to FR14k closed-set. DEFERS — the actual halt-write code at Epic 3 Story 3.7. (Task 6.)
6. **OWNS — L1 install-boundary rule:** third closed-enum rule-id `install-boundary-protection`; protected `packages/keel-invariants/src/` files. (Task 7.)
7. **OWNS — `.claude/settings.local.json` pre-commit rejection + hook self-protection extension:** `check-no-committed-dotfiles.ts` extension + `.claude/settings(\.local)?\.json` pattern in hook. (Task 8.)
8. **OWNS — Three Story 2.16 trace SC-17 close-out candidates D-7/D-8/D-9:** substrate-to-seed byte-identity (via manifest entries), NFR5a minimum-entry gate, `hooks` key precondition (subsumed by sub-tree hash). (Task 11.)
9. **OWNS — Pre-install `bash -n` + `dash -n` discipline codification:** pre-commit invariant gate (iter-305 NOVEL LESSON). (Task 12.)
10. **OWNS — Epic-2 close-out SC-17 polish-pass absorption:** 15-25 citation-lockstep / doc-drift DEFERs from Stories 1.8-1.16 + 2.1-2.14 backlog absorbed inline; remainder carry forward with rationale. (Task 16.)
11. **DEFERS — Epic 3 Story 3.7:** halt-write implementation (reads threshold, counts JSONL, writes halt sentinel).
12. **DEFERS — Epic 4 Story 4.x:** S4 scanner binary + pre-commit wiring to consume the authored rules.
13. **DEFERS — Epic 4 Story 4.13:** `scans.hook_denials[]` → `scans.prompt_injection.findings[]` consumer (Story 2.16 AC 8).
14. **DEFERS — Epic 14:** CI visibility dashboard panel implementation (Task 9 pins the contract; Epic 14 builds the panel).
15. **DEFERS — Epic 15a Story 15a.4:** `create-keel-app --preserve-permissions` for seed hook exec-bit (D-36).

### Substrate ground-truth citations

**Hook script ground-truth:**
- `.claude/hooks/block-secret-access.sh` — 94 lines at iter-309 baseline, mode 0755. Line ranges: `:4-16` stdin+jq parse; `:17-32` log_block/block functions (D-21/D-24 absorb here); `:33-39` Read exemption (D-17 asymmetry root); `:40-61` hook-self-protection rules (D-14/D-16 absorb here); `:62-88` secret-access-denylist rules (D-12/D-13/D-17/D-18/D-20/D-30/D-31 absorb here); `:89-92` fork-hook invocation (D-26/D-27 absorb here); `:93-94` default approve.

**Settings ground-truth:**
- `.claude/settings.json` — 67 lines at iter-309 baseline. Structure: `:3-17` permissions.deny (13 entries); `:18-25` permissions.allow (6 entries); `:27-66` hooks.PreToolUse (6 matchers from Story 2.16). Story 2.17 adds 2 matchers (D-25 MultiEdit + NotebookEdit) + edits allow-rule globs (D-4/D-5/D-8) + adds secret-file patterns (D-10/D-30).

**Manifest ground-truth:**
- `packages/keel-invariants/src/invariants.manifest.ts` — 333 lines at iter-309 baseline. Schema at `:3-46` with `{id, description, sourcePath, contentHash, anchors}`. Last entry `INV-claude-hook-secret-denylist` at `:323-330` (35th entry). Story 2.17 extends schema with optional `hashScope` field + adds 4 entries (39 total).
- `packages/keel-invariants/src/sync-gate.ts` — 100 lines at iter-309 baseline. Whole-file walker at `:36-100`. Story 2.17 extends walker to branch on `hashScope.kind`.

**`.git/hooks/` ground-truth:**
- `commit-msg` (479 bytes, executable) + `pre-commit` (479 bytes, executable) — prek-installed at Story 1.4/1.5 substrate. Plus 15 `.sample` hooks (not runtime-active). Story 2.17 `INV-git-hooks-preservation` protects only `commit-msg` + `pre-commit` via names+shebangs hashing.

**PRD + Architecture citations:**
- `prd.md:1075` NFR5a (deny-rule baseline).
- `prd.md:1076` NFR5b (bypass-resistance — CLOSEST BIND to Story 2.17 user story).
- `prd.md:959` FR14k halt-reason enum (`SECURITY_CRITICAL` in closed set).
- `prd.md:1003` FR36 severity-threshold halt contract.
- `prd.md:1004` FR37 security-evidence.json contract.
- `prd.md:1012` FR42 INVARIANTS.md agent-readable index.
- `prd.md:1013` FR43 pre-merge sync-gate.
- `architecture.md:202-220` S3 security-evidence schema + `scans.prompt_injection.findings[]`.
- `architecture.md:222` S4 prompt-injection scan tier.
- `architecture.md:940` project tree `packages/keel-invariants/src/prompt-injection-rules/` subdirectory.
- `architecture.md:1444` bootstrap instruction for the scan-rules subdirectory.

### Content-hash scoping strategy (the key design decision)

The manifest schema extension in Task 1.1 introduces three `hashScope.kind` values, each purpose-built:

1. **`jq-subtree`** — for JSON files with fork-extension slots (e.g. `.claude/settings.json` where forks MAY add sibling keys without triggering substrate drift). Filter normalises ordering via `sort_by`. Canonical form: `jq -c '<filter>' <file> | sha256sum`.
2. **`anchor-range`** — reserved for non-JSON files where HTML-comment or shell-comment markers delimit substrate regions. Not used at Story 2.17 landing (no substrate file fits this pattern yet); schema-reserved for future stories.
3. **`names-and-shebangs`** — for directories where byte-content drifts across tooling upgrades (prek-installed hooks) but the NAMES + SHEBANG-lines are stable contract. Walker reads `EXPECTED_HOOKS` enumeration, builds `sort(name + "\t" + first-line-of-file)` over `.git/hooks/<name>` files, hashes.

Back-compat: absent `hashScope` → whole-file sha256 (current behaviour). All 35 pre-existing entries remain unchanged.

Rejected alternatives:
- **Schema-shape perturbation** (e.g. adding `$schema` or `_substrate_anchor` JSON key to `.claude/settings.json`): perturbs Claude Code's settings parser; some versions may log warnings or refuse unknown top-level keys; fragile.
- **Whole-file hashing of `.claude/settings.json`**: RED on every fork allow-list addition; defeats the fork-extension-without-substrate-edit contract (NFR45 + `docs/invariants/fork.md` § Amendment-vs-fork decision tree).
- **Multi-sourcePath per manifest entry** (i.e. one ID protects N files with N hashes): requires array-typed `contentHash`; schema and comparison logic get messy; reject in favour of multi-entry-per-concern (each concern gets its own ID).

### 7-site AMEND coordination pattern (extended from Story 2.16)

When a fork operator with legitimate need modifies substrate-authoritative surfaces, the AMEND PR must touch these sites IN LOCKSTEP (byte-identity or content-hash-updated as appropriate):

1. `.claude/hooks/block-secret-access.sh` — substrate hook script.
2. `.claude/settings.json` `hooks.PreToolUse` sub-tree — substrate hook registration.
3. `docs/invariants/claude-hook-denylist.md` — invariant doc (contract description).
4. `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh` — seed hook (byte-identity).
5. `packages/keel-templates/src/seeds/.claude/settings.json` `hooks.PreToolUse` sub-tree — seed settings (byte-identity).
6. `packages/keel-invariants/src/invariants.manifest.ts` — manifest contentHash (whatever entries the amendment covers: `INV-claude-hook-secret-denylist`, `INV-claude-settings-deny-rules`, `INV-claude-hook-secret-denylist-doc`).
7. `INVARIANTS.md` — anchor bullet (if the amendment introduces or removes an anchor).

Post-Story 2.17 additional lockstep sites (if amendment touches these):
8. `packages/keel-invariants/src/prek-hook-manifest.ts` — when amendment adds/removes expected hook names.
9. `.git/hooks/commit-msg` + `.git/hooks/pre-commit` — regenerated via `prek install` after any `.pre-commit-config.yaml` change; names+shebangs hash updates.
10. `packages/keel-invariants/src/prompt-injection-rules/` — S4 rules added/removed.

### Bypass-resistance hierarchy (defense-in-depth)

Story 2.17 completes a THREE-LAYER defense:

- **Layer 1 — In-session (Story 2.16):** PreToolUse hook `.claude/hooks/block-secret-access.sh` blocks `Bash`, `Read`, `Edit`, `Write`, `Grep`, `Glob` tool calls matching the denylist. Applies REGARDLESS of permission mode (NFR5a Ralph-path defense via `--dangerously-skip-permissions`). Caught: real-time secret access + hook self-protection + L1 install-boundary (Task 7 adds).
- **Layer 2 — Git-layer (Story 2.17 primary scope):** Story 1.9 pre-merge sync-gate reads `invariants.manifest.ts` + `.git/hooks/` + `.claude/settings.json` + `.claude/hooks/block-secret-access.sh`; emits `content-hash-mismatch` drift if any out-of-band mutation landed (edits that evaded Layer 1 via a non-Claude editor, race condition, or novel bypass). PR cannot merge with drift.
- **Layer 3 — Pre-commit scan (Story 2.17 rules + Epic 4 scanner):** S4 prompt-injection regex rules flag any diff touching `.claude/hooks/**`, `.claude/settings*.json`, or `.git/hooks/**` with severity `high`. FR36 threshold at `high` → commit blocked + `security-evidence.json.overall_severity_max = "high"` → `halt_required = true` → Ralph halts `SECURITY_CRITICAL`.

**Layer 1 catches commit-time in-session attempts. Layer 2 catches out-of-band attempts that evaded Layer 1. Layer 3 catches attempts that landed in the diff (a regression in Layer 1 OR legitimate substrate amendment — the latter passes because the content-hash is updated in lockstep + the AMEND PR carries a `feat!:` commit that's human-reviewed).**

### Halt-write contract (Epic 3 Story 3.7 consumer spec)

```json
{
  "reason": "SECURITY_CRITICAL",
  "iteration_id": "<uuid>",
  "rule_id": "hook-self-protection",
  "block_count": <N>,
  "threshold": <T>
}
```

Written to `${RALPH_BASE_DIR}/halt` at Ralph iteration end when `jq -c 'select(.rule_id == "hook-self-protection")' ${RALPH_BASE_DIR}/logs/<iter-id>/blocked-tool-calls.jsonl | wc -l >= T` where `T = read-config('.ralph/config.toml', '[hooks].self_protection_halt_threshold', default=3)`.

Epic 3 Story 3.7 owns the `read-config` implementation. Story 2.17 pins the key-name, schema, default, range (`1..=100`), and fail-closed behaviour (out-of-range → default + stderr warning per D-23).

### L1 install-boundary protection rationale

Epic 3's RS1 (Ralph safe-set) defines three layers of code Ralph is NOT permitted to author:
- L1 (install boundary): `packages/keel-invariants/src/` substrate enforcement code.
- L2 (hook boundary): `.claude/hooks/`, `.claude/settings.json` (substrate sub-tree), `.git/hooks/` preserved set.
- L3 (orchestrator boundary): `ralph.py`, `.ralph/PROMPT_*.md` (runtime loop contracts).

Story 2.16 covers L2 + L3 (partial — git-hooks via self-protection rule). Story 2.17 Task 7 adds the L1 coverage via a dedicated `install-boundary-protection` rule-id. Closing the loop: any Ralph-authored edit attempt against substrate enforcement code is blocked at hook layer + would ALSO fail the sync-gate at Layer 2 + would flag S4 at Layer 3 — triple defense.

### DEFER absorption plan (SC-17 scope)

**Primary scope (hook + settings bypass-resistance; must-absorb):**
- Story 2.16 iter-308 CR DEFERs D-12..D-36 (25 entries) → Task 10.1 + Task 7 (L1) + Task 8 (local-settings) + Task 12 (pre-install discipline) + Task 11.1 (seed-byte-identity).
- Story 2.15 carry-forward D-2/D-4/D-5/D-7/D-8/D-9/D-10/D-11 (8 entries; D-1/D-3/D-6 already mitigated by Story 2.16 hook layer) → Task 10.2 (permissions-layer patches).
- Story 2.16 iter-306 trace D-7/D-8/D-9 (3 entries) → Task 11.

**Cumulative primary-scope absorption: 36 entries** (25 + 8 + 3).

**Secondary scope (SC-17 polish-pass; should-absorb 15-25 entries via Task 16):**
- Story 2.13 CR D-11 (citation-lockstep Dockerfile line numbers — if touched by Story 2.17 Task 13 docs).
- Story 2.14 CR D-8 (architecture.md:361 citation unverified — verify + fix inline).
- Story 2.14 CR D-15 (grep UPSTREAM_SHA placeholder — if touched by Task 16.1 audit).
- Assorted 1.8-1.16 DEFERs for citation-lockstep class.
- Remainder: defer to Epic 3+ or obsolete-remove.

**Tertiary scope (defer-to-later — carry-forward list):**
- Stories 1.8-1.16 non-citation-lockstep DEFERs (substrate code changes outside Story 2.17 touch-set).
- Stories 2.1-2.12 DEFERs (devbox substrate-code changes — per-fork-path, SSH opt-in, mode-flip edge cases — all outside Story 2.17 touch-set).
- Target carry-forward count at Epic 2 close: **< 30 DEFERs** (from 83 pre-Story-2.17 count; 36 substrate + 15-25 polish + 0-N triage = 51-61 absorbed).

### Project Structure Notes

- Alignment with unified project structure: all new files under `packages/keel-invariants/src/` (TypeScript substrate) + `.claude/hooks/` (bash substrate) + `.ralph/` (config) + `docs/invariants/` (contract docs) + `packages/keel-templates/src/seeds/.claude/` (seed lockstep) + `_bmad-output/planning-artifacts/` (epics.md — unchanged; Story 2.17 is the final Epic-2 consumer).
- Detected conflicts: none. Story 2.17 touch-set does not overlap with any open Epic 3 story branches.
- Naming convention: manifest IDs continue `INV-<kebab>` pattern (`INV-claude-settings-deny-rules`, `INV-git-hooks-preservation`, `INV-git-hooks-preservation-enumeration`, `INV-claude-hook-secret-denylist-doc`). Test files match `<module>.test.ts`. Prompt-injection rules use `s4-<kebab>` prefix.

### References

- `_bmad-output/planning-artifacts/epics.md:1722-1773` — Story 2.17 ACs (authoritative).
- `_bmad-output/planning-artifacts/prd.md:1074-1076` — NFR5/5a/5b (authoritative user-story tie).
- `_bmad-output/planning-artifacts/prd.md:959` — FR14k halt-reason enum.
- `_bmad-output/planning-artifacts/prd.md:1003-1015` — FR36/37/42/43/45.
- `_bmad-output/planning-artifacts/architecture.md:202-220` — S3 security-evidence schema.
- `_bmad-output/planning-artifacts/architecture.md:222` — S4 prompt-injection scan tier.
- `_bmad-output/implementation-artifacts/2-15-committed-claude-settings-json-with-deny-allow-permission-policies.md` — Story 2.15 completion (permissions-layer baseline).
- `_bmad-output/implementation-artifacts/2-16-claude-pretooluse-hooks-for-secret-file-denylist-ralph-compatible.md` — Story 2.16 completion (hook-layer baseline + 25 DEFERs).
- `_bmad-output/implementation-artifacts/deferred-work.md` — cumulative DEFER ledger (83 entries at iter-309 baseline).
- `packages/keel-invariants/src/invariants.manifest.ts:323-330` — `INV-claude-hook-secret-denylist` current entry (re-pointed by Story 2.17).
- `packages/keel-invariants/src/sync-gate.ts` — gate walker (extended by Task 1.2).
- `.claude/hooks/block-secret-access.sh` — hook substrate (amended by Task 10.1 + Task 7).
- `.claude/settings.json` — settings substrate (amended by Task 2 + Task 10.2).
- `.ralph/config.toml` — halt-threshold pin (verified by Task 6.1).
- `docs/invariants/claude-hook-denylist.md` — Story 2.16 invariant doc (amended by Task 13.5).
- `docs/invariants/fork.md` § Amendment-vs-fork decision tree — fork-path reference (AC 5).
- `AGENTS.md:211-236` — Story 2.15 + 2.16 H3 sections (Story 2.17 appends after).
- `INVARIANTS.md:138-142` — Story 2.16 H3 (Story 2.17 appends after).
- `packages/devbox/README.md` § Claude PreToolUse hooks (Story 2.16) — Story 2.17 appends sibling H2.
- `packages/keel-templates/README.md` — seed-assets bullet (updated by Task 14.4).

### LLM-dev-agent guardrails (prevent the most likely disasters)

1. **DO NOT blindly apply all 25 D-12..D-36 patterns at once.** Apply in small groups (e.g. D-12/D-13/D-35 anchoring together; D-14/D-15/D-16 mutation-path coverage together) with `bash -n` + `dash -n` after each group. Iter-305 NOVEL LESSON: hook self-immolation bricks Bash/Read/Edit/Write/Grep/Glob surfaces; recovery via Monitor escape-hatch. Work in small, reversible increments.
2. **DO NOT modify sync-gate.ts behaviour for existing 35 entries.** The `hashScope` field is OPTIONAL; absent → whole-file sha256 → no change for pre-existing entries. Any observable change to Story 1.9's output for pre-existing entries is a regression.
3. **DO NOT invent new halt reasons.** `reason: "SECURITY_CRITICAL"` per FR14k closed enum is the ONLY correct value. AskUserQuestion is NOT invoked from runtime loop (RALPH.md guardrail 3).
4. **DO NOT hash `.claude/settings.json` whole-file.** Breaks fork-extension contract. Sub-tree hash via `jq-subtree` is the contract.
5. **DO NOT repoint `INV-claude-hook-secret-denylist` without preserving invariant-doc protection.** The split into `INV-claude-hook-secret-denylist` (hook script) + `INV-claude-hook-secret-denylist-doc` (invariant doc) keeps both protected. Do not drop one.
6. **DO NOT implement Epic 3 Story 3.7's halt-write in Story 2.17.** Task 6 pins the CONTRACT; Story 3.7 implements. Out-of-scope for Story 2.17 dev-story iter.
7. **DO NOT implement Epic 4's S4 scanner binary in Story 2.17.** Task 5 authors the RULES (TypeScript modules); the pre-commit scanner that invokes them is Epic 4 Story 4.x. Out-of-scope.
8. **DO NOT forget seed lockstep.** After amending substrate `.claude/hooks/block-secret-access.sh` OR `.claude/settings.json`, run a diff against the seed to confirm byte-identity (or re-sync). Sync-gate will RED if mismatched.
9. **DO NOT delete DEFERs from `deferred-work.md` without rationale.** Each DEFER absorbed / deferred / obsoleted must carry a one-line justification. Audit trail must survive Epic 2 → Epic 3 handoff.
10. **DO NOT exceed ~700 lines for this story file.** The original Story 2.16 was 600 lines; Story 2.17 scope is ~1.3x (83-DEFER absorption + 3-layer defense); target 700-800 lines including Completion Notes.

## Dev Agent Record

### Agent Model Used

Claude Opus 4.7 (1M context) — `claude-opus-4-7[1m]`; Ralph iter-309 create-story.

### Debug Log References

- iter-309 `/bmad-create-story` (this iteration): drafted Story 2.17 from epics.md:1722-1773 + Story 2.16 learnings + 83-DEFER inventory triage. Research subagent fan-out (general-purpose) collected previous-story intel + PRD/arch citations + substrate surface + deferred-work ledger in a single round — 5,700-word report returned in ~200K tokens / 46 tool_uses / 451s duration (subagent budget well above the BH enumerate-touched-files optimisation of iter-308; the research subagent is scope-unbounded by design whereas BH is enumeration-bounded).

### Completion Notes List

_(populated by `/bmad-dev-story` at lifecycle state `atdd-scaffolded → review`)_

### File List

_(populated by `/bmad-dev-story`; expected surface 25-35 files)_

Forecast File List (for dev-story planning):

**NEW (~10 files):**
- `packages/keel-invariants/src/prek-hook-manifest.ts`
- `packages/keel-invariants/src/prek-hook-manifest.test.ts`
- `packages/keel-invariants/src/prompt-injection-rules/hook-settings-tamper.ts`
- `packages/keel-invariants/src/prompt-injection-rules/hook-settings-tamper.test.ts`
- `packages/keel-invariants/src/check-claude-hook-syntax.ts`
- `packages/keel-invariants/src/check-claude-hook-syntax.test.ts`
- `packages/keel-invariants/src/check-nfr5a-minimum.ts`
- `packages/keel-invariants/src/check-nfr5a-minimum.test.ts`
- `packages/keel-invariants/src/check-seed-byte-identity.ts` (if chosen over manifest-entry approach)
- `packages/keel-invariants/src/check-seed-byte-identity.test.ts`

**MODIFIED (~15-20 files):**
- `.claude/hooks/block-secret-access.sh` (D-12..D-36 absorption + L1 install-boundary rule)
- `.claude/settings.json` (D-4/D-5/D-8/D-10/D-25 permissions-layer + MultiEdit/NotebookEdit matchers)
- `packages/keel-invariants/src/invariants.manifest.ts` (35 → 39 entries + schema `hashScope` field)
- `packages/keel-invariants/src/sync-gate.ts` (multi-mode walker)
- `packages/keel-invariants/src/manifest-reader.ts` (sub-tree/anchor-range/names-shebangs helpers)
- `packages/keel-invariants/src/sync-gate.test.ts` (+8 tests)
- `packages/keel-invariants/src/check-no-committed-dotfiles.ts` (add `.claude/settings.local.json` pattern)
- `.ralph/config.toml` (verify halt-threshold pin)
- `.pre-commit-config.yaml` (wire new invariant gates)
- `docs/invariants/claude-hook-denylist.md` (§ Git-layer + § S4 + § L1 + § Halt-threshold + § Limitations + § Pre-install + § Fresh-fork seed)
- `docs/invariants/ralph-execute.md` (§ Halt-threshold consumer forward-ref — if file exists; else note TODO)
- `AGENTS.md` (new H3 § Hook + settings bypass-resistance (Story 2.17))
- `CLAUDE.md` (new sibling bullet)
- `INVARIANTS.md` (new H3 + 4 bullets)
- `packages/devbox/README.md` (new H2)
- `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh` (re-sync)
- `packages/keel-templates/src/seeds/.claude/settings.json` (re-sync)
- `packages/keel-templates/README.md` (seed-assets bullet → "Story 2.15+2.16+2.17")
- `_bmad-output/implementation-artifacts/deferred-work.md` (SC-17 triage section)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (`2-17-…: ready-for-dev → review` at dev-story end)

### Change Log

| Version | Date       | Description                                                                                                                                                                                                                                                           | Author |
| ------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
| 0.1     | 2026-04-24 | `/bmad-create-story` initial draft (iter-309): 8 ACs authored from epics.md:1722-1773; 17 Tasks + ~70 subtasks covering 3-layer defense + 36-entry primary DEFER absorption + 15-25 SC-17 polish absorption + seed/doc/INVARIANTS sibling-append; status `drafted`.  | Ralph  |
