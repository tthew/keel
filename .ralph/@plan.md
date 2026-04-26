# Implementation Plan

## NOW

_(empty — iter-435 EPIC 1 RECLOSE close-out complete; halt JSON `{"reason":"EPIC_DONE","epic":1,"pr":236}` written to `$RALPH_BASE_DIR/halt`. On next invocation post-merge of PR #236 → `feat/epic-2-packaged-devbox`, § Cross-epic transition step 1-3 branches autonomously: queries `gh pr view 236 --json state,mergedAt`; if MERGED + sprint-status has next epic backlog story `3.1` → NOW = `Run /bmad-create-story`, Epic = `Epic 3 - <title>`, Story = `3.1`, Story State = `_(no story)_`, PR: n/a; if not yet merged → re-writes EPIC_DONE halt; if no next epic in sprint-status → ALL_EPICS_DONE terminal halt. Sprint-status confirms epic-3 in backlog with rows 3.1..3.17+ at lines 182-203, so post-merge auto-advance to Story 3.1 expected.)_

## QUEUE (post-EPIC_DONE re-entry)

_(empty — § Cross-epic transition handles re-entry post-merge autonomously per § Cross-epic transition step 1-3 branch logic; no pre-queued tasks needed for the post-merge iteration.)_

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty — Story 1.21 ATDD-skipped iter-400 via FR14n § ATDD-skip pure ground (a) substrate-verification per IP § ATDD Skip Rationale; no red-phase tests authored.)_

## DONE (current story phase only — pruned at iter-435; older fix-arc detail in RALPH.md signposts)

- [x] iter-435: **EPIC 1 RECLOSE LANDED — issue #233 SCP REOPEN-ARC complete.** All 5 REOPEN-ARC stories DONE: 1.17 (iter-220) + 1.18 (iter-260) + 1.19 (iter-330) + 1.20 (iter-397) + 1.21 (iter-434 CR-pass-5 PASS). Sprint-status `epic-1: in-progress → done` at line 137 (was 136 per IP — operative-grep-pattern-vs-line-ref reconciliation per iter-428 14th-class carry-rule; +1 line drift from iter-434 last_updated header prepend) + last_updated header prepended per iter-401 dev-story precedent (commit `480ceff`). PR #236 transitioned Draft→Open via `gh pr ready 236` (graphql clean first-try). PR body `Refs #233` → `Closes #233` via REST `gh api repos/.../pulls/236 --method PATCH --input <jq -Rs body>` (graphql LADDER step 1 i/o-timeout 4 consecutive vs same-host curl 200 — NEW api-egress-flake sub-class g: gh-CLI-graphql-vs-curl-divergence; REST LADDER step 2 cleared after 1 retry). Final CI gate PR #236 SHA `480ceff` PASS via `gh pr checks 236`: node 1m12s + python 11s; run 24961982720; reviews=0 + issue-comments=0 + pr-line-comments=0 → no PR review feedback to address per § PR Transition & Final CI Gate item 2. EPIC_DONE halt JSON `{"reason":"EPIC_DONE","epic":1,"pr":236}` written. Path: human merges PR #236 → next invocation § Cross-epic transition step 1-3 → branch (MERGED + epic-3 in sprint-status backlog) → NOW = `Run /bmad-create-story` for Story 3.1 in fresh context. **NEW api-egress-flake sub-class g landed iter-435 (gh-CLI-graphql-vs-curl-divergence; 47th cumulative datapoint of class):** `gh pr edit/view --json` graphql calls fail with `dial tcp 140.82.121.6:443: i/o timeout` while same-host `curl https://api.github.com/zen` returns 200 — gh CLI's graphql HTTP path uses different cached IP / TCP destination than ad-hoc curl. **NEW LADDER carry-rule sub-step:** when `gh pr edit --body-file` graphql times out, fall back to `gh api repos/<o>/<r>/pulls/<N> --method PATCH --input <jsonfile>` REST PATCH with `jq -Rs '{body: .}'` body wrapper. All gates GREEN at step 4: typecheck 16/16 (FULL TURBO 146ms), lint 16/16 (FULL TURBO 176ms), keel-invariants 10 files / 52 tests (270ms; 4-drift baseline UNCHANGED — 0 NEW drift from sprint-status .yaml edit), pytest 4/4 (0.22s).

