# Story 2.12: Loopback-bound port publication + opt-in `KEEL_DEVBOX_SSH` sshd

Status: ready-for-dev <!-- Ralph-internal `Story State` = `atdd-scaffolded` after iter-267 `/bmad-testarch-atdd` SKIP-WITH-GROUNDS-(c)+(ii)+(iii) per FR14n. 22nd-cumulative ATDD-skip precedent (Stories 1.7-1.16 = 10 Epic-1 skips; Stories 2.1-2.11 = 11 Epic-2 skips through iter-256; Story 2.12 iter-267 = 22). Grounds load-bearing: (c) AC class mixed — ACs 1-3 are bash-functional-testable (`docker compose config` port-form assertions + sshd_config static verification + entrypoint-smoke), ACs 4-5 operator-workstation-deferred (live host-LAN SSH peer + pubkey-auth flow infeasible in DinD backend B); (ii) no live test runner at 1.0 — `package.json` `test` script turbo-wired to zero implementing packages + no `playwright.config.*`/`cypress.config.*`/`vitest.config.*`/`conftest.py`/`bats` under repo; (iii) adversarial coverage substitutes exist — post-dev SM two-subagent verifier (iter-235 pattern) + three-layer CR adversarial fan-out (iter-260 convergence rule) + Story 1.9 sync-gate on new `docs/invariants/devbox-ssh.md` contentHash + Epic 13 harness downstream regression. Prior Ralph-internal transitions preserved: `drafted` iter-265; `validated` iter-266 (8 PATCH + 8 DEFER + 3 DISMISS). Sprint-status row stays `ready-for-dev` (ATDD gate does NOT flip sprint-status per iter-202 precedent). Next iter (iter-268) advances `atdd-scaffolded → in-dev` via `/bmad-dev-story` fresh-context; impl-time smokes per Story 2.11 iter-257 dev-agent pattern (resolver functional smokes + `docker compose config` port-form assertions + sshd_config static grep). No story-file Change Log entry per Story 2.5 iter-186 canonical ATDD-skip pattern — rationale lives in IP § DONE + RALPH.md Signposts + this HTML comment only. -->

<!-- Note: Validation is optional. Run `/bmad-create-story (args: "review")` for pre-dev quality check before `/bmad-testarch-atdd` / `/bmad-dev-story`. -->

## Story

As a substrate maintainer,
I want every published devbox port bound to `127.0.0.1` (no `0.0.0.0`) and an opt-in sshd (enabled via `KEEL_DEVBOX_SSH=true`) that is pubkey-only and loopback-bound at `127.0.0.1:2222`,
So that the devbox's attack surface is limited to the host loopback, never a LAN or internet-reachable interface.

## Acceptance Criteria

1. **Loopback-bound port publication — every `ports:` mapping uses `127.0.0.1:<host>:<container>` form.** Given `packages/devbox/docker-compose.yml`, when I inspect the `ports:` block, then every port mapping uses the explicit `127.0.0.1:<host>:<container>` form (no `0.0.0.0:...` form, no bare `<host>:<container>` form which Docker silently binds to `0.0.0.0`). Story 2.2 (landed iter-148) already established this posture for the four publish ports `KEEL_DEVBOX_PORT_WEB` / `..._API` / `..._STORYBOOK` / `..._VITE_HMR` at `docker-compose.yml:153-157`; Story 2.12 PINS the posture as an invariant so future story edits cannot regress it. The new sshd port mapping (when added by AC 3) MUST also use the loopback-bound form.

2. **Default — `KEEL_DEVBOX_SSH=false` — sshd does NOT run AND port 2222 is NOT published.** Given `KEEL_DEVBOX_SSH=false` (the `.envrc.example:40` default; iterating per Story 2.2 SC the unset case also defaults to `false`), when the container starts (`pnpm devbox:start`), then no `sshd` process is running inside the container (`pgrep sshd` inside the container returns no PIDs / exit 1) AND `docker port keel-devbox` lists no `2222/tcp` mapping AND `docker compose -f packages/devbox/docker-compose.yml config` emits NO `127.0.0.1:2222:2222` line (compose stack matches the no-SSH posture at the YAML layer, not just the runtime layer). The four Story 2.2 publish ports remain published unaffected.

3. **Opt-in — `KEEL_DEVBOX_SSH=true` — sshd runs, pubkey-only, port 2222 loopback-bound via published-port confinement, host keys persisted in named volume.** Given `KEEL_DEVBOX_SSH=true` in `.envrc`, when the container starts, then sshd runs inside the container listening on port 2222 (container-side `ListenAddress` intentionally unset — inbound packets arrive on container eth0, not container-loopback, under both `userland-proxy=true` and `userland-proxy=false` Docker modes; loopback confinement is enforced by the `127.0.0.1:2222:2222` publish in `docker-compose.ssh.yml`, NOT by sshd config) AND password auth is disabled (`PasswordAuthentication no`, `ChallengeResponseAuthentication no`, `KbdInteractiveAuthentication no`) AND only pubkey auth is allowed (`PubkeyAuthentication yes`) AND root login is disabled (`PermitRootLogin no`) AND host keys auto-generate on first boot via explicit `ssh-keygen -t ed25519 -f /home/dev/.ssh/host_keys/ssh_host_ed25519_key -N ""` + `ssh-keygen -t rsa -b 4096 -f /home/dev/.ssh/host_keys/ssh_host_rsa_key -N ""` (entrypoint logic — the keys persist in the `keel_home_dev` named volume per Story 2.5 so subsequent restarts re-use the same keys; first-boot generation is a one-time event gated on key absence). `docker port keel-devbox` lists `2222/tcp -> 127.0.0.1:2222` AND `docker compose … config` emits the loopback-bound `127.0.0.1:${KEEL_DEVBOX_SSH_PORT:-2222}:2222` line.

