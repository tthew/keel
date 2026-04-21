# Implementation Plan

## NOW

- [ ] iter-87: `/bmad-code-review (args: "2")` — FR14n row 9 `sm-verified → done`. FIFTH cumulative ZERO-PATCH CR precedent CANDIDATE (Stories 1.11/1.12/1.13/1.14 → 1.15). Three-layer adversarial fan-out (Blind Hunter + Edge Case Hunter + Acceptance Auditor) on iter-84 dev-story commit `2137c83`. Triage per convergence-doctrine + ZERO-PATCH-doctrine + adversarial-triage default. Expected outcome: 0 PATCH / 0 DECISION-NEEDED / 5-8 DEFER / ~10-13 DISMISS (lower DEFER vs Story 1.14's 10, due to smaller 4-packageRules surface + no `.release-please-manifest.json` hash-cascade concerns + no "release-please WORKFLOW = Story 13.5" consumer-deferral ambiguity — Renovate App install is a cleaner ops carve-out). After CR: Story State `sm-verified → done`; BMad Status `review → done`; sprint-status `1-15-...: review → done` + `last_updated: 2026-04-21 Story-1-15-done UTC`. Next: iter-88 starts Story 1.16 (`_(no story) → drafted` for `1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold`). Epic 1 NOT yet complete; PR #226 stays Draft through Story 1.16 completion.

## QUEUE (Story 1.15 — renovate config i7)

_(empty — iter-87 CR is the only remaining Story 1.15 step; iter-88+ opens Story 1.16 drafting)_

## BLOCKED

_(none)_

## DONE (current epic — trailing iterations only)

- [x] iter-86: **FR14n row 7 `traced → sm-verified` via `/bmad-create-story (args: "review")` post-dev SM ZERO-PATCH — FIFTH cumulative precedent** (Stories 1.11 iter-58 + 1.12 iter-65 + 1.13 iter-72 + 1.14 iter-79 → 1.15 iter-86). Independent fresh-context Sonnet Explore subagent audited all 4 ACs against committed iter-84 implementation + live filesystem state. All 4 ACs SATISFIED verbatim: AC 1 (renovate.json shape + 4 packageRules + I7 pin-mode + grouped updates) — valid JSON extending `config:recommended`, canonical `$schema`, 4 packageRules with groupNames sorted `["opentelemetry","pg-uuidv7","radix-ui","vitest"]` each `rangeStrategy: pin` + `automerge: false`; AC 2 substrate half — top-level `automerge: false` + per-rule × 4 encodes policy (runtime half scope-carved); AC 3 first half — `groupName: "opentelemetry"` + `matchPackagePatterns: ["^@opentelemetry/"]` (pnpm.overrides atomicity scope-carved); AC 4 — manifest 22 entries with both new IDs + INVARIANTS.md H3 section positioned correctly with both anchor bullets. All 6 Task 6 smokes re-verified LIVE byte-identical at SM re-check; sync-gate wall 629ms (68.6% margin vs Story 1.9 AC 7 <2s budget; within iter-84/iter-85's 644ms/638ms band — consistent sub-650ms substrate signal). Zero unmet-AC findings; zero PATCHes applied. Change Log v1.5 row appended. Story State `traced → sm-verified`; no BMad Status change (`review` retained until CR at iter-87); sprint-status `last_updated: 2026-04-21 Story-1-15-sm-verified UTC`.
- [x] iter-85: **FR14n row 5 `in-dev → traced` via `/bmad-testarch-trace (args: "yolo")` NINTH cumulative WAIVED precedent** (Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57 + 1.12 iter-64 + 1.13 iter-71 + 1.14 iter-78 → 1.15 iter-85). Four trace artefacts authored at `_bmad-output/test-artifacts/traceability/1-15-*`. All 6 Task 6 smokes re-verified LIVE byte-identical to iter-84 dev-story record; `pnpm keel-invariants:check` exit 0 in 638ms. AC 1 + AC 4 substrate-verified; AC 2 + AC 3 scope-carved to Renovate GitHub App runtime + Epic 13 CI gate. Change Log v1.4 row appended.
- [x] iter-84: **FR14n row 4 `atdd-scaffolded → in-dev` via `/bmad-dev-story` SINGLE-PASS at configuration-surface scale** (Story 1.14 iter-77 precedent held). 4 files landed: 2 NEW (`.github/renovate.json` + `docs/invariants/renovate.md`) + 2 MODIFIED (`packages/keel-invariants/src/invariants.manifest.ts` +2 entries → 22 total; `INVARIANTS.md` +1 H3 + 2 anchor bullets). All 6 Task 6 smokes GREEN; full quality-gate suite PASS. Task 5 no-op held: zero cascade hash updates.
- [x] iter-83: **FR14n row 3 `validated → atdd-scaffolded` via `/bmad-testarch-atdd` hybrid ground-(c) variant-(ii)+(iii) ATDD-SKIP — NINTH cumulative precedent**. Skill preflight HALTs at Step 1.2 (no test runner). Change Log v1.2 row.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1-1.14 done; Story 1.15 traced iter-85; Story 1.16 backlog — SM/CR remaining on Story 1.15 + 1 full × Story 1.16 before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** Story 1.15 — Renovate config with version-pinning rules (I7).
- **Story File:** `_bmad-output/implementation-artifacts/1-15-renovate-config-with-version-pinning-rules-i7.md`.
- **Story State:** `sm-verified` — FR14n matrix row 7 complete at iter-86 (`/bmad-create-story (args: "review")` post-dev SM FIFTH cumulative ZERO-PATCH precedent; fresh-context Sonnet Explore subagent audit confirmed all 4 ACs SATISFIED; 6 smokes re-verified LIVE byte-identical; sync-gate 629ms); row 9 (`sm-verified → done` via `/bmad-code-review (args: "2")`) next at iter-87.
- **GitHub Issue:** Story 1.15 at **#39** (https://github.com/tthew/ralph-bmad/issues/39). Parent Epic 1 at **#9** OPEN (closes at EPIC_DONE halt). Story 1.14 at #38 expected CLOSED on PR merge (ralph.py wiring; PR merge waits for EPIC_DONE).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.15 + 1.16 complete FR14n lifecycle).

## Notes

- **Story 1.15 iter-86 post-dev SM closed ZERO-PATCH.** FIFTH cumulative precedent (1.11/1.12/1.13/1.14 → 1.15). All 4 ACs SATISFIED; sync-gate 629ms (iter-84 644ms, iter-85 638ms — consistent sub-650ms band).
- **Carry-forward rules INTO iter-87 `/bmad-code-review (args: "2")` FIFTH cumulative ZERO-PATCH CR precedent candidate:**
  - Three-layer adversarial fan-out: Blind Hunter (diff-only) + Edge Case Hunter (diff + repo-read) + Acceptance Auditor (AC-verification) on iter-84 commit `2137c83`. Fresh-context Sonnet subagents in parallel.
  - Triage per convergence-doctrine: only findings that survive ≥2 of 3 layers ascend to PATCH consideration. Default adversarial triage: PATCH only when finding is a shipping-blocker (security / correctness / contract violation); everything else DEFER or DISMISS.
  - **ZERO-PATCH-doctrine (iter-59/66/73/80 precedent):** 4 prior CRs landed zero PATCH, zero DECISION-NEEDED, ≥5 DEFER, majority DISMISS. Story 1.15 config-surface forecast: 0 PATCH / 0 DECISION-NEEDED / 5-8 DEFER / 10-13 DISMISS. Lower DEFER vs Story 1.14's 10 due to: (a) smaller 4-packageRules surface; (b) no manifest-file hash-cascade concerns; (c) no "release-please WORKFLOW = Story 13.5" consumer-deferral ambiguity — Renovate App install is a cleaner single-clause ops carve-out.
  - CR selects "Create action items" (`args: "2"`) — any findings become iter-88+ QUEUE fix tasks. ZERO findings → Story State `sm-verified → done` in same iteration → iter-88 opens Story 1.16 drafting.
  - After CR closes: BMad Status `review → done`; sprint-status `1-15-...: review → done` + `last_updated: 2026-04-21 Story-1-15-done UTC`.
  - Budget ~18-22K tokens (orient ~2K + 3 parallel Sonnet subagents ~12-15K + triage ~1K + Change Log v1.6 + IP/RALPH/sprint-status ~3K — matches iter-80 ~22K precedent).
- **Issue Tracking carry-forward.** Story 1.15 at **#39** — current iteration commit trailer uses `Refs #39`. Parent Epic 1 at **#9** OPEN.
