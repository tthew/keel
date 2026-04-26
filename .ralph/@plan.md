# Implementation Plan

## NOW

- [ ] Re-run `/bmad-code-review (args: "2")` — CR-pass-3 to confirm `fixes-pending → done` per FR14n matrix after PATCH-10 + PATCH-11 + PATCH-12 fix-arc complete (forecast 0 residual after sweep-completion carry-rule applied — PATCH-10/11/12 closed all line-233/241/174 sites at iter-422/423/424). ~medium

## QUEUE (Story 1.21 CR-pass-3 → Epic 1 reclose)

- [ ] Re-close Epic 1 (`epic-1: in-progress → done` after Story 1.21 closes); transition PR #236 Draft→Open final CI gate per § PR Transition & Final CI Gate; on success: write `EPIC_DONE` halt; on next invocation post-merge § Cross-epic transition advances to next available epic OR writes `ALL_EPICS_DONE` if no next epic.

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty — Story 1.21 ATDD-skipped iter-400 via FR14n § ATDD-skip pure ground (a) substrate-verification per IP § ATDD Skip Rationale; no red-phase tests authored.)_

## DONE (current story phase only — pruned at iter-424; older fix-arc detail in RALPH.md signposts)

- [x] iter-424: **Story 1.21 CR-pass-2 PATCH-12 LANDED — single-iter clean PATCH (3rd + FINAL of 3-PATCH CR-pass-2 fix-arc).** Single Edit at story file `1-21-…md:174` § Audit methodology: dropped trailing clause "; per-story event counts are recorded in the test-debt.md catalogue rows" — `test-debt.md` row schema (Skip ground / AC class / Effort / Risk class / Source / Carry-to) has no event-count field; deflection promised non-existent data. Sentence now ends at "multi-event skips." Resolves Edge#1 from iter-421 CR-pass-2. PATCH-12 action-item checkbox flipped `[ ]` → `[x]` at story file line 481 with "Landed iter-424" annotation. Pre-push CI gate at step 0h: LADDER step 1 first-try clear (`gh pr checks 236` returned both PASS for iter-423 PATCH-11 push origin SHA `4561b56` — node 1m3s + python 13s; run 24957531806; 39th cumulative api.github.com datapoint, **recovery from iter-423 4-rung NO-recovery sub-class (d)** confirms sub-class is intermittent not persistent). Sweep-completion carry-rule applied: pre-Edit `grep -n "per-story event counts"` confirmed line 174 was the only PATCH-12-scoped occurrence (lines 481 + 512 are CR-action-item / Change Log historical records, scope-excluded per established precedent). All gates GREEN at step 4: typecheck 16/16 (FULL TURBO 132ms), lint 16/16 (FULL TURBO 123ms), build 17/17 (FULL TURBO 237ms), keel-invariants 10 files / 52 tests in 879ms (sync-gate.test.ts 5 tests included; 4-drift baseline UNCHANGED — 0 NEW drift from cosmetic .md edit), pytest 4/4 in 0.22s. **CR-pass-2 fix-arc COMPLETE (3 of 3 PATCH landed iter-422/423/424).** Cumulative pre-merge PATCH Story 1.21 lifecycle: **22** projected (UNCHANGED from iter-422 forecast revision; PATCH-12 landed within envelope). NOW advances to CR-pass-3 invocation per FR14n `fixes-pending` row QUEUE-empty exit condition (PATCH-10/11/12 all `[x]`; QUEUE drained). Forecast residual envelope post-iter-424: **22 final** (CR-pass-3 expected 0 residual — sweep-completion carry-rule applied at all 3 PATCH; cosmetic completeness only). **Path forward:** CR-pass-3 (iter-425; forecast 0 residual) → Epic 1 reclose + PR #236 Draft→Open final CI gate + EPIC_DONE halt → § Cross-epic transition on next invocation post-merge.

