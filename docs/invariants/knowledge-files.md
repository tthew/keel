# Invariant — Knowledge-File Upkeep Contract

**Scope:** every Ralph iteration (build mode + plan mode) on any Keel-forked repo.
**Status:** informational at 1.0; hard gate deferred to 1.1 Growth-tier.
**Machine-enforced in:** prek informational hook (1.0); commit-time reminder in `.ralph/PROMPT_*.md`.
**Normative spec:** `_bmad-output/planning-artifacts/prd.md` § Agent Workflow Contracts → Knowledge-file upkeep contract (FR14j).

## The three files

| File        | Audience                           | Contents                                                                          |
|-------------|------------------------------------|-----------------------------------------------------------------------------------|
| `AGENTS.md` | Any AI agent (Claude, Codex, etc.) | Operational truth — conventions, paths, git rules. Kept operational; no bloat.    |
| `CLAUDE.md` | Claude Code specifically           | Claude-Code quirks (skills, settings). Points to `AGENTS.md` for shared truth.    |
| `RALPH.md`  | Ralph (autonomous loop)            | Ralph's private journal — signposts, lessons, gotchas, decisions. One-line entries. |

## Promotion rules

- **Applies to every agent → `AGENTS.md`.** Commands, conventions, paths, git policy.
- **Claude-Code-specific → `CLAUDE.md`.** Skill behaviour, slash-command catalog, MCP config, settings.local.json caveats.
- **Ralph-flavoured → `RALPH.md`.** Past-iteration rationale, gotchas, decisions the next Ralph would benefit from knowing but that don't belong in operational truth.

## The upkeep rule

A "learned-but-did-not-write-down" iteration is by definition a wasted iteration. If an iteration discovers something non-obvious, the writer commits at least one knowledge-file update alongside the work — same commit is fine.

**Not required for routine iterations** that produce no new insight. The trigger is discovery, not the clock.

## Anti-patterns

- **Bloated `AGENTS.md`.** Every line lives in every agent's context on every loop. Operational only. If it's a one-time decision rationale, it goes to `RALPH.md`. If it's a Claude-Code quirk, it goes to `CLAUDE.md`.
- **Duplication across files.** `CLAUDE.md` points to `AGENTS.md` for shared truth; it does not re-state it.
- **`RALPH.md` as changelog.** `RALPH.md` is a journal of *decisions and gotchas*, not a diary of what changed. Git history is the changelog.

## Structure — `RALPH.md`

Four sections, dated one-liners, pruned on obsolescence:

```markdown
## Signposts
- <date> — one-line
## Lessons
- <date> — one-line
## Gotchas
- <date> — one-line
## Decisions
- <date> — one-line
```

## Fork enforcement

Substrate ships the three files at the 1.0 cut with empty-but-valid skeletons (`packages/keel-templates/` seeds). Forks inherit the upkeep contract; the prek informational hook and prompt-file reminders are non-toggle-able. A 1.1 Growth-tier candidate upgrades the informational hook to a hard gate gated on an iteration's declaration of whether it learned something non-obvious (self-declaration, audited by the monthly retrospective).
