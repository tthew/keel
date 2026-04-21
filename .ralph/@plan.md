# Implementation Plan

## NOW

- [ ] `/bmad-code-review (args: "2")` — FR14n row 9 `sm-verified → done`; THIRD cumulative CR fan-out for gate-authoring substrate (Story 1.11 iter-59 → 1.12 iter-66 → 1.13 iter-73). Forecast 11-16 DEFER (iter-66 forecast 10-15 + iter-71 post-commit-SHA-drift +1).

## QUEUE (Story 1.13 — design-token quality gates)

_(empty — CR fix tasks seeded only after Blind Hunter/Edge Case Hunter/Acceptance Auditor fan-out lands findings.)_

## BLOCKED

_(none)_

## DONE (current story/phase only)

- [x] iter-72: **FR14n row 7 `traced → sm-verified` via `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification.** THIRD cumulative ZERO-PATCH post-dev SM precedent (Stories 1.11 iter-58 + 1.12 iter-65 + 1.13 iter-72) for contract-only / contract-populator / data-only / emitter+tooling / gate-authoring substrate stories. Independent fresh-context Sonnet verifier audited all 6 ACs against committed implementation; all MET with no spec/implementation contradictions. AC-1 schema-validate gate (Ajv-2020 CLI + prod deps + structured JSON findings + bin wiring). AC-2 WCAG AA contrast gate (50 static pairs × light+dark + Ottosson 2020 matrix + 3-iter gamut-map + authored tokens.json retunes + dark-mode overlay additions). AC-3 sync gate `--check` mode (buffer re-emit + byte-compare + SHA-resolver hoist + tagged failure-mode fallback + diamond-DAG cycle guard). AC-4 manifest 14→17 (three new entries + sync-gate shared sourcePath + identical contentHash + INVARIANTS.md section with 3 column-0 anchors). AC-5 prek + package.json wiring (2 new hooks + 4 new root scripts + umbrella + 2 bin entries). AC-6 defers absorbed (Story 1.12 spec v1.5 + tokens.schema.json `leafBreakpoint` def). **Live check-all re-verified exit 0**; all 7 Tasks `[x]`; iter-70 + iter-71 commits landed. **iter-71 NEW FINDING (post-commit SHA drift on emitter outputs) correctly deferred to iter-73 CR** — architectural defer, not an unmet AC, does NOT block sm-verification. Zero PATCHes applied — pure verdict-append (single v1.5 Change Log row on Story 1.13 spec). **Compound-ZERO-PATCH condition (e) pre-staged** — preventative audit discipline held through full 7-layer lifecycle (drafting L1-L7 → 2-PATCH pre-dev SM → ATDD-skip → first-pass dev → ZERO-PATCH trace → ZERO-PATCH SM). Story State: `traced → sm-verified`. Budget: ~6K tokens (orient + 1 Sonnet subagent fresh-context AC audit + v1.5 Change Log row + IP/RALPH updates).

- [x] iter-71: **FR14n row 5 `in-dev → traced` via `/bmad-testarch-trace (args: "yolo")`.** SEVENTH CUMULATIVE WAIVED PRECEDENT for contract-only / contract-populator / data-only / emitter+tooling / gate-authoring substrate stories. Four trace artifacts authored under `_bmad-output/test-artifacts/traceability/`. **Substrate evidence STRONGEST of the seven cumulative precedents** — iter-70 Task 7 three negative smokes directly probe AC 1/2/3 fail-closed contracts at CLI-exit-code level. **iter-71 NEW FINDING — post-commit SHA drift on emitter outputs** (emitter SHA-resolver sees pre-commit SHA at dev-time; post-commit `--check` sees new SHA → byte-mismatch). Inline fix applied (re-emit + commit). Queued for iter-73 CR DEFER.

- [x] iter-70: **FR14n row 4 `atdd-scaffolded → in-dev` via `/bmad-dev-story`.** Single-pass execution at 6-AC + 7-Task scale. Recovery pattern applied (prior session killed post-work-landed, pre-commit; verify-before-commit confirmed via full quality-gate suite re-run: `pnpm -w {typecheck,lint,build,format:check}` + `pnpm keel-invariants:check-all` + `pnpm exec prek run --all-files` all green). All 3 Task 7 negative smokes PASS.

- [x] iter-69: **FR14n row 3 `validated → atdd-scaffolded` via hybrid ground-(c) variant-(ii)+(iii) ATDD-skip clause.** Seventh cumulative Epic 1 ATDD-skip precedent.

- [x] iter-68: **FR14n row 2 `drafted → validated` via `/bmad-create-story (args: "review")` pre-dev SM.** TWO in-place PATCHes resolving AC 4 internal contradiction.

- [x] iter-67: **FR14n row 1 `_(no story) → drafted` via `/bmad-create-story`.** 6 ACs + 7 Tasks + seven preventative audit layers pre-applied at drafting time.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.12 done; 1.13 drafted iter-67 + SM-validated iter-68 + ATDD-skipped iter-69 + dev-story landed iter-70 + traced iter-71 + SM-verified iter-72; 1.14–1.16 backlog → 3 more stories × full FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** Story 1.13 — Token quality gates (schema validation + WCAG AA contrast + source-output sync)
- **Story File:** `_bmad-output/implementation-artifacts/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md`
- **Story State:** `sm-verified` — FR14n matrix rows 1 (iter-67) + 2 (iter-68) + 3 (iter-69 SKIP) + 4 (iter-70) + 5 (iter-71) + 7 (iter-72) complete; row 9 `/bmad-code-review` pending at iter-73 for `sm-verified → done`.
- **GitHub Issue:** Story 1.13 issue TBD (ralph.py resolves on subsequent iter start). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.13–1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.13 forecast: 7-iteration floor ON SCHEDULE at iter-72** — iter-67 drafted → iter-68 validated → iter-69 atdd-skip → iter-70 in-dev → iter-71 traced → iter-72 sm-verified → iter-73 done; matches Story 1.11 iter-53..iter-59 + Story 1.12 iter-60..iter-66 each at exactly 7 iters.
- **Carry-forward rules INTO Story 1.13 iter-73 CR — COMPOUNDING PRIOR ART:**
  - **Seven preventative audit layers** (iter-53/54/56/59/60/67) + Layer-4 iter-68 enhancement held through dev + trace + SM. All 7 layers already discharged ZERO-PATCH at SM; carry-forward discipline: re-verify at CR via Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out.
  - **Compound-ZERO-PATCH achievable under 5 conditions** (iter-66): (a) seven preventative audit layers — CONFIRMED iter-67; (b) pre-dev SM ≤2 PATCHes — CONFIRMED iter-68 2-PATCH; (c) single-pass dev — CONFIRMED iter-70 recovery; (d) clean trace — CONFIRMED iter-71 ZERO-PATCH; (e) clean SM — **CONFIRMED iter-72 ZERO-PATCH**; iter-73 CR defenses pre-staged.
  - **CR DEFER ceiling scales** (iter-66): populator ≈5 DEFER; emitter/gate ≈8-12 DEFER; Story 1.13 forecast 10-15 + 1 (iter-71 post-commit-SHA-drift) = **11-16 DEFER at gate-authoring scale**.
  - **Multi-layer-corroborated authoring-choice findings are DEFER, not PATCH** (iter-59 + iter-66 at 10-DEFER ceiling).
  - **Single-layer BH/EH findings default DISMISS unless corroborated** (iter-36/52/59/66 at 26 dismisses).
  - **Structural trace inheritance ~90% savings** CONFIRMED iter-71; CR-artefact inheritance analogous at iter-73.
  - **Drift-smoke revert patterns** (iter-45/56/63/70/71) — Task 7 three negative smokes carried through dev + trace.
  - **Ground-(c) hybrid variant-(ii)+(iii)** unlocks ATDD-skip + trace-WAIVED for substrate+tooling + gate-authoring stories (SEVENTH precedent).
  - **`/bmad-code-review (args: "2")` arg `2` = "Leave as action items"** (vacuous in ZERO-PATCH case but required to force non-interactive branch).
  - **Killed-iteration-recovery verify-before-commit** (iter-70 lesson) — carry through to iter-73.
  - **Post-commit SHA drift on emitter outputs** (iter-71 NEW lesson) — any story that edits `packages/ui/tokens.json` MUST re-emit outputs AFTER the initial commit lands + commit again, OR the sync-gate will fail on next `--check`. Architectural fix queued for iter-73 CR.
- **Story 1.13 DEFER pre-enumeration (for iter-73 CR fan-out, per iter-66 preventative-pre-staging pattern):**
  - **iter-71 finding — post-commit SHA drift** on emitter outputs. Architectural DEFER candidate: (a) content-hash provenance vs git-SHA (preferred — deterministic + uncommitted-safe); (b) document dual-commit pattern + post-commit CI hook; (c) accept + document.
  - Likely BH/EH surface: Ajv compile-cost profile; OKLCH→sRGB floating-point precision; pair-enumeration completeness vs tokens.json leaves; `gamutMap` 3-iter convergence edge; `--check` mode zero-write purity; `resolveSourceSha` failure-mode distinction robustness; alias-cycle diamond-DAG guard; `$modes.dark` overlay resolution in contrast walker; `color-math.ts` pure-function fixtures; manifest entry description paraphrase risk on Stories 1.4/1.5/1.10/1.11/1.12 cross-cutting entries.
- **Story 1.13 NOT absorbing (route elsewhere):** REPO_ROOT brittle → reliability/Epic 3; fontSize hardcoded 1.5 → Epic 7/3; shadow-machinery → Story 1.17-TBD or Epic 7.
- **Issue Tracking carry-forward.** Parent Epic 1 at **#9** OPEN (never `Closes`; Ralph transitions at EPIC_DONE halt). Story 1.13 issue TBD. iter-72 commit trailer uses `Refs #9` (parent-epic fallback unless `RALPH_ISSUE_NUMBER` is set).
