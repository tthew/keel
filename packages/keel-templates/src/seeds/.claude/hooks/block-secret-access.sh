#!/usr/bin/env bash
# .claude/hooks/block-secret-access.sh - Story 2.16 PreToolUse hook
# Story 2.17 Task 7 (L1 install-boundary), Task 8 (settings-file patterns), Task 10.1 D-12..D-35.
set -euo pipefail
# D-19 — case-insensitive pattern matching across case/regex blocks (defense-in-depth on mixed-case
# FS bypass: e.g. `cat .ENVRC`, `/HOME/DEV/.claude/...`). Restored before fork-hook invocation.
shopt -s nocasematch
payload="$(cat)"
# D-34 — jq fail-secure: on parse failure (malformed JSON) set tool_name=__unknown__, stderr-log,
# and run a catch-all raw-payload scan below (before default-approve). Prior silent `|| printf ''`
# fallback allowed malformed payloads to fall through all case arms + reach default approve.
if ! tool_name="$(printf '%s' "$payload" | jq -r '.tool_name // empty' 2>/dev/null)"; then
  printf '[block-secret-access] jq parse failed; fail-secure unknown-tool scan\n' >&2
  tool_name="__unknown__"
fi
[ -z "$tool_name" ] && tool_name="__unknown__"
bash_command=""
normalized=""
file_path=""
pattern=""
search_path=""
case "$tool_name" in
  Bash) bash_command="$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null || printf '')" ;;
  # D-25 — MultiEdit + NotebookEdit matchers added at .claude/settings.json hooks.PreToolUse.
  # MultiEdit uses .tool_input.file_path (parallel to Edit); NotebookEdit uses .tool_input.notebook_path.
  Read|Edit|Write|MultiEdit) file_path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null || printf '')" ;;
  NotebookEdit) file_path="$(printf '%s' "$payload" | jq -r '.tool_input.notebook_path // empty' 2>/dev/null || printf '')" ;;
  Grep) pattern="$(printf '%s' "$payload" | jq -r '.tool_input.pattern // empty' 2>/dev/null || printf '')"
        search_path="$(printf '%s' "$payload" | jq -r '.tool_input.path // empty' 2>/dev/null || printf '')" ;;
  Glob) pattern="$(printf '%s' "$payload" | jq -r '.tool_input.pattern // empty' 2>/dev/null || printf '')"
        # D-20 — Glob tool also exposes `.tool_input.path`; previously only Grep's path was read.
        search_path="$(printf '%s' "$payload" | jq -r '.tool_input.path // empty' 2>/dev/null || printf '')" ;;
