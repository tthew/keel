# Implementation Plan

## NOW

- [ ] iter-88: `/bmad-create-story` — FR14n row 1 `_(no story) → drafted` for Story 1.16 (`1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold`). Story 1.16 is the FINAL open story in Epic 1 sprint-status (verified live: `1-15-...: done`, `1-16-...: backlog`, `epic-1-retrospective: optional`). Drafting discipline: pre-apply the seven-layer audit carry-forward (L1 stable-IDs; L2 Task↔AC bidirectional coverage; L3 sprint-status wording; L4 cross-file convergence; L5 mechanical-counter derivation per iter-76 lesson — Story 1.16 = TENTH cumulative Epic-1 ATDD-skip + WAIVED-trace candidate + SIXTH ZERO-PATCH-CR candidate; L6 schema-permission diff; L7 domain-specific carve-out for fork-extension-pattern scaffolding). Story 1.16 class: scaffolding story (`fork.md` scaffold + growth-tier invariant registration — canonical final-story-in-epic shape per Story 1.15 precedent). Target ≤2 PATCH pre-dev SM (matches Stories 1.11/1.12/1.13/1.14/1.15 1-2 PATCH precedent average). Single-pass dev expected at configuration-surface-tier scale. Post-Story-1.16 done: EPIC_DONE halt (Epic 1 complete); PR #226 transitions Draft → Open via `/bmad-dev-story`-free terminal iteration; final CI gate; merge.

## QUEUE (Story 1.16 — fork-extension scaffold)

_(empty at iter-88 start — drafting is the entry point)_

## BLOCKED

_(none)_

## DONE (current epic — trailing iterations only)

- [x] iter-87: **FR14n row 9 `sm-verified → done` via `/bmad-code-review (args: "2")` FIFTH cumulative ZERO-PATCH CR precedent** (Stories 1.11 iter-59 + 1.12 iter-66 + 1.13 iter-73 + 1.14 iter-80 → 1.15 iter-87). Three-layer adversarial fan-out in parallel fresh-context Sonnet subagents on commit `2137c83` code-surface (`.ralph/tmp/story-1-15-cr-diff.patch`; Ralph bookkeeping excluded): Blind Hunter 6 findings, Edge Case Hunter 10 findings, Acceptance Auditor all 4 ACs MET / SCOPE-CARVED + 2 pre-existing spec Dev Notes citation drifts (`architecture.md:305` maps to VITE env-vars not Implementation Invariants index; `architecture.md:649` maps to React error boundaries not Dev-time tooling enumeration; I7 verbatim text at `architecture.md:342` which rationale doc correctly cites). Triage per convergence-doctrine + ZERO-PATCH-doctrine + adversarial-triage default: **0 PATCH / 0 DECISION-NEEDED / 10 DEFER / 8 DISMISS**. DEFER count matches Story 1.14 iter-80 exactly at 10 (configuration-surface tier ceiling). 10 DEFERs routed: packageRule cleanup (2) — redundant Vitest `matchPackageNames` + `vitest-environment-*` hyphen-separator gap; Story 2.1 devbox empirical validation (2) — pg_uuidv7 Docker `matchPackageNames` vs `matchDepNames` + `config:best-practices` devDep automerge preset-merge-order; renovate.md amendments (2) — lockFileMaintenance-pin-retro clarification + fork-extension doc defect per Story 1.14 iter-80 defer #10 class-of-issue; spec amendment (1) — architecture.md:305/:649 Dev Notes citation drift per Story 1.14 iter-80 :597 precedent; Story 2.1 devbox landing (1) — add `ignorePaths`/`enabledManagers`; Epic 3 reliability (2) — declarative-policy-coverage exhaustiveness guard + contentHash prettier-version drift hardening per Story 1.13 iter-71 + Story 1.14 iter-80 defer #9 architectural-defer. Compound-ZERO-PATCH SATISFIED across full 7-iteration `drafted → done` lifecycle (iter-81 → iter-87) — matches Stories 1.11/1.12/1.13/1.14 7-iter floors. Story State: `sm-verified → done`; BMad Status: `review → done`; sprint-status: `1-15-...: review → done` + `last_updated: 2026-04-21 Story-1-15-done UTC`. Change Log v1.6 appended; deferred-work.md new section authored with 10 entries.
- [x] iter-86: FR14n row 7 `traced → sm-verified` via `/bmad-create-story (args: "review")` post-dev SM FIFTH cumulative ZERO-PATCH precedent. All 4 ACs SATISFIED; 6 smokes re-verified LIVE byte-identical; sync-gate 629ms (68.6% margin). Zero unmet-AC findings.
- [x] iter-85: FR14n row 5 `in-dev → traced` via `/bmad-testarch-trace (args: "yolo")` NINTH cumulative WAIVED precedent. 4 trace artefacts authored.
- [x] iter-84: FR14n row 4 `atdd-scaffolded → in-dev` via `/bmad-dev-story` SINGLE-PASS at configuration-surface scale. 4 files landed (2 NEW + 2 MODIFIED); 22 invariants total.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1-1.15 done; Story 1.16 final open story — full 7-iter FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** _(no story)_ — iter-88 opens Story 1.16 drafting.
- **Story File:** n/a (iter-88 creates `_bmad-output/implementation-artifacts/1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold.md`).
- **Story State:** `_(no story)` — iter-88 FR14n row 1 `_(no story) → drafted` via `/bmad-create-story`.
- **GitHub Issue:** Story 1.15 at **#39** closed on PR merge (ralph.py wiring; PR merge waits for EPIC_DONE). Story 1.16 issue TBD — `/bmad-create-story` creates it or ralph.py resolves it at iter-88 start. Parent Epic 1 at **#9** OPEN (closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through iter-88..iter-94 Story 1.16 lifecycle; Draft→Open at EPIC_DONE after Story 1.16 `done`).

