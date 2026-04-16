#!/bin/bash
# DEPRECATED: Use `uv run ralph.py` instead.
# This script is kept for reference. See docs/ralph.md.
#
# Ralph Loop - Outer loop script for autonomous execution
#
# Usage: ./loop.sh [build|plan] [max_iterations] [-d|--debug]
# Arguments can appear in any order.
# Examples:
#   ./loop.sh              # Build mode, unlimited iterations
#   ./loop.sh 20           # Build mode, max 20 iterations
#   ./loop.sh build        # Build mode, unlimited (explicit)
#   ./loop.sh build 20     # Build mode, max 20 (explicit)
#   ./loop.sh plan         # Plan mode, unlimited iterations
#   ./loop.sh plan 5       # Plan mode, max 5 iterations
#   ./loop.sh -d           # Build mode with Claude --debug
#   ./loop.sh build -d     # Same as above (flags work anywhere)
#   ./loop.sh build 5 -d   # Build mode, max 5, with debug
#
# Environment variables:
#   ITERATION_TIMEOUT=15m    Max time per iteration (default: 15m)

set -euo pipefail

# Parse all arguments - flags can appear in any position
DEBUG=${DEBUG:-0}
MODE="build"
PROMPT_FILE="PROMPT_build.md"
MAX_ITERATIONS=0
ITERATION_TIMEOUT="${ITERATION_TIMEOUT:-120m}"

for arg in "$@"; do
    case "$arg" in
        -d|--debug)
            DEBUG=1
            ;;
        plan)
            MODE="plan"
            PROMPT_FILE="PROMPT_plan.md"
            ;;
        build)
            MODE="build"
            PROMPT_FILE="PROMPT_build.md"
            ;;
        *)
            # If it's a number, use it as max iterations
            if [[ "$arg" =~ ^[0-9]+$ ]]; then
                MAX_ITERATIONS=$arg
            fi
            ;;
    esac
done

# Set Claude debug flag
CLAUDE_DEBUG_FLAG=""
if [ $DEBUG -eq 1 ]; then
    CLAUDE_DEBUG_FLAG="--debug"
fi

ITERATION=0
CURRENT_BRANCH=$(git branch --show-current)

# Persist native Tasks across iterations via shared task list
# Tasks survive hard kills, providing crash recovery context
TASK_LIST_ID="ralph-$(echo "$CURRENT_BRANCH" | tr '/' '-')"
export CLAUDE_CODE_TASK_LIST_ID="$TASK_LIST_ID"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Ralph Loop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Mode:   $MODE"
echo "Prompt: $PROMPT_FILE"
echo "Branch: $CURRENT_BRANCH"
echo "Timeout: $ITERATION_TIMEOUT per iteration"
echo "Tasks:  $TASK_LIST_ID (~/.claude/tasks/$TASK_LIST_ID/)"
[[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]] && [ "$MAX_ITERATIONS" -gt 0 ] && echo "Max:    $MAX_ITERATIONS iterations"
[ $DEBUG -eq 1 ] && echo "Debug:  enabled"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Show debug info if enabled
if [ $DEBUG -eq 1 ]; then
    echo ""
    echo "Debug Info:"
    echo "  NOW section from IMPLEMENTATION_PLAN.md:"
    grep -A3 "^## NOW" IMPLEMENTATION_PLAN.md 2>/dev/null | head -5 || echo "  (no NOW section found)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

HALT_FILE=".ralph-halt"
rm -f "$HALT_FILE"

trap 'echo ""; echo "Interrupted by user"; exit 130' INT

while true; do
    if [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]] && [ "$MAX_ITERATIONS" -gt 0 ] && [ $ITERATION -ge "$MAX_ITERATIONS" ]; then
        echo "Reached max iterations: $MAX_ITERATIONS"
        break
    fi

    ITERATION=$((ITERATION + 1))
    echo ""
    echo "======================== ITERATION $ITERATION ========================"
    echo "[$(date '+%H:%M:%S')] Starting iteration $ITERATION..."

    # Show debug info for each iteration if enabled
    if [ $DEBUG -eq 1 ]; then
        echo ""
        echo "Debug Info:"
        echo "  NOW section from IMPLEMENTATION_PLAN.md:"
        grep -A3 "^## NOW" IMPLEMENTATION_PLAN.md 2>/dev/null | head -5 || echo "  (no NOW section found)"
        echo "────────────────────────────────────────"
    fi
    echo ""

    # Run Ralph iteration (disable errexit to capture exit code)
    set +e
    timeout --foreground "$ITERATION_TIMEOUT" claude -p \
        --output-format stream-json \
        --dangerously-skip-permissions \
        --model opus \
        --verbose \
        $CLAUDE_DEBUG_FLAG \
        < "$PROMPT_FILE" \
        | uv run ralph-dashboard.py
    EXIT_CODE=${PIPESTATUS[0]}
    set -e

    echo ""
    echo "[$(date '+%H:%M:%S')] Iteration $ITERATION finished (exit code: $EXIT_CODE)"

    if [ $EXIT_CODE -eq 130 ]; then
        echo "Interrupted by user (Ctrl-C)"
        break
    elif [ $EXIT_CODE -eq 124 ]; then
        echo "⏰  Iteration timed out after $ITERATION_TIMEOUT"
        echo "    Context likely exhausted. Next iteration gets fresh context."
    elif [ $EXIT_CODE -ne 0 ]; then
        echo "⚠️  Claude exited with non-zero code: $EXIT_CODE"
        echo "    Common causes: API error, hook rejection"
    fi

    # Check for halt sentinel
    if [ -f "$HALT_FILE" ]; then
        echo ""
        echo "━━━ Ralph requested HALT ━━━"
        cat "$HALT_FILE"
        echo ""
        break
    fi

    # Fallback: check IP for AWAIT_MERGE state
    if grep -q "^(AWAIT_MERGE" IMPLEMENTATION_PLAN.md 2>/dev/null; then
        echo ""
        echo "━━━ Ralph in AWAIT_MERGE state ━━━"
        break
    fi

    echo ""
    echo "======================== ITERATION $ITERATION COMPLETE ========================"
    echo ""
done

echo ""
echo "━━━ Ralph Loop Complete ━━━"
echo "Iterations: $ITERATION"
if [ -f "$HALT_FILE" ]; then
    echo "Halt reason: $(cat "$HALT_FILE")"
    echo "Delete before restarting: rm $HALT_FILE"
    TASK_DIR="$HOME/.claude/tasks/$TASK_LIST_ID"
    if [ -d "$TASK_DIR" ]; then
        rm -rf "$TASK_DIR"
        echo "Cleaned task list: $TASK_LIST_ID"
    fi
fi
