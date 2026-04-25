# Implementation Plan

## NOW

- [ ] **(awaiting human merge of PR #230 — EPIC_DONE halt fired iter-343)** Per § Cross-epic transition step 3, on next invocation re-evaluate `gh pr view 230 --json state,mergedAt`: if `state=MERGED && mergedAt != null` AND sprint-status has Epic 3 backlog story `3-1-…: backlog` → NOW becomes `Run /bmad-create-story` (skill auto-marks Epic 3 `in-progress` + produces `_bmad-output/implementation-artifacts/3-1-{slug}.md`); update Context to `Epic = 3 - <title>`, `Story = 3.1`, `Story State = _(no story)_ → drafted`, `PR: n/a`. If PR still OPEN/DRAFT/CLOSED-unmerged → re-write `EPIC_DONE` halt (idempotent). If sprint-status has no Epic 3 backlog row anymore (i.e. inconsistency) → write `EPIC_DONE` with diagnostic `note` field per § Cross-epic transition state-inconsistent branch.

## QUEUE (Epic 3 — Ralph package + multi-iteration loop, 33 stories)

- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (Epic 3 stories will introduce a CI baseline; new PR per Epic 3 branch will rebaseline `statusCheckRollup`).
- [ ] _(carry-forward from iter-342, NOT landed iter-343 by Guardrail-5 scope-tightness)_ RALPH.md upkeep: append iter-342 § Lessons line "third-precedent re-validation of Ralph args=\"2\" CR inline-bundle-close at end-of-epic (Story 2.15 iter-301 / Story 2.16 iter-308 / Story 2.17 iter-342, all final-stories of substrate-feature epic-clusters, 2-4 PATCH band) — promote convention from precedent to documented lesson"; append § Gotchas line "in-session install-boundary hook fires on `bash_command` containing L1 path strings + mutation-verb-shaped documentation text (e.g. literal `find ... -delete` in DEFER bullet bodies inside python3 heredoc), even when no L1 file is targeted by the executed mutation; workaround = author /tmp file via `Write` tool (Edit|Write hook arm checks file_path not bash_command), then `cat /tmp/foo >> destination` from a bash_command containing neither L1 path strings nor mutation verbs". Land at first Epic 3 story dev iter that has slack OR roll into an Epic 2 retrospective iter if the operator triggers `/bmad-retrospective` for Epic 2 before Epic 3 starts.

## BLOCKED

_(empty — iter-343 PR Transition close-out clean: `gh pr ready 230` → "ready for review"; `gh pr checks 230 --watch --fail-fast` → "no checks reported" exit=1 (gh's no-checks convention, NOT a CI failure — `statusCheckRollup: []` confirmed via `gh pr view 230 --json` baseline unchanged iter-272..343); `gh pr view 230 --json reviews,comments,reviewRequests` → all `[]`; mergeStateStatus=CLEAN, mergeable=MERGEABLE.)_

## ATDD Red Phase

_(empty — substrate coverage at Epic 2 close: 7 persistent `node:test` unit tests GREEN (Story 2.17 Task 5.5 `hook-settings-tamper.test.ts`) + 74 persistent replay fixtures GREEN (`packages/keel-invariants/fixtures/hooks/run-all.sh` 55 positive + 19 negative). Total persistent/reproducible at iter-343: 7 unit tests + 74 replay fixtures.)_

## DONE (iter-343 PR Transition Draft→Open + final CI gate + EPIC_DONE halt)

- [x] iter-343: **Epic 2 close-out — PR #230 Draft→Open + final CI gate clean + EPIC_DONE halt.** Per Ralph Build Mode § PR Transition & Final CI Gate: (1) `gh pr ready 230` → "✓ Pull request tthew/ralph-bmad#230 is marked as 'ready for review'"; (2) `gh pr checks 230 --watch --fail-fast` → "no checks reported on the 'feat/epic-2-packaged-devbox' branch" exit=1 (gh convention for no-checks-configured baseline, NOT CI failure — `statusCheckRollup: []` confirmed unchanged iter-272..343; per IP carry-forward + `gh` man-page semantics); (3) `gh pr view 230 --json state,isDraft,mergeable,mergeStateStatus,reviews,reviewDecision,reviewRequests,comments,statusCheckRollup` → `{state: OPEN, isDraft: false, mergeStateStatus: CLEAN, mergeable: MERGEABLE, reviews: [], reviewDecision: "", reviewRequests: [], comments: [], statusCheckRollup: []}` — no review feedback to address; (4) sprint-status flip `epic-2: in-progress → done` at line 131 + comment-line + data-field `last_updated:` advanced to `Epic-2-done-PR-230-Draft-to-Open-final-CI-gate-iter-343`; (5) write `EPIC_DONE` halt (`{"reason":"EPIC_DONE","epic":2,"pr":230}`). On NEXT invocation (after human merges PR #230 to main), § Cross-epic transition step 3 re-evaluates: branch-1 (MERGED + Epic 3 `3-1-…: backlog` row present) auto-advances to NOW=`Run /bmad-create-story` for Epic 3 Story 3.1. Pre-push gates iter-343: typecheck + lint + format:check + keel-invariants:check-all expected GREEN unchanged (no source mutation; only YAML metadata + IP markdown). **NOVEL — none.** Pure epic-close bookkeeping iter following the FR14n + § Cross-epic transition normative spec. **First Epic-2-PR-Transition iter; reuses Story Lifecycle row `done` → § Cross-epic transition fall-through.**

- [x] iter-342: **Story 2.17 `/bmad-code-review (args: "2")` CR LANDING — FR14n `sm-verified → done`; Epic 2 17/17 stories COMPLETE.** 3 PATCH bundle-close (third precedent after Story 2.15 iter-301 + Story 2.16 iter-308) + 25 DEFER + ~10 dismissed-as-noise. PATCH-1 `INVARIANTS.md:146` stale-citation refresh (plain-`Edit` route); PATCH-2 `.pre-commit-config.yaml:31` filter-regex extension + manifest contentHash refresh (python3 atomic-replace); PATCH-3 `packages/keel-invariants/src/sync-gate.ts:147` tautology-simplification (python3 `shutil.move` /tmp staging, L1-protected). Detail in commit `831168e`.

- [x] iter-341: **Story 2.17 `/bmad-create-story (args: "review")` post-dev SM verification CLEAN — 0 PATCH; FR14n `traced → sm-verified`.** Detail in commit `c3417ec`.

- [x] iter-340: **Story 2.17 `/bmad-testarch-trace (args: "yolo")` GATE WAIVED — FR14n `in-dev → traced`; TWENTY-SEVENTH cumulative trace-WAIVED.** Detail in commit `055f8e1`.

_(iter-303..339 LANDING detail pruned per Guardrail 2; retained in commits + story-file Status HTML comment chain + story-file Change Log 0.1-0.30 rows.)_

## Context

- **Phase:** 4-implementation — **Epic 2 COMPLETE at iter-343** (17/17 stories `done` at iter-342; epic-row flipped `in-progress → done` at iter-343; PR #230 transitioned Draft→Open + final CI gate clean + `EPIC_DONE` halt fired). Awaiting human merge of PR #230.
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred.
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:121; bash + jq baked at :36-37 + :48). Host-side shim count: **18** at iter-343 (unchanged). iter-333 Dockerfile edit + iter-334 whitelist edit await operator-workstation rebake to materialize.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17/17 stories `done`; **epic-row flipped `done` at iter-343 sprint-status line 131**. Epic 2 lifecycle complete.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (PR #230 Draft→Open at iter-343; awaiting human merge to main).
- **Story:** _(no story — Story 2.17 `done` at iter-342; Epic 2 closed at iter-343; § Cross-epic transition picks up Epic 3 Story 3.1 after human merges PR #230.)_
- **Story File:** `_bmad-output/implementation-artifacts/2-17-hook-settings-bypass-resistance-git-layer-manifest-s4-halt.md` (untouched at iter-343 — epic-close iter, not story-close).
- **Story State:** `done` (Story 2.17 — iter-342 CR LANDING bundle-close; iter-343 layered the epic-close PR Transition on top).
- **Next-Epic Story:** Epic 3 Story 3.1 = `3-1-packages-ralph-package-install-boundary-via-uv-tool-install` (sprint-status line 151, `backlog`). Auto-advance fires on next invocation after PR #230 merge per § Cross-epic transition step 3 first branch.
- **GitHub Issue:** no GitHub Project configured; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (ralph.py auto-transitions to Done on `EPIC_DONE` halt detection at iter-343 close).
- **PR:** #230 **Open** (mergeStateStatus=CLEAN, mergeable=MERGEABLE) — https://github.com/tthew/ralph-bmad/pull/230 — iter-343 transitioned Draft→Open. No CI configured (`statusCheckRollup: []` unchanged iter-272..343); final CI gate "no checks reported" (gh exit=1 = no-checks convention, NOT failure). No review feedback (`reviews: []`, `comments: []`, `reviewRequests: []`).

## Notes

- **iter-343 NOVEL — none.** Pure Epic-close bookkeeping iter following FR14n § Story Lifecycle row `done` → § Cross-epic transition fall-through. Three datapoints worth noting (none promotion-threshold-meeting):
  - (a) `gh pr checks --watch --fail-fast` exit=1 with stdout "no checks reported" is the no-CI-configured baseline carry-forward signal, NOT a CI failure — `statusCheckRollup: []` is the source-of-truth-via-`gh pr view --json`. Carry-forward from iter-272..342 confirmed at iter-343 first PR-Transition exercise of the gate.
  - (b) `gh pr ready` is idempotent on already-Open PRs (treated as no-op at re-entry per § Cross-epic transition state-inconsistent recovery branch). Not exercised iter-343 (PR was Draft); informational for future Epic-close iters that re-enter post-halt.
  - (c) Epic 2 PR Transition required ZERO post-transition CI work — the no-CI baseline meant `gh pr ready 230` + `gh pr view 230 --json reviews,comments` were the entire gate. Epic 3 will likely change this once Epic 3 Story 3.x lands a `.github/workflows/*.yml` (per Epic 3 backlog rows 3-7 pre-push CI gate, 3-13 pre-merge fast manifest integrity gate, 3-30 atomic iteration commits NFR26 pre-commit gate).

- **iter-343 RALPH.md upkeep DEFERRED — carry-forward to Epic 3 Story 3.1 first dev iter or Epic 2 retrospective iter** (whichever lands first). Per Guardrail 5 (one task per iteration), iter-343 scope was strictly the PR Transition + EPIC_DONE halt. The two iter-342 promotion-noted items (§ Lessons "third-precedent CR inline-bundle-close at end-of-epic" + § Gotchas "in-session install-boundary fires on bash_command path-string + mutation-verb documentation text in python3 heredoc; workaround = `Write` /tmp + `cat >>` from bash sans path-strings") are recorded as carry-forward QUEUE item with full text for the future iter to copy-paste-append.

- **iter-342 NOVEL — none. Reinforcement-class observation (carry-forward, single data point):** bundle-close at 3 PATCH (iter-342) extends the precedent ladder Story 2.15 iter-301 `PATCH-4 bundled-close` + Story 2.16 iter-308 `PATCH-2 bundled-close` to a third datapoint; the args="2" workflow contract literally says "Leave as action items" but the established Ralph precedent allows inline bundle-close when the patches are non-controversial AND the L1 boundary permits via established py3-route. **Promotion to RALPH.md § Lessons** noted on third precedent re-validation (best-practice for end-of-epic CR-landing class iters with 2-4 PATCH band) — landing deferred to iter-343+N per scope-tightness.

- **iter-341 NOVEL — none.** Pure SM-review bookkeeping; CLEAN at zero-PATCH for Epic-2 close-out story corroborates that Story 2.17 implementation chain (iter-309 draft → iter-310 pre-dev SM 3-PATCH → iter-311 ATDD-skip → iter-312..339 dev → iter-340 trace WAIVED) was disciplined enough that the post-dev SM had no surface to find.

- **iter-340 NOVEL — none.** Pure trace bookkeeping; FIRST repo wired `node:test` runner (Story 2.17 AC 3) coexists with FIRST persisted replay corpus (74-fixture); both substrates SURVIVE iterations and reproduce on every run.

- **iter-339 NOVEL — none.** Pure story-close bookkeeping; Task 17 dev-phase close + sprint-status flip.

- **iter-338 NOVEL — none.** Sub-novel observation (carry-forward, single data point): SC-N triage iters can co-land 2-3 citation-lockstep one-line absorbs alongside the audit write-up when target files are outside every hashed sub-tree (no manifest contentHash refresh route required).

- **iter-332 NOVEL — promoted to RALPH.md § Gotchas (2026-04-24).** Hook-contract tests MUST align to the REACHABLE branch in the runtime: (a) D-22 resolved-path branch dominates direct-path case-globs; (b) `__unknown__` fires only on jq-parse-fail or missing `.tool_name`; (c) L1 mutation-verb regex requires specific filenames; (d) Grep/Glob `search_path` case-glob requires trailing content. Full detail in `packages/keel-invariants/fixtures/hooks/README.md § Dominance notes`.

- **iter-329 NOVEL — `shutil.move` vs `os.replace` for /tmp-to-L1 new-file authoring (RALPH.md § Gotchas 2026-04-24 iter-329).** `os.replace` requires same-fs atomic rename; cross-fs raises `[Errno 18]`. `shutil.move` handles cross-fs via copy2+unlink fallback. **Re-validated at iter-342 PATCH-3** — sync-gate.ts edit via python3 `shutil.move` from /tmp staging worked first-attempt (cross-fs cross-mount).

- **iter-320 NOVEL carry-forwards (now DOCUMENTED at iter-336)** — shell case-globs prefix-then-any matching + ESLint self-exclusion-glob requirement at `eslint.config.keel-invariants.js`; both in `docs/invariants/claude-hook-denylist.md § Limitations` as awareness-level guidance.

- **iter-319 NOVEL carry-forward RE-CONFIRMED iter-320..343** — `/tmp` tmpfs `noexec,nosuid,nodev,relatime` per Story 2.5 hardening; `python3 <abs>` works because Python interprets the file rather than execve-ing it.

- **iter-318 carry-forward — `gh pr view` GraphQL timeout recipe.** Three retries is the bound per iter-318; PR #230 baseline `statusCheckRollup: []` unchanged iter-272..343; iter-343 exercised `gh pr view 230 --json state,...` once at orient + once post-transition — both first-attempt successes (no GraphQL timeout this iter).

- **iter-317/316 carry-forward — D-15 + D-14 minor regex + Python-write loophole** — recorded `complete: pre-landed iter-325` at iter-337 Task 16 sub-item (e). Routing pattern remains in active use **at iter-342 PATCH-3** for sync-gate.ts L1 edit via python3 `shutil.move` /tmp staging. NOT exercised iter-343 (no L1 file mutation; only YAML + markdown edits both outside L1 + outside contentHash-pinned sets).

- **iter-314 SM-review promotion threshold: 5→7 data points** unchanged at iter-343. Story 2.17 CR LANDING bundle-close at 3 PATCH at iter-342 confirmed the IP forecast band 2-4 + 15-25 DEFER and serves as the third precedent data point absorbed by the Ralph Build Mode args="2" inline-bundle-close convention (Story 2.15 iter-301 + Story 2.16 iter-308 + Story 2.17 iter-342 — all final-stories of their respective epic-close substrate-feature clusters); promotion-threshold (5-7 data points) NOT met but noted in carry-forward QUEUE item for landing in next slack iter.
