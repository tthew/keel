# Implementation Plan — PR #230 Round-3 review-fix-arc

Detail: `.ralph/round3-fix-arc.md` (Round-2 closeout at `.ralph/round2-fix-arc.md`). The IP holds NOW + QUEUE + DONE + Context only.

## NOW

- [ ] **Monitor PR #230 CI** — `gh pr checks 230 --watch --fail-fast` (1 node job pending at HEAD `b1ee46d`; 3/4 already pass). On pass: promote next QUEUE → NOW. On fail: queue fix tasks per failure to TOP of QUEUE. ~small.

## QUEUE (Round-3 fix-arc; pull from `.ralph/round3-fix-arc.md`)

- [ ] **Round-3 thread-resolve sweep** — live unresolved=2 (A5+A6 DEFER-by-design); no R3 reviewer threads posted. Self-post R3-self-review summary comment per Round-2 pattern (`iter:pr-230-round2-decompose`) listing FIX-12..16 + WONTFIX-doc landings + DEFER A5/A6 + NOFIX R3-I03..I06. Mark sweep done.
- [ ] **Final CI watch + EPIC_DONE halt** — re-check CI clean → write `EPIC_DONE` per `.ralph/round3-fix-arc.md § Halt criterion`.

## DONE (Round-3 only — Round-1+2 archived in git log + RALPH.md `iter:pr-230-fix-1..11` + `iter:pr-230-wontfix-d1d2d3` + `iter:pr-230-thread-resolve-sweep` + `iter:pr-230-epic2-halt`)

- [iter-pr230-round3-decompose] decompose Round-3 review fan-out — `69341fa` (PR #230)
- [iter-pr230-fix-12] close R3-Hook-A subshell-form bypass — `4420c3f` (PR #230)
- [iter-pr230-fix-13] close R3-Hook-B verb-list + dot-source bypass — `d3c127a` (PR #230)
- [iter-pr230-fix-14] wire keel-invariants drift gate to pre-commit + CI — `8115bb2` (PR #230)
- [iter-pr230-fix-15] close awk-injection class via shape gates — `e4bf2d5` (PR #230)
- [iter-pr230-fix-16] replace stale literal line refs with section refs — `4a8642b` (PR #230)
- [iter-pr230-wontfix-r3] inline WONTFIX-doc R3-H48/H49/D03/D04 — `b1ee46d` (PR #230)
- [iter-pr230-prune] prune IP back under 8K doc-budget cap (PR #230)

## Context

- **Phase:** 4-implementation — PR #230 Round-3 review-fix-arc landings complete (FIX-12..16 + WONTFIX-doc). Remaining: thread-resolve sweep + final CI gate + EPIC_DONE halt.
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done`; PR #230 OPEN/CLEAN/MERGEABLE awaiting closeout.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent.)_
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 OPEN, isDraft=false; HEAD `b1ee46d`; CI in-flight (1 node pending, 3/4 already pass). Live unresolved-thread count: 2 (A5+A6 DEFER-by-design); no R3 reviewer threads posted.
