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
    '_bmad-output/implementation-artifacts/2-8-claude-code-oauth-via-pnpm-claude.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    'INVARIANTS.md',
    'AGENTS.md',
    'CLAUDE.md',
    'RALPH.md',
    'packages/devbox/README.md',
    'packages/devbox/scripts/claude-host.sh',
    'package.json',
    '_bmad-output/test-artifacts/traceability/2-7-gate-decision.json',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/2-8-claude-code-oauth-via-pnpm-claude.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/2-8-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 2.8 Claude Code OAuth via `pnpm claude`

**Target:** Story 2.8 — Epic-2-ships-envelope-upstream-CLI-ships-runtime class story delivering 1 host-side bash shim (`packages/devbox/scripts/claude-host.sh`) that pre-flights docker reachability (AC 1 exit 8 branch) + container liveness (AC 1 exit 9 branch per SC-4 no-auto-start), then `exec docker exec -it --user dev -w /workspace keel-devbox claude "$@"` so upstream `@anthropic-ai/claude-code@2.1.116` surfaces its OAuth URL on the operator terminal (AC 1) and writes the resulting token under `/home/dev/.claude/` inside the Story 2.5 `keel_home_dev` named volume (AC 2), where it survives `pnpm devbox:restart` (AC 3) until the upstream CLI detects expiry and re-triggers OAuth (AC 4) or `pnpm devbox:clean --with-volumes` wipes the named volume (AC 5). SC-2 pins the upstream-CLI scope carve-out: Story 2.8 ships the invocation envelope; upstream `@anthropic-ai/claude-code@2.1.116` + Anthropic's OAuth endpoint + Docker named-volume substrate (Story 2.5) own all five AC behaviors. Five ACs delivered iter-230 via `/bmad-dev-story` single-iteration landing (6 Tasks / 30 subtasks all green; 1 NEW script + 3 modified files exactly matching the iter-228 pre-dev SM-reviewed v1.1 post-PATCH forecast — ZERO-DRIFT implementation). Story State `in-dev` at iter-231 trace entry — iter-230 `/bmad-dev-story` completed AC 1–AC 5 end-to-end at substrate level + ITERATION-ENV-SAFE SMOKES ALL PASSED (bash -n × 1; pnpm wiring count 1; stub-docker info-fail → exit 8 + log; stub-docker not-running → exit 9 + log; stub-docker running → final exec args `-it --user dev -w /workspace keel-devbox claude` captured + exit 0; args-passthrough `claude-host.sh --version` → stub captures `--version` arg verbatim; no-TTY-gate grep → 0 matches). Live OAuth-flow smokes (AC 1 URL surface + AC 2 token file write + AC 3 restart-survival + AC 4 re-auth-on-expiry + AC 5 volume-delete-clears) are **backend-A-only operator-workstation-deferred** per SC-17 (Anthropic OAuth endpoint + upstream CLI + Docker substrate own the behaviors; DinD-B iteration env cannot safely exercise interactive OAuth against Anthropic without polluting operator credentials; Story 2.5 iter-187 + Story 2.6 iter-201/204/216/219 + Story 2.7 iter-223 precedent cluster inherited). Canonical `pnpm claude` usage recipes pinned in `packages/devbox/README.md § Claude Code authentication (Story 2.8)` for the operator first-run + re-auth + volume-delete paths.

