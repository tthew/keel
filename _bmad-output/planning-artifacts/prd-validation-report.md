---
validationTarget: '_bmad-output/planning-artifacts/prd.md'
validationDate: '2026-04-18'
inputDocuments:
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad.md
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md
  - _bmad-output/planning-artifacts/research/technical-keel-ralph-bmad-research-2026-04-17.md
  - _bmad-output/brainstorming/brainstorming-session-2026-04-17-0910.md
  - docs/ralph.md
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
validationStatus: COMPLETE
holisticQualityRating: '5/5 - Excellent'
overallStatus: PASS
---

# PRD Validation Report

**PRD Being Validated:** `_bmad-output/planning-artifacts/prd.md`
**Validation Date:** 2026-04-18

## Input Documents

- PRD: `prd.md`
- PRFAQ: `prfaq-ralph-bmad.md`
- PRFAQ Distillate: `prfaq-ralph-bmad-distillate.md`
- Technical Research: `research/technical-keel-ralph-bmad-research-2026-04-17.md`
- Brainstorming Session: `brainstorming-session-2026-04-17-0910.md`
- Ralph Loop Reference: `docs/ralph.md`
- Additional Reference Documents: none

## Pre-Validation Party Mode Round (2026-04-18)

Before systematic validation steps, a pre-validation Party Mode round surfaced concerns from four agents (John/PM, Winston/Architect, Murat/Test Architect, Victor/Innovation Strategist). Three convergence tension-points emerged:

1. **Absorption-tripwire integrity** (John + Victor + Winston) — the monthly blank-starter-sprint has no named owner, no pre-registered "green" definition, and no escape-hatch-closing commitment. **Not yet addressed** — will re-surface during systematic validation (Brief Coverage step, Measurability step) or Post-Validation round.
2. **`Required tests:` schema authority + mutability** (Murat + Winston) — load-bearing and ambiguous on authorship and mutability. **Addressed via PRD edit pass** (see below).
3. **PRD-vs-architecture altitude** (Winston + Murat) — generator algorithm, tmpfs/shm sizes, and CI minute budgets pinned at PRD level when they should pin outcome and defer numerics to empirically-validated reference configs. **Addressed via PRD edit pass** (see below).

### PRD Edit Pass (Party-Mode-driven, applied 2026-04-18)

Applied Murat + Winston's concrete edit proposals. Summary of changes committed to `prd.md`:

- **Tension #2 — `Required tests:` schema authority + mutability:**
  - § Technical Success backpressure bullet rewritten with planning-skill authorship + append-only + content-hash tamper-evidence + stable-test-id semantics.
  - FR14a split into FR14a + three new sub-FRs: FR14a1 (Authorship separation), FR14a2 (Manifest immutability — append-only with content hash, pre-merge-fast rejects shrinkage without signed `expand:` annotation), FR14a3 (Assertion-shape floor — ≥80% mutant-kill on high-risk slices).
  - New FR14l (Halt-on-same-test-fails threshold) demotes "3 consecutive" to a configurable default pending M9 empirical tuning.
