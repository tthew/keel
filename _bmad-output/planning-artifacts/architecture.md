---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-04-19'
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/prd-validation-report.md
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad.md
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
  - _bmad-output/planning-artifacts/ux-design-directions.html
  - _bmad-output/planning-artifacts/research/technical-keel-ralph-bmad-research-2026-04-17.md
  - _bmad-output/brainstorming/brainstorming-session-2026-04-17-0910.md
  - docs/ralph.md
  - docs/invariants/knowledge-files.md
  - docs/invariants/ralph-execute.md
  - docs/absorption-tripwire/vertical-slice-acceptance.md
workflowType: 'architecture'
project_name: 'Keel (ralph-bmad)'
user_name: 'Tthew'
date: '2026-04-18'
---

# Architecture Decision Document — Keel

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## 📌 Project Posture (read this first)

**Research and learning is the primary purpose of this project. Everything else is secondary.**

Keel is dual-posture per the PRD (research project + functional boilerplate). This architecture doc extends the PRD's tie-breaker — **research-output richness wins when it conflicts with substrate ship-velocity** — into a stronger operating rule: **substrate concerns that don't serve research-output are acceptable misses at 1.0.**

Consequences that shape how every decision below should be read:

- **Over-engineering substrate-correctness is waste.** If an architectural decision hardens the substrate against a failure mode that only matters at scale beyond N=1, defer it. Examples of acceptable deferrals at 1.0: per-tenant RLS outlier baselines; weekly "money-path" synthetic tests in nightly; Paddle/Google/Resend consumer-driven contract (Pact) tests; chaos/fault-injection.
- **Research infrastructure is first-class.** Decisions that enable reproducible measurement (the monthly blank-starter-sprint, checkpoint entries, tripwire datapoints, sprint-log aggregation) are 1.0 blocking, not Growth-tier.
- **Iteration is the expected failure mode.** If a decision turns out wrong, Tthew will retune the plan and try again — that's the stated operating mode. Don't pre-build for the wrong outcomes; ship the simplest workable thing.
- **N=1 persona preservation.** Don't add abstraction for hypothesised peer operators. A shim with one implementation is scar tissue, not architecture.
- **What survives substrate obsolescence is the principle layer.** `packages/keel-invariants/` + the research corpus (`docs/research/`) are the artefacts that outlive Keel-as-substrate if the absorption tripwire fires. Architect for that outcome.

When a future reader (future-Tthew, future-LLM, future-contributor) encounters a decision in this doc that doesn't make substrate-purist sense, check it against these priorities. If the decision serves research-output under this posture, it's probably right.

## Project Context Analysis

### Requirements Overview

**Functional Requirements (85 total, 10 clusters):** Execution Environment (FR1–FR6, FR1a); Autonomous Agent Loop (FR7–FR14 with FR14a–FR14l sub-FRs for acceptance-driven backpressure, authorship separation, append-only manifest with content-hash, assertion-shape floor, halt-threshold); Tenant Isolation (FR15–FR18) — Day-1 RLS parameterised over tenancy templates; Platform Services (FR19–FR23); Internationalization (FR24–FR27, FR64); Quality & Governance (FR28–FR34); Security Verification & Evidence (FR35–FR41); Invariants (FR41–FR45) — three-layer stack with sync gate; Forkability & Upgradability (FR46–FR53, FR54–FR64); Configuration & Generator (FR65–FR68) with FR67's six-property normalization contract (pure / deterministic / idempotent / order-independent / canonical-form-exists / stable-rule-identity).

**Non-Functional Requirements (45 total, 9 clusters):** Performance; Security (ASVS L1 baseline + per-iteration evidence + sandbox-as-boundary); Scalability (no artificial ceiling, CI-grep-gate-enforced); Accessibility (WCAG 2.1 AA on scaffolded UI); Integration; Reliability (fail-closed defaults, generator idempotency, invariants-sync gate); Maintainability (15 hr/mo ceiling as archive trigger); Observability (OTel traces, audit log, security evidence); Invariants (execution-budget headroom NFR4b, worktree retention NFR28a, halt schema NFR33a, tokenizer-aware budgets NFR4, context-utilisation smart zone NFR4a, CI empirical baseline NFR28b, monthly review NFR28c, prompt-set pinned per Keel major NFR29a, breaking-delta catalogue NFR30).

**Scale & Complexity:**

