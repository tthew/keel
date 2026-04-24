# Implementation Plan

## NOW

- [ ] **Story 2.17 `/bmad-testarch-trace (args: "yolo")` — `in-dev → traced` AC→test coverage gate.** 27th cumulative trace iter (Epic-2 17-story chain continuation). **Forecast: WAIVED** per iter-311 ATDD-skip grounds-(ii)+(iii) + impl-time-smokes substrate-coverage substitute (iter-332 74 persisted replay fixtures + iter-329 7-test node:test suite — the FIRST `node:test` in-repo and genuine AC-3 S4 rule coverage evidence; the trace gate can cite these as meaningful coverage rather than a pure waiver). Traceability matrix will map AC 1-8 to concrete evidence sites: AC 1 → manifest entries at `packages/keel-invariants/src/invariants.manifest.ts` + sync-gate 41-entry walk; AC 2 → `sync-gate.ts` walker branches + `check-all` exit 0; AC 3 → 7 `node:test` tests @ `prompt-injection-rules/hook-settings-tamper.test.ts` (first repo `node:test`); AC 4 → `.ralph/config.toml:self_protection_halt_threshold=3` pin + `docs/invariants/claude-hook-denylist.md § Halt-threshold pin`; AC 5 → `docs/invariants/fork.md § Amendment-vs-fork decision tree` (Story 1.6 pre-existing) + 7-site AMEND Dev Notes pattern; AC 6 → `.claude/hooks/block-secret-access.sh` L1 rule + iter-315 end-to-end runtime verification + 74 fixture replays; AC 7 → `check-no-committed-dotfiles.ts` extension + hook `.claude/settings.*.json` case-glob; AC 8 → `docs/invariants/claude-hook-denylist.md § CI visibility contract` H3 section + Epic 14 forward-link. ~medium own-iter item per iter-311 ATDD-skip precedent density (10-40K tokens; trace skill reads story file + AC list + touched files). Closes out the `in-dev → traced` lifecycle transition per Story Lifecycle Decision Matrix.

## QUEUE (Story 2.17 lifecycle close + Epic 2 close-out)
- [ ] _(after traced)_ `/bmad-create-story (args: "review")` — post-dev SM `traced → sm-verified` per Story Lifecycle Decision Matrix; ~medium own-iter item.
- [ ] _(after sm-verified)_ `/bmad-code-review (args: "2")` — `sm-verified → done` per Story Lifecycle Decision Matrix; ~medium-to-large own-iter item (final-story CR at Epic 2 close usually accretes 2-4 PATCH + ~15-25 DEFER triage).
- [ ] _(after Story 2.17 `done`)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion fires `EPIC_DONE` halt; on re-entry auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..339).

## BLOCKED

_(empty — iter-339 Task 17 (Story file completion + sprint-status flip) landed cleanly. Verification gates matrix (15.2 sync-gate check-all + 15.3 prek run --all-files + 15.4 keel-invariants test 7/7 + 15.1-replay 74/74 fixtures) all GREEN. Story 2.17 `/bmad-dev-story` dev-phase FULLY COMPLETE — 17/17 top-level Tasks DONE.)_

## ATDD Red Phase

_(empty — iter-311 SKIP-WITH-GROUNDS-(ii)+(iii). Impl-time substrate coverage at Story 2.17 close: 397 cumulative smokes GREEN across iter-315..320 runs + 7 genuine `node:test` unit tests GREEN at iter-329 for Task 5 S4 rules + 74 persisted replay fixtures GREEN at iter-332 / re-replayed at iter-339 (`packages/keel-invariants/fixtures/hooks/run-all.sh` — 55 positive + 19 negative). Total persisted/reproducible at iter-339: 7 unit tests + 74 replay fixtures.)_

## DONE (iter-339 Task 17 Story file completion + sprint-status flip landed — Story 2.17 dev-phase FULLY COMPLETE)

