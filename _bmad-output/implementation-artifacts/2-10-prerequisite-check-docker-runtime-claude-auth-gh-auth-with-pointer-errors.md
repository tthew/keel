# Story 2.10: Prerequisite check (Docker runtime + Claude auth + gh auth) with pointer errors

Status: ready-for-dev

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

- [ ] **Task 1: Author `packages/devbox/scripts/prereq-check.sh`** (AC 1, AC 2, AC 3, AC 4, AC 5)
  - [ ] Shebang `#!/usr/bin/env bash` + banner header (purpose = FR5 prerequisite-check primitive; dual-ref Story 2.10 AC 1–5 + Story 2.6 uniform exit-code schema + Stories 2.8/2.9 token-persistence contracts).
  - [ ] `set -euo pipefail`.
  - [ ] `unset COMPOSE_PROJECT_NAME` — Story 2.6 AI-8/AI-12 + Story 2.7 SC-10 + Story 2.8 SC-8 + Story 2.9 SC-8 defensive-posture precedent. Protects `keel-devbox_keel_home_dev` named-volume identity (`INV-devbox-homedev-named-volume`).
  - [ ] `VOLUME_NAME="${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}_keel_home_dev"` — compose-project-scoped volume name; operator-overridable via `KEEL_DEVBOX_COMPOSE_PROJECT` (Story 2.2 parameterization) with default matching docker-compose.yml's `name:` field.
  - [ ] `log() { printf '[prereq-check] %s\n' "$*" >&2; }`.
  - [ ] Arg parsing: accept one optional positional arg `--tier1` (Docker only) or `--tier2` (all three; default). Reject unknown args with exit 2 and a usage message.
  - [ ] **Tier 1 check — Docker runtime reachable:**
    - [ ] `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log_err_docker_missing; exit 8; }` where `log_err_docker_missing` is a function emitting two stderr lines: `[prereq-check] docker unreachable — is the daemon running?` and `[prereq-check] install Docker Desktop: https://docs.docker.com/desktop/install/` (AC 1 URL verbatim).
    - [ ] Tighter-variant `--format '{{.ServerVersion}}'` per Story 2.7 + 2.8 + 2.9 inheritance chain; NOT bare `docker info` (which has `>/dev/null` echoing).
  - [ ] **Tier 2 check — Docker + Claude + gh tokens:**
    - [ ] Run Tier 1 first. If exit 8 → exit 8 (propagated; Tier 2 cannot proceed without Docker).
    - [ ] Probe named volume: `docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1` — if volume does NOT exist (fresh-fork first-run before `pnpm devbox:start` has created it), treat as "both tokens missing" and aggregate both pointer errors into the composite stderr message.
    - [ ] Probe Claude token: `docker run --rm -v "${VOLUME_NAME}":/vol:ro alpine:3.19 test -e /vol/.claude/.credentials.json` (SC-7 image pin). Exit 0 → present; non-zero → missing; record finding.
    - [ ] Probe gh token: `docker run --rm -v "${VOLUME_NAME}":/vol:ro alpine:3.19 test -e /vol/.config/gh/hosts.yml`. Exit 0 → present; non-zero → missing; record finding.
    - [ ] Aggregate findings (composite-message contract per AC 5 + SC-5): if both tokens missing, emit TWO stderr lines — `[prereq-check] Claude Code not authed — run 'pnpm claude' first` + `[prereq-check] gh CLI not authed — run 'pnpm gh:auth' first` — in that order (Claude before gh, matching Story 2.8 → 2.9 landing order), then exit 2. If exactly one missing, emit one line + exit 2. If both present, exit 0 silently.
  - [ ] Exit-code schema (extends Story 2.6 uniform): `0` all pass, `2` one or more tokens missing (composite pointer list emitted), `8` docker unreachable (install-URL pointer emitted), `12` other docker-daemon error (volume-inspect crash, alpine pull failure under fail-closed egress) — propagated via `docker`'s own non-zero exit.
  - [ ] `chmod +x` at creation.

