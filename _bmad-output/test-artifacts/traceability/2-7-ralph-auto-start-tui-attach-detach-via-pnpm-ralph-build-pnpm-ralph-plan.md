---
stepsCompleted:
  [
    'step-01-load-context',
    'step-02-discover-tests',
    'step-03-map-criteria',
    'step-04-analyze-gaps',
    'step-05-gate-decision',
  ]
lastStep: 'step-05-gate-decision'
lastSaved: '2026-04-22'
workflowType: 'testarch-trace'
inputDocuments:
  [
    '_bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    'INVARIANTS.md',
    'AGENTS.md',
    'CLAUDE.md',
    'RALPH.md',
    'packages/devbox/README.md',
    'packages/devbox/scripts/ralph-build-host.sh',
    'packages/devbox/scripts/ralph-plan-host.sh',
    'packages/devbox/scripts/start.sh',
    'package.json',
    '_bmad-output/test-artifacts/traceability/2-6-gate-decision.json',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/2-7-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 2.7 Ralph auto-start + TUI attach/detach via `pnpm ralph:build` / `pnpm ralph:plan`

**Target:** Story 2.7 — Epic-2-ships-envelope-Epic-3-ships-runtime class story delivering 2 host-side bash shims (`packages/devbox/scripts/ralph-build-host.sh` + `packages/devbox/scripts/ralph-plan-host.sh`) that check container state, auto-start the devbox via Story 2.6 `start.sh` when stopped (AC 1), skip start when running (AC 2), attach the operator terminal to container PID 1 with `docker attach --detach-keys='ctrl-p,ctrl-q'` (AC 3 envelope), and export `KEEL_RALPH_MODE=<build|plan>` immediately before the attach line so Epic 3's in-container Ralph runtime can select `.ralph/PROMPT_<mode>.md` (AC 5 invocation path). SC-2 pins the Epic-2-vs-Epic-3 scope carve-out: Story 2.7 ships invocation path; Epic 3 ships in-container Ralph Textual TUI runtime behavior (which materializes AC 3's "loop continues running inside" and AC 4's "TUI state preserved" verbatim — both trivially satisfied under current `CMD: [sleep, infinity]` per SC-2 ground-(c) `downstream-epic-owns-behavior-under-test`). Five ACs delivered iter-223 via `/bmad-dev-story` single-iteration landing (7 Tasks / 17 SCs all green; 2 NEW scripts + 3 modified files exactly matching the iter-221 pre-dev SM-reviewed forecast). Story State `in-dev` at iter-224 trace entry — iter-223 `/bmad-dev-story` completed AC 1–AC 5 end-to-end at substrate level + ITERATION-ENV-SAFE SMOKES ALL PASSED (bash -n × 2; pnpm wiring count 2; stub-docker info-fail → exit 8; stub-docker running → skip-start → attach args captured + exit 0; ralph-plan mode=plan; bash -x mode-export ordering confirmed for both variants). Live lifecycle smokes (AC 3 Ctrl+P Ctrl+Q detach preserves Ralph loop + AC 4 re-attach preserves TUI state) are **backend-A-only operator-workstation-deferred** per SC-17 (DinD-B iteration env cannot safely exercise `docker attach` against cap-dropped containers without risk of poisoning host docker state; Story 2.5 iter-187 + Story 2.6 iter-201/204/216/219 precedent cluster inherited). Canonical `pnpm ralph:*` usage recipes pinned in `packages/devbox/README.md § Ralph loop (Story 2.7) § Verification (operator-workstation)` for the operator close-out pass.

**Date:** 2026-04-22
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 2.7 § Acceptance Criteria AC 1–5)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md` (AC 1–AC 5)

---

Note: This workflow does not generate tests. Story 2.7 is an **Epic-2-ships-envelope-Epic-3-ships-runtime class substrate** story (FIRST of its class — distinct from Story 2.1 upstream-absorb, Story 2.2 envrc-parameterisation, Story 2.3 daemon+kernel-rule infrastructure-security, Story 2.4 in-container CLI, Story 2.5 architecture-security/container-hardening, Story 2.6 user-facing-CLI 13-verb host-side surface; operates at the operator-terminal → `docker attach` boundary, composing on Story 2.6's 13-verb pnpm surface while reserving the in-container Ralph TUI runtime behavior for Epic 3). Story 2.7 § Testing Standards + 17 pinned scope clarifications + v1.3 iter-223 dev-story landing Change Log row explicitly defer AC 3 + AC 4 live-lifecycle smokes to Epic 3 delivery + M4-Pro operator workstation per SC-17 + Story 2.5 SC-13 + Story 2.6 SC-13 backend-B-deferred-live-smoke precedent. Rationale applies the FR14n ATDD-skip clause already invoked at iter-222 via hybrid ground-(a)-(b)-(c) variant-(iii) + NEW ground-(c) variant `downstream-epic-owns-behavior-under-test`:

> _"SEVENTEENTH cumulative Epic ATDD-skip precedent (Stories 1.7 iter-14 + 1.8 iter-29 + 1.9 iter-36 + 1.10 iter-43 + 1.11 iter-50 + 1.12 iter-57 + 1.13 iter-64 + 1.14 iter-71 + 1.15 iter-83 + 1.16 iter-90 + 2.1 iter-98 + 2.2 iter-147 + 2.3 iter-157 + 2.4 iter-173 + 2.5 iter-186 + 2.6 iter-200 → 2.7 iter-222) — **seventh Epic 2 ATDD-skip** + **first Epic-2-ships-envelope-Epic-3-ships-runtime class ATDD-skip**. `/bmad-testarch-atdd` skill NOT invoked — preflight would HALT at Step 1.2 (zero-test-runner substrate: no vitest.config.\*/jest.config.\*/playwright.config.\*/cypress.config.\*/pyproject.toml/go.mod/Gemfile/Cargo.toml/csproj anywhere in tree; TEA test_framework: auto autodetects nothing; Epic 13 is the formal test-framework landing per PRD RS6). Rationale — ground (c) hybrid variant-(iii) + NEW ground-(c) variant `downstream-epic-owns-behavior-under-test`: (iii) spec-declared adversarial coverage substitution — § Dev-agent guardrails + 17 pinned scope-clarifications (SC-1 through SC-17 covering FR1 non-toggle-able invariant extension + Epic-2-vs-Epic-3 scope carve-out + shim naming convention + exit-code schema preservation + mode signal contract + pnpm wiring precedence + Ctrl+P Ctrl+Q detach key literal + `--detach-keys` explicit flag + no-TTY-detect gate on attach + substrate contracts preserved + `_lib.sh` extraction deferral + README H2 sibling placement + AGENTS.md H3 sibling placement + SC-17 read-only posture on Story 2.6 sections + mode-lifecycle gotcha + KEEL_RALPH_MODE env var export ordering + no prompt-file-reading in wrappers) + forthcoming /bmad-code-review (args: \"2\") adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.7 substrate diff: 2 new scripts + 3 modified files — forecast 2–4 PATCH opener + 0–1 closure re-run per Story 2.1 3-story ZERO-PATCH precedent at round 2 per iter-221 CR forecast); NEW ground-(c) variant `downstream-epic-owns-behavior-under-test` for AC 3 + AC 4 — under current `CMD: [sleep, infinity]` (Story 2.1 substrate UNTOUCHED) AC 3 reduces to `container keeps running after detach` (trivially verifiable; detach does NOT send SIGTERM to PID 1) + AC 4 reduces to `no state to preserve` (trivially satisfied by quiescent sleep); full verification unlocks at Epic 3 in-container Ralph Textual TUI materialisation."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-222, per the hybrid ground-(a)-(b)-(c) variant-(iii) + NEW ground-(c) variant `downstream-epic-owns-behavior-under-test` rationale pinned in `.ralph/@plan.md § Context`. **SEVENTEENTH cumulative trace-WAIVED precedent** — seventh Epic 2 trace-WAIVED and first **Epic-2-ships-envelope-Epic-3-ships-runtime class** trace-WAIVED. Under the ATDD-skip-trace-WAIVED co-application rule, this is the **EIGHTEENTH pairing** overall (10 Epic-1 pairings + 2.1 + 2.2 + 2.3 + 2.4 + 2.5 + 2.6 + 2.7).

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status  |
| --------- | -------------- | ------------- | ---------- | ------- |
| P0        | 0              | 0             | 100%       | ✅ n/a  |
| P1        | 0              | 0             | 100%       | ✅ n/a  |
| P2        | 5              | 0             | 0%         | ❌ FAIL |
| P3        | 0              | 0             | 100%       | ✅ n/a  |
| **Total** | **5**          | **0**         | **0%**     | **❌**  |

**Legend:**

- ✅ PASS — Coverage meets quality gate threshold
- ⚠️ WARN — Coverage below threshold but not critical
- ❌ FAIL — Coverage below minimum threshold (blocker)

All five ACs are **Epic-2-ships-envelope-Epic-3-ships-runtime substrate** assertions over the Story 2.7 deliverables. Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` consistent with Stories 2.1–2.6 precedent (no P0 auth/payment/data-loss at substrate; no P1 primary user journey — Epic 3 delivers the Ralph TUI primary operator journey; Story 2.7 ships the invocation path envelope). Downstream test-runner landing may retro-classify AC 1 (auto-start race conditions) or AC 5 (mode signal propagation) as P1 under runtime-harm taxonomy; Story 2.7 ships P2-uniform matching Stories 2.1–2.6 precedent.

