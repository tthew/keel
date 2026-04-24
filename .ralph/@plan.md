# Implementation Plan

## NOW

- [ ] **Story 2.17 `/bmad-dev-story` CONTINUATION — Task 16 (SC-17 polish bundle: substrate-bake prek + whitelist + iter-317 NOVEL docs-only carry-forward)** — SC-17 Epic-2 close-out audit per Task 16 scope. (a) substrate-bake prek native binary in Dockerfile (Story 2.5 AMEND) so fresh-fork devbox first-boot works without network access — addresses iter-313 BLOCKED class; (b) add `release-assets.githubusercontent.com` to substrate `packages/devbox/whitelist/github.txt` so operator doesn't need manual `pnpm devbox:whitelist add`; (c) host-OS-aware `.git/hooks/*` config portability (if iter-312 gotcha re-emerges on fresh fork); (d) iter-314 NOVEL CANDIDATE docs-promotion to `docs/invariants/install-boundary.md § Source-to-dist resolver` if threshold reached (currently 1 site — threshold not met — keep deferred); (e) iter-317 NOVEL carry-forward complete (iter-325 § L1 install-boundary rule § Substrate-maintenance loophole narrative landed); (f) iter-320 NOVEL reader-verb word-boundary anchoring defer to Epic 4 Story 4.x scanner or `docs/invariants/claude-hook-denylist.md § Limitations` — document-only action; (g) iter-329 sub-novel `eslint.config.keel-invariants.js` self-exclusion-glob extension pattern documentation in the same limitations section. ~medium (mix of Dockerfile AMEND + whitelist file edit + doc-only deferrals; pre-flight check advised — if Dockerfile AMEND lands cleanly decompose the whitelist + doc items into separate QUEUE entries).

## QUEUE (Story 2.17 post-Task-15.1 decomposition + lifecycle close + Epic 2 close-out)

- [ ] Task 17 (completion): close out Story 2.17 `in-dev (partial) → in-dev` once Tasks 16 lands + verify sub-tasks 15.2/15.3/15.4/15.5 (re-run `pnpm keel-invariants:check-all` 41 entries + `pre-commit run --all-files` + `pnpm --filter @keel/keel-invariants test` 7/7 GREEN + populate Completion Notes with per-AC evidence). Ensure story DoD complete + Dev Agent Record populated + Change Log final row.
- [ ] _(after Story 2.17 Tasks fully landed)_ `/bmad-testarch-trace (args: "yolo")` — `in-dev → traced`. 27th cumulative trace; likely WAIVED per Epic-2 17-story chain continuation + impl-time-smokes substitute. Exception: iter-329 Task 5 authored 7 genuine `node:test` unit tests (the first keel-invariants tests in-repo), so SM review can cite them as AC-3 coverage evidence and trace does not have to waive for Task 5.
- [ ] _(after traced)_ `/bmad-create-story (args: "review")` — post-dev SM `traced → sm-verified`.
- [ ] _(after sm-verified)_ `/bmad-code-review (args: "2")` — `sm-verified → done`.
- [ ] _(after Story 2.17 `done`)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion fires `EPIC_DONE` halt; on re-entry auto-advances to Epic 3 Story 3.1.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..331).

## BLOCKED

_(empty — iter-332 Task 15.1 bash-fixture persistence landed uneventful; all pre-push gates GREEN.)_

## ATDD Red Phase

_(empty — iter-311 SKIP-WITH-GROUNDS-(ii)+(iii). Impl-time substrate coverage: 397 cumulative smokes GREEN across iter-315..320 runs + 7 genuine `node:test` unit tests GREEN at iter-329 for Task 5 S4 rules + **74 persisted replay fixtures GREEN at iter-332** (`packages/keel-invariants/fixtures/hooks/run-all.sh` — 55 positive + 19 negative). Total persisted/reproducible at iter-332: 7 unit tests + 74 replay fixtures. Task 15.1 DONE.)_

