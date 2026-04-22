# Story 2.4: Whitelist source-of-truth + `pnpm devbox:whitelist` atomic-reload CLI

Status: traced

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want a repo-tracked whitelist source-of-truth (`packages/devbox/whitelist.default.txt` + per-category fragments + per-fork override) plus a `pnpm devbox:whitelist sync` CLI that reloads atomically under file-lock,
so that egress policy changes are reviewable in git and applied without container restart (FR1a).

## Acceptance Criteria

1. **Given** `packages/devbox/`,
   **When** I read the whitelist layout,
   **Then** `whitelist.default.txt` holds the substrate baseline
   **And** per-category fragments (e.g., `whitelist.github.txt`, `whitelist.npm.txt`, `whitelist.anthropic.txt`) compose into the final policy
   **And** a per-fork override file (gitignored path documented in `AGENTS.md`) can add fork-specific domains.

2. **Given** `pnpm devbox:whitelist sync`,
   **When** I run it,
   **Then** the CLI reads the composed whitelist, validates domain syntax, acquires a file-lock, and reloads dnsmasq + nftables atomically (reusing Story 2.3's mechanism)
   **And** the CLI exits zero on successful reload with a diff summary (domains added/removed).

3. **Given** a syntax-invalid entry in any whitelist file,
   **When** the CLI runs,
   **Then** it exits non-zero with a line/file pointer
   **And** the previous policy remains active (fail-closed).

4. **Given** concurrent sync attempts,
   **When** two `pnpm devbox:whitelist sync` commands run simultaneously,
   **Then** the file-lock serialises them
   **And** no partial policy state is ever active.

5. **Given** the whitelist is tracked in git,
   **When** a PR edits any whitelist file,
   **Then** the commit is subject to standard prek gates (Story 1.4/1.5)
   **And** reviewers see exactly which domains were added/removed.

### Scope clarifications (pinned at draft, MUST be honored — not re-negotiable without Change Log entry)

- **SC-1 (CLI subcommand surface, AC 2/5):** `whitelist.sh` ships exactly four subcommands — `sync`, `add <domain>`, `remove <domain>`, `list`. This matches architecture tree l.1002 `# add/remove/list/sync (single tool, FR1a)` and PRD §CLI-Tool Surface l.493 (`pnpm devbox:whitelist <add|remove|list|sync> [domain]`). No args / unknown subcommand prints usage to stderr and exits 2. Architecture decided `add/remove` are operator-editing conveniences for the per-fork override file (SC-3), NOT substrate-mutating operations — they cannot edit `whitelist.default.txt` or `whitelist/*.txt` (substrate baseline + category fragments are source-level PR territory per FR44 AMEND path; edits there go through prek gates at commit time per AC 5, not runtime CLI).
- **SC-2 (per-fork override file path, AC 1):** `packages/devbox/whitelist.local.txt`. Chosen to mirror the Story 2.2 `.envrc.local` / `.envrc` per-fork precedent (committed `.envrc.example` template, gitignored `.envrc.local` per-fork mutation surface) at the kebab-`.local.txt` suffix. DO NOT use `whitelist.fork.txt` (stale earlier proposal; drifts from the Story 2.2 `.local` naming anchor), `whitelist.override.txt`, or `packages/devbox/whitelist/local.txt` (path-under-fragments-dir would collide with the sort-order-driven composition of category fragments). In-container absolute path via existing workspace bind-mount: `/workspace/packages/devbox/whitelist.local.txt`.
- **SC-3 (per-fork override gitignore, AC 1):** add `packages/devbox/whitelist.local.txt` to the `# Environment / secrets` block of the repo-root `.gitignore` AT THE END of that block (after all pre-existing entries — `.secrets`, `!packages/devbox/.secrets.example`, `.envrc.example`, `*.pem`, `*.key` at 2026-04-21 HEAD — and before the blank separator to the next `# Dependencies` block; block-end placement avoids off-by-one ambiguity and keeps the `.secrets` family contiguous per iter-173 SM review). Emit both the positive ignore (`packages/devbox/whitelist.local.txt`) **and** an explanatory inline comment (e.g., `# Story 2.4 per-fork whitelist override; operator-editable via whitelist.sh add/remove; NEVER committed.`). DO NOT add a `!packages/devbox/whitelist.local.example` bang — there is no committed `.example` template for the whitelist override (substrate baseline already lives in `whitelist.default.txt` + category fragments; Story 2.2 iter-151 AR-2 precedent says allow-list sentences should NOT list `.example` companions unless one actually exists, to avoid the asymmetry bug).
- **SC-4 (composition order extension of Story 2.3's `start-egress.sh`, AC 1):** Story 2.3 iter-157+ `start-egress.sh:66-99` composes `whitelist.default.txt` + `whitelist/*.txt` (sort-order fragments) via a `compose_whitelist()` function using `find | mapfile`. Story 2.4 extends `compose_whitelist()` with a THIRD stage: after the fragments loop, append `whitelist.local.txt` IF present and readable. Precedence: **append-only, additive** — the per-fork override cannot remove substrate domains (domains already in baseline or fragments remain; the override adds on top, and the final `sort -u` dedupes). This satisfies the SC-3 "fork override cannot override fail-closed default" narrow scope at the composition layer (fail-closed is enforced by the dnsmasq default `address=/#/` directive + nftables default-drop; composition is strictly additive). SC-4 MUST NOT introduce a composition-order change that would let forks SHRINK the allow-list at runtime (that is an AMEND path per FR44).
- **SC-5 (domain-syntax validation regex, AC 3):** strict LDH (letter-digit-hyphen) domain regex — `^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$` applied per line after comment + blank stripping. Additional bounds: total length ≤ 253 chars (RFC 1035). Rejects: underscores, leading/trailing hyphens, empty labels, slashes, whitespace-embedded names, zero-width Unicode. Passes: standard RFC-compliant public hostnames (`registry.npmjs.org`, `api.github.com`, `sub.example.co.uk`). Rationale: closes Story 2.3 CR defer D2 (iter-171 § Review Findings); a malformed entry would inject arbitrary text into the rendered `server=/<domain>/<upstream>` dnsmasq directive or `ip daddr <ip> accept` nftables rule, potentially fail-opening. IDN (internationalised domain) support is deferred to post-1.0 — 1.0 operators pre-punycode-encode IDN entries (operator contract documented in README). **Known limitations (scope-pinned at 1.0; deferred to post-1.0 refinement):** (a) RFC 3696 §2 all-numeric TLD prohibition (e.g., `example.123`) is NOT enforced — the LDH regex treats TLDs syntactically identical to other labels; failure mode is benign (dnsmasq simply fails to resolve; fail-closed); adding RFC-3696 enforcement requires a secondary label-class check and is out of scope for the 1.0 "strict LDH" contract. (b) Trailing-dot FQDN notation (e.g., `api.github.com.`) is rejected by the regex (the final `\.` would require another label); operators MUST use bare-name form. (c) Impact: both (a) and (b) are operator-ergonomics issues, not security-critical — the fail-closed posture means any mis-parsed entry is ignored rather than matched, so the injection-prevention property is preserved.
- **SC-6 (validation failure contract, AC 3):** on syntax-validation failure, `whitelist.sh` exits 2 with stderr `<file>:<lineno>: invalid domain syntax: '<offending-line>'` (file path relative to `packages/devbox/` when inside `packages/devbox/`; line number is 1-indexed inside the offending file, NOT in the composed stream). Previous policy remains active — `whitelist.sh` MUST NOT invoke `reload-egress.sh` on validation failure; no mutation of `/etc/dnsmasq.conf` or nftables ruleset occurs. This is the AC 3 fail-closed contract: syntactic errors keep the old policy, never the new one. Multiple syntax errors collected in a single pass (each emitted as its own stderr line) before exiting 2 — operator sees the full list, not just the first failure.
- **SC-7 (diff summary format, AC 2):** after a successful sync, `whitelist.sh sync` emits the diff to **stdout** (operator-readable) as:

  ```
  whitelist sync: <N> domains active
  +added.example.com
  -removed.example.com
   …
  (0 added, 0 removed)    # when no changes
  ```

  Domains grouped: `+` additions, then `-` removals, each sorted alphabetically. Trailing paren line reports counts. If no changes, only the header + `(0 added, 0 removed)` parenthetical are emitted (still exit 0 — idempotent). Diff is computed by comparing the **previous composed whitelist** (read from a persistent snapshot at `/run/keel-whitelist.previous.txt`, written at the end of each successful sync) against the newly composed whitelist BEFORE applying. On the first-ever sync (no previous snapshot), every domain is a `+` addition. DO NOT emit the diff to stderr (operators read stdout; stderr is reserved for errors + diagnostics per POSIX convention).
- **SC-8 (mutation file-lock, AC 4 + concurrent add/remove):** Story 2.3's `reload-egress.sh` already serialises **reload** ordering via `flock -x /run/keel-egress.lock` (SC-5 of Story 2.3). Story 2.4 adds a SECOND lock `flock -x /run/keel-whitelist-mutate.lock` held during the `add`/`remove` subcommand's **mutation phase** (read → edit → write of `whitelist.local.txt`) to prevent torn writes from concurrent `add foo.com` + `remove bar.com`. The mutation lock is released BEFORE invoking `reload-egress.sh` so the reload lock acquires cleanly without nested-lock deadlock risk. The `sync` subcommand acquires NO mutation lock (pure read of composed whitelist + passthrough to reload-egress.sh, which holds its own lock). Lock timeout: 10s (matches Story 2.3 reload-lock timeout; exits 4 with actionable stderr on timeout).
- **SC-9 (atomic-mutation discipline for `whitelist.local.txt` writes):** `add` / `remove` subcommands write to a tempfile adjacent to the target (`whitelist.local.txt.tmp.$$` — PID suffix for concurrent-safety within the flock-guarded region), then `mv` onto the target for atomic replacement. DO NOT edit in place (a SIGTERM mid-write would leave a half-written file that the next sync misparses). If the target does not yet exist on `add`, the tempfile is the full new content and `mv` creates it; on `remove` with a non-existent target, the subcommand is a no-op success (nothing to remove; exit 0 with a warning to stderr). The tempfile + cleanup is trap-registered on EXIT so crashes don't leave `.tmp.$$` debris.
- **SC-10 (list-subcommand source attribution, architecture l.1002):** `whitelist.sh list` prints the CURRENT composed whitelist (baseline + fragments + override, deduped + sorted) with a prefix column indicating source: `D` = default (`whitelist.default.txt`), `F:<name>` = fragment (`whitelist/<name>.txt` without the `.txt`), `L` = per-fork override (`whitelist.local.txt`). Format: `<prefix>  <domain>` (two-space separator). Output sorted alphabetically by domain (source prefix follows). Example:

  ```
  F:anthropic  api.anthropic.com
  F:github     api.github.com
  L            extra.myfork.com
  F:npm        registry.npmjs.org
  ```

  When the same domain appears in multiple sources (e.g., fragment + override), `list` emits one line showing the FIRST-encountered source in composition order (default → fragments-sorted → override), matching the `sort -u` dedup semantics of the compose function. Source attribution is advisory (operator-readable); runtime enforcement is indifferent to source.
- **SC-11 (exit-code contract):** exit 0 = success; exit 2 = usage error / validation failure (AC 3); exit 3 = whitelist file unreadable (default / fragment / override); exit 4 = mutation flock unavailable within 10s (AC 4); exit 5–7 = propagated from `reload-egress.sh` (5 nftables apply failed, 6 render / marker-validation failure, 7 dnsmasq SIGHUP failed). Mirrors Story 2.3 `reload-egress.sh` exit codes 2–7 so callers (future host-side wrapper / operator-shell) get uniform semantics across the egress CLI family.
- **SC-12 (package.json `pnpm devbox:whitelist` wiring, AC 2):** add a single script entry to `packages/devbox/package.json` `scripts` block: `"devbox:whitelist": "./scripts/whitelist.sh"`. This is the IN-CONTAINER invocation path (`packages/devbox/` is bind-mounted at `/workspace/packages/devbox/`; the devbox container runs `pnpm` commands at `/workspace/packages/devbox/`). The host-side `pnpm devbox:whitelist` convenience wrapper that `docker exec`s into the container belongs to Story 2.6 (`Host-side pnpm devbox:* CLI surface`) — Story 2.4 ships the container-resident bridge; Story 2.6 ships the host-side shim. At Story 2.4 landing, operators invoke via `docker exec keel-devbox pnpm --filter @keel/devbox devbox:whitelist <subcommand>` OR `docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh <subcommand>`. DO NOT add a root-level `pnpm devbox:whitelist` alias in the repo-root `package.json` (that is Story 2.6's scope for the full `devbox:*` surface).
- **SC-13 (scripts output-location + shape):** new file `packages/devbox/scripts/whitelist.sh` — kebab-case, `.sh` suffix, `0755` perm, `#!/usr/bin/env bash`, `set -euo pipefail`. Matches Story 2.1's `benchmark.sh` + Story 2.3's `reload-egress.sh` / `start-egress.sh` / `egress-log-tailer.sh` / `monitor.sh` shape. Use `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` for self-rooted path resolution (matches reload-egress.sh:36). Parent-directory references use `${SCRIPT_DIR}/..` (NOT absolute `/workspace/packages/devbox/`) so the script remains relocation-safe inside the container.
- **SC-14 (start-egress.sh extension discipline):** Story 2.4 edits `packages/devbox/scripts/start-egress.sh`'s `compose_whitelist()` function (lines 66–99 at 2026-04-21 HEAD) to append the `whitelist.local.txt` file IF present and readable AFTER the fragments loop. This is a ~5-line addition inside the existing `{ … }` block, matching the conditional pattern already used for the baseline (`if [[ -r "${WHITELIST_DEFAULT}" ]]`). DO NOT refactor the function, rename variables, or change sort-order semantics. Add a block-comment sentence pinning the additive-precedence contract (SC-4). `compose_whitelist()` remains responsible for the initial at-boot composition; `whitelist.sh` uses the IDENTICAL composition algorithm (SCs 4 + 5) for its own at-CLI-time compose operation — the two composers MUST produce byte-identical output for the same input files (verified by Task 7.5 smoke).
- **SC-15 (no new invariant manifest entry):** Story 2.4 is a **consumer** of Story 2.3's `INV-devbox-egress-contract` (manifest at `packages/keel-invariants/src/invariants.manifest.ts`; source doc `docs/invariants/devbox-egress.md`). Story 2.4 does NOT register a new `INV-*` entry and does NOT refresh `INV-devbox-egress-contract`'s `contentHash`. Rationale: the invariant's substrate-authoritative contract is fail-closed DNS + IPv4/IPv6 parity + atomic reload (three sub-contracts consolidated per Story 2.3 SC-10); Story 2.4 adds a user-facing CLI layer that CONSUMES the reload primitive, without altering any of the three sub-contracts. Per RALPH.md iter-156 manifest-schema lesson: add a manifest entry only when a story introduces a new substrate rule with its own `sourcePath` doc; consumer stories reference existing invariants from the CLI's documentation but do not bind new contentHashes. If Story 2.4 incidentally touches the `docs/invariants/devbox-egress.md` doc (e.g., to document the per-fork override composition), the existing `INV-devbox-egress-contract` contentHash MUST be refreshed via the Story 2.2 iter-153 protocol (Task 6.4) — but this is a pure doc-sync operation, not a new invariant.
- **SC-16 (in-container execution locus):** `whitelist.sh` runs **inside the devbox container** (the dnsmasq + nftables state it mutates lives inside the container). Operator invocation paths at Story 2.4 landing:
  1. `docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh <subcommand>` (canonical)
  2. `docker exec -w /workspace/packages/devbox keel-devbox pnpm devbox:whitelist <subcommand>` (via SC-12 script)
  Story 2.6 later wraps `docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh "$@"` behind a host-side `pnpm devbox:whitelist` alias at the repo root. DO NOT ship a host-side wrapper at Story 2.4 — wait for Story 2.6. Dev-agent MUST NOT invoke `docker exec` from `whitelist.sh` itself (already-inside-container; exec-recursion risk).
- **SC-17 (first-boot-safety inheritance):** `whitelist.sh sync` calls `reload-egress.sh <composed-whitelist-path>` which inherits Story 2.3 iter-162 AR-1's encapsulated bootstrap detour (`restore_resolv_pin()` + `resolver_bootstrap_active` guard + dnsmasq-liveness gate). No duplicate bootstrap logic in `whitelist.sh`. Validates the Story 2.3 iter-155 SC-8 architectural promise: "future callers inherit first-boot safety without duplicating detour logic." First downstream caller; confirms the primitive's contract holds. RALPH.md iter-171 lesson: domain-regex validation at the `whitelist.sh` boundary (SC-5) is Story 2.4's narrower scope-appropriate mitigation for CR defer D2 (reload-egress.sh itself does not gain regex validation; the CLI is the operator-editable entry point, reload-egress.sh is a trusted internal primitive).
- **SC-18 (previous-snapshot path for diff summary):** `/run/keel-whitelist.previous.txt` — persisted on tmpfs (container-writable, cleared on container restart; first-sync-after-restart shows every domain as `+` which is correct new-posture reporting). Alternative `/workspace/.keel/whitelist.previous.txt` rejected (pollutes bind-mount with transient state; operator sees a stray file in `git status`). Permission `0644`; owner root (pre-Story-2.5 runtime posture).
- **SC-19 (no scope creep — this story delivers EXACTLY the user-facing CLI):** Story 2.4 MUST NOT touch `reload-egress.sh` (Story 2.3's primitive), the dnsmasq / nftables templates, the JSONL tailer, the `INV-devbox-egress-contract` rule body, Dockerfile, `docker-compose.yml` (beyond what SC-14 requires for `start-egress.sh` extension), `user:` / `cap_drop:` (Story 2.5), or the host-side `pnpm devbox:*` CLI surface beyond SC-12's single `devbox:whitelist` entry (Story 2.6).

## Tasks / Subtasks

- [x] **Task 1 — `scripts/whitelist.sh` skeleton + subcommand dispatcher** (AC 2, SC-1, SC-11, SC-13)
  - [x] Subtask 1.1: create `packages/devbox/scripts/whitelist.sh` with standard header (`#!/usr/bin/env bash`, `set -euo pipefail`, banner comment referencing Story 2.4 + AC 2 + SC-1). Set `chmod 0755`.
  - [x] Subtask 1.2: declare constants — `SCRIPT_DIR` (self-rooted), `DEVBOX_DIR` (`${SCRIPT_DIR}/..`), `WHITELIST_DEFAULT` (`${DEVBOX_DIR}/whitelist.default.txt`), `WHITELIST_FRAGMENTS_DIR` (`${DEVBOX_DIR}/whitelist`), `WHITELIST_LOCAL` (`${DEVBOX_DIR}/whitelist.local.txt`), `COMPOSED_WHITELIST` (`/run/keel-whitelist.composed.txt` — reuse Story 2.3's path), `PREVIOUS_COMPOSED` (`/run/keel-whitelist.previous.txt`; SC-18), `MUTATE_LOCK` (`/run/keel-whitelist-mutate.lock`; SC-8), `RELOAD_SCRIPT` (`${SCRIPT_DIR}/reload-egress.sh`).
  - [x] Subtask 1.3: implement `usage()` function emitting a short help block to stderr (4 subcommand lines + exit codes summary) and `log()` helper mirroring Story 2.3's `printf 'whitelist: %s\n' "$*" >&2`.
  - [x] Subtask 1.4: main dispatcher — parse `$1` as subcommand; case block routing to `cmd_sync`, `cmd_add`, `cmd_remove`, `cmd_list`; default + empty case prints usage + exit 2. Each sub-case shifts remaining args and calls the corresponding function.

- [x] **Task 2 — Composition + validation primitives** (AC 1, AC 3, SC-4, SC-5, SC-6)
  - [x] Subtask 2.1: implement `compose_whitelist_into()` — takes destination path as arg; emits the composed (baseline → fragments sorted → `whitelist.local.txt` if present) + comment-stripped + blank-stripped + `sort -u` output into the destination. MUST produce byte-identical output to Story 2.3's `start-egress.sh:66-99` `compose_whitelist()` for the same input files (SC-14 dual-composer contract). Use `mapfile -t fragments < <(LC_ALL=C find "${WHITELIST_FRAGMENTS_DIR}" -maxdepth 1 -type f -name '*.txt' -print | sort)` — identical to start-egress.sh iter-170 pattern (whitespace-safe enumeration).
  - [x] Subtask 2.2: implement `validate_composed()` — takes a composed whitelist path as arg; iterates `whitelist.default.txt` + every `whitelist/*.txt` + `whitelist.local.txt` (if present); per-file per-line-after-strip, applies the LDH regex (SC-5) + 253-char total-length bound; on failure emits `<file>:<lineno>: invalid domain syntax: '<line>'` to stderr (SC-6). Uses `local -i error_count=0`; returns 0 if zero errors, 2 otherwise. Collect ALL errors before returning (operator sees the full list, not just the first).
  - [x] Subtask 2.3: implement `mkdir -p /run` idempotent pre-flight at function-call time (matches start-egress.sh:35 posture; `/run` may be empty or not-yet-writable on a fresh container init, though in practice `start-egress.sh` has already run by the time `whitelist.sh` is invoked — the idempotent mkdir is defensive belt-and-braces).

- [x] **Task 3 — `sync` subcommand** (AC 2, AC 4, SC-4, SC-7, SC-17)
  - [x] Subtask 3.1: `cmd_sync()` — no args; if args are passed, usage + exit 2.
  - [x] Subtask 3.2: compose to a tempfile (`mktemp /tmp/keel-whitelist-sync.XXXXXX`) via `compose_whitelist_into()`. Trap-register the tempfile for EXIT cleanup.
  - [x] Subtask 3.3: validate the source files via `validate_composed()`; on non-zero, exit 2 WITHOUT invoking `reload-egress.sh` (SC-6 fail-closed).
  - [x] Subtask 3.4: compute diff — if `${PREVIOUS_COMPOSED}` exists, run `diff --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format='' "${PREVIOUS_COMPOSED}" "${tempfile}"` into a variable; otherwise every line is a `+` addition (first-sync-after-boot case per SC-18). GNU `diff` emits changed lines in file-position order — for two already-sorted inputs this yields per-label-sorted but **interleaved** `+`/`-` lines. SC-7 format mandates `+` group first, then `-` group, each sorted alphabetically — so post-process the raw diff: extract additions (`grep '^+' | sort`) and removals (`grep '^-' | sort`) into two separate sorted lists. Count additions + removals (`wc -l` each after grouping).
  - [x] Subtask 3.5: move tempfile onto `${COMPOSED_WHITELIST}` (`mv`, atomic inode swap — tempfile is on the same filesystem via `/tmp` on tmpfs, so `mv` is rename(2)). If the move fails (cross-fs; shouldn't happen on standard devbox but defensive), fall back to `cp -f` + `rm`.
  - [x] Subtask 3.6: invoke `${RELOAD_SCRIPT} "${COMPOSED_WHITELIST}"` — propagate its exit code (SC-11 passthrough 5/6/7). On non-zero reload, DO NOT update `${PREVIOUS_COMPOSED}` (the policy didn't change; the next sync should diff against the still-previous state).
  - [x] Subtask 3.7: on reload success, `cp -f "${COMPOSED_WHITELIST}" "${PREVIOUS_COMPOSED}"` (+ `chmod 0644`). This establishes the snapshot for the next diff (SC-18).
  - [x] Subtask 3.8: emit the diff summary to stdout per SC-7 format — header line (`whitelist sync: <N> domains active`), then the sorted additions list from Subtask 3.4 (each prefixed `+`), then the sorted removals list (each prefixed `-`), then the trailing count line `(<A> added, <R> removed)`. If zero additions and zero removals, emit only the header + `(0 added, 0 removed)` parenthetical.
  - [x] Subtask 3.9: exit 0.

- [x] **Task 4 — `add` subcommand** (AC 2, AC 4, SC-1, SC-5, SC-8, SC-9)
  - [x] Subtask 4.1: `cmd_add()` — takes exactly one arg `<domain>`; usage + exit 2 if missing or extra.
  - [x] Subtask 4.2: validate the single `<domain>` against SC-5 regex + length bound BEFORE acquiring the mutation lock (fast-fail on obvious garbage without blocking other operators). On failure: stderr `invalid domain syntax: '<domain>'` + exit 2.
  - [x] Subtask 4.3: acquire mutation lock — `exec 201>"${MUTATE_LOCK}"; flock -x -w 10 201 || { log "ERROR: mutation lock unavailable within 10s"; exit 4; }` (fd 201 to avoid collision with reload-egress.sh's fd 200).
  - [x] Subtask 4.4: check idempotence — if `${WHITELIST_LOCAL}` exists AND `grep -Fxq "<domain>" "${WHITELIST_LOCAL}"`, log `domain '<domain>' already present in whitelist.local.txt; no-op` + release lock + invoke sync (to ensure runtime state matches — defensive) + exit 0.
  - [x] Subtask 4.5: atomic append — write tempfile next to target (`tempfile="${WHITELIST_LOCAL}.tmp.$$"`; trap-register for EXIT cleanup). Compose contents: existing content (if file exists) + `\n<domain>\n` (ensure trailing newline discipline). `cp -f "${tempfile}" "${WHITELIST_LOCAL}"` then `rm -f "${tempfile}"`. `chmod 0644 "${WHITELIST_LOCAL}"`.
  - [x] Subtask 4.6: release mutation lock (close fd 201 via `exec 201>&-`).
  - [x] Subtask 4.7: invoke `cmd_sync` to recompose + reload + emit diff (the `+<domain>` line surfaces to operator). Propagate sync's exit code.

- [x] **Task 5 — `remove` subcommand** (AC 2, AC 4, SC-1, SC-8, SC-9)
  - [x] Subtask 5.1: `cmd_remove()` — takes exactly one arg `<domain>`; usage + exit 2 if missing or extra.
  - [x] Subtask 5.2: validate the domain against SC-5 regex BEFORE acquiring lock (consistent with `add`; cheap fail-fast).
  - [x] Subtask 5.3: acquire mutation lock (identical to Subtask 4.3; fd 201).
  - [x] Subtask 5.4: check presence — if `${WHITELIST_LOCAL}` does NOT exist, log `whitelist.local.txt does not exist; nothing to remove` + release lock + exit 0 (no-op success per SC-9 non-existent-target semantics).
  - [x] Subtask 5.5: check substrate-source — if the domain appears in `whitelist.default.txt` or any `whitelist/*.txt` fragment, log `WARNING: '<domain>' is a substrate baseline / category-fragment domain; remove requires source-level PR (FR44 AMEND path). whitelist.local.txt override has no effect on substrate domains.` + release lock + exit 2 (operator-education; prevents surprise-nothing-happened). Matching uses the composition semantics (strip comments + blanks first) before `grep -Fxq` so that commented lines don't produce false positives and whitespace-padded entries still match: `grep -Fxq -- "${domain}" <(sed -E 's/#.*$//' "${substrate_files[@]}" | awk 'NF' )`. Iterate `substrate_files` = `whitelist.default.txt` + every `whitelist/*.txt` fragment.
  - [x] Subtask 5.6: if the domain is not in `${WHITELIST_LOCAL}`, log `domain '<domain>' not present in whitelist.local.txt; no-op` + release lock + exit 0 (idempotent remove).
  - [x] Subtask 5.7: atomic strip — write tempfile via `grep -Fxv "<domain>" "${WHITELIST_LOCAL}" > "${tempfile}"`; `mv "${tempfile}" "${WHITELIST_LOCAL}"`; `chmod 0644`. If the grep result is empty (only line was the removed domain), the file remains but empty — acceptable (subsequent syncs skip empty files per the strip-blanks composer).
  - [x] Subtask 5.8: release mutation lock.
  - [x] Subtask 5.9: invoke `cmd_sync` to recompose + reload + emit diff.

- [x] **Task 6 — `list` subcommand** (AC 1, SC-10)
  - [x] Subtask 6.1: `cmd_list()` — no args; usage + exit 2 if args passed.
  - [x] Subtask 6.2: no mutation lock needed (pure read).
  - [x] Subtask 6.3: build source-attribution map — iterate each source file in composition order (default, then each fragment sorted, then override if present); for each non-blank non-comment line in each file, record the source prefix for the first occurrence of that domain. Use an associative array: `declare -A source_of; for file in ...; do while read -r line; do [[ -n "${source_of[$line]+x}" ]] || source_of["$line"]="<prefix>"; done; done`.
  - [x] Subtask 6.4: emit sorted output — `for domain in $(printf '%s\n' "${!source_of[@]}" | LC_ALL=C sort); do printf '%s  %s\n' "${source_of[$domain]}" "${domain}"; done`. Two-space separator per SC-10.
  - [x] Subtask 6.5: exit 0.

- [x] **Task 7 — `start-egress.sh` extension + `whitelist.default.txt` baseline-doc refresh + dual-composer parity smoke** (AC 1, SC-4, SC-14)
  - [x] Subtask 7.1: edit `packages/devbox/scripts/start-egress.sh` `compose_whitelist()` function (existing at lines 66–99 as of 2026-04-21 HEAD) — inside the `{ … }` block, after the fragments `for fragment in "${fragments[@]}"` loop but before the closing `}`, add a conditional append block for `${DEVBOX_DIR}/whitelist.local.txt`:

    ```bash
    # Story 2.4 (SC-4): per-fork override composed last so fork-added domains
    # append additively to baseline + fragments. Override file is gitignored
    # (SC-3) — absent by default; present when operator has invoked
    # `whitelist.sh add <domain>` at least once in this container lifetime OR
    # has pre-placed the file via a fork-scaffolding step.
    if [[ -r "${DEVBOX_DIR}/whitelist.local.txt" ]]; then
      cat "${DEVBOX_DIR}/whitelist.local.txt"
    fi
    ```
  - [x] Subtask 7.2: update the banner comment at start-egress.sh:12–13 to append `+ whitelist.local.txt if present` to the composition-order description.
  - [x] Subtask 7.3: update `whitelist.default.txt` header comment block (lines 9–12 + 25–28 at HEAD) — replace the stale "Composition order" section to list the three stages explicitly (baseline → fragments → local-override); replace the "DO NOT add per-fork domains here — Story 2.4 introduces…" paragraph with a terse "Per-fork override lives at `whitelist.local.txt` (gitignored); edit via `pnpm devbox:whitelist add|remove <domain>` or hand-edit + `pnpm devbox:whitelist sync`." sentence. Content-length change triggers NO manifest refresh because `whitelist.default.txt` is not a `sourcePath` of any invariant (Story 2.3's `INV-devbox-egress-contract` sourcePath is `docs/invariants/devbox-egress.md`, not the whitelist file).
  - [x] Subtask 7.4: dual-composer parity smoke (in-iteration, no container needed) — write a small shell harness that invokes both `start-egress.sh`'s `compose_whitelist` and `whitelist.sh`'s `compose_whitelist_into` against the same inputs (with a fabricated `whitelist.local.txt` test fixture), `diff` the outputs, verify byte-identical. Document harness invocation in Debug Log References. This verifies SC-14's dual-composer contract statically.
  - [x] Subtask 7.5: NO manifest refresh needed — `start-egress.sh` is not a `sourcePath` in `invariants.manifest.ts` (confirmed by `grep -n start-egress.sh packages/keel-invariants/src/invariants.manifest.ts` returning zero matches at HEAD). If any future story registers start-egress.sh as a sourcePath, that registration triggers its own contentHash gate.

- [x] **Task 8 — `whitelist.local.txt` gitignore + AGENTS.md per-fork override doc** (AC 1, SC-2, SC-3)
  - [x] Subtask 8.1: edit `.gitignore` at repo root — inside the `# Environment / secrets` block, insert AT THE END of that block (i.e., after all pre-existing entries in the block — `.secrets`, `!packages/devbox/.secrets.example`, `.envrc.example`, `*.pem`, `*.key` at 2026-04-21 HEAD — and before the blank line that separates the block from the next `# Dependencies` block). Rationale: keeping the `.secrets` family (`.secrets` → bang → `.envrc.example`) visually contiguous and placing new entries at block-end avoids off-by-one ambiguity about "immediately after `!packages/devbox/.secrets.example`". Append:

    ```
    # Story 2.4 per-fork whitelist override — operator-editable via whitelist.sh add/remove; NEVER committed.
    packages/devbox/whitelist.local.txt
    ```

    NO bang-negation for `whitelist.local.example` (SC-3 rationale — no committed `.example` template; substrate baseline lives in `whitelist.default.txt` + category fragments which serve as the working references).
  - [x] Subtask 8.2: edit `AGENTS.md` — add a new H3 subsection under § Devbox iteration environment titled `### Per-fork whitelist override (Story 2.4)` documenting:
    - Path: `packages/devbox/whitelist.local.txt` (gitignored; SC-3).
    - Composition: appended last, additive-only (cannot remove substrate domains); final `sort -u` dedupes.
    - Mutation: `pnpm devbox:whitelist add <domain>` / `remove <domain>` edit the file atomically under a mutation lock; `sync` recomposes + reloads; `list` prints the composed state with source attribution.
    - AMEND path: substrate domains (baseline + fragments) are edited source-level per FR44 AMEND (PR + prek gates per AC 5).
    - Growth-tier note: `INVARIANTS.fork.md` fork-owned invariants (if the fork opts in per `docs/invariants/fork.md` § INVARIANTS.fork.md scaffold) MAY NOT relax the fail-closed default, IPv4/IPv6 parity, or atomic-reload semantics — the per-fork path is strictly additive.
  - [x] Subtask 8.3: update `packages/devbox/README.md` § Egress policy section (Story 2.3 authored at the § Egress policy (Story 2.3) H2) — add a new `### Per-fork whitelist override (Story 2.4)` subsection BELOW the existing § Verification + § Reload subsections, documenting the `whitelist.local.txt` path + the four CLI subcommands + the in-container invocation paths (SC-16). Include an example session:

    ```sh
    # Add a per-fork domain (auto-syncs)
    docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh add internal-registry.myfork.com

    # Inspect composed state with source attribution
    docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh list

    # Remove a per-fork domain (auto-syncs)
    docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh remove internal-registry.myfork.com

    # Recompose + reload without changes (e.g., after hand-editing whitelist.local.txt)
    docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh sync
    ```

    Note Story 2.6 later wraps these behind `pnpm devbox:whitelist <subcommand>` on the host.

- [x] **Task 9 — `packages/devbox/package.json` script wiring** (AC 2, SC-12)
  - [x] Subtask 9.1: edit `packages/devbox/package.json` `scripts` block — add one entry: `"devbox:whitelist": "./scripts/whitelist.sh"`. Preserve the existing `build` / `typecheck` / `lint` entries verbatim (do NOT reorder; add the new key after `lint`). JSON validity — trailing comma rules.
  - [x] Subtask 9.2: verify `pnpm --filter @keel/devbox run` lists `devbox:whitelist` (deferred to operator workstation per backend-B constraint; record in Debug Log References).

- [x] **Task 10 — Live smokes (positive + negative + concurrent + validation)** (AC 2–5)
  - [x] Subtask 10.1: sync-on-empty-override smoke (AC 2) — with no `whitelist.local.txt`, run `whitelist.sh sync`; verify exit 0 + diff summary shows only baseline + fragment domains (all as `+` on first-ever sync, or `0 added, 0 removed` on repeat sync); verify `/run/keel-whitelist.previous.txt` is written. Record in Debug Log References.
  - [x] Subtask 10.2: add-new-domain smoke (AC 2, AC 5) — `whitelist.sh add test-domain.example`; verify exit 0 + diff summary includes `+test-domain.example`; verify `whitelist.local.txt` now contains the domain (cat + grep); verify subsequent `whitelist.sh sync` shows `(0 added, 0 removed)` (idempotence); verify `git status` shows `whitelist.local.txt` as **untracked** (SC-3 gitignore). Record.
  - [x] Subtask 10.3: remove-domain smoke (AC 2) — `whitelist.sh remove test-domain.example`; verify exit 0 + diff summary includes `-test-domain.example`; verify `whitelist.local.txt` no longer contains the domain. Record.
  - [x] Subtask 10.4: list smoke (AC 1) — `whitelist.sh list`; verify output is sorted + shows source prefix for every domain; verify no duplicates. Record.
  - [x] Subtask 10.5: validation-failure smoke (AC 3) — temporarily append a malformed domain to `whitelist.local.txt` (e.g., `bad_domain_with_underscore.example`); `whitelist.sh sync`; verify exit 2 + stderr contains `whitelist.local.txt:<lineno>: invalid domain syntax: 'bad_domain_with_underscore.example'`; verify `reload-egress.sh` was NOT invoked (previous policy active); verify `nft list chain inet keel_egress output_v4` still shows pre-sync rules; clean up the malformed line after the smoke. Record.
  - [x] Subtask 10.6: substrate-source-protection smoke (SC-1 + SC-5) — `whitelist.sh remove registry.npmjs.org` (baseline fragment entry); verify exit 2 + stderr contains `WARNING: 'registry.npmjs.org' is a substrate baseline / category-fragment domain; remove requires source-level PR`. Record.
  - [x] Subtask 10.7: concurrent-sync smoke (AC 4) — spawn two `whitelist.sh sync` invocations in background from the same shell (`&`), wait for both; verify both exit 0 (reload-egress.sh's flock serialises them cleanly); verify final composed whitelist matches expectation. Record.
  - [x] Subtask 10.8: file-not-readable smoke (SC-11 exit 3) — temporarily `chmod 000 whitelist.local.txt`; `whitelist.sh sync`; verify exit 3 + stderr explicit about the unreadable path; restore `chmod 0644` after the smoke. Record.
  - [x] Subtask 10.9: dual-composer parity smoke (SC-14) — Task 7.4 harness; verify `start-egress.sh`'s compose output is byte-identical to `whitelist.sh`'s `compose_whitelist_into` output. This smoke runs in the iteration env via `bash` against the scripts (no container needed — the composers don't touch runtime state). Record.
  - [x] Subtask 10.10: backend-safety note — smokes 10.1–10.8 require a running devbox container (invoke via `docker exec`); smokes 10.9 runs in iteration env. Per Story 2.3 Task 12.8 precedent, smokes 10.1–10.8 are **deferred to operator workstation** if the iteration env cannot start the container (backend B bind-mount denial per Story 2.1 iter-127). Document deferral in Debug Log References at dev-story closure.

- [x] **Task 11 — Change Log + sprint-status flip** (lifecycle hygiene)
  - [x] Subtask 11.1 *(completed iter-172 draft)*: v1.0 Change Log entry recorded in this file (draft summary, Status transition `backlog → ready-for-dev`, sprint-status row + timestamp).
  - [x] Subtask 11.2 *(completed iter-172 draft)*: `sprint-status.yaml` row `2-4-whitelist-source-of-truth-…` was flipped `backlog → ready-for-dev` at draft time.
  - [x] Subtask 11.3 *(completed iter-172 draft)*: `# last_updated: 2026-04-22 Story-2-4-ready-for-dev UTC` comment line appended to sprint-status.yaml top at draft time.
  - [x] Subtask 11.4: dev-story appends a **v1.3** Change Log entry at landing (dev-story completion summary) — iter number, files touched, live-smoke deferral status (10.1–10.8 defer to operator workstation per backend-B). Subsequent lifecycle entries v1.4 (post-dev SM) and v1.5+ (CR cycle) land at their own gates.
  - [x] Subtask 11.5: ensure no scope creep (SC-19) — this story delivers EXACTLY `whitelist.sh` CLI + `start-egress.sh` 5-line extension + `package.json` one-line script wiring + `.gitignore` + `AGENTS.md` + `README.md` doc updates + `whitelist.default.txt` header-comment refresh. Stories 2.5 (hardening), 2.6 (host-side pnpm wrappers), 2.13 (healthcheck) remain in `backlog` until their turn.

## Dev Notes

### Architecture pin — Story 2.4's slot in the egress mechanism family (non-negotiable)

Architecture § S5 (architecture.md:224) pinned **dual-layer atomic reload via `pnpm devbox:whitelist sync`** as the operator interface; Story 2.3 landed the in-container `reload-egress.sh` primitive; Story 2.4 ships the user-facing CLI on top of it. Architecture § Devbox Package Tree (architecture.md:1002) pins the file path: `packages/devbox/scripts/whitelist.sh # add/remove/list/sync (single tool, FR1a)`. The `# add/remove/list/sync` inline comment fixes the four-subcommand surface (SC-1). PRD § CLI-Tool Surface (prd.md:493) pins the host-side invocation shape `pnpm devbox:whitelist <add|remove|list|sync> [domain]`. Story 2.4 wires the in-container half (SC-12); Story 2.6 wires the host-side half.

### File layout (pinned by `architecture.md` lines 975–1004; extended by this story)

```
packages/devbox/
├── Dockerfile                     # Story 2.1 — untouched
├── docker-compose.yml             # Story 2.1 + 2.2 + 2.3 — untouched
├── entrypoint.sh                  # Story 2.1 + 2.3 — untouched
├── .envrc.example                 # Story 2.2 + 2.3 — untouched
├── README.md                      # Story 2.1 + 2.3 — extended by Task 8.3
├── VERSIONS.md                    # Story 2.1 + 2.3 — untouched
├── package.json                   # Story 2.1 — extended by Task 9 (one `scripts` entry)
├── whitelist.default.txt          # Story 2.3 — header comment refreshed by Task 7.3
├── whitelist.local.txt            # NEW (gitignored; created on first `whitelist.sh add`)
├── whitelist/                     # Story 2.3 — untouched
│   ├── npm.txt
│   ├── anthropic.txt
│   └── github.txt
├── nftables/                      # Story 2.3 — untouched
│   └── egress.nft
├── dnsmasq/                       # Story 2.3 — untouched
│   └── dnsmasq.conf
└── scripts/
    ├── benchmark.sh               # Story 2.1 — untouched
    ├── start-egress.sh            # Story 2.3 — extended by Task 7 (5-line addition)
    ├── reload-egress.sh           # Story 2.3 — untouched (consumed by whitelist.sh sync)
    ├── egress-log-tailer.sh       # Story 2.3 — untouched
    ├── monitor.sh                 # Story 2.3 — untouched
    └── whitelist.sh               # NEW (Task 1–6) — user-facing CLI
```

Other repo-level touches:
- `.gitignore` — one new entry + comment (Task 8.1)
- `AGENTS.md` — new § Per-fork whitelist override subsection (Task 8.2)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — row flip + timestamp (Task 11)

### Scope boundary — what Story 2.4 does NOT deliver

| Scope | Owner | Rationale |
|---|---|---|
| Modifications to `reload-egress.sh` (e.g., adding domain-regex validation inside the primitive) | Post-1.0 (optional) | SC-5 + SC-17: regex validation lives at the `whitelist.sh` boundary (the operator-editable entry point); reload-egress.sh is an already-trusted internal primitive. Story 2.3 iter-171 CR defer D2 is narrowly mitigated by Story 2.4 without touching the primitive. |
| New `INV-*` manifest entry or `INV-devbox-egress-contract` contentHash refresh | n/a (consumer story per SC-15) | Story 2.4 consumes Story 2.3's invariant without amending the three sub-contracts. Doc-referenced-only touches don't require a contentHash refresh unless the `sourcePath` doc itself is edited. |
| Host-side `pnpm devbox:whitelist` wrapper at repo root + full `pnpm devbox:*` CLI surface | Story 2.6 | Host-side lifecycle CLI is Story 2.6's entire scope (all `devbox:*` commands including the whitelist forwarder). Story 2.4 ships only the in-container `packages/devbox/package.json` script per SC-12. |
| `user: dev` non-root container user + `cap_drop: [ALL]` + `security_opt: [no-new-privileges:true]` | Story 2.5 | Hardening story; whitelist.sh at Story 2.4 runs as root (pre-2.5 runtime posture); Story 2.5 reworks to run as `dev` with `cap_add: NET_ADMIN + NET_RAW` preserved. |
| `pnpm devbox:monitor` JSONL tail CLI refinements (filter args, format flags) | Story 2.6 | Story 2.3 shipped minimal `monitor.sh`; operator filter + format flags belong to the uniform CLI surface. |
| IDN (internationalised domain name) Punycode support | Post-1.0 | SC-5 pins strict LDH regex at 1.0; operators pre-encode IDN entries (documented in README). Post-1.0 refinement if operator pushback emerges. |
| Fork-override removal semantics (shrink the allow-list below substrate) | FR44 AMEND path | SC-4 composition is additive-only; shrinking substrate requires a source-level PR against `whitelist.default.txt` / `whitelist/*.txt`. |

### Previous story intelligence — patterns Story 2.4 MUST reuse

**From Story 2.3 (landed iter-167, CR-closed iter-171):**
- `reload-egress.sh` takes ONE arg (`<composed-whitelist-path>`) and acquires `/run/keel-egress.lock` on fd 200 for 10s. Exit codes 2–7 are already pinned — Story 2.4 inherits them via passthrough (SC-11).
- `compose_whitelist()` in `start-egress.sh` is the reference algorithm: concatenate baseline + `mapfile`-enumerated fragments + strip comments/blanks + `sort -u`. Story 2.4's `compose_whitelist_into` MUST match it byte-for-byte for the same inputs (SC-14 dual-composer contract; Task 7.4 smoke verifies).
- Scripts shape: kebab-case `.sh`, `#!/usr/bin/env bash`, `set -euo pipefail`, `0755`, self-rooted `SCRIPT_DIR` (matches `reload-egress.sh:36` + `start-egress.sh:23`).
- Trap-register tempfiles on EXIT for crash-safety (reload-egress.sh pattern).
- Fail-closed discipline at every boundary — validation failures do NOT invoke the reload primitive (SC-6 + AC 3 verbatim).
- `mapfile -t arr < <(LC_ALL=C find ... -maxdepth 1 -type f -name '*.txt' -print | sort)` for whitespace-safe fragment enumeration (iter-170 AR-9 drain lesson).
- Backend-B iteration-env bind-mount denial — live smokes defer to operator workstation; record in Debug Log References.

**From Story 2.2 (landed iter-148, CR-closed iter-154):**
- `.envrc.local` gitignored + `.envrc.example` committed pattern — SC-2 mirrors this for `whitelist.local.txt` (no committed `.example` per SC-3 rationale: asymmetry bug avoidance).
- contentHash refresh protocol only when a `sourcePath` doc itself is edited; Story 2.4 does NOT trigger a refresh (SC-15).
- Story 2.2 CR iter-151 AR-2 taught: allow-list sentences in invariant docs must narrow to files with corresponding `.gitignore` bang-negations. Story 2.4 introduces `whitelist.local.txt` as gitignore-only-no-negation (SC-3 + Task 8.1) — matches the pattern because there is NO committed `.example` template to negate.
- Change Log versioning: v1.0 = initial draft, v1.1 = pre-dev SM fixes, v1.2 = ATDD (or skip), v1.3 = dev-story landing, v1.4 = post-dev SM, v1.5 = CR opener, v1.6+ = drain iterations, v1.N = CR re-run close.

**From Story 2.3 CR iter-171 defers (now first-downstream-caller mitigation):**
- CR defer D2 (domain-regex validation) → Story 2.4 SC-5 (regex at CLI boundary, not primitive boundary) — narrower scope-appropriate mitigation.
- CR defer D7 (no regression tests for shell scripts) — remains deferred; Story 2.4 inherits Epic 13 test-harness scope for unit-test coverage.
- CR defer D3 (SIGTERM-during-flock race) — remains deferred; `whitelist.sh`'s mutation-lock has the same ~24-line window before trap registration, low-likelihood race accepted (SC-19 scope-isolation: do not touch primitive hardening).

### CLI design philosophy — four subcommands, one responsibility each

- **`sync`**: recompose + validate + atomic-reload. No side effects on `whitelist.local.txt`. This is the primitive callers (CI hooks, external tooling) build upon.
- **`add <domain>`**: fork-operator-editable mutation of `whitelist.local.txt`; implicit `sync` at tail (operator-UX — "one command does the thing").
- **`remove <domain>`**: mirror of `add`; implicit `sync` at tail. Protects substrate domains via explicit operator-education error (SC-1).
- **`list`**: read-only observability; prints composed state with source attribution (SC-10) to help operators debug "why is domain X allowed/blocked".

Each subcommand is independently invocable; `add`/`remove` intentionally trigger `sync` so operators don't forget the two-step dance. Explicit-`sync`-only-callers can use `--no-sync` in post-1.0 if a use case emerges.

### Fail-closed discipline — AC 3 is the load-bearing contract

The CLI MUST satisfy three fail-closed invariants:

1. **Validation failure ⇒ previous policy active.** On any SC-5 regex failure (AC 3 Given clause), `reload-egress.sh` is NOT invoked. The current `/etc/dnsmasq.conf` + nftables ruleset stays in force. Operator sees exit 2 + stderr pointer. This is verified by smoke 10.5.
2. **Composition failure ⇒ previous policy active.** If a whitelist source file is unreadable (exit 3), no reload happens. Same fail-closed posture.
3. **Reload-egress.sh failure ⇒ previous policy active (propagated).** Reload-egress.sh's own kernel-atomic semantics ensure that nft-transaction failures roll back. Story 2.4's CLI simply propagates its exit code without additional recovery logic (SC-11 passthrough).

Fail-OPEN at any of these three points would be a security-critical defect (an attacker who can inject a malformed domain into any whitelist source could force a reload that exits before applying, but silently leaves a prior-state policy that was mutated by a concurrent writer — fortunately, Story 2.4's mutation-lock + atomic-replace discipline prevents mid-write reads).

### Runtime location — in-container (SC-16 rationale)

- The state being mutated (dnsmasq config, nftables ruleset) lives inside the container.
- The whitelist source files live in the repo bind-mounted at `/workspace/packages/devbox/` — readable from inside the container without copy.
- Running on the host would require either (a) shelling out to `docker exec` for every `nft -f` / `kill -HUP` call (pulls half the primitive into the host; fragile), or (b) maintaining a host-side copy of `reload-egress.sh`'s rendering logic (duplication; drift-risk).
- In-container execution keeps the whole CLI + primitive in one namespace. Host-side ergonomics are Story 2.6's scope (a thin `docker exec` forwarder).

### Previous-composed snapshot path — `/run/keel-whitelist.previous.txt` (SC-18 rationale)

- Must be container-writable (`/run` is tmpfs on the devbox container; `start-egress.sh:35` already `mkdir -p /run`).
- Must be transient (cleared on container restart; first-sync-after-restart shows every domain as `+` which is correct new-posture reporting — the previous-policy reference is the reboot).
- Must NOT pollute `/workspace` (bind-mount to host; operator sees a stray file in `git status` → noise).
- Alternative `/var/run/keel/…` rejected (adds a namespace without benefit; `/run` is the Linux-standard tmpfs for init-writable state).

### Dev-agent guardrails (MUST-follow list)

1. **Fail-closed everywhere.** Validation failures + file-read failures NEVER invoke `reload-egress.sh`. Previous policy stays active. AC 3 verbatim.
2. **Propagate reload-egress.sh exit codes.** Do not recover or mask exit codes 5/6/7; operator needs the underlying diagnosis (SC-11).
3. **No duplicate reload logic.** `whitelist.sh` MUST call `${SCRIPT_DIR}/reload-egress.sh` as an external process; do NOT inline `nft -f` / `kill -HUP` calls.
4. **Composition byte-identity.** `whitelist.sh`'s compose and `start-egress.sh`'s compose MUST produce identical output for the same inputs (SC-14). Task 7.4 smoke verifies; dev-agent MUST NOT diverge the algorithms.
5. **Atomic mutation.** `add`/`remove` use tempfile + `mv` onto target (SC-9); never edit in place. Trap-register tempfiles on EXIT.
6. **Mutation-lock discipline.** `add`/`remove` acquire `/run/keel-whitelist-mutate.lock` on fd 201 (NOT fd 200 — collision with reload-egress.sh's fd 200); release BEFORE invoking sync so reload-egress.sh's flock acquires cleanly (SC-8 nested-lock-deadlock avoidance).
7. **No gitignore bang-negation for `.example`.** There is NO committed template for the override; SC-3 is explicit about omitting the bang-negation to prevent the Story 2.2 iter-151 AR-2 asymmetry bug.
8. **No `INV-*` manifest edits.** Story 2.4 is consumer-only (SC-15); do not touch `packages/keel-invariants/src/invariants.manifest.ts` or `docs/invariants/devbox-egress.md`.
9. **Scope isolation.** No `user:` / `cap_drop:` / `security_opt:` (Story 2.5). No host-side `pnpm devbox:*` wrappers beyond the SC-12 `devbox:whitelist` entry (Story 2.6). No primitive-hardening (reload-egress.sh stays untouched). No healthcheck (Story 2.13).
10. **Kebab-case + `.sh` + `0755`.** Follow Story 2.1 `benchmark.sh` + Story 2.3 script shape.
11. **Backend-B aware.** Live smokes (Task 10.1–10.8) defer to operator workstation; document in Debug Log References per Story 2.3 Task 12 precedent.
12. **Substrate-source protection.** `remove` MUST detect substrate-source domains (baseline or fragment) and emit a clear operator-education error (SC-1 + Subtask 5.5); do NOT silently no-op or succeed — operators need to know the override has no effect on substrate.
13. **No `.envrc` / `.envrc.local` edits.** Only `packages/devbox/.envrc.example` is ever committed; Story 2.4 does NOT introduce new `.envrc` knobs (SC-2's override path is a dedicated `whitelist.local.txt` file, not an env var).

### Project Structure Notes

- `packages/devbox/scripts/whitelist.sh` — NEW; owned by the devbox substrate.
- `packages/devbox/whitelist.local.txt` — NEW (runtime-created on first `add`); gitignored; owned by the fork operator at runtime.
- `packages/devbox/scripts/start-egress.sh` — extended by a 5-line block inside `compose_whitelist()`; unchanged elsewhere.
- `packages/devbox/whitelist.default.txt` — header-comment refresh only (Task 7.3); content unchanged.
- `packages/devbox/package.json` — one new `scripts` entry.
- `.gitignore` — one new entry + inline comment.
- `AGENTS.md` — new H3 subsection under existing § Devbox iteration environment.
- `packages/devbox/README.md` — new H3 subsection under existing § Egress policy (Story 2.3) H2.

**Detected conflicts / variances:** Architecture tree (l.1002) comments `# add/remove/list/sync (single tool, FR1a)` — SC-1 pins this subcommand surface verbatim. No drift. Epic 2 Story 2.4 AC mentions per-category fragments as `whitelist.github.txt` (flat naming), while architecture tree + Story 2.3 use `whitelist/github.txt` (subdirectory naming); this was resolved at Story 2.3 draft (iter-155) per the epics-wins-over-architecture rule's FILE-LOCATION-drift extension (Story 1.14 iter-74 precedent) — fragments live under `whitelist/` subdir as Story 2.3 shipped; Story 2.4 consumes that shape without change. The Epic 2 Story 2.4 AC 1 phrase `per-category fragments (e.g., whitelist.github.txt, whitelist.npm.txt, whitelist.anthropic.txt)` is treated as informal shorthand for the fragment files; no naming change required at Story 2.4.

### References

- [Source: `_bmad-output/planning-artifacts/epics.md` § Epic 2 § Story 2.4 (l.1267–1299)] — user-story + AC 1–5 verbatim.
- [Source: `_bmad-output/planning-artifacts/prd.md` § FR1a] — fail-closed + repo-tracked whitelist + per-fork override + atomic reload contract.
- [Source: `_bmad-output/planning-artifacts/prd.md` § CLI-Tool Surface (l.493)] — `pnpm devbox:whitelist <add|remove|list|sync> [domain]` subcommand shape.
- [Source: `_bmad-output/planning-artifacts/prd.md` § Devbox Implementation Contract (l.549)] — no `curl|sh` / runtime installs; single mechanism.
- [Source: `_bmad-output/planning-artifacts/architecture.md` § S5 (l.224)] — dual-layer belt-and-braces + atomic-reload via file-locked shell-script.
- [Source: `_bmad-output/planning-artifacts/architecture.md` § Devbox Package Tree (l.975–1004)] — `scripts/whitelist.sh # add/remove/list/sync (single tool, FR1a)` pin.
- [Source: `docs/invariants/devbox-egress.md` § Mechanism] — `reload-egress.sh <composed-whitelist-path>` primitive contract (Story 2.4 caller inherits).
- [Source: `docs/invariants/devbox-egress.md` § Amendment] — fork overrides MAY add per-fork domains AND MUST NOT relax fail-closed default / parity / atomic-reload.
- [Source: `AGENTS.md` § Fork extension (FR44)] — FORK vs AMEND vs DEFER decision tree; Story 2.4's override path is FORK, baseline + fragment edits are AMEND.
- [Source: `_bmad-output/implementation-artifacts/2-3-egress-policy-…-.md` § Scope clarifications SC-8 + Dev Notes § Scope boundary + § Dev-agent guardrails (l.39–60, l.294–306, l.393–407)] — Story 2.3 explicitly defers `whitelist.sh` to Story 2.4; first-downstream-caller contract.
- [Source: `_bmad-output/implementation-artifacts/2-3-egress-policy-…-.md` § Review Findings D2 (l.243)] — CR iter-171 defer: domain-regex validation carries to Story 2.4's user-facing CLI. SC-5 mitigates.
- [Source: `packages/devbox/scripts/reload-egress.sh:1–46 + 82–99`] — primitive argument contract + exit-code table (SC-11 inherits).
- [Source: `packages/devbox/scripts/start-egress.sh:66–99`] — `compose_whitelist()` reference algorithm (SC-14 dual-composer contract anchor).
- [Source: `packages/devbox/whitelist.default.txt` (whole file)] — baseline header + comment format.
- [Source: `.gitignore` (repo root, lines 38–44 at 2026-04-21)] — Story 2.2 `.envrc.local` + `.secrets` gitignore block (SC-3 insertion site).

## Dev Agent Record

### Agent Model Used

claude-opus-4-7 (1M context) via Ralph build-mode iter-174.

### Debug Log References

**Subtask 7.4 / 10.9 — Dual-composer parity smoke (SC-14, in-iteration):**

```text
=== start-egress.sh compose_whitelist output ===
api.anthropic.com
api.github.com
example.com
extra.fork.example
github.com
registry.npmjs.org
shared.example.org
=== whitelist.sh compose_whitelist_into output ===
api.anthropic.com
api.github.com
example.com
extra.fork.example
github.com
registry.npmjs.org
shared.example.org
=== diff ===
PARITY SMOKE PASS — byte-identical (default + 3 fragments + local)
```

Harness method: source `whitelist.sh` (main-guard skips dispatcher when `BASH_SOURCE[0] != $0`); extract `compose_whitelist()` body from `start-egress.sh` via `awk '/^compose_whitelist\(\) \{$/,/^\}$/'`; override `WHITELIST_DEFAULT` / `WHITELIST_FRAGMENTS_DIR` / `WHITELIST_LOCAL` / `COMPOSED_WHITELIST` constants to point at a `mktemp -d` fixture containing baseline + npm/anthropic/github fragments + local override (with `shared.example.org` deliberately overlapping default + local to verify `sort -u` dedup); invoke both composers; `diff -u` outputs. Test fixture also exercises comment-stripping (`# baseline header comment`) and dedup (`shared.example.org` appears in both default + local; final output has one). SC-14 byte-identity contract verified.

**Iteration-env-safe additional smokes (not in spec, run for confidence):**

- `bash -n whitelist.sh` → syntax OK
- `bash whitelist.sh` (no args) → exit 2 + usage emitted to stderr
- `bash whitelist.sh garbage` (unknown subcommand) → exit 2
- `bash whitelist.sh add` (zero args) → exit 2
- `bash whitelist.sh add foo bar` (two args) → exit 2
- `bash whitelist.sh add 'bad_underscore.example'` → exit 2 + `invalid domain syntax: 'bad_underscore.example'`
- `bash whitelist.sh add '-leading-hyphen.example'` → exit 2
- `bash whitelist.sh add 'api.github.com.'` (trailing-dot SC-5 known-limit) → exit 2
- `bash whitelist.sh add 'api.example.org'` (well-formed) → past regex, fails on `/run/keel-whitelist-mutate.lock: Permission denied` (expected — `/run` is privileged outside container)
- `cmd_list` against fixture (D + F:anthropic + F:github + L sources) → emits `<prefix>  <domain>` two-space-separated, alphabetical by domain, source attribution correct
- `validate_sources` against fixture with 4 malformed lines + 1 well-formed line → emits 4 stderr errors with correct DEVBOX_DIR-relative paths + line numbers + offending text; multi-error collection per SC-6 verified

**Subtask 9.2 — `pnpm --filter @keel/devbox run` listing (deferred):** operator-workstation-deferred per backend-B carve-out (no `pnpm` install in iteration env). The `package.json` `scripts` block edit is byte-validated (Subtask 9.1) — operator runs `pnpm --filter @keel/devbox run` to confirm `devbox:whitelist` appears.

**Subtasks 10.1–10.8 (live container smokes) — operator-workstation-deferred per Subtask 10.10 + backend-B carve-out (Story 2.1 iter-127 precedent):**

- 10.1 (sync-on-empty-override) — requires running devbox container + `/run/keel-whitelist.composed.txt` writable + dnsmasq + nft.
- 10.2 (add-new-domain) — requires container + `whitelist.local.txt` write + reload chain.
- 10.3 (remove-domain) — requires container + reload chain.
- 10.4 (list against running container) — requires container; iteration-env list smoke against fixture (above) confirms output format.
- 10.5 (validation-failure) — requires container to verify `nft list chain` shows pre-sync rules unchanged. Iteration-env validate_sources smoke (above) confirms stderr format + multi-error collection + exit 2 contract.
- 10.6 (substrate-source-protection) — `cmd_remove` substrate-check logic exercised in code; iteration-env smoke deferred (requires running container to also verify state untouched).
- 10.7 (concurrent-sync) — requires container + actual `/run/keel-egress.lock` flock arbitration.
- 10.8 (file-not-readable exit 3) — requires container + `chmod 000` on `whitelist.local.txt`.

These smokes bundle into the Story 2.4 "operator-acceptance smoke pass" deferred to the M4-Pro operator workstation per the Story 2.3 Task 12 + Story 2.1 iter-127 precedent. Backend-B (host socket-passthrough) iteration env cannot exercise the container-runtime stack (`/run` not writable, no dnsmasq, no nft, bind-mount-source-not-shared denial for `compose run`).

**Substrate-source protection smoke (Subtask 5.5 logic):** the `cmd_remove` substrate-check uses `sed -E 's/#.*$//' "${substrate_files[@]}" | awk 'NF { ... print }' | grep -Fxq -- "${domain}"` — match-with-comment-strip + whitespace-trim, mirroring composer semantics. Iteration-env code-path inspection only; runtime smoke requires container.

### Completion Notes List

- **Story 2.4 dev-story landed iter-174.** New file `packages/devbox/scripts/whitelist.sh` (~360 LOC, `0755`) implements all four subcommands (`sync` / `add` / `remove` / `list`) per architecture.md § Devbox Package Tree (l.1002) + PRD § CLI-Tool Surface (l.493). Consumes Story 2.3's `reload-egress.sh` primitive without modification (SC-17 first-downstream-caller validates the encapsulated bootstrap-detour contract).
- **SC-14 dual-composer byte-identity verified.** Parity smoke (`Subtask 7.4 / 10.9`) ran in iteration env against a 5-domain fixture spanning all three composition stages (baseline + 3 fragments + local override) with deliberate overlap to test `sort -u` dedup semantics. Outputs byte-identical. Both composers share the identical `mapfile -t fragments < <(LC_ALL=C find … -maxdepth 1 -type f -name '*.txt' -print | sort)` enumeration + `sed -E 's/#.*$//' | awk 'NF { … print }' | LC_ALL=C sort -u` post-processing.
- **`start-egress.sh` extension is a 5-line conditional `cat`** added inside the existing `compose_whitelist()` `{ … }` block, AFTER the fragments loop, BEFORE the closing `}`. Comment block pins SC-4 additive-only contract + SC-14 byte-identity contract. Banner comment at start-egress.sh:12–13 updated to mention `+ whitelist.local.txt if present`. WHITELIST_LOCAL constant added to the constants block at line 27.
- **Fail-closed discipline at three boundaries:** (a) SC-6 — `cmd_sync` runs `validate_sources` BEFORE `compose_whitelist_into`; on failure, exits 2 WITHOUT touching `${COMPOSED_WHITELIST}` or invoking reload-egress.sh. (b) SC-3 — file-read failure (default / fragment / override unreadable when `-e` exists) exits 3. (c) SC-11 passthrough — reload-egress.sh exit codes 5/6/7 propagate verbatim; PREVIOUS_COMPOSED snapshot is NOT updated on reload failure (next sync diffs against still-previous state).
- **Mutation-lock discipline (SC-8):** `cmd_add` / `cmd_remove` acquire `/run/keel-whitelist-mutate.lock` on fd 201 (NOT fd 200 — collision with reload-egress.sh's fd 200). Released BEFORE invoking `cmd_sync` so reload-egress.sh's flock acquires cleanly (nested-lock-deadlock avoidance). 10s timeout exits 4 with actionable stderr.
- **Atomic-mutation discipline (SC-9):** `cmd_add` writes tempfile `${WHITELIST_LOCAL}.tmp.$$` then `mv` onto target (rename(2), atomic on same FS). Tempfile contents read existing file via `existing="$(cat "${WHITELIST_LOCAL}")"` (strips trailing newlines) then `printf '%s\n' "${existing}"` re-adds clean newline + appends new domain — handles hand-edit-without-trailing-newline state. Trap-registers tempfile cleanup on EXIT for crash-safety. `cmd_remove` uses `grep -Fxv` into tempfile + `mv` (idempotent — accepts grep exit 1 when file becomes empty via `|| true`).
- **List source attribution (SC-10):** declare-A associative array maps domain → source prefix. Iteration order: default (`D`) → fragments-sorted (`F:<basename>`) → local (`L`); first-encounter wins (matches `sort -u` semantics). Output format `<prefix>  <domain>` (two-space separator), sorted alphabetically by domain.
- **Domain-syntax validation (SC-5):** strict LDH per-label regex `^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$` + 253-char total-length bound. Two callers: `validate_sources()` (called by `cmd_sync`; iterates source files; collects ALL errors before returning) and `validate_domain()` (called by `cmd_add`/`cmd_remove` for fast-fail before mutation lock). DEVBOX_DIR-relative file path in stderr per SC-6.
- **Substrate-source protection (Subtask 5.5):** `cmd_remove` checks if the requested domain appears in `whitelist.default.txt` or any `whitelist/*.txt` fragment (with comment-stripping + whitespace-trim mirroring composer semantics). On match, emits operator-education error (FR44 AMEND path pointer) + exits 2. Prevents the silent-no-op surprise where an operator believes they removed a domain but the substrate baseline keeps it active.
- **Diff format (SC-7):** `cmd_sync` computes `diff --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format=''` between `${PREVIOUS_COMPOSED}` and the new tempfile, post-processes via `grep '^+' | sort` + `grep '^-' | sort` to produce SC-7-grouped output (additions group first, then removals, each alphabetical), then emits to stdout: header (`whitelist sync: <N> domains active`), additions list, removals list, count line (`(<A> added, <R> removed)`). First-sync-after-boot (no PREVIOUS_COMPOSED): every domain is a `+` addition.
- **Sourceability via main guard:** `whitelist.sh` wraps its main dispatcher in `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then ... fi` so it can be sourced without firing the usage-and-exit branch. Required by Task 7.4 parity harness.
- **Documentation deliverables:** AGENTS.md gained `### Per-fork whitelist override (Story 2.4)` H3 under § Devbox iteration environment; `packages/devbox/README.md` gained `### Per-fork whitelist override (Story 2.4)` H3 under § Egress policy (Story 2.3) (with subcommand table + example invocation session); `whitelist.default.txt` header refreshed to document the three-stage composition order + per-fork override path.
- **`.gitignore` entry:** `packages/devbox/whitelist.local.txt` added at end of `# Environment / secrets` block (line 48), with inline comment explaining provenance + non-committal nature. `git check-ignore -v` smoke verified the rule fires; touched-fixture untracked + cleaned up.
- **`package.json` script wiring (SC-12):** single new `scripts` entry `"devbox:whitelist": "./scripts/whitelist.sh"` appended after `lint`. JSON validity preserved (trailing comma rule). Pre-existing `build` / `typecheck` / `lint` entries unchanged.
- **No invariant manifest edits (SC-15):** Story 2.4 is consumer-only; no new `INV-*` registered, no `INV-devbox-egress-contract` contentHash refresh. `docs/invariants/devbox-egress.md` not edited (sourcePath unchanged).
- **No scope creep (SC-19 verified):** edits stay within the eight files pinned at story Project Structure Notes — `whitelist.sh` (NEW), `whitelist.local.txt` (runtime-created, gitignored — NOT created during dev-story), `start-egress.sh` (5-line composition extension + 2-line constants edit + banner refresh), `whitelist.default.txt` (header rewrite, content unchanged), `package.json` (one entry), `.gitignore` (one entry + comment), `AGENTS.md` (one new H3), `README.md` (one new H3). No `reload-egress.sh` touch (Story 2.3 primitive). No Dockerfile / `docker-compose.yml` / `user:` / `cap_drop:` / Story 2.6 host-side wrapper / Story 2.13 healthcheck edits.
- **FR14n Story State `validated → in-dev`** via the 14th-cumulative-precedent ATDD-skip route (recorded in IP § Notes iter-173). Sprint-status row 2-4: `ready-for-dev → review`. Live smokes 10.1–10.8 deferred to operator workstation per Subtask 10.10 (backend-B carve-out).

### File List

- `packages/devbox/scripts/whitelist.sh` (NEW, 0755, ~360 LOC) — four-subcommand CLI implementing all of Tasks 1–6.
- `packages/devbox/scripts/start-egress.sh` (modified) — Task 7 SC-14 extension: WHITELIST_LOCAL constant added, 5-line conditional `cat` added inside `compose_whitelist()` after fragments loop, banner comment refreshed.
- `packages/devbox/whitelist.default.txt` (modified) — Task 7.3 header-comment rewrite documenting the three-stage composition order + per-fork override path. Content (zero domain entries) unchanged.
- `packages/devbox/package.json` (modified) — Task 9.1 added single `"devbox:whitelist": "./scripts/whitelist.sh"` scripts entry.
- `packages/devbox/README.md` (modified) — Task 8.3 added `### Per-fork whitelist override (Story 2.4)` H3 with subcommand table + example invocation session.
- `AGENTS.md` (modified) — Task 8.2 added `### Per-fork whitelist override (Story 2.4)` H3 under § Devbox iteration environment.
- `.gitignore` (modified) — Task 8.1 added `packages/devbox/whitelist.local.txt` entry at end of `# Environment / secrets` block with inline comment.
- `_bmad-output/implementation-artifacts/2-4-whitelist-source-of-truth-pnpm-devbox-whitelist-atomic-reload-cli.md` (this file, modified) — task checkboxes + Dev Agent Record + Change Log v1.3 + Status flip.
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (modified) — Task 11 sprint-status row 2-4 flip + last_updated comment line.

## Change Log

| Version | Date       | Iter | Summary                                                                                                         |
| ------- | ---------- | ---- | --------------------------------------------------------------------------------------------------------------- |
| v1.0    | 2026-04-22 | 172  | Initial draft — Story 2.4 Whitelist source-of-truth + pnpm devbox:whitelist atomic-reload CLI. Status `backlog → ready-for-dev`; sprint-status row flipped with timestamp comment. Scope: new `packages/devbox/scripts/whitelist.sh` CLI with four subcommands (`sync` / `add` / `remove` / `list`) per SC-1 architecture pin; consumes Story 2.3's `reload-egress.sh` primitive without modification (SC-17 first-downstream-caller); per-fork override at `packages/devbox/whitelist.local.txt` (SC-2) gitignored (SC-3); composition extension in Story 2.3 `start-egress.sh`'s `compose_whitelist()` (SC-14 dual-composer byte-identity); domain-regex validation at CLI boundary per SC-5 (mitigates Story 2.3 CR iter-171 defer D2); diff summary stdout format (SC-7); mutation-lock on fd 201 to avoid collision with reload-egress.sh fd 200 (SC-8); exit codes 2/3/4 local + 5/6/7 passthrough (SC-11); consumer-only — no new invariant manifest entry (SC-15). Seven Ralph-invocable tasks + two documentation tasks + one smoke task + one lifecycle-hygiene task (11 total). Story 2.4 is infrastructure-CLI class — smaller scope than Story 2.3's 17-SC infrastructure-security class; forecast per iter-155 fix-chain equation `(carve-out × 3) + (live-smoke-defer × 3) + (impl-surface-LOC / 100)`: zero substrate-new + backend-B defer (+3) + impl ~250 LOC (+3) → ~3–6 iter fix-chain forecast; projected tighter than Story 2.3's 10-iter chain due to consumer-not-authoritative scope. |
| v1.1    | 2026-04-22 | 173  | Pre-dev SM review (`/bmad-create-story review`) — three-layer parallel fresh-context Sonnet fan-out against SC-5 (LDH regex), SC-6 (validation contract), SC-1/5.5 (substrate-source grep), SC-8 (fd-lock collision), SC-14 (byte-identity composer), SC-7/3.4 (diff grouping), SC-12 (package.json wiring), SC-3 (gitignore insertion), and Task 11 (lifecycle framing). **Findings applied (1 CRITICAL + 4 ENHANCEMENTS):** (1) **CRITICAL** Subtask 3.4 — GNU `diff` emits changed lines in file-position order (not SC-7-grouped `+`-first-then-`-` alphabetical), so added explicit post-processing (`grep '^+' \| sort` + `grep '^-' \| sort`) plus Subtask 3.8 rewrite to compose the header + sorted-additions-list + sorted-removals-list + count-line in SC-7 order. (2) **ENHANCEMENT** Subtask 5.5 — `grep -Fxq` now strips comments + blanks (`sed -E 's/#.*$//' \| awk 'NF'`) before substrate-source match to prevent false positives from commented lines. (3) **ENHANCEMENT** Task 7 title renamed to `start-egress.sh extension + whitelist.default.txt baseline-doc refresh + dual-composer parity smoke` (Subtask 7.3 was a doc-refresh, not an extension; title now reflects all three sub-scopes). (4) **ENHANCEMENT** SC-3 + Subtask 8.1 — gitignore insertion site clarified from "immediately after `!packages/devbox/.secrets.example`" (ambiguous: line 45 vs end-of-block line 47) to "AT THE END of the `# Environment / secrets` block" (unambiguous; keeps the `.secrets` family contiguous). (5) **ENHANCEMENT** Task 11 — Subtasks 11.1 / 11.2 / 11.3 marked `[x]` with `*(completed iter-172 draft)*` annotation (these were performed at draft time); dev-story's lifecycle-hygiene obligation renumbered to Subtask 11.4 (v1.3 Change Log entry at landing) + 11.5 (SC-19 scope-creep check). **Documented as known limitations (scope-pinned at 1.0, deferred to post-1.0):** SC-5 regex does not enforce RFC 3696 §2 all-numeric TLD prohibition nor FQDN trailing-dot notation — failure mode is benign (fail-closed resolution rather than fail-open match); injection-prevention property preserved. **FR14n Story State transition `drafted → validated`.** Status `ready-for-dev → validated`. No substrate code edits this iter (story-doc-only fixes). Next iteration — ATDD-skip decision per the 13-cumulative-precedent IP QUEUE § 1: Story 2.4 has no authored test-runner (Task 7.4 + Task 10 smokes are ad-hoc shell-level); hybrid ground-(c)+(ii)+(iii) skip applies (downstream Epic 13 harness owns regression coverage; SM review + CR substitute for adversarial coverage). **Fourteenth cumulative FR14n ATDD-skip precedent projected** (Stories 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14/1.15/1.16/2.1/2.2/2.3 → 2.4). |
| v1.3    | 2026-04-22 | 174  | **dev-story landing** — `/bmad-dev-story` executed all 11 tasks in single fresh-context iteration. Eight files touched: NEW `packages/devbox/scripts/whitelist.sh` (~360 LOC, 0755) implementing four-subcommand CLI (`sync` / `add` / `remove` / `list`); `start-egress.sh` extended with WHITELIST_LOCAL constant + 5-line conditional `cat` inside `compose_whitelist()` after fragments loop + banner refresh (SC-14 byte-identity); `whitelist.default.txt` header rewritten to document three-stage composition; `package.json` gained `"devbox:whitelist": "./scripts/whitelist.sh"` script entry (SC-12); `packages/devbox/README.md` gained `### Per-fork whitelist override (Story 2.4)` H3 with subcommand table + invocation session; `AGENTS.md` gained matching H3 under § Devbox iteration environment; `.gitignore` gained `packages/devbox/whitelist.local.txt` entry at end of `# Environment / secrets` block (SC-3, no `.example` bang per Story 2.2 iter-151 AR-2 asymmetry-bug avoidance). **SC-14 dual-composer parity smoke (Subtask 7.4 / 10.9) passed in iteration env** — byte-identical output across baseline + 3 fragments + local override fixture (with deliberate `shared.example.org` overlap to verify `sort -u` dedup); harness sources `whitelist.sh` (main-guard added so it's sourceable without firing dispatcher) + `awk`-extracts `compose_whitelist()` body from `start-egress.sh`, overrides constants to point at fixture, diffs outputs. **Iteration-env-safe additional smokes** all pass: `bash -n` syntax check, dispatcher exit-2 contract (no-args / unknown-subcommand / wrong-arity), domain-syntax validation rejection (underscore / leading-hyphen / trailing-dot SC-5 known-limit), well-formed-domain regex acceptance (then expected `/run` permission-denied at mutation lock — backend-B context, not a defect), `cmd_list` source-attribution output format (`<prefix>  <domain>` two-space, alphabetical), `validate_sources` multi-error collection (4 stderr lines for 4 malformed fixture entries with correct DEVBOX_DIR-relative paths + line numbers, valid lines pass — SC-6 verified). **`.gitignore` smoke** verified `git check-ignore -v packages/devbox/whitelist.local.txt` fires the new rule (.gitignore:48). **Live container smokes 10.1–10.8 + 9.2 deferred** to operator workstation per Subtask 10.10 + Story 2.1 iter-127 backend-B precedent (host socket-passthrough cannot exercise `/run`, dnsmasq, nft, or `pnpm install` from iteration env). FR14n Story State `validated → in-dev`. sprint-status row `2-4`: `ready-for-dev → review`. PR #230 stays Draft (Epic 2 closes at Story 2.17). Next iteration: `/bmad-testarch-trace (args: "yolo")` for `in-dev → traced` AC→test coverage gate. |
| v1.4    | 2026-04-22 | 175  | **`/bmad-testarch-trace (args: "yolo")` trace entry — FR14n Story State `in-dev → traced`.** Four trace artefacts produced under `_bmad-output/test-artifacts/traceability/`: `2-4-coverage-matrix.json` (Phase 1 — 5 P2 ACs; 0% automated coverage; STRONG substrate evidence with file-presence + content-signal + line numbers + SC-14 parity-smoke PASS for each AC); `2-4-e2e-trace-summary.json` (Phase 2 schema-v1 rationale); `2-4-gate-decision.json` (WAIVED with grounds (a)+(b)+(c)+(d) variant-(ii)+(iii) rationale); `2-4-whitelist-source-of-truth-pnpm-devbox-whitelist-atomic-reload-cli.md` (full report). **Gate verdict: WAIVED — FOURTEENTH cumulative trace-WAIVED precedent** (Stories 1.7 → 1.16 = 10 Epic-1 pairings; 2.1 iter-126 = 11; 2.2 iter-149 = 12; 2.3 iter-159 = 13; 2.4 iter-175 = 14). **FIFTEENTH cumulative ATDD-skip-trace-WAIVED co-application pairing** (pairs with iter-173 ATDD-skip). First user-facing-CLI class precedent-holder (Stories 2.1 = infrastructure-smoke, 2.2 = hybrid infrastructure + configuration, 2.3 = infrastructure-security with daemon + kernel-rule + atomic-reload + log-tailer; 2.4 = operator-editable bash CLI with subcommand dispatcher + domain-regex validation + mutation-lock + atomic-replace + diff summary outside the Vitest/Playwright idiom). Unlike Story 2.3 which had ZERO iteration-env runtime assertions, Story 2.4 has MORE iteration-env executable evidence: **SC-14 dual-composer parity smoke PASSED byte-identical** (baseline + 3 fragments + local override fixture with `shared.example.org` dedup-overlap; harness sources `whitelist.sh` via `BASH_SOURCE[0]==$0` main-guard + `awk`-extracts `compose_whitelist()` body from `start-egress.sh`); iteration-env dispatcher exit-2 contract (no-args / unknown-subcommand / wrong-arity); `validate_domain` single-arg regex rejection (underscore / leading-hyphen / trailing-dot SC-5 known-limit); `validate_sources` multi-error collection (4 stderr lines for 4 malformed fixture entries with DEVBOX_DIR-relative paths + 1-indexed line numbers — SC-6 verified); `cmd_list` source-attribution output (`<prefix>  <domain>` two-space-separated, alphabetical, first-encounter-wins source attribution); `git check-ignore -v packages/devbox/whitelist.local.txt` rule-fires at `.gitignore:48`. Only live container smokes (Subtask 10.1–10.8 full reload chain + Subtask 9.2 `pnpm --filter @keel/devbox run` listing) remain operator-workstation-deferred per Subtask 10.10 + Story 2.1 iter-127 backend-B precedent. Sync-gate green (20 manifest entries valid; NO new entry per SC-15 consumer-only; `INV-devbox-egress-contract` contentHash `aad16a51…6889b` unchanged per SC-19 scope isolation). Story Status `in-dev → traced`. Next iteration: `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification (`traced → sm-verified` or `sm-fixes-pending`). CR-forecast envelope ~2–4 PATCH opener per iter-155 equation (0-carve-out + backend-B live-smoke defer + ~360 LOC impl → ~6.6 ceiling; tighter than Story 2.3's 10-iter chain because dual-composer parity PASS in iteration env de-risks SC-14 byte-identity invariant). |