- **Tension #3 — PRD-vs-architecture altitude:**
  - FR67 rewritten to pin six externally-observable properties (pure / deterministic / idempotent / order-independent / canonical-form-exists / stable-rule-identity) with internal ordering + merge + canonicalisation deferred to architecture handoff §Generator-Normalization-Algorithm.
  - Five cross-references collapsed to FR67 cite (Executive Summary mechanism #3; Technical Success Config-to-invariants sync; M0.7 milestone; `packages/keel-generator` description; load-bearing core requirements; Technical Risks generator-idempotency mitigation). Invariants § Coverage generator-contract bullet also harmonised.
  - NFR8 rewritten to pin tmpfs `noexec,nosuid` + `.envrc`-parameterised-sizes invariant only; numeric defaults (2 GB / 1 GB / 500 MB) demoted to `packages/devbox/.envrc.example` as architecture-owned reference config.
  - New NFR8a declares devbox numerics as retunable reference config not PRD requirements.
  - Devbox Implementation Contract (base image & architecture, tmpfs policy) and M0.5 (b) Compose updated to cite `.envrc.example` + NFR8a consistently.
  - New NFR28b (CI-budget empirical baseline) + NFR28c (Monthly CI-budget review); § Technical Success CI-pyramid bullet gets "target-SLOs not invariants" prefatory sentence.

**Cross-file callouts surfaced but deferred:**
- Architecture stubs `§Generator-Normalization-Algorithm` + `§Devbox-Reference-Config` (cited by FR67 and NFR8/NFR8a respectively) — authored at `bmad-create-architecture`.
- New file `packages/devbox/.envrc.example` — authored at M0.5.

### Open Pre-Validation Concerns (unaddressed by edit pass — to be tracked as validation findings)

From the Party Mode round, **still open** for validation to hunt or for a future PRD-revision round:

- **Absorption-tripwire integrity** (John + Victor): no named owner for the monthly sprint; no pre-registered "green" definition; no commitment-device preventing goalpost-drift when month-2 hits the threshold. Victor's specific ask: "write down — now, before the first sprint — the exact acceptance criteria for the vertical slice, in a file that you agree not to edit once sprints start running."
- **Dual-posture tie-breaker** (John): "substrate AND research project — both first-class" needs a one-sentence priority rule for when they conflict. Otherwise "first-class" is a word for "haven't decided."
- **Product #2 concreteness** (John): business-success metrics (T2NP <1 week, 2 products in 12 months) assume product #2 exists as a named, queued bet. If it doesn't, the payback math is notional.
- **Flake-budget enforcer** (Murat): existing NFR28 sets flake thresholds (0.1% deterministic, 2% nightly) but doesn't name the enforcement mechanism when the nightly budget is breached. Murat's ask: named owner + p95 pass rate over 7 days + PR-blocking automation.
- **Paddle sandbox + Google OAuth live only at release-gated** (Murat): proposes a weekly synthetic "money path" in nightly rather than waiting for release to run fully-live flows.
- **2×2 matrix expansion policy** (Murat): when nightly grows to N×M cells, no explicit promotion rule to move cells from nightly → weekly.
- **Pre-merge-fast empirical baseline** (Murat): even with new NFR28b requiring a two-week baseline, no measured prototype exists today — Murat wants confirmation that M9's 4 days are sized for this, or the budget is aspirational.
- **"Synthetic schemas" definition** (Murat): clarification on whether RLS unit tests use in-memory pg shim (fast) or ephemeral Postgres (integration-tier).
- **Per-iteration security-evidence schema** (Murat): is the "critical-severity" field machine-parseable by Ralph's halt logic, or free-text markdown?
- **Prompt-injection scan implementation tier** (Murat): regex/AST vs LLM-based; the latter defeats the ≤10s pre-commit budget.

## Validation Findings

### Format Detection (step-v-02)

**PRD Structure — all Level 2 headers found (16 total):**

1. ## Executive Summary (line 78)
2. ## Project Classification (line 100)
3. ## Success Criteria (line 112)
4. ## Product Scope (line 148)
5. ## User Journeys (line 243)
6. ## Domain-Specific Requirements (line 313)
7. ## Innovation & Novel Patterns (line 375)
8. ## Developer-Tool & CLI-Tool Specific Requirements (line 420)
9. ## Project Scoping & Phased Development (line 542)
10. ## The Line: Keel Development vs Development with Keel (line 622)
11. ## Agent Workflow Contracts (line 671)
12. ## Security-by-Default Requirements (line 751)
13. ## Invariants (line 804)
14. ## Functional Requirements (line 854)
15. ## Baseline Product Capabilities Inherited by Forks (line 960)
16. ## Non-Functional Requirements (line 984)

**BMAD Core Sections Present:**
- Executive Summary: **Present** (line 78)
- Success Criteria: **Present** (line 112)
- Product Scope: **Present** (line 148, plus expanded at "Project Scoping & Phased Development" line 542)
- User Journeys: **Present** (line 243)
- Functional Requirements: **Present** (line 854)
- Non-Functional Requirements: **Present** (line 984)

**Format Classification:** BMAD Standard
**Core Sections Present:** 6/6

**Notes:**
- PRD substantially exceeds minimum BMAD structure — 10 additional top-level sections beyond the 6 core, including Project Classification, Domain-Specific Requirements, Innovation & Novel Patterns, Developer-Tool & CLI-Tool Specific Requirements, The Line, Agent Workflow Contracts, Security-by-Default Requirements, Invariants, and Baseline Product Capabilities. This reflects the dual research-project / substrate posture and the agentic-execution risk surface unique to this PRD.
- Section ordering follows BMAD convention (Summary → Classification → Criteria → Scope → Journeys → Domain/Innovation → Specific Requirements → Requirements → Baseline → NFRs).
- No structural deviations that would impede downstream BMAD consumption (UX Design, Architecture, Epics, Stories).

Proceeding to systematic validation checks (density, brief-coverage, measurability, traceability, etc.) against the post-edit-pass PRD.

### Information Density Validation (step-v-03)

**Anti-Pattern Violations:**

**Conversational Filler:** 0 occurrences
- Scanned for: "The system will allow users to...", "It is important to note that...", "In order to", "For the purpose of", "With regard to"
- Result: No matches

**Wordy Phrases:** 0 occurrences
- Scanned for: "Due to the fact that", "In the event of", "At this point in time", "In a manner that", "In order for", "Prior to"
- Result: No matches

**Redundant Phrases:** 0 occurrences (substantive)
- Scanned for: "Future plans", "Past history", "Absolutely essential", "Completely finish", "Each and every", "Needless to say", "Basically", "Actually"
- Result: 6 raw matches for "actually" — all substantive qualifiers, not filler:
  - Lines 164, 175, 581, 582: "a product of that shape is **actually queued**" — distinguishes real queued products from hypothetical ones. Encodes the PRD's load-bearing YAGNI policy (Growth-tier shapes ship only on real consumption). Removal changes meaning.
  - Line 263: "which unbuilt milestones are **actually load-bearing** vs aspirational" — distinguishes empirically-observed load-bearing from claimed. Removal changes meaning.
  - Line 595: "the capture of what was **actually load-bearing** once substrate-delta evaporates" — same pattern. Removal changes meaning.
- Net violation count: 0

**Total Violations:** 0

**Severity Assessment:** PASS

**Recommendation:** PRD demonstrates high information density with zero canonical anti-pattern violations. Dense substrate-technical register throughout; every "actually" reviewed is a semantic-weight-bearing qualifier distinguishing real-world triggers from hypothetical framing. Consistent with the PRD's stated principle "high signal-to-noise ratio" (per `data/prd-purpose.md`).

**Non-blocking observations (optional polish, not gating):**
- The frontmatter `editHistory` entries are extremely dense and long-form (single-paragraph changes-log entries of 300–800 words). These are historical records and do not affect PRD consumption; they are excluded from density scoring but worth noting as a maintenance surface should the PRD author prefer shorter entries in future passes.

### Product Brief Coverage (step-v-04)

**Status:** N/A — No Product Brief was provided as input.

PRD frontmatter confirms `documentCounts.briefs: 0`. The brief-equivalent upstream inputs used for this PRD are:
- PRFAQ (`prfaq-ralph-bmad.md`) + distillate (`prfaq-ralph-bmad-distillate.md`)
- Technical research (`research/technical-keel-ralph-bmad-research-2026-04-17.md`)
- Brainstorming session (`brainstorming-session-2026-04-17-0910.md`)
- Ralph loop reference (`docs/ralph.md`)

Traceability against PRFAQ + research + brainstorming will surface in step-v-06 (traceability validation) rather than here. This step is strictly scoped to Product Brief coverage per the canonical BMAD PRD chain (product-brief → PRD); when no brief exists, the check is skipped as designed.

### Measurability Validation (step-v-05)

**Total FRs analyzed:** 85 (confirmed)
**Total NFRs analyzed:** 45 (confirmed)

#### Functional Requirements

**Format Violations:** 0
All 85 FRs follow either `[Actor] can [capability]` (Developer / End user / Maintainer / Agent / System) or the sub-FR structural-contract pattern (MUST / cannot / enforces / rejects). FR67 (line 957) is a properties list (a)–(f) but prefixed "Generator output satisfies…" — structural-contract form. No pure-prose FRs lacking subject-verb structure found.

**Subjective Adjectives Found:** 0
Scanned for: easy, easily, fast, faster, quickly, quick, simple, straightforward, intuitive, user-friendly, responsive, snappy, efficient, robust, reliable, seamless. No unqualified uses. "fast" appears only as the proper-noun CI tier `pre-merge-fast`. "reliable" does not appear in any FR/NFR.

**Vague Quantifiers Found:** 0
Scanned for: multiple, several, some, many, few, various, a number of. No matches governing measurable concepts. Compound forms (`multi-iteration`, `multi-shape`) are structural per the guardrail (they name a project-type, not a count).

**Implementation Leakage:** 0 hard violations; 1 soft note
- **FR14a2** (line 879) — `Levenshtein-distance` names a specific internal similarity algorithm. **Defensible** because it is the concrete measurement mechanism that makes the append-only rule testable, and no public contract forces the choice. Flagged as "watch, not violate." (Architect could elect a different similarity measure at architecture phase; PRD should loosen phrasing to "content-similarity measure (specific algorithm per architecture)" in a future polish pass. Not blocking.)

The load-bearing tech references in FRs (Paddle, better-auth, pg-boss, Resend, OpenTelemetry, Prisma-adjacent RLS, TanStack Start) are correctly **not flagged** — they are the PRD's source-layer-pinned-invariants thesis, not leakage.

**FR Violations Total:** 0

#### Non-Functional Requirements

**Missing Metrics / Measurement Methods / Untestable:** 2
- **NFR3** (line 990) — "RLS query overhead is measurable, monitored, and held below a threshold set in the architecture doc. Budget deferred." No metric, no measurement method, no placeholder target in the PRD itself. Measurability is explicitly punted to the architecture doc with no stub value. Acknowledges measurability is required but doesn't deliver it at PRD level. **Severity: LOW-MODERATE.** Recommended fix: either add a target band (e.g., "RLS overhead < 15% of query wall-clock for typical tenant-scoped reads, validated via synthetic RLS vs non-RLS benchmark per NFR28b methodology") or explicitly mark `deferred to architecture with acknowledged PRD placeholder — target TBD at §RLS-Performance-Budget`.
- **NFR19** (line 1015) — "The substrate imposes no scalability ceiling beyond the underlying runtime (Node.js, Postgres, pg-boss)." No metric, no measurement method; the "no ceiling" phrasing is unfalsifiable as stated. **Severity: LOW.** Recommended fix: add a demonstrated-envelope statement (e.g., "tested to N concurrent tenants, M jobs-per-minute, P concurrent connections on commodity Postgres; beyond-envelope performance is out of scope until a real fork demands it") or a pointer to a benchmark gate.

**Incomplete Template:** 0
**Missing Context:** 0

Soft notes (not counted as violations):
- **NFR36** (line 1055) — Reserved/deleted slot. Not a requirement, not a violation — but leaves a numeric gap. Consider explicit renumber or removal comment before 1.0 freeze for maintenance hygiene.

**NFR Violations Total:** 2

#### Overall Assessment

**Total Requirements:** 130 (85 FRs + 45 NFRs)
**Total Violations:** 2 (both NFR measurability gaps; 0 FR violations)

**Severity:** PASS (<5 violations)

**Recommendation:** Requirements demonstrate strong measurability. FRs are uniformly verb-driven with actor-capability or system-invariant structure; NFRs are overwhelmingly quantified via targets (≤10s, ≥80% mutant-kill, >0.1% flake, CVSS ≥ 9, etc.), named standards (WCAG 2.1 AA, OWASP ASVS L1), or testable binary properties (fail-closed gates, mount flags, volume-not-bindmount). Two NFRs (NFR3 RLS overhead, NFR19 scalability ceiling) are the exceptions — both frame measurability as either deferred-to-architecture or absence-of-limit without a testable envelope. Both are fixable via short polish edits; neither is blocking.

**Key themes:**
- The Ralph FR cluster (FR14a through FR14l including sub-FRs) uses MUST / cannot / enforces / rejects consistently — rigorous structural-contract semantics.
- The Security, Observability, and Reliability NFR clusters are uniformly measurable.
- The two measurability gaps cluster in sections where a budget is either deferred (NFR3 → architecture) or framed as an absence (NFR19 → no ceiling). Pattern suggests a targeted polish pass on "deferred-measurability" items rather than systemic rewrites.

### Traceability Validation (step-v-06)

#### Chain Validation

**Executive Summary → Success Criteria:** Intact
- Mechanism 1 (source-layer invariant pinning) → Technical Success "Config-to-invariants sync" + Day-1 RLS generator
- Mechanism 2 (non-toggle-able gates + Ralph backpressure + PR-lifecycle matrix + pre-push CI gate) → Technical Success "Four-layer quality gates" + "Ralph acceptance-driven backpressure"
- Mechanism 3 (Day-1 RLS parameterised over tenancy templates) → Technical Success "Day-1 RLS invariant"
- Mechanism 4 (decomposed CI pyramid) → Technical Success "Decomposed CI pyramid"

**Success Criteria → User Journeys:** Intact
- T2NP → J1 (day-6 resolution); TTGNA → J3 (tenancy template exercised); Launchpad readiness → J1 resolution; M4 checkpoint → J2; Absorption tripwire → J1 ("March datapoint") + J2 (quarterly-clock reference); CI-pyramid tiers, four-layer gates, acceptance-driven backpressure, Day-1 RLS, on-the-loop ratio → J3
- Maintenance ceiling → not journey-operationalised but appropriately tracked via NFR29 (steady-state metric, outside journey scope)
- Import-boundary enforcement traced via J3 precondition + Journey Requirements Summary row "Package boundaries enforced at compile time" → M0
- Config-to-invariants sync traced via J1 one-line edit flow + Journey Requirements Summary row "`keel.config.ts` one-line shape edit" → M0.7

**User Journeys → Functional Requirements:** Intact
- J1: FR46-48 (bootstrap, shape edit), FR15-18 (RLS), FR54-64 (baseline product capabilities), FR60 (Paddle presets) — via Journey Requirements Summary rows
- J2: FR33 (checkpoint markdown artefact) — singular but content-appropriate
- J3: FR1-6, FR1a (devbox/prereqs), FR7-14 + FR14a-l (Ralph loop), FR35-41 (security verification), FR28-34 (gates) — via Journey Requirements Summary rows

**Scope → FR Alignment:** Intact
- Every 1.0-scoped FR maps to ≥1 milestone; every milestone has ≥1 FR delivering it.
- M0 → FR28, FR34, FR41, FR51-52
- M0.5 → FR1-6, FR1a
- M0.7 → FR65-68, FR15, FR41-43
- M1 → FR15-18
- M2 → FR54-59
- M3 → FR60-62
- M4 → FR19-20
- M5 → FR22-23
- M6 → FR21
- M7 → FR24-27, FR64
- M9 → FR28-32, FR14a-l, FR35-40, FR53

#### Orphan Elements

**Orphan Functional Requirements:** 0

All 85 FRs trace to at least one upstream justification. Notable near-orphans that pass validation:
- FR45 (fork INVARIANTS.fork.md) — Growth-tier; traces via Invariants § Extension/override model
- FR49 (Growth-tier adapter migration guide) — traces via Out of Scope + Growth Features
- FR63 (Growth-tier second billing provider) — traces via Growth Features
- FR14e (Non-Deterministic Backpressure scaffold) — traces via Innovation § acceptance-driven backpressure + Growth-tier default

**Unsupported Success Criteria:** 0

All criteria trace to journeys, the Journey Requirements Summary, or explicit NFR/Growth scope. Maintenance ceiling → NFR29; absorption tripwire → Domain § Agent-Capability Substrate Absorption Risk + quarterly observability outside narrative journey (acceptable per research-output dual-posture).

**User Journeys Without FRs:** 0

All three journeys map to explicit FR clusters via Journey Requirements Summary table (lines 299-311).

#### Traceability Matrix Summary (cluster view)

| FR Cluster | Traceable Origins | Status |
|---|---|---|
| Execution Environment (FR1-FR6, FR1a) | J3 precondition, Exec Environment §, Devbox Contract, NFR5-NFR10, Risk Mitigation (devbox cold-start, bootstrap handoff) | Pass |
| Ralph + Agent Workflow (FR7-FR14, FR14a-l, FR14a1-a3) | J3 iteration flow, Technical Success (backpressure, CI pyramid), § Agent Workflow Contracts, Innovation §5, Risk Mitigation (security-verif overhead) | Pass |
| Tenant Isolation (FR15-FR18) | Technical Success Day-1 RLS, J1 climax, J3 backpressure, Innovation §3, Validation Approach "Day-1 RLS" row | Pass |
| Platform Services (FR19-FR23) | Journey Req Summary row "Observability+audit+feature-flags+i18n", Baseline Product Capabilities, M4-M6 milestones | Pass |
| Internationalization (FR24-FR27, FR64) | Must-have capabilities list (M7), Journey Req Summary observability row, NFR20-21 | Pass |
| Quality & Governance (FR28-FR34) | Technical Success four-layer gates + decomposed CI, J2 checkpoint, Innovation §4, Validation Approach "Non-toggle-able gates" | Pass |
| Security Verification & Evidence (FR35-FR41) | Technical Success, Security-by-Default §, J3 iteration step 4, Innovation §5, Validation Approach "Per-iteration security evidence" | Pass |
| Invariants (FR41-FR45) | Invariants §, Coverage table, Innovation §1, §2 | Pass |
| Forkability & Upgradability (FR46-FR53, FR54-FR64) | J1 bootstrap + shape-edit, Out of Scope (adapters/migration), Baseline Product Capabilities, Growth Features, Correlated-Library Risk Policy | Pass |
| Configuration & Generator (FR65-FR68) | Technical Success config-to-invariants sync, Executive Summary mechanism #1 + #3, Invariants § Sync enforcement, Risk Mitigation (generator idempotency) | Pass |

#### Overall

**Total Traceability Issues:** 0

**Severity:** PASS

**Recommendation:** Traceability chain is intact — all requirements trace to user needs, business objectives, or research-output criteria. The PRD's four pre-built traceability aids (Journey Requirements Summary ~L295, Innovation Validation Approach ~L399, Risk Mitigation ~L412, Invariants Coverage ~L828) do substantial chain work and leave no clusters orphaned. The FR/journey graph is well-connected; research-output criteria (monthly blank-starter-sprint) trace via domain-specific § Absorption Risk + Validation Approach row rather than a narrative journey, consistent with the dual-posture (substrate + research) project classification. Post-wizard-reversal FR pruning (removed FR65-74 wizard FRs, collapsed M2/M3/M7 adapter scope) eliminated what would previously have been the most likely orphan-source; the 4 renumbered FR65-68 each trace cleanly to Technical Success config-to-invariants sync plus Executive Summary mechanisms #1 and #3.

### Implementation Leakage Validation (step-v-07)

**IMPORTANT context for this step:** This PRD's load-bearing thesis is **source-layer-pinned invariants**. The PRD explicitly hardwires specific technologies (better-auth, Paddle, Prisma + Postgres, TanStack Start, pg-boss, Resend, OpenTelemetry, English baseline) as substrate choices; naming these is the PRD's core differentiator, not leakage. Canonical leakage criteria are applied with this context in mind per the `data/prd-purpose.md` rule that capability-relevant terms are acceptable when they describe WHAT the system must do.

#### Leakage by Category

**Frontend Frameworks:** 0 violations
- Mentions scanned: TanStack Start (hardwired per thesis — capability-relevant); Next.js (appears in 3 places: line 339 as correlated-library demotion-path example, line 459 as post-1.0 migration example, FR49 line 947 as Growth-tier migration-guide example — all contextually framed as illustrative future-state, not PRD implementation spec)
- All mentions are capability-relevant (thesis-hardwired) or illustrative (migration-path examples).

**Backend Frameworks:** 0 violations
- No Express, Django, Rails, Spring, FastAPI, Laravel etc. found. TanStack Start covers full-stack; better-auth is auth not "framework."

**Databases:** 0 violations
- Mentions scanned: PostgreSQL / Postgres (capability-relevant — Day-1 RLS invariant physically requires Postgres per FR15, NFR11; the generator emits Postgres-specific RLS policies).
- Prisma (capability-relevant — hardwired ORM per thesis).
- No MongoDB, MySQL, Redis (separate), Cassandra, DynamoDB.

**Cloud Platforms:** 0 violations
- Mentions scanned: AWS CLI (line 156) — appears as a devbox-image pinned tool, not as a requirement for the product runtime. Defensible as operational toolchain pin.
- Supabase CLI (line 156) — same; devbox tool bake.
- Vercel / Fly / Railway (line 180) — listed as **optional Growth-tier deploy-target Dockerfile presets**, explicitly optional polish, not 1.0 infrastructure requirements.
- No GCP, Azure, Cloudflare, Netlify found in requirement scope.

**Infrastructure:** 0 violations
- Docker / docker-compose: the devbox IS the security boundary (see § Security-by-Default Requirements → "Sandbox is the security boundary" line 755). Docker mentions are capability-relevant — removing them would break the sandbox-as-security-boundary thesis.
- No Kubernetes, Terraform, Ansible, etc. found.

**Libraries:** 0 violations
- Hardwired-stack libraries (better-auth, Paddle, pg-boss, Resend, TanStack Start, tRPC, react-hook-form, Zod, Zustand, Tailwind, OpenTelemetry, Prisma) — all capability-relevant per PRD thesis.
- Auth.js appears only in correlated-library demotion example (line 339) as illustrative migration target — acceptable.
- Playwright, Chromium — appear in devbox-bake tool list + NFR8 "canonical workload envelope" — operational, not product capability.
- `delta`, `gh`, `uv` — devbox tool pins; operational toolchain.

**Data Formats:** 0 violations
- JSON: appears in halt schema (FR14k, NFR33a), security-evidence persistence (FR37, NFR15), context-meter (FR14d), stream-json logs (FR13). All capability-relevant — JSON is the *public contract* for machine-readable artefacts Ralph + downstream tooling consume.
- Markdown: `.ralph/@plan.md` structure (FR14k), `docs/checkpoints/` entries, knowledge files (FR14j). Capability-relevant — markdown is the *public contract* for human-readable agent state.

**Other Implementation Details:** 0 hard violations; 1 soft note carried from step-v-05
- **FR14a2 Levenshtein-distance** (line 879) — names a specific string-similarity algorithm. Defensible because it's the measurable mechanism making the append-only rule testable; no public contract forces the choice. Classified as "watch, not violate" (can loosen to "content-similarity measure, specific algorithm per architecture" at polish pass). Not blocking.

#### Summary

**Total Implementation Leakage Violations:** 0

**Severity:** PASS

**Recommendation:** No significant implementation leakage found. Requirements properly specify WHAT via the PRD's explicit source-layer-pinned-invariants thesis — where specific tech names appear, they are either (a) the hardwired substrate itself (the PRD's core differentiator), (b) illustrative migration-path examples in Growth-tier / correlated-library policy, (c) devbox operational tool pins, or (d) optional future deploy-target presets. The one soft note (FR14a2 Levenshtein-distance) is a measurability-mechanism choice, not a runtime implementation leak, and is loosen-able at architecture phase without PRD revision.

