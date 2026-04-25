---
title: 'RALPH.md + .ralph/@plan.md one-shot doc-budget prune (issue #231)'
type: 'chore'
created: '2026-04-25'
status: 'done'
route: 'one-shot'
---

# RALPH.md + .ralph/@plan.md one-shot doc-budget prune (issue #231)

## Intent

**Problem:** `RALPH.md` (1.15 MB / 633 lines) and `.ralph/@plan.md` (14.6 KB / 77 lines) exceed the doc-budget caps shipped in commit 9716ca5 (200K bytes / 500 lines / 60 word-per-bullet for RALPH.md; 8K bytes / 60 lines / 25 word-per-DONE-bullet for `@plan.md`). Phase-1 warn-in-prompt fires on every commit and orient-read consumes 50–70% of Ralph's ~117K-token per-iteration execution budget — the bloat is the precondition `RALPH.md` prune the proposal called out as a follow-up.

**Approach:** One-shot rewrite of both files under tighter-than-proposal per-section FIFO caps (Signposts ≤15, Lessons ≤12, Gotchas ≤8 — proposal allowed ≤20/≤15/≤10; tighter targets leave headroom for future bullets) with mandatory `<!-- iter:N -->` markers for future age-decay (`current_iter − N > 30 → deletable`). Durable signal preserved; iteration-by-iteration close-out logs dropped — per the proposal's explicit "git log is the archive" decision, no archive files created. Adversarial review (general-purpose subagent, no anchoring on author reasoning) caught three factual errors (FR14n state-list completeness, sprint-status.yaml line refs, stale Story-1.16 CI references) — all PATCH-fixed before commit. Both files now pass the hook in `halt-in-prompt` mode (the strictest setting), so the warn-in-prompt baseline is silent and the empirical FP-rate calibration window can begin.

## Suggested Review Order

**Doc-budget compliance (entry point — verify the prune actually meets the gate)**

- The single source of truth for thresholds; both files measure against this.
  [`doc-budget.json`](../../.githooks/doc-budget.json)

- Pre-commit hook reads SSOT, computes sizes, emits findings per file.
  [`check-ralph-doc-budget.sh:48`](../../tools/check-ralph-doc-budget.sh#L48)

**Pruned `RALPH.md` content (≤15 / ≤12 / ≤8 per-section, ≤60 words per bullet)**

- New header rule line documents the iter-marker re-attestation convention.
  [`RALPH.md:14`](../../RALPH.md#L14)

- Signposts now lead with the doc-budget enforcement signpost itself.
  [`RALPH.md:28`](../../RALPH.md#L28)

- FR14n decision bullet — full 11-state list inlined after adversarial PATCH.
  [`RALPH.md:84`](../../RALPH.md#L84)

- CI-staging gotchas — re-targeted from stale "Story 1.16" to live "Epic 3 Story 3.7" after PATCH.
  [`RALPH.md:71`](../../RALPH.md#L71)

**`.ralph/@plan.md` continuity (next iter must be able to pick up)**

- NOW marks the prune iter done; QUEUE has the Cross-epic transition pickup verbatim.
  [`@plan.md:5`](../../.ralph/@plan.md#L5)

- Sprint-status line refs corrected to lines 132 + 153 (PATCH from review).
  [`@plan.md:32`](../../.ralph/@plan.md#L32)

**Mechanical bookkeeping (peripherals)**

- Header line 5 updated from "lands in Epic 3 per RS6" to current Phase-1+Phase-2 status.
  [`RALPH.md:5`](../../RALPH.md#L5)
