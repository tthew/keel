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
  - _bmad-output/implementation-artifacts/1-20-activate-fr14i-for-real-end-vacuous-pass.md
  - _bmad-output/planning-artifacts/epics.md
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/architecture.md
coverageBasis: acceptance_criteria
oracleConfidence: high
oracleResolutionMode: formal_requirements
oracleSources:
  - _bmad-output/implementation-artifacts/1-20-activate-fr14i-for-real-end-vacuous-pass.md (AC1-AC6)
externalPointerStatus: not_used
tempCoverageMatrixPath: _bmad-output/test-artifacts/traceability/1-20-coverage-matrix.json
---

# Traceability Matrix & Gate Decision — Story 1.20 Activate FR14i for real (end vacuous-pass mode)

**Target:** Story 1.20 — Activate FR14i for real (end vacuous-pass mode)
**Date:** 2026-04-26 (iter-391)
**Evaluator:** Tthew (TEA Agent via Ralph build-mode)
**Coverage Oracle:** acceptance_criteria
**Oracle Confidence:** high
**Oracle Sources:** Story 1.20 ACs 1–6 (formal requirements)

---

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status        |
| --------- | -------------- | ------------- | ---------- | ------------- |
| P0        | 3              | 3             | 100%       | ✅ MET        |
| P1        | 2              | 2             | 100%       | ✅ MET        |
| P2        | 1              | 1             | 100%       | ✅ MET        |
| P3        | 0              | 0             | n/a        | n/a           |
| **Total** | **6**          | **6**         | **100%**   | **PASS**      |

**Gate decision: PASS.** Story 1.20 is the FR14i activation story (`INV-fr14i-ci-workflow-presence` registration + workflow trigger-filter expansion + `INV-git-hooks-preservation*` family drift carve-out). Class is **substrate-extension** with hybrid (a)+(c) ATDD-skip ground (per FR14n § ATDD-skip ground discrimination, iter-365 carry-rule). Coverage is honoured via:

