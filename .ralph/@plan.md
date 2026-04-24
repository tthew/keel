# Implementation Plan

## NOW

- [ ] **Story 2.15 `/bmad-create-story`** (`_(no story) → drafted`). Next epic story — "Committed Claude settings.json with deny/allow permission policies." First story in the Epic 2 "hook posture" run (2.15 → 2.16 → 2.17 trio); marks the pivot from devbox-substrate runtime concerns (2.1-2.13) + devbox-policy concerns (2.14) to Claude-Code-host concerns (2.15-2.17 settings.json + PreToolUse hooks + bypass-resistance + Epic 2 close-out). Per § Story Lifecycle Decision Matrix row `_(no story)`: invoke `/bmad-create-story` — picks next story from sprint-status (2-15-…: backlog → ready-for-dev). Story State transition: `_(no story) → drafted`.

## QUEUE (Story 2.15 lifecycle + 2.16..2.17 substrate queue)

- [ ] _(after Story 2.15 drafted)_ Story 2.15 full lifecycle (drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done) — ~6-10 iter band per iter-286 NOVEL LESSON for standard-substrate stories.
- [ ] _(after Story 2.15 done)_ Story 2.16 Claude PreToolUse hooks for secret-file denylist — full lifecycle.
- [ ] _(after Story 2.16 done)_ Story 2.17 hook-settings bypass-resistance + Epic 2 SC-17 close-out polish pass. SC-17 reconciliation absorbs cumulative **47 DEFERs at iter-294 Story 2.14 CR landing** (31 pre-CR + 16 iter-294 CR additions) PLUS Stories 2.15..2.16 accrued DEFERs.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..294).

## BLOCKED

_(none — Story 2.14 closed cleanly at iter-294 CR; cumulative DEFER queue rolls to 2.17.)_

## ATDD Red Phase

_(none — Story 2.14 ATDD-skipped at iter-289 with grounds-(ii)+(iii); no red-phase tests owed. Carry-forward from iter-289.)_

## DONE (iter-294 `/bmad-code-review (args: "2")` — Story State `sm-verified → done`; PATCH-2 bundled close)

- [x] iter-294: **STORY 2.14 CR CLOSURE** (`sm-verified → done`). Three-layer Ralph-hosted adversarial fan-out per iter-271/iter-277 pattern: Blind Hunter (`general-purpose` diff-only, 19 raw) + Edge Case Hunter (`general-purpose` diff+project-read, 13 raw) + Acceptance Auditor (`general-purpose` diff+spec+invariant+trace, 4/4 ACs PASS). Diff scope: Story 2.14 substrate commits `d2c49d7..HEAD` restricted to 6 substrate files (301-line diff, +224/-2). **2 first-class PATCH applied in-iter + 16 DEFER + ~10 DISMISS.** P1 = bisect-shorthand three-site lockstep (`git bisect HEAD` → `git bisect start HEAD` at AGENTS.md:206 + packages/devbox/README.md:995 + INVARIANTS.md:134; flagged at iter-293 post-dev SM; three-layer convergence); P2 = cherry-pick category-count three-site lockstep (add `/ network-exposure` to INVARIANTS.md:134; 4-category IN-SCOPE list now five-site-consistent). Bundled close per iter-264 Story 2.11 PATCH-1 precedent (avoids fixes-pending multi-iter path when fixes are trivial cross-doc lockstep prose edits). `pnpm keel-invariants:check` GREEN post-edits (34 manifest entries unchanged; contentHash on `devbox-legacy-branch-retention.md` unchanged — P1/P2 edits touch consumer-docs only). Sprint-status row `review → done`; Story file Status `review → done` + v1.3 Change Log entry appended; deferred-work.md § Story 2.14 section with 16 entries appended. Cumulative Story 2.14 lifecycle PATCH count: 6 (iter-288 pre-dev SM) + 0 (iter-290 partial) + 0 (iter-291 Task 1 retry) + 0 (iter-292 trace WAIVED) + 0 (iter-293 post-dev SM) + 2 (iter-294 CR) = **8 PATCH total** — within iter-286 NOVEL LESSON forecast band (~6-10 for narrow-diff doc-heavy). Commit candidate: `docs(story-2-14): iter-294 /bmad-code-review (args: "2") CR — sm-verified → done; PATCH-2 bundled close (bisect-shorthand + cherry-pick-category three-site lockstep); 16 DEFER to Story 2.17 SC-17`.

