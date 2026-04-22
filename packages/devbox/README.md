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

| #   | Deliverable                                        | Landed in       | Status                                                                            |
| --- | -------------------------------------------------- | --------------- | --------------------------------------------------------------------------------- |
| a   | Devbox image (Ubuntu 24.04 LTS, baked toolchain)   | Story 2.1       | landing                                                                           |
| b   | Compose file + workspace mount                     | Story 2.1       | landing                                                                           |
| c   | Entrypoint narrowed, zero runtime network installs | Story 2.1       | landing                                                                           |
| d   | Egress policy fix (dnsmasq + nftables + whitelist) | Story 2.3 / 2.4 | ~~deferred~~ _(Story 2.3 landed iter-158; Story 2.4 whitelist CLI still pending)_ |
| e   | `pnpm devbox:*` lifecycle bridge                   | Story 2.6       | deferred                                                                          |

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

## Egress policy (Story 2.3)

### Overview

The devbox enforces a fail-closed egress posture via two cooperating in-container layers (belt-and-braces per `architecture.md § S5` and `docs/invariants/devbox-egress.md`):

- **dnsmasq** — DNS authority bound to `127.0.0.1:53`; default `address=/#/` returns `0.0.0.0`/`::` for every domain; explicit `server=/<domain>/${KEEL_DEVBOX_DNS_UPSTREAM}` entries forward whitelisted domains to the operator-chosen upstream (default `1.1.1.1`).
- **nftables** — `inet keel_egress` table with `output_v4` + `output_v6` chains both `policy drop`. Layer-3 default-deny in both families closes upstream cc-devbox's IPv6 bypass.

If dnsmasq fails to start, `entrypoint.sh` fails the container — there is no silent-allow path (NFR6).

### Files

| Path                                                   | Role                                                                |
| ------------------------------------------------------ | ------------------------------------------------------------------- |
| `packages/devbox/whitelist.default.txt`                | Substrate-baseline domain list (empty at 1.0; comment header only). |
| `packages/devbox/whitelist/{npm,anthropic,github}.txt` | Category fragments covering the required substrate egress surface.  |
| `packages/devbox/nftables/egress.nft`                  | nftables ruleset template; marker block replaced at reload time.    |
| `packages/devbox/dnsmasq/dnsmasq.conf`                 | dnsmasq config template; marker block replaced at reload time.      |
| `packages/devbox/scripts/start-egress.sh`              | Entrypoint helper — one-shot bootstrap + first reload + tailer.     |
| `packages/devbox/scripts/reload-egress.sh`             | Atomic reload primitive (flock + `nft -f` + `kill -HUP`).           |
| `packages/devbox/scripts/egress-log-tailer.sh`         | Background JSONL emitter + 50 MB rotation (5 gzip generations).     |
| `packages/devbox/scripts/monitor.sh`                   | Operator-facing live `tail -F` via `jq -c`.                         |

### Verification

The following checks run on an operator workstation (backend-A native or M4-Pro) against a baked + started container. Backend-B iteration environments cannot exercise `nft` / full DNS round-trip — the `docker exec …` invocations below are the canonical smokes.

```sh
# IPv4/IPv6 parity (AC 2, SC-7 verbatim)
docker exec keel-devbox nft list chain inet keel_egress output_v4 | grep -q 'policy drop'
docker exec keel-devbox nft list chain inet keel_egress output_v6 | grep -q 'policy drop'

# resolv.conf pinned (AC 1)
docker exec keel-devbox cat /etc/resolv.conf
# Expect nameserver 127.0.0.1 + options edns0 single-request-reopen.

# Fail-closed unwhitelisted smoke (AC 5)
docker exec keel-devbox curl -m 3 -sSf https://example-unwhitelisted.invalid
# Expect non-zero exit; stderr "Could not resolve host" / timeout.

# JSONL schema round-trip (AC 3)
docker exec keel-devbox tail -n 1 /workspace/logs/egress-queries.jsonl | jq -e '
  has("timestamp") and has("query") and has("type") and
  has("result") and has("upstream") and has("client")'
```

### Reload

```sh
# Atomic reload against the composed whitelist (Story 2.4 later wraps this as `pnpm devbox:whitelist sync`):
docker exec keel-devbox /workspace/packages/devbox/scripts/reload-egress.sh /run/keel-whitelist.composed.txt

# Live-tail the JSONL query log:
docker exec -it keel-devbox /workspace/packages/devbox/scripts/monitor.sh
```

`reload-egress.sh` serialises concurrent reloads via `flock -x /run/keel-egress.lock` (10 s timeout → exit 4); applies the nftables ruleset via a single `nft -f <tempfile>` kernel transaction (failure → exit 5, previous ruleset stays active); reloads dnsmasq via `kill -HUP <pid>` (fallback `pkill -HUP dnsmasq`; failure → exit 7 — fallible seam per SC-5 residual risk).

### Per-fork whitelist override (Story 2.4)

