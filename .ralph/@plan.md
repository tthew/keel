# Implementation Plan

## NOW

- [ ] **CR fix #2/6 [HIGH]** — AC 6 spec stream-channel correction: `_bmad-output/implementation-artifacts/1-9-…md:41` currently says "structured JSON report on stdout" / "structured JSON report on stdout"; impl at `packages/keel-invariants/src/check.ts:9` writes `process.stderr.write`, and Dev Agent Record + File List + trace md + coverage-matrix.json all say "stderr" (8 occurrences). Fix spec line 41 `stdout → stderr` (two occurrences in that one prose bullet) to align spec with reality — minimal-edit over the alternative of flipping impl + 8 trace citations. ~small

## QUEUE (Story 1.9 — CR-iter-7 fix pass; 4 patches remaining + CR re-run)

- [ ] **CR fix #3/6 [HIGH]** — "7 distinct source files" count correction in § Performance posture of story spec `1-9-…md:128` + trace md "all 7 distinct `sourcePath` files exist on baseline" (enumerates 8 paths in the same sentence) + coverage-matrix.json at `Baseline substrate = 7 distinct source files (10 invariants dedupe to 7)` + any RALPH.md iter-1/iter-4 narrative mentioning "7". Actual count: **8 distinct `sourcePath` files** across 10 manifest entries (Task 2 added `docs/invariants/ralph-execute.md` as the 8th).
- [ ] **CR fix #4/6 [HIGH]** — "two runtime smoke tests (clean + drift + performance path)" → "three" in story spec `1-9-…md:118` § Testing Standards rationale (b) + trace md + coverage-matrix.json verbatim quotes. Parenthetical enumerates three; cardinality word says two. Note: iter-8 added TWO MORE smokes (AC 2 + AC 5), so the count is now FIVE — update all echoes accordingly.
- [ ] **CR fix #5/6 [MEDIUM]** — Off-by-one line citations in trace bundle. `1-9-coverage-matrix.json` + `1-9-e2e-trace-summary.json` + trace md cite story lines 94, 95, 81, 117, 137, 140 but actual lines are 95, 96, 82, 118, 138, 141 respectively (consistently +1). Grep all `story file line NNN` / `line:NNN` citations across all four trace files and re-anchor. Note: iter-8's spec edits may shift line numbers further; re-anchor against post-iter-8 line numbers.
- [ ] **CR fix #6/6 [MEDIUM]** — Dev Agent Record AC-matrix entry for AC 2 at story `1-9-…md:138` currently reads "AC 2 (addition drift) — ✅ schema-level (manifest-side unique-id refine + anchor-walker's manifest-ID-membership check)". The id-uniqueness refine catches duplicate manifest IDs — NOT addition drift. Post-iter-8 truth: AC 2 is now end-to-end via iter-8 manifest-side missing-anchor smoke. Update entry to: "AC 2 (addition drift) — ✅ end-to-end via iter-8 Task-5 manifest-side missing-anchor smoke (delete `INV-commitlint-shared` anchor → exit 1 + `added-to-source-only` with sourcePath; revert; byte-identical restore) — anchor-side realisation per § Scope Carve-Out".
- [ ] After QUEUE empties, re-run `/bmad-code-review (args: "2")` adversarial triage against post-fix diff. Expected outcome per FR14n matrix row 10: zero findings → `fixes-pending → sm-verified → done` (single-transition edge per Story 1.7 iter-20 precedent). If new findings surface, queue new fix tasks.

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7/8 fix pass)

- [x] iter-7: `/bmad-code-review (args: "2")` Ralph-hosted three-layer fan-out — 6 patches + 10 defers + 3 dismissed. CRITICAL: `ANCHOR_REGEX` uppercase-class bug reproduced by Edge Case Hunter + Acceptance Auditor.
- [x] **iter-8: CR fix #1/6 [CRITICAL]** — `ANCHOR_REGEX` `[A-Z][A-Z0-9-]+` → `INV-[a-z0-9]+(?:-[a-z0-9]+)+` at `sync-gate.ts:24`; added symmetric `added-to-source-only` emitter to invariants loop (lines 59-66); spec echoes corrected at story lines 52/125/154 per spec-echoes-impl-bug carry-forward rule. Added 2 new Task-5 smokes (AC 5 docs-side orphan-anchor + AC 2 manifest-side missing-anchor); both green, both byte-identically revert-restored. Dev Agent Record AC 5 upgraded structural→end-to-end. All 6 quality gates re-green (typecheck 16/16 cached, lint 16/16, build 16/16 cached, format:check, commitlint 0/0 + 1 pre-existing warning, prek 3/3 Passed). All 5 smokes green (3 original re-verified + 2 new).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — 4 patches remaining)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on CR zero-findings outcome per matrix row 9.
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-8 fix #1 landing verifies "spec-echoes-impl-bug" carry-forward rule in practice.** The CRITICAL bug manifested at both spec line 52 (authoring guidance regex literal) and impl line 24 (copied verbatim by dev-story). Fix lands in BOTH locations + 2 further spec echoes (lines 125, 154) in the same commit. Next CR re-run after QUEUE empties should NOT re-surface this finding if the spec-echoes are cleanly synchronised.
- **Fix #6's framing rewrite is now partially-discharged by iter-8 smokes.** The iter-8 AC 2 manifest-side smoke directly exercises the previously-unreachable anchor-side carve-out; fix #6's rewrite of line 138 now has ground truth to cite (`end-to-end via iter-8 Task-5 manifest-side missing-anchor smoke`). Already reflected in the fix #6 task description above.
- **Remaining 4 fixes are all spec/trace-artefact edits** (no code changes). Should compress — possibly batch into 2 commits (fix #2+#3 stream-channel + count-drift in spec; fix #4+#5 trace bundle + counts) — but IP contract is one-per-iteration. Stick to the per-iteration discipline unless budget pressure forces compression.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-8. Parent Epic 1 issue **#9** — `Refs #9` only.