- [x] iter-422 + iter-423: PATCH-10 + PATCH-11 LANDED (1st + 2nd of 3-PATCH CR-pass-2 fix-arc). PATCH-10 at story file:233 (forecast SM-validate row "23"→"24" + "30 cross-links"→"27"); PATCH-11 at story file:241 ("~30 cross-link edits"→"27"). Both single-iter clean. iter-423 surfaced api.github.com 4-rung NO-recovery sub-class (d) 2nd surfacing — fall-through-to-work permitted via ORIGIN-SHA-already-GREEN clause; confirmed intermittent at iter-424 (LADDER step 1 first-try clear). Detail in RALPH.md signposts.

- [x] iter-421: **Story 1.21 CR-pass-2 PASS — 9 findings (3 PATCH + 1 DEFER + 5 DISMISSED).** FR14n `fixes-pending → fixes-pending` (stays — 3 NEW PATCH raised). Auditor: "CR-pass-2 clean. Story 1.21 ready for `fixes-pending → done` flip" + Edge surfaced 2 missed-sweep residuals + 1 deflection clarification. **NEW carry-rule:** Sweep-completion carry-rule (1st datapoint of CR-pass-N sweep-completion class) — when CR-pass-N PATCH targets a count-drift, sweep ALL occurrences via `grep -n` before claiming done; otherwise CR-pass-(N+1) catches residuals. PATCH-10/11/12 are this rule's first surfacing.

- [x] iter-409..420: Story 1.21 CR-pass-1 fix-arc PATCH-1..9 (9 of 9 LANDED) + multi-deferred-push tracker drains. Audit + sweep class CR-pass-1 envelope datapoint 9 PATCH (mid-band of 0–9 forecast). 14 cumulative network-flake deferred-push datapoints across iter-372 SSH-egress class + 28 across api.github.com class. Detail in RALPH.md signposts.

- [x] iter-404: **Story 1.21 `/bmad-code-review (args: "2")` CR-pass-1 — 23 findings → 9 PATCH + 6 DEFER + 8 DISMISSED.** FR14n `sm-verified → fixes-pending`. All 6 ACs reconfirmed satisfied at operative-test level.

- [x] iter-401..403: Story 1.21 dev-story (iter-401 0 PATCH; FR14n `atdd-scaffolded → in-dev → review`) → trace (iter-402 0 PATCH; `in-dev → traced`) → SM-verify (iter-403 2 PATCH; `traced → sm-verified`).

- [x] iter-398..400: Story 1.21 drafted (iter-398) → SM-validated (iter-399 7 PATCH; `drafted → validated`) → ATDD-skipped pure ground (a) substrate-verification (iter-400; `validated → atdd-scaffolded`).

- [x] iter-1: `/bmad-correct-course` on issue #233 — Sprint Change Proposal; Epic 1 REOPENED for Stories 1.17–1.21.

## Context

- **Phase:** 4-implementation — Story 1.21 CR-pass-2 PATCH-12 LANDED iter-424 (3rd + FINAL of 3-PATCH fix-arc); 0 PATCH remaining; CR-pass-3 next.
- **Runtime:** cc-devbox iteration env. `uv 0.11.7` + `pnpm` available. Python 3.12.3 satisfies `requires-python = ">=3.10"`. github.com / api.github.com network access intermittent (api-egress-flake class — 39 cumulative datapoints at iter-424 step 0h: LADDER step 1 first-try clear, datapoint 39, **recovery from iter-423 NO-recovery sub-class (d)** confirms sub-class is intermittent not persistent); ssh-egress-flake class distinct (17 cumulative datapoints across iter-372..420b).
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (REOPENED for Stories 1.17–1.21).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` — this work targets it as the PR base, not `main`.
- **Working Branch:** `chore/correct-course-test-runner-233` (based on `origin/feat/epic-2-packaged-devbox`).
- **Story:** 1.21 — Sweep prior `ATDD deferred` stories into `test-debt:` follow-ups.
- **Story File:** `_bmad-output/implementation-artifacts/1-21-sweep-prior-atdd-deferred-stories-into-test-debt-followups.md`.
- **Story State:** `fixes-pending` per FR14n § Story Lifecycle Decision Matrix `fixes-pending` row. **CR-pass-2 fix-arc COMPLETE** at iter-424 (PATCH-10 iter-422 + PATCH-11 iter-423 + PATCH-12 iter-424; QUEUE drained of PATCH items). Per FR14n `fixes-pending` row exit condition: re-run `/bmad-code-review (args: "2")` to confirm `done`. **NOW = CR-pass-3 invocation.** **Path:** CR-pass-3 (iter-425; forecast 0 residual after sweep-completion carry-rule applied) → Epic 1 reclose + PR #236 Draft→Open final CI gate + EPIC_DONE halt → § Cross-epic transition on next invocation post-merge.
- **GitHub Issue:** Issue #233 ("Course Correction: Bootstrap test runner + CI"). PR #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`) carries `Refs #233`; `Closes #233` lands at Story 1.21 close-out.
- **PR:** #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`).

