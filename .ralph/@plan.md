# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — pre-dev validation of Story 1.8 spec (drafted → validated) ~small

## QUEUE (Story 1.8 — invariants-manifest-ts-contract-exporter)

- [ ] Run `/bmad-testarch-atdd` — red-phase scaffolds (validated → atdd-scaffolded); likely skip-to-in-dev since AC 4 is validated by Task 3's runtime smoke (no separate runner-probe needed)
- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md")` — implement Tasks 1–3 (atdd-scaffolded → in-dev)
- [ ] Run `/bmad-testarch-trace (args: "yolo")` — coverage gate (in-dev → traced); expect WAIVED per Story 1.7 iter-5 precedent (no test runner; Zod parse IS the runtime check)
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (traced → sm-verified)
- [ ] Run `/bmad-code-review (args: "2")` — quality gate (sm-verified → done)
- [ ] After Story 1.8 done: `/bmad-create-story` for Story 1.9 (`invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`)

## BLOCKED

_(none)_

## DONE (Story 1.8 — spec authoring)

- [x] Ralph-hosted `/bmad-create-story` — Story 1.8 spec authored at `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`; 3-task decomposition (Task 1 `invariants.manifest.ts` contract + 9-entry data + architecture.md:922 dot-form normalisation; Task 2 zod dep + import-time validation; Task 3 quality gates + sprint-status bump). Sprint-status bumped `1-8: backlog → ready-for-dev` with `last_updated: 2026-04-20 Story-1-8-spec UTC`. Story State: `(no story) → drafted`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.7 done; 1.8 in flight)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter`
- **Story:** 1.8 — invariants-manifest-ts-contract-exporter (PRD FR42; consumed by Story 1.9 sync-gate per FR43)
- **Story File:** `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`
- **Story State:** drafted

## Notes

- Spec authored inline (Ralph-hosted) per Stories 1.6/1.7 precedent — `/bmad-create-story` skill would HITL-halt on user-input checkpoints; Ralph uses the skill's `template.md` + prior-story skeleton as the authoring template.
- Architecture.md:922 hyphen→dot normalisation carried the Story 1.7 iter-20 deferred finding into a Task-1 subtask (not a separate story) — single-character correction, not behavioural.
- Issue Tracking: parent Epic 1 issue **#9**, Story 1.8 issue **#32**. Every commit carries `Refs #32` + `Refs #9` trailers; `Closes #32` reserved for PR body at EPIC_DONE transition.
