# Implementation Plan — PR #230 Round-4 review-fix-arc

Detail: `.ralph/round4-fix-arc.md` (Round-3 closeout at `.ralph/round3-fix-arc.md`; Round-2 at `.ralph/round2-fix-arc.md`). The IP holds NOW + QUEUE + DONE + Context only. Round-3 closeout (EPIC_DONE halt) reversed by user 2026-05-05 directing A5+A6 land in PR #230 with cross-engine adversarial validation.

## NOW

- [x] **Round-4 decompose** — Claude×2 + Codex×1 parallel adversarial validation of A5+A6 fix designs landed at `.ralph/round4-fix-arc.md`. Halt sentinel cleared. Trajectory: FIX-17 → FIX-18 → R4-WONTFIX-doc → sweep+EPIC_DONE.

## QUEUE (Round-4 fix-arc)

- [ ] **FIX-17 (A5)** — interpreter string-literal symlink + literal-path scan in `.claude/hooks/block-secret-access.sh` Bash-arm; substrate↔seed byte-parity + manifest contentHash lockstep (L370 + L407); empirical 13-payload + R1+R2+R3 regression + codex sparring. Detail § FIX-17 of `.ralph/round4-fix-arc.md`.
- [ ] **FIX-18 (A6)** — `sync-gate.ts` self-protection via NEW manifest entry `INV-keel-invariants-sync-gate-snapshots` (anchor-range scope around `EXPECTED_INVARIANT_IDS` + `BYTE_PARITY_PAIRS`); recursive ID add; INVARIANTS.md anchor; inline WONTFIX-comment for R4-Inv-I07 (manifest pointer-mutation). Detail § FIX-18.
- [ ] **R4-WONTFIX-doc** — inline comment R4-H50 (heredoc interp form) at hook L294 region; substrate↔seed byte-parity + manifest lockstep. Detail § R4-WONTFIX-doc.
- [ ] **Thread-resolve sweep + EPIC_DONE** — self-summary comment mapping FIX-17/FIX-18/WONTFIX → closing commits; resolve A5+A6 GraphQL threads; final CI gate; EPIC_DONE halt with R4-complete note. Detail § Halt criterion.

## DONE (Round-4 only — Round-1+2+3 archived in git log + RALPH.md `iter:pr-230-fix-1..16` + `iter:pr-230-wontfix-d1d2d3` + `iter:pr-230-wontfix-r3` + `iter:pr-230-thread-resolve-sweep` + `iter:pr-230-epic2-done-halt`)

- [iter-pr230-round4-decompose] Round-4 decompose — Claude×2 + Codex×1 parallel adversarial validation; A5+A6 designs verified SOUND (codex Q7 chicken-and-egg → false alarm; claude-A sync-gate.ts:227 confabulation disproven by direct read). R4-H50 (heredoc) → WONTFIX-doc; R4-H51 (`file`/`stat` metadata-readers) → NOFIX (not content-readers); R4-Inv-I07 (manifest pointer-mutation) → inline WONTFIX (pre-existing structural limit at anchor-range layer). Halt sentinel cleared. Audit transcripts `/tmp/codex_round4_audit_out.md` + Claude-A/B agent outputs.

## Context

- **Phase:** 4-implementation — PR #230 Round-4 review-fix-arc IN-PROGRESS. User reversed Round-3 EPIC_DONE 2026-05-05 directing A5+A6 land in PR #230 with cross-engine adversarial validation (Claude+Codex consensus before commit).
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done`; PR #230 OPEN/CLEAN/MERGEABLE awaiting Round-4 closeout.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent.)_
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 OPEN, isDraft=false; HEAD `288e676` (PR-trigger CI 4/4 GREEN; 1 push-trigger node CANCELLED at 15min — runner timeout, not code). 1 unpushed local commit `cbc07aa` (prior Round-3 closeout intent IP — superseded by this Round-4 commit). Live unresolved-thread count: 2 (A5+A6 — to be resolved post-FIX-17+FIX-18). Pre-existing R3 closeout self-summary at issuecomment-4380346184.
