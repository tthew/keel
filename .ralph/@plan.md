# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story` — Story 2.13 drafting per § Story Lifecycle row `_(no story)_ → drafted`. Story 2.13 = "Healthcheck on dnsmasq + sshd — replaces upstream's broken `curl :3000` healthcheck" per sprint-status row at `_bmad-output/implementation-artifacts/sprint-status.yaml:124`. Skill auto-marks row `backlog → ready-for-dev` + produces story file `_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md`. Fresh-context skill invocation per CLAUDE.md § Claude Code specifics "one skill per context window" — Ralph queues it; `/bmad-create-story` executes end-to-end in its own context. Expected inputs from Story 2.13 Epic 2 spec + Story 2.12 carry-forward DEFERs (esp. D-2 `SSHD_PID` scoping + D-3 zombie reaping surface — Story 2.13's healthcheck design MUST account for both).

## QUEUE (Story 2.13 lifecycle + 2.14..2.17 substrate queue)

- [ ] _(iter-281, post-`/bmad-create-story`)_ Story 2.13 pre-dev SM validation: `/bmad-create-story (args: "review")` per matrix row `drafted → validated`. Forecast 1-3 PATCH typical pre-dev SM band (iter-266 precedent for novel-runtime-behaviour stories; 2.13 novel surface = healthcheck CMD lifecycle × sshd background × dnsmasq lifecycle intersection).
- [ ] _(after validated)_ `/bmad-testarch-atdd` per matrix row `validated → atdd-scaffolded`. Forecast: likely SKIP-WITH-GROUNDS-(c)+(ii)+(iii) per Story 2.12 iter-267 22nd-cumulative precedent (no test runner wired at substrate stage; live healthcheck exec requires real Docker).
- [ ] _(after atdd-scaffolded)_ `/bmad-dev-story (args: "{story_file_path}")` per matrix row `atdd-scaffolded → in-dev`. Scope: entrypoint.sh healthcheck exec + docker-compose.yml healthcheck stanza + potentially Dockerfile HEALTHCHECK directive + invariant doc + sync-gate manifest entry.
- [ ] _(after in-dev)_ `/bmad-testarch-trace (args: "yolo")` per matrix row `in-dev → traced` (forecast WAIVED per Story 2.12 iter-269 pattern).
- [ ] _(after traced)_ `/bmad-create-story (args: "review")` post-dev SM per matrix row `traced → sm-verified`.
- [ ] _(after sm-verified)_ `/bmad-code-review (args: "2")` per matrix row `sm-verified → done | fixes-pending` — three-layer Ralph-hosted adversarial fan-out (iter-271 pattern + iter-277 NOVEL LESSON #2 META guard carry-forward: if Auditor verdict contradicts Blind+Edge convergent finding on runtime-semantics, FAVOUR convergent + RUN EMPIRICAL TEST).
- [ ] _(after Story 2.13 done)_ Story 2.14 legacy branch retention policy — full lifecycle.
- [ ] _(after Story 2.14 done)_ Story 2.15 committed Claude settings.json deny/allow — full lifecycle.
- [ ] _(after Story 2.15 done)_ Story 2.16 Claude PreToolUse hooks for secret-file denylist — full lifecycle.
- [ ] _(after Story 2.16 done)_ Story 2.17 hook-settings bypass-resistance + Epic 2 SC-17 close-out polish pass. SC-17 reconciliation absorbs cumulative 11 DEFERs from iter-271 + 7 from iter-277 (post-iter-278 absorptions: 9-2=7 remaining) + 4 from iter-279 = **cumulative 22 Story 2.12 DEFERs** to reconcile, PLUS cumulative Epic 2 Story 2.13..2.16 DEFERs accrued during those stories.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured at 2026-04-24 per iter-219..279 confirmation; `statusCheckRollup: []` continues; iter-279 orient `gh pr view 230` initially HTTPS :443 timeout then retry GREEN — SSH :22 recovery asymmetry carry-forward from iter-263 LESSON).

## BLOCKED