- [ ] **Task 2: Root `package.json` pnpm wiring — `pnpm devbox:prereq:check` standalone verb** (AC 5 — operator-surface discoverability)
  - [ ] Add one entry to `scripts`: `"devbox:prereq:check": "./packages/devbox/scripts/prereq-check.sh"`.
  - [ ] Insertion point — AFTER the `"devbox:env:check"` entry (alphabetical within the `devbox:*` group; `devbox:env:check` → `devbox:prereq:check` sort order) and BEFORE `"ralph:build"`. Verb form uses the existing `devbox:<subverb>` colon pattern (Story 2.6 precedent for `devbox:env:check`).
  - [ ] Verb form deliberate: **`devbox:prereq:check` uses double-colon (namespace:sub-verb form), matching `devbox:env:check` precedent.** Operators running the verb standalone execute Tier 2 by default (exits 0 silently if all three pass); `pnpm devbox:prereq:check --tier1` for Docker-only. AC 5 "fresh-fork first-run surfaces missing-item list" is satisfied by this direct verb OR by ralph/devbox wrapper pre-flight (SC-11 wires it into all shims).
  - [ ] Smoke: `pnpm run 2>&1 | grep -E '^ +devbox:prereq:check$'` → 1 match.

- [ ] **Task 3: Wire Tier 2 into `ralph-build-host.sh` + `ralph-plan-host.sh`** (AC 2, AC 3, AC 4 — Ralph-invocation-gating)
  - [ ] At the top of each ralph-*-host.sh, BEFORE the existing `docker info` pre-flight + auto-start block, add: `"$(dirname "${BASH_SOURCE[0]}")/prereq-check.sh" --tier2`. Propagate the exit code: if prereq-check exits non-zero, ralph-*-host.sh exits with the same code without attempting auto-start or `docker attach`.
  - [ ] Remove the existing inline `docker info` pre-flight block from each ralph-*-host.sh (now subsumed by `prereq-check.sh --tier2` which runs Tier 1 first). Do NOT remove the `start.sh` auto-start block or the final `docker attach` — those remain.
  - [ ] Preserve Story 2.7's auto-start posture: after prereq-check passes, ralph-*-host.sh still sub-invokes `start.sh` (which may be a no-op if container already running) and then `docker attach`es. The prereq-check-before-auto-start ordering is deliberate — operators without Docker should NOT see an auto-start attempt.
  - [ ] Exit-code passthrough: prereq-check's exit 8 / 2 / 12 propagate through ralph-*-host.sh unchanged; Story 2.7's existing 9 / 10 / 11 schema for auto-start and healthcheck still applies AFTER the prereq-check gate.

- [ ] **Task 4: Wire Tier 1 into the 15 other host-side shims** (AC 1, AC 5 — "any `pnpm devbox:*` command" gating)
  - [ ] Affected shims (15 total):
    - Story 2.6 devbox verbs (13): `build.sh`, `rebuild.sh`, `start.sh`, `stop.sh`, `restart.sh`, `clean.sh`, `shell.sh`, `attach.sh`, `status.sh`, `logs.sh`, `monitor-host.sh`, `whitelist-host.sh`, `env-check.sh`.
    - Story 2.8 (1): `claude-host.sh`.
    - Story 2.9 (1): `gh-auth-host.sh`.
  - [ ] For each shim, at the top BEFORE the existing inline `docker info` block (but AFTER `set -euo pipefail` + `unset COMPOSE_PROJECT_NAME`), add: `"$(dirname "${BASH_SOURCE[0]}")/prereq-check.sh" --tier1`. Propagate exit code (exit 8 bubbles up; no further pre-flight runs if prereq-check fails).
  - [ ] **Remove the existing inline `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || { log ...; exit 8; }` block** from each shim (now subsumed by prereq-check Tier 1). Preserve each shim's OTHER pre-flight (`docker inspect` container-state check, env-var probes in env-check.sh, etc.) — those remain per-shim concerns.
  - [ ] `env-check.sh` (Story 2.6) special case: `env-check.sh` currently has NO `docker info` check (it validates env vars only, not Docker reachability). Story 2.10 STILL calls `prereq-check.sh --tier1` at the top of env-check.sh so fresh-fork first-run `pnpm devbox:env:check` also surfaces the install-URL pointer when Docker is missing (AC 5 "any `pnpm devbox:*` command"). This is a NEW gate for env-check.sh, not a refactor. Exit-code schema extension: env-check.sh's existing `2`/`3` (missing var / `.envrc` unreadable) codes remain; `8` (docker unreachable) is now also possible, emitted by the prereq-check call.
  - [ ] **Substrate contracts preserved on each shim:** only the single `docker info`-line block is removed + a single `prereq-check.sh --tier1` call is added. All other shim logic (container-name derivation, container-state inspect, final `exec`/`attach`/`compose` calls, signal handling, TTY posture, args passthrough) is UNCHANGED. Mirror discipline with Story 2.6/2.8/2.9 prior art is preserved.
  - [ ] Exception — `prereq-check.sh` does NOT call itself. No recursion.