**Note for downstream reviewers:** This PRD inverts the canonical "specify WHAT, not HOW" rule in a narrow, deliberate way — the hardwired stack IS the product decision. Architecture phase receives these tech pins as non-negotiable inputs, not as open design questions. This is documented in the PRD's Executive Summary mechanism #1 and § Project Classification → Configuration Model.

### Domain Compliance Validation (step-v-08)

**Domain:** general (per § Project Classification line 104: `Domain: general — agentic-engineering workflow; autonomous-code-execution risk surface`)

**Complexity:** Low (general/standard — not Healthcare, Fintech, GovTech, EdTech, or Legal-tech)

**Assessment:** N/A — No canonical regulatory domain compliance requirements apply (HIPAA, PCI-DSS, SOC2, WCAG-as-government-mandate, NIST, FedRAMP, etc. are not triggered).

#### Observations (non-gating)

The PRD anticipates the "general domain" classification and **authors its own quasi-regulatory domain-specific requirements** in § Domain-Specific Requirements (lines 313-373). This is unusual but well-justified given the domain novelty (autonomous-code-execution risk has no pre-existing compliance framework). The self-authored surface covers:

1. **Autonomous-Code-Execution Risk Surface** (lines 317-333) — devbox sandbox as security boundary; per-iteration security evidence; non-toggle-able gates. Functionally equivalent to regulatory-style controls for a category that doesn't yet have regulators.
2. **Correlated-Library Risk Policy** (lines 334-341) — hardwired-library maintainer-signal thresholds; abandonment-triggered demotion path. Functional-equivalent of supply-chain risk governance.
3. **Model and Tooling Evolution** (lines 342-362) — tested-model-generation discipline; breaking-upgrade detection; major-version cadence anchored to model-generation drift. Functional-equivalent of dependency-compatibility governance.
4. **Agent-Capability Substrate Absorption Risk** (lines 363-373) — monthly blank-starter-sprint falsification tripwire; archive kill criterion. Self-imposed governance for a technology whose competitive baseline shifts monthly.