Story 2.4 ships `packages/devbox/scripts/whitelist.sh` — the user-facing CLI on top of Story 2.3's `reload-egress.sh` primitive. Four subcommands per `architecture.md § Devbox Package Tree` (l.1002):

| Subcommand        | Effect                                                                | Exit codes                                                                  |
| ----------------- | --------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `sync`            | Recompose + LDH-regex validate + atomic-reload (no mutation)          | 0 ok; 2 validate; 3 unreadable; 5–7 reload                                  |
| `add <domain>`    | Append `<domain>` to `whitelist.local.txt` (atomic, locked) + `sync`  | 0 ok; 2 syntax; 3 unreadable; 4 lock-timeout; 5–7 reload                    |
| `remove <domain>` | Strip `<domain>` from `whitelist.local.txt` (atomic, locked) + `sync` | 0 ok; 2 substrate-domain / syntax; 3 unreadable; 4 lock-timeout; 5–7 reload |
| `list`            | Print composed state with source prefix (`D` / `F:<name>` / `L`)      | 0 ok                                                                        |

The per-fork override file `packages/devbox/whitelist.local.txt` is gitignored (no committed `.example` template — substrate baseline already lives in `whitelist.default.txt` + `whitelist/*.txt`). Composition is additive-only; the override CANNOT shrink the substrate baseline (`remove <substrate-domain>` errors with operator education and routes the operator to the source-level PR / FR44 AMEND path).

In-container invocation paths (Story 2.6 later wraps these behind a host-side `pnpm devbox:whitelist` alias; until then operators invoke via `docker exec`):

```sh
# Add a per-fork domain (auto-syncs)
docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh add internal-registry.myfork.com

# Inspect composed state with source attribution
docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh list

# Remove a per-fork domain (auto-syncs)
docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh remove internal-registry.myfork.com

# Recompose + reload without changes (e.g., after hand-editing whitelist.local.txt)
docker exec keel-devbox /workspace/packages/devbox/scripts/whitelist.sh sync
```

Domain-syntax validation uses a strict LDH (letter-digit-hyphen) regex with a 253-char total-length bound (RFC 1035). Underscores, leading/trailing hyphens, empty labels, slashes, embedded whitespace, and zero-width Unicode are rejected. IDN entries MUST be pre-punycode-encoded by the operator (1.0 scope; refinement deferred). Validation failure exits 2 WITHOUT invoking `reload-egress.sh` — previous policy stays active (AC 3 fail-closed).

### Known upstream bugs fixed

1. **Divergent whitelist tooling** — upstream shipped two independent reload paths (`manage-whitelist.sh` + `whitelist`) with different state; Story 2.3 collapses onto a single `reload-egress.sh` primitive.
2. **Fail-open `/etc/resolv.conf` fallback to `8.8.8.8`** — upstream leaked queries to public DNS when dnsmasq was slow; Story 2.3 pins `resolv.conf` to `nameserver 127.0.0.1` only.
3. **IPv6 default-deny gap** — upstream only blocked IPv4; Story 2.3 adds `address=/#/::` + `chain output_v6 { policy drop }` for full parity.

## Hardening (Story 2.5)

The devbox container is hardened against post-exploitation runtime compromise per NFR7 + NFR8 + NFR8a + NFR10. Machine-enforced by `INV-devbox-homedev-named-volume` (`docs/invariants/devbox-hardening.md`); runtime compose-shape check deferred to Story 2.17. Layered barriers:

- **Non-root `dev` user** (UID/GID 1000) — `Dockerfile` creates the user with `groupadd --gid 1000 dev && useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home dev`; `USER dev` directive switches before `ENTRYPOINT`. UID 1000 aligns with common host UIDs for bind-mount passthrough on macOS + Linux.
- **Capability bounding set** — `docker-compose.yml` sets `cap_drop: [ALL]` + `cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE]`. Three narrow caps; see § Capability rationale below.
- **`no-new-privileges:true`** — `security_opt: [no-new-privileges:true]` sets `PR_SET_NO_NEW_PRIVS=1` on PID 1; kernel masks file-cap `F(effective)` bits on exec + disables setuid privilege elevation.
- **tmpfs `/tmp` + `/var/tmp` with `noexec,nosuid`** — long-syntax `tmpfs:` block consumes `KEEL_DEVBOX_TMPFS_TMP_MB` + `KEEL_DEVBOX_TMPFS_VARTMP_MB` knobs published by Story 2.2. `/var/log` intentionally NOT tmpfs-mounted (dnsmasq + nftables log files live under `/workspace/logs/` per Story 2.3).
- **Named Docker volume `keel_home_dev` for `/home/dev`** — substrate-authoritative, non-toggle-able. No `KEEL_DEVBOX_*` setting can flip this to a host bind-mount. Claude Code tokens (Story 2.8), `gh` tokens (Story 2.9), shell history live only inside this volume. Upstream cc-devbox's `./dev-home:/home/dev:delegated` bind-mount pattern is intentionally NOT retained (NFR10).

### Capability rationale

