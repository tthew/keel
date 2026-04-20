# Implementation Plan

## NOW

- [ ] Story 1.6 Task 3 — full quality gates + sprint-status `1-6 → done` ~small

## QUEUE (Story 1.6)

- [ ] Transition PR Draft→Open — final CI gate (after Task 3)

## BLOCKED

_(none)_

## DONE (Story 1.6)

- [x] Story 1.6 Task 1 — authored `keel-invariants/no-verify-bypass` ESLint rule; plugin aggregator; registered in `sharedBase` + `forPackage()` with self-exclusion; `./eslint-plugin` subpath export; self-verify probes pass; all quality gates green
- [x] Story 1.6 Task 2 — ATDD probes all pass (AC 2 string-literal reject / AC 2b template-literal static-quasi reject + dynamic-quasi allow / negative comment-only allow / AC 5 prek-runner parity dirty-reject + clean-pass); defensive quality gates 16/16 FULL TURBO typecheck + lint, format:check clean, commitlint 0/0

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.5 done; 1.6 in-progress; 1.7–1.16 backlog)
- **Epic Branch:** `feat/story-1-6-quality-gate-bypass-prevention`
- **Story:** 1.6 — Quality-gate bypass prevention (Tasks 1–2 done; Task 3 remains)
- **Story File:** `_bmad-output/implementation-artifacts/1-6-quality-gate-bypass-prevention.md`
- **PR:** #222 Draft — `{isDraft:true, state:OPEN}`; CI wiring is Story 1.16's scope so `statusCheckRollup` stays empty
