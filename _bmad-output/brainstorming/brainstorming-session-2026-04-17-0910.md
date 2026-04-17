---
stepsCompleted: [1, 2, 3, 4]
inputDocuments: []
session_topic: 'SaaS boilerplate project — a solid, non-overengineered architectural foundation for rapid iteration on SaaS ideas'
session_goals: 'Progressive flow: wide feature net → architectural angles & tradeoffs → differentiation vs. existing boilerplates → failure modes / what would kill this → target user & use-case ideation'
selected_approach: 'progressive-flow'
techniques_used: ['SCAMPER Method', 'What If Scenarios', 'Morphological Analysis', 'Assumption Reversal', 'Alien Anthropologist', 'Reversal Inversion', 'Reverse Brainstorming', 'Chaos Engineering', 'Role Playing', 'Permission Giving']
ideas_generated: 104
context_file: ''
session_active: false
workflow_completed: true
---

# Brainstorming Session Results

**Facilitator:** Tthew
**Date:** 2026-04-17

## Session Overview

**Topic:** SaaS boilerplate project — a solid, non-overengineered architectural foundation intended as a jumping pad for rapid iteration on SaaS ideas.

**Goals (Progressive Flow — option F):**
1. Wide net of feature ideas (broad divergence)
2. Architectural angles & tradeoffs (stress-test "not overengineered")
3. Differentiation vs. existing boilerplates (SaaS Pegasus, Bullet Train, Supastarter, create-t3-app, etc.)
4. Failure modes & "what would kill this" (adversarial)
5. Target user & use-case ideation (who this is deliberately for / not for)

### Session Setup

**Baseline must-have feature scope (all confirmed in):**
- Secure auth: authentication, authorization, roles, permissions
- Register / signup / logout / email verification / password reset
- Internationalization & localization
- Feature flagging
- Payments
- Teams/orgs & multi-tenancy
- Subscription billing
- Transactional email
- Admin dashboard
- Audit logs
- Background jobs / queues
- File uploads
- Webhooks (inbound + outbound)
- API keys / programmatic access
- Observability (logs / metrics / traces)
- API-first (REST/GraphQL) from day one

**Stack anchor (recommended, open to challenge in architecture pass):**
TypeScript + Next.js (App Router) + Postgres + Prisma + tRPC.
Rationale: single-language fullstack (speed + maintainability), ecosystem coverage for every baseline feature, mature integrations (NextAuth/Clerk, Stripe, Resend, Inngest/Trigger.dev, Unleash/Flagsmith, OpenTelemetry).

**Constraint north star:** "Not overengineered" — every feature must earn its place. Boring, maintainable, forkable.

### Context Guidance

_No context file provided._

---

## Technique Selection