- [x] iter-339: **Story 2.17 `/bmad-dev-story` CONTINUATION CLOSE — Task 17 (Story file completion + sprint-status flip) landed. 17/17 top-level Tasks DONE.** Verification gates matrix (Task 15.2-15.4 fold-in) all GREEN: (15.2) `pnpm keel-invariants:check-all` exit 0 on 41 manifest entries — 35 whole-file + 4 `hashScope`-flagged (`INV-claude-settings-deny-rules` jq-subtree + `INV-git-hooks-preservation` names-and-shebangs + 2 whole-file seed anchors) + tokens-sync clean; entry count cross-checked `node -e "import('@keel/keel-invariants').then(m => console.log(m.invariants.length))"` → `41`. (15.3) `./node_modules/.bin/prek run --all-files` — 8-hook PASS matrix: TypeScript type-check + ESLint + Prettier format:check + Claude PreToolUse hook syntax (Task 12) + NFR5a deny-list minimum-entry gate (Task 11.2) + Design-token schema + Design-token WCAG AA contrast all PASS + 1 SKIPPED (no matching files to check); prek invoked from `./node_modules/.bin/prek` path because devbox does NOT expose prek on `$PATH` (iter-333 Story 2.5 AMEND Dockerfile bakes `/usr/local/bin/prek` but has NOT been materialised by operator-workstation rebake per IP Context § Baked image carry-forward). (15.4) `pnpm --filter @keel/keel-invariants test` — 7/7 GREEN (38.96ms) via `node --test dist/prompt-injection-rules/hook-settings-tamper.test.js`: `s4-claude-hooks-tamper` 3 positive + 1 negative fork-extension-slot (AST-tier `jsonPathsChanged` augmentation on `.hooks.PostToolUse` edit) + `s4-git-hooks-tamper` 1 positive (`.git/hooks/` addition) + `s4-skip-permissions-injection` 1 positive + 1 safe-path sweep × 13-entry allow-list. (15.1 replay) `bash packages/keel-invariants/fixtures/hooks/run-all.sh` — `74 passed / 0 failed / 74 total` (iter-332 persisted corpus reproduces at iter-339 without drift). Story file mutations (all via plain-`Edit` tool on story file + sprint-status.yaml — both outside L1 + hook-self-protection ranges): (a) Dev Agent Record § Completion Notes List populated with iter-339 entry (Verification-gates matrix + Per-Task completion matrix 1-17 with landing-iter citations + Per-AC evidence matrix 1-8 with concrete artefact cross-refs + Pre-push quality gates summary); (b) File List § iter-316..iter-339 cumulative enumeration appended (substrate MODIFIED + enforcement-code MODIFIED + docs MODIFIED + NEW substrate modules + NEW persisted fixture corpus + iter-339 Task 17 close-out 4-file list); (c) Change Log row 0.28 appended; (d) Task 15 flipped `[~] → [x]` + 15.2/15.3/15.4/15.5 all `[ ] → [x]`; (e) Task 17 flipped `[ ] → [x]` + 17.1/17.2/17.3 all `[ ] → [x]`; (f) Status line lifecycle HTML comment extended iter-339 segment with terminal "Task 17 CLOSED" marker; Status moves `in-dev (partial) → in-dev`. Sprint-status: `_bmad-output/implementation-artifacts/sprint-status.yaml` `2-17-hook-settings-bypass-resistance-git-layer-manifest-s4-halt: ready-for-dev → review` + `last_updated: 2026-04-24 Story-2-17-review-iter-339 UTC`. Story 2.17 dev-phase FULLY COMPLETE: 17/17 top-level Tasks DONE; 17/17 sub-task sets DONE (1.4 / 3.4 / 12.3 unit-test sub-tasks properly DEFERRED to Epic 13 per Task 1.4 "no test runner wired" grounds; the one `node:test` suite that DID land is Task 5.5's 7-test S4 rule-suite — the first `node:test` use in-repo). Pre-push gates all GREEN at iter-339 post-edit re-verification: `pnpm -w typecheck` 16/16 cached + `pnpm -w lint` 16/16 cached + `pnpm -w format:check` clean + `pnpm keel-invariants:check-all` exit 0 on 41 entries unchanged. No substrate hook/settings/manifest contentHash sub-tree perturbation; no seed re-sync required; no manifest contentHash refresh route (story-file + sprint-status.yaml + IP + RALPH.md all outside every hashed path). **No novel gotcha / lesson / decision — pure story-close bookkeeping** following iter-338 / iter-337 / iter-335 / iter-330 discipline; brief signpost entry appended to RALPH.md § Signposts for next-Ralph orientation.

- [x] iter-338: Task 16 (story-spec) `deferred-work.md` Epic-1 + early-Epic-2 DEFER triage; 693 → 763 lines (+70); 45 absorbed / ~173 carry-forward / 0 obsolete; 2 inline citation-lockstep absorbs (`packages/devbox/README.md:966` dev-sudo + `INVARIANTS.md:134` Four → Five workflow contracts). Detail in commit `b11db59`.

- [x] iter-337: Task 16 sub-items (d)+(e) marker-only defer-record bundle; (d) iter-314 NOVEL runtime translation `defer: threshold-not-met`; (e) iter-317 NOVEL loophole `complete: pre-landed iter-325`. Detail in commit `c2bf002`.

- [x] iter-336: Task 16 sub-items (f)+(g) bundle — one-bullet append to `docs/invariants/claude-hook-denylist.md § Limitations`. Manifest `INV-claude-hook-secret-denylist-doc` contentHash refresh. Detail in commit `50851e3`.

- [x] iter-335: Task 16 sub-item (c) DEFERRED `defer: conditional-on-re-emergence`. Detail in commit `ba695d3`.

- [x] iter-334: Task 16 sub-item (b) — `release-assets.githubusercontent.com` whitelist addition. Detail in commit `8eb6817`.

- [x] iter-333: Task 16(a) substrate-bake prek native Rust binary in `packages/devbox/Dockerfile` (Story 2.5 AMEND). Detail in commit `353b9f0`.

- [x] iter-332: Task 15.1 — 74 persisted hook replay fixtures under `packages/keel-invariants/fixtures/hooks/`. Detail in commit `cdf4d79`.

- [x] iter-331: Task 9 CI visibility contract stub for Epic 14 consumer. Detail in commit `420f8c1`.

_(iter-303..330 LANDING detail pruned per Guardrail 2; retained in commits through `718276d` + story-file Status HTML comment chain + story-file Change Log 0.1-0.28 rows.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **16/17 stories done** (2.1-2.16) + **Story 2.17 `in-dev` at iter-339** (Epic-2 final story; dev-phase FULLY COMPLETE post-iter-339 Task 17 close; next iter = `/bmad-testarch-trace` → `in-dev → traced`).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred.
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:121; bash + jq baked at :36-37 + :48). Host-side shim count: **18** at iter-339 (unchanged). iter-333 Dockerfile edit + iter-334 whitelist edit await operator-workstation rebake to materialize (image stays at pre-iter-333 baseline; whitelist edit takes effect on next devbox container restart since whitelist is read at startup, not baked into image).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **16 done** (2.1-2.16); **1 in-dev** (2.17 — dev-phase FULLY COMPLETE at iter-339; 17/17 top-level Tasks DONE; lifecycle transitioning `in-dev → traced → sm-verified → done` via Story Lifecycle Decision Matrix).
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.17 — Hook + settings bypass-resistance (git-layer + manifest + S4 + halt).
- **Story File:** `_bmad-output/implementation-artifacts/2-17-hook-settings-bypass-resistance-git-layer-manifest-s4-halt.md` (~662 lines post-iter-339 Change Log 0.28 append + Status iter-339 segment append + lifecycle HTML comment iter-339 entry + Task 15 + 17 sub-tasks all marked `[x]` + Dev Agent Record iter-339 Completion Notes block + File List iter-316..iter-339 cumulative enumeration).
- **Story State:** `in-dev` — iter-340 NOW = `/bmad-testarch-trace (args: "yolo")` per § Story Lifecycle row `in-dev → traced`; 27th cumulative trace iter; likely WAIVED per Epic-2 17-story chain continuation + impl-time-smokes substitute (cumulative 7 `node:test` unit tests + 74 persisted replay fixtures).
- **GitHub Issue:** no GitHub Project configured; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..338).

