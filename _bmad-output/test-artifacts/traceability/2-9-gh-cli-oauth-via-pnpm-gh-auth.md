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
lastSaved: '2026-04-23'
workflowType: 'testarch-trace'
inputDocuments:
  [
    '_bmad-output/implementation-artifacts/2-9-gh-cli-oauth-via-pnpm-gh-auth.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    'INVARIANTS.md',
    'AGENTS.md',
    'CLAUDE.md',
    'RALPH.md',
    'packages/devbox/README.md',
    'packages/devbox/scripts/gh-auth-host.sh',
    'packages/devbox/whitelist/github.txt',
    'package.json',
    '_bmad-output/test-artifacts/traceability/2-8-gate-decision.json',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/2-9-gh-cli-oauth-via-pnpm-gh-auth.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/2-9-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 2.9 `gh` CLI OAuth via `pnpm gh:auth`

**Target:** Story 2.9 — Epic-2-ships-envelope-upstream-CLI-ships-runtime class story (SECOND instance of the class after Story 2.8; first was Claude Code OAuth) delivering 1 host-side bash shim (`packages/devbox/scripts/gh-auth-host.sh`) that pre-flights docker reachability (AC 1 exit 8 branch) + container liveness (AC 1 exit 9 branch per SC-4 no-auto-start) + bind-mount source alignment (exit 12 branch retrofitted via iter-239 `lib/check-mount-source.sh`), then `exec docker exec -it --user dev -w "${CONTAINER_WORKDIR}" -e KEEL_DEVBOX_REPO_NAME=${REPO_NAME} keel-devbox gh auth login "$@"` so apt-installed upstream `gh` CLI (Dockerfile:123-136; Renovate `apt` manager-tracked per Story 1.15) surfaces its GitHub OAuth device-code URL + one-time code on the operator terminal (AC 1) and writes the resulting token under `/home/dev/.config/gh/` inside the Story 2.5 `keel_home_dev` named volume (AC 2), where it survives `pnpm devbox:restart` (AC 3) until upstream `gh` CLI detects expiry or revocation and surfaces a re-auth pointer that Ralph's pre-push gate (Epic 3 Story 3.7) treats as a halt-able condition (AC 4 — novel two-element AC vs. Story 2.8's 5-AC split). SC-2 pins the upstream-CLI scope carve-out: Story 2.9 ships the invocation envelope; upstream `gh` CLI + GitHub's OAuth endpoint + Docker named-volume substrate (Story 2.5) + Epic-3-Story-3.7 halt-write consumer own all four AC behaviors. Four ACs delivered iter-237 via `/bmad-dev-story` single-iteration landing (6 Tasks / 36 subtasks all green; 1 NEW script + 3 modified files exactly matching the iter-235 pre-dev SM-reviewed v1.1 post-2-PATCH forecast — ZERO-DRIFT implementation). Story State `in-dev` at iter-242 trace entry — iter-237 `/bmad-dev-story` completed AC 1–AC 4 end-to-end at substrate level + ITERATION-ENV-SAFE SMOKES ALL PASSED (bash -n × 1; pnpm wiring count 1; stub-docker info-fail → exit 8 + log; stub-docker not-running → exit 9 + log; stub-docker running → final exec args `-it --user dev -w /workspace keel-devbox gh auth login` captured + exit 0; args-passthrough `gh-auth-host.sh --web` → stub captures `--web` arg verbatim; no-TTY-gate grep → 0 matches). Live OAuth-flow smokes (AC 1 URL surface + AC 2 token file write + AC 3 restart-survival + AC 4 re-auth-pointer) are **backend-A-only operator-workstation-deferred** per SC-17 (GitHub OAuth endpoint + upstream `gh` CLI + Docker substrate own the behaviors; DinD-B iteration env cannot safely exercise interactive OAuth against GitHub without polluting operator credentials; Story 2.5 iter-187 + Story 2.6 iter-201/204/216/219 + Story 2.7 iter-223 + Story 2.8 iter-230 precedent cluster inherited). Post-iter-237 iter-239 infrastructure-refactor retrofit (`lib/main-repo-resolver.sh` + `lib/check-mount-source.sh` sourcing; final exec uses `${CONTAINER_WORKDIR}` instead of hardcoded `/workspace` + `-e KEEL_DEVBOX_REPO_NAME=${REPO_NAME}` env var; exit 12 branch for bind-mount mismatch) is substrate-polish orthogonal to AC 1–4 verification envelope — wrapper is still stateless, still interactive-only, still no-auto-start, still no wrapper-side token inspection (SC-15). Canonical `pnpm gh:auth` usage recipes pinned in `packages/devbox/README.md § gh CLI authentication (Story 2.9)` for the operator first-run + args-composition (`--web`, `--hostname github.com`, `--scopes "repo,workflow"`) + re-auth paths.

