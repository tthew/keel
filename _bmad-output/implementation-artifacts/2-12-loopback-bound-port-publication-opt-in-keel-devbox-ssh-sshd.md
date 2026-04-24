# Story 2.12: Loopback-bound port publication + opt-in `KEEL_DEVBOX_SSH` sshd

Status: ready-for-dev <!-- Ralph-internal `Story State` = `drafted` after `/bmad-create-story` lands. Sprint-status row flipped `backlog → ready-for-dev` per workflow.md step 6. Next iter advances `drafted → validated` via `/bmad-create-story (args: "review")`. -->

<!-- Note: Validation is optional. Run `/bmad-create-story (args: "review")` for pre-dev quality check before `/bmad-testarch-atdd` / `/bmad-dev-story`. -->

## Story

As a substrate maintainer,
I want every published devbox port bound to `127.0.0.1` (no `0.0.0.0`) and an opt-in sshd (enabled via `KEEL_DEVBOX_SSH=true`) that is pubkey-only and loopback-bound at `127.0.0.1:2222`,
So that the devbox's attack surface is limited to the host loopback, never a LAN or internet-reachable interface.

## Acceptance Criteria

1. **Loopback-bound port publication — every `ports:` mapping uses `127.0.0.1:<host>:<container>` form.** Given `packages/devbox/docker-compose.yml`, when I inspect the `ports:` block, then every port mapping uses the explicit `127.0.0.1:<host>:<container>` form (no `0.0.0.0:...` form, no bare `<host>:<container>` form which Docker silently binds to `0.0.0.0`). Story 2.2 (landed iter-148) already established this posture for the four publish ports `KEEL_DEVBOX_PORT_WEB` / `..._API` / `..._STORYBOOK` / `..._VITE_HMR` at `docker-compose.yml:153-157`; Story 2.12 PINS the posture as an invariant so future story edits cannot regress it. The new sshd port mapping (when added by AC 3) MUST also use the loopback-bound form.

2. **Default — `KEEL_DEVBOX_SSH=false` — sshd does NOT run AND port 2222 is NOT published.** Given `KEEL_DEVBOX_SSH=false` (the `.envrc.example:40` default; iterating per Story 2.2 SC the unset case also defaults to `false`), when the container starts (`pnpm devbox:start`), then no `sshd` process is running inside the container (`pgrep sshd` inside the container returns no PIDs / exit 1) AND `docker port keel-devbox` lists no `2222/tcp` mapping AND `docker compose -f packages/devbox/docker-compose.yml config` emits NO `127.0.0.1:2222:2222` line (compose stack matches the no-SSH posture at the YAML layer, not just the runtime layer). The four Story 2.2 publish ports remain published unaffected.

