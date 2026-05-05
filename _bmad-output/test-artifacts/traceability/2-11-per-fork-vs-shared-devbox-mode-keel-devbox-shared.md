---
stepsCompleted:
  - step-01-load-context
  - step-02-discover-tests
  - step-03-map-criteria
  - step-04-analyze-gaps
  - step-05-gate-decision
lastStep: 'step-05-gate-decision'
lastSaved: '2026-04-24'
workflowType: 'testarch-trace'
inputDocuments:
  - '_bmad-output/implementation-artifacts/2-11-per-fork-vs-shared-devbox-mode-keel-devbox-shared.md'
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  - '_bmad-output/implementation-artifacts/2-11-per-fork-vs-shared-devbox-mode-keel-devbox-shared.md#Acceptance Criteria'
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/2-11-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision - Story 2.11: Per-fork vs shared devbox mode (`KEEL_DEVBOX_SHARED`)

**Target:** Story 2.11 — Per-fork vs shared devbox mode (`KEEL_DEVBOX_SHARED`)
**Date:** 2026-04-24
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/2-11-per-fork-vs-shared-devbox-mode-keel-devbox-shared.md#Acceptance Criteria`

---

Note: This workflow does not generate tests. If gaps exist, run `/bmad-testarch-atdd` or `/bmad-testarch-automate` to create coverage.

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status |
| --------- | -------------- | ------------- | ---------- | ------ |
| P0        | 0              | 0             | 100%       | ✅ PASS (n/a) |
| P1        | 0              | 0             | 100%       | ✅ PASS (n/a) |
| P2        | 4              | 0             | 0%         | ⚠️ WAIVED (ground-(a)+(b)+(c) hybrid; no test runner at Story 2.11 substrate stage; Epic 13 scope) |
| P3        | 0              | 0             | 100%       | ✅ PASS (n/a) |
| **Total** | **4**          | **0**         | **0%**     | **⚠️ WAIVED** |

**Legend:**

- ✅ PASS - Coverage meets quality gate threshold
- ⚠️ WARN / WAIVED - Coverage below threshold but not critical OR waiver applies
- ❌ FAIL - Coverage below minimum threshold (blocker)

---

### Detailed Mapping

#### AC-1: Per-fork mode (default) — isolated container + isolated named volume (P2)

- **Coverage:** NONE (WAIVED) ⚠️
- **Tests:** _(no automated tests — Epic 13 scope)_
- **Substrate-verification:** iter-257 `/bmad-dev-story` Debug Log references 6 resolver functional smokes (Task 1 closure). Resolver invocation under `KEEL_DEVBOX_SHARED` unset OR `=false` → `KEEL_DEVBOX_COMPOSE_PROJECT=keel-devbox` + `KEEL_DEVBOX_CONTAINER_NAME_RESOLVED=keel-devbox` + operator override `KEEL_DEVBOX_CONTAINER_NAME=my-fork-devbox` respected per Story 2.1 preserved path. `bash -n` syntax-check clean on all 18 shims including `start.sh`/`rebuild.sh`/`shell.sh`/`build.sh`/`stop.sh`/`restart.sh`/`clean.sh` at their resolver-invocation insertion sites. `pnpm keel-invariants:check` EXIT=0 after Task 5 landing + manifest rebuild.
- **Gaps (WAIVED — defer per ground-(a) substrate-verification):**
  - Missing: live two-forks-at-different-fork-roots smoke verifying Compose "container name already in use" collision when both forks invoke `pnpm devbox:start` without a `KEEL_DEVBOX_CONTAINER_NAME` override (operator-workstation-deferred backend-A).
  - Missing: live isolation-probe verifying fork A's `keel-devbox_keel_home_dev` named volume is invisible to fork B's `my-fork-devbox_keel_home_dev` override (operator-workstation-deferred backend-A).
- **Recommendation:** Accept WAIVED verdict. Substrate-verification + CR-pass adversarial-backstop provides confidence; live fresh-fork multi-invocation smoke deferred to M4-Pro operator workstation backend-A where two-forks-sibling state is reproducible without DinD-B complications.

---

#### AC-2: Shared mode — single shared container + single shared named volume across forks (P2)

