# Ralph TUI

Unified loop orchestrator and live dashboard for autonomous Claude Code sessions. A single full-screen [Textual](https://textual.textualize.io/) app that spawns `claude -p` as a subprocess, parses `stream-json` stdout, and manages the iteration loop.

## Quick start

```bash
uv run ralph.py                    # Build mode, unlimited iterations
uv run ralph.py build 5            # Build mode, max 5 iterations
uv run ralph.py plan               # Plan mode, unlimited
uv run ralph.py plan 3 --debug     # Plan mode, 3 iters, debug
uv run ralph.py --timeout 30m      # Custom per-iteration timeout
```

### Prerequisites

- **uv** — `curl -LsSf https://astral.sh/uv/install.sh | sh` (or `brew install uv`)
- **Python 3.10+** — uv handles this automatically
- **claude** — Claude Code CLI must be on `$PATH`

No `pip install`, no virtualenv. The PEP 723 `# /// script` block declares `textual>=1.0.0` and `uv run` resolves it.

## CLI reference

```
uv run ralph.py [build|plan] [N] [--timeout T] [--prompt STR]
                [--tool TOOL] [--model MODEL] [--effort LEVEL]
                [--safe | --unsafe] [--debug] [--worktree NAME]
                [--tool-arg KEY=VAL]... [--tool-flag FLAG]...
                [--tool-config PATH]
```

| Argument                   | Description                                                                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `mode`                     | `build` (default) or `plan`                                                                                                             |
| `N`                        | Max iterations (default: unlimited)                                                                                                     |
| `--timeout T`              | Per-iteration timeout. Accepts `15m`, `2h`, `90s`, or raw seconds. Default: `120m`. Also reads `ITERATION_TIMEOUT` env var.             |
| `--prompt STR`, `-p STR`   | One-shot initial instruction appended to the main prompt on iteration 1 only.                                                           |
| `--tool TOOL`              | Which AI coding CLI to invoke. Built-ins: `claude`, `codex`, `gemini`. Extend via `.ralph-tools.json`.                                  |
| `--model MODEL`            | Canonical `model`. Maps to `claude --model`, `codex --model`, `gemini -m`, etc.                                                         |
| `--effort {low,medium,high,xhigh,max}` | Canonical `effort` (reasoning level). Claude profile default: `xhigh` (per Anthropic's Opus 4.7 guidance for coding / agentic loops). |
| `--max-budget-usd AMOUNT`  | Canonical `max_budget_usd`. Per-iteration spend cap in USD (claude `--max-budget-usd`). Recommended at `xhigh`/`max` effort.                    |
| `--fallback-model MODEL`   | Canonical `fallback_model`. Fallback when the primary model is overloaded (claude `--fallback-model`).                                          |
| `--permission-mode MODE`   | Canonical `permission_mode`. Claude permission mode: `acceptEdits`, `auto`, `bypassPermissions`, `default`, `dontAsk`, `plan`. More granular than `--safe`/`--unsafe`. |
| `--safe` / `--unsafe`      | Canonical `unsafe` (e.g. claude `--dangerously-skip-permissions`, codex `--skip-git-repo-check`). Defaults to the tool's default (on). |
| `--debug`, `-d`            | Canonical `debug` flag. claude-only today.                                                                                              |
| `--worktree NAME`          | Canonical `worktree`. claude-only today.                                                                                                |
| `--tool-arg KEY=VAL`       | Passthrough; appends `[KEY, VAL]` to the subprocess argv. Repeatable.                                                                   |
| `--tool-flag FLAG`         | Passthrough; appends a bare flag to the subprocess argv. Repeatable.                                                                    |
| `--tool-config PATH`       | Alternate path for the project tool-config JSON (default: `.ralph-tools.json` in CWD).                                                  |

### Project tool-config: `.ralph-tools.json`

Optional, loaded from CWD. Layers on top of the in-code defaults (CLI flags still win):

```json
{
  "tools": {
    "claude": {
      "defaults": { "model": "claude-opus-4-7", "effort": "high" },
      "base_args_append": [],
      "flag_map_append":  {}
    },
    "my-fork": {
      "binary": "my-claude-fork",
      "base_args": ["-p", "--output-format", "stream-json", "--verbose"],
      "flag_map":  { "model": "--model", "effort": "--effort" },
      "defaults":  { "effort": "medium" },
      "stream_format": "claude-stream-json"
    }
  }
}
```

- Known tool names (claude/codex/gemini) merge onto the in-code profile.
- Unknown tool names register a new profile. `binary` is required; everything else is optional.
- `stream_format` selects the output adapter — `claude-stream-json` enables full token/cost/tool tracking; `plain` (default) just pipes stdout to the log.

Canonicals that a tool doesn't know about are silently dropped at command build time. When the user explicitly sets such a flag on the CLI (e.g. `--effort high --tool gemini`), Ralph logs a one-line dim warning under the first ITERATION header.

## Prompts

- `PROMPT_build.md` — build mode loop instructions (BMad-driven, one task per iteration)
- `PROMPT_plan.md` — planning mode loop instructions (gap analysis, no implementation)

Both are adapted for the `ralph-bmad` workflow: `bmad-*` skill naming, required-phase gates from `_bmad/_config/bmad-help.csv`, and `_bmad-output/` artifact locations.

## TUI layout

```
┌──────────────────────────────────────────────────────┐
│  Ralph Loop  ─  build  ─  feat/epic-…                │  session line
│  Iteration 3/10  ─  Turn 7  ─  Task list: ralph-…    │  iteration line
│  ████████░░░░░░░░░░  42%  (84K / 200K)  |  5h: …     │  context bar + ccusage
│  in: 45,231  out: 12,003  c_w: 8,100  c_r: 18,666    │  token breakdown
│  Cost: $0.12 (session: $0.38)  ─  Elapsed: 4m23s     │  cost / time
│  Last: Bash → git status                             │  last tool
├──────────────────────────────────────────────────────┤
│  🔧 Read → /path/to/file                             │  scrollable
│                                                      │  RichLog
│  ## Analysis                                         │
│  The file contains...                                │
│                                                      │
│  ── Iteration 1 Summary ──────────────────           │
│  ── ITERATION 2 ──────────────────                   │
│                                                      │
│  🔧 Glob → **/*.ts                                   │
└──────────────────────────────────────────────────────┘
  Shift+select to copy │ o: open log │ q: quit │ Log: ralph-logs/…
```

**Header** (top 7 lines) updates every second. **Output log** is a scrollable RichLog:

- New content auto-scrolls to bottom
- Scroll up to pause auto-follow; scroll back to bottom to resume
- Press `o` to open the session log in `$PAGER`
- Press `q` to quit

## Architecture

```
ralph.py (Textual App)
  ├── __main__: argparse → app.run()
  ├── on_mount: start run_loop() worker
  └── run_loop() worker thread:
      for each iteration:
        ├── subprocess.Popen(claude -p --output-format stream-json < PROMPT)
        ├── read stdout line by line → call_from_thread(process_event)
        ├── wait for exit → handle exit code
        ├── check .ralph-halt file
        ├── check AWAIT_MERGE in IMPLEMENTATION_PLAN.md
        └── continue or break
```

Since `ralph.py` owns the subprocess (not receiving piped stdin), Textual gets the terminal naturally — no stdin/tty fd swap needed.

## Features

| Feature                | Details                                                                                                                   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **Halt detection**     | Create `.ralph-halt` to stop the loop. Ralph reads and displays the halt reason.                                          |
| **AWAIT_MERGE**        | Loop stops when `IMPLEMENTATION_PLAN.md` contains a line starting with `(AWAIT_MERGE`.                                    |
| **Timeout**            | Per-iteration timer. On timeout, subprocess is terminated and mapped to exit code 124. Next iteration gets fresh context. |
| **Task persistence**   | Sets `CLAUDE_CODE_TASK_LIST_ID` so native Tasks survive across iterations. Cleaned up on halt.                            |
| **Exit code handling** | 130 = SIGINT (break), 124 = timeout (continue), other non-zero = error (continue).                                        |
| **Session tracking**   | Cumulative cost and elapsed time across all iterations.                                                                   |
| **ccusage integration**| If `ccusage` is on `$PATH`, shows 5h billing-block spend and remaining time.                                              |
| **Session logs**       | Every run writes a log to `ralph-logs/<branch>-<timestamp>.log`. `*.log` is already gitignored.                           |
