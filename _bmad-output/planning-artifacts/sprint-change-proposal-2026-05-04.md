---
title: Sprint Change Proposal — Codex first-class parity + knowledge-file restructure
date: 2026-05-04
author: Tthew (via /bmad-correct-course + party mode rounds 1-3)
project: ralph-bmad / Keel
scope: Major (PM + Architect involvement)
status: draft — awaiting Tthew approval
related: PRD FR3, FR5, FR7, FR14j, FR14k; NFR5a, NFR5b, NFR10, NFR30; Epic 2 (Stories 2.8, 2.10, 2.15, 2.16, 2.17); Epic 3 (Stories 3.2, 3.10); architecture.md § tools.json + § Knowledge-file contract + § Substrate Security Posture
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
- **Coverage gap confirmed via fresh codex docs research (2026-05-04, fetched live from developers.openai.com/codex):**
  - Codex DOES have `[[hooks.PreToolUse]]` (in `~/.codex/config.toml` or `<repo>/.codex/hooks.json`), feature-flagged behind `[features] codex_hooks = true`.
  - Codex docs do NOT explicitly state `PreToolUse` survives `--dangerously-bypass-approvals-and-sandbox` (Claude's docs DO guarantee this).
  - Codex tool-name surface differs (`shell_tool` / `apply_patch` rather than `Read` / `Grep` / `Glob`) — denylist matchers must be re-derived empirically.
  - Codex reads `AGENTS.md` natively (3-tier hierarchy: global → Git-root walk → cwd; deeper overrides shallower; 32 KiB cap).
  - `codex exec --json` emits JSONL stream events (`thread.started`, `turn.completed`, `item.command_executed`); no per-turn cost field.
  - Session resume via `~/.codex/sessions/<uuid>.jsonl` + `codex exec resume --last`.
- **CLAUDE.md duplicates ~50% of AGENTS.md content.** Today's CLAUDE.md (80 lines) carries substrate-level truth (commands table, architecture, knowledge-file contract, promotion rules, git/PR conventions) that codex never reads. Codex enters the repo half-blind — only ~6 of CLAUDE.md's bullets are actually Claude-Code-specific.
- **PROMPT_build.md / PROMPT_plan.md leak Claude-flavored language** — `TaskList` / `TaskCreate` (Claude-Code APIs), "Sonnet subagents" (Claude-only model), "Claude Code slash commands" (Claude-only invocation surface), `.claude/` exclusion in source-scan without `.codex/` parallel.
- **The 2026-04-17 research report (`technical-keel-ralph-bmad-research-2026-04-17.md:175`)** explicitly parked codex as Tier-2 "not blocked at the quality-gates story." This proposal supersedes that framing.

**What changed since 2026-04-17:** Tthew's stated preference shifted from "Tier-2 acceptable" to "more durable." This is a legitimate input but constitutes architectural taste, not new external evidence. The substrate's dual-posture tie-breaker ("research-output richness wins over substrate ship-velocity") justifies the depth: monthly absorption sprints under both CLIs become a research artifact in their own right.

---

## Section 2 — Impact Analysis

### 2.1 Epic Impact

| Epic | Status | Impact |
|------|--------|--------|
| Epic 1 — Substrate scaffolding | done | No story changes. INVARIANTS.md acquires new entries (`INV-substrate-defense-layers`, `barrier.hooks.deny-list-canonical`, `INV-codex-hooks-feature-enabled`); `packages/keel-invariants/` acquires `hookBarrier.ts` data + per-CLI emitters. These land via Epic 2 stories that depend on them; no Epic-1 retroactive change. |
| Epic 2 — Packaged devbox | backlog | **5 existing stories amended + 4 new stories.** See Story Impact below. |
| Epic 3 — Ralph build mode | backlog | **2 existing stories amended + 1 new story.** Cross-CLI crash-journal contract reframe in 3.10; tool-agnostic prompt template seed in 3.3. |
| Epic 14 — Research corpus | backlog | Optional: add a row in `docs/research/test-ids.md` for cross-CLI absorption-delta as a Growth-tier research dimension. Out of 1.0 critical-path scope. |
| Epics 4-13, 15a, 15b | backlog | No structural changes. |

**Epic order/priority unchanged.**

### 2.2 Story Impact

**Epic 2 amendments (existing stories):**

| Story | Current scope | Proposed amendment |
|-------|---------------|--------------------|
| 2.8 — Claude Code OAuth via `pnpm claude` | claude-only | Rename to "AI-CLI OAuth via `pnpm <cli>`"; existing claude path stays as Tier-1 reference impl; **new twin Story 2.8b** for codex (`pnpm codex` → `codex login`; tokens at `/home/dev/.codex/`; named volume `codex-auth:/home/dev/.codex` parallel to existing claude-auth mount). |
| 2.10 — Prerequisite check (Docker + Claude auth + gh auth) | claude-only auth probe | Extend AC: when `aiCli === "codex"`, prereq check ALSO probes `~/.codex/auth.json` (or `OPENAI_API_KEY`) AND parses `~/.codex/config.toml` to assert `[features] codex_hooks = true`. Fail-pointer-error citing `docs/install/codex.md` if either missing. (Per Winston's "same-machinery-as-FR5" recommendation.) |
| 2.15 — Committed `.claude/settings.json` deny rules | claude-only | Rename to "Hook-barrier emission — committed per-CLI config from canonical deny-list." Adds: canonical `packages/keel-invariants/src/hookBarrier.ts` data module. **New twin Story 2.15b** for codex emitter (`emitCodexHooks() → .codex/hooks.json` with re-derived `shell_tool` / `apply_patch` matchers). |
| 2.16 — Claude PreToolUse hooks | claude-only | Rename to "PreToolUse hook implementation — per-CLI." Existing claude scope preserved. **New twin Story 2.16b** for codex `.codex/hooks/block-secret-access.sh` PreToolUse hook with deny-signal normalizer (exit-2 + JSON `permissionDecision: deny`). |
| 2.17 — Hook + settings bypass-resistance (git-layer) | claude-only manifest entries | Extend AC: invariant manifest registers `INV-claude-hook-secret-denylist` AND `INV-codex-hook-secret-denylist`; pre-merge sync gate covers `.claude/settings*.json`, `.claude/hooks/**`, `.codex/hooks.json`, `.codex/hooks/**`. NFR5b 3-strike halt counter normalizes both deny-signal shapes. |

**Epic 2 new stories:**

- **2.8b** — Codex OAuth via `pnpm codex` (size: S; depends on 2.5 named-volume infra).
- **2.15b** — `emitCodexHooks()` per-CLI emitter (size: M; depends on canonical deny-list from 2.15).
- **2.16b** — Codex `.codex/hooks/block-secret-access.sh` PreToolUse hook + deny-signal normalizer (size: M; depends on 2.15b; **empirical prereq** — capture `codex exec --json` output once to nail down actual tool surface names).
- **2.18 (new)** — One-time `keel doctor --tool codex` smoketest writes `.ralph/.codex-doctor-pass` sentinel verifying (a) codex auth present, (b) `codex_hooks=true` in config, (c) basic deny-list smoke (read of `.envrc.test-fixture` blocked). Halt with reason `CODEX_DOCTOR_REQUIRED` until sentinel present. Size: S.

**Epic 3 amendments:**

| Story | Current scope | Proposed amendment |
|-------|---------------|--------------------|
| 3.2 — Ralph multi-iteration loop with `claude -p` | claude-only invocation | Rename to "Ralph multi-iteration loop with configured AI CLI." Replace `claude -p` references with "the configured AI CLI binary"; rephrase effort-default narrative as Claude-default (`xhigh`) with codex-default deferred to codex profile (codex doesn't expose `--effort` flag). Add AC for tool-axis selection via `--tool {claude\|codex}` and `.ralph/tools.json` profile resolution. |
| 3.3 — Prompt template seeds | claude-shaped | Re-seed `packages/keel-templates/PROMPT_*.template.md` with tool-aware-fallback prose (per AC3/AC4 surgery in this proposal § 4.2). Single template; per-CLI deltas inline. |
| 3.10 — Native Claude Code task list as crash journal | claude-only | Reframe as "Cross-CLI crash-journal contract." `.ralph/@plan.md` becomes the substrate-invariant crash journal (per FR14k). Native Claude task list is a Claude-only convenience mirror that survives hard kills; codex equivalent is `~/.codex/sessions/<uuid>.jsonl` with auto-resume via `codex exec resume --last`. Spec narrative updated; no behavioral change to `.ralph/@plan.md` schema. |

**Epic 3 new story:**

- **3.34 (new)** — Nightly `--yolo` bypass-survival promotion gate. Test that codex `[[hooks.PreToolUse]]` denylist holds when codex runs with `--dangerously-bypass-approvals-and-sandbox`. After 30 consecutive green nightly runs, flip codex profile default from `--sandbox=workspace-write -c approval_policy="never"` to `--dangerously-bypass-approvals-and-sandbox`. Size: M (CI workflow + flake-budget integration + auto-promotion script).

### 2.3 PRD Conflicts

| FR/NFR | Current text (pinned implicit Claude assumption) | Proposed change |
|--------|--------------------------------------------------|-----------------|
| FR3 | "Developer can authenticate Claude Code and `gh` CLI once per devbox via browser OAuth flows" | "Developer can authenticate the configured AI CLI (Claude Code or codex) and `gh` CLI once per devbox via browser OAuth flows" |
| FR5 | "System can enforce prerequisites (Docker runtime, Claude Code authentication, `gh` CLI authentication)" | "System can enforce prerequisites (Docker runtime, configured AI CLI authentication AND CLI-specific feature-flag/config preconditions, `gh` CLI authentication)" — codex-specific feature-flag check is `[features] codex_hooks = true` |
| FR7 | "Agent can execute a multi-iteration loop... invoking `claude -p` with adaptive thinking" | "Agent can execute a multi-iteration loop... invoking the configured AI CLI binary (`claude -p` or `codex exec --json`) with CLI-appropriate effort/thinking settings" |
| FR14j | "Agent can maintain three audience-scoped knowledge files (`RALPH.md`, `AGENTS.md`, `CLAUDE.md`) with pinned promotion rules" | "Agent maintains layered knowledge files: `AGENTS.md` (substrate operational truth, read by every agent), `RALPH.md` (Ralph's private journal), `INVARIANTS.md` (machine-enforced rules index). Per-CLI supplement files (e.g., `CLAUDE.md`) are OPTIONAL and contain only CLI-specific deltas — never duplicate AGENTS.md content. Promotion rules pinned in AGENTS.md." (Tool-agnostic; deliberately no `CODEX.md` named.) |
| FR14k | "...native Claude Code task list as the iteration's crash journal" | "...`.ralph/@plan.md` as the iteration's substrate-invariant crash journal; native CLI task-list APIs (Claude `TaskList`/`TaskCreate`) are optional convenience mirrors that may survive hard kills" |
| NFR5a | Hooks-barrier described as Claude-Code-specific | Reframe as substrate-invariant: "in-session secret-access barrier via PreToolUse hooks emitted from canonical deny-list (`packages/keel-invariants/src/hookBarrier.ts`); per-CLI config files (`.claude/settings.json`, `.codex/hooks.json`) are projections of the canonical data" |
| NFR5b | bypass-resistance via git-layer manifest entries `INV-claude-hook-secret-denylist` | Extend manifest to register both `INV-claude-hook-secret-denylist` and `INV-codex-hook-secret-denylist`; deny-signal normalizer covers exit-2 + JSON `permissionDecision: deny` shapes |
| NFR10 | "Claude Code and `gh` CLI authentication tokens persisted only inside devbox volume" | "Configured AI CLI (Claude Code, codex) and `gh` CLI authentication tokens persisted only inside devbox volume; named volumes `claude-auth:/home/dev/.claude/`, `codex-auth:/home/dev/.codex/`, `gh-config:/home/dev/.config/gh/`" |
| NFR30 | "Every Keel major version documents tested model generation, Claude Code CLI version, BMad version, and Ralph version" | "...documents tested model generation per supported AI CLI (Claude Code Opus N, codex gpt-N), AI CLI versions, BMad version, Ralph version. Multi-CLI matrix in `docs/upgrades/major-releases.md`." |

**New PRD invariant:** `INV-substrate-defense-layers` — pinned in PRD § Implementation Considerations + architecture.md § Substrate Security Posture. Names the 4-layer defense model:

1. **In-session hooks (NFR5a)** — PreToolUse barrier emitted per-CLI from canonical deny-list. Coverage: claude documented; codex empirical-pending.
2. **Git-layer invariant manifest (NFR5b)** — pre-commit sync gate.
3. **Ralph runtime halt threshold (NFR33a)** — 3-strike SECURITY_CRITICAL halt.
4. **S4 prompt-injection scan (FR40)** — pre-commit pattern scan.

> *Permission prompts are out-of-band UX, not part of the defense model. Substrate runs autonomous; barriers-and-gates enforce safety.*

### 2.4 Architecture Conflicts

| Section | Change |
|---------|--------|
| § tools.json (line ~829) | Codex profile fixed: `base_args=["exec", "--json"]`; `flag_map` corrected (`unsafe → --dangerously-bypass-approvals-and-sandbox`, `sandbox → --sandbox`, `model → --model`, `ephemeral → --ephemeral`); `defaults={"unsafe": False, "sandbox": "workspace-write"}` at 1.0 (tiered — flips to `unsafe: True` after 30-green promotion); `stream_format="codex-json"` (new). Tool config also documents `-c approval_policy="never"` injection via `tool_args`. |
| § Substrate-Authorship-Constants | Add `AI_CLI_SHAPES = ["claude", "codex"]`. Add `HOOK_BARRIER_DENY_LIST` constant pointing at `packages/keel-invariants/src/hookBarrier.ts`. |
| § Substrate Security Posture (new subsection) | Pin `INV-substrate-defense-layers`. Add **Defense Layer Coverage Matrix** (rows: claude, codex; columns: in-session hooks, git-layer manifest, runtime halt, prompt-scan; cells: documented \| empirical-pending \| not-applicable). Codex × in-session hooks = empirical-pending until Story 3.34 ships 30-green. |
| § Knowledge-file contract | Replace 4-row table with: AGENTS.md (substrate primary, every agent; soft 24 KiB / hard 30 KiB budget); RALPH.md (Ralph private); INVARIANTS.md (machine-enforced index); `<CLI>.md` (optional per-CLI delta, ≤25 lines, signpost-only — no duplication of AGENTS.md content). Pin: "AGENTS.md is the only file every agent is GUARANTEED to read." |
| § RC1-RC3 (research corpus) | Optional Growth-tier addition: cross-CLI absorption-delta as a sprint-log dimension. Out of 1.0 critical-path. |
| § Ralph Path-Resolution Contract | Unchanged — already CLI-neutral. |

### 2.5 UI/UX Conflicts

The substrate's UX contract is "agent as first-class user" (architecture.md §89). The knowledge-file + prompt-file restructure addresses the existing UX wound: codex agents enter the repo half-blind because the truth lives in CLAUDE.md (which codex never reads). No external user-facing UI changes.

### 2.6 Technical Impact

**`ralph.py` changes:**

- P0 — consecutive-failure backoff (~10 LOC at `ralph.py:~1822` exit-code handler): `min(60, 2**n)` exponential cap; reset on exit_code=0; no new halt reason; no schema change.
- P1 — codex profile correctness (`ralph.py:586-596`): updated `flag_map`, `base_args`, `defaults`, `stream_format`. ~15 LOC.
- P2 — `CodexJsonAdapter` parallel to `ClaudeStreamJsonAdapter` (`ralph.py:1036-1160`): parses codex JSONL events; populates `turns`, `tokens`, `tool_use` capabilities; cost + context-pct render as em-dash (codex emits no cost). ~200 LOC + JSONL fixture for tests.
- P3 — ccusage `--since today` bug fix (`ralph.py:215`): drop `--since` arg; rely on `--active`. Fixes midnight-edge. ~2 LOC.
- P4 — ccusage hide-row when tool != claude (`ralph.py:1308`, `ralph.py:1460`): gate row render + `set_interval` registration. ~10 LOC.
- P5 — codex telemetry replacement (CodexJsonAdapter accumulates `turn.completed.usage.{input_tokens,output_tokens}`; header shows `Tokens: in/out`; no cost estimate). Bundled with P2.

**Knowledge files:**

- `AGENTS.md` absorbs Common commands table, High-level architecture (compact), single canonical Knowledge-file contract table, single Promotion rules table. Adds `Tool Entry Points` section; adds `State / Crash Journal` section pointing at `.ralph/@plan.md` as cross-CLI canonical; adds `Tool dirs` section listing `.claude/` + `.codex/` exclusions; adds `BMAD Invocation` section pointing at `_bmad/_config/bmad-help.csv` as catalog source. Voice unified to imperative second-person.
- `CLAUDE.md` shrinks to ~15-25 lines per Sally's draft (Section 4.1 below).
- `RALPH.md` unchanged structurally (private journal).
- `INVARIANTS.md` acquires new manifest IDs.
- Prompt files re-seeded per Section 4.2.

**`packages/keel-invariants/`:**

- New `src/hookBarrier.ts` — canonical deny-list as data + `emitClaudeHooks()` + `emitCodexHooks()` emitters + invariant manifest registration of `barrier.hooks.deny-list-canonical`.

---

## Section 3 — Recommended Approach

**Direct Adjustment** (not Rollback, not MVP Review). Specifically:

- **Codex tier:** First-class — substrate axis `aiCli: "claude" | "codex"`, both Tier-1 implementations, claude as default-emitted choice.
- **Parity bar:** Substrate-invariant ("more durable") — every substrate invariant has a codex-side equivalent. Tier-1 quality is gated empirically (30-green promotion gate) for the bypass-survival concern.
- **Tiered permissive default:** Codex profile defaults to `--sandbox=workspace-write -c approval_policy="never"` at 1.0. Permissive (no prompts), hooks alive. Promotes to `--dangerously-bypass-approvals-and-sandbox` after Story 3.34 ships 30 consecutive green nightly bypass-survival runs. Per Murat's risk model: do not promote undocumented security behavior on vibes.
- **Defense Layer Coverage Matrix tells the truth.** Codex × in-session hooks = empirical-pending until promotion gate fires. Substrate ships honestly with the gap named.
- **Track-of-PRs sequenced delivery.** Five PRs in dependency order — see Section 5.
- **Scope:** Major. Requires PM (FR/NFR rephrasing) + Architect (contract design + Defense Layer Coverage Matrix) + Developer (ralph.py runtime + per-CLI hook emitters) handoff.

**Rationale (in dependency order):**

1. The infinite-crash bleed must stop first (PR-1 is XS) so empirical codex testing can proceed without burning iteration time.
2. Codex must run at all (PR-2: profile correctness + adapter) before any parity story can be empirically validated.
3. Knowledge-file restructure (PR-3) unblocks codex agents from operating half-blind; it's pure docs and ships independent of runtime work.
4. PRD/Architecture edits (PR-4) follow once contract is settled — they pin language for downstream stories.
5. Codex-twin Epic 2 stories + Story 3.34 (PR-5+) deliver substrate-invariant parity in dependency-correct order.

**Effort estimate:**

- PR-1 (XS): ~10-15 LOC + 1 LOC ccusage. ½ day.
- PR-2 (S): ~30 LOC profile + ~200 LOC adapter + JSONL fixture + tests. 2-3 days.
- PR-3 (M): docs surgery, ~150-line CLAUDE.md edit + ~200-line AGENTS.md absorbs + prompt-file edits. 1-2 days.
- PR-4 (M): PRD/Architecture rephrasing — sensitive editing of long docs. 2-3 days.
- PR-5+ (codex-twin Epic 2 + 3.34): 2.8b (S, 1 day), 2.10 amendment (XS, ½ day), 2.15b (M, 2-3 days, **empirical prereq** — capture codex tool-name surface), 2.16b (M, 2-3 days), 2.17 amendment (S, 1 day), 2.18 keel doctor (S, 1 day), 3.34 nightly bypass-survival (M, 2-3 days). Total: ~10-14 days.

**Total elapsed estimate:** ~3 weeks of Ralph build-iterations (with normal review cadence).

**Risk assessment:**

- **Highest risk:** R-CDX-2 (`--yolo` bypass-survival undocumented). Mitigated by tiered default + 30-green promotion gate. Worst case: codex ships with `--sandbox=workspace-write` permanently, never promotes to `--yolo`. Acceptable for substrate posture.
- **Empirical prereq:** Story 2.15b matchers must be re-derived against captured `codex exec --json` output (not docs-derived). Schedule 1-hour capture session before writing 2.15b matchers; otherwise risk shipping matchers against wrong tool names.
- **Documentation drift:** PR-3 (knowledge-file restructure) must land before any codex iteration runs in production, or codex agents continue operating half-blind.

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

**`CLAUDE.md` target (per Sally's draft):**

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

## Pointers

- For Ralph-loop guidance: `RALPH.md`
- For machine-enforced rules: `INVARIANTS.md`
- For substrate operational truth: `AGENTS.md`
```

**FR14j rewrite (per Winston):**

> Agent maintains layered knowledge files: `AGENTS.md` (shared substrate operational truth, read by every agent), `RALPH.md` (Ralph's private journal), `INVARIANTS.md` (machine-enforced rules index). Per-CLI supplement files (e.g., `CLAUDE.md`) are OPTIONAL and contain only CLI-specific deltas — never duplicate AGENTS.md content. Promotion rules pinned in AGENTS.md.

**R4 (knowledge-file upkeep contract) rotation change:** Per-iteration nudge rotates `AGENTS.md / RALPH.md / INVARIANTS.md`. CLAUDE.md drops out — it changes only when Claude Code itself ships a new quirk (low-frequency event, doesn't deserve a per-iteration touch).

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

### 4.5 Architecture edits (PR-4, paired with PRD)

Per § 2.4 above. Defense Layer Coverage Matrix added (rows: claude, codex; columns: 4 layers; cells: documented \| empirical-pending \| not-applicable). § tools.json codex profile fix documented inline. § Knowledge-file contract rewrite per Winston. § Substrate-Authorship-Constants gets `AI_CLI_SHAPES` + `HOOK_BARRIER_DENY_LIST`.

### 4.6 New invariants (PR-2 + PR-5+)

| Invariant ID | Path | Description | Story |
|--------------|------|-------------|-------|
| `INV-substrate-defense-layers` | doc-only | 4-layer defense model named in PRD + arch | PR-4 |
| `barrier.hooks.deny-list-canonical` | `packages/keel-invariants/src/hookBarrier.ts` | Canonical deny-list + per-CLI emitters | 2.15 (amended) |
| `INV-codex-hooks-feature-enabled` | `~/.codex/config.toml` `[features] codex_hooks = true` | Substrate hard-fails if off when `--tool codex` | 2.10 (amended) |
| `INV-codex-hook-secret-denylist` | `.codex/hooks.json` + `.codex/hooks/block-secret-access.sh` | Codex PreToolUse hook + deny-rules | 2.16b |
| (existing) `INV-claude-hook-secret-denylist` | `.claude/settings.json` + `.claude/hooks/block-secret-access.sh` | Unchanged | 2.15/2.16 (existing) |

### 4.7 sprint-status.yaml updates

Pending Tthew approval — to be applied during workflow Step 5 finalization. Proposed delta:

```yaml
# Epic 2 amendments (existing entries renamed; new entries added):
2-8-claude-code-oauth-via-pnpm-claude: backlog                   # rename to "ai-cli-oauth"
2-8b-codex-oauth-via-pnpm-codex: backlog                          # NEW
2-10-prerequisite-check-... (extended scope, no rename)
2-15-... (renamed: hook-barrier-emission-per-cli)
2-15b-codex-hooks-emitter: backlog                                # NEW
2-16-... (renamed: pretooluse-hook-implementation-per-cli)
2-16b-codex-pretooluse-hook: backlog                              # NEW
2-17-... (extended scope, no rename)
2-18-keel-doctor-codex-smoketest: backlog                         # NEW

# Epic 3 amendments:
3-2-... (rephrased, no rename)
3-3-... (re-seeded templates, no rename)
3-10-... (reframed crash-journal contract, no rename)
3-34-nightly-yolo-bypass-survival-promotion-gate: backlog         # NEW
```

---

## Section 5 — Implementation Handoff

### Scope classification: **Major**

Requires PM (FR/NFR rephrasing in PRD), Architect (contract design + Defense Layer Coverage Matrix in architecture.md), Developer (ralph.py runtime + per-CLI hook emitters + new stories) coordination.

### Recommended PR sequence

| PR | Size | Contents | Depends on | Unblocks |
|----|------|----------|------------|----------|
| **PR-1** | XS (~½ day) | ralph.py P0 backoff (`ralph.py:1822`); ccusage `--since today` bug fix (`ralph.py:215`) | None — standalone bleed-stop | Empirical codex testing without burning iteration time |
| **PR-2** | S (~2-3 days) | ralph.py P1 codex profile correctness; P2 `CodexJsonAdapter`; P4 ccusage hide-row when tool != claude; P5 codex telemetry replacement | PR-1 (clean exit-code handling); empirical capture session for codex JSONL fixture | "Codex actually runs" — Ralph loop functional under `--tool codex` with `--sandbox=workspace-write` permissive default |
| **PR-3** | M (~1-2 days) | Knowledge-file restructure: AGENTS.md absorbs; CLAUDE.md shrinks to ~25-line signpost; PROMPT_build.md + PROMPT_plan.md de-Clauded with inline fallback prose; FR14j rewrite (in `_bmad-output/planning-artifacts/prd.md`); R4 rotation flip | None (pure docs) | Codex agents stop operating half-blind; PR-4 cleaner because contract is settled |
| **PR-4** | M (~2-3 days) | PRD edits (FR3, FR5, FR7, FR14j, FR14k, NFR5a, NFR5b, NFR10, NFR30) + new `INV-substrate-defense-layers`; architecture.md edits (§ tools.json, § Substrate-Authorship-Constants, § Substrate Security Posture + Defense Layer Coverage Matrix, § Knowledge-file contract rewrite) | PR-3 (knowledge-file contract pinned first) | Downstream stories have stable language to reference |
| **PR-5** | S (~1 day) | Story 2.8b: `pnpm codex` codex OAuth + named volume `codex-auth:/home/dev/.codex/` parallel mount | Epic 2 Story 2.5 (named volume infra) | Codex auth in devbox |
| **PR-6** | XS (~½ day) | Story 2.10 amendment: prereq check extends to codex (auth + `codex_hooks=true` config flag) | PR-5 | Substrate doctor gates codex iterations with sentinel |
| **PR-7** | XS (~½ day) | Story 2.18: `keel doctor --tool codex` writes `.ralph/.codex-doctor-pass` sentinel after smoketest | PR-2 (codex profile runs); PR-6 (prereq check exists) | Per-CLI doctor sentinel pattern shipped |
| **PR-8** | M (~2-3 days) | Story 2.15 amendment + Story 2.15b: canonical `packages/keel-invariants/src/hookBarrier.ts` data + `emitClaudeHooks()` + `emitCodexHooks()`; INVARIANTS.md updates with new manifest IDs | PR-4 (canonical contract pinned); **empirical prereq:** capture `codex exec --json` output once to nail down `shell_tool` / `apply_patch` matchers | Hook-barrier deny-list canonical |
| **PR-9** | M (~2-3 days) | Story 2.16b: `.codex/hooks/block-secret-access.sh` PreToolUse hook + deny-signal normalizer (exit-2 + JSON `permissionDecision: deny`) | PR-8 (canonical deny-list exists) | Codex in-session hook barrier shipped (empirical-pending coverage) |
| **PR-10** | S (~1 day) | Story 2.17 amendment: git-layer manifest + sync gate covers `.codex/hooks.json`, `.codex/hooks/**`; NFR5b 3-strike halt counter normalizes both deny-signal shapes | PR-9 | Bypass-resistance covers both CLIs |
| **PR-11** | M (~2-3 days) | Story 3.34: nightly `--yolo` bypass-survival CI workflow + 30-green auto-promotion script (flips codex profile default `unsafe: False → True`) | PR-9 (codex hooks emitter shipped); PR-10 (manifest covers codex) | Defense Layer Coverage Matrix codex × in-session-hooks cell promotes empirical-pending → documented |

**Total elapsed estimate:** ~3 weeks of Ralph build-iterations.

### Deliverables

- This Sprint Change Proposal at `_bmad-output/planning-artifacts/sprint-change-proposal-2026-05-04.md` ✓ (this file)
- 11 PRs delivered in dependency order
- PRD changelog entry for the codex-parity escalation
- Updated `_bmad-output/implementation-artifacts/sprint-status.yaml` reflecting renamed + new stories
- `INVARIANTS.md` registers new manifest IDs
- `docs/install/codex.md` (new) documenting codex OAuth + `codex_hooks=true` config requirement
- `docs/agents/` subdir is **not** created at 1.0 (per Winston's "boring technology" call) — promoted to Growth-tier evolution if 3rd CLI lands

### Success criteria

- **PR-1:** Ralph loop running `--tool codex` no longer infinite-loops on tool-launch failures; ccusage row shows non-zero data at 00:30 local.
- **PR-2:** `uv run ralph.py build --tool codex` completes one iteration successfully; CodexJsonAdapter populates header tokens correctly; em-dashes render gracefully for cost/context.
- **PR-3:** Codex agent entering the repo for the first time can execute correctly using only AGENTS.md as the entry point; `wc -l CLAUDE.md` ≤ 30; PROMPT_build.md / PROMPT_plan.md grep -c claude-specific-language drops to ≤ 5 (CLI-named adapter callouts only).
- **PR-4:** PRD validation passes; FR14j rewrite + INV-substrate-defense-layers reviewed by John (PM agent) without scope objections; architecture.md Defense Layer Coverage Matrix renders cleanly.
- **PR-11:** 30 consecutive nightly green bypass-survival runs trigger codex profile default flip from `unsafe: False` to `unsafe: True`; Defense Layer Coverage Matrix codex × in-session-hooks cell flips to "documented".

### Routing (per scope classification)

- **PR-3, PR-4** (PRD + Architecture changes) → Product Manager (John) + System Architect (Winston) for review.
- **PR-1, PR-2** (ralph.py runtime) → Developer (Amelia) for direct implementation.
- **PR-5 through PR-11** (codex-twin Epic 2 + Epic 3 stories) → Developer (Amelia) per BMad story-execution flow (`/bmad-create-story` → `/bmad-dev-story` → `/bmad-code-review`).

---

## Section 6 — Open items requiring Tthew sign-off

| Item | Recommendation | Required for proposal approval? |
|------|----------------|--------------------------------|
| **JTBD answer** (John's round-1 dissent) — vendor-hedge / future-proof / research-richness / fork-friendliness / other | Implicit "research-richness" framing per dual-posture tie-breaker. Affects PRD prose only. | Optional — proposal can ship with implicit framing; John will likely flag at PR-4 PRD review. |
| **Story numbering convention** | Twin-suffix-b within Epic 2 (e.g., 2.8b) rather than new Epic 2b dedicated. Lower ceremony; sprint-status.yaml stays clean. | Recommended — used throughout this proposal. |
| **Empirical prereq for PR-8** | 1-hour capture session to grep `item.command_executed.command` from `codex exec --json` output. Must happen BEFORE writing 2.15b matchers. | Required — schedule before Story 2.15b kickoff. |
| **R-CDX-2 personal evidence** | If Tthew has already locally tested whether codex `[[hooks.PreToolUse]]` survives `--dangerously-bypass-approvals-and-sandbox` and observed it survives, override Murat's tiered-default proposal and ship `--yolo` as default at 1.0 (skip the 30-green promotion gate). | Optional — affects PR-2 codex profile defaults + PR-11 scope. |
| **`docs/install/codex.md` content** | New file documenting codex OAuth flow + `codex_hooks=true` requirement + `OPENAI_API_KEY` headless escape hatch. Sized in PR-5. | No sign-off needed — uncontroversial. |

---

## Approval

- [ ] **Tthew** — approves Sprint Change Proposal for implementation
- [ ] (Optional) JTBD answer pinned: ____________________
- [ ] (Optional) R-CDX-2 personal evidence: ☐ already tested green ☐ not tested → tier per proposal

Once approved, the workflow proceeds to **Step 5 (finalize + route)** and **Step 6 (workflow completion)**, including the `sprint-status.yaml` update from § 4.7.

---

## Provenance

This proposal was navigated via `/bmad-correct-course` with three party-mode rounds:

- **Round 1** (Murat, Amelia, Winston, John): trigger framing, codex hooks parity research, AI-CLI-as-shape pattern, risk register R-CDX-1..4, John's JTBD dissent.
- **Round 2** (Murat, Amelia, Winston) + cross-model echo (Murat-codex, Amelia-codex, Winston-codex on `gpt-5.5 xhigh`): permissive default tiered, P0 trim, ccusage triage, Winston-codex's `usageTelemetry` capability proposal as Growth-tier.
- **Round 3** (Paige, Winston, Sally, Amelia-codex): knowledge-file restructure, `docs/agents/` deferred to Growth-tier, FR14j rewrite, R4 rotation flip, prompt-file de-Clauding with inline fallback prose.

Cross-model agreement (3 Claude personas + 3 codex personas on the security-critical questions) materially strengthens the recommendation: substrate-invariant parity is durable; tiered permissive default is the empirically honest path; AGENTS.md as load-bearing primary entry-point is the right architecture for a 2-CLI substrate.
