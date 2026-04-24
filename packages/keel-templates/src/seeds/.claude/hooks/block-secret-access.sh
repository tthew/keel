#!/usr/bin/env bash
# .claude/hooks/block-secret-access.sh - Story 2.16 PreToolUse hook (Story 2.17 Task 7 L1 install-boundary extension; Task 8.4 settings.*.json forward-compat pattern)
set -euo pipefail
payload="$(cat)"
tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null || printf '')"
bash_command=""
file_path=""
pattern=""
grep_path=""
case "$tool_name" in
  Bash) bash_command="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || printf '')" ;;
  Read|Edit|Write) file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null || printf '')" ;;
  Grep) pattern="$(printf '%s' "$payload" | jq -r '.tool_input.pattern // empty' 2>/dev/null || printf '')"
        grep_path="$(printf '%s' "$payload" | jq -r '.tool_input.path // empty' 2>/dev/null || printf '')" ;;
  Glob) pattern="$(printf '%s' "$payload" | jq -r '.tool_input.pattern // empty' 2>/dev/null || printf '')" ;;
esac
log_block() {
  local rule_id="$1" match="$2"
  [ -z "${RALPH_BASE_DIR:-}" ] && return 0
  local iter_id="${RALPH_ITER_ID:-unknown}"
  local log_dir="${RALPH_BASE_DIR}/logs/${iter_id}"
  mkdir -p "$log_dir" 2>/dev/null || return 0
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '{"timestamp":"%s","iteration_id":"%s","tool":"%s","args_redacted":"<redacted>","rule_id":"%s","match":"%s"}\n' \
    "$ts" "$iter_id" "$tool_name" "$rule_id" "$match" >> "$log_dir/blocked-tool-calls.jsonl" 2>/dev/null || true
}
block() {
  local rule_id="$1" match="$2"
  printf '{"decision":"block","reason":"%s","match":"%s"}\n' "$rule_id" "$match"
  log_block "$rule_id" "$match"
  exit 0
}
# Story 2.17 Task 7 — L1 install-boundary protection regex (shared by Edit|Write + Bash arms).
# Protected substrate files under packages/keel-invariants/src/ that Ralph MUST NOT author.
l1_path_re='packages/keel-invariants/src/(invariants\.manifest\.ts|sync-gate\.ts|manifest-reader\.ts|prek-hook-manifest\.ts|prompt-injection-rules/)'
case "$tool_name" in
  Read)
    case "$file_path" in
      *.envrc.example|*.secrets.example|*.env.example)
        printf '{"decision":"approve"}\n'; exit 0 ;;
    esac ;;
