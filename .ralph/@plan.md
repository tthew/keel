# Implementation Plan

## NOW

- [ ] **CR fix #4/6 [HIGH]** — "two runtime smoke tests (clean + drift + performance path)" → current count is FIVE. Fix targets: story spec `1-9-…md` § Testing Standards rationale (b) + trace md + `1-9-coverage-matrix.json` verbatim quotes. Parenthetical originally enumerated three; cardinality word said two; iter-8 added TWO MORE smokes (AC 2 manifest-side missing-anchor + AC 5 docs-side orphan-anchor) for a current count of FIVE. Update all echoes to "five runtime smoke tests (clean + drift + performance + AC 2 manifest-side missing-anchor + AC 5 docs-side orphan-anchor)". ~small

## QUEUE (Story 1.9 — CR-iter-7 fix pass; 2 patches remaining + CR re-run)

- [ ] **CR fix #5/6 [MEDIUM]** — Off-by-one line citations in trace bundle. `1-9-coverage-matrix.json` + `1-9-e2e-trace-summary.json` + trace md cite story lines 94, 95, 81, 117, 137, 140 but iter-4-dev-story actual lines were 95, 96, 82, 118, 138, 141 respectively (consistently +1). Note: iter-8 + iter-9 + iter-10 spec edits may shift line numbers further; re-anchor against post-iter-10 line numbers. Grep all `story file line NNN` / `line:NNN` citations across all four trace files and re-compute.
- [ ] **CR fix #6/6 [MEDIUM]** — Dev Agent Record AC-matrix entry for AC 2 currently reads "AC 2 (addition drift) — ✅ schema-level (manifest-side unique-id refine + anchor-walker's manifest-ID-membership check)". The id-uniqueness refine catches duplicate manifest IDs — NOT addition drift. Post-iter-8 truth: AC 2 is now end-to-end via iter-8 manifest-side missing-anchor smoke. Update entry to: "AC 2 (addition drift) — ✅ end-to-end via iter-8 Task-5 manifest-side missing-anchor smoke (delete `INV-commitlint-shared` anchor → exit 1 + `added-to-source-only` with sourcePath; revert; byte-identical restore) — anchor-side realisation per § Scope Carve-Out".
- [ ] After QUEUE empties, re-run `/bmad-code-review (args: "2")` adversarial triage against post-fix diff. Expected outcome per FR14n matrix row 10: zero findings → `fixes-pending → sm-verified → done` (single-transition edge per Story 1.7 iter-20 precedent). If new findings surface, queue new fix tasks.

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7/8/9/10 fix pass)

- [x] iter-7: `/bmad-code-review (args: "2")` Ralph-hosted three-layer fan-out — 6 patches + 10 defers + 3 dismissed. CRITICAL: `ANCHOR_REGEX` uppercase-class bug reproduced by Edge Case Hunter + Acceptance Auditor.
- [x] **iter-8: CR fix #1/6 [CRITICAL]** — `ANCHOR_REGEX` `[A-Z][A-Z0-9-]+` → `INV-[a-z0-9]+(?:-[a-z0-9]+)+` at `sync-gate.ts:24`; added symmetric `added-to-source-only` emitter to invariants loop (lines 59-66); spec echoes corrected at story lines 52/125/154 per spec-echoes-impl-bug carry-forward rule. Added 2 new Task-5 smokes (AC 5 docs-side orphan-anchor + AC 2 manifest-side missing-anchor); both green, both byte-identically revert-restored. Dev Agent Record AC 5 upgraded structural→end-to-end. All 6 quality gates re-green (typecheck 16/16 cached, lint 16/16, build 16/16 cached, format:check, commitlint 0/0 + 1 pre-existing warning, prek 3/3 Passed). All 5 smokes green (3 original re-verified + 2 new).
- [x] **iter-9: CR fix #2/6 [HIGH]** — AC 6 scope carve-out stream-channel prose `stdout → stderr` at story spec line 41 (two occurrences in that one bullet). Aligns prose with impl at `packages/keel-invariants/src/check.ts:9` (`process.stderr.write`) + the 7 other `stderr` echoes across Dev Agent Record + File List + trace md + coverage-matrix.json. Pure prose edit — zero code changes. Quality gates re-green: typecheck 16/16 cached, lint 16/16 cached, format:check 0. **Pattern corollary established:** the INVERSE class of iter-7's spec-echoes-impl-bug exists — spec-authoring-error diverging from correct-impl. Same grep-the-literal-across-all-artefacts fix mechanism; tie-break by picking the side that agrees with the majority of echoes (here: 7 stderr echoes vs 2 stdout echoes = stderr wins).
- [x] **iter-10: CR fix #3/6 [HIGH]** — "7 distinct source files" → "8 distinct source files" + "10 invariants dedupe to 7" → "10 invariants dedupe to 8". 6 literal edits across 3 live artefacts: story spec line 130 § Performance posture (2 swaps in one sentence) + Dev Agent Record AC 3 line 141 + trace md line 116 (sentence was self-contradicting: "all 7 distinct" vs enumerated 8 paths) + trace md line 171 Shared-source dedup + coverage-matrix.json line 49 (AC-3 substrate_verification) + coverage-matrix.json line 90 (AC-7 scope_notes). Authoritative count confirmed against `packages/keel-invariants/src/invariants.manifest.ts` — 10 manifest entries, 8 distinct sourcePaths (`eslint.config.keel-invariants.js` and `.pre-commit-config.yaml` each host two invariants by shared-source design). Story 1.8 spec line 226's "7 distinct" stays unedited — it reflects Story 1.8's historically-correct 9-invariant substrate. RALPH.md iter-1 line 41's "7" also stays unedited per historical-journal-integrity rule. Quality gates re-green: format:check 0, typecheck 16/16 cached, lint 16/16 cached. JSON re-validated. Pure prose — zero code changes.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — 2 patches remaining)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on CR zero-findings outcome per matrix row 9.
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-10 extended the "historical-journal-integrity" discipline** — RALPH.md entries written at iter-N record what-was-believed-at-iter-N and are NOT retroactively edited even when subsequent reality diverges. Live artefacts (spec, trace, coverage-matrix) MUST reflect current state; journal entries are snapshots. iter-1's line-41 "substrate has 7 distinct source files after dedup" was stale-at-authoring (spec added the 10th entry as Task 2; 10→8-sourcePaths was foreseeable) but the journal convention still holds — a later iteration's diverged-reality note goes into a new journal entry, not a retroactive edit. Next Ralph: when CR flags RALPH.md historical narratives as drift, the fix is a forward-looking annotation, not a retroactive edit.
- **Pattern triple-confirmation:** iter-8 spec-echoes-impl-bug carry-forward (spec literal copied impl typo) + iter-9 spec-authoring-error vs correct-impl (majority-of-echoes tie-break) + iter-10 count-drift across live artefacts (spec pre-Task-2 figure never refreshed post-Task-2). All three share the "grep the literal across every artefact and align to the authoritative side" mechanism; the tie-break rule differs per class (iter-8 = impl is authoritative if bug is in impl; iter-9 = majority-of-echoes wins; iter-10 = current ground truth wins over stale snapshot).
- **Remaining 2 fixes are all spec/trace-artefact edits** (no code changes). fix #5 requires re-anchoring post-iter-10 line numbers (my iter-10 edits shifted trace md line 116's wording slightly; story spec line 130/141 stay at current line numbers since edits were in-place single-word swaps). Stick to one-per-iteration per IP contract.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-10. Parent Epic 1 issue **#9** — `Refs #9` only.
