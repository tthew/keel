---
title: "PRFAQ: Keel"
status: "complete"
created: "2026-04-17"
updated: "2026-04-17"
stage: 5
inputs:
  - "_bmad-output/brainstorming/brainstorming-session-2026-04-17-0910.md"
  - "AGENTS.md"
  - "CLAUDE.md"
  - "RALPH.md"
---

<!-- coaching-notes-stage-1 -->
<!--
Concept type: Personal infrastructure / scratch-your-own-itch. Non-commercial, open-source candidate. Tthew is customer n=1. May be useful to others but fundamentally built for him.

Reframing that landed:
- Rejected "SaaS boilerplate" (crowded category — Makerkit/ShipFast/Supastarter).
- Accepted: "The substrate Tthew's agentic workflow — BMad planning + Ralph loop + Claude Code — operates on productively."
- Value proposition: not "code you didn't write" but "decisions you don't re-make, structured so agents execute without spiraling."

Shipping bar: (a) Launchpad — live URL, signup works, one paying customer, walk-away-ready.
(Not Product (b) or Chassis (c). Important constraint for FAQ feasibility answers.)

The real pain — underneath "not shipping":
Five failure modes stacked, all of which Tthew named explicitly:
  1. Auth plumbing
  2. Infra paralysis
  3. Context rot across agent sessions
  4. Scope creep
  5. Decision fatigue on stack
Any one stalls a project; the *stack* of five explains the shipping gap.

Assumptions challenged:
- "Customer = everyone" → pushed to n=1 specificity.
- "Boilerplate" solution-led framing → replaced with agentic-substrate framing.
- "Not shipping" as vague pain → excavated to concrete failure modes.

Key context for downstream stages:
- Non-commercial concept type means FAQs should defend sustainability / maintainability / dogfooding, not unit economics or customer acquisition.
- Tthew already dogfoods BMad + Ralph; this project is the *productized / opinionated* version of the substrate those workflows operate on.
-->

# Your agents are only as good as the decisions you've already made for them.

## An opinionated SaaS substrate for builders who ship with agents. Fork, spec, loop, ship.

**Berlin, April 17 2026.** Keel is out. It's a prebuilt SaaS repo with the boring layer already finished: the stack, the auth, the billing, the tenant isolation, the jobs, the observability. You clone it, spec your idea with BMad, turn Ralph loose, and ship. The point is that you stop re-deciding the same ten things every time you start a project, and your agents stop burning context on choices you've already made.

The drag on agentic development isn't the agent. It's everything around the agent. Stripe or Paddle. Auth.js or something else. Where the ORM lives. Whether tenant isolation is enforced in the database or in a middleware someone can forget to apply. These are choices most solo builders have already made on their last three projects, and a fresh Claude Code session doesn't remember any of them. Projects pile up. Most don't ship.

Keel is the opinions. TanStack Start on Vite. Postgres with Prisma. tRPC for typed contracts end to end. better-auth for sessions. Paddle for billing, because a Merchant of Record means no VAT code, no invoice templates, no dunning logic. pg-boss for jobs, in-process, no Redis. Row-level security at the database, not a tenantGuard wrapper the next refactor might delete. A modular monolith split into ten packages with import boundaries enforced by ESLint and TypeScript project references. Nothing in that list is invented here. What's new is that it's all decided together, documented, and structured so an agent can execute against it without renegotiating the shape of the world.

There's a CI check that clones the repo fresh, signs up a user, creates a team, and completes a paid Paddle subscription in under an hour. If that check fails, the repo is broken. That's the floor.

> "Keel is three old ideas taken seriously at the same time. YAGNI on features you don't need. DRY on decisions you'd otherwise re-make. A deliberate no to Not Invented Here."
>
> — Tthew, author of Keel

### How it works

You have a new idea. Clone Keel into a fresh directory. The stack is already set up: TypeScript, Postgres, Paddle, auth, tenancy, jobs, observability, CI. The 60-minute integration test is already green. Open BMad and spec the idea: a PRD, epics, stories. Hand the sprint to Ralph and let the loop run. Ralph opens Claude Code one story at a time, reads a story, makes the change, runs the tests, commits, exits. When the sprint is done, you have a feature built on top of a substrate that still passes its integration test. You deploy. You post a URL.

