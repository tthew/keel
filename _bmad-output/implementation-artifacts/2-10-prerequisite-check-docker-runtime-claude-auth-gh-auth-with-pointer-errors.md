# Story 2.10: Prerequisite check (Docker runtime + Claude auth + gh auth) with pointer errors

Status: review <!-- sprint-row status unchanged — Ralph-internal `Story State` = `traced` post-trace-WAIVED at iter-249 per § Story Lifecycle Decision Matrix row `in-dev → traced`. Sprint-row stays `review` per iter-202 precedent (trace gate does NOT flip sprint-row; only Change Log records). Trace WAIVED — TWENTIETH cumulative precedent per § Testing Standards three-ground conjunction (ground-(a) 9/9 stub-docker smokes + ground-(b) no test runner + ground-(c) variant `external-service-owns-behavior-under-test` with multi-service composition — FIRST application). Four artefacts landed under `_bmad-output/test-artifacts/traceability/2-10-*`. -->


<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want a prerequisite check that runs on fresh-fork first-run and on every Ralph invocation, failing with install-pointer or auth-pointer errors if Docker runtime is missing, Claude Code is not authed, or `gh` is not authed,
So that Ralph cannot execute autonomously in a broken environment (FR5).

## Acceptance Criteria

1. **Docker-missing fails with install-pointer.** Given a host without Docker installed (or daemon unreachable), when I run `pnpm ralph:build` or any `pnpm devbox:*` command, then the prerequisite check fails with a stderr message pointing at Docker Desktop install instructions (the URL `https://docs.docker.com/desktop/install/` appears verbatim in the message) and the command exits non-zero before starting or exec'ing into the devbox.

2. **Claude-missing fails with auth-pointer (Ralph-gated).** Given Docker is running but Claude Code is not authed inside the devbox, when `pnpm ralph:build` (or `pnpm ralph:plan`) runs its prerequisite check, then the check detects the missing token by probing `/home/dev/.claude/` state inside the `keel_home_dev` named volume and surfaces the pointer error `"Claude Code not authed — run 'pnpm claude' first"` and exits non-zero before attaching to the Ralph TUI.

3. **gh-missing fails with auth-pointer (Ralph-gated).** Given Claude Code is authed but `gh` is not, when `pnpm ralph:build` (or `pnpm ralph:plan`) runs its prerequisite check, then the check detects the missing gh token by probing `/home/dev/.config/gh/` state inside the `keel_home_dev` named volume and surfaces `"gh CLI not authed — run 'pnpm gh:auth' first"` and exits non-zero before attaching to the Ralph TUI.

4. **All-satisfied passes silently and Ralph starts normally.** Given all three prerequisites are satisfied (Docker running + Claude token present + gh token present), when `pnpm ralph:build` runs, then the prerequisite check passes silently (no stderr spam; exit 0) and the Ralph loop starts normally by attaching to the container via Story 2.7's `docker attach` path.

5. **Fresh-fork first-run surfaces a composite missing-item list; no partial bypass.** Given fresh-fork first-run (no previous devbox state — no container, no named volume, no tokens) when a new fork operator runs any `pnpm devbox:*` or `pnpm ralph:*` command, then the prerequisite check runs and surfaces the missing-item list as a single stderr message (aggregating Docker / Claude / gh findings per tier contract per SC-5) and an exit-zero path requires all three to be satisfied (no partial bypass — operator cannot pass `--skip-claude` or `--force` to bypass any check at 1.0).

## Tasks / Subtasks

- [x] **Task 1: Author `packages/devbox/scripts/prereq-check.sh`** (AC 1, AC 2, AC 3, AC 4, AC 5)
  - [x] Shebang `#!/usr/bin/env bash` + banner header (purpose = FR5 prerequisite-check primitive; dual-ref Story 2.10 AC 1–5 + Story 2.6 uniform exit-code schema + Stories 2.8/2.9 token-persistence contracts).
  - [x] `set -euo pipefail`.
  - [x] `unset COMPOSE_PROJECT_NAME` — Story 2.6 AI-8/AI-12 + Story 2.7 SC-10 + Story 2.8 SC-8 + Story 2.9 SC-8 defensive-posture precedent. Protects `keel-devbox_keel_home_dev` named-volume identity (`INV-devbox-homedev-named-volume`).
  - [x] `VOLUME_NAME="${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}_keel_home_dev"` — compose-project-scoped volume name; operator-overridable via `KEEL_DEVBOX_COMPOSE_PROJECT` (Story 2.2 parameterization) with default matching docker-compose.yml's `name:` field.
  - [x] `log() { printf '[prereq-check] %s\n' "$*" >&2; }`.
  - [x] Arg parsing: accept one optional positional arg `--tier1` (Docker only) or `--tier2` (all three; default). Reject unknown args with exit 2 and a usage message.
  - [x] **Tier 1 check — Docker runtime reachable:**
    - [x] `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log_err_docker_missing; exit 8; }` where `log_err_docker_missing` is a function emitting two stderr lines: `[prereq-check] docker unreachable — is the daemon running?` and `[prereq-check] install Docker Desktop: https://docs.docker.com/desktop/install/` (AC 1 URL verbatim).
    - [x] Tighter-variant `--format '{{.ServerVersion}}'` per Story 2.7 + 2.8 + 2.9 inheritance chain; NOT bare `docker info` (which has `>/dev/null` echoing).
  - [x] **Tier 2 check — Docker + Claude + gh tokens:**
    - [x] Run Tier 1 first. If exit 8 → exit 8 (propagated; Tier 2 cannot proceed without Docker).
    - [x] Probe named volume: `docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1` — if volume does NOT exist (fresh-fork first-run before `pnpm devbox:start` has created it), treat as "both tokens missing" and aggregate both pointer errors into the composite stderr message.
    - [x] Probe Claude token: `docker run --rm -v "${VOLUME_NAME}":/vol:ro alpine:3.19 test -e /vol/.claude/.credentials.json` (SC-7 image pin). Exit 0 → present; non-zero → missing; record finding.
    - [x] Probe gh token: `docker run --rm -v "${VOLUME_NAME}":/vol:ro alpine:3.19 test -e /vol/.config/gh/hosts.yml`. Exit 0 → present; non-zero → missing; record finding.
    - [x] Aggregate findings (composite-message contract per AC 5 + SC-5): if both tokens missing, emit TWO stderr lines — `[prereq-check] Claude Code not authed — run 'pnpm claude' first` + `[prereq-check] gh CLI not authed — run 'pnpm gh:auth' first` — in that order (Claude before gh, matching Story 2.8 → 2.9 landing order), then exit 2. If exactly one missing, emit one line + exit 2. If both present, exit 0 silently.
  - [x] Exit-code schema (extends Story 2.6 uniform): `0` all pass, `2` one or more tokens missing (composite pointer list emitted), `8` docker unreachable (install-URL pointer emitted), `12` other docker-daemon error (volume-inspect crash, alpine pull failure under fail-closed egress) — propagated via `docker`'s own non-zero exit.
  - [x] `chmod +x` at creation.

- [x] **Task 2: Root `package.json` pnpm wiring — `pnpm devbox:prereq:check` standalone verb** (AC 5 — operator-surface discoverability)
  - [x] Add one entry to `scripts`: `"devbox:prereq:check": "./packages/devbox/scripts/prereq-check.sh"`.
  - [x] Insertion point — AFTER the `"devbox:env:check"` entry (alphabetical within the `devbox:*` group; `devbox:env:check` → `devbox:prereq:check` sort order) and BEFORE `"ralph:build"`. Verb form uses the existing `devbox:<subverb>` colon pattern (Story 2.6 precedent for `devbox:env:check`).
  - [x] Verb form deliberate: **`devbox:prereq:check` uses double-colon (namespace:sub-verb form), matching `devbox:env:check` precedent.** Operators running the verb standalone execute Tier 2 by default (exits 0 silently if all three pass); `pnpm devbox:prereq:check --tier1` for Docker-only. AC 5 "fresh-fork first-run surfaces missing-item list" is satisfied by this direct verb OR by ralph/devbox wrapper pre-flight (SC-11 wires it into all shims).
  - [x] Smoke: `pnpm run 2>&1 | grep -E '^ +devbox:prereq:check$'` → 1 match.

- [x] **Task 3: Wire Tier 2 into `ralph-build-host.sh` + `ralph-plan-host.sh`** (AC 2, AC 3, AC 4 — Ralph-invocation-gating)
  - [x] At the top of each ralph-*-host.sh, BEFORE the existing `docker info` pre-flight + auto-start block, add: `"$(dirname "${BASH_SOURCE[0]}")/prereq-check.sh" --tier2`. Propagate the exit code: if prereq-check exits non-zero, ralph-*-host.sh exits with the same code without attempting auto-start or `docker attach`.
  - [x] Remove the existing inline `docker info` pre-flight block from each ralph-*-host.sh (now subsumed by `prereq-check.sh --tier2` which runs Tier 1 first). Do NOT remove the `start.sh` auto-start block or the final `docker attach` — those remain.
  - [x] Preserve Story 2.7's auto-start posture: after prereq-check passes, ralph-*-host.sh still sub-invokes `start.sh` (which may be a no-op if container already running) and then `docker attach`es. The prereq-check-before-auto-start ordering is deliberate — operators without Docker should NOT see an auto-start attempt.
  - [x] Exit-code passthrough: prereq-check's exit 8 / 2 / 12 propagate through ralph-*-host.sh unchanged; Story 2.7's existing 9 / 10 / 11 schema for auto-start and healthcheck still applies AFTER the prereq-check gate.

- [x] **Task 4: Wire Tier 1 into the 15 other host-side shims** (AC 1, AC 5 — "any `pnpm devbox:*` command" gating)
  - [x] Affected shims (15 total):
    - Story 2.6 devbox verbs (13): `build.sh`, `rebuild.sh`, `start.sh`, `stop.sh`, `restart.sh`, `clean.sh`, `shell.sh`, `attach.sh`, `status.sh`, `logs.sh`, `monitor-host.sh`, `whitelist-host.sh`, `env-check.sh`.
    - Story 2.8 (1): `claude-host.sh`.
    - Story 2.9 (1): `gh-auth-host.sh`.
  - [x] For each shim, at the top BEFORE the existing inline `docker info` block (but AFTER `set -euo pipefail` + `unset COMPOSE_PROJECT_NAME`), add: `"$(dirname "${BASH_SOURCE[0]}")/prereq-check.sh" --tier1`. Propagate exit code (exit 8 bubbles up; no further pre-flight runs if prereq-check fails).
  - [x] **Remove the existing inline `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log ...; exit 8; }` block** from each shim (now subsumed by prereq-check Tier 1). Preserve each shim's OTHER pre-flight (`docker inspect` container-state check, env-var probes in env-check.sh, etc.) — those remain per-shim concerns.
  - [x] **`restart.sh` special case (2026-04-23 verified):** `restart.sh` has NO inline `docker info` block of its own — it transitively delegates Docker reachability to `stop.sh` + `start.sh` (both of which get the prereq-check wire-in in this task). Story 2.10 STILL prepends `"$(dirname "${BASH_SOURCE[0]}")/prereq-check.sh" --tier1` at the top of `restart.sh` for consistency + fail-fast visibility (operator gets the install-URL pointer BEFORE restart.sh invokes stop.sh). No inline-block REMOVAL step applies — prepend only. The existing L47 `# docker info` narrative comment can stay (documentation of transitive coverage) or be updated to reference `prereq-check.sh` at dev-agent's discretion.
  - [x] `env-check.sh` (Story 2.6) special case: `env-check.sh` currently has NO `docker info` check (it validates env vars only, not Docker reachability). Story 2.10 STILL calls `prereq-check.sh --tier1` at the top of env-check.sh so fresh-fork first-run `pnpm devbox:env:check` also surfaces the install-URL pointer when Docker is missing (AC 5 "any `pnpm devbox:*` command"). This is a NEW gate for env-check.sh, not a refactor. Exit-code schema extension: env-check.sh's existing `2`/`3` (missing var / `.envrc` unreadable) codes remain; `8` (docker unreachable) is now also possible, emitted by the prereq-check call.
  - [x] **Substrate contracts preserved on each shim:** only the single `docker info`-line block is removed + a single `prereq-check.sh --tier1` call is added. All other shim logic (container-name derivation, container-state inspect, final `exec`/`attach`/`compose` calls, signal handling, TTY posture, args passthrough) is UNCHANGED. Mirror discipline with Story 2.6/2.8/2.9 prior art is preserved.
  - [x] Exception — `prereq-check.sh` does NOT call itself. No recursion.

