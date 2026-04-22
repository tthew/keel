# Invariant — Devbox container hardening (non-root user + capability bounding set + tmpfs noexec/nosuid + named volume for /home/dev)

**Scope:** every Keel-forked devbox container (`packages/devbox/`) and the Ralph iteration environments that consume it.
**Status:** non-toggle-able at the substrate level; fork-time requirement.
**Machine-enforced in:** spec-enforced at 1.0 via content-hashed manifest entry + pre-merge sync-gate (`packages/keel-invariants/` FR43); runtime compose-shape check (parsing `docker-compose.yml`, asserting the `volumes:` stanza is a named volume and the `cap_drop`/`cap_add`/`security_opt` posture matches this contract, rejecting accidental bind-mount drift) deferred to Story 2.17 OR a dedicated `packages/keel-invariants/src/check-devbox-compose-shape.ts` in Story 2.6+ per Story 2.5 SC-10. At 1.0 the static drift detection + the SC-6 unconditional named-volume-form phrasing in the compose file provide the enforcement surface; no runtime parser ships with Story 2.5.
**Normative reference:** `_bmad-output/planning-artifacts/prd.md` § NFR7 + § NFR8 + § NFR8a + § NFR10; `_bmad-output/planning-artifacts/architecture.md` § Execution environment (lines 73, 173, 542-548); `AGENTS.md` § Devbox iteration environment.

## Intent

The devbox container's process posture is **minimum-privilege**, with **layered barriers** that a runtime compromise must cross before reaching persistence, host escape, or lateral privilege:

1. Processes run as a non-root `dev` user (UID/GID 1000) — a container break-out that lands at the shell does not start from UID 0.
2. The kernel capability bounding set is reduced to three narrow substrate-operational caps (NET_ADMIN + NET_RAW + NET_BIND_SERVICE) via `cap_drop: [ALL]` + explicit `cap_add`.
3. `no-new-privileges:true` sets `PR_SET_NO_NEW_PRIVS=1` on PID 1 — the kernel masks file-cap `F(effective)` bits on exec + disables setuid-bit privilege elevation, so even a setuid-root binary cannot escalate.
4. `/tmp` and `/var/tmp` mount as tmpfs with `noexec,nosuid` — a dropped-in executable in those directories cannot be executed; setuid bits in those paths are honored by neither mount nor NNP.
5. Persistent state for `/home/dev` (Claude Code tokens per Story 2.8, `gh` tokens per Story 2.9, shell history) lives in a named Docker volume `keel_home_dev` — never a host bind-mount. A host compromise cannot read tokens via filesystem traversal; a container compromise cannot persist outside the named volume.

Threat model: this contract targets a **post-exploitation runtime compromise** that lands at the entrypoint's user context — the attacker who already executes arbitrary code as `dev` must cross cap-drop + NNP + tmpfs-noexec + named-volume-only-persistence barriers to gain persistence, escalate privilege, or escape the container. It does NOT target build-time supply-chain attacks (that is Epic 4 scanner territory) or kernel 0days (out of substrate scope at 1.0).

## Contract

### Non-root dev user

