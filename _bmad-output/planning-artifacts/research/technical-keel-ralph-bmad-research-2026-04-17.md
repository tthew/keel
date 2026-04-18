---
stepsCompleted: [1, 2, 3, 4, 5]
inputDocuments:
  - "_bmad-output/planning-artifacts/prfaq-ralph-bmad.md"
  - "_bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md"
  - "ralph.py"
  - "PROMPT_build.md"
  - "PROMPT_plan.md"
  - "AGENTS.md"
  - "CLAUDE.md"
  - "RALPH.md"
  - "docs/ralph.md"
workflowType: 'research'
lastStep: 5
research_type: 'technical'
research_topic: 'validate all technical specifications + Ralph/BMAD/Keel greenfield integration'
research_goals:
  - Confirm every technical claim in the PRFAQ is real and current
  - Confirm every Claude Code flag exercised by ralph.py exists on the live CLI
  - Study Ghuntley's canonical Ralph Wiggum technique to surface lessons for the PRD
  - Design how Ralph + BMAD + Keel should integrate for greenfield project kickoff
user_name: 'Tthew'
date: '2026-04-17'
web_research_enabled: true
source_verification: true
---

# Research Report: Technical Validation — Keel stack, Ralph loop, and BMAD integration

**Date:** 2026-04-17
**Author:** Tthew
**Research Type:** technical

---

## Research Overview

This report validates the technical specifications asserted across three surfaces in this workspace:

1. **The PRFAQ for Keel** (`_bmad-output/planning-artifacts/prfaq-ralph-bmad.md`) — concept-level technical claims about the substrate Keel will ship (stack, tooling, quality-gate architecture, market-timing claims).
2. **The Ralph loop implementation** (`ralph.py`) — every Claude Code flag, environment variable, and event-stream shape Ralph depends on.
3. **The Ralph technique itself** — Ghuntley's canonical design (how-to-ralph-wiggum), plus adjacent prior art (bmalph) relevant to the Ralph + BMAD + Keel greenfield question.

Every claim below is labeled **[CONFIRMED]**, **[CORRECTED]**, **[FLAG]**, or **[UNKNOWN]**. Corrections and flags are the only load-bearing items for the PRD.

---

## Part 1 — Claude Code / Ralph surface area

All twelve canonical flags Ralph renders into the `claude` invocation (see `ralph.py:229-252`) have been verified against the live `claude --help` output on this machine and cross-checked against Anthropic's public 2026 documentation.

### Flag-by-flag verification

| Canonical (ralph.py) | CLI flag | Live `claude --help` | Web docs | Notes |
|---|---|---|---|---|
| `model` | `--model` | [CONFIRMED] | [CONFIRMED] | Aliases `opus`/`sonnet` or full IDs. |
| `effort` | `--effort` | [CONFIRMED] | [CONFIRMED] | Choices: `low, medium, high, xhigh, max`. |
| `unsafe` | `--dangerously-skip-permissions` | [CONFIRMED] | [CONFIRMED] | The well-known "YOLO" flag. |
| `permission_mode` | `--permission-mode` | [CONFIRMED] | partial | Live CLI confirms all six values Ralph enumerates at `ralph.py:503`: `acceptEdits, auto, bypassPermissions, default, dontAsk, plan`. Public docs mostly cover the first three. |
| `worktree` | `--worktree` | [CONFIRMED] | [CONFIRMED] | Optional name; companion `--tmux` flag opens iTerm2/tmux panes per worktree. |
| `debug` | `--debug` | [CONFIRMED] | [CONFIRMED] | Filters supported. |
| `settings` | `--settings` | [CONFIRMED] | [CONFIRMED] | Ralph's default `{"thinking": "adaptive"}` is a valid settings shape. |
| `max_budget_usd` | `--max-budget-usd` | [CONFIRMED] | [CONFIRMED] | Only works with `--print`. Ralph always runs with `-p`, so this is safe. |
| `fallback_model` | `--fallback-model` | [CONFIRMED] | [CONFIRMED] | Only works with `--print`. Same safety as above. |
| `-p` (base) | `-p, --print` | [CONFIRMED] | [CONFIRMED] | |
| `--output-format stream-json` (base) | `--output-format` | [CONFIRMED] | [CONFIRMED] | NDJSON event stream. |
| `--verbose` (base) | `--verbose` | [CONFIRMED] | [CONFIRMED] | |

