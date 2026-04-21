# Implementation Plan

## NOW

- [ ] Run `/bmad-code-review (args: "2")` — post-SM CR adversarial action-items gate. State transition `sm-verified → done` (ZERO-PATCH close) OR `sm-verified → fixes-pending` (per FR14n adversarial default). Forecast: TIGHTER envelope than Story 2.1's iter-128 → iter-138 → iter-144 three-cycle / 9-AI opener — (a) no operator-owned carve-out to adjudicate, (b) all 5 ACs live-verified at trace + SM time, (c) `check-no-committed-dotfiles.ts` is 36 lines of Node-only leaf code (minimal adversarial attack surface vs 2.1's image + compose + shell + markdown + manifest cross-cutting surface). ~small (skill runs in its own fresh-context iteration; Ralph's iteration is orient + queue + commit + push).

## QUEUE (Story 2.2 `sm-verified → done`)

- [ ] _(conditional, post-Story-2.17 done)_ Transition PR #230 Draft→Open — final CI gate after all Epic 2 stories done; monitor CI; merge.
- [ ] _(conditional, post-Epic-2 merged)_ § Cross-epic transition → Epic 3 Story 3.1 via `/bmad-create-story` OR halt EPIC_DONE awaiting merge.

## BLOCKED

_(none — Story 2.2 SM-verified ZERO-PATCH + ZERO-CARVE-OUT; lifecycle continues via CR gate.)_

## DONE (Story 2.2 — iter-145 draft, iter-146 review-with-fixes, iter-147 ATDD-skip, iter-148 dev-story, iter-149 trace, iter-150 SM-verified)

- [x] iter-150: **`/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification — verdict `sm-verified`; Story State `traced → sm-verified`; ZERO-PATCH + ZERO-CARVE-OUT.** Second Epic 2 post-dev SM precedent (Story 2.1 iter-127 → Story 2.2 iter-150); **first hybrid infrastructure-smoke + configuration-surface story with NO operator-owned carve-out** (contrast Story 2.1 iter-127's backend-B bind-mount / M4-Pro-native carve-outs on AC 3/4). AC-by-AC verdict SATISFIED ×5: AC 1 (`.envrc.example` 14-line header + 14-knob enumeration + 6-section grouping) + AC 2 (compose parameterisation live-verified `docker compose config` exit 0; cpus 8 / mem_limit 12884901888 = 12 GB / shm_size 2147483648 = 2 GB / platform linux/arm64 / nofile 65536 / 4× host_ip 127.0.0.1) + AC 3 (retune override `KEEL_DEVBOX_MEMORY_GB=16 KEEL_DEVBOX_CPUS=4` → cpus 4 + mem_limit 17179869184 = 16 GB at YAML-substitution time) + AC 4 (`.secrets.example` 6-key scaffold verbatim architecture.md:328) + AC 5 (lint rule + `.gitignore` + prek hook + manifest entry + INVARIANTS.md anchor + invariant doc; sync-gate `node dist/check.js` exit 0 re-verified this iter). Scope-creep audit CLEAN (no tmpfs / SSH / shared / healthcheck / pnpm devbox:* beyond Story 2.2 scope); source citations all re-resolve (epics.md:1200-1231, prd.md:1079-1080 + 547-551, architecture.md:275-295 + 299-342 + 328). Residual non-blocking deviations (pre-disclosed iter-148 v1.3 + iter-149 trace): (1) prek binary not in iteration env — node-direct + pnpm-script substitute with identical script-layer semantics; (2) `git check-ignore -v` git 2.43 exit-code deviation — functional equivalent via `git status` + `git add --dry-run`; (3) Task 4 `/tmp/fake.envrc` spec-drift — corrected smoke uses `/tmp/.envrc`. SM judgement on all three: ACCEPTED — none affect AC text satisfaction. Status stays `review` (sprint-status unchanged; `done` flips at CR closure). Deliverable: one Change Log v1.4 entry appended to `_bmad-output/implementation-artifacts/2-2-envrc-parameterisation-contract.md`. Budget: ~35K tokens. Next: `/bmad-code-review (args: "2")` for `sm-verified → done` OR `fixes-pending`.

- [x] iter-149: **`/bmad-testarch-trace (args: "yolo")` WAIVED — TWELFTH cumulative Epic WAIVED precedent; Story State `in-dev → traced`.** Four artifacts authored in `_bmad-output/test-artifacts/traceability/`. Full detail in `f349dd7` commit message + story file Change Log.

- [x] iter-148: **`/bmad-dev-story` landed Story 2.2 implementation in a single iteration (all 8 Tasks complete; AC 1–AC 5 green); Story State `atdd-scaffolded → in-dev`.** Full detail in `ff8121a` commit message.

- [x] iter-147: **`/bmad-testarch-atdd` ATDD-SKIP — TWELFTH cumulative Epic precedent** — full detail in `44e4ce2` commit message.

- [x] iter-146: **`/bmad-create-story (args: "review")` pre-dev SM validation applied 9 fixes** — full detail in `cc9aee8` commit message + story file v1.1 Change Log.

- [x] iter-145: **`/bmad-create-story` produced story file draft (Story State: `_(no story) → drafted`; sprint-status `2-2: backlog → ready-for-dev`).** Full detail in `fd03e1d` commit message.

## Context

- **Phase:** 4-implementation — Epic 2 open at 1/17 stories done (2.1 done at iter-144); Story 2.2 `sm-verified` as of iter-150.
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available` § Backend contract). Iteration-context bind-mount denial persists — but Story 2.2's substrate evidence is NOT bind-mount-dependent (pre-daemon YAML-time / static-file / CLI-exit-code / sync-gate checks), so the denial is non-blocking at SM time. Operator-workstation resolves prek binary install via native prek + `pnpm install && pnpm exec prek run` when needed.
- **Baked image:** `keel-devbox:local` (iter-123 first bake; 848 MB, linux/arm64). Version matrix in `packages/devbox/VERSIONS.md § Bake log`.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; Story 2.1 done; Story 2.2 `sm-verified` (CR gate remains); Stories 2.3..2.17 in `backlog`.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2; PR #230 transitions to Open at epic completion).
- **Story:** 2.2 — `.envrc` parameterisation contract.
- **Story File:** `_bmad-output/implementation-artifacts/2-2-envrc-parameterisation-contract.md`.
- **Story State:** `sm-verified` — iter-150 `/bmad-create-story (args: "review")` post-dev SM verification ZERO-PATCH + ZERO-CARVE-OUT close; Change Log v1.4 entry. Next iteration: `/bmad-code-review (args: "2")` for `sm-verified → done` OR `sm-verified → fixes-pending`.
- **GitHub Issue:** Story 2.2 issue **#42** (https://github.com/tthew/ralph-bmad/issues/42). Parent Epic 2 → #10.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (stays Draft across Epic 2; no CI runners pre-Epic-13; transitions to Open at Story 2.17 done).

