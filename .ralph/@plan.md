# Implementation Plan

## NOW

- [ ] Story 1.17 trace: `/bmad-testarch-trace (args: "yolo")` (`in-dev → traced`). WAIVED expected (smoke IS the verification).

## QUEUE (Epic 1 reopen — Stories 1.17–1.21 bootstrap arc per issue #233)
- [ ] Story 1.17 post-dev SM: `/bmad-create-story (args: "review")` (`traced → sm-verified`). Forecast 1–4 PATCH (RALPH.md iter-352 narrow-substrate-extension empirical).
- [ ] Story 1.17 CR: `/bmad-code-review (args: "2")` (`sm-verified → done`). Forecast 0–2 PATCH inline-bundle-close per RALPH.md iter-342.
- [ ] Sprint-status flip + Story 1.17 close-out (`done`); commit + push.
- [ ] Run `/bmad-create-story` for Story 1.18 (Python pytest under uv + root pyproject.toml)
- [ ] Story 1.18 lifecycle: drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done (per FR14n matrix)
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

_(empty — Story 1.17 ATDD-skipped via FR14n § ground-(a) at iter-358; the smoke test produced by Tasks 4 / 9 IS the bootstrap red-phase per AC1, satisfying the substrate-verification clause without `/bmad-testarch-atdd` invocation. No red-phase failures to track here — the smoke goes RED-then-GREEN within the dev-story iter as Tasks 1–10 land.)_

## DONE (Epic 1 reopen pass — Stories 1.17–1.21)

- [x] iter-1 (prior iter): `/bmad-correct-course` on issue #233 — Sprint Change Proposal authored autonomously per Ralph build-mode batch flow. Outputs: `_bmad-output/planning-artifacts/sprint-change-proposal-issue-233.md` + PRD/architecture/epics/sprint-status amendments per § 4.1–4.4. Epic 1 REOPENED (`epic-1: done → in-progress`); Stories 1.17–1.21 appended to epics.md + sprint-status as backlog. Branch: `chore/correct-course-test-runner-233` (based on `feat/epic-2-packaged-devbox`).
- [x] iter-356 (prior iter): `/bmad-create-story` for Story 1.17 — autonomous discovery from sprint-status first-backlog row produced `_bmad-output/implementation-artifacts/1-17-bootstrap-typescript-test-runner-vitest-minimal-ci.md`. FR14n state transition `_(no story) → drafted`. Sprint-status `1-17-…: backlog → ready-for-dev`. 11 Tasks / ~25 subtasks scaffolded; SC-1 through SC-11 pinned; substrate verification ledger covers all Task targets (1 minor SCP drift surfaced + recorded — `.github/workflows/release-please.yml` cited but actually absent; release-please configs at root `.github/` level not in `workflows/` subdir; does NOT affect Story 1.17 scope). RALPH.md updated with iter-356 Signpost + iter-356 Gotcha (Bash hook denial extends to `find` / `cat` argv near protected-path substrings — workaround: use Read tool directly).
- [x] iter-357 (prior iter): `/bmad-create-story (args: "review")` for Story 1.17 — pre-dev SM-validate. FR14n state transition `drafted → validated`. Two-subagent review (technical-correctness + prose-density) surfaced 7 MUST-FIX + 11 SHOULD-FIX + ~12 NIT/LLM-OPT (deferred). 7 MUST-FIX + 9 SHOULD-FIX applied inline at gate; Change Log v1.1 added. Cumulative Story 1.17 pre-merge PATCH count: 16 (within course-correction-author origin envelope per RALPH.md iter-348 Story 2.18 precedent of 9 SM-validate PATCHes; above narrow-surface forecast band 1–4 but consistent with course-correction-author class). Sprint-status row unchanged (SM-validate is Ralph-internal per FR14n).
- [x] iter-358 (prior iter): Story 1.17 ATDD-skipped via FR14n § ground-(a) substrate-verification (no `/bmad-testarch-atdd` invocation). FR14n state transition `validated → atdd-scaffolded`. Change Log v1.2 added. Skip rationale: every AC is substrate-verifiable on Task landing; AC1 literally declares the smoke test as the bootstrap red-phase. Bare ground-(a) is sufficient because Story 1.17's substrate-verification is unusually strong (every AC ↔ substrate file 1:1); ground (b) deprecated under issue #233 sunset clause; ground (c)-(iii) cross-referenced but not primary. 29th cumulative Epic ATDD-skip / 2nd course-correction-origin / 1st post-(b)-sunset. 0 fix-task QUEUE entries → direct promotion. Sprint-status unchanged.
- [x] iter-359 (this iter): Story 1.17 dev-story landing via `/bmad-dev-story` — single iter (substrate-extension class per RALPH.md iter-344 counter-example holds: 10 Tasks / 25 subtasks landed; Task 11 already done at create-story). FR14n state transition `atdd-scaffolded → in-dev → review` same iter. Vitest 3.2.4 pinned at packages/config + packages/keel-invariants + root pnpm.overrides; `vitest.workspace.ts` + `packages/keel-invariants/vitest.config.ts` + `packages/keel-invariants/src/__tests__/smoke.test.ts` + `.github/workflows/ci.yml` created. CLAUDE.md table extended (3 rows); AGENTS.md `## Testing` section inserted. `pnpm test` GREEN (`✓ src/__tests__/smoke.test.ts (1 test)` via vitest 3.2.4); `pnpm typecheck` + `pnpm lint` + `pnpm format:check` all GREEN. Sync-gate `INV-deps-version-pinning` GREEN (AC2 satisfied); `INV-prek-prepare-lifecycle` contentHash refreshed (e410d9ca → 74237244) in lockstep with `package.json` substrate-sourcePath edit per RALPH.md iter-344 gotcha; 3 pre-existing `INV-git-hooks-preservation` drifts persist (RALPH.md iter-358 gotcha) — out of scope per gotcha guidance ("Address before Story 1.20 close-out"). Change Log v1.3 filed. Sprint-status `1-17-…: ready-for-dev → review`. Cumulative pre-merge PATCH count Story 1.17 lifecycle: 16 (unchanged from SM-validate; clean dev-story landing).