4. **External (non-loopback) connection refusal.** Given sshd is enabled (`KEEL_DEVBOX_SSH=true`), when an external (non-loopback) client attempts to connect (e.g., `ssh -p 2222 dev@<host-LAN-IP>` from a peer machine on the host's LAN), then the connection is refused at the Docker published-port layer (the `127.0.0.1:2222:2222` mapping binds the host socket exclusively to the `127.0.0.1` host-loopback interface — under `userland-proxy=true` mode, `docker-proxy` only listens on `127.0.0.1:2222`; under `userland-proxy=false` mode, Docker's iptables `DOCKER` chain DNAT rules are scoped to the loopback destination. Both modes refuse LAN-sourced traffic) AND only `ssh -p 2222 dev@127.0.0.1` from the host (the Docker-daemon host) succeeds with a registered pubkey. AC verification is operator-workstation only — DinD backend B (the iteration env) cannot exercise non-loopback LAN clients meaningfully; substrate verification per Story 2.5 iter-186 posture (config-shape correctness via `docker compose config` + invariant doc claim). NOTE: Defence-in-depth via container-side sshd `ListenAddress 127.0.0.1` is intentionally NOT used — see AC 3 + sshd_config header comment — because container-loopback is disjoint from host-loopback and would silently reject all inbound traffic under either Docker userland-proxy mode. Single-layer host-side publish confinement is correct and sufficient.

5. **Operator authorized-keys flow — pubkey written to `/home/dev/.ssh/authorized_keys` inside named volume; persists across restarts.** Given a fork operator wants to add their pubkey, when they follow the documented flow in `packages/devbox/README.md § Opt-in SSH (Story 2.12)`, then the pubkey is appended to `/home/dev/.ssh/authorized_keys` inside the `keel_home_dev` named volume (Story 2.5 substrate; persists across container restarts + image rebuilds; tokens never bind-mounted to host per NFR10) AND a subsequent `ssh -p 2222 dev@127.0.0.1 -i <matching-private-key>` succeeds AND the pubkey survives `pnpm devbox:stop && pnpm devbox:start` AND survives `pnpm devbox:rebuild` (image rebuild) because the named volume is preserved across both operations (Story 2.6 AC 4 + Story 2.11 AC 1 contracts).

## Tasks / Subtasks

