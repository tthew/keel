# INV-devbox-ssh — Loopback-bound port publication + opt-in sshd

Companion to `INV-devbox-homedev-named-volume` (Story 2.5 hardening) and
`INV-devbox-mode` (Story 2.11 per-fork vs shared). Pins the substrate-
authoritative posture for devbox port publication + the `KEEL_DEVBOX_SSH=true`
opt-in sshd contract. Story 2.12 lands the full opt-in path; Story 2.2
established the four loopback-bound publish ports (`KEEL_DEVBOX_PORT_WEB` /
`..._API` / `..._STORYBOOK` / `..._VITE_HMR`) that AC 1 of Story 2.12 now
PINS as an invariant.

## Loopback-bound port publication contract

Every `ports:` mapping in `packages/devbox/docker-compose.yml` AND every
sibling compose override file (`packages/devbox/docker-compose.ssh.yml`
today; future per-fork add-ons) MUST use the explicit `127.0.0.1:<host>:
<container>` form. The bare `<host>:<container>` form and the explicit
`0.0.0.0:...` form are FORBIDDEN — Docker silently binds bare-form
publications to `0.0.0.0` (all host interfaces), widening the attack surface
to the host's LAN without operator intent. This is a SUBSTRATE INVARIANT:
forks MAY NOT publish any devbox port to `0.0.0.0` and MAY NOT use the
bare-port form. Downstream stories that add ports (e.g. Story 2.13
healthcheck surfaces, Epic 6 RLS debugger) MUST honour this contract.

## SSH signal

`KEEL_DEVBOX_SSH` in the repo-root `.envrc` is the operator-facing opt-in
signal. Normalisation rules:

- Case-fold via `tr '[:upper:]' '[:lower:]'` before compare.
- ONLY the literal `true` (any-case) enables the opt-in.
- EVERY other value — `false`, `yes`, `on`, `1`, empty, unset, `garbage` —
  fail-closes to no-SSH.
- Strict-true-only posture mirrors Story 2.11 `KEEL_DEVBOX_SHARED`
  normalisation idiom at `packages/devbox/scripts/lib/main-repo-resolver.sh:152`.
- Forks MAY NOT extend the accepted-signal set.

## Opt-in sshd contract

When `KEEL_DEVBOX_SSH=true`:

- sshd runs as UID 1000 (`dev`) — the Story 2.5 non-root user. No CAP_SETUID
  or CAP_NET_BIND_SERVICE required for the port-2222 bind (>1024).
- `Port 2222` (host port parameterised via `KEEL_DEVBOX_SSH_PORT:-2222` in
  the compose override; container port is fixed).
- `PermitRootLogin no`.
- `PasswordAuthentication no`, `ChallengeResponseAuthentication no`,
  `KbdInteractiveAuthentication no`.
- `PubkeyAuthentication yes`.
- `AllowUsers dev`.
- `UsePAM no`, `PrintMotd no`.
- Host keys at `/home/dev/.ssh/host_keys/ssh_host_ed25519_key` +
  `ssh_host_rsa_key`.
- `AuthorizedKeysFile /home/dev/.ssh/authorized_keys`.
- First-boot atomic key generation via explicit
  `ssh-keygen -t ed25519 -f <path> -N ""` +
  `ssh-keygen -t rsa -b 4096 -f <path> -N ""` into a scratch dir, then
  atomically `mv -T` into place. Mid-keygen container kills leave no
  partial keypair (sshd would refuse a half-generated pair).
- Persistence via the `keel_home_dev` named volume (Story 2.5 substrate;
  NFR10). Host keys + `authorized_keys` survive container restart + image
  rebuild.
- Container-side `ListenAddress` is INTENTIONALLY UNSET. See
  § External (non-loopback) connection refusal for rationale.

Baked sshd_config template at `packages/devbox/sshd/sshd_config` is
`COPY`-ed to `/etc/ssh/sshd_config` at image-build time. Runtime
entrypoint.sh MUST NOT modify the config (Story 2.1 AC 2 forbidden-runtime-
install posture).

## No-SSH default contract

When `KEEL_DEVBOX_SSH=false` or unset:

