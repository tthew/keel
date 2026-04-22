# Story 2.6: Host-side `pnpm devbox:*` CLI surface

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want host-side `pnpm devbox:{build,rebuild,clean,status,logs,shell,attach,start,stop,restart,whitelist,monitor,env:check}` commands driving the devbox lifecycle,
so that I never need to learn raw `docker compose` incantations to operate my devbox (FR1).

## Acceptance Criteria

1. **Given** the devbox package,
   **When** I inspect `packages/devbox/scripts/`,
   **Then** there is one script per command (or a single CLI entry dispatching by subcommand)
   **And** `package.json` exposes each as a `pnpm devbox:<cmd>`.

2. **Given** `pnpm devbox:build`,
   **When** I run it,
   **Then** the image is built from `packages/devbox/Dockerfile`
   **And** `pnpm devbox:rebuild` rebuilds with `--no-cache`.

3. **Given** `pnpm devbox:start`,
   **When** I run it,
   **Then** the container comes up via compose (from Story 2.1)
   **And** healthchecks (Story 2.13) must pass before the command returns zero.

4. **Given** `pnpm devbox:stop` / `pnpm devbox:restart` / `pnpm devbox:clean`,
   **When** I run each,
   **Then** `stop` halts without destroying the named volume, `restart` is `stop && start`, and `clean` removes the container and image but keeps the named volume from Story 2.5 (prompting for explicit confirmation before volume deletion).

5. **Given** `pnpm devbox:shell`,
   **When** I run it,
   **Then** it opens an interactive shell as the `dev` user inside the running container.

6. **Given** `pnpm devbox:attach`,
   **When** I run it,
   **Then** it attaches to the container's stdout/stderr (for observing Ralph TUI from Story 2.7)
   **And** supports `Ctrl+P Ctrl+Q` detach without killing the container (Story 2.7 prereq).

7. **Given** `pnpm devbox:status` / `pnpm devbox:logs` / `pnpm devbox:monitor`,
   **When** I run each,
   **Then** `status` prints container state + healthcheck, `logs` tails container stdout/stderr, `monitor` displays a live resource snapshot (cpu/memory/network).

8. **Given** `pnpm devbox:env:check`,
   **When** I run it,
   **Then** it validates that `.envrc` is present and every required `KEEL_DEVBOX_*` variable is defined
   **And** exits non-zero with a missing-var report if any are absent.

9. **Given** `pnpm devbox:whitelist`,
   **When** I run it (wired in Story 2.4),
   **Then** it invokes the atomic-reload flow from Story 2.4.

### Scope clarifications (pinned at draft, MUST be honored — not re-negotiable without Change Log entry)

- **SC-1 (host-side execution locus):** every `packages/devbox/scripts/<verb>.sh` created by this story runs **on the host** (operator workstation). Their primary role is to translate `pnpm devbox:<verb>` into `docker compose -f packages/devbox/docker-compose.yml …` or `docker exec <container> …` invocations. DO NOT invoke these scripts from inside the container (Story 2.4's `whitelist.sh` is the in-container counterexample; Story 2.6 scripts are the host-side shim surface per Story 2.4 SC-16 + SC-12). Where a verb has BOTH a host-side and in-container facet (notably `whitelist`, `monitor`), Story 2.6 ships the host-side shim that `docker exec`s into the in-container primitive. DO NOT invoke `docker exec` from inside `packages/devbox/scripts/whitelist.sh` (Story 2.4 in-container primitive — recursion risk).

- **SC-2 (13-verb surface + pnpm script names):** Story 2.6 ships EXACTLY 13 pnpm scripts at the **repo-root** `package.json`, matching the user-story verb enumeration. Canonical kebab-case + colon namespace; one colon for top-level verbs, double colon for sub-namespaced `env:check` (matches PRD § CLI-Tool Surface naming at `prd.md:488-494` + architecture § Devbox Package Tree at `architecture.md:975-1004`):

  | pnpm script | Script file | Purpose |
  | --- | --- | --- |
  | `devbox:build` | `packages/devbox/scripts/build.sh` | `docker compose build` (cached) |
  | `devbox:rebuild` | `packages/devbox/scripts/rebuild.sh` | `docker compose build --no-cache` |
  | `devbox:start` | `packages/devbox/scripts/start.sh` | `docker compose up -d` + healthcheck poll |
  | `devbox:stop` | `packages/devbox/scripts/stop.sh` | `docker compose stop` (named volume preserved) |
  | `devbox:restart` | `packages/devbox/scripts/restart.sh` | `stop.sh && start.sh` |
  | `devbox:clean` | `packages/devbox/scripts/clean.sh` | `docker compose down --rmi local` + confirm-before-volume-delete |
  | `devbox:shell` | `packages/devbox/scripts/shell.sh` | `docker exec -it … bash -l` as `dev` user |
  | `devbox:attach` | `packages/devbox/scripts/attach.sh` | `docker attach --detach-keys='ctrl-p,ctrl-q' …` |
  | `devbox:status` | `packages/devbox/scripts/status.sh` | `docker compose ps` + healthcheck state |
  | `devbox:logs` | `packages/devbox/scripts/logs.sh` | `docker compose logs -f` |
  | `devbox:monitor` | `packages/devbox/scripts/monitor.sh` | `docker exec … /workspace/packages/devbox/scripts/egress-log-tailer.sh` (Story 2.3 primitive) |
  | `devbox:whitelist` | `packages/devbox/scripts/whitelist-host.sh` | `docker exec … /workspace/packages/devbox/scripts/whitelist.sh "$@"` (Story 2.4 in-container primitive) |
  | `devbox:env:check` | `packages/devbox/scripts/env-check.sh` | validate `.envrc` presence + required `KEEL_DEVBOX_*` vars |

  Script filenames use hyphens (kebab-case) to match existing siblings (`benchmark.sh`, `egress-log-tailer.sh`, `reload-egress.sh`, `start-egress.sh`). The `env-check.sh` filename has ONE hyphen; the pnpm alias `devbox:env:check` has the double-colon (filename-naming vs CLI-namespace-naming are deliberately distinct — see Story 2.4 SC-13 script-shape precedent).

  **Rationale for `monitor.sh` vs `whitelist-host.sh` rename:** the existing in-container monitor has no host-side counterpart today, so `monitor.sh` is free for the host-side shim OR Story 2.6 creates `monitor-host.sh` mirroring the `whitelist-host.sh` pattern. **Decision: rename the existing in-container `monitor.sh` to `monitor-egress.sh` is out of scope; instead, Story 2.6's host-side `monitor.sh` DOES NOT pre-exist — check current state.** If `packages/devbox/scripts/monitor.sh` already exists as in-container tailer (precursor), rename it IN THIS STORY to `monitor-egress.sh` + update any entrypoint references + add the host-side `monitor.sh` shim that `docker exec`s into it. See Task 2 for the pre-flight check.

- **SC-3 (repo-root `package.json` wiring, AC 1):** add 13 script entries to the `"scripts"` block of `/workspace/ralph-bmad/.claude/worktrees/ralph/package.json`. Each entry maps to the host-side script under `packages/devbox/scripts/`. Example shape:

  ```json
  "scripts": {
    "…existing entries…",
    "devbox:build": "./packages/devbox/scripts/build.sh",
    "devbox:rebuild": "./packages/devbox/scripts/rebuild.sh",
    "devbox:start": "./packages/devbox/scripts/start.sh",
    "devbox:stop": "./packages/devbox/scripts/stop.sh",
    "devbox:restart": "./packages/devbox/scripts/restart.sh",
    "devbox:clean": "./packages/devbox/scripts/clean.sh",
    "devbox:shell": "./packages/devbox/scripts/shell.sh",
    "devbox:attach": "./packages/devbox/scripts/attach.sh",
    "devbox:status": "./packages/devbox/scripts/status.sh",
    "devbox:logs": "./packages/devbox/scripts/logs.sh",
    "devbox:monitor": "./packages/devbox/scripts/monitor.sh",
    "devbox:whitelist": "./packages/devbox/scripts/whitelist-host.sh",
    "devbox:env:check": "./packages/devbox/scripts/env-check.sh"
  }
  ```

  Order: insert AFTER the existing `keel-invariants:*` block and BEFORE `"prepare"`. Alphabetical ordering WITHIN the `devbox:*` block is NOT required (grouped by lifecycle: build → start → stop → clean, then interactive (shell/attach), then observability (status/logs/monitor), then whitelist + env:check). DO NOT add `"devbox:whitelist"` to `packages/devbox/package.json` at the same time — Story 2.4 already owns that entry for the in-container invocation path; Story 2.6 adds ONLY the root-level host-side alias with the `-host.sh` suffix suffix-resolved script.

- **SC-4 (script shape — matches Story 2.4 SC-13):** every new `packages/devbox/scripts/<verb>.sh` file:
  - kebab-case, `.sh` suffix, `0755` perm, `#!/usr/bin/env bash`, `set -euo pipefail`.
  - Self-rooted path resolution: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` + `DEVBOX_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"`. NO absolute `/workspace/` paths (relocation-safe for fork re-rooting).
  - Banner comment block: Story 2.6 + relevant AC ids + brief purpose.
  - `log()` helper: `log() { printf '<verb>: %s\n' "$*" >&2; }` — script-prefixed, stderr-targeted, per-verb prefix.
  - `usage()` function for scripts that accept subcommands/flags; exits 2 on usage violation.

- **SC-5 (exit-code contract — cross-CLI uniform with Story 2.3 / 2.4):** each Story 2.6 script declares its own exit codes in the banner, but the following codes are reserved for uniformity across the devbox CLI family (matches Story 2.4 SC-11 `reload-egress.sh` codes 2–7 + new Story 2.6 codes 8–11):
  - `0` success.
  - `2` usage error / validation failure (missing arg, unknown subcommand, `env:check` missing required var).
  - `3` source file unreadable (`.envrc` absent for `env:check`, docker-compose.yml not found).
  - `4` mutation lock unavailable within timeout (if Story 2.6 scripts introduce locking — see SC-12).
  - `5–7` propagated from in-container primitives (`whitelist.sh`, `reload-egress.sh`) via `docker exec` — exit code passthrough.
  - `8` docker runtime unreachable (`docker info` failed). Emit `devbox: docker unreachable — is the daemon running?` to stderr.
  - `9` container not running when required (shell/attach/status-running-mode/whitelist/monitor require a running container; fail with `devbox: container 'keel-devbox' is not running — run 'pnpm devbox:start' first`).
  - `10` image not built when required (first `start` after a fresh clone; suggest `pnpm devbox:build`).
  - `11` healthcheck timeout (Story 2.13 gates `start` — if healthcheck does not pass within `KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S` default 120s, exit 11 + leave container running for operator debugging).
  - `124` — RESERVED for `timeout`(1) command semantics (operator-facing `timeout`-wrapped invocations). Do not use internally.

  Story 2.6 MUST document this exit-code table in `packages/devbox/README.md § Host-side CLI (Story 2.6)` (SC-23) — Story 2.4 AI-5 drain precedent: the exit-code table is CR-scrutinised for completeness.

- **SC-6 (compose file path + project name, AC 2 + AC 3):** every `docker compose` invocation in Story 2.6 scripts uses:
  - `-f "${DEVBOX_DIR}/docker-compose.yml"` (explicit file — avoids working-directory ambiguity when operator runs `pnpm devbox:*` from anywhere in the repo).
  - NO `-p` / `--project-name` flag. Compose-project-name is pinned to `keel-devbox` via the top-level `name:` key at `packages/devbox/docker-compose.yml:43` (Story 2.5 iter-194 AI-3 landing). Overriding via `-p` or `COMPOSE_PROJECT_NAME` drifts the namespaced volume FQN to `<override>_keel_home_dev` (AR-12 docs polish). **Story 2.6 honors the pinned name; operators who explicitly set `COMPOSE_PROJECT_NAME=…` (e.g., to run two devboxes side-by-side) opt into the drifted FQN documented in SC-23.**
  - Container name: `${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}` — matches `docker-compose.yml:56`. Scripts read this via `source "${DEVBOX_DIR}/../../.envrc" 2>/dev/null || true` + default fallback. DO NOT hardcode `keel-devbox` where the envvar can be used.

- **SC-7 (`.envrc` handling — host-side vs in-container, AC 3 + AC 8):** `docker-compose.yml` declares `env_file: ../../.envrc` (repo-root `.envrc`, loaded INTO the container at compose bring-up). Story 2.6 host-side scripts DO NOT source `.envrc` themselves EXCEPT for `env-check.sh` which PARSES it to validate key presence (SC-14). Rationale: compose handles env-file loading for the container; host scripts only need a small subset of vars (e.g., `KEEL_DEVBOX_CONTAINER_NAME`, `KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S`) that operators may want to inject at host-side invocation time. For those narrow cases, scripts use `"${VAR:-default}"` bash expansion reading from the process environment (operator sets via direnv or explicit `export`) — they do NOT source `.envrc` directly. Sourcing `.envrc` on the host would execute arbitrary bash in the operator's shell which is a footgun (direnv's allow-list is the safer integration surface and Story 2.2 ships it).