- [ ] **Task 5: Register `INV-devbox-prereq-check` + author `docs/invariants/devbox-prereq-check.md`** (AC 1–5 machine-enforced contract)
  - [ ] Add new entry to `packages/keel-invariants/src/invariants.manifest.ts`:
    - `id: 'INV-devbox-prereq-check'`
    - `description: 'Prerequisite check for Docker runtime + Claude Code auth + gh auth runs on every host-side shim invocation and fails fast with pointer errors (Story 2.10).'`
    - `sourcePath: 'docs/invariants/devbox-prereq-check.md'`
    - `contentHash: '<sha256 of the authored md file content>'`
    - `anchors: ['INV-devbox-prereq-check']`
  - [ ] **InvariantSchema five-field compliance** (Story 2.3 iter-156 LESSON):  `InvariantSchema` at `packages/keel-invariants/src/invariants.manifest.ts:3-15` requires exactly `{id, description, sourcePath, contentHash, anchors}` — NO `name` field; `anchors` entries are backtick-wrapped ID literals NOT H3-header strings; `contentHash` is bare 64-char lowercase hex NOT `sha256:<hex>` prefixed. Story 2.10 compliance is mandatory.
  - [ ] Author `docs/invariants/devbox-prereq-check.md` with the following H2-structured sections so each sub-contract is hashed into `contentHash` (Story 2.3 iter-156 LESSON — multi-faceted contracts embed sub-schemas verbatim in the `sourcePath` doc):
    - `## Three-check contract` — enumerates Docker / Claude / gh probes + the exact stderr message templates (verbatim pointer strings from ACs 1–3).
    - `## Exit-code schema` — pins `0 / 2 / 8 / 12` semantics per Task 1.
    - `## Tier contract (Tier 1 vs Tier 2)` — pins which shim invokes which tier (full enumeration of the 17 shims) so downstream refactors cannot drift.
    - `## No-partial-bypass` — AC 5 clause verbatim: no `--skip-claude` / `--force` / `KEEL_PREREQ_BYPASS` escape-hatch at 1.0; a fork operator needing to bypass is outside the supported operator-experience envelope.
    - `## Fresh-fork first-run behavior` — AC 5 narrative for the volume-absent case (probe volume existence → if absent, treat as both tokens missing).
    - `## Alpine probe image` — SC-7 pin: `alpine:3.19` as the minimal throwaway image used for volume file-existence probes; any future minor bump requires `packages/keel-invariants/` substrate review + Renovate `docker` manager tracking.
  - [ ] Compute `contentHash`: `sha256sum docs/invariants/devbox-prereq-check.md | awk '{print $1}'`. Paste the 64-char lowercase hex into the manifest entry. `pnpm keel-invariants:check` MUST pass after manifest + doc both land (Story 1.9 sync-gate verification).
  - [ ] Append entry to `INVARIANTS.md` under the devbox section (after `INV-devbox-homedev-named-volume`) as: `- **\`INV-devbox-prereq-check\`**` with one-line description; index-only, no body (`INVARIANTS.md` is an agent-readable index per FR42).
  - [ ] Dev-agent guardrail: the anchor bullet MUST match the verbatim regex `/^-\s+\*\*\`([A-Z][A-Z0-9-]+)\`\*\*/gm` per `INV-INVARIANTS-sync-gate` (Story 1.9). Lowercase-after-`INV-` prefix is mandatory (Story 1.9 iter-7 LESSON — real `INV-*` IDs are lowercase after the `INV-` prefix).