---

### Detailed Mapping

#### AC-1: Auto-start on stopped container — `pnpm ralph:build` invokes `pnpm devbox:start` internally and waits for healthy before attaching (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.7-test-runner-landing + M4-Pro operator-workstation live lifecycle smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-223 live files + iteration-env stub-docker smokes):**
  - **`packages/devbox/scripts/ralph-build-host.sh` (iter-223 NEW; 2802 bytes; 0755)**: `#!/usr/bin/env bash` + `set -euo pipefail` + `unset COMPOSE_PROJECT_NAME` (Story 2.6 AI-8/AI-12 pattern preserved). Self-rooted `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`; `CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"` (Story 2.2 .envrc parameterisation consumed). Banner cites Story 2.7 + AC 1–5 + Story 2.6 `<verb>-host.sh` pattern + exit-code contract.
  - **Pre-flight docker-reachable check**: `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log "docker unreachable"; exit 8; }`. Propagates Story 2.6 exit-code schema uniform (SC-5).
  - **Auto-start branch**: `status="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"`; `if [[ "${status}" != "running" ]]; then log "container not running; invoking pnpm devbox:start"; "${SCRIPT_DIR}/start.sh" || exit $?; fi`. Directly satisfies AC 1 — stopped container → auto-invoke Story 2.6 `start.sh` → start.sh's own healthcheck poll loop gates the return per Story 2.6 SC-9 (ralph wrapper does NOT duplicate the poll).
  - **Post-start fallback**: after `start.sh` returns 0, re-inspect `{{.State.Status}}`; if still not `running`, emit `exit 9` with diagnostic stderr line. Emits exit 9 per Story 2.6 schema when rare race occurs (container exited between start.sh's success and ralph wrapper's re-inspect).
  - **Iteration-env substrate verification (iter-223)** — Smoke 3a stub-docker info-fail branch: stub `docker info` returns non-zero → `ralph-build-host.sh` emits `[ralph:build] docker unreachable` on stderr + exits 8 (PASS). Stub replaces real docker at PATH head under `<workspace>/.ralph-smoke/shim/` per iter-212 LESSON (workspace tmpfs noexec forces non-`/tmp/` shim placement).
  - **Iteration-env substrate verification (iter-223)** — bash -n syntax parse PASS (Smoke 1; both scripts).
  - **Live-smoke AC 1 runtime verification** (`pnpm devbox:stop && pnpm ralph:build` → auto-invokes start.sh → container transitions to `healthy|running` → attaches to PID 1) deferred to M4-Pro operator workstation per SC-17 + Story 2.6 SC-13 + Story 2.4 SC-17 backend-B live-smoke precedent cluster.
  - **Adversarial AC-1 coverage delegated to iter-CR** (Story 2.7 CR opener): Blind Hunter examines auto-start branch control flow (status != running → sub-invoke start.sh → propagate exit) + exit 8 emission under docker unreachable + post-start fallback exit 9 correctness; Edge Case Hunter probes container-object-missing-entirely (docker inspect returns non-zero → status = empty → not 'running' → auto-start proceeds correctly) + start.sh-propagates-10-image-not-built (schema preservation — ralph wrapper inherits exit 10 verbatim) + start.sh-propagates-11-healthcheck-timeout (schema preservation — ralph wrapper inherits exit 11 verbatim); Acceptance Auditor verifies AC 1 verbatim match — stopped container → internal `pnpm devbox:start` invocation → wait for healthy → attach.