**Date:** 2026-04-22
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 2.8 § Acceptance Criteria AC 1–5)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/2-8-claude-code-oauth-via-pnpm-claude.md` (AC 1–AC 5)

---

Note: This workflow does not generate tests. Story 2.8 is an **Epic-2-ships-envelope-upstream-CLI-ships-runtime class substrate** story (FIRST of its class — distinct from Story 2.1 upstream-absorb, Story 2.2 envrc-parameterisation, Story 2.3 daemon+kernel-rule infrastructure-security, Story 2.4 in-container CLI, Story 2.5 architecture-security/container-hardening, Story 2.6 user-facing-CLI 13-verb host-side surface, Story 2.7 Epic-2-envelope-Epic-3-runtime; operates at the operator-terminal → `docker exec -it` boundary delegating five distinct ACs to `@anthropic-ai/claude-code@2.1.116` upstream CLI + Anthropic OAuth endpoint + Story 2.5 Docker named-volume substrate). Story 2.8 § Testing Standards + 17 pinned scope clarifications + v1.3 iter-230 dev-story landing Change Log row explicitly defer AC 1–AC 5 live-OAuth smokes to M4-Pro operator workstation per SC-17 + Story 2.5 SC-13 + Story 2.6 SC-13 + Story 2.7 SC-17 backend-B-deferred-live-smoke precedent. Rationale applies the FR14n ATDD-skip clause already invoked at iter-229 via hybrid ground-(a)-(b)-(c) variant-(iii) + NEW ground-(c) variant `external-service-owns-behavior-under-test`:

> _"EIGHTEENTH cumulative Epic ATDD-skip precedent (Stories 1.7 iter-14 + 1.8 iter-29 + 1.9 iter-36 + 1.10 iter-43 + 1.11 iter-50 + 1.12 iter-57 + 1.13 iter-64 + 1.14 iter-71 + 1.15 iter-83 + 1.16 iter-90 + 2.1 iter-98 + 2.2 iter-147 + 2.3 iter-157 + 2.4 iter-173 + 2.5 iter-186 + 2.6 iter-200 + 2.7 iter-222 → 2.8 iter-229) — **eighth Epic 2 ATDD-skip** + **first Epic-2-ships-envelope-upstream-CLI-ships-runtime class ATDD-skip**. `/bmad-testarch-atdd` skill NOT invoked — preflight would HALT at Step 1.2 (zero-test-runner substrate: no vitest.config.\*/jest.config.\*/playwright.config.\*/cypress.config.\* anywhere in tree; TEA test_framework: auto autodetects nothing; Epic 13 is the formal test-framework landing per PRD RS6). Rationale — ground (c) hybrid variant-(iii) + NEW ground-(c) variant `external-service-owns-behavior-under-test`: (iii) spec-declared adversarial coverage substitution — § Dev-agent guardrails + 17 pinned scope-clarifications (SC-1 through SC-17 covering FR1 non-toggle-able invariant extension to 16-verb total surface + SC-2 upstream Claude Code CLI + Anthropic OAuth endpoint own auth-flow semantics + SC-3 pnpm wiring precedence + SC-4 no-auto-start fail-closed exit 9 + SC-6 hardcoded-`-it` no-TTY-detect-gate + SC-9 `\"$@\"` args-passthrough + SC-12 no compose edits + SC-14 host-side-shim accounting + SC-15 wrapper does NOT inspect/parse token file + SC-17 read-only posture on Story 2.6/2.7 README + AGENTS.md sections) + forthcoming /bmad-code-review (args: \"2\") adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.8 substrate diff: 1 new script + 3 modified files — forecast 1–3 PATCH opener + 0 closure re-run per Story 2.7 iter-226 ONE-PASS ZERO-PATCH precedent; Story 2.8 is SECOND one-pass ZERO-PATCH candidate given narrower novel surface); NEW ground-(c) variant `external-service-owns-behavior-under-test` for AC 1/2/3/4/5 — AC 1's `OAuth URL surfaced to my host terminal` + AC 2's `tokens stored at /home/dev/.claude/` + AC 3's `token reused across restart` + AC 4's `re-auth on expiry` + AC 5's `tokens gone after volume-delete` all reference behaviors owned by (i) upstream `@anthropic-ai/claude-code@2.1.116` CLI (Anthropic-owned; baked at Dockerfile:119) + (ii) Anthropic's OAuth endpoint (external service at api.anthropic.com + console.anthropic.com; Story 2.3/2.4 egress substrate whitelists) + (iii) Docker named-volume persistence (Story 2.5 `keel_home_dev` + `INV-devbox-homedev-named-volume` already verified — not re-verified at Story 2.8 scope); full verification unlocks at M4-Pro operator workstation backend-A live OAuth flow. This is the natural extension of Story 2.7's `downstream-epic-owns-behavior-under-test` (Epic-3-scope) with a sibling for upstream-CLI + external-endpoint-scope auth-flow class (Story 2.8 Claude + Story 2.9 gh forecast inheritance)."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-229, per the hybrid ground-(a)-(b)-(c) variant-(iii) + NEW ground-(c) variant `external-service-owns-behavior-under-test` rationale pinned in `.ralph/@plan.md § Context`. **EIGHTEENTH cumulative trace-WAIVED precedent** — eighth Epic 2 trace-WAIVED and first **Epic-2-ships-envelope-upstream-CLI-ships-runtime class** trace-WAIVED. Under the ATDD-skip-trace-WAIVED co-application rule, this is the **NINETEENTH pairing** overall (10 Epic-1 pairings + 2.1 + 2.2 + 2.3 + 2.4 + 2.5 + 2.6 + 2.7 + 2.8).

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

