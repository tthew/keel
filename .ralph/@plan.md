# Implementation Plan

## NOW

- [ ] `/bmad-create-story` — FR14n row 1 `_(no story) → drafted`; picks Story 1.14 (`release-please monorepo config`) from sprint-status. Pre-stage seven preventative audit layers at drafting time per iter-53/54/56/59/60/67 compound discipline.

## QUEUE (Story 1.14 — release-please monorepo config)

_(empty — post-CR seed; fix tasks will be re-seeded only if future trace/SM/CR emit findings.)_

## BLOCKED

_(none)_

## DONE (current story/phase only)

- [x] iter-73: **FR14n row 9 `sm-verified → done` via `/bmad-code-review (args: "2")` FOURTH cumulative ZERO-PATCH CR precedent.** Three-layer adversarial review on commit `8f5d6f4` code surface (`.ralph/tmp/story-1-13-cr-diff.patch`; Ralph-bookkeeping files excluded): Blind Hunter ~30 findings diff-only; Edge Case Hunter ~80 findings diff + repo read; Acceptance Auditor 14 spec deviations (5/6 ACs MET, 6/7 Tasks MET). After iter-36+iter-52+iter-59+iter-65+iter-66 two-layer convergence-doctrine triage + iter-58+iter-65+iter-72 ZERO-PATCH doctrine: **0 PATCH / 0 DECISION-NEEDED / 13 DEFER / ~112 DISMISS**. DEFER count within iter-66 forecast (10-15 + iter-71 post-commit-SHA-drift = 11-16 at gate-authoring scale). 13 defers route to: Epic 3 reliability (post-commit SHA drift — iter-71 architectural finding); contrast-gate completeness follow-up story (pair-enumeration gaps — accent.fg × accent.*, accent.focus × surface.*, severity/state cross-surface, text.accent × inset/overlay; border.default dev-reclass; severity/state dark overlays as literals); spec amendments (INV-tokens-contrast-check description paraphrase; accent.500/600 retune over-scope; leafBreakpoint regex); advanced color-math hardening (parseOklch unitless-L + alpha drop; gamutMap 3-iter cap); SHA resolver empty-stderr/empty-stdout collapse; schema-gate robustness (Ajv strict-mode). All 13 defers recorded with `carry-to:` reasons per adversarial-triage-default. **Compound-ZERO-PATCH satisfied — all 5 conditions (a)-(e) held**: (a) seven preventative audit layers pre-applied iter-67; (b) 2-PATCH pre-dev SM iter-68; (c) single-pass dev iter-70 (recovery); (d) ZERO-PATCH trace iter-71 + inline SHA-drift fix; (e) ZERO-PATCH SM iter-72; iter-73 CR ZERO-PATCH. 7-iteration lifecycle held exactly (iter-67 → iter-73). Review Findings section authored under § Tasks / Subtasks with 13 `[x] [Review][Defer]` entries. Deferred-work.md new section authored with convergent-layer citations + location + nature + defer reason + carry-to per defer. Story State: `sm-verified → done`; Status: `review → done`; sprint-status: `1-13-...: review → done` + `last_updated: 2026-04-21 Story-1-13-done UTC`. Budget: ~40K tokens (orient ~3K + 3 parallel Sonnet subagent fan-outs ~30K + triage + writes ~7K).

- [x] iter-72: **FR14n row 7 `traced → sm-verified` via `/bmad-create-story (args: "review")`.** THIRD cumulative ZERO-PATCH post-dev SM precedent. Independent fresh-context Sonnet verifier audited all 6 ACs against committed implementation; all MET with no spec/implementation contradictions. iter-71 NEW FINDING (post-commit SHA drift) correctly deferred to iter-73 CR — architectural defer, not an unmet AC. Zero PATCHes applied — pure verdict-append (v1.5 Change Log row).

- [x] iter-71: **FR14n row 5 `in-dev → traced` via `/bmad-testarch-trace (args: "yolo")`.** SEVENTH CUMULATIVE WAIVED PRECEDENT. Substrate evidence STRONGEST of the seven — iter-70 Task 7 three negative smokes directly probe AC 1/2/3 fail-closed contracts at CLI-exit-code level. iter-71 NEW FINDING: post-commit SHA drift on emitter outputs; inline fix applied (re-emit + commit); queued for iter-73 CR DEFER.

- [x] iter-70: **FR14n row 4 `atdd-scaffolded → in-dev` via `/bmad-dev-story`.** Single-pass execution at 6-AC + 7-Task scale. Recovery pattern applied (prior session killed post-work-landed, pre-commit; verify-before-commit confirmed via full quality-gate suite). All 3 Task 7 negative smokes PASS.

- [x] iter-69: **FR14n row 3 `validated → atdd-scaffolded` via hybrid ground-(c) variant-(ii)+(iii) ATDD-skip.** Seventh cumulative Epic 1 ATDD-skip precedent.

- [x] iter-68: **FR14n row 2 `drafted → validated` via `/bmad-create-story (args: "review")` pre-dev SM.** TWO in-place PATCHes.