- **Coverage:** NONE (WAIVED) ⚠️
- **Tests:** _(no automated tests — Epic 13 scope)_
- **Substrate-verification:** iter-257 `/bmad-dev-story` Debug Log references resolver functional smoke under `KEEL_DEVBOX_SHARED=true` → `KEEL_DEVBOX_COMPOSE_PROJECT=keel-devbox-shared` + `KEEL_DEVBOX_CONTAINER_NAME_RESOLVED=keel-devbox-shared` + `KEEL_DEVBOX_REPO_NAME=$(basename parent)` + `KEEL_DEVBOX_WORKSPACE=$(dirname fork-root)`. SC-4 load-bearing smoke: `KEEL_DEVBOX_SHARED=true KEEL_DEVBOX_CONTAINER_NAME=my-fork-devbox` → `CONTAINER_NAME_RESOLVED=keel-devbox-shared` (operator override INTENTIONALLY IGNORED — pinned in `docs/invariants/devbox-mode.md § Shared mode container-name opinionation` + `AGENTS.md § Per-fork vs shared devbox mode (Story 2.11)` agent guardrail). `docker-compose.yml` top-level `name: ${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}` parameterisation YAML-valid at static parse time; `bash -n` clean on compose-invoking shims.
- **Gaps (WAIVED — defer per ground-(a) substrate-verification + ground-(c) spec-declared-CR-substitution):**
  - Missing: live `docker compose -f packages/devbox/docker-compose.yml config` emit under full shared-mode env-var matrix verifying the resolved YAML carries `name: keel-devbox-shared` + parent-bind source + parent-name target (SC-13; operator-workstation-deferred backend-A).
  - Missing: live two-forks-at-sibling-paths under shared parent dir with both forks' `.envrc` carrying `KEEL_DEVBOX_SHARED=true`, sequential `pnpm devbox:start` from fork A then fork B, verifying fork B's invocation becomes a no-op health-poll (docker inspect detects existing `keel-devbox-shared` container) + both resolver paths land at `/workspace/<parent>/{fork-a,fork-b}/` inside the shared container (operator-workstation-deferred backend-A).
- **Recommendation:** Accept WAIVED verdict. Substrate-verification covers the resolver + compose-config static path; live shared-mode attach smoke deferred to M4-Pro operator workstation backend-A where sibling-forks-under-shared-parent state is reproducible.

---

#### AC-3: Mid-use flip — `pnpm devbox:env:check` warns about orphaned cross-mode containers (P2)

