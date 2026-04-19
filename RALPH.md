# RALPH.md — notes from Ralph, to Ralph

This file is Ralph's private workspace. It is **not** the authoritative agent guide (that's `AGENTS.md`, linked from `CLAUDE.md`). This is where Ralph leaves signposts, lessons, gotchas, and decisions for the next Ralph who picks up the loop.

Rules:

- Append, don't rewrite history. The value is cumulative.
- Keep entries terse. One line is often enough. A future Ralph will skim this fast.
- Date every entry (ISO `YYYY-MM-DD`) so stale knowledge can be pruned.
- Prune: if a note is obsolete because the underlying state changed, delete it. Don't leave lies.
- If a note becomes authoritative and applies to any agent (not just Ralph), promote it to `AGENTS.md` and remove it here.

## Signposts (read me first)

Things the next Ralph should know before doing anything.

- 2026-04-19: Keel planning is complete — PRD, architecture, UX spec, epics 1-15b with stories, implementation-readiness all committed under `_bmad-output/planning-artifacts/`. Next implementation phase starts with `/bmad-sprint-planning` (required gate) → `/bmad-create-story`. The earlier "fresh install / no planning artifacts" signpost is obsolete.
- 2026-04-16: This repo runs Ralph inside worktrees under `.claude/worktrees/` (gitignored). Never `git worktree remove` on exit — the worktree preserves WIP for the next iteration.

## Lessons learned

Things that went wrong, and why — so the next Ralph doesn't repeat them.

- 2026-04-19: IP can drift badly between mini-epics when the user manually swaps branches outside a Ralph iteration. First action on every iteration: reconcile `.ralph/@plan.md` against the actual branch/PR state (`git branch --show-current`, `gh pr view`) before treating the IP NOW as authoritative. Stale DONE sections are harmless; a stale NOW is misleading.

## Gotchas

Rough edges in tools, flaky tests, odd repo conventions, environment quirks.

- _(empty)_

## Decisions

Choices made with rationale. Useful when a future Ralph wonders "why did past-Ralph do it this way?"

- 2026-04-16: Closed ralph-port as EPIC_DONE while PR #2 was still Open (not merged). Rationale: all implementation commits were already on the branch, CI was green, no review feedback pending, and merging is a user-authorization action. Halt signals the user to merge, then start planning.
- 2026-04-19: Same pattern, second time — closed ralph-gh-project-tracking as EPIC_DONE while PR #215 was Open (CI green, MERGEABLE, CLEAN, no reviews). Confirms the precedent: Ralph-tooling mini-epics on single-commit feat branches halt with EPIC_DONE as soon as the PR is Open + clean, regardless of merge status. User handles the merge.

## Open questions

Things Ralph couldn't resolve autonomously and left for a human — cross-reference with `.ralph/@plan.md § BLOCKED`.

- _(empty)_
