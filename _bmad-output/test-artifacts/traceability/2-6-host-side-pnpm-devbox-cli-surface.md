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
    '_bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    'INVARIANTS.md',
    'AGENTS.md',
    'CLAUDE.md',
    'RALPH.md',
    'docs/invariants/devbox-hardening.md',
    'docs/invariants/devbox-dind.md',
    'docs/invariants/devbox-egress.md',
    'packages/devbox/README.md',
    'packages/devbox/docker-compose.yml',
    'packages/devbox/scripts/benchmark.sh',
    'packages/devbox/scripts/whitelist.sh',
    'packages/devbox/scripts/monitor.sh',
    'package.json',
    'packages/keel-invariants/src/invariants.manifest.ts',
    '_bmad-output/test-artifacts/traceability/2-4-gate-decision.json',
    '_bmad-output/test-artifacts/traceability/2-5-gate-decision.json',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/2-6-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 2.6 host-side `pnpm devbox:*` CLI surface

**Target:** Story 2.6 — user-facing-CLI surface translating operator intent into `docker compose` / `docker exec` invocations: 13 host-side bash scripts under `packages/devbox/scripts/` (`build`, `rebuild`, `start`, `stop`, `restart`, `clean`, `shell`, `attach`, `status`, `logs`, `monitor-host`, `whitelist-host`, `env-check`) + 13 `devbox:*` pnpm entries in repo-root `package.json` + uniform exit-code family (0/2/3/4/5-7/8/9/10/11/124) + healthcheck poll (stub-friendly; consumes Story 2.13 when landed) + three-tier destructive-op gate on `clean` + backend-B awareness + FR1a JSONL monitor-semantic pin (NOT `docker stats`). Absorbs Story 2.5 CR DEFERs AR-10 (operator-migration docs) + AR-11 (env-check shape validation) + AR-12 (COMPOSE_PROJECT_NAME docs polish) unconditionally; AR-7 (`/run` relocation) + AR-9 (`/etc/*` chown) conditional on operator-workstation smoke outcome per SC-19 + SC-20 — NOT triggered at iter-201 impl landing. Nine ACs delivered iter-201 via `/bmad-dev-story` single-iteration landing (10 Tasks / 25 SCs all green; 13 NEW scripts + 6 modified files exactly matching the v0.2 SM-reviewed forecast). Story State `in-dev` at iter-202 trace entry — iter-201 `/bmad-dev-story` completed AC 1–AC 9 end-to-end at substrate level + ITERATION-ENV-SAFE SMOKES ALL PASSED + `docker compose config --quiet` parse-smoke GREEN + sync-gate GREEN with 21 manifest entries (2× contentHash refresh verified: `INV-prek-prepare-lifecycle` `87f37b45…` → `5960e7c4…`; `INV-devbox-homedev-named-volume` `f34cb62f…` → `5e868749…`) + `pnpm check-all` GREEN + `pnpm typecheck` GREEN + `pnpm lint` GREEN (16 successful passes) + `pnpm format:check` GREEN. Per-AC lifecycle live smokes (AC 2-7 `pnpm devbox:{build,start,status,shell,logs,stop,restart,clean}` end-to-end) are **backend-A-only operator-workstation-deferred** per SC-13 + Story 2.4 SC-17 + Story 2.5 SC-13 precedent (DinD-B iteration env cannot safely exercise lifecycle-mutating `docker compose up/down/start/stop` sequences against a shared host daemon without risk of poisoning unrelated host projects; M4-Pro native Docker Desktop is the authoritative AC 2-7 verification environment). Canonical `pnpm devbox:*` recipes pinned in `packages/devbox/README.md § Host-side CLI (Story 2.6) § Verification (operator-workstation)` for the operator close-out pass.