- [x] **Task 5: Register `INV-devbox-prereq-check` + author `docs/invariants/devbox-prereq-check.md`** (AC 1–5 machine-enforced contract)
  - [x] Add new entry to `packages/keel-invariants/src/invariants.manifest.ts`:
    - `id: 'INV-devbox-prereq-check'`
    - `description: 'Prerequisite check for Docker runtime + Claude Code auth + gh auth runs on every host-side shim invocation and fails fast with pointer errors (Story 2.10).'`
    - `sourcePath: 'docs/invariants/devbox-prereq-check.md'`
    - `contentHash: '<sha256 of the authored md file content>'`
    - `anchors: ['INV-devbox-prereq-check']`
  - [x] **InvariantSchema five-field compliance** (Story 2.3 iter-156 LESSON):  `InvariantSchema` at `packages/keel-invariants/src/invariants.manifest.ts:3-15` requires exactly `{id, description, sourcePath, contentHash, anchors}` — NO `name` field; `anchors` entries are backtick-wrapped ID literals NOT H3-header strings; `contentHash` is bare 64-char lowercase hex NOT `sha256:<hex>` prefixed. Story 2.10 compliance is mandatory.
  - [x] Author `docs/invariants/devbox-prereq-check.md` with the following H2-structured sections so each sub-contract is hashed into `contentHash` (Story 2.3 iter-156 LESSON — multi-faceted contracts embed sub-schemas verbatim in the `sourcePath` doc):
    - `## Three-check contract` — enumerates Docker / Claude / gh probes + the exact stderr message templates (verbatim pointer strings from ACs 1–3).
    - `## Exit-code schema` — pins `0 / 2 / 8 / 12` semantics per Task 1.
    - `## Tier contract (Tier 1 vs Tier 2)` — pins which shim invokes which tier (full enumeration of the 17 shims) so downstream refactors cannot drift.
    - `## No-partial-bypass` — AC 5 clause verbatim: no `--skip-claude` / `--force` / `KEEL_PREREQ_BYPASS` escape-hatch at 1.0; a fork operator needing to bypass is outside the supported operator-experience envelope.
    - `## Fresh-fork first-run behavior` — AC 5 narrative for the volume-absent case (probe volume existence → if absent, treat as both tokens missing).
    - `## Alpine probe image` — SC-7 pin: `alpine:3.19` as the minimal throwaway image used for volume file-existence probes; any future minor bump requires `packages/keel-invariants/` substrate review + Renovate `docker` manager tracking.
  - [x] Compute `contentHash`: `sha256sum docs/invariants/devbox-prereq-check.md | awk '{print $1}'`. Paste the 64-char lowercase hex into the manifest entry. `pnpm keel-invariants:check` MUST pass after manifest + doc both land (Story 1.9 sync-gate verification).
  - [x] Append entry to `INVARIANTS.md` under the devbox section (after `INV-devbox-homedev-named-volume`) as: `- **\`INV-devbox-prereq-check\`**` with one-line description; index-only, no body (`INVARIANTS.md` is an agent-readable index per FR42).
  - [x] Dev-agent guardrail: the anchor bullet MUST match the verbatim regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` per `packages/keel-invariants/src/sync-gate.ts:24` (Story 1.9 sync-gate). Lowercase-after-`INV-` prefix is MANDATORY (regex's `[a-z0-9]` character class is case-sensitive; Story 1.9 iter-7 LESSON — real `INV-*` IDs are lowercase after the `INV-` prefix). Example compliant bullet: `- **\`INV-devbox-prereq-check\`** — Prerequisite check for Docker runtime + Claude + gh auth on every host-side shim invocation. Source: \`docs/invariants/devbox-prereq-check.md\`.`

- [x] **Task 6: Operator + agent documentation + Change Log housekeeping** (AC 1–5 comprehension)
  - [x] **`packages/devbox/README.md`** — append new H2 `## Prerequisite check (Story 2.10)` AFTER the existing `## gh CLI authentication (Story 2.9)` H2 (sibling placement at the same outline level) and BEFORE `## cc-devbox upstream provenance`.  Content: (a) quick-start `pnpm devbox:prereq:check` invocation; (b) three-check enumeration (Docker / Claude / gh) + exact pointer strings; (c) tier contract — Tier 1 gates every host-side shim; Tier 2 gates ralph-*-host.sh + standalone verb; (d) fresh-fork first-run walkthrough — expect a composite missing-item list on first `pnpm ralph:build`; operator follows the pointer sequence (install Docker → `pnpm devbox:start` → `pnpm claude` → `pnpm gh:auth` → re-run `pnpm ralph:build`); (e) exit-code reference — `0` / `2` / `8` / `12`; (f) no-bypass posture — there is NO `--skip-claude` / `--force` / `KEEL_PREREQ_BYPASS` at 1.0; operators with nuanced needs (e.g., CI harness without host browser) run `prereq-check.sh --tier1` directly and bypass token probes; (g) cross-ref to `AGENTS.md § Prerequisite check`.
  - [x] **DO NOT modify existing `## Host-side CLI (Story 2.6)`, `## Ralph loop (Story 2.7)`, `## Claude Code authentication (Story 2.8)`, or `## gh CLI authentication (Story 2.9)` sections** — append a NEW sibling H2 only. Rewriting prior stories' sections is scope-creep (SC-17 inherited from Story 2.9).
  - [x] **`AGENTS.md`** — append new H3 `### Prerequisite check (Story 2.10)` AFTER the existing `### gh CLI authentication (Story 2.9)` H3 under § Devbox iteration environment. Content: (a) canonical invocation is `pnpm devbox:prereq:check` (never call `prereq-check.sh` directly from agent contexts); (b) three-check contract + the exact pointer strings + exit-code schema; (c) `INV-devbox-prereq-check` citation for the machine-enforced contract; (d) fail-mode guidance — when prereq-check exits 8, agents MUST queue `pnpm devbox:build` or Docker-install as an operator fix task (agents do NOT attempt to install Docker autonomously); when prereq-check exits 2 with a Claude-missing pointer, queue `pnpm claude`; when gh-missing, queue `pnpm gh:auth`; (e) Epic 3 pre-push-gate halt-able pointer extension — when Ralph's in-loop pre-push gate fires a prereq-check and it exits 8 or 2, write halt `{"reason":"CI_BLOCKED","note":"<exact pointer string>"}` per the closed halt-reason enum (`INV-ralph-halt-reason-enum`; PRD FR14k). Stories 2.8 SC-10 and 2.9 SC-10 already pin `CI_BLOCKED` for Claude/gh-specific halts; Story 2.10 generalises to the composite prereq-check surface.
  - [x] **DO NOT modify existing `### Host-side CLI (Story 2.6)`, `### Ralph loop (Story 2.7)`, `### Claude Code authentication (Story 2.8)`, or `### gh CLI authentication (Story 2.9)` sections** — append a NEW sibling H3 only (SC-17).
  - [x] **Change Log v1.0 entry** — record 5 ACs + 6 tasks + ~17 SCs; initial draft; dev-ready; ATDD skip forecast under FR14n matrix row 3 ground-(a)+(b)+(c) conjunction per § Testing Standards; trace WAIVED forecast; CR PATCH forecast 0–3 opener (narrow novel surface — composition on Stories 2.6/2.8/2.9 with SC-14 `_lib.sh`-adjacent shim refactor being the new element).
  - [x] **Sprint-status housekeeping:** Step 4 (dev-story) flips `2-10-...: ready-for-dev → in-progress`; Step 9 (dev-story) flips `in-progress → review`. Not a create-story task — the `/bmad-create-story` workflow's step 6 automation flips `backlog → ready-for-dev`.

## Dev Notes

### Scope clarifications (SC-1..SC-17)

**SC-1 — Stories 2.6 + 2.7 + 2.8 + 2.9 host-side CLI is the composable substrate.** Story 2.10 composes on Story 2.6's 13-verb devbox surface + Story 2.7's 2-verb ralph auto-start pair + Story 2.8's `claude` verb + Story 2.9's `gh:auth` verb, adding ONE more standalone verb (`devbox:prereq:check`) + 17 shim wire-ins. The host-side-shim count after Story 2.10 landing is **18** total (17 Story 2.9 landing + 1 new Story 2.10 `prereq-check.sh`). Story 2.10 `prereq-check.sh` deliberately is NOT a `<verb>-host.sh` (`<verb>-host.sh` is reserved for pnpm-verb wrappers per Story 2.6 SC-2 naming convention) — it is a shared primitive called by other shims. Its name follows the Story 2.3/2.4 primitive-naming pattern (`reload-egress.sh`, `whitelist.sh`) — verb-first-no-host-suffix for non-pnpm-verb orchestrators. [Source: 2-9-gh-cli-oauth-via-pnpm-gh-auth.md § Dev Notes SC-1; 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-2]

**SC-2 — Docker runtime check delegates to upstream Docker Desktop (external CLI).** AC 1's "Docker runtime reachable" is a behaviour of the host Docker Desktop (or Docker Engine on Linux/Colima on macOS). Story 2.10's wrapper invokes `docker info --format '{{.ServerVersion}}'` and interprets any non-zero exit as "Docker unreachable." The pointer URL `https://docs.docker.com/desktop/install/` is the canonical Docker-Desktop install page at the Docker-owned docs site; the URL is hardcoded in `prereq-check.sh` at draft time (2026-04-23 verified; if Docker changes URL, a future substrate polish updates the string). Story 2.10 does NOT: (a) vendor or self-host the install guide; (b) attempt any auto-install path; (c) verify Docker version compatibility (INV-devbox-dind-available covers the broader Docker runtime contract; Story 2.10 probes reachability only). [Source: `INV-devbox-dind-available` § Backend contract; `docs/invariants/devbox-dind.md`]

**SC-3 — Claude / gh token detection is filesystem-based, not CLI-based.** AC 2's "probe `/home/dev/.claude/` state" explicitly directs filesystem probing over invoking `claude --version` or `gh auth status`. Rationale: CLI-based probes require the target binaries to be reachable + functional, which adds failure modes (network / permission / upstream-CLI-crash); filesystem probe on the named volume is deterministic and side-effect-free. The probe files are:
- **Claude: `/home/dev/.claude/.credentials.json`** — upstream `@anthropic-ai/claude-code@2.1.116` writes this file post-OAuth (verified via Story 2.8 iter-230 live smoke on operator workstation). Path is upstream contract; if upstream rotates filename (future major version), Story 2.10's probe path MUST update in lockstep + the `SC-3 probe-file` row in `docs/invariants/devbox-prereq-check.md § Three-check contract` MUST be re-hashed into `contentHash` at manifest level.
- **gh: `/home/dev/.config/gh/hosts.yml`** — upstream `gh` CLI default location (verified via Story 2.9 iter-237 + iter-244 live smoke on operator workstation). Same rotation contract applies.

Story 2.10 does NOT parse or validate the file contents — existence alone is the signal. If the file exists but contains an expired token, `pnpm ralph:build` will still "pass" the prereq-check, and the expired-token condition surfaces later during actual `claude` or `gh` invocations (both of which have their own re-auth-pointer surfaces per Story 2.8 AC 4 + Story 2.9 AC 4; Ralph's in-loop pre-push gate in Epic 3 Story 3.7 catches these separately). This is deliberate — the prereq-check is a presence-of-file gate, NOT a token-validity gate (validity is upstream's concern). [Source: Story 2.8 AC 4 re-auth pointer; Story 2.9 AC 4 re-auth pointer + halt-able handling; `packages/devbox/scripts/claude-host.sh` Story 2.8 substrate; `packages/devbox/scripts/gh-auth-host.sh` Story 2.9 substrate]

