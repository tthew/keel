---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-02b-vision
  - step-02c-executive-summary
  - step-03-success
  - step-04-journeys
  - step-05-domain
  - step-06-innovation
  - step-07-project-type
  - step-08-scoping
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
  - step-12-complete
  - step-e-01-discovery
  - step-e-02-review
  - step-e-03-edit
lastEdited: '2026-04-18'
editHistory:
  - date: '2026-04-18'
    changes: 'Post-validation polish pass (Top 3 improvements from 2026-04-17 validation report, all LOW-severity, non-blocking). (1) Journey Requirements Summary table extended with "Observability + audit + feature-flags + i18n baseline (FR21-FR27, FR64)" row mapping to J1 + J3 (implicit) and milestones M5, M6, M7 — closes the LOW-informational traceability gap on journey-visibility of FR21/22/23/24-27. (2) Added "Scriptable / CI mode" subsection in CLI-Tool Surface § consolidating the three 1.0 non-interactive affordances (non-interactive bootstrap, headless Claude auth via ANTHROPIC_API_KEY env-var Tier-2 path, deferred-at-1.0 Growth-tier candidates) into one anchor — raises cli_tool `scripting_support` project-type requirement from Partial to Met. (3) FR65-FR68 rewritten to [Actor] can [capability] format while preserving structural-contract content: FR65 "Developer can declare...", FR66 "Developer can regenerate...", FR67 "System can normalize...", FR68 "System can enforce..." — eliminates the Measurability step''s format-deviation callout.'
  - date: '2026-04-17'
    changes: 'Wizard-reversal pivot (supersedes the 2026-04-17 wizard-pinning pivot below). Removed setup-time wizard-pinned invariants thesis; reverted to source-layer-pinned invariants with two hardwired shapes (B2B + B2C). Root cause (applied five-whys): wizard scope was sized for N>1 but persona is N=1=Tthew; Marcus peer-agency journey was vanity cover for narcissistic scope. Removed: FR65-FR74 (wizard/config-as-invariants FRs), NFR34-NFR37 (wizard UX/schema/idempotency NFRs), M0.6 (Keel CLI + wizard engine), M8 (migration-between-choices guides), Journey 4 (Marcus peer fork + monthly upstream rebase), adapter-surface multi-implementation scope in M2/M3/M7 (collapsed to better-auth/Paddle/TanStack Start/Prisma/pg-boss/Resend single-impl each). Narrowed M0.7 to a tenancy-template generator only (team + user templates for B2B + B2C). Preserved: three-layer invariants stack + sync gate, Day-1 RLS parameterised over tenancy (two templates), devbox sandbox + --dangerously-skip-permissions safety, four-layer gates, per-iteration security verification + evidence, Ralph + acceptance-driven backpressure, M4 checkpoint ritual. Shape scope at 1.0: B2B + B2C hardwired (pick via one-line keel.config.ts edit — no wizard UI, no interactive prompts); Marketplace + API-first deferred to 1.1/1.2. Success metrics: replaced RIAR (gameable; smaller tasks inflate the ratio) with TTGNA (time-to-green-on-novel-adapter — externally-bound clock); added Victor monthly blank-starter-sprint as quarterly-observable absorption-risk tripwire (research-output doubling as governance). CI decomposed per Murat: pre-commit ≤10s / pre-merge-fast ≤3min (deterministic) / pre-merge-slow ≤10min / nightly ≤60min (live-network hits live here, never pre-merge) / release-gated manual. Generator normalization contract pinned per Winston: pure function expand(policy,config)→Rule[], canonicalised output array hashing, order-independent, deterministic merge precedence. Python CLI (keel.py) demoted to internal orchestration-only; user-facing CLI is TypeScript. Revised MVP: ~29d (realistic-slip 30-34d), back inside the original pre-wizard-pivot posture. Research-project reframe explicit: Keel succeeds as agentic-dev research even if it fails as substrate, provided blank-starter-sprint logs accumulate.'
  - date: '2026-04-17'
    changes: 'Post-validation polish pass (superseded by wizard-reversal above for wizard-specific findings; structural findings still apply). HIGH findings: (H1) qualified NFR35 fail-closed to distinguish rejection-class from warning-class combinations; restructured Wizard Validation Rules into Rejection-class and Warning-class blocks with explicit --accept-warnings non-interactive behaviour. (H2) added parenthetical anchor at first use of "Tier-2 deviation path" in Out of Scope pointing at the Implementation Considerations definition. MEDIUM findings: (M1) added elision note for single-option wizard axes (Jobs, Email); (M2) added postPivotNote frontmatter entries to PRFAQ and PRFAQ distillate flagging them as superseded-on-thesis with pointer to current PRD; (M3) corrected Journey 2 M4-checkpoint day to ~29 (was ~25) to match new milestone cumulative; (M4) reframed Vision § bullet 3 from "enforced invariants" to "wizard-pinned-and-frozen invariants." LOW findings deferred (non-blocking, documented in validation report).'
  - date: '2026-04-17'
    changes: 'Thesis pivot: source-layer hardwired invariants → setup-time wizard-pinned invariants. Escalated Keel CLI + scaffolding to MVP. All core features (auth, DB, framework, billing, jobs, email) become wizard-configurable with quick-start defaults matching the previous hardwired stack; post-setup config is frozen and materialised into packages/keel-invariants/. Added four product shapes to wizard (SaaS-B2B default, Marketplace, B2C, API-first). New milestones M0.6 (Keel CLI + wizard) and M0.7 (config-as-invariants plumbing); MVP plan extended 26d → 48d (realistic-slip 48-52d). Removed framework/stack alternatives and product-shape restrictions from Out of Scope. Added FR65-FR74 Configuration & Scaffolding section. Added NFR34-NFR37 wizard-UX / config-schema-versioning / generator-idempotency. Unstub guides reframed as migration-between-choices guides. New Invariants subsection "Config-as-invariants." Keel differentiator restated: agent-coherent scaffolding + setup-time invariant pinning + security-by-default + Ralph loop — not specific library choices.'
  - date: '2026-04-17'
    changes: 'Applied Top 3 polish improvements from validation report: (1) added Agent-Capability Substrate Absorption Risk sub-section to Domain-Specific Requirements; (2) added consolidated Out of Scope sub-section to Product Scope; (3) pinned invariants-sync mechanism sketch in Invariants § and FR43.'
  - date: '2026-04-17'
    changes: 'Incorporated upstream Ralph-wiggum (github.com/ghuntley/how-to-ralph-wiggum) canonical patterns and Opus 4.7 migration-guide findings. Added: Model-and-Tooling-Evolution delta catalogue (Domain §); sandbox-is-the-security-boundary preamble (Security-by-Default §); Ralph-prompt-conventions row (Invariants Coverage table); FR7 effort/adaptive-thinking clarification; FR9 task_budget advisory; FR9a stop-reason branching; FR13 thinking.display summarized; FR14a Acceptance-Driven Backpressure; FR14b plan-staleness trigger; FR14c subagent fan-out budget; FR14d per-iteration context meter; FR14e Non-Deterministic Backpressure scaffold; NFR4 tokenizer-aware budgets; NFR4a context-utilisation smart zone; NFR29a model-version-pinned prompt-set; NFR30 breaking-delta catalogue. BMAD upstream currently v6.3.0 (installed version) — no deltas to propagate.'
inputDocuments:
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad.md
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md
  - _bmad-output/planning-artifacts/research/technical-keel-ralph-bmad-research-2026-04-17.md
  - _bmad-output/brainstorming/brainstorming-session-2026-04-17-0910.md
  - docs/ralph.md
documentCounts:
  briefs: 0
  prfaqs: 2
  research: 1
  brainstorming: 1
  projectDocs: 1
projectType: hybrid
ralphScope: in-scope-evolving-deliverable
workflowType: prd
classification:
  projectType: developer_tool
  projectSubtype: cli_tool
  contentShape: multi-shape-hardwired  # B2B + B2C hardwired at 1.0 (pick via one-line keel.config.ts edit — no wizard UI); Marketplace + API-first deferred to 1.1/1.2
  projectContext: greenfield  # absorbing brownfield Ralph harness
  domain: general
  domainNotes: agentic-engineering workflow; autonomous-code-execution risk surface
  complexity: high
  ralphDisposition: fork  # monthly upstream diff review
  qualityGatePosture: non-negotiable
  architectureStatus: axes-resolved-pending-formalization
  executionModel: containerized-agent-autonomy
  securityPosture: non-negotiable
  configurationModel: source-layer-pinned  # hardwired defaults in substrate code; keel.config.ts is a typed config file with two valid shape values (b2b, b2c), no wizard UI; shape variation limited to tenancy-template generator (team, user)
  personaModel: n-equals-one  # Tthew is the only user; any peer-audience framing is hypothetical and does not drive scope
  projectPosture: research-plus-boilerplate  # dual outcome — agentic-development research project AND functional opinionated boilerplate for rapid SaaS iteration
---

# Product Requirements Document - Keel

**Author:** Tthew
**Date:** 2026-04-17

## Executive Summary

Keel is an opinionated SaaS substrate with **source-layer-pinned invariants**, built for one person (Tthew) shipping SaaS ideas through agentic workflows — BMad planning, the Ralph loop, and Claude Code. It is simultaneously a **research project** (agentic-development under model-drift and invariant enforcement) and a **functional opinionated boilerplate** for rapid B2B / B2C SaaS iteration; both outcomes are first-class. The problem it solves: shipping SaaS ideas rapidly requires decisions made once and leveraged across product bets; when those decisions live as convention rather than in the repository as enforced invariants, each new product re-litigates infrastructure and agents spiral on questions that should already be settled. Future state: the builder spends more time on-the-loop (directing, reviewing, course-correcting) and less time in-the-loop (implementing mechanically), which compounds work across forks and unlocks product bets that wouldn't justify cold-start infrastructure investment on their own.

### What Makes This Special

Three co-equal first-class principles form a causal chain. **Invariants enforced at the source layer** (RLS policies, import boundaries, non-toggle-able gates, hardwired stack choices materialised in committed substrate code) enable agent coherence — agents do not re-litigate settled decisions because the decisions are not options. Agent coherence is the precondition for staying on-the-loop rather than babysitting agents in-the-loop. On-the-loop work then compounds across products, because decisions survive forks as invariants and do not evaporate as conventions.

Four load-bearing mechanisms implement the chain: (1) **source-layer invariant pinning** — substrate packages hardwire the stack choice (better-auth, Prisma + Postgres, TanStack Start, Paddle, pg-boss, Resend, English baseline) in committed code; a typed `keel.config.ts` carries only the values that genuinely vary per-fork (shape: `b2b` | `b2c`, tenancy: `team` | `user`, project identity, OTel exporter endpoint) and is consumed at build time by a narrow generator; (2) **non-toggle-able four-layer quality gates plus Ralph acceptance-driven backpressure** applied equally to agent-authored and human-authored commits; (3) **Day-1 RLS policies parameterised over two tenancy templates** (team for B2B, user for B2C) emitted by an idempotent generator with a pinned normalization contract — pure `expand(policy, config) → Rule[]`, canonicalised-output hashing, order-independent, deterministic merge precedence; (4) **decomposed CI pyramid** — pre-commit (≤10s), pre-merge-fast (≤3min, deterministic, no live network), pre-merge-slow (≤10min, ephemeral DB), nightly (≤60min, live-network sandbox hits quarantined here), release-gated (manual) — replacing any monolithic 60-minute gate on the critical path.

Thesis: *"Your agents are only as good as the decisions you've already frozen for them."* The competitive category is adjacent but not coincident — ShipFast, Makerkit, Supastarter are human-optimised boilerplates at the $199–$299 tier with runtime-toggleable or convention-based configuration and no agentic affordances; Bmalph-class tools are orchestration-only, not a deployable substrate. The honest competitor, however, is *a patient solo builder with a sharper CLAUDE.md* — which is why absorption risk is treated as a quarterly falsification test, not a long-horizon existential (see Success Criteria → Absorption tripwire). Keel's differentiator is the combination of agent-coherent scaffolding, source-layer invariant pinning, security-by-default (sandbox + Day-1 RLS + per-iteration verification + structured evidence), and the Ralph loop — not specific library choices.

### Execution Environment