- [x] iter-293: Story 2.14 POST-DEV SM LANDING (`traced → sm-verified`). ZERO PATCH + 0 new DEFER; all 4 ACs PASS; sprint-status row unchanged at `review`.

_(iter-287..292 Story 2.14 drafting → pre-dev SM → ATDD-skip → dev-story partial + retry → trace detail pruned per Guardrail 2; full detail in story-file Change Logs v1.0 + v1.1 + v1.2.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **14/17 stories done** (2.1-2.14) + 2.15-2.17 backlog.
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred; substrate smokes re-verified at iter-294 (`pnpm keel-invariants:check` GREEN at 34 manifest entries post-P1+P2 edits).
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:120). Host-side shim count: **18** at iter-294 (unchanged — CR iter landed 2 narrow prose edits only, zero substrate-shim changes).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **14 done** (2.1-2.14); **3 backlog** (2.15-2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** _(no story)_ — Story 2.14 closed at iter-294 CR; Story 2.15 not yet drafted.
- **Story File:** n/a (Story 2.15 draft fires at iter-295)
- **Story State:** `_(no story)_` — next iter invokes `/bmad-create-story` for Story 2.15 per § Story Lifecycle Decision Matrix row `_(no story)`.
- **GitHub Issue:** Story 2.14 issue unknown; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..294).

## Notes

- **iter-294 observation (bundled close precedent reinforced):** Story 2.14 CR PATCH-2 bundled close matches iter-264 Story 2.11 PATCH-1 bundled close pattern — the controlling factor for bundling is `fix narrowness + convergent reviewer signal`, not PATCH count. P1 (three-layer convergent) + P2 (single-layer but cross-file material drift) both pass the trivial-and-obvious gate; bundling avoids the fixes-pending → fix iter → CR re-run iter triple that slows lifecycle by 2 iters. Bundled close is not universally correct — complex fixes or non-convergent reviewer signals should use fixes-pending. Pattern documented at RALPH.md § Lessons iter-294.
- **iter-294 observation (three-layer-convergence as PATCH promoter):** P1 (bisect shorthand) flagged by ALL THREE reviewers independently (Blind prose-pattern-matched; Edge empirically reproduced the `Unknown bisect subcommand: HEAD` shell error; Auditor verified via spec-text-to-impl comparison). Three-layer convergence promotes a finding from "candidate" to "mandatory" — high-confidence, low-regret PATCH. Contrast with P2 single-layer (Blind-only cross-file read) which still warrants PATCH on cross-file substrate three-site-lockstep grounds but represents the lower-confidence tier.
- **iter-286 NOVEL LESSON forecast band closed for Story 2.14.** Cumulative: 8 PATCH lifecycle-total (within ~6-10 band). Narrower than Story 2.13 (6 cumulative — ZERO-PATCH at CR) and Story 2.12 (11 cumulative — CR PATCH-6 plus re-run). On-brand for narrow-diff policy story.
- **Cumulative DEFER forecast for Stories 2.14..2.17 Epic-2 close-out:** 47 pending at iter-294 (31 + 16 new). Remaining Stories 2.15-2.17 accumulate additional. Absorption at Story 2.17 SC-17 close-out.
- **iter-291 NOVEL LESSON (initial-connection fetch-timeout budget under post-outage recovery) carry-forward:** default 120s `timeout` wrapping `git fetch` INSUFFICIENT; 240s required. Carry-forward; next upstream-fetch task under post-outage conditions defaults to 240s+ timeout.
- **iter-292 NOVEL LESSON (narrower-grounds trace-WAIVED precedent) carry-forward:** Story 2.14 is the FIRST trace-WAIVED in the 24-precedent chain to apply NARROWER grounds than prior sibling (dropped ground-(c) variant-(ii)). Pinned in RALPH.md § Lessons.
