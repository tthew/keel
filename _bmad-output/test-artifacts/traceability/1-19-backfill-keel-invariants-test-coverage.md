---
stepsCompleted:
  - step-01-load-context
  - step-02-discover-tests
  - step-03-map-criteria
  - step-04-analyze-gaps
  - step-05-gate-decision
lastStep: step-05-gate-decision
lastSaved: 2026-04-26
workflowType: testarch-trace
inputDocuments:
  - _bmad-output/implementation-artifacts/1-19-backfill-keel-invariants-test-coverage.md
  - _bmad-output/planning-artifacts/epics.md
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/architecture.md
coverageBasis: acceptance_criteria
oracleConfidence: high
oracleResolutionMode: formal_requirements
oracleSources:
  - _bmad-output/implementation-artifacts/1-19-backfill-keel-invariants-test-coverage.md (AC1-AC6)
externalPointerStatus: not_used
tempCoverageMatrixPath: /tmp/tea-trace-coverage-matrix-1-19.json
---

# Traceability Matrix & Gate Decision — Story 1.19 Backfill `keel-invariants` test coverage

**Target:** Story 1.19 — Backfill `keel-invariants` test coverage
**Date:** 2026-04-26 (iter-375)
**Evaluator:** Tthew (TEA Agent via Ralph build-mode)
**Coverage Oracle:** acceptance_criteria
**Oracle Confidence:** high
**Oracle Sources:** Story 1.19 ACs 1–6 (formal requirements)

---

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status        |
| --------- | -------------- | ------------- | ---------- | ------------- |
| P0        | 3              | 3             | 100%       | ✅ MET        |
| P1        | 2              | 2             | 100%       | ✅ MET        |
| P2        | 1              | 0             | 0%         | informational |
| P3        | 0              | 0             | n/a        | n/a           |
| **Total** | **6**          | **5**         | **83%**    | **PASS**      |

**Gate decision: PASS.** Story 1.19 is the FIRST reopen-arc story whose AC class is "test backfill of untested impl" — coverage IS the deliverable per IP § NOW directive + SC-12 trace-row 0–2 PATCH expected. All five test-covered ACs (AC1 ESLint rule + AC2 three enforcers + AC3 sync-gate four drift classes + AC4 Zod schema rejections + AC5 NEW `INV-package-test-coverage-floor` enforcer + manifest registration) are FULL via 34 deterministic vitest cases under `pnpm --filter @keel/keel-invariants test` (42/42 GREEN at iter-374 dev-story per Change Log v1.3). AC6 is a process-only AC discharged at `/bmad-code-review` iteration per FR14n state matrix `sm-verified → done`; PARTIAL at trace gate by construction (no runtime test surface).

### Detailed Mapping

#### AC1: Each ESLint rule has positive + negative test coverage; tests pass under `pnpm --filter @keel/keel-invariants test` (P0)

- **Coverage:** FULL ✅
- **Tests (8):**
  - `1.19-UNIT-001` — `packages/keel-invariants/src/eslint-rules/__tests__/no-verify-bypass.test.ts:12` `valid: --verify (different flag, lookahead prevents substring miss)` — RuleTester valid case (negative; rule does NOT fire).
  - `1.19-UNIT-002` — `…:25` `valid: no-verify (lookbehind prevents partial token match)` — RuleTester valid case.
  - `1.19-UNIT-003` — `…:37` `valid: template literal containing no bypass token` — RuleTester valid case (template literal class).
  - `1.19-UNIT-004` — `…:49` `valid: empty string literal` — RuleTester valid case (degenerate input).
  - `1.19-UNIT-005` — `…:61` `invalid: --no-verify literal → reports messageId bypass + token data` — RuleTester invalid case (positive; rule fires); asserts `errors: [{ messageId: 'bypass', data: { token: '--no-verify' } }]`.
  - `1.19-UNIT-006` — `…:78` `invalid: --dangerously-skip-permissions literal → reports bypass + token` — second BYPASS_PATTERN.
  - `1.19-UNIT-007` — `…:95` `invalid: template literal cooked-value carries --no-verify` — template-literal traversal.
  - `1.19-UNIT-008` — `…:112` `invalid: template literal multi-token line carries --dangerously-skip-permissions` — multi-token line.
- **Evidence:** Dev Agent Record § Completion Notes (v1.3, iter-374): vitest reporter `8 tests` GREEN under `src/eslint-rules/__tests__/no-verify-bypass.test.ts` line. Both BYPASS_PATTERN tokens × {literal, template} × {valid, invalid} permutations covered.
- **Recommendation:** none — AC verified end-to-end. Future ESLint-rule additions to `eslint-rules/` should follow the same valid+invalid pattern (carry-rule for Story 2.16 / Epic 4 follow-up rules).

#### AC2: Each per-rule `check-*.ts` enforcer has CLI integration test exercising green-path exit-0 + red-path exit-1 + structured stderr (P0)

