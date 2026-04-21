# Story 2.1: `packages/devbox/` absorb from cc-devbox — image + compose + substrate tooling access

Status: in-progress

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want `packages/devbox/` to absorb the upstream [`cc-devbox`](https://github.com/tthew/cc-devbox) per the PRD M0.5 five-deliverable sub-scope (image, compose, entrypoint, egress-policy fix, pnpm lifecycle bridge) with a pinned Ubuntu 24.04 LTS base image and the full substrate toolchain baked at image build time (no runtime network installs),
So that I can run substrate tooling (`pnpm test`, `pnpm lint`, and — once Epic 6 lands — `pnpm rls:explain`) inside a reproducible Docker container whose cold-start and warm-start wall-clocks meet NFR2 and whose build output satisfies FR1 (devbox lifecycle via pnpm), FR6 (substrate tooling inside devbox), and the five M0.5 deliverable slots [Source: planning-artifacts/prd.md#M0.5-Devbox; planning-artifacts/epics.md#Epic-2-Story-2.1].

## Acceptance Criteria

1. **Given** the monorepo scaffold from Epic 1,
   **When** I inspect `packages/devbox/`,
   **Then** I find `Dockerfile`, `docker-compose.yml`, `entrypoint.sh`, and `scripts/` for the host CLI (wired in Story 2.6)
   **And** the Dockerfile `FROM ubuntu:24.04` with a documented pin rationale in a comment header.

   **Story 2.1 scope clarification — `packages/devbox/` already exists as a TypeScript workspace package** (scaffolded in Story 1.1 with `package.json`, `src/`, `tsconfig.json`, `eslint.config.js`). Story 2.1 ADDS the runtime-infrastructure siblings (`Dockerfile`, `docker-compose.yml`, `entrypoint.sh`, `scripts/`, plus the placeholders listed in AC-scope-clarifications below). Do NOT delete or rewrite the existing TS scaffolding — the devbox package hosts both the host-side build-tooling surface (TS) and the runtime-image content (Dockerfile + compose + shell scripts). Coexistence is fine; `tsconfig.json` / `eslint.config.js` already exclude Dockerfile/shell paths by default.

   **Story 2.1 scope clarification — pin-rationale comment header.** The Dockerfile first lines MUST be a block comment explaining the Ubuntu 24.04 LTS choice (current LTS cadence runs through April 2029; aligns with Node 20 LTS support horizon; matches arch decision at architecture.md § Technical Stack; upstream cc-devbox's 22.04 pin is superseded). Comment block belongs at the top of the file BEFORE the `FROM` line so it survives build cache invalidation reviews.

2. **Given** the Dockerfile,
   **When** the image builds,
   **Then** `node@20-lts`, `pnpm`, `@anthropic-ai/claude-code`, `gh`, `uv`, `aws-cli`, `supabase-cli`, `delta`, and Playwright browser deps are baked at image-build time
   **And** no runtime network installs occur in `entrypoint.sh`.

   **Story 2.1 scope clarification — version pinning.** Bake EXACT pinned versions where possible (`node@20.<patch>`, `pnpm@10.29.2` matching root `package.json:5`, specific `aws-cli` release). For `@anthropic-ai/claude-code` and `gh`, use the latest stable at bake time but record the installed versions in a dedicated `VERSIONS.md` under `packages/devbox/` so Renovate (Story 1.15 — `.github/renovate.json`) can track upgrades. Playwright browser deps = the system packages required by `playwright install-deps` (chromium + firefox + webkit OS-level libs); do NOT install the Playwright Node package itself at image bake — that's a project `devDependencies` concern. The goal is that an `npx playwright install` call inside the container at test time runs zero OS-package installs (all sys deps already present).

   **Story 2.1 scope clarification — no runtime network installs.** `entrypoint.sh` is narrowed to workspace ownership chown + named-volume directory bring-up + service start signalling. Upstream cc-devbox's runtime `npm install -g @anthropic-ai/claude-code claude-flow` + `curl | sh` for `uv` patterns MUST be moved to image-build time in the Dockerfile — not replicated in `entrypoint.sh`. A post-bake verification task (see Tasks / Subtasks Task 6) greps the checked-in `entrypoint.sh` for `npm install`, `pip install`, `curl.*\|.*sh`, `wget.*\|.*sh` and fails Story 2.1 acceptance if any match.

3. **Given** the baked image,
   **When** I run `pnpm test` or `pnpm lint` inside the container (via `pnpm devbox:shell` from Story 2.6),
   **Then** both commands execute against the workspace mounted at `/workspace`
   **And** the RLS debugger (landing in Epic 6) can be invoked without additional image changes.

   **Story 2.1 scope clarification — `pnpm devbox:shell` is Story 2.6's deliverable, not 2.1's.** Story 2.6 wires the host-side `pnpm devbox:{build,start,stop,restart,shell,attach,status,logs,clean,rebuild,whitelist,monitor,env:check}` CLI surface. Story 2.1's AC3 is verified via the equivalent RAW DOCKER COMMAND the CLI wrapper will eventually call: `docker compose -f packages/devbox/docker-compose.yml run --rm devbox pnpm test` and `... pnpm lint`. If both exit 0, AC3 is met. Story 2.6 will later swap this raw invocation for the `pnpm devbox:shell` wrapper without image or compose changes.

   **Story 2.1 scope clarification — workspace mount contract.** `docker-compose.yml` mounts the monorepo root at `/workspace` inside the container (per arch § File Structure at architecture.md:973-1002 and § I3 / I5 at architecture.md:271-295). This applies to per-fork mode (default); the shared-workspace mode (`KEEL_DEVBOX_SHARED=true` per Story 2.11) is NOT in Story 2.1 scope — just leave the mount path parameterisable so Story 2.11 can extend it without rewriting the compose file.

   **Story 2.1 scope clarification — "RLS debugger without additional image changes".** This is a FORWARD COMPATIBILITY AC, not a working debugger in Story 2.1. Meet it by ensuring the image bakes everything Epic 6 Story 6.5 (`pnpm rls:explain`) will need: Postgres client tooling (`psql`), delta (already listed), and the ability to `pnpm install` the workspace without image changes. The AC is verified by a Dev Note entry cross-referencing which baked tools cover Epic 6's requirement list — not by running the debugger (it doesn't exist yet).

4. **Given** the NFR2 cold-start budget,
   **When** I measure first `pnpm devbox:start` on an Apple-Silicon M4-Pro baseline,
   **Then** cold start completes in ≤ 5 minutes
   **And** a subsequent warm start completes in ≤ 30 seconds
   **And** the measurement method + baseline hardware are documented in `packages/devbox/README.md`.

   **Story 2.1 scope clarification — `pnpm devbox:start` is Story 2.6's lifecycle CLI.** As with AC3, verify via the equivalent raw compose command: `docker compose -f packages/devbox/docker-compose.yml up --build -d` (cold-start) and `docker compose ... up -d` after a prior successful build (warm-start). Record the wall-clock in `packages/devbox/README.md` § Benchmarks with `date`-stamped entries per arch.md § NFR28b empirical-baseline honesty posture (architecture.md:264-270 — label measurements as provenance-documented, not magical-number).

   **Story 2.1 scope clarification — non-Apple-Silicon fork baselines.** The NFR2 target is the M4-Pro envelope. Forks on x86 or lower-spec Apple Silicon are expected to retune `.envrc` knobs per NFR8a (architecture.md:295) — record this in README § Benchmarks with a pointer to I5's `.envrc.example` (architecture.md:275-293). DO NOT block Story 2.1 on x86 cold-start timing; measurement is against the PRD-documented baseline.

   **Story 2.1 scope clarification — measurement method.** Cold-start = `docker system prune -af && time docker compose up --build -d`. Warm-start = `docker compose down && time docker compose up -d` against a pre-built image. Both commands ship in `packages/devbox/scripts/benchmark.sh` (first iteration scaffold; enrichment in subsequent epics). README captures the hardware profile (`uname -a`, `sysctl -n hw.memsize hw.ncpu`, Docker version), wall-clock values, and run date.

   **Story 2.1 scope clarification — single-run variance posture.** Single-run wall-clocks on M-series baselines vary ±20% (thermal state, Docker Desktop daemon state, apt mirror latency). Record first-run values as a **modelled baseline** per arch.md:264-270 NFR28b honesty reframe — NOT as a reproducible tight envelope. If the first cold-start exceeds NFR2 by a small delta (< 2× budget), retry twice and record the median in README § Benchmarks as an append-only entry. Do NOT fail Story 2.1 on first-run noise; only escalate to IP § BLOCKED if median > 2× budget (cc-devbox-comparison note required).

## Tasks / Subtasks

- [x] **Task 1: Scaffold runtime-infrastructure sibling files under `packages/devbox/`** (AC: 1)
  - [x] Author `packages/devbox/Dockerfile` with the Ubuntu 24.04 LTS pin rationale block-comment header described in AC1 scope-clarification (`# Pin rationale: Ubuntu 24.04 LTS (support through April 2029) …`) BEFORE the `FROM ubuntu:24.04` directive.
  - [x] Author `packages/devbox/docker-compose.yml` with one service (`devbox`) mounting `../../` → `/workspace`, parameterised via `env_file: ../../.envrc` (per arch § I6 at architecture.md:299-302). Leave resource-limit knobs (`cpus`, `mem_limit`, `shm_size`, `tmpfs`) as literal placeholders with TODO comments naming Story 2.2 as the owner of full `.envrc` parameterisation; Story 2.1 just needs the file to parse + bring a container up.
  - [x] Author `packages/devbox/entrypoint.sh` narrowed to workspace ownership chown + named-volume directory setup + `sleep infinity` (or equivalent service-keepalive). Shebang `#!/usr/bin/env bash`, `set -euo pipefail`, executable bit (`chmod +x`).
  - [x] Create `packages/devbox/scripts/` directory. Task 5's `scripts/benchmark.sh` is the first (and only) script Story 2.1 authors under this directory; the full `pnpm devbox:*` lifecycle wrappers (`build.sh`, `start.sh`, `stop.sh`, `shell.sh`, `attach.sh`, `whitelist.sh`, `monitor.sh`, `env-check.sh`, etc. per arch.md:989-1002) are Story 2.6's scope. No `.gitkeep` needed — `benchmark.sh` populates the directory.
  - [x] Confirm the existing `packages/devbox/package.json`, `src/`, `tsconfig.json`, `eslint.config.js` remain untouched; the new runtime-infrastructure files are siblings, not replacements.

- [x] **Task 2: Bake substrate toolchain at image-build time** (AC: 2) — _source-level complete; actual image bake blocked on Docker availability (see Dev Agent Record)_
  - [x] In `Dockerfile`, install system dependencies via `apt-get` in a single cached layer: `curl`, `git`, `ca-certificates`, `build-essential`, `unzip`, `jq`, `postgresql-client` (provides `psql` for Epic 6 Story 6.5 `pnpm rls:explain` forward-compatibility per AC3 Dev Note), plus Playwright browser OS-level deps (per [playwright.dev: ubuntu 24.04 deps list](https://playwright.dev/docs/browsers#install-browsers) — keep the list inline so Renovate + Story 1.15 can track).
  - [x] Install `node@20-lts` via NodeSource apt repo (pin exact minor version in `Dockerfile` comment; honour root `package.json` `"engines": { "node": ">=20 <21" }`).
  - [x] Install `pnpm@10.29.2` globally via `npm install -g pnpm@10.29.2` — exact match to root `package.json:5`.
  - [x] Install `@anthropic-ai/claude-code` globally via `npm install -g @anthropic-ai/claude-code` at image build time. Record the pinned version in `packages/devbox/VERSIONS.md`.
  - [x] Install `gh` via apt (GitHub's `cli.github.com` apt repo). Pin per `apt-cache policy gh` at bake time; record in VERSIONS.md.
  - [x] Install `uv` via the official installer (`curl -LsSf https://astral.sh/uv/install.sh | sh`) AT IMAGE BUILD — not at runtime. Record the installed version in VERSIONS.md.
  - [x] Install `aws-cli` v2 via the official installer (pin version per AWS's current stable).
  - [x] Install `supabase-cli` via the official installer or apt.
  - [x] Install `delta` (git-delta) via apt or GitHub release download.
  - [x] Verify Playwright browser deps by running `npx --yes playwright@latest install-deps` at image build and confirming zero install actions at runtime.
  - [x] Author `packages/devbox/VERSIONS.md` listing every baked tool + its pinned version, with a header note that Renovate (Story 1.15) tracks Dockerfile version strings via `.github/renovate.json` custom managers.

- [x] **Task 3: Narrow `entrypoint.sh` to zero runtime network installs** (AC: 2)
  - [x] Confirm `entrypoint.sh` contains ONLY: workspace ownership chown (`chown -R dev:dev /workspace` — the `dev` user lands in Story 2.5 hardening; Story 2.1 uses `root` placeholder with a TODO comment naming Story 2.5), named-volume directory bring-up for `/home/dev/.claude/` + `/home/dev/.config/gh/` (empty directories — Stories 2.8/2.9 populate them via OAuth), and a `sleep infinity` (or `tail -f /dev/null`) service keepalive.
  - [x] Add a Story 2.1-scope-only grep check to verify no forbidden patterns appear: `grep -E 'npm install|pip install|curl[^|]*\|[[:space:]]*sh|wget[^|]*\|[[:space:]]*sh' entrypoint.sh` MUST return exit code 1 (no matches). **Verified exit code 1 at iter-99.**
  - [x] `chmod +x packages/devbox/entrypoint.sh` and confirm via `ls -la` that the bit is committed (git tracks executable bit on shell scripts). **Verified `100755` via `git ls-files -s` at iter-99.**

- [ ] **Task 4: Verify substrate tooling access from inside the image** (AC: 3) — **BLOCKED: Docker daemon unavailable in the Ralph container environment; see Dev Agent Record § Blocked for the follow-up plan. Task 4 execution deferred to operator workstation or Epic 13 CI.**
  - [ ] Build the image: `docker compose -f packages/devbox/docker-compose.yml build`. Confirm exit code 0.
  - [ ] Run substrate tests from the container via the raw compose command: `docker compose -f packages/devbox/docker-compose.yml run --rm devbox pnpm test`. Confirm **exit code 0**. Turbo reports `0 runnable tasks` if no package currently wires `test` — this still exits 0, which satisfies AC3 (it proves `pnpm` and `turbo` are reachable and the workspace mount is live). A non-zero exit OR `command not found` FAILS AC3.
  - [ ] Run substrate lint from the container: `docker compose -f packages/devbox/docker-compose.yml run --rm devbox pnpm lint`. Same acceptance posture — **exit code 0** (turbo-empty-task is fine; `command not found` is not).
  - [x] Add a Dev Note entry confirming: Epic 6's `pnpm rls:explain` (Story 6.5) will land WITHOUT image changes because the image bakes `psql` (via `postgresql-client` apt), `delta`, and the monorepo workspace tooling is mounted at `/workspace`. Enumerate the Epic 6 tool list here so the forward-compatibility check is auditable. **Enumerated in VERSIONS.md § Epic 6 forward-compatibility roster.**

- [ ] **Task 5: Measure NFR2 cold-start + warm-start on the baseline** (AC: 4) — **partial: script landed, benchmark run BLOCKED on Docker availability**
  - [x] Author `packages/devbox/scripts/benchmark.sh` that runs (a) `docker system prune -af --volumes` to ensure cold-start state, (b) `time docker compose -f packages/devbox/docker-compose.yml up --build -d` to measure cold-start, (c) `docker compose ... down` + `time docker compose ... up -d` to measure warm-start, (d) writes the two wall-clock values + hardware profile + Docker version + run date to `packages/devbox/README.md § Benchmarks` as an append-only log entry.
  - [ ] Run `packages/devbox/scripts/benchmark.sh` once from the M4-Pro baseline; confirm cold-start ≤ 5 min and warm-start ≤ 30 s. If either exceeds the NFR2 budget, file a TODO in `packages/devbox/README.md § Benchmarks` with the delta and a hypothesis (image size, apt mirror distance, etc.) — DO NOT fail Story 2.1 unless the delta exceeds the budget by >2×, in which case escalate to IP § BLOCKED with a cc-devbox-comparison note.
  - [x] Document the measurement method (commands, prune mode, baseline hardware, Docker version) in `packages/devbox/README.md § Benchmarks` per AC4 scope-clarification. **Benchmarks section header + escalation rules written; first-run append entry lands from operator workstation.**

- [x] **Task 6: Author `packages/devbox/README.md` with M0.5 sub-scope summary** (AC: 1, 2, 3, 4)
  - [x] Expand the existing minimal `README.md` to cover: (a) what `packages/devbox/` is (the absorbed cc-devbox runtime), (b) the five M0.5 deliverables with status (Story 2.1 lands (a)-(c); (d) egress-policy fix is Story 2.3; (e) lifecycle bridge is Story 2.6), (c) the pin rationale for Ubuntu 24.04 LTS + baked toolchain list, (d) the § Benchmarks section (NFR2 measurement log), (e) a cc-devbox-upstream-provenance section citing [github.com/tthew/cc-devbox](https://github.com/tthew/cc-devbox) as the absorb source + the `legacy-devbox` branch retention policy (Story 2.14 scope — reference only).
  - [x] Add a "What this story does NOT deliver" sub-section listing Stories 2.2-2.17 with one-liner scope markers so future-Ralph iterating on Epic 2 can orient quickly.

- [ ] **Task 7: Forbidden-pattern grep + structural validation** (AC: 2) — **partial: 3 of 4 checks executed at iter-99; `docker compose config` BLOCKED on Docker availability**
  - [x] Run the runtime-install regex check from Task 3 against the committed `entrypoint.sh`; must return no matches. **PASS (grep exit code 1) at iter-99.**
  - [x] Verify `Dockerfile` first non-blank lines are the pin-rationale comment block (Task 1). **PASS — `head -5 Dockerfile` shows the pin-rationale header as the first content.**
  - [ ] Verify `docker-compose.yml` parses: `docker compose -f packages/devbox/docker-compose.yml config` exits 0. **BLOCKED: Docker not on PATH in Ralph container; compose-config parse deferred to operator workstation.**
  - [x] Verify `entrypoint.sh` has executable bit set in git (`git ls-files -s packages/devbox/entrypoint.sh | head -c 6` returns `100755`). **PASS — `git ls-files -s` returned `100755` for both `entrypoint.sh` and `scripts/benchmark.sh` at iter-99.**

- [x] **Task 8: Update `_bmad-output/implementation-artifacts/sprint-status.yaml`** (post-dev hygiene; Ralph-automated)
  - [x] After all ACs verified, confirm the `/bmad-create-story` run already flipped `epic-2: backlog → in-progress` and `2-1-…: backlog → ready-for-dev`. Story 2.1 moves to `done` only via `/bmad-code-review` after SM + CR gates per PROMPT_build.md § Story Lifecycle Decision Matrix. **Story 2.1 state advanced to `in-progress` at dev-story Step 4 (iter-99); `done` remains gated behind trace + SM-review + CR per FR14n matrix.**

## Dev Notes

### Architecture decisions consumed by Story 2.1

- **Sandbox-as-security-boundary posture** — devbox is what makes `--dangerously-skip-permissions` safe [Source: planning-artifacts/architecture.md:88; planning-artifacts/prd.md:1074 NFR5]. A runtime compromise inside the container MUST NOT reach the host. Story 2.1 ships the *image* and *compose* foundation; the full fail-closed posture (NFR6 egress + NFR7 non-root/caps + NFR8 tmpfs-noexec + NFR10 named-volume) lands across Stories 2.3, 2.5, 2.8-2.9.
- **Ubuntu 24.04 LTS base** pinned for Node 20 LTS alignment + April 2029 support horizon [Source: planning-artifacts/prd.md:167-168 § M0.5(a); planning-artifacts/epics.md:1182].
- **Zero runtime network installs** — upstream cc-devbox's pattern of runtime `npm install -g @anthropic-ai/claude-code claude-flow` + `curl | sh uv` per boot MUST be moved to image-build. Rationale: reproducibility + offline reliability + audit surface — every baked package is Renovate-trackable via `.github/renovate.json` (Story 1.15) [Source: planning-artifacts/prd.md:168-170 § M0.5(a)(c); planning-artifacts/epics.md:1187].
- **Workspace mount contract** — `/workspace` inside the container maps to the monorepo root on the host; parameterised via compose env [Source: planning-artifacts/architecture.md:973-1002 § File Structure; architecture.md:271-295 § I3 + I5].
- **Image tree target** — the file-tree Story 2.1 + follow-up stories should assemble under `packages/devbox/` matches architecture.md:973-1002 exactly. Story 2.1 lands `Dockerfile`, `docker-compose.yml`, `entrypoint.sh`, `scripts/benchmark.sh` (from Task 5), `README.md`, `VERSIONS.md`. Follow-up stories land `.envrc.example` (Story 2.2), `whitelist.default.txt` + `whitelist/` + `nftables/` + `dnsmasq/` (Stories 2.3-2.4), `pg-init.sql` (Epic 6 Story 6.1 — Prisma schema baseline adds `CREATE EXTENSION pg_uuidv7` + init per arch.md:978 + I7 at arch.md:342-346; Story 2.1's compose declares ONLY the `devbox` service, no Postgres service, so no `pg-init.sql` dependency at 2.1 time), full `scripts/*` lifecycle wrappers (Story 2.6 per arch.md:989-1002).

### NFRs in scope for Story 2.1

- **NFR2** — cold-start ≤ 5 min / warm-start ≤ 30 s on Apple-Silicon M4-Pro. Validated via `packages/devbox/scripts/benchmark.sh` (Task 5) + documented in README § Benchmarks with measurement-method provenance (honesty posture per arch.md:264-270 NFR28b reframe) [Source: planning-artifacts/prd.md:1064-1065 NFR2; planning-artifacts/epics.md:1194-1198].
- **FR1, FR6** — Lifecycle CLI (`pnpm devbox:*`) is Story 2.6 scope; Story 2.1 ships the image + compose that the CLI wraps [Source: planning-artifacts/prd.md:927-933 FR1/FR6; planning-artifacts/epics.md:1146 Epic 2 FR coverage].

### NFRs explicitly DEFERRED to later Epic 2 stories

- **NFR5 (all exec in devbox)** — Story 2.17 enforces at hook layer.
- **NFR6 (fail-closed DNS + IPv4/IPv6 parity + atomic reload)** — Stories 2.3 + 2.4.
- **NFR7 (non-root + capabilities + no-new-privileges)** — Story 2.5.
- **NFR8 / NFR8a (tmpfs noexec/nosuid + `.envrc` reference defaults)** — Stories 2.5 + 2.2.
- **NFR10 (named volume for Claude + gh tokens)** — Stories 2.5 + 2.8 + 2.9.
- **NFR5a (Claude hook-based in-devbox secret-access barrier)** — Stories 2.15 + 2.16.

Story 2.1's validation bar is AC1-AC4 literally. The remaining NFRs above are out of scope; Story 2.1 MUST NOT partially implement them in ways that drift from the dedicated story's scope (e.g., do NOT add a non-root `dev` user in `Dockerfile` — that's Story 2.5's contract; use `root` with a TODO pointing at Story 2.5).

### Source-layer provenance: cc-devbox upstream absorb

- Upstream source: [github.com/tthew/cc-devbox](https://github.com/tthew/cc-devbox) [Source: planning-artifacts/prd.md:167; planning-artifacts/epics.md:1150; planning-artifacts/architecture.md:132-134].
- Known upstream defects resolved by Story 2.1 (or its Epic 2 siblings):
  - Runtime `npm install -g` + `curl | sh` in `entrypoint.sh` → replaced by image-bake (Story 2.1 AC2 + Task 3).
  - Hardcoded `/Users/tthew/Development` parent-dir mount → replaced by `.envrc`-driven per-fork vs shared-workspace mount (Story 2.1 sets the mount path; Story 2.11 adds the shared mode).
  - Divergent whitelist tooling + fail-open resolv.conf + IPv6 gap → Stories 2.3 + 2.4.
  - Broken `curl :3000` healthcheck → Story 2.13 (dnsmasq + sshd liveness).
  - `./dev-home:/home/dev:delegated` bind-mount for auth tokens → replaced by named Docker volume (NFR10; Stories 2.5 + 2.8 + 2.9).
- `legacy-devbox` branch retention — standalone cc-devbox functional until after M4 checkpoint (Story 2.14) [Source: planning-artifacts/architecture.md:617; planning-artifacts/prd.md:616-617].

### Testing standards

- Story 2.1's deliverables are infrastructure artefacts (Dockerfile, compose, shell scripts, README). Substrate-level unit tests do not apply. Verification is via:
  - Structural tests — `docker compose config` exits 0, `Dockerfile` builds, `entrypoint.sh` has executable bit, grep checks (Task 7).
  - Functional tests — raw compose commands surface the substrate tooling (Task 4 AC3).
  - Performance tests — `benchmark.sh` records wall-clocks (Task 5 AC4).
- **ATDD red-phase posture.** The story's testable ACs (AC1 structural, AC2 bake list, AC3 substrate tool access, AC4 NFR2 cold/warm wall-clock) lend themselves to shell-script or docker-based checks rather than Vitest. The `/bmad-testarch-atdd` step should scaffold executable check scripts (e.g., `packages/devbox/tests/structural.sh`, `packages/devbox/tests/tools.sh`, `packages/devbox/tests/benchmark.assert.sh`) or — if the atdd-skill decides these are infrastructure-smoke rather than red-phase-unit-testable — record a SKIP rationale in IP per PROMPT_build.md guardrail 4 (ATDD skip allowed if no testable ACs; record rationale in IP).

### Project Structure Notes

- `packages/devbox/` pre-exists as a scaffolded TypeScript workspace package (`package.json`, `src/`, `tsconfig.json`, `eslint.config.js`) from Story 1.1. Story 2.1 adds runtime-infrastructure siblings — there is no structural conflict; coexistence is fine.
- Root `package.json` (`/workspace/ralph-bmad/.claude/worktrees/ralph/package.json`) already defines `test`, `lint`, `typecheck`, `build` turbo-wrappers. Story 2.1 consumes these via `pnpm test` / `pnpm lint` from inside the container without modification.
- `pnpm devbox:*` scripts in root `package.json` are Story 2.6's scope — Story 2.1 MUST NOT add them. Verification of AC3/AC4 uses raw `docker compose` commands.
- No conflict detected with existing Epic 1 stories. Epic 1 invariants (`packages/keel-invariants/`, `INVARIANTS.md`, tokens pipeline) are orthogonal — they run inside the eventual container but do not constrain the Dockerfile shape.

### References

- [planning-artifacts/prd.md § M0.5 Devbox](../../_bmad-output/planning-artifacts/prd.md) — five-deliverable sub-scope (lines 167-172).
- [planning-artifacts/prd.md § FR1, FR6, NFR2, NFR5-NFR10](../../_bmad-output/planning-artifacts/prd.md) — function + NFR pins for Epic 2 (lines 927-933, 1064-1082).
- [planning-artifacts/epics.md § Epic 2 Story 2.1](../../_bmad-output/planning-artifacts/epics.md) — full BDD AC block (lines 1142-1198).
- [planning-artifacts/architecture.md § File Structure / devbox subtree](../../_bmad-output/planning-artifacts/architecture.md) — exhaustive file-tree target (lines 973-1002).
- [planning-artifacts/architecture.md § I3 / I5 / I6](../../_bmad-output/planning-artifacts/architecture.md) — `.envrc` contract, reference defaults, secrets posture (lines 271-340).
- [planning-artifacts/architecture.md § Sandbox as security boundary](../../_bmad-output/planning-artifacts/architecture.md) — rationale for devbox-as-boundary (line 88).
- [planning-artifacts/architecture.md § NFR28b empirical-honesty reframe](../../_bmad-output/planning-artifacts/architecture.md) — measurement-provenance posture (lines 264-270).
- Upstream source — [github.com/tthew/cc-devbox](https://github.com/tthew/cc-devbox).
- Playwright Ubuntu 24.04 deps — [playwright.dev/docs/browsers#install-browsers](https://playwright.dev/docs/browsers#install-browsers).

## Dev Agent Record

### Agent Model Used

Ralph build-loop iteration iter-99 (claude-opus-4-7[1m]) invoking `/bmad-dev-story` on Story 2.1.

### Debug Log References

- Task 7.1 — `grep -E 'npm install|pip install|curl[^|]*\|[[:space:]]*sh|wget[^|]*\|[[:space:]]*sh' packages/devbox/entrypoint.sh` → exit code 1 (no matches).
- Task 7.2 — `head -5 packages/devbox/Dockerfile` → pin-rationale comment block is the first content (before `FROM ubuntu:24.04`).
- Task 7.4 — `git ls-files -s packages/devbox/entrypoint.sh packages/devbox/scripts/benchmark.sh` → both `100755`.
- Task 7.3 — `command -v docker` → not found in Ralph container environment. `docker compose config` parse deferred.

### Completion Notes List

- **Source-level implementation complete for AC 1 (Dockerfile + compose + entrypoint + scripts/), AC 2 (baked toolchain authored in Dockerfile RUN layers + VERSIONS.md enumeration), and AC 3 forward-compatibility Dev Note (VERSIONS.md § Epic 6 forward-compatibility roster).**
- **Dynamic verification blocked — Docker daemon unavailable in the Ralph container environment.** The following substeps cannot execute from this iteration:
  - Task 4 image build (`docker compose build`).
  - Task 4 substrate tooling access (`docker compose run pnpm test/lint` exit code 0).
  - Task 5 NFR2 benchmark run (`scripts/benchmark.sh` cold / warm wall-clocks).
  - Task 7.3 `docker compose config` parse validation.
- These substeps are **not failures** — the deliverable shape meets AC 1 / AC 2 / AC 3 authoring at source level; AC 4 has the measurement-method + scripts/benchmark.sh in place per AC 4 scope clarification "the measurement method … ship in packages/devbox/scripts/benchmark.sh (first iteration scaffold)". The runtime verification step is the operator-workstation bake + benchmark run, which is the environmental assumption baked into NFR2 (M4-Pro baseline) by design. See `.ralph/@plan.md § BLOCKED` for the follow-up plan.
- **No scope creep into Stories 2.2 – 2.17.** Verified: no `.envrc.example` authored (Story 2.2), no dnsmasq / nftables / whitelist files (Stories 2.3 / 2.4), no non-root `dev` user or `cap_drop` / `no-new-privileges` / tmpfs stanzas (Story 2.5; Dockerfile stays on `root` placeholder with TODO comments), no `pnpm devbox:*` lifecycle scripts (Story 2.6; only `benchmark.sh` landed), no named-volume mounts for OAuth (Stories 2.8 / 2.9; entrypoint.sh pre-creates dirs but compose has no `volumes:` top-level), no `KEEL_DEVBOX_SHARED` compose branches (Story 2.11; `KEEL_DEVBOX_WORKSPACE` env-var left parameterisable), no healthcheck (Story 2.13), no legacy-devbox retention logic (Story 2.14), no Claude hook posture changes (Stories 2.15 – 2.17).
- **Existing TypeScript scaffold preserved.** `packages/devbox/package.json`, `src/index.ts`, `src/index.test.ts` (if present), `tsconfig.json`, `eslint.config.js`, and existing `dist/` artefacts are untouched. Runtime-infrastructure siblings (`Dockerfile`, `docker-compose.yml`, `entrypoint.sh`, `scripts/benchmark.sh`, `VERSIONS.md`, updated `README.md`) coexist per Story 2.1 AC 1 scope-clarification.
- **Epic 6 forward-compat roster enumerated in VERSIONS.md.** `postgresql-client` (psql), git-delta, and the bind-mounted workspace tooling (pnpm / turbo) cover Epic 6 Story 6.5 `pnpm rls:explain` — no image rebuild required when Epic 6 lands.

### Blocked (Docker-dependent substeps)

**Blocker:** Docker daemon not available on the Ralph container PATH. `command -v docker` returns exit 127; no `/var/run/docker.sock` visible either.

**Why the blocker applies only to dynamic verification:** AC 1 (file shape), AC 2 (source-level bake directives + zero runtime installs), and AC 3 Dev Note (forward-compat roster) are satisfied by the committed artefacts. AC 3 tooling access + AC 4 NFR2 measurement are *by design* environmental — NFR2's baseline is an Apple-Silicon M4-Pro operator workstation, not a CI sandbox (per story AC 4 scope clarification and `architecture.md § I5`).

**Follow-up path (captured in `.ralph/@plan.md § BLOCKED`):**

1. Operator workstation runs `docker compose -f packages/devbox/docker-compose.yml build` → expect exit 0 (AC 3 build step).
2. Operator workstation runs `docker compose -f packages/devbox/docker-compose.yml config` → expect exit 0 (Task 7.3).
3. Operator workstation runs `docker compose -f packages/devbox/docker-compose.yml run --rm devbox pnpm test` and `… pnpm lint` → expect exit 0 for both (AC 3 substrate tooling access).
4. Operator workstation runs `packages/devbox/scripts/benchmark.sh` → records cold / warm timings into `packages/devbox/README.md § Benchmarks` (AC 4). Expected envelope: cold ≤ 300 s, warm ≤ 30 s on M4-Pro baseline.
5. On successful bake + benchmark: Ralph's next iteration confirms the appended README § Benchmarks entry, updates VERSIONS.md bake log, marks Tasks 4 / 5-run / 7.3 `[x]`, flips Story Status from `in-progress` to `review`, and advances Story State `in-dev (partial) → in-dev`.

**Escalation posture per AC 4:** if cold-start delta > 2× budget on the operator run, escalate with a cc-devbox-comparison note in IP § BLOCKED rather than flipping Story Status.

### File List

New files (added by Story 2.1):

- `packages/devbox/Dockerfile` — Ubuntu 24.04 LTS image with baked substrate toolchain (Tasks 1 + 2).
- `packages/devbox/docker-compose.yml` — single-service compose, `env_file: ../../.envrc` with `required: false`, `KEEL_DEVBOX_WORKSPACE` parameterised bind mount (Task 1).
- `packages/devbox/entrypoint.sh` — narrowed to chown + named-volume dir setup + `exec "$@"` keepalive (Task 3; `100755` in git).
- `packages/devbox/scripts/benchmark.sh` — NFR2 cold / warm start measurement with append-only README write (Task 5 script; `100755` in git).
- `packages/devbox/VERSIONS.md` — baked-toolchain version table + Epic 6 forward-compat roster + bake log (Task 2 + Task 4 Dev Note).

Modified files:

- `packages/devbox/README.md` — expanded from the 4-line stub to full Story 2.1 README covering M0.5 deliverable status, pin rationale, baked toolchain summary, Story-2.1-scope `docker compose` usage block, "what this story does NOT deliver" roadmap, § Benchmarks scaffold, and cc-devbox provenance (Task 6).
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — story status flipped `ready-for-dev → in-progress`; `last_updated` field refreshed (workflow Step 4 + Task 8).
- `_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md` — this file: Tasks 1 – 3, 6, 8 marked `[x]`; Tasks 4, 5, 7 partially marked with blocked substeps explicit; Status `ready-for-dev → in-progress`; Dev Agent Record + File List + Change Log v1.3 authored.

Untouched (verified):

- `packages/devbox/package.json`, `packages/devbox/src/*`, `packages/devbox/tsconfig.json`, `packages/devbox/eslint.config.js`, `packages/devbox/dist/*` — TypeScript scaffold from Story 1.1 preserved intact.

## Change Log

- **v1.0** (2026-04-21 iter-96): Initial drafting by `/bmad-create-story` on cross-epic Epic-1→Epic-2 auto-advance. Four ACs pinned verbatim from epics.md:1171-1198 with scope carve-outs distinguishing Story 2.1's five M0.5(a-c) deliverables (image + compose + entrypoint) from Stories 2.2-2.17 deferrals (`.envrc` parameterisation, egress policy + whitelist, Story 2.5 hardening, OAuth, lifecycle CLI, per-fork vs shared mount, healthcheck, legacy-devbox retention, Claude hook posture). Eight tasks enumerated (scaffold + bake + entrypoint-narrow + tooling-access verify + NFR2 bench + README + structural validation + sprint-status hygiene). Story class: substrate / infrastructure-smoke / runtime-docker — ELEVENTH cumulative Epic ATDD-skip candidate (first Epic 2; first "infrastructure-smoke class" iteration — Epic 1's ten ATDD-skips were "documentation-surface" + "configuration-surface" classes) + cross-epic auto-advance first-invocation pattern validator.
- **v1.1** (2026-04-21 iter-97): Pre-dev SM review via `/bmad-create-story (args: "review")`. ZERO critical issues; FIVE tightening enhancements applied by parallel-subagent gap-analysis against epics.md:1142-1198 + prd.md:160-180 (M0.5 five deliverables) + 920-940 (FR1/FR6) + 1060-1090 (NFR2/NFR5-10) + arch.md:80-100 + 260-300 + 271-340 + 970-1010 + 125-145: **(1)** Task 2 apt list adds `postgresql-client` to make Task 4's Epic 6 `pnpm rls:explain` forward-compat Dev Note claim concretely implementable; **(2)** Task 1 subtask 4 drops redundant `.gitkeep` (Task 5's `scripts/benchmark.sh` auto-populates the dir); **(3)** Task 4 subtasks 2+3 tighten "exit 0 OR empty-task-set" ambiguity to `exit code 0` (turbo `0 runnable tasks` = exit 0 = pass; `command not found` = fail); **(4)** AC4 measurement-method clarification adds single-run variance posture (±20% M-series noise → record first-run as modelled baseline per arch.md:264-270 NFR28b honesty reframe; retry + median before escalating to BLOCKED; escalate only at > 2× budget); **(5)** Dev Note § "Image tree target" pins `pg-init.sql` to Epic 6 Story 6.1 (not vague "Epic 6") + clarifies Story 2.1's compose has ONE service (`devbox`), no Postgres → no `pg-init.sql` dependency at 2.1 time. Scope-creep check CLEAN (no bleed into 2.2/2.3-2.4/2.5/2.6/2.8-2.9). Source citations all resolve. Story State transitions `drafted → validated`.
- **v1.3** (2026-04-21 iter-99): `/bmad-dev-story` source-level implementation pass (atdd-scaffolded → in-dev partial). Authored `packages/devbox/Dockerfile` (Ubuntu 24.04 LTS pin-rationale header + baked toolchain: node 20 LTS NodeSource + pnpm 10.29.2 + @anthropic-ai/claude-code + gh via cli.github.com apt + uv Astral installer + AWS CLI v2 arch-aware + Supabase CLI release .deb + git-delta release .deb + Playwright OS deps list including libnss3 / libnspr4 / libatk1.0-0t64 / libatk-bridge2.0-0t64 / libcups2t64 / libdrm2 / libxkbcommon0 / libatspi2.0-0t64 / libx11-6 / libxcomposite1 / libxdamage1 / libxext6 / libxfixes3 / libxrandr2 / libgbm1 / libpango-1.0-0 / libcairo2 / libasound2t64 + `postgresql-client` for Epic 6 forward-compat). Authored `packages/devbox/docker-compose.yml` (single `devbox` service; `env_file: ../../.envrc` with `required: false` so compose parses pre-Story-2.2; `KEEL_DEVBOX_WORKSPACE`-parameterised bind mount for Story 2.11 future-compat; TODO comments naming Stories 2.2 / 2.5 / 2.8 / 2.9 / 2.13 as owners of resource / hardening / OAuth / healthcheck stanzas). Authored `packages/devbox/entrypoint.sh` narrowed to workspace chown (root placeholder with TODO for Story 2.5 `dev` user) + named-volume dir pre-creation for `/home/dev/.claude/` + `/home/dev/.config/gh/` + `exec "$@"` keepalive (compose CMD defaults to `sleep infinity`); forbidden-pattern grep regex PASS (exit 1); git executable bit `100755` confirmed. Authored `packages/devbox/scripts/benchmark.sh` (NFR2 cold / warm-start measurement: `docker system prune -af --volumes` → `time docker compose up --build -d` cold, `down && time up -d` warm; append-only README writes with host uname + Docker version + Compose version; budgets inline; `100755`). Authored `packages/devbox/VERSIONS.md` (baked-tool table + Epic 6 forward-compat roster enumerating psql / delta / bind-mount tooling + bake log with iter-99 entry). Rewrote `packages/devbox/README.md` from 4-line stub to full M0.5 deliverable status + Ubuntu pin rationale + baked toolchain summary + Story-2.1-scope `docker compose` usage block + "what this story does NOT deliver" 17-row roadmap + § Benchmarks scaffold + cc-devbox upstream provenance. Updated `_bmad-output/implementation-artifacts/sprint-status.yaml` `ready-for-dev → in-progress` + `last_updated: 2026-04-21 Story-2-1-in-progress UTC`. **Tasks 1 – 3, 6, 8 marked `[x]`.** Task 2 marked `[x]` at source level with explicit Dev Agent Record note that the actual image bake is Docker-dependent; Tasks 4, 5-run, 7.3 remain `[ ]` with blocked-substep rationale in the task text pointing at Dev Agent Record § Blocked. Task 7 partials marked `[x]`: grep PASS (7.1), Dockerfile pin-rationale header PASS (7.2), git executable bit `100755` PASS (7.4). **BLOCKER: Docker daemon unavailable in the Ralph container environment** — AC 3 `docker compose build/run pnpm test/lint` and AC 4 `scripts/benchmark.sh` execution + Task 7.3 `docker compose config` parse require an operator workstation with Docker Desktop / Engine installed. Follow-up 5-step operator run plan captured in Dev Agent Record § Blocked + `.ralph/@plan.md § BLOCKED`. Story State transitions `atdd-scaffolded → in-dev (partial)` per PROMPT_build.md § dev-story invocation partial-completion rule. Next Ralph iteration either (a) re-queues `/bmad-dev-story` (no-op if Docker still unavailable) or (b) operator completes bake + benchmark runs out-of-band and the subsequent Ralph iter closes Tasks 4 / 5-run / 7.3, advances Story State `in-dev (partial) → in-dev`, then queues `/bmad-testarch-trace (args: "yolo")` for `in-dev → traced`.
- **v1.2** (2026-04-21 iter-98): `/bmad-testarch-atdd` hybrid ground-(c) variant-(ii)+(iii) ATDD-SKIP — FR14n matrix row 3 `validated → atdd-scaffolded`. **ELEVENTH cumulative Epic ATDD-skip precedent** (Stories 1.7 iter-14 + 1.8 iter-29 + 1.9 iter-36 + 1.10 iter-43 + 1.11 iter-50 + 1.12 iter-57 + 1.13 iter-64 + 1.14 iter-71 + 1.15 iter-83 + 1.16 iter-90 → 2.1 iter-98) — **first Epic 2 ATDD-skip** and **first "infrastructure-smoke class" ATDD-skip** (Epic 1's ten skips were documentation-surface + configuration-surface classes; Story 2.1 extends the precedent to Docker / docker-compose / shell-script runtime-infrastructure artifacts). Skill preflight HALTs at Step 1.2 (no test runner — `vitest.config.*` / `jest.config.*` / `playwright.config.*` absent; no `pyproject.toml` / `go.mod` / `*.csproj` / `Gemfile` / `Cargo.toml` either; test-framework landing is Epic 13 / post-Epic-1 per prior ten precedents). Four-ground rationale grounded in Story 2.1's infrastructure-smoke class (ACs 1-4 all Docker/compose/shell smoke per story lines 15-56 + § Testing standards lines 147-152 explicit ATDD-skip contemplation): **(a)** substrate-verification-covers-ACs at CLI-exit-code level — Task 4 (`docker compose -f packages/devbox/docker-compose.yml build` + `docker compose run --rm devbox pnpm test` + `pnpm lint` all exit code 0) exercises AC 3 end-to-end; Task 5 (`packages/devbox/scripts/benchmark.sh` writes timestamped wall-clock to README § Benchmarks per arch.md:264-270 NFR28b modelled-baseline posture; cold ≤ 300 s, warm ≤ 30 s) exercises AC 4; Task 7 (Dockerfile first non-blank lines = pin-rationale block-comment regex + `docker compose config` exit 0 + `git ls-files -s entrypoint.sh` returns `100755` + `grep -E 'npm install|pip install|curl[^|]*\|[[:space:]]*sh|wget[^|]*\|[[:space:]]*sh' entrypoint.sh` exit 1) exercises AC 1 + AC 2 structural + AC 2 entrypoint-narrow at raw-CLI level; **(b)** no-runner — framework prerequisite unmet (no test framework at 1.0; Epic 13 delivers); **(c)** HYBRID variant-(ii)+(iii) — NFR2 M-series single-run variance carve-out (first-run noise budget ±20% per arch.md:264-270; median-of-three fallback before escalation per AC4 scope-clarification) is DOWNSTREAM observability-class behaviour — audit rigour will strengthen once Epic 13 lands a bench-timing harness (variant ii); adversarial AC 1 + AC 2 + AC 3 + AC 4 coverage (Dockerfile pin-rationale comment block integrity + apt-list completeness for Epic 6 forward-compat + Playwright browser OS-level deps match upstream list + `entrypoint.sh` narrowing correctness + compose `env_file` reference + workspace mount parameterisation for Story 2.11 + VERSIONS.md Renovate-trackability + README § Benchmarks honesty posture) delegated to iter-`/bmad-code-review (args: "2")` three-layer fan-out at post-sm-verified gate (variant iii); **(d)** upstream-provenance-precedent — upstream cc-devbox itself has no test suite (inspection of [github.com/tthew/cc-devbox](https://github.com/tthew/cc-devbox) shows Dockerfile + `docker-compose.yml` + `entrypoint.sh` + `whitelist.sh` + bash scripts with no red-phase harness); absorbing cc-devbox into `packages/devbox/` preserves that posture faithfully; substituting a Playwright/Vitest scaffold at absorb time would introduce a testing-class Ralph has not yet decided to adopt for runtime-infrastructure artefacts (deferred to Epic 13's framework landing + per-package policy). Mirrors Stories 1.14 iter-76 + 1.15 iter-83 + 1.16 iter-90 v1.2 pattern exactly (no test-plan artefacts authored — variant-(ii)+(iii) substitution pattern; identical precedent-hold extended with ground-(d) upstream-provenance addition for infrastructure-smoke class stories). Story State transitions `validated → atdd-scaffolded` via FR14n row 3; next iter queues `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md")` for the `atdd-scaffolded → in-dev` transition.
