# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story` — pick up Story 1.9 (`invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`) from sprint-status ~medium

## QUEUE (Story 1.9 — invariant-sync-gate-runtime-tooling-reader-walker-drift-detector)

_(none — next story drives the next iteration's QUEUE per FR14n Story Lifecycle Decision Matrix)_

## BLOCKED

_(none)_

## DONE (Story 1.8 — spec + pre-dev SM + ATDD skip + dev-story + trace + post-dev SM + CR)

- [x] Ralph-hosted `/bmad-create-story` — Story 1.8 spec authored at `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`; 3-task decomposition; sprint-status bumped `1-8: backlog → ready-for-dev`. Story State: `(no story) → drafted`.
- [x] Pre-dev SM review (iter-2; `drafted → validated` per FR14n matrix row 2). 9-check audit; one critical fix applied (architecture.md:922 hyphen→dot normalisation discharge note). Story State: `drafted → validated`.
- [x] FR14n ATDD-skip applied (iter-3; `validated → atdd-scaffolded` via matrix row 3 skip clause). Three-prong rationale: (a) substrate-verification-covers-AC 4 end-to-end + (b) no test runner at substrate level + (c) Zod upstream test suite covers schema shape. Second application of the skip clause (Story 1.7 precedent). Story State: `validated → atdd-scaffolded`.
- [x] Ralph-hosted `/bmad-dev-story` (iter-4; `atdd-scaffolded → in-dev` per FR14n matrix row 4). All 3 Tasks landed: (1) authored `packages/keel-invariants/src/invariants.manifest.ts` (ESM TS, 9-entry `Invariant[]`, Zod schemas, import-time `InvariantsSchema.parse(raw)`) + `src/index.ts` re-export; (2) added `zod@3.25.76` runtime dep (3.x-line pin; skipped v4.x); (3) full quality-gate bundle green (typecheck/lint/build 16/16 / format 0 / commitlint 0 / prek all Passed / runtime smoke `OK: 9 invariants`). Two dev-time findings fixed in-iteration. Sprint-status bumped `1-8: ready-for-dev → done`. Story State: `atdd-scaffolded → in-dev`.
- [x] Ralph-hosted `/bmad-testarch-trace (args: "yolo")` (iter-5; `in-dev → traced` per FR14n matrix row 5). Oracle: formal requirements (4 ACs, all P2). Coverage: 0% automated (structural — no test runner at substrate; Story 1.16 scope). Substrate verification: 7 quality gates green + Task 3 runtime smoke `OK: 9 invariants` exercised AC 4 end-to-end. **Gate: WAIVED 🔓** — second consecutive Epic 1 substrate-stage WAIVED (1.7 + 1.8); FR14n ATDD-skip precedent (iter-3) now load-bearing through the trace gate. Zero coverage gaps queued as fix tasks (all four P2 gaps explicitly scoped-out to Story 1.9 + Story 1.16). Story State: `in-dev → traced`.
- [x] Post-dev SM review (iter-6; `traced → sm-verified` per FR14n matrix row 7). AC-by-AC requirements-satisfaction audit against live implementation: AC 1 ✓ `invariants: Invariant[]` exported (invariants.manifest.ts:89); AC 2 ✓ Zod-enforced id regex + 9/9 sourcePaths verified on disk + 9/9 sha256 contentHashes re-computed and matched (whole-file carve-out intact); AC 3 ✓ contract side delivered (`Invariant` type + 9-entry canonical list), enforcement carved to Story 1.9; AC 4 ✓ synchronous top-level `InvariantsSchema.parse(raw)` + runtime smoke via `import('@keel/keel-invariants')` returns `9 invariants` + `InvariantSchema` exported. **Outcome: zero unmet-AC findings, zero fix tasks queued** (all four scope carve-outs flow through cleanly from the story spec). Story File v1.3 changelog entry added. Story State: `traced → sm-verified`.
- [x] Ralph-hosted `/bmad-code-review (args: "2")` (iter-7; `sm-verified → done` per FR14n matrix row 9). Three parallel adversarial layers: Blind Hunter (16 findings) + Edge Case Hunter (15 findings) + Acceptance Auditor (**zero AC violations** — all 9 contentHashes re-verified vs on-disk sha256). Triage: **0 decision-needed, 0 patches, 6 defers, 19 dismissed.** Defers written to `_bmad-output/implementation-artifacts/deferred-work.md § Deferred from: code review of story-1.8 (2026-04-20)`: contentHash drift validation + sourcePath traversal guard + id uniqueness refine + cross-entry hash consistency refine (all Story 1.9 enforcement-side scope per FR43 § Scope Carve-Out) + readonly/freeze + schema-evolution metadata (spec-silent hardening). **Precedent: Epic-1-substrate contract-only stories complete `sm-verified → done` in a single CR iteration with zero patches** (contrast Story 1.7 which needed 4 CR cycles on docs + 1.3–1.6 which were single-pass). Story File v1.4 changelog entry added; § Review Findings subsection written. Story State: `sm-verified → done`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 next)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (carries forward to Story 1.9 via fresh sub-branch per §FR14m single-PR-per-story or continue on same branch — decision at iter-8 spec-authoring time)
- **Story:** _(no story — next `/bmad-create-story` picks Story 1.9 from sprint-status)_
- **Story File:** _n/a_
- **Story State:** _(no story)_
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16; stays Draft through Epic 1 per PR Lifecycle Decision Matrix; Draft→Open transition is an EPIC_DONE-gated ritual)

## Notes

- **Story 1.8 complete** — twin WAIVED-trace + zero-unmet-AC SM + zero-patch CR confirms the Epic-1-substrate contract-only pattern: ATDD-skip (iter-3) + trace WAIVED (iter-5) + zero-unmet SM (iter-6) + zero-patch CR (iter-7). Story 1.7 was 4-CR-cycles and sets the **upper** envelope; Story 1.8 is single-pass and sets the **lower**. Expect Story 1.9 (sync-gate enforcement side) to trend closer to 1.7 given it introduces runtime behaviour (walker + reader + drift-detector) that substrate-verification cannot cover — ATDD skip will likely NOT apply there.
- **Story 1.9 carries forward six defers from Story 1.8 CR** — all six are natural-fit for the sync-gate's enforcement surface: contentHash drift validation, sourcePath traversal guard, id uniqueness refine, cross-entry hash consistency refine (these four are literally Story 1.9's scope per FR43 § Scope Carve-Out), + two spec-silent hardening items (readonly/freeze, schema-evolution metadata). Ralph authoring Story 1.9's spec at iter-8 should absorb these into AC definitions and task-decomposition rather than re-surface them as late-stage CR findings.
- Issue Tracking: Story 1.8 issue **#32** — `Closes #32` reserved for PR body at EPIC_DONE transition (not for this iter's commit). Story 1.9 issue number TBD at iter-8 `/bmad-create-story` time (ralph.py issue-linking module creates one per FR42-adjacent GH-project-tracking flow). Parent Epic 1 issue **#9** — remains `Refs` only; closed by ralph.py EPIC_DONE halt handler when Epic 1 completes.
