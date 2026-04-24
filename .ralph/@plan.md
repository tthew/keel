# Implementation Plan

## NOW

- [ ] **Story 2.17 `/bmad-dev-story` CONTINUATION** (`in-dev (partial)` — 8 of 17 Tasks / subtrees landed across iter-312 + iter-314; 9 remaining). Per § Story Lifecycle Decision Matrix row `atdd-scaffolded` continuation. **iter-315 NOW candidate: Task 7 (L1 install-boundary hook rule)** — XL, own-iter per LLM-guardrail #1 "apply in small groups / no self-immolation risk". Hook-surface editing requires pre-install `bash -n` + careful denylist growth; projected 40-60K budget.

## QUEUE (Story 2.17 continuation + lifecycle close + Epic 2 close-out)

- [ ] _(after Task 7)_ Task 8 (.claude/settings.local.json pre-commit rejection + hook self-protection pattern) + Task 10.2 D-2/D-4/D-5/D-8 permissions-layer edits (small bundle).
- [ ] _(after Task 10.2)_ Task 10.1 D-12..D-36 (25 items; 3-4 iters own decomposition per LLM-guardrail #1 "small groups with `bash -n` after each").
- [ ] _(after Task 10.1)_ Task 11 (D-7/D-8/D-9 lints) + Task 13 (docs sibling-append AGENTS.md/CLAUDE.md/packages/devbox/README.md including Task 2.3 fork-extension-slot doc) + Task 14 (seed lockstep) + Task 5 (S4 rules) + Task 6 (halt-threshold doc pin + config.toml verify) + Task 9 doc pins + Task 15 (≥25 impl-time fixture smokes) + Task 16 (SC-17 polish) + Task 17 (completion).
- [ ] **SC-17 close-out candidates** queued for Task 16: (a) substrate-bake prek native binary in Dockerfile (Story 2.5 AMEND) so fresh-fork devbox first-boot works without network access — addresses iter-313 BLOCKED class; (b) add `release-assets.githubusercontent.com` to substrate `packages/devbox/whitelist/github.txt` so operator doesn't need manual `pnpm devbox:whitelist add`; (c) host-OS-aware `.git/hooks/*` config portability (if iter-312 gotcha re-emerges on fresh fork); (d) iter-314 NOVEL CANDIDATE: promote `loadExpectedHooks` runtime path translation into a generic "source-to-dist resolver" if further TS-authored enumerator entries land (currently 1 site — threshold not met).
- [ ] _(after Story 2.17 Tasks fully landed)_ `/bmad-testarch-trace (args: "yolo")` — `in-dev → traced`. 27th cumulative trace; likely WAIVED per Epic-2 17-story chain continuation + impl-time-smokes substitute; MAY apply PARTIAL-AC ground-(c) variant-(ii) on AC 3/AC 4/AC 8 behavioural signals.
- [ ] _(after traced)_ `/bmad-create-story (args: "review")` — post-dev SM `traced → sm-verified`.
- [ ] _(after sm-verified)_ `/bmad-code-review (args: "2")` — `sm-verified → done`.
- [ ] _(after Story 2.17 `done`)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..314).

## BLOCKED

_(empty — iter-313 cleared the prek cache-eviction BLOCKED; iter-314 sync-gate runtime gap in `loadExpectedHooks` resolved inline via minimal `.ts`→`.js` path translation, not deferred.)_

## ATDD Red Phase

