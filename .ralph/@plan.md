# Implementation Plan

## NOW

- [ ] Story 1.6 Task 2 — ATDD probes (AC 2 bypass-string rejects / AC 2b template-literal / negative comment / AC 5 prek-runner parity) ~medium

## QUEUE (Story 1.6)

- [ ] Story 1.6 Task 3 — full quality gates + sprint-status `1-6 → done`
- [ ] Transition PR Draft→Open — final CI gate (after Task 3)

## BLOCKED

_(none)_

## DONE (Story 1.6)

- [x] Post-merge sync — PR #221 merged as `297402c`; new branch `feat/story-1-6-quality-gate-bypass-prevention` from `origin/main`; stale `(AWAIT_MERGE` marker cleared
- [x] Story 1.6 spec authored — 3-task decomposition; `_bmad-output/implementation-artifacts/1-6-quality-gate-bypass-prevention.md`; sprint-status `1-6 → ready-for-dev`; Scope Carve-Out for AC 1/3/4 (forward-refs to Stories 1.8+1.9)
- [x] Draft PR #222 created targeting main — `{isDraft:true, state:OPEN, statusCheckRollup:[]}`; IP reflects PR reference (iteration-1 bookkeeping, matches Story 1.5 precedent)
- [x] Story 1.6 Task 1 — authored `keel-invariants/no-verify-bypass` ESLint rule (ESM `.js`, `Literal`+`TemplateElement` visitor, lookbehind/lookahead boundary); plugin aggregator; registered in `sharedBase` + `forPackage()` with self-exclusion; `./eslint-plugin` subpath export added; self-verify probes pass; `pnpm -w typecheck` 16/16 + `pnpm -w lint` 16/16 + `pnpm format:check` clean + `commitlint` 0/0

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.5 done; 1.6 in-progress; 1.7–1.16 backlog)
- **Epic Branch:** `feat/story-1-6-quality-gate-bypass-prevention`
- **Story:** 1.6 — Quality-gate bypass prevention (Task 1 done; Tasks 2–3 remain)
- **Story File:** `_bmad-output/implementation-artifacts/1-6-quality-gate-bypass-prevention.md`
- **PR:** #222 Draft — `{isDraft:true, state:OPEN}`; CI wiring is Story 1.16's scope so `statusCheckRollup` stays empty