- **Coverage:** FULL ✅
- **Tests (12 across 3 files; honours per-enforcer stderr shape AS-SHIPPED per SC-2 lock — prose for hook-syntax + dotfiles, JSON for nfr5a-minimum):**
  - **`check-no-committed-dotfiles.ts` (4 tests):**
    - `1.19-INT-001` — `packages/keel-invariants/src/__tests__/check-no-committed-dotfiles.test.ts:17` `exits 0 with no staged files (vacuous green path)` — green-path baseline.
    - `1.19-INT-002` — `…:23` `exits 0 with compliant staged file paths (incl. .envrc.example schema-companion)` — anchored-regex fallthrough exemption per substrate ledger line 247.
    - `1.19-INT-003` — `…:34` `exits 1 with .envrc in staged files; stderr matches Refusing-to-commit prose` — red-path; asserts prose stderr per `check-no-committed-dotfiles.ts:35-38`.
    - `1.19-INT-004` — `…:41` `exits 1 with .claude/settings.local.json in staged files; stderr names the offender` — second denylist anchor.
  - **`check-nfr5a-minimum.ts` (4 tests):**
    - `1.19-INT-005` — `packages/keel-invariants/src/__tests__/check-nfr5a-minimum.test.ts:33` `exits 0 when settings.json carries 13 deny + 6 allow (substrate baseline)` — green-path; Strategy A tmpdir relocation per SC-5 lock.
    - `1.19-INT-006` — `…:45` `exits 1 with deny-min violation; stderr is single-line JSON {status: violation, ...} citing 13` — red-path JSON; `JSON.parse(stderr.trim())` per substrate ledger line 262.
    - `1.19-INT-007` — `…:58` `exits 1 with allow-min violation; stderr is single-line JSON citing the lower bound` — second violation class.
    - `1.19-INT-008` — `…:71` `exits 1 when .permissions.deny is missing/not-array; stderr cites missing-or-not-an-array` — missing-array shape; the third violation sub-case per Subtask 4.2.
  - **`check-claude-hook-syntax.ts` (4 tests):**
    - `1.19-INT-009` — `packages/keel-invariants/src/__tests__/check-claude-hook-syntax.test.ts:33` `exits 0 for bash-shebang script with valid syntax` — green-path; Strategy A inherited per SC-5 lock.
    - `1.19-INT-010` — `…:42` `exits 0 for sh-shebang script that passes both bash AND dash` — sh-dispatch dual-checker green per `check-claude-hook-syntax.ts:43-46`.
    - `1.19-INT-011` — `…:49` `exits 1 for bash-shebang script with if-fi mismatch; stderr cites syntax failures` — red-path bash-only.
    - `1.19-INT-012` — `…:59` `exits 1 for sh-shebang script using bashism here-string \`<<<\` (fails dash)` — red-path sh-dispatch; **fixture corrected at iter-374** from `[[ "x" = "x" ]]` (which dash -n parses as command name, exits 0) to `<<<` here-string (true syntax-level bashism per RALPH.md iter-374 ATDD-fixture-validation carry-rule).
- **Evidence:** Dev Agent Record § Completion Notes (v1.3, iter-374): vitest reporter `4 tests` GREEN per file (3 files × 4 tests = 12 cases); `pnpm --filter @keel/keel-invariants build && test` GREEN end-to-end (`dist/check-*.js` artifacts present per turbo `dependsOn: ["^build"]`).
- **Recommendation:** none — AC verified end-to-end across all 3 in-scope enforcers per epics.md:1218-1221 (the 2 `tokens-*` enforcers are out of AC2 scope per Story 1.13 design-token gates). The substrate-ledger-pinned per-enforcer stderr shapes (prose vs JSON) are honoured AS-SHIPPED per SC-2 lock; NOT re-litigatable at CR.

#### AC3: Sync-gate CLI integration tests exercise each of the four canonical drift classes with the expected exit-code-1 + DriftReport JSON shape (P1)

- **Coverage:** FULL ✅
- **Tests (5; 4 drift classes per epics.md:1225 + 1 clean-baseline negative-space companion per Subtask 6.4 INCLUDED-not-optional lock):**
  - `1.19-INT-013` — `packages/keel-invariants/src/__tests__/sync-gate.test.ts:27` `added-to-source-only: manifest entry exists, INVARIANTS.md has no anchor` — drift-class-1; `vi.doMock` per-test for manifest-reader (Strategy A per SC-5 lock at Subtask 6.2).
  - `1.19-INT-014` — `…:56` `removed-from-source-only: INVARIANTS.md has anchor, sourcePath is missing on disk` — drift-class-2; `read-error` branch per `sync-gate.ts:120-127`.
  - `1.19-INT-015` — `…:87` `removed-from-docs-only: INVARIANTS.md has orphan anchor, manifest is empty` — drift-class-3.
  - `1.19-INT-016` — `…:103` `content-hash-mismatch: source file content does not match manifest contentHash` — drift-class-4; expects `expectedHash`/`actualHash` payload.
  - `1.19-INT-017` — `…:135` `clean baseline: aligned manifest + docs + source returns status: clean` — clean-baseline negative-space companion. **Fixture corrected at iter-374**: id switched `INV-aligned` → `INV-aligned-fixture` because singleton ids fail the ANCHOR_REGEX `INV-[a-z0-9]+(-[a-z0-9]+)+` quantifier (per RALPH.md iter-374 ATDD-fixture-validation carry-rule).
