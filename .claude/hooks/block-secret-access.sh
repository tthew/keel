#!/usr/bin/env bash
# .claude/hooks/block-secret-access.sh - Story 2.16 PreToolUse hook
# Story 2.17 Task 7 (L1 install-boundary), Task 8 (settings-file patterns), Task 10.1 D-12..D-24.
set -euo pipefail
# D-19 — case-insensitive pattern matching across case/regex blocks (defense-in-depth on mixed-case
# FS bypass: e.g. `cat .ENVRC`, `/HOME/DEV/.claude/...`). Restored before fork-hook invocation.
shopt -s nocasematch
payload="$(cat)"
tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null || printf '')"
bash_command=""
normalized=""
file_path=""
pattern=""
search_path=""
case "$tool_name" in
  Bash) bash_command="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || printf '')" ;;
  Read|Edit|Write) file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null || printf '')" ;;
  Grep) pattern="$(printf '%s' "$payload" | jq -r '.tool_input.pattern // empty' 2>/dev/null || printf '')"
        search_path="$(printf '%s' "$payload" | jq -r '.tool_input.path // empty' 2>/dev/null || printf '')" ;;
  Glob) pattern="$(printf '%s' "$payload" | jq -r '.tool_input.pattern // empty' 2>/dev/null || printf '')"
        # D-20 — Glob tool also exposes `.tool_input.path`; previously only Grep's path was read.
        search_path="$(printf '%s' "$payload" | jq -r '.tool_input.path // empty' 2>/dev/null || printf '')" ;;
esac
# D-22 — resolve symlink target for Read/Edit/Write file paths; exemption-guard below blocks
# `decoy.envrc.example → /home/dev/.claude/.credentials.json` bypass attempts.
resolved_file_path=""
if [ -n "$file_path" ]; then
  resolved_file_path="$(readlink -f "$file_path" 2>/dev/null || printf '%s' "$file_path")"
fi
log_block() {
  local rule_id="$1" match="$2"
  [ -z "${RALPH_BASE_DIR:-}" ] && return 0
  local iter_id="${RALPH_ITER_ID:-unknown}"
  local log_dir="${RALPH_BASE_DIR}/logs/${iter_id}"
  mkdir -p "$log_dir" 2>/dev/null || return 0
  local ts; ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  # D-21 — jq --arg construction prevents JSON injection via " / \ / newline in iter/rule/match.
  # D-24 — append-failure surfaces to stderr instead of silent-drop; block decision still stdouts.
  if ! jq -nc \
    --arg ts "$ts" \
    --arg iter "$iter_id" \
    --arg tool "$tool_name" \
    --arg rule "$rule_id" \
    --arg match "$match" \
    '{timestamp: $ts, iteration_id: $iter, tool: $tool, args_redacted: "<redacted>", rule_id: $rule, match: $match}' \
    >> "$log_dir/blocked-tool-calls.jsonl"; then
    printf '[block-secret-access] JSONL write failed: %d\n' "$?" >&2
  fi
}
block() {
  local rule_id="$1" match="$2"
  printf '{"decision":"block","reason":"%s","match":"%s"}\n' "$rule_id" "$match"
  log_block "$rule_id" "$match"
  exit 0
}

