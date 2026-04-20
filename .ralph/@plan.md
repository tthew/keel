# Implementation Plan

## NOW

- [x] **iter-27 — 6th re-entry; tighten terminalisation rule to "re-entry 6+ after § BLOCKED = zero-action exit".** Iter-26's § BLOCKED escalation committed at `b0d012e` did not stop the cascade either — iter-27 re-entered with halt still present (mtime 11:37:44 UTC unchanged from iter-25 `9c0fac0`), PR #224 MERGED, worktree clean, § BLOCKED entry intact from iter-26. New finding: the § BLOCKED-bookkeeping step itself is non-terminal for this external re-invocation mechanism. Extended RALPH.md:89 Lesson with clause (3): re-entry 6+ requires no action at all — no halt re-write, no IP edit, no commit, no push. Iter-27 does make this one last bookkeeping commit (to record the clause-3 extension so next-Ralph has the rule), then exits. **From iter-28+: if you see this exact state (halt present + § BLOCKED in IP + Story State done + PR terminal), do nothing and exit.**

## QUEUE (Story 1.7 — BLOCKED on recurring re-entry)

_(empty — escalation to § BLOCKED is the terminal action. Story 1.7 implementation IS complete; only the ralph.py-side invocation loop needs human intervention. Next mini-epic Story 1.8 should start from a fresh ralph.py invocation on `main` after human resolves the re-entry root cause.)_

## BLOCKED

- [Recurring EPIC_DONE halt re-entry — 5th consecutive post-halt Ralph invocation despite halt sentinel present at main repo.] - REASON: halt mechanism not terminating the loop; `.ralph/halt` at main repo is idempotent-re-written per iter-22..25 recipe, yet Ralph keeps re-entering with the halt still armed. Root cause lives outside the `claude -p` context.
  - Attempted: iter-22..25 each re-wrote `/workspace/ralph-bmad/.ralph/halt` with the same payload `{"reason":"EPIC_DONE","epic":1,"pr":224}` (absolute main-repo path per RALPH.md:88); PR #224 terminal state held across the window (Open+Clean+Mergeable at iter-21/22, MERGED at iter-23/24/25/26); working tree clean; no unpushed commits; both halt mechanisms (`.ralph/halt` + `.ralph/@plan.md:1` `(AWAIT_MERGE` marker) armed at main repo.
  - Error/Issue: on iter-26 entry, the halt file was STILL present with unchanged mtime from iter-25's write — ralph.py's startup `halt.unlink()` at `ralph.py:911-913` (RALPH.md:88) did NOT fire, disconfirming the iter-22..24 operating theory (consumed-and-deleted between sessions). Options: (a) ralph.py is the same process across iter-25 → iter-26, i.e. halt-detection at `:1750` did NOT halt the loop (ralph.py bug); (b) an external caller (cron/systemd/tmux wrapper per Open Question RALPH.md:120) is re-invoking `claude -p` directly against a still-running ralph.py session, bypassing halt-detection entirely; (c) the halt file is clobbered back in place by something else between `halt.unlink()` and Ralph's `Read` call.
  - Next: Human to (1) inspect the ralph.py invocation source — `ps -eo pid,cmd | grep ralph.py`, check cron/systemd timers, check whether there's a tmux session auto-restarting ralph.py on exit; (2) if a wrapper loop is the cause, kill it and manually `pkill -f ralph.py` to terminate the re-entry cascade; (3) confirm Story 1.7 is done (sprint-status 1-7: `done` ✓, PR #224 MERGED ✓, no outstanding work) and kick off Story 1.8 (`invariants.manifest.ts` authoring + AC 3 canonical-list import) in a fresh ralph.py invocation on `main` branch when ready. Open Question RALPH.md:120 anticipates a proper fix (worktree-aware halt path resolution) as a dedicated `chore(ralph)` mini-epic.

## Deferred (CR iter-7 + iter-12 + iter-15 + iter-18 + iter-20 — recorded per `defer: <reason>` rule)