- [ ] **Task 6: Operator + agent documentation + Change Log housekeeping** (AC 1–5 comprehension)
  - [ ] **`packages/devbox/README.md`** — append new H2 `## Prerequisite check (Story 2.10)` AFTER the existing `## gh CLI authentication (Story 2.9)` H2 (sibling placement at the same outline level) and BEFORE `## cc-devbox upstream provenance`.  Content: (a) quick-start `pnpm devbox:prereq:check` invocation; (b) three-check enumeration (Docker / Claude / gh) + exact pointer strings; (c) tier contract — Tier 1 gates every host-side shim; Tier 2 gates ralph-*-host.sh + standalone verb; (d) fresh-fork first-run walkthrough — expect a composite missing-item list on first `pnpm ralph:build`; operator follows the pointer sequence (install Docker → `pnpm devbox:start` → `pnpm claude` → `pnpm gh:auth` → re-run `pnpm ralph:build`); (e) exit-code reference — `0` / `2` / `8` / `12`; (f) no-bypass posture — there is NO `--skip-claude` / `--force` / `KEEL_PREREQ_BYPASS` at 1.0; operators with nuanced needs (e.g., CI harness without host browser) run `prereq-check.sh --tier1` directly and bypass token probes; (g) cross-ref to `AGENTS.md § Prerequisite check`.
  - [ ] **DO NOT modify existing `## Host-side CLI (Story 2.6)`, `## Ralph loop (Story 2.7)`, `## Claude Code authentication (Story 2.8)`, or `## gh CLI authentication (Story 2.9)` sections** — append a NEW sibling H2 only. Rewriting prior stories' sections is scope-creep (SC-17 inherited from Story 2.9).
  - [ ] **`AGENTS.md`** — append new H3 `### Prerequisite check (Story 2.10)` AFTER the existing `### gh CLI authentication (Story 2.9)` H3 under § Devbox iteration environment. Content: (a) canonical invocation is `pnpm devbox:prereq:check` (never call `prereq-check.sh` directly from agent contexts); (b) three-check contract + the exact pointer strings + exit-code schema; (c) `INV-devbox-prereq-check` citation for the machine-enforced contract; (d) fail-mode guidance — when prereq-check exits 8, agents MUST queue `pnpm devbox:build` or Docker-install as an operator fix task (agents do NOT attempt to install Docker autonomously); when prereq-check exits 2 with a Claude-missing pointer, queue `pnpm claude`; when gh-missing, queue `pnpm gh:auth`; (e) Epic 3 pre-push-gate halt-able pointer extension — when Ralph's in-loop pre-push gate fires a prereq-check and it exits 8 or 2, write halt `{"reason":"CI_BLOCKED","note":"<exact pointer string>"}` per the closed halt-reason enum (`INV-ralph-halt-reason-enum`; PRD FR14k). Stories 2.8 SC-10 and 2.9 SC-10 already pin `CI_BLOCKED` for Claude/gh-specific halts; Story 2.10 generalises to the composite prereq-check surface.
  - [ ] **DO NOT modify existing `### Host-side CLI (Story 2.6)`, `### Ralph loop (Story 2.7)`, `### Claude Code authentication (Story 2.8)`, or `### gh CLI authentication (Story 2.9)` sections** — append a NEW sibling H3 only (SC-17).
  - [ ] **Change Log v1.0 entry** — record 5 ACs + 6 tasks + ~17 SCs; initial draft; dev-ready; ATDD skip forecast under FR14n matrix row 3 ground-(a)+(b)+(c) conjunction per § Testing Standards; trace WAIVED forecast; CR PATCH forecast 0–3 opener (narrow novel surface — composition on Stories 2.6/2.8/2.9 with SC-14 `_lib.sh`-adjacent shim refactor being the new element).
  - [ ] **Sprint-status housekeeping:** Step 4 (dev-story) flips `2-10-...: ready-for-dev → in-progress`; Step 9 (dev-story) flips `in-progress → review`. Not a create-story task — the `/bmad-create-story` workflow's step 6 automation flips `backlog → ready-for-dev`.

