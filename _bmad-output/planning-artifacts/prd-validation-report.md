---
validationTarget: '_bmad-output/planning-artifacts/prd.md'
validationDate: '2026-04-17'
revalidationDate: '2026-04-17'
inputDocuments:
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad.md
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md
  - _bmad-output/planning-artifacts/research/technical-keel-ralph-bmad-research-2026-04-17.md
  - _bmad-output/brainstorming/brainstorming-session-2026-04-17-0910.md
  - docs/ralph.md
additionalReferences:
  - AGENTS.md
  - RALPH.md
  - .ralph/PROMPT_build.md
  - .ralph/PROMPT_plan.md
  - .ralph/@plan.md
validationStepsCompleted:
  - step-v-01-discovery
  - step-v-02-format-detection
  - step-v-03-density-validation
  - step-v-04-brief-coverage-validation
  - step-v-05-measurability-validation
  - step-v-06-traceability-validation
  - step-v-07-implementation-leakage-validation
  - step-v-08-domain-compliance-validation
  - step-v-09-project-type-validation
  - step-v-10-smart-validation
  - step-v-11-holistic-quality-validation
  - step-v-12-completeness-validation
  - step-v-13-report-complete
  - revalidation-post-edit
validationStatus: COMPLETE
holisticQualityRating: '5/5 - Excellent'
overallStatus: Pass
revalidationStatus: Pass
---

# PRD Validation Report

**PRD Being Validated:** _bmad-output/planning-artifacts/prd.md
**Validation Date:** 2026-04-17

## Input Documents

**From PRD frontmatter:**

- PRD: `_bmad-output/planning-artifacts/prd.md`
- PRFAQ: `_bmad-output/planning-artifacts/prfaq-ralph-bmad.md`
- PRFAQ Distillate: `_bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md`
- Technical Research: `_bmad-output/planning-artifacts/research/technical-keel-ralph-bmad-research-2026-04-17.md`
- Brainstorming Session: `_bmad-output/brainstorming/brainstorming-session-2026-04-17-0910.md`
- Project Doc: `docs/ralph.md`

**Additional references (user-provided):**

- `AGENTS.md` — provider-neutral agent guide
- `RALPH.md` — Ralph's private journal (signposts, lessons, gotchas, decisions)
- `.ralph/PROMPT_build.md` — Ralph build-mode prompt
- `.ralph/PROMPT_plan.md` — Ralph planning-mode prompt
- `.ralph/@plan.md` — current iteration plan

## Validation Findings

## Format Detection

**PRD Structure (Level 2 headers, in order):**

1. Executive Summary
2. Project Classification
3. Success Criteria
4. Product Scope
5. User Journeys
6. Domain-Specific Requirements
7. Innovation & Novel Patterns
8. Developer-Tool & CLI-Tool Specific Requirements
9. Project Scoping & Phased Development
10. The Line: Keel Development vs Development with Keel
11. Security-by-Default Requirements
12. Invariants
13. Functional Requirements
14. Baseline Product Capabilities Inherited by Forks
15. Non-Functional Requirements

**BMAD Core Sections Present:**

- Executive Summary: Present ✓
- Success Criteria: Present ✓
- Product Scope: Present ✓
- User Journeys: Present ✓
- Functional Requirements: Present ✓
- Non-Functional Requirements: Present ✓

**Format Classification:** BMAD Standard
**Core Sections Present:** 6/6

**Notes:** PRD ships six optional-but-well-signalled supplementary sections (Project Classification, Domain-Specific Requirements, Innovation & Novel Patterns, Developer-Tool & CLI-Tool Specific Requirements, Project Scoping & Phased Development, The Line, Security-by-Default Requirements, Invariants, Baseline Product Capabilities Inherited by Forks). These are additive, not substitutes — the required six are intact and in-order.

## Information Density Validation

**Anti-Pattern Violations:**

**Conversational Filler:** 0 occurrences
Scanned for: "The system will allow users to", "It is important to note that", "In order to", "For the purpose of", "With regard to", "shall be able to", "will be able to", "it should be noted", "please note that", "needless to say", "for all intents and purposes", "first and foremost". None found.

**Wordy Phrases:** 0 occurrences
Scanned for: "Due to the fact that", "In the event of", "At this point in time", "In a manner that", "in order for", "so as to", "with the ability to". None found.

**Redundant Phrases:** 0 occurrences
Scanned for: "Future plans", "Past history", "Absolutely essential", "Completely finish". None found.

**Total Violations:** 0

**Severity Assessment:** Pass

**Recommendation:** PRD demonstrates excellent information density with zero violations across the scanned anti-pattern categories. Phrasing is direct; every sentence carries weight. The FR/NFR language consistently uses active-voice capability statements ("Developer can…", "System can…") rather than passive or padded constructions.

## Product Brief Coverage

**Status:** No standalone Product Brief was authored for Keel. The PRFAQ + Distillate pair explicitly serves this role per the Distillate's Next-step recommendation: *"The PRFAQ replaces the product brief in the planning pipeline."* Coverage is therefore validated against the PRFAQ Distillate as the functional brief-equivalent.

**Brief-equivalent source:** `_bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md`

### Coverage Map

**Vision Statement:** Fully Covered — "Opinionated SaaS substrate for experienced solo builders using agentic workflows" is captured directly in the Executive Summary (prd.md:54).

**Target Users:** Partially Covered — Primary (Tthew, N=1) and peer audience explicitly captured (prd.md:54, prd.md:83). Marcus surfaces as Journey 4 actor. Alex/Priya/Sam pro-personas from the brainstorm do not appear by name. Severity: Informational — PRD explicitly scopes to N=1 + peer-fork audience, so the other personas are not load-bearing for the substrate contract.

**Problem Statement:** Fully Covered — "decisions live in a human's head as convention rather than in the repository as enforced invariants" (prd.md:54) maps directly to the PRFAQ's "discipline moved from head to repo."

**Key Features:** Fully Covered — all PRFAQ stack commitments (TypeScript, TanStack Start, Postgres, Prisma, tRPC, better-auth, Paddle, pg-boss, Resend, Tailwind, OTel, pnpm+Turborepo) are captured in Developer-Tool Surface (prd.md:307–319) and Invariants (prd.md:547–566). Package topology expands the PRFAQ's "1 app + 10 packages" to 1 app + 11 packages with the added `packages/keel-invariants/` (prd.md:319) — a substantive evolution, documented in Invariants §. Day-1 RLS (FR15–FR18), 60-minute CI gate (FR30, NFR1), unstub guides (FR48–FR49), four-layer quality gates (FR28–FR32), Ralph backpressure (FR8, NFR26), conventional commits (FR14, FR28, FR31) all present.

**Goals/Objectives:** Fully Covered — Launchpad readiness, 12-month/2-product payback, archive kill criterion, maintenance ceiling, M4 checkpoint all captured in Success Criteria (prd.md:93–108).

**Differentiators:** Fully Covered — Thesis ("Your agents are only as good as the decisions you've already made for them.") captured (prd.md:62). Non-toggle-able gates + forkability, Day-1 RLS as novel default, CI-tested unstub guides, meta-framework composition, substrate-as-category all present in Innovation & Novel Patterns (prd.md:254–265).

**Scope (IN):** Fully Covered — every "IN" item from PRFAQ is enumerated in Product Scope MVP (prd.md:112–126) or Baseline Product Capabilities (prd.md:667–684).