esac
case "$tool_name" in
  Edit|Write)
    # Story 2.17 Task 8.4 — settings-file patterns (exact, forward-compat .*.json, and nested under any prefix).
    case "$file_path" in
      .claude/settings.json|.claude/settings.local.json|.claude/settings.*.json|*/.claude/settings.json|*/.claude/settings.local.json|*/.claude/settings.*.json)
        block "hook-self-protection" "settings-file" ;;
      .claude/hooks/*|*/.claude/hooks/*) block "hook-self-protection" "hook-script-file" ;;
      .git/hooks/*|*/.git/hooks/*) block "hook-self-protection" "git-hook-file" ;;
    esac
    # Story 2.17 Task 7 — L1 install-boundary Edit|Write denial.
    if [[ "$file_path" =~ $l1_path_re ]]; then
      block "install-boundary-protection" "install-boundary-file"
    fi ;;
  Bash)
    if [[ "$bash_command" =~ ^git[[:space:]]+(commit|push) ]] && [[ "$bash_command" == *--no-verify* ]]; then
      block "hook-self-protection" "git-no-verify-bypass"
    fi
    case "$bash_command" in
      rm*.claude/settings*|rm*.claude/hooks/*|rm*.git/hooks/*) block "hook-self-protection" "rm-against-protected" ;;
      mv*.claude/settings*|mv*.claude/hooks/*|mv*.git/hooks/*) block "hook-self-protection" "mv-against-protected" ;;
      chmod*.claude/hooks/*|chmod*.git/hooks/*) block "hook-self-protection" "chmod-against-protected" ;;
      tee*.claude/settings*|tee*.claude/hooks/*) block "hook-self-protection" "tee-against-protected" ;;
      sed*-i*.claude/settings*|sed*-i*.claude/hooks/*) block "hook-self-protection" "sed-i-against-protected" ;;
      echo*\>*.claude/settings*|echo*\>*.claude/hooks/*) block "hook-self-protection" "echo-redirect-against-protected" ;;
      cp*.claude/settings*|cp*.claude/hooks/*) block "hook-self-protection" "cp-against-protected" ;;
    esac
    # Story 2.17 Task 7 — L1 install-boundary Bash mutation denial.
    # Guard expensive regex matching behind the path-presence gate (short-circuit on non-L1 commands).
    if [[ "$bash_command" =~ $l1_path_re ]]; then
      if [[ "$bash_command" =~ (^|[[:space:]])(rm|mv|chmod|tee|cp|truncate|dd)[[:space:]] ]]; then
        block "install-boundary-protection" "mutation-verb-against-l1"
      fi
      if [[ "$bash_command" =~ (^|[[:space:]])sed[[:space:]]+-i ]]; then
        block "install-boundary-protection" "sed-i-against-l1"
      fi
      if [[ "$bash_command" =~ (^|[[:space:]])echo.*\> ]]; then
        block "install-boundary-protection" "echo-redirect-against-l1"
      fi
      if [[ "$bash_command" =~ (^|[[:space:]])find[[:space:]].*-delete ]]; then
        block "install-boundary-protection" "find-delete-against-l1"
      fi
    fi ;;
esac
case "$tool_name" in
  Bash)
    case "$bash_command" in
      env|export|set) block "secret-access-denylist" "env-dump-bare" ;;
      printenv*) block "secret-access-denylist" "printenv-idiom" ;;
      cat*/proc/*/environ*) block "secret-access-denylist" "cat-proc-environ" ;;
      cat*/home/dev/.claude/*|cat*/home/dev/.config/gh/*) block "secret-access-denylist" "cat-oauth-token" ;;
      cat*.envrc*|cat*/.envrc*) block "secret-access-denylist" "cat-envrc-file" ;;
      cat*.secrets*|cat*/.secrets*) block "secret-access-denylist" "cat-secrets-file" ;;
      cat*.env|cat*.env.*|cat*/.env|cat*/.env.*) block "secret-access-denylist" "cat-env-file" ;;
    esac ;;
  Read)
    case "$file_path" in
      /home/dev/.claude/*|/home/dev/.config/gh/*) block "secret-access-denylist" "read-oauth-token" ;;
      /proc/*/environ|*/proc/*/environ) block "secret-access-denylist" "read-proc-environ" ;;
      *.envrc|*.envrc.*|*/.envrc|*/.envrc.*) block "secret-access-denylist" "read-envrc-file" ;;
      *.env|*.env.*|*/.env|*/.env.*) block "secret-access-denylist" "read-env-file" ;;
      *.secrets|*.secrets.*|*/.secrets|*/.secrets.*) block "secret-access-denylist" "read-secrets-file" ;;
    esac ;;
  Grep|Glob)
    case "$pattern" in
      *.env*|*.envrc*|*.secrets*) block "secret-access-denylist" "grep-glob-secret-pattern" ;;
    esac
    case "$grep_path" in
      /home/dev/.claude/*|/home/dev/.config/gh/*) block "secret-access-denylist" "grep-path-oauth" ;;
    esac ;;
esac
if [ -x .claude/hooks/block-secret-access.fork.sh ]; then
  printf '%s' "$payload" | .claude/hooks/block-secret-access.fork.sh
  exit "$?"
fi
printf '{"decision":"approve"}\n'
exit 0