**Approach:** Progressive Technique Flow (5 phases matched to user's outcome goals)

- **Phase 1 — Wide Feature Net:** SCAMPER (primary) + What If Scenarios (booster)
- **Phase 2 — Architectural Angles:** Morphological Analysis (primary) + Assumption Reversal (booster)
- **Phase 3 — Differentiation:** Alien Anthropologist (primary) + Reversal Inversion (booster)
- **Phase 4 — Failure Modes:** Reverse Brainstorming (primary) + Chaos Engineering (booster)
- **Phase 5 — Target User:** Role Playing (primary) + Permission Giving (booster)

**Journey Rationale:** Broad coverage first, then structured architecture, then sharpening against the market, then adversarial stress-test, then humanizing — each phase feeds the next.

---

## Ideation Log

_(Ideas appended below by technique as the session progresses. Idea format: **[Category #X] Title** / _Concept_ / _Novelty_.)_

### Phase 1 — Wide Feature Net (SCAMPER + What If Scenarios)

#### SCAMPER Lens 1 — SUBSTITUTE

**[Feat #1] Auth-as-a-thin-adapter, not auth-as-code**
_Concept_: Ship with an auth port (interface) and three drop-in adapters: NextAuth (self-hosted), Clerk (managed), WorkOS (enterprise/SSO). Pick one via `create-` flag; no auth logic in userland code.
_Novelty_: Most boilerplates hardcode one auth choice and force a rewrite to change. Adapter-first treats auth as a commodity.

**[Feat #2] Payments = Stripe + a migration-safe pricing DSL**
_Concept_: Declarative `pricing.ts` compiles to Stripe Products/Prices on `pnpm pricing:sync`. Every price change is a PR with a reviewable diff.
_Novelty_: Pricing as code, reversible between environments — not a Stripe dashboard free-for-all.

**[Feat #3] Email = React Email + local dev inbox**
_Concept_: React Email components previewed in a bundled local inbox (Mailpit-style) that intercepts outbound mail in dev.
_Novelty_: You see every email before prod users do. Most boilerplates give you a Resend key and a prayer.

**[Feat #4] i18n via message IDs compiled at build, not runtime lookup**
_Concept_: Compile-time typed message IDs (Lingui/FormatJS). Missing translations = build error.
_Novelty_: Untranslated strings can't ship. i18n becomes a type-system problem.

**[Feat #5] Feature flags = plain TS conditions, backed by provider adapter**
_Concept_: Single `flags.ts` exposes typed flags; provider (Unleash/Flagsmith/PostHog/local file) plugs in via env.
_Novelty_: Flag deletion is a TypeScript refactor, not a grep. Dead flags caught by `tsc`.

**[Feat #6] Background jobs = function signatures, not a queue API**
_Concept_: `await jobs.sendWelcome(userId)` — typed function call, routed to Inngest/Trigger.dev/BullMQ.
_Novelty_: Jobs feel like local calls; queue is an implementation detail.

**[Feat #7] Admin dashboard = generated from schema, not hand-built**
_Concept_: Retool-style auto-generated CRUD derived from Prisma schema + per-model policy decorators.
_Novelty_: No one maintains the admin panel because there isn't one to maintain.

**[Feat #8] Audit logs = structured events, not string messages**
_Concept_: Typed event union (`AuditEvent = {type: 'user.login'} | {type: 'billing.subscribed'}`). Queryable, typed, analytics-ready.
_Novelty_: Audit log doubles as product analytics feed.

**[Feat #9] Observability = OpenTelemetry + one env var**
_Concept_: OTel baseline; `OTEL_EXPORTER_OTLP_ENDPOINT=…` points at any backend.
_Novelty_: No observability vendor lock-in — pick vendor when you have revenue.

**[Feat #10] File uploads = signed-URL direct-to-storage, never through app**
_Concept_: Client requests signed URL → uploads direct to S3/R2 → server records metadata. App never sees bytes.
_Novelty_: App can run on serverless/edge from day one without request-size limits.

#### SCAMPER Lens 2 — COMBINE

**[Feat #11] Audit log × feature flags = flag-aware audit** _(Tier 3 — cut from MVP)_
_Concept_: Every audit event records active flags for the actor at that moment.
_Novelty_: Flag archaeology for incident debugging.

**[Feat #12] API keys × RBAC = keys are users without faces** _(Tier 3 — cut from MVP; only if API-first product)_
_Concept_: API keys modeled as first-class actors with scoped role; one authz engine for both humans and keys.
_Novelty_: Eliminates the #1 API-key authz bug class.

**[Feat #13] Teams × billing = per-team subscriptions with shared quotas** _(Tier 1 — KEEP)_
_Concept_: Subscriptions attach to teams, not users. Quota enforcement rolls up to the team.
_Novelty_: Most boilerplates ship user-billing and force a painful rewrite for the first enterprise customer. Structurally expensive to retrofit.

**[Feat #14] Webhooks (outbound) × feature flags = gradual webhook rollout** _(Tier 3 — cut; outbound webhooks aren't MVP)_
_Concept_: Flag-gated outbound webhooks with % rollout and dry-run.
_Novelty_: Webhooks as a safely-deployable product surface.

**[Feat #15] Feature flags × i18n = translate flags too** _(Tier 3 — cut from MVP)_
_Concept_: Flag names/descriptions and gated strings live together in i18n.
_Novelty_: International rollout = flag + locale ship together.

**[Feat #16] Transactional email × observability = per-email traces** _(Tier 3 — cut from MVP; maybe Tier 2 hook)_
_Concept_: Every send gets a trace ID linking request + job + render.
_Novelty_: Support moves from "we'll investigate" to "here's the trace."

**[Feat #17] Tenancy × admin = impersonate any tenant, tracked as audit event** _(Tier 3 — cut; no admin UI in MVP)_
_Concept_: Admin impersonation with explicit reason + audit + customer-visible record.
_Novelty_: Transparent support access.

**[Feat #18] Password reset × magic links × passkeys = unified identity-recovery flow** _(Tier 2 — keep; skip passkeys in MVP)_
_Concept_: One endpoint, one state machine for password reset / magic link / passkey enrollment.
_Novelty_: One flow to test and harden, not three half-broken parallel ones.

**[Feat #19] Jobs × webhooks × retries = webhooks are just jobs with a URL** _(Tier 2 — keep, when outbound webhooks unstubbed)_
_Concept_: Outbound webhooks reuse the job system's retry/backoff/dead-letter semantics.
_Novelty_: One reliability primitive for both worlds.

**[Feat #20] Feature flags × billing = paywall as a flag** _(Tier 2 — keep)_
_Concept_: Entitlements are flags evaluated with the current subscription context.
_Novelty_: No separate entitlement service; plan change propagates in seconds.

---

#### Session Pivot — Minimal Viable Foundation (MVF) Thesis

User challenged the first-20 drift toward feature-maximalism. Triaged all 16 baselines into three tiers:

**Tier 1 (Ship real code Day 1 — structurally expensive to retrofit):**
- Users + Teams + Memberships data model
- Auth: signup/login/logout/password-reset/email-verify (one opinionated provider, no adapter)
- Single `can(user, action, resource)` authz primitive (no ABAC, no CASL)
- Stripe subscriptions **on teams** (not users), one plan
- Transactional email (one provider, 3 templates: welcome, reset, invite)
- DB migrations + seed script
- One deploy target (Dockerfile OR Vercel, not both)

**Tier 2 (Scaffold only — typed hooks with stub implementations):**
- Feature flags (local-file provider; adapter point exists)
- i18n (one locale, `t()` wired up)
- Audit log (typed event emitter, one table, no UI)
- Background jobs (only for welcome/reset email; consider `setTimeout + DB row` before Inngest)
- Inbound webhooks (Stripe only)
- File uploads (signed URL, one example: avatar)
- Observability (logs + OTel hook via env var)

**Tier 3 (Do NOT ship in boilerplate — cut from baseline):**
- Admin dashboard (use Prisma Studio + SQL)
- API keys (defer unless building an API product)
- Outbound webhooks
- API-first REST/GraphQL from day one (use tRPC/server-actions, expose later)
- Full observability stack / traces / dashboards

**[Feat #22] Minimal Viable Foundation thesis**
_Concept_: Boilerplate = data model + auth + billing + one email pipeline + deploy config. Everything else is a typed hook point with a stub. The README teaches you how to unstub each when you need it.
_Novelty_: Most boilerplates sell "look how much it does." This sells "look how much it doesn't force on you."

**[Feat #23] "Unstub guide" as first-class deliverable**
_Concept_: Every Tier 2 hook has `docs/unstub/<feature>.md` with: when to unstub, 3 opinionated options, files to edit, rollback plan.
_Novelty_: The boilerplate teaches the upgrade path, not just the starting state.

_From here, every new idea must defend itself: Tier 1, Tier 2, or rejected as Tier 3._

#### User Correction — State management stack

User pushed back on earlier "no state library" framing. Revised stack decision:
- **tRPC + @tanstack/react-query**: server state on client (tRPC default)
- **react-hook-form + Zod**: form state (Zod schemas shared with tRPC inputs)
- **Zustand**: global/non-trivial client state only, small stores, feature-colocated
- **useState / URL params**: local + shareable UI state

tRPC is the service layer from the client's POV; "no service layer" originally meant "no Java-style `UserService`/`UserRepository` inside tRPC procedures" — clarified in revised #45.

#### What If Scenarios — Booster Provocation

**"What if we preferred Paddle to Stripe for payments?"** (user-injected)

Exposed a weak default. Stripe was picked out of Next.js ecosystem inertia, not because it matches the stated user (solo/small-team founders doing rapid global-SaaS iteration). **Paddle is the Merchant of Record**, removing VAT/sales-tax/invoicing/dunning from userland code on every SaaS idea — a compounding benefit for the boilerplate's actual target use case.

Decision capture:
- **Default:** Paddle (MVF + rapid-iteration fit)
- **Alternative:** Stripe (ecosystem, Connect, US-high-volume) — unstub guide
- **Abstraction:** One payments port (deliberate exception to "no adapters" rule; justified because payment-provider choice is a business-model concern, not a developer-preference concern)
- **Pricing DSL:** Provider-agnostic source of truth, sync target configurable

---

#### Phase 1 Close — Summary

- **Total ideas generated:** 68
- **Rejected (Tier 3, openly cut):** 7
- **Surviving:** 61 — 40 Tier 1 (ship code Day 1) + 17 Tier 2 (typed hooks with unstub guides) + 4 session-level decisions
- **Core artifact:** The Minimal Viable Foundation (MVF) thesis + 3-tier triage
- **Stack anchor (revised):** TS · Next.js · Postgres · Prisma · tRPC · react-hook-form + Zod · Zustand · Paddle · Resend · Inngest (or pg-boss) · Tailwind · OpenTelemetry
- **Two deliberate adapter exceptions:** payments (MoR vs PSP is a business-model concern)
- **One deliberate no-adapter commitment:** auth (pick one provider, no port)

---

### Phase 2 — Architectural Angles & Tradeoffs (Morphological Analysis + Assumption Reversal)

#### Axis 1 — Multi-tenancy model
**Default (revised per user provocation):** Shared schema + `teamId` + **RLS policies enforced Day 1**. `tenantGuard(teamId, () => { ... })` opens a Prisma transaction and runs `SET LOCAL app.current_team_id = ?`; all queries inside are auto-filtered by RLS policies. ESLint rule enforces `tenantGuard()` usage as a style check (RLS is the security check). Schema-per-tenant and DB-per-tenant still rejected for MVP.

**Original default was Tier 2 unstub; flipped because provocation exposed "not overengineered" instinct being misapplied to a security invariant. Convention beats nothing; invariant beats convention. For a boilerplate whose users fork fast and take shortcuts, RLS is the only mechanism that survives.**

#### Axis 2 — Deploy target
**Default:** Node container (Fly.io default; `Dockerfile` portable to Railway/Render/VPS). Vercel rejected as day-1 default because it forces paid deps (Prisma Accelerate, Inngest/Trigger.dev) to preserve the one-datastore + pg-boss commitments; Vercel deploy shipped as Tier 2 unstub guide. Edge (Cloudflare Workers) rejected as architecturally incompatible with single-process job/DB commitments.

#### Axis 3 — Session strategy
**Default:** DB-backed sessions in Postgres. Opaque session ID in `HttpOnly, Secure, SameSite=Strict` cookie, 30-day expiry. `sessions` table with lazy `lastSeenAt` updates. No JWT-as-session.

**JWT clarification (user correction):** Session ≠ JWT, but JWT has legitimate uses as short-lived claims-bearing access tokens for APIs, service-to-service, and OIDC federation. Industry-standard 2026 model is layered: DB session for browser auth + JWT minted from session for specific use cases.

**Migration path is additive:** Layer 0 (session) → Layer 1 (`mintAccessToken` utility when public API or scoped tokens needed) → Layer 2 (service-to-service trust on signature) → Layer 3 (OIDC provider mode). Session table shape is invariant across all layers.

**[Feat #69] JWT access-token minter as a Tier 2 hook, layered on DB sessions** — _Tier 2_
_Concept_: `mintAccessToken(session, {audience, scopes, ttl})` + `verifyAccessToken(jwt)` utility. Consumers verify signature + audience + scope without hitting the auth DB. Ships as stub + unstub guide.
_Defense_: Addresses "what if we need stateless claims later?" explicitly. Makes the layered architecture visible from day 1 without shipping crypto code prematurely.

#### Axis 4 — ORM / DB access
**Default:** Prisma (anchor retained). Edge incompatibility concerns evaporated in Axis 2 (Node container). Prisma's strengths (schema-first migrations, `include` relational queries, Studio, community) match rapid-iteration goal. Drizzle/Kysely Tier 2 unstub guides for specific scenarios (edge deploy, read-heavy hot paths). Prisma Data Platform / Accelerate / Pulse explicitly NOT shipped.

#### Axis 5 — Monorepo structure (revised per user correction)

**Original default** (single Next.js app, no workspace) was too minimal. User correctly challenged: modular monolith with enforced boundaries buys microservices optionality at near-zero run-cost and is the structurally honest baseline for a boilerplate claiming rapid iteration.

**Revised default:** Modular monolith on **pnpm workspaces + Turborepo** from Day 1.

**Package split (Day 1) — finer, per user refinement:**
```
apps/
  web/                    Next.js app — thin; imports from packages
packages/
  db/                     Prisma schema + generated client
  contracts/              Shared Zod schemas (tRPC, events, forms) + types
  config/                 Env validation (Zod) + typed access
  core/                   Auth/session, authz can(), tenancy guard
  billing/                Paddle adapter, subscription state, webhook → job
  email/                  React Email templates + provider adapter
  jobs/                   pg-boss wrapper, typed job definitions
  flags/                  Feature flag adapter + typed flag defs (with expiry)
  audit/                  Typed audit event emitter + writer
  ui/                     Shared UI primitives (starts minimal; grows with reuse)
```

**1 app + 10 packages.** Dependency graph is acyclic by construction:
- Leaves (no workspace deps): `db`, `contracts`, `config`, `ui`
- Mid-tier: `audit` (→ db, contracts), `jobs` (→ db, config), `email` (→ contracts), `flags` (→ db)
- Higher: `core` (→ db, contracts, config), `billing` (→ db, contracts, jobs, audit)
- Top: `apps/web` imports everything it needs

ESLint `no-restricted-imports` encodes this graph; accidental cycles become lint errors.

**No `apps/worker` Day 1.** pg-boss runs in-process in `apps/web`. `apps/worker` is the canonical Tier 2 extraction path — enabled by `packages/platform/jobs` already being a package.

**Boundary enforcement (mechanical, not aspirational):**
1. ESLint `no-restricted-imports` encoded per-package
2. TypeScript project references (per-package `tsconfig.json`)
3. Explicit `dependencies` in each `package.json`

**ADR:** `docs/adr/001-when-does-it-become-a-package.md` — rule: "a concern earns its own package when it has its own lifecycle OR needs to be consumed by two+ apps."

**Turborepo kept minimal:** three pipelines (`build`, `test`, `typecheck`). Local cache only. Remote cache is Tier 2.

**[Feat #71] Modular monolith with enforced boundaries from Day 1** — _Tier 1_
_Concept_: pnpm workspaces + Turborepo + 6-package split + 1 app. Boundaries enforced via ESLint + TS project references.
_Defense_: Retrofitting module boundaries into a flat src at month 6 is painful; installing at Day 1 is ~2 hours of config and buys microservices optionality.
_Novelty_: Ships the ADR and enforcement tooling as part of the baseline — boundaries are mechanical, not aspirational.

**[Feat #72] `apps/worker` extraction as Tier 2 unstub** — _Tier 2_
_Concept_: Jobs live in `packages/jobs`; inline in web Day 1; extraction path documented (create `apps/worker`, import package, split deploy).
_Defense_: Concrete microservices-optionality payoff the modular structure buys. Documented extraction proves the pattern works.
_Novelty_: First Tier 2 unstub the package structure actively enables.

#### Axis 6 — Background job system
**Default:** pg-boss (Postgres-native). Honors one-datastore commitment; runs in-process with web Day 1; same library works in `apps/worker` extraction. BullMQ rejected (requires Redis); Inngest/Trigger.dev Tier 2 unstub guides. Typed job registry pattern (#73) is the architectural primitive — backing service swappable.

**[Feat #73] Typed job registry; pg-boss as Day-1 adapter** — _Tier 1_
_Concept_: `defineJob(name, payloadSchema, handler)` registers a job. `jobs.<name>(payload)` is fully typed. Renaming a job or changing payload shape is a `tsc` error.
_Defense_: Only case (besides payments) where adapter shape earns its keep Day 1 — the alternative (untyped enqueue) is a refactor landmine.
_Novelty_: Job names and payloads are part of the type system.

#### Axis 7 — Auth provider
**Default:** Auth.js v5 (self-hosted library). Honors DB-session commitment (Axis 3) — Clerk cannot without dual source of truth. Free, huge community, Prisma adapter, OAuth + credentials + magic-link. Wrapped in `packages/core/auth` with opinions: DB session strategy forced, Google OAuth + email/password only, custom UI (no Auth.js `<SignInButton>`), step-up auth middleware on top (`requireRecentAuth`).

**Alternatives rejected as Day-1 defaults (Tier 2 unstub guides):**
- Clerk — breaks DB-session architecture, vendor lock-in, MAU pricing cliff
- WorkOS — enterprise overkill for MVP
- Supabase Auth — couples stack to Supabase
- better-auth — honest near-miss; smaller community in 2026; revisit in 12 months
- Roll-your-own — reimplementing OAuth/CSRF/crypto is a risk landmine

---

### Phase 2 — Summary

**7 load-bearing architectural axes resolved:**

| # | Axis | Default | Core rationale |
|---|------|---------|----------------|
| 1 | Tenancy | Shared schema + `tenantGuard()` | RLS Tier 2 when regulated customer appears |
| 2 | Deploy | Node container (Fly/Docker) | Honors one-datastore + long-running worker commitments |
| 3 | Session | DB-backed sessions + JWT Tier 2 hook | Revocation + step-up + layered JWT minter |
| 4 | ORM | Prisma | Schema-first + `include` + community mass; edge concerns moot after Axis 2 |
| 5 | Repo | Modular monolith, pnpm workspaces + Turborepo, 10 packages | Enforced boundaries = cheap microservices optionality |
| 6 | Jobs | pg-boss | One-datastore honored; in-process Day 1, `apps/worker` Tier 2 |
| 7 | Auth | Auth.js v5 | Honors DB-session commitment; free; community mass |

**Cross-cutting patterns that emerged:**
- **Adapter exceptions are deliberate** (payments, jobs) — justified, not reflexive
- **Tier 2 unstub guides** are first-class artifacts, not afterthoughts
- **Structural decisions ship with mechanical enforcement** (ESLint rules, migrations linter, Zod env validation)
- **Every axis checks against prior commitments** — consistency was earned, not assumed

---

### Phase 3 — Differentiation vs. Existing Boilerplates

Reference landscape: create-t3-app, SaaS Pegasus, Bullet Train, Supastarter, ShipFast, Nextacular, Chadnext, various Next.js starters.

#### Alien Anthropologist (8 bewilderments at market conventions)

- **[Feat #74]** No landing page in the app repo (why does every boilerplate ship one?)
- **[Feat #75]** Paddle default, not Stripe (why pick by ecosystem inertia, not user fit?)
- **[Feat #76]** Count omissions, not features (features are maintenance debt, not virtues)
- **[Feat #77]** No cookie banner (unauthenticated surface has no cookies to ask about)
- **[Feat #78]** No admin dashboard (no one maintains it; Prisma Studio + SQL is enough)
- **[Feat #79]** Two roles, not six (your product decides RBAC, not the boilerplate)
- **[Feat #80]** Postgres only, use its features (skip the ORM multi-DB abstraction tax)
- **[Feat #81]** No analytics SDK pre-wired (product-strategy decision, not infra)

#### Reversal Inversion (5 positioning flips)

- **[Feat #82]** "Iteration-ready" not "production-ready" (different user, different commitment)
- **[Feat #83]** Ship docs, not features (unstub guides are the artifact)
- **[Feat #84]** Optimize for fork, not demo (believable seed, working local dev, preflight)
- **[Feat #85]** Enforced modularity, not decorative (ESLint + TS refs + ADR)
- **[Feat #86]** Pick one and commit, not abstract (two adapter exceptions, explicit)

#### Synthesized positioning

**[Feat #87] Positioning thesis: "For founders who fork boilerplates fast and often"** — _Tier 1_
Named target user: solo/small-team founder iterating on SaaS ideas. NOT enterprise, NOT learners, NOT hobbyists.

**[Feat #88] Three-line elevator pitch (not twenty)** — _Tier 1_
1. Paddle-first (no tax code, ever)
2. Modular monolith with enforced boundaries (microservices-optional)
3. Unstub guides as first-class (docs are features)

**[Feat #89] The 60-minute test** — _Tier 1 (design principle)_
Single success criterion: `git clone` → user signs up → verifies → joins a team → pays Paddle, within 60 minutes. Every decision scored against it.

#### Non-differentiators (happy to be boring)

Postgres, Prisma, Tailwind, Google OAuth, GitHub Actions, Vitest+Playwright, React Email, Resend, OpenTelemetry. Commodity picks; differentiation lives in *constraints applied to a boring stack*, not in stack novelty.

---

#### What If Scenarios — Booster Provocation #2

**"What if we replaced Next.js with TanStack Start / TanStack Router?"** (user-injected)

Cascading provocation. Next.js was the inherited "safe" default; our stack had already accumulated TanStack footprint implicitly (tRPC uses @tanstack/react-query; Zustand is TanStack-ecosystem adjacent). Flipping framework forces re-evaluating auth, because Auth.js v5 is tightly coupled to Next.js.

**Decision: adopt TanStack Start + better-auth as a pair.**

**Rationale:**
- Stack becomes thematically coherent (TanStack-everywhere + Postgres-everywhere)
- End-to-end type safety (routes + loaders + tRPC + forms + events) — aligns with #4 "missing translation = build error" thesis generalized to all layers
- Simpler mental model than RSC + Server Actions
- Vite dev server speed
- TanStack Start + better-auth is the *fit-for-purpose* pick — matches our architectural commitments (type-as-spec, DB-first, modular monolith) better than Next.js + Auth.js

**Correlated-risk accepted:** two smaller-community libraries instead of two massive ones. Mitigation: (1) both actively maintained with real backers; (2) unstub guide documents migration back to Next.js + Auth.js if either stalls; (3) keep router abstraction shallow enough that swap is ~2 days.

**Revised stack anchor:**
TS · **TanStack Start** (Vite) · Postgres · Prisma · tRPC · react-hook-form + Zod · Zustand · **better-auth** · Paddle · Resend · pg-boss · Tailwind · OpenTelemetry

**Revised non-differentiators list:** Next.js removed (now a *fit* pick was made; TanStack Start). Everything else unchanged.

**[Feat #90] TanStack Start + better-auth pair** — _Tier 1_
_Concept_: TanStack Start as SSR framework; better-auth as auth library; Vite as bundler. All other architectural commitments retained.
_Defense_: Coherent stack, end-to-end types, matches target-user's iteration priorities over community-mass conservatism.
_Novelty_: First SaaS boilerplate positioned on TanStack-Start-first architecture.

**[Feat #91] "Boring under constraints" positioning refined** — _Tier 1_
_Concept_: Boring where it doesn't cost (Postgres, Prisma, Tailwind, etc.); fit-for-purpose where coherence matters (TanStack Start, better-auth, Paddle). Differentiation remains in *constraints applied to the stack*.
_Defense_: Honest framing — "boring" is a per-layer principle, not a blanket rule.
_Novelty_: Treats each layer as a separate boring-vs-fit decision rather than an ideological commitment.

**[Feat #63 — REVISED] Server-side flag evaluation in route loaders (not RSC)**— _Tier 1_
_Concept_: `flags.evaluate(user)` runs in the TanStack Start route loader. Loader data flows to the component via typed loader context. Client never sees the flag provider; no flash of hidden content.
_Defense_: Same server-side-evaluation principle as RSC version; cleaner mental model (no RSC boundary confusion). Loader-data is TanStack Router's first-class primitive.
_Novelty_: Flag evaluation is load-time + typed, not request-time + SDK.

#### Axes impacted by framework/auth flip — revised summary

| # | Axis | Revised default | Change |
|---|------|-----------------|--------|
| 2 | Deploy | Node container (same) | No change |
| 3 | Session | DB-backed (same) + JWT hook via better-auth access-token plugin | Unstub simpler |
| 5 | Repo | Modular monolith, `apps/web` is TanStack Start | `apps/web` internals change; package structure unchanged |
| 7 | Auth | **better-auth** (was Auth.js v5) | Framework coupling drove the swap |

Axes 1 (tenancy), 4 (Prisma), 6 (pg-boss) unaffected.

---

### Phase 4 — Failure Modes / What Would Kill This

Reverse Brainstorming + Chaos Engineering. Each kill vector paired with a concrete hardening.

#### Ecosystem / upstream risks
- **[Kill #1]** TanStack Start / better-auth stalls → keep framework glue thin; auth schema is ours not library's; tested migration-back-to-Next.js+Auth.js unstub guide
- **[Kill #2]** Paddle pivots → payments port with *tested* Stripe adapter; provider-agnostic pricing DSL; positioning caveat in README
- **[Kill #3]** Forks become unpullable → kernel-vs-plumage separation in `docs/forking.md`; extension points not modification points; per-release merge guides; cherry-pick-able security branch

#### Architectural rot
- **[Kill #4]** Cross-tenant leak → ESLint rule requiring `tenantGuard()` closure; `testIsolation()` Vitest helper; RLS as defense-in-depth unstub
- **[Kill #5]** Audit log unbounded → table partitioned by month Day 1; retention unstub shipped Day 1; cold-storage forward unstub
- **[Kill #6]** pg-boss falls behind silently → `pnpm doctor` queue depth check; OTel metric + example alert; dead-letter threshold → audit event; Inngest migration unstub

#### MVF / discipline decay
- **[Kill #7]** Small-feature creep → 60-minute test runs in CI (scripted); PR template asks "what did this cut?"; literal feature-count ceiling
- **[Kill #8]** Unstub guides go stale → quarterly automated execution of each guide in CI; enforce by execution, not review
- **[Kill #9]** Flag expiry ignored → `justification: string` field required on flag renewal; max-one-renewal policy
- **[Kill #10]** Target user forgotten → ADR template requires "which target user?"; anti-persona list prominent in README; CI checks readme target-user section intact

#### Dev / operational failures
- **[Kill #11]** Dangerous migration merged → linter tuned high-precision; waiver requires second reviewer with expand-contract plan; staging dry-run in CI
- **[Kill #12]** Google OAuth misconfigured → `pnpm doctor` does real OAuth discovery check; `bin/setup` prompts + validates; first-boot wizard shows expected redirect URI

#### Chaos scenarios (stress-test existing hardening)
- **[Chaos #1]** Postgres 10-min outage → no additional work; single-Postgres is conscious SPOF; HA is Tier 2 unstub
- **[Chaos #2]** Paddle webhook flood → handled by #58 (idempotent job keyed on event.id); add vitest replay test
- **[Chaos #3]** Node container dies mid-request → no additional work; Fly auto-restart + stateful DB cover it

#### New defensive ideas emerging

**[Feat #92] `testIsolation(procedure)` Vitest helper** — _Tier 1_
_Concept_: Utility that seeds two tenants, runs a tRPC procedure as tenant A, asserts zero tenant-B rows in result. Failure is a bright red test.
_Defense_: Tenant-isolation is the highest-cost bug class. Cheap test helper makes the assertion routine, not heroic.
_Novelty_: Tenant-leak defense as a standard test pattern, not a special audit.

**[Feat #93] Audit log table partitioned by month from Day 1** — _Tier 1_
_Concept_: `audit_events` is a Postgres partitioned table, `PARTITION BY RANGE (created_at)`. Retention job drops old partitions; cold storage forward is Tier 2.
_Defense_: Unbounded-growth rot is certain without a plan. Partitioning is free on Day 1 and painful to retrofit.
_Novelty_: Ships the retention architecture before the retention problem.

**[Feat #94] 60-minute test runs in CI**  — _Tier 1_
_Concept_: Headless script clones repo, runs `bin/setup`, boots, signs up a user, verifies email (against local Mailpit), joins a team, starts a Paddle sandbox subscription. Times the whole thing. If >60 min wall-clock, CI fails.
_Defense_: Feature creep is certain without a measurable ceiling. Makes the positioning enforceable.
_Novelty_: First SaaS boilerplate with a scripted, CI-enforced onboarding-time ceiling.

**[Feat #95] Unstub guides executed quarterly in CI** — _Tier 1_
_Concept_: Scheduled CI job picks a Tier 2 unstub (rotating), executes its documented steps in a throwaway env, asserts a working system results. Stale guide = red build.
_Defense_: Kill #8 mitigation. Docs-as-code that tests itself.
_Novelty_: Treats documentation as executable, not reference.

**[Feat #96] Kernel-vs-plumage `docs/forking.md`** — _Tier 1_
_Concept_: Explicit list of "don't modify these" (kernel: auth schema, migration patterns, tenant-guard, session model) vs "customize freely" (plumage: UI, copy, email templates, pricing config). Upgrade guide honors the distinction.
_Defense_: Kill #3 mitigation — gives forkers a stable surface to pull from.
_Novelty_: Most boilerplates have no such convention; forks rot by month 6.

**[Feat #97] PR template enforces MVF discipline** — _Tier 1_
_Concept_: PR template requires: "Which Tier does this pay for?", "What did this cut?", "Which target user benefits?" Non-answers block merge.
_Defense_: Kill #7 + #10. Forcing function for reviewers, not just authors.
_Novelty_: Treats discipline as tooling, not culture.

**[Feat #98] Waiver pattern for dangerous migrations requires second reviewer** — _Tier 1_
_Concept_: Unsafe migration requires `// migration:unsafe-ok reason: <expand-contract plan>` comment. Linter blocks merge unless a reviewer other than the author explicitly approves the waiver.
_Defense_: Kill #11. Prevents linter waiver from being a rubber stamp.
_Novelty_: GitHub's CODEOWNERS pattern applied to migration safety.

---

### Phase 4 — Summary

**12 kill vectors + 3 chaos scenarios identified.**

All hardenings are Tier 1 (structural) because failure modes are structural. New patterns introduced:
- Enforcement via execution (CI runs the guide; CI runs the 60-min test; CI runs isolation test)
- Enforcement via schema (audit partitioning, flag expiry, tenant guard)
- Enforcement via process (PR template, waiver pattern, second-reviewer rules)

**No single point of failure uncovered.** The stack survives realistic chaos scenarios with no additional code — the prior architecture already has the right shape.

**Biggest residual risk:** correlated-library risk of TanStack Start + better-auth pair. Mitigation is the *tested* migration-back unstub guide. If that guide isn't actually executed once before shipping, it's a lie.

**7 new Tier 1 features added: #92–#98.** All defensive, enforceable via tooling.

---

#### What If Scenarios — Booster Provocation #3

**"What if we enforced RLS from the get go?"** (user-injected)

Exposed that Axis 1's Tier-2-unstub default was "not overengineered" instinct misapplied to a security invariant. Convention (`tenantGuard()`) beats nothing; invariant (RLS) beats convention — especially for a boilerplate whose users fork fast and cut corners per iteration.

**Decision: flip RLS to Day 1 default.** Axis 1 revised. `tenantGuard()` reshaped to be the session-variable-setter, not the WHERE-clause injector. Kill #4 becomes physically prevented, not just conventionally enforced.

Cost: ~1 day setup + forker's 2-hour learning curve. Payoff: Kill #4 drops from "possible with enforcement" to "physically prevented"; enterprise-readiness timeline shortens; the Postgres-first thesis (#80) actually gets applied where it matters most.

**[Feat #99] RLS policies Day 1; `tenantGuard()` as session-variable-setter** — _Tier 1_
_Concept_: Every tenant-scoped table ships with Postgres RLS policy using `current_setting('app.current_team_id')`. Prisma client extension sets it inside `tenantGuard()` transaction. ESLint rule enforces style; RLS enforces security.
_Defense_: Convention → invariant. Flipping Tier 2 → Tier 1 because the "not overengineered" lens is wrong for security invariants.
_Novelty_: First boilerplate with DB-level tenant isolation as *default*, not optional path.

**[Feat #100] `pnpm rls:explain` — RLS-aware query debugger** — _Tier 1_
_Concept_: CLI takes a query + tenant ID, runs with RLS debug logging, shows which policies filtered what. Turns silent-filter onboarding friction into a lookup.
_Defense_: Eliminates the single biggest RLS adoption friction; makes RLS feel like an ergonomic default.
_Novelty_: DX investment in the RLS experience — treats forker learning curve as a first-class concern.

---

### Phase 5 — Target User & Use-Case Ideation

Role Playing (4 pro-personas) + Permission Giving (5 anti-personas) + Flagship use cases.

#### Pro-personas (designed for)
- **Alex — Solo Indie Hacker** — ships idea #4 this weekend; wants local-first, zero cloud deps, $5/mo bill
- **Priya — Small-Team Startup CTO** — passes security diligence on Day 1; splits features to 4 engineers; onboards #5 in a day
- **Marcus — Agency Contractor** — 2–3 forks/month; needs 6-month upstream compatibility; kernel-vs-plumage discipline
- **Sam — AI-Assisted Builder** — pair-programs with Claude/Cursor; needs explicit-over-implicit codebase patterns

#### Anti-personas (say loudly: not for you, try X)
- Enterprise Architect → Clerk Enterprise / WorkOS
- Next.js Learner → create-t3-app + tutorials first
- Hobbyist / Portfolio → Vercel template
- B2C Consumer App Builder → B2C-specific starter or strip teams layer
- API-First / Developer Tools SaaS → unstub #12 + #14 immediately or pick different starter
- Marketplace / Multi-sided → swap Paddle for Stripe Connect or pick Bullet Train / SaaS Pegasus

#### Flagship use cases (scripted acceptance tests, not marketing)
- **UC#1** Weekend SaaS Drop (Alex) — validated by 60-min test (#94)
- **UC#2** Funded Seed-Stage MVP (Priya) — security diligence, 4-person team, engineer #5 onboards in a day
- **UC#3** Agency "Client SaaS N" (Marcus) — fork + 6-month upstream rebase with zero conflicts
- **UC#4** AI-Assisted Solo Ship (Sam) — AI-regenerated `src/` doesn't break the boilerplate
- **UC#5** Rapid-Iteration Founder (Tthew) — idea #7 ships in 2 days

#### Sharpened target user

> The experienced founder or small team that ships SaaS ideas rapidly and often. Values shipping velocity over stack novelty, database-level invariants over application conventions, and honest constraints over feature-count marketing. Has shipped before. Will fork this more than once. Comfortable with Postgres, SQL, CLI-first workflows.

**[Feat #101] Anti-persona section prominent in README** — _Tier 1_
Third header in README after pitch and elevator. Honest redirects to better-fit alternatives. Ethical positioning + filter.

**[Feat #102] AI-assisted builder as a named design audience** — _Tier 1_
Sam (persona #4) is first-class, not afterthought. Design principles: explicit over implicit, consistent over clever, typed over duck. AI-paired dev is how the target user ships in 2026.

**[Feat #103] Flagship use cases as scripted acceptance tests, not marketing copy** — _Tier 1_
Each UC has a CI test. UC#1 = 60-min test. UC#3 = scripted fork + simulated upstream rebase with zero-conflict assertion. UC#4 = AI-regenerated `src/` doesn't break.

**[Feat #104] Target-user filter at README top** — _Tier 1_
First 3 lines of README: pitch / target-user filter / anti-persona link. User self-filters before cloning.

---

## Idea Organization & Prioritization

### Thematic Clusters (13 themes)

1. **Repo Foundation & Tooling** — #24, #25, #27, #29, #33, #42, #61, #65, #71
2. **Auth & Identity Core** — #18, #35, #36, #40, #43, #47, #51, #52, #53, #54, #57, #62, #69, #90
3. **Data Model & Tenancy** — #38, #49, #92, #99, #100
4. **Billing (Paddle)** — #2, #13, #20, #28, #58, #66, #67, #68
5. **Email & Communications** — #3 + 3-template baseline
6. **Jobs System** — #6, #72, #73
7. **Feature Flags** — #5, #56, #63
8. **Audit & Observability** — #8, #9, #41, #44, #93
9. **Frontend Patterns** — #39, #46, #48, #50, #55, #63, #90
10. **Deploy & Ops** — #10, #30, #31, Axis 2
11. **Docs & Process** — #23, #64, #87, #88, #89, #95, #96, #97, #101, #102, #104
12. **Testing & Quality** — #32, #60, #94, #98, #103
13. **Seed / Dev Experience** — #59

### Implementation Milestones (9 phases, ~22 focused days)

| # | Milestone | Theme(s) | Est. |
|---|-----------|----------|------|
| M0 | Repo foundation & tooling | 1, 11 | 2d |
| M1 | Data model + RLS tenancy | 3 | 2d |
| M2 | Auth & Identity | 2 | 3d |
| M3 | Billing (Paddle) | 4 | 3d |
| M4 | Email + Jobs | 5, 6 | 2d |
| M5 | Observability + Audit | 8 | 2d |
| M6 | Feature flags | 7 | 1d |
| M7 | Frontend patterns + UI | 9 | 3d |
| M8 | Docs & discipline systems | 11 | 2d |
| M9 | Testing & CI hardening | 12, 13 | 2d |

Critical path: M1 → M2 → M3/M4; M7 parallelizable post-M2; M8 parallel; M9 last.

### Top Priority — This Week's Actions

1. **Run `/bmad-create-prd`** — convert this session into a formal PRD with ~20 epics
2. **Write one-page positioning doc** — opens the README
3. **2-hour integration spike** — verify TanStack Start + better-auth + Prisma + tRPC works together (riskiest correlated assumption)
4. **(Optional) `/bmad-create-architecture`** — formalize the 7-axis architectural decisions

### Three Patterns Worth Naming

1. **"Not overengineered" as a lens has a failure mode** — it drifts toward undershipping on security invariants and structural commitments. Three user provocations (Paddle, TanStack Start, Day-1 RLS) caught this; all three flipped Tier 2 defaults to Tier 1.
2. **Adapter exceptions earn their keep only when defended** — only two adapters in the whole design (payments, jobs); both justified by business-model or structural criteria; every other "swappable" interface is rejected on purpose.
3. **Invariants beat conventions beat documentation** — RLS > tenantGuard > "remember to filter by teamId." Security posture comes from escalating to invariants wherever the cost is reasonable.

---

## Session Summary & Completion

**Topic:** SaaS boilerplate project — solid architectural foundation as a jumping pad for rapid iteration on SaaS ideas.

**Approach:** Progressive Technique Flow across 5 phases.

**Totals:**
- Ideas generated: **104**
- Rejected (Tier 3, openly cut): **~9** (explicit #26, #34, #50 plus COMBINE-phase cuts)
- Surviving: **~95** (40 Tier 1 structural + 15 Tier 1 process/docs + 17 Tier 2 stubs + ~20 positioning/design)
- Load-bearing architectural axes resolved: **7**
- User-injected What If provocations that overturned defaults: **3** (Paddle, TanStack Start, Day-1 RLS)

**Final stack anchor:**
TS · **TanStack Start** (Vite) · Postgres · Prisma · tRPC · react-hook-form+Zod · Zustand · **better-auth** · **Paddle** · Resend · pg-boss · Tailwind · OpenTelemetry

**Core differentiators (Phase 3 result):**
1. Paddle-first billing (MoR, no tax code, ever)
2. Modular monolith with enforced boundaries (microservices-optional)
3. Unstub guides as first-class (docs are features)
4. Database-level tenant isolation Day 1 (RLS, not convention)

**Target user (sharpened):**
The experienced founder or small team that ships SaaS ideas rapidly and often. Values shipping velocity over stack novelty, database-level invariants over application conventions, and honest constraints over feature-count marketing.

**Success criterion:** The 60-minute test — `git clone` → signup → verify → team → paid subscription in ≤60 minutes, measured by scripted CI job.

**Next BMad workflow steps:**
1. `/bmad-create-prd` — convert brainstorm into PRD (~20 epics)
2. `/bmad-create-architecture` — formalize 7-axis architectural decisions
3. `/bmad-create-epics-and-stories` — break down into implementation backlog
4. `/bmad-check-implementation-readiness` — validate gate before sprint planning
5. `/bmad-sprint-planning` — kick off implementation






