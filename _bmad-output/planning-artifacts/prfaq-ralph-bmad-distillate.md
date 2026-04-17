---
title: "PRFAQ Distillate: Keel"
type: llm-distillate
source: "prfaq-ralph-bmad.md"
created: "2026-04-17"
purpose: "Token-efficient context for downstream PRD creation"
---

# PRFAQ Distillate: Keel

## Concept summary

- Keel is an opinionated SaaS substrate for experienced solo builders using agentic workflows (BMad planning + Ralph loop + Claude Code).
- Non-commercial, scratch-your-own-itch / personal infrastructure / open-source candidate. MIT license. N=1 primary user (Tthew).
- Value proposition: decisions pre-made so agents execute without spiraling. Discipline moved from head to repo.
- Thesis: "Your agents are only as good as the decisions you've already made for them."
- Target bar: Launchpad — live URL, signup, one paying customer (framed as a functional test, not a commercial milestone), walk-away-ready.
- Voice: manifesto to peers; plain English; honest disqualification; no marketing.

## Target persona

- Primary: Tthew (N=1). Experienced solo leader, 25+ years web dev, pivoting into agentic workflows. Customer = author.
- Archetype: experienced solo builder who ships with agents, not "everyone."
- Four pro-personas from brainstorm (may surface in PRD user research): Alex (solo indie), Priya (startup CTO), Marcus (agency builder), Sam (AI-paired builder).
- Anti-personas with explicit redirects: Enterprise → Clerk/WorkOS; Learner → create-t3-app; Hobbyist → Vercel template; B2C consumer apps; API-first products; Marketplace products.
- Not for: human-typing-code workflows, teams that skip the Claude Code + BMad + Ralph stack, clean learner experiences.

## Rejected framings and why they were dropped

- "SaaS boilerplate" framing — rejected as crowded category (Makerkit/ShipFast/Supastarter commoditised at $199-$299). Keel is positioned as agent-execute optimised, not human-read/write optimised.
- Community-member / user quote in press release — cut as speculative-future fiction; violates "keep it real" bar; leader quote carries voice alone.
- Headline alternatives rejected: "Stop rebuilding auth every time Claude ships a new model" (negative framing, too Claude-specific); "An opinionated SaaS launchpad for the 'On the Loop' era" (buzzword-reliant).
- Name alternatives rejected: Forgepad (composite with visible seams), Substrate (deliberately boring but passed over), Primer, Plinth, Understory, Decided (audacious but risky as unsearchable English word). Chose Keel for structural-metaphor directness.
- AI-writing tropes explicitly rejected mid-session: tricolons, "not X — it's Y" constructions, manufactured vividness ("miracle / wet yarn"), excessive em-dashes, marketing abstractions ("collapses the decision tax"), false precision. Tthew flagged these against Wikipedia's "Signs of AI writing" page.

## Stack (validated, settled — these are Tier-1 structural commitments)

- Language: TypeScript
- Framework: TanStack Start on Vite
- DB: Postgres
- ORM: Prisma
- API: tRPC (typed contracts end-to-end)
- Auth: better-auth (DB-backed sessions). NO adapter — hardwired.
- Payments: Paddle (Merchant of Record; no VAT/invoice/dunning in userland). HAS adapter.
- Jobs: pg-boss (in-process, Postgres-native; no Redis). HAS typed job-registry adapter.
- Email: Resend
- UI: Tailwind
- Observability: OpenTelemetry
- Monorepo: pnpm workspaces + Turborepo
- Package topology: 1 app + 10 packages — `apps/web` + `packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui}`
- Forms: react-hook-form + Zod
- State: Zustand

## Tooling decisions (non-default choices that matter for PRD-level detail)

- `prek` (Rust reimpl of pre-commit framework) chosen over `husky`. Reason: declarative YAML config, broader hook ecosystem via pre-commit.com registry, faster, no Node required for the hook runner itself.
- `commitlint` for conventional-commit format enforcement, invoked via `prek` as a pre-commit hook.
- `release-please` (Google) chosen over `semantic-release` and `changesets`. Reason: human-gated Release PR matches N=1 maintainer cadence; monorepo-aware via release-please-monorepo; no npm publish needed (fork-and-use model); the commits decide the version, the maintainer decides when to ship.
- ESLint `no-restricted-imports` + TypeScript project references enforce package import boundaries at compile time (not at review time).
- Deliberate adapter exceptions: ONLY payments (MoR vs PSP is business-model-specific) and jobs (typed job registry). Auth gets NO adapter by deliberate commitment.
- All other cross-component swaps route through unstub guides in `docs/unstub/` — executed quarterly in CI, stale guide = red build.

