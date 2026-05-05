---
title: Sprint Change Proposal — Codex First-Class Tier-1 Substrate (Proposal A)
date: 2026-05-05
author: Tthew (via /bmad-correct-course YOLO mode — Claude orchestrator + Opus sub-agent + 2 codex sparring rounds)
project: ralph-bmad / Keel
scope: Major (PM + Architect + Dev coordination)
status: awaiting Tthew approval
related: PRD FR3, FR5, FR7, FR14k (codex session-resume clause), FR40 (`.codex/**` extension); NFR5a, NFR5b, NFR6, NFR10, NFR30; Epic 2 (Stories 2.1, 2.10, 2.15, 2.16, 2.17, 2.19/2.20/2.21/2.22 NEW); Epic 3 (Stories 3.2, 3.10, 3.34 NEW); architecture.md § tools.json + § Substrate-Authorship-Constants + § Substrate Security Posture
supersedes: original PR #237 PR-0 (alongside companion proposal Proposal B `docs/agents-first-knowledge-restructure`)
companion: Proposal B — knowledge-file + prompt-file restructure (separate sprint change proposal)
---

# Sprint Change Proposal — Codex First-Class Tier-1 Substrate (Proposal A)

> **Decomposition note.** This is one of two sprint change proposals split out of PR #237's bundled artifact at the user's request. Proposal A (this document) owns the codex parity / Tier-1 substrate axis. Proposal B (`docs/agents-first-knowledge-restructure`) owns the AGENTS.md-primary knowledge-file + prompt-file restructure. The original bundled proposal at `_bmad-output/planning-artifacts/sprint-change-proposal-2026-05-04.md` is **superseded** by A + B together; PR #237 PR-0 is **superseded by A-0 + B-0**.

## Section 1 — Issue Summary

**The change in one sentence:** escalate codex CLI from a Tier-2 deviation path to a first-class Tier-1 substrate axis, with substrate-invariant parity on covered surfaces and named gaps where parity is empirically impossible.

**Trigger evidence:**

- **Bug observed.** Tthew reports: "Ralph loops don't work currently with codex. The harness loads but the loop crashes infinitely." Root cause confirmed in `ralph.py`:
  - `ralph.py:586-596` codex profile uses `--skip-git-repo-check` as the "unsafe" mapping (wrong flag — it skips git checks, not approvals/sandbox).
  - `ralph.py:1822-1824` exit-code handling only breaks on SIGINT 130; non-zero exits log a warning and retry forever — no consecutive-failure halt.