**Date:** 2026-04-22
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 2.6 § Acceptance Criteria AC 1-9)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md` (AC 1–AC 9)

---

Note: This workflow does not generate tests. Story 2.6 is a **user-facing-CLI class substrate** story (SECOND of Epic 2's user-facing-CLI class after Story 2.4 whitelist CLI; SIXTH Epic 2 delivery overall: bash CLI with 13-verb host-side surface + pnpm wiring + env validation + monitor-semantic reconciliation + AR absorption triad — operates at the operator-workstation → Docker daemon boundary, orthogonal to Story 2.3's daemon+kernel-rule infrastructure-security class AND Story 2.5's architecture-security / container-hardening class; mirrors Story 2.4's user-facing-CLI posture but broader per-verb surface with simpler per-script complexity) whose § Dev-agent guardrails + 25 pinned scope clarifications + v1.0 iter-201 dev-story landing Change Log row explicitly defer per-AC live-lifecycle smokes (AC 2-7 `pnpm devbox:{build,start,status,shell,logs,stop,restart,clean}` end-to-end recipes) to M4-Pro operator workstation per SC-13 + Story 2.4 SC-17 + Story 2.5 SC-13 backend-B-deferred-live-smoke precedent. Rationale applies the FR14n ATDD-skip clause already invoked at iter-200 via hybrid ground-(a)-(b)-(c)-(d) variant-(ii)+(iii):

> _"SIXTEENTH cumulative Epic ATDD-skip precedent (Stories 1.7 iter-14 + 1.8 iter-29 + 1.9 iter-36 + 1.10 iter-43 + 1.11 iter-50 + 1.12 iter-57 + 1.13 iter-64 + 1.14 iter-71 + 1.15 iter-83 + 1.16 iter-90 + 2.1 iter-98 + 2.2 iter-147 + 2.3 iter-157 + 2.4 iter-173 + 2.5 iter-186 → 2.6 iter-200) — **sixth Epic 2 ATDD-skip** + **second user-facing-CLI class ATDD-skip** (Story 2.4 = user-facing-CLI: 1-script 4-subcommand bash CLI with regex validation + mutation-lock + atomic-replace + subcommand dispatcher; Story 2.6 = user-facing-CLI: 13-verb host-side pnpm wrapper surface + uniform exit-code family + healthcheck poll + three-tier destructive-op gate + backend-B awareness + env-validation + monitor-semantic pin). `/bmad-testarch-atdd` skill NOT invoked — preflight would HALT at Step 1.2 (zero-test-runner substrate: no vitest.config.\*/jest.config.\*/playwright.config.\*/cypress.config.\*/pyproject.toml/go.mod/Gemfile/Cargo.toml/csproj anywhere in tree; TEA test_framework: auto autodetects nothing; Epic 13 is the formal test-framework landing per PRD RS6). Rationale — ground (c) hybrid variant-(ii)+(iii): (ii) downstream integration-gate coverage (Story 2.7 Ralph auto-start TUI consumes devbox:attach + devbox:start primitives — validates AC 3 + AC 6 via auto-start + detach-key sequence; Story 2.8 Claude Code OAuth wrapper consumes devbox:shell — validates AC 5; Story 2.9 gh CLI OAuth wrapper consumes devbox:shell — validates AC 5; Story 2.10 prereq-check consumes devbox:env:check — validates AC 8; Story 2.13 real healthcheck dnsmasq+sshd probe lands — validates AC 3 healthcheck semantics without Story 2.6 code change; Epic 13 test-runner landing owns regression coverage); (iii) spec-declared adversarial coverage substitution — § Dev-agent guardrails + 25 pinned scope-clarifications (SC-1 through SC-25) + forthcoming /bmad-code-review (args: \"2\") adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.6 substrate diff: 13 new scripts + 4 docs surfaces + 2× invariant-hash refresh) substitute for red-phase scaffolds."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-200, per the hybrid ground-(a)-(b)-(c)-(d) variant-(ii)+(iii) rationale (substrate-verification-covers-ACs + iteration-env-safe-smokes-augment + no-runner + Epic 13 test-runner landing + spec-declared-CR-substitution + upstream-provenance-precedent) pinned in `.ralph/@plan.md § Context`. **SIXTEENTH cumulative trace-WAIVED precedent** — sixth Epic 2 trace-WAIVED and second **user-facing-CLI class** trace-WAIVED. Under the ATDD-skip-trace-WAIVED co-application rule, this is the **SEVENTEENTH pairing** overall (10 Epic-1 pairings + 2.1 + 2.2 + 2.3 + 2.4 + 2.5 + 2.6).

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status  |
| --------- | -------------- | ------------- | ---------- | ------- |
| P0        | 0              | 0             | 100%       | ✅ n/a  |
| P1        | 0              | 0             | 100%       | ✅ n/a  |
| P2        | 9              | 0             | 0%         | ❌ FAIL |
| P3        | 0              | 0             | 100%       | ✅ n/a  |
| **Total** | **9**          | **0**         | **0%**     | **❌**  |

**Legend:**

- ✅ PASS — Coverage meets quality gate threshold
- ⚠️ WARN — Coverage below threshold but not critical
- ❌ FAIL — Coverage below minimum threshold (blocker)

All nine ACs are **user-facing-CLI substrate** assertions over the Story 2.6 deliverables. Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` consistent with Stories 2.1 + 2.2 + 2.3 + 2.4 + 2.5 precedent (no P0 auth/payment/data-loss at substrate; no P1 primary user journey — operator interacts with the CLI surface once Stories 2.7/2.8/2.9/2.10 wire Ralph + Claude + gh + prereq-check consumers on top). Downstream test-runner landing may retro-classify AC 4 (`clean` destructive-op gate regression could destroy a host-shared volume under backend B) or AC 8 (env-check miss could propagate silent config drift) as P1 under runtime-harm taxonomy; Story 2.6 ships P2-uniform matching Stories 2.1-2.5 precedent.

---

### Detailed Mapping

#### AC-1: One script per command under `packages/devbox/scripts/` and each wired as a `pnpm devbox:<cmd>` entry in repo-root `package.json` (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.6-test-runner-landing + M4-Pro operator-workstation live lifecycle smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-201 live files + iteration-env `bash -n` smokes + pnpm wiring count + sync-gate refresh):**
  - **`packages/devbox/scripts/` (iter-201)**: 13 NEW bash scripts created per SC-2 table: `build.sh`, `rebuild.sh`, `start.sh`, `stop.sh`, `restart.sh`, `clean.sh`, `shell.sh`, `attach.sh`, `status.sh`, `logs.sh`, `monitor-host.sh`, `whitelist-host.sh`, `env-check.sh`. Each file is 0755; `#!/usr/bin/env bash`; `set -euo pipefail`; self-rooted path resolution via `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` + `DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"` (no absolute `/workspace/` paths — relocation-safe for fork re-rooting per SC-4). Banner comment block cites Story 2.6 + relevant AC ids + brief purpose + SC-5 exit-code table per SC-4. 6 pre-existing scripts UNEDITED (benchmark.sh / egress-log-tailer.sh / monitor.sh / reload-egress.sh / start-egress.sh / whitelist.sh) per SC-25 scope boundary.
  - **Repo-root `package.json` (iter-201)**: 13 NEW `devbox:*` script entries inserted between the `keel-invariants:*` block and `"prepare"` per SC-3. Each maps 1:1 to `./packages/devbox/scripts/<name>.sh`. Naming per PRD § CLI-Tool Surface `prd.md:488-494` + architecture § Devbox Package Tree `architecture.md:975-1004`: kebab-case + single colon for top-level (`devbox:build`) + double colon for sub-namespaced (`devbox:env:check`).
  - **Iteration-env substrate verification (iter-201)**: `pnpm run | grep -E '^\s+devbox:' | wc -l` → 13 (Subtask 8.5 smoke PASSED — captures absence regressions). `bash -n packages/devbox/scripts/<each>.sh` × 13 → all OK (Subtask 8.1 smoke PASSED). Story 2.6 LESSON formalised: `bash -n` as iteration-env-safe syntax smoke applies to every CLI-family story.
  - **Sync-gate GREEN (iter-201)**: `INV-prek-prepare-lifecycle` contentHash drift expected + captured + refreshed (`87f37b45…` → `5960e7c4…`) because package.json edit +13 devbox:* entries changes the sourcePath contents. Manifest updated; `pnpm --filter @keel/keel-invariants build` rebuilt `dist/check.js`; `keel-invariants:check-all` exit 0.
  - **`AGENTS.md` (iter-201)**: new H3 `### Host-side CLI (Story 2.6)` under `## Devbox iteration environment` AFTER the existing `### Container hardening (Story 2.5)` H3 per SC-24 — 5 terse operational bullets documenting pnpm as the only host surface + env-check pre-flight + named-volume preservation + uniform exit-code family + monitor semantic pin + cross-references to Story 2.4 whitelist + Story 2.5 hardening H3s.
  - **`packages/devbox/README.md` (iter-201)**: new H2 `## Host-side CLI (Story 2.6)` after `## Hardening (Story 2.5)` per SC-23 — FR1 summary citing `architecture.md:74` host-surface rule + 13-row subcommand table + exit-code family table + `.envrc` integration paragraph + backend-B awareness paragraph + operator-workstation verification recipes + iteration-env-safe smokes recipe + cross-references to Story 2.4 whitelist H3 for `pnpm devbox:whitelist` operator workflow.
  - **Live-smoke AC 1 runtime verification** (`pnpm devbox:build`, `devbox:start`, `devbox:status`, `devbox:shell`, `devbox:logs`, `devbox:stop`, `devbox:restart`, `devbox:clean` end-to-end lifecycle) deferred to M4-Pro operator workstation per Story 2.4 SC-17 + Story 2.5 SC-13 backend-B live-smoke constraint.
  - **Adversarial AC-1 coverage delegated to iter-CR**: Blind Hunter examines 13-script layer shape + main-guard + self-rooted path resolution + banner-exit-code-table consistency + package.json edit target ordering; Edge Case Hunter probes missing-script-file when pnpm entry exists (exit 127 bash-resolution) + duplicated pnpm entry detection + operator-ran-from-any-subdir relocation-safety via SCRIPT_DIR; Acceptance Auditor verifies AC 1 verbatim match — one script per command + every command exposed as `pnpm devbox:<cmd>`.