esac
# D-22 — resolve symlink target for Read/Edit/Write/MultiEdit/NotebookEdit file paths; exemption-guard
# below blocks `decoy.envrc.example → /home/dev/.claude/.credentials.json` bypass attempts.
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
# D-31 — /proc secret-bearing paths added to symlink-example-to-secret-dir guard.
case "$tool_name" in
  Read)
    case "$file_path" in
      *.envrc.example|*.secrets.example|*.env.example)
        case "$resolved_file_path" in
          /home/dev/.claude/*|/home/dev/.config/gh/*|*/home/dev/.claude/*|*/home/dev/.config/gh/*|/home/dev/.ssh/*|*/home/dev/.ssh/*|/proc/*/environ|*/proc/*/environ|/proc/*/cmdline|/proc/*/mem|/proc/*/status|/proc/*/auxv|/proc/*/maps|/proc/self/*|/proc/kcore|/proc/kmem|/proc/kallsyms)
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
        /home/dev/.claude/*|/home/dev/.config/gh/*|*/home/dev/.claude/*|*/home/dev/.config/gh/*|/home/dev/.ssh/*|*/home/dev/.ssh/*|/proc/*/environ|*/proc/*/environ|/proc/*/cmdline|/proc/*/mem|/proc/*/status|/proc/*/auxv|/proc/*/maps|/proc/self/*|/proc/kcore|/proc/kmem|/proc/kallsyms)
          block "secret-access-denylist" "symlink-example-to-secret-dir" ;;
      esac
      printf '{"decision":"approve"}\n'; exit 0
    fi ;;
esac

case "$tool_name" in
  # D-25 — MultiEdit + NotebookEdit share Edit|Write hook-self-protection + L1 install-boundary gating.
  # MultiEdit writes multiple edits to one file (file_path parallel to Edit).
  # NotebookEdit writes a notebook cell (notebook_path, already extracted into file_path above).
  Edit|Write|MultiEdit|NotebookEdit)
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
    # D-14/D-35 — hook-self-protection mutation-verb word-boundary anchoring. Each verb must appear
    # at start-of-command followed by whitespace or EOL; previously bare `rm*` / `cp*` / `dd*`
    # case-globs FP'd on `rmdir` / `cpio` / `ddrescue`. Regex form `^rm([[:space:]]|$)` tightens.
    # Runs against $normalized to catch wrapper-prefixed forms (D-15 strips sudo/bash -c/etc.).
    protected_paths_re='(\.claude/settings|\.claude/hooks/|\.git/hooks/)'
    if [[ "$normalized" =~ $protected_paths_re ]]; then
      if [[ "$normalized" =~ ^rm([[:space:]]|$) ]]; then block "hook-self-protection" "rm-against-protected"; fi
      if [[ "$normalized" =~ ^mv([[:space:]]|$) ]]; then block "hook-self-protection" "mv-against-protected"; fi
      if [[ "$normalized" =~ ^chmod([[:space:]]|$) ]]; then block "hook-self-protection" "chmod-against-protected"; fi
      if [[ "$normalized" =~ ^tee([[:space:]]|$) ]]; then block "hook-self-protection" "tee-against-protected"; fi
      if [[ "$normalized" =~ ^sed[[:space:]]+(-[a-zA-Z]*[iI]|--in-place) ]]; then block "hook-self-protection" "sed-i-against-protected"; fi
      if [[ "$normalized" =~ ^echo[[:space:]] ]] && [[ "$normalized" =~ \> ]]; then block "hook-self-protection" "echo-redirect-against-protected"; fi
      if [[ "$normalized" =~ ^cp([[:space:]]|$) ]]; then block "hook-self-protection" "cp-against-protected"; fi
      if [[ "$normalized" =~ ^truncate([[:space:]]|$) ]]; then block "hook-self-protection" "truncate-against-protected"; fi
      if [[ "$normalized" =~ ^dd([[:space:]]|$) ]]; then block "hook-self-protection" "dd-against-protected"; fi
    fi
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
# D-28 — tilde-form (~/.claude, ~/.config/gh, ~/.ssh) + /home/dev/.ssh parallel patterns; hook sees
# pre-expansion text, so tilde-form is an active bypass surface in agent paths.
# D-31 — /proc surface narrow: /proc/PID/(cmdline|environ|mem|status|auxv|maps), /proc/self/*,
# /proc/k{core,mem,allsyms}. Regex form replaces the prior /proc/*/environ-only case-glob chain.
case "$tool_name" in
  Bash)
    if [[ "$normalized" =~ ^(env|export|set)([[:space:]]|$) ]]; then
      block "secret-access-denylist" "env-dump-bare"
    fi
    # D-31 — /proc reader detection via regex (word-boundary verb + expanded secret-bearing paths).
    # Replaces prior 19-alternative `cat*/proc/*/environ*|...` case-glob; far more maintainable.
    reader_verb_re='(^|[[:space:]])(cat|less|tail|head|bat|xxd|od|strings|more|grep|awk|sed|cp|dd)[[:space:]]'
    interp_verb_re='(^|[[:space:]])(node|python|python3|perl|ruby|php)[[:space:]]+-[a-zA-Z]*[ec]'
    proc_secret_re='/proc/([0-9]+|self)/(cmdline|environ|mem|status|auxv|maps|stack|syscall|io)|/proc/(kcore|kmem|kallsyms)'
    if [[ "$normalized" =~ $reader_verb_re || "$normalized" =~ $interp_verb_re ]]; then
      if [[ "$normalized" =~ $proc_secret_re ]]; then
        block "secret-access-denylist" "cat-proc-environ"
      fi
    fi
    case "$normalized" in
      printenv*) block "secret-access-denylist" "printenv-idiom" ;;
      cat*/home/dev/.claude/*|cat*/home/dev/.config/gh/*|cat*~/.claude/*|cat*~/.config/gh/*|less*/home/dev/.claude/*|less*/home/dev/.config/gh/*|less*~/.claude/*|less*~/.config/gh/*|tail*/home/dev/.claude/*|tail*/home/dev/.config/gh/*|tail*~/.claude/*|tail*~/.config/gh/*|head*/home/dev/.claude/*|head*/home/dev/.config/gh/*|head*~/.claude/*|head*~/.config/gh/*|bat*/home/dev/.claude/*|bat*/home/dev/.config/gh/*|bat*~/.claude/*|bat*~/.config/gh/*|xxd*/home/dev/.claude/*|xxd*/home/dev/.config/gh/*|xxd*~/.claude/*|xxd*~/.config/gh/*|od*/home/dev/.claude/*|od*/home/dev/.config/gh/*|od*~/.claude/*|od*~/.config/gh/*|strings*/home/dev/.claude/*|strings*/home/dev/.config/gh/*|strings*~/.claude/*|strings*~/.config/gh/*|more*/home/dev/.claude/*|more*/home/dev/.config/gh/*|more*~/.claude/*|more*~/.config/gh/*|grep*/home/dev/.claude/*|grep*/home/dev/.config/gh/*|grep*~/.claude/*|grep*~/.config/gh/*|awk*/home/dev/.claude/*|awk*/home/dev/.config/gh/*|awk*~/.claude/*|awk*~/.config/gh/*|sed*/home/dev/.claude/*|sed*/home/dev/.config/gh/*|sed*~/.claude/*|sed*~/.config/gh/*|cp*/home/dev/.claude/*|cp*/home/dev/.config/gh/*|cp*~/.claude/*|cp*~/.config/gh/*|dd*/home/dev/.claude/*|dd*/home/dev/.config/gh/*|dd*~/.claude/*|dd*~/.config/gh/*|node*-[ec]*/home/dev/.claude/*|node*-[ec]*/home/dev/.config/gh/*|node*-[ec]*~/.claude/*|node*-[ec]*~/.config/gh/*|python*-[ec]*/home/dev/.claude/*|python*-[ec]*/home/dev/.config/gh/*|python*-[ec]*~/.claude/*|python*-[ec]*~/.config/gh/*|python3*-[ec]*/home/dev/.claude/*|python3*-[ec]*/home/dev/.config/gh/*|python3*-[ec]*~/.claude/*|python3*-[ec]*~/.config/gh/*|perl*-[ec]*/home/dev/.claude/*|perl*-[ec]*/home/dev/.config/gh/*|perl*-[ec]*~/.claude/*|perl*-[ec]*~/.config/gh/*|ruby*-[ec]*/home/dev/.claude/*|ruby*-[ec]*/home/dev/.config/gh/*|ruby*-[ec]*~/.claude/*|ruby*-[ec]*~/.config/gh/*|php*-[ec]*/home/dev/.claude/*|php*-[ec]*/home/dev/.config/gh/*|php*-[ec]*~/.claude/*|php*-[ec]*~/.config/gh/*) block "secret-access-denylist" "cat-oauth-token" ;;
      cat*/home/dev/.ssh/*|cat*~/.ssh/*|less*/home/dev/.ssh/*|less*~/.ssh/*|tail*/home/dev/.ssh/*|tail*~/.ssh/*|head*/home/dev/.ssh/*|head*~/.ssh/*|bat*/home/dev/.ssh/*|bat*~/.ssh/*|xxd*/home/dev/.ssh/*|xxd*~/.ssh/*|od*/home/dev/.ssh/*|od*~/.ssh/*|strings*/home/dev/.ssh/*|strings*~/.ssh/*|more*/home/dev/.ssh/*|more*~/.ssh/*|grep*/home/dev/.ssh/*|grep*~/.ssh/*|awk*/home/dev/.ssh/*|awk*~/.ssh/*|sed*/home/dev/.ssh/*|sed*~/.ssh/*|cp*/home/dev/.ssh/*|cp*~/.ssh/*|dd*/home/dev/.ssh/*|dd*~/.ssh/*|node*-[ec]*/home/dev/.ssh/*|node*-[ec]*~/.ssh/*|python*-[ec]*/home/dev/.ssh/*|python*-[ec]*~/.ssh/*|python3*-[ec]*/home/dev/.ssh/*|python3*-[ec]*~/.ssh/*|perl*-[ec]*/home/dev/.ssh/*|perl*-[ec]*~/.ssh/*|ruby*-[ec]*/home/dev/.ssh/*|ruby*-[ec]*~/.ssh/*|php*-[ec]*/home/dev/.ssh/*|php*-[ec]*~/.ssh/*) block "secret-access-denylist" "cat-ssh-key" ;;
      cat*.envrc*|cat*/.envrc*|less*.envrc*|less*/.envrc*|tail*.envrc*|tail*/.envrc*|head*.envrc*|head*/.envrc*|bat*.envrc*|bat*/.envrc*|xxd*.envrc*|xxd*/.envrc*|od*.envrc*|od*/.envrc*|strings*.envrc*|strings*/.envrc*|more*.envrc*|more*/.envrc*|grep*.envrc*|grep*/.envrc*|awk*.envrc*|awk*/.envrc*|sed*.envrc*|sed*/.envrc*|cp*.envrc*|cp*/.envrc*|dd*.envrc*|dd*/.envrc*|node*-[ec]*.envrc*|node*-[ec]*/.envrc*|python*-[ec]*.envrc*|python*-[ec]*/.envrc*|python3*-[ec]*.envrc*|python3*-[ec]*/.envrc*|perl*-[ec]*.envrc*|perl*-[ec]*/.envrc*|ruby*-[ec]*.envrc*|ruby*-[ec]*/.envrc*|php*-[ec]*.envrc*|php*-[ec]*/.envrc*) block "secret-access-denylist" "cat-envrc-file" ;;
      cat*.secrets*|cat*/.secrets*|less*.secrets*|less*/.secrets*|tail*.secrets*|tail*/.secrets*|head*.secrets*|head*/.secrets*|bat*.secrets*|bat*/.secrets*|xxd*.secrets*|xxd*/.secrets*|od*.secrets*|od*/.secrets*|strings*.secrets*|strings*/.secrets*|more*.secrets*|more*/.secrets*|grep*.secrets*|grep*/.secrets*|awk*.secrets*|awk*/.secrets*|sed*.secrets*|sed*/.secrets*|cp*.secrets*|cp*/.secrets*|dd*.secrets*|dd*/.secrets*|node*-[ec]*.secrets*|node*-[ec]*/.secrets*|python*-[ec]*.secrets*|python*-[ec]*/.secrets*|python3*-[ec]*.secrets*|python3*-[ec]*/.secrets*|perl*-[ec]*.secrets*|perl*-[ec]*/.secrets*|ruby*-[ec]*.secrets*|ruby*-[ec]*/.secrets*|php*-[ec]*.secrets*|php*-[ec]*/.secrets*) block "secret-access-denylist" "cat-secrets-file" ;;
      cat*.env|cat*.env.*|cat*/.env|cat*/.env.*|less*.env|less*.env.*|less*/.env|less*/.env.*|tail*.env|tail*.env.*|tail*/.env|tail*/.env.*|head*.env|head*.env.*|head*/.env|head*/.env.*|bat*.env|bat*.env.*|bat*/.env|bat*/.env.*|xxd*.env|xxd*.env.*|xxd*/.env|xxd*/.env.*|od*.env|od*.env.*|od*/.env|od*/.env.*|strings*.env|strings*.env.*|strings*/.env|strings*/.env.*|more*.env|more*.env.*|more*/.env|more*/.env.*|grep*.env|grep*.env.*|grep*/.env|grep*/.env.*|awk*.env|awk*.env.*|awk*/.env|awk*/.env.*|sed*.env|sed*.env.*|sed*/.env|sed*/.env.*|cp*.env|cp*.env.*|cp*/.env|cp*/.env.*|dd*.env|dd*.env.*|dd*/.env|dd*/.env.*|node*-[ec]*.env|node*-[ec]*.env.*|node*-[ec]*/.env|node*-[ec]*/.env.*|python*-[ec]*.env|python*-[ec]*.env.*|python*-[ec]*/.env|python*-[ec]*/.env.*|python3*-[ec]*.env|python3*-[ec]*.env.*|python3*-[ec]*/.env|python3*-[ec]*/.env.*|perl*-[ec]*.env|perl*-[ec]*.env.*|perl*-[ec]*/.env|perl*-[ec]*/.env.*|ruby*-[ec]*.env|ruby*-[ec]*.env.*|ruby*-[ec]*/.env|ruby*-[ec]*/.env.*|php*-[ec]*.env|php*-[ec]*.env.*|php*-[ec]*/.env|php*-[ec]*/.env.*) block "secret-access-denylist" "cat-env-file" ;;
    esac ;;
  Read)
    # D-22 — evaluate resolved path against secret-dir denies first (catches symlink-to-oauth-token
    # bypass where file_path itself looks benign but symlink target is in a secret directory).
    # D-28 — /home/dev/.ssh/ resolved parallel.
    # D-31 — /proc surface narrow: cmdline, mem, status, auxv, maps, self/*, kcore, kmem, kallsyms.
    case "$resolved_file_path" in
      /home/dev/.claude/*|/home/dev/.config/gh/*) block "secret-access-denylist" "read-resolved-to-oauth-token" ;;
      /home/dev/.ssh/*) block "secret-access-denylist" "read-resolved-to-ssh-key" ;;
      /proc/*/environ|*/proc/*/environ|/proc/*/cmdline|*/proc/*/cmdline|/proc/*/mem|*/proc/*/mem|/proc/*/status|*/proc/*/status|/proc/*/auxv|*/proc/*/auxv|/proc/*/maps|*/proc/*/maps|/proc/self/*|*/proc/self/*|/proc/kcore|*/proc/kcore|/proc/kmem|*/proc/kmem|/proc/kallsyms|*/proc/kallsyms)
        block "secret-access-denylist" "read-resolved-to-proc-environ" ;;
    esac
    case "$file_path" in
      /home/dev/.claude/*|/home/dev/.config/gh/*) block "secret-access-denylist" "read-oauth-token" ;;
      # D-28 — tilde-form read paths (hook sees pre-expansion text).
      \~/.claude/*|\~/.config/gh/*) block "secret-access-denylist" "read-oauth-token-tilde" ;;
      /home/dev/.ssh/*|\~/.ssh/*) block "secret-access-denylist" "read-ssh-key" ;;
      /proc/*/environ|*/proc/*/environ|/proc/*/cmdline|*/proc/*/cmdline|/proc/*/mem|*/proc/*/mem|/proc/*/status|*/proc/*/status|/proc/*/auxv|*/proc/*/auxv|/proc/*/maps|*/proc/*/maps|/proc/self/*|*/proc/self/*|/proc/kcore|*/proc/kcore|/proc/kmem|*/proc/kmem|/proc/kallsyms|*/proc/kallsyms)
        block "secret-access-denylist" "read-proc-environ" ;;
      *.envrc|*.envrc.*|*/.envrc|*/.envrc.*) block "secret-access-denylist" "read-envrc-file" ;;
      *.env|*.env.*|*/.env|*/.env.*) block "secret-access-denylist" "read-env-file" ;;
      *.secrets|*.secrets.*|*/.secrets|*/.secrets.*) block "secret-access-denylist" "read-secrets-file" ;;
      # D-30 — secret-file patterns (parallel to Story 2.15 iter-316 permissions-layer landing).
      id_rsa|*/id_rsa|id_ed25519|*/id_ed25519|id_ecdsa|*/id_ecdsa|*.pem|*.key|credentials.json|*/credentials.json|.pgpass|*/.pgpass|.npmrc|*/.npmrc|.pypirc|*/.pypirc|*.p12|*.pfx|*.crt)
        block "secret-access-denylist" "read-secret-file" ;;
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

