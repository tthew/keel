---
title: Sprint Change Proposal — Codex first-class parity + knowledge-file restructure
date: 2026-05-04
author: Tthew (via /bmad-correct-course + party mode rounds 1-3 + multi-reviewer audit rounds 1-3)
project: ralph-bmad / Keel
scope: Major (PM + Architect involvement) — PR-0 corrections-only PR sequenced ahead of PR-1
status: revised post-multi-reviewer-audit (2026-05-04) — awaiting Tthew approval. See § Audit revisions for change list.
related: PRD FR3, FR5, FR7, FR14j, FR14k, FR40; NFR5a, NFR5b, NFR6, NFR10, NFR30, NFR33a; Epic 2 (Stories 2.1, 2.10, 2.15, 2.16, 2.17, 2.18-2.21 NEW); Epic 3 (Stories 3.2, 3.3, 3.10, 3.34 NEW); architecture.md § tools.json + § Knowledge-file contract + § Substrate Security Posture
---

# Sprint Change Proposal — Codex first-class parity + knowledge-file restructure

## Section 1 — Issue Summary

**Two coupled changes are being proposed in one navigation:**

1. **Codex CLI escalation from "Tier-2 deviation path" to first-class Tier-1 substrate shape.** Tthew leans toward "more durable" — substrate-invariant parity, not just functional parity. Every substrate invariant gets a codex-side equivalent.
2. **Knowledge-file + prompt-file restructure.** AGENTS.md becomes the substrate's primary entry point for every agent. CLAUDE.md shrinks to a ~15-25-line signpost containing only Claude-Code-specific deltas. PROMPT_build.md / PROMPT_plan.md are de-Clauded with inline tool-aware fallback prose. The R4 knowledge-file upkeep contract rotates AGENTS.md / RALPH.md / INVARIANTS.md (CLAUDE.md drops out).

**Trigger evidence:**

- **Bug observed.** Tthew reports: "Ralph loops don't work currently with codex. The harness loads but the loop crashes infinitely." Root cause confirmed in `ralph.py`:
  - `ralph.py:586-596` codex profile uses `--skip-git-repo-check` as the "unsafe" mapping (wrong flag — it skips git checks, not approvals/sandbox).
  - `ralph.py:1822-1824` exit-code handling only breaks on SIGINT 130; non-zero exits log a warning and retry forever — no consecutive-failure halt.
