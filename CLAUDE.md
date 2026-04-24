# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See [AGENTS.md](./AGENTS.md) for the full agent guide — it is the source of truth for any AI coding agent (Claude Code, Codex, etc.). The notes below are Claude-Code-specific or Ralph-loop-specific supplements.

## What this repo is

A BMad Method v6.3.0 project (`bmad-method` + `core`, `cis`, `tea`, `bmb` modules). Fresh install — no product code yet. The first real work is a planning artifact (PRD, product brief, or PRFAQ), not code. See [README.md](./README.md) for module inventory.

## Common commands

There is no build/test/lint suite yet (nothing to build). The operational surface is the BMad skills and the Ralph loop.

| Task                              | Command                                                         |
| --------------------------------- | --------------------------------------------------------------- |
| Figure out the next required step | `/bmad-help` (reads `_bmad/_config/bmad-help.csv`)              |
| Run a BMad workflow               | `/<skill-name>` — e.g. `/bmad-create-prd`, `/bmad-create-story` |
| Run Ralph in planning mode        | `uv run ralph.py plan [N]`                                      |
| Run Ralph in build mode           | `uv run ralph.py build [N]`                                     |
| Ralph with custom timeout         | `uv run ralph.py --timeout 30m`                                 |
| Stop the Ralph loop               | `echo '{"reason":"EPIC_DONE",...}' > "$RALPH_BASE_DIR/halt"`    |

Ralph writes session logs to `$RALPH_BASE_DIR/logs/` (gitignored). `$RALPH_BASE_DIR/halt` is the halt sentinel (also gitignored). `RALPH_BASE_DIR` is exported by `ralph.py` to every subprocess and resolves to the worktree's `.ralph/` directory when `--worktree X` is set (or cwd-relative `.ralph/` otherwise). See [docs/ralph.md](./docs/ralph.md#halt-path-resolution) for the resolver + invocation-mode table.

## High-level architecture

Two overlapping systems in this repo:

**1. BMad skill system.** Skills under `.claude/skills/<name>/SKILL.md` are invocable as `/<name>` slash commands. They drive a phased workflow (analysis → planning → solutioning → implementation). The catalog of every skill, its required-status, and its phase lives in `_bmad/_config/bmad-help.csv`. Required gates (PRD, Architecture, Epics & Stories, Implementation Readiness, Sprint Planning, Create Story, Dev Story) are blocking — don't skip them. Every skill declares an `output-location` — artifacts belong in `_bmad-output/`, not scattered. Prefix: `bmad-*` (not `bmad_bmm_*`).

**2. Ralph loop.** `ralph.py` is a Textual TUI that spawns `claude -p` in a subprocess, reads `stream-json`, and manages an iteration loop. Per iteration it reads one of two prompt files:

- `.ralph/PROMPT_build.md` — one task per iteration, commit + push + exit
- `.ralph/PROMPT_plan.md` — gap analysis, IP update, no code changes

The loop halts on `$RALPH_BASE_DIR/halt`, on `(AWAIT_MERGE` in `$RALPH_BASE_DIR/@plan.md`, or at `max_iterations`. State carries between iterations via `$RALPH_BASE_DIR/@plan.md` (committed) and native Claude Code tasks (via `CLAUDE_CODE_TASK_LIST_ID`). Paths resolve against the worktree when `--worktree X` is set — never use hardcoded main-repo absolutes. See [docs/ralph.md § Halt path resolution](./docs/ralph.md).

## Knowledge-file contract

Four files serve distinct audiences. Don't conflate them.

| File                                         | Audience                                           | Contents                                                                                                                                                                                                                                                         |
| -------------------------------------------- | -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AGENTS.md`                                  | Any AI agent (Claude, Codex, etc.)                 | Authoritative operational guide — conventions, paths, git rules                                                                                                                                                                                                  |
| `CLAUDE.md`                                  | Claude Code specifically                           | Claude-Code quirks (skills, settings) + pointers to AGENTS.md and RALPH.md                                                                                                                                                                                       |
| `RALPH.md`                                   | Ralph (autonomous loop)                            | Ralph's private journal — signposts, lessons, gotchas, decisions                                                                                                                                                                                                 |
| `INVARIANTS.md`                              | Any AI agent or human — machine-enforced rules     | Agent-readable index of stable IDs mapping to `packages/keel-invariants/` (FR42; drift-detected by Story 1.9 sync-gate per FR43)                                                                                                                                 |
| `INVARIANTS.fork.md` (Growth-tier, optional) | Fork-specific agent/human — machine-enforced rules | Fork-owned additive rules to upstream INVARIANTS.md; substrate rules take precedence (FR45; `docs/invariants/fork.md` § Precedence). Not present at 1.0 — fork operators opt in by copying `packages/keel-invariants/templates/INVARIANTS.fork.md` to repo root. |

Precedence: upstream `INVARIANTS.md` is authoritative for every rule registered in `invariants.manifest.ts`; `INVARIANTS.fork.md` (when a fork opts in) is additive — fork rules ADD TO substrate but cannot override it. See `docs/invariants/fork.md` § Precedence + § Amendment-vs-fork decision tree for the opt-in flow + conflict-resolution paths.

When you discover something new during a session:

- Applies to every agent → promote to `AGENTS.md`
- Claude-Code-specific (skill behavior, `.claude/` config) → `CLAUDE.md`
- Ralph-flavored (gotchas, iteration lessons, rationale for past choices) → `RALPH.md`
- Machine-enforced (config / lint rule / pre-merge gate in code) → `INVARIANTS.md` + `packages/keel-invariants/`

## Promotion rules

| Audience / scope                            | File                                          |
| ------------------------------------------- | --------------------------------------------- |
| Applies to every AI agent (ops + truth)     | `AGENTS.md`                                   |
| Claude-Code-specific (skills, settings)     | `CLAUDE.md`                                   |
| Ralph-gotchas (iteration-loop lessons)      | `RALPH.md`                                    |
| Machine-enforced (config/rule/gate in code) | `INVARIANTS.md` + `packages/keel-invariants/` |

## Claude Code specifics

- **Skills are slash commands.** Anything under `.claude/skills/<name>/SKILL.md` is invocable as `/<name>`. Use `/bmad-help` to pick the right one for the current phase.
- **One skill per context window.** BMad skills assume a clean context. Start a fresh conversation for each.
- **Memory.** BMad agent sidecar memory lives in `_bmad/_memory/`. Claude Code user-level memory lives outside this repo (`~/.claude/...`). Don't persist transient task state to either.
- **Committed settings at `.claude/settings.json`** — tracked permission policy (`permissions.deny` + `permissions.allow`) per NFR5a. See `AGENTS.md § Claude Code settings policy (Story 2.15)` for the fork-extension honour system. Don't edit to weaken the deny list — Story 2.17's content-hash sync-gate will flag tampering once landed.
- **Don't touch `.claude/settings.local.json`** — it's user-specific and gitignored. Local allow rules extend but cannot weaken committed deny rules (see `AGENTS.md § Claude Code settings policy (Story 2.15)` for resolution semantics).
- **Don't invent skills.** Only invoke skills listed in the Claude Code `available-skills` block or explicitly typed as `/<name>` by the user.
- **Worktrees.** If you're running inside a worktree under `.claude/worktrees/` (gitignored), never clean it up on exit — the worktree preserves WIP for the next iteration.

## Git / PR conventions

Inherited from AGENTS.md: `main` is the default branch and PR target. Branches use `chore/*`, `feat/*`, `fix/*`, `docs/*` scopes. Never force-push `main`, never skip hooks or signing.
