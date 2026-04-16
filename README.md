# ralph-bmad

A project scaffolded with the [BMad Method](https://docs.bmad-method.org) — an opinionated, skill-driven workflow for taking software from idea to shipped code with AI agents.

## Status

Fresh install. No planning or implementation artifacts yet. The next step is Phase 1 (Analysis) or jumping straight to Phase 2 (Create PRD) — see `/bmad-help` in Claude Code for a guided recommendation.

## Layout

```
_bmad/                    BMad installation — modules, skills, configs
  _config/                Installation manifest and help catalog
  core/                   Core utilities (editorial review, sharding, etc.)
  bmm/                    BMad Method — the primary planning → dev workflow
  cis/                    Creative Intelligence Suite — brainstorming, design thinking
  tea/                    Test Architecture Enterprise — test design & automation
  bmb/                    BMad Builder — author your own modules / skills / agents

_bmad-output/             Generated artifacts (committed deliverables)
  planning-artifacts/     PRDs, architecture, epics, UX specs
  implementation-artifacts/  Stories, sprint plans
  test-artifacts/         Test plans, traceability, gate decisions

.claude/skills/           Skill definitions available to Claude Code
docs/                     Project knowledge base (human-curated)
```

## Installed modules

| Module                      | Version | Purpose                                   |
| --------------------------- | ------- | ----------------------------------------- |
| Core                        | 6.3.0   | Shared utilities (review, shard, distill) |
| BMad Method (bmm)           | 6.3.0   | PRD → architecture → stories → dev flow   |
| Creative Intelligence (cis) | 0.1.9   | Ideation, storytelling, innovation        |
| Test Architecture (tea)     | 1.7.2   | Test design, automation, NFRs             |
| BMad Builder (bmb)          | 1.5.0   | Build / edit agents, skills, modules      |

## Getting started

Inside Claude Code:

- `/bmad-help` — figure out where you are and what to do next
- `/bmad:product-brief` — a gentler start if the concept is already clear
- `/bmad:prd` — go straight to requirements once the idea is solid

Each skill is best run in a **fresh context window**.