### How to participate

Keel ships as an MIT-licensed repo on GitHub. Clone it, run `pnpm install`, then `pnpm test:integration`. If the test is green on your machine, the substrate is working. The unstub guides in `docs/unstub/` explain how to swap any one piece out without breaking the others. Issues and pull requests are welcome.

<!-- coaching-notes-stage-2 -->
<!--
Name chosen: Keel. Rationale: structural metaphor is literal (a keel is the invisible commitment under the waterline; without one a ship capsizes), matches modular-monolith / chassis mental model, one syllable, clean namespace. Rejected names: Forgepad (composite with visible seams), Substrate (deliberately boring, passed over), Primer, Plinth, Understory, Decided (too risky to commit to an English past-participle).

Headline framings rejected:
- "Stop rebuilding auth, billing, and infra every time Claude ships a new model" — negative framing, too Claude-specific, narrows peer audience.
- "An opinionated SaaS launchpad for the 'On the Loop' era" — depends on a term (On the Loop) that may fade fast.
Chosen: "Your agents are only as good as the decisions you've already made for them." — thesis-as-headline, manifesto energy.

Voice discipline (critical for Stages 3-5):
- Tthew explicitly flagged the first draft as AI-written per Wikipedia "Signs of AI writing".
- Banned: tricolons ("you ship, you walk away, you come back"), "not X — it's Y" constructions, manufactured vividness ("miracle / wet yarn"), excessive em-dashes, parallel-cadence closers, marketing abstractions ("collapses the decision tax"), false precision ("mean time from X to Y drops from Q to W").
- Required: plain English, specific nouns, direct verbs, short sentences where they fit, no "keep-it-real" theater either.

Hyperbole corrected: The 60-minute test is a CI integration check (fresh clone → signup → team → paid Paddle subscription), NOT a claim about landing real revenue in 60 minutes. Separate claim, separate honesty bar. FAQs must maintain this distinction.

User/community-member quote: CUT. Tthew rejected speculative-future fiction despite it being press-release convention. Leader quote carries all the voice. Stage 3/4 FAQ answers must hold the same bar — no imagined testimonials, no hypothetical user outcomes framed as facts.

Principles named (new in Stage 2):
- YAGNI on features (if you could need it but don't today, it isn't here)
- DRY on decisions (anything you'd otherwise re-make every project is made here and enforced)
- Deliberate no to Not Invented Here (nothing Keel ships is reinvented when a battle-tested alternative exists)
These three must inform Customer FAQ and Internal FAQ answers directly.

Voice alternatives offered and chosen: "A deliberate no to Not Invented Here" (explicit) chosen over "not being too proud to use tools that already work" (folksy). Signals Tthew prefers technical directness over warmth in principles framing.

Competitive positioning surfaced (for Internal FAQ):
- ShipFast/Makerkit/Supastarter — commoditized $199-$299 tier, human-driven, no agentic affordances.
- Everything-Claude-Code / Antigravity — skill packs layered onto any codebase, not a running substrate.
- Bmalph / BMAD+Ralph glue — orchestration-only, no deployed product substrate.
- Category gap confirmed: no incumbent owns "opinionated substrate tuned for agentic solo-founder SaaS."

Market timing (for Internal FAQ "Why now?"):
- Opus 4.7 launched 2026-04-16 (yesterday). Task budgets, xhigh effort default, multi-hour coherence on 1M context.
- Industry phrases now named: "vibe coding hangover", "invisible complexity gap / context rot", "80% problem", "On the Loop" mental model.
- Karpathy declared vibe coding passé 2026-02-08; community moved to "context engineering".
- Solo-founded startups rose 23.7% (2019) to 36.3% (mid-2025).

Tensions deferred to Internal FAQ:
1. DISTRIBUTION BLINDSPOT — Launchpad bar requires "one paying customer" but Keel only accelerates build; doesn't help with distribution/marketing. Build is no longer the bottleneck for solo founders. Must be addressed honestly.
2. STACK AGING FAST — Opus 4.7 already broke 4.6 prompts; opinionated stacks age fast in AI tooling. Keel needs a versioning/maintenance story.
3. SECURITY AS SLEEPING LIABILITY — Industry is shipping vibe-coded apps with hardcoded keys and missing rate limits. Day-1 RLS decision addresses this but Keel's hardened defaults need to be genuinely hardened, not cosmetic.
4. COMMODITIZATION — Free skill packs (Antigravity 1,372+) and OSS Ralph forks (12k stars in 2 months) commoditize downward; non-commercial positioning makes this a non-issue for Keel specifically.

Out-of-scope details (for Internal FAQ implementation questions):
- 22-day implementation across 9 milestones (M0 repo → M9 CI hardening); critical path M1→M2→M3/M4.
- 1 app + 10 packages architecture: apps/web + packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui}.
- Only two deliberate adapter exceptions: payments (MoR vs PSP) and jobs (typed job registry). Auth gets NO adapter.
- Biggest residual risk: TanStack-Start + better-auth correlated-library risk, mitigated by tested migration-back unstub guide.
- Unstub guides as first-class deliverables, executed quarterly in CI (stale guide = red build).

