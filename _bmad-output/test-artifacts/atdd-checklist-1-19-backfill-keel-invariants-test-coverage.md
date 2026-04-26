---
storyId: 1.19
storyKey: 1-19-backfill-keel-invariants-test-coverage
storyFile: _bmad-output/implementation-artifacts/1-19-backfill-keel-invariants-test-coverage.md
atddChecklistPath: _bmad-output/test-artifacts/atdd-checklist-1-19-backfill-keel-invariants-test-coverage.md
stepsCompleted:
  - step-01-preflight-and-context
  - step-02-generation-mode
  - step-03-test-strategy
  - step-04-generate-tests
  - step-04c-aggregate
  - step-05-validate-and-complete
lastStep: step-05-validate-and-complete
lastSaved: '2026-04-26'
generatedTestFiles:
  - packages/keel-invariants/src/eslint-rules/__tests__/no-verify-bypass.test.ts
  - packages/keel-invariants/src/__tests__/check-no-committed-dotfiles.test.ts
  - packages/keel-invariants/src/__tests__/check-nfr5a-minimum.test.ts
  - packages/keel-invariants/src/__tests__/check-claude-hook-syntax.test.ts
  - packages/keel-invariants/src/__tests__/sync-gate.test.ts
  - packages/keel-invariants/src/__tests__/invariants.manifest.test.ts
  - packages/keel-invariants/src/__tests__/check-package-test-coverage-floor.test.ts
inputDocuments:
  - _bmad-output/implementation-artifacts/1-19-backfill-keel-invariants-test-coverage.md
  - _bmad/tea/config.yaml
  - packages/keel-invariants/vitest.config.ts
  - packages/keel-invariants/src/__tests__/smoke.test.ts
  - packages/keel-invariants/src/eslint-rules/no-verify-bypass.js
  - packages/keel-invariants/src/check-no-committed-dotfiles.ts
  - packages/keel-invariants/src/check-nfr5a-minimum.ts
  - packages/keel-invariants/src/check-claude-hook-syntax.ts
  - packages/keel-invariants/src/sync-gate.ts
  - packages/keel-invariants/src/invariants.manifest.ts
---

# ATDD Checklist — Story 1.19 (Backfill `keel-invariants` test coverage)

## Step 1 — Preflight & context

- **Stack detected:** `backend` (TS Node + vitest under pnpm workspace; no Playwright / Cypress / browser config). `_bmad/tea/config.yaml` `test_stack_type: auto` → backend per detection algorithm (no frontend indicators in `packages/keel-invariants/`; `pyproject.toml` exists at root from Story 1.18 but the unit-of-work for Story 1.19 is `packages/keel-invariants/` which is purely TS).
- **Prerequisites:** Story validated (Story 1.19 FR14n state `validated` per IP iter-372). Test framework configured: `packages/keel-invariants/vitest.config.ts` (vitest 3.2.4 pinned). Pre-existing fixture: `src/__tests__/smoke.test.ts` (1 it-block, GREEN per iter-366 baseline).
- **Story key:** `1-19-backfill-keel-invariants-test-coverage` (filename basename); story id `1.19`.
- **Knowledge base loaded (core tier only — backend stack):** `data-factories`, `component-tdd`, `test-quality`, `test-healing-patterns`, `test-levels-framework`, `test-priorities-matrix`, `ci-burn-in`. Playwright / Pact / contract-testing fragments NOT loaded (out of stack).
- **Inputs confirmed.** Story 1.19 carries 6 ACs, 11 Tasks, ~38 subtasks, 12 SCs. SC-11 mandates FULL ATDD red-phase per § ATDD-skip ground-(b) sunset. SC-2 + AC2/AC4 reinterpretation locks honoured (per-enforcer stderr shape AS-SHIPPED; AC4 = sourcePath SHAPE not file existence).

## Step 2 — Generation mode

- **Mode:** AI generation (default per backend stack). Recording mode skipped (no UI). Sequential execution mode (Ralph build-loop is single-actor; subagent dispatch = self).

## Step 3 — Test strategy (AC → level → priority)

| AC  | Test surface                                                      | Level       | Priority | RED scaffolds | File                                                                      |
| --- | ----------------------------------------------------------------- | ----------- | -------- | ------------- | ------------------------------------------------------------------------- |
| AC1 | ESLint rule positive + negative coverage (`no-verify-bypass`)      | Unit        | P0       | 8             | `eslint-rules/__tests__/no-verify-bypass.test.ts`                          |
| AC2 | `check-no-committed-dotfiles` CLI (prose stderr, AS-SHIPPED)      | Integration | P0       | 4             | `__tests__/check-no-committed-dotfiles.test.ts`                            |
| AC2 | `check-nfr5a-minimum` CLI (single-line JSON stderr, AS-SHIPPED)   | Integration | P0       | 4             | `__tests__/check-nfr5a-minimum.test.ts`                                    |
| AC2 | `check-claude-hook-syntax` CLI (prose stderr, AS-SHIPPED)         | Integration | P0       | 4             | `__tests__/check-claude-hook-syntax.test.ts`                               |
| AC3 | sync-gate four canonical drift classes + clean baseline           | Integration | P0       | 5             | `__tests__/sync-gate.test.ts`                                              |
| AC4 | Zod schema rejection + `superRefine` duplicate-id                 | Unit        | P0       | 6             | `__tests__/invariants.manifest.test.ts`                                    |
| AC5 | NEW `check-package-test-coverage-floor` enforcer (NDJSON stderr)  | Integration | P0       | 3             | `__tests__/check-package-test-coverage-floor.test.ts`                      |