**SC-4 — Probe container is `alpine:3.19` throwaway, NOT the devbox image.** The token-probe runs `docker run --rm -v "${VOLUME_NAME}":/vol:ro alpine:3.19 test -e /vol/...`. `alpine:3.19` is chosen for: (a) smallest footprint (~5MB compressed) — low cost at first-pull; (b) stable enough — alpine minor-line pin avoids surprise major-version drift (alpine major-line-bumps occasionally break musl-libc ABI). **Egress-whitelist non-applicability.** `prereq-check.sh` runs host-side; `docker run` issues the alpine pull via the operator's Docker daemon (backend B: `/var/run/docker.sock` bind-mounted from host; the pull uses the host's network namespace, NOT the container's). The devbox in-container egress allow-list at `packages/devbox/whitelist*.txt` governs outbound traffic FROM within the devbox's network namespace only — alpine-pull traffic originates from the host Docker daemon and is out of devbox-egress scope. No whitelist modification required. Operators running on restrictive host-network environments (corp proxies, air-gapped CI) handle Docker Hub reachability as part of Story 2.10 SC-2 / `INV-devbox-dind-available`'s Docker-Desktop-install prerequisite; not a Story 2.10 concern. **Alternatives considered + rejected:** (α) the devbox image itself (`keel-devbox:local`) — rejected because the devbox image is ~848 MB and the probe runs every invocation; (β) `busybox` — rejected because `test -e` semantics differ subtly (busybox's `test` builtin vs util-linux); (γ) a pre-built alpine-with-test image in ghcr.io — rejected as over-engineering at 1.0. [Source: `INV-devbox-dind-available` § Backend contract; docker-compose.yml Story 2.1 socket-passthrough]

**SC-5 — Composite-message aggregation within Tier 2; Tier 1 fails fast.** AC 5 "surfaces the missing-item list as a single message" applies to the Tier 2 token-probe phase (Claude + gh) where both probes are independent and can run in sequence without cross-dependence. Docker-missing DOES break composite aggregation — if Docker is down, the volume probe cannot run, so Claude/gh status is unknown. The contract is: Tier 1 (Docker) fails fast with ONE pointer; Tier 2 (tokens) runs both probes + aggregates findings into ONE composite message. The user-experience sequence under fresh-fork first-run with nothing satisfied:
1. `pnpm ralph:build` → prereq-check Tier 1 fails → stderr: `docker unreachable ... install Docker Desktop: https://docs.docker.com/desktop/install/` → exit 8.
2. Operator installs Docker Desktop → re-runs `pnpm ralph:build` → prereq-check Tier 1 passes → Tier 2 probes volume → volume does not exist yet → aggregate both tokens missing → stderr: `Claude Code not authed — run 'pnpm claude' first\ngh CLI not authed — run 'pnpm gh:auth' first` → exit 2.
3. Operator runs `pnpm devbox:start` (container comes up; named volume auto-inits) → `pnpm claude` (OAuth flow) → `pnpm gh:auth` (OAuth flow) → re-runs `pnpm ralph:build` → prereq-check passes silently → Ralph TUI attaches.

Under step-wise recovery where the operator fixes Docker but runs `pnpm ralph:build` before running `pnpm devbox:start`, the volume may not exist yet → Tier 2 probes fail with both-missing message. Operator must run `pnpm devbox:start` to auto-init the volume before `pnpm claude` can write its token. [Source: AC 5; Story 2.5 § Named volume auto-init]

**SC-6 — Exit-code schema extends Story 2.6's uniform schema with one new code.** Story 2.10 uses `0` (pass), `2` (missing tokens; reuses Story 2.6 env-check's `2` semantic "missing/shape violation"), `8` (docker unreachable; reuses Story 2.6 universal code), `12` (other docker-daemon error). No NEW exit codes at 1.0. Tier-specific code `9` (Ralph-wrapper container not running) remains Story 2.7's concern and runs AFTER prereq-check; prereq-check itself does not emit `9`. Ralph-wrapper codes `10` (image not built) and `11` (healthcheck timeout) similarly remain Story 2.7's post-prereq-check concerns. The minimal schema extension keeps operator surface small + matches the iter-199 SC-5 "inherit not extend" discipline. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-5; 2-7 SC-5; 2-8 SC-5; 2-9 SC-5]

**SC-7 — Probe image pinned at `alpine:3.19`; manually version-tracked at 1.0 (Renovate regex-manager deferred).** See SC-4 rationale. The exact string `alpine:3.19` appears in: (a) `prereq-check.sh` source (Task 1); (b) `docs/invariants/devbox-prereq-check.md § Alpine probe image` section (Task 5); (c) `packages/devbox/README.md § Prerequisite check` reference (Task 6). **Renovate coverage at 1.0.** Story 1.15's Renovate config at `.github/renovate.json` uses the default `docker` manager fileMatch, which scans Dockerfile + docker-compose.yml ONLY — shell-script image references are NOT auto-discovered. Story 2.10's `alpine:3.19` ref in `prereq-check.sh` is therefore MANUALLY version-tracked at 1.0. A future substrate-polish pass MAY add a `customManagers` (regex-manager) entry to `.github/renovate.json` matching `*.sh` files with an image-reference pattern (e.g., `PROBE_IMAGE="alpine:<version>"`), or operators may inline a `# renovate: datasource=docker depName=alpine` hint comment above the `PROBE_IMAGE` assignment once the regex-manager lands. Deferred as an FR44 AMEND trajectory item, not a Story 2.10 scope. **Drift-detection at 1.0.** The three sites (source, doc, README) must update in a single commit; sync-gate (Story 1.9) catches `docs/invariants/devbox-prereq-check.md` edits that skip manifest `contentHash` re-computation. The source + README sites are NOT sync-gate-enforced — operators manage these by convention (single-commit discipline; CR Acceptance Auditor catches straggler drifts). [Source: `.github/renovate.json` Story 1.15 baseline; Story 1.9 sync-gate]

**SC-8 — `unset COMPOSE_PROJECT_NAME` at top of prereq-check.sh.** Story 2.6 AI-8 (iter-212) + AI-12 (iter-217) + Stories 2.7/2.8/2.9 SC-10/SC-8/SC-8 defensive-posture precedent. Protects `keel-devbox_keel_home_dev` named-volume identity — a compose-project override would redirect the volume path away from `INV-devbox-homedev-named-volume`. Cost is 1 line; benefit is uniform substrate posture. [Source: Story 2.6 iter-212 AI-8 + iter-217 AI-12]

**SC-9 — No signal trapping on prereq-check.sh.** The script runs host-side-only (no `docker exec` inside; the alpine probe IS a `docker run` but the wrapper does not hold it open for interactive I/O). Signals would propagate to the alpine probe naturally via `docker run`'s own forwarding. Defensive trap handlers would have no effect under prereq-check's short-lived-synchronous-probe model. Follows Story 2.1 iter-144 SIGPIPE + Stories 2.7/2.8/2.9 SC-10 "no-signal-trap" posture.

**SC-10 — Container name / volume name derivation via env-var fallback.** Story 2.2 parameterised container + compose-project names via `.envrc`. Story 2.10's `VOLUME_NAME` derives from `KEEL_DEVBOX_COMPOSE_PROJECT` fallback (default `keel-devbox`) — the docker-compose-default volume-name scheme is `<project>_<volume-key>` (i.e. `keel-devbox_keel_home_dev`; verified via docker-compose.yml:170-171 + iter-212 AI-8 fix). Multi-fork / worktree operators who override `KEEL_DEVBOX_COMPOSE_PROJECT` get their scoped volume name automatically. [Source: Story 2.2 envrc parameterisation; docker-compose.yml:170-171 Story 2.5 named-volume]

**SC-11 — Wire-in to all 17 existing host-side shims is load-bearing for AC 5.** AC 5 "any `pnpm devbox:*` or `pnpm ralph:*` command" scopes the prereq-check to every verb. Task 4 wires Tier 1 into 15 shims (excluding prereq-check.sh itself); Task 3 wires Tier 2 into the 2 ralph verbs. TOTAL: 17 shims touched in Story 2.10. **Dev-agent guardrail:** when modifying each shim with an inline `docker info --format '{{.ServerVersion}}' ...` block (14 of the 15 Task-4 shims at 2026-04-23 verified — all except `restart.sh` + `env-check.sh`), REMOVE the 3–4-line block and REPLACE with a single `"$(dirname "${BASH_SOURCE[0]}")/prereq-check.sh" --tier1` invocation (1 line). For `restart.sh` (transitive-delegate, no inline block; see Task 4 special case) + `env-check.sh` (NO existing docker info; new gate — see Task 4 env-check.sh clause), PREPEND ONLY; no block-removal step. Net: 14 shims decrease ~2-3 lines each (~35-line diff reduction across the shim family) + 3 shims gain 1 line each (restart.sh, env-check.sh, and the two ralph-*-host.sh shims under Task 3 where Tier 2 prepends with block-swap). PLUS prereq-check.sh itself (~150 lines new). Other shim logic (container-state check, `exec` line, args handling) is UNCHANGED. **Explicitly out-of-scope — `benchmark.sh` (2026-04-23 verified):** `packages/devbox/scripts/benchmark.sh` has its own inline `docker info >/dev/null 2>&1 || { ...; exit 127; }` block at L123 (command-not-found convention exit 127, NOT Story 2.6 uniform exit 8). Story 2.10 does NOT touch benchmark.sh because: (a) it is NOT wired as a `pnpm devbox:*` verb (invoked manually as `bash packages/devbox/scripts/benchmark.sh`), so AC 5 does not apply; (b) its exit-127 semantic is load-bearing to the NFR2 benchmark contract (operators expect `127 = no-docker-available` distinction from `8 = daemon-unreachable`); reconciling to uniform exit 8 would require cross-coordination with NFR2 consumers (CI benchmark harness, operator runbooks) and belongs to a dedicated FR44 AMEND, not Story 2.10. Dev-agent MUST NOT add `prereq-check.sh` to benchmark.sh. [Source: § Project Structure Notes; Tasks 3 + 4; `packages/devbox/scripts/benchmark.sh:123`]

**SC-12 — `_lib.sh` refactor trajectory advances but does NOT complete in Story 2.10.** Story 2.6 AR-19 flagged library-extraction across 8 scripts; Story 2.7 SC-14 deferred at 15 shims; Story 2.8 SC-14 deferred at 16; Story 2.9 SC-14 deferred at 17 + CR iter-244 AR-60..AR-70 re-raised 11 substrate-wide items pointing at post-Epic-2 `_lib.sh` amortization. Story 2.10's `prereq-check.sh` is a NEW shared primitive (not a refactor of existing inline blocks into `_lib.sh`) — it replaces one specific concern (the `docker info` check + adds token probes + emits pointers) with a single orchestrator. Other inline duplications (container-state inspect, `log()` function definitions, `CONTAINER_NAME` fallback, `unset COMPOSE_PROJECT_NAME`) REMAIN duplicated per shim — their `_lib.sh` extraction is still deferred to post-Epic-2. Story 2.10 is the **first story in the `_lib.sh` refactor trajectory** where a shared primitive lands as a standalone file (iter-239's `lib/main-repo-resolver.sh` + `lib/check-mount-source.sh` were retrofits, not story-scoped; Story 2.10 is the first story-scoped lift). Dev-agent guardrail: do NOT extract additional helpers (container-state inspect, log fn) as part of Story 2.10 — scope-creep. [Source: Story 2.6 AR-19; Story 2.9 § Review Findings AR-60..AR-70; iter-239 retrofit precedent]

**SC-13 — No compose / Dockerfile / entrypoint.sh edits in Story 2.10.** The prereq-check is a host-side orchestration primitive. It does NOT require container-internal support — the alpine probe is a standalone `docker run`. No compose volume-mount addition, no Dockerfile placeholder, no entrypoint-hook. [Source: compose.yml + Dockerfile + entrypoint.sh unchanged]

**SC-14 — No Ralph (`ralph.py`) TUI changes in Story 2.10.** The TUI is Epic 3 scope. Story 2.10's prereq-check runs BEFORE `ralph.py` is reached (host-side wrapper `ralph-*-host.sh` calls prereq-check then `docker attach`). If Ralph's in-loop pre-push gate (Epic 3 Story 3.7) wants to run the prereq-check during a running iteration (e.g., to detect a revoked token mid-loop), that is a downstream consumer of the same primitive — Story 2.10 pins the contract (invariant + exit codes) so Epic 3 Story 3.7 can invoke without needing to re-invent the probe semantics. Cross-reference mirror: Story 2.9 SC-2's "halt-able handling owned by Epic 3 Story 3.7" pattern. [Source: Story 2.9 SC-2; `docs/invariants/ralph-execute.md` § Halt schema]