## Notes

- **iter-339 NOVEL — none (promotion threshold unreached).** Pure story-close bookkeeping iter (Task 17 completion DoD + Dev Agent Record populate + sprint-status flip + Change Log final row). No substrate / hook / settings / manifest / seed mutation. Precedent: iter-301 Story 2.15 Task-17-equivalent CR-close vs. iter-308 Story 2.16 Task-17-equivalent CR-close; Story 2.17's Task 17 is a dev-phase close (not CR-close) because ATDD was SKIP-WITH-GROUNDS at iter-311 so the lifecycle chain is `dev-story → trace → post-dev SM → CR → done` with Task 17 at the `dev-story → trace` seam rather than at CR landing. No novel gotcha / lesson / decision — brief RALPH.md § Signposts entry appended for next-Ralph orientation.

- **iter-338 NOVEL — none (promotion threshold unreached).** Sub-novel observation (single data point — carry-forward): SC-N triage iters can co-land 2-3 citation-lockstep one-line absorbs alongside the audit write-up when target files are outside every hashed sub-tree (no manifest contentHash refresh route required; pure plain-`Edit` route on `INVARIANTS.md` + `packages/devbox/README.md` + `deferred-work.md`). Promotion to RALPH.md as iter-density best-practice on second re-validation. The 763-line `deferred-work.md` itself is now the principal SC-N close-out artefact for Story 2.17; future-Story analogous SC-N close-out tasks should target the same H2 append pattern.

