# Implementation Plan

## NOW

- [ ] Re-run `/bmad-code-review (args: "2")` — Story State `fixes-pending → done | fixes-pending` confirmation gate after iter-261 PATCH-1 landing. Three-layer Ralph-hosted adversarial fan-out per § Story Lifecycle Decision Matrix row `fixes-pending → done | fixes-pending`. Expected closure pattern per iter-253 LESSON + iter-260 NOVEL LESSON: ZERO new first-class PATCH + possibly 0-1 new second-class DEFER → `done`. If NEW convergent-across-2-of-3-layers findings surface, re-enter `fixes-pending` with new QUEUE entries. Patch surface to re-review (now pushed): resolver one-liner + docstring + AGENTS.md + devbox-mode.md (two sites) + story Change Log v1.5 + manifest contentHash. Sprint-status row UNCHANGED at `review` on PATCH re-run; only confirmation `done` flips sprint.

## QUEUE (Story 2.11 CR closure → Stories 2.12..2.17 → Epic 2 close-out)

- [ ] _(after Story 2.11 `done`)_ Iterate Stories 2.12..2.17 through full lifecycle — 6 remaining substrate stories spanning loopback-bound port publication + healthcheck + legacy branch + settings + hooks + bypass-resistance. Per § Cross-epic within-epic route, auto-advance continues without halt as long as sprint-status has backlog rows.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; next iter on re-entry auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured at 2026-04-24 per iter-219..262 repeated pre-push confirmation — `gh pr view 230` returns `statusCheckRollup: []`; iter-260..263 pre-flight `gh pr view` hit HTTPS :443 timeout — transient, not a CI gate).

## BLOCKED