**Date:** 2026-04-23
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 2.9 § Acceptance Criteria AC 1–4)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/2-9-gh-cli-oauth-via-pnpm-gh-auth.md` (AC 1–AC 4)

---

Note: This workflow does not generate tests. Story 2.9 is an **Epic-2-ships-envelope-upstream-CLI-ships-runtime class substrate** story (SECOND of its class after Story 2.8 — distinct from Story 2.1 upstream-absorb, Story 2.2 envrc-parameterisation, Story 2.3 daemon+kernel-rule infrastructure-security, Story 2.4 in-container CLI, Story 2.5 architecture-security/container-hardening, Story 2.6 user-facing-CLI 13-verb host-side surface, Story 2.7 Epic-2-envelope-Epic-3-runtime; operates at the operator-terminal → `docker exec -it` boundary delegating four ACs to upstream `gh` CLI + GitHub OAuth endpoint + Story 2.5 Docker named-volume substrate + Epic 3 Story 3.7 pre-push-gate halt-write consumer). Story 2.9 § Testing Standards + 17 pinned scope clarifications + v1.3 iter-237 dev-story landing Change Log row explicitly defer AC 1–AC 4 live-OAuth smokes to M4-Pro operator workstation per SC-17 + Story 2.5 SC-13 + Story 2.6 SC-13 + Story 2.7 SC-17 + Story 2.8 SC-17 backend-B-deferred-live-smoke precedent. Rationale applies the FR14n ATDD-skip clause already invoked at iter-236 via hybrid ground-(a)-(b)-(c) variant-(iii) + ground-(c) variant `external-service-owns-behavior-under-test` (inherited verbatim from Story 2.8 with 1:1 GitHub-for-Anthropic substitution):

> _"NINETEENTH cumulative Epic ATDD-skip precedent (Stories 1.7 iter-14 + 1.8 iter-29 + 1.9 iter-36 + 1.10 iter-43 + 1.11 iter-50 + 1.12 iter-57 + 1.13 iter-64 + 1.14 iter-71 + 1.15 iter-83 + 1.16 iter-90 + 2.1 iter-98 + 2.2 iter-147 + 2.3 iter-157 + 2.4 iter-173 + 2.5 iter-186 + 2.6 iter-200 + 2.7 iter-222 + 2.8 iter-229 → 2.9 iter-236) — **ninth Epic 2 ATDD-skip** + **second Epic-2-ships-envelope-upstream-CLI-ships-runtime class ATDD-skip**. `/bmad-testarch-atdd` skill NOT invoked — preflight would HALT at Step 1.2 (zero-test-runner substrate: no vitest.config.\*/jest.config.\*/playwright.config.\*/cypress.config.\* anywhere in tree at iter-236/iter-242; TEA test_framework: auto autodetects nothing; Epic 13 is the formal test-framework landing per PRD RS6). Rationale — ground (c) hybrid variant-(iii) + ground-(c) variant `external-service-owns-behavior-under-test`: (iii) spec-declared adversarial coverage substitution — § Dev-agent guardrails + 17 pinned scope-clarifications (SC-1 through SC-17 covering FR1 non-toggle-able invariant extension to 17-verb total surface + SC-2 upstream `gh` CLI + GitHub OAuth endpoint own auth-flow semantics + SC-3 pnpm wiring precedence + SC-4 no-auto-start fail-closed exit 9 + SC-6 hardcoded-`-it` no-TTY-detect-gate + SC-9 `\"$@\"` args-passthrough scoped to `gh auth login` + SC-12 no compose edits + SC-14 host-side-shim accounting 17 at Story 2.9 landing + SC-15 wrapper does NOT inspect/parse token file + SC-17 read-only posture on Story 2.6/2.7/2.8 README + AGENTS.md sections) + /bmad-code-review (args: \"2\") adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.9 substrate diff: 1 new script + 3 modified files — forecast 0 PATCH opener + 0 closure re-run per Story 2.7 iter-226 + Story 2.8 iter-233 ONE-PASS ZERO-PATCH cumulative precedent; Story 2.9 is FOURTH one-pass ZERO-PATCH candidate given narrowest novel surface in Epic 2 to date); ground-(c) variant `external-service-owns-behavior-under-test` for AC 1/2/3/4 — AC 1's `OAuth URL surfaced to my host terminal` + AC 2's `tokens stored at /home/dev/.config/gh/` + AC 3's `token reused across restart` + AC 4's `re-auth pointer + Ralph pre-push gate halt-able` all reference behaviors owned by (i) upstream `gh` CLI (apt-installed; Dockerfile:123-136; Renovate `apt` manager-tracked) + (ii) GitHub's OAuth endpoint (external service; Story 2.3/2.4 egress substrate whitelists 7 domains per `packages/devbox/whitelist/github.txt`: `api.github.com`, `github.com`, `raw.githubusercontent.com`, `objects.githubusercontent.com`, `codeload.github.com`, `ghcr.io`, `pkg-containers.githubusercontent.com`) + (iii) Docker named-volume persistence (Story 2.5 `keel_home_dev` + `INV-devbox-homedev-named-volume` already verified — not re-verified at Story 2.9 scope) + (iv) Epic 3 Story 3.7 pre-push-gate halt-write consumer (`INV-ralph-halt-reason-enum` closed halt-reason `CI_BLOCKED`; Story 2.9 pins contract, Epic 3 implements); full verification unlocks at M4-Pro operator workstation backend-A live OAuth flow. This is 1:1 mechanical inheritance from Story 2.8's ground-(c) variant with GitHub-for-Anthropic substitution; AC 4 novel two-element structure (re-auth pointer + Ralph halt-able) compresses Story 2.8's AC 4 (re-auth) + AC 5 (volume-delete) into a single AC that also pins the Epic 3 Story 3.7 consumer contract."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-236, per the hybrid ground-(a)-(b)-(c) variant-(iii) + ground-(c) variant `external-service-owns-behavior-under-test` rationale pinned in `.ralph/@plan.md § Context` + story file § Change Log v1.2. **NINETEENTH cumulative trace-WAIVED precedent** — ninth Epic 2 trace-WAIVED and second **Epic-2-ships-envelope-upstream-CLI-ships-runtime class** trace-WAIVED. Under the ATDD-skip-trace-WAIVED co-application rule, this is the **TWENTIETH pairing** overall (10 Epic-1 pairings + 2.1 + 2.2 + 2.3 + 2.4 + 2.5 + 2.6 + 2.7 + 2.8 + 2.9).

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status  |
| --------- | -------------- | ------------- | ---------- | ------- |
| P0        | 0              | 0             | 100%       | ✅ n/a  |
| P1        | 0              | 0             | 100%       | ✅ n/a  |
| P2        | 4              | 0             | 0%         | ❌ FAIL |
| P3        | 0              | 0             | 100%       | ✅ n/a  |
| **Total** | **4**          | **0**         | **0%**     | **❌**  |

**Legend:**

