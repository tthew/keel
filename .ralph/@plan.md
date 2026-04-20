# Implementation Plan

## NOW

- [ ] Story State `fixes-pending` → Re-run `/bmad-code-review (args: "2")` — confirm `### Review Findings` cleared; Story State `fixes-pending → sm-verified → done` (no new findings) OR `fixes-pending` again (any new finding queues a fresh fix) ~medium

## QUEUE (Story 1.7 — re-gate + PR transition)

- [ ] Story State `done` → Transition PR #224 Draft→Open — rewrite title/body for full spec+iter-1+iter-2+iter-3+Tasks-1-3+trace+SM-review+CR commit range; EPIC_DONE halt (mini-epic convention, 7th story-implementation precedent)

## BLOCKED

_(none)_

## Deferred (CR iter-7 — recorded per `defer: <reason>` rule)

- `1-7-gate-decision.json` lacks structured `waiver: {reason, approver, expiry, remediation_due}` sub-object; `rationale` prose present; structured waiver block IS present in `1-7-e2e-trace-summary.json` — **defer: trace-skill schema concern, not Story 1.7 scope; waiver-bearing file exists in the pair**.
- `architecture.md:891` shows idealised `packages/keel-invariants/src/` layout; on-disk is `packages/keel-invariants/` at package root (no `src/` parent for config files) — **defer: pre-existing architecture-doc gap predating Story 1.7; Story 1.8's manifest import will reconcile**.

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artefact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-11)

- [x] **CR fix #4/4 — waiver expiry placeholder replaced.** Set trace md line 514 from `expiry: '2026-XX-XX (expires when Story 1.9 sync-gate lands)'` → `expiry: 'deferred (expires when Story 1.9 sync-gate lands)'`. CR pointer `~1209` was drifted again (live trace md is 540 lines, not 1209) — another instance of the iter-10 line-pointer-drift lesson already recorded in RALPH.md, no new journal entry needed. Chose `deferred` over an arbitrary concrete date because Story 1.9's landing isn't fixed; parenthetical preserves remediation trigger and aligns with `remediation_due: 'Stories 1.8 + 1.9 (Epic 1 backlog)'`. Story-file `### Review Findings` item 4/4 flipped `[ ] → [x]` with **Resolved iter-11** addendum. All 4 CR patch findings now resolved; 2 deferred findings retain `[x]` defer status. Next: re-run `/bmad-code-review (args: "2")` per FR14n matrix row 10 — empty `### Review Findings` or new findings surfaced.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 CR-fixes-pending; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** fixes-pending