_(none — Story 2.12 DONE at iter-279 CR closure re-run #2 ZERO-PATCH; branch in sync with origin at `947cbce`.)_

## ATDD Red Phase

_(none — iter-267 ATDD-skip-with-grounds-(c)+(ii)+(iii) per FR14n; 22nd-cumulative ATDD-skip precedent for Story 2.12; new ATDD decision for Story 2.13 forecast at iter-281-ish.)_

## DONE (iter-279 Story 2.12 CLOSURE — ZERO-PATCH; `fixes-pending → done`; sprint-status row `review → done`)

- [x] iter-279: **STORY 2.12 DONE — `/bmad-code-review (args: "2")` closure re-run #2 ZERO-PATCH.** Three-layer Ralph-hosted adversarial fan-out (Blind Hunter `general-purpose` diff-only, 0H/3M/3L; Edge Case Hunter `general-purpose` diff+project-read, 1H/2M/3L — HIGH walked into DEFER-class on close read; Acceptance Auditor `bmad-agent-architect` Winston diff+spec+context, ZERO-PATCH HIGH-confidence). Diff scope `HEAD~1..HEAD` = commit `947cbce` iter-278 PATCH-6 landing (175 insertions / 115 deletions across 5 files). **Triage: 0 PATCH + 4 DEFER + 7 DISMISS.** Single NOW task per Guardrail 5.

  - **Convergent mechanism confirmation:** rc-capture pattern `set +e; (set -e; ...); rc=$?; set -e; [[ rc -ne 0 ]] && diag` ACTUALLY propagates errexit because subshell is NOT on the LHS of `||` (followed by `;` then rc-capture) → bash(1) `||`-LHS recursive rule does NOT apply. Walked end-to-end by Auditor; Blind+Edge independently confirmed. Destructive PATCH-4 cascade (unconditional `rm -rf host_keys` on keygen failure) structurally closed.

  - **iter-277 NOVEL LESSON #2 META guard check:** Auditor agrees with Blind + Edge on mechanism (all three layers converge on ZERO-PATCH). No contradiction → no empirical-test override triggered. Guardrail remains codified for future runtime-semantics questions.

  - **4 DEFER carry-to-Story-2.17 (all orthogonal to PATCH-6 — pre-existing from iter-268 Task 3 or cosmetic future-guard class):** (D-1) sshd.log first-boot diagnostic gap — add `install -m 0644 -o root -g root /dev/null /var/log/sshd.log` to Dockerfile adjacent to dnsmasq.log pre-create (~1 line); (D-2) `SSHD_PID` scoped to subshell — Story 2.13 healthcheck design must not depend on it; (D-3) zombie reaping under `exec gosu dev` handoff — evaluate tini-as-PID-1 promotion vs `trap "wait" EXIT`; (D-4) "pre-gosu" comment vestige at entrypoint.sh:175 — cosmetic polish. None exploitable in default operator config.

  - **7 DISMISS (reasoning pinned in spec § Change Log v1.8 + deferred-work.md § iter-279 closure re-run #2):** Blind M1 "set +e / ( window" (zero live surface); Blind M2 "ssh_init_status mechanism" (self-resolved correct in Blind's own text); Blind L4 "sleep 0.5 racy" (pre-existing; Story 2.13 healthcheck scope); Blind L5 "|| true on tail redundant" (mechanism-correct); Blind L6 "rm/mv window" (self-healing per Blind's text); Edge L3 "entropy starvation" (acceptable per Edge's text); Edge L2 "PATCH-4 path correctness" (triple-negative confirmation; non-finding).

  - **Story State transition:** `fixes-pending → done`. Sprint-status row flipped `review → done` at `_bmad-output/implementation-artifacts/sprint-status.yaml:123` + yaml header `last_updated` line. Cumulative Story 2.12 metrics FROZEN at: 6 PATCHes (iter-271: 5 + iter-277: 1) within iter-271 LESSON 4-7 novel-runtime-behaviour band; 2 closure re-runs (iter-277 1-PATCH + iter-279 0-PATCH) matching iter-264 LESSON budget; 22 cumulative DEFERs (11 iter-271 + 7 remaining iter-277 post-iter-278-absorption + 4 iter-279) queued for Story 2.17 SC-17 reconciliation.

  - **PR:** #230 **Draft** — `statusCheckRollup: []` carries unchanged across iter-272..279; iter-279 orient `gh pr view 230` initially HTTPS :443 i/o timeout then retry GREEN — SSH :22 recovery asymmetry carry-forward from iter-263 LESSON (HTTPS :443 unreliable; SSH :22 typically reliable). Branch in sync with origin at `947cbce` pre-commit; about to push commit with Story 2.12 closure artifacts (spec Status `review → done` + Change Log v1.8 + sprint-status row `review → done` + deferred-work.md iter-279 block + IP + RALPH.md entry).

  - **Budget consumed:** ~55K tokens (orient ~8K + diff reads ~4K + three-layer fan-out ~30K via sub-agents + artifact edits ~7K + IP + RALPH.md + commit-prep ~6K stacking). Well within ~117K execution budget; exit cleanly per Guardrail 12.

- [x] iter-278: **STORY 2.12 PATCH-6 LANDED** — `packages/devbox/entrypoint.sh:141-211` rewritten to rc-capture subshell pattern; 2 iter-277 DEFERs absorbed. See commit `947cbce`.
- [x] iter-277: **STORY 2.12 CR CLOSURE RE-RUN #1 LANDED** — `/bmad-code-review (args: "2")` 1 PATCH (PATCH-6) + 9 DEFER + 3 DISMISS. See commit `3eadcff`. PATCH-6 landed iter-278; 2 of 9 DEFERs absorbed iter-278; 7 remain for Story 2.17 close-out.
- [x] iter-272..276: **STORY 2.12 PATCH-1..5 LANDED** — see commits `30b7d8d`/`1df64ab`/`0d83fae`/`820591a`/`43b4e4b`.
- [x] iter-271: `/bmad-code-review (args: "2")` — `sm-verified → fixes-pending`; 5 PATCH + 11 DEFER + ~10 DISMISS. See commit `a777224`.

_(iter-253..270 Story 2.10/2.11/2.12 closure + Story 2.12 drafting/pre-dev-SM/ATDD/dev-story/trace-gate/post-dev-SM iters pruned per Guardrail 2.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **12/17 stories done** (2.1-2.12) + 5/17 backlog (2.13..2.17). Epic 2 next story = 2.13 (healthcheck on dnsmasq + sshd).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live fresh-fork first-run smokes operator-workstation-deferred; substrate smokes covered through iter-279 (`pnpm keel-invariants:check` GREEN at `946f1ac1…907029` carried from iter-276; no contentHash edit this iter).
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:120). Host-side shim count: **18** at iter-279 (unchanged — no shim edits this iter; closure artifact-only).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **12 done** (2.1-2.12); 5 backlog (2.13..2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** _(no story — iter-280 will advance to Story 2.13 via `/bmad-create-story`)_
- **Story File:** n/a
- **Story State:** _(no story)_
- **GitHub Issue:** Story 2.12 issue unknown; `RALPH_ISSUE_NUMBER` unset at iter-279 orient. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` carried unchanged iter-272..279; iter-279 orient GREEN after HTTPS :443 retry).

## Notes

- **iter-279 meta-observation (ZERO-PATCH CR closure as-expected outcome pattern):** re-run #2 after a single-region PATCH landed at re-run #1 converges ZERO-PATCH in 2/2 Story 2.12 forecast cycles where it was predicted (iter-278 → iter-279). Pattern extends iter-264 LESSON multi-pass CR cycle to the single-region-PATCH sub-case — converge at re-run N+1 after the PATCH lands at re-run N. Generalises: after any non-zero PATCH closure re-run, the next closure re-run's forecast baseline is ZERO-PATCH unless the PATCH touched a region that surfaces new mechanisms.
- **iter-279 meta-observation (Edge Case Hunter HIGH graceful downgrade to DEFER on close read):** Edge Case Hunter initially flagged sshd.log first-boot as HIGH then walked the code path and self-downgraded to diagnostic-gap-only DEFER class within the same output block. This discipline (sub-agent walks its own flag before emitting) is consistent with iter-271 pattern where sub-agents are prompted to explicitly include "non-findings you walked and ruled out" section. Re-affirms iter-260 LESSON convergence-signal-high-confidence-triage: when reviewers self-qualify severity downward, triage should respect that.
- **iter-278 meta-observation carry-forward (DEFER absorption discipline):** a PATCH that re-touches a region with queued cosmetic DEFERs should ABSORB those DEFERs into the patch. Iter-278 absorbed 2 iter-277 DEFERs successfully. Iter-279 CR did NOT ship a PATCH so no new absorption pattern to record; formalise as a Ralph convention when the next PATCH re-touches a DEFERred region (e.g. Story 2.17 close-out pass SHOULD absorb 22 cumulative Story 2.12 DEFERs into its own PATCH rather than filing new DEFERs).
- **iter-277 NOVEL LESSON #1 carry-forward (bash subshell `||`-LHS errexit suppression is recursive):** confirmed stable at iter-279 — the rc-capture pattern was reviewed by three independent layers and all three confirmed the mechanism correct. LESSON remains load-bearing for Stories 2.13..2.17 / Epic 6 / Epic 13 "wrap risky block for non-fatal posture" patterns.
- **iter-277 NOVEL LESSON #2 carry-forward (META empirical-test override):** guard did NOT fire at iter-279 (all three layers converged). Guard remains codified for future runtime-semantics questions. Prior-pass PATCH-6 emergence was the canonical instance; iter-279 is the first case where it was not triggered since codification — healthy signal that the guard is calibrated (not every CR re-run forces empirical override).
- **iter-276 NOVEL LESSON carry-forward (hazard-class discrimination under word-splitting):** stable at iter-279 — no new word-splitting hazard surfaced. Story 2.13 healthcheck may introduce new word-splitting vectors if it composes HEALTHCHECK CMD with shell expansion; carry-forward advisory.
- **iter-276 observation carry-forward (contentHash edit cost model):** iter-279 did NOT touch any contentHash-tracked source (no code edits this iter — closure artifact-only). `pnpm keel-invariants:check` GREEN carried from iter-276 at `946f1ac1…907029`.
- **iter-273 NOVEL LESSON carry-forward (compose env-propagation sites are normalisation chokepoints):** stable at iter-279. Story 2.13 healthcheck likely WILL introduce new compose-level env propagation (HEALTHCHECK CMD may source env vars) — carry-forward advisory for Story 2.13 pre-dev SM gate.
- **iter-272 LESSON carry-forward (orient-time PATCH order decision framework):** not applicable at iter-279 (no PATCHes to order).
- **iter-271 NOVEL LESSON carry-forward (forecast band breach via novel-runtime-behaviour surface):** Story 2.12 cumulative 6 PATCHes within 4-7 band. Story 2.13 forecast carry-forward: healthcheck runtime lifecycle × dnsmasq signal × sshd background is MODERATE novel-runtime-behaviour surface; pre-budget 3-5 first-class PATCH at CR even with clean SM gates.
- **iter-271 LESSON carry-forward (three-subagent pattern):** iter-279 ZERO-PATCH outcome REINFORCES the pattern — Blind + Edge + Auditor three-layer fan-out handles convergence cleanly even when re-run #2 is expected to close; pattern evolution with iter-277 META guard remains healthy.
- **iter-270 NOVEL LESSON carry-forward (drift-band re-baseline):** substrate-citation drift BIMODAL; iter-279 added 0 new substantive (closure artifact-only; no doc-spec change). Cumulative Epic 2 remaining substantive: 0 new beyond iter-278 inventory.
- **iter-264 LESSON carry-forward:** CR re-run DEFER-vs-PATCH severity-class-first; Story 2.12 closed within 0-3 first-class PATCH band at re-run #2 (ZERO-PATCH outcome). Precedent extends: 4-7 novel-runtime-behaviour band cap @ iter-271 confirmed achievable + closeable within 2 closure re-runs.
- **iter-263 LESSON carry-forward:** SSH :22 / HTTPS :443 asymmetric recovery; iter-279 HTTPS :443 i/o timeout on first orient → retry GREEN → SSH :22 push forecast clean. Pattern stable.
- **iter-257 LESSON reaffirmed (no contentHash edit at iter-279):** no sync-gate recompute; `pnpm keel-invariants:check` GREEN carried from iter-276 unchanged.
- **iter-244/246 audit-findings carry-forward:** restart.sh transitive-delegate; benchmark.sh OUT-OF-SCOPE (SC-11) threading compose-override; Manifest entry count **32** at iter-279 (unchanged).
- **Substrate-citation drift cumulative forecast for Stories 2.13..2.17:** ~5-12 cumulative substantive + ~40-60 cumulative mechanical drifts. SC-17 single reconciliation at Story 2.17 landing. Story 2.12 cumulative drift count post-iter-279: 22 cumulative DEFERs (11 iter-271 + 7 remaining iter-277 post-iter-278-absorption + 4 iter-279) — largest single-story DEFER pile in Epic 2 to date, reflecting novel-runtime-behaviour surface.
