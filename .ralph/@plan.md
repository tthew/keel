# Implementation Plan

## NOW

- [ ] Re-run `/bmad-code-review (args: "2")` — CR-pass-4 to confirm `fixes-pending → done` per FR14n matrix after PATCH-14 + PATCH-16 + PATCH-17 fix-arc complete. Forecast 0–2 residual per iter-425 carry-rule (CR-pass-(N+1) forecast must NOT extrapolate "0 residual" from CR-pass-N's success rate; convergence requires 2-consecutive-zero-PATCH CR passes — CR-pass-3 had 3 PATCH so CR-pass-4 must produce 0 PATCH AND CR-pass-5 must produce 0 PATCH for full convergence proof, OR CR-pass-4 with no findings closes `done` directly per FR14n matrix `fixes-pending` row exit condition). ~medium

## QUEUE (Story 1.21 CR-pass-4 → Epic 1 reclose)

- [ ] Re-close Epic 1 (`epic-1: in-progress → done` after Story 1.21 closes); transition PR #236 Draft→Open final CI gate per § PR Transition & Final CI Gate; on success: write `EPIC_DONE` halt; on next invocation post-merge § Cross-epic transition advances to next available epic OR writes `ALL_EPICS_DONE` if no next epic.

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty — Story 1.21 ATDD-skipped iter-400 via FR14n § ATDD-skip pure ground (a) substrate-verification per IP § ATDD Skip Rationale; no red-phase tests authored.)_

## DONE (current story phase only — pruned at iter-429; older fix-arc detail in RALPH.md signposts)

- [x] iter-429: **PATCH-17 LANDED — 2 categorical-wording sites swapped at story file lines 156 + 325 + Change Log v1.9 entry + PATCH-17 self-flip at line 513.** FR14n `fixes-pending` UNCHANGED (0 PATCH still pending — CR-pass-3 fix-arc CONTENT-COMPLETE; next gate = CR-pass-4 re-run). Operative fix: line 156 (Subtask 8.2 evidence) "32 cumulative ATDD-skips post-bootstrap" → "32 cumulative project ATDD-skips (4 post-bootstrap: 1.17, 1.18, 1.20 hybrid, 1.21)"; line 325 (AC2 verification matrix) "32 cumulative post-bootstrap ATDD-skips" → "same target string". The two sites used different word orderings ("ATDD-skips post-bootstrap" vs "post-bootstrap ATDD-skips") so two distinct Edit calls were required (no single `replace_all` would catch both). Sweep-completion carry-rule (iter-421) applied cleanly via `grep -n '32 cumulative'` returning 5 matches; operative ground-truth narrowed to 2 (lines 513 PATCH spec + 529 dismissal note + 551 Change Log v1.6 historical entry preserved per repo convention — touching them would self-corrupt the spec or violate Change Log immutability). Change Log v1.9 entry inserted in correct chronological position (v1.7 → v1.8 → v1.9) after one-shot reorder via awk swap (initial Edit prepended v1.9 before v1.8; awk swap fixed). All gates GREEN at step 4: typecheck 16/16 (FULL TURBO 172ms), lint 16/16 (FULL TURBO 115ms), keel-invariants 10 files / 52 tests (758ms; 4-drift baseline UNCHANGED — 0 NEW drift from cosmetic .md edits), pytest 4/4 (0.20s). Cumulative pre-merge PATCH Story 1.21 lifecycle: **24** projected UNCHANGED (PATCH-17 was already counted at iter-425 +3 CR-pass-3 raise; landing it does not change projection). Step 5 push will carry 3 commits: `1bda4be` (PATCH-16, deferred from iter-428), `c74ac9f` (iter-428 close-out IP note), and the new PATCH-17 commit. NOW advances to top QUEUE CR-pass-4 (forecast 0–2 residual per iter-425 carry-rule). **Path forward:** CR-pass-4 (iter-430) → if 0 PATCH: Epic 1 reclose + PR #236 Draft→Open final CI gate + EPIC_DONE halt → § Cross-epic transition on next invocation post-merge; if 1+ PATCH: continue fix-arc per FR14n matrix.

