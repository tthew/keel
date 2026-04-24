# Implementation Plan

## NOW

- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md")` — Story 2.13 dev-story per § Story Lifecycle row `atdd-scaffolded → in-dev`. Scope: 5 Tasks — compose healthcheck block (dig dnsmasq + optional nc sshd; POSIX-sh `&&`/`||` under `/bin/sh` dash; YAML `>-` folded-scalar) + probe-tooling verification (dnsutils / netcat-openbsd baked; sshd IPv4 loopback grep-only guard per PATCH-4) + `INV-devbox-healthcheck` manifest entry + invariant doc (`docs/invariants/devbox-healthcheck.md` with § Intent + § Probe contract + § Timing parameters + § Probe tooling + § Exit codes + § Probe domain stability H2 sections) + README § Healthcheck + AGENTS.md § Healthcheck + optional Task 5 Dockerfile `sshd.log` pre-create (absorbs Story 2.12 iter-279 D-1 DEFER; dev-agent discretion). Forecast ~30-50K (smaller than Story 2.12's ~70-100K; fewer files touched; no new apt package; no new resolver function). Manifest count 32 → 33.

## QUEUE (Story 2.13 lifecycle + 2.14..2.17 substrate queue)
- [ ] _(after in-dev)_ `/bmad-testarch-trace (args: "yolo")` per matrix row `in-dev → traced` (forecast WAIVED per Story 2.12 iter-269 pattern — ACs 1, 2, 3, 5 substrate-covered by static smokes + sync-gate; AC 4 operator-workstation-deferred).
- [ ] _(after traced)_ `/bmad-create-story (args: "review")` post-dev SM per matrix row `traced → sm-verified`. Two-subagent pattern (iter-235 LESSON). Forecast 0-2 PATCH per iter-270 NOVEL LESSON drift-band re-baseline (pre-dev SM absorbs CRITICAL; post-dev narrower).
- [ ] _(after sm-verified)_ `/bmad-code-review (args: "2")` per matrix row `sm-verified → done | fixes-pending` — three-layer Ralph-hosted adversarial fan-out (iter-271 pattern + iter-277 NOVEL LESSON #2 META guard carry-forward). Forecast 1-3 first-class PATCH (moderate-novelty band per iter-264 LESSON; narrower than Story 2.12 novel-runtime-behaviour outlier).
- [ ] _(after Story 2.13 done)_ Story 2.14 legacy branch retention policy — full lifecycle.
- [ ] _(after Story 2.14 done)_ Story 2.15 committed Claude settings.json deny/allow — full lifecycle.
- [ ] _(after Story 2.15 done)_ Story 2.16 Claude PreToolUse hooks for secret-file denylist — full lifecycle.
- [ ] _(after Story 2.16 done)_ Story 2.17 hook-settings bypass-resistance + Epic 2 SC-17 close-out polish pass. SC-17 reconciliation absorbs cumulative **18 Story 2.12 DEFERs carried to Story 2.17** (11 iter-271 + 3 remaining iter-277 post-iter-278-and-iter-280-absorptions + 4 iter-279) if Story 2.13 Task 5 lands D-1 absorption; PLUS cumulative Epic 2 Story 2.13..2.16 DEFERs accrued during those stories.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured at 2026-04-24 per iter-219..280 confirmation; `statusCheckRollup: []` continues; iter-280 orient `gh pr view 230` GREEN first try — SSH :22 recovery asymmetry carry-forward from iter-263 LESSON quiescent this iter).

## BLOCKED

_(none — iter-282 ATDD-skip converged cleanly; branch in sync at `9863358` pre-commit; push status unchanged.)_

## ATDD Red Phase

_(none — iter-282 ATDD-skip-with-grounds-(c)+(ii)+(iii) for Story 2.13 per FR14n; 23rd-cumulative ATDD-skip precedent (10 Epic-1 + 13 Epic-2); zero scaffolds produced; AC 1 + AC 5 bash-testable as impl-time smokes at `/bmad-dev-story`; AC 2 + AC 3 + AC 4 operator-workstation-deferred; no red-phase tests owed.)_

## DONE (iter-282 Story 2.13 ATDD SKIP-WITH-GROUNDS — `/bmad-testarch-atdd` landing; `validated → atdd-scaffolded`; 23rd-cumulative precedent; ZERO-PATCH iter)

