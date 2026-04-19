# Implementation Plan

## NOW

- [ ] Story 1.3 Task 2 — migrate all 16 per-package `eslint.config.js` files from `export default shared` → `export default forPackage('<name>')` ~medium

## QUEUE (Story 1.3 mini-epic)

- [ ] Story 1.3 Task 3 — ATDD smoke probes via `eslint --stdin` for AC 1 / AC 2 / AC 3 (+ web self-import + negative); capture evidence in Debug Log
- [ ] Story 1.3 Task 4 — full quality-gate verification (typecheck / lint / format:check / commitlint) + sprint-status `ready-for-dev` → `done` (land BEFORE Draft→Open)
- [ ] Transition PR Draft→Open — rewrite title/body to cover full commit range, then `gh pr ready` (per RALPH.md "Multi-commit story PRs drift PR metadata from reality")

## BLOCKED

_(none)_

## DONE (Story 1.3 mini-epic)

- [x] Reconciled after user merge of PR #218 (main now `784fbd0`); fresh branch `feat/story-1-3-eslint-no-restricted-imports-import-boundary-rules` off `origin/main`; stale halt cleared
- [x] Story 1.3 spec authored (`_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`) — 4-task decomposition, AC 1–5; sprint-status `1-3 → ready-for-dev`
- [x] Story 1.3 Task 1 — shared ESLint config appended: 7th universal entry (AC 1+2) + named `forPackage(ownName)` factory (AC 3). Self-verification probe from `packages/audit/`: `default-len=7 forPackage-type=function`. Typecheck 16/16 (FULL TURBO second run, 174ms); lint 16/16 green (13.76s cold). No false-positives on empty `src/index.ts` consumers.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress)
- **Epic Branch:** `feat/story-1-3-eslint-no-restricted-imports-import-boundary-rules`
- **Story:** 1.3 — ESLint `no-restricted-imports` import-boundary rules — **ready-for-dev**
- **Story File:** `_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`
- **PR:** #219 Draft, MERGEABLE, CLEAN, 0 reviews, 0 checks (no CI workflows until Story 1.16)
