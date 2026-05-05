# Implementation Plan — PR #230 Round-3 review-fix-arc

Detail: `.ralph/round3-fix-arc.md` (Round-2 closeout at `.ralph/round2-fix-arc.md`). The IP holds NOW + QUEUE + DONE + Context only.

## NOW

- [ ] **Write EPIC_DONE halt** — Step-0h CI gate clears first if pending. Then `echo '{"reason":"EPIC_DONE","epic":2,"pr":230}' > "$RALPH_BASE_DIR/halt"` per `.ralph/round3-fix-arc.md § Halt criterion`. ~small.

## QUEUE (none — closeout iter)

## DONE (Round-3 only — Round-1+2 archived in git log + RALPH.md `iter:pr-230-fix-1..11` + `iter:pr-230-wontfix-d1d2d3` + `iter:pr-230-thread-resolve-sweep` + `iter:pr-230-epic2-halt`)

- [iter-pr230-round3-decompose] decompose Round-3 review fan-out — `69341fa` (PR #230)
- [iter-pr230-fix-12] close R3-Hook-A subshell-form bypass — `4420c3f` (PR #230)
- [iter-pr230-fix-13] close R3-Hook-B verb-list + dot-source bypass — `d3c127a` (PR #230)
- [iter-pr230-fix-14] wire keel-invariants drift gate to pre-commit + CI — `8115bb2` (PR #230)
- [iter-pr230-fix-15] close awk-injection class via shape gates — `e4bf2d5` (PR #230)
- [iter-pr230-fix-16] replace stale literal line refs with section refs — `4a8642b` (PR #230)
- [iter-pr230-wontfix-r3] inline WONTFIX-doc R3-H48/H49/D03/D04 — `b1ee46d` (PR #230)
- [iter-pr230-ci-watch-cb0894c] monitor PR CI on cb0894c — CI GREEN 4/4 (PR #230)
- [iter-pr230-r3-self-summary] R3 closeout self-summary comment posted (issuecomment-4380346184) — FIX-12..16 + WONTFIX-doc map + DEFER A5/A6 + NOFIX (PR #230)

## Context

- **Phase:** 4-implementation — PR #230 Round-3 review-fix-arc closeout complete (FIX-12..16 + WONTFIX-doc landed; self-summary posted). Remaining: EPIC_DONE halt.
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done`; PR #230 OPEN/CLEAN/MERGEABLE awaiting closeout.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent.)_
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 OPEN, isDraft=false; HEAD `288e676`; CI GREEN 4/4 (2 node + 2 python; runs 25382951041 + 25382953573). Live unresolved-thread count: 2 (A5+A6 DEFER-by-design). R3 closeout self-summary at issuecomment-4380346184.