3. **Opt-in — `KEEL_DEVBOX_SSH=true` — sshd runs, pubkey-only, port 2222 loopback-bound, host keys persisted in named volume.** Given `KEEL_DEVBOX_SSH=true` in `.envrc`, when the container starts, then sshd runs inside the container bound to `127.0.0.1:2222` (server-side `ListenAddress 127.0.0.1` in `sshd_config` — defence-in-depth even though Docker's `127.0.0.1:2222:2222` already loopback-binds the published port) AND password auth is disabled (`PasswordAuthentication no`, `ChallengeResponseAuthentication no`, `KbdInteractiveAuthentication no`) AND only pubkey auth is allowed (`PubkeyAuthentication yes`) AND root login is disabled (`PermitRootLogin no`) AND host keys auto-generate on first boot via `ssh-keygen -A -f /home/dev/.ssh/host_keys/` (entrypoint logic — the keys persist in the `keel_home_dev` named volume per Story 2.5 so subsequent restarts re-use the same keys; first-boot generation is a one-time event). `docker port keel-devbox` lists `2222/tcp -> 127.0.0.1:2222` AND `docker compose … config` emits the loopback-bound `127.0.0.1:${KEEL_DEVBOX_SSH_PORT:-2222}:2222` line.

4. **External (non-loopback) connection refusal.** Given sshd is enabled (`KEEL_DEVBOX_SSH=true`), when an external (non-loopback) client attempts to connect (e.g., `ssh -p 2222 dev@<host-LAN-IP>` from a peer machine on the host's LAN), then the connection is refused at the Docker layer (the `127.0.0.1:2222:2222` mapping refuses non-loopback source IPs at the kernel iptables NAT layer — Docker emits `DNAT` rules scoped to `127.0.0.1`) AND only `ssh -p 2222 dev@127.0.0.1` from the host succeeds with a registered pubkey. AC verification is operator-workstation only — DinD backend B (the iteration env) cannot exercise non-loopback LAN clients meaningfully; substrate verification per Story 2.5 iter-186 posture (config-shape correctness via `docker compose config` + invariant doc claim).

5. **Operator authorized-keys flow — pubkey written to `/home/dev/.ssh/authorized_keys` inside named volume; persists across restarts.** Given a fork operator wants to add their pubkey, when they follow the documented flow in `packages/devbox/README.md § Opt-in SSH (Story 2.12)`, then the pubkey is appended to `/home/dev/.ssh/authorized_keys` inside the `keel_home_dev` named volume (Story 2.5 substrate; persists across container restarts + image rebuilds; tokens never bind-mounted to host per NFR10) AND a subsequent `ssh -p 2222 dev@127.0.0.1 -i <matching-private-key>` succeeds AND the pubkey survives `pnpm devbox:stop && pnpm devbox:start` AND survives `pnpm devbox:rebuild` (image rebuild) because the named volume is preserved across both operations (Story 2.6 AC 4 + Story 2.11 AC 1 contracts).

## Tasks / Subtasks

- [ ] **Task 1: Add `openssh-server` to the Dockerfile apt layer + bake `sshd_config` template** (AC 3, AC 4)
  - [ ] Edit `packages/devbox/Dockerfile:43-91` (apt-get layer): add `openssh-server` package alongside the existing `openssh-client` (line 65). Renovate `apt` manager (Story 1.15) tracks the package version.
  - [ ] Bake a hardened `sshd_config` template at image-build time. Source: `packages/devbox/sshd/sshd_config` (NEW file under `packages/devbox/sshd/` directory, mirroring the Story 2.3 `packages/devbox/dnsmasq/` + `packages/devbox/nftables/` template-directory convention). Copy via Dockerfile `COPY packages/devbox/sshd/sshd_config /etc/ssh/sshd_config` (path relative to compose build context — `packages/devbox/Dockerfile`'s context is `packages/devbox/` per `docker-compose.yml:69-71` `build.context: .`). Set permissions: `chmod 0644 /etc/ssh/sshd_config && chown root:root /etc/ssh/sshd_config`.
  - [ ] `sshd_config` content (verbatim — pinned to a hash hashed-ish minimum but not contentHash-tracked since not an INV-doc):
    ```
    # packages/devbox/sshd/sshd_config — Story 2.12
    # Hardened sshd config; only-loopback-bound + pubkey-only.
    Port 2222
    ListenAddress 127.0.0.1
    HostKey /home/dev/.ssh/host_keys/ssh_host_ed25519_key
    HostKey /home/dev/.ssh/host_keys/ssh_host_rsa_key
    PermitRootLogin no
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    KbdInteractiveAuthentication no
    PubkeyAuthentication yes
    AuthorizedKeysFile /home/dev/.ssh/authorized_keys
    AllowUsers dev
    UsePAM no
    PrintMotd no
    AcceptEnv LANG LC_*
    Subsystem sftp /usr/lib/openssh/sftp-server
    LogLevel INFO
    SyslogFacility AUTH
    ```
  - [ ] Pre-create `/home/dev/.ssh/` + `/home/dev/.ssh/host_keys/` directories in the Dockerfile near line 252 (where `/home/dev/.claude` + `/home/dev/.config/gh` are pre-created). Mode 0700; owner `dev:dev` (matches Story 2.5 non-root-user posture). Do NOT pre-generate the host keys at image-build time — first-boot generation in entrypoint.sh ensures the keys live in the named-volume payload (per AC 3 persistence requirement).
  - [ ] Add `setcap +ep` invocation if needed for sshd port-bind under `cap_drop: [ALL]` + `cap_add: [..., NET_BIND_SERVICE]`. Port 2222 is >1024 so NET_BIND_SERVICE is NOT required for the bind itself; sshd should run as `dev` (UID 1000) under USER dev with no extra capability. Verify at impl time: `ss -tlnp` inside the container confirms `127.0.0.1:2222` is bound by `sshd` running as `dev`.

- [ ] **Task 2: Conditionally publish port 2222 via a compose override file `docker-compose.ssh.yml` + resolver wiring** (AC 2, AC 3)
  - [ ] Create `packages/devbox/docker-compose.ssh.yml` — Compose override that ADDS the port 2222 mapping when included. Shape:
    ```yaml
    # packages/devbox/docker-compose.ssh.yml — Story 2.12
    # Compose override: adds loopback-bound port 2222 publication for opt-in sshd.
    # Included by host-side shims when KEEL_DEVBOX_SSH=true. NEVER edit the
    # base docker-compose.yml ports block to add 2222 — this file is the
    # only site that publishes 2222.
    services:
      devbox:
        ports:
          - '127.0.0.1:${KEEL_DEVBOX_SSH_PORT:-2222}:2222'
    ```
  - [ ] **Compose-CLI inclusion path.** When `KEEL_DEVBOX_SSH=true`, host-side shims that invoke `docker compose` (the 13 from Story 2.6's CLI surface that compose-up / compose-down / compose-config — `start.sh`, `stop.sh`, `restart.sh`, `build.sh`, `rebuild.sh`, `clean.sh`, `logs.sh`, `status.sh`, `env-check.sh` for `docker compose config` smokes) MUST add `-f packages/devbox/docker-compose.ssh.yml` AFTER the base `-f packages/devbox/docker-compose.yml`. Last-write-wins compose-merge semantics: the override file's `ports:` array is APPENDED (Compose v2 `!override` would replace; default merge appends list-typed keys for `services.<svc>.ports`).
  - [ ] **Resolver extension.** Add a NEW function `resolve_ssh_state()` to `packages/devbox/scripts/lib/main-repo-resolver.sh` (sibling to `resolve_main_repo_and_workdir` + `resolve_mode_specific_state`). Function reads `KEEL_DEVBOX_SSH` from the process env, normalises (lowercase + accept-`true`-only — fail-closed to no-SSH for any other value, mirroring Story 2.11 `KEEL_DEVBOX_SHARED` normalisation pattern at `lib/main-repo-resolver.sh:146`), and exports two outputs:
    - `KEEL_DEVBOX_SSH_RESOLVED=true|false` (canonical normalised value).
    - `KEEL_DEVBOX_COMPOSE_FILES_ARGS` — a string containing the compose `-f` arg list. Per-fork no-SSH: `"-f packages/devbox/docker-compose.yml"`. Opt-in SSH: `"-f packages/devbox/docker-compose.yml -f packages/devbox/docker-compose.ssh.yml"`. Shared mode (Story 2.11) does NOT change this — the override composes regardless of mode (sshd is per-container, not per-mode).
  - [ ] Caller invocation order: `resolve_main_repo_and_workdir` → `resolve_mode_specific_state` → `resolve_ssh_state` → exports → downstream `docker compose` invocations.
  - [ ] Update existing 9 compose-invoking shims to consume `${KEEL_DEVBOX_COMPOSE_FILES_ARGS}` instead of hardcoded `-f packages/devbox/docker-compose.yml`. Affected sites (canonical inventory via `grep -rn 'docker compose -f packages/devbox/docker-compose.yml' packages/devbox/scripts/`): `start.sh`, `stop.sh`, `restart.sh`, `build.sh`, `rebuild.sh`, `clean.sh`, `logs.sh`, `status.sh`, `env-check.sh`. Each substitution: `docker compose -f packages/devbox/docker-compose.yml` → `docker compose ${KEEL_DEVBOX_COMPOSE_FILES_ARGS}`.
  - [ ] Header comment block update: amend the existing `lib/main-repo-resolver.sh:9-28` doc-block (already extended by Story 2.11) with a NEW `SSH state (Story 2.12)` paragraph naming the two outputs (`KEEL_DEVBOX_SSH_RESOLVED`, `KEEL_DEVBOX_COMPOSE_FILES_ARGS`).

- [ ] **Task 3: First-boot host-key generation + conditional sshd start in `entrypoint.sh`** (AC 3, AC 5)
  - [ ] Edit `packages/devbox/entrypoint.sh` — add a NEW block AFTER the existing Story 2.3 egress-init block (currently the last meaningful block before `exec gosu dev "$@"` at line 154) and BEFORE the `exec gosu dev "$@"` handoff. Block contract:
    ```bash
    # Story 2.12: opt-in sshd. KEEL_DEVBOX_SSH is normalised by the host-side
    # resolver before container start; here we honour the in-container env var
    # (propagated via docker-compose.yml § environment).
    if [[ "${KEEL_DEVBOX_SSH:-false}" == "true" ]]; then
      # First-boot: generate host keys into the named-volume path so they
      # persist across restarts (Story 2.5 keel_home_dev volume; AC 3).
      if [[ ! -f /home/dev/.ssh/host_keys/ssh_host_ed25519_key ]]; then
        mkdir -p /home/dev/.ssh/host_keys
        chown -R dev:dev /home/dev/.ssh/host_keys 2>/dev/null || true
        chmod 0700 /home/dev/.ssh/host_keys
        gosu dev ssh-keygen -A -f /home/dev/.ssh/  # generates into ./host_keys/ via the -f prefix + symlink convention
      fi
      # Touch the authorized_keys file (mode 0600) so sshd does not refuse
      # to start under StrictModes (default yes). Empty file = no inbound
      # auth; operator appends pubkeys via the documented flow (AC 5).
      if [[ ! -f /home/dev/.ssh/authorized_keys ]]; then
        touch /home/dev/.ssh/authorized_keys
        chown dev:dev /home/dev/.ssh/authorized_keys 2>/dev/null || true
        chmod 0600 /home/dev/.ssh/authorized_keys
      fi
      # Launch sshd in background as dev (port 2222 > 1024, no NET_BIND_SERVICE
      # needed). The -D flag keeps sshd in foreground, but we background with
      # `&` because the entrypoint's `exec gosu dev "$@"` is the PID 1 keepalive.
      gosu dev /usr/sbin/sshd -D -e 2>>/var/log/sshd.log &
    fi
    ```
  - [ ] **`ssh-keygen -A -f` semantics audit:** OpenSSH's `-A` generates one key per algorithm using default paths under `/etc/ssh/` (NOT under `-f`'s prefix). The Dockerfile + sshd_config diverts via `HostKey /home/dev/.ssh/host_keys/...` — entrypoint MUST explicitly `ssh-keygen -t ed25519 -f /home/dev/.ssh/host_keys/ssh_host_ed25519_key -N ""` and `ssh-keygen -t rsa -b 4096 -f /home/dev/.ssh/host_keys/ssh_host_rsa_key -N ""` rather than rely on `-A`. Verify at impl time + adjust the entrypoint block accordingly. Empty passphrase via `-N ""` avoids the interactive prompt; host keys are not user-passphrase-protected in any conventional sshd setup.
  - [ ] **`gosu dev` ordering:** `ssh-keygen` runs BEFORE the `exec gosu dev "$@"` handoff which still runs as root (per `user: "0:0"` in compose; gosu drops to dev for the CMD only). The keygen explicitly invokes `gosu dev` so the key files are created with dev:dev ownership from t=0 — avoids relying on `chown` calls that fail under `cap_drop: [ALL]` without CAP_CHOWN (Story 2.5 hardening — same `2>/dev/null || true` best-effort posture as the existing `entrypoint.sh:101-105` `chown` block).
  - [ ] **Background-process death handling:** sshd in background (`&`) is intentional — PID 1 is `gosu dev sleep infinity` (or Epic 3's Ralph TUI). If sshd dies mid-session, the entrypoint does NOT restart it (sshd's own `-D` foreground mode + Docker's restart policy do not compose here; restart policy is at the container level not the in-container PID level). Story 2.13 will add a healthcheck that probes `nc -z 127.0.0.1 2222` when `KEEL_DEVBOX_SSH=true` and fails the container's healthcheck if sshd is down — operator can `pnpm devbox:restart` to recover.
  - [ ] **Forbidden runtime install.** `sshd_config` is BAKED at image-build time (Task 1); entrypoint MUST NOT modify it at runtime. `ssh-keygen` is a binary from `openssh-server` — no apt invocation, no curl-pipe-sh, conforms to entrypoint.sh's iter-1 forbidden-runtime-install posture (Story 2.1 AC 2; entrypoint header comment block lines 17-19).

- [ ] **Task 4: Propagate `KEEL_DEVBOX_SSH` into the container via compose `environment:` block** (AC 3 prerequisite)
  - [ ] Edit `packages/devbox/docker-compose.yml` — extend the existing `environment:` block at line 135-136 (currently propagates only `KEEL_DEVBOX_REPO_NAME`) to add `KEEL_DEVBOX_SSH`:
    ```yaml
    environment:
      KEEL_DEVBOX_REPO_NAME: ${KEEL_DEVBOX_REPO_NAME:-ralph-bmad}
      KEEL_DEVBOX_SSH: ${KEEL_DEVBOX_SSH:-false}
    ```
  - [ ] Without this propagation, entrypoint.sh's `${KEEL_DEVBOX_SSH:-false}` reads from the container's env which is empty for non-explicitly-propagated vars (compose's `${VAR}` interpolation runs on the HOST at parse time; the container only sees vars in `environment:` or `env_file:`).
  - [ ] Remove the existing TODO marker at `docker-compose.yml:250` (`# TODO(Story 2.12): opt-in sshd + port 2222 publication via KEEL_DEVBOX_SSH=true.`) since Story 2.12 lands the full opt-in path.
  - [ ] Amend the Story-roadmap comment block at `docker-compose.yml:1-27` to add a Story 2.12 LANDED line: `#   - Story 2.12 : opt-in sshd via KEEL_DEVBOX_SSH=true (port 2222, pubkey-only, host keys persisted in keel_home_dev). LANDED iter-<this>.` Insertion point: between the existing Story 2.11 line (`docker-compose.yml:22`) and the existing Story 2.13 line (`docker-compose.yml:23`). Match the past-tense LANDED-iter-NNN pattern of Stories 2.2 / 2.3 / 2.5 / 2.11.

- [ ] **Task 5: Register `INV-devbox-ssh` + author `docs/invariants/devbox-ssh.md`** (AC 1–5 machine-enforced contract)
  - [ ] Add new entry to `packages/keel-invariants/src/invariants.manifest.ts`:
    - `id: 'INV-devbox-ssh'`
    - `description: 'Opt-in sshd via KEEL_DEVBOX_SSH=true — pubkey-only, root-disabled, loopback-bound 127.0.0.1:2222, host keys + authorized_keys persisted in keel_home_dev named volume; loopback-bound port publication invariant for ALL ports (no 0.0.0.0 / no bare-port bindings) (Story 2.12).'`
    - `sourcePath: 'docs/invariants/devbox-ssh.md'`
    - `contentHash: '<sha256 of the authored md file content>'`
    - `anchors: ['INV-devbox-ssh']`
  - [ ] **InvariantSchema five-field compliance** (Story 2.3 iter-156 LESSON; verified at `packages/keel-invariants/src/invariants.manifest.ts:3-15`): `InvariantSchema` = `{id, description, sourcePath, contentHash, anchors}` — no `name` field; `anchors` entries are bare ID strings; `contentHash` is bare 64-char lowercase hex. Cross-check existing Story 2.11 `INV-devbox-mode` entry for canonical shape.
  - [ ] Author `docs/invariants/devbox-ssh.md` with the following H2 sections (Story 2.3 iter-156 LESSON: multi-faceted contracts embed sub-schemas verbatim in the `sourcePath` doc):
    - `## Loopback-bound port publication contract` — every `ports:` mapping MUST use `127.0.0.1:<host>:<container>` form; bare `<host>:<container>` and explicit `0.0.0.0:...` are forbidden. Applies to base compose + every override (sibling `docker-compose.ssh.yml`, future per-fork add-ons).
    - `## SSH signal` — `KEEL_DEVBOX_SSH=true|false|unset`; normalisation rules (lowercase compare; non-`true` defaults to `false`; fail-closed to no-SSH on any unrecognised value).
    - `## Opt-in sshd contract` — sshd runs as UID 1000 (`dev`); `ListenAddress 127.0.0.1`; `Port 2222`; `PermitRootLogin no`; `PasswordAuthentication no`; `PubkeyAuthentication yes`; `AllowUsers dev`; host keys at `/home/dev/.ssh/host_keys/`; `authorized_keys` at `/home/dev/.ssh/authorized_keys`; first-boot key generation; persistence via `keel_home_dev` named volume.
    - `## No-SSH default contract` — `KEEL_DEVBOX_SSH=false` (or unset): sshd is NOT started AND port 2222 is NOT published AND `docker compose config` emits no 2222 mapping. Compose override file `packages/devbox/docker-compose.ssh.yml` is the SINGLE site that publishes 2222; the base `docker-compose.yml` MUST NOT publish 2222.
    - `## Resolver contract` — `packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_ssh_state()` is the single resolution site; every host-side compose-invoking shim invokes it after `resolve_mode_specific_state`; exports `KEEL_DEVBOX_SSH_RESOLVED` + `KEEL_DEVBOX_COMPOSE_FILES_ARGS`.
    - `## External (non-loopback) connection refusal` — Docker's `127.0.0.1:2222:2222` mapping refuses non-loopback source IPs at the iptables-NAT layer; defence-in-depth via sshd_config's `ListenAddress 127.0.0.1`. Operator-workstation verification only; substrate verifies via `docker compose config` shape.
    - `## Operator authorized-keys flow` — pubkey appended to `/home/dev/.ssh/authorized_keys` from inside the container (`pnpm devbox:shell` then `echo 'ssh-ed25519 AAAA…' >> ~/.ssh/authorized_keys`); persistence guaranteed by the named volume across restarts + image rebuilds; agents MUST NOT bind-mount or copy `authorized_keys` outside the named volume (NFR10 — same posture as Story 2.8/2.9 OAuth tokens).
    - `## Named volume relationship to INV-devbox-homedev-named-volume` — Story 2.5's `INV-devbox-homedev-named-volume` pins the unqualified name `keel_home_dev`; Story 2.12's host keys + authorized_keys live INSIDE that volume; Story 2.12 does NOT touch the volume's name or substrate posture.
    - `## Invariant stability` — loopback-bound port publication is a SUBSTRATE INVARIANT — forks MAY NOT publish to `0.0.0.0` or use bare-port form. Opt-in sshd is OPERATOR-DEFAULT-OFF — forks MAY NOT change the default to `true`. Fork-level growth-tier `INVARIANTS.fork.md` rules MAY add fork-specific sshd_config overlays (e.g., MFA via `AuthenticationMethods publickey,keyboard-interactive`) but MAY NOT weaken substrate defaults (no PasswordAuthentication; no PermitRootLogin).
  - [ ] Compute `contentHash`: `sha256sum docs/invariants/devbox-ssh.md | awk '{print $1}'`. Paste 64-char lowercase hex into the manifest entry. `pnpm keel-invariants:check` MUST pass after manifest + doc both land (Story 1.9 sync-gate verification).
  - [ ] Append entry to `INVARIANTS.md` under the devbox section after `INV-devbox-mode` (Story 2.11 anchor) as: ``- **`INV-devbox-ssh`** — Opt-in sshd + loopback-bound port publication contract (`KEEL_DEVBOX_SSH=true` opens 127.0.0.1:2222 pubkey-only; ALL ports must use 127.0.0.1:<host>:<container> form). Source: `docs/invariants/devbox-ssh.md`.`` Index-only, no body (FR42).
  - [ ] Anchor bullet MUST match the verbatim regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` per `packages/keel-invariants/src/sync-gate.ts:24` (Story 1.9 sync-gate). Lowercase-after-`INV-` prefix MANDATORY (Story 1.9 iter-7 LESSON).
  - [ ] Add new `### Devbox SSH (Story 2.12)` H3 in `INVARIANTS.md` between `### Devbox mode (Story 2.11)` and the next existing H3 (or end of devbox section if 2.12 is the last). One-line H3 body, then the anchor bullet underneath.

- [ ] **Task 6: Operator + agent documentation** (AC 1–5 comprehension)
  - [ ] **`packages/devbox/README.md`** — append new H2 `## Opt-in SSH (Story 2.12)` AFTER the existing `## Per-fork vs shared devbox mode (Story 2.11)` H2 and BEFORE `## cc-devbox upstream provenance` (SC-17 sibling-append; do NOT edit prior story sections). Content:
    - (a) Loopback-bound port publication invariant statement (cite `INV-devbox-ssh` for machine-enforcement); apply to ALL future port additions.
    - (b) `.envrc` snippet showing `KEEL_DEVBOX_SSH=false` (default) and `KEEL_DEVBOX_SSH=true` (opt-in).
    - (c) Three operator walkthroughs:
      - **Default no-SSH walkthrough:** fresh fork, `.envrc` default, `pnpm devbox:start` → no port 2222 mapping (`docker port keel-devbox` confirms).
      - **Opt-in sshd walkthrough:** operator sets `KEEL_DEVBOX_SSH=true` in `.envrc`, runs `pnpm devbox:start` (host-side resolver appends `-f docker-compose.ssh.yml` to the compose CLI), entrypoint generates host keys on first boot + starts sshd, operator confirms via `docker port keel-devbox` (lists `2222/tcp -> 127.0.0.1:2222`) + `pgrep sshd` inside `pnpm devbox:shell`.
      - **Authorized-keys flow walkthrough:** operator runs `pnpm devbox:shell` → `cat ~/.ssh/authorized_keys` (empty initially) → `echo 'ssh-ed25519 AAAAxxx user@host' >> ~/.ssh/authorized_keys` (append from inside the container; pubkey persists in named volume) → exit shell → from host, `ssh -p 2222 -i ~/.ssh/id_ed25519 dev@127.0.0.1` succeeds.
    - (d) Mode-flip note: switching between `KEEL_DEVBOX_SSH=false` and `=true` requires container teardown (`pnpm devbox:stop && pnpm devbox:start`) — entrypoint reads the env var ONCE at container start. Mid-session env-var flips have no effect until restart.
    - (e) `INV-devbox-ssh` citation for the machine-enforced contract.
  - [ ] **DO NOT modify existing `## Host-side CLI (Story 2.6)`, `## Ralph loop (Story 2.7)`, `## Claude Code authentication (Story 2.8)`, `## gh CLI authentication (Story 2.9)`, `## Prerequisite check (Story 2.10)`, or `## Per-fork vs shared devbox mode (Story 2.11)` sections** — append a NEW sibling H2 only (SC-17).
  - [ ] **`AGENTS.md`** — append new H3 `### Opt-in SSH (Story 2.12)` AFTER the existing `### Per-fork vs shared devbox mode (Story 2.11)` H3 under § Devbox iteration environment. Content:
    - (a) Loopback-bound port publication invariant one-line statement: `Every published devbox port MUST use 127.0.0.1:<host>:<container> form. New port additions in any compose override file must follow this contract.`
    - (b) `KEEL_DEVBOX_SSH` opt-in one-liner + resolver site citation: `packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_ssh_state()`.
    - (c) Compose override file pattern: `packages/devbox/docker-compose.ssh.yml` is the SINGLE site that publishes port 2222; included by the resolver into the compose CLI when `KEEL_DEVBOX_SSH=true`.
    - (d) Token persistence: host keys + `authorized_keys` live INSIDE the `keel_home_dev` named volume (Story 2.5 substrate; mirrors Story 2.8/2.9 OAuth-token-persistence posture). Agents MUST NOT bind-mount, copy, surface, or inspect these files outside the named volume.
    - (e) Re-auth pointer: if a Ralph subagent reports an SSH connection failure to `127.0.0.1:2222`, queue `pnpm devbox:shell` + manual `~/.ssh/authorized_keys` append as a fix task (operator-interactive). Agents SHOULD NOT auto-modify `authorized_keys` from outside the container.
    - (f) `INV-devbox-ssh` citation for the machine-enforced contract.
    - (g) Cross-references: § Container hardening (Story 2.5) for the named volume substrate; § Claude Code authentication (Story 2.8) + § gh CLI authentication (Story 2.9) for the token-persistence pattern parallel.
  - [ ] **DO NOT modify existing `### Host-side CLI (Story 2.6)`, `### Ralph loop (Story 2.7)`, `### Claude Code authentication (Story 2.8)`, `### gh CLI authentication (Story 2.9)`, `### Prerequisite check (Story 2.10)`, or `### Per-fork vs shared devbox mode (Story 2.11)` sections** — append a NEW sibling H3 only (SC-17).
  - [ ] **`packages/devbox/.envrc.example:40` comment update (SC-15):** current comment reads `# Opt-in sshd + port 2222 publication. Active Story 2.12; Story 2.2 publishes the knob only.` Update to past tense: `# false = no sshd (default); true = opt-in sshd + port 2222 publication. Active at Story 2.12 (landed iter-<this>). Resolver: packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_ssh_state(). Compose override: packages/devbox/docker-compose.ssh.yml.`
  - [ ] **Change Log v1.0 entry** — record 5 ACs + 6 tasks + ~14 SCs (see § Success Criteria); initial draft; dev-ready; ATDD forecast: NON-SKIP for ACs 1, 2, 3 (port-form assertions via `docker compose config` grep + entrypoint behaviour smokes); operator-workstation-deferred for ACs 4, 5 (live SSH connect requires real Docker + SSH client); trace forecast NON-WAIVED; CR PATCH forecast 0–3 opener (moderate novel surface — entrypoint extension + compose override + resolver function are structurally mirrored on Stories 2.3/2.5/2.11 precedents but the sshd-host-key-bootstrap path is genuinely novel; iter-253 LESSON forecast-carry: ~1/1000/year operator-edge SECOND-class DEFERs likely).
  - [ ] **Sprint-status housekeeping:** `/bmad-create-story` workflow's step 6 flips `2-12-…: backlog → ready-for-dev` at THIS iteration's landing. `/bmad-dev-story` Step 4 flips `ready-for-dev → in-progress`; Step 9 flips `in-progress → review`. `/bmad-code-review (args: "2")` closure flips `review → done`.

## Dev Notes

### Relevant architecture patterns and constraints

- **Substrate authority: `packages/devbox/`.** All Story 2.12 changes scoped to `packages/devbox/Dockerfile`, `packages/devbox/docker-compose.yml`, the new `packages/devbox/docker-compose.ssh.yml`, the new `packages/devbox/sshd/sshd_config`, `packages/devbox/entrypoint.sh`, `packages/devbox/scripts/lib/main-repo-resolver.sh`, and the 9 compose-invoking shims. Plus the new `docs/invariants/devbox-ssh.md` invariant doc + `INVARIANTS.md` anchor + manifest entry + operator docs at `packages/devbox/README.md` + `AGENTS.md` + `.envrc.example` comment update.
- **Compose-override pattern.** Conditional port publication uses Docker Compose v2's `-f` file-merge semantics (last-file-wins for scalars; APPEND for list-typed keys like `services.<svc>.ports`). Pinned in Story 2.6 architecture (the `${KEEL_DEVBOX_COMPOSE_FILES_ARGS}` env-var carrying the compose `-f` arg list). Docker Compose v2.20+ floor pinned at `packages/devbox/docker-compose.yml:78` (Story 2.1 substrate). The override file's `services.devbox.ports` array adds the port 2222 entry to the base file's existing ports array (which has 4 entries from Story 2.2).
- **`set -euo pipefail` discipline + resolver function shape.** Mirror Story 2.11 `resolve_mode_specific_state()` pattern: pure string manipulation (no command rc-dependence), default-substitution `${KEEL_DEVBOX_SSH:-false}` to survive `set -u`. Case-fold normalisation via `tr '[:upper:]' '[:lower:]'` (mirrors `lib/main-repo-resolver.sh:146` Story 2.11 site).
- **Entrypoint forbidden-runtime-install posture.** Story 2.1 AC 2 + entrypoint header lines 17-19 forbid `apt-get` / `npm install` / `pip install` / `curl…|sh` at runtime. Task 3's entrypoint extension only invokes `ssh-keygen` (binary baked at image-build time via `openssh-server` apt package) and `gosu dev /usr/sbin/sshd -D`; neither violates the posture.
- **`INV-devbox-homedev-named-volume` interaction.** Host keys + authorized_keys live INSIDE `keel_home_dev` (Story 2.5 substrate). Story 2.12 does NOT change the named-volume contract; it only adds new file-tree paths under `/home/dev/.ssh/`. Persistence semantics inherited unchanged.
- **`INV-devbox-mode` interaction (Story 2.11).** SSH state is per-CONTAINER, not per-MODE. Both per-fork mode (`keel-devbox` container) and shared mode (`keel-devbox-shared` container) honour `KEEL_DEVBOX_SSH` independently. The compose-files-args resolver output is the same in both modes; the per-mode container-name resolution composes orthogonally.
- **Defence-in-depth posture for AC 4.** Two layers refuse non-loopback connections: (1) Docker's iptables-NAT layer (`127.0.0.1:2222:2222` mapping); (2) sshd's own `ListenAddress 127.0.0.1` directive. If the operator's host firewall fails / Docker daemon misconfigures, sshd still refuses non-loopback inbound. If sshd_config is corrupted, Docker still refuses. Both layers must misbehave for an external IP to reach the dev shell.
- **No PRD amendment required.** PRD line 551 (architecture.md `:551`) verbatim matches AC 1 (loopback-bound ports + opt-in sshd). PRD line 74 (`:74`) verbatim matches AC 3 (`KEEL_DEVBOX_SSH=true` pubkey-only loopback-bound). Architecture line 550 verbatim matches the healthcheck-with-sshd-when-enabled posture (Story 2.13 scope, not Story 2.12).
- **Story 2.13 forward-compat.** Story 2.12's sshd-running-as-background-process leaves PID 1 free for the existing `sleep infinity` (or Epic 3's Ralph TUI). Story 2.13 will add a healthcheck that probes sshd liveness when `KEEL_DEVBOX_SSH=true`; Story 2.12 makes no healthcheck claim.

### Source tree components to touch

- `packages/devbox/Dockerfile` — apt-layer addition (`openssh-server`); `COPY packages/devbox/sshd/sshd_config`; pre-create `/home/dev/.ssh/host_keys/`.
- `packages/devbox/sshd/sshd_config` — NEW file (verbatim contents in Task 1).
- `packages/devbox/docker-compose.yml` — `environment:` block addition for `KEEL_DEVBOX_SSH`; remove TODO marker; Story 2.12 LANDED roadmap line.
- `packages/devbox/docker-compose.ssh.yml` — NEW file (conditional port-2222 override).
- `packages/devbox/entrypoint.sh` — first-boot host-key-gen + conditional sshd-launch block.
- `packages/devbox/scripts/lib/main-repo-resolver.sh` — new `resolve_ssh_state()` function + header doc-block extension.
- `packages/devbox/scripts/{start,stop,restart,build,rebuild,clean,logs,status,env-check}.sh` — 9 compose-invoking shims; substitute hardcoded `-f docker-compose.yml` with `${KEEL_DEVBOX_COMPOSE_FILES_ARGS}`.
- `packages/keel-invariants/src/invariants.manifest.ts` — new `INV-devbox-ssh` entry.
- `docs/invariants/devbox-ssh.md` — NEW authoritative contract doc.
- `INVARIANTS.md` — new `### Devbox SSH (Story 2.12)` H3 + one-line anchor bullet.
- `packages/devbox/README.md` — new `## Opt-in SSH (Story 2.12)` H2.
- `AGENTS.md` — new `### Opt-in SSH (Story 2.12)` H3.
- `packages/devbox/.envrc.example` — line 40 comment past-tense update.

### Testing standards summary

- **ATDD forecast: NON-SKIP for ACs 1, 2, 3.** Red-phase scaffolds candidate:
  - AC 1: smoke — `docker compose -f packages/devbox/docker-compose.yml config | grep -E '"published":\s*"127\.0\.0\.1:'` returns 4 lines (Story 2.2 ports); NO line missing the `127.0.0.1:` prefix; NO `0.0.0.0:` prefix.
  - AC 2: smoke — `KEEL_DEVBOX_SSH=false docker compose ${KEEL_DEVBOX_COMPOSE_FILES_ARGS} config | grep '2222'` returns NO matches.
  - AC 3: smoke — `KEEL_DEVBOX_SSH=true docker compose ${KEEL_DEVBOX_COMPOSE_FILES_ARGS} config | grep -E '127\.0\.0\.1:2222:2222'` returns ≥1 match.
  - AC 4 + AC 5: red-phase scaffold INFEASIBLE (live SSH connect requires real Docker daemon + SSH client + non-loopback peer for AC 4). Operator-workstation deferral (Story 2.5 iter-186 substrate-smoke posture). Trace-gate per-AC `defer:` candidate.
- **Trace-gate forecast: NON-WAIVED for ACs 1-3; partial-defer for ACs 4, 5.** Story 2.7 / 2.11 precedent for operator-workstation-only ACs.
- **CR forecast: 0-3 PATCH opener.** Novel surface (compose-override-file resolution, sshd entrypoint integration, host-key-bootstrap) is moderate. Precedents: Stories 2.1 (compose) + 2.5 (Dockerfile/entrypoint hardening) + 2.11 (resolver-function pattern) cover all implementation sites. Per iter-251/253 LESSON, adversarial CR catches what narrow-AC verification cannot; forecast 0-1 first-class PATCH + 2-4 second-class operator-edge DEFERs is band-aligned.
- **No harness infrastructure deferred to this story.** Resolver function + compose-config grep both testable via bash functional tests; entrypoint behaviour testable via `docker compose run --rm` smoke + `docker exec` probes (operator workstation).

### Success Criteria (SCs)

1. **Loopback-bound port publication is invariant.** Every `ports:` mapping (base compose + override + every future override) MUST use `127.0.0.1:<host>:<container>` form. Pinned in `INV-devbox-ssh § Loopback-bound port publication contract`. Future story edits adding ports MUST honour this — fork-level extension permitted, weakening forbidden.
2. **Opt-in sshd is fail-closed.** `KEEL_DEVBOX_SSH=true` is the EXACT signal; `True`, `TRUE`, `yes`, `1`, etc. all also accepted (case-fold normalisation); EVERY other value (`false`, `0`, empty, unset, `garbage`) defaults to NO sshd. No accidental opt-in via typo.
3. **Compose-override single-source.** `packages/devbox/docker-compose.ssh.yml` is the ONLY site that publishes port 2222. The base `packages/devbox/docker-compose.yml` MUST NOT have a 2222 entry in `ports:`. Lockstep enforced by code review + `INV-devbox-ssh § No-SSH default contract`.
4. **Resolver single-site discipline.** `resolve_ssh_state` is the ONLY site that decides SSH mode + composes the `-f` arg list. No shim re-computes mode independently; no inline `if [[ $KEEL_DEVBOX_SSH == true ]]` blocks outside the resolver and entrypoint.sh.
5. **Sshd runs as `dev` UID 1000.** No CAP_NET_BIND_SERVICE required for port 2222 (>1024). Sshd process visible in `ps -eo pid,user,cmd | grep sshd` as `dev sshd: /usr/sbin/sshd -D`. Honours Story 2.5 non-root posture.
6. **Pubkey-only authentication.** `PasswordAuthentication no` + `ChallengeResponseAuthentication no` + `KbdInteractiveAuthentication no` + `PubkeyAuthentication yes` in baked sshd_config. `PermitRootLogin no` + `AllowUsers dev` further constrain auth surface.
7. **Host keys persist via named volume.** Host keys at `/home/dev/.ssh/host_keys/ssh_host_ed25519_key` + `ssh_host_rsa_key` survive `pnpm devbox:stop && pnpm devbox:start` AND `pnpm devbox:rebuild` (image rebuild) because they live inside `keel_home_dev` named volume (Story 2.5 substrate).
8. **Authorized_keys flow operator-controlled.** Empty `authorized_keys` at first boot — no inbound SSH possible. Operator appends pubkeys from inside `pnpm devbox:shell`; pubkeys persist in named volume; survive restart + rebuild.
9. **No environment leakage.** `KEEL_DEVBOX_SSH` propagated via compose `environment:` (NOT `env_file:`-only). Without explicit `environment:` propagation, container sees empty env-var even though host's `.envrc` set it (compose's `${VAR}` interpolation runs on host at parse time).
10. **Entrypoint sshd is background.** `gosu dev /usr/sbin/sshd -D &` — backgrounded so PID 1 remains the `exec gosu dev "$@"` keepalive. PID 1 death tears down the container; sshd process death does NOT (Story 2.13 healthcheck adds detection).
11. **No new exit codes.** Story 2.6's uniform schema (0/2/3/8/9/10/11/12) + Story 2.10's additions + Story 2.11's no-additions apply unchanged. SSH start failure is logged to `/var/log/sshd.log` inside the container, not surfaced as a host-side exit code.
12. **Defence-in-depth via `ListenAddress 127.0.0.1`.** Even if Docker's `127.0.0.1:2222:2222` mapping is somehow circumvented (operator-edited compose; runtime `docker run --network host`; operator wraps with `socat`), sshd's own bind refuses non-loopback inbound.
13. **No PRD amendment.** PRD `:74` + `:551` + architecture `:550` + `:551` are unchanged. Story 2.12 is substrate-only.
14. **SC-17 close-out scope carry-forward.** Inherit from Stories 2.6/2.8/2.9/2.10/2.11: DO NOT modify prior stories' docs sections in README.md / AGENTS.md; append NEW sibling sections only. Rewriting prior sections is scope-creep for Epic 2 close-out polish (Story 2.17).

### Project Structure Notes

- **Alignment with unified project structure.** Story 2.12 lives entirely under `packages/devbox/` (Dockerfile + compose + sshd/ template + entrypoint + scripts/lib/) + `docs/invariants/devbox-ssh.md` + `INVARIANTS.md` + `packages/keel-invariants/src/invariants.manifest.ts` + `packages/devbox/README.md` + `AGENTS.md` + `packages/devbox/.envrc.example`. No cross-package leakage. Source tree follows architecture.md:975-999 (`packages/devbox/scripts` layout, `packages/keel-invariants/src/invariants.manifest.ts`).
- **No detected conflicts or variances.** The change set composes cleanly on Story 2.1 (compose / entrypoint surface) + Story 2.2 (KEEL_DEVBOX_SSH knob publication + four loopback-bound ports already established) + Story 2.3 (entrypoint egress-init pattern) + Story 2.5 (Dockerfile non-root + cap_drop + named volume) + Story 2.11 (resolver-function pattern + 18-shim wiring contract). The new `packages/devbox/sshd/` template directory mirrors the existing `packages/devbox/dnsmasq/` + `packages/devbox/nftables/` template-directory convention from Story 2.3.
- **`packages/devbox/sshd/` directory provenance.** NEW directory (Story 2.12 first occupant). Mirrors Story 2.3 pattern (`packages/devbox/dnsmasq/`, `packages/devbox/nftables/`) — config templates baked into the image at build time live under their own subdirectory. No README needed at 1.0; the file count is 1 (`sshd_config`) and the contract is documented in `docs/invariants/devbox-ssh.md`.

### References

- [Source: _bmad-output/planning-artifacts/prd.md#74] FR/Executive summary: "Host surface = `pnpm <subcommand>` only. Users never type `docker` / `docker-compose` / `ssh` directly. sshd is opt-in via `KEEL_DEVBOX_SSH=true` (pubkey-only, loopback-bound `127.0.0.1:2222`)."
- [Source: _bmad-output/planning-artifacts/prd.md#291] PRD `.envrc.example` snippet: `KEEL_DEVBOX_SSH=false` default.
- [Source: _bmad-output/planning-artifacts/architecture.md#550] Healthcheck contract: "Based on dnsmasq process liveness (and sshd liveness when `KEEL_DEVBOX_SSH=true`)" — Story 2.13 consumer; Story 2.12 prerequisite (sshd existence).
- [Source: _bmad-output/planning-artifacts/architecture.md#551] Ports: "3000 (dev FE), 3001 (dev BE), 6006 (Storybook), 24679 (Vite HMR), all bound to `127.0.0.1` (not `0.0.0.0`) for host-only exposure. SSH port 2222 only exposed when `KEEL_DEVBOX_SSH=true`. Port list parameterisable via `.envrc`."
- [Source: _bmad-output/planning-artifacts/architecture.md#1153] PRD-pinned `.envrc` parameterisation enumerates `KEEL_DEVBOX_SSH` + `KEEL_DEVBOX_SHARED` toggles.
- [Source: _bmad-output/planning-artifacts/architecture.md#1160] Architecture-pinned: "Ports bound to `127.0.0.1` (no `0.0.0.0`); opt-in sshd via `KEEL_DEVBOX_SSH=true` (pubkey-only, loopback-bound `127.0.0.1:2222`, host keys auto-generate on first boot)."
- [Source: _bmad-output/planning-artifacts/epics.md#1540-1572] Story 2.12 epic block: 5 acceptance criteria verbatim (loopback-bound ports + no-SSH default + opt-in sshd + external-refusal + authorized-keys flow).
- [Source: packages/devbox/.envrc.example#40] `KEEL_DEVBOX_SSH=false` default — Story 2.2 published the knob; Story 2.12 activates.
- [Source: packages/devbox/docker-compose.yml#22-24] Story-roadmap comment block — Task 4 inserts Story 2.12 LANDED line.
- [Source: packages/devbox/docker-compose.yml#135-136] `environment:` block — Task 4 extends with `KEEL_DEVBOX_SSH` propagation.
- [Source: packages/devbox/docker-compose.yml#150-157] Existing loopback-bound ports block (Story 2.2; AC 1 already satisfied).
- [Source: packages/devbox/docker-compose.yml#250] TODO marker for Story 2.12 — Task 4 removes.
- [Source: packages/devbox/Dockerfile#43-91] apt-get layer — Task 1 extends with `openssh-server`.
- [Source: packages/devbox/Dockerfile#65] Existing `openssh-client` package — Task 1 adds sibling `openssh-server`.
- [Source: packages/devbox/Dockerfile#252-253] `mkdir -p /workspace /home/dev/.claude /home/dev/.config/gh` — Task 1 extends with `/home/dev/.ssh/host_keys`.
- [Source: packages/devbox/entrypoint.sh#107-119] Named-volume directory bring-up loop — Task 3 inserts sshd-launch block AFTER this loop and AFTER the Story 2.3 egress-init block.
- [Source: packages/devbox/entrypoint.sh#125-130] Story 2.3 egress-init block — Task 3 inserts sshd block AFTER (sshd needs egress-policy active so that DNS resolution works during host-key-gen if any reverse-DNS happens).
- [Source: packages/devbox/scripts/lib/main-repo-resolver.sh#9-28] Header doc-block — Task 2 extends with `SSH state (Story 2.12)` paragraph.
- [Source: packages/devbox/scripts/lib/main-repo-resolver.sh#100-200] `resolve_main_repo_and_workdir` + `resolve_mode_specific_state` (Story 2.11) — Task 2 adds sibling `resolve_ssh_state` AFTER `resolve_mode_specific_state`.
- [Source: packages/keel-invariants/src/invariants.manifest.ts#3-15] InvariantSchema five-field shape — Task 5 compliance.
- [Source: packages/keel-invariants/src/sync-gate.ts#24] Anchor regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` — Task 5 INVARIANTS.md bullet compliance.
- [Source: docs/invariants/devbox-hardening.md (Story 2.5)] `INV-devbox-homedev-named-volume` authoritative doc; Story 2.12 doc cross-references for named-volume relationship (host keys + authorized_keys live INSIDE the volume).
- [Source: docs/invariants/devbox-mode.md (Story 2.11)] `INV-devbox-mode`; Story 2.12 SSH state is per-CONTAINER, not per-MODE; orthogonal composition documented in Story 2.12 invariant doc.
- [Source: docs/invariants/devbox-prereq-check.md (Story 2.10)] `INV-devbox-prereq-check`; Story 2.12 does NOT extend prereq-check — sshd is opt-in, never required.
- [Source: docs/invariants/fork.md § Amendment-vs-fork decision tree (Story 1.16)] Substrate default preservation; fork-level `INVARIANTS.fork.md` additive rules; Task 5 § Invariant stability.
- [Source: _bmad-output/implementation-artifacts/2-11-…md] Story 2.11 resolver-function pattern + 18-shim-wiring + 3-site-doc-lockstep — Story 2.12 reuses the resolver pattern (`resolve_ssh_state`) and the SC-17 sibling-append docs convention.
- [Source: _bmad-output/implementation-artifacts/2-5-…md] Story 2.5 Dockerfile + entrypoint hardening pattern — Story 2.12 entrypoint extension follows the chown-best-effort + cap_drop-aware posture.
- [Source: _bmad-output/implementation-artifacts/2-3-…md] Story 2.3 in-container template directory pattern (`packages/devbox/dnsmasq/`, `packages/devbox/nftables/`) — Story 2.12 mirrors with new `packages/devbox/sshd/`.

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List