- sshd is NOT started (entrypoint.sh's `[[ "${KEEL_DEVBOX_SSH:-false}" ==
  "true" ]]` gate evaluates false).
- Port 2222 is NOT published at the compose layer — the
  `packages/devbox/docker-compose.ssh.yml` override file is NOT included in
  the `docker compose -f` invocation (the resolver exports an empty
  `KEEL_DEVBOX_COMPOSE_FILE_SSH`, and the shim's `${VAR:+-f "${VAR}"}` idiom
  expands to nothing).
- `docker compose -f packages/devbox/docker-compose.yml config` emits NO
  `2222` port line.
- The four Story 2.2 publish ports remain unaffected.

`packages/devbox/docker-compose.ssh.yml` is the SINGLE site that publishes
port 2222. The base `packages/devbox/docker-compose.yml` MUST NOT include a
`2222` entry in its `ports:` block. Lockstep enforced by code review +
`INV-devbox-ssh § No-SSH default contract`.

## Resolver contract

`packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_ssh_state()` is
the SINGLE resolution site for the SSH state. Caller invocation order
(every host-side compose-invoking shim):

1. `resolve_main_repo_and_workdir`.
2. `resolve_mode_specific_state` (Story 2.11 per-fork vs shared).
3. `resolve_ssh_state` (Story 2.12 SSH state).
4. `export` deltas, then downstream `docker compose` invocations.

Exports:

- `KEEL_DEVBOX_SSH_RESOLVED` — `"true"` | `"false"` (canonical normalised).
- `KEEL_DEVBOX_COMPOSE_FILE_SSH` — `""` (no-SSH) OR the absolute path to
  `docker-compose.ssh.yml` (opt-in SSH).

No shim re-computes SSH mode independently; no inline
`if [[ $KEEL_DEVBOX_SSH == true ]]` blocks outside the resolver and
`entrypoint.sh`.

Compose-CLI idiom at every invoking site (Story 2.12 PATCH-5,
iter-276):

```
source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"
resolve_ssh_state
source "${SCRIPT_DIR}/lib/compose-args.sh"
resolve_compose_args
docker compose "${COMPOSE_ARGS[@]}" <subcommand>
```

`resolve_compose_args` populates the `COMPOSE_ARGS` bash array with
`(-f <base-compose-yml>)`, appending `(-f <ssh-override-yml>)` when
`KEEL_DEVBOX_COMPOSE_FILE_SSH` is non-empty. The array idiom avoids
the embedded-quote-under-unquoted-alt-expansion word-splitting hazard
that the prior inline `${KEEL_DEVBOX_COMPOSE_FILE_SSH:+-f
"${KEEL_DEVBOX_COMPOSE_FILE_SSH}"}` form exposed on fork repo paths
containing whitespace — distinct hazard class from the iterable-word-
splitting lesson at RALPH.md 2026-04-21 AR-9. See
`packages/devbox/scripts/lib/compose-args.sh` header for the full
analysis.

## External (non-loopback) connection refusal

Docker's `127.0.0.1:2222:2222` mapping in `docker-compose.ssh.yml` is the
SINGLE loopback-confinement layer.

- Under `userland-proxy=true` (Docker default), `docker-proxy` binds the
  host-side socket to `127.0.0.1:2222` ONLY; LAN-sourced traffic never
  reaches `docker-proxy`.
- Under `userland-proxy=false`, Docker's `iptables` `DOCKER` chain DNAT
  rules are scoped to the `127.0.0.1` host-destination; LAN-sourced
  packets do not match the rule and are dropped.

In BOTH modes, LAN-sourced SSH attempts against the host's non-loopback
interfaces are refused. Only `ssh -p 2222 dev@127.0.0.1` from the host
(the Docker-daemon host) succeeds — and only with a registered pubkey.

Container-side sshd `ListenAddress` is NOT used. Container-loopback is
DISJOINT from host-loopback: inbound traffic from Docker's published port
arrives on the container's `eth0` interface (via iptables DNAT or
docker-proxy re-origination), NOT on the container's `127.0.0.1`. Binding
sshd to `ListenAddress 127.0.0.1` inside the container would SILENTLY drop
all inbound connections under either userland-proxy mode — AC 3 would be
broken. The single-layer host-side-publish posture is correct and
sufficient; the container network namespace is an isolated attack surface
because external peers cannot reach `eth0` without traversing the
published-port gate on the host.

Operator-workstation verification only — DinD backend B iteration envs
cannot exercise a non-loopback LAN peer meaningfully (Story 2.5 iter-186
posture). Substrate verifies via `docker compose config` shape +
AC-1-contract claim + this invariant doc.

## Operator authorized-keys flow

To register a pubkey:

1. Start the devbox (`pnpm devbox:start`).
2. `pnpm devbox:shell` (lands inside the container as UID 1000 `dev`).
3. `echo 'ssh-ed25519 AAAA... user@host' >> ~/.ssh/authorized_keys`.
4. Exit shell.
5. From host: `ssh -p 2222 -i ~/.ssh/id_ed25519 dev@127.0.0.1`.

The pubkey persists in `/home/dev/.ssh/authorized_keys` INSIDE the
`keel_home_dev` named volume (Story 2.5 substrate). Survives:

- `pnpm devbox:stop && pnpm devbox:start` (container restart).
- `pnpm devbox:rebuild` (image rebuild — the named volume is preserved).

Agents MUST NOT bind-mount, copy, surface, or inspect `authorized_keys`
outside the named volume — same posture as Story 2.8/2.9 OAuth tokens
(NFR10). Automated re-auth or pubkey insertion from outside the container
is NOT permitted; pubkey registration is an operator-interactive gesture.

## Named volume relationship to INV-devbox-homedev-named-volume

Story 2.5's `INV-devbox-homedev-named-volume` pins the unqualified name
`keel_home_dev`. Story 2.12's host keys + `authorized_keys` live INSIDE
that volume at `/home/dev/.ssh/host_keys/` + `/home/dev/.ssh/authorized_keys`.
Story 2.12 does NOT touch the volume's name, the substrate mount posture,
or the non-toggle-able contract — it only adds new file-tree paths under
`/home/dev/.ssh/`. Persistence semantics inherited unchanged.

## Mode (Story 2.11) orthogonality

SSH state is per-CONTAINER, not per-MODE. Both per-fork mode
(`keel-devbox` container + `keel-devbox_keel_home_dev` volume) and shared
mode (`keel-devbox-shared` container + `keel-devbox-shared_keel_home_dev`
volume) honour `KEEL_DEVBOX_SSH` independently. `resolve_ssh_state()`
composes orthogonally to `resolve_mode_specific_state()`; the compose-file
argument is identical in both modes.

## Invariant stability

- **Loopback-bound port publication** is a SUBSTRATE INVARIANT. Forks MAY
  NOT publish any devbox port to `0.0.0.0` or use bare-port form.
- **Opt-in sshd is OPERATOR-DEFAULT-OFF.** Forks MAY NOT change the
  default to `true` (no substrate-wide "always-on sshd" posture).
- Fork-level Growth-tier `INVARIANTS.fork.md` rules MAY add fork-specific
  sshd_config overlays (e.g., MFA via
  `AuthenticationMethods publickey,keyboard-interactive`) but MAY NOT
  weaken substrate defaults: no `PasswordAuthentication yes`, no
  `PermitRootLogin yes`, no bare-port publication, no `0.0.0.0` binding,
  no container-side `ListenAddress` that breaks AC 3.

## Cross-references

- `packages/devbox/sshd/sshd_config` — baked config template.
- `packages/devbox/docker-compose.ssh.yml` — compose override.
- `packages/devbox/docker-compose.yml § environment` — `KEEL_DEVBOX_SSH`
  container-env propagation.
- `packages/devbox/entrypoint.sh` — first-boot host-key-gen + sshd launch.
- `packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_ssh_state()`
  — single resolution site.
- `packages/devbox/.envrc.example:40` — operator knob publication.
- `packages/devbox/README.md § Opt-in SSH (Story 2.12)` — operator docs.
- `AGENTS.md § Opt-in SSH (Story 2.12)` — agent-facing guardrails.
- `INV-devbox-homedev-named-volume` (`docs/invariants/devbox-hardening.md`)
  — named-volume substrate.
- `INV-devbox-mode` (`docs/invariants/devbox-mode.md`) — per-fork vs shared
  orthogonality.
