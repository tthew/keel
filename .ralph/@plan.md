# Implementation Plan

## NOW

- [ ] Run `/bmad-testarch-atdd` — red-phase acceptance scaffolds for Story 1.10's 4 ACs. State `validated` → `atdd-scaffolded` per FR14n matrix row 3. ~medium

## QUEUE (Story 1.10 — design-token schema, semantic + rationale contract)

- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md")` — implement tokens.schema.json + tokens.md + manifest+INVARIANTS.md entries + sync-gate smokes. State `atdd-scaffolded` → `in-dev`. ~large
- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability matrix. State `in-dev` → `traced` (or `trace-fixes-pending`). ~medium
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM requirements-satisfaction verification. State `traced` → `sm-verified` (or `sm-fixes-pending`). ~medium
- [ ] Run `/bmad-code-review (args: "2")` — adversarial CR with action items. State `sm-verified` → `done` (or `fixes-pending`). ~medium

## BLOCKED

_(none)_

## DONE (Story 1.10 — iter-43 pre-dev review)

- [x] iter-43: `/bmad-create-story (args: "review")` pre-dev SM review applied two critical fixes to `1-10-design-token-schema-semantic-rationale-contract.md`: (a) AC 2 stable-ID example corrected `TOKEN-motion-scale-snap` → `TOKEN-motion-snap` + added scope carve-out clarifying the epic's `motion.scale.*` / `density.scale.*` shorthand resolves to the global dial (`TOKEN-motion-scale` / `TOKEN-density-scale`, `$type: number` leaves) plus tier siblings (`TOKEN-motion-{instant|snap|swift|smooth|drift}` / `TOKEN-density-{compact|default|comfortable}`), matching architecture.md:693's two-segment `<category>.<semantic-name>` ID pattern and DTCG's group-node `$type`-prohibition; (b) Task 4 sprint-status transition rewritten from `backlog → in-progress at /bmad-create-story time, then in-progress → review at /bmad-dev-story completion` to the canonical Ralph direct-jump `ready-for-dev → done` at `/bmad-dev-story` completion (per Story 1.7 / 1.8 precedent — skip BMad `in-progress → review` intermediate; Ralph's FR14n owns the post-dev gates); story-file Status terminal state corrected `review → done` in the same subtask. Added `## Change Log` section with v1.0 (iter-42 authoring) + v1.1 (iter-43 pre-dev review) rows per Story 1.8 line 239 precedent. **FR14n state transition `drafted → validated`** per matrix row 2. Story file Status stays `ready-for-dev` (BMad convention; Ralph FR14n `validated` tracked in IP § Context). ACs 1, 3, 4 spot-validated well-formed; scope carve-outs (AC 1 schema-vs-value separation + AC 4 two-entry manifest carve-out) intact; 13 Reference citations spot-validated. Pure prose + markdown edit; zero code changes; quality gates not re-run (no TS/JS touched). PR #226 stays Draft with no CI checks reported. Story 1.10 issue number unset at iter-43 — parent Epic 1 `Refs #9` only.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.9 done; 1.10 `validated` at iter-43; 1.11–1.16 backlog → 6 more stories × full FR14n lifecycle remaining after 1.10 closure before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** 1.10 — design-token schema, semantic + rationale contract
- **Story File:** `_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md`
- **Story State:** `validated` — FR14n matrix row 3 next action `/bmad-testarch-atdd` for `validated → atdd-scaffolded`
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Story 1.10 positioning.** First of 4 design-token-pipeline stories in Epic 1 (1.10 schema+rationale contract → 1.11 source population Direction A → 1.12 emitter pipeline → 1.13 quality gates). Story 1.10 is analogous to Story 1.8's role (`invariants.manifest.ts` contract) — contract-only, zero runtime behaviour, two artefact files + 2 manifest entries + 1 new INVARIANTS.md section. Per the contract-only / data-only pattern observed in Stories 1.3–1.6 + 1.8, expected to trend single-pass CR rather than the multi-pass behaviour of Story 1.9 (runtime sync-gate) + Story 1.7 (docs prose). Halving hypothesis from Story 1.9 was decisively falsified (iter-14 4 → iter-18 2 → iter-21 2 → iter-24 5 → iter-30 5 → iter-36 30 raw / 4 PATCH → iter-41 3 raw / 0 PATCH ZERO-OUT at round 7) — apply the four-layer carry-forward enumeration (sibling-artefact / SYMMETRIC-AC-PARALLEL / SIBLING-FIELD-PARALLEL / broader-corpus-vocabulary-propagation) from iter-22/24/30/36 RALPH Signposts + iter-36 two-layer-convergence-gates-PATCH-promotion rule to bound Story 1.10's CR loop tight.
- **Schema vs value separation.** Story 1.10 ships DTCG schema STRUCTURE + rationale PROSE only; Story 1.11 populates Direction A concrete values. This separation — contract-then-data — matches Story 1.8's posture (contract-then-enforcement in 1.9) and lets 1.10's ACs stay tight. Story 1.13's value-quality gates (schema-validation + WCAG AA contrast + source-output sync) run AFTER 1.11 source lands; Story 1.10 only needs to satisfy the structure-validates-DTCG claim of AC 1.
- **Two-entry manifest registration.** AC 4's epic phrasing at `epics.md:951` (`an entry INV-tokens-schema-contract registers tokens.schema.json + tokens.md`) conflicts with Story 1.8's single-`sourcePath`-per-`Invariant` shape. Resolution: two sibling manifest entries (`INV-tokens-schema-contract` → schema; `INV-tokens-semantic-rationale` → rationale doc), both anchored under a new `### Design-token schema + semantic rationale (Story 1.10)` section in `INVARIANTS.md`. Pattern matches `INV-eslint-shared` + `INV-eslint-import-boundary` (two IDs, shared `sourcePath`); here it's two IDs + two distinct `sourcePath` values. Documented as Story 1.10 § AC 4 scope carve-out in the story file.
- **AC 2 motion/density stable-ID carve-out (iter-43 pre-dev-review addition).** The epic's AC 2 shorthand `motion.scale.*` / `density.scale.*` is NOT a nested-group reference. Stable IDs resolve as: `TOKEN-motion-scale` (dial leaf) + `TOKEN-motion-{instant|snap|swift|smooth|drift}` (tier sibling leaves); `TOKEN-density-scale` (dial leaf) + `TOKEN-density-{compact|default|comfortable}` (tier sibling leaves). Three-segment IDs (`TOKEN-motion-scale-snap`) are ruled out — DTCG prohibits group nodes carrying `$type`, architecture.md:693 pins two-segment `<category>.<semantic-name>` pattern, and the story's Task 1 schema models the dial as a sibling of the tiers. Consistency enforced across the story's AC 2 + Task 1 schema + Task 2 rationale-doc sections.
- **Anchor regex landmines avoided** (Story 1.9 CR defer carry-forward — `deferred-work.md:37-38`): new `INVARIANTS.md` anchors use column-0 `- **\`INV-*\`**` form (regex binding at `packages/keel-invariants/src/sync-gate.ts:24`) and avoid fenced-code-block examples containing `INV-` bullets. Any rationale-doc example that needs to SHOW the anchor format uses inline backticks in prose, not triple-backtick fences.
- **Issue Tracking:** Story 1.10 issue number unset at iter-43 (no GH Project auto-issue creation configured for individual stories). Parent Epic 1 issue **#9** — `Refs #9` only.