- ✅ PASS — Coverage meets quality gate threshold
- ⚠️ WARN — Coverage below threshold but not critical
- ❌ FAIL — Coverage below minimum threshold (blocker)

All four ACs are **Epic-2-ships-envelope-upstream-CLI-ships-runtime substrate** assertions over the Story 2.9 deliverables. Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` consistent with Stories 2.1–2.8 precedent (no P0 auth/payment/data-loss at substrate — the OAuth flow IS auth, but AC-class here is "wrapper invocation envelope" not "credential-storage mechanism"; no P1 primary user journey — upstream `gh` CLI delivers the primary OAuth UX; Story 2.9 ships the host-side invocation path envelope). Downstream test-runner landing may retro-classify AC 1 (docker exec TTY + stdin_open reliability) or AC 4 (Ralph halt-write consumer contract correctness under expired-token branch) as P1 under runtime-harm taxonomy; Story 2.9 ships P2-uniform matching Stories 2.1–2.8 precedent.

---

### Detailed Mapping

#### AC-1: OAuth flow surfaced to host terminal — `pnpm gh:auth` invokes `gh auth login` inside the container and the OAuth URL is surfaced to the host terminal; completing the flow in a host browser returns control to the CLI (P2)

- **Coverage:** NONE ❌ (deferred to upstream-CLI-owned OAuth endpoint + M4-Pro operator-workstation live flow + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-237 live file + iteration-env stub-docker smokes):**
  - **`packages/devbox/scripts/gh-auth-host.sh` (iter-237 NEW; iter-239 retrofit 82 lines; 0755)**: `#!/usr/bin/env bash` + `set -euo pipefail` + `unset COMPOSE_PROJECT_NAME` (Story 2.6 AI-8/AI-12 + Story 2.7 SC-10 + Story 2.8 SC-8 defensive-posture precedent preserved). `CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"` (Story 2.2 .envrc parameterisation consumed). `SCRIPT_DIR` derived at line 39 for iter-239 `source lib/main-repo-resolver.sh` + `source lib/check-mount-source.sh` retrofits (diverges from Story 2.8 claude-host.sh which has no `SCRIPT_DIR` per SC-4 no-auto-start posture; Story 2.9 adds SCRIPT_DIR for shared-lib sourcing, not for `start.sh` sub-invoke — SC-4 no-auto-start contract preserved unchanged). Banner cites Story 2.9 + AC 1–4 + Story 2.6 `<verb>-host.sh` pattern + Story 2.7 + Story 2.8 inheritance + exit-code contract (including novel exit 12 per iter-239).
  - **Pre-flight 1 — docker daemon reachable**: `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log "docker unreachable — is the daemon running?"; exit 8; }`. Inherits Story 2.7 `ralph-build-host.sh:36` + Story 2.8 `claude-host.sh` tighter variant (catches reachable-but-broken-daemon states; strictly broader than Story 2.6 bare `docker info >/dev/null 2>&1` form).
  - **Pre-flight 2 — container state inspect (SC-4 no-auto-start)**: `state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"`. If `state != "running"` → log `"container 'keel-devbox' is not running — run 'pnpm devbox:start' first"` and exit 9. NO auto-start per SC-4 — auth is a one-off gesture not a loop-entry gesture; operator explicitly runs `pnpm devbox:start` first. Mirrors Story 2.8 posture; contrast Story 2.7's ralph wrappers which DO auto-start.
  - **Pre-flight 3 — bind-mount source matches current main repo (iter-239 retrofit)**: `check_mount_source` sourced from `lib/check-mount-source.sh`; exits 12 on mismatch with a `pnpm devbox:restart` hint. Orthogonal to AC 1 OAuth-flow envelope — defends against worktree-A-then-worktree-B bind-source-stale race; does not affect OAuth URL surface correctness.
  - **Final exec**: `exec docker exec -it --user dev -w "${CONTAINER_WORKDIR}" -e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}" "${CONTAINER_NAME}" gh auth login "$@"`. Interactive-only; hardcoded `-it` (no TTY-detect gate per SC-6 — OAuth flow IS the operator-interactive AC, same posture as Story 2.7 SC-8 `docker attach` wrappers + Story 2.8 SC-6 `claude`). `--user dev` binds to UID 1000 per Story 2.5 hardening substrate (`/home/dev/.config/gh/` inside `keel_home_dev` named volume is dev-owned). `-w "${CONTAINER_WORKDIR}"` post-iter-239 uses parameterised workspace path (was hardcoded `/workspace` at iter-237 landing; both forms resolve to the same container cwd under default `KEEL_DEVBOX_REPO_NAME=ralph-bmad`). `gh auth login` hardcoded as subcommand (SC-9 args-passthrough via `"$@"` scopes to `auth login` only; operators wanting generic `gh` composition use `pnpm devbox:shell` per SC-15-sibling read-only posture).
  - **Iteration-env substrate verification (iter-237)** — Smoke 1: `bash -n packages/devbox/scripts/gh-auth-host.sh` → syntax valid (PASS).
  - **Iteration-env substrate verification (iter-237)** — Smoke 2: `pnpm run 2>&1 | grep -E '^ +gh:auth$'` → 1 match (no namespace pollution; SC-3 pnpm wiring precedence honoured — `gh:auth` entry between `claude` and `prepare`).
  - **Iteration-env substrate verification (iter-237)** — Smoke 3a stub-docker info-fail branch: stub `docker info` returns non-zero → `gh-auth-host.sh` emits `[gh-auth] docker unreachable — is the daemon running?` on stderr + exits 8 (PASS). Stub replaces real docker at PATH head under `<workspace>/.ralph-smoke/shim/` per Story 2.7 iter-223 LESSON (workspace tmpfs noexec forces non-`/tmp/` shim placement).
  - **Iteration-env substrate verification (iter-237)** — Smoke 3b stub-docker not-running branch: stub `docker inspect --format '{{.State.Status}}' keel-devbox` returns empty → `gh-auth-host.sh` emits `[gh-auth] container 'keel-devbox' is not running — run 'pnpm devbox:start' first` on stderr + exits 9 (PASS).
  - **Iteration-env substrate verification (iter-237)** — Smoke 3c stub-docker running branch: stub `docker inspect --format '{{.State.Status}}' keel-devbox` returns `running` → `gh-auth-host.sh` logs `[gh-auth] invoking gh auth login inside keel-devbox (first run: complete OAuth in host browser; token persists at /home/dev/.config/gh/)` → proceeds to `exec docker exec -it --user dev -w /workspace keel-devbox gh auth login` → stub-docker captured verbatim → wrapper exit 0 (PASS).
  - **Iteration-env substrate verification (iter-237)** — Smoke 3d args-passthrough: `gh-auth-host.sh --web` under `STUB_DOCKER_MODE=running` → stub captures `-it --user dev -w /workspace keel-devbox gh auth login --web` — `--web` arg reaches `gh auth login` verbatim via `"$@"` (PASS; SC-9 satisfied).
  - **Iteration-env substrate verification (iter-237)** — Smoke 4 no-TTY-gate: `grep -c 'tty_flag\|-t 0' gh-auth-host.sh` → 0 matches (hardcoded `-it` per SC-6; no TTY-detect code path; OAuth flow IS the AC).
  - **Live-smoke AC 1 runtime verification** (`pnpm gh:auth` → URL + one-time code printed to host terminal → operator follows URL in host browser + pastes code → device-code exchange completes → token written under `/home/dev/.config/gh/hosts.yml`) deferred to M4-Pro operator workstation per § Testing Standards ground-(c) `external-service-owns-behavior-under-test`. Backend B iteration env cannot safely exercise interactive OAuth against GitHub without polluting operator credentials.
  - **Adversarial AC-1 coverage delegated to iter-CR** (Story 2.9 CR opener): Blind Hunter examines pre-flight branches (exit 8 under docker unreachable + exit 9 under container not running + exit 12 under bind-mount mismatch) + final-exec assembly correctness (`exec docker exec -it --user dev -w ${CONTAINER_WORKDIR} -e KEEL_DEVBOX_REPO_NAME=${REPO_NAME} keel-devbox gh auth login "$@"` literal value) + no-auto-start posture (SC-4 pinned; mirrors Story 2.8; contrast Story 2.7 auto-start); Edge Case Hunter probes docker-exec-output-redirection (OAuth URL + one-time code printed to stdout — `-it` preserves TTY on both sides, surface to host terminal; no stdout redirection in wrapper); Acceptance Auditor verifies AC 1 verbatim match — `pnpm gh:auth` → `gh auth login` inside container → OAuth URL + one-time code to host terminal → host browser + code-paste completes flow + returns control to CLI.

