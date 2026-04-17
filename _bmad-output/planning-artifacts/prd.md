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
lastEdited: '2026-04-17'
editHistory:
  - date: '2026-04-17'
    changes: 'Post-validation polish pass. HIGH findings: (H1) qualified NFR35 fail-closed to distinguish rejection-class from warning-class combinations; restructured Wizard Validation Rules into Rejection-class and Warning-class blocks with explicit --accept-warnings non-interactive behaviour. (H2) added parenthetical anchor at first use of "Tier-2 deviation path" in Out of Scope pointing at the Implementation Considerations definition. MEDIUM findings: (M1) added elision note for single-option wizard axes (Jobs, Email); (M2) added postPivotNote frontmatter entries to PRFAQ and PRFAQ distillate flagging them as superseded-on-thesis with pointer to current PRD; (M3) corrected Journey 2 M4-checkpoint day to ~29 (was ~25) to match new milestone cumulative; (M4) reframed Vision § bullet 3 from "enforced invariants" to "wizard-pinned-and-frozen invariants." LOW findings deferred (non-blocking, documented in validation report).'
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
  contentShape: multi-shape-configurable  # SaaS-B2B default; Marketplace, B2C, API-first available via wizard
  projectContext: greenfield  # absorbing brownfield Ralph harness
  domain: general
  domainNotes: agentic-engineering workflow; autonomous-code-execution risk surface
  complexity: high
  ralphDisposition: fork  # monthly upstream diff review
  qualityGatePosture: non-negotiable
  architectureStatus: axes-resolved-pending-formalization
  executionModel: containerized-agent-autonomy
  securityPosture: non-negotiable
  configurationModel: setup-time-pinned  # wizard-chosen at scaffold; frozen post-setup; materialised into packages/keel-invariants/
---

# Product Requirements Document - Keel

**Author:** Tthew
**Date:** 2026-04-17

## Executive Summary

Keel is an opinionated SaaS substrate configurable at scaffold time via a setup wizard and frozen thereafter, built for one person (Tthew) and a small peer audience of experienced solo builders who ship SaaS ideas using agentic workflows — BMad planning, the Ralph loop, and Claude Code. The problem it solves is that shipping SaaS ideas rapidly requires decisions made once and leveraged across product bets; when those decisions live in a human's head as convention rather than in the repository as enforced invariants, each new product re-litigates infrastructure and agents spiral on questions that should already be settled. Keel's future state: the builder spends more time on-the-loop (directing, reviewing, course-correcting) and less time in-the-loop (implementing mechanically), which compounds work across forks and unlocks product bets that wouldn't justify cold-start infrastructure investment on their own.

### What Makes This Special

Three co-equal first-class principles form a causal chain. **Invariants enforced at the repository layer** (RLS policies, import boundaries, non-toggle-able gates — all generated from wizard-pinned configuration at scaffold time) enable agent coherence — agents do not re-litigate settled decisions because the decisions are materialised mechanically at setup and frozen rather than left as conventions. Agent coherence is the precondition for staying on-the-loop rather than babysitting agents in-the-loop. On-the-loop work then compounds across products, because decisions survive forks as invariants and do not evaporate as conventions.

Four load-bearing mechanisms implement the chain: (1) **setup-time invariant pinning** via a wizard that writes typed configuration (`keel.config.ts`) consumed by substrate packages, with post-setup config frozen — agents see the config as invariants, not options; (2) **non-toggle-able four-layer quality gates plus Ralph backpressure** applied equally to agent-authored and human-authored commits regardless of which wizard choices were made; (3) **CI-tested migration-between-choices guides** for swapping scaffold-time selections post-fork (docs are features; stale guide = red build); (4) **quick-start defaults** — pressing Enter through the wizard produces the SaaS-B2B stack (Paddle, better-auth, Prisma + Postgres, TanStack Start, pg-boss, Resend, self-host deploy, team tenancy, English baseline) so the defaults path matches what would historically have been the hardwired posture.

Thesis: *"Your agents are only as good as the decisions you've already frozen for them."* The competitive category is empty by verified research — ShipFast, Makerkit, Supastarter are human-optimised boilerplates commoditised at the $199–$299 tier with neither setup-time invariant pinning nor agent-coherent scaffolding; Bmalph-class tools are orchestration-only, not a deployable substrate. Keel's differentiator is the combination of agent-coherent scaffolding, setup-time invariant pinning, security-by-default (sandbox + Day-1 RLS + per-iteration verification), and the Ralph loop — not specific library choices.

### Execution Environment