- [x] iter-428: **PATCH-16 LANDED — 8 CR-pass-1 patch checkboxes flipped at story-file lines 438-445 + PATCH-16 self-flip at line 512.** FR14n `fixes-pending` UNCHANGED (PATCH-17 still pending at iter-428 close). Audit-trail integrity restored: action-item checkbox state now matches content-state. Story file gained `### v1.8 (iter-428 — 2026-04-26)` Change Log entry. **iter-428 carry-rule landed in RALPH.md Lessons (14th class):** IP-planner operative-grep-pattern-vs-target-set reconciliation — when IP-planner sweep specs include BOTH an operative grep pattern AND a line range AND the grep returns wrong-count matches, fall back to the line range from the PATCH spec text as ground-truth. Pre-push CI gate at step 0h: api.github.com class **43rd cumulative datapoint** sub-class (a) endpoint-split (graphql `gh pr checks 236` failed with i/o timeout to `140.82.121.6:443` again; LADDER step 2 REST `gh api repos/.../commits/<sha>/check-runs` cleared first-try; both checks PASS for SHA `6a53fec` iter-427 push: node + python = success). All gates GREEN at step 4: typecheck 16/16, lint 16/16, keel-invariants 52/52, pytest 4/4. Local commit `1bda4be` (PATCH-16) UNPUSHED due to SSH-egress flake at iter-428 step 5 (18th datapoint of iter-372 SSH-egress class).

- [x] iter-427: **PATCH-14 LANDED — SCP § citation fix at story-file lines 30 + 155.** FR14n `fixes-pending` UNCHANGED. Operative `replace_all` of `SCP § Section 4.2` → `SCP § 4.1`. PATCH-14 checkbox flipped at line 511. **iter-427 carry-rule landed in RALPH.md Lessons (13th class):** IP-planner sweep-count vs operative-grep reconciliation — when prior-iter IP claims K occurrences AND specifies the operative grep pattern, re-run the operative grep AT FIX-TIME and trust it as source-of-truth. All gates GREEN.

- [x] iter-426: **CI monitoring iteration — PR #236 SHA `8aa3e4e` (iter-425 CR-pass-3 push) CI cleared at iter-426 step 0h.** node + python both PASS first-try at LADDER step 1.

- [x] iter-425: **Story 1.21 CR-pass-3 LANDED — 18+ findings raised across 3 parallel review layers; triaged into 3 PATCH + 1 DEFER + ~14 DISMISSED.** FR14n `fixes-pending → fixes-pending` (3 NEW PATCH raised). All 6 ACs reconfirmed satisfied at operative-test level. **3 NEW PATCH raised:** PATCH-14 (SCP § citation), PATCH-16 (8 stale CR-pass-1 PATCH checkboxes), PATCH-17 (categorical-wording fix). **NEW carry-rule landed iter-425:** CR-pass-(N+1) forecast must NOT extrapolate "0 residual" from CR-pass-N's success rate; conservative forecast bound = max(0, |unique-finding-classes-not-yet-surfaced|), ~1–3 PATCH per CR-pass-N≥2 until 2-consecutive-zero-PATCH CR passes confirm convergence.

- [x] iter-422 + iter-423 + iter-424: PATCH-10 + PATCH-11 + PATCH-12 LANDED (3-PATCH CR-pass-2 fix-arc complete). Detail in RALPH.md signposts.

- [x] iter-421: **Story 1.21 CR-pass-2 PASS — 9 findings (3 PATCH + 1 DEFER + 5 DISMISSED).** FR14n `fixes-pending → fixes-pending`. **NEW carry-rule:** Sweep-completion carry-rule.

- [x] iter-409..420: Story 1.21 CR-pass-1 fix-arc PATCH-1..9 (9 of 9 LANDED) + multi-deferred-push tracker drains. Detail in RALPH.md signposts.

- [x] iter-404: **Story 1.21 `/bmad-code-review (args: "2")` CR-pass-1 — 23 findings → 9 PATCH + 6 DEFER + 8 DISMISSED.** FR14n `sm-verified → fixes-pending`.