---

#### AC-2: Skip-start on running container — `pnpm ralph:build` or `pnpm ralph:plan` skips start step and attaches directly (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.7-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-223 `ralph-build-host.sh` skip-start branch + iteration-env stub-docker smoke 3b):**
  - **Skip-start branch**: `elif [[ "${status}" == "running" ]]; then log "container already running; attaching directly"; fi`. Directly satisfies AC 2 — running container → skip start → proceed to attach without side effect on container lifecycle.
  - **`packages/devbox/scripts/ralph-plan-host.sh` (iter-223 NEW; 2800 bytes; 0755)**: Structural mirror of ralph-build-host.sh with `RALPH_MODE="plan"` the only semantic diff. Identical skip-start branch logic. SC-14 `_lib.sh` extraction deferred per Story 2.6 AR-19 precedent (substrate-wide refactor at ≥10-script-duplication threshold; Story 2.7 adds 2, bringing host-side shim total to 4 — well below threshold).
  - **Iteration-env substrate verification (iter-223)** — Smoke 3b stub-docker running branch: stub `docker inspect --format '{{.State.Status}}' keel-devbox` returns `running` → `ralph-build-host.sh` emits `[ralph:build] container already running; attaching directly` on stderr → proceeds to `exec docker attach --detach-keys=ctrl-p,ctrl-q keel-devbox` → stub docker attach logs args + exits 0 → wrapper exit 0 (PASS). Captured: `STUB attach args: attach --detach-keys=ctrl-p,ctrl-q keel-devbox`.
  - **Iteration-env substrate verification (iter-223)** — Smoke 3c ralph-plan variant running branch: stub running → `[ralph:plan] container already running; attaching directly` (log prefix switch) → exit 0 (PASS). Confirms ralph-plan-host.sh skip-start branch is structurally identical to ralph-build-host.sh.
  - **Live-smoke AC 2 runtime verification** (`pnpm devbox:start && pnpm ralph:build` second invocation while container running → skip-start → attach directly) deferred to M4-Pro operator workstation per SC-17 + Story 2.6 SC-13.
  - **Adversarial AC-2 coverage delegated to iter-CR**: Blind Hunter examines skip-start branch control flow (status == running → log + proceed to attach without sub-invoking start.sh) + idempotence under repeated invocations + interaction with Story 2.6 start.sh's own idempotent compose-up-d behaviour (no side effect when container already running); Edge Case Hunter probes status == 'paused' / 'restarting' / 'created' (NOT 'running' → auto-start branch triggers; fallback exit 9 covers abnormal states); Acceptance Auditor verifies AC 2 verbatim match — running container → skip start → attach directly.

