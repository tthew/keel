# Implementation Plan

## NOW

- [ ] PR #221 Draft→Open — rewrite title/body for full 5-commit range, `gh pr ready`, then EPIC_DONE halt ~small

## QUEUE (Story 1.5)

_(empty)_

## BLOCKED

_(none)_

## DONE (Story 1.5 mini-epic)

- [x] Story 1.5 spec authored — 3-task decomposition; sprint-status `1-5 → ready-for-dev`
- [x] Draft PR #221 created — `{isDraft:true, state:OPEN, mergeable:MERGEABLE, mergeStateStatus:CLEAN, statusCheckRollup:[]}`
- [x] Story 1.5 Task 1 — `.pre-commit-config.yaml` 4th hook entry + `prepare` flag; both shims installed; probes green
- [x] Story 1.5 Task 2 — ATDD probes via real `git commit`: AC 2 lands exit 0; AC 3 rejects with `subject-empty` + `type-empty`; AC 4 structural note recorded; tree clean
- [x] Story 1.5 Task 3 — verification gates all FULL TURBO on FIRST call; sprint-status `1-5 → done` co-landed (pre-transition orphan-prevention)

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress; Stories 1.1–1.5 done)
- **Epic Branch:** `feat/story-1-5-conventional-commit-enforcement-via-commitlint-prek`
- **Story:** 1.5 — Conventional-commit enforcement via commitlint + prek (done)
- **Story File:** `_bmad-output/implementation-artifacts/1-5-conventional-commit-enforcement-via-commitlint-prek.md`
- **PR:** #221 Draft (5 commits on branch after Task 3)