- [x] iter-401..403: Story 1.21 dev-story (iter-401 0 PATCH) → trace (iter-402 0 PATCH) → SM-verify (iter-403 2 PATCH).

- [x] iter-398..400: Story 1.21 drafted → SM-validated (7 PATCH) → ATDD-skipped pure ground (a) substrate-verification.

- [x] iter-1: `/bmad-correct-course` on issue #233 — Sprint Change Proposal; Epic 1 REOPENED for Stories 1.17–1.21.

## Context

- **Phase:** 4-implementation — Story 1.21 CR-pass-3 fix-arc CONTENT-COMPLETE; iter-429 PATCH-17 LANDED. Path: CR-pass-4 (iter-430) re-run → Epic 1 reclose.
- **Runtime:** cc-devbox iteration env. `uv 0.11.7` + `pnpm` available. Python 3.12.3 satisfies `requires-python = ">=3.10"`. github.com / api.github.com network access intermittent (api-egress-flake class — **43 cumulative datapoints** at iter-429 step 0h: REST `gh api repos/tthew/ralph-bmad/commits/<sha>/check-runs` cleared first-try LADDER step 2 against SHA `6a53fec` (node + python both green); recovery-streak-4 on REST endpoint after graphql failure pattern; intermittent-graphql-flake confirmed iter-426..428); ssh-egress-flake class distinct (17 cumulative datapoints across iter-372..420b; 18th at iter-428 step 5 push deferred).
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (REOPENED for Stories 1.17–1.21).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` — this work targets it as the PR base, not `main`.
- **Working Branch:** `chore/correct-course-test-runner-233` (based on `origin/feat/epic-2-packaged-devbox`).
- **Story:** 1.21 — Sweep prior `ATDD deferred` stories into `test-debt:` follow-ups.
- **Story File:** `_bmad-output/implementation-artifacts/1-21-sweep-prior-atdd-deferred-stories-into-test-debt-followups.md`.
- **Story State:** `fixes-pending` per FR14n § Story Lifecycle Decision Matrix. **CR-pass-3 fix-arc CONTENT-COMPLETE** at iter-429 (PATCH-14 + PATCH-16 + PATCH-17 all LANDED). Per FR14n `fixes-pending` row exit condition: QUEUE PATCH items now drained, re-run `/bmad-code-review (args: "2")` CR-pass-4 to confirm `done`. **NOW = `/bmad-code-review (args: "2")` CR-pass-4 re-run (forecast 0–2 residual per iter-425 carry-rule).** **Path:** CR-pass-4 (iter-430) → if 0 PATCH: Epic 1 reclose + PR #236 Draft→Open final CI gate + EPIC_DONE halt → § Cross-epic transition on next invocation post-merge; if 1+ PATCH: continue fix-arc.
- **GitHub Issue:** Issue #233 ("Course Correction: Bootstrap test runner + CI"). PR #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`) carries `Refs #233`; `Closes #233` lands at Story 1.21 close-out.
- **PR:** #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`).

## Notes