Dockerfile creates `dev` with `groupadd --gid 1000 dev && useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home dev`, chowns `/home/dev` to `dev:dev` at image-build time (so first-boot `keel_home_dev` volume auto-init preserves correct ownership per Docker's populate-from-image semantics), and emits `USER dev` before `ENTRYPOINT`. UID/GID 1000 is the Linux first-human-user convention and aligns with most non-root host UIDs on macOS + Apple-Silicon Docker Desktop, minimising bind-mount chown friction under dropped `CAP_CHOWN`. Shell is `/bin/bash` (not `/bin/sh` → `dash` on Ubuntu 24.04) for operator-shell consistency with `entrypoint.sh`'s `#!/usr/bin/env bash` shebang.

### Capability bounding set

`docker-compose.yml` declares `cap_drop: [ALL]` (strips every kernel capability including those inherited from the executable's bounding set) plus `cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE]`. Each cap has a distinct substrate-operational rationale:

- `NET_ADMIN` — nftables rule load via netlink (Story 2.3 egress policy; `reload-egress.sh` invokes `nft -f <tempfile>` which requires netlink write).
- `NET_RAW` — raw-socket probes dnsmasq may issue during health/connectivity checks.
- `NET_BIND_SERVICE` — dnsmasq binds port 53 under `cap_drop: [ALL]`. The bounding set without this cap excludes `NET_BIND_SERVICE` even from root-equivalent processes (Linux kernel kernel-strips a cap from the bounding set even if the process has `geteuid() == 0`). The `:<1024` port-bind requirement (kernel-enforced) has no alternative under `cap_drop: [ALL]` except an explicit cap_add — OR running dnsmasq on a high port + rewriting `resolv.conf` (rejected: breaks Story 2.3's `nameserver 127.0.0.1` contract).

This is a Story 2.5 reconciliation of AC 2's drafted "only NET_ADMIN and NET_RAW" language — the drafted parenthetical "(required by nftables in Story 2.3)" was the RATIONALE for those two caps, not an exclusivity clause. The three-cap list is the minimum viable bounding set under the story's `cap_drop: [ALL]` + dnsmasq :53-bind + USER dev posture. Companion PRD NFR7 "NET_ADMIN/NET_RAW-only kernel caps" text predates the bounding-set × port-bind interaction analysis; this doc supersedes the PRD text per FR44 manifest-authority discipline.

`security_opt: [no-new-privileges:true]` sets `PR_SET_NO_NEW_PRIVS=1` on PID 1. Under NNP, file-cap `F(effective)` bits are kernel-disabled on exec per capabilities(7) ("any bits that would ordinarily grant greater privileges are ignored"), and the setuid bit is similarly masked. The **load-bearing capability propagation path** is Docker ≥19.03's ambient-capability automation: when `cap_add` is declared alongside USER non-root, Docker raises each bounded cap into PID 1's ambient set via `prctl(PR_CAP_AMBIENT, PR_CAP_AMBIENT_RAISE, ...)`. Ambient caps survive `exec()` regardless of NNP (this is ambient's kernel-design purpose); PID 1 → entrypoint.sh → start-egress.sh → dnsmasq/nft all inherit the three caps without file-cap action. File caps via `setcap +eip` in the Dockerfile remain as a portability fallback for runtimes without Docker's ambient-cap automation (older Docker, some Podman-compat forks) — harmless no-ops under the primary NNP+ambient path.

### tmpfs posture

Two service-level tmpfs mounts via Compose long-syntax:

```yaml
tmpfs:
  - /tmp:exec=false,suid=false,size=${KEEL_DEVBOX_TMPFS_TMP_MB:-2048}m
  - /var/tmp:exec=false,suid=false,size=${KEEL_DEVBOX_TMPFS_VARTMP_MB:-1024}m
```

Compose `exec=false` → kernel `noexec`, `suid=false` → kernel `nosuid`. Sizes parameterised via Story 2.2's published `.envrc` knobs (`packages/devbox/.envrc.example:29-30`) per NFR8a retunability. `/var/log` is intentionally NOT tmpfs-mounted at 1.0 — dnsmasq + nftables log files live under `/workspace/logs/` per Story 2.3 SC-17 (the workspace bind-mount owns log persistence), and keeping `/var/log` as a normal image layer avoids invalidating dnsmasq-packaged log-dir initialization behavior. The `KEEL_DEVBOX_TMPFS_LOGS_MB` knob Story 2.2 published at `.envrc.example:31` remains inert at Story 2.5 and is NOT consumed by this contract.

### /home/dev named volume

`docker-compose.yml` declares a top-level `volumes:` block with a single named volume `keel_home_dev: {}` (default `local` driver, no `driver_opts`) and mounts it at `/home/dev` via a service-level `type: volume` entry. Docker populates the empty volume from the image layer's `/home/dev` ownership on first boot (auto-init-from-image semantics per docs.docker.com/storage/volumes/#populate-a-volume-using-a-container). The volume name `keel_home_dev` is:

- Underscore-only (Docker volume naming disallows most special chars).
- Matched to the `keel-devbox` container-name prefix for operator-greppability.
- Intentionally NOT parameterized by any `KEEL_DEVBOX_*` knob — the invariant is **explicitly non-toggle-able** per AC 4 ("no host bind-mount is used for /home/dev under any KEEL_DEVBOX_* setting"). The contract is substrate-authoritative; no operator-reachable setting can flip `/home/dev` to a bind-mount form.

Future stories subscribe to subpaths of this volume:

- Story 2.8 populates `/home/dev/.claude/` (Claude Code OAuth tokens).
- Story 2.9 populates `/home/dev/.config/gh/` (gh OAuth tokens).
- Shell history accumulates under `/home/dev/.local/share/{zsh,bash}/`.

They do NOT introduce separate volumes; they consume subpaths of `keel_home_dev`.

## Enforcement

### Static drift

Story 1.9's pre-merge sync-gate (FR43) computes this doc's `sha256` and compares it to the `contentHash` field of `INV-devbox-homedev-named-volume` in `packages/keel-invariants/src/invariants.manifest.ts`. Any edit to this doc without a matching manifest update (or vice versa) fails the gate with an expected-vs-actual hash diff. The gate also asserts that every manifest `anchors: [...]` entry matches a backtick-wrapped literal in the source doc; the `INV-devbox-homedev-named-volume` anchor at the end of this doc is the walker-findable target.

### Runtime compose-shape check (deferred)

Parsing `docker-compose.yml` at runtime (or at `pnpm devbox:start`), asserting:

- `services.devbox.cap_drop` contains `ALL`.
- `services.devbox.cap_add` is exactly `[NET_ADMIN, NET_RAW, NET_BIND_SERVICE]` (unordered set equality).
- `services.devbox.security_opt` contains `no-new-privileges:true`.
- `services.devbox.tmpfs` contains two entries, both with `exec=false,suid=false`, paths `/tmp` and `/var/tmp`.
- `services.devbox.volumes` contains a `type: volume, source: keel_home_dev, target: /home/dev` entry.
- Top-level `volumes:` declares `keel_home_dev` with no `driver_opts` that would rebind it to host.

Rejecting accidental bind-mount drift (e.g. an operator editing `docker-compose.yml` to set `source: ../../dev-home` for `target: /home/dev`) is a runtime concern with its own test matrix. Story 2.5 establishes the invariant surface + manifest registration; the TypeScript parser lands at Story 2.17 "Hook + settings bypass-resistance" OR a dedicated `packages/keel-invariants/src/check-devbox-compose-shape.ts` in Story 2.6+. This matches Story 2.3 SC-10's pattern where the invariant registration preceded the runtime check by several iterations.

## Verification

> **Note on compose-project-name overrides:** the verification commands below assume the pinned `name: keel-devbox` in `docker-compose.yml`. Operators who set `COMPOSE_PROJECT_NAME=<name>` or pass `-p <name>` to `docker compose` must substitute that project name in the volume FQN: `<name>_keel_home_dev` instead of `keel-devbox_keel_home_dev`. The substrate-authoritative named-volume contract (NFR10) is preserved regardless of project-name override — only the FQN prefix changes.

Live-smoke matrix for AC 1–5. Operator-workstation-deferred under DinD backend B (host socket-passthrough) per Story 2.4 SC-17 precedent — running `docker exec` against a cap-dropped container from a DinD-B iteration environment can poison the host's docker state; the M4-Pro native-Docker Desktop run is authoritative for AC 5 + AC 2 bounding-set verification.

### AC 1 — Non-root dev user

```sh
docker exec keel-devbox id
# Expect: uid=1000(dev) gid=1000(dev) groups=1000(dev)
```

### AC 2 — Capability bounding set + no-new-privileges

```sh
docker exec keel-devbox sh -c 'capsh --print'
# Expect 'Bounding set =cap_net_bind_service,cap_net_raw,cap_net_admin' (order not guaranteed; set equality)
docker inspect keel-devbox --format '{{ .HostConfig.SecurityOpt }}'
# Expect: [no-new-privileges]
```

### AC 3 — tmpfs /tmp + /var/tmp with noexec,nosuid

```sh
docker exec keel-devbox mount | grep /tmp
# Expect two lines:
#   tmpfs on /tmp type tmpfs (rw,nosuid,nodev,noexec,relatime,size=2097152k)
#   tmpfs on /var/tmp type tmpfs (rw,nosuid,nodev,noexec,relatime,size=1048576k)
```

### AC 4 — /home/dev named volume

```sh
docker inspect keel-devbox --format '{{ range .Mounts }}{{ .Type }} {{ .Source }} {{ .Destination }}\n{{ end }}'
# Expect one line resembling 'volume keel-devbox_keel_home_dev /home/dev'
docker volume inspect keel-devbox_keel_home_dev
# Expect Driver: local, Scope: local
```

### AC 5 Smoke A — /tmp noexec

```sh
docker exec keel-devbox sh -c 'printf "#!/bin/sh\necho hello\n" > /tmp/t.sh && chmod +x /tmp/t.sh && /tmp/t.sh; echo exit=$?'
# Expect nonzero exit: 'Permission denied'.
# MNT_NOEXEC produces EACCES only; ENOEXEC ("exec format error") is a
# distinct kernel error class fired for malformed shebangs or bad ELF
# magic, unrelated to the noexec mount flag — do not expect it here.
# Uses `printf` not `echo`: POSIX echo does NOT interpret \n without -e, so
# the shebang+body write is single-line with echo and does not produce a
# valid script — printf reliably emits both lines (SC-13).
```

### AC 5 Smoke B — no-new-privileges

```sh
docker exec keel-devbox sh -c 'grep ^NoNewPrivs /proc/self/status'
# Expect: "NoNewPrivs:\t1". Direct kernel-flag read — version-independent,
# no dependence on sudo's own NNP detection heuristics. Proves
# PR_SET_NO_NEW_PRIVS=1 is applied to the container's init process
# (and inherited by every `docker exec` descendant). Prior `sudo --help`
# form exited 0 without attempting privilege elevation — false-positive
# under any posture; /proc/self/status exercises the AC 5 NNP contract
# directly at the kernel interface.
```

### Capability-exercise smoke (SC-15 ambient-cap verification)

```sh
docker exec keel-devbox nft list table inet keel_egress
# Expect: nftables ruleset loaded (Story 2.3 egress policy active under
# cap-dropped posture). A successful load proves NET_ADMIN is in PID 1's
# ambient set (ambient cap propagation working).
docker exec keel-devbox sh -c 'ss -tlnp | grep :53'
# Expect: dnsmasq bound on 127.0.0.1:53. A successful bind proves
# NET_BIND_SERVICE is in dnsmasq's effective set via ambient propagation.
```

## Backend compatibility

Both DinD-A (true Docker-in-Docker, isolated daemon) and DinD-B (host socket-passthrough via `/var/run/docker.sock` bind-mount) preserve the hardening posture — the Docker daemon applies `cap_drop` / `cap_add` / `security_opt` / `tmpfs` / `volumes` at container-start regardless of which backend fronts the daemon. Live smokes that exercise `docker exec` against cap-dropped containers are operator-workstation-deferred under DinD-B per Story 2.4 SC-17 precedent — the DinD-B environment cannot safely exercise the full `docker exec` sequence without risk of poisoning the host's docker state. The M4-Pro native-Docker-Desktop run is authoritative for AC 5 + AC 2 bounding-set verification.

## Companion invariants

This contract composes with two peer Epic-2 substrate-security invariants to form the fork-time posture:

- `INV-devbox-dind-available` (fork-time Docker runtime requirement) — every fork's devbox-equivalent environment provides `docker` on PATH + reachable daemon + `docker compose` subcommand (`docs/invariants/devbox-dind.md`).
- `INV-devbox-egress-contract` (Story 2.3 fail-closed egress) — dnsmasq + nftables default-deny with IPv4/IPv6 parity + atomic reload (`docs/invariants/devbox-egress.md`).

Together these three form the Epic-2 substrate-security trio: environment (DinD available) + network (fail-closed egress) + process (hardened container). A fork that weakens any sub-contract pursues the AMEND path (source-level PR against this doc + `invariants.manifest.ts` + `INVARIANTS.md` anchor), not the FORK path.

## Amendment

This invariant is **substrate-authoritative**. Fork-extension via `INVARIANTS.fork.md` (FR45; `docs/invariants/fork.md` § Precedence) MAY add per-fork hardening (e.g. additional cap drops for stricter postures, larger tmpfs caps, additional tmpfs mounts) but MUST NOT relax the dev-user posture, the three-cap bounding set (except to narrow it further), the `no-new-privileges:true` posture, the tmpfs `noexec,nosuid` flags, or the `/home/dev` named-volume-only contract. A fork that needs to weaken any of those pursues the AMEND path (source-level PR against this doc + `invariants.manifest.ts` + `INVARIANTS.md` anchor together — the Story 1.6 + 1.9 source-level fork path). Substrate-wins precedence per `docs/invariants/fork.md` § Precedence.

## Consumption

- **Humans / AI agents:** read this file; when authoring Story 2.6 (host-side CLI), Story 2.8 (Claude Code OAuth), Story 2.9 (gh OAuth), Story 2.11 (shared-workspace mode), Story 2.13 (healthcheck), Story 2.17 (hook bypass-resistance), verify that the new code honours the contract surface here rather than introducing a parallel user, cap, or persistence path.
- **`AGENTS.md` § Devbox iteration environment → Container hardening (Story 2.5):** operator-readable summary pointing back to this invariant doc.
- **`packages/devbox/README.md` § Hardening (Story 2.5):** operator-quickstart with copy-paste verification commands.
- **`_bmad-output/planning-artifacts/architecture.md` § Execution environment (lines 73, 542-548):** references this invariant for the hardening posture narrative.
- **`_bmad-output/planning-artifacts/prd.md` § NFR7 / NFR8 / NFR8a / NFR10:** this doc supersedes the drafted NFR7 cap list per FR44 manifest-authority; the SC-4 three-cap rationale is the load-bearing reconciliation.
- **Story 1.9 sync-gate:** at pre-merge, asserts this file's content hash in `invariants.manifest.ts` matches its on-disk hash AND that the `INVARIANTS.md` anchor bullet names the matching backtick-wrapped stable ID.

## Extension (FR44)

Fork operators who need additional container-hardening contracts (e.g. seccomp profiles, AppArmor/SELinux labels, additional cap drops beyond the substrate three) document per-fork entries in their fork's `INVARIANTS.fork.md` under a `FORK-<fork-slug>-hardening-<slug>` entry. The substrate invariant remains unchanged; forks extend additively. If a fork substitution contradicts the contract surface (relaxed cap drops, bind-mounted `/home/dev`, tmpfs without `noexec,nosuid`), that is an AMEND-path change against this doc + `invariants.manifest.ts` + `INVARIANTS.md` anchor.

---

`INV-devbox-homedev-named-volume`