**Total:** 7 NEW test files / **34 RED-phase `it.skip()` scaffolds** (matches SC-12 forecast surface decomposition; see story line 234 — actual block count 34, slight upward revision from 33 due to ID-format malformed-input enumeration via array-loop counting as 1 it-block, not N).

**No E2E scaffolds:** backend stack — `tea-atdd-e2e-tests-*.json` worker yields zero tests. Worker A (API) carried the full red-phase output.

**Priority rationale (all P0):** Story 1.19 IS the test coverage backfill — every test surface is the deliverable. No P1/P2/P3 tiering at this story (deferred edge cases live in QUEUE fix-task envelope per CR pass).

## Step 4 — Generated test scaffolds (RED phase)

**TDD red-phase contract honoured:** every it() body asserts the EXPECTED behaviour and is wrapped in `.skip(...)`. Activation (remove `.skip`) by `/bmad-dev-story` per Story 1.19 Tasks 2–8 subtask 2.4/3.3/4.4/5.4/6.5/7.4/8.3.

| File                                                       | Tests | Skipped | Status     | Notes                                                                                                |
| ---------------------------------------------------------- | ----- | ------- | ---------- | ---------------------------------------------------------------------------------------------------- |
| `eslint-rules/__tests__/no-verify-bypass.test.ts`           | 8     | 8       | RED scaffold | Dynamic-import via `RULE_PATH` const so TS skips JS-source declaration check (no .d.ts on rule).      |
| `__tests__/check-no-committed-dotfiles.test.ts`             | 4     | 4       | RED scaffold | Static `import.meta.dirname` cliPath (Node 20.11+ baseline per Subtask 3.1).                          |
| `__tests__/check-nfr5a-minimum.test.ts`                     | 4     | 4       | RED scaffold | Strategy A tmpdir relocation (per Subtask 4.2 + 4.3 lock-don't-defer).                                |
| `__tests__/check-claude-hook-syntax.test.ts`                | 4     | 4       | RED scaffold | Strategy A inherited from Subtask 4.2 (Subtask 5.1).                                                  |
| `__tests__/sync-gate.test.ts`                               | 5     | 5       | RED scaffold | `vi.doMock(...)` per-test for manifest-reader (per Subtask 6.2 Strategy A lock).                      |
| `__tests__/invariants.manifest.test.ts`                     | 6     | 6       | RED scaffold | 5 InvariantSchema rejection classes + 1 InvariantsSchema superRefine duplicate-id (per Subtask 7.3). |
| `__tests__/check-package-test-coverage-floor.test.ts`       | 3     | 3       | RED scaffold | Targets NOT-YET-IMPLEMENTED enforcer; dev-story Task 8.1 authors source before activation.            |

**Pre-existing tests untouched:**

- `src/__tests__/smoke.test.ts` (1 test) — still GREEN.
- `src/prompt-injection-rules/hook-settings-tamper.test.ts` (7 `node:test` callsites) — vitest config still excludes per Subtask 1.2 spec; Task 1 migration is dev-story work, NOT ATDD scaffolding.

## Step 4c — Aggregation

- **Subagent A (API RED):** complete; 34 it.skip() blocks across 7 files.
- **Subagent B (E2E RED):** N/A (backend stack); zero tests emitted (correct per backend profile).
- **TDD compliance verified:** every authored it() carries `.skip(...)`; vitest reports `34 skipped` / `0 active failing` for the new files.
- **File-load verification:** `pnpm --filter @keel/keel-invariants test` exits 0 (skipped tests register but do not execute); `pnpm typecheck` exit 0; `pnpm lint` exit 0; `pnpm format:check` exit 0 (post `pnpm format` apply).

## Step 5 — Validate & complete

**RED-phase contract:**

- ✅ Every test has `it.skip(...)` (RED phase requirement)
- ✅ Every test asserts EXPECTED behaviour (will fail when activated until impl/backfill complete)
- ✅ All tests register in vitest collector but do not execute
- ✅ Lint + typecheck + format clean across the new surface

**Activation handoff to `/bmad-dev-story`:**

1. Story 1.19 Task 1 (vitest migration of `prompt-injection-rules/hook-settings-tamper.test.ts`) is a precondition — must land BEFORE the 7 RED scaffolds activate, since it removes the `vitest.config.ts` exclude that currently shields the prompt-injection-rules surface from double-discovery.
2. For each AC, dev-story removes `.skip` per file as the corresponding implementation surface is verified. The 6 backfill-of-existing-impl files (no-verify-bypass + 3 check-* + sync-gate + invariants.manifest) should turn GREEN immediately on activation IF the impl is correct — if a test stays RED, that surfaces the pre-existing bug that the SCP § risk assessment forecast (4–6 CR iterations driven by impl-bug surfacing).
3. AC5 (check-package-test-coverage-floor.test.ts) targets NOT-YET-IMPLEMENTED source. Dev-story Task 8.1 authors `check-package-test-coverage-floor.ts`; Task 9.x registers manifest + INVARIANTS.md entries; the 3 scaffolds activate AFTER Task 8.1 lands.
4. ATDD red-phase is now durable: vitest run shows the 34 skipped tests every iteration. Each `.skip` removal is a story-progress signal.

**FR14n state transition:** `validated → atdd-scaffolded` (Story 1.19; first reopen-arc story to re-introduce ATDD post Stories 1.17/1.18 ATDD-skip era per SC-11).

**Cumulative pre-merge PATCH count Story 1.19 lifecycle to date:** 21 (unchanged from SM-validate iter-372; ATDD-scaffold is a pure-add — no spec mutation; tracks as N=34 red-phase scaffolds in lifecycle ledger NOT a PATCH count addend per SC-12 ATDD-scaffold row).

**Next step (Ralph FR14n matrix `atdd-scaffolded` row):** `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-19-backfill-keel-invariants-test-coverage.md")`.
