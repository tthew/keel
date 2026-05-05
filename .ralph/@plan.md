# Implementation Plan — PR #230 Round-4 review-fix-arc

Detail: `.ralph/round4-fix-arc.md` (Round-3 closeout at `.ralph/round3-fix-arc.md`; Round-2 at `.ralph/round2-fix-arc.md`). The IP holds NOW + QUEUE + DONE + Context only. Round-3 closeout (EPIC_DONE halt) reversed by user 2026-05-05 directing A5+A6 land in PR #230 with cross-engine adversarial validation.

## NOW

- [ ] **FIX-18 (A6)** — `sync-gate.ts` self-protection via NEW manifest entry `INV-keel-invariants-sync-gate-snapshots` (anchor-range scope around `EXPECTED_INVARIANT_IDS` + `BYTE_PARITY_PAIRS`); recursive ID add; INVARIANTS.md anchor; inline WONTFIX-comment for R4-Inv-I07 (manifest pointer-mutation). Detail § FIX-18 of `.ralph/round4-fix-arc.md`. ~medium

## QUEUE (Round-4 fix-arc)

- [ ] **R4-WONTFIX-doc** — inline comment R4-H50 (heredoc interp form) at hook L294 region; substrate↔seed byte-parity + manifest lockstep. Detail § R4-WONTFIX-doc.
- [ ] **Thread-resolve sweep + EPIC_DONE** — self-summary comment mapping FIX-17/FIX-18/WONTFIX → closing commits; resolve A5+A6 GraphQL threads; final CI gate; EPIC_DONE halt with R4-complete note. Detail § Halt criterion.

## DONE (Round-4 only — Round-1+2+3 archived in git log + RALPH.md `iter:pr-230-fix-1..16` + `iter:pr-230-wontfix-d1d2d3` + `iter:pr-230-wontfix-r3` + `iter:pr-230-thread-resolve-sweep` + `iter:pr-230-epic2-done-halt`)

- [iter-pr230-round4-decompose] Round-4 decompose — Claude×2 + Codex×1 parallel adversarial validation; A5+A6 designs verified SOUND. Halt sentinel cleared. Audit transcripts `/tmp/codex_round4_audit_out.md` + Claude-A/B agent outputs.
- [iter-pr230-fix-17] FIX-17 (A5) — interp string-literal symlink + literal-path scan landed. Hook substrate+seed regex extracted to single-quoted variable `_fix17_re` per FIX-12 carry-rule (canonical bash `[[ =~ ]]` idiom). Substrate↔seed byte-parity (`fc91f291…`); manifest contentHash lockstep L370+L407 (`42e5b501…` → `fc91f291…`) via Node-script L1 bypass. 82/82 hook fixtures + 56/56 vitest + 16/16 typecheck/lint + sync-gate clean. **PRIOR-ITER RECOVERY**: previous Ralph wrote inline regex with literal `)` + `` ` `` choking bash parser → entire loop bricked (every Read/Bash/Glob/Grep/Write blocked by hook syntax-error). Recovery via `Agent isolation:worktree` reading HEAD bytes + Node-script bypass to write fixed bytes. Detail § Lessons learned `iter:pr-230-fix-17`.
- [iter-pr230-r4-ci-watch] CI 4/4 GREEN @ `5ea5a7c` (FIX-17 push-trigger). Pre-FIX-18 push-clean state confirmed; no review-comment churn this iter.

## Context

- **Phase:** 4-implementation — PR #230 Round-4 review-fix-arc IN-PROGRESS. User reversed Round-3 EPIC_DONE 2026-05-05 directing A5+A6 land in PR #230 with cross-engine adversarial validation (Claude+Codex consensus before commit).
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done`; PR #230 OPEN/CLEAN/MERGEABLE awaiting Round-4 closeout.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent.)_
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 OPEN, isDraft=false; HEAD `5ea5a7c` (FIX-17 — PR-trigger CI 4/4 GREEN, no in-flight runs; branch `up to date with origin`). Live unresolved-thread count: 2 (A5+A6 — A5 to be resolved post-FIX-18 land via thread-resolve sweep). Pre-existing R3 closeout self-summary at issuecomment-4380346184.