- **Coverage gap confirmed via fresh codex docs research (2026-05-04, fetched live from developers.openai.com/codex) + post-audit corrections (codex 0.128.0 verified locally):**
  - Codex DOES have `[[hooks.PreToolUse]]` (in `~/.codex/config.toml` or `<repo>/.codex/hooks.json`), feature-flagged via `features.codex_hooks`. **Correction:** `codex_hooks` is `stable true` by default per `codex features list`; INV check on literal `[features] codex_hooks = true` TOML presence FALSE-FAILS. Assertion mechanism must use runtime probe (`codex features list | grep '^codex_hooks: enabled$'`).
  - Codex docs do NOT explicitly state `PreToolUse` survives `--dangerously-bypass-approvals-and-sandbox` (Claude's docs DO guarantee this).
  - **Correction:** Codex hook matcher tool names are `Bash`, `apply_patch` (matches `Edit`/`Write`), and MCP names like `mcp__fs__read` — NOT `shell_tool` (which is a feature flag name, not a hook matcher). PreToolUse only intercepts simple Bash + apply_patch + MCP tool calls; **`web_search` and unified-exec are NOT intercepted** — substrate-invariant L1 parity has a named ceiling.
  - `codex exec --json` emits JSONL stream events. **Correction:** the actual surface is `thread.started`, `turn.started`, `turn.completed` (with `usage.input_tokens` / `usage.output_tokens`; no cost field), `turn.failed`, plus `item.started` / `item.updated` / `item.completed` envelopes wrapping `item.type: "command_execution" | "agent_message" | "reasoning"` — NOT a flat `item.command_executed` / `item.agent_message`. Empirical capture is a **PR-2 prereq**, not just PR-8.
  - Session resume via `~/.codex/sessions/YYYY/MM/DD/rollout-...<uuid>.jsonl` + `codex exec resume --last` (sessions are global per-user, not per-cwd; auto-resume **deferred to Growth-tier** at 1.0 — `.ralph/@plan.md` is the only durable crash journal).
- **The 2026-04-17 research report (`technical-keel-ralph-bmad-research-2026-04-17.md:175`)** explicitly parked codex as Tier-2 "not blocked at the quality-gates story." This proposal supersedes that framing.

**What changed since 2026-04-17:** Tthew's stated preference shifted from "Tier-2 acceptable" to "more durable." This is a legitimate input but constitutes architectural taste, not new external evidence. The substrate's dual-posture tie-breaker ("research-output richness wins over substrate ship-velocity") justifies the depth: monthly absorption sprints under both CLIs become a research artifact in their own right.

**Scope boundary (vs. Proposal B):** This proposal does NOT rewrite knowledge-file prose (AGENTS.md / CLAUDE.md / PROMPT_*.md). Where this proposal touches FR14k, FR40, or architecture.md § Knowledge-file contract, it cites canonical entrypoints by name only — Proposal B owns the prose surgery, R4 rotation flip, and `.ralph/PROMPT_*.md` line-by-line edits. See § Cross-cutting splits below.

---

## Section 2 — Impact Analysis

### 2.1 Epic Impact

| Epic | Status | Impact |
|------|--------|--------|
| Epic 1 — Substrate scaffolding | done | No story changes. INVARIANTS.md acquires four new entries (`INV-substrate-defense-layers`, `INV-barrier-hooks-deny-list-canonical`, `INV-codex-hooks-feature-enabled`, `INV-codex-hook-secret-denylist`); `packages/keel-invariants/` acquires `hookBarrier.ts` data + per-CLI emitters; manifest entries source-pinned (no "doc-only" — schema requires `sourcePath` + `contentHash` + `anchors`). These land via Epic 2 stories that depend on them; no Epic-1 retroactive change. |
| Epic 2 — Packaged devbox | backlog | **6 existing stories amended + 4 new stories** (sequential numbering: 2.19, 2.20, 2.21, 2.22 — *not* 2.18-2.21; the original 2.18 slot conflicts with `2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix: done` already in `_bmad-output/implementation-artifacts/sprint-status.yaml:180`). Story 2.1 amended for codex CLI baked at image-build. See Story Impact below. |
| Epic 3 — Ralph build mode | backlog | **2 existing stories amended + 1 new story (3.34).** Cross-CLI crash-journal contract reframe in 3.10 (codex session-resume defer-to-Growth); Story 3.2 grows pidfile lock + per-CLI binary invocation amendments. |
| Epic 14 — Research corpus | backlog | Optional: add a row in `docs/research/test-ids.md` for cross-CLI absorption-delta as a Growth-tier research dimension. Out of 1.0 critical-path scope. |
| Epics 4-13, 15a, 15b | backlog | No structural changes. |

**Epic order/priority unchanged.**

### 2.2 Story Impact

**Epic 2 amendments (existing stories):**

| Story | Current scope | Proposed amendment |
|-------|---------------|--------------------|
| 2.1 — Devbox image build (toolchain provenance) | claude-only baked toolchain (`@anthropic-ai/claude-code@<pinned>`) | Extend AC: bake `@openai/codex@<pinned>` at image-build alongside claude (per PRD §545 toolchain provenance). Without this amendment, Story 2.10 prereq probe + Story 2.22 pre-loop probe have nothing to probe. |
| 2.10 — Prerequisite check (Docker + Claude auth + gh auth) | claude-only auth probe | Extend AC: when `aiCli === "codex"`, prereq check ALSO probes `~/.codex/auth.json` (or `OPENAI_API_KEY`) AND runs `codex features list` to assert `codex_hooks` is `enabled` (runtime probe — NOT literal TOML presence, which false-fails on default-enabled installs per codex 0.128.0 verification). AND probes `codex --version` against minimum-version-with-hooks-support. Fail-pointer-error citing `docs/install/codex.md` if any missing. |
| 2.15 — Committed `.claude/settings.json` deny rules | claude-only | Rename to **"hook-barrier-emission-per-cli"** ("Hook-barrier emission — committed per-CLI config from canonical deny-list"). Adds: canonical `packages/keel-invariants/src/hookBarrier.ts` data module. Codex emitter (`emitCodexHooks() → .codex/hooks.json` with empirically-derived matchers using actual codex tool names `Bash`, `apply_patch`, `mcp__*`) lands in Story 2.20 (was 2.19 in original draft). |
| 2.16 — Claude PreToolUse hooks | claude-only | Rename to **"pretooluse-hook-implementation-per-cli"** ("PreToolUse hook implementation — per-CLI"). Existing claude scope preserved. Codex `.codex/hooks/block-secret-access.sh` PreToolUse hook with deny-signal normalizer (exit-2 + JSON `permissionDecision: deny`) lands in Story 2.21. |
| 2.17 — Hook + settings bypass-resistance (git-layer) | claude-only manifest entries | Extend AC: invariant manifest registers `INV-claude-hook-secret-denylist` AND `INV-codex-hook-secret-denylist`; pre-merge sync gate covers `.claude/settings*.json`, `.claude/hooks/**`, `.codex/hooks.json`, `.codex/hooks/**`. Manifest covers `.codex/**` (full subtree, including `.codex/AGENTS.md`). NFR5b 3-strike halt counter normalizes ALL non-deny outcomes per Story 2.21 normalizer ACs. |
| 2.8 — Claude Code OAuth via `pnpm claude` | claude-only | (Existing renames pinned in Proposal B's Section 4 do not include 2.8 itself; 2.8 stays as Tier-1 reference impl — codex login flow lands in NEW Story 2.19 via `pnpm codex` with token storage at `/home/dev/.codex/` inside the existing single named `/home/dev/` volume per NFR10.) |

**Epic 2 new stories (sequential numbering — 2.19/2.20/2.21/2.22 — confirms `sprint-status.yaml:180` precedent for `2-18-...`):**

- **2.19** — Codex OAuth via `pnpm codex` (size: S; depends on 2.1 amendment for codex CLI baked + existing single `/home/dev/` named volume from current 2.5). Token storage: `/home/dev/.codex/` inside the existing single named `/home/dev/` volume per NFR10 (no new parallel volume).
- **2.20** — `emitCodexHooks()` per-CLI emitter (size: M; depends on canonical deny-list from 2.15; **empirical prereq promoted to PR-2 not just to this story** — capture `codex exec --json` output + commit fixture at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl` with consuming test owner before adapter and matchers ship).
- **2.21** — Codex `.codex/hooks/block-secret-access.sh` PreToolUse hook + deny-signal normalizer with **enumerated non-deny shape handling** (process-fail / stdout-empty / hooks-disabled-silent-allow / partial-JSON / hooks-config absent all fail-closed). Size: M; depends on 2.20.
- **2.22** — Per-CLI **pre-loop pointer probe** verifying (a) codex auth present, (b) `codex_hooks=enabled` per `codex features list`, (c) codex version ≥ minimum supporting hooks, (d) deny-list smoke (read of `.envrc.test-fixture` blocked + canary counter increments). Sentinel content = sha256 of `.codex/hooks.json` + codex binary version + matcher names; pre-commit hook rejects committed sentinel. **Implementation note:** `keel doctor` does not exist as a CLI today and `CODEX_DOCTOR_REQUIRED` would violate the closed halt-reason enum + autonomy guardrail (per `INVARIANTS.md:47`). **Reframed as pre-loop pointer error in `ralph.py` codex-profile spawn path** — fails fast before iteration begins with a diagnostic message; no new halt reason needed; closed halt-enum + autonomy guardrail per `INVARIANTS.md:47` are reaffirmed. Size: S.

**Epic 3 amendments:**

| Story | Current scope | Proposed amendment |
|-------|---------------|--------------------|
| 3.2 — Ralph multi-iteration loop with `claude -p` | claude-only invocation | Rephrase to "Ralph multi-iteration loop with configured AI CLI." Replace `claude -p` references with "the configured AI CLI binary"; rephrase effort-default narrative as Claude-default (`xhigh`) with codex-default deferred to codex profile (codex doesn't expose `--effort` flag). Add AC for tool-axis selection via `--tool {claude\|codex}` and `.ralph/tools.json` profile resolution. **Cross-CLI lock contention:** add pidfile `.ralph/.lock` to prevent concurrent invocations against the same worktree (silent corruption of `.ralph/@plan.md` otherwise — no `flock`/`fcntl` exists in `ralph.py` today). |
| 3.10 — Native Claude Code task list as crash journal | claude-only | Reframe as "Cross-CLI crash-journal contract." `.ralph/@plan.md` becomes the substrate-invariant crash journal (per FR14k). Native Claude task list is a Claude-only convenience mirror that survives hard kills. **Codex session-resume parity DEFERRED to Growth-tier** — codex sessions live at `~/.codex/sessions/YYYY/MM/DD/rollout-...<uuid>.jsonl` and are global-per-user (not worktree-scoped); `codex exec resume --last` selects globally most-recent and may resume into wrong cwd. At 1.0, codex iterations rely solely on `.ralph/@plan.md`. Spec narrative updated; no behavioral change to `.ralph/@plan.md` schema. |

**Epic 3 new story:**

- **3.34 (new)** — Nightly `--yolo` bypass-survival promotion gate. Test that codex `[[hooks.PreToolUse]]` denylist holds when codex runs with `--dangerously-bypass-approvals-and-sandbox`. **Test design (mandatory — no false-green):** per nightly run, three sub-tests must ALL pass — (1) **positive control**: prompt codex (under `--yolo`) to read `.envrc.test-fixture` containing canary `KEEL_CANARY_<run-id>`; assert codex stream-json contains a deny event for the EXACT tool-name + path, assert canary NOT in stdout, assert `.ralph/logs/hook-fires.jsonl` counter incremented by exactly 1; (2) **negative control**: prompt codex to read `.ralph/test-allowed-fixture` (NOT in deny-list); assert read succeeds with content in stdout, no deny event, counter unchanged; (3) **canary**: hook-invocation-counter delta == 1 from positive control — if delta == 0, FAIL the run regardless of leak assertion (kills tool-name-mismatch silent-pass dead). **Promotion threshold (hardened):** 30 consecutive green nights AND ≥2 distinct codex versions (catches version-drift regression) AND ≥1 chaos-injected deliberate-deny verification per week (matcher intentionally broken to confirm test fails-closed). After all conditions met, **`keel-bot` opens a reviewable PR** flipping codex profile default from `--sandbox=workspace-write -c approval_policy="never"` to `--dangerously-bypass-approvals-and-sandbox` — NOT direct push to main, required human approval per `AGENTS.md` ("never force-push main, never skip hooks or signing"). Demote-trigger conditions also pinned (regression after promote → bot opens demote PR). Size: M (CI workflow + flake-budget integration + bot-PR opener script + chaos fixture + canary counter logger).

### 2.3 PRD Conflicts

| FR/NFR | Current text (pinned implicit Claude assumption) | Proposed change |
|--------|--------------------------------------------------|-----------------|
| FR3 | "Developer can authenticate Claude Code and `gh` CLI once per devbox via browser OAuth flows" | "Developer can authenticate the configured AI CLI (Claude Code or codex) and `gh` CLI once per devbox via browser OAuth flows" — codex-shape recognition. |
| FR5 | "System can enforce prerequisites (Docker runtime, Claude Code authentication, `gh` CLI authentication)" | "System can enforce prerequisites (Docker runtime, configured AI CLI authentication AND CLI-specific feature-flag/config preconditions, `gh` CLI authentication)" — per-CLI tools.json profile. Codex-specific feature-flag check is `codex features list \| grep '^codex_hooks: enabled$'` (runtime probe — NOT literal `[features] codex_hooks = true` TOML presence, which false-fails on default-enabled installs per codex 0.128.0 verification). Also probe `codex --version` against minimum-version-with-hooks-support. |
| FR7 | "Agent can execute a multi-iteration loop... invoking `claude -p` with adaptive thinking" | "Agent can execute a multi-iteration loop... invoking the configured AI CLI binary (`claude -p` or `codex exec --json`) with CLI-appropriate effort/thinking settings" — `CodexJsonAdapter` event mapping covered in Architecture § tools.json. |
| FR14k | "...native Claude Code task list as the iteration's crash journal" | (codex-only clause split owned by A:) "...codex session-resume is NOT a substrate-invariant crash journal at 1.0 — promotion to parity is Growth-tier (worktree-aware session selection upstream prereq)." (Proposal B owns the canonical-naming clause.) |
| FR40 | Pattern-scan list pins `CLAUDE.md, skill files, .ralph/PROMPT_*.md, docs/**/*.md` | (codex-only extension owned by A:) Extend to **`.codex/AGENTS.md`**, **`.codex/hooks.json`**, **`.codex/hooks/**`** (3-tier codex hierarchy + committed config files). (Proposal B owns the AGENTS.md cell.) |
| NFR5a | Hooks-barrier described as Claude-Code-specific | Reframe as substrate-invariant with **explicit tool-surface coverage clause**: "in-session secret-access barrier via PreToolUse hooks emitted from canonical deny-list (`packages/keel-invariants/src/hookBarrier.ts`); per-CLI config files (`.claude/settings.json`, `.codex/hooks.json`) are projections of the canonical data. **Barrier coverage is bounded by per-CLI hook matcher tool-name surface**: claude intercepts Read/Grep/Glob/Bash/Edit/Write/MultiEdit; codex PreToolUse intercepts Bash + apply_patch (which matches Edit/Write) + MCP names (`mcp__*`) only — `web_search` and unified-exec are NOT intercepted. Tools outside the per-CLI surface are out-of-scope for L1 and rely on L0 (devbox sandbox + egress) + L2 (git-layer manifest) + L3 (runtime halt)." |
| NFR5b | bypass-resistance via git-layer manifest entries `INV-claude-hook-secret-denylist` | Extend manifest to register both `INV-claude-hook-secret-denylist` and `INV-codex-hook-secret-denylist`; **deny-signal normalizer** enumerates ALL non-deny outcomes and fails-closed: (a) affirmative deny via exit-2 OR JSON `permissionDecision: deny` → counter increment; (b) ambiguous shapes (process-fail mid-write / stdout-empty / hooks-disabled-silent-allow / partial-JSON / hooks-config absent) → fail-closed (treat as not-deny → halt SECURITY_CRITICAL); (c) hook-fire counter delta == 0 when expected → fail-closed. |
| NFR6 | (existing) network egress allowlist | Cited directly as **Layer 0** in Defense Layer Coverage Matrix — no new NFR text required; existing NFR6 covers default-deny egress and is the foundational layer of the substrate defense. |
| NFR10 | "Claude Code and `gh` CLI authentication tokens persisted only inside devbox volume" | "Configured AI CLI (Claude Code, codex) and `gh` CLI authentication tokens persisted only inside the devbox's single named `/home/dev/` volume per PRD §546. Codex auth lives at `/home/dev/.codex/` inside that volume; claude auth at `/home/dev/.claude/`; `gh` tokens at `/home/dev/.config/gh/`. **No separate parallel `claude-auth`/`codex-auth` volumes** — preserves the existing one-volume contract that decouples persistence from any specific host path." |
| NFR30 | "Every Keel major version documents tested model generation, Claude Code CLI version, BMad version, and Ralph version" | "...documents tested model generation per supported AI CLI (Claude Code Opus N, codex gpt-N), AI CLI versions, BMad version, Ralph version. Multi-CLI matrix in `docs/upgrades/major-releases.md`." Codex auth probe added per Story 2.10 amendment. |
| Story 2.1 / Devbox toolchain provenance (PRD §545) | Bake only `@anthropic-ai/claude-code@<pinned>` | Add `@openai/codex@<pinned>` baked at image-build alongside claude. Without this, Story 2.10 prereq probe + Story 2.22 pre-loop probe have nothing to probe inside the devbox. |

**New PRD invariant:** `INV-substrate-defense-layers` — pinned in PRD § Implementation Considerations + architecture.md § Substrate Security Posture. **Source-pinned (cannot be "doc-only" per InvariantSchema requiring sourcePath + contentHash + anchors):** sourcePath = `_bmad-output/planning-artifacts/architecture.md`; anchors = `["INV-substrate-defense-layers", "Defense Layer Coverage Matrix"]`; contentHash computed at A-0 commit. Names the **5-layer + meta defense model**:

0. **Layer 0 — Devbox container + network egress allowlist (NFR6, NFR9, FR1a)** — outermost barrier; egress whitelist + tmpfs noexec/nosuid + container `no-new-privileges` + ipv4/ipv6 default-deny parity. The leaked-secret-with-no-exfil-path is half-defused at L0.
1. **Layer 1 — In-session PreToolUse hooks (NFR5a)** — PreToolUse barrier emitted per-CLI from canonical deny-list. **Sub-columns** (codex hook-surface coverage gap): for codex, matrix splits into `bash | apply_patch | mcp | unified-exec | web_search | other`; cells `documented | empirical-pending | not-intercepted`. Codex × in-session hooks coverage is bounded — `web_search` and unified-exec are `not-intercepted`. Claude × L1 documented; codex × L1 covered surfaces = empirical-pending until Story 3.34 promotion gate fires.
2. **Layer 2 — Git-layer invariant manifest + sync-gate (NFR5b)** — pre-commit drift detection.
3. **Layer 3 — Ralph runtime halt threshold (NFR33a)** — 3-strike SECURITY_CRITICAL halt; closed enum per `INV-ralph-halt-reason-enum`; deny-signal normalizer per NFR5b above.
4. **Layer 4 — Auth-token + log-secret isolation (NFR10)** — single named `/home/dev/` volume; `.ralph/logs/` secret-scrub on emit (Growth-tier extension).

**Meta-layer M1 — S4 prompt-injection scan (FR40)** — build-time pattern scan over committed prompts/config/docs. Not a runtime defense; runs at commit boundary only. Demoted from peer layer in original 4-layer model.

> *Permission prompts are out-of-band UX, not part of the defense model. Substrate runs autonomous (per `INV-ralph-halt-reason-enum` autonomy guardrail rejecting external-blocking states); barriers-and-gates enforce safety.*

### 2.4 Architecture Conflicts

| Section | Change |
|---------|--------|
| § tools.json (line ~829) | Codex profile fixed: `base_args=["exec", "--json"]`; `flag_map` corrected (`unsafe → --dangerously-bypass-approvals-and-sandbox`, `sandbox → --sandbox`, `model → --model`, `ephemeral → --ephemeral`); `defaults={"unsafe": False, "sandbox": "workspace-write"}` at 1.0 (tiered — flips to `unsafe: True` after Story 3.34 promotion gate; bot-PR not direct push). **Stream format & event mapping:** `stream_format="codex-json"` (new); `CodexJsonAdapter` dispatches on `item.started`/`item.updated`/`item.completed` envelopes wrapping `item.type: "command_execution" \| "agent_message" \| "reasoning"` (NOT a flat `item.command_executed`). **`-c approval_policy="never"` injection mechanism:** add `prefix_args` field on `ToolProfile` for fixed token-pair injection (`["-c", "approval_policy=never"]`) — current `tool_args` shape splits on `=` and cannot emit `-c key=value` correctly. |
| § Substrate-Authorship-Constants | Add `AI_CLI_SHAPES = ["claude", "codex"]`. Add `HOOK_BARRIER_DENY_LIST` constant pointing at `packages/keel-invariants/src/hookBarrier.ts`. **Downstream-touchpoint checklist:** adding a 3rd shape requires changes in (1) `ralph.py` profile dict, (2) AGENTS.md fallback prose [reference only — Proposal B owns the prose], (3) tools.json schema, (4) doctor sentinel naming, (5) `hookBarrier.ts` emitter, (6) invariant manifest entry — pin this 6-touchpoint list alongside the constant. |
| § Substrate Security Posture (new subsection) | Pin `INV-substrate-defense-layers` (source-pinned to architecture.md § Substrate Security Posture; not "doc-only" per InvariantSchema requirement). Add **Defense Layer Coverage Matrix (5-layer + meta)**: rows × cells = `claude × {L0..L4, M1}` and `codex × {L0..L4, M1}`. Codex × L1 expands to sub-columns `bash \| apply_patch \| mcp \| unified-exec \| web_search \| other` with cell values `documented \| empirical-pending \| not-intercepted`; codex × `web_search` and `unified-exec` start as `not-intercepted` (PreToolUse coverage gap acknowledged honestly). Claude × L0 egress = `deferred-growth` at 1.0 (NFR9 in scope; per-iteration egress audit Growth-tier). Codex × L1 covered surfaces = `empirical-pending` until Story 3.34's 30-green + ≥2-version + chaos-injection promotion gate fires. |
| § Knowledge-file contract | (Reference only — Proposal B owns the rewrite.) A's only architectural touchpoint here is to ensure the codex-side (`.codex/AGENTS.md` + `AGENTS.override.md` precedence) is named in the FR40 + FR14k clauses A owns. No prose surgery in this proposal. |
| § Ralph Path-Resolution Contract | Unchanged — already CLI-neutral. |

### 2.5 UI/UX Conflicts

The substrate's UX contract is "agent as first-class user" (architecture.md §89). Proposal A's only UX-adjacent surface is the codex-side experience: codex agents currently fail to run the Ralph loop at all (infinite crash). The fix here is mechanical (tools.json profile + adapter); the half-blind-codex problem is owned by Proposal B (knowledge-file restructure). No external user-facing UI changes.

### 2.6 Technical Impact

**`ralph.py` changes:**

- P0 — consecutive-failure backoff (~10 LOC at `ralph.py:1820` exit-code handler, BEFORE the existing `if exit_code == 130: break` at line 1823): `min(60, 2**n)` exponential cap; reset on exit_code=0; **requires `consecutive_failures = 0` initialization at `ralph.py:~1740`** (after `worker = get_current_worker()`, before the iteration `while`-loop at line 1747) — without this, the snippet `NameError`s on first non-zero exit. Exit-code 124 (timeout) now contributes to the backoff counter (intended; named explicitly so reviewers don't surprise-revert). No new halt reason; no schema change.
- P1 — codex profile correctness (`ralph.py:586-596`): updated `flag_map`, `base_args`, `defaults`, `stream_format`. **`-c approval_policy="never"` injection mechanism:** add new `prefix_args` field on `ToolProfile` for fixed token-pair `["-c", "approval_policy=never"]`; current `tool_args` shape splits on `=` and cannot emit `-c key=value` correctly. ~20 LOC.
- P2 — `CodexJsonAdapter` parallel to `ClaudeStreamJsonAdapter` (`ralph.py:1036-1160`): parses codex JSONL events. **Event mapping:** dispatch on `item.started`/`item.updated`/`item.completed` envelopes wrapping `item.type: "command_execution" | "agent_message" | "reasoning"` (NOT a flat `item.command_executed`); `thread.started` → `session_id` capture; `turn.completed.usage.{input_tokens,output_tokens}` → `app.total_input/total_output`; `turn.failed` → log + bump `turn_count`. Capabilities advertised: `{elapsed, turns, tokens, tool_use}` (omits `cost`, `context`); existing render code at `ralph.py:1450, 1469, 1480` correctly produces em-dashes via the existing `else` branches at `:1459, :1475, :1485` (no polymorphism refactor needed — `OutputAdapter` capability-set is the existing seam). ~200 LOC + JSONL fixture for tests. **PR-2 prereq:** empirical capture of `codex exec --json` output; commit fixture at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl` with named consuming test owner before adapter ships.
- P3 — ccusage `--since today` bug fix at **`ralph.py:218`** (line drift corrected from `:215`; `today` is *defined* at line 215, the `subprocess.run` *call* is at line 218): drop `--since` arg; rely on `--active`. Fixes midnight-edge for live fetch. Cache layer (`ralph.py:173-202`) writes a 5-min TTL cache without date partitioning, so post-midnight a stale pre-midnight cache could still serve from `_read_block_cache` for ≤TTL; live-fetch midnight-edge is fixed but cache may serve pre-midnight data for ≤5 min post-midnight (minor; acceptable at 1.0). ~2 LOC.
- P4 — ccusage hide-row when tool != claude. **Sites (6 total):** `ralph.py:215-218` (cache fetch), `ralph.py:1122` ("Cost " stats append in summary), `ralph.py:1308` (interval registration), `ralph.py:1460-1467` (header render), `ralph.py:1482, :1486` (header Cost/em-dash render), `ralph.py:1719` (loop-complete summary). All gated by `if self.config.tool == "claude":`. ~20 LOC across 6 sites. Cleanup nit: `CLAUDE_CODE_TASK_LIST_ID` env at `ralph.py:1760` always set even when `tool != "claude"` — gate or rename to CLI-neutral; out of P0-P5 scope, flag for separate hygiene pass.
- P5 — codex telemetry replacement (CodexJsonAdapter accumulates `turn.completed.usage.{input_tokens,output_tokens}`; header shows `Tokens: in/out`; no cost estimate). Bundled with P2.

**`packages/keel-invariants/`:**

- New `src/hookBarrier.ts` — canonical deny-list as data + `emitClaudeHooks()` + `emitCodexHooks()` emitters + invariant manifest registration of `INV-barrier-hooks-deny-list-canonical` (renamed from invalid `barrier.hooks.deny-list-canonical`).

**Knowledge files (cross-references only — Proposal B owns prose):**

- `INVARIANTS.md` acquires four new manifest IDs (this proposal owns the IDs; prose pinning is in PR A-0 against architecture.md, not knowledge-file restructure).
- `AGENTS.md` / `CLAUDE.md` / `PROMPT_*.md` prose surgery: **out of A's scope.** Proposal B (`docs/agents-first-knowledge-restructure`) owns those edits.

---

## Section 3 — Recommended Approach

**Direct Adjustment** (not Rollback, not MVP Review). Specifically:

- **Codex tier:** First-class — substrate axis `aiCli: "claude" | "codex"`, both Tier-1 implementations, claude as default-emitted choice.
- **Parity bar (JTBD reframe):** "Future-proof multi-CLI substrate with named gaps" — every substrate invariant attempts a codex-side equivalent; where parity is empirically impossible (e.g., codex PreToolUse not intercepting `web_search`/unified-exec), the Defense Layer Coverage Matrix names the gap honestly and L0 (egress) + L2 (manifest) + L3 (halt) catch the residual blast radius. Tier-1 quality on covered surfaces is gated empirically (Story 3.34 promotion gate). The matrix-naming-the-gaps is itself the research output.
- **Tiered permissive default:** Codex profile defaults to `--sandbox=workspace-write -c approval_policy="never"` at 1.0. Permissive (no prompts), hooks alive. Promotes to `--dangerously-bypass-approvals-and-sandbox` after Story 3.34 ships 30 consecutive green nightly bypass-survival runs **AND ≥2 distinct codex versions AND ≥1 chaos-injected deny-verification per week**. Per Murat's risk model: do not promote undocumented security behavior on vibes.
- **Defense Layer Coverage Matrix tells the truth (5-layer + meta).** L0 egress / L1 in-session-hooks (with sub-columns per codex tool surface) / L2 git-manifest / L3 runtime-halt / L4 auth-token+log isolation; M1 prompt-scan as build-time meta. Codex × L1 covered surfaces = empirical-pending until promotion gate fires; codex × `web_search` and unified-exec start as `not-intercepted`. Substrate ships honestly with the gap named.
- **Track-of-PRs sequenced delivery (renumbered A-0..A-9):** **A-0** (corrections-only docs PR — codex parity subset only) lands in parallel with B-0. See Section 5.
- **Scope:** Major. A-0 + downstream PRs require PM (FR/NFR rephrasing) + Architect (5-layer Coverage Matrix + INV ID corrections + halt-enum reaffirmation) + Developer (ralph.py runtime + per-CLI hook emitters) coordination.

**Rationale (in dependency order):**

0. **A-0 corrections-only docs PR** lands first (in parallel with B-0): PRD FR/NFR amendments owned by A (FR3, FR5, FR7, FR14k codex clause, FR40 codex extension, NFR5a tool-surface clause, NFR5b non-deny shape handling, NFR10 single-volume preserve, NFR30, NFR6 Layer-0 citation, Story 2.1 amendment), architecture.md edits (§ tools.json + `prefix_args`, § Substrate-Authorship-Constants + `AI_CLI_SHAPES` + 6-touchpoint checklist, § Substrate Security Posture + 5-layer + meta Defense Coverage Matrix with codex sub-columns), invariant ID corrections (rename `barrier.hooks.deny-list-canonical` → `INV-barrier-hooks-deny-list-canonical`; source-pin `INV-substrate-defense-layers`; remove `CODEX_DOCTOR_REQUIRED` halt reason — replaced by pre-loop pointer error), halt-enum + autonomy-guardrail reaffirmation. **Does NOT include FR14j or knowledge-file contract prose** — those belong to B-0.
1. The infinite-crash bleed must stop next (A-1 is XS) so empirical codex testing can proceed without burning iteration time.
2. Codex must run at all (A-2: profile correctness + adapter + **empirical capture prereq promoted from A-6**) before any parity story can be empirically validated. **A-2 must follow B-1** (Proposal B's PROMPT_*.md de-Clauding) so codex agents read post-restructure prompts when they first run.
3. Epic 2 sequential stories (2.19/2.20/2.21/2.22) + Story 3.34 deliver substrate-invariant parity on covered surfaces in dependency-correct order.

**Effort estimate:**

- A-0 (M): PRD/Architecture corrections (codex parity subset) + INV ID renames + halt-enum reaffirmation + Coverage Matrix shape pin. 1-2 days.
- A-1 (XS): ~10-15 LOC + `consecutive_failures` init + 1 LOC ccusage. ½ day.
- A-2 (S): ~20 LOC profile + `prefix_args` injection mechanism + ~200 LOC adapter (with corrected event mapping) + JSONL fixture + tests + empirical-capture session (1 hour) + ccusage hide-row across 6 sites + telemetry replacement. 2-3 days.
- A-3 (S): 2.19 codex OAuth via `pnpm codex`. 1 day.
- A-4 (XS): 2.10 amendment (codex auth + features-list runtime probe + version probe). ½ day.
- A-5 (S): 2.22 pre-loop pointer probe. 1 day.
- A-6 (M): 2.15 amendment + 2.20 emitCodexHooks. 2-3 days.
- A-7 (M): 2.21 codex PreToolUse hook + non-deny normalizer. 2-3 days.
- A-8 (S): 2.17 amendment (manifest covers `.codex/**`; FR40 codex scan extension). 1 day.
- A-9 (M): Story 3.34 nightly bypass-survival promotion gate. 2-3 days.

**Total elapsed estimate (A only):** ~3 weeks of Ralph build-iterations.

**Risk assessment:**

- **Highest risk:** R-CDX-2 (`--yolo` bypass-survival undocumented + L1 coverage gap). Mitigated by tiered default + hardened promotion gate (30-green + ≥2-version + chaos-injection + canary counter) + Coverage Matrix sub-columns naming `web_search`/unified-exec as `not-intercepted` (relying on L0 egress + L2 manifest + L3 halt). Worst case: codex ships with `--sandbox=workspace-write` permanently and `web_search`/unified-exec uncovered at L1 (caught by L0 egress). Acceptable for substrate posture.
- **Empirical prereq:** Story 2.20 matchers + A-2 adapter event mapping must be re-derived against captured `codex exec --json` output (not docs-derived). Schedule 1-hour capture session before A-2; fixture committed at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl` with named consuming test owner. Otherwise risk shipping adapter against wrong event names AND matchers against wrong tool names.
- **Cross-proposal ordering:** A-2 must land after B-1 (Proposal B's PROMPT_*.md de-Clauding) so codex agents read post-restructure prompts when they first run. If B-1 slips, A-2 can be reordered against partial B progress, but document the dependency in the cross-proposal status.
- **Empty-package dependencies:** `packages/devbox/` (Story 2.1 amendment for codex CLI bake) must not block PR sequence; addressed in Story 2.1 amendment above.

---

## Section 4 — Detailed Change Proposals

### 4.1 Cross-cutting splits A owns (vs. B)

To avoid duplicate edits when A and B land in parallel, the following items are **partially** owned:

- **FR40** — A owns the extension to `.codex/AGENTS.md` + `.codex/hooks.json` + `.codex/hooks/**` cells in the prompt-injection scan list. The AGENTS.md cell is owned by B. Both PRs touch the same FR40 paragraph; A's PR adds the codex-side rows and B's adds the AGENTS.md row. Reviewer note: rebase order should be B-0 first, A-0 second (or merge A-0 into B-0 first if B-0 lands ahead).
- **FR14k** — A owns the codex session-resume defer-to-Growth runtime caveat. The canonical-naming clause (`.ralph/@plan.md` as substrate-invariant crash journal; native CLI task-list APIs as optional convenience mirror) is owned by B.
- **Architecture § Substrate-Authorship-Constants 6-touchpoint checklist** — A owns the constant + checklist itself. Touchpoint #2 ("AGENTS.md fallback prose") is a *reference* in this proposal; B authors the actual prose.

### 4.2 ralph.py runtime fixes (A-1, A-2)

**P0 (A-1):** Consecutive-failure backoff at `ralph.py:~1820` exit-code handler:

```python
# Init at ralph.py:~1740 (after worker = get_current_worker(), before while-loop at :1747):
consecutive_failures = 0

# After non-130 exit (at ralph.py:~1820, BEFORE existing if exit_code == 130 at :1823):
if exit_code != 0 and exit_code != 130:
    consecutive_failures += 1
    backoff = min(60, 2 ** consecutive_failures)
    self.call_from_thread(
        self._log_write,
        Text(f"⚠ {self.config.tool} exited with code {exit_code}; backing off {backoff}s", style="yellow")
    )
    time.sleep(backoff)
elif exit_code == 0:
    consecutive_failures = 0
```

No new halt reason. No schema change. Drops infinite tight-loop on tool-launch failures from "burn the whole iteration block" to "lose ~3 minutes."

**P1 (A-2):** Codex profile correctness at `ralph.py:586-596`:

```python
"codex": ToolProfile(
    name="codex",
    binary="codex",
    base_args=["exec", "--json"],
    prefix_args=["-c", "approval_policy=never"],   # NEW field for fixed -c key=value
    flag_map={
        "model":            "--model",
        "unsafe":           "--dangerously-bypass-approvals-and-sandbox",
        "sandbox":          "--sandbox",
        "ephemeral":        "--ephemeral",
        "skip_git_check":   "--skip-git-repo-check",
    },
    defaults={
        "unsafe": False,                  # tiered: False at 1.0, flips to True after 3.34's 30-green
        "sandbox": "workspace-write",
        "skip_git_check": True,
    },
    stream_format="codex-json",
),
```

**P2 (A-2):** `CodexJsonAdapter` parallel to `ClaudeStreamJsonAdapter` (`ralph.py:1036-1160`). Maps codex JSONL events to TUI capabilities `{elapsed, turns, tokens, tool_use}`. Em-dashes for cost + context-pct (codex emits no cost; `--json` events don't currently expose context-window data).

Event mapping (corrected per empirical capture):
- `thread.started` → session_id captured.
- `turn.started` → no-op.
- `turn.completed` → `turn_count++`; `usage.input_tokens` → `app.total_input`; `usage.output_tokens` → `app.total_output`. Cache fields absent — leave defaults at 0.
- `turn.failed` → log error; bump turn_count.
- `item.started` / `item.updated` / `item.completed` envelopes wrapping `item.type`:
  - `"command_execution"` → tool_use display (`{WRENCH} shell {command}`).
  - `"agent_message"` / `"reasoning"` → markdown render.

**P3 (A-1):** ccusage `--since today` bug fix at **`ralph.py:218`**:

```python
# Before:
result = subprocess.run(
    ["ccusage", "blocks", "--active", "--offline", "--json", "--since", today],
    ...
)
# After:
result = subprocess.run(
    ["ccusage", "blocks", "--active", "--offline", "--json"],
    ...
)
```

Eliminates the midnight-edge bug where the active block disappears around 00:00 because it started "yesterday" by date.

**P4 (A-2):** ccusage hide-row gating across 6 sites — see § 2.6 Technical Impact for full site list.

**P5 (A-2):** Codex telemetry replacement — bundled with P2's `CodexJsonAdapter`. Header row for codex shows `Tokens: in/out` accumulated across iterations; no cost row (em-dash).

### 4.3 PRD edits (A-0)

Per § 2.3 above (codex parity subset only — A does NOT touch FR14j or the knowledge-file contract). New `INV-substrate-defense-layers` invariant pinned in PRD § Implementation Considerations + architecture.md § Substrate Security Posture (5-layer + meta model). PRD changelog entry summarizing the codex-parity escalation.

### 4.4 Architecture edits (A-0, paired with PRD)

Per § 2.4 above. Defense Layer Coverage Matrix added — 5-layer + meta: rows × cells = `{claude, codex} × {L0 egress, L1 in-session-hooks (with codex sub-columns: bash | apply_patch | mcp | unified-exec | web_search | other), L2 git-manifest, L3 runtime-halt, L4 auth-token+log isolation, M1 prompt-scan meta}`; cells: `documented | empirical-pending | not-intercepted | deferred-growth | not-applicable`. § tools.json codex profile fix documented inline (with `prefix_args` field on `ToolProfile` for `-c approval_policy=never` injection). § Substrate-Authorship-Constants gets `AI_CLI_SHAPES` + `HOOK_BARRIER_DENY_LIST` + 6-touchpoint checklist for adding a 3rd shape.

### 4.5 New invariants (A-0 + A-2 + A-6+)

| Invariant ID | sourcePath | Anchors | Description | Story |
|--------------|------------|---------|-------------|-------|
| `INV-substrate-defense-layers` | `_bmad-output/planning-artifacts/architecture.md` | `["INV-substrate-defense-layers", "Defense Layer Coverage Matrix"]` | 5-layer + meta defense model named in PRD + arch (source-pinned, NOT "doc-only" per InvariantSchema requiring sourcePath + contentHash + anchors) | A-0 |
| `INV-barrier-hooks-deny-list-canonical` (renamed from `barrier.hooks.deny-list-canonical` — original failed regex `^INV-[a-z0-9]+(-[a-z0-9]+)+$`) | `packages/keel-invariants/src/hookBarrier.ts` | `["INV-barrier-hooks-deny-list-canonical"]` | Canonical deny-list + per-CLI emitters | 2.15 (amended) |
| `INV-codex-hooks-feature-enabled` | runtime probe (assertion via `codex features list \| grep '^codex_hooks: enabled$'`) | `["INV-codex-hooks-feature-enabled"]` | Substrate hard-fails if `codex_hooks` not enabled in effective feature state when `--tool codex` (runtime probe — NOT literal `[features] codex_hooks = true` TOML presence, which false-fails on default-enabled installs per codex 0.128.0). Re-probed per Ralph iteration spawn (not just devbox boot — host config can drift mid-session). | 2.10 (amended) |
| `INV-codex-hook-secret-denylist` | `.codex/hooks.json` + `.codex/hooks/block-secret-access.sh` | `["INV-codex-hook-secret-denylist"]` | Codex PreToolUse hook + deny-rules; matchers use actual codex tool names (`Bash`, `apply_patch`, `mcp__*`) | 2.21 |
| (existing) `INV-claude-hook-secret-denylist` | `.claude/settings.json` + `.claude/hooks/block-secret-access.sh` | `["INV-claude-hook-secret-denylist"]` | Unchanged | 2.15/2.16 (existing) |

**Note:** All invariant entries in A-0 require `contentHash` (sha256) + manifest registration via `packages/keel-invariants/src/invariants.manifest.ts`. No "doc-only" framing; the InvariantSchema regex + required-fields contract is the constraint.

### 4.6 sprint-status.yaml updates

Pending Tthew approval — to be applied during workflow Step 5 finalization. Proposed delta (A-only, sequential numbering 2.19/2.20/2.21/2.22 since `sprint-status.yaml:180` already pins `2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix: done`):

```yaml
# Epic 2 amendments:
2-1-... (extended scope: bake codex CLI in toolchain provenance)
2-10-prerequisite-check-... (extended scope, no rename — codex auth + runtime feature probe + version probe)
2-15-... (renamed: hook-barrier-emission-per-cli)
2-16-... (renamed: pretooluse-hook-implementation-per-cli)
2-17-... (extended scope, no rename — manifest covers .codex/** + non-deny shape handling)
2-19-codex-oauth-via-pnpm-codex: backlog                          # NEW
2-20-codex-hooks-emitter: backlog                                 # NEW
2-21-codex-pretooluse-hook: backlog                               # NEW
2-22-codex-pre-loop-probe: backlog                                # NEW (reframed from halt-with-CODEX_DOCTOR_REQUIRED to pre-loop pointer error since `keel doctor` does not exist + closed halt enum forbids new external-blocking reasons)

# Epic 3 amendments:
3-2-... (rephrased + pidfile lock — no rename)
3-10-... (reframed crash-journal contract — codex session-resume defer-to-Growth)
3-34-nightly-yolo-bypass-survival-promotion-gate: backlog         # NEW (with positive+negative+canary controls + ≥2-version + chaos-injection threshold)
```

---

## Section 5 — Implementation Handoff

### Scope classification: **Major**

Requires PM (FR/NFR rephrasing in PRD), Architect (contract design + Defense Layer Coverage Matrix in architecture.md), Developer (ralph.py runtime + per-CLI hook emitters + new stories) coordination.

### Recommended PR sequence (renumbered A-0..A-9; A-only)

| PR | Size | Contents | Depends on | Unblocks |
|----|------|----------|------------|----------|
| **A-0** | M (~1-2 days) | **Corrections-only docs PR (codex parity subset)** — PRD amendments owned by A (FR3, FR5, FR7, FR14k codex clause, FR40 codex extension, NFR5a tool-surface clause, NFR5b non-deny shape handling, NFR10 single-volume preserve, NFR30, NFR6 Layer-0 citation, Story 2.1 toolchain); architecture.md edits (§ tools.json + `prefix_args` mechanism, § Substrate-Authorship-Constants + 6-touchpoint checklist, § Substrate Security Posture + 5-layer + meta Defense Coverage Matrix with codex sub-columns); INV ID corrections (rename `barrier.hooks.deny-list-canonical` → `INV-barrier-hooks-deny-list-canonical`; source-pin `INV-substrate-defense-layers` to architecture.md with sourcePath+contentHash+anchors; remove `CODEX_DOCTOR_REQUIRED` halt reason — replaced by pre-loop pointer error); halt-enum + autonomy-guardrail reaffirmation. **Does NOT include FR14j or knowledge-file contract prose** — those go to B-0. | None — standalone docs PR; lands in **parallel with B-0** | All downstream A PRs cite already-pinned PRD/arch language |
| **A-1** | XS (~½ day) | ralph.py P0 backoff (insert at `ralph.py:1820` before existing 1823; **`consecutive_failures = 0` init at `ralph.py:~1740`**); ccusage `--since today` bug fix at `ralph.py:218`. Original PR-1. | A-0 (no behavioral dependency, but cleaner if language already pinned); can run in parallel with B-1 | Empirical codex testing without burning iteration time |
| **A-2** | S (~2-3 days) | ralph.py P1 codex profile correctness (with `prefix_args` field for `-c approval_policy=never`); P2 `CodexJsonAdapter` (with corrected `item.started`/`item.completed` envelope dispatch); **empirical capture prereq** — capture `codex exec --json` output, commit fixture at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl`, name consuming test owner; P4 ccusage hide-row across all 6 sites; P5 codex telemetry replacement. Original PR-2. | A-1 (clean exit-code handling); **B-1 (must follow Proposal B's PROMPT_*.md de-Clauding so codex reads post-restructure prompts when first running)**; empirical capture session | "Codex actually runs" — Ralph loop functional under `--tool codex` with `--sandbox=workspace-write` permissive default |
| **A-3** | S (~1 day) | Story 2.19: `pnpm codex` codex OAuth via `codex login`; tokens at `/home/dev/.codex/` inside the existing single named `/home/dev/` volume (NFR10 single-volume preserved). Original PR-5. | Epic 2 Story 2.1 amendment (bake codex CLI in toolchain) | Codex auth in devbox |
| **A-4** | XS (~½ day) | Story 2.10 amendment: prereq check extends to codex — auth probe + `codex features list` runtime probe (NOT TOML literal) + `codex --version` minimum-version check. Original PR-6. | A-3 | Codex prereq gating |
| **A-5** | XS (~½ day) | Story 2.22: per-CLI **pre-loop pointer error** in `ralph.py` codex-spawn path verifying (a) auth, (b) `codex_hooks=enabled`, (c) version, (d) deny-list smoke with canary counter; sentinel content = sha256 of `.codex/hooks.json` + version + matchers; pre-commit hook rejects committed sentinel. **NOT a halt reason** (`CODEX_DOCTOR_REQUIRED` would violate closed halt-enum + autonomy guardrail per `INVARIANTS.md:47`); fails fast pre-iteration with diagnostic message. `keel doctor` CLI does not exist; this is a `ralph.py`-resident probe. Original PR-7. | A-2, A-4 | Per-CLI pre-loop probe pattern shipped |
| **A-6** | M (~2-3 days) | Story 2.15 amendment + Story 2.20: canonical `packages/keel-invariants/src/hookBarrier.ts` data + `emitClaudeHooks()` + `emitCodexHooks()` (matchers using actual codex names `Bash`, `apply_patch`, `mcp__*`); INVARIANTS.md + manifest registers `INV-barrier-hooks-deny-list-canonical` (renamed from invalid `barrier.hooks.deny-list-canonical`) + `INV-codex-hook-secret-denylist` with sourcePath/contentHash/anchors. Original PR-8. | A-0 (canonical contract pinned); empirical fixture committed in A-2 | Hook-barrier deny-list canonical |
| **A-7** | M (~2-3 days) | Story 2.21: `.codex/hooks/block-secret-access.sh` PreToolUse hook + deny-signal normalizer with **enumerated non-deny shape handling** (exit-2 + JSON `permissionDecision: deny` increment counter; process-fail / stdout-empty / hooks-disabled-silent-allow / partial-JSON / hooks-config-absent → fail-closed SECURITY_CRITICAL halt). Original PR-9. | A-6 | Codex in-session hook barrier shipped (empirical-pending coverage on intercepted surfaces; `web_search`/unified-exec marked `not-intercepted` in matrix) |
| **A-8** | S (~1 day) | Story 2.17 amendment: git-layer manifest + sync gate covers `.codex/hooks.json`, `.codex/hooks/**`, `.codex/AGENTS.md`; NFR5b 3-strike halt counter handles all non-deny shapes (per A-7); FR40 prompt-scan extends to `.codex/**` (the AGENTS.md cell is owned by B). Original PR-10. | A-7 | Bypass-resistance covers both CLIs |
| **A-9** | M (~2-3 days) | Story 3.34: nightly `--yolo` bypass-survival CI workflow with **positive + negative + canary controls** (mandatory); promotion gate **30 green + ≥2 codex versions + ≥1 weekly chaos-injection** (hardened); **bot-PR opener** (NOT direct push) flips codex profile default `unsafe: False → True` with required human approval; demote-trigger conditions pinned. Original PR-11. | A-7, A-8 | Defense Layer Coverage Matrix codex × in-session-hooks (intercepted surfaces) cell promotes empirical-pending → documented |

**Total elapsed estimate (A only):** ~3 weeks of Ralph build-iterations.

**Cross-proposal ordering (A vs B):**
- B-0 ∥ A-0 (parallel docs-only foundation PRs)
- B-1 ∥ A-1 (low blast-radius, any order)
- A-2 must follow B-1 (so codex agents read post-restructure AGENTS.md when first running)
- A-3..A-9 sequential per dependency chain above

### Deliverables (A only)

- This Sprint Change Proposal at `_bmad-output/planning-artifacts/sprint-change-proposal-2026-05-05-codex-tier1.md` ✓ (this file)
- 10 PRs (A-0..A-9) delivered in dependency order
- PRD changelog entry for the codex-parity escalation (codex parity subset only)
- Updated `_bmad-output/implementation-artifacts/sprint-status.yaml` reflecting sequential numbering 2.19/2.20/2.21/2.22 + 3.34
- `INVARIANTS.md` registers four new manifest IDs (with proper regex-conformant names + sourcePath/contentHash/anchors)
- `docs/install/codex.md` (new) documenting codex OAuth + `codex features list` probe + `OPENAI_API_KEY` headless escape hatch
- `docs/ralph.md` codex-aware updates (getting-started flow + ralph.py architecture diagram for codex profile)

### Success criteria

- **A-0:** PRD validation passes; INVARIANTS.md sync-gate green for new IDs; 5-layer + meta Defense Coverage Matrix reviewed by John (PM) + Winston (Architect) without scope objections; halt-enum reaffirmed; A-0's text does NOT collide with B-0's FR14j prose.
- **A-1:** Ralph loop running `--tool codex` no longer infinite-loops on tool-launch failures; ccusage row shows non-zero data at 00:30 local.
- **A-2:** `uv run ralph.py build --tool codex` completes one iteration successfully; CodexJsonAdapter (with corrected event mapping) populates header tokens correctly; em-dashes render gracefully for cost/context; committed JSONL fixture validated by consuming test.
- **A-9:** 30 consecutive nightly green bypass-survival runs across ≥2 codex versions with ≥1 weekly chaos-injection trigger keel-bot to open promotion PR (human-approved); Defense Layer Coverage Matrix codex × L1 (intercepted surfaces) cell flips to "documented"; not-intercepted surfaces (`web_search`/unified-exec) remain marked honestly.

### Routing

- **A-0** (PRD + Architecture corrections, codex subset) → Product Manager (John) + System Architect (Winston) — **must review BEFORE A-2 ships**.
- **A-1, A-2** (ralph.py runtime) → Developer (Amelia) for direct implementation.
- **A-3 through A-9** (Epic 2 + Epic 3 stories) → Developer (Amelia) per BMad story-execution flow (`/bmad-create-story` → `/bmad-dev-story` → `/bmad-code-review`).

---

## Section 6 — Open items requiring Tthew sign-off

| Item | Recommendation | Required for proposal approval? |
|------|----------------|--------------------------------|
| **JTBD reframe (A's anchor)** | "Future-proof multi-CLI substrate with named gaps." The verified PreToolUse coverage gap (`web_search`/unified-exec not intercepted) means substrate-invariant parity has a named ceiling visible only from the codex side. The honest framing is that the substrate makes the parity attempt, names where parity is empirically impossible, and ships the 5-layer + meta Defense Coverage Matrix as the truth-telling artefact. This subsumes research-richness (the matrix IS the research output) without overclaiming durability. Affects PRD prose only. | Recommended — proposal ships with revised framing pinned in A-0. |
| **Story numbering convention** | **Sequential 2.19/2.20/2.21/2.22** (NOT 2.18-2.21 — original 2.18 conflicts with `2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix: done` already in `_bmad-output/implementation-artifacts/sprint-status.yaml:180`). Twin-suffix-b has no precedent. | Recommended — applied throughout this proposal. |
| **Empirical capture prereq for A-2** | 1-hour capture session to grep actual event names + tool surface from `codex exec --json` output (NOT docs-derived). Commit fixture at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl` with named consuming test owner. Must happen BEFORE A-2 (was originally PR-8 prereq); affects both adapter event mapping + Story 2.20 matchers. | Required — schedule before A-2 kickoff. |
| **R-CDX-2 personal-evidence override hardened** | If Tthew has already locally tested whether codex `[[hooks.PreToolUse]]` survives `--dangerously-bypass-approvals-and-sandbox`, override is **only honored with committed transcript artifact** at `_bmad-output/research/codex-yolo-survival-<date>.jsonl` showing positive + negative + canary controls all passing, with codex version + commit hash. Without recorded reproducible evidence, ship the tiered default + 30-green + ≥2-version + chaos-injection promotion gate. | Optional — without committed transcript, defaults to hardened gate. |
| **`docs/install/codex.md` content** | New file documenting codex OAuth flow + `codex features list` runtime probe (NOT TOML literal) + minimum codex version + `OPENAI_API_KEY` headless escape hatch. Sized in A-3. | No sign-off needed — uncontroversial. |

---

## Approval

- [ ] **Tthew** — approves Sprint Change Proposal A (Codex First-Class Tier-1 Substrate) for implementation
- [ ] (Optional) JTBD answer pinned: ____________________
- [ ] (Optional) R-CDX-2 personal evidence: ☐ already tested green ☐ not tested → tier per proposal
- [ ] Companion Proposal B (`docs/agents-first-knowledge-restructure`) reviewed alongside this one (recommended — A-2 depends on B-1)

Once approved, the workflow proceeds to **Step 5 (finalize + route)** and **Step 6 (workflow completion)**, including the `sprint-status.yaml` update from § 4.6.

---

## Provenance

This proposal was decomposed from PR #237's bundled sprint change proposal (`_bmad-output/planning-artifacts/sprint-change-proposal-2026-05-04.md`, 571 lines) at the user's request. **Decomposition consensus reached across:**

- **Claude orchestrator** (initiating session)
- **Opus 4.7 sub-agent** (parallel review of PR #237)
- **Codex sparring rounds** (2 rounds via `codex exec`, session `019df9bb-276d-7643-ad9e-14ae0fdc8f2b`) — codex caught and corrected the stale `2.18` numbering against `sprint-status.yaml:180` (now 2.19/2.20/2.21/2.22).

**Inheritance from original (PR #237) provenance:** the original artifact was navigated via `/bmad-correct-course` with three party-mode rounds (Murat/Amelia/Winston/John/Paige/Sally + cross-model echoes on `gpt-5.5 xhigh`), then revised post-multi-reviewer-audit (4 sub-agents + 2 codex instances over 3 rounds) reaching APPROVE-WITH-MAJOR-CORRECTIONS verdict. The codex parity scope (this Proposal A) preserves all 7 critical + 9 high + 13 medium + 3 low corrections from that audit relevant to Tier-1 substrate parity.

**Supersedes original PR #237 PR-0** alongside companion proposal Proposal B. Reviewers should treat the bundled foundation artifact (`sprint-change-proposal-2026-05-04.md`) as no longer authoritative once A-0 + B-0 land.

**Guardrails applied during decomposition:**
1. No knowledge-file prose surgery (AGENTS.md / CLAUDE.md / PROMPT_*.md) beyond minimal references required by architecture/invariant parity. B owns the prose.
2. Original PR-0 explicitly marked as superseded by A-0 + B-0.
3. Cross-proposal ordering (A-2 must follow B-1) pinned in § 5 PR sequence + § 3 Risk assessment + § 5 Cross-proposal ordering.
4. FR40 + FR14k cross-cutting splits owned (codex-only cells / clauses) — see § 4.1.
