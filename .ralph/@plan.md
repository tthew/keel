# Implementation Plan

## NOW

- [ ] Story 1.5 Task 2 — ATDD probes via real `git commit -m`: AC 2 valid accepts, AC 3 invalid rejects, AC 4 author-parity structural note ~medium

## QUEUE (Story 1.5)

- [ ] Story 1.5 Task 3 — quality gates + sprint-status bump `1-5 → done` (land in Task 3's commit to avoid orphan per Stories 1.2–1.4 precedent)
- [ ] PR #221 Draft→Open — rewrite title/body for full commit range, `gh pr ready`, EPIC_DONE halt

## BLOCKED

_(none)_

## DONE (Story 1.5 mini-epic)

- [x] Story 1.5 spec authored — 3-task decomposition; sprint-status `1-5 → ready-for-dev`
- [x] Draft PR #221 created — `{isDraft:true, state:OPEN, mergeable:MERGEABLE, mergeStateStatus:CLEAN, statusCheckRollup:[]}`
- [x] Story 1.5 Task 1 — `.pre-commit-config.yaml` 4th hook entry + `prepare` flag; both shims installed; probes green

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress; Stories 1.1–1.4 done)
- **Epic Branch:** `feat/story-1-5-conventional-commit-enforcement-via-commitlint-prek`
- **Story:** 1.5 — Conventional-commit enforcement via commitlint + prek (ready-for-dev)
- **Story File:** `_bmad-output/implementation-artifacts/1-5-conventional-commit-enforcement-via-commitlint-prek.md`
- **PR:** #221 Draft (just created; 1 commit — spec only)
