# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — pre-dev validation of Story 1.10 readiness per FR14n matrix row 2. Story State `drafted` → `validated`. ~medium

## QUEUE (Story 1.10 — design-token schema, semantic + rationale contract)

- [ ] Run `/bmad-testarch-atdd` — red-phase acceptance scaffolds for Story 1.10's 4 ACs. State `validated` → `atdd-scaffolded`. ~medium
- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md")` — implement tokens.schema.json + tokens.md + manifest+INVARIANTS.md entries + sync-gate smokes. State `atdd-scaffolded` → `in-dev`. ~large
- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability matrix. State `in-dev` → `traced` (or `trace-fixes-pending`). ~medium
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM requirements-satisfaction verification. State `traced` → `sm-verified` (or `sm-fixes-pending`). ~medium
- [ ] Run `/bmad-code-review (args: "2")` — adversarial CR with action items. State `sm-verified` → `done` (or `fixes-pending`). ~medium

## BLOCKED

_(none)_

## DONE (Story 1.10 — iter-42 opening)

- [x] iter-42: `/bmad-create-story` drafted Story 1.10 at `_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md`. Story file authored with 4 ACs (schema shape, rationale-doc IDs, cross-link, manifest registration), 4 Tasks (schema author / rationale-doc author / manifest+INVARIANTS register / quality gates+sync-gate smokes+sprint-status bump), Dev Notes (architecture pattern refs: three-layer invariant, cross-runtime semantic tokens, W1 party-mode amendment, DTCG format refresher, semantic token inventory), Project Structure Notes (alignment + DTCG-vs-typed-source variance documented), 13 citations in References. AC 4 scope carve-out: epic's single-`INV-tokens-schema-contract` entry collapsed to two sibling entries (`INV-tokens-schema-contract` + `INV-tokens-semantic-rationale`) to preserve Story 1.8's single-`sourcePath`-per-entry `Invariant` contract — per manifest shape at `packages/keel-invariants/src/invariants.manifest.ts:6-11`. Sprint-status bumped `1-10-…: backlog → ready-for-dev`; `last_updated: 2026-04-20 Story-1-10-ready-for-dev UTC`. **FR14n state transition `_(no story)_ → drafted`** per matrix row 1. Story file Status set to `ready-for-dev` (BMad convention; Ralph FR14n calls this `drafted`). Pure prose + YAML edit; zero code changes; quality gates not re-run this iteration (no TS/JS touched). PR #226 stays Draft.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.9 done; 1.10 drafted at iter-42; 1.11–1.16 backlog → 6 more stories × full FR14n lifecycle remaining after 1.10 closure before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** 1.10 — design-token schema, semantic + rationale contract
- **Story File:** `_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md`
- **Story State:** `drafted` — FR14n matrix row 2 next action `/bmad-create-story (args: "review")` for `drafted → validated`
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Story 1.10 positioning.** First of 4 design-token-pipeline stories in Epic 1 (1.10 schema+rationale contract → 1.11 source population Direction A → 1.12 emitter pipeline → 1.13 quality gates). Story 1.10 is analogous to Story 1.8's role (`invariants.manifest.ts` contract) — contract-only, zero runtime behaviour, two artefact files + 2 manifest entries + 1 new INVARIANTS.md section. Per the contract-only / data-only pattern observed in Stories 1.3–1.6 + 1.8, expected to trend single-pass CR rather than the multi-pass behaviour of Story 1.9 (runtime sync-gate) + Story 1.7 (docs prose). Halving hypothesis from Story 1.9 was decisively falsified (iter-14 4 → iter-18 2 → iter-21 2 → iter-24 5 → iter-30 5 → iter-36 30 raw / 4 PATCH → iter-41 3 raw / 0 PATCH ZERO-OUT at round 7) — apply the four-layer carry-forward enumeration (sibling-artefact / SYMMETRIC-AC-PARALLEL / SIBLING-FIELD-PARALLEL / broader-corpus-vocabulary-propagation) from iter-22/24/30/36 RALPH Signposts + iter-36 two-layer-convergence-gates-PATCH-promotion rule to bound Story 1.10's CR loop tight.
- **Schema vs value separation.** Story 1.10 ships DTCG schema STRUCTURE + rationale PROSE only; Story 1.11 populates Direction A concrete values. This separation — contract-then-data — matches Story 1.8's posture (contract-then-enforcement in 1.9) and lets 1.10's ACs stay tight. Story 1.13's value-quality gates (schema-validation + WCAG AA contrast + source-output sync) run AFTER 1.11 source lands; Story 1.10 only needs to satisfy the structure-validates-DTCG claim of AC 1.
- **Two-entry manifest registration.** AC 4's epic phrasing at `epics.md:951` (`an entry INV-tokens-schema-contract registers tokens.schema.json + tokens.md`) conflicts with Story 1.8's single-`sourcePath`-per-`Invariant` shape. Resolution: two sibling manifest entries (`INV-tokens-schema-contract` → schema; `INV-tokens-semantic-rationale` → rationale doc), both anchored under a new `### Design-token schema + semantic rationale (Story 1.10)` section in `INVARIANTS.md`. Pattern matches `INV-eslint-shared` + `INV-eslint-import-boundary` (two IDs, shared `sourcePath`); here it's two IDs + two distinct `sourcePath` values. Documented as Story 1.10 § AC 4 scope carve-out in the story file.
- **Anchor regex landmines avoided** (Story 1.9 CR defer carry-forward — `deferred-work.md:37-38`): new `INVARIANTS.md` anchors use column-0 `- **\`INV-*\`**` form (regex binding at `packages/keel-invariants/src/sync-gate.ts:24`) and avoid fenced-code-block examples containing `INV-` bullets. Any rationale-doc example that needs to SHOW the anchor format uses inline backticks in prose, not triple-backtick fences.
- **Issue Tracking:** Story 1.10 issue number unset at iter-42 (no GH Project auto-issue creation configured for individual stories). Parent Epic 1 issue **#9** — `Refs #9` only.
