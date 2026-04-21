# Implementation Plan

## NOW

- [ ] Detect operator-bake delta since iter-99 commit `5278738` — if `packages/devbox/README.md § Benchmarks` has a new append-only entry OR `packages/devbox/VERSIONS.md § Bake log` has a new entry, invoke `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md")` to close Tasks 4 + 5-run + 7.3; otherwise commit iter-N detection observation + exit. **Guardrail-3 compliance: no auto-wait; detection gates the predictable no-op `/bmad-dev-story` invocation.** ~small

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

- [x] iter-100..117: **Rolling detect-delta no-op observations since iter-99 commit `5278738`.** Each iter re-ran the cheap detection (read `packages/devbox/README.md` lines 117-122 + `packages/devbox/VERSIONS.md § Bake log`); every iter confirmed the iter-99 "Pending first bake" / "image not baked in the Ralph container environment" entries are still the latest — no operator-bake delta. `/bmad-dev-story` re-invocation stays deferred per the detect-gated pattern (~5-10K tokens per iter vs ~30-50K for a no-op skill call; RALPH.md signpost 2026-04-21). Story State pinned `in-dev (partial)`, PR #230 Draft, `mergeStateStatus: CLEAN`, no CI runners pre-Epic-13. Pattern will continue rolling until the operator workstation runs the 5-step bake plan in § BLOCKED.
- [x] iter-99: **Story 2.1 `/bmad-dev-story` source-level implementation pass (atdd-scaffolded → in-dev partial).** Authored `packages/devbox/{Dockerfile, docker-compose.yml, entrypoint.sh, scripts/benchmark.sh, VERSIONS.md}` + rewrote `README.md`. Static Task 7 gates PASS (runtime-install grep exit 1, Dockerfile pin-rationale header, `100755` bits on both scripts). Sprint-status flipped `2-1-…: ready-for-dev → in-progress`. Dynamic gates (Tasks 4 + 5-run + 7.3) BLOCKED on Docker daemon — see § BLOCKED for the 5-step operator run plan. Change Log v1.3 in story file. Commit `5278738` is the current Story 2.1 source-level baseline referenced by every subsequent detection iter.

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
- **ATDD-skip precedent-extension to Epic 2** (RALPH.md signpost 2026-04-21). All remaining Epic 2 stories share the infrastructure-smoke class; future-Ralph re-uses the variant-(ii)+(iii)+(d) template without framework-detection deliberation.
- **Cross-epic auto-advance pattern validated** (iter-96). **Partial-completion pattern validated** (iter-99 — first real exercise of PROMPT_build.md § dev-story invocation).
- **Story 2.1 scope bounded by AC1-AC4 literally.** Scope carve-outs in the story file pin what 2.1 delivers vs what later Epic 2 stories own. iter-99 preserved this — no bleed into Stories 2.2-2.17. Substrate's pre-existing `packages/devbox/` TS scaffold preserved; Story 2.1 ADDED runtime-infrastructure siblings only.
- **Detection-gated skill re-invocation pattern (iter-100 installs, RALPH.md signpost).** When a skill re-invocation is predictably a no-op (here: Docker still unavailable → `/bmad-dev-story` would re-emit the same partial state), gate the skill invocation behind a cheap detection read rather than burning 30-50K tokens on the skill itself. For Story 2.1 the detection signals are new append-only entries in `packages/devbox/README.md § Benchmarks` or `packages/devbox/VERSIONS.md § Bake log`. Future Epic-2 stories with similar Docker-gated partials adopt the same pattern by pinning their own per-story detection signals. Extends guardrail 3 ("never wait for user input") to "never burn tokens on predictable no-ops".