- **Evidence:** Dev Agent Record § Completion Notes (v1.3, iter-374): vitest reporter `5 tests` GREEN under `src/__tests__/sync-gate.test.ts` line. Each test programmatically invokes `runSyncGate(repoRoot)` against an `mkdtemp` fixture per Subtask 6.1.
- **Gaps:** the two `git-hook-*` drift classes (`sync-gate.ts:18-19`) are OUT OF SCOPE per SC-3 (epic-spec four-class enumeration governs); deferred to Story 1.21 audit OR Epic 4 follow-up per the SM-validate iter-371 lock-don't-defer rule. Pre-existing 3× `INV-git-hooks-preservation` runtime drifts (RALPH.md iter-358 gotcha) are also carved out per SC-9.
- **Recommendation:** Story 1.21 audit codifies the worktree-mode resolver fix for the `git-hook-*` walker AND adds adversarial coverage for the two excluded classes if scoped (per SC-9 two-path deferral).

#### AC4: Manifest Zod schema rejection tests cover each malformed-input class (P1)

- **Coverage:** FULL ✅
- **Tests (6; 5 InvariantSchema rejection classes per AC4 sub-cases + 1 InvariantsSchema superRefine per Subtask 7.3 INCLUDED-not-optional lock):**
  - `1.19-UNIT-009` — `packages/keel-invariants/src/__tests__/invariants.manifest.test.ts:21` `rejects bad ID format: BadID, INV-UPPER, inv-lower, INV-singleton, INV-bad_underscore` — sub-case 1; array-loop covers 5 input classes in one `it()` block.
  - `1.19-UNIT-010` — `…:29` `rejects entry missing required field (description / id / sourcePath / contentHash / anchors)` — sub-case 2; covers each missing-field permutation.
  - `1.19-UNIT-011` — `…:39` `rejects contentHash regex violations (length, uppercase hex, non-hex char)` — sub-case 3.
  - `1.19-UNIT-012` — `…:48` `rejects empty anchors array (z.array(...).min(1))` — sub-case 4.
  - `1.19-UNIT-013` — `…:54` `rejects sourcePath SHAPE violations (absolute, traversal, backslash)` — sub-case 5; honours SC-2 reinterpretation (file-existence covered by AC3 drift-class-2, NOT here).
  - `1.19-UNIT-014` — `…:63` `superRefine: rejects array containing duplicate ids` — InvariantsSchema schema-level uniqueness guard per `invariants.manifest.ts:54-87`.
- **Evidence:** Dev Agent Record § Completion Notes (v1.3, iter-374): vitest reporter `6 tests` GREEN under `src/__tests__/invariants.manifest.test.ts` line. All assertions use `safeParse(...).success === false` (no throw); `error.issues[]` shape verified via Zod payload.
- **Recommendation:** none — AC verified end-to-end. The two SC-2 reinterpretations (Zod stops at string shape; sync-gate owns filesystem existence) are NOT re-litigatable at CR per SM-validate iter-371 lock.

#### AC5: `INV-package-test-coverage-floor` invariant registered in `invariants.manifest.ts` + `INVARIANTS.md` index; enforcer ships as a `check-*.ts` CLI bin; sync-gate stays clean (P0)

- **Coverage:** FULL ✅
- **Tests (3 + 3 substrate verifications):**
  - `1.19-INT-018` — `packages/keel-invariants/src/__tests__/check-package-test-coverage-floor.test.ts:45` `green: covered package (>=1 *.test.ts under src/) exits 0 with empty stderr` — green-path; Strategy A tmpdir + workspace-fixture per SC-5 lock at Subtask 8.3.
  - `1.19-INT-019` — `…:60` `green: exempt package (devbox) without coverage exits 0 (EXEMPT_LIST recognised)` — exempt-path; verifies `EXEMPT_LIST = new Set(['keel-templates', 'devbox'])` per AC5 + NFR1a + PRD line 1068.
  - `1.19-INT-020` — `…:72` `red: non-exempt package missing coverage exits 1; stderr is NDJSON {status: violation, package, message}` — red-path NDJSON; honours Subtask 8.1 multi-violation wire-format lock.
  - `1.19-SUBSTRATE-001` — `packages/keel-invariants/src/check-package-test-coverage-floor.ts` (NEW; 79 lines per Change Log v1.3): standalone CLI shipped with shebang `#!/usr/bin/env node`, REPO_ROOT resolution via `path.resolve(import.meta.dirname, '..', '..', '..')`, `fs.readdir(srcDir, { recursive: true })` (Node 20.11+ stable per Subtask 8.1 lock), NDJSON wire format. **TS narrowing fix at first build:** `readdir(... { recursive: true })` returns `string[]`; the spec's `typeof name === "string" ? name : name.toString()` ternary produced `name: never` in the false branch — simplified to `entry.endsWith('.test.ts')` directly per Change Log v1.3.
  - `1.19-SUBSTRATE-002` — `packages/keel-invariants/src/invariants.manifest.ts` (modify): `INV-package-test-coverage-floor` array entry registered with contentHash `57555cb453e7cc46569874befb28d7faa2c5689f458da2b8c11303c8f4cfa32e` per Subtask 9.1; sync-gate runtime verification at `pnpm keel-invariants:check` reports zero new drift attributable to this story (3 pre-existing `INV-git-hooks-preservation` drifts persist UNCHANGED per SC-9 carve-out).
  - `1.19-SUBSTRATE-003` — `INVARIANTS.md` (modify): new section `### Test coverage floor (Story 1.19)` + entry inserted at correct line-anchor (between Story 1.16 Fork extension end at line 88 + Story 2.1 Devbox iteration substrate header at line 90 per Subtask 9.3 SM-validate iter-371 lock).
