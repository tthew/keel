# Implementation Plan

(AWAIT_MERGE — PR #221 Open, CLEAN, MERGEABLE, 0 reviews, 0 checks; `.ralph/halt` already carries `EPIC_DONE` payload. Awaiting user merge before Story 1.6.)

## NOW

_(none — Story 1.5 mini-epic shipped; loop awaits user merge)_

## QUEUE

_(empty — post-merge iteration picks up Story 1.6)_

## BLOCKED

_(none)_

## DONE (Story 1.5 mini-epic)

- [x] Story 1.5 spec authored — 3-task decomposition; sprint-status `1-5 → ready-for-dev`
- [x] Draft PR #221 created — `{isDraft:true, state:OPEN, mergeable:MERGEABLE, mergeStateStatus:CLEAN, statusCheckRollup:[]}`
- [x] Story 1.5 Task 1 — `.pre-commit-config.yaml` 4th hook entry + `prepare` flag; both shims installed; probes green
- [x] Story 1.5 Task 2 — ATDD probes via real `git commit`: AC 2 lands exit 0; AC 3 rejects with `subject-empty` + `type-empty`; AC 4 structural note recorded; tree clean
- [x] Story 1.5 Task 3 — verification gates all FULL TURBO on FIRST call; sprint-status `1-5 → done` co-landed (pre-transition orphan-prevention)
- [x] PR #221 Draft→Open — title/body rewritten for full 5-commit scope; `gh pr ready`; MERGEABLE / CLEAN / no-reviews / no-checks; EPIC_DONE halt signalled
- [x] Halt reinforcement — `(AWAIT_MERGE` marker added (belt-and-suspenders — ralph.py:1758 guarantees loop stop if halt file detection at :1750 was missed)

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.5 done; 1.6–1.16 backlog)
- **Epic Branch:** `feat/story-1-5-conventional-commit-enforcement-via-commitlint-prek`
- **Story:** 1.5 — Conventional-commit enforcement via commitlint + prek (done)
- **Story File:** `_bmad-output/implementation-artifacts/1-5-conventional-commit-enforcement-via-commitlint-prek.md`
- **PR:** #221 Open (5 impl commits + 2 bookkeeping commits)
