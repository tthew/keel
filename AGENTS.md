# Agent instructions — ralph-bmad

This file is the provider-neutral guide for any AI coding agent working in this repo (Claude Code, Codex, etc.). Claude Code reads `CLAUDE.md`, which points here.

## What this project is

`ralph-bmad` is scaffolded with the [BMad Method](https://docs.bmad-method.org) — a skill-driven workflow that takes a software idea through analysis, planning, solutioning, and implementation using AI agents.

The install is fresh. There is no product code yet. The first real work is a planning artifact (PRD, product brief, or PRFAQ), not code.

## Where things live

| Path                              | What's there                                             |
| --------------------------------- | -------------------------------------------------------- |
| `_bmad/`                          | BMad installation: modules, configs, skill manifests     |
| `_bmad/_config/manifest.yaml`     | Installed module versions                                |
| `_bmad/_config/bmad-help.csv`     | Catalog of every skill, phase, and menu code             |
| `_bmad-output/planning-artifacts/`      | PRDs, architecture, epics, UX specs (committed)    |
| `_bmad-output/implementation-artifacts/`| Stories, sprint plans (committed)                  |
| `_bmad-output/test-artifacts/`          | Test plans, traceability, gate decisions (committed) |
| `.claude/skills/`                 | Skill definitions — the source of `/skill-name` commands |
| `docs/`                           | Human-curated project knowledge base                     |

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

## When you're unsure

Prefer `/bmad-help` over guessing. If that doesn't resolve it, read the relevant `SKILL.md` under `.claude/skills/` — every skill is self-describing.
