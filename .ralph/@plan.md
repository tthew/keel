# Implementation Plan

## NOW

- [ ] Story 1.6 Task 1 — author `keel-invariants/no-verify-bypass` ESLint rule + register in shared config + `./eslint-plugin` subpath export ~medium

## QUEUE (Story 1.6)

- [ ] Story 1.6 Task 2 — ATDD probes (AC 2 bypass-string rejects / AC 2b template-literal / negative comment / AC 5 prek-runner parity)
- [ ] Story 1.6 Task 3 — full quality gates + sprint-status `1-6 → done`
- [ ] Transition PR Draft→Open — final CI gate (after Task 3)

## BLOCKED

_(none)_

## DONE (Story 1.6)

- [x] Post-merge sync — PR #221 merged as `297402c`; new branch `feat/story-1-6-quality-gate-bypass-prevention` from `origin/main`; stale `(AWAIT_MERGE` marker cleared
- [x] Story 1.6 spec authored — 3-task decomposition; `_bmad-output/implementation-artifacts/1-6-quality-gate-bypass-prevention.md`; sprint-status `1-6 → ready-for-dev`; Scope Carve-Out for AC 1/3/4 (forward-refs to Stories 1.8+1.9)
- [x] Draft PR #222 created targeting main — `{isDraft:true, state:OPEN, statusCheckRollup:[]}`; IP reflects PR reference (iteration-1 bookkeeping, matches Story 1.5 precedent)

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.5 done; 1.6 ready-for-dev; 1.7–1.16 backlog)
- **Epic Branch:** `feat/story-1-6-quality-gate-bypass-prevention`
- **Story:** 1.6 — Quality-gate bypass prevention (ready-for-dev)
- **Story File:** `_bmad-output/implementation-artifacts/1-6-quality-gate-bypass-prevention.md`
- **PR:** #222 Draft (created this iteration; `{isDraft:true, state:OPEN, statusCheckRollup:[]}` — no CI wired yet, Story 1.16's scope)
