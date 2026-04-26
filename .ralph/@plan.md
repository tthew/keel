# Implementation Plan

## NOW

- [ ] PATCH-10: Story file `1-21-…md:233` § Substrate-extension-class forecast SM-validate row sweep "23-DEFER inherited list" → "24-DEFER inherited list" + "30 cross-links" → "27 cross-links" — extends PATCH-9 + PATCH-8 sweep to forecast-rationale prose missed at CR-pass-1 (Edge#2 iter-421). ~small

## QUEUE (Story 1.21 CR-pass-2 fix-arc → CR-pass-3 → Epic 1 reclose)

- [ ] PATCH-11: Story file `1-21-…md:241` § Test-surface decomposition "~30 cross-link edits" → "27 cross-link edits" — twin sweep to PATCH-8 (Edge#3 iter-421).
- [ ] PATCH-12: Story file `1-21-…md:174` § Audit methodology deflection "per-story event counts are recorded in the test-debt.md catalogue rows" — schema has no event-count field; replace with simpler statement (drop trailing clause; end sentence at "multi-event skips.") (Edge#1 iter-421).
- [ ] Re-run `/bmad-code-review (args: "2")` — CR-pass-3 to confirm `fixes-pending → done` per FR14n matrix after PATCH-10..12 land (forecast 0 residual after sweep-completion carry-rule applied).
- [ ] Re-close Epic 1 (`epic-1: in-progress → done` after Story 1.21 closes); transition PR #236 Draft→Open final CI gate per § PR Transition & Final CI Gate; on success: write `EPIC_DONE` halt; on next invocation post-merge § Cross-epic transition advances to next available epic OR writes `ALL_EPICS_DONE` if no next epic.

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty — Story 1.21 ATDD-skipped iter-400 via FR14n § ATDD-skip pure ground (a) substrate-verification per IP § ATDD Skip Rationale; no red-phase tests authored.)_

## DONE (CR-pass-2 raised 3 new PATCH; QUEUE drains across iter-422+)

- [x] iter-421: **Story 1.21 `/bmad-code-review (args: "2")` CR-pass-2 PASS — 3 parallel review layers (Blind Hunter + Edge Case Hunter + Acceptance Auditor); 9 findings triaged into 3 PATCH + 1 DEFER + 5 DISMISSED.** FR14n `fixes-pending → fixes-pending` (stays — 3 NEW PATCH raised; QUEUE re-fills). Auditor verdict: "CR-pass-2 clean. Story 1.21 ready for `fixes-pending → done` flip" but Edge surfaced 2 missed-sweep residuals + 1 deflection clarification. **3 PATCH queued at TOP of QUEUE** (CR re-pass envelope mid-band — was forecast 0–6 single-iter; 3 across 1–3 iters acceptable per audit + sweep class CR re-pass first datapoint). All 6 ACs reconfirmed satisfied at operative-test level. **3 PATCH targets:** (PATCH-10) line 233 forecast-rationale "23-DEFER" → "24" + "30 cross-links" → "27" — extends PATCH-9 + PATCH-8 sweep to forecast prose missed at CR-pass-1; (PATCH-11) line 241 "~30 cross-link edits" → "27" — twin sweep to PATCH-8; (PATCH-12) line 174 deflection "per-story event counts are recorded in the test-debt.md catalogue rows" — schema has no event-count field; remove false forward-pointer. **1 DEFER** appended to deferred-work.md § Deferred from: code review of story-1-21 CR-pass-2 (2026-04-26 iter-421): line 221 prose redundancy (PATCH-6 restates "first pure-ground-(a)" three times in one paragraph; carry-to Epic 4 close-out audit). **5 DISMISSED items recorded inline** in story file § CR-pass-2 (Out-of-Scope 7-vs-8 self-check / Walked-stories total exclusion-list cosmetic / test-debt.md OOS exemplar swap loses ground-(a) link / × ~30 → × 27 parity verification / forecast-table line 234 "4th post-(b)-sunset" two-axes counting). **NEW carry-rule landed at iter-421**: Sweep-completion carry-rule — when CR-pass-N PATCH targets a count-drift, sweep ALL occurrences via `grep -n '<old-value>' <file>` before claiming PATCH-N done; otherwise CR-pass-(N+1) catches residuals as fresh findings (PATCH-10/PATCH-11 are this rule's first surfacing). Cumulative pre-merge PATCH Story 1.21 lifecycle: **21** projected (was 18 at CR-pass-1; +3 CR-pass-2 PATCH findings — sweep-completion class). **Audit + sweep class CR re-pass envelope CALIBRATED at iter-421 (5th datapoint):** CR-pass-2 3 PATCH (mid-band of 0–6 forecast envelope; non-zero residual driven by sweep-completion gap from CR-pass-1 line-targeted vs occurrence-targeted PATCH). Forecast residual envelope post-iter-421: **21 final** (assumes 0 residual at CR-pass-3 after sweep-completion carry-rule applied — PATCH-10/11 close all known count-drift sites at scale). Pre-CR-pass-2 LADDER: graphql `gh pr checks 236` flake at step 0h (31st cumulative api.github.com class datapoint) → REST `gh api commits/02ed7b9/check-runs` clear (32nd datapoint) — pre-push CI gate satisfied via LADDER step 2 fallback. **Multi-deferred-push tracker:** 2 unpushed commits at iter-421 start (`b2ca12f` iter-420 monitor + `de03c68` iter-420b IP correction); iter-421 step 5 pushes 3-commit batch (carry-forward + this iter CR-pass-2 commit). Next NOW per FR14n matrix `fixes-pending` row: top QUEUE PATCH-10 (line 233 sweep); when QUEUE empties (3 PATCH × 1 iter = 3 iters minimum + CR-pass-3), re-run `/bmad-code-review (args: "2")` to confirm `done`.

- [x] iter-420b: iter-420 step-5 push DEFERRED to iter-421 — SSH-egress port 22 timeout (90s wrapper exit 124; 17th cumulative iter-372 class datapoint, single attempt sufficient probe per iter-413b carry-rule). 1 unpushed commit at iter-421 start (`b2ca12f` = iter-420 monitor PASS + IP prune + RALPH iter-420 signpost). Multi-deferred-push tracker re-opened (drains at first iter-421+ push clear).

- [x] iter-420: Monitor PR #236 CI on iter-419 push (3-commit batch SHA `02ed7b9`) → BOTH CHECKS GREEN (node 1m8s + python 12s; run 24956455918). LADDER step 1 cleared first-try. Multi-deferred-push tracker (iter-413..iter-419) FULLY RESOLVED at iter-420 monitor. CR-pass-2 promoted to NOW per IP carry-rule.

- [x] iter-419: **Story 1.21 CR-pass-1 PATCH-9 LANDED via fall-through clause + 3-commit batch pushed (multi-deferred-push tracker RESOLVED) — FINAL fix-arc PATCH (9 of 9 complete).** PATCH-9 work: single-line Edit at story file `1-21-…md:294` § References — annotation "23 inherited DEFER entries" → "24" — completes the v1.1 SM-validate count-correction sweep. Resolves Blind#3 finding from iter-404 CR-pass-1.

- [x] iter-418: **Story 1.21 CR-pass-1 PATCH-8 LANDED via fall-through clause — 8th in-iter fall-through PATCH landing across 1.21 fix-arc.** PATCH-8 work: single-line Edit at story file `1-21-…md:282` § Project Structure Notes — Files-modified `<story-slug>.md` cross-link estimate "× ~30" → "× 27". Resolves Blind#13 finding from iter-404 CR-pass-1. iter-418 step-5 push DEFERRED (16th iter-372 class datapoint).

- [x] iter-417: PATCH-7 LANDED (Change Log v1.1 chrono reorder; Blind#12) via fall-through; iter-416 push CI PASS via REST-fallback after LADDER 3-rung flake (25th api.github.com datapoint). 4-commit batch pushed (3 carry-forward + PATCH-7). Edit-tool EOF-newline gotcha 1st datapoint.

- [x] iter-416..416b: PATCH-6 LANDED (Subtask 6.1 wording disambiguation; Blind#11); push DEFERRED (15th iter-372 class datapoint).

- [x] iter-415: Monitor UNRESOLVED — 4-endpoint api.github.com within-iter joint-flake NO-recovery (NEW sub-class signature, 23rd datapoint); push DEFERRED; carry-rule LADDER updated to 5-step.

- [x] iter-413..414: PATCH-4 LANDED (story file:174 dropped Story 2.6 multi-skip example; Edge#1) + PATCH-5 LANDED (test-debt.md:23 § Audit methodology Story 1.7→1.8 OUT example; Edge#8) via fall-through after REST-fallback CI clear. 3-commit batch pushed at iter-414 (multi-deferred tracker RESOLVED).

- [x] iter-409..412: PATCH-1 LANDED (Subtask 1.3 OUT count "8"→"7"; Blind#9) + PATCH-2 LANDED (en-dash bootstrap-arc range "1.17–1.20"→"1.17–1.21"; Edge#3) + PATCH-3 LANDED (story file:172 stale "~30"→"27" + 7-story divergence framing) via fall-through clauses. iter-412 was a pure monitor iter (graphql one-shot recovery; NEW joint-endpoint within-iter sub-class).

- [x] iter-404: **Story 1.21 `/bmad-code-review (args: "2")` CR-pass-1 — 3 parallel review layers (Blind Hunter + Edge Case Hunter + Acceptance Auditor); 23 findings triaged into 9 PATCH + 6 DEFER + 8 DISMISSED.** FR14n `sm-verified → fixes-pending`. 9 PATCH targets: cosmetic count consistency + cross-classification fixes + Change Log ordering. 6 DEFER appended to `deferred-work.md` § Deferred from: code review of story-1-21 (2026-04-26 iter-404). 8 DISMISSED items recorded inline. All gates re-GREEN at CR.

- [x] iter-401..403: Story 1.21 dev-story (iter-401 0 PATCH; FR14n `atdd-scaffolded → in-dev → review` Status flip; ~25 subtasks; test-debt.md NEW + 27 originating story files cross-linked) → trace (iter-402 0 PATCH; FR14n `in-dev → traced`; 4 trace artefacts) → SM-verify (iter-403 2 PATCH; FR14n `traced → sm-verified`).

- [x] iter-398..400: Story 1.21 drafted (iter-398 FR14n `_(no story) → drafted`) → SM-validated (iter-399 7 PATCH; FR14n `drafted → validated`) → ATDD-skipped pure ground (a) substrate-verification (iter-400; FR14n `validated → atdd-scaffolded`).

- [x] iter-1: `/bmad-correct-course` on issue #233 — Sprint Change Proposal; Epic 1 REOPENED for Stories 1.17–1.21.

## Context

- **Phase:** 4-implementation — Story 1.21 CR-pass-2 complete iter-421; CR-pass-2 raised 3 NEW PATCH (sweep-completion class); QUEUE re-fills.
- **Runtime:** cc-devbox iteration env. `uv 0.11.7` + `pnpm` available. Python 3.12.3 satisfies `requires-python = ">=3.10"`. github.com / api.github.com network access intermittent (api-egress-flake class — 32nd cumulative datapoint at iter-421 step 0h LADDER step 1 graphql flake → step 2 REST clear; carry-rule confirmed); ssh-egress-flake class distinct (17 cumulative datapoints across iter-372..420b).
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (REOPENED for Stories 1.17–1.21).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` — this work targets it as the PR base, not `main`.
- **Working Branch:** `chore/correct-course-test-runner-233` (based on `origin/feat/epic-2-packaged-devbox`).
- **Story:** 1.21 — Sweep prior `ATDD deferred` stories into `test-debt:` follow-ups.
- **Story File:** `_bmad-output/implementation-artifacts/1-21-sweep-prior-atdd-deferred-stories-into-test-debt-followups.md`.
- **Story State:** `fixes-pending` per FR14n § Story Lifecycle Decision Matrix `fixes-pending` row (iter-421 CR-pass-2 raised 3 NEW PATCH + 1 DEFER + 5 DISMISSED; auditor verdict: 6/6 ACs reconfirmed satisfied at operative-test level). **CR-pass-2 fix-arc OPEN** — QUEUE-empty exit condition (after PATCH-10 + PATCH-11 + PATCH-12 land) triggers CR-pass-3 invocation per FR14n matrix `fixes-pending` row. **NOW = PATCH-10**. **Path:** PATCH-10 (iter-422) → PATCH-11 (iter-423) → PATCH-12 (iter-424) → CR-pass-3 (iter-425; forecast 0 residual after sweep-completion carry-rule applied) → Epic 1 reclose + PR #236 Draft→Open + EPIC_DONE halt.
- **GitHub Issue:** Issue #233 ("Course Correction: Bootstrap test runner + CI"). PR #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`) carries `Refs #233`; `Closes #233` lands at Story 1.21 close-out.
- **PR:** #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`).

## Notes

- **Story 1.21 forecast envelope (post-iter-421 CR-pass-2):** Cumulative pre-merge PATCH **21 projected** (was 18 at CR-pass-1; +3 CR-pass-2 PATCH findings — sweep-completion class). Stage breakdown remaining: 3 PATCH fix-arc across 1–3 iters + CR-pass-3 (forecast 0 residual after sweep-completion carry-rule applied). Cumulative residual envelope post-iter-421: **21 final** (within 13–43 first-datapoint-of-class envelope; calibrated mid-band on cumulative across 5 lifecycle datapoints).
- **Sweep-completion carry-rule (NEW iter-421 — 1st datapoint of CR-pass-N sweep-completion class):** When CR-pass-N PATCH targets a count-drift at specific line(s), the PATCH commit MAY leave parallel occurrences elsewhere in the file untouched. Carry-rule for future CR fix-arcs: when CR-pass-N PATCH targets a count-drift, sweep ALL occurrences via `grep -n '<old-value>' <file>` before claiming PATCH-N done; otherwise CR-pass-(N+1) catches residuals as fresh findings. PATCH-10 + PATCH-11 at iter-421 are this rule's 1st surfacing (PATCH-8 at line 282 missed line 241; PATCH-9 at line 294 missed line 233).
- **Audit + sweep class envelope CALIBRATED at iter-421 CR-pass-2 (5 datapoints):** dev-story 0-PATCH (iter-401) + trace 0-PATCH (iter-402) + SM-verify 2-PATCH (iter-403) + CR-pass-1 9-PATCH (iter-404) + CR-pass-2 3-PATCH (iter-421, mid-band of 0–6 re-pass envelope). Future audit + sweep stories inherit envelope dev-story 0–3 / trace 0–2 / SM-verify 1–4 / CR-pass-1 0–9 / CR-pass-N≥2 0–4.
- **Iter-358 INV-git-hooks-preservation worktree-mode drift carry-rule (carry-forward to Epic 4 hardening):** Story 1.17 + 1.18 + 1.19 + 1.20 + 1.21 disposition (c) carry-forward unchanged at iter-421. 4-drift sync-gate baseline persists.
- **iter-372 SSH-egress flake carry-rule (17 cumulative datapoints across iter-372..420b):** kill-after-hang + retry-fail sub-class added at iter-388. First-retry-resolves carry-rule does NOT always hold.
- **api.github.com network class (32 cumulative datapoints across iter-397..421):** Sub-classes by endpoint affected: (a) endpoint-split graphql-only (5 datapoints); (b) joint-endpoint cross-iter (defer push); (c) joint-endpoint within-iter recovery (graphql-watch → REST → graphql-one-shot). LADDER carry-rule: (1) `gh pr checks <PR> --watch --fail-fast`; (2) REST `gh api repos/<owner>/<repo>/commits/<sha>/check-runs`; (3) graphql `gh pr checks <PR>` one-shot; (4) defer push to next iter.
- **Course-correction precedent stack 3 deep:** issue #231 (PR #234 MERGED) → issue #232 (PR #235 MERGED) → issue #233 (PR #236 in-flight; pending Story 1.21 close + Draft→Open final CI gate). Issue #233 is the first to REOPEN a closed epic.
- **Epic 4 hard-precondition:** Epic 4 (per-iteration security verification) extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Stories 1.19 + 1.20 backfill IS LANDED + DONE; Epic 4 unblock requires Story 1.21 + Epic 1 reclose.
