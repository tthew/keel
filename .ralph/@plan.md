# Implementation Plan

## NOW

- [ ] Re-close Epic 1 per § PR Transition & Final CI Gate: (a) sprint-status update `epic-1: in-progress → done` (line 136 — replace `in-progress  # was: done — reopened by issue #233 SCP for Stories 1.17–1.21 (test runner bootstrap pass)` with `done  # reclosed iter-435 after Story 1.21 done at iter-434 CR-pass-5 PASS — issue #233 SCP REOPEN-ARC complete`); (b) `gh pr ready 236` Draft→Open; (c) `gh pr checks 236 --watch --fail-fast` final CI gate; (d) on PASS: write `EPIC_DONE` halt JSON to `$RALPH_BASE_DIR/halt`; on FAIL: queue fix tasks per § PR Transition & Final CI Gate fail branch; (e) on next invocation post-merge § Cross-epic transition advances to next available epic OR writes `ALL_EPICS_DONE` if no next epic. ~medium

## QUEUE (post-EPIC_DONE re-entry)

_(empty — § Cross-epic transition handles re-entry post-merge autonomously per § Cross-epic transition step 1-3 branch logic; no pre-queued tasks needed for the post-merge iteration. If no next epic in sprint-status: ALL_EPICS_DONE terminal halt.)_

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty — Story 1.21 ATDD-skipped iter-400 via FR14n § ATDD-skip pure ground (a) substrate-verification per IP § ATDD Skip Rationale; no red-phase tests authored.)_

## DONE (current story phase only — pruned at iter-434; older fix-arc detail in RALPH.md signposts)

