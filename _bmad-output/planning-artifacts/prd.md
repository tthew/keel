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
  contentShape: saas_b2b
  projectContext: greenfield  # absorbing brownfield Ralph harness
  domain: general
  domainNotes: agentic-engineering workflow; autonomous-code-execution risk surface
  complexity: high
  ralphDisposition: fork  # monthly upstream diff review
  qualityGatePosture: non-negotiable
  architectureStatus: axes-resolved-pending-formalization
  executionModel: containerized-agent-autonomy
  securityPosture: non-negotiable
---

# Product Requirements Document - Keel

**Author:** Tthew
**Date:** 2026-04-17

## Executive Summary

Keel is an opinionated SaaS substrate built for one person (Tthew) and a small peer audience of experienced solo builders who ship SaaS ideas using agentic workflows — BMad planning, the Ralph loop, and Claude Code. The problem it solves is that shipping SaaS ideas rapidly requires decisions made once and leveraged across product bets; when those decisions live in a human's head as convention rather than in the repository as enforced invariants, each new product re-litigates infrastructure and agents spiral on questions that should already be settled. Keel's future state: the builder spends more time on-the-loop (directing, reviewing, course-correcting) and less time in-the-loop (implementing mechanically), which compounds work across forks and unlocks product bets that wouldn't justify cold-start infrastructure investment on their own.

### What Makes This Special

Three co-equal first-class principles form a causal chain. Invariants enforced at the data layer (RLS policies, import boundaries, non-toggle-able gates) enable agent coherence — agents do not re-litigate settled decisions because the decisions are enforced mechanically rather than documented conventionally. Agent coherence is the precondition for staying on-the-loop rather than babysitting agents in-the-loop. On-the-loop work then compounds across products, because decisions survive forks as invariants and do not evaporate as conventions.

Four load-bearing mechanisms implement the chain: invariants beat conventions beat docs (RLS > tenantGuard > "remember to filter"); adapter minimalism with exactly two deliberate exceptions (payments, jobs); CI-tested unstub guides as first-class artifacts (docs are features; stale guide = red build); non-toggle-able four-layer quality gates plus Ralph backpressure.

Thesis: *"Your agents are only as good as the decisions you've already made for them."* The competitive category is empty by verified research — ShipFast, Makerkit, Supastarter are human-optimised and commoditised at the $199–$299 tier; Bmalph-class tools are orchestration-only, not a deployable substrate. Keel is what they operate on.

### Execution Environment