- `1-7-gate-decision.json` lacks structured `waiver: {reason, approver, expiry, remediation_due}` sub-object; `rationale` prose present; structured waiver block IS present in `1-7-e2e-trace-summary.json` — **defer: trace-skill schema concern, not Story 1.7 scope; waiver-bearing file exists in the pair**.
- `architecture.md:891` shows idealised `packages/keel-invariants/src/` layout; on-disk is `packages/keel-invariants/` at package root (no `src/` parent for config files) — **defer: pre-existing architecture-doc gap predating Story 1.7; Story 1.8's manifest import will reconcile**.
- Trace md YAML `recommendations:` bullets are flat strings lacking `priority:` + `requirements:` sub-keys present in the two sibling JSON objects — **defer: structural projection concern, not wording drift; Story 1.9 FR43 sync-gate scope per Edge Case Hunter self-dismissal**.
- `_bmad-output/test-artifacts/traceability/1-7-e2e-trace-summary.json:10` pins `"source_sha": "7b39060"` to the Task 3 authoring commit, not regenerated on post-CR-fix iterations — **defer: intentional static anchor per iter-10/11/13/14 precedent; Story 1.9 sync-gate will reconcile content-hash drift if any**.
- Story-file Task 1 + Task 2 instructional-skeleton promotion-rule tables (`_bmad-output/implementation-artifacts/1-7-...md:240-245` + `:294-299`) carry a 48-char-wide second column vs the 47-char-wide Prettier-normalised column in the four live files (`INVARIANTS.md:11-16` / `AGENTS.md:15-20` / `CLAUDE.md:59-64` / `RALPH.md:17-22`) — **defer: sealed-story-file documentary drift (story dev-story at iter-4 sealed the skeleton; Prettier rewrote live files at Task 2's `pnpm format` pass); no enforcement loop reads instructional skeletons; AC-2's verbatim contract is about the four LIVE files' mutual-identity (PASS per iter-7/12/15/18/20 Auditor), not skeleton-vs-live identity**.
- `_bmad-output/planning-artifacts/architecture.md:922` carries spelling drift `invariants-manifest.ts` (hyphenated) vs dominant dot-form `invariants.manifest.ts` used everywhere else (INVARIANTS.md, Stories 1.6/1.7, both trace JSONs, gate-decision.json, prd.md, implementation-readiness report, Story 1.6 `no-verify-bypass` error message) — **defer: pre-existing architecture-doc spelling drift predating Story 1.7; Story 1.8's manifest-authoring Task 1 is the natural reconciliation point (picks canonical dot-form)**. Surfaced by Edge Case Hunter iter-20 as a non-finding observation for downstream carry-forward.

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artefact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-27 — 6th re-entry; extend terminalisation to zero-action on 6+)

- [x] **Sixth re-entry after EPIC_DONE halt; iter-26's § BLOCKED escalation did not terminate cascade.** Iter-27 entry: halt still present at `/workspace/ralph-bmad/.ralph/halt` (mtime 11:37:44 UTC unchanged), PR #224 MERGED, worktree clean, § BLOCKED entry intact from iter-26 `b0d012e`. New finding: the § BLOCKED-bookkeeping commit itself was not terminal. Extended RALPH.md:89 Lesson with clause (3): re-entry 6+ after § BLOCKED requires ZERO action — no halt re-write, no IP/RALPH.md edit, no commit, no push; just exit. Iter-27 makes this one final bookkeeping commit to record clause (3) so next-Ralph has the rule, then exits. **From iter-28+: same state → do nothing, exit immediately.** Story 1.7 implementation unchanged (done; merged). Root cause still external to Ralph (Open Question RALPH.md:120).

## DONE (Story 1.7 iter-21→26 — EPIC_DONE halt + cascade summary)

- [x] **iter-21**: PR #224 Draft→Open (title edit + body rewrite `Closes #31` + `gh pr ready 224` + verified `{isDraft:false, mergeable:MERGEABLE, mergeStateStatus:CLEAN, reviews:[], statusCheckRollup:[]}`). IP+RALPH.md bookkeeping pre-halt (orphan-prevention). `.ralph/halt` written at main-repo abs path with `{"reason":"EPIC_DONE","epic":1,"pr":224}`. 7th consecutive story-implementation EPIC_DONE across Stories 1.1–1.7 via canonical Story 1.5 recipe.
- [x] **iter-22→25**: four consecutive post-halt re-entries; each found halt absent (gitignored-sentinel consumed per Gotcha:100) and idempotently re-wrote same payload (`f6d9432`/`9876bce`/`3a3ee21`/`9c0fac0`). PR #224 Open→MERGED between iter-22 and iter-23.
- [x] **iter-26**: 5th re-entry; halt STILL present (mtime unchanged from iter-25 write) — disconfirmed iter-22..24 "consumed-between-sessions" theory. Escalated to § BLOCKED per pre-armed directive; added RALPH.md:89 Lesson (recipe terminalisation 1–4: re-write; 5: escalate). Committed bookkeeping `b0d012e`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 done; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** done