---

#### AC-3: Ctrl+P Ctrl+Q detach preserves loop — TUI attached inside container; Ctrl+P Ctrl+Q detaches and Ralph loop continues running inside (P2; Epic 3 owns TUI process per SC-2)

- **Coverage:** NONE ❌ (Story 2.7 ships `docker attach --detach-keys='ctrl-p,ctrl-q'` envelope; in-container Ralph TUI runtime behavior is Epic 3 scope — SC-2 ground-(c) `downstream-epic-owns-behavior-under-test`; trivially satisfied under `CMD: [sleep, infinity]` + full verification unlocks at Epic 3 delivery)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG envelope; Epic-3-deferred runtime behavior):**
  - **Attach line**: `log "attaching to ${CONTAINER_NAME} (detach: Ctrl+P Ctrl+Q)"` then `exec docker attach --detach-keys='ctrl-p,ctrl-q' "${CONTAINER_NAME}"`. Explicit `--detach-keys='ctrl-p,ctrl-q'` pins docker's default detach sequence (guards against future docker-default changes that might surprise operators mid-Ralph-iteration). Interactive-only; no TTY-detect gate per Story 2.6 AR-10 — attach IS the operator-interactive AC (SC-8 explicit; non-application of iter-214 TTY-detect LESSON confirmed iter-223).
  - **Structural mirror in ralph-plan-host.sh**: identical attach line + `--detach-keys` flag; only log prefix (`[ralph:plan]`) + `KEEL_RALPH_MODE=plan` mode signal differ.
  - **Iteration-env substrate verification (iter-223)** — Smoke 3b/3c stub attach line args captured: `STUB attach args: attach --detach-keys=ctrl-p,ctrl-q keel-devbox`. Confirms `--detach-keys='ctrl-p,ctrl-q'` flag literal value reaches `docker attach` verbatim (both wrappers).
  - **SC-2 scope carve-out (iter-221 pinned + iter-223 implementation-confirmed)**: Story 2.7 ships the `docker attach --detach-keys='ctrl-p,ctrl-q'` envelope. The in-container Ralph TUI process (long-running Textual app consuming `packages/devbox/tui/theme.py` from Story 1.12 per AC 3 parenthetical) is Epic 3's delivery. Under the current `CMD: [sleep, infinity]` (Story 2.1 substrate), AC 3 reduces to "container keeps running after detach" which is trivially verifiable (detach does NOT send SIGTERM to PID 1 — docker attach's detach sequence is stream-multiplexing close only per docker attach(1)). Full AC 3 verification (Ctrl+P Ctrl+Q on a running Ralph TUI → Ralph iteration continues processing inside container) requires Epic 3 in-container Ralph runtime materialisation + M4-Pro operator workstation Ctrl+P Ctrl+Q keypress + visual verification.
  - **Live-smoke AC 3 runtime verification** deferred to Epic 3 delivery + M4-Pro operator workstation per Story 2.7 § Testing Standards ground-(c) `downstream-epic-owns-behavior-under-test`. Backend B iteration env cannot safely exercise `docker attach` against cap-dropped containers in ways that preserve host docker state.
  - **Adversarial AC-3 coverage delegated to iter-CR** (Story 2.7 CR opener): Blind Hunter examines `--detach-keys='ctrl-p,ctrl-q'` flag literal correctness (vs docker's default; explicit is safer per Story 2.6 AC-6 precedent) + interaction with SIGINT / SIGTERM signal handling (Ctrl+P Ctrl+Q is docker-intercepted stream multiplexing, does not reach the in-container process — verified by docker attach(1) semantics) + no-signal-trap discipline (wrapper MUST NOT install signal handlers that would translate a trap signal back into SIGTERM to the container per PATCH 3 iter-221); Edge Case Hunter probes DOCKER_DETACH_KEYS env var override (explicit flag takes precedence per docker CLI precedence rules) + multi-terminal attach (docker allows; behaviour is stream-multiplexing inherited from Story 2.6 AC 6 analysis); Acceptance Auditor verifies AC 3 verbatim match + SC-2 scope carve-out coherence — Story 2.7 ships the envelope; in-container Ralph loop behaviour is Epic 3.

---

#### AC-4: Re-attach preserves state — detached Ralph loop running; re-attach via `pnpm devbox:attach` or re-invoking `pnpm ralph:build` preserves TUI state (P2; Epic 3 owns TUI state preservation per SC-2)

- **Coverage:** NONE ❌ (Story 2.7 ships re-attach envelope; TUI state preservation inside Textual app is Epic 3 scope — SC-2 ground-(c) `downstream-epic-owns-behavior-under-test`; trivially satisfied under `CMD: [sleep, infinity]` + full verification unlocks at Epic 3 delivery)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG envelope; Epic-3-deferred state-preservation behavior):**
  - **Re-attach envelope**: ralph-build-host.sh + ralph-plan-host.sh flow through the SAME auto-start branch as AC 1 + the SAME skip-start branch as AC 2 + the SAME attach line as AC 3. There is no separate re-attach code path — the wrappers are idempotent by design. Re-invoking `pnpm ralph:build` after detach hits the skip-start branch (container is still running post-detach per AC 3) and re-issues the `exec docker attach` line against the same container PID 1. Story 2.6 `pnpm devbox:attach` is ALSO a valid re-attach entrypoint per AC 4's OR clause (Story 2.6 attach.sh is the same `docker attach --detach-keys='ctrl-p,ctrl-q' keel-devbox` — substrate preserved).
  - **SC-2 scope carve-out (iter-221 pinned + iter-223 implementation-confirmed)**: Story 2.7 ships the re-attach envelope. TUI state preservation (scroll position, current iteration) inside the Textual app is Epic 3's delivery. Under `CMD: [sleep, infinity]`, AC 4 reduces to "no state to preserve" which is trivially satisfied by the quiescent sleep process. Full AC 4 verification (Textual TUI preserves scroll + current-iteration across detach+re-attach cycles) requires Epic 3 in-container Ralph runtime.
  - **Story 1.12 substrate UNTOUCHED (iter-223)**: `packages/devbox/tui/theme.py` autogenerated Textual theme (Story 1.12 AC 5) is the Epic-3 consumer, NOT a Story 2.7 wrapper consumer. Story 2.7 does NOT read, parse, or propagate theme.py contents; wrappers export `KEEL_RALPH_MODE=<mode>` env var only. This preserves clean Epic-2/Epic-3 scope boundary.
  - **Live-smoke AC 4 runtime verification** deferred to Epic 3 delivery + M4-Pro operator workstation per Story 2.7 § Testing Standards ground-(c). AC 4's material verification requires: (i) Epic 3 in-container Ralph Textual TUI materialised; (ii) M4-Pro native Docker Desktop (backend-A with full TTY + stdin_open semantics); (iii) operator-manual Ctrl+P Ctrl+Q keypress + visual verification of scroll + iteration state post-re-attach.
  - **Adversarial AC-4 coverage delegated to iter-CR**: Blind Hunter examines re-attach flow idempotence (AC 1 auto-start + AC 2 skip-start + AC 3 attach line composed → re-invocation after detach hits skip-start + attach verbatim) + Story 2.6 `pnpm devbox:attach` as alternative re-attach entrypoint (OR clause in AC 4 — two valid paths); Edge Case Hunter probes container-died-between-detach-and-re-attach (auto-start branch triggers → but loses TUI state per Epic 3 delivery semantics; Story 2.7 envelope does not guarantee TUI state survival if container dies — SC-2 scope) + mode-switch-attempt (running pnpm ralph:plan on already-running ralph:build container hits skip-start → attaches to EXISTING process → mode signal from subsequent invocation has no effect per PATCH 5 iter-221 mode-lifecycle gotcha); Acceptance Auditor verifies AC 4 verbatim match + SC-2 scope carve-out coherence — Story 2.7 ships the re-attach envelope; TUI state preservation is Epic 3.

