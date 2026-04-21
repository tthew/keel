# Implementation Plan

## NOW

- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability matrix. Expected outcome per Story 2.1's infrastructure-smoke class + v1.2 ATDD-SKIP precedent (no Vitest/Playwright suite at 1.0; red-phase harness lands Epic 13): either `traced` (trace skill records AC-to-structural-check coverage via the Task 7 grep regex + Dockerfile pin-rationale + compose config + `100755` checks + iter-123 bake + iter-124 compose config runs as the "tests") or `trace-fixes-pending` with QUEUE fix tasks for any coverage gap (AC 3 + AC 4 dynamic runtime verification gaps fold into operator-owned carve-out per story v1.4). Advances Story State `in-dev → traced` or `trace-fixes-pending`. ~medium

## QUEUE (Epic 2 Story 2.1)
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (`traced → sm-verified` or `sm-fixes-pending`; SM gate decides acceptance of operator-owned carve-out for Tasks 4.2 + 4.3 + 5.2)
- [ ] Run `/bmad-code-review (args: "2")` — CR with Create-action-items (`sm-verified → done` or `fixes-pending`)
- [ ] Implement `packages/keel-invariants/` runtime rule for `INV-devbox-dind-available` — write `packages/keel-invariants/src/check-devbox-dind.ts` asserting (a) `command -v docker && docker info` exit 0, (b) `docker run --rm hello-world` exits 0 (functional criterion per iter-122 doc rewrite), (c) record detected backend (A/B) for downstream consumers to gate on. Add unit test (Epic 13 framework pending; Story 1.9 sync-gate pattern in the meantime), wire into `pnpm keel-invariants:check-all` composite. Spec source: `docs/invariants/devbox-dind.md`. After this lands, bump `contentHash` in the manifest entry accordingly if the doc file changes.
- [ ] Add pre-flight bind-mount probe to `packages/devbox/scripts/benchmark.sh` — after `detect_backend()`, if `BACKEND=B`, run `docker run --rm -v "${workspace}":/_probe alpine:latest true` (or reuse `hello-world` if pulled); on failure emit a structured error ("backend B + workspace not host-shared; see README § Pending first bake; either run on operator workstation with worktree under `/Users/...` or switch to backend A") and exit 2 BEFORE the destructive/up-d phase. Mirrors the iter-122 cold-prune refusal-gate pattern. Spec source: RALPH.md iter-124 signpost.
- [ ] Monitor PR CI — queue fix tasks for any failures
- [ ] Transition PR Draft→Open — final CI gate (after all Epic 2 stories done)

## BLOCKED

_(none — Tasks 4.2 + 4.3 + 5.2 are operator-owned carve-outs per Story 2.1 v1.4; SM review gate is the next arbiter.)_

## DONE (Epic 2 Story 2.1)

- [x] iter-125: **`/bmad-dev-story` re-invocation codifies iter-123+iter-124 empirical evidence.** Applied story-file deltas: Task 2 header annotated with iter-123 bake + version-matrix reference; Task 4 header + subtask 4.1 `[x]` (bake landed iter-123); Tasks 4.2 + 4.3 `[ ]` updated with backend-B bind-mount denial root cause + operator-workstation resolution paths; Task 5 header + subtask 5.2 same treatment (warm-start + cold-prune both operator-owned); Task 7 top-level + Task 7.3 `[x]` (iter-124 compose config PASS); Dev Agent Record § Agent Model Used expanded across iter-99/iter-123/iter-124/iter-125; § Debug Log References added iter-123 bake refs + iter-124 compose config + bind-mount denial probes; § Completion Notes rewritten with AC-by-AC status + Status-flip rationale; § Blocked renamed "Blocked (backend-B bind-mount-denial carve-out under iteration context)" + resolution timeline (iter-121→122→123→124→125) + bounded-scope rationale + 4-step operator follow-up path; § File List refreshed with iter-122/123/124 modifications + substrate-level files emitted during execution; Change Log v1.4 appended (before v1.2 per existing sort convention). `sprint-status.yaml`: 2-1 `in-progress → review`, `last_updated` refreshed. Status: `in-progress → review`. Story State: `in-dev (partial) → in-dev`.

- [x] iter-124: **Exercise the baked image — empirical outcome.** Task 7.3 (`docker compose config`) exits 0. Tasks 4 + 5-run BLOCKED on backend-B bind-mount denial (iteration-container worktree path not in host Docker Desktop File Sharing allowlist). Probes confirmed: `/tmp` ✓, `$PWD` ✗. `benchmark.sh` failed cleanly via `set -euo pipefail` (no corrupt README entry). Updated `packages/devbox/README.md § Pending first bake` with the iter-123+iter-124 empirical summary + operator-owned carve-out scope extension. RALPH.md iter-124 signpost added. iter-125 codified deltas into story file.