**SC-15 — No token-file content inspection; existence only.** Per SC-3, `prereq-check.sh` tests ONLY file existence. Post-probe the token files remain `claude`'s and `gh`'s property — their format, rotation, revocation semantics are upstream contract (Story 2.8 SC-15 + Story 2.9 SC-15 inheritance). Validity is verified at actual-invocation time by the respective CLIs and is out of Story 2.10's scope. [Source: Story 2.8 SC-15; Story 2.9 SC-15]

**SC-16 — `--help` not required at 1.0 (Story 2.6 AR-18 deferral applies).** `pnpm devbox:prereq:check --help` is consumed by pnpm before reaching the wrapper; operators must use `pnpm devbox:prereq:check -- --help` to reach prereq-check.sh's own help — which at 1.0 does not exist. Story 2.10 inherits the AR-18 deferral chain from Stories 2.6/2.7/2.8/2.9. Whenever AR-18 is picked up in a substrate-polish pass, prereq-check.sh joins the rollout. [Source: Story 2.9 SC-16]

**SC-17 — Task 6 + Task 5 append NEW sibling sections; do NOT modify existing story sections.** `packages/devbox/README.md` hosts H2s for Stories 2.6 + 2.7 + 2.8 + 2.9 (in that order); `AGENTS.md § Devbox iteration environment` hosts H3s for the same four stories. Story 2.10 appends a new H2 + H3 respectively, BETWEEN Story 2.9's sections and the next following top-level section (README `## cc-devbox upstream provenance`; AGENTS top-level `## Ralph loop`). **The existing Story 2.6 + 2.7 + 2.8 + 2.9 sections are READ-ONLY for Story 2.10.** Any observed drift in those sections is an FR44 AMEND path, not a Story 2.10 change. This SC closes the scope-creep vector inherited from Stories 2.7 PATCH 4 / 2.8 SC-17 / 2.9 SC-17. [Source: Story 2.9 SC-17]

### File placement + pnpm wiring

**New files (2):**
- `packages/devbox/scripts/prereq-check.sh` — host-side primitive (standalone invocation + library for 17 shim wire-ins).
- `docs/invariants/devbox-prereq-check.md` — `INV-devbox-prereq-check` authoritative contract doc (hashed into manifest `contentHash`).

**Modified files (21):**
- Root `package.json` — add `devbox:prereq:check` script entry.
- `packages/keel-invariants/src/invariants.manifest.ts` — register `INV-devbox-prereq-check` entry (6-line manifest block; 29 → 30 entries at 2026-04-23 baseline; count reflects the full substrate manifest including Stories 1.3–1.15 tokens/release/renovate/prek/eslint/prettier/tsconfig/fork + Epic-2 devbox entries + ralph-halt entries, NOT only devbox entries).
- `INVARIANTS.md` — add one anchor bullet under § devbox section.
- `packages/devbox/README.md` — append `## Prerequisite check (Story 2.10)` H2 sibling.
- `AGENTS.md` — append `### Prerequisite check (Story 2.10)` H3 sibling.
- 15 existing host-side shims under `packages/devbox/scripts/` — each gets the 4-line inline `docker info` block REPLACED with a 1-line `prereq-check.sh --tier1` call:
  - `build.sh`, `rebuild.sh`, `start.sh`, `stop.sh`, `restart.sh`, `clean.sh`, `shell.sh`, `attach.sh`, `status.sh`, `logs.sh`, `monitor-host.sh`, `whitelist-host.sh`, `env-check.sh` (13 Story 2.6 verbs), `claude-host.sh` (Story 2.8), `gh-auth-host.sh` (Story 2.9).
- 2 ralph shims — each gets the inline `docker info` block REPLACED with `prereq-check.sh --tier2`:
  - `ralph-build-host.sh`, `ralph-plan-host.sh`.

**Unchanged (critical — do NOT touch):**
- `packages/devbox/docker-compose.yml` (Story 2.1/2.5 substrate — SC-13 NO compose edits).
- `packages/devbox/Dockerfile` (Story 2.1/2.5 substrate — SC-13 NO Dockerfile edits).
- `packages/devbox/entrypoint.sh` (Story 2.3 substrate).
- `packages/devbox/whitelist.default.txt`, `packages/devbox/whitelist/*.txt` (Story 2.3/2.4 substrate — alpine:3.19 image pull covered by `*.docker.io` baseline; no new egress entries at 1.0 — verify at impl time).
- `packages/devbox/tui/theme.py` (Story 1.12 artifact; not relevant).
- `ralph.py` at repo root (Epic 3 scope; Story 2.10 does NOT touch).
- `packages/devbox/scripts/lib/*.sh` (iter-239 retrofit helpers; Story 2.10 does NOT modify them; `prereq-check.sh` is a sibling under `scripts/` NOT a member of `scripts/lib/`).
- Story 2.8's `claude-host.sh` body beyond the inline `docker info` swap, Story 2.9's `gh-auth-host.sh` body beyond the inline `docker info` swap, Story 2.7's `ralph-*-host.sh` bodies beyond the inline `docker info` swap — SC-11 limits Story 2.10's edits to the pre-flight line ONLY; all other shim logic is untouched.

### Shim structure template (applies to prereq-check.sh)

```bash
#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# packages/devbox/scripts/prereq-check.sh — Story 2.10
#
# FR5 prerequisite check: Docker runtime + Claude Code auth + gh auth.
# Runs on every host-side shim invocation (`pnpm devbox:*`, `pnpm ralph:*`)
# at pre-flight + as a standalone verb (`pnpm devbox:prereq:check`). Fails
# fast with pointer-error stderr messages if any of the three prerequisites
# is missing, so Ralph cannot execute autonomously in a broken environment.
#
# Tiers:
#   --tier1  Docker runtime only (used by every `pnpm devbox:*` shim + by
#            `pnpm claude` + `pnpm gh:auth` to keep auth-establishing verbs
#            usable even with no tokens present).
#   --tier2  Docker + Claude + gh (default; used by `pnpm ralph:build` +
#            `pnpm ralph:plan` + standalone invocation).
#
# Exit codes (Story 2.6 uniform schema, extended):
#   0   all checks pass (silent).
#   2   one or more tokens missing (composite pointer list emitted, Claude
#       before gh; AC 5 + SC-5 no-partial-bypass; tier2 only).
#   8   docker runtime unreachable (install-pointer emitted:
#       https://docs.docker.com/desktop/install/; tier1 + tier2).
#   12  other docker-daemon error (volume-inspect crash, alpine pull
#       failure under fail-closed egress; propagated via docker's exit).
# ---------------------------------------------------------------------------
set -euo pipefail
unset COMPOSE_PROJECT_NAME

VOLUME_NAME="${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}_keel_home_dev"
PROBE_IMAGE="alpine:3.19"  # SC-7 pin; Renovate docker manager tracked

log() { printf '[prereq-check] %s\n' "$*" >&2; }

# Arg parsing — accept --tier1 or --tier2 (default --tier2).
tier="tier2"
case "${1:-}" in
  --tier1) tier="tier1" ;;
  --tier2|"") tier="tier2" ;;
  *) log "usage: $(basename "$0") [--tier1|--tier2]"; exit 2 ;;
esac

# -------- Tier 1: Docker runtime reachable --------
if ! docker info --format '{{.ServerVersion}}' >/dev/null 2>&1; then
  log "docker unreachable — is the daemon running?"
  log "install Docker Desktop: https://docs.docker.com/desktop/install/"
  exit 8
fi

if [[ "${tier}" == "tier1" ]]; then
  exit 0
fi

# -------- Tier 2: Claude + gh tokens --------

# If the named volume does not exist (fresh-fork pre-`pnpm devbox:start`),
# treat as both tokens missing — probe-container mount would auto-create
# the volume, which is an unwanted side-effect.
volume_present=0
if docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1; then
  volume_present=1
fi

claude_present=0
gh_present=0

if [[ "${volume_present}" -eq 1 ]]; then
  if docker run --rm -v "${VOLUME_NAME}":/vol:ro "${PROBE_IMAGE}" \
        test -e /vol/.claude/.credentials.json >/dev/null 2>&1; then
    claude_present=1
  fi
  if docker run --rm -v "${VOLUME_NAME}":/vol:ro "${PROBE_IMAGE}" \
        test -e /vol/.config/gh/hosts.yml >/dev/null 2>&1; then
    gh_present=1
  fi
fi

missing=0
if [[ "${claude_present}" -eq 0 ]]; then
  log "Claude Code not authed — run 'pnpm claude' first"
  missing=1
fi
if [[ "${gh_present}" -eq 0 ]]; then
  log "gh CLI not authed — run 'pnpm gh:auth' first"
  missing=1
fi

if [[ "${missing}" -eq 1 ]]; then
  exit 2
fi

exit 0
```

Structural ancestors: env-check.sh (Story 2.6; validator pattern + `log()` + exit-code emission) + reload-egress.sh (Story 2.3; host-side primitive pattern + `unset COMPOSE_PROJECT_NAME` + standalone-orchestrator shape).

### Three-check contract narrative (AC 1 + AC 2 + AC 3 + AC 4 + AC 5 anchor)

The three checks run in dependency order: Docker → Claude → gh. Docker is prerequisite-of-prerequisites (token probes need `docker run`); Claude precedes gh only by listing order (Story 2.8 landed before Story 2.9; the composite pointer-list preserves that order per SC-5).

**Tier-contract enumeration** (normative; mirrors the `docs/invariants/devbox-prereq-check.md § Tier contract` section for `contentHash` binding):

| Shim                        | Tier   | Rationale                                                |
| --------------------------- | ------ | -------------------------------------------------------- |
| `build.sh`                  | tier1  | Docker needed; image not yet built; no tokens required.  |
| `rebuild.sh`                | tier1  | Same.                                                    |
| `start.sh`                  | tier1  | Volume auto-inits here; tokens not required.             |
| `stop.sh`                   | tier1  | Container mgmt; tokens not required.                     |
| `restart.sh`                | tier1  | Container mgmt; tokens not required.                     |
| `clean.sh`                  | tier1  | Destroys state; tokens not required.                     |
| `shell.sh`                  | tier1  | Interactive shell; tokens not required for shell entry.  |
| `attach.sh`                 | tier1  | Attach to PID 1; tokens not required.                    |
| `status.sh`                 | tier1  | Read-only state inspect.                                 |
| `logs.sh`                   | tier1  | Read-only log tail.                                      |
| `monitor-host.sh`           | tier1  | Read-only DNS-event tail.                                |
| `whitelist-host.sh`         | tier1  | Local-whitelist mgmt; tokens not required.               |
| `env-check.sh`              | tier1  | `.envrc` var validator; tokens not required.             |
| `claude-host.sh`            | tier1  | Auth-establishing verb — tokens would be circular.       |
| `gh-auth-host.sh`           | tier1  | Auth-establishing verb — tokens would be circular.       |
| `ralph-build-host.sh`       | tier2  | Ralph needs all three to run autonomously (FR5).         |
| `ralph-plan-host.sh`        | tier2  | Same.                                                    |
| `prereq-check.sh`           | —      | Invokes itself recursively is NOT supported; it IS the primitive. |

### Testing Standards

**ATDD skip (FR14n matrix row 3 — TWENTIETH cumulative precedent forecast).** Story 2.10 inherits the FR14n three-ground conjunction with ground-(a) + ground-(c) as the load-bearing grounds (ground-(b) "no test runner" remains true at Story 2.10 landing per Story 1.16 deferral):