All five ACs are **Epic-2-ships-envelope-upstream-CLI-ships-runtime substrate** assertions over the Story 2.8 deliverables. Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` consistent with Stories 2.1–2.7 precedent (no P0 auth/payment/data-loss at substrate — the OAuth flow IS the auth, but AC-class here is "wrapper invocation envelope" not "credential-storage mechanism"; no P1 primary user journey — upstream CLI delivers the primary OAuth UX; Story 2.8 ships the host-side invocation path envelope). Downstream test-runner landing may retro-classify AC 1 (docker exec TTY + stdin_open reliability) or AC 2 (named-volume persistence under operator volume overrides) as P1 under runtime-harm taxonomy; Story 2.8 ships P2-uniform matching Stories 2.1–2.7 precedent.

---

### Detailed Mapping

#### AC-1: OAuth flow surfaced to host terminal — `pnpm claude` invokes `claude` inside the container and the OAuth URL is surfaced to the host terminal; following the URL in a host browser completes the flow (P2)

- **Coverage:** NONE ❌ (deferred to upstream-CLI-owned OAuth endpoint + M4-Pro operator-workstation live flow + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-230 live file + iteration-env stub-docker smokes):**
  - **`packages/devbox/scripts/claude-host.sh` (iter-230 NEW; 54 lines; 0755)**: `#!/usr/bin/env bash` + `set -euo pipefail` + `unset COMPOSE_PROJECT_NAME` (Story 2.6 AI-8/AI-12 + Story 2.7 SC-10 defensive-posture precedent preserved). `CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"` (Story 2.2 .envrc parameterisation consumed). No `SCRIPT_DIR` variable per v1.1 PATCH 2 (SC-4 no-auto-start → no `start.sh` sub-invoke → SCRIPT_DIR would be dead code; contrast Story 2.7 ralph-*-host.sh:29+46 which DOES use SCRIPT_DIR for the sub-invoke). Banner cites Story 2.8 + AC 1–5 + Story 2.6 `<verb>-host.sh` pattern + Story 2.7 ralph-build-host.sh interactive-exec precedent + exit-code contract.
  - **Pre-flight 1 — docker daemon reachable**: `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log "docker unreachable — is the daemon running?"; exit 8; }`. Inherits Story 2.7 `ralph-build-host.sh:36` tighter variant per v1.1 PATCH 1 (catches reachable-but-broken-daemon states; strictly broader than Story 2.6 bare `docker info >/dev/null 2>&1` form).
  - **Pre-flight 2 — container state inspect (SC-4 no-auto-start)**: `state="$(docker inspect --format '{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || true)"`. If `state != "running"` → log `"container 'keel-devbox' is not running — run 'pnpm devbox:start' first"` and exit 9. NO auto-start per SC-4 — auth is a one-off gesture not a loop-entry gesture; operator explicitly runs `pnpm devbox:start` first. Contrast Story 2.7's ralph wrappers which DO auto-start (SC-4 explicit deviation from Story 2.7 posture).
  - **Final exec**: `exec docker exec -it --user dev -w /workspace "${CONTAINER_NAME}" claude "$@"`. Interactive-only; hardcoded `-it` (no TTY-detect gate per SC-6 — OAuth flow IS the operator-interactive AC, same posture as Story 2.7 SC-8 `docker attach` wrappers). `--user dev` binds to UID 1000 per Story 2.5 hardening substrate (`/home/dev/.claude/` inside `keel_home_dev` named volume is dev-owned). `-w /workspace` aligns with Story 2.6 shell.sh/attach.sh cwd convention. Args-passthrough via `"$@"` per SC-9 enables `pnpm claude --version` + `pnpm claude -p "…"` composition.
  - **Iteration-env substrate verification (iter-230)** — Smoke 3a stub-docker info-fail branch: stub `docker info` returns non-zero → `claude-host.sh` emits `[claude] docker unreachable — is the daemon running?` on stderr + exits 8 (PASS). Stub replaces real docker at PATH head under `<workspace>/.ralph-smoke/shim/` per Story 2.7 iter-223 LESSON (workspace tmpfs noexec forces non-`/tmp/` shim placement).
  - **Iteration-env substrate verification (iter-230)** — Smoke 3c stub-docker running branch: stub `docker inspect --format '{{.State.Status}}' keel-devbox` returns `running` → `claude-host.sh` logs `[claude] invoking claude inside keel-devbox (first run: complete OAuth in host browser; token persists at /home/dev/.claude/)` → proceeds to `exec docker exec -it --user dev -w /workspace keel-devbox claude` → stub-docker captured verbatim (after the leading `exec` verb consumed by the stub) → wrapper exit 0 (PASS).
  - **Iteration-env substrate verification (iter-230)** — Smoke 3d args-passthrough: `claude-host.sh --version` under `STUB_DOCKER_MODE=running` → stub captures `-it --user dev -w /workspace keel-devbox claude --version` — `--version` arg reaches claude verbatim via `"$@"` (PASS; SC-9 satisfied).
  - **Iteration-env substrate verification (iter-230)** — bash -n syntax parse PASS (Smoke 1).
  - **Live-smoke AC 1 runtime verification** (`pnpm claude` → URL printed to host terminal → operator follows URL in host browser → device-code exchange completes → token written under `/home/dev/.claude/`) deferred to M4-Pro operator workstation per § Testing Standards ground-(c) `external-service-owns-behavior-under-test`. Backend B iteration env cannot safely exercise interactive OAuth against Anthropic without polluting operator credentials.
  - **Adversarial AC-1 coverage delegated to iter-CR** (Story 2.8 CR opener): Blind Hunter examines pre-flight branches (exit 8 under docker unreachable + exit 9 under container not running) + final-exec assembly correctness (`exec docker exec -it --user dev -w /workspace keel-devbox claude "$@"` literal value) + no-auto-start posture (SC-4 pinned; contrast Story 2.7 auto-start); Edge Case Hunter probes docker-exec-output-redirection (OAuth URL printed to stdout — `-it` preserves TTY on both sides, URL surfaces to host terminal; no stdout redirection in wrapper); Acceptance Auditor verifies AC 1 verbatim match — `pnpm claude` → claude inside container → OAuth URL to host terminal → host browser completes flow.

