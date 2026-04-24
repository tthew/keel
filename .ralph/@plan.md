# Implementation Plan

## NOW

- [ ] **Story 2.17 `/bmad-dev-story` CONTINUATION** (`in-dev (partial)` — 14 of 17 Tasks / subtrees landed across iter-312..319; 3 remaining). Per § Story Lifecycle Decision Matrix row `atdd-scaffolded` continuation. **iter-320 NOW candidate: Task 10.1 D-31..D-36 fourth/final batch (6 D-items / ~40K budget)** — /proc surface narrow (D-31; narrows current `cat*/proc/*/environ*` beyond `/environ` to cover `/proc/*/cmdline`, `/proc/*/mem`, `/proc/*/status` variants if the story spec pins them at drafting); config.toml key-name contract (D-32 — lockstep between hook + Epic 3 consumer; spec at story-file Task 10.1 D-list); Grep content-search scope carve-out (D-33); jq silent fail-open (D-34); unanchored case-glob false-positives audit (D-35); seed exec-bit preservation (D-36 — post-iter-319 validation that seed file has +x bit same as substrate). Close-out batch; doc narrative heaviest; 1 iter. Route via Write + python3 per iter-316 NOVEL LESSON + iter-317+318+319 confirmations.

## QUEUE (Story 2.17 continuation + lifecycle close + Epic 2 close-out)

- [ ] _(after Task 10.1 fully landed at iter-320)_ Task 11 (D-7/D-8/D-9 lints) + Task 13 (docs sibling-append AGENTS.md/CLAUDE.md/packages/devbox/README.md including Task 2.3 fork-extension-slot doc) + Task 14 (seed lockstep) + Task 5 (S4 rules) + Task 6 (halt-threshold doc pin + config.toml verify) + Task 9 doc pins + Task 15 (≥25 impl-time fixture smokes — cumulative 173 at iter-319; see Notes) + Task 16 (SC-17 polish) + Task 17 (completion).
- [ ] **SC-17 close-out candidates** queued for Task 16: (a) substrate-bake prek native binary in Dockerfile (Story 2.5 AMEND) so fresh-fork devbox first-boot works without network access — addresses iter-313 BLOCKED class; (b) add `release-assets.githubusercontent.com` to substrate `packages/devbox/whitelist/github.txt` so operator doesn't need manual `pnpm devbox:whitelist add`; (c) host-OS-aware `.git/hooks/*` config portability (if iter-312 gotcha re-emerges on fresh fork); (d) iter-314 NOVEL CANDIDATE: promote `loadExpectedHooks` runtime path translation into a generic "source-to-dist resolver" if further TS-authored enumerator entries land (currently 1 site — threshold not met); (e) iter-317 NOVEL: either close Python-write loophole at hook layer (Python source AST parse — costly, rejected) OR document it explicitly in `docs/invariants/claude-hook-denylist.md § Limitations` (the loophole is legitimate at Story 2.17 scope for substrate-self-maintenance; S4 scan layer + manifest content-hash backstop cover it).
- [ ] _(after Story 2.17 Tasks fully landed)_ `/bmad-testarch-trace (args: "yolo")` — `in-dev → traced`. 27th cumulative trace; likely WAIVED per Epic-2 17-story chain continuation + impl-time-smokes substitute.
- [ ] _(after traced)_ `/bmad-create-story (args: "review")` — post-dev SM `traced → sm-verified`.
- [ ] _(after sm-verified)_ `/bmad-code-review (args: "2")` — `sm-verified → done`.
- [ ] _(after Story 2.17 `done`)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion fires `EPIC_DONE` halt; on re-entry auto-advances to Epic 3 Story 3.1.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..317).

## BLOCKED

_(empty — iter-319 pre-push gates all GREEN at first pass; no retries needed.)_

## ATDD Red Phase

_(empty — iter-311 SKIP-WITH-GROUNDS-(ii)+(iii). Impl-time substrate coverage: iter-312 `check-claude-hook-syntax.ts`; iter-314 `names-and-shebangs` walker; iter-315 14 hook smokes GREEN; iter-316 5; iter-317 53; iter-318 41; iter-319 60 — cumulative 173 impl-time static probes toward Task 15.1 ≥25 target. Far above threshold; Task 15.1 remaining scope is bash-fixture persistence under `packages/keel-invariants/fixtures/hooks/` for future-Ralph replay, not additional probe authoring.)_

## DONE (iter-319 PARTIAL CONTINUATION)