- **SC-8 (`build.sh` / `rebuild.sh` — AC 2):**
  - `build.sh`: `docker compose -f "${COMPOSE_FILE}" build devbox` (named service; compose handles cache). Exit 0 on success; propagate docker exit code on failure.
  - `rebuild.sh`: `docker compose -f "${COMPOSE_FILE}" build --no-cache devbox`. Fresh rebuild from scratch (used after Dockerfile change or layer-corruption recovery).
  - Neither script runs the container — they only build the image (named `keel-devbox:local` per `docker-compose.yml` image ref + Ralph convention).
  - Backend-B destructive-op gate: NONE required (build-only; no image deletion). `rebuild --no-cache` does not prune unrelated host images.

- **SC-9 (`start.sh` — AC 3):**
  - Pre-flight: `docker info --format '{{.ServerVersion}}' >/dev/null 2>&1 || exit 8`. Then verify image exists: `docker image inspect keel-devbox:local >/dev/null 2>&1 || { log "image not built — run pnpm devbox:build"; exit 10; }`.
  - `docker compose -f "${COMPOSE_FILE}" up -d devbox`.
  - Healthcheck poll: Story 2.13 will wire the real healthcheck (dnsmasq + sshd). **Story 2.6 ships a stub-friendly poll loop:** `docker compose -f "${COMPOSE_FILE}" ps --format json devbox | jq -r '.[0].Health'` (or `.Status` if Health absent). Poll every 2s up to `${KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S:-120}` seconds. Accept `healthy`, `starting` (within first 30s grace), or bare `running` (when no healthcheck is configured — pre-Story-2.13 posture). Reject `unhealthy` or any `exited|dead|removing|paused` immediately → exit 11.
  - On timeout without healthy state: emit `devbox: container failed to reach healthy state within <N>s — check 'pnpm devbox:logs'` + exit 11. Leave the container running for operator debugging.
  - On success: emit `devbox: started (container keel-devbox)` to stdout + exit 0.
  - **MUST NOT** block forever. MUST NOT auto-invoke `pnpm devbox:build` on image-missing (operator intent must be explicit).