---

#### AC-2: Token persisted in named volume — tokens stored at `/home/dev/.claude/` inside the Story 2.5 `keel_home_dev` named volume; token file is never bind-mounted to host filesystem (P2; Story 2.5 substrate owns persistence per SC-2)

- **Coverage:** NONE ❌ (Story 2.8 ships no-token-inspection wrapper per SC-15; Story 2.5 named-volume substrate owns persistence — SC-2 ground-(c) `external-service-owns-behavior-under-test`; named-volume contract already verified at Story 2.5 iter-188 landing)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Story 2.5 substrate + iter-230 no-wrapper-token-access):**
  - **Story 2.5 substrate (iter-188 landed; UNTOUCHED at Story 2.8 iter-230)**: `packages/devbox/docker-compose.yml:90-92` declares `keel_home_dev` named volume mounted at `/home/dev` with `INV-devbox-homedev-named-volume` enforcing non-toggle-able posture. `/home/dev/.claude/` inherits the named-volume persistence transitively — token file lives inside the named volume by construction, not by Story 2.8 wrapper action. Story 2.8 does NOT create, mount, or modify any volume; composition-only on Story 2.5.
  - **`packages/devbox/scripts/claude-host.sh` (iter-230 NEW)**: Wrapper does NOT read, parse, inspect, bind-mount, or surface the token file. Zero `volume` / `mount` / `--mount` / `-v` flags in the final exec line. Token file format + write location owned by upstream `@anthropic-ai/claude-code@2.1.116` CLI (Dockerfile:119 baked). SC-15 read-only posture codifies the no-wrapper-token-access discipline.
  - **Iteration-env substrate verification (iter-230)** — `grep -c 'volume\|mount\|-v ' packages/devbox/scripts/claude-host.sh` → 0 matches (verified: no bind-mount flags in wrapper). `grep -c '\.claude' packages/devbox/scripts/claude-host.sh` → reference only in the info-log literal (`token persists at /home/dev/.claude/`), not in any exec argument.
  - **SC-12 scope carve-out (iter-228 pinned + iter-230 implementation-confirmed)**: Story 2.8 does NOT modify `packages/devbox/docker-compose.yml`. The stale `# TODO(Story 2.8 / 2.9): named-volume mounts for OAuth tokens.` at compose:156 is intentionally left in place per SC-12 — Story 2.5 compose:90-92 already subsumes the token-mount requirement; TODO is self-documenting.
  - **Live-smoke AC 2 runtime verification** (`pnpm claude` → OAuth completes → `docker exec keel-devbox ls -la /home/dev/.claude/` shows token file owned by UID 1000 inside `keel_home_dev` named volume; `docker inspect --format '{{json .Mounts}}' keel-devbox | jq` confirms `/home/dev` mount source is the named volume NOT a bind-mount path) deferred to M4-Pro operator workstation per § Testing Standards ground-(c) + Story 2.5 iter-187 precedent cluster.
  - **Adversarial AC-2 coverage delegated to iter-CR**: Blind Hunter verifies the wrapper has zero path traversal or token-handling logic (SC-15 read-only posture holds; upstream CLI owns the token write); Edge Case Hunter probes the Story 2.5 named-volume contract durability (operator explicit `-v /path:/home/dev` override at docker run time would bypass the volume — not reachable via `pnpm claude` surface per Story 2.6 wrapping; operator can only drop to raw `docker run` deliberately, which is FR1 non-toggle-able invariant violation anyway); Acceptance Auditor verifies AC 2 verbatim match — tokens at `/home/dev/.claude/` + never bind-mounted to host.

---

#### AC-3: Token survives restart — `pnpm devbox:restart` or `pnpm devbox:stop && start` preserves token; subsequent Claude Code invocation reuses existing token (no re-auth) (P2; Docker named-volume substrate + upstream CLI own behavior per SC-2)