**Conclusion:** Ralph's CLI contract is 100% aligned with the live Claude Code binary. No hallucinated flags, no drift.

### Environment-variable / state-carrying claims

- **`CLAUDE_CODE_TASK_LIST_ID` env var** — [CONFIRMED]. Introduced in Claude Code v2.1.16 (2026-01-22). Tasks persist to `~/.claude/tasks/{task_list_id}/`. Cross-session broadcast is real: updates propagate to all sessions sharing an ID. Ralph's `_cleanup_task_list()` at `ralph.py:1139-1142` targets the correct directory.
- **Opt-out env var `CLAUDE_CODE_ENABLE_TASKS=false`** — [CONFIRMED, v2.1.19+]. Worth noting for defensive deployments; Ralph doesn't need it today.
- **stream-json event shapes** — [CONFIRMED]. The `system` / `assistant` / `result` event types Ralph parses at `ralph.py:667-792` match Anthropic's documented headless-mode contract. `usage.{input_tokens, output_tokens, cache_creation_input_tokens, cache_read_input_tokens}` and `result.{cost_usd, num_turns, duration_ms, duration_api_ms}` are all real keys.

### Opus 4.7 claims (PRFAQ line 103–104)

| Claim | Verdict | Evidence |
|---|---|---|
| Opus 4.7 shipped 2026-04-16 | [CONFIRMED] | Anthropic announcement; Snowflake/Bedrock/Vertex GA the same day. |
| Model ID `claude-opus-4-7` | [CONFIRMED] | Public API docs. |
| 1M-token context, 128K max output | [CONFIRMED] | Premium pricing above 200K input tokens. |
| `xhigh` is the new effort tier between `high` and `max` | [CONFIRMED] | Official effort docs. |
| `xhigh` is the Claude Code default on Opus 4.7 | [CONFIRMED] | Anthropic best-practices post. Ralph's claude-profile default (`ralph.py:248`) matches. |
| Task budgets (beta header `task-budgets-2026-03-13`, min 20K tokens) | [CONFIRMED] | Whats-new-4.7 docs. |
| Multi-hour coherence, lower loop rate | [CONFIRMED] | "Loop resistance" benchmark and +14% over 4.6 at fewer tokens per Anthropic. |
| Opus 4.7 "already broke 4.6 prompts" (PRFAQ Q7) | [CONFIRMED] | Anthropic explicitly notes "a few tweaks to prompts and harnesses can make a big difference" and that tokenizer + higher reasoning impact token usage. Useful evidence for the versioning-cadence argument in Customer FAQ Q7. |

---

## Part 2 — Keel stack validation

The thirteen named technologies in the PRFAQ distillate (`prfaq-ralph-bmad-distillate.md:37-53`) are each production-grade and current as of April 2026.

### Core framework layer

- **TanStack Start on Vite** — [CONFIRMED]. v1.0 stable landed March 2026 after a September 2025 RC. Migrated from Vinxi to Vite in v1.121.0 (June 2025). Active releases continue through 2026-04-15 (v1.167.x). Documented limitations: smaller ecosystem and fewer tutorials vs Next.js; documentation still has gaps. This is an acknowledged risk in PRFAQ Q1 and Q2; reality matches.
- **better-auth** — [CONFIRMED]. Official TanStack Start integration exists at `/src/routes/api/auth/$.ts` with `createServerFn`-based `getSession`/`ensureSession` helpers. In early 2026 better-auth acquired and now maintains Auth.js — which materially de-risks the "correlated-library" story in PRFAQ Q2, since the "migrate back to Auth.js" unstub guide now migrates to a library maintained by the same team.
- **Postgres + Prisma + tRPC + Tailwind + Resend + OpenTelemetry** — all [CONFIRMED] as current, boring, primitive choices matching Keel's "boring stable primitives" thesis.
- **pg-boss** — [CONFIRMED active]. Recent npm publishes (~3 weeks), new `@pg-boss/dashboard` and `@pg-boss/proxy` packages shipped. Ceiling is ~50K jobs/sec per 2026 analysis; well beyond a Launchpad-bar SaaS. Uses `SKIP LOCKED` for exactly-once delivery.
- **Paddle Merchant of Record** — [CONFIRMED]. Sandbox API active. **Important:** the PRFAQ should specify "Paddle Billing" (the new platform) not "Paddle Classic" (being sunset). Pricing 5% + $0.50 vs Stripe's 2.9% + $0.30, but tax + compliance + currency are included. Approval-based onboarding is a real operational footnote — not instant signup. 2-5 day integration time matches the milestone plan's assumptions.

