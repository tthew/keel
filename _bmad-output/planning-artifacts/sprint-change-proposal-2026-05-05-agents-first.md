---
title: Sprint Change Proposal — AGENTS-First Knowledge & Prompt Restructure (Proposal B)
date: 2026-05-05
author: Tthew (via /bmad-correct-course YOLO sub-agent; navigated by Claude orchestrator + Opus sub-agent + codex 2-round spar, session 019df9bb-276d-7643-ad9e-14ae0fdc8f2b)
project: ralph-bmad / Keel
scope: Major (PM + Architect + Dev coordination — docs-prose-heavy but touches FR14j + Architecture § Knowledge-file contract)
status: draft — awaiting Tthew approval. Companion: Proposal A (codex Tier-1 parity, separate proposal).
related: PRD FR14j (rewrite), FR14k (canonical-naming clause only — codex session-resume runtime caveat is OWNED BY A), FR40 (AGENTS.md cell only); Architecture § Knowledge-file contract (rewrite); Epic 3 Stories 3.3 (amendment) + 3.10 (wording-only); R4 knowledge-file upkeep rotation contract.
supersedes: PR #237 PR-0 — alongside companion Proposal A. The bundled `sprint-change-proposal-2026-05-04.md` is decomposed; this artefact owns the knowledge-file + prompt-file restructure half. Proposal A owns codex Tier-1 parity (auth, hooks, profile, adapter, defense matrix, INV-codex-*, ccusage scope, Stories 2.19-2.22 + 3.34, etc.).
---

# Sprint Change Proposal — AGENTS-First Knowledge & Prompt Restructure (Proposal B)

## Section 1 — Issue Summary

PR #237 bundled two coupled changes — codex CLI Tier-1 escalation AND a knowledge-file + prompt-file restructure — into a single sprint change proposal. Tthew has decided to split the navigation so each half can be reviewed and landed independently. **This proposal owns Proposal B: the AGENTS-First Knowledge & Prompt Restructure.** The companion Proposal A owns codex Tier-1 parity.

**Why split now.** The two halves have different review surfaces (Proposal B is mostly PM-prose + Dev-edits in markdown; Proposal A is Architect-heavy security posture + Dev runtime work) and different blast radii (B is low-risk docs-only; A touches `ralph.py` runtime, hook emitters, manifest IDs). Splitting lets Proposal B land first in the docs-only foundation slot without coupling to Proposal A's empirical capture / hook emitter / promotion gate work.

**Trigger evidence (B-relevant subset of original PR #237 trigger):**

- **CLAUDE.md duplicates ~50% of AGENTS.md content.** Today's CLAUDE.md (~80 lines on disk per the original proposal's `wc -l`; ~11 KiB) carries substrate-level truth — commands table, architecture overview, knowledge-file contract, promotion rules, git/PR conventions — that any agent other than Claude Code never reads. Codex (which Proposal A escalates to Tier-1) enters the repo half-blind because the substrate truth lives in CLAUDE.md, not AGENTS.md. Restructuring is required regardless of Proposal A's fate: even if codex stays Tier-2, AGENTS.md is still the agent-readable source-of-truth contract per `INV-knowledge-files-upkeep`.
- **`PROMPT_build.md` / `PROMPT_plan.md` leak Claude-flavoured language.** `TaskList` / `TaskCreate` (Claude-specific tool names), "Sonnet subagents" (Claude-only model naming), "Claude Code slash commands" (Claude-only invocation surface), `.claude/` exclusion in source-scan with no `.codex/` parallel. These leaks force any non-Claude agent to translate the prompt mid-iteration — translation cost the substrate currently externalises onto the agent.
- **R4 knowledge-file upkeep rotation reads stale by design.** Today's R4 nudge rotates `RALPH.md / AGENTS.md / CLAUDE.md`. CLAUDE.md only changes when Claude Code itself ships a new quirk (rare); rotating it per-iteration generates noise. Flipping the rotation to `AGENTS.md / RALPH.md / INVARIANTS.md` aligns the upkeep cadence with where the substrate's load-bearing knowledge actually drifts.
- **`AGENTS.md` is the only file every agent is GUARANTEED to read.** Codex reads `AGENTS.md` natively via its 3-tier hierarchy (global → Git-root walk → cwd; deeper overrides shallower; 32 KiB cap; `AGENTS.override.md` precedes `AGENTS.md` per directory). Claude Code reads `AGENTS.md` per the substrate's `INV-knowledge-files-upkeep` rule. Any future Tier-2 CLI that respects the AGENTS.md convention inherits the same entry point. Treating AGENTS.md as the substrate's primary entry-point and CLAUDE.md as an optional ≤25-line per-CLI delta matches that reality.

**What this proposal does NOT cover (owned by Proposal A):** codex CLI escalation, codex hook emitters, codex auth/profile/adapter, defense-layer coverage matrix, INV-codex-* / INV-substrate-defense-layers / INV-barrier-* invariants, ccusage hide-row, codex session-resume runtime caveat, AI_CLI_SHAPES + 6-touchpoint architecture-constants, Stories 2.1 amendment / 2.19 / 2.20 / 2.21 / 2.22 / 3.34. **Boundary rule (codex-supplied guardrail):** if a claim or piece of content is about codex behavior, codex auth, codex hooks, codex bypass survival, or any defense-layer / per-CLI-config substance, it belongs to Proposal A — even if its wording happens to land in AGENTS.md or `PROMPT_*.md` after Proposal B's restructure. This proposal's edits MAY reference Proposal A's pinned outcomes (e.g., quote FR14j as the file's primary entry-point statement) but MUST NOT author A's substance.

---

## Section 2 — Impact Analysis

### 2.1 Epic Impact