- **Coverage:** NONE ❌ (Story 2.8 wrapper is stateless; Docker named-volume + upstream CLI token-reuse logic own behavior — SC-2 ground-(c) `external-service-owns-behavior-under-test`; Docker named-volume persistence already verified at Story 2.5 substrate landing)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Story 2.5 named-volume + Story 2.6 restart primitives + upstream CLI token-reuse):**
  - **Story 2.5 substrate (iter-188 landed; UNTOUCHED at Story 2.8 iter-230)**: `keel_home_dev` named volume survives container restart by Docker semantics — `docker compose down` without `--volumes` flag does NOT delete named volumes; `docker compose up -d` on an existing volume mounts the same volume. Story 2.6 `pnpm devbox:restart` + `pnpm devbox:stop && start` are the canonical restart primitives and are named-volume-safe by Story 2.6 SC default + Story 2.5 `INV-devbox-homedev-named-volume`. Token-survival is a property of the Docker named-volume substrate, NOT of Story 2.8's wrapper.
  - **`packages/devbox/scripts/claude-host.sh` (iter-230 NEW)**: Wrapper is stateless — re-invocation after restart hits the same pre-flight branches + final exec line against the same `${CONTAINER_NAME}` container. There is no wrapper-side state cache; claude reads its token from the mounted named volume on every invocation. Idempotent by construction.
  - **Upstream Claude Code CLI semantics** (`@anthropic-ai/claude-code@2.1.116` baked at Dockerfile:119): On invocation, claude checks `/home/dev/.claude/` for an existing token; valid token → skip OAuth, proceed silently; missing or expired token → trigger OAuth flow (AC 4 path). This is upstream Anthropic-owned behavior — Story 2.8 does NOT duplicate, proxy, or inspect it. `@anthropic-ai/claude-code@2.1.116` pinning protects against upstream breaking changes until substrate-controlled bump.
  - **Live-smoke AC 3 runtime verification** (sequence `pnpm claude` first run OAuth completes → `pnpm devbox:restart` → `pnpm claude` second invocation → claude proceeds silently; no OAuth re-trigger; existing token reused) deferred to M4-Pro operator workstation per § Testing Standards ground-(c). Requires live Anthropic endpoint for initial seed; subsequent restart-survival check is a filesystem-persistence assertion against Docker named-volume semantics (Story 2.5 substrate; not re-verified at Story 2.8 scope).
  - **Adversarial AC-3 coverage delegated to iter-CR**: Blind Hunter verifies the wrapper adds no re-auth-forcing logic (no `rm /home/dev/.claude/*` or `--logout` flag injection); Edge Case Hunter probes concurrent-invocation (two operators run `pnpm claude` on the same devbox simultaneously — upstream CLI owns the file-locking contract; Story 2.8 wrapper does not serialise), token-file-corruption (upstream CLI owns recovery — AC 4 re-auth path activates); Acceptance Auditor verifies AC 3 verbatim match — restart preserves token + subsequent invocation reuses it.

---

#### AC-4: Re-auth on expiry is self-serve — Ralph or manual `claude` invocation under expired/revoked token surfaces clear re-auth pointer; `pnpm claude` can be re-run to refresh without affecting other devbox state (P2; upstream CLI + Anthropic endpoint own expiry/refresh per SC-2)

- **Coverage:** NONE ❌ (Story 2.8 wrapper is re-auth-transparent; upstream CLI + Anthropic endpoint own expiry detection + re-OAuth-trigger — SC-2 ground-(c) `external-service-owns-behavior-under-test`; documentation substrate pointer added per Task 3 + Task 4)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; iter-230 README + AGENTS.md re-auth pointers + wrapper idempotence):**
  - **`packages/devbox/README.md` (iter-230 MODIFIED)**: New `## Claude Code authentication (Story 2.8)` H2 sibling section documents the re-auth path operator-facing — bullet (d): "if claude reports 'not authenticated' or Ralph's pre-push gate surfaces an auth failure, re-run `pnpm claude` — OAuth re-triggers in the same flow." Operator comprehension covered.
  - **`AGENTS.md` (iter-230 MODIFIED)**: New `### Claude Code authentication (Story 2.8)` H3 sibling section under § Devbox iteration environment documents the agent-facing re-auth pointer — `Re-auth pointer:` bullet: "if Ralph's `gh push`-adjacent tooling reports a Claude Code auth failure, queue `pnpm claude` as a fix task (operator-interactive). Agents SHOULD NOT attempt automated re-auth — OAuth requires a host browser." Agent contract codified.
  - **`packages/devbox/scripts/claude-host.sh` (iter-230 NEW)**: Re-auth flows through the SAME pre-flight branches + same final exec line as initial auth — wrapper is idempotent. Upstream CLI detects expired/revoked token and triggers OAuth flow on invocation; wrapper surfaces the URL to operator terminal identically to AC 1. No separate re-auth code path needed.
  - **Upstream Claude Code CLI semantics** (`@anthropic-ai/claude-code@2.1.116`): Token expiry + refresh + re-OAuth-trigger logic owned by upstream. Clear error message surfacing is upstream behavior; Story 2.8 wrapper neither catches nor massages claude's stderr. SC-15 read-only posture.
  - **Live-smoke AC 4 runtime verification** (sequence `pnpm claude` OAuth completes → artificially expire token OR wait for real expiry → `pnpm claude` → claude detects expiration, prints re-auth URL, operator re-completes OAuth in browser) deferred to M4-Pro operator workstation per § Testing Standards ground-(c). Requires live Anthropic endpoint + real token lifecycle.
  - **Adversarial AC-4 coverage delegated to iter-CR**: Blind Hunter verifies the wrapper does not suppress or mangle claude's stderr (no `2>/dev/null` or stderr redirection on the final exec); Edge Case Hunter probes partial-expiry (refresh-token valid + access-token expired — upstream CLI owns refresh-flow; Story 2.8 transparent), revocation-from-anthropic-side (upstream reports 401 + triggers OAuth; same surfaced-URL flow as AC 1); Acceptance Auditor verifies AC 4 verbatim match — expired/revoked token → clear re-auth pointer + `pnpm claude` refresh path + no collateral devbox-state damage.