## Dev Notes

### Scope clarifications (SC-1..SC-17)

**SC-1 — Stories 2.6 + 2.7 + 2.8 + 2.9 host-side CLI is the composable substrate.** Story 2.10 composes on Story 2.6's 13-verb devbox surface + Story 2.7's 2-verb ralph auto-start pair + Story 2.8's `claude` verb + Story 2.9's `gh:auth` verb, adding ONE more standalone verb (`devbox:prereq:check`) + 17 shim wire-ins. The host-side-shim count after Story 2.10 landing is **18** total (17 Story 2.9 landing + 1 new Story 2.10 `prereq-check.sh`). Story 2.10 `prereq-check.sh` deliberately is NOT a `<verb>-host.sh` (`<verb>-host.sh` is reserved for pnpm-verb wrappers per Story 2.6 SC-2 naming convention) — it is a shared primitive called by other shims. Its name follows the Story 2.3/2.4 primitive-naming pattern (`reload-egress.sh`, `whitelist.sh`) — verb-first-no-host-suffix for non-pnpm-verb orchestrators. [Source: 2-9-gh-cli-oauth-via-pnpm-gh-auth.md § Dev Notes SC-1; 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-2]

**SC-2 — Docker runtime check delegates to upstream Docker Desktop (external CLI).** AC 1's "Docker runtime reachable" is a behaviour of the host Docker Desktop (or Docker Engine on Linux/Colima on macOS). Story 2.10's wrapper invokes `docker info --format '{{.ServerVersion}}'` and interprets any non-zero exit as "Docker unreachable." The pointer URL `https://docs.docker.com/desktop/install/` is the canonical Docker-Desktop install page at the Docker-owned docs site; the URL is hardcoded in `prereq-check.sh` at draft time (2026-04-23 verified; if Docker changes URL, a future substrate polish updates the string). Story 2.10 does NOT: (a) vendor or self-host the install guide; (b) attempt any auto-install path; (c) verify Docker version compatibility (INV-devbox-dind-available covers the broader Docker runtime contract; Story 2.10 probes reachability only). [Source: `INV-devbox-dind-available` § Backend contract; `docs/invariants/devbox-dind.md`]

**SC-3 — Claude / gh token detection is filesystem-based, not CLI-based.** AC 2's "probe `/home/dev/.claude/` state" explicitly directs filesystem probing over invoking `claude --version` or `gh auth status`. Rationale: CLI-based probes require the target binaries to be reachable + functional, which adds failure modes (network / permission / upstream-CLI-crash); filesystem probe on the named volume is deterministic and side-effect-free. The probe files are:
- **Claude: `/home/dev/.claude/.credentials.json`** — upstream `@anthropic-ai/claude-code@2.1.116` writes this file post-OAuth (verified via Story 2.8 iter-230 live smoke on operator workstation). Path is upstream contract; if upstream rotates filename (future major version), Story 2.10's probe path MUST update in lockstep + the `SC-3 probe-file` row in `docs/invariants/devbox-prereq-check.md § Three-check contract` MUST be re-hashed into `contentHash` at manifest level.
- **gh: `/home/dev/.config/gh/hosts.yml`** — upstream `gh` CLI default location (verified via Story 2.9 iter-237 + iter-244 live smoke on operator workstation). Same rotation contract applies.