Keel ships a Docker-based devbox (absorbed from the author's prior `cc-devbox` project) inside which Ralph, Claude Code, and all agent-authored code execution run under `--dangerously-skip-permissions` — the sandbox is what makes the flag safe. The host-side entry point is `pnpm <subcommand>`, which proxies through a thin Python CLI (`keel.py`, uv-runnable) that manages container lifecycle and forwards commands. Users never invoke Docker, docker-compose, or SSH directly.

## Project Classification

- **Project Type:** `developer_tool` / `cli_tool`, `saas_b2b` content shape
- **Domain:** `general` — agentic-engineering workflow; autonomous-code-execution risk surface
- **Complexity:** High — novel full Day-1 RLS matrix, TanStack Start + better-auth correlated-library risk, stack aging under model/tooling evolution
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

- **60-minute CI integration gate**: `git clone` → signup → team → paid Paddle subscription passes in under 60 minutes. Non-toggle-able. Red gate = broken repo.
- **Four-layer quality gates** (pre-commit / pre-merge / pre-deploy / release), non-toggle-able at config layer.
- **Ralph backpressure**: loop halts on consecutive failed tests or task-budget exhaustion.
- **Day-1 RLS invariant**: every tenant-scoped table ships with a Postgres RLS policy using `current_setting('app.current_team_id')`. Physical prevention, not convention.
- **Unstub guide CI**: quarterly runs verify migration-back paths (TanStack Start ↔ Next.js; better-auth ↔ Auth.js). Stale guide = red build.
- **Import-boundary enforcement**: ESLint `no-restricted-imports` + TypeScript project references. Compile-time, not review-time.

## Product Scope

### MVP - Minimum Viable Product (Keel 1.0)

26-day milestone plan (33-36-day realistic-slip estimate). MVP gate: Launchpad.

- **M0 Repo foundation & tooling** (2d) — pnpm workspaces, Turborepo, prek, commitlint, release-please, ESLint + TS project refs, conventional-commits enforcement.
- **M0.5 Devbox + host CLI** (3d) — absorb `cc-devbox` into `packages/devbox/`; parameterise hardcoded paths; ship `keel.py` (Python, uv-runnable); wire pnpm script topology (ralph:*, devbox:*, claude); implement auto-start logic and TUI docker-attach UX.
- **M1 Data model + RLS tenancy** (2d) — Day-1 RLS policies, `tenantGuard()` as session-variable-setter, `pnpm rls:explain` CLI.
- **M2 Auth & Identity** (3d) — better-auth hardwired, DB-backed sessions, Google OAuth + email/password, step-up auth middleware.
- **M3 Billing (Paddle)** (3d) — MoR integration, webhook processing, subscription lifecycle, adapter registered.
- **M4 Email + Jobs** (2d) — Resend integration, pg-boss typed job registry, three baseline email templates.
- **M5 Observability + Audit** (2d) — OpenTelemetry traces, append-only audit log schema.
- **M6 Feature flags** (1d) — server-side evaluation in TanStack Start route loaders.
- **M7 Frontend patterns + UI** (4d) — tRPC + react-hook-form + Zod + Zustand + Tailwind + i18n framework wired into TanStack Start (library deferred to architecture doc) with typed-key enforcement and English baseline locale.
- **M8 Docs & discipline systems** (2d) — two unstub guides (TanStack Start ↔ Next.js; better-auth ↔ Auth.js), CI-tested.
- **M9 Testing & CI hardening** (2d) — 60-min integration test, quarterly unstub CI, RLS policy tests against every migration.

### Growth Features (Post-MVP)

- **Additional unstub guides**: Clerk ↔ better-auth, Stripe ↔ Paddle, Drizzle ↔ Prisma, Vercel deploy target, Next.js migration detail.
- **Keel-flavoured scaffolding CLI**: `pnpm dlx create-keel-app` producing a fresh-forked repo with pre-configured project name, tenancy model, deploy target, and baseline seed data.
- **Scaffoldable optional addons**: analytics SDK integration hook points (e.g., PostHog, Plausible) and cookie banner / consent management. Shipped as opt-in scaffolds invoked during fork creation, not as Tier-1 substrate defaults.

### Vision (Future)

Keel 1.0 is the first codified substrate in a larger meta-framework for shipping SaaS ideas on agentic workflows. The meta-framework composes three pillars:

1. **BMad** — planning artefacts (PRD, architecture, epics, stories) as enforceable contracts between phases.
2. **Ralph** — autonomous loop harness running against committed plans.
3. **Keel** — substrate on which Ralph executes; the enforced invariants that let agents stay coherent across iterations and forks.

Vision is dogfood-first: the meta-framework is validated by Tthew shipping multiple products on it, not by external adoption. Adoption signaling (blog post, peer-community share) is permitted but not planned.

## User Journeys

### Journey 1 — Tthew: Product #2 Happy Path (validates T2NP ≤ 1 week)

**Opening.** Saturday morning, eight months after Keel 1.0 cut. Tthew has a new product idea that has been percolating for two weeks. Decision made: start it. Time-tracking begins.

**Rising action.** `git clone keel-repo product2-app && cd product2-app && pnpm install`. Fifteen minutes in, the 60-minute integration test runs green locally: signup → team → Paddle sandbox subscription, end-to-end. No stack decision re-litigated — auth is better-auth, DB is Prisma+Postgres, jobs are pg-boss, none are toggles. Product-specific work begins at minute 20.

**Climax.** Day three. First product feature (domain entity + tRPC route + UI) lands green on CI, including Day-1 RLS policy for the new table. No tenant-filter bug escapes because the policy is invariant, not convention. Claude Code has been running Ralph iterations against the story list since day one; RIAR is sitting at 78% across a rolling window.

**Resolution.** Day six. Live URL, signup working, first real user interaction recorded. T2NP for product #2: 6 days 4 hours. Target: < 1 week. Pass. The next Saturday, Tthew considers a further product idea — not because the current one is scaled, but because the cold-start tax no longer deters the attempt.

### Journey 2 — Tthew: M4 Checkpoint Governance Ritual (edge case)

**Opening.** Day 14 of the 26-day Keel 1.0 build. M1-M4 green (RLS, auth, billing, email+jobs). M5-M9 remain. Tthew opens the calendar entry for the M4 checkpoint.

**Rising action.** The question is pre-committed and specific: "Push M5-M9, or pause and ship real product on partial substrate?" Repo state tells part of the story: 60-minute integration test green; four-layer gates in place; RLS invariant enforced. What is missing: unstub guides, full observability, hardened frontend patterns. The actual signal is the 12-month/2-product kill criterion — a product idea has been deferred precisely because substrate was not ready.

**Climax.** Tthew picks "pause and ship." Substrate at ~60% of 1.0 scope but covers every load-bearing concern for the deferred product. The decision is committed as a markdown entry in the repo (not a private note). M5-M9 become Phase 1.1, scheduled post-launch.

**Resolution.** The ritual protects against its own failure mode — procrastination masquerading as finishing. The 12-month archive clock starts when the partial-Keel product ships, not when 1.0 is cut. Three months later, the shipped product forces M5 (observability) because debugging needs it — the substrate learns which unbuilt milestones are actually load-bearing vs aspirational.

### Journey 3 — Ralph / Claude Code: Agent Iteration on a Keel Repo (validates RIAR ≥ 70%)

*Departure from narrative template: state-transition arc for a non-human user.*

**Precondition state.**

- Repo at commit N with green 60-min CI, RLS policies validated, all four-layer gates passing.
- Devbox container running (auto-started by `pnpm ralph:build` if not already up); DNS whitelist active; `--dangerously-skip-permissions` safe because sandboxed.
- `.ralph/@plan.md` holds the current story: "Add email verification flow for new team invites" (story ID #42).
- Claude Code context loaded with repo invariants (better-auth, Resend, pg-boss) via `CLAUDE.md` + skill definitions.
- Ralph iteration budget: 30 minutes per iteration; 3 consecutive failures halts the loop.

**Iteration flow.**

1. Ralph (running inside the devbox) spawns `claude -p --dangerously-skip-permissions` with the story file as input. Claude reads the bind-mounted workspace, sees `packages/core/auth`, `packages/email`, and existing better-auth patterns. No decision is re-litigated.
2. Claude writes a new tRPC mutation `team.inviteWithVerification`, adds a Zod schema, creates a Resend email template, wires pg-boss to enqueue the verification send.
3. Tests run: unit (pass), integration (pass), RLS policy against the new `invite_tokens` table (fail — no policy exists yet).
4. Ralph sees the failure. Claude generates the RLS policy based on the existing pattern, re-runs.
5. All tests green. Conventional-commit message generated. Iteration commits and pushes.

**Backpressure branch (alternate path).**

If iteration 3 in a row fails the same integration test, Ralph halts via `.ralph/halt`. Next human check surfaces the halt signal.

**Success signal.** Iteration completes autonomously, contributing to RIAR ≥ 70%.

**Repository-state delta.** New mutation, new email template, new RLS policy, new pg-boss job registration — all four landing together because the substrate made all four patterns local and findable.

### Journey 4 — Marcus: Peer Agency Fork + Monthly Upstream Rebase

**Opening.** Marcus runs a three-person agency. Two client SaaS projects have shipped on Keel forks in the four months since 1.0 dropped. A new client project starts Monday.

**Rising action.** Monday morning. `git clone … my-client-proj && pnpm install && pnpm keel:scaffold`. The scaffolding CLI (Growth tier) asks for project name, tenancy model, deploy target. Marcus answers. Fresh fork is product-ready in 20 minutes.

**Climax.** End of month one. Marcus runs his standard ritual: pull upstream Keel `main`, rebase. release-please on upstream has cut 1.1.0 with one new unstub guide (Clerk ↔ better-auth), a pg-boss dependency bump, a Paddle webhook signature rotation. Rebase conflicts in his product code: zero. Package boundaries meant upstream changes touched only `packages/*`; his product code lives in `apps/web/features/*`. Unstub CI ran green during release-please; Marcus trusts the 1.1.0 tag.

**Resolution.** Twenty minutes of rebase work, no surgery. Marcus charges the client 0.25 days for the upgrade. Fourth such rebase since 1.0; all four non-events. Keel's invariants survived non-Tthew use.

### Journey Requirements Summary

The four journeys converge on the same capability set — which is the point, not a coincidence.

| Capability                                             | Journeys  | Milestones     |
|--------------------------------------------------------|-----------|----------------|
| Forkable repo, green integration test in minutes       | J1, J4    | M0, M9         |
| Day-1 RLS as physical invariant                        | J1, J3    | M1             |
| Auth/billing/email/jobs as hardwired opinion           | J1, J3    | M2, M3, M4     |
| Package boundaries enforced at compile time            | J3, J4    | M0             |
| Ralph backpressure + CI as autonomous gate             | J3        | M9, harness    |
| Checkpoint ritual + governance artifacts in-repo       | J2        | M8             |
| Scaffolding CLI for fresh forks                        | J4        | Growth tier    |
| Unstub guide CI protecting upstream and downstream     | J4        | M8, M9         |

## Domain-Specific Requirements

Keel's domain is general SaaS — no regulatory regime binds substrate code. Complexity is high on technical grounds. Three domain-novel concerns are captured here because they are not covered by Executive Summary, Technical Success, or standard NFRs.

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

Two libraries carry correlated-community risk at 1.0: TanStack Start (framework) and better-auth (auth library). Policy:

1. Quarterly CI run of the migration-back unstub guide for each. Stale guide ≥ 1 quarter fails substrate build.
2. If either library's maintenance signal drops below a named threshold (no release in 6 months, or security advisory unpatched > 14 days), the next major Keel version cuts the correlated pair via the unstub path.

### Model and Tooling Evolution

Opus 4.7 broke prompts tuned for Opus 4.6 (April 2026 release). Policy: every Keel major version documents the model generation and tooling versions it was tested against. A breaking model upgrade is a triggering event for a major Keel release test-run — not a silent bump.

## Innovation & Novel Patterns

### Detected Innovation Areas

Keel's innovation is not in individual stack choices (Postgres, Tailwind, OpenTelemetry are boring on purpose). Innovation lives in *constraints applied to the boring stack* and in the meta-framework composition:

1. **Substrate-as-category (hedged novelty).** Existing agentic-engineering tooling sits at orchestration (Bmalph-class) or skill-pack (Claude skill catalogs) layers. Keel proposes a third: the deployable substrate. Category is unclaimed per PRFAQ research; claim does not create category.
2. **Day-1 RLS as mandatory default.** Appears to be novel for this class of boilerplate: verified against Makerkit, ShipFast, Supastarter, SaaS Pegasus, Bullet Train, Nextacular, Chadnext — none ship RLS Day-1. Long-tail indie substrates not exhaustively swept. Security-critical behavior becomes physical invariant, not documented convention.
3. **Non-toggle-able quality gates + forkability.** Four-layer gates cannot be disabled via config. To remove a gate, fork. Governance choice: "permissibility of change" is encoded at the source layer, not the config layer.
4. **CI-tested unstub guides.** Migration-back paths run quarterly through CI; stale guide = red build. Docs as executable artefacts.
5. **Meta-framework composition (BMad + Ralph + Keel + Claude Code).** No known competing project ships this specific chain: planning contracts → autonomous loop → enforced substrate → agent runtime.

### Market Context & Competitive Landscape

Closest adjacencies: Bmalph / vibesparking (orchestration-only); Antigravity skill packs (skill layers, no substrate); Makerkit / ShipFast / Supastarter (human-optimised, commoditised at $199–$299, Stripe-first, no agentic affordances). See `_bmad-output/planning-artifacts/research/` for competitive detail. Hedged: "verified empty" reflects first-page-of-Google + known-community scan; long-tail indie GitHub substrates labelled "agent-ready saas starter" or "claude-optimised boilerplate" not exhaustively swept.

### Validation Approach

Each innovation area has a specific validation gate:

| Innovation                  | Validation Gate                                                   |
|-----------------------------|-------------------------------------------------------------------|
| Substrate-as-category       | 2-4 products shipped on Keel within 12 months (archive threshold) |
| Day-1 RLS                   | Pre-M2 policy-matrix spike converges in ≤ 1 day                   |
| Non-toggle-able gates       | M8 docs audit: no gate disable-able without fork                  |
| CI-tested unstub guides     | Red build on first quarterly run at month 3 post-1.0              |
| Meta-framework composition  | RIAR ≥ 70% on first fork                                          |

### Risk Mitigation

- **Category-creation hazard**: fallback positioning is "opinionated agent-authored SaaS boilerplate." No refactor required.
- **RLS complexity overflow**: downgrade to Tier-2 unstub if pre-M2 spike doesn't converge.
- **Correlated-library failure**: cut pair in next major Keel version via unstub path (per Domain section).
- **Meta-framework piece churn**: tested-combination documented per Keel major version; breaking model upgrade triggers a test-run release.

## Developer-Tool & CLI-Tool Specific Requirements

### Project-Type Overview

Keel is primarily a **developer_tool** (SaaS substrate shipped to developers) with a **cli_tool** surface exposed via pnpm scripts. The single host-side user surface is `pnpm <subcommand>`, which proxies to a Python implementation (`keel.py`, uv-runnable) that manages the devbox container and forwards commands. Users never type `docker`, `docker compose`, `ssh`, or raw `uv` commands — pnpm is the idiom. Keel produces **saas_b2b** product instances, but those SaaS concerns (multi-tenancy, RBAC, subscriptions, integrations) are opinionated substrate defaults, not customisation surfaces, and are covered in Technical Success + Executive Summary.

### Developer-Tool Surface

**Language support.** TypeScript only. No polyglot targets — Python / Go / Rust SDKs are explicitly out of scope. Rationale: single-language typing across the tRPC boundary is a first-principles substrate commitment.

**Package manager.** `pnpm` only. Monorepo uses `pnpm workspaces` + Turborepo; alternative package managers (npm, yarn) are not supported because of workspace semantics. CI fails builds that use other managers.

**Installation methods.** Two paths at 1.0:

1. `git clone` fork (primary).
2. Growth-tier: `pnpm dlx create-keel-app` scaffolding CLI.

No `npm publish` of individual packages. Fork-and-use model; packages are not distributed as standalone libraries.

**Prerequisite: Docker Desktop** (or equivalent Linux Docker runtime). The devbox is a non-toggle-able invariant; fresh forks run a first-run check that fails with a pointer to install instructions.

**API surface (developer-facing).** Substrate packages expose typed exports:

- `packages/core/auth` — better-auth wrapped with `requireRecentAuth` middleware.
- `packages/billing` — Paddle adapter + typed webhook registry.
- `packages/jobs` — pg-boss typed job registry.
- `packages/email` — Resend wrapper + baseline templates.
- `packages/core` — `tenantGuard()` session-variable setter.
- `packages/contracts` — tRPC contract definitions.
- `packages/flags` — server-side flag evaluator (route-loader scope).
- `packages/audit` — append-only audit log schema + helpers.
- `packages/db` — Prisma client + RLS-aware extension.
- `packages/ui` — Tailwind-based primitives.
- `packages/keel-invariants` — shared tsconfig-base, ESLint config, Prettier, commitlint rules, prek hooks, import-boundary rules. Consumed by every other substrate and product package.

**Code examples.** The fresh fork is the canonical example. No separate example/tutorial app ships. Pre-seeded data + baseline Paddle sandbox subscription make the fork immediately demonstrable.

**Migration guides (unstub).** Two at 1.0: TanStack Start ↔ Next.js; better-auth ↔ Auth.js. CI-tested quarterly. Additional guides are Growth-tier.

**IDE integration.** None shipped. Keel assumes Claude Code / Cursor / equivalent as the primary development environment — the agentic workflow is the IDE.

### CLI-Tool Surface

**Architectural rule.** Every host-side command is invoked as `pnpm <subcommand>`. The `package.json` scripts proxy to `uv run keel.py <subcommand>`; Python is the implementation, pnpm is the interface. Users never type `uv` or `python` directly.

**Host-side commands (proxy to container or manage lifecycle):**

| Command                                  | Effect                                                                                                                       |
|------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| `pnpm ralph:build`                       | Auto-starts devbox if needed; attaches to Ralph TUI inside container (Textual, via docker-attach). Ctrl+P Ctrl+Q detaches without killing. |
| `pnpm ralph:plan`                        | Same as above but in planning mode.                                                                                          |
| `pnpm ralph:status`                      | Queries Ralph state from `.ralph/logs/` without attaching.                                                                   |
| `pnpm ralph:stop`                        | Writes `.ralph/halt` sentinel to halt the loop cleanly.                                                                       |
| `pnpm devbox:start` / `stop` / `shell`   | Container lifecycle (manual fallback; auto-start is the default).                                                             |
| `pnpm claude`                            | Interactive Claude Code session inside devbox.                                                                                |
| `pnpm keel:scaffold`                     | Growth tier; command surface TBD during architecture doc.                                                                    |

**Container-native commands (run after `pnpm devbox:shell`):**

| Command                                     | Effect                                                            |
|---------------------------------------------|-------------------------------------------------------------------|
| `pnpm test` / `pnpm lint` / `pnpm dev`      | Standard monorepo scripts.                                         |
| `pnpm rls:explain <query> --tenant=<id>`    | RLS policy debugger (Tier 1). DB-bound; must run inside container network. |

**Devbox scope.** Per-fork by default — each Keel fork gets its own container mounted against that fork's workspace only. `KEEL_DEVBOX_SHARED=true` in `.envrc` enables shared-devbox mode (one container, parent-directory mount) for N=1 dogfooders matching the current `cc-devbox` pattern.

**Claude authentication.** Lives inside the devbox persistent volume (`/home/dev/.claude/`), not on the host. First `pnpm claude` invocation per devbox triggers OAuth; the URL is surfaced to the host; user completes OAuth in host browser; session persists in the container volume. CI and headless escape hatch: `ANTHROPIC_API_KEY` env var pass-through (Tier-2 unstub, not the default UX).

**Output formats.**

- Ralph: Textual TUI (interactive) + `.ralph/logs/` (stream-json persisted) + `.ralph/halt` (JSON halt signal).
- Scaffolding: plain-text status + exit code.
- RLS debugger: structured table (which policies fired, which rows filtered).

**Config method.** Per-invocation flags + per-project `.ralph/` dotfiles (`PROMPT_build.md`, `PROMPT_plan.md`, `@plan.md`). No global user-level config. Per-project stance is deliberate.

**Ralph command flags (inherited from absorbed Ralph harness):** `--timeout`, `--max-iterations`, `--permission-mode`, `--max-budget-usd`, `--fallback-model`, `--effort`.

**Shell completion.** Not shipped at 1.0. Growth-tier candidate.

### Implementation Considerations

- **Hardwire vs adapter policy**: auth is NO-adapter; payments and jobs are the two deliberate adapter exceptions. Every other "swappable" interface is explicitly rejected; import boundaries enforce this at compile time.
- **Boundary enforcement**: ESLint `no-restricted-imports` + TypeScript project references prevent cross-package imports that violate the package topology. Compile-time, not review-time.
- **Distribution**: zero npm-publish; GitHub release via release-please is the distribution channel. Fork-and-use model assumes forkers track upstream.

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach: Platform MVP.** Keel is not a problem-solving MVP (the problem is well-understood from N=1 experience), not an experience MVP (no end-users interact with the substrate directly), and not a revenue MVP (one paying customer is a functional test, not a growth milestone). Validated learning = 2-4 real products shipped on Keel within 12 months of 1.0; failure to hit 2 within 12 months archives the substrate per Kill Criterion.

**Resource Requirements.** N=1 (Tthew) + agentic workforce (Ralph + Claude Code). Required skills: TypeScript, Postgres/SQL, system design, prompt craft. Time budget: 26 focused days (see Product Scope M0-M9 with M0.5 devbox milestone and i18n-extended M7); realistic first-slip budget 33-36 days. Compression absorbed by M7-M9 (docs polish, CI hardening).

### MVP Feature Set (Phase 1 — Keel 1.0)

Milestones M0-M9 (including M0.5) are fully enumerated in Product Scope. This section maps user journeys to MVP-critical milestones:

| Journey                         | MVP-critical?                  | Milestones required            |
|---------------------------------|--------------------------------|--------------------------------|
| J1 Product #2 happy path        | Yes — validates T2NP           | M0-M4, M9                      |
| J2 M4 checkpoint ritual         | Yes — governance invariant     | M8 (checkpoint doc)            |
| J3 Agent iteration              | Yes — validates RIAR           | M0-M4, M9 + harness + M0.5 devbox |
| J4 Marcus peer fork             | No — ergonomics not invariant  | None (Growth tier)             |

**Must-have capabilities for 1.0:**

- Fork-clone produces a green 60-minute integration test (M0, M9).
- Devbox container as non-toggle-able execution environment (M0.5).
- Day-1 RLS invariant enforced at database layer (M1).
- Hardwired auth / billing / jobs / email (M2-M4).
- Non-toggle-able four-layer quality gates with Ralph backpressure (M9).
- Two CI-tested unstub guides (M8).
- In-repo M4 checkpoint document structure (M8).
- Internationalization framework wired into TanStack Start with English baseline locale and typed-key enforcement (M7). Non-negotiable core requirement.
- Per-iteration security verification with structured evidence: secret scan, dependency audit, SAST, prompt-injection scan; findings block commit; evidence persisted to `.ralph/logs/` (M0 + M9). Non-negotiable core requirement.
- Invariants stack at M0: machine-enforced package (`packages/keel-invariants/`) + agent-readable `INVARIANTS.md` + documentation layer + sync pre-merge gate.

### Post-MVP Features

**Phase 2 (Growth, months 1-6 post-1.0):**

- Scaffolding CLI (`pnpm keel:scaffold`) — enables J4 ergonomics.
- Additional unstub guides: Clerk ↔ better-auth; Stripe ↔ Paddle; Drizzle ↔ Prisma; Vercel deploy; Next.js migration detail.
- Scaffoldable optional addons: analytics SDK (PostHog / Plausible hook points) and cookie banner / consent management. Shipped as opt-in scaffolds invoked during fork creation.
- Shell completion for the pnpm-exposed command set.
- Headless Ralph mode (`--no-tui` or equivalent) for CI scenarios.
- Independent package versioning via release-please-monorepo if a package is extracted as a standalone library.

**Phase 3 (Expansion — dogfood-first):**

- Meta-framework formalisation across BMad + Ralph + Keel + Claude Code.
- Product-count milestone: 2-4 products shipped on Keel within 12 months of 1.0.
- Adoption signaling (blog post, peer-community share) — permitted but not planned.

### Risk Mitigation Strategy

**Technical Risks:**

- *Full Day-1 RLS policy matrix (novel at scale)* — pre-M2 spike budgeted at ≤ 1 day. If the matrix does not converge in a day, Day-1 RLS downgrades to Tier-2 unstub with a clear migration path. Accepted tradeoff.
- *Correlated-library risk (TanStack Start + better-auth)* — tested migration-back unstub guides (M8) run quarterly through CI. If either library's maintenance signal drops below the policy threshold (see Domain section), cut the pair in the next major Keel version.
- *60-minute CI test engineering is a known first-slip candidate (3 planned days → 5-6 real)* — compression absorbed by M7-M9.
- *Devbox cold-start and image size (~3.5 GB per cc-devbox baseline)* — affects Ralph iteration startup time on first invocation. Mitigation: persistent container across Ralph invocations; rebuild only on Dockerfile diffs; document pre-warming as an operational tip.
- *Bootstrap handoff at M0.5* — the cc-devbox → `packages/devbox/` migration happens mid-build. If the absorbed devbox fails to build or run, Keel's own build stalls. Mitigation: keep standalone `cc-devbox` functional on a `legacy-devbox` branch until after the M4 checkpoint as a fallback path.
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

Keel is self-hosting — the meta-framework used to build Keel is the framework Keel ships. Post-1.0, the practical question for any Keel repo is not "which framework are we using" (it's always BMad + Ralph + Keel + Claude Code) but "what mode of work is this change"?

### Three modes

1. **Development with Keel** — product code only. `apps/web/features/*`, product-specific schemas, product tests. Upstream rebase is by-design safe; package boundaries (enforced at compile time) prevent drift.
2. **Keel development via fork** — substrate code on your own fork. `packages/*`, `keel.py`, substrate CI, unstub guides. You own divergence. Upstream rebase may conflict.
3. **Keel development proper** — substrate changes intended to flow upstream. PR to the upstream Keel repo.

### Where the line lives

| Dimension    | The line                                                          |
|--------------|-------------------------------------------------------------------|
| Physical     | Substrate: `packages/*`, `keel.py`, `docs/unstub/*`, `packages/keel-templates/*`, substrate CI workflows. Product: `apps/web/features/*`, product schemas, product tests. No ambiguous middle. |
| Temporal     | The 1.0 cut ritual. Before cut: only Keel-development exists. At cut: archival + template seeding draws the line. After cut: every fresh fork starts in "development with Keel" by default. |
| Enforceable  | Compile-time (ESLint `no-restricted-imports` + TypeScript project references); CI path-based gate routing; convention. |

### State categories

| Category             | Location                        | Scope        | Behaviour on fork                                       |
|----------------------|---------------------------------|--------------|---------------------------------------------------------|
| Substrate source     | `packages/*`, `keel.py`         | Shared       | Inherited unchanged; upstream rebases cleanly.          |
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

### Baseline reference

Keel adopts **OWASP Top 10:2025**, **ASVS Level 1**, and **OWASP Top 10 for Agentic Applications (2026)** as the substrate security baseline (see `github.com/agamm/claude-code-owasp`). ASVS Level 2+ is a Tier-2 unstub for forks with regulated-compliance needs.

### Substrate-level controls (inherited by every fork)

- **Sandbox isolation** — devbox DNS whitelist, non-root user, tmpfs noexec, NET_ADMIN/NET_RAW-only capabilities (see Execution Environment).
- **Tenant isolation at database layer** — RLS on every tenant-scoped table.
- **Non-toggle-able quality gates** — apply equally to agent-authored and human-authored commits.
- **Secrets never committed** — pre-commit gate rejects known secret patterns.
- **Dependency audit** — Dependabot or equivalent blocks merges with critical vulnerabilities.
- **Audit log append-only** — security-relevant events persisted immutably.

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

Evidence is persisted to `.ralph/logs/<iteration-id>/security-evidence.json` for every iteration. Signed cryptographic attestation is a Tier-2 unstub for forks with compliance needs.

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

A pre-merge quality gate verifies the three layers don't drift. If `packages/keel-invariants/` changes without a corresponding `INVARIANTS.md` change, the build fails. The specific sync mechanism is deferred to the architecture doc.

### Coverage

| Invariant                                 | Machine-enforced in                                                                                           | Agent-readable in                                      | Documented in                       |
|-------------------------------------------|---------------------------------------------------------------------------------------------------------------|--------------------------------------------------------|-------------------------------------|
| Commit message format                     | commitlint via prek                                                                                           | INVARIANTS.md §commit                                  | docs/invariants/commit.md           |
| Security standards                        | per-iteration verification; OWASP ASVS L1 baseline                                                            | INVARIANTS.md §security                                | docs/invariants/security.md         |
| Coding standards (TS, lint, format)       | tsconfig-base + ESLint + Prettier                                                                             | INVARIANTS.md §coding                                  | docs/invariants/coding.md           |
| Repo structure / package boundaries       | ESLint `no-restricted-imports` + TS project refs                                                              | INVARIANTS.md §structure + CLAUDE.md package map       | docs/invariants/repo.md             |
| Backend technology constraints            | Substrate packages physically depend on Prisma, better-auth, pg-boss, Paddle, Resend, OTel                    | INVARIANTS.md §backend                                 | docs/invariants/backend.md          |
| Client technology constraints             | `apps/web` built on TanStack Start; UI uses Tailwind, tRPC, RHF, Zod, Zustand                                  | INVARIANTS.md §client                                  | docs/invariants/client.md           |

### Extension / override model for forks

- **Default**: forks inherit everything unchanged. Substrate upstream changes flow on rebase.
- **Extend**: forks author their own extension configs (e.g., `eslint.config.fork.js extends eslint.config.keel-invariants.js`). Substrate never touches these files; rebase is clean.
- **Override**: forks that need to remove an invariant entirely fork `packages/keel-invariants/` — explicit substrate divergence, documented in the fork's README.
- **Agent-facing**: forks add product-specific invariants to a fork-owned `INVARIANTS.fork.md`; `CLAUDE.md` references both files.

### Principle

The thesis *"invariants beat conventions beat docs"* applies to the invariants themselves: the machine-enforced layer is the invariant; agent-readable and documentation layers are explanations. Sync-gate enforcement prevents the layers from drifting — drift would recreate the exact "docs lie about reality" problem Keel is designed to eliminate.

## Functional Requirements

### Execution Environment Management

- **FR1**: Developer can manage devbox lifecycle (start, stop, shell, attach) via pnpm-exposed commands.
- **FR2**: Developer can invoke Ralph (`pnpm ralph:build` / `pnpm ralph:plan`) with the devbox auto-starting if not already running.
- **FR3**: Developer can authenticate Claude Code once per devbox via browser OAuth flow surfaced to the host terminal.
- **FR4**: Developer can select between per-fork devbox (default) and shared devbox mode via `.envrc` configuration.
- **FR5**: System can enforce Docker as a prerequisite, failing fresh-fork first-run with an install-pointer error.
- **FR6**: Developer can run substrate-internal tooling (tests, lints, RLS debugger) inside the devbox.

### Autonomous Agent Loop

- **FR7**: Agent can execute a multi-iteration loop against a committed plan (`.ralph/@plan.md`) inside the devbox.
- **FR8**: System can halt the Ralph loop on a configurable threshold of consecutive test failures or security-verification failures (see Security Verification & Evidence).
- **FR9**: System can halt the Ralph loop on task-budget exhaustion per iteration.
- **FR10**: Developer can detach from a running Ralph loop (loop continues executing) and later re-attach to observe state.
- **FR11**: Developer can query Ralph state without attaching via `pnpm ralph:status`.
- **FR12**: Developer can halt the Ralph loop cleanly via `pnpm ralph:stop`.
- **FR13**: System can persist Ralph iteration logs in `stream-json` format for replay and debugging.
- **FR14**: System can require conventional-commit format for all commit messages, regardless of authorship.

### Tenant Isolation

- **FR15**: System can enforce tenant data isolation at the database layer via Row Level Security policies on all tenant-scoped tables.
- **FR16**: Developer can set the current tenant context via `tenantGuard()` session-variable setter inside request transactions.
- **FR17**: Developer can debug RLS policy decisions for a given query and tenant context.
- **FR18**: System can enforce that new tenant-scoped tables ship with an RLS policy, via CI check.

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
- **FR39**: System can enforce OWASP ASVS Level 1 as the substrate security baseline; ASVS Level 2+ is a documented Tier-2 unstub.
- **FR40**: System can scan committed agent-context-loader files (`CLAUDE.md`, skill files, `.ralph/PROMPT_*.md`, `docs/**/*.md`) for prompt-injection patterns as part of pre-commit quality gates.

### Invariants

- **FR41**: System can ship a versioned invariants package (`packages/keel-invariants/`) consumed by lint, format, type-check, commit, and merge gates across all substrate and product code.
- **FR42**: System can expose invariants to agents via `INVARIANTS.md` at repo root, referenced by `CLAUDE.md`, providing an agent-readable index of machine-enforced rules.
- **FR43**: System can enforce sync between the machine-enforced layer (`packages/keel-invariants/`) and the agent-readable layer (`INVARIANTS.md`) via a pre-merge gate that fails when one changes without the other.
- **FR44**: Developer can extend invariants via extension configs that build on `packages/keel-invariants/` (e.g., `eslint.config.fork.js extends eslint.config.keel-invariants.js`) without modifying substrate files.
- **FR45**: Developer can (Growth tier) scaffold a fork-specific `INVARIANTS.fork.md` that is referenced alongside the upstream `INVARIANTS.md` by `CLAUDE.md`.

### Forkability & Upgradability

- **FR46**: Developer can fork Keel, rename, and configure project-specific values without modifying substrate package internals.
- **FR47**: Developer can (Growth tier) scaffold a fresh Keel-forked project via `pnpm keel:scaffold`.
- **FR48**: Developer can migrate from an opinionated substrate choice (TanStack Start, better-auth) to its documented alternative via a CI-tested unstub guide.
- **FR49**: System can run quarterly CI against each unstub guide; stale guide fails the substrate build.
- **FR50**: Maintainer can cut a Keel major version with the tested model/tooling generation combination documented in the release notes.
- **FR51**: System can (Growth tier) wipe residual `_bmad-output/` and `.ralph/` state on fork-scaffolding, seeding empty per-project state from templates in `packages/keel-templates/`.
- **FR52**: Maintainer can archive per-version planning artifacts to `docs/archive/keel-<version>-planning/` before each major-version tag cut, leaving the shipping substrate with empty per-project state directories.
- **FR53**: System can distinguish substrate-territory commits from product-territory commits via path-based CI rules, triggering different gate profiles for each (full 60-min integration + unstub CI on substrate paths; product tests only on `apps/web/features/*` paths).

## Baseline Product Capabilities Inherited by Forks

These capabilities are pre-wired in every Keel-forked project. Forks can extend or customise but do not need to implement them.

### Identity & Access

- **FR54**: End user can sign up via email+password or Google OAuth.
- **FR55**: End user can verify their email address via a Resend-delivered link.
- **FR56**: End user can create, join, leave, and be invited to teams.
- **FR57**: End user can maintain DB-backed sessions with revocation support.
- **FR58**: System can require recent auth (step-up) for sensitive actions.
- **FR59**: End user can log out of all active sessions.

### Commerce

- **FR60**: End user can subscribe to a paid plan via Paddle (Merchant of Record).
- **FR61**: System can process Paddle webhooks for subscription lifecycle events (creation, cancellation, dunning, upgrade, downgrade).
- **FR62**: System can enforce subscription-gated access to premium capabilities.
- **FR63**: Developer can extend Paddle integration via the registered payment adapter.

### End-User Localization

- **FR64**: End user can select a preferred locale; the system persists and honors the selection across sessions.

## Non-Functional Requirements

### Performance

- **NFR1**: The 60-minute CI integration test completes in under 60 minutes on a standard GitHub Actions runner. Non-toggle-able. Red build if exceeded.
- **NFR2**: Devbox cold-start (first-run build) completes within 5 minutes on Apple-Silicon-class hardware; warm-start (container reuse) within 30 seconds. Targets to be validated during M0.5.
- **NFR3**: RLS query overhead is measurable, monitored, and held below a threshold set in the architecture doc. Budget deferred.
- **NFR4**: Ralph iteration startup (context load, task parse, agent spawn) completes within 20 seconds; iteration task-budget is enforced.

### Security

- **NFR5**: All agent execution runs inside the devbox; `--dangerously-skip-permissions` is never invoked on the host. Non-toggle-able at config layer; bypass requires a source-level fork.
- **NFR6**: Container network egress is default-deny; reachable hosts are limited to the dnsmasq whitelist. Expanding the whitelist is an explicit user action, logged.
- **NFR7**: Container runs as a non-root user (uid/gid ≠ 0). Kernel capabilities limited to NET_ADMIN and NET_RAW.
- **NFR8**: `/tmp`, `/var/tmp`, and `/workspace/logs` are mounted tmpfs with noexec and nosuid flags.
- **NFR9**: Secrets must never be committed. A pre-commit gate rejects commits that match known secret patterns (API keys, bearer tokens, private keys).
- **NFR10**: Claude Code authentication tokens are persisted only inside the devbox volume (`/home/dev/.claude/`); the host's `~/.claude/` is never bind-mounted.
- **NFR11**: Tenant isolation is enforced at the database layer (RLS), not the application layer. An application-layer bug cannot cross tenant boundaries.
- **NFR12**: All authenticated sessions are DB-backed with revocation support. Stateless-JWT sessions are a documented Tier-2 unstub only.
- **NFR13**: All audit log entries are append-only. Application code cannot delete or modify past entries.
- **NFR14**: Dependency audit (Dependabot or equivalent) runs on every PR; critical vulnerabilities block merge.
- **NFR15**: Every Ralph iteration produces structured security evidence (secret scan + dep audit + SAST + prompt-injection scan + test coverage) persisted to `.ralph/logs/<iteration-id>/security-evidence.json` before commit.
- **NFR16**: Security-verification failures are equivalent-priority to test-verification failures for the Ralph loop's halt behaviour.
- **NFR17**: Keel adopts OWASP Top 10:2025, ASVS Level 1, and OWASP Top 10 for Agentic Applications (2026) as the substrate security baseline. Level 2+ is a Tier-2 unstub for compliance-bound forks.
- **NFR18**: Critical-severity security findings (hardcoded production secrets, CVSS ≥ 9 vulnerabilities, known RCE patterns) trigger immediate Ralph halt without retry.

### Scalability

- **NFR19**: The substrate imposes no scalability ceiling beyond the underlying runtime (Node.js, Postgres, pg-boss). Horizontal scaling via worker-process extraction is a documented Tier-2 unstub.

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
- **NFR30**: Every Keel major version documents the tested model generation (e.g., Opus 4.7), Claude Code CLI version, BMad version, and Ralph version. A breaking upstream model upgrade triggers a new major version test-run.
- **NFR31**: The Invariants stack's three layers (machine-enforced, agent-readable, documented) are kept in sync by a pre-merge gate; drift between layers fails the build.

### Observability

- **NFR32**: Every request handled by a Keel-forked app emits OpenTelemetry traces correlated by request ID. Sampling rate is configurable per-deploy.
- **NFR33**: Ralph iterations emit structured stream-json logs to `.ralph/logs/` with per-iteration ID, start/stop timestamps, claude subprocess exit status, and test results.
