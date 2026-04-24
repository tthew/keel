# Implementation Plan

## NOW

- [ ] **Story 2.17 `/bmad-dev-story` CONTINUATION — Task 16 sub-item (b) — whitelist `release-assets.githubusercontent.com` in `packages/devbox/whitelist/github.txt`** — one-line addition to the operator-workstation runtime egress allow-list so GitHub-release-asset downloads (e.g. re-installing prek from source if the substrate binary disappears on an exotic host, or future bake-at-runtime operator scripts) succeed without manual `pnpm devbox:whitelist add` each time. Companion to iter-333 Dockerfile substrate-bake: the Dockerfile curl lands at *build time* outside the runtime firewall; the whitelist addition handles the *runtime* egress path for post-bake operator flows. One file, one line. No manifest / hook / seed perturbation — `packages/devbox/whitelist/github.txt` is not a hashed sub-tree. ~small.

## QUEUE (Story 2.17 Task-16 remainder + lifecycle close + Epic 2 close-out)

- [ ] Task 16 sub-item (c) — host-OS-aware `.git/hooks/*` config portability doc (CONDITIONAL — only if iter-312 `core.hooksPath` macOS/Linux gotcha re-emerges on a fresh fork; low priority since iter-313 clarified the iter-312 observation was stale pre-devbox-restart state). If skipped this iter, record `defer: conditional-on-re-emergence` with pointer to iter-312 RALPH.md entry and move on.
- [ ] Task 16 sub-item (f) — iter-320 NOVEL reader-verb word-boundary anchoring pattern documentation — one-paragraph addition to `docs/invariants/claude-hook-denylist.md § Limitations` noting the case-glob prefix-then-any matching semantics and the regex word-boundary workaround (single data point; promotion threshold unreached — document as a "Limitations" entry not as a formal rule). Doc-only plain-`Edit` route.
- [ ] Task 16 sub-item (g) — iter-329 sub-novel `eslint.config.keel-invariants.js` self-exclusion-glob pattern documentation — one-sentence extension to the same `§ Limitations` paragraph noting that rule-authoring modules detecting their own literal needle (e.g. `--dangerously-skip-permissions`, `--no-verify`) require glob-scoped self-exclusion in the ESLint config. Doc-only plain-`Edit` route. Likely bundled with (f).
- [ ] Task 16 sub-items (d) + (e) — iter-314 NOVEL docs-promotion threshold (1 site; unmet) + iter-317 NOVEL carry-forward (iter-325 § L1 install-boundary rule § Substrate-maintenance loophole narrative already landed) — marker-only; record `defer: threshold-not-met` + `complete: pre-landed iter-325` in IP respectively and prune.
- [ ] Task 16 (story-spec) — `deferred-work.md` triage: Epic-1 (Stories 1.8-1.16) + early-Epic-2 (Stories 2.1-2.14) DEFER audit per story-file Task 16.1-16.4 (target 15-25 absorbed citation-lockstep items + cumulative Epic 2 DEFER balance < 30 at close). Distinct from the IP's "SC-17 polish bundle" label — this is the story-spec scope proper. Medium-large own-iter item.
- [ ] Task 17 (completion): close out Story 2.17 `in-dev (partial) → in-dev` once Task 16 fully lands + verify sub-tasks 15.2/15.3/15.4/15.5 (re-run `pnpm keel-invariants:check-all` 41 entries + `pre-commit run --all-files` + `pnpm --filter @keel/keel-invariants test` 7/7 GREEN + populate Completion Notes with per-AC evidence). Ensure story DoD complete + Dev Agent Record populated + Change Log final row.
- [ ] _(after Story 2.17 Tasks fully landed)_ `/bmad-testarch-trace (args: "yolo")` — `in-dev → traced`. 27th cumulative trace; likely WAIVED per Epic-2 17-story chain continuation + impl-time-smokes substitute. Exception: iter-329 Task 5 authored 7 genuine `node:test` unit tests (the first keel-invariants tests in-repo), so SM review can cite them as AC-3 coverage evidence and trace does not have to waive for Task 5.
- [ ] _(after traced)_ `/bmad-create-story (args: "review")` — post-dev SM `traced → sm-verified`.
- [ ] _(after sm-verified)_ `/bmad-code-review (args: "2")` — `sm-verified → done`.
- [ ] _(after Story 2.17 `done`)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion fires `EPIC_DONE` halt; on re-entry auto-advances to Epic 3 Story 3.1.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..332).

