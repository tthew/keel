# Implementation Plan

## NOW

_(empty — Epic 1 DONE at iter-95; EPIC_DONE halt written; ralph.py will halt loop on next orient)_

## QUEUE (Epic 1 — CLOSED)

_(empty — Epic 1 terminated; next loop invocation in plan-mode will open Epic 2 — Packaged Devbox)_

## BLOCKED

_(none)_

## DONE (Epic 1 terminal iteration only — prune prior story iterations on next epic)

- [x] iter-95: **Epic 1 EPIC_DONE terminal sequence.** PR #226 `Draft → Open` via `gh pr ready` (#226 state flipped `isDraft:false`); PR body + title rewritten Epic-1-scoped (`feat(epic-1): Substrate Foundation & Machine-Enforced Invariants — Stories 1.8–1.16`); `Closes #33–#40` added for Stories 1.9–1.16 story-issue auto-closure on merge (Story 1.8 issue #32 already CLOSED pre-PR, preserved as `Refs #32`; Epic-1 issue #9 as `Refs #9` — Ralph does NOT manually `Closes` epic issues per ralph.py EPIC_DONE automation contract); final CI gate green (`gh pr checks 226 --watch --fail-fast` exit 0 — "no checks reported on the 'feat/story-1-8-invariants-manifest-ts-contract-exporter' branch" since CI runners not yet authored pre-Epic-13 wiring); PR review feedback fetch clean (`reviews:[], comments:[]`). Post-CI-green actions executed: (a) `sprint-status.yaml` `epic-1: in-progress → done` + `last_updated: 2026-04-21 Story-1-16-done → Epic-1-done UTC`; (b) IP terminal mark; (c) RALPH.md Epic-1 retrospective signpost appended; (d) commit `chore(ralph): Story 1.16 iter-95 — Epic 1 DONE; PR #226 Draft→Open; EPIC_DONE halt` with trailer `Refs #40`; (e) push to `origin feat/story-1-8-invariants-manifest-ts-contract-exporter`; (f) `{"reason":"EPIC_DONE","epic":1,"pr":226}` written to `$RALPH_BASE_DIR/halt` (resolves `/workspace/ralph-bmad/.claude/worktrees/ralph/.ralph/halt` per ralph.py worktree-scoped exporter). ralph.py reads halt + stops loop + transitions Epic-1 issue #9 to Done via GitHub project workflow. **Epic 1 — Substrate Foundation & Machine-Enforced Invariants — closes at 16 stories done across ~95 Ralph iterations.**

## Context

- **Phase:** 4-implementation — **Epic 1 CLOSED.** Next invocation: plan-mode (gap analysis toward Epic 2 — Packaged Devbox).
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants — **DONE at iter-95.** 16/16 stories complete.
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (retained post-merge until Epic 2 opens; PR #226 Open awaits human merge).
- **Story:** _(none — Epic 1 closed at iter-95)._
- **Story File:** _(n/a — next invocation in plan-mode or Epic 2 Story 2.1)._
- **Story State:** _(no story)._
- **GitHub Issue:** Story 1.16 #40 closes on PR #226 merge via GitHub native `Closes #40` automation. Epic 1 #9 transitions to Done by ralph.py on EPIC_DONE halt detection.
- **PR:** #226 **Open** — awaits human merge + CI runners (CI wiring lands in Epic 13).

## Notes

- **Epic 1 terminal retrospective (compressed signposts).**
  - 16 stories landed across ~95 Ralph iterations (iter-1 Story 1.8 spec → iter-95 EPIC_DONE halt).
  - 6 of 16 stories (1.11, 1.12, 1.13, 1.14, 1.15, 1.16) held **compound-ZERO-PATCH-discipline** across the full `atdd-scaffolded → in-dev → traced → sm-verified → done` lifecycle — single-pass dev + ZERO-PATCH trace + ZERO-PATCH post-dev SM + ZERO-PATCH CR.
  - 10 cumulative trace-WAIVED precedents (`/bmad-testarch-trace` invoked but coverage waived on docs/config-only stories).
  - 10 cumulative ATDD-SKIP precedents (no-testable-AC stories allowed state `validated → atdd-scaffolded` without red-phase scaffold per PROMPT_build.md guardrail 4).
  - Inherited-drafting-drift class: Story 1.14 iter-80 + 1.15 iter-87 + 1.16 iter-94 all routed `packages/create-keel-app/` not-yet-existing prose drift to DEFER (carry to Epic 15a) rather than PATCH in-epic; preserves cross-epic doc-sync contract.
  - FR42/FR43/FR44/FR45 substrate invariant quartet fully anchored: INVARIANTS.md index + sync-gate drift detector + fork-extension ESLint pattern + Growth-tier INVARIANTS.fork.md scaffold. Fork extension substrate-wins precedence invariant held across 5-surface framing audit (Story 1.16 iter-94 CR Edge Case Hunter triad).
- **EPIC_DONE halt path rule.** `$RALPH_BASE_DIR` exported by ralph.py resolves to `/workspace/ralph-bmad/.claude/worktrees/ralph/.ralph/`. Writing halt to `$RALPH_BASE_DIR/halt` (via shell expansion) or the equivalent relative `.ralph/halt` from worktree cwd both work. Hardcoded main-repo absolute path (`/workspace/ralph-bmad/.ralph/halt`) is WRONG — ralph.py will not detect it from the worktree subprocess (2026-04-20 Story 1.7 iter-22..28 re-entry cascade incident). Verified at iter-95 commit-time: halt written to worktree-scoped `$RALPH_BASE_DIR/halt`.
- **Next Ralph invocation.** Epic 1 closed. The next `uv run ralph.py build` will find `epic-1: done` + no open stories in Epic 1, match the Halt-sentinel absent condition (ralph.py cleans halt on startup), and enter orient for plan-mode or Epic 2 kickoff. Recommended: run `/bmad-help` to confirm phase transition + queue Story 2.1 (`packages/devbox/` absorb + substrate tooling access) via `/bmad-create-story`.
