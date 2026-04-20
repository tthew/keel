# Ralph TUI

Unified loop orchestrator and live dashboard for autonomous Claude Code sessions. A single full-screen [Textual](https://textual.textualize.io/) app that spawns `claude -p` as a subprocess, parses `stream-json` stdout, and manages the iteration loop.

## Quick start

```bash
uv run ralph.py                        # Build mode, unlimited iterations
uv run ralph.py build --iterations 5   # Build mode, max 5 iterations
uv run ralph.py plan                   # Plan mode, unlimited
uv run ralph.py plan -n 3 --debug      # Plan mode, 3 iters, debug
uv run ralph.py --timeout 30m          # Custom per-iteration timeout
```

### Prerequisites

- **uv** — `curl -LsSf https://astral.sh/uv/install.sh | sh` (or `brew install uv`)
- **Python 3.10+** — uv handles this automatically
- **claude** — Claude Code CLI must be on `$PATH`

No `pip install`, no virtualenv. The PEP 723 `# /// script` block declares `textual>=1.0.0` and `uv run` resolves it.

## CLI reference

```
uv run ralph.py [build|plan] [--iterations N] [--timeout T] [--prompt STR]
                [--tool TOOL] [--model MODEL] [--effort LEVEL]
                [--safe | --unsafe] [--debug] [--worktree NAME]
                [--gh-project URL | --no-gh-project]
                [--tool-arg KEY=VAL]... [--tool-flag FLAG]...
                [--tool-config PATH]
```

| Argument                   | Description                                                                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `mode`                     | `build` (default) or `plan`                                                                                                             |
| `--iterations N`, `-n N`   | Max iterations (default: unlimited, i.e. `0`). Replaces the old positional `N` argument.                                               |
| `--timeout T`              | Per-iteration timeout. Accepts `15m`, `2h`, `90s`, or raw seconds. Default: `120m`. Also reads `ITERATION_TIMEOUT` env var.             |
| `--prompt STR`, `-p STR`   | One-shot initial instruction appended to the main prompt on iteration 1 only.                                                           |
| `--tool TOOL`              | Which AI coding CLI to invoke. Built-ins: `claude`, `codex`, `gemini`. Extend via `.ralph/tools.json`.                                  |
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
| `--tool-config PATH`       | Alternate path for the project tool-config JSON (default: `.ralph/tools.json` in CWD).                                                  |
| `--gh-project URL`         | GitHub Project URL override (e.g. `https://github.com/users/<u>/projects/<n>`). Skip to auto-detect from `gh project list --owner @me`. |
| `--no-gh-project`          | Disable GH Project integration (no issue transitions, no prompt injection).                                                             |

### Project tool-config: `.ralph/tools.json`

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

## GitHub Project integration

When a GitHub Project is reachable, Ralph drives the project's **Status** field for observability. The integration is best-effort: `gh` CLI failures, missing auth, or unreachable projects degrade to a yellow warning line in the log — the loop continues.

### Discovery

On startup (background thread), Ralph resolves a project in this order:

1. `--gh-project URL` (explicit override).
2. `gh project list --owner @me` — if exactly one open project exists, use it.
3. Otherwise, pick the first open project whose items include an issue on the current repo.

Pass `--no-gh-project` to disable entirely.

### Issue mapping

Project items are matched by title:

- **Stories:** titles starting with `Story <N>.<M>:` — e.g. `Story 15a.5:` maps to story id `15a.5`.
- **Epics:** titles starting with `Epic <N>:` — e.g. `Epic 3:` maps to epic id `3`; `Epic 15b:` to `15b`.

The current iteration's story and epic come from `.ralph/@plan.md` § Context:

```markdown
## Context

- **Epic:** Epic 15a - CreateKeelApp
- **Story:** 15a.3
```

`"none"` / `"n/a"` / `"tbd"` in those fields skip the lookup for that iteration.

### State transitions

| When                            | Ralph action                                                                                  |
| ------------------------------- | --------------------------------------------------------------------------------------------- |
| Iteration start (story in plan) | Transition story issue `→ In Progress` (idempotent — skipped if already set).                 |
| Iteration exit (any outcome)    | No transition from Ralph. Left to GH's native PR-merge automation via `Closes #N` in PR body. |
| `EPIC_DONE` halt                | Transition the epic issue `→ Done` directly.                                                  |
| Failure / timeout               | No transition — issue stays `In Progress` to signal attention.                                |

Story → Done is deliberately NOT driven from ralph.py. GitHub Projects has a built-in workflow that moves an issue to Done when it's closed, and `Closes #N` in a merged PR closes the issue. Double-transitioning from ralph.py would race this workflow and produce misleading history.

### Subprocess environment

When a story/epic is resolved, Ralph sets these env vars on the spawned tool process and prepends an **Issue Tracking (this iteration)** block to the prompt:

| Var                       | Contents                                      |
| ------------------------- | --------------------------------------------- |
| `RALPH_ISSUE_NUMBER`      | Story issue number (int).                     |
| `RALPH_ISSUE_URL`         | Story issue URL.                              |
| `RALPH_EPIC_ISSUE_NUMBER` | Parent epic issue number.                     |
| `RALPH_EPIC_ISSUE_URL`    | Parent epic issue URL.                        |
| `RALPH_PROJECT_URL`       | Project board URL.                            |

The prompt prepend instructs Ralph to include `Refs #N` in commit trailers and `Closes #N` in the PR body when the story is complete. See `.ralph/PROMPT_build.md` § Issue Tracking.

## Prompts

- `.ralph/PROMPT_build.md` — build mode loop instructions (BMad-driven, one task per iteration)
- `.ralph/PROMPT_plan.md` — planning mode loop instructions (gap analysis, no implementation)

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
│  Story 15a.3 #204 [In Progress] ─ Epic 15a #23 ─ …  │  GH project
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
  Shift+select to copy │ o: open log │ q: quit │ Log: .ralph/logs/…
```

**Header** (top 8 lines) updates every second. **Output log** is a scrollable RichLog:

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
        ├── check .ralph/halt file
        ├── check AWAIT_MERGE in .ralph/@plan.md
        └── continue or break
```

Since `ralph.py` owns the subprocess (not receiving piped stdin), Textual gets the terminal naturally — no stdin/tty fd swap needed.

## Features

| Feature                | Details                                                                                                                   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **Halt detection**     | Create `.ralph/halt` to stop the loop. Ralph reads and displays the halt reason.                                          |
| **AWAIT_MERGE**        | Loop stops when `.ralph/@plan.md` contains a line starting with `(AWAIT_MERGE`.                                           |
| **Timeout**            | Per-iteration timer. On timeout, subprocess is terminated and mapped to exit code 124. Next iteration gets fresh context. |
| **Task persistence**   | Sets `CLAUDE_CODE_TASK_LIST_ID` so native Tasks survive across iterations. Cleaned up on halt.                            |
| **Exit code handling** | 130 = SIGINT (break), 124 = timeout (continue), other non-zero = error (continue).                                        |
| **Session tracking**   | Cumulative cost and elapsed time across all iterations.                                                                   |
| **ccusage integration**| If `ccusage` is on `$PATH`, shows 5h billing-block spend and remaining time.                                              |
| **Session logs**       | Every run writes a log to `.ralph/logs/<branch>-<timestamp>.log`. `.ralph/logs/` is gitignored.                           |

## Loop contracts

This doc describes the Ralph TUI runtime. The loop's **behavioural contracts** — what every iteration MUST do — live elsewhere and are enforced by the prompt files, not by `ralph.py`:

- **Normative spec:** `_bmad-output/planning-artifacts/prd.md` § Agent Workflow Contracts (FR14f–FR14k, NFR4b / NFR28a / NFR33a).
- **Runtime enforcement:** `.ralph/PROMPT_build.md` and `.ralph/PROMPT_plan.md` — seeded at 1.0 from `packages/keel-templates/PROMPT_*.template.md`.
- **Per-invariant narrative:** `docs/invariants/ralph-execute.md` + `docs/invariants/knowledge-files.md`.

### Execute-phase spine (build mode)

**orient → one task → commit → update IP → pre-push quality gate → pre-push CI gate → push → exit**

One task per iteration, no exceptions. Compound NOW tasks ("do X AND Y") decompose at orient. Each BMad-workflow invocation consumes one full iteration. `/bmad-dev-story` runs in a fresh context window regardless of task count — it owns its own internal decomposition. Story-cycle sequencing is governed by the Story-lifecycle decision matrix below (FR14n).

### PR-lifecycle decision matrix (abridged)

| PR State | Epic State      | Action                                                       |
|----------|-----------------|--------------------------------------------------------------|
| No PR    | Tasks remain    | Push → create Draft PR → monitor CI.                         |
| Draft    | Tasks remain    | Push (pre-push CI gate) → monitor CI.                        |
| Draft    | All tasks done  | Queue "Transition PR Draft → Open — final CI gate".          |
| Open     | CI running      | `gh pr checks --watch --fail-fast` → fix failures.           |
| Open     | CI green        | Check review feedback → address or mark EPIC_DONE.           |
| Open     | Review feedback | Queue fix tasks → implement → re-run CI gate.                |

Anti-constraints: never mark EPIC_DONE while Draft; never transition Draft → Open until all tasks done; never address review feedback while Draft.

### Story-lifecycle decision matrix (abridged)

Gate ordering: **coverage (trace) → requirements (SM review) → quality (CR) → done**. Full matrix in `docs/invariants/ralph-execute.md`; normative spec FR14n.

| Story State           | Next skill                                                       |
|-----------------------|------------------------------------------------------------------|
| _(no story)_          | `/bmad-create-story`                                             |
| `drafted`             | `/bmad-create-story (args: "review")` — pre-dev                  |
| `validated`           | `/bmad-testarch-atdd` (or skip with IP rationale)                |
| `atdd-scaffolded`     | `/bmad-dev-story (args: "{story_file_path}")`                    |
| `in-dev`              | `/bmad-testarch-trace (args: "yolo")` — coverage gate            |
| `trace-fixes-pending` | Top QUEUE fix task (add missing AC test)                         |
| `traced`              | `/bmad-create-story (args: "review")` — post-dev SM verification |
| `sm-fixes-pending`    | Top QUEUE fix task (satisfy unmet AC)                            |
| `sm-verified`         | `/bmad-code-review (args: "2")`                                  |
| `fixes-pending`       | Top QUEUE fix task (one CR action item per iter)                 |
| `done`                | Next story or EPIC_DONE halt                                     |

Anti-constraints: never skip states; never invoke `/bmad-dev-story` outside `atdd-scaffolded` / `/bmad-testarch-trace` outside `in-dev` / `/bmad-create-story (args: "review")` post-dev outside `traced` / `/bmad-code-review` outside `sm-verified` without IP rationale; never mark `done` with un-addressed fix tasks in QUEUE from any gate (trace, SM, CR); every gate finding becomes a QUEUE fix task unless IP records `defer:`.

### Halt schema

`.ralph/halt` is JSON: `{"reason": "<enum>", "epic": <N|null>, "pr": "<url|null>"}`. Closed reason enum at 1.0: `EPIC_DONE`, `AWAIT_MERGE`, `BUDGET_EXHAUSTED`, `CI_BLOCKED`, `SECURITY_CRITICAL`. `ralph.py` reads and displays; forks that replace the runtime honour the schema.

### Knowledge-file upkeep

Three audience-scoped files update on every iteration that learned something non-obvious: `AGENTS.md` (shared operational), `CLAUDE.md` (Claude-Code-specific), `RALPH.md` (Ralph-private journal). A "learned-but-did-not-write-down" iteration is by definition wasted — upkeep is commit-time, not optional.