- **SC-10 (`stop.sh` / `restart.sh` — AC 4):**
  - `stop.sh`: `docker compose -f "${COMPOSE_FILE}" stop devbox`. Does NOT call `down` (which removes the container); `stop` keeps the container object around so `start` is a no-op-fast next time. Named volume `keel_home_dev` is naturally preserved (stop doesn't touch volumes). Exit 0 on success.
  - `restart.sh`: invokes `stop.sh` then `start.sh` in sequence via absolute paths (`"${SCRIPT_DIR}/stop.sh"` + `"${SCRIPT_DIR}/start.sh"`). If stop fails, abort before start. Propagate start's exit code as final rc.

- **SC-11 (`clean.sh` — AC 4, destructive-op gate + backend-B awareness):**
  - **Three-tier behavior by flag:**
    1. `clean.sh` (no flag): `docker compose -f "${COMPOSE_FILE}" down --rmi local --remove-orphans` — removes container + image (scoped to local `keel-devbox:local` tag), leaves named volume `keel_home_dev` UNTOUCHED. Exit 0.
    2. `clean.sh --with-volumes`: WARNING banner + explicit y/N prompt (`read -p "This will DESTROY the keel_home_dev named volume (Claude Code + gh tokens LOST). Continue? [y/N] "`). On `y` only: `docker compose -f "${COMPOSE_FILE}" down --rmi local --volumes --remove-orphans`. On anything else: abort + exit 0 (no-op). Auto-yes via `--yes` (CI-only path; operator-typed `--yes` is explicit acknowledgement).
    3. `clean.sh --allow-broad-prune`: RESERVED (SC-13 backend-B gate). By default, no broad `docker system prune` is invoked. This flag is a **future safety valve** for operator-workstation native runs where a full image / container / volume prune is intended. At 1.0 launch this flag is declared in the banner but the guarded invocation falls back to the scoped `down --rmi local` behavior — broad-prune support lands at Story 2.17 or a later hardening pass per `devbox-dind.md` § Backend contract / benchmark.sh `--allow-broad-prune` precedent. **DO NOT implement broad-prune at Story 2.6;** declare the flag + reject with `devbox clean: --allow-broad-prune is reserved; scoped cleanup is the 1.0 default — see devbox-dind.md § Backend contract` + exit 0 (treat as a no-op accepted flag).
  - Backend-B detection (matches `benchmark.sh` precedent per `devbox-dind.md:41-47`): `if [[ -f /.dockerenv ]] || docker info --format '{{.Name}}' 2>/dev/null | grep -Eq '^(docker-desktop|moby|linuxkit-)'; then BACKEND=B; fi`. Under backend B, `clean.sh --with-volumes` refuses the volume-destroy path WITHOUT an additional `--force-backend-b` flag (prevents accidental destruction of a host-shared docker volume on socket-passthrough envs). Emit `devbox clean: backend B detected — volume destruction requires --force-backend-b acknowledgement`.

- **SC-12 (lifecycle mutation lock — optional, backend-B friendly):** concurrent `pnpm devbox:start` on the same operator workstation is unlikely but possible (two terminals, one operator). If Story 2.6 adds lifecycle locking, use `/tmp/keel-devbox-lifecycle.lock` (host tmpfs; operator-writable) with `flock -x -w 10` on a fresh fd (e.g., fd 202 — disjoint from Story 2.3's fd 200 + Story 2.4's fd 201 even though those are in-container). Exit 4 on lock-timeout. **SC-12 DEFERRED at 1.0 drafting** — only ship this if operator-workstation testing surfaces concurrent-invocation races; initial implementation can omit the lock. Trade-off: docker compose itself is concurrent-safe at the compose level (two `docker compose up -d` calls coalesce to one container-create), so the lock is a DX-level improvement (avoids interleaved output confusion) not a correctness fix. If deferred, add a note in `packages/devbox/README.md § Host-side CLI § Known gaps`.

- **SC-13 (`shell.sh` / `attach.sh` — AC 5 + AC 6):**
  - `shell.sh`: `docker exec -it --user dev -w /workspace "${CONTAINER_NAME}" bash -l`. Explicit `--user dev` matches Story 2.5 non-root posture (Dockerfile `USER dev`). `-w /workspace` starts in the workspace root so operators don't land in `/home/dev`. `-l` login shell to source bashrc/profile.
  - `attach.sh`: `docker attach --detach-keys='ctrl-p,ctrl-q' "${CONTAINER_NAME}"`. `--detach-keys` pins Ctrl+P Ctrl+Q as the detach sequence (docker's default, but making it explicit protects against future docker-default changes that might surprise operators mid-Ralph-iteration). `attach` returns the PID 1 process's stdio to the operator — this is the Ralph TUI in Story 2.7. On non-running container: exit 9.
  - Both exit 0 on clean termination. Shell exits inherit the user's shell exit rc (typically 0 on `exit`; non-zero if last command failed). Attach exit rc is inherited from detach (0 on Ctrl+P Ctrl+Q) or signal propagation.

- **SC-14 (`env-check.sh` — AC 8 + AR-11 absorption):**
  - Required `KEEL_DEVBOX_*` vars — this list is the union of vars referenced in `docker-compose.yml` + entrypoint + Story 2.1-2.5 invariant docs. Story 2.6 dev-agent MUST grep the current HEAD to regenerate this list (`rg 'KEEL_DEVBOX_[A-Z_]+' packages/devbox/ .envrc.example` + sort-uniq) to avoid stale-list drift. Seed list (NOT authoritative — regenerate at impl-time):
    - `KEEL_DEVBOX_CONTAINER_NAME` (default `keel-devbox`)
    - `KEEL_DEVBOX_IMAGE_TAG` (default `keel-devbox:local`)
    - `KEEL_DEVBOX_TMPFS_TMP_MB` (Story 2.2 knob; AR-11 envvar validation)
    - `KEEL_DEVBOX_TMPFS_VARTMP_MB` (Story 2.2 knob; AR-11)
    - `KEEL_DEVBOX_TMPFS_LOGS_MB` (Story 2.2 inert knob at 1.0)
    - `KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S` (Story 2.6 knob; default 120)
    - `KEEL_DEVBOX_SHARED` (Story 2.11 — if envvar NAMED in docker-compose.yml or entrypoint by the time Story 2.6 lands)
    - `KEEL_DEVBOX_SSH` (Story 2.12 — ditto)
  - Algorithm:
    1. `ENVRC_PATH="${DEVBOX_DIR}/../../.envrc"`. If not readable → exit 3 with `devbox env-check: .envrc not found at <path> — run 'direnv allow' or copy .envrc.example` message.
    2. Parse `.envrc` line by line. For each `export KEEL_DEVBOX_<NAME>=…` or `KEEL_DEVBOX_<NAME>=…` line, record the var name + value.
    3. For each required var in the list: check presence (empty value is PRESENT — presence != non-empty). **AR-11 absorption:** for the two tmpfs-size vars (`KEEL_DEVBOX_TMPFS_TMP_MB` + `KEEL_DEVBOX_TMPFS_VARTMP_MB`), additionally validate value shape: strictly non-empty positive integer (regex `^[1-9][0-9]*$`). Reject `0`, empty, negative, or non-numeric (`"2gb"`) with stderr `env-check: KEEL_DEVBOX_TMPFS_TMP_MB='<value>' — expected positive integer MB count (no units)`.
    4. Emit stdout summary: `env-check: <N> of <M> required vars present; <K> value-shape violations`.
    5. Exit 0 iff every required var is present AND every shape-validated var passes. Otherwise exit 2.
  - **Names-only, never values:** `env-check` must NEVER echo a var's value to stdout/stderr (secrets discipline per `architecture.md:335,1004`). On shape violation, the stderr message MAY include the offending value (as shown above) ONLY for integer-type vars where the value is not a credential. For any var matching the pattern `*_TOKEN`, `*_SECRET`, `*_KEY`, `*_PASSWORD`, suppress value in error message (`KEEL_DEVBOX_* vars at 1.0 do not include any credential-named vars, but the guard is defensive`).
  - **Fail-closed:** `env-check` exits non-zero BEFORE any `docker compose` invocation. Scripts that depend on env validity (`start.sh`, `clean.sh`) MAY call `env-check.sh` as a pre-flight; **decision at 1.0: `start.sh` calls it, others do not.** The pre-flight in `start.sh` is tunable via `KEEL_DEVBOX_START_SKIP_ENV_CHECK=true` (operator escape hatch for CI scenarios with alternate env injection).

- **SC-15 (`status.sh` / `logs.sh` / `monitor.sh` — AC 7):**
  - `status.sh`: `docker compose -f "${COMPOSE_FILE}" ps --format table devbox` + explicit healthcheck extraction via `docker inspect --format '{{.State.Health.Status}}' "${CONTAINER_NAME}" 2>/dev/null || echo "(no healthcheck configured)"`. Emits both to stdout. Exit 0 even if container is stopped (status-reporting is not itself an error); exit 9 only if the container object doesn't exist at all.
  - `logs.sh`: `docker compose -f "${COMPOSE_FILE}" logs -f --tail=100 devbox`. Default follow-mode with 100-line backlog. Flags `--no-follow`, `--tail=<N>` forwarded to compose if supplied. Exit 0 on clean detach (SIGINT).
  - `monitor.sh`: **host-side shim** — `docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/egress-log-tailer.sh "$@"` OR `/workspace/packages/devbox/scripts/monitor.sh` depending on the in-container primitive's name at Story 2.6 impl-time. **Pre-flight discovery:** `ls packages/devbox/scripts/monitor*.sh egress-log-tailer.sh` at impl time; the FR1a-mandated "JSONL tail" surface (`prd.md:494`) is Story 2.3's output at `packages/devbox/scripts/egress-log-tailer.sh` at 2026-04-22 HEAD. If `packages/devbox/scripts/monitor.sh` already exists as an in-container primitive, this story MAY rename it to `monitor-egress.sh` to free the `monitor.sh` filename for the host-side shim, OR it MAY name the host-side shim `monitor-host.sh` + keep in-container `monitor.sh` untouched. **Decision at drafting: name the host-side shim `monitor.sh` ONLY IF no in-container file of that name exists; otherwise name it `monitor-host.sh` to avoid the collision.** Dev-agent resolves at Task 2 pre-flight.

- **SC-16 (`whitelist-host.sh` — AC 9 + Story 2.4 SC-12 absorption):**
  - Thin shim: `docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/whitelist.sh "$@"`. Arguments passthrough verbatim (including the `add|remove|list|sync` subcommand + domain argument).
  - Pre-flight: container-running gate (exit 9 if stopped). DO NOT auto-start the container (operator intent must be explicit — a `whitelist.sh add` that silently starts the container violates least-surprise).
  - Exit-code passthrough: whitelist.sh exits 0/2/3/4/5/6/7; host-side shim propagates verbatim.
  - **Story 2.4 SC-12 scope-boundary satisfaction:** this is the EXACT `docker exec`-shim Story 2.4's SC-12 explicitly deferred to Story 2.6. Create under `packages/devbox/scripts/whitelist-host.sh` (hyphen suffix disambiguates from in-container `whitelist.sh`) so a fork operator grepping `packages/devbox/scripts/whitelist*` immediately sees the two-file pattern (in-container primitive + host-side shim).
  - DO NOT add a dispatch / subcommand parser inside `whitelist-host.sh` — it's pure passthrough. Any CLI argument validation is the responsibility of the in-container `whitelist.sh` (avoids dual-source-of-truth-for-validation drift).

- **SC-17 (no new `INV-*` invariant — consumer story per Story 2.4 SC-15 precedent):** Story 2.6 is a **consumer** of `INV-devbox-dind-available` (Story 2.1), `INV-devbox-egress-contract` (Story 2.3), and `INV-devbox-homedev-named-volume` (Story 2.5). It does NOT register a new `INV-*` manifest entry and does NOT refresh existing contentHashes UNLESS the story touches `docs/invariants/devbox-hardening.md` (AR-10 operator-migration prose) — in which case the existing `INV-devbox-homedev-named-volume` contentHash MUST be refreshed via the iter-195/iter-196 three-step sync-gate protocol (see RALPH.md + Story 2.5 iter-195 LESSON):
  1. Edit `docs/invariants/devbox-hardening.md` (AR-10 operator-migration section).
  2. Run `pnpm keel-invariants:check` — drift report prints `expected <new-hash>, actual <old-hash>`.
  3. Update `packages/keel-invariants/src/invariants.manifest.ts` `INV-devbox-homedev-named-volume` entry's `contentHash` field to the new hash.
  4. `pnpm --filter @keel/keel-invariants build` to rebuild `dist/check.js` (the check consumes bundled manifest constants, not the `.ts` source).
  5. `pnpm keel-invariants:check-all` — must exit 0.

- **SC-18 (no compose-shape edits — NFR10 preservation):** Story 2.6 MUST NOT edit `packages/devbox/docker-compose.yml` EXCEPT to add/adjust healthcheck-related fields IF Story 2.13's healthcheck lands in parallel (Story 2.13 is the scope-owner of healthcheck; Story 2.6 consumes it via SC-9 poll loop). No cap_drop/cap_add changes, no security_opt changes, no tmpfs-mount changes, no named-volume changes. All Story 2.5 hardening posture is preserved verbatim. Runtime compose-shape check lands at Story 2.17 (separate scope).

- **SC-19 (AR-7 deferral explicit):** Story 2.5 CR-opener AR-7 (`/run` relocation from whitelist.sh state files + dnsmasq pid-file under USER dev, SC-14 branch (ii) of Story 2.5) is NOT absorbed by Story 2.6 unless operator-workstation empirical smoke surfaces `/run` ownership breakage. Story 2.6 dev-agent runs the AC 5 Smoke A/B recipes from `packages/devbox/README.md § Hardening § Verification` as part of implementation closure. IF `pnpm devbox:start` succeeds + `pnpm devbox:whitelist sync` succeeds + egress log writes to `/workspace/logs/egress-queries.jsonl` — then `/run` ownership is fine under SC-14 branch (i) happy path, AR-7 stays deferred. IF any of those surfaces a `/run/*: Permission denied` → Story 2.6 escalates: relocate `MUTATE_LOCK` + `COMPOSED_WHITELIST` + `PREVIOUS_COMPOSED` + dnsmasq pid-file to `/tmp/keel-state/` in the same iteration (edits `whitelist.sh`, `dnsmasq.conf`, `start-egress.sh`) — recorded in Change Log v1.? entry + Review Findings subsection.

- **SC-20 (AR-9 deferral explicit):** Story 2.5 CR-opener AR-9 (`/etc/resolv.conf` + `/etc/dnsmasq.conf` EACCES writes from reload-egress.sh + start-egress.sh under USER dev) is HIGHER severity than AR-7 — runtime egress init surface. Story 2.6 dev-agent MUST verify during AC 3 `pnpm devbox:start` smoke that the container boots WITHOUT `FATAL: cannot write /etc/resolv.conf`. IF that fatal surfaces, Story 2.6 escalates: add `RUN chown dev:dev /etc/resolv.conf /etc/dnsmasq.conf` to Dockerfile BEFORE `USER dev` directive (single-line fix; minimal blast radius). Document the Dockerfile edit in Change Log v1.? + Review Findings. IF `pnpm devbox:start` succeeds cleanly, AR-9 remains documented-only (add a line to `packages/devbox/README.md § Hardening § Known gaps` noting the `/etc/*` ownership dependency).

- **SC-21 (AR-10 absorption — operator-migration docs, ALWAYS in scope):** regardless of AR-7/AR-9 empirical outcomes, Story 2.6 ALWAYS adds the AR-10 pre-Story-2.5 named-volume migration documentation. Target: new H3 `### Operator migration (pre-Story-2.5 named-volume recovery)` under the existing `## Hardening (Story 2.5)` H2 in `packages/devbox/README.md`. Content:
  - Symptom detection: `docker volume inspect keel-devbox_keel_home_dev 2>/dev/null | jq -r '.[0].Options // "(none)"'` + `docker run --rm -v keel-devbox_keel_home_dev:/mnt alpine stat -c '%u:%g' /mnt` — if UID/GID is `0:0` (root) rather than `1000:1000` (dev), the volume was populated pre-Story-2.5 and Claude Code / gh writes will silently fail EACCES.
  - Recovery: `pnpm devbox:stop && docker volume rm keel-devbox_keel_home_dev && pnpm devbox:start` — the fresh volume auto-populates from the image layer under the Story 2.5 `dev:dev` ownership (non-interactive; tokens lost — operator re-runs `pnpm claude` + `pnpm gh:auth` from Stories 2.8/2.9).
  - Safety rail: **DO NOT run `docker volume rm` without `pnpm devbox:stop` first** — removing a mounted volume under the running container leaves daemon-state inconsistent.
  - Reference `INV-devbox-homedev-named-volume` (from `INVARIANTS.md` + `docs/invariants/devbox-hardening.md`) for the authoritative substrate rule.

- **SC-22 (AR-12 absorption — Compose project-name docs polish):** at the top of the `## Hardening (Story 2.5) § Verification` section AND at the top of `docs/invariants/devbox-hardening.md § Verification`, add a single-sentence qualifier:
  > **Note on compose-project-name overrides:** the verification commands below assume the pinned `name: keel-devbox` in `docker-compose.yml`. Operators who set `COMPOSE_PROJECT_NAME=<name>` or pass `-p <name>` to `docker compose` must substitute that project name in the volume FQN: `<name>_keel_home_dev` instead of `keel-devbox_keel_home_dev`. The substrate-authoritative named-volume contract (NFR10) is preserved regardless of project-name override — only the FQN prefix changes.

  Sync-gate: if this edit touches `docs/invariants/devbox-hardening.md`, follow the SC-17 three-step contentHash refresh protocol.

- **SC-23 (README documentation target — new H2 `## Host-side CLI (Story 2.6)`):** add a new H2 section to `packages/devbox/README.md` AFTER the existing `## Hardening (Story 2.5)` H2. Contents:
  - Summary: "Every devbox interaction is a `pnpm devbox:*` subcommand. Operators never type `docker`, `docker compose`, or `docker exec` directly (FR1, `architecture.md:74`)."
  - Subcommand table: 13 rows matching SC-2, columns = `Subcommand | Purpose | Exit codes`.
  - Exit-code table: reserved codes 0/2/3/4/5-7/8/9/10/11 with one-line descriptions (SC-5).
  - `.envrc` integration: one paragraph on env-check semantics + direnv expectation (SC-7 + SC-14).
  - Backend-B awareness: one paragraph on `clean.sh --with-volumes` + `--force-backend-b` gate (SC-11).
  - Operator-workstation verification recipes: same copy-paste-recipe format as Story 2.5's § Verification section (per Story 2.1 iter-127 + Story 2.5 iter-187 precedent). Smokes: `pnpm devbox:build` + `pnpm devbox:start` + `pnpm devbox:status` + `pnpm devbox:shell` + `pnpm devbox:stop` + `pnpm devbox:clean` end-to-end run.
  - Cross-reference the Story 2.4 `### Per-fork whitelist override (Story 2.4)` H3 for the `pnpm devbox:whitelist` operator surface.

- **SC-24 (AGENTS.md anchor — new H3 under `## Devbox iteration environment`):** add a new H3 `### Host-side CLI (Story 2.6)` to `AGENTS.md` AFTER the existing `### Container hardening (Story 2.5)` H3. Contents (terse bullets matching Story 2.4 + Story 2.5 AGENTS.md precedent — operational-only, no duplicate of README):
  - Canonical invocation surface: `pnpm devbox:<verb>` (13 verbs). Never `docker` / `docker compose` / `docker exec` directly.
  - `pnpm devbox:env:check` as the pre-flight for any devbox invocation; operators hit `.envrc` missing → `env-check` exits 2 with actionable list.
  - `pnpm devbox:clean` preserves `keel_home_dev` named volume (NFR10); `--with-volumes` gates on explicit confirmation + backend-B has an extra `--force-backend-b` gate.
  - Exit codes 8 (docker unreachable) / 9 (container not running) / 10 (image not built) / 11 (healthcheck timeout) — each one has a specific operator remediation hint printed to stderr.
  - Cross-reference § Per-fork whitelist override (Story 2.4) + § Container hardening (Story 2.5) for the upstream substrate contracts that Story 2.6 consumes.

- **SC-25 (no scope creep — boundaries):** Story 2.6 MUST NOT:
  - Touch Story 2.1's Dockerfile except the narrow AR-9 `chown /etc/*` fix IF SC-20 empirical escalation triggers.
  - Touch Story 2.3's `reload-egress.sh`, `start-egress.sh`, dnsmasq.conf (except AR-7 `/run` relocation IF SC-19 escalates).
  - Touch Story 2.4's `whitelist.sh` (in-container primitive — the host-side shim is the only Story 2.6 addition to the whitelist surface).
  - Touch Story 2.5's `USER dev`, `cap_drop/cap_add`, `security_opt`, tmpfs mounts, or the `keel_home_dev` named volume declaration.
  - Add healthcheck definitions to `docker-compose.yml` (Story 2.13 scope — Story 2.6 CONSUMES it via SC-9 poll).
  - Ship Ralph auto-start / TUI attach wiring (Story 2.7 scope — Story 2.6 ships `devbox:start` + `devbox:attach` as the primitives Story 2.7 composes).
  - Ship Claude Code / gh OAuth wrappers (Stories 2.8 / 2.9 — Story 2.6 ships `devbox:shell` as the primitive they compose on top of).
  - Ship prerequisite-check gating (Story 2.10 — Story 2.6's `env:check` is NARROW to `.envrc` + `KEEL_DEVBOX_*` envvar validation, not full host prereq check).
  - Introduce any new `INV-*` invariant (SC-17).

## Tasks / Subtasks

- [ ] **Task 1 — Pre-flight: map existing `packages/devbox/scripts/*.sh` vs Story 2.6 target names** (SC-2, SC-4, SC-15)
  - [ ] Subtask 1.1: `ls packages/devbox/scripts/*.sh` — record which target filenames (build/start/stop/restart/shell/attach/status/logs/clean/rebuild/monitor/env-check/whitelist-host) already exist. At drafting HEAD (2026-04-22), the following exist: `benchmark.sh`, `egress-log-tailer.sh`, `monitor.sh`, `reload-egress.sh`, `start-egress.sh`, `whitelist.sh`. The name collision risk is `monitor.sh` — resolve per SC-15 at Subtask 1.2.
  - [ ] Subtask 1.2: inspect the existing `packages/devbox/scripts/monitor.sh` — is it (a) an in-container tailer (precursor to the FR1a JSONL-monitor surface), (b) a host-side stub, or (c) not present at all (filename was reserved in the arch tree but not yet shipped)? Three decision paths:
    - (a) In-container tailer → rename to `packages/devbox/scripts/monitor-egress.sh` + update any entrypoint / docs / package.json references + create the new host-side `monitor.sh` shim.
    - (b) Host-side stub → replace contents with the proper host-side shim.
    - (c) Not present → create the host-side `monitor.sh` shim (net-new file).
  - [ ] Subtask 1.3: record the decision in Dev Agent Record § Debug Log References.
  - [ ] Subtask 1.4: regenerate the authoritative `KEEL_DEVBOX_*` required-var list at Story 2.6 impl time via `rg -N --no-heading 'KEEL_DEVBOX_[A-Z_]+' packages/devbox/ .envrc.example 2>/dev/null | grep -oE 'KEEL_DEVBOX_[A-Z_]+' | sort -u`. Compare against SC-14 seed list; drift is expected (Story 2.2 tmpfs-size knobs + Story 2.5 container-name + Story 2.6 healthcheck-timeout MUST all appear). Record the final list as a constant in `env-check.sh`.

- [ ] **Task 2 — Create 13 bash scripts under `packages/devbox/scripts/`** (SC-2, SC-4, SC-6, one file per verb; all AC)
  - [ ] Subtask 2.1: `build.sh` per SC-8.
  - [ ] Subtask 2.2: `rebuild.sh` per SC-8.
  - [ ] Subtask 2.3: `start.sh` per SC-9 (healthcheck poll loop + exit-code 8/10/11 semantics).
  - [ ] Subtask 2.4: `stop.sh` per SC-10.
  - [ ] Subtask 2.5: `restart.sh` per SC-10 (delegates to `stop.sh` + `start.sh` via `"${SCRIPT_DIR}/..."`).
  - [ ] Subtask 2.6: `clean.sh` per SC-11 (three-tier flag behavior + backend-B gate).
  - [ ] Subtask 2.7: `shell.sh` per SC-13 (docker exec -it --user dev -w /workspace … bash -l).
  - [ ] Subtask 2.8: `attach.sh` per SC-13 (docker attach --detach-keys=ctrl-p,ctrl-q).
  - [ ] Subtask 2.9: `status.sh` per SC-15 (compose ps + docker inspect health).
  - [ ] Subtask 2.10: `logs.sh` per SC-15 (compose logs -f --tail=100 + flag forwarding).
  - [ ] Subtask 2.11: `monitor.sh` (or `monitor-host.sh` per Subtask 1.2 decision) — host-side shim per SC-15 (docker exec into egress-log-tailer.sh or in-container monitor-egress.sh).
  - [ ] Subtask 2.12: `whitelist-host.sh` per SC-16 (thin `docker exec … whitelist.sh "$@"` shim).
  - [ ] Subtask 2.13: `env-check.sh` per SC-14 (parse .envrc + required-var presence + AR-11 shape validation for tmpfs-size ints).
  - [ ] Subtask 2.14: `chmod 0755` on every new script file.
  - [ ] Subtask 2.15: each script passes `bash -n <file>` (syntax check). Optional `shellcheck <file>` if available on operator workstation (no repo-wide shellcheck gate at 1.0 — matches Story 2.4 testing-standard precedent).

- [ ] **Task 3 — Wire 13 pnpm script entries into repo-root `package.json`** (AC 1, SC-3)
  - [ ] Subtask 3.1: edit `/workspace/ralph-bmad/.claude/worktrees/ralph/package.json` `"scripts"` block — insert the 13 `devbox:*` entries AFTER the `keel-invariants:*` block and BEFORE `"prepare"`.
  - [ ] Subtask 3.2: verify `pnpm <script-name>` works end-to-end for at least `devbox:env:check` (the only script that runs fully on the host without requiring docker). Expect exit 0 if `.envrc` present + required vars set, exit 2 with missing-var report otherwise.
  - [ ] Subtask 3.3: verify `pnpm <script-name>` for `devbox:build`, `devbox:status` — these are docker-operational but low-risk (build is idempotent; status is read-only). Operator-workstation-deferred if iteration env's docker backend cannot reach the image registry. Record outcome in Dev Agent Record.
  - [ ] Subtask 3.4: run `pnpm -w run format:check` + `pnpm -w run lint` to ensure package.json edit doesn't trip prettier/ESLint. `pnpm typecheck` unaffected (bash scripts not typechecked).

- [ ] **Task 4 — AR-10 operator-migration docs (pre-Story-2.5 named-volume recovery)** (SC-21)
  - [ ] Subtask 4.1: add new H3 `### Operator migration (pre-Story-2.5 named-volume recovery)` under `## Hardening (Story 2.5)` H2 in `packages/devbox/README.md` with the content prescribed in SC-21 (symptom detection + recovery + safety rail + invariant cross-ref).
  - [ ] Subtask 4.2: if Subtask 4.1 edits `docs/invariants/devbox-hardening.md` (OPTIONAL — only if the migration guidance is promoted to the invariant doc itself), run the SC-17 three-step contentHash sync-gate.

- [ ] **Task 5 — AR-12 docs polish (COMPOSE_PROJECT_NAME override note)** (SC-22)
  - [ ] Subtask 5.1: add the SC-22 single-sentence qualifier to `packages/devbox/README.md § Hardening § Verification`.
  - [ ] Subtask 5.2: add the same qualifier to `docs/invariants/devbox-hardening.md § Verification`.
  - [ ] Subtask 5.3: if Subtask 5.2 edits `docs/invariants/devbox-hardening.md`, run the SC-17 three-step contentHash sync-gate: `pnpm keel-invariants:check` (drift report) → update manifest → `pnpm --filter @keel/keel-invariants build` → `pnpm keel-invariants:check-all`.

- [ ] **Task 6 — README `## Host-side CLI (Story 2.6)` H2 section** (SC-23, AC 1)
  - [ ] Subtask 6.1: add new H2 section to `packages/devbox/README.md` AFTER `## Hardening (Story 2.5)` H2.
  - [ ] Subtask 6.2: include summary paragraph (FR1 citation) + 13-row subcommand table (Subcommand | Purpose | Exit codes) + exit-code table (0/2/3/4/5-7/8/9/10/11) + .envrc integration paragraph + backend-B awareness paragraph + operator-workstation verification recipes (Story 2.5 iter-187 precedent format).
  - [ ] Subtask 6.3: cross-reference the Story 2.4 whitelist H3 section for `devbox:whitelist` operator workflow.

- [ ] **Task 7 — AGENTS.md `### Host-side CLI (Story 2.6)` H3 anchor** (SC-24)
  - [ ] Subtask 7.1: insert new H3 under `## Devbox iteration environment`, AFTER the existing `### Container hardening (Story 2.5)` H3.
  - [ ] Subtask 7.2: terse bullets per SC-24 (pnpm is the only host surface, `env:check` pre-flight, `clean` named-volume gate, exit-code remediation hints, cross-references).
  - [ ] Subtask 7.3: do NOT duplicate the README content — AGENTS.md is operational-only.

- [ ] **Task 8 — Iteration-env-safe smokes (host-side script shape)** (AC 1, AC 8, Story 2.4 testing-approach precedent)
  - [ ] Subtask 8.1: `bash -n packages/devbox/scripts/<each-new>.sh` — syntax-valid for all 13 scripts.
  - [ ] Subtask 8.2: `pnpm devbox:env:check` with `.envrc` present → exit 0 (or 2 if `.envrc.example` is the only file and required vars missing). `pnpm devbox:env:check` with `.envrc` absent → exit 3 + `env-check: .envrc not found …` stderr.
  - [ ] Subtask 8.3: dispatcher-level smokes for any script that takes subcommands (currently only `whitelist-host.sh` which is passthrough and `clean.sh` which takes flags): invoke with no args → exit 2 + usage block; invoke with unknown flag → exit 2.
  - [ ] Subtask 8.4: compose-file-existence smoke: `test -f packages/devbox/docker-compose.yml` (trivial; guards against accidentally moving the compose file).
  - [ ] Subtask 8.5: root-level pnpm wiring smoke: `pnpm run` (no args) lists all 13 `devbox:*` scripts in the output. Captures absence regressions.
  - [ ] Subtask 8.6: record smokes as copy-paste recipes in `packages/devbox/README.md § Host-side CLI (Story 2.6) § Verification` (per SC-23 + Story 2.4 iter-174 precedent).

- [ ] **Task 9 — Operator-workstation full-lifecycle smoke (DEFERRED to operator — backend-B carve-out)** (AC 2, AC 3, AC 4, AC 5, AC 6, AC 7, SC-19, SC-20)
  - [ ] Subtask 9.1: record the smoke recipe as copy-paste in README:
    ```bash
    pnpm devbox:env:check          # expect exit 0
    pnpm devbox:build              # expect image 'keel-devbox:local' built
    pnpm devbox:start              # expect 'devbox: started (container keel-devbox)' + exit 0
    pnpm devbox:status             # expect container 'running' + healthcheck (if configured)
    pnpm devbox:shell -c 'whoami && pwd && id'  # expect 'dev', '/workspace', 'uid=1000(dev) gid=1000(dev) …'
    pnpm devbox:logs --no-follow --tail=50       # expect recent container logs
    pnpm devbox:whitelist list                    # expect composed whitelist with source prefixes
    pnpm devbox:stop               # expect container stopped, volume preserved
    pnpm devbox:start              # expect idempotent re-start
    pnpm devbox:clean              # expect container + image removed, volume preserved
    docker volume inspect keel-devbox_keel_home_dev >/dev/null && echo "volume preserved ✓"
    pnpm devbox:clean --with-volumes  # expect y/N prompt; answer N → no-op
    ```
  - [ ] Subtask 9.2: verify on M4-Pro native Docker Desktop (operator-workstation); DinD backend B in cc-devbox iteration env cannot safely exercise this (Story 2.5 iter-187 + Story 2.4 iter-174 precedent).
  - [ ] Subtask 9.3: if any of Subtask 9.1's steps surface `/run/*: Permission denied` or `/etc/resolv.conf: EACCES`, trigger SC-19 / SC-20 escalation paths in the SAME iteration (do not defer to a follow-on story).

- [ ] **Task 10 — Final quality gates + sprint-status flip** (Story 2.4 iter-174 precedent)
  - [ ] Subtask 10.1: `pnpm -w run format:check` → clean.
  - [ ] Subtask 10.2: `pnpm -w run lint` → clean for JS/TS (bash not linted at 1.0).
  - [ ] Subtask 10.3: `pnpm --filter @keel/devbox typecheck` → clean (bash additions don't affect tsc).
  - [ ] Subtask 10.4: `pnpm keel-invariants:check-all` → exit 0. If SC-17 sync-gate fired (Tasks 4–5 docs-invariant edits), confirm contentHash is in sync.
  - [ ] Subtask 10.5: `docker compose -f packages/devbox/docker-compose.yml config --quiet` → exit 0 (parse-smoke; Story 2.5 iter-187 precedent; the compose file is untouched at Story 2.6, but the parse-smoke detects any transitive-env-var breakage).
  - [ ] Subtask 10.6: update sprint-status.yaml: `development_status["2-6-host-side-pnpm-devbox-cli-surface"]` flip `backlog → ready-for-dev` (or `in-progress` → `review` at dev-story commit time, etc. per lifecycle state).
  - [ ] Subtask 10.7: update Dev Agent Record + File List + Completion Notes.

## Dev Notes

### Architectural anchors

- **FR1 (PRD `prd.md:927`):** "Developer can manage devbox lifecycle (start, stop, shell, attach) via pnpm-exposed commands." This story is the direct realisation of FR1's host-side surface contract.
- **FR1a (PRD `prd.md:933`):** egress policy + structured JSONL query log + `pnpm devbox:whitelist`-manageable allow-list. Story 2.6's host-side `devbox:whitelist` + `devbox:monitor` shims expose FR1a's substrate (delivered by Stories 2.3 + 2.4) at the operator CLI.
- **Architectural rule (PRD `prd.md:477`):** *"Every host-side command is invoked as `pnpm <subcommand>`. The `package.json` scripts manage devbox lifecycle and forward to container-native commands. Ralph itself is a Python Textual TUI running inside the devbox; users attach to it via `pnpm ralph:*` but never invoke Python directly on the host."* Story 2.6's scripts are the `pnpm`-to-`docker` translation layer.
- **Architecture § Devbox Package Tree (`architecture.md:975-1004`):** commits to one `.sh` file per verb under `packages/devbox/scripts/`. Story 2.6 adds 13 files matching this tree.
- **M0.5 (e) lifecycle bridge (PRD `prd.md:172`):** upstream Makefile targets `build`, `start`, `stop`, `restart`, `shell`, `status`, `logs`, `clean`, `rebuild`, `whitelist`, `monitor` — re-exposed as `pnpm devbox:*`. The epics-stories layer adds `attach`, `env:check` (total 13).
- **PRD § CLI-Tool Surface (`prd.md:488-494`):** pins naming (`pnpm devbox:start / stop / shell`, `pnpm devbox:build / rebuild / clean / status / logs`, `pnpm devbox:attach`, `pnpm devbox:whitelist <add|remove|list|sync>`, `pnpm devbox:monitor`).

### Story 2.4 whitelist.sh precedent — copy patterns verbatim

Story 2.4's `packages/devbox/scripts/whitelist.sh` is the **canonical Story 2.6 template**. Every new script header + `log()` helper + `usage()` block + main-guard dispatcher follows that shape.

- Banner + `#!/usr/bin/env bash` + `set -euo pipefail` (`whitelist.sh:1-35`).
- Self-rooted paths (`whitelist.sh:37-40`).
- `log()` at `whitelist.sh:56`.
- `usage()` heredoc at `whitelist.sh:58-73` + exit 2.
- Main-guard + dispatcher at `whitelist.sh:468-487`.
- Fail-closed discipline: `set -e` propagation; no `2>/dev/null || true` silent-swallow (Story 2.4 iter-180 AI-3 drain lesson).
- Atomic-writes: tempfile-adjacent-to-target + `mv` (Story 2.4 iter-178 AI-1 drain lesson — cross-fs `mv` fails; tempfile must live on the SAME filesystem as destination).
- `mktemp` not `$$` for predictable-tempfile safety (Story 2.4 iter-181 AI-4 drain lesson).
- Explicit `|| rc=$?` rc-capture when distinguishing expected-nonzero from error (Story 2.4 iter-179 AI-2 drain lesson).

**Story 2.6 host-side scripts differ from Story 2.4's in-container posture in one critical way:** they invoke `docker` / `docker compose` / `docker exec`, which means they need the host-side docker runtime. Add the SC-5 exit code 8 (`docker unreachable`) pre-flight to every script that talks to docker.

### Story 2.5 hardening posture — what Story 2.6 must respect

From `_bmad-output/implementation-artifacts/2-5-…named-volume.md` + `docs/invariants/devbox-hardening.md` + `INV-devbox-homedev-named-volume`:

- **Container user:** `dev` UID/GID 1000. All `docker exec` invocations use `--user dev` unless root is explicitly required (Story 2.6 has NO root-required paths — even AR-9 `/etc/*` chown is a Dockerfile-time operation, not runtime).
- **Capability bounding set:** `cap_drop: [ALL]` + `cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE]`. Scripts MUST NOT attempt operations requiring other caps (CHOWN, DAC_OVERRIDE, SETUID, etc.) inside the container.
- **`no-new-privileges: true`:** `setuid`/`setgid` elevations fail. Scripts MUST NOT invoke `sudo` or any suid binary.
- **tmpfs `/tmp` + `/var/tmp` with `noexec,nosuid`:** scripts CANNOT `chmod +x` a file under `/tmp` and then execute it (kernel blocks). Host-side Story 2.6 scripts are NOT affected (they run on the host's filesystem; only in-container scripts that write to /tmp are affected).
- **Named volume `keel_home_dev` for `/home/dev` — NON-TOGGLE-ABLE:** NFR10 substrate-authoritative. Story 2.6 `clean` preserves this by default; `--with-volumes` gates destruction on explicit y/N prompt + backend-B flag gate.

### Backend-B destructive-op discipline (`docs/invariants/devbox-dind.md`)

The cc-devbox iteration environment uses backend B (host docker socket passthrough). Broad destructive-op scripts (`docker system prune`, `docker volume prune`, `docker image prune -a`, `docker rm -f $(docker ps -aq)`) destroy host-wide state.

Story 2.6 scripts that MIGHT prune:
- `clean.sh` (default): scoped `docker compose down --rmi local --remove-orphans` — safe under either backend.
- `clean.sh --with-volumes`: destroys `keel_home_dev` volume ONLY; requires `--force-backend-b` acknowledgement under backend B detection.
- `clean.sh --allow-broad-prune`: RESERVED flag; no-op at 1.0. Broad-prune lands at a later story.
- `rebuild.sh`: `docker compose build --no-cache` — invalidates cache for the `keel-devbox` service only, not host-wide.

`benchmark.sh` is the backend-B-detection reference implementation (`devbox-dind.md:47`). Copy its `docker info --format '{{.Name}}'` + `/.dockerenv` posture.

### Compose project-name pin + volume FQN awareness

`packages/devbox/docker-compose.yml:43` → `name: keel-devbox`. Volume FQN = `keel-devbox_keel_home_dev`. Story 2.5 iter-194 AI-3 drain landed this pin.

Operators who override via `COMPOSE_PROJECT_NAME=<name>` or `-p <name>` drift the FQN prefix. Story 2.6 scripts honor the pinned name (SC-6); SC-22 adds docs polish acknowledging the override path.

### File List targets (for Dev Agent Record at impl-time)

New files (13 scripts + possibly 1 rename):
- `packages/devbox/scripts/build.sh` (NEW)
- `packages/devbox/scripts/rebuild.sh` (NEW)
- `packages/devbox/scripts/start.sh` (NEW)
- `packages/devbox/scripts/stop.sh` (NEW)
- `packages/devbox/scripts/restart.sh` (NEW)
- `packages/devbox/scripts/clean.sh` (NEW)
- `packages/devbox/scripts/shell.sh` (NEW)
- `packages/devbox/scripts/attach.sh` (NEW)
- `packages/devbox/scripts/status.sh` (NEW)
- `packages/devbox/scripts/logs.sh` (NEW)
- `packages/devbox/scripts/monitor.sh` OR `packages/devbox/scripts/monitor-host.sh` (NEW; Task 1.2 decision)
- `packages/devbox/scripts/whitelist-host.sh` (NEW)
- `packages/devbox/scripts/env-check.sh` (NEW)
- (optional) `packages/devbox/scripts/monitor-egress.sh` (RENAMED from existing `monitor.sh` per Task 1.2 decision (a))

Modified files:
- `/workspace/ralph-bmad/.claude/worktrees/ralph/package.json` — 13 new `devbox:*` script entries (SC-3).
- `packages/devbox/README.md` — new H3 § Operator migration (SC-21) + AR-12 qualifier at existing § Verification (SC-22) + new H2 § Host-side CLI (Story 2.6) (SC-23).
- `AGENTS.md` — new H3 § Host-side CLI (Story 2.6) (SC-24).
- (conditional) `docs/invariants/devbox-hardening.md` — AR-12 qualifier at § Verification (SC-22) + contentHash refresh via SC-17 sync-gate if touched.
- (conditional) `packages/keel-invariants/src/invariants.manifest.ts` — `INV-devbox-homedev-named-volume` contentHash refresh if SC-17 sync-gate fires.
- (conditional — SC-19 escalation) `packages/devbox/dnsmasq/dnsmasq.conf`, `packages/devbox/scripts/start-egress.sh`, `packages/devbox/scripts/whitelist.sh` — `/run` relocation to `/tmp/keel-state/` IF AR-7 surfaces.
- (conditional — SC-20 escalation) `packages/devbox/Dockerfile` — `RUN chown dev:dev /etc/resolv.conf /etc/dnsmasq.conf` before `USER dev` IF AR-9 surfaces.

### Project Structure Notes

**Alignment with unified project structure:**
- Script-file shape + naming (`.sh`, `0755`, kebab-case) matches Story 2.1 `benchmark.sh` + Story 2.3 `reload-egress.sh`/`start-egress.sh`/`egress-log-tailer.sh` + Story 2.4 `whitelist.sh` precedent.
- pnpm script naming (`devbox:*` with `env:check` double-colon) matches PRD § CLI-Tool Surface + architecture § Devbox Package Tree.
- Docs split across README (narrative + recipes, SC-23) + AGENTS.md (operational, SC-24) matches Story 2.4 / Story 2.5 three-surface precedent.

**Detected conflicts or variances:**
- Existing `packages/devbox/scripts/monitor.sh` filename collision with Story 2.6 target host-side `monitor.sh` — resolved at Task 1.2 (rename in-container tailer OR suffix host-side shim with `-host`).
- Repo-root `package.json` has NO existing `devbox:*` scripts (SC-3 is a net-new block); no merge-conflict risk.
- `.envrc.example` + `.envrc` — Story 2.2 contract. Story 2.6 `env-check` parses `.envrc` only (`.envrc.example` is a template reference, not runtime). If operator hasn't copied `.envrc.example → .envrc`, env-check emits exit 3 + copy-pointer message.

### References

- Epics source: `_bmad-output/planning-artifacts/epics.md:1336-1382` (Story 2.6 verbatim block); `epics.md:1142` (Epic 2 header); cross-story dependencies lines 1181, 1190, 1219, 1394, 1522, 1580.
- PRD: `_bmad-output/planning-artifacts/prd.md:927` (FR1), `:933` (FR1a), `:477` (architectural rule), `:488-494` (CLI-Tool Surface), `:172` (M0.5 e lifecycle bridge), `:538-562` (Devbox Implementation Contract § Lifecycle scripts).
- Architecture: `_bmad-output/planning-artifacts/architecture.md:74` (host-surface rule), `:152` (Turborepo), `:158` (`pnpm devbox:shell`), `:304` (`env_file: ../../.envrc`), `:335` (names-only env-check), `:975-1004` (Devbox Package Tree), `:1283` (Vite HMR via `pnpm devbox:shell`).
- Story 2.4 (canonical CLI template): `_bmad-output/implementation-artifacts/2-4-whitelist-source-of-truth-pnpm-devbox-whitelist-atomic-reload-cli.md` — SC-11 exit codes, SC-12 scope boundary, SC-13 script shape, SC-16 in-container locus, Tasks 1-7 subtask decomposition pattern.
- Story 2.5: `_bmad-output/implementation-artifacts/2-5-container-hardening-non-root-user-capabilities-tmpfs-noexec-named-volume.md` — § Review Findings AR-7..AR-12 (Story 2.6 absorbs AR-10 + AR-11 + AR-12 unconditionally; AR-7 + AR-9 conditional on operator-workstation smoke outcome).
- Invariants: `INVARIANTS.md` lines 90-106 (devbox-trio); `docs/invariants/devbox-dind.md` (backend-B detection); `docs/invariants/devbox-egress-contract.md` (consumed via `whitelist-host.sh` + `monitor.sh`); `docs/invariants/devbox-hardening.md` (SC-17 sync-gate target if edited; SC-22 AR-12 docs polish target).
- Manifest: `packages/keel-invariants/src/invariants.manifest.ts` — `INV-devbox-homedev-named-volume` contentHash `f34cb62feea03eb0d3ef80d29221fc85fa1d1ee3ba01e7e26ef06ee5c9715a5e` (Story 2.5 v1.8 drain landing; SC-17 sync-gate refresh target if SC-22 touches the invariant doc).
- Canonical reference implementation to copy patterns from: `packages/devbox/scripts/whitelist.sh` (488 lines; SC-4 script shape, SC-5 exit codes, main-guard dispatcher).
- Backend-B detection reference: `packages/devbox/scripts/benchmark.sh` (`devbox-dind.md:47`).
- Compose file: `packages/devbox/docker-compose.yml` — `name: keel-devbox` at line 43; `container_name: ${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}` at line 56; `env_file: ../../.envrc`.
- Repo-root target for SC-3 pnpm entries: `/workspace/ralph-bmad/.claude/worktrees/ralph/package.json:9-22` `"scripts"` block.
- Ralph coupling: `.ralph/@plan.md:7` pins Story 2.6 as the next-up queue head with AR-7 / AR-9 / AR-10 / AR-11 / AR-12 scope-owner duties.

## Dev Agent Record

### Agent Model Used

claude-opus-4-7[1m] (Ralph build-mode drafting context)

### Debug Log References

_(populated by dev-story iteration)_

### Completion Notes List

_(populated by dev-story iteration)_

### File List

_(populated by dev-story iteration — see Dev Notes § File List targets for expected surface)_

## Change Log

| Version | Date | Iter | Who | Change |
| --- | --- | --- | --- | --- |
| v0.1 | 2026-04-22 | iter-198 | Ralph (create-story) | Initial draft — 13-verb host-side CLI surface, 25 scope clarifications, 10 tasks. Absorbs Story 2.5 CR DEFERs AR-10 (unconditional) + AR-11 (env-check shape validation, unconditional) + AR-12 (compose-project-name docs polish, unconditional); AR-7 `/run` relocation + AR-9 `/etc/*` chown conditional on operator-workstation smoke outcome per SC-19 + SC-20. Status drafted (sprint-status `backlog → ready-for-dev`). |