Story 2.10 does NOT parse or validate the file contents — existence alone is the signal. If the file exists but contains an expired token, `pnpm ralph:build` will still "pass" the prereq-check, and the expired-token condition surfaces later during actual `claude` or `gh` invocations (both of which have their own re-auth-pointer surfaces per Story 2.8 AC 4 + Story 2.9 AC 4; Ralph's in-loop pre-push gate in Epic 3 Story 3.7 catches these separately). This is deliberate — the prereq-check is a presence-of-file gate, NOT a token-validity gate (validity is upstream's concern). [Source: Story 2.8 AC 4 re-auth pointer; Story 2.9 AC 4 re-auth pointer + halt-able handling; `packages/devbox/scripts/claude-host.sh` Story 2.8 substrate; `packages/devbox/scripts/gh-auth-host.sh` Story 2.9 substrate]

**SC-4 — Probe container is `alpine:3.19` throwaway, NOT the devbox image.** The token-probe runs `docker run --rm -v "${VOLUME_NAME}":/vol:ro alpine:3.19 test -e /vol/...`. `alpine:3.19` is chosen for: (a) smallest footprint (~5MB compressed) — low egress cost at first-pull; (b) stable enough — alpine minor-line pin avoids surprise major-version drift (alpine major-line-bumps occasionally break musl-libc ABI); (c) already on egress allow-list via the generic `*.docker.io` entry (verify at impl time via `grep alpine packages/devbox/whitelist*.txt` — if absent, Story 2.10 MUST add alpine's registry domain, not rely on wildcard). **Alternatives considered + rejected:** (α) the devbox image itself (`keel-devbox:local`) — rejected because the devbox image is ~848 MB and the probe runs every invocation; (β) `busybox` — rejected because `test -e` semantics differ subtly (busybox's `test` builtin vs util-linux); (γ) a pre-built alpine-with-test image in ghcr.io — rejected as over-engineering at 1.0. Renovate `docker` manager tracks `alpine:3.19` in a new `renovate.json5` regex-manager entry OR a `## dependencies` comment in `prereq-check.sh` (dev-agent choice per Story 1.15 precedent). [Source: Story 1.15 Renovate config; docs/invariants/devbox-egress.md § Allow-list baseline]

**SC-5 — Composite-message aggregation within Tier 2; Tier 1 fails fast.** AC 5 "surfaces the missing-item list as a single message" applies to the Tier 2 token-probe phase (Claude + gh) where both probes are independent and can run in sequence without cross-dependence. Docker-missing DOES break composite aggregation — if Docker is down, the volume probe cannot run, so Claude/gh status is unknown. The contract is: Tier 1 (Docker) fails fast with ONE pointer; Tier 2 (tokens) runs both probes + aggregates findings into ONE composite message. The user-experience sequence under fresh-fork first-run with nothing satisfied:
1. `pnpm ralph:build` → prereq-check Tier 1 fails → stderr: `docker unreachable ... install Docker Desktop: https://docs.docker.com/desktop/install/` → exit 8.
2. Operator installs Docker Desktop → re-runs `pnpm ralph:build` → prereq-check Tier 1 passes → Tier 2 probes volume → volume does not exist yet → aggregate both tokens missing → stderr: `Claude Code not authed — run 'pnpm claude' first\ngh CLI not authed — run 'pnpm gh:auth' first` → exit 2.
3. Operator runs `pnpm devbox:start` (container comes up; named volume auto-inits) → `pnpm claude` (OAuth flow) → `pnpm gh:auth` (OAuth flow) → re-runs `pnpm ralph:build` → prereq-check passes silently → Ralph TUI attaches.