---

#### AC-2: `pnpm devbox:build` builds image from `packages/devbox/Dockerfile`; `pnpm devbox:rebuild` rebuilds with `--no-cache` (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.6-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-201 `build.sh` + `rebuild.sh` + iteration-env `bash -n` + `docker compose config --quiet` parse-smoke):**
  - **`packages/devbox/scripts/build.sh` (iter-201 NEW)**: `docker compose -f "${COMPOSE_FILE}" build devbox` per SC-8. Named service; compose handles cache. Exit 0 on success; propagates docker exit code on failure. Does NOT run the container (build-only).
  - **`packages/devbox/scripts/rebuild.sh` (iter-201 NEW)**: `docker compose -f "${COMPOSE_FILE}" build --no-cache devbox` per SC-8. Fresh rebuild from scratch (used after Dockerfile change or layer-corruption recovery). Backend-B destructive-op gate NONE required — `--no-cache` invalidates cache for the `keel-devbox` service only, not host-wide (SC-11 rationale).
  - **`packages/devbox/docker-compose.yml` (iter-201 UNTOUCHED per SC-18)**: compose file preserves Story 2.5 hardening posture verbatim. Both build.sh + rebuild.sh use `-f "${COMPOSE_FILE}"` explicit file flag (avoids working-directory ambiguity) + NO `-p`/`--project-name` flag (project-name pinned to `keel-devbox` via top-level `name:` at `docker-compose.yml:43`; operator overrides via `COMPOSE_PROJECT_NAME` documented in SC-22 AR-12 docs polish).
  - **Iteration-env substrate verification (iter-201)**: `bash -n build.sh` + `bash -n rebuild.sh` → OK. `docker compose config --quiet` (parse-smoke Subtask 10.5) → exit 0 (compose file parses cleanly).
  - **Live-smoke AC 2 runtime verification** (`pnpm devbox:build` → `keel-devbox:local` built; `pnpm devbox:rebuild` → same image rebuilt with `--no-cache`; cache invalidation verified via build-log absence of `CACHED` markers) deferred to M4-Pro operator workstation per SC-13.
  - **Adversarial AC-2 coverage delegated to iter-CR**: Blind Hunter examines `docker compose build` flag correctness + `-f` explicit-file-flag placement + `--no-cache` flag handling; Edge Case Hunter probes build-with-no-cache-dir + Dockerfile-absent + cross-run cache-invalidation determinism; Acceptance Auditor verifies AC 2 verbatim match.

---

#### AC-3: `pnpm devbox:start` brings up container via compose; healthcheck (Story 2.13) must pass before command returns zero (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.6-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-201 `start.sh` + pre-flight chain + healthcheck poll + SC-9 stub-friendly posture):**
  - **`packages/devbox/scripts/start.sh` (iter-201 NEW) pre-flight sequence per SC-9**: (1) `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || exit 8` (docker runtime reachable — emits `devbox: docker unreachable — is the daemon running?`); (2) `docker image inspect keel-devbox:local >/dev/null 2>&1 || exit 10` (image exists — emits `devbox: image not built — run 'pnpm devbox:build'`); (3) `env-check.sh` pre-flight invocation unless `KEEL_DEVBOX_START_SKIP_ENV_CHECK=true` (operator escape hatch for CI scenarios with alternate env injection per SC-14).
  - **`packages/devbox/scripts/start.sh` (iter-201 NEW) healthcheck poll loop per SC-9**: `docker compose -f "${COMPOSE_FILE}" up -d devbox` + stub-friendly poll `docker inspect --format '{{.State.Health.Status}}' keel-devbox 2>/dev/null || docker inspect --format '{{.State.Status}}' keel-devbox` every 2s up to `${KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S:-120}` seconds. Accepts `healthy`, bare `running` (pre-Story-2.13 posture when no healthcheck configured), or `starting` (within first 30s grace). Rejects `unhealthy|exited|dead|removing|paused` IMMEDIATELY → exit 11 (container left running for operator debug). On timeout → `devbox: container failed to reach healthy state within <N>s — check 'pnpm devbox:logs'` + exit 11. On success → `devbox: started (container keel-devbox)` + exit 0. MUST NOT block forever. MUST NOT auto-invoke `pnpm devbox:build` on image-missing.
  - **Story 2.13 coupling (iter-201)**: SC-9 poll loop is stub-friendly — Story 2.13 defines the real healthcheck (dnsmasq + sshd liveness). Story 2.6 consumes Story 2.13's healthcheck via the same poll loop (no code change required at Story 2.13 landing — the poll already accepts `healthy` from a configured healthcheck; `running` remains the pre-Story-2.13 fallback). SC-18 forbids Story 2.6 from defining the healthcheck itself.
  - **Iteration-env substrate verification (iter-201)**: `bash -n start.sh` → OK. `docker compose config --quiet` → exit 0. `pnpm devbox:env:check` (start.sh pre-flight) exit 0 with seeded `.envrc`.
  - **Live-smoke AC 3 runtime verification** (`pnpm devbox:start` → container transitions to `healthy|running`; healthcheck poll returns 0 within timeout; `docker compose ps devbox` shows container running) deferred to M4-Pro operator workstation per Story 2.4 SC-17 + Story 2.5 SC-13 precedent (DinD-B iteration env cannot safely `docker compose up -d` against a shared host daemon).
  - **Adversarial AC-3 coverage delegated to iter-CR**: Blind Hunter examines pre-flight sequence ordering + stub-friendly poll fallback logic (`.Health` vs `.Status` branch) + 30s starting grace vs strict rejection states; Edge Case Hunter probes healthcheck-undefined edge + container-already-running idempotence + timeout-exceeded leave-running-for-debug + unhealthy-immediate-exit-11 pre-timeout; Acceptance Auditor verifies AC 3 verbatim match.

