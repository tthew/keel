---
validationTarget: '_bmad-output/planning-artifacts/prd.md'
validationDate: '2026-04-17'
inputDocuments:
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad.md
  - _bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md
  - _bmad-output/planning-artifacts/research/technical-keel-ralph-bmad-research-2026-04-17.md
  - _bmad-output/brainstorming/brainstorming-session-2026-04-17-0910.md
  - docs/ralph.md
validationStepsCompleted:
  - step-v-01-discovery
  - step-v-02-format-detection
  - step-v-02b-parity-check
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
validationStatus: PASS
priorValidationReport: 'prd-validation-report-pre-pivot-2026-04-17.md'
triggerEvent: 'Post-pivot validation after thesis shift: source-layer hardwired invariants → setup-time wizard-pinned invariants. Prior report (pre-pivot) archived.'
resolutionStatus:
  H1: RESOLVED
  H2: RESOLVED
  M1: RESOLVED
  M2: RESOLVED
  M3: RESOLVED
  M4: RESOLVED
  L1: DEFERRED
  L2: DEFERRED
  L3: DEFERRED
  L4: NO_ACTION
  L5: NO_ACTION
resolutionDate: '2026-04-17'
---

# PRD Validation Report

**PRD Being Validated:** `_bmad-output/planning-artifacts/prd.md` (1002 lines, 79 FRs incl. 14a-e variants, 37 NFRs)
**Validation Date:** 2026-04-17
**Post-pivot:** yes — thesis shifted from source-layer hardwired invariants to setup-time wizard-pinned invariants, with full Keel CLI + wizard escalated to MVP.
**Status:** **PASS** (originally PASS_WITH_FINDINGS; HIGH + MEDIUM resolved 2026-04-17 in follow-up polish pass — see resolutionStatus frontmatter). LOW findings deferred as documented below.

## Input Documents

- `_bmad-output/planning-artifacts/prfaq-ralph-bmad.md` — loaded. **STALE relative to pivot** (see Parity Findings).
- `_bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md` — loaded. **STALE relative to pivot**.
- `_bmad-output/planning-artifacts/research/technical-keel-ralph-bmad-research-2026-04-17.md` — loaded. Research is stack-neutral; parity holds.
- `_bmad-output/brainstorming/brainstorming-session-2026-04-17-0910.md` — loaded. Parity holds for axes resolved; wizard pivot is post-brainstorm and expected to be absent.
- `docs/ralph.md` — loaded. Ralph harness behaviour; parity holds.

---

## Validation Findings

### Severity distribution

| Severity | Count | Blocks downstream? |
|---|---|---|
| **CRITICAL** | 0 | No |
| **HIGH** | 2 | Yes — fix before UX / Architecture |
| **MEDIUM** | 4 | No (improves quality) |
| **LOW** | 5 | No (polish) |

---

### HIGH

#### H1. NFR35 "fails closed" contradicts wizard validation rules (warnings, not rejections)

- **Section:** `Developer-Tool & CLI-Tool Specific → Wizard & Configuration → Validation rules` (line ~539) vs `Non-Functional Requirements → Configuration & Wizard UX → NFR35` (line ~1000).
- **Issue:** NFR35 asserts the wizard "fails closed on validation errors — incompatible combinations surface at wizard time with a clear error (not silently at first test) and block scaffold creation." But the Validation rules list two "warning, not rejection" cases: `shape = api_first` with `billing = paddle`, and `deploy target = vercel` with `framework = tanstack-start`. Warnings that allow scaffold creation are not fail-closed.
- **Why it matters:** Downstream (Architecture, Epics) will derive the wizard's behavioural contract from one source or the other. If the NFR is correct, the warnings must become rejections or an explicit "proceed with confirmation" prompt path. If the warnings are correct, NFR35 needs to qualify "fails closed" as "for hard-incompatible combinations only."
- **Recommended fix (smallest diff):** add to NFR35: *"Rejection classes are enumerated in the Wizard Validation Rules. Warning-class combinations require explicit user confirmation to proceed (`--accept-warnings` in non-interactive mode); silent proceed-past-warning is forbidden."*

#### H2. Terminology "Tier-2 deviation path" used 9 times but anchored only at line ~494