| Epic | Status | Impact (B-only) |
|------|--------|-----------------|
| Epic 1 — Substrate scaffolding | done | No story changes. AGENTS.md gains substrate-truth content (absorbed from CLAUDE.md); INVARIANTS.md unchanged by B. |
| Epic 2 — Packaged devbox | backlog | No story changes from B. (Proposal A amends Story 2.1 + adds 2.19-2.22; not B's scope.) |
| Epic 3 — Ralph build mode | backlog | **Story 3.3 amendment** (re-seed `.ralph/PROMPT_*.md` with tool-aware fallback prose; scope narrowed at 1.0 — Epic 12 prereq for `keel-templates` package-templated seeding remains deferred). **Story 3.10 wording-only update** (cross-CLI crash-journal language; codex session-resume implementation/probe details belong to A). |
| Epics 4-13, 15a, 15b | backlog | No structural changes. |

**Epic order/priority unchanged.**

### 2.2 Story Impact

**Epic 3 amendments (B-owned):**

| Story | Current scope | Proposed amendment (B) |
|-------|---------------|------------------------|
| 3.3 — Prompt template seeds (`PROMPT_build.template.md`, `PROMPT_plan.template.md`) | claude-shaped seeds | Re-seed live `.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md` with tool-aware fallback prose (per § 4.2 line-by-line edits). Single template; per-CLI deltas inline as `Claude: X. Codex: Y.` prose. **Caveat (carried from PR #237):** `packages/keel-templates/` is "populated in Epic 12" empty shell per `packages/keel-templates/README.md:5`. Story 3.3's B-scope at 1.0 is **the live `.ralph/PROMPT_*.md` seeds only**; future package-templated seeding remains deferred to Epic 12 (or Story 3.3 grows an Epic 12 dependency at that time). No change to Story 3.3's existing AC structure beyond the prose-content swap. |
| 3.10 — Native Claude Code task list as crash journal | claude-only narrative | **Wording-only reframe** to "Cross-CLI crash-journal contract." `.ralph/@plan.md` is named the substrate-invariant crash journal (per the FR14k canonical-naming clause introduced by this proposal). Native Claude task list is acknowledged as a Claude-only convenience mirror that survives hard kills. **No behavioural change to `.ralph/@plan.md` schema; no new ACs.** Codex session-resume parity / runtime details are NOT this story's concern — those belong to Proposal A. |

**No new stories** are introduced by Proposal B.

### 2.3 PRD Conflicts (B-owned subset only)

| FR | Current text (pinned implicit Claude assumption) | Proposed change (B) |
|----|--------------------------------------------------|---------------------|
| **FR14j** (PRD `prd.md:960`) | "Agent can maintain three audience-scoped knowledge files (`RALPH.md` private journal, `AGENTS.md` shared operational, `CLAUDE.md` Claude-Code-specific) with pinned promotion rules…" | "Agent maintains layered knowledge files: **`AGENTS.md` (substrate primary entry-point — operational source of truth, read by every agent; per codex's 3-tier hierarchy `AGENTS.override.md` precedes `AGENTS.md` per directory)**, `RALPH.md` (Ralph's private journal), `INVARIANTS.md` (machine-enforced rules index). **Per-CLI supplement files (e.g., `CLAUDE.md`) are OPTIONAL and contain only CLI-specific deltas — soft cap ≤25 lines, signpost-only, never duplicate AGENTS.md content. `<CLI>.md` MUST preserve a pointer to `INVARIANTS.fork.md` precedence rules where applicable.** Promotion rules pinned in AGENTS.md. The doc-budget enforcement clauses (issue #231 / Story 3.34 amendment) are unchanged." (Tool-agnostic; deliberately no `CODEX.md` named.) |
| **FR14k canonical-naming clause** (PRD `prd.md:961`) | Existing FR14k pins `.ralph/@plan.md` schema + `.ralph/halt` schema + native Claude Code task list as crash journal + path resolution | **Add canonical-naming clause:** "**`.ralph/@plan.md` is the substrate-invariant cross-CLI crash journal**; native CLI task-list APIs (Claude `TaskList` / `TaskCreate`) are optional convenience mirrors. The IP-side record is the durable crash-journal entry; the native task is a per-CLI convenience that may survive hard kills." (Codex session-resume defer-to-Growth runtime caveat is **not** added by B — that clause is owned by Proposal A.) Path-resolution clause + halt schema + autonomy constraint preserved unchanged. |
| **FR40** (PRD `prd.md:1010`) | Pattern-scan list pins `CLAUDE.md, skill files, .ralph/PROMPT_*.md, docs/**/*.md` | **Extend to `AGENTS.md`** (now load-bearing per restructure — every agent reads it, including potential prompt-injection vectors that reach the substrate via AGENTS.md edits). The `.codex/AGENTS.md` + `.codex/hooks.json` + `.codex/hooks/**` cells are **not** added by B — those belong to Proposal A. |

**No new PRD invariants** are introduced by Proposal B.

### 2.4 Architecture Conflicts (B-owned subset only)

| Section | Change |
|---------|--------|
| **§ Knowledge-file contract** (architecture.md — search target near `R4. Knowledge-file upkeep contract` at `:446`; the canonical knowledge-file table currently lives in CLAUDE.md and AGENTS.md, with R4 referencing it from architecture) | **Rewrite the knowledge-file audience/contents table** as the canonical authoritative version (currently the table is duplicated in AGENTS.md + CLAUDE.md with subtle drift). Rows: `AGENTS.md` (substrate primary, every agent — operational source of truth; voice imperative second-person; doc-budget enforced per FR14j amendment); `RALPH.md` (Ralph private — signposts/lessons/gotchas/decisions); `INVARIANTS.md` (machine-enforced rules index — agent-readable index of stable IDs mapping to `packages/keel-invariants/`); `<CLI>.md` (optional per-CLI delta — ≤25-line signpost; current concrete instance is `CLAUDE.md`; never duplicates AGENTS.md content; MUST retain pointer to `INVARIANTS.fork.md` precedence rule). Pin: **"`AGENTS.md` is the only file every agent is GUARANTEED to read."** Architecture's R4 contract paragraph (`architecture.md:446`) updates to flip the rotation set from `AGENTS.md / CLAUDE.md / RALPH.md` to **`AGENTS.md / RALPH.md / INVARIANTS.md`** (CLAUDE.md drops out — only changes when Claude Code itself ships a new quirk, with explicit trigger conditions named in AGENTS.md per the new "When to update CLAUDE.md" section). |

**No changes to** § tools.json (A-owned), § Substrate-Authorship-Constants (A-owned for `AI_CLI_SHAPES` addition + 6-touchpoint checklist), § Substrate Security Posture (A-owned for Defense Layer Coverage Matrix), § RC1-RC3 research corpus (no B changes), § Ralph Path-Resolution Contract (unchanged — already CLI-neutral).

### 2.5 UI/UX Conflicts

The substrate's UX contract is "agent as first-class user" (architecture.md §89). Proposal B addresses an existing UX wound — agents that are not Claude Code enter the repo half-blind because the operational truth lives in CLAUDE.md (which they never read). The restructure makes the substrate's primary entry-point the file every agent is guaranteed to read. **No external user-facing UI changes.**

### 2.6 Technical Impact (B-only)

**Knowledge files (B-scope edits):**

- **`AGENTS.md`** absorbs the substrate-truth content currently duplicated in CLAUDE.md (target: ~10-11 KiB of additions per the original PR #237 measurement — current AGENTS.md ≈ 6.7 KiB on a fresh AGENTS-light baseline; with absorption ≈ 10-11 KiB total). **Note (B-author observation 2026-05-05):** the live AGENTS.md in this worktree is materially larger than the 6.7 KiB baseline cited in PR #237 (today's `wc -c` shows ≈ 69 KiB). The absorption target is therefore expressed as **content-shape additions** (Common commands table; single canonical Knowledge-file contract table; Tool entry points section; State / Crash Journal section; Tool dirs section; BMAD invocation section; "When to update CLAUDE.md" section) rather than a fixed KiB delta. The doc-budget enforcement guardrail (issue #231 / Story 3.34) governs the actual size at commit time; B's job is to make AGENTS.md the substrate's primary entry-point, not to land it under a specific byte ceiling. If the soft-budget warns post-restructure, that triggers a separate trim pass under Story 3.34's existing guardrails — **not** a re-architecture of B.
- **`AGENTS.md` voice + section ordering** unified to imperative second-person, present tense, with first-30-seconds principle (most-acted-upon section first). New section ordering proposed in § 4.1 below.
- **`AGENTS.md`** grows a **"When to update CLAUDE.md"** section naming explicit trigger conditions (per the R4 upkeep rotation rationale): new slash-command shape observed; new `~/.claude/` config path discovered; new built-in tool name appears in Claude release notes; settings.json schema change observed in Claude Code release. Without explicit triggers, agents will silently let CLAUDE.md stale.
- **`CLAUDE.md`** shrinks to a ≤25-line signpost — preserves pointer to `INVARIANTS.fork.md` precedence rule (per consensus open-item #2 below). Concrete draft in § 4.1.
- **`RALPH.md`** unchanged structurally (private journal — out of B's scope).
- **`INVARIANTS.md`** unchanged by B (no new IDs introduced; A may add codex-related IDs separately).
- **Prompt files** (`.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md`) re-seeded with inline `Claude: X. Codex: Y.` fallback prose per § 4.2.

**No `ralph.py` changes.** No `packages/keel-invariants/` changes. No new manifest entries. Proposal B is docs-prose-only.

---

## Section 3 — Recommended Approach

**Direct Adjustment** (not Rollback, not MVP Review). Specifically:

- **Knowledge-file restructure:** AGENTS.md becomes the substrate's primary entry-point. CLAUDE.md shrinks to a ≤25-line signpost preserving INVARIANTS.fork.md precedence pointer. AGENTS.md grows a "When to update CLAUDE.md" section pinning the trigger conditions.
- **Prompt-file restructure:** `.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md` de-Clauded with inline `Claude: X. Codex: Y.` fallback prose. Single template; per-CLI deltas inline. (Per the original PR #237 design: no template engine, no per-CLI variable substitution at 1.0; Growth-tier evolution if a 3rd CLI lands.)
- **R4 rotation flip:** Per-iteration nudge rotates `AGENTS.md / RALPH.md / INVARIANTS.md`. CLAUDE.md drops out of per-iteration rotation; updates triggered by the explicit conditions in AGENTS.md's new "When to update CLAUDE.md" section.
- **Track-of-PRs sequenced delivery (B-internal renumbered B-0..B-2):**
  - **B-0** — foundation docs PR: PRD FR14j rewrite + PRD FR14k canonical-naming clause + PRD FR40 AGENTS.md cell extension + Architecture § Knowledge-file contract rewrite + R4 rotation contract documented + AGENTS.override.md precedence pinned. Pure doc edits to PRD + architecture; no behavioral change.
  - **B-1** — the actual prose surgery (= original PR #237 PR-3): AGENTS.md absorption + CLAUDE.md shrink + `PROMPT_build.md` / `PROMPT_plan.md` de-Clauding + AGENTS.md "When to update CLAUDE.md" section + R4 rotation flip applied to live files. Cites already-pinned PRD/arch language from B-0.
  - **B-2 (optional)** — `docs/ralph.md` + `README.md` codex-aware updates as a small follow-up docs PR. (Per codex sign-off: these are operator/navigation knowledge surfaces, not codex runtime — fit cleanly in B's docs-prose lane rather than A's codex-runtime lane.)
- **Ordering vs Proposal A:** **B-0 ∥ A-0** (parallel docs-only foundation PRs — no shared files; B-0 owns FR14j / FR14k canonical clause / FR40 AGENTS.md cell / arch § Knowledge-file contract / R4 rotation; A-0 owns FR3 / FR5 / FR7 / NFR5a / NFR5b / NFR6 / NFR10 / NFR30 / Story 2.1 / Defense Coverage Matrix / `INV-substrate-defense-layers` / `AI_CLI_SHAPES` + 6-touchpoint). **B-1 ∥ A-1** (low blast-radius, any order). **A-2** (codex profile / adapter) MUST follow B-1 so codex agents read post-restructure AGENTS.md when first running — otherwise codex enters the repo half-blind on its first iteration. A-3..A-9 follow per A's internal dependency chain.
- **Scope:** Major. B-0 routes to PM (John, FR14j cited-language signoff) + Architect (Winston, § Knowledge-file contract rewrite signoff). B-1 routes to PM (FR14j cited-language signoff in live files) + Developer (Amelia, execution). B-2 routes to Developer (Amelia, execution).

**Rationale (in dependency order):**

1. **B-0 lands first.** Pinning FR14j + FR14k canonical clause + FR40 AGENTS.md cell + arch § Knowledge-file contract before B-1 means B-1's prose surgery cites already-pinned language; reviewers don't argue about wording in two places.
2. **B-1 unblocks codex agents from operating half-blind.** Once AGENTS.md is the substrate's primary entry-point and CLAUDE.md is a ≤25-line signpost, any future codex iteration (under A-2's profile fix) reads the post-restructure AGENTS.md on first run.
3. **B-2 is optional.** `docs/ralph.md` + `README.md` codex-aware updates are operator-navigation polish, not load-bearing for substrate correctness; can land any time after B-1 or be deferred to Growth-tier.

**Effort estimate:**

- **B-0** (M): PRD FR14j rewrite + FR14k canonical clause + FR40 AGENTS.md cell + Architecture § Knowledge-file contract rewrite + R4 rotation contract documented. **1-2 days.**
- **B-1** (M): docs surgery — ~150-line CLAUDE.md edit (preserving fork-precedence pointer) + AGENTS.md absorption (target ~10-11 KiB content-shape additions) + AGENTS.md "When to update CLAUDE.md" section + `.ralph/PROMPT_*.md` line-by-line edits per § 4.2 + R4 rotation flip in any sprint-rotation contract location. **1-2 days.**
- **B-2** (S, optional): `docs/ralph.md` + `README.md` codex-aware updates — getting-started flow paragraphs naming AGENTS.md as primary; ralph.py architecture diagram captions made tool-neutral where currently Claude-named. **½-1 day.**

**Total elapsed estimate:** ~3-4 days of Ralph build-iterations for B-0 + B-1; B-2 is +½-1 day if pursued.

**Risk assessment:**

- **Lowest risk overall.** B is docs-prose-only — no runtime, no security posture, no manifest/sync-gate/halt-enum touchpoints. Reviewable by reading.
- **Documentation drift risk:** B-1 cites B-0's pinned FR14j language; B-1 must NOT land before B-0 ships. (B-1 ∥ A-1 ordering applies — B-1 may land in parallel with A-1 once both B-0 + A-0 are in main.)
- **Codex-agent half-blind window:** if A-2 (codex profile correctness, codex actually runs) ships before B-1, codex agents read pre-restructure CLAUDE.md-heavy AGENTS.md and operate half-blind for that window. Mitigation: enforce ordering — A-2 MUST follow B-1.
- **Doc-budget interaction:** Story 3.34's orient-gate + pre-commit hook (issue #231) is currently in `warn-only` mode per FR14j's amendment. B-1's AGENTS.md absorption MAY trip the warn threshold; this is acceptable at 1.0 (warn does not block) and triggers a separate trim pass under Story 3.34's existing budgets — not a re-architecture of B.
- **Empty-package dependencies:** `packages/keel-templates/` is "populated in Epic 12" per `packages/keel-templates/README.md:5`. Story 3.3's B-scope is narrowed at 1.0 to seed live `.ralph/PROMPT_*.md` only; package-templated seeding deferred to Epic 12. No B-blocker.

---

## Section 4 — Detailed Change Proposals

### 4.1 Knowledge-file restructure

**`AGENTS.md` — section ordering (first-30-seconds principle):**

1. **Header + audience** — "Provider-neutral guide for any AI coding agent. Source of truth — read this first."
2. **What this is** (existing)
3. **Where things live** (existing path table)
4. **Common commands** (absorbed from CLAUDE.md — single canonical commands table)
5. **Tool entry points** (NEW) — names AGENTS.md as primary; `<CLI>.md` files (currently only CLAUDE.md exists) as optional ≤25-line per-CLI deltas; codex reads AGENTS.md natively per its 3-tier hierarchy with `AGENTS.override.md` precedence.
6. **State / Crash Journal** (NEW) — `.ralph/@plan.md` is the substrate-invariant cross-CLI crash journal (per FR14k canonical-naming clause). Native CLI task-list APIs (Claude `TaskList` / `TaskCreate`) are optional convenience mirrors that may survive hard kills.
7. **Tool dirs** (NEW) — `.claude/`, `.codex/` excluded from app-source scans unless editing agent config.
8. **How to work here** (existing)
9. **BMAD invocation** (NEW) — `_bmad/_config/bmad-help.csv` is the catalog source-of-truth. Claude invokes via `/bmad-*` slash commands; other CLIs read the CSV catalog + the relevant `.claude/skills/<skill>/SKILL.md` and execute the named workflow directly (no slash-command surface in non-Claude CLIs).
10. **Knowledge-file contract** (absorbed; single canonical table — sourced from architecture's § Knowledge-file contract rewrite per B-0).
11. **Promotion rules** (existing — single canonical table).
12. **Project conventions** (existing).
13. **Git / PR conventions** (existing).
14. **Fork extension (FR44)** (existing).
15. **Ralph loop** (existing).
16. **When to update CLAUDE.md** (NEW — R4 upkeep trigger section; see content below).
17. **When you're unsure** (existing).

**Voice:** imperative, second-person, present tense throughout. "Run `/bmad-help` to find the next step." not "Skills are slash commands."

**`AGENTS.md` — "When to update CLAUDE.md" section content (B-0 pin proposal):**

> Update `CLAUDE.md` when (and only when) one of these conditions fires:
>
> - A new Claude Code slash-command shape is observed (e.g., a new `/<name>` invocation pattern that AGENTS.md's BMAD section doesn't already cover).
> - A new `~/.claude/` config path is discovered that affects in-repo workflow (e.g., a settings field that interacts with `.claude/settings.json` or `.claude/hooks/**`).
> - A new built-in Claude Code tool name appears in Claude release notes (e.g., a new tool like `WebSearch` that needs hook-matcher coverage or per-CLI documentation).
> - Claude Code ships a settings.json schema change that affects the substrate's deny-rule or hook authorship.
>
> If none of these conditions fire in an iteration, **do not update CLAUDE.md**. CLAUDE.md is not part of the per-iteration R4 rotation (`AGENTS.md / RALPH.md / INVARIANTS.md`) — the rotation drives upkeep on substrate-truth files where drift naturally accumulates; CLAUDE.md drifts only when Claude Code itself changes.

**`CLAUDE.md` target draft (≤25 lines, INVARIANTS.fork.md precedence pointer preserved per consensus open-item #2):**

```markdown
# CLAUDE.md — Claude Code deltas

`AGENTS.md` is the source of truth. Read it first.

## Claude-Code-specific

- Skills under `.claude/skills/<name>/SKILL.md` invoke as `/<name>` slash commands.
- One skill per context window — start a fresh conversation for each.
- `.claude/settings.local.json` is gitignored — don't touch.
- Worktrees under `.claude/worktrees/` — never clean up on exit.
- Memory: `_bmad/_memory/` (project-level) or `~/.claude/` (user-level).
- Native task list (`TaskList` / `TaskCreate`) is a Claude-only convenience mirror over `.ralph/@plan.md`; it survives hard kills but is not the substrate-invariant crash journal.
- Hooks: `.claude/hooks/block-secret-access.sh` denies secret-access patterns regardless of permission mode (Story 2.16 substrate). Don't tamper in-session — the hook self-protects.

## Fork-invariants precedence

`INVARIANTS.md` (upstream) is authoritative for every rule registered in `invariants.manifest.ts`; `INVARIANTS.fork.md` (when a fork opts in via `packages/keel-invariants/templates/INVARIANTS.fork.md`) is additive — fork rules ADD TO substrate but cannot override it. See `docs/invariants/fork.md` § Precedence.

## Pointers

- For Ralph-loop guidance: `RALPH.md`.
- For machine-enforced rules: `INVARIANTS.md`.
- For substrate operational truth: `AGENTS.md`.
```

**FR14j rewrite (B-0 pin):**

> Agent maintains layered knowledge files: **`AGENTS.md` (substrate primary entry-point — operational source of truth, read by every agent; per codex's 3-tier hierarchy `AGENTS.override.md` precedes `AGENTS.md` per directory)**, `RALPH.md` (Ralph's private journal), `INVARIANTS.md` (machine-enforced rules index). **Per-CLI supplement files (e.g., `CLAUDE.md`) are OPTIONAL and contain only CLI-specific deltas — soft cap ≤25 lines, signpost-only, never duplicate AGENTS.md content; `<CLI>.md` MUST preserve a pointer to `INVARIANTS.fork.md` precedence rules where applicable.** Promotion rules pinned in AGENTS.md. Doc-budget enforcement (issue #231 / Story 3.34 amendment) clauses preserved unchanged.

**FR14k canonical-naming clause (B-0 pin — additive, does NOT replace existing FR14k content):**

> **`.ralph/@plan.md` is the substrate-invariant cross-CLI crash journal** (the durable per-iteration record across all CLIs). Native CLI task-list APIs (Claude `TaskList` / `TaskCreate`) are optional convenience mirrors that may survive hard kills; the IP-side record in `.ralph/@plan.md` is the source of truth, the native task is a per-CLI convenience.

(The existing FR14k path-resolution clause + halt schema enum + autonomy constraint are unchanged. Codex session-resume defer-to-Growth runtime caveat is **not** added by B — owned by Proposal A.)

**FR40 AGENTS.md cell (B-0 pin):**

> Pattern-scan list extended to include **`AGENTS.md`** (now load-bearing per the FR14j restructure — every agent reads it, including potential prompt-injection vectors that reach the substrate via AGENTS.md edits). Existing entries (`CLAUDE.md`, skill files, `.ralph/PROMPT_*.md`, `docs/**/*.md`) preserved. (The `.codex/AGENTS.md` + `.codex/hooks.json` + `.codex/hooks/**` cells are owned by Proposal A.)

**R4 (knowledge-file upkeep contract) rotation change (B-0 pin):**

Per-iteration nudge rotates **`AGENTS.md / RALPH.md / INVARIANTS.md`**. CLAUDE.md drops out of per-iteration rotation — it changes only when one of the trigger conditions named in AGENTS.md's "When to update CLAUDE.md" section fires. Architecture's R4 contract paragraph (`architecture.md:446`) is updated in B-0 to reflect this rotation set; AGENTS.md's promotion-rules table is updated in B-1 to match.

### 4.2 Prompt-file restructure (PROMPT_build.md + PROMPT_plan.md)

**Approach:** Direct prose with explicit `Claude: X. Codex: Y.` inline fallback. No template engine, no per-CLI variable substitution at 1.0 (Growth-tier evolution if a 3rd CLI lands). All edits land in B-1.

**`.ralph/PROMPT_build.md` line-by-line edits (line numbers per the live file at the time of B-1 authoring; verify in-iteration before applying):**

- **Orient 0c** — Replace `Study @AGENTS.md for operational commands. @CLAUDE.md points to it. Study @RALPH.md…` with `Study @AGENTS.md (operational source of truth, every agent reads this). If running Claude Code, also read @CLAUDE.md for adapter behavior. Study @RALPH.md — the notes prior Ralphs left for you…`
- **Orient 0e (excluded directories)** — Add `.codex/` to the excluded directories list. New text: `Application source… directories under repo root other than \`_bmad/\`, \`_bmad-output/\`, \`.claude/\`, \`.codex/\`, \`docs/\`.`
- **Orient 0e (parallel agents)** — Replace `Use Sonnet subagents for searches/reads; one Sonnet subagent at most for any build/test command (backpressure)` with `Use parallel read/search helpers when available. Claude: Sonnet subagents for reads/searches; at most one build/test subagent (backpressure). Codex: use local \`rg\` / \`grep\` and plan-file state; no subagent assumption.`
- **Orient 0g (task-list orient)** — Replace `Run TaskList. If tasks exist from a killed prior iteration, they show in-flight work. Use alongside IP to orient, then mark stale tasks deleted. If no tasks, proceed.` with `Read \`.ralph/@plan.md\` (the IP) — this is the substrate-invariant crash journal. Claude: also run \`TaskList\` to inspect any in-flight native tasks from a killed prior iteration; reconcile against IP; mark stale tasks deleted. Codex: \`.ralph/@plan.md\` is the only durable crash journal; codex's \`update_plan\` is session-local UI, not durable state.`
- **Step 1b (NOW recording)** — Replace `Create 1 native Task for the NOW item (TaskCreate). Update status as you progress. Max 3 active tasks (NOW + up to 2 sub-steps). These survive hard kills.` with `Record NOW in \`.ralph/@plan.md\`. Claude: also mirror NOW into one native Task (\`TaskCreate\`); update status as you progress; max 3 active native tasks (NOW + up to 2 sub-steps). The IP-side record is the durable crash-journal entry; the native task is a Claude-only convenience that survives hard kills.`
- **Step 3a (knowledge-file upkeep)** — Replace `@CLAUDE.md / @AGENTS.md — if a convention applies to every future agent, promote it to AGENTS.md (or, if Claude-Code-specific, CLAUDE.md). Keep AGENTS.md operational — bloated AGENTS.md pollutes every future loop's context.` with `@AGENTS.md — if a convention, command, or path discovered this iteration applies to every future agent, promote it here. @CLAUDE.md — only Claude-Code-specific quirks (skill invocation, settings file paths, etc.); never duplicate AGENTS.md content; consult AGENTS.md's "When to update CLAUDE.md" trigger conditions before editing. Keep AGENTS.md within the doc-budget guardrails (issue #231 / Story 3.34) — bloated AGENTS.md pollutes every future loop's context. @INVARIANTS.md — if the rule is machine-enforced (config / lint rule / pre-merge gate), index it here.` (R4 rotation: AGENTS.md / RALPH.md / INVARIANTS.md.)
- **Commit step** — Replace `Commit IP + RALPH.md + AGENTS.md/CLAUDE.md changes alongside the work` with `Commit IP + RALPH.md + AGENTS.md (or INVARIANTS.md, if applicable) changes alongside the work. CLAUDE.md updates are rare — only when a trigger condition from AGENTS.md's "When to update CLAUDE.md" section fires.`
- **BMAD invocation footer** — Replace `BMad skills in this project use the \`bmad-\` prefix and are invoked via Claude Code slash commands. Source of truth: \`_bmad/_config/bmad-help.csv\` and \`/bmad-help\`.` with `BMad skills in this project use the \`bmad-\` prefix. Source of truth: \`_bmad/_config/bmad-help.csv\`. Claude: invoke via \`/bmad-*\` slash commands. Codex: read the CSV catalog + the relevant \`.claude/skills/<skill>/SKILL.md\` and execute the named workflow directly (no slash-command surface in codex).`
- **Closing knowledge-file paragraph** — Replace `Keep @AGENTS.md operational only — bloated AGENTS.md pollutes every future loop's context. Document bugs in IP even if unrelated. @RALPH.md is where Ralph-flavored notes live (signposts, lessons, gotchas, decisions); AGENTS.md/CLAUDE.md is for shared operational truth.` with `Keep @AGENTS.md operational only — bloated AGENTS.md pollutes every future loop's context (doc-budget guardrails per issue #231 / Story 3.34). Document bugs in IP even if unrelated. @RALPH.md is where Ralph-flavored notes live (signposts, lessons, gotchas, decisions); @AGENTS.md is for shared operational truth across all CLIs; @INVARIANTS.md indexes machine-enforced rules. CLAUDE.md is a ≤25-line per-CLI signpost — see AGENTS.md's "When to update CLAUDE.md" section for trigger conditions.`

**`.ralph/PROMPT_plan.md` line-by-line edits:**

- **Header file table** — Update header to reflect tool-neutral file table: `Files: IP=.ralph/@plan.md | A.md=AGENTS.md (primary) | C.md=CLAUDE.md (Claude adapter only) | I.md=INVARIANTS.md | SS=sprint-status.yaml`
- **Excluded dirs** — Add `.codex/` — `Study source dirs (anything outside \`_bmad/\`, \`_bmad-output/\`, \`.claude/\`, \`.codex/\`, \`docs/\`)`.
- **AGENTS.md study line** — Replace `Study @AGENTS.md for operational context. @CLAUDE.md points to it.` with `Study @AGENTS.md for operational context (source of truth, every agent). If running Claude Code, also read @CLAUDE.md for adapter-specific behavior.`
- **Knowledge-file upkeep** — Same R4 rotation update as PROMPT_build.md: AGENTS.md / RALPH.md / INVARIANTS.md; CLAUDE.md adapter-only with trigger-condition pointer.

### 4.3 Architecture § Knowledge-file contract rewrite (B-0)

The canonical Knowledge-file contract table currently lives duplicated in AGENTS.md + CLAUDE.md with subtle drift. **B-0 makes architecture.md the canonical source.** Rewritten table:

| File | Audience | Contents |
|------|----------|----------|
| `AGENTS.md` | Substrate primary — every agent (Claude Code, codex, any future Tier-2 CLI that respects AGENTS.md) | Authoritative operational guide — conventions, paths, git rules, BMAD invocation. The only file every agent is GUARANTEED to read. Voice imperative second-person; doc-budget enforced per FR14j amendment. |
| `RALPH.md` | Ralph (autonomous loop) | Ralph's private journal — signposts, lessons, gotchas, decisions, rationale for past choices. |
| `INVARIANTS.md` | Any AI agent or human — machine-enforced rules | Agent-readable index of stable IDs mapping to `packages/keel-invariants/` (FR42; drift-detected by Story 1.9 sync-gate per FR43). |
| `INVARIANTS.fork.md` (Growth-tier, optional) | Fork-specific agent/human | Fork-owned additive rules to upstream INVARIANTS.md; substrate rules take precedence (FR45). |
| `<CLI>.md` (optional per-CLI delta — current concrete instance is `CLAUDE.md`) | The named CLI specifically | CLI-specific quirks only (Claude Code: skill invocation, settings paths, hooks, worktree retention). ≤25-line signpost. Never duplicates AGENTS.md content. MUST preserve a pointer to `INVARIANTS.fork.md` precedence rule where applicable. |

**Precedence:** upstream `INVARIANTS.md` is authoritative for every rule registered in `invariants.manifest.ts`; `INVARIANTS.fork.md` (when a fork opts in) is additive — fork rules ADD TO substrate but cannot override it. See `docs/invariants/fork.md` § Precedence.

**R4 rotation contract (architecture.md:446 update):** Per-iteration nudge rotates **`AGENTS.md / RALPH.md / INVARIANTS.md`** (CLAUDE.md drops out — only changes when a trigger condition from AGENTS.md's "When to update CLAUDE.md" section fires). Pre-commit hook emits a warning (not a hard fail) if all three rotation-set files are untouched AND no justification found; Ralph honours the warning by prompting itself to reflect.

### 4.4 sprint-status.yaml updates

Pending Tthew approval — to be applied during workflow Step 5 finalisation. Proposed delta (B-only):

```yaml
# Epic 3 amendments (B-only):
3-3-prompt-template-seeds:                       # scope-narrowed at 1.0 — re-seed live .ralph/PROMPT_*.md only;
                                                 # package-templated seeding deferred to Epic 12 (no rename)
3-10-native-claude-code-task-list-as-crash-journal:  # wording-only reframe to cross-CLI crash-journal contract;
                                                 # codex session-resume defer-to-Growth caveat owned by Proposal A
                                                 # (no rename, no AC change)
```

No new stories; no story renumbering. (Compare with Proposal A's sprint-status delta which adds 2.18-2.21 + 3.34 + Story 2.1 amendment.)

---

## Section 5 — Implementation Handoff

### Scope classification: **Major**

Although B is docs-prose-only, it touches FR14j (PRD-level) + Architecture § Knowledge-file contract — both PM and Architect must review B-0. B-1's prose surgery routes to PM (cited-language signoff) + Developer (execution). B-2 (optional) routes to Developer.

### Recommended PR sequence (B-internal, renumbered B-0..B-2)

| PR | Size | Contents | Depends on | Unblocks |
|----|------|----------|------------|----------|
| **B-0** | M (~1-2 days) | **Foundation docs PR** — PRD FR14j rewrite + FR14k canonical-naming clause + FR40 AGENTS.md cell extension; Architecture § Knowledge-file contract rewrite + R4 rotation contract updated to `AGENTS.md / RALPH.md / INVARIANTS.md`; AGENTS.override.md precedence pinned in FR14j; INVARIANTS.fork.md precedence preservation noted as a B-1 acceptance criterion. Pure doc edits to `_bmad-output/planning-artifacts/prd.md` + `_bmad-output/planning-artifacts/architecture.md`; no behavioural change. | None — standalone docs PR. Parallel to A-0 (no shared files). | B-1 cites already-pinned PRD/arch language; A-2 (codex profile) downstream of B-1 reads post-restructure AGENTS.md. |
| **B-1** | M (~1-2 days) | **The actual prose surgery.** AGENTS.md absorbs substrate-truth currently duplicated in CLAUDE.md (target: ~10-11 KiB content-shape additions per § 4.1; doc-budget guardrails govern actual byte size); CLAUDE.md shrinks to ≤25-line signpost preserving `INVARIANTS.fork.md` precedence pointer per § 4.1 draft; AGENTS.md grows "When to update CLAUDE.md" section per § 4.1; `.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md` de-Clauded with inline `Claude: X. Codex: Y.` fallback prose per § 4.2; R4 rotation flip applied to AGENTS.md promotion-rules table. | B-0 (cites pinned FR14j, FR14k canonical clause, FR40 AGENTS.md cell, arch § Knowledge-file contract). Independent of A-0/A-1. | A-2 (codex profile correctness) MUST follow B-1 so codex agents read post-restructure AGENTS.md when first running. |
| **B-2 (optional)** | S (~½-1 day) | **`docs/ralph.md` + `README.md` codex-aware updates** — getting-started flow paragraphs naming AGENTS.md as primary entry-point; ralph.py architecture diagram captions made tool-neutral where currently Claude-named. Per codex sign-off: these are operator/navigation knowledge surfaces, not codex runtime; fit cleanly in B's docs-prose lane rather than A's codex-runtime lane. | B-1 (cites post-restructure AGENTS.md naming). Independent of A-2..A-9. | (Polish — operator-navigation clarity; no downstream PR depends on B-2.) |

**Total elapsed estimate (B-only):** ~3-4 days for B-0 + B-1; +½-1 day for optional B-2.

### Deliverables

- This Sprint Change Proposal at `_bmad-output/planning-artifacts/sprint-change-proposal-2026-05-05-agents-first.md` ✓ (this file).
- **B-0 PR:** PRD + Architecture edits per § 2.3 + § 2.4 + § 4.3.
- **B-1 PR:** AGENTS.md absorption + CLAUDE.md shrink + `PROMPT_*.md` line-by-line edits per § 4.2 + AGENTS.md "When to update CLAUDE.md" section per § 4.1.
- **B-2 PR (optional):** `docs/ralph.md` + `README.md` codex-aware getting-started + architecture-diagram-caption updates.
- **PRD changelog entry** for the AGENTS-first restructure (paired with the B-0 PR description).
- **No `INVARIANTS.md` changes** by Proposal B (A may add codex-related IDs; not B's scope).
- **Story 3.3 + 3.10 sprint-status delta** per § 4.4.

### Success criteria

- **B-0:** PRD validation passes against the FR14j rewrite + FR14k canonical-naming clause + FR40 AGENTS.md cell. Architecture § Knowledge-file contract rewrite reviewed by John (PM) + Winston (Architect) without scope objections. R4 rotation flip pinned in architecture.md:446 paragraph.
- **B-1:** A non-Claude agent (codex, or any AGENTS.md-respecting CLI) entering the repo for the first time can execute correctly using only AGENTS.md as the entry point — verified by spot-check that AGENTS.md contains the substrate-truth previously sourced from CLAUDE.md (commands table, knowledge-file contract, BMAD invocation, state/crash journal, tool entry points, tool dirs). `wc -l CLAUDE.md` ≤ 25 lines AND CLAUDE.md preserves the `INVARIANTS.fork.md` precedence pointer per § 4.1 draft. `grep -c "Claude\|TaskList\|TaskCreate\|Sonnet"` in `.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md` drops to ≤ 8 hits total (CLI-named adapter callouts only).
- **B-2 (if pursued):** `docs/ralph.md` and `README.md` getting-started flows reference AGENTS.md as the primary entry-point; tool-named diagram captions generalised where appropriate.

### Routing (per scope classification)

- **B-0** (PRD + Architecture corrections) → Product Manager (John) for FR14j cited-language signoff + System Architect (Winston) for § Knowledge-file contract rewrite signoff. **Must review BEFORE B-1 ships.**
- **B-1** (Knowledge-file + prompt restructure) → Product Manager (John) for FR14j cited-language signoff in live files + Developer (Amelia) for execution.
- **B-2** (optional docs polish) → Developer (Amelia) for direct implementation.

---

## Section 6 — Open items requiring Tthew sign-off

| Item | Recommendation (B-author 2026-05-05) | Required for proposal approval? |
|------|--------------------------------------|--------------------------------|
| **R4 upkeep trigger contract content** — sign-off on the trigger conditions named in AGENTS.md's "When to update CLAUDE.md" section | Recommended trigger set (per § 4.1): (1) new Claude Code slash-command shape observed, (2) new `~/.claude/` config path discovered, (3) new built-in tool name in Claude release notes, (4) settings.json schema change observed. Without explicit triggers, agents will silently let CLAUDE.md stale. | Recommended — proposal ships with the recommended trigger set pinned in B-0; revisable in B-1 if Tthew adjusts the trigger list. |
| **`INVARIANTS.fork.md` preservation in the new ≤25-line CLAUDE.md** — sign-off on the literal pointer text | Recommended literal text (per § 4.1 draft): the "Fork-invariants precedence" section quoting the existing `CLAUDE.md:43-51` precedence rule (upstream INVARIANTS.md authoritative; INVARIANTS.fork.md additive — fork rules ADD TO substrate but cannot override; pointer to `docs/invariants/fork.md § Precedence`). | Recommended — proposal ships with the recommended text in § 4.1; revisable in B-1 if Tthew prefers a tighter wording. |
| **`docs/ralph.md` + `README.md` codex-aware updates content (B-2 scope)** | Recommended scope (per § 5 Deliverables): getting-started flow paragraphs naming AGENTS.md as primary entry-point; ralph.py architecture-diagram captions made tool-neutral where currently Claude-named. Defer to Growth-tier if Tthew prefers — B-2 is optional. | Optional — without sign-off, B-2 is not pursued; B-0 + B-1 ship the substrate-correctness portion of Proposal B. |

---

## Approval

- [ ] **Tthew** — approves Sprint Change Proposal B for implementation.
- [ ] R4 upkeep trigger conditions: ☐ adopt recommended set ☐ adjust to: ____________________
- [ ] INVARIANTS.fork.md pointer text in new CLAUDE.md: ☐ adopt recommended ☐ adjust to: ____________________
- [ ] B-2 pursued? ☐ yes (pursue `docs/ralph.md` + `README.md` updates) ☐ no (defer to Growth-tier)

Once approved, the workflow proceeds to Step 5 (finalise + route) and Step 6 (workflow completion), including the `sprint-status.yaml` update from § 4.4.

---

## Provenance

This proposal was navigated via `/bmad-correct-course` in YOLO mode by a Claude sub-agent in worktree `agent-ac07093d`, authoring Proposal B from the pre-decided consensus reached across:

- **Round 1 — Claude orchestrator + Opus sub-agent decomposition** of PR #237's bundled `sprint-change-proposal-2026-05-04.md` into Proposal A (codex Tier-1 parity) + Proposal B (AGENTS-first knowledge & prompt restructure).
- **Round 2 — codex spar (session 019df9bb-276d-7643-ad9e-14ae0fdc8f2b)** validating the decomposition boundary, supplying the guardrail "do not absorb codex behavior, auth, hooks, bypass, defense-layer, or any A-scope claim just because the wording appears in AGENTS/PROMPT files," and signing off on B-2 (`docs/ralph.md` + `README.md` codex-aware updates) as B-scope rather than A-scope.

**Supersedes:** PR #237 PR-0 — alongside companion Proposal A. The bundled `sprint-change-proposal-2026-05-04.md` is decomposed into two independent navigations; B owns the knowledge-file + prompt-file restructure, A owns codex Tier-1 parity. Neither proposal stands without the other for the original PR #237 vision, but each is independently reviewable and landable.

**Cross-reviewer alignment achieved:** Claude orchestrator + Opus sub-agent + codex (2 rounds) all converge on the boundary above. The codex-supplied guardrail is honoured throughout this proposal — no claim about codex behaviour, codex auth, codex hooks, codex bypass, or any defense-layer / per-CLI-config substance has been authored in B; references to A's pinned outcomes are by-pointer only (e.g., FR14j as the file's primary entry-point statement).