### Tooling layer

- **`prek` (Rust reimpl of pre-commit)** — [CONFIRMED]. `github.com/j178/prek`. Drop-in with `.pre-commit-config.yaml`, additionally supports `prek.toml`. ~2× install speed, ~7× hook-exec speed on small/medium repos. Already adopted by CPython, Apache Airflow, FastAPI, Django, Home Assistant, Ruff. Single binary, no Python runtime required for the runner itself. PRFAQ's rationale (declarative YAML, faster, no Node required, broader hook ecosystem) is accurate.
- **`commitlint`** — [CONFIRMED] universal, runs fine under prek as a pre-commit hook.
- **`release-please` + `release-please-monorepo`** — [CONFIRMED]. Monorepo story is the `node-workspace` plugin (plus `cargo-workspace` / `maven-workspace` for other stacks). The "rolling Release PR, commits decide version, maintainer decides when to ship" description in PRFAQ Q3/Q11 is exactly how it works. **Gotcha for the PRD:** v4 broke the old `releases_created` output — must use `release_created` or the path-prefixed variant in any GitHub Actions wiring.
- **ESLint `no-restricted-imports` + TypeScript project references** — [CONFIRMED] as the standard pattern for compile-time package-boundary enforcement in pnpm/Turborepo monorepos. No novel mechanism.

### Stack risk summary

The only real standing risks from the PRFAQ (Q1, Q2, Internal-Q1, Internal-Q2) are already acknowledged in the concept:

1. **TanStack Start ecosystem depth** — real but manageable; v1 stable is six weeks old as of this research.
2. **Paddle sandbox API stability** — single-event risk as called out in Internal-Q6.
3. **Day-1 RLS policy matrix** — still an unvalidated design problem per Internal-Q1; pre-M2 spike is the right response.

No new risks surfaced in the stack search. The stack is *current, boring, and battle-tested* — exactly what the thesis claims.

---

## Part 3 — Market-timing claims (corrections)

The PRFAQ's coaching notes contain two small factual errors worth fixing before the PRD. Neither changes the argument; both change the citation.

### [CORRECTED] Karpathy "vibe coding passé" date

