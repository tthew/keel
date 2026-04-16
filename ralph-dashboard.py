#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "rich",
# ]
# ///
"""Ralph Dashboard - Humanizes claude stream-json output for live monitoring.

Reads stream-json from stdin (piped from `claude -p --output-format stream-json`)
and outputs a human-friendly live view showing:
- Model info and context window
- Tool calls as they happen
- Ralph's text output rendered as markdown (via rich)
- Running context usage %, cost, and elapsed time

Run with: uv run ralph-dashboard.py (dependencies resolved automatically via PEP 723)
"""

import json
import signal
import sys
import time
import os
import shutil

from rich.console import Console
from rich.markdown import Markdown

# Die instantly on SIGINT/SIGPIPE — no traceback, no delay.
# Required for proper pipeline teardown so bash's trap fires immediately.
signal.signal(signal.SIGINT, signal.SIG_DFL)
try:
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
except AttributeError:
    pass  # Windows

# ── Box-drawing constants ──────────────────────────────────────
HEAVY  = "\u2501"   # ━
LIGHT  = "\u2500"   # ─
ARROW  = "\u2192"   # →
BLOCK  = "\u2588"   # █
SHADE  = "\u2591"   # ░
WRENCH = "\U0001f527"


def format_duration(seconds):
    """Format seconds into human-readable duration."""
    m, s = divmod(int(seconds), 60)
    if m > 0:
        return f"{m}m{s:02d}s"
    return f"{s}s"


def format_cost(cost):
    """Format cost in dollars."""
    if cost < 0.01:
        return f"${cost:.4f}"
    return f"${cost:.2f}"


def make_bar(pct, width=20):
    """Create a progress bar string."""
    filled = int(width * pct / 100)
    filled = min(filled, width)
    return BLOCK * filled + SHADE * (width - filled)


def separator(char=LIGHT, width=50):
    return char * width


