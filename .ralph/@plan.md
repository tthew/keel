# Implementation Plan

## NOW

- [ ] Run `/bmad-code-review (args: "2")` — adversarial triage via 3-layer Ralph-hosted fan-out (Blind Hunter / Edge Case Hunter / Acceptance Auditor); `sm-verified → done` (zero findings) OR `fixes-pending` (action items queued). ~large

## QUEUE (Story 1.9 — invariant-sync-gate-runtime-tooling-reader-walker-drift-detector)

_(empty — CR is terminal-gate step before Epic 1 EPIC_DONE transition)_

## BLOCKED

_(none)_

## DONE (Story 1.9 — SM verification)

- [x] `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction audit (iter-6; `traced → sm-verified` per FR14n matrix row 7). Pattern: Sonnet subagent delegation (bmad-agent-pm) per Story 1.7 iter-6 source-heavy-story rule (docs-only → inline; source-heavy → subagent to preserve main-loop context). All 7 ACs PASS (1: clean-path smoke re-verified exit 0; 2: anchor-side-only wired per spec carve-out; 3: structural removed-from-source branch at sync-gate.ts:53-67; 4: drift-path smoke end-to-end + branch at sync-gate.ts:69-77; 5: anchor-loop branch at sync-gate.ts:80-87; 6: CLI exit-code contract pinned at check.ts:8-13 per Epic 13 carve-out; 7: 0.77s perf smoke + Promise.all dedup). All 5 Tasks COMPLETE (1: 3 NEW TS files + 4-kind drift detector + shared-source dedup; 2: 10th manifest entry INV-ralph-halt-path-resolution with byte-matching contentHash; 3: 4 Zod refines (traversal-guard + id-uniqueness + cross-entry-hash-consistency + readonly+Object.freeze); 4: CLI wired via pnpm keel-invariants:check + repo-root alias + index.ts re-exports; 5: 7 quality gates green + 3 smoke tests + sprint-status bumped + provisional-header discharged). Zero scope creep; three spec-vs-reality deltas all explicitly documented in Completion Notes (@types/node@20.19.0 devDep + scoped types:["node"] in tsconfig.json + INV-prek-prepare-lifecycle hash recomputed c83420f2…6e after root package.json mutation). SM_VERIFIED first-pass — no fix tasks queued.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 sm-verified)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until EPIC_DONE of Epic 1 per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `sm-verified` (Ralph FR14n matrix row 7) — sprint-status + story-file Status remain `review` per dev-story workflow step 9 semantics; flips to `done` only on CR zero-findings outcome per matrix row 9.
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **SM-audit evidence convention applied:** per Story 1.7 iter-6 / Story 1.8 iter-6 precedent, audit trail lives in IP § DONE (this file), NOT in story-file Dev Agent Record (dev-story sealed that at iter-4; rewriting it would conflict with the `review` status and confuse future stories' Previous Story Intelligence scans). Trace bundle under `_bmad-output/test-artifacts/traceability/1-9-*` remains authoritative for coverage; IP DONE is authoritative for SM-review findings.
- **Third cumulative confirmation of Ralph-hosted `/bmad-create-story (args: "review")` fallback pattern** (the skill has no native `review` mode per Story 1.7 iter-2 Lessons): Story 1.7 iter-6 (docs-only → inline checklist walk); Story 1.8 iter-6 (source-heavy → Sonnet subagent); Story 1.9 iter-6 (source-heavy → Sonnet subagent, richest evidence surface of the three).
- **Next iteration queues CR adversarial triage** via `/bmad-code-review (args: "2")`. Per § Story Lifecycle Decision Matrix row 9: `sm-verified → done` on zero findings OR `fixes-pending` on action items queued. Pattern from Story 1.7 iter-7 / iter-12 / iter-15 / iter-18 / iter-20: three parallel `Agent` calls with role-semantic subagent types (bmad-agent-architect as Blind Hunter / bmad-tea as Edge Case Hunter / bmad-agent-dev as Acceptance Auditor); diff saved to `/tmp/story-1-9-review-diff.txt` via `git diff origin/main..HEAD -- . ':!.ralph/@plan.md' ':!.ralph/logs/'`; args "2" pre-selects step-04 option 2 ("Create action items"). Nesting a Skill() call to `/bmad-code-review` would HALT at step-01/step-04 HITL checkpoints — Ralph-hosted fan-out is the canonical realisation.
- **Expected CR findings surface for Story 1.9:** richer than Story 1.8 (contract-only story had 6 CR defers) because Story 1.9 ships three runtime TS files + a CLI + schema hardening. Likely surfaces: (a) possible Blind Hunter cross-artefact drift between story Completion Notes and trace bundle wording (spec-vs-reality § Testing Standards "2 runtime smoke tests" vs iter-4 shipping 3 — already noted in iter-5 IP but not yet harmonised in story file); (b) possible Edge Case Hunter finding on anchor-walker regex edge cases (e.g., behaviour on malformed bullet lines); (c) possible Acceptance Auditor verdict on "PASS" vs "PARTIAL" for AC 3/AC 5 (structural-only — CR may want end-to-end evidence not present in smoke). Any defers that are natural-scope for Story 1.10+ should flow into `deferred-work.md` per Story 1.8 → 1.9 defer-absorption precedent.
- **PR #226 lifecycle:** step-5c "all epic stories done" semantics — PR #226 stays Draft through Epic 1 (Stories 1.9–1.16 remaining); Draft→Open at EPIC_DONE. Today's CR pass doesn't trigger PR transition.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-6 (no GH project auto-creation for stories). Parent Epic 1 issue **#9** — `Refs #9` only; closed by ralph.py EPIC_DONE halt handler at Epic 1 completion.
