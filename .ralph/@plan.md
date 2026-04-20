# Implementation Plan

## NOW

- [ ] Story 1.7 Task 1 — author `INVARIANTS.md` at repo root with audience header + promotion-rule table + 9-entry stable-ID index (Stories 1.2/1.3/1.4/1.5/1.6 invariants) ~medium

## QUEUE (Story 1.7)

- [ ] Story 1.7 Task 2 — align audience headers + promotion-rule table (verbatim) in `AGENTS.md` / `CLAUDE.md` / `RALPH.md`; extend CLAUDE.md's Knowledge-file contract table with INVARIANTS.md row; add RALPH.md scope note per AC 5
- [ ] Story 1.7 Task 3 — quality gates (typecheck / lint / format:check / commitlint / prek-runner) + sprint-status bump `1-7 → done` + story Status `ready-for-dev → done`
- [ ] Transition PR #224 Draft→Open — rewrite title/body for full spec+Tasks-1-3 commit range; EPIC_DONE halt (mini-epic convention)

## BLOCKED

_(none)_

## DONE (Story 1.7 iter-1)

- [x] Cut fresh branch `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules` from `origin/main` (--no-track)
- [x] Author `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md` (3-task decomposition; scope carve-out for AC 3 → Stories 1.8/1.9)
- [x] Bump sprint-status `1-7 → ready-for-dev` + `last_updated`
- [x] Reset IP (clear stale AWAIT_MERGE, seed Story 1.7 context)
- [x] Commit spec+sprint-status+IP+RALPH signpost (`463b3ec`); push; create Draft PR #224 (`{isDraft:true, state:OPEN, statusCheckRollup:[]}` — Story 1.16 still owes CI workflows, empty rollup expected per Story 1.6 precedent)

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 in flight; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** drafted