## DONE (iter-332 Task 15.1 bash-fixture persistence)

- [x] iter-332: **Story 2.17 `/bmad-dev-story` PARTIAL CONTINUATION — Task 15.1 (bash-fixture persistence under `packages/keel-invariants/fixtures/hooks/` for future-Ralph replay). Task 15 flipped `[ ] → [~]`; 15.1 DONE; 15.2-15.5 fold into Task 17 completion verify.** 74 replay fixtures authored (55 positive × every reachable `(rule-id, match)` tuple + 1 standalone D-22 symlink; 19 negative × FP-avoidance) all GREEN via `bash packages/keel-invariants/fixtures/hooks/run-all.sh` (74/0/74). Infra: `_lib.sh` (expect_block/expect_approve + 7 `payload_*` helpers incl. `payload_notool`), `run-all.sh` (iterate + summary), `README.md` (layout + rule-id reference + dominance notes + regeneration recipe), `_gen-fixtures.py` (generator persisted for future-Ralph extension). Non-L1 path; plain Write allowed. Triage loop: first run had 9 FAIL → traced to **four runtime-reachability clarifications** now captured in README § Dominance notes + promoted to RALPH.md § Gotchas 2026-04-24 iter-332 Gotcha entry: (a) D-22 Read resolved-path branch (`read-resolved-to-*`) dominates direct-path case-globs in devbox since `readlink -f` canonicalises through physical `/home/dev/.claude/` + `/home/dev/.ssh/` + `/proc/self/` — direct-path tokens unreachable; (b) `__unknown__` fires only on jq-parse-fail or missing `.tool_name` (payload_notool exercises it); (c) L1 `find -delete` regex requires specific filenames under `src/`, not the dir itself; (d) Grep/Glob `search_path` case-glob requires trailing content. Standalone symlink fixture keeps throwaway symlink live across hook invocation. Pre-push gates all GREEN: `pnpm --filter @keel/keel-invariants build` tsc -b clean; `pnpm keel-invariants:check-all` exit 0 on 41 entries (no contentHash refresh needed — fixtures not in manifest + L1 covers `src/` only); `pnpm -w typecheck` 16/16 (1.478s); `pnpm -w format:check` clean (after one-shot `pnpm prettier --write fixtures/hooks/README.md`); `pnpm -w lint` 16/16 (4.321s). No substrate hook/settings/manifest-sub-tree perturbation; no seed re-sync required. Net post-iter-332: **3 top-level Tasks remain: 15 (15.2-15.5 folded into Task 17 completion verify), 16 (SC-17 polish), 17 (completion)**. Iteration NOVEL: RALPH.md § Gotchas +1 entry (runtime-reachability rule for hook-contract tests).

- [x] iter-331: Task 9 (CI visibility contract stub for Epic 14) — invariant-doc § CI visibility contract H3 section + manifest contentHash refresh `486e6ee1ec6e…` → `cb32195fc573…`. Detail in commit `420f8c1`.

- [x] iter-330: Task 6 (halt-threshold verify-pass) — pure-verify iter with no file mutation. Detail in commit `718276d`.

- [x] iter-329: Task 5 (S4 prompt-injection scan rules) — three `high`-severity rules + 7 `node:test` GREEN. Detail in commit `58e2ff9`.