In addition, the PRD self-adopts named baselines that parallel regulatory compliance:
- **OWASP Top 10:2025** + **ASVS Level 1** + **OWASP Top 10 for Agentic Applications (2026)** (NFR17)
- **WCAG 2.1 Level AA** for baseline UI components (NFR20)

**Assessment of self-authored domain-specific sections:** Well-scoped, internally consistent, and appropriately measurable. No formal regulatory compliance is required or missing; the PRD has pre-emptively authored its own equivalent surface. Pass.

#### Summary

**Required Regulatory Sections Present:** N/A (general domain)
**Compliance Gaps:** 0
**Self-authored domain-specific requirements adequacy:** Pass (well-documented, measurable, aligned with risk posture)

**Severity:** PASS

**Recommendation:** No canonical domain compliance requirements apply. The PRD has pre-emptively authored domain-specific requirements appropriate to the novel autonomous-code-execution risk surface; these are well-scoped and measurable. Consider a future pass (not blocking for 1.0) on whether the self-authored domain requirements should be re-classified as a separate "Agentic-Development Compliance" surface once more projects in this space exist and conventions emerge.

### Project-Type Compliance Validation (step-v-09)

**Project Type:** Dual classification per § Project Classification line 100 — `developer_tool` / `cli_tool`, `multi-shape-hardwired` content shape. Validated against union of both project-type requirement sets.