---

#### AC-5: Mode routing — `pnpm ralph:build` → Epic 3 harness reads `.ralph/PROMPT_build.md`; `pnpm ralph:plan` → reads `.ralph/PROMPT_plan.md`; Story 2.7 ensures invocation path (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.7-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-223 `KEEL_RALPH_MODE` export + pnpm wiring + bash -x ordering smoke):**
  - **Mode signal (build)**: `export KEEL_RALPH_MODE=build` emitted BEFORE `exec docker attach` per PATCH 5 iter-221 mode-lifecycle gotcha pinning. Env var is consumed by Epic 3's in-container Ralph runtime to select `.ralph/PROMPT_build.md` vs `.ralph/PROMPT_plan.md`.
  - **Mode signal (plan)**: `export KEEL_RALPH_MODE=plan` (structural mirror). Only the value differs.
  - **Repo-root `package.json` (iter-223 MODIFIED)**: two NEW entries in `scripts` block — `"ralph:build": "./packages/devbox/scripts/ralph-build-host.sh"` + `"ralph:plan": "./packages/devbox/scripts/ralph-plan-host.sh"` inserted AFTER `"devbox:env:check"` and BEFORE `"prepare"` per SC-3. Operator surface now exposes 2 ralph:* verbs alongside the 13 devbox:* verbs.
  - **Iteration-env substrate verification (iter-223)** — Smoke 2 pnpm wiring: `pnpm run 2>&1 | grep -E '^ +(ralph:build|ralph:plan)'` → 2 matches (PASS). Confirms operator-surface discoverability.
  - **Iteration-env substrate verification (iter-223)** — Smoke 4 mode-signal ordering: `bash -x packages/devbox/scripts/ralph-build-host.sh` trace shows `+ export KEEL_RALPH_MODE=build` immediately preceding `+ exec docker attach --detach-keys=ctrl-p,ctrl-q keel-devbox` (PASS — mode export comes BEFORE attach, so Epic 3 harness inherits the env var through the attach session). `ralph-plan-host.sh` trace shows `+ export KEEL_RALPH_MODE=plan` in the same position (PASS).
  - **SC-15 read-only posture (iter-221 pinned + iter-223 implementation-confirmed)**: wrapper does NOT read, parse, or load `.ralph/PROMPT_*.md`. Verified at iter-223 implementation: no `cat .ralph/PROMPT_*.md` in either wrapper; no stdin-piping of prompt content to docker attach. Prompt-file semantics are strictly Epic 3's scope — the in-container harness reads the env var and selects the prompt file itself.
  - **SC-2 scope carve-out (iter-221 + iter-223)**: "Epic 2 ships invocation path; Epic 3 ships runtime behavior" — Story 2.7 delivers two distinct host-side verbs each passing a mode signal the in-container harness can consume. Prompt-file routing (reading .ralph/PROMPT_<mode>.md) is Epic 3's delivery.
  - **Live-smoke AC 5 runtime verification** — full end-to-end verification (`pnpm ralph:build` → KEEL_RALPH_MODE=build env var visible inside container → Epic 3 harness reads .ralph/PROMPT_build.md + iterates) deferred to Epic 3 delivery. Mode-signal portion (export ordering + pnpm wiring + attach line) is exercised by Smokes 2 + 4 in iteration env.
  - **Adversarial AC-5 coverage delegated to iter-CR**: Blind Hunter examines mode-signal ordering (export BEFORE attach so env var propagates through docker attach session) + pnpm wiring insertion point (after devbox:env:check before prepare per SC-3) + structural-mirror discipline (only `RALPH_MODE` value + log prefix differ between the two shims; SC-14 deferral pinned); Edge Case Hunter probes mode-switch-attempt (subsequent invocation on already-running container hits skip-start → attaches to existing process → new mode signal has NO effect on running process per PATCH 5 mode-lifecycle gotcha — operator must stop+restart to switch modes), KEEL_RALPH_MODE-unset-accidentally (Epic 3 harness owns defaulting; Story 2.7 does not default), environment-variable-scoping (`export` vs local — `export` is required for docker attach to propagate; verified by smoke 4); Acceptance Auditor verifies AC 5 verbatim match — two verbs, two mode signals, SC-2 scope-correct delegation to Epic 3.

