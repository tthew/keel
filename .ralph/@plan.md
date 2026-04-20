# Implementation Plan

## NOW

- [ ] Run `/bmad-code-review (args: "2")` — quality gate (sm-verified → done) ~medium

## QUEUE (Story 1.8 — invariants-manifest-ts-contract-exporter)

- [ ] After Story 1.8 done: `/bmad-create-story` for Story 1.9 (`invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`)

## BLOCKED

_(none)_

## DONE (Story 1.8 — spec + pre-dev SM + ATDD skip + dev-story + trace + post-dev SM)

- [x] Ralph-hosted `/bmad-create-story` — Story 1.8 spec authored at `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`; 3-task decomposition; sprint-status bumped `1-8: backlog → ready-for-dev`. Story State: `(no story) → drafted`.
- [x] Pre-dev SM review (iter-2; `drafted → validated` per FR14n matrix row 2). 9-check audit; one critical fix applied (architecture.md:922 hyphen→dot normalisation discharge note). Story State: `drafted → validated`.
- [x] FR14n ATDD-skip applied (iter-3; `validated → atdd-scaffolded` via matrix row 3 skip clause). Three-prong rationale: (a) substrate-verification-covers-AC 4 end-to-end + (b) no test runner at substrate level + (c) Zod upstream test suite covers schema shape. Second application of the skip clause (Story 1.7 precedent). Story State: `validated → atdd-scaffolded`.
- [x] Ralph-hosted `/bmad-dev-story` (iter-4; `atdd-scaffolded → in-dev` per FR14n matrix row 4). All 3 Tasks landed: (1) authored `packages/keel-invariants/src/invariants.manifest.ts` (ESM TS, 9-entry `Invariant[]`, Zod schemas, import-time `InvariantsSchema.parse(raw)`) + `src/index.ts` re-export; (2) added `zod@3.25.76` runtime dep (3.x-line pin; skipped v4.x); (3) full quality-gate bundle green (typecheck/lint/build 16/16 / format 0 / commitlint 0 / prek all Passed / runtime smoke `OK: 9 invariants`). Two dev-time findings fixed in-iteration. Sprint-status bumped `1-8: ready-for-dev → done`. Story State: `atdd-scaffolded → in-dev`.
- [x] Ralph-hosted `/bmad-testarch-trace (args: "yolo")` (iter-5; `in-dev → traced` per FR14n matrix row 5). Oracle: formal requirements (4 ACs, all P2). Coverage: 0% automated (structural — no test runner at substrate; Story 1.16 scope). Substrate verification: 7 quality gates green + Task 3 runtime smoke `OK: 9 invariants` exercised AC 4 end-to-end. **Gate: WAIVED 🔓** — second consecutive Epic 1 substrate-stage WAIVED (1.7 + 1.8); FR14n ATDD-skip precedent (iter-3) now load-bearing through the trace gate. Artefacts: `1-8-coverage-matrix.json`, `1-8-e2e-trace-summary.json`, `1-8-gate-decision.json`, `1-8-invariants-manifest-ts-contract-exporter.md` under `_bmad-output/test-artifacts/traceability/`. Zero coverage gaps queued as fix tasks (all four P2 gaps explicitly scoped-out to Story 1.9 + Story 1.16 per story file § Testing Standards + inline AC scope carve-outs). Story State: `in-dev → traced`.
- [x] Post-dev SM review (iter-6; `traced → sm-verified` per FR14n matrix row 7). AC-by-AC requirements-satisfaction audit against live implementation: AC 1 ✓ `invariants: Invariant[]` exported (invariants.manifest.ts:89); AC 2 ✓ Zod-enforced id regex + 9/9 sourcePaths verified on disk + 9/9 sha256 contentHashes re-computed and matched (whole-file carve-out intact); AC 3 ✓ contract side delivered (`Invariant` type + 9-entry canonical list), enforcement carved to Story 1.9; AC 4 ✓ synchronous top-level `InvariantsSchema.parse(raw)` + runtime smoke via `import('@keel/keel-invariants')` returns `9 invariants` + `InvariantSchema` exported. **Outcome: zero unmet-AC findings, zero fix tasks queued** (all four scope carve-outs flow through cleanly from the story spec). Story File v1.3 changelog entry added. Story State: `traced → sm-verified`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.7 done; 1.8 in flight)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter`
- **Story:** 1.8 — invariants-manifest-ts-contract-exporter (PRD FR42; consumed by Story 1.9 sync-gate per FR43)
- **Story File:** `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`
- **Story State:** sm-verified
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16)

## Notes

- Post-dev SM review emerged cleanly (zero unmet ACs, zero fix tasks) — the twin WAIVED-trace precedent (Stories 1.7 + 1.8 substrate) is reinforced: contract-only stories with explicit scope carve-outs land SM-review in one iteration. Expect same shape at Story 1.9's SM gate once enforcement lands.
- Next iteration: `/bmad-code-review (args: "2")` — sole remaining Story 1.8 gate. Expected shape: adversarial triage finds 0–2 action items (Epic 1 substrate stories have trended low-CR-yield; Story 1.7 needed 4 CR cycles, Stories 1.3–1.6 were single-pass).
- Issue Tracking: parent Epic 1 issue **#9**, Story 1.8 issue **#32**. Every commit carries `Refs #32` + `Refs #9` trailers; `Closes #32` reserved for PR body at EPIC_DONE transition.
