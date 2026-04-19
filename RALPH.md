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

- 2026-04-19: Keel planning is complete — PRD, architecture, UX spec, epics 1-15b with stories, implementation-readiness all committed under `_bmad-output/planning-artifacts/`. Sprint-planning artifact now also exists at `_bmad-output/implementation-artifacts/sprint-status.yaml` (16 epics, 189 stories, all `backlog`). Next required gate: `/bmad-create-story` (Story 1.1).
- 2026-04-19: `/bmad-sprint-planning` with 189 stories exceeds hand-writing budget — the skill's step 1 regex (`### Story N.M:`) is OK but the per-story kebab-case conversion is mechanical. Used a throwaway Python script (`/tmp/gen_sprint_status.py`, not committed) invoked via `uv run --with pyyaml` for validation. Next Ralph: if regenerating, skip Python and just re-run `/bmad-sprint-planning` — the skill handles fuzzy matching.
- 2026-04-16: This repo runs Ralph inside worktrees under `.claude/worktrees/` (gitignored). Never `git worktree remove` on exit — the worktree preserves WIP for the next iteration.

## Lessons learned

Things that went wrong, and why — so the next Ralph doesn't repeat them.

- 2026-04-19: IP can drift badly between mini-epics when the user manually swaps branches outside a Ralph iteration. First action on every iteration: reconcile `.ralph/@plan.md` against the actual branch/PR state (`git branch --show-current`, `gh pr view`) before treating the IP NOW as authoritative. Stale DONE sections are harmless; a stale NOW is misleading.

## Gotchas

Rough edges in tools, flaky tests, odd repo conventions, environment quirks.

- 2026-04-19: The `WIP` GitHub Marketplace app sets a commit status that stays `IN_PROGRESS` while a PR is Draft and resolves green the instant the PR is marked ready. `gh pr checks --watch --fail-fast` on a Draft PR whose only check is WIP will hang indefinitely. If IP has both "Monitor PR CI" and "Transition Draft→Open" queued and the PR is Draft + only-WIP-pending, skip Monitor and go directly to Transition. Orient step 0h ("pending check → NOW=Monitor CI") has a carve-out for this: a solitary WIP-app check on a Draft PR is not real CI.

## Decisions

Choices made with rationale. Useful when a future Ralph wonders "why did past-Ralph do it this way?"

- 2026-04-16: Closed ralph-port as EPIC_DONE while PR #2 was still Open (not merged). Rationale: all implementation commits were already on the branch, CI was green, no review feedback pending, and merging is a user-authorization action. Halt signals the user to merge, then start planning.
- 2026-04-19: Same pattern, second time — closed ralph-gh-project-tracking as EPIC_DONE while PR #215 was Open (CI green, MERGEABLE, CLEAN, no reviews). Confirms the precedent: Ralph-tooling mini-epics on single-commit feat branches halt with EPIC_DONE as soon as the PR is Open + clean, regardless of merge status. User handles the merge.
- 2026-04-19: Third application — closed sprint-planning mini-epic as EPIC_DONE while PR #216 was Open (CLEAN, MERGEABLE, WIP check green, no reviews). Single-commit planning-artifact PR on `docs/keel-sprint-planning`. Precedent is now load-bearing across three consecutive mini-epics: single-commit planning-artifact or Ralph-tooling PRs halt with EPIC_DONE on Open+clean+no-reviews; user merges.

## Open questions

Things Ralph couldn't resolve autonomously and left for a human — cross-reference with `.ralph/@plan.md § BLOCKED`.

- _(empty)_
