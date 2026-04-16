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

- 2026-04-16: Fresh BMad install — no product code, no planning artifacts. First real work is a planning artifact (PRD / product brief / PRFAQ), not code. Build-mode Ralph cannot produce these; run planning skills (`/bmad-product-brief`, `/bmad-create-prd`) in fresh contexts instead.
- 2026-04-16: This repo runs Ralph inside worktrees under `.claude/worktrees/` (gitignored). Never `git worktree remove` on exit — the worktree preserves WIP for the next iteration.

## Lessons learned

Things that went wrong, and why — so the next Ralph doesn't repeat them.

- _(empty)_

## Gotchas

Rough edges in tools, flaky tests, odd repo conventions, environment quirks.

- _(empty)_

## Decisions

Choices made with rationale. Useful when a future Ralph wonders "why did past-Ralph do it this way?"

- 2026-04-16: Closed ralph-port as EPIC_DONE while PR #2 was still Open (not merged). Rationale: all implementation commits were already on the branch, CI was green, no review feedback pending, and merging is a user-authorization action. Halt signals the user to merge, then start planning.

## Open questions

Things Ralph couldn't resolve autonomously and left for a human — cross-reference with `IMPLEMENTATION_PLAN.md § BLOCKED`.

- _(empty)_