- Primary domain: full-stack TypeScript SaaS substrate + containerized agentic-dev harness + narrow-scope codegen contract
- Complexity level: Medium-High (source-layer pinning inverts canonical PRD thesis — architecture's job is to *preserve* the hardwired stack and design where/how invariants live, not to relitigate them; narrow generator is the only codegen surface)
- Project type: `developer_tool` + `cli_tool` (dual)
- Configuration model: source-layer-pinned invariants
- Persona model: N=1 (Tthew only; peer-audience framing is hypothetical and does not drive scope)
- Estimated architectural surfaces: ~14 packages + devbox runtime + generator engine + Ralph loop contracts + 5-tier CI pyramid + 3-layer invariants stack + cross-runtime semantic token contract

**Primary load-bearing surfaces deferred to this architecture workflow** (PRD-pinned handoffs):

1. **§Generator-Normalization-Algorithm** (FR67) — internal ordering lattice, merge precedence, canonicalisation procedure for the six-property pure `expand(policy, config) → Rule[]` contract.
2. **§Devbox-Reference-Config** (NFR8 / NFR8a) — tmpfs sizes, CPU/memory/shm/nofile reference defaults in `packages/devbox/.envrc.example`, retunable without PRD amendment.
3. **§RLS-Performance-Budget** (NFR3) — refine `< 15% query wall-clock overhead` placeholder via empirical baseline on ephemeral Postgres.
4. **§Egress-Policy Mechanism** (FR1a) — dnsmasq-repaired vs nftables-egress vs alternative; deterministic fail-closed DNS whitelist with IPv4/IPv6 parity, atomic reload, structured JSONL query log.

### Technical Constraints & Dependencies

- **Hardwired stack as non-negotiable input** (not architecture decisions): TanStack Start + tRPC + Prisma + Postgres + better-auth + Paddle + pg-boss + Resend + Tailwind + Zod + react-hook-form + Zustand + OpenTelemetry + pnpm workspaces + Turborepo + prek + commitlint + release-please.
- **Packages pinned by PRD:** `apps/web` + `packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui, keel-invariants, devbox, keel-generator, keel-templates}`.
- **Execution environment:** Docker devbox — Ubuntu 24.04 LTS, non-root `dev` user (uid/gid ≠ 0, NOPASSWD sudo for substrate-internal ops), NET_ADMIN/NET_RAW-only kernel caps, `no-new-privileges`, noexec/nosuid tmpfs (`/tmp`, `/var/tmp`, `/workspace/logs`, `/run`), fail-closed DNS (IPv4 + IPv6 parity, atomic reload, structured JSONL query log), named-volume auth persistence (not host bind-mount). `.envrc`-parameterised (arch, CPUs, memory, shm, nofile, ports). Reference defaults calibrated for Apple-Silicon M4-Pro but host-retunable.
- **Host surface = `pnpm <subcommand>` only.** Users never type `docker` / `docker-compose` / `ssh` directly. sshd is opt-in via `KEEL_DEVBOX_SSH=true` (pubkey-only, loopback-bound `127.0.0.1:2222`).
- **One-time auth prerequisites inside devbox:** Claude Code OAuth (`pnpm claude`) + `gh auth login` (`pnpm gh:auth`). Tokens persist in named Docker volume (`/home/dev/.claude/`, `/home/dev/.config/gh/`); host `~/.claude/` and `~/.config/gh/` are never bind-mounted. Ralph cannot push until `gh` is authenticated.
- **Two shapes at 1.0:** `b2b` (default, team tenancy, team-seats Paddle preset) and `b2c` (user tenancy, individual-subscription Paddle preset). Marketplace + API-first deferred to 1.1 / 1.2 on consumption-driven YAGNI.
- **CI pyramid (5 tiers):** pre-commit ≤10s / pre-merge-fast ≤3min (deterministic, no live network) / pre-merge-slow ≤10min (ephemeral Postgres) / nightly ≤60min (Paddle sandbox + Google OAuth live here only) / release-gated (manual). Minute budgets are target-SLOs pinned by a 2-week p95 empirical baseline (NFR28b); monthly review PR is routine (NFR28c).
- **Model-drift insulation:** tokenizer-aware budgets; per-major-Keel prompt-set pinning (NFR29a); breaking-delta catalogue (NFR30); Opus 4.7 is the currently tested baseline with documented Opus 4.6→4.7 deltas.
- **TypeScript-only end-to-end.** Ralph's internal Python Textual TUI is orchestration-only (runs inside devbox), not a user-facing 1.0 surface.
- **No `npm publish` at 1.0** — fork-and-use model. Exception: Invariant Pack, if the absorption tripwire fires (20% time-to-green delta sustained 2 consecutive months), publishes to npm within 30 days as the pre-committed pivot destination.
- **Dual posture tie-breaker:** when substrate ship-velocity and research-output richness conflict, **research-output richness always wins**; substrate ship-velocity is instrumentation.

### Cross-Cutting Concerns Identified

1. **Three-layer invariant pattern** — applied consistently to: code (`packages/keel-invariants/` + `INVARIANTS.md` + docs), design tokens (Tailwind + Textual theme + catalog), Ralph loop contracts (FR14f–k + `docs/invariants/ralph-execute.md` + CLAUDE/AGENTS/RALPH.md), i18n keys (typed enforcement + CI gate + locale docs), and security evidence (JSON schema + persisted artefacts + human-readable summary).
2. **Source-layer pinning discipline** — architecture's job is *where and how the invariants live*, not *what they are*. Hardwired stack is PRD-owned; architecture owns the physics of enforcement.
3. **Shape-aware narrow generator** — single FR67-compliant pure `expand` emits RLS tenancy template + Paddle shape preset from `keel.config.ts`. Internal ordering lattice, merge precedence, canonicalisation owned by §Generator-Normalization-Algorithm.
4. **Sandbox as security boundary** — devbox is what makes `--dangerously-skip-permissions` safe; a runtime compromise cannot reach the host. Egress-policy mechanism choice (§Egress-Policy Mechanism) is the load-bearing architecture question here.
5. **Agent as first-class user** — knowledge-file audience separation (AGENTS / CLAUDE / RALPH); catalog IDs greppable and stable; "one right answer" bias on every authoring surface; first-try CI pass as the effortless-loop bar for agent authoring.
6. **Cross-runtime semantic tokens** — shared status / severity / density vocabulary consumed by both the Textual TUI theme AND the Tailwind config. The design system is a *source-layer invariant*, not a taste decision.
7. **Empirical SLO discipline** — minute budgets are target-SLOs pinned via 2-week p95 baseline + monthly re-baseline PR; architecture must own the measurement and baseline artefacts.
8. **Absorption-falsification as architecture constraint** — nothing architecture decides should prevent the Invariant Pack pivot. The principle layer (YAGNI, DRY, NIH-refusal, invariants-beat-conventions, documented rationale) survives substrate obsolescence.
9. **Cross-layer sync enforcement** — pre-merge gates close: (a) `keel.config.ts` → generator output drift, (b) `packages/keel-invariants/` manifest drift (content-hash + ID stability), (c) design-token manifest → Tailwind + Textual consumer drift, (d) `Required tests:` append-only manifest drift (FR14a2 Levenshtein-similarity or architecture-chosen equivalent).
10. **N=1 persona preservation** — architecture must not pre-build for hypothetical peer operators; scripted-agent operation and multi-operator affordances are Growth-tier, not substrate.

## Starter Template Evaluation

### Primary Technology Domain

Full-stack TypeScript monorepo (`developer_tool` + `cli_tool` dual classification) — TanStack Start web app on Vite + Postgres + tRPC + Prisma, assembled as a 14-package pnpm-workspaces + Turborepo monorepo, with a Docker devbox as the non-toggle-able execution boundary and a Python Textual TUI (Ralph) as the agent-loop orchestrator inside the devbox.

### Starter Options Considered

1. **`@tanstack/cli` (unified, 2026 official)** — `pnpm create @tanstack/start@latest`. Minimal form (zero add-ons) provides validated TanStack Start + Vite + Router + Tailwind v4 wiring plus agent-friendly JSON introspection (`--list-add-ons`, `--addon-details ... --json`). Selected for `apps/web` only.
2. **`create-turbo`** — rejected. Default scaffold ships Next.js + Changesets + `apps/docs`, all of which conflict with PRD-pinned choices (TanStack Start, release-please, 14-package topology without a docs app). Would require 50%+ remove-and-replace; hand-authoring `pnpm-workspace.yaml` + `turbo.json` is faster.
3. **TanStack Builder (AI-first alternative)** — rejected. Interactive AI-driven setup does not match Keel's invariants-first posture; setup decisions are already made and frozen.
4. **Fully custom `pnpm init` scaffold** — rejected for `apps/web` (TanStack Start's Vite + Router + Tailwind v4 wiring is non-trivial); accepted for monorepo root + all non-`apps/web` packages (hand-authored per PRD-pinned 14-package topology).

### Selected Starter: **Hybrid — `@tanstack/cli` for `apps/web` + manual scaffold for the monorepo**

**Rationale for Selection:**

The PRD's source-layer-pinned-invariants thesis treats every cross-component decision as already-made. Most off-the-shelf starters inject conventions (Next.js, Changesets, Clerk, Drizzle, `apps/docs`) that would have to be stripped out — the strip-and-replace tax exceeds the authoring tax. The exception is `@tanstack/cli` in its minimal form: TanStack Start + Vite + Router + Tailwind v4 is the exact hardwired choice and the CLI's agent-friendly JSON introspection aligns with Keel's agent-first ethos. For everything else — Turborepo config, `pnpm-workspace.yaml`, 14-package topology, `packages/devbox/`, Ralph harness, invariants package, generator, templates — hand-authoring from 2026 reference patterns produces a cleaner substrate than fighting a starter's defaults.

**Initialization Commands:**

```bash
# Root monorepo — manual scaffold (no create-turbo; PRD-pinned 14-package topology)
pnpm init
# author: pnpm-workspace.yaml, turbo.json, tsconfig.base.json, .prek/,
#         commitlint.config.js, release-please-config.json,
#         .github/release-please-manifest.json, .envrc.example

# apps/web — minimal TanStack Start (zero add-ons; PRD-pinned stack layered on top)
pnpm create @tanstack/start@latest apps/web
# explicitly DO NOT pass: --add-ons clerk  (PRD hardwires better-auth)
# explicitly DO NOT pass: --add-ons drizzle (PRD hardwires Prisma)
# explicitly DO NOT pass: --add-ons shadcn (UX defers component-library choice
#                                           to architecture phase)
# then author: tRPC client, better-auth client, Paddle checkout wiring

# packages/devbox — absorb from upstream cc-devbox per PRD M0.5
git clone https://github.com/tthew/cc-devbox packages/devbox
# then apply M0.5 deliverables (a–e) from PRD § Devbox Implementation Contract:
# (a) image bake, (b) compose .envrc-parameterised, (c) narrowed entrypoint,
# (d) egress-policy fix per FR1a, (e) pnpm devbox:* lifecycle bridge

# Ralph harness — inherit ralph.py from current ralph-bmad repo (fork disposition)
# Monthly upstream diff review per PRD ralphDisposition: fork

# Remaining 13 packages — authored directly per PRD § API surface:
# packages/{db, contracts, config, core, billing, email, jobs, flags,
#           audit, ui, keel-invariants, keel-generator, keel-templates}
```

**Architectural Decisions Provided by Starter:**

**Language & Runtime:** TypeScript strict mode + Vite dev server + `@tanstack/cli` scaffold (no polyglot targets — PRD-pinned).

**Styling Solution:** Tailwind v4 (always-on in `@tanstack/cli` 2026; no flag needed). Design tokens layered on top via `packages/ui` + `packages/keel-invariants` design-token manifest (cross-runtime: Tailwind config + Textual theme consumers — see UX spec design-system-as-invariant).

**Build Tooling:** Vite for `apps/web`; Turborepo for monorepo task orchestration (content-aware caching + incremental builds + dependency-graph-aware task running); `tsconfig.base.json` + TypeScript project references for compile-time package-boundary enforcement alongside ESLint `no-restricted-imports`.

**Testing Framework:** Deferred — to be decided in architectural decisions phase. Natural fits: Vitest (aligns with Vite+TS workspace), Playwright (PRD pins it for end-to-end + devbox bakes browser deps at image build).

**Code Organization:** 14-package topology per PRD § API surface — `apps/web` + `packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui, keel-invariants, devbox, keel-generator, keel-templates}`. ESLint `no-restricted-imports` + TS project references enforce boundaries at compile time (rules hardwired in `packages/keel-invariants/`, static across shapes).

**Development Experience:** Vite HMR on port 24679 (devbox-bound to `127.0.0.1`), `pnpm devbox:shell` for container-native commands, `pnpm ralph:build` / `pnpm ralph:plan` for agent loop inside the devbox, TanStack Router devtools in `apps/web`, `@tanstack/cli` JSON introspection surfaces for downstream Claude Code queries (`--list-add-ons`, `search-docs ... --json`).

**Conflict-avoidance notes (add-on flags explicitly NOT passed):**

- **No `--add-ons clerk`** — PRD hardwires better-auth (DB-backed sessions + step-up middleware + `requireRecentAuth` wrapper).
- **No `--add-ons drizzle`** — PRD hardwires Prisma (Prisma client + RLS-aware extension in `packages/db`).
- **No `--add-ons shadcn` at 1.0** — UX spec defers component-library choice to the architecture phase (design-system-as-invariant decision; the picked library must be LLM-consumable, copy-paste-safe, AA-first, and token-driven).
- **No `--router-only`** — Keel needs TanStack Start's SSR / route-loaders (NFR20 AA-enforced, flag evaluation in route loaders per FR21).

**Note:** Project initialization using these commands becomes the first implementation story (M0 repo foundation + M0.5 devbox absorption + M0.7 narrow-scope generator scaffolding).

## Core Architectural Decisions

### Decision Priority Analysis

**Already decided by PRD (do NOT re-litigate):** TypeScript strict mode; Postgres + Prisma; tRPC; better-auth (DB-backed sessions, Google OAuth + email/password, step-up middleware, `requireRecentAuth`); Paddle (two hardwired shape presets); pg-boss; Resend; TanStack Start on Vite; Tailwind v4; react-hook-form + Zod; Zustand; OpenTelemetry; pnpm workspaces + Turborepo; prek + commitlint; release-please; Docker devbox (Ubuntu 24.04 LTS, non-root `dev`, NET_ADMIN/NET_RAW-only, noexec/nosuid tmpfs, fail-closed DNS, named-volume auth persistence); RLS parameterised over tenancy template via `current_setting('app.current_tenant_id')` + `tenantGuard()`; Google OAuth + email/password at 1.0 with SSO deferred to Growth-tier.

**Critical Decisions (block implementation):** D1 `tenantGuard()` mechanism; D2 migration strategy; D3 synthetic-schema tiered strategy; S3 security-evidence schema; S5 §Egress-Policy Mechanism; G1–G6 §Generator-Normalization-Algorithm; R1 halt schema extensions; R2 `Required tests:` manifest format; R7 §Ralph Path-Resolution Contract.

**Important Decisions (shape architecture):** D4 §RLS-Performance-Budget; S1 session storage & cleanup; S2 step-up middleware pattern; S4 prompt-injection scan tier; A1–A4 tRPC patterns; F1 component library; F2 design-token manifest; F3 routing & data-loading; F4 Zustand posture; I2 CI/CD workflows; I4 OTel defaults; I5 §Devbox-Reference-Config; R3 PR-lifecycle state machine; R4 knowledge-file upkeep.

**Deferred Decisions (post-MVP with rationale):** F1 component-library version pinning (pin at M7 vendor-in); S4 LLM-based nightly prompt-injection scan (empirical evidence needed first); S6 weekly money-path promotion to nightly (post-M9 empirical); I1 hosting Dockerfile presets (Growth-tier consumption-driven); D4 §RLS-Performance-Budget numeric refinement (2-week p95 baseline post-M1 produces the final number).

### Data Architecture

**D1. Tenant-scoping mechanism (`tenantGuard()` implementation).** Prisma Client Extension (`$extends`) with query-interception + transaction-wrapped `SET LOCAL app.current_tenant_id`. Per-request tx opens in a tRPC middleware, sets the session-local, runs the handler, commits. Modern Prisma-sanctioned hook (middleware `$use()` is deprecated); `SET LOCAL` inside a transaction is the cleanest RLS semantic — no cross-request leak, no connection-pool bleed, PgBouncer-compatible (transaction pooling mode). **Affects:** `packages/db`, `packages/core/auth`, every tenant-scoped tRPC procedure.

**D2. Migration strategy.** `prisma migrate deploy` (forward-only, snapshot-based). Ephemeral-pg CI applies the full migration chain on each pre-merge-slow run (≤10min). Generator-emitted RLS policies land as SQL executed via `prisma db execute` inside companion migrations whose filenames encode the generator content-hash — drift between `keel.config.ts` and applied RLS becomes a migration-file diff. **Affects:** `packages/db/migrations/`, `packages/keel-generator`, M0.7 + M9.

**D3. Synthetic-schema strategy for RLS tests (resolves Murat's open concern).** Tiered:

- **Pre-merge-fast (≤3min):** RLS unit tests against `@electric-sql/pglite` (WASM in-memory Postgres) — millisecond-fast, RLS-compatible.
- **Pre-merge-slow (≤10min):** RLS integration tests against Docker-backed ephemeral Postgres via `testcontainers-node` for faithful policy semantics, PL/pgSQL, extensions.

**Affects:** pre-merge-fast CI, pre-merge-slow CI, `packages/db/test-utils`, M9.

**D4. §RLS-Performance-Budget (PRD handoff; refines NFR3 placeholder).** Budget is a **p95 wall-clock delta** measured via benchmark harness running the same query with and without RLS on a seeded dataset. Seed: 10k rows across 100 tenants (`team` template, 100 rows/tenant) + 10k rows across 10k tenants (`user` template, 1 row/tenant). Benchmark lives in nightly (≤60min, stable timing). Monthly review via NFR28c cadence; p95 delta > 20% for two consecutive monthly baselines flags NFR3 breach → triage. **Affects:** nightly CI, `packages/db/bench`, NFR3 architecture-ref.

### Authentication & Security

**S1. Session storage schema & cleanup.** better-auth DB-backed sessions → Prisma schema adds `Session` + `Account` tables. pg-boss scheduled job `session-cleanup` runs daily to delete expired sessions. **Affects:** `packages/db/schema.prisma`, `packages/jobs/scheduled/session-cleanup.ts`, M2 + M4.

**S2. Step-up middleware pattern.** tRPC middleware `requireRecentAuth({ maxAge: '5m' })` checks session `lastActivity` + `mfaVerifiedAt`. On expiry returns `UNAUTHORIZED` with `code: 'STEP_UP_REQUIRED'`; client catches, redirects to re-auth flow. Applied to all billing routes + tenant-admin routes. **Affects:** `packages/core/auth/middleware.ts`, `packages/contracts`, `apps/web`.

**S3. Per-iteration security-evidence schema (resolves Murat's open concern on parseability).** Structured JSON (not free-text markdown). Ralph halt-logic reads `halt_required` (boolean) + `overall_severity_max` (enum). Critical → immediate halt via `.ralph/halt` with `reason: "SECURITY_CRITICAL"`:

```json
{
  "iteration_id": "<uuid>",
  "diff_sha": "<hash>",
  "timestamp": "<ISO8601>",
  "scans": {
    "secrets":          { "tool": "gitleaks",   "findings": [], "severity_max": "none" },
    "deps":             { "tool": "pnpm audit", "findings": [], "severity_max": "low"  },
    "sast":             { "tool": "semgrep",    "findings": [], "severity_max": "none" },
    "prompt_injection": { "tool": "custom",     "findings": [], "severity_max": "none" }
  },
  "overall_severity_max": "low",
  "halt_required": false
}
```

Severity enum: `none | low | medium | high | critical`. **Affects:** `packages/keel-invariants/security-evidence.schema.json`, `.ralph/logs/<iter-id>/security-evidence.json`, Ralph halt-logic.

**S4. Prompt-injection scan implementation tier (resolves Murat's open concern under ≤10s budget).** Regex + AST at pre-commit (hard ≤10s constraint). Rules detect: (a) zero-width Unicode in committed files, (b) known jailbreak trigger strings in agent-reachable markdown (`AGENTS.md`, `CLAUDE.md`, `RALPH.md`, `.ralph/@plan.md`, story files, upstream docs), (c) suspicious git-diff patterns (new `--dangerously-skip-permissions` outside `packages/devbox`, `rm -rf /` in scripts, new shell-eval from agent-authored docs). LLM-based deep scan **deferred to nightly tier** (≤60min) where budget allows. Both tiers persist findings to security-evidence.json. **Affects:** `packages/keel-invariants/prompt-injection-rules/`, pre-commit hook, nightly CI.

**S5. §Egress-Policy Mechanism (PRD handoff for FR1a).** Belt-and-braces: repaired dnsmasq (DNS authority + JSONL query log for FR1a observability) + nftables (layer-3 egress enforcement at packet level for IPv4 + IPv6 default-deny, closes the "dnsmasq slow/restarting" and "IPv6 bypasses dnsmasq" holes). Both reload atomically via `pnpm devbox:whitelist sync` which rewrites `whitelist.default.txt` + `nft` table + reloads dnsmasq under a single shell-script guarded by a file lock. Repo-tracked whitelist (`packages/devbox/whitelist.default.txt` + per-fork override) so `git reset` restores a known network posture. **Affects:** `packages/devbox/`, FR1a mechanism resolution, M0.5 (d).

**S6. Release-gated security baseline promotion path.** Paddle sandbox + Google OAuth live money path runs at release-gated only at 1.0 (PRD FR30). Weekly synthetic money path in nightly deferred post-M9 — first tag weekly money-path as a nightly-candidate cell, gate promotion behind 4 consecutive green runs. **Affects:** NFR17 / FR30, nightly CI post-M9.

### API & Communication Patterns

**A1. tRPC transport.** HTTP with `httpBatchLink` (TanStack Start SSR-native). WebSocket transport deferred to Growth-tier (no real-time-collab at 1.0). **Affects:** `packages/contracts`, `apps/web/app/trpc-client.ts`.

**A2. tRPC middleware stack order.** `openTelemetry` → `loggerContext` → `tenantGuard` (D1) → `requireAuth` → `requireRecentAuth` (when applicable) → handler. OTel first so all downstream middleware is traced. **Affects:** `packages/contracts/middleware/`.

**A3. Error-handling standard.** tRPC errors with `code` enum: `UNAUTHORIZED | FORBIDDEN | NOT_FOUND | BAD_REQUEST | INTERNAL_SERVER_ERROR | STEP_UP_REQUIRED | TENANT_MISMATCH`. Zod validation errors auto-map to `BAD_REQUEST`. Human-readable messages are i18n-keyed via typed-key enforcement (FR27). **Affects:** `packages/contracts/errors.ts`.

**A4. Webhook signature-verification pattern.** Paddle webhook handler validates via Paddle's official SDK `verifyWebhookSignature()`. Per-handler idempotency key persisted in Postgres: table `webhook_events`, PK `(provider, event_id)` unique. Idempotent lifecycle handling per FR30. **Affects:** `packages/billing/webhooks/paddle.ts`, `packages/db/schema.prisma`, M3.

### Frontend Architecture

**F1. Component library.** shadcn/ui + Radix primitives (matches UX spec's canonical reference: copy-into-repo, CSS-variable tokens, Radix a11y primitives, AA-first, `components.json` designed for LLM parsing). Vendor-in-repo: zero external-dependency drift; version-pin is "what we vendored when." Composition-pattern references from Tailwind UI / Catalyst without code licenses. **Affects:** `packages/ui`, `docs/design/catalog.md`, M7.

**F2. Design-token manifest (cross-runtime contract).** Single source: `packages/keel-invariants/design-tokens.ts` (typed). Emits at build time: (i) Tailwind v4 `@theme` config; (ii) Textual `app.tcss` theme. Sync-enforced pre-merge via content-hash on `design-tokens.ts` + consumer-hash verification. Categories: color semantics (status/severity matching S3 enum), type scale, spacing rhythm, motion, density, focus ring. **Affects:** `packages/keel-invariants`, `packages/ui`, Ralph TUI theme, cross-layer sync gate.

**F3. Routing & data-loading.** TanStack Router file-based routes + `loader` functions for server-side data + `defer` / `Await` for streamed SSR. Per-route `loader` carries tRPC server-side calls (unified client). Route-loader-scoped feature-flag evaluation per FR21. **Affects:** `apps/web/app/routes/`, `packages/flags`.

**F4. Zustand usage posture.** Client-only ephemeral UI state (modal open/closed, form draft, wizard step). Server state is tRPC query cache (`@tanstack/react-query`, bundled with TanStack Router). **No Zustand state hydrated from SSR.**

**Persistence exception.** Zustand's `persist` middleware targeting `sessionStorage` (default) or `localStorage` (rare, justified) is permitted **only** where it delivers real user benefit — e.g., multi-step signup form draft surviving accidental reload, sidebar collapsed/expanded state within a session, unsent-comment recovery. Rules:

1. **Default to `sessionStorage`.** Use `localStorage` only when persistence-across-sessions has a named benefit (documented in the store's rationale comment).
2. **Never persist PII, auth tokens, tenant IDs, or billing state.** Gitleaks + Semgrep rule enforced at pre-commit.
3. **Every persisted store carries a `version` + `migrate()` fn** (Zustand `persist` option) — schema drift across releases must not silently corrupt user state.
4. **Hydration is lazy** (client-mount only); SSR render assumes the default state.
5. **Rationale comment required** at store definition (e.g., `// persist: sessionStorage — keeps in-flight signup draft across accidental reload`).

**Affects:** `apps/web`, `packages/ui`, `packages/keel-invariants/semgrep-rules/`.

### Infrastructure & Deployment

**I1. Hosting at 1.0.** None pinned. Keel ships fork-and-use; deploy-target is fork-chosen. Optional `Dockerfile.<target>` presets (Vercel, Fly, Railway) deferred to Growth-tier per PRD. `release-gated` CI runs against localhost/ephemeral-pg, not a real environment. **Affects:** PRD Out of Scope preserved.

**I2. CI/CD pipeline implementation.** GitHub Actions with five workflows matching the 5-tier CI pyramid. Path-based gate-profile split per FR53: `packages/**/*` vs `docs/**/*` vs `_bmad-output/**/*` receive different gate profiles (code changes → all tiers; docs changes → pre-commit + pre-merge-fast only). Matrix-driven for shape × tenancy combinatorics in nightly (2×2 = 4 cells at 1.0).

**NFR28b empirical baseline — honesty reframe (Party-Mode-driven).** The PRD's NFR28b asks for a 2-week p95 empirical baseline before minute budgets lock as invariants. At N=1 with a 4-day M9 budget, no 2-week organic traffic exists. Rather than fake the baseline, the architecture commits to two-phase honesty:

- **At 1.0 (M9):** ship the CI pipeline + minute budgets + harness. Budgets are **modeled targets** derived from local-dev measurements + synthesized PR traffic. Explicitly labelled as such in `.github/workflows/*.yml` comments and in `docs/invariants/ci-budgets.md`.
- **At M10 (or first 2-week real-traffic window, whichever comes first):** re-baseline against empirical p95 per NFR28b's original schema. If the modeled budgets materially underestimate, widen them via an explicit amendment PR (same ceremony as other invariants).

Don't claim empirical what is modelled. Research-output richness requires integrity about measurement provenance. **Affects:** `.github/workflows/`, `docs/invariants/ci-budgets.md`, M9 + M10.

**I3. Environment configuration.** `.envrc` (direnv-compatible) at repo root + `.envrc.example` committed. Loads per-fork: Postgres URL, Paddle API key, Resend API key, Google OAuth secret, `ANTHROPIC_API_KEY` (Tier-2 deviation path only), devbox resource knobs. Never committed: `.env`, `.envrc` (local). **Affects:** `packages/devbox/`, `.envrc.example`, forker onboarding.

**I4. Observability exporter defaults.** OpenTelemetry SDK with console-exporter default when `OTEL_EXPORTER_OTLP_ENDPOINT` unset (prevents network errors in dogfood / CI); OTLP exporter when set. Sampling: 100% for errors, 10% for non-error traces in production forks (override via `packages/config`). Trace propagation through tRPC middleware (A2). **Affects:** `packages/core/otel.ts`, `packages/contracts/middleware/opentelemetry.ts`, M5.

**I5. §Devbox-Reference-Config (PRD handoff for NFR8 / NFR8a).** `packages/devbox/.envrc.example` holds retunable defaults calibrated to Apple-Silicon M4-Pro baseline:

```bash
# Reference defaults (retunable per NFR8a; NOT PRD requirements)
KEEL_DEVBOX_ARCH=linux/arm64
KEEL_DEVBOX_CPUS=8
KEEL_DEVBOX_MEMORY_GB=12
KEEL_DEVBOX_SHM_GB=2
KEEL_DEVBOX_NOFILE=65536
KEEL_DEVBOX_TMPFS_TMP_GB=2
KEEL_DEVBOX_TMPFS_VAR_TMP_GB=1
KEEL_DEVBOX_TMPFS_LOGS_MB=500
KEEL_DEVBOX_PORT_WEB=3000
KEEL_DEVBOX_PORT_API=3001
KEEL_DEVBOX_PORT_STORYBOOK=6006
KEEL_DEVBOX_PORT_VITE_HMR=24679
KEEL_DEVBOX_SSH=false
KEEL_DEVBOX_SHARED=false
```

Non-Apple-Silicon or resource-constrained forks override via per-fork `.envrc`. **Affects:** `packages/devbox/.envrc.example`, `packages/devbox/docker-compose.yml`, NFR8 / NFR8a.

**I6. Dev container secrets & env var management (simplest-workable posture).** Single dotfile → devbox, Vite-native VITE_-prefix for client-runtime, typed `getSecret()` for server-side access, boot-time Zod validation. No pluggable provider shim (Victor: "the shim is scar tissue from imagined future consulting gigs"; Winston: addressed because the shim doesn't exist, so the unexercised-interface risk disappears).

**Host-side plumbing:**

- `.envrc` (gitignored) at repo root, direnv-compatible; `.envrc.example` (committed) lists every required key with scrubbed values + inline comments. This is the canonical schema.
- `packages/devbox/docker-compose.yml` uses plain `env_file: ../../.envrc` — no allow-list codegen, no `env-passthrough.ts`. Whatever's in `.envrc` flows to the devbox. Maintenance surface: one file.

**Client-runtime env vars (front-end build):**

- Any env var whose key starts with `VITE_` is inlined into the `apps/web` client bundle at build time per Vite's native convention. Accessed as `import.meta.env.VITE_FOO` in client code.
- Non-`VITE_` env vars stay server-side — never bundled, never shipped to the browser.
- No custom wiring in `vite.config.ts`; TanStack Start inherits Vite's behaviour directly.

**Typed secret access (server-side):**

- `packages/config/src/env.ts` — two Zod schemas (`ServerEnv`, `ClientEnv`), parsed once at module load. Missing required keys fail-closed with an actionable error pointing at `.envrc.example`.
- `packages/config/src/secrets.ts` — exports `getSecret<K extends ServerSecretName>(name: K)` that returns `serverEnv[name]` with full TypeScript typing. Typo-catching (`getSecret('PADLE_API_KEY')` fails typecheck); autocomplete on secret names; single place to discover what's required.
- `getSecret()` is a thin typed accessor over the parsed Zod object — no provider dispatch, no async, no runtime indirection beyond what Zod already does at boot.
- **Never construct secret names dynamically.** Call sites use string literals matching the typed enum; Semgrep rule forbids `getSecret(\`PADDLE_${env}_API_KEY\`)`-style template construction.

**Redaction & leak prevention (orthogonal to how secrets are read):**

- Structured logger (`packages/core/logger.ts`) redacts any field matching known secret patterns (`/api[_-]?key/i`, `/token/i`, `/secret/i`, `Bearer\s+.+`, Postgres DSNs) before emission. Applied at the logger-context tRPC middleware boundary (A2).
- Gitleaks in pre-commit (S3 scan list) blocks committed secret patterns; `.gitleaksignore` forbidden in `packages/*` (fork-only escape).
- Semgrep rules `no-env-log.yml` + `no-dynamic-secret.yml` forbid `console.log(process.env)`, JSON-stringifying objects containing redactable keys, and dynamic `getSecret()` construction.
- Security-evidence scan (S3) includes the `secrets` category — a finding is `SECURITY_CRITICAL` → halt.

**CI (GitHub Actions):**

- Repo-level secrets (`PADDLE_SANDBOX_API_KEY`, `PADDLE_PROD_API_KEY`, `RESEND_API_KEY`, `GOOGLE_OAUTH_CLIENT_SECRET`, `ANTHROPIC_API_KEY`, `DATABASE_URL_EPHEMERAL`) mapped into workflow env at **step level** (never job level — smaller blast radius).
- Workflow-level env minimisation: pre-commit + pre-merge-fast receive zero external secrets (RLS unit tests run on pglite per D3). Pre-merge-slow gets ephemeral-pg DSN only. Nightly gets sandbox adjacents. Release-gated gets production adjacents.
- `act` local runner: `.secrets` file gitignored, `.secrets.example` committed.

**Secret lifecycle (forker flow):**

- **Adding a secret:** (1) append to `.envrc.example` with scrubbed value + comment, (2) append key to the appropriate Zod schema in `packages/config/src/env.ts` (and the `ServerSecretName` type it re-exports for `getSecret()`). That's it — the `env_file` passthrough picks it up automatically. Two files, no codegen.
- **Rotating:** update the real value source (host `.envrc` / GH Actions secret), restart devbox; `pnpm devbox:env:check` lists key names only (never values) for smoke verification.
- **Removing:** remove from Zod schema → TypeScript compile fails at every call site → clean up references → remove from `.envrc.example`.

**Pre-1.0 audit:**

- M9 pre-release audit: `grep -ri 'process.env\.'` across `packages/*` + `apps/web/app/*` — every server-side match must route through `getSecret()` (except allow-listed non-secret env vars: `NODE_ENV`, `OTEL_EXPORTER_OTLP_ENDPOINT`); every client-side match must use `import.meta.env.VITE_*`. Ships as `pnpm keel:audit-env` script.

**Affects:** `.envrc.example`, `packages/devbox/docker-compose.yml` (`env_file: ../../.envrc`), `packages/devbox/scripts/env-check.sh`, `packages/config/src/env.ts`, `packages/config/src/secrets.ts`, `packages/core/logger.ts`, `packages/keel-invariants/semgrep-rules/`, `.github/workflows/*`, `.secrets.example`, `docs/invariants/secrets.md`, M0 + M9.

**I7. Version pinning at M0 (Party-Mode-driven; three-agent convergence).** Reproducibility serves research-output richness directly — an irreproducible substrate produces a corrupted research corpus. Pin exact versions for these three at M0, gate upgrades through Renovate with grouped-update rules and integration-test requirements:

- **Vitest** — pin exact minor (e.g. `3.x.y` at M0 cut); pinned in `packages/config` + `pnpm.overrides` to block transitive drift. Rationale (Murat): Stryker-Vitest mutation-testing integration is mature; Stryker-node:test is experimental; Vitest's worker-thread model + Vite cache is the fastest pre-merge-fast cold-start; pipeline coherence with TanStack Start (Vite-based) outweighs community size at N=1.
- **OpenTelemetry JS SDK** — pin exact version of `@opentelemetry/sdk-node`, `@opentelemetry/api`, and each instrumentation; `pnpm.overrides` to prevent transitive minor skew. Rationale (Winston, Murat): OTel API/SDK split has had painful minor-version skew through 2024-2025 and hasn't fully stabilised as of early 2026; "latest stable" is a time-bomb.
- **Postgres image with `pg_uuidv7` extension** — pin a specific Docker image tag (e.g. `ghcr.io/fboulnois/pg_uuidv7:<version>`) + bake `CREATE EXTENSION pg_uuidv7;` into the compose init SQL. Rationale (all three agents): UUIDv7 PKs are a schema assumption, not a tooling choice. Silent extension loss on image update breaks every fresh-clone devbox boot and every ephemeral-pg CI run — violates the agent-authorship first-try bar.

**Renovate configuration** lands in M0 alongside the pins — grouped-update rules + mandatory integration-test-passing-required-before-merge for pinned dependencies. `.github/renovate.json` is the authority.

**Affects:** `packages/config/package.json` + root `pnpm-workspace.yaml` overrides, `packages/devbox/docker-compose.yml` + `packages/devbox/pg-init.sql`, `.github/renovate.json`, M0.

### Research Corpus Architecture (dual-posture "research-output wins" infrastructure)

The PRD's dual-posture tie-breaker ("research-output richness wins when it conflicts with substrate ship-velocity") requires a corpus that is mechanically aggregable by future-you / future-LLM / future-reader — not free-form prose that bit-rots into "whatever I wrote that month." These three decisions formalise the corpus as a first-class deliverable on equal architectural footing with the substrate.

**RC1. Corpus layout.** `docs/research/` is the append-only corpus home. These are data artefacts, not runtime code, so the corpus lives in `docs/` rather than `packages/`. Subdirectories:

- `docs/research/sprint-logs/` — monthly blank-starter-sprint entries (`YYYY-MM.md` + companion `YYYY-MM.json`).
- `docs/research/checkpoints/` — quarterly M4 checkpoint entries (absorbs existing `docs/checkpoints/`).
- `docs/research/tripwire/` — monthly aggregated tripwire datapoints (JSON primary, markdown companion). References `docs/absorption-tripwire/vertical-slice-acceptance.md` as the pre-registered criteria.
- `docs/research/README.md` — index, schema pointers, aggregation guidance, citation conventions.

Amendment ceremony matches the vertical-slice-acceptance pattern (PR + rationale in file's own changelog + 24h cooling-off between PR open and merge). Measurement integrity requires that "post-hoc editing to protect the project when the tripwire fires" is architecturally resisted.

**RC2. Typed schemas.** Three JSON Schemas in `packages/keel-invariants/src/schemas/` (same location as halt / plan / security-evidence / rule schemas — consistent with the three-layer invariant pattern):

- `sprint-log.schema.json` — `{ month, slice_id, model_version, keel_ttg_seconds, blank_ttg_seconds, keel_tokens_total, blank_tokens_total, keel_context_exhausted_count, blank_context_exhausted_count, keel_rework_rate, blank_rework_rate, delta_percent, notes }`
- `checkpoint.schema.json` — `{ quarter, date, decision_enum (continue | pause_and_ship | pivot | archive), evidence_paths[], next_evaluation_date, rationale }`
- `tripwire.schema.json` — `{ month, verdict_enum (pass | warn | breach), source_sprint_log_id, consecutive_breach_count, pivot_recommended, raw_datapoints[] }`

All three are machine-parseable, versioned via `$schema`, and consumed by aggregation tooling (RC3). Stable schemas are the precondition for mechanical aggregation of the corpus into a paper / post / published dataset if the research output ever warrants external publication.

**RC3. Aggregation tooling.** `pnpm research:aggregate` CLI at M9 — reads `docs/research/**/*.json`, validates against RC2 schemas, emits a flattened `docs/research/corpus.jsonl` suitable for LLM context loading and dataset publication. Idempotent + deterministic output (same canonical-form discipline as G4). Runs as a nightly CI step so the aggregate stays current without manual work. A stale aggregate is a pre-merge-fast warning (not fail — the corpus is the authoritative source).

**Affects:** `docs/research/`, `packages/keel-invariants/src/schemas/{sprint-log,checkpoint,tripwire}.schema.json`, `packages/keel-invariants/src/research-aggregate.ts`, nightly CI workflow, M9.

### Ralph Loop Contracts (architecture-owned implementation)

**R1. Halt schema extensions (confirms NFR33a).** Pinned JSON: `{"reason": "<enum>", "epic": <N|null>, "pr": "<url|null>", "iteration_id": "<uuid>", "timestamp": "<ISO8601>"}`. Closed enum: `EPIC_DONE | AWAIT_MERGE | BUDGET_EXHAUSTED | CI_BLOCKED | SECURITY_CRITICAL | RALPH_STAGE_REGRESSION`. Architecture extends with `iteration_id` + `timestamp` for log correlation. Path resolution is spec'd separately in **R7** (`$RALPH_BASE_DIR/halt`). **Affects:** `.ralph/halt`, `packages/keel-invariants/halt.schema.json`.

**R2. `Required tests:` manifest format (resolves FR14a2).** Content-hashed, append-only fenced block per-task in `.ralph/@plan.md`:

````
<!-- task:auto:story-42 -->
Required tests:
- id: test-story-42-unit-a (hash: abc123…)
  path: packages/core/auth/__tests__/invite.unit.test.ts::inviteWithVerification_creates_token
- id: test-story-42-rls (hash: def456…)
  path: packages/db/__tests__/rls.integration.test.ts::invite_tokens_rls_blocks_cross_tenant
manifest_hash: <sha256-of-above>
<!-- end -->
````

Pre-merge-fast rejects tasks where `manifest_hash` shrank or the `id` list shrank without a signed `expand:` annotation line naming removed IDs + signer + rationale. Content-similarity measure: **stable-test-id primary, Levenshtein on test name secondary** (stable ID is the stronger check; loosens FR14a2's "Levenshtein-distance" to architecture-chosen equivalent per validation note). **Affects:** `.ralph/@plan.md` schema, pre-merge-fast CI check, `packages/keel-invariants/plan.schema.json`.

**R3. PR-lifecycle state machine.** Authoritative state lives in GitHub PR (`gh pr view --json state,isDraft,reviewDecision,statusCheckRollup`); mirrored to `.ralph/@plan.md`. Ralph reads at orient; pure function `transition(pr_state, epic_state) → action` implemented in `.ralph/lib/pr-state.ts` (TypeScript, invoked via `tsx`). Same six rows + three anti-constraints as PRD's decision matrix. **Affects:** `.ralph/lib/`, orient-phase contract, FR14h.

**R4. Knowledge-file upkeep contract.** Per FR14j: `AGENTS.md` (shared operational), `CLAUDE.md` (Claude-Code-specific), `RALPH.md` (Ralph-private). Every iteration's commit includes a diff to at least one of the three OR a justification comment in the commit body explaining why nothing was learned. Pre-commit hook emits a warning (not a hard fail) if all three are untouched AND no justification found; Ralph honours the warning by prompting itself to reflect. **Affects:** pre-commit hook, Ralph prompt files, M9.

**R5. Headless Ralph `--no-tui` as research instrumentation (Party-Mode-driven reclassification).** Originally deferred to Growth-tier in the PRD; promoted to M0/M1 research infrastructure because the TUI is a human-observation interface and the dual-posture tie-breaker makes structured data collection primary. A TUI cannot be driven by a cron job or GitHub Action without losing measurement integrity (Victor, 2026-04-19 pressure-test: "If the tripwire measurement is run by you, manually, watching a TUI, measurement integrity is already compromised").

- **Flag:** `ralph.py --no-tui` (or the equivalent in a refactored harness) — suppresses the Textual UI, writes structured JSON to `.ralph/logs/<iteration-id>/` and a concluding summary line to stdout, exits with a known code.
- **Use cases at 1.0:** monthly blank-starter-sprint runs (tripwire harness); scheduled GitHub Actions or cron-driven sprint re-runs for model-version drift testing; reproducible re-runs for RC3 aggregation.
- **Non-use:** the default interactive build/plan loop stays TUI-driven — the research-instrumentation framing doesn't deprecate the human-observed default.
- **Output contract:** structured JSON matching the RC2 sprint-log schema emitted to `docs/research/sprint-logs/YYYY-MM.json` on completion; stdout summary includes a single JSON line for shell-pipe consumption.

**Affects:** `ralph.py` (or successor harness), `.ralph/logs/`, RC2 sprint-log schema, `docs/research/sprint-logs/`, M0 (flag plumbing) + M1 (first empirical run against the harness).

**R6. Flake measurement layer at 1.0 (Party-Mode-driven; enforcement deferred).** Flakiness at N=1 under Ralph is existentially worse than on a human team — Ralph sees a flaky test, marks an iteration red, burns a cycle. Murat's risk framing: flake is a multiplier on wasted agent-iterations, the scarcest resource in this architecture. But enforcement (quarantine policy, PR-fail thresholds) requires ~500+ iterations of statistically-meaningful history that doesn't exist at 1.0.

**Split the difference:**

- **Ship at 1.0 (measurement):** per-test outcome logging to `.ralph/flake-log/YYYY-MM/<date>.jsonl` — one JSON line per test execution with `{ test_id, iteration_id, outcome (pass|fail|skip), duration_ms, attempt_number, timestamp }`. Vitest reporter + CI workflow hook both emit the same shape. Stable test IDs (per C4 convention below) are the key.
- **Defer to M10 / first empirical breach (enforcement):** quarantine policy, 7-day p95 pass-rate thresholds, PR-fail gates. Built on measurement data once there's enough to be meaningful; cant-free because the data justifies the gate.

The research-output framing: flake data is itself a research artefact. Aggregation into `docs/research/flake-log/` summary markdown is a deferrable tool; raw JSONL is sufficient at 1.0.

**Affects:** `.ralph/flake-log/`, `packages/keel-invariants/src/schemas/flake-log.schema.json`, Vitest custom reporter in `packages/keel-invariants/src/flake-reporter.ts`, GH Actions workflow reporter step, M9 (measurement ship) + M10-or-breach (enforcement build).

**R7. §Ralph Path-Resolution Contract (confirms FR14k + NFR33a).** The orchestrator (`ralph.py` or fork successor) and the agent (`claude --worktree X`) MUST resolve `.ralph/halt`, `.ralph/@plan.md`, `.ralph/PROMPT_*.md`, and `.ralph/logs/` to the same absolute directory, regardless of the orchestrator's cwd. Algorithm:

```
if cfg.worktree == "":                        # single-checkout fallback
    ralph_base = abspath(cwd / ".ralph")
else:                                         # worktree mode
    main_repo = parent(`git rev-parse --git-common-dir`)
    ralph_base = main_repo / ".claude/worktrees" / cfg.worktree / ".ralph"
```

`git rev-parse --git-common-dir` is cwd-invariant — it points at the main repo's `.git/` whether ralph.py was invoked from the main repo or from inside a worktree, so the resolved path is deterministic in both invocation modes.

**Env contract.** Orchestrator MUST export `RALPH_BASE_DIR` (absolute) into the subprocess env alongside `CLAUDE_CODE_TASK_LIST_ID` / `RALPH_ISSUE_NUMBER`. Agents MUST address halt, @plan.md, and PROMPT files via `$RALPH_BASE_DIR` or via relative `.ralph/*` paths (which coincide with `$RALPH_BASE_DIR` when the agent cwd is the worktree) — **never** via hardcoded main-repo absolute paths. A startup banner emits `Ralph base: <abs> (cwd: <abs>)` as the first line of every session log so mismatches surface visibly.

**Defensive dual-path.** During the transition window (while legacy agents may still carry the pre-fix "write halt to main-repo abs path" rule in memory), orchestrator halt detection SHOULD also check `cwd/.ralph/halt` as a fallback, migrate it to the canonical `$RALPH_BASE_DIR/halt` path, and log a warning. Remove the fallback at the next Keel major release after all downstream prompt/knowledge sets have migrated.

**Why this matters.** The 2026-04-20 Story 1.7 iter-22..28 re-entry cascade was root-caused to a cwd-relative halt detection in `ralph.py` racing against an agent that had been told to write halt at the main-repo absolute path. When the orchestrator's cwd shifted to the worktree (user launched ralph.py from inside `.claude/worktrees/ralph`), the two paths diverged and ralph.py never saw the halt; the loop fired eight zero-action iterations inside a single process before the user killed it. A deterministic resolver + env var closes this class of bug without adding complexity to the agent prompt (the agent continues to use `.ralph/halt` relative to its own cwd, which is the worktree, which agrees with `RALPH_BASE_DIR`).

**Affects:** `ralph.py` resolver + env-var injection + startup banner + defensive dual-path halt read; `docs/invariants/ralph-execute.md` § Path Resolution; `INVARIANTS.md` `INV-ralph-halt-path-resolution` row; `docs/ralph.md` § Halt path resolution; `CLAUDE.md` / `AGENTS.md` / `RALPH.md` / `.ralph/PROMPT_build.md` halt-command clarifications; Story 1.9 sync-gate walker (enforces path-resolution drift detection between ralph.py source + docs + manifest entry).

### §Generator-Normalization-Algorithm (PRD handoff for FR67)

**G1. Signature.** `expand(policy: TenancyPolicy, config: KeelConfig) → Rule[]` — pure TypeScript function, no I/O, no `Date.now()`, no `Math.random()`.

**G2. Ordering lattice.** Input `policy.rules: Rule[]`; output sorted by `(rule.target.table, rule.target.op, rule.id)` lexicographically — stable under input permutation (order-independent property).

**G3. Merge precedence (config-override → policy-default → template-default).** `KeelConfig.overrides?.rls?.<table>.<op>` wins over `policy.rules` wins over `template.defaultRules`. Conflicts resolved by highest-precedence source silently; no "deep merge" of individual rule fields (prevents ambiguity).

**G4. Canonical form.** Output is a JSON array of `Rule` objects, each with keys in fixed order (`id`, `target`, `predicate`, `using`, `with_check`); whitespace-stable via `JSON.stringify(arr, null, 2)`; trailing newline. Content-hash is `sha256(canonical_form)`.

**G5. Stable rule identity.** `rule.id` is `<table>_<op>_<tenancy>_<version>` (e.g., `users_select_team_v1`) — collision-free by construction, survives cosmetic rewrites. Versioning: increment when semantic meaning changes; rename alone (same hash) is not a semantic change.

**G6. Idempotence proof.** Pre-merge-fast runs `expand(expand(policy, config)) === expand(policy, config)` (content-hash equality) — catches round-trip regressions. **Affects:** `packages/keel-generator/`, `packages/keel-invariants/rule.schema.json`, M0.7 + M9.

### Acknowledged Hygiene Items (Party-Mode-driven; ≤1 paragraph each)

These are items flagged in the 2026-04-19 Party-Mode pressure-test that don't warrant full decisions but need to be written down before the architecture locks so the answer is in the record when the first bug surfaces.

**C1. pg-boss retry / idempotency / dead-letter posture.** Use pg-boss defaults at 1.0: 3 retries with exponential backoff (250ms × 2^n). Idempotency is responsibility-of-caller: every job payload either (a) carries a natural idempotency key (e.g., `(provider, event_id)` for webhook-derived work, A4), or (b) is structurally idempotent (e.g., `session-cleanup` deletes where `expired_at < now()`). Dead-letter handling = manual inspection of `pgboss.job_archive` at 1.0; automated DLQ routing is a Growth-tier concern. Poison-message handling (same job failing after all retries) leaves the row in `archive` with `state='failed'` — no auto-halt, but OTel span records the failure with `error: true`. **Affects:** `packages/jobs/src/worker.ts`, `docs/invariants/jobs.md`.

**C2. Generator reorder-stability.** G1–G6's canonical form hashes the **sorted rule set**, not input file layout. Input perturbations that don't change the rule set (field reorders in `schema.prisma`, comment edits, whitespace-only diffs) MUST NOT produce a new migration. A dedicated invariant test in `packages/keel-generator/reorder-stability.test.ts` permutes policy inputs through a range of structural rewrites and asserts content-hash equality. Part of the M0.7 acceptance criteria for G6. **Affects:** `packages/keel-generator/`, M0.7.

**C3. OTel trace + tenant context propagation across the pg-boss boundary.** Acknowledged hole at 1.0 — the canonical fix is documented, implementation lives in M4 with the jobs cluster. Job payloads include `tenant_id` (top-level field, required) and `traceparent` (W3C trace-context header, required). Worker middleware re-applies `tenantGuard()` to establish `app.current_tenant_id` before the handler runs; OTel SDK restores the parent trace context from `traceparent`. No job reads tenant data without passing through `tenantGuard()` — lint rule enforces this. Cross-boundary integration tests (tRPC handler enqueues → worker picks up → tenant isolation preserved) deferred to Growth-tier; smoke test at M4 only. **Affects:** `packages/jobs/src/worker.ts`, `packages/jobs/src/schemas/*`, `packages/contracts/middleware/opentelemetry.ts`, M4.

**C4. Test-ID stability convention.** R2's `Required tests:` content-hashed manifest depends on stable test IDs. Vitest's default test ID is `describe` + `it` path — cosmetic `describe` refactors would fail the manifest-stability check as "shrinkage." Convention: every test uses explicit IDs matching `^T-\d{4}$` in the test title, e.g., `test('T-0042: inviteWithVerification_creates_token', ...)`. Manifest keys on `T-\d{4}` only; human description can change freely. IDs are allocated from a monotonically increasing counter in `docs/research/test-ids.md` (append-only, never reused). Enforced via ESLint `keel/stable-test-id` rule at pre-commit. **Affects:** `packages/keel-invariants/eslint-rules/stable-test-id.cjs`, `docs/research/test-ids.md`, M9.

### Decision Impact Analysis

**Implementation Sequence (story-planning input):**

1. **M0** — Root scaffold (I3 `.envrc.example`, I6 secrets Zod schema + `getSecret()` typed accessor, I2 GH Actions skeleton, I7 version pinning: Vitest + OTel + `pg_uuidv7` image tag + Renovate config, R5 `--no-tui` flag plumbing, RC1 `docs/research/` directory structure, RC2 research schemas)
2. **M0.5** — Devbox (S5, I5, I6 compose `env_file: ../../.envrc`, C2 generator reorder-stability test scaffold)
3. **M0.7** — Generator (G1–G6 + C2 reorder-stability test as acceptance, D2 migration integration)
4. **M1** — Data model + RLS (D1, D3 pglite + testcontainers, D4 bench harness, R5 first empirical sprint-log entry against the harness)
5. **M2** — Auth (S1, S2)
6. **M3** — Billing (A4 webhooks)
7. **M4** — Email + Jobs (S1 cleanup job, C1 pg-boss retry posture documented, C3 OTel cross-boundary context propagation)
8. **M5** — Observability (I4)
9. **M6** — Flags (F3 loader-scoped)
10. **M7** — Frontend (F1 component library, F2 design tokens, F4 Zustand posture)
11. **M9** — CI hardening (all `pre-merge-fast` additions: D3 tiered, S3 evidence, S4 pre-commit regex, R2 manifest check, R3 state machine, G6 idempotence, I6 Semgrep secret rules + `pnpm keel:audit-env` + two-way sync check (`.envrc.example ↔ env.ts`), R6 flake measurement layer, RC3 research aggregation CLI `pnpm research:aggregate`, NFR28b modeled-target labelling, C4 test-ID stability ESLint rule)
12. **M10 (or first 2-week real-traffic window)** — NFR28b empirical re-baseline; R6 flake enforcement (if data warrants)

**Cross-Component Dependencies:**

- D1 depends on S2 (middleware order) depends on A2 (middleware stack).
- D4 bench depends on D3 (ephemeral-pg). Budget review in NFR28c cadence.
- F2 tokens are upstream of F1 (library imports tokens), upstream of Ralph TUI theme (same source).
- G1–G6 block D2 (migration files embed generator output via `prisma db execute`).
- R2 depends on S3 (evidence schema), depends on R1 (halt schema), depends on C4 (stable test IDs).
- R5 `--no-tui` depends on RC2 sprint-log schema (output contract).
- RC3 aggregation CLI depends on RC2 schemas + RC1 corpus layout.
- S5 dnsmasq + nftables dual-mechanism touches FR1a observability (dnsmasq JSONL log) + enforcement (nftables).
- I7 version pinning unblocks every downstream test + observability decision (D3, D4, I4, R6).
- C3 OTel cross-boundary depends on I4 (OTel SDK init) and the jobs package payload schema.

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

Conflict points identified for Keel's 2026 agent-authorship surface: DB naming; API naming; Code + file naming; Project organisation; Test colocation; tRPC shape; Error format; Date/time format; JSON field casing; Event + job naming; State update patterns; Error recovery; Loading states; Design-token IDs; i18n key paths; Commit format; PR titles; Knowledge-file voice. Every pattern below is written so two different agent instances (Claude Code instance A vs instance B, or Claude vs Codex) arrive at the same code. Branching options = design-system failure.

### Naming Patterns

**Database (Postgres / Prisma):**

- **Tables:** `snake_case`, **singular** (`user`, `team`, `invite_token`). Prisma maps `User` model → `user` table via `@@map`; singular matches RLS policy reading (`policy_on_user`, not `policy_on_users`).
- **Columns:** `snake_case` (`created_at`, `tenant_id`, `mfa_verified_at`). Prisma field aliases via `@map`.
- **Foreign keys:** `<parent>_id` (`team_id`, `user_id`). Never `fk_`-prefixed.
- **Indexes:** `idx_<table>_<column(s)>` (`idx_user_email`, `idx_invite_token_team_id_created_at`).
- **RLS policy names:** `policy_<table>_<op>_<tenancy>_<version>` matching the generator's `rule.id` (G5).
- **Enums:** singular `snake_case` (`enum membership_role`).
- **Session vars:** `app.<name>` prefix (`app.current_tenant_id`).

**TypeScript / TanStack / tRPC:**

- **Types / classes / React components:** `PascalCase` (`InviteToken`, `<SignupForm />`).
- **Variables / functions:** `camelCase` (`inviteToken`, `createInviteToken()`).
- **Constants:** `SCREAMING_SNAKE_CASE` only for module-global immutables (`DEFAULT_SESSION_MAX_AGE`). Otherwise `camelCase const`.
- **tRPC procedures:** `camelCase` verb-first (`inviteTeamMember`, `cancelSubscription`). Never passive.
- **tRPC routers:** `camelCase` nouns (`router.team.invite`).
- **Zod schemas:** `<Name>Schema` suffix (`InviteTokenSchema`). Inferred type same name without suffix: `type InviteToken = z.infer<typeof InviteTokenSchema>`.
- **Hooks:** `useXxx` (`useTenantContext`).

**Files & directories:**

- **React components:** `PascalCase.tsx` (`SignupForm.tsx`).
- **Non-component TS modules:** `kebab-case.ts` (`tenant-guard.ts`, `trpc-client.ts`).
- **Route files** (TanStack Router file-based): `kebab-case.tsx` per TanStack convention (`signup.tsx`, `billing.cancel.tsx`).
- **Test files:** `<source>.test.ts` or `<source>.test.tsx` colocated next to source (no top-level `__tests__/`). Keeps FR14a2 `Required tests:` paths short + stable + greppable.
- **Integration tests:** `<source>.integration.test.ts` suffix; tier gate by suffix (pre-merge-slow + nightly only).
- **Fixtures:** `<source>.fixtures.ts` colocated.
- **Markdown docs:** `kebab-case.md`.

**API / URL:**

- **tRPC procedure paths:** auto-generated from router structure (`team.invite.create`). No REST-style `/api/team/invite`.
- **Webhook routes** (only non-tRPC HTTP surface): `/webhooks/<provider>` — always POST (`/webhooks/paddle`, `/webhooks/resend`).
- **OAuth callback routes:** `/auth/callback/<provider>` (`/auth/callback/google`).

### Structure Patterns

**Project organisation (PRD-pinned):**

```
apps/web/                          # TanStack Start (sole 1.0 app)
  app/
    routes/                        # TanStack Router file-based routes
    components/                    # shadcn/ui-vendored + composition
    lib/                           # app-scoped helpers (no exports)
packages/
  db/              contracts/   config/    core/         billing/
  email/           jobs/        flags/     audit/        ui/
  keel-invariants/ keel-generator/         keel-templates/
  devbox/
```

**In-package layout (every `packages/*`):**

```
packages/<name>/
  src/
    index.ts                       # Public surface — ONLY export from here
    <feature>/
      <feature>.ts                 # Implementation
      <feature>.test.ts            # Colocated unit test
      <feature>.fixtures.ts        # Colocated fixtures (optional)
  package.json
  tsconfig.json                    # Extends keel-invariants/tsconfig.base.json
  README.md                        # Purpose + public surface + stable-ID refs
```

**Test colocation rules:**

- **Unit tests:** `.test.ts` next to source. Pre-merge-fast + nightly.
- **Integration tests:** `.integration.test.ts`. Pre-merge-slow + nightly.
- **E2E tests:** `apps/web/e2e/*.e2e.test.ts`. Nightly only.
- **No top-level `__tests__/` folders.** Anti-pattern; separates exercise from subject, breaks grep-find.

**Public surface enforcement:**

- **Only `src/index.ts` exports.** Imports from `@keel/<pkg>/internal/*` rejected by ESLint `no-restricted-imports` (hardwired in `packages/keel-invariants/`).
- **Cross-package imports via `@keel/<pkg>` alias** (defined in `tsconfig.base.json` `paths`).
- **No relative imports crossing `src/` boundary.** ESLint rule.

**Routes vs components:**

- **Routes live in `apps/web/app/routes/` only.** Page-template logic (shape-aware composition) lives in `packages/ui/page-templates/`. Routes import + compose; routes never define a template inline.
- **Shape-aware split:** `packages/ui/page-templates/{b2b, b2c, shared}/`. A page template imported from the wrong shape is an ESLint rule violation.

### Format Patterns

**tRPC responses:**

- **No API response wrapper.** tRPC return value is the response; `TRPCError` is the error. No `{ data, error }` wrappers — tRPC's own shape is idiomatic and what `@tanstack/react-query` expects.
- **Success return:** the router output type's data shape. No metadata envelope; pagination fields sit inside the return: `{ items, nextCursor }`.
- **Error return:** `throw new TRPCError({ code, message, cause })` — `code` from A3 enum; `message` is an i18n key (`error.auth.step_up_required`); client renders via typed-key i18n.
- **Null vs undefined:** `undefined` for absent; `null` for explicit-absent. Optional fields use `?:`; never `| null | undefined` union. Zod `nullable()` only where `null` carries semantics.

**JSON field casing:**

- **tRPC payloads:** `camelCase` (auto, since TS types flow through).
- **Webhook-incoming payloads:** provider-native (Paddle sends `snake_case`) — wrap and re-shape at the boundary via Zod `schema.parse()` inside `packages/billing/webhooks/paddle.ts`.
- **Persistent JSON files** (`security-evidence.json`, halt, `.ralph/@plan.md` fenced blocks, generator canonical form): `snake_case` per existing PRD schemas.
- **Rationale:** camelCase at runtime boundaries; snake_case for persisted artefacts — matches Postgres convention + grep-friendliness.

**Dates & times:**

- **Wire format** (tRPC, JSON, logs): ISO 8601 UTC with Z suffix (`2026-04-18T13:42:17.123Z`).
- **Database:** `timestamptz`. Prisma emits `DateTime`.
- **In-code:** `Date` in TypeScript. No Moment / Luxon / date-fns as cross-package exports — date arithmetic goes through `packages/keel-invariants/dates.ts` helpers (`utcNow()`, `addMinutes()`, `isExpired()`).
- **UI display:** `Intl.DateTimeFormat` with user locale (FR24–FR27 i18n path). Never hardcoded formats.

**Booleans:**

- `true` / `false`, never `1` / `0` (except as RLS policy return values where Postgres expects them).
- Field names read as predicates: `isExpired`, `hasMfa`, `canInvite` — not `expired`, `mfa`, `invite`.

**IDs:**

- **UUIDv7** for all new-row PKs (sortable by time; `pg_uuidv7` extension). Prisma default via `@default(dbgenerated("uuidv7()"))`.
- **Typed IDs** at TS layer via Zod branded types: `z.string().uuid().brand<'TenantId'>()` — prevents `userId` passed where `tenantId` is expected.

### Communication Patterns

**Event + job naming:**

- **pg-boss job names:** `<domain>.<action>` dotted (`email.send_verification`, `billing.process_paddle_webhook`, `session.cleanup`). Registered in `packages/jobs/registry.ts` as a typed map → agents cannot invent ad-hoc job names.
- **Audit-log event types:** `<resource>.<verb>` past-tense (`user.signed_up`, `subscription.created`, `invite.accepted`). Stored in `audit_log.event_type` column.
- **OpenTelemetry span names:** `<package>.<operation>` (`trpc.team.invite.create`, `db.user.findMany`, `job.email.send_verification`). Set via OTel middleware A2.
- **OTel attribute keys:** `keel.<namespace>.<attr>` (`keel.tenant.id`, `keel.shape`). All keel-scoped attributes under `keel.*` namespace.

**State management (Zustand + TanStack Query):**

- **Server state:** TanStack Query (bundled with TanStack Router). Query keys are `[<procedure-path>, <input>]` tuples per tRPC convention. No manual `fetch`.
- **Client ephemeral state:** Zustand. One store per feature (`useSignupFormStore`, `useBillingModalStore`). Shape: `{ state, actions }`; never mix selectors into actions.
- **Immutable updates always** (Zustand via Immer middleware if mutation syntax desired). Never mutate state outside an action.
- **No global "app state" god-store.** Anti-pattern.

**i18n key paths:**

- Dot-separated `<domain>.<surface>.<key>` (`auth.signup.title`, `billing.checkout.confirm_button`, `error.auth.step_up_required`).
- Keys typed via codegen from the English baseline locale; bare strings in `.tsx` fail the build (FR27).
- Never concatenate keys at runtime. Use interpolation params: `t('billing.receipt.total', { amount: formatted })`.

### Process Patterns

**Error handling:**

- **Boundaries:** one React error boundary per top-level route via TanStack Router `errorComponent`. Catches render errors; logs to OTel; renders i18n-keyed recovery UI.
- **tRPC errors** flow `TRPCError` → `@tanstack/react-query` → `useQuery.error` / `useMutation.error`. Never swallow; always surface to UI via i18n key.
- **Server-side unexpected errors:** caught by `openTelemetry` middleware (A2), re-thrown as `TRPCError({ code: 'INTERNAL_SERVER_ERROR', cause })`; OTel span recorded with `error: true` + severity attribute.
- **Never log secrets / tokens / session IDs.** Gitleaks + Semgrep scans at pre-commit + nightly catch regressions.
- **Agent error-handling rule:** never swallow errors in generated code (`try { ... } catch { /* ignore */ }` is a Semgrep fail).

**Loading states:**

- **Client-initiated loads:** TanStack Query `isPending` drives `<LoadingSkeleton />` from `packages/ui/feedback/`. One skeleton primitive per screen kind.
- **SSR / route-loader-driven loads:** TanStack Router `defer` + `<Suspense>` + `<Await>`. Skeleton lives in the same place.
- **Never show spinners for <200ms operations.** `<Delayed>` primitive in `packages/ui/feedback/` wraps the skeleton.

**Retry + idempotency:**

- **pg-boss jobs:** default 3 retries with exponential backoff (250ms × 2^n); idempotency via `(provider, event_id)` unique constraint (A4).
- **Webhooks:** idempotent via the `webhook_events` table; replay is a no-op.
- **tRPC mutations:** non-idempotent by default unless flagged; client-side retry never happens automatically (TanStack Query `retry: false` on mutations).

**Validation:**

- **Input:** Zod at every tRPC boundary; no manual validation downstream.
- **Output:** Zod on webhook ingress; typed return types elsewhere.
- **Shape-aware validation:** `keel.config.ts` schema is Zod; invalid values fail typecheck; FR67 generator requires valid config as precondition.

### Commit / PR / Knowledge-file Patterns

**Conventional commits (enforced by commitlint via prek):**

- Types: `feat | fix | docs | chore | refactor | test | build | ci | perf`.
- Scopes: package names (`feat(billing): …`, `fix(devbox): …`) or `prd` / `arch` for planning artefacts.
- Subject: lowercase, imperative, no period (`add paddle webhook signature validation`).
- Body (optional): explains *why*, not *what*.
- `BREAKING CHANGE:` footer triggers release-please major bump.

**PR titles:** match the primary commit's subject (release-please uses it).

**Knowledge-file voice (AGENTS / CLAUDE / RALPH):**

- **`AGENTS.md`:** authoritative, normative, imperative. "Use X; don't Y." Applies to every AI agent.
- **`CLAUDE.md`:** Claude-Code specifics only; pointer to AGENTS.md for everything else. No re-statement.
- **`RALPH.md`:** private journal, first-person-plural Ralph voice. Signposts, lessons, gotchas. Stale entries pruned on upkeep.

### Design-token ID Pattern

- **Format:** `<category>.<semantic-name>.<modifier?>` (`color.status.success`, `color.status.success.bg`, `space.density.compact`, `motion.duration.fast`).
- **Stable IDs across runtime.** Same ID produces the matching Tailwind class (`text-status-success`) AND Textual style (`$status-success`).
- **No ad-hoc tokens in `apps/web`.** ESLint rule forbids inline `color: '#…'` except in `packages/keel-invariants/design-tokens.ts`.

### Enforcement Guidelines

**Pre-commit (≤10s):** prek + commitlint + ESLint + TypeScript changed-files + prompt-injection regex (S4) + bare-string + ARIA lint + token-drift check.

**Pre-merge-fast (≤3min):** full typecheck across all packages + generator idempotence (G6) + `Required tests:` manifest integrity (R2) + RLS unit tests on pglite (D3) + import-boundary audit + i18n key coverage.

**Pre-merge-slow (≤10min):** RLS integration on testcontainers Postgres (D3) + shape × tenancy matrix smoke + webhook contract tests.

**All AI agents MUST:**

- Name artefacts per the rules above — tables `snake_case` singular, TS `camelCase`, files `kebab-case.ts` or `PascalCase.tsx`.
- Colocate `.test.ts` next to source; never create top-level `__tests__/`.
- Import across packages via `@keel/<pkg>` alias, never relative paths crossing `src/`.
- Export only via `src/index.ts`; internal paths via `@keel/<pkg>/internal/*` are ESLint-forbidden.
- Surface errors to the UI via i18n keys; never swallow via `catch {}`.
- Use UUIDv7 + Zod-branded typed IDs for all new-row PKs and cross-tenant guards.
- Register pg-boss jobs via `packages/jobs/registry.ts`; never invent ad-hoc job names.
- Emit OTel spans with `<package>.<operation>` names and `keel.<namespace>.<attr>` attributes.
- Commit in conventional format scoped to a package.

**Pattern violation handling:** violations fail CI. No manual suppression. Forks that disagree with a pattern fork `packages/keel-invariants/` (source-layer change, not config toggle).

### Pattern Examples

**Good — tRPC mutation with tenant guard + i18n error:**

```ts
export const cancelSubscription = protectedProcedure
  .input(CancelSubscriptionSchema)
  .mutation(async ({ input, ctx }) => {
    const sub = await ctx.db.subscription.findFirst({ where: { id: input.subscriptionId }});
    if (!sub) throw new TRPCError({ code: 'NOT_FOUND', message: 'error.billing.subscription_not_found' });
    return ctx.billing.cancel(sub.id);
  });
```

**Anti-pattern — bare string + swallowed error + response wrapper:**

```ts
export const cancelSubscription = protectedProcedure
  .input(CancelSubscriptionSchema)
  .mutation(async ({ input, ctx }) => {
    try {
      const result: any = await fetch(`/api/cancel/${input.subscriptionId}`);  // raw fetch, any-typed
      return { data: result, error: null, message: "Subscription cancelled" };  // wrapper + bare string
    } catch {  // swallowed
      return { data: null, error: "Failed" };  // detail lost
    }
  });
```

**Good — design token usage:**

```tsx
<Button className="bg-accent-500 text-on-accent hover:bg-accent-600">Sign up</Button>
```

**Anti-pattern — ad-hoc colors:**

```tsx
<Button className="bg-blue-500 hover:bg-blue-700" style={{ color: '#fff' }}>Sign up</Button>
```

## Project Structure & Boundaries

### Requirements → Structure Mapping

| PRD surface | Lives in |
| --- | --- |
| FR1–FR6, FR1a (Execution Environment) | `packages/devbox/` |
| FR7–FR14l (Autonomous Agent Loop) | `.ralph/`, `packages/keel-invariants/schemas/`, `packages/keel-templates/` |
| FR15–FR18 (Tenant Isolation / RLS) | `packages/db/`, `packages/core/auth/`, `packages/keel-generator/` |
| FR19 (Observability) | `packages/core/otel.ts`, `packages/contracts/middleware/opentelemetry.ts` |
| FR20 (Audit) | `packages/audit/` |
| FR21 (Feature flags) | `packages/flags/` |
| FR22 (Email transport) | `packages/email/` |
| FR23 (Jobs) | `packages/jobs/` |
| FR24–FR27, FR64 (i18n) | `apps/web/app/i18n/`, `packages/keel-invariants/i18n-keys.ts` |
| FR28–FR34 (Quality & Governance / CI) | `.github/workflows/`, `packages/keel-invariants/ci-matrix.ts` |
| FR35–FR41 (Security Verification & Evidence) | `packages/keel-invariants/schemas/security-evidence.schema.json`, `.ralph/logs/<iter-id>/`, pre-commit hooks |
| FR41–FR45 (Invariants) | `packages/keel-invariants/`, `INVARIANTS.md`, `docs/invariants/` |
| FR46–FR53 (Forkability) | `create-keel-app/`, `docs/upgrades/`, release-please config |
| FR54–FR64 (Baseline product capabilities) | `apps/web/` + `packages/ui/page-templates/` |
| FR65–FR68 (Configuration & Generator) | `keel.config.ts`, `packages/keel-generator/`, `packages/config/` |
| Dual-posture research output (PRD § Business Success; Project Posture amendment) | `docs/research/`, `packages/keel-invariants/src/schemas/{sprint-log,checkpoint,tripwire,flake-log}.schema.json`, `packages/keel-invariants/src/{research-aggregate,flake-reporter}.ts`, `ralph.py --no-tui` |

### Complete Project Directory Structure

```
ralph-bmad/                                # Keel repo (this fork absorbs ralph-bmad as harness)
├── README.md                              # Keel elevator + "what this is / isn't"
├── AGENTS.md                              # Authoritative AI-agent operational guide
├── CLAUDE.md                              # Claude-Code specifics + pointer to AGENTS.md
├── RALPH.md                               # Ralph private journal
├── INVARIANTS.md                          # Agent-readable invariants narrative (FR42)
├── LICENSE                                # MIT
├── package.json                           # pnpm + turbo scripts + version (release-please-owned)
├── pnpm-workspace.yaml                    # Workspaces: apps/*, packages/*, create-keel-app
├── pnpm-lock.yaml
├── turbo.json                             # Pipeline tasks (build/test/lint/typecheck/bench)
├── tsconfig.json                          # Extends keel-invariants/tsconfig.base.json
├── keel.config.ts                         # Per-fork typed config (shape, tenancy, projectIdentity, otelExporter)
├── .envrc.example                         # I6 direnv reference (Postgres/Paddle/Resend/OAuth/ANTHROPIC_API_KEY)
├── .secrets.example                       # I6 act local GH Actions runner secrets reference
├── .nvmrc                                 # Node 20 LTS
├── .node-version                          # volta/fnm parity
├── .gitignore
├── .gitattributes
├── .editorconfig
├── commitlint.config.js                   # Conventional-commits + scope enforcement
├── release-please-config.json             # Monorepo release orchestration
├── .github/
│   ├── release-please-manifest.json
│   ├── renovate.json                      # I7 grouped-update rules + integration-test gates
│   ├── CODEOWNERS
│   ├── dependabot.yml
│   ├── ISSUE_TEMPLATE/{bug.md,proposal.md}
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       ├── pre-merge-fast.yml             # FR28–FR34 (≤3min, zero external secrets per I6)
│       ├── pre-merge-slow.yml             # (≤10min, ephemeral-pg DSN only)
│       ├── nightly.yml                    # (≤60min, Paddle sandbox + Google OAuth + Resend test; RC3 research:aggregate runs here)
│       ├── release-gated.yml              # (manual, prod adjacents)
│       ├── release-please.yml             # release-please PR/tag automation
│       └── path-profile.yml               # FR53 path-based gate-profile router
├── .prek/
│   └── hooks.yaml                         # typecheck / lint / commitlint / gitleaks / prompt-injection regex / token drift / stable-test-id
├── .ralph/
│   ├── PROMPT_build.md                    # Build-mode agent prompt (seeded from keel-templates)
│   ├── PROMPT_plan.md                     # Plan-mode agent prompt
│   ├── @plan.md                           # Agent-owned plan (story list + Required tests: blocks per R2)
│   ├── flake-log/                         # R6 per-test outcome JSONL — YYYY-MM/<date>.jsonl
│   ├── tools.json                         # Canonical tool profiles (claude, codex, gemini)
│   ├── halt                               # (transient) Halt signal JSON per R1
│   ├── lib/
│   │   └── pr-state.ts                    # R3 PR-lifecycle state machine (tsx-invoked)
│   └── logs/                              # gitignored iteration logs + security-evidence.json
├── ralph.py                               # Inherited Textual TUI harness (fork-disposition)
├── docs/
│   ├── ralph.md                           # Ralph TUI runtime reference
│   ├── invariants/
│   │   ├── ralph-execute.md               # FR14f–k narrative
│   │   ├── knowledge-files.md             # AGENTS / CLAUDE / RALPH upkeep narrative
│   │   ├── secrets.md                     # I6 env var & secrets narrative
│   │   ├── ci-budgets.md                  # A6/NFR28b modeled-vs-empirical budget provenance
│   │   ├── jobs.md                        # C1 pg-boss retry / idempotency / DLQ posture
│   │   └── README.md                      # Index
│   ├── absorption-tripwire/
│   │   └── vertical-slice-acceptance.md   # Pre-registered falsification criteria (PRD-pinned)
│   ├── research/                          # RC1 — dual-posture research corpus home
│   │   ├── README.md                      # Index, schema pointers, aggregation guidance
│   │   ├── sprint-logs/                   # Monthly blank-starter-sprint entries (RC2 schema)
│   │   │   └── YYYY-MM.{md,json}          # Per-month — md for humans, json for aggregation
│   │   ├── checkpoints/                   # Quarterly M4 checkpoint entries (absorbs docs/checkpoints/)
│   │   │   └── YYYY-Q#.{md,json}
│   │   ├── tripwire/                      # Monthly tripwire verdicts (RC2 tripwire schema)
│   │   │   └── YYYY-MM.{md,json}
│   │   ├── test-ids.md                    # C4 append-only test-ID ledger (T-0001..T-NNNN)
│   │   └── corpus.jsonl                   # RC3 aggregated output (regenerated nightly)
│   ├── design/
│   │   ├── catalog.md                     # Component catalog (stable IDs, copy-paste examples)
│   │   └── tokens.md                      # Design-token manifest explainer
│   ├── upgrades/                          # Post-1.0 one-axis migration guides (FR49)
│   │   └── README.md
│   └── architecture/                      # (may shard from architecture.md later)
├── apps/
│   └── web/                               # TanStack Start (sole 1.0 app)
│       ├── package.json
│       ├── tsconfig.json
│       ├── vite.config.ts
│       ├── tailwind.config.ts             # (re)built from keel-invariants/design-tokens.ts
│       ├── postcss.config.ts
│       ├── app/
│       │   ├── entry.client.tsx
│       │   ├── entry.server.tsx
│       │   ├── root.tsx
│       │   ├── routes/
│       │   │   ├── __root.tsx
│       │   │   ├── index.tsx
│       │   │   ├── signup.tsx             # FR54
│       │   │   ├── login.tsx              # FR54
│       │   │   ├── verify.tsx             # FR54
│       │   │   ├── reset-password.tsx     # FR54
│       │   │   ├── billing.index.tsx      # FR60
│       │   │   ├── billing.cancel.tsx     # FR60
│       │   │   ├── billing.portal.tsx     # FR60
│       │   │   ├── team.index.tsx         # FR56 (b2b only)
│       │   │   ├── team.invite.tsx        # FR56 (b2b only)
│       │   │   ├── profile.index.tsx      # (b2c default)
│       │   │   ├── webhooks.paddle.ts     # A4 — the only non-tRPC HTTP surface
│       │   │   ├── auth.callback.google.tsx
│       │   │   └── api.trpc.$.ts          # tRPC mount
│       │   ├── i18n/
│       │   │   ├── en.ts                  # English baseline locale
│       │   │   └── messages.generated.ts  # typed keys codegen output
│       │   ├── lib/
│       │   │   ├── trpc-client.ts         # A1 httpBatchLink
│       │   │   └── auth-client.ts         # better-auth client wiring
│       │   └── components/                # Page composition (pulls from packages/ui)
│       └── e2e/                           # Playwright E2E (nightly only)
│           ├── signup.e2e.test.ts
│           └── billing.e2e.test.ts
├── create-keel-app/                       # pnpm dlx bootstrap package
│   ├── package.json                       # published as create-keel-app
│   ├── src/
│   │   ├── cli.ts                         # clone + strip planning artefacts + first install
│   │   └── strip-planning.ts
│   └── README.md
└── packages/
    ├── keel-invariants/                   # FR42–FR44 (hardwired invariants)
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts                   # Public surface
    │   │   ├── eslint-config.cjs          # no-restricted-imports + a11y + no-bare-strings
    │   │   ├── tsconfig.base.json         # strict TS + project-ref contract
    │   │   ├── prettier.config.cjs
    │   │   ├── commitlint.config.cjs
    │   │   ├── prek-hooks.yaml            # reference hook graph
    │   │   ├── design-tokens.ts           # F2 single source (color/space/type/motion/density)
    │   │   ├── emit-tailwind-theme.ts     # Build-step emitter (apps/web consumer)
    │   │   ├── emit-textual-theme.ts      # Build-step emitter (ralph.py consumer)
    │   │   ├── dates.ts                   # utcNow / addMinutes / isExpired helpers
    │   │   ├── schemas/
    │   │   │   ├── halt.schema.json                 # R1
    │   │   │   ├── plan.schema.json                 # R2 Required tests: manifest
    │   │   │   ├── security-evidence.schema.json    # S3
    │   │   │   ├── rule.schema.json                 # G4 canonical generator output
    │   │   │   ├── sprint-log.schema.json           # RC2 monthly tripwire datapoint
    │   │   │   ├── checkpoint.schema.json           # RC2 quarterly M4 decision
    │   │   │   ├── tripwire.schema.json             # RC2 aggregated verdict
    │   │   │   └── flake-log.schema.json            # R6 per-test outcome entry
    │   │   ├── eslint-rules/
    │   │   │   └── stable-test-id.cjs               # C4 enforces T-\d{4} test IDs
    │   │   ├── flake-reporter.ts                    # R6 Vitest custom reporter → .ralph/flake-log/
    │   │   ├── research-aggregate.ts                # RC3 pnpm research:aggregate CLI
    │   │   ├── semgrep-rules/                       # I6 + S4 + agent-error-handling
    │   │   │   ├── no-env-log.yml                   # I6
    │   │   │   ├── no-dynamic-secret.yml            # I6
    │   │   │   ├── no-swallowed-catch.yml           # Process-pattern enforcement
    │   │   │   ├── no-persist-tenant-id.yml         # F4 persistence rule
    │   │   │   └── no-raw-fetch.yml                 # tRPC-only enforcement
    │   │   ├── prompt-injection-rules/              # S4 (a)(b)(c)
    │   │   │   ├── zero-width.ts
    │   │   │   ├── jailbreak-triggers.ts
    │   │   │   └── diff-patterns.ts
    │   │   ├── invariants.manifest.ts               # FR43 generated manifest (ID+hash)
    │   │   ├── i18n-keys.ts                         # Typed key enumeration
    │   │   └── ci-matrix.ts                         # FR28–FR34 gate-profile definitions
    │   ├── test/                                    # Schema + rule-regression tests
    │   └── README.md
    ├── keel-generator/                    # FR65–FR68 + G1–G6
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── expand.ts                  # G1 pure expand(policy, config) → Rule[]
    │   │   ├── canonicalize.ts            # G4 canonical-form + hash
    │   │   ├── merge.ts                   # G3 merge precedence
    │   │   ├── ordering.ts                # G2 sort lattice
    │   │   ├── emit-rls.ts                # Postgres RLS SQL emitter (by tenancy template)
    │   │   ├── emit-paddle-preset.ts      # Shape-specific billing preset emitter
    │   │   ├── templates/
    │   │   │   ├── rls-team.ts            # b2b tenancy
    │   │   │   ├── rls-user.ts            # b2c tenancy
    │   │   │   ├── paddle-team-seats.ts
    │   │   │   └── paddle-individual.ts
    │   │   ├── expand.test.ts             # G6 idempotence tests
    │   │   ├── canonicalize.test.ts
    │   │   └── merge.test.ts
    │   └── README.md
    ├── keel-templates/                    # FR14k seed prompt templates
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── PROMPT_build.template.md
    │   │   └── PROMPT_plan.template.md
    │   └── README.md
    ├── devbox/                            # FR1a, FR1–FR6, NFR5–NFR11, S5, I5, I6
    │   ├── package.json
    │   ├── Dockerfile                     # Ubuntu 24.04 LTS; tool bake at image build
    │   ├── docker-compose.yml             # .envrc-parameterised; env_file: ../../.envrc
    │   ├── .envrc.example                 # I5 reference defaults (devbox knobs)
    │   ├── pg-init.sql                    # I7 CREATE EXTENSION pg_uuidv7 + other init
    │   ├── entrypoint.sh                  # Workspace chown + named-volume + services bring-up
    │   ├── whitelist.default.txt          # Repo-tracked DNS whitelist (FR1a)
    │   ├── whitelist/                     # Per-category whitelist fragments
    │   │   ├── npm.txt
    │   │   ├── anthropic.txt
    │   │   └── github.txt
    │   ├── nftables/
    │   │   └── egress.nft                 # S5 layer-3 default-deny template
    │   ├── dnsmasq/
    │   │   └── dnsmasq.conf               # S5 DNS authority + JSONL query log
    │   └── scripts/                       # Lifecycle (pnpm devbox:* forwards to these)
    │       ├── build.sh
    │       ├── start.sh
    │       ├── stop.sh
    │       ├── restart.sh
    │       ├── shell.sh
    │       ├── attach.sh
    │       ├── status.sh
    │       ├── logs.sh
    │       ├── clean.sh
    │       ├── rebuild.sh
    │       ├── whitelist.sh               # add/remove/list/sync (single tool, FR1a)
    │       ├── monitor.sh                 # JSONL tail (FR1a replacement for monitor-blocks.sh)
    │       └── env-check.sh               # I6 pnpm devbox:env:check validator (names only)
    ├── db/                                # FR15–FR18, D1–D3 RLS
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts                   # Prisma client + tenantGuard extension export
    │   │   ├── client.ts                  # Prisma Client + D1 $extends extension
    │   │   ├── tenant-guard.ts            # D1 SET LOCAL tx wrapper
    │   │   ├── rls-helpers.ts             # rls:explain CLI backing lib
    │   │   ├── test-utils/
    │   │   │   ├── pglite-setup.ts        # D3 pre-merge-fast unit harness
    │   │   │   └── testcontainers-pg.ts   # D3 pre-merge-slow integration harness
    │   │   └── bench/
    │   │       ├── rls-overhead.bench.ts  # D4 §RLS-Performance-Budget
    │   │       └── seed.ts                # 10k rows team + user datasets
    │   ├── prisma/
    │   │   ├── schema.prisma              # Core models + generator-emitted RLS
    │   │   └── migrations/                # D2 forward-only + generator-output hashed filenames
    │   ├── scripts/
    │   │   └── rls-explain.ts             # pnpm rls:explain <query> --tenant=<id>
    │   ├── rls.unit.test.ts               # D3 pre-merge-fast
    │   ├── rls.integration.test.ts        # D3 pre-merge-slow
    │   └── README.md
    ├── contracts/                         # tRPC surface + A2 middleware stack
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── router.ts                  # Root router composition
    │   │   ├── errors.ts                  # A3 TRPCError code enum + i18n-key contracts
    │   │   ├── context.ts                 # Request context (tenant, user, db, otel)
    │   │   ├── procedures.ts              # publicProcedure + protectedProcedure builders
    │   │   └── middleware/
    │   │       ├── opentelemetry.ts       # A2 [0]
    │   │       ├── logger-context.ts      # A2 [1]
    │   │       ├── tenant-guard.ts        # A2 [2] — wraps D1
    │   │       ├── require-auth.ts        # A2 [3]
    │   │       └── require-recent-auth.ts # A2 [4], S2 step-up
    │   └── README.md
    ├── config/                            # keel.config.ts loader + runtime config parsing + I6 secrets
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── load.ts                    # keel.config.ts Zod-parsed loader
    │   │   ├── schema.ts                  # KeelConfig Zod schema
    │   │   ├── env.ts                     # I6 .envrc-derived env Zod validation
    │   │   └── secrets.ts                 # I6 getSecret() + KeelSecretName enum + provider shim
    │   └── README.md
    ├── core/                              # Cross-cutting core utilities
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── auth/                      # FR54, S1–S2
    │   │   │   ├── index.ts
    │   │   │   ├── better-auth.ts         # DB-backed sessions config
    │   │   │   ├── step-up.ts             # S2 requireRecentAuth helpers
    │   │   │   └── google-oauth.ts        # Google OAuth provider config
    │   │   ├── otel.ts                    # I4 OTel SDK init + exporter defaults
    │   │   └── logger.ts                  # I6 redacting structured logger
    │   └── README.md
    ├── billing/                           # FR60, A4
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── paddle.ts                  # Paddle SDK wrapper
    │   │   ├── presets/
    │   │   │   ├── team-seats.ts
    │   │   │   └── individual-subscription.ts
    │   │   ├── webhooks/
    │   │   │   └── paddle.ts              # A4 signature verification + idempotent handler
    │   │   └── lifecycle/
    │   │       ├── subscription.ts
    │   │       └── webhook-events.ts      # Idempotency via webhook_events table
    │   └── README.md
    ├── email/                             # FR22, S1
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── resend.ts
    │   │   └── templates/                 # react-email
    │   │       ├── verify.tsx
    │   │       ├── invite.tsx
    │   │       └── reset-password.tsx
    │   └── README.md
    ├── jobs/                              # FR23, S1 scheduled
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── registry.ts                # Typed job-name map (agents MUST register here)
    │   │   ├── worker.ts                  # pg-boss worker bootstrap
    │   │   └── scheduled/
    │   │       ├── session-cleanup.ts     # S1 daily
    │   │       └── rls-bench.ts           # D4 nightly
    │   └── README.md
    ├── flags/                             # FR21, F3
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── evaluator.ts               # Server-side evaluation
    │   │   └── loader-scope.ts            # Route-loader integration
    │   └── README.md
    ├── audit/                             # FR20
    │   ├── package.json
    │   ├── src/
    │   │   ├── index.ts
    │   │   ├── log.ts                     # Append-only audit log writer
    │   │   └── events.ts                  # Event-type enum
    │   └── README.md
    └── ui/                                # FR54–FR56 UI primitives + page templates
        ├── package.json
        ├── src/
        │   ├── index.ts
        │   ├── primitives/                # F1 shadcn/ui vendored (copy-into-repo)
        │   │   ├── button.tsx
        │   │   ├── input.tsx
        │   │   ├── label.tsx
        │   │   ├── form.tsx
        │   │   ├── dialog.tsx
        │   │   └── …                      # AA-first, Radix-based
        │   ├── feedback/
        │   │   ├── loading-skeleton.tsx
        │   │   ├── delayed.tsx            # Process-pattern delay wrapper
        │   │   └── empty-state.tsx
        │   ├── page-templates/            # Shape-aware composition (ESLint-guarded)
        │   │   ├── shared/
        │   │   │   ├── signup.tsx
        │   │   │   ├── login.tsx
        │   │   │   └── verify-email.tsx
        │   │   ├── b2b/
        │   │   │   ├── team-dashboard.tsx
        │   │   │   ├── team-invite.tsx
        │   │   │   └── billing-team-seats.tsx
        │   │   └── b2c/
        │   │       ├── profile.tsx
        │   │       └── billing-individual.tsx
        │   └── tokens.generated.ts        # Tailwind-class map (emitted by F2)
        └── README.md
```

### Architectural Boundaries

**API boundaries:**

- **External surface:** `apps/web/app/routes/webhooks.paddle.ts` (A4) + `apps/web/app/routes/auth.callback.google.tsx` (OAuth) + `apps/web/app/routes/api.trpc.$.ts` (tRPC mount). Non-tRPC HTTP is forbidden elsewhere.
- **tRPC routers:** composed in `packages/contracts/src/router.ts`; each subrouter lives in its owning package's `src/router.ts` and is mounted by name (`team`, `billing`, `auth`, `audit`).
- **Session variable boundary:** `app.current_tenant_id` set inside per-request tx by `packages/db/tenant-guard.ts` (D1); every RLS policy keys on it; no handler reads `ctx.tenantId` for queries — queries flow through the Prisma extension.

**Component boundaries (frontend):**

- Routes (`apps/web/app/routes/`) compose **page templates** (`packages/ui/page-templates/`) which use **primitives** (`packages/ui/primitives/`) which consume **design tokens** (`packages/keel-invariants/design-tokens.ts`).
- **Shape-aware split:** routes may import from `packages/ui/page-templates/shared` OR from the shape matching `keel.config.ts → shape`. Cross-shape imports are an ESLint rule violation.
- **No route imports `packages/db` directly.** Routes → `loader` → `ctx.trpc.<procedure>.query()` → tRPC handler → `packages/db`.

**Service boundaries (packages as service units):**

- `core/auth` owns session state + step-up + OAuth. Nothing else writes to `Session` / `Account` tables.
- `billing` owns Paddle webhook ingress + subscription lifecycle + preset emission. Nothing else calls Paddle APIs or writes to `Subscription`.
- `jobs` owns pg-boss worker bootstrap + registry. Handlers live inside the owning package and register via `packages/jobs/registry.ts`.
- `email` owns Resend calls + baseline templates. Other packages enqueue `email.send_*` jobs — never call Resend directly.
- `audit` is write-only from other packages; reads only from an admin tRPC procedure (N=1 dogfood at 1.0).
- `config` owns secrets access (I6 `getSecret()`) + `keel.config.ts` loading. No other package reads `process.env` for secret values.

**Data boundaries:**

- **Schema authority:** `packages/db/prisma/schema.prisma`. Models grouped into sections by owning package (via Prisma's `@@schema` when multi-schema adopted, else by comment section).
- **Migration authority:** `packages/db/prisma/migrations/`. Forward-only. Generator-emitted migrations filename-encode the content-hash (D2).
- **RLS authority:** emitted by `packages/keel-generator` into a companion migration; never hand-written in `schema.prisma`.
- **Caching:** none at 1.0 beyond TanStack Query's per-client cache. Server-side cache is Growth-tier.

### Requirements-to-Structure Mapping (Feature View)

**Feature: Tenant Isolation (FR15–FR18)**

- Schema: `packages/db/prisma/schema.prisma` (models + `@@schema`)
- RLS emission: `packages/keel-generator/src/emit-rls.ts` + `templates/rls-{team,user}.ts`
- Request-path guard: `packages/db/src/tenant-guard.ts` (D1)
- Middleware: `packages/contracts/src/middleware/tenant-guard.ts` (A2)
- Tests (unit): `packages/db/rls.unit.test.ts` (D3 pglite)
- Tests (integration): `packages/db/rls.integration.test.ts` (D3 testcontainers)
- Bench: `packages/db/src/bench/rls-overhead.bench.ts` (D4)

**Feature: Autonomous Agent Loop (FR7–FR14l)**

- Prompt templates (seed): `packages/keel-templates/src/PROMPT_*.template.md`
- Runtime prompts: `.ralph/PROMPT_build.md`, `.ralph/PROMPT_plan.md`
- Loop contracts narrative: `docs/invariants/ralph-execute.md`
- PR-state machine: `.ralph/lib/pr-state.ts` (R3)
- Halt schema: `packages/keel-invariants/src/schemas/halt.schema.json` (R1)
- Plan manifest schema: `packages/keel-invariants/src/schemas/plan.schema.json` (R2)
- Security-evidence schema: `packages/keel-invariants/src/schemas/security-evidence.schema.json` (S3)
- Knowledge-file upkeep: `AGENTS.md`, `CLAUDE.md`, `RALPH.md` + pre-commit warning hook

**Cross-cutting — Secrets & Env (I6)**

- `.envrc.example` + `.secrets.example` (root)
- `packages/devbox/docker-compose.yml` (`env_file: ../../.envrc` — direct passthrough)
- `packages/devbox/scripts/env-check.sh` (validator — prints key names only)
- `packages/config/src/env.ts` (Zod `ServerEnv` + `ClientEnv` schemas; boot-time parse)
- `packages/config/src/secrets.ts` (typed `getSecret()` over `serverEnv`; typo-catching; no provider shim)
- `packages/core/logger.ts` (redacting logger)
- `packages/keel-invariants/semgrep-rules/no-env-log.yml`, `no-dynamic-secret.yml`
- `docs/invariants/secrets.md` (narrative)
- `pnpm keel:audit-env` script (M9 audit)
- Client-runtime: `VITE_`-prefixed env vars accessed as `import.meta.env.VITE_*` in `apps/web/app/**` (Vite native, no custom wiring)

**Cross-cutting — Research Corpus (RC1–RC3, R5, R6)**

- Corpus home: `docs/research/{sprint-logs, checkpoints, tripwire}/*.{md,json}` + `docs/research/README.md`
- Typed schemas: `packages/keel-invariants/src/schemas/{sprint-log, checkpoint, tripwire, flake-log}.schema.json`
- Aggregation tooling: `packages/keel-invariants/src/research-aggregate.ts` → `docs/research/corpus.jsonl` (`pnpm research:aggregate`, runs nightly)
- Headless Ralph: `ralph.py --no-tui` emits sprint-log JSON on completion
- Flake measurement: `packages/keel-invariants/src/flake-reporter.ts` (Vitest custom reporter) → `.ralph/flake-log/YYYY-MM/<date>.jsonl`
- Test-ID ledger: `docs/research/test-ids.md` (append-only)

**Cross-cutting — Design System (F1 + F2)**

- Token source: `packages/keel-invariants/src/design-tokens.ts`
- Tailwind consumer: `packages/keel-invariants/src/emit-tailwind-theme.ts` → `apps/web/tailwind.config.ts`
- Textual consumer: `packages/keel-invariants/src/emit-textual-theme.ts` → Ralph TUI theme
- Tailwind class map: `packages/ui/src/tokens.generated.ts`
- Primitives: `packages/ui/src/primitives/*` (vendored shadcn/ui + Radix)
- Catalog doc: `docs/design/catalog.md`

### Integration Points

**Internal communication:**

- **Frontend ↔ backend:** tRPC exclusively (A1 httpBatchLink). TanStack Router `loader` uses server-side tRPC caller; client-side calls go through `@tanstack/react-query`.
- **Cross-package:** TypeScript imports via `@keel/<pkg>` alias. No HTTP between packages.
- **Jobs ← producers:** tRPC handlers call `ctx.jobs.enqueue('<typed-name>', payload)`; payload schema is Zod-validated at enqueue time.

**External integrations:**

- **Paddle** — webhook-in via `webhooks.paddle.ts`, API-out via `packages/billing/src/paddle.ts`. Signature verified per A4. Idempotency via `webhook_events` (`provider='paddle'`).
- **Resend** — fire-and-forget from `email.send_*` jobs; errors retry with backoff per pg-boss defaults.
- **Google OAuth** — callback at `apps/web/app/routes/auth.callback.google.tsx`; exchange via better-auth.
- **Anthropic / Claude Code** — Claude Code CLI inside devbox only; tokens in named volume `/home/dev/.claude/`; never host-bind-mounted.
- **GitHub** — `gh` CLI inside devbox; tokens in `/home/dev/.config/gh/`. Ralph pushes + creates PRs via `gh`.

**Data flow (canonical write path):**

```
Browser form submit
  ↳ apps/web route loader or action
    ↳ packages/contracts tRPC procedure
      ↳ middleware: otel → logger → tenantGuard → requireAuth → [requireRecentAuth]
        ↳ handler (Zod-validates input)
          ↳ packages/core/<domain> service call
            ↳ packages/db Prisma $extends (D1: SET LOCAL + RLS-bounded query)
              ↳ Postgres tenant-scoped read/write
            ↳ packages/jobs enqueue (if async follow-up)
            ↳ packages/audit.log.write (if auditable)
          ↳ return value → tRPC success payload
```

### File Organisation Patterns

**Configuration files:**

- **Root:** `package.json`, `tsconfig.json`, `turbo.json`, `pnpm-workspace.yaml`, `commitlint.config.js`, `release-please-config.json`, `keel.config.ts`, `.envrc.example`, `.secrets.example`, `.nvmrc`, `.gitignore`, `.editorconfig`, `.prek/hooks.yaml`.
- **Per-package:** `package.json`, `tsconfig.json` (extends `keel-invariants/tsconfig.base.json`).
- **Environment vars:** `.envrc` (gitignored), `.envrc.example` (committed, at root + `packages/devbox/`).
- **No app-scoped `.env.<stage>` files at 1.0.** Runtime config loads via `packages/config/env.ts` from `.envrc`-sourced environment only.

**Source organisation:** every `packages/*` follows the `src/index.ts`-is-the-only-export rule; no top-level `__tests__/`; no `lib/` vs `src/` split inside packages.

**Test organisation:**

- Unit: colocated `.test.ts` in each package's `src/`.
- Integration: colocated `.integration.test.ts` (tier-gated by suffix).
- E2E: `apps/web/e2e/*.e2e.test.ts` only.
- Bench: `packages/*/src/bench/*.bench.ts` (nightly only).

**Asset organisation:**

- UI static assets (images, fonts, icons) — `apps/web/public/` only.
- Email template assets — `packages/email/src/templates/` (react-email, no static images at 1.0).
- No per-package `assets/` folders.

### Development Workflow Integration

**Development server:** `pnpm devbox:shell` → `pnpm dev` starts Vite HMR on `apps/web` (port 24679 HMR, 3000 webapp). Postgres runs as a devbox-internal compose service; Prisma client auto-reconnects on schema change.

**Build process (Turborepo pipeline at root `turbo.json`):**

- `build` — per-package (respects TS project refs)
- `typecheck` — per-package
- `test` — per-package (tier-gated by CI caller)
- `lint` — per-package + root
- `bench` — per-package (nightly-only)

Parallelism uses pnpm's graph awareness; cached by content hash.

**Deployment:** 1.0 has no deploy-target (fork-and-use). Forks author `apps/web/Dockerfile.<target>` + CD workflow. `release-please` manages version bumps + changelogs; tag merge triggers GitHub release + optional fork-CD.

## Architecture Validation Results

_Completed 2026-04-19 after Party-Mode pressure-testing (Winston, Murat, Victor) and the Project Posture amendment (research-primary). Findings folded back into Steps 4–6 as ratified decisions (I6 simplification, I7 pinning, A2/RC1–RC3 research corpus, R5 headless Ralph, R6 flake measurement, C1–C4 hygiene items, D1 posture amendment)._

### Coherence Validation ✅

**Decision compatibility.** All 43 architecture-owned decisions (D1–D4, S1–S6, A1–A4, F1–F4, I1–I7, R1–R6, G1–G6, C1–C4, RC1–RC3) are mutually coherent. No contradictions. The three most-intertwined decision clusters — RLS stack (D1 per-request tx + D3 tiered pglite/testcontainers + D4 p95 benchmark), research instrumentation (R5 `--no-tui` + R6 flake measurement + RC1–RC3 corpus), and I6 secrets (direnv + Zod + `getSecret()` + Vite `VITE_` prefix) — each form internally-consistent physics. I6's simplification (dropping the provider shim) closes an N=1-persona-violation risk flagged by Victor without breaking Winston's "exercise the interface" concern (the interface no longer exists, so there's no unexercised abstraction).

**Pattern consistency.** Naming conventions (snake_case Postgres, camelCase TS, kebab-case files with PascalCase React components) flow consistently across every decision. Three-layer invariant pattern (machine-enforced → agent-readable → documented) applied uniformly to: source-code invariants, design tokens, Ralph loop contracts, i18n keys, security evidence, secrets, research corpus, flake data. "One right way per pattern" holds at every decision point.

**Structure alignment.** 14-package topology + `docs/research/` corpus home support every decision. Architecture-privileged location of `packages/keel-invariants/` (holding schemas, ESLint rules, design tokens, prompt templates, research-aggregate tool) makes the Invariant Pack pivot structurally cheap if the absorption tripwire fires. Research corpus is a peer-status artefact to substrate code, aligning with D1's dual-posture tie-breaker.

### Requirements Coverage Validation ✅

**All 85 FRs + 45 NFRs mapped** to architectural owners (see Requirements → Structure table). The four PRD-pinned load-bearing surfaces (§Generator-Normalization-Algorithm, §Devbox-Reference-Config, §RLS-Performance-Budget, §Egress-Policy Mechanism) resolved via G1–G6, I5, D4, and S5 respectively. Dual-posture research output is now first-class — RC1–RC3 + R5 + R6 form a cohesive research infrastructure.

### Implementation Readiness Validation ✅

**All 43 architecture-owned decisions carry** rationale, affects-list, and enforcement physics (where it lives, how it's enforced, what sync gate catches drift). Version pins (I7) close the reproducibility gap at M0. Complete project tree (no placeholder folders). Pattern completeness across all conflict categories. First-try bar achievable.

### Gap Analysis Results

**Critical gaps:** None.

**Important gaps closed via Party-Mode amendments:**

- ✅ Vitest version pinning → I7
- ✅ OpenTelemetry JS SDK version pinning → I7
- ✅ `pg_uuidv7` extension (compose-side init SQL) → I7 + `packages/devbox/pg-init.sql`
- ✅ Research corpus home → A2 (RC1–RC3)
- ✅ Headless Ralph as research instrumentation → R5
- ✅ Flake measurement layer → R6
- ✅ NFR28b empirical-baseline honesty → A6 (modelled at 1.0, empirical at M10)
- ✅ Secrets simplification (drop provider shim, keep typed `getSecret()`) → I6 simplified
- ✅ pg-boss retry / idempotency posture → C1
- ✅ Generator reorder-stability test → C2
- ✅ OTel cross-boundary tenant + trace propagation → C3
- ✅ Test-ID stability convention → C4
- ✅ Project posture amendment (research primary, substrate secondary) → D1

**Accepted deferrals** (with Party-Mode rationale):

- **Per-tenant RLS outlier baseline** — deferred. Winston + Murat argued 1.0; D1 project-posture amendment accepts the substrate-correctness miss. If a skewed-tenant pathology surfaces during a Keel-consumed product, it will be diagnosed and fixed at that point.
- **Weekly money-path synthetic in nightly** — deferred. Murat argued 1.0; D1 posture accepts. Paddle/Google/Resend drift risk at release-gated-only cadence is acknowledged.
- **Paddle webhook consumer-driven contract (Pact) tests** — deferred to Growth-tier.
- **Mutation-testing runtime budget calculation** — Murat's M9 item. Acknowledged; implementation staged at M9.
- **Chaos/fault-injection** — Growth-tier.
- **release-please-monorepo per-package release mode** — deferred; single-bundled release is the N=1 choice.
- **Pre-written Invariant Pack release-mode PR** (Victor) — deferred; 30-day tripwire clock is enough to configure live.
- **`keel-invariants` standalone-consumption smoke test** (Victor) — deferred; architecture is designed to support the pivot, but empirical verification waits until the pivot fires.
- **Product #2 M4 pre-commit decision** — deferred; remains on the M4 checkpoint agenda but is not architecturally pre-committed.
- **Admin dashboard / shell completion / additional deploy-target Dockerfiles** — explicit PRD Out of Scope, Growth-tier.

### Validation Issues Addressed

All important gaps flagged in the initial Step 7 draft and the Party-Mode pressure-test were either folded into the architecture as ratified amendments or explicitly accepted as deferrals with rationale under the Project Posture amendment (D1).

### Architecture Completeness Checklist

**Requirements Analysis:**
- [x] Project context thoroughly analyzed (PRD, validation report, PRFAQ, UX spec, project docs, research)
- [x] Scale and complexity assessed (Medium-High; 14 packages; 5-tier CI; 2 shapes × 2 tenancy)
- [x] Technical constraints identified (PRD-pinned stack; Docker prerequisite; N=1 persona; research-primary posture)
- [x] Cross-cutting concerns mapped (10 identified, all assigned owners, plus research corpus and flake measurement)

**Architectural Decisions:**
- [x] 43 decisions documented with enforcement physics (D1–D4, S1–S6, A1–A4, F1–F4, I1–I7, R1–R6, G1–G6, C1–C4, RC1–RC3)
- [x] Technology stack fully specified (PRD-pinned + architecture-resolved + exact version pins via I7)
- [x] Integration patterns defined (tRPC exclusively internal; webhooks + OAuth at boundary; Vite VITE_ prefix for client runtime)
- [x] Performance considerations addressed (D4 benchmark + NFR28b empirical-honesty reframe)

**Implementation Patterns:**
- [x] Naming conventions established (DB, TS, files, API, i18n, tokens, test-IDs)
- [x] Structure patterns defined (public surface, test colocation, shape-aware split)
- [x] Communication patterns specified (tRPC + pg-boss + OTel spans + research corpus schemas)
- [x] Process patterns documented (error boundaries, loading states, retry, validation, flake measurement)

**Project Structure:**
- [x] Complete directory structure defined (14 packages + `apps/web` + `docs/research/` corpus + `.ralph/flake-log/`)
- [x] Component boundaries established (ESLint rules + TS project refs)
- [x] Integration points mapped (tRPC, webhooks, external APIs, data flow, research aggregation)
- [x] Requirements to structure mapping complete (all 10 FR clusters + dual-posture research output + cross-cutting concerns)

### Architecture Readiness Assessment

**Overall Status:** **READY FOR IMPLEMENTATION.**

**Confidence Level:** **High.** The architecture passed three independent adversarial pressure-tests (Winston, Murat, Victor) and every identified gap was either closed via amendment or explicitly accepted as a deferral under the Project Posture amendment (D1). The research-primary posture makes the deferral list coherent — substrate-correctness concerns that don't serve research-output are acceptable misses at 1.0, consistent with the user's stated operating mode ("if this iteration doesn't work out, I'll tweak it and try again").

**Key strengths:**

1. **Research output is first-class.** RC1–RC3 + R5 + R6 form a complete research corpus infrastructure — typed schemas, aggregation tooling, headless measurement, flake data. The dual-posture tie-breaker has teeth.
2. **Source-layer invariants discipline preserved.** PRD thesis flows through every decision; architecture physics enforce what the PRD declares.
3. **Simplification wins.** I6 dropped the provider shim; pattern consistency held; no abstraction for hypothesised users. Victor's N=1 persona rule honoured.
4. **Version pinning at M0** (I7) closes the reproducibility gap Winston + Murat converged on without over-investing.
5. **Honesty about limits.** A6 reframe of NFR28b as modelled-at-1.0 + empirical-at-M10 avoids aspirational claims.
6. **Party-Mode-driven hygiene.** C1–C4 (pg-boss, generator reorder, OTel cross-boundary, test-IDs) are written down so the first bug surface doesn't re-litigate architectural intent.

**Areas for future enhancement (post-1.0 / when data warrants):**

- **Per-tenant RLS outlier** instrumentation on first consumer-driven pain signal
- **Weekly money-path** synthetic in nightly on first release-gate drift incident
- **Flake enforcement** policy once the measurement layer has meaningful data (≥500 iterations)
- **Release-please monorepo** reconfiguration if the Invariant Pack pivot fires
- **Consumer-driven contract tests** (Pact) for Paddle/Google/Resend
- **Chaos / fault-injection** in nightly
- **Admin dashboard, shell completion, additional deploy-targets** — Growth-tier per PRD

### Implementation Handoff

**AI Agent Guidelines:**

- Follow architectural decisions exactly as documented — branching is design-system failure.
- Use implementation patterns consistently across all packages; colocate tests, export only via `src/index.ts`, import cross-package via `@keel/<pkg>` alias.
- Respect package boundaries and the shape-aware split — cross-shape template imports are ESLint-forbidden.
- **Honour the Project Posture amendment (D1).** Research output serves research; substrate over-engineering is waste. When a decision seems substrate-correct but research-neutral-or-negative, flag it for review.
- Refer to `docs/invariants/` for narrative explanations (including `secrets.md`, `ci-budgets.md`, `jobs.md`); consult this architecture doc for decisions.
- Treat PRD-pinned stack (TanStack Start, Prisma, better-auth, Paddle, pg-boss, Resend, OTel) + version pins (I7) as invariants; do not relitigate.
- **Emit research output by default.** Every iteration's commit includes knowledge-file upkeep (AGENTS / CLAUDE / RALPH per R4); every Ralph run emits structured JSON to `.ralph/logs/`; monthly tripwire runs emit to `docs/research/sprint-logs/`; the corpus is the product as much as the substrate is.

**First Implementation Priority (M0 scaffolding story):**

```bash
# 1. Root monorepo scaffold (manual)
pnpm init
# Author: pnpm-workspace.yaml, turbo.json, tsconfig.base.json (→ keel-invariants),
#         commitlint.config.js, release-please-config.json,
#         .github/release-please-manifest.json, .github/renovate.json (I7),
#         .envrc.example, .secrets.example, .prek/hooks.yaml, .nvmrc

# 2. apps/web — minimal TanStack Start (zero add-ons per Step 3)
pnpm create @tanstack/start@latest apps/web
# Pin Vitest exact version (I7) in apps/web + packages/config package.json
# Pin @opentelemetry/sdk-node + @opentelemetry/api + instrumentations exact versions (I7)
# Configure pnpm.overrides at root to prevent transitive drift

# 3. packages/devbox — absorb from upstream cc-devbox (M0.5)
git clone https://github.com/tthew/cc-devbox packages/devbox
# Apply M0.5 deliverables (a–e) from PRD § Devbox Implementation Contract
# Apply S5 (dnsmasq + nftables), I5 (.envrc.example), I6 (compose env_file: ../../.envrc)
# Add packages/devbox/pg-init.sql with CREATE EXTENSION pg_uuidv7 (I7)
# Pin Postgres image tag to ghcr.io/fboulnois/pg_uuidv7:<version> (I7)

# 4. Ralph harness — inherit ralph.py from the ralph-bmad repo (fork disposition)
# Add --no-tui flag plumbing (R5) with sprint-log JSON output to docs/research/sprint-logs/

# 5. packages/keel-invariants — scaffold first (everything depends on it)
mkdir -p packages/keel-invariants/src/{schemas,semgrep-rules,eslint-rules,prompt-injection-rules}
# Seed design-tokens.ts, tsconfig.base.json, eslint-config.cjs
# Seed schemas/: halt, plan, security-evidence, rule (existing) + sprint-log, checkpoint,
#                 tripwire, flake-log (RC2, R6 — new)
# Seed eslint-rules/stable-test-id.cjs (C4)
# Stub flake-reporter.ts (R6) + research-aggregate.ts (RC3)

# 6. docs/research/ scaffolding (RC1)
mkdir -p docs/research/{sprint-logs,checkpoints,tripwire}
# Author docs/research/README.md with corpus guidance
# Author docs/research/test-ids.md (C4 append-only ledger)
# Author docs/invariants/{secrets.md, ci-budgets.md, jobs.md}

# 7. Remaining 13 packages — scaffold empty shells with src/index.ts + package.json + README.md
# packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui,
#           keel-generator, keel-templates} + create-keel-app

# 8. packages/config scaffolding:
#    - src/env.ts: ServerEnv + ClientEnv Zod schemas, boot-time parse
#    - src/secrets.ts: typed getSecret<K>(name: K) over serverEnv
```

After M0 scaffolding, implementation proceeds along the PRD milestone sequence (M0.5 → M0.7 → M1 → … → M9 → M10) with the cross-component dependency graph from §Decision Impact Analysis driving story ordering.

**Architecture locks here.** Implementation proceeds in the normal BMad flow: `bmad-create-epics-and-stories` → `bmad-create-story` → `bmad-dev-story` → Ralph loop.
