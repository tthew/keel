# Implementation Plan

## NOW

- [ ] Transition PR #220 Draft→Open — rewrite title/body for 5-commit range (spec + Task 1 + Task 2 + Task 3); `gh pr ready`; EPIC_DONE halt (Stories 1.1/1.2/1.3 precedent: story-implementation PRs halt EPIC_DONE on Open+clean+no-reviews+no-checks, since Story 1.16 still owes CI workflows) ~small

## QUEUE (Story 1.4 mini-epic)

_(none — NOW is the terminal iteration)_

## BLOCKED

_(none)_

## DONE (Story 1.4 mini-epic)

- [x] Reconciled after user merge of PR #219 (main now `40507d9`); fresh branch off `origin/main`; stale halt cleared
- [x] Story 1.4 spec authored — 3-task decomposition; sprint-status `1-4 → ready-for-dev`
- [x] Draft PR #220 created — body covers spec-only state; title/body to be rewritten before `gh pr ready` per multi-commit precedent
- [x] Story 1.4 Task 1 shipped — `@j178/prek@0.3.9` pinned, `.pre-commit-config.yaml` authored, `prepare: prek install` wired; hook installed to main `.git/hooks/pre-commit`; AC 6 self-verification all exit 0
- [x] Story 1.4 Task 2 shipped — 5 ATDD probes (AC 2/3/4/5/6) all green; every probe artefact removed; branch tip back at `3450924`
- [x] Story 1.4 Task 3 shipped — `pnpm install` Already up to date (`prepare` idempotent); `pnpm -w typecheck` + `pnpm -w lint` 16/16 `>>> FULL TURBO` 136ms + 114ms on FIRST call; `pnpm format:check` exit 0; commitlint 0/0 across 4 branch commits; `pnpm exec prek run --all-files` all three hooks Passed; story Status `ready-for-dev → done`; sprint-status `1-4 → done` co-landed per Story 1.2/1.3 precedent

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress)
- **Epic Branch:** `feat/story-1-4-pre-commit-quality-gates-via-prek-type-check-lint-format`
- **Story:** 1.4 — Pre-commit quality gates via prek (type-check, lint, format) — **done** (all 3 tasks complete; sprint-status flipped; story spec Status done)
- **Story File:** `_bmad-output/implementation-artifacts/1-4-pre-commit-quality-gates-via-prek-type-check-lint-format.md`
- **PR:** #220 Draft — 5 commits (spec + IP + Tasks 1/2/3); title/body rewrite + `gh pr ready` queued as NOW
