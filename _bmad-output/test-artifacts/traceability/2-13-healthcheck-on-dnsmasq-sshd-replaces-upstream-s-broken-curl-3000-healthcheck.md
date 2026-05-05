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
  - '_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md'
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  - '_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md#Acceptance Criteria'
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/2-13-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision - Story 2.13: Healthcheck on dnsmasq + sshd (replaces upstream's broken `curl :3000` healthcheck)

**Target:** Story 2.13 — Healthcheck on dnsmasq + sshd (replaces upstream's broken `curl :3000` healthcheck)
**Date:** 2026-04-24
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md#Acceptance Criteria`

---

Note: This workflow does not generate tests. If gaps exist, run `/bmad-testarch-atdd` or `/bmad-testarch-automate` to create coverage.

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status |
| --------- | -------------- | ------------- | ---------- | ------ |
| P0        | 0              | 0             | 100%       | ✅ PASS (n/a) |
| P1        | 0              | 0             | 100%       | ✅ PASS (n/a) |
| P2        | 5              | 0             | 0%         | ⚠️ WAIVED (ground-(a)+(b)+(c) hybrid; no test runner at Story 2.13 substrate stage; Epic 13 scope; AC 4 operator-workstation-deferred by AC contract per Dev Notes:149) |
| P3        | 0              | 0             | 100%       | ✅ PASS (n/a) |
| **Total** | **5**          | **0**         | **0%**     | **⚠️ WAIVED** |

**Legend:**

- ✅ PASS - Coverage meets quality gate threshold
- ⚠️ WARN / WAIVED - Coverage below threshold but not critical OR waiver applies
- ❌ FAIL - Coverage below minimum threshold (blocker)

---

### Detailed Mapping

#### AC-1: No `curl localhost:3000` in the healthcheck; TODO marker replaced with real block (P2)

- **Coverage:** NONE (WAIVED) ⚠️
- **Tests:** _(no automated tests — Epic 13 scope)_
- **Substrate-verification:** iter-283 `/bmad-dev-story` recovery-landing impl-time smokes. Relevant to AC 1: (i) `grep -c '3000' packages/devbox/docker-compose.yml` returns exactly 2 matches — line 167 `KEEL_DEVBOX_PORT_WEB:-3000` publish (Story 2.2 Web port knob; expected per story-file Dev Notes:149) + line 264 prose reference string `"upstream's broken \`curl :3000\` healthcheck"` inside the Story 2.13 healthcheck block comment (meta-reference, not a live invocation). Zero `curl localhost:3000` live invocations. (ii) The TODO marker `# TODO(Story 2.13): healthcheck dnsmasq + sshd liveness.` at `docker-compose.yml:263` replaced with a `CMD-SHELL` `healthcheck:` block composed via YAML `>-` folded-scalar two-clause POSIX-sh string. (iii) Story-roadmap line at `docker-compose.yml:24` converted to past tense `LANDED iter-283` matching Stories 2.2 / 2.3 / 2.5 / 2.11 / 2.12 roadmap-line pattern. (iv) Manifest sync-gate `pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check` GREEN post rebuild with `INV-devbox-healthcheck` registered binding `docs/invariants/devbox-healthcheck.md § No curl :3000` via contentHash `665174a3592106eabbb9f6b5dd39ce813839b3c61a89f1709d81e90524d18623` (33rd manifest entry).
- **Gaps (WAIVED — defer per ground-(a) substrate-verification + ground-(b) no-test-runner):**
  - Missing: live `docker compose -f packages/devbox/docker-compose.yml config --format json | jq '.services.devbox.healthcheck.test'` returning the two-clause CMD-SHELL string; operator-workstation-deferred backend-A.
  - Missing: live `docker inspect --format '{{.State.Health.Status}}' keel-devbox` returning `healthy` within 30-40s of `pnpm devbox:start` (no longer the persistent `unhealthy` noise of upstream's `curl :3000`); operator-workstation-deferred backend-A.
- **Recommendation:** Accept WAIVED verdict. Substrate-verification covers the YAML layer + sync-gate + negative assertion (no live `curl localhost:3000`); live docker-compose-config emit + docker-inspect-Health-Status smokes deferred to M4-Pro operator workstation backend-A.

---

#### AC-2: dnsmasq liveness probe — DNS query against `127.0.0.1:53` resolving `api.github.com` (P2)

- **Coverage:** NONE (WAIVED) ⚠️
- **Tests:** _(no automated tests — Epic 13 scope)_
- **Substrate-verification:** iter-283 `/bmad-dev-story` recovery-landing impl-time smokes. Relevant to AC 2: (i) `dash -n` POSIX-sh syntax-parse on the joined healthcheck CMD string (`dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com >/dev/null && { [ "${KEEL_DEVBOX_SSH:-false}" != "true" ] || nc -z 127.0.0.1 2222; }`) returned exit 0 — clean POSIX-shell parse, no bashisms, no `[[ ... ]]`, no arrays, `{...;}` grouping with terminal `;` before `}` per POSIX sh. (ii) `grep -n 'dnsutils' packages/devbox/Dockerfile` confirms line 61 — `dig` is baked via `/usr/bin/dig` on Ubuntu 24.04 apt install, no PATH issue under USER `dev` per `Dockerfile:347`. `dig` opens a UDP client socket on a high ephemeral port (no `CAP_NET_BIND_SERVICE` needed) — succeeds under Story 2.5 `cap_drop: [ALL]` + three-cap allow as UID 1000. (iii) Three-site `api.github.com` lockstep verified: (a) compose healthcheck CMD string, (b) `docs/invariants/devbox-healthcheck.md § Probe contract + § Probe domain stability`, (c) `packages/devbox/README.md § Healthcheck (Story 2.13)`. (iv) `grep -n 'api.github.com' packages/devbox/whitelist/github.txt` confirms line 8 — probe domain is always-whitelisted per Story 2.3 default fragment + Story 2.9 gh-auth load-bearing substrate (the only whitelist fragment guaranteed to be load-bearing for every fork because `gh auth login` / `gh push` depend on it). (v) `dig +short +time=3 +tries=1` exit-code semantics: exit 0 on successful DNS transaction including NXDOMAIN responses (NXDOMAIN counts as success for liveness — measuring dnsmasq RESPONSIVENESS, not whitelist membership); exit 9 on resolver timeout / connection refused; exit 10 on fatal error.
- **Gaps (WAIVED — defer per ground-(a) substrate-verification + ground-(b) no-test-runner):**
  - Missing: live `dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com` from inside `pnpm devbox:shell` returning DNS response + exit 0; operator-workstation-deferred backend-A.
  - Missing: live `docker inspect --format '{{json .State.Health}}' keel-devbox` emitting `"Status":"healthy"` + healthcheck-history entries with `{"ExitCode":0,"Output":""}` after `start_period: 30s` elapses; operator-workstation-deferred backend-A.
- **Recommendation:** Accept WAIVED verdict. Substrate-verification covers the POSIX-sh parse + tooling-baked + three-site probe-domain lockstep + whitelist-fragment-load-bearing layers; live dig-probe-exit + docker-inspect-healthcheck-history smokes deferred to M4-Pro operator workstation backend-A.

---

#### AC-3: Conditional sshd liveness probe when `KEEL_DEVBOX_SSH=true`; no healthcheck difference under `false` (P2)

- **Coverage:** NONE (WAIVED) ⚠️
- **Tests:** _(no automated tests — Epic 13 scope)_
- **Substrate-verification:** iter-283 `/bmad-dev-story` recovery-landing impl-time smokes. Relevant to AC 3: (i) `grep -n 'netcat-openbsd' packages/devbox/Dockerfile` confirms line 64 — `nc` baked via `/usr/bin/nc.openbsd` on Ubuntu 24.04; BSD variant supports `-z` (zero-byte probe / scan mode). `netcat-traditional` does NOT support `-z` and is NOT installed — load-bearing apt-manager pin per Story 1.15 Renovate. `nc -z` opens a TCP client socket to `127.0.0.1:2222` (no capability needed). (ii) `grep -E '^ListenAddress' packages/devbox/sshd/sshd_config` returns empty — Story 2.12 iter-266 PATCH-F4 deliberately leaves the directive unset so OpenSSH listens on all local addresses (IPv4 `0.0.0.0` + IPv6 `::`), which includes `127.0.0.1:2222` for `nc -z` IPv4 probe to connect (verification smoke PATCH-4 PASS per story file Task 2; AGENTS.md § Opt-in SSH (Story 2.12) "Container-side `ListenAddress` is INTENTIONALLY unset" — loopback confinement is enforced solely by the host-side `127.0.0.1:2222:2222` publish in `docker-compose.ssh.yml`). (iii) POSIX-shell branching analysis: `[ "${KEEL_DEVBOX_SSH:-false}" != "true" ] || nc -z 127.0.0.1 2222` — under `KEEL_DEVBOX_SSH=false/unset` the test evaluates TRUE (left operand `false` != `true`), short-circuits past `||` → `nc` NOT invoked; under `KEEL_DEVBOX_SSH=true` the test evaluates FALSE → `nc -z 127.0.0.1 2222` runs + its exit code governs. The outer `&&` pairing with clause 1 ensures both must succeed for exit 0 per POSIX `&&` short-circuit semantics. (iv) `KEEL_DEVBOX_SSH_RESOLVED` canonical env-propagation via Story 2.12 iter-273 PATCH-2 (compose `environment:` block sources the normalised stream) ensures case-folded `true` reaches the container — raw case variants (`True`/`TRUE`/`tRuE`) NEVER reach the probe. (v) Manifest sync-gate GREEN post rebuild with `INV-devbox-healthcheck` binding `§ SSH-conditional branch`.
- **Gaps (WAIVED — defer per ground-(a) substrate-verification + ground-(b) no-test-runner):**
  - Missing: live `KEEL_DEVBOX_SSH=true pnpm devbox:start` → `docker inspect --format '{{json .State.Health}}' keel-devbox` emits a healthcheck-history entry with the joined two-clause CMD string executed + exit 0 under opt-in; operator-workstation-deferred backend-A.
  - Missing: live `nc -z 127.0.0.1 2222` from inside `pnpm devbox:shell` under opt-in returning exit 0 (TCP three-way-handshake + immediate close); operator-workstation-deferred backend-A.
  - Missing: live `KEEL_DEVBOX_SSH=false` default-mode observation that healthcheck remains single-probe (dnsmasq only) — verify no TCP probe to :2222 attempted in no-SSH mode; operator-workstation-deferred backend-A.
- **Recommendation:** Accept WAIVED verdict. Substrate-verification covers the BSD-nc tooling pin + sshd_config-ListenAddress-unset + POSIX-branching logic + Story-2.12-env-propagation-canonical-stream + manifest sync-gate layers; live conditional-probe exit-code observation smokes deferred to M4-Pro operator workstation backend-A.

---

#### AC-4: Mid-run service death transitions container to `unhealthy` after `retries: 3` failures (P2)

- **Coverage:** NONE (WAIVED) ⚠️
- **Tests:** _(no automated tests — operator-workstation-deferred by AC contract per Dev Notes:149)_
- **Substrate-verification:** AC 4 is pre-declared operator-workstation-only by story-file Dev Notes:149 (_"Operator-workstation deferral (Story 2.5 iter-186 substrate-smoke posture; AC 4 live SIGKILL infeasible under DinD backend B cap-dropped semantics). Trace-gate per-AC `defer:` candidate."_). DinD backend B iteration env cannot safely exercise mid-run `docker exec pkill -SIGKILL dnsmasq` / `pkill -SIGKILL sshd` against cap-dropped containers — AGENTS.md § Devbox iteration environment § safety rule critical under backend B flags broad-state-mutation + destructive ops under host-socket passthrough as poisoning-adjacent-host-project risk. Substrate-verification: (i) Healthcheck timing parameters `interval: 10s` / `timeout: 5s` / `retries: 3` / `start_period: 30s` set in compose block per Dev Notes contract; verified by shape inspection of the healthcheck YAML block at `docker-compose.yml:263-270`. Retries=3 with interval=10s yields 30s detection latency post-start-period — standard Docker HEALTHCHECK state-machine contract (upstream Docker daemon owns the retry accumulator + `State.Health.Status` transition; Story 2.13 probe is the trigger, not the consumer of state). (ii) `pnpm devbox:status` consumer at `status.sh:54` reads `docker inspect --format '{{.State.Health.Status}}'` unchanged from Story 2.6 substrate — Story 2.13 unblocks the branch consumers already query by supplying the probe that produces meaningful state (no longer perpetual `starting` stub or persistent `unhealthy` noise of upstream's broken `curl :3000`). (iii) `start.sh:92-120` healthcheck poll loop (Story 2.6 AC 2.6.4) and `start.sh:103` unhealthy-but-running branch unchanged — Story 2.13 adds the probe, not the consumer. (iv) `INV-devbox-healthcheck § Timing parameters` pins the four values via contentHash `665174a3592106eabbb9f6b5dd39ce813839b3c61a89f1709d81e90524d18623`; sync-gate (Story 1.9) detects drift mechanically. (v) Dev Notes Task 5 D-1 absorption (iter-283) pre-creates `/var/log/sshd.log` via Dockerfile `install -m 0644 -o root -g root /dev/null /var/log/sshd.log` at `:318-330` pre-gosu — operator diagnostic pointer in AGENTS.md § Healthcheck § Agent diagnostic pointer (`docker inspect State.Health.Status: unhealthy` → queue `pnpm devbox:logs` + `/var/log/sshd.log` inspect) is unblocked by this pre-create.
- **Gaps (WAIVED — defer per ground-(c) HYBRID variant-(ii) operator-workstation-deferred-AC-completion):**
  - Missing: live `pnpm devbox:start` → observe `docker inspect --format '{{.State.Health.Status}}' keel-devbox` transition `starting → healthy` within 30-40s; `docker exec keel-devbox pkill -SIGKILL dnsmasq` (backend-A only — operator workstation); observe `{{.State.Health.Status}}` transition `healthy → unhealthy` within next 30s (3 × 10s interval); `pnpm devbox:status` surfaces `unhealthy` state to operator; operator-workstation-only backend-A.
  - Missing: analogous live sshd SIGKILL sequence under `KEEL_DEVBOX_SSH=true` opt-in mode — `docker exec keel-devbox pkill -SIGKILL sshd` produces same healthy → unhealthy transition via the nc -z clause failing; operator-workstation-only backend-A.
  - Missing: live `docker inspect --format '{{json .State.Health.Log}}' keel-devbox` emits `ExitCode != 0` + `Output` capture for the 3 consecutive failing probes before the `Status` flips; operator-workstation-only backend-A.
- **Recommendation:** Accept WAIVED verdict per spec-declared operator-workstation-deferral (Story 2.13 Dev Notes:149 affirmatively pre-declares AC 4 operator-workstation-only at the substrate stage). Forthcoming `/bmad-code-review (args: "2")` adversarial envelope (Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out) provides designated adversarial backstop for substrate-correctness of the timing-shape + consumer-branch + Docker-state-machine-contract layers.

---

#### AC-5: Healthcheck timing parameters documented with rationale (P2)

- **Coverage:** NONE (WAIVED) ⚠️
- **Tests:** _(no automated tests — Epic 13 scope)_
- **Substrate-verification:** iter-283 `/bmad-dev-story` recovery-landing impl-time smokes. Relevant to AC 5: (i) Compose healthcheck block inspection — `interval: 10s` / `timeout: 5s` / `retries: 3` / `start_period: 30s` all present at `docker-compose.yml:263-270` per contract. (ii) `docs/invariants/devbox-healthcheck.md § Timing parameters` documents all four values with per-knob rationale: `interval 10s` (6 probes/min/service; dnsmasq JSONL log volume ~8640 queries/day documented for FR37 Epic-4 security-evidence consumer); `timeout 5s` (dig worst-case 3s + nc worst-case 1s = 4s margin under 5s timeout); `retries 3` (30s detection latency post-start-period; transient-glitch tolerance vs real-failure detection speed balance); `start_period 30s` (entrypoint init budget start-egress.sh 3-5s for nftables + dnsmasq + resolv.conf pin; sshd ~1s under opt-in; 30s covers cold-boot + first-probe latency; failures during this window don't count against `retries`). (iii) `packages/devbox/README.md § Healthcheck (Story 2.13)` H2 section appended between `## Opt-in SSH (Story 2.12)` H2 and `## cc-devbox upstream provenance` H2 (SC-17 sibling-append discipline — prior story sections UNCHANGED) with four-row timing-parameter rationale table mirroring the invariant doc + two operator walkthroughs (default mode `KEEL_DEVBOX_SSH=false` / opt-in sshd walkthrough with manual `pkill sshd` from inside `pnpm devbox:shell`). (iv) `packages/devbox/README.md:921` forward-ref `Broken curl :3000 healthcheck → Story 2.13 …` converted to past-tense `→ fixed in Story 2.13 … LANDED iter-283` per SC-17. (v) `AGENTS.md § Healthcheck (Story 2.13)` H3 appended after `### Opt-in SSH (Story 2.12)` within § Devbox iteration environment — operator-facing agent-diagnostic pointer + probe-tooling-baked pin (dnsutils + netcat-openbsd; BSD-nc load-bearing for `-z`) + probe-domain-lockstep (three-site `api.github.com` + `github.txt:8`) + SSH-conditional-branch (env-propagation via Story 2.12 iter-273 PATCH-2) + timing-substrate-authoritative (no `KEEL_DEVBOX_*` knob; AMEND-path for fork-local adjustment) + scope-carve-out (compose-level only; no Dockerfile `HEALTHCHECK` directive for fork maintainer raw `docker run` paths) + cross-reference. (vi) Manifest sync-gate GREEN post rebuild with `INV-devbox-healthcheck` binding `§ Timing parameters`. Three-site timing-values lockstep: compose + invariant doc + README all carry `interval 10s` / `timeout 5s` / `retries 3` / `start_period 30s`; future drift detected by sync-gate contentHash binding.
- **Gaps (WAIVED — defer per ground-(a) substrate-verification + ground-(b) no-test-runner):**
  - Missing: live `docker inspect --format '{{json .Config.Healthcheck}}' keel-devbox` emitting the four canonical timing values; operator-workstation-deferred backend-A.
  - Missing: automated lockstep drift lint (SC-17 close-out D-5 per Story 2.13 pre-dev SM iter-281) mechanically enforcing three-site `api.github.com` + timing-values sync across compose + invariant doc + README; deferred to Story 2.17 polish pass.
- **Recommendation:** Accept WAIVED verdict. Substrate-verification covers the four-knob timing-value presence + invariant-doc rationale + README operator-walkthroughs + AGENTS.md agent-guardrails + SC-17 forward-ref past-tense layers; live docker-inspect-Config.Healthcheck smoke + SC-17 automated lockstep lint deferred to Epic 2 close-out.

---

### Gap Analysis

#### Critical Gaps (BLOCKER) ❌

0 gaps found. No P0 requirements exist for Story 2.13 (all 5 ACs at P2 per Epic-2-substrate precedent).

---

#### High Priority Gaps (PR BLOCKER) ⚠️

0 gaps found. No P1 requirements exist for Story 2.13.

---

#### Medium Priority Gaps (WAIVED via ground-(a)+(b)+(c) hybrid) ⚠️

5 gaps found. **All WAIVED per gate rationale — no test runner at Story 2.13 substrate stage (Epic 13 scope); substrate-verification covers ACs 1, 2, 3, 5 runtime branches at iter-283 dev-story recovery impl-time smokes; AC 4 operator-workstation-deferred by AC contract (Dev Notes:149).**

1. **AC-1: No `curl localhost:3000`; TODO marker replaced** (P2) — WAIVED
   - Current Coverage: NONE (no automated tests)
   - Substrate-verification: iter-283 grep-based negative-assertion (2 `3000` matches both expected — Story-2.2 publish + Story-2.13 comment prose) + manifest sync-gate GREEN (`INV-devbox-healthcheck` contentHash-binds `§ No curl :3000`) + Story-roadmap past-tense update
   - Recommend: operator-workstation backend-A live `docker compose config` + `docker inspect State.Health.Status` smoke at Epic 2 close-out

2. **AC-2: dnsmasq liveness probe via `dig @127.0.0.1:53 api.github.com`** (P2) — WAIVED
   - Current Coverage: NONE (no automated tests)
   - Substrate-verification: dash -n POSIX parse GREEN + dnsutils baked at Dockerfile:61 + three-site `api.github.com` lockstep + whitelist/github.txt:8 load-bearing + dig exit-code semantics contract
   - Recommend: operator-workstation backend-A live dig-probe + docker-inspect healthcheck-history smokes

3. **AC-3: Conditional `nc -z 127.0.0.1 2222` under `KEEL_DEVBOX_SSH=true`** (P2) — WAIVED
   - Current Coverage: NONE (no automated tests)
   - Substrate-verification: netcat-openbsd baked at Dockerfile:64 (BSD -z load-bearing) + sshd_config ListenAddress unset (Story 2.12 PATCH-F4) + POSIX branching analysis short-circuit logic + Story-2.12 env-propagation canonical stream + manifest sync-gate
   - Recommend: operator-workstation backend-A live `KEEL_DEVBOX_SSH=true/false` conditional-probe observation smokes

4. **AC-4: Mid-run service death → `State.Health.Status: unhealthy` after retries=3** (P2) — WAIVED
   - Current Coverage: NONE (operator-workstation-deferred by AC contract — live SIGKILL infeasible under DinD backend B cap-dropped semantics per Dev Notes:149)
   - Substrate-verification: timing-shape inspection (interval 10s / timeout 5s / retries 3 / start_period 30s) + Story-2.6 consumer-branch unchanged (status.sh:54 + start.sh:103) + Docker state-machine upstream contract + Task 5 D-1 absorption `/var/log/sshd.log` pre-create unblocks AGENTS.md diagnostic pointer
   - Recommend: operator-workstation backend-A live pkill-SIGKILL sequence + retry-accumulator + State.Health.Status transition smoke; spec-declared operator-workstation-deferral from Dev Notes:149

5. **AC-5: Timing parameters documented with rationale** (P2) — WAIVED
   - Current Coverage: NONE (no automated tests)
   - Substrate-verification: compose block four-knob presence + invariant-doc § Timing parameters per-knob rationale + README H2 four-row rationale table + two operator walkthroughs + SC-17 forward-ref past-tense + AGENTS.md H3 six-guardrails + three-site timing-values lockstep via contentHash binding
   - Recommend: operator-workstation backend-A live `docker inspect Config.Healthcheck` smoke + SC-17 automated lockstep drift lint (D-5 Story 2.17 close-out)

---

#### Low Priority Gaps (Optional) ℹ️

0 gaps found. No P3 requirements exist for Story 2.13.

---

### Coverage Heuristics Findings

#### Endpoint Coverage Gaps

- Endpoints without direct API tests: 0 — Story 2.13 does NOT add API surface; compose healthcheck block + Dockerfile log-pre-create + invariant doc + README H2 + AGENTS.md H3 are substrate YAML/Dockerfile/doc concerns, not API endpoints.

#### Auth/Authz Negative-Path Gaps

- Criteria missing denied/invalid-path tests: 0 (not applicable — Story 2.13 has no auth surface; healthcheck probes dnsmasq (DNS query) + sshd TCP handshake, neither of which exercises authentication; sshd pubkey auth remains Story 2.12 substrate contract and is explicitly NOT exercised by `nc -z` per invariant doc § Probe contract).

#### Happy-Path-Only Criteria

- Criteria missing error/edge scenarios: 0 — AC 4 IS the mid-run-failure criterion (State.Health.Status transition to `unhealthy` on 3 consecutive probe failures); AC 2 covers the happy-path dnsmasq probe; AC 3 covers the conditional sshd probe under opt-in AND the no-probe-difference observation under default false. Substrate-verification covers happy-path (AC 2 + AC 3 opt-in) AND closed-path (AC 3 default false short-circuit logic) AND failure-path (AC 4 via timing-shape + consumer-branch + Docker-state-machine contract + Task 5 D-1 `/var/log/sshd.log` pre-create).

#### UI Journey Coverage

- Criteria missing UI-level coverage: not applicable — Story 2.13 has no UI surface.

#### UI State Coverage

- Criteria missing state-coverage assertions: not applicable — Story 2.13 has no UI surface.

---

### Quality Assessment

#### Tests with Issues

_(no tests exist — no-op)_

---

#### Tests Passing Quality Gates

_(0 / 0 tests — no-op; substrate-smokes are documented in iter-283 Dev Agent Record § Debug Log References, not wired as automated regressions)_

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

1. **Accept WAIVED verdict per TWENTY-THIRD cumulative trace-WAIVED precedent + TWENTY-FOURTH ATDD-skip-trace-WAIVED pairing.** Story 2.13 is a direct extension of the Epic-2-substrate pattern established at Stories 2.1-2.12; ground-(a)+(b)+(c) hybrid conjunction applies with operator-workstation-deferred-AC-completion variant-(ii) for AC 4. Queue `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification next per § Story Lifecycle Decision Matrix row `traced → sm-verified`.

2. **Reaffirm iter-257 LESSON on manifest rebuild discipline at iter-283 (recovery-iter variant).** `pnpm --filter @keel/keel-invariants build` MUST precede `pnpm keel-invariants:check` after adding a new `InvariantSchema` entry — including when verifying inherited WIP from a killed-pre-commit prior iter (iter-283 recovery precedent matching iter-268 Story 2.12 recovery pattern). iter-283 Completion Notes pins the observation; carry-forward guardrail remains for Stories 2.14..2.17 dev-story landings.

#### Short-term Actions (This Milestone)

1. **Operator-workstation backend-A live smokes at Epic 2 close-out (Story 2.17-adjacent polish pass).** Five live smokes deferred per ground-(c) + spec-declared operator-workstation-deferral: (a) `docker compose config` healthcheck-test emit returning the CMD-SHELL two-clause string; (b) `dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com` from inside `pnpm devbox:shell` returning DNS response + exit 0; (c) `KEEL_DEVBOX_SSH=true` opt-in `nc -z 127.0.0.1 2222` returning exit 0 + healthcheck-history entry; (d) `docker exec keel-devbox pkill -SIGKILL dnsmasq` → `State.Health.Status: healthy → unhealthy` transition within 30s; analogous sshd SIGKILL sequence; (e) `docker inspect --format '{{json .Config.Healthcheck}}'` emit returning the four canonical timing values. No Story 2.13 code change required at any live-flow verification point — compose healthcheck block + Dockerfile log-pre-create + invariant doc are stateless contracts; upstream Docker daemon + dnsmasq + sshd + dig + nc contracts are convention-stable.

2. **CR adversarial envelope fan-out** via `/bmad-code-review (args: "2")` at the next QUEUE item after `traced → sm-verified`. Three-layer Ralph-hosted triage: Blind Hunter (`bmad-agent-architect` diff-only) + Edge Case Hunter (`bmad-tea` diff+project-read) + Acceptance Auditor (`bmad-agent-dev` diff+spec+INV). Forecast 1-3 first-class PATCH per iter-264 LESSON moderate-novelty band + iter-277 NOVEL LESSON #2 META guard carry-forward — narrower than Story 2.12 novel-runtime-behaviour outlier since Story 2.13 inherits Story 2.12's KEEL_DEVBOX_SSH env propagation + Story 2.6's status.sh consumer branch + Story 2.5's cap-dropped runtime unchanged (no new resolver function, no new compose override file, no new background daemon). Story 2.13 is EIGHTH one-pass ZERO-PATCH CR precedent candidate if pre-dev SM v1.1 6-PATCH + 3-DEFER absorption holds across the single novel-surface vector (POSIX-sh probe-composition inside YAML folded-scalar).

#### Long-term Actions (Backlog)

1. **Epic 13 test framework landing** unblocks mechanical automation of ACs 1, 2, 3, 5 (AC 4 remains operator-workstation-only by AC contract pending physical peer infrastructure beyond Epic 13 scope). Carry-forward target for `packages/devbox/tests/` vitest suites per Story 13.* scope — compose-config healthcheck-test-string inspection + dash-POSIX-parse regression + Dockerfile apt-layer grep + sshd_config ListenAddress-absence grep + three-site lockstep drift checks are all mechanically-regression-safe.

2. **Automated three-site lockstep drift lint (SC-17 candidate; Story 2.13 pre-dev SM iter-281 DEFER D-5).** Story 2.13 introduces the convention of three-site `api.github.com` + timing-values lockstep across compose + invariant doc + README; a future keel-invariants lint could mechanically enforce the lockstep. Defer to Story 2.17 Epic 2 close-out polish pass / Epic 13 scope.

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
- **P2 Tests**: 0/0 (n/a — 5 P2 ACs uncovered)
- **P3 Tests**: 0/0 (n/a)

**Overall Pass Rate**: n/a (no tests)

**Test Results Source**: not_applicable

---

#### Coverage Summary (from Phase 1)

**Requirements Coverage:**

- **P0 Acceptance Criteria**: 0/0 (100% — n/a) ✅
- **P1 Acceptance Criteria**: 0/0 (100% — n/a) ✅
- **P2 Acceptance Criteria**: 0/5 (0%)
- **Overall Coverage**: 0%

**Code Coverage**: not measured (no test runner)

---

#### Non-Functional Requirements (NFRs)

**Security**: PASS ✅ — Healthcheck probe runs as USER `dev` UID 1000 (Dockerfile:347) under Story 2.5 `cap_drop: [ALL]` + three-cap allow (NET_ADMIN / NET_RAW / NET_BIND_SERVICE). `dig` opens a UDP client socket on a high ephemeral port + `nc -z` opens a TCP client socket to 127.0.0.1:2222 — neither requires capability escalation. Probe domain `api.github.com` is always-whitelisted (Story 2.3 default fragment + Story 2.9 gh-auth load-bearing); no new external attack surface. Healthcheck does NOT exercise sshd pubkey authentication — `nc -z` only verifies TCP three-way-handshake, avoiding test-key fragility and preserving Story 2.12 pubkey-only auth trust model. No Dockerfile `HEALTHCHECK` directive (compose-authoritative; raw `docker run` path does not carry the probe — prevents operator-confusion in fork-maintainer image-inspection flows). `/var/log/sshd.log` pre-create (Task 5 D-1 absorption) is mode 0644 owned root:root pre-gosu — DAC invariant preserved (iter-281 PATCH-6 pattern carry-forward from Story 2.12).

**Performance**: PASS ✅ — Healthcheck runs every 10s (6 probes/min/service = 8640 dnsmasq queries/day; accrues in existing Story 2.3 `egress-queries.jsonl` JSONL log documented for FR37 Epic-4 security-evidence consumer). Single-probe worst-case wall-time: `dig +time=3 +tries=1` worst case 3s + `nc -z` worst case ~1s = 4s combined, 1s margin under `timeout: 5s`. Retries=3 with interval=10s yields 30s detection latency post-start-period (balances transient-glitch tolerance against real-failure detection speed). `start_period: 30s` covers entrypoint init budget (start-egress.sh 3-5s for nftables + dnsmasq + resolv.conf pin; sshd ~1s under opt-in) comfortably without counting first-boot glitches against retries.

**Reliability**: PASS ✅ — POSIX-shell safe syntax (`dash` compatible, no bashisms, no `[[ ... ]]`, no arrays); `dash -n` parse GREEN at iter-283. Probe survives YAML folded-scalar joining (two clause lines adjacent; blank-line preservation hazard averted per iter-281 PATCH-3 story-level guard + iter-276 NOVEL LESSON on word-splitting hazard-class discrimination). Exit-code semantics preserved (Docker HEALTHCHECK consumes `0 = healthy`, any non-zero = unhealthy; exit codes 1/9/10 all map uniformly to unhealthy state and preserved in `docker inspect` for operator introspection; Docker's internal exit code 2 reserved — probe authors SHOULD NOT return 2). SSH-conditional branch reads `KEEL_DEVBOX_SSH_RESOLVED` canonical stream from Story 2.12 iter-273 PATCH-2 env propagation; raw case variants never reach the probe. No runtime toggle-able bypass — timing substrate-authoritative per § Timing parameters; fork-local adjustment requires AMEND PR per FR44 AMEND path.

**Maintainability**: PASS ✅ — Three-site lockstep discipline (compose + invariant doc + README) across `api.github.com` probe domain + timing values + SSH-conditional branch logic. New `INV-devbox-healthcheck` (33rd manifest entry) binds doc via `contentHash 665174a3592106eabbb9f6b5dd39ce813839b3c61a89f1709d81e90524d18623`; sync-gate (Story 1.9) detects drift mechanically. AGENTS.md § Healthcheck H3 provides six agent-guardrails including diagnostic pointer (`State.Health.Status: unhealthy` → `pnpm devbox:logs` + `/var/log/sshd.log` inspect — unblocked by Task 5 D-1 absorption of pre-create). `packages/devbox/README.md § Healthcheck` four-row timing-rationale table + two operator walkthroughs provides operator-visibility per AC 5 contract. Story-roadmap line at `docker-compose.yml:24` past-tense update + `README.md:921` forward-ref past-tense update preserves SC-17 sibling-append discipline. Automated three-site lockstep drift lint candidate for SC-17 Story 2.17 close-out (D-5 pre-dev SM DEFER).

**NFR Source**: substrate documentation + iter-283 Dev Agent Record recovery-landing completion notes.

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
| P2 Coverage | 0% | WAIVED — 5 ACs at Epic-2-substrate posture; no test runner at 1.0 stage; AC 4 operator-workstation-deferred by AC contract per Dev Notes:149 |
| P3 Coverage | n/a | No P3 criteria exist |

---

### GATE DECISION: ⚠️ WAIVED

---

### Rationale

Epic-2-substrate-healthcheck-compose-probe class story (THIRTEENTH Epic 2 delivery; FIRST story combining (i) POSIX-sh probe-composition inside a YAML `>-` folded-scalar + (ii) Docker HEALTHCHECK state-machine consumer (interval 10s / timeout 5s / retries 3 / start_period 30s — upstream Docker daemon owns the retry accumulator + State.Health.Status transition) + (iii) multi-clause conditional-probe composition on the Story 2.12 `KEEL_DEVBOX_SSH` env var — distinct from Stories 2.1-2.12 non-healthcheck-layer extensions) shipping 1 NEW authoritative invariant doc + 1 NEW `INV-devbox-healthcheck` manifest entry (33rd) + `docker-compose.yml` healthcheck block replacing TODO marker (~12 LOC net-new) + `Dockerfile` Task 5 D-1 absorption (one-line `install -m 0644 -o root -g root /dev/null /var/log/sshd.log` pre-gosu) + Story-roadmap past-tense update + collateral INVARIANTS.md H3 + README H2 (with four-row timing-rationale table + two operator walkthroughs) + AGENTS.md H3 (with six agent-guardrails) + `README.md:921` SC-17 forward-ref past-tense update. Five ACs — all P2 per FR14n Epic-2-substrate precedent.

**TWENTY-THIRD cumulative trace-WAIVED precedent** extending Story 2.12 iter-269 twenty-second: Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57 + 1.12 iter-64 + 1.13 iter-71 + 1.14 iter-78 + 1.15 iter-85 + 1.16 iter-92 → 2.1 iter-126 → 2.2 iter-149 → 2.3 iter-159 → 2.4 iter-175 → 2.5 iter-188 → 2.6 iter-202 → 2.7 iter-224 → 2.8 iter-231 → 2.9 iter-242 → 2.10 iter-249 → 2.11 iter-258 → 2.12 iter-269 → 2.13 iter-284. TWENTY-FOURTH ATDD-skip-trace-WAIVED co-application pairing overall (extends iter-282 ATDD-skip grounds (c)+(ii)+(iii)).

**Ground-(a)+(b)+(c) hybrid conjunction applied:**

- **(a) Substrate-verification** covers ACs 1, 2, 3, 5 at the substrate layer via iter-283 recovery-landing impl-time smokes:
  - (i) `sha256sum docs/invariants/devbox-healthcheck.md` matches the manifest's `contentHash 665174a3592106eabbb9f6b5dd39ce813839b3c61a89f1709d81e90524d18623` — INVARIANT-doc bind verified.
  - (ii) `pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check` + `pnpm keel-invariants:check-all` all GREEN post manifest rebuild — 33 InvariantSchema entries; sync-gate (Story 1.9) confirms `INV-devbox-healthcheck` binding is drift-free. iter-257 NOVEL LESSON reaffirmed (recovery-iter variant): manifest rebuild MUST precede sync-gate check after adding a new `InvariantSchema` entry — applies equally when verifying inherited WIP from killed-pre-commit prior iter.
  - (iii) `dash -n` POSIX-sh syntax-parse on the joined healthcheck CMD string (`dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com >/dev/null && { [ "${KEEL_DEVBOX_SSH:-false}" != "true" ] || nc -z 127.0.0.1 2222; }`) returned exit 0 — clean POSIX-shell parse, no bashisms, no `[[ ... ]]`, no arrays, `{...;}` grouping with terminal `;` before `}` per POSIX sh.
  - (iv) Three-site `api.github.com` lockstep verified: compose healthcheck CMD + invariant doc § Probe contract + § Probe domain stability + README § Healthcheck (Story 2.13).
  - (v) Probe-tooling-baked verification: `dnsutils` at `Dockerfile:61` → `dig` at `/usr/bin/dig`; `netcat-openbsd` at `Dockerfile:64` → `nc` at `/usr/bin/nc.openbsd` with BSD `-z` support; `netcat-traditional` NOT installed (Renovate apt-manager-tracked per Story 1.15).
  - (vi) `grep -E '^ListenAddress' packages/devbox/sshd/sshd_config` returns empty (PATCH-4 verification PASS per story file Task 2; Story 2.12 iter-266 PATCH-F4 deliberately leaves directive unset so OpenSSH listens on IPv4 `0.0.0.0` + IPv6 `::` which includes `127.0.0.1:2222` for `nc -z` IPv4 probe).
  - (vii) Timing-values lockstep verified: `interval 10s` / `timeout 5s` / `retries 3` / `start_period 30s` present at compose `docker-compose.yml:263-270` + invariant doc § Timing parameters + README four-row rationale table.
  - (viii) AC-1 negative-assertion verified: `grep -c '3000'` returns exactly 2 matches — line 167 Story-2.2 `KEEL_DEVBOX_PORT_WEB:-3000` publish + line 264 prose meta-reference in the Story 2.13 healthcheck comment. Zero `curl localhost:3000` live invocations.
  - (ix) Story-2.12 env-propagation canonical stream unchanged: compose `environment:` block sources `KEEL_DEVBOX_SSH_RESOLVED` per iter-273 PATCH-2 — case-folded `true` reaches container, raw case variants NEVER reach the probe.

- **(b) No test runner wired** at Story 2.13 substrate stage — Epic 13 scope; recursive probe at iter-284 for `vitest.config.*` / `jest.config.*` / `playwright.config.*` / `cypress.config.*` / `pyproject.toml` / `go.mod` / `Gemfile` / `Cargo.toml` under the repo root (excluding `node_modules`, `.pnpm-store`, `_bmad/`) returns zero matches; `tests/` directories present only under `.claude/skills/bmad-*/scripts/tests/` (BMad skill internals, not application tests under `packages/`).

- **(c) HYBRID variant-(ii) operator-workstation-deferred-AC-completion** for AC 4 — Story 2.13 Dev Notes:149 affirmatively declares _"Operator-workstation deferral (Story 2.5 iter-186 substrate-smoke posture; AC 4 live SIGKILL infeasible under DinD backend B cap-dropped semantics). Trace-gate per-AC `defer:` candidate."_ DinD backend B iteration env cannot safely exercise mid-run `docker exec pkill -SIGKILL dnsmasq` / `pkill -SIGKILL sshd` against cap-dropped containers — AGENTS.md § Devbox iteration environment § safety rule critical under backend B flags these as poisoning-adjacent-host-project risk. AC 4 has runtime behaviour (mid-run probe failure + retry accumulator + State.Health.Status transition) but that behaviour is exercisable ONLY at operator workstation backend-A.

**Alternative partial-waive considered.** IP § NOW pre-declared the alternative at iter-284 orient: "ACs 1, 2, 3, 5 covered by impl-time smokes logged in iter-283 dev-story recovery landing; AC 4 operator-workstation-deferred" — i.e., WAIVE-with-grounds (partial) for AC 4 only with ACs 1, 2, 3, 5 substrate-covered. Elected full-waive per 23rd-cumulative-pairing consistency rule + `coverage_basis=acceptance_criteria` mechanical-matrix-absent at substrate stage (the Phase-1 matrix JSON schema does not carry a partial-waive vocabulary distinguishing "substrate-smoke covers branch X" from "automated regression covers branch X"). Full-waive under 23rd-cumulative-pairing precedent is the consistent + mechanically-unambiguous posture.

**The deterministic FAIL signal (overall 0% < 80%) is a structural false-positive** — no test runner is wired at Story 2.13 substrate stage. Live fresh-fork smokes (dig-probe + docker-inspect-healthcheck-history + SIGKILL + retry-accumulator + State.Health.Status transition + docker-inspect-Config.Healthcheck) require M4-Pro operator workstation backend-A where real Docker daemon + full container lifecycle + safe cap-dropped-container SIGKILL sequences are reproducible; DinD backend B iteration env's host-socket passthrough cannot safely exercise these without poisoning host daemon state (unrelated host-project ports + credentials + images).

---

### Residual Risks

1. **ACs 1-3 + AC 5 live substrate smokes operator-workstation-deferred**
   - **Priority**: P2
   - **Probability**: Low (substrate-smokes cover YAML + dash-POSIX-parse + tooling-baked + sshd_config-unset + env-propagation + sync-gate layers; live smokes verify Docker daemon HEALTHCHECK consumer behaviour against the substrate probe)
   - **Impact**: Medium (live probe-composition mismatch or timing-shape mis-consumption could surprise operator at Epic 2 close-out; AC 5 timing-values drift across three sites could accumulate without drift lint)
   - **Risk Score**: Low-Medium (probability × impact)
   - **Mitigation**: operator-workstation backend-A smokes at Epic 2 close-out (Story 2.17-adjacent polish pass); sync-gate contentHash binding detects invariant-doc drift; three-site `api.github.com` + timing-values lockstep provides drift-resistance
   - **Remediation**: Epic 13 test framework landing enables mechanical regression for ACs 1-3 + AC 5; SC-17 automated three-site lockstep drift lint (D-5 Story 2.17 close-out)

2. **AC 4 depends on real Docker daemon HEALTHCHECK state-machine semantics + safe mid-run SIGKILL sequences**
   - **Priority**: P2
   - **Probability**: Low (Docker's HEALTHCHECK state-machine contract is upstream-stable; timing parameters follow standard convention; dnsmasq + sshd SIGKILL → restart absence is explicit — the probe detects absence, no restart-loop semantics intended)
   - **Impact**: Medium (live mid-run failure detection could surprise operator if retry accumulator fails to trip as expected; Task 5 D-1 absorption (`/var/log/sshd.log` pre-create) unblocks the AGENTS.md diagnostic pointer for operator triage)
   - **Risk Score**: Low-Medium (probability × impact; depends on upstream Docker HEALTHCHECK contract which is convention-stable)
   - **Mitigation**: `INV-devbox-healthcheck § Timing parameters` pins the four timing values via contentHash; sync-gate detects drift; AGENTS.md + README.md + invariant doc provide three-site operator-doc lockstep; AGENTS.md diagnostic pointer + Task 5 D-1 `/var/log/sshd.log` pre-create unblock operator triage flow
   - **Remediation**: operator-workstation backend-A live smokes at Epic 2 close-out (Story 2.17-adjacent); Epic 13 test framework landing (AC 4 remains operator-workstation-only even under Epic 13 scope if vitest harness cannot safely exercise cap-dropped-container SIGKILL; physical peer infrastructure not needed for AC 4 unlike Story 2.12 AC 4 LAN-peer refusal)

**Overall Residual Risk**: LOW

---

### Waiver Details

**Original Decision**: ❌ FAIL (Rule 2: Overall coverage 0% < 80%)

**Reason for Failure**:

- Structural: no test runner wired at Story 2.13 substrate stage (Epic 13 scope)

**Waiver Information**:

- **Waiver Reason**: Epic-2-substrate-healthcheck-compose-probe class story — TWENTY-THIRD cumulative trace-WAIVED precedent + TWENTY-FOURTH ATDD-skip-trace-WAIVED pairing. Ground-(a)+(b)+(c) hybrid conjunction applied with substrate-verification + no-test-runner + operator-workstation-deferred-AC-completion variant-(ii) for AC 4 (live SIGKILL + retry accumulator + State.Health.Status transition). Consistent with Stories 2.1-2.12 Epic-2 substrate pattern.
- **Waiver Approver**: Ralph (autonomous gate via bmad-testarch-trace workflow; FR14n matrix row 3 precedent)
- **Approval Date**: 2026-04-24
- **Waiver Expiry**: Epic 13 (test framework landing) OR operator-workstation backend-A Epic 2 close-out smoke pass — whichever lands first; waiver does NOT apply to Story 2.17+ polish-pass re-trace or Epic 13 automation scope
- **Per-AC waiver posture**:
  - ACs 1, 2, 3, 5: substrate-verification-based; waiver EXPIRES when Epic 13 landing enables mechanical regression (mechanically reproducible at backend-A via compose-config healthcheck-test emit + dig-from-shell + nc-from-shell under opt-in + docker-inspect-Config.Healthcheck + three-site-lockstep drift lint).
  - AC 4: operator-workstation-deferred-AC-completion-based; waiver EXPIRES when operator-workstation backend-A Epic 2 close-out smoke runs pass (AC 4 mid-run SIGKILL + retry accumulator + State.Health.Status transition may be coverable by Epic 13 if vitest integration harness can safely stand up Docker + cap-dropped-container SIGKILL sequences; otherwise remains operator-workstation-only).

**Monitoring Plan**:

- `/bmad-code-review (args: "2")` adversarial envelope (Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out) at next lifecycle step
- sync-gate (Story 1.9) drift detection binds `INV-devbox-healthcheck` contract via contentHash
- operator-workstation backend-A live smokes at Epic 2 close-out polish pass (Story 2.17-adjacent)

**Remediation Plan**:

- **Fix Target**: Epic 13 (test framework landing) + Story 2.17 Epic 2 close-out operator-workstation smoke pass + SC-17 automated three-site lockstep drift lint
- **Due Date**: Epic 13 delivery window per sprint-status; Story 2.17 Epic 2 close-out
- **Owner**: Epic 13 story authors + Story 2.17 author
- **Verification**: automated regression suite in `packages/devbox/tests/` under vitest / playwright (framework TBD at Epic 13 scope) for ACs 1-3 + AC 5; operator-workstation backend-A smoke script for AC 4

**Business Justification**:

Story 2.13 is the THIRTEENTH delivery in Epic 2's substrate pattern — each prior story (2.1-2.12) has earned the same WAIVED verdict under the same ground-(a)+(b)+(c) hybrid conjunction. Breaking the pattern at Story 2.13 (e.g., insisting on automated tests before test framework lands) would require Epic 13 to land first, which inverts Epic dependency order. The cumulative substrate debt is tracked as Epic 13 scope; this trace gate preserves the convention without introducing scope-creep. The single novel-surface vector (POSIX-sh probe-composition inside YAML folded-scalar) received thorough adversarial triage at iter-281 pre-dev SM (6 PATCH + 3 DEFER absorbed including YAML-blank-line-preservation-hazard guard + BSD-nc-pin + sshd_config-ListenAddress-unset verification) which materially reduces the post-dev-SM + CR PATCH forecast.

---

### Gate Recommendations

#### For WAIVED Decision 🔓

1. **Deploy with Convention-Enforced Guardrails**
   - Substrate-smokes validate healthcheck CMD string (POSIX-sh parse) + tooling-baked pins (BSD-nc for `-z`) + three-site probe-domain lockstep + three-site timing-values lockstep + env-propagation canonical stream at iter-283 `/bmad-dev-story` recovery-landing Debug Log references; sync-gate binds invariant doc via contentHash
   - AGENTS.md + README.md + invariant doc all surface operator-discipline requirements (timing substrate-authoritative → AMEND path for fork adjustment; scope carve-out compose-only → raw `docker run` does not carry probe; diagnostic pointer unhealthy → `pnpm devbox:logs` + `/var/log/sshd.log` inspect)
   - Task 5 D-1 absorption unblocks AGENTS.md diagnostic pointer: `/var/log/sshd.log` pre-create pre-gosu preserves root:root ownership for sshd write-access under cap-dropped posture

2. **Post-Landing Monitoring**
   - `/bmad-code-review (args: "2")` adversarial envelope at next lifecycle step (forecast 1-3 first-class PATCH per iter-264 LESSON moderate-novelty band; narrower than Story 2.12 novel-runtime-behaviour outlier)
   - sync-gate drift detection on `INV-devbox-healthcheck` contentHash
   - operator-workstation backend-A live smokes at Epic 2 close-out

3. **Mandatory Remediation (Epic-Boundary)**
   - Epic 13 test framework landing unblocks mechanical regression for ACs 1-3 + AC 5; AC 4 may still require operator-workstation if vitest harness cannot safely exercise SIGKILL against cap-dropped containers
   - Story 2.17 Epic 2 close-out polish pass is the last opportunity to run live operator-workstation smokes + SC-17 three-site lockstep drift lint before Epic 2 PR merge

---

### Next Steps

**Immediate Actions** (this iteration + next):

1. Commit trace artefacts (this markdown + 3 JSONs) + update IP (Story State `in-dev → traced`; queue `/bmad-create-story (args: "review")` post-dev SM as next NOW)
2. Push to `origin feat/epic-2-packaged-devbox` (PR #230 Draft; no CI configured — `statusCheckRollup: []` carries unchanged)
3. Update RALPH.md Signposts with iter-284 trace-gate landing signpost

**Follow-up Actions** (next 1-3 iterations):

1. `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification per § Story Lifecycle row `traced → sm-verified`
2. `/bmad-code-review (args: "2")` adversarial envelope per § Story Lifecycle row `sm-verified → done`
3. Stories 2.14..2.17 sequential lifecycle (4 remaining substrate stories until Epic 2 close-out at Story 2.17)

**Stakeholder Communication**:

- Operator (Tthew): Story 2.13 trace-gated WAIVED per Epic-2-substrate convention; substrate-verification covers ACs 1, 2, 3, 5 runtime branches at iter-283 dev-story recovery impl-time smokes; AC 4 operator-workstation-deferred by AC contract
- Future Ralph iterations: carry-forward the POSIX-sh-probe-composition + YAML-folded-scalar-composition + Docker-HEALTHCHECK-state-machine-consumer + three-site-lockstep discipline pattern to Stories 2.14..2.17

---

## Integrated YAML Snippet (CI/CD)

```yaml
traceability_and_gate:
  traceability:
    story_id: '2.13'
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
      medium: 5
      low: 0
    quality:
      passing_tests: 0
      total_tests: 0
      blocker_issues: 0
      warning_issues: 0
    recommendations:
      - 'Accept WAIVED per TWENTY-THIRD cumulative trace-WAIVED precedent'
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
      traceability: '_bmad-output/test-artifacts/traceability/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md'
      nfr_assessment: substrate_docs_in_iter-283_dev_agent_record
      code_coverage: not_measured
    next_steps: 'queue /bmad-create-story (args: "review") post-dev SM; then /bmad-code-review (args: "2") CR; then Story 2.14'
    waiver:
      reason: 'Epic-2-substrate-healthcheck-compose-probe class; TWENTY-THIRD cumulative trace-WAIVED precedent; ground-(a)+(b)+(c) hybrid with operator-workstation-deferred-AC-completion variant-(ii) for AC 4'
      approver: 'Ralph (autonomous; FR14n matrix row 3)'
      expiry: 'Epic 13 test framework landing OR Epic 2 close-out operator-workstation backend-A smoke pass'
      remediation_due: 'Epic 13 delivery window + Story 2.17 Epic 2 close-out'
```

---

## Related Artifacts

- **Story File:** `_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md`
- **Test Design:** not applicable (Epic 13 scope)
- **Tech Spec:** `_bmad-output/planning-artifacts/prd.md` (§ Devbox Implementation Contract, healthcheck); `_bmad-output/planning-artifacts/architecture.md` (§ Executive summary, § Devbox compose layer)
- **Test Results:** not applicable (no test runner)
- **NFR Assessment:** substrate documentation + iter-283 Dev Agent Record recovery-landing completion notes
- **Test Files:** not applicable
- **Invariant Doc:** `docs/invariants/devbox-healthcheck.md` (new; contentHash `665174a3592106eabbb9f6b5dd39ce813839b3c61a89f1709d81e90524d18623`)
- **Manifest Entry:** `INV-devbox-healthcheck` (33rd entry) at `packages/keel-invariants/src/invariants.manifest.ts`

---

## Sign-Off

**Phase 1 - Traceability Assessment:**

- Overall Coverage: 0% (structural false-positive; WAIVED)
- P0 Coverage: 100% (n/a — no P0 ACs) ✅
- P1 Coverage: 100% (n/a — no P1 ACs) ✅
- Critical Gaps: 0
- High Priority Gaps: 0
- Medium Priority Gaps (WAIVED): 5

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
