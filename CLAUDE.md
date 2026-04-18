# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See [AGENTS.md](./AGENTS.md) for the full agent guide — it is the source of truth for any AI coding agent (Claude Code, Codex, etc.). The notes below are Claude-Code-specific or Ralph-loop-specific supplements.

## What this repo is

A BMad Method v6.3.0 project (`bmad-method` + `core`, `cis`, `tea`, `bmb` modules). Fresh install — no product code yet. The first real work is a planning artifact (PRD, product brief, or PRFAQ), not code. See [README.md](./README.md) for module inventory.

## Common commands

There is no build/test/lint suite yet (nothing to build). The operational surface is the BMad skills and the Ralph loop.

| Task                            | Command                                           |
| ------------------------------- | ------------------------------------------------- |
| Figure out the next required step | `/bmad-help` (reads `_bmad/_config/bmad-help.csv`) |
| Run a BMad workflow             | `/<skill-name>` — e.g. `/bmad-create-prd`, `/bmad-create-story` |
| Run Ralph in planning mode      | `uv run ralph.py plan [N]`                        |
| Run Ralph in build mode         | `uv run ralph.py build [N]`                       |
| Ralph with custom timeout       | `uv run ralph.py --timeout 30m`                   |
| Stop the Ralph loop             | `echo '{"reason":"EPIC_DONE",...}' > .ralph/halt` |

Ralph writes session logs to `.ralph/logs/` (gitignored). `.ralph/halt` is the halt sentinel (also gitignored). See [docs/ralph.md](./docs/ralph.md) for the full TUI reference.

## High-level architecture

Two overlapping systems in this repo:

**1. BMad skill system.** Skills under `.claude/skills/<name>/SKILL.md` are invocable as `/<name>` slash commands. They drive a phased workflow (analysis → planning → solutioning → implementation). The catalog of every skill, its required-status, and its phase lives in `_bmad/_config/bmad-help.csv`. Required gates (PRD, Architecture, Epics & Stories, Implementation Readiness, Sprint Planning, Create Story, Dev Story) are blocking — don't skip them. Every skill declares an `output-location` — artifacts belong in `_bmad-output/`, not scattered. Prefix: `bmad-*` (not `bmad_bmm_*`).

**2. Ralph loop.** `ralph.py` is a Textual TUI that spawns `claude -p` in a subprocess, reads `stream-json`, and manages an iteration loop. Per iteration it reads one of two prompt files:

- `.ralph/PROMPT_build.md` — one task per iteration, commit + push + exit
- `.ralph/PROMPT_plan.md` — gap analysis, IP update, no code changes

The loop halts on `.ralph/halt`, on `(AWAIT_MERGE` in `.ralph/@plan.md`, or at `max_iterations`. State carries between iterations via `.ralph/@plan.md` (committed) and native Claude Code tasks (via `CLAUDE_CODE_TASK_LIST_ID`).

## Knowledge-file contract

Three files serve distinct audiences. Don't conflate them.

| File        | Audience                          | Contents                                                                  |
| ----------- | --------------------------------- | ------------------------------------------------------------------------- |
| `AGENTS.md` | Any AI agent (Claude, Codex, etc.)| Authoritative operational guide — conventions, paths, git rules           |
| `CLAUDE.md` | Claude Code specifically          | Claude-Code quirks (skills, settings) + pointers to AGENTS.md and RALPH.md |
| `RALPH.md`  | Ralph (autonomous loop)           | Ralph's private journal — signposts, lessons, gotchas, decisions          |

When you discover something new during a session:

- Applies to every agent → promote to `AGENTS.md`
- Claude-Code-specific (skill behavior, `.claude/` config) → `CLAUDE.md`
- Ralph-flavored (gotchas, iteration lessons, rationale for past choices) → `RALPH.md`

## Claude Code specifics

- **Skills are slash commands.** Anything under `.claude/skills/<name>/SKILL.md` is invocable as `/<name>`. Use `/bmad-help` to pick the right one for the current phase.
- **One skill per context window.** BMad skills assume a clean context. Start a fresh conversation for each.
- **Memory.** BMad agent sidecar memory lives in `_bmad/_memory/`. Claude Code user-level memory lives outside this repo (`~/.claude/...`). Don't persist transient task state to either.
- **Don't touch `.claude/settings.local.json`** — it's user-specific and gitignored.
- **Don't invent skills.** Only invoke skills listed in the Claude Code `available-skills` block or explicitly typed as `/<name>` by the user.
- **Worktrees.** If you're running inside a worktree under `.claude/worktrees/` (gitignored), never clean it up on exit — the worktree preserves WIP for the next iteration.

## Git / PR conventions

Inherited from AGENTS.md: `main` is the default branch and PR target. Branches use `chore/*`, `feat/*`, `fix/*`, `docs/*` scopes. Never force-push `main`, never skip hooks or signing.