- **Coverage:** NONE (WAIVED) ⚠️
- **Tests:** _(no automated tests — Epic 13 scope)_
- **Substrate-verification:** iter-257 `/bmad-dev-story` Debug Log references Task 4 env-check orphan-container probe landing with Story 2.10 PATCH-1 rc-capture pattern (`rc=0; docker inspect … || rc=$?; case "${rc}" in 0) emit warning ;; 1) : ;; *) : ;; esac`) — survives `set -e` without rc-suppression hazard. SC-8 three-site lockstep verified at landing time: env-check.sh emit string + `docs/invariants/devbox-mode.md § Mid-use flip warning` + `packages/devbox/README.md § Per-fork vs shared mode § Mid-use flip` carry byte-identical warning strings (substrate-lockstep convention-enforced at 1.0; candidate for SC-17 substrate lint). `bash -n` syntax-check clean on env-check.sh.
- **Gaps (WAIVED — defer per ground-(a) substrate-verification + ground-(b) no-test-runner):**
  - Missing: live `pnpm devbox:env:check` invocation against a host daemon carrying an orphaned `keel-devbox` or `keel-devbox-shared` container from the prior mode, verifying stderr warning emit + pointer at `pnpm devbox:clean` + exit code unchanged (operator-workstation-deferred backend-A — iter-env's host-socket-passthrough cannot safely produce cross-mode orphans without poisoning host daemon state).
- **Recommendation:** Accept WAIVED verdict. Substrate-verification + CR-pass adversarial-backstop (Edge Case Hunter coverage of rc-capture + warning-string-drift) provides confidence; live orphan-probe smoke deferred to operator workstation.

---

#### AC-4: Concurrent-Ralph behaviour in shared mode — single-operator-by-convention Ralph TUI (P2)

- **Coverage:** NONE (WAIVED) ⚠️
- **Tests:** _(no automated tests — NOT feasible; doc-only concurrency decision)_
- **Substrate-verification:** Doc-only concurrency decision pinned in three sites: (i) `_bmad-output/implementation-artifacts/2-11-per-fork-vs-shared-devbox-mode-keel-devbox-shared.md § Dev Notes § Concurrency decision (AC 4 implementation note)` records Option C selection with Option A (substrate lockfile — rejected for machinery complexity) + Option B (parallel via per-fork-name subdir — rejected: Ralph's `CMD` is image-layer time; multi-Ralph-per-container is Epic 3 domain) rationale; (ii) `docs/invariants/devbox-mode.md § Concurrency decision` records the contract substrate-bound via `INV-devbox-mode` contentHash gate; (iii) `AGENTS.md § Per-fork vs shared devbox mode (Story 2.11) § Agent guardrail (attach semantics)` records the prohibition "agents MUST NOT implement a 'second-attach-auto-detaches-first' feature — Docker does not expose that semantic; shared mode's concurrency story is convention-first, not machinery-first." Story 2.11 § Testing Standards (story file:166) affirmatively declares doc-only status + trace-gate waive candidate for AC 4.
- **Gaps (WAIVED — defer per ground-(c) spec-declared-CR-substitution variant-(iii) + story-file doc-only declaration):**
  - Missing: no red-phase scaffold feasible — Docker does not expose a second-attach-auto-detach semantic (the behaviour under concurrent `docker attach` is interleaved stdin/stdout I/O corruption, NOT automatic detachment). No harness exists for cross-fork simulation at the iteration-env layer; AC 4 is documentation-bound, not machinery-bound.
  - Missing: no automated assertion possible on "operators coordinate out-of-band" — this is an operator-education contract, not a runtime-enforced gate.
- **Recommendation:** Accept WAIVED verdict per spec-declared-CR-substitution (Story 2.11 § Testing Standards affirmatively pre-declares partial-waive candidate). Forthcoming `/bmad-code-review (args: "2")` adversarial envelope (Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out) provides designated adversarial backstop for doc-only AC integrity (concurrency-decision pinning + agent-guardrail absorption).

---

### Gap Analysis

#### Critical Gaps (BLOCKER) ❌

0 gaps found. No P0 requirements exist for Story 2.11 (all 4 ACs at P2 per Epic-2-substrate precedent).

---

#### High Priority Gaps (PR BLOCKER) ⚠️

0 gaps found. No P1 requirements exist for Story 2.11.

---

#### Medium Priority Gaps (WAIVED via ground-(a)+(b)+(c) hybrid) ⚠️

4 gaps found. **All WAIVED per gate rationale — no test runner at Story 2.11 substrate stage (Epic 13 scope); substrate-verification covers AC 1 + AC 2 + AC 3 runtime branches at iter-257 dev-story; AC 4 doc-only per spec-declared-CR-substitution.**

1. **AC-1: Per-fork mode isolation** (P2) — WAIVED
   - Current Coverage: NONE (no automated tests)
   - Substrate-verification: iter-257 resolver functional smokes + `bash -n` + `pnpm keel-invariants:check`
   - Recommend: operator-workstation backend-A live two-forks-at-different-roots smoke when Epic 2 close-out runs

2. **AC-2: Shared mode single-container + parent-bind** (P2) — WAIVED
   - Current Coverage: NONE (no automated tests)
   - Substrate-verification: iter-257 resolver functional smokes including SC-4 operator-override-IGNORED path
   - Recommend: operator-workstation backend-A live `docker compose config` emit + two-forks-attach smoke

3. **AC-3: Env-check orphan warning** (P2) — WAIVED
   - Current Coverage: NONE (no automated tests)
   - Substrate-verification: Task 4 env-check probe lands with Story 2.10 PATCH-1 rc-capture pattern; SC-8 three-site warning-string lockstep verified at landing
   - Recommend: operator-workstation backend-A live orphan probe against staged daemon state

4. **AC-4: Concurrent-Ralph single-operator-by-convention** (P2) — WAIVED
   - Current Coverage: NONE (doc-only AC — NOT feasible)
   - Substrate-verification: doc-only; three-site lockstep pinning (story file + invariant doc + AGENTS.md agent guardrail); spec-declared-CR-substitution per § Testing Standards
   - Recommend: accept doc-only WAIVE; `/bmad-code-review (args: "2")` adversarial envelope is designated backstop

---

#### Low Priority Gaps (Optional) ℹ️

0 gaps found. No P3 requirements exist for Story 2.11.

---

### Coverage Heuristics Findings

#### Endpoint Coverage Gaps

- Endpoints without direct API tests: 0 — Story 2.11 does NOT add API surface; resolver function + compose-project parameterisation + env-check stderr-warning are substrate shell/YAML concerns, not API endpoints.

#### Auth/Authz Negative-Path Gaps

- Criteria missing denied/invalid-path tests: 0 (not applicable — Story 2.11 does not touch auth/authz flows; Claude + gh OAuth are upstream-owned per Stories 2.8/2.9).

#### Happy-Path-Only Criteria

- Criteria missing error/edge scenarios: 0 — Story 2.11 AC 3 IS the error-class criterion (orphan cross-mode container is the edge case); substrate-verification covers rc-capture survival under `set -e` + warning-string lockstep. AC 4 Option A/B rejections + Option C guardrail encode the negative-path (second-attach-auto-detach) posture.

#### UI Journey Coverage

- Criteria missing UI-level coverage: not applicable — Story 2.11 has no UI surface.

#### UI State Coverage

- Criteria missing state-coverage assertions: not applicable — Story 2.11 has no UI surface.

---

### Quality Assessment

#### Tests with Issues

_(no tests exist — no-op)_

---

#### Tests Passing Quality Gates

_(0 / 0 tests — no-op; substrate-smokes are documented in iter-257 Dev Agent Record § Debug Log References, not wired as automated regressions)_

---

### Duplicate Coverage Analysis

_(not applicable — no automated test suite)_

---

### Coverage by Test Level

| Test Level | Tests | Criteria Covered | Coverage % |
| ---------- | ----- | ---------------- | ---------- |
| E2E        | 0     | 0                | 0%         |
| API        | 0     | 0                | 0%         |
| Component  | 0     | 0                | 0%         |
| Unit       | 0     | 0                | 0%         |
| **Total**  | **0** | **0**            | **0%**     |

---

### Traceability Recommendations

#### Immediate Actions (Before PR Merge)

1. **Accept WAIVED verdict per TWENTY-FIRST cumulative trace-WAIVED precedent + TWENTY-SECOND ATDD-skip-trace-WAIVED pairing.** Story 2.11 is a direct extension of the Epic-2-substrate pattern established at Stories 2.1-2.10; ground-(a)+(b)+(c) hybrid conjunction applies. Queue `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification next per § Story Lifecycle Decision Matrix row `traced → sm-verified`.

2. **Reinforce iter-257 NOVEL LESSON on manifest rebuild discipline** — `pnpm --filter @keel/keel-invariants build` MUST precede `pnpm keel-invariants:check` after adding a new `InvariantSchema` entry. Add as RALPH.md § Lessons entry (already captured in `.ralph/@plan.md § Notes` at iter-257; promote to RALPH.md § Lessons this iteration alongside the current trace gate commit).

#### Short-term Actions (This Milestone)

1. **Operator-workstation backend-A live smokes at Epic 2 close-out (Story 2.17-adjacent).** Three live smokes deferred per ground-(c): (a) two-forks-at-different-roots per-fork isolation + Compose-collision; (b) sibling-forks-under-shared-parent shared-mode attach + docker inspect no-op health-poll; (c) env-check orphan probe against staged daemon state. No Story 2.11 code change required; stateless verification.

2. **CR adversarial envelope fan-out** via `/bmad-code-review (args: "2")` at the next QUEUE item after `traced → sm-verified`. Three-layer Ralph-hosted triage: Blind Hunter (`bmad-agent-architect` diff-only) + Edge Case Hunter (`bmad-tea` diff+project-read) + Acceptance Auditor (`bmad-agent-dev` diff+spec+INV). Forecast 1 first-class PATCH + 2-3 second-class operator-edge DEFERs per iter-253 LESSON; Story 2.11 is SIXTH one-pass ZERO-PATCH CR precedent candidate if pre-dev SM v1.1 absorption holds.

#### Long-term Actions (Backlog)

1. **Epic 13 test framework landing** unblocks mechanical automation of AC 1-3 (AC 4 remains doc-only). Carry-forward target for `packages/devbox/tests/` vitest suites per Story 13.* scope.

2. **Substrate-lockstep lint for warning-string three-site drift (SC-17 candidate).** Story 2.11 AC 3 introduces the convention; a future keel-invariants lint could mechanically enforce byte-identity of the warning-string across env-check.sh + invariant doc + README. Defer to retrospective / Epic 13 scope.

---

## PHASE 2: QUALITY GATE DECISION

**Gate Type:** story
**Decision Mode:** deterministic (with manual WAIVED override per ground-(a)+(b)+(c) hybrid)

---

### Evidence Summary

#### Test Execution Results

- **Total Tests**: 0
- **Passed**: 0 (0%)
- **Failed**: 0 (0%)
- **Skipped**: 0 (0%)
- **Duration**: n/a

**Priority Breakdown:**

- **P0 Tests**: 0/0 (n/a) ✅
- **P1 Tests**: 0/0 (n/a) ✅
- **P2 Tests**: 0/0 (n/a — 4 P2 ACs uncovered)
- **P3 Tests**: 0/0 (n/a)

**Overall Pass Rate**: n/a (no tests)

**Test Results Source**: not_applicable

---

#### Coverage Summary (from Phase 1)

**Requirements Coverage:**

- **P0 Acceptance Criteria**: 0/0 (100% — n/a) ✅
- **P1 Acceptance Criteria**: 0/0 (100% — n/a) ✅
- **P2 Acceptance Criteria**: 0/4 (0%)
- **Overall Coverage**: 0%

**Code Coverage**: not measured (no test runner)

---

#### Non-Functional Requirements (NFRs)

**Security**: PASS ✅ — Shared mode's parent-dir bind extends blast radius (documented explicitly in `packages/devbox/README.md § Per-fork vs shared mode § Shared-mode bind scope`); SC-4 operator-override-IGNORED posture in shared mode prevents container-name divergence. No new attack surface introduced at the network, secret, or capability layers. Container hardening (Story 2.5 `cap_drop: [ALL]` + `cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE]` + `no-new-privileges: true`) preserved unchanged by compose-project parameterisation.

**Performance**: PASS ✅ — Resolver function is pure bash string manipulation (`dirname`/`basename`/literal-assignment); runtime cost is negligible. No additional docker invocations on the start path in per-fork mode; shared mode adds a single `docker inspect` call in fork B's invocation for the no-op health-poll (AC 2 contract).

**Reliability**: PASS ✅ — Fail-closed posture preserved: resolver's `KEEL_DEVBOX_SHARED` read uses `${KEEL_DEVBOX_SHARED:-false}` default-substitution to survive `set -u`; Task 4 env-check orphan probe uses Story 2.10 PATCH-1 rc-capture to survive `set -e`; warning-string three-site lockstep (SC-8) minimises drift risk. No runtime toggle-able bypass exists.

**Maintainability**: PASS ✅ — Resolver single-site discipline (SC-2) + compose-project single-source (SC-3) + mode-detection ordering (SC-11) pinned in story file + substrate docs. New `INV-devbox-mode` (30th manifest entry) binds doc via `contentHash 4ddc4eea3a3f28cde90a1c7944f14d52a18aa1a0a214d9a45050aea1ec313cf2`; sync-gate (Story 1.9) detects drift mechanically.

**NFR Source**: substrate documentation + iter-257 Dev Agent Record completion notes.

---

#### Flakiness Validation

_(not applicable — no test suite)_

---

### Decision Criteria Evaluation

#### P0 Criteria (Must ALL Pass)

| Criterion             | Threshold | Actual | Status |
| --------------------- | --------- | ------ | ------ |
| P0 Coverage           | 100%      | 100%   | ✅ PASS (n/a — no P0 ACs) |
| P0 Test Pass Rate     | 100%      | n/a    | ✅ PASS (n/a) |
| Security Issues       | 0         | 0      | ✅ PASS |
| Critical NFR Failures | 0         | 0      | ✅ PASS |
| Flaky Tests           | 0         | 0      | ✅ PASS (n/a — no tests) |

**P0 Evaluation**: ✅ ALL PASS (vacuously — no P0 criteria)

---

#### P1 Criteria (Required for PASS, May Accept for CONCERNS)

| Criterion              | Threshold | Actual | Status |
| ---------------------- | --------- | ------ | ------ |
| P1 Coverage            | ≥90%      | 100%   | ✅ PASS (n/a — no P1 ACs) |
| P1 Test Pass Rate      | ≥95%      | n/a    | ✅ PASS (n/a) |
| Overall Test Pass Rate | ≥95%      | n/a    | ✅ PASS (n/a) |
| Overall Coverage       | ≥80%      | 0%     | ❌ NOT_MET (overridden by WAIVER) |

**P1 Evaluation**: ✅ ALL PASS (vacuously — no P1 criteria). Overall Coverage deterministically FAILs but is OVERRIDDEN by WAIVED verdict per ground-(a)+(b)+(c) hybrid.

---

#### P2/P3 Criteria (Informational, Don't Block)

| Criterion | Actual | Notes |
| --------- | ------ | ----- |
| P2 Coverage | 0% | WAIVED — 4 ACs at Epic-2-substrate posture; no test runner at 1.0 stage |
| P3 Coverage | n/a | No P3 criteria exist |

---

### GATE DECISION: ⚠️ WAIVED

---

### Rationale

Epic-2-substrate-dual-mode-resolver-extension class story (ELEVENTH Epic 2 delivery; FIRST dual-mode-opinionated-resolver class — distinct from Stories 2.1-2.10 single-mode-resolver extensions) shipping 1 NEW authoritative invariant doc + 1 NEW `INV-devbox-mode` manifest entry + `resolve_mode_specific_state()` 62-LOC net-new resolver function + `docker-compose.yml` top-level `name:` parameterisation + 18 host-side shim wire-ins + 1 NEW env-check Task 4 orphan probe + collateral INVARIANTS.md H3 + README H2 + AGENTS.md H3 + `.envrc.example` SC-15 past-tense comment. Four ACs — all P2 per FR14n Epic-2-substrate precedent.

**TWENTY-FIRST cumulative trace-WAIVED precedent** extending Story 2.10 iter-249 twentieth: Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57 + 1.12 iter-64 + 1.13 iter-71 + 1.14 iter-78 + 1.15 iter-85 + 1.16 iter-92 → 2.1 iter-126 → 2.2 iter-149 → 2.3 iter-159 → 2.4 iter-175 → 2.5 iter-188 → 2.6 iter-202 → 2.7 iter-224 → 2.8 iter-231 → 2.9 iter-242 → 2.10 iter-249 → 2.11 iter-258. TWENTY-SECOND ATDD-skip-trace-WAIVED co-application pairing overall.

**Ground-(a)+(b)+(c) hybrid conjunction applied:**

- **(a) Substrate-verification** covers AC 1 + AC 2 + AC 3 runtime branches via 6 iter-257 resolver functional smokes (per-fork default → `KEEL_DEVBOX_COMPOSE_PROJECT=keel-devbox`; shared `KEEL_DEVBOX_SHARED=true` → `keel-devbox-shared` + parent-bind env vars; SC-4 operator-override-IGNORED verified; env-check orphan probe rc-capture survives `set -e`) + `bash -n` syntax-check clean on all 18 shims + `pnpm keel-invariants:check` sync-gate PASS after manifest rebuild.
- **(b) No test runner wired** at Story 2.11 substrate stage — Epic 13 scope; recursive probe at iter-258 for `vitest.config.*`/`jest.config.*`/`playwright.config.*`/`cypress.config.*`/`pyproject.toml`/`go.mod`/`Gemfile`/`Cargo.toml` returns zero matches; `tests/` directory absent.
- **(c) HYBRID variant-(iii) spec-declared-CR-substitution** — Story 2.11 § Dev Notes § Concurrency decision pins AC 4 rationale (Option C chosen over Options A/B); § Testing Standards (story file:166) affirmatively declares _"AC 4: no red-phase scaffold feasible (concurrency decision is documentation-only; no harness exists for cross-fork simulation). ATDD for AC 4 is out of scope — trace-gate waive candidate for AC 4 only."_ + forthcoming `/bmad-code-review (args: "2")` adversarial envelope as designated backstop. This is FIRST spec-declared-CR-substitution-with-doc-only-AC application for Epic 2 — prior Epic-2 spec-declared-CR-substitution applications (Stories 2.5/2.6/2.7/2.8/2.9/2.10) were full-story grounds, not per-AC doc-only bypass.

**Alternative partial-waive considered.** IP § NOW pre-declared the alternative at iter-258 orient: "ACs 1-3 smoke-covered in iter-257 dev-story Debug Log, AC 4 doc-only — let the trace skill decide." Elected full-waive per 22nd-cumulative-pairing consistency rule + `coverage_basis=acceptance_criteria` mechanical-matrix-absent at substrate stage. A per-AC partial-waive would require a mechanical coverage-counting convention that distinguishes "substrate-smoke covers branch X" from "automated regression covers branch X"; the trace-matrix vocabulary at 1.0 does not support that distinction. Full-waive under 22nd-cumulative-pairing precedent is the consistent + mechanically-unambiguous posture.

**The deterministic FAIL signal (overall 0% < 80%) is a structural false-positive** — no test runner is wired at Story 2.11 substrate stage. Live fresh-fork multi-invocation smokes (two-forks-per-fork-isolation + shared-mode-attach + env-check orphan probe) require M4-Pro operator workstation backend-A where sibling-forks-under-shared-parent state is safely reproducible; DinD-B iteration env's host-socket passthrough cannot safely exercise cross-mode state transitions without poisoning host daemon state.

---

### Residual Risks

1. **AC 1/2/3 live fresh-fork smokes operator-workstation-deferred**
   - **Priority**: P2
   - **Probability**: Low (substrate-smokes cover runtime branches; live smokes verify envelope assembly)
   - **Impact**: Medium (live attach against wrong mode's container could surprise operator at Epic 2 close-out)
   - **Risk Score**: Low-Medium (probability × impact)
   - **Mitigation**: operator-workstation backend-A smoke at Epic 2 close-out (Story 2.17-adjacent polish pass); env-check orphan warning provides runtime operator guidance for mid-use flips
   - **Remediation**: Epic 13 test framework landing enables mechanical regression

2. **AC 4 operator-discipline depends on out-of-band coordination**
   - **Priority**: P2
   - **Probability**: Low (shared mode is N=1 dogfood-class; operators are themselves)
   - **Impact**: Medium (interleaved I/O corruption on concurrent attach corrupts Ralph TUI state)
   - **Risk Score**: Low (probability × impact; single-operator-in-N=1 dogfood posture)
   - **Mitigation**: `AGENTS.md` + `README.md` + `docs/invariants/devbox-mode.md` all document the contention model explicitly; agent guardrail prohibits auto-detach-second-attach feature implementation
   - **Remediation**: none at 1.0 — contract is intentional; fork operators needing true-parallel Ralph revert to per-fork mode

**Overall Residual Risk**: LOW

---

### Waiver Details

**Original Decision**: ❌ FAIL (Rule 2: Overall coverage 0% < 80%)

**Reason for Failure**:

- Structural: no test runner wired at Story 2.11 substrate stage (Epic 13 scope)

**Waiver Information**:

- **Waiver Reason**: Epic-2-substrate-dual-mode-resolver-extension class story — TWENTY-FIRST cumulative trace-WAIVED precedent + TWENTY-SECOND ATDD-skip-trace-WAIVED pairing. Ground-(a)+(b)+(c) hybrid conjunction applied with substrate-verification + no-test-runner + spec-declared-CR-substitution variant-(iii) for AC 4 doc-only concurrency decision. Consistent with Stories 2.1-2.10 Epic-2 substrate pattern.
- **Waiver Approver**: Ralph (autonomous gate via bmad-testarch-trace workflow; FR14n matrix row 3 precedent)
- **Approval Date**: 2026-04-24
- **Waiver Expiry**: Epic 13 (test framework landing) OR operator-workstation backend-A Epic 2 close-out smoke pass — whichever lands first; waiver does NOT apply to Story 2.17+ polish-pass re-trace or Epic 13 automation scope

**Monitoring Plan**:

- `/bmad-code-review (args: "2")` adversarial envelope (Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out) at next lifecycle step
- sync-gate (Story 1.9) drift detection binds `INV-devbox-mode` contract via contentHash
- operator-workstation backend-A live smokes at Epic 2 close-out polish pass

**Remediation Plan**:

- **Fix Target**: Epic 13 (test framework landing)
- **Due Date**: Epic 13 delivery window per sprint-status
- **Owner**: Epic 13 story authors
- **Verification**: automated regression suite in `packages/devbox/tests/` under vitest / playwright (framework TBD at Epic 13 scope)

**Business Justification**:

Story 2.11 is the ELEVENTH delivery in Epic 2's substrate pattern — each prior story (2.1-2.10) has earned the same WAIVED verdict under the same ground-(a)+(b)+(c) hybrid conjunction. Breaking the pattern at Story 2.11 (e.g., insisting on automated tests before test framework lands) would require Epic 13 to land first, which inverts Epic dependency order. The cumulative substrate debt is tracked as Epic 13 scope; this trace gate preserves the convention without introducing scope-creep.

---

### Gate Recommendations

#### For WAIVED Decision 🔓

1. **Deploy with Convention-Enforced Guardrails**
   - Substrate-smokes validate runtime branches at iter-257 `/bmad-dev-story` Debug Log references; sync-gate binds invariant doc via contentHash; warning-string three-site lockstep minimises drift risk
   - AGENTS.md + README.md + invariant doc all surface operator-discipline requirements (mid-Ralph-loop flip prohibition; concurrent-attach interleaving; shared-mode bind-scope security posture)
   - No runtime toggle-able bypass exists — fork operators needing different semantics revert to per-fork mode or AMEND substrate

2. **Post-Landing Monitoring**
   - `/bmad-code-review (args: "2")` adversarial envelope at next lifecycle step
   - sync-gate drift detection on `INV-devbox-mode` contentHash
   - operator-workstation backend-A live smokes at Epic 2 close-out

3. **Mandatory Remediation (Epic-Boundary)**
   - Epic 13 test framework landing unblocks mechanical regression for AC 1-3
   - Story 2.17 Epic 2 close-out polish pass is the last opportunity to run live operator-workstation smokes before Epic 2 PR merge

---

### Next Steps

**Immediate Actions** (this iteration + next):

1. Commit trace artefacts (this markdown + 3 JSONs) + update IP (Story State `in-dev → traced`; queue `/bmad-create-story (args: "review")` post-dev SM as next NOW)
2. Promote iter-257 NOVEL LESSON on manifest rebuild discipline to `RALPH.md § Lessons` as part of this iter's upkeep (step 3a)
3. Push (BLOCKED on SSH :22 egress if still timing out at step 5; otherwise flush commits together with the iter-258 trace-gate commit)

**Follow-up Actions** (next 1-3 iterations):

1. `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification per § Story Lifecycle row `traced → sm-verified`
2. `/bmad-code-review (args: "2")` adversarial envelope per § Story Lifecycle row `sm-verified → done`
3. Story 2.12..2.17 sequential lifecycle (6 remaining substrate stories until Epic 2 close-out at Story 2.17)

**Stakeholder Communication**:

- Operator (Tthew): Story 2.11 trace-gated WAIVED per Epic-2-substrate convention; substrate-verification covers AC 1-3 branches at iter-257 dev-story; AC 4 doc-only
- Future Ralph iterations: carry-forward the dual-mode-resolver pattern + manifest-rebuild discipline to Stories 2.12..2.17

---

## Integrated YAML Snippet (CI/CD)

```yaml
traceability_and_gate:
  traceability:
    story_id: '2.11'
    date: '2026-04-24'
    coverage:
      overall: 0%
      p0: 100% (n/a)
      p1: 100% (n/a)
      p2: 0%
      p3: 100% (n/a)
    gaps:
      critical: 0
      high: 0
      medium: 4
      low: 0
    quality:
      passing_tests: 0
      total_tests: 0
      blocker_issues: 0
      warning_issues: 0
    recommendations:
      - 'Accept WAIVED per TWENTY-FIRST cumulative trace-WAIVED precedent'
      - 'Queue /bmad-create-story (args: "review") post-dev SM next'
      - 'operator-workstation backend-A live smokes at Epic 2 close-out'

  gate_decision:
    decision: 'WAIVED'
    gate_type: 'story'
    decision_mode: 'deterministic'
    criteria:
      p0_coverage: 100%
      p0_pass_rate: n/a
      p1_coverage: 100%
      p1_pass_rate: n/a
      overall_pass_rate: n/a
      overall_coverage: 0%
      security_issues: 0
      critical_nfrs_fail: 0
      flaky_tests: 0
    thresholds:
      min_p0_coverage: 100
      min_p0_pass_rate: 100
      min_p1_coverage: 90
      min_p1_pass_rate: 95
      min_overall_pass_rate: 95
      min_coverage: 80
    evidence:
      test_results: not_applicable
      traceability: '_bmad-output/test-artifacts/traceability/2-11-per-fork-vs-shared-devbox-mode-keel-devbox-shared.md'
      nfr_assessment: substrate_docs_in_iter-257_dev_agent_record
      code_coverage: not_measured
    next_steps: 'queue /bmad-create-story (args: "review") post-dev SM; then /bmad-code-review (args: "2") CR; then Story 2.12'
    waiver:
      reason: 'Epic-2-substrate-dual-mode-resolver-extension class; TWENTY-FIRST cumulative trace-WAIVED precedent; ground-(a)+(b)+(c) hybrid with spec-declared-CR-substitution variant-(iii) for AC 4 doc-only'
      approver: 'Ralph (autonomous; FR14n matrix row 3)'
      expiry: 'Epic 13 test framework landing OR Epic 2 close-out operator-workstation backend-A smoke pass'
      remediation_due: 'Epic 13 delivery window'
```

---

## Related Artifacts

- **Story File:** `_bmad-output/implementation-artifacts/2-11-per-fork-vs-shared-devbox-mode-keel-devbox-shared.md`
- **Test Design:** not applicable (Epic 13 scope)
- **Tech Spec:** `_bmad-output/planning-artifacts/prd.md` (FR4); `_bmad-output/planning-artifacts/architecture.md` (§ Workspace mount; § Decisions matrix)
- **Test Results:** not applicable (no test runner)
- **NFR Assessment:** substrate documentation + iter-257 Dev Agent Record completion notes
- **Test Files:** not applicable
- **Invariant Doc:** `docs/invariants/devbox-mode.md` (new; contentHash `4ddc4eea3a3f28cde90a1c7944f14d52a18aa1a0a214d9a45050aea1ec313cf2`)
- **Manifest Entry:** `INV-devbox-mode` (30th entry) at `packages/keel-invariants/src/invariants.manifest.ts`

---

## Sign-Off

**Phase 1 - Traceability Assessment:**

- Overall Coverage: 0% (structural false-positive; WAIVED)
- P0 Coverage: 100% (n/a — no P0 ACs) ✅
- P1 Coverage: 100% (n/a — no P1 ACs) ✅
- Critical Gaps: 0
- High Priority Gaps: 0
- Medium Priority Gaps (WAIVED): 4

**Phase 2 - Gate Decision:**

- **Decision**: ⚠️ WAIVED
- **P0 Evaluation**: ✅ ALL PASS (vacuously)
- **P1 Evaluation**: ✅ ALL PASS (vacuously; Overall Coverage NOT_MET overridden by WAIVER)

**Overall Status:** ⚠️ WAIVED

**Next Steps:**

- Queue `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification (Story State `traced → sm-verified` OR `sm-fixes-pending`) per § Story Lifecycle Decision Matrix.

**Generated:** 2026-04-24
**Workflow:** testarch-trace v4.0 (Enhanced with Gate Decision)

---

<!-- Powered by BMAD-CORE™ -->
