# Implementation Plan — PR #230 Round-2 review-fix-arc

Detail: `.ralph/round2-fix-arc.md` (inventory, recipes, sparring discipline, halt criterion). The IP holds NOW + QUEUE + DONE + Context only.

## NOW

- [ ] FIX-7 — close A1 + A4 via shell-separator boundary unification across hook verb regexes ~medium

## QUEUE (Round-2 fix-arc — order minimises merge conflict + maximises per-fix isolation)

- [ ] FIX-8 — close A3 via ANSI-C escape-decode pass after `$'…'` strip ~medium
- [ ] FIX-9 — close A2 via absolute-path redirect catch (L180 + L199 widening) ~small
- [ ] FIX-10 — close A7 via healthcheck v6 chain + policy-drop verification ~medium
- [ ] FIX-11 — close C1 via dnsmasq.conf comment items 2/3 reframe ~small
- [ ] WONTFIX-D1/D2/D3 — anchor inline `# WONTFIX` comments at hook L171, L251, L257 ~small
- [ ] DEFER A5 + A6 — append follow-up tracker note to RALPH.md § Open questions
- [ ] Thread-resolve sweep — Node-script reply + `resolveReviewThread` per Round-2 thread
- [ ] Monitor PR CI — `gh pr checks --watch --fail-fast` after final fix-arc push
- [ ] Transition PR — final CI gate → EPIC_DONE halt for cross-epic next-Ralph

## DONE

- [iter-pr230-round2-decompose] Round-2 review (12 unresolved) decomposed into FIX-6..11 + WONTFIX + 2 DEFER — `75bb178`
- [iter-pr230-fix-6] FIX-6 closes A8 — `main-repo-resolver.sh` REPO_NAME case-pattern rejects `..` / `.` / `*..*` (PR #230)

## Context

- **Phase:** 4-implementation — PR #230 Round-2 review-fix-arc.
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done`. Round-1 fix-arc closed at `4eaec8d`. Round-2 review reopened the PR 2026-05-05.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent)._
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 Open, isDraft=false, MERGEABLE, CLEAN. CI green at `75bb178` (4/4 SUCCESS). 11 unresolved Round-2 threads (A1-A7, C1, D1-D3) post-FIX-6; A8 closing-thread to be resolved in sweep iter.
