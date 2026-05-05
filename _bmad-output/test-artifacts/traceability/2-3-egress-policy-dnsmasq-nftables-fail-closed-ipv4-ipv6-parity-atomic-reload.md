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
lastSaved: '2026-04-21'
workflowType: 'testarch-trace'
inputDocuments:
  [
    '_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    'INVARIANTS.md',
    'AGENTS.md',
    'CLAUDE.md',
    'RALPH.md',
    'docs/invariants/devbox-egress.md',
    'docs/invariants/devbox-dind.md',
    'packages/devbox/dnsmasq/dnsmasq.conf',
    'packages/devbox/nftables/egress.nft',
    'packages/devbox/whitelist.default.txt',
    'packages/devbox/whitelist/npm.txt',
    'packages/devbox/whitelist/anthropic.txt',
    'packages/devbox/whitelist/github.txt',
    'packages/devbox/scripts/start-egress.sh',
    'packages/devbox/scripts/reload-egress.sh',
    'packages/devbox/scripts/egress-log-tailer.sh',
    'packages/devbox/scripts/monitor.sh',
    'packages/devbox/docker-compose.yml',
    'packages/devbox/Dockerfile',
    'packages/devbox/entrypoint.sh',
    'packages/devbox/.envrc.example',
    'packages/devbox/README.md',
    'packages/devbox/VERSIONS.md',
    'packages/keel-invariants/src/invariants.manifest.ts',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/2-3-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 2.3 egress policy (fail-closed, IPv4/IPv6 parity, atomic reload)

**Target:** Story 2.3 — fail-closed egress policy via in-container dnsmasq (DNS authority + JSONL query log) + nftables (layer-3 default-deny IPv4 + IPv6) with atomic-reload semantics (flock + `nft -f` kernel-atomic + `kill -HUP dnsmasq`). Closes upstream cc-devbox bugs: divergent-whitelist-tooling, fail-open `/etc/resolv.conf` fallback to `8.8.8.8`, IPv6 default-deny gap. Five ACs delivered iter-158 via `/bmad-dev-story` single-iteration landing (13 Tasks / ~50 subtasks all green; 11 new files + 11 modified files exactly matching v1.2 forecast). Story State `in-dev` at iter-159 trace entry — iter-158 `/bmad-dev-story` completed AC 1–AC 5 end-to-end at template level with sync-gate exit 0 (consolidated `INV-devbox-egress-contract` contentHash `aad16a51aa1dc7527c0312e6b99217966d7f3f3478fb677dd347792e9cb6889b` locks the invariant doc against drift). Live runtime smokes (Task 12.1 – 12.8: resolv.conf pin probe, IPv4/IPv6 parity via `nft list chain`, positive/negative curl, atomic-reload preservation, JSONL schema round-trip, log-rotation threshold) are **backend-B operator-workstation-deferred** — iteration env (cc-devbox host-socket-passthrough per `INV-devbox-dind-available`) lacks kernel-nftables privilege + the bind-mount-denial precedent from Story 2.1 iter-127 applies; SC-7 verbatim commands + AC-mapped `docker exec` recipes pinned in `docs/invariants/devbox-egress.md § Verification` + `packages/devbox/README.md § Egress policy § Verification` for the operator close-out pass. Concrete dnsmasq + nftables apt-versions in `packages/devbox/VERSIONS.md § Egress policy` are placeholder pending next baked-image re-bake (Task 1.2 + 1.3 DEFER). Contrasts with Story 2.2's fully-in-iteration-executable substrate (docker compose config is pre-daemon YAML-time) + inherits Story 2.1's operator-owned carve-out pattern for runtime container smokes.

**Date:** 2026-04-21
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 2.3 § Acceptance Criteria lines 14–39)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md` (AC 1–AC 5)

---

Note: This workflow does not generate tests. Story 2.3 is an **infrastructure-security class substrate** story (THIRD of Epic 2 + FIRST of its class: dnsmasq daemon + nftables kernel rules + file-locked atomic-reload + JSONL log-tailer, all outside the Vitest/Playwright idiom — contrast Story 2.1 pure runtime-infrastructure and Story 2.2 hybrid infrastructure-smoke + configuration-surface) whose § Testing standards block (story lines 358-370 Dev-agent guardrails) + § Change Log v1.2 row (iter-157 ATDD-skip) explicitly declares:

> _"THIRTEENTH cumulative Epic ATDD-skip precedent (Stories 1.7 iter-14 + 1.8 iter-29 + 1.9 iter-36 + 1.10 iter-43 + 1.11 iter-50 + 1.12 iter-57 + 1.13 iter-64 + 1.14 iter-71 + 1.15 iter-83 + 1.16 iter-90 + 2.1 iter-98 + 2.2 iter-147 → 2.3 iter-157) — **third Epic 2 ATDD-skip** + **first 'infrastructure-security class' ATDD-skip** (Story 2.1 = infrastructure-smoke single-class; Story 2.2 = hybrid infrastructure-smoke + configuration-surface; Story 2.3 = infrastructure-security: dnsmasq daemon + nftables kernel rules + file-locked atomic-reload + JSONL log-tailer, all outside the Vitest/Playwright idiom). `/bmad-testarch-atdd` skill NOT invoked — preflight would HALT at Step 1.2 (zero-test-runner substrate: no vitest.config.*/jest.config.*/playwright.config.*/cypress.config.*/pyproject.toml/go.mod/Gemfile/Cargo.toml/csproj anywhere in tree; TEA test_framework: auto autodetects nothing; Epic 13 is the formal test-framework landing per PRD RS6). Rationale — ground (c) hybrid variant-(ii)+(iii): (ii) downstream integration-gate coverage (Story 2.5 hardening integration re-verifies AC 1/2/4/5 in cap_drop:[ALL] + user:dev + tmpfs context; Story 2.4 per-fork whitelist override exercises AC 4 atomic-reload primitive via whitelist.sh; Story 2.6 lifecycle CLI + Story 2.13 healthcheck exercise daemon posture end-to-end; Epic 4 FR37 security-evidence consumer hard-references SC-3 pinned JSONL schema); (iii) spec-declared adversarial coverage substitution — 12 Dev-agent Guardrails + 17 pinned scope-clarifications (SC-1 through SC-17) + forthcoming /bmad-code-review (args: \"2\") adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.3 substrate diff) substitute for red-phase scaffolds."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-157, per the hybrid ground-(a)-(b)-(c)-(d) variant-(ii)+(iii) rationale (substrate-verification-covers-AC + no-runner + Epic 13 test-runner landing + spec-declared-CR-substitution + upstream-provenance-precedent) pinned in `.ralph/@plan.md § Context` and RALPH.md Signposts 2026-04-21. **THIRTEENTH cumulative trace-WAIVED precedent** — third Epic 2 trace-WAIVED and first **infrastructure-security class** trace-WAIVED (Story 2.1 was pure runtime-infrastructure; Story 2.2 was hybrid infrastructure-smoke + configuration-surface; Story 2.3 introduces the daemon + kernel-rule + atomic-reload idiom). Under the ATDD-skip-trace-WAIVED co-application rule, this is the **FOURTEENTH pairing** overall (10 Epic-1 pairings + 2.1 + 2.2 + 2.3).

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

All five ACs are **infrastructure-security substrate** assertions over the Story 2.3 deliverables (AC 1: dnsmasq in-container DNS authority + `/etc/resolv.conf` pinned to `127.0.0.1:53` + upstream fail-open resolv.conf gap closed; AC 2: nftables default-policy DROP IPv4 + IPv6 parity; AC 3: JSONL query log at `/workspace/logs/egress-queries.jsonl` with 50 MB + 5-generation rotation; AC 4: atomic reload via flock + `nft -f` kernel-atomic + `kill -HUP dnsmasq`; AC 5: fail-closed unwhitelisted curl — DNS NXDOMAIN AND TCP reject). Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` consistent with Story 2.1 + 2.2 precedent (no P0 auth/payment/data-loss at substrate; no P1 primary user journey — end-user only sees the effect post-Story-2.4 whitelist.sh CLI + post-Story-2.6 pnpm devbox:whitelist wrapper). Downstream test-runner landing may retro-classify AC 5 fail-closed-block as P1 (hard blocker to core use per runtime-harm taxonomy); Story 2.3 ships P2-uniform matching Stories 2.1 + 2.2 precedent.

