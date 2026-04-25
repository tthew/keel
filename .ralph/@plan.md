# Implementation Plan

## NOW

- [x] iter-344: One-shot RALPH.md + @plan.md prune (issue #231 follow-up) — RALPH.md 1.15MB→17KB / 633→93 lines; @plan.md condensed; doc-budget warn-in-prompt baseline silent.

## QUEUE (Epic 3 — Ralph package + multi-iteration loop, 33 stories)

- [ ] § Cross-epic transition: re-evaluate `gh pr view 230 --json state,mergedAt` next invocation. If MERGED + Epic 3 backlog row `3-1-…: backlog` present → NOW = `Run /bmad-create-story` (skill auto-marks Epic 3 in-progress + produces Story 3.1 file). Otherwise re-write `EPIC_DONE` halt.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures.

## BLOCKED

_(empty — iter-343 close-out clean; iter-344 prune clean.)_

## ATDD Red Phase

_(empty — substrate coverage at Epic 2 close: 7 persistent `node:test` unit tests GREEN + 74 persistent replay fixtures GREEN.)_

## DONE

- [x] iter-344: RALPH.md + @plan.md prune; doc-budget hook silent in warn-mode.
- [x] iter-343: Epic-2 close-out — PR #230 Draft→Open + EPIC_DONE halt.
- [x] iter-342: Story 2.17 CR LANDING — sm-verified → done; 3 PATCH bundle-close + 25 DEFER.

_(prior DONE detail in commits + story-file Status HTML comment chain + story-file Change Log.)_

## Context

- **Phase:** 4-implementation — Epic 2 COMPLETE; awaiting human merge of PR #230.
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17/17 stories `done`; epic-row `done` at sprint-status line 132.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (PR #230 OPEN, awaiting merge).
- **Story:** _(no story — Story 2.17 done iter-342; § Cross-epic transition picks up Epic 3 Story 3.1 after merge.)_
- **Story State:** `done` (Story 2.17).
- **Next-Epic Story:** Epic 3 Story 3.1 = `3-1-packages-ralph-package-install-boundary-via-uv-tool-install` (sprint-status line 153, `backlog`).
- **GitHub Issue:** no GH Project configured; `RALPH_ISSUE_NUMBER` unset.
- **PR:** #230 Open / mergeStateStatus=CLEAN / mergeable=MERGEABLE — https://github.com/tthew/ralph-bmad/pull/230.
- **Working branch (this iter):** `chore/course-correct-doc-budget-231` — issue #231 doc-budget harness landed iter-344-prev (commit 9716ca5); RALPH.md prune lands here.

## Notes

- iter-344 prune routed via `/bmad-quick-dev` one-shot path (zero blast radius — RALPH.md is private journal; git log preserves full history per Paige's roundtable rejection of archive files).
- Doc-budget halt-in-prompt mode promotion gates on baseline FP-rate proof: ≥20 healthy iters in `sizes.jsonl` + P90 ≥30% below cap + Phase-1 FP <5%. Stays in warn-in-prompt until then.
