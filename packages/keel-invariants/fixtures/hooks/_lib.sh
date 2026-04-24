#!/usr/bin/env bash
# Shared helpers for block-secret-access.sh replay fixtures (Story 2.17 Task 15.1).
# Each fixture sources this file, crafts a JSON payload, and asserts the hook's
# decision. The hook itself lives at <repo>/.claude/hooks/block-secret-access.sh
# and consumes stdin payloads shaped like Claude Code PreToolUse events.

set -euo pipefail

# Locate repo root from this file's location: packages/keel-invariants/fixtures/hooks/_lib.sh
# shellcheck disable=SC2155
FIXTURES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2155
REPO_ROOT="$(cd "${FIXTURES_LIB_DIR}/../../../../" && pwd)"
HOOK_PATH="${REPO_ROOT}/.claude/hooks/block-secret-access.sh"

if [ ! -x "$HOOK_PATH" ]; then
  printf 'FIXTURE-LIB ERROR: hook not found or not executable: %s\n' "$HOOK_PATH" >&2
  exit 2
fi

# Unset Ralph-runtime env so fixture runs do not append to real logs.
unset RALPH_BASE_DIR RALPH_ITER_ID

_run_hook() {
  local payload="$1"
  printf '%s' "$payload" | "$HOOK_PATH"
}

_extract() {
  # $1=json $2=jq-expr. Returns empty if jq exits nonzero.
  printf '%s' "$1" | jq -r "$2" 2>/dev/null || printf ''
}

_fail() {
  local label="$1" reason="$2" actual="$3"
  printf 'FAIL [%s]: %s\n  actual: %s\n' "$label" "$reason" "$actual" >&2
  return 1
}

_pass() {
  local label="$1"
  printf 'PASS [%s]\n' "$label"
}

# expect_block LABEL PAYLOAD RULE_ID [MATCH]
# Asserts decision=block, reason=RULE_ID, optionally match=MATCH.
expect_block() {
  local label="$1" payload="$2" expected_rule="$3" expected_match="${4:-}"
  local output decision reason match
  output="$(_run_hook "$payload")"
  decision="$(_extract "$output" '.decision // empty')"
  reason="$(_extract "$output" '.reason // empty')"
  match="$(_extract "$output" '.match // empty')"
  if [ "$decision" != "block" ]; then
    _fail "$label" "expected decision=block, got decision=$decision" "$output"
    return 1
  fi
  if [ "$reason" != "$expected_rule" ]; then
    _fail "$label" "expected reason=$expected_rule, got reason=$reason" "$output"
    return 1
  fi
  if [ -n "$expected_match" ] && [ "$match" != "$expected_match" ]; then
    _fail "$label" "expected match=$expected_match, got match=$match" "$output"
    return 1
  fi
  _pass "$label"
}

# expect_approve LABEL PAYLOAD
# Asserts decision=approve (no rule fired; hook default or intentional exemption).
expect_approve() {
  local label="$1" payload="$2"
  local output decision
  output="$(_run_hook "$payload")"
  decision="$(_extract "$output" '.decision // empty')"
  if [ "$decision" != "approve" ]; then
    _fail "$label" "expected decision=approve, got $output" "$output"
    return 1
  fi
  _pass "$label"
}

# payload_bash COMMAND
# Produces a Bash-tool PreToolUse payload.
payload_bash() {
  jq -nc --arg cmd "$1" '{tool_name:"Bash",tool_input:{command:$cmd}}'
}

# payload_read FILE_PATH
payload_read() {
  jq -nc --arg fp "$1" '{tool_name:"Read",tool_input:{file_path:$fp}}'
}

# payload_edit FILE_PATH  (Edit|Write|MultiEdit share the same shape)
payload_edit() {
  jq -nc --arg fp "$1" '{tool_name:"Edit",tool_input:{file_path:$fp}}'
}

payload_write() {
  jq -nc --arg fp "$1" '{tool_name:"Write",tool_input:{file_path:$fp}}'
}

payload_multiedit() {
  jq -nc --arg fp "$1" '{tool_name:"MultiEdit",tool_input:{file_path:$fp}}'
}

payload_notebookedit() {
  jq -nc --arg np "$1" '{tool_name:"NotebookEdit",tool_input:{notebook_path:$np}}'
}

# payload_grep PATTERN [PATH]
payload_grep() {
  if [ $# -ge 2 ]; then
    jq -nc --arg pat "$1" --arg p "$2" '{tool_name:"Grep",tool_input:{pattern:$pat,path:$p}}'
  else
    jq -nc --arg pat "$1" '{tool_name:"Grep",tool_input:{pattern:$pat}}'
  fi
}

payload_glob() {
  if [ $# -ge 2 ]; then
    jq -nc --arg pat "$1" --arg p "$2" '{tool_name:"Glob",tool_input:{pattern:$pat,path:$p}}'
  else
    jq -nc --arg pat "$1" '{tool_name:"Glob",tool_input:{pattern:$pat}}'
  fi
}

# payload_raw TOOL_NAME JSON_INPUT
# Escape hatch for unusual tool names.
payload_raw() {
  jq -nc --arg tn "$1" --argjson inp "$2" '{tool_name:$tn,tool_input:$inp}'
}

# payload_notool JSON_INPUT
# Omits tool_name entirely. Hook line 12-16 sets tool_name="__unknown__" when the field
# is empty/missing, which triggers the D-34 fail-secure unknown-tool fallback scan.
payload_notool() {
  jq -nc --argjson inp "$1" '{tool_input:$inp}'
}
