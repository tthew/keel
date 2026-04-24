# Implementation Plan

## NOW

- [ ] **Story 2.17 `/bmad-dev-story` CONTINUATION** (`in-dev (partial)` — now at 3/17 Tasks post iter-312 + 0 additional post iter-313 recovery). Per § Story Lifecycle Decision Matrix row `atdd-scaffolded` continuation. iter-314 bundled scope: **Task 2 (.claude/settings.json sub-tree jq-subtree registration) + Tasks 3.2-3.4 + Task 4 (4 new manifest entries: 35→39) + Task 12.2 (doc pin for claude-hook-syntax rule)** — all manifest/doc surface, non-hook-surface, no self-immolation risk per LLM-guardrail #1. Bundle chosen per iter-312 signpost + IP QUEUE ordering guidance. Projected budget: ~30-40K implementation fits within ~80K post-orient envelope.

## QUEUE (Story 2.17 continuation + lifecycle close + Epic 2 close-out)

- [ ] _(after iter-314 manifest bundle)_ Task 7 (L1 install-boundary hook rule — XL, own-iter per LLM-guardrail #1 "apply in small groups").
- [ ] _(after Task 7)_ Task 8 (.claude/settings.local.json denylist) + Task 10.2 D-2/D-4/D-5/D-8 permissions-layer edits (small bundle).
- [ ] _(after Task 10.2)_ Task 10.1 D-12..D-36 (25 items; 3-4 iters own decomposition per LLM-guardrail #1).
- [ ] _(after Task 10.1)_ Task 11 (D-7/D-8/D-9 lints) + Task 13 (docs sibling-append) + Task 14 (seed lockstep) + Task 5 (S4 rules) + Task 6 + 9 doc pins + Task 15 (≥25 impl-time fixture smokes) + Task 16 (SC-17 polish) + Task 17 (completion).
- [ ] **SC-17 close-out candidates** queued for Task 16: (a) substrate-bake prek native binary in Dockerfile (Story 2.5 AMEND) so fresh-fork devbox first-boot works without network access — addresses iter-313 BLOCKED class; (b) add `release-assets.githubusercontent.com` to substrate `packages/devbox/whitelist/github.txt` so operator doesn't need manual `pnpm devbox:whitelist add`; (c) host-OS-aware `.git/hooks/*` config portability (if iter-312 gotcha re-emerges on fresh fork).
- [ ] _(after Story 2.17 Tasks fully landed)_ `/bmad-testarch-trace (args: "yolo")` — `in-dev → traced`. 27th cumulative trace; likely WAIVED per Epic-2 17-story chain continuation + impl-time-smokes substitute; MAY apply PARTIAL-AC ground-(c) variant-(ii) on AC 3/AC 4/AC 8 behavioural signals.
- [ ] _(after traced)_ `/bmad-create-story (args: "review")` — post-dev SM `traced → sm-verified`.
- [ ] _(after sm-verified)_ `/bmad-code-review (args: "2")` — `sm-verified → done`.
- [ ] _(after Story 2.17 `done`)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..313).

## BLOCKED

_(empty — iter-312 BLOCKED cleared at iter-313 via prek binary cache transplant from sibling worktree; see § DONE iter-313 entry + RALPH.md Signposts 2026-04-24.)_

## ATDD Red Phase

_(empty — iter-311 SKIP-WITH-GROUNDS-(ii)+(iii); no red-phase scaffolds authored. Impl-time substrate coverage: iter-312 landed `check-claude-hook-syntax.ts` with shebang-aware dispatch as a live pre-commit gate (operator-verifiable). Task 15.1's ≥25 impl-time fixture smokes + Task 1.4/3.4/5.5/7.5/11/12.3 subtask-level smokes remain deferred per Story 2.17 spec.)_

## DONE (iter-313 RECOVERY + iter-312 PARTIAL LANDING bundled)

- [x] iter-313: **RECOVERY — BLOCKED cleared + iter-312 staged work landed (15-file commit).** Root cause of iter-312 BLOCKED: `node_modules/@j178/prek/node_modules/.bin_real/prek` was empty in main workspace — cache eviction, not egress-whitelist gap as iter-312 IP hypothesised. Sibling worktree `.claude/worktrees/blog-post/node_modules/.pnpm/@j178+prek@0.3.9/.../.bin_real/prek` retained functional `prek 0.3.9` (Apr 13 mtime; pre-dating the eviction event). Recovery sequence: (a) `cp` from sibling → main `.bin_real/` — no network access needed; (b) `prek install --hook-type pre-commit --hook-type commit-msg` — rewrote `.git/hooks/pre-commit` + `.git/hooks/commit-msg` with correct Linux path `/workspace/ralph-bmad/node_modules/.pnpm/@j178+prek@0.3.9/.../.bin_real/prek`. Hooks now fully functional. **Corrects iter-312 GOTCHA claim:** `git config core.hooksPath` at iter-313 orient returned `/workspace/ralph-bmad/.git/hooks` (Linux, correct) — iter-312's "macOS host absolute path" claim was stale pre-devbox-restart observation; hooks don't silently no-op, they fail-closed when prek binary cache evicted. **Additional pollution cleanup:** `.pnpm-store/` + `design_handoff_*/` added to `.prettierignore` + `.gitignore` (untracked repo-root artifacts were blocking format:check); minimal `prettier --write packages/devbox/README.md` for ambient whitespace drift (table-alignment; unrelated to iter-312 work). **Pre-push quality gates all GREEN iter-313:** `pnpm -w typecheck` ✓ (16 tasks); `pnpm -w lint` ✓ (16 tasks, 0 errors); `pnpm -w format:check` ✓ (post ignore-file updates + README.md rewrite); `pnpm --filter @keel/keel-invariants build` ✓; `node dist/check.js` sync-gate ✓ exit 0 (35 entries clean); `node dist/check-claude-hook-syntax.js` ✓ exit 0.
- [x] iter-312: **STORY 2.17 `/bmad-dev-story` PARTIAL** (Tasks 1 + 3.1 + 12.1 of 17). Staged at iter-312; landed at iter-313 per above recovery. Scope summary: Task 1 extended `InvariantSchema` with optional `hashScope` discriminated-union (`jq-subtree` / `anchor-range` / `names-and-shebangs`); added 4 helpers to `manifest-reader.ts`; extended `sync-gate.ts` walker; back-compat verified. Task 3.1 authored `prek-hook-manifest.ts` with `EXPECTED_HOOKS: readonly ExpectedHook[]`. Task 12.1 authored `check-claude-hook-syntax.ts` with shebang-aware dispatch (NOVEL FINDING absorbed: bash shebang → bash -n; sh shebang → bash -n + dash -n) + wired `keel-invariants:claude-hook-syntax` bin + `.pre-commit-config.yaml` hook entry. Sync-gate hash refresh: 3 pre-existing entries invalidated + updated (`INV-prek-pre-commit-config`, `INV-prek-commit-msg-config`, `INV-prek-prepare-lifecycle`).

_(iter-303..311 LANDING detail pruned per Guardrail 2; retained in commits `441d710` / `7c89ff1` / `128e1b7` / `efde582` / `dfe14fd` / `1fa09ff` / `04cca7e` / `3d3105f` / `369bc2b` + story-file Status HTML comment chain + story-file Change Log 0.1-0.3 rows.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **16/17 stories done** (2.1-2.16) + **Story 2.17 `in-dev (partial)` at iter-313** (Epic-2 final story; XL partial landing — 3 of 17 Tasks; 14 Tasks remaining).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred.
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:121; bash + jq baked at :36-37 + :48). Host-side shim count: **18** at iter-313 (unchanged — recovery iter touching keel-invariants substrate + top-level ignore config only).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **16 done** (2.1-2.16); **1 in-dev (partial)** (2.17 — 3/17 Tasks landed iter-312, landed via commit at iter-313).
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.17 — Hook + settings bypass-resistance (git-layer + manifest + S4 + halt).
- **Story File:** `_bmad-output/implementation-artifacts/2-17-hook-settings-bypass-resistance-git-layer-manifest-s4-halt.md` (~540 lines post-iter-312 partial annotation).
- **Story State:** `in-dev (partial)` — iter-314 NOW = `/bmad-dev-story` CONTINUATION per § Story Lifecycle dev-story invocation guidance.
- **GitHub Issue:** no GitHub Project configured; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..313).

## Notes

- **iter-313 NOVEL LESSON CANDIDATE — sibling-worktree cache transplant as BLOCKED recovery pattern.** When a binary-download-on-first-run shim (prek, etc.) fails under devbox fail-closed egress, check sibling worktrees under `.claude/worktrees/` for cached binaries before triggering operator-gated whitelist amendments. Cost: `cp` + `<tool> install` (~seconds). Value: full iter unblock without operator round-trip. Applicable to any npm-wrapped-rust-binary class. Promotion threshold: 2 data points (iter-313 is first; next occurrence promotes to RALPH.md § Lessons).
- **iter-313 NOVEL LESSON CANDIDATE — iter-312 GOTCHA claim CORRECTED.** iter-312 observed `core.hooksPath` returning macOS host absolute path + claimed hooks silently no-op in-container. iter-313 observed `core.hooksPath` returning correct Linux path (`/workspace/ralph-bmad/.git/hooks`). Most likely explanation: devbox restart between iters regenerated `.git/config`. **REVISED model:** hooks fail-CLOSED when prek binary cache evicted (exec returns non-zero → git aborts commit), NOT silently no-op. The "6 commits with broken lint since iter-305" observation is still VALID but explained by: lint failed → prek fail → those commits must have happened OUTSIDE the devbox (on operator workstation where macOS path resolved) OR between cache populations. Mitigation stands: run quality gates manually before commit in the devbox as defense-in-depth.
- **iter-313 carry-forward from iter-312 — NOVEL FINDING absorbed in Task 12.1 (shebang-aware dispatch)** preserved. Any future hook-syntax-check spec must specify shebang-aware dispatch, NOT blanket bash-AND-dash.
- **iter-313 carry-forward — 27th cumulative ATDD-skip chain sustained.** No change at iter-313 (recovery iter, not ATDD gate).
- **iter-313 carry-forward — `hashScope` schema extension architectural decision validated at iter-312, unchanged at iter-313.** 3-variant discriminated union cleanly encodes the 3 substantive fork-extension semantics. Promotion from story Dev Notes to `docs/invariants/fork.md` § Content-hash scoping at Story 2.17 full-landing close.
- **iter-313 carry-forward — narrow-after-SM-absorb 5→7-data-point STABLE LESSON promotion threshold:** unchanged. Story 2.17 post-dev SM (iter-315+ post-full-landing) remains promotion gate.
- **iter-313 carry-forward — Task decomposition validated under XL budget pressure.** iter-312 landed 3 Tasks in ~45K impl budget; iter-313 recovery consumed ~25K budget (binary transplant + quality gate fixes + IP + RALPH.md signpost + commit). Projected remaining 5-7 iters to full Story 2.17 landing. Rate-pattern observation candidate remains pending 2 more data points (iter-314 + iter-315 XL continuation iters).
- **iter-313 SC-17 close-out candidates queued** (see QUEUE block). Three concrete candidates: (a) pre-bake prek native binary in Dockerfile, (b) add `release-assets.githubusercontent.com` to substrate whitelist, (c) host-OS-aware `.git/hooks/*` config portability. Absorbed into Task 16 polish-pass scope at Story 2.17 close-out.
