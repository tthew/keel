# Implementation Plan

## NOW

- [ ] Re-queue `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md")` — advance Story 2.1 `in-dev (partial) → in-dev` by closing Tasks 4 + 5-run + 7.3 once Docker daemon is available in the iteration environment (operator bake out-of-band OR devbox-enabled CI). Source-level work (Tasks 1-3, 6, 8 + Task 7.1/7.2/7.4) landed in iter-99. ~medium

## QUEUE (Epic 2 Story 2.1)

- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability (in-dev → traced or trace-fixes-pending)
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (traced → sm-verified)
- [ ] Run `/bmad-code-review (args: "2")` — CR with Create-action-items (sm-verified → done or fixes-pending)
- [ ] Monitor PR CI — queue fix tasks for any failures
- [ ] Transition PR Draft→Open — final CI gate (after all Epic 2 stories done)

## BLOCKED

- [ ] **Docker daemon unavailable in Ralph container — Story 2.1 Tasks 4 + 5-run + 7.3 execution blocked.** REASON: AC 3 `docker compose build/run pnpm test/lint` + AC 4 `scripts/benchmark.sh` (cold/warm NFR2 measurement) + Task 7.3 `docker compose config` parse all require a Docker daemon; the Ralph container has no `docker` binary on PATH and no socket mount. By story design (AC 4 scope clarification), NFR2 baseline is the operator's M4-Pro workstation, not a CI sandbox.
  - Attempted: `command -v docker` → not found; `docker compose version` → command not found.
  - Error/Issue: Source-level artefacts complete and static checks all pass (grep exit 1, pin-rationale header present, `100755` executable bits confirmed), but dynamic verification is externally-gated on Docker availability.
  - Next (5-step operator run plan — captured in story Dev Agent Record § Blocked):
    1. Operator workstation runs `docker compose -f packages/devbox/docker-compose.yml build` → expect exit 0.
    2. Operator workstation runs `docker compose -f packages/devbox/docker-compose.yml config` → expect exit 0 (Task 7.3).
    3. Operator workstation runs `docker compose -f packages/devbox/docker-compose.yml run --rm devbox pnpm test` and `… pnpm lint` → expect exit 0 for both (AC 3).
    4. Operator workstation runs `packages/devbox/scripts/benchmark.sh` → appends cold / warm timings to `packages/devbox/README.md § Benchmarks` (AC 4). Budgets: cold ≤ 300 s, warm ≤ 30 s.
    5. On successful bake + benchmark: next Ralph iteration reads README diff, marks Tasks 4 + 5-run + 7.3 `[x]` in story file, updates VERSIONS.md bake log with pinned versions, flips Story Status `in-progress → review`, advances Story State `in-dev (partial) → in-dev`, and queues `/bmad-testarch-trace (args: "yolo")`.
  - Escalation posture per AC 4 scope clarification: if cold-start delta > 2× NFR2 budget on the operator run, escalate with a cc-devbox-comparison note here rather than flipping Story Status.

## DONE (Epic 2 Story 2.1)

- [x] iter-99: **Story 2.1 `/bmad-dev-story` source-level implementation pass (atdd-scaffolded → in-dev partial).** Authored `packages/devbox/Dockerfile` (Ubuntu 24.04 LTS pin-rationale block-comment header + 9 RUN layers baking node 20 LTS via NodeSource + pnpm 10.29.2 + `@anthropic-ai/claude-code` + `gh` via `cli.github.com` apt + `uv` Astral installer + AWS CLI v2 arch-aware + Supabase CLI release `.deb` + git-delta release `.deb` + Playwright OS deps reconciled via `npx playwright install-deps`). Authored `packages/devbox/docker-compose.yml` (single `devbox` service, `env_file: ../../.envrc` with `required: false`, `KEEL_DEVBOX_WORKSPACE`-parameterised bind mount for Story 2.11 future-compat, TODO comments naming Stories 2.2/2.5/2.8/2.9/2.13 as owners of deferred stanzas). Authored `packages/devbox/entrypoint.sh` narrowed to chown + named-volume dir pre-create + `exec "$@"` keepalive with shebang `#!/usr/bin/env bash` + `set -euo pipefail` + `100755` git bit. Authored `packages/devbox/scripts/benchmark.sh` (NFR2 measurement script with cold prune + warm down/up passes + append-only README writes; `100755`). Authored `packages/devbox/VERSIONS.md` (toolchain version table + Epic 6 forward-compat roster enumerating psql / delta / bind-mount tooling + bake log with iter-99 entry). Rewrote `packages/devbox/README.md` from 4-line stub to full M0.5 deliverable status table + Ubuntu pin rationale + baked toolchain summary + Story-2.1-scope `docker compose` usage block + "what this story does NOT deliver" 17-row roadmap table + § Benchmarks scaffold + cc-devbox upstream provenance section. Updated sprint-status.yaml `2-1-...: ready-for-dev → in-progress` + `last_updated: 2026-04-21 Story-2-1-in-progress UTC`. Static Task 7 gates PASS: 7.1 runtime-install grep returned exit 1 (no matches); 7.2 Dockerfile pin-rationale header confirmed first content via `head -5`; 7.4 `git ls-files -s` returned `100755` for both `entrypoint.sh` + `scripts/benchmark.sh`. **Dynamic gates BLOCKED — Docker daemon unavailable** (see § BLOCKED). Story State `atdd-scaffolded → in-dev (partial)`. Change Log v1.3 written in-situ to story file with full authored-artefact enumeration + blocked substeps + partial-completion rationale.
- [x] iter-98: **Story 2.1 /bmad-testarch-atdd ELEVENTH cumulative ATDD-SKIP (validated → atdd-scaffolded).** FR14n matrix row 3 skip path. Hybrid ground-(c) variant-(ii)+(iii) + NEW ground-(d) upstream-provenance precedent-extension. First Epic 2 ATDD-skip and first "infrastructure-smoke class" precedent. Skill preflight HALTs at Step 1.2 (no test runner — vitest/jest/playwright/pytest/go/rust/ruby configs absent). Four-ground rationale detailed in Change Log v1.2. Story State `validated → atdd-scaffolded`.
- [x] iter-97: **Story 2.1 pre-dev validation (drafted → validated) — ZERO critical issues, 5 enhancements applied.** `/bmad-create-story (args: "review")` autonomous mode. Gap-analysis subagent cross-referenced epics/prd/arch with zero critical blockers; 5 tightening edits (Task 2 apt list adds `postgresql-client`, Task 1 drops redundant `.gitkeep`, Task 4 tightens "exit 0" ambiguity, AC4 adds single-run variance posture, Dev Note pins `pg-init.sql` to Epic 6 Story 6.1). Story State `drafted → validated`.
- [x] iter-96: **Epic 1 → Epic 2 cross-epic auto-advance.** PR #226 MERGED at 2026-04-21T09:41:48Z. Per PROMPT_build.md § Cross-epic transition step 3 MERGED branch: NOW = `/bmad-create-story` (no halt, no re-entry loop). Branch `feat/epic-2-packaged-devbox` off main. Sprint-status flipped `epic-2: backlog → in-progress` + `2-1-…: backlog → ready-for-dev`. Story file authored with full BDD ACs + scope carve-outs. Story State `_(no story) → drafted`.

