# Implementation Plan — PR #230 Round-5 final-merge-gate review

Detail in `.ralph/round5-fix-arc.md`. Previous rounds: `round4-fix-arc.md`, `round3-fix-arc.md`, `round2-fix-arc.md`. Round-4 EPIC_DONE halt reversed by user 2026-05-05 directing **Round-5: independent adversarial sweep + codex sparring** on HEAD `799c877`. Final pre-halt gate is +1/-1 on whether PR #230 should be merged. **Round-5 dispatch+synthesis COMPLETE this iter → 1 CRITICAL finding R5-A1 → FIX-19 in QUEUE.**

## NOW

- [x] **Round-5 dispatch + synthesis** — Agent A (hook bypass) returned 1 finding (R5-A1 alternate-shell wrapper); empirically verified by 27 payload runs (11 confirmed bypasses across zsh/dash/ksh/mksh/ash/fish/csh/tcsh/busybox+sh + path-prefix + flag-bundle + multi-wrap forms; covers secret-access + hook-self-protection + --no-verify). Agent B (sync-gate/manifest) verdict CLEAR. Agent C (spec-compliance) verdict COMPLIANT. Codex run pending. Synthesis → FIX-19 design captured in `.ralph/round5-fix-arc.md`.

## QUEUE (Round-5 fix-arc)

- [ ] **FIX-19 (R5-A1) — extend wrapper-shell alternation** at hook substrate L77; mirror to seed; bump manifest contentHashes for `INV-claude-hook-secret-denylist` (substrate) + `INV-claude-hook-secret-denylist-seed`; design captured in `.ralph/round5-fix-arc.md` § FIX-19. ~medium
- [ ] **FIX-19 empirical-validation + regression** — re-run all 27 R5 payloads (must flip 11 BYPASS → BLOCK; rest stay correct); re-run R1-R4 hook-fixture regression (≥ 82/82 GREEN); run typecheck + lint + test; codex sparring confirmation. ~small
- [ ] **Final +1 merge gate** — post-FIX-19 CI watch; if 4/4 GREEN + zero findings on follow-up codex audit, write EPIC_DONE halt with `r5-merge-+1` note. ~small

## BLOCKED

_(none)_

## DONE (Round-5 only — full audit trail in `.ralph/round5-fix-arc.md`)

- [iter-pr230-r5-dispatch-synthesis] Round-5 adversarial dispatch (Claude×3 in parallel + codex sparring) + 27-payload empirical bypass map; CRITICAL finding R5-A1 (alternate-shell wrapper bypasses 11+ shells/forms across 3 protection classes); FIX-19 design captured. Round-5 fix-arc opened.

## Context

- **Phase:** 4-implementation — Round-5 final-merge-gate adversarial review.
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done`; PR #230 OPEN/CLEAN/MERGEABLE awaiting Round-5 verdict.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypassed § Story Lifecycle per landing-summary intent.)_
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 OPEN, isDraft=false, MERGEABLE/CLEAN; HEAD `799c877` (CI 4/4 GREEN). Round-5 dispatch complete this iter; FIX-19 (CRITICAL R5-A1 alternate-shell wrapper bypass) queued for next iter; +1 merge gate gated on FIX-19 land + codex confirmation.