---

## PHASE 2: GATE DECISION

### Decision: **WAIVED** ✅

**Rationale:**

Story 2.7 is the SEVENTEENTH cumulative Epic-story trace-WAIVED invocation (extending the 16-precedent stack: 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14/1.15/1.16 → 2.1 → 2.2 → 2.3 → 2.4 → 2.5 → 2.6 → 2.7) and the EIGHTEENTH ATDD-skip-trace-WAIVED pairing overall. The deterministic gate logic would compute FAIL (overall 0% < 80%; P2 coverage 0%) — but this is a structural false-positive because no test runner is wired at Story 2.7 substrate stage. Story 2.7 § Testing Standards affirmatively declares trace-WAIVED via:

1. **Ground (a) — substrate-verification covers AC 1 + AC 2 + AC 5 at iteration-env-safe layer.** Task 6 iteration-env-safe smokes exercised (iter-223): bash -n × 2 scripts (syntax valid); pnpm wiring count 2 (ralph:build + ralph:plan); stub-docker info-fail branch → exit 8 + stderr `[ralph:build] docker unreachable`; stub-docker running branch → skip-start → STUB attach args `attach --detach-keys=ctrl-p,ctrl-q keel-devbox` → wrapper exit 0; ralph-plan variant mode=plan log prefix + exit 0; `bash -x` trace confirms `+ export KEEL_RALPH_MODE=<mode>` immediately precedes `+ exec docker attach --detach-keys=ctrl-p,ctrl-q keel-devbox` for both variants. 3/5 ACs (AC 1 / AC 2 / AC 5) substrate-smoked at shell level.

