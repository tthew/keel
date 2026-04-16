#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "textual>=1.0.0",
# ]
# ///
"""Ralph TUI — Unified loop orchestrator + live dashboard.

Replaces loop.sh + ralph-dashboard.py with a single full-screen Textual app.
Spawns `claude -p` as a subprocess, reads stream-json stdout, manages the
iteration loop, and renders everything in a rich TUI.

Usage:
    uv run ralph.py                    # build mode, unlimited
    uv run ralph.py build 5            # build mode, max 5 iterations
    uv run ralph.py plan               # plan mode, unlimited
    uv run ralph.py plan 3 --debug     # plan mode, 3 iters, debug
    uv run ralph.py --timeout 30m      # custom per-iteration timeout
"""

from __future__ import annotations

import argparse
import json
import os
import shlex
import shutil
import subprocess
import sys
import threading
import time
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import TextIO

from textual.app import App, ComposeResult
from textual.containers import Container
from textual.widgets import RichLog, Static
from rich.markdown import Markdown
from rich.text import Text
from textual.worker import get_current_worker
from textual import work

# ── Box-drawing constants ──────────────────────────────────────
HEAVY  = "\u2501"   # ━
LIGHT  = "\u2500"   # ─
ARROW  = "\u2192"   # →
BLOCK  = "\u2588"   # █
SHADE  = "\u2591"   # ░
WRENCH = "\U0001f527"

# Cache for ccusage block usage (slow command ~90s)
BLOCK_CACHE_PATH = Path("/tmp/ralph-block-usage.json")
BLOCK_CACHE_TTL = 300  # 5 minutes


# ── Helpers ────────────────────────────────────────────────────

def format_duration(seconds: float) -> str:
    m, s = divmod(int(seconds), 60)
    h, m = divmod(m, 60)
    if h > 0:
        return f"{h}h{m:02d}m{s:02d}s"
    if m > 0:
        return f"{m}m{s:02d}s"
    return f"{s}s"


def format_cost(cost: float) -> str:
    if cost < 0.01:
        return f"${cost:.4f}"
    return f"${cost:.2f}"


def make_bar(pct: float, width: int = 20) -> str:
    filled = min(int(width * pct / 100), width)
    return BLOCK * filled + SHADE * (width - filled)


def parse_timeout(value: str) -> float:
    """Parse timeout string like '15m', '2h', '90s', '1800' into seconds."""
    value = value.strip().lower()
    if value.endswith("h"):
        return float(value[:-1]) * 3600
    if value.endswith("m"):
        return float(value[:-1]) * 60
    if value.endswith("s"):
        return float(value[:-1])
    return float(value)


def format_remaining_time(minutes: int) -> str:
    """Format remaining minutes as 'Xh Ym' or 'Xm'."""
    if minutes >= 60:
        h, m = divmod(minutes, 60)
        return f"{h}h{m:02d}m"
    return f"{minutes}m"


@dataclass
class BlockUsage:
    """5-hour billing block usage data from ccusage."""
    tokens: int = 0
    cost: float = 0.0
    remaining_minutes: int = 0
    cost_per_hour: float = 0.0
    available: bool = False


def _read_block_cache() -> BlockUsage | None:
    """Read cached block usage if fresh enough."""
    try:
        if not BLOCK_CACHE_PATH.exists():
            return None
        cache_age = time.time() - BLOCK_CACHE_PATH.stat().st_mtime
        if cache_age > BLOCK_CACHE_TTL:
            return None
        data = json.loads(BLOCK_CACHE_PATH.read_text())
        return BlockUsage(
            tokens=data["tokens"],
            cost=data["cost"],
            remaining_minutes=data["remaining_minutes"],
            cost_per_hour=data["cost_per_hour"],
            available=True,
        )
    except Exception:
        return None


def _write_block_cache(usage: BlockUsage) -> None:
    """Write block usage to cache file."""
    try:
        BLOCK_CACHE_PATH.write_text(json.dumps({
            "tokens": usage.tokens,
            "cost": usage.cost,
            "remaining_minutes": usage.remaining_minutes,
            "cost_per_hour": usage.cost_per_hour,
        }))
    except Exception:
        pass


