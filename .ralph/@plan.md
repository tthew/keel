# Implementation Plan

## NOW

- [x] Close out ralph-gh-project-tracking mini-epic — PR #215 Open, CI green, no reviews → EPIC_DONE ~small

## QUEUE (next phase: Keel implementation)

- [ ] After PR #215 merges, start Keel Epic 1 — invoke `/bmad-sprint-planning` in a fresh context to generate sprint status, then `/bmad-create-story` for Story 1.1

## BLOCKED

_(none)_

## DONE (ralph-gh-project-tracking mini-epic)

- [x] Discover GH Project on startup; map Story/Epic issues by title
- [x] Drive `Status` field: Story→In Progress at iteration start; Epic→Done on EPIC_DONE halt
- [x] Per-iteration env vars (`RALPH_ISSUE_*`, `RALPH_EPIC_ISSUE_*`, `RALPH_PROJECT_URL`) + prepended Issue Tracking prompt block
- [x] Positional iterations arg → `--iterations N` / `-n N`; `--gh-project URL` override; `--no-gh-project` escape hatch
- [x] Failures degrade to warnings; loop never halts on gh/auth/network issues
- [x] `docs/ralph.md` documents discovery, mapping, state-transition table, env vars

## Context

- **Phase:** 3-solutioning complete (PRD/architecture/UX/epics done) → 4-implementation not yet started; Ralph-tooling mini-epic closing this iteration
- **Epic:** ralph-gh-project-tracking (closing with EPIC_DONE this iteration)
- **Epic Branch:** feat/ralph-gh-project-tracking → PR #215 (Open, MERGEABLE, CLEAN, CI green)
- **Story:** n/a (feat on Ralph tooling, not a BMad story)
- **Story File:** n/a