## Quality gates (non-negotiable, four layers + backpressure)

- Pre-commit (via prek): type-check, lint, format, conventional-commit format (commitlint).
- Pre-merge: unit + integration tests green, RLS policies passing against every migration, import boundaries enforced, Dependabot and security audit clean.
- Pre-deploy: 60-minute integration test green, no direct-to-main commits.
- Release automation: release-please maintains rolling Release PR; merging tags + publishes GitHub release.
- Ralph backpressure: agent loop halts on consecutive failed tests or task-budget exhaustion — does not burn cycles on broken premises.
- Non-toggle-able inside a Keel repo. Forking to remove is permitted; disabling via config is not.

## Competitive intelligence

- ShipFast/Makerkit/Supastarter: human-optimised, no agentic affordances, commoditised $199-$299 tier. Differentiator: Keel is agent-execute optimised; decisions are documented/enforced at the data layer rather than held as human convention.
- Everything-Claude-Code / Antigravity (1,372+ skills): skill packs layered onto any codebase; not a running substrate. Differentiator: Keel ships a deployable substrate, not skill packs.
- Bmalph / BMAD+Ralph glue CLIs: orchestration-only; no deployed product substrate. Differentiator: Keel is what Bmalph operates on.
- Category gap confirmed: no incumbent owns "opinionated substrate tuned for agentic solo-founder SaaS."

## Market timing (for "why now" in PRD)

- Opus 4.7 shipped 2026-04-16 (day before this PRFAQ) — task budgets, xhigh effort default, multi-hour coherence on 1M context. Long-horizon agent loops are now reliable.
- Industry phrases named in last 4 months: "vibe coding hangover" (late 2025), "invisible complexity gap / context rot", "80% problem", "On the Loop" mental model.
- Karpathy declared vibe coding passé 2026-02-08; community moved to "context engineering" and "agentic engineering."
- Solo-founded startups rose from 23.7% (2019) to 36.3% (mid-2025).
- Ralph loop reached 12k+ GitHub stars in 2 months; BMad+Ralph fusion projects (Bmalph, vibesparking) proliferating.

## Scope — IN

- Full stack listed above.
- Day-1 RLS policies for multi-tenant isolation (not a Tier-2 unstub — invariant, not convention).
- 60-minute CI integration test: fresh clone → signup → team → paid Paddle subscription must pass in under an hour.
- Unstub guides as first-class deliverables, two planned at 1.0: TanStack Start ↔ Next.js, better-auth ↔ Auth.js. Quarterly CI runs.
- Four-layer quality gates + Ralph backpressure.
- Conventional commits enforced by prek + commitlint + release-please.
- BMad + Ralph + Claude Code assumed as the agentic workflow.

## Scope — OUT

- Clean learner experience (Keel assumes prior SaaS shipping).
- Enterprise affordances: no SSO adapter, no SIEM/audit-log shipping, no SOC 2 ambition.
- Marketplace / B2C product shapes.
- Admin dashboard, outbound webhooks, REST/GraphQL API-from-day-one, multi-DB ORM abstraction.
- Adoption outside the Claude Code + BMad + Ralph workflow (tests/docs assume this; not hostile, just not accommodated).
- Toggle-able quality gates.
- Distribution / customer acquisition (accepted trade-off; belongs to a separate follow-on project).
- npm publish of packages (fork-and-use model).

## Scope — MAYBE

- Independent package versioning via release-please-monorepo (if a package is later extracted as a standalone library).
- Additional unstub guides beyond the initial two.
- Adoption signaling beyond MIT license — blog post, peer-community share. Not planned, not forbidden.

## Open questions / unknowns (flagged for PRD follow-up)

- Full Day-1 RLS policy matrix has not been designed. Existing RLS experience is partial. **Spike before M2.**
- Unstub guide authoring with tested CI run is ~2x effort of prose guides. Unproven at Keel's scale.
- How Keel's versioning cadence keeps up with model/tooling releases. First Opus 4.7 → 4.8/5.0 break will reveal whether release-please + conventional commits + quarterly CI is enough.
- Adoption path beyond N=1 (no plan; acceptable for scratch-your-own-itch, missed opportunity vs manifesto voice).
- The 40% procrastination admission (Q10): what specific product opportunity or harder commitment is Keel delaying? **Unresolved; Tthew to self-examine before M1.**

