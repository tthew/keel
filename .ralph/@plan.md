# Implementation Plan

## NOW

- [ ] _(post-this-iter)_ Run `/bmad-create-story` for Story 1.17 (Bootstrap TypeScript test runner Vitest + minimal CI). FR14n state transition `_(no story) → drafted`. Fresh context window per § BMad Workflows; one workflow per iteration.

## QUEUE (Epic 1 reopen — Stories 1.17–1.21 bootstrap arc per issue #233)

- [ ] Run `/bmad-create-story` for Story 1.17 (TS Vitest + minimal CI workflow)
- [ ] Story 1.17 lifecycle: drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done (per FR14n matrix; one skill per iteration)
- [ ] Run `/bmad-create-story` for Story 1.18 (Python pytest under uv + root pyproject.toml)
- [ ] Story 1.18 lifecycle (same as 1.17)
- [ ] Run `/bmad-create-story` for Story 1.19 (keel-invariants test backfill — highest-risk untested code; budget 4–6 CR iterations)
- [ ] Story 1.19 lifecycle
- [ ] Run `/bmad-create-story` for Story 1.20 (Activate FR14i — register `INV-fr14i-ci-workflow-presence`)
- [ ] Story 1.20 lifecycle
- [ ] Run `/bmad-create-story` for Story 1.21 (audit + sweep prior ATDD-skip into test-debt.md)
- [ ] Story 1.21 lifecycle
- [ ] Re-close Epic 1 (`epic-1: in-progress → done` after Story 1.21 closes); transition PR Draft→Open final CI gate

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty — this iter is `/bmad-correct-course` autonomous SCP authoring; no red-phase scaffolds expected. Stories 1.17–1.21 will produce red-phase scaffolds in their own ATDD iterations once the runner exists.)_

## DONE (Epic 1 reopen pass — Stories 1.17–1.21)

- [x] iter-1 (this iter): **`/bmad-correct-course` on issue #233 — Sprint Change Proposal authored autonomously per Ralph build-mode batch flow.** Inputs: GitHub issue #233 ("Course Correction: Bootstrap test runner + CI for TypeScript Vitest and Python pytest under uv before Epic 1 closes"; comprehensive multi-agent roundtable analysis with proposed Stories 1.17–1.21, decisions D1–D5, impacted artifact list, acceptance criteria); branch `chore/correct-course-test-runner-233` based on `origin/feat/epic-2-packaged-devbox` tip `8ab7a1a` (Epic 2 closed; PR #235 merged). Outputs: (a) `_bmad-output/planning-artifacts/sprint-change-proposal-issue-233.md` (~25KB; Section 1 issue summary + Section 2 impact analysis with Epic / Story / Artifact / Technical breakdown + Section 3 recommended approach `Direct Adjustment` + Section 4 detailed change proposals across PRD / architecture / epics / sprint-status + Section 5 implementation handoff); (b) PRD amendments — new FR14o (Test runner mandate; TS Vitest + Python pytest under uv + minimal CI); new NFR1a (Test coverage floor; ≥1 passing test per `src/`-bearing package); FR14a manifest-real-files clause amendment; FR14i pre-bootstrap-degradation amendment; FR14n ATDD-skip ground-(b) sunset amendment; (c) architecture amendments — replaced line-154 `Testing Framework: Deferred` with the recorded decision (Vitest TS + pytest under uv Python; Playwright deferred to M9); new D6 (Python project shape) decision; new § M0 substrate developer-productivity floor section consolidating the bootstrap arc; (d) epics amendments — appended Stories 1.17–1.21 to Epic 1 between Story 1.16 and Epic 2; (e) sprint-status amendment — `epic-1: done → in-progress` + 5 new backlog rows. Decisions resolved: D1 = no halt (autonomous boundary; Epic 1 PR #226 already merged); D2 = Story 1.19 parallelizable but hard-precondition for Epic 4; D3 = both PRD path AND invariants path; D4/D6 = root `pyproject.toml` + `uv.lock` (D6 numbered new in architecture); D5 = new architecture § M0 substrate. Epic 1 framing: REOPEN (precedent-extension; #231 / #232 added stories to active/future epics, this is first to a closed epic). Branch upstream cleared (`git branch --unset-upstream`) so push goes to its own remote, not epic-2.