- **Sections:** first use at line 202 (Out of Scope — ASVS L2+), first definition at line ~494 (Implementation Considerations).
- **Issue:** A reader hitting "Tier-2 deviation path" in Out of Scope (§ Product Scope) encounters the term ~290 lines before its definition. LLMs consuming the PRD as context will attach the definition to the anchor only, but human reviewers reading linearly will bounce.
- **Recommended fix:** add a one-line glossary note at the top of Out of Scope, or move the terminology anchor into the Executive Summary/What-Makes-Special. Minimal-change option: add a parenthetical at first use: *"lives behind a Tier-2 deviation path (off-wizard-catalogue exit — see Developer-Tool & CLI-Tool Specific → Implementation Considerations for definition) for compliance-bound forks."*

---

### MEDIUM

#### M1. Single-option wizard axes (Jobs, Email) create degenerate prompts

- **Section:** `Wizard & Configuration → Wizard choice catalogue` (~line 515).
- **Issue:** Jobs is `**pg-boss** (only option at 1.0)`; Email is `**resend** (only option at 1.0)`. A wizard prompt with a single option is either a confirmation step (confusing UX) or skipped silently (inconsistent catalogue). NFR34's 5-minute quick-start target assumes efficient prompts.
- **Recommended fix:** add to the catalogue description: *"Single-option axes at 1.0 (Jobs, Email) are elided from interactive prompts; they still appear in `keel.config.ts` with the sole supported value so Growth-tier additions slot into the existing schema without migration."*

#### M2. PRFAQ documents stale relative to thesis pivot

- **Files:** `prfaq-ralph-bmad.md` and `prfaq-ralph-bmad-distillate.md` still use "hardwired" / "adapter minimalism with exactly two deliberate exceptions" framing.
- **Issue:** The PRD is now authoritative; the PRFAQs as input documents tell a different story. Downstream consumers (human or LLM) who read the PRFAQ first will form a stale mental model.
- **Recommended fix:** add a `postPivotNote:` entry to each PRFAQ's frontmatter pointing at this PRD's editHistory, OR run `bmad-edit-prd` on the PRFAQ assets to align. Lowest-effort: append a `## Superseded Positioning` section to each PRFAQ with a pointer to `prd.md`. Not blocking — downstream BMad workflows read the PRD as the authoritative input.

#### M3. Milestone-day coherence in Journey 2 drifts with new plan

- **Section:** `User Journeys → Journey 2` (~line 240).
- **Issue:** Updated to "Day ~25 of the 48-day Keel 1.0 build. M0-M4 green (...). M5-M9 remain." Cumulative day-count for M0-M4 under the new plan: M0 (2) + M0.5 (3) + M0.6 (6) + M0.7 (3) + M1 (3) + M2 (5) + M3 (5) + M4 (2) = **29 days** to end of M4. Day ~25 falls inside M4 (Email+Jobs), not after it. Either (a) use "~Day 29" or (b) soften to "around the M4 checkpoint, ~60% through the 48-day plan."
- **Recommended fix:** change to *"Day ~29 of the 48-day Keel 1.0 build."* or *"Around the M4 checkpoint (~60% through the 48-day plan)."*

#### M4. Vision paragraph still uses "enforced invariants" without wizard framing

- **Section:** `Product Scope → Vision (Future)` (~line 161).
- **Issue:** Bullet 3 still reads *"Keel — substrate on which Ralph executes; the enforced invariants that let agents stay coherent across iterations and forks."* Post-pivot, the invariants are wizard-pinned-and-frozen, not source-layer. Semantically defensible but not sharpened to the new thesis.
- **Recommended fix:** change to *"Keel — substrate on which Ralph executes; the wizard-pinned-and-frozen invariants that let agents stay coherent across iterations and forks, regardless of which scaffold-time stack choices each fork made."*

---

### LOW

#### L1. Journey 3 validates RIAR "on a Keel repo" without specifying wizard-stack diversity

- **Section:** `User Journeys → Journey 3` (~line 248).
- **Issue:** Journey 3 validates RIAR ≥ 70%. Post-pivot, RIAR should ideally be demonstrated across different wizard-chosen stacks (not just the defaults) to prove the agent-coherent scaffolding thesis. J3 doesn't explicitly address this.
- **Recommended fix:** add a sentence at the end of J3 Resolution: *"Sustained RIAR ≥ 70% across forks with different wizard-chosen stacks is what validates the agent-coherent-scaffolding thesis, not just RIAR on defaults. Initial measurement is on the defaults-stack; diversification target is Growth-tier."*

