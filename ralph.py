#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "textual>=1.0.0",
# ]
# ///
"""Ralph TUI — Unified loop orchestrator + live dashboard.

Full-screen Textual app. Spawns `claude -p` as a subprocess, reads
stream-json stdout, manages the iteration loop, and renders everything
in a rich TUI.

Usage:
    uv run ralph.py                                 # build mode, unlimited
    uv run ralph.py build 5                         # build mode, 5 iterations
    uv run ralph.py plan                            # plan mode, unlimited
    uv run ralph.py plan 3 --debug                  # plan mode, 3 iters, debug
    uv run ralph.py --timeout 30m                   # custom per-iteration timeout
    uv run ralph.py plan -p "focus on Epic 2"       # seed first iteration
    uv run ralph.py --tool codex                    # use codex instead of claude
    uv run ralph.py --model claude-opus-4-7         # specific model
    uv run ralph.py --effort high                   # claude reasoning effort
    uv run ralph.py --safe                          # don't skip permissions
    uv run ralph.py --tool-flag --resume            # raw flag passthrough
    uv run ralph.py --tool-arg --allowed-tools=Bash # raw arg passthrough

Per-project defaults and custom tools can live in .ralph/tools.json —
see docs/ralph.md for the schema.
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
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any, TextIO

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


# ── Tool profiles ──────────────────────────────────────────────

# Canonical concept → per-tool CLI flag. Absence means the tool doesn't
# expose that concept; Ralph silently skips it (and warns if the user
# explicitly set it on the CLI).
#
# Value semantics inside the canonical dict:
#   True     → emit the bare flag
#   False/None → skip
#   str/int  → emit [flag, str(value)]


@dataclass
class ToolProfile:
    name: str
    binary: str
    base_args: list[str] = field(default_factory=list)
    flag_map: dict[str, str] = field(default_factory=dict)
    defaults: dict[str, Any] = field(default_factory=dict)
    stream_format: str = "plain"  # "claude-stream-json" | "plain"


DEFAULT_TOOL_PROFILES: dict[str, ToolProfile] = {
    "claude": ToolProfile(
        name="claude",
        binary="claude",
        base_args=["-p", "--output-format", "stream-json", "--verbose"],
        flag_map={
            "model":           "--model",
            "effort":          "--effort",
            "unsafe":          "--dangerously-skip-permissions",
            "permission_mode": "--permission-mode",
            "worktree":        "--worktree",
            "debug":           "--debug",
            "settings":        "--settings",
            "max_budget_usd":  "--max-budget-usd",
            "fallback_model":  "--fallback-model",
        },
        defaults={
            # Opus 4.7 recommends 'xhigh' as the starting point for
            # coding / agentic loops — see Anthropic's migration guide.
            "effort":   "xhigh",
            "unsafe":   True,
            "settings": json.dumps({"thinking": "adaptive"}),
        },
        stream_format="claude-stream-json",
    ),
    "codex": ToolProfile(
        name="codex",
        binary="codex",
        base_args=["exec"],
        flag_map={
            "model":  "--model",
            "unsafe": "--skip-git-repo-check",
        },
        defaults={"unsafe": True},
        stream_format="plain",
    ),
    "gemini": ToolProfile(
        name="gemini",
        binary="gemini",
        base_args=[],
        flag_map={"model": "-m"},
        defaults={},
        stream_format="plain",
    ),
}


def _clone_profile(p: ToolProfile) -> ToolProfile:
    return ToolProfile(
        name=p.name,
        binary=p.binary,
        base_args=list(p.base_args),
        flag_map=dict(p.flag_map),
        defaults=dict(p.defaults),
        stream_format=p.stream_format,
    )


def load_tool_profiles(config_path: Path) -> dict[str, ToolProfile]:
    """Return merged tool profiles: in-code defaults + optional project config.

    The config file shape:
        {
          "tools": {
            "<known-name>": {
              "defaults":         { "<canonical>": <value>, ... },
              "base_args_append": [ ... ],
              "flag_map_append":  { "<canonical>": "<flag>", ... },
              "stream_format":    "plain" | "claude-stream-json"
            },
            "<new-name>": {
              "binary":        "bin",
              "base_args":     [ ... ],
              "flag_map":      { ... },
              "defaults":      { ... },
              "stream_format": "plain"
            }
          }
        }

    Unknown tool entries register a brand-new profile (must supply `binary`).
    """
    profiles = {name: _clone_profile(p) for name, p in DEFAULT_TOOL_PROFILES.items()}

    if not config_path.exists():
        return profiles

    try:
        data = json.loads(config_path.read_text())
    except json.JSONDecodeError as e:
        print(f"Error: invalid JSON in {config_path}: {e}", file=sys.stderr)
        sys.exit(1)

    tools_data = data.get("tools", {})
    if not isinstance(tools_data, dict):
        print(f"Error: {config_path}: 'tools' must be an object", file=sys.stderr)
        sys.exit(1)

    for name, spec in tools_data.items():
        if not isinstance(spec, dict):
            print(f"Error: {config_path}: tools.{name} must be an object", file=sys.stderr)
            sys.exit(1)

        if name in profiles:
            prof = profiles[name]
            if "defaults" in spec:
                prof.defaults.update(spec["defaults"])
            if "base_args_append" in spec:
                prof.base_args.extend(spec["base_args_append"])
            if "flag_map_append" in spec:
                prof.flag_map.update(spec["flag_map_append"])
            if "stream_format" in spec:
                prof.stream_format = spec["stream_format"]
        else:
            if "binary" not in spec:
                print(
                    f"Error: {config_path}: new tool '{name}' is missing 'binary'",
                    file=sys.stderr,
                )
                sys.exit(1)
            profiles[name] = ToolProfile(
                name=name,
                binary=spec["binary"],
                base_args=list(spec.get("base_args", [])),
                flag_map=dict(spec.get("flag_map", {})),
                defaults=dict(spec.get("defaults", {})),
                stream_format=spec.get("stream_format", "plain"),
            )

    return profiles


# ── Config ─────────────────────────────────────────────────────


@dataclass
class RalphConfig:
    mode: str = "build"
    prompt_file: str = ".ralph/PROMPT_build.md"
    max_iterations: int = 0
    timeout_seconds: float = 7200.0  # 120m default
    branch: str = ""
    task_list_id: str = ""
    initial_prompt: str = ""
    tool: str = "claude"
    profile: ToolProfile = field(default_factory=lambda: _clone_profile(DEFAULT_TOOL_PROFILES["claude"]))
    canonicals: dict[str, Any] = field(default_factory=dict)
    ignored_canonicals: list[str] = field(default_factory=list)
    tool_args: list[tuple[str, str]] = field(default_factory=list)
    tool_flags: list[str] = field(default_factory=list)


def _parse_tool_arg(raw: str) -> tuple[str, str]:
    if "=" not in raw:
        raise argparse.ArgumentTypeError(
            f"--tool-arg expects KEY=VAL (got {raw!r})"
        )
    k, v = raw.split("=", 1)
    if not k:
        raise argparse.ArgumentTypeError(f"--tool-arg KEY must be non-empty (got {raw!r})")
    return (k, v)


def build_cli_cmd(cfg: RalphConfig) -> list[str]:
    """Render argv from the resolved profile + canonical overrides + passthrough."""
    prof = cfg.profile
    cmd = [prof.binary, *prof.base_args]
    for key, value in cfg.canonicals.items():
        flag = prof.flag_map.get(key)
        if flag is None:
            continue
        if value is None or value is False:
            continue
        if value is True:
            cmd.append(flag)
        else:
            cmd.extend([flag, str(value)])
    for k, v in cfg.tool_args:
        cmd.extend([k, v])
    for f in cfg.tool_flags:
        cmd.append(f)
    return cmd


def build_config() -> RalphConfig:
    parser = argparse.ArgumentParser(
        description="Ralph TUI — unified loop orchestrator + live dashboard",
        usage=(
            "uv run ralph.py [build|plan] [N] [--timeout T] [--prompt STR]\n"
            "                    [--tool TOOL] [--model MODEL]\n"
            "                    [--effort {low,medium,high,xhigh,max}]\n"
            "                    [--max-budget-usd AMOUNT] [--fallback-model MODEL]\n"
            "                    [--permission-mode MODE] [--safe | --unsafe]\n"
            "                    [--debug] [--worktree NAME]\n"
            "                    [--tool-arg KEY=VAL]... [--tool-flag FLAG]...\n"
            "                    [--tool-config PATH]"
        ),
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
        "--timeout",
        default=os.environ.get("ITERATION_TIMEOUT", "120m"),
        help="Per-iteration timeout (e.g. 15m, 2h, 90s). Default: 120m",
    )
    parser.add_argument(
        "--prompt", "-p",
        default="",
        type=str,
        help="Initial instruction appended to the main prompt on the first iteration only",
    )
    parser.add_argument(
        "--tool",
        default="claude",
        type=str,
        help="AI coding CLI tool to invoke per iteration (default: claude). "
             "Additional tools can be registered via .ralph/tools.json.",
    )
    parser.add_argument(
        "--model",
        default=None,
        type=str,
        help="Model name passed to the tool (canonical: 'model')",
    )
    parser.add_argument(
        "--effort",
        default=None,
        choices=["low", "medium", "high", "xhigh", "max"],
        help="Reasoning effort (canonical: 'effort'). Claude profile default: 'xhigh'.",
    )
    parser.add_argument(
        "--debug", "-d",
        action="store_const",
        const=True,
        default=None,
        help="Pass the tool's debug flag (canonical: 'debug')",
    )
    parser.add_argument(
        "--worktree",
        default=None,
        type=str,
        help="Git worktree name (canonical: 'worktree')",
    )
    parser.add_argument(
        "--max-budget-usd",
        default=None,
        type=float,
        metavar="AMOUNT",
        help="Cap API spend for each iteration in USD "
             "(canonical: 'max_budget_usd'). Recommended when running at "
             "xhigh/max effort.",
    )
    parser.add_argument(
        "--fallback-model",
        default=None,
        type=str,
        metavar="MODEL",
        help="Fallback model when the primary is overloaded "
             "(canonical: 'fallback_model').",
    )
    parser.add_argument(
        "--permission-mode",
        default=None,
        choices=["acceptEdits", "auto", "bypassPermissions", "default", "dontAsk", "plan"],
        help="Claude permission mode (canonical: 'permission_mode'). "
             "More granular than --safe/--unsafe — e.g. 'acceptEdits' to "
             "auto-accept edits without permission-checking everything.",
    )
    perm_group = parser.add_mutually_exclusive_group()
    perm_group.add_argument(
        "--safe",
        dest="unsafe_override",
        action="store_const",
        const=False,
        default=None,
        help="Disable the tool's 'unsafe' flag (e.g. claude --dangerously-skip-permissions)",
    )
    perm_group.add_argument(
        "--unsafe",
        dest="unsafe_override",
        action="store_const",
        const=True,
        default=None,
        help="Force the tool's 'unsafe' flag on (overrides project config)",
    )
    parser.add_argument(
        "--tool-arg",
        action="append",
        type=_parse_tool_arg,
        default=[],
        metavar="KEY=VAL",
        help="Passthrough arg appended verbatim to the tool invocation "
             "(e.g. --tool-arg --allowed-tools=Bash,Edit). Repeatable.",
    )
    parser.add_argument(
        "--tool-flag",
        action="append",
        type=str,
        default=[],
        metavar="FLAG",
        help="Passthrough bare flag appended verbatim to the tool invocation "
             "(e.g. --tool-flag --resume). Repeatable.",
    )
    parser.add_argument(
        "--tool-config",
        default=".ralph/tools.json",
        type=str,
        help="Path to project tool-config JSON (default: .ralph/tools.json)",
    )

    args = parser.parse_args()

    # Resolve profiles
    profiles = load_tool_profiles(Path(args.tool_config))
    if args.tool not in profiles:
        print(
            f"Error: unknown tool '{args.tool}'. Known: {', '.join(sorted(profiles))}",
            file=sys.stderr,
        )
        sys.exit(1)
    profile = profiles[args.tool]

    # Merge canonicals: profile.defaults ← CLI overrides
    cli_canonicals: dict[str, Any] = {}
    if args.model is not None:
        cli_canonicals["model"] = args.model
    if args.effort is not None:
        cli_canonicals["effort"] = args.effort
    if args.unsafe_override is not None:
        cli_canonicals["unsafe"] = args.unsafe_override
    if args.debug is not None:
        cli_canonicals["debug"] = args.debug
    if args.worktree is not None:
        cli_canonicals["worktree"] = args.worktree
    if args.max_budget_usd is not None:
        cli_canonicals["max_budget_usd"] = args.max_budget_usd
    if args.fallback_model is not None:
        cli_canonicals["fallback_model"] = args.fallback_model
    if args.permission_mode is not None:
        cli_canonicals["permission_mode"] = args.permission_mode

    ignored = [k for k in cli_canonicals if k not in profile.flag_map]
    canonicals: dict[str, Any] = dict(profile.defaults)
    canonicals.update(cli_canonicals)

    prompt_file = f".ralph/PROMPT_{args.mode}.md"
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

    halt = Path(".ralph/halt")
    if halt.exists():
        halt.unlink()

    return RalphConfig(
        mode=args.mode,
        prompt_file=prompt_file,
        max_iterations=args.max_iterations,
        timeout_seconds=parse_timeout(args.timeout),
        branch=branch,
        task_list_id=task_list_id,
        initial_prompt=args.prompt,
        tool=args.tool,
        profile=profile,
        canonicals=canonicals,
        ignored_canonicals=ignored,
        tool_args=list(args.tool_arg),
        tool_flags=list(args.tool_flag),
    )


# ── Output adapters ────────────────────────────────────────────


class OutputAdapter:
    """Renders a subprocess's stdout stream into the TUI.

    `capabilities` is a set of header fields the adapter can populate. The
    RalphApp uses it to decide whether to show real numbers or em-dashes.
    """

    capabilities: set[str] = {"elapsed"}

    def __init__(self, app: "RalphApp") -> None:
        self.app = app

    def handle_line(self, raw_line: str) -> None:  # pragma: no cover
        raise NotImplementedError

    def on_iteration_end(self, exit_code: int, duration_s: float) -> None:
        pass


class PlainTextAdapter(OutputAdapter):
    """Dumb pass-through for tools without a structured event stream."""

    capabilities = {"elapsed"}

    def handle_line(self, raw_line: str) -> None:
        self.app._log_write(raw_line)

    def on_iteration_end(self, exit_code: int, duration_s: float) -> None:
        # Skip the summary on error/timeout — the app already logs that.
        if exit_code not in (0,):
            return
        app = self.app
        app._log_write("")
        app._log_write(app._section_header(f"Iteration {app.iteration} Summary"))
        stats = Text()
        stats.append("Duration ", style="dim")
        stats.append(format_duration(duration_s))
        app._log_write(stats)
        app._log_write(app._dim_rule())
        app._log_write("")


class ClaudeStreamJsonAdapter(OutputAdapter):
    """Parses claude's stream-json events into turns, tokens, cost, tool use."""

    capabilities = {"elapsed", "turns", "cost", "tokens", "context", "tool_use"}

    def handle_line(self, raw_line: str) -> None:
        try:
            event = json.loads(raw_line)
        except json.JSONDecodeError:
            self.app._log_write(raw_line)
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
        app = self.app
        app.model_name = event.get("model", app.model_name)
        if "contextWindow" in event:
            app.context_window = event["contextWindow"]
        app._update_header()

    def _handle_assistant(self, event: dict) -> None:
        app = self.app
        app.turn_count += 1

        if app.turn_count > 1:
            app._log_write("")

        usage = event.get("message", {}).get("usage", {})
        if usage:
            app.total_input = usage.get("input_tokens", app.total_input)
            app.total_output = usage.get("output_tokens", app.total_output)
            app.total_cache_create = usage.get("cache_creation_input_tokens", app.total_cache_create)
            app.total_cache_read = usage.get("cache_read_input_tokens", app.total_cache_read)

        content = event.get("message", {}).get("content", [])
        for block in content:
            block_type = block.get("type", "")
            if block_type == "text":
                text = block.get("text", "")
                if text.strip():
                    app._log_write(Markdown(text))
            elif block_type == "tool_use":
                tool_name = block.get("name", "unknown")
                tool_input = block.get("input", {})
                detail = extract_tool_detail(tool_input)
                app.last_tool = f"{tool_name}{detail}"
                app._log_write(Text(f"{WRENCH} {tool_name}{detail}"))

        app._update_header()

    def _handle_result(self, event: dict) -> None:
        app = self.app
        result_cost = event.get("cost_usd", 0.0)
        app.iter_cost = result_cost
        app.session_cost += result_cost
        total_turns = event.get("num_turns", app.turn_count)
        duration_s = event.get("duration_ms", 0) / 1000
        duration_api_s = event.get("duration_api_ms", 0) / 1000

        usage = event.get("usage", {})
        if usage:
            app.total_input = usage.get("input_tokens", app.total_input)
            app.total_output = usage.get("output_tokens", app.total_output)
            app.total_cache_create = usage.get("cache_creation_input_tokens", app.total_cache_create)
            app.total_cache_read = usage.get("cache_read_input_tokens", app.total_cache_read)

        total_tokens = (
            app.total_input + app.total_output
            + app.total_cache_create + app.total_cache_read
        )
        ctx_pct = (total_tokens / app.context_window * 100) if app.context_window > 0 else 0

        app._log_write("")
        app._log_write(app._section_header(f"Iteration {app.iteration} Summary"))

        stats = Text()
        stats.append("Turns ", style="dim")
        stats.append(f"{total_turns}")
        stats.append(f"  {LIGHT}  ", style="dim")
        stats.append("Cost ", style="dim")
        stats.append(format_cost(result_cost))
        stats.append(f"  {LIGHT}  ", style="dim")
        stats.append("Duration ", style="dim")
        stats.append(format_duration(duration_s))
        app._log_write(stats)

        if duration_api_s > 0:
            api = Text()
            api.append("API ", style="dim")
            api.append(format_duration(duration_api_s))
            api.append(f"  {LIGHT}  ", style="dim")
            api.append("Overhead ", style="dim")
            api.append(format_duration(duration_s - duration_api_s))
            app._log_write(api)

        tokens = Text()
        tokens.append("Tokens ", style="dim")
        tokens.append(f"{total_tokens:,}")
        tokens.append(f" ({ctx_pct:.0f}%)", style="dim")
        tokens.append(f"  {LIGHT}  ", style="dim")
        tokens.append("in ", style="dim")
        tokens.append(f"{app.total_input:,}")
        tokens.append("  out ", style="dim")
        tokens.append(f"{app.total_output:,}")
        tokens.append("  c_w ", style="dim")
        tokens.append(f"{app.total_cache_create:,}")
        tokens.append("  c_r ", style="dim")
        tokens.append(f"{app.total_cache_read:,}")
        app._log_write(tokens)

        result_text = event.get("result", "")
        if result_text:
            app._log_write("")
            app._log_write(Markdown(result_text))

        app._log_write(app._dim_rule())
        app._log_write("")
        app._update_header()


