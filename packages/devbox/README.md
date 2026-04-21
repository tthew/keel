# `@keel/devbox`

Sandboxed execution environment — absorbed from upstream
[`github.com/tthew/cc-devbox`](https://github.com/tthew/cc-devbox) per the PRD
M0.5 five-deliverable sub-scope. Story 2.1 lands the image + compose +
entrypoint foundation; later Epic 2 stories extend it with egress policy,
hardening, OAuth, lifecycle CLI, and healthchecks.

> **Hybrid package.** This directory holds both the host-side TypeScript
> workspace package (`package.json`, `src/`, `tsconfig.json`,
> `eslint.config.js` — scaffolded by Story 1.1) **and** the runtime-image
> content (`Dockerfile`, `docker-compose.yml`, `entrypoint.sh`, `scripts/`).
> Coexistence is by design; the TS surface is excluded from Docker build
> context via the substrate conventions and the runtime files are excluded
> from the TypeScript project references.

## M0.5 deliverables status

| #   | Deliverable                                        | Landed in       | Status   |
| --- | -------------------------------------------------- | --------------- | -------- |
| a   | Devbox image (Ubuntu 24.04 LTS, baked toolchain)   | Story 2.1       | landing  |
| b   | Compose file + workspace mount                     | Story 2.1       | landing  |
| c   | Entrypoint narrowed, zero runtime network installs | Story 2.1       | landing  |
| d   | Egress policy fix (dnsmasq + nftables + whitelist) | Story 2.3 / 2.4 | deferred |
| e   | `pnpm devbox:*` lifecycle bridge                   | Story 2.6       | deferred |

## Ubuntu 24.04 LTS pin rationale

- LTS support runs through **April 2029**.
- Matches Node 20 LTS maintenance horizon + root `package.json` engines.
- Aligns with `architecture.md § Technical Stack`.
- Supersedes upstream cc-devbox's 22.04 pin so M0.5 ships on current LTS.

A later LTS bump (e.g. 26.04) re-evaluates the whole substrate toolchain in
one coordinated step rather than drifting per-tool.

## Baked toolchain

See `VERSIONS.md` for the authoritative table and the Renovate-tracked
datasource mapping. Summary:

- **System** — curl, git, ca-certificates, build-essential, unzip, jq,
  postgresql-client (Epic 6 forward-compat), Playwright browser OS deps.
- **Language runtimes** — Node 20 LTS (NodeSource), Python via `uv`.
- **Package managers** — pnpm 10.29.2 (global).
- **Claude + GitHub tooling** — `@anthropic-ai/claude-code`, `gh`.
- **Cloud / data** — AWS CLI v2, Supabase CLI, git-delta.

Every tool above is installed **at image-build time** (Dockerfile layers).
`entrypoint.sh` does not run any network installs; a grep-based structural
check (Task 7) enforces this invariant.

## Usage (Story 2.1 scope)

Story 2.1 predates the `pnpm devbox:*` lifecycle CLI (Story 2.6). Verify the
M0.5 foundation using raw `docker compose` commands from the repo root:

```sh
# Build the image.
docker compose -f packages/devbox/docker-compose.yml build

# Run substrate tests inside the container.
docker compose -f packages/devbox/docker-compose.yml run --rm devbox pnpm test
docker compose -f packages/devbox/docker-compose.yml run --rm devbox pnpm lint

# Start a long-running container.
docker compose -f packages/devbox/docker-compose.yml up -d
docker compose -f packages/devbox/docker-compose.yml exec devbox bash

# Stop + remove.
docker compose -f packages/devbox/docker-compose.yml down
```

Story 2.6 replaces each of the above with a `pnpm devbox:*` alias backed by
a script under `packages/devbox/scripts/` without changing the image or the
compose file.

## What this story does NOT deliver

Story 2.1 is bounded to AC 1 – AC 4 literally. The rest of Epic 2 delivers:

| Story     | Scope                                                                              |
| --------- | ---------------------------------------------------------------------------------- |
| ~~2.2~~   | ~~`.envrc` + `.envrc.example` + compose knob parameterisation.~~ (landed iter-148) |
| 2.3       | dnsmasq + nftables egress policy (fail-closed).                                    |
| 2.4       | Whitelist tooling consolidation (`whitelist.sh` unified CLI).                      |
| 2.5       | Non-root `dev` user + `cap_drop: [ALL]` + `no-new-privileges` + tmpfs.             |
| 2.6       | `pnpm devbox:*` lifecycle CLI (13-verb surface).                                   |
| 2.7       | Ralph auto-start inside the devbox on pnpm scripts.                                |
| 2.8       | Claude OAuth named-volume hydration.                                               |
| 2.9       | GitHub CLI OAuth named-volume hydration.                                           |
| 2.10      | Prereq check (`pnpm devbox:env:check` key-name-only validator).                    |
| 2.11      | Per-fork vs shared workspace mode (`KEEL_DEVBOX_SHARED=true`).                     |
| 2.12      | Compose port publication for in-container services.                                |
| 2.13      | Healthcheck (dnsmasq + sshd liveness).                                             |
| 2.14      | `legacy-devbox` branch retention policy (post-M4 EOL).                             |
| 2.15–2.17 | Claude hook posture (in-devbox secret-access barrier, NFR5a).                      |

## NFR2 cold-/warm-start budget

- **Cold start** (image + volume prune → `docker compose up --build -d`):
  ≤ **300 s** (5 min) on the Apple-Silicon M4-Pro baseline.
- **Warm start** (`docker compose down && up -d` against a pre-built image):
  ≤ **30 s**.

Measurement method and escalation rules are captured in
`scripts/benchmark.sh`. Single-run values are modelled baselines per
`architecture.md § NFR28b` (lines 264-270) — not a reproducible envelope.

### Benchmarks

This section is append-only. Every `scripts/benchmark.sh` run writes a new
entry below. Forks running on non-M4-Pro hardware are expected to retune
`.envrc` knobs (Story 2.2) rather than blocking on the baseline budget; see
`architecture.md § I5` (lines 275-293).

#### Pending first bake

Story 2.1 iter-123 produced the first `keel-devbox:local` image inside the
Ralph iteration environment (backend B per
`docs/invariants/devbox-dind.md`; safe-subset: `docker compose build` is
additive-only, no host-state mutation). See `VERSIONS.md § Bake log` for the
full toolchain matrix + image stats.

iter-124 confirmed Task 7.3 (`docker compose config` — exit 0, resolved YAML
valid). Dynamic runtime steps (`docker compose run --rm devbox pnpm test` +
`pnpm lint` for Task 4; `scripts/benchmark.sh --skip-cold` for Task 5
warm-only) are BLOCKED under backend B when invoked from the Ralph
iteration container: the compose file's workspace bind-mount source
resolves to the iteration-container-internal path
(`/workspace/.../worktrees/<name>`), which is not shared with the host
Docker Desktop daemon — the daemon refuses container creation with
`mounts denied: <path> is not shared from the host and is not known to
Docker`. This is an **iteration-context limitation of backend B**, not a
defect of the compose file or `benchmark.sh`; the host daemon can only
bind-mount paths it has been configured to share (e.g. macOS Docker
Desktop → Preferences → Resources → File Sharing, which by default
includes `/Users`, `/tmp`, `/private`, and `/Volumes` but NOT the
iteration container's internal root).

Consequently, **every bind-mount-based compose runtime** (`compose run`,
`compose up -d`, substrate `pnpm test/lint` against the mounted workspace,
warm-start benchmark) joins the existing operator-owned carve-out
alongside the destructive cold-prune pass. The first authoritative
benchmark entry (cold + warm) still lands from an operator workstation —
either M4-Pro native (AC 4 authoritative path, backend A equivalent via
its own Docker Desktop because the worktree lives on the host-shared
`/Users/...` tree) or a backend-A isolated DinD harness where the
iteration container owns its own daemon. Ralph iteration-context bakes
remain valid for the static/build subset only (image build + version
matrix capture + compose config validation).

## Retuning

Numeric devbox knobs — CPU / memory / shm / nofile caps, tmpfs sizes, port
numbers, SSH/shared toggles, target arch — are retunable per fork without a
PRD amendment per NFR8a. `packages/devbox/.envrc.example` is the committed
schema; fork operators copy it to the repo-root `.envrc` and edit the value.
See also the file header of `packages/devbox/.envrc.example` for I5 context
— [`architecture.md` § I5 §Devbox-Reference-Config](../../_bmad-output/planning-artifacts/architecture.md)
(lines 275-295) and [PRD NFR8a retunability](../../_bmad-output/planning-artifacts/prd.md)
(lines 1079-1080).

Retune flow (from repo root):

```sh
# 1. Seed root .envrc from the committed schema.
cp packages/devbox/.envrc.example .envrc

# 2. Activate (direnv-using hosts) or manual source.
direnv allow                 # if using direnv
# OR
source .envrc                # manual shell export

# 3. Edit .envrc to override the default(s) you want to retune.
#    Example: KEEL_DEVBOX_MEMORY_GB=16 on an M4-Max with 48 GB unified memory.

# 4. Restart the devbox so compose re-reads the new values.
pnpm devbox:restart          # Story 2.6 lifecycle CLI; until it lands use:
docker compose -f packages/devbox/docker-compose.yml down
docker compose -f packages/devbox/docker-compose.yml up -d
```

`docker-compose.yml` pulls every tunable via `${KEEL_DEVBOX_*}` with a
default-fallback (non-swarm form: service-level `cpus:` / `mem_limit:` /
`shm_size:` / `ulimits:` / `platform:` / `ports:`), so edits to `.envrc`
take effect on the next `down && up -d` without touching the compose file.

### Secrets

`packages/devbox/.secrets.example` is the committed schema for the
`act` local GitHub-Actions runner (architecture.md:328-330). Forks copy
it to `packages/devbox/.secrets` (gitignored per Story 2.2 AC 5) and fill
in per-fork dev values before invoking `act`. The production secret
source is GitHub repo → Settings → Secrets and variables → Actions;
`.secrets` mirrors that set locally. Pre-merge-fast CI runs with ZERO
external secrets — the `.secrets` file is consumed only in the
pre-merge-slow / nightly / release-gated tiers (Epic 13).

## cc-devbox upstream provenance

- Upstream source:
  [github.com/tthew/cc-devbox](https://github.com/tthew/cc-devbox).
- Known upstream defects resolved by Story 2.1 (or its Epic 2 siblings):
  - Runtime `npm install -g` + `curl | sh` in `entrypoint.sh` → moved to
    image-bake (Story 2.1 AC 2 + Task 3).
  - Hardcoded `/Users/tthew/Development` parent-dir mount → replaced by
    `.envrc`-driven per-fork vs shared mount (Story 2.1 AC 3; Story 2.11
    flips the shared mode).
  - Divergent whitelist tooling + fail-open resolv.conf + IPv6 gap →
    Stories 2.3 + 2.4.
  - Broken `curl :3000` healthcheck → Story 2.13 (dnsmasq + sshd liveness).
  - `./dev-home:/home/dev:delegated` bind-mount for auth tokens → replaced
    by named Docker volumes (NFR10; Stories 2.5 + 2.8 + 2.9).
- `legacy-devbox` branch retention — standalone cc-devbox stays functional
  until after the M4 checkpoint (Story 2.14).