#### L2. M0.6 depends on M0.7 config schema; sequence could be M0.6a/b or reordered

- **Section:** `Product Scope → MVP → M0.6 / M0.7` (~line 137).
- **Issue:** M0.6 (Keel CLI + wizard engine, 6d) needs a config schema to write against. M0.7 (config-as-invariants plumbing, 3d) defines that schema + generator. Building M0.6 before M0.7 requires either stubbing the schema or interleaving. Not a correctness issue but a sequence-reality issue that will surface during execution.
- **Recommended fix:** add a note: *"M0.6 and M0.7 may interleave — the wizard can be built against a stub schema while M0.7 lands the generator; alternatively swap order with M0.7 first, M0.6 second. Architecture doc will resolve."*

#### L3. FR67 wizard catalogue lists 15 axes; NFR34 5-minute quick-start bound may tighten

- **Section:** `FR67` (line 903) / `NFR34` (line 999).
- **Issue:** 15 prompts in 5 minutes = 20 seconds per prompt including read-question + press-Enter. Feasible for Enter-through, but assumes pre-validated defaults don't trigger re-prompts (e.g., if project-identity is required unconditionally per FR67's last axis note, that's manual typing, eating into budget).
- **Recommended fix:** clarify NFR34: *"Quick-start budget excludes manual typing for fields without defaults (project name, slug, domain placeholder); all axes with defaults pressable-through are assumed."*

#### L4. New `Terminology` note in Implementation Considerations is a departure from the original bullet-list style

- **Section:** `Developer-Tool & CLI-Tool Specific → Implementation Considerations` (~line 494).
- **Issue:** The appended terminology note is a ~5-line bullet that differs in shape from the surrounding single-line bullets. Minor style inconsistency.
- **Recommended fix:** none — the content is load-bearing and the shape is appropriate. Flagging only for awareness.

#### L5. `docs/unstub/*` in historical text at line 442 kept intentionally

- **Section:** `Migration-between-choices guides (the former "unstub guides")` (line 442).
- **Issue:** None. The parenthetical "former 'unstub guides'" is deliberate — it cushions readers migrating from the pre-pivot PRD. Kept as validation context.

---

## Validation Axes — Detail

### Format Detection (Step v-02)

- **Result:** BMAD Standard. All 9 core sections present (Executive Summary, Success Criteria, Product Scope, User Journeys, Domain-Specific Requirements, Innovation Analysis, Developer-Tool & CLI-Tool Specific Requirements, Functional Requirements, Non-Functional Requirements). Additional non-standard sections (The Line, Security-by-Default, Invariants) are well-motivated and do not break BMAD conformance.
- **Level-2 headers:** 15 `## ` headers. Subsections under each are `### ` level-3. Clean hierarchy.
- **Frontmatter:** complete and updated post-pivot. `classification.contentShape` correctly reflects `multi-shape-configurable`; `configurationModel: setup-time-pinned` is an additive field consistent with BMAD practice.

### Parity Check vs Input Documents (Step v-02b)

- **PRFAQ**: STALE on thesis — see M2 above.
- **Research doc**: parity holds. Competitive analysis against ShipFast/Makerkit/Supastarter is consistent with the new positioning.
- **Brainstorming session**: parity holds on seven load-bearing axes. Wizard pivot is explicitly post-brainstorm.
- **`docs/ralph.md`**: parity holds. Ralph harness behaviour unaffected by the thesis pivot.

### Density Validation (Step v-03)

- **Result:** PASS. No anti-patterns detected in new content. Direct voice ("Users can...", "System can...", "Wizard rejects..."). Zero instances of "It is important to note that..." or "In order to..." in the rewrite. Quick-start defaults paragraph in Executive Summary is a deliberate list (acceptable density trade for lookup-efficiency).
- **Note:** the Wizard Choice Catalogue table is 15 rows of reference data. Dense by construction; acceptable.

### Measurability Validation (Step v-05)