# D-15 — wrapper-command normalization. Strip outermost wrapper prefix (single level, up to 3 rounds)
# to defeat `sudo cat /proc/self/environ`, `bash -c 'cat .envrc'`, `/usr/bin/rm .claude/hooks/foo`, etc.
# Known residual gap: compound commands (`echo safe && rm protected`) evade. Defense-in-depth, not sole.
if [ "$tool_name" = "Bash" ]; then
  normalized="$bash_command"
  for _ in 1 2 3; do
    if [[ "$normalized" =~ ^(bash|sh)[[:space:]]+-c[[:space:]]+[\"\']?(.*)$ ]]; then
      normalized="${BASH_REMATCH[2]}"
    elif [[ "$normalized" =~ ^sudo[[:space:]]+(.*)$ ]]; then
      normalized="${BASH_REMATCH[1]}"
    elif [[ "$normalized" =~ ^(/usr/bin/|/bin/)(.*)$ ]]; then
      normalized="${BASH_REMATCH[2]}"
    elif [[ "$normalized" =~ ^xargs([[:space:]]+-[a-zA-Z]+)*[[:space:]]+(.*)$ ]]; then
      normalized="${BASH_REMATCH[2]}"
    elif [[ "$normalized" =~ ^eval[[:space:]]+[\"\']?(.*)$ ]]; then
      normalized="${BASH_REMATCH[1]}"
    elif [[ "$normalized" =~ ^env([[:space:]]+[A-Z_][A-Za-z0-9_]*=[^[:space:]]+)+[[:space:]]+(.*)$ ]]; then
      normalized="${BASH_REMATCH[2]}"
    elif [[ "$normalized" =~ ^\\(.*)$ ]]; then
      normalized="${BASH_REMATCH[1]}"
    else
      # Do NOT strip interp-stdin (`python -c`, `node -e`, …) here — case globs below require
      # the reader-verb prefix to match `python*-[ec]*.envrc*` etc. Stripping would lose that
      # context and the Python source's `open('.envrc')` string would escape detection.
      break
    fi
  done
fi

# Story 2.17 Task 7 — L1 install-boundary protection regex (shared by Edit|Write + Bash arms).
l1_path_re='packages/keel-invariants/src/(invariants\.manifest\.ts|sync-gate\.ts|manifest-reader\.ts|prek-hook-manifest\.ts|prompt-injection-rules/)'

# D-17 — Read/Bash reader exemption for *.envrc.example / *.secrets.example / *.env.example
# (schema-companion files, intentional documentation samples).
# D-22 — guard: if the example path resolves through a symlink into a secret directory, DENY.
case "$tool_name" in
  Read)
    case "$file_path" in
      *.envrc.example|*.secrets.example|*.env.example)
        case "$resolved_file_path" in
          /home/dev/.claude/*|/home/dev/.config/gh/*|*/home/dev/.claude/*|*/home/dev/.config/gh/*|/proc/*/environ|*/proc/*/environ)
            block "secret-access-denylist" "symlink-example-to-secret-dir" ;;
        esac
        printf '{"decision":"approve"}\n'; exit 0 ;;
    esac ;;
  Bash)
    # Reader-verb (D-12 readers + interp-stdin) against *.example companion files — approve,
    # but D-22 guards against a symlink-in-example-suffix pointing into a secret directory.
    example_read_re='^(cat|less|tail|head|bat|xxd|od|strings|more|grep|awk|sed|cp|dd|node|python|python3|perl|ruby|php)([[:space:]]+-[ec])?([[:space:]]+[^[:space:]]+)*[[:space:]]+([^[:space:]]*\.(envrc|secrets|env)\.example)([[:space:]]|$)'
    if [[ "$normalized" =~ $example_read_re ]]; then
      example_arg="${BASH_REMATCH[4]}"
      example_resolved="$(readlink -f "$example_arg" 2>/dev/null || printf '%s' "$example_arg")"
      case "$example_resolved" in
        /home/dev/.claude/*|/home/dev/.config/gh/*|*/home/dev/.claude/*|*/home/dev/.config/gh/*|/proc/*/environ|*/proc/*/environ)
          block "secret-access-denylist" "symlink-example-to-secret-dir" ;;
      esac
      printf '{"decision":"approve"}\n'; exit 0
    fi ;;
esac

case "$tool_name" in
  Edit|Write)
    # Task 8.4 — settings-file patterns (exact, forward-compat .*.json, and nested under any prefix).
    case "$file_path" in
      .claude/settings.json|.claude/settings.local.json|.claude/settings.*.json|*/.claude/settings.json|*/.claude/settings.local.json|*/.claude/settings.*.json)
        block "hook-self-protection" "settings-file" ;;
      .claude/hooks/*|*/.claude/hooks/*) block "hook-self-protection" "hook-script-file" ;;
      .git/hooks/*|*/.git/hooks/*) block "hook-self-protection" "git-hook-file" ;;
    esac
    # Task 7 — L1 install-boundary Edit|Write denial.
    if [[ "$file_path" =~ $l1_path_re ]]; then
      block "install-boundary-protection" "install-boundary-file"
    fi ;;
  Bash)
    # D-16 — git --no-verify broadened regex. Covers git env-prefix (A=1 B=2 git ...), absolute-path
    # git, `-c` / `-C` pre-args (`git -c core.x=y commit ...`), all mutating subcommands.
    # Wrapper-aware: also matches against $normalized (strips bash -c / sudo / etc.).
    no_verify_re='^(([A-Z_]+=[^[:space:]]+[[:space:]]+)*)?(/usr/bin/|/bin/)?git([[:space:]]+-[cCp][[:space:]]+[^[:space:]]+)*[[:space:]]+(commit|push|merge|rebase|am|pull|cherry-pick|revert)[[:space:]].*--no-verify'
    if [[ "$bash_command" =~ $no_verify_re ]] || [[ "$normalized" =~ $no_verify_re ]]; then
      block "hook-self-protection" "git-no-verify-bypass"
    fi
    # D-14 — hook-self-protection mutation-verb coverage canonicalized. Each verb covers all three
    # target classes (.claude/settings*, .claude/hooks/*, .git/hooks/*). Run against $normalized to
    # catch wrapper-prefixed forms (sudo/bash -c/etc. stripped by D-15 normalization above).
    case "$normalized" in
      rm*.claude/settings*|rm*.claude/hooks/*|rm*.git/hooks/*) block "hook-self-protection" "rm-against-protected" ;;
      mv*.claude/settings*|mv*.claude/hooks/*|mv*.git/hooks/*) block "hook-self-protection" "mv-against-protected" ;;
      chmod*.claude/settings*|chmod*.claude/hooks/*|chmod*.git/hooks/*) block "hook-self-protection" "chmod-against-protected" ;;
      tee*.claude/settings*|tee*.claude/hooks/*|tee*.git/hooks/*) block "hook-self-protection" "tee-against-protected" ;;
      sed*-i*.claude/settings*|sed*-i*.claude/hooks/*|sed*-i*.git/hooks/*) block "hook-self-protection" "sed-i-against-protected" ;;
      echo*\>*.claude/settings*|echo*\>*.claude/hooks/*|echo*\>*.git/hooks/*) block "hook-self-protection" "echo-redirect-against-protected" ;;
      cp*.claude/settings*|cp*.claude/hooks/*|cp*.git/hooks/*) block "hook-self-protection" "cp-against-protected" ;;
      truncate*.claude/settings*|truncate*.claude/hooks/*|truncate*.git/hooks/*) block "hook-self-protection" "truncate-against-protected" ;;
      dd*.claude/settings*|dd*.claude/hooks/*|dd*.git/hooks/*) block "hook-self-protection" "dd-against-protected" ;;
    esac
    # find -delete / find -exec rm against protected paths (regex — free-form find args).
    if [[ "$normalized" =~ (^|[[:space:]])find[[:space:]].*(\.claude/settings|\.claude/hooks/?|\.git/hooks/?).*(-delete|-exec[[:space:]]+rm) ]]; then
      block "hook-self-protection" "find-delete-against-protected"
    fi
    # Task 7 — L1 install-boundary Bash mutation denial. Path-presence gate short-circuits non-L1.
    if [[ "$bash_command" =~ $l1_path_re || "$normalized" =~ $l1_path_re ]]; then
      if [[ "$normalized" =~ (^|[[:space:]])(rm|mv|chmod|tee|cp|truncate|dd)[[:space:]] ]]; then
        block "install-boundary-protection" "mutation-verb-against-l1"
      fi
      if [[ "$normalized" =~ (^|[[:space:]])sed[[:space:]]+-i ]]; then
        block "install-boundary-protection" "sed-i-against-l1"
      fi
      if [[ "$normalized" =~ (^|[[:space:]])echo.*\> ]]; then
        block "install-boundary-protection" "echo-redirect-against-l1"
      fi
      if [[ "$normalized" =~ (^|[[:space:]])find[[:space:]].*-delete ]]; then
        block "install-boundary-protection" "find-delete-against-l1"
      fi
    fi ;;
esac

# D-13 — env|export|set word-boundary (regex replaces exact-match case). Catches `env`, `env `,
# `env | sort`, `env -0`, `export`, `export -p`, `set`, `set -o posix`. Avoids false-positives on
# `envsubst`, `envvar=x cmd`, `exportfs`, `setup.sh` (no word-boundary break after verb).
# D-12 — reader verb expansion (14 readers × 5 path classes + interp-stdin with -[ec]).
case "$tool_name" in
  Bash)
    if [[ "$normalized" =~ ^(env|export|set)([[:space:]]|$) ]]; then
      block "secret-access-denylist" "env-dump-bare"
    fi
    case "$normalized" in
      printenv*) block "secret-access-denylist" "printenv-idiom" ;;
      cat*/proc/*/environ*|less*/proc/*/environ*|tail*/proc/*/environ*|head*/proc/*/environ*|bat*/proc/*/environ*|xxd*/proc/*/environ*|od*/proc/*/environ*|strings*/proc/*/environ*|more*/proc/*/environ*|grep*/proc/*/environ*|awk*/proc/*/environ*|sed*/proc/*/environ*|cp*/proc/*/environ*|dd*/proc/*/environ*|node*-[ec]*/proc/*/environ*|python*-[ec]*/proc/*/environ*|python3*-[ec]*/proc/*/environ*|perl*-[ec]*/proc/*/environ*|ruby*-[ec]*/proc/*/environ*|php*-[ec]*/proc/*/environ*) block "secret-access-denylist" "cat-proc-environ" ;;
      cat*/home/dev/.claude/*|cat*/home/dev/.config/gh/*|less*/home/dev/.claude/*|less*/home/dev/.config/gh/*|tail*/home/dev/.claude/*|tail*/home/dev/.config/gh/*|head*/home/dev/.claude/*|head*/home/dev/.config/gh/*|bat*/home/dev/.claude/*|bat*/home/dev/.config/gh/*|xxd*/home/dev/.claude/*|xxd*/home/dev/.config/gh/*|od*/home/dev/.claude/*|od*/home/dev/.config/gh/*|strings*/home/dev/.claude/*|strings*/home/dev/.config/gh/*|more*/home/dev/.claude/*|more*/home/dev/.config/gh/*|grep*/home/dev/.claude/*|grep*/home/dev/.config/gh/*|awk*/home/dev/.claude/*|awk*/home/dev/.config/gh/*|sed*/home/dev/.claude/*|sed*/home/dev/.config/gh/*|cp*/home/dev/.claude/*|cp*/home/dev/.config/gh/*|dd*/home/dev/.claude/*|dd*/home/dev/.config/gh/*|node*-[ec]*/home/dev/.claude/*|node*-[ec]*/home/dev/.config/gh/*|python*-[ec]*/home/dev/.claude/*|python*-[ec]*/home/dev/.config/gh/*|python3*-[ec]*/home/dev/.claude/*|python3*-[ec]*/home/dev/.config/gh/*|perl*-[ec]*/home/dev/.claude/*|perl*-[ec]*/home/dev/.config/gh/*|ruby*-[ec]*/home/dev/.claude/*|ruby*-[ec]*/home/dev/.config/gh/*|php*-[ec]*/home/dev/.claude/*|php*-[ec]*/home/dev/.config/gh/*) block "secret-access-denylist" "cat-oauth-token" ;;
      cat*.envrc*|cat*/.envrc*|less*.envrc*|less*/.envrc*|tail*.envrc*|tail*/.envrc*|head*.envrc*|head*/.envrc*|bat*.envrc*|bat*/.envrc*|xxd*.envrc*|xxd*/.envrc*|od*.envrc*|od*/.envrc*|strings*.envrc*|strings*/.envrc*|more*.envrc*|more*/.envrc*|grep*.envrc*|grep*/.envrc*|awk*.envrc*|awk*/.envrc*|sed*.envrc*|sed*/.envrc*|cp*.envrc*|cp*/.envrc*|dd*.envrc*|dd*/.envrc*|node*-[ec]*.envrc*|node*-[ec]*/.envrc*|python*-[ec]*.envrc*|python*-[ec]*/.envrc*|python3*-[ec]*.envrc*|python3*-[ec]*/.envrc*|perl*-[ec]*.envrc*|perl*-[ec]*/.envrc*|ruby*-[ec]*.envrc*|ruby*-[ec]*/.envrc*|php*-[ec]*.envrc*|php*-[ec]*/.envrc*) block "secret-access-denylist" "cat-envrc-file" ;;
      cat*.secrets*|cat*/.secrets*|less*.secrets*|less*/.secrets*|tail*.secrets*|tail*/.secrets*|head*.secrets*|head*/.secrets*|bat*.secrets*|bat*/.secrets*|xxd*.secrets*|xxd*/.secrets*|od*.secrets*|od*/.secrets*|strings*.secrets*|strings*/.secrets*|more*.secrets*|more*/.secrets*|grep*.secrets*|grep*/.secrets*|awk*.secrets*|awk*/.secrets*|sed*.secrets*|sed*/.secrets*|cp*.secrets*|cp*/.secrets*|dd*.secrets*|dd*/.secrets*|node*-[ec]*.secrets*|node*-[ec]*/.secrets*|python*-[ec]*.secrets*|python*-[ec]*/.secrets*|python3*-[ec]*.secrets*|python3*-[ec]*/.secrets*|perl*-[ec]*.secrets*|perl*-[ec]*/.secrets*|ruby*-[ec]*.secrets*|ruby*-[ec]*/.secrets*|php*-[ec]*.secrets*|php*-[ec]*/.secrets*) block "secret-access-denylist" "cat-secrets-file" ;;
      cat*.env|cat*.env.*|cat*/.env|cat*/.env.*|less*.env|less*.env.*|less*/.env|less*/.env.*|tail*.env|tail*.env.*|tail*/.env|tail*/.env.*|head*.env|head*.env.*|head*/.env|head*/.env.*|bat*.env|bat*.env.*|bat*/.env|bat*/.env.*|xxd*.env|xxd*.env.*|xxd*/.env|xxd*/.env.*|od*.env|od*.env.*|od*/.env|od*/.env.*|strings*.env|strings*.env.*|strings*/.env|strings*/.env.*|more*.env|more*.env.*|more*/.env|more*/.env.*|grep*.env|grep*.env.*|grep*/.env|grep*/.env.*|awk*.env|awk*.env.*|awk*/.env|awk*/.env.*|sed*.env|sed*.env.*|sed*/.env|sed*/.env.*|cp*.env|cp*.env.*|cp*/.env|cp*/.env.*|dd*.env|dd*.env.*|dd*/.env|dd*/.env.*|node*-[ec]*.env|node*-[ec]*.env.*|node*-[ec]*/.env|node*-[ec]*/.env.*|python*-[ec]*.env|python*-[ec]*.env.*|python*-[ec]*/.env|python*-[ec]*/.env.*|python3*-[ec]*.env|python3*-[ec]*.env.*|python3*-[ec]*/.env|python3*-[ec]*/.env.*|perl*-[ec]*.env|perl*-[ec]*.env.*|perl*-[ec]*/.env|perl*-[ec]*/.env.*|ruby*-[ec]*.env|ruby*-[ec]*.env.*|ruby*-[ec]*/.env|ruby*-[ec]*/.env.*|php*-[ec]*.env|php*-[ec]*.env.*|php*-[ec]*/.env|php*-[ec]*/.env.*) block "secret-access-denylist" "cat-env-file" ;;
    esac ;;
  Read)
    # D-22 — evaluate resolved path against secret-dir denies first (catches symlink-to-oauth-token
    # bypass where file_path itself looks benign but symlink target is in a secret directory).
    case "$resolved_file_path" in
      /home/dev/.claude/*|/home/dev/.config/gh/*) block "secret-access-denylist" "read-resolved-to-oauth-token" ;;
      /proc/*/environ|*/proc/*/environ) block "secret-access-denylist" "read-resolved-to-proc-environ" ;;
    esac
    case "$file_path" in
      /home/dev/.claude/*|/home/dev/.config/gh/*) block "secret-access-denylist" "read-oauth-token" ;;
      /proc/*/environ|*/proc/*/environ) block "secret-access-denylist" "read-proc-environ" ;;
      *.envrc|*.envrc.*|*/.envrc|*/.envrc.*) block "secret-access-denylist" "read-envrc-file" ;;
      *.env|*.env.*|*/.env|*/.env.*) block "secret-access-denylist" "read-env-file" ;;
      *.secrets|*.secrets.*|*/.secrets|*/.secrets.*) block "secret-access-denylist" "read-secrets-file" ;;
    esac ;;
  Grep|Glob)
    # D-18 — narrow patterns to specific secret-file name forms. Carve-out first for *.example
    # schema-companion searches (docs enumeration legitimate; parallel to Read/Bash D-17 exemption).
    case "$pattern" in
      *.envrc.example|*.envrc.example.*|*.secrets.example|*.secrets.example.*|*.env.example|*.env.example.*) ;;
      .env|.env.*|*.env|*.env.*|*/.env|*/.env.*|**/.env|**/.env.*|.envrc|.envrc.*|*.envrc|*.envrc.*|*/.envrc|*/.envrc.*|**/.envrc|**/.envrc.*|.secrets|.secrets.*|*.secrets|*.secrets.*|*/.secrets|*/.secrets.*|**/.secrets|**/.secrets.*)
        block "secret-access-denylist" "grep-glob-secret-pattern" ;;
    esac
    # D-20 — path-arg inspection for BOTH Grep and Glob (previously Grep only).
    case "$search_path" in
      /home/dev/.claude/*|/home/dev/.config/gh/*|*/home/dev/.claude/*|*/home/dev/.config/gh/*) block "secret-access-denylist" "grep-glob-path-oauth" ;;
    esac ;;
esac

# D-19 — restore default case-sensitive matching before invoking fork hook (clean child env).
shopt -u nocasematch
if [ -x .claude/hooks/block-secret-access.fork.sh ]; then
  printf '%s' "$payload" | .claude/hooks/block-secret-access.fork.sh
  exit "$?"
fi
printf '{"decision":"approve"}\n'
exit 0
