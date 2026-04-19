# Implementation Plan

## NOW

- [ ] Story 1.4 Task 1 — pin `@j178/prek@0.3.9`, author `.pre-commit-config.yaml` (3 local hooks), wire root `prepare: prek install`, verify `.git/hooks/pre-commit` ~medium

## QUEUE (Story 1.4 mini-epic)

- [ ] Story 1.4 Task 2 — ATDD probes (AC 2/3/4 commit-abort + AC 5 clean-commit + AC 6 prek-runner parity); capture evidence in Debug Log
- [ ] Story 1.4 Task 3 — full quality gates + sprint-status `1-4 → done` + story Status → done
- [ ] Transition PR Draft→Open — rewrite title/body for full commit range (precedent load-bearing per Stories 1.1/1.2/1.3) + `gh pr ready` + EPIC_DONE halt

## BLOCKED

_(none)_

## DONE (Story 1.4 mini-epic)

- [x] Reconciled after user merge of PR #219 (main now `40507d9`); fresh branch off `origin/main`; stale halt cleared
- [x] Story 1.4 spec authored — 3-task decomposition; sprint-status `1-4 → ready-for-dev`
- [x] Draft PR #220 created — body covers spec-only state; title/body to be rewritten before `gh pr ready` per multi-commit precedent

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress)
- **Epic Branch:** `feat/story-1-4-pre-commit-quality-gates-via-prek-type-check-lint-format`
- **Story:** 1.4 — Pre-commit quality gates via prek (type-check, lint, format) — **ready-for-dev**
- **Story File:** `_bmad-output/implementation-artifacts/1-4-pre-commit-quality-gates-via-prek-type-check-lint-format.md`
- **PR:** #220 Draft — spec-only; title/body to rewrite for full commit range before `gh pr ready`
