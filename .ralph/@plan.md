# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — pre-dev SM validation of Story 2.2 readiness against the create-story checklist (`_bmad-output/implementation-artifacts/2-2-envrc-parameterisation-contract.md` produced at iter-145). State transition `drafted → validated`. Per § Story Lifecycle Decision Matrix row `drafted`. One-workflow-per-iteration guardrail: this is the full iteration task. ~medium

## QUEUE (Story 2.2 `drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done`)

- [ ] Run `/bmad-testarch-atdd` — red-phase scaffolds for Story 2.2 OR record FR14n ATDD-skip rationale (mixed: lint-rule TS can Vitest, dotfile schemas + compose + gitignore are infrastructure-smoke; decide per atdd-skill output). State transition `validated → atdd-scaffolded`.
- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-2-envrc-parameterisation-contract.md")` — implement Story 2.2. State transition `atdd-scaffolded → in-dev`.
- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability matrix for Story 2.2. State transition `in-dev → traced`.
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM requirements-satisfaction verification. State transition `traced → sm-verified`.
- [ ] Run `/bmad-code-review (args: "2")` — post-SM CR adversarial action-items gate. State transition `sm-verified → done` OR `sm-verified → fixes-pending` (multi-cycle envelope bounded by Story 2.1's iter-128 → iter-138 → iter-144 three-cycle precedent).
- [ ] _(conditional, post-Story-2.17 done)_ Transition PR #230 Draft→Open — final CI gate after all Epic 2 stories done; monitor CI; merge.
- [ ] _(conditional, post-Epic-2 merged)_ § Cross-epic transition → Epic 3 Story 3.1 via `/bmad-create-story` OR halt EPIC_DONE awaiting merge.

## BLOCKED

_(none — Story 2.2 produced as `ready-for-dev`; no prerequisites beyond the next-iteration's `/bmad-create-story (args: "review")` validation.)_

## DONE (Story 2.2 — iter-145 `/bmad-create-story` produces story file)

- [x] iter-145: **`/bmad-create-story` produced `_bmad-output/implementation-artifacts/2-2-envrc-parameterisation-contract.md` (Story State: `_(no story) → drafted`; sprint-status `2-2: backlog → ready-for-dev`).** Exhaustive context-engine pass per skill contract: Epic 2 context loaded from `epics.md:1142-1231`; Architecture I3/I5/I5a/I6 sections loaded from `architecture.md:269-342`; repo-root `.gitignore` (L35-39) + `.pre-commit-config.yaml` + `packages/keel-invariants/` (manifest shape, eslint-rules precedent, sync-gate flow) + `packages/devbox/docker-compose.yml` (post-iter-144 state) + Story 2.1 patterns (iter-128..iter-144 CR chain) all extracted into Dev Notes. Story file structure: AC1-AC5 verbatim from epics + enriched with 14 scope clarifications covering (tmpfs-naming drift MB vs GB, authoritative M4-Pro reference defaults table, file-header block contract, inline-comment format, compose parameterisation mapping table with deploy-stanza anti-pattern callout + non-swarm cpus/mem_limit/shm_size canonical form + loopback-bound ports for Story 2.12 reduced-rework, tmpfs/SSH/shared DEFERRED to Stories 2.5/2.11/2.12, `.secrets.example` 6-key scaffold matching architecture.md:328 verbatim, `.gitignore` bang-suffix negation pattern, keel-invariants lint rule mechanism-ii prek hook design vs ESLint rule mechanism-i, `INV-gitignored-secret-commit-deny` manifest entry + `docs/invariants/` shape matching AI-7 iter-135 precedent, sourcePath doc-vs-impl decision deferred to dev-time). 8 Tasks (Task 1 `.envrc.example`, Task 2 compose parameterisation, Task 3 `.secrets.example`, Task 4 lint rule end-to-end, Task 5 `.gitignore` extension, Task 6 README § Retuning, Task 7 structural verification sweep, Task 8 sprint-status hygiene) with AC references + grep-friendly verification literals. Testing standards: Vitest unit test for lint rule natural; compose/gitignore are infrastructure-smoke; ATDD decision deferred to `/bmad-testarch-atdd` invocation per FR14n. Open questions enumerated for implementation-time resolution (tmpfs naming drift, `.secrets.example` location drift, manifest sourcePath doc-vs-impl). Sprint-status: `2-2: backlog → ready-for-dev`, `last_updated: 2026-04-21 Story-2-2-ready-for-dev UTC`. **Next iteration:** `/bmad-create-story (args: "review")` pre-dev SM validation per § Story Lifecycle Decision Matrix row `drafted`.

- [x] iter-144: Story 2.1 third CR gate ZERO-PATCH verdict (`fixes-pending → done`; sprint-status `2-1: in-progress → done`). Full detail in `9dbe6e3` commit message + story-2.1 file § Review Findings `#### iter-144 RE-RUN-2`. Twenty-eighth cumulative Epic post-SM CR / CR-re-run iteration; multi-cycle upper envelope bounded to three cycles matching Story 1.9 precedent.

## Context

- **Phase:** 4-implementation — Epic 2 open at 1/17 stories done (2.1 done at iter-144); Story 2.2 `ready-for-dev` as of iter-145.
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available` § Backend contract). Iteration-context bind-mount denial persists; operator-workstation resolves via native Docker Desktop under host-shared `/Users/...` OR backend-A isolated DinD harness.
- **Baked image:** `keel-devbox:local` (iter-123 first bake; 848 MB, linux/arm64). Version matrix in `packages/devbox/VERSIONS.md § Bake log`.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; Story 2.1 done; Story 2.2 ready-for-dev; Stories 2.3..2.17 remain in `backlog`.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2; PR #230 transitions to Open at epic completion).
- **Story:** 2.2 — `.envrc` parameterisation contract.
- **Story File:** `_bmad-output/implementation-artifacts/2-2-envrc-parameterisation-contract.md`.
- **Story State:** `drafted` — Story 2.2 file produced at iter-145. Next iteration's `/bmad-create-story (args: "review")` transitions to `validated`.
- **GitHub Issue:** Story 2.2 issue TBD — ralph.py injects `RALPH_ISSUE_NUMBER` / `RALPH_ISSUE_URL` next iteration. Parent Epic 2 → #10 (unchanged). Commit trailer pattern `Refs #<story-issue>` once RALPH_ISSUE_NUMBER resolves; `Refs #10` meanwhile for Epic traceability.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (stays Draft across Epic 2; no CI runners pre-Epic-13; transitions to Open at Story 2.17 done).

## Notes

- **DinD is fork-time substrate, not transitional.** `INV-devbox-dind-available` — every fork's cc-devbox-equivalent must provide Docker. Podman/rootless-Docker conformant if daemon reachability holds (backend C extension per iter-144 defer).
- **Backend B is the reference environment at 2026-04-21.** Host socket-passthrough. Broad-state-mutation scripts MUST detect backend + refuse destructive ops by default (`benchmark.sh` reference from iter-122). Bind-mount compose runtime requires host-shared File Sharing allowlist coverage — operator-owned from iteration context.
- **NFR2 authority unchanged.** AC 4 cold ≤ 300s / warm ≤ 30s remains authoritative on M4-Pro native. Story 2.2 is infrastructure-parameterisation — no runtime-performance impact on NFR2; AC3 retunability verified via `docker compose config` static YAML expansion (no daemon required).
- **Story 2.2 parameterises knobs for Story 2.5 (tmpfs) + Story 2.11 (shared) + Story 2.12 (loopback ports / SSH).** Those downstream stories activate the tmpfs / shared / SSH knobs that Story 2.2 adds to `.envrc.example`. Story 2.2 MUST NOT partially implement those — defer per § Story 2.1 "NFRs explicitly DEFERRED" posture.
- **Cross-epic auto-advance pattern validated** (iter-96). **Partial-completion pattern validated** (iter-99). **Backend-B safety-gate pattern established** (iter-122). **Review-with-operator-owned-carve-out pattern validated** (iter-125). **SM-verified-with-operator-owned-carve-out pattern validated** (iter-127). **CR-fixes-pending-adversarial-default pattern validated** (iter-128). **CR-re-run-adversarial-default + action-item-bundling pattern validated** (iter-138). **Doc-drift two-row bundle closure pattern validated** (iter-141). **Story-artefact spec-vs-code drift closure pattern validated** (iter-142). **Operator-UX polish pattern validated** (iter-143). **ZERO-PATCH third-gate close pattern validated** (iter-144; three-cycle upper envelope for Epic-2 infrastructure-smoke stories). **Context-engine-exhaustive story-creation pattern validated** (iter-145; Story 2.2 file with 14 scope clarifications + AC-mapping tables + 8 concrete Tasks + grep-friendly verification literals at file-producer time; designed to minimise dev-agent decision surface + prevent disasters by framing mapping tables + naming drift + mechanism-ii prek design + deferral posture up front).