---

### Detailed Mapping

#### AC-1: dnsmasq in-container DNS authority + `/etc/resolv.conf` points only at `127.0.0.1:53` + upstream fail-open resolv.conf gap closed (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.3-test-runner-landing + operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Task 3 + Task 5 + Task 9 + Task 10 + Task 11 authoring + iter-159 live file + syntax + sync-gate verification probe AC 1 at CLI-exit-code level):**
  - **`packages/devbox/dnsmasq/dnsmasq.conf` presence + content (iter-158 authored; iter-159 live-verified, 2592 bytes)**: fail-closed defaults `address=/#/0.0.0.0` + `address=/#/::` (any domain NOT in allow-list yields 0.0.0.0/:: per SC-12) + `listen-address=127.0.0.1,::1` + `port=53` + `bind-interfaces` + `user=nobody` / `group=nogroup` (privilege-drop post-port-53-bind per Task 3.1) + `no-hosts` + `no-resolv` (no `/etc/resolv.conf` or `/etc/hosts` upstream reads) + hardening trio `domain-needed` + `bogus-priv` + `stop-dns-rebind` + `log-queries=extra` + `log-facility=/var/log/dnsmasq.log` (SC-3 JSONL emitter feed) + `KEEL_EGRESS_ALLOWLIST_MARKER_{START,END}` placeholder block for reload-time `server=/<domain>/$UPSTREAM` injection per SC-12.
  - **`packages/devbox/scripts/start-egress.sh` presence + content + syntax (iter-158 authored; iter-159 bash -n exit 0 verified; 4767 bytes; 0755 exec bit)**: `#!/usr/bin/env bash` + `set -euo pipefail` shape per SC-9 (matches Story 2.1 `benchmark.sh`); `mkdir -p /workspace/logs` + `mkdir -p /run` (SC-17 idempotent pre-create); overwrites `/etc/resolv.conf` to exactly two lines `nameserver 127.0.0.1` + `options edns0 single-request-reopen` per SC-13 (NO `8.8.8.8`, NO `1.1.1.1`, NO corporate resolver — upstream ONLY reachable via dnsmasq per-domain `server=` directives; closes upstream cc-devbox bug #2 fail-open fallback); composes initial whitelist at `/run/keel-whitelist.composed.txt` (whitelist.default.txt + whitelist/*.txt concatenation with comment/blank strip per Task 5.4); invokes `scripts/reload-egress.sh /run/keel-whitelist.composed.txt` (first-time rule generation + apply per Task 5.5); launches `scripts/egress-log-tailer.sh` via `nohup … >/dev/null 2>&1 &` + PID capture to `/run/keel-egress-tailer.pid` per Task 5.6; dnsmasq-liveness check via 5s retry loop (`pgrep -x dnsmasq` || `ss -lnp | grep ':53'`) with fail-hard `exit 1` per Task 5.7 (AC 5 fail-closed-no-silent-allow).
  - **`packages/devbox/.envrc.example` lines 43-44 iter-158**: new `# --- Egress policy (Story 2.3) ---` section + single knob `KEEL_DEVBOX_DNS_UPSTREAM=1.1.1.1  # Upstream resolver for whitelisted domains. Cloudflare default; operator may retune to corporate resolver. Consumed by packages/devbox/scripts/reload-egress.sh.` per SC-14 (120-char budget; NO whitelist-source knob per Story 2.4 boundary; NO rotation-size knob per SC-4 pin).
  - **`packages/devbox/Dockerfile` lines 56-57 iter-158**: `dnsmasq` + `nftables` appended to the existing `apt-get install` layer per SC-1 + Story 2.1 single-layer discipline (same RUN block as Story 2.1's system-packages; `apt-get clean && rm -rf /var/lib/apt/lists/*` discipline preserved). Binaries available in baked image post-next-bake; concrete versions captured in VERSIONS.md § Egress policy at operator-workstation re-bake (Task 1.2 + 1.3 DEFER per backend-B constraint).
  - **`packages/devbox/entrypoint.sh` line 101 iter-158**: `# Story 2.3: fail-closed egress policy (dnsmasq + nftables). Hard-fail if init fails.` comment + single new block per SC-11 invoking `/workspace/packages/devbox/scripts/start-egress.sh` via absolute bind-mount path; explicit fail-hard `exit 1` with actionable stderr if script is missing or non-executable (fail-closed posture per NFR6 + Dev-agent Guardrail #1). Inserted AFTER Story 2.1 workspace-owner chown + OAuth volume dir bring-up; BEFORE `exec "$@"` / `sleep infinity` tail per SC-11 surgery-discipline. `bash -n` exit 0 at iter-159.
  - **Live-smoke AC 1 runtime verification (Task 12.1 substrate — `docker exec devbox cat /etc/resolv.conf | grep -q '^nameserver 127\.0\.0\.1$'` + `pgrep -x dnsmasq` + `ss -lnp | grep ':53'` + Task 3.3 `dnsmasq --test --conf-file=packages/devbox/dnsmasq/dnsmasq.conf`)** deferred to operator workstation per backend-B iteration-env constraint (Story 2.1 iter-127 bind-mount-denial precedent; kernel-nftables-privilege absent in DinD host-socket-passthrough layer). SC-13 verbatim command pinned in `docs/invariants/devbox-egress.md § Verification` + `packages/devbox/README.md § Egress policy § Verification` for operator close-out pass.
  - **Adversarial AC-1 coverage delegated to iter-CR** per § Testing Standards hybrid ground-(c) variant-(iii) spec-declared-CR-substitution: Blind Hunter examines dnsmasq.conf directive set for completeness + privilege-drop correctness + fail-closed-default language; Edge Case Hunter probes `no-hosts` + `no-resolv` + `bind-interfaces` interaction edge cases (DHCP-like probes, IPv6 link-local); Acceptance Auditor verifies SC-12 allow-mechanism marker block format + SC-13 exact-two-line resolv.conf + SC-14 knob format match architecture.md § S5 verbatim.

---

#### AC-2: nftables default policy DROP for both IPv4 (`ip filter output`) + IPv6 (`ip6 filter output`) filter output chains; upstream IPv6 gap closed via in-container parity test (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.3-test-runner-landing + operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Task 4 + Task 9 authoring + iter-159 live file + sync-gate verification probe AC 2 at CLI-exit-code level):**
  - **`packages/devbox/nftables/egress.nft` presence + content (iter-158 authored; iter-159 live-verified, 3605 bytes)**: single `table inet keel_egress` with two chains per SC-7 — `chain output_v4 { type filter hook output priority 0; policy drop; meta nfproto != ipv4 accept; ct state established,related accept; [loopback-dns allows]; KEEL_EGRESS_ALLOWLIST_MARKER_START … MARKER_END; }` + `chain output_v6 { type filter hook output priority 0; policy drop; meta nfproto != ipv6 accept; ct state established,related accept; [loopback-dns allows]; KEEL_EGRESS_ALLOWLIST_MARKER_START … MARKER_END; }`. Both chains hooked at identical priority 0 per SC-7. SC-7 verbatim commands (`nft list chain inet keel_egress output_v4 | grep -q 'policy drop'` + IPv6 equivalent) pinned in `docs/invariants/devbox-egress.md § Verification`.
  - **Non-obvious nftables chain-scope pattern applied iter-158**: `meta nfproto != <family> accept` short-circuit as FIRST rule of each chain (not a policy-level filter). In inet-family tables with two chains hooked at identical priority, both chains evaluate EVERY packet from BOTH families — the naïve scope-via-`meta nfproto` pattern the v1.1 draft implied would double-drop non-target-family packets via each chain's `policy drop`. Accept-fast first rule preserves per-chain family scope while the SC-7 `grep -q 'policy drop'` assertion still passes because chain policy is unchanged. Decision pinned in Story 2.3 file v1.3 Change Log + Completion Notes (non-obvious-decisions checklist).
  - **Baseline allow rules in both chains (AC 2 mechanism completeness)**: `ct state established,related accept` (preserves established-connection preservation across atomic reload per SC-5 commentary); loopback DNS reply path `udp dport 53 ip daddr 127.0.0.1 accept` + `udp sport 53 ip saddr 127.0.0.1 accept` (Task 4.1 design); `KEEL_EGRESS_ALLOWLIST_MARKER_{START,END}` placeholder block for reload-time resolved-IP `ip daddr <addr> accept` + `ip6 daddr <addr6> accept` injection per Task 4.1.
  - **`packages/devbox/docker-compose.yml` lines 91-99 iter-158**: `cap_add: [NET_ADMIN, NET_RAW]` added to `devbox` service per SC-6 (defensive-explicit; container is currently root-with-all-caps — cap_add is a no-op pre-Story-2.5; locks the explicit allowance so Story 2.5's future `cap_drop: [ALL]` reduces to `cap_drop:[ALL] + cap_add:[NET_ADMIN,NET_RAW]` without breaking egress enforcement). Comment block at lines 91-97 documents `CAP_NET_BIND_SERVICE` (port-53 bind) handoff to Story 2.5's privilege-drop orchestration per Dev Notes § User-account timeline. Stale `# TODO(Story 2.3): add nftables / dnsmasq sidecar services` comment at line 10 replaced by factual in-container wiring descriptor per Task 9.1. NO `cap_drop: [ALL]`, NO `user: dev`, NO `security_opt: [no-new-privileges:true]` — those belong to Story 2.5 (SC-6 scope-creep prohibition). Pre-existing Story 2.5/2.11/2.12/2.13 TODO rows preserved verbatim.
  - **`packages/devbox/Dockerfile` lines 56-57 iter-158**: `nftables` apt-appended (binary available after next image bake). iter-123 bake is pre-Story-2.3; re-bake deferred to operator workstation (Task 1.2 + 1.3; backend-B iteration-env re-bake denial per Story 2.1 iter-127 precedent). `nft --version` probe concrete-version-capture deferred.
  - **Live-smoke AC 2 runtime verification (Task 12.3 SC-7 verbatim `nft list chain inet keel_egress output_v4 | grep -q 'policy drop'` + Task 12.4 IPv6 equivalent + Task 4.3 `nft -c -f packages/devbox/nftables/egress.nft` check-only syntactic validation)** deferred to operator workstation per backend-B iteration-env constraint + kernel-nftables-privilege absence in DinD host-socket-passthrough layer. SC-7 verbatim commands pinned in `docs/invariants/devbox-egress.md § Verification` + `packages/devbox/README.md § Egress policy § Verification` for operator close-out.
  - **Adversarial AC-2 coverage delegated to iter-CR**: Blind Hunter examines egress.nft table + chain structure for inet-family idiom correctness (single table vs split `ip filter output` + `ip6 filter output`) + priority-0 hook ordering + policy-drop placement; Edge Case Hunter probes the `meta nfproto != <family> accept` short-circuit + baseline established,related evaluation edge cases (conntrack helper absence, NEW state re-evaluation during reload) + marker-block round-trip fidelity; Acceptance Auditor verifies both chains declare `policy drop` verbatim (SC-7 grep target) + cap_add list includes exactly [NET_ADMIN, NET_RAW] + Dockerfile nftables apt-append preserves single-layer discipline.

---

#### AC-3: dnsmasq JSONL query log at pinned path suitable for FR37 security-evidence persistence; log rotation configured to prevent unbounded growth (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.3-test-runner-landing + operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Task 3 + Task 7 + Task 8 + Task 10.2 authoring + iter-159 live file + syntax verification probe AC 3 at CLI-exit-code level):**
  - **`packages/devbox/scripts/egress-log-tailer.sh` presence + content + syntax (iter-158 authored; iter-159 bash -n exit 0 verified; 7377 bytes; 0755 exec bit)**: `#!/usr/bin/env bash` + `set -euo pipefail` shape per SC-9; tails `/var/log/dnsmasq.log` via `tail -Fn0` (follow + new-file-on-rotation; start from end so historical lines are not re-emitted per Task 7.2); parses each dnsmasq query-log line via 3-format parser (query format `<timestamp> dnsmasq[<pid>]: query[<type>] <domain> from <client>` + reply format `<timestamp> dnsmasq[<pid>]: reply <domain> is <answer>` + block format `<timestamp> dnsmasq[<pid>]: config <domain> is <NXDOMAIN|0.0.0.0>` per Task 7.3) and synthesizes JSONL records per SC-3 6-field schema.
  - **SC-2 pinned JSONL path `/workspace/logs/egress-queries.jsonl`** written per SC-17 (start-egress.sh idempotent `mkdir -p /workspace/logs` — host-side bind-mount guaranteed). Epic 4 FR37 security-evidence emitter consumes this path; path pinned at 1.0 for downstream hard-reference.
  - **SC-3 6-field JSONL schema (stable declared field order: `timestamp`/`query`/`type`/`result`/`upstream`/`client`; UTF-8; LF-terminated; one object per line) EMBEDDED VERBATIM in `docs/invariants/devbox-egress.md § JSONL query log schema`** per iter-156 PATCH 3 — contentHash `aad16a51aa1dc7527c0312e6b99217966d7f3f3478fb677dd347792e9cb6889b` locks the 6-field contract against drift (Story 2.2 iter-151 AR-2 lesson: contract language scattered outside `sourcePath` doc drifts silently). Example line pinned: `{"timestamp":"2026-04-21T12:34:56.789Z","query":"api.anthropic.com","type":"A","result":"allow","upstream":"1.1.1.1","client":"127.0.0.1"}`.
  - **SC-4 rotation mechanism (Task 7.4 design)**: on every write, check filesize; if `> 50 MB` pinned threshold, rotate inline — close fd, rename `egress-queries.jsonl → egress-queries.jsonl.1.tmp`, gzip → `egress-queries.jsonl.1.gz`, shift older generations (`.N.gz → .N+1.gz`), drop anything beyond `.5.gz`, reopen fd to fresh empty `egress-queries.jsonl`. 50 MB + 5 generations ≈ 250 MB worst-case — well under `KEEL_DEVBOX_TMPFS_LOGS_MB=500` default (Story 2.5 consumer). Avoids external logrotate daemon (container single-purpose discipline); gzip is stdlib.
  - **SC-15 process model (Task 5.6 + 7.1 design)**: egress-log-tailer.sh runs as background process launched from start-egress.sh via `nohup … >/dev/null 2>&1 &`; PID captured to `/run/keel-egress-tailer.pid` for clean `kill -TERM` on reload. Rationale: dnsmasq doesn't natively emit JSONL; tailing its text log + transforming is the simplest stable approach without introducing a new daemon.
  - **SC-16 reload/rotation safety**: rotation releases the open file handle BEFORE the `nft`/`HUP` reload completes (reload is orthogonal to rotation — rotation does not drop in-flight queries). Rotation cadence is event-driven per write; atomic reload script does NOT trigger rotation. SIGTERM/SIGINT handler flushes + closes cleanly per Task 7.5. Parse-error fallback: malformed dnsmasq log lines emit JSONL records with `result=parse-error` + raw line in `"raw"` field — no silent drops per Task 7.6.
  - **`packages/devbox/scripts/monitor.sh` presence + content + syntax (iter-158 authored; iter-159 bash -n exit 0 verified; 881 bytes; 0755 exec bit)**: `exec tail -Fn0 /workspace/logs/egress-queries.jsonl | jq -c --unbuffered '.'` — operator-facing raw JSONL tail per SC-9 + AC 3 observability. NO filter args, NO format flags (Story 2.4/2.6 scope per Task 8.3).
  - **Live-smoke AC 3 runtime verification (Task 12.6 JSONL schema round-trip via `tail /workspace/logs/egress-queries.jsonl | jq -c .` + SC-3 6-field contract validation + Task 12.7 log-rotation smoke via 51 MB synthesized writes or local-uncommitted 1 MB threshold override)** deferred to operator workstation per backend-B iteration-env constraint. SC-3 + SC-4 verbatim specifications pinned in `docs/invariants/devbox-egress.md § JSONL query log schema` for operator close-out.
  - **Adversarial AC-3 coverage delegated to iter-CR**: Blind Hunter examines egress-log-tailer.sh dnsmasq parser for 3-format coverage completeness + SC-3 field-order correctness + result-enum coverage (allow / block / nxdomain / servfail / parse-error); Edge Case Hunter probes the rotation path for edge cases (write-during-rotation race, concurrent fd open, `.5.gz` drop semantics, SIGTERM-during-rotation-reentry) + raw-line preservation on parse-error; Acceptance Auditor verifies SC-2 path + SC-3 schema + SC-4 threshold + SC-15 process-model + SC-16 reload-orthogonality match story Dev Notes verbatim.

---

#### AC-4: Atomic reload via file-lock (mechanism used by Story 2.4's CLI); dnsmasq + nftables re-loaded without dropping in-flight connections; reload is atomic (either both layers apply new policy, or neither does) (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.3-test-runner-landing + operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Task 6 authoring + iter-159 live file + syntax verification probe AC 4 at CLI-exit-code level):**
  - **`packages/devbox/scripts/reload-egress.sh` presence + content + syntax (iter-158 authored; iter-159 bash -n exit 0 verified; 8342 bytes; 0755 exec bit)**: `#!/usr/bin/env bash` + `set -euo pipefail` shape per SC-9. Implements SC-5 atomic-reload contract verbatim:
    1. Argument contract: `reload-egress.sh <composed-whitelist-path>` — single arg, path to composed-and-validated whitelist file. Exit 2 if arg missing; exit 3 if path unreadable per Task 6.2.
    2. `flock -x 200` on `/run/keel-egress.lock` (fd 200) — serialize concurrent reloads. If lock unavailable within 10s, exit 4 with actionable stderr per Task 6.3.
    3. Render nftables ruleset: copy `packages/devbox/nftables/egress.nft` to temp file; replace `KEEL_EGRESS_ALLOWLIST_MARKER_{START,END}` block with resolved IP allow-rules (for each domain: `getent ahostsv4` + `getent ahostsv6` → emit `ip daddr <addr> accept` + `ip6 daddr <addr6> accept` in appropriate chain per Task 6.4).
    4. Render dnsmasq conf: copy `packages/devbox/dnsmasq/dnsmasq.conf` to `/etc/dnsmasq.conf`; replace marker block with `server=/<domain>/${KEEL_DEVBOX_DNS_UPSTREAM:-1.1.1.1}` per Task 6.5.
    5. Apply ruleset via `nft -f <temp-rendered-file>` — single kernel-atomic transaction. If fails, abort reload (previous ruleset stays active); exit 5 with stderr per Task 6.6.
    6. Reload dnsmasq via `kill -HUP $(cat /run/dnsmasq.pid)` — config re-read without restart (established DNS connections preserved). Fallback if pidfile missing: `pkill -HUP dnsmasq` per Task 6.7.
    7. Release flock on exit via trap per Task 6.8.
    8. Exit 0 with one-line summary to stdout (`reload ok: N domains, M ipv4 rules, K ipv6 rules`) per Task 6.9.
  - **SC-5 kernel-atomic guarantee**: `nft -f <single-tempfile>` is kernel-atomic — the new ruleset replaces the old in a single transaction; in-flight packets matching the old ruleset's `ct state established,related accept` rule continue to match the new ruleset's equivalent rule (baseline established,related rule preserved across reloads per egress.nft Task 4.1 design). `kill -HUP dnsmasq` re-reads `/etc/dnsmasq.conf` + whitelist files without daemon restart — preserves in-flight UDP/TCP DNS queries (UDP stateless; dnsmasq answer cache persists).
  - **SC-5 failure modes (8 documented exit codes)**: nft -f fails → previous ruleset stays active (kernel rollback); reload-egress.sh exits 5 before dnsmasq HUP; dnsmasq config unchanged → atomicity preserved. `nft -f` succeeds but `kill -HUP` fails → new nftables active with old dnsmasq config (documented fallible seam per story v1.3 Completion Notes § Known residual risk). Mitigation: dnsmasq HUP rarely fails; pidfile-read failure falls back to `pkill -HUP dnsmasq`; if both fail, exit 7 with actionable stderr; operator may manually restart dnsmasq (Story 2.4 CLI will surface this via diff-summary). Accepted residual risk at 1.0.
  - **SC-8 whitelist compose boundary**: Story 2.3 ships the `reload-egress.sh` primitive taking a single composed whitelist filepath as argument + performs the atomic reload. Story 2.3 ships a static baseline composition (`whitelist.default.txt` + `whitelist/*.txt` concatenation, NO per-fork override) run once at container start via `start-egress.sh` Task 5.4. Story 2.4 later produces `scripts/whitelist.sh` user-facing CLI that handles per-fork override + validation + diff summary + invocation of `reload-egress.sh`. Story 2.3 MUST NOT create `scripts/whitelist.sh` (SC-8 scope prohibition).
  - **SC-16 reload/rotation orthogonality**: reload does NOT trigger rotation; rotation is event-driven per write in `egress-log-tailer.sh`; `reload-egress.sh` does not interact with the JSONL tailer process lifecycle.
  - **Live-smoke AC 4 runtime verification (Task 12.5 atomic-reload preservation: long-running `curl --keepalive-time 60 https://api.anthropic.com/` in background + `reload-egress.sh` invocation on same whitelist → verify curl connection not broken AND reload exits 0 within 2s + timing + both exit codes)** deferred to operator workstation per backend-B iteration-env constraint (requires live dnsmasq + running container + actual nftables kernel rule-load path). SC-5 verbatim specification pinned in `docs/invariants/devbox-egress.md § Mechanism` + `§ Verification` for operator close-out.
  - **Adversarial AC-4 coverage delegated to iter-CR**: Blind Hunter examines reload-egress.sh sequence correctness (flock-before-render; render-before-apply; nft-f-before-HUP; trap-release-flock) + 8 exit-code completeness; Edge Case Hunter probes the `flock -x` 10s-timeout recovery + `nft -f` rollback-on-syntax-error + `kill -HUP` pidfile-missing → pkill fallback + getent ahostsv4/v6 empty-result handling + SC-5 fallible-seam operator-recovery-path; Acceptance Auditor verifies SC-5 4-step atomic contract + SC-8 single-arg CLI + SC-16 reload/rotation-orthogonality + Task 6.2–6.9 exit-code mapping match story Dev Notes verbatim.

---

#### AC-5: Attempting to curl an unwhitelisted domain fails — DNS resolution fails (dnsmasq NXDOMAIN) AND TCP connection is rejected (nftables default-deny); upstream divergent-whitelist-script problem closed (one mechanism, two enforcement layers) (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.3-test-runner-landing + operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; dual-layer belt-and-braces enforcement verified at template level + entrypoint fail-hard + README documentation):**
  - **Dual-layer belt-and-braces enforcement per architecture § S5 line 224 + PRD FR1a + NFR6 — verified at template level**:
    - **Layer 1 (DNS resolution)**: dnsmasq default `address=/#/0.0.0.0` + `address=/#/::` in `packages/devbox/dnsmasq/dnsmasq.conf` per SC-12 returns 0.0.0.0/:: for any domain NOT in the allow-list `server=/<domain>/<upstream>` entries — fail-closed posture at DNS resolution layer. dnsmasq answer format at `/var/log/dnsmasq.log` surfaces as `config <domain> is <NXDOMAIN|0.0.0.0>` → egress-log-tailer.sh synthesizes JSONL `{"result":"nxdomain",...}` per SC-3.
    - **Layer 2 (layer-3 enforcement)**: nftables `chain output_v4 { policy drop }` + `chain output_v6 { policy drop }` in `packages/devbox/nftables/egress.nft` per SC-7 drops any layer-3 packet not matched by a preceding allow rule — fail-closed posture at kernel packet-filter layer. Even if dnsmasq were somehow bypassed (pre-resolved IP, hardcoded client), the kernel-level drop enforces the policy.
  - **SC-13 resolv.conf pin (start-egress.sh Task 5.3)**: `/etc/resolv.conf` overwritten to exactly two lines `nameserver 127.0.0.1` + `options edns0 single-request-reopen`. NO upstream IP written to resolv.conf (no 8.8.8.8, no 1.1.1.1, no corporate resolver). Upstream ONLY reachable via dnsmasq's per-domain `server=` directives. **Closes upstream cc-devbox bug #2 (fail-open resolv.conf fallback to 8.8.8.8)** — verbatim from `packages/devbox/README.md § Egress policy § Known upstream bugs fixed` line 262 + PRD M0.5.
  - **SC-1 in-container runtime**: dnsmasq + nftables run as in-container daemons/rules inside the devbox service, NOT as separate Compose sidecar services — matches AC 1 verbatim "When the container starts, dnsmasq runs as the in-container DNS authority" + architecture § S5 single file-locked shell-script inside the container. Stale `# TODO(Story 2.3): add nftables / dnsmasq sidecar services` `docker-compose.yml:10` comment replaced by factual in-container wiring descriptor per Task 9.1.
  - **SC-8 single-mechanism collapse**: Story 2.3 ships ONE reload primitive (`reload-egress.sh`); Story 2.4 is the sole operator entry point (`whitelist.sh`). **Closes upstream cc-devbox bug #1 (divergent whitelist tooling — upstream shipped `manage-whitelist.sh` with `/etc/whitelist-domains.conf` + `pkill -HUP` AND a separate `whitelist` script with `/workspace/.claude/whitelist` + `pkill + respawn` — different state, different reload, intermittent unexpected blocks)** — verbatim from README § Known upstream bugs fixed line 261.
  - **IPv4/IPv6 parity verbatim (SC-7 + AC 2 closure)**: `address=/#/0.0.0.0` + `address=/#/::` in dnsmasq + `chain output_v4` + `chain output_v6` both `policy drop` in nftables. **Closes upstream cc-devbox bug #3 (IPv6 default-deny gap — upstream's `whitelist.conf` only blocked IPv4 `address=/#/127.0.0.1`; IPv6 AAAA queries bypassed)** — verbatim from README § Known upstream bugs fixed line 263.
  - **Entrypoint fail-hard posture (entrypoint.sh line 101 per SC-11)**: hard-fails `exit 1` if `start-egress.sh` is missing or non-executable — NO silent-allow path; fail-closed default per NFR6. Dev-agent Guardrail #1 (Fail-closed everywhere): start-egress.sh exits 1 if dnsmasq fails to start after 5s retry; reload-egress.sh exits 5/6/7 for nft-f/render/SIGHUP failures; entrypoint re-raises — verified at story file § Completion Notes § Guardrail compliance check.
  - **`packages/devbox/README.md § Egress policy § Known upstream bugs fixed` subsection (Task 11.2)**: three-line list documenting divergent whitelist tooling + fail-open resolv.conf + IPv6 gap — hard-referenced in § Known upstream bugs fixed at lines 261-263 for 1.0 shipping documentation.
  - **Live-smoke AC 5 runtime verification (Task 12.2 negative smoke: `curl -m 3 -sSf https://example.com/ 2>&1 | grep -Ei 'could not resolve|refused|timed out'` exits 0 + records stderr + Task 12.1 positive smoke: `curl -m 5 -sSf https://registry.npmjs.org/` exits 0 via npm allow-list)** deferred to operator workstation per backend-B iteration-env constraint. SC-12 + SC-7 combined verbatim commands pinned in `docs/invariants/devbox-egress.md § Verification` + `packages/devbox/README.md § Egress policy § Verification` for operator close-out.
  - **Adversarial AC-5 coverage delegated to iter-CR**: Blind Hunter examines dual-layer mechanism for independence (layer 1 failure does not defeat layer 2 and vice versa) + NXDOMAIN result-enum coverage + single-mechanism-collapse completeness (no secondary reload path); Edge Case Hunter probes the fail-closed posture under dnsmasq crash / nftables rule-load failure / start-egress.sh missing / `.envrc` KEEL_DEVBOX_DNS_UPSTREAM unset edge cases; Acceptance Auditor verifies AC 5 verbatim wording satisfied by SC-12 + SC-13 + SC-7 + SC-8 combination + entrypoint fail-hard exit 1 + README § Known upstream bugs fixed three-line list matches upstream bug-closure claims.

---

## PHASE 2: TEST DISCOVERY INVENTORY

### Test Collection Status

**COLLECTED** — No test runner is configured at this substrate stage; acknowledged per hybrid ATDD-skip clause (third Epic 2 + first infrastructure-security class; thirteenth cumulative trace-WAIVED precedent). A framework-aware recursive file search for `**/*.test.ts`, `**/*.spec.ts`, `**/*.test.tsx`, `**/*.spec.tsx`, `**/tests/**`, `vitest.config.*`, `jest.config.*`, `playwright.config.*`, `cypress.config.*`, `pyproject.toml`, `go.mod`, `Gemfile`, `Cargo.toml`, `*.csproj`, `pytest.ini` under the worktree at iter-159 returns zero matches — identical to Story 2.1 iter-126 + Story 2.2 iter-149 precedent. Stack detection: root `package.json` has no `react`, `vue`, `angular`, `next`, `playwright`, `cypress`, `vitest`, `jest` dependencies; `tea_config` inherits TEA framework default (`test_framework: auto`) which autodetects nothing under this substrate. The Story 2.3 file itself is the only artefact referencing runtime assertions (Task 12.1 – 12.8 live-smoke tasks are backend-B operator-workstation deferred per v1.1 PATCH 4; AC-mapped `docker exec` recipes with concrete `nft` / `curl` / `grep -q` invocations pinned in `docs/invariants/devbox-egress.md § Verification` + `packages/devbox/README.md § Egress policy § Verification` for operator close-out).

### Test Counts

- **Files:** 0
- **Cases:** 0
- **Skipped:** 0
- **Fixme:** 0
- **Pending:** 0

### By Level

| Level     | Tests | Files |
| --------- | ----- | ----- |
| E2E       | 0     | 0     |
| API       | 0     | 0     |
| Component | 0     | 0     |
| Unit      | 0     | 0     |
| Other     | 0     | 0     |

---

## PHASE 3: GAP ANALYSIS

### Critical Gaps (Priority P0)

None — AC coverage breakdown has no P0 rows (infrastructure-security substrate at Story 2.3 substrate stage, matching Story 2.1 + 2.2 P2-uniform precedent).

### High-Priority Gaps (Priority P1)

None — AC coverage breakdown has no P1 rows. See § Coverage Summary note: downstream test-runner landing may retro-classify AC 5 fail-closed-block as P1 under runtime-harm taxonomy; Story 2.3 ships P2-uniform matching Story 2.1 + 2.2 precedent.

### Medium-Priority Gaps (Priority P2)

| ID   | Coverage | Reason                                                                                                                                                                                                                                                                                                                                                                                                             |
| ---- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| AC-1 | NONE     | Infrastructure-security substrate; no test runner at 1.0 (Epic 13 scope). Structural claim-verifiable via future shell-smoke (docker exec): `cat /etc/resolv.conf \| grep -q '^nameserver 127\.0\.0\.1$'` + `pgrep -x dnsmasq` + `ss -lnp \| grep ':53'` + `dnsmasq --test --conf-file=...`. Template-level file presence + syntax + .envrc.example knob + Dockerfile apt-append + entrypoint hook all verified. |
| AC-2 | NONE     | Infrastructure-security substrate; no test runner at 1.0. Structural claim-verifiable via future shell-smoke: SC-7 verbatim `nft list chain inet keel_egress output_v4 \| grep -q 'policy drop'` + IPv6 equivalent + `nft -c -f packages/devbox/nftables/egress.nft`. Template-level egress.nft + policy-drop chain decls + cap_add + nftables apt-append all verified.                                             |
| AC-3 | NONE     | Infrastructure-security substrate; no test runner at 1.0. Structural claim-verifiable via future shell-smoke: `tail /workspace/logs/egress-queries.jsonl \| jq -c .` + SC-3 6-field assertion + SC-4 rotation smoke (51 MB writes). Template-level egress-log-tailer.sh + monitor.sh + SC-3 verbatim-embed + SC-4 threshold all verified.                                                                           |
| AC-4 | NONE     | Infrastructure-security substrate; no test runner at 1.0. Structural claim-verifiable via future shell-smoke: long-curl + reload-egress.sh preservation + exit-code timing. Template-level reload-egress.sh + SC-5 flock/nft-f/kill-HUP wiring + 8 exit codes + SC-8 boundary all verified.                                                                                                                         |
| AC-5 | NONE     | Infrastructure-security substrate; no test runner at 1.0. Structural claim-verifiable via future shell-smoke: positive curl npmjs + negative curl example.com + stderr fail-closed pattern. Template-level dual-layer mechanism + entrypoint fail-hard + resolv.conf pin + single-mechanism-collapse all verified.                                                                                                  |

### Heuristic Coverage Signals

- **Endpoint gaps:** none (not applicable — this is substrate infrastructure, not a request-response API endpoint surface).
- **Auth negative-path gaps:** not applicable (no auth flow at this stage — Story 2.3 predates Epic 5 platform authentication work).
- **Happy-path only:** not applicable (error-path coverage is intentionally **PRESENT** in the sense that fail-closed is THE contract — AC 5 IS the error-path + fail-closed guarantee; positive path is AC 1 allow-list; dual-layer enforcement creates both paths equivalently).
- **UI journey gaps:** not applicable (substrate infrastructure; no UI surface).
- **UI state gaps:** not applicable.

---

## PHASE 4: GATE DECISION

**Status:** `WAIVED`

**Determination:** Deterministic coverage computation reports `overall_coverage_pct = 0%` (below 80% minimum threshold). Under normal gate criteria this FAILS. Per hybrid ATDD-skip clause + THIRTEENTH cumulative trace-WAIVED precedent + ground-(a)-(b)-(c)-(d) variant-(ii)+(iii) rationale, the zero-test-runner posture is **accepted** at Story 2.3 substrate stage with downstream test-runner-landing + operator-workstation live smokes explicitly deferring the runner-hosted coverage path.

**Gate criteria:**

- P0 coverage required 100% → actual 100% (no P0 criteria, vacuous PASS) — **MET**
- P1 coverage target 90% / minimum 80% → actual 100% (no P1 criteria, vacuous PASS) — **MET**
- Overall coverage minimum 80% → actual 0% (no tests at substrate stage) — **NOT MET**

### Rationale

**THIRTEENTH cumulative Epic trace-WAIVED precedent (Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57 + 1.12 iter-64 + 1.13 iter-71 + 1.14 iter-78 + 1.15 iter-85 + 1.16 iter-92 → 2.1 iter-126 → 2.2 iter-149 → 2.3 iter-159).** Story 2.3 is the **first infrastructure-security class** story — the combination of dnsmasq daemon + nftables kernel rules + file-locked atomic-reload + JSONL log-tailer operates outside the Vitest/Playwright idiom entirely. Every prior Epic 2 trace-WAIVED (2.1 iter-126 pure runtime-infrastructure; 2.2 iter-149 hybrid infrastructure-smoke + configuration-surface) had at least one in-iteration-executable assertion path; Story 2.3 ships template-only substrate evidence with every runtime smoke (resolv.conf pin + `nft list chain` parity + positive/negative curl + atomic-reload preservation + JSONL round-trip + log-rotation) operator-workstation-deferred via the backend-B iteration-env kernel-privilege constraint. Under the ATDD-skip-trace-WAIVED co-application rule, this is the **FOURTEENTH cumulative pairing** overall (10 Epic-1 pairings + 2.1 + 2.2 + 2.3).

**Ground (a) — substrate-verification-covers-ACs at CLI-exit-code level.** All 5 ACs have STRONG substrate evidence verified LIVE at iter-159:

- **AC 1** — `packages/devbox/dnsmasq/dnsmasq.conf` (2592 bytes): fail-closed `address=/#/0.0.0.0` + `address=/#/::` + `listen-address=127.0.0.1,::1` + `port=53` + `bind-interfaces` + `user=nobody` privilege-drop + `log-queries=extra` + `KEEL_EGRESS_ALLOWLIST_MARKER` block per SC-12. `start-egress.sh` (4767 bytes, bash -n OK) SC-13 resolv.conf pin to exactly `nameserver 127.0.0.1` + `options edns0 single-request-reopen`. `.envrc.example` L43-44 `KEEL_DEVBOX_DNS_UPSTREAM=1.1.1.1` knob per SC-14. `Dockerfile` L56-57 `dnsmasq` apt-append. `entrypoint.sh` L101 single new fail-hard block per SC-11.
- **AC 2** — `packages/devbox/nftables/egress.nft` (3605 bytes): single `table inet keel_egress` with `chain output_v4` + `chain output_v6` both `type filter hook output priority 0; policy drop` per SC-7. `meta nfproto != <family> accept` first-rule short-circuit per iter-158 non-obvious decision. `docker-compose.yml` L91-99 `cap_add: [NET_ADMIN, NET_RAW]` per SC-6. `Dockerfile` L56-57 `nftables` apt-append.
- **AC 3** — `packages/devbox/scripts/egress-log-tailer.sh` (7377 bytes, bash -n OK): SC-3 6-field JSONL schema EMBEDDED VERBATIM in `docs/invariants/devbox-egress.md § JSONL query log schema` per iter-156 PATCH 3 (contentHash `aad16a51aa1dc7527c0312e6b99217966d7f3f3478fb677dd347792e9cb6889b`). SC-2 `/workspace/logs/egress-queries.jsonl` pinned path. SC-4 50 MB + 5 gzip generations inline rotation. SC-15 nohup background + SIGTERM flush-close. SC-16 reload/rotation orthogonality. `monitor.sh` (881 bytes, bash -n OK) operator `tail -Fn0 | jq -c` facade.
- **AC 4** — `packages/devbox/scripts/reload-egress.sh` (8342 bytes, bash -n OK): SC-5 atomic-reload verbatim — `flock -x /run/keel-egress.lock` 10s timeout + `nft -f <tempfile>` kernel-atomic transaction + `kill -HUP $(cat /run/dnsmasq.pid)` with `pkill -HUP dnsmasq` fallback + trap-released flock + 8 documented exit codes (2 missing-arg / 3 unreadable-path / 4 lock-timeout / 5 nft-fail / 6 render-fail / 7 SIGHUP-fail / 0 success). SC-8 whitelist-compose-boundary preserved.
- **AC 5** — dual-layer belt-and-braces fail-closed (dnsmasq NXDOMAIN at layer 1 + nftables layer-3 drop at layer 2). SC-13 resolv.conf pin closes upstream cc-devbox bug #2. SC-1 in-container runtime + SC-8 single-mechanism collapse closes upstream bug #1. IPv4/IPv6 parity closes upstream bug #3. Entrypoint fail-hard exit 1 if start-egress.sh missing.

**Sync-gate exit 0 green** at iter-159 — `node packages/keel-invariants/dist/check.js` validates 20 manifest entries including the new `INV-devbox-egress-contract` entry. The contentHash locks the consolidated invariant doc (`docs/invariants/devbox-egress.md`) against silent drift per Story 2.2 iter-151 AR-2 lesson (contract-splitting grows asymmetry risk — SC-10 ONE consolidated invariant honoured, not three split).

**Bash -n syntax check exit 0** at iter-159 for all 4 new scripts (`start-egress.sh` / `reload-egress.sh` / `egress-log-tailer.sh` / `monitor.sh`) + modified `entrypoint.sh`.

**Ground (b) — no test runner at 1.0.** Framework prerequisite unmet; Epic 13 delivers formal test-framework landing per PRD RS6. Recursive probe for vitest/jest/playwright/cypress configs returns zero matches at iter-159; stack detection returns none (`package.json` has no react/vue/angular/next/playwright/cypress/vitest/jest dependencies — Epic 13 delivers framework landing per prior twelve precedents).

**Ground (c) — HYBRID variant-(ii)+(iii) adversarial-coverage substitution.**

- **Variant (ii) downstream test-runner-landing-covers-per-AC-coverage:** Story 2.3-test-runner-landing (Epic 13 scope) will unlock per-AC runtime probes (resolv.conf pin + pgrep dnsmasq + SC-7 verbatim parity + dual-layer positive/negative curl + atomic-reload preservation + JSONL schema round-trip + log-rotation threshold). Story 2.4 whitelist CLI exercises AC 4 atomic-reload via the user-facing entry point; Story 2.5 hardening integration re-verifies AC 1/2/4/5 in the `cap_drop:[ALL] + user:dev + tmpfs` context; Story 2.6 lifecycle CLI + Story 2.13 healthcheck exercise the daemon posture end-to-end; Epic 4 FR37 security-evidence consumer hard-references the SC-3 pinned JSONL schema. None of these block Story 2.3 `review → done` transition under the WAIVED precedent — substrate evidence at iter-159 is complete for the in-iteration-executable portion of the story.
- **Variant (iii) spec-declared-CR-substitution:** Story 2.3 § Dev-agent guardrails (12 MUST-follow rules: fail-closed-everywhere + atomic-reload-kernel-level + IPv4/IPv6-parity-verbatim + JSONL-schema-stable + scope-isolation + entrypoint-minimal-surgery + invariant-drift-discipline + no-runtime-installs + kebab-case-sh-0755 + backend-B-aware + no-.envrc/.envrc.local-edits + single-source-of-truth) + 17 pinned scope-clarifications (SC-1 through SC-17 covering runtime location, JSONL path/schema/rotation, atomic-reload mechanism, cap_add wiring, parity verification commands, whitelist boundary vs Story 2.4, scripts output-location, invariant consolidation, entrypoint surgery discipline, dnsmasq allow-mechanism, resolv.conf override, upstream DNS knob, JSONL emitter process model, log-rotation safety, workspace-logs dir) + forthcoming `/bmad-code-review (args: "2")` adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.3 substrate diff: ~650 LOC across 11 new files + 11 modified files) substitute for red-phase scaffolds.

**Ground (d) — upstream-provenance-precedent.** Story 2.1 iter-98 established ground-(d) for infrastructure-smoke class stories absorbing upstream cc-devbox content: upstream cc-devbox has no test suite, absorbing preserves that posture faithfully; Story 2.3 inherits this ground-(d) via its extension of Story 2.1's fail-closed egress scaffold — Story 2.3 IS the fix for upstream cc-devbox's three documented bugs (divergent-whitelist-tooling + fail-open-resolv.conf + IPv6-default-deny-gap per `packages/devbox/README.md § Egress policy § Known upstream bugs fixed` lines 261-263). nftables + dnsmasq are standard substrate components; upstream doesn't ship tests for the kernel packet-filter idiom.

**CR-forecast envelope.** Per the iter-151/154/155 equation (carve-out × 3 + live-AC-coverage × 3 + impl-surface-LOC / 100): 0-carve-out + backend-B live-smoke defer (+3) + ~650 LOC impl (+6) → **6–9 iter fix-chain projected**; likely LOOSER than Story 2.2's 4-iter + TIGHTER than Story 2.1's 16-iter. This forecast is recorded as a CR-gate calibration signal, not a coverage-gate input.

**Story State transition:** FR14n `Story State` transitions `in-dev → traced` at iter-159 completion. Next QUEUE item: `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification (`traced → sm-verified` or `sm-fixes-pending`).

### Blockers

None.

### Recommendations

1. **[MEDIUM] Accept WAIVED posture** — five P2 ACs cover an infrastructure-security class story (third Epic 2 + first of its class: daemon + kernel-rule + file-locked atomic-reload + JSONL log-tailer outside the Vitest/Playwright idiom) with no live test runner at 1.0. All 5 ACs have STRONG substrate evidence (templates + scripts + invariant doc + manifest entry + sprint-status + entrypoint + compose + Dockerfile + README + VERSIONS + .envrc.example) verified LIVE at iter-159. Per-AC runner-hosted coverage deferred to Story 2.3-test-runner-landing (Epic 13 scope) + backend-B operator-workstation live smokes (Task 12.1 – 12.8).
2. **[MEDIUM]** Story 2.3 authors the fail-closed-egress contract substrate: 11 new files + 11 modified files exactly matching v1.2 forecast; single consolidated `INV-devbox-egress-contract` invariant (SC-10 per Story 2.2 iter-151 AR-2 lesson) + `docs/invariants/devbox-egress.md` with SC-3 JSONL schema embedded verbatim (iter-156 PATCH 3 contentHash drift-lock). Downstream consumers: Story 2.4 whitelist CLI + Story 2.5 hardening + Story 2.6 host-side pnpm + Story 2.13 healthcheck + Epic 4 FR37 security-evidence consumer. Any silent edit to `docs/invariants/devbox-egress.md` triggers sync-gate FAIL at pre-commit per Story 1.9 drift detection.
3. **[MEDIUM]** Story 2.3 test-runner landing (Epic 13 scope) + backend-B operator-workstation live smokes will unlock per-AC runner-hosted probes per Task 12.1 – 12.8: AC 1 resolv.conf pin + pgrep dnsmasq + dnsmasq --test; AC 2 SC-7 verbatim parity commands + nft -c syntactic check; AC 3 JSONL schema round-trip + 50 MB rotation; AC 4 atomic-reload preservation via long-curl + reload.sh; AC 5 positive npmjs curl + negative example.com curl + fail-closed stderr pattern. Plus Task 1.2 `nft --version` + `dnsmasq --version` baked-image version probe (concrete versions captured in VERSIONS.md § Egress policy) + Task 11.4 `docker compose config` parse check after cap_add + .envrc.example changes. None of these block Story 2.3 `review → done` transition under the WAIVED precedent.
4. **[LOW]** Run `/bmad-testarch-test-review` to assess test quality (no tests exist — no-op; recorded for parity with downstream pipelines).

---

## Collection Status: COLLECTED

All static analysis complete. Acknowledged zero runner-hosted tests at this substrate stage per hybrid ATDD-skip clause (THIRTEENTH cumulative trace-WAIVED precedent; third Epic 2 + first infrastructure-security class). Gate status: `WAIVED`. FR14n `Story State` transitions `in-dev → traced` at iter-159 completion. Next QUEUE item: `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification.

---

## Change Log

| Date       | Version | Description                                                                                                                                                                                                                                                                                                                                                                | Author                 |
| ---------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| 2026-04-21 | 1.0     | Initial trace created iter-159. Coverage oracle: acceptance_criteria (formal requirements); coverage confidence: high. Result: **WAIVED (THIRTEENTH cumulative trace-WAIVED precedent + FOURTEENTH ATDD-skip-trace-WAIVED co-application pairing)** — 5 P2 ACs with STRONG substrate evidence + zero-test-runner acknowledgment per hybrid ATDD-skip clause ground-(a)-(b)-(c)-(d) variant-(ii)+(iii). Per-AC runner-hosted coverage deferred to Epic 13 test-runner-landing + Task 12.1 – 12.8 operator-workstation live smokes. Substrate-evidence LIVE verification at iter-159: sync-gate exit 0 (20 manifest entries valid; new INV-devbox-egress-contract contentHash aad16a51…2e9cb6889b); bash -n exit 0 on 4 new scripts + entrypoint.sh; file + content + line-number verification on dnsmasq.conf + egress.nft + .envrc.example + Dockerfile + docker-compose.yml + README + VERSIONS + manifest + INVARIANTS.md + invariant doc. CR-forecast envelope 6–9 iter fix-chain per iter-151/154/155 equation (0-carve-out + backend-B live-smoke defer + ~650 LOC impl). Story State transition `in-dev → traced`. | TEA Agent (Ralph iter-159) |