_(none — iter-261/262 SSH :22 BLOCKED cleared at iter-263 step-1 `git push origin feat/epic-2-packaged-devbox` exit 0; `f9db54a..e835913` pushed to remote. HTTPS :443 pre-push probe still timing out but is not a gate; no CI configured on PR #230.)_

## ATDD Red Phase

_(none — Story 2.11 ATDD-skipped at iter-256 per grounds (c)+(ii)+(iii); iter-258 trace gate WAIVED; iter-259 post-dev SM ZERO-PATCH + 2 MINOR drift DEFERs; iter-260 CR closure 1-PATCH + 16 DEFER + 44 DISMISS; iter-261 PATCH-1 landed; iter-263 BLOCKED cleared.)_

## DONE (iter-263 BLOCKED cleared + iter-261 PATCH-1 pushed; Story 2.11 State stays `fixes-pending` QUEUE-emptied pending CR re-run)

- [x] iter-263: **BLOCKED cleared — SSH :22 recovered.** Step-1 action per iter-262 § NOW recovery branch: retried `timeout 60 git push origin feat/epic-2-packaged-devbox` → exit 0. Three unpushed commits (`d8ee3a2` iter-261 PATCH-1 impl + `a52f231` iter-261 BLOCKED docs + `e835913` iter-262 BLOCKED-carry-forward docs) landed on remote in one push (`f9db54a..e835913`). Pre-flight `gh pr view` still hit HTTPS :443 timeout (30s exit 124) — consistent with iter-260..262 pattern; not a push gate (PR #230 has `statusCheckRollup: []`, no CI configured). Carry-forward count reset 2 → 0. Total BLOCKED duration: iter-261 → iter-262 → iter-263 recovery = 2 full iters carry-forward, matching iter-249..258 precedent (3-iter max before considering HTTPS-over-proxy fallback). iter-263 impl surface: push + IP edits (NOW advancement + BLOCKED clearance + DONE condensation) + RALPH.md iter-263 signpost prepend + this commit. No code, no docs beyond IP/RALPH.md. Budget consumed ~6-8K tokens. Next iter re-runs `/bmad-code-review (args: "2")` for `fixes-pending → done | fixes-pending` confirmation gate.
- [x] iter-261: STORY 2.11 PATCH-1 LANDING — SC-4 opinionated-shared-mode posture extended to `REPO_NAME`. Resolver one-liner + docstring + three-site doc lockstep (AGENTS.md + `docs/invariants/devbox-mode.md` × 2) + manifest contentHash rebuild (`4ddc4e… → 0647445…` at `invariants.manifest.ts:277`) + sync-gate clean + story file v1.5 Change Log. Closes convergent-across-2-of-3-layers iter-260 CR finding (Winston #5 Blind + Edge E6 Edge on silent-override class). Commits `d8ee3a2`/`a52f231`/`e835913` pushed at iter-263; sprint row unchanged at `review`.

_(iter-253..260 Story 2.10 closure + Story 2.11 create-story / pre-dev SM / ATDD-skip / dev-story / trace / post-dev SM / CR iters pruned per Guardrail 2 — see Story 2.11 § Change Log v1.0..v1.5 + RALPH.md Signposts iter-253..263 for per-gate detail. iter-262 BLOCKED-carry-forward entry pruned per Guardrail 2; the resolution at iter-263 subsumes it.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **10/17 stories done** (2.1-2.10) + 1/17 in review (2.11 at state `fixes-pending` post-PATCH-1 QUEUE-emptied; sprint row unchanged at `review`) + 6/17 backlog (2.12..2.17).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live fresh-fork first-run smokes operator-workstation-deferred; substrate smokes covered at iter-248 9/9 + iter-252 9/9 + iter-257 6/6 + iter-259 adversarial SM + iter-260 three-layer adversarial CR + iter-261 PATCH-1 one-liner sync-gate clean + iter-263 push recovery.
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:119). Host-side shim count: **18** at iter-263 (unchanged since iter-261 — PATCH-1 one-liner in resolver + doc lockstep; no shim count delta).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **10 done** (2.1-2.10); 1 in-review at state `fixes-pending` post-PATCH-1 (2.11); 6 backlog (2.12..2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.11 — Per-fork vs shared devbox mode (`KEEL_DEVBOX_SHARED`)
- **Story File:** `_bmad-output/implementation-artifacts/2-11-per-fork-vs-shared-devbox-mode-keel-devbox-shared.md`
- **Story State:** `fixes-pending` — Story 2.11 PATCH-1 landed at iter-261, pushed at iter-263 (resolver one-liner + three-site doc lockstep + manifest contentHash rebuild + sync-gate clean). QUEUE emptied. Next iter re-runs `/bmad-code-review (args: "2")` for `fixes-pending → done | fixes-pending` confirmation gate.
- **GitHub Issue:** Story 2.11 likely unwired (`RALPH_ISSUE_NUMBER` unset at iter-263 orient; skipping `Refs #<story-issue>` in commits per § Issue Tracking guard). Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out, NOT iter-263).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — last confirmed `{"isDraft":true,"mergeStateStatus":"CLEAN","state":"OPEN","statusCheckRollup":[]}` at iter-259 orient; iter-260..263 pre-flight `gh pr view 230` hit HTTPS :443 timeout (`dial tcp 140.82.*:443: i/o timeout`). Transient network fluctuation per iter-249..263 pattern; no CI configured so not a push gate — iter-263 push via SSH :22 succeeded cleanly despite HTTPS :443 flake.

## Notes

- **iter-263 LESSON — SSH :22 / HTTPS :443 asymmetric recovery.** At iter-263 recovery, SSH :22 push succeeded (`exit 0`) while HTTPS :443 `gh pr view` still hit `dial tcp 140.82.*:443: i/o timeout` (30s exit 124). Confirms iter-249..258 precedent: the two transport paths recover independently. Push via SSH is the primary progress vector; `gh pr view` HTTPS timeout is non-blocking when PR has no CI (empty `statusCheckRollup`). Future BLOCKED recovery should always attempt the push first regardless of HTTPS state; only if SSH :22 is also timing out should carry-forward apply. Promote to RALPH.md § Lessons this iter.
- **iter-261 LESSON — PATCH-surface-well-scoped-compact-iter pattern** (~15-20K tokens). Single-task-per-iter + single-source-of-truth patch discipline enables compact patch-and-exit iters when the PATCH surface is well-scoped: one-liner code change + three-site doc lockstep + manifest contentHash rebuild.
- **iter-260 LESSONS carry-forward:** (1) three-layer adversarial fan-out convergence signal (2-of-3 layer overlap = high-confidence PATCH); (2) Blind Hunter false-positive class #1 (unset-array-access under `set -u` without REQUIRED_VARS fence verification); (3) iter-259 two-subagent post-dev SM pattern distinct from CR three-layer adversarial lens.
- **iter-259 LESSONS carry-forward unchanged:** (1) post-dev SM two-subagent pattern; (2) D2 architecture.md:547 7-site cascade pattern — pre-existing deferred; (3) partial-waive trace-gate vocabulary absence; (4) manifest rebuild required after new InvariantSchema entry OR contentHash update.
- **iter-258 partial-waive trace-gate LESSON + iter-257 shared-mode operator-override INTENTIONAL ignore (SC-4)** remain relevant — SC-4 posture NOW EXTENDED to both `CONTAINER_NAME` + `REPO_NAME` per iter-261 PATCH-1.
- **iter-244/246 audit-findings carry-forward** unchanged: (1) restart.sh transitive-delegate prepend-only; (2) benchmark.sh OUT-OF-SCOPE clarification (SC-11); (3) Manifest entry count **31** post-Story-2.11 (corrected from off-by-one "30" in story file per Amelia F1 / AR-76 defer); (4) Alpine egress non-applicability doctrine.
- **Substrate-citation drift cumulative forecast for Stories 2.11..2.17 unchanged:** iter-260 totals (2 MINOR + 5 SC-17 deferrals = 7 items for Story 2.11 alone) hold. Cumulative Epic 2 forecast: ~23-34 cumulative line-number drifts + 2-3 substantive citation-claim misplacements. SC-17 scope holds: single reconciliation pass at Story 2.17 landing. Deferred-work.md remains at 562 lines — iter-261..263 added no new AR entries.