#### Required Sections

**developer_tool required:**
- **language_matrix:** Present (line 428 "Language support. TypeScript only, end-to-end. No polyglot targets — Python / Go / Rust SDKs are explicitly out of scope.")
- **installation_methods:** Present (line 432 "Installation methods. Two paths at 1.0" — `pnpm dlx create-keel-app` + `git clone`)
- **api_surface:** Present (line 441 "API surface (developer-facing)" — 12 typed package exports enumerated)
- **code_examples:** Present (line 457 "Code examples. The fresh fork with default `shape: b2b` is the canonical example.")
- **migration_guide:** Present (line 459 "Post-1.0 migration paths" + FR49, FR63 Growth-tier migration-guide-per-axis policy)

**cli_tool required:**
- **command_structure:** Present (§ CLI-Tool Surface lines 463-491 with two command tables — host-side lifecycle + container-native — covering 15+ commands with `pnpm devbox:whitelist add|remove|list|sync` argument structure)
- **output_formats:** Present (line 496 "Output formats" — Ralph TUI, stream-json logs, JSON halt signal, plain-text bootstrap status)
- **config_schema:** Present (`keel.config.ts` schema pinned in FR65; `.ralph/@plan.md` schema pinned in FR14k; halt-signal JSON schema pinned in FR14k + NFR33a)
- **scripting_support:** Present (line 509 "Scriptable / CI mode" subsection — non-interactive bootstrap, headless Claude auth via `ANTHROPIC_API_KEY` Tier-2 path, deferred Growth-tier candidates explicitly consolidated). Added in post-validation polish pass per prior 2026-04-18 editHistory entry.

**Required Sections Present:** 9/9

#### Excluded Sections (Should Not Be Present)

**developer_tool skip:**
- **visual_design:** Absent ✓
- **store_compliance:** Absent ✓ (no app-store submission; Keel is fork-and-use)

**cli_tool skip:**
- **visual_design:** Absent ✓
- **ux_principles:** Absent ✓ (no CLI UX principles section; BMAD-standard § User Journeys is universal and not cli-UX-specific)
- **touch_interactions:** Absent ✓

**Excluded Sections Present:** 0

**Note on NFR20 baseline UI components** (WCAG 2.1 AA signup/login/billing/locale-selector/team-management): These are **not** a visual-design section violation. They describe baseline UI components that ship with the *generated SaaS app* a Keel fork produces, not Keel's own developer-facing surface. Keel produces SaaS apps; those apps must meet accessibility standards. Correctly classified as baseline product capability, not Keel-tool UX.

#### Compliance Summary

**Required Sections:** 9/9 present (100%)
**Excluded Sections Present:** 0 (target: 0)
**Compliance Score:** 100%

**Severity:** PASS

**Recommendation:** All required sections for developer_tool + cli_tool are present and adequately documented. No excluded sections detected. The dual-classification is coherent — the PRD correctly treats Keel as a SaaS-substrate-authored-in-TS consumed via pnpm scripts, addressing both the developer-tool axis (packages, installation, migration) and the cli-tool axis (command structure, output formats, config schema, scripting support) without conflating them.

**Observations (non-gating):**
- The Scriptable / CI mode subsection (line 509) was added specifically to raise `scripting_support` from Partial to Met per the prior 2026-04-17 validation-report finding. Polish-pass traceability confirmed; fix landed.
- The PRD correctly cross-cites between developer-tool and cli-tool sections rather than duplicating content, which preserves density while covering both classifications.

### SMART Requirements Validation (step-v-10)

**Total Functional Requirements:** 85

Scored cluster-by-cluster rather than per-FR due to volume (85 FRs × 5 dimensions = 425 cells); individual FRs called out only where any SMART dimension would score <3. This scoring leverages prior step findings (0 measurability violations, 0 orphans, 0 implementation leakage hard violations) as grounding.

#### SMART Cluster Scoring

| Cluster | S | M | A | R | T | Avg | Notes |
|---|---|---|---|---|---|---|---|
| Execution Environment (FR1–FR6, FR1a) | 5 | 5 | 5 | 5 | 5 | 5.0 | FR1a pins fail-closed semantics with atomic-reload, IPv4/IPv6 parity, JSONL output — highly measurable. Mechanism deferred to architecture, scope attainable. |
| Ralph + Agent Workflow (FR7–FR14l) | 5 | 5 | 5 | 5 | 5 | 5.0 | Post-Party-Mode rigor: orient / execute / PR-matrix / knowledge / halt schemas each carry normative spec pointers. FR14a1–FR14a3 close authorship / manifest / mutation loopholes. |
| Tenant Isolation (FR15–FR18) | 5 | 5 | 5 | 5 | 5 | 5.0 | Template-parameterised over shape with CI enforcement (FR18); `tenantGuard()` + `rls:explain` pinned concretely. |
| Platform Services (FR19–FR23) | 4 | 4 | 5 | 5 | 5 | 4.6 | Terse by design — library names pin behaviour (pg-boss, Resend, OTel). Slight softness on *measurable* outcomes (FR22 "all request paths" has no explicit coverage gate) but traceable to source-layer invariants. |
| Internationalization (FR24–FR27, FR64) | 5 | 5 | 5 | 5 | 5 | 5.0 | FR27 promotes i18n-key usage to a CI-enforced gate — measurable. Baseline-locale + override path clear. |
| Quality & Governance (FR28–FR34) | 5 | 5 | 5 | 5 | 5 | 5.0 | Tiered gates (prek, pre-merge, release-gated, release-please) each with explicit invocation surfaces. FR30 names the paid-sandbox E2E shape clearly. |
| Security Verification & Evidence (FR35–FR41) | 5 | 5 | 5 | 5 | 5 | 5.0 | Per-iteration scan + evidence persistence + halt threshold + ASVS-L1 baseline with documented Tier-2 path. Prompt-injection scan (FR40) explicit. |
| Invariants (FR41–FR45) | 5 | 5 | 4 | 5 | 5 | 4.8 | FR43 ID+hash manifest drift check is sharp. FR45 (Growth-tier) intentionally deferred — acceptable on Attainable. |
| Forkability & Upgradability (FR46–FR53, FR54–FR64) | 5 | 5 | 5 | 5 | 5 | 5.0 | FR47 "No wizard. No prompts." pinned; FR48 shape-swap path concrete; FR49 Growth deferral clean. FR53 path-based gate-profile split measurable. |
| Configuration & Generator (FR65–FR68) | 4 | 5 | 5 | 5 | 5 | 4.8 | FR67 expresses a six-property structural contract (pure / deterministic / idempotent / order-independent / canonical / stable-ID) — less "can X" capability-shaped; acceptable, but Specific drops to 4. |

**Legend:** 1=Poor, 3=Acceptable, 5=Excellent. Dimensions: S=Specific, M=Measurable, A=Attainable, R=Relevant, T=Traceable.