- [x] iter-282: **STORY 2.13 ATDD SKIP — `/bmad-testarch-atdd` landing.** FR14n Story State transition `validated → atdd-scaffolded` under § Story Lifecycle row `skip → in-dev allowed only if story has no testable ACs; record rationale in IP` clause. ZERO-PATCH iter per Story 2.5 iter-186 canonical pattern (IP + RALPH.md + story-file Status HTML comment only; no story-file Change Log v1.2 entry). Zero scaffolds produced (no test runner at substrate stage — Epic 13 scope).

  - **Grounds-(c)+(ii)+(iii) load-bearing for Story 2.13:**
    - **(c) Mixed-class ACs:** AC 1 + AC 5 bash-functional-testable (AC 1 via `docker compose config` → `jq '.services.devbox.healthcheck.test'` JSON-array shape assertion + grep absence of `curl localhost:3000`; AC 5 via README § Healthcheck section-present + timing values documented). AC 2 + AC 3 + AC 4 exercise only against a live Docker daemon executing the healthcheck CMD in a running container — AC 4 specifically requires mid-run `docker exec kill -9` of dnsmasq / sshd with `State.Health.Status` transition observation, infeasible under DinD backend B cap-dropped container semantics.
    - **(ii) No live test runner at substrate stage:** `package.json` test surface turbo-wired to zero implementing packages; no playwright / cypress / vitest / conftest / bats / jest configured under repo. Bash-functional-testable AC 1 + AC 5 land as Task-internal impl-time smokes at `/bmad-dev-story` (not as separate Playwright/Cypress scaffolds).
    - **(iii) Adversarial-coverage substitutes:** post-dev SM two-subagent (iter-235 pattern) + CR three-layer fan-out (iter-271 / 277 pattern) + Story 1.9 sync-gate on new `docs/invariants/devbox-healthcheck.md` sha256 contentHash tracking + Epic 13 downstream regression harness when it lands.

  - **23rd-cumulative FR14n ATDD-skip precedent** (10 Epic-1: Stories 1.1, 1.3..1.11 — pure doc/config stories with no live runtime surface; 13 Epic-2: Stories 2.1..2.13 — substrate infrastructure stories where live runtime semantics require operator workstation). Pattern now stable at ~100% cumulative rate since Epic 1 opened at iter-83 2026-04-17.

  - **Sprint-status UNCHANGED** at `ready-for-dev` per iter-202 pattern (ATDD-skip does not flip sprint-row; `in-progress` flip happens at `/bmad-dev-story` iter-283).

  - **PR:** #230 **Draft** — `statusCheckRollup: []` carries unchanged across iter-272..282; iter-282 orient `gh pr view 230` GREEN first try (`gh pr checks 230` returned a single GraphQL-endpoint i/o timeout which cleared on retry via `gh pr view 230 --json`, consistent with iter-263 SSH :22 / HTTPS :443 asymmetric-recovery LESSON at low-amplitude flake tier). Branch in sync with origin at `9863358` pre-commit.

  - **Budget consumed:** ~30K tokens (orient ~10K + skill invocation + Step-01 preflight read ~6K + Story 2.12 iter-267 precedent commit cross-check ~4K + story-file Status HTML comment edit + IP + RALPH.md + commit-prep ~10K stacking). Well within ~117K execution budget; exit cleanly per Guardrail 12.

- [x] iter-281: Story 2.13 VALIDATED — `/bmad-create-story (args: "review")` pre-dev SM; `drafted → validated`; 6 PATCH (4 NARROW + 2 SUBSTANTIVE) + 3 DEFER + ~12 DISMISS; Change Log v1.1. See commit `6e0e810` + IP-cleanup carry-forward `9863358`. Forecast-band: above narrow 1-3 forecast, under 8-PATCH Story-2.12 outlier — drivers: doc-heavy Story 2.13 surface + 4-subagent adversarial spread.

- [x] iter-280: Story 2.13 DRAFTED — `/bmad-create-story`; `_(no story) → drafted`; story file ~275 lines, 5 ACs + 5 Tasks (Task 5 optional absorbs Story 2.12 iter-279 D-1 DEFER). See commit `985aee0`.

- [x] iter-279: Story 2.12 DONE — `/bmad-code-review (args: "2")` closure re-run #2 ZERO-PATCH. See commit `ce3ffb4`.

- [x] iter-272..278: Story 2.12 PATCH-1..6 LANDED + iter-277 CR closure re-run #1. Commits `30b7d8d`/`1df64ab`/`0d83fae`/`820591a`/`43b4e4b`/`3eadcff`/`947cbce`.

- [x] iter-271: `/bmad-code-review (args: "2")` — `sm-verified → fixes-pending`; 5 PATCH + 11 DEFER + ~10 DISMISS. See commit `a777224`.