- [x] iter-434: **CR-pass-5 PASS — 0 NEW PATCH (33 raw findings → 0 PATCH + 0 DEFER + 33 DISMISSED) — CONVERGENCE EVENT — FR14n `fixes-pending → done`.** First 0-PATCH CR pass in the 5-CR-pass audit-trail; matrix exit condition met. NEW carry-rule landed iter-434 (16th class — convergence-detection at-FIRST-zero-PATCH-CR-pass): the FR14n `fixes-pending` row exit condition is satisfied at the FIRST 0-PATCH CR pass, NOT a 2-consecutive-zero-PATCH alternative.

- [x] iter-433: PATCH-19 LANDED at commit `3c5216b` — line 513 `forecast-table line 240` → `line 234` + Change Log v1.12 + self-flip at line 551.

- [x] iter-432: PATCH-18 LANDED at commit `b3aa46a` — 2 sites period→hyphen at story-file lines 80 + 89 + Change Log v1.11 + self-flip at line 549.

- [x] iter-430..431: CR-pass-4 LANDED — 2 PATCH (PATCH-18 + PATCH-19) + 1 DEFER + ~12 DISMISSED across 3 parallel review layers; CI cleared on PR #236 SHA `cba5e3e`.

- [x] iter-425..429: CR-pass-3 LANDED — 3 PATCH (PATCH-14/16/17) + 1 DEFER + ~14 DISMISSED. NEW carry-rules: 13th-class IP-planner sweep-count vs operative-grep + 14th-class operative-grep-pattern-vs-target-set + 15th-class CR-pass-(N+1) forecast must NOT extrapolate "0 residual".

- [x] iter-421..424: CR-pass-2 LANDED — 3 PATCH (PATCH-10/11/12) + 1 DEFER + 5 DISMISSED. NEW carry-rule: Sweep-completion carry-rule.

- [x] iter-409..420: CR-pass-1 fix-arc PATCH-1..9 (9 of 9 LANDED).

- [x] iter-404..408: CR-pass-1 raised — 23 findings → 9 PATCH + 6 DEFER + 8 DISMISSED. FR14n `sm-verified → fixes-pending`.

- [x] iter-398..403: Story 1.21 drafted → SM-validated (7 PATCH) → ATDD-skipped pure ground (a) → dev-story (0 PATCH) → trace (0 PATCH) → SM-verify (2 PATCH).

- [x] iter-1: `/bmad-correct-course` on issue #233 — Sprint Change Proposal; Epic 1 REOPENED for Stories 1.17–1.21.

## Context

- **Phase:** 4-implementation — **EPIC 1 RECLOSE LANDED at iter-435; issue #233 SCP REOPEN-ARC complete.** EPIC_DONE halt JSON written to `$RALPH_BASE_DIR/halt`. Path: human merges PR #236 → next invocation § Cross-epic transition advances to Story 3.1 (epic-3 backlog confirmed at sprint-status lines 182-203) OR re-writes EPIC_DONE halt if PR not yet merged.
- **Runtime:** cc-devbox iteration env. `uv 0.11.7` + `pnpm` available. Python 3.12.3 satisfies `requires-python = ">=3.10"`. github.com / api.github.com network access intermittent (api-egress-flake class — **47 cumulative datapoints at iter-435**; iter-435 introduced NEW sub-class g: gh-CLI-graphql-vs-curl-divergence — `gh pr edit/view --json` graphql i/o-timeout while same-host curl 200; REST `gh api ... --method PATCH --input` workaround landed). ssh-egress-flake class **22 cumulative datapoints at iter-433** UNCHANGED at iter-434/435 (iter-435 step 5 push of `480ceff` cleared first-try — no flake).
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (RECLOSED at iter-435; **all 5 REOPEN-ARC stories DONE**: 1.17/1.18/1.19/1.20/1.21).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` — PR #236 base.
- **Working Branch:** `chore/correct-course-test-runner-233` (based on `origin/feat/epic-2-packaged-devbox`).
- **Story:** 1.21 — Sweep prior `ATDD deferred` stories into `test-debt:` follow-ups (DONE at iter-434).
- **Story File:** `_bmad-output/implementation-artifacts/1-21-sweep-prior-atdd-deferred-stories-into-test-debt-followups.md`.
- **Story State:** `done` (Epic 1 RECLOSED at iter-435 via § PR Transition & Final CI Gate; halt fired).
- **GitHub Issue:** Issue #233 ("Course Correction: Bootstrap test runner + CI"). PR #236 (OPEN, ready-for-review) carries `Closes #233` (body PATCHed at iter-435 via REST workaround); auto-closes issue on merge.
- **PR:** #236 (OPEN, ready-for-review, base: `feat/epic-2-packaged-devbox`; final CI gate PASS SHA `480ceff` run 24961982720).

