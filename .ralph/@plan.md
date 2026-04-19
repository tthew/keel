# Implementation Plan

## NOW

- [ ] Story 1.3 Task 1 — extend `packages/keel-invariants/eslint.config.keel-invariants.js` with universal `no-restricted-imports` (AC 1+2) + named export `forPackage(ownName)` (AC 3) ~medium

## QUEUE (Story 1.3 mini-epic)

- [ ] Story 1.3 Task 2 — migrate all 16 per-package `eslint.config.js` to `forPackage('<name>')`
- [ ] Story 1.3 Task 3 — ATDD smoke probes via `eslint --stdin` for AC 1 / AC 2 / AC 3 + negative probe; capture in Debug Log
- [ ] Story 1.3 Task 4 — full quality-gate verification (typecheck / lint / format:check / commitlint) + sprint-status bump `ready-for-dev` → `done` BEFORE Draft→Open
- [ ] Transition PR Draft→Open — rewrite title/body to cover full commit range, then `gh pr ready` (per RALPH.md "Multi-commit story PRs drift PR metadata from reality")

## BLOCKED

_(none)_

## DONE (Story 1.3 mini-epic)

- [x] Reconciled after user merge of PR #218 (main now `784fbd0`); fresh branch `feat/story-1-3-eslint-no-restricted-imports-import-boundary-rules` off `origin/main`; stale halt cleared
- [x] Story 1.3 spec authored (`_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`) — 4-task decomposition, AC 1–5 mirror epic + expanded AC 5 for full-workspace lint evidence; sprint-status `1-3 → ready-for-dev`

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress)
- **Epic Branch:** `feat/story-1-3-eslint-no-restricted-imports-import-boundary-rules`
- **Story:** 1.3 — ESLint `no-restricted-imports` import-boundary rules — **ready-for-dev**
- **Story File:** `_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`
- **PR:** _(not yet created — opens after Task 1 first push)_