- [x] iter-434: **CR-pass-5 PASS — 0 NEW PATCH (33 raw findings → 0 PATCH + 0 DEFER + 33 DISMISSED) — CONVERGENCE EVENT — FR14n `fixes-pending → done`.** First 0-PATCH CR pass in the 5-CR-pass audit-trail; matrix exit condition met per `fixes-pending` row exit clause "re-run CR with 0 finding closes `done` directly". Auditor verdict: "AC1+AC2+AC3+AC4+AC5+AC6 all satisfied at operative-test level; fix-arc landed cleanly; no regressions". 33 raw findings (Blind Hunter 15 cynical + Edge Case Hunter 10 project-aware JSON + Acceptance Auditor 8 AC-mapped) every one mapped to: (a) already-PATCHed in CR-pass-1..4 / (b) already-DEFERRED to deferred-work.md (recursive duplicates) / (c) already-DISMISSED with established carry-rule precedent / (d) NEW false-positive (PATCH-numbering-gap interpretive / Subtask 7.3 forward-reference reflective-authoring / pytest 4-tests-3-files multi-test-per-file ground-truth / Subtask 2.1 (6) Epic-1-only count internally consistent / sprint-status `review` post-CR-pass-5 = THIS iter's close-out action / CR-pass-5 missing-v1.13 temporal misunderstanding / AC1 ordering 1.7→1.11 OUT-of-scope explicit per AC1 / AC2 enforcement structural-by-design / AC3 cross-link uniform-trailer accepted at CR-pass-2 / Status:review-vs-fixes-pending two-tier convention). **NEW carry-rule landed iter-434 (16th class — convergence-detection at-FIRST-zero-PATCH-CR-pass):** the FR14n `fixes-pending` row exit condition is satisfied at the FIRST 0-PATCH CR pass, NOT a 2-consecutive-zero-PATCH alternative — the iter-425 conservative forecast bound (~1–3 PATCH per CR-pass-N≥2 until 2-consecutive-zero confirms convergence) is a FORECAST heuristic for budget planning, NOT a matrix exit gate; once a CR pass produces 0 PATCH, the matrix transition fires. **CR-pass-5 forecast outcome (0 PATCH at lower-band of 0–2 forecast):** envelope held; iter-425 carry-rule's predictive power confirmed for the FOURTH consecutive CR pass (CR-pass-2 produced 3 / CR-pass-3 produced 3 / CR-pass-4 produced 2 / CR-pass-5 produced 0). Story-file Status flipped `review → done` (line 3); sprint-status row flipped `review → done` (line 157) + `# last_updated:` comment block top-prepended per iter-401 dev-story precedent. CR-pass-5 § Review Findings sub-section appended at lines 579-630 (33 dismissed items recorded inline with rationale; cross-references to prior CR-pass-1..4 dispositions). v1.13 Change Log entry appended at file tail. All gates GREEN at step 4: typecheck 16/16 (FULL TURBO 145ms), lint 16/16 (FULL TURBO 137ms), keel-invariants 10 files / 52 tests (937ms; 4-drift baseline UNCHANGED — 0 NEW drift from cosmetic .md edits), pytest 4/4 (0.20s). Cumulative pre-merge PATCH Story 1.21 lifecycle: **26 FINAL** (UNCHANGED from CR-pass-4 close projection; 0 CR-pass-5 PATCH = convergence-class outcome). NOW advances to top QUEUE Epic 1 reclose. **Path forward:** iter-435 (Epic 1 reclose + sprint-status `epic-1: in-progress → done` + PR #236 Draft→Open + final CI gate + EPIC_DONE halt) → human merges PR #236 → next invocation § Cross-epic transition (advance to next epic OR ALL_EPICS_DONE).

- [x] iter-433: PATCH-19 LANDED at commit `3c5216b` — line 513 `forecast-table line 240` → `line 234` + Change Log v1.12 + self-flip at line 551. Push FAILED 2x at step 5 (SSH-egress flake — 22nd cumulative datapoint of iter-372 class); 6 unpushed commits carry to iter-434.

- [x] iter-432: PATCH-18 LANDED at commit `b3aa46a` — 2 sites period→hyphen at story-file lines 80 + 89 + Change Log v1.11 + self-flip at line 549. Push FAILED at step 5 (SSH-egress flake — 19th cumulative datapoint).

- [x] iter-431: CI monitoring PASS — PR #236 SHA `cba5e3e` (iter-430 push) CI cleared (node 1m13s + python 13s; run 24959581036).

- [x] iter-430: CR-pass-4 LANDED — 2 PATCH (PATCH-18 + PATCH-19) + 1 DEFER + ~12 DISMISSED across 3 parallel review layers.

- [x] iter-427..429: PATCH-14 + PATCH-16 + PATCH-17 LANDED (3-PATCH CR-pass-3 fix-arc complete). 13th-class (iter-427) + 14th-class (iter-428) IP-planner sweep-count vs operative-grep + operative-grep-pattern-vs-target-set reconciliation carry-rules.

- [x] iter-425: Story 1.21 CR-pass-3 LANDED — 18+ findings → 3 PATCH (PATCH-14/16/17) + 1 DEFER + ~14 DISMISSED. NEW carry-rule: CR-pass-(N+1) forecast must NOT extrapolate "0 residual" from CR-pass-N's success rate.

- [x] iter-422..424: PATCH-10 + PATCH-11 + PATCH-12 LANDED (3-PATCH CR-pass-2 fix-arc complete).

- [x] iter-421: Story 1.21 CR-pass-2 PASS — 9 findings (3 PATCH + 1 DEFER + 5 DISMISSED). NEW carry-rule: Sweep-completion carry-rule.

- [x] iter-409..420: Story 1.21 CR-pass-1 fix-arc PATCH-1..9 (9 of 9 LANDED).

- [x] iter-404: Story 1.21 `/bmad-code-review (args: "2")` CR-pass-1 — 23 findings → 9 PATCH + 6 DEFER + 8 DISMISSED. FR14n `sm-verified → fixes-pending`.

- [x] iter-398..403: Story 1.21 drafted → SM-validated (7 PATCH) → ATDD-skipped pure ground (a) → dev-story (0 PATCH) → trace (0 PATCH) → SM-verify (2 PATCH).

- [x] iter-1: `/bmad-correct-course` on issue #233 — Sprint Change Proposal; Epic 1 REOPENED for Stories 1.17–1.21.

## Context

- **Phase:** 4-implementation — Story 1.21 CR-pass-5 PASS at iter-434 (0 NEW PATCH, FR14n `fixes-pending → done`); CONVERGENCE EVENT — first 0-PATCH CR pass in 5-CR-pass audit-trail. **iter-434: CR-pass-5 PASS — 33 raw findings → 0 PATCH + 0 DEFER + 33 DISMISSED; story-file Status flipped `review → done`; sprint-status row flipped `review → done`; v1.13 Change Log entry appended; CR-pass-5 § Review Findings sub-section recorded.** Path: Epic 1 reclose (iter-435) → PR #236 Draft→Open final CI gate → EPIC_DONE halt → § Cross-epic transition on next invocation post-merge.
- **Runtime:** cc-devbox iteration env. `uv 0.11.7` + `pnpm` available. Python 3.12.3 satisfies `requires-python = ">=3.10"`. github.com / api.github.com network access intermittent (api-egress-flake class — **46 cumulative datapoints at iter-433** UNCHANGED at iter-434; iter-434 step 0h `gh pr checks 236` clean first-try for HEAD SHA `da01035` iter-431 push CI = node+python both PASS so step 0h proceeded). ssh-egress-flake class **22 cumulative datapoints at iter-433** UNCHANGED at iter-434 (iter-434 push attempt at step 5 not yet executed at IP write-time; carry-forward 6 unpushed commits from iter-432/433 + this iter's CR-pass-5 close-out commit = 7-commit batch potential push at step 5; first-retry-resolves carry-rule applies ~82% of time per iter-433 extension).
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (REOPENED for Stories 1.17–1.21; **all 5 REOPEN-ARC stories DONE at iter-434**: 1.17 (iter-220) + 1.18 (iter-260) + 1.19 (iter-330) + 1.20 (iter-397) + 1.21 (iter-434)).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` — this work targets it as the PR base, not `main`.
- **Working Branch:** `chore/correct-course-test-runner-233` (based on `origin/feat/epic-2-packaged-devbox`).
- **Story:** 1.21 — Sweep prior `ATDD deferred` stories into `test-debt:` follow-ups (DONE at iter-434; FR14n `fixes-pending → done`).
- **Story File:** `_bmad-output/implementation-artifacts/1-21-sweep-prior-atdd-deferred-stories-into-test-debt-followups.md`.
- **Story State:** `done` per FR14n § Story Lifecycle Decision Matrix (CR-pass-5 0-PATCH outcome triggered `fixes-pending → done` exit transition per matrix `fixes-pending` row exit clause). **Path:** iter-435 NOW = Epic 1 reclose per QUEUE (sprint-status `epic-1: in-progress → done` + PR #236 Draft→Open + final CI gate + EPIC_DONE halt → § Cross-epic transition on next invocation post-merge).
- **GitHub Issue:** Issue #233 ("Course Correction: Bootstrap test runner + CI"). PR #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`) carries `Refs #233`; `Closes #233` lands at PR #236 Draft→Open transition body edit (iter-435 close-out).
- **PR:** #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`).

## Notes

- **Story 1.21 forecast envelope FINAL (post-iter-434 CR-pass-5 PASS — convergence event):** Cumulative pre-merge PATCH **26 FINAL** (within 13–43 first-datapoint-of-class envelope; tracking upper-mid-band; 5-CR-pass extension). Stage breakdown: 7 SM-validate + 2 SM-verify + 9 CR-pass-1 + 3 CR-pass-2 + 3 CR-pass-3 + 2 CR-pass-4 + 0 CR-pass-5 = 26. **Audit + sweep class CR re-pass envelope FINAL CALIBRATED at iter-434 (8th + final datapoint):** dev-story 0 / trace 0 / SM-verify 2 / CR-pass-1 9 / CR-pass-2 3 / CR-pass-3 3 / CR-pass-4 2 / CR-pass-5 0. Future audit + sweep stories (Epic 4 close-out audit if any) inherit envelope dev-story 0–3 / trace 0–2 / SM-verify 1–4 / CR-pass-1 0–9 / CR-pass-N≥2 0–3 (N≥5 trends to 0 — convergence).
- **NEW carry-rule iter-434 (16th class — convergence-detection at-FIRST-zero-PATCH-CR-pass):** the FR14n `fixes-pending` row exit condition "stays `fixes-pending` until QUEUE empties → re-run CR → `done`" is satisfied at the FIRST 0-PATCH CR pass, NOT a 2-consecutive-zero-PATCH alternative. The iter-425 conservative forecast bound (~1–3 PATCH per CR-pass-N≥2 until 2-consecutive-zero confirms convergence) is a FORECAST heuristic for budget planning, NOT a matrix exit gate; once a CR pass produces 0 PATCH, the matrix transition fires. Reference incident: this iter-434 CR-pass-5 0-PATCH FR14n `fixes-pending → done` transition.
- **NEW carry-rule iter-428 (14th class — IP-planner operative-grep-pattern-vs-target-set reconciliation):** when IP-planner sweep specs include BOTH an operative grep pattern AND a line range, BOTH must be reconciled at fix-time. **iter-433 extension:** trust grep result over IP/spec line-ref when file has accreted lines from prior Change Log entries.
- **NEW carry-rule iter-427 (13th class — IP-planner sweep-count vs operative-grep reconciliation):** when prior-iter IP claims K sweep occurrences AND specifies the operative grep pattern, re-run the operative grep AT FIX-TIME and trust it as source-of-truth.
- **CR-pass-(N+1) forecast carry-rule (iter-425; extension of iter-421 sweep-completion):** CR-pass-(N+1) forecast must NOT extrapolate "0 residual" from "100% success rate of CR-pass-N PATCH against the carry-rule(s) known at CR-pass-N" — each CR-pass-N may surface NEW finding classes invisible at CR-pass-(N-1). Conservative forecast bound = max(0, |unique-finding-classes-not-yet-surfaced|), ~1–3 PATCH per CR-pass-N≥2 until 2-consecutive-zero-PATCH CR passes confirm convergence. **iter-434 supersedes this for matrix-exit purposes (16th-class carry-rule):** the 2-consecutive-zero alternative is a forecast heuristic for budget planning, NOT a matrix exit gate — first 0-PATCH closes done.
- **Sweep-completion carry-rule (iter-421; precedent applied at iter-422/423/424 + iter-429 + iter-432 + iter-433):** When CR-pass-N PATCH targets a count-drift OR cross-reference-drift, sweep ALL occurrences via `grep -n '<old-value>' <file>` before claiming PATCH-N done. **iter-433 PATCH-19 extension:** carry-rule applies to in-line cross-reference correction class (line-ref drift); same sweep verb stays valid.
- **iter-432 sub-class 15a carry-rule (extends iter-428 14th-class):** `replace_all` is unsafe when the target substring also appears verbatim inside narrative quotation OR historical Change Log entries. **iter-433 extension:** PATCH-19's 3-site narrative-quoted preservation footprint (PATCH-19 spec body + 2 Change Log entries) is the largest yet for any single-PATCH operative target in this fix-arc.
- **api.github.com network class (45 cumulative datapoints across iter-397..432; UNCHANGED at iter-433/434):** Sub-classes: (a) endpoint-split graphql-only; (b) joint-endpoint cross-iter; (c) joint-endpoint within-iter recovery; (d) 4-endpoint within-iter joint-flake NO-recovery. LADDER carry-rule: (1) `gh pr checks <PR> --watch --fail-fast`; (2) REST `gh api repos/<owner>/<repo>/commits/<sha>/check-runs`; (3) graphql `gh pr checks <PR>` one-shot; (4) defer push to next iter OR fall-through to work iff ORIGIN SHA was already proven GREEN at a PRIOR iter and no new push has intervened.
- **Course-correction precedent stack 3 deep:** issue #231 (PR #234 MERGED) → issue #232 (PR #235 MERGED) → issue #233 (PR #236 in-flight; pending Epic 1 reclose iter-435 + Draft→Open final CI gate). Issue #233 is the first to REOPEN a closed epic.
- **Epic 4 hard-precondition:** Epic 4 (per-iteration security verification) extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Stories 1.19 + 1.20 backfill IS LANDED + DONE; **Story 1.21 DONE at iter-434**; Epic 4 unblock NOW requires only Epic 1 reclose (iter-435).
- **iter-372 SSH-egress flake carry-rule (22 cumulative datapoints across iter-372..433):** kill-after-hang + retry-fail sub-class. First-retry-resolves carry-rule does NOT always hold (4 of 22 datapoints are 2-consecutive-fail events at step 5 — first-retry-resolves carry-rule applies ~82% of the time). 6 unpushed commits from iter-432/433 carry to iter-434 step 5; this iter's CR-pass-5 close-out adds a 7th commit; potential 7-commit batch push.
- **Iter-358 INV-git-hooks-preservation worktree-mode drift carry-rule (carry-forward to Epic 4 hardening):** Story 1.17 + 1.18 + 1.19 + 1.20 + 1.21 disposition (c) carry-forward unchanged. 4-drift sync-gate baseline persists.
