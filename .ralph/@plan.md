# Implementation Plan

## NOW

- [x] **iter-24 — halt-sentinel re-write #3 (third consecutive post-EPIC_DONE re-entry).** Main-repo `/workspace/ralph-bmad/.ralph/halt` IS present with valid payload `{"reason":"EPIC_DONE","epic":1,"pr":224}` (mtime carry-over from iter-22/23 writes); main-repo `/workspace/ralph-bmad/.ralph/@plan.md:1` carries stale-but-valid-shape `(AWAIT_MERGE — Story 1.6 shipped; PR #222 Open; waiting for user merge)` marker from Story 1.6 that SHOULD halt ralph.py at `:1758`. PR #224 MERGED (unchanged from iter-23); Story 1.7 `done`; worktree clean; no unpushed commits. Per iter-22/23 Gotcha recipe (RALPH.md:100): idempotent re-write of main-repo halt (via absolute path per RALPH.md:88 rule), bookkeep iter-24, commit+push, exit. Third data point empirically strengthens "halt-sentinel re-write is the terminal no-op; no other work required" — both halt mechanisms (halt file + AWAIT_MERGE marker) remain armed at main repo between iterations despite the repeated re-entries; the clearing-between-sessions race is an ralph.py-side concern outside Story 1.7 scope (open question RALPH.md:120 — worktree-vs-main-repo path resolution).

## QUEUE (Story 1.7 — PR transition → EPIC_DONE halt)

_(empty — EPIC_DONE halt. Next mini-epic: Story 1.8 — `invariants.manifest.ts` authoring + AC 3 canonical-list import.)_

## BLOCKED

_(none)_

## Deferred (CR iter-7 + iter-12 + iter-15 + iter-18 + iter-20 — recorded per `defer: <reason>` rule)

- `1-7-gate-decision.json` lacks structured `waiver: {reason, approver, expiry, remediation_due}` sub-object; `rationale` prose present; structured waiver block IS present in `1-7-e2e-trace-summary.json` — **defer: trace-skill schema concern, not Story 1.7 scope; waiver-bearing file exists in the pair**.
- `architecture.md:891` shows idealised `packages/keel-invariants/src/` layout; on-disk is `packages/keel-invariants/` at package root (no `src/` parent for config files) — **defer: pre-existing architecture-doc gap predating Story 1.7; Story 1.8's manifest import will reconcile**.
- Trace md YAML `recommendations:` bullets are flat strings lacking `priority:` + `requirements:` sub-keys present in the two sibling JSON objects — **defer: structural projection concern, not wording drift; Story 1.9 FR43 sync-gate scope per Edge Case Hunter self-dismissal**.
- `_bmad-output/test-artifacts/traceability/1-7-e2e-trace-summary.json:10` pins `"source_sha": "7b39060"` to the Task 3 authoring commit, not regenerated on post-CR-fix iterations — **defer: intentional static anchor per iter-10/11/13/14 precedent; Story 1.9 sync-gate will reconcile content-hash drift if any**.
- Story-file Task 1 + Task 2 instructional-skeleton promotion-rule tables (`_bmad-output/implementation-artifacts/1-7-...md:240-245` + `:294-299`) carry a 48-char-wide second column vs the 47-char-wide Prettier-normalised column in the four live files (`INVARIANTS.md:11-16` / `AGENTS.md:15-20` / `CLAUDE.md:59-64` / `RALPH.md:17-22`) — **defer: sealed-story-file documentary drift (story dev-story at iter-4 sealed the skeleton; Prettier rewrote live files at Task 2's `pnpm format` pass); no enforcement loop reads instructional skeletons; AC-2's verbatim contract is about the four LIVE files' mutual-identity (PASS per iter-7/12/15/18/20 Auditor), not skeleton-vs-live identity**.
- `_bmad-output/planning-artifacts/architecture.md:922` carries spelling drift `invariants-manifest.ts` (hyphenated) vs dominant dot-form `invariants.manifest.ts` used everywhere else (INVARIANTS.md, Stories 1.6/1.7, both trace JSONs, gate-decision.json, prd.md, implementation-readiness report, Story 1.6 `no-verify-bypass` error message) — **defer: pre-existing architecture-doc spelling drift predating Story 1.7; Story 1.8's manifest-authoring Task 1 is the natural reconciliation point (picks canonical dot-form)**. Surfaced by Edge Case Hunter iter-20 as a non-finding observation for downstream carry-forward.

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artefact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-23 — halt-sentinel re-write #2)

- [x] **Second consecutive re-entry after EPIC_DONE halt; PR #224 state delta Open→MERGED between iter-22 and iter-23.** `gh pr view 224 --json state,isDraft,mergeable,mergeStateStatus,reviews,statusCheckRollup` → `{"isDraft":false,"mergeStateStatus":"UNKNOWN","mergeable":"UNKNOWN","reviews":[],"state":"MERGED","statusCheckRollup":[]}`. `.ralph/halt` again absent on re-entry (consumed or cleared between iter-22 and iter-23 per gitignored-sentinel Gotcha). Per iter-22 recipe verbatim: halt-sentinel re-write is the idempotent terminal no-op regardless of PR state evolution (Open→Merged). Payload unchanged `{"reason":"EPIC_DONE","epic":1,"pr":224}`. Recipe tightened: "accept any terminal PR state (Open+Clean+Mergeable OR MERGED) as valid grounds for halt re-write".

## DONE (Story 1.7 iter-22 — halt-sentinel re-write #1)

- [x] **Halt-sentinel re-write after gitignored-file clearing between iterations.** Post-iter-21 re-entry found `.ralph/halt` absent despite iter-21's DONE entry claiming it was written; PR #224 terminal state still fully intact (Open+Clean+Mergeable). Root cause: `.ralph/halt` is gitignored so it does NOT survive ralph.py/worktree restarts (consumed-and-deleted on detection, or worktree's untracked sentinel cleared). Re-wrote `.ralph/halt` idempotently with same payload; RALPH.md Gotcha 2026-04-20 line 100 + this ledger entry arm next Ralph with the "halt-sentinel re-write is idempotent terminal no-op" recipe. Empirically discharged at iter-23/iter-24 (happened three times consecutively — recipe is load-bearing).