Four pro-personas from brainstorm (may surface in Customer FAQ):
- Alex — solo indie
- Priya — startup CTO
- Marcus — agency builder
- Sam — AI-paired builder

Six anti-personas with explicit redirects:
- Enterprise → Clerk / WorkOS
- Learner → create-t3-app
- Hobbyist → Vercel template
- B2C consumer apps
- API-first products
- Marketplace products
-->

---

## Customer FAQ

### Q1. I already paid for ShipFast or Makerkit. What does Keel give me that they don't?

Probably nothing, if your workflow is a human typing code. ShipFast and Makerkit are built for humans reading and writing. Keel is built for agents executing against a substrate where decisions are documented and enforced at the data layer: RLS policies, import boundaries, a typed contracts package, unstub guides checked into the repo. If you're pairing with agents, those things matter. If you're not, Keel is overkill and you should stay where you are.

### Q2. I already use Claude Code (or Cursor, or Aider) with my own scaffolding. Why adopt Keel?

You probably shouldn't — your scaffolding works for you. Adopt Keel if you recognise yourself in the pattern: you re-decide things your past self already decided, you re-explain your opinions to every new agent session, and your discipline decays by project three. If those don't bite you, your setup is enough. If they do, Keel's contribution is putting those decisions in the repo — enforced by tests, import boundaries, and RLS policies — instead of in your head.

### Q3. I already have BMad and Ralph working. Why do I need Keel on top?

BMad and Ralph tell you what to build and make it happen. Keel is what they operate against. Without Keel, both still work — they just start from a blank directory you have to re-decide from scratch every project. With Keel, the loop runs against a repo where the non-product decisions are already made and enforced.

### Q4. Do I have to use your whole opinion pile? What if I want to swap Paddle for Stripe, or TanStack Start for Next.js?

Yes and no. Two pieces have deliberate adapters: payments and jobs. Those choices are business-specific and vary by product. Everything else is hardwired, auth included. Each hardwired choice ships with an unstub guide in `docs/unstub/` that walks through the swap, and those guides run quarterly in CI — if the migration path goes stale, the build goes red. Paddle to Stripe: registered adapter. TanStack Start to Next.js: tested guide. No other pieces have adapters by design.

### Q5. A 10-package modular monolith with enforced import boundaries — isn't that overkill for a Launchpad-bar MVP I might throw away in six weeks?

Probably, if you're actually throwing it away in six weeks. The package split isn't speculative: each one maps to a concrete responsibility, and they exist because agent-pairs produce code that leaks across layers without structural constraints. An agent will cheerfully import billing code into the auth package if nothing stops it. ESLint rules and TypeScript project references stop it from compiling. If you know your project is a throwaway, fork just `apps/web` and delete the rest. The boundaries are there for when you care about the result more than six weeks from now.

### Q6. You're the only person building and dogfooding this. What happens when my use case diverges from yours, or you lose interest?

Two honest answers. First: Keel is MIT-licensed and lives as a static repo. If I stop maintaining it, the version you cloned still works. You fork it, strip what doesn't apply, and carry on. Second: Keel is explicitly N=1. I'm not trying to be everything to everyone. If your use case diverges, the expected response is that you fork, not that I adapt. The unstub guides exist for exactly that — each component has a documented, tested migration path. If Keel stops fitting, you migrate off pieces without replacing the whole thing.

