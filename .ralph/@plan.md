# Implementation Plan

## NOW

- [ ] Apply ralph.py halt-path resolver + doc/artefact updates on `chore/ralph-halt-path-resolution` ~medium (closes RALPH.md Open Question 2026-04-20; root-cause-fix for the Story 1.7 iter-22..28 re-entry cascade)

## QUEUE (ralph-tooling mini-epic → then Story 1.8)

- [ ] Phase 4 verification: run `uv run ralph.py build --iterations 1 --worktree ralph` from both main-repo cwd and worktree cwd; confirm startup banner, halt detection, clean exit
- [ ] Commit + push chore(ralph) branch; open PR targeting main
- [ ] After merge: `/bmad-create-story` for Story 1.8 (`invariants-manifest-ts-contract-exporter`) on a fresh `feat/story-1-8-*` branch

## BLOCKED

_(none)_

## DONE (ralph-tooling mini-epic — halt-path resolution)

- [x] Phase 1 recovery: deleted stale `/workspace/ralph-bmad/.ralph/halt`; reset worktree `.ralph/@plan.md` off main's `chore/ralph-halt-path-resolution`; synced stale main-repo `.ralph/@plan.md` (removed Story 1.6 `(AWAIT_MERGE` marker so a main-cwd session doesn't mis-halt).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.7 done; 1.8–1.16 backlog). This branch is a ralph-tooling chore, not an Epic 1 story.
- **Epic Branch:** `chore/ralph-halt-path-resolution`
- **Story:** none — ralph-tooling chore (root-cause fix for halt-path mismatch between ralph.py cwd and agent cwd)
- **Story File:** n/a
- **Story State:** _(no story)_
