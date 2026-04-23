# INV-devbox-prereq-check — Prerequisite check (Docker runtime + Claude auth + gh auth)

**Source of truth for Story 2.10 (FR5).** Machine-enforced contract for the prerequisite check that runs at pre-flight on every host-side shim invocation (`pnpm devbox:*`, `pnpm ralph:*`) and as a standalone verb (`pnpm devbox:prereq:check`). Any change to this document re-hashes the manifest `contentHash`; Story 1.9 sync-gate detects drift.

## Three-check contract

The primitive `packages/devbox/scripts/prereq-check.sh` runs up to three checks in dependency order:

1. **Docker runtime reachable** — `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1`. On non-zero exit, emits two stderr lines — the reachability log followed by the install-URL pointer — and exits `8`:

   ```
   [prereq-check] docker unreachable — is the daemon running?
   [prereq-check] install Docker Desktop: https://docs.docker.com/desktop/install/
   ```

   The install-URL string `https://docs.docker.com/desktop/install/` appears **verbatim** per AC 1. The URL is canonical Docker-owned content; any future Docker-URL rotation is a substrate polish (AMEND path).

2. **Claude Code token present** (Tier 2 only) — probes `/home/dev/.claude/.credentials.json` inside the `keel_home_dev` named volume via a throwaway `alpine:3.19` container with a read-only mount. On missing token, emits:

   ```
   [prereq-check] Claude Code not authed — run 'pnpm claude' first
   ```

3. **gh CLI token present** (Tier 2 only) — probes `/home/dev/.config/gh/hosts.yml` identically. On missing token, emits:

   ```
   [prereq-check] gh CLI not authed — run 'pnpm gh:auth' first
   ```

**Existence, not validity.** The probes use `test -e <path>`. Token-format, token-validity, and token-rotation semantics are owned by upstream `@anthropic-ai/claude-code` + `gh` CLI — an expired Claude or gh token passes this check and surfaces downstream at actual `claude`/`gh` invocation time.

## Exit-code schema

