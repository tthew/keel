# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (`traced → sm-verified` OR `sm-fixes-pending`). ~medium

## QUEUE (Story 1.9 — invariant-sync-gate-runtime-tooling-reader-walker-drift-detector)

- [ ] Run `/bmad-code-review (args: "2")` — adversarial triage (`sm-verified → done` OR `fixes-pending`).

## BLOCKED

_(none)_

## DONE (Story 1.9 — trace gate)

- [x] `/bmad-testarch-trace (args: "yolo")` ran end-to-end (iter-5; `in-dev → traced` per FR14n matrix row 5). Decision **WAIVED** mirroring Story 1.8's trace precedent — runtime-tooling story at pre-test-runner substrate stage; deterministic rule engine FAIL (P1 0% < 80%, overall 0% < 80%) is a structural false-positive. Substrate verification STRONGER than Story 1.8's (3 runtime smoke tests covering AC-1 + AC-4 + AC-7 end-to-end vs Story 1.8's single Task-3 smoke). AC-2 source-tree auto-discovery + AC-6 CI workflow wiring explicit spec scope carve-outs; AC-3 / AC-5 structural only (CR adversarial pass is agreed backstop per § Testing Standards). 4 artifacts landed: `1-9-coverage-matrix.json` (Phase 1 matrix) + `1-9-e2e-trace-summary.json` (Phase 2 summary) + `1-9-gate-decision.json` (slim gate signal) + `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md` (full report). Priority classification: 5 P1 (AC-1/2/3/4/5 core drift branches) + 2 P2 (AC-6 CLI contract; AC-7 perf NFR); 0 P0 (no auth/payment/data-loss). Waiver expiry: Story 1.16 (test-runner) + Epic 13 (CI workflow wiring).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 traced)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until EPIC_DONE of Epic 1 per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `traced` (Ralph FR14n) — sprint-status + story-file Status remain `review` per dev-story workflow step 9 semantics
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Trace gate WAIVED rationale (Story 1.9-specific vs 1.8):** Story 1.9 has GENUINE runtime behaviour — three Task 5 shell-invocation smoke tests exercised AC-1 (clean-path `pnpm keel-invariants:check` → exit 0) + AC-4 (mutation on `tsconfig.base.json` → exit 1 + JSON DriftReport on stderr for `INV-tsconfig-base content-hash-mismatch` + revert round-trip byte-verified) + AC-7 (0.77s wall-clock; 62% under 2s budget; >2x headroom) end-to-end. Story 1.8's trace WAIVED on rationale "Story 1.9 is the integration test" — that promise was kept at iter-5 (post-Task-2 clean-path smoke proved Story 1.8's manifest contract shipped correctly; if it hadn't, the smoke would have reported drift).
- **Spec-vs-reality correction during trace authoring:** § Testing Standards cites "2 runtime smoke tests" but Task 5 Completion Notes enumerate 3 (clean + drift + performance). Trace rationale uses "3 runtime smoke tests" to reflect actual implementation; the minor wording discrepancy between § Testing Standards and Dev Agent Record is a spec-authoring artifact (authored iter-1; 3 smoke tests landed iter-4) that doesn't invalidate the WAIVED call.
- **FR14n matrix row 5 state-mapping:** sprint-status + story-file Status stay at `review` (per dev-story workflow step 9); Ralph's FR14n Story State advances `in-dev → traced`. Divergence between the two state namespaces is expected + documented in Story 1.9 iter-4 IP notes; sprint-status flips to `done` only at the END of CR per FR14n matrix row 10.
- **Next iteration queues post-dev SM review** via `/bmad-create-story (args: "review")`. Per § Story Lifecycle Decision Matrix row 7: `traced → sm-verified` on satisfaction OR `sm-fixes-pending` on unmet-AC findings. Pattern from Story 1.8 iter-6: fallback to Sonnet-subagent + inline checklist.md audit — the `bmad-create-story` skill has no native `review` mode.
- Issue Tracking: Story 1.9 issue number still unset at iter-5 (no GH project auto-creation for stories). Parent Epic 1 issue **#9** — `Refs #9` only; closed by ralph.py EPIC_DONE halt handler at Epic 1 completion.