---

#### AC-5: Volume-delete clears token (NFR10 fresh-fork behaviour) — `pnpm devbox:clean --with-volumes` wipes tokens; next devbox run requires `pnpm claude` re-auth (P2; Story 2.6 clean primitives + Docker volume-delete semantics own behavior per SC-2)

- **Coverage:** NONE ❌ (Story 2.8 wrapper does not persist outside named volume; Story 2.6 `pnpm devbox:clean --with-volumes` owns volume-delete path; Docker volume-delete + upstream CLI OAuth re-seed own behavior — SC-2 ground-(c) `external-service-owns-behavior-under-test`)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Story 2.6 clean primitives + Story 2.5 named-volume + iter-230 no-wrapper-cache):**
  - **Story 2.6 substrate (iter-201 landed; UNTOUCHED at Story 2.8 iter-230)**: `pnpm devbox:clean` preserves `keel_home_dev` by default (NFR10). `--with-volumes` flag gates on `[y/N]` prompt (or `--yes`); under backend B an additional `--force-backend-b` flag is required to prevent surprise destruction of a host-shared volume per AGENTS.md § Host-side CLI (Story 2.6). Volume-delete → `/home/dev/.claude/` → token file gone by Docker semantics.
  - **`packages/devbox/scripts/claude-host.sh` (iter-230 NEW)**: Wrapper does NOT cache or persist token state outside `/home/dev/.claude/`. After `pnpm devbox:clean --with-volumes`, next `pnpm claude` invocation hits an empty `/home/dev/.claude/` → upstream CLI detects no token → triggers OAuth flow → operator completes → token re-seeds fresh. Expected per NFR10 fresh-fork behaviour (deliberate design; not a bug).
  - **`packages/devbox/README.md` (iter-230 MODIFIED)**: § Claude Code authentication bullet (e) — "`pnpm devbox:clean --with-volumes` wipes `/home/dev/.claude/` along with `keel_home_dev`; expected per NFR10 fresh-fork behaviour; re-run `pnpm claude` to re-seed." Operator comprehension covered.
  - **Story 2.5 substrate**: `INV-devbox-homedev-named-volume` enforces named-volume posture; volume-delete semantics are Docker-native. Story 2.8 does NOT add a re-seed-on-delete hook or auto-re-auth — operator-interactive re-seed is the intended NFR10 posture.
  - **Live-smoke AC 5 runtime verification** (sequence `pnpm claude` OAuth seeds token → `pnpm devbox:clean --with-volumes --force-backend-b` volume deleted → `pnpm devbox:start` → `pnpm claude` → OAuth URL surfaces again; token gone; fresh flow required) deferred to M4-Pro operator workstation per § Testing Standards ground-(c) + Story 2.5 iter-187 precedent. Backend B cannot safely exercise `--with-volumes --force-backend-b` without destroying host-shared state.
  - **Adversarial AC-5 coverage delegated to iter-CR**: Blind Hunter verifies no wrapper-side backup or shadow-copy of token outside the named volume (SC-15 read-only posture); Edge Case Hunter probes `pnpm devbox:clean` WITHOUT `--with-volumes` (token SHOULD survive — NFR10 preservation; verified by Story 2.6 iter-201 substrate default), partial-volume-delete-interruption (volume is atomic at Docker daemon level — either deleted or retained, no partial state), named-volume-renamed-by-operator (`COMPOSE_PROJECT_NAME` override would produce a different volume name — Story 2.8 wrapper's `unset COMPOSE_PROJECT_NAME` defends against this per Story 2.6 AI-8 + Story 2.7 SC-10 pattern); Acceptance Auditor verifies AC 5 verbatim match — volume-delete → token gone → `pnpm claude` re-auth required.

---

## PHASE 2: GATE DECISION

### Decision: **WAIVED** ✅

**Rationale:**

Story 2.8 is the EIGHTEENTH cumulative Epic-story trace-WAIVED invocation (extending the 17-precedent stack: 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14/1.15/1.16 → 2.1 → 2.2 → 2.3 → 2.4 → 2.5 → 2.6 → 2.7 → 2.8) and the NINETEENTH ATDD-skip-trace-WAIVED pairing overall. The deterministic gate logic would compute FAIL (overall 0% < 80%; P2 coverage 0%) — but this is a structural false-positive because no test runner is wired at Story 2.8 substrate stage. Story 2.8 § Testing Standards affirmatively declares trace-WAIVED via:

1. **Ground (a) — substrate-verification covers AC 1 invocation envelope at iteration-env-safe layer.** Task 5 iteration-env-safe smokes exercised (iter-230): bash -n × 1 script (syntax valid); pnpm wiring count 1 (claude); stub-docker info-fail branch → exit 8 + stderr `[claude] docker unreachable — is the daemon running?`; stub-docker not-running branch → exit 9 + stderr `[claude] container 'keel-devbox' is not running — run 'pnpm devbox:start' first`; stub-docker running branch → final exec `-it --user dev -w /workspace keel-devbox claude` captured verbatim → wrapper exit 0; args-passthrough `claude-host.sh --version` → stub captures `--version` arg verbatim; no-TTY-gate `grep -c 'tty_flag\|-t 0' claude-host.sh` → 0 matches. 1/5 ACs (AC 1 invocation envelope) substrate-smoked at shell level; 4/5 ACs upstream-CLI + Docker-substrate-deferred.

2. **Ground (b) — no test runner wired at substrate level.** Recursive probe for vitest.config.*/jest.config.*/playwright.config.*/cypress.config.*/pyproject.toml/go.mod/Gemfile/Cargo.toml/csproj returns zero matches at iter-231. Epic 13 is the formal test-framework landing per PRD RS6. Bare "no runner" is insufficient per Story 1.8 guardrail — it combines with ground (a) and NEW ground (c).

3. **Ground (c) NEW VARIANT — `external-service-owns-behavior-under-test` for AC 1 / AC 2 / AC 3 / AC 4 / AC 5.** All five ACs reference behaviors owned by: (i) upstream `@anthropic-ai/claude-code@2.1.116` CLI (Anthropic-owned; baked at Dockerfile:119) for OAuth URL surfacing + token file write/read + token refresh logic; (ii) Anthropic's OAuth endpoint (external service at `api.anthropic.com` + `console.anthropic.com` — Story 2.3/2.4 egress substrate already whitelists); (iii) Docker named-volume persistence substrate (Story 2.5 `keel_home_dev` + `INV-devbox-homedev-named-volume`; already verified at Story 2.5 landing — not re-verified at Story 2.8 scope). Story 2.8's wrapper can ONLY verify: (α) invocation envelope is correctly assembled; (β) pre-flight guards emit correct exit codes; (γ) args-passthrough works; (δ) no wrapper-side token inspection/caching (SC-15). Full AC verification requires: live `@anthropic-ai/claude-code@2.1.116` reaching Anthropic's OAuth endpoint + host browser for URL completion + real Anthropic account + M4-Pro native Docker Desktop for reliable `docker exec -it` TTY + stdin_open under cap-dropped containers. This is the natural extension of Story 2.7's `downstream-epic-owns-behavior-under-test` (Epic-3-scope) with a sibling for upstream-CLI + external-endpoint-scope auth-flow class (Story 2.8 Claude + Story 2.9 gh forecast inheritance).

4. **Hybrid variant-(iii) spec-declared-CR-substitution.** Story 2.8 § Dev-agent guardrails + 17 pinned scope-clarifications (SC-1 through SC-17) + forthcoming `/bmad-code-review (args: "2")` adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.8 substrate diff: 1 new script + 3 modified files; forecast 1–3 PATCH opener + 0 closure re-run per Story 2.7 iter-226 ONE-PASS ZERO-PATCH precedent — Story 2.8 is SECOND one-pass ZERO-PATCH candidate given narrower novel surface) substitute for red-phase scaffolds.