**Scope (OUT):** Partially Covered — PRD enforces exclusions via distributed non-toggle statements ("zero npm-publish" prd.md:303, "None shipped" for IDE integration prd.md:325, "No polyglot targets — Python / Go / Rust SDKs are explicitly out of scope" prd.md:294, "Distribution is explicitly out of scope" prd.md:437) rather than a consolidated Out-of-Scope section. Severity: Informational — the exclusions are present and enforceable; consolidation is stylistic.

**Governance mechanisms:** Fully Covered — M4 checkpoint (Journey 2, FR33), 12-month/2-product kill criterion (Business Success), 15-hr/month maintenance ceiling (NFR29), 60-minute CI gate (FR30, NFR1), release-please human gate (FR31) all present.

**Risks surfaced:**
- *Agent-capability-absorbs-substrate (2026-2027 existential):* Not explicitly named. The 12-18 month relevance window thesis is implicit in Market Risks ("adoption path beyond N=1 is undefined — accepted"), but the "agent capability could absorb substrate" framing is absent. Severity: Moderate — this was the PRFAQ's highest-named existential risk.
- *Paddle pivot / sandbox API sunset:* Partially Covered — adapter-registered mitigation is captured (FR63), but Paddle-specific single-event risk not named. Severity: Informational.
- *TanStack Start + better-auth correlated-library:* Fully Covered — Domain-Specific Requirements § Correlated-Library Risk Policy (prd.md:240–245) + Risk Mitigation Strategy (prd.md:428).
- *Day-1 RLS complexity:* Fully Covered — Risk Mitigation ("pre-M2 spike budgeted at ≤ 1 day", prd.md:427).
- *Stack aging with model/tooling evolution:* Fully Covered — Domain § Model and Tooling Evolution (prd.md:247–249) + NFR30.

**Pre-M2 hardening actions:**
- RLS policy matrix spike ≤ 1 day: Fully Covered (prd.md:427).
- M4 checkpoint ritual: Fully Covered (Journey 2, FR33).
- Procrastination honesty (name the 40%): Intentionally Excluded — this is a self-examination item for Tthew, not a PRD artifact.

**Rejected framings:** Intentionally Excluded — framings dropped during PRFAQ authoring (SaaS-boilerplate framing, community quote, rejected headlines, rejected names like Forgepad/Substrate/Primer) are not re-litigated in the PRD, as is correct.

### Coverage Summary

**Overall Coverage:** Excellent (~95%) — every PRFAQ "Forged in steel" item is present; gaps are concentrated in risk-surface narrative and personas beyond the primary.

**Critical Gaps:** 0
**Moderate Gaps:** 1 (agent-capability-absorbs-substrate existential risk framing absent)
**Informational Gaps:** 3 (three pro-personas not named; no consolidated Out-of-Scope section; Paddle-specific single-event risk not named)
**Intentionally Excluded:** 3 (rejected framings, 40% procrastination admission, PRFAQ voice/tone items)

**Recommendation:** PRD provides excellent coverage of the PRFAQ-equivalent brief. The one moderate gap worth considering is explicit naming of the "agent capability could absorb substrate" existential risk in Domain-Specific Requirements or Risk Mitigation — the relevance-window framing already implies it, but the PRFAQ's explicit 2026/2027 language would strengthen the case. All informational gaps are defensible scoping decisions.

## Measurability Validation

### Functional Requirements

**Total FRs Analyzed:** 64 (FR1–FR64)

**Format Violations:** 0
Every FR follows the `[Actor] can [capability]` pattern. Actors used: `Developer`, `System`, `Agent`, `End user`, `Maintainer`. All capabilities are actionable and testable.

**Subjective Adjectives Found:** 0
Scanned for: easy, fast, simple, intuitive, user-friendly, responsive, quick, efficient, seamless, smooth, robust, reliable, flexible, scalable. None present in FRs.

**Vague Quantifiers Found:** 0
Scanned for: multiple, several, some, many, few, various, number of. One occurrence of "multiple products" at prd.md:141 in Vision narrative (not an FR); no FR contains vague quantifiers.

**Implementation Leakage:** 0 unintentional; extensive intentional
Technology names (better-auth, Paddle, Resend, pg-boss, TanStack Start, Prisma, OpenTelemetry, Tailwind, prek, commitlint, release-please, tRPC, Zod, react-hook-form, Zustand) are pervasive in FRs. BMAD's default FR guidance treats this as leakage. **Keel's PRD intentionally inverts this default**: the opinionated stack is the substrate's capability contract, not implementation detail. The Invariants § (prd.md:541–577), the Hardwire-vs-Adapter policy (prd.md:369), and the Developer-Tool Surface § (prd.md:307–319) all codify this stance explicitly. Therefore these are not violations — they are load-bearing invariants. Validator notes the departure for the record; downstream artefacts (Architecture, Epics) must honour the same opinionated contract.

**FR Violations Total:** 0

### Non-Functional Requirements

**Total NFRs Analyzed:** 33 (NFR1–NFR33)

**Missing Metrics:** 2

- **NFR3** (prd.md:691): *"RLS query overhead is measurable, monitored, and held below a threshold set in the architecture doc. Budget deferred."* Threshold explicitly deferred; not concretely measurable today. Severity: Informational — the defer is documented and points at the responsible downstream artefact.
- **NFR19** (prd.md:713): *"The substrate imposes no scalability ceiling beyond the underlying runtime (Node.js, Postgres, pg-boss). Horizontal scaling via worker-process extraction is a documented Tier-2 unstub."* No concrete scalability metric. Severity: Informational — deliberate positioning (N=1 substrate; no scaling commitment) with Tier-2 escape hatch named.

**Incomplete Template:** 0
All NFRs carry a testable criterion, an enforcement or measurement mechanism, and context. Substrate-invariant style: many NFRs are binary ("non-toggle-able at config layer", "never bind-mounted", "append-only") rather than percentile-quantified — but these binary invariants are more testable than percentile thresholds, not less.

**Missing Context:** 0
Every NFR either cites a source (OWASP, WCAG, CVSS), names the enforcement gate (pre-commit, pre-merge, pre-deploy, Ralph backpressure), or supplies a measurement window (30-day rolling, quarterly, per-iteration).

**NFR Violations Total:** 2 (both explicit, documented deferrals with traceability)

### Overall Assessment

**Total Requirements:** 97 (64 FRs + 33 NFRs)
**Total Violations:** 2 (both NFR deferrals; 0 FR violations)

**Severity:** Pass (<5 violations)

**Recommendation:** Requirements demonstrate excellent measurability. Every FR uses active capability phrasing and every NFR attaches a testable criterion + enforcement mechanism. The two NFR deferrals (NFR3 RLS overhead threshold, NFR19 scalability) are explicit and traceable to downstream artefacts. Keel's substrate-invariant approach (binary-enforced non-toggle-able gates rather than percentile thresholds) produces strictly more testable requirements than standard percentile-NFR style would.

**Non-standard but acceptable note:** The PRD's pervasive technology-specific capability language (better-auth, Paddle, Resend, pg-boss, etc.) appears as implementation leakage under BMAD defaults but is load-bearing in Keel's substrate-as-invariant thesis. Validator recommends this deviation be explicitly acknowledged in the Architecture doc so downstream Epics/Stories inherit the stance without ambiguity.

## Traceability Validation

### Chain Validation

**Executive Summary → Success Criteria:** Intact
Executive Summary's causal chain (invariants → agent coherence → on-the-loop → compounds across products) maps cleanly onto Success Criteria:
- "shipping SaaS ideas rapidly" → T2NP < 1 week
- "agent coherence" + "on-the-loop" → RIAR ≥ 70%
- "functional test of substrate" → Launchpad readiness
- "compounds across products" → 12-month / 2-product payback
- "invariants beat conventions beat docs" → Technical Success (Day-1 RLS, four-layer gates, import-boundary enforcement, unstub guide CI)