`cap_drop: [ALL]` strips every kernel capability including those inherited from the executable's bounding set. Three caps are added explicitly:

| Cap                | Why it's required                                                                                                                                                                                                                      |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `NET_ADMIN`        | nftables rule load via netlink (Story 2.3 egress policy; `reload-egress.sh` invokes `nft -f <tempfile>`).                                                                                                                              |
| `NET_RAW`          | raw-socket probes dnsmasq may issue for connectivity health.                                                                                                                                                                           |
| `NET_BIND_SERVICE` | dnsmasq port 53 bind under `cap_drop: [ALL]`. The bounding set without this cap rejects `:<1024` bind from any process, root-equivalent or not. Adding it explicitly is the minimum viable posture under Story 2.5's cap-drop default. |

Capabilities NOT added: `CAP_SYS_ADMIN` (no container-administration ops in substrate), `CAP_CHOWN` (entrypoint's runtime chown calls fail under dropped CAP_CHOWN — this is expected + tolerated via stderr-capture-and-continue; image-build-time chown seeds `/home/dev` ownership correctly for first-boot volume auto-init), `CAP_SYS_PTRACE` (no debugger substrate), and every other Linux cap. Under `PR_SET_NO_NEW_PRIVS=1` the capability propagation path is Docker ≥19.03's ambient-cap automation via `prctl(PR_CAP_AMBIENT_RAISE)`; `setcap +eip` on `/usr/sbin/dnsmasq` + `/usr/sbin/nft` in the `Dockerfile` remains as a portability fallback for older Docker or Podman-compat forks.

### Verification

> **Note on compose-project-name overrides:** the verification commands below assume the pinned `name: keel-devbox` in `docker-compose.yml`. Operators who set `COMPOSE_PROJECT_NAME=<name>` or pass `-p <name>` to `docker compose` must substitute that project name in the volume FQN: `<name>_keel_home_dev` instead of `keel-devbox_keel_home_dev`. The substrate-authoritative named-volume contract (NFR10) is preserved regardless of project-name override — only the FQN prefix changes.

Operator-workstation run (M4-Pro native Docker Desktop); DinD backend B is not authoritative for these smokes per the Backend compatibility section below.

```sh
# AC 1 — non-root dev user
docker exec keel-devbox id
# Expect: uid=1000(dev) gid=1000(dev) groups=1000(dev)

# AC 2 — bounding set + no-new-privileges
docker exec keel-devbox sh -c 'capsh --print'
# Expect: Bounding set =cap_net_bind_service,cap_net_raw,cap_net_admin
docker inspect keel-devbox --format '{{ .HostConfig.SecurityOpt }}'
# Expect: [no-new-privileges]

# AC 3 — tmpfs noexec,nosuid
docker exec keel-devbox mount | grep /tmp
# Expect two lines with 'nosuid,nodev,noexec' for /tmp + /var/tmp

# AC 4 — named volume for /home/dev
docker inspect keel-devbox --format '{{ range .Mounts }}{{ .Type }} {{ .Source }} {{ .Destination }}\n{{ end }}'
# Expect a 'volume <project>_keel_home_dev /home/dev' line; no bind-mount for /home/dev
docker volume inspect keel-devbox_keel_home_dev
# Expect Driver: local, Scope: local

# AC 5 Smoke A — /tmp noexec
docker exec keel-devbox sh -c 'printf "#!/bin/sh\necho hello\n" > /tmp/t.sh && chmod +x /tmp/t.sh && /tmp/t.sh; echo exit=$?'
# Expect nonzero exit: "Permission denied".
# MNT_NOEXEC produces EACCES only; ENOEXEC ("exec format error") is a
# distinct kernel error class for malformed shebang or bad ELF magic,
# unrelated to the noexec mount flag — do not expect it from this smoke.
# Uses `printf` (not POSIX `echo`) so the shebang+body actually land on two lines.

# AC 5 Smoke B — no-new-privileges visible in kernel flags
docker exec keel-devbox sh -c 'grep ^NoNewPrivs /proc/self/status'
# Expect: "NoNewPrivs:\t1" — direct kernel-flag read, version-independent.
# Proves PR_SET_NO_NEW_PRIVS=1 is applied to the container's init process
# (and inherited by every `docker exec` descendant). Prior `sudo --help`
# form exited 0 without attempting elevation — false-positive under any
# posture; /proc/self/status exercises the AC 5 NNP contract directly.

# Capability-exercise smoke (nftables + dnsmasq functional under cap_drop)
docker exec keel-devbox nft list table inet keel_egress
# Expect: nftables ruleset loaded — confirms NET_ADMIN ambient-cap propagation
docker exec keel-devbox sh -c 'ss -tlnp | grep :53'
# Expect: dnsmasq on 127.0.0.1:53 — confirms NET_BIND_SERVICE ambient cap
```

### Known limitations

- **Runtime chown failures are expected** under `cap_drop: [ALL]` (CAP_CHOWN is dropped). `entrypoint.sh`'s `chown` calls on `/workspace`, `/home/dev/.claude`, `/home/dev/.config/gh` emit stderr diagnostics but do NOT abort — image-build-time chown already seeded `/home/dev` correctly for named-volume auto-init, and `/workspace` ownership is driven by the host bind-mount's UID passthrough. Non-matching host UIDs (host user ≠ UID 1000) produce a "read-only-ish" workspace under dev; operators align their host UID with container UID 1000 for a seamless experience.
- **Live-smoke matrix is operator-workstation-authoritative** under DinD backend B (host socket-passthrough). The DinD-B iteration environment cannot safely exercise `docker exec` sequences against cap-dropped containers — doing so risks poisoning the host's docker state. M4-Pro native Docker Desktop is the authoritative AC 5 + AC 2 bounding-set verification environment.
- **Story 2.4 whitelist.sh compatibility** under USER dev + tmpfs `/run/` auto-mount: state files under `/run/` are dev-writable when Docker's tmpfs auto-mount preserves the image-layer ownership established by the Dockerfile. Empirical verification deferred to operator-workstation smoke (Task 11.8); happy path (SC-14 branch (i)) requires no code change. If the empirical outcome requires relocation, state files move to `/tmp/keel-state/` (still tmpfs but `noexec,nosuid` is fine — state files are not executable).

### Backend compatibility

Both DinD backends (A = true Docker-in-Docker, B = host socket-passthrough per `INV-devbox-dind-available`) preserve the hardening posture — the Docker daemon applies `cap_drop` + `cap_add` + `security_opt` + `tmpfs` + `volumes` at container-start regardless of which fronts the daemon. Under backend B only warm-only NFR2 measurement is autonomously safe; the same constraint applies to hardening live smokes. See `docs/invariants/devbox-hardening.md` § Backend compatibility.

### Operator migration (pre-Story-2.5 named-volume recovery)

Operators who ran an earlier `keel-devbox` build (before Story 2.5 landed the `USER dev` + `keel_home_dev` named-volume hardening) may have populated the volume under `root:root` ownership. Under the Story 2.5 `USER dev` posture, writes into `/home/dev/.claude` (Story 2.8) or `/home/dev/.config/gh` (Story 2.9) will silently fail EACCES against a root-owned volume, leaving auth-token persistence broken with no stderr signal.

**Symptom detection:**

```sh
# Inspect volume options (first-boot auto-init metadata).
docker volume inspect keel-devbox_keel_home_dev 2>/dev/null | jq -r '.[0].Options // "(none)"'

# Inspect the volume's root ownership. The expected value after Story 2.5 is 1000:1000 (dev).
docker run --rm -v keel-devbox_keel_home_dev:/mnt alpine stat -c '%u:%g' /mnt
# Expect: 1000:1000 — if the output is 0:0, the volume was populated pre-Story-2.5 and needs recovery.
```

**Recovery (destructive — re-auth required):**

```sh
pnpm devbox:stop                                 # halt the container first
docker volume rm keel-devbox_keel_home_dev       # destroy the root-owned volume
pnpm devbox:start                                # fresh volume auto-populates under dev:dev
# Operator re-runs:
#   pnpm claude            # Story 2.8 re-login
#   pnpm gh:auth           # Story 2.9 re-login
```

On the next `pnpm devbox:start`, Docker auto-populates the fresh empty volume from the image-layer ownership established by `Dockerfile`'s `chown -R dev:dev /home/dev` step — under the Story 2.5 `USER dev` posture, the volume lands at `dev:dev` (1000:1000).

**Safety rail:** do NOT run `docker volume rm` without `pnpm devbox:stop` first — removing a mounted volume under the running container leaves the daemon state inconsistent.

**Substrate rule:** `INV-devbox-homedev-named-volume` (`INVARIANTS.md`, `docs/invariants/devbox-hardening.md`) is authoritative. No `KEEL_DEVBOX_*` knob can flip `/home/dev` back to a host bind-mount; this migration is the once-per-fork recovery path for pre-Story-2.5 volumes.

## Host-side CLI (Story 2.6)

Every devbox interaction is a `pnpm devbox:*` subcommand. Operators never type `docker`, `docker compose`, or `docker exec` directly (FR1, `architecture.md:74`). The host-side shim scripts under `packages/devbox/scripts/` translate each `pnpm devbox:<verb>` into the right `docker compose` / `docker exec` invocation; a few verbs (`monitor`, `whitelist`) are thin shims over in-container primitives from Stories 2.3 + 2.4.

### Subcommand surface

| Subcommand              | Purpose                                                                                                        | Exit codes (beyond success)      |
| ----------------------- | -------------------------------------------------------------------------------------------------------------- | -------------------------------- |
| `pnpm devbox:build`     | `docker compose build devbox` (cached).                                                                        | `8`                              |
| `pnpm devbox:rebuild`   | `docker compose build --no-cache devbox` (fresh).                                                              | `8`                              |
| `pnpm devbox:start`     | `docker compose up -d` + healthcheck poll (timeout `KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S`, default 120s).   | `2`, `3`, `8`, `10`, `11`        |
| `pnpm devbox:stop`      | `docker compose stop devbox` (container preserved; volume preserved).                                          | `8`                              |
| `pnpm devbox:restart`   | `stop.sh` then `start.sh` in sequence.                                                                         | inherited                        |
| `pnpm devbox:clean`     | `docker compose down --rmi local --remove-orphans`; `--with-volumes` gates on y/N + `--force-backend-b`.       | `2`, `8`                         |
| `pnpm devbox:shell`     | `docker exec -it --user dev -w /workspace` bash login shell (extra args → `bash -l "$@"`).                     | `8`, `9`                         |
| `pnpm devbox:attach`    | `docker attach --detach-keys='ctrl-p,ctrl-q'` — observe PID 1 stdio (Ralph TUI in Story 2.7).                  | `8`, `9`                         |
| `pnpm devbox:status`    | `docker compose ps` + `docker inspect` healthcheck status.                                                     | `8`, `9`                         |
| `pnpm devbox:logs`      | `docker compose logs -f --tail=100 devbox` (flags forwarded: `--no-follow`, `--tail=<N>`, `--since <ts>`).     | `8`                              |
| `pnpm devbox:monitor`   | `docker exec` into Story 2.3's in-container `monitor.sh` — **FR1a JSONL DNS-event tail** (not `docker stats`). | `3`, `8`, `9`                    |
| `pnpm devbox:whitelist` | `docker exec` into Story 2.4's `whitelist.sh` (subcommands: `add` / `remove` / `list` / `sync`).               | `2`, `3`, `4`, `5`–`7`, `8`, `9` |
| `pnpm devbox:env:check` | Validate `.envrc` presence + every required `KEEL_DEVBOX_*` var + tmpfs-int shape.                             | `2`, `3`                         |

### Exit-code family (uniform across devbox CLI)

| Code    | Meaning                                                                                                            |
| ------- | ------------------------------------------------------------------------------------------------------------------ |
| `0`     | Success.                                                                                                           |
| `2`     | Usage error / validation failure (missing arg, unknown flag, `env:check` missing required var or shape violation). |
| `3`     | Source file unreadable (`.envrc` absent for `env-check`, in-container `monitor.sh` missing).                       |
| `4`     | Mutation lock unavailable within timeout (Story 2.4 `whitelist.sh` passthrough).                                   |
| `5`–`7` | Propagated verbatim from in-container primitives (`whitelist.sh` / `reload-egress.sh`).                            |
| `8`     | Docker runtime unreachable — `docker info` failed. Stderr hint: `is the daemon running?`.                          |
| `9`     | Container not running — `pnpm devbox:start` not yet called.                                                        |
| `10`    | Image not built — `pnpm devbox:build` not yet called.                                                              |
| `11`    | `start` healthcheck timeout. Container is left running for operator debugging via `pnpm devbox:logs`.              |
| `124`   | Reserved for `timeout(1)`-wrapped invocations (operator-facing). Not used internally.                              |

### `.envrc` integration

`pnpm devbox:env:check` is the pre-flight for every devbox invocation. It parses `.envrc` at the repo root (gitignored; seed from `packages/devbox/.envrc.example` + `direnv allow`) and verifies:

- Every required `KEEL_DEVBOX_*` variable is present (15 keys at 1.0 matching `.envrc.example`'s active block).
- Tmpfs size knobs (`KEEL_DEVBOX_TMPFS_TMP_MB`, `KEEL_DEVBOX_TMPFS_VARTMP_MB`, `KEEL_DEVBOX_TMPFS_LOGS_MB`) are strictly positive integers (no units, no zero — AR-11 shape-validation absorption).

Missing vars and shape violations are reported to stderr by name; values are echoed only for the tmpfs-int shape class (not a credential class). `pnpm devbox:start` calls `env-check` as its own pre-flight unless `KEEL_DEVBOX_START_SKIP_ENV_CHECK=true` is set (CI escape hatch for alternate env injection).

### Backend-B awareness (`pnpm devbox:clean --with-volumes`)

`pnpm devbox:clean` (no flag) removes only the container + local image; the `keel_home_dev` named volume (NFR10) is preserved. To destroy the volume, pass `--with-volumes` — the script prompts `[y/N]` (or consumes `--yes`). Under backend B (host socket-passthrough per `docs/invariants/devbox-dind.md § Backend contract`), an additional `--force-backend-b` acknowledgement is required because destroying `keel_home_dev` under a shared host daemon can surprise unrelated projects that share the compose prefix. See `packages/devbox/scripts/benchmark.sh § detect_backend` for the reference backend probe.

### Verification (operator-workstation)

Run on M4-Pro native Docker Desktop; DinD backend B in cc-devbox iteration environments cannot safely exercise the full lifecycle per Story 2.4 / Story 2.5 precedent.

```sh
pnpm devbox:env:check          # expect exit 0
pnpm devbox:build              # expect image 'keel-devbox:local' built
pnpm devbox:start              # expect 'start: started (container keel-devbox, state=…)' + exit 0
pnpm devbox:status             # expect 'state: running' + healthcheck line
pnpm devbox:shell -c 'whoami && pwd && id'
# Expect: dev / /workspace / uid=1000(dev) gid=1000(dev) …
pnpm devbox:logs --no-follow --tail=50
pnpm devbox:whitelist list     # composed state with source prefixes (D/F:*/L)
pnpm devbox:stop               # container stopped; volume preserved
pnpm devbox:start              # idempotent re-start
pnpm devbox:clean              # container + image removed; volume preserved
docker volume inspect keel-devbox_keel_home_dev >/dev/null && echo "volume preserved ✓"
pnpm devbox:clean --with-volumes  # expect y/N prompt; answer N → no-op (safe default)
```

### Iteration-env-safe smokes

These run in backend-B iteration environments (no lifecycle mutation):

```sh
# Syntax validity of every script.
for f in packages/devbox/scripts/{build,rebuild,start,stop,restart,clean,shell,attach,status,logs,monitor-host,whitelist-host,env-check}.sh; do bash -n "$f"; done

# pnpm wiring regression check — expect 13 devbox:* entries.
pnpm run 2>/dev/null | grep -E '^\s+devbox:' | wc -l   # expect 13

# env-check with/without .envrc.
pnpm devbox:env:check                                   # exit 3 if no .envrc; exit 0 with seeded .envrc

# Dispatcher usage paths (no docker state mutation).
./packages/devbox/scripts/clean.sh --unknown   # exit 2 + usage
./packages/devbox/scripts/clean.sh --help      # exit 0 + usage
```

### Cross-references

- `### Per-fork whitelist override (Story 2.4)` above — `pnpm devbox:whitelist <add|remove|list|sync>` subcommand semantics + substrate-additive composition rules.
- `### Operator migration (pre-Story-2.5 named-volume recovery)` above — one-time recovery for volumes populated before Story 2.5's `USER dev` posture.
- `docs/invariants/devbox-dind.md § Backend contract` — backend-A/B detection + destructive-op safety rule.

## Ralph loop (Story 2.7)

`pnpm ralph:build` and `pnpm ralph:plan` are the operator entry points to the Ralph iteration loop (FR2). Each command auto-starts the devbox if not running, then attaches the operator terminal to the container's PID 1 stdio. The in-container Ralph runtime (Epic 3) consumes a mode signal the wrapper sets before attaching.

### Quick start

```sh
pnpm ralph:build    # build mode — container auto-starts if stopped, then attach
pnpm ralph:plan     # plan mode — same lifecycle, different mode signal
# Ctrl+P Ctrl+Q     # detach from the container; the loop keeps running
pnpm devbox:attach  # re-attach to the running loop
```

### Auto-start contract (AC 1, AC 2)

Each wrapper inspects the container's state before attaching:

- **Container not running** → invokes `packages/devbox/scripts/start.sh` (the Story 2.6 primitive; does NOT shell out to `pnpm devbox:start` — see Story 2.7 § SC-9). `start.sh` builds the image if needed, `docker compose up -d`s the devbox, and polls the healthcheck until ready. On its success, the wrapper re-inspects the container and proceeds to attach. On its failure, the exit code propagates verbatim (`10` / `11` / `8`).
- **Container already running** → skips the start step and attaches directly.

### Ctrl+P Ctrl+Q detach + re-attach (AC 3, AC 4)

`docker attach --detach-keys='ctrl-p,ctrl-q'` is pinned explicitly — it matches docker's default but guards against future docker-default changes (Story 2.6 `attach.sh:39` precedent). Pressing Ctrl+P Ctrl+Q detaches the operator terminal without killing the container; the in-container Ralph loop keeps running. Re-attach with `pnpm devbox:attach` or by re-invoking `pnpm ralph:build` — the existing loop is preserved.

### Mode routing (AC 5)

Before attaching, each wrapper exports `KEEL_RALPH_MODE=build|plan`. Epic 3's in-container Ralph runtime reads this at startup to select `.ralph/PROMPT_build.md` or `.ralph/PROMPT_plan.md`. **Mode is set once per container-start** — running the other mode script on an already-running container attaches to the existing process without switching mode. To switch modes, stop and re-start: `pnpm devbox:stop && pnpm ralph:plan`. Prompt-file semantics themselves are Epic 3 scope.

### Exit codes (inherited from Story 2.6)

| Code | Meaning                                                                              |
| ---- | ------------------------------------------------------------------------------------ |
| `0`  | Clean detach.                                                                        |
| `8`  | Docker runtime unreachable — `docker info` failed. Hint: is the daemon running?      |
| `9`  | Container not running (rare — post-auto-start fallback after `start.sh` returned 0). |
| `10` | Image not built — propagated from `start.sh`.                                        |
| `11` | `start` healthcheck timeout — propagated from `start.sh`.                            |
| `*`  | `docker attach` error — propagated.                                                  |

### Cross-references

- `AGENTS.md § Ralph loop` — agent-facing operational contract for the wrappers.
- `### Host-side CLI (Story 2.6)` above — `start.sh` / `attach.sh` primitives that Story 2.7 composes on.
- Story 2.7 file `_bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md` — full spec, scope clarifications SC-1..SC-17, and Epic-3 carve-out.

## Claude Code authentication (Story 2.8)

`pnpm claude` is the operator entry point for Claude Code inside the devbox (FR3). First invocation per fresh devbox triggers the Anthropic OAuth flow; the URL surfaces on your host terminal and you complete the flow in a host browser. Tokens persist at `/home/dev/.claude/` inside the `keel_home_dev` named volume (Story 2.5 substrate), so subsequent invocations skip auth and survive `pnpm devbox:restart`.

### Quick start

```sh
pnpm devbox:start       # bring the container up first (no auto-start per SC-4)
pnpm claude             # first run: follow the URL printed to your terminal in a host browser
pnpm claude --version   # any claude args pass through via "$@"
pnpm claude -p "hello"  # one-shot prompt after the token is seeded
```

### First-run OAuth flow (AC 1, AC 2)

1. `pnpm claude` with no existing token invokes `claude` inside `keel-devbox` under `docker exec -it --user dev -w /workspace`. The OAuth device-code flow prints a URL (and optionally a code) to your terminal.
2. Open the URL in a host browser, complete Anthropic OAuth, and — if prompted — paste the device code back into the page.
3. `claude` writes the token file under `/home/dev/.claude/` inside the `keel_home_dev` named volume. The token is never bind-mounted to the host filesystem.

### Persistence contract (AC 3)

Tokens survive `pnpm devbox:restart`, `pnpm devbox:stop && pnpm devbox:start`, and host reboots — the `keel_home_dev` named volume persists across the container's lifecycle (Story 2.5 § Named volume `keel_home_dev`). Re-running `pnpm claude` on an already-authed devbox is a no-op at the auth layer: claude detects the existing token and proceeds to its default action (interactive session, or whatever `"$@"` args selected).

### Re-auth on expiry (AC 4)

If claude reports "not authenticated" — or Ralph's pre-push gate surfaces an auth failure — re-run `pnpm claude`. The OAuth flow repeats; the new token overwrites the old under `/home/dev/.claude/`. No wrapper-side state tracking is required; Claude Code owns the refresh semantics.

### Volume-delete reset (AC 5)

`pnpm devbox:clean --with-volumes` wipes `/home/dev/.claude/` along with the entire `keel_home_dev` named volume — expected per NFR10 fresh-fork behaviour. After a volume-delete reset, `pnpm claude` must be re-run to re-seed the token.

### Pre-flight expectation

`pnpm claude` fails-closed with exit `9` if the container is not running — it does NOT auto-start the devbox (contrast `pnpm ralph:build`, which DOES auto-start per Story 2.7 SC-1). Auth is a one-off operator gesture; auto-start would mask intent and add a 30–60s first-invocation delay. Run `pnpm devbox:start` first.

### Exit codes (Story 2.6 uniform schema)

| Code | Meaning                                                                         |
| ---- | ------------------------------------------------------------------------------- |
| `0`  | Clean exit — OAuth completed, or claude's own clean exit.                       |
| `8`  | Docker runtime unreachable — `docker info` failed. Hint: is the daemon running? |
| `9`  | Container not running — run `pnpm devbox:start` first (no auto-start per SC-4). |
| `*`  | `claude` or `docker exec` error — propagated unchanged.                         |

### Cross-references

- `AGENTS.md § Claude Code authentication` — agent-facing operational contract (never invoke `docker exec … claude` directly; token persistence contract on `keel_home_dev`).
- `### Host-side CLI (Story 2.6)` above — `shell.sh` / `attach.sh` interactive-exec primitives that `claude-host.sh` mirrors.
- `### Ralph loop (Story 2.7)` above — contrast: `ralph-build-host.sh` / `ralph-plan-host.sh` DO auto-start; `claude-host.sh` does NOT (SC-4).
- Story 2.8 file `_bmad-output/implementation-artifacts/2-8-claude-code-oauth-via-pnpm-claude.md` — full spec, scope clarifications SC-1..SC-17, upstream-CLI carve-out.

## gh CLI authentication (Story 2.9)

`pnpm gh:auth` is the operator entry point for `gh auth login` inside the devbox (FR3, gh side). First invocation per fresh devbox triggers GitHub's OAuth device-code flow; the URL + one-time code surface on your host terminal and you complete the flow in a host browser. Tokens persist at `/home/dev/.config/gh/` inside the `keel_home_dev` named volume (Story 2.5 substrate), so subsequent invocations skip auth and survive `pnpm devbox:restart`. Ralph then uses the token for `gh push` / `gh pr view` / `gh pr checks` inside the container without re-auth.

### Quick start

```sh
pnpm devbox:start                          # bring the container up first (no auto-start per SC-4)
pnpm gh:auth                               # first run: follow the URL + one-time code in a host browser
pnpm gh:auth --web                         # web-only OAuth flow
pnpm gh:auth --hostname github.com         # explicit host (default is github.com)
pnpm gh:auth --scopes "repo,workflow"      # custom OAuth scopes
```

Args passthrough is scoped to `gh auth login` only — the wrapper hardcodes the `auth login` subcommand. For general `gh` composition (`gh pr list`, `gh pr view`, etc.), use `pnpm devbox:shell` and invoke `gh` inside the shell.

### First-run OAuth flow (AC 1, AC 2)

1. `pnpm gh:auth` with no existing credentials invokes `gh auth login` inside `keel-devbox` under `docker exec -it --user dev -w /workspace`. The interactive prompt asks for the host (default `github.com`), protocol (HTTPS/SSH), and authentication method (web vs paste-token).
2. Select the web-OAuth flow. `gh` prints `https://github.com/login/device` + a one-time code to your terminal.
3. Open the URL in a host browser, complete GitHub OAuth, and paste the one-time code on the GitHub confirmation page.
4. `gh` writes the token under `/home/dev/.config/gh/hosts.yml` (default location) inside the `keel_home_dev` named volume. The token is never bind-mounted to the host filesystem.

### Persistence contract (AC 3)

Tokens survive `pnpm devbox:restart`, `pnpm devbox:stop && pnpm devbox:start`, and host reboots — the `keel_home_dev` named volume persists across the container's lifecycle (Story 2.5 § Named volume `keel_home_dev`). Subsequent `gh pr view`, `git push`, and `gh pr checks` invocations reuse the token transparently. Re-running `pnpm gh:auth` on an already-authed devbox re-triggers the OAuth flow (overwrites the existing token).

### Re-auth on expiry (AC 4)

If `gh` reports `authentication required` / HTTP 401 — or Ralph's pre-push gate (Epic 3) surfaces a `gh not authed` failure — re-run `pnpm gh:auth`. The OAuth flow repeats and the new token overwrites the old entry under `/home/dev/.config/gh/`. No wrapper-side state tracking is required; the `gh` CLI owns the refresh semantics.

### Ralph pre-push gate halt-able pointer (AC 4 second clause — Epic 3 scope)

When Ralph's pre-push gate (Story 3.7) detects a gh-auth failure, it writes a halt sentinel `{"reason":"CI_BLOCKED","note":"gh not authed — run 'pnpm gh:auth'"}` per the closed halt-reason enum (PRD FR14k + `docs/invariants/ralph-execute.md` § Halt schema) rather than silently retrying. This prevents iterations from spinning against a non-advancing pushing contract. Story 2.9 pins the pointer-error surface + the invariant of how Ralph MUST respond; the halt-write itself is delivered by Epic 3.

### Volume-delete reset

`pnpm devbox:clean --with-volumes` wipes `/home/dev/.config/gh/` along with the entire `keel_home_dev` named volume — expected per NFR10 fresh-fork behaviour. After a volume-delete reset, `pnpm gh:auth` must be re-run to re-seed the token.

### Pre-flight expectation

`pnpm gh:auth` fails-closed with exit `9` if the container is not running — it does NOT auto-start the devbox (contrast `pnpm ralph:build`, which DOES auto-start per Story 2.7 SC-1; mirrors `pnpm claude` per Story 2.8 SC-4). Auth is a one-off operator gesture; auto-start would mask intent and add a 30–60s first-invocation delay. Run `pnpm devbox:start` first.

### Exit codes (Story 2.6 uniform schema)

| Code | Meaning                                                                                                          |
| ---- | ---------------------------------------------------------------------------------------------------------------- |
| `0`  | Clean exit — OAuth completed, or `gh`'s own clean exit.                                                          |
| `8`  | Docker runtime unreachable — `docker info` failed. Hint: is the daemon running?                                  |
| `9`  | Container not running — run `pnpm devbox:start` first (no auto-start per SC-4).                                  |
| `*`  | `gh` or `docker exec` error — propagated unchanged (including OAuth timeout / cancellation / GitHub rate-limit). |

### Cross-references

- `AGENTS.md § gh CLI authentication` — agent-facing operational contract (never invoke `docker exec … gh auth login` directly; token persistence contract on `keel_home_dev`; Ralph halt-able re-auth path).
- `### Host-side CLI (Story 2.6)` above — `shell.sh` / `attach.sh` interactive-exec primitives that `gh-auth-host.sh` mirrors via `claude-host.sh` intermediary.
- `### Claude Code authentication (Story 2.8)` above — sibling auth-class verb; `gh-auth-host.sh` mirrors `claude-host.sh` verbatim with gh-specific substitutions.
- Story 2.9 file `_bmad-output/implementation-artifacts/2-9-gh-cli-oauth-via-pnpm-gh-auth.md` — full spec, scope clarifications SC-1..SC-17, upstream-CLI + GitHub-OAuth-endpoint carve-out, AC 4 Epic 3 halt-able contract.

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
