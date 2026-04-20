# Implementation Plan

## NOW

- [ ] **CR fix #3/6 [HIGH]** — "7 distinct source files" count correction. After iter-9 the authoritative count is **8 distinct `sourcePath` files** across 10 manifest entries (Task 2 added `docs/invariants/ralph-execute.md` as the 8th). Fix targets: story spec § Performance posture (story `1-9-…md` — grep for `7 distinct` and for `10 invariants dedupe to 7`); trace md "all 7 distinct `sourcePath` files exist on baseline" (enumerates 8 paths in the same sentence — self-contradicts); `1-9-coverage-matrix.json` verbatim quote `Baseline substrate = 7 distinct source files (10 invariants dedupe to 7)`; any RALPH.md iter-1/iter-4 narrative mentioning the "7" figure. Edit all occurrences to "8" / "10 invariants dedupe to 8". Same pattern as iter-9 (stream-channel): grep literal, align to authoritative side. ~small

## QUEUE (Story 1.9 — CR-iter-7 fix pass; 3 patches remaining + CR re-run)

- [ ] **CR fix #4/6 [HIGH]** — "two runtime smoke tests (clean + drift + performance path)" → current count is FIVE. Fix targets: story spec `1-9-…md` § Testing Standards rationale (b) + trace md + `1-9-coverage-matrix.json` verbatim quotes. Parenthetical originally enumerated three; cardinality word said two; iter-8 added TWO MORE smokes (AC 2 manifest-side missing-anchor + AC 5 docs-side orphan-anchor) for a current count of FIVE. Update all echoes to "five runtime smoke tests (clean + drift + performance + AC 2 manifest-side missing-anchor + AC 5 docs-side orphan-anchor)".
- [ ] **CR fix #5/6 [MEDIUM]** — Off-by-one line citations in trace bundle. `1-9-coverage-matrix.json` + `1-9-e2e-trace-summary.json` + trace md cite story lines 94, 95, 81, 117, 137, 140 but iter-4-dev-story actual lines were 95, 96, 82, 118, 138, 141 respectively (consistently +1). Note: iter-8 + iter-9 spec edits may shift line numbers further; re-anchor against post-iter-9 line numbers. Grep all `story file line NNN` / `line:NNN` citations across all four trace files and re-compute.
- [ ] **CR fix #6/6 [MEDIUM]** — Dev Agent Record AC-matrix entry for AC 2 currently reads "AC 2 (addition drift) — ✅ schema-level (manifest-side unique-id refine + anchor-walker's manifest-ID-membership check)". The id-uniqueness refine catches duplicate manifest IDs — NOT addition drift. Post-iter-8 truth: AC 2 is now end-to-end via iter-8 manifest-side missing-anchor smoke. Update entry to: "AC 2 (addition drift) — ✅ end-to-end via iter-8 Task-5 manifest-side missing-anchor smoke (delete `INV-commitlint-shared` anchor → exit 1 + `added-to-source-only` with sourcePath; revert; byte-identical restore) — anchor-side realisation per § Scope Carve-Out".
- [ ] After QUEUE empties, re-run `/bmad-code-review (args: "2")` adversarial triage against post-fix diff. Expected outcome per FR14n matrix row 10: zero findings → `fixes-pending → sm-verified → done` (single-transition edge per Story 1.7 iter-20 precedent). If new findings surface, queue new fix tasks.

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7/8/9 fix pass)

- [x] iter-7: `/bmad-code-review (args: "2")` Ralph-hosted three-layer fan-out — 6 patches + 10 defers + 3 dismissed. CRITICAL: `ANCHOR_REGEX` uppercase-class bug reproduced by Edge Case Hunter + Acceptance Auditor.
- [x] **iter-8: CR fix #1/6 [CRITICAL]** — `ANCHOR_REGEX` `[A-Z][A-Z0-9-]+` → `INV-[a-z0-9]+(?:-[a-z0-9]+)+` at `sync-gate.ts:24`; added symmetric `added-to-source-only` emitter to invariants loop (lines 59-66); spec echoes corrected at story lines 52/125/154 per spec-echoes-impl-bug carry-forward rule. Added 2 new Task-5 smokes (AC 5 docs-side orphan-anchor + AC 2 manifest-side missing-anchor); both green, both byte-identically revert-restored. Dev Agent Record AC 5 upgraded structural→end-to-end. All 6 quality gates re-green (typecheck 16/16 cached, lint 16/16, build 16/16 cached, format:check, commitlint 0/0 + 1 pre-existing warning, prek 3/3 Passed). All 5 smokes green (3 original re-verified + 2 new).
- [x] **iter-9: CR fix #2/6 [HIGH]** — AC 6 scope carve-out stream-channel prose `stdout → stderr` at story spec line 41 (two occurrences in that one bullet). Aligns prose with impl at `packages/keel-invariants/src/check.ts:9` (`process.stderr.write`) + the 7 other `stderr` echoes across Dev Agent Record + File List + trace md + coverage-matrix.json. Pure prose edit — zero code changes. Quality gates re-green: typecheck 16/16 cached, lint 16/16 cached, format:check 0. **Pattern corollary established:** the INVERSE class of iter-7's spec-echoes-impl-bug exists — spec-authoring-error diverging from correct-impl. Same grep-the-literal-across-all-artefacts fix mechanism; tie-break by picking the side that agrees with the majority of echoes (here: 7 stderr echoes vs 2 stdout echoes = stderr wins).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — 3 patches remaining)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on CR zero-findings outcome per matrix row 9.
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-8 fix #1 verified "spec-echoes-impl-bug" rule in practice; iter-9 fix #2 established the INVERSE corollary** — spec-authoring-error diverging from correct-impl (stdout → stderr at line 41). Same grep-the-literal fix mechanism; authoritative side = majority-of-echoes (7 stderr vs 2 stdout = stderr).
- **Fix #6's framing rewrite is now partially-discharged by iter-8 smokes.** The iter-8 AC 2 manifest-side smoke directly exercises the previously-unreachable anchor-side carve-out; fix #6's rewrite now has ground truth to cite (`end-to-end via iter-8 Task-5 manifest-side missing-anchor smoke`). Already reflected in the fix #6 task description above.
- **Remaining 3 fixes are all spec/trace-artefact edits** (no code changes). Budget-permitting batching: fix #3+#4 are both count-drift edits of the same cardinality-vs-enumeration class across overlapping file sets (story spec + trace bundle). Stick to one-per-iteration per IP contract unless budget pressure forces compression.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-9. Parent Epic 1 issue **#9** — `Refs #9` only.