---

#### AC-2: Token persisted in named volume — tokens stored at `/home/dev/.config/gh/` inside the Story 2.5 `keel_home_dev` named volume; no host bind-mount involved (P2; Story 2.5 substrate owns persistence per SC-2)

- **Coverage:** NONE ❌ (Story 2.9 ships no-token-inspection wrapper per SC-15; Story 2.5 named-volume substrate owns persistence — SC-2 ground-(c) `external-service-owns-behavior-under-test`; named-volume contract already verified at Story 2.5 iter-188 landing)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Story 2.5 substrate + iter-237 no-wrapper-token-access):**
  - **Story 2.5 substrate (iter-188 landed; UNTOUCHED at Story 2.9 iter-237)**: `packages/devbox/docker-compose.yml` declares `keel_home_dev` named volume mounted at `/home/dev` with `INV-devbox-homedev-named-volume` enforcing non-toggle-able posture. `/home/dev/.config/gh/` inherits the named-volume persistence transitively — token file (`hosts.yml`) lives inside the named volume by construction, not by Story 2.9 wrapper action. Story 2.9 does NOT create, mount, or modify any volume; composition-only on Story 2.5.
  - **`packages/devbox/scripts/gh-auth-host.sh` (iter-237 NEW)**: Wrapper does NOT read, parse, inspect, bind-mount, or surface the token file. Zero `volume` / `mount` / `--mount` / `-v` flags in the final exec line (the iter-239 `-e KEEL_DEVBOX_REPO_NAME=${REPO_NAME}` env-var addition is an env-forward, not a volume mount). Token file format + write location (`hosts.yml` under `/home/dev/.config/gh/`) owned by upstream `gh` CLI (apt-installed; Dockerfile:123-136). SC-15 read-only posture codifies the no-wrapper-token-access discipline (mirrors Story 2.8 SC-15 Claude-token-opacity).
  - **Iteration-env substrate verification (iter-237)** — `grep -c 'volume\|mount\|\-v ' packages/devbox/scripts/gh-auth-host.sh` → 0 matches (verified post-iter-239: `-v ` as a bind-mount flag is absent; the iter-239 env-var `-e ` is orthogonal). `grep -c '\.config/gh' packages/devbox/scripts/gh-auth-host.sh` → reference only in the info-log literal (`token persists at /home/dev/.config/gh/`), not in any exec argument.
  - **SC-12 scope carve-out (iter-235 pinned + iter-237 implementation-confirmed)**: Story 2.9 does NOT modify `packages/devbox/docker-compose.yml`. The stale `# TODO(Story 2.8 / 2.9): named-volume mounts for OAuth tokens.` at compose:156 is intentionally left in place per SC-12 — Story 2.5 compose named-volume already subsumes the token-mount requirement for both Claude (`/home/dev/.claude/`) + `gh` (`/home/dev/.config/gh/`) token paths; TODO is self-documenting across Stories 2.8 + 2.9.
  - **Live-smoke AC 2 runtime verification** (`pnpm gh:auth` → OAuth completes → `docker exec keel-devbox ls -la /home/dev/.config/gh/` shows `hosts.yml` token file owned by UID 1000 inside `keel_home_dev` named volume; `docker inspect --format '{{json .Mounts}}' keel-devbox | jq` confirms `/home/dev` mount source is the named volume NOT a bind-mount path) deferred to M4-Pro operator workstation per § Testing Standards ground-(c) + Story 2.5 iter-187 + Story 2.8 iter-230 precedent cluster.
  - **Adversarial AC-2 coverage delegated to iter-CR**: Blind Hunter verifies the wrapper has zero path traversal or token-handling logic (SC-15 read-only posture holds; upstream `gh` CLI owns the token write); Edge Case Hunter probes the Story 2.5 named-volume contract durability (operator explicit `-v /path:/home/dev` override at docker run time would bypass the volume — not reachable via `pnpm gh:auth` surface per Story 2.6 wrapping; operator can only drop to raw `docker run` deliberately, which is FR1 non-toggle-able invariant violation anyway); Acceptance Auditor verifies AC 2 verbatim match — tokens at `/home/dev/.config/gh/` + no host bind-mount involved.

