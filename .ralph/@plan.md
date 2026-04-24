# Implementation Plan

## NOW

- [ ] **Story 2.14 CR — `/bmad-code-review (args: "2")`** (three-layer Ralph-hosted adversarial fan-out per iter-271/iter-277 pattern). Forecast 0-2 first-class PATCH per iter-279 + iter-286 ZERO-PATCH precedent for narrow-diff documentation-heavy stories; potential EIGHTH one-pass ZERO-PATCH CR candidate. Novel-surface narrower than Story 2.13 (no POSIX-sh probe inside YAML folded-scalar; no Docker HEALTHCHECK state-machine consumer). Single novel-surface vector: cross-story lockstep contract with Story 15b.1 (captured at § Retirement gate § Lockstep contract clause). Minor TL;DR shorthand observation at README.md:995 + AGENTS.md:206 flagged at iter-293 post-dev SM for CR adversarial-triage (shorthand `git bisect HEAD 5278738` vs invariant-doc canonical `git bisect start HEAD 5278738`). Transition on success: Story State `sm-verified → done`.

## QUEUE (Story 2.14 lifecycle + 2.15..2.17 substrate queue)

- [ ] _(after Story 2.14 done)_ Story 2.15 committed Claude settings.json deny/allow — full lifecycle.
- [ ] _(after Story 2.15 done)_ Story 2.16 Claude PreToolUse hooks for secret-file denylist — full lifecycle.
- [ ] _(after Story 2.16 done)_ Story 2.17 hook-settings bypass-resistance + Epic 2 SC-17 close-out polish pass. SC-17 reconciliation absorbs cumulative **31 DEFERs at iter-292 Story 2.14 trace landing** (unchanged from iter-291 — trace-gate iter absorbs zero new DEFERs; pure substrate-verification + WAIVED-emit) PLUS Story 2.14 remaining lifecycle DEFERs from post-dev SM (D-X retention-branch-existence probe + D-6 three-site-triage-pointer-lockstep lint — sibling to Story 2.13's D-5 healthcheck-lockstep-lint) + CR + Stories 2.15..2.16 accrued DEFERs.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..292).

## BLOCKED

_(none — iter-291 github.com apex-host outage self-resolved at iter-291 orient; Task 1 landed; trace landed at iter-292.)_

## ATDD Red Phase

_(none — Story 2.14 ATDD-skipped at iter-289 with grounds-(ii)+(iii); no red-phase tests owed. Carry-forward from iter-289.)_

## DONE (iter-293 `/bmad-create-story (args: "review")` — Story State `traced → sm-verified`; ZERO PATCH clean-advance)

- [x] iter-293: **STORY 2.14 POST-DEV SM LANDING** (`traced → sm-verified`). AC-by-AC satisfaction verification against implementation artefacts: AC 1 (legacy branch + banner + pre-absorption layout), AC 2 (invariant doc § Cherry-pick workflow lines 57-91), AC 3 (§ Retirement gate lines 140-152), AC 4 (§ Triage path lines 93-130 + README TL;DR + AGENTS.md H3). **0 PATCH + 0 new DEFER** — matches iter-270 NOVEL LESSON ("pre-dev SM absorbs novel surface → post-dev gates clean-advance dominant"); narrower-grounds precedent from iter-292 trace-WAIVED carries (all ACs static-smoke-testable). One minor CR-scope observation flagged in story-file v1.2 Change Log: README.md:995 + AGENTS.md:206 compressed TL;DR shorthand `git bisect HEAD 5278738` vs invariant-doc canonical `git bisect start HEAD 5278738` — NOT an unmet-AC finding (AC 4 only requires the authoritative recipe in the invariant doc, which is present); deferred to CR adversarial-triage. Story-file v1.2 Change Log entry appended; sprint-status row unchanged at `review` per iter-269/iter-279/iter-285 precedent (the `review` row covers traced/sm-verified/CR sub-states). Commit candidate: `docs(story-2-14): iter-293 /bmad-create-story (args: "review") post-dev SM — traced → sm-verified; ZERO PATCH + 0 new DEFER`.

- [x] iter-292: STORY 2.14 TRACE-GATE LANDING (`in-dev → traced`; WAIVED ground-(a)+(b) — 24th cumulative precedent; FIRST narrower-grounds precedent dropping (c) variant-(ii) per NOVEL LESSON; full detail in three trace artefacts under `_bmad-output/test-artifacts/traceability/2-14-*`).

- [x] iter-287..291: Story 2.14 DRAFTING → PRE-DEV SM → ATDD-SKIP → DEV-STORY PARTIAL + RETRY (`_(no story) → drafted → validated → atdd-scaffolded → in-dev (partial) → in-dev → review`). Pruned per Guardrail 2; full detail in story-file Change Logs v1.0 + v1.1.

_(iter-272..286 Story 2.12+2.13 full-lifecycle detail pruned at iter-291 per Guardrail 2.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **13/17 stories done** (2.1-2.13) + Story 2.14 at `sm-verified` post iter-293 post-dev SM landing + 2.15-2.17 backlog.
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred; substrate smokes re-verified at iter-293 (`pnpm keel-invariants:check` GREEN at 34 manifest entries).
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:120). Host-side shim count: **18** at iter-293 (unchanged from iter-291 — SM iter landed story-file Change Log entry only; zero substrate-code edits).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **13 done** (2.1-2.13); **1 at sm-verified** (2.14); **3 backlog** (2.15-2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.14 — Legacy-devbox branch retention policy.
- **Story File:** `_bmad-output/implementation-artifacts/2-14-legacy-devbox-branch-retention-policy.md`
- **Story State:** `sm-verified` at iter-293 landing. Post-dev SM verified all 4 ACs satisfied against implementation artefacts; ZERO PATCH clean-advance per iter-270 NOVEL LESSON. Sprint-status row unchanged at `review` per iter-269/iter-279/iter-285 precedent (review covers traced/sm-verified/CR). Next per § Story Lifecycle Decision Matrix row `sm-verified`: `/bmad-code-review (args: "2")` CR.
- **GitHub Issue:** Story 2.14 issue unknown; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..293).

## Notes

- **iter-293 observation (pure-verification post-dev SM iter):** iter-293 added zero new PATCH / zero new DEFER / zero substrate-code edit — the post-dev SM iter is pure AC-by-AC artefact verification + story-file v1.2 Change Log append + IP-update. Cumulative PATCH stable at 6 (iter-288 pre-dev SM origin). On-track for iter-286 NOVEL LESSON ~6-10 lifecycle band projection.
- **iter-293 observation (TL;DR shorthand flag for CR):** README.md:995 + AGENTS.md:206 carry compressed `git bisect HEAD 5278738` shorthand inside narrative bash-comment contexts; invariant-doc § Triage path authoritative recipe at line 112 uses full `git bisect start HEAD 5278738`. Minor literal-copy-paste would error; deferred to CR adversarial-triage rather than patched at post-dev SM (AC 4 only requires authoritative recipe in invariant doc, which is present; shorthand is TL;DR-contextual narrative). Watch for CR action item covering this.
- **iter-292 NOVEL LESSON (narrower-grounds trace-WAIVED precedent) carry-forward:** Story 2.14 is the FIRST trace-WAIVED in the 24-precedent chain to apply NARROWER grounds than prior sibling (dropped ground-(c) variant-(ii)). Pinned in RALPH.md § Lessons.
- **iter-291 NOVEL LESSON (initial-connection fetch-timeout budget under post-outage recovery) carry-forward:** default 120s `timeout` wrapping `git fetch` INSUFFICIENT; 240s required. Carry-forward; next upstream-fetch task under post-outage conditions defaults to 240s+ timeout.
- **iter-286 NOVEL LESSON forecast-band stable at iter-293:** Story 2.14 cumulative PATCH = 6 (iter-288 pre-dev SM) + 0 (iter-290 partial) + 0 (iter-291 Task 1 retry) + 0 (iter-292 trace) + 0 (iter-293 post-dev SM) = 6. On-track for ~6-10 lifecycle band. Projected remaining: 0-2 CR.
- **Cumulative DEFER forecast for Stories 2.14..2.17 Epic-2 close-out:** 31 pending at iter-293 (unchanged — SM iter adds zero new DEFERs; D-X + D-6 remain trace-gate-noted but not first-class queued). Remaining Story 2.14 CR + Stories 2.15-2.17 accumulate additional. Absorption at Story 2.17 SC-17 close-out.