- **Ground (a) — Substrate-verification covers AC 1 + AC 5 composite-message surface at iteration-env-safe layer.** Task 7 smoke tests (SEE Task 7 sub-bullets in Tasks/Subtasks above — to be authored as part of dev-story impl task) exercise: stub-docker Tier 1 fail (docker info returns non-zero → exit 8 + verbatim install-URL log); stub-docker Tier 1 pass + volume-absent (Tier 2 runs, both tokens missing, composite stderr surface captured verbatim); stub-docker Tier 1 pass + volume-present + both files present (exit 0 silent); stub-docker Tier 1 pass + volume-present + Claude-only present (gh-missing pointer emitted; exit 2); stub-docker Tier 1 pass + volume-present + gh-only present (Claude-missing pointer emitted; exit 2); argument parsing for `--tier1` / `--tier2` / unknown-arg → exit 2.
- **Ground (b) — No test runner wired at substrate level yet.** Story 1.16 delivers the runner; bare "no runner" is insufficient per Story 1.8 guardrail — combined with (a) + (c) per three-ground conjunction.
- **Ground (c) — External-service-owns-behavior-under-test for AC 1 Docker-reachability behavior + AC 2/3 token-presence-in-named-volume behavior.** AC 1's "Docker runtime reachable" is owned by Docker Desktop / Docker Engine (host-side external service; not part of the devbox-in-container environment). AC 2/3's "token present in named volume" is owned by Stories 2.8 / 2.9 OAuth flows (already verified at Story 2.8 iter-230 + Story 2.9 iter-237 live operator-workstation smokes) + Docker named-volume persistence (Story 2.5 substrate; already verified). Story 2.10's wrapper verifies ONLY: (i) the probe invocation envelope (stub-docker asserts `docker volume inspect`, `docker run --rm -v <vol>:/vol:ro alpine:3.19 test -e <path>` are the exact invocations); (ii) the exit-code + stderr-message surface is AC-verbatim; (iii) the tier-dispatch branches correctly. Full AC 1 + AC 2 + AC 3 + AC 4 + AC 5 live verification requires (α) a live Docker Desktop install + fresh-fork state, (β) operator's live `pnpm claude` + `pnpm gh:auth` OAuth flows, (γ) a host browser. cc-devbox backend-B (iteration env) covers the stub-docker envelope; operator-workstation covers the live-flow end-to-end.

**Trace WAIVED expected at `/bmad-testarch-trace` gate.** 5 ACs total: ACs 1/2/3/4/5 all substrate-smoked at wrapper envelope + external-service-owned at behavior level. Deterministic coverage: ~1/5 = 20% automated (wrapper envelope only); ~4/5 = 80% external-owned (Docker + Stories 2.8/2.9 OAuth + Story 2.5 named-volume + Epic 3 Story 3.7 halt-able extension). Trace verdict: WAIVED with rationale "Story 2.10 wrapper envelope substrate-smoked; three-check behaviors owned by Docker Desktop + Stories 2.8/2.9 OAuth substrate + Story 2.5 named-volume substrate; Epic 3 Story 3.7 owns halt-able consumer contract; operator-workstation smoke covers live composite flow." Following the Story 2.9 iter-242 WAIVED precedent; this is the **TWENTIETH cumulative trace-WAIVED precedent forecast**.

**CR adversarial backstop applies.** The `/bmad-code-review (args: "2")` Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out exercises ACs at the design-contract layer (tier-dispatch correctness; composite-message ordering; exit-code schema non-regression; volume-probe side-effect freedom under `docker run --rm`; SC-11 17-shim wire-in coverage completeness; SC-12 scope-creep absence). Story 2.10 CR forecast: **0–3 PATCH opener** (novel surface vs Story 2.9: the 17-shim refactor is NEW — first multi-shim-edit story in Epic 2; `prereq-check.sh` is first non-`<verb>-host.sh` host-side primitive; INV-devbox-prereq-check is first new manifest entry in Epic 2). Dense SC pinning (17 SCs at draft time — matches Stories 2.7/2.8/2.9 post-PATCH density) follows the iter-219/226/233/244 LESSON forecast band "≥2 PATCHes pre-dev SM → candidate for one-pass ZERO-PATCH CR" — Story 2.10 is candidate for FIFTH cumulative one-pass ZERO-PATCH precedent if the pattern holds under novel multi-shim-edit surface.

**Live flow operator-workstation-deferred.** AC 1's install-URL pointer (`https://docs.docker.com/desktop/install/`) is a docs URL; verification is "string appears in stderr verbatim," covered by stub-docker smokes. AC 2/3's token-present-in-volume verification requires live OAuth flows on operator workstation — deferred per Story 2.8 iter-230 + Story 2.9 iter-237 precedent cluster. AC 4 silent-pass is verified by stub-docker smoke with both probes returning 0. AC 5 composite message is verified by the fresh-fork-smoke (stub-docker + volume-absent branch).

### Substrate contracts preserved (do NOT modify)

Story 2.10 composes on top of the following substrate contracts. Any change to these is OUT OF SCOPE for Story 2.10 and requires a dedicated FR44 AMEND path:

- **Story 2.1 substrate** — `packages/devbox/Dockerfile`, `packages/devbox/docker-compose.yml` base shape, `/usr/local/bin/entrypoint.sh`, `CMD: ["sleep", "infinity"]`.
- **Story 2.2 substrate** — `.envrc` parameterization including `KEEL_DEVBOX_CONTAINER_NAME` + `KEEL_DEVBOX_COMPOSE_PROJECT` (volume-name derivation).
- **Story 2.3 substrate** — Egress whitelist; alpine probe-image pull covered by `*.docker.io` entry (verify at impl time).
- **Story 2.4 substrate** — Whitelist source-of-truth; no modifications.
- **Story 2.5 substrate** — Non-root `dev` user + `keel_home_dev` named volume at `/home/dev` + `INV-devbox-homedev-named-volume`; Story 2.10 PROBES the volume (read-only mount; no mutation).
- **Story 2.6 substrate** — 13 devbox verbs + uniform exit-code schema; Story 2.10 EXTENDS by wiring Tier 1 into each shim; existing shim bodies are edited minimally (1 block swap per shim).
- **Story 2.7 substrate** — Ralph auto-start pattern; Story 2.10 ADDS Tier 2 pre-flight BEFORE the auto-start block in each ralph-*-host.sh.
- **Story 2.8 substrate** — `claude-host.sh` + `/home/dev/.claude/.credentials.json` post-OAuth token path; Story 2.10 probes existence of this file (SC-3).
- **Story 2.9 substrate** — `gh-auth-host.sh` + `/home/dev/.config/gh/hosts.yml` post-OAuth token path; Story 2.10 probes existence of this file (SC-3).
- **Story 1.9 substrate** — sync-gate + `InvariantSchema` five-field contract; Story 2.10 ADDS `INV-devbox-prereq-check` entry conforming to the schema; `contentHash` binds `docs/invariants/devbox-prereq-check.md` content.
- **Story 1.12/1.13 substrate** — design-token + theme generation; not touched.
- **Story 1.15 substrate** — Renovate `docker` manager tracking for `alpine:3.19` image pin per SC-7.
- **Epic 3 Story 3.7 future consumer** — pre-push-gate halt-write consuming `INV-devbox-prereq-check` contract; Story 2.10 pins the contract only, does not implement.

### Project Structure Notes

**Alignment with architecture.md scripts tree (lines 991-1004):** The architecture tree enumerates a subset of scripts under `packages/devbox/scripts/` without full bottom-to-top coverage. At Story 2.10 draft time (2026-04-23), the directory holds 23 scripts (Story 2.9 landing: 17 host-side shims + 6 Story 2.3/2.4 in-container primitives). Story 2.10 adds 1 more host-side primitive (`prereq-check.sh`, NOT a `<verb>-host.sh`), bringing the directory to 24 + the host-side-shim subset to 18 when the new primitive is counted. Architecture tree does NOT explicitly enumerate `prereq-check.sh` — this is an epics-vs-architecture scope extension, not drift (Story 2.6 iter-201 + Story 2.7 iter-223 + Story 2.8 iter-230 + Story 2.9 iter-242 precedent chain).

**Alignment with `docs/invariants/` folder:** Story 2.10 adds `docs/invariants/devbox-prereq-check.md` alongside the existing `devbox-dind.md`, `devbox-egress.md`, `devbox-hardening.md`. Naming convention matches prior entries (`devbox-<kebab-case-concern>.md`).

**Variance with `INVARIANTS.md`:** Story 2.10 adds ONE new anchor bullet under the devbox section (after `INV-devbox-homedev-named-volume`). Story 1.9 sync-gate will drift-detect any further anchor-changes in the same commit.

**No invariants.manifest.ts refactor:** Story 2.10 adds ONE manifest entry (29 → 30 entries at 2026-04-23 baseline — counts the full substrate manifest, not only devbox entries). The existing entries are UNCHANGED. Schema (`InvariantSchema`) is UNCHANGED — Story 2.10 conforms; any schema evolution (adding optional fields) is a separate FR44 AMEND.

### Previous-story intelligence (Stories 2.8 iter-233 + 2.9 iter-244 one-pass ZERO-PATCH CR closure)

Stories 2.8 (iter-233) + 2.9 (iter-244) are the THIRD + FOURTH cumulative one-pass ZERO-PATCH CR closure precedents in the project (chain: Story 1.13 iter-85 → 2.7 iter-226 → 2.8 iter-233 → 2.9 iter-244). The pattern is now crystallized: dense pre-dev SM PATCHes (≥2) → verbatim spec-template implementation → ATDD skip + trace WAIVED → post-dev SM ZERO-PATCH → CR ZERO-PATCH one-pass.

**LESSON carry-forward for Story 2.10 (chain Story 2.8 + 2.9 → forecast Story 2.10):** Dense pre-dev SM PATCHes → verbatim spec-template implementation → reliable one-pass ZERO-PATCH CR closure. Story 2.10 ships 17 SCs at draft time (matching Stories 2.7/2.8/2.9 post-PATCH 17-SC density). Story 2.10's pre-dev SM review at `/bmad-create-story (args: "review")` gate is the critical upstream for one-pass CR outcome — if SM PATCH density falls below 2, SM review is under-engaged relative to the pattern. Forecast: 2–5 PATCHes at SM gate — wider band than Stories 2.8/2.9 because Story 2.10 has NOVEL substrate-interaction surfaces:
- **Multi-shim refactor** (SC-11: 17 shims touched) — first such story in Epic 2. Pre-dev SM may surface drift about scope (which shims; which blocks; what if a shim already edited by iter-239 retrofit has divergent inline docker-info block).
- **First new `INV-*` manifest entry in Epic 2** (SC-12 context: iter-239 retrofit extracted two `lib/` files but did NOT add a manifest entry; Story 2.10 IS the first Epic 2 story-scoped manifest extension).
- **Alpine probe image pin** (SC-4 + SC-7) — first story using a Docker image as a runtime probe dependency; Renovate wiring + whitelist-entry coverage need cross-verification.
- **Tier dispatch semantics** — first story with a multi-tier argument surface in a host-side shim.

**LESSON carry-forward on substrate-citation drift pattern:** Story 2.9 iter-243 surfaced 13 substrate-file line-number drifts (all from iter-238..241 retrofits) at post-dev SM gate. Story 2.10 will accumulate MORE such drift as Stories 2.11..2.17 land more changes on the same branch. Resolution policy: defer line-number reconciliation to Story 2.17 Epic 2 close-out per SC-17 polish convention. Apply two-subagent verification pattern (iter-235 LESSON) at post-dev SM gate — source-file + planning-artefact subagents in parallel returning VERIFIED / DRIFTED / MISSING verdicts.

**LESSON carry-forward on stub-docker harness (Story 2.7 iter-223 + 2.8 iter-230 + 2.9 iter-237):** workspace-based `<workspace>/.ralph-smoke/shim/` NOT `/tmp/` (tmpfs noexec); explicit `rm -rf .ralph-smoke/` in final assertion call NOT EXIT trap in setup (each Bash tool call is separate shell). Applies to Story 2.10's prereq-check.sh smokes (Tier 1 fail / Tier 1 pass+volume-absent / Tier 1 pass+Claude-only / Tier 1 pass+gh-only / Tier 1 pass+both-present / arg-parsing).