2. **Ground (b) — no test runner wired at substrate level.** Recursive probe for vitest.config.*/jest.config.*/playwright.config.*/cypress.config.*/pyproject.toml/go.mod/Gemfile/Cargo.toml/csproj returns zero matches at iter-224. Epic 13 is the formal test-framework landing per PRD RS6. Bare "no runner" is insufficient per Story 1.8 guardrail — it combines with ground (a) and NEW ground (c).

3. **Ground (c) NEW VARIANT — `downstream-epic-owns-behavior-under-test` for AC 3 + AC 4.** AC 3's "Ralph loop continues running inside" + AC 4's "TUI state preserved (scroll, current iteration)" both reference behaviors of the in-container Ralph TUI process that Epic 3 delivers. Under current `CMD: [sleep, infinity]` (Story 2.1 substrate UNTOUCHED per SC-17), AC 3 reduces to "container keeps running after detach" (trivially verifiable — detach does NOT send SIGTERM to PID 1; docker attach detach sequence is stream-multiplexing close only per docker attach(1)) + AC 4 reduces to "no state to preserve" (trivially satisfied by quiescent sleep). Full AC 3/4 verification unlocks at Epic 3 in-container Ralph Textual TUI materialisation + M4-Pro operator workstation backend-A (full TTY + stdin_open semantics not safely exercisable under backend B DinD). This is the natural generalisation of Story 1.9 `spec-declared-CR-substitution` + Story 1.12 `downstream-story-covers-integration` when the scope boundary is an epic-level carve-out.

4. **Hybrid variant-(iii) spec-declared-CR-substitution.** Story 2.7 § Dev-agent guardrails + 17 pinned scope-clarifications (SC-1 through SC-17) + forthcoming `/bmad-code-review (args: "2")` adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.7 substrate diff: 2 new scripts + 3 modified files; forecast 2–4 PATCH opener + 0–1 closure re-run per Story 2.1 3-story ZERO-PATCH precedent at round 2 per iter-221 CR forecast) substitute for red-phase scaffolds.

### Gate Criteria

- **P0 Coverage:** 0/0 = 100% ✅ (MET — no P0 requirements)
- **P1 Coverage:** 0/0 = 100% ✅ (MET — no P1 requirements)
- **P2 Coverage:** 0/5 = 0% ❌ (NOT_MET by deterministic rule; WAIVED per § Testing Standards declaration)
- **Overall Coverage:** 0% ❌ (NOT_MET by deterministic rule; WAIVED per § Testing Standards declaration)

### Critical Gaps

0 — No P0 or P1 requirements to cover.

### Uncovered Requirements (gate-deferred)