## Notes

- **DinD is fork-time substrate, not transitional.** `INV-devbox-dind-available` — every fork's cc-devbox-equivalent must provide Docker. Podman/rootless-Docker conformant if daemon reachability holds (backend C extension per iter-144 defer).
- **Backend B is the reference environment at 2026-04-21.** Host socket-passthrough. Broad-state-mutation scripts MUST detect backend + refuse destructive ops by default (`benchmark.sh` reference from iter-122). Bind-mount compose runtime requires host-shared File Sharing allowlist coverage — operator-owned from iteration context. **Story 2.2's SM review confirms the "NO operator-owned carve-out" infrastructure-smoke story class** — `docker compose config` is pre-daemon YAML-time, not bind-mount-dependent.
- **NFR2 authority unchanged.** AC 4 cold ≤ 300s / warm ≤ 30s remains authoritative on M4-Pro native. Story 2.2 is infrastructure-parameterisation — no runtime-performance impact on NFR2.
- **Story 2.2 parameterises knobs for Story 2.5 (tmpfs) + Story 2.11 (shared) + Story 2.12 (loopback ports / SSH).** Those downstream stories activate the tmpfs / shared / SSH knobs that Story 2.2 adds to `.envrc.example`.
- **Twelfth cumulative Epic WAIVED precedent validated** (iter-149). **Cumulative chain: Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57 + 1.12 iter-64 + 1.13 iter-71 + 1.14 iter-78 + 1.15 iter-85 + 1.16 iter-92 + 2.1 iter-126 → 2.2 iter-149.** Twelfth cumulative ATDD-skip precedent validated (iter-147; second Epic 2). **Second Epic 2 post-dev SM precedent validated (iter-150; first hybrid class with ZERO-CARVE-OUT).** Exhaustive-context-engine story-creation pattern validated (iter-145). Pre-dev SM validation with parallel-subagent-review pattern validated (iter-146). Single-iteration dev-story landing pattern validated (iter-148). Pre-daemon YAML-time substrate evidence pattern validated (iter-149; first no-carve-out infrastructure-smoke story). Cross-epic auto-advance pattern validated (iter-96). Partial-completion pattern validated (iter-99). Backend-B safety-gate pattern established (iter-122). Review-with-operator-owned-carve-out pattern validated (iter-125). SM-verified-with-operator-owned-carve-out pattern validated (iter-127). **SM-verified-ZERO-CARVE-OUT pattern validated (iter-150 — tighter budget than iter-127 because no topology-constraint adjudication).** CR-fixes-pending-adversarial-default pattern validated (iter-128). CR-re-run-adversarial-default + action-item-bundling pattern validated (iter-138). Doc-drift two-row bundle closure pattern validated (iter-141). Story-artefact spec-vs-code drift closure pattern validated (iter-142). Operator-UX polish pattern validated (iter-143). ZERO-PATCH third-gate close pattern validated (iter-144; three-cycle upper envelope for Epic-2 infrastructure-smoke stories).
