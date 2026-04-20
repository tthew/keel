# Implementation Plan

## NOW

- [ ] Fix B/4 [HIGH] — stale "Not exercised in smoke" AC-5 framing (iter-8 smoke upgrade not propagated to trace narrative). Edit 3 sites: trace md:143 (AC-5 mapping bullet) + trace md:260 (Happy-Path-Only section) + coverage-matrix.json:69 AC-5 substrate_verification (the "Not exercised in smoke" tail of the field now that Fix A re-cased the regex). Leave AC-3 equivalents unchanged (trace md:116 + coverage-matrix.json:49) — iter-8 did NOT add an AC-3 smoke; only AC-2 + AC-5. Pure prose — zero code changes. ~small

## QUEUE (Story 1.9 — CR iter-14 re-run surfaced 3 new fix tasks + 4 defers; stays `fixes-pending` until QUEUE empties → re-run CR)

- [ ] Fix C/4 [HIGH + MEDIUM] — count drift "three smokes" → "five smokes" + "AC 1+4+7 only" → "AC 1+2+4+5+7" across ~13 sites (iter-11 narrow-scope pre-announced). Target inventory:
  - spec:120 (trailing "AC 1 / AC 4 / AC 7 fully covered at the shell-invocation level" — iter-11 patched opening "five" but left closing AC-list stale = internal self-contradiction)
  - spec:149 ("three smoke tests materially cover 4 of 7 ACs end-to-end; remaining 3 are schema-level" — iter-4 dev-story phrasing, now 5 smokes cover 5 of 7 ACs; AC-3 + AC-6 remain schema/structural)
  - trace md:307 + 349 + 436 + 465 + 526 + 555 + 583 + 614 (8 sites with "three" / "3 runtime smoke tests" / "AC-1 + AC-4 + AC-7 end-to-end")
  - coverage-matrix.json:160 + e2e-trace-summary.json:73 (2 sites with "Task 5 shell-invocation smoke tests already cover AC-1 + AC-4 + AC-7 end-to-end")
  - gate-decision.json:12 (rationale: "Task 5's three shell-invocation smoke tests exercised AC 1 + AC 4 + AC 7 end-to-end … AC 2 / AC 3 / AC 5 realised schema-level" — AC-2 + AC-5 now end-to-end post-iter-8; only AC-3 remains schema+structural). Pure prose — zero code changes. ~medium
- [ ] Re-run `/bmad-code-review (args: "2")` CR adversarial triage against post-Fix-A/B/C diff. Expected outcome per FR14n matrix row 10: zero Blind Hunter findings → `fixes-pending → sm-verified → done` (single-transition edge). If new findings surface, queue fix tasks; stay `fixes-pending`. ~medium

## BLOCKED

_(none)_

## DONE (Story 1.9 — CR iter-7 through iter-15)

