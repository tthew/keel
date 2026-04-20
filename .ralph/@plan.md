# Implementation Plan

## NOW

- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability matrix (`in-dev → traced`). ~medium

## QUEUE (Story 1.9 — invariant-sync-gate-runtime-tooling-reader-walker-drift-detector)

- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (`traced → sm-verified`).
- [ ] Run `/bmad-code-review (args: "2")` — adversarial triage (`sm-verified → done` OR `fixes-pending`).

## BLOCKED

_(none)_

## DONE (Story 1.9 — dev-story implementation)

- [x] `/bmad-dev-story` ran end-to-end (iter-4; `atdd-scaffolded → in-dev` per FR14n matrix row 4). All 5 Tasks landed in a single iteration:
  - **Task 1** — `manifest-reader.ts` (ESM; `readSourceFile` + `computeSha256` + re-exports `invariants` / `Invariant`) + `sync-gate.ts` (`runSyncGate(repoRoot)` + `readAnchors(repoRoot)` + `DriftReport` / `Drift` / `DriftKind` types; anchor walker regex `/^-\s+\*\*`([A-Z][A-Z0-9-]+)`\*\*/gm`; source reads deduped via `uniqueSourcePaths` set + `Promise.all` parallelism).
  - **Task 2** — 10th manifest entry `INV-ralph-halt-path-resolution` with `sourcePath: 'docs/invariants/ralph-execute.md'` + `contentHash: 8c679cd…cba8b` (re-verified via live `sha256sum`; byte-identical to spec-baked literal).
  - **Task 3** — 4 Story 1.8 CR defers absorbed: (a) sourcePath traversal `.refine()` guard; (b) id-uniqueness `superRefine`; (c) cross-entry `contentHash` consistency `superRefine`; (d) `export const invariants: readonly Invariant[] = Object.freeze(...)`. Defer #6 (schema-evolution metadata) stays in `deferred-work.md` per spec.
  - **Task 4** — `check.ts` CLI entry (`repoRoot = resolve(import.meta.dirname, '../../..')`; JSON DriftReport on stderr; exit 0/1). `packages/keel-invariants/package.json` gained `bin.keel-invariants-check` + `scripts.check`. Repo-root `package.json` gained `scripts.keel-invariants:check` alias. `src/index.ts` re-exports `runSyncGate` + types.
  - **Task 5** — 7 quality gates green (`pnpm install` / `typecheck 16/16` / `lint 16/16` / `build 16/16` / `format:check` post-prettier-rewrite-of-2-files / `commitlint 0 problems` / `prek 3/3 Passed`); 3 runtime smoke tests green (clean-path exit 0 / drift-path exit 1 + JSON DriftReport for `INV-tsconfig-base content-hash-mismatch` post-1-char-mutation + revert verified byte-for-byte / performance 0.77s wall-clock under AC 7's 2s budget); sprint-status + story Status → `review` (Ralph's FR14n `atdd-scaffolded → in-dev`; sprint-status uses dev-story workflow step 9's `review` state — the spec's Task 5 `→ done` target reaches completion at the post-CR iteration per FR14n trace → SM review → CR → done); Provisional-ID header discharged from `INVARIANTS.md` (both halves of Story 1.7's carve-out — "canonical IDs pinned by 1.8" + "drift-detection lands in 1.9" — now landed).
- [x] **Spec amendments recorded during dev** (pattern: future SM-review should expect spec amendments when a story's first genuine-runtime substrate story meets TypeScript's stdlib-type requirements):
  - `@types/node@20.19.0` devDep added to `@keel/keel-invariants` (spec's "no new deps needed" was accurate for runtime, but TS stdlib type resolution for `node:*` + `process` + `import.meta.dirname` requires it; types-only devDep, not runtime).
  - `"types": ["node"]` added to `packages/keel-invariants/tsconfig.json` (package-scoped, NOT `tsconfig.base.json` — avoiding polluting every workspace member's type roots).
  - `INV-prek-prepare-lifecycle` `contentHash` recomputed `0ba4c6fb…76 → c83420f2…6e` after Task-4-mandated `keel-invariants:check` script insertion in root `package.json` (substrate hash mirrors actual file state; legitimate same-PR contract update, not drift).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 in-dev)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until EPIC_DONE of Epic 1 per PROMPT_build.md step 5c "if all epic stories are done"; prior per-story-PR pattern (1.1–1.7) is superseded by current step-5c semantics)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `in-dev` (Ralph FR14n) / `review` (sprint-status + story-file Status per dev-story workflow step 9)
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Story 1.9 is the first Epic-1-substrate story with genuine runtime behaviour** — walker + drift-detector + CLI, NOT pure data-contract. AC coverage matrix documented in story file § Dev Agent Record § Completion Notes: AC 1/4/7 end-to-end via Task 5 smoke; AC 3/5 structural (not exercised because substrate is currently clean); AC 2 schema-level + spec-delegated to CR adversarial pass; AC 6 CLI-contract-only (workflow wiring is Epic 13 scope). Trace gate at `in-dev → traced` should PASS (not WAIVED) — materially covers 4-of-7 at shell-invocation + 2-of-7 structurally + 1-of-7 at schema/CR layer.
- **Spec-divergence pattern — spec said "no new deps needed" but TypeScript required `@types/node` for Node stdlib type resolution.** Future Story 1.16+ test-runner wiring will likely hit the same pattern — `node:test` + `vitest` both need `@types/node`. Flag at spec-time.
- **Sprint-status vs FR14n state mapping:** dev-story workflow step 9 sets sprint-status to `review` (not `done`) after implementation. Ralph's FR14n maps this to Story State `in-dev`. Subsequent iterations (trace → SM-review → CR) flip sprint-status to `done` at the END of CR per FR14n matrix row 10 (`sm-verified → done` via `/bmad-code-review`).
- Issue Tracking: Story 1.9 issue number still unset at iter-4 (no GH project auto-creation for stories). Parent Epic 1 issue **#9** — `Refs #9` only; closed by ralph.py EPIC_DONE halt handler at Epic 1 completion.
