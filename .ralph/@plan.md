# Implementation Plan

## NOW

- [ ] **Re-run `/bmad-code-review (args: "2")`** for Story 1.10 — `fixes-pending → done` per FR14n matrix row 10 (QUEUE empty post iter-51 Fix CR-1; convergent CR trajectory expects clean pass, zero action items; completes CR layer for Story 1.10). ~medium

## QUEUE (Story 1.10 — design-token schema, semantic + rationale contract)

_(empty — iter-52 CR re-verify is the sole FR14n row 10 exit condition. On clean pass: Story State `fixes-pending → done`; Story 1.10 lifecycle closes after 11 iterations (iter-42..52). Next: Story 1.11 per sprint-status.)_

## BLOCKED

_(none)_

## DONE (Story 1.10 — iter-51 Fix CR-1)

- [x] iter-51: **Fix CR-1 [MEDIUM] landed; FR14n state stays `fixes-pending` pending iter-52 CR re-verify.** Single-line schema edit to `packages/ui/tokens.schema.json` — added `"required": ["light", "dark"]` after `"additionalProperties": false` at line 328 (inside `modesOverlay` `$def`); enforces spec Task 1 line 66's explicit "Story 1.10 declares the two required modes (`light`, `dark`)" prescription that iter-50 Blind+Edge convergent CR-1 finding surfaced. Recomputed `sha256sum packages/ui/tokens.schema.json`: `abb5bc4c779d7cb8029a1c55bf6d3cb86092aa7105f2eb31c247da53093e07ac → 15380636645d6eb1610845c7f295629b1f3a0ba3fec9f6c04262ece581b055e6`; updated `INV-tokens-schema-contract.contentHash` at `packages/keel-invariants/src/invariants.manifest.ts:133`. Re-ran `pnpm -w typecheck` ✓ (16/16 tasks, 8.5s — Zod import-time validation of manifest clean) + rebuilt `packages/keel-invariants` (`tsc -b` regenerates `dist/check.js` — the sync-gate check runs against compiled output per iter-48 Gotcha) + `pnpm keel-invariants:check` clean-path exit 0 (zero drift output). Two source files modified (schema + manifest); no docs or INVARIANTS.md changes (fix is internal-schema-structure, not an anchor/stable-ID addition). Zero per-finding § Review Findings checkbox update this iter (iter-50 CR subsection tracks CR-1 as `PATCH` — next iter-52 re-run produces a fresh CR subsection with zero findings, completing the layer). PR #226 CI: `no checks reported`; push safe. Tracked at GitHub issue #34 — `Refs #34` in commit trailer.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.9 done; 1.10 `fixes-pending` — iter-52 CR re-verify pending; 1.11–1.16 backlog → 6 more stories × full FR14n lifecycle remaining after 1.10 closure before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** 1.10 — design-token schema, semantic + rationale contract
- **Story File:** `_bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md`
- **Story State:** `fixes-pending` — iter-51 discharged the sole PATCH (CR-1); QUEUE now empty. FR14n matrix row 10 transition guard: stays `fixes-pending` until iter-52 re-runs `/bmad-code-review (args: "2")` clean → `fixes-pending → done` per matrix row 10 exit.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Story 1.10 positioning.** First of 4 design-token-pipeline stories in Epic 1 (1.10 schema+rationale contract → 1.11 source population Direction A → 1.12 emitter pipeline → 1.13 quality gates). **Contract-only single-pass CR hypothesis partially falsified** (iter-7 Decisions): Story 1.10 surfaced 1 convergent Blind+Edge PATCH vs. Story 1.8's zero-finding clean CR. Closure trajectory holding at projected shape (iter-50 CR + iter-51 Fix + iter-52 re-run = 3-iter CR layer, analogous to iter-47..49 SM-layer 3-iter shape). Total Story 1.10 FR14n lifecycle iterations projected: 11 (iter-42..52) — ~1.5× Story 1.8's 7-iter closure, consistent with the partial-falsification hypothesis.
- **Trace posture.** Gate WAIVED (fourth cumulative — 1.7 iter-5 + 1.8 iter-5 + 1.9 iter-8 + 1.10 iter-46). Seven-point rationale pinned at iter-46 trace artefacts; unchanged by the SM / CR rounds.
- **Post-iter-51 audit trail.** Four files touched: `packages/ui/tokens.schema.json` (single-line `"required": ["light", "dark"]` added); `packages/keel-invariants/src/invariants.manifest.ts` (one-field `contentHash` swap); `.ralph/@plan.md` (this file); `RALPH.md` (new iter-51 Signpost). Zero docs / INVARIANTS.md / story-file / sprint-status changes — matches the mechanical-fix-round iteration pattern (iter-48 Fix SM-1 precedent). Quality gates re-run: `pnpm -w typecheck` ✓ + `pnpm --filter @keel/keel-invariants build` + `pnpm keel-invariants:check` clean-path ✓ exit 0. Drift-path smokes NOT re-run (iter-45 comprehensive drift evidence remains load-bearing; fix does not touch sync-gate walker/reader/drift-detector).
- **Anchor regex landmines avoided** (Story 1.9 CR defer carry-forward — `deferred-work.md:37-38`): iter-51 added no new `INV-*` anchors; pure single-line internal-schema edit + hash resync. No column-0 anchor-shape risk.
- **CR triage doctrine applied last iter** (iter-36 two-layer-convergence + iter-41 residue-family-catalogue + iter-50 new AC-carve-out-as-bulk-DEFER-gate): convergent Blind+Edge PATCH applied clean at iter-51. Iter-52 CR re-run is expected to land zero findings (AC-carve-out class already drained; single PATCH discharged; no new diff surface between iter-50 and iter-52 except the ~3-line-total fix + hash char-swap). If residual single-layer findings resurface, they're dismissed per DISMISS-class discipline (single-layer adversarial overreach without Edge/Auditor convergence).
- **Issue Tracking:** Story 1.10 tracked at GitHub issue **#34**. `Refs #34` in every commit trailer (including this iter's); `Closes #34` lands in PR body only when Story 1.10 reaches `done` (matrix row 11) — iter-52 earliest (post-clean-CR-re-run). Parent Epic 1 issue **#9** — `Refs #9` optional; never `Closes` it (ralph.py transitions epic issues to Done on EPIC_DONE halt).