# D-34 — unknown-tool fallback (jq-parse-failed or missing tool_name). Raw-payload substring
# scan for unambiguous secret-bearing paths; fail-secure blocks rather than silent approve.
# Targets absolute paths that cannot legitimately occur in non-secret-bearing tool inputs.
if [ "$tool_name" = "__unknown__" ]; then
  case "$payload" in
    *"/home/dev/.claude/"*|*"/home/dev/.config/gh/"*|*"/home/dev/.ssh/"*)
      block "secret-access-denylist" "unknown-tool-raw-secret-dir" ;;
    *"/proc/kcore"*|*"/proc/kmem"*|*"/proc/kallsyms"*|*"/proc/self/"*)
      block "secret-access-denylist" "unknown-tool-raw-proc-kernel" ;;
  esac
  case "$payload" in
    *"/proc/"[0-9]*"/environ"*|*"/proc/"[0-9]*"/cmdline"*|*"/proc/"[0-9]*"/mem"*|*"/proc/"[0-9]*"/status"*|*"/proc/"[0-9]*"/auxv"*|*"/proc/"[0-9]*"/maps"*)
      block "secret-access-denylist" "unknown-tool-raw-proc-pid" ;;
  esac
fi

# D-19 — restore default case-sensitive matching before invoking fork hook (clean child env).
shopt -u nocasematch