### Gate Criteria

- **P0 Coverage:** 0/0 = 100% ✅ (MET — no P0 requirements)
- **P1 Coverage:** 0/0 = 100% ✅ (MET — no P1 requirements)
- **P2 Coverage:** 0/5 = 0% ❌ (NOT_MET by deterministic rule; WAIVED per § Testing Standards declaration)
- **Overall Coverage:** 0% ❌ (NOT_MET by deterministic rule; WAIVED per § Testing Standards declaration)

### Critical Gaps

0 — No P0 or P1 requirements to cover.

### Uncovered Requirements (gate-deferred)

- AC-1 (P2): OAuth flow surfaced to host terminal. Substrate: claude-host.sh pre-flight branches (exit 8 / exit 9) + final exec (`-it --user dev -w /workspace keel-devbox claude "$@"`); smokes 3a/3b/3c/3d all green. Deferred: live `@anthropic-ai/claude-code@2.1.116` → Anthropic OAuth endpoint → host browser flow to M4-Pro operator workstation.
- AC-2 (P2): Token persisted in named volume. Substrate: Story 2.5 `keel_home_dev` named volume (verified at Story 2.5 iter-188 landing) + wrapper SC-15 no-token-inspection posture; no bind-mount flags in final exec. Deferred: live filesystem inspection post-OAuth to operator workstation.
- AC-3 (P2): Token survives restart. Substrate: Docker named-volume survival-across-compose-restart semantics (Story 2.5) + wrapper idempotence. Deferred: live OAuth seed + `pnpm devbox:restart` + silent second invocation to operator workstation.
- AC-4 (P2): Re-auth on expiry is self-serve. Substrate: README H2 + AGENTS.md H3 re-auth pointers (iter-230) + wrapper transparency to upstream CLI stderr. Deferred: live expired/revoked token + OAuth re-trigger to operator workstation.
- AC-5 (P2): Volume-delete clears token (NFR10). Substrate: Story 2.6 `pnpm devbox:clean --with-volumes` primitive (iter-201) + wrapper no-persistence-outside-named-volume (SC-15) + README bullet (e). Deferred: live `--with-volumes --force-backend-b` + re-seed to operator workstation.

