# Implementation Plan — PR #230 Round-5 final-merge-gate review

Detail in `.ralph/round5-fix-arc.md`. Previous rounds: `round4-fix-arc.md`, `round3-fix-arc.md`, `round2-fix-arc.md`. Round-4 EPIC_DONE halt reversed by user 2026-05-05 directing Round-5 sweep + codex sparring on HEAD `799c877`. **FIX-19 landed `027efa7`; awaiting push-trigger CI to confirm green; +1 EPIC_DONE halt gated on CI.**

## NOW

- [ ] **Push FIX-19 + monitor CI** — push `027efa7` to remote; monitor `gh pr checks 230 --watch --fail-fast`; on 4/4 GREEN → write +1 EPIC_DONE halt; on red → diagnose + fix.

## QUEUE (Round-5 fix-arc)

- [ ] **Final +1 merge gate** — write EPIC_DONE halt with `r5-merge-+1` note: `{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"R5-complete: FIX-19 landed (027efa7); 27/27 R5 payloads BLOCK; sync-gate clean; 82/82 hook regression; 56/56 vitest; awaiting human merge"}`. ~tiny

## BLOCKED

_(none)_

## DONE (Round-5 only — full audit trail in `.ralph/round5-fix-arc.md`)

- [iter-pr230-r5-dispatch-synthesis] Round-5 adversarial dispatch (Claude×3 + codex sparring) + 27-payload empirical bypass map; CRITICAL finding R5-A1 (alternate-shell wrapper bypasses 11+ shells/forms across 3 protection classes); FIX-19 design captured. Round-5 fix-arc opened. Commit `4fd7c64`.
- [iter-pr230-r5-fix-19] FIX-19 landed `027efa7` — wrapper-strip alternation extended (bash|sh|zsh|dash|ksh|mksh|ash|fish|csh|tcsh|busybox+sh) + path-prefix + flag-bundle + long-flag + bundled-c-flag forms; substrate ↔ seed byte-identical; manifest contentHashes for `INV-claude-hook-secret-denylist` + `-seed` bumped in lockstep (`fea60018…` → `35c5b484…`). Empirical re-validation: all 27 R5 payloads now BLOCK (was 11 BYPASS pre-fix); regression suite 82/82; sync-gate clean; typecheck+lint+test (56/56) GREEN. Codex sparring environmentally blocked (bubblewrap sandbox issue), not a substantive blocker — the empirical 27-payload before/after delta is conclusive.

## Context

- **Phase:** 4-implementation — Round-5 final-merge-gate adversarial review.
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done`; PR #230 OPEN/CLEAN/MERGEABLE.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypassed § Story Lifecycle.)_
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 OPEN, isDraft=false, MERGEABLE/CLEAN; HEAD `027efa7` (FIX-19 + R5 audit trail; awaiting push-trigger CI). Round-5 verdict pending CI: 4/4 GREEN → +1 EPIC_DONE halt; red → diagnose + fix.