---

#### AC-3: Token survives restart — `pnpm devbox:restart` or `pnpm devbox:stop && start` preserves token; Ralph's subsequent `gh pr view` / `git push` reuses existing token (no re-auth) (P2; Docker named-volume substrate + upstream CLI own behavior per SC-2)

- **Coverage:** NONE ❌ (Story 2.9 wrapper is stateless; Docker named-volume + upstream `gh` CLI token-reuse logic own behavior — SC-2 ground-(c) `external-service-owns-behavior-under-test`; Docker named-volume persistence already verified at Story 2.5 substrate landing)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Story 2.5 named-volume + Story 2.6 restart primitives + upstream CLI token-reuse):**
  - **Story 2.5 substrate (iter-188 landed; UNTOUCHED at Story 2.9 iter-237)**: `keel_home_dev` named volume survives container restart by Docker semantics — `docker compose down` without `--volumes` flag does NOT delete named volumes; `docker compose up -d` on an existing volume mounts the same volume. Story 2.6 `pnpm devbox:restart` + `pnpm devbox:stop && start` are the canonical restart primitives and are named-volume-safe by Story 2.6 SC default + Story 2.5 `INV-devbox-homedev-named-volume`. Token-survival is a property of the Docker named-volume substrate, NOT of Story 2.9's wrapper. Mirrors Story 2.8 AC-3 inheritance exactly.
  - **`packages/devbox/scripts/gh-auth-host.sh` (iter-237 NEW)**: Wrapper is stateless — re-invocation after restart hits the same pre-flight branches + final exec line against the same `${CONTAINER_NAME}` container. There is no wrapper-side state cache; `gh` reads its token from the mounted named volume on every invocation. Idempotent by construction.
  - **Upstream `gh` CLI semantics** (apt-installed at Dockerfile:123-136; Renovate `apt` manager-tracked per Story 1.15): On invocation, `gh` checks `/home/dev/.config/gh/hosts.yml` for an existing token; valid token → skip OAuth, proceed silently; missing or expired token → return auth-required error or trigger re-auth flow (AC 4 path). This is upstream GitHub-owned behavior — Story 2.9 does NOT duplicate, proxy, or inspect it. Renovate `apt` manager-tracking protects against upstream breaking changes until substrate-controlled bump.
  - **Ralph usage-path semantics (AC-3-specific)**: AC 3 specifically references `gh pr view` and `git push` (not `gh auth login`). These are the Ralph pre-push gate + PR-monitoring usage paths (Epic 3 Story 3.7 consumer). Token-reuse-across-restart for these paths is a transitive property of (i) `gh` reading `~/.config/gh/hosts.yml` on invocation, (ii) `hosts.yml` living in the `keel_home_dev` named volume per AC 2, (iii) named volume surviving `pnpm devbox:restart` per Story 2.5 + 2.6 substrate. Story 2.9 wrapper is NOT on the `gh pr view` / `git push` path — those paths are Epic 3 Story 3.7 scope (Ralph's in-container tooling) which consumes the persisted token without any new wrapping.
  - **Live-smoke AC 3 runtime verification** (sequence `pnpm gh:auth` first run OAuth completes → `pnpm devbox:restart` → `docker exec keel-devbox gh pr view <N>` second invocation → `gh` proceeds silently; no OAuth re-trigger; existing token reused) deferred to M4-Pro operator workstation per § Testing Standards ground-(c). Requires live GitHub endpoint for initial seed; subsequent restart-survival check is a filesystem-persistence assertion against Docker named-volume semantics (Story 2.5 substrate; not re-verified at Story 2.9 scope).
  - **Adversarial AC-3 coverage delegated to iter-CR**: Blind Hunter verifies the wrapper adds no re-auth-forcing logic (no `rm /home/dev/.config/gh/*` or `--clear-token` flag injection); Edge Case Hunter probes concurrent-invocation (two operators run `pnpm gh:auth` on the same devbox simultaneously — upstream `gh` CLI owns the file-locking contract; Story 2.9 wrapper does not serialise), token-file-corruption (upstream `gh` owns recovery — AC 4 re-auth-pointer path activates); Acceptance Auditor verifies AC 3 verbatim match — restart preserves token + subsequent `gh pr view` / `git push` invocation reuses it.

---

#### AC-4: Expired/revoked token surfaces clear pointer + Ralph pre-push gate halt-able — `gh` invocations under expired/revoked token surface clear pointer to re-run `pnpm gh:auth`; Ralph's pre-push gate (Epic 3) treats this as a halt-able condition rather than silently retrying (P2 — two-element AC combining Story 2.8's AC-4 re-auth + pinning Epic 3 Story 3.7 consumer contract; upstream CLI + GitHub endpoint + Epic 3 consumer own behavior per SC-2)

- **Coverage:** NONE ❌ (Story 2.9 wrapper is re-auth-transparent; upstream `gh` CLI + GitHub endpoint own expiry detection; Epic 3 Story 3.7 owns halt-write implementation — SC-2 ground-(c) `external-service-owns-behavior-under-test`; documentation substrate pointer added per Task 3 + Task 4; Epic-3-scope halt-contract pinned per `INV-ralph-halt-reason-enum` `CI_BLOCKED`)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-237 README + AGENTS.md re-auth pointers + wrapper idempotence + Epic-3-contract pin):**
  - **`packages/devbox/README.md` (iter-237 MODIFIED)**: New `## gh CLI authentication (Story 2.9)` H2 sibling section (between Story 2.8 Claude H2 and `## cc-devbox upstream provenance` H2) documents the re-auth path operator-facing — quick-start + OAuth flow + args-composition recipes + re-auth pointer + pre-push-gate halt-able cross-ref to Epic 3 Story 3.7. Operator comprehension covered. 67 lines added.
  - **`AGENTS.md` (iter-237 MODIFIED)**: New `### gh CLI authentication (Story 2.9)` H3 sibling section (between Story 2.8 Claude H3 and top-level `## Ralph loop`) under § Devbox iteration environment documents the agent-facing re-auth pointer — `Re-auth pointer:` bullet: "if Ralph's `gh push` / `gh pr view` / `gh pr checks` tooling reports a gh auth failure, queue `pnpm gh:auth` as a fix task (operator-interactive). Agents SHOULD NOT attempt automated re-auth — OAuth requires a host browser." Agent contract codified. 11 lines added.
  - **`packages/devbox/scripts/gh-auth-host.sh` (iter-237 NEW)**: Re-auth flows through the SAME pre-flight branches + same final exec line as initial auth — wrapper is idempotent. Upstream `gh` CLI detects expired/revoked token and surfaces auth-required error (or re-triggers OAuth under `gh auth login` invocation); wrapper surfaces the URL + code to operator terminal identically to AC 1. No separate re-auth code path needed.
  - **Upstream `gh` CLI semantics** (apt-installed): Token expiry + revocation detection + auth-required error messaging + re-OAuth-trigger logic (under explicit `gh auth login` re-invocation) owned by upstream. Clear error message surfacing is upstream behavior; Story 2.9 wrapper neither catches nor massages `gh`'s stderr. SC-15 read-only posture.
  - **Epic 3 Story 3.7 halt-write consumer contract (Story 2.9 pins; Epic 3 implements)**: AC 4 second element "Ralph's pre-push gate (Epic 3) treats this as a halt-able condition rather than silently retrying" pins the `CI_BLOCKED` halt-reason contract per `INV-ralph-halt-reason-enum` closed halt-reason enum (PRD FR14k; `docs/invariants/ralph-execute.md` § Halt schema). When Ralph's pre-push gate (Story 3.7) detects an auth-broken gh invocation, it writes halt sentinel `{"reason":"CI_BLOCKED","note":"gh not authed — run 'pnpm gh:auth'"}`. Agents inheriting Epic 3 scope MUST NOT retry the push silently or invent a new halt reason (§ Halt § Autonomy guardrail applies). Story 2.9 pins the contract verbatim in `AGENTS.md § gh CLI authentication (Story 2.9)` bullet "Ralph pre-push gate halt-able (Epic 3 scope)"; Epic 3 Story 3.7 implements the halt-write. Invariant `INV-ralph-halt-reason-enum` consumed-not-modified at Story 2.9.
  - **Egress substrate (Story 2.3/2.4 whitelist unchanged)**: `packages/devbox/whitelist/github.txt` contains 7 entries covering all GitHub OAuth + API + raw-content + LFS / release + GHCR + package-container paths — `api.github.com`, `github.com`, `raw.githubusercontent.com`, `objects.githubusercontent.com`, `codeload.github.com`, `ghcr.io`, `pkg-containers.githubusercontent.com`. Story 2.9 does NOT modify whitelist fragments (SC-12-parallel; re-auth traffic flows through unchanged egress contract).
  - **Live-smoke AC 4 runtime verification** (sequence `pnpm gh:auth` OAuth completes → artificially expire/revoke token via GitHub UI OR wait for real expiry → `docker exec keel-devbox gh pr view <N>` → `gh` detects expiration, prints re-auth pointer, operator re-runs `pnpm gh:auth` to refresh) deferred to M4-Pro operator workstation per § Testing Standards ground-(c). Requires live GitHub endpoint + real token lifecycle.
  - **Live-smoke AC 4 Ralph halt-write branch** requires Epic 3 Story 3.7 shipped (not yet scoped; substrate-contract-only at Story 2.9). Smoke at Epic 3 landing: Ralph pre-push gate invocation against expired-token devbox → expects `CI_BLOCKED` halt sentinel with `"note":"gh not authed — run 'pnpm gh:auth'"` at `$RALPH_BASE_DIR/halt`; ralph.py reads halt + stops loop.
  - **Adversarial AC-4 coverage delegated to iter-CR**: Blind Hunter verifies the wrapper does not suppress or mangle `gh`'s stderr (no `2>/dev/null` or stderr redirection on the final exec); Edge Case Hunter probes partial-expiry (refresh-token valid + access-token expired — upstream `gh` owns refresh-flow; Story 2.9 transparent), revocation-from-github-side (upstream reports 401 + prompts re-auth; same surfaced-URL flow as AC 1), Epic-3-halt-contract wording (`CI_BLOCKED` reason is in closed enum; `note` field is free-form but agents MUST NOT invent new halt reasons per § Halt § Autonomy guardrail); Acceptance Auditor verifies AC 4 two-element match — expired/revoked token → clear re-auth pointer to `pnpm gh:auth` + Epic 3 pre-push gate halts rather than silent-retries.