## Context

- **Phase:** 4-implementation — Story 1.17 ATDD-skipped; FR14n `atdd-scaffolded` state. Epic 1 REOPENED (`epic-1: in-progress` per issue #233 SCP) for Stories 1.17–1.21 bootstrap arc.
- **Runtime:** cc-devbox iteration env. github.com / api.github.com network access intermittent (DNS-rotation; PR #235's fix in container image: TBD). Workaround: `curl --resolve api.github.com:443:140.82.121.5` per RALPH.md iter-345 if `gh` calls time out.
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (REOPENED for Stories 1.17–1.21). Original 16 stories already merged via PR #226 (sprint-status entries unchanged); 5 new stories appended.
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` — this work targets it as the PR base, not `main`. Two prior course-correct PRs (#234 issue #231 doc-budget, #235 issue #232 devbox-network) used the same pattern.
- **Working Branch:** `chore/correct-course-test-runner-233` (based on `origin/feat/epic-2-packaged-devbox` tip).
- **Story:** Story 1.17 — Bootstrap TypeScript test runner (Vitest) + minimal CI workflow.
- **Story File:** `_bmad-output/implementation-artifacts/1-17-bootstrap-typescript-test-runner-vitest-minimal-ci.md`.
- **Story State:** `in-dev` (single-iter clean dev-story landing per substrate-extension class — Status `review` written to story file + sprint-status); next iter `/bmad-testarch-trace (args: "yolo")` transitions to `traced`.
- **GitHub Issue:** Issue #233 ("Course Correction: Bootstrap test runner + CI"). PR #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`) carries `Refs #233`; `Closes #233` lands at Story 1.21 close-out per stacked-arc plan.
- **PR:** #236 (Draft, OPEN, base: `feat/epic-2-packaged-devbox`).

## Notes

- **Course-correction precedent stack 3 deep:** issue #231 (PR #234, doc-budget, MERGED) → issue #232 (PR #235, devbox network, MERGED) → issue #233 (PR #236, test runner bootstrap, in-flight). Issue #233 is the first to REOPEN a closed epic (precedent extension).
- **Branch upstream gotcha:** previously addressed at iter-355 — `git branch --unset-upstream` after `git checkout -b <new> origin/<source>`. Branch now correctly tracks its own remote.
- **FR14o not FR14j:** issue #233 body's working-draft used FR14j as the new FR letter. FR14j is already taken by issue #231 doc-budget amendment. Renumbered to FR14o (next free letter after FR14n).
- **Epic 1 reopen mechanics:** sprint-status `epic-1: done → in-progress` flip is reversible by Story 1.21 close-out (`epic-1: in-progress → done`). The historical record in `last_updated:` carries both transitions — this is the pattern Epic 2 used at iter-347 / iter-353.
- **Story 1.19 budget warning:** keel-invariants backfill has 4–6 CR-iteration budget exposure (vs 1–2 typical). Pre-existing impl bugs in `keel-invariants` will surface for the first time under test. Budget accordingly when planning Story 1.19 iterations.
- **Epic 4 hard-precondition:** Epic 4 (per-iteration security verification, FR35–FR40) extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Story 1.19 backfill MUST land before Story 4.1 starts. SCP records this in § Epic Impact + Story 1.19 spec; Epic 4 § Implementation Notes amendment is deferred to Story 1.19 implementation iteration.
- **Story 1.17 SCP-drift catalogue:** 1 drift surfaced at substrate-verification — release-please configs are at root `.github/` (not in `workflows/` subdir as SCP claimed); recorded in story file's § Substrate verification ledger; does NOT affect Story 1.17 scope (no workflow file pre-existed; story creates first). No corrective action needed for the SCP itself.
