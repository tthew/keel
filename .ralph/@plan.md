# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — pre-dev SM validation (matrix row 2; `drafted → validated`) ~small

## QUEUE (Story 1.9 — invariant-sync-gate-runtime-tooling-reader-walker-drift-detector)

- [ ] Run `/bmad-testarch-atdd` — red-phase scaffolds OR apply FR14n matrix row 3 skip clause (`validated → atdd-scaffolded`). Decision at iter-3 time: Story 1.9 has runtime behaviour (walker + drift-detector), not purely substrate-verification — ATDD skip UNLIKELY to apply (per IP-Notes prediction based on Story 1.8 pattern + RALPH.md Decisions guardrail requiring all three grounds).
- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md")` — executes 5 Tasks (`atdd-scaffolded → in-dev`).
- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability matrix (`in-dev → traced`). Expect PASS (not WAIVED) — Story 1.9 has runtime smoke-tests (clean/drift/performance paths in Task 5) that materially cover ACs 1/4/7; ACs 2/3/5 are schema-level covered by manifest Zod refines + walker regex.
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (`traced → sm-verified`).
- [ ] Run `/bmad-code-review (args: "2")` — adversarial triage (`sm-verified → done` OR `fixes-pending`).

## BLOCKED

_(none)_

## DONE (Story 1.9 — spec authoring)

- [x] Ralph-hosted `/bmad-create-story` inline realisation (iter-1; `(no story) → drafted` per FR14n matrix). Spec authored at `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md` with 5-task decomposition: Task 1 authors `manifest-reader.ts` + `sync-gate.ts` (anchor walker + drift detector + structured `DriftReport`); Task 2 closes pre-existing `INV-ralph-halt-path-resolution` docs-only drift by appending 10th entry to manifest (sourcePath=`docs/invariants/ralph-execute.md`; contentHash=`8c679cd…cba8b` pre-computed at authoring); Task 3 absorbs 4 of 6 Story 1.8 CR defers as Zod schema hardening (sourcePath traversal guard + id uniqueness refine + cross-entry hash consistency + readonly/freeze); Task 4 wires CLI entry (`pnpm keel-invariants:check`) via package.json `bin` + root script; Task 5 quality gates + 3 runtime smoke tests (clean/drift/performance) + sprint-status bump. Three scope carve-outs documented (AC 2 anchor-side-only; AC 6 CI workflow → Epic 13; `schemaVersion` stays deferred). Sprint-status bumped `1-9: backlog → ready-for-dev` + `last_updated: 2026-04-20 Story-1-9-spec UTC` (ninth consecutive story-implementation confirmation of preemptive-orphan-prevention after 1.1–1.8). Story State: `(no story) → drafted`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 drafted)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until EPIC_DONE of Epic 1 per PROMPT_build.md step 5c "if all epic stories are done"; prior per-story-PR pattern (1.1–1.7) is superseded by current step-5c semantics)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `drafted`
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Story 1.9 is enforcement-side of FR43** — first Epic-1-substrate story with genuine runtime behaviour (walker + drift-detector + CLI), NOT pure data-contract. Expect a hotter trace gate than Stories 1.7/1.8 (both WAIVED on ATDD-skip grounds); Story 1.9's runtime smoke tests in Task 5 materially cover ACs 1/4/7 at the shell level. ATDD skip clause (FR14n matrix row 3) is unlikely to apply — RALPH.md guardrail requires all three grounds (substrate-coverage + no-test-runner + upstream-covered); Story 1.9 satisfies only the middle one.
- **10th manifest entry (`INV-ralph-halt-path-resolution`) closes pre-existing drift.** The halt-path-resolution fix (commit `5cfa055`, PR #225) added the 10th anchor to `INVARIANTS.md` at line 48 but did NOT update Story 1.8's manifest. Story 1.9 Task 2 closes this gap — without it, Story 1.9's own sync-gate would report `removed-from-docs-only` on first run (ironic: the enforcement tool would catch itself-being-unfinished). Dev-story MUST land Task 2 before Task 5's clean-path smoke test.
- **Four-of-six Story 1.8 CR defers absorbed in Task 3** — sourcePath traversal guard + id uniqueness refine + cross-entry hash consistency + readonly/freeze. Two remain deferred: contentHash drift validation (IS Task 1's sync-gate scope, functionally absorbed at tool level without needing schema change) + schema-evolution metadata (`schemaVersion`/`deprecated`/`since`; stays in `deferred-work.md` until a concrete deprecation need arises).
- Issue Tracking: Story 1.9 issue number TBD at next iter-2 time (ralph.py injects `RALPH_ISSUE_NUMBER` env var when IP's `**Story:**` field lands on the next iteration's orient scan). Parent Epic 1 issue **#9** — `Refs #9` only; closed by ralph.py EPIC_DONE halt handler at Epic 1 completion.