- **Story 1.21 forecast envelope (post-iter-429 PATCH-17 LANDED — CR-pass-3 fix-arc CONTENT-COMPLETE):** Cumulative pre-merge PATCH **24 projected UNCHANGED** (PATCH-17 was already counted at iter-425 +3 CR-pass-3 raise; landing it does not change projection). Stage breakdown: 7 SM-validate + 2 SM-verify + 9 CR-pass-1 + 3 CR-pass-2 + 3 CR-pass-3 = 24. Forecast residual: CR-pass-4 (forecast 0–2 residual per iter-425 carry-rule). Cumulative residual envelope post-iter-429: **24–26 final** (within 13–43 first-datapoint-of-class envelope; tracking toward upper-band as multi-CR-pass class extends).
- **NEW carry-rule iter-428 (14th class — IP-planner operative-grep-pattern-vs-target-set reconciliation):** when IP-planner sweep specs include BOTH an operative grep pattern AND a line range, BOTH must be reconciled at fix-time. If the grep returns wrong-count (under or over), fall back to the line range from the PATCH spec text as ground-truth.
- **NEW carry-rule iter-427 (13th class — IP-planner sweep-count vs operative-grep reconciliation):** when prior-iter IP claims K sweep occurrences AND specifies the operative grep pattern, re-run the operative grep AT FIX-TIME and trust it as source-of-truth over IP's claimed count.
- **CR-pass-(N+1) forecast carry-rule (iter-425; extension of iter-421 sweep-completion):** CR-pass-(N+1) forecast must NOT extrapolate "0 residual" from "100% success rate of CR-pass-N PATCH against the carry-rule(s) known at CR-pass-N" — each CR-pass-N may surface NEW finding classes invisible at CR-pass-(N-1). Conservative forecast bound = max(0, |unique-finding-classes-not-yet-surfaced|), ~1–3 PATCH per CR-pass-N≥2 until 2-consecutive-zero-PATCH CR passes confirm convergence.
- **Sweep-completion carry-rule (iter-421; precedent applied at iter-422/423/424 + iter-429):** When CR-pass-N PATCH targets a count-drift, sweep ALL occurrences via `grep -n '<old-value>' <file>` before claiming PATCH-N done. **iter-429 PATCH-17 extension:** carry-rule applies cleanly even when target substring has 2 word-order variants (lines 156 "ATDD-skips post-bootstrap" vs 325 "post-bootstrap ATDD-skips") — each variant requires a distinct Edit call but the count-drift-axis sweep verb stays valid; preserve narrative-quoted/historical occurrences (PATCH-spec quoting + dismissal-note + Change-Log historical entries).
- **Audit + sweep class envelope CALIBRATED at iter-425 CR-pass-3 (6 datapoints):** dev-story 0-PATCH + trace 0-PATCH + SM-verify 2-PATCH + CR-pass-1 9-PATCH + CR-pass-2 3-PATCH + CR-pass-3 3-PATCH (mid-band 0–6). Future audit + sweep stories inherit envelope dev-story 0–3 / trace 0–2 / SM-verify 1–4 / CR-pass-1 0–9 / CR-pass-N≥2 0–4.
- **api.github.com network class (43 cumulative datapoints across iter-397..428):** Sub-classes by endpoint affected: (a) endpoint-split graphql-only (incl iter-426 + iter-427 + iter-428 — recovery-streak-4 on REST endpoint; intermittent-graphql-flake confirmed iter-426..428 = 3-consecutive-iter graphql-fail-with-REST-recovery); (b) joint-endpoint cross-iter; (c) joint-endpoint within-iter recovery; (d) **4-endpoint within-iter joint-flake NO-recovery** (iter-415 NEW; 2 surfacings iter-415 + iter-423; intermittent confirmed at iter-424..428). LADDER carry-rule: (1) `gh pr checks <PR> --watch --fail-fast`; (2) REST `gh api repos/<owner>/<repo>/commits/<sha>/check-runs`; (3) graphql `gh pr checks <PR>` one-shot; (4) defer push to next iter OR fall-through to work iff ORIGIN SHA was already proven GREEN at a PRIOR iter and no new push has intervened.
- **Course-correction precedent stack 3 deep:** issue #231 (PR #234 MERGED) → issue #232 (PR #235 MERGED) → issue #233 (PR #236 in-flight; pending Story 1.21 close + Draft→Open final CI gate). Issue #233 is the first to REOPEN a closed epic.
- **Epic 4 hard-precondition:** Epic 4 (per-iteration security verification) extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Stories 1.19 + 1.20 backfill IS LANDED + DONE; Epic 4 unblock requires Story 1.21 + Epic 1 reclose.
- **iter-372 SSH-egress flake carry-rule (18 cumulative datapoints across iter-372..428):** kill-after-hang + retry-fail sub-class. First-retry-resolves carry-rule does NOT always hold (iter-428 18th datapoint = 2 consecutive `ssh: connect to host github.com port 22: Connection timed out`).
- **Iter-358 INV-git-hooks-preservation worktree-mode drift carry-rule (carry-forward to Epic 4 hardening):** Story 1.17 + 1.18 + 1.19 + 1.20 + 1.21 disposition (c) carry-forward unchanged. 4-drift sync-gate baseline persists.
