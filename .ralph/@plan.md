# Implementation Plan

## NOW

- [ ] Run `/bmad-code-review (args: "2")` — adversarial CR with "Create action items" pre-selected. FR14n matrix row 9: `sm-verified → done` (no findings) OR `sm-verified → fixes-pending` (CR surfaces action items → one per iteration). ~medium

## QUEUE (Story 1.10 — design-token schema, semantic + rationale contract)

_(empty — CR outcome at iter-50 determines whether Story 1.10 closes as `done` or enters `fixes-pending` loop)_

## BLOCKED

_(none)_

## DONE (Story 1.10 — iter-49 SM re-verify)

- [x] iter-49: **Post-dev SM re-verify; FR14n state `sm-fixes-pending → sm-verified`.** Re-ran `/bmad-create-story (args: "review")` to confirm iter-48's Fix SM-1 discharged the sole § Review Findings item. Per-AC re-attestation: AC 1/2/4 unchanged since iter-47 (schema + manifest + anchor-bullets all pre-existing green); AC 3 now green — `### Font` section present at `docs/invariants/tokens.md:149` with role-intro paragraph + `TOKEN-font-{name}` group-level bullet enumerating `TOKEN-font-sans` + `TOKEN-font-mono`, mirroring Neutral primitive-ramp pattern permitted by Task 2; schema `fontGroup` at `packages/ui/tokens.schema.json:249-257` now has full cross-link parity back to rationale doc. AC 4 re-verified at byte level: `sha256sum docs/invariants/tokens.md` = `efd5fa0d84d3478cd4af530f3cc57c734f9b4e23415d0c7085fb8e6296d1a82c`, matches `INV-tokens-semantic-rationale.contentHash` at manifest line 141; `pnpm keel-invariants:check` clean-path exit 0. § Review Findings all checkboxes `[x]` (SM-1 discharged iter-48; no new findings surfaced). No source-code changes (verification-only iteration); no drift-smokes re-run (iter-45's comprehensive drift-path evidence remains load-bearing). Story file Change Log v1.5 row appended. PR #226 CI: `no checks reported`; push safe. Tracked at GitHub issue #34 — `Refs #34` in commit trailer.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.9 done; 1.10 `sm-verified` awaiting iter-50 CR; 1.11–1.16 backlog → 6 more stories × full FR14n lifecycle remaining after 1.10 closure before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** 1.10 — design-token schema, semantic + rationale contract
- **Story File:** `_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md`
- **Story State:** `sm-verified` — iter-49 discharged the SM gate after iter-48's Fix SM-1 proved clean on re-verify. Next iteration runs `/bmad-code-review (args: "2")` per FR14n matrix row 9.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Story 1.10 positioning.** First of 4 design-token-pipeline stories in Epic 1 (1.10 schema+rationale contract → 1.11 source population Direction A → 1.12 emitter pipeline → 1.13 quality gates). Contract-only single-pass SM hypothesis was partially falsified at iter-47 (1 MEDIUM finding vs. Story 1.8 iter-5 zero-findings); fix was ~small (single prose insert + single hash bump); SM layer closed in two rounds (iter-47 review + iter-48 fix + iter-49 re-verify). CR hypothesis (iter-7 Decisions: contract-only-trends-single-pass-CR) resolves at iter-50: zero-finding CR would keep the hypothesis intact at the CR layer (SM had the novel structural miss; CR auditors check correctness not completeness).
- **Trace posture.** Gate WAIVED (fourth cumulative — 1.7 iter-5 + 1.8 iter-5 + 1.9 iter-8 + 1.10 iter-46). Seven-point rationale pinned at iter-46 trace artefacts; unchanged by iter-48's prose-only fix or iter-49's verification-only re-verify.
- **Post-iter-49 audit trail.** Only one file touched: `_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md` — Change Log v1.5 row appended documenting the `sm-fixes-pending → sm-verified` transition. Zero schema, rationale-doc, manifest, or runtime-code changes. Quality gate evidence: `pnpm keel-invariants:check` exit 0 re-confirmed during re-verify (sync-gate still detects no drift post iter-48 hash update).
- **Anchor regex landmines avoided** (Story 1.9 CR defer carry-forward — `deferred-work.md:37-38`): iter-49 added no new `INV-*` anchors; pure verification. No column-0 anchor-shape risk at this iteration.
- **Issue Tracking:** Story 1.10 tracked at GitHub issue **#34**. `Refs #34` in every commit trailer; `Closes #34` lands in PR body only when Story 1.10 reaches `done` (matrix row 11) — iter-50 CR outcome determines whether iter-50 is the `done` transition or opens a `fixes-pending` loop. Parent Epic 1 issue **#9** — `Refs #9` optional; never `Closes` it (ralph.py transitions epic issues to Done on EPIC_DONE halt).