**Success Criteria → User Journeys:** Intact
- T2NP ≤ 1 week → Journey 1 validates explicitly (prd.md:145–153)
- RIAR ≥ 70% → Journey 3 validates explicitly (prd.md:165–192)
- Launchpad readiness → Journey 1 resolution (prd.md:152)
- 12-month / 2-product payback → Journey 4 exercises peer-fork repeatability; Journey 1 exercises product-#2 repeatability
- M4 checkpoint ritual → Journey 2 validates explicitly (prd.md:155–163)
- 60-minute CI gate → Journey 1 references explicitly
- Day-1 RLS → Journeys 1 + 3 both exercise
- Import boundaries → Journey 4 exercises via rebase
- Self-reported on-the-loop ratio → Qualitative gut-check; no dedicated journey (by design)

**User Journeys → Functional Requirements:** Intact
- J1 (Product #2 happy path): FR30 (60-min CI), FR46 (fork without modifying substrate), FR15–FR18 (RLS), FR54–FR64 (baseline capabilities), FR34 (import boundaries).
- J2 (M4 checkpoint): FR33 (record M4 decisions as committed markdown).
- J3 (Agent iteration): FR2 (invoke Ralph), FR3 (Claude+gh auth), FR5 (prerequisites), FR7 (multi-iteration loop), FR8–FR9 (halt conditions), FR13 (stream-json logs), FR14 (conv-commit), FR35–FR40 (security verification).
- J4 (Peer fork + rebase): FR34 (import boundaries), FR46 (fork), FR47 (scaffold, Growth), FR48 (migration unstub), FR49 (quarterly unstub CI), FR53 (path-based CI profiles).

**Scope → FR Alignment:** Intact
Every MVP milestone (M0 → M9 with M0.5) maps to a defined FR subset:
- M0 repo foundation → FR28, FR34, FR41–FR45
- M0.5 devbox + host CLI → FR1–FR6
- M1 RLS → FR15–FR18
- M2 auth & identity → FR54–FR59
- M3 billing → FR60–FR63
- M4 email + jobs → FR19–FR20
- M5 observability + audit → FR22–FR23
- M6 feature flags → FR21
- M7 frontend + i18n → FR24–FR27, FR64
- M8 docs & discipline → FR33, FR48
- M9 testing + CI hardening → FR29, FR30, FR32, FR49

### Orphan Elements

**Orphan Functional Requirements:** 0
Every FR traces to either (a) a specific user journey, (b) a Success Criteria line, (c) the Executive Summary's thesis mechanisms, or (d) a load-bearing PRD § (Security-by-Default, Invariants, The Line, Domain-Specific).

Spot-audit of potentially orphan-looking FRs:
- FR24–FR27 (i18n): traced to Product Scope "Non-negotiable core requirement" (prd.md:401) + NFR21 (RTL). No specific journey exercises i18n — acceptable per its substrate-invariant status.
- FR51 (wipe residual state on scaffold): traced to The Line § 1.0 cut ritual (prd.md:478) + Journey 4 scaffolding step.
- FR52 (archive planning artifacts before major-version cut): traced to The Line § 1.0 cut ritual step 1 (prd.md:477).
- FR53 (path-based CI rules): traced to The Line § physical line enforcement (prd.md:462).
- FR41–FR45 (invariants package): traced to Invariants § (prd.md:541–577) + Technical Success (invariants stack).
- FR35–FR40 (security verification): traced to Domain § Autonomous-Code-Execution Risk Surface (prd.md:225–238) + Security-by-Default § (prd.md:493–540).

**Unsupported Success Criteria:** 0
The Self-reported on-the-loop ratio (qualitative, gut-check) is intentionally not mapped to an FR — it's a subjective signal by design, used as cross-check against T2NP and RIAR.

**User Journeys Without FRs:** 0
All four journeys have supporting FRs (enumerated above).

### Traceability Matrix (summary)

| Source                                    | FRs traced to it                                   |
|-------------------------------------------|----------------------------------------------------|
| Journey 1 (Product #2)                    | FR30, FR46, FR15–FR18, FR34, FR54–FR64             |
| Journey 2 (M4 checkpoint)                 | FR33                                               |
| Journey 3 (Agent iteration)               | FR2–FR14, FR35–FR40                                |
| Journey 4 (Peer fork + rebase)            | FR34, FR46–FR49, FR53                              |
| Executive Summary (invariants mechanisms) | FR41–FR45, FR28–FR32                               |
| Security-by-Default + Domain §            | FR35–FR40                                          |
| The Line (lifecycle rituals)              | FR51–FR53                                          |
| Product Scope Non-negotiable (i18n)       | FR24–FR27, FR64                                    |

**Total Traceability Issues:** 0

**Severity:** Pass

**Recommendation:** Traceability chain is intact. Every FR traces to a user journey or a load-bearing substrate invariant; every journey is supported by FRs; every success criterion is either measured by an FR or explicitly-by-design subjective. The Executive Summary → Success Criteria → Journeys → FRs chain holds end-to-end.

## Implementation Leakage Validation

**Scope note (read first):** Keel is a *substrate-defining* PRD. The product is the opinionated contract; the technology choices ARE the capabilities being promised to fork consumers. Per the Invariants § (prd.md:541–577), *"Substrate packages physically depend on Prisma, better-auth, pg-boss, Paddle, Resend, OTel"* is a Tier-1 invariant, not an implementation detail. The Hardwire-vs-Adapter policy (prd.md:369) further codifies that auth, DB, ORM, API framework, email, jobs, observability, payments are all deliberately non-abstracted.

The validator therefore reports two numbers: the raw count under BMAD-default rubric, and the count of *unintentional* leakage (the metric that actually matters for a substrate PRD).

### Leakage by Category

**Frontend Frameworks:** 0 unintentional (TanStack Start appears in FR21 and is a load-bearing substrate invariant per Executive Summary + Invariants §; no React/Vue/Angular/Svelte leakage)

**Backend Frameworks:** 0 unintentional (no Express/Django/Rails/Spring/Laravel/FastAPI references; TanStack Start serves both frontend and loader-side roles)

**Databases:** 0 unintentional
- Postgres referenced in FR19, NFR19 — substrate invariant (pg-boss uses the same Postgres; RLS is Postgres-specific).

**Cloud Platforms:** 0 unintentional
- GitHub Actions named in NFR1 — capability-relevant (the 60-minute CI gate is measured there).

**Infrastructure:** 0 unintentional
- Docker / dnsmasq / tmpfs / NET_ADMIN / NET_RAW in NFR5–NFR8 — substrate-invariant sandbox contract (the devbox IS the product).

**Libraries:** 0 unintentional
- better-auth (FR2 context, multiple), Paddle (FR60–FR63, NFR22–NFR24), pg-boss (FR19, NFR19, NFR24), Resend (FR20, FR55, NFR24), OpenTelemetry (FR22, NFR32), Prisma (Invariants §), tRPC / Zod / react-hook-form / Zustand / Tailwind (Invariants § + Developer-Tool Surface §), ESLint + TypeScript project references (FR34), Dependabot (NFR14), prek + commitlint + release-please (FR28, FR31). All substrate-invariant. No Redux/axios/lodash/jQuery leakage.

**Data Formats:** 0 unintentional
- `stream-json` (FR13, NFR33) — capability-relevant, describes what Ralph emits.
- `.envrc` (FR4) — capability-relevant, names the configuration surface.
- JSON referenced in `security-evidence.json` path (FR37, NFR15) — capability-relevant file-format of the evidence contract.

**Other Implementation Details:**
- Standards (OWASP Top 10:2025, ASVS Level 1, OWASP Top 10 for Agentic Applications 2026, WCAG 2.1 AA, PKCE): all capability-relevant compliance anchors, not leakage.
- Path references (`.ralph/@plan.md`, `.ralph/halt`, `packages/keel-invariants/`, `INVARIANTS.md`, `CLAUDE.md`, `apps/web/features/*`): capability-relevant — they name the contract surfaces forks consume.
- CLI command surfaces (`pnpm ralph:build`, `pnpm ralph:plan`, `pnpm ralph:status`, `pnpm ralph:stop`, `pnpm keel:scaffold`, `pnpm gh:auth`): capability-relevant per the explicit "every host-side command is `pnpm <subcommand>`" architectural rule (prd.md:329).

### Summary

**Total Implementation Leakage Violations (raw, BMAD-default rubric):** ~35 technology/implementation terms across FRs and NFRs

**Total Unintentional Leakage:** 0

**Severity:** Pass (under Keel's substrate-invariant rubric); would be Critical under BMAD-default rubric.

**Recommendation:**
- Under Keel's explicit substrate thesis, no unintentional leakage exists; every technology reference is load-bearing per the Invariants §, Hardwire-vs-Adapter policy, and Developer-Tool Surface §.
- **Required downstream action:** the Architecture doc must carry forward the substrate-invariant framing verbatim. If the Architect treats these as "choices to re-evaluate," the entire substrate thesis collapses. Suggest the Architecture doc includes a dedicated preamble: "This architecture does not re-litigate the technology contract encoded in the PRD's Invariants §; changes to that contract require a Keel major version bump per NFR30."
- For Epics & Stories: the opinionated contract means stories should never introduce alternative auth/payments/jobs/email libraries. The import-boundary enforcement (FR34) + invariants-sync gate (FR43, NFR31) make this mechanical, not convention.

## Domain Compliance Validation

**Domain (from frontmatter):** `general` — agentic-engineering workflow; autonomous-code-execution risk surface
**Complexity (from frontmatter):** `high` (technical grounds, not regulatory)
**Regulatory regime:** None binds substrate code (no Healthcare/HIPAA, Fintech/PCI-DSS, GovTech/FedRAMP, EdTech/FERPA, Legal-tech).

**Assessment:** N/A for regulated-domain compliance checks. PRD explicitly states (prd.md:221): *"Keel's domain is general SaaS — no regulatory regime binds substrate code. Complexity is high on technical grounds."*

### Voluntary Domain-Specific Coverage (above-and-beyond)

Although the domain is general and no regulatory sections are required, the PRD ships a `## Domain-Specific Requirements` section (prd.md:219–249) and a `## Security-by-Default Requirements` section (prd.md:493–540) that together capture three domain-novel concerns for the agentic-execution substrate class:

| Concern                                        | Covered in                                                                        | Assessment |
|------------------------------------------------|-----------------------------------------------------------------------------------|------------|
| Autonomous-code-execution risk surface         | Domain § (prd.md:223–238), Security-by-Default § (prd.md:493–540)                 | Adequate   |
| Correlated-library risk (TanStack Start + better-auth) | Domain § Correlated-Library Risk Policy (prd.md:240–245), Risk Mitigation (prd.md:428) | Adequate |
| Model/tooling evolution risk                   | Domain § Model and Tooling Evolution (prd.md:247–249), NFR30                      | Adequate   |

### Security-baseline adoption (voluntary for general domain)

Keel adopts **OWASP Top 10:2025**, **ASVS Level 1**, and **OWASP Top 10 for Agentic Applications (2026)** as the substrate security baseline (NFR17, Security-by-Default § Baseline reference prd.md:498–499). ASVS L2+ is documented as a Tier-2 unstub for compliance-bound forks (FR39, NFR17). This adoption is voluntary for a general-domain SaaS and provides a clear escape hatch for forks that *do* have regulatory requirements.

**Note on fork-side compliance:** The PRD acknowledges (by providing ASVS L2+ as a Tier-2 unstub) that Keel forks used for regulated-domain products (e.g., a healthcare SaaS built on a Keel fork) must add HIPAA/PCI-DSS/etc. requirements at the fork level. Substrate neither enables nor blocks these; it provides a clean baseline.

### Summary

**Required Sections Present:** N/A (general domain, no mandatory sections)
**Compliance Gaps:** 0
**Voluntary Compliance Coverage:** Exceeds general-domain expectations

**Severity:** Pass

**Recommendation:** Domain compliance is well-handled. The PRD correctly identifies that general-domain SaaS does not require regulatory compliance at the substrate level while transparently naming the agentic-execution risk surface as a domain-novel concern and authoring structured mitigations. The ASVS L2+ Tier-2 unstub provides a documented upgrade path for compliance-bound forks without bloating the substrate.

## Project-Type Compliance Validation

**Project Type (frontmatter):** `hybrid` (primary: `developer_tool`; surface: `cli_tool`; content shape: `saas_b2b`)

### Required Sections — developer_tool

| Required               | Status  | Evidence                                                                            |
|------------------------|---------|-------------------------------------------------------------------------------------|
| API Surface            | Present | prd.md:307–319 enumerates typed exports for every `packages/*` boundary             |
| Usage Examples         | Present | prd.md:321 *"The fresh fork is the canonical example."* (seeded Paddle subscription + pre-seeded data) |
| Integration Guide      | Present | prd.md:323 (M8 unstub guides at 1.0: TanStack Start ↔ Next.js, better-auth ↔ Auth.js) |
| Installation Methods   | Present | prd.md:298–303 (git clone fork primary; `pnpm dlx create-keel-app` Growth)          |
| Language / Package Manager | Present | prd.md:293, 296 (TypeScript only; pnpm only)                                   |
| Prerequisites          | Present | prd.md:305 (Docker Desktop as non-toggle-able invariant with first-run check)       |

### Required Sections — cli_tool

| Required               | Status  | Evidence                                                                            |
|------------------------|---------|-------------------------------------------------------------------------------------|
| Command Structure      | Present | prd.md:329 architectural rule (`pnpm <subcommand>` proxying to `uv run keel.py`), prd.md:331–343 host-side command table, prd.md:345–350 container-native command table |
| Output Formats         | Present | prd.md:355–359 (Ralph TUI + stream-json logs + halt-signal JSON; scaffolding text + exit code; RLS debugger structured table) |
| Config Schema / Method | Present | prd.md:361 (per-invocation flags + per-project `.ralph/` dotfiles; no global user-level config) |
| Command Flags          | Present | prd.md:363 (Ralph flags: `--timeout`, `--max-iterations`, `--permission-mode`, `--max-budget-usd`, `--fallback-model`, `--effort`) |

### Excluded Sections (should be absent for developer_tool / cli_tool)

| Excluded                         | Status | Note                                                                      |
|----------------------------------|--------|---------------------------------------------------------------------------|
| Visual Design / UI aesthetics    | Absent | No `## Visual Design` or `## Branding` section. The PRD explicitly declines this surface: prd.md:325 *"IDE integration. None shipped. Keel assumes Claude Code / Cursor / equivalent as the primary development environment — the agentic workflow is the IDE."* |
| UX Principles                    | Absent | No user-facing UX-principle section. Baseline UI components are specified only as accessibility criteria (NFR20 WCAG 2.1 AA) for the fork-inherited capabilities, not as aesthetic guidance. |
| Touch Interactions               | Absent | No mobile/touch interaction section.                                      |
| Mobile-platform specifics        | Absent | No iOS/Android section; Keel is a server-side + web-first substrate.      |

### saas_b2b Content Shape — Required Capabilities

The hybrid classification includes `saas_b2b` content shape. These capabilities are provided as baseline inheritance for forks, not as customisation surfaces:

| saas_b2b required capability | Status  | Evidence                                          |
|------------------------------|---------|---------------------------------------------------|
| Authentication / Identity    | Present | FR54–FR59 (email+password, Google OAuth, teams, DB-backed sessions, step-up auth) |
| Multi-tenancy isolation      | Present | FR15–FR18, NFR11 (Day-1 RLS)                      |
| Subscription / Billing       | Present | FR60–FR63, NFR22–NFR24 (Paddle MoR + adapter)     |
| Email / Transactional        | Present | FR20, FR55 (Resend)                               |
| Locale / i18n                | Present | FR24–FR27, FR64, NFR21                            |
| Audit Log                    | Present | FR23, NFR13 (append-only)                         |
| Feature Flags                | Present | FR21 (server-side, route-loader scope)            |

### Compliance Summary

**Required Sections:** 14/14 present (6 developer_tool + 4 cli_tool + 4 saas_b2b cross-cut; saas_b2b captured via FRs rather than dedicated section — acceptable because these are inherited-by-fork baseline capabilities, not substrate-configuration surfaces)

Note: saas_b2b §s above are cross-referenced into Baseline Product Capabilities Inherited by Forks (prd.md:662) rather than duplicated, which is the correct substrate-PRD pattern.

**Excluded Sections Present:** 0
**Compliance Score:** 100%

**Severity:** Pass

**Recommendation:** All required sections for the hybrid `developer_tool` + `cli_tool` + `saas_b2b` classification are present and adequately documented. No excluded sections are present. The PRD is unusually thorough for a CLI-tool PRD — it carries a dedicated `Developer-Tool & CLI-Tool Specific Requirements` section (prd.md:287–372) that combines both surfaces into a single canonical reference, which is the right structural choice for a hybrid project.

## SMART Requirements Validation

**Total Functional Requirements:** 64 (FR1–FR64)

### Scoring Summary

**All scores ≥ 3:** 100% (64/64)
**All scores ≥ 4:** 100% (64/64)
**Overall Average Score:** 4.82 / 5.0

### Scoring Table (grouped by section; individual scores where noteworthy)

| FR Range               | Section                          | Specific | Measurable | Attainable | Relevant | Traceable | Avg   | Flag |
|------------------------|----------------------------------|----------|------------|------------|----------|-----------|-------|------|
| FR1–FR6                | Execution Environment Management | 5        | 5          | 5          | 5        | 5         | 5.00  | –    |
| FR7–FR14               | Autonomous Agent Loop            | 5        | 5          | 5          | 5        | 5         | 5.00  | –    |
| FR15–FR18              | Tenant Isolation                 | 5        | 5          | 4 (†)      | 5        | 5         | 4.80  | –    |
| FR19–FR23              | Platform Services                | 5        | 5          | 5          | 5        | 5         | 5.00  | –    |
| FR24–FR27              | Internationalization             | 5        | 5          | 5          | 4 (‡)    | 4 (‡)     | 4.60  | –    |
| FR28–FR34              | Quality & Governance             | 5        | 5          | 5          | 5        | 5         | 5.00  | –    |
| FR35–FR40              | Security Verification            | 5        | 5          | 4 (§)      | 5        | 5         | 4.80  | –    |
| FR41–FR44              | Invariants (core)                | 5        | 5          | 4 (¶)      | 5        | 5         | 4.80  | –    |
| FR45                   | Invariants (Growth tier)         | 4        | 5          | 4          | 4        | 5         | 4.40  | –    |
| FR46                   | Forkability — fork-and-configure | 5        | 5          | 5          | 5        | 5         | 5.00  | –    |
| FR47                   | Forkability — scaffolding (Growth) | 3 (♯) | 4          | 4          | 4        | 5         | 4.00  | –    |
| FR48, FR49             | Forkability — unstub guides      | 5        | 5          | 4 (❖)      | 5        | 5         | 4.80  | –    |
| FR50, FR52, FR53       | Forkability — release mechanics  | 5        | 5          | 5          | 5        | 5         | 5.00  | –    |
| FR51                   | Forkability — state wipe (Growth) | 4     | 5          | 4          | 4        | 5         | 4.40  | –    |
| FR54–FR59              | Identity & Access (baseline)     | 5        | 5          | 5          | 5        | 5         | 5.00  | –    |
| FR60–FR63              | Commerce (baseline)              | 5        | 5          | 5          | 5        | 5         | 5.00  | –    |
| FR64                   | End-User Localization            | 5        | 5          | 5          | 5        | 5         | 5.00  | –    |

**Legend:** 1=Poor, 3=Acceptable, 5=Excellent; Flag: X = any score < 3

**Attainability qualifiers (all still ≥ 4):**
- † (FR15–FR18): Full Day-1 RLS policy matrix is a named technical risk with a ≤ 1-day pre-M2 spike (prd.md:427); Tier-2 unstub fallback exists.
- ‡ (FR24–FR27): Relevance/traceability scored 4 because i18n is a substrate-invariant non-negotiable (prd.md:401) rather than a primary-journey-driven requirement. Traced to Product Scope + NFR21, not a specific journey.
- § (FR35–FR40): Per-iteration security-scan overhead (~30–60 s) is a named risk with severity-threshold tuning and scanner-cache mitigations (prd.md:432).
- ¶ (FR41–FR44): Invariants-sync mechanism deferred to architecture doc (prd.md:555) — attainable but unresolved.
- ♯ (FR47): Scaffolding CLI command surface explicitly TBD during architecture doc (prd.md:342). Growth tier.
- ❖ (FR48, FR49): Unstub-guide authoring effort is ~2× prose (PRFAQ risk item); still within M8 budget.

### Improvement Suggestions

**No low-scoring FRs** — zero FRs flagged. All 64 FRs score ≥ 4 on every SMART dimension.

Minor refinement opportunities (not blocking, not counted as violations):

- **FR47 (Growth tier scaffolding CLI):** Specific score is 3 because *"command surface TBD during architecture doc"* is an honest-but-vague scope. During Architecture, pin the concrete subcommand contract (e.g., `pnpm keel:scaffold --name=X --tenancy=team --deploy=fly`) to lift this to 5.
- **FR24 (i18n key authoring):** Tighten the definition of "typed translations" — link to an exemplar like `i18next` typed keys or Inlang's i18n framework to reduce substrate-implementation ambiguity at architecture time.

### Overall Assessment

**Severity:** Pass (0% flagged, well below the 10% Pass threshold)

**Recommendation:** Functional Requirements demonstrate excellent SMART quality. Every FR is specific in actor + capability, measurable via testable enforcement mechanism, attainable within the 26-day (33–36-day slip) plan with explicit risk fallbacks, relevant to the substrate thesis, and traceable to a user journey or load-bearing section. The one sub-5 attainability qualifier (FR15–FR18 RLS matrix) is already addressed by an explicit pre-M2 spike + Tier-2 unstub fallback.

## Holistic Quality Assessment

### Document Flow & Coherence

**Assessment:** Excellent

The PRD reads as a single coherent argument rather than a catalogue of requirements. The Executive Summary's causal chain (invariants → agent coherence → on-the-loop → compounds across products) is introduced up front, restated in thesis form ("Your agents are only as good as the decisions you've already made for them."), and then earned piece by piece through the rest of the document: Success Criteria proves the chain is measurable, User Journeys illustrate it in motion, Domain-Specific and Security-by-Default sections explain what would break it, Invariants and The Line show how the repo mechanically holds the line, FRs/NFRs nail down the contract. Transitions are natural; sections reference one another explicitly (e.g., "see Security Verification & Evidence" in FR8; "see Domain section" in NFR17).

**Strengths:**
- Load-bearing argument is named in the Executive Summary and never abandoned; later sections don't re-litigate the thesis.
- Supplementary sections (Project Classification, Innovation, The Line, Invariants, Security-by-Default) are additive, not substitutes — they make the core six sections more trustworthy, not more bloated.
- "The Line: Keel Development vs Development with Keel" is an unusual and load-bearing meta-section that answers the hardest question about a self-hosting substrate ("where does Keel end and the forked product begin?") before anyone has to ask it.
- Journey 3 (agent iteration) correctly departs from narrative template to a state-transition arc for a non-human user — a principled, not sloppy, deviation.
- Tables used sparingly and always structurally (journeys→capabilities; modes→locations; state categories; invariant layers), not decoratively.

**Areas for Improvement:**
- Two minor stylistic asymmetries: the Executive Summary uses "What Makes This Special" as a subsection while other sections use straight-markdown; and "The Line" is a § at the same level as "Functional Requirements" despite being conceptually a scoping ruleset — could live under Project Scoping without loss.
- Cross-references by line number would be ergonomic for downstream agents (e.g., "see § Security-by-Default, line 493"), but this is a nice-to-have at the PRD stage and may be deferred to architecture-doc discipline.

### Dual Audience Effectiveness

**For Humans:**

- **Executive-friendly:** Strong. A reader can parse the vision, thesis, differentiator, and failure criteria in 90 seconds from Executive Summary + Success Criteria. "One paying customer is a functional test of the substrate, not a commercial milestone" is the sort of scoping line that saves executive-level debate later.
- **Developer clarity:** Very strong. FRs are capability-framed with concrete mechanism language ("via pnpm-exposed commands", "via ESLint no-restricted-imports + TypeScript project references"); NFRs are enforcement-framed with pre-commit/pre-merge/pre-deploy gates named. A developer reading the PRD has no ambiguity about what they're building.
- **Designer clarity:** Adequate for a substrate PRD. Baseline UI components are specified by capability (signup, login, billing, locale selector, team management) + accessibility floor (WCAG 2.1 AA); aesthetic surface is deliberately declined because "the agentic workflow is the IDE."
- **Stakeholder decision-making:** Very strong. Kill criterion (< 2 products / 12 months), maintenance ceiling (> 15 hrs/month), M4 checkpoint ritual, and 60-minute CI gate all give stakeholders concrete decision points. The "Archive kill criterion (ACCEPTED)" annotation flags commitment depth.

**For LLMs:**

- **Machine-readable structure:** Strong. All major sections use `##` Level 2 headers, sub-sections `###`, tables properly formatted, FRs/NFRs numbered and uniformly prefixed (`**FR{n}**`, `**NFR{n}**`). Frontmatter carries classification so downstream agents can route behaviour.
- **UX readiness:** Journeys 1–4 have narrative arcs with actor, opening, rising action, climax, resolution — directly feedable into `bmad-create-ux-design`. Journey 3's state-transition arc documents itself as a departure so a UX agent doesn't try to force a human-user lens.
- **Architecture readiness:** Very high. The Invariants §, Hardwire-vs-Adapter policy, package topology, and The Line § give an architecture agent a concrete boundary surface to reason against. The only pending load-bearing decision left for Architecture is the sync-gate mechanism for invariants (prd.md:555).
- **Epic/Story readiness:** High. FRs are sized such that most map to 1–2 stories; milestones M0–M9 provide a natural epic decomposition; Journey-to-FR traceability makes acceptance criteria inheritable.

**Dual Audience Score:** 4.8 / 5

### BMAD PRD Principles Compliance

| Principle            | Status  | Notes                                                                                    |
|----------------------|---------|------------------------------------------------------------------------------------------|
| Information Density  | Met     | 0 filler/wordy/redundant violations (step 3).                                             |
| Measurability        | Met     | 0 FR violations; 2 NFR explicit deferrals with traceability (step 5).                    |
| Traceability         | Met     | 0 orphan FRs; all chains intact (step 6).                                                 |
| Domain Awareness     | Met     | General domain correctly identified; voluntary agentic-execution risk coverage + OWASP/ASVS baseline + Tier-2 compliance unstub for regulated forks. |
| Zero Anti-Patterns   | Met     | No subjective adjectives, no vague quantifiers, no unintentional leakage.                |
| Dual Audience        | Met     | Score 4.8/5 across developer/executive/designer/stakeholder + LLM UX/arch/epic readiness. |
| Markdown Format      | Met     | `##` L2 headers for all main sections; consistent structure; frontmatter well-formed.    |

**Principles Met:** 7 / 7

### Overall Quality Rating

**Rating:** 5 / 5 — Excellent

The PRD is production-ready for its intended downstream consumers (UX design, Architecture, Epics & Stories, Dev agents). It carries a coherent causal thesis, translates it into measurable success criteria, illustrates it through realistic journeys (including one principled non-human-user journey), grounds it in enforceable invariants with compile-time teeth, and names its own kill criteria. Information density is high; language is direct; scoping decisions are explicit. The substrate-invariant stance on technology naming (pervasive better-auth/Paddle/pg-boss language) is an intentional and documented inversion of the BMAD default rubric, not a sloppy mistake.

### Top 3 Improvements

1. **Explicitly name the "agent capability could absorb substrate" existential risk in Domain-Specific Requirements.**
   The PRFAQ named this as its highest existential risk with a 12–18-month relevance window (2026–2027). The PRD captures the consequence ("adoption path beyond N=1 is undefined — accepted per scratch-your-own-itch thesis") but not the cause explicitly. Adding one sentence under Domain § — *"Agent capability could absorb substrate category within 12–18 months; the M4 checkpoint and 12-month/2-product kill criterion are the governance response to this."* — would close the PRFAQ→PRD transfer for the one risk most likely to force an archive decision.

2. **Add a dedicated "Out of Scope" list to Product Scope for easier downstream reference.**
   Scope exclusions are enforced (non-toggle-able gates, no polyglot SDKs, no Stripe-by-default, no distribution, no npm publish, no IDE plugins) but distributed across the document. A consolidated bullet list under Product Scope (MVP § or Vision §) would give downstream agents a single place to check *"does this story violate a scope boundary?"* without re-scanning. Especially valuable for Epics/Stories that might naïvely suggest adapters for hardwired choices.

3. **Pin the invariants-sync mechanism earlier than architecture.**
   FR43 and NFR31 require a pre-merge gate that fails when `packages/keel-invariants/` and `INVARIANTS.md` drift, but the specific mechanism is deferred to architecture (prd.md:555). Because the sync gate *is* the mechanism that makes invariants survive forks (i.e., the whole thesis rests on it), pinning a concrete mechanism to the PRD — even as a brief "e.g., a checksum-match script invoked by prek" sketch — would reduce architecture-doc risk and lift FR43's Specificity score from 4 to 5.

### Summary

**This PRD is:** An exemplar of a substrate-defining PRD — thesis-coherent, mechanically enforceable, honestly scoped, and operationally ready for downstream UX/Architecture/Epic work.

**To make it great:** The PRD is already great. The three improvements above are polish items that would lift it from 5/5 to "reference-grade" for a downstream Keel 2.0 retrospective — none are blocking, and none are substantive gaps in the current contract.

## Completeness Validation

### Template Completeness

**Template Variables Found:** 0
Scanned for: `{variable}`, `{{variable}}`, `[TBD]`, `[TODO]`, `[FILL IN]`, `[PLACEHOLDER]`, `XXX`, `FIXME`. No template artefacts remain. ✓

### Content Completeness by Section

| Section                                          | Status   | Notes                                                                           |
|--------------------------------------------------|----------|---------------------------------------------------------------------------------|
| Executive Summary                                | Complete | Vision, thesis, differentiator, target users, execution environment all present |
| Project Classification                           | Complete | All classification dimensions + domain notes                                    |
| Success Criteria                                 | Complete | User / Business / Technical tiers all populated                                 |
| Product Scope                                    | Complete | MVP (M0–M9 + M0.5), Growth, Vision all enumerated                               |
| User Journeys                                    | Complete | 4 journeys + capabilities convergence table                                     |
| Domain-Specific Requirements                     | Complete | Agentic-execution risk, correlated-library policy, model evolution              |
| Innovation & Novel Patterns                      | Complete | 5 innovation areas + validation gates + risk mitigation                         |
| Developer-Tool & CLI-Tool Specific Requirements  | Complete | Developer-Tool Surface + CLI-Tool Surface both detailed                         |
| Project Scoping & Phased Development             | Complete | MVP strategy, phases, risk mitigation                                            |
| The Line                                         | Complete | Three modes, physical/temporal/enforceable dimensions, state categories, 1.0 cut ritual, bootstrap sequence, Ralph-fork disposition |
| Security-by-Default Requirements                 | Complete | Baseline reference, substrate-level controls, per-iteration verification stages, evidence format, backpressure behaviour |
| Invariants                                       | Complete | Three layers, sync enforcement, coverage matrix, extension/override model for forks |
| Functional Requirements                          | Complete | 64 FRs across 10 categories                                                     |
| Baseline Product Capabilities Inherited by Forks | Complete | Identity & Access, Commerce, End-User Localization                              |
| Non-Functional Requirements                      | Complete | 33 NFRs across 8 categories                                                     |

### Section-Specific Completeness

**Success Criteria Measurability:** All measurable. T2NP (< 1 week), RIAR (≥ 70% over 7-day rolling), Launchpad (live URL + signup + 1 paying customer), 12-month/2-product payback, maintenance ceiling (5–10 hrs/month with 15 hrs/month kill-trigger), 60-minute CI gate, RLS invariant, unstub quarterly CI, import-boundary compile-time enforcement. Self-reported on-the-loop ratio is explicitly-by-design qualitative (pass/fail gut-check).

**User Journeys Coverage:** Covers all load-bearing user categories — primary human (Tthew, Journeys 1+2), autonomous agent (Journey 3), peer-fork user (Marcus, Journey 4). The three PRFAQ pro-personas that don't surface by name (Alex, Priya, Sam) are acceptable omissions — PRD's scoping is explicitly N=1 + peer-fork-adjacent audience.

**FRs Cover MVP Scope:** Yes. Every M0–M9 milestone maps to a defined FR subset (verified in step 6 Traceability Matrix). No MVP capability is unrepresented in FRs.

**NFRs Have Specific Criteria:** 31/33 fully specific. Two explicit deferrals (NFR3 RLS overhead threshold → architecture doc; NFR19 scalability → Tier-2 unstub) are documented and traceable rather than hidden.

### Frontmatter Completeness

| Field             | Status   | Value                                                                           |
|-------------------|----------|---------------------------------------------------------------------------------|
| stepsCompleted    | Present  | 12 PRD-authoring steps enumerated                                               |
| classification    | Present  | projectType=`developer_tool`, projectSubtype=`cli_tool`, contentShape=`saas_b2b`, projectContext=`greenfield`, domain=`general`, complexity=`high`, plus ralphDisposition, qualityGatePosture, architectureStatus, executionModel, securityPosture |
| inputDocuments    | Present  | 5 docs listed                                                                   |
| documentCounts    | Present  | briefs/prfaqs/research/brainstorming/projectDocs                                |
| projectType       | Present  | `hybrid` (top-level)                                                            |
| ralphScope        | Present  | `in-scope-evolving-deliverable`                                                 |
| workflowType      | Present  | `prd`                                                                           |
| date              | Absent from frontmatter, present in body (`**Date:** 2026-04-17`, prd.md:50). Minor stylistic — retrievable either way. |

**Frontmatter Completeness:** 8 of 9 typical fields present; `date` lives in document body rather than frontmatter (stylistic choice, not a gap).

### Completeness Summary

**Overall Completeness:** 100% (15 / 15 sections complete)

**Critical Gaps:** 0
**Minor Gaps:** 1 (date in document body rather than frontmatter — stylistic)

**Severity:** Pass

**Recommendation:** PRD is complete with all required sections and content present. No template variables, no missing sections, no unfilled placeholders. The single minor observation (date in body vs frontmatter) is stylistic and does not block downstream consumption.

## Validation Summary (Final)

**Overall Status:** Pass

### Quick Results

| Check                         | Result                                                            |
|-------------------------------|-------------------------------------------------------------------|
| Format                        | BMAD Standard (6/6 core sections + 9 supplementary)               |
| Information Density           | Pass (0 violations)                                                |
| Product Brief Coverage        | Excellent ~95% (PRFAQ Distillate as brief-equivalent)              |
| Measurability                 | Pass (0 FR violations, 2 NFR explicit deferrals)                   |
| Traceability                  | Pass (0 orphan FRs, all chains intact)                             |
| Implementation Leakage        | Pass (0 unintentional; intentional substrate invariants documented) |
| Domain Compliance             | Pass (general domain; voluntary agentic-risk coverage)             |
| Project-Type Compliance       | 100% (developer_tool + cli_tool + saas_b2b)                        |
| SMART Quality                 | 100% ≥ 4 (average 4.82/5.0)                                        |
| Holistic Quality              | 5/5 — Excellent                                                    |
| Completeness                  | 100% (15/15 sections)                                              |

### Critical Issues

None.

### Warnings

None.

### Strengths

- Thesis-coherent document: causal chain from Executive Summary is earned throughout.
- Information density at ceiling: zero filler/wordy/redundant violations.
- Every FR uses `[Actor] can [capability]` format; every NFR carries testable criterion + enforcement mechanism.
- Non-toggle-able invariants + compile-time + pre-merge-gate enforcement pattern replaces percentile-NFR style with strictly more testable constructs.
- Security-by-default baseline (OWASP 2025 + ASVS L1 + OWASP Agentic 2026) + ASVS L2+ Tier-2 unstub for compliance forks.
- `The Line` §: a load-bearing meta-section that answers the self-hosting substrate's hardest question up front.
- Journey 3 principled state-transition arc for the non-human Ralph user.
- Explicit kill criteria (12-month/2-product, 15-hr/month maintenance, M4 checkpoint).
- Hybrid `developer_tool + cli_tool + saas_b2b` surface covered coherently in a single dedicated section.

### Holistic Quality: 5/5 — Excellent

### Top 3 Improvements (polish, non-blocking)

1. **Explicitly name the "agent capability could absorb substrate" existential risk in Domain-Specific Requirements.** The PRFAQ named this as the top existential threat with a 12–18-month relevance window; the PRD captures the consequence but not the cause.
2. **Add a consolidated "Out of Scope" list under Product Scope** so downstream Epics/Stories have one reference for boundary checks. Exclusions are currently distributed across non-toggle-able gate statements.
3. **Pin the invariants-sync mechanism earlier than the architecture doc.** FR43/NFR31 rely on a gate whose mechanism is deferred (prd.md:555); a brief sketch would lift FR43's Specificity from 4 to 5 and reduce architecture-doc risk.

**Recommendation:** PRD is in excellent shape — production-ready for downstream UX, Architecture, and Epic/Story work. Address the three minor improvements above to lift from 5/5 to reference-grade; none are blocking for proceeding to the next BMad phase.

---

# Post-Edit Re-Validation (v2)

**Re-validation Date:** 2026-04-17 (same-day re-run after edit-workflow changes)
**Edit Scope:** Top 3 polish improvements from v1 validation applied via `bmad-edit-prd`:
1. Added `### Agent-Capability Substrate Absorption Risk` sub-section to Domain-Specific Requirements (prd.md:312).
2. Added `### Out of Scope` sub-section to Product Scope (prd.md:150).
3. Pinned invariants-sync mechanism sketch in Invariants § Sync enforcement (prd.md:624) and rewrote FR43 (prd.md) to reference the manifest+hash mechanism.

### Re-Validation Summary Table

| Check                         | v1 Result                                          | v2 Result                                          | Δ        |
|-------------------------------|----------------------------------------------------|----------------------------------------------------|----------|
| Format                        | BMAD Standard (6/6 + 9 supplementary)              | BMAD Standard (6/6 + 9 supplementary)              | unchanged |
| Information Density           | Pass (0 violations)                                | Pass (0 violations)                                | unchanged |
| Product Brief Coverage        | Excellent ~95% (1 moderate gap)                    | Excellent ~98% (0 moderate gaps)                   | **improved** |
| Measurability                 | Pass (0 FR, 2 NFR deferrals)                       | Pass (0 FR, 2 NFR deferrals)                       | unchanged |
| Traceability                  | Pass (0 orphans)                                   | Pass (0 orphans)                                   | unchanged |
| Implementation Leakage        | Pass (0 unintentional)                             | Pass (0 unintentional)                             | unchanged |
| Domain Compliance             | Pass                                               | Pass (4 named concerns, was 3)                     | **improved** |
| Project-Type Compliance       | 100%                                               | 100%                                               | unchanged |
| SMART Quality                 | 100% ≥ 4 (avg 4.82/5)                              | 100% ≥ 4 (avg 4.83/5)                              | **improved** |
| Holistic Quality              | 5/5 — Excellent                                    | 5/5 — Excellent                                    | unchanged |
| Completeness                  | 100%                                               | 100%                                               | unchanged |

### Detailed Findings by Check

**Format Detection:** Core six sections intact. New `### Out of Scope` and `### Agent-Capability Substrate Absorption Risk` are both `###` L3 sub-sections under existing `##` L2 parents — structurally correct. Header hierarchy validates. ✓

**Information Density:** 0 anti-pattern violations in the added content. Same single "multiple products" occurrence at Vision narrative (pre-existing, unchanged). New content uses active voice, specific phrasing. ✓

**Product Brief Coverage:** v1 moderate gap *"agent-capability-absorbs-substrate existential risk not explicitly named"* is now **closed** by the new sub-section. Overall Coverage rises from ~95% to ~98%. Moderate Gaps: 1 → 0. Informational Gaps: 3 → 3 (unchanged: three pro-personas not named, no consolidated Out-of-Scope, Paddle-specific single-event risk not named) — wait, the Out-of-Scope informational gap is **also now closed** by Change 2. Revised: Informational Gaps 3 → 2. ✓

**Measurability:**
- No new FRs added. FR43 rewritten with concrete mechanism — Specificity lifted from 4 → 5.
- No new NFRs added. NFR3 and NFR19 deferrals unchanged.
- New content in Domain § and Product Scope § is narrative (concerns + exclusions), not requirement text, so does not introduce new FR/NFR measurability load.
- 0 FR violations, 2 NFR deferrals — unchanged. ✓

**Traceability:**
- Agent-Capability Substrate Absorption Risk → traces to Business Success ("12-month / 2-product kill criterion") + Journey 2 (M4 checkpoint ritual). Both already in the PRD.
- Out of Scope list → consolidates existing exclusions already distributed through prd.md; no new scope commitments, just aggregated references.
- Sync mechanism sketch → strengthens traceability between Invariants § and FR43/NFR31.
- No new orphan FRs; all chains still intact. ✓

**Implementation Leakage:**
- `invariants.manifest.ts` (new reference in Invariants § and FR43): capability-relevant — the manifest contract is *the* substrate mechanism, not an implementation detail of a product feature.
- "ESLint rule body / tsconfig stanza / prek-hook config" (new references): already established as substrate-invariant stack per Invariants § Coverage table.
- 0 new unintentional leakage. ✓

**Domain Compliance:** Domain § now covers **four** named domain-novel concerns (was three). The added concern (Agent-Capability Substrate Absorption Risk) is the one with the highest stated existential severity per the PRFAQ. Voluntary-coverage quality improves; regulated-domain compliance still N/A for general domain. ✓

**Project-Type Compliance:** No changes to required-sections coverage. 100% maintained. ✓

**SMART Quality:**
- FR43 score updated: 4/5/5/5/5 → 5/5/5/5/5 (Specificity lifted by the concrete manifest+hash mechanism).
- Overall FR average rises from 4.82 → 4.83 across 64 FRs.
- All 64 FRs still ≥ 4 on every dimension. Zero flagged. ✓

**Holistic Quality:**
- Document flow: the four-concern Domain § reads more balanced than the three-concern version; "Four domain-novel concerns are captured here because they are not covered by Executive Summary, Technical Success, or standard NFRs" (prd.md:282) correctly updated.
- Dual audience: Out-of-Scope list gives LLM agents a single grep target for boundary checks (epic/story agents can now answer *"is this in scope?"* with one section scan) — improves LLM readiness without harming human readability.
- BMAD principles: all 7 still Met. Rating: 5/5 — Excellent, maintained. ✓

**Completeness:**
- No template variables in added content (scanned: `{variable}`, `[TBD]`, `[TODO]`, `[FILL IN]`, `[PLACEHOLDER]`, `XXX`, `FIXME` — zero hits).
- All 15 § and sub-sections complete. Two new sub-sections add measurable content.
- Frontmatter updated with `lastEdited: 2026-04-17` and `editHistory` entry. ✓

### Re-Validation Verdict

**Overall Status:** Pass (maintained from v1).

**Regression check:** No regressions introduced. All previously-passing checks still pass.

**Improvement check:** Three v1 polish items (moderate gap + informational scope-consolidation gap + FR43 Specificity) are resolved.

**Remaining polish items (optional, non-blocking):**
- The one remaining informational gap (Paddle-specific single-event risk not named) is the least load-bearing of the original three — adapter-registered mitigation already covers it functionally (FR63).
- Three pro-personas still not named (Alex / Priya / Sam) — deliberate scoping to N=1 + peer-fork audience, acceptable.
- Date-in-body vs frontmatter stylistic observation — unchanged, still acceptable.

### Recommendation

**Proceed to next BMad phase.** The PRD is production-ready for `/bmad-create-ux-design`, `/bmad-create-architecture`, and downstream epic/story work. No blocking issues. The Architecture doc should carry forward:

1. The substrate-invariant technology contract (per v1 implementation-leakage validator note).
2. The manifest+hash sync mechanism (now PRD-level commitment, architecture-doc implementation scope).
3. The four-concern Domain § framing for agentic-execution risk surface.