## Notes

- **Story 1.21 forecast envelope (post-iter-424 CR-pass-2 fix-arc COMPLETE):** Cumulative pre-merge PATCH **22 projected** (UNCHANGED from iter-423; PATCH-12 landed within envelope). Stage breakdown remaining: CR-pass-3 (forecast 0 residual after sweep-completion carry-rule applied at all 3 PATCH). Cumulative residual envelope post-iter-424: **22 final** (within 13–43 first-datapoint-of-class envelope; calibrated mid-band on cumulative across 5 lifecycle datapoints).
- **Sweep-completion carry-rule (iter-421 NEW; 1st-class precedent applied at iter-422/423/424 with 100% success rate over 3 PATCH):** When CR-pass-N PATCH targets a count-drift, sweep ALL occurrences via `grep -n '<old-value>' <file>` before claiming PATCH-N done. PATCH-10/11/12 all applied this rule cleanly with no missed parallel sites. Forecast: CR-pass-3 0 residual on count-drift class.
- **Audit + sweep class envelope CALIBRATED at iter-421 CR-pass-2 (5 datapoints):** dev-story 0-PATCH + trace 0-PATCH + SM-verify 2-PATCH + CR-pass-1 9-PATCH + CR-pass-2 3-PATCH (mid-band 0–6). Future audit + sweep stories inherit envelope dev-story 0–3 / trace 0–2 / SM-verify 1–4 / CR-pass-1 0–9 / CR-pass-N≥2 0–4.
- **api.github.com network class (39 cumulative datapoints across iter-397..424):** Sub-classes by endpoint affected: (a) endpoint-split graphql-only; (b) joint-endpoint cross-iter (defer push); (c) joint-endpoint within-iter recovery; (d) **4-endpoint within-iter joint-flake NO-recovery** (iter-415 NEW; 2 surfacings iter-415 + iter-423; intermittent confirmed at iter-424 LADDER step 1 first-try clear). LADDER carry-rule: (1) `gh pr checks <PR> --watch --fail-fast`; (2) REST `gh api commits/<sha>/check-runs`; (3) graphql `gh pr checks <PR>` one-shot; (4) defer push to next iter OR fall-through to work iff ORIGIN SHA was already proven GREEN at a PRIOR iter and no new push has intervened.
- **Course-correction precedent stack 3 deep:** issue #231 (PR #234 MERGED) → issue #232 (PR #235 MERGED) → issue #233 (PR #236 in-flight; pending Story 1.21 close + Draft→Open final CI gate). Issue #233 is the first to REOPEN a closed epic.
- **Epic 4 hard-precondition:** Epic 4 (per-iteration security verification) extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Stories 1.19 + 1.20 backfill IS LANDED + DONE; Epic 4 unblock requires Story 1.21 + Epic 1 reclose.
- **iter-372 SSH-egress flake carry-rule (17 cumulative datapoints across iter-372..420b):** kill-after-hang + retry-fail sub-class. First-retry-resolves carry-rule does NOT always hold.
- **Iter-358 INV-git-hooks-preservation worktree-mode drift carry-rule (carry-forward to Epic 4 hardening):** Story 1.17 + 1.18 + 1.19 + 1.20 + 1.21 disposition (c) carry-forward unchanged. 4-drift sync-gate baseline persists.