# D-26 — anchor fork-hook path to substrate hook's own directory (cwd-independence); fork-hook
# lives next to the substrate hook regardless of which cwd the Claude Code runtime spawns from.
# D-27 — fork-hook contract enforcement: parse stdout as JSON {decision, reason?, match?};
# validate shape; fail-closed on nonzero exit OR invalid JSON with a substrate-emitted block.
fork_hook_path="$(dirname "${BASH_SOURCE[0]}")/block-secret-access.fork.sh"
if [ -x "$fork_hook_path" ]; then
  fork_output=""
  fork_exit=0
  fork_output="$(printf '%s' "$payload" | "$fork_hook_path" 2>/dev/null)" || fork_exit=$?
  if [ "$fork_exit" -ne 0 ]; then
    block "fork-hook-contract-violation" "nonzero-exit"
  fi
  if ! printf '%s' "$fork_output" | jq -e 'type == "object" and ((.decision == "approve") or (.decision == "block" and ((.reason // "") | length) > 0))' >/dev/null 2>&1; then
    block "fork-hook-contract-violation" "invalid-json-shape"
  fi
  if printf '%s' "$fork_output" | jq -e '.decision == "block"' >/dev/null 2>&1; then
    fork_reason="$(printf '%s' "$fork_output" | jq -r '.reason // ""')"
    fork_match="$(printf '%s' "$fork_output" | jq -r '.match // ""')"
    log_block "fork-hook:$fork_reason" "$fork_match"
  fi
  printf '%s\n' "$fork_output"
  exit 0
fi
printf '{"decision":"approve"}\n'
exit 0