Extends Story 2.6 uniform schema with one new code (`2` reused from env-check's missing-var semantic):

| Exit | Meaning                                                      |
| ---- | ------------------------------------------------------------ |
| `0`  | All checks pass (silent; no stderr).                         |
| `2`  | One or more tokens missing (composite pointer list emitted, Claude before gh; AC 5 + SC-5 no-partial-bypass). Also returned on unknown-arg usage error. Tier 2 only. |
| `8`  | Docker runtime unreachable. Install-pointer emitted. Tier 1 + Tier 2. |
| `12` | Other docker-daemon error (volume-inspect crash, alpine pull failure under fail-closed egress). Propagated via `docker`'s own non-zero exit. |

Codes `9` (container not running) / `10` (image not built) / `11` (healthcheck timeout) are Story 2.6/2.7 downstream-of-prereq-check concerns and are NOT emitted by `prereq-check.sh` itself.

## Tier contract (Tier 1 vs Tier 2)

The primitive accepts one optional positional arg — `--tier1` or `--tier2` (default `--tier2`). Every host-side shim pre-flights with exactly one tier choice per the enumeration below:

| Shim                        | Tier   | Rationale                                                |
| --------------------------- | ------ | -------------------------------------------------------- |
| `build.sh`                  | tier1  | Docker needed; image not yet built; no tokens required.  |
| `rebuild.sh`                | tier1  | Same.                                                    |
| `start.sh`                  | tier1  | Volume auto-inits here; tokens not required.             |
| `stop.sh`                   | tier1  | Container mgmt; tokens not required.                     |
| `restart.sh`                | tier1  | Container mgmt; tokens not required (prepend-only — restart.sh has no inline `docker info`; transitively delegates to stop.sh + start.sh). |
| `clean.sh`                  | tier1  | Destroys state; tokens not required.                     |
| `shell.sh`                  | tier1  | Interactive shell; tokens not required for shell entry.  |
| `attach.sh`                 | tier1  | Attach to PID 1; tokens not required.                    |
| `status.sh`                 | tier1  | Read-only state inspect.                                 |
| `logs.sh`                   | tier1  | Read-only log tail.                                      |
| `monitor-host.sh`           | tier1  | Read-only DNS-event tail.                                |
| `whitelist-host.sh`         | tier1  | Local-whitelist mgmt; tokens not required.               |
| `env-check.sh`              | tier1  | `.envrc` var validator; tokens not required (prepend-only — env-check.sh had no prior `docker info` gate). |
| `claude-host.sh`            | tier1  | Auth-establishing verb — Tier 2 would be circular.       |
| `gh-auth-host.sh`           | tier1  | Auth-establishing verb — Tier 2 would be circular.       |
| `ralph-build-host.sh`       | tier2  | Ralph needs all three to run autonomously (FR5).         |
| `ralph-plan-host.sh`        | tier2  | Same.                                                    |
| `prereq-check.sh`           | —      | IS the primitive; does not recurse.                      |

Net touch count in Story 2.10: 17 shims wired (15 block-swap replacing the former inline `docker info` with a single `prereq-check.sh --tier<N>` call + 2 prepend-only for `restart.sh` and `env-check.sh`).

## No-partial-bypass

Story 2.10 AC 5 pins the no-bypass posture at 1.0. **There is no `--skip-claude`, `--force`, `KEEL_PREREQ_BYPASS`, or equivalent escape hatch in `prereq-check.sh`.** An operator with a nuanced need (e.g. CI harness without a host browser, or a Ralph smoke-test that pre-seeds tokens outside the OAuth flow) runs `prereq-check.sh --tier1` directly and bypasses the token probes — the tier argument is the ONLY supported posture-tuning knob. An exit-zero path from `ralph-*-host.sh` requires all three checks to pass under Tier 2; no partial-pass state is representable.

Fork operators needing to relax this posture pursue the AMEND path against this doc (substrate-wide contract change); there is no per-fork opt-out at 1.0 (`INVARIANTS.fork.md` scaffold is additive-only per `docs/invariants/fork.md` § Precedence).

## Fresh-fork first-run behavior

On a fresh fork with no devbox state — no container has been started, the `keel_home_dev` named volume does not yet exist, no Claude or gh token files are present — Tier 2 surfaces a composite missing-item list per AC 5. The `docker volume inspect "${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}_keel_home_dev"` probe returns non-zero (volume does not exist); `prereq-check.sh` treats this as **both tokens missing** and aggregates both pointer lines into a single stderr message (Claude before gh), then exits `2`:

```
[prereq-check] Claude Code not authed — run 'pnpm claude' first
[prereq-check] gh CLI not authed — run 'pnpm gh:auth' first
```

**Why volume-absent maps to both-tokens-missing (not volume-probe-error).** A bare `docker run -v <nonexistent-volume>:/vol:ro alpine test -e …` would auto-create an empty volume as a Docker-daemon side-effect. The prereq-check must NOT mutate host state at pre-flight time; explicit `docker volume inspect` + treat-absent-as-both-missing preserves the no-side-effect contract.

Operator recovery sequence (AC 5 walkthrough):

1. `pnpm ralph:build` → Tier 1 passes → Tier 2 probes volume → absent → composite missing-item list → exit 2.
2. `pnpm devbox:start` → container starts + volume auto-inits (Story 2.5 substrate).
3. `pnpm claude` → OAuth flow → Claude token written to `/home/dev/.claude/.credentials.json` inside `keel_home_dev`.
4. `pnpm gh:auth` → OAuth flow → gh token written to `/home/dev/.config/gh/hosts.yml` inside `keel_home_dev`.
5. `pnpm ralph:build` → all three checks pass silently → Ralph TUI attaches.

## Alpine probe image

`alpine:3.19` is the pinned throwaway image used for the token-existence probes. Chosen for: minimal footprint (~5 MB compressed); stable minor-line (avoids major-line musl-libc ABI drift); POSIX-compliant `test -e` semantics via BusyBox.

**Three source-of-truth sites** all spell `alpine:3.19`:

- `packages/devbox/scripts/prereq-check.sh` (runtime).
- This document (`Alpine probe image` section — hashed into manifest `contentHash`).
- `packages/devbox/README.md § Prerequisite check` (operator-facing reference).

At 1.0 the `alpine:3.19` version is **manually tracked**. Renovate's default `docker` manager scans Dockerfile + docker-compose.yml only; shell-script image references are not auto-discovered. A future substrate polish adds a `customManagers` (regex-manager) entry to `.github/renovate.json` to track `alpine:<version>` across the shell-script surface, or inlines a `# renovate: datasource=docker depName=alpine` hint above the `PROBE_IMAGE` assignment. Deferred as an FR44 AMEND trajectory item.

**Egress.** The alpine pull originates from the host Docker daemon (backend B: `/var/run/docker.sock` bind-mounted) and crosses the host's network namespace — not the devbox in-container namespace. `packages/devbox/whitelist*.txt` governs in-container egress only; no whitelist modification is required for Story 2.10. Operators on restricted host networks (corp proxies, air-gapped CI) handle Docker Hub reachability at the Docker-Desktop-install layer (per `INV-devbox-dind-available`), not at the prereq-check layer.

## Consumption

- **Host-side shims:** every entry in the tier-contract table above invokes `"$(dirname "${BASH_SOURCE[0]}")/prereq-check.sh" --tier<N>` at pre-flight (prepended AFTER `set -euo pipefail` + `unset COMPOSE_PROJECT_NAME` + `SCRIPT_DIR` derivation).
- **Standalone operator verb:** `pnpm devbox:prereq:check` runs Tier 2 by default (exits 0 silently on all-pass; exits 2 with the composite list on tokens-missing; exits 8 with the install pointer on docker-down). `pnpm devbox:prereq:check -- --tier1` exercises Docker-only (useful for CI harnesses without a host browser).
- **Epic 3 Story 3.7 in-loop pre-push gate** (future consumer): when Ralph's in-loop pre-push gate detects an auth-broken `gh push` or `claude`, it writes the halt sentinel `{"reason":"CI_BLOCKED","note":"<exact pointer string from prereq-check>"}` per the closed halt-reason enum (`INV-ralph-halt-reason-enum`; PRD FR14k). Story 2.10 pins the contract; Story 3.7 implements the halt-write.

## Extension (FR44)

Per the substrate-wins precedence rule in `docs/invariants/fork.md § Precedence`, forks that disagree with any element of the three-check contract, tier contract, exit-code schema, or no-bypass posture pursue the AMEND path — a source-level PR against `packages/keel-invariants/` + this document + the invariants manifest + the `INVARIANTS.md` anchor bullet in a single commit. Fork-specific additions (e.g., a fourth check for a fork-specific auth source) can compose in a `INVARIANTS.fork.md` entry (Growth-tier), but cannot remove or relax the three substrate checks.