## Notes

- **Story 1.21 forecast envelope FINAL (post-iter-434 CR-pass-5 PASS — convergence event; iter-435 EPIC 1 RECLOSE close-out non-PATCH):** Cumulative pre-merge PATCH **26 FINAL**. Stage breakdown: 7 SM-validate + 2 SM-verify + 9 CR-pass-1 + 3 CR-pass-2 + 3 CR-pass-3 + 2 CR-pass-4 + 0 CR-pass-5 = 26. Future audit + sweep stories inherit envelope dev-story 0–3 / trace 0–2 / SM-verify 1–4 / CR-pass-1 0–9 / CR-pass-N≥2 0–3 (N≥5 trends to 0 — convergence).
- **NEW carry-rule iter-435 (sub-class g — gh-CLI-graphql-vs-curl-divergence; LADDER carry-rule extension):** when `gh pr edit --body-file` graphql times out with `dial tcp 140.82.121.6:443: i/o timeout` while same-host `curl https://api.github.com/zen` returns 200, fall back to REST `gh api repos/<owner>/<repo>/pulls/<N> --method PATCH --input <jsonfile>` with `jq -Rs '{body: .}' < body.md > patch.json`. Reference incident: iter-435 PR #236 body `Refs #233` → `Closes #233` edit.
- **NEW carry-rule iter-434 (16th class — convergence-detection at-FIRST-zero-PATCH-CR-pass):** the FR14n `fixes-pending` row exit condition is satisfied at the FIRST 0-PATCH CR pass.
- **NEW carry-rules iter-427/428/425/421/432:** see RALPH.md signposts for full carry-rule lineage (13th-15th-class + iter-421 sweep-completion + iter-432 15a-class replace_all-narrative-quoted-preservation).
- **api.github.com network class (47 cumulative datapoints at iter-435):** Sub-classes: (a) endpoint-split graphql-only; (b) joint-endpoint cross-iter; (c) joint-endpoint within-iter recovery; (d) 4-endpoint within-iter joint-flake NO-recovery; **(g) NEW iter-435 — gh-CLI-graphql-vs-curl-divergence**. LADDER carry-rule: (1) `gh pr checks <PR> --watch --fail-fast`; (2) REST `gh api repos/<owner>/<repo>/commits/<sha>/check-runs`; (3) graphql `gh pr checks <PR>` one-shot; (4) defer push; **(5 NEW iter-435):** for body edits use REST `gh api ... --method PATCH --input <jsonfile>`.
- **Course-correction precedent stack 3 deep (1st 2 MERGED + 3rd RECLOSED at iter-435):** issue #231 (PR #234 MERGED) → issue #232 (PR #235 MERGED) → issue #233 (PR #236 OPEN ready-for-review, awaiting human merge).
- **Epic 4 hard-precondition:** UNBLOCKED at iter-435 EPIC 1 RECLOSE — all Stories 1.19 + 1.20 + 1.21 DONE + Epic 1 reclosed + PR #236 awaiting merge. Post-merge → Story 3.1 (next epic per sprint-status).
- **iter-372 SSH-egress flake carry-rule (22 cumulative datapoints; UNCHANGED at iter-435):** kill-after-hang + retry-fail sub-class. First-retry-resolves carry-rule applies ~82% of time per iter-433 extension. iter-435 step 5 push cleared first-try (no flake — datapoint 23 NOT raised).
- **Iter-358 INV-git-hooks-preservation worktree-mode drift carry-rule (carry-forward to Epic 4 hardening):** Story 1.17 + 1.18 + 1.19 + 1.20 + 1.21 disposition (c) carry-forward unchanged. 4-drift sync-gate baseline persists.