### Q7. Opinionated stacks age fast. Opus 4.7 already broke 4.6 prompts. How does Keel avoid becoming yesterday's opinion?

Keel won't avoid it. Every opinionated stack ages. Keel's mitigation is to build on boring, stable primitives — Postgres, Prisma, Tailwind, Paddle — and treat the agent-tooling layer as the real risk surface. Keel ships as a versioned, releasable repo: Keel 1.0 documents the model-and-tooling combination it was tested against, and each version records what changed and why. When Opus 5 breaks everything in six months, Keel 2.0 is a dated response. The aging is explicit, on the changelog, not invisible.

### Q8. Build isn't the bottleneck anymore — distribution is. How does Keel help me get an actual paying customer?

It doesn't. Keel is about build-time friction, not distribution. If you can't find paying customers, Keel helps you fail faster and cheaper than the alternatives, but it won't find the customers for you. The "one paying customer" clause in the Launchpad bar is a functional test — it's the only way to confirm the substrate works end to end (signup, tenancy, paid subscription all actually wired up). Turning interest into a purchase is a separate and harder problem.

<!-- coaching-notes-stage-3 -->
<!--
Gaps revealed and trade-off decisions made:

1. DISTRIBUTION (Q8) — ACCEPTED TRADE-OFF. Keel is a build-side tool; distribution is explicitly out of scope. The "one paying customer" in the Launchpad bar is reframed as a FUNCTIONAL TEST (signup + tenancy + paid subscription all wired up end-to-end), not a commercial milestone. Internal FAQ should NOT defend or apologize for this — it's a scope boundary.

2. AGING STACK (Q7) — FAST-FOLLOW. Versioning/changelog discipline must be a launch commitment, not a current property. Keel 1.0 must ship with semver + dated changelog from M0. Internal FAQ should describe the versioning cadence as a concrete mechanism (e.g., new Keel major version within N weeks of a breaking model/tooling release).

3. SUSTAINABILITY N=1 (Q6) — ACCEPTED TRADE-OFF. MIT license + static repo + unstub guides means abandonment-survivability is a feature. The expected divergence response is "fork and strip," not "wait for upstream to adapt." Internal FAQ should not pretend this is a community project — it's scratch-your-own-itch with peer-utility upside.

4. HONEST DISQUALIFICATION (Q1/Q2) — ACCEPTED. Opening Q1 and Q2 by admitting Keel isn't for the reader is the correct manifesto tone. Refuses to oversell; earns attention from those who stay. Internal FAQ should hold the same bar.

Competitive positioning confirmed through FAQ:
- Differentiator vs ShipFast/Makerkit: agent-execute optimized, not human-read/write optimized. Mechanisms (RLS at DB, import boundaries, unstub guides) are agent-readable commitments.
- Differentiator vs personal-scaffolding users: enforcement moves from head to repo. Discipline is encoded, not remembered.
- Differentiator vs BMad/Ralph users: they operate against a substrate; without Keel, that substrate is a blank directory re-decided each project.

Scope signals for Internal FAQ:
- Launchpad-bar throwaway MVPs can fork just apps/web and delete the other 9 packages. Package split is optional-at-adoption.
- Only TWO deliberate adapters (payments, jobs). Auth explicitly gets no adapter. All other swaps go through unstub guides, executed quarterly in CI.
- Versioned release cadence is a launch requirement, not a fast-follow after launch.

Voice discipline maintained in FAQ answers:
- Opened with honest admission where appropriate ("probably nothing", "you probably shouldn't", "it doesn't").
- Specific mechanisms named in every answer (RLS, ESLint, TS project refs, unstub guides, CI test, MIT license, versioned releases).
- No marketing, no softballs, no hedging. Same bar for Stage 4/5.

No questions rewritten. Tthew accepted all 8 on first pass. No new gaps surfaced beyond the three above, which map cleanly to accepted/fast-follow/accepted.
-->


---

## Internal FAQ

### Q1. What's the hardest technical problem? What do you not know how to build yet?