_(iter-253..270 Story 2.10/2.11/2.12 closure + Story 2.12 lifecycle iters pruned per Guardrail 2.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **12/17 stories done** (2.1-2.12) + 5/17 in-flight (2.13 atdd-scaffolded at iter-282; 2.14..2.17 backlog). Epic 2 current active story = 2.13 (healthcheck on dnsmasq + sshd).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live fresh-fork first-run smokes operator-workstation-deferred; substrate smokes covered through iter-282 (`pnpm keel-invariants:check` GREEN at `946f1ac1…907029` carried from iter-276; no contentHash edit this iter — ATDD-skip iter, no source mutation).
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:120). Host-side shim count: **18** at iter-282 (unchanged — ATDD-skip iter, no shim edits).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **12 done** (2.1-2.12); **1 atdd-scaffolded** (2.13 at iter-282); **4 backlog** (2.14..2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.13 — Healthcheck on dnsmasq + sshd (replaces upstream's broken `curl :3000` healthcheck).
- **Story File:** `_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md`
- **Story State:** `atdd-scaffolded` (iter-282 `/bmad-testarch-atdd` SKIP-WITH-GROUNDS-(c)+(ii)+(iii); 23rd cumulative precedent; next gate `/bmad-dev-story` at iter-283 for `atdd-scaffolded → in-dev`).
- **GitHub Issue:** Story 2.13 issue unknown; `RALPH_ISSUE_NUMBER` unset at iter-282 orient. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` carried unchanged iter-272..282; iter-282 orient `gh pr view 230` GREEN first try; single `gh pr checks 230` GraphQL-endpoint i/o timeout cleared on `--json` retry — iter-263 asymmetric-recovery at low-amplitude flake tier).

## Notes

- **iter-282 meta-observation (23rd-cumulative ATDD-skip; pattern stable):** Story 2.13 ATDD-skip fits the established cumulative skip precedent (10 Epic-1 + 13 Epic-2). No novel-lesson-producing iter — pattern is now mature enough that each new skip iter is a one-line RALPH.md signpost with iter-number + grounds-tuple marker. META guard does NOT fire (no empirical test overriding expected skip decision).
- **iter-282 meta-observation (TodoWrite reminder hooks):** harness surfaced TodoWrite reminders twice this iter (once mid-orient, once mid-edit). Observation: in ZERO-PATCH iters the todo list is a single in-progress entry throughout; reminder is a false-positive at substrate-iter density. No pattern change needed; reminder is documented harness behaviour.
- **iter-280/281 NOVEL LESSON carry-forward (doc-heavy pre-dev SM band widening + citation-audit false-positive mitigation):** both pinned in RALPH.md § Lessons; neither exercised at iter-282 (ATDD-skip iter). Will reactivate at iter-284 post-dev SM + iter-285 CR.
- **iter-278 LESSON carry-forward (DEFER absorption discipline):** Story 2.13 Task 5 proactively absorbs Story 2.12 iter-279 D-1 at drafting time (iter-280). Pattern remains load-bearing; not exercised at iter-282.
- **iter-277 NOVEL LESSON #1 carry-forward (bash subshell `||`-LHS errexit suppression):** Story 2.13 healthcheck CMD uses `/bin/sh` (dash) `&&`/`||` not bash subshells; mechanism does not apply to dash errexit. Stays codified for bash-wrapped impl-time smokes at iter-283 dev-story if any.
- **iter-276 NOVEL LESSON carry-forward (hazard-class discrimination under word-splitting):** stable at iter-282; Story 2.13 YAML folded-scalar `>-` strategy designed to avoid multi-line word-splitting.
- **iter-276 observation carry-forward (contentHash edit cost model):** iter-282 did NOT touch any contentHash-tracked source (ATDD-skip iter is IP + story-Status + RALPH.md edits only). `pnpm keel-invariants:check` GREEN carried from iter-276 at `946f1ac1…907029` unchanged.
- **iter-273 NOVEL LESSON carry-forward (compose env-propagation chokepoints):** stable; Story 2.13 reuses Story 2.12 PATCH-2 `KEEL_DEVBOX_SSH_RESOLVED` canonical stream — no new chokepoint introduced at iter-282.
- **iter-271 LESSON carry-forward (three-subagent pattern for post-dev SM + CR):** applicable at iter-284 (post-dev SM) + iter-285 (CR). Not exercised at iter-282.
- **iter-270 NOVEL LESSON carry-forward (drift-band re-baseline):** applicable at iter-284 post-dev SM. Not exercised at iter-282.
- **iter-264 LESSON carry-forward:** CR re-run DEFER-vs-PATCH severity-class-first; Story 2.13 forecast closure budget = 1 closure re-run at worst (narrower than Story 2.12's 2).
- **iter-263 LESSON carry-forward:** SSH :22 / HTTPS :443 asymmetric recovery; iter-282 exhibited a low-amplitude `gh pr checks 230` GraphQL i/o timeout that cleared via `gh pr view 230 --json` retry — consistent with the LESSON pattern at milder tier. No blocker-class retry cascade this iter.
- **iter-257 LESSON reaffirmed (no contentHash edit at iter-282):** no sync-gate recompute; `pnpm keel-invariants:check` GREEN carried from iter-276 unchanged. Will fire at Story 2.13 dev-story iter-283 when `INV-devbox-healthcheck` manifest entry + `docs/invariants/devbox-healthcheck.md` author both land (manifest count 32 → 33 at dev-story landing).
- **Substrate-citation drift cumulative forecast for Stories 2.13..2.17:** ~5-12 cumulative substantive + ~30-50 cumulative mechanical drifts. SC-17 single reconciliation at Story 2.17 landing. Cumulative DEFER tally at iter-282 Story 2.13 atdd-scaffolded = 25 (Story 2.12 final 22 + Story 2.13 pre-dev-SM 3). Task 5 optional absorption of D-1 would bring total to 24 if exercised at iter-283.