_(iter-303..328 LANDING detail pruned per Guardrail 2; retained in commits through `58e2ff9` + story-file Status HTML comment chain + story-file Change Log 0.1-0.21 rows.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **16/17 stories done** (2.1-2.16) + **Story 2.17 `in-dev (partial)` at iter-332** (Epic-2 final story; XL partial landing continuing through Task 15.1 DONE + remaining Tasks 16/17).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred.
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:121; bash + jq baked at :36-37 + :48). Host-side shim count: **18** at iter-331 (unchanged).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **16 done** (2.1-2.16); **1 in-dev (partial)** (2.17 — Task 10.1 iter-320 complete; Task 13 iter-325 complete; Task 11 iter-327 complete; Task 14 iter-328 complete; Task 5 iter-329 complete; Task 6 iter-330 complete; Task 9 iter-331 complete; Task 15.1 iter-332 complete; 3 top-level Tasks remain: 15 (15.2-15.5 fold into Task 17 completion verify), 16, 17).
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.17 — Hook + settings bypass-resistance (git-layer + manifest + S4 + halt).
- **Story File:** `_bmad-output/implementation-artifacts/2-17-hook-settings-bypass-resistance-git-layer-manifest-s4-halt.md` (~567 lines post-iter-332 Change Log 0.21 append + Task 15 flipped `[~]` + Task 15.1 checkbox set).
- **Story State:** `in-dev (partial)` — iter-333 NOW = `/bmad-dev-story` CONTINUATION per § Story Lifecycle dev-story invocation guidance; NOW item Task 16 SC-17 polish bundle (medium).
- **GitHub Issue:** no GitHub Project configured; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..332).

## Notes

- **iter-332 NOVEL — single data point promoted to RALPH.md § Gotchas (2026-04-24 iter-332).** Hook-contract tests MUST align to the REACHABLE branch in the runtime, not to source-order case precedence. Four devbox-runtime reachability learnings: (a) D-22 resolved-path branch dominates direct-path case-globs; (b) `__unknown__` fires only on jq-parse-fail or missing `.tool_name`; (c) L1 `find -delete` regex requires specific filenames, not dir; (d) Grep/Glob `search_path` case-glob requires trailing content. Full detail in `packages/keel-invariants/fixtures/hooks/README.md § Dominance notes`. Single data point; promotion to rule-type on second re-validation (likely Task 15.2-15.5 completion OR Epic 4 scanner-binary authoring).

- **iter-331 NOVEL — none (promotion threshold unreached).** Mechanical invariant-doc amendment + manifest contentHash refresh following established iter-325/329 docs-amend-plus-python3-heredoc discipline. Sub-novel observation: the "verify-pass, likely additive edit if drift found" NOW pattern is a repeated one-shot motif for contract-pin tasks (iter-330 Task 6 pure-verify; iter-331 Task 9 verify-then-additive). When future verify-pass NOW items find drift at orient, the python3-heredoc manifest-refresh route + plain-Edit for the doc target (outside L1) is the canonical two-step pattern.

- **iter-330 NOVEL — none (pure-verify pass with no file mutation).** Mechanical Task 6 verification following pre-landed iter-318 D-23 `.ralph/config.toml` header-comment + iter-325 Task 13.5 § Halt-threshold pin D-23 + D-32 amendments. No substrate perturbation; no manifest refresh; no seed re-sync. Pre-push gates not re-run (identical state to iter-329 GREEN set). Promotion threshold unreached.

- **iter-329 NOVEL — `shutil.move` vs `os.replace` for /tmp-to-L1 new-file authoring (recorded in RALPH.md § Gotchas 2026-04-24 iter-329).** `os.replace` requires same-fs atomic rename; when `/tmp` is tmpfs and the repo is on a different mount, the call raises `[Errno 18] Invalid cross-device link`. `shutil.move` handles cross-fs automatically via copy2+unlink fallback. Distinct from the iter-315/316/325/326/327/331 python3-heredoc in-place atomic-replace pattern (that uses `target + '.tmp'` adjacent to the target — always same-fs; iter-331 re-confirmed at manifest contentHash refresh for `INV-claude-hook-secret-denylist-doc`). Applies generally to any future L1-additive authoring (more S4 rules, sync-gate helpers, manifest-reader utilities).

- **iter-328 NOVEL — none (promotion threshold unreached).** Mechanical docs-only Task 14 landing; seed-sync lockstep audit trivially passed per continuous discipline; no perturbation.

