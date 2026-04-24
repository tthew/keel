# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story` — Story 2.12 (`_(no story) → drafted`). Auto-advances per § Story Lifecycle Decision Matrix row `done → Next story in the current epic` after Story 2.11 closed at iter-264. Story 2.12 is Epic 2's loopback-bound port publication (`KEEL_DEVBOX_SSH`/`sshd` opt-in per sprint-status row `2-12-loopback-bound-port-publication-opt-in-keel-devbox-ssh-sshd`). Single-skill-per-iter discipline: next iter runs `/bmad-create-story` ONLY — do NOT bundle pre-dev review, ATDD, or dev-story. IP Context will flip `Story 2.11 → 2.12` + `Story State: _(no story) → drafted` + `Story File: n/a → <2.12 slug>.md` when the skill lands.

## QUEUE (Story 2.12 lifecycle → Stories 2.13..2.17 → Epic 2 close-out)

- [ ] _(after Story 2.12 `drafted`)_ Iterate Story 2.12 through full lifecycle (drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done). Epic 2 within-epic auto-advance continues without halt as long as sprint-status has backlog rows.
- [ ] _(Stories 2.13..2.17)_ Iterate through full lifecycle — 5 remaining substrate stories spanning healthcheck replacement + legacy branch retention + committed settings + hooks + bypass-resistance. Each runs full lifecycle; no cross-epic transitions until Epic 2 final story (2.17) completes.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured at 2026-04-24 per iter-219..263 repeated pre-push confirmation — `gh pr view 230` returns `statusCheckRollup: []`).

## BLOCKED

_(none — iter-264 CR closure write + push clean.)_

## ATDD Red Phase

_(none — Story 2.11 ATDD-skipped at iter-256 per grounds (c)+(ii)+(iii); all subsequent gates passed. Story 2.12 forecast: ATDD-applicable likely — loopback-bound port publication has testable smokes via `docker compose config` port-range assertions + opt-in env-flag enforcement.)_

## DONE (iter-264 Story 2.11 CR closure — `fixes-pending → done`)