def fetch_block_usage(force_refresh: bool = False) -> BlockUsage:
    """Fetch block usage from cache or ccusage."""
    # Try cache first (unless forcing refresh)
    if not force_refresh:
        cached = _read_block_cache()
        if cached:
            return cached

    # Run ccusage (slow, ~90s)
    today = datetime.now().strftime("%Y%m%d")
    try:
        result = subprocess.run(
            ["ccusage", "blocks", "--active", "--offline", "--json", "--since", today],
            capture_output=True,
            text=True,
            timeout=180,  # Increased timeout for slow scans
        )
        if result.returncode != 0:
            return BlockUsage()
        data = json.loads(result.stdout)
        block = next((b for b in data.get("blocks", []) if b.get("isActive")), None)
        if not block:
            return BlockUsage()
        usage = BlockUsage(
            tokens=block.get("totalTokens", 0),
            cost=block.get("costUSD", 0.0),
            remaining_minutes=(block.get("projection") or {}).get("remainingMinutes", 0),
            cost_per_hour=(block.get("burnRate") or {}).get("costPerHour", 0.0),
            available=True,
        )
        _write_block_cache(usage)
        return usage
    except Exception:
        return BlockUsage()


def extract_tool_detail(tool_input: dict) -> str:
    if "file_path" in tool_input:
        return f" {ARROW} {tool_input['file_path']}"
    if "command" in tool_input:
        cmd = tool_input["command"].replace("\n", " ")
        return f" {ARROW} {cmd[:60]}"
    if "pattern" in tool_input:
        return f" {ARROW} {tool_input['pattern']}"
    if "query" in tool_input:
        return f" {ARROW} {tool_input['query'][:60]}"
    if "prompt" in tool_input and "subagent_type" in tool_input:
        return f" ({tool_input['subagent_type']})"
    return ""


# ── Config ─────────────────────────────────────────────────────

@dataclass
class RalphConfig:
    mode: str = "build"
    prompt_file: str = "PROMPT_build.md"
    max_iterations: int = 0
    timeout_seconds: float = 7200.0  # 120m default
    debug: bool = False
    branch: str = ""
    task_list_id: str = ""
    worktree: str = ""


def build_config() -> RalphConfig:
    parser = argparse.ArgumentParser(
        description="Ralph TUI — unified loop orchestrator + live dashboard",
        usage="uv run ralph.py [build|plan] [N] [--debug] [--timeout T]",
    )
    parser.add_argument(
        "mode",
        nargs="?",
        default="build",
        choices=["build", "plan"],
        help="Execution mode (default: build)",
    )
    parser.add_argument(
        "max_iterations",
        nargs="?",
        default=0,
        type=int,
        help="Maximum iterations (default: unlimited)",
    )
    parser.add_argument(
        "--debug", "-d",
        action="store_true",
        help="Pass --debug to claude",
    )
    parser.add_argument(
        "--timeout",
        default=os.environ.get("ITERATION_TIMEOUT", "120m"),
        help="Per-iteration timeout (e.g. 15m, 2h, 90s). Default: 120m",
    )

    parser.add_argument(
        "--worktree",
        default="",
        type=str,
        help="Name of Git worktree to pass to Claude",
    )

    args = parser.parse_args()

    prompt_file = f"PROMPT_{args.mode}.md"
    if not Path(prompt_file).is_file():
        print(f"Error: {prompt_file} not found", file=sys.stderr)
        sys.exit(1)

    branch = ""
    try:
        branch = subprocess.check_output(
            ["git", "branch", "--show-current"],
            text=True, stderr=subprocess.DEVNULL,
        ).strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        branch = "unknown"

    task_list_id = f"ralph-{branch.replace('/', '-')}"

    # Remove stale halt file
    halt = Path(".ralph-halt")
    if halt.exists():
        halt.unlink()

    return RalphConfig(
        mode=args.mode,
        prompt_file=prompt_file,
        max_iterations=args.max_iterations,
        timeout_seconds=parse_timeout(args.timeout),
        debug=args.debug,
        branch=branch,
        task_list_id=task_list_id,
        worktree=args.worktree,
    )


# ── Textual App ────────────────────────────────────────────────