## BLOCKED

_(empty — iter-333 Task 16(a) substrate-bake prek in Dockerfile landed uneventful; all pre-push gates GREEN.)_

## ATDD Red Phase

_(empty — iter-311 SKIP-WITH-GROUNDS-(ii)+(iii). Impl-time substrate coverage: 397 cumulative smokes GREEN across iter-315..320 runs + 7 genuine `node:test` unit tests GREEN at iter-329 for Task 5 S4 rules + 74 persisted replay fixtures GREEN at iter-332 (`packages/keel-invariants/fixtures/hooks/run-all.sh` — 55 positive + 19 negative). Total persisted/reproducible at iter-333: 7 unit tests + 74 replay fixtures. Task 15.1 DONE.)_

## DONE (iter-333 Task 16(a) substrate-bake prek in Dockerfile)

- [x] iter-333: **Story 2.17 `/bmad-dev-story` PARTIAL CONTINUATION — Task 16 sub-item (a) — Story 2.5 AMEND — substrate-bake prek native Rust binary in `packages/devbox/Dockerfile`.** 23-line arch-aware `RUN` block inserted after git-delta release-asset block (`Dockerfile:212`) and before Playwright deps block; pattern matches git-delta + supabase-cli + aws-cli fail-fast structure (iter-128 CR AI-6 consistency). `curl … github.com/j178/prek/releases/download/v0.3.9/prek-${prek_arch}.tar.gz | tar | install -m 0755 /tmp/prek /usr/local/bin/prek` with `prek_arch ∈ {x86_64,aarch64}-unknown-linux-gnu` via `uname -m`; fail-closed `exit 1` on unsupported arch; `prek --version` probe ensures install drift fails the RUN. Pin `v0.3.9` locked-step with root `package.json` `devDependencies["@j178/prek"]`. **Closes iter-313 BLOCKED class** — fresh-fork devbox first-boot no longer needs GitHub-releases network egress to re-populate an evicted `node_modules/.pnpm-store` prek cache; operator recovery becomes `prek install -t pre-commit -t commit-msg` against the substrate binary to rewrite `.git/hooks/*`. **No image rebake in-session** — Dockerfile edit lands in git; `keel-devbox:local` rebake deferred to operator-workstation per Story 2.5 baseline. **No substrate hook / settings / manifest / seed perturbation** — Dockerfile outside every hashed path. Pre-push gates all GREEN: `pnpm -w typecheck` 16/16 (0.509s); `pnpm -w lint` 16/16 (1.246s); `pnpm -w format:check` clean; `pnpm keel-invariants:check-all` exit 0 on 41 entries unchanged. **NOW bundle decomposition**: sub-item (b) whitelist `release-assets.githubusercontent.com` promoted to iter-334 NOW (small); sub-items (c) conditional + (d-g) doc-only items routed to QUEUE per Guardrail 9 (one task per iteration). Net post-iter-333: **3 top-level Tasks remain — 15 (15.2-15.5 fold into Task 17), 16 (polish bundle — sub-items b-g remain in QUEUE + story-spec deferred-work.md triage), 17 (completion)**. No novel gotcha / lesson / decision — mechanical substrate-pattern-match exercise.

- [x] iter-332: Task 15.1 (bash-fixture persistence under `packages/keel-invariants/fixtures/hooks/` — 74/0/74 GREEN). Detail in commit `cdf4d79`.

