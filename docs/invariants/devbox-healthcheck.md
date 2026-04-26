# devbox-healthcheck — Compose healthcheck probes dnsmasq + sshd liveness

**Invariant ID:** `INV-devbox-healthcheck`
**Source of truth:** `packages/devbox/docker-compose.yml § services.devbox.healthcheck`
**Story:** 2.13 (Epic 2 — Sandboxed Execution Environment)
**Companion docs:** `docs/invariants/devbox-egress.md` (dnsmasq substrate), `docs/invariants/devbox-ssh.md` (sshd substrate), `docs/invariants/devbox-hardening.md` (capability bounding-set).

## Intent

The compose-level `healthcheck:` block reflects actual in-container service health. The container's `State.Health.Status` is the single signal `pnpm devbox:status` (Story 2.6 `status.sh:54`) and `pnpm devbox:start`'s poll (Story 2.6 AC 2.6.4; `start.sh:92-120`) consume. Upstream cc-devbox's `curl :3000` healthcheck targeted a non-existent service and left every run permanently `unhealthy`; Story 2.13 closes that bug by probing the services the devbox actually runs — dnsmasq (always) and sshd (iff `KEEL_DEVBOX_SSH=true`).

## Probe contract

Composed shell expression, POSIX sh safe (Ubuntu 24.04's `/bin/sh` is `dash`, not bash). Two clauses joined by `&&`:

- **Clause 1 (always)** — `dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com` — probes dnsmasq. Liveness semantics: clause 1 success = dnsmasq RESPONSIVE (NXDOMAIN counts as success; we are measuring whether dnsmasq accepts + replies to the query, not whether the whitelist contains the domain). `+short` truncates output (stdout redirected to `/dev/null` anyway); `+time=3` caps single-query wall time at 3s; `+tries=1` disables the default 2-retry fallback.
- **Clause 2 (iff `KEEL_DEVBOX_SSH=true`)** — `nc -z -w 2 127.0.0.1 2222` — probes sshd TCP listener. Liveness semantics: clause 2 success = TCP three-way-handshake completes (does NOT exercise pubkey auth). Under `KEEL_DEVBOX_SSH=false` (or unset), the `[ "${KEEL_DEVBOX_SSH:-false}" != "true" ]` short-circuits past `||`, so only dnsmasq probes run.

Canonical joined form (as emitted by `docker compose config § test[1]`):

```
dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com >/dev/null && { [ "${KEEL_DEVBOX_SSH:-false}" != "true" ] || nc -z -w 2 127.0.0.1 2222; }
```

The probe deliberately does NOT exercise whitelist membership or pubkey auth — both would add fragility without adding health signal. Whitelist drift would false-positive the healthcheck; pubkey-auth probing would require committed test keys that weaken the trust model.

## Timing parameters

| Key            | Value | Rationale                                                                                                                                                                                                                                                                |
| -------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `interval`     | `10s` | Probe every 10s. 6 probes/min per service = ~8640 dnsmasq queries/day accruing in `/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/egress-queries.jsonl`. Expected baseline; FR37 Epic-4 consumers filter via `jq 'select(.query != "api.github.com")'`.                         |
| `timeout`      | `5s`  | Kill hung probes at 5s. Worst-case probe = `dig +time=3 +tries=1` (3s) + `nc -z -w 2` (≤2s) = ≤5s, matching the outer cap. PR #230 review (iter-9; D-9 closure) added the explicit `nc -z -w 2` cap for belt-and-braces consistency with `dig`'s `+time=3 +tries=1` — typical-case `nc -z` returns in ~1s, but the `-w 2` ceiling guards against TCP edge cases (e.g. `SYN_SENT` storm against a wedged sshd) inheriting the 5s outer kill rather than failing fast.                                                                                                                                                     |
| `retries`      | `3`   | Container transitions to `unhealthy` after 3 consecutive failures — ~30s detection latency post-`start_period`. Balances transient-glitch tolerance against real-failure detection speed.                                                                                |
| `start_period` | `30s` | Entrypoint init budget: `start-egress.sh` ~3-5s for nftables + dnsmasq + resolv.conf pin; sshd ~1s under opt-in. 30s comfortably covers cold-boot + first-probe latency; failures during this window don't count against `retries` (Docker `HEALTHCHECK` start-period semantics). |

Timing values are substrate-authoritative. Fork-local adjustment requires an AMEND PR against this section per FR44 AMEND; fork-extension via `docker-compose.fork.yml` compose-override is the per-fork path (see § Fork extension contract).

## Probe tooling

Baked at image build:

- `dig` via `dnsutils` apt package (`packages/devbox/Dockerfile:61`).
- `nc` via `netcat-openbsd` apt package (`packages/devbox/Dockerfile:64`). The BSD `nc` variant is load-bearing — `netcat-traditional` does NOT support `-z` (zero-byte probe mode).

Both probes run as USER `dev` (`packages/devbox/Dockerfile:360`); no capability or SUID dependency. `dig` opens a UDP client socket on a high ephemeral port (no `CAP_NET_BIND_SERVICE` needed); `nc -z` opens a TCP client socket to `127.0.0.1:2222` (no cap needed). Under `cap_drop: [ALL]` + three-cap allow (NET_ADMIN / NET_RAW / NET_BIND_SERVICE per `INV-devbox-homedev-named-volume`), both probes succeed as `dev`.

Do NOT switch to `curl` / `wget` / `openssl s_client` without updating this invariant.

## Exit codes

| Tool                                                                              | Code                                 | Meaning                                          |
| --------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------------------ |
| `dig`                                                                             | `0`                                  | Any DNS response including `NXDOMAIN`.           |
| `dig`                                                                             | `1`                                  | Parse error on response.                         |
| `dig`                                                                             | `9`                                  | Resolver timeout / connection refused (dnsmasq down). |
| `dig`                                                                             | `10`                                 | Fatal error.                                     |
| `nc -z`                                                                           | `0`                                  | TCP three-way-handshake completes + immediate close. |
| `nc -z`                                                                           | non-zero                             | `ECONNREFUSED` / timeout / `ENOENT`.             |
| Composed shell (`dig … && { [ test ] \|\| nc -z … ; }`)                           | `0`                                  | Both clauses succeed per POSIX `&&` short-circuit. |
| Composed shell                                                                    | non-zero                             | Any clause failure.                              |
| Docker `HEALTHCHECK` consumer                                                     | `0`                                  | healthy.                                         |
| Docker `HEALTHCHECK` consumer                                                     | non-zero                             | unhealthy (no coercion; exit codes preserved in `docker inspect --format '{{json .State.Health}}'` for operator introspection). |
| Docker-internal reserved                                                          | `2`                                  | Docker's own sentinel for internal errors — probe authors MUST NOT return `2`. |

## Probe domain stability

`api.github.com` is the canonical probe domain, anchored at `packages/devbox/whitelist/github.txt:8` (Story 2.3 default-whitelist substrate + Story 2.9 `gh auth login` load-bearing — the only whitelist fragment guaranteed to be present for every fork's gh-auth flow). Removing `api.github.com` from `whitelist/github.txt` will cause dnsmasq to REFUSE the query (not `NXDOMAIN`) → `dig` exits non-zero → healthcheck fails even when dnsmasq is otherwise healthy.

**Three-site lockstep.** If a future story amends `whitelist/github.txt` or renames the probe domain, all THREE sites must update simultaneously:

1. `packages/devbox/docker-compose.yml § services.devbox.healthcheck.test` (the probe itself).
2. `docs/invariants/devbox-healthcheck.md § Probe contract + § Probe domain stability` (this file).
3. `packages/devbox/README.md § Healthcheck (Story 2.13)` (operator-facing documentation).

Automated drift check deferred to Story 2.17 close-out lint (Story 2.13 pre-dev SM DEFER D-5).

## SSH-conditional branch

`KEEL_DEVBOX_SSH` env var is populated inside the container by `packages/devbox/docker-compose.yml § environment` sourcing `KEEL_DEVBOX_SSH_RESOLVED` (Story 2.12 iter-273 PATCH-2; `INV-devbox-ssh`). The healthcheck's POSIX-sh `[ "${KEEL_DEVBOX_SSH:-false}" != "true" ]` check reads the canonical case-folded value — no case-variant drift (raw `True` / `TRUE` / `TrUe` never reach the container; the resolver pre-normalises to strict `"true"` or `"false"`).

- **`KEEL_DEVBOX_SSH=false` (or unset) mode:** `${VAR:-false}` expands to `false`; `[ "false" != "true" ]` exits 0; chain past `||` short-circuits the `nc -z` call. Only dnsmasq probes run.
- **`KEEL_DEVBOX_SSH=true` mode:** `[ "true" != "true" ]` exits non-zero; falls through to `nc -z -w 2 127.0.0.1 2222`. Both probes run; either failure marks unhealthy.

## No curl :3000

The base compose file's `healthcheck.test` MUST NOT reference `curl localhost:3000` under any circumstance. The upstream cc-devbox default is a known bug (no service listens on 3000 at substrate scope). Epic 7+ apps/web MAY later bind port 3000, but the devbox healthcheck is NOT an app-layer probe — it verifies the substrate services (dnsmasq + optional sshd) that every story and every epic depend on. Forks adding app-layer health probes MUST do so via compose override (`docker-compose.fork.yml`) or the Growth-tier fork-invariants scaffold, not by regressing the base `healthcheck.test`.

## Fork extension contract

Forks MAY add fork-specific probes via compose override file (`docker-compose.fork.yml` or similar), merging into the base `healthcheck.test` array.

Forks MAY NOT weaken the substrate probe:

- No removing the dnsmasq clause.
- No removing the sshd clause under `KEEL_DEVBOX_SSH=true`.
- No raising `interval` above 30s (slow-probe regression).
- No raising `timeout` above 10s (masks real hangs).
- No disabling `retries`.

Growth-tier `INVARIANTS.fork.md` fork-owned rules are additive per FR45 + `docs/invariants/fork.md § Precedence`. Substrate-wins precedence applies — fork rules ADD TO but CANNOT override the substrate posture pinned here.