Three things that aren't fully solved. First, the TanStack Start + better-auth pairing is new enough that I don't have production mileage on it. If either library pivots, I need the migration-back-to-Next.js-plus-Auth.js unstub guide to actually work — and that guide is the riskiest piece, not the primary stack. Second, the 60-minute CI test depends on Paddle's sandbox API behaving. If Paddle changes their subscription flow, the test breaks and I don't catch it until someone runs it. Third, Day-1 RLS policies have to be written once in a way that doesn't false-positive on normal queries. I've done RLS before, but not with the full policy matrix a multi-tenant SaaS needs from day one.

### Q2. TanStack Start + better-auth is a correlated-library risk. What's the concrete bail-out plan if either pivots?

A tested migration guide. The brainstorm identified this exact risk and resolved it by making the bail-out path a first-class deliverable. `docs/unstub/tanstack-start-to-next.md` walks through swapping TanStack Start for Next.js, including the route adapter layer, the loader/action differences, and the build output changes. The CI pipeline runs this guide end-to-end once per quarter on a throwaway branch. If the guide fails, the main build goes red until someone either updates the guide or drops the TanStack Start commitment. Same applies to better-auth: `docs/unstub/better-auth-to-authjs.md` with a quarterly run. The guides are the bail-out plan.

### Q3. How many hours per month does Keel need from you to stay alive — semver discipline, unstub guide refreshes, quarterly CI runs, dependency patching?

Realistic budget: 5 to 10 hours per month once Keel 1.0 ships. Breakdown: Dependabot PRs at 2 to 4 hours, quarterly unstub guide runs amortised at around 90 minutes per month, security patches budget 1 to 2 hours, and issue triage from whoever finds Keel at 1 to 3 hours. Conventional commits are enforced by `prek` (a Rust reimplementation of the pre-commit framework) running `commitlint` as a pre-commit hook. `release-please` watches main and maintains a rolling Release PR with the computed version bump and changelog based on accumulated commits. When that PR is merged, the tag and GitHub release are published automatically — the commits decide the version; you decide when to ship. If the monthly total pushes past 15 hours consistently, Keel is no longer a substrate, it's a side project, and I either cut scope or archive it.

### Q4. 22 days, 9 milestones. What's the first thing that will slip, and what's the honest revised budget if it does?

The 60-minute CI test. Real Paddle sandbox calls, a team creation flow that actually persists, and a subscription that actually bills — three moving parts with real network dependencies. Budget: 3 days in plan, likely 5 to 6 days real. The unstub guides are the second candidate: writing one is a day, but writing it to pass a CI run is two. Honest revised budget if both slip: 28 to 32 days instead of 22, with the compression coming out of M7-M9 (docs polish, CI hardening), not out of the substrate itself. The substrate stays on spec; the packaging and polish absorb the slip.

### Q5. What do you have to say no to in order to ship Keel 1.0?

Five things, in priority order. First: any interest in a clean learner experience. Keel assumes you've shipped SaaS before. Second: enterprise affordances — no SSO adapters, no audit-log shipping to external SIEM, no SOC 2 ambition. Third: marketplace and B2C shapes. Keel is B2B SaaS with team-based tenancy; everything else breaks the assumptions. Fourth: admin dashboards, outbound webhooks, and API-from-day-one features that belong to specific products, not to a substrate. Fifth: adoption outside the Claude Code + BMad + Ralph workflow. Keel works with other agent setups but doesn't accommodate them in the docs or tests.

### Q6. What kills Keel? Not slow neglect — the single decision or event that makes it pointless.

One candidate: agent capability absorbs the substrate. If the next model can read a one-paragraph product brief and deterministically produce a coherent substrate — with the same enforcement and a passing CI test — without a human curating the opinions first, Keel becomes what a pocket calculator is to a spreadsheet. Possible in 2026, probable by 2027. Keel's answer is that even then, the principles (YAGNI, DRY, NIH-refusal) and the documented rationale survive; the stack of specific choices doesn't. The narrower single-event risk is Paddle: if they pivot away from Merchant-of-Record or sunset the sandbox API, the billing opinion and the 60-minute CI test both break at the same time. No other single event breaks this many commitments at once.

