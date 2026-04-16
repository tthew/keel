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
uv run ralph.py [build|plan] [N] [--debug] [--timeout T] [--worktree NAME]
```

| Argument        | Description                                                                                                                |
| --------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `mode`          | `build` (default) or `plan`                                                                                                |
| `N`             | Max iterations (default: unlimited)                                                                                        |
| `--debug`, `-d` | Pass `--debug` to claude                                                                                                   |
| `--timeout T`   | Per-iteration timeout. Accepts `15m`, `2h`, `90s`, or raw seconds. Default: `120m`. Also reads `ITERATION_TIMEOUT` env var.|
| `--worktree`    | Name of Git worktree to pass to Claude                                                                                     |

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
