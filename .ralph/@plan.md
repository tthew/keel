# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — Story 1.18 post-dev SM-verify (FR14n `traced → sm-verified`); forecast 1–4 PATCH per RALPH.md iter-352 narrow-substrate-extension + iter-361 Story 1.17 post-dev SM-verify 4-PATCH datapoint within band.

## QUEUE (Epic 1 reopen — Stories 1.18–1.21 bootstrap arc per issue #233)
- [ ] Story 1.18 lifecycle continues: sm-verified → done (per FR14n matrix; CR via `/bmad-code-review (args: "2")`)
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

_(empty — Story 1.18 ATDD-skipped at iter-365 via FR14n § ATDD-skip ground-(a) substrate-verification per Story 1.17 iter-358 precedent. Three Python smoke scaffolds (`tests/test_ralph.py` + `scripts/tests/test_bootstrap_bmad_agents.py` + `packages/devbox/tui/tests/test_theme.py`) authored at iter-366 dev-story landed GREEN on first run by construction — 4 tests passed (the second `test_format_duration_hour_plus_ends_with_s` was the optional-second-assertion per Subtask 3.1). 30th cumulative project ATDD-skip / 2nd post-(b)-sunset / 3rd course-correction-origin.)_

## DONE (Epic 1 reopen pass — Stories 1.17–1.21)

- [x] iter-1 (prior iter): `/bmad-correct-course` on issue #233 — Sprint Change Proposal authored autonomously per Ralph build-mode batch flow. Outputs: `_bmad-output/planning-artifacts/sprint-change-proposal-issue-233.md` + PRD/architecture/epics/sprint-status amendments per § 4.1–4.4. Epic 1 REOPENED (`epic-1: done → in-progress`); Stories 1.17–1.21 appended to epics.md + sprint-status as backlog. Branch: `chore/correct-course-test-runner-233` (based on `feat/epic-2-packaged-devbox`).
- [x] iter-356 → iter-362: Story 1.17 lifecycle complete (`drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done`). Cumulative pre-merge PATCH count: 22 (16 SM-validate + 4 SM-verify + 2 CR; 0 dev-story; 0 trace; 0 ATDD-skip). Vitest 3.2.4 pinned; smoke test GREEN; `.github/workflows/ci.yml` shipped (first workflow file in repo); CR iter-362 added top-level `permissions: contents: read` + `concurrency: cancel-in-progress` blocks. Epic 1 REOPEN-ARC story 1 of 5 done.
- [x] iter-363: `/bmad-create-story` for Story 1.18 — autonomous discovery from sprint-status first-backlog row (`1-18-bootstrap-python-test-runner-pytest-under-uv`). FR14n state transition `_(no story) → drafted`. Sprint-status row `backlog → ready-for-dev`. **0 SCP-side drifts** at substrate verification. 10 Tasks / ~22 subtasks scaffolded; SC-1 through SC-11 pinned.
- [x] iter-364: `/bmad-create-story (args: "review")` for Story 1.18 — pre-dev SM-validate. FR14n state transition `drafted → validated`. 14 PATCHes applied inline at gate (within iter-363 forecast envelope 8–14). 2 deferred (LLM-OPT). Cumulative pre-merge PATCH count Story 1.18 lifecycle to date: 14.
- [x] iter-365: Story 1.18 ATDD-skipped via FR14n § ATDD-skip clause; FR14n state transition `validated → atdd-scaffolded`. Bare ground-(a) substrate-verification sufficiency. **30th cumulative project ATDD-skip / 2nd post-(b)-sunset / 3rd course-correction-origin.** Cumulative pre-merge PATCH count Story 1.18 lifecycle: 14 (unchanged from SM-validate).
- [x] iter-366: Story 1.18 dev-story landed via `/bmad-dev-story` (Change Log v1.3); FR14n state transition `atdd-scaffolded → in-dev → review` (single-iter same-iteration per RALPH.md iter-344 substrate-extension class — third confirmation after Story 2.18 iter-350 + Story 1.17 iter-359). All 10 Tasks / 22 subtasks complete; all 5 ACs satisfied. **Substrate-probe gap surfaced + corrected at dev-story time:** SM-validate Subtask 3.1 missed `ralph.py:66` top-level `from textual.app import ...` (verified at dev-story via Grep — 5 textual imports at lines 66/67/68/71/72, all top-level). Resolution: added `textual==8.2.4` as 5th dev dep (SC-3 wording was "four"; +1 deviation justified by AC1 satisfaction; SC-3 policy ["exact-version pinning per I7"] preserved on all 5). **Resolved-highest version drift vs spec forecast:** pytest 9.0.3 (vs 8.x), pytest-asyncio 1.3.0 (vs 0.x); ruff 0.15.12 + mypy 1.20.2 within forecast. `pnpm typecheck/lint/format:check` GREEN; sync-gate PARTIAL (3 pre-existing `INV-git-hooks-preservation` drifts per RALPH.md iter-358 — out of scope per SC-9, AC2 satisfied because not attributable to this story); actionlint unavailable (GH ingestion-side fallback per AC3 + Story 1.17 Subtask 10.4 precedent). 0 fix-task QUEUE entries → direct promotion to `review`. Cumulative pre-merge PATCH count Story 1.18 lifecycle: 14 (unchanged — clean dev-story landing, 0 PATCHes at gate; matches Story 1.17 iter-359 zero-PATCH dev-story baseline).
- [x] iter-367 (this iter): Story 1.18 trace landed via `/bmad-testarch-trace (args: "yolo")` (Change Log v1.4); FR14n state transition `in-dev → traced`. Gate **WAIVED** — 30th cumulative trace-WAIVED + 2nd Epic-1-reopen-arc + 3rd course-correction-origin. Coverage 1/5 FULL (20%); P0 50% (AC1 FULL via 4 pytest smokes; AC2 PARTIAL — sync-gate green for new drift, manifest registration deferred per SC-8 + SC-9); P1 0% (AC3 PARTIAL — `actionlint` unavailable, GH ingestion fallback); P2 0% (AC4 + AC5 doc-substrate PARTIAL). Hybrid grounds (a)+(c) variant-(ii)+(iii) per IP § NOW directive. 0 fix-task QUEUE entries → direct promotion to `traced`. Trace artefacts at `_bmad-output/test-artifacts/traceability/1-18-bootstrap-python-test-runner-pytest-under-uv.md` + `…-e2e-trace-summary.json` + `…-gate-decision.json`. Cumulative pre-merge PATCH count Story 1.18 lifecycle: 14 (unchanged — WAIVED applies no patches; matches Story 1.17 iter-360 zero-PATCH trace baseline).