---

## PHASE 2: GATE DECISION

### Decision: **WAIVED** ✅

**Rationale:**

Story 2.9 is the NINETEENTH cumulative Epic-story trace-WAIVED invocation (extending the 18-precedent stack: 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14/1.15/1.16 → 2.1 → 2.2 → 2.3 → 2.4 → 2.5 → 2.6 → 2.7 → 2.8 → 2.9) and the TWENTIETH ATDD-skip-trace-WAIVED pairing overall. The deterministic gate logic would compute FAIL (overall 0% < 80%; P2 coverage 0%) — but this is a structural false-positive because no test runner is wired at Story 2.9 substrate stage. Story 2.9 § Testing Standards affirmatively declares trace-WAIVED via:

1. **Ground (a) — substrate-verification covers AC 1 invocation envelope at iteration-env-safe layer.** Task 5 iteration-env-safe smokes exercised (iter-237): bash -n × 1 script (syntax valid); pnpm wiring count 1 (`gh:auth` between `claude` and `prepare`); stub-docker info-fail branch → exit 8 + stderr `[gh-auth] docker unreachable — is the daemon running?`; stub-docker not-running branch → exit 9 + stderr `[gh-auth] container 'keel-devbox' is not running — run 'pnpm devbox:start' first`; stub-docker running branch → final exec `-it --user dev -w /workspace keel-devbox gh auth login` captured verbatim → wrapper exit 0; args-passthrough `gh-auth-host.sh --web` → stub captures `--web` arg verbatim; no-TTY-gate `grep -c 'tty_flag\|-t 0' gh-auth-host.sh` → 0 matches. 1/4 ACs (AC 1 invocation envelope) substrate-smoked at shell level; 3/4 ACs upstream-CLI + Docker-substrate + Epic-3-consumer-deferred.