class RalphApp(App):
    """Full-screen TUI for the Ralph autonomous loop."""

    CSS = """
    #header-panel {
        dock: top;
        height: 7;
        border-bottom: solid $accent;
        padding: 0 1;
    }
    #session-line {
        color: $text;
    }
    #iter-line {
        color: $text-muted;
    }
    #context-bar {
        color: $success;
    }
    #token-line {
        color: $text-muted;
    }
    #cost-line {
        color: $text;
    }
    #tool-line {
        color: $accent;
    }
    #output-log {
        scrollbar-size: 1 1;
        padding: 0 0 0 1;
    }
    #footer {
        dock: bottom;
        height: 1;
        color: $text-muted;
        background: $surface;
        padding: 0 1;
    }
    """

    BINDINGS = [
        ("q", "quit", "Quit"),
        ("o", "open_log", "Open log"),
    ]

    def __init__(self, config: RalphConfig) -> None:
        super().__init__()
        self.config = config

        # Session-level state
        self.iteration = 0
        self.session_start = time.time()
        self.session_cost = 0.0

        # Per-iteration state
        self.turn_count = 0
        self.total_input = 0
        self.total_output = 0
        self.total_cache_create = 0
        self.total_cache_read = 0
        self.iter_cost = 0.0
        self.iter_start = time.time()
        self.last_tool = ""
        self.model_name = "claude-opus-4-5"
        self.context_window = 200_000

        # Subprocess ref for cleanup
        self._proc: subprocess.Popen | None = None

        # Session log file
        self._log_file: TextIO | None = None
        self._log_path: str = ""

        # 5-hour block usage (from ccusage)
        self.block_usage = BlockUsage()

    def compose(self) -> ComposeResult:
        with Container(id="header-panel"):
            yield Static(id="session-line")
            yield Static(id="iter-line")
            yield Static(id="context-bar")
            yield Static(id="token-line")
            yield Static(id="cost-line")
            yield Static(id="tool-line")
        yield RichLog(id="output-log", auto_scroll=False, max_lines=5_000, markup=True)
        yield Static(id="footer")

    def on_mount(self) -> None:
        # Set up session log file
        os.makedirs("ralph-logs", exist_ok=True)
        branch_slug = self.config.branch.replace("/", "-")
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        self._log_path = f"ralph-logs/{branch_slug}-{timestamp}.log"
        self._log_file = open(self._log_path, "w")

        self.query_one("#footer", Static).update(
            f"  Shift+select to copy \u2502 o: open log \u2502 q: quit"
            f" \u2502 Log: {self._log_path}"
        )

        self._update_header()
        self.set_interval(1.0, self._tick_elapsed)

        # Try cache immediately for fast display
        cached = _read_block_cache()
        if cached:
            self.block_usage = cached

        # Then refresh in background
        self._fetch_block_usage_async(force_refresh=True)
        self.set_interval(300.0, lambda: self._fetch_block_usage_async(force_refresh=True))  # 5 min refresh
        self.run_loop()

    @work(thread=True)
    def _fetch_block_usage_async(self, force_refresh: bool = False) -> None:
        """Fetch block usage in a background thread."""
        usage = fetch_block_usage(force_refresh=force_refresh)
        self.call_from_thread(self._set_block_usage, usage)

    def _set_block_usage(self, usage: BlockUsage) -> None:
        """Update block usage state and refresh header."""
        self.block_usage = usage
        self._update_header()

    def _tick_elapsed(self) -> None:
        """Refresh header every second for live elapsed time."""
        self._update_header()

    # ── Log helpers ────────────────────────────────────────────

    def _section_header(self, title: str, width: int = 50) -> Text:
        """Create a styled section header: ── Title ─────────"""
        prefix = f"{LIGHT}{LIGHT} "
        suffix_len = max(width - len(prefix) - len(title) - 1, 3)
        line = Text()
        line.append(prefix, style="dim")
        line.append(title, style="bold")
        line.append(f" {LIGHT * suffix_len}", style="dim")
        return line

    def _dim_rule(self, width: int = 50) -> Text:
        """Create a dim horizontal rule."""
        return Text(LIGHT * width, style="dim")

    def _log_write(self, content) -> None:
        """Write to both RichLog and session log file with smart scroll."""
        log = self.query_one("#output-log", RichLog)

        # Smart scroll: only auto-scroll if already at bottom
        # Allow 1-line tolerance for rounding
        at_bottom = log.scroll_y >= log.max_scroll_y - 1

        log.write(content, scroll_end=at_bottom)

        if self._log_file:
            if isinstance(content, Markdown):
                self._log_file.write(content.markup + "\n")
            elif isinstance(content, Text):
                self._log_file.write(content.plain + "\n")
            else:
                self._log_file.write(str(content) + "\n")
            self._log_file.flush()

    def action_open_log(self) -> None:
        """Suspend TUI and open the session log in $PAGER."""
        if not self._log_path:
            return
        pager = os.environ.get("PAGER", "less")
        with self.suspend():
            os.system(f"{pager} {shlex.quote(self._log_path)}")

    # ── Header updates ─────────────────────────────────────────

    def _update_header(self) -> None:
        cfg = self.config
        max_label = f"/{cfg.max_iterations}" if cfg.max_iterations > 0 else ""

        self.query_one("#session-line", Static).update(
            f"  Ralph Loop  {LIGHT}  {cfg.mode}  {LIGHT}  {cfg.branch}"
        )
        self.query_one("#iter-line", Static).update(
            f"  Iteration {self.iteration}{max_label}"
            f"  {LIGHT}  Turn {self.turn_count}"
            f"  {LIGHT}  Task list: {cfg.task_list_id}"
        )

        total_tokens = (
            self.total_input + self.total_output
            + self.total_cache_create + self.total_cache_read
        )
        ctx_pct = (total_tokens / self.context_window * 100) if self.context_window > 0 else 0
        bar = make_bar(ctx_pct, width=12)

        ctx_line = f"  Context: {bar} {ctx_pct:.0f}% ({total_tokens // 1000}K/{self.context_window // 1000}K)"
        if self.block_usage.available:
            bu = self.block_usage
            tok_m = bu.tokens / 1_000_000
            remaining = format_remaining_time(bu.remaining_minutes)
            ctx_line += f"  |  5h: {format_cost(bu.cost)} . {tok_m:.1f}M tok . {remaining} left"
        elif not _read_block_cache():
            ctx_line += "  |  5h: Loading..."
        self.query_one("#context-bar", Static).update(ctx_line)
        self.query_one("#token-line", Static).update(
            f"  in: {self.total_input:,}  out: {self.total_output:,}"
            f"  c_w: {self.total_cache_create:,}  c_r: {self.total_cache_read:,}"
        )

        elapsed = time.time() - self.iter_start
        session_elapsed = time.time() - self.session_start
        self.query_one("#cost-line", Static).update(
            f"  Cost: {format_cost(self.iter_cost)}"
            f"  (session: {format_cost(self.session_cost)})"
            f"  {LIGHT}  Elapsed: {format_duration(elapsed)}"
            f"  (session: {format_duration(session_elapsed)})"
        )
        self.query_one("#tool-line", Static).update(
            f"  Last: {self.last_tool}" if self.last_tool else "  Last: (none)"
        )

    # ── Event processing (ported from ralph-dashboard.py) ──────

    def process_event(self, raw_line: str) -> None:
        """Parse a stream-json line and dispatch to handler."""
        try:
            event = json.loads(raw_line)
        except json.JSONDecodeError:
            # Not JSON — debug output, pass through
            self._log_write(raw_line)
            return

        event_type = event.get("type", "")

        if event_type == "system":
            self._handle_system(event)
        elif event_type == "assistant":
            self._handle_assistant(event)
        elif event_type == "result":
            self._handle_result(event)
        # user events (tool results) are skipped — too verbose

    def _handle_system(self, event: dict) -> None:
        self.model_name = event.get("model", self.model_name)
        if "contextWindow" in event:
            self.context_window = event["contextWindow"]
        self._update_header()

    def _handle_assistant(self, event: dict) -> None:
        self.turn_count += 1

        # Blank line between turns
        if self.turn_count > 1:
            self._log_write("")

        # Update token usage
        usage = event.get("message", {}).get("usage", {})
        if usage:
            self.total_input = usage.get("input_tokens", self.total_input)
            self.total_output = usage.get("output_tokens", self.total_output)
            self.total_cache_create = usage.get("cache_creation_input_tokens", self.total_cache_create)
            self.total_cache_read = usage.get("cache_read_input_tokens", self.total_cache_read)

        # Process content blocks
        content = event.get("message", {}).get("content", [])
        for block in content:
            block_type = block.get("type", "")

            if block_type == "text":
                text = block.get("text", "")
                if text.strip():
                    self._log_write(Markdown(text))

            elif block_type == "tool_use":
                tool_name = block.get("name", "unknown")
                tool_input = block.get("input", {})
                detail = extract_tool_detail(tool_input)
                self.last_tool = f"{tool_name}{detail}"
                self._log_write(Text(f"{WRENCH} {tool_name}{detail}"))

        self._update_header()

    def _handle_result(self, event: dict) -> None:
        result_cost = event.get("cost_usd", 0.0)
        self.iter_cost = result_cost
        self.session_cost += result_cost
        total_turns = event.get("num_turns", self.turn_count)
        duration_s = event.get("duration_ms", 0) / 1000
        duration_api_s = event.get("duration_api_ms", 0) / 1000

        # Final usage
        usage = event.get("usage", {})
        if usage:
            self.total_input = usage.get("input_tokens", self.total_input)
            self.total_output = usage.get("output_tokens", self.total_output)
            self.total_cache_create = usage.get("cache_creation_input_tokens", self.total_cache_create)
            self.total_cache_read = usage.get("cache_read_input_tokens", self.total_cache_read)

        total_tokens = (
            self.total_input + self.total_output
            + self.total_cache_create + self.total_cache_read
        )
        ctx_pct = (total_tokens / self.context_window * 100) if self.context_window > 0 else 0

        self._log_write("")
        self._log_write(self._section_header(f"Iteration {self.iteration} Summary"))

        stats = Text()
        stats.append("Turns ", style="dim")
        stats.append(f"{total_turns}")
        stats.append(f"  {LIGHT}  ", style="dim")
        stats.append("Cost ", style="dim")
        stats.append(format_cost(result_cost))
        stats.append(f"  {LIGHT}  ", style="dim")
        stats.append("Duration ", style="dim")
        stats.append(format_duration(duration_s))
        self._log_write(stats)

        if duration_api_s > 0:
            api = Text()
            api.append("API ", style="dim")
            api.append(format_duration(duration_api_s))
            api.append(f"  {LIGHT}  ", style="dim")
            api.append("Overhead ", style="dim")
            api.append(format_duration(duration_s - duration_api_s))
            self._log_write(api)

        tokens = Text()
        tokens.append("Tokens ", style="dim")
        tokens.append(f"{total_tokens:,}")
        tokens.append(f" ({ctx_pct:.0f}%)", style="dim")
        tokens.append(f"  {LIGHT}  ", style="dim")
        tokens.append("in ", style="dim")
        tokens.append(f"{self.total_input:,}")
        tokens.append("  out ", style="dim")
        tokens.append(f"{self.total_output:,}")
        tokens.append("  c_w ", style="dim")
        tokens.append(f"{self.total_cache_create:,}")
        tokens.append("  c_r ", style="dim")
        tokens.append(f"{self.total_cache_read:,}")
        self._log_write(tokens)

        result_text = event.get("result", "")
        if result_text:
            self._log_write("")
            self._log_write(Markdown(result_text))

        self._log_write(self._dim_rule())
        self._log_write("")
        self._update_header()

    # ── Iteration lifecycle ────────────────────────────────────

    def _on_iteration_start(self) -> None:
        self.turn_count = 0
        self.total_input = 0
        self.total_output = 0
        self.total_cache_create = 0
        self.total_cache_read = 0
        self.iter_cost = 0.0
        self.iter_start = time.time()
        self.last_tool = ""

        self._log_write("")
        self._log_write(self._section_header(f"ITERATION {self.iteration}"))
        self._log_write("")
        self._update_header()

    def _on_iteration_end(self, exit_code: int) -> None:
        if exit_code == 124:
            self._log_write(Text("⏰ Iteration timed out — context likely exhausted", style="yellow"))
            self._log_write(self._dim_rule())
        elif exit_code != 0 and exit_code != 130:
            self._log_write(Text(f"⚠ Claude exited with code {exit_code}", style="red"))
            self._log_write(self._dim_rule())
        self._update_header()

    def _on_halt(self) -> None:
        self._log_write("")
        self._log_write(self._section_header("HALT"))
        try:
            with open(".ralph-halt") as f:
                self._log_write(f.read())
        except FileNotFoundError:
            pass
        self._log_write(self._dim_rule())
        self._cleanup_task_list()

    def _on_await_merge(self) -> None:
        self._log_write("")
        self._log_write(self._section_header("AWAIT_MERGE"))

    def _on_loop_complete(self) -> None:
        self._log_write("")
        self._log_write(self._section_header("Loop Complete"))

        stats = Text()
        stats.append("Iterations ", style="dim")
        stats.append(f"{self.iteration}")
        stats.append(f"  {LIGHT}  ", style="dim")
        stats.append("Cost ", style="dim")
        stats.append(format_cost(self.session_cost))
        stats.append(f"  {LIGHT}  ", style="dim")
        stats.append("Time ", style="dim")
        stats.append(format_duration(time.time() - self.session_start))
        self._log_write(stats)
        self._log_write(self._dim_rule())

        self.query_one("#session-line", Static).update(
            f"  Ralph Loop  {LIGHT}  {self.config.mode}  {LIGHT}  COMPLETE  (q to quit)"
        )

    def _cleanup_task_list(self) -> None:
        task_dir = Path.home() / ".claude" / "tasks" / self.config.task_list_id
        if task_dir.is_dir():
            shutil.rmtree(task_dir)

    # ── Loop worker ────────────────────────────────────────────

    @work(thread=True)
    def run_loop(self) -> None:
        worker = get_current_worker()

        while not worker.is_cancelled:
            cfg = self.config

            if cfg.max_iterations > 0 and self.iteration >= cfg.max_iterations:
                break

            self.iteration += 1
            self.call_from_thread(self._on_iteration_start)

            # Build command
            cmd = [
                "claude", "-p",
                "--output-format", "stream-json",
                "--dangerously-skip-permissions",
                "--model", "opus",
                "--effort", "medium",
                "--verbose",
                "--settings", json.dumps({
                    "thinking": "adaptive"
                }),
            ]

            if cfg.worktree:
                cmd.extend(["--worktree", cfg.worktree])

            if cfg.debug:
                cmd.append("--debug")

            env = {**os.environ, "CLAUDE_CODE_TASK_LIST_ID": cfg.task_list_id}

            # Open prompt file as stdin
            prompt_fh = open(cfg.prompt_file, "r")

            proc = subprocess.Popen(
                cmd,
                stdin=prompt_fh,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                env=env,
            )
            self._proc = proc
            prompt_fh.close()  # subprocess has inherited the fd

            # Timeout via timer thread
            timed_out = threading.Event()

            def _timeout_handler():
                timed_out.set()
                if proc.poll() is None:
                    proc.terminate()

            timer = threading.Timer(cfg.timeout_seconds, _timeout_handler)
            timer.start()

            try:
                for line in proc.stdout:
                    if worker.is_cancelled:
                        proc.terminate()
                        break
                    line = line.strip()
                    if line:
                        self.call_from_thread(self.process_event, line)

                exit_code = proc.wait()
            finally:
                timer.cancel()

            # Map timeout termination to exit code 124 (matches loop.sh convention)
            if timed_out.is_set():
                exit_code = 124

            self._proc = None
            self.call_from_thread(self._on_iteration_end, exit_code)

            # Exit code handling
            if exit_code == 130:  # SIGINT
                break

            # Halt detection
            if Path(".ralph-halt").exists():
                self.call_from_thread(self._on_halt)
                break

            # AWAIT_MERGE detection
            try:
                with open("IMPLEMENTATION_PLAN.md") as f:
                    for ip_line in f:
                        if ip_line.startswith("(AWAIT_MERGE"):
                            self.call_from_thread(self._on_await_merge)
                            break
                    else:
                        # No AWAIT_MERGE found, continue loop
                        continue
                # If we broke out of the for loop, AWAIT_MERGE was found
                break
            except FileNotFoundError:
                pass

        self.call_from_thread(self._on_loop_complete)

    # ── Cleanup ────────────────────────────────────────────────

    def on_unmount(self) -> None:
        if self._proc and self._proc.poll() is None:
            self._proc.terminate()
        if self._log_file:
            self._log_file.close()
            self._log_file = None


# ── Main ───────────────────────────────────────────────────────

def main() -> None:
    config = build_config()
    app = RalphApp(config)
    app.run()
    if app._log_path:
        print(f"Session log: {app._log_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