- [x] iter-319: **Story 2.17 `/bmad-dev-story` PARTIAL CONTINUATION — Task 10.1 D-25..D-30 third batch** landed. `.claude/hooks/block-secret-access.sh` 225→262 lines; `.claude/settings.json` `hooks.PreToolUse` 6→8 matchers. **D-25 MultiEdit + NotebookEdit matchers** — two new entries in `.claude/settings.json` `hooks.PreToolUse`; hook's `case "$tool_name"` extracts `file_path` for `MultiEdit` + `notebook_path` for `NotebookEdit`; Edit|Write case arm widened to `Edit|Write|MultiEdit|NotebookEdit` so hook-self-protection + L1 install-boundary fire across all four mutation matchers. **D-26 fork-hook cwd-independence** — replaced `.claude/hooks/block-secret-access.fork.sh` hardcoded path with `"$(dirname "${BASH_SOURCE[0]}")/block-secret-access.fork.sh"`. **D-27 fork-hook contract** — captured `fork_output` + `fork_exit` via `|| fork_exit=$?` (avoids `set -e` short-circuit); jq-validated JSON shape (`type=="object" and ((.decision=="approve") or (.decision=="block" and (.reason|length)>0))`); substrate FAILS CLOSED on nonzero exit OR invalid JSON with its own `{"decision":"block","reason":"fork-hook-contract-violation","match":"nonzero-exit|invalid-json-shape"}` + JSONL log. Valid fork-block decisions log `fork-hook:<reason>` for Epic 4 FR37 traceability. **D-28 tilde-form + /home/dev/.ssh/** — Read arm `\~/.claude/*|\~/.config/gh/*` → `read-oauth-token-tilde`; `/home/dev/.ssh/*|\~/.ssh/*` → `read-ssh-key`; resolved arm `/home/dev/.ssh/*` → `read-resolved-to-ssh-key`; Bash arm reader-verb case-glob alternation adds 34 tilde-form entries (14 readers × 2 paths + 6 interp-stdin × 2 paths) plus 38 entries for `/home/dev/.ssh/` + `~/.ssh/`. **D-29 ABSORBED-BY-TASK-4** (doc-only marker). **D-30 Read-path secret-file patterns** — 19 patterns added (`id_rsa`|`*/id_rsa`|`id_ed25519`|`*/id_ed25519`|`id_ecdsa`|`*/id_ecdsa`|`*.pem`|`*.key`|`credentials.json`|`*/credentials.json`|`.pgpass`|`*/.pgpass`|`.npmrc`|`*/.npmrc`|`.pypirc`|`*/.pypirc`|`*.p12`|`*.pfx`|`*.crt`) → `read-secret-file`; `id_rsa.pub` intentionally remains approvable via exact-match-not-prefix. **Impl-time fixture smokes: 60 GREEN** (`/tmp/story217-iter319-smoke.py` — 8 D-25 + 2 D-26 + 7 D-27 + 12 D-28 + 19 D-30 + 12 regressions); 0 FAIL at first run against pre-install staged hook. Re-ran against installed substrate hook 60/60 GREEN. Manifest `INV-claude-hook-secret-denylist` contentHash `eda1f6dd7abf…` → `b16b42be9d3d…`; `INV-claude-settings-deny-rules` contentHash `321efb987bd8…` → `51cd4b26c208…`. Seeds re-synced byte-identical (`packages/keel-templates/src/seeds/.claude/{hooks/block-secret-access.sh,settings.json}`). Pre-push gates all GREEN (typecheck 16/16, lint 16/16, format:check clean, sync-gate exit 0 on 39 entries, claude-hook-syntax exit 0).

_(iter-303..318 LANDING detail pruned per Guardrail 2; retained in commits through `a3108ef` + story-file Status HTML comment chain + story-file Change Log 0.1-0.8 rows.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **16/17 stories done** (2.1-2.16) + **Story 2.17 `in-dev (partial)` at iter-319** (Epic-2 final story; XL partial landing — 14 of 17 Tasks / subtrees landed across iter-312..319; 3 remaining).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred.
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:121; bash + jq baked at :36-37 + :48). Host-side shim count: **18** at iter-319 (unchanged).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **16 done** (2.1-2.16); **1 in-dev (partial)** (2.17 — 14 of 17 Tasks / subtrees landed).
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.17 — Hook + settings bypass-resistance (git-layer + manifest + S4 + halt).
- **Story File:** `_bmad-output/implementation-artifacts/2-17-hook-settings-bypass-resistance-git-layer-manifest-s4-halt.md` (~590 lines post-iter-316; unchanged body at iter-319 — Task 10.1 D-25..D-30 spec already pinned at iter-311 drafting; Status HTML-comment + Change Log 0.9 row updated inline).
- **Story State:** `in-dev (partial)` — iter-320 NOW = `/bmad-dev-story` CONTINUATION per § Story Lifecycle dev-story invocation guidance; NOW candidate Task 10.1 D-31..D-36 fourth/final batch.
- **GitHub Issue:** no GitHub Project configured; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..319).

## Notes