- [ ] **Task 1: Add `openssh-server` to the Dockerfile apt layer + bake `sshd_config` template** (AC 3, AC 4)
  - [ ] Edit `packages/devbox/Dockerfile:43-91` (apt-get layer): add `openssh-server` package alongside the existing `openssh-client` (line 65). Renovate `apt` manager (Story 1.15) tracks the package version.
  - [ ] Bake a hardened `sshd_config` template at image-build time. Source: `packages/devbox/sshd/sshd_config` (NEW file under `packages/devbox/sshd/` directory, mirroring the Story 2.3 `packages/devbox/dnsmasq/` + `packages/devbox/nftables/` template-directory convention). Copy via Dockerfile `COPY packages/devbox/sshd/sshd_config /etc/ssh/sshd_config` (path relative to compose build context — `packages/devbox/Dockerfile`'s context is `packages/devbox/` per `docker-compose.yml:69-71` `build.context: .`). Set permissions: `chmod 0644 /etc/ssh/sshd_config && chown root:root /etc/ssh/sshd_config`.
  - [ ] `sshd_config` content (verbatim — copy into `packages/devbox/sshd/sshd_config`; NOT contentHash-tracked since not a `sourcePath` of any `INV-*` entry):
    ```
    # packages/devbox/sshd/sshd_config — Story 2.12
    # Hardened sshd config; pubkey-only, root-disabled.
    #
    # Loopback binding at container-side is NOT specified here — the
    # container's network namespace receives incoming published-port
    # traffic on its eth0 interface (via Docker's iptables-NAT rules
    # under default `userland-proxy=false` mode, or via docker-proxy's
    # re-originated connection under `userland-proxy=true`). In BOTH
    # modes, packets arrive on eth0, NOT on the container's 127.0.0.1.
    # Binding sshd to `ListenAddress 127.0.0.1` would silently drop
    # all inbound connections. Leave `ListenAddress` at sshd's default
    # (any address in container netns); host-side loopback confinement
    # is enforced by the `127.0.0.1:2222:2222` publish in
    # docker-compose.ssh.yml (AC 4). The container netns is already an
    # isolated attack surface — external peers cannot reach eth0
    # without traversing the published-port gate on the host.
    Port 2222
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
  - [ ] **No `setcap` invocation.** Port 2222 > 1024; `NET_BIND_SERVICE` is NOT required for the bind. Sshd runs as `dev` (UID 1000) with no extra capability needed. Verify at impl time: `ss -tlnp` (or `ss -tlpn` if `-p` requires root) inside the container confirms `0.0.0.0:2222` is bound by `sshd` running as `dev`. Do NOT add a `setcap +ep /usr/sbin/sshd` line to the Dockerfile — it would violate Story 2.5's `no-new-privileges=1` posture expectations and is unnecessary.

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
  - [ ] **Compose-CLI inclusion path.** When `KEEL_DEVBOX_SSH=true`, host-side shims that invoke `docker compose -f "${COMPOSE_FILE}"` MUST extend the invocation with a second `-f "${COMPOSE_FILE_SSH}"` after the base file. Compose v2 multi-file merge spec: `services.<svc>.ports` is a sequence-typed key that CONCATENATES across `-f` files (ref: compose-spec.io § Merge/override — `ports`, `expose`, `external_links`, `dns`, `dns_search`, `tmpfs`, `volumes` are additive sequences). Base file's 4 Story-2.2 ports + override's 1 SSH port = 5 total; no duplicate-2222 risk because the base file does NOT publish 2222.
  - [ ] **Resolver extension.** Add a NEW function `resolve_ssh_state()` to `packages/devbox/scripts/lib/main-repo-resolver.sh` (sibling to `resolve_main_repo_and_workdir` + `resolve_mode_specific_state`). Function reads `KEEL_DEVBOX_SSH` from the process env, normalises (lowercase via `tr '[:upper:]' '[:lower:]'` + accept-`true`-only — fail-closed to no-SSH for any other value including `yes`/`1`/`on`), mirroring the Story 2.11 `KEEL_DEVBOX_SHARED` normalisation idiom at `lib/main-repo-resolver.sh:152` (the `tr` line; the `resolve_mode_specific_state()` function opener is at `:146`). Exports:
    - `KEEL_DEVBOX_SSH_RESOLVED=true|false` (canonical normalised value).
    - `KEEL_DEVBOX_COMPOSE_FILE_SSH` — EITHER the empty string (no-SSH) OR the absolute path `"${DEVBOX_DIR}/docker-compose.ssh.yml"` (opt-in SSH). The shim pattern then becomes `docker compose -f "${COMPOSE_FILE}" ${KEEL_DEVBOX_COMPOSE_FILE_SSH:+-f "${KEEL_DEVBOX_COMPOSE_FILE_SSH}"}` — the `${VAR:+-f "${VAR}"}` parameter-expansion form expands to `-f <path>` when non-empty and to the empty string when empty, avoiding the word-splitting hazard of passing a joined `-f <a> -f <b>` string through unquoted expansion (RALPH.md 2026-04-21 AR-9 bash-iterable-word-splitting LESSON). Shared mode (Story 2.11) does NOT change this — the override composes regardless of mode (sshd is per-container, not per-mode).
  - [ ] Caller invocation order: `resolve_main_repo_and_workdir` → `resolve_mode_specific_state` → `resolve_ssh_state` → exports → downstream `docker compose` invocations.
  - [ ] **Update the 8 actual compose-invoking shims** to thread `${KEEL_DEVBOX_COMPOSE_FILE_SSH:+-f "${KEEL_DEVBOX_COMPOSE_FILE_SSH}"}` through every `docker compose -f "${COMPOSE_FILE}"` call site. Verified inventory (via `grep -c '^[^#]*docker compose -f' packages/devbox/scripts/*.sh` at iter-266): `build.sh` (1 site), `rebuild.sh` (1), `start.sh` (1), `stop.sh` (1), `status.sh` (1), `clean.sh` (2 sites — preserve + destructive paths), `logs.sh` (2 sites — follow-mode + passthrough-mode), `benchmark.sh` (6 sites — NFR2 cold/warm instrumentation, all paths MUST pick up the override so sshd-enabled benchmarks measure the enabled posture). Scripts WITHOUT compose invocations and therefore NOT in scope for substitution: `restart.sh` (delegates to stop.sh + start.sh), `env-check.sh` (parses `.envrc` only; no compose call), `monitor-host.sh` (`docker exec` shim, not compose), `attach.sh` / `shell.sh` / `claude-host.sh` / `gh-auth-host.sh` / `ralph-build-host.sh` / `ralph-plan-host.sh` / `whitelist-host.sh` (docker-exec shims). Story 2.7's 2 ralph wrappers + Story 2.8/2.9 auth shims + Story 2.6 shell/attach do NOT compose-invoke and therefore inherit sshd state via the already-running container's environment (set at `docker compose up` time via Task 4 env propagation).
  - [ ] Header comment block update: the existing `lib/main-repo-resolver.sh:1-28` doc-block covers only the original three WORKTREE_ROOT / REPO_NAME / CONTAINER_WORKDIR resolver outputs; Story 2.11 extended the file via a SECOND doc paragraph at `:35-77` describing `resolve_mode_specific_state()`. Task 2 adds a THIRD doc paragraph AFTER the Story 2.11 paragraph (i.e., inserted at approximately `:78` — adjust line for current file) describing `resolve_ssh_state()`: the two outputs (`KEEL_DEVBOX_SSH_RESOLVED`, `KEEL_DEVBOX_COMPOSE_FILE_SSH`), the `true`-only normalisation, and the caller invocation order contract. Do NOT edit the original `:1-28` or the Story 2.11 `:35-77` paragraphs.

- [ ] **Task 3: First-boot host-key generation + conditional sshd start in `entrypoint.sh`** (AC 3, AC 5)
  - [ ] **Insertion point.** Edit `packages/devbox/entrypoint.sh` — add a NEW block AFTER the existing Story 2.3 egress-init block (`entrypoint.sh:121-130` — the `start-egress.sh` dispatch wrapped in an `if [[ ... ]]` conditional) and BEFORE the CMD-empty fallback + `exec gosu dev "$@"` handoff at `entrypoint.sh:155-159` (`:154` is the `if [ "$#" -eq 0 ]; then` opener; `:155` and `:157` are the two exec handoffs). The new block MUST land BEFORE the if/else block, not inside it.
  - [ ] **Entrypoint block contract** (copy-paste-ready; NO placeholders):
    ```bash
    # Story 2.12: opt-in sshd. KEEL_DEVBOX_SSH is normalised on the host by
    # resolve_ssh_state() before container start; here we honour the
    # container-side env var (propagated via docker-compose.yml § environment
    # by Task 4). Case-sensitive "true" match mirrors Story 2.11 shared-mode
    # entrypoint posture — normalisation already done host-side.
    if [[ "${KEEL_DEVBOX_SSH:-false}" == "true" ]]; then
      # Pre-creation runs as root (pre-gosu). Use gosu to create the tree
      # with dev:dev ownership from t=0 so the subsequent keygen + sshd both
      # run as dev without relying on CAP_CHOWN (Story 2.5 hardening).
      gosu dev mkdir -p /home/dev/.ssh/host_keys
      # Idempotent perm enforcement EVERY boot (not gated on existence).
      # The named volume may have been inspected from host OR pre-populated
      # with stray perms on upgrade; sshd's StrictModes (default yes) rejects
      # any parent dir more permissive than 0700, silently. Enforce.
      chmod 0700 /home/dev/.ssh /home/dev/.ssh/host_keys
      # Atomic host-key generation: a mid-keygen container kill leaves a
      # partial keypair which sshd refuses. Generate BOTH keys into a
      # scratch dir then atomically mv into place. Guard on BOTH algorithms'
      # final filenames — if either is missing, regenerate both.
      if [[ ! -f /home/dev/.ssh/host_keys/ssh_host_ed25519_key ]] \
         || [[ ! -f /home/dev/.ssh/host_keys/ssh_host_rsa_key ]]; then
        gosu dev rm -rf /home/dev/.ssh/host_keys.tmp
        gosu dev mkdir -p /home/dev/.ssh/host_keys.tmp
        gosu dev ssh-keygen -q -t ed25519 -f /home/dev/.ssh/host_keys.tmp/ssh_host_ed25519_key -N "" < /dev/null
        gosu dev ssh-keygen -q -t rsa -b 4096 -f /home/dev/.ssh/host_keys.tmp/ssh_host_rsa_key -N "" < /dev/null
        gosu dev mv -T /home/dev/.ssh/host_keys.tmp /home/dev/.ssh/host_keys
      fi
      # Touch authorized_keys with 0600 every boot (idempotent). Empty file
      # = no inbound auth; operator appends pubkeys via Task 6 flow (AC 5).
      [[ -f /home/dev/.ssh/authorized_keys ]] || gosu dev touch /home/dev/.ssh/authorized_keys
      chmod 0600 /home/dev/.ssh/authorized_keys
      # Launch sshd as dev (port 2222 > 1024; NET_BIND_SERVICE not needed).
      # -D = foreground; backgrounded with `&` because PID 1 is the `exec
      # gosu dev "$@"` handoff below. Liveness verified post-spawn so a
      # silent sshd startup failure does NOT leave the entrypoint proceeding
      # with an un-started sshd + operator seeing port 2222 published +
      # connections refusing (§ Dev Notes § Liveness verification contract).
      gosu dev /usr/sbin/sshd -D -e 2>>/var/log/sshd.log &
      SSHD_PID="$!"
      sleep 0.5
      if ! kill -0 "${SSHD_PID}" 2>/dev/null; then
        echo "entrypoint: sshd failed to start; tail /var/log/sshd.log:" >&2
        tail -n 20 /var/log/sshd.log >&2 || true
        echo "entrypoint: sshd startup failure is NON-FATAL under Story 2.12 SC-10 (background process; PID 1 remains the exec handoff). Operator: pnpm devbox:logs keel-devbox + investigate." >&2
      fi
    fi
    ```
  - [ ] **`set -e` + background-spawn interaction.** The `gosu dev /usr/sbin/sshd -D … &` returns exit 0 from the FORK regardless of whether sshd successfully bound the port (bash's `&` operator itself never fails). Under `set -e` this means a crashing sshd would NOT trip the entrypoint — the container would proceed cleanly with port 2222 published (by Docker) but no listener inside. The `kill -0 ${SSHD_PID}` check 0.5s later catches the common failure modes (config syntax error, host-key unreadable, port already in use by stray process); non-fatal reporting preserves SC-10 (background process lifecycle = operator's responsibility) while surfacing the failure in container logs. Story 2.13 healthcheck is the authoritative long-term signal.
  - [ ] **Ownership under `cap_drop: [ALL]`.** Running `mkdir -p` + key generation as `gosu dev` ensures the directory tree + key files are created with `dev:dev` ownership from t=0. The entrypoint's `chmod` calls do NOT need CAP_CHOWN (chmod only needs process ownership, which dev has). The separate `chown` calls from the pre-Story-2.12 named-volume-dir block (`entrypoint.sh:111-117`) retain their existing `2>/dev/null || true` best-effort posture — Story 2.12 adds no new root-`chown` calls.
  - [ ] **Forbidden runtime install.** `sshd_config` is BAKED at image-build time (Task 1); entrypoint MUST NOT modify it at runtime. `ssh-keygen` is a binary from `openssh-server` — no apt invocation, no curl-pipe-sh, conforms to entrypoint.sh's forbidden-runtime-install posture (Story 2.1 AC 2; entrypoint header comment block lines 17-19).

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
    - `## Opt-in sshd contract` — sshd runs as UID 1000 (`dev`); `Port 2222`; `PermitRootLogin no`; `PasswordAuthentication no`; `ChallengeResponseAuthentication no`; `KbdInteractiveAuthentication no`; `PubkeyAuthentication yes`; `AllowUsers dev`; `UsePAM no`; host keys at `/home/dev/.ssh/host_keys/ssh_host_{ed25519,rsa}_key`; `authorized_keys` at `/home/dev/.ssh/authorized_keys`; first-boot atomic key generation via explicit `-t ed25519` + `-t rsa -b 4096`; persistence via `keel_home_dev` named volume. Container-side `ListenAddress` INTENTIONALLY unset (see § External connection refusal for rationale).
    - `## No-SSH default contract` — `KEEL_DEVBOX_SSH=false` (or unset): sshd is NOT started AND port 2222 is NOT published AND `docker compose config` emits no 2222 mapping. Compose override file `packages/devbox/docker-compose.ssh.yml` is the SINGLE site that publishes 2222; the base `docker-compose.yml` MUST NOT publish 2222.
    - `## Resolver contract` — `packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_ssh_state()` is the single resolution site; every host-side compose-invoking shim invokes it after `resolve_mode_specific_state`; exports `KEEL_DEVBOX_SSH_RESOLVED` + `KEEL_DEVBOX_COMPOSE_FILES_ARGS`.
    - `## External (non-loopback) connection refusal` — Docker's `127.0.0.1:2222:2222` mapping is the SINGLE loopback-confinement layer. Under `userland-proxy=true` (default), `docker-proxy` binds host-side `127.0.0.1:2222` only; under `userland-proxy=false`, iptables DNAT targets are scoped to the host's loopback destination. In BOTH modes, LAN-sourced traffic is refused. Container-side sshd `ListenAddress` is NOT used — container-loopback is disjoint from host-loopback and would silently drop traffic that arrives on container eth0. Operator-workstation verification only; substrate verifies via `docker compose config` shape + AC 4 invariant doc claim.
    - `## Operator authorized-keys flow` — pubkey appended to `/home/dev/.ssh/authorized_keys` from inside the container (`pnpm devbox:shell` then `echo 'ssh-ed25519 AAAA…' >> ~/.ssh/authorized_keys`); persistence guaranteed by the named volume across restarts + image rebuilds; agents MUST NOT bind-mount or copy `authorized_keys` outside the named volume (NFR10 — same posture as Story 2.8/2.9 OAuth tokens).
    - `## Named volume relationship to INV-devbox-homedev-named-volume` — Story 2.5's `INV-devbox-homedev-named-volume` pins the unqualified name `keel_home_dev`; Story 2.12's host keys + authorized_keys live INSIDE that volume; Story 2.12 does NOT touch the volume's name or substrate posture.
    - `## Invariant stability` — loopback-bound port publication is a SUBSTRATE INVARIANT — forks MAY NOT publish to `0.0.0.0` or use bare-port form. Opt-in sshd is OPERATOR-DEFAULT-OFF — forks MAY NOT change the default to `true`. Fork-level growth-tier `INVARIANTS.fork.md` rules MAY add fork-specific sshd_config overlays (e.g., MFA via `AuthenticationMethods publickey,keyboard-interactive`) but MAY NOT weaken substrate defaults (no PasswordAuthentication; no PermitRootLogin).
  - [ ] Compute `contentHash`: `sha256sum docs/invariants/devbox-ssh.md | awk '{print $1}'`. Paste 64-char lowercase hex into the manifest entry. `pnpm keel-invariants:check` MUST pass after manifest + doc both land (Story 1.9 sync-gate verification).
  - [ ] Append entry to `INVARIANTS.md` under the devbox section after `INV-devbox-mode` (Story 2.11 anchor) as: ``- **`INV-devbox-ssh`** — Opt-in sshd + loopback-bound port publication contract (`KEEL_DEVBOX_SSH=true` opens 127.0.0.1:2222 pubkey-only; ALL ports must use 127.0.0.1:<host>:<container> form). Source: `docs/invariants/devbox-ssh.md`.`` Index-only, no body (FR42).
  - [ ] Anchor bullet MUST match the verbatim regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` per `packages/keel-invariants/src/sync-gate.ts:24` (Story 1.9 sync-gate). Lowercase-after-`INV-` prefix MANDATORY (Story 1.9 iter-7 LESSON).
  - [ ] Add new `### Devbox SSH (Story 2.12)` H3 in `INVARIANTS.md` AFTER the `### Devbox mode (Story 2.11)` H3 body + its `INV-devbox-mode` anchor bullet, and BEFORE the `### Gitignored-secret commit-deny (Story 2.2)` H3 (verified at `INVARIANTS.md:120` at iter-266 — the devbox H3 sequence is NOT strictly numerical; Story 2.2's gitignored-secret H3 lives AFTER all Story 2.1/2.3/2.5/2.10/2.11 devbox H3s). One-line H3 body (mirroring Story 2.11's one-line body), then the anchor bullet underneath.

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
- **`set -euo pipefail` discipline + resolver function shape.** Mirror Story 2.11 `resolve_mode_specific_state()` pattern: pure string manipulation (no command rc-dependence), default-substitution `${KEEL_DEVBOX_SSH:-false}` to survive `set -u`. Case-fold normalisation via `tr '[:upper:]' '[:lower:]'` (mirrors `lib/main-repo-resolver.sh:152` — the actual `tr` line inside `resolve_mode_specific_state()`; the function opener is at `:146` and the `if [[ "$shared" != "true" ]]` gate is at `:154`).
- **Entrypoint forbidden-runtime-install posture.** Story 2.1 AC 2 + entrypoint header lines 17-19 forbid `apt-get` / `npm install` / `pip install` / `curl…|sh` at runtime. Task 3's entrypoint extension only invokes `ssh-keygen` (binary baked at image-build time via `openssh-server` apt package) and `gosu dev /usr/sbin/sshd -D`; neither violates the posture.
- **`INV-devbox-homedev-named-volume` interaction.** Host keys + authorized_keys live INSIDE `keel_home_dev` (Story 2.5 substrate). Story 2.12 does NOT change the named-volume contract; it only adds new file-tree paths under `/home/dev/.ssh/`. Persistence semantics inherited unchanged.
- **`INV-devbox-mode` interaction (Story 2.11).** SSH state is per-CONTAINER, not per-MODE. Both per-fork mode (`keel-devbox` container) and shared mode (`keel-devbox-shared` container) honour `KEEL_DEVBOX_SSH` independently. The compose-files-args resolver output is the same in both modes; the per-mode container-name resolution composes orthogonally.
- **Defence-in-depth posture for AC 4.** Two layers refuse non-loopback connections: (1) Docker's iptables-NAT layer (`127.0.0.1:2222:2222` mapping); (2) sshd's own `ListenAddress 127.0.0.1` directive. If the operator's host firewall fails / Docker daemon misconfigures, sshd still refuses non-loopback inbound. If sshd_config is corrupted, Docker still refuses. Both layers must misbehave for an external IP to reach the dev shell.
- **No PRD amendment required.** PRD `:544` (Attach UX) + `:550` (Healthcheck) + `:551` (Ports) and architecture.md `:74` (Executive summary) + `:285-292` (.envrc block) + `:291` (KEEL_DEVBOX_SSH=false default) are the verbatim sources for the AC 1-5 contract. All sources are unchanged; Story 2.12 lands the substrate without amending planning artefacts.
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
2. **Opt-in sshd is fail-closed.** `KEEL_DEVBOX_SSH=true` is the opt-in signal; case-fold normalisation accepts `true`, `True`, `TRUE`, `TrUe` (i.e., any-case spelling of the literal `true`). EVERY other value — `false`, `yes`, `on`, `1`, empty, unset, `garbage` — defaults to NO sshd. Strict-true-only posture mirrors Story 2.11 `KEEL_DEVBOX_SHARED` normalisation idiom at `lib/main-repo-resolver.sh:152`; forks MAY NOT extend the accepted-signal set.
3. **Compose-override single-source.** `packages/devbox/docker-compose.ssh.yml` is the ONLY site that publishes port 2222. The base `packages/devbox/docker-compose.yml` MUST NOT have a 2222 entry in `ports:`. Lockstep enforced by code review + `INV-devbox-ssh § No-SSH default contract`.
4. **Resolver single-site discipline.** `resolve_ssh_state` is the ONLY site that decides SSH mode + composes the `-f` arg list. No shim re-computes mode independently; no inline `if [[ $KEEL_DEVBOX_SSH == true ]]` blocks outside the resolver and entrypoint.sh.
5. **Sshd runs as `dev` UID 1000.** No CAP_NET_BIND_SERVICE required for port 2222 (>1024). Sshd process visible in `ps -eo pid,user,cmd | grep sshd` as `dev sshd: /usr/sbin/sshd -D`. Honours Story 2.5 non-root posture.
6. **Pubkey-only authentication.** `PasswordAuthentication no` + `ChallengeResponseAuthentication no` + `KbdInteractiveAuthentication no` + `PubkeyAuthentication yes` in baked sshd_config. `PermitRootLogin no` + `AllowUsers dev` further constrain auth surface.
7. **Host keys persist via named volume.** Host keys at `/home/dev/.ssh/host_keys/ssh_host_ed25519_key` + `ssh_host_rsa_key` survive `pnpm devbox:stop && pnpm devbox:start` AND `pnpm devbox:rebuild` (image rebuild) because they live inside `keel_home_dev` named volume (Story 2.5 substrate).
8. **Authorized_keys flow operator-controlled.** Empty `authorized_keys` at first boot — no inbound SSH possible. Operator appends pubkeys from inside `pnpm devbox:shell`; pubkeys persist in named volume; survive restart + rebuild.
9. **No environment leakage.** `KEEL_DEVBOX_SSH` propagated via compose `environment:` (NOT `env_file:`-only). Without explicit `environment:` propagation, container sees empty env-var even though host's `.envrc` set it (compose's `${VAR}` interpolation runs on host at parse time).
10. **Entrypoint sshd is background.** `gosu dev /usr/sbin/sshd -D &` — backgrounded so PID 1 remains the `exec gosu dev "$@"` keepalive. PID 1 death tears down the container; sshd process death does NOT (Story 2.13 healthcheck adds detection).
11. **No new exit codes.** Story 2.6's uniform schema (0/2/3/8/9/10/11/12) + Story 2.10's additions + Story 2.11's no-additions apply unchanged. SSH start failure is logged to `/var/log/sshd.log` inside the container, not surfaced as a host-side exit code.
12. **Single-layer published-port confinement.** Loopback confinement is enforced by Docker's `127.0.0.1:2222:2222` publish in `docker-compose.ssh.yml` (host-side). Container-side sshd `ListenAddress 127.0.0.1` is INTENTIONALLY NOT set — container-loopback is disjoint from host-loopback, and binding there would silently drop all inbound traffic under both Docker `userland-proxy` modes. The container network namespace is an isolated attack surface; external peers cannot reach container eth0 without traversing the host-side `127.0.0.1:2222` publish. If the operator circumvents the publish (runtime `docker run --network host`; socat wrap; operator-edited compose), the attack surface widens to the operator's trust posture — this is an operator escape hatch, not a Story-2.12 regression.
13. **No PRD amendment.** PRD `:74` + `:551` + architecture `:550` + `:551` are unchanged. Story 2.12 is substrate-only.
14. **SC-17 close-out scope carry-forward.** Inherit from Stories 2.6/2.8/2.9/2.10/2.11: DO NOT modify prior stories' docs sections in README.md / AGENTS.md; append NEW sibling sections only. Rewriting prior sections is scope-creep for Epic 2 close-out polish (Story 2.17).

### Project Structure Notes

- **Alignment with unified project structure.** Story 2.12 lives entirely under `packages/devbox/` (Dockerfile + compose + sshd/ template + entrypoint + scripts/lib/) + `docs/invariants/devbox-ssh.md` + `INVARIANTS.md` + `packages/keel-invariants/src/invariants.manifest.ts` + `packages/devbox/README.md` + `AGENTS.md` + `packages/devbox/.envrc.example`. No cross-package leakage. Source tree follows architecture.md:975-999 (`packages/devbox/scripts` layout, `packages/keel-invariants/src/invariants.manifest.ts`).
- **No detected conflicts or variances.** The change set composes cleanly on Story 2.1 (compose / entrypoint surface) + Story 2.2 (KEEL_DEVBOX_SSH knob publication + four loopback-bound ports already established) + Story 2.3 (entrypoint egress-init pattern) + Story 2.5 (Dockerfile non-root + cap_drop + named volume) + Story 2.11 (resolver-function pattern + 18-shim wiring contract). The new `packages/devbox/sshd/` template directory mirrors the existing `packages/devbox/dnsmasq/` + `packages/devbox/nftables/` template-directory convention from Story 2.3.
- **`packages/devbox/sshd/` directory provenance.** NEW directory (Story 2.12 first occupant). Mirrors Story 2.3 pattern (`packages/devbox/dnsmasq/`, `packages/devbox/nftables/`) — config templates baked into the image at build time live under their own subdirectory. No README needed at 1.0; the file count is 1 (`sshd_config`) and the contract is documented in `docs/invariants/devbox-ssh.md`.

### References

- [Source: _bmad-output/planning-artifacts/architecture.md#74] Executive summary: "Host surface = `pnpm <subcommand>` only. Users never type `docker` / `docker-compose` / `ssh` directly. sshd is opt-in via `KEEL_DEVBOX_SSH=true` (pubkey-only, loopback-bound `127.0.0.1:2222`)."
- [Source: _bmad-output/planning-artifacts/architecture.md#291] `.envrc.example` snippet inside architecture.md § Devbox Implementation Contract: `KEEL_DEVBOX_SSH=false` default.
- [Source: _bmad-output/planning-artifacts/architecture.md#285-292] `.envrc` parameterisation block enumerating `KEEL_DEVBOX_SSH` + `KEEL_DEVBOX_SHARED` toggles verbatim.
- [Source: _bmad-output/planning-artifacts/prd.md#104] PRD Executive Summary — "users never invoke Docker, docker-compose, or SSH directly (sshd is an opt-in escape hatch via `KEEL_DEVBOX_SSH=true`, off by default)."
- [Source: _bmad-output/planning-artifacts/prd.md#544] PRD § Devbox Implementation Contract — Attach UX: "Opt-in sshd is enabled via `KEEL_DEVBOX_SSH=true` in `.envrc`; when enabled, sshd is pubkey-only (no password auth), host keys auto-generate on first boot, and the port is bound to loopback (`127.0.0.1:2222`)."
- [Source: _bmad-output/planning-artifacts/prd.md#550] Healthcheck contract: "Based on dnsmasq process liveness (and sshd liveness when `KEEL_DEVBOX_SSH=true`)" — Story 2.13 consumer; Story 2.12 prerequisite (sshd existence).
- [Source: _bmad-output/planning-artifacts/prd.md#551] Ports: "3000 (dev FE), 3001 (dev BE), 6006 (Storybook), 24679 (Vite HMR), all bound to `127.0.0.1` (not `0.0.0.0`) for host-only exposure. SSH port 2222 only exposed when `KEEL_DEVBOX_SSH=true`. Port list parameterisable via `.envrc`."
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
- [Source: packages/devbox/entrypoint.sh#121-130] Story 2.3 egress-init block (comment at :121; conditional dispatch at :125-130) — Task 3 inserts sshd block AFTER this block so egress policy is active during host-key-gen (any reverse-DNS or remote lookup sshd-keygen performs resolves through dnsmasq's whitelist).
- [Source: packages/devbox/entrypoint.sh#154-159] CMD-empty fallback + exec handoff (`:154` = `if [ "$#" -eq 0 ]; then`; `:155` + `:157` = the two `exec gosu dev ...` statements) — Task 3 block inserted BEFORE this if/else, not inside it.
- [Source: packages/devbox/scripts/lib/main-repo-resolver.sh#1-28] Original header doc-block (WORKTREE_ROOT / REPO_NAME / CONTAINER_WORKDIR) — DO NOT edit; Story 2.11 already extended via a SECOND doc paragraph.
- [Source: packages/devbox/scripts/lib/main-repo-resolver.sh#35-77] Story 2.11 Mode-specific-state doc paragraph — DO NOT edit; Task 2 appends a THIRD paragraph describing `resolve_ssh_state()` AFTER this one.
- [Source: packages/devbox/scripts/lib/main-repo-resolver.sh#146-203] `resolve_mode_specific_state()` function (opener at `:146`; `tr` case-fold at `:152`; gate at `:154`) — Task 2 adds sibling `resolve_ssh_state()` AFTER this function.
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

## Change Log

### v1.1 — iter-266 pre-dev SM gate (`drafted → validated`)

Four parallel Sonnet subagents re-analysed story against sources. Ralph triage produced 8 PATCH + 8 DEFER + 3 DISMISS across critical + second-class findings.

**PATCH-1 (§ References).** Swapped `prd.md ↔ architecture.md` file-paths for 6 citations. Verified at iter-266: `architecture.md:74` holds "Host surface…sshd opt-in"; `architecture.md:291` holds `KEEL_DEVBOX_SSH=false` snippet; `prd.md:550` holds Healthcheck contract; `prd.md:551` holds Ports contract. Replaced architecture.md:1153 / :1160 citations (stale lines pointing at app-tree content) with architecture.md:285-292 (.envrc parameterisation block) + prd.md:104 (Executive Summary) + prd.md:544 (Attach UX). Removed the redundant stale "PRD line 551 … architecture.md :551 verbatim matches" Dev Note — replaced with a clean enumeration of the 6 authoritative source sites.

**PATCH-2 (Task 2 shim inventory).** Corrected 3-way wrong claim: original spec said "9 shims" hardcoded-path-based via a grep that returns 0 hits (scripts use `"${COMPOSE_FILE}"` var pattern, not a literal). Verified at iter-266 via `grep -c '^[^#]*docker compose -f' packages/devbox/scripts/*.sh`: actual 8 compose-invoking scripts are `build.sh, rebuild.sh, start.sh, stop.sh, status.sh, clean.sh (2 sites), logs.sh (2 sites), benchmark.sh (6 sites)`. Non-invoking scripts explicitly named OUT-OF-SCOPE: `restart.sh` (delegates to stop+start), `env-check.sh` (parses .envrc only), plus the docker-exec shims (`monitor-host/attach/shell/claude-host/gh-auth-host/ralph-*-host/whitelist-host`). Also switched the resolver's export shape from a word-split-fragile string (`KEEL_DEVBOX_COMPOSE_FILES_ARGS`) to a conditional-expansion single-path (`KEEL_DEVBOX_COMPOSE_FILE_SSH`), using the `${VAR:+-f "${VAR}"}` idiom that avoids RALPH.md 2026-04-21 AR-9 iterable-word-splitting hazards.

**PATCH-3 (Task 3 entrypoint block).** Critical — original code block had `gosu dev ssh-keygen -A -f /home/dev/.ssh/` which is LITERALLY BROKEN (`-A` ignores `-f`, writes to `/etc/ssh/` which is read-only-after-image-build). Three-way convergent from Subagents 2/3/4. Replaced with explicit `-t ed25519 -f <path> -N ""` + `-t rsa -b 4096 -f <path> -N ""` invocations, wrapped in an atomic `mkdir tmpdir → generate → mv -T` pattern that survives mid-keygen container kills. Added idempotent perm enforcement every boot (chmod outside existence guards, per Subagent 4 F2 — StrictModes silent-reject defence). Changed root-`mkdir` to `gosu dev mkdir` so keygen doesn't hit "permission denied" against a root-owned directory (Subagent 3 finding). Added `< /dev/null` to every ssh-keygen invocation (prevents interactive prompt under `set -e`). Corrected entrypoint insertion-point claim: exec handoff is at `:155`/`:157`, NOT `:154` (line 154 is the CMD-empty `if` opener).

**PATCH-4 (Task 3 liveness verification).** Added post-spawn `SSHD_PID="$!"; sleep 0.5; kill -0 "${SSHD_PID}"` check with non-fatal stderr reporting (Subagent 4 F3 CRITICAL). Background `&` returns exit 0 from the fork regardless of sshd's actual startup success; without the liveness check, a crashing sshd leaves operator seeing `docker port` reporting 2222 published + connections refusing, with no signal until operator tries to ssh. Non-fatal posture preserves SC-10 (background process lifecycle is operator's responsibility post-spawn); fatal halt would regress the no-SSH-default-should-just-work contract on sshd-config-corruption edge cases. Story 2.13 healthcheck remains the authoritative long-term signal.

**PATCH-5 (sshd_config + AC 3 + AC 4 + SC-12 + invariant doc).** Removed `ListenAddress 127.0.0.1` from sshd_config (Subagent 4 F4 CRITICAL). Rationale: container's network namespace has its own loopback; inbound traffic from Docker's published port arrives on container eth0 (via iptables DNAT under `userland-proxy=false`, or via docker-proxy re-origination under `userland-proxy=true` default), NOT on container-loopback. Binding sshd to `127.0.0.1` inside the container would SILENTLY reject all inbound traffic under both modes — AC 3 would be broken. Loopback confinement is correctly + solely enforced by Docker's `127.0.0.1:2222:2222` publish in `docker-compose.ssh.yml` (host-side). Rewrote AC 3 + AC 4 + SC 12 + invariant doc § Opt-in sshd contract + § External connection refusal to reflect single-layer host-side-publish posture. Added sshd_config header comment explaining the intentional absence of `ListenAddress`.

**PATCH-6 (SC-2 normalisation).** Removed "`yes`, `1`, etc. all also accepted" misstatement; pinned strict `true`-only posture mirroring Story 2.11 `resolve_mode_specific_state()` idiom at `lib/main-repo-resolver.sh:152`. Forks MAY NOT extend the accepted-signal set. Aligns SC-2 with AC 3 + Task 2 resolver contract.

**PATCH-7 (Dev Notes + References line pins).** Corrected `lib/main-repo-resolver.sh:146` line-pin (the function opener; normalisation at `:152`; gate at `:154`). Corrected the "already extended by Story 2.11" claim about `:9-28` — Story 2.11's extension is at `:35-77`, original doc-block at `:1-28` is untouched. Clarified Task 2 inserts a THIRD doc paragraph AFTER the Story 2.11 paragraph. Added source-citations for entrypoint.sh `:121-130` (egress-init block is actually :121-130, not :125-130) and `:154-159` (CMD-empty fallback + exec handoff).

**PATCH-8 (Task 1 setcap).** Removed self-cancelling subtask ("Add `setcap +ep` if needed…NET_BIND_SERVICE is NOT required") — replaced with an affirmative "No `setcap` invocation" instruction that closes the read-body-cancels-title confusion. Verification hook preserved.

**DEFER items (8):**
1. sshd_config `StrictModes no` opt-out (kept StrictModes default; Task 3 idempotent perm enforcement sufficient).
2. docker-exec shims `-e KEEL_DEVBOX_SSH=...` propagation safeguard (operator-edge; once-at-start contract already clear in Task 6(d) mode-flip note).
3. Task 5 invariant-doc H2 section overlap (8→6 consolidation); polish-only, defer to CR cycle or Story 2.17 close-out.
4. Override file `name:` subtask hardening (Compose v2 implicitly picks up from base file; correct-by-default).
5. SC-13 ("No PRD amendment") — narrative SC without Task-enforcement step; keep for traceability.
6. `resolve_ssh_state()` paths-with-spaces edge (current repo `/workspace/ralph-bmad` is safe; fork under `/Users/<space>/…` would hit AR-9 word-splitting — mitigated by PATCH-2's `${VAR:+-f "${VAR}"}` single-path idiom).
7. Operator lockout/revoke flow documentation (Task 6 gap; queue for CR cycle).
8. Task 6 authorized-keys echo `>>` command-injection surface (operator-trusted content; defer to Story 2.13 or Epic 2 close-out docs polish).

**DISMISS items (3):**
1. InvariantSchema description-field compliance (already compliant; Story 2.3 iter-156 LESSON applies cleanly).
2. SC-1/SC-3 overlap with AC 1/AC 2 (standard pattern across Epic 2 stories; not a defect).
3. Compose v2 `ports:` merge REPLACE-vs-CONCATENATE claim (per compose-spec.io, `ports` IS in the additive-sequence key list alongside `expose`, `external_links`, `dns`, `dns_search`, `tmpfs`, `volumes` — the original spec claim was correct).

**Outcome.** Story State `drafted → validated`. 8 PATCH applied in-place; 8 DEFER + 3 DISMISS logged. Next gate: `/bmad-testarch-atdd` for `validated → atdd-scaffolded` (forecast: NON-SKIP for ACs 1-3 via `docker compose config` + entrypoint behaviour smokes; ACs 4-5 operator-workstation-deferred per iter-256/258 precedent). Pre-dev SM review PATCH-count (8) lands slightly above iter-221 LESSON's ~5-ceiling — driven by the two CRITICAL substantive findings (F3 liveness + F4 userland-proxy) that are NOT density-amortisable; the three additional non-blocker PATCHes (7, 8, and half of 2) are narrow pins.