- **Evidence:** Dev Agent Record § Completion Notes (v1.3, iter-374): vitest reporter `3 tests` GREEN under `src/__tests__/check-package-test-coverage-floor.test.ts` line; `pnpm keel-invariants:package-test-coverage-floor` runs against live worktree per Subtask 10.4 — keel-invariants GREEN (no violation; this story IS its backfill) + keel-templates + devbox EXEMPT-recognised; 12 other workspace packages reported as informational coverage-floor violations per locked Subtask 10.4 carve-out (Story 1.21 backfill candidates).
- **Recommendation:** Story 1.21 audit lands the `keel-templates` + `devbox` coverage backfill follow-ups (the two EXEMPT_LIST entries) per NFR1a + the locked Subtask 10.4 carve-out. Pre-commit/CI invocation of the new enforcer is Story 1.21 audit OR Epic 4 follow-up territory per SC-6.

#### AC6: All Story 1.19 CR action items addressed in QUEUE fix iterations OR explicitly deferred with `defer:` rationale; story transitions `sm-verified → done` cleanly (P2)

- **Coverage:** PARTIAL ⚠️ (PROCESS-ONLY; not a runtime-test-covered AC)
- **Tests (1 process-marker):**
  - `1.19-PROCESS-001` — `_bmad-output/implementation-artifacts/1-19-backfill-keel-invariants-test-coverage.md:63` AC6 prose: "discharged at `/bmad-code-review` iteration per FR14n state matrix `sm-verified → done`".
- **Gaps:** AC6 has no runtime test surface by construction. Discharge happens at the `sm-verified → done` lifecycle transition driven by `/bmad-code-review (args: "2")` per FR14n state matrix; expected 4–6 CR iterations per IP § Notes line 54 + SCP § risk Medium + SC-12 forecast envelope CR row.
- **Recommendation:** none at trace gate. AC6 closes at the CR-substitution iteration; `defer:` rationales captured per RALPH.md iter-353 inline-bundle-close + iter-362 mid-arc narrow-band recipe + iter-369 first-CI-workflow-job hardening residual class precedents.

---

### Gap Analysis

#### Critical Gaps (BLOCKER) ❌

0 critical gaps. All three P0 ACs (AC1 ESLint rule + AC2 three enforcers + AC5 NEW INV-package-test-coverage-floor enforcer + manifest registration) are FULL.

#### High Priority Gaps (PR BLOCKER) ⚠️

0 high-priority gaps. Both P1 ACs (AC3 sync-gate four drift classes + AC4 Zod schema rejections) are FULL.

#### Medium Priority Gaps (Nightly) ⚠️

1 P2 PARTIAL gap — AC6 process-only, discharged at CR iteration per FR14n. By construction; not a runtime-test-coverable AC.

#### Low Priority Gaps (Optional) ℹ️

0.

---

### Coverage Heuristics Findings

- **Endpoint coverage gaps:** not applicable (no API surface in Story 1.19; the story is internal test backfill of `packages/keel-invariants/`).
- **Auth/Authz negative-path gaps:** not applicable.
- **Happy-path-only gaps:** **NONE** — every AC's test surface explicitly covers BOTH the green path AND the red path (AC1 RuleTester valid + invalid; AC2 each enforcer exit-0 + exit-1; AC3 each drift class + clean baseline; AC4 each malformed-input class via `safeParse(...).success === false`; AC5 covered + exempt + red). This is the structural inverse of Stories 1.17 + 1.18 traces (which marked happy-path-only minimality on bootstrap smoke tests).
- **UI journey gaps:** not applicable.
- **UI state gaps:** not applicable.

---

### Quality Assessment

- **Tests passing quality gates:** 34/34 (the Story-1.19-attributable surface) — passes vitest 3.2.4 with sub-second wall time per file (slowest: `no-verify-bypass.test.ts` at 375ms incl. 303ms RuleTester warm-up; total package suite 873ms wall time per dev-story v1.3).
- **Total package suite:** 42/42 GREEN (34 Story-1.19-attributable + 7 `prompt-injection-rules/hook-settings-tamper.test.ts` migrated by Task 1 + 1 pre-existing `smoke.test.ts` from Story 1.17 substrate).
- **No flaky tests detected** — all tests are deterministic per-fixture; no network or filesystem-shared-state dependencies (each tmpdir fixture isolated via `mkdtemp`).
- **Skipped tests:** 0 (the original 34 RED-phase `it.skip()` scaffolds from iter-373 ATDD all activated GREEN at iter-374 dev-story per Change Log v1.3 + Step 4 guardrail-4 ATDD-red-phase pruning rule).