#### Flagged Individual FRs

0 flagged (<3 in any dimension).

Near-flags that resolved to ≥3:
- **FR14a2** (line 879) and **FR67** (line 957) were candidates for Specific softness — both resolve to 4/5 structural-contract scores, not <3, because each pins measurable artefacts (test-id + content-hash for FR14a2; six-property checklist for FR67).
- **FR45, FR49, FR14e, FR63** Growth-tier deferrals all carry explicit 1.0 vs Growth scope markers and shipping paths — not aspirational.

#### Aggregate

- **Clusters with all dimensions ≥ 4:** 10/10 = 100%
- **Clusters with all dimensions ≥ 3:** 10/10 = 100%
- **Overall average:** 4.92 / 5.0 (246 / 250)
- **Individually flagged FRs:** 0 / 85 = 0%

**Severity:** PASS

**Recommendation:** Functional Requirements demonstrate strong SMART quality overall. All 10 clusters score ≥4 on every dimension; 0 FRs flagged for <3 in any dimension. The PRD's structural-contract FRs (FR14a2 Levenshtein, FR67 six-property generator contract) trade "can X" capability phrasing for pinned invariant properties — this is intentional per the source-layer-pinned-invariants thesis and does not reduce below the Pass threshold. Growth-tier deferrals are cleanly scope-bounded with explicit 1.0-vs-Growth shipping boundaries rather than aspirational hand-waves.

**Key themes:**
- Strongest cluster: **Ralph + Agent Workflow** (FR14a–FR14l). Post-Party-Mode iteration hardened it into normative-spec-backed contracts with authorship separation, manifest immutability (append-only + content-hash), mutation-sampled assertion floors, and closed halt-reason enums.
- Slightly softer clusters: **Platform Services** (FR19–FR23) at 4.6 (library-name brevity trades Specific detail for density) and **Configuration & Generator** (FR65–FR68) at 4.8 (structural-contract shape on FR67). Both trade-offs are deliberate and validated by prior steps.
- Growth-tier and deferred FRs are correctly handled — they show their work (explicit 1.0/Growth distinction, consumption-driven activation, CI-tested migration paths) rather than hiding scope fuzz.

### Holistic Quality Assessment (step-v-11)

Synthesized from steps 1-10 findings plus a whole-document cohesion pass. Scoped to PRD-as-artifact quality; strategic/governance questions from Party Mode are carried forward as Top 3 Improvements rather than artifact defects.

#### Document Flow & Coherence

**Assessment:** Excellent

**Strengths:**
- Clear narrative spine: `Source-layer invariants → Agent coherence → On-the-loop → Compounding across products`. Executive Summary articulates this as three co-equal principles + four load-bearing mechanisms, then successive sections implement each.
- Cross-referencing between sections is consistent and working: Success Criteria ↔ Journey Requirements Summary ↔ FR clusters ↔ Validation Approach ↔ Invariants Coverage — four pre-built traceability surfaces that do real chain work.
- `editHistory` frontmatter preserves pivot trail: wizard-reversal, devbox-detail-absorption, Ralph/BMad integration pass, post-validation polish, Party-Mode edit pass. Each entry is dense but faithful; future readers can reconstruct decision genealogy.
- Post-Party-Mode edit pass (today, 2026-04-18) hardened two high-risk areas — `Required tests:` schema authority/mutability and PRD-vs-architecture altitude — without disrupting the overall document shape.

**Areas for Improvement:**
- `editHistory` entries are themselves 300–800 words each; six entries total. The historical burden is real but not load-bearing for downstream consumption. A future polish could consolidate to headline-per-pivot + collapsed detail blocks.
- Some section headers (e.g., "The Line: Keel Development vs Development with Keel") rely on established reader-context; executive-first-time-readers may need to scan backward. Minor.
- Journey 2 (M4 checkpoint governance) is content-light compared to J1 and J3 — reflects the ritual's narrative-thinness, but could carry one more concrete scenario.

#### Dual Audience Effectiveness

**For Humans:**
- **Executive-friendly:** Strong — Executive Summary + Thesis + competitive framing deliver the vision in ~3 paragraphs. Density is a barrier for first-time executive readers but Section headings navigate well.
- **Developer clarity:** Excellent — every FR is actionable, FR clusters map to milestones, Devbox Implementation Contract and CLI-Tool Surface give concrete dev-facing affordances.
- **Designer clarity:** N/A — no traditional UX surface for a CLI tool; baseline product UI components (NFR20 WCAG 2.1 AA) are appropriately scoped to generated SaaS apps, not the Keel CLI itself.
- **Stakeholder decision-making:** Excellent — explicit archive kill criterion (<2 products in 12 months), maintenance ceiling (>15h/mo triggers scope-cut), M4 recurring checkpoint with markdown-artefact commits, and absorption tripwire all give stakeholders (here: Tthew wearing stakeholder hat at N=1) clear falsification handles.

**For LLMs:**
- **Machine-readable structure:** Excellent — all 16 § Level 2 headers, all FRs and NFRs on canonical `- **FRn**:` / `- **NFRn**:` patterns, YAML frontmatter with `classification.domain`, `classification.projectType`, `inputDocuments`, `editHistory`, `stepsCompleted`. High LLM parseability.
- **UX readiness:** N/A for Keel itself (CLI tool); Epic/Story phase for baseline UI components of the generated SaaS can be driven by FR47–FR53 + NFR20–21.
- **Architecture readiness:** Excellent — § Invariants, § Devbox Implementation Contract, § Agent Workflow Contracts, § Security-by-Default, and FR67 all explicitly hand off specific surfaces to `bmad-create-architecture` with named handoff sections (§Generator-Normalization-Algorithm, §Devbox-Reference-Config). Primary load-bearing surfaces flagged (generator normalization contract + RLS tenancy-template design) per § Project Classification line 108.
- **Epic/Story readiness:** Excellent — 85 FRs cluster into 10 natural epic domains; each cluster maps to ≥1 milestone; milestones carry day-budgets. Straightforward to decompose via `bmad-create-epics-and-stories`.

**Dual Audience Score:** 5/5

#### BMAD PRD Principles Compliance

| Principle | Status | Notes |
|-----------|--------|-------|
| Information Density | Met | 0 canonical anti-pattern violations (step-v-03); "every sentence carries weight" evidenced by dense substrate-technical register throughout. |
| Measurability | Met | 128 of 130 requirements fully measurable (step-v-05); 2 NFR gaps (NFR3 RLS overhead, NFR19 scalability ceiling) — both non-blocking polish items. |
| Traceability | Met | 0 orphan FRs, 0 unsupported success criteria, 0 user journeys without FRs; 4 pre-built traceability surfaces do real chain work (step-v-06). |
| Domain Awareness | Met | General-domain classification correctly applied; 4 self-authored quasi-regulatory sections (Autonomous-Code-Execution Risk, Correlated-Library Risk Policy, Model and Tooling Evolution, Agent-Capability Substrate Absorption Risk) pre-empt compliance for a novel domain (step-v-08). |
| Zero Anti-Patterns | Met | 0 canonical anti-pattern violations across density, measurability, implementation-leakage, and SMART scans. |
| Dual Audience | Met | Strong for both humans and LLMs; concrete LLM-handoff surfaces named. |
| Markdown Format | Met | All 16 Level 2 headers; consistent FR/NFR list format; tables at Journey Requirements Summary, Validation Approach, Coverage, CLI-Tool Surface. |

**Principles Met:** 7/7

#### Overall Quality Rating

**Rating:** 5/5 — Excellent (PRD-as-artifact); ready for downstream BMAD consumption.