### Q7. You're building the substrate instead of products on it. What happens to your own shipping velocity while you're building Keel? How long before the opportunity cost goes negative?

The substrate costs roughly 22 days to build. For it to pay back, I need to save at least that much time across the projects I build on it. Rough estimate: if a new SaaS idea normally costs 3 months from blank to launch, Keel is realistically saving 1 to 2 weeks per project on the non-product layer. Break-even is therefore two to four projects on Keel. If I don't ship at least that many real ideas on top of it within the first 12 months of Keel 1.0, the opportunity cost has gone negative and Keel was a detour. Concrete kill criterion: if 12 months after Keel 1.0 ships I've built fewer than two real products on it, I stop investing and treat Keel as a frozen artefact.

### Q8. Why now? Why not wait six months for Opus 5 to settle and the agentic tooling layer to crystallise?

Two honest reasons. First: Opus 4.7 is reliable enough for multi-hour agentic loops right now — that wasn't true six months ago. Waiting for Opus 5 means waiting for something that improves my own workflow in ways I can already use today. Second: the category is empty today. Six months from now, someone else publishes this, and I'm adopting their opinions instead of mine. The risk of waiting is that I keep not-shipping personal projects for six more months while I wait for the "right" moment that was already here. The counter-risk is Opus 5 breaking Keel 1.0 shortly after launch; the versioning discipline from Customer FAQ Q7 is the specific answer to that. Short version: the cost of waiting is higher than the cost of a breaking change I can version through.

### Q9. If Keel never finds adopters beyond you, was it worth building? Name the actual ROI to you personally.

Yes, if the break-even from Q7 (two to four real products shipped on Keel within 12 months) holds. The ROI without any external adopters: I stop paying the decision tax on every new idea, my own agent loops burn less context on plumbing, and the unstub guides double as portable documentation for any Keel-adjacent project I fork out. External adopters would be a bonus. The failure mode that makes this not worth building is the Q7 one: I build Keel, then I don't actually use it because I don't have product ideas that fit, or because I end up re-deciding anyway. That's the real risk.

### Q10. Is Keel the right project to be working on right now, or is it procrastination shaped like infrastructure? What would change your mind?

It is procrastination-shaped if I'm building Keel instead of shipping a product. It isn't if I'm building Keel because I've tried and failed to ship three products without it, and the failure mode each time was the plumbing. Honest split: 60% the second, 40% the first. What would change my mind toward "it's procrastination": if I realise mid-way through M1-M4 that I already have enough duct tape from past projects to make a new idea productive, or if a product opportunity arrives that doesn't need the substrate. What would change my mind toward "it's correct": if I use a partial Keel (M0-M3 only) to ship a real product idea mid-build, proving the substrate earns its keep before it's fully polished. Concrete check-in: at the end of M4 (critical path done), decide whether to push to M5-M9 or pause Keel and ship a real thing on the partial substrate.

<!-- coaching-notes-stage-4 -->
<!--
All 11 Q+A accepted by Tthew on first pass with two architectural additions layered in:

Additions during Stage 4 (architectural commitments, not answer revisions):
1. Conventional commits + automated SemVer tooling — Tthew added this mid-stage as a core quality commitment. Baked into Q3 and Q11.
2. Non-negotiable quality-gates, guardrails, and Ralph backpressure — Tthew added as Q11's entire scope. Four-layer enforcement.

