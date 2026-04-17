#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = []
# ///
"""Bootstrap .claude/agents/*.md from _bmad/_config/agent-manifest.csv.

BMad v6.3 ships persona metadata but does not emit Claude Code subagent
registration files, so `subagent_type: "bmad-agent-*"` calls fail. This script
generates the missing files so party-mode and direct agent invocations work.

Run once (idempotent; rerun after BMad upgrades):
    uv run scripts/bootstrap-bmad-agents.py
"""

import csv
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CSV_PATH = REPO_ROOT / "_bmad" / "_config" / "agent-manifest.csv"
OUT_DIR = REPO_ROOT / ".claude" / "agents"

ADVISORY_TOOLS = ["Read", "Grep", "Glob", "WebFetch", "WebSearch"]
EXECUTION_TOOLS = ["Read", "Grep", "Glob", "Edit", "Write", "Bash", "WebFetch"]
TOOL_POLICY = {
    "bmad-agent-dev": EXECUTION_TOOLS,
    "bmad-tea": EXECUTION_TOOLS,
}


def description(row: dict) -> str:
    role = row["role"].strip().rstrip(".")
    caps = [c.strip() for c in row["capabilities"].split(",")[:3]]
    return f"{role}. Expertise: {', '.join(caps)}. Use when consulting {row['displayName']} on these topics."


def body(row: dict) -> str:
    return f"""You are {row['displayName']} ({row['title']}), a BMAD agent.

## Identity
{row['identity']}

## Communication Style
{row['communicationStyle']}

## Principles
{row['principles']}

## Capabilities
{row['capabilities']}

Respond authentically as {row['displayName']}. Your communication style and principles are load-bearing, not decorative — stay in character. When invoked inside a roundtable or party-mode skill, follow the additional instructions that skill layers on top of this prompt.
"""


def main() -> int:
    if not CSV_PATH.exists():
        print(f"error: {CSV_PATH} not found — is BMad installed?", file=sys.stderr)
        return 1

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    with CSV_PATH.open() as f:
        reader = csv.DictReader(f)
        count = 0
        for row in reader:
            name = row["name"].strip()
            if not name:
                continue
            tools = ", ".join(TOOL_POLICY.get(name, ADVISORY_TOOLS))
            out_path = OUT_DIR / f"{name}.md"
            out_path.write_text(
                f"---\nname: {name}\ndescription: {description(row)}\ntools: {tools}\nmodel: inherit\n---\n\n{body(row)}"
            )
            count += 1
            print(f"  wrote {out_path.relative_to(REPO_ROOT)}")

    print(f"\ngenerated {count} agent(s) in {OUT_DIR.relative_to(REPO_ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