Under step-wise recovery where the operator fixes Docker but runs `pnpm ralph:build` before running `pnpm devbox:start`, the volume may not exist yet → Tier 2 probes fail with both-missing message. Operator must run `pnpm devbox:start` to auto-init the volume before `pnpm claude` can write its token. [Source: AC 5; Story 2.5 § Named volume auto-init]

**SC-6 — Exit-code schema extends Story 2.6's uniform schema with one new code.** Story 2.10 uses `0` (pass), `2` (missing tokens; reuses Story 2.6 env-check's `2` semantic "missing/shape violation"), `8` (docker unreachable; reuses Story 2.6 universal code), `12` (other docker-daemon error). No NEW exit codes at 1.0. Tier-specific code `9` (Ralph-wrapper container not running) remains Story 2.7's concern and runs AFTER prereq-check; prereq-check itself does not emit `9`. Ralph-wrapper codes `10` (image not built) and `11` (healthcheck timeout) similarly remain Story 2.7's post-prereq-check concerns. The minimal schema extension keeps operator surface small + matches the iter-199 SC-5 "inherit not extend" discipline. [Source: 2-6-host-side-pnpm-devbox-cli-surface.md § Dev Notes SC-5; 2-7 SC-5; 2-8 SC-5; 2-9 SC-5]

**SC-7 — Probe image pinned at `alpine:3.19` with Renovate `docker` manager tracking.** See SC-4 rationale. The exact string `alpine:3.19` appears in: (a) `prereq-check.sh` source (Task 1); (b) `docs/invariants/devbox-prereq-check.md § Alpine probe image` section (Task 5); (c) `packages/devbox/README.md § Prerequisite check` reference (Task 6). Renovate tracks via standard image-reference auto-discovery; no custom regex manager needed (Story 1.15 baseline covers `docker` manager). Drift-detection: any future change to the image ref must update all three sites in a single commit (sync-gate will fail on hash-drift if `docs/invariants/devbox-prereq-check.md` is edited without manifest `contentHash` re-computation — Story 1.9 guarantees this). [Source: Story 1.15 Renovate config; Story 1.9 sync-gate]

**SC-8 — `unset COMPOSE_PROJECT_NAME` at top of prereq-check.sh.** Story 2.6 AI-8 (iter-212) + AI-12 (iter-217) + Stories 2.7/2.8/2.9 SC-10/SC-8/SC-8 defensive-posture precedent. Protects `keel-devbox_keel_home_dev` named-volume identity — a compose-project override would redirect the volume path away from `INV-devbox-homedev-named-volume`. Cost is 1 line; benefit is uniform substrate posture. [Source: Story 2.6 iter-212 AI-8 + iter-217 AI-12]

**SC-9 — No signal trapping on prereq-check.sh.** The script runs host-side-only (no `docker exec` inside; the alpine probe IS a `docker run` but the wrapper does not hold it open for interactive I/O). Signals would propagate to the alpine probe naturally via `docker run`'s own forwarding. Defensive trap handlers would have no effect under prereq-check's short-lived-synchronous-probe model. Follows Story 2.1 iter-144 SIGPIPE + Stories 2.7/2.8/2.9 SC-10 "no-signal-trap" posture.

**SC-10 — Container name / volume name derivation via env-var fallback.** Story 2.2 parameterised container + compose-project names via `.envrc`. Story 2.10's `VOLUME_NAME` derives from `KEEL_DEVBOX_COMPOSE_PROJECT` fallback (default `keel-devbox`) — the docker-compose-default volume-name scheme is `<project>_<volume-key>` (i.e. `keel-devbox_keel_home_dev`; verified via docker-compose.yml:170-171 + iter-212 AI-8 fix). Multi-fork / worktree operators who override `KEEL_DEVBOX_COMPOSE_PROJECT` get their scoped volume name automatically. [Source: Story 2.2 envrc parameterisation; docker-compose.yml:170-171 Story 2.5 named-volume]