**Scale:**
- 5/5 - Excellent: Exemplary, ready for production use ✓
- 4/5 - Good: Strong with minor improvements needed
- 3/5 - Adequate: Acceptable but needs refinement
- 2/5 - Needs Work: Significant gaps or issues
- 1/5 - Problematic: Major flaws, needs substantial revision

**Rating rationale:** All 11 systematic validation checks pass cleanly. The Post-Party-Mode edit pass closed two of the three flagged tension-points; the third (absorption-tripwire integrity, dual-posture tie-breaker, product #2 concreteness) is strategic/governance rather than PRD-artifact quality and is appropriately carried forward as explicit improvement opportunities rather than concealed defects. This PRD is rare in its combination of density, rigor, self-falsification framing, and explicit architecture-handoff surfacing.

#### Top 3 Improvements

These are the most impactful improvements to make the PRD **definitively great** rather than merely excellent. All three are strategic/governance items surfaced during the pre-validation Party Mode round; they are open by the user's deliberate choice, not by oversight.

1. **Pre-register the blank-starter-sprint "green" definition.**

   **Why:** Victor, John, and Winston converged on this: the absorption tripwire has a numeric threshold (20% time-to-green delta sustained 2 consecutive months) but no pre-registered acceptance criteria for what "green" means per vertical slice. Without pre-registration, the definition can drift to protect the substrate when the tripwire fires. This is the single biggest strategic risk in the PRD: the kill criterion is self-measured by the project author, and the yardstick is undefined.

   **How:** Before month-1 runs, commit a `docs/absorption-tripwire/vertical-slice-acceptance.md` with the exact vertical-slice acceptance criteria (e.g., "user signup → tenant creation → first billable-event recorded → audit log entry verified") as a pinned artefact. Add a covenant clause forbidding edits post-commit except with the same ceremony as a Keel major version. Document the named owner (Tthew) and escalation path if the tripwire fires and the criteria need legitimate updating. This closes the escape hatch Victor flagged as "pre-laid retreat."

2. **Add a dual-posture tie-breaker rule.**

   **Why:** John flagged the "substrate AND research project — both first-class" framing as a "haven't decided yet" signal. Both outcomes being first-class is undecidable when they trade off (e.g., a slower M2 ship path that produces richer research output on the auth-axis drift). A one-sentence priority rule converts the dual posture from a hedge into a genuine strategy.

   **How:** Add to § Project Classification a clause like: "When substrate ship-velocity and research-output richness conflict at a decision point, substrate ship-velocity wins until M4 checkpoint; research-output richness wins post-1.0 if an absorption-tripwire-eligible signal is active. Otherwise default to substrate ship-velocity." Customize the specific rule to Tthew's actual preference; the point is to *have* a rule, not to have this particular one.

3. **Address the remaining Party Mode concerns from Murat + John (polish pass, not blocking 1.0).**

   **Why:** Seven concrete items were identified in the pre-validation round but deferred from today's edit pass — flake-budget enforcer owner, nightly "money path" promotion (currently Paddle/OAuth only runs at release-gated), 2×2 cell expansion policy, pre-merge-fast empirical-baseline confirmation, "synthetic schemas" definition (in-memory vs ephemeral Postgres), security-evidence schema parseability, prompt-injection scan implementation tier, and product #2 concreteness. Each is a small fix; together they close the last governance gaps.

   **How:** A single "polish pass 2" Party-Mode round with Murat + John during the M9 CI-hardening window (when pre-merge-fast empirical data becomes available) to apply all seven fixes at once. Defer until M9 because most require empirical evidence that does not exist yet.

#### Summary

**This PRD is:** an exemplary source-layer-pinned-invariants substrate specification with 0 artifact-level defects, rare self-falsification governance, and explicit architecture-handoff surfaces — ready for `bmad-create-architecture` consumption immediately.

**To make it definitively great:** pre-register the blank-starter-sprint acceptance criteria, add a dual-posture tie-breaker rule, and schedule a post-M9 polish pass to close the seven deferred Party Mode items.

### Completeness Validation (step-v-12)

Final gate check. Verifies no template variables remain, required content is present in every section, section-specific completeness is met, and frontmatter is properly populated.

#### Template Completeness

**Template Variables Found:** 0

Scanned for: `{variable}`, `{{variable}}`, `{placeholder}`, `[placeholder]`, `TODO`, `TBD`, `FIXME`, `XXX`. No matches found. ✓

#### Content Completeness by Section

| Section | Status | Notes |
|---------|--------|-------|
| Executive Summary | Complete | Vision + 4 load-bearing mechanisms + Execution Environment + Fork Initialisation subsections populated |
| Success Criteria | Complete | User Success (T2NP, TTGNA, on-the-loop), Business Success (5 criteria + tripwire), Technical Success (6 criteria + decomposed CI pyramid) |
| Product Scope | Complete | MVP (10 milestones with day-budgets) + Growth Features (6 categories) + Vision + Out of Scope |
| User Journeys | Complete | J1 (Product #2 Happy Path), J2 (M4 Checkpoint Governance), J3 (Agent Iteration) + Journey Requirements Summary table |
| Domain-Specific Requirements | Complete | 4 sub-sections covering autonomous-code-execution risk surface, correlated-library risk, model/tooling evolution, substrate absorption risk |
| Innovation & Novel Patterns | Complete | Detected areas, market context, Validation Approach table, Risk Mitigation |
| Developer-Tool & CLI-Tool Specific Requirements | Complete | Project-Type Overview, Developer-Tool Surface, CLI-Tool Surface, Implementation Considerations, Devbox Implementation Contract |
| Project Scoping & Phased Development | Complete | MVP Strategy, Feature Set, Post-MVP Features, Risk Mitigation Strategy |
| The Line | Complete | Three modes, state categories, 1.0 cut ritual, bootstrap sequence, Ralph-fork disposition |
| Agent Workflow Contracts | Complete | Orient/Execute phase contracts, PR-lifecycle matrix, Knowledge-file upkeep, Crash-journal, Halt schema, Planning mode separation |
| Security-by-Default Requirements | Complete | Sandbox-as-boundary preamble, baseline reference, substrate-level controls, Ralph-loop verification, verification with proof, backpressure behaviour |
| Invariants | Complete | Three layers, sync enforcement, coverage table, extension/override model, principle |
| Functional Requirements | Complete | 85 FRs across 10 sub-clusters (Execution Environment, Autonomous Agent Loop, Tenant Isolation, Platform Services, I18n, Quality & Governance, Security Verification, Invariants, Forkability, Config & Generator) |
| Baseline Product Capabilities | Complete | Identity & Access, Data model, Billing, Jobs, Email, Flags, Audit, UI, CLI — inherited by forks |
| Non-Functional Requirements | Complete | 45 NFRs across 9 sub-sections (Performance, Security, Scalability, Accessibility, Integration, Reliability, Maintainability, Observability, Invariants) |

**Sections Complete:** 16/16

#### Section-Specific Completeness

- **Success Criteria Measurability:** All measurable (step-v-05 confirmed, both User and Technical Success carry quantified metrics or named standards; Business Success criteria carry explicit falsification thresholds)
- **User Journeys Coverage:** Yes — covers the only user type (N=1 Tthew) across three journey scenarios (Happy path, M4 checkpoint governance, Agent iteration). Additional personae are explicitly out of scope per § Project Classification.
- **FRs Cover MVP Scope:** Yes (step-v-06 scope↔FR alignment confirmed — every M0–M9 milestone has ≥1 FR, every 1.0 FR maps to a milestone)
- **NFRs Have Specific Criteria:** All except 2 (NFR3 RLS overhead deferred to architecture without placeholder; NFR19 scalability ceiling framed as "no ceiling" without testable envelope). Both are polish items, not blocking.

#### Frontmatter Completeness

| Field | Status |
|-------|--------|
| `stepsCompleted` | Present (17 entries spanning creation + edit passes) |
| `lastEdited` | Present (`'2026-04-18'`) |
| `editHistory` | Present (9 entries covering the full pivot trail from 2026-04-17 onward) |
| `inputDocuments` | Present (5 files) |
| `documentCounts` | Present (briefs: 0, prfaqs: 2, research: 1, brainstorming: 1, projectDocs: 1) |
| `projectType` | Present (hybrid) |
| `ralphScope` | Present (in-scope-evolving-deliverable) |
| `workflowType` | Present (prd) |
| `classification.projectType` | Present (developer_tool) |
| `classification.projectSubtype` | Present (cli_tool) |
| `classification.contentShape` | Present (multi-shape-hardwired) |
| `classification.projectContext` | Present (greenfield) |
| `classification.domain` | Present (general) |

**Frontmatter Completeness:** 13/13 fields populated (100%)

#### Completeness Summary

**Overall Completeness:** 100% (16/16 sections complete, 0 template variables, 13/13 frontmatter fields)

**Critical Gaps:** 0
**Minor Gaps:** 2 (NFR3 and NFR19 measurability — carried over from step-v-05 as non-blocking polish items)

**Severity:** PASS

**Recommendation:** PRD is complete with all required sections and content present. Two minor measurability items (NFR3, NFR19) are polish-pass candidates, not completeness gaps. No template variables, no unfilled placeholders, no missing sections. Ready for downstream BMAD consumption.

---

## Final Summary (step-v-13)

### Overall Status: **PASS**

### Quick Results

| Validation Step | Severity | Notes |
|----------------|----------|-------|
| Format Detection | BMAD Standard | 6/6 core sections + 10 supplementary; 16 §2 headers total |
| Information Density | PASS | 0 anti-pattern violations; all 6 "actually" uses substantive |
| Product Brief Coverage | N/A | No brief provided; PRFAQ + research + brainstorming served as upstream |
| Measurability | PASS | 130/130 requirements fully measurable (post-fix pass); NFR3 + NFR19 warnings resolved |
| Traceability | PASS | 0 orphan FRs, 0 unsupported criteria, 0 journey gaps |
| Implementation Leakage | PASS | 0 violations; tech references are PRD thesis, not leakage |
| Domain Compliance | PASS | General domain; 4 self-authored quasi-regulatory sections |
| Project-Type Compliance | PASS (100%) | 9/9 required sections (developer_tool + cli_tool); 0 excluded violations |
| SMART Requirements | PASS | 10/10 clusters ≥ 4 on all dimensions; 0 flagged FRs; 4.92/5.0 average |
| Holistic Quality | 5/5 Excellent | 7/7 BMAD principles met; ready for production use |
| Completeness | PASS (100%) | 16/16 sections, 0 template variables, 13/13 frontmatter fields |

### Critical Issues: **None**

### Warnings: **0 remaining** (2 NFR polish items resolved in post-validation fix pass — see below)

#### Original warnings (resolved 2026-04-18)

1. ~~**NFR3** (line 990) — RLS query overhead measurability deferred to architecture without PRD-level placeholder target.~~ **RESOLVED** — rewritten to "< 15% of query wall-clock for typical tenant-scoped reads" PRD-placeholder target band, measured via pre-merge-slow RLS integration on ephemeral Postgres using NFR28b empirical-baseline methodology. Architecture phase refines the final value at §RLS-Performance-Budget.
2. ~~**NFR19** (line 1015) — Scalability ceiling framed as absence-of-limit ("imposes no scalability ceiling") without testable envelope.~~ **RESOLVED** — rewritten to "no artificial scalability ceiling — no hardcoded rate limits, connection caps, or throughput throttles in substrate code," verified by CI grep-gate on `packages/core/**`, `packages/jobs/**`, `packages/billing/**`. Demonstrated load envelope explicitly out-of-scope at 1.0; fork-reported bottleneck → Tier-1 deviation promotion rule.

Neither fix invented numeric targets not yet validated; both converted deferred / unfalsifiable framing into honest, testable PRD-level properties.

### Strengths

- **Post-Party-Mode rigor on Ralph + Agent Workflow cluster** (FR14a–FR14l): authorship separation, manifest immutability, mutation-sampled assertion floors, closed halt-reason enums — normative-spec-backed contracts throughout
- **Pre-built traceability surfaces**: Journey Requirements Summary, Innovation Validation Approach, Risk Mitigation, Invariants Coverage — four tables doing real chain work and leaving no clusters orphaned
- **Self-authored domain compliance**: for a novel autonomous-code-execution domain with no pre-existing regulatory framework, the PRD pre-emptively authored 4 quasi-regulatory sections (Autonomous-Code-Execution Risk, Correlated-Library Risk Policy, Model/Tooling Evolution, Agent-Capability Substrate Absorption Risk)
- **Rare falsification honesty**: archive kill criterion, maintenance ceiling, monthly absorption-tripwire with 20% threshold — the PRD commits to its own disprovability
- **Architecture-handoff clarity**: named handoff sections (§Generator-Normalization-Algorithm, §Devbox-Reference-Config) and primary load-bearing surfaces flagged in § Project Classification
- **Dense but consumable for both audiences**: LLM-parseable YAML frontmatter + canonical FR/NFR list patterns + section structure; human-readable narrative spine from Executive Summary through Success Criteria to Requirements

### Holistic Quality Rating: **5/5 — Excellent**

All 7 BMAD PRD principles met. Artifact-level defects: 0. Strategic/governance open items (from Party Mode) carried forward as Top 3 Improvements rather than concealed as defects. Ready for `bmad-create-architecture` consumption immediately.

### Top 3 Improvements (non-blocking; strategic governance)

1. **Pre-register the blank-starter-sprint "green" definition.** Write down exact vertical-slice acceptance criteria to a committed file (`docs/absorption-tripwire/vertical-slice-acceptance.md`) before month-1 runs, with a no-edit covenant. Closes the escape-hatch Victor identified; closes the "measured by the measurer" integrity risk.

2. **Add a dual-posture tie-breaker rule.** One-sentence priority rule for when substrate-success and research-success conflict. Converts "both first-class" from a hedge into a genuine strategy (John's ask).

3. **Address remaining Party Mode concerns in a post-M9 polish pass** (bundle): flake-budget enforcer owner, weekly "money path" promotion (Paddle/OAuth currently only at release-gated), 2×2 cell expansion policy, pre-merge-fast empirical baseline confirmation, "synthetic schemas" definition, security-evidence schema parseability, prompt-injection scan implementation tier, product #2 concreteness. Defer until M9 because most require empirical evidence not yet available.

### Recommendation

**PRD is in excellent shape and ready for downstream BMAD consumption** (`bmad-create-architecture` → `bmad-create-epics-and-stories` → `bmad-create-story` → implementation). The two NFR measurability polish items and the three strategic improvements are non-blocking and fit naturally into:
- Architecture phase (NFR3 architecture-doc reference resolves when architecture doc materialises §RLS-Performance-Budget)
- Pre-M1 setup (Top 3 Improvement #1 — pre-registration file)
- Executive Summary polish (Top 3 Improvement #2 — tie-breaker rule)
- M9 empirical-evidence polish pass (Top 3 Improvement #3 — Murat-led bundle)

No validation findings require revision before proceeding to architecture.