def main():
    console = Console()
    start_time = time.time()
    term_width = shutil.get_terminal_size((80, 24)).columns
    sep_width = min(term_width, 60)

    # State tracking
    model_name = "claude-opus-4-5"
    context_window = 200000
    turn_count = 0
    total_input = 0
    total_output = 0
    total_cache_create = 0
    total_cache_read = 0
    total_cost = 0.0
    last_tool = ""
    header_printed = False
    last_was_status = False  # Track if previous output was a status bar

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            # Not JSON — pass through as-is (e.g. debug output)
            print(line, flush=True)
            last_was_status = False
            continue

        event_type = event.get("type", "")

        # ── system/init: print header ──
        if event_type == "system":
            model_name = event.get("model", model_name)
            if "contextWindow" in event:
                context_window = event["contextWindow"]
            if not header_printed:
                print("", flush=True)
                print(separator(HEAVY, sep_width), flush=True)
                print(f"  Ralph Dashboard", flush=True)
                print(separator(HEAVY, sep_width), flush=True)
                print(f"  Model:    {model_name}", flush=True)
                print(f"  Context:  {context_window // 1000}K tokens", flush=True)
                print(separator(HEAVY, sep_width), flush=True)
                print("", flush=True)
                header_printed = True
            continue

        # ── assistant: text or tool_use ──
        if event_type == "assistant":
            turn_count += 1

            # Update token usage from this event
            usage = event.get("message", {}).get("usage", {})
            if usage:
                total_input = usage.get("input_tokens", total_input)
                total_output = usage.get("output_tokens", total_output)
                total_cache_create = usage.get("cache_creation_input_tokens", total_cache_create)
                total_cache_read = usage.get("cache_read_input_tokens", total_cache_read)

            # Process content blocks
            content = event.get("message", {}).get("content", [])
            for block in content:
                block_type = block.get("type", "")

                if block_type == "text":
                    text = block.get("text", "")
                    if text.strip():
                        if last_was_status:
                            print("", flush=True)
                        console.print(Markdown(text))
                        console.print()

                elif block_type == "tool_use":
                    tool_name = block.get("name", "unknown")
                    tool_input = block.get("input", {})
                    last_tool = tool_name

                    # Extract useful context from tool input
                    detail = ""
                    if "file_path" in tool_input:
                        detail = f" {ARROW} {tool_input['file_path']}"
                    elif "command" in tool_input:
                        cmd = tool_input["command"].replace("\n", " ")
                        detail = f" {ARROW} {cmd[:60]}"
                    elif "pattern" in tool_input:
                        detail = f" {ARROW} {tool_input['pattern']}"
                    elif "query" in tool_input:
                        detail = f" {ARROW} {tool_input['query'][:60]}"
                    elif "prompt" in tool_input and "subagent_type" in tool_input:
                        detail = f" ({tool_input['subagent_type']})"

                    if last_was_status:
                        print("", flush=True)
                    print(f"  [Turn {turn_count}] {WRENCH} {tool_name}{detail}", flush=True)

            # Status bar
            elapsed = time.time() - start_time
            total_tokens = total_input + total_output + total_cache_create + total_cache_read
            context_pct = (total_tokens / context_window * 100) if context_window > 0 else 0
            bar = make_bar(context_pct)

            status = (
                f"  {bar}  {context_pct:.0f}% "
                f"({total_tokens // 1000}K / {context_window // 1000}K)"
                f"   {format_cost(total_cost)}"
                f"   {format_duration(elapsed)}"
            )
            print(status[:term_width], flush=True)
            last_was_status = True
            continue

        # ── user: tool results (skip content) ──
        if event_type == "user":
            continue

        # ── result: final summary ──
        if event_type == "result":
            elapsed = time.time() - start_time
            result_cost = event.get("cost_usd", total_cost)
            total_turns = event.get("num_turns", turn_count)
            duration_s = event.get("duration_ms", elapsed * 1000) / 1000
            duration_api_s = event.get("duration_api_ms", 0) / 1000

            # Try to get final usage from result
            usage = event.get("usage", {})
            if usage:
                total_input = usage.get("input_tokens", total_input)
                total_output = usage.get("output_tokens", total_output)
                total_cache_create = usage.get("cache_creation_input_tokens", total_cache_create)
                total_cache_read = usage.get("cache_read_input_tokens", total_cache_read)

            total_tokens = total_input + total_output + total_cache_create + total_cache_read
            context_pct = (total_tokens / context_window * 100) if context_window > 0 else 0

            print("", flush=True)
            print(separator(HEAVY, sep_width), flush=True)
            print(f"  Iteration Summary", flush=True)
            print(separator(LIGHT, sep_width), flush=True)
            print(f"  Turns:     {total_turns}", flush=True)
            print(f"  Cost:      {format_cost(result_cost)}", flush=True)
            print(f"  Duration:  {format_duration(duration_s)}", flush=True)
            if duration_api_s > 0:
                print(f"  API time:  {format_duration(duration_api_s)}", flush=True)
                print(f"  Overhead:  {format_duration(duration_s - duration_api_s)}", flush=True)
            print(separator(LIGHT, sep_width), flush=True)
            print(f"  Tokens:    {total_tokens:,}  ({context_pct:.0f}% of {context_window // 1000}K)", flush=True)
            print(f"    input:       {total_input:,}", flush=True)
            print(f"    output:      {total_output:,}", flush=True)
            print(f"    cache write: {total_cache_create:,}", flush=True)
            print(f"    cache read:  {total_cache_read:,}", flush=True)

            # Also print the result text if present
            result_text = event.get("result", "")
            if result_text:
                print(separator(LIGHT, sep_width), flush=True)
                console.print(Markdown(result_text))

            print(separator(HEAVY, sep_width), flush=True)
            print("", flush=True)
            last_was_status = False
            continue

    # If we get here without a result event (e.g. timeout killed claude)
    elapsed = time.time() - start_time
    total_tokens = total_input + total_output + total_cache_create + total_cache_read
    if total_tokens > 0 and event_type != "result":
        context_pct = (total_tokens / context_window * 100) if context_window > 0 else 0
        print("", flush=True)
        print(separator(HEAVY, sep_width), flush=True)
        print(f"  Stream ended (no result event)", flush=True)
        print(separator(LIGHT, sep_width), flush=True)
        print(f"  Elapsed:    {format_duration(elapsed)}", flush=True)
        print(f"  Last tool:  {last_tool}", flush=True)
        print(f"  Tokens:     {total_tokens:,}  ({context_pct:.0f}% of {context_window // 1000}K)", flush=True)
        print(separator(HEAVY, sep_width), flush=True)
        print("", flush=True)


if __name__ == "__main__":
    main()