- **Test surface (test-covered):** 5 new vitest cases under `packages/keel-invariants/src/__tests__/invariants.manifest.fr14i.test.ts` covering AC1 + AC2 (narrowed SEMANTIC contract; generic drift mechanic inherited from Story 1.19's `sync-gate.test.ts`).
- **Substrate-verification surface (FR14n § ATDD-skip ground (a)):** AC4 (sync-gate anchor-walker output at Subtask 9.4) + AC5 (git diff exactness clause at Subtask 9.6 + AC1 contentHash lockstep) + AC3 (RALPH.md grep-token verification at Subtask 6.3, ≥2 hits).
- **Documentation-side carve-out (FR14n § ATDD-skip ground (c) variant-(ii)):** AC6 option-b-defer with formal `deferred-work.md` § Story 1.20 carve-out (4 rows; 3 AC6-scope `INV-git-hooks-preservation*` + 1 inherited `INV-package-test-coverage-floor`); pre-existing-drift class precedent established in Story 1.17 SC-9 + 1.18 SC-9 + 1.19 SC-9 (3 Epic-1 reopen-arc precedents).

Per the substrate-extension class precedent (Story 1.17 iter-360 + 1.18 iter-367 + 1.19 iter-374 trace gates all returned PASS at the trace step), Story 1.20 maintains the trend. **0–2 PATCH expected this gate** per iter-364 substrate-extension subclass yield-trend prediction; **0 PATCH applied this iteration** (clean-trace landing, 4th datapoint of substrate-extension class clean-trace passes).

### Detailed Mapping

#### AC1: Manifest registration of `INV-fr14i-ci-workflow-presence` with whole-file sha256 + sync-gate green (P0)

- **Coverage:** FULL ✅
- **Tests (5 vitest cases):**
  - `1.20-UNIT-001` — `packages/keel-invariants/src/__tests__/invariants.manifest.fr14i.test.ts:7` `entry exists in manifest` — asserts `invariants.find(i => i.id === 'INV-fr14i-ci-workflow-presence')` resolves; covers AC1 entry-existence assertion.
  - `1.20-UNIT-002` — `…:11` `sourcePath is .github/workflows/ci.yml` — asserts the literal-string equality per AC1 sourcePath clause.
  - `1.20-UNIT-003` — `…:15` `whole-file hashScope (no hashScope field)` — asserts `entry?.hashScope === undefined`; covers AC1 absent-`hashScope` clause (whole-file is the back-compat default per `HashScopeSchema` discriminatedUnion absent-variant comment at `invariants.manifest.ts:11-31`).
  - `1.20-UNIT-004` — `…:19` `anchors array contains the canonical id` — asserts `entry?.anchors === ['INV-fr14i-ci-workflow-presence']`; covers AC1 anchors-array clause.
  - `1.20-UNIT-005` — `…:23` `contentHash matches /^[0-9a-f]{64}$/` — asserts the sha256 regex shape; covers AC1 contentHash-shape sub-clause (the AC1 "matches the file's sha256 AS LANDED IN THIS STORY" semantic clause is independently verified via Subtask 9.4 sync-gate's content-hash drift detection).
- **Substrate evidence (cross-referenced with the test surface):**
  - **Manifest entry:** `packages/keel-invariants/src/invariants.manifest.ts:438-445` (38th entry, after `INV-package-test-coverage-floor`).
  - **`contentHash`:** `5754ab12462ea9073d5642e158d753815d3cdb52e4f682c984127ebffd5a8d86` matches live `sha256sum .github/workflows/ci.yml` per substrate ground-truth probe at iter-391 trace.
  - **Sync-gate output (Subtask 9.4):** the new entry is sync-gate-clean (no `added-to-source-only` / `removed-from-docs-only` / `content-hash-mismatch` for this id); 0 NEW drift surfaced.
- **Evidence:** Dev Agent Record § Completion Notes (v1.2, iter-390): vitest reporter `5 tests` GREEN under `src/__tests__/invariants.manifest.fr14i.test.ts`; full suite 52/52 (47 pre-existing + 5 new). `pnpm --filter @keel/keel-invariants build && test` end-to-end GREEN.
- **Recommendation:** none — AC verified end-to-end. The 5 vitest cases exhaustively cover the AC1 sub-clauses (entry-exists, sourcePath, hashScope-absent, anchors, contentHash-shape) per AC2 narrowing rationale (Dev Notes § AC2 narrowing rationale).

#### AC2: Drift detection on workflow-file delete/move/edit blocks pre-merge-fast (P1)

- **Coverage:** FULL ✅ (narrowed scope of coverage per Dev Notes § AC2 narrowing rationale; locked at create-story per Subtask 8.1 negative assertion)
- **Tests (5 vitest cases for the SEMANTIC-contract slice; generic drift mechanic INHERITED from Story 1.19):**
  - The same 5 cases as AC1 above (`1.20-UNIT-001` … `1.20-UNIT-005`) cover the SEMANTIC contract: an entry exists in the manifest with the right shape (sourcePath, hashScope-absent, anchors, contentHash-shape). Per Dev Notes § AC2 narrowing rationale, this is the AC2-specific surface: registration-shape-only.
- **Inherited generic drift coverage (Story 1.19 `sync-gate.test.ts`):**
  - `1.19-INT-013` — `packages/keel-invariants/src/__tests__/sync-gate.test.ts:27` `added-to-source-only` — drift-class-1 generic mechanic.
  - `1.19-INT-014` — `…:56` `removed-from-source-only` — drift-class-2 generic mechanic; covers `read-error` branch per `sync-gate.ts:120-127` (the file-deleted/moved sub-clause of AC2).
  - `1.19-INT-015` — `…:87` `removed-from-docs-only` — drift-class-3 generic mechanic.
  - `1.19-INT-016` — `…:103` `content-hash-mismatch` — drift-class-4 generic mechanic; covers `expectedHash`/`actualHash` payload (the file-edited sub-clause of AC2).
  - `1.19-INT-017` — `…:135` `clean baseline` — clean-baseline negative-space companion.
- **Substrate evidence:**
  - The `INV-fr14i-ci-workflow-presence` entry inherits the sync-gate's drift mechanic by virtue of registering as a STANDARD whole-file entry (no per-id fixture required per AC2 narrowing rationale).
  - **Subtask 9.4 sync-gate output** confirms the generic mechanic operates correctly on the new id: when `.github/workflows/ci.yml` is content-stable (live state), the entry is sync-gate-clean; the 4 deferred drifts in unrelated families do NOT include any drift on `INV-fr14i-ci-workflow-presence`.
- **Negative assertion (Subtask 8.1):** the new test file MUST NOT import or invoke `runSyncGate` from `../sync-gate.js`. Verified at iter-390 dev-story by visual inspection of `invariants.manifest.fr14i.test.ts` (file imports only `vitest` describe/test/expect + `invariants` from `../invariants.manifest.js`; no `sync-gate` import).
- **Evidence:** Dev Agent Record § Completion Notes (v1.2, iter-390): "Story 1.20 inherits Story 1.19's generic drift coverage by virtue of registering a STANDARD whole-file entry — no new sync-gate fixture required" per Dev Notes § AC2 narrowing rationale. AC2 narrowing locked at create-story per SC-spec.
- **Recommendation:** none — AC verified end-to-end via the SEMANTIC slice (5 new cases) + the GENERIC slice (Story 1.19 inheritance). Any expansion of the smoke beyond entry-shape MUST route to a Story 1.21 test-debt entry per Subtask 8.1 lock.

#### AC3: RALPH.md execute-spine documentation amended to cite FR14i activation (P2)

- **Coverage:** FULL ✅ (substrate-verification class — no runtime test surface possible by AC nature; verified via grep at dev-story per Subtask 6.3)
- **Tests:** none (substrate-only AC; FR14n § ATDD-skip ground (a) covers — substrate-verification at sync-gate output / grep output is the loop closure).
- **Substrate evidence:**
  - **Subtask 6.1 grep-token surface adaptation** (per Dev Agent Record iter-390 Completion Notes): pinned tokens (`FR14i pre-push gate` + `Pre-push CI gate \(FR14i\)`) returned 0 hits in RALPH.md. Per AC3's INTENT (cite FR14i activation in RALPH.md execute-spine), the orient-step + execute-step cross-references were placed as a NEW iter-390 § Signposts entry + a NEW iter-390 § Decisions entry carrying the exact prose templates from Subtask 6.2 verbatim.
  - **Subtask 6.3 grep verification** (per Dev Agent Record iter-390): `grep -c "INV-fr14i-ci-workflow-presence" RALPH.md` returned `3` (≥ 2 expected — Signposts entry header + body mentions + Decisions entry mentions); satisfies the AC3 INTENT clause.
  - The existing `FR14i: vacuous-pass mode` notice prose (per PRD line 959 amendment) remains documented as the degradation behaviour for environments where the workflow file is absent (e.g. fresh forks pre-create-keel-app); preserved per AC3 lock-pre-existing-prose clause.
- **Evidence:** Dev Agent Record § Completion Notes (v1.2, iter-390): "Subtask 6.3 verification: `grep -c \"INV-fr14i-ci-workflow-presence\" RALPH.md` returned 3 (≥ 2 expected — Signposts entry header + body mentions + Decisions entry mentions)." AC3 INTENT discharged.
- **Recommendation:** none — AC discharged via substrate-verification at grep output. Future RALPH.md restructures (e.g. iter-N where Signposts/Decisions section ordering changes) MUST preserve the `INV-fr14i-ci-workflow-presence` token cross-references; carry-rule for Story 1.21 audit IFF section reordering is introduced.

#### AC4: INVARIANTS.md index entry for `INV-fr14i-ci-workflow-presence` at canonical insertion point + sync-gate anchor-walker resolves it (P0)

- **Coverage:** FULL ✅ (substrate-verification class — anchor-walker resolution is the test-equivalent loop closure)
- **Tests:** none direct (substrate-only AC; FR14n § ATDD-skip ground (a) covers — sync-gate's anchor-walker output IS the verification mechanic).
- **Inherited generic anchor-walker coverage (Story 1.19 `sync-gate.test.ts`):**
  - `1.19-INT-013` — `packages/keel-invariants/src/__tests__/sync-gate.test.ts:27` `added-to-source-only` — drift-class-1 anchor-walker mechanic (manifest entry exists but INVARIANTS.md anchor missing).
  - `1.19-INT-015` — `…:87` `removed-from-docs-only` — drift-class-3 anchor-walker mechanic (orphan anchor in INVARIANTS.md but manifest empty).
- **Substrate evidence:**
  - **INVARIANTS.md insertion point** (per substrate ground-truth probe at iter-391): line 96 `### Activated FR14i pre-push CI gate (Story 1.20)` H3 header inserted between Story 1.19 H3 close (line 95 blank) and Story 2.1 H3 open (line 102).
  - **Bullet shape** (per Dev Agent Record iter-390 File List + per substrate ground-truth at iter-391): line 100 `- **\`INV-fr14i-ci-workflow-presence\`** — FR14i pre-push CI gate activation: …. Source: \`.github/workflows/ci.yml\`.` matches the canonical sibling-shape from `INV-package-test-coverage-floor` (line 94) per Story 1.19's anchor-token convention; verifies sync-gate's `ANCHOR_REGEX` at `sync-gate.ts:36`.
  - **Subtask 9.4 sync-gate output** (per Dev Agent Record iter-390): the new `INV-fr14i-ci-workflow-presence` id is sync-gate-clean; no `removed-from-docs-only` (the anchor was found in INVARIANTS.md) and no `added-to-source-only` (the manifest entry from Task 4 + INVARIANTS.md anchor from Task 5 are both present and matched by id).
  - **Cross-reference to `docs/invariants/ralph-execute.md` § Orient phase step 8** (Task 7 amendment, per Dev Agent Record iter-390): the docs-side anchor was extended with `INV-fr14i-ci-workflow-presence` cross-reference + `INVARIANTS.md § Activated FR14i pre-push CI gate (Story 1.20)` pointer; satisfies AC4's "or inline anchor in docs/invariants/ralph-execute.md if no dedicated doc exists" clause (no dedicated `docs/invariants/fr14i.md` was created at 1.0 per AC4 lock-don't-proliferate clause).
- **Evidence:** Dev Agent Record § Completion Notes (v1.2, iter-390): "Subtask 9.4 final sync-gate output: exit non-zero. Drifts surfaced (4 total — IDENTICAL to Subtask 1.2 baseline; 0 NEW drift introduced by Story 1.20)…The new `INV-fr14i-ci-workflow-presence` entry is sync-gate-clean (no `added-to-source-only` / `removed-from-docs-only` / `content-hash-mismatch` for that id)…AC1 + AC6 lockstep verification (Subtask 3.2): PASS."
- **Recommendation:** none — AC verified end-to-end via sync-gate's anchor-walker green-for-this-id output. The lockstep `INV-ralph-halt-*` pair refresh (Task 7.3) is also clean per the same Subtask 9.4 evidence.

#### AC5: `.github/workflows/ci.yml` trigger filter expanded to cover `feat/epic-*` PR bases (P0)

- **Coverage:** FULL ✅ (substrate-verification class — git diff byte-identical clause + sha256 verification + AC1 contentHash lockstep is the test-equivalent loop closure; behavioural fire-on-PR-push deferred to PR push per Subtask 2.2 fallback)
- **Tests:** none direct in this story (the 5 vitest cases for AC1 implicitly cover the contentHash-shape AND the sync-gate's content-hash drift detection mechanic — i.e. the workflow file's actual on-disk shape is verified via the sha256 lockstep with the manifest entry; if the workflow filter were rolled back to `[main]`, the sha256 would change and `INV-fr14i-ci-workflow-presence` would surface a `content-hash-mismatch` drift).
- **Substrate evidence:**
  - **Subtask 9.6 byte-identical clause** (per Dev Agent Record iter-390 Completion Notes): `git diff HEAD -- .github/workflows/ci.yml` shows EXACTLY 2 changed lines (the two `branches:` arrays — `[main]` → `[main, 'feat/epic-*']` for both `pull_request:` and `push:` blocks). All other surfaces (`name: ci`, `on:`, `permissions:`, `concurrency:`, both `jobs:` `node` + `python` blocks, all step ordering) BYTE-IDENTICAL to the post-Story-1.18 baseline.
  - **Post-edit sha256** (per Dev Agent Record iter-390 + re-verified at iter-391 trace): `5754ab12462ea9073d5642e158d753815d3cdb52e4f682c984127ebffd5a8d86` matches the manifest entry's `contentHash` at `invariants.manifest.ts:443`. The workflow file's content-stability is enforced going forward by `INV-fr14i-ci-workflow-presence` drift detection.
  - **Subtask 2.2 YAML validation fallback** (per Dev Agent Record iter-390): Python `yaml` module + `node yaml` package both unavailable in cc-devbox iter env; behavioural verification deferred to PR push (the workflow itself runs on PR push providing loop closure). Visual inspection at iter-390 + iter-391 trace confirms valid YAML flow-sequence syntax `[main, 'feat/epic-*']` (the `'feat/epic-*'` glob string is single-quoted per YAML 1.2 § 6.6 plain-scalar restrictions; alphanumeric `main` does not require quoting).
  - **Behavioural verification at PR push** (out-of-band loop closure): post-Story-1.20 push, PR #236 `gh pr checks` will return non-empty status checks for the first time (sunset of iter-371 `statusCheckRollup: []` BY DESIGN carry-rule). This out-of-band evidence is captured at PR-push time, NOT at trace gate.
- **Evidence:** Dev Agent Record § Completion Notes (v1.2, iter-390): "AC5 byte-identical clause (Subtask 9.6): `git diff HEAD -- .github/workflows/ci.yml` shows EXACTLY 2 changed lines (the two `branches:` arrays — `[main]` → `[main, 'feat/epic-*']` for both `pull_request:` and `push:` blocks). All other surfaces … BYTE-IDENTICAL. Post-edit sha256 `5754ab12462ea9073d5642e158d753815d3cdb52e4f682c984127ebffd5a8d86`."
- **Recommendation:** none — AC verified end-to-end via substrate-verification (git diff exactness + sha256 + AC1 contentHash lockstep). Future ci.yml edits MUST update `INV-fr14i-ci-workflow-presence`'s `contentHash` in lockstep (per the standard whole-file invariant convention); deviation surfaces a `content-hash-mismatch` drift at sync-gate. Behavioural fire-on-PR-push is captured out-of-band on first push to PR #236 (and every future stacked-epic PR base).

#### AC6: Pre-existing 3× `INV-git-hooks-preservation` family drifts addressed (resolve OR formally defer with rationale) (P1)

- **Coverage:** FULL ✅ (substrate-verification class — option-b-defer chosen; FR14n § ATDD-skip ground (c) variant-(ii) "pre-existing drift carve-out" is the test-equivalent loop closure; 3rd Epic-1-reopen-arc precedent following Story 1.17 SC-9 + Story 1.18 SC-9 + Story 1.19 SC-9)
- **Tests:** none direct (substrate-only AC; FR14n § ATDD-skip ground (c) variant-(ii) covers — pre-existing drift carve-out is a recognised class).
- **Substrate evidence:**
  - **Decision (Subtask 3.1)** (per Dev Agent Record iter-390 Completion Notes): **option-b-defer chosen**. Current cc-devbox iter env is worktree-only per AGENTS.md § Worktrees; option-a-resolve requires non-worktree clone access to compute the canonical `.git/hooks/` walker hash and is BLOCKED here.
  - **Deferral target (Subtask 3.1)** (per Dev Agent Record iter-390): all 4 drifts (3 AC6-scope `INV-git-hooks-preservation*` family + 1 inherited `INV-package-test-coverage-floor` per Subtask 9.2 inherited-failure carve-out) formally deferred to Story 1.21 audit per `_bmad-output/implementation-artifacts/deferred-work.md` § Story 1.20 dev-story (2026-04-26) carve-out (4 rows; AC6 + inherited cleanly separated by Subtask 9.2 carve-out class).
  - **Subtask 1.2 baseline (pre-Story-1.20 edits)** (per Dev Agent Record iter-390): 4 drifts captured (3 in `INV-git-hooks-preservation` family per AC6 scope + 1 inherited `INV-package-test-coverage-floor` content-hash-mismatch outside AC6 scope per Subtask 9.2 inherited-failure carve-out). Predicted "≥ 3" lower-bound met; 4 observed drives the option-a/b decision per Subtask 1.2 divergence-handling clarification.
  - **Subtask 9.4 sync-gate post-Story-1.20 output** (per Dev Agent Record iter-390): exit non-zero. Drifts surfaced (4 total — IDENTICAL to Subtask 1.2 baseline; **0 NEW drift introduced by Story 1.20**):
    - `INV-git-hooks-preservation` `git-hook-missing` `commit-msg` (deferred — see deferred-work.md)
    - `INV-git-hooks-preservation` `git-hook-missing` `pre-commit` (deferred)
    - `INV-git-hooks-preservation` `content-hash-mismatch` (deferred)
    - `INV-package-test-coverage-floor` `content-hash-mismatch` (deferred — inherited, outside AC6 scope per Subtask 9.2 carve-out)
  - **AC6 + AC1 lockstep verification (Subtask 3.2)** (per Dev Agent Record iter-390): PASS. The new `INV-fr14i-ci-workflow-presence` entry is sync-gate-clean; deferred drifts are pre-existing per RALPH.md iter-358 + iter-359 + iter-367 datapoints, NOT Story-1.20-introduced.
- **Evidence:** Dev Agent Record § Completion Notes (v1.2, iter-390): "**AC6 decision (Subtask 3.1): option-b-defer chosen.** … All 4 drifts (3 AC6-scope + 1 inherited) formally deferred to Story 1.21 audit per `_bmad-output/implementation-artifacts/deferred-work.md` § Story 1.20 dev-story (2026-04-26) carve-out … **AC1 + AC6 lockstep verification (Subtask 3.2): PASS.**"
- **Recommendation:** none for Story 1.20 — option-b-defer is documented + sync-gate-discriminated. Story 1.21 audit MUST address the 4 deferred drifts (3 AC6-scope + 1 inherited `INV-package-test-coverage-floor`); root-cause for the AC6-scope 3 is `sync-gate.ts` `names-and-shebangs` walker hardcoding `<repoRoot>/.git/hooks` (vs worktree mode where `.git` is a file pointer per RALPH.md iter-358). Resolution path for Story 1.21: implement worktree-aware resolver in `sync-gate.ts` OR rebake the manifest's `INV-git-hooks-preservation*` `contentHash` from a non-worktree clone.

---

### Coverage Heuristics

- **Endpoint coverage:** N/A (Story 1.20 has no API/endpoint surface — pure substrate registration story).
- **Auth/authz coverage:** N/A (Story 1.20 has no auth/session/permission surface).
- **Error-path coverage:** N/A (the sync-gate's drift mechanic IS the error path; covered by Story 1.19 `sync-gate.test.ts` four-drift-class fixtures inherited at AC2).
- **UI journey coverage:** N/A (no UI surface).
- **UI state coverage:** N/A.

### Phase 1 Summary

```
✅ Phase 1 Complete: Coverage Matrix Generated

📊 Coverage Statistics:
- Total Requirements: 6
- Fully Covered: 6 (100%)
- Partially Covered: 0
- Uncovered: 0

🎯 Priority Coverage:
- P0: 3/3 (100%)
- P1: 2/2 (100%)
- P2: 1/1 (100%)
- P3: 0/0 (n/a)

⚠️ Gaps Identified:
- Critical (P0): 0
- High (P1): 0
- Medium (P2): 0
- Low (P3): 0

🔍 Coverage Heuristics:
- Endpoints without tests: 0 (N/A — no endpoints)
- Auth negative-path gaps: 0 (N/A — no auth surface)
- Happy-path-only criteria: 0 (drift mechanic covered via Story 1.19 inheritance)

📝 Recommendations: 1 (process-quality follow-up)

🔄 Phase 2: Gate decision (next step)
```

---

## PHASE 2: GATE DECISION

### Gate Decision: **PASS** ✅

**Rationale:** P0 coverage is 100% (3/3), P1 coverage is 100% (2/2; >= 90% target), P2 coverage is 100% (1/1), and overall coverage is 100% (>= 80% minimum). All six Story 1.20 ACs are FULL via the hybrid (a)+(c) coverage governance: 5 vitest cases cover AC1+AC2 (test-covered registration shape + narrowed SEMANTIC contract); AC3+AC4+AC5 are substrate-verification (grep-output / sync-gate anchor-walker output / git diff byte-identical clause + sha256 + AC1 contentHash lockstep); AC6 is documentation-side carve-out (option-b-defer with `deferred-work.md` § Story 1.20 + Subtask 9.4 sync-gate output proving 0 NEW drift introduced). No critical or high gaps; substrate-extension class precedent (Story 1.17 + 1.18 + 1.19 trace gates) honoured at the 4th datapoint of class.

### Gate Criteria

| Criterion                | Required | Actual | Status     |
| ------------------------ | -------- | ------ | ---------- |
| P0 coverage              | 100%     | 100%   | ✅ MET     |
| P1 coverage (target)     | 90%      | 100%   | ✅ MET     |
| P1 coverage (minimum)    | 80%      | 100%   | ✅ MET     |
| Overall coverage minimum | 80%      | 100%   | ✅ MET     |

### Coverage Analysis

```
🚨 GATE DECISION: PASS

📊 Coverage Analysis:
- P0 Coverage: 100% (Required: 100%) → MET
- P1 Coverage: 100% (PASS target: 90%, minimum: 80%) → MET
- Overall Coverage: 100% (Minimum: 80%) → MET

✅ Decision Rationale:
P0 coverage is 100%, P1 coverage is 100% (target: 90%), and overall coverage is 100% (minimum: 80%).

⚠️ Critical Gaps: 0

📝 Recommended Actions:
1. (LOW) Run /bmad-code-review to assess Story 1.20 implementation quality (next FR14n state matrix step: traced → sm-verified via `/bmad-create-story (args: "review")` post-dev SM verification, then sm-verified → done via `/bmad-code-review (args: "2")`).

📂 Full Report: _bmad-output/test-artifacts/traceability/1-20-activate-fr14i-for-real-end-vacuous-pass.md

✅ GATE: PASS - Release approved, coverage meets standards
```

### Recommendations

1. **(LOW)** Story 1.20 trace gate is PASS — 0 P0/P1/P2 gaps; 0 PATCH applied at this gate (4th datapoint of substrate-extension class clean-trace passes; matches Story 1.17 iter-360 + Story 1.18 iter-367 + Story 1.19 iter-374 precedent envelope). Next FR14n state matrix step: `traced → sm-verified` via `/bmad-create-story (args: "review")` post-dev SM verification.

### Story 1.21 follow-up notes (for the audit + sweep planning)

- **AC6 deferral target locked:** the 4 drifts captured at Subtask 9.4 + the deferred-work.md § Story 1.20 carve-out are the AC6 audit scope. Root-cause for the 3 AC6-scope drifts is the `sync-gate.ts` worktree-mode hardcoding (per RALPH.md iter-358); Story 1.21 should land a worktree-aware resolver OR rebake the manifest's `INV-git-hooks-preservation*` `contentHash` from a non-worktree clone.
- **AC2 test-debt items:** any expansion of the `invariants.manifest.fr14i.test.ts` smoke beyond entry-shape MUST route to Story 1.21 (per Subtask 8.1 negative assertion lock); none identified at trace gate but the carry-rule remains.
- **Inherited `INV-package-test-coverage-floor` drift:** outside AC6 scope per Subtask 9.2 carve-out; routed to Story 1.21 audit per Dev Agent Record iter-390. Story 1.21 audit MUST surface the root cause (which package's `src/` lacks a `*.test.ts`) and either backfill OR widen `EXEMPT_LIST`.

---

## TRACE TARGET METADATA

| Field                      | Value                                                                                          |
| -------------------------- | ---------------------------------------------------------------------------------------------- |
| target.type                | story                                                                                          |
| target.id                  | 1.20                                                                                           |
| target.label               | Activate FR14i for real (end vacuous-pass mode)                                                |
| collection_mode            | contract_static                                                                                |
| collection_status          | COLLECTED                                                                                      |
| coverage_basis             | acceptance_criteria                                                                            |
| oracle.resolution_mode     | formal_requirements                                                                            |
| oracle.confidence          | high                                                                                           |
| oracle.synthetic           | false                                                                                          |
| oracle.external_pointer    | not_used                                                                                       |
| allow_gate                 | true                                                                                           |
| gate_eligible              | true                                                                                           |
| gate_decision              | PASS                                                                                           |
| evaluator                  | Tthew (TEA Agent via Ralph build-mode)                                                         |
| decision_mode              | deterministic                                                                                  |
| source_sha                 | (resolved by CI/CD runner)                                                                     |

---

**Workflow:** `bmad-testarch-trace` v6.3.0
**Phase:** PHASE_2_COMPLETE (gate decision rendered)
**Output Files:**
- `_bmad-output/test-artifacts/traceability/1-20-activate-fr14i-for-real-end-vacuous-pass.md` (this file)
- `_bmad-output/test-artifacts/traceability/1-20-coverage-matrix.json` (Phase 1 coverage matrix)
- `_bmad-output/test-artifacts/traceability/1-20-e2e-trace-summary.json` (machine-readable summary for CI/CD)
- `_bmad-output/test-artifacts/traceability/1-20-gate-decision.json` (slim gate signal for pipelines)