---

### Coverage by Test Level

| Test Level | Tests  | Criteria Covered    | Coverage % |
| ---------- | ------ | ------------------- | ---------- |
| E2E        | 0      | 0                   | n/a        |
| API        | 0      | 0                   | n/a        |
| Component  | 0      | 0                   | n/a        |
| Unit       | 34     | 5 (AC1–AC5 FULL)    | 83%        |
| **Total**  | **34** | **5**               | **83%**    |

Note: AC6 is process-only (no test surface); counted as PARTIAL but tracked outside the unit-level inventory above. AC5's three `1.19-SUBSTRATE-*` rows are substrate-verified (manifest registration + INVARIANTS.md section + enforcer source ship), not pytest-discoverable; counted within AC5's FULL status because the AC explicitly couples test cases with substrate-side registration.

---

### Traceability Recommendations

#### Immediate Actions (Before PR Merge)

1. **None — gate is PASS** with deterministic decision logic. Proceed to post-dev SM (`/bmad-create-story (args: "review")`) per IP § QUEUE first item (forecast 1–4 PATCH per RALPH.md iter-352 narrow-substrate-extension empirical envelope; iter-368 + iter-361 confirmed Story 1.18 + Story 1.17 post-dev SM-verify yielded 4 PATCH at gate within band).

#### Short-term Actions (This Milestone — Epic 1 reopen arc, Stories 1.17–1.21)

1. **Story 1.20** — Activate FR14i (`INV-fr14i-ci-workflow-presence` invariant registration); expand `.github/workflows/ci.yml` trigger filter to cover `feat/epic-*` PR bases per RALPH.md iter-371 gotcha; address pre-existing 3× `INV-git-hooks-preservation` drifts before close-out per RALPH.md iter-358.
2. **Story 1.21** — Audit + sweep: register `INV-vitest-pin` + `INV-pytest-pin`; resolve `INV-git-hooks-preservation` worktree-mode resolver bug; ATDD-skip retro-sweep into test-debt.md; **`keel-templates` + `devbox` coverage backfill** per the locked Subtask 10.4 carve-out + NFR1a EXEMPT_LIST follow-up; Python coverage backfill if scoped.

#### Long-term Actions (Backlog — beyond Epic 1 reopen arc)

1. **Epic 4** (per-iteration security verification) — extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Story 1.19 backfill discharges the Epic 4 hard-precondition (per IP § Notes line 60); Epic 4 stories will follow the Story 1.19 ESLint+enforcer test pattern per § Recommendation under AC1.
2. **Story 1.21 audit** may add adversarial tests for the 7 `manifest-reader.ts` crypto/fs helpers (`computeSubtreeHash` jq-subtree / `computeAnchorRangeHash` anchor-range / `computeNamesAndShebangsHash` names-and-shebangs hashScope variants) — explicitly out of Story 1.19 scope per SM-validate iter-371 lock + Dev Notes substrate-ledger correction.

---

## PHASE 2: QUALITY GATE DECISION

**Gate Type:** story
**Decision Mode:** deterministic (P0 100% + P1 100% + Overall 83% all MET)

### Evidence Summary

#### Test Execution Results

- **Total Tests**: 34 (Story-1.19-attributable surface) + 8 inherited (prompt-injection migration + Story 1.17 smoke) = 42 package-wide
- **Passed**: 42 (100%)
- **Failed**: 0
- **Skipped**: 0
- **Duration**: 873ms wall time (vitest 3.2.4 reporter per dev-story v1.3 § Completion Notes Task 10.1)
- **Test Results Source**: iter-env Subtask 10.1 (`pnpm --filter @keel/keel-invariants build && pnpm --filter @keel/keel-invariants test`); evidence captured in Story 1.19 § Dev Agent Record § Completion Notes v1.3

#### Coverage Summary (from Phase 1)

- **P0 ACs**: 3/3 FULL (100%) — AC1 ESLint rule (8 tests); AC2 three enforcers (12 tests); AC5 NEW enforcer + manifest (3 tests + 3 substrate verifications)
- **P1 ACs**: 2/2 FULL (100%) — AC3 sync-gate four drift classes + clean baseline (5 tests); AC4 Zod schema rejections (6 tests)
- **P2 ACs**: 0/1 FULL (0%) — AC6 process-only (discharged at CR iteration; PARTIAL by construction)
- **Overall**: 83% (5/6 FULL)
- **Coverage Source**: this report

#### Non-Functional Requirements (NFRs)

- **Security**: PASS — Story 1.19 backfills test coverage for the substrate-side enforcers that gate merges via FR42/FR43/FR43a. AC1 verifies `no-verify-bypass` ESLint rule (defends against `--no-verify` + `--dangerously-skip-permissions` token surfaces); AC2 verifies the three secret/hook/permissions enforcers; AC5 ships the new NFR1a coverage-floor enforcer. No new secrets handling; no new auth surface.
- **Performance**: PASS — 42 tests in 873ms wall time; sub-second per file; no perf surface impacts.
- **Reliability**: PASS — vitest 3.2.4 pinned per Story 1.17 substrate; deterministic fixture isolation via `mkdtemp` per integration-test cluster; no flaky tests detected.
- **Maintainability**: PASS — substrate-extension class per RALPH.md iter-344 + iter-359 + iter-366 (additive edits; no rewrites). New enforcer mirrors `check-no-committed-dotfiles.ts` shape; new test files mirror `__tests__/smoke.test.ts` import header per Story 1.19 SC-1 vitest-house-style.