2. **Ground (b) — no test runner wired at substrate level.** Recursive probe for vitest.config.*/jest.config.*/playwright.config.*/cypress.config.*/pyproject.toml/go.mod/Gemfile/Cargo.toml/csproj returns zero matches at iter-242. Epic 13 is the formal test-framework landing per PRD RS6. Bare "no runner" is insufficient per Story 1.8 guardrail — it combines with ground (a) and ground (c).

3. **Ground (c) VARIANT — `external-service-owns-behavior-under-test` for AC 1 / AC 2 / AC 3 / AC 4.** All four ACs reference behaviors owned by: (i) upstream `gh` CLI (apt-installed; Dockerfile:123-136; Renovate `apt` manager-tracked per Story 1.15) for OAuth URL + one-time-code surfacing + token file write/read + token refresh logic; (ii) GitHub's OAuth endpoint (external service; Story 2.3/2.4 egress substrate already whitelists 7 domains per `packages/devbox/whitelist/github.txt`); (iii) Docker named-volume persistence substrate (Story 2.5 `keel_home_dev` + `INV-devbox-homedev-named-volume`; already verified at Story 2.5 landing — not re-verified at Story 2.9 scope); (iv) Epic 3 Story 3.7 pre-push-gate halt-write consumer (`INV-ralph-halt-reason-enum` closed halt-reason `CI_BLOCKED`; Story 2.9 pins contract in AGENTS.md + story file, Epic 3 Story 3.7 implements the halt-write). Story 2.9's wrapper can ONLY verify: (α) invocation envelope is correctly assembled; (β) pre-flight guards emit correct exit codes (8/9/12); (γ) args-passthrough works (scoped to `gh auth login`); (δ) no wrapper-side token inspection/caching (SC-15). Full AC verification requires: live `gh` CLI reaching GitHub's OAuth endpoint + host browser for URL + code-paste completion + real GitHub account + M4-Pro native Docker Desktop for reliable `docker exec -it` TTY + stdin_open under cap-dropped containers + Epic 3 Story 3.7 shipped for halt-write branch. This is 1:1 mechanical inheritance from Story 2.8's ground-(c) variant with GitHub-for-Anthropic substitution; AC 4 two-element structure (re-auth pointer + Ralph halt-able) compresses Story 2.8's AC 4 (re-auth) + AC 5 (volume-delete) into a single AC that also pins the Epic 3 Story 3.7 consumer contract.

4. **Hybrid variant-(iii) spec-declared-CR-substitution.** Story 2.9 § Dev-agent guardrails + 17 pinned scope-clarifications (SC-1 through SC-17) + forthcoming `/bmad-code-review (args: "2")` adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.9 substrate diff: 1 new script + 3 modified files; forecast 0 PATCH opener + 0 closure re-run per Story 2.7 iter-226 + Story 2.8 iter-233 ONE-PASS ZERO-PATCH cumulative precedent — Story 2.9 is FOURTH one-pass ZERO-PATCH candidate given narrowest novel surface in Epic 2 to date) substitute for red-phase scaffolds.

### Gate Criteria

- **P0 Coverage:** 0/0 = 100% ✅ (MET — no P0 requirements)
- **P1 Coverage:** 0/0 = 100% ✅ (MET — no P1 requirements)
- **P2 Coverage:** 0/4 = 0% ❌ (NOT_MET by deterministic rule; WAIVED per § Testing Standards declaration)
- **Overall Coverage:** 0% ❌ (NOT_MET by deterministic rule; WAIVED per § Testing Standards declaration)

### Critical Gaps

0 — No P0 or P1 requirements to cover.

### Uncovered Requirements (gate-deferred)

