#!/usr/bin/env bash
# .claude/hooks/block-secret-access.sh - Story 2.16 PreToolUse hook
# Story 2.17 Task 7 (L1 install-boundary), Task 8 (settings-file patterns), Task 10.1 D-12..D-35.
# D-37 (PR #230 multi-vector adversarial review, 2026-05-04): word-boundary mutation-verb
# alternation + install/ln/sponge additions + redirect-into-protected catch + ANSI-C wrapper-strip.
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
# D-37 (PR #230) — added ANSI-C `$'...'` arm so `bash -c $'cat .env'` strips to `cat .env`
# instead of leaving `$'cat .env'` (which all downstream case-globs miss).
if [ "$tool_name" = "Bash" ]; then
  normalized="$bash_command"
  for _ in 1 2 3; do
    if [[ "$normalized" =~ ^(bash|sh)[[:space:]]+-c[[:space:]]+[\"\']?(.*)$ ]]; then
      normalized="${BASH_REMATCH[2]}"
    elif [[ "$normalized" =~ ^\$\'(.*)\'$ ]]; then
      # D-37 — ANSI-C `$'...'` strip. Common after a bash -c arm consumes the outer wrapper.
      # Both the leading `$'` and trailing `'` are required so the greedy (.*) leaves the trailing
      # apostrophe to the anchor — without the mandatory trailing `'` the (.*) gobbles the trailing
      # quote and downstream case-globs (anchored on `.env` end) miss the resulting `cat .env'`.
      # D-38 (PR #230 review-fix-arc, FIX-8 / A3) — decode ANSI-C backslash escapes after strip;
      # printf %b matches bash ANSI-C decoding for all viable bypass vectors (\xNN hex, \t \n \r
      # \f \v escapes, \NNN / \0NNN octal, \\). Without this pass `bash -c $'cat\x20.env'` slips
      # downstream regex (hook saw the literal source text, not the decoded `cat .env`).
      normalized="${BASH_REMATCH[1]}"
      if decoded="$(printf '%b' "$normalized" 2>/dev/null)"; then
        normalized="$decoded"
      fi
    elif [[ "$normalized" =~ ^sudo[[:space:]]+(.*)$ ]]; then
      normalized="${BASH_REMATCH[1]}"
    elif [[ "$normalized" =~ ^(/usr/bin/|/bin/)(.*)$ ]]; then
      normalized="${BASH_REMATCH[2]}"
    elif [[ "$normalized" =~ ^xargs([[:space:]]+-[a-zA-Z]+)*[[:space:]]+(.*)$ ]]; then
      normalized="${BASH_REMATCH[2]}"
    elif [[ "$normalized" =~ ^(eval|builtin|command|exec)[[:space:]]+[\"\']?(.*)$ ]]; then
      # FIX-13 v2 (PR #230 R3-Hook-B sub-agent C4) — extended `eval` arm with `builtin`,
      # `command`, `exec` to close literal `.` form bypass via non-stripped prefix. Each
      # is a bash control-builtin that prefixes any command and shell-evaluates the rest;
      # stripping mirrors eval semantics.
      normalized="${BASH_REMATCH[2]}"
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

# FIX-12 (PR #230 review-fix-arc R3-Hook-A) — verb-gate left-boundary char class
# widened to admit ( ` $ so subshell forms ((rm .env), $(cat .env), `cat .env`)
# cannot escape the verb gate. Stored in a variable so bash does not interpret
# backtick + $ as command-substitution / parameter-expansion in inline =~
# patterns (the inline arms below previously had to use [;&|] only because
# inline backtick/$ would have triggered shell expansion before regex match).
verb_left_re='(^|[[:space:]]|[`$();&|]+[[:space:]]*)'
# Narrower variant for verbs that only fire at command position (e.g. env
# dump). Excludes the bare [[:space:]] arm so substring matches in argument
# text (`echo "Important env vars: PATH"`) do not falsely flag.
subshell_left_re='(^|[`$();&|]+[[:space:]]*)'


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
    example_read_re='^(cat|less|tail|head|bat|xxd|od|strings|more|grep|awk|sed|cp|dd|node|python|python3|perl|ruby|php|wc|nl|hexdump|tac|pv|column|jq|yq|tr|read|mapfile|curl|wget|source|\.|paste|cmp|comm|diff|fmt|fold|expand|unexpand|pr|rev|md5sum|sha256sum|sha1sum|b3sum|cksum|zcat|bzcat|xzcat|lzcat|zless|zgrep|bzgrep|xzgrep)([[:space:]]+-[ec])?([[:space:]]+[^[:space:]]+)*[[:space:]]+([^[:space:]]*\.(envrc|secrets|env)\.example)([[:space:]]|$)'
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
    # D-37 (PR #230) — extended D-14/D-35 verb list to catch pipe-form bypasses + add
    # install/ln/sponge. Word-boundary now matches verb at start, after whitespace, OR
    # after a pipe (closes `cat /tmp/x | tee safe.txt > .claude/settings.json` bypass).
    # Per-verb sub-match names retained for fixture/JSONL back-compat.
    # WONTFIX (PR #230 D1) — substring-co-occurrence FP: any mutation verb (tee/cp/mv/...)
    # blocks if a protected substring appears anywhere in $normalized, even when the verb
    # does NOT target the protected path (e.g. `grep .claude/settings docs.md | tee
    # /tmp/notes.txt`). Verb-target binding would require shell-arg parsing per verb;
    # the conservative stance is paid for by the FP cost. Operators should reach for the
    # Read/Edit tools for legitimate access. ⊗ Do NOT narrow $protected_paths_re to "fix"
    # this — the FP cost is by design.
    protected_paths_re='(\.claude/settings|\.claude/hooks/|\.git/hooks/)'
    if [[ "$normalized" =~ $protected_paths_re ]]; then
      if [[ "$normalized" =~ ${verb_left_re}rm([[:space:]]|>|$) ]]; then block "hook-self-protection" "rm-against-protected"; fi
      if [[ "$normalized" =~ ${verb_left_re}mv([[:space:]]|>|$) ]]; then block "hook-self-protection" "mv-against-protected"; fi
      if [[ "$normalized" =~ ${verb_left_re}chmod([[:space:]]|>|$) ]]; then block "hook-self-protection" "chmod-against-protected"; fi
      if [[ "$normalized" =~ ${verb_left_re}tee([[:space:]]|>|$) ]]; then block "hook-self-protection" "tee-against-protected"; fi
      if [[ "$normalized" =~ ${verb_left_re}sed[[:space:]]+(-[a-zA-Z]*[iI]|--in-place) ]]; then block "hook-self-protection" "sed-i-against-protected"; fi
      if [[ "$normalized" =~ ${verb_left_re}echo[[:space:]] ]] && [[ "$normalized" =~ \> ]]; then block "hook-self-protection" "echo-redirect-against-protected"; fi
      if [[ "$normalized" =~ ${verb_left_re}cp([[:space:]]|>|$) ]]; then block "hook-self-protection" "cp-against-protected"; fi
      if [[ "$normalized" =~ ${verb_left_re}truncate([[:space:]]|>|$) ]]; then block "hook-self-protection" "truncate-against-protected"; fi
      if [[ "$normalized" =~ ${verb_left_re}dd([[:space:]]|>|$) ]]; then block "hook-self-protection" "dd-against-protected"; fi
      # D-37 — newly-covered verbs (install/ln/sponge) under unified match-name.
      if [[ "$normalized" =~ ${verb_left_re}(install|ln|sponge)([[:space:]]|>|$) ]]; then block "hook-self-protection" "mutation-verb-against-protected"; fi
      # D-37 / FIX-9 (PR #230) — catch ANY redirect into a protected path with an optional
      # path prefix (`/workspace/.../.claude/settings.json`, `./.claude/...`, etc.). The
      # `[^[:space:]\"\']*` arm absorbs any non-whitespace/non-quote bytes between the redirect
      # operator and the protected token. Defends against unknown future writers.
      if [[ "$normalized" =~ \>+[[:space:]]*[\"\']?[^[:space:]\"\']*(\.claude/settings|\.claude/hooks/|\.git/hooks/) ]]; then block "hook-self-protection" "redirect-against-protected"; fi
    fi
    # find -delete / find -exec rm against protected paths (regex — free-form find args).
    if [[ "$normalized" =~ ${verb_left_re}find[[:space:]].*(\.claude/settings|\.claude/hooks/?|\.git/hooks/?).*(-delete|-exec[[:space:]]+rm) ]]; then
      block "hook-self-protection" "find-delete-against-protected"
    fi
    # Task 7 — L1 install-boundary Bash mutation denial. Path-presence gate short-circuits non-L1.
    # D-37 (PR #230) — alternation widened with install/ln/sponge to mirror the protected-paths
    # block above. word-boundary semantics already match pipe-form via prior alternation.
    if [[ "$bash_command" =~ $l1_path_re || "$normalized" =~ $l1_path_re ]]; then
      if [[ "$normalized" =~ ${verb_left_re}(rm|mv|chmod|tee|cp|truncate|dd|install|ln|sponge)([[:space:]]|>|$) ]]; then
        block "install-boundary-protection" "mutation-verb-against-l1"
      fi
      if [[ "$normalized" =~ ${verb_left_re}sed[[:space:]]+-i ]]; then
        block "install-boundary-protection" "sed-i-against-l1"
      fi
      if [[ "$normalized" =~ ${verb_left_re}echo.*\> ]]; then
        block "install-boundary-protection" "echo-redirect-against-l1"
      fi
      if [[ "$normalized" =~ \>+[[:space:]]*[\"\']?[^[:space:]\"\']*packages/keel-invariants/src/ ]]; then
        block "install-boundary-protection" "redirect-against-l1"
      fi
      if [[ "$normalized" =~ ${verb_left_re}find[[:space:]].*-delete ]]; then
        block "install-boundary-protection" "find-delete-against-l1"
      fi
    fi ;;
esac

# D-13 — env|export|set word-boundary (regex replaces exact-match case). Catches `env`, `env `,
# `env | sort`, `env -0`, `export`, `export -p`, `set`, `set -o posix`. Avoids false-positives on
# `envsubst`, `envvar=x cmd`, `exportfs`, `setup.sh` (no word-boundary break after verb).
# D-12 — reader verb expansion (50 readers × 5 path classes + interp-stdin with -[ec]; FIX-13 added wc|nl|hexdump|tac|pv|column|jq|yq|tr|read|mapfile|curl|wget plus sub-agent C1/C2/C3 residuals (paste|cmp|comm|diff|fmt|fold|expand|unexpand|pr|rev|md5sum|sha256sum|sha1sum|b3sum|cksum|zcat|bzcat|xzcat|lzcat|zless|zgrep|bzgrep|xzgrep); dotsource_re covers source/. with C4 builtin|command|exec wrapper-strip).
# D-28 — tilde-form (~/.claude, ~/.config/gh, ~/.ssh) + /home/dev/.ssh parallel patterns; hook sees
# pre-expansion text, so tilde-form is an active bypass surface in agent paths.
# D-31 — /proc surface narrow: /proc/PID/(cmdline|environ|mem|status|auxv|maps), /proc/self/*,
# /proc/k{core,mem,allsyms}. Regex form replaces the prior /proc/*/environ-only case-glob chain.
case "$tool_name" in
  Bash)
    if [[ "$normalized" =~ ${subshell_left_re}(env|export|set)([[:space:]]|\`|$) ]]; then
      block "secret-access-denylist" "env-dump-bare"
    fi
    # D-31 — /proc reader detection via regex (word-boundary verb + expanded secret-bearing paths).
    # Replaces prior 19-alternative `cat*/proc/*/environ*|...` case-glob; far more maintainable.
    reader_verb_re="${verb_left_re}(cat|less|tail|head|bat|xxd|od|strings|more|grep|awk|sed|cp|dd|wc|nl|hexdump|tac|pv|column|jq|yq|tr|read|mapfile|curl|wget|paste|cmp|comm|diff|fmt|fold|expand|unexpand|pr|rev|md5sum|sha256sum|sha1sum|b3sum|cksum|zcat|bzcat|xzcat|lzcat|zless|zgrep|bzgrep|xzgrep)[[:space:]]"
    # WONTFIX (PR #230 R3-H48) - verb-trailing `[[:space:]]` class accepts
    # whitespace only; no-space verb-trailing forms (`cat<.env`, `cat>.env`,
    # `cat;.env`) bypass the gate. Do NOT loosen the trailing class to
    # admit `<` / `>` / `;` / `|` without a quote/heredoc-aware pre-pass:
    # would FP on `cat<<HEREDOC`, `cat<<EOF`, and similar legitimate forms.
    # Operators reaching for no-space-trailing readers against secret paths
    # is itself a workflow-anti-pattern (the Read tool exists for this);
    # accepted-residual class.
    # D-38 (PR #230 review-fix-arc, FIX-1) — flag-class widened to alphanumeric so digit
    # chars in interpreter flags (e.g. `perl -0ne …`) participate in verb-match. Prior
    # `[a-zA-Z]*[ec]` rejected `0` and let `perl -0ne … .env` slip past the gate.
    interp_verb_re="${verb_left_re}(node|python|python3|perl|ruby|php)[[:space:]]+-[a-zA-Z0-9]*[ec]"
    # WONTFIX (PR #230 R3-H49) - static-vs-dynamic analysis limit. The hook
    # regex-matches the raw command string; it does NOT shell-evaluate sub-
    # expressions before matching. Constructs concealing a reader-verb
    # behind a runtime decode (`bash -c "$(echo Y2F0IC5lbnY= | base64 -d)"`,
    # `eval "$(...)"`) evade detection because the post-decode `cat .env`
    # exists only after bash spawns a child shell. Adding runtime evaluation
    # would require a sandboxed shell evaluator (out of scope for a regex-
    # based gate); the egress firewall (Story 2.3) + OAuth named-volume
    # isolation (Stories 2.8 / 2.9) are the load-bearing layers against
    # this class. Accepted-residual class. Do NOT add runtime analysis.
    # FIX-13 (PR #230 review-fix-arc, R3-Hook-B) — dot-sourcing detection. `source <file>`
    # and `. <file>` shell-EVALUATE the file contents (more dangerous than reader-verb leak:
    # env vars from a sourced secret leak into every subsequent command). Literal `.` form
    # uses the stricter subshell_left_re boundary (no whitespace-only left context) to avoid
    # FP on `find . -name .env` / `cd ./foo` legitimate-period-arg cases. WONTFIX (string-
    # literal FP class, sibling of D2/D3): `echo "source .env"` blocks if `.env` follows;
    # same residual class — operators should reach for the Read tool. ⊗ Do NOT add a quote-
    # stripping pre-pass.
    dotsource_re="(${verb_left_re}source[[:space:]]|${subshell_left_re}\.[[:space:]])"
    proc_secret_re='/proc/([0-9]+|self)/(cmdline|environ|mem|status|auxv|maps|stack|syscall|io)|/proc/(kcore|kmem|kallsyms)'
    if [[ "$normalized" =~ $reader_verb_re || "$normalized" =~ $interp_verb_re || "$normalized" =~ $dotsource_re ]]; then
      if [[ "$normalized" =~ $proc_secret_re ]]; then
        block "secret-access-denylist" "cat-proc-environ"
      fi
    fi
    # D-38 (PR #230 review-fix-arc, FIX-1) — token-form bash-regex replaces anchored
    # case-globs to close 7 verified bypass classes documented in the PR-review summary:
    # quoted (`cat ".env"`), chained (`cat .env && true`), trailing-ws (`cat .env `),
    # interpreter string-literal (`python3 -c '..."." env...'`, `node -e '..."." env...'`),
    # quoted-with-leading-arg (`awk '{print}' ".env"`), ANSI-C-wrapper-residual
    # (`bash -c $'cat .env'` — D-37 wrapper-strip preserved upstream + regression-tested).
    #
    # Token-boundary character class: start | whitespace | `"` | `'` | `(` | `)` | `/`
    # | `|` | `&` | `;` | `<` | `>` | `:` | `=` | `\` | end-of-string. Boundaries on BOTH
    # sides for `.env` (right boundary required to avoid `.env_template` false-positive).
    # `\` is included so backslash-escaped quote sequences inside string literals
    # (`perl -0ne "...\".env\"..."`) treat the surrounding `\` as a token boundary.
    # `.envrc` / `.secrets` / oauth-dir / ssh-dir keep left-boundary only (preserves prior
    # trailing-`*` permissive semantics — they already tolerated quote/pipe trailing).
    secret_left_re='(^|[[:space:]"'\''`$(/|&;<>:=\])'
    secret_right_re='([[:space:]"'\''()|&;<>:=`$\]|$)'
    # WONTFIX (PR #230 D2) — quoted-literal FP: `echo "docs mention printenv"` blocks
    # because the regex sees the raw command string without parsing shell quoting. A
    # quote-stripping pre-pass (`sed -E 's/"[^"]*"//g'`) re-introduces the leading-
    # `printenv` bypass via embedded-quote ambiguity in nested forms. Operators should
    # use the Read tool to consult documentation rather than echoing literal `printenv`
    # strings. ⊗ Do NOT add quote-stripping.
    # printenv idiom — token-boundary on both sides (closes pipe-form `cmd | printenv`).
    printenv_re='(^|[^A-Za-z0-9_/.-])printenv([^A-Za-z0-9_/.-]|$)'
    if [[ "$normalized" =~ $printenv_re ]]; then
      block "secret-access-denylist" "printenv-idiom"
    fi
    # Verb gate — reader-verb OR interp-stdin must be present. printenv handled above
    # because it is its own verb (no separate target file).
    if [[ "$normalized" =~ $reader_verb_re || "$normalized" =~ $interp_verb_re || "$normalized" =~ $dotsource_re ]]; then
      oauth_dir_re="${secret_left_re}(/home/dev/\.claude/|/home/dev/\.config/gh/|~/\.claude/|~/\.config/gh/)"
      ssh_dir_re="${secret_left_re}(/home/dev/\.ssh/|~/\.ssh/)"
      # WONTFIX (PR #230 D3) — interpreter string-literal FP: `python3 -c 'print(".env")'`
      # blocks because any `.env` token under an interp verb fires the gate. Allow-listing
      # read-API call sites (open / readFileSync / read_text / require / dynamic forms) is
      # bypass-prone — `__import__('builtins').open`, `eval('o' + 'pen')`, `getattr(io,
      # 'open')` trivially defeat any allowlist. Conservative stance preserved by design;
      # operators should use the Read tool for actual reads. ⊗ Do NOT add a read-API allowlist.
      env_file_re="${secret_left_re}\.env(\.[A-Za-z0-9_.-]*)?${secret_right_re}"
      envrc_file_re="${secret_left_re}\.envrc"
      secrets_file_re="${secret_left_re}\.secrets"
      if [[ "$normalized" =~ $oauth_dir_re ]]; then block "secret-access-denylist" "cat-oauth-token"; fi
      if [[ "$normalized" =~ $ssh_dir_re ]]; then block "secret-access-denylist" "cat-ssh-key"; fi
      if [[ "$normalized" =~ $envrc_file_re ]]; then block "secret-access-denylist" "cat-envrc-file"; fi
      if [[ "$normalized" =~ $secrets_file_re ]]; then block "secret-access-denylist" "cat-secrets-file"; fi
      if [[ "$normalized" =~ $env_file_re ]]; then block "secret-access-denylist" "cat-env-file"; fi
      # FIX-2 (PR #230 review-fix-arc) — Bash-arm symlink-deref. Mirror D-22 Read-arm
      # `readlink -f` resolution per token. Closes `cat /tmp/symlink-to-/home/dev/.claude/x`
      # bypass: literal-text case-globs above only see the symlink path; per-token resolve
      # exposes the secret-bearing target. Verb-gated (already inside `reader_verb_re ||
      # interp_verb_re` arm) so non-reader commands skip the readlink cost. `[ -L ]`
      # per-token gate keeps cost bounded to actual symlinks (typical command has 0 hits).
      read -ra _fix2_tokens <<< "$normalized"
      for _fix2_tok in "${_fix2_tokens[@]}"; do
        _fix2_tok="${_fix2_tok#\"}"; _fix2_tok="${_fix2_tok%\"}"
        _fix2_tok="${_fix2_tok#\'}"; _fix2_tok="${_fix2_tok%\'}"
        [ -z "$_fix2_tok" ] && continue
        case "$_fix2_tok" in -*) continue ;; esac
        [ -L "$_fix2_tok" ] || continue
        _fix2_resolved="$(readlink -f "$_fix2_tok" 2>/dev/null || printf '')"
        case "$_fix2_resolved" in
          /home/dev/.claude/*|/home/dev/.config/gh/*) block "secret-access-denylist" "bash-resolved-to-oauth-token" ;;
          /home/dev/.ssh/*) block "secret-access-denylist" "bash-resolved-to-ssh-key" ;;
          /proc/*/environ|/proc/*/cmdline|/proc/*/mem|/proc/*/status|/proc/*/auxv|/proc/*/maps|/proc/self/*|/proc/kcore|/proc/kmem|/proc/kallsyms)
            block "secret-access-denylist" "bash-resolved-to-proc-environ" ;;
        esac
        case "$_fix2_resolved" in
          *.env|*.env.*|*/.env|*/.env.*) block "secret-access-denylist" "bash-resolved-to-env-file" ;;
          *.envrc|*.envrc.*|*/.envrc|*/.envrc.*) block "secret-access-denylist" "bash-resolved-to-envrc-file" ;;
          *.secrets|*.secrets.*|*/.secrets|*/.secrets.*) block "secret-access-denylist" "bash-resolved-to-secrets-file" ;;
        esac
      done
    fi ;;
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