## Context

- **Phase:** 4-implementation — Epic 2 open, Story 2.1 in-dev (partial). Docker-dependent dynamic verification blocked on operator workstation.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; Story 2.1 is the image + compose + entrypoint foundation.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** 2.1 — `packages/devbox/` absorb from cc-devbox (image + compose + substrate tooling access).
- **Story File:** `_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md`
- **Story State:** in-dev (partial) — iter-99 landed Tasks 1-3, 6, 8 + Task 7 static subtasks; Tasks 4, 5-run, 7.3 await Docker-capable environment (see § BLOCKED for the 5-step operator run plan).
- **GitHub Issue:** Story 2.1 → #41 (https://github.com/tthew/ralph-bmad/issues/41). Parent Epic 2 → #10. Commit trailer `Refs #41`.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (no CI runners pre-Epic-13; Draft→Open transition queued at end of Epic 2).

## Notes

- **Docker-unavailable precedent (FIRST occurrence).** The Ralph container has no `docker` binary and no socket mount — a class of environment Ralph had not previously encountered in Epic 1's documentation/config work. The Dev Agent Record § Blocked in the story file, the BLOCKED entry in this IP, and the v1.3 Change Log all capture the 5-step operator-workstation follow-up plan. RALPH.md signpost appended. Future Epic 2 stories (2.3 egress, 2.5 hardening, 2.6 CLI, etc.) will hit the same blocker unless Docker is made available in the Ralph iteration environment OR dev-story's dynamic verification is delegated downstream (Epic 13 CI harness with Docker-in-Docker, or an explicit operator-workstation gate pattern).
- **Partial-completion pattern validated.** PROMPT_build.md § dev-story invocation states: "If dev-story returns with un-finished tasks (partial completion), record `Story State = in-dev (partial)` in IP Context and queue it again in the next iteration." iter-99 is the first real exercise of this rule. Next-Ralph's iter-100 re-queues `/bmad-dev-story` but will no-op (or at best, only re-verify static gates) until the blocker clears.
- **ATDD-skip precedent-extension to Epic 2** (see iter-98 DONE entry + RALPH.md signpost). All remaining Epic 2 stories share the infrastructure-smoke class; future-Ralph re-uses the variant-(ii)+(iii)+(d) template without framework-detection deliberation.
- **Cross-epic auto-advance pattern validated** (iter-96).
- **Story 2.1 scope bounded by AC1-AC4 literally.** Scope carve-outs in the story file pin what 2.1 delivers vs what later Epic 2 stories own. iter-99 implementation preserved this — no bleed into Stories 2.2-2.17.
- **Substrate pre-existing `packages/devbox/`** TypeScript scaffold preserved; Story 2.1 ADDED runtime-infrastructure siblings only.
- **`/bmad-dev-story` iteration budget posture.** iter-99 executed within budget (no Docker wall-clock consumed; pure authoring + static checks + story-file edits + IP/RALPH upkeep). Next Ralph iter budget depends on whether Docker is available — if so, add 5–7 min wall-clock for the Docker cold-build pass (operator-workstation envelope).