- [x] iter-331: Task 9 (CI visibility contract stub for Epic 14) — invariant-doc § CI visibility contract H3 section + manifest contentHash refresh `486e6ee1ec6e…` → `cb32195fc573…`. Detail in commit `420f8c1`.

- [x] iter-330: Task 6 (halt-threshold verify-pass) — pure-verify iter with no file mutation. Detail in commit `718276d`.

- [x] iter-329: Task 5 (S4 prompt-injection scan rules) — three `high`-severity rules + 7 `node:test` GREEN. Detail in commit `58e2ff9`.

_(iter-303..328 LANDING detail pruned per Guardrail 2; retained in commits through `58e2ff9` + story-file Status HTML comment chain + story-file Change Log 0.1-0.22 rows.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **16/17 stories done** (2.1-2.16) + **Story 2.17 `in-dev (partial)` at iter-333** (Epic-2 final story; XL partial landing continuing through Task 16 sub-item (a) DONE + remaining Tasks 16/17).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred.
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:121; bash + jq baked at :36-37 + :48). Host-side shim count: **18** at iter-333 (unchanged). Dockerfile edit at iter-333 awaits operator-workstation rebake to materialize (image stays at pre-iter-333 baseline until rebake).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **16 done** (2.1-2.16); **1 in-dev (partial)** (2.17 — Task 10.1 iter-320 complete; Task 13 iter-325 complete; Task 11 iter-327 complete; Task 14 iter-328 complete; Task 5 iter-329 complete; Task 6 iter-330 complete; Task 9 iter-331 complete; Task 15.1 iter-332 complete; Task 16(a) iter-333 complete; 3 top-level Tasks remain: 15 (15.2-15.5 fold into Task 17), 16 (polish bundle 16(b-g) + story-spec deferred-work.md triage), 17).
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.17 — Hook + settings bypass-resistance (git-layer + manifest + S4 + halt).
- **Story File:** `_bmad-output/implementation-artifacts/2-17-hook-settings-bypass-resistance-git-layer-manifest-s4-halt.md` (~573 lines post-iter-333 Change Log 0.22 append + Status iter-333 segment append + lifecycle HTML comment iter-333 entry).
- **Story State:** `in-dev (partial)` — iter-334 NOW = `/bmad-dev-story` CONTINUATION per § Story Lifecycle dev-story invocation guidance; NOW item Task 16 sub-item (b) whitelist addition (small).
- **GitHub Issue:** no GitHub Project configured; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..333).

## Notes

- **iter-333 NOVEL — none (promotion threshold unreached).** Mechanical substrate-bake Dockerfile AMEND following established arch-aware release-asset fail-fast pattern (iter-128 CR AI-6 baseline) — precedent in same Dockerfile for supabase-cli (`Dockerfile:176-191`), git-delta (`:196-212`), and aws-cli (`:152-163`). Sub-novel observation: Dockerfile AMENDs during later-story dev-story are a documented practice when the AMEND is narrowly substrate-fix-scoped and closes a concrete BLOCKED incident class (iter-313 BLOCKED here); the change is tagged "Story 2.5 AMEND" in the Change Log narrative but lands in the Story 2.17 dev-story commit since it's motivated by SC-17 close-out. Pattern-match exercise only; no RALPH.md promotion.

- **iter-332 NOVEL — single data point promoted to RALPH.md § Gotchas (2026-04-24 iter-332).** Hook-contract tests MUST align to the REACHABLE branch in the runtime, not to source-order case precedence. Four devbox-runtime reachability learnings: (a) D-22 resolved-path branch dominates direct-path case-globs; (b) `__unknown__` fires only on jq-parse-fail or missing `.tool_name`; (c) L1 `find -delete` regex requires specific filenames, not dir; (d) Grep/Glob `search_path` case-glob requires trailing content. Full detail in `packages/keel-invariants/fixtures/hooks/README.md § Dominance notes`. Single data point; promotion to rule-type on second re-validation.