- [x] iter-67: **FR14n row 1 `_(no story) → drafted` via `/bmad-create-story`.** 6 ACs + 7 Tasks + seven preventative audit layers pre-applied.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.13 done; 1.14–1.16 backlog → 3 more stories × full FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** _(no story)_ — Story 1.13 done iter-73; Story 1.14 picks up at iter-74 via `/bmad-create-story`.
- **Story File:** n/a — resolved at next `/bmad-create-story` invocation.
- **Story State:** _(no story)_ — FR14n matrix row 1 pending at iter-74.
- **GitHub Issue:** Story 1.14 issue TBD (ralph.py resolves on subsequent iter start). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.14–1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.13 forecast held 7-iteration floor EXACTLY** (iter-67 → iter-73). Third consecutive 7-iter-floor story after Story 1.11 (iter-53..59) + Story 1.12 (iter-60..66); pattern calibrated for substrate-layer stories at 6-AC scale.
- **Carry-forward rules INTO Story 1.14 iter-74 `/bmad-create-story`:**
  - **Compound-ZERO-PATCH lifecycle CONFIRMED ACHIEVABLE** (iter-67..73 is the existence proof) — Story 1.14 drafting should pre-stage all seven preventative audit layers at drafting time (iter-53/54/56/59/60/67 compound discipline) + target ≤2 PATCH at pre-dev SM + single-pass dev + ZERO-PATCH trace/SM/CR.
  - **CR DEFER scale evidence** (4 cumulative ZERO-PATCH CRs): populator ≈5 DEFER (Story 1.10 iter-52 RE-RUN), contract-populator ≈5 DEFER (Story 1.11 iter-59), emitter+tooling ≈10 DEFER (Story 1.12 iter-66), gate-authoring ≈13 DEFER (Story 1.13 iter-73). DEFER count scales with surface complexity — Story 1.14 (release-please monorepo config) is configuration-surface + toolchain-wiring; forecast ≈5-8 DEFER.
  - **Seven preventative audit layers**: (L1) stable-IDs for new enforced invariants; (L2) task-enumeration-vs-consumer-requirement diff; (L3) sprint-status transition wording; (L4) internal-consistency drift (cross-AC coherence); (L5) cross-file line-number staleness; (L6) schema-permission diff; (L7) domain-specific carve-out (release-please for Story 1.14 — monorepo config `packages:`/`release-as:` shape + Changelog type format + pnpm workspace integration).
  - **Multi-layer-corroborated authoring-choice findings are DEFER, not PATCH** (iter-59/66/73 at 5→10→13 DEFER ceiling).
  - **Single-layer BH/EH findings default DISMISS unless corroborated** (iter-36/52/59/66/73 at ~100-dismisses-per-gate-story ceiling).
  - **Single-layer Acceptance-Auditor findings are SPEC-AUTHORITATIVE** (iter-73 doctrine confirmation): AA findings treated as DEFER (spec-amendment) when they flag authoring-choice divergences (border.default dev-reclass, accent.500/600 over-scope, description paraphrase); DISMISS only if the AA finding is spec-inherited error (text.tertiary/text.disabled/surface.invert non-existent tokens).
  - **Ground-(c) hybrid variant-(ii)+(iii)** unlocks ATDD-skip + trace-WAIVED for substrate+tooling + gate-authoring stories (SEVENTH precedent held through CR).
  - **`/bmad-code-review (args: "2")` arg `2` = "Leave as action items"** (vacuous in ZERO-PATCH case but required to force non-interactive branch).
  - **Killed-iteration-recovery verify-before-commit** (iter-70 lesson) — carry through to iter-74+.
  - **Post-commit SHA drift on emitter outputs** (iter-71 lesson, iter-73 DEFER) — any story that edits `packages/ui/tokens.json` MUST re-emit outputs AFTER the initial commit lands + commit again, OR the sync-gate will fail on next `--check`. Architectural fix deferred to Epic 3 reliability (or new Story 1.17-TBD) — content-hash provenance option preferred.
- **Story 1.14 drafting pointers** (not yet read — for iter-74 drafting):
  - Epic 1 Story 1.14 is `release-please monorepo config — single bundled mode` (sprint-status key `1-14-release-please-monorepo-config-single-bundled-mode`).
  - Cross-references likely needed: `_bmad-output/planning-artifacts/epics.md` Story 1.14 line range; PRD FR entries for release-please + monorepo release discipline; architecture.md § release pyramid / CI pipeline.
  - Expected new invariants: release-please manifest config (1 or 2 IDs); .github/workflows/release-please.yml (optional — Epic 13 scope); root package.json `version-scripts` (if needed).
- **Story 1.14 NOT absorbing** (route elsewhere): none identified yet; pre-stage at drafting time per iter-67 L7 discipline.
- **Issue Tracking carry-forward.** Parent Epic 1 at **#9** OPEN (never `Closes`; Ralph transitions at EPIC_DONE halt after Stories 1.14/1.15/1.16 all complete FR14n lifecycle). Story 1.14 issue TBD. iter-73 commit trailer uses `Refs #9` (parent-epic fallback unless `RALPH_ISSUE_NUMBER` is set).