- **Coverage gap confirmed via fresh codex docs research (2026-05-04, fetched live from developers.openai.com/codex) + post-audit corrections (codex 0.128.0 verified locally):**
  - Codex DOES have `[[hooks.PreToolUse]]` (in `~/.codex/config.toml` or `<repo>/.codex/hooks.json`), feature-flagged via `features.codex_hooks`. **Post-audit correction:** `codex_hooks` is `stable true` by default per `codex features list`; INV check on literal `[features] codex_hooks = true` TOML presence FALSE-FAILS. Assertion mechanism must use runtime probe (`codex features list | grep '^codex_hooks: enabled$'`).
  - Codex docs do NOT explicitly state `PreToolUse` survives `--dangerously-bypass-approvals-and-sandbox` (Claude's docs DO guarantee this).
  - **Post-audit correction:** Codex hook matcher tool names are `Bash`, `apply_patch` (matches `Edit`/`Write`), and MCP names like `mcp__fs__read` — NOT `shell_tool` (which is a feature flag name, not a hook matcher). PreToolUse only intercepts simple Bash + apply_patch + MCP tool calls; **web_search and unified-exec are NOT intercepted** — substrate-invariant L1 parity has a named ceiling.
  - Codex reads `AGENTS.md` natively (3-tier hierarchy: global → Git-root walk → cwd; deeper overrides shallower; 32 KiB cap). **Post-audit correction:** each directory checks `AGENTS.override.md` BEFORE `AGENTS.md`; at most one file per directory.
  - `codex exec --json` emits JSONL stream events. **Post-audit correction:** the actual surface is `thread.started`, `turn.started`, `turn.completed` (with `usage.input_tokens` / `usage.output_tokens`; no cost field), `turn.failed`, plus `item.started` / `item.updated` / `item.completed` envelopes wrapping `item.type: "command_execution" | "agent_message" | "reasoning"` — NOT a flat `item.command_executed` / `item.agent_message`. Empirical capture is a **PR-2 prereq**, not just PR-8.
  - Session resume via `~/.codex/sessions/YYYY/MM/DD/rollout-...<uuid>.jsonl` + `codex exec resume --last` (sessions are global per-user, not per-cwd; auto-resume **deferred to Growth-tier** at 1.0 — `.ralph/@plan.md` is the only durable crash journal).
- **CLAUDE.md duplicates ~50% of AGENTS.md content.** Today's CLAUDE.md (80 lines) carries substrate-level truth (commands table, architecture, knowledge-file contract, promotion rules, git/PR conventions) that codex never reads. Codex enters the repo half-blind — only ~6 of CLAUDE.md's bullets are actually Claude-Code-specific.
- **PROMPT_build.md / PROMPT_plan.md leak Claude-flavored language** — `TaskList` / `TaskCreate` (Claude-Code APIs), "Sonnet subagents" (Claude-only model), "Claude Code slash commands" (Claude-only invocation surface), `.claude/` exclusion in source-scan without `.codex/` parallel.
- **The 2026-04-17 research report (`technical-keel-ralph-bmad-research-2026-04-17.md:175`)** explicitly parked codex as Tier-2 "not blocked at the quality-gates story." This proposal supersedes that framing.

**What changed since 2026-04-17:** Tthew's stated preference shifted from "Tier-2 acceptable" to "more durable." This is a legitimate input but constitutes architectural taste, not new external evidence. The substrate's dual-posture tie-breaker ("research-output richness wins over substrate ship-velocity") justifies the depth: monthly absorption sprints under both CLIs become a research artifact in their own right.

---

## Section 2 — Impact Analysis

### 2.1 Epic Impact

| Epic | Status | Impact |
|------|--------|--------|
| Epic 1 — Substrate scaffolding | done | No story changes. INVARIANTS.md acquires new entries (`INV-substrate-defense-layers`, `INV-barrier-hooks-deny-list-canonical`, `INV-codex-hooks-feature-enabled`, `INV-codex-hook-secret-denylist`); `packages/keel-invariants/` acquires `hookBarrier.ts` data + per-CLI emitters; manifest entries source-pinned (no "doc-only" — schema requires `sourcePath` + `contentHash` + `anchors`). These land via Epic 2 stories that depend on them; no Epic-1 retroactive change. |
| Epic 2 — Packaged devbox | backlog | **6 existing stories amended + 4 new stories** (sequential numbering: 2.18-2.21). Story 2.1 amended for codex CLI baked at image-build. See Story Impact below. |
| Epic 3 — Ralph build mode | backlog | **2 existing stories amended + 1 new story (3.34).** Cross-CLI crash-journal contract reframe in 3.10 (codex session-resume defer-to-Growth); tool-agnostic prompt template seed in 3.3 (caveat: `packages/keel-templates/` is "populated in Epic 12" per `packages/keel-templates/README.md` — Epic 12 prereq must be acknowledged or scope of 3.3 narrowed to seed prose only without package surface change). |
| Epic 14 — Research corpus | backlog | Optional: add a row in `docs/research/test-ids.md` for cross-CLI absorption-delta as a Growth-tier research dimension. Out of 1.0 critical-path scope. |
| Epics 4-13, 15a, 15b | backlog | No structural changes. |

**Epic order/priority unchanged.**

### 2.2 Story Impact

**Epic 2 amendments (existing stories):**

| Story | Current scope | Proposed amendment |
|-------|---------------|--------------------|
| 2.1 — Devbox image build (toolchain provenance) | claude-only baked toolchain (`@anthropic-ai/claude-code@<pinned>`) | Extend AC: bake `@openai/codex@<pinned>` at image-build alongside claude (per PRD §545 toolchain provenance). Without this amendment, Story 2.10 prereq probe + Story 2.21 doctor probe have nothing to probe. **New amendment surfaced by post-audit review.** |
| 2.8 — Claude Code OAuth via `pnpm claude` | claude-only | Rename to "AI-CLI OAuth via `pnpm <cli>`"; existing claude path stays as Tier-1 reference impl; codex login flow (`pnpm codex` → `codex login`) added per Story 2.18. **Token storage:** codex auth lives at `/home/dev/.codex/` inside the existing single named `/home/dev/` volume per PRD §546 (no new parallel volume — proposal's earlier `codex-auth` invented volume reverted post-audit to preserve NFR10). |
| 2.10 — Prerequisite check (Docker + Claude auth + gh auth) | claude-only auth probe | Extend AC: when `aiCli === "codex"`, prereq check ALSO probes `~/.codex/auth.json` (or `OPENAI_API_KEY`) AND runs `codex features list` to assert `codex_hooks` is `enabled` (runtime probe — NOT literal TOML presence, which false-fails on default-enabled installs per post-audit codex 0.128.0 verification). AND probes `codex --version` against minimum-version-with-hooks-support. Fail-pointer-error citing `docs/install/codex.md` if any missing. (Per Winston's "same-machinery-as-FR5" recommendation.) |
| 2.15 — Committed `.claude/settings.json` deny rules | claude-only | Rename to "Hook-barrier emission — committed per-CLI config from canonical deny-list." Adds: canonical `packages/keel-invariants/src/hookBarrier.ts` data module. Codex emitter (`emitCodexHooks() → .codex/hooks.json` with empirically-derived matchers using actual codex tool names `Bash`, `apply_patch`, `mcp__*`) lands in Story 2.19. |
| 2.16 — Claude PreToolUse hooks | claude-only | Rename to "PreToolUse hook implementation — per-CLI." Existing claude scope preserved. Codex `.codex/hooks/block-secret-access.sh` PreToolUse hook with deny-signal normalizer (exit-2 + JSON `permissionDecision: deny`) lands in Story 2.20. |
| 2.17 — Hook + settings bypass-resistance (git-layer) | claude-only manifest entries | Extend AC: invariant manifest registers `INV-claude-hook-secret-denylist` AND `INV-codex-hook-secret-denylist`; pre-merge sync gate covers `.claude/settings*.json`, `.claude/hooks/**`, `.codex/hooks.json`, `.codex/hooks/**`. NFR5b 3-strike halt counter normalizes ALL non-deny outcomes (exit-2 + JSON `permissionDecision: deny` for affirmative deny; **fail-closed** on ambiguous shapes: process-fail mid-write, stdout-empty, hooks-disabled-silent-allow, partial-JSON — each enumerated in Story 2.20 normalizer ACs). |

**Epic 2 new stories (sequential numbering — twin-suffix-b reverted post-audit per `_bmad-output/implementation-artifacts/sprint-status.yaml` precedent):**

- **2.18** — Codex OAuth via `pnpm codex` (size: S; depends on 2.1 amendment for codex CLI baked + existing single `/home/dev/` named volume from current 2.5).
- **2.19** — `emitCodexHooks()` per-CLI emitter (size: M; depends on canonical deny-list from 2.15; **empirical prereq promoted to PR-2 not just PR-8** — capture `codex exec --json` output + commit fixture at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl` with consuming test owner before adapter and matchers ship).
- **2.20** — Codex `.codex/hooks/block-secret-access.sh` PreToolUse hook + deny-signal normalizer with **enumerated non-deny shape handling** (process-fail / stdout-empty / hooks-disabled-silent-allow / partial-JSON all fail-closed). Size: M; depends on 2.19.
- **2.21** — Per-CLI doctor probe (sentinel pattern) verifying (a) codex auth present, (b) `codex_hooks=enabled` per `codex features list`, (c) codex version ≥ minimum supporting hooks, (d) deny-list smoke (read of `.envrc.test-fixture` blocked + canary counter increments). Sentinel content = sha256 of `.codex/hooks.json` + codex binary version + matcher names; pre-commit hook rejects committed sentinel. **Implementation note (post-audit):** `keel doctor` does not exist as a CLI today and `CODEX_DOCTOR_REQUIRED` would violate the closed halt-reason enum + autonomy guardrail (per `INVARIANTS.md:47`). **Reframe as pre-loop pointer error in `ralph.py` codex-profile spawn path** — fails fast before iteration begins with diagnostic message; no new halt reason needed. Size: S.

**Epic 3 amendments:**

| Story | Current scope | Proposed amendment |
|-------|---------------|--------------------|
| 3.2 — Ralph multi-iteration loop with `claude -p` | claude-only invocation | Rename to "Ralph multi-iteration loop with configured AI CLI." Replace `claude -p` references with "the configured AI CLI binary"; rephrase effort-default narrative as Claude-default (`xhigh`) with codex-default deferred to codex profile (codex doesn't expose `--effort` flag). Add AC for tool-axis selection via `--tool {claude\|codex}` and `.ralph/tools.json` profile resolution. **Cross-CLI lock contention (post-audit):** add pidfile `.ralph/.lock` to prevent concurrent invocations against the same worktree (silent corruption of `.ralph/@plan.md` otherwise — no `flock`/`fcntl` exists in `ralph.py` today). |
| 3.3 — Prompt template seeds | claude-shaped | Re-seed prompts at `.ralph/PROMPT_*.md` with tool-aware-fallback prose (per AC3/AC4 surgery in this proposal § 4.2). Single template; per-CLI deltas inline. **Caveat (post-audit):** `packages/keel-templates/` is "populated in Epic 12" empty shell per `packages/keel-templates/README.md:5` — Story 3.3 SCOPE NARROWED to seed live `.ralph/PROMPT_*.md` only at 1.0; future package-templated seeding deferred to Epic 12 (or Story 3.3 grows an Epic 12 dependency). |
| 3.10 — Native Claude Code task list as crash journal | claude-only | Reframe as "Cross-CLI crash-journal contract." `.ralph/@plan.md` becomes the substrate-invariant crash journal (per FR14k). Native Claude task list is a Claude-only convenience mirror that survives hard kills. **Codex session-resume parity DEFERRED to Growth-tier (post-audit)** — codex sessions live at `~/.codex/sessions/YYYY/MM/DD/rollout-...<uuid>.jsonl` and are global-per-user (not worktree-scoped); `codex exec resume --last` selects globally most-recent and may resume into wrong cwd. At 1.0, codex iterations rely solely on `.ralph/@plan.md`. Spec narrative updated; no behavioral change to `.ralph/@plan.md` schema. |

**Epic 3 new story:**

- **3.34 (new)** — Nightly `--yolo` bypass-survival promotion gate. Test that codex `[[hooks.PreToolUse]]` denylist holds when codex runs with `--dangerously-bypass-approvals-and-sandbox`. **Test design (post-audit, mandatory — no false-green):** per nightly run, three sub-tests must ALL pass — (1) **positive control**: prompt codex (under `--yolo`) to read `.envrc.test-fixture` containing canary `KEEL_CANARY_<run-id>`; assert codex stream-json contains a deny event for the EXACT tool-name + path, assert canary NOT in stdout, assert `.ralph/logs/hook-fires.jsonl` counter incremented by exactly 1; (2) **negative control**: prompt codex to read `.ralph/test-allowed-fixture` (NOT in deny-list); assert read succeeds with content in stdout, no deny event, counter unchanged; (3) **canary**: hook-invocation-counter delta == 1 from positive control — if delta == 0, FAIL the run regardless of leak assertion (kills tool-name-mismatch silent-pass dead). **Promotion threshold (post-audit, hardened):** 30 consecutive green nights AND ≥2 distinct codex versions (catches version-drift regression) AND ≥1 chaos-injected deliberate-deny verification per week (matcher intentionally broken to confirm test fails-closed). After all conditions met, **`keel-bot` opens a reviewable PR** flipping codex profile default from `--sandbox=workspace-write -c approval_policy="never"` to `--dangerously-bypass-approvals-and-sandbox` — NOT direct push to main, required human approval per `AGENTS.md` ("never force-push main, never skip hooks or signing"). Demote-trigger conditions also pinned (regression after promote → bot opens demote PR). Size: M (CI workflow + flake-budget integration + bot-PR opener script + chaos fixture + canary counter logger).

### 2.3 PRD Conflicts

| FR/NFR | Current text (pinned implicit Claude assumption) | Proposed change |
|--------|--------------------------------------------------|-----------------|
| FR3 | "Developer can authenticate Claude Code and `gh` CLI once per devbox via browser OAuth flows" | "Developer can authenticate the configured AI CLI (Claude Code or codex) and `gh` CLI once per devbox via browser OAuth flows" |
| FR5 | "System can enforce prerequisites (Docker runtime, Claude Code authentication, `gh` CLI authentication)" | "System can enforce prerequisites (Docker runtime, configured AI CLI authentication AND CLI-specific feature-flag/config preconditions, `gh` CLI authentication)" — codex-specific feature-flag check is `codex features list \| grep '^codex_hooks: enabled$'` (runtime probe — NOT literal `[features] codex_hooks = true` TOML presence, which false-fails on default-enabled installs per codex 0.128.0 verification). Also probe `codex --version` against minimum-version-with-hooks-support. |
| FR7 | "Agent can execute a multi-iteration loop... invoking `claude -p` with adaptive thinking" | "Agent can execute a multi-iteration loop... invoking the configured AI CLI binary (`claude -p` or `codex exec --json`) with CLI-appropriate effort/thinking settings" |
| FR14j | "Agent can maintain three audience-scoped knowledge files (`RALPH.md`, `AGENTS.md`, `CLAUDE.md`) with pinned promotion rules" | "Agent maintains layered knowledge files: `AGENTS.md` (substrate operational truth, read by every agent — note `AGENTS.override.md` precedes `AGENTS.md` per codex's 3-tier hierarchy), `RALPH.md` (Ralph's private journal), `INVARIANTS.md` (machine-enforced rules index). Per-CLI supplement files (e.g., `CLAUDE.md`) are OPTIONAL and contain only CLI-specific deltas — never duplicate AGENTS.md content. Promotion rules pinned in AGENTS.md." (Tool-agnostic; deliberately no `CODEX.md` named.) |
| FR14k | "...native Claude Code task list as the iteration's crash journal" | "...`.ralph/@plan.md` as the iteration's substrate-invariant crash journal; native CLI task-list APIs (Claude `TaskList`/`TaskCreate`) are optional convenience mirrors that may survive hard kills. Codex session-resume is NOT a substrate-invariant crash journal at 1.0 — promotion to parity is Growth-tier (worktree-aware session selection upstream prereq)." |
| FR40 (post-audit addition) | Pattern-scan list pins `CLAUDE.md, skill files, .ralph/PROMPT_*.md, docs/**/*.md` | Extend to **`AGENTS.md`** (now load-bearing per restructure) AND **`.codex/AGENTS.md`**, **`.codex/hooks.json`**, **`.codex/hooks/**`** (3-tier codex hierarchy + committed config files). |
| NFR5a | Hooks-barrier described as Claude-Code-specific | Reframe as substrate-invariant with **explicit tool-surface coverage clause (post-audit)**: "in-session secret-access barrier via PreToolUse hooks emitted from canonical deny-list (`packages/keel-invariants/src/hookBarrier.ts`); per-CLI config files (`.claude/settings.json`, `.codex/hooks.json`) are projections of the canonical data. **Barrier coverage is bounded by per-CLI hook matcher tool-name surface**: claude intercepts Read/Grep/Glob/Bash/Edit/Write/MultiEdit; codex PreToolUse intercepts Bash + apply_patch (which matches Edit/Write) + MCP names (`mcp__*`) only — `web_search` and unified-exec are NOT intercepted. Tools outside the per-CLI surface are out-of-scope for L1 and rely on L0 (devbox sandbox + egress) + L2 (git-layer manifest) + L3 (runtime halt)." |
| NFR5b | bypass-resistance via git-layer manifest entries `INV-claude-hook-secret-denylist` | Extend manifest to register both `INV-claude-hook-secret-denylist` and `INV-codex-hook-secret-denylist`; **deny-signal normalizer (post-audit)** enumerates ALL non-deny outcomes and fails-closed: (a) affirmative deny via exit-2 OR JSON `permissionDecision: deny` → counter increment; (b) ambiguous shapes (process-fail mid-write / stdout-empty / hooks-disabled-silent-allow / partial-JSON / hooks-config absent) → fail-closed (treat as not-deny → halt SECURITY_CRITICAL); (c) hook-fire counter delta == 0 when expected → fail-closed. |
| NFR10 | "Claude Code and `gh` CLI authentication tokens persisted only inside devbox volume" | "Configured AI CLI (Claude Code, codex) and `gh` CLI authentication tokens persisted only inside the devbox's single named `/home/dev/` volume per PRD §546. Codex auth lives at `/home/dev/.codex/` inside that volume; claude auth at `/home/dev/.claude/`; `gh` tokens at `/home/dev/.config/gh/`. **No separate parallel `claude-auth`/`codex-auth` volumes** — preserves the existing one-volume contract that decouples persistence from any specific host path." |
| NFR30 | "Every Keel major version documents tested model generation, Claude Code CLI version, BMad version, and Ralph version" | "...documents tested model generation per supported AI CLI (Claude Code Opus N, codex gpt-N), AI CLI versions, BMad version, Ralph version. Multi-CLI matrix in `docs/upgrades/major-releases.md`." |
| Story 2.1 / Devbox toolchain provenance (PRD §545) (post-audit addition) | Bake only `@anthropic-ai/claude-code@<pinned>` | Add `@openai/codex@<pinned>` baked at image-build alongside claude. Without this, Story 2.10 prereq probe + Story 2.21 doctor probe have nothing to probe inside the devbox. |
| NFR6 (post-audit citation) | (existing) network egress allowlist | Cited directly as **Layer 0** in Defense Layer Coverage Matrix — no new NFR needed; existing NFR6 covers default-deny egress and is the foundational layer of the substrate defense. |

**New PRD invariant:** `INV-substrate-defense-layers` — pinned in PRD § Implementation Considerations + architecture.md § Substrate Security Posture. **Source-pinned (post-audit; cannot be "doc-only" per InvariantSchema requiring sourcePath + contentHash + anchors):** sourcePath = `_bmad-output/planning-artifacts/architecture.md`; anchors = `["INV-substrate-defense-layers", "Defense Layer Coverage Matrix"]`; contentHash computed at PR-0 commit. Names the **5-layer + meta defense model (post-audit, expanded from original 4)**:

0. **Layer 0 — Devbox container + network egress allowlist (NFR6, NFR9, FR1a)** — outermost barrier; egress whitelist + tmpfs noexec/nosuid + container `no-new-privileges` + ipv4/ipv6 default-deny parity. The leaked-secret-with-no-exfil-path is half-defused at L0.
1. **Layer 1 — In-session PreToolUse hooks (NFR5a)** — PreToolUse barrier emitted per-CLI from canonical deny-list. **Sub-columns** (post-audit, codex hook-surface coverage gap): for codex, matrix splits into `bash | apply_patch | mcp | unified-exec | web_search | other`; cells `documented | empirical-pending | not-intercepted`. Codex × in-session hooks coverage is bounded — `web_search` and unified-exec are `not-intercepted`. Claude × L1 documented; codex × L1 covered surfaces = empirical-pending until Story 3.34 promotion gate fires.
2. **Layer 2 — Git-layer invariant manifest + sync-gate (NFR5b)** — pre-commit drift detection.
3. **Layer 3 — Ralph runtime halt threshold (NFR33a)** — 3-strike SECURITY_CRITICAL halt; closed enum per `INV-ralph-halt-reason-enum`; deny-signal normalizer per NFR5b above.
4. **Layer 4 — Auth-token + log-secret isolation (NFR10)** — single named `/home/dev/` volume; `.ralph/logs/` secret-scrub on emit (Growth-tier extension).

**Meta-layer M1 — S4 prompt-injection scan (FR40)** — build-time pattern scan over committed prompts/config/docs. Not a runtime defense; runs at commit boundary only. Demoted from peer layer in original 4-layer model.

> *Permission prompts are out-of-band UX, not part of the defense model. Substrate runs autonomous (per `INV-ralph-halt-reason-enum` autonomy guardrail rejecting external-blocking states); barriers-and-gates enforce safety.*

### 2.4 Architecture Conflicts

| Section | Change |
|---------|--------|
| § tools.json (line ~829) | Codex profile fixed: `base_args=["exec", "--json"]`; `flag_map` corrected (`unsafe → --dangerously-bypass-approvals-and-sandbox`, `sandbox → --sandbox`, `model → --model`, `ephemeral → --ephemeral`); `defaults={"unsafe": False, "sandbox": "workspace-write"}` at 1.0 (tiered — flips to `unsafe: True` after Story 3.34 promotion gate; bot-PR not direct push). **Stream format & event mapping (post-audit):** `stream_format="codex-json"` (new); adapter dispatches on `item.started`/`item.updated`/`item.completed` envelopes wrapping `item.type: "command_execution" \| "agent_message" \| "reasoning"` (NOT a flat `item.command_executed`). **`-c approval_policy="never"` injection mechanism (post-audit):** add `prefix_args` field on `ToolProfile` for fixed token-pair injection (`["-c", "approval_policy=never"]`) — current `tool_args` shape splits on `=` and cannot emit `-c key=value` correctly (per Dev finding C4). |
| § Substrate-Authorship-Constants | Add `AI_CLI_SHAPES = ["claude", "codex"]`. Add `HOOK_BARRIER_DENY_LIST` constant pointing at `packages/keel-invariants/src/hookBarrier.ts`. **Downstream-touchpoint checklist (post-audit):** adding a 3rd shape requires changes in (1) `ralph.py` profile dict, (2) AGENTS.md fallback prose, (3) tools.json schema, (4) doctor sentinel naming, (5) `hookBarrier.ts` emitter, (6) invariant manifest entry — pin this 6-touchpoint list alongside the constant. |
| § Substrate Security Posture (new subsection) | Pin `INV-substrate-defense-layers` (source-pinned to architecture.md § Substrate Security Posture; not "doc-only" per InvariantSchema requirement). Add **Defense Layer Coverage Matrix (5-layer + meta, post-audit)**: rows × cells = `claude × {L0..L4, M1}` and `codex × {L0..L4, M1}`. Codex × L1 expands to sub-columns `bash \| apply_patch \| mcp \| unified-exec \| web_search \| other` with cell values `documented \| empirical-pending \| not-intercepted`; codex × `web_search` and `unified-exec` start as `not-intercepted` (PreToolUse coverage gap acknowledged honestly). Claude × L0 egress = `deferred-growth` at 1.0 (NFR9 in scope; per-iteration egress audit Growth-tier). Codex × L1 covered surfaces = `empirical-pending` until Story 3.34's 30-green + ≥2-version + chaos-injection promotion gate fires. |
| § Knowledge-file contract | Replace 4-row table with: AGENTS.md (substrate primary, every agent; **soft 24 KiB / hard 30 KiB budget — note codex hard-cap is 32 KiB**; absorption from CLAUDE.md targets ~10-11 KiB total post-restructure per `wc -c` math, NOT the original 6-7 KiB estimate); `AGENTS.override.md` precedes `AGENTS.md` per directory in codex hierarchy; RALPH.md (Ralph private); INVARIANTS.md (machine-enforced index); `<CLI>.md` (optional per-CLI delta, ≤25 lines, signpost-only — no duplication of AGENTS.md content). Pin: "AGENTS.md is the only file every agent is GUARANTEED to read." **Preserve fork-precedence contract (post-audit):** the 25-line CLAUDE.md replacement MUST retain a pointer to `INVARIANTS.fork.md` (precedence rule: upstream substrate wins; fork rules ADD-TO but cannot OVERRIDE) — currently in `CLAUDE.md:43-51`. Add **R4 upkeep trigger for CLAUDE.md (post-audit):** AGENTS.md grows a "When to update CLAUDE.md" section naming trigger conditions (new slash-command shape observed, new `~/.claude/` config path discovered, new built-in tool name appears in Claude release notes). |
| § RC1-RC3 (research corpus) | Optional Growth-tier addition: cross-CLI absorption-delta as a sprint-log dimension. Out of 1.0 critical-path. |
| § Ralph Path-Resolution Contract | Unchanged — already CLI-neutral. |

### 2.5 UI/UX Conflicts

The substrate's UX contract is "agent as first-class user" (architecture.md §89). The knowledge-file + prompt-file restructure addresses the existing UX wound: codex agents enter the repo half-blind because the truth lives in CLAUDE.md (which codex never reads). No external user-facing UI changes.

### 2.6 Technical Impact

**`ralph.py` changes (post-audit line numbers + initialization corrections):**

- P0 — consecutive-failure backoff (~10 LOC at `ralph.py:1820` exit-code handler, BEFORE the existing `if exit_code == 130: break` at line 1823): `min(60, 2**n)` exponential cap; reset on exit_code=0; **requires `consecutive_failures = 0` initialization at `ralph.py:~1740`** (after `worker = get_current_worker()`, before the iteration `while`-loop at line 1747) — without this, the snippet `NameError`s on first non-zero exit (Dev finding C2). Exit-code 124 (timeout) now contributes to the backoff counter (intended; named explicitly so reviewers don't surprise-revert). No new halt reason; no schema change.
- P1 — codex profile correctness (`ralph.py:586-596`): updated `flag_map`, `base_args`, `defaults`, `stream_format`. **`-c approval_policy="never"` injection mechanism (post-audit):** add new `prefix_args` field on `ToolProfile` for fixed token-pair `["-c", "approval_policy=never"]`; current `tool_args` shape splits on `=` and cannot emit `-c key=value` correctly. ~20 LOC (was 15; +5 for `prefix_args` field + emission rule).
- P2 — `CodexJsonAdapter` parallel to `ClaudeStreamJsonAdapter` (`ralph.py:1036-1160`): parses codex JSONL events. **Event mapping (post-audit corrected):** dispatch on `item.started`/`item.updated`/`item.completed` envelopes wrapping `item.type: "command_execution" | "agent_message" | "reasoning"` (NOT a flat `item.command_executed`); `thread.started` → `session_id` capture; `turn.completed.usage.{input_tokens,output_tokens}` → `app.total_input/total_output`; `turn.failed` → log + bump `turn_count`. Capabilities advertised: `{elapsed, turns, tokens, tool_use}` (omits `cost`, `context`); existing render code at `ralph.py:1450, 1469, 1480` correctly produces em-dashes via the existing `else` branches at `:1459, :1475, :1485` (no polymorphism refactor needed — `OutputAdapter` capability-set is the existing seam, per Dev finding). ~200 LOC + JSONL fixture for tests. **PR-2 prereq (post-audit):** empirical capture of `codex exec --json` output; commit fixture at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl` with named consuming test owner before adapter ships.
- P3 — ccusage `--since today` bug fix at **`ralph.py:218`** (proposal line drift corrected from `:215`; `today` is *defined* at line 215, the `subprocess.run` *call* is at line 218): drop `--since` arg; rely on `--active`. Fixes midnight-edge for live fetch. **Note (post-audit):** cache layer (`ralph.py:173-202`) writes a 5-min TTL cache without date partitioning, so post-midnight a stale pre-midnight cache could still serve from `_read_block_cache` for ≤TTL; live-fetch midnight-edge is fixed but cache may serve pre-midnight data for ≤5 min post-midnight (minor; acceptable at 1.0). ~2 LOC.
- P4 — ccusage hide-row when tool != claude. **Sites (post-audit, expanded — proposal originally listed only 1308 + 1460):** `ralph.py:215-218` (cache fetch), `ralph.py:1122` ("Cost " stats append in summary), `ralph.py:1308` (interval registration), `ralph.py:1460-1467` (header render), `ralph.py:1482, :1486` (header Cost/em-dash render), `ralph.py:1719` (loop-complete summary). All gated by `if self.config.tool == "claude":`. ~20 LOC across 6 sites. Cleanup nit: `CLAUDE_CODE_TASK_LIST_ID` env at `ralph.py:1760` always set even when `tool != "claude"` — gate or rename to CLI-neutral; out of P0-P5 scope, flag for separate hygiene pass.
- P5 — codex telemetry replacement (CodexJsonAdapter accumulates `turn.completed.usage.{input_tokens,output_tokens}`; header shows `Tokens: in/out`; no cost estimate). Bundled with P2.

**Knowledge files:**

- `AGENTS.md` absorbs Common commands table, High-level architecture (compact), single canonical Knowledge-file contract table, single Promotion rules table. Adds `Tool Entry Points` section; adds `State / Crash Journal` section pointing at `.ralph/@plan.md` as cross-CLI canonical; adds `Tool dirs` section listing `.claude/` + `.codex/` exclusions; adds `BMAD Invocation` section pointing at `_bmad/_config/bmad-help.csv` as catalog source; adds `When to update CLAUDE.md` section per R4 upkeep trigger (post-audit). Voice unified to imperative second-person. **Size estimate (post-audit corrected):** ~10-11 KiB total post-absorption (current AGENTS.md = 6.7 KiB + ~50% of CLAUDE.md = ~4 KiB), NOT the original 6-7 KiB estimate. Comfortable under 24 KiB soft / 30 KiB hard / 32 KiB codex-cap.
- `CLAUDE.md` shrinks to ~15-25 lines per Sally's draft (Section 4.1 below) — **with INVARIANTS.fork.md precedence pointer preserved (post-audit)**.
- `RALPH.md` unchanged structurally (private journal).
- `INVARIANTS.md` acquires new manifest IDs.
- Prompt files re-seeded per Section 4.2.

**`packages/keel-invariants/`:**

- New `src/hookBarrier.ts` — canonical deny-list as data + `emitClaudeHooks()` + `emitCodexHooks()` emitters + invariant manifest registration of `barrier.hooks.deny-list-canonical`.

---

## Section 3 — Recommended Approach

**Direct Adjustment** (not Rollback, not MVP Review). Specifically:

- **Codex tier:** First-class — substrate axis `aiCli: "claude" | "codex"`, both Tier-1 implementations, claude as default-emitted choice.
- **Parity bar (post-audit reframe):** "Future-proof multi-CLI substrate with named gaps" — every substrate invariant attempts a codex-side equivalent; where parity is empirically impossible (e.g., codex PreToolUse not intercepting `web_search`/unified-exec), the Defense Layer Coverage Matrix names the gap honestly and L0 (egress) + L2 (manifest) + L3 (halt) catch the residual blast radius. Tier-1 quality on covered surfaces is gated empirically (Story 3.34 promotion gate). The matrix-naming-the-gaps is itself the research output.
- **Tiered permissive default:** Codex profile defaults to `--sandbox=workspace-write -c approval_policy="never"` at 1.0. Permissive (no prompts), hooks alive. Promotes to `--dangerously-bypass-approvals-and-sandbox` after Story 3.34 ships 30 consecutive green nightly bypass-survival runs **AND ≥2 distinct codex versions AND ≥1 chaos-injected deny-verification per week** (post-audit hardening). Per Murat's risk model: do not promote undocumented security behavior on vibes.
- **Defense Layer Coverage Matrix tells the truth (5-layer + meta, post-audit).** L0 egress / L1 in-session-hooks (with sub-columns per codex tool surface) / L2 git-manifest / L3 runtime-halt / L4 auth-token+log isolation; M1 prompt-scan as build-time meta. Codex × L1 covered surfaces = empirical-pending until promotion gate fires; codex × `web_search` and unified-exec start as `not-intercepted`. Substrate ships honestly with the gap named.
- **Track-of-PRs sequenced delivery (post-audit, expanded):** **PR-0** (corrections-only docs PR) lands before PR-1, then PR-1..PR-11 — see Section 5.
- **Scope:** Major. PR-0 + PR-3/4 require PM (FR/NFR rephrasing — 6 additional amendments beyond original list) + Architect (5-layer Coverage Matrix + INV ID corrections + halt-enum reaffirmation) + Developer (ralph.py runtime + per-CLI hook emitters) handoff.

**Rationale (in dependency order, post-audit):**

0. **PR-0 corrections-only docs PR** lands first: PRD FR/NFR amendments (FR3/5/7/14j/14k/40, NFR5a/5b/6/10/30/33a, Story 2.1 amendment, NFR6 Layer-0 citation), architecture.md Defense Coverage Matrix (5-layer + meta + sub-columns), invariant ID corrections (rename `barrier.hooks.deny-list-canonical` → `INV-barrier-hooks-deny-list-canonical`; source-pin `INV-substrate-defense-layers`; remove `CODEX_DOCTOR_REQUIRED` halt reason — replaced by pre-loop pointer error), CLAUDE.md INVARIANTS.fork.md precedence preserved, halt-enum + autonomy-guardrail reaffirmation. (Some original PR-4 contents may fold into PR-0; remaining downstream PRs cite already-pinned language.)
1. The infinite-crash bleed must stop next (PR-1 is XS) so empirical codex testing can proceed without burning iteration time.
2. Codex must run at all (PR-2: profile correctness + adapter + **empirical capture prereq promoted from PR-8**) before any parity story can be empirically validated.
3. Knowledge-file restructure (PR-3) unblocks codex agents from operating half-blind; references PR-0's pinned FR14j language.
4. (PR-4 contents may have folded into PR-0; if any architecture-only edits remain, they land here.)
5. Epic 2 sequential stories (2.18-2.21) + Story 3.34 deliver substrate-invariant parity on covered surfaces in dependency-correct order.

**Effort estimate (post-audit):**

- PR-0 (M): PRD/Architecture corrections + INV ID renames + halt-enum reaffirmation + INVARIANTS.fork.md preservation + Coverage Matrix shape pin. 1-2 days.
- PR-1 (XS): ~10-15 LOC + `consecutive_failures` init + 1 LOC ccusage. ½ day.
- PR-2 (S): ~20 LOC profile + `prefix_args` injection mechanism + ~200 LOC adapter (with corrected event mapping) + JSONL fixture + tests + empirical-capture session (1 hour). 2-3 days.
- PR-3 (M): docs surgery — ~150-line CLAUDE.md edit (preserving fork-precedence pointer) + ~200-line AGENTS.md absorbs (~10-11 KiB target post-restructure) + prompt-file edits + R4 upkeep trigger section. 1-2 days.
- PR-4 (M, may fold into PR-0): residual architecture-only edits if any remain after PR-0. 1-2 days (may be 0).
- PR-5+ (codex Epic 2 sequential + 3.34): 2.18 codex OAuth (S, 1 day), 2.10 amendment (XS, ½ day), 2.19 emitCodexHooks (M, 2-3 days), 2.20 codex PreToolUse + normalizer with non-deny shape handling (M, 2-3 days), 2.17 amendment (S, 1 day), 2.21 pre-loop probe (S, 1 day), 3.34 nightly bypass-survival with positive+negative+canary controls (M, 2-3 days). Total: ~10-14 days.

**Total elapsed estimate:** ~3 weeks of Ralph build-iterations (with normal review cadence). PR-0 adds +1-2 days but recovers against PR-3/PR-4 churn.

**Risk assessment:**

- **Highest risk:** R-CDX-2 (`--yolo` bypass-survival undocumented + L1 coverage gap). Mitigated by tiered default + hardened promotion gate (30-green + ≥2-version + chaos-injection + canary counter) + Coverage Matrix sub-columns naming `web_search`/unified-exec as `not-intercepted` (relying on L0 egress + L2 manifest + L3 halt). Worst case: codex ships with `--sandbox=workspace-write` permanently and `web_search`/unified-exec uncovered at L1 (caught by L0 egress). Acceptable for substrate posture.
- **Empirical prereq (post-audit promotion):** Story 2.19 matchers + PR-2 adapter event mapping must be re-derived against captured `codex exec --json` output (not docs-derived). Schedule 1-hour capture session before PR-2 (was PR-8 prereq); fixture committed at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl` with named consuming test owner. Otherwise risk shipping adapter against wrong event names AND matchers against wrong tool names.
- **Documentation drift:** PR-3 (knowledge-file restructure) cites PR-0's pinned FR14j; PR-3 must land before any codex iteration runs in production, or codex agents continue operating half-blind.
- **Empty-package dependencies:** `packages/devbox/` (Story 2.1 amendment for codex CLI bake) and `packages/keel-templates/` (Story 3.3 scope narrowed at 1.0 — Epic 12 prereq for package-templated seeding) must not block PR sequence; both are addressed in amendments above.

---

## Section 4 — Detailed Change Proposals

### 4.1 Knowledge-file restructure

**`AGENTS.md` (target: absorbs ~50% of CLAUDE.md content; aim ~6-7 KiB total, well under 24 KiB soft / 30 KiB hard budget):**

New section ordering (first-30-seconds principle — most-acted-upon first):

1. **Header + audience** — "Provider-neutral guide for any AI coding agent. Source of truth — read this first."
2. **What this is** (existing)
3. **Where things live** (existing path table)
4. **Common commands** (absorbed from CLAUDE.md)
5. **Tool entry points** (NEW) — names AGENTS.md as primary; `<CLI>.md` files (currently only CLAUDE.md exists) as optional per-CLI deltas; codex reads AGENTS.md natively.
6. **State / Crash Journal** (NEW) — `.ralph/@plan.md` is the cross-CLI canonical crash journal (per FR14k). Native CLI task-list APIs are optional convenience mirrors.
7. **Tool dirs** (NEW) — `.claude/`, `.codex/` excluded from app-source scans unless editing agent config.
8. **How to work here** (existing)
9. **BMAD invocation** (NEW) — `_bmad/_config/bmad-help.csv` is the catalog source-of-truth. Claude invokes via `/bmad-*` slash commands; other CLIs read the CSV catalog + `.claude/skills/<skill>/SKILL.md` directly and execute the named workflow.
10. **Knowledge-file contract** (absorbed; single canonical table)
11. **Promotion rules** (existing — single canonical table)
12. **Project conventions** (existing)
13. **Git / PR conventions** (existing)
14. **Fork extension (FR44)** (existing)
15. **Ralph loop** (existing)
16. **When you're unsure** (existing)

Voice: imperative, second-person, present tense throughout. "Run `/bmad-help` to find the next step." not "Skills are slash commands."

**`CLAUDE.md` target (per Sally's draft, post-audit revised to preserve INVARIANTS.fork.md precedence):**

```markdown
# CLAUDE.md — Claude Code deltas

AGENTS.md is the source of truth. Read it first.

## Claude-Code-specific

- Skills under `.claude/skills/<name>/SKILL.md` invoke as `/<name>` slash commands
- One skill per context window
- `.claude/settings.local.json` is gitignored — don't touch
- Worktrees under `.claude/worktrees/` — never clean up on exit
- Memory: `_bmad/_memory/` (project) or `~/.claude/` (user)
- Native task list (`TaskList`/`TaskCreate`) is a Claude-only convenience mirror over `.ralph/@plan.md`; it survives hard kills

## Fork-invariants precedence

`INVARIANTS.md` (upstream) is authoritative for every rule registered in `invariants.manifest.ts`; `INVARIANTS.fork.md` (when a fork opts in via `packages/keel-invariants/templates/INVARIANTS.fork.md`) is additive — fork rules ADD TO substrate but cannot override it. See `docs/invariants/fork.md` § Precedence.

## Pointers

- For Ralph-loop guidance: `RALPH.md`
- For machine-enforced rules: `INVARIANTS.md`
- For substrate operational truth: `AGENTS.md`
```

**FR14j rewrite (per Winston, post-audit refined):**

> Agent maintains layered knowledge files: `AGENTS.md` (shared substrate operational truth, read by every agent — `AGENTS.override.md` precedes `AGENTS.md` per directory in codex's 3-tier hierarchy), `RALPH.md` (Ralph's private journal), `INVARIANTS.md` (machine-enforced rules index). Per-CLI supplement files (e.g., `CLAUDE.md`) are OPTIONAL and contain only CLI-specific deltas — never duplicate AGENTS.md content; `<CLI>.md` MUST preserve a pointer to `INVARIANTS.fork.md` precedence rules where applicable. Promotion rules pinned in AGENTS.md.

**R4 (knowledge-file upkeep contract) rotation change:** Per-iteration nudge rotates `AGENTS.md / RALPH.md / INVARIANTS.md`. CLAUDE.md drops out of per-iteration rotation — it changes only when Claude Code itself ships a new quirk. **R4 upkeep trigger (post-audit):** AGENTS.md grows a "When to update CLAUDE.md" section naming the trigger conditions explicitly: new slash-command shape observed, new `~/.claude/` config path discovered, new built-in tool name appears in Claude release notes. Without an explicit trigger, agents will silently let CLAUDE.md stale.

### 4.2 Prompt-file restructure (PROMPT_build.md + PROMPT_plan.md)

**Approach:** Direct prose with explicit `Claude: X. Codex: Y.` inline fallback. No template engine, no per-CLI variable substitution at 1.0 (Growth-tier evolution if a 3rd CLI lands).

**`.ralph/PROMPT_build.md` line-by-line edits:**

- **L9 (orient 0c):** Replace `Study @AGENTS.md for operational commands. @CLAUDE.md points to it. Study @RALPH.md...` with `Study @AGENTS.md (operational source of truth, every agent reads this). If running Claude Code, also read @CLAUDE.md for adapter behavior. Study @RALPH.md — the notes prior Ralphs left for you...`
- **L11 (orient 0e):** Add `.codex/` to the excluded directories list — `Application source... directories under repo root other than \`_bmad/\`, \`_bmad-output/\`, \`.claude/\`, \`.codex/\`, \`docs/\`.`
- **L11 (orient 0e):** Replace `Use Sonnet subagents for searches/reads; one Sonnet subagent at most for any build/test command (backpressure)` with `Use parallel read/search helpers when available. Claude: Sonnet subagents for reads/searches; at most one build/test subagent (backpressure). Codex: use local \`rg\`/\`grep\` and plan-file state; no subagent assumption.`
- **L0g:** Replace `Run TaskList. If tasks exist from a killed prior iteration, they show in-flight work. Use alongside IP to orient, then mark stale tasks deleted. If no tasks, proceed.` with `Read \`.ralph/@plan.md\` (the IP) — this is the substrate-invariant crash journal. Claude: also run \`TaskList\` to inspect any in-flight native tasks from a killed prior iteration; reconcile against IP; mark stale tasks deleted. Codex: \`.ralph/@plan.md\` is the only durable crash journal; codex's \`update_plan\` is session-local UI, not durable state.`
- **L1b:** Replace `Create 1 native Task for the NOW item (TaskCreate). Update status as you progress. Max 3 active tasks (NOW + up to 2 sub-steps). These survive hard kills.` with `Record NOW in \`.ralph/@plan.md\`. Claude: also mirror NOW into one native Task (\`TaskCreate\`); update status as you progress; max 3 active native tasks (NOW + up to 2 sub-steps). The IP-side record is the durable crash-journal entry; the native task is a Claude-only convenience that survives hard kills.`
- **L24-L25 (step 3a knowledge-file upkeep):** Replace `@CLAUDE.md / @AGENTS.md — if a convention applies to every future agent, promote it to AGENTS.md (or, if Claude-Code-specific, CLAUDE.md). Keep AGENTS.md operational — bloated AGENTS.md pollutes every future loop's context.` with `@AGENTS.md — if a convention, command, or path discovered this iteration applies to every future agent, promote it here. @CLAUDE.md — only Claude-Code-specific quirks (skill invocation, settings file paths, etc.); never duplicate AGENTS.md content. Keep AGENTS.md under ~24 KiB — bloated AGENTS.md pollutes every future loop's context (codex hard-caps at 32 KiB). @INVARIANTS.md — if the rule is machine-enforced (config / lint rule / pre-merge gate), index it here.` (R4 rotation: AGENTS.md / RALPH.md / INVARIANTS.md.)
- **L25 (commit):** Replace `Commit IP + RALPH.md + AGENTS.md/CLAUDE.md changes alongside the work` with `Commit IP + RALPH.md + AGENTS.md (or INVARIANTS.md, if applicable) changes alongside the work. CLAUDE.md updates are rare — only when Claude Code itself ships a new quirk.`
- **L107:** Replace `BMad skills in this project use the \`bmad-\` prefix and are invoked via Claude Code slash commands. Source of truth: \`_bmad/_config/bmad-help.csv\` and \`/bmad-help\`.` with `BMad skills in this project use the \`bmad-\` prefix. Source of truth: \`_bmad/_config/bmad-help.csv\`. Claude: invoke via \`/bmad-*\` slash commands. Codex: read the CSV catalog + the relevant \`.claude/skills/<skill>/SKILL.md\` and execute the named workflow directly (no slash-command surface in codex).`
- **L196 (closing):** Replace `Keep @AGENTS.md operational only — bloated AGENTS.md pollutes every future loop's context. Document bugs in IP even if unrelated. @RALPH.md is where Ralph-flavored notes live (signposts, lessons, gotchas, decisions); AGENTS.md/CLAUDE.md is for shared operational truth.` with `Keep @AGENTS.md operational only — bloated AGENTS.md pollutes every future loop's context (codex hard-caps at 32 KiB). Document bugs in IP even if unrelated. @RALPH.md is where Ralph-flavored notes live (signposts, lessons, gotchas, decisions); @AGENTS.md is for shared operational truth across all CLIs; @INVARIANTS.md indexes machine-enforced rules.`

**`.ralph/PROMPT_plan.md` line-by-line edits:**

- **L7 (top):** Update header — `Files: IP=.ralph/@plan.md | A.md=AGENTS.md (primary) | C.md=CLAUDE.md (Claude adapter only) | I.md=INVARIANTS.md | SS=sprint-status.yaml`
- **L18:** Add `.codex/` to excluded dirs — `Study source dirs (anything outside \`_bmad/\`, \`_bmad-output/\`, \`.claude/\`, \`.codex/\`, \`docs/\`)`
- **L19:** Replace `Study @AGENTS.md for operational context. @CLAUDE.md points to it.` with `Study @AGENTS.md for operational context (source of truth, every agent). If running Claude Code, also read @CLAUDE.md for adapter-specific behavior.`
- **L40-L41:** Same R4 rotation update as PROMPT_build.md — AGENTS.md / RALPH.md / INVARIANTS.md; CLAUDE.md adapter-only.

### 4.3 ralph.py runtime fixes (per Amelia)

**P0 (PR-1):** Consecutive-failure backoff at `ralph.py:~1822` exit-code handler:

```python
# After non-130 exit:
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

**P1 (PR-2):** Codex profile correctness at `ralph.py:586-596`:

```python
"codex": ToolProfile(
    name="codex",
    binary="codex",
    base_args=["exec", "--json"],
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

`-c approval_policy="never"` is injected via `tool_args` (not flag_map; `-c` takes a key=value pair).

**P2 (PR-2):** `CodexJsonAdapter` parallel to `ClaudeStreamJsonAdapter` (`ralph.py:1036-1160`). Maps codex JSONL events to TUI capabilities `{turns, tokens, tool_use}`. Em-dashes for cost + context-pct (codex emits no cost; `--json` events don't currently expose context-window data).

Event mapping:
- `thread.started` → session_id captured (used for resume parity with Claude task-list).
- `turn.started` → no-op.
- `turn.completed` → `turn_count++`; `usage.input_tokens` → `app.total_input`; `usage.output_tokens` → `app.total_output`. Cache fields absent — leave defaults at 0.
- `turn.failed` → log error; bump turn_count.
- `item.command_executed` → tool_use display (`{WRENCH} shell {command}`).
- `item.agent_message` / `item.agent_reasoning` → markdown render.

**P3 (PR-1):** ccusage `--since today` bug fix at `ralph.py:215`:

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

**P4 (PR-2):** ccusage hide-row gating at `ralph.py:1308` and `ralph.py:1460`:

```python
# ralph.py:1308 (registration):
if self.config.tool == "claude":
    self._fetch_block_usage_async(force_refresh=True)
    self.set_interval(300.0, lambda: self._fetch_block_usage_async(force_refresh=True))

# ralph.py:1460 (render):
if self.config.tool == "claude" and self.block_usage.available:
    bu = self.block_usage
    ...
```

**P5 (PR-2):** Codex telemetry replacement — bundled with P2's `CodexJsonAdapter`. Header row for codex shows `Tokens: in/out` accumulated across iterations; no cost row (em-dash).

### 4.4 PRD edits (PR-4)

Per § 2.3 above. New `INV-substrate-defense-layers` invariant pinned in PRD § Implementation Considerations + architecture.md § Substrate Security Posture (4-layer model). PRD changelog entry summarizing the codex-parity escalation + 4-layer naming.

### 4.5 Architecture edits (PR-0, paired with PRD)

Per § 2.4 above. Defense Layer Coverage Matrix added — **5-layer + meta (post-audit)**: rows × cells = `{claude, codex} × {L0 egress, L1 in-session-hooks (with codex sub-columns: bash | apply_patch | mcp | unified-exec | web_search | other), L2 git-manifest, L3 runtime-halt, L4 auth-token+log isolation, M1 prompt-scan meta}`; cells: `documented | empirical-pending | not-intercepted | deferred-growth | not-applicable`. § tools.json codex profile fix documented inline (with `prefix_args` field on `ToolProfile` for `-c approval_policy=never` injection). § Knowledge-file contract rewrite per Winston (preserves INVARIANTS.fork.md precedence). § Substrate-Authorship-Constants gets `AI_CLI_SHAPES` + `HOOK_BARRIER_DENY_LIST` + 6-touchpoint checklist for adding a 3rd shape.

### 4.6 New invariants (PR-0 + PR-2 + PR-5+) — post-audit corrections applied

| Invariant ID | sourcePath | Anchors | Description | Story |
|--------------|------------|---------|-------------|-------|
| `INV-substrate-defense-layers` | `_bmad-output/planning-artifacts/architecture.md` | `["INV-substrate-defense-layers", "Defense Layer Coverage Matrix"]` | 5-layer + meta defense model named in PRD + arch (post-audit: source-pinned, NOT "doc-only" per InvariantSchema requiring sourcePath + contentHash + anchors) | PR-0 |
| `INV-barrier-hooks-deny-list-canonical` (renamed from `barrier.hooks.deny-list-canonical` — original failed regex `^INV-[a-z0-9]+(-[a-z0-9]+)+$`) | `packages/keel-invariants/src/hookBarrier.ts` | `["INV-barrier-hooks-deny-list-canonical"]` | Canonical deny-list + per-CLI emitters | 2.15 (amended) |
| `INV-codex-hooks-feature-enabled` | runtime probe (assertion via `codex features list \| grep '^codex_hooks: enabled$'`) | `["INV-codex-hooks-feature-enabled"]` | Substrate hard-fails if `codex_hooks` not enabled in effective feature state when `--tool codex` (post-audit: runtime probe — NOT literal `[features] codex_hooks = true` TOML presence, which false-fails on default-enabled installs per codex 0.128.0). Re-probed per Ralph iteration spawn (not just devbox boot — host config can drift mid-session). | 2.10 (amended) |
| `INV-codex-hook-secret-denylist` | `.codex/hooks.json` + `.codex/hooks/block-secret-access.sh` | `["INV-codex-hook-secret-denylist"]` | Codex PreToolUse hook + deny-rules; matchers use actual codex tool names (`Bash`, `apply_patch`, `mcp__*`) | 2.20 |
| (existing) `INV-claude-hook-secret-denylist` | `.claude/settings.json` + `.claude/hooks/block-secret-access.sh` | `["INV-claude-hook-secret-denylist"]` | Unchanged | 2.15/2.16 (existing) |

**Note:** All invariant entries in PR-0 require `contentHash` (sha256) + manifest registration via `packages/keel-invariants/src/invariants.manifest.ts`. The proposal's earlier "doc-only" framing for `INV-substrate-defense-layers` (line 364 of original draft) is impossible per the InvariantSchema regex + required-fields contract — corrected here.

### 4.7 sprint-status.yaml updates

Pending Tthew approval — to be applied during workflow Step 5 finalization. Proposed delta:

```yaml
# Epic 2 amendments (post-audit: sequential numbering; twin-suffix-b reverted — no precedent in sprint-status.yaml):
2-1-... (extended scope: bake codex CLI in toolchain provenance — post-audit addition)
2-8-claude-code-oauth-via-pnpm-claude: backlog                   # rename to "ai-cli-oauth"
2-10-prerequisite-check-... (extended scope, no rename — codex auth + runtime feature probe)
2-15-... (renamed: hook-barrier-emission-per-cli)
2-16-... (renamed: pretooluse-hook-implementation-per-cli)
2-17-... (extended scope, no rename — manifest covers .codex/** + non-deny shape handling)
2-18-codex-oauth-via-pnpm-codex: backlog                          # NEW (was 2.8b)
2-19-codex-hooks-emitter: backlog                                 # NEW (was 2.15b)
2-20-codex-pretooluse-hook: backlog                               # NEW (was 2.16b)
2-21-codex-pre-loop-probe: backlog                                # NEW (was 2.18; reframed from halt-with-CODEX_DOCTOR_REQUIRED to pre-loop pointer error since `keel doctor` does not exist + closed halt enum forbids new external-blocking reasons)

# Epic 3 amendments:
3-2-... (rephrased + pidfile lock — no rename)
3-3-... (re-seeded prompts at .ralph/PROMPT_*.md only — Epic 12 prereq for package-templated seeding)
3-10-... (reframed crash-journal contract — codex session-resume defer-to-Growth)
3-34-nightly-yolo-bypass-survival-promotion-gate: backlog         # NEW (with positive+negative+canary controls + ≥2-version + chaos-injection threshold)
```

---

## Section 5 — Implementation Handoff

### Scope classification: **Major**

Requires PM (FR/NFR rephrasing in PRD), Architect (contract design + Defense Layer Coverage Matrix in architecture.md), Developer (ralph.py runtime + per-CLI hook emitters + new stories) coordination.

### Recommended PR sequence (post-audit: PR-0 inserted, sequential story numbering)

| PR | Size | Contents | Depends on | Unblocks |
|----|------|----------|------------|----------|
| **PR-0** (NEW post-audit) | M (~1-2 days) | **Corrections-only docs PR** — PRD amendments (FR3, FR5, FR7, FR14j, FR14k, FR40 ext, NFR5a tool-surface clause, NFR5b non-deny shape handling, NFR10 single-volume preserve, NFR30, Story 2.1 toolchain, NFR6 Layer-0 citation); architecture.md edits (§ tools.json + `prefix_args` mechanism, § Substrate-Authorship-Constants + 6-touchpoint checklist, § Substrate Security Posture + 5-layer + meta Defense Coverage Matrix with codex sub-columns, § Knowledge-file contract rewrite preserving INVARIANTS.fork.md precedence); INV ID corrections (rename `barrier.hooks.deny-list-canonical` → `INV-barrier-hooks-deny-list-canonical`; source-pin `INV-substrate-defense-layers` to architecture.md with sourcePath+contentHash+anchors; remove `CODEX_DOCTOR_REQUIRED` halt reason — replaced by pre-loop pointer error); halt-enum + autonomy-guardrail reaffirmation. | None — standalone docs PR | All downstream PRs cite already-pinned PRD/arch language; PR-1/PR-2 don't block on language drift |
| **PR-1** | XS (~½ day) | ralph.py P0 backoff (insert at `ralph.py:1820` before existing 1823; **`consecutive_failures = 0` init at `ralph.py:~1740`**); ccusage `--since today` bug fix at **`ralph.py:218`** (post-audit corrected from `:215`) | PR-0 (no behavioral dependency, but cleaner if language already pinned) | Empirical codex testing without burning iteration time |
| **PR-2** | S (~2-3 days) | ralph.py P1 codex profile correctness (with `prefix_args` field for `-c approval_policy=never`); P2 `CodexJsonAdapter` (with corrected `item.started`/`item.completed` envelope dispatch); **empirical capture prereq promoted from PR-8** — capture `codex exec --json` output, commit fixture at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl`, name consuming test owner; P4 ccusage hide-row across all 6 sites (post-audit expansion: 215-218, 1122, 1308, 1460-1467, 1482, 1486, 1719); P5 codex telemetry replacement | PR-1 (clean exit-code handling); empirical capture session | "Codex actually runs" — Ralph loop functional under `--tool codex` with `--sandbox=workspace-write` permissive default |
| **PR-3** | M (~1-2 days) | Knowledge-file restructure: AGENTS.md absorbs (~10-11 KiB target post-audit); CLAUDE.md shrinks to ~25-line signpost **with INVARIANTS.fork.md precedence pointer preserved**; AGENTS.md grows "When to update CLAUDE.md" section per R4 upkeep trigger; PROMPT_build.md + PROMPT_plan.md de-Clauded with inline fallback prose; R4 rotation flip | PR-0 (cites pinned FR14j) | Codex agents stop operating half-blind |
| **PR-4** (may fold into PR-0 post-audit) | (M, may be 0) | Residual architecture-only edits if any remain after PR-0. May be zero if PR-0 absorbed all PRD/arch corrections. | PR-0 | (cleanup) |
| **PR-5** | S (~1 day) | Story 2.18 (was 2.8b): `pnpm codex` codex OAuth via `codex login`; tokens at `/home/dev/.codex/` inside the existing single named `/home/dev/` volume (post-audit: NFR10 single-volume preserved). | Epic 2 Story 2.1 (post-audit amendment to bake codex CLI in toolchain) | Codex auth in devbox |
| **PR-6** | XS (~½ day) | Story 2.10 amendment: prereq check extends to codex — auth probe + `codex features list` runtime probe (NOT TOML literal) + `codex --version` minimum-version check | PR-5 | Codex prereq gating |
| **PR-7** | XS (~½ day) | Story 2.21 (was 2.18 keel-doctor): per-CLI **pre-loop pointer error** in `ralph.py` codex-spawn path verifying (a) auth, (b) `codex_hooks=enabled`, (c) version, (d) deny-list smoke with canary counter; sentinel content = sha256 of `.codex/hooks.json` + version + matchers; pre-commit hook rejects committed sentinel. **Post-audit reframe:** NOT a halt reason (`CODEX_DOCTOR_REQUIRED` would violate closed halt-enum + autonomy guardrail per `INVARIANTS.md:47`); fails fast pre-iteration with diagnostic message. `keel doctor` CLI does not exist; this is a `ralph.py`-resident probe. | PR-2, PR-6 | Per-CLI pre-loop probe pattern shipped |
| **PR-8** | M (~2-3 days) | Story 2.15 amendment + Story 2.19 (was 2.15b): canonical `packages/keel-invariants/src/hookBarrier.ts` data + `emitClaudeHooks()` + `emitCodexHooks()` (matchers using actual codex names `Bash`, `apply_patch`, `mcp__*`); INVARIANTS.md + manifest registers `INV-barrier-hooks-deny-list-canonical` (renamed from invalid `barrier.hooks.deny-list-canonical`) + `INV-codex-hook-secret-denylist` with sourcePath/contentHash/anchors | PR-0 (canonical contract pinned); **empirical fixture committed in PR-2** (no longer a separate prereq) | Hook-barrier deny-list canonical |
| **PR-9** | M (~2-3 days) | Story 2.20 (was 2.16b): `.codex/hooks/block-secret-access.sh` PreToolUse hook + deny-signal normalizer with **enumerated non-deny shape handling** (exit-2 + JSON `permissionDecision: deny` increment counter; process-fail / stdout-empty / hooks-disabled-silent-allow / partial-JSON / hooks-config-absent → fail-closed SECURITY_CRITICAL halt) | PR-8 | Codex in-session hook barrier shipped (empirical-pending coverage on intercepted surfaces; `web_search`/unified-exec marked `not-intercepted` in matrix) |
| **PR-10** | S (~1 day) | Story 2.17 amendment: git-layer manifest + sync gate covers `.codex/hooks.json`, `.codex/hooks/**`, `.codex/AGENTS.md`; NFR5b 3-strike halt counter handles all non-deny shapes (per PR-9); FR40 prompt-scan extends to AGENTS.md + `.codex/**` | PR-9 | Bypass-resistance covers both CLIs |
| **PR-11** | M (~2-3 days) | Story 3.34: nightly `--yolo` bypass-survival CI workflow with **positive + negative + canary controls** (post-audit, mandatory); promotion gate **30 green + ≥2 codex versions + ≥1 weekly chaos-injection** (post-audit hardened); **bot-PR opener** (NOT direct push) flips codex profile default `unsafe: False → True` with required human approval; demote-trigger conditions pinned | PR-9, PR-10 | Defense Layer Coverage Matrix codex × in-session-hooks (intercepted surfaces) cell promotes empirical-pending → documented |

**Total elapsed estimate:** ~3 weeks of Ralph build-iterations + ~1-2 days for PR-0.

### Deliverables

- This Sprint Change Proposal at `_bmad-output/planning-artifacts/sprint-change-proposal-2026-05-04.md` (revised post-audit) ✓ (this file)
- 11-12 PRs delivered in dependency order (PR-0 added; PR-4 may fold into PR-0)
- PRD changelog entry for the codex-parity escalation + post-audit corrections
- Updated `_bmad-output/implementation-artifacts/sprint-status.yaml` reflecting sequential numbering
- `INVARIANTS.md` registers new manifest IDs (with proper regex-conformant names + sourcePath/contentHash/anchors)
- `docs/install/codex.md` (new) documenting codex OAuth + `codex features list` probe + `OPENAI_API_KEY` headless escape hatch
- `docs/ralph.md` + `README.md` codex-aware updates (post-audit: getting-started flow + ralph.py architecture diagram)
- `docs/agents/` subdir is **not** created at 1.0 (per Winston's "boring technology" call) — promoted to Growth-tier evolution if 3rd CLI lands

### Success criteria

- **PR-0:** PRD validation passes; INVARIANTS.md sync-gate green for new IDs; FR14j rewrite + 5-layer + meta Defense Coverage Matrix reviewed by John (PM) + Winston (Architect) without scope objections; halt-enum reaffirmed.
- **PR-1:** Ralph loop running `--tool codex` no longer infinite-loops on tool-launch failures; ccusage row shows non-zero data at 00:30 local.
- **PR-2:** `uv run ralph.py build --tool codex` completes one iteration successfully; CodexJsonAdapter (with corrected event mapping) populates header tokens correctly; em-dashes render gracefully for cost/context; committed JSONL fixture validated by consuming test.
- **PR-3:** Codex agent entering the repo for the first time can execute correctly using only AGENTS.md as the entry point; `wc -l CLAUDE.md` ≤ 30 AND CLAUDE.md preserves INVARIANTS.fork.md pointer; PROMPT_build.md / PROMPT_plan.md grep -c claude-specific-language drops to ≤ 5 (CLI-named adapter callouts only).
- **PR-11:** 30 consecutive nightly green bypass-survival runs across ≥2 codex versions with ≥1 weekly chaos-injection trigger keel-bot to open promotion PR (human-approved); Defense Layer Coverage Matrix codex × L1 (intercepted surfaces) cell flips to "documented"; not-intercepted surfaces (`web_search`/unified-exec) remain marked honestly.

### Routing (per scope classification, post-audit)

- **PR-0** (PRD + Architecture corrections) → Product Manager (John) + System Architect (Winston) — **must review BEFORE any code-bearing PR ships**.
- **PR-3** (Knowledge-file + prompt restructure) → Product Manager (John) for FR14j cited-language signoff + Developer (Amelia) for execution.
- **PR-1, PR-2** (ralph.py runtime) → Developer (Amelia) for direct implementation.
- **PR-5 through PR-11** (Epic 2 sequential 2.18-2.21 + Epic 3 stories) → Developer (Amelia) per BMad story-execution flow (`/bmad-create-story` → `/bmad-dev-story` → `/bmad-code-review`).

---

## Section 6 — Open items requiring Tthew sign-off (post-audit revised)

| Item | Recommendation | Required for proposal approval? |
|------|----------------|--------------------------------|
| **JTBD answer** (John's round-1 dissent + post-audit reframe) — vendor-hedge / future-proof / research-richness / fork-friendliness / other | **Post-audit recommendation:** "future-proof multi-CLI substrate with named gaps." The verified PreToolUse coverage gap (`web_search`/unified-exec not intercepted) means substrate-invariant parity has a named ceiling visible only from the codex side. The honest framing is that the substrate makes the parity attempt, names where parity is empirically impossible, and ships the 5-layer + meta Defense Coverage Matrix as the truth-telling artefact. This subsumes research-richness (the matrix IS the research output) without overclaiming durability. Affects PRD prose only. | Recommended — proposal ships with revised framing pinned in PR-0. |
| **Story numbering convention** | **Post-audit reversal:** sequential numbering (Story 2.18, 2.19, 2.20, 2.21) — twin-suffix-b has no precedent in `_bmad-output/implementation-artifacts/sprint-status.yaml:46-281`; the 15a/15b pattern is epic-level split, not story-level twin. Sequential keeps sprint-status.yaml grep-clean and matches existing 2.1-2.17 convention. | Recommended — applied throughout post-audit revision. |
| **PR-0 corrections-only PR insertion** (post-audit addition) | Insert PR-0 (PRD/arch corrections + INV ID renames + halt-enum reaffirmation + INVARIANTS.fork.md preservation + Coverage Matrix shape pin) BEFORE PR-1. PR-4 may fold into PR-0. Routing: PM (John) + Architect (Winston) review BEFORE any code-bearing PR ships. Net cost: +1-2 days, recovered against PR-3/PR-4 churn. | Recommended — post-audit consensus across architect-R2, PM-R3, codex-R3. |
| **Empirical capture prereq for PR-2** (post-audit promotion from PR-8) | 1-hour capture session to grep actual event names + tool surface from `codex exec --json` output (NOT docs-derived). Commit fixture at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl` with named consuming test owner. Must happen BEFORE PR-2 (was PR-8 prereq); affects both adapter event mapping + Story 2.19 matchers. | Required — schedule before PR-2 kickoff. |
| **R-CDX-2 personal evidence** (post-audit hardened) | If Tthew has already locally tested whether codex `[[hooks.PreToolUse]]` survives `--dangerously-bypass-approvals-and-sandbox`, override is **only honored with committed transcript artifact** at `_bmad-output/research/codex-yolo-survival-<date>.jsonl` showing positive + negative + canary controls all passing, with codex version + commit hash. Without recorded reproducible evidence, ship the tiered default + 30-green + ≥2-version + chaos-injection promotion gate. | Optional — without committed transcript, defaults to hardened gate. |
| **`docs/install/codex.md` content** | New file documenting codex OAuth flow + `codex features list` runtime probe (NOT TOML literal) + minimum codex version + `OPENAI_API_KEY` headless escape hatch. Sized in PR-5. | No sign-off needed — uncontroversial. |

---

## Approval

- [ ] **Tthew** — approves Sprint Change Proposal for implementation
- [ ] (Optional) JTBD answer pinned: ____________________
- [ ] (Optional) R-CDX-2 personal evidence: ☐ already tested green ☐ not tested → tier per proposal

Once approved, the workflow proceeds to **Step 5 (finalize + route)** and **Step 6 (workflow completion)**, including the `sprint-status.yaml` update from § 4.7.

---

## Provenance

This proposal was navigated via `/bmad-correct-course` with three party-mode rounds, then revised post-multi-reviewer-audit (3 rounds):

**Original proposal — party-mode navigation:**

- **Round 1** (Murat, Amelia, Winston, John): trigger framing, codex hooks parity research, AI-CLI-as-shape pattern, risk register R-CDX-1..4, John's JTBD dissent.
- **Round 2** (Murat, Amelia, Winston) + cross-model echo (Murat-codex, Amelia-codex, Winston-codex on `gpt-5.5 xhigh`): permissive default tiered, P0 trim, ccusage triage, Winston-codex's `usageTelemetry` capability proposal as Growth-tier.
- **Round 3** (Paige, Winston, Sally, Amelia-codex): knowledge-file restructure, `docs/agents/` deferred to Growth-tier, FR14j rewrite, R4 rotation flip, prompt-file de-Clauding with inline fallback prose.

**Post-audit revision — multi-reviewer audit (4 sub-agents + 2 codex instances over 3 rounds):**

- **Audit Round 1** (Architect, TEA, Dev, Edge-case-hunter sub-agents + Codex-1 technical-correctness + Codex-2 integration-gaps on `gpt-5.5 xhigh`): 32 substantive findings spanning 7 critical / 9 high / 13 medium / 3 low. Verdict split — 5 reviewers APPROVE-WITH-CORRECTIONS, Codex-2 REJECT.
- **Audit Round 2** (Architect-R2 spar): contested-items reconciliation (5+meta layer model, hardened threshold, hook-coverage parity, verdict). Lands at APPROVE-WITH-MAJOR-CORRECTIONS.
- **Audit Round 3** (PM-R3 + Codex-R3 spar): PM identifies 6 additional FR/NFR amendments + PR-0 insertion + sequential numbering reversal + JTBD reframe; Codex-R3 upgrades from REJECT → APPROVE-WITH-MAJOR-CORRECTIONS, agreeing with all four contested positions.

**Cross-reviewer alignment achieved (post-audit Round 3):** Architect-R2 + PM-R3 + Codex-R3 + 4 sub-agent positions all converge on **APPROVE-WITH-MAJOR-CORRECTIONS** with the same fix list. This revision folds those corrections in-place. See § Audit revisions for the full change list.

Cross-model agreement (3+ Claude personas + 3+ codex personas across navigation + audit rounds, on the security-critical questions) materially strengthens the recommendation: future-proof multi-CLI substrate with named gaps is the honest framing; tiered permissive default + hardened promotion gate (30-green + ≥2 codex versions + ≥1 weekly chaos-injection + canary counter) is the empirically honest path; AGENTS.md as load-bearing primary entry-point is the right architecture for a 2-CLI substrate (with INVARIANTS.fork.md precedence preserved); the 5-layer + meta Defense Coverage Matrix with codex L1 sub-columns honestly names the PreToolUse coverage gap (`web_search`/unified-exec `not-intercepted`).

---

## § Audit revisions (2026-05-04)

This section documents the post-multi-reviewer-audit changes folded into this proposal. Reviewers: 4 BMad sub-agents (Architect/Winston, TEA/Murat, Dev/Amelia, Edge-case-hunter) + 2 codex instances (gpt-5.5 xhigh) over 3 audit rounds. Final verdict (cross-reviewer aligned): **APPROVE-WITH-MAJOR-CORRECTIONS**.

### Critical corrections (7) — must fix before any PR ships

1. **Halt-enum violation removed.** Story 2.18's `CODEX_DOCTOR_REQUIRED` halt reason violated the closed 7-reason enum + autonomy guardrail (`INVARIANTS.md:47` + `packages/keel-invariants/src/invariants.manifest.ts:131`). Reframed as **pre-loop pointer error** in `ralph.py` codex-spawn path (Story 2.21).
2. **Invariant ID regex compliance.** `barrier.hooks.deny-list-canonical` failed `^INV-[a-z0-9]+(-[a-z0-9]+)+$` regex (`packages/keel-invariants/src/invariants.manifest.ts:4`). Renamed to `INV-barrier-hooks-deny-list-canonical`.
3. **"Doc-only" invariants impossible.** `INV-substrate-defense-layers` cannot be doc-only — InvariantSchema requires `sourcePath` + `contentHash` + `anchors[]`. Source-pinned to `_bmad-output/planning-artifacts/architecture.md § Substrate Security Posture`.
4. **Adapter event-name bug fixed.** Original `item.command_executed`/`item.agent_message`/`item.agent_reasoning` corrected to `item.started`/`item.updated`/`item.completed` envelopes wrapping `item.type: "command_execution" | "agent_message" | "reasoning"`. Empirical capture promoted to PR-2 prereq.
5. **Hook matcher tool names corrected.** Original `shell_tool`/`apply_patch` corrected to `Bash`/`apply_patch` (matches Edit/Write)/`mcp__*` per codex 0.128.0 verification. `shell_tool` is a feature flag, not a hook matcher.
6. **`INV-codex-hooks-feature-enabled` mechanism corrected.** Runtime probe (`codex features list | grep '^codex_hooks: enabled$'`) replaces literal TOML check, which false-failed on default-enabled installs.
7. **Story 3.34 false-green protection.** Mandatory positive + negative + canary controls per nightly run, plus hardened threshold: 30-green + ≥2 distinct codex versions + ≥1 chaos-injected deny-verification per week.

### High corrections (9)

8. **NFR10 single-volume preserved.** Reverted invented parallel `claude-auth`/`codex-auth` volumes; codex auth lives at `/home/dev/.codex/` inside the existing single named `/home/dev/` volume per PRD §546.
9. **`keel doctor` reframed.** CLI does not exist; Story 2.21 uses `ralph.py`-resident pre-loop probe instead.
10. **Story 2.1 amendment.** Devbox toolchain bakes `@openai/codex@<pinned>` alongside claude (post-audit addition).
11. **Story 3.3 scope narrowed.** `packages/keel-templates/` is "populated in Epic 12" empty shell; Story 3.3 seeds live `.ralph/PROMPT_*.md` only at 1.0.
12. **PR-2/PR-3 ordering compatibility.** PR-0 lands first; both PR-2 and PR-3 reference already-pinned PRD/arch language.
13. **5-layer + meta Defense Coverage Matrix.** L0 egress (NFR6) + L1 hooks (with codex sub-columns: bash/apply_patch/mcp/unified-exec/web_search/other) + L2 manifest (NFR5b) + L3 halt (NFR33a) + L4 auth-token+log isolation (NFR10); M1 prompt-scan as build-time meta.
14. **Empirical capture artifact pinned.** Fixture path + consuming test owner committed at `packages/keel-invariants/test/fixtures/codex-pretooluse.jsonl` before PR-2.
15. **`-c approval_policy="never"` injection mechanism.** Added `prefix_args` field on `ToolProfile` for fixed token-pair emission; current `tool_args` shape splits on `=` and cannot emit `-c key=value` correctly.
16. **`consecutive_failures` initialization.** P0 backoff snippet requires `consecutive_failures = 0` at `ralph.py:~1740` (before `while`-loop at `:1747`); without this, snippet `NameError`s.

### Medium corrections (13)

17. **AGENTS.md target size.** Revised from 6-7 KiB to 10-11 KiB (current 6.7 KiB + ~50% of CLAUDE.md = ~4 KiB).
18. **Story 3.34 auto-promotion = bot-PR.** `keel-bot` opens reviewable PR (NOT direct push), required human approval per `AGENTS.md` "never force-push main, never skip hooks or signing."
19. **R-CDX-2 personal-evidence override hardened.** Override only honored with committed transcript artifact (positive + negative + canary controls + codex version + commit hash).
20. **CLAUDE.md fork-precedence preserved.** 25-line replacement retains pointer to `INVARIANTS.fork.md` precedence rule.
21. **NFR5b deny-signal normalizer enumerated.** All non-deny outcomes (process-fail, stdout-empty, hooks-disabled-silent-allow, partial-JSON, hooks-config absent) fail-closed → SECURITY_CRITICAL halt.
22. **Codex session-resume defer-to-Growth.** Sessions are global-per-user (not worktree-scoped); auto-resume ambiguous; `.ralph/@plan.md` is the only durable crash journal at 1.0.
23. **Cross-CLI lock contention.** Add pidfile `.ralph/.lock` to prevent concurrent invocations same worktree (no `flock`/`fcntl` in `ralph.py` today).
24. **AI_CLI_SHAPES touchpoint checklist.** Adding a 3rd shape requires changes in 6 places; pinned alongside the constant.
25. **ccusage hide-row sites expanded.** Original 2 sites (1308, 1460) expanded to 6 (215-218, 1122, 1308, 1460-1467, 1482, 1486, 1719).
26. **`pnpm codex` ownership pinned.** Story 2.18 ACs pin `packages/devbox/package.json` script + reuse of single `/home/dev/` volume.
27. **Pre-loop probe sentinel hash-bound.** `.ralph/.codex-doctor-pass` content = sha256 of `.codex/hooks.json` + codex version + matchers; pre-commit hook rejects committed sentinel.
28. **R4 rotation upkeep trigger.** AGENTS.md grows "When to update CLAUDE.md" section naming trigger conditions.
29. **`docs/ralph.md` + `README.md` codex-aware updates.** Both still describe Claude-only flow; added to PR-2/PR-3 deliverables.

### Low corrections (3)

30. **AGENTS.override.md precedence.** Codex hierarchy checks `AGENTS.override.md` BEFORE `AGENTS.md` per directory; named in FR14j rewrite.
31. **Line drift `:215` → `:218`.** ccusage `--since today` site corrected (`today` defined at `:215`, subprocess call at `:218`).
32. **`CLAUDE_CODE_TASK_LIST_ID` env always set.** Cleanup nit: gate or rename to CLI-neutral; flagged for separate hygiene pass.

### Structural changes

- **PR-0 corrections-only docs PR inserted ahead of PR-1.** Folds PRD amendments + arch corrections + INV ID renames + halt-enum reaffirmation + INVARIANTS.fork.md preservation + Coverage Matrix shape pin. PR-4 may fold into PR-0.
- **Story numbering reversed: twin-suffix-b → sequential.** Stories 2.8b/2.15b/2.16b renumbered to 2.18/2.19/2.20; original 2.18 renumbered to 2.21 (and reframed as pre-loop probe).
- **JTBD reframed.** "Future-proof multi-CLI substrate with named gaps" replaces implicit "research-richness" — the verified L1 coverage gap means substrate parity has a named ceiling visible only from the codex side.

### Additional PRD amendments (6 beyond original §2.3)

- FR40 — extend prompt-injection scan to `AGENTS.md` + `.codex/AGENTS.md` + `.codex/hooks.json` + `.codex/hooks/**`.
- NFR5a — explicit tool-surface coverage clause.
- FR14k — codex session-resume defer-to-Growth.
- Story 2.1 / PRD §545 — bake `@openai/codex@<pinned>` in devbox toolchain.
- NFR6 — cited as Layer 0 in Defense Coverage Matrix (no new NFR; existing NFR6 covers default-deny egress).
- (NFR5b — non-deny shape enumeration covered above.)