- AC-1 (P2): OAuth flow surfaced to host terminal. Substrate: gh-auth-host.sh pre-flight branches (exit 8 / exit 9 / exit 12) + final exec (`-it --user dev -w ${CONTAINER_WORKDIR} -e KEEL_DEVBOX_REPO_NAME=${REPO_NAME} keel-devbox gh auth login "$@"`); smokes 1/2/3a/3b/3c/3d/4 all green. Deferred: live `gh` CLI → GitHub OAuth endpoint → host browser + code-paste flow to M4-Pro operator workstation.
- AC-2 (P2): Token persisted in named volume. Substrate: Story 2.5 `keel_home_dev` named volume (verified at Story 2.5 iter-188 landing) + wrapper SC-15 no-token-inspection posture; no bind-mount flags in final exec. Deferred: live filesystem inspection post-OAuth to operator workstation.
- AC-3 (P2): Token survives restart. Substrate: Docker named-volume survival-across-compose-restart semantics (Story 2.5) + wrapper idempotence + Ralph-path transitivity (Epic 3 Story 3.7 consumer of persisted token). Deferred: live OAuth seed + `pnpm devbox:restart` + silent second `gh pr view` invocation to operator workstation.
- AC-4 (P2): Expired/revoked token surfaces clear pointer + Ralph pre-push gate halt-able. Substrate: README H2 + AGENTS.md H3 re-auth pointers (iter-237) + wrapper transparency to upstream CLI stderr + `INV-ralph-halt-reason-enum` `CI_BLOCKED` contract pinned. Deferred: live expired/revoked token + re-auth pointer surfacing to operator workstation; Epic 3 Story 3.7 shipping for halt-write branch.

---

## Recommendations

1. **MEDIUM — Accept WAIVED posture.** Four P2 ACs covering an Epic-2-ships-envelope-upstream-CLI-ships-runtime class story (SECOND instance; first was Story 2.8 Claude OAuth). NINETEENTH cumulative trace-WAIVED; TWENTIETH ATDD-skip-trace-WAIVED co-application pairing. 1/4 ACs (AC 1 invocation envelope) substrate-smoked at shell level; 3/4 ACs (AC 2 token-volume / AC 3 restart-survival / AC 4 re-auth-pointer + Ralph halt-able) upstream-CLI + Docker-substrate + Epic-3-consumer-deferred under SC-2 ground-(c) `external-service-owns-behavior-under-test`.
2. **MEDIUM — Story 2.9 authors 1 NEW host-side bash shim + 3 modified files per SC-17 scope boundary.** Substrate contracts preserved verbatim (Story 2.1 Dockerfile + entrypoint.sh + CMD[sleep,infinity] + Story 2.2 .envrc + Story 2.3 egress whitelist — all 7 `whitelist/github.txt` entries unchanged + Story 2.4 whitelist + Story 2.5 hardening + named-volume LOAD-BEARING for AC 2/3 + Story 2.6 13-verb surface + shell.sh/attach.sh interactive-exec pattern composed + Story 2.7 2-verb ralph surface + Story 2.8 claude-host.sh template mirrored 1:1 with `gh`-for-claude substitution + Story 1.12 theme.py orthogonal). No new invariants.manifest.ts entries. Sync-gate GREEN. `INV-ralph-halt-reason-enum` consumed-not-modified (AC 4 Epic-3 consumer contract pin).
3. **MEDIUM — Per-AC live-OAuth-flow verification unlocks at M4-Pro operator workstation backend-A.** AC 1/2/3/4 material verification requires live `gh` CLI reaching GitHub's OAuth endpoint (7 whitelisted domains) + host browser + real GitHub account. No Story 2.9 code change required at any live-flow verification point — wrapper is stateless; upstream `gh` CLI + Docker named-volume substrate + Epic 3 Story 3.7 (halt-write branch) own all four behaviors. Downstream consumer signal: Epic 3 Story 3.7 ships the Ralph pre-push gate halt-write consumer against expired-token devbox (`CI_BLOCKED` halt reason + operator-education note); Story 2.9 pins the contract; Epic 3 implements.
4. **LOW — Run /bmad-testarch-test-review.** No tests exist — no-op; recorded for parity with downstream pipelines.

---

## Display Summary

```
🚨 GATE DECISION: WAIVED

📊 Coverage Analysis:
- P0 Coverage: 100% (0/0; no P0 requirements) → MET
- P1 Coverage: 100% (0/0; no P1 requirements) → MET
- P2 Coverage: 0% (0/4) → NOT_MET (deterministic) → WAIVED per § Testing Standards
- Overall Coverage: 0% (0/4) → NOT_MET (deterministic) → WAIVED

✅ Decision Rationale:
NINETEENTH cumulative trace-WAIVED precedent — SECOND Epic-2-ships-envelope-upstream-CLI-
ships-runtime class; ground-(c) variant `external-service-owns-behavior-under-test` for AC
1–4 (upstream apt-installed `gh` CLI + GitHub OAuth endpoint + Story 2.5 Docker named-volume
substrate + Epic 3 Story 3.7 halt-write consumer own the behaviors). 1/4 ACs substrate-smoked
(AC 1 invocation envelope: 7 smokes green); 3/4 ACs upstream-CLI + Docker-substrate +
Epic-3-consumer-deferred (AC 2 token-volume; AC 3 restart-survival; AC 4 re-auth-pointer +
Ralph halt-able). Iteration-env-safe smokes ALL PASSED at iter-237 (7 smokes over 1 script —
matching Story 2.8 per-script density at 7.0/script).

⚠️ Critical Gaps: 0

📝 Recommended Actions (top 3):
1. Accept WAIVED; 19th cumulative / 20th pairing
2. Story 2.9 scope: 1 script + 3 modified files; substrate contracts preserved
3. M4-Pro operator workstation unlocks AC 1–4 live-OAuth material verification; Epic 3
   Story 3.7 ships halt-write branch for AC 4 second-element consumer contract

📂 Full Report: _bmad-output/test-artifacts/traceability/2-9-gh-cli-oauth-via-pnpm-gh-auth.md
📂 Coverage Matrix: _bmad-output/test-artifacts/traceability/2-9-coverage-matrix.json
📂 E2E Trace Summary: _bmad-output/test-artifacts/traceability/2-9-e2e-trace-summary.json
📂 Gate Decision: _bmad-output/test-artifacts/traceability/2-9-gate-decision.json
```