---

#### AC-4: `pnpm devbox:stop` halts without destroying named volume; `devbox:restart` = stop+start; `devbox:clean` removes container+image but keeps named volume (confirm-before-volume-delete) (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.6-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-201 `stop.sh` + `restart.sh` + `clean.sh` three-tier + backend-B detection + NFR10 preservation):**
  - **`packages/devbox/scripts/stop.sh` (iter-201 NEW)**: `docker compose -f "${COMPOSE_FILE}" stop devbox` per SC-10. Does NOT call `down` (which removes the container); `stop` keeps the container object around so `start` is a no-op-fast next time. Named volume `keel_home_dev` is naturally preserved (stop doesn't touch volumes — matches Story 2.5 NFR10 substrate-authoritative posture). Exit 0 on success.
  - **`packages/devbox/scripts/restart.sh` (iter-201 NEW)**: invokes `stop.sh` then `start.sh` sequentially via absolute paths (`"${SCRIPT_DIR}/stop.sh"` + `"${SCRIPT_DIR}/start.sh"`) per SC-10. If stop fails, abort before start. Propagates start's exit code as final rc.
  - **`packages/devbox/scripts/clean.sh` (iter-201 NEW) three-tier destructive-op gate per SC-11**: (1) no-flag default: `docker compose -f "${COMPOSE_FILE}" down --rmi local --remove-orphans` — removes container + image (scoped to `keel-devbox:local` tag); leaves named volume `keel_home_dev` UNTOUCHED; safe under either backend; (2) `--with-volumes`: WARNING banner + explicit `[y/N]` prompt (`read -p "This will DESTROY the keel_home_dev named volume (Claude Code + gh tokens LOST). Continue? [y/N] "`); on `y` only → `docker compose down --rmi local --volumes --remove-orphans`; auto-yes via `--yes` (CI-only path); (3) `--allow-broad-prune`: RESERVED no-op at 1.0 — declared in banner but guarded invocation falls back to scoped `down --rmi local`; emits `devbox clean: --allow-broad-prune is reserved; scoped cleanup is the 1.0 default`.
  - **`packages/devbox/scripts/clean.sh` (iter-201 NEW) backend-B detection per SC-11**: mirrors `benchmark.sh § detect_backend` (`docs/invariants/devbox-dind.md:41-47`) — `if [[ -f /.dockerenv ]] || docker info --format '{{.Name}}' 2>/dev/null | grep -Eq '^(docker-desktop|moby|linuxkit-)'; then BACKEND=B; fi`. Under backend B, `clean.sh --with-volumes` refuses the volume-destroy path WITHOUT additional `--force-backend-b` flag (prevents accidental destruction of a host-shared docker volume on socket-passthrough envs). Emits `devbox clean: backend B detected — volume destruction requires --force-backend-b acknowledgement`.
  - **`packages/devbox/docker-compose.yml` (iter-201 UNTOUCHED)**: Story 2.5 named-volume contract preserved verbatim — `volumes: { keel_home_dev: {} }` top-level + service-level `type: volume, source: keel_home_dev, target: /home/dev` long-syntax. SC-18 forbids Story 2.6 from editing compose-shape; NFR10 substrate-authoritative posture guarantees `keel_home_dev` is the non-toggle-able home for Claude Code + gh tokens + shell history.
  - **Iteration-env substrate verification (iter-201)**: `bash -n stop.sh` + `bash -n restart.sh` + `bash -n clean.sh` → all OK. Dispatcher smokes (Subtask 8.3): `clean.sh --unknown` → exit 2 + usage block; `clean.sh --help` → exit 0 + usage block.
  - **Live-smoke AC 4 runtime verification** (`pnpm devbox:stop` preserves volume; `pnpm devbox:restart` = stop+start; `pnpm devbox:clean` default preserves keel_home_dev; `--with-volumes` with [y/N] + backend-B `--force-backend-b` gate) deferred to M4-Pro operator workstation per SC-13.
  - **Adversarial AC-4 coverage delegated to iter-CR**: Blind Hunter examines `stop` vs `down` semantic difference + `restart.sh` two-phase rc propagation + clean three-tier flag matrix + backend-B gate interaction; Edge Case Hunter probes volume-persistence across stop+start cycles + container-not-running-at-stop-time idempotence + double-prompt under `--with-volumes`+`--yes`; Acceptance Auditor verifies AC 4 verbatim match.

---

#### AC-5: `pnpm devbox:shell` opens interactive shell as `dev` user inside running container (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.6-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-201 `shell.sh` + Story 2.5 USER dev posture inherited):**
  - **`packages/devbox/scripts/shell.sh` (iter-201 NEW)**: `docker exec -it --user dev -w /workspace "${CONTAINER_NAME}" bash -l` per SC-13. Explicit `--user dev` matches Story 2.5 non-root posture (Dockerfile `USER dev`; UID/GID 1000). `-w /workspace` starts in workspace root so operators don't land in `/home/dev`. `-l` login shell to source bashrc/profile. Pre-flight: container-running gate (exit 9 if stopped; emits `devbox: container 'keel-devbox' is not running — run 'pnpm devbox:start' first`).
  - **`packages/devbox/docker-compose.yml` (iter-201 UNTOUCHED)**: Story 2.5 hardening posture preserved — `cap_drop: [ALL]` + `cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE]` + `security_opt: [no-new-privileges:true]` + tmpfs `/tmp` + `/var/tmp` with `exec=false,suid=false` + named volume `keel_home_dev` for `/home/dev`. Shell sessions inherit this hardening — operator sees bash prompt as dev user under capability-bounded + NNP + noexec posture.
  - **Iteration-env substrate verification (iter-201)**: `bash -n shell.sh` → OK. Dispatcher-level smoke not applicable (shell.sh takes no flags).
  - **Live-smoke AC 5 runtime verification** (`pnpm devbox:shell` → interactive bash prompt; `whoami` → `dev`; `id` → `uid=1000(dev) gid=1000(dev)`; `pwd` → `/workspace`; ctrl+D exits cleanly with rc 0) deferred to M4-Pro operator workstation per SC-13.
  - **Adversarial AC-5 coverage delegated to iter-CR**: Blind Hunter examines `docker exec -it --user dev -w /workspace` flag ordering + `bash -l` login-shell semantics + pre-flight container-running gate + interaction with Story 2.5 USER dev (no conflict); Edge Case Hunter probes shell-exit-via-ctrl+D + shell-exit-via-command-rc-propagation + root-home-access-denied under dev user + attempted-sudo-blocked under NNP; Acceptance Auditor verifies AC 5 verbatim match.

---

#### AC-6: `pnpm devbox:attach` attaches to container stdout/stderr (Story 2.7 TUI target); supports `Ctrl+P Ctrl+Q` detach without killing container (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.6-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-201 `attach.sh` + Story 2.7 coupling):**
  - **`packages/devbox/scripts/attach.sh` (iter-201 NEW)**: `docker attach --detach-keys='ctrl-p,ctrl-q' "${CONTAINER_NAME}"` per SC-13. `--detach-keys` pins Ctrl+P Ctrl+Q as the detach sequence (docker's default; making it explicit protects against future docker-default changes that might surprise operators mid-Ralph-iteration). `attach` returns the PID 1 process's stdio to the operator — this is the Ralph TUI in Story 2.7. Pre-flight: container-running gate (exit 9 if stopped).
  - **Story 2.7 coupling (iter-201)**: Ralph auto-start TUI attach/detach via `pnpm ralph:build` + `pnpm ralph:plan` (Story 2.7 scope; backlog at iter-202) consumes `pnpm devbox:attach` as its canonical attach primitive. Detach-key sequence ctrl-p,ctrl-q is load-bearing — the sequence must NOT kill the container (which would lose Ralph state between iterations). SC-25 scope-boundary forbids Story 2.6 from shipping the Ralph TUI wiring itself; Story 2.7 owns that composition.
  - **Iteration-env substrate verification (iter-201)**: `bash -n attach.sh` → OK.
  - **Live-smoke AC 6 runtime verification** (`pnpm devbox:attach` → operator's terminal connected to PID 1 stdio; `Ctrl+P Ctrl+Q` → clean detach; container still running post-detach; re-attach reconnects) deferred to M4-Pro operator workstation per SC-13.
  - **Adversarial AC-6 coverage delegated to iter-CR**: Blind Hunter examines `docker attach --detach-keys='ctrl-p,ctrl-q'` flag literal + pre-flight container-running gate + SIGINT-vs-detach behaviour; Edge Case Hunter probes attach-to-non-pid-1-entrypoint + double-attach from two terminals + detach-with-custom-keys-envvar; Acceptance Auditor verifies AC 6 verbatim match.

---

#### AC-7: `pnpm devbox:status` prints container state + healthcheck; `devbox:logs` tails container stdout/stderr; `devbox:monitor` displays a live FR1a JSONL DNS-event tail (NOT `docker stats` — PRD `:494` authoritative) (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.6-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-201 `status.sh` + `logs.sh` + `monitor-host.sh` + SC-15 monitor-semantic pin):**
  - **`packages/devbox/scripts/status.sh` (iter-201 NEW)**: `docker compose -f "${COMPOSE_FILE}" ps --format table devbox` + explicit healthcheck extraction via `docker inspect --format '{{.State.Health.Status}}' "${CONTAINER_NAME}" 2>/dev/null || echo "(no healthcheck configured)"` per SC-15. Exit 0 even if container stopped (status-reporting is not itself an error); exit 9 only if the container object doesn't exist at all.
  - **`packages/devbox/scripts/logs.sh` (iter-201 NEW)**: `docker compose -f "${COMPOSE_FILE}" logs -f --tail=100 devbox` per SC-15. Default follow-mode with 100-line backlog. Flags `--no-follow`, `--tail=<N>` forwarded to compose. Exit 0 on clean detach (SIGINT).
  - **`packages/devbox/scripts/monitor-host.sh` (iter-201 NEW)**: host-side shim per SC-15 — `docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/monitor.sh "$@"`. The in-container target is Story 2.3's pre-existing JSONL egress-log tailer at `packages/devbox/scripts/monitor.sh` (banner line 2 confirms: `"packages/devbox/scripts/monitor.sh — Story 2.3 (AC 3 observability) — Operator-facing live tail of the JSONL egress query log."`). Story 2.6 does NOT rename, delete, or edit the in-container primitive.
  - **SC-15 monitor-semantic pin (iter-201)**: `pnpm devbox:monitor` ships as the FR1a JSONL DNS-event tail per PRD `:494` (`"Structured tail of allowed/blocked DNS events consuming the FR1a structured query-log (JSONL)."`) + architecture `:1003` (`"monitor.sh # JSONL tail (FR1a replacement for monitor-blocks.sh)"`). Epics AC 7 "cpu/memory/network" phrasing is historical drift from the PRD and does NOT override the authoritative PRD + architecture definition — any future `docker stats`-style verb would be a separate story (out of scope at 1.0 per SC-25). Story v0.2 iter-199 AI-2 CRITICAL resolved this drift at pre-dev SM review; v1.0 iter-201 landing implements the pin correctly.
  - **Iteration-env substrate verification (iter-201)**: `bash -n status.sh` + `bash -n logs.sh` + `bash -n monitor-host.sh` → all OK. Pre-flight for `monitor-host.sh` verifies in-container `monitor.sh` presence; failure exits 3 with `devbox monitor: in-container primitive missing — rebuild via 'pnpm devbox:build'`.
  - **Live-smoke AC 7 runtime verification** (`pnpm devbox:status` compose-ps+healthcheck lines; `pnpm devbox:logs` follow-mode tail; `pnpm devbox:monitor` JSONL event tail from `/workspace/logs/egress-queries.jsonl`) deferred to M4-Pro operator workstation per SC-13.
  - **Adversarial AC-7 coverage delegated to iter-CR**: Blind Hunter examines `docker compose ps --format table` output shape + `docker inspect .State.Health.Status` null-handling branch + `logs -f --tail=100` flag forwarding + `monitor-host.sh` shim passthrough (no subcommand parser inside shim — SC-16 dual-source-of-truth-for-validation avoidance); Edge Case Hunter probes status-on-stopped-container (exit 0 per SC-15) + logs-with-empty-container + monitor-host-against-pre-Story-2.3-container; Acceptance Auditor verifies AC 7 verbatim match — includes SC-15 monitor-semantic pin reconciling epics AC 7 drift.

---

#### AC-8: `pnpm devbox:env:check` validates `.envrc` presence + every required `KEEL_DEVBOX_*` var; exits non-zero with missing-var report if any absent (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.6-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop) — **NOTE:** this AC has the STRONGEST iteration-env evidence of all 9; three end-to-end branches (exit 3 / exit 0 / exit 2) ran in iteration env at iter-201.
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONGEST; iter-201 `env-check.sh` + AR-11 shape validation + iteration-env-safe smokes PASSED for 3 branches):**
  - **`packages/devbox/scripts/env-check.sh` (iter-201 NEW) algorithm per SC-14**: (1) `ENVRC_PATH="${DEVBOX_DIR}/../../.envrc"` (repo-root .envrc); if not readable → exit 3 with `devbox env-check: .envrc not found at <path> — run 'direnv allow' or copy .envrc.example`; (2) parse `.envrc` line by line; for each `export KEEL_DEVBOX_<NAME>=…` or `KEEL_DEVBOX_<NAME>=…`, record var name + value; (3) REQUIRED_VARS constant = 15 active `.envrc.example` keys (regenerated at impl-time via `rg 'KEEL_DEVBOX_[A-Z_]+' packages/devbox/ .envrc.example | sort -u`; Task 1.4 Debug Log records final list); (4) AR-11 absorption: for TMPFS_TMP_MB + TMPFS_VARTMP_MB + TMPFS_LOGS_MB, additionally validate value shape via regex `^[1-9][0-9]*$` (reject 0, empty, negative, or non-numeric `"2gb"`); (5) emit stdout summary: `env-check: <N> of <M> required vars present; <K> value-shape violations`; (6) exit 0 iff every required var present AND every shape-validated var passes; otherwise exit 2.
  - **`packages/devbox/scripts/env-check.sh` (iter-201 NEW) names-only stderr posture per SC-14**: `env-check` NEVER echoes a var's value to stdout/stderr for credential-classed vars (pattern `*_TOKEN|*_SECRET|*_KEY|*_PASSWORD`). For shape-violated tmpfs-int vars, stderr MAY include the offending value (these are non-credential shape assertions).
  - **`packages/devbox/scripts/start.sh` (iter-201) env-check pre-flight integration**: `start.sh` invokes `env-check.sh` as its OWN pre-flight unless `KEEL_DEVBOX_START_SKIP_ENV_CHECK=true` (operator escape hatch for CI scenarios with alternate env injection per SC-14).
  - **AR-11 absorption (iter-201)**: env-check shape-validation for tmpfs-size knobs absorbs Story 2.5 CR AR-11 deferred-to-Story-2.6 action item. Task 1.4 regenerated authoritative `KEEL_DEVBOX_*` var list at impl-time: 18 var names across the codebase; 15 active `.envrc.example` keys as REQUIRED_VARS; 2 optional (`KEEL_DEVBOX_CONTAINER_NAME`, `KEEL_DEVBOX_WORKSPACE`); 1 code-internal (`KEEL_DEVBOX_WORKSPACE_OWNER`).
  - **Iteration-env substrate verification (iter-201) — Task 3.2 + Task 8.2 smokes ALL PASSED**: (a) `pnpm devbox:env:check` with NO `.envrc` present → exit 3 + stderr `devbox env-check: .envrc not found at …`; (b) `pnpm devbox:env:check` with seeded `.envrc` (copied from `.envrc.example`) → exit 0 + stdout `env-check: 15 of 15 required vars present; 0 value-shape violations`; (c) `pnpm devbox:env:check` with deliberately-bad tmpfs ints (`KEEL_DEVBOX_TMPFS_TMP_MB=2gb` + `KEEL_DEVBOX_TMPFS_VARTMP_MB=0`) → exit 2 + both violations reported by name on stderr. **ALL THREE BRANCHES executed in iteration env** — strongest runtime evidence of any Story 2.6 AC.
  - **Live-smoke AC 8 runtime verification** covered by iteration-env-safe smokes above (env-check is host-side; NOT docker-dependent). Additional operator-workstation smoke documented in README: `pnpm devbox:env:check` after `cp packages/devbox/.envrc.example .envrc && direnv allow` → exit 0 + success summary.
  - **Adversarial AC-8 coverage delegated to iter-CR**: Blind Hunter examines REQUIRED_VARS list correctness vs `.envrc.example` active block + `.envrc` parse regex + names-only-secrets-discipline pattern match + tmpfs-int shape regex; Edge Case Hunter probes .envrc-with-commented-out-KEEL_DEVBOX-var + .envrc-with-blank-value (is PRESENT per SC-14) + .envrc-with-value-containing-`#` + Unicode/non-ASCII var values + SECRETS-classed var with value masked in stderr; Acceptance Auditor verifies AC 8 verbatim match.

---

#### AC-9: `pnpm devbox:whitelist` invokes atomic-reload flow from Story 2.4 (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.6-test-runner-landing + M4-Pro operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-201 `whitelist-host.sh` + Story 2.4 SC-12 scope-boundary satisfaction + exit-code passthrough):**
  - **`packages/devbox/scripts/whitelist-host.sh` (iter-201 NEW)**: thin shim per SC-16 — `docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/whitelist.sh "$@"`. Arguments passthrough verbatim (including `add|remove|list|sync` subcommand + domain argument). Pre-flight: container-running gate (exit 9 if stopped); does NOT auto-start the container (operator intent must be explicit).
  - **Story 2.4 SC-12 scope-boundary satisfaction (iter-201)**: `whitelist-host.sh` is the EXACT `docker exec`-shim Story 2.4's SC-12 explicitly deferred to Story 2.6. Hyphen-suffix filename disambiguates from in-container `whitelist.sh` so a fork operator grepping `packages/devbox/scripts/whitelist*` immediately sees the two-file pattern (in-container primitive + host-side shim). DO NOT add a dispatch / subcommand parser inside `whitelist-host.sh` — it's pure passthrough; any CLI argument validation is the responsibility of the in-container `whitelist.sh` (avoids dual-source-of-truth-for-validation drift per SC-16).
  - **`packages/devbox/scripts/whitelist.sh` (iter-201 UNTOUCHED)**: Story 2.4 in-container atomic-reload primitive preserved verbatim — SC-4 three-stage composer (baseline + fragments + local override) + atomic-replace via `mv` on same filesystem + file-lock coordination + dnsmasq/nftables reload via Story 2.3 reload-egress.sh. Exit-code passthrough: `whitelist.sh` exits 0/2/3/4/5/6/7; host-side shim propagates verbatim (SC-5 exit-code table codes 5-7 reserved for in-container primitive passthrough).
  - **Story 2.4 SC-12 pnpm devbox:whitelist wiring update (iter-201)**: Story 2.4 iter-174 pointed `devbox:whitelist` at `packages/devbox/scripts/whitelist.sh` (the in-container primitive; temporary wiring). Story 2.6 iter-201 UPDATES this entry to `./packages/devbox/scripts/whitelist-host.sh` (the host-side shim) per SC-3. Story 2.4 Dev-Agent-Record iter-174 anticipated this replacement.
  - **Iteration-env substrate verification (iter-201)**: `bash -n whitelist-host.sh` → OK. Dispatcher-level smoke not applicable — whitelist-host.sh is pure passthrough; any subcommand validation is in-container primitive's responsibility.
  - **Live-smoke AC 9 runtime verification** (`pnpm devbox:whitelist add example.com` → in-container writes + composes + reloads; `pnpm devbox:whitelist list` → source-attributed `D|F:<name>|L` prefixes; `pnpm devbox:whitelist sync` → recompose + reload without mutation) deferred to M4-Pro operator workstation per SC-13 + Story 2.4 SC-17 precedent.
  - **Adversarial AC-9 coverage delegated to iter-CR**: Blind Hunter examines shim passthrough correctness (`"$@"` argument forwarding; `docker exec -it` TTY posture) + container-running pre-flight + no-auto-start posture; Edge Case Hunter probes exit-code-passthrough (in-container 0/2/3/4/5/6/7 all propagate) + stdout/stderr streaming correctness + SIGINT propagation; Acceptance Auditor verifies AC 9 verbatim match — `devbox:whitelist` invokes the Story 2.4 atomic-reload flow via host-side shim → in-container primitive.

---

## PHASE 2: TEST INVENTORY

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

None — AC coverage breakdown has no P0 rows (user-facing-CLI substrate at Story 2.6 substrate stage, matching Stories 2.1 + 2.2 + 2.3 + 2.4 + 2.5 P2-uniform precedent).

### High-Priority Gaps (Priority P1)

None — AC coverage breakdown has no P1 rows. See § Coverage Summary note: downstream test-runner landing may retro-classify AC 4 (`clean` destructive-op regression) or AC 8 (env-check silent-config-drift) as P1 under runtime-harm taxonomy; Story 2.6 ships P2-uniform matching Stories 2.1-2.5 precedent.

### Medium-Priority Gaps (Priority P2)

Nine ACs (AC-1 through AC-9) at coverage NONE — substrate evidence STRONG for all nine at iter-201; iteration-env-safe smokes ALL PASSED; per-AC lifecycle live smokes (AC 2-7 build/start/status/shell/logs/stop/restart/clean end-to-end) deferred to M4-Pro operator workstation per SC-13 + Story 2.4 SC-17 + Story 2.5 SC-13 backend-B live-smoke precedent. AC 8 (env-check) has the strongest evidence of all — three end-to-end branches (exit 3 / exit 0 / exit 2) ran in iteration env.

### Low-Priority Gaps (Priority P3)

None.

---

## PHASE 4: COVERAGE HEURISTICS

- **Endpoint coverage gaps:** 0 (no API endpoints in scope — host-side CLI substrate)
- **Auth negative-path gaps:** `not_applicable` (no auth surface in scope)
- **Happy-path-only gaps:** 0 (all 9 ACs explicitly include failure paths via SC-5 uniform exit-code family)
- **UI journey gaps:** `not_applicable` (no UI surface in scope)
- **UI state gaps:** `not_applicable`

---

## PHASE 5: RECOMMENDATIONS

1. **[MEDIUM] Accept WAIVED posture** — 9 P2 ACs cover a user-facing-CLI class story (SECOND of its class after Story 2.4 iter-174 whitelist CLI; SIXTH Epic 2 delivery) with no live test runner at 1.0. All 9 ACs have STRONG substrate evidence verified LIVE at iter-201 + iteration-env-safe smokes ALL PASSED (bash -n × 13; pnpm wiring count 13; env-check exit-3/exit-0/exit-2; dispatcher usage). Per-AC lifecycle live smokes deferred to M4-Pro operator workstation per SC-13 + Story 2.4 SC-17 + Story 2.5 SC-13 backend-B live-smoke precedent.

2. **[MEDIUM] Story 2.6 authors 13 NEW bash scripts + 6 modified files per SC-25 scope boundary.** Downstream consumers: Story 2.7 Ralph auto-start TUI (consumes devbox:attach + devbox:start); Story 2.8 Claude Code OAuth wrapper (consumes devbox:shell); Story 2.9 gh CLI OAuth wrapper (consumes devbox:shell); Story 2.10 prereq-check (consumes devbox:env:check); Story 2.13 real healthcheck (consumed by SC-9 start.sh poll loop with no code change); Story 2.17 runtime compose-shape check (orthogonal).

3. **[MEDIUM] Story 2.6 test-runner landing (Epic 13 scope) + backend-A operator-workstation live lifecycle smokes** will unlock per-AC runner-hosted probes. None block Story 2.6 `review → done` transition under the WAIVED precedent — substrate evidence + iteration-env-safe smokes at iter-201 are complete for the in-iteration-executable portion of the story.

4. **[LOW] Run /bmad-testarch-test-review to assess test quality** (no tests exist — no-op; recorded for parity with downstream pipelines).

---

## PHASE 6: RATIONALE

Story 2.6 applies the FR14n ATDD-skip clause already invoked at iter-200 per hybrid ground-(a)-(b)-(c)-(d) variant-(ii)+(iii):

- **Ground (a) substrate-verification-covers-ACs:** 13 bash scripts + 13 pnpm entries + healthcheck poll + three-tier clean gate + env-check with AR-11 shape validation + monitor-semantic pin + AR absorption triad (AR-10 + AR-11 + AR-12) all live at iter-201 with sync-gate 2× refresh GREEN. Iteration-env-safe smokes ALL PASSED across syntax + wiring + env-check + dispatcher surfaces — stronger than Story 2.5 (zero runtime assertions for some ACs).
- **Ground (b) no test runner at Story 2.6 time** — Epic 13 scope per sixteen precedents (Stories 1.7-1.16 + 2.1-2.5 uniform).
- **Ground (c) variant (ii) downstream coverage:** Stories 2.7 (Ralph TUI attach/detach) + 2.8 (Claude OAuth wrapper) + 2.9 (gh OAuth wrapper) + 2.10 (prereq-check) + 2.13 (real healthcheck) validate Story 2.6 primitives at integration level; Epic 13 delivers test-runner regression coverage.
- **Ground (c) variant (iii) spec-declared-CR-substitution:** 25 pinned scope-clarifications + forthcoming `/bmad-code-review` adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out) substitute for red-phase scaffolds.
- **Ground (d) upstream-provenance-precedent:** upstream cc-devbox has no test suite; Story 2.6 re-exposes upstream Makefile targets as `pnpm devbox:*` + adds `attach` + `env:check` per PRD M0.5(e) lifecycle bridge.

The deterministic FAIL signal (overall 0% < 80%) is a structural false-positive; no test runner is wired at Story 2.6 substrate stage.

**SIXTEENTH CUMULATIVE TRACE-WAIVED PRECEDENT** — SECOND user-facing-CLI class after Story 2.4 (iter-175), distinct from Story 2.3's daemon+kernel-rule infrastructure-security class and Story 2.5's architecture-security / container-hardening class. **SEVENTEENTH ATDD-skip-trace-WAIVED co-application pairing** overall (10 Epic-1 + 2.1-2.6).

Unlike Story 2.5's zero-runtime-assertions DinD-B-blocked posture, Story 2.6's iteration-env evidence mirrors Story 2.4's MORE-than-Story-2.3 stance: host-side bash runs freely in iteration env without docker lifecycle mutation. Story 2.6 advances Story State `in-dev → traced` (FR14n lifecycle matrix); next QUEUE item: `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification (`traced → sm-verified` or `sm-fixes-pending`).

---

## GATE DECISION: WAIVED

**Rationale:** User-facing-CLI class substrate story with zero test runner at Story 2.6 stage; nine P2 ACs covered by STRONG substrate evidence + iteration-env-safe smokes (bash -n × 13; pnpm wiring count 13; env-check three-branch exit 3/0/2; dispatcher usage) + backend-A operator-workstation live lifecycle recipes pinned in README. FR14n ATDD-skip clause hybrid ground-(a)-(b)-(c)-(d) variant-(ii)+(iii) applied at iter-200; this gate mirrors that clause. SIXTEENTH cumulative trace-WAIVED precedent; SEVENTEENTH ATDD-skip-trace-WAIVED pairing.

**Gate Criteria:**

| Criterion                | Threshold | Actual | Status |
| ------------------------ | --------- | ------ | ------ |
| P0 Coverage              | 100%      | 100%   | ✅ MET (no P0 rows) |
| P1 Coverage              | ≥90% (80% minimum) | 100%  | ✅ MET (no P1 rows) |
| Overall Coverage         | ≥80%      | 0%     | ❌ NOT_MET (structural — no test runner) |

**Overall Status:** WAIVED ✅ (Story advances `in-dev → traced`)

**Next Steps:**

- Run `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification (`traced → sm-verified`).
- On `sm-verified`, run `/bmad-code-review (args: "2")` per § Story Lifecycle Decision Matrix (forecast: 4-6 PATCH opener for user-facing-CLI class; Story 2.4 5-PATCH envelope precedent).

---

**Generated:** 2026-04-22
**Workflow:** testarch-trace v4.0 (Enhanced with Gate Decision)

<!-- Powered by BMAD-CORE™ -->