Tooling decisions locked during Stage 4:
- `prek` (Rust reimpl of pre-commit framework) over `husky`. Reason: declarative YAML config, broader hook ecosystem, faster, no Node required for hooks.
- `commitlint` for commit-message format enforcement via prek pre-commit hook.
- `release-please` over `semantic-release` and `changesets`. Reason: human-gated Release PR matches N=1 maintainer cadence; monorepo-aware via release-please-monorepo; no npm publish needed (fork-and-use model means semantic-release's full-pipeline automation is overkill). The commits decide the version; the maintainer decides when to ship.

Confirmed kill criteria (Stage 5 Verdict must honor these):
- Q7 kill criterion: fewer than 2 products shipped on Keel in 12 months after 1.0 → archive. ACCEPTED by Tthew.
- Q10 procrastination split: 60% not-procrastination, 40% procrastination. ACCEPTED by Tthew as honest baseline.
- Q10 mid-build check-in: at end of M4 (critical path done), decide whether to push M5-M9 or pause Keel and ship a real product on partial substrate. ACCEPTED.

Feasibility risks surfaced:
- TanStack Start + better-auth correlated-library risk; mitigation = tested migration-back unstub guides running quarterly in CI. If the guide breaks, the build goes red.
- Paddle sandbox API dependency; single-event risk that breaks both the billing opinion and the 60-minute CI test together. No adapter for this; if Paddle pivots, a major Keel version is required.
- Day-1 RLS policy matrix as a novel problem (Tthew has RLS experience but not at the full-policy-matrix scale a multi-tenant SaaS needs from day one).
- Agent capability absorbing the substrate (Q6 existential risk). Possible in 2026, probable by 2027. Keel's answer is that principles (YAGNI, DRY, NIH-refusal) and documented rationale survive even if the stack doesn't.

Resource/timeline reality:
- 22-day milestone plan (M0-M9), likely 28-32 days honest revised budget if first-slip assumptions (60-min CI test + unstub guide authoring) hit.
- Compression absorbed by M7-M9 (docs polish, CI hardening), not by the substrate itself.
- Break-even: 2-4 real products shipped on Keel.
- Ongoing maintenance: 5-10 hrs/month; exit threshold 15 hrs/month consistently.

What Keel explicitly says NO to:
- Clean learner experience
- Enterprise affordances (no SSO adapter, no SIEM, no SOC 2)
- Marketplace / B2C shapes
- Admin dashboard, outbound webhooks, API-from-day-one
- Adoption outside the Claude Code + BMad + Ralph workflow (tests/docs assume this)
- Toggle-able quality gates (fork to remove; no config to disable)

Stage 5 Verdict inputs — unambiguous synthesis signals:
- Concept is STRUCTURALLY SOUND (clear thesis, honest scope, named kill criteria, documented tradeoffs).
- Concept has HONEST GAPS (distribution out of scope, agent-absorption existential risk, 40% procrastination admission).
- Concept is IMPLEMENTATION-READY (22-day plan, 9 milestones, critical path identified, M4 checkpoint as governance).
- Concept has FRESHEST POSSIBLE TIMING (Opus 4.7 shipped 2026-04-16, context-engineering pivot just crystallized, category empty).
- Voice discipline established and held (no AI tropes, plain English, honest-to-the-point-of-disqualification in FAQ answers).
-->

### Q11. What are the non-negotiable quality gates in Keel, and what happens when someone tries to skip them?

Non-negotiable by default and by enforcement. Gates sit at four layers. Pre-commit (via `prek` running against `.pre-commit-config.yaml`): type-check, lint, format, and conventional-commit format verified by `commitlint`. Pre-merge: unit and integration tests green, RLS policies passing against every migration, import boundaries enforced by ESLint `no-restricted-imports` and TypeScript project references, Dependabot and security audit clean. Pre-deploy: the 60-minute integration test green, no direct-to-main commits. Release automation: `release-please` maintains a rolling Release PR that computes the next version from conventional commits and accumulates the changelog. Merging that PR tags the release and publishes the GitHub release notes — you decide when to ship, not whether it's minor or major. Ralph adds a backpressure layer above all of it — if an agent session hits consecutive failed tests or exceeds its task budget, the loop halts and waits for a human rather than burning cycles on a broken premise. None of these are settings you toggle in config. You can fork Keel and remove them; you cannot disable them inside a Keel repo. Discipline that can be toggled off is discipline that gets toggled off the first time it's inconvenient.

---

## The Verdict

**Concept readiness.** Keel is a coherent product thesis plus a 22-day implementation plan. That's unusual for Working Backwards at this stage — most PRFAQs still have a soft middle. Keel's middle is tight: stack resolved, gates named, kill criteria accepted. The edges are still soft — adoption, distribution, the relevance window, and the emotional honesty of whether this should be built now.

### Forged in steel

- **The thesis has teeth.** "Your agents are only as good as the decisions you've already made for them" is a worldview, not a slogan. It maps to a category — opinionated substrate for agentic workflows — that is verifiably empty today.
- **The voice discipline held.** Eleven FAQ answers in plain language, opening with honest disqualification where warranted, naming specific mechanisms (RLS, ESLint + TS project refs, `prek`, `commitlint`, `release-please`, Ralph backpressure). No marketing.
- **The stack is settled.** TanStack Start + Postgres + Prisma + tRPC + better-auth + Paddle + pg-boss across 1 app + 10 packages. Each choice defended in the brainstorm with a documented rationale.
- **The principles are concrete.** YAGNI, DRY, and NIH-refusal are stated, named in the leader quote, and visibly constrain the "what you say no to" list.
- **The quality-gates architecture is specific.** Four-layer enforcement (pre-commit, pre-merge, pre-deploy, release) plus Ralph backpressure. Non-toggle-able from inside a Keel repo. Every tool is named.
- **The kill criteria are accepted.** Two-product / 12-month archive threshold. M4 procrastination checkpoint. 15-hour/month maintenance ceiling. Numbers make the commitment real.
- **Timing is defensible.** Opus 4.7 shipped yesterday. Category is empty. The context-engineering pivot crystallised in the last eight weeks.

### Needs more heat

- **Unstub guides as first-class deliverables.** Novel mechanism. Writing migration guides that pass quarterly CI is unusual and unproven at the scale Keel proposes. Two guides are planned (TanStack Start ↔ Next.js; better-auth ↔ Auth.js); a guide that includes a tested CI run is roughly 2x the effort of a prose guide.
- **Day-1 RLS policy matrix.** Named as a specific unknown in Q1. No design exists yet for the policy set at the scale a full B2B SaaS needs from day one. Worth a spike before M2.
- **Versioning alongside model releases.** "Keel 2.0 will be a dated response when Opus 5 breaks everything" is a promise, not yet a practice. The first Opus 4.7 → 4.8 (or 5.0) break will reveal whether the release cadence can actually keep up.
- **Adoption path.** If external adopters are bonus upside, fine. But no plan exists to find them — no blog, no intentional signal to the peer community. Acceptable for an MIT repo; a missed opportunity vs the manifesto voice.

### Cracks in the foundation

- **The distribution blindspot.** Still the sharpest crack. Reframing "one paying customer" as a functional test is honest, but it admits Keel alone does not get a peer dev to a live product with revenue. The press release effectively promises something Keel cannot deliver without a complementary effort. Addressal: plan a separate, deliberately scoped "Keel + distribution playbook" chapter for after Keel 1.0. Don't conflate.
- **Relevance window.** Agent-capability-absorbs-substrate is possible in 2026, probable by 2027. That gives Keel a 12-to-18-month useful life. The 22-day build only pays back if you ship 2+ products in that window. Fragile sequence.
- **40% procrastination admission.** You called the split 60/40. That's honest, and it's a crack. Forty percent of this project is Tthew-avoiding-something. A specific product opportunity you should be building instead? A harder decision being deferred? The Verdict can't answer this — only you can — but it's an unresolved input to the M4 checkpoint.
- **Correlated-library risk is not yet battle-tested.** TanStack Start + better-auth migration-back unstub guides are the mitigation. The guides don't exist yet, and quarterly CI discipline is a commitment rather than a running practice. If both libraries pivot within six months of Keel 1.0, the migration-back story has to work on first attempt.

### Overall

**Proceed — with three hardening items addressed before M2.**

The concept has survived the gauntlet more cleanly than most. The middle is solid. Three specific next actions before you write a line of substrate code:

1. **RLS policy matrix spike (≤ 1 day).** Sketch the full policy set you'd need for a B2B SaaS with team-based tenancy. If it doesn't converge in a day, downgrade Day-1 RLS to a Tier-2 stub with a clear unstub path.
2. **M4 checkpoint ritual.** Calendar the decision now. A specific date. A specific question: "Do I ship a real product on partial Keel, or push to M5-M9?" Governance beats willpower.
3. **Procrastination honesty.** Spend thirty minutes on what the 40% represents. Name the product opportunity being delayed, or the harder commitment being avoided. You don't have to share it; you do have to see it clearly before M1.

If all three happen, this PRFAQ is the last gate before Keel becomes a PRD.