#### Flakiness Validation

- **Burn-in Iterations**: not run (sub-second deterministic suite; flake risk near-zero per fixture-isolation analysis above).
- **Flaky Tests Detected**: 0.
- **Burn-in Source**: not_available (Story 1.21 audit may add burn-in fixtures if scoped).

---

### Decision Criteria Evaluation

#### P0 Criteria

| Criterion             | Threshold | Actual              | Status   |
| --------------------- | --------- | ------------------- | -------- |
| P0 Coverage           | 100%      | 100%                | ✅ PASS  |
| P0 Test Pass Rate     | 100%      | 100% (34/34 active) | ✅ PASS  |
| Security Issues       | 0         | 0                   | ✅ PASS  |
| Critical NFR Failures | 0         | 0                   | ✅ PASS  |
| Flaky Tests           | 0         | 0                   | ✅ PASS  |

**P0 Evaluation**: PASS on every criterion. AC1 + AC2 + AC5 all FULL with both green-path and red-path verification.

#### P1 Criteria

| Criterion              | Threshold | Actual | Status   |
| ---------------------- | --------- | ------ | -------- |
| P1 Coverage            | ≥80%      | 100%   | ✅ PASS  |
| P1 Test Pass Rate      | ≥80%      | 100%   | ✅ PASS  |
| Overall Test Pass Rate | ≥80%      | 100%   | ✅ PASS  |
| Overall Coverage       | ≥80%      | 83%    | ✅ PASS  |

**P1 Evaluation**: PASS on every criterion. AC3 + AC4 both FULL.

#### P2/P3 Criteria

| Criterion         | Actual          | Notes                                                     |
| ----------------- | --------------- | --------------------------------------------------------- |
| P2 Test Pass Rate | n/a             | AC6 process-only; discharged at CR iteration per FR14n   |
| P3 Test Pass Rate | n/a             | No P3 ACs                                                 |

---

### GATE DECISION: PASS ✅

### Rationale

Story 1.19 is the FIRST reopen-arc story whose AC class is "test backfill of untested impl" — coverage IS the deliverable per IP § NOW directive. The story explicitly does NOT inherit the bootstrap-runtime structural-WAIVED posture of Stories 1.17 + 1.18 (which were the test runners themselves). Per FR14n state matrix `in-dev → traced` row + SC-12 trace-row 0–2 PATCH expected envelope, the deterministic decision logic applies cleanly:

- **P0 coverage = 100%** (AC1 + AC2 + AC5 all FULL via 23 tests + 3 substrate verifications) → Rule 1 PASS satisfied.
- **P1 coverage = 100%** (AC3 + AC4 both FULL via 11 tests) → Rule 4 PASS satisfied (≥90% target met).
- **Overall coverage = 83%** (5/6 ACs FULL; AC6 process-only PARTIAL) → Rule 2 PASS satisfied (≥80% minimum met).