## DONE (Story 1.7 iter-21 — EPIC_DONE halt)

- [x] **PR #224 Draft→Open transition + EPIC_DONE halt (Story 1.7 terminal iteration).** Preconditions from iter-20: Story State `done`, sprint-status `1-7: done` (committed in iter-20 `6111869`), working tree clean, no unpushed commits. Transition steps executed: (1) `gh pr edit 224 --title "Story 1.7 — invariants knowledge files (INVARIANTS.md) + promotion rules" --body-file /tmp/pr-224-body.md` — title dropped "(spec only — Draft)" suffix; body rewritten to capture the full 20-commit arc (spec + iter-1/2/3 bookkeeping + `7b39060` Tasks 1/2/3 + `acd2111` trace yolo WAIVED + `7e55867` post-dev SM all-5-ACs-PASS + 5 CR passes `a3dc238`/`abe4cf3`/`a72ea45`/`9978597`/`6111869` + 8 fix commits `50ad993`/`d638be4`/`cc95934`/`4c178ec`/`7aa2672`/`6c75c59`/`8905e5f`/`a70b854`/`6b08401` + § Deferred six-item carry-forward); `Closes #31` for the story issue, `Refs #9` for Epic 1. (2) `gh pr ready 224` — PR transitioned Draft→Open. (3) Verified `gh pr view 224 --json state,isDraft,mergeable,mergeStateStatus,reviews,statusCheckRollup` → `{"isDraft":false,"mergeStateStatus":"CLEAN","mergeable":"MERGEABLE","reviews":[],"state":"OPEN","statusCheckRollup":[]}` — all five gates green; empty rollup expected per Story 1.16 scope-carve-out. (4) IP + RALPH.md bookkeeping committed pre-halt (this commit) to avoid the orphan-from-main anti-pattern from 2026-04-19 Story 1.1. (5) `.ralph/halt` written with payload `{"reason":"EPIC_DONE","epic":1,"pr":224}`. **7th consecutive story-implementation EPIC_DONE precedent** across Stories 1.1–1.7, all following the canonical Story 1.5 recipe (line 109 RALPH.md Decisions). User authorizes the merge; next mini-epic is Story 1.8 (`invariants.manifest.ts` authoring + AC 3 canonical-list import; picks up the 9 provisional INV-* IDs from INVARIANTS.md and the sixth § Deferred carry-forward `architecture.md:922` dot-form spelling reconciliation).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 done; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** done