## Notes

- **Story 1.15 iter-87 CR closed ZERO-PATCH — FIFTH cumulative precedent across 5 consecutive stories (1.11/1.12/1.13/1.14/1.15).** Full 7-iteration `drafted → done` lifecycle held (iter-81 → iter-87). Configuration-surface + epic-verbatim-ID discipline + pre-staged seven-layer audit discipline + ZERO-PATCH across trace/SM/CR held exactly.
- **Carry-forward rules INTO iter-88 `/bmad-create-story` for Story 1.16 (SIXTH ZERO-PATCH CR candidate):**
  - Story 1.16 class: scaffolding-story (`fork.md` scaffold + growth-tier invariant registration). Expected surface: 1 new markdown + 1-2 new manifest entries + 1-2 anchor bullets. Configuration-surface tier.
  - Mechanical counters per iter-76 lesson (compute from sprint-status, don't copy-paste): Story 1.7 iter-2 = 1st ATDD-skip; 1.8 = 2nd; 1.9 = 3rd; 1.10 = 4th; 1.11 = 5th; 1.12 = 6th; 1.13 = 7th; 1.14 = 8th; 1.15 = 9th → **Story 1.16 = 10th cumulative Epic-1 ATDD-skip candidate** (also 10th WAIVED-trace candidate + SIXTH ZERO-PATCH-CR candidate).
  - Target discipline: 7-iter floor (iter-88 → iter-94) matches all 5 precedents. Final story in Epic 1; iter-94 done → EPIC_DONE halt → PR #226 Draft→Open → final CI gate → merge.
  - Pre-flight budget: iter-88 `/bmad-create-story` drafting ~12-18K tokens (orient + epic-read + seven-layer audit pre-application + IP/RALPH/sprint-status bumps) — matches Story 1.14 iter-74 + Story 1.15 iter-81 precedents.
- **Issue Tracking carry-forward.** Story 1.15 at **#39** — on iter-88 start the story issue transitions automatically via ralph.py based on IP `**Story:**` field (currently `_(no story)`). Story 1.16 issue will be created/resolved at iter-88. Parent Epic 1 at **#9** OPEN.
