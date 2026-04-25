# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` for Story 1.18 — pre-dev SM-validate (FR14n `drafted → validated`).

## QUEUE (Epic 1 reopen — Stories 1.18–1.21 bootstrap arc per issue #233)
- [ ] Story 1.18 lifecycle continues: validated → atdd-scaffolded → in-dev → traced → sm-verified → done (per FR14n matrix)
- [ ] Run `/bmad-create-story` for Story 1.19 (keel-invariants test backfill — highest-risk untested code; budget 4–6 CR iterations)
- [ ] Story 1.19 lifecycle
- [ ] Run `/bmad-create-story` for Story 1.20 (Activate FR14i — register `INV-fr14i-ci-workflow-presence`; address pre-existing 3× `INV-git-hooks-preservation` drifts before close-out per RALPH.md iter-358)
- [ ] Story 1.20 lifecycle
- [ ] Run `/bmad-create-story` for Story 1.21 (audit + sweep prior ATDD-skip into test-debt.md)
- [ ] Story 1.21 lifecycle
- [ ] Re-close Epic 1 (`epic-1: in-progress → done` after Story 1.21 closes); transition PR Draft→Open final CI gate

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty — Story 1.17 closed at iter-362 with smoke test GREEN. Story 1.18 ATDD-skip forecast: ground-(a) substrate-verification (the three Python smoke scaffolds ARE the bootstrap red-phase per AC1; FR14n § ground-(b) sunset post-Story-1.17).)_

## DONE (Epic 1 reopen pass — Stories 1.17–1.21)

- [x] iter-1 (prior iter): `/bmad-correct-course` on issue #233 — Sprint Change Proposal authored autonomously per Ralph build-mode batch flow. Outputs: `_bmad-output/planning-artifacts/sprint-change-proposal-issue-233.md` + PRD/architecture/epics/sprint-status amendments per § 4.1–4.4. Epic 1 REOPENED (`epic-1: done → in-progress`); Stories 1.17–1.21 appended to epics.md + sprint-status as backlog. Branch: `chore/correct-course-test-runner-233` (based on `feat/epic-2-packaged-devbox`).
- [x] iter-356 → iter-362: Story 1.17 lifecycle complete (`drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done`). Cumulative pre-merge PATCH count: 22 (16 SM-validate + 4 SM-verify + 2 CR; 0 dev-story; 0 trace; 0 ATDD-skip). Vitest 3.2.4 pinned; smoke test GREEN; `.github/workflows/ci.yml` shipped (first workflow file in repo); CR iter-362 added top-level `permissions: contents: read` + `concurrency: cancel-in-progress` blocks. Epic 1 REOPEN-ARC story 1 of 5 done.
- [x] iter-363 (this iter): `/bmad-create-story` for Story 1.18 — autonomous discovery from sprint-status first-backlog row (`1-18-bootstrap-python-test-runner-pytest-under-uv`). FR14n state transition `_(no story) → drafted`. Sprint-status row `backlog → ready-for-dev`. **0 SCP-side drifts** at substrate verification (improvement vs Story 1.17 iter-356's 1 drift — Python sibling inherits already-shipped CI workflow). 10 Tasks / ~22 subtasks scaffolded; SC-1 through SC-11 pinned (Python version, dev-dep pinning, action versions, smoke targets, PEP 723 coexistence direction all locked at SM-validate per RALPH.md iter-357 lesson). Story file at `_bmad-output/implementation-artifacts/1-18-bootstrap-python-test-runner-pytest-under-uv.md`. Forecast envelope: 10–24 cumulative pre-merge PATCH (vs Story 1.17's 22).

## Context

- **Phase:** 4-implementation — Story 1.18 drafted (FR14n `drafted` state at iter-363). Epic 1 REOPENED (`epic-1: in-progress` per issue #233 SCP) for Stories 1.17–1.21 bootstrap arc; 4 stories remaining (1.18 in-flight, 1.19 keel-invariants backfill, 1.20 FR14i activation, 1.21 audit + sweep). Epic re-close at Story 1.21 done.
- **Runtime:** cc-devbox iteration env. `uv 0.11.7` available at `/usr/local/bin/uv` (confirmed at substrate probe). github.com / api.github.com network access intermittent (DNS-rotation; PR #235's fix in container image: TBD).
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (REOPENED for Stories 1.17–1.21).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` — this work targets it as the PR base, not `main`.
- **Working Branch:** `chore/correct-course-test-runner-233` (based on `origin/feat/epic-2-packaged-devbox`).
- **Story:** Story 1.18 — Bootstrap Python test runner (pytest under uv) + root pyproject.toml.
- **Story File:** `_bmad-output/implementation-artifacts/1-18-bootstrap-python-test-runner-pytest-under-uv.md`.
- **Story State:** `drafted` (created at iter-363 via `/bmad-create-story` autonomous discovery; FR14n state transition `_(no story) → drafted`. 5 ACs verbatim from SCP-233 § 4.6 + epics.md:1172-1204; 10 Tasks / ~22 subtasks; SC-1 through SC-11 pinned with course-correction-author origin yield mitigation per RALPH.md iter-357 — Python 3.10+ floor / dev-dep exact-pinning / action major-pin / smoke targets / PEP 723 long-term-coexistence direction all locked at SM-validate, NOT deferred. Substrate verification ledger: 0 drifts. Next NOW = `/bmad-create-story (args: "review")` for SM-validate gate.
- **GitHub Issue:** Issue #233 ("Course Correction: Bootstrap test runner + CI"). PR #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`) carries `Refs #233`; `Closes #233` lands at Story 1.21 close-out per stacked-arc plan.
- **PR:** #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`).

## Notes

- **Course-correction precedent stack 3 deep:** issue #231 (PR #234, doc-budget, MERGED) → issue #232 (PR #235, devbox network, MERGED) → issue #233 (PR #236, test runner bootstrap, in-flight). Issue #233 is the first to REOPEN a closed epic.
- **Story 1.17 → 1.18 inheritance:** Story 1.18 inherits the .github/workflows/ci.yml substrate (Story 1.17 shipped it) and the AGENTS.md `## Testing` section (Story 1.17 inserted it with a forward-pointer). Story 1.18 EXTENDS both additively per SC-5 + AC5.
- **Pre-existing INV-git-hooks-preservation drifts:** 3× drifts persist on `feat/epic-2-packaged-devbox` head (RALPH.md iter-358 gotcha — sync-gate hardcodes `<repoRoot>/.git/hooks` which is empty in worktree mode). Out of scope for Story 1.18 per SC-9 carve-out; address before Story 1.20 close-out.
- **Story 1.19 budget warning:** keel-invariants backfill has 4–6 CR-iteration budget exposure (vs 1–2 typical). Pre-existing impl bugs in `keel-invariants` will surface for the first time under test.
- **Epic 4 hard-precondition:** Epic 4 (per-iteration security verification, FR35–FR40) extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Story 1.19 backfill MUST land before Story 4.1 starts.