**LESSON carry-forward on ground-(c) external-service variant:** Stories 2.8/2.9 ground-(c) variant "external-service-owns-behavior-under-test" applied to OAuth flows (Anthropic + GitHub endpoints). Story 2.10 re-applies with a DIFFERENT external service (Docker Desktop's install URL + volume-persistence behavior) — the abstraction holds. Story 2.10 is the FIRST non-OAuth ground-(c) application in Epic 2.

### Git intelligence (recent substrate history)

Recent commits (last 5 on `feat/epic-2-packaged-devbox`):
1. `930b912 docs(story-2-9): iter-244 — CR closure ZERO-PATCH one-pass, sm-verified → done, 4th cumulative precedent` — Story 2.9 CR closed.
2. `8c3bdb8 docs(story-2-9): iter-243 — post-dev SM ZERO-PATCH, traced → sm-verified, 4th one-pass candidate` — Story 2.9 post-dev SM ZERO-PATCH.
3. `d9a7151 docs(story-2-9): iter-242 — trace gate WAIVED, in-dev → traced, 19th cumulative precedent` — Story 2.9 trace gate.
4. `034777c feat(devbox): mirror host repo paths inside container — /workspace/<repo>` — iter-240 retrofit (path mirroring).
5. `5ee7249 fix(devbox): make pnpm ralph:build/plan launch ralph.py TUI in container` — iter-241 retrofit.

**Actionable pattern extraction:**
- Commit scope `docs(story-2-N)` for lifecycle iters; `feat(devbox)` for impl + infrastructure retrofits; `fix(devbox)` for defect-fixing retrofits.
- Iteration numbers monotonically increase across story boundaries — Story 2.9 spanned iter-234..244; Story 2.10 begins iter-245.
- One lifecycle gate per iter + commit — matches Ralph guardrail 5.
- Infrastructure retrofits (iter-238..241) have been landing on the Epic 2 branch orthogonally to story lifecycle; Story 2.10 may see similar retrofits if any prereq-check implementation surprise surfaces (e.g., alpine pull failure under a misconfigured egress baseline).

### References

- Source story AC: [Source: _bmad-output/planning-artifacts/epics.md:1477-1511]
- FR5 verbatim: [Source: _bmad-output/planning-artifacts/prd.md:931]
- Epic 2 objective statement + cross-story dependencies: [Source: _bmad-output/planning-artifacts/epics.md:1142-1168]
- FR1 non-toggle-able pnpm surface (applies to Story 2.10): [Source: _bmad-output/planning-artifacts/architecture.md:74]
- `pnpm devbox:prereq:check` naming pattern (matches `devbox:env:check` colon form): [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-2]
- One-time auth prerequisites (Claude + gh token paths): [Source: _bmad-output/planning-artifacts/architecture.md:75, :335, :1239]
- `pnpm devbox:env:check` validator existing pattern: [Source: packages/devbox/scripts/env-check.sh:1-80+; architecture.md:1004, :1198]
- Named volume `keel_home_dev` at `/home/dev`: [Source: packages/devbox/docker-compose.yml:170-171; Story 2.5 § Dev Notes named-volume contract; `INV-devbox-homedev-named-volume`]
- Claude Code OAuth token path: [Source: packages/devbox/scripts/claude-host.sh Story 2.8 substrate; `/home/dev/.claude/.credentials.json`]
- gh OAuth token path: [Source: packages/devbox/scripts/gh-auth-host.sh Story 2.9 substrate; `/home/dev/.config/gh/hosts.yml`]
- Docker Desktop install URL: [Source: https://docs.docker.com/desktop/install/ — Docker-owned canonical docs; verified 2026-04-23; hardcoded at prereq-check.sh + devbox-prereq-check.md]
- INV-devbox-dind-available (Docker prereq): [Source: INVARIANTS.md line 94; docs/invariants/devbox-dind.md]
- INV-devbox-egress-contract (alpine pull reachability): [Source: INVARIANTS.md line 100; docs/invariants/devbox-egress.md]
- INV-devbox-homedev-named-volume (volume-probe substrate): [Source: INVARIANTS.md line 106; docs/invariants/devbox-hardening.md]
- INV-ralph-halt-reason-enum (Epic 3 consumer contract for CI_BLOCKED halt): [Source: INVARIANTS.md; packages/keel-invariants/src/invariants.manifest.ts]
- Closed halt-reason enum (CI_BLOCKED reason for Epic 3 halt consumer): [Source: docs/invariants/ralph-execute.md § Halt schema; AGENTS.md § Ralph loop § Halt autonomy guardrail; _bmad-output/planning-artifacts/prd.md FR14k]
- Story 2.6 uniform exit-code schema: [Source: _bmad-output/implementation-artifacts/2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-5]
- Story 2.7 ralph-*-host.sh auto-start posture: [Source: _bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md § Dev Notes SC-1]
- Story 2.8 SC-15 token-file-inspect carve-out: [Source: _bmad-output/implementation-artifacts/2-8-claude-code-oauth-via-pnpm-claude.md § Dev Notes SC-15]
- Story 2.9 SC-15 token-file-inspect carve-out: [Source: _bmad-output/implementation-artifacts/2-9-gh-cli-oauth-via-pnpm-gh-auth.md § Dev Notes SC-15]
- Story 2.9 SC-17 read-only-on-prior-story-sections: [Source: _bmad-output/implementation-artifacts/2-9-gh-cli-oauth-via-pnpm-gh-auth.md § Dev Notes SC-17]
- Story 2.3 iter-156 multi-faceted-invariant-doc LESSON: [Source: RALPH.md § Decisions 2026-04-21 iter-156]
- Story 1.9 sync-gate + InvariantSchema 5-field compliance: [Source: packages/keel-invariants/src/invariants.manifest.ts:3-15; `/^-\s+\*\*\`([A-Z][A-Z0-9-]+)\`\*\*/gm` anchor regex]
- Story 1.15 Renovate `docker` manager for image pin tracking: [Source: _bmad-output/implementation-artifacts/1-15-renovate-config-with-version-pinning-rules-i7.md]

## Dev Agent Record

### Agent Model Used

claude-opus-4-7[1m] (Claude Opus 4.7, 1M-token context window)

### Debug Log References

- **iter-248 `/bmad-dev-story` fresh-context invocation.** Story State `atdd-scaffolded → in-dev`; sprint-status flipped `ready-for-dev → in-progress` at dev-story Step 4, then `in-progress → review` at dev-story Step 9.
- **Stub-docker harness (workspace-based; torn down at iter end):** `<workspace>/.ralph-smoke/shim/docker` — argv-driven stub responding to `docker info` / `docker volume inspect` / `docker run … test -e …` keyed off `$KEEL_SMOKE_MODE`. Path prefix `<workspace>/.ralph-smoke/shim:/usr/bin:/bin`. NOT `/tmp/` (tmpfs noexec) per iter-223/230/237 LESSON. `rm -rf .ralph-smoke/` in final assertion call, NOT EXIT trap (each Bash tool call is separate shell).
- **9 stub-docker smoke scenarios all PASS:**
  1. Tier 1 + docker-down → exit 8 + verbatim install-URL `https://docs.docker.com/desktop/install/` (AC 1).
  2. Tier 1 + docker-up → exit 0 silent.
  3. Tier 2 + volume absent (fresh-fork first-run) → exit 2 + composite message with Claude-before-gh ordering (AC 5).
  4. Tier 2 + both tokens present → exit 0 silent (AC 4).
  5. Tier 2 + Claude-only present → exit 2 + gh-missing pointer only (AC 3 isolation).
  6. Tier 2 + gh-only present → exit 2 + Claude-missing pointer only (AC 2 isolation).
  7. No-arg default → Tier 2 behaviour (per SC-specified default).
  8. Unknown arg (`--bogus`) → usage message + exit 2.
  9. `pnpm run | grep devbox:prereq:check` → 1 match (Task 2 wiring smoke).
- **`pnpm keel-invariants:check` EXIT=0** after Task 5 landing (manifest 29 → 30 entries; `docs/invariants/devbox-prereq-check.md` contentHash `eb5b9db25e0afc77c4caf38c8bf60b37921a76df2ea030c91f66e848b0d8fe40`). `package.json` contentHash also bumped `d89072918e… → dc5ed31b8a…` as expected side-effect of the `devbox:prereq:check` pnpm script entry (INV-prek-prepare-lifecycle binds whole file content).
- **Shim `bash -n` parse check:** all 18 edited/new scripts parse cleanly (`OK — all 18 scripts parse`).

### Completion Notes List

- **Task 1** — `packages/devbox/scripts/prereq-check.sh` authored (~120 LOC) with the v1.2 spec-template structure verbatim: `set -euo pipefail`, `unset COMPOSE_PROJECT_NAME`, `VOLUME_NAME` derivation, `PROBE_IMAGE="alpine:3.19"` (SC-7), `log()` fn, arg-parse `--tier1`/`--tier2`/default/unknown, Tier 1 `docker info --format '{{.ServerVersion}}'` + install-URL, early-exit on Tier 1, volume-inspect + fresh-fork branch, read-only alpine probes for `/home/dev/.claude/.credentials.json` + `/home/dev/.config/gh/hosts.yml`, aggregate + Claude-before-gh emit, exit 2. `chmod +x` applied. Verbatim AC strings present.
- **Task 2** — Root `package.json` gained `"devbox:prereq:check": "./packages/devbox/scripts/prereq-check.sh"` between `devbox:env:check` and `ralph:build` (alphabetical within `devbox:*` group per Task 2 spec). `pnpm run` surface confirms entry.
- **Task 3** — Block-swap applied to `ralph-build-host.sh` + `ralph-plan-host.sh`: former `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log docker unreachable; exit 8; }` block replaced by `"${SCRIPT_DIR}/prereq-check.sh" --tier2`. Tier 2 propagates exit codes 8/2/12 before the auto-start + `docker attach` sequence. No other shim logic touched.
- **Task 4 — 13 block-swap** — `build.sh`, `rebuild.sh`, `start.sh`, `stop.sh`, `clean.sh`, `shell.sh`, `attach.sh`, `status.sh`, `logs.sh`, `monitor-host.sh`, `whitelist-host.sh`, `claude-host.sh`, `gh-auth-host.sh` each had their inline `docker info` block replaced by a single-line `"${SCRIPT_DIR}/prereq-check.sh" --tier1` call. `attach.sh` gained a new `SCRIPT_DIR` derivation (previously relied only on `CONTAINER_NAME`). `clean.sh`'s `detect_backend` helper retains its orthogonal `docker info --format '{{.Name}}'` call per the inline comment (reachability is prereq-check's; backend-identity is detect_backend's; no overlap).
- **Task 4 — 2 prepend-only** — `restart.sh` (no prior inline block; transitive delegate) and `env-check.sh` (NEW gate; env-check previously validated `.envrc` only) each gained a prepend-only `"${SCRIPT_DIR}/prereq-check.sh" --tier1` call. `restart.sh`'s L47 narrative comment about transitive coverage preserved unchanged.
- **Task 5** — `INV-devbox-prereq-check` registered in `packages/keel-invariants/src/invariants.manifest.ts` (30th entry; immediately after `INV-devbox-homedev-named-volume`; InvariantSchema five-field compliance — `id`/`description`/`sourcePath`/`contentHash`/`anchors`). Authoritative doc `docs/invariants/devbox-prereq-check.md` authored with 8 H2 sections (Three-check contract / Exit-code schema / Tier contract / No-partial-bypass / Fresh-fork first-run behavior / Alpine probe image / Consumption / Extension) so every sub-contract hashes into `contentHash` per Story 2.3 iter-156 LESSON. `INVARIANTS.md` anchor bullet added under new `### Devbox prerequisite check (Story 2.10)` H3 section between Devbox hardening (2.5) and Gitignored-secret commit-deny (2.2); verbatim regex compliant with `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` anchor shape per Story 1.9 sync-gate.
- **Task 6 — README** — `packages/devbox/README.md § Prerequisite check (Story 2.10)` appended as H2 sibling AFTER `## gh CLI authentication (Story 2.9)` and BEFORE `## cc-devbox upstream provenance`. Contents: quick-start invocation + three-check contract + tier contract table (4 rows) + fresh-fork first-run walkthrough (5 steps) + exit-code reference table (4 rows) + no-bypass posture + alpine probe image pin + cross-references to AGENTS.md / INV-devbox-prereq-check / Stories 2.6/2.8/2.9 / Story 2.10 spec file.
- **Task 6 — AGENTS.md** — `### Prerequisite check (Story 2.10)` appended as H3 sibling AFTER `### gh CLI authentication (Story 2.9)` under `## Devbox iteration environment`. Contents: canonical invocation via `pnpm devbox:prereq:check` (never direct `prereq-check.sh`); three-check contract + tier contract + exit-code schema; fail-mode guidance for agent fix-task queueing (exit 8 → Docker install; exit 2 Claude-missing → `pnpm claude`; exit 2 gh-missing → `pnpm gh:auth`; composite → `pnpm devbox:start` first); no-bypass posture; Epic 3 Story 3.7 halt-able `CI_BLOCKED` pointer; scope carve-out (Docker Desktop / OAuth / named volume owned upstream); cross-references. Prior Stories 2.6/2.7/2.8/2.9 sections NOT modified (SC-17).
- **ATDD skip carry-forward** — iter-247 applied FR14n matrix row 3 three-ground conjunction (ground-a substrate-smoke + ground-b no runner + ground-c external-service). Iter-248 dev-story populated Task 7-equivalent stub-docker smokes INLINE as part of impl verification (9/9 pass). No red-phase artefacts persisted; harness torn down at iter end per iter-223/230/237 LESSON.
- **Shim count at Story 2.10 close:** 18 host-side files under `packages/devbox/scripts/` (17 pre-Story-2.10 + `prereq-check.sh` new primitive) + 6 in-container primitives + 2 `lib/*.sh` retrofits = 26 total under `scripts/`. 17 shim wire-ins applied (15 block-swap + 2 prepend-only). `benchmark.sh` out-of-scope per SC-11 (exit-127 NFR2 contract preserved).
- **No novel RALPH.md lesson generated at impl time** — mechanical inheritance from Stories 2.6/2.8/2.9 confirmed across all 17 shim edits + the new primitive. The `prereq-check.sh` shared-primitive pattern IS the novel surface, but its architectural shape is already covered by Story 2.3/2.4 primitive precedent (`reload-egress.sh`, `whitelist.sh`) — signpost-only entry sufficient.

### File List

**New (2):**

- `packages/devbox/scripts/prereq-check.sh` — FR5 prerequisite-check primitive (Tier 1 + Tier 2; Docker / Claude / gh probes; no-bypass posture).
- `docs/invariants/devbox-prereq-check.md` — `INV-devbox-prereq-check` authoritative contract doc (8 H2 sections; hashed into manifest contentHash).

**Modified (21):**

- `package.json` — added `devbox:prereq:check` pnpm script entry.
- `packages/keel-invariants/src/invariants.manifest.ts` — registered `INV-devbox-prereq-check` (30th entry); bumped `INV-prek-prepare-lifecycle` contentHash to match new `package.json` content.
- `INVARIANTS.md` — added `### Devbox prerequisite check (Story 2.10)` H3 section with one anchor bullet.
- `packages/devbox/README.md` — appended `## Prerequisite check (Story 2.10)` H2 sibling section.
- `AGENTS.md` — appended `### Prerequisite check (Story 2.10)` H3 sibling under `## Devbox iteration environment`.
- `packages/devbox/scripts/build.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/rebuild.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/start.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/stop.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/restart.sh` — Tier 1 prepend-only (transitive-delegate shim; no prior inline block).
- `packages/devbox/scripts/clean.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/shell.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/attach.sh` — Tier 1 block-swap (gained new `SCRIPT_DIR` derivation).
- `packages/devbox/scripts/status.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/logs.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/monitor-host.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/whitelist-host.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/env-check.sh` — Tier 1 prepend-only (NEW gate; env-check had no prior inline `docker info`).
- `packages/devbox/scripts/claude-host.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/gh-auth-host.sh` — Tier 1 block-swap.
- `packages/devbox/scripts/ralph-build-host.sh` — Tier 2 block-swap.
- `packages/devbox/scripts/ralph-plan-host.sh` — Tier 2 block-swap.
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — `2-10-…: ready-for-dev → in-progress → review` + two `last_updated` line appends.
- `_bmad-output/implementation-artifacts/2-10-…-pointer-errors.md` — this story file (Status flip; Task checkboxes; Dev Agent Record; File List; Change Log v1.3).

## Change Log

- v1.4 (2026-04-23) — **`/bmad-testarch-trace (args: "yolo")` fresh-context at iter-249; Story State `in-dev → traced`; TWENTIETH cumulative trace-WAIVED precedent (extending 19-precedent stack Stories 1.7 → 2.9 → 2.10); TWENTY-FIRST ATDD-skip-trace-WAIVED pairing overall.** Oracle resolved from § Acceptance Criteria (5 P2 ACs; formal_requirements; high confidence; not synthetic; external_pointer_status `not_used`). Deterministic gate would FAIL (overall 0% < 80%; P2 0/5; no test runner wired at substrate) → **WAIVED** per § Testing Standards three-ground conjunction with new multi-service composition variant: (a) substrate-verification covers AC 1 install-URL + AC 2/3/4/5 composite-message + exit-code surfaces at iteration-env-safe layer via 9/9 stub-docker smokes landed inline at iter-248 dev-story Task 7-equivalent impl (iter-249 orient confirms unchanged — wrapper surface + smoke results recapped in § Detailed Mapping); (b) no test runner wired (Story 1.16 deferred; Epic 13 is formal landing); (c) ground-(c) variant `external-service-owns-behavior-under-test` with MULTI-SERVICE composition — FIRST application in Epic 2; FIRST non-OAuth ground-(c) Epic-2 application — AC 1 Docker Desktop install-URL + Docker Engine daemon-reachability (Docker Inc. owns install path + `https://docs.docker.com/desktop/install/` docs URL) + AC 2/3 Stories 2.8/2.9 upstream OAuth flows already operator-workstation-verified + Story 2.5 `keel_home_dev` named-volume persistence already verified at iter-188 (joint ownership of token-presence-at-path existence) + AC 4 Story 2.7 `docker attach` envelope + Epic 3 in-container TUI (reduces to `sleep infinity` per Story 2.7 SC-2 until Epic 3 materializes) + AC 5 `docs/invariants/devbox-prereq-check.md § No-partial-bypass` spec-declared contract + `INV-ralph-halt-reason-enum` `CI_BLOCKED` consumed-not-modified for Epic 3 Story 3.7 halt-write consumer. **TWENTIETH cumulative trace-WAIVED precedent** — tenth Epic 2 trace-WAIVED + FIRST Epic-2-ships-envelope-composes-upstream-external-services class trace-WAIVED. Five artefacts landed under `_bmad-output/test-artifacts/traceability/`: `2-10-coverage-matrix.json` (PHASE_1_COMPLETE; 5 P2 ACs with per-AC substrate_evidence arrays; 30+ evidence entries across the five ACs) + `2-10-e2e-trace-summary.json` (gate_status WAIVED; schema_version 1; 4 recommendations — 3 MEDIUM + 1 LOW) + `2-10-gate-decision.json` (slim schema; p0/p1 MET; overall NOT_MET; WAIVED rationale text) + `2-10-prerequisite-check-docker-runtime-claude-auth-gh-auth-with-pointer-errors.md` (frontmatter + PHASE 1 per-AC detailed mapping + PHASE 2 gate decision + Recommendations + Display Summary; ~180 substantive lines; references cumulative-precedent chain + iter-248 9-smoke harness results + 17-shim wire-in enumeration + `INV-devbox-prereq-check` 30th manifest entry + collateral `INV-prek-prepare-lifecycle` contentHash-bump discipline). Status HTML comment updated `in-dev → traced` inline. **Sprint-status UNCHANGED per iter-202 precedent** (trace gate does NOT flip sprint-row; only Change Log records). Next iter (iter-250) queues `/bmad-create-story (args: "review")` fresh-context per § Story Lifecycle matrix row `traced → sm-verified | sm-fixes-pending` — forecast 0-3 PATCH band per Story 2.9 iter-243 ZERO-PATCH precedent + Story 2.10 wider novel-surface forecast (17 shim edits ADD lines to prepend-only shims which may shift § References line numbers; two-subagent substrate-citation verification pattern from iter-235 LESSON re-applies). **LESSON carry-forward for post-dev SM + CR gates:** iter-249 trace-WAIVED template inherited ~85% structure from Story 2.9 iter-242 (lower than Stories 2.8's 90% inheritance from 2.7); adaptation required 5-AC-uniform re-authoring + multi-service-composition ground-(c) variant + 9-smoke narrative integration + 17-shim wire-in enumeration + 30th-manifest-entry + collateral-contentHash-bump novelty. **No novel RALPH.md LESSON generated at trace gate** — template inheritance worked as forecast; the novel observation (collateral INV-prek-prepare-lifecycle contentHash discipline + stub-docker 9-smoke harness generalization) was already captured by iter-248 RALPH.md signpost. Budget iter-249: ~40K (orient + oracle resolve + prior Story 2.9 template read + 4 artefact writes + story file v1.4 prepend + IP update + RALPH.md signpost + commit + push).
- v1.3 (2026-04-23) — **`/bmad-dev-story` fresh-context impl at iter-248; Story State `atdd-scaffolded → in-dev`.** Task 1-6 all complete; 6 tasks with 37 sub-bullets total, every checkbox flipped `[x]`. Implementation surface landed exactly to v1.2 spec: (1) `packages/devbox/scripts/prereq-check.sh` new shared primitive (~120 LOC; not a `<verb>-host.sh` per SC-1 naming convention); (2) `pnpm devbox:prereq:check` script entry wired between `devbox:env:check` and `ralph:build` per Task 2 alphabetical order; (3) `ralph-build-host.sh` + `ralph-plan-host.sh` Tier 2 block-swap per Task 3; (4) 13 Tier 1 block-swap shims (`build`, `rebuild`, `start`, `stop`, `clean`, `shell`, `attach`, `status`, `logs`, `monitor-host`, `whitelist-host`, `claude-host`, `gh-auth-host`) + 2 Tier 1 prepend-only shims (`restart.sh` transitive-delegate + `env-check.sh` NEW gate) per Task 4 — exactly the 15+2=17 shim count pinned by SC-11; (5) `INV-devbox-prereq-check` registered as the 30th manifest entry + `docs/invariants/devbox-prereq-check.md` authored with 8 H2 sections (Three-check contract / Exit-code schema / Tier contract / No-partial-bypass / Fresh-fork first-run behavior / Alpine probe image / Consumption / Extension) all hashed into `contentHash: eb5b9db25e0afc77c4caf38c8bf60b37921a76df2ea030c91f66e848b0d8fe40` + `INVARIANTS.md` anchor bullet under new `### Devbox prerequisite check (Story 2.10)` H3 per Task 5 (verbatim regex-compliant per Story 1.9 sync-gate); (6) `packages/devbox/README.md § Prerequisite check (Story 2.10)` + `AGENTS.md § Prerequisite check (Story 2.10)` sibling H2/H3 sections appended per Task 6 (prior Stories 2.6/2.7/2.8/2.9 sections untouched per SC-17). **Stub-docker smokes — 9/9 PASS** executed from workspace-based `.ralph-smoke/shim/` per iter-223/230/237 LESSON (NOT `/tmp/` tmpfs noexec; torn down in final assertion call, NOT EXIT trap): (i) Tier 1 + docker-down → exit 8 + verbatim install-URL `https://docs.docker.com/desktop/install/`; (ii) Tier 1 + docker-up → exit 0 silent; (iii) Tier 2 + volume-absent (fresh-fork first-run) → exit 2 + composite message Claude-before-gh ordering; (iv) Tier 2 + both tokens present → exit 0 silent; (v) Tier 2 + Claude-only → exit 2 + gh-missing pointer only; (vi) Tier 2 + gh-only → exit 2 + Claude-missing pointer only; (vii) No-arg default → Tier 2; (viii) Unknown arg → usage + exit 2; (ix) `pnpm run | grep devbox:prereq:check` → 1 match. **`pnpm keel-invariants:check` EXIT=0** after manifest landing (29→30 entries); required a collateral `INV-prek-prepare-lifecycle` contentHash bump `d89072918e…→dc5ed31b8a…` tracking the `package.json` change (expected side-effect; whole-file content hash). **`bash -n` parse check** on all 18 edited scripts: clean. **Story State → in-dev:** dev-story Step 9 flipped sprint-status `2-10-…: in-progress → review` (single iter ran both Step 4 ready-for-dev→in-progress AND Step 9 in-progress→review because impl + smokes + gates all fit in a single dev-story invocation). **Next iter (iter-249) queues `/bmad-testarch-trace (args: "yolo")`** per § Story Lifecycle matrix row `in-dev → traced`; trace WAIVED forecast TWENTIETH cumulative precedent per v1.0 Testing Standards. **ATDD Ground-(a) Task 7 smokes inheritance**: the 9 stub-docker smokes at iter-248 are the Task 7-equivalent impl-time smokes (v1.2 referenced "Task 7 smoke tests" in § Testing Standards but Task 7 was not authored as a standalone sub-bullet in Tasks/Subtasks — dev-agent ran them inline per v1.2 ground-(a) citation). Budget iter-248: ~95K (orient + 18 shim reads + Task 1 author + Task 2 pnpm edit + 2 Task 3 block-swaps + 13 Task 4 block-swaps + 2 Task 4 prepend-onlys + Task 5 manifest/doc/INVARIANTS.md + Task 6 README/AGENTS.md appends + sha256 compute + keel-invariants build + sync-gate verification + 9 smoke assertions + story file Status flip + 37 checkbox flips + Dev Agent Record + File List + Change Log v1.3 + sprint-status review flip + commit + push). **LESSON carry-forward for post-dev SM gate:** substrate-citation drift two-subagent verification pattern (iter-235 LESSON) MAY apply — Story 2.10 touched 17 shims + docker-compose volume name reference + `packages/keel-invariants/src/invariants.manifest.ts` — line-number drifts in v1.0-v1.3 § References potentially higher than Story 2.9's 13-drift baseline because Story 2.10 prepend-only edits ADD lines (restart.sh + env-check.sh gain 1 line each; block-swap shims neutral on line-count). **LESSON candidate for post-dev SM + CR gates** (iter-249/250/251+): dev-agent Task 5 landed `INV-prek-prepare-lifecycle` contentHash bump in the SAME commit as the new `devbox:prereq:check` pnpm entry — this is the correct discipline under Story 1.9 sync-gate, not scope-creep (the whole-file content hash binds every line of `package.json`). Future stories touching root `package.json` for new pnpm verbs MUST similarly update `INV-prek-prepare-lifecycle` contentHash in the same commit. Forecast: Stories 2.11..2.17 landing additional pnpm scripts will repeat this pattern — document in RALPH.md if a Ralph drifts on this gate (e.g., forgets the manifest-hash bump and the sync-gate catches it post-push).
- v1.2 (2026-04-23) — **FR14n ATDD-skip applied (iter-247; Story State `validated → atdd-scaffolded`; TWENTIETH cumulative precedent — chain: Stories 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14/1.15/1.16 + 2.1/2.2/2.3/2.4/2.5/2.6/2.7/2.8/2.9 → 2.10).** Skill `/bmad-testarch-atdd` NOT invoked through full generation flow; preflight Step 1.2 hard-prerequisite "test framework configured" FAILS at iter-247 (verified via `find . -maxdepth 5 -type f \( -name 'vitest.config.*' -o -name 'jest.config.*' -o -name 'playwright.config.*' -o -name 'cypress.config.*' -o -name 'pytest.ini' -o -name 'conftest.py' -o -name 'go.mod' -o -name 'Cargo.toml' -o -name 'Gemfile' \) | grep -v node_modules | grep -v '\.bmad'` returns empty — no test runner at substrate; Story 1.16 deferred to post-Epic-2). TEA `test_framework: auto` autodetects nothing; skill would HALT per step-01 fail-closed posture → skip is the only autonomous path per Ralph Guardrail 3 (never wait for user input; choose autonomous path). **Skip grounds satisfied per § Testing Standards three-ground conjunction:** (a) substrate-verification covers AC 1 install-URL + AC 5 composite-message via Task 7 stub-docker smokes at impl time (Tier 1 fail → exit 8 + verbatim `https://docs.docker.com/desktop/install/`; Tier 1 pass + volume-absent → composite missing-item list + exit 2; Tier 1 pass + volume-present + both files present → exit 0 silent; Tier 1 pass + Claude-only → gh-missing pointer + exit 2; Tier 1 pass + gh-only → Claude-missing pointer + exit 2; arg-parse `--tier1` / `--tier2` / unknown → exit 2); (b) no test runner wired at substrate (Story 1.16 deferred); (c) ground-(c) variant "external-service-owns-behavior-under-test" — FIRST non-OAuth ground-(c) application in Epic 2 (all prior Epic 2 ground-(c) applications at Stories 2.8/2.9 pinned the OAuth-endpoint-owns-behavior rationale; Story 2.10 broadens the abstraction to Docker Desktop's install-URL + Docker-Engine-owned daemon-reachability behavior for AC 1, + Stories 2.8/2.9 upstream `claude` + `gh` OAuth flows already verified at operator-workstation for AC 2/3 token-write behavior, + Story 2.5 `keel_home_dev` named-volume persistence substrate already verified for AC 2/3 token-survival behavior, + Epic 3 Story 3.7 halt-able consumer contract pinned not implemented for AC 5 downstream enforcement — Story 2.10's wrapper verifies only the probe invocation envelope + exit-code + stderr-message surface + tier-dispatch branching, NOT Docker daemon behavior or OAuth token write semantics). **AC 5 NEW element** vs Stories 2.8/2.9: "composite missing-item list aggregation within a single stderr message" — covered under ground-(a) Task 7 fresh-fork stub-docker smoke (Tier 2 + volume-absent branch aggregates both Claude + gh pointer lines in Claude-before-gh order matching Stories 2.8 → 2.9 landing order); live composite flow verified at operator workstation when operator runs first `pnpm ralph:build` against a fresh fork with no devbox state. Story State `validated → atdd-scaffolded` (skip-marker endpoint; NOT direct `→ in-dev`, consistent with Story 1.8 iter-3 + Story 1.9 iter-3 + Story 1.12 iter-62 + Story 1.13/14/15/16 + Story 2.1/2.2/2.3/2.4/2.5/2.6/2.7/2.8/2.9 precedent chain — TWENTIETH cumulative ATDD-skip). Sprint-status UNCHANGED (ATDD-skip is IP-lifecycle state, not sprint-row state per Story 2.7 iter-222 + Story 2.8 iter-229 + Story 2.9 iter-236 precedent). **No new RALPH.md lesson generated** — full mechanical inheritance from Story 2.9 iter-236 confirmed; no novel surface at the ATDD gate specifically (the novel surfaces enumerated at v1.1 PATCH 1-4 are all downstream of ATDD). Next iter queues `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-10-prerequisite-check-docker-runtime-claude-auth-gh-auth-with-pointer-errors.md")` per § Story Lifecycle matrix row `atdd-scaffolded → in-dev`. Budget iter-247: ~40K (orient + skill dispatch + prerequisite verify + Change Log prepend + IP update + sprint-status-unchanged verify + RALPH.md signpost + commit + push).
- v1.1 (2026-04-23) — Pre-dev SM review via `/bmad-create-story (args: "review")` fresh-context at iter-246. Story State `drafted → validated`. Four PATCHes applied against v1.0; sprint-status `2-10-…: ready-for-dev` unchanged (pre-dev SM gate is Ralph-internal, not sprint-row state). **PATCH 1 — SC-4 + SC-7 alpine egress + Renovate correction:** Removed erroneous "alpine covered by `*.docker.io` whitelist entry" claim (no such entry exists + `prereq-check.sh` runs host-side so devbox egress doesn't apply); removed erroneous "Renovate auto-discovers shell-script image refs" claim (default `docker` manager fileMatch covers Dockerfile + docker-compose.yml only per Story 1.15 scope); documented manual `alpine:3.19` version tracking at 1.0 with deferred `customManagers` regex-manager trajectory. **PATCH 2 — manifest entry count:** Corrected "19 → 20 entries" to "29 → 30 entries at 2026-04-23 baseline" (current manifest count per `packages/keel-invariants/src/invariants.manifest.ts` audit; counts full substrate manifest across Stories 1.3–1.15 + Epic-2 devbox + ralph-halt entries, not only devbox). Applied in Task 5 first bullet + Dev Notes § Project Structure Notes. **PATCH 3 — Task 5 anchor regex precision:** Corrected quoted regex from `/^-\s+\*\*\`([A-Z][A-Z0-9-]+)\`\*\*/gm` to `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` (matches actual `packages/keel-invariants/src/sync-gate.ts:24` — lowercase-after-`INV-` is regex-enforced, not just convention); added example compliant bullet. **PATCH 4 — restart.sh + benchmark.sh shim discipline:** `restart.sh` special case documented (no inline `docker info` block; prepend-only wire-in; transitive delegation via stop.sh/start.sh preserved); `benchmark.sh` explicitly flagged OUT-OF-SCOPE under SC-11 (not a pnpm verb; exit-127 command-not-found semantic load-bearing to NFR2 contract; reconciliation to uniform exit-8 deferred as FR44 AMEND). Clarifies 14-vs-3 shim refactor shape (14 block-swap + 3 prepend-only, not 15+2 block-swap). Net PATCH count: **4** — matches low end of forecast 2–5 band per Story 2.10 novel-surface expectation (multi-shim refactor + first Epic-2 new-INV + alpine probe + tier-dispatch). **Carry-forward for post-dev SM gate:** substrate-citation drift two-subagent verification pattern (iter-235 LESSON) re-applies. Line-number drifts in v1.0 § References (e.g. `docker-compose.yml:170-171` — volume now at L257) are deferred to Epic 2 close-out per SC-17. **LESSON continuation:** iter-221 `~5-PATCH` ceiling held — 4 PATCHes at low end of 2–5 forecast band; novel surfaces surfaced exactly the predicted categories (egress-vs-host-side runtime confusion at SC-4/SC-7; manifest-count staleness; anchor-regex precision; multi-shim refactor shape). Pattern chain for one-pass ZERO-PATCH post-dev SM + CR candidate: v1.1 density now 5 ACs + 6 tasks + 17 SCs (SC content refined; count unchanged) + 2 new PATCH-introduced notes (restart.sh/benchmark.sh) — matches Stories 2.7/2.8/2.9 post-PATCH density precedent.
- v1.0 (2026-04-23) — Initial draft. 5 ACs + 6 tasks + 17 SCs. Scope carve-outs pinned: SC-2 upstream Docker Desktop owns install path + hardcoded URL at 1.0; SC-3 filesystem-based token probe (existence only, not validity); SC-4/SC-7 alpine:3.19 pin with Renovate `docker` manager tracking; SC-5 composite-message aggregation within Tier 2 + Tier 1 fails fast; SC-11 17-shim wire-in required for AC 5 "any pnpm devbox/ralph command"; SC-12 NEW shared primitive (first story-scoped `scripts/` lift in emerging `_lib.sh` refactor trajectory; iter-239 retrofit was non-story-scoped); SC-13 no compose/Dockerfile/entrypoint edits; SC-14 ralph.py TUI unchanged (Epic 3 scope); SC-15 no token content inspection; SC-17 read-only posture on Stories 2.6/2.7/2.8/2.9 README + AGENTS.md sections. File placement: standalone primitive at `packages/devbox/scripts/prereq-check.sh` (NOT `<verb>-host.sh` — primitive-naming per Story 2.3/2.4 pattern). INV-devbox-prereq-check registered in manifest + authoritative doc at `docs/invariants/devbox-prereq-check.md` (multi-section structure so each sub-contract hashes into `contentHash` per Story 2.3 iter-156 LESSON). ATDD skip forecast per FR14n matrix row 3 ground-(a)+(b)+(c) conjunction — TWENTIETH cumulative precedent. Trace WAIVED forecast — TWENTIETH cumulative precedent. CR forecast: 0–3 PATCH opener + candidate FIFTH one-pass ZERO-PATCH precedent if pattern holds under novel multi-shim-edit surface. Draft density: 5 ACs + 6 tasks + 17 SCs matches Stories 2.7/2.8/2.9 post-PATCH density; pre-dev SM gate expected 2-5 PATCHes (wider band than prior due to novel surfaces: multi-shim refactor, first Epic-2 new-INV entry, alpine-probe-image dependency, tier-dispatch argv). Projected lifecycle: iter-245 drafted → iter-246 validated → iter-247 atdd-scaffolded → iter-248 in-dev → iter-249 traced → iter-250 sm-verified → iter-251 done (7-iteration close if one-pass ZERO-PATCH holds; longer if novel surface generates CR iterations).