- **iter-332 NOVEL — promoted to RALPH.md § Gotchas (2026-04-24).** Hook-contract tests MUST align to the REACHABLE branch in the runtime: (a) D-22 resolved-path branch dominates direct-path case-globs; (b) `__unknown__` fires only on jq-parse-fail or missing `.tool_name`; (c) L1 `find -delete` regex requires specific filenames; (d) Grep/Glob `search_path` case-glob requires trailing content. Full detail in `packages/keel-invariants/fixtures/hooks/README.md § Dominance notes`.

- **iter-329 NOVEL — `shutil.move` vs `os.replace` for /tmp-to-L1 new-file authoring (RALPH.md § Gotchas 2026-04-24 iter-329).** `os.replace` requires same-fs atomic rename; cross-fs raises `[Errno 18]`. `shutil.move` handles cross-fs via copy2+unlink fallback.

- **iter-320 NOVEL carry-forwards (now DOCUMENTED at iter-336)** — shell case-globs prefix-then-any matching + ESLint self-exclusion-glob requirement at `eslint.config.keel-invariants.js`; both in `docs/invariants/claude-hook-denylist.md § Limitations` as awareness-level guidance (Task 16 (f)+(g) bundle).

- **iter-319 NOVEL carry-forward RE-CONFIRMED iter-320..339** — `/tmp` tmpfs `noexec,nosuid,nodev,relatime` per Story 2.5 hardening; `python3 <abs>` works because Python interprets the file rather than execve-ing it.

- **iter-318 carry-forward — `gh pr view` GraphQL timeout recipe.** Three retries is the bound per iter-318; PR #230 baseline `statusCheckRollup: []` unchanged iter-272..338; iter-339 did NOT exercise `gh pr view` at orient (no CI checks running; step-5 CI gate will verify at push time).

- **iter-317/316 carry-forward — D-15 + D-14 minor regex + Python-write loophole** — recorded `complete: pre-landed iter-325` at iter-337 Task 16 sub-item (e). Routing pattern remains in active use.

- **iter-314 carry-forward** — `.ts→.js` / `/src/→/dist/` runtime translation in `loadExpectedHooks` recorded `defer: threshold-not-met` at iter-337 Task 16 sub-item (d); single-site fix at `manifest-reader.ts:93-108`; promotion deferred until a second site exercises the same translation.

- **iter-314 SM-review promotion threshold: 5→7 data points** unchanged. Story 2.17 post-dev SM estimate iter-341+ after `/bmad-testarch-trace` (iter-340) + `/bmad-create-story (args: "review")` (iter-341) per Story Lifecycle Decision Matrix chain.