- [x] iter-7: `/bmad-code-review (args: "2")` Ralph-hosted three-layer fan-out — 6 patches + 10 defers + 3 dismissed. CRITICAL: `ANCHOR_REGEX` uppercase-class bug reproduced by Edge Case Hunter + Acceptance Auditor.
- [x] iter-8 through iter-13: 6 CR fix patches landed — (1) CRITICAL `ANCHOR_REGEX` uppercase→lowercase + symmetric `added-to-source-only` emitter + 2 new Task-5 smokes + spec echoes; (2) HIGH spec line 41 stdout→stderr; (3) HIGH count 7→8 sourcePath files; (4) HIGH count 2→5 runtime smokes (narrow-scope per iter-11); (5) MEDIUM trace-bundle line citations re-anchored (31 edits); (6) MEDIUM Dev Agent Record AC 2 status prose upgraded schema→end-to-end.
- [x] iter-14: `/bmad-code-review (args: "2")` CR RE-RUN — 3-layer Ralph-hosted fan-out against post-fix diff. Verdicts: Blind Hunter NEW_FINDINGS (3 HIGH trace residue + 1 MEDIUM spec self-contradiction → queued as Fix A/B/C); Edge Case Hunter MINOR_ONLY (4 LOWs → defers); Acceptance Auditor PASS (all 7 AC with live repros). Impl CLEAN; trace-narrative STALE. **New pattern established: trace-bundle semantic-drift from impl-upgrade** — when a later iter upgrades AC coverage (here iter-8's Task-5 smoke additions), the trace bundle's "Happy-Path-Only" + "Not exercised in smoke" + smoke-count + AC-coverage-list semantics must be refreshed at the SAME commit as the upgrade. Adversarial triage: 3 patch (A/B/C) + 4 defer (2 new + 2 reconfirmed) + 0 dismissed.
- [x] **iter-15: Fix A/4 [HIGH] landing — stale UPPERCASE regex echo swap at 2 trace-bundle sites.** Edited `[A-Z][A-Z0-9-]+` → `INV-[a-z0-9]+(?:-[a-z0-9]+)+` at trace md:141 (AC-5 substrate verification anchor-walker cite) + coverage-matrix.json:69 (AC-5 substrate_verification). 4 additional uppercase hits in story spec (impl-artifacts md:52, 127, 150, 178) are intentional historical citations (describe the iter-7 bug, not propagate it) — left untouched per iter-8's spec-echoes-impl-bug rule which already corrected the prescriptive echoes at lines 52/125/154 inline. JSON schema validation PASS (`python -c "json.load(...)"` clean). Pure prose — zero code changes — no test runner re-exercise needed; prek commit-stage hook covers format-check + commitlint. Story State: remains `fixes-pending` (Fix B + C + CR re-run still in QUEUE).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending — iter-14 CR re-run surfaced 3 new fix patches; 2 fix iters + 1 final CR re-run remaining)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until Epic 1 EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — sprint-status + story-file Status remain `review`; flips to `done` only on NEXT CR re-run zero-findings outcome per matrix row 9 single-transition edge.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-15 Fix A executed narrow-scope per iter-11 discipline.** Two edit sites, one regex-literal swap class. Did NOT combine with Fix B (AC-5 "Not exercised in smoke" framing) even though coverage-matrix.json:69 is a shared target — preserves revert granularity if Fix A alone needs reverting without disturbing Fix B's framing edit. Trade-off: two separate commits touching the same JSON field; mitigated by the precise `replace_all: false` edits that leave the rest of the field untouched.
- **Untouched historical uppercase-regex citations — policy confirmation.** impl-artifacts/1-9-*.md lines 52, 127, 150, 178 all contain `[A-Z][A-Z0-9-]+` text but those are narrative citations OF the bug (change-log entries + carry-forward rule descriptions) — they correctly describe the pre-iter-8 state. Only prescriptive echoes (regex used as implementation guidance) need correction. iter-8's fix already corrected the prescriptive echoes at story lines 52/125/154 in-place. Future CR passes should not flag narrative/historical citations as stale.
- **Pattern corollary established iter-14 (carried forward): trace-bundle semantic-drift from impl-upgrade.** When iteration N+k upgrades AC coverage (new smoke, fixed unreachable branch, new end-to-end evidence), the trace bundle's three claim classes drift: (i) "Not exercised in smoke" (now false for the upgraded AC — Fix B targets this); (ii) smoke-count cardinals ("three"→"five" — Fix C targets this); (iii) AC-coverage lists ("AC-1 + AC-4 + AC-7" → "AC-1 + AC-2 + AC-4 + AC-5 + AC-7" — Fix C targets this). Regex-literal echoes (Fix A class) are the spec-echoes-impl-bug rule from iter-8 carried into trace artefacts which iter-8 missed because iter-8 expected the next `/bmad-testarch-trace` re-run to refresh them — but the lifecycle never re-ran trace (went straight from `in-dev` → one-shot `traced` via iter-5 then SM-review at iter-6). Generalised carry-forward: every AC-coverage-upgrading iteration MUST update trace bundle's mirror claims in the same commit (impl + spec echoes + trace artefacts), not defer to a hypothetical future trace re-run.
- **Fix B targets 3 sites** — trace md:143 (AC-5 bullet), trace md:260 (Happy-Path-Only section), coverage-matrix.json:69 tail-of-field (already partially touched by Fix A's regex swap, so Fix B will extend the same line). Fix B phrasing target: "Not exercised in smoke" → "Exercised via iter-8 Task-5 smoke (append `INV-fake-orphan` → exit 1 + `removed-from-docs-only`; revert; byte-identical restore)".
- **Fix C scope is ~13 target sites across 5 artefacts** — single mechanical prose-swap like iter-10's 6-site swap + iter-12's 31-site re-anchor. Do NOT split into Fix C1/C2/C3 by artefact — the underlying change is one semantic ("post-iter-8 reality: 5 smokes covering AC 1+2+4+5+7 end-to-end; only AC-3 + AC-6 remain schema/structural"), and splitting would fragment a single coherent edit across iterations.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-15. Parent Epic 1 issue **#9** — `Refs #9` only.