- [x] iter-123: **First successful devbox image bake (safe-subset, backend B).** `keel-devbox:local` — image ID `e7e91f1537f1`, 848 MB, linux/arm64, ~4.5 min. Captured pinned tool versions from inside the image (node 20.20.2, pnpm 10.29.2, claude-code 2.1.116, gh 2.90.0, uv 0.11.7, AWS CLI 2.34.33, Supabase 2.90.0, git-delta 0.19.2, psql 16.13, Ubuntu 24.04.4 LTS) → `packages/devbox/VERSIONS.md § Bake log`. Two build-wrangling gotchas logged (`| tee` swallows exit codes; `cmd > log &` inside `run_in_background` Bash nests backgrounding). Mitigation: Monitor + terminal-state grep on log file.

- [x] iter-121 + iter-122 (summarised): Docker landed iter-121 via operator install; `INV-devbox-dind-available` codified as fork-time substrate requirement (`docs/invariants/devbox-dind.md` + manifest.ts + INVARIANTS.md anchor + AGENTS.md + RALPH.md + architecture.md I5a). iter-122 discovered backend B (host socket-passthrough, NOT isolated DinD); rewrote invariant doc with § Backend contract + § Safety rule; added `detect_backend()` + backend-B destructive-op refusal gate + `--allow-broad-prune` + `--skip-cold` to `benchmark.sh`; corrected manifest `contentHash`.

- [x] iter-99 (summarised; full detail preserved in git log + RALPH.md iter-99 signpost): Story 2.1 source tree authored (Dockerfile, docker-compose.yml, entrypoint.sh, scripts/benchmark.sh, VERSIONS.md, README.md), closing Tasks 1-3, 6, 8 + Task 7 static subtasks; sprint-status `ready-for-dev → in-progress`; Change Log v1.3 in story file; baseline commit `5278738`.

## Context

- **Phase:** 4-implementation — Epic 2 open, Story 2.1 advanced to `in-dev` (review-ready) at iter-125. Next lifecycle gate: `/bmad-testarch-trace (args: "yolo")` for AC → test coverage gate.
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available` § Backend contract). Iteration-context bind-mount denial against compose runtime is a documented operational constraint (RALPH.md iter-124 signpost); operator-workstation resolves either via M4-Pro native with worktree under host-shared `/Users/...` (backend-B File Sharing allowlist overlap) OR backend-A isolated DinD.
- **Baked image:** `keel-devbox:local` (first bake iter-123 2026-04-21). Version matrix in `packages/devbox/VERSIONS.md § Bake log`. linux/arm64 — matches M4-Pro operator workstation architecture.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; Story 2.1 is the image + compose + entrypoint foundation.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** 2.1 — `packages/devbox/` absorb from cc-devbox (image + compose + substrate tooling access).
- **Story File:** `_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md`
- **Story State:** in-dev — iter-125 closed Task 4.1 + Task 7 + Task 7.3 in-iteration; Tasks 4.2 + 4.3 + 5.2 carry updated operator-owned carve-out rationale; Status flipped `in-progress → review`. Advances `in-dev → traced` when `/bmad-testarch-trace` confirms AC → test coverage.
- **GitHub Issue:** Story 2.1 → #41 (https://github.com/tthew/ralph-bmad/issues/41). Parent Epic 2 → #10. Commit trailer `Refs #41`.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (no CI runners pre-Epic-13; Draft→Open transition queued at end of Epic 2).

## Notes

- **DinD is fork-time substrate, not transitional.** Every fork's cc-devbox-equivalent environment must provide Docker per `INV-devbox-dind-available`. Forks substituting Podman/rootless Docker remain conformant if daemon reachability + function hold.
- **Backend B is the reference environment at 2026-04-21.** Host socket-passthrough to macOS Docker Desktop. Broad-state-mutation scripts MUST detect the backend + refuse destructive ops by default (`benchmark.sh` is the reference at iter-122). Bind-mount-based compose runtime requires host-shared File Sharing allowlist coverage of the workspace path — operator-owned from iteration context.
- **NFR2 authority unchanged.** AC 4 cold ≤ 300s / warm ≤ 30s remains authoritative on M4-Pro native. Post iter-124, BOTH cold AND warm runtime measurement are operator-owned.
- **Cross-epic auto-advance pattern validated** (iter-96). **Partial-completion pattern validated** (iter-99). **Backend-B safety-gate pattern established** (iter-122). **Review-with-operator-owned-carve-out pattern validated** (iter-125; story flips `review` without force-closing operator-owned `[ ]` tasks because the carve-out is an AC scope clarification, not a task skip).
- **Story 2.1 scope bounded by AC1-AC4 literally.** Substrate's pre-existing `packages/devbox/` TS scaffold preserved; Story 2.1 ADDED runtime-infrastructure siblings + substrate-level DinD invariant files (`docs/invariants/devbox-dind.md` + manifest entry + anchors) emitted during execution.
