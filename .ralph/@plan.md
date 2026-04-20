# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM re-verify. With SM-1 fixed and no other fix tasks pending, expect transition `sm-fixes-pending → sm-verified` per FR14n matrix row 7 (all § Review Findings checkboxes now `[x]`). ~medium

## QUEUE (Story 1.10 — design-token schema, semantic + rationale contract)

- [ ] Run `/bmad-code-review (args: "2")` — adversarial CR with action items. State `sm-verified → done` (or `fixes-pending`). ~medium

## BLOCKED

_(none)_

## DONE (Story 1.10 — iter-48 Fix SM-1)

- [x] iter-48: **Fix SM-1 [MEDIUM] landed; FR14n state stays `sm-fixes-pending` (QUEUE empty of fix tasks → iter-49 re-runs SM review for `sm-fixes-pending → sm-verified`).** Single prose edit + one manifest hash update + clean-path gate re-run. Added `### Font` section to `docs/invariants/tokens.md` between `### Type scale` and `### Spacing / radius / breakpoints` — two-sentence role-intro paragraph + one consolidated `TOKEN-font-{name}` bullet listing `TOKEN-font-sans` + `TOKEN-font-mono` (mirrors Neutral primitive-ramp pattern permitted by Task 2). Recomputed `sha256sum docs/invariants/tokens.md`: `2d8d0e3f...25c0 → efd5fa0d84d3478cd4af530f3cc57c734f9b4e23415d0c7085fb8e6296d1a82c`. Updated `INV-tokens-semantic-rationale.contentHash` at `packages/keel-invariants/src/invariants.manifest.ts:141`. Re-ran `pnpm -w typecheck` ✓ (Zod import-time validation of manifest), `pnpm -w build` ✓ (rebuild `dist/check.js` with new manifest), `pnpm keel-invariants:check` clean-path ✓ exit 0. § Review Findings SM-1 checkbox flipped `[ ] → [x]`. No drift-smokes re-run — iter-45's comprehensive drift-path exercise (content-hash-mismatch exit 1 + added-to-source-only exit 1 + byte-identical reverts) remains load-bearing for Story 1.10's AC 4 end-to-end claim. Story file Change Log v1.4 row appended. PR #226 CI: `no checks reported`; push safe. Tracked at GitHub issue #34 — `Refs #34` in commit trailer.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.9 done; 1.10 `sm-fixes-pending` awaiting iter-49 SM re-verify; 1.11–1.16 backlog → 6 more stories × full FR14n lifecycle remaining after 1.10 closure before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** 1.10 — design-token schema, semantic + rationale contract
- **Story File:** `_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md`
- **Story State:** `sm-fixes-pending` — iter-48 discharged the only § Review Findings item (SM-1) but state only transitions on SM re-verify per FR14n matrix row 8 ("stays until QUEUE empties → re-run validate → `sm-verified`"). iter-49 NOW is the re-run.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Story 1.10 positioning.** First of 4 design-token-pipeline stories in Epic 1 (1.10 schema+rationale contract → 1.11 source population Direction A → 1.12 emitter pipeline → 1.13 quality gates). Contract-only single-pass SM hypothesis was partially falsified at iter-47 (1 MEDIUM finding vs. Story 1.8 iter-5 zero-findings); fix was ~small (single prose insert + single hash bump). CR hypothesis (iter-7 Decisions: contract-only-trends-single-pass-CR) remains to-be-determined until iter-50 earliest.
- **Trace posture.** Gate WAIVED (fourth cumulative — 1.7 iter-5 + 1.8 iter-5 + 1.9 iter-8 + 1.10 iter-46). Seven-point rationale pinned at iter-46 trace artefacts; unchanged by iter-48's prose-only fix.
- **Post-iter-48 audit trail.** Only three files touched: `docs/invariants/tokens.md` (+9 lines — Font section), `packages/keel-invariants/src/invariants.manifest.ts` (1 hash char-swap at line 141), `_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md` (SM-1 checkbox flip + Change Log v1.4 row). Zero schema or runtime-code changes. Quality-gate evidence: `pnpm -w typecheck` 16/16 ✓, `pnpm -w build` 16/16 ✓, `pnpm keel-invariants:check` exit 0 (no drift).
- **Anchor regex landmines avoided** (Story 1.9 CR defer carry-forward — `deferred-work.md:37-38`): iter-48 added no new `INV-*` anchors; only added `TOKEN-*` bullet (not scanned by sync-gate walker). No column-0 anchor-shape risk at this iteration.
- **Issue Tracking:** Story 1.10 tracked at GitHub issue **#34**. `Refs #34` in every commit trailer; `Closes #34` lands in PR body only when Story 1.10 reaches `done` (matrix row 11). Parent Epic 1 issue **#9** — `Refs #9` optional; never `Closes` it (ralph.py transitions epic issues to Done on EPIC_DONE halt).