_(empty — iter-311 SKIP-WITH-GROUNDS-(ii)+(iii); no red-phase scaffolds authored. Impl-time substrate coverage: iter-312 landed `check-claude-hook-syntax.ts` with shebang-aware dispatch; iter-314 exercised `names-and-shebangs` walker end-to-end via sync-gate. Task 15.1's ≥25 impl-time fixture smokes + Task 3.4/5.5/7.5/11/12.3 subtask-level smokes remain deferred per Story 2.17 spec.)_

## DONE (iter-314 PARTIAL CONTINUATION)

- [x] iter-314: **Story 2.17 `/bmad-dev-story` PARTIAL CONTINUATION** — Tasks 2 + 3.2 + 3.3 + 4 + 12.2 landed; manifest 35 → 39 entries. **Task 2** registered `INV-claude-settings-deny-rules` with `jq-subtree` filter covering `.permissions.deny` + `.hooks.PreToolUse` substrate-authoritative sub-trees (initial hash `c33844c4…137b`). **Tasks 3.2 + 3.3** registered `INV-git-hooks-preservation` (`names-and-shebangs`, hash `cb27263d…e829` from `sort(name\tshebang)` over `commit-msg` + `pre-commit`) + sibling `INV-git-hooks-preservation-enumeration` (whole-file sha256 `e5ff4a32…c35d`; same sourcePath as names-and-shebangs entry — legitimate per superRefine distinct-hashScope rule). **Task 4 Option B executed:** existing `INV-claude-hook-secret-denylist` sourcePath repointed from invariant doc to hook script (`eb5f2d3a…b8c`); new sibling `INV-claude-hook-secret-denylist-doc` carries the invariant-doc drift protection (`118d956c…9330`). **Task 12.2** landed § Pre-install discipline + § Story 2.17 git-layer backstop table + Limitations rewire in `docs/invariants/claude-hook-denylist.md`. **INVARIANTS.md** gained new H3 § Hook + settings bypass-resistance (Story 2.17) with 4 anchor bullets. **Micro-scope sync-gate runtime fix:** `loadExpectedHooks` gained `.ts → .js` / `/src/ → /dist/` path translation — required because Node's dynamic `import()` can't read TS source; preserves the Dev Notes sourcePath===enumeratorPath convention while making it work at runtime. Pre-push gates all GREEN (typecheck 16/16; lint 16/16; format:check clean; sync-gate exit 0 on 39 entries; claude-hook-syntax exit 0).

_(iter-303..313 LANDING detail pruned per Guardrail 2; retained in commits through `0f91844` + story-file Status HTML comment chain + story-file Change Log 0.1-0.4 rows.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **16/17 stories done** (2.1-2.16) + **Story 2.17 `in-dev (partial)` at iter-314** (Epic-2 final story; XL partial landing — 8 of 17 Tasks / subtrees landed across iter-312 + iter-314; 9 remaining).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred.
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:121; bash + jq baked at :36-37 + :48). Host-side shim count: **18** at iter-314 (unchanged).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **16 done** (2.1-2.16); **1 in-dev (partial)** (2.17 — 8 of 17 Tasks / subtrees landed).
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.17 — Hook + settings bypass-resistance (git-layer + manifest + S4 + halt).
- **Story File:** `_bmad-output/implementation-artifacts/2-17-hook-settings-bypass-resistance-git-layer-manifest-s4-halt.md` (~560 lines post-iter-314).
- **Story State:** `in-dev (partial)` — iter-315 NOW = `/bmad-dev-story` CONTINUATION per § Story Lifecycle dev-story invocation guidance; NOW candidate Task 7 (L1 install-boundary hook rule).
- **GitHub Issue:** no GitHub Project configured; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..314).

## Notes

- **iter-314 NOVEL LESSON CANDIDATE — `names-and-shebangs` runtime path translation.** The `sourcePath === enumeratorPath === TS source file` convention documented in Dev Notes is correct as a DRIFT-ANCHOR contract, but the runtime `loadExpectedHooks` helper must translate `.ts → .js` / `/src/ → /dist/` to actually import the module under Node's ESM. Single-site fix at `manifest-reader.ts:93-108` suffices; no changes needed to the Dev Notes or the sourcePath. Promotion threshold: 2 data points (iter-314 is first; next `names-and-shebangs` entry — if any — promotes to `docs/invariants/fork.md § Content-hash scoping` or inline as a `loadExpectedHooks` helper doc-string).
- **iter-314 rate-pattern data point — 4 Tasks/iter sustained for narrow-infra continuation.** iter-312 landed 3 Tasks (Task 1 + 3.1 + 12.1 — schema + enumeration + syntax-check); iter-314 landed 5 subtrees (Task 2 + 3.2 + 3.3 + 4 + 12.2 — 4 manifest entries + 1 doc pin). Both "narrow-infra non-hook-surface" iters per LLM-guardrail #1. Confirms iter-312 forecast of 6-8 iters to full Story 2.17 landing (Task 7 next = hook-surface XL = 1-2 Tasks/iter expected). Projected 4-6 iters to full Story 2.17 landing from iter-314 end.
- **iter-314 carry-forward — narrow-after-SM-absorb 5→7-data-point STABLE LESSON promotion threshold:** unchanged. Story 2.17 post-dev SM (iter-316+ post-full-landing) remains promotion gate.
- **iter-314 carry-forward — `hashScope` schema extension architectural decision now EMPIRICALLY VALIDATED at runtime.** Both `jq-subtree` + `names-and-shebangs` walker branches exercised end-to-end iter-314; all 39 entries clean. Promotion from story Dev Notes to `docs/invariants/fork.md § Content-hash scoping` remains scheduled for Story 2.17 close.
- **iter-314 SC-17 close-out candidates carry forward** unchanged (prek native binary bake, release-assets whitelist, host-OS-aware git-hooks config). iter-314 adds (d): evaluate generic source-to-dist resolver if more TS-authored enumerator entries land.