## Context

- **Phase:** 4-implementation — Epic 1 REOPENED (`epic-1: done → in-progress` per issue #233 SCP) for Stories 1.17–1.21 bootstrap arc.
- **Runtime:** cc-devbox iteration env. github.com / api.github.com network access intermittent (DNS-rotation; PR #235's fix not yet in container image). Workaround: `curl --resolve api.github.com:443:140.82.121.5 https://api.github.com/...` per RALPH.md iter-345 if `gh` calls time out.
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (REOPENED for Stories 1.17–1.21). Original 16 stories already merged via PR #226 (sprint-status entries unchanged); 5 new stories appended.
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` — this work targets it as the PR base, not `main`. Two prior course-correct PRs (#234 issue #231 doc-budget, #235 issue #232 devbox-network) used the same pattern.
- **Working Branch:** `chore/correct-course-test-runner-233` (based on `origin/feat/epic-2-packaged-devbox` tip `8ab7a1a`).
- **Story:** _(none — Stories 1.17–1.21 not yet drafted; next iteration creates Story 1.17.)_
- **Story File:** _(n/a)_
- **Story State:** _(no story)_ — next iteration `/bmad-create-story` transitions to `drafted`.
- **GitHub Issue:** Issue #233 ("Course Correction: Bootstrap test runner + CI"). PR (this iter creates) will reference `Refs #233`; closes on Epic 1 reopen close-out.
- **PR:** _(this iter creates draft PR targeting `feat/epic-2-packaged-devbox`)._

## Notes

- **Course-correction precedent stack now 3 deep:** issue #231 (PR #234, doc-budget) → issue #232 (PR #235, devbox network) → issue #233 (PR this iter creates, test runner bootstrap). All three target `feat/epic-2-packaged-devbox`. Issue #233 is the first to REOPEN a closed epic (precedent extension).
- **Branch upstream gotcha:** `git checkout -b <new> origin/feat/epic-2-packaged-devbox` auto-tracks the source remote. Always run `git branch --unset-upstream` immediately after to prevent accidental push to epic-2 from a sub-branch. Push uses explicit `git push -u origin <branch>` refspec.
- **FR14o not FR14j:** issue #233 body's working-draft used FR14j as the new FR letter. FR14j is already taken by the issue #231 doc-budget amendment (knowledge-file upkeep contract + doc-budget enforcement). Renumbered to FR14o (next free letter after FR14n).
- **Epic 1 reopen mechanics:** sprint-status `epic-1: done → in-progress` flip is reversible by Story 1.21 close-out (`epic-1: in-progress → done`). The historical record in `last_updated:` carries both transitions — this is the pattern Epic 2 used at iter-347 (`Epic-2-done-to-in-progress-Story-2-18-active`) and iter-353 (`Epic-2-in-progress-to-done-Story-2-18-closed`). Issue #233 follows the same arc.
- **Story 1.19 budget warning:** keel-invariants backfill is the only Story 1.x with significant CR-iteration budget exposure (4–6 cycles forecast vs 1–2 typical for substrate stories). The reason: pre-existing impl bugs in `keel-invariants` will surface for the first time under test. Budget accordingly when planning Story 1.19 iterations.
- **Epic 4 hard-precondition:** Epic 4 (per-iteration security verification, FR35–FR40) extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Story 1.19 backfill MUST land before Story 4.1 starts. SCP records this in § Epic Impact + Story 1.19 spec; Epic 4 § Implementation Notes amendment is deferred to Story 1.19 implementation iteration (out of scope for SCP-only iter).