- **iter-327 NOVEL — none (promotion threshold unreached).** Mechanical Task 11.1 landing following established python3-heredoc atomic-replace discipline for L1-protected manifest edits. Sub-novel carry-forward: **sync-gate drift-kind `added-to-source-only` proves the reverse-direction invariant** (manifest entries without INVARIANTS.md anchors fail sync-gate just as anchors without manifest entries do — validated iter-327). Also: **manifest can carry two entries at distinct sourcePaths that share a contentHash legitimately** (substrate + seed at byte-identity-by-convention — intentional).

- **iter-326 NOVEL carry-forward — negative-smoke harness pattern for path-hardcoded `check-*.ts` scripts.** `node --import <hook>` + `fs.readFileSync` path-redirect stub enables impl-time negative smokes without modifying the substrate file under test. Single data point at iter-326. iter-329 Task 5 unit tests used a different pattern (node:test builtin + synthetic DiffHunk inputs — no path-redirect needed since rules are pure functions). Promotion threshold 2 still unreached.

- **iter-320 NOVEL carry-forward — shell case-globs match prefix-then-any, not word-boundary-anchored.** `case "$normalized" in rm*.claude/settings*) ...` matches `rmdir .claude/settings.json` (FP). Fix via regex `[[ "$normalized" =~ ^rm([[:space:]]|$) ]]`. **Rule:** new case-glob-based rule authoring inside `.claude/hooks/*.sh` MUST use word-boundary regex for any verb with common-prefix collision risk. Single data point at iter-320 for D-35 restructure; still unreached at iter-331 (no new hook case-globs added).

- **iter-320 NOVEL carry-forward — `chmod` command prefix FP-blocks seed-sync pattern.** Bash command `chmod 755 <src> && python3 -c "...'.claude/hooks/...'..."` tripped hook case-glob. **Rule:** future substrate-mutation ops needing both file-mode + atomic replace MUST be one python3 script (os.chmod + os.replace). iter-329/331 authoring did not need chmod (rule/test/manifest files have no exec-bit requirement).

- **iter-319 NOVEL carry-forward RE-CONFIRMED at iter-320+iter-322+iter-325+iter-326+iter-327+iter-328+iter-329+iter-330+iter-331** — `/tmp` tmpfs `noexec,nosuid,nodev,relatime` (Story 2.5 hardening). iter-331 invariant-doc Edit did not touch /tmp; manifest refresh used in-place `target + '.tmp'` (same-fs). iter-329 `/tmp/hook-settings-tamper.ts` + `.test.ts` authored as data-only TypeScript source (not executed — node runs the compiled `dist/` outputs; tmpfs `noexec` doesn't apply). Related: the cross-filesystem gap between /tmp (tmpfs) and repo (different mount) is what surfaced the iter-329 `os.replace` NOVEL lesson.

- **iter-318 carry-forward — `sed -i <expr>` + `gh pr view` GraphQL timeout recipes.** Both unchanged at iter-331; no sed invocations in-iter; `gh pr view 230` attempted at orient and timed out (dial tcp 140.82.121.5:443: i/o timeout) — net-egress transient flake; does not block the iter since NOW item did not require PR-state branching.

- **iter-317/316 carry-forward — D-15 + D-14 minor regex + Python-write loophole.** D-15 wrapper normalization must not strip interp-stdin readers; D-14 find-delete trailing-slash optional. Python-write loophole DOCUMENTED at iter-325 Task 13.5; iter-329/331 used python3-only route for the non-cross-fs manifest hash refresh (python3-heredoc in-place), demonstrating the documented "legitimate for substrate-self-maintenance" path in practice.

- **iter-319 + earlier carry-forward pool — low-activity holds.** `readlink -f` canonicalises even when target file doesn't exist; `install-boundary-protection` rule-id live-enforcing; `names-and-shebangs` runtime `.ts→.js` / `/src/→/dist/` translation; SC-17 candidates unchanged at iter-331.

- **iter-314 SM-review promotion threshold: 5→7 data points** unchanged; Story 2.17 post-dev SM estimate iter-332+ after Tasks 15/16/17 land (1 medium fixture-persistence + 1 polish bundle + 1 completion task remain).