- **PRFAQ asserts (line 104):** "Karpathy declared vibe coding passé 2026-02-08"
- **Actual date:** **2026-02-04** — posted one year to the day after the original 2025-02-02 vibe-coding tweet. The post is `x.com/karpathy/status/2019137879310836075`.
- **Impact on concept:** none. The timeline argument (Karpathy pivoted off vibe coding ≈2 months before Keel's PRFAQ) still holds.

### [CORRECTED] Karpathy's preferred new term

- **PRFAQ asserts (line 104):** "community moved to 'context engineering'"
- **Actual:** Karpathy himself explicitly prefers **"agentic engineering"** in the 2026-02-04 post. "Context engineering" is a real adjacent term used broadly in the community, but attributing it to Karpathy is inaccurate.
- **Recommended fix:** in the PRD's "Why now" framing, split these:
  - "Karpathy coined **agentic engineering** on 2026-02-04" (precise Karpathy attribution)
  - "the broader community adopted **context engineering**" (broader community move)

### [UNKNOWN — low stakes] Other market stats

- **"Ralph loop reached 12k+ GitHub stars in 2 months"** — not directly verified; the VentureBeat / HumanLayer coverage confirms the phenomenon and virality but I did not check the exact star count. Low-stakes marketing framing; verify before using the number in any published material.
- **"Antigravity 1,372+ skills"** — not verified. Same low-stakes treatment.
- **"Solo-founded startups rose 23.7% (2019) to 36.3% (mid-2025)"** — not verified. If this appears in the PRD, pull the number from the source document.

---

## Part 4 — Ralph Wiggum technique (canonical design)

Studied `github.com/ghuntley/how-to-ralph-wiggum` and Ghuntley's two origin posts (`ghuntley.com/ralph`, `ghuntley.com/loop`). Key takeaways that are *not* already captured in this repo's `RALPH.md`:

### Design principles Ghuntley names explicitly

1. **"One task per loop. Only one thing."** — This repo's `PROMPT_build.md` already embodies this. Worth reaffirming in the PRD's Ralph-backpressure section.
2. **"~170K of truly usable context out of 200K advertised; aim for 40-60% utilization for 'smart zone'."** — Opus 4.7's 1M context window loosens this constraint dramatically, but the *per-iteration* principle still applies — the goal is never to fill the window, because filled windows rot.
3. **"Keep `AGENTS.md` operational only. Status belongs in `IMPLEMENTATION_PLAN.md`."** — This repo already splits that way (AGENTS.md is canonical, IMPLEMENTATION_PLAN.md is iteration state). A good invariant for Keel to inherit.
4. **"Steer upstream + steer downstream + tune like a guitar."** — Upstream via specs and existing code patterns; downstream via tests/typechecks/lints; tune prompts by watching failures. This maps cleanly to Keel's four-layer quality gates plus Ralph backpressure.
5. **"The plan is disposable — regenerate if stale; cost is one planning loop."** — Ralph's plan vs. build mode asymmetry (PLANNING is cheap + re-runnable; BUILDING is committed).

### Mechanisms Ghuntley uses that this repo could add

- **Work-branch scoping (`./loop.sh plan-work "user auth with OAuth"`)** — creates a branch-scoped `IMPLEMENTATION_PLAN.md` for one feature rather than the whole project. Determinism at plan-creation time, not at task-selection time. **This is a natural fit for BMAD Epic-level Ralph runs:** the sprint plan picks the Epic, the Ralph plan-mode iteration generates a scoped IP for that Epic only, and the build-mode iterations execute against it.
- **Acceptance-driven backpressure** — deriving test requirements from acceptance criteria during planning so that "tests pass" becomes the completion gate. BMAD already produces acceptance criteria per story — this is an integration opportunity (see Part 5).
- **Non-deterministic backpressure via LLM-as-judge** — iterate-until-pass on subjective criteria (tone, UX). Out of scope for Keel 1.0 but worth a note in the PRD "Maybe" section.

### Security / blast-radius posture

- Ghuntley's explicit philosophy: *"It's not if it gets popped, it's when. And what is the blast radius?"*
- Canonical deployment targets: Docker locally, **Fly Sprites** or **E2B** for remote sandboxes.
- Ralph already uses `--dangerously-skip-permissions` by default (it is the whole point), so Keel's docs should include a "how to sandbox Ralph" section that names Fly Sprites / E2B as concrete options. This is a PRD-level concern, not a PRFAQ one.

### Agent-agnostic ambition

Ghuntley explicitly lists `amp`, `codex`, `opencode` as alternative CLIs the Ralph technique works with — it is not Claude-Code-specific. Ralph in this repo already reflects that (see `DEFAULT_TOOL_PROFILES` at `ralph.py:228-272` with `claude` / `codex` / `gemini` profiles). **Implication for the PRD:** the Keel × Ralph integration story should not hard-lock to Claude Code, but the *quality gates* story can assume Claude Code in the default Tier-1 path and leave codex/gemini as Tier-2.

---

## Part 5 — Ralph + BMAD + Keel greenfield integration (design proposal)

### Prior art: bmalph

**[CONFIRMED EXISTS]** `github.com/LarsCowe/bmalph` — an npm-installed CLI that wires BMAD-METHOD (planning, Phases 1-3) to Ralph (execution loop, Phase 4). This is the *closest* existing analogue to what Keel would ship.

bmalph's architecture:

- `bmalph init [--platform claude-code|codex|opencode|copilot|cursor]` — generates `_bmad/`, `.ralph/`, `bmalph/` directories and a platform-specific instructions file (`CLAUDE.md`, `AGENTS.md`, etc.).
- `bmalph implement` (or `/bmalph-implement`) — transitions from BMAD planning artifacts to a Ralph-executable plan.
- `bmalph run` (or `bash .ralph/ralph_loop.sh`) — starts the loop. Ralph picks stories, implements TDD, commits. Halts when all stories are done or circuit-breaker triggers.
- Smart-merge: when `bmalph implement` re-runs after Ralph has made progress, completed stories (`[x]`) are preserved and a `SPECS_CHANGELOG.md` records spec diffs.
- Tier-1 (Ralph-supported) platforms: Claude Code, OpenAI Codex, OpenCode, GitHub Copilot, Cursor.
- Tier-2 (planning-only) platforms: Windsurf, Aider.

**Gap vs Keel:** bmalph orchestrates BMAD + Ralph but does *not* provide a substrate — every new project starts from an empty directory, and the user is still making all 10+ non-product decisions every time. This is precisely the gap Keel exists to close.

### Proposed Keel greenfield kickoff flow

The clean mental model keeps three responsibilities separate:

| Layer | Responsibility | Tooling |
|---|---|---|
| **Keel** | Substrate — the opinionated repo (stack, auth, tenancy, jobs, CI test, quality gates) | Clone template; no CLI of its own |
| **BMAD** | Planning — PRD, architecture, epics, stories, sprint plan | BMad skills (`/bmad-*`) |
| **Ralph** | Execution — one story per iteration, commit + push + halt | `ralph.py` (already in this repo) |

Greenfield command flow (proposed):

```bash
# 1. Clone substrate
$ keel new my-product        # or: gh repo create --template keel-org/keel my-product
$ cd my-product

# 2. Verify substrate is healthy (the 60-minute functional test)
$ pnpm install
$ pnpm test:integration

# 3. BMAD planning — produces _bmad-output/planning-artifacts/*
$ /bmad-create-prd
$ /bmad-create-architecture
$ /bmad-create-epics-and-stories
$ /bmad-check-implementation-readiness   # required gate
$ /bmad-sprint-planning                   # required gate

# 4. Per-story loop (BMAD CS → Ralph build → BMAD CR)
$ /bmad-create-story                      # produces _bmad-output/implementation-artifacts/story-*.md
$ uv run ralph.py build                   # Ralph executes the story
$ /bmad-code-review                       # back to create-story, or epic-complete
```

### Integration contracts (what each layer owns)

**Keel owns (ships in every new repo):**

- `AGENTS.md` — operational source of truth. Commands, test invocations, package topology, RLS conventions, import-boundary rules. Small, stable, read by every Ralph iteration.
- `CLAUDE.md` — points to AGENTS.md + Claude-Code-specific notes (`.claude/settings.json`, skill conventions).
- `RALPH.md` — the Ralph journal; starts empty; Ralph writes into it across sessions.
- `PROMPT_build.md` and `PROMPT_plan.md` — Keel-tuned defaults that know how to read BMAD story files.
- `.ralph-tools.json` — Keel's defaults for the Ralph tool-profile system (e.g. always xhigh, always max-budget, always bypassPermissions in sandbox).
- `.ralph-halt` ignored in `.gitignore` (Ralph halt sentinel).
- `_bmad/` config pre-installed with Keel-appropriate module selection.

**BMAD owns (produces into `_bmad-output/`):**

- `planning-artifacts/` — PRD, architecture, epics, stories, readiness reports, sprint plans.
- `implementation-artifacts/` — per-story spec files that Ralph reads.
- Required gates (enforced via `_bmad/_config/bmad-help.csv`): PRD → Architecture → Epics → IR → Sprint → Create Story → Dev Story.

**Ralph owns (state carried across iterations):**

- `IMPLEMENTATION_PLAN.md` — the active iteration state; Ralph's plan-mode regenerates it, Ralph's build-mode appends/updates it.
- `.ralph-halt` — halt sentinel. Rich halt reason JSON.
- `CLAUDE_CODE_TASK_LIST_ID` — stable per-branch task-list ID (`ralph-<branch-slug>`), backed by `~/.claude/tasks/<id>/`.
- `ralph-logs/` (gitignored) — per-iteration stream-json logs.

### Halt-and-handoff points (governance)

Three natural halt surfaces in the greenfield flow — each aligned to a BMAD gate:

1. **Post-planning halt** — after `/bmad-sprint-planning`, before first Ralph iteration. Human confirms the sprint plan is the right next-sprint scope. No Ralph time burned on misaligned plan.
2. **Per-story halt** — after Ralph completes one story (commit + push + exit iteration), the loop halts for `/bmad-code-review`. CR either approves or sends back to Dev Story (another Ralph iteration on the same story).
3. **Epic-complete halt** — Ralph writes `(AWAIT_MERGE` into `IMPLEMENTATION_PLAN.md` when the epic is done; loop halts naturally. Human runs `/bmad-retrospective` or pushes to next epic.

This is already implemented in this repo's `ralph.py:1115-1117` (`_on_await_merge`) and `ralph.py:1104-1113` (`_on_halt`). Keel inherits this behavior for free.

### What Keel specifically adds vs plain bmalph

1. **The substrate itself** — 10 packages, RLS policies, Paddle wiring, OpenTelemetry, CI integration test.
2. **Quality gates pre-wired** — prek config, commitlint config, release-please config, ESLint import boundaries, TypeScript project references. Ralph commits can't pass pre-commit without them.
3. **Unstub guides** — `docs/unstub/tanstack-start-to-next.md`, `docs/unstub/better-auth-to-authjs.md`. Run quarterly in CI. A *stale* guide turns the build red — so the bail-out paths are always live.
4. **Seeded BMAD config** — Keel's `_bmad/bmm/config.yaml` pre-points `project_knowledge` at Keel's docs so BMAD planning agents know the substrate from turn one.
5. **Seeded Ralph config** — `.ralph-tools.json` with Keel-sensible defaults (Opus 4.7, xhigh, max-budget-usd caps, bypassPermissions-in-sandbox, worktree for parallel epic work).
6. **The 60-minute CI test as Ralph's smoke test** — Ralph's first iteration after `keel new` can be instructed to *re-run the 60-minute integration test* and confirm the substrate is green before touching any story. Baseline check every time.

### Reuse vs reinvent — the pragmatic question

bmalph exists. It works today. Three options for Keel:

- **Option A — use bmalph directly.** `keel new` calls `bmalph init --platform claude-code` under the hood after cloning the substrate. Pro: zero reinvention, ride bmalph's maintenance. Con: another dependency; bmalph's `.ralph/ralph_loop.sh` is a plain bash loop and does not offer the TUI this repo already has.
- **Option B — fork bmalph's conventions, keep this repo's Ralph TUI.** Adopt bmalph's directory layout and `implement`/`run` semantics but run them on top of `ralph.py`. Pro: best of both — TUI + proven conventions. Con: forking surface to maintain.
- **Option C — ignore bmalph, keep evolving this repo's Ralph.** This repo's Ralph (`ralph.py`) has multi-tool profiles, a full Textual TUI, ccusage integration, canonical-flag abstraction, and now a verified alignment with Claude Code 2.1.x. It is already *past* bmalph on the engineering surface. Pro: no coordination cost. Con: miss adoption of a convention layer the community already recognizes.

**Recommendation for the PRD:** Option B with a clear credit/compat statement. The conventions (e.g. `_bmad-output/` location, story-file discovery rules, `implement`/`run` mental model) should be bmalph-compatible so a user moving between bmalph and Keel doesn't retrain. The engine underneath stays `ralph.py` because it already ships capabilities bmalph's bash loop doesn't offer.

### Spike checklist (pre-M2)

Concrete validation steps for the three pre-M2 hardening items from the PRFAQ's Verdict, plus the new integration question:

- [ ] **RLS policy matrix spike** (PRFAQ Verdict item 1) — sketch the full policy set for B2B-with-team tenancy. If it doesn't fit a day, downgrade to Tier-2 stub.
- [ ] **M4 checkpoint calendared** (PRFAQ Verdict item 2) — specific date, specific question.
- [ ] **Procrastination honesty** (PRFAQ Verdict item 3) — 30 min personal note.
- [ ] **bmalph compatibility audit** (new) — produce a directory-layout and prompt-contract diff between this repo and `LarsCowe/bmalph`. Decide Option A/B/C explicitly.
- [ ] **Sandbox posture doc** — write a short Keel doc naming Fly Sprites or E2B as the blessed sandbox for running Ralph with `--dangerously-skip-permissions`. Reference Ghuntley's blast-radius framing.
- [ ] **Ghuntley's work-branch pattern** — evaluate whether Ralph's plan-mode should accept an Epic scope (`uv run ralph.py plan --epic 2`) to mirror bmalph/Ghuntley's `plan-work` pattern. Aligns with BMAD's epic-by-epic cadence.

---

## Summary of deltas the PRD should absorb

1. **Two small PRFAQ corrections** (Karpathy date 2026-02-04, Karpathy term "agentic engineering" not "context engineering"). Trivial, citation-only.
2. **Paddle Billing ≠ Paddle Classic** — PRD should name "Paddle Billing" explicitly and note the Classic sunset.
3. **better-auth + Auth.js consolidation** — the unstub guide story is *stronger* than the PRFAQ implies, because the same team now maintains both.
4. **Ralph ↔ Claude Code 2.1.x** — fully verified. No drift. `ralph.py` is correct as shipped, including the unusual `auto`/`dontAsk` permission-modes.
5. **bmalph prior art** — must be cited and compared in the PRD's "Competitive intelligence" section (currently names "Bmalph / BMAD+Ralph glue CLIs" as orchestration-only; reality is that bmalph is the closest analog to a Keel kickoff experience, and the Keel differentiator is the substrate, not the orchestration).
6. **Integration proposal** (Part 5 above) — candidate answer to Customer FAQ Q3 ("I already have BMAD and Ralph working. Why do I need Keel on top?"). The answer becomes more concrete: Keel is the repo Ralph + BMAD *land on*, with quality gates, unstub guides, and seeded configs already wired so the first `/bmad-create-prd` and first `uv run ralph.py build` both run against a healthy substrate rather than a blank directory.
7. **Spike checklist** (six items) — extends the PRFAQ Verdict's three items with three integration-layer items for pre-M2.

---

## Sources

### Claude Code / Claude Opus 4.7

- [Claude Code — CLI reference](https://code.claude.com/docs/en/cli-reference)
- [What's new in Claude Opus 4.7 — Claude API Docs](https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-7)
- [Effort — Claude API Docs](https://platform.claude.com/docs/en/build-with-claude/effort)
- [Introducing Claude Opus 4.7 — Anthropic](https://www.anthropic.com/news/claude-opus-4-7)
- [Best practices for using Claude Opus 4.7 with Claude Code — Claude](https://claude.com/blog/best-practices-for-using-claude-opus-4-7-with-claude-code)
- [Claude Code — Model configuration](https://code.claude.com/docs/en/model-config)
- [Claude Code — Settings](https://code.claude.com/docs/en/settings)
- [Claude Code Autonomous Mode: --dangerously-skip-permissions guide](https://pasqualepillitteri.it/en/news/141/claude-code-dangerously-skip-permissions-guide-autonomous-mode)
- [Claude Code CLI Cheat Sheet 2026](https://computingforgeeks.com/claude-code-cheat-sheet/)
- [Claude Code's Tasks update — VentureBeat](https://venturebeat.com/orchestration/claude-codes-tasks-update-lets-agents-work-longer-and-coordinate-across)
- [Cross-Session Tasks in Claude Code — ClaudeArchitect](https://claudearchitect.com/docs/claude-code/claude-code-cross-session-tasks/)
- [Claude Opus 4.7 Is Here: Release Confirmed April 16, 2026 — FindSkill.ai](https://findskill.ai/blog/claude-opus-4-7-release-tracker/)

### Keel stack

- [TanStack Start Overview](https://tanstack.com/start/latest/docs/framework/react/overview)
- [TanStack Start v1 Release Candidate — TanStack Blog](https://tanstack.com/blog/announcing-tanstack-start-v1)
- [TanStack Start v1.0: Type-Safe React Framework — byteiota](https://byteiota.com/tanstack-start-v1-0-type-safe-react-framework-2026/)
- [Better Auth — TanStack Start Integration](https://better-auth.com/docs/integrations/tanstack)
- [Better Auth — Optimizing for Performance](https://better-auth.com/docs/guides/optimizing-for-performance)
- [Top 5 authentication solutions for secure TanStack Start apps in 2026 — WorkOS](https://workos.com/blog/top-authentication-solutions-tanstack-start-2026)
- [pg-boss — GitHub](https://github.com/timgit/pg-boss)
- [pg-boss — npm](https://www.npmjs.com/package/pg-boss)
- [Postgres is the only Queue you need (until 50k jobs/sec) — Medium](https://medium.com/@harsh.vaghela.work/postgres-is-the-only-queue-you-need-until-50k-jobs-sec-5931611b551c)
- [Paddle — Subscriptions, Payments & Tax for SaaS](https://www.paddle.com/)
- [Paddle MoR: Everything you need to know](https://www.paddle.com/paddle-101)
- [Stripe vs Paddle: Fees, Tax Handling & MoR Compared](https://designrevision.com/blog/stripe-vs-paddle)
- [prek — GitHub](https://github.com/j178/prek)
- [Prek: A High-Performance Rust Reimplementation of Pre-commit — UBOS](https://ubos.tech/news/prek-a-high-performance-rust-reimplementation-of-pre-commit/)
- [release-please — GitHub](https://github.com/googleapis/release-please)
- [release-please-action — GitHub](https://github.com/googleapis/release-please-action)
- [release-please monorepo example — GitHub](https://github.com/amarjanica/release-please-monorepo-example)

### Ralph technique and Karpathy timeline

- [Ralph Wiggum as a "software engineer" — Geoffrey Huntley](https://ghuntley.com/ralph/)
- [Everything is a Ralph loop — Geoffrey Huntley](https://ghuntley.com/loop/)
- [how-to-ralph-wiggum — GitHub (Ghuntley)](https://github.com/ghuntley/how-to-ralph-wiggum)
- [A Brief History of Ralph — HumanLayer Blog](https://www.humanlayer.dev/blog/brief-history-of-ralph)
- [How Ralph Wiggum went from 'The Simpsons' to the biggest name in AI — VentureBeat](https://venturebeat.com/technology/how-ralph-wiggum-went-from-the-simpsons-to-the-biggest-name-in-ai-right-now)
- [Vibe coding is passé — The New Stack](https://thenewstack.io/vibe-coding-is-passe/)
- [Andrej Karpathy on X (2026-02-04)](https://x.com/karpathy/status/2019137879310836075)
- [The End of Vibe Coding: Karpathy's Shift to 'Agentic Engineering' — Buttondown](https://buttondown.com/verified/archive/the-end-of-vibe-coding-andrej-karpathys-shift-to/)

### bmalph and BMAD integration

- [bmalph — GitHub (LarsCowe)](https://github.com/LarsCowe/bmalph)
- [Bmalph: BMAD planning + Ralph autonomous loop, glued together — DEV.to](https://dev.to/lacow/bmalph-bmad-planning-ralph-autonomous-loop-glued-together-in-one-command-14ka)
- [Greenfield vs Brownfield in BMAD Method — Medium](https://medium.com/@visrow/greenfield-vs-brownfield-in-bmad-method-step-by-step-guide-89521351d81b)
- [BMad Method User Guide](https://bmadcodes.com/user-guide/)
