# Implementation Plan

## NOW

- [ ] Run `/bmad-testarch-trace (args: "yolo")` — coverage gate (in-dev → traced); expect WAIVED per Story 1.7 iter-5 precedent (no test runner at substrate level; Zod parse at import-time IS the runtime check for AC 4; integration-level probing lands in Story 1.9) ~medium

## QUEUE (Story 1.8 — invariants-manifest-ts-contract-exporter)

- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (traced → sm-verified)
- [ ] Run `/bmad-code-review (args: "2")` — quality gate (sm-verified → done)
- [ ] After Story 1.8 done: `/bmad-create-story` for Story 1.9 (`invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`)

## BLOCKED

_(none)_

## DONE (Story 1.8 — spec authoring + pre-dev SM review + ATDD skip + dev-story)

- [x] Ralph-hosted `/bmad-create-story` — Story 1.8 spec authored at `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`; 3-task decomposition; sprint-status bumped `1-8: backlog → ready-for-dev`. Story State: `(no story) → drafted`.
- [x] Pre-dev SM review (iter-2; `drafted → validated` per FR14n matrix row 2). 9-check audit; one critical fix applied (architecture.md:922 hyphen→dot normalisation discharge note). Story State: `drafted → validated`.
- [x] FR14n ATDD-skip applied (iter-3; `validated → atdd-scaffolded` via matrix row 3 skip clause). Rationale pinned in spec + IP: AC 4 runtime validation covered end-to-end by Task 3 substrate smoke + no test runner at substrate level + Zod's upstream test suite covers shape correctness. Second application of the skip clause (Story 1.7 precedent). Story State: `validated → atdd-scaffolded`.
- [x] Ralph-hosted `/bmad-dev-story` (iter-4; `atdd-scaffolded → in-dev` per FR14n matrix row 4). All 3 Tasks landed: (1) authored `packages/keel-invariants/src/invariants.manifest.ts` (ESM TS, 9-entry `Invariant[]`, Zod schemas, import-time `InvariantsSchema.parse(raw)` validator) + `src/index.ts` re-export; (2) added `zod@3.25.76` runtime dep (3.x-line pin; skipped v4.x major — decision pinned in RALPH.md Decisions 2026-04-20); (3) full quality-gate bundle green (typecheck 16/16 / lint 16/16 / build 16/16 / format 0 / commitlint 0 / prek all Passed / runtime smoke `OK: 9 invariants`). Two dev-time findings fixed in-iteration: (a) `INV-no-verify-bypass` description rewritten to reference rule source rather than naming the flagged tokens inline (avoids ESLint self-reference collision; INVARIANTS.md kept verbatim since markdown is out of rule scope); (b) prettier auto-write on `invariants.manifest.ts`. Sprint-status bumped `1-8: ready-for-dev → done`. Story file Status flipped to `done`; Task checkboxes `[x]`; Dev Agent Record populated; Change Log v1.2 added. Story State: `atdd-scaffolded → in-dev`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.7 done; 1.8 in flight)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter`
- **Story:** 1.8 — invariants-manifest-ts-contract-exporter (PRD FR42; consumed by Story 1.9 sync-gate per FR43)
- **Story File:** `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`
- **Story State:** in-dev
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16)

## Notes

- Dev-story landed all 3 Tasks in one iteration (not partial) — Story State advances `atdd-scaffolded → in-dev` (fully, not `in-dev (partial)`).
- Issue Tracking: parent Epic 1 issue **#9**, Story 1.8 issue **#32**. Every commit carries `Refs #32` + `Refs #9` trailers; `Closes #32` reserved for PR body at EPIC_DONE transition.
