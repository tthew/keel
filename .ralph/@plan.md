# Implementation Plan

## NOW

- [ ] _(empty — Story 1.2 mini-epic halted EPIC_DONE; next human action is merging PR #218)_

## QUEUE

_(empty)_

## BLOCKED

_(none)_

## DONE (Story 1.2 mini-epic)

- [x] Reconciled IP + branch after user merge of PR #217 (main now `4bf11af`); fresh branch `feat/story-1-2-keel-invariants-shared-configs` off `origin/main`
- [x] Story 1.2 spec authored
- [x] Story 1.2 Task 1 — relocated `tsconfig.base.json`; 15 subpath `extends` flips; 15 × workspace devDep additions
- [x] Story 1.2 Task 2 — shared-config devDeps (eslint/prettier/commitlint toolchain, current stable)
- [x] Story 1.2 Task 3 — ESLint flat config + `./eslint` subpath export
- [x] Story 1.2 Task 4 — Prettier config + `./prettier` subpath + root `.prettierignore`
- [x] Story 1.2 Task 5 — commitlint config + `./commitlint` subpath export
- [x] Story 1.2 Task 6 — wired root shims + 16 per-member eslint configs + lint/format scripts
- [x] Story 1.2 Task 7 — verification + format-fix on 3 pre-existing markdown files; all gates green
- [x] Sprint-status bookkeeping — Story 1.2 `ready-for-dev` → `done` (landed before PR transition per Lessons "Post-halt bookkeeping commits can orphan from main")
- [x] PR #218 body rewritten to cover full 9-commit range (per Lessons "Multi-commit story PRs drift PR metadata from reality"); `gh pr ready` → state OPEN, MERGEABLE, CLEAN, 0 reviews, 0 checks (no CI workflows until Story 1.16)
- [x] **EPIC_DONE halt** — matches story-implementation precedent (Decisions 2026-04-19 "First story-implementation mini-epic halted")

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress)
- **Epic Branch:** `feat/story-1-2-keel-invariants-shared-configs`
- **Story:** 1.2 — `packages/keel-invariants` bootstrap + shared ESLint/Prettier/commitlint configs — **DONE**
- **Story File:** `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md`
- **PR:** #218 Open, MERGEABLE, CLEAN, 0 reviews, 0 checks