## Context

- **Phase:** 4-implementation — Story 1.18 traced (FR14n `traced` state at iter-367; Story file `Status: review`). Epic 1 REOPENED (`epic-1: in-progress` per issue #233 SCP) for Stories 1.17–1.21 bootstrap arc; 4 stories remaining in lifecycle (1.18 in post-dev SM gate, 1.19 keel-invariants backfill, 1.20 FR14i activation, 1.21 audit + sweep). Epic re-close at Story 1.21 done.
- **Runtime:** cc-devbox iteration env. `uv 0.11.7` available at `/usr/local/bin/uv` (confirmed at substrate probe). Python 3.12.3 at `/usr/bin/python3` (satisfies `requires-python = ">=3.10"`). `actionlint` not available (GH ingestion-side fallback per AC3). github.com / api.github.com network access intermittent (DNS-rotation; PR #235's fix in container image: TBD).
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (REOPENED for Stories 1.17–1.21).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` — this work targets it as the PR base, not `main`.
- **Working Branch:** `chore/correct-course-test-runner-233` (based on `origin/feat/epic-2-packaged-devbox`).
- **Story:** Story 1.18 — Bootstrap Python test runner (pytest under uv) + root pyproject.toml.
- **Story File:** `_bmad-output/implementation-artifacts/1-18-bootstrap-python-test-runner-pytest-under-uv.md`.
- **Story State:** `traced` (trace landed at iter-367 via `/bmad-testarch-trace (args: "yolo")`; FR14n state transition `in-dev → traced`; gate WAIVED per IP § NOW directive). **Next-NOW per FR14n matrix:** `traced → sm-verified` via `/bmad-create-story (args: "review")`; forecast 1–4 PATCH per RALPH.md iter-352 narrow-substrate-extension empirical envelope + iter-361 Story 1.17 post-dev SM-verify 4-PATCH datapoint within band.
- **GitHub Issue:** Issue #233 ("Course Correction: Bootstrap test runner + CI"). PR #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`) carries `Refs #233`; `Closes #233` lands at Story 1.21 close-out per stacked-arc plan.
- **PR:** #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`).

## Notes

- **Course-correction precedent stack 3 deep:** issue #231 (PR #234, doc-budget, MERGED) → issue #232 (PR #235, devbox network, MERGED) → issue #233 (PR #236, test runner bootstrap, in-flight). Issue #233 is the first to REOPEN a closed epic.
- **Story 1.17 → 1.18 inheritance:** Story 1.18 inherits the `.github/workflows/ci.yml` substrate (Story 1.17 shipped it) and the AGENTS.md `## Testing` section (Story 1.17 inserted it with a forward-pointer). Story 1.18 EXTENDED both additively per SC-5 + AC5 — both edits landed cleanly at iter-366.
- **Pre-existing INV-git-hooks-preservation drifts:** 3× drifts persist on `feat/epic-2-packaged-devbox` head (RALPH.md iter-358 gotcha — sync-gate hardcodes `<repoRoot>/.git/hooks` which is empty in worktree mode). Out of scope for Story 1.18 per SC-9 carve-out; address before Story 1.20 close-out.
- **Story 1.19 budget warning:** keel-invariants backfill has 4–6 CR-iteration budget exposure (vs 1–2 typical). Pre-existing impl bugs in `keel-invariants` will surface for the first time under test.
- **Epic 4 hard-precondition:** Epic 4 (per-iteration security verification, FR35–FR40) extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Story 1.19 backfill MUST land before Story 4.1 starts.
- **Substrate-probe gap class identified at iter-366:** SM-validate substrate probes can miss top-level imports inside otherwise-guarded modules (e.g. `ralph.py:66` `from textual.app import` evaluated unconditionally despite `if __name__ == "__main__":` at `:2015-2016` guarding only App instantiation). Future story SM-validate substrate probes that cite "module-level import has no side-effects" must explicitly grep for ALL top-level imports of any non-stdlib package; the `__main__` guard alone is insufficient evidence. Carry-rule for Story 1.19 + Story 1.20 + Epic 4 stories that test/load substrate Python modules.