Keel ships a Docker-based devbox (absorbed from the author's prior `cc-devbox` project) inside which Ralph, Claude Code, and all agent-authored code execution run under `--dangerously-skip-permissions` — the sandbox is what makes the flag safe. The host-side entry point is `pnpm <subcommand>`, which proxies through the Keel CLI (`keel.py`, uv-runnable — first-class 1.0 surface) that manages container lifecycle, runs the setup wizard, and forwards commands. Users never invoke Docker, docker-compose, or SSH directly.

Autonomous Ralph execution has two one-time auth prerequisites inside the devbox: Claude Code (`pnpm claude` triggers OAuth; tokens persist in `/home/dev/.claude/`) and `gh` CLI (`pnpm gh:auth` triggers `gh auth login`; tokens persist in `/home/dev/.config/gh/`). Ralph cannot push commits or open PRs autonomously until `gh` is authenticated. Both flows surface their OAuth URLs to the host terminal; the host browser completes the flow; tokens stay inside the container volume and never touch the host's own `~/.claude/` or `~/.config/gh/`.

### First-Run Setup Wizard

At fork creation (`pnpm dlx create-keel-app`) or on first clone of an unconfigured repo (`pnpm keel:init`), Keel launches a setup wizard inside the devbox. The wizard presents a bounded catalogue of choices (product shape, auth library, DB/ORM, framework, billing, jobs, email, deploy target, tenancy model, analytics, error tracking, cookie banner, extra locales, OTel exporter, project identity) with sensible defaults; pressing Enter through produces the SaaS-B2B quick-start stack. Answers are validated (incompatible combinations rejected at wizard time with explicit error messages), persisted to `keel.config.ts` at the repo root, and materialised into `packages/keel-invariants/` via an idempotent generator that emits ESLint config, tsconfig-base, commitlint config, prek hooks, and import-boundary rules from the config.

Post-setup, the config is frozen: agents see `keel.config.ts` as invariants, not options. `pnpm keel:configure` re-runs the wizard against the same schema but refuses to change values already materialised into substrate code without an explicit `--migrate <option>` flag that invokes the relevant migration-between-choices guide. Non-interactive mode (`pnpm keel:init --shape=saas_b2b --auth=better-auth ...` or `--from-config <file>`) supports CI scaffolding and agent-authored fork creation. The full choice catalogue, defaults table, and validation rules live in the Developer-Tool & CLI-Tool Specific Requirements section.

## Project Classification

- **Project Type:** `developer_tool` / `cli_tool`, `multi-shape-configurable` content shape (SaaS-B2B default; Marketplace, B2C consumer-app, and API-first / developer-API-as-product available as wizard-selected shapes)
- **Configuration Model:** Setup-time invariants — wizard-chosen at scaffold, frozen post-setup, materialised into `keel.config.ts` and `packages/keel-invariants/` via an idempotent generator; agents see the config as invariants
- **Domain:** `general` — agentic-engineering workflow; autonomous-code-execution risk surface
- **Complexity:** High — novel full Day-1 RLS matrix (parameterised over tenancy model), wizard-driven invariant generation, correlated-library risk on multiple scaffold-time choices, stack aging under model/tooling evolution
- **Project Context:** Greenfield, absorbing the brownfield Ralph harness (`ralphDisposition: fork`, monthly upstream diff review)
- **Quality Gate Posture:** Non-negotiable — disabling via config forbidden; forking to remove permitted
- **Architecture Status:** Seven load-bearing axes resolved in brainstorm; formalization deferred to `bmad-create-architecture`

## Success Criteria

### User Success

Primary user is Tthew (N=1). User success is operationalised through two ratio-style measurements with equal priority:

- **Time-to-next-product (T2NP)**: measured from "decision to start product #2" to "product shipped — live URL, working signup, first real user interaction." Target: < 1 week. Baseline: multi-week infrastructure re-litigation and stack-decision tax on an unstructured start.
- **Ralph iteration autonomy rate (RIAR)**: % of Ralph iterations that complete their assigned task without human intervention (no rollback, no mid-iteration course-correct, no manual code-fix). Target: ≥ 70% sustained across a seven-day rolling window. Baseline to be established in M4 via instrumented runs on a pre-Keel repo.

Secondary qualitative signal:

- **Self-reported on-the-loop ratio** at the M4 checkpoint and at 1.0 cut — subjective comparison against pre-Keel baseline. Pass/fail only; used as gut-check against T2NP and RIAR.

### Business Success

- **Launchpad readiness (1.0 gate)**: live URL + working signup + one paying customer. Framed as functional test of the substrate, not a commercial milestone.
- **12-month / 2-product payback**: 2-4 products shipped on Keel within 12 months of 1.0.
- **Archive kill criterion (ACCEPTED)**: fewer than 2 products shipped within 12 months → archive Keel.
- **Maintenance ceiling (ACCEPTED)**: sustained > 15 hrs/month triggers scope-cut or archive. Expected steady-state: 5-10 hrs/month.
- **M4 checkpoint ritual**: explicit decision at end of critical path between "push M5-M9" vs "pause and ship real product on partial substrate."

### Technical Success

- **60-minute CI integration gate**: `git clone` → wizard (quick-start defaults) → signup → tenant formation (team / user / org per tenancy-model choice) → paid subscription (via wizard-chosen billing) passes in under 60 minutes. Non-toggle-able. Red gate = broken repo. Matrix-tested across each supported shape × billing combination.
- **Wizard completion time**: Quick-start (all defaults, Enter-through) completes in under 5 minutes; full customisation (every choice answered deliberately) completes in under 20 minutes. Incompatible-combination errors surface at wizard time, not at first test.
- **Four-layer quality gates** (pre-commit / pre-merge / pre-deploy / release), non-toggle-able at config layer. Applied identically regardless of wizard-chosen stack.
- **Ralph backpressure**: loop halts on consecutive failed tests or task-budget exhaustion.
- **Day-1 RLS invariant**: every tenant-scoped table ships with a Postgres RLS policy parameterised over the wizard-chosen tenancy model (`team` / `user` / `org`). Policy source-of-truth is `keel.config.ts → tenancy`; the generator emits the matching `current_setting('app.current_tenant_id')` session variable and RLS template. Physical prevention, not convention.
- **Migration-between-choices CI**: quarterly runs verify swap paths for every wizard choice that has more than one option (TanStack Start ↔ Next.js; better-auth ↔ Auth.js ↔ Clerk; Prisma ↔ Drizzle; Paddle ↔ Stripe). Stale guide = red build.
- **Import-boundary enforcement**: ESLint `no-restricted-imports` + TypeScript project references. Compile-time, not review-time. Rules are generated from `keel.config.ts` via the invariants generator so boundaries reflect the wizard-chosen package topology.
- **Config-to-invariants sync**: `keel.config.ts` edits without matching generator output fail the pre-merge gate. Re-running the generator is idempotent.

## Product Scope

### MVP - Minimum Viable Product (Keel 1.0)

48-day milestone plan (48-52-day realistic-slip estimate). MVP gate: Launchpad. The 22-day increase over the pre-pivot 26-day plan is absorbed entirely by wizard + config-as-invariants scope (M0.6, M0.7) and per-choice parameterisation of M1/M2/M3/M7/M8/M9.

- **M0 Repo foundation & tooling** (2d) — pnpm workspaces, Turborepo, prek, commitlint, release-please, ESLint + TS project refs, conventional-commits enforcement.
- **M0.5 Devbox** (3d) — absorb `cc-devbox` into `packages/devbox/`; parameterise hardcoded paths; auto-start logic and TUI docker-attach UX.
- **M0.6 Keel CLI + wizard engine** (6d) — ship `keel.py` (Python, uv-runnable) as first-class 1.0 surface; wizard UI (interactive and non-interactive `--flags` / `--from-config`); choice catalogue schema versioned per major Keel release; incompatible-combination validation; re-runnability guardrails (`pnpm keel:configure` with `--migrate <option>` path); scaffolding command `pnpm dlx create-keel-app`; wire pnpm script topology (ralph:*, devbox:*, claude, keel:*).
- **M0.7 Config-as-invariants plumbing** (3d) — `keel.config.ts` typed schema; idempotent generator emitting `packages/keel-invariants/` contents (ESLint, tsconfig-base, commitlint, prek hooks, import-boundary rules) from the config; sync-enforcement pre-merge gate covering config → generator-output drift.
- **M1 Data model + RLS tenancy** (3d, was 2d) — Day-1 RLS policies parameterised over wizard-chosen tenancy model (team / user / org); `tenantGuard()` as session-variable-setter keyed on `app.current_tenant_id`; `pnpm rls:explain` CLI; tenancy-model generator templates.
- **M2 Auth & Identity** (5d, was 3d) — auth-library adapter surface; wizard-default better-auth implementation with DB-backed sessions, Google OAuth + email/password, step-up middleware; Auth.js and Clerk implementations scaffolded behind the adapter for wizard-time selection.
- **M3 Billing** (5d, was 3d) — shape-aware billing selector; wizard-default Paddle (SaaS-B2B / B2C shapes) with MoR integration, webhook processing, subscription lifecycle; Stripe Connect implementation for Marketplace shape; Stripe standard implementation for API-first shape.
- **M4 Email + Jobs** (2d) — wizard-default Resend integration with three baseline email templates; wizard-default pg-boss typed job registry. Alternative providers scaffolded as Growth-tier wizard options.
- **M5 Observability + Audit** (2d) — OpenTelemetry traces with wizard-configured exporter endpoint; append-only audit log schema.
- **M6 Feature flags** (1d) — server-side evaluation in wizard-chosen framework's route loaders.
- **M7 Frontend patterns + UI** (5d, was 4d) — tRPC + react-hook-form + Zod + Zustand + Tailwind + i18n framework wired into wizard-chosen framework; wizard-default TanStack Start implementation; Next.js implementation scaffolded behind the adapter; typed-key enforcement; English baseline locale.
- **M8 Migration-between-choices guides** (3d, was 2d) — CI-tested guides for every wizard choice that exposes >1 option (TanStack Start ↔ Next.js; better-auth ↔ Auth.js ↔ Clerk; Prisma ↔ Drizzle; Paddle ↔ Stripe; team ↔ user ↔ org tenancy migrations). Guides drive the `pnpm keel:configure --migrate <option>` path.
- **M9 Testing & CI hardening** (4d, was 2d) — 60-min integration test matrix (each supported shape × billing combination); quarterly migration-between-choices CI; RLS policy tests against every migration; wizard-path smoke matrix covering all defaults + a sampled cross-section of non-default combinations.

### Growth Features (Post-MVP)

- **Expanded wizard choice catalogue**: additional auth libraries beyond better-auth / Auth.js / Clerk; additional frameworks beyond TanStack Start / Next.js; additional ORMs beyond Prisma / Drizzle; additional job runners beyond pg-boss; additional email providers beyond Resend; additional deploy targets (Vercel, Fly, Railway).
- **Expanded migration-between-choices guide coverage**: every new wizard option ships with a CI-tested migration path from the defaults for its axis.
- **Wizard UX polish**: interactive TUI visual refresh; pre-scaffold preview mode (`pnpm keel:init --dry-run` emits the prospective `keel.config.ts` without materialising); richer incompatible-combination hints with suggested fixes.
- **Shape-specific Growth features**:
  - *Marketplace*: dispute resolution workflow scaffold, ratings / reviews scaffold, payout dashboard.
  - *B2C consumer-app*: freemium tier scaffold, referral system, push-notification scaffold.
  - *API-first*: developer portal, sandbox environments, quota-based pricing scaffold, GraphQL option alongside OpenAPI.
- **Runtime-configurable substrate pieces** (deliberate limited scope): only truly runtime concerns (feature flag evaluation, locale selection, OTel sampling rate) move to runtime configuration. Core stack choices remain frozen-at-setup.

### Vision (Future)

Keel 1.0 is the first codified substrate in a larger meta-framework for shipping SaaS ideas on agentic workflows. The meta-framework composes three pillars:

1. **BMad** — planning artefacts (PRD, architecture, epics, stories) as enforceable contracts between phases.
2. **Ralph** — autonomous loop harness running against committed plans.
3. **Keel** — substrate on which Ralph executes; the wizard-pinned-and-frozen invariants that let agents stay coherent across iterations and forks, regardless of which scaffold-time stack each fork selected.

Vision is dogfood-first: the meta-framework is validated by Tthew shipping multiple products on it, not by external adoption. Adoption signaling (blog post, peer-community share) is permitted but not planned.

### Out of Scope

Consolidated exclusions. Items here are explicitly not in 1.0 scope; most are either non-toggle-able invariants (fork-to-remove), deliberate architectural non-commitments, or bounded by the wizard catalogue. Downstream Epics and Stories that propose any of these items must be rejected or escalated to a scope-change decision.

**Languages & polyglot targets:**

- No Python / Go / Rust / Ruby SDKs. TypeScript only, end-to-end.
- No non-pnpm package managers. `pnpm` is the monorepo contract; npm and yarn are unsupported.

**Wizard catalogue boundaries (what's NOT configurable at 1.0):**

- No free-form stack composition. The wizard exposes a bounded catalogue per axis (see Developer-Tool & CLI-Tool Specific → Wizard Choice Catalogue); additions are Growth-tier.
- No runtime-toggleable stack choices. The wizard pins choices at scaffold time; runtime-configurable core substrate is out of scope. Post-setup re-selection requires `pnpm keel:configure --migrate <option>` running the relevant migration-between-choices guide.
- No zero-choice (convention-only) scaffolding. Even Enter-through-defaults produces a committed `keel.config.ts`; there is no "no config" path.

**Product shapes (wizard-selected at 1.0):**

- **Supported at 1.0**: SaaS-B2B (default), Marketplace (two-sided platform), B2C consumer-app, API-first / developer-API-as-product. Shape choice drives downstream wizard validation (e.g., Marketplace shape requires Stripe Connect; API-first activates public-API scaffolding).
- No clean learner / tutorial experience. Keel assumes prior SaaS shipping.
- No custom / free-form shape. Shapes are bounded to the four above; new shapes ship in minor or major Keel versions, not per-fork.

**Shape-activated features (only present when the matching shape is wizard-chosen):**

- REST / GraphQL public API surface, OpenAPI generation, API key lifecycle, rate limiting → activated only when `shape = api_first`; absent under other shapes (tRPC remains the internal contract).
- Outbound webhooks / developer-facing webhook subscription → activated only when `shape = api_first`.
- Multi-role identity (buyer / seller), payout flows, take-rate billing → activated only when `shape = marketplace`.

**Enterprise affordances (explicit non-commitments):**

- No SSO adapter (SAML / OIDC beyond Google OAuth). Growth-tier wizard option candidate.
- No SIEM / audit-log shipping to external systems.
- No SOC 2 / ISO 27001 / HIPAA / PCI-DSS compliance posture. ASVS Level 2+ lives behind a Tier-2 deviation path (an off-wizard-catalogue exit — see Developer-Tool & CLI-Tool Specific → Implementation Considerations for definition) for compliance-bound forks.

**Capabilities deferred beyond 1.0:**

- No admin dashboard.
- No IDE plugin / extension. The agentic workflow is the IDE.
- No shell completion for `pnpm` commands at 1.0.
- No headless Ralph (`--no-tui`) mode at 1.0. Growth-tier candidate.
- No global user-level config file. Per-project `.ralph/` dotfiles only.
- No per-fork wizard schema extensions at 1.0. Forks can add product-specific invariants via `INVARIANTS.fork.md` (FR45) but the wizard catalogue is substrate-scoped.

**Governance non-commitments:**

- No toggle-able quality gates post-setup. Removal requires fork.
- No backwards-compatibility guarantees across Keel major versions. Each major documents its tested model/tooling combination and its wizard schema version; breaking model upgrades or breaking wizard schema changes trigger new majors.
- No silent wizard choice changes on upstream rebase. If Keel upstream ships a new wizard option default, forks inherit the new option as available but the fork's existing frozen choice is preserved on rebase.

**Out of project (belongs to a separate follow-on):**

- No distribution strategy / customer-acquisition playbook.
- No `npm publish` of individual substrate packages. Fork-and-use only.
- No planned adoption signaling (blog, peer-community push). Permitted but not planned.
- No scope commitment for agent-authorship workflows outside the Claude Code + BMad + Ralph triad. Tests and docs assume this stack.

## User Journeys

### Journey 1 — Tthew: Product #2 Happy Path (validates T2NP ≤ 1 week)

**Opening.** Saturday morning, eight months after Keel 1.0 cut. Tthew has a new product idea that has been percolating for two weeks. Decision made: start it. Time-tracking begins.

**Rising action.** `pnpm dlx create-keel-app product2-app`. The setup wizard launches inside a transient devbox: shape (SaaS-B2B — Enter), auth (better-auth — Enter), DB (Prisma+Postgres — Enter), framework (TanStack Start — Enter), billing (Paddle — Enter), jobs (pg-boss — Enter), email (Resend — Enter), deploy target (self-host — Enter), tenancy (team — Enter), analytics (none — Enter), project identity ("product2", "product-two-xyz"). Four minutes: wizard complete. `keel.config.ts` committed; `packages/keel-invariants/` materialised. Fifteen minutes in, the 60-minute integration test runs green locally: signup → team → Paddle sandbox subscription, end-to-end. No stack decision re-litigated — the wizard answers are frozen as invariants, and agents see them that way. Product-specific work begins at minute 20.

**Climax.** Day three. First product feature (domain entity + tRPC route + UI) lands green on CI, including Day-1 RLS policy for the new table (generated from the wizard-pinned `tenancy = team` setting). No tenant-filter bug escapes because the policy is invariant, not convention. Claude Code has been running Ralph iterations against the story list since day one; RIAR is sitting at 78% across a rolling window.

**Resolution.** Day six. Live URL, signup working, first real user interaction recorded. T2NP for product #2 (inclusive of the ~4-minute wizard): 6 days 4 hours. Target: < 1 week. Pass. The next Saturday, Tthew considers a further product idea — perhaps a marketplace shape this time — not because the current one is scaled, but because the cold-start tax no longer deters the attempt.

### Journey 2 — Tthew: M4 Checkpoint Governance Ritual (edge case)

**Opening.** Day ~29 of the 48-day Keel 1.0 build — M4 has just closed. M0-M4 green (repo foundation, devbox, Keel CLI + wizard, config-as-invariants, RLS, auth, billing, email+jobs). M5-M9 remain. Tthew opens the calendar entry for the M4 checkpoint.

**Rising action.** The question is pre-committed and specific: "Push M5-M9, or pause and ship real product on partial substrate?" Repo state tells part of the story: 60-minute integration test green on defaults; four-layer gates in place; RLS invariant enforced; wizard + config-as-invariants landed; scaffolding CLI operational. What is missing: migration-between-choices guides, full observability, hardened frontend patterns. The actual signal is the 12-month/2-product kill criterion — a product idea has been deferred precisely because substrate was not ready.

**Climax.** Tthew picks "pause and ship." Substrate at ~60% of 1.0 scope but covers every load-bearing concern for the deferred product. The decision is committed as a markdown entry in the repo (not a private note). M5-M9 become Phase 1.1, scheduled post-launch.

**Resolution.** The ritual protects against its own failure mode — procrastination masquerading as finishing. The 12-month archive clock starts when the partial-Keel product ships, not when 1.0 is cut. Three months later, the shipped product forces M5 (observability) because debugging needs it — the substrate learns which unbuilt milestones are actually load-bearing vs aspirational.

### Journey 3 — Ralph / Claude Code: Agent Iteration on a Keel Repo (validates RIAR ≥ 70%)

*Departure from narrative template: state-transition arc for a non-human user.*

**Precondition state.**

- Repo at commit N with green 60-min CI, RLS policies validated, all four-layer gates passing. Wizard-setup long-completed; `keel.config.ts` frozen.
- Devbox container running (auto-started by `pnpm ralph:build` if not already up); DNS whitelist active; `--dangerously-skip-permissions` safe because sandboxed.
- Claude Code and `gh` CLI both authenticated inside the devbox volume; tokens persist across container restarts; prerequisite check passed.
- `.ralph/@plan.md` holds the current story: "Add email verification flow for new team invites" (story ID #42).
- Claude Code context loaded with repo invariants — `keel.config.ts` (wizard-pinned choices: better-auth, Resend, pg-boss, team tenancy) exposed via `CLAUDE.md` + skill definitions + `INVARIANTS.md`. Agents treat these as invariants, not options.
- Ralph iteration budget: 30 minutes per iteration; 3 consecutive failures halts the loop.

**Iteration flow.**

1. Ralph (running inside the devbox) spawns `claude -p --dangerously-skip-permissions`, piping the build-mode Ralph prompt (`.ralph/PROMPT_build.md`) as input. The Ralph prompt directs Claude to read the implementation plan at `.ralph/@plan.md`, pick the next pending item from the NOW/QUEUE sections (story #42: "Add email verification flow for new team invites"), and execute it. Claude reads the bind-mounted workspace, sees `packages/core/auth`, `packages/email`, and existing better-auth patterns. No decision is re-litigated.
2. Claude writes a new tRPC mutation `team.inviteWithVerification`, adds a Zod schema, creates a Resend email template, wires pg-boss to enqueue the verification send.
3. Tests run: unit (pass), integration (pass), RLS policy against the new `invite_tokens` table (fail — no policy exists yet).
4. Ralph sees the failure. Claude generates the RLS policy based on the existing pattern, re-runs.
5. All tests green. Conventional-commit message generated. Iteration commits and pushes.

**Backpressure branch (alternate path).**

If iteration 3 in a row fails the same integration test, Ralph halts via `.ralph/halt`. Next human check surfaces the halt signal.

**Success signal.** Iteration completes autonomously, contributing to RIAR ≥ 70%.

**Repository-state delta.** New mutation, new email template, new RLS policy, new pg-boss job registration — all four landing together because the substrate made all four patterns local and findable.

### Journey 4 — Marcus: Peer Agency Fork + Monthly Upstream Rebase

**Opening.** Marcus runs a three-person agency. Two client SaaS projects have shipped on Keel forks in the four months since 1.0 dropped. A new client project starts Monday — this one is a marketplace, unlike the first two (SaaS-B2B).

**Rising action.** Monday morning. `pnpm dlx create-keel-app my-client-proj`. The 1.0 setup wizard runs: shape = `marketplace` (not default), auth = better-auth (default), DB = Prisma+Postgres (default), framework = Next.js (override of TanStack Start default for this client's React preference), billing = Stripe Connect (required by marketplace shape — wizard validates and rejects Paddle selection with a clear error), tenancy = team, analytics = PostHog, deploy = Fly.io. Marcus uses the interactive wizard the first time; subsequent client projects he starts from a shared non-interactive config template via `--from-config`. Fresh fork is product-ready in 20 minutes including wizard. `keel.config.ts` committed alongside the first commit.

**Climax.** End of month one. Marcus runs his standard ritual: pull upstream Keel `main`, rebase. release-please on upstream has cut 1.1.0 with one new wizard option (Clerk added to auth catalogue), a pg-boss dependency bump, a Paddle webhook signature rotation. Rebase conflicts in his product code: zero. Package boundaries meant upstream changes touched only `packages/*`; his product code lives in `apps/web/features/*`. His existing `keel.config.ts` values (shape = marketplace, auth = better-auth, framework = Next.js) are preserved on rebase — the new Clerk option becomes available to future forks but doesn't change his fork's frozen choices. Migration-between-choices CI ran green during release-please; Marcus trusts the 1.1.0 tag.

**Resolution.** Twenty minutes of rebase work, no surgery. Marcus charges the client 0.25 days for the upgrade. Fourth such rebase since 1.0; all four non-events. Keel's setup-time invariants survived non-Tthew use across three different wizard-chosen stacks.

### Journey Requirements Summary

The four journeys converge on the same capability set — which is the point, not a coincidence.

| Capability                                             | Journeys  | Milestones     |
|--------------------------------------------------------|-----------|----------------|
| Scaffolding CLI + setup wizard                         | J1, J4    | M0.6           |
| Config-as-invariants (keel.config.ts + generator)      | J1, J3, J4| M0.7           |
| Forkable repo, green integration test in minutes       | J1, J4    | M0, M9         |
| Day-1 RLS parameterised over wizard tenancy choice     | J1, J3    | M0.7, M1       |
| Auth/billing/email/jobs as wizard-pinned opinion       | J1, J3, J4| M2, M3, M4     |
| Shape-aware wizard validation (incompatible combos)    | J4        | M0.6           |
| Package boundaries enforced at compile time (from config) | J3, J4 | M0, M0.7       |
| Ralph backpressure + CI as autonomous gate             | J3        | M9, harness    |
| Checkpoint ritual + governance artifacts in-repo       | J2        | M8             |
| Migration-between-choices CI protecting upstream/downstream | J4   | M8, M9         |

## Domain-Specific Requirements

Keel's domain is general SaaS — no regulatory regime binds substrate code. Complexity is high on technical grounds. Four domain-novel concerns are captured here because they are not covered by Executive Summary, Technical Success, or standard NFRs.

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

Two libraries carry correlated-community risk at 1.0 as defaults: TanStack Start (framework) and better-auth (auth library). Additional wizard-option libraries (Auth.js, Clerk, Next.js, Drizzle, Stripe) each carry their own maintenance risk tracked per-axis. Policy:

1. Quarterly CI run of the migration-between-choices guide for each wizard axis with >1 option. Stale guide ≥ 1 quarter fails substrate build.
2. If any wizard-option library's maintenance signal drops below a named threshold (no release in 6 months, or security advisory unpatched > 14 days), the next major Keel version demotes that option from the wizard catalogue; affected forks migrate via the documented migration-between-choices path.

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

- **Probability / timing:** possible 2026, probable 2027. Relevance window: 12–18 months from 1.0 cut.
- **Failure signature:** an agent given a plain `pnpm create …` starter produces substantively equivalent substrate output (Day-1 RLS parameterised by tenancy, wizard-equivalent setup-time invariant pinning for auth/payments/jobs/DB/framework, non-toggle-able gates, migration-between-choices CI) inside a single long-running session without Keel.
- **Governance response (already in place):** the 12-month / 2-product kill criterion (Business Success) and the M4 checkpoint ritual (Journey 2) are the primary governance responses to this risk — both force an explicit keep-or-archive decision against real shipped-product signal rather than sunk-cost preservation.
- **Mitigation principle (not stack):** what survives substrate absorption is the principle layer — YAGNI, DRY, NIH-refusal, invariants-beat-conventions, and the documented rationale behind the seven load-bearing axes — not the specific stack choices. Keel's internal docs preserve the *why* so the next substrate (or an agent recreating it) inherits the reasoning even if the code is obsolete.
- **Triggering signals to watch:** an agent reliably producing a green 60-minute integration test from a blank starter inside one context window; Bmalph-class orchestration tools shipping substrate defaults; a major model release explicitly marketed as "SaaS-ready out of the box."

## Innovation & Novel Patterns

### Detected Innovation Areas

Keel's innovation is not in individual stack choices (Postgres, Tailwind, OpenTelemetry are boring on purpose). Innovation lives in *the wizard-pinned discipline applied to a bounded catalogue of boring stacks* and in the meta-framework composition:

1. **Setup-time invariant pinning (core novelty).** Wizard answers at scaffold time materialise into `keel.config.ts` + generated substrate invariants, frozen post-setup. Agents see the config as invariants — they cannot re-litigate a choice the wizard pinned. Competing boilerplates (Makerkit, ShipFast, Supastarter) are configurable at runtime / convention-based; Keel is configurable at setup-time then frozen. This is the axis on which Keel differs from the $199-$299 tier.
2. **Agent-coherent scaffolding.** The wizard, generator, and invariants-sync gate compose into a scaffolding model where agent context (`CLAUDE.md` + `INVARIANTS.md`) is always consistent with the generated substrate code. Fork-time variance does not leak into agent confusion because every fork has a single frozen config agents can load.
3. **Day-1 RLS as generator output.** RLS policies are parameterised over the wizard-chosen tenancy model (team / user / org) and emitted by the generator. Appears novel for this class of boilerplate: verified against Makerkit, ShipFast, Supastarter, SaaS Pegasus, Bullet Train, Nextacular, Chadnext — none ship RLS Day-1 let alone tenancy-parameterised RLS. Long-tail indie substrates not exhaustively swept.
4. **Non-toggle-able quality gates + forkability.** Four-layer gates cannot be disabled via config regardless of wizard choices. To remove a gate, fork. Governance choice: "permissibility of change" is encoded at the source layer, not the config layer.
5. **CI-tested migration-between-choices guides.** Swap paths between wizard options (TanStack ↔ Next.js; better-auth ↔ Auth.js ↔ Clerk; Prisma ↔ Drizzle; Paddle ↔ Stripe; team ↔ user ↔ org tenancy) run quarterly through CI; stale guide = red build. Docs as executable artefacts; every wizard option shipped alongside its exit path.
6. **Meta-framework composition (BMad + Ralph + Keel + Claude Code).** No known competing project ships this specific chain: planning contracts → autonomous loop → wizard-pinned substrate → agent runtime.

### Market Context & Competitive Landscape

Closest adjacencies: Bmalph / vibesparking (orchestration-only); Antigravity skill packs (skill layers, no substrate); Makerkit / ShipFast / Supastarter (human-optimised boilerplates, commoditised at $199–$299, typically Stripe-first, no agentic affordances, no setup-time invariant pinning — their configurability is runtime / convention, not scaffold-time-then-frozen). See `_bmad-output/planning-artifacts/research/` for competitive detail. Hedged: "verified empty" reflects first-page-of-Google + known-community scan; long-tail indie GitHub substrates labelled "agent-ready saas starter" or "claude-optimised boilerplate" not exhaustively swept. The wizard-pinned-invariants pattern itself is the defensible novelty; individual wizard-selectable libraries are boring on purpose.

### Validation Approach

Each innovation area has a specific validation gate:

| Innovation                       | Validation Gate                                                                                      |
|----------------------------------|------------------------------------------------------------------------------------------------------|
| Setup-time invariant pinning     | `pnpm keel:configure --migrate` path proven on ≥ 1 wizard-option swap within 6 months of 1.0         |
| Agent-coherent scaffolding       | RIAR ≥ 70% sustained across forks with >1 distinct wizard-chosen stack                               |
| Substrate-as-category            | 2-4 products shipped on Keel within 12 months (archive threshold)                                    |
| Day-1 RLS parameterised          | Pre-M1 tenancy-template spike converges in ≤ 1 day for each of team / user / org                     |
| Non-toggle-able gates            | M8 docs audit: no gate disable-able without fork, regardless of wizard choices                       |
| CI-tested migration guides       | Red build on first quarterly run at month 3 post-1.0                                                 |
| Meta-framework composition       | RIAR ≥ 70% on first fork                                                                              |

### Risk Mitigation

- **Category-creation hazard**: fallback positioning is "opinionated agent-authored SaaS boilerplate." No refactor required.
- **RLS complexity overflow**: downgrade affected tenancy model to Growth-tier if pre-M1 spike doesn't converge; wizard warns on selection.
- **Wizard-option library failure**: demote the option from the wizard catalogue in next major Keel version; affected forks migrate via the documented migration-between-choices path (per Domain section).
- **Meta-framework piece churn**: tested-combination documented per Keel major version; breaking model upgrade triggers a test-run release.

## Developer-Tool & CLI-Tool Specific Requirements

### Project-Type Overview

Keel is primarily a **developer_tool** (SaaS substrate shipped to developers) with a **cli_tool** surface exposed via pnpm scripts. The single host-side user surface is `pnpm <subcommand>`, which proxies to the Keel CLI (`keel.py`, uv-runnable — first-class 1.0 surface) that manages the devbox container, runs the setup wizard, and forwards commands. Users never type `docker`, `docker compose`, `ssh`, or raw `uv` commands — pnpm is the idiom. Keel produces product instances in one of four shapes (SaaS-B2B default, Marketplace, B2C consumer-app, API-first) as selected by the setup wizard. Shape + other wizard choices pin the substrate invariants at scaffold time and are frozen post-setup; the cross-cutting concerns (multi-tenancy, RBAC, subscriptions, integrations) are wizard-configurable with opinionated defaults. Wizard details live in the Wizard & Configuration subsection below.

### Developer-Tool Surface

**Language support.** TypeScript only. No polyglot targets — Python / Go / Rust SDKs are explicitly out of scope. Rationale: single-language typing across the tRPC (or shape-activated public API) boundary is a first-principles substrate commitment.

**Package manager.** `pnpm` only. Monorepo uses `pnpm workspaces` + Turborepo; alternative package managers (npm, yarn) are not supported because of workspace semantics. CI fails builds that use other managers.

**Installation methods.** Two paths at 1.0, both running the setup wizard:

1. `pnpm dlx create-keel-app <project-name>` — scaffolding CLI; launches a transient devbox and runs the interactive wizard; commits `keel.config.ts` into the new repo's first commit.
2. `git clone` fork followed by `pnpm keel:init` — for teams that prefer to clone-then-customise; the unconfigured repo refuses other commands until the wizard has run.

Non-interactive mode is supported on both paths via flags (`--shape=saas_b2b --auth=better-auth ...`) or `--from-config <file>` for reproducible / agent-authored scaffolds.

No `npm publish` of individual packages. Fork-and-use model; packages are not distributed as standalone libraries.

**Prerequisite: Docker Desktop** (or equivalent Linux Docker runtime). The devbox is a non-toggle-able invariant; fresh forks run a first-run check that fails with a pointer to install instructions.

**API surface (developer-facing).** Substrate packages expose typed exports; the substrate ships every wizard-option implementation behind the relevant adapter, and the generator prunes unselected implementations at scaffold time:

- `packages/core/auth` — adapter surface + wizard-option implementations (better-auth default, Auth.js, Clerk); wrapped with `requireRecentAuth` middleware regardless of choice.
- `packages/billing` — shape-aware billing adapter; wizard-option implementations (Paddle default, Stripe Connect for marketplace, Stripe standard for API-first) + typed webhook registry.
- `packages/jobs` — pg-boss typed job registry (default); Growth-tier alternatives scaffold behind the same adapter.
- `packages/email` — Resend wrapper + baseline templates (default); Growth-tier alternatives scaffold behind the same adapter.
- `packages/core` — `tenantGuard()` session-variable setter keyed on `app.current_tenant_id`; tenancy-model-parameterised (team / user / org).
- `packages/contracts` — tRPC contract definitions; API-first shape additionally activates OpenAPI-generated public contracts.
- `packages/flags` — server-side flag evaluator (route-loader scope for wizard-chosen framework).
- `packages/audit` — append-only audit log schema + helpers.
- `packages/db` — Prisma client default + RLS-aware extension; Drizzle implementation behind the same interface for wizard-time selection.
- `packages/ui` — Tailwind-based primitives.
- `packages/keel-invariants` — shared tsconfig-base, ESLint config, Prettier, commitlint rules, prek hooks, import-boundary rules. Contents are **partially generated** from `keel.config.ts` at scaffold time (FR66-FR68). Consumed by every other substrate and product package.
- `packages/keel-wizard` — wizard engine, choice catalogue schema, validation rules, non-interactive flag parser, migration-between-choices driver. Consumed by `pnpm dlx create-keel-app`, `pnpm keel:init`, `pnpm keel:configure`.
- `packages/keel-templates` — per-wizard-option template snippets consumed by the generator; seed `PROMPT_*.template.md` files used at 1.0 cut.

**Code examples.** The fresh fork (wizard-default output) is the canonical example. No separate example/tutorial app ships. Pre-seeded data + baseline Paddle sandbox subscription make the default fork immediately demonstrable; shape-specific forks (marketplace, B2C, API-first) are demonstrable with their own shape-appropriate seed data.

**Migration-between-choices guides (the former "unstub guides").** At 1.0, CI-tested quarterly for every wizard choice with more than one option: TanStack Start ↔ Next.js; better-auth ↔ Auth.js ↔ Clerk; Prisma ↔ Drizzle; Paddle ↔ Stripe; team ↔ user ↔ org tenancy. Additional axes (new wizard options shipped in 1.1+) ship with their own guides at the same CI cadence. Guides drive the `pnpm keel:configure --migrate <option>` path.

**IDE integration.** None shipped. Keel assumes Claude Code / Cursor / equivalent as the primary development environment — the agentic workflow is the IDE.

### CLI-Tool Surface

**Architectural rule.** Every host-side command is invoked as `pnpm <subcommand>`. The `package.json` scripts proxy to `uv run keel.py <subcommand>`; Python is the implementation, pnpm is the interface. Users never type `uv` or `python` directly.

**Host-side commands (proxy to container or manage lifecycle):**

| Command                                   | Effect                                                                                                                        |
|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `pnpm dlx create-keel-app <name>`         | Scaffolding CLI (1.0). Launches transient devbox, runs setup wizard interactively (or non-interactively via flags / `--from-config`), commits `keel.config.ts` into the new repo's first commit. |
| `pnpm keel:init`                          | Runs the setup wizard on an unconfigured cloned repo. Refuses to run if `keel.config.ts` already exists.                     |
| `pnpm keel:configure`                     | Re-runs the wizard against the current `keel.config.ts`. Changes to already-materialised choices require `--migrate <option>` which invokes the relevant migration-between-choices guide. |
| `pnpm keel:configure --dry-run`           | Emits the prospective `keel.config.ts` diff without materialising. Growth-tier polish; 1.0 ships read-only preview.           |
| `pnpm keel:doctor`                        | Validates that `keel.config.ts` is in sync with the generated invariants (packages/keel-invariants/, tsconfig, eslint, prek). Fail-closed on drift; mirrors the pre-merge gate. |
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
| `pnpm rls:explain <query> --tenant=<id>`    | RLS policy debugger (Tier 1). DB-bound; must run inside container network. |

**Devbox scope.** Per-fork by default — each Keel fork gets its own container mounted against that fork's workspace only. `KEEL_DEVBOX_SHARED=true` in `.envrc` enables shared-devbox mode (one container, parent-directory mount) for N=1 dogfooders matching the current `cc-devbox` pattern.

**Claude authentication.** Lives inside the devbox persistent volume (`/home/dev/.claude/`), not on the host. First `pnpm claude` invocation per devbox triggers OAuth; the URL is surfaced to the host; user completes OAuth in host browser; session persists in the container volume. CI and headless escape hatch: `ANTHROPIC_API_KEY` env var pass-through (Tier-2 deviation path, not the default UX).

**Output formats.**

- Ralph: Textual TUI (interactive) + `.ralph/logs/` (stream-json persisted) + `.ralph/halt` (JSON halt signal).
- Scaffolding: plain-text status + exit code.
- RLS debugger: structured table (which policies fired, which rows filtered).

**Config method.** Per-invocation flags + per-project `.ralph/` dotfiles (`PROMPT_build.md`, `PROMPT_plan.md`, `@plan.md`). No global user-level config. Per-project stance is deliberate.

**Ralph command flags (inherited from absorbed Ralph harness):** `--timeout`, `--max-iterations`, `--permission-mode`, `--max-budget-usd`, `--fallback-model`, `--effort`.

**Shell completion.** Not shipped at 1.0. Growth-tier candidate.

### Implementation Considerations

- **Defaults vs wizard choice policy**: every core substrate concern (auth, DB, framework, billing, jobs, email, tenancy, deploy target, shape, analytics, error tracking, cookie banner, locales, OTel exporter, project identity) is a wizard-selectable choice with a sensible default. Post-wizard, the config is frozen and materialised into substrate code; agents see the config as invariants. The "adapter vs hardwire" distinction is collapsed — every core concern is implemented as an adapter whose selected implementation is pinned at scaffold time.
- **Boundary enforcement**: ESLint `no-restricted-imports` + TypeScript project references prevent cross-package imports that violate the package topology. Compile-time, not review-time. Rules are generated from `keel.config.ts` so boundaries reflect the wizard-chosen package topology.
- **Distribution**: zero npm-publish; GitHub release via release-please is the distribution channel. Fork-and-use model assumes forkers track upstream. Upstream wizard-option additions surface as new available choices without changing the fork's frozen selections.
- **Terminology — migration-between-choices vs Tier-2 deviation path**: *Migration-between-choices* applies to swaps **within the wizard catalogue** (e.g., better-auth → Auth.js, Paddle → Stripe); 1.0 ships CI-tested guides for every such axis. *Tier-2 deviation path* applies to exits **outside the wizard catalogue** (e.g., ASVS Level 2+ compliance posture, stateless-JWT sessions, signed cryptographic attestation, horizontal scaling by worker-process extraction, raw `ANTHROPIC_API_KEY` pass-through). Deviation paths are documented but not wizard-surfaced; forks choosing them accept divergence responsibility.

### Wizard & Configuration

The setup wizard is the first-class entry point to any Keel repo and the canonical source of invariant values. This subsection pins the 1.0 contract; the architecture doc will resolve implementation detail.

#### Invocation model

| Entry point                            | Mode                       | Context                                                                                       |
|----------------------------------------|----------------------------|-----------------------------------------------------------------------------------------------|
| `pnpm dlx create-keel-app <name>`      | Interactive (default) / flags / `--from-config` | Fresh scaffold. Creates new repo, launches transient devbox, runs wizard, commits `keel.config.ts` + generated substrate in one commit. |
| `pnpm keel:init`                       | Interactive / flags / `--from-config` | Unconfigured clone. Blocks all other `pnpm keel:*` / `pnpm ralph:*` commands until wizard completes. |
| `pnpm keel:configure`                  | Interactive / flags        | Configured fork. Reads current `keel.config.ts`, presents current values as defaults, requires `--migrate <option>` to change already-materialised values. |
| Non-interactive `--from-config <file>` | Any of the above           | Pass pre-authored `keel.config.ts`. Skips prompts; validates; materialises. Required for CI scaffolds and agent-authored fork creation. |

#### Wizard choice catalogue (1.0)

Each axis: default (**bold**), 1.0 alternatives, shape-gated availability, validation notes.

| Axis                | Default & 1.0 options                                                   | Shape-gated?                       | Notes                                                                                      |
|---------------------|-------------------------------------------------------------------------|------------------------------------|--------------------------------------------------------------------------------------------|
| Product shape       | **saas_b2b** / marketplace / b2c / api_first                            | Shape drives downstream gating     | Shape choice constrains billing, tenancy, surface-area.                                    |
| Auth library        | **better-auth** / auth-js / clerk                                       | All shapes                         | All three provide DB-backed sessions + step-up middleware.                                 |
| DB / ORM            | **prisma-postgres** / drizzle-postgres                                  | All shapes                         | Postgres is the only supported DB at 1.0; ORM is the wizard choice.                        |
| Framework           | **tanstack-start** / nextjs                                             | All shapes                         | Both support server-side flag eval in route loaders.                                       |
| Billing             | **paddle** / stripe-standard / stripe-connect                           | paddle & stripe-standard: saas_b2b, b2c, api_first. stripe-connect: marketplace required. | Wizard rejects `shape = marketplace` with `billing != stripe-connect` (Paddle MoR cannot pay third-party sellers). |
| Jobs                | **pg-boss** (only option at 1.0)                                        | All shapes                         | Alternatives are Growth-tier.                                                              |
| Email               | **resend** (only option at 1.0)                                         | All shapes                         | Alternatives are Growth-tier.                                                              |
| Deploy target       | **self-host** / vercel / fly / railway                                  | All shapes                         | Changes generated CI workflows + Dockerfile base.                                          |
| Tenancy model       | **team** / user / org                                                   | All shapes; b2c defaults to user   | Drives RLS template (session variable, policy shape). b2c shape overrides default to user. |
| Analytics           | **none** / posthog / plausible                                          | All shapes                         | Shipped as opt-in SDK integration hook points.                                              |
| Error tracking      | **none** / sentry / glitchtip                                           | All shapes                         | Shipped as opt-in SDK integration hook points.                                              |
| Cookie banner       | **none** / basic-consent-banner                                         | All shapes                         | Growth-tier UX polish; 1.0 ships the basic option.                                          |
| Extra locales       | **none beyond English baseline** / comma-separated locale list          | All shapes                         | English baseline is always present; additional locales scaffold empty translation files.   |
| OTel exporter       | **localhost** / OTLP-endpoint-URL                                       | All shapes                         | Configurable endpoint; OTel itself is non-toggle-able (NFR32).                              |
| Project identity    | Name, slug, default domain placeholder                                  | All shapes                         | Always required. No default; wizard prompts unconditionally.                                |

Growth-tier: additional options per axis (more auth libraries, more frameworks, more ORMs, more job runners, more email providers, more deploy targets, SSO integration, audit-log shipping).

**Single-option axes at 1.0** (Jobs = `pg-boss`, Email = `resend`) are elided from interactive prompts to avoid degenerate confirmation steps; they still appear in `keel.config.ts` with the sole supported value so Growth-tier additions slot into the existing schema without a migration.

#### Validation rules

Wizard surfaces invalid / questionable combinations at wizard time (not at first test). Two classes:

**Rejection-class** (block scaffold creation, no override):

- `shape = marketplace` with `billing != stripe-connect` → rejected (Paddle MoR cannot pay third-party sellers; Stripe standard does not handle platform payouts).
- `shape = b2c` with `tenancy = org` → rejected (B2C consumer apps do not have organisation-scoped tenancy; `team` or `user` expected).
- `extra locales` including `en` → rejected (English is baseline; don't duplicate).

**Warning-class** (require explicit user confirmation, blockable in non-interactive mode without `--accept-warnings`):

- `shape = api_first` with `billing = paddle` → warning (Paddle can bill API customers but rate-limiting / quota integration is better with Stripe usage-based).
- `deploy target = vercel` with `framework = tanstack-start` → warning (Vercel hosts TanStack Start but not natively optimised; Growth-tier polish will sharpen).

Silent-proceed-past-warning is forbidden (NFR35); non-interactive runs without `--accept-warnings` fail closed on warning-class combinations as well.

#### Re-runnability & migration path

- First-run materialisation: irreversible without `--migrate`. Config values that have substrate code generated from them (auth, DB, framework, billing, jobs, email, tenancy, shape) cannot change via plain `pnpm keel:configure`.
- `pnpm keel:configure --migrate <option>` path: invokes the relevant migration-between-choices guide (M8 deliverable). Guide is a sequence of codemods + manual steps; runs inside the devbox; updates `keel.config.ts` and regenerates substrate in a single commit.
- Non-materialised values (extra locales, analytics provider, error tracking, cookie banner, deploy target, OTel exporter endpoint, project identity) can change via plain `pnpm keel:configure` with no `--migrate` flag needed; the generator re-emits affected files.

#### Generated artifacts

The generator emits (deterministic, idempotent, content-hashed):

- `packages/keel-invariants/*` — tsconfig-base, ESLint config, Prettier config, commitlint rules, prek hooks, import-boundary rules.
- `packages/keel-invariants/invariants.manifest.ts` — the typed manifest consumed by the sync-enforcement gate (see Invariants §).
- Substrate adapter selection — `packages/{core/auth,billing,jobs,email,db}/` have their wizard-unselected implementations pruned by the generator at scaffold time so the shipping substrate contains only the chosen path plus adapter surface.
- `CLAUDE.md` wizard-choice block — generated section referencing `keel.config.ts` so agents load the current fork's pinned choices into context.
- `INVARIANTS.md` config-derived entries — the tenancy, shape, auth, and billing sections reflect the wizard's frozen answers.

#### Wizard schema versioning

The wizard choice catalogue is versioned per major Keel release. `keel.config.ts` carries a `schemaVersion` field; the wizard validates the file against the matching schema and refuses to run if versions mismatch. Schema upgrades across major Keel versions are handled by the migration-between-choices guide mechanism.

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach: Platform MVP.** Keel is not a problem-solving MVP (the problem is well-understood from N=1 experience), not an experience MVP (no end-users interact with the substrate directly), and not a revenue MVP (one paying customer is a functional test, not a growth milestone). Validated learning = 2-4 real products shipped on Keel within 12 months of 1.0; failure to hit 2 within 12 months archives the substrate per Kill Criterion.

**Resource Requirements.** N=1 (Tthew) + agentic workforce (Ralph + Claude Code). Required skills: TypeScript, Postgres/SQL, system design, prompt craft, wizard UX / interactive-CLI design. Time budget: 48 focused days (see Product Scope M0-M9 with M0.5 devbox, M0.6 Keel CLI + wizard, M0.7 config-as-invariants plumbing, and per-choice parameterisation of M1/M2/M3/M7/M8/M9); realistic first-slip budget 48-52 days. The 22-day increase over the pre-pivot 26-day plan is absorbed entirely by wizard + config-as-invariants scope and per-choice parameterisation. Compression absorbed by M7-M9 (docs polish, CI hardening, wizard-path smoke matrix).

### MVP Feature Set (Phase 1 — Keel 1.0)

Milestones M0-M9 (including M0.5) are fully enumerated in Product Scope. This section maps user journeys to MVP-critical milestones:

| Journey                         | MVP-critical?                  | Milestones required                     |
|---------------------------------|--------------------------------|-----------------------------------------|
| J1 Product #2 happy path        | Yes — validates T2NP           | M0-M4, M0.6, M0.7, M9                   |
| J2 M4 checkpoint ritual         | Yes — governance invariant     | M8 (checkpoint doc)                     |
| J3 Agent iteration              | Yes — validates RIAR           | M0-M4, M0.5, M0.6, M0.7, M9 + harness   |
| J4 Marcus peer fork             | Yes (CLI promoted to 1.0)      | M0.6 (scaffolding CLI), M0.7, M8, M9    |

**Must-have capabilities for 1.0:**

- Fork-clone produces a green 60-minute integration test (M0, M9), matrix-tested across wizard shape × billing.
- Devbox container as non-toggle-able execution environment (M0.5).
- Keel CLI + setup wizard as first-class 1.0 surface with interactive, flag-driven, and `--from-config` modes (M0.6). Non-negotiable core requirement.
- Scaffolding CLI `pnpm dlx create-keel-app` at 1.0 — promoted from Growth-tier (M0.6).
- Config-as-invariants plumbing: `keel.config.ts` schema + idempotent generator + sync-enforcement pre-merge gate (M0.7). Non-negotiable core requirement.
- Day-1 RLS invariant enforced at database layer, parameterised over wizard tenancy model (M0.7, M1).
- Wizard-pinned auth / billing / jobs / email / framework / DB with default-quick-start path matching the pre-pivot hardwired stack (M2-M4, M7).
- Non-toggle-able four-layer quality gates with Ralph backpressure (M9), applied identically regardless of wizard choices.
- CI-tested migration-between-choices guides for every wizard axis with >1 option: TanStack Start ↔ Next.js; better-auth ↔ Auth.js ↔ Clerk; Prisma ↔ Drizzle; Paddle ↔ Stripe; team ↔ user ↔ org (M8).
- In-repo M4 checkpoint document structure (M8).
- Internationalization framework wired into wizard-chosen framework with English baseline locale and typed-key enforcement (M7). Non-negotiable core requirement.
- Per-iteration security verification with structured evidence: secret scan, dependency audit, SAST, prompt-injection scan; findings block commit; evidence persisted to `.ralph/logs/` (M0 + M9). Non-negotiable core requirement.
- Invariants stack at M0 + M0.7: machine-enforced package (`packages/keel-invariants/`, partially generated from `keel.config.ts`) + agent-readable `INVARIANTS.md` + documentation layer + sync pre-merge gate covering both manifest drift and config-to-generator-output drift.
- `gh` CLI authentication inside devbox volume with first-run prerequisite check that halts Ralph cleanly if auth is missing (M0.5). Prerequisite for autonomous push and PR creation.
- Wizard validation fails-closed on incompatible combinations at wizard time, not at first test (M0.6). Non-negotiable core requirement.

### Post-MVP Features

**Phase 2 (Growth, months 1-6 post-1.0):**

- Expanded wizard choice catalogue per axis (auth, framework, ORM, jobs, email, deploy target) + each addition accompanied by its own migration-between-choices guide.
- Shape-specific Growth scaffolds: marketplace dispute / ratings / payouts; B2C freemium / referrals / push; API-first developer portal / sandbox / GraphQL.
- Wizard UX polish: `--dry-run` preview mode; richer incompatible-combination hints with suggested fixes; visual TUI refresh.
- Shell completion for the pnpm-exposed command set.
- Headless Ralph mode (`--no-tui` or equivalent) for CI scenarios.
- Independent package versioning via release-please-monorepo if a package is extracted as a standalone library.
- SSO adapter (SAML / OIDC beyond Google OAuth) as a wizard option for regulated forks.

**Phase 3 (Expansion — dogfood-first):**

- Meta-framework formalisation across BMad + Ralph + Keel + Claude Code.
- Product-count milestone: 2-4 products shipped on Keel within 12 months of 1.0.
- Adoption signaling (blog post, peer-community share) — permitted but not planned.

### Risk Mitigation Strategy

**Technical Risks:**

- *Day-1 RLS policy matrix parameterised over tenancy (novel at scale)* — pre-M1 spike budgeted at ≤ 1 day per tenancy model (team / user / org = up to 3d). If the matrix does not converge in a day per model, that tenancy option downgrades to Growth-tier and the wizard warns on selection. Accepted tradeoff.
- *Wizard choice-combination explosion* — N axes × M options per axis generates a combinatorial test space. Mitigation: 1.0 CI matrix covers (a) all defaults, (b) every single-axis non-default (vary one axis at a time), and (c) a sampled cross-section of multi-axis combinations keyed to shape-specific requirements. Full-matrix Cartesian testing is Growth-tier.
- *Correlated-library risk across wizard options* — each wizard-selectable library carries its own maintenance risk; two load-bearing defaults (TanStack Start, better-auth) also carry correlated-community risk at 1.0. Migration-between-choices guides (M8) run quarterly through CI for every axis with >1 option. If any wizard-option library's maintenance signal drops below the policy threshold (see Domain §), the next major Keel version demotes that option from the wizard catalogue.
- *Generator idempotency + drift-detection complexity* — the generator is required to be deterministic and content-hashed so the sync gate can detect drift. Mitigation: treat the generator as a load-bearing substrate package (`packages/keel-generator`) with its own test suite and boundaries.
- *60-minute CI test engineering across the wizard matrix* — known first-slip candidate (4 planned days for M9 → 6-8 real). Compression absorbed by M7-M9; last-mile compression if needed is to reduce the M9 sampled-cross-section from "every shape × billing" to "each shape with its required billing + the default combination."
- *Devbox cold-start and image size (~3.5 GB per cc-devbox baseline)* — affects Ralph iteration startup time on first invocation. Mitigation: persistent container across Ralph invocations; rebuild only on Dockerfile diffs; document pre-warming as an operational tip.
- *Bootstrap handoff at M0.5 + M0.6 + M0.7* — the cc-devbox → `packages/devbox/` migration + new wizard + config-as-invariants plumbing all land mid-build. If any of the absorbed/new pieces fails, Keel's own build stalls. Mitigation: keep standalone `cc-devbox` functional on a `legacy-devbox` branch until after the M4 checkpoint; keep the wizard engine (M0.6) independently testable against a stub generator so M0.7 can land afterward.
- *Wizard-time validation soundness* — incompatible-combination rejections must be comprehensive, or wizard-invalid configs leak into the generator. Mitigation: validation rules live in `packages/keel-wizard/` alongside property-based tests; every rejection rule is both documented in the Wizard § and tested.
- *Security-verification overhead in the Ralph loop* — running SAST + secret scan + dependency audit + prompt-injection scan per iteration adds ~30-60s per iteration at typical scanner speeds and may trigger false-positive halts. Mitigation: configurable severity threshold tuning per scanner category (architecture doc), cache unchanged-file scan results across iterations; recurring false-positive categories force an upstream scanner-config fix rather than an escape hatch.

**Market Risks:**

- *Substrate-as-category may not stick* — fallback positioning is "opinionated agent-authored SaaS boilerplate." No refactor required; existing artifacts remain valid.
- *Adoption path beyond N=1 is undefined* — accepted per scratch-your-own-itch thesis. Distribution is explicitly out of scope and belongs to a separate follow-on project.

**Resource Risks:**

- *26 → 33-36 day slip* — governed by M4 checkpoint ritual (mid-build decision: push M5-M9 or pause and ship real product on partial substrate).
- *Sustained > 15 hrs/month maintenance post-1.0* — triggers scope-cut or archive. Expected steady-state 5-10 hrs/month.
- *Procrastination via perfecting-substrate-instead-of-shipping-product* — governed by the 12-month / 2-product kill criterion.
- *Docker Desktop prerequisite gates fresh forkers without Docker installed* — devbox is Tier-1 invariant, not optional. Mitigation: fresh-fork first-run check fails with a clear pointer to install instructions; no graceful degradation to non-containerised Ralph.

## The Line: Keel Development vs Development with Keel

Keel is self-hosting — the meta-framework used to build Keel is the framework Keel ships. Post-1.0, the practical question for any Keel repo is not "which framework are we using" (it's always BMad + Ralph + Keel + Claude Code, with wizard-chosen stack pinned in `keel.config.ts`) but "what mode of work is this change"?

### Three modes

1. **Development with Keel** — product code only. `apps/web/features/*`, product-specific schemas, product tests. Upstream rebase is by-design safe; package boundaries (enforced at compile time) prevent drift.
2. **Keel development via fork** — substrate code on your own fork. `packages/*`, `keel.py`, substrate CI, migration-between-choices guides. You own divergence. Upstream rebase may conflict.
3. **Keel development proper** — substrate changes intended to flow upstream. PR to the upstream Keel repo.

### Where the line lives

| Dimension    | The line                                                          |
|--------------|-------------------------------------------------------------------|
| Physical     | Substrate: `packages/*`, `keel.py`, `keel.config.ts` (schema), `docs/migrations/*`, `packages/keel-templates/*`, `packages/keel-wizard/*`, substrate CI workflows. Product: `apps/web/features/*`, product schemas, product tests. No ambiguous middle. |
| Temporal     | The 1.0 cut ritual. Before cut: only Keel-development exists. At cut: archival + template seeding draws the line. After cut: every fresh fork starts in "development with Keel" by default. |
| Enforceable  | Compile-time (ESLint `no-restricted-imports` + TypeScript project references); CI path-based gate routing; convention. |

### State categories

| Category             | Location                        | Scope        | Behaviour on fork                                       |
|----------------------|---------------------------------|--------------|---------------------------------------------------------|
| Substrate source     | `packages/*`, `keel.py`         | Shared       | Inherited unchanged; upstream rebases cleanly.          |
| Wizard-pinned config | `keel.config.ts` (root)         | Per-fork     | Frozen at fork setup; preserved on rebase; upstream-added wizard options become available but don't alter fork's existing choices. |
| Generated invariants | `packages/keel-invariants/*`    | Per-fork     | Regenerated from `keel.config.ts` at build time; idempotent; rebase conflicts resolved by re-running the generator. |
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
- **M0.5 landing**: `packages/devbox/` and `keel.py` take over; standalone `cc-devbox` and `ralph.py` become deprecated-but-still-functional.
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
- **Tenant isolation at database layer** — RLS on every tenant-scoped table, parameterised over wizard-chosen tenancy model.
- **Non-toggle-able quality gates** — apply equally to agent-authored and human-authored commits regardless of wizard-chosen stack.
- **Secrets never committed** — pre-commit gate rejects known secret patterns.
- **Dependency audit** — Dependabot or equivalent blocks merges with critical vulnerabilities.
- **Audit log append-only** — security-relevant events persisted immutably.
- **Wizard-time security validation** — the wizard rejects scaffold-time combinations that break substrate security baselines (e.g., `shape = api_first` without a billing option that supports rate-limit-bound usage quotas generates an incompatible-combination warning; forks that bypass the wizard and hand-author `keel.config.ts` hit the same validation at `pnpm keel:doctor` time).

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

A pre-merge quality gate verifies the three layers don't drift. If `packages/keel-invariants/` changes without a corresponding `INVARIANTS.md` change, the build fails. The same gate additionally covers the config → invariants generator path: `keel.config.ts` edits without matching generator output also fail the build (see Config-as-invariants below).

**Mechanism sketch (PRD-level commitment; implementation details deferred to architecture doc):**

- **Manifest contract.** `packages/keel-invariants/` exports an `invariants.manifest.ts` enumerating every rule as a typed record with a stable ID, a human-readable title, the enforcement layer (lint / typecheck / commit-hook / pre-merge / pre-deploy), and a content hash over the rule's normalized machine-readable definition (e.g., the ESLint rule body, the tsconfig stanza, the prek-hook config).
- **Documentation anchors.** `INVARIANTS.md` addresses each invariant by the same stable ID using an anchored heading (e.g., `### <invariant-id> — <title>`). The `docs/invariants/*.md` per-invariant narrative files reference the same IDs.
- **Sync check.** A pre-merge script reads the manifest, walks the three layers, and fails the build on any of: (a) an ID in the manifest that is missing an anchor in `INVARIANTS.md`; (b) an anchor in `INVARIANTS.md` with no corresponding manifest entry (orphaned documentation); (c) a manifest entry whose content hash has changed without a matching `INVARIANTS.md` edit in the same PR.
- **Why these three signals.** Addition drift fails (a); removal drift fails (b); edit drift fails (c). No other drift mode exists between layers.
- **Architecture-doc follow-up:** the hashing algorithm, CI hook placement, Ralph-backpressure integration, and the handling of transitively-generated rules (e.g., one ESLint rule expanded from a higher-level policy declaration) are architecture-doc territory.

### Config-as-invariants

`keel.config.ts` at the repo root is the source-of-truth for all wizard-pinned choices (shape, auth, DB, framework, billing, jobs, email, tenancy, deploy target, locales, analytics, error tracking, cookie banner, OTel exporter, project identity). Substrate packages and `packages/keel-invariants/` consume it at build/lint/gate time. The generator regenerates downstream files (ESLint config, tsconfig-base, commitlint config, prek hooks, import-boundary rules, `INVARIANTS.md` wizard-derived blocks, `CLAUDE.md` wizard-choice block, `invariants.manifest.ts`) whenever the config changes.

**Drift detection.** The sync-enforcement gate is extended to cover the config → invariants path. Failure modes:

- `keel.config.ts` changed without a corresponding regenerated output (addition, edit, removal on any wizard axis) → build fails.
- Generator output changed without a `keel.config.ts` change of equal scope → build fails (prevents hand-edited generator output shipping alongside stale config).
- `keel.config.ts` schema version does not match the wizard-schema version shipped by the current Keel major → build fails with a pointer to the wizard-schema migration path.

**Re-generation contract.** Running `pnpm keel:doctor --fix` (or the implicit regeneration step in `pnpm keel:configure`) is idempotent: re-running against an already-synchronised repo produces no diff. Content-hashing each generated artefact guards against silent divergence.

**Post-setup change policy.** Wizard-pinned values that have substrate code generated from them (auth, DB, framework, billing, jobs, email, tenancy, shape) cannot change via plain `keel.config.ts` edit. The only sanctioned path is `pnpm keel:configure --migrate <option>`, which runs the relevant migration-between-choices guide (FR48/49), updates `keel.config.ts`, and regenerates substrate in a single commit. Hand-editing `keel.config.ts` to change one of these values without the migration flag fails the pre-merge gate.

**Non-materialised values** (extra locales, analytics provider, error tracking, cookie banner, deploy target, OTel exporter endpoint, project identity) can change via plain `pnpm keel:configure` with no `--migrate` flag; the generator re-emits only the affected files.

### Coverage

| Invariant                                 | Machine-enforced in                                                                                           | Agent-readable in                                      | Documented in                       |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------------|--------------------------------------------------------|-------------------------------------|
| Commit message format                     | commitlint via prek                                                                                           | INVARIANTS.md §commit                                  | docs/invariants/commit.md           |
| Security standards                        | per-iteration verification; OWASP ASVS L1 baseline                                                            | INVARIANTS.md §security                                | docs/invariants/security.md         |
| Coding standards (TS, lint, format)       | tsconfig-base + ESLint + Prettier                                                                             | INVARIANTS.md §coding                                  | docs/invariants/coding.md           |
| Repo structure / package boundaries       | ESLint `no-restricted-imports` + TS project refs                                                              | INVARIANTS.md §structure + CLAUDE.md package map       | docs/invariants/repo.md             |
| Backend technology constraints            | Substrate packages physically depend on Prisma, better-auth, pg-boss, Paddle, Resend, OTel                    | INVARIANTS.md §backend                                 | docs/invariants/backend.md          |
| Client technology constraints             | `apps/web` built on TanStack Start; UI uses Tailwind, tRPC, RHF, Zod, Zustand                                  | INVARIANTS.md §client                                  | docs/invariants/client.md           |
| Ralph prompt conventions (model-pinned)   | `.ralph/PROMPT_*.md` template contract: adaptive thinking + explicit `effort`; `thinking.display = "summarized"`; no sampling knobs; no prefills; positive examples; explicit subagent-triggering phrasing; fan-out cap invariant (1 Sonnet per build/test) | INVARIANTS.md §prompts                                 | docs/invariants/prompts.md          |
| Wizard-pinned stack choices (config)      | `keel.config.ts` + idempotent generator → `packages/keel-invariants/*`, adapter-implementation pruning, `invariants.manifest.ts`; pre-merge sync gate catches drift | INVARIANTS.md §config (generated)                      | docs/invariants/config.md           |

### Extension / override model for forks

- **Default**: forks inherit the substrate unchanged; the fork's `keel.config.ts` is the only per-fork divergence point. Upstream changes to generator logic or baseline invariants flow on rebase; upstream-added wizard options surface as newly available choices without altering the fork's frozen selections.
- **Extend**: forks author their own extension configs (e.g., `eslint.config.fork.js extends eslint.config.keel-invariants.js`). Substrate never touches these files; rebase is clean. Forks that need config values the substrate doesn't expose via the wizard extend `keel.config.fork.ts` (referenced from `keel.config.ts`) with fork-specific values.
- **Override**: forks that need to remove an invariant entirely fork `packages/keel-invariants/` — explicit substrate divergence, documented in the fork's README.
- **Agent-facing**: forks add product-specific invariants to a fork-owned `INVARIANTS.fork.md`; `CLAUDE.md` references both files alongside the wizard-generated `INVARIANTS.md` block.

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

- **FR15**: System can enforce tenant data isolation at the database layer via Row Level Security policies on all tenant-scoped tables, parameterised over the wizard-chosen tenancy model (team / user / org).
- **FR16**: Developer can set the current tenant context via `tenantGuard()` session-variable setter (keyed on `app.current_tenant_id`) inside request transactions; the setter's tenant-resolution logic is generated from the wizard-chosen tenancy model.
- **FR17**: Developer can debug RLS policy decisions for a given query and tenant context via `pnpm rls:explain`.
- **FR18**: System can enforce that new tenant-scoped tables ship with an RLS policy matching the wizard-chosen tenancy model, via CI check.

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
- **FR30**: System can run the pre-deploy 60-minute CI integration test (fresh clone → signup → team → Paddle subscription).
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

- **FR46**: Developer can fork Keel, rename, and configure project-specific values without modifying substrate package internals — all customisation flows through `keel.config.ts`.
- **FR47**: Developer can scaffold a fresh Keel-forked project via `pnpm dlx create-keel-app` (1.0 scope, promoted from Growth). The command launches a transient devbox, runs the setup wizard, and commits `keel.config.ts` + generated substrate into the new repo's first commit.
- **FR48**: Developer can migrate from a wizard-pinned choice to another option via `pnpm keel:configure --migrate <option>`, which drives the relevant CI-tested migration-between-choices guide (e.g., TanStack Start → Next.js, better-auth → Auth.js, team → user tenancy).
- **FR49**: System can run quarterly CI against each migration-between-choices guide (every wizard axis with >1 option); stale guide fails the substrate build.
- **FR50**: Maintainer can cut a Keel major version with the tested model/tooling generation combination AND the wizard schema version documented in the release notes.
- **FR51**: System can wipe residual `_bmad-output/` and `.ralph/` state on fork-scaffolding (1.0 scope), seeding empty per-project state from templates in `packages/keel-templates/`.
- **FR52**: Maintainer can archive per-version planning artifacts to `docs/archive/keel-<version>-planning/` before each major-version tag cut, leaving the shipping substrate with empty per-project state directories.
- **FR53**: System can distinguish substrate-territory commits from product-territory commits via path-based CI rules, triggering different gate profiles for each (full 60-min integration matrix + migration-between-choices CI on substrate paths; product tests only on `apps/web/features/*` paths).

### Configuration & Scaffolding

- **FR65**: Developer can scaffold a fresh Keel-forked project via `pnpm dlx create-keel-app <project-name>`, which launches a transient devbox container and runs the setup wizard inside it.
- **FR66**: Developer can run the setup wizard on an unconfigured cloned repo via `pnpm keel:init`; the command refuses to run if `keel.config.ts` already exists.
- **FR67**: Wizard can present a bounded choice catalogue (shape, auth, DB, framework, billing, jobs, email, deploy target, tenancy model, analytics, error tracking, cookie banner, extra locales, OTel exporter, project identity) with sensible defaults; pressing Enter through every prompt uses the defaults path and produces the SaaS-B2B quick-start stack.
- **FR68**: Wizard can operate in non-interactive mode via command-line flags (e.g., `--shape=saas_b2b --auth=better-auth --db=prisma-postgres`) or via `--from-config <file>` for CI scaffolding and agent-authored fork creation.
- **FR69**: System can reject incompatible wizard-choice combinations at wizard time with a clear error message (e.g., `shape=marketplace` with `billing=paddle` fails because Paddle MoR cannot pay third-party sellers).
- **FR70**: System can persist wizard answers to `keel.config.ts` at the repo root — typed, committed, source-of-truth for all downstream invariant generation.
- **FR71**: System can generate `packages/keel-invariants/` contents (ESLint config, tsconfig-base, commitlint config, prek hooks, import-boundary rules, `invariants.manifest.ts`) from `keel.config.ts` via an idempotent build-time generator; re-running against an already-synchronised repo produces no diff.
- **FR72**: Developer can re-run the wizard via `pnpm keel:configure`; choices that have substrate code generated from them (auth, DB, framework, billing, jobs, email, tenancy, shape) can only change via `--migrate <option>`, which invokes the relevant migration-between-choices guide.
- **FR73**: System can version the wizard schema per major Keel version; `keel.config.ts` carries a `schemaVersion` field validated at wizard load time; version mismatches surface as build failures with a pointer to the schema migration path.
- **FR74**: Developer can validate `keel.config.ts` is in sync with generated invariants via `pnpm keel:doctor`; the command mirrors the pre-merge drift gate and fails closed on any detected drift.

## Baseline Product Capabilities Inherited by Forks

These capabilities are pre-wired in every Keel-forked project using wizard-chosen or default implementations. Forks can extend or customise but do not need to implement them. Specific libraries named below are **quick-start defaults**; wizard-configured alternatives provide equivalent capability through the same adapter surface.

### Identity & Access

- **FR54**: End user can sign up via email+password or Google OAuth.
- **FR55**: End user can verify their email address via a Resend-delivered link.
- **FR56**: End user can create, join, leave, and be invited to teams.
- **FR57**: End user can maintain DB-backed sessions with revocation support.
- **FR58**: System can require recent auth (step-up) for sensitive actions.
- **FR59**: End user can log out of all active sessions.

### Commerce

- **FR60**: End user can subscribe to a paid plan via the wizard-chosen billing provider (Paddle default; Stripe standard or Stripe Connect available per shape). For `shape = marketplace`, end user can additionally receive payouts as a seller via Stripe Connect.
- **FR61**: System can process billing-provider webhooks for lifecycle events (subscription creation, cancellation, dunning, upgrade, downgrade; plus marketplace-specific events where applicable) with signature verification and idempotent handling.
- **FR62**: System can enforce subscription-gated access to premium capabilities (for SaaS-B2B / B2C shapes) or usage-quota-gated access (for API-first shape).
- **FR63**: Developer can extend the wizard-selected billing provider via the registered payment adapter; adapter surface is consistent across Paddle / Stripe-standard / Stripe-Connect implementations.

### End-User Localization

- **FR64**: End user can select a preferred locale; the system persists and honors the selection across sessions.

## Non-Functional Requirements

### Performance

- **NFR1**: The 60-minute CI integration test completes in under 60 minutes on a standard GitHub Actions runner. Non-toggle-able. Red build if exceeded.
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
- **NFR28**: Integration test flake rate is tracked; sustained > 2% across a 30-day rolling window triggers an M8 docs-audit review. The 2% threshold is a starting target, to be validated during the first CI-hardening cycle.

### Maintainability

- **NFR29**: Substrate steady-state maintenance (triage, fixes, upgrades) stays at 5-10 hours per month. Sustained > 15 hours/month triggers scope-cut or archive per the Business Success kill criterion.
- **NFR29a (Model-version-pinned prompt-set)**: Keel's Ralph prompt templates (`.ralph/PROMPT_build.md`, `.ralph/PROMPT_plan.md`, and `packages/keel-templates/PROMPT_*.template.md`) are pinned to a specific model generation per major Keel version. Minor Keel versions inherit the prompt-set unchanged; major Keel versions may diverge and must record the tested model generation + prompt delta in release notes. This anchors the Opus-4.6→4.7-style breaking-prompt risk to major-version cadence rather than ambient drift.
- **NFR30**: Every Keel major version documents the tested model generation (e.g., Opus 4.7), Claude Code CLI version, BMad version, and Ralph version. A breaking upstream model upgrade triggers a new major version test-run. "Breaking" is evaluated against Domain-Specific Requirements § Model and Tooling Evolution delta catalogue and includes, at minimum: extended-thinking API changes, thinking-display default flips, sampling-knob removals, tokenizer re-baselines, prefill-handling changes, instruction-following literality shifts, default subagent/tool-call spawn-rate changes, and new stop-reason introductions. Silent (non-breaking) upgrades do not trigger a major — but the policy defaults to "treat as breaking" if the delta is ambiguous.
- **NFR31**: The Invariants stack's three layers (machine-enforced, agent-readable, documented) are kept in sync by a pre-merge gate; drift between layers fails the build.

### Observability

- **NFR32**: Every request handled by a Keel-forked app emits OpenTelemetry traces correlated by request ID. Sampling rate is configurable per-deploy; exporter endpoint is wizard-configurable.
- **NFR33**: Ralph iterations emit structured stream-json logs to `.ralph/logs/` with per-iteration ID, start/stop timestamps, claude subprocess exit status, and test results.

### Configuration & Wizard UX

- **NFR34**: The setup wizard completes in under 5 minutes for the quick-start (all-defaults, Enter-through) path and under 20 minutes for fully-customised runs. Measured as wall-clock from `pnpm dlx create-keel-app` or `pnpm keel:init` launch to `keel.config.ts` committed; excludes devbox cold-start time (covered by NFR2).
- **NFR35**: The wizard fails closed on hard-incompatible validation errors — enumerated rejection-class combinations (see Wizard & Configuration → Validation rules) surface at wizard time with a clear error (not silently at first test) and block scaffold creation. Warning-class combinations surface as a clear warning and require explicit user confirmation to proceed (`--accept-warnings` in non-interactive mode); silent proceed-past-warning is forbidden. No implicit "best-effort" scaffolds from invalid configs.
- **NFR36**: The wizard schema is pinned per major Keel version. `keel.config.ts` files include a `schemaVersion`; loads against a mismatched schema fail closed with a pointer to the migration-between-choices guide for schema upgrades. This anchors wizard-schema evolution to the major-release cadence (analogous to NFR29a for prompt-sets).
- **NFR37**: The `keel.config.ts` → generated-invariants pipeline is idempotent — running the generator repeatedly against an already-synchronised repo produces no diff. Idempotency is verified by a pre-merge test that regenerates and diffs.
