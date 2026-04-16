# Claude Code instructions

See [AGENTS.md](./AGENTS.md) for the full agent guide — it is the source of truth and applies to Claude Code.

## Claude Code specifics

- **Skills are available as slash commands.** Anything under `.claude/skills/<name>/SKILL.md` can be invoked as `/<name>`. Use `/bmad-help` to find the right skill for the current phase.
- **Memory lives in `_bmad/_memory/`** (for BMad agent sidecars) and in Claude Code's user-level memory system (outside this repo). Don't persist transient task state to either.
- **Don't touch `.claude/settings.local.json`** — it's user-specific and gitignored.
- **Run each BMad skill in a fresh context window.** Start a new conversation when the user invokes a new skill.
