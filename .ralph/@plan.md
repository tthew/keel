# Implementation Plan

## NOW

- [ ] Author Story 1.5 spec + iteration-1 bootstrap (branch, sprint-status → ready-for-dev, Draft PR) ~medium

## QUEUE (Story 1.5)

- [ ] Story 1.5 Task 1 — author commit-msg hook entry + update `prepare` script (`-t pre-commit -t commit-msg`); verify `.git/hooks/commit-msg` lands
- [ ] Story 1.5 Task 2 — ATDD probes: valid commit accepts (AC 2), invalid commit rejects (AC 3), author parity note (AC 4)
- [ ] Story 1.5 Task 3 — quality gates + sprint-status bump `1-5 → done`
- [ ] PR Draft→Open transition — rewrite title/body for full commit range, `gh pr ready`, EPIC_DONE halt

## BLOCKED

_(none)_

## DONE

_(fresh mini-epic; no iterations yet)_

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress; Stories 1.1–1.4 done)
- **Epic Branch:** `feat/story-1-5-conventional-commit-enforcement-via-commitlint-prek`
- **Story:** 1.5 — Conventional-commit enforcement via commitlint + prek (backlog → ready-for-dev this iteration)
- **Story File:** `_bmad-output/implementation-artifacts/1-5-conventional-commit-enforcement-via-commitlint-prek.md`
- **PR:** TBD (Draft created this iteration)