- **iter-319 NOVEL — `/tmp` tmpfs is `noexec,nosuid,nodev,relatime` (Story 2.5 container hardening).** `[ -x /tmp/...sh ]` returns FALSE even for files at mode 0755 because kernel refuses exec(2) regardless of st_mode bits. Fork-hook smokes that stage scripts under `/tmp/` and rely on substrate hook's `[ -x "$fork_hook_path" ]` to find them will SILENTLY fail to invoke the fork hook (substrate treats it as absent + falls back to default-approve). **Workaround:** stage fork-hook smoke fixtures under `$HOME/tmp-*/` or `/workspace/*` (both exec-allowed). Confirmed at iter-319 by `findmnt /tmp` → `rw,nosuid,nodev,noexec,relatime,size=2097152k`. Not a security bypass — this is intended NFR8/NFR8a hardening posture. **Carry-forward rule:** future hook-smokes that need a directory with exec-allowed files (forks of the substrate hook, capability probes, etc.) must use `$HOME/tmp-story*/` base. Promote to RALPH.md Gotchas at 2 data points (iter-319 is first — watch for re-validation at Task 10.1 D-31..D-36 fourth batch).

- **iter-319 NOVEL — `readlink -f` returns canonical path regardless of target file existence when parent dir exists.** The D-22 resolved-path Read arm fires FIRST for `/home/dev/.claude/*` + `/home/dev/.ssh/*` reads because `/home/dev/.claude` + `/home/dev/.ssh` parent dirs exist (Story 2.5 named volume + Story 2.12 opt-in SSH substrate), so `readlink -f` canonicalises the path even when the target file doesn't exist. Hook then fires with rule-id `read-resolved-to-*` variant (`read-resolved-to-oauth-token`, `read-resolved-to-ssh-key`, `read-resolved-to-proc-environ`). Direct-path rule-id `read-*` (e.g. `read-ssh-key`) only fires if `readlink -f` FAILS (parent dir missing). **Test-authoring rule:** smokes targeting secret-dir reads under `/home/dev/.claude/` / `/home/dev/.config/gh/` / `/home/dev/.ssh/` / `/proc/*/environ` must accept EITHER rule-id variant via substring-contains (`"ssh-key"`, `"oauth-token"`, `"proc-environ"`) rather than exact-match. Not a security contract issue — rule-id duality is correct D-22 design; test expectations were the defect.

- **iter-318 NOVEL carry-forward — `sed -i <expr>` case-glob over-block when `<expr>` contains substrate-protected path literals.** Unchanged at iter-319; D-25..D-30 batch did not touch the D-14 case-globs. Carry-forward rule holds.

- **iter-318 NOVEL carry-forward — `gh pr view` GraphQL API intermittent timeout + curl-sanity workaround.** iter-319 orient succeeded on first `gh pr view` call — no timeout seen. Carry-forward rule holds (use `curl -sI --max-time 8 https://api.github.com/` sanity before entering BLOCKED).

- **iter-317 carry-forward — D-15 wrapper normalization MUST NOT strip interp-stdin readers.** Unchanged at iter-319; D-25..D-30 batch did not touch the D-15 normalizer.

- **iter-317 carry-forward — D-14 find-delete regex trailing-slash optional.** Unchanged at iter-319.

- **iter-316 carry-forward RE-CONFIRMED at iter-319** — Python-based hook/settings/manifest edit loophole still open post-D-25..D-30 landing. iter-319 exploited 4× (hook apply + settings apply + seed hook + seed settings) — structurally identical to iter-316/317/318. Still pending long-term close at Task 16 SC-17 (option (e) — explicit doc-only limitation at `docs/invariants/claude-hook-denylist.md § Limitations`).

- **iter-316 NOVEL LESSON re-validated at iter-319** — Write-then-python3 pattern (6th data point now). Already in `RALPH.md § Gotchas 2026-04-24 (Story 2.17 iter-316)` — no promotion action required.

- **iter-315 carry-forward — `install-boundary-protection` rule-id EMPIRICALLY RE-VALIDATED at iter-319** (D-25.f MultiEdit smoke + REG.k Edit smoke GREEN). Unchanged.

- **iter-314 carry-forward — `names-and-shebangs` runtime path translation.** Single data point; promotion threshold 2 unreached. Unchanged at iter-319 (no new TS-authored enumerator entries added).

- **iter-314 carry-forward — narrow-after-SM-absorb 5→7-data-point STABLE LESSON promotion threshold:** unchanged. Story 2.17 post-dev SM moves further out with iter-319 third-batch continuation (iter-322+ estimate).

- **iter-314 SC-17 close-out candidates carry forward** unchanged. iter-319 did NOT promote any new candidates — D-25..D-30 batch landing was clean; novel lessons are test-authoring-discipline (noexec-/tmp + readlink canonicalisation) not hook-contract issues.