---

## Recommendations

1. **MEDIUM — Accept WAIVED posture.** Five P2 ACs covering an Epic-2-ships-envelope-upstream-CLI-ships-runtime class story. EIGHTEENTH cumulative trace-WAIVED; NINETEENTH ATDD-skip-trace-WAIVED co-application pairing. 1/5 ACs (AC 1 invocation envelope) substrate-smoked at shell level; 4/5 ACs (AC 2 token-volume / AC 3 restart-survival / AC 4 re-auth / AC 5 volume-delete) upstream-CLI + Docker-substrate-deferred under SC-2 ground-(c) `external-service-owns-behavior-under-test`.
2. **MEDIUM — Story 2.8 authors 1 NEW host-side bash shim + 3 modified files per SC-17 scope boundary.** Substrate contracts preserved verbatim (Story 2.1 Dockerfile + entrypoint.sh + CMD[sleep,infinity] + Story 2.2 .envrc + Story 2.3 egress whitelist — `api.anthropic.com` + `console.anthropic.com` already covered + Story 2.4 whitelist + Story 2.5 hardening + named-volume LOAD-BEARING for AC 2/3/5 + Story 2.6 13-verb surface + shell.sh/attach.sh interactive-exec pattern composed + Story 2.7 2-verb ralph surface + ralph-*-host.sh interactive-exec precedent composed + Story 1.12 theme.py orthogonal). No new invariants.manifest.ts entries. Sync-gate GREEN.
3. **MEDIUM — Per-AC live-OAuth-flow verification unlocks at M4-Pro operator workstation backend-A.** AC 1/2/3/4/5 material verification requires live `@anthropic-ai/claude-code@2.1.116` reaching Anthropic's OAuth endpoint + host browser + real Anthropic account. No Story 2.8 code change required at any live-flow verification point — wrapper is stateless; upstream CLI + Docker named-volume substrate own all five behaviors. Downstream consumer signal: Story 2.9 `pnpm gh:auth` inherits the same upstream-CLI-ships-runtime pattern verbatim (GitHub CLI + GitHub OAuth endpoint); NINETEENTH (and ultimately TWENTIETH co-application) ATDD-skip-trace-WAIVED pairing forecast at Story 2.9 with identical ground-(c) variant.
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
EIGHTEENTH cumulative trace-WAIVED precedent — FIRST Epic-2-ships-envelope-upstream-CLI-
ships-runtime class; NEW ground-(c) variant `external-service-owns-behavior-under-test` for
AC 1–5 (upstream @anthropic-ai/claude-code@2.1.116 CLI + Anthropic OAuth endpoint + Story 2.5
Docker named-volume substrate own the behaviors). 1/5 ACs substrate-smoked (AC 1 invocation
envelope: 7 smokes green); 4/5 ACs upstream-CLI + Docker-substrate-deferred (AC 2 token-
volume; AC 3 restart-survival; AC 4 re-auth; AC 5 volume-delete). Iteration-env-safe smokes
ALL PASSED at iter-230 (7 smokes over 1 script — densest per-script coverage in Epic 2).

⚠️ Critical Gaps: 0

📝 Recommended Actions (top 3):
1. Accept WAIVED; 18th cumulative / 19th pairing
2. Story 2.8 scope: 1 script + 3 modified files; substrate contracts preserved
3. M4-Pro operator workstation unlocks AC 1–5 live-OAuth material verification

📂 Full Report: _bmad-output/test-artifacts/traceability/2-8-claude-code-oauth-via-pnpm-claude.md
📂 Coverage Matrix: _bmad-output/test-artifacts/traceability/2-8-coverage-matrix.json
📂 E2E Trace Summary: _bmad-output/test-artifacts/traceability/2-8-e2e-trace-summary.json
📂 Gate Decision: _bmad-output/test-artifacts/traceability/2-8-gate-decision.json
```