- [x] iter-264: **STORY 2.11 CR RE-RUN CONFIRMATION GATE — `fixes-pending → done`.** Three-layer Ralph-hosted adversarial fan-out on iter-261 PATCH-1 surface (commit `d8ee3a2`; 5 substantive files, 184 diff lines; iter-262/263 commits excluded as Ralph IP/RALPH.md bookkeeping per Guardrail 8). Winston Blind (`bmad-agent-architect`, diff-only — 3 findings: #1 medium manifest `description` field single-env-var drift; #2 low grep-audit obligation; #3 nit cosmetic `shared_parent_name` single-use). Murat Edge (`bmad-tea`, diff+project-read — 0 findings, explicit `[]` + sha256 `0647445551…` verified + four converging doc sites enumerated: AGENTS.md:168, devbox-mode.md § Shared mode contract, devbox-mode.md § Invariant stability, resolver.sh docstring + inline comment). Amelia Auditor (`bmad-agent-dev`, diff+spec+context — 1 finding DEFER-recommended: manifest description drift at `invariants.manifest.ts:275`). **Triage: 0 PATCH + 1 DEFER (D17/AR-91: manifest description non-executable drift; sync-gate hashes `sourcePath` doc content not `description` string — architecturally cannot catch; SC-17 Epic 2 close-out class) + 2 DISMISS (Winston #2 resolved by Murat project-read enumeration; Winston #3 Winston self-dismiss "leave as-is").** Convergent Winston#1 + Amelia#1 on description-drift classified DEFER (not PATCH) per NEW severity-class-first rule: second-class agent-readable drift follows severity class → DEFER even when 2-of-3 convergent (iter-264 NOVEL LESSON refines iter-260 convergence rule). Story file Status flipped `review → done` + Change Log v1.6 appended + Review Findings D17 + deferred-work.md AR-91 entry + sprint-status row flipped `2-11-…: review → done` + new `last_updated` comment. NO code/doc changes — closure-only iter. Budget consumed ~55-70K (orient ~25K + three-layer fan-out ~37K + triage + closure writes). Per § Story Lifecycle Decision Matrix row `done → Next story in current epic`: NOW = `/bmad-create-story` for Story 2.12 next iter. NO cross-epic transition (intra-Epic-2 advance).
- [x] iter-263: BLOCKED cleared — SSH :22 recovered. Three commits (`d8ee3a2`/`a52f231`/`e835913`) pushed in one `git push`. (Condensed per Guardrail 2; see RALPH.md § Signposts iter-263 for detail.)
- [x] iter-261: STORY 2.11 PATCH-1 LANDING — SC-4 opinionated-shared-mode posture extended from `KEEL_DEVBOX_CONTAINER_NAME` to also cover `KEEL_DEVBOX_REPO_NAME`. Resolver one-liner + docstring + three-site doc lockstep (AGENTS.md + `docs/invariants/devbox-mode.md` × 2) + manifest contentHash rebuild (`4ddc4eea… → 0647445551…`) + sync-gate clean. Closes convergent iter-260 Winston#5 Blind + Edge E6 finding on silent-override class.

_(iter-253..262 Story 2.10 closure + Story 2.11 create-story / pre-dev SM / ATDD-skip / dev-story / trace / post-dev SM / CR / PATCH-1 / BLOCKED iters pruned per Guardrail 2 — see Story 2.11 § Change Log v1.0..v1.6 + RALPH.md § Signposts iter-253..264 for per-gate detail.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **11/17 stories done** (2.1-2.11) + 6/17 backlog (2.12..2.17).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live fresh-fork first-run smokes operator-workstation-deferred; substrate smokes covered through iter-264 (iter-263 push recovery, iter-264 three-layer adversarial CR closure ZERO-PATCH confirmation).
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:119). Host-side shim count: **18** at iter-264 (unchanged — Story 2.12 may add 0-1 shim for SSH opt-in).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **11 done** (2.1-2.11); 6 backlog (2.12..2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** _(no story — Story 2.11 closed at iter-264; next iter runs `/bmad-create-story` for Story 2.12)_
- **Story File:** n/a (Story 2.12 file created by next iter's `/bmad-create-story`)
- **Story State:** `_(no story)` — Story 2.11 done at iter-264. Next iter transitions `_(no story) → drafted` via `/bmad-create-story` per § Story Lifecycle Decision Matrix.
- **GitHub Issue:** Story 2.12 issue unknown until `/bmad-create-story` runs next iter; `RALPH_ISSUE_NUMBER` typically unset for this project (last confirmed unset at iter-263 orient). Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` per iter-219..263 confirmation); push is unblocked at any Story State.

## Notes

- **iter-264 NOVEL LESSON — CR re-run DEFER-vs-PATCH severity-class-first rule.** When a prior PATCH iter updates a hashed source-file AND its manifest contentHash but leaves the manifest `description` string untouched, the description field drifts from the authoritative doc in a way the sync-gate cannot detect (sync-gate hashes `sourcePath` doc content, not `description`). Convergent 2-of-3 flagging on this drift class is legitimate signal BUT the iter-260 LESSON's "2-of-3 = PATCH" rule was distilled from FIRST-class correctness findings (AC-breaking level); second-class agent-readable drift follows severity class → DEFER even when convergent. **Rule:** classify by severity class FIRST, convergence-count SECOND. Manifest `description` string is architecturally out-of-sync-gate-hash-surface by Story 1.9 design; drifts there belong in SC-17 close-out reconciliation pass. Promote to RALPH.md § Lessons this iter.
- **iter-263 LESSON carry-forward** — SSH :22 / HTTPS :443 asymmetric recovery; push via SSH is primary progress vector even when HTTPS :443 `gh pr view` times out. Future BLOCKED recovery always attempts push first regardless of HTTPS state.
- **iter-261 LESSON carry-forward** — PATCH-surface-well-scoped-compact-iter pattern (~15-20K tokens) when single-source-of-truth + one-liner code + three-site doc lockstep.
- **iter-260 LESSONS carry-forward (REFINED by iter-264):** (1) three-layer adversarial fan-out convergence signal — 2-of-3 overlap is **high-confidence triage signal**, NOT automatic PATCH; severity class + finding nature determine final disposition per iter-264 NOVEL LESSON; (2) Blind Hunter false-positive class #1 (unset-array-access under `set -u` without REQUIRED_VARS fence verification); (3) iter-259 two-subagent post-dev SM pattern distinct from CR three-layer adversarial lens.
- **iter-259 LESSONS carry-forward unchanged:** post-dev SM two-subagent pattern; D2 architecture.md:547 7-site cascade pattern; partial-waive trace-gate vocabulary absence; manifest rebuild required after new InvariantSchema entry OR contentHash update.
- **iter-244/246 audit-findings carry-forward** unchanged: restart.sh transitive-delegate; benchmark.sh OUT-OF-SCOPE (SC-11); Manifest entry count **31** post-Story-2.11; Alpine egress non-applicability doctrine.
- **Substrate-citation drift cumulative forecast for Stories 2.12..2.17:** iter-260 baseline (2 MINOR + 5 SC-17 deferrals for Story 2.11) + iter-264 new AR-91 (manifest description single-env-var drift D17). Cumulative Epic 2 forecast: ~24-35 cumulative drifts + 2-3 citation-claim misplacements. SC-17 scope holds: single reconciliation pass at Story 2.17 landing. Deferred-work.md now at ~580 lines (iter-264 added AR-91 + re-run subsection).