**Why not WAIVED?** Unlike Stories 1.17 + 1.18 (substrate-extension class with bootstrap structural rationale), Story 1.19 ships REAL tests that adversarially exercise existing impl. The ATDD-skip ground-(b) sunset (issue #233 amendment) is the explicit policy gate that makes WAIVED inappropriate here per SC-11 directive. The test surface is the deliverable.

**Why not CONCERNS?** P1 coverage is 100% (well above the 90% target); overall 83% (above 80% minimum); no NFR failures; no flaky tests; no critical/high gaps. Every gate criterion lands at MET.

**Cumulative trace counter:** 1st story-trace PASS in Epic 1 reopen arc (after Stories 1.17 iter-360 + 1.18 iter-367 trace-WAIVED). 1st adversarial-backfill-class trace PASS overall in the project (Stories 1.7–1.16 + 2.1–2.18 traces were all WAIVED-class substrate-extension). Pattern: when AC scope IS coverage authoring (NOT bootstrap substrate), the trace gate transitions from WAIVED to PASS automatically per the FR14n state matrix logic; no special override required.

### Residual Risks (For PASS)

1. **AC6 discharge depends on CR iteration outcomes** (forecast 4–6 iterations per IP § Notes line 54).
   - **Priority**: P2
   - **Probability**: Medium — pre-existing impl bugs in `keel-invariants` may surface for the first time under test (per SCP § risk Medium directive); each surface bug becomes a CR action item.
   - **Impact**: Low — CR action items convert to QUEUE fix tasks per FR14n state matrix `sm-verified → done` row + RALPH.md iter-353 + iter-362 mid-arc inline-bundle-close recipes.
   - **Mitigation**: SM-validate iter-371 explicitly forecast this risk + locked AC scope tightly to prevent scope creep.
   - **Remediation**: each CR iteration addresses ≥1 action item or explicitly defers with `defer:` rationale per AC6 + RALPH.md iter-353 precedent. Story 1.19 transitions `done` only when QUEUE empties.
2. **Pre-existing 3× `INV-git-hooks-preservation` drifts** persist on `feat/epic-2-packaged-devbox` head (RALPH.md iter-358 gotcha — sync-gate's `git-hook-*` walker hardcodes `<repoRoot>/.git/hooks` which is empty in worktree mode).
   - **Priority**: P2
   - **Probability**: certain (currently present in iter-env; not introduced by Story 1.19; identical posture to Stories 1.17 + 1.18 traces).
   - **Impact**: Low — drifts are advisory (sync-gate is not in `.pre-commit-config.yaml`); fires only on manual `pnpm keel-invariants:check`.
   - **Mitigation**: out of scope per Story 1.18 SC-9 + Story 1.19 SC-9 carve-out ("Address before Story 1.20 close-out").
   - **Remediation**: Story 1.20 fix-task — patch the resolver to honour `core.hooksPath` when set.
3. **`actionlint` deferred** to GH ingestion (post-PR-base-flip-to-main; Story 1.18 trace iter-367 Residual Risk #2 inheritance). Story 1.19's edits do NOT touch `.github/workflows/ci.yml`, so AC scope is unaffected; Residual Risk inherited from Story 1.18 lifecycle, not Story 1.19's.
   - **Priority**: P2
   - **Probability**: Low.
   - **Impact**: None for Story 1.19 (no workflow YAML edits).
   - **Mitigation**: AC inheritance only; not a Story 1.19 deliverable.
   - **Remediation**: Story 1.20 activates FR14i + `INV-fr14i-ci-workflow-presence`; Epic 1 reopen-arc PR's eventual base-flip to `main` triggers first ingestion validation.
4. **12 informational coverage-floor violations from Subtask 10.4** are Story 1.21 backfill candidates (not Story 1.19 blockers).
   - **Priority**: P3
   - **Probability**: certain (already reported per Subtask 10.4 locked carve-out).
   - **Impact**: None for Story 1.19 (carve-out explicitly allows enforcer exit-1 when keel-invariants is GREEN + EXEMPT_LIST recognised).
   - **Mitigation**: SC-6 + locked Subtask 10.4 carve-out; pre-commit/CI invocation deferred to Story 1.21 / Epic 4.
   - **Remediation**: Story 1.21 audit lands the `keel-templates` + `devbox` backfill follow-ups + decides whether to address the other 12 packages.

**Overall Residual Risk:** LOW — all residual signals are bounded + tracked + scheduled.

### Waiver Details

Not applicable — gate decision is PASS (no waiver required).

---

### Gate Recommendations

1. **Proceed to post-dev SM** (`/bmad-create-story (args: "review")`) per IP § QUEUE first item. Forecast 1–4 PATCH (RALPH.md iter-352 narrow-substrate-extension empirical envelope; iter-368 + iter-361 confirmed Story 1.18 + Story 1.17 post-dev SM-verify yielded 4 PATCH at gate within band; Story 1.19 may land at slightly higher end — wider scope per 6 ACs / 11 Tasks vs Story 1.18's 5 ACs / 10 Tasks).
2. **Proceed to CR** (`/bmad-code-review (args: "2")`) after SM-verify completes. Forecast 4–12 PATCH across 4–6 iterations per IP § Notes line 54 + SCP § risk Medium + SC-12 forecast envelope CR row.
3. **Land Story 1.19 close-out** (sprint-status flip + Change Log v1.5+ depending on CR class).
4. **Carry forward to Story 1.20** (FR14i activation) per FR14n state matrix; draft via `/bmad-create-story` from sprint-status next-backlog row after Story 1.19 marked done.

---

### Next Steps

**Immediate Actions**:

1. Record this gate PASS in Story 1.19 § Change Log v1.4.
2. Update IP § Story State `in-dev → traced`; advance NOW to post-dev SM.
3. Update RALPH.md § Signposts with iter-375 trace-PASS entry (1st story-trace PASS in Epic 1 reopen arc; 1st adversarial-backfill-class trace PASS overall).

**Follow-up Actions**:

1. Story 1.20 activates FR14i + addresses pre-existing 3× `INV-git-hooks-preservation` drifts (per Residual Risk #2).
2. Story 1.21 audit lands `keel-templates` + `devbox` coverage backfill follow-ups (per Residual Risk #4).
3. Future SM-validate substrate probes apply the iter-374 ATDD-fixture-validation carry-rule (validate ATDD-authored fixtures against the SAME REGEX/PARSER the impl uses; assertion-by-eyeball-of-impl-comment is insufficient).

---

## Integrated YAML Snippet (CI/CD)

```yaml
traceability_and_gate:
  traceability:
    story_id: '1.19'
    date: '2026-04-26'
    coverage:
      overall: 83%
      p0: 100%
      p1: 100%
      p2: 0%
      p3: n/a
    gaps:
      critical: 0
      high: 0
      medium: 1  # AC6 process-only
      low: 0
    quality:
      passing_tests: 42
      total_tests: 42
      blocker_issues: 0
      warning_issues: 0
    recommendations:
      - 'AC6 process-only gap closes at /bmad-code-review iteration per FR14n sm-verified -> done'
      - 'Story 1.21 audit lands keel-templates + devbox coverage backfill (NFR1a EXEMPT_LIST follow-up)'
      - 'Story 1.21 audit may add adversarial tests for the 7 manifest-reader.ts crypto/fs helpers'

  gate_decision:
    decision: 'PASS'
    gate_type: 'story'
    decision_mode: 'deterministic'
    criteria:
      p0_coverage: 100%
      p0_pass_rate: 100%
      p1_coverage: 100%
      p1_pass_rate: 100%
      overall_pass_rate: 100%
      overall_coverage: 83%
      security_issues: 0
      critical_nfrs_fail: 0
      flaky_tests: 0
    thresholds:
      min_p0_coverage: 100
      min_p0_pass_rate: 100
      min_p1_coverage: 80
      min_p1_pass_rate: 80
      min_overall_pass_rate: 80
      min_coverage: 80
    evidence:
      test_results: 'iter-env Subtask 10.1; vitest 3.2.4 reporter `42 passed` (34 Story-1.19 + 8 inherited) in 873ms'
      traceability: '_bmad-output/test-artifacts/traceability/1-19-backfill-keel-invariants-test-coverage.md'
      nfr_assessment: 'inline (Security + Performance + Reliability + Maintainability all PASS)'
      code_coverage: 'AC-mapped (5/6 FULL via 34 deterministic vitest cases)'
    next_steps: 'Run /bmad-create-story (args: "review") for post-dev SM verification'
```

---

## Related Artifacts

- **Story File:** `_bmad-output/implementation-artifacts/1-19-backfill-keel-invariants-test-coverage.md`
- **Test Design:** none authored separately; ATDD red-phase scaffolds at iter-373 (`/bmad-testarch-atdd`) served as the contract — see ATDD checklist artifact at `_bmad-output/test-artifacts/atdd-checklist-1-19-backfill-keel-invariants-test-coverage.md`
- **Tech Spec:** `_bmad-output/planning-artifacts/architecture.md § M0 substrate developer-productivity floor` (lines 198–240; coverage-floor NFR1a sub-section)
- **Test Results:** `pnpm --filter @keel/keel-invariants test` iter-env GREEN per dev-story v1.3 § Completion Notes (`42 passed in 873ms`)
- **NFR Assessment:** inline (Security + Performance + Reliability + Maintainability all PASS)
- **Test Files (7 NEW + 1 migrated):**
  - `packages/keel-invariants/src/eslint-rules/__tests__/no-verify-bypass.test.ts` (8 tests; AC1)
  - `packages/keel-invariants/src/__tests__/check-no-committed-dotfiles.test.ts` (4 tests; AC2)
  - `packages/keel-invariants/src/__tests__/check-nfr5a-minimum.test.ts` (4 tests; AC2)
  - `packages/keel-invariants/src/__tests__/check-claude-hook-syntax.test.ts` (4 tests; AC2)
  - `packages/keel-invariants/src/__tests__/sync-gate.test.ts` (5 tests; AC3)
  - `packages/keel-invariants/src/__tests__/invariants.manifest.test.ts` (6 tests; AC4)
  - `packages/keel-invariants/src/__tests__/check-package-test-coverage-floor.test.ts` (3 tests; AC5)
  - `packages/keel-invariants/src/prompt-injection-rules/hook-settings-tamper.test.ts` (7 tests; migrated from `node:test` to vitest by Task 1)
- **Sibling Traces:**
  - `_bmad-output/test-artifacts/traceability/1-17-bootstrap-typescript-test-runner-vitest-minimal-ci.md` (Story 1.17 iter-360 trace-WAIVED — TS test-runner bootstrap; coverage-target predecessor)
  - `_bmad-output/test-artifacts/traceability/1-18-bootstrap-python-test-runner-pytest-under-uv.md` (Story 1.18 iter-367 trace-WAIVED — Python test-runner bootstrap)

---

## Sign-Off

**Phase 1 — Traceability Assessment:**

- Overall Coverage: 83% (5/6 FULL; 1/6 PARTIAL — AC6 process-only)
- P0 Coverage: 100% (AC1 ESLint rule FULL; AC2 three enforcers FULL; AC5 NEW enforcer + manifest FULL)
- P1 Coverage: 100% (AC3 sync-gate four drift classes FULL; AC4 Zod schema rejections FULL)
- Critical Gaps: 0
- High Priority Gaps: 0
- Medium Priority Gaps: 1 (AC6 process-only by construction)

**Phase 2 — Gate Decision:**

- **Decision**: PASS ✅
- **P0 Evaluation**: MET (100% coverage, 100% pass rate)
- **P1 Evaluation**: MET (100% coverage, ≥90% target satisfied)
- **Overall Status**: PASS ✅ — 1st story-trace PASS in Epic 1 reopen arc (after Stories 1.17 iter-360 + 1.18 iter-367 trace-WAIVED); 1st adversarial-backfill-class trace PASS overall in the project

**Generated:** 2026-04-26 (iter-375)
**Workflow:** testarch-trace v4.0 (Enhanced with Gate Decision)

---

<!-- Powered by BMAD-CORE™ -->