## Resource & timeline

- 22-day milestone plan (M0 repo → M9 CI hardening); critical path M1 → M2 → M3/M4.
- Realistic revised budget if first-slip assumptions hit: 28-32 days.
- First-slip candidates: 60-minute CI test (3 planned → 5-6 real), unstub guide authoring (1 day prose → 2 days CI-passing).
- Compression absorbed by M7-M9 (docs polish, CI hardening); substrate stays on spec.
- Ongoing maintenance after 1.0: 5-10 hrs/month. Exit threshold: >15 hrs/month consistently → archive or cut scope.
- Break-even: 2-4 real products shipped on Keel within 12 months of 1.0.

## Governance mechanisms (commitments Tthew accepted)

- **M4 checkpoint:** at end of critical path, explicit decision between pushing M5-M9 vs pausing Keel to ship real product on partial substrate. Procrastination governance.
- **12-month / 2-product kill criterion:** if fewer than 2 products ship on Keel within 12 months of 1.0 → archive. ACCEPTED.
- **15-hour/month maintenance ceiling:** exceeding this consistently triggers scope cut or archive.
- **60-minute CI gate:** integration test is the substrate-readiness floor; red test = broken repo.
- **Release-please human gate:** commits decide version; maintainer decides when to ship.

## Risks surfaced and mitigations

- **Agent capability absorbs substrate.** Existential risk. Possible 2026, probable 2027. Relevance window 12-18 months. Mitigation is principles (YAGNI/DRY/NIH-refusal) and documented rationale survive the specific stack decisions.
- **Paddle pivot or sandbox API sunset.** Single-event risk that breaks billing opinion + 60-minute CI test together. No other single event breaks this many commitments. Mitigation: register payment adapter early, keep Stripe integration as a tested alternative via adapter.
- **TanStack Start + better-auth correlated-library risk.** Mitigation: tested migration-back unstub guides + quarterly CI. Not yet battle-tested.
- **Day-1 RLS policy complexity.** Novel problem at full multi-tenant SaaS scale. Mitigation: pre-M2 spike to validate feasibility.
- **Stack aging with model/tooling evolution.** Opus 4.7 already broke 4.6 prompts. Mitigation: semver-versioned releases with dated changelog; each Keel major version documents the model-and-tooling combination it was tested against.

## Verdict findings — actionable items for downstream PRD

### Forged in steel (carry forward as-is)

- Thesis: "Your agents are only as good as the decisions you've already made for them."
- Stack, package split, adapter policy (2 deliberate exceptions: payments, jobs).
- Four-layer quality gates + Ralph backpressure, tooling named (prek + commitlint + release-please).
- Kill criteria: 2-product/12-month archive; M4 checkpoint; 15-hr/month maintenance ceiling.

### Needs more heat (address before or during PRD)

- Unstub guide CI-tested authoring — budget 2x effort of prose; plan for first two guides early.
- Day-1 RLS policy matrix — sketch a full policy set as a ≤1-day pre-M2 spike.
- Versioning cadence as a practice — first Opus tooling event triggers a Keel major release test run.
- Adoption signaling — decide in PRD whether an intentional launch signal exists.

### Cracks (must be addressed deliberately)

- Distribution blindspot — carve a follow-on "Keel + distribution playbook" project; don't let the press release's "one paying customer" claim bleed into substrate scope.
- Relevance window — 22-day build only pays back via 2+ products shipped within 12-18 months; governance checkpoint at M4.
- 40% procrastination admission — Tthew self-examination before M1.
- Correlated-library pair — migration-back guides must be written and pass CI before external adoption is invited.

## Three pre-M2 hardening actions (from Verdict)

1. **RLS policy matrix spike (≤ 1 day).** If full policy set doesn't converge in a day, downgrade Day-1 RLS to Tier-2 stub with clear unstub path.
2. **M4 checkpoint ritual.** Calendar date + specific question ("ship on partial Keel, or push M5-M9?") before M1 begins.
3. **Procrastination honesty.** 30 minutes naming the 40%. Document internally; doesn't need sharing.

## Next-step recommendation

Use this PRFAQ + distillate as input for PRD creation. The PRFAQ replaces the product brief in the planning pipeline. Downstream skill: `bmad-create-prd` with these files pointed to as context.
