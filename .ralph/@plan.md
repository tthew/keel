# Implementation Plan

## NOW

- [ ] Transition PR #219 Draft→Open — rewrite title/body to cover full 7-commit range (spec + Tasks 1–4 + sprint-status), then `gh pr ready`; EPIC_DONE halt on Open+clean+no-reviews (per RALPH.md precedent) ~small

## QUEUE (Story 1.3 mini-epic)

_(empty — Task 4 complete; only PR transition remains)_

## BLOCKED

_(none)_

## DONE (Story 1.3 mini-epic)

- [x] Reconciled after user merge of PR #218 (main now `784fbd0`); fresh branch off `origin/main`; stale halt cleared
- [x] Story 1.3 spec authored — 4-task decomposition; sprint-status `1-3 → ready-for-dev`
- [x] Story 1.3 Task 1 — shared ESLint config extended (7th universal entry + `forPackage` factory)
- [x] Story 1.3 Task 2 — 16 × per-package `eslint.config.js` migrated to `forPackage('<name>')`; keel-invariants self uses relative import (self-alias forbidden by its own AC 3 rule)
- [x] Story 1.3 Task 3 — ATDD smoke probes; AC 1 pattern gap caught + broadened patterns in both 7th-entry and `forPackage` 8th-entry body; 5/5 probes correct post-fix
- [x] Story 1.3 Task 4 — verification-only iteration: typecheck 16/16 FULL TURBO (151ms), lint 16/16 FULL TURBO (138ms), format:check exit 0, commitlint 0/0 across 4 branch commits. Sprint-status bumped `1-3 → done`, `last_updated` set to `2026-04-19 20:36 UTC`. Story file Status → `done`; Completion Notes + File List populated; Debug Log appended with Task 4 cache-warm evidence. Landed BEFORE Draft→Open to prevent orphan-bookkeeping-commit risk.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress)
- **Epic Branch:** `feat/story-1-3-eslint-no-restricted-imports-import-boundary-rules`
- **Story:** 1.3 — ESLint `no-restricted-imports` import-boundary rules — **done**
- **Story File:** `_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`
- **PR:** #219 Draft, MERGEABLE, CLEAN, 0 reviews, 0 checks (no CI workflows until Story 1.16)