**SC-11 — Wire-in to all 17 existing host-side shims is load-bearing for AC 5.** AC 5 "any `pnpm devbox:*` or `pnpm ralph:*` command" scopes the prereq-check to every verb. Task 4 wires Tier 1 into 15 shims (excluding prereq-check.sh itself); Task 3 wires Tier 2 into the 2 ralph verbs. TOTAL: 17 shims touched in Story 2.10. **Dev-agent guardrail:** when modifying each shim, REMOVE the existing inline `docker info --format '{{.ServerVersion}}' ...` block (3–4 lines) and REPLACE with a single `"$(dirname "${BASH_SOURCE[0]}")/prereq-check.sh" --tier1` invocation (1 line). Net: shim line-count decreases by ~2-3 lines each × 15 shims = ~35-line diff across the shim family. PLUS prereq-check.sh itself (~150 lines new). Other shim logic (container-state check, `exec` line, args handling) is UNCHANGED. [Source: § Project Structure Notes; Tasks 3 + 4]

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
- `packages/keel-invariants/src/invariants.manifest.ts` — register `INV-devbox-prereq-check` entry (6-line manifest block; 19 → 20 entries).
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

**No invariants.manifest.ts refactor:** Story 2.10 adds ONE manifest entry (19 → 20 entries). The existing entries are UNCHANGED. Schema (`InvariantSchema`) is UNCHANGED — Story 2.10 conforms; any schema evolution (adding optional fields) is a separate FR44 AMEND.

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

_(populated during dev-story implementation)_

### Completion Notes List

_(populated during dev-story implementation)_

### File List

_(populated during dev-story implementation)_

## Change Log

- v1.0 (2026-04-23) — Initial draft. 5 ACs + 6 tasks + 17 SCs. Scope carve-outs pinned: SC-2 upstream Docker Desktop owns install path + hardcoded URL at 1.0; SC-3 filesystem-based token probe (existence only, not validity); SC-4/SC-7 alpine:3.19 pin with Renovate `docker` manager tracking; SC-5 composite-message aggregation within Tier 2 + Tier 1 fails fast; SC-11 17-shim wire-in required for AC 5 "any pnpm devbox/ralph command"; SC-12 NEW shared primitive (first story-scoped `scripts/` lift in emerging `_lib.sh` refactor trajectory; iter-239 retrofit was non-story-scoped); SC-13 no compose/Dockerfile/entrypoint edits; SC-14 ralph.py TUI unchanged (Epic 3 scope); SC-15 no token content inspection; SC-17 read-only posture on Stories 2.6/2.7/2.8/2.9 README + AGENTS.md sections. File placement: standalone primitive at `packages/devbox/scripts/prereq-check.sh` (NOT `<verb>-host.sh` — primitive-naming per Story 2.3/2.4 pattern). INV-devbox-prereq-check registered in manifest + authoritative doc at `docs/invariants/devbox-prereq-check.md` (multi-section structure so each sub-contract hashes into `contentHash` per Story 2.3 iter-156 LESSON). ATDD skip forecast per FR14n matrix row 3 ground-(a)+(b)+(c) conjunction — TWENTIETH cumulative precedent. Trace WAIVED forecast — TWENTIETH cumulative precedent. CR forecast: 0–3 PATCH opener + candidate FIFTH one-pass ZERO-PATCH precedent if pattern holds under novel multi-shim-edit surface. Draft density: 5 ACs + 6 tasks + 17 SCs matches Stories 2.7/2.8/2.9 post-PATCH density; pre-dev SM gate expected 2-5 PATCHes (wider band than prior due to novel surfaces: multi-shim refactor, first Epic-2 new-INV entry, alpine-probe-image dependency, tier-dispatch argv). Projected lifecycle: iter-245 drafted → iter-246 validated → iter-247 atdd-scaffolded → iter-248 in-dev → iter-249 traced → iter-250 sm-verified → iter-251 done (7-iteration close if one-pass ZERO-PATCH holds; longer if novel surface generates CR iterations).
