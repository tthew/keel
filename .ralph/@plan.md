# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — pre-dev validation (drafted → validated) ~small

## QUEUE (Epic 2 Story 2.1)

- [ ] Run `/bmad-testarch-atdd` — red-phase scaffolds for Story 2.1 (validated → atdd-scaffolded; may SKIP if infra-smoke per § ATDD skip rationale and record rationale in IP)
- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md")` — implement Story 2.1 (atdd-scaffolded → in-dev)
- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability (in-dev → traced or trace-fixes-pending)
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (traced → sm-verified)
- [ ] Run `/bmad-code-review (args: "2")` — CR with Create-action-items (sm-verified → done or fixes-pending)
- [ ] Monitor PR CI — queue fix tasks for any failures
- [ ] Transition PR Draft→Open — final CI gate (after all Epic 2 stories done)

## BLOCKED

_(none)_

## DONE (Epic 2 iter-96 cross-epic transition)

- [x] iter-96: **Epic 1 → Epic 2 cross-epic auto-advance.** PR #226 MERGED at 2026-04-21T09:41:48Z confirmed via `gh pr view 226 --json state,mergedAt` (state: MERGED). Per PROMPT_build.md § Cross-epic transition step 3: MERGED AND sprint-status has next epic (Epic 2) with backlog story `2-1-…` → NOW = `/bmad-create-story` (no halt, no re-entry loop). Branch `feat/epic-2-packaged-devbox` created off `main` (5a88889). `/bmad-create-story` ran: sprint-status.yaml flipped `epic-2: backlog → in-progress` + `2-1-…: backlog → ready-for-dev` + `last_updated: 2026-04-21 Story-2-1-ready-for-dev UTC`. Story file authored at `_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md` (full BDD ACs from epics.md:1171-1198; 8 tasks with scope carve-outs pinning 2.1's deliverables vs Stories 2.2-2.17 deferrals; Dev Notes cite arch.md:973-1002 file tree + PRD M0.5 deliverables + cc-devbox upstream provenance + NFR2/FR1/FR6 in-scope + NFR5-NFR10 explicitly deferred). Story State transitions `_(no story) → drafted` per § Story Lifecycle Decision Matrix. Next iter picks up `drafted → validated` via `/bmad-create-story (args: "review")`.

## Context

- **Phase:** 4-implementation — Epic 2 open, Story 2.1 drafted (first story of Epic 2).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; M0.5 five-deliverable sub-scope distributed across stories 2.1 (image + compose + entrypoint), 2.2 (.envrc contract), 2.3-2.4 (egress policy + whitelist), 2.5 (hardening), 2.6 (pnpm lifecycle CLI), 2.7 (Ralph auto-start), 2.8-2.9 (OAuth), 2.10 (prereq check), 2.11 (per-fork vs shared), 2.12 (port publication), 2.13 (healthcheck), 2.14 (legacy-devbox retention), 2.15-2.17 (Claude hook posture).
- **Epic Branch:** `feat/epic-2-packaged-devbox` (created off main at 5a88889 this iter).
- **Story:** 2.1 — `packages/devbox/` absorb from cc-devbox (image + compose + substrate tooling access).
- **Story File:** `_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md`
- **Story State:** drafted
- **GitHub Issue:** _(not yet queried — Epic 2 issue + Story 2.1 issue tracking env vars will surface on next iter if ralph.py GH project injection is wired for Epic 2; absence not a blocker per PROMPT_build.md § Issue Tracking)._
- **PR:** _n/a — draft PR to be created at push time this iter._

## Notes

- **Cross-epic auto-advance pattern validated (first invocation).** Epic 1 → Epic 2 transition executed from `/loop` build-mode entry per PROMPT_build.md § Cross-epic transition — no re-halt loop, no plan-mode roundtrip. Decision tree branch 3 (MERGED + next epic has backlog `(N+1).1`) fired cleanly.
- **Story 2.1 scope bounded by AC1-AC4 literally.** Scope carve-outs in the story file pin what 2.1 delivers (image + compose + entrypoint + NFR2 bench) vs what later Epic 2 stories own (hardening, egress, OAuth, CLI wrappers). Dev-story iteration must not accidentally over-deliver from adjacent stories — especially Story 2.5 non-root/caps/tmpfs and Story 2.3 dnsmasq/nftables.
- **Substrate pre-existing `packages/devbox/`** was scaffolded as a TypeScript workspace package by Story 1.1. Story 2.1 ADDS sibling runtime-infrastructure files (`Dockerfile`, `docker-compose.yml`, `entrypoint.sh`, `scripts/`, `VERSIONS.md`). Do NOT delete or rewrite the TS scaffolding — coexistence is the design.
- **ATDD posture for Story 2.1.** The ACs are infrastructure-smoke — may warrant an ATDD SKIP rationale in IP if `/bmad-testarch-atdd` determines shell-script asserts better serve the red-phase requirement than Vitest units. Record the decision in IP per PROMPT_build.md guardrail 4 SKIP clause.