def make_adapter(profile: ToolProfile, app: "RalphApp") -> OutputAdapter:
    if profile.stream_format == "claude-stream-json":
        return ClaudeStreamJsonAdapter(app)
    return PlainTextAdapter(app)


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
        self.model_name = config.canonicals.get("model", "") or ""
        self.context_window = 200_000

        # Output adapter (selected by tool profile)
        self.adapter: OutputAdapter = make_adapter(config.profile, self)

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
        os.makedirs(".ralph/logs", exist_ok=True)
        branch_slug = self.config.branch.replace("/", "-")
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        self._log_path = f".ralph/logs/{branch_slug}-{timestamp}.log"
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

    def _canonicals_summary(self) -> str:
        """Render ' (key: value, flag, …)' for the session line."""
        parts: list[str] = []
        prof = self.config.profile
        for key, val in self.config.canonicals.items():
            if key not in prof.flag_map:
                continue
            if val is None or val is False:
                continue
            if key == "settings":
                continue  # too long for a header
            if val is True:
                parts.append(key)
            else:
                s = str(val)
                if len(s) > 24:
                    s = s[:21] + "…"
                parts.append(f"{key}: {s}")
        return f"  ({', '.join(parts)})" if parts else ""

    def _update_header(self) -> None:
        cfg = self.config
        caps = self.adapter.capabilities
        max_label = f"/{cfg.max_iterations}" if cfg.max_iterations > 0 else ""

        self.query_one("#session-line", Static).update(
            f"  Ralph Loop  {LIGHT}  {cfg.tool}  {LIGHT}  {cfg.mode}  {LIGHT}  {cfg.branch}"
            f"{self._canonicals_summary()}"
        )

        turn_str = f"Turn {self.turn_count}" if "turns" in caps else "Turn —"
        self.query_one("#iter-line", Static).update(
            f"  Iteration {self.iteration}{max_label}"
            f"  {LIGHT}  {turn_str}"
            f"  {LIGHT}  Task list: {cfg.task_list_id}"
        )

        if "context" in caps:
            total_tokens = (
                self.total_input + self.total_output
                + self.total_cache_create + self.total_cache_read
            )
            ctx_pct = (total_tokens / self.context_window * 100) if self.context_window > 0 else 0
            bar = make_bar(ctx_pct, width=12)
            ctx_line = f"  Context: {bar} {ctx_pct:.0f}% ({total_tokens // 1000}K/{self.context_window // 1000}K)"
        else:
            ctx_line = "  Context: —"
        if self.block_usage.available:
            bu = self.block_usage
            tok_m = bu.tokens / 1_000_000
            remaining = format_remaining_time(bu.remaining_minutes)
            ctx_line += f"  |  5h: {format_cost(bu.cost)} . {tok_m:.1f}M tok . {remaining} left"
        elif not _read_block_cache():
            ctx_line += "  |  5h: Loading..."
        self.query_one("#context-bar", Static).update(ctx_line)

        if "tokens" in caps:
            token_line = (
                f"  in: {self.total_input:,}  out: {self.total_output:,}"
                f"  c_w: {self.total_cache_create:,}  c_r: {self.total_cache_read:,}"
            )
        else:
            token_line = "  in: —  out: —  c_w: —  c_r: —"
        self.query_one("#token-line", Static).update(token_line)

        elapsed = time.time() - self.iter_start
        session_elapsed = time.time() - self.session_start
        if "cost" in caps:
            cost_part = (
                f"  Cost: {format_cost(self.iter_cost)}"
                f"  (session: {format_cost(self.session_cost)})"
            )
        else:
            cost_part = "  Cost: —  (session: —)"
        self.query_one("#cost-line", Static).update(
            f"{cost_part}"
            f"  {LIGHT}  Elapsed: {format_duration(elapsed)}"
            f"  (session: {format_duration(session_elapsed)})"
        )

        if "tool_use" in caps:
            tool_line = f"  Last: {self.last_tool}" if self.last_tool else "  Last: (none)"
        else:
            tool_line = "  Last: —"
        self.query_one("#tool-line", Static).update(tool_line)

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
        if self.iteration == 1 and self.config.initial_prompt:
            self._log_write(Text(f"Initial prompt: {self.config.initial_prompt}", style="dim"))
            self._log_write("")
        if self.iteration == 1 and self.config.ignored_canonicals:
            for key in self.config.ignored_canonicals:
                self._log_write(Text(
                    f"--{key} ignored: {self.config.tool} has no '{key}' concept",
                    style="yellow",
                ))
            self._log_write("")
        self._update_header()

    def _on_iteration_end(self, exit_code: int, duration_s: float) -> None:
        if exit_code == 124:
            self._log_write(Text("⏰ Iteration timed out — context likely exhausted", style="yellow"))
            self._log_write(self._dim_rule())
        elif exit_code != 0 and exit_code != 130:
            self._log_write(Text(
                f"⚠ {self.config.tool} exited with code {exit_code}", style="red"
            ))
            self._log_write(self._dim_rule())
        self.adapter.on_iteration_end(exit_code, duration_s)
        self._update_header()

    def _on_halt(self) -> None:
        self._log_write("")
        self._log_write(self._section_header("HALT"))
        try:
            with open(".ralph/halt") as f:
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

            cmd = build_cli_cmd(cfg)

            env = {**os.environ, "CLAUDE_CODE_TASK_LIST_ID": cfg.task_list_id}

            # Build prompt stdin content (optionally augmented with --prompt on iteration 1)
            prompt_text = Path(cfg.prompt_file).read_text()
            if cfg.initial_prompt and self.iteration == 1:
                prompt_text = (
                    f"{prompt_text.rstrip()}\n\n"
                    "---\n\n"
                    "## Initial Instruction (this run)\n\n"
                    "After studying the prompt above, treat the following as your first concrete instruction for this iteration:\n\n"
                    f"{cfg.initial_prompt}\n"
                )

            proc = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                text=True,
                env=env,
            )
            self._proc = proc
            proc.stdin.write(prompt_text)
            proc.stdin.close()

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
                        self.call_from_thread(self.adapter.handle_line, line)

                exit_code = proc.wait()
            finally:
                timer.cancel()

            # Map timeout termination to exit code 124 (GNU timeout convention)
            if timed_out.is_set():
                exit_code = 124

            duration_s = time.time() - self.iter_start
            self._proc = None
            self.call_from_thread(self._on_iteration_end, exit_code, duration_s)

            # Exit code handling
            if exit_code == 130:  # SIGINT
                break

            # Halt detection
            if Path(".ralph/halt").exists():
                self.call_from_thread(self._on_halt)
                break

            # AWAIT_MERGE detection
            try:
                with open(".ralph/@plan.md") as f:
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
