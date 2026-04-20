# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (traced → sm-verified) ~medium

## QUEUE (Story 1.8 — invariants-manifest-ts-contract-exporter)

- [ ] Run `/bmad-code-review (args: "2")` — quality gate (sm-verified → done)
- [ ] After Story 1.8 done: `/bmad-create-story` for Story 1.9 (`invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`)

## BLOCKED

_(none)_

## DONE (Story 1.8 — spec + pre-dev SM + ATDD skip + dev-story + trace)

- [x] Ralph-hosted `/bmad-create-story` — Story 1.8 spec authored at `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`; 3-task decomposition; sprint-status bumped `1-8: backlog → ready-for-dev`. Story State: `(no story) → drafted`.
- [x] Pre-dev SM review (iter-2; `drafted → validated` per FR14n matrix row 2). 9-check audit; one critical fix applied (architecture.md:922 hyphen→dot normalisation discharge note). Story State: `drafted → validated`.
- [x] FR14n ATDD-skip applied (iter-3; `validated → atdd-scaffolded` via matrix row 3 skip clause). Three-prong rationale: (a) substrate-verification-covers-AC 4 end-to-end + (b) no test runner at substrate level + (c) Zod upstream test suite covers schema shape. Second application of the skip clause (Story 1.7 precedent). Story State: `validated → atdd-scaffolded`.
- [x] Ralph-hosted `/bmad-dev-story` (iter-4; `atdd-scaffolded → in-dev` per FR14n matrix row 4). All 3 Tasks landed: (1) authored `packages/keel-invariants/src/invariants.manifest.ts` (ESM TS, 9-entry `Invariant[]`, Zod schemas, import-time `InvariantsSchema.parse(raw)`) + `src/index.ts` re-export; (2) added `zod@3.25.76` runtime dep (3.x-line pin; skipped v4.x); (3) full quality-gate bundle green (typecheck/lint/build 16/16 / format 0 / commitlint 0 / prek all Passed / runtime smoke `OK: 9 invariants`). Two dev-time findings fixed in-iteration. Sprint-status bumped `1-8: ready-for-dev → done`. Story State: `atdd-scaffolded → in-dev`.
- [x] Ralph-hosted `/bmad-testarch-trace (args: "yolo")` (iter-5; `in-dev → traced` per FR14n matrix row 5). Oracle: formal requirements (4 ACs, all P2). Coverage: 0% automated (structural — no test runner at substrate; Story 1.16 scope). Substrate verification: 7 quality gates green + Task 3 runtime smoke `OK: 9 invariants` exercised AC 4 end-to-end. **Gate: WAIVED 🔓** — second consecutive Epic 1 substrate-stage WAIVED (1.7 + 1.8); FR14n ATDD-skip precedent (iter-3) now load-bearing through the trace gate. Artefacts: `1-8-coverage-matrix.json`, `1-8-e2e-trace-summary.json`, `1-8-gate-decision.json`, `1-8-invariants-manifest-ts-contract-exporter.md` under `_bmad-output/test-artifacts/traceability/`. Zero coverage gaps queued as fix tasks (all four P2 gaps explicitly scoped-out to Story 1.9 + Story 1.16 per story file § Testing Standards + inline AC scope carve-outs). Story State: `in-dev → traced`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.7 done; 1.8 in flight)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter`
- **Story:** 1.8 — invariants-manifest-ts-contract-exporter (PRD FR42; consumed by Story 1.9 sync-gate per FR43)
- **Story File:** `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`
- **Story State:** traced
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16)

## Notes

- Trace gate WAIVED with zero fix tasks queued — all 4 ACs' coverage gaps are explicitly scoped-out by the story's own § Testing Standards + inline AC carve-outs. Next iteration proceeds straight to post-dev SM verification (no QUEUE-empty re-run of trace needed; rationale: this is a WAIVED outcome, not a PASS-with-pending-gaps).
- Issue Tracking: parent Epic 1 issue **#9**, Story 1.8 issue **#32**. Every commit carries `Refs #32` + `Refs #9` trailers; `Closes #32` reserved for PR body at EPIC_DONE transition.