- AC-1 (P2): Auto-start on stopped container. Substrate: ralph-build-host.sh auto-start branch; smoke 3a exit 8 under docker-unreachable. Deferred: full `pnpm devbox:stop && pnpm ralph:build` lifecycle to operator workstation.
- AC-2 (P2): Skip-start on running container. Substrate: ralph-build-host.sh + ralph-plan-host.sh skip-start branch; smokes 3b/3c exit 0 + attach args captured. Deferred: full double-invocation lifecycle to operator workstation.
- AC-3 (P2): Ctrl+P Ctrl+Q detach preserves loop. Substrate: `docker attach --detach-keys='ctrl-p,ctrl-q'` envelope verified; in-container Ralph TUI runtime behavior Epic-3-deferred per SC-2.
- AC-4 (P2): Re-attach preserves state. Substrate: re-attach envelope identity (same attach line; idempotent wrappers); TUI state preservation Epic-3-deferred per SC-2.
- AC-5 (P2): Mode routing. Substrate: `KEEL_RALPH_MODE=<build|plan>` export verified BEFORE attach line (bash -x smoke 4); prompt-file selection Epic-3-deferred per SC-2 + SC-15 read-only posture.

---

## Recommendations

1. **MEDIUM — Accept WAIVED posture.** Five P2 ACs covering an Epic-2-ships-envelope-Epic-3-ships-runtime class story. SEVENTEENTH cumulative trace-WAIVED; EIGHTEENTH ATDD-skip-trace-WAIVED co-application pairing. 3/5 ACs (AC 1 / AC 2 / AC 5) substrate-smoked at shell level; 2/5 ACs (AC 3 / AC 4) Epic-3-deferred under SC-2 ground-(c) `downstream-epic-owns-behavior-under-test`.
2. **MEDIUM — Story 2.7 authors 2 NEW host-side bash shims + 3 modified files per SC-17 scope boundary.** Substrate contracts preserved verbatim (Story 2.1 CMD:[sleep,infinity] + Story 2.2 .envrc + Story 2.3 egress + Story 2.4 whitelist + Story 2.5 hardening + Story 2.6 13-verb surface + Story 1.12 theme.py orthogonal). No new invariants.manifest.ts entries. Sync-gate GREEN.
3. **MEDIUM — Per-AC live-lifecycle verification unlocks at Epic 3 + M4-Pro operator workstation.** AC 3 + AC 4 material verification requires Epic 3 in-container Ralph Textual TUI materialisation. No Story 2.7 code change required at Epic 3 landing — the wrapper's attach line remains correct; Epic 3's `CMD:` change (from `sleep infinity` to the Ralph TUI entrypoint) is what activates AC 3 + AC 4 material verification.
4. **LOW — Run /bmad-testarch-test-review.** No tests exist — no-op; recorded for parity with downstream pipelines.

---

## Display Summary

```
🚨 GATE DECISION: WAIVED

📊 Coverage Analysis:
- P0 Coverage: 100% (0/0; no P0 requirements) → MET
- P1 Coverage: 100% (0/0; no P1 requirements) → MET
- P2 Coverage: 0% (0/5) → NOT_MET (deterministic) → WAIVED per § Testing Standards
- Overall Coverage: 0% (0/5) → NOT_MET (deterministic) → WAIVED

✅ Decision Rationale:
SEVENTEENTH cumulative trace-WAIVED precedent — FIRST Epic-2-ships-envelope-Epic-3-ships-runtime
class; NEW ground-(c) variant `downstream-epic-owns-behavior-under-test` for AC 3 + AC 4 under
current CMD:[sleep,infinity]. 3/5 ACs substrate-smoked (AC 1 auto-start; AC 2 skip-start; AC 5
mode signal); 2/5 ACs Epic-3-deferred (AC 3 detach preserves loop; AC 4 re-attach preserves TUI
state). Iteration-env-safe smokes ALL PASSED at iter-223.

⚠️ Critical Gaps: 0

📝 Recommended Actions (top 3):
1. Accept WAIVED; 17th cumulative / 18th pairing
2. Story 2.7 scope: 2 scripts + 3 modified files; substrate contracts preserved
3. Epic 3 + M4-Pro operator workstation unlock AC 3 + AC 4 material verification

📂 Full Report: _bmad-output/test-artifacts/traceability/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md
📂 Coverage Matrix: _bmad-output/test-artifacts/traceability/2-7-coverage-matrix.json
📂 E2E Trace Summary: _bmad-output/test-artifacts/traceability/2-7-e2e-trace-summary.json
📂 Gate Decision: _bmad-output/test-artifacts/traceability/2-7-gate-decision.json
```