Keel ships a Docker-based devbox (absorbed from the author's prior `cc-devbox` project) inside which Ralph, Claude Code, and all agent-authored code execution run under `--dangerously-skip-permissions` — the sandbox is what makes the flag safe. The host-side entry point is `pnpm <subcommand>`; pnpm scripts manage container lifecycle and forward commands. Ralph itself runs as a Python Textual TUI **inside** the devbox (orchestration runtime, not a user-facing 1.0 surface); users never invoke Docker, docker-compose, or SSH directly.

Autonomous Ralph execution has two one-time auth prerequisites inside the devbox: Claude Code (`pnpm claude` triggers OAuth; tokens persist in `/home/dev/.claude/`) and `gh` CLI (`pnpm gh:auth` triggers `gh auth login`; tokens persist in `/home/dev/.config/gh/`). Ralph cannot push commits or open PRs autonomously until `gh` is authenticated. Both flows surface their OAuth URLs to the host terminal; the host browser completes the flow; tokens stay inside the container volume and never touch the host's own `~/.claude/` or `~/.config/gh/`.

### Fork Initialisation

A Keel fork starts in one of two ways: `git clone` of a fresh substrate tag (pick the tag matching the tested model generation; see NFR30) or a minimal `pnpm dlx create-keel-app <name>` bootstrap that git-clones the substrate, strips upstream planning artefacts, and runs the first install. **There is no interactive setup wizard.** Shape selection is a one-line edit to `keel.config.ts` at the repo root — `shape: "b2b"` (default, hardwired) or `shape: "b2c"`. The edit triggers the generator to emit the matching tenancy-template RLS (`team` for B2B, `user` for B2C) and to materialise the corresponding hardwired Paddle billing preset (B2B team-seats config or B2C individual-subscription config). Invalid shape values fail at typecheck; the generator run is idempotent and content-hashed, so drift between `keel.config.ts` and the emitted invariants is caught by the pre-merge gate. Marketplace and API-first shapes are deferred to 1.1 / 1.2.

## Project Classification

- **Project Type:** `developer_tool` / `cli_tool`, `multi-shape-hardwired` content shape (B2B + B2C hardwired at 1.0 via one-line `keel.config.ts` edit; no wizard UI; Marketplace + API-first deferred to 1.1/1.2)
- **Configuration Model:** Source-layer-pinned invariants — substrate packages hardwire stack choices in committed code; `keel.config.ts` carries only per-fork values that genuinely vary (`shape`, `tenancy`, `projectIdentity`, OTel endpoint); a narrow idempotent generator emits the matching tenancy-template RLS and shape-specific billing preset
- **Persona Model:** `n-equals-one` — Tthew is the primary and only user. Any peer-audience framing is hypothetical and does not drive scope; a single named user does not constitute a market
- **Project Posture:** Dual — research project (agentic-development under model-drift + invariant enforcement) AND functional opinionated boilerplate. Success as research is decoupled from success as substrate; the monthly blank-starter-sprint log is the research output that persists even under substrate absorption
- **Domain:** `general` — agentic-engineering workflow; autonomous-code-execution risk surface
- **Complexity:** Medium-High — Day-1 RLS parameterised over two tenancy templates, narrow-scope idempotent generator with pinned normalization contract, stack aging under model/tooling evolution. (Downgraded from High after wizard-reversal — the combinatorial adapter-surface complexity is out of 1.0 scope.)
- **Project Context:** Greenfield, absorbing the brownfield Ralph harness (`ralphDisposition: fork`, monthly upstream diff review)
- **Quality Gate Posture:** Non-negotiable — disabling via config forbidden; forking to remove permitted
- **Architecture Status:** Axes resolved in brainstorm (reduced after wizard-reversal); formalization deferred to `bmad-create-architecture` with the generator's normalization contract and RLS tenancy-template design as the primary load-bearing surfaces

## Success Criteria

### User Success

Primary (and only) user is Tthew (N=1). User success is operationalised through two measurements with equal priority:

- **Time-to-next-product (T2NP)**: measured from "decision to start product #2" to "product shipped — live URL, working signup, first real user interaction." Target: < 1 week. Baseline: multi-week infrastructure re-litigation and stack-decision tax on an unstructured start.
- **Time-to-green-on-novel-adapter (TTGNA)**: median wall-clock from "new axis-implementation requested" (e.g., adding Stripe Connect for a marketplace fork, or a second framework scaffold) to "invariants green in CI, including RLS tests, import boundaries, and per-iteration security evidence." Machine-verifiable via git-timestamps + CI-log timestamps. Target: ≤ 2 working days at 1.0 cut; ≤ 4 hours by v1.2. Replaces the pre-wizard-reversal RIAR metric, which was gameable by self-imposed task-granularity. TTGNA's clock is externally-bound to an adapter unit and cannot be inflated by slicing work.

Secondary qualitative signal:

- **Self-reported on-the-loop ratio** at the M4 checkpoint and at 1.0 cut — subjective comparison against pre-Keel baseline. Pass/fail only; used as gut-check against T2NP and TTGNA.

### Business Success

- **Launchpad readiness (1.0 gate)**: live URL + working signup + one paying customer. Framed as functional test of the substrate, not a commercial milestone.
- **12-month / 2-product payback**: 2-4 products shipped on Keel within 12 months of 1.0.
- **Archive kill criterion (ACCEPTED)**: fewer than 2 products shipped within 12 months → archive Keel. This is the slow-clock post-mortem trigger, not the primary defence — the absorption tripwire below fires quarterly.
- **Maintenance ceiling (ACCEPTED)**: sustained > 15 hrs/month triggers scope-cut or archive. Expected steady-state: 5-10 hrs/month.
- **M4 checkpoint ritual (PROMOTED)**: explicit decision at end of critical path between "push remaining milestones" vs "pause and ship real product on partial substrate." Promoted from one-time M4 ritual to **recurring quarterly falsification checkpoint** post-1.0. Each run commits a markdown entry to `docs/checkpoints/` recording the decision and the evidence it was made against.
- **Absorption-risk tripwire (monthly blank-starter-sprint)**: every calendar month, a 2-hour timebox: the current frontier model (whichever shipped that month) is given a vanilla starter (Next.js + Supabase + Vercel, fresh `pnpm create`) and Keel's invariant manifest as context. Build the same vertical slice both ways, same time budget; log tokens, context-window exhaustion, rework rate, and wall-clock time-to-green. **Falsification threshold**: if blank-starter time-to-green comes within 20% of Keel's time-to-green for *two consecutive months*, the substrate layer is absorbed. **Response**: archive Keel codegen; pivot to **Invariant Pack** (versioned, LLM-consumable contract manifest shipped to npm within 30 days of tripwire). The sprint log is also the research-project output — it persists as evidence of the agent-capability curve independent of Keel's substrate fate.

### Technical Success

- **Decomposed CI pyramid (replaces monolithic 60-min gate)**:
  - **Pre-commit (≤10s)**: prek hooks, ESLint on changed files, commitlint, prompt-injection scan (FR40).
  - **Pre-merge-fast (≤3min, deterministic, no live network)**: full typecheck, generator idempotency (content-hash round-trip), RLS policy unit tests against synthetic schemas, webhook signature-verification contract tests with recorded fixtures, invariants-manifest sync (FR43).
  - **Pre-merge-slow (≤10min)**: RLS integration against ephemeral Postgres, generator end-to-end against both shape configs, one smoke-per-shape end-to-end.
  - **Nightly (≤60min)**: full shape × tenancy combinatoric (2 × 2 = 4 cells at 1.0 with Paddle hardwired per shape). Live-network sandbox hits (Paddle sandbox, Google OAuth) live here and only here. Flake budget resets daily.
  - **Release-gated (manual)**: pre-deploy 1.0-readiness verification. `git clone` → shape-edit → signup → tenant formation → paid Paddle sandbox subscription → teardown. Runs on both shapes (B2B team + B2C user). Non-toggle-able. Red gate = broken repo.
- **Four-layer quality gates** (pre-commit / pre-merge / pre-deploy / release), non-toggle-able at config layer. Applied identically to agent-authored and human-authored commits.
- **Ralph acceptance-driven backpressure**: plan file (`.ralph/@plan.md`) enumerates a `Required tests:` list per task (schema-validated, not prose); task cannot be marked done until every listed test passes. Loop halts on 3 consecutive failures of the same test, on task-budget exhaustion, or on critical-severity security findings.
- **Day-1 RLS invariant**: every tenant-scoped table ships with a Postgres RLS policy parameterised over the shape's tenancy template (`team` for B2B, `user` for B2C). Policy source-of-truth is `keel.config.ts → { shape, tenancy }`; the generator emits the matching `current_setting('app.current_tenant_id')` session variable and RLS template. Physical prevention, not convention. Both templates ship in 1.0; `org` tenancy is Growth-tier.
- **Import-boundary enforcement**: ESLint `no-restricted-imports` + TypeScript project references. Compile-time, not review-time. Rules hardwired in `packages/keel-invariants/` (static — they do not vary by shape).
- **Config-to-invariants sync (narrow scope)**: `keel.config.ts` edits to `shape` / `tenancy` without matching regenerated RLS/billing-preset outputs fail the pre-merge gate. Re-running the generator is idempotent; the normalization contract (pure `expand(policy, config) → Rule[]`, canonicalised-output hashing, order-independent, deterministic merge precedence) closes the drift hole.

## Product Scope

### MVP - Minimum Viable Product (Keel 1.0)

**28-day milestone plan (30-34-day realistic-slip).** MVP gate: Launchpad. This budget restores the original pre-wizard-pivot posture (26d) and adds a narrow 2d increment for the tenancy-template generator and B2C shape support (two hardwired Paddle presets, two tenancy templates). Adapter-surface multi-implementation scope (the 22-day blowout from the wizard-pivot) is entirely removed; alternatives to any single-impl default are Growth-tier.

- **M0 Repo foundation & tooling** (2d) — pnpm workspaces, Turborepo, prek, commitlint, release-please, ESLint + TS project refs, conventional-commits enforcement. ESLint config and tsconfig-base are **hardwired** in `packages/keel-invariants/`, not generated.
- **M0.5 Devbox** (3d) — absorb `cc-devbox` into `packages/devbox/`; parameterise hardcoded paths; auto-start logic and TUI docker-attach UX.
- **M0.7 Tenancy-template generator** (2d, was 3d config-as-invariants) — narrow-scope idempotent generator: reads `keel.config.ts` (typed schema carrying `shape`, `tenancy`, `projectIdentity`, OTel endpoint), emits the matching RLS tenancy template and the shape-specific Paddle billing preset. Normalization contract pinned: pure `expand(policy, config) → Rule[]`, canonicalised-output hashing, order-independent, deterministic merge precedence. Sync-enforcement pre-merge gate covers `keel.config.ts` → generator-output drift.
- **M1 Data model + RLS tenancy** (3d) — Day-1 RLS policies for **two tenancy templates** (team for B2B, user for B2C); `tenantGuard()` as session-variable-setter keyed on `app.current_tenant_id`; `pnpm rls:explain` CLI; RLS policy unit tests against synthetic schemas and integration tests against ephemeral Postgres for both templates.
- **M2 Auth & Identity** (3d) — **better-auth hardwired** (no adapter surface): DB-backed sessions, Google OAuth + email/password, step-up middleware, `requireRecentAuth` wrapper. A thin `packages/core/auth` re-export surface exists so `apps/web` imports are stable, but there is no second implementation scaffolded.
- **M3 Billing** (3d) — **Paddle hardwired** with two shape-specific preset configs (B2B team-seats; B2C individual-subscription). Webhook processing, signature verification, idempotent lifecycle handling. Stripe Connect (marketplace) and Stripe standard (API-first) are Growth-tier — shipped in 1.1 / 1.2 when a product of that shape is actually queued.
- **M4 Email + Jobs** (2d) — **Resend hardwired** with three baseline email templates (verify, invite, reset); **pg-boss hardwired** typed job registry.
- **M5 Observability + Audit** (2d) — OpenTelemetry traces with config-file-driven exporter endpoint; append-only audit log schema.
- **M6 Feature flags** (1d) — server-side evaluation in TanStack Start route loaders.
- **M7 Frontend patterns + UI** (3d) — **TanStack Start hardwired** + tRPC + react-hook-form + Zod + Zustand + Tailwind + i18n framework with typed-key enforcement; English baseline locale.
- **M9 Testing & CI hardening** (4d) — decomposed CI pyramid (pre-commit / pre-merge-fast / pre-merge-slow / nightly / release-gated) per Technical Success; RLS policy tests across both tenancy templates; shape × tenancy matrix in nightly (2×2 = 4 cells with Paddle hardwired per shape); acceptance-driven backpressure wiring (`Required tests:` schema in `.ralph/@plan.md`); per-iteration security-evidence persistence.

M0.6 (Keel CLI + wizard engine), M8 (migration-between-choices guides), and adapter-surface work in M2/M3/M7 are **out of 1.0 scope** (removed in the wizard-reversal pivot — see editHistory). If a second implementation on any axis becomes load-bearing post-1.0, it enters via Growth-tier with its own CI-tested migration path.

### Growth Features (Post-MVP)

- **Marketplace shape (1.1)**: `shape: "marketplace"` added to `keel.config.ts`; Stripe Connect hardwired as the billing preset for this shape (wizard-reversal policy: a *third hardwired preset*, not an adapter surface); dispute resolution workflow scaffold; ratings / reviews scaffold; payout dashboard; multi-role identity (buyer / seller). Ships only when a marketplace product is actually queued to consume it (applies YAGNI to itself).
- **API-first shape (1.2)**: `shape: "api_first"` added; Stripe standard hardwired as the billing preset; developer portal, sandbox environments, quota-based pricing, OpenAPI surface, outbound-webhook subscription, API key lifecycle. Same "ships when consumed" policy.
- **Org tenancy template (Growth)**: `tenancy: "org"` added as a third RLS template for fork-types that need nested-scope tenancy. Triggers only when a real fork-consumer demands it.
- **Second-implementation adapters (on-demand)**: if and only if a specific axis (auth, ORM, framework, email, jobs) needs a second implementation to unblock a real product, the second impl enters via a thin adapter surface paired with a CI-tested migration path. One axis at a time, driven by actual consumption. The default posture remains single-impl-hardwired.
- **Runtime-configurable substrate pieces** (deliberate limited scope): only truly runtime concerns (feature flag evaluation, locale selection, OTel sampling rate) move to runtime configuration. Core stack choices remain hardwired at the source layer.
- **Operational polish**: shell completion for `pnpm` commands; headless Ralph mode (`--no-tui`) for CI scenarios; additional email templates; additional deploy-target Dockerfiles (Vercel, Fly, Railway) as optional presets.

### Vision (Future)

Keel 1.0 is the first codified substrate in a larger meta-framework for shipping SaaS ideas on agentic workflows. The meta-framework composes three pillars:

1. **BMad** — planning artefacts (PRD, architecture, epics, stories) as enforceable contracts between phases.
2. **Ralph** — autonomous loop harness running against committed plans.
3. **Keel** — substrate on which Ralph executes; source-layer-pinned invariants (hardwired stack choices + generated RLS/billing templates) that let agents stay coherent across iterations and forks. If the monthly absorption tripwire fires, pillar 3 pivots from "substrate" to **Invariant Pack** — a versioned, LLM-consumable contract manifest plugging into any starter, shipped to npm within 30 days of tripwire.

Vision is dogfood-first: the meta-framework is validated by Tthew shipping multiple products on it, not by external adoption. Adoption signaling (blog post, peer-community share) is permitted but not planned. The research-project output (monthly blank-starter-sprint logs + per-iteration evidence archives) is a first-class deliverable that persists independently of substrate fate.

### Out of Scope

Consolidated exclusions. Items here are explicitly not in 1.0 scope; most are either non-toggle-able invariants (fork-to-remove) or deliberate architectural non-commitments. Downstream Epics and Stories that propose any of these items must be rejected or escalated to a scope-change decision.

**Languages & polyglot targets:**

- No Python / Go / Rust / Ruby SDKs. TypeScript only, end-to-end.
- No non-pnpm package managers. `pnpm` is the monorepo contract; npm and yarn are unsupported.

**Setup UX non-commitments (post-wizard-reversal):**

- **No interactive setup wizard.** There is no `pnpm keel:init`, no `pnpm keel:configure`, no `create-keel-app` wizard-UI, no choice catalogue, no incompatible-combination validator-at-wizard-time. Fork initialisation is `git clone` of a tagged release or the minimal `pnpm dlx create-keel-app <name>` bootstrap (clone + strip planning artefacts + first install).
- **No stack-axis optionality at 1.0.** Each axis (auth, DB, framework, billing, jobs, email) has exactly one hardwired implementation. Second implementations enter post-1.0 on a per-axis, consumption-driven basis via thin adapter + migration guide (see Growth Features).
- **No migration-between-choices guides at 1.0.** With one impl per axis there is nothing to migrate between. Growth-tier second-implementations ship with their own migration paths individually.

**Product shapes at 1.0:**

- **Supported at 1.0**: B2B (default, `shape: "b2b"`, team tenancy) and B2C (`shape: "b2c"`, user tenancy). Shape is a one-line edit to `keel.config.ts`; each shape has a hardwired Paddle billing preset (team-seats for B2B; individual-subscription for B2C).
- **Deferred to 1.1 / 1.2**: Marketplace (`shape: "marketplace"` — Stripe Connect, multi-role, payouts, disputes) and API-first (`shape: "api_first"` — Stripe standard, quota-based billing, developer portal, public API surface, outbound webhooks, API key lifecycle). These are Growth-tier per the "shipped only when a product of that shape is queued" policy.
- No clean learner / tutorial experience. Keel assumes prior SaaS shipping.
- No custom / free-form shape at 1.0. New shapes enter via minor-version bumps after real-product demand, not per-fork.

**Enterprise affordances (explicit non-commitments):**

- No SSO adapter (SAML / OIDC beyond Google OAuth). Growth-tier candidate.
- No SIEM / audit-log shipping to external systems.
- No SOC 2 / ISO 27001 / HIPAA / PCI-DSS compliance posture. ASVS Level 2+ lives behind a Tier-2 deviation path (see Developer-Tool & CLI-Tool Specific → Implementation Considerations for definition) for compliance-bound forks.

**Capabilities deferred beyond 1.0:**

- No admin dashboard.
- No IDE plugin / extension. The agentic workflow is the IDE.
- No shell completion for `pnpm` commands at 1.0.
- No headless Ralph (`--no-tui`) mode at 1.0. Growth-tier candidate.
- No global user-level config file. Per-project `.ralph/` dotfiles only.
- No per-fork substrate extensions at 1.0. Forks can add product-specific invariants via `INVARIANTS.fork.md` (FR45) but substrate-scoped invariants remain upstream.

**Governance non-commitments:**

- No toggle-able quality gates post-setup. Removal requires fork.
- No backwards-compatibility guarantees across Keel major versions. Each major documents its tested model/tooling combination; breaking model upgrades trigger new majors (see NFR30).
- `keel.config.ts` schema evolution across majors follows the same policy — minor additions (new fields with sensible defaults) are non-breaking; removals or semantic changes trigger a major.

**Out of project (belongs to a separate follow-on):**

- No distribution strategy / customer-acquisition playbook.
- No `npm publish` of individual substrate packages. Fork-and-use only. (Exception: the Invariant Pack, if the absorption tripwire fires, is published to npm as the pivot destination.)
- No planned adoption signaling (blog, peer-community push). Permitted but not planned.
- No scope commitment for agent-authorship workflows outside the Claude Code + BMad + Ralph triad. Tests and docs assume this stack.
- **No peer-user scope.** Keel's persona is N=1=Tthew. Any peer-operator framing (agency fork, team-of-one use, etc.) is hypothetical and does not drive capability, journey, or test scope. If a peer appears and wants to use Keel, that is a signal to reconsider scope — not a reason to pre-build for it.

## User Journeys

### Journey 1 — Tthew: Product #2 Happy Path (validates T2NP ≤ 1 week)

**Opening.** Saturday morning, eight months after Keel 1.0 cut. Tthew has a new product idea (a B2C consumer app, unlike product #1 which was B2B) percolating for two weeks. Decision made: start it. Time-tracking begins.

**Rising action.** `pnpm dlx create-keel-app product2-app` — the minimal bootstrap clones the latest substrate tag, strips upstream planning artefacts, runs `pnpm install`. Two minutes. Tthew opens `keel.config.ts` and edits one line: `shape: "b2b"` → `shape: "b2c"`. The pre-commit hook runs the generator, which emits the B2C tenancy template (user-scoped RLS) and the B2C Paddle billing preset (individual-subscription); the pre-merge-fast gate passes in under 3 minutes; the pre-merge-slow gate passes in under 10. No stack decision re-litigated — every substrate choice is hardwired in committed code, not re-chosen. Product-specific work begins at minute 15.

**Climax.** Day three. First product feature (domain entity + tRPC route + UI) lands green, including Day-1 RLS policy for the new table (generated from the `tenancy = user` setting in `keel.config.ts`). No tenant-filter bug escapes because the policy is invariant, not convention. Claude Code has been running Ralph iterations against the story list since day one; acceptance-driven backpressure (per-task `Required tests:` schema) means the first iteration that tried to skip the RLS test on the new `user_profile` table was rejected by the plan gate before it reached CI.

**Resolution.** Day six. Live URL, signup working, first real user interaction recorded. T2NP for product #2 (inclusive of the 15-minute bootstrap + config edit): 6 days 2 hours. Target: < 1 week. Pass. TTGNA for the `user`-tenancy RLS template (already exercised by substrate CI, so no new-adapter work) is recorded as 0. The next month, the monthly blank-starter-sprint datapoint for March comes in at Keel's time-to-green +38% — Keel still earns its keep. The next Saturday, Tthew considers a further product idea — not because the current one is scaled, but because the cold-start tax no longer deters the attempt.

### Journey 2 — Tthew: M4 Checkpoint Governance Ritual (edge case)

**Opening.** Day ~18 of the 28-day Keel 1.0 build — M4 has just closed. M0-M4 green (repo foundation, devbox, narrow-scope tenancy generator, Day-1 RLS for team + user templates, better-auth hardwired, Paddle hardwired with B2B + B2C presets, Resend + pg-boss). M5-M9 remain (observability, flags, frontend patterns, CI hardening). Tthew opens the calendar entry for the M4 checkpoint.

**Rising action.** The question is pre-committed and specific: "Push M5-M9, or pause and ship real product on partial substrate?" Repo state tells part of the story: pre-merge-fast + pre-merge-slow gates green on both shapes; four-layer gates in place; RLS invariants enforced for team and user templates; generator idempotency + drift-detection landed; bootstrap-clone path works end-to-end. What is missing: observability, feature flags, hardened frontend patterns, decomposed CI pyramid nightly/release-gated tiers. The actual signal: a B2C product idea has been deferred precisely because substrate was not ready, and the quarterly absorption tripwire is approaching its third run — the research-project clock is ticking on a substrate-delta datapoint.

**Climax.** Tthew picks "pause and ship." Substrate at ~60% of 1.0 scope but covers every load-bearing concern for the deferred B2C product. The decision is committed as a markdown entry in `docs/checkpoints/` (not a private note), naming the three observations that tipped the call. M5-M9 become Phase 1.1, scheduled post-launch.

**Resolution.** The ritual protects against its own failure mode — procrastination masquerading as finishing. The 12-month archive clock starts when the partial-Keel product ships, not when 1.0 is cut; the monthly blank-starter-sprint keeps running either way. Three months later, the shipped product forces M5 (observability) because debugging needs it — the substrate learns which unbuilt milestones are actually load-bearing vs aspirational. Post-1.0, the M4 ritual is promoted to a **recurring quarterly checkpoint** — same decision framing, new evidence each quarter.

### Journey 3 — Ralph / Claude Code: Agent Iteration on a Keel Repo (validates TTGNA + acceptance-driven backpressure)

*Departure from narrative template: state-transition arc for a non-human user.*

**Precondition state.**

- Repo at commit N with all four gate tiers green (pre-commit, pre-merge-fast, pre-merge-slow, prior nightly); RLS policies validated for the fork's shape; `keel.config.ts` committed with `shape: "b2b"`, `tenancy: "team"`.
- Devbox container running (auto-started by `pnpm ralph:build` if not already up); DNS whitelist active; `--dangerously-skip-permissions` safe because sandboxed.
- Claude Code and `gh` CLI both authenticated inside the devbox volume; tokens persist across container restarts; prerequisite check passed.
- `.ralph/@plan.md` holds the current story with acceptance-driven structure — story #42 "Add email verification flow for new team invites" with a machine-validated `Required tests:` list (unit tests on the mutation, integration test against ephemeral Postgres, RLS test on the `invite_tokens` table, security-evidence scan on the iteration diff).
- Claude Code context loaded with the fork's invariants — hardwired stack choices (better-auth, Resend, pg-boss, Prisma, TanStack Start) exposed via `CLAUDE.md` + skill definitions + `INVARIANTS.md`; `keel.config.ts` values (shape, tenancy, projectIdentity) read from the same source. Agents treat all of this as invariants, not options.
- Ralph iteration budget: 30 minutes per iteration; 3 consecutive failures of the same test halts the loop.

**Iteration flow.**

1. Ralph (running inside the devbox) spawns `claude -p --dangerously-skip-permissions` with adaptive thinking + explicit `effort: "xhigh"`, piping the build-mode Ralph prompt (`.ralph/PROMPT_build.md`) as input. The Ralph prompt directs Claude to read `.ralph/@plan.md`, pick story #42, and execute it. Claude reads the bind-mounted workspace, sees `packages/core/auth`, `packages/email`, and existing better-auth patterns. No decision is re-litigated.
2. Claude writes a new tRPC mutation `team.inviteWithVerification`, adds a Zod schema, creates a Resend email template, wires pg-boss to enqueue the verification send.
3. `Required tests:` list is driven in order. Unit tests pass. Integration tests pass. RLS policy test against the new `invite_tokens` table fails — no policy exists yet. Acceptance-driven backpressure blocks the task-done mark.
4. Ralph sees the failure. Claude reads the generator's team-tenancy template, writes the RLS policy matching it, re-runs the RLS test. Pass. Security-evidence scan (secret scan + dep audit + SAST + prompt-injection scan on the diff) runs; evidence is persisted to `.ralph/logs/<iteration-id>/security-evidence.json`. All evidence green.
5. All tests in `Required tests:` green. Conventional-commit message generated. Iteration commits and pushes.

**Backpressure branch (alternate path).**

If iteration 3 in a row fails the same integration test, Ralph halts via `.ralph/halt`. A critical-severity security finding halts immediately without retry (NFR18).

**Success signal.** Iteration completes autonomously under the acceptance-driven plan; TTGNA for novel-adapter work (if the story required one) is logged to `.ralph/logs/ttgna.jsonl` for success-criteria measurement.

**Repository-state delta.** New mutation, new email template, new RLS policy, new pg-boss job registration — all four landing together because the substrate made all four patterns local and findable, and because the hardwired stack meant the agent did not have to choose.

### Journey Requirements Summary

The three journeys converge on the same capability set — which is the point, not a coincidence.

| Capability                                             | Journeys  | Milestones     |
|--------------------------------------------------------|-----------|----------------|
| Minimal bootstrap (clone + strip + install)            | J1        | M0, M9         |
| Source-layer-pinned stack (hardwired substrate)        | J1, J3    | M2, M3, M4, M7 |
| Tenancy-template generator (team + user; narrow scope) | J1, J3    | M0.7, M1       |
| Day-1 RLS parameterised over shape → tenancy           | J1, J3    | M0.7, M1       |
| `keel.config.ts` one-line shape edit                   | J1        | M0.7           |
| Package boundaries enforced at compile time            | J3        | M0             |
| Ralph acceptance-driven backpressure + decomposed CI   | J3        | M9, harness    |
| Per-iteration security verification + evidence         | J3        | M0, M9         |
| Observability + audit + feature-flags + i18n baseline (FR21-FR27, FR64) | J1, J3 (implicit) | M5, M6, M7 |
| Checkpoint ritual + governance artifacts in `docs/checkpoints/` | J2 | (ongoing)      |
| Monthly blank-starter-sprint tripwire                  | J1, J2    | (ongoing post-1.0) |

## Domain-Specific Requirements

Keel's domain is general SaaS — no regulatory regime binds substrate code. Complexity is medium-high on technical grounds (downgraded from high post-wizard-reversal; the combinatorial adapter-surface complexity is out of scope). Four domain-novel concerns are captured here because they are not covered by Executive Summary, Technical Success, or standard NFRs.

### Autonomous-Code-Execution Risk Surface

Keel repos are designed for agent authorship under Ralph + Claude Code. The implied risk surface is inherited from the workflow, not from the substrate stack:

- **Prompt injection** — via story files, committed markdown, or upstream docs reachable by agent context loaders.
- **Loop-runaway economics** — unbounded iteration consuming model tokens against broken premises.
- **Agent-generated-code review gaps** — human review bandwidth does not scale with agent commit rate.

Substrate mitigations (load-bearing, non-toggle-able):

- **Execution containerization via devbox.** All agent execution runs inside a Docker container with dnsmasq-based DNS whitelist (default-deny), non-root user, NET_ADMIN/NET_RAW-only kernel capabilities, and noexec/nosuid tmpfs for `/tmp` and logs. This is what makes `--dangerously-skip-permissions` safe; a runtime compromise cannot reach the host.
- **Per-iteration security verification.** Every Ralph iteration runs secret scan, dependency audit, SAST, and prompt-injection scan on the diff before commit; findings block the commit; evidence is persisted (see Security-by-Default Requirements).
- **Ralph backpressure** halts the loop on consecutive test failures.
- **Per-iteration task-budget ceiling** prevents loop-runaway economics.
- **All four quality-gate layers** apply equally to agent-authored and human-authored commits.
- **Conventional-commit format** preserves commit-level traceability regardless of author.

### Correlated-Library Risk Policy

Two hardwired libraries carry correlated-community risk at 1.0: **TanStack Start** (framework) and **better-auth** (auth library). Both are young relative to their incumbents; both are the single implementation of their axis in 1.0. Policy:

1. **Monitor cadence.** Each hardwired library's maintenance signal is checked quarterly: release frequency, open-issue velocity, unpatched security advisories, upstream project health.
2. **Threshold for demotion.** If a hardwired library's signal drops below a named threshold — no release in 6 months, *or* security advisory unpatched > 14 days, *or* maintainer abandonment signal — the next major Keel version replaces that hardwired choice with an alternative (e.g., better-auth → Auth.js, TanStack Start → Next.js). The replacement is shipped with a **one-axis migration path** (codemod + manual steps) as a substrate-upgrade guide, not a wizard-option migration.
3. **No speculative hedging.** Adapter surfaces are not pre-built for hardwired libraries on the chance they fail. If demotion happens, it happens as a real one-time migration, not as ambient adapter-maintenance tax.

### Model and Tooling Evolution

Opus 4.7 broke prompts tuned for Opus 4.6 (April 2026 release). Policy: every Keel major version documents the model generation and tooling versions it was tested against. A breaking model upgrade is a triggering event for a major Keel release test-run — not a silent bump.

**Concrete Opus 4.6 → 4.7 deltas that motivate this policy** (sourced from `platform.claude.com/docs/en/about-claude/models/migration-guide`):

- **Extended-thinking API change.** `thinking: { type: "enabled", budget_tokens: N }` now returns 400. Replacement: `thinking: { type: "adaptive" }` with `output_config.effort` tuning. Adaptive thinking is off by default — bare requests run without thinking and appear to stall before first output if the harness waits on reasoning.
- **Thinking display default.** Previously `summarized`; now `omitted`. Harnesses that treated streaming reasoning as a liveness signal must set `thinking.display = "summarized"` explicitly.
- **Sampling knobs removed.** Non-default `temperature` / `top_p` / `top_k` return 400. Steering happens via prompt phrasing and `effort` alone.
- **Assistant-message prefills removed.** Replaced by structured outputs, `output_config.format`, or explicit system instructions.
- **Tokenizer re-baseline.** Up to ~35% more tokens per byte for the same text on Opus 4.7. `max_tokens`, compaction triggers, and the ~117K iteration budget must be re-calibrated per model version.
- **More literal instruction following.** Opus 4.7 does not silently generalise one-item examples to siblings. Prompt scaffolding must spell out every rule.
- **Fewer subagents and tool calls by default.** Ralph-style fan-out must be explicitly prompted; raise `effort` to `high`/`xhigh` to restore Opus-4.6-equivalent spawn rates.
- **Positive examples preferred over negative instructions.** "Positive examples showing how Claude can communicate with the appropriate level of concision tend to be more effective than negative examples."
- **New stop reason.** `model_context_window_exceeded` is now distinct from `max_tokens`. Harnesses must branch on it.
- **`task_budget` beta advisory.** Header `task-budgets-2026-03-13`, 20K minimum; model-visible running counter distinct from `max_tokens` that paces thinking + tool calls + output across an iteration. Not a hard cap — a suggestion. Keel will adopt it for per-iteration token pacing where supported.
- **Dropped beta headers.** `fine-grained-tool-streaming-2025-05-14`, `interleaved-thinking-2025-05-14`, `effort-2025-11-24` are all GA-merged. Keel prompts must not carry them.
- **Expanded cybersecurity refusal class.** Legitimate pentest/vuln workflows require the Cyber Verification Program; relevant to forks in regulated-compliance or security-research territory, not substrate-default.

Each delta above is a reason the substrate's prompt-set is pinned per major Keel version (see NFR29a) and why a breaking model upgrade is treated as a major-release test-run event (NFR30).

### Agent-Capability Substrate Absorption Risk

The PRFAQ named this as Keel's top existential risk. As agent capability grows — larger context windows, better long-horizon coherence, more sophisticated tool use — the load-bearing decisions Keel encodes as invariants may become reproducible on-the-fly by a sufficiently capable agent operating directly on an empty repo. If that happens, the substrate category itself collapses.

- **Probability / timing:** possible 2026, probable 2027. Relevance window: 12–18 months from 1.0 cut. **This risk is treated as a quarterly-observable falsification test, not a long-horizon existential** (see Success Criteria → Absorption-risk tripwire).
- **Failure signature:** an agent given a plain `pnpm create …` starter plus Keel's invariant manifest produces substantively equivalent substrate output (Day-1 RLS parameterised by tenancy, source-layer invariant pinning for auth/payments/jobs/DB/framework, non-toggle-able gates) inside a single long-running session without Keel's codegen layer.
- **Governance response (primary — quarterly tripwire):** the **monthly blank-starter-sprint** (Success Criteria § Business Success) is the load-bearing defence. 2-hour timebox per month; current frontier model; vanilla starter + Keel manifest as context; build the same vertical slice both ways and compare wall-clock time-to-green. If blank-starter comes within 20% of Keel for two consecutive months, substrate is absorbed → pivot to Invariant Pack within 30 days.
- **Governance response (secondary — slow clock):** the 12-month / 2-product archive kill criterion and the recurring M4 checkpoint ritual. These are post-mortem-style triggers; they detect irrelevance after it has already cost opportunity, and are retained as final backstops.
- **Mitigation principle (survives absorption):** what survives is the **principle layer** — YAGNI, DRY, NIH-refusal, invariants-beat-conventions, and the documented rationale behind the load-bearing axes — not the specific stack choices. Keel's internal docs preserve the *why* so the next substrate (or an agent recreating it) inherits the reasoning even if the code is obsolete. The Invariant Pack pivot target *is* this principle layer in publishable form.
- **Research-project framing:** the monthly sprint log is itself a first-class output regardless of substrate fate. Each datapoint measures a specific model generation's substrate-equivalence delta on a specific vertical slice — the curve of that delta over time is the agentic-development research artefact Keel contributes to the field.
- **Triggering signals to watch (between tripwire firings):** an agent reliably producing green substrate-equivalent output from a blank starter inside one context window; Bmalph-class orchestration tools shipping substrate defaults; a major model release explicitly marketed as "SaaS-ready out of the box."

## Innovation & Novel Patterns

### Detected Innovation Areas

Keel's innovation is not in individual stack choices (Postgres, Tailwind, OpenTelemetry are boring on purpose). Innovation lives in *source-layer invariant discipline applied to a hardwired stack, under a research-project posture that falsifies its own novelty on a quarterly clock*:

1. **Source-layer invariant pinning (core novelty).** Substrate packages hardwire stack choices in committed code; `keel.config.ts` carries only the values that genuinely vary per-fork (shape, tenancy, project identity, OTel endpoint). Agents see committed substrate as the invariants — they cannot re-litigate a decision that is a physical dependency. Competing boilerplates (Makerkit, ShipFast, Supastarter) are configurable at runtime / convention-based; Keel is hardwired, with narrow per-fork variation generated from the typed config. This is the axis on which Keel differs from the $199-$299 tier.
2. **Agent-coherent scaffolding.** `CLAUDE.md` + `INVARIANTS.md` + the three-layer invariants stack compose into a scaffolding model where agent context is always consistent with the committed substrate. Because the substrate is hardwired (not choice-based), there is no fork-time variance for context to drift against; the narrow generator output (RLS templates + billing presets) is the only variation surface, and it is content-hash-verified.
3. **Day-1 RLS as generator output.** RLS policies are parameterised over the shape's tenancy template (team for B2B, user for B2C) and emitted by the generator. Appears novel for this class of boilerplate: verified against Makerkit, ShipFast, Supastarter, SaaS Pegasus, Bullet Train, Nextacular, Chadnext — none ship RLS Day-1 let alone tenancy-parameterised RLS. Long-tail indie substrates not exhaustively swept.
4. **Non-toggle-able quality gates + forkability.** Four-layer gates cannot be disabled via config. To remove a gate, fork. Governance choice: "permissibility of change" is encoded at the source layer, not the config layer. The decomposed CI pyramid (pre-commit / pre-merge-fast / pre-merge-slow / nightly / release-gated) preserves this invariant while enabling fast pre-merge feedback.
5. **Acceptance-driven backpressure + per-iteration security evidence.** Ralph plan files carry a schema-validated `Required tests:` list per task; tasks cannot close until every listed test passes. Per-iteration security scans (secret, dep, SAST, prompt-injection) persist structured evidence to `.ralph/logs/`. Together these make agent authorship auditable and non-fraudulent in a way manual human review cannot scale to.
6. **Absorption-falsification as research methodology.** The monthly blank-starter-sprint is both governance (tripwire) and research (datapoint series). No competing project in the boilerplate space treats its own obsolescence as a first-class measurement.
7. **Meta-framework composition (BMad + Ralph + Keel + Claude Code).** No known competing project ships this specific chain: planning contracts → autonomous loop → source-layer-pinned substrate → agent runtime.

### Market Context & Competitive Landscape

Closest adjacencies: Bmalph / vibesparking (orchestration-only); Antigravity skill packs (skill layers, no substrate); Makerkit / ShipFast / Supastarter (human-optimised boilerplates, commoditised at $199–$299, typically Stripe-first, no agentic affordances, no source-layer invariant pinning — their configurability is runtime / convention). See `_bmad-output/planning-artifacts/research/` for competitive detail.

**Honest-competitor note**: the real competitor is not a commercial boilerplate — it is *a patient solo builder with a sharper CLAUDE.md*. A disciplined operator hand-rolling invariants in a weekend for product #1 and copying them into product #2 produces a convention, not a category. Keel's defence is (a) source-layer pinning makes the invariants materially enforced, not conventional, and (b) the monthly blank-starter-sprint falsifies this defence on a rolling basis — if the sharper-CLAUDE.md-alternative reaches parity, Keel pivots to the Invariant Pack.

Hedged: "verified empty" reflects first-page-of-Google + known-community scan; long-tail indie GitHub substrates labelled "agent-ready saas starter" or "claude-optimised boilerplate" not exhaustively swept. The source-layer-pinned-invariants + substrate-absorption-falsification pattern is the defensible novelty.

### Validation Approach

Each innovation area has a specific validation gate:

| Innovation                                      | Validation Gate                                                                                      |
|-------------------------------------------------|------------------------------------------------------------------------------------------------------|
| Source-layer invariant pinning                  | ≥ 2 products shipped on Keel forks with < 1 hour substrate-re-litigation time; TTGNA ≤ 2 working days at 1.0 |
| Agent-coherent scaffolding                      | Acceptance-driven backpressure on `Required tests:` blocks ≥ 1 real regression per week in dogfood use; Ralph logs prove it |
| Substrate-as-category (vs absorbed-already)     | Monthly blank-starter-sprint log shows > 20% time-to-green delta sustained across 12 months         |
| Day-1 RLS parameterised (team + user)           | Pre-M1 tenancy-template spike converges in ≤ 1.5 days per template (team, user); org deferred to Growth-tier |
| Non-toggle-able gates                           | Repo audit at 1.0 cut: no gate disable-able without a source-layer fork                              |
| Per-iteration security evidence                 | 100% of Ralph iterations at 1.0 produce `security-evidence.json`; sampling audit confirms green evidence matches green commits |
| Meta-framework composition                      | T2NP < 1 week on product #2; TTGNA ≤ 2 working days on any novel-adapter work                        |
| Absorption-falsification research output        | ≥ 6 consecutive monthly blank-starter-sprint datapoints published by month 6 post-1.0                 |

### Risk Mitigation

- **Category-creation hazard**: fallback positioning is "opinionated agent-authored SaaS boilerplate with source-layer invariant enforcement." No refactor required if the "category" framing doesn't land — the mechanisms are independently valuable.
- **RLS complexity overflow**: downgrade affected tenancy template to Growth-tier if pre-M1 spike doesn't converge; org tenancy is already Growth-tier for this reason.
- **Hardwired-library failure** (TanStack Start or better-auth maintenance signal drops): the next major Keel version replaces the hardwired choice with an alternative via a one-axis codemod migration. Not pre-built.
- **Meta-framework piece churn**: tested-combination documented per Keel major version; breaking model upgrade triggers a test-run release (NFR30).
- **Absorption-tripwire false-positive** (one anomalous month of close blank-starter parity): the 20%-for-two-consecutive-months threshold resists single-datapoint noise; re-run the sprint with a different vertical slice before declaring absorption.

## Developer-Tool & CLI-Tool Specific Requirements

### Project-Type Overview

Keel is primarily a **developer_tool** (SaaS substrate shipped to developers) with a **cli_tool** surface exposed via pnpm scripts. The single host-side user surface is `pnpm <subcommand>`; scripts manage the devbox container lifecycle and forward commands. Users never type `docker`, `docker compose`, or `ssh` directly. Keel produces product instances in one of two **hardwired** shapes at 1.0 — B2B (default) and B2C — selected by a one-line edit to `keel.config.ts`. Marketplace and API-first shapes are deferred to 1.1/1.2. There is no interactive setup wizard: the substrate ships hardwired, and the narrow per-fork variation (shape → tenancy template → billing preset) is handled by an idempotent generator reading the typed config.

### Developer-Tool Surface

**Language support.** TypeScript only, end-to-end. No polyglot targets — Python / Go / Rust SDKs are explicitly out of scope. Rationale: single-language typing across the tRPC boundary is a first-principles substrate commitment. Ralph's internal Python (Textual TUI) runs only inside the devbox and is orchestration runtime, not a user-facing surface.

**Package manager.** `pnpm` only. Monorepo uses `pnpm workspaces` + Turborepo; alternative package managers (npm, yarn) are not supported. CI fails builds that use other managers.

**Installation methods.** Two paths at 1.0:

1. `pnpm dlx create-keel-app <project-name>` — minimal bootstrap: git-clones the substrate at its latest tag, strips upstream planning artefacts (`_bmad-output/` → `docs/archive/`), runs `pnpm install`, commits the first commit. No wizard; no prompts. Non-interactive end-to-end.
2. `git clone <keel-tag>` — direct clone of a tagged substrate release. The user then edits `keel.config.ts` if shape differs from the default, commits, and is ready to start product work.

No `npm publish` of individual packages at 1.0. Fork-and-use model; packages are not distributed as standalone libraries. (Exception retained: the Invariant Pack, if the absorption tripwire fires, publishes to npm as the pivot destination.)

**Prerequisite: Docker Desktop** (or equivalent Linux Docker runtime). The devbox is a non-toggle-able invariant; fresh forks run a first-run check that fails with a pointer to install instructions.

**API surface (developer-facing).** Substrate packages expose typed exports. Every axis is hardwired at 1.0 — no adapter surface, no alternative implementations scaffolded:

- `packages/core/auth` — better-auth implementation; DB-backed sessions, Google OAuth + email/password, step-up middleware, `requireRecentAuth` wrapper.
- `packages/billing` — Paddle implementation with two hardwired shape presets (B2B team-seats, B2C individual-subscription); typed webhook registry with signature verification; idempotent lifecycle handling.
- `packages/jobs` — pg-boss typed job registry.
- `packages/email` — Resend wrapper + baseline templates (verify, invite, reset).
- `packages/core` — `tenantGuard()` session-variable setter keyed on `app.current_tenant_id`; tenancy-template-parameterised (team for B2B, user for B2C).
- `packages/contracts` — tRPC contract definitions.
- `packages/flags` — server-side flag evaluator (TanStack Start route-loader scope).
- `packages/audit` — append-only audit log schema + helpers.
- `packages/db` — Prisma client + RLS-aware extension.
- `packages/ui` — Tailwind-based primitives.
- `packages/keel-invariants` — shared tsconfig-base, ESLint config, Prettier, commitlint rules, prek hooks, import-boundary rules. These are **hardwired** (not generated) at 1.0 because they do not vary by shape. Consumed by every other substrate and product package.
- `packages/keel-generator` — narrow-scope idempotent generator: reads `keel.config.ts`, emits the matching RLS tenancy template (team or user) and the shape-specific Paddle billing preset into well-known paths under `packages/core/` and `packages/billing/`. Implements the pinned normalization contract (pure `expand(policy, config) → Rule[]`, canonicalised-output hashing, order-independent, deterministic merge precedence).
- `packages/keel-templates` — seed `PROMPT_*.template.md` files used at 1.0 cut for `.ralph/PROMPT_*.md` scaffolding on fresh forks.

**Code examples.** The fresh fork with default `shape: "b2b"` is the canonical example. No separate example/tutorial app ships. Pre-seeded data + baseline Paddle sandbox subscription make the default fork immediately demonstrable; a fork that sets `shape: "b2c"` is demonstrable with B2C-appropriate seed data.

**Post-1.0 migration paths.** When a second implementation on any axis enters Growth-tier (e.g., Next.js added alongside TanStack Start), it ships with its own CI-tested migration guide from the hardwired default. One axis at a time, driven by real consumption. At 1.0 there are no migration guides because there is nothing to migrate between.

**IDE integration.** None shipped. Keel assumes Claude Code / Cursor / equivalent as the primary development environment — the agentic workflow is the IDE.

### CLI-Tool Surface

**Architectural rule.** Every host-side command is invoked as `pnpm <subcommand>`. The `package.json` scripts manage devbox lifecycle and forward to container-native commands. Ralph itself is a Python Textual TUI running **inside** the devbox; users attach to it via `pnpm ralph:*` but never invoke Python directly on the host.

**Host-side commands (lifecycle + forward):**

| Command                                   | Effect                                                                                                                        |
|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `pnpm dlx create-keel-app <name>`         | Minimal bootstrap. Clones latest substrate tag, strips upstream planning artefacts, runs `pnpm install`, commits first commit. Non-interactive. No wizard. |
| `pnpm ralph:build`                        | Auto-starts devbox if needed; attaches to Ralph TUI inside container (Textual, via docker-attach). Ctrl+P Ctrl+Q detaches without killing. |
| `pnpm ralph:plan`                         | Same as above but in planning mode.                                                                                           |
| `pnpm ralph:status`                       | Queries Ralph state from `.ralph/logs/` without attaching.                                                                    |
| `pnpm ralph:stop`                         | Writes `.ralph/halt` sentinel to halt the loop cleanly.                                                                        |
| `pnpm devbox:start` / `stop` / `shell`    | Container lifecycle (manual fallback; auto-start is the default).                                                              |
| `pnpm claude`                             | Interactive Claude Code session inside devbox; first-run triggers OAuth.                                                      |
| `pnpm gh:auth`                            | One-time `gh auth login` flow inside devbox; tokens persist in container volume (`/home/dev/.config/gh/`).                     |

**Container-native commands (run after `pnpm devbox:shell`):**

| Command                                     | Effect                                                            |
|---------------------------------------------|-------------------------------------------------------------------|
| `pnpm test` / `pnpm lint` / `pnpm dev`      | Standard monorepo scripts.                                         |
| `pnpm generate`                             | Runs the narrow-scope generator (RLS tenancy template + billing preset from `keel.config.ts`). Idempotent. Invoked by pre-commit hook; direct invocation for debugging only. |
| `pnpm rls:explain <query> --tenant=<id>`    | RLS policy debugger. DB-bound; must run inside container network.  |

**Devbox scope.** Per-fork by default — each Keel fork gets its own container mounted against that fork's workspace only. `KEEL_DEVBOX_SHARED=true` in `.envrc` enables shared-devbox mode (one container, parent-directory mount) for N=1 dogfood matching the current `cc-devbox` pattern.

**Claude authentication.** Lives inside the devbox persistent volume (`/home/dev/.claude/`), not on the host. First `pnpm claude` invocation per devbox triggers OAuth; the URL is surfaced to the host; user completes OAuth in host browser; session persists in the container volume. CI and headless escape hatch: `ANTHROPIC_API_KEY` env var pass-through (Tier-2 deviation path, not the default UX).

**Output formats.**

- Ralph: Textual TUI (interactive) + `.ralph/logs/` (stream-json persisted) + `.ralph/halt` (JSON halt signal).
- Bootstrap (`create-keel-app`): plain-text status + exit code.
- Generator: plain-text "n files emitted" + content-hash footer; non-zero exit on drift.
- RLS debugger: structured table (which policies fired, which rows filtered).

**Config method.** Per-invocation flags + per-project `.ralph/` dotfiles (`PROMPT_build.md`, `PROMPT_plan.md`, `@plan.md`). No global user-level config. Per-project stance is deliberate.

**Ralph command flags (inherited from absorbed Ralph harness):** `--timeout`, `--max-iterations`, `--permission-mode`, `--max-budget-usd`, `--fallback-model`, `--effort`.

**Shell completion.** Not shipped at 1.0. Growth-tier candidate.

**Scriptable / CI mode.** The 1.0 scriptable/non-interactive surface consolidates to three affordances:

- **Non-interactive bootstrap.** `pnpm dlx create-keel-app <name>` is non-interactive end-to-end: no prompts, no wizard, reads no `stdin`. Exits with a plain-text status and exit code. Suitable for driving from CI or from an outer-loop orchestrator.
- **Headless Claude auth via env-var.** CI jobs bypass OAuth by passing `ANTHROPIC_API_KEY` into the devbox; this is the documented Tier-2 deviation path (see `### Implementation Considerations → Terminology`), not the default UX. The interactive-OAuth-in-devbox path remains the N=1 dogfood default.
- **Deferred at 1.0, queued Growth-tier.** Shell completion (`pnpm <tab>`), headless Ralph (`--no-tui`), and global user-level config are explicitly out of 1.0 scope (see `## Product Scope → Out of Scope`). They enter Growth-tier only if a scripted-agent operator — not N=1 dogfood — drives real demand.

Everything else on the CLI surface is interactive by design. The N=1 persona's workflow is interactive at 1.0; scripted-agent operation is a Growth-tier concern.

### Implementation Considerations

- **Hardwired-stack policy**: every core substrate concern (auth, DB, framework, billing, jobs, email, tenancy, deploy target) ships with exactly one implementation at 1.0, depended-upon by physical import. Agents cannot re-litigate a choice because there is nothing to choose. The narrow generator output (RLS tenancy template + Paddle shape preset) is the single surface where `keel.config.ts` drives emitted code; all other configurable values (`projectIdentity`, OTel exporter endpoint) are consumed at runtime or build time without codegen.
- **Shape mechanism**: `shape: "b2b"` (default) or `shape: "b2c"` is a literal edit to `keel.config.ts`. Typescript's type system rejects invalid values at typecheck. Pre-commit hook runs `pnpm generate`; post-generation, pre-merge-fast verifies idempotency (content-hash round-trip) and sync (regenerating produces no diff).
- **Boundary enforcement**: ESLint `no-restricted-imports` + TypeScript project references prevent cross-package imports that violate the package topology. Compile-time, not review-time. Rules are **hardwired** in `packages/keel-invariants/` (they do not vary by shape).
- **Distribution**: zero npm-publish at 1.0; GitHub release via release-please is the distribution channel. Fork-and-use model assumes forkers track upstream.
- **Terminology — Growth-tier migration vs Tier-2 deviation path**: *Growth-tier migration* applies to on-demand additions of second implementations to a hardwired axis (e.g., Next.js added alongside TanStack Start in a future minor); each such addition ships with its own CI-tested migration path. *Tier-2 deviation path* applies to exits outside the substrate's supported posture (e.g., ASVS Level 2+ compliance, stateless-JWT sessions, signed cryptographic attestation, horizontal scaling by worker-process extraction, raw `ANTHROPIC_API_KEY` pass-through). Deviation paths are documented but not substrate-surfaced; forks choosing them accept divergence responsibility.
- **`keel.config.ts` schema**: typed, minimal. Fields: `shape` (literal union), `tenancy` (derived-default-from-shape, user-overridable to the other valid value), `projectIdentity` (name, slug, optional domain placeholder), `otelExporter` (endpoint URL, default `localhost`). No `schemaVersion` field at 1.0 (deferred until there is a reason to version).

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach: Platform MVP with research-project companion.** Keel is not a problem-solving MVP (the problem is well-understood from N=1 experience), not an experience MVP (no end-users interact with the substrate directly), and not a revenue MVP (one paying customer is a functional test, not a growth milestone). It is simultaneously a **research project** measuring agentic-development substrate-equivalence under model drift. Validated learning along two axes: **as substrate**, 2-4 real products shipped on Keel within 12 months of 1.0 (failure → archive); **as research**, monthly blank-starter-sprint logs accumulating regardless of substrate fate.

**Resource Requirements.** N=1 (Tthew) + agentic workforce (Ralph + Claude Code). Required skills: TypeScript, Postgres/SQL, system design, prompt craft. Time budget: **28 focused days** (see Product Scope M0-M9 with M0.5 devbox and M0.7 narrow-scope tenancy-template generator); realistic first-slip budget 30-34 days. This restores the original pre-wizard-pivot posture — the 22-day wizard/adapter-surface expansion has been fully removed (see editHistory wizard-reversal entry). Compression absorbed by M7-M9 (frontend patterns polish + decomposed-CI pyramid hardening).

### MVP Feature Set (Phase 1 — Keel 1.0)

Milestones M0-M9 (including M0.5 devbox and M0.7 tenancy-template generator) are fully enumerated in Product Scope. This section maps user journeys to MVP-critical milestones:

| Journey                         | MVP-critical?                  | Milestones required                     |
|---------------------------------|--------------------------------|-----------------------------------------|
| J1 Product #2 happy path        | Yes — validates T2NP           | M0-M4, M0.7, M9                         |
| J2 M4 checkpoint ritual         | Yes — governance invariant     | (spans M0-M4; checkpoint artefact only) |
| J3 Agent iteration              | Yes — validates TTGNA          | M0-M4, M0.5, M0.7, M9 + harness         |

**Must-have capabilities for 1.0:**

- Fresh-fork clone produces green pre-merge-fast + pre-merge-slow (M0, M9), exercised on both shapes (B2B team + B2C user).
- Devbox container as non-toggle-able execution environment (M0.5).
- Minimal bootstrap `pnpm dlx create-keel-app` — clone + strip + install; non-interactive; no wizard (M0, M9).
- Narrow-scope tenancy-template generator: `keel.config.ts` typed schema (shape, tenancy, projectIdentity, OTel endpoint) + idempotent generator emitting RLS template + Paddle preset + pre-merge sync gate (M0.7). Non-negotiable core requirement.
- Day-1 RLS invariant enforced at database layer, parameterised over two tenancy templates (team for B2B, user for B2C) (M0.7, M1).
- Hardwired auth / billing / jobs / email / framework / DB (better-auth, Paddle, pg-boss, Resend, TanStack Start, Prisma) (M2-M4, M7).
- Non-toggle-able four-layer quality gates with Ralph acceptance-driven backpressure (M9), applied identically to agent-authored and human-authored commits. Decomposed CI pyramid per Technical Success.
- In-repo checkpoint document structure at `docs/checkpoints/` (seeded by M0).
- Internationalization framework wired into TanStack Start with English baseline locale and typed-key enforcement (M7). Non-negotiable core requirement.
- Per-iteration security verification with structured evidence: secret scan, dependency audit, SAST, prompt-injection scan; findings block commit; evidence persisted to `.ralph/logs/<iteration-id>/security-evidence.json` (M0 + M9). Non-negotiable core requirement.
- Invariants stack at M0 + M0.7: machine-enforced package (`packages/keel-invariants/` — hardwired rules + the generated `invariants.manifest.ts`) + agent-readable `INVARIANTS.md` + documentation layer + sync pre-merge gate covering manifest drift and the narrow config → generator-output drift.
- `gh` CLI authentication inside devbox volume with first-run prerequisite check that halts Ralph cleanly if auth is missing (M0.5). Prerequisite for autonomous push and PR creation.
- Generator normalization contract pinned: pure `expand(policy, config) → Rule[]`, canonicalised-output hashing, order-independent, deterministic merge precedence (M0.7). Non-negotiable core requirement.
- Monthly blank-starter-sprint harness + log format (does not have to be automated at 1.0; manual-run tooling with a JSON log schema is sufficient). Load-bearing for the absorption tripwire.

### Post-MVP Features

**Phase 2 (Growth, months 1-6 post-1.0):**

- Marketplace shape (1.1) — `shape: "marketplace"`, Stripe Connect hardwired preset, multi-role identity, payouts, disputes. Ships when a marketplace product is actually queued.
- API-first shape (1.2) — `shape: "api_first"`, Stripe standard hardwired preset, developer portal, OpenAPI, public-API surface, quota-based pricing. Ships when an API-first product is actually queued.
- Org tenancy template — `tenancy: "org"` added as third RLS template for forks that need nested-scope tenancy.
- Second-implementation adapters on demand — if a real product forces a second auth/ORM/framework/email/jobs implementation, it enters with its own CI-tested migration path. One axis at a time.
- Shell completion for the pnpm-exposed command set.
- Headless Ralph mode (`--no-tui` or equivalent) for CI scenarios.
- Independent package versioning via release-please-monorepo if a package is extracted as a standalone library.
- SSO adapter (SAML / OIDC beyond Google OAuth) for regulated forks.

**Phase 3 (Expansion — dogfood-first):**

- Meta-framework formalisation across BMad + Ralph + Keel + Claude Code.
- Product-count milestone: 2-4 products shipped on Keel within 12 months of 1.0.
- Adoption signaling (blog post, peer-community share) — permitted but not planned.
- **Contingent: Invariant Pack pivot** — if the monthly absorption tripwire fires (two consecutive months of blank-starter parity within 20%), pivot Phase 3 to publishing the Invariant Pack as a versioned npm package within 30 days. This is the pre-committed exit; it is *not* a failure mode, it is the capture of what was actually load-bearing once substrate-delta evaporates.

### Risk Mitigation Strategy

**Technical Risks:**

- *Day-1 RLS policy parameterised over two tenancy templates* — pre-M1 spike budgeted at ≤ 1.5 days per template (team, user = up to 3d). If either does not converge, that template downgrades to Growth-tier (which for B2C with `user` tenancy means shipping B2C only at Phase 2). Accepted tradeoff.
- *Generator idempotency + drift-detection complexity* — the generator is required to be deterministic and content-hashed so the sync gate can detect drift. Mitigation: treat `packages/keel-generator` as a load-bearing substrate package with its own test suite; pinned normalization contract (pure `expand(policy, config) → Rule[]`, canonicalised-output hashing, order-independent, deterministic merge precedence) closes the transitive-rule-expansion hole.
- *Decomposed-CI pyramid engineering* — known first-slip candidate (4 planned days for M9 → 5-6 real). Mitigation: the pyramid is designed so pre-merge-fast can land first (≤3min deterministic gate) and pre-merge-slow / nightly / release-gated layers can follow incrementally without blocking the merge of earlier layers.
- *Devbox cold-start and image size (~3.5 GB per cc-devbox baseline)* — affects Ralph iteration startup time on first invocation. Mitigation: persistent container across Ralph invocations; rebuild only on Dockerfile diffs; document pre-warming as an operational tip.
- *Bootstrap handoff at M0.5* — the cc-devbox → `packages/devbox/` migration lands mid-build. If the absorbed devbox fails, Keel's own build stalls. Mitigation: keep standalone `cc-devbox` functional on a `legacy-devbox` branch until after the M4 checkpoint.
- *Security-verification overhead in the Ralph loop* — running SAST + secret scan + dependency audit + prompt-injection scan per iteration adds ~30-60s per iteration at typical scanner speeds and may compound to 7-13% iteration tax. Mitigation: cache-unchanged-file scan results is **load-bearing at M0** (not deferred); configurable severity threshold tuning per scanner category (architecture doc); recurring false-positive categories force an upstream scanner-config fix rather than an escape hatch.
- *Correlated-library risk on hardwired defaults* — TanStack Start and better-auth are young relative to incumbents. Mitigation: quarterly maintenance-signal check per Domain-Specific § Correlated-Library Risk Policy; demotion-via-migration in next major if thresholds hit.

**Market Risks:**

- *Substrate-as-category may not stick* — fallback positioning is "opinionated agent-authored SaaS boilerplate with source-layer invariant enforcement." No refactor required; existing artefacts remain valid. The Invariant Pack pivot target is the contingent destination if the absorption tripwire fires.
- *Adoption path beyond N=1 is undefined* — accepted per scratch-your-own-itch thesis. Distribution is explicitly out of scope and belongs to a separate follow-on project.

**Resource Risks:**

- *28 → 30-34 day slip* — governed by M4 checkpoint ritual (mid-build decision: push M5-M9 or pause and ship real product on partial substrate).
- *Sustained > 15 hrs/month maintenance post-1.0* — triggers scope-cut or archive. Expected steady-state 5-10 hrs/month.
- *Procrastination via perfecting-substrate-instead-of-shipping-product* — governed by the monthly absorption tripwire (faster feedback than the 12-month kill criterion) AND the M4 checkpoint ritual.
- *Docker Desktop prerequisite gates fresh forkers without Docker installed* — devbox is Tier-1 invariant, not optional. Mitigation: fresh-fork first-run check fails with a clear pointer to install instructions; no graceful degradation to non-containerised Ralph.
- *Scope re-inflation under future "peer-user" temptation* — the wizard-reversal happened because N>1 framing smuggled in during planning. Mitigation: `personaModel: n-equals-one` is a classification-level invariant; any PR or story that justifies itself with "a second user would want X" must be rejected or escalated to an explicit persona-scope change in the frontmatter.

## The Line: Keel Development vs Development with Keel

Keel is self-hosting — the meta-framework used to build Keel is the framework Keel ships. Post-1.0, the practical question for any Keel repo is not "which framework are we using" (it's always BMad + Ralph + Keel + Claude Code, with shape selected in `keel.config.ts`) but "what mode of work is this change"?

### Three modes

1. **Development with Keel** — product code only. `apps/web/features/*`, product-specific schemas, product tests. Upstream rebase is by-design safe; package boundaries (enforced at compile time) prevent drift.
2. **Keel development via fork** — substrate code on your own fork. `packages/*`, substrate CI, Growth-tier migration paths. You own divergence. Upstream rebase may conflict.
3. **Keel development proper** — substrate changes intended to flow upstream. PR to the upstream Keel repo.

### Where the line lives

| Dimension    | The line                                                          |
|--------------|-------------------------------------------------------------------|
| Physical     | Substrate: `packages/*` (including `packages/keel-invariants/`, `packages/keel-generator/`, `packages/keel-templates/`, `packages/devbox/`), `keel.config.ts` (schema), substrate CI workflows. Product: `apps/web/features/*`, product schemas, product tests. No ambiguous middle. |
| Temporal     | The 1.0 cut ritual. Before cut: only Keel-development exists. At cut: archival + template seeding draws the line. After cut: every fresh fork starts in "development with Keel" by default. |
| Enforceable  | Compile-time (ESLint `no-restricted-imports` + TypeScript project references); CI path-based gate routing; convention. |

### State categories

| Category             | Location                        | Scope        | Behaviour on fork                                       |
|----------------------|---------------------------------|--------------|---------------------------------------------------------|
| Substrate source     | `packages/*`                    | Shared       | Inherited unchanged; upstream rebases cleanly.          |
| Fork config          | `keel.config.ts` (root)         | Per-fork     | Small typed config (shape, tenancy, projectIdentity, OTel endpoint); preserved on rebase. |
| Generated per-fork artefacts | `packages/core/rls/*.generated.ts`, `packages/billing/paddle/preset.generated.ts`, `packages/keel-invariants/invariants.manifest.ts` | Per-fork | Regenerated from `keel.config.ts` at build time; idempotent; rebase conflicts resolved by re-running `pnpm generate`. |
| Product source       | `apps/web/features/*`           | Per-project  | Substrate never modifies this directory.                |
| Planning artifacts   | `_bmad-output/`                 | Per-project  | Archived to `docs/archive/` at every major-version cut. |
| Ralph runtime state  | `.ralph/`                       | Per-project  | Prompts seeded from templates; logs gitignored.         |
| Devbox runtime       | container volume                | Per-fork     | `KEEL_DEVBOX_SHARED=true` override for N=1 dogfood.     |

### The 1.0 cut ritual

1. Move `_bmad-output/*` to `docs/archive/keel-1.0-planning/`.
2. Retire `cc-devbox`; the absorbed `packages/devbox/` is canonical.
3. Empty `apps/web/features/*` (Launchpad seed only).
4. Seed `packages/keel-templates/PROMPT_*.template.md` from current `.ralph/PROMPT_*.md`.
5. Tag `v1.0.0` on the substrate.

### Bootstrap sequence (Keel's own build, pre-1.0)

- **M0 → M0.5**: standalone `cc-devbox` + standalone `ralph.py`.
- **M0.5 landing**: `packages/devbox/` takes over; standalone `cc-devbox` becomes deprecated-but-still-functional on a `legacy-devbox` branch until after the M4 checkpoint. `ralph.py` is absorbed into `packages/devbox/` as the in-devbox orchestration runtime.
- **M1 → 1.0 cut**: Keel dogfoods the absorbed versions.
- **1.0 cut**: above ritual; cc-devbox retired.

### Ralph-fork disposition

Keel absorbs Ralph at a specific commit. Monthly upstream diff review (per `ralphDisposition: fork` frontmatter) evaluates whether upstream changes are worth pulling. Maintainer-only concern; invisible to forkers in "development with Keel" mode.

## Security-by-Default Requirements

Security is a non-negotiable core requirement — equivalent in status to i18n, quality gates, and RLS. Every Ralph iteration must implement and verify security with structured evidence. The sandbox from Execution Environment is the starting point, not the full story.

### Sandbox is the security boundary

Agent execution under `--dangerously-skip-permissions` has no recoverable operating mode — once the permission system is bypassed, the only thing between an agent-authored action and the host is the sandbox boundary. The substrate's contract, accordingly, is blast-radius minimization: scoped credentials (tokens live in the devbox volume, never the host), scoped network (default-deny DNS whitelist), scoped filesystem (tmpfs noexec/nosuid for ephemeral paths; read-only mounts where possible), scoped kernel capabilities (NET_ADMIN/NET_RAW only). This mirrors the upstream Ralph-wiggum canonical guidance (*"Use protection — the sandbox is your only security boundary; not if popped, but when"* — `github.com/ghuntley/how-to-ralph-wiggum`) but pins Keel's specific substrate controls rather than leaving the boundary to fork-operator judgement.

### Baseline reference

Keel adopts **OWASP Top 10:2025**, **ASVS Level 1**, and **OWASP Top 10 for Agentic Applications (2026)** as the substrate security baseline (see `github.com/agamm/claude-code-owasp`). ASVS Level 2+ is a Tier-2 deviation path for forks with regulated-compliance needs.

### Substrate-level controls (inherited by every fork)

- **Sandbox isolation** — devbox DNS whitelist, non-root user, tmpfs noexec, NET_ADMIN/NET_RAW-only capabilities (see Execution Environment).
- **Tenant isolation at database layer** — RLS on every tenant-scoped table, parameterised over the shape's tenancy template (team for B2B, user for B2C).
- **Non-toggle-able quality gates** — apply equally to agent-authored and human-authored commits across the hardwired stack.
- **Secrets never committed** — pre-commit gate rejects known secret patterns.
- **Dependency audit** — Dependabot or equivalent blocks merges with critical vulnerabilities.
- **Audit log append-only** — security-relevant events persisted immutably.
- **Config-layer type enforcement** — `keel.config.ts` field types (literal unions for `shape` and `tenancy`) rule out invalid combinations at typecheck, not at runtime. Combinations that would violate substrate security baselines (e.g., API-first shape without usage-quota billing) are simply not reachable in the 1.0 schema; when those shapes enter in 1.1/1.2 they ship with hardwired billing presets that satisfy the baseline by construction.

### Ralph-loop per-iteration security verification

Every Ralph iteration runs a security-verification stage as a first-class backpressure trigger, equivalent priority to test verification. The stage produces evidence; the commit is blocked until evidence is present and green:

1. **Secret scan** on the iteration diff (`detect-secrets` / `truffleHog` / equivalent). Any hit blocks commit.
2. **Dependency audit** on manifest changes (`pnpm audit --prod`, `pip-audit` for Python). High-severity vulnerabilities block commit.
3. **SAST-style checks** on diff paths: SQL injection, XSS, SSRF, path traversal, command injection (ESLint security plugins, Semgrep, or equivalent).
4. **Auth / authorization code coverage** — new auth-related code must include passing tests.
5. **Crypto correctness** — if crypto primitives are introduced, verify stdlib usage (no custom crypto), TLS 1.3+, Argon2/bcrypt for passwords, ≥128-bit session entropy.
6. **Error-handling audit** — responses must not leak stack traces, internal paths, or version info.
7. **Prompt-injection scan** on committed files reachable by agent context loaders (`CLAUDE.md`, skill files, `.ralph/PROMPT_*.md`, `docs/**/*.md`, test fixtures). Heuristic pattern matching for injection attempts.
8. **Supply-chain lock** — lockfile is committed and unchanged unless the iteration intentionally upgrades dependencies (called out in the commit message).

### Verification with proof

"Proof" in Keel means **structured evidence**, not cryptographic attestation. Evidence consists of:

- Scanner outputs (JSON-formatted results from each scan).
- Test results for security-relevant code paths.
- A commit message descriptor identifying the security controls added and pointing at the evidence file.

Evidence is persisted to `.ralph/logs/<iteration-id>/security-evidence.json` for every iteration. Signed cryptographic attestation is a Tier-2 deviation path for forks with compliance needs.

### Backpressure behaviour

Security-verification failures are equivalent-priority to test failures:

- **Single security failure**: iteration retries with scanner output fed back into Claude's context (attempt self-remediation).
- **Three consecutive iterations with the same security failure**: Ralph halts via `.ralph/halt`; next human check surfaces the security halt signal.
- **Critical-severity finding** (hardcoded production secret, CVSS ≥ 9 vulnerability, known RCE pattern): immediate halt, no retry.

## Invariants

Keel ships a versioned invariants stack with three synchronised layers. Each layer serves a different consumer (machines, agents, humans) but tells the same story — invariants in Keel are the physical expression of the thesis *"invariants beat conventions beat docs."*

### The three layers

| Layer             | Artifact                                                                                                                | Consumer                              | Purpose                                                      |
|-------------------|-------------------------------------------------------------------------------------------------------------------------|---------------------------------------|--------------------------------------------------------------|
| Machine-enforced  | `packages/keel-invariants/` — tsconfig-base, ESLint config, Prettier, commitlint, prek hooks, import-boundary rules     | Build tools, CI                       | Invariants enforced at compile/commit/merge time             |
| Agent-readable    | `INVARIANTS.md` at repo root, referenced by `CLAUDE.md`                                                                 | Ralph, Claude Code, future agents     | Context-loaded reference so agents don't re-litigate         |
| Documentation     | `docs/invariants/*.md` (commit-format, security, coding, repo-structure, backend, client)                                | Humans onboarding                     | Narrative explanation + rationale                             |

### Sync enforcement

A pre-merge quality gate verifies the three layers don't drift. If `packages/keel-invariants/` changes without a corresponding `INVARIANTS.md` change, the build fails. The same gate additionally covers the narrow `keel.config.ts` → generated-artefact path: config edits without matching regenerated RLS tenancy template or Paddle billing preset also fail the build.

**Mechanism — pinned at PRD level, not deferred:**

- **Manifest contract.** `packages/keel-invariants/` exports an `invariants.manifest.ts` enumerating every rule as a typed record with a stable ID, a human-readable title, the enforcement layer (lint / typecheck / commit-hook / pre-merge / pre-deploy), and a content hash over the rule's canonicalised machine-readable definition.
- **Generator normalization contract** (transitive-rule-expansion handling, previously deferred): the generator is a pure function `expand(policy, config) → Rule[]`. Every emitted `Rule` carries a `derivedFrom: <policy-id>` field. Content hashing is computed over the **canonicalised output array** (sorted by stable rule-ID, whitespace-normalised, comment-stripped) — not the source policy, not the pretty-printed file. Two policies expanding to the same low-level rule merge via **deterministic precedence** (alphabetical by policy-id, ties broken by insertion order in the manifest). Generator output is **order-independent** — `expand(A then B) === expand(B then A)` for the output set. This closes the drift hole that a naive hash would leave open the moment a second policy lands.
- **Documentation anchors.** `INVARIANTS.md` addresses each invariant by the same stable ID using an anchored heading (e.g., `### <invariant-id> — <title>`). The `docs/invariants/*.md` per-invariant narrative files reference the same IDs.
- **Sync check.** A pre-merge script reads the manifest, walks the three layers, and fails the build on any of: (a) an ID in the manifest that is missing an anchor in `INVARIANTS.md`; (b) an anchor in `INVARIANTS.md` with no corresponding manifest entry (orphaned documentation); (c) a manifest entry whose content hash has changed without a matching `INVARIANTS.md` edit in the same PR. Addition drift fails (a); removal drift fails (b); edit drift fails (c). No other drift mode exists between layers.
- **Fork-config drift.** `keel.config.ts` edits that change `shape` or `tenancy` without regenerating `packages/core/rls/*.generated.ts` and `packages/billing/paddle/preset.generated.ts` fail the pre-merge gate. Running `pnpm generate` against an already-synchronised repo produces no diff (idempotency verified by a pre-merge-fast test that regenerates and diffs). There is no schemaVersion check at 1.0 — `keel.config.ts` is too small to need one; a schemaVersion field enters only when it earns its keep.

### Coverage

| Invariant                                 | Machine-enforced in                                                                                           | Agent-readable in                                      | Documented in                       |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------------|--------------------------------------------------------|-------------------------------------|
| Commit message format                     | commitlint via prek                                                                                           | INVARIANTS.md §commit                                  | docs/invariants/commit.md           |
| Security standards                        | per-iteration verification; OWASP ASVS L1 baseline                                                            | INVARIANTS.md §security                                | docs/invariants/security.md         |
| Coding standards (TS, lint, format)       | tsconfig-base + ESLint + Prettier (all hardwired in `packages/keel-invariants/`)                              | INVARIANTS.md §coding                                  | docs/invariants/coding.md           |
| Repo structure / package boundaries       | ESLint `no-restricted-imports` + TS project refs (hardwired)                                                  | INVARIANTS.md §structure + CLAUDE.md package map       | docs/invariants/repo.md             |
| Backend technology constraints            | Substrate packages physically depend on Prisma, better-auth, pg-boss, Paddle, Resend, OTel                    | INVARIANTS.md §backend                                 | docs/invariants/backend.md          |
| Client technology constraints             | `apps/web` built on TanStack Start; UI uses Tailwind, tRPC, RHF, Zod, Zustand                                  | INVARIANTS.md §client                                  | docs/invariants/client.md           |
| Ralph prompt conventions (model-pinned)   | `.ralph/PROMPT_*.md` template contract: adaptive thinking + explicit `effort`; `thinking.display = "summarized"`; no sampling knobs; no prefills; positive examples; explicit subagent-triggering phrasing; fan-out cap invariant (1 Sonnet per build/test) | INVARIANTS.md §prompts                                 | docs/invariants/prompts.md          |
| Shape-driven generated artefacts          | `keel.config.ts` → `pnpm generate` → `packages/core/rls/*.generated.ts` + `packages/billing/paddle/preset.generated.ts` + `invariants.manifest.ts`; pre-merge sync gate catches drift | INVARIANTS.md §shape (references `keel.config.ts`)     | docs/invariants/shape.md            |

### Extension / override model for forks

- **Default**: forks inherit the substrate unchanged; the fork's `keel.config.ts` (shape / tenancy / projectIdentity / OTel endpoint) is the only per-fork divergence point. Upstream changes to substrate packages or hardwired rules flow on rebase.
- **Extend**: forks author their own extension configs (e.g., `eslint.config.fork.js extends eslint.config.keel-invariants.js`). Substrate never touches these files; rebase is clean. Forks that need config values the substrate doesn't expose in `keel.config.ts` extend `keel.config.fork.ts` (referenced from the main config) with fork-specific values.
- **Override**: forks that need to remove an invariant entirely fork `packages/keel-invariants/` — explicit substrate divergence, documented in the fork's README.
- **Agent-facing**: forks add product-specific invariants to a fork-owned `INVARIANTS.fork.md`; `CLAUDE.md` references both files alongside the upstream `INVARIANTS.md`.

### Principle

The thesis *"invariants beat conventions beat docs"* applies to the invariants themselves: the machine-enforced layer is the invariant; agent-readable and documentation layers are explanations. Sync-gate enforcement prevents the layers from drifting — drift would recreate the exact "docs lie about reality" problem Keel is designed to eliminate.

## Functional Requirements

### Execution Environment Management

- **FR1**: Developer can manage devbox lifecycle (start, stop, shell, attach) via pnpm-exposed commands.
- **FR2**: Developer can invoke Ralph (`pnpm ralph:build` / `pnpm ralph:plan`) with the devbox auto-starting if not already running.
- **FR3**: Developer can authenticate Claude Code and `gh` CLI once per devbox via browser OAuth flows surfaced to the host terminal; tokens for both persist in the devbox volume.
- **FR4**: Developer can select between per-fork devbox (default) and shared devbox mode via `.envrc` configuration.
- **FR5**: System can enforce prerequisites (Docker runtime, Claude Code authentication, `gh` CLI authentication) on fresh-fork first-run and on every Ralph invocation, failing with install-pointer or auth-pointer errors for missing items. Ralph cannot execute autonomously until all prerequisites are satisfied.
- **FR6**: Developer can run substrate-internal tooling (tests, lints, RLS debugger) inside the devbox.

### Autonomous Agent Loop

- **FR7**: Agent can execute a multi-iteration loop against a committed plan (`.ralph/@plan.md`) inside the devbox, invoking `claude -p` with adaptive thinking and an explicit `effort` setting (default `xhigh` for build iterations, `high` for plan iterations) per Opus 4.7 conventions.
- **FR8**: System can halt the Ralph loop on a configurable threshold of consecutive test failures or security-verification failures (see Security Verification & Evidence).
- **FR9**: System can halt the Ralph loop on task-budget exhaustion per iteration, using the model-visible `task_budget` advisory counter (beta header `task-budgets-2026-03-13`, ≥ 20K) where available and `max_tokens` as the hard invisible ceiling.
- **FR9a**: System can branch halt handling between `max_tokens` and `model_context_window_exceeded` stop reasons, persisting which applied to each iteration for budget-re-baseline analysis.
- **FR10**: Developer can detach from a running Ralph loop (loop continues executing) and later re-attach to observe state.
- **FR11**: Developer can query Ralph state without attaching via `pnpm ralph:status`.
- **FR12**: Developer can halt the Ralph loop cleanly via `pnpm ralph:stop`.
- **FR13**: System can persist Ralph iteration logs in `stream-json` format for replay and debugging, with `thinking.display = "summarized"` enabled so reasoning traces are preserved across the omitted-by-default Opus 4.7 behaviour.
- **FR14**: System can require conventional-commit format for all commit messages, regardless of authorship.
- **FR14a (Acceptance-Driven Backpressure)**: System can require the Ralph plan file to enumerate a `Required tests:` list per task (derived from story / spec acceptance criteria by the `bmad-create-story` and `bmad-agent-dev` skills). A build iteration cannot mark a task done until every listed test passes; the list covers functional, integration, RLS-policy, and security-verification tests uniformly (FR35–FR40).
- **FR14b (Plan-staleness trigger)**: System can detect plan staleness (plan artefact older than a configured threshold relative to repo activity, or the same task advanced across N consecutive iterations without progress) and automatically schedule a plan-mode regeneration rather than silently looping. Default thresholds: 5 no-progress iterations, or 72 hours of plan-artefact age against an active repo.
- **FR14c (Subagent fan-out budget)**: System can configure a substrate-default subagent fan-out cap (Sonnet-class read/search subagents) with a documented default of 250 parallel and a ceiling of 500. The build/test backpressure rule — **at most one Sonnet subagent for any build, test, or lint command per iteration** — is a non-toggle-able invariant enforced by the Ralph prompt contract, not a tunable.
- **FR14d (Per-iteration context meter)**: Agent can emit structured context-utilisation metrics per iteration (advertised-vs-usable context window, specs load, orient load, execute load, output load, percentage utilisation) to `.ralph/logs/<iteration-id>/context-meter.json`. Triggers: exit cleanly above 80% utilisation; flag above 60% so loop-level observability can spot drift.
- **FR14e (Non-Deterministic Backpressure scaffold)**: Developer can opt a task into LLM-as-judge acceptance via a fixture (pattern-named `lib/llm-review.ts`) that runs a scoped Opus-class subagent against the diff with the task's subjective acceptance criteria and returns pass/fail. Failure counts as a test failure under FR8 backpressure. Growth-tier default; 1.0 ships the pattern contract so fork-authored fixtures are interoperable.

### Tenant Isolation

- **FR15**: System can enforce tenant data isolation at the database layer via Row Level Security policies on all tenant-scoped tables, parameterised over the shape's tenancy template (team for B2B, user for B2C). Templates are emitted by the generator from `keel.config.ts`; a third `org` template is Growth-tier.
- **FR16**: Developer can set the current tenant context via `tenantGuard()` session-variable setter (keyed on `app.current_tenant_id`) inside request transactions; the setter's tenant-resolution logic is emitted from the shape's tenancy template.
- **FR17**: Developer can debug RLS policy decisions for a given query and tenant context via `pnpm rls:explain`.
- **FR18**: System can enforce that new tenant-scoped tables ship with an RLS policy matching the fork's tenancy template, via CI check.

### Platform Services

- **FR19**: Developer can register typed background jobs via pg-boss, running in the same Postgres database as the app.
- **FR20**: Developer can send transactional emails via Resend using baseline templates.
- **FR21**: Developer can define and evaluate server-side feature flags in TanStack Start route loaders.
- **FR22**: System can emit OpenTelemetry traces for all request paths.
- **FR23**: System can record append-only audit log entries for security-relevant events.

### Internationalization & Localization

- **FR24**: Developer can author user-facing content using i18n keys resolved to typed translations, not bare strings.
- **FR25**: System can detect locale from the `Accept-Language` header with explicit user-preference override.
- **FR26**: Developer can ship baseline locales (English at minimum) with a documented path for adding additional locales.
- **FR27**: System can enforce i18n-key usage via lint or CI check that prevents bare user-facing strings from shipping.

### Quality & Governance

- **FR28**: System can run pre-commit quality gates (type-check, lint, format, conventional-commit format) via prek.
- **FR29**: System can run pre-merge quality gates (unit + integration tests, RLS policy tests, import boundaries, dependency audit).
- **FR30**: System can run the release-gated CI tier (manual trigger): `git clone` → shape-edit → signup → tenant formation → paid Paddle sandbox subscription → teardown. Exercised on both shapes (B2B team + B2C user) before a release tag. See Technical Success § Decomposed CI pyramid for the full tier structure; the pre-deploy monolith from the pre-wizard-reversal version is replaced by this release-gated tier sitting above nightly.
- **FR31**: System can maintain a rolling release-please Release PR with conventional-commit-based versioning.
- **FR32**: System can prevent quality-gate bypass via configuration; removal requires a source-level fork.
- **FR33**: Developer can record M4 checkpoint decisions as committed markdown artefacts in the repo.
- **FR34**: System can enforce import boundaries at compile time via ESLint `no-restricted-imports` + TypeScript project references.

### Security Verification & Evidence

- **FR35**: System can run per-iteration security verification (secret scan, dependency audit, SAST, prompt-injection scan) on every Ralph iteration diff before commit.
- **FR36**: System can block a Ralph iteration commit when any security scan reports a finding above the configured severity threshold.
- **FR37**: Agent can persist security evidence (scanner outputs, test results, timestamps) to `.ralph/logs/<iteration-id>/security-evidence.json` for every iteration.
- **FR38**: System can halt the Ralph loop on consecutive security-scan failures equivalent to the test-failure backpressure policy.
- **FR39**: System can enforce OWASP ASVS Level 1 as the substrate security baseline; ASVS Level 2+ is a documented Tier-2 deviation path.
- **FR40**: System can scan committed agent-context-loader files (`CLAUDE.md`, skill files, `.ralph/PROMPT_*.md`, `docs/**/*.md`) for prompt-injection patterns as part of pre-commit quality gates.

### Invariants

- **FR41**: System can ship a versioned invariants package (`packages/keel-invariants/`) consumed by lint, format, type-check, commit, and merge gates across all substrate and product code.
- **FR42**: System can expose invariants to agents via `INVARIANTS.md` at repo root, referenced by `CLAUDE.md`, providing an agent-readable index of machine-enforced rules.
- **FR43**: System can enforce sync between the machine-enforced layer (`packages/keel-invariants/`) and the agent-readable layer (`INVARIANTS.md`) via a pre-merge gate that reads an exported `invariants.manifest.ts` (stable-ID + content-hash per rule) and fails the build on addition drift (manifest ID missing an `INVARIANTS.md` anchor), removal drift (orphaned `INVARIANTS.md` anchor), or edit drift (manifest hash change without matching `INVARIANTS.md` edit in the same PR).
- **FR44**: Developer can extend invariants via extension configs that build on `packages/keel-invariants/` (e.g., `eslint.config.fork.js extends eslint.config.keel-invariants.js`) without modifying substrate files.
- **FR45**: Developer can (Growth tier) scaffold a fork-specific `INVARIANTS.fork.md` that is referenced alongside the upstream `INVARIANTS.md` by `CLAUDE.md`.

### Forkability & Upgradability

- **FR46**: Developer can fork Keel, rename, and configure project-specific values via a one-line edit to `keel.config.ts` (shape, tenancy, projectIdentity, OTel endpoint) without modifying substrate package internals.
- **FR47**: Developer can bootstrap a fresh Keel-forked project via `pnpm dlx create-keel-app <project-name>` — non-interactive: clones the latest substrate tag, strips upstream planning artefacts, runs `pnpm install`, commits the first commit. No wizard. No prompts.
- **FR48**: Developer can change a fork's shape (`b2b` ↔ `b2c`) via a literal edit to `keel.config.ts` followed by `pnpm generate` (invoked by the pre-commit hook). Type-checking rejects invalid shape values; the generator emits the matching RLS tenancy template and Paddle billing preset; the sync-enforcement pre-merge gate catches drift between the edit and the emitted artefacts.
- **FR49**: *(Growth-tier)* When a second implementation enters an axis via Growth-tier (e.g., Next.js alongside TanStack Start), that axis ships a CI-tested migration guide from the hardwired default. At 1.0 there are no migration guides because there is nothing to migrate between.
- **FR50**: Maintainer can cut a Keel major version with the tested model/tooling generation combination documented in the release notes (see NFR30). A breaking upstream model upgrade triggers a new major version test-run; `keel.config.ts` schema changes are evaluated separately per the post-1.0 schema-evolution policy.
- **FR51**: System can wipe residual `_bmad-output/` and `.ralph/` state on fork-scaffolding (1.0 scope), seeding empty per-project state from templates in `packages/keel-templates/`.
- **FR52**: Maintainer can archive per-version planning artifacts to `docs/archive/keel-<version>-planning/` before each major-version tag cut, leaving the shipping substrate with empty per-project state directories.
- **FR53**: System can distinguish substrate-territory commits from product-territory commits via path-based CI rules, triggering different gate profiles for each (full decomposed-CI pyramid including nightly shape × tenancy matrix on substrate paths; pre-merge-fast + pre-merge-slow tests only on `apps/web/features/*` paths).

### Configuration & Generator

- **FR65**: Developer can declare per-fork configuration via a typed `keel.config.ts` module at the repo root carrying four fields: `shape` (literal union `"b2b" | "b2c"`), `tenancy` (literal union `"team" | "user"` — defaults derived from shape but user-overridable to the other valid value), `projectIdentity` (name, slug, optional domain placeholder), `otelExporter` (endpoint URL, default `"localhost"`). Invalid field values fail at typecheck. No `schemaVersion` field at 1.0 (added only when a breaking schema change earns it).
- **FR66**: Developer can regenerate per-fork artefacts via `pnpm generate`, which reads `keel.config.ts` and emits the shape's RLS tenancy template to `packages/core/rls/*.generated.ts`, the shape's Paddle billing preset to `packages/billing/paddle/preset.generated.ts`, and the `invariants.manifest.ts` content-hash manifest entries that cover these generated artefacts. Idempotent — re-running against an already-synchronised repo produces no diff (verified by pre-merge-fast test).
- **FR67**: System can normalize generator output via a pinned contract — pure `expand(policy, config) → Rule[]`, canonicalised-output hashing (sorted by stable rule-ID, whitespace-normalised, comment-stripped), order-independent, deterministic merge precedence (alphabetical by policy-id, ties broken by insertion order in the manifest).
- **FR68**: System can enforce sync between `keel.config.ts` and generated artefacts at the pre-merge-fast gate. Any edit to `shape` or `tenancy` without a matching regeneration fails the build; any edit to generated files without a matching `keel.config.ts` source-of-truth change also fails the build.

## Baseline Product Capabilities Inherited by Forks

These capabilities are pre-wired in every Keel-forked project using hardwired substrate implementations. Forks can extend or customise but do not need to implement them. The libraries named below are **the hardwired stack at 1.0**; alternatives are Growth-tier and enter on-demand with their own migration paths.

### Identity & Access

- **FR54**: End user can sign up via email+password or Google OAuth (better-auth implementation).
- **FR55**: End user can verify their email address via a Resend-delivered link.
- **FR56**: End user can create, join, leave, and be invited to teams (B2B shape) — or manage their individual account profile (B2C shape).
- **FR57**: End user can maintain DB-backed sessions with revocation support.
- **FR58**: System can require recent auth (step-up) for sensitive actions.
- **FR59**: End user can log out of all active sessions.

### Commerce

- **FR60**: End user can subscribe to a paid plan via Paddle. B2B shape uses the team-seats preset (per-seat pricing, team-owner billing contact); B2C shape uses the individual-subscription preset (single-user pricing). Both presets are hardwired in `packages/billing/paddle/` and selected via the shape value in `keel.config.ts`.
- **FR61**: System can process Paddle webhooks for lifecycle events (subscription creation, cancellation, dunning, upgrade, downgrade) with signature verification and idempotent handling.
- **FR62**: System can enforce subscription-gated access to premium capabilities. Usage-quota-gated access is deferred to the API-first shape in 1.2.
- **FR63**: *(Growth-tier)* A second billing provider (e.g., Stripe standard or Stripe Connect) enters via a thin adapter + migration guide when a real product forces it. At 1.0 Paddle is the single hardwired implementation.

### End-User Localization

- **FR64**: End user can select a preferred locale; the system persists and honors the selection across sessions. English baseline is always present; additional locales are added by scaffolding empty translation files in the fork.

## Non-Functional Requirements

### Performance

- **NFR1**: The decomposed CI pyramid hits the following wall-clock budgets on a standard GitHub Actions runner: pre-commit ≤10s, pre-merge-fast ≤3min (must be deterministic — no live-network hits), pre-merge-slow ≤10min, nightly ≤60min (live-network sandbox hits quarantined here), release-gated (manual) bounded only by the live-network path. Non-toggle-able. Any tier exceeding its budget fails the build. This replaces the pre-wizard-reversal monolithic 60-minute integration gate on the critical path.
- **NFR2**: Devbox cold-start (first-run build) completes within 5 minutes on Apple-Silicon-class hardware; warm-start (container reuse) within 30 seconds. Targets to be validated during M0.5.
- **NFR3**: RLS query overhead is measurable, monitored, and held below a threshold set in the architecture doc. Budget deferred.
- **NFR4**: Ralph iteration startup (context load, task parse, agent spawn) completes within 20 seconds; iteration task-budget is enforced. Token budgets (`max_tokens`, execution ceiling, compaction triggers) are tokenizer-aware and re-baselined per tested model version — Opus 4.7's tokenizer emits up to ~35% more tokens per byte than Opus 4.6 for the same text, so fixed numeric budgets cannot transfer across major model versions without re-measurement.
- **NFR4a (Context utilisation smart zone)**: Ralph iterations aim for 40–60% utilisation of the advertised context window (200K advertised ≈ 176K usable for Opus 4.7; 117K execution budget target). Iterations exceeding 80% trigger a clean-exit budget signal; iterations below 30% are flagged as under-utilised for potential task-batching review. Smart-zone metrics are emitted by FR14d's per-iteration context meter.

### Security

- **NFR5**: All agent execution runs inside the devbox; `--dangerously-skip-permissions` is never invoked on the host. Non-toggle-able at config layer; bypass requires a source-level fork.
- **NFR6**: Container network egress is default-deny; reachable hosts are limited to the dnsmasq whitelist. Expanding the whitelist is an explicit user action, logged.
- **NFR7**: Container runs as a non-root user (uid/gid ≠ 0). Kernel capabilities limited to NET_ADMIN and NET_RAW.
- **NFR8**: `/tmp`, `/var/tmp`, and `/workspace/logs` are mounted tmpfs with noexec and nosuid flags.
- **NFR9**: Secrets must never be committed. A pre-commit gate rejects commits that match known secret patterns (API keys, bearer tokens, private keys).
- **NFR10**: Claude Code and `gh` CLI authentication tokens are persisted only inside the devbox volume (`/home/dev/.claude/` and `/home/dev/.config/gh/`); the host's `~/.claude/` and `~/.config/gh/` are never bind-mounted.
- **NFR11**: Tenant isolation is enforced at the database layer (RLS), not the application layer. An application-layer bug cannot cross tenant boundaries.
- **NFR12**: All authenticated sessions are DB-backed with revocation support. Stateless-JWT sessions are a documented Tier-2 deviation path only.
- **NFR13**: All audit log entries are append-only. Application code cannot delete or modify past entries.
- **NFR14**: Dependency audit (Dependabot or equivalent) runs on every PR; critical vulnerabilities block merge.
- **NFR15**: Every Ralph iteration produces structured security evidence (secret scan + dep audit + SAST + prompt-injection scan + test coverage) persisted to `.ralph/logs/<iteration-id>/security-evidence.json` before commit.
- **NFR16**: Security-verification failures are equivalent-priority to test-verification failures for the Ralph loop's halt behaviour.
- **NFR17**: Keel adopts OWASP Top 10:2025, ASVS Level 1, and OWASP Top 10 for Agentic Applications (2026) as the substrate security baseline. Level 2+ is a Tier-2 deviation path for compliance-bound forks.
- **NFR18**: Critical-severity security findings (hardcoded production secrets, CVSS ≥ 9 vulnerabilities, known RCE patterns) trigger immediate Ralph halt without retry.

### Scalability

- **NFR19**: The substrate imposes no scalability ceiling beyond the underlying runtime (Node.js, Postgres, pg-boss). Horizontal scaling via worker-process extraction is a documented Tier-2 deviation path.

### Accessibility

- **NFR20**: Baseline UI components shipped with Keel (signup, login, billing, locale selector, team management) meet WCAG 2.1 Level AA for keyboard navigation, colour contrast, and screen-reader semantics.
- **NFR21**: The i18n framework supports RTL languages at the layout level (logical properties, directional CSS) so right-to-left locales render correctly without component rewrites.

### Integration

- **NFR22**: Paddle webhook processing is idempotent — repeated delivery of the same event produces the same end state.
- **NFR23**: Paddle webhook signatures are verified against Paddle's public key; unsigned or mis-signed webhooks are rejected.
- **NFR24**: Failed external-service calls (Paddle, Resend) surface through pg-boss job retry semantics with exponential backoff and a dead-letter queue.
- **NFR25**: OAuth flows (Google) enforce PKCE and state-parameter verification to prevent authorization-code injection.

### Reliability

- **NFR26**: Ralph iteration commits are atomic — an iteration commits a green-test-and-green-security-evidence state or leaves the repo unchanged. Partial-state commits are rejected at the pre-commit gate.
- **NFR27**: Quality gates (pre-commit, pre-merge, pre-deploy) fail closed — any gate unreachable or misconfigured rejects the commit, PR, or deploy. No silent-success mode.
- **NFR28**: Flake-rate budgets are tier-specific. **Pre-merge-fast + pre-merge-slow gates must be deterministic — flake rate > 0.1% across a 30-day window triggers immediate CI-hardening.** Nightly tier (live-network) tolerates up to 2% flake across a 30-day window; sustained > 2% triggers a review. This tier-specific budget resolves the pre-wizard-reversal arithmetic conflict where 2% flake on a 60-min monolithic E2E gate was incompatible with Ralph's 3-consecutive-failures halt.

### Maintainability

- **NFR29**: Substrate steady-state maintenance (triage, fixes, upgrades) stays at 5-10 hours per month. Sustained > 15 hours/month triggers scope-cut or archive per the Business Success kill criterion.
- **NFR29a (Model-version-pinned prompt-set)**: Keel's Ralph prompt templates (`.ralph/PROMPT_build.md`, `.ralph/PROMPT_plan.md`, and `packages/keel-templates/PROMPT_*.template.md`) are pinned to a specific model generation per major Keel version. Minor Keel versions inherit the prompt-set unchanged; major Keel versions may diverge and must record the tested model generation + prompt delta in release notes. This anchors the Opus-4.6→4.7-style breaking-prompt risk to major-version cadence rather than ambient drift.
- **NFR30**: Every Keel major version documents the tested model generation (e.g., Opus 4.7), Claude Code CLI version, BMad version, and Ralph version. A breaking upstream model upgrade triggers a new major version test-run. "Breaking" is evaluated against Domain-Specific Requirements § Model and Tooling Evolution delta catalogue and includes, at minimum: extended-thinking API changes, thinking-display default flips, sampling-knob removals, tokenizer re-baselines, prefill-handling changes, instruction-following literality shifts, default subagent/tool-call spawn-rate changes, and new stop-reason introductions. Silent (non-breaking) upgrades do not trigger a major — but the policy defaults to "treat as breaking" if the delta is ambiguous.
- **NFR31**: The Invariants stack's three layers (machine-enforced, agent-readable, documented) are kept in sync by a pre-merge gate; drift between layers fails the build.

### Observability

- **NFR32**: Every request handled by a Keel-forked app emits OpenTelemetry traces correlated by request ID. Sampling rate is configurable per-deploy; exporter endpoint is read from `keel.config.ts → otelExporter` at build time.
- **NFR33**: Ralph iterations emit structured stream-json logs to `.ralph/logs/` with per-iteration ID, start/stop timestamps, claude subprocess exit status, and test results.

### Configuration & Generator UX

- **NFR34**: The minimal bootstrap (`pnpm dlx create-keel-app <name>`) completes in under 2 minutes wall-clock excluding devbox cold-start (covered by NFR2). No interactive prompts. No wizard.
- **NFR35**: Shape edits to `keel.config.ts` that produce invalid values fail at typecheck — not silently at first test. The shape + tenancy literal-union types rule out invalid combinations at compile time; there is no runtime validator because there is no user-facing wizard that could present invalid combinations.
- **NFR36**: *(Reserved.)* The pre-wizard-reversal NFR36 (wizard-schema versioning) is deleted. `keel.config.ts` carries no `schemaVersion` field at 1.0; a field is added only when a breaking schema change earns it. See Out of Scope § Governance non-commitments for the evolution policy.
- **NFR37**: The `keel.config.ts` → generated-artefact pipeline is idempotent — running `pnpm generate` repeatedly against an already-synchronised repo produces no diff. Idempotency is verified by a pre-merge-fast test that regenerates and diffs. Content-hashing each generated artefact (per the normalization contract in the Invariants § Sync enforcement subsection) guards against silent divergence.
