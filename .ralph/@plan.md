# Implementation Plan

## NOW

- [ ] _(none — Story 1.3 shipped; EPIC_DONE halt written this iteration)_

## QUEUE (Story 1.3 mini-epic)

_(empty)_

## BLOCKED

_(none)_

## DONE (Story 1.3 mini-epic)

- [x] Reconciled after user merge of PR #218 (main now `784fbd0`); fresh branch off `origin/main`; stale halt cleared
- [x] Story 1.3 spec authored — 4-task decomposition; sprint-status `1-3 → ready-for-dev`
- [x] Story 1.3 Task 1 — shared ESLint config extended (7th universal entry + `forPackage` factory)
- [x] Story 1.3 Task 2 — 16 × per-package `eslint.config.js` migrated to `forPackage('<name>')`; keel-invariants self uses relative import (self-alias forbidden by its own AC 3 rule)
- [x] Story 1.3 Task 3 — ATDD smoke probes; AC 1 pattern gap caught + broadened patterns in both 7th-entry and `forPackage` 8th-entry body; 5/5 probes correct post-fix
- [x] Story 1.3 Task 4 — verification-only: typecheck/lint 16/16 FULL TURBO, format:check 0, commitlint 0/0 × 4 commits. Sprint-status `1-3 → done`. Story Status → `done`.
- [x] PR #219 Draft→Open transition — title/body rewritten for full 6-commit range before `gh pr ready`; EPIC_DONE halt written (Open + MERGEABLE + CLEAN + 0 reviews + 0 checks).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress)
- **Epic Branch:** `feat/story-1-3-eslint-no-restricted-imports-import-boundary-rules`
- **Story:** 1.3 — ESLint `no-restricted-imports` import-boundary rules — **done**
- **Story File:** `_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`
- **PR:** #219 Open, MERGEABLE, CLEAN, 0 reviews, 0 checks (no CI workflows until Story 1.16)