- **Result:** PASS with minor note.
- FRs 65-74: capability-framed, testable (each FR maps to a specific command behaviour that can be automated).
- NFRs 34-37: time budgets (5min / 20min), idempotency verification (regen-and-diff), schema-version validation. All measurable.
- **Note:** NFR34's "excludes devbox cold-start time" caveat is correct but means the user-perceived wizard time includes ~30s (warm) to ~5min (cold) from NFR2. Surface this in user-facing docs if confusion arises; not a PRD fix.

### Traceability Validation (Step v-06)

- **Result:** PASS. Vision → Success Criteria → Journeys → FRs chain intact post-pivot:
  - **Vision**: "substrate on which Ralph executes" → **Success Criteria**: T2NP ≤ 1 week, RIAR ≥ 70% → **Journey 1**: wizard-included T2NP validation → **FR65-FR74**: capability requirements.
  - **Wizard-pinned invariants thesis** → **Technical Success**: config-to-invariants sync → **FR70, FR71, FR74**: config persistence, generation, validation.
  - **Shape support thesis** → **Wizard Catalogue** → **FR60-FR63** (shape-aware billing), **FR15-FR18** (tenancy-parameterised RLS).
- **Minor gap:** the "agent-coherent scaffolding" differentiator (Innovation §) would benefit from an explicit journey sentence tying it to RIAR measurement across different wizard stacks. Captured as L1.

### Implementation Leakage (Step v-07)

- **Result:** PASS. Wizard Choice Catalogue names specific libraries (better-auth, Paddle, TanStack Start). This is **not** implementation leakage — it is the substrate's product promise (specific supported libraries at 1.0 are the defaults; the catalogue is the contract). PRD-appropriate.
- **Edge case:** FR71 enumerates specific generator outputs (`invariants.manifest.ts`, ESLint config, etc.). This is substrate-surface enumeration, not implementation detail. PRD-appropriate.

### Domain Compliance (Step v-08)

- **Result:** PASS. Domain = general SaaS (no regulatory regime binding substrate code). Autonomous-code-execution risk surface fully handled in Security-by-Default Requirements. Compliance-bound forks route through Tier-2 deviation path (ASVS L2+) — consistent.

### Project-Type Validation (Step v-09)

- **Result:** PASS. `developer_tool` / `cli_tool` requirements substantially expanded by the new Wizard & Configuration subsection. API surface, CLI surface, installation, prerequisite, config persistence all covered.

### SMART Validation (Step v-10)

- **Result:** PASS. FRs 65-74 are capability-scoped with explicit trigger commands. NFRs are measurable. No subjective adjectives in new content.

### Holistic Quality (Step v-11)

- **Result:** PASS with polish backlog (findings above). PRD is internally coherent post-pivot. The thesis shift is explicit in Executive Summary, What-Makes-Special, Innovation, and Implementation Considerations — reader cannot miss it.

### Completeness (Step v-12)

- **Result:** PASS. All 9 BMAD core sections present. Wizard surface, config-as-invariants, and shape-aware billing all specified. FR and NFR numbering is contiguous and correctly extended.

---

## Recommended Next Actions

1. **Fix H1** (NFR35 vs warnings) — 2-line edit. Blocks nothing else.
2. **Fix H2** (Tier-2 deviation path anchor placement) — 1-line edit or move anchor up.
3. (Optional) apply M1-M4 polish edits in a single follow-up pass.
4. (Optional) run `bmad-edit-prd` on the PRFAQ assets to align with the pivoted thesis (M2).
5. **Proceed to Architecture** (`bmad-create-architecture`) once H1/H2 are resolved. The architecture doc will resolve:
   - M0.6 / M0.7 sequencing (L2).
   - Generator hashing algorithm and CI hook placement.
   - Wizard schema format (TypeScript types vs JSON Schema vs Zod).
   - Migration-between-choices guide file format and executor.
   - `keel.config.ts` vs `keel.config.fork.ts` composition rules.
   - Shape-activated feature gating mechanism.
   - Idempotency verification strategy (content-hash algorithm).

---

## Status

**PASS** as of 2026-04-17 polish pass. H1 + H2 + M1-M4 resolved; see the PRD's editHistory for specific diffs. No CRITICAL findings. LOW findings are deferred improvement opportunities (non-blocking for Architecture / UX Design).
