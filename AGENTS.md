# Agent instructions — ralph-bmad

This file is the provider-neutral guide for any AI coding agent working in this repo (Claude Code, Codex, etc.). Claude Code reads `CLAUDE.md`, which points here.

## What this project is

`ralph-bmad` is scaffolded with the [BMad Method](https://docs.bmad-method.org) — a skill-driven workflow that takes a software idea through analysis, planning, solutioning, and implementation using AI agents.

The install is fresh. There is no product code yet. The first real work is a planning artifact (PRD, product brief, or PRFAQ), not code.

## Promotion rules

Where content belongs, by audience and scope. When you learn something new during a session, promote to the correct file.

| Audience / scope                            | File                                          |
| ------------------------------------------- | --------------------------------------------- |
| Applies to every AI agent (ops + truth)     | `AGENTS.md`                                   |
| Claude-Code-specific (skills, settings)     | `CLAUDE.md`                                   |
| Ralph-gotchas (iteration-loop lessons)      | `RALPH.md`                                    |
| Machine-enforced (config/rule/gate in code) | `INVARIANTS.md` + `packages/keel-invariants/` |

## Where things live

| Path                                     | What's there                                             |
| ---------------------------------------- | -------------------------------------------------------- |
| `_bmad/`                                 | BMad installation: modules, configs, skill manifests     |
| `_bmad/_config/manifest.yaml`            | Installed module versions                                |
| `_bmad/_config/bmad-help.csv`            | Catalog of every skill, phase, and menu code             |
| `_bmad-output/planning-artifacts/`       | PRDs, architecture, epics, UX specs (committed)          |
| `_bmad-output/implementation-artifacts/` | Stories, sprint plans (committed)                        |
| `_bmad-output/test-artifacts/`           | Test plans, traceability, gate decisions (committed)     |
| `.claude/skills/`                        | Skill definitions — the source of `/skill-name` commands |
| `docs/`                                  | Human-curated project knowledge base                     |

## How to work here

1. **Orient first.** Run `/bmad-help` (or read `_bmad/_config/bmad-help.csv`) to see what phase the project is in and what the next required step is.
2. **One skill per context window.** BMad skills assume a clean context. Don't chain several skills in one session — start a fresh conversation for each.
3. **Artifacts belong in `_bmad-output/`.** Don't scatter PRDs, stories, or test plans elsewhere. Follow the `output-location` declared in each skill.
4. **Respect required gates.** The `required=true` rows in `bmad-help.csv` are blocking — don't skip Create PRD, Create Architecture, Create Epics & Stories, Implementation Readiness, Sprint Planning, Create Story, or Dev Story unless the user explicitly opts out.
5. **Don't invent skills.** Only invoke skills listed in the Claude Code `available-skills` block or explicitly typed as `/<name>` by the user.

## Project conventions

- Communication language: **English**
- Document output language: **English**
- User: Tthew, intermediate skill level (see `_bmad/bmm/config.yaml`)
- Keep responses terse; the user prefers signal over ceremony.

## Git / PR conventions

- `main` is the default branch and the PR target.
- Branch names: `chore/*`, `feat/*`, `fix/*`, or `docs/*` — match the scope.
- Never force-push to `main`. Never skip hooks or signing.

## Fork extension (FR44)

Forks extend substrate ESLint rules without editing `packages/keel-invariants/` by creating `eslint.config.fork.js` at the fork root and importing `@keel/keel-invariants/eslint` (subpath export declared at `packages/keel-invariants/package.json:14`). Canonical copy-ready example:

```js
import sharedConfig from '@keel/keel-invariants/eslint';

export default [
  {
    rules: {
      /* fork-specific rules */
    },
  },
  ...sharedConfig, // substrate LAST → substrate wins (docs/invariants/fork.md § Precedence)
];
```

- **Precedence rule.** Substrate rules take precedence over fork rules at the same file glob via ESLint flat-config last-write-wins semantics + the spread-at-end convention. Forks that want the opposite posture (fork-wins) spread substrate FIRST; this is unusual and should carry a comment in the fork's `eslint.config.fork.js` explaining why.
- **Amendment-vs-fork decision.** Three paths when a fork disagrees with substrate: (a) FORK — fork-specific need, use `eslint.config.fork.js`; (b) AMEND — substrate-wide need, open a PR against `packages/keel-invariants/` + `INVARIANTS.md` + manifest entry + anchor bullet (the Story 1.6 + 1.9 source-level fork path); (c) DEFER — premature need, log in `_bmad-output/implementation-artifacts/deferred-work.md`.
- **Growth-tier `INVARIANTS.fork.md`.** See `docs/invariants/fork.md` § INVARIANTS.fork.md scaffold for the Growth-tier opt-in flow; Epic 15a's `create-keel-app --include-fork-invariants` flag is the downstream runtime automating the manual template copy.

## Ralph loop

- `ralph.py` is the TUI loop orchestrator. Run with `uv run ralph.py [build|plan] [N]`.
- Loop prompts live at `.ralph/PROMPT_build.md` and `.ralph/PROMPT_plan.md`.
- `RALPH.md` is Ralph's private journal — signposts, lessons, gotchas, decisions. Ralph reads it on orient and updates it before committing.
- Halt + plan-file + PROMPT + logs resolve to `$RALPH_BASE_DIR` (an absolute path ralph.py exports to every subprocess). When `--worktree X` is set, `$RALPH_BASE_DIR = <main_repo>/.claude/worktrees/X/.ralph/`; otherwise cwd-relative `.ralph/`. Write halt via `$RALPH_BASE_DIR/halt` — never a hardcoded main-repo absolute path.
- **Cross-epic transitions auto-advance in build-mode** (FR14n 2026-04-21): when the current epic's last story is `done` and the PR has merged, Ralph queues `/bmad-create-story` for the next epic's first story — no plan-mode roundtrip, no re-halt loop. See `.ralph/PROMPT_build.md` § Cross-epic transition.
- **Halt autonomy guardrail** (`INV-ralph-halt-reason-enum`): every halt reason is bounded; Ralph never halts waiting for open-ended human input; `AskUserQuestion` is not invoked from the runtime loop. Closed reason-set at 1.0: `EPIC_DONE`, `ALL_EPICS_DONE`, `AWAIT_MERGE`, `BUDGET_EXHAUSTED`, `CI_BLOCKED`, `SECURITY_CRITICAL`, `RALPH_STAGE_REGRESSION`.
- Full reference: [docs/ralph.md](./docs/ralph.md) — see § Halt path resolution + § Halt schema.

## When you're unsure

Prefer `/bmad-help` over guessing. If that doesn't resolve it, read the relevant `SKILL.md` under `.claude/skills/` — every skill is self-describing.
