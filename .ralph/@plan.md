# Implementation Plan

## NOW

- [ ] **Story 2.14 post-dev SM — `/bmad-create-story (args: "review")`** (post-dev requirements-satisfaction verification per § Story Lifecycle Decision Matrix row `traced → sm-verified`). Forecast 0-2 PATCH per iter-270 NOVEL LESSON drift-band re-baseline (pre-dev SM at iter-288 absorbed 6 PATCH + 1 DEFER; post-dev SM narrower band). Transition on success: Story State `traced → sm-verified`.

## QUEUE (Story 2.14 lifecycle + 2.15..2.17 substrate queue)

- [ ] _(after Story 2.14 sm-verified)_ Story 2.14 CR — `/bmad-code-review (args: "2")`. Forecast 0-2 first-class PATCH per iter-279 + iter-286 ZERO-PATCH precedent for narrow-diff documentation-heavy stories; potential EIGHTH one-pass ZERO-PATCH CR candidate (Task 1 retry at iter-291 was pure spec-execution with zero deviation, reinforcing narrow-diff ZERO-PATCH forecast). Novel-surface narrower than Story 2.13 (no POSIX-sh probe inside YAML folded-scalar; no Docker HEALTHCHECK state-machine consumer). Single novel-surface vector: cross-story lockstep contract with Story 15b.1 (captured at § Retirement gate § Lockstep contract clause).
- [ ] _(after Story 2.14 done)_ Story 2.15 committed Claude settings.json deny/allow — full lifecycle.
- [ ] _(after Story 2.15 done)_ Story 2.16 Claude PreToolUse hooks for secret-file denylist — full lifecycle.
- [ ] _(after Story 2.16 done)_ Story 2.17 hook-settings bypass-resistance + Epic 2 SC-17 close-out polish pass. SC-17 reconciliation absorbs cumulative **31 DEFERs at iter-292 Story 2.14 trace landing** (unchanged from iter-291 — trace-gate iter absorbs zero new DEFERs; pure substrate-verification + WAIVED-emit) PLUS Story 2.14 remaining lifecycle DEFERs from post-dev SM (D-X retention-branch-existence probe + D-6 three-site-triage-pointer-lockstep lint — sibling to Story 2.13's D-5 healthcheck-lockstep-lint) + CR + Stories 2.15..2.16 accrued DEFERs.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..292).

## BLOCKED

_(none — iter-291 github.com apex-host outage self-resolved at iter-291 orient; Task 1 landed; trace landed at iter-292.)_

## ATDD Red Phase

_(none — Story 2.14 ATDD-skipped at iter-289 with grounds-(ii)+(iii); no red-phase tests owed. Carry-forward from iter-289.)_

## DONE (iter-292 `/bmad-testarch-trace (args: "yolo")` — Story State `in-dev → traced`; WAIVED verdict landed)

- [x] iter-292: **STORY 2.14 TRACE-GATE LANDING** (`in-dev → traced` at Phase-2 completion). Three trace artefacts written: `_bmad-output/test-artifacts/traceability/2-14-legacy-devbox-branch-retention-policy.md` (full matrix + gate decision) + `2-14-coverage-matrix.json` (Phase-1 structured output) + `2-14-gate-decision.json` (Phase-2 structured output) + `2-14-e2e-trace-summary.json` (integrated CI/CD snippet). Verdict: **⚠️ WAIVED** via ground-(a)+(b) hybrid — **TWENTY-FOURTH cumulative trace-WAIVED precedent; TWENTY-FIFTH ATDD-skip-trace-WAIVED co-application pairing**. Commit candidate: `docs(story-2-14): iter-292 /bmad-testarch-trace — in-dev → traced; WAIVED ground-(a)+(b) (narrower than 2.13 — drops (c) variant-(ii)); 24th cumulative precedent`.
  - **NOVEL LESSON (narrower-grounds precedent — FIRST trace-WAIVED dropping ground-(c) variant-(ii)):** Story 2.14 is the first trace-WAIVED in the 24-precedent chain to apply NARROWER grounds than prior sibling — specifically dropping ground-(c) operator-workstation-deferred-AC-completion from Story 2.13's (a)+(b)+(c)-variant-(ii). Rationale: Story 2.14's 4 ACs are all static-smoke-testable at the substrate layer (AC 1 via `git ls-remote origin refs/heads/legacy-devbox` + `git show origin/legacy-devbox:README.md | head -20`; ACs 2-4 via doc-content grep against `docs/invariants/devbox-legacy-branch-retention.md` + sha256 sync-gate + three-site lockstep). No runtime behaviour requires live operator-workstation observation (no cap-dropped-container SIGKILL sequences; no Docker HEALTHCHECK state-machine observation; no mid-run probe accumulator). LESSON: trace-gate grounds-application is per-story-narrowable — future policy-class / branch-state / doc-heavy stories may apply (a)+(b) narrower than runtime-code-heavy predecessors. Pinned in RALPH.md § Lessons.
  - **Substrate-verification smokes ALL PASSED at iter-292 re-verification** (iter-290 + iter-291 Dev Agent Record impl-time smokes also carry forward):
    - (i) `git ls-remote origin refs/heads/legacy-devbox` → `cfdf011006d44f52e36f461eacd8395e7f54ac0e  refs/heads/legacy-devbox`;
    - (ii) `git show origin/legacy-devbox:README.md | head -20` → retention banner with 3-section (scope/sunset/operator-pointer) + upstream SHA `8ea5131eecbbfe0d0eb063c55f170cce6915af90` substituted + upstream ASCII-art preserved below;
    - (iii) `sha256sum docs/invariants/devbox-legacy-branch-retention.md` → `02f6048f78cf3c4e315ec6bc5c55bd52a7278d2cba99cc1f1e7b5a5b91d0c4ca` matching manifest contentHash at `invariants.manifest.ts:309`;
    - (iv) `pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check` → GREEN at 34 manifest entries;
    - (v) `INVARIANTS.md:136` anchor bullet regex-compliant per `sync-gate.ts:24`;
    - (vi) Three-site triage-pointer lockstep verified: invariant doc § Triage path (93-130) + README H2 at `:985` + AGENTS.md H3 at `:202`;
    - (vii) § Cherry-pick workflow at invariant doc lines 57-91 carries canonical `git format-patch | sed | git am` recipe + minimal-drift framing + IN/OUT-OF-SCOPE lists + documented-but-not-automated clause;
    - (viii) § Retirement gate at 140-152 carries 5-step sequence + lockstep-contract clause with Story 15b.1;
    - (ix) § Triage path at 93-130 carries canary-then-bisect recipe + `5278738` anchor rationale + load-bearing-UX framing;
    - (x) Recursive probe for `vitest.config.*`/`jest.config.*`/`playwright.config.*`/`cypress.config.*`/`pyproject.toml`/`go.mod`/`Gemfile`/`Cargo.toml` under repo root → zero matches (no test runner wired at Story 2.14 substrate stage; Epic 13 scope).
  - **Cumulative PATCH forecast update at iter-292 trace landing.** Story 2.14 cumulative PATCH = 6 (iter-288 pre-dev SM) + 0 (iter-290 dev-story partial) + 0 (iter-291 Task 1 retry; pure spec-execution) + 0 (iter-292 trace; pure substrate-verification + WAIVED-emit) = **6 PATCH at `in-dev → traced`**. On-track for iter-286 NOVEL LESSON ~6-10 lifecycle band. Projected remaining: 0-2 at post-dev SM + 0-2 at CR. Potential EIGHTH one-pass ZERO-PATCH CR candidate for narrow-diff documentation-heavy stories.

- [x] iter-291: **STORY 2.14 TASK 1 LANDING** (`in-dev (partial) → in-dev → review` at workflow Step 9). Full detail pruned per Guardrail 2; full Dev Agent Record in story file v1.1 Change Log + iter-291 orient recovery + Task 1 retry Completion Notes.

- [x] iter-287..290: Story 2.14 DRAFTING → PRE-DEV SM → ATDD-SKIP → DEV-STORY PARTIAL LANDING (`_(no story) → drafted → validated → atdd-scaffolded → in-dev (partial)`). Pruned per Guardrail 2; full detail in story-file Change Logs + prior IP iters.

_(iter-272..286 Story 2.12+2.13 full-lifecycle detail pruned at iter-291 per Guardrail 2.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **13/17 stories done** (2.1-2.13) + Story 2.14 at `traced` post iter-292 trace landing + 2.15-2.17 backlog.
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred; substrate smokes covered through iter-292 (`pnpm keel-invariants:check` GREEN at 34 manifest entries — re-verified post manifest rebuild at iter-292 trace-verification).
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:120). Host-side shim count: **18** at iter-292 (unchanged from iter-291 — trace iter landed artefacts only; zero substrate-code edits).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **13 done** (2.1-2.13); **1 at traced** (2.14); **3 backlog** (2.15-2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.14 — Legacy-devbox branch retention policy.
- **Story File:** `_bmad-output/implementation-artifacts/2-14-legacy-devbox-branch-retention-policy.md`
- **Story State:** `traced` at iter-292 landing. Trace-gate verdict: **WAIVED** via ground-(a)+(b) hybrid (narrower than Story 2.13's (a)+(b)+(c)-variant-(ii); drops (c) since all 4 ACs static-smoke-testable). Sprint-status row unchanged at `review` (Status field tracks BMad workflow gate; Ralph-internal Story State tracks lifecycle position). Next per § Story Lifecycle Decision Matrix row `traced`: `/bmad-create-story (args: "review")` post-dev SM.
- **GitHub Issue:** Story 2.14 issue unknown; `RALPH_ISSUE_NUMBER` unset. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..292).

## Notes

- **iter-292 NOVEL LESSON (narrower-grounds trace-WAIVED precedent):** Story 2.14 is the FIRST trace-WAIVED in the 24-precedent chain to apply NARROWER grounds than prior sibling — specifically dropping ground-(c) variant-(ii) operator-workstation-deferred-AC-completion from Story 2.13's (a)+(b)+(c). Rationale: policy-class / branch-state / doc-heavy stories have no runtime behaviour requiring live operator-workstation observation; the substrate-verification layer (git-state probes + sha256 sync-gate + three-site lockstep) is sufficient. Future Epic 13 test framework landing will enable full mechanical regression with NO operator-workstation dependency (contrast Story 2.13 where AC 4 remains operator-workstation-only even under Epic 13). LESSON: trace-gate grounds-application is per-story-narrowable. Pinned in RALPH.md § Lessons.
- **iter-292 observation (pure-spec-execution trace-gate iter):** iter-292 added zero new PATCH / zero new DEFER / zero substrate-code edit — the trace-gate iter is pure substrate-verification + WAIVED-emit + three-trace-artefact-write + IP-update. Cumulative PATCH stable at 6 (iter-288 pre-dev SM origin). On-track for iter-286 NOVEL LESSON ~6-10 lifecycle band projection.
- **iter-292 observation (e2e-trace-summary.json source_sha authoritative):** Used `git rev-parse HEAD` → `d03a7fc4bca58986aadc519e29c6b6d5958aee36` as the source_sha for iter-292 traceability fingerprint (corresponds to iter-291 Task 1 commit `d03a7fc`). Future trace iters should capture source_sha at trace-gate execution time, not invariant-doc-landing time — trace artefacts bind to the execution-time substrate state.
- **iter-291 NOVEL LESSON (initial-connection fetch-timeout budget under post-outage recovery) carry-forward:** default 120s `timeout` wrapping `git fetch` from upstream INSUFFICIENT under post-outage recovery initial-connection latency; 240s required. Carry-forward from iter-291; next upstream-fetch task under post-outage conditions defaults to 240s+ timeout.
- **iter-291 observation (iter-286 NOVEL LESSON #3 META-guard applied AT Task 1 exec) carry-forward:** upstream docker-compose.yml grep at Task 1 exec confirmed expected `curl :3000/api/health` healthcheck — known-divergence NOT cherry-pick candidate. Carry-forward; META-guard discipline is the forcing-function for any spec-endorsed claim about upstream state.
- **iter-286 NOVEL LESSON forecast-band stable at iter-292:** Story 2.14 cumulative PATCH = 6 (iter-288 pre-dev SM) + 0 (iter-290 partial) + 0 (iter-291 Task 1 retry) + 0 (iter-292 trace) = 6. On-track for ~6-10 lifecycle band. Projected remaining: 0-2 post-dev SM + 0-2 CR.
- **Cumulative DEFER forecast for Stories 2.14..2.17 Epic-2 close-out:** 31 pending at iter-292 (unchanged from iter-291 — trace iter adds zero new DEFERs; D-X + D-6 candidates are noted in trace recommendations but not yet queued as first-class DEFERs). Remaining Story 2.14 lifecycle (post-dev SM + CR) + Stories 2.15-2.17 accumulate additional. Absorption at Story 2.17 SC-17 close-out.