- **iter-331 NOVEL — none (promotion threshold unreached).** Mechanical invariant-doc amendment + manifest contentHash refresh following established iter-325/329 docs-amend-plus-python3-heredoc discipline. Sub-novel observation: the "verify-pass, likely additive edit if drift found" NOW pattern is a repeated one-shot motif for contract-pin tasks (iter-330 Task 6 pure-verify; iter-331 Task 9 verify-then-additive).

- **iter-330 NOVEL — none (pure-verify pass with no file mutation).**

- **iter-329 NOVEL — `shutil.move` vs `os.replace` for /tmp-to-L1 new-file authoring (recorded in RALPH.md § Gotchas 2026-04-24 iter-329).** `os.replace` requires same-fs atomic rename; when `/tmp` is tmpfs and the repo is on a different mount, the call raises `[Errno 18] Invalid cross-device link`. `shutil.move` handles cross-fs automatically via copy2+unlink fallback.

- **iter-328..326 NOVEL carry-forward — low-activity or promotion-threshold-unreached** (mechanical lockstep audit / NFR5a gate / negative-smoke harness pattern). Detail in iter-332 IP § Notes chain preserved through commit history.

- **iter-320 NOVEL carry-forward — shell case-globs match prefix-then-any, not word-boundary-anchored.** `case "$normalized" in rm*.claude/settings*) ...` matches `rmdir .claude/settings.json` (FP). Fix via regex `[[ "$normalized" =~ ^rm([[:space:]]|$) ]]`. **Rule:** new case-glob-based rule authoring inside `.claude/hooks/*.sh` MUST use word-boundary regex for any verb with common-prefix collision risk. Single data point at iter-320 for D-35 restructure; still unreached at iter-333. Documentation target: Task 16 sub-item (f).

- **iter-320 NOVEL carry-forward — `chmod` command prefix FP-blocks seed-sync pattern.** Bash command `chmod 755 <src> && python3 -c "...'.claude/hooks/...'..."` tripped hook case-glob. **Rule:** future substrate-mutation ops needing both file-mode + atomic replace MUST be one python3 script (os.chmod + os.replace). Still unreached at iter-333.

- **iter-319 NOVEL carry-forward RE-CONFIRMED iter-320..333** — `/tmp` tmpfs `noexec,nosuid,nodev,relatime` (Story 2.5 hardening). iter-333 Dockerfile edit did not touch /tmp runtime (build-time `/tmp/prek.tar.gz` lands at Docker build layer, unaffected by runtime noexec mount). Related: cross-filesystem gap between /tmp (tmpfs) and repo (different mount) is what surfaced iter-329 `os.replace` NOVEL lesson.

- **iter-318 carry-forward — `sed -i <expr>` + `gh pr view` GraphQL timeout recipes.** Both unchanged at iter-333; no sed invocations in-iter; `gh pr view 230` at orient retried-on-timeout one-shot workflow pattern held again.

- **iter-317/316 carry-forward — D-15 + D-14 minor regex + Python-write loophole.** D-15 wrapper normalization must not strip interp-stdin readers; D-14 find-delete trailing-slash optional. Python-write loophole DOCUMENTED at iter-325 Task 13.5; iter-329/331 used python3-only route for the non-cross-fs manifest hash refresh (python3-heredoc in-place).

- **iter-319 + earlier carry-forward pool — low-activity holds.** `readlink -f` canonicalises even when target file doesn't exist; `install-boundary-protection` rule-id live-enforcing; `names-and-shebangs` runtime `.ts→.js` / `/src/→/dist/` translation; SC-17 candidates unchanged at iter-333.

- **iter-314 SM-review promotion threshold: 5→7 data points** unchanged; Story 2.17 post-dev SM estimate iter-334+ after remaining Tasks 16/17 land (3 decomposed QUEUE items + story-spec Task 16 + completion).
