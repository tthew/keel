# Implementation Plan

## NOW

- [ ] Story 1.3 Task 4 — sprint-status `1-3 → done` bump + re-verify quality gates (typecheck / lint / format:check / commitlint); land BEFORE Draft→Open ~small

## QUEUE (Story 1.3 mini-epic)

- [ ] Transition PR Draft→Open — rewrite title/body to cover full commit range, then `gh pr ready` (per RALPH.md "Multi-commit story PRs drift PR metadata from reality")

## BLOCKED

_(none)_

## DONE (Story 1.3 mini-epic)

- [x] Reconciled after user merge of PR #218 (main now `784fbd0`); fresh branch `feat/story-1-3-eslint-no-restricted-imports-import-boundary-rules` off `origin/main`; stale halt cleared
- [x] Story 1.3 spec authored (`_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`) — 4-task decomposition, AC 1–5; sprint-status `1-3 → ready-for-dev`
- [x] Story 1.3 Task 1 — shared ESLint config appended: 7th universal entry (AC 1+2) + named `forPackage(ownName)` factory (AC 3). Self-verification probe from `packages/audit/`: `default-len=7 forPackage-type=function`. Typecheck 16/16 (FULL TURBO second run, 174ms); lint 16/16 green (13.76s cold). No false-positives on empty `src/index.ts` consumers.
- [x] Story 1.3 Task 2 — 16 × per-package `eslint.config.js` migrated to `forPackage('<name>')`. **Landmine hit + fixed:** `packages/keel-invariants/eslint.config.js` with generic `import { forPackage } from '@keel/keel-invariants/eslint'` triggers its own self-import rule (keel-invariants can't alias-import itself under AC 3). Fix: for keel-invariants ONLY, use relative `import { forPackage } from './eslint.config.keel-invariants.js'`. Other 15 members use the generic `@keel/keel-invariants/eslint` form. Gates: lint 16/16 green (5.68s cold, 214ms FULL TURBO warm); typecheck 16/16 (1.54s cold, 245ms FULL TURBO warm); format:check exit 0; commitlint 0/0 across 3 branch commits. Consumer probe from `packages/audit/`: `default-len=7 forPackage-type=function forPackage("audit")-len=8`.
- [x] Story 1.3 Task 3 — ATDD smoke probes via `eslint --stdin` (AC 1 / AC 2 / AC 3 audit + AC 3 web + negative). Initial AC 1 probe revealed real pattern gap: `**/packages/*/src/**` requires literal "packages" in specifier but realistic relative form `../../contracts/src/...` has none → rule did NOT fire. Per Task 3 directive, looped back to Task 1 and broadened AC 1 `group` in both the 7th entry and `forPackage`'s 8th entry with 6 depth-prefixed patterns (`../../**/src{,/**}`, `../../../**/src{,/**}`, `../../../../**/src{,/**}`). Post-fix probes all green: AC 1/2/3/web exit 1 with correct `no-restricted-imports` + message; negative (side-effect import `import '@keel/contracts';`) exit 0. Debug Log in story file captures all 5 probe outputs. Gates: lint 16/16 cold 6.955s; typecheck 16/16 cold 1.488s (both invalidated by the config-file edit, expected); format:check exit 0; commitlint 0/0 across 4 branch commits.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (in-progress)
- **Epic Branch:** `feat/story-1-3-eslint-no-restricted-imports-import-boundary-rules`
- **Story:** 1.3 — ESLint `no-restricted-imports` import-boundary rules — **ready-for-dev**
- **Story File:** `_bmad-output/implementation-artifacts/1-3-eslint-no-restricted-imports-import-boundary-rules.md`
- **PR:** #219 Draft, MERGEABLE, CLEAN, 0 reviews, 0 checks (no CI workflows until Story 1.16)
