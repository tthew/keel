# Implementation Plan

## NOW

- [ ] Story 1.4 Task 3 — full quality gates + sprint-status `1-4 → done` + story Status → done ~small

## QUEUE (Story 1.4 mini-epic)

- [ ] Transition PR Draft→Open — rewrite title/body for full commit range (precedent load-bearing per Stories 1.1/1.2/1.3) + `gh pr ready` + EPIC_DONE halt

## BLOCKED

_(none)_

## DONE (Story 1.4 mini-epic)

- [x] Reconciled after user merge of PR #219 (main now `40507d9`); fresh branch off `origin/main`; stale halt cleared
- [x] Story 1.4 spec authored — 3-task decomposition; sprint-status `1-4 → ready-for-dev`
- [x] Draft PR #220 created — body covers spec-only state; title/body to be rewritten before `gh pr ready` per multi-commit precedent
- [x] Story 1.4 Task 1 shipped — `@j178/prek@0.3.9` pinned, `.pre-commit-config.yaml` authored, `prepare: prek install` wired; hook installed to main `.git/hooks/pre-commit` (shared across worktrees); AC 6 self-verification via `pnpm exec prek run --all-files <id>` → all 3 exit 0; full gates FULL TURBO
- [x] Story 1.4 Task 2 shipped — 5 ATDD probes (AC 2 TS error / AC 3 cross-pkg relative import / AC 4 double-quote / AC 5 clean-commit / AC 6 prek-runner parity); all behaved as spec predicted; every probe artefact removed; branch tip back at `3450924`; AC 5 used `_bmad-output/__ac5-probe.txt` (in `.prettierignore`) instead of spec's `echo "" >> RALPH.md` to avoid Prettier trailing-blank-line false-positive; AC 3 caught by both `lint` AND `typecheck` (no default export at target) — defense-in-depth, not a drift

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress)
- **Epic Branch:** `feat/story-1-4-pre-commit-quality-gates-via-prek-type-check-lint-format`
- **Story:** 1.4 — Pre-commit quality gates via prek (type-check, lint, format) — **ready-for-dev** (Tasks 1 + 2 done; Task 3 = verification + sprint-status bump)
- **Story File:** `_bmad-output/implementation-artifacts/1-4-pre-commit-quality-gates-via-prek-type-check-lint-format.md`
- **PR:** #220 Draft — spec + Task 1 committed; title/body to rewrite for full commit range before `gh pr ready`
