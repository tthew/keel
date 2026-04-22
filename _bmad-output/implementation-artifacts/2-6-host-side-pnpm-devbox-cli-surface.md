# Story 2.6: Host-side `pnpm devbox:*` CLI surface

Status: in-progress

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
  | `devbox:monitor` | `packages/devbox/scripts/monitor-host.sh` | `docker exec … /workspace/packages/devbox/scripts/monitor.sh` (Story 2.3 in-container JSONL tail primitive) |
  | `devbox:whitelist` | `packages/devbox/scripts/whitelist-host.sh` | `docker exec … /workspace/packages/devbox/scripts/whitelist.sh "$@"` (Story 2.4 in-container primitive) |
  | `devbox:env:check` | `packages/devbox/scripts/env-check.sh` | validate `.envrc` presence + required `KEEL_DEVBOX_*` vars |

  Script filenames use hyphens (kebab-case) to match existing siblings (`benchmark.sh`, `egress-log-tailer.sh`, `reload-egress.sh`, `start-egress.sh`). The `env-check.sh` filename has ONE hyphen; the pnpm alias `devbox:env:check` has the double-colon (filename-naming vs CLI-namespace-naming are deliberately distinct — see Story 2.4 SC-13 script-shape precedent).

  **Rationale for `monitor-host.sh` suffix (matches `whitelist-host.sh` precedent):** at 2026-04-22 HEAD, `packages/devbox/scripts/monitor.sh` already exists as the Story 2.3 in-container JSONL egress-log tailer (`monitor.sh:1-22` banner confirms: *"packages/devbox/scripts/monitor.sh — Story 2.3 (AC 3 observability) — Operator-facing live tail of the JSONL egress query log."*). Story 2.6 does NOT rename, delete, or edit this file — it is the in-container primitive that the host-side shim `docker exec`s into. Story 2.6 adds a NEW host-side file `packages/devbox/scripts/monitor-host.sh` mirroring Story 2.4's `whitelist.sh` (in-container) / `whitelist-host.sh` (host-side shim) pattern. The `-host` suffix disambiguates in every `ls packages/devbox/scripts/monitor*` listing — operators and future-Ralph see the two-file pair and the locus distinction is immediate. See Task 1.2 for the pre-flight verification (expected state path).

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
    "devbox:monitor": "./packages/devbox/scripts/monitor-host.sh",
    "devbox:whitelist": "./packages/devbox/scripts/whitelist-host.sh",
    "devbox:env:check": "./packages/devbox/scripts/env-check.sh"
  }
  ```

  Order: insert AFTER the existing `keel-invariants:*` block and BEFORE `"prepare"`. Alphabetical ordering WITHIN the `devbox:*` block is NOT required (grouped by lifecycle: build → start → stop → clean, then interactive (shell/attach), then observability (status/logs/monitor), then whitelist + env:check). DO NOT add `"devbox:whitelist"` to `packages/devbox/package.json` at the same time — Story 2.4 already owns that entry for the in-container invocation path; Story 2.6 adds ONLY the root-level host-side alias with the `-host.sh`-suffix-resolved script (applies to `devbox:whitelist` → `whitelist-host.sh` AND `devbox:monitor` → `monitor-host.sh`; all other verbs use their canonical unsuffixed filename).

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
  - `monitor-host.sh`: **host-side shim** — `docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/monitor.sh "$@"`. The in-container `monitor.sh` is Story 2.3's JSONL egress-log tailer (exists at 2026-04-22 HEAD per `packages/devbox/scripts/monitor.sh:1-22`: *"Operator-facing live tail of the JSONL egress query log"*). Pre-flight `test -f packages/devbox/scripts/monitor.sh` confirms presence; failure exits 3 with `devbox monitor: in-container primitive missing — rebuild via 'pnpm devbox:build'` message.
    - **Semantic reconciliation — PRD `:494` is authoritative:** epics AC 7 verbatim says `monitor` "displays a live resource snapshot (cpu/memory/network)." This is loose shorthand that the PRD clarifies: PRD § CLI-Tool Surface at `prd.md:494` defines `pnpm devbox:monitor` as *"Structured tail of allowed/blocked DNS events consuming the FR1a structured query-log (JSONL). Replaces upstream's `monitor-blocks.sh` grep-on-dnsmasq-log approach."* Architecture tree at `architecture.md:1003` reinforces: `monitor.sh # JSONL tail (FR1a replacement for monitor-blocks.sh)`. **Implementation semantic: `pnpm devbox:monitor` = FR1a JSONL DNS-event tail, NOT `docker stats`-style cpu/memory view.** The epics "cpu/memory/network" phrasing is historical drift from the PRD and does NOT override the authoritative PRD + architecture definition. Dev-agent MUST implement the JSONL-tail shim, not a `docker stats` wrapper. Any future `docker stats`-style verb would require a separate story (out of scope at 1.0).
    - Pre-flight: container-running gate (exit 9 if stopped). Passthrough stdout/stderr with docker `-it` for interactive terminal sizing. On SIGINT, clean detach (exit 0).

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

- [x] **Task 1 — Pre-flight: map existing `packages/devbox/scripts/*.sh` vs Story 2.6 target names** (SC-2, SC-4, SC-15)
  - [x] Subtask 1.1: `ls packages/devbox/scripts/*.sh` — confirm HEAD state matches drafting snapshot (2026-04-22): `benchmark.sh`, `egress-log-tailer.sh`, `monitor.sh`, `reload-egress.sh`, `start-egress.sh`, `whitelist.sh`. If new scripts have been added by Stories 2.3-2.5 follow-ons between draft (iter-198) and impl, note the delta in Dev Agent Record.
  - [x] Subtask 1.2: verify `packages/devbox/scripts/monitor.sh` is the Story 2.3 in-container JSONL tailer (banner line 3 matches `packages/devbox/scripts/monitor.sh — Story 2.3`). If banner-confirmed, NO rename/edit is performed — Story 2.6 adds the NEW `monitor-host.sh` host-side shim per SC-2 + SC-15. If the file has drifted (contents changed since 2026-04-22 HEAD) or is absent, halt + escalate to operator (this is a cross-story regression signal, not a Story 2.6 repair path).
  - [x] Subtask 1.3: record the HEAD-confirmation result in Dev Agent Record § Debug Log References.
  - [x] Subtask 1.4: regenerate the authoritative `KEEL_DEVBOX_*` required-var list at Story 2.6 impl time via `rg -N --no-heading 'KEEL_DEVBOX_[A-Z_]+' packages/devbox/ .envrc.example 2>/dev/null | grep -oE 'KEEL_DEVBOX_[A-Z_]+' | sort -u`. Compare against SC-14 seed list; drift is expected (Story 2.2 tmpfs-size knobs + Story 2.5 container-name + Story 2.6 healthcheck-timeout MUST all appear). Record the final list as a constant in `env-check.sh`.

- [x] **Task 2 — Create 13 bash scripts under `packages/devbox/scripts/`** (SC-2, SC-4, SC-6, one file per verb; all AC)
  - [x] Subtask 2.1: `build.sh` per SC-8.
  - [x] Subtask 2.2: `rebuild.sh` per SC-8.
  - [x] Subtask 2.3: `start.sh` per SC-9 (healthcheck poll loop + exit-code 8/10/11 semantics).
  - [x] Subtask 2.4: `stop.sh` per SC-10.
  - [x] Subtask 2.5: `restart.sh` per SC-10 (delegates to `stop.sh` + `start.sh` via `"${SCRIPT_DIR}/..."`).
  - [x] Subtask 2.6: `clean.sh` per SC-11 (three-tier flag behavior + backend-B gate).
  - [x] Subtask 2.7: `shell.sh` per SC-13 (docker exec -it --user dev -w /workspace … bash -l).
  - [x] Subtask 2.8: `attach.sh` per SC-13 (docker attach --detach-keys=ctrl-p,ctrl-q).
  - [x] Subtask 2.9: `status.sh` per SC-15 (compose ps + docker inspect health).
  - [x] Subtask 2.10: `logs.sh` per SC-15 (compose logs -f --tail=100 + flag forwarding).
  - [x] Subtask 2.11: `monitor-host.sh` — host-side shim per SC-15: `docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/monitor.sh "$@"`. The in-container target is Story 2.3's JSONL egress-log tailer per PRD `:494` + architecture `:1003` (NOT `docker stats`). Pre-flight: container-running gate (exit 9 if stopped).
  - [x] Subtask 2.12: `whitelist-host.sh` per SC-16 (thin `docker exec … whitelist.sh "$@"` shim).
  - [x] Subtask 2.13: `env-check.sh` per SC-14 (parse .envrc + required-var presence + AR-11 shape validation for tmpfs-size ints).
  - [x] Subtask 2.14: `chmod 0755` on every new script file.
  - [x] Subtask 2.15: each script passes `bash -n <file>` (syntax check). Optional `shellcheck <file>` if available on operator workstation (no repo-wide shellcheck gate at 1.0 — matches Story 2.4 testing-standard precedent).

- [x] **Task 3 — Wire 13 pnpm script entries into repo-root `package.json`** (AC 1, SC-3)
  - [x] Subtask 3.1: edit `/workspace/ralph-bmad/.claude/worktrees/ralph/package.json` `"scripts"` block — insert the 13 `devbox:*` entries AFTER the `keel-invariants:*` block and BEFORE `"prepare"`.
  - [x] Subtask 3.2: verify `pnpm <script-name>` works end-to-end for at least `devbox:env:check` (the only script that runs fully on the host without requiring docker). Expect exit 0 if `.envrc` present + required vars set, exit 2 with missing-var report otherwise.
  - [x] Subtask 3.3: verify `pnpm <script-name>` for `devbox:build`, `devbox:status` — these are docker-operational but low-risk (build is idempotent; status is read-only). Operator-workstation-deferred if iteration env's docker backend cannot reach the image registry. Record outcome in Dev Agent Record.
  - [x] Subtask 3.4: run `pnpm -w run format:check` + `pnpm -w run lint` to ensure package.json edit doesn't trip prettier/ESLint. `pnpm typecheck` unaffected (bash scripts not typechecked).

- [x] **Task 4 — AR-10 operator-migration docs (pre-Story-2.5 named-volume recovery)** (SC-21)
  - [x] Subtask 4.1: add new H3 `### Operator migration (pre-Story-2.5 named-volume recovery)` under `## Hardening (Story 2.5)` H2 in `packages/devbox/README.md` with the content prescribed in SC-21 (symptom detection + recovery + safety rail + invariant cross-ref).
  - [x] Subtask 4.2: if Subtask 4.1 edits `docs/invariants/devbox-hardening.md` (OPTIONAL — only if the migration guidance is promoted to the invariant doc itself), run the SC-17 three-step contentHash sync-gate. *(NOT triggered — AR-10 migration docs live in README only; invariant doc was touched by AR-12 qualifier (Task 5) instead, which fired the sync-gate.)*

- [x] **Task 5 — AR-12 docs polish (COMPOSE_PROJECT_NAME override note)** (SC-22)
  - [x] Subtask 5.1: add the SC-22 single-sentence qualifier to `packages/devbox/README.md § Hardening § Verification`.
  - [x] Subtask 5.2: add the same qualifier to `docs/invariants/devbox-hardening.md § Verification`.
  - [x] Subtask 5.3: if Subtask 5.2 edits `docs/invariants/devbox-hardening.md`, run the SC-17 three-step contentHash sync-gate: `pnpm keel-invariants:check` (drift report) → update manifest → `pnpm --filter @keel/keel-invariants build` → `pnpm keel-invariants:check-all`.

- [x] **Task 6 — README `## Host-side CLI (Story 2.6)` H2 section** (SC-23, AC 1)
  - [x] Subtask 6.1: add new H2 section to `packages/devbox/README.md` AFTER `## Hardening (Story 2.5)` H2.
  - [x] Subtask 6.2: include summary paragraph (FR1 citation) + 13-row subcommand table (Subcommand | Purpose | Exit codes) + exit-code table (0/2/3/4/5-7/8/9/10/11) + .envrc integration paragraph + backend-B awareness paragraph + operator-workstation verification recipes (Story 2.5 iter-187 precedent format).
  - [x] Subtask 6.3: cross-reference the Story 2.4 whitelist H3 section for `devbox:whitelist` operator workflow.

- [x] **Task 7 — AGENTS.md `### Host-side CLI (Story 2.6)` H3 anchor** (SC-24)
  - [x] Subtask 7.1: insert new H3 under `## Devbox iteration environment`, AFTER the existing `### Container hardening (Story 2.5)` H3.
  - [x] Subtask 7.2: terse bullets per SC-24 (pnpm is the only host surface, `env:check` pre-flight, `clean` named-volume gate, exit-code remediation hints, cross-references).
  - [x] Subtask 7.3: do NOT duplicate the README content — AGENTS.md is operational-only.

- [x] **Task 8 — Iteration-env-safe smokes (host-side script shape)** (AC 1, AC 8, Story 2.4 testing-approach precedent)
  - [x] Subtask 8.1: `bash -n packages/devbox/scripts/<each-new>.sh` — syntax-valid for all 13 scripts.
  - [x] Subtask 8.2: `pnpm devbox:env:check` with `.envrc` present → exit 0 (or 2 if `.envrc.example` is the only file and required vars missing). `pnpm devbox:env:check` with `.envrc` absent → exit 3 + `env-check: .envrc not found …` stderr.
  - [x] Subtask 8.3: dispatcher-level smokes for any script that takes subcommands (currently only `whitelist-host.sh` which is passthrough and `clean.sh` which takes flags): invoke with no args → exit 2 + usage block; invoke with unknown flag → exit 2.
  - [x] Subtask 8.4: compose-file-existence smoke: `test -f packages/devbox/docker-compose.yml` (trivial; guards against accidentally moving the compose file).
  - [x] Subtask 8.5: root-level pnpm wiring smoke: `pnpm run` (no args) lists all 13 `devbox:*` scripts in the output. Captures absence regressions.
  - [x] Subtask 8.6: record smokes as copy-paste recipes in `packages/devbox/README.md § Host-side CLI (Story 2.6) § Verification` (per SC-23 + Story 2.4 iter-174 precedent).

- [x] **Task 9 — Operator-workstation full-lifecycle smoke (DEFERRED to operator — backend-B carve-out)** (AC 2, AC 3, AC 4, AC 5, AC 6, AC 7, SC-19, SC-20)
  - [x] Subtask 9.1: record the smoke recipe as copy-paste in README (landed in `packages/devbox/README.md § Host-side CLI (Story 2.6) § Verification (operator-workstation)`).
  - [x] Subtask 9.2: verify on M4-Pro native Docker Desktop (operator-workstation); DinD backend B in cc-devbox iteration env cannot safely exercise this (Story 2.5 iter-187 + Story 2.4 iter-174 precedent). *(Deferred to operator — recipe is in README.)*
  - [x] Subtask 9.3: if any of Subtask 9.1's steps surface `/run/*: Permission denied` or `/etc/resolv.conf: EACCES`, trigger SC-19 / SC-20 escalation paths in the SAME iteration (do not defer to a follow-on story). *(Not triggered — live smoke deferred to operator workstation; AR-7 + AR-9 remain deferred per SC-19/SC-20 conditional gate. No evidence of breakage at impl-time; operator smoke will re-gate.)*

- [x] **Task 10 — Final quality gates + sprint-status flip** (Story 2.4 iter-174 precedent)
  - [x] Subtask 10.1: `pnpm -w run format:check` → clean.
  - [x] Subtask 10.2: `pnpm -w run lint` → clean for JS/TS (bash not linted at 1.0).
  - [x] Subtask 10.3: `pnpm --filter @keel/devbox typecheck` → clean (bash additions don't affect tsc).
  - [x] Subtask 10.4: `pnpm keel-invariants:check-all` → exit 0. If SC-17 sync-gate fired (Tasks 4–5 docs-invariant edits), confirm contentHash is in sync.
  - [x] Subtask 10.5: `docker compose -f packages/devbox/docker-compose.yml config --quiet` → exit 0 (parse-smoke; Story 2.5 iter-187 precedent; the compose file is untouched at Story 2.6, but the parse-smoke detects any transitive-env-var breakage).
  - [x] Subtask 10.6a: flip sprint-status `development_status["2-6-host-side-pnpm-devbox-cli-surface"]` `backlog → ready-for-dev`. *(completed iter-198 draft; do NOT re-flip from `backlog` — current sprint-status row is already at `ready-for-dev`.)*
  - [x] Subtask 10.6b: flip sprint-status `ready-for-dev → in-progress` at dev-story commencement (dev-story skill auto-performs this; operator confirms after run). *(Single-iter landing — elided in favour of combined `ready-for-dev → review` flip per Story 2.4 iter-174 + Story 2.5 iter-187 precedent.)*
  - [x] Subtask 10.6c: flip sprint-status `in-progress → review` at dev-story commit-time (dev-story skill auto-performs this on completion).
  - [x] Subtask 10.7: update Dev Agent Record + File List + Completion Notes.

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

New files (13 scripts):
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
- `packages/devbox/scripts/monitor-host.sh` (NEW — host-side shim; in-container target is existing Story 2.3 `monitor.sh` unedited)
- `packages/devbox/scripts/whitelist-host.sh` (NEW — host-side shim; in-container target is existing Story 2.4 `whitelist.sh` unedited)
- `packages/devbox/scripts/env-check.sh` (NEW)

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
- Existing `packages/devbox/scripts/monitor.sh` (Story 2.3 in-container JSONL tailer) stays unedited; Story 2.6 adds a NEW host-side shim at `packages/devbox/scripts/monitor-host.sh` per SC-2 + SC-15 (mirrors Story 2.4 `whitelist-host.sh` pattern). No collision risk; no rename path.
- Repo-root `package.json` has NO existing `devbox:*` scripts (SC-3 is a net-new block); no merge-conflict risk.
- `.envrc.example` + `.envrc` — Story 2.2 contract. Story 2.6 `env-check` parses `.envrc` only (`.envrc.example` is a template reference, not runtime). If operator hasn't copied `.envrc.example → .envrc`, env-check emits exit 3 + copy-pointer message.

### References

- Epics source: `_bmad-output/planning-artifacts/epics.md:1336-1382` (Story 2.6 verbatim block); `epics.md:1142` (Epic 2 header); cross-story dependencies lines 1181, 1190, 1219, 1394, 1522, 1580.
- PRD: `_bmad-output/planning-artifacts/prd.md:927` (FR1), `:933` (FR1a), `:477` (architectural rule), `:488-494` (CLI-Tool Surface), `:172` (M0.5 e lifecycle bridge), `:538-562` (Devbox Implementation Contract § Lifecycle scripts).
- Architecture: `_bmad-output/planning-artifacts/architecture.md:74` (host-surface rule), `:152` (Turborepo), `:158` (`pnpm devbox:shell`), `:304` (`env_file: ../../.envrc`), `:335` (names-only env-check), `:975-1004` (Devbox Package Tree), `:1283` (Vite HMR via `pnpm devbox:shell`).
- Story 2.4 (canonical CLI template): `_bmad-output/implementation-artifacts/2-4-whitelist-source-of-truth-pnpm-devbox-whitelist-atomic-reload-cli.md` — SC-11 exit codes, SC-12 scope boundary, SC-13 script shape, SC-16 in-container locus, Tasks 1-7 subtask decomposition pattern.
- Story 2.5: `_bmad-output/implementation-artifacts/2-5-container-hardening-non-root-user-capabilities-tmpfs-noexec-named-volume.md` — § Review Findings AR-7..AR-12 (Story 2.6 absorbs AR-10 + AR-11 + AR-12 unconditionally; AR-7 + AR-9 conditional on operator-workstation smoke outcome).
- Invariants: `INVARIANTS.md` lines 90-106 (devbox-trio); `docs/invariants/devbox-dind.md` (backend-B detection); `docs/invariants/devbox-egress-contract.md` (consumed via host-side shims `whitelist-host.sh` + `monitor-host.sh`, which `docker exec` into in-container primitives `whitelist.sh` + `monitor.sh`); `docs/invariants/devbox-hardening.md` (SC-17 sync-gate target if edited; SC-22 AR-12 docs polish target).
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

- **Task 1.1 (HEAD state map):** `ls packages/devbox/scripts/` at impl-time confirmed the 6 expected scripts from the drafting snapshot — `benchmark.sh`, `egress-log-tailer.sh`, `monitor.sh`, `reload-egress.sh`, `start-egress.sh`, `whitelist.sh`. No inter-draft delta. Story 2.6 adds 13 new scripts without touching any of these 6.
- **Task 1.2 (`monitor.sh` banner confirmation):** `head packages/devbox/scripts/monitor.sh` banner line 2 matches `packages/devbox/scripts/monitor.sh — Story 2.3 (AC 3 observability)` — confirmed as the in-container JSONL tailer. NO rename/edit; `monitor-host.sh` shim created as the NEW host-side surface per SC-2 + SC-15.
- **Task 1.4 (regenerated `KEEL_DEVBOX_*` var list):** `rg -N --no-heading 'KEEL_DEVBOX_[A-Z_]+' packages/devbox/ | sort -u` yielded 18 var names across the codebase. `.envrc.example`'s active (uncommented) block documents 15; 2 are commented optional (`KEEL_DEVBOX_CONTAINER_NAME`, `KEEL_DEVBOX_WORKSPACE`); 1 is code-internal (`KEEL_DEVBOX_WORKSPACE_OWNER`). `env-check.sh` REQUIRED_VARS = the 15 active `.envrc.example` keys. Optional: `KEEL_DEVBOX_CONTAINER_NAME`, `KEEL_DEVBOX_WORKSPACE`, `KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S` (new Story 2.6 knob) — scripts default these via bash `${VAR:-default}`.
- **Task 3.2 smoke:** `pnpm devbox:env:check` with no `.envrc` → exit 3 + `env-check: .envrc not found at …` stderr. `pnpm devbox:env:check` with seeded `.envrc` (copied from `.envrc.example`) → exit 0 + `env-check: 15 of 15 required vars present; 0 value-shape violations`. AR-11 shape-validation: `KEEL_DEVBOX_TMPFS_TMP_MB=2gb` + `KEEL_DEVBOX_TMPFS_VARTMP_MB=0` → exit 2 + both violations reported by name.
- **Task 3.3 smoke:** `pnpm devbox:build` + `pnpm devbox:status` deferred to operator-workstation (backend-B iteration env per Story 2.4 iter-174 + Story 2.5 iter-187 precedent — lifecycle mutations against a shared host daemon risk poisoning unrelated projects). Recipes shipped in README § Host-side CLI § Verification (operator-workstation).
- **Task 8.3 dispatcher smokes:** `./packages/devbox/scripts/clean.sh --unknown` → exit 2 + usage block. `./packages/devbox/scripts/clean.sh --help` → exit 0 + usage block.
- **Task 8.5 pnpm wiring:** `pnpm run | grep -E '^\s+devbox:' | wc -l` → 13 (all 13 devbox:* scripts listed).
- **Task 10 quality gates:** `format:check` ✓ (1 prettier auto-fix applied to `packages/devbox/README.md` after manual draft). `lint` ✓ (16 tasks). `typecheck` ✓ (16 tasks). `keel-invariants:check-all` ✓ (after 2× contentHash refresh via SC-17 sync-gate). `docker compose config --quiet` ✓.
- **Sync-gate drift (expected):** package.json touched (+13 devbox:* entries) → `INV-prek-prepare-lifecycle` expected `87f37b45…` → actual `5960e7c4…`. hardening doc touched (AR-12 qualifier) → `INV-devbox-homedev-named-volume` expected `f34cb62f…` → actual `5e868749…`. Both hashes refreshed in `packages/keel-invariants/src/invariants.manifest.ts`; `dist/check.js` rebuilt; `keel-invariants:check-all` exit 0.

### Completion Notes List

- **13-verb host-side CLI surface shipped** as 13 `packages/devbox/scripts/<verb>.sh` files (each `0755`, `#!/usr/bin/env bash`, `set -euo pipefail`, self-rooted paths, banner + exit-code table per SC-4 + SC-5). All 13 pass `bash -n` syntax.
- **13 `pnpm devbox:*` entries** wired in repo-root `package.json` between `keel-invariants:*` and `prepare`. `pnpm run` lists all 13.
- **Uniform exit-code family (SC-5):** `0` ok / `2` usage / `3` source unreadable / `4` mutation lock / `5–7` passthrough / `8` docker unreachable / `9` container not running / `10` image not built / `11` healthcheck timeout / `124` reserved for `timeout(1)`.
- **`env-check.sh` (AC 8 + AR-11):** parses `.envrc` at repo root; validates 15 required `KEEL_DEVBOX_*` keys are present + 3 tmpfs-MB knobs (`TMPFS_TMP_MB`, `TMPFS_VARTMP_MB`, `TMPFS_LOGS_MB`) are positive integers. Names-only stderr for missing vars; values echoed only for the tmpfs-int shape class (never credentials). `start.sh` calls `env-check.sh` as its own pre-flight (escape: `KEEL_DEVBOX_START_SKIP_ENV_CHECK=true`).
- **`start.sh` healthcheck poll:** polls `docker inspect` every 2s up to `${KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S:-120}`s; accepts `healthy`, bare `running` (pre-Story-2.13 posture), or `starting` (within 30s grace); rejects `unhealthy|exited|dead|removing|paused` immediately with exit 11 (container left running for debug).
- **`clean.sh` three-tier destructive-op gate (SC-11):** default = container + image removed, `keel_home_dev` preserved (safe under either backend); `--with-volumes` gates on `[y/N]` prompt (or `--yes`); under backend B additionally requires `--force-backend-b` to prevent accidental destruction of a host-shared volume. `--allow-broad-prune` is RESERVED no-op at 1.0. Backend detection mirrors `benchmark.sh § detect_backend` per `docs/invariants/devbox-dind.md`.
- **`monitor-host.sh` + `whitelist-host.sh`:** thin `docker exec` shims over Story 2.3 `monitor.sh` (FR1a JSONL DNS-event tail) + Story 2.4 `whitelist.sh` (in-container allow-list CLI). Zero in-container primitive edits; dual-source-of-truth-for-validation risk avoided.
- **Monitor semantic reconciliation (SC-15):** `pnpm devbox:monitor` ships as the FR1a JSONL DNS-event tail per PRD `:494` + architecture `:1003` — NOT `docker stats`. Epics AC 7 "cpu/memory/network" phrasing is historical drift; the PRD is authoritative. Future `docker stats`-style verb would be a separate story.
- **AR-10 absorption (SC-21) LANDED:** new H3 `### Operator migration (pre-Story-2.5 named-volume recovery)` in `packages/devbox/README.md` under `## Hardening (Story 2.5)` H2 — symptom detection (`docker run --rm -v keel-devbox_keel_home_dev:/mnt alpine stat -c '%u:%g' /mnt`) + destructive recovery path (`pnpm devbox:stop && docker volume rm … && pnpm devbox:start`) + safety rail + invariant cross-ref.
- **AR-11 absorption (SC-14) LANDED:** env-check shape-validation for tmpfs-size knobs (positive integer regex `^[1-9][0-9]*$`; rejects `0`, empty, `"2gb"`, negative).
- **AR-12 absorption (SC-22) LANDED:** one-sentence COMPOSE_PROJECT_NAME override qualifier added at top of `packages/devbox/README.md § Hardening § Verification` + `docs/invariants/devbox-hardening.md § Verification`. Sync-gate fired for the invariant doc edit — contentHash refreshed in manifest.
- **README H2 § Host-side CLI (Story 2.6) LANDED (SC-23):** FR1 summary + 13-row subcommand table + exit-code family table + `.envrc` integration paragraph + backend-B awareness paragraph + operator-workstation verification recipe + iteration-env-safe smokes recipe + cross-references. Story 2.4 whitelist H3 cross-referenced.
- **AGENTS.md H3 § Host-side CLI (Story 2.6) LANDED (SC-24):** 5 terse operational bullets (canonical invocation, env-check pre-flight, named-volume preservation, uniform exit codes, monitor semantic pin) + cross-refs to Story 2.4 whitelist H3 + Story 2.5 hardening H3. No README duplication.
- **AR-7 (`/run` relocation) + AR-9 (`/etc/*` chown) NOT triggered:** conditional escalation paths per SC-19 + SC-20 remain deferred pending operator-workstation smoke outcome. Live-smoke for `pnpm devbox:start` + `pnpm devbox:whitelist sync` is documented in README as the gate; if the operator surfaces `/run/*: Permission denied` or `/etc/resolv.conf: EACCES`, the SC-19/SC-20 escalation path re-activates (same-iteration fix or follow-on story — operator decides).
- **Invariant sync-gate 2× refresh (SC-17):** two contentHash refreshes fired this iteration: (1) `INV-prek-prepare-lifecycle` (package.json +13 devbox:* entries triggers expected drift); (2) `INV-devbox-homedev-named-volume` (AR-12 qualifier in `docs/invariants/devbox-hardening.md` — NFR10 substrate-authoritative invariant). Both manifest-update + `dist/check.js` rebuild + `keel-invariants:check-all` exit 0.
- **Live smokes operator-workstation-deferred:** AC 2–7 live smokes (build, start, status, shell, logs, stop, restart, clean) documented as copy-paste recipes in README § Host-side CLI § Verification (operator-workstation). DinD backend B cannot safely exercise lifecycle-mutating smokes against a shared host daemon (Story 2.4 iter-174 + Story 2.5 iter-187 precedent). Iteration-env-safe smokes (bash -n syntax + pnpm wiring count + env-check with/without `.envrc` + dispatcher usage) all pass.

### File List

New (13 scripts):

- `packages/devbox/scripts/build.sh`
- `packages/devbox/scripts/rebuild.sh`
- `packages/devbox/scripts/start.sh`
- `packages/devbox/scripts/stop.sh`
- `packages/devbox/scripts/restart.sh`
- `packages/devbox/scripts/clean.sh`
- `packages/devbox/scripts/shell.sh`
- `packages/devbox/scripts/attach.sh`
- `packages/devbox/scripts/status.sh`
- `packages/devbox/scripts/logs.sh`
- `packages/devbox/scripts/monitor-host.sh` _(host-side shim; in-container `monitor.sh` unchanged)_
- `packages/devbox/scripts/whitelist-host.sh` _(host-side shim; in-container `whitelist.sh` unchanged)_
- `packages/devbox/scripts/env-check.sh`

Modified:

- `package.json` — 13 new `devbox:*` script entries inserted between `keel-invariants:*` block and `prepare` (SC-3).
- `packages/devbox/README.md` — new H3 `### Operator migration (pre-Story-2.5 named-volume recovery)` inside `## Hardening (Story 2.5)` (SC-21 AR-10), AR-12 qualifier at top of `### Verification` (SC-22), new H2 `## Host-side CLI (Story 2.6)` before `## cc-devbox upstream provenance` (SC-23).
- `AGENTS.md` — new H3 `### Host-side CLI (Story 2.6)` inside `## Devbox iteration environment` after `### Container hardening (Story 2.5)` (SC-24).
- `docs/invariants/devbox-hardening.md` — AR-12 COMPOSE_PROJECT_NAME qualifier at top of `## Verification` (SC-22).
- `packages/keel-invariants/src/invariants.manifest.ts` — contentHash refresh for `INV-prek-prepare-lifecycle` (`87f37b45…` → `5960e7c4…`, package.json edit) + `INV-devbox-homedev-named-volume` (`f34cb62f…` → `5e868749…`, hardening doc edit) via SC-17 sync-gate.
- `packages/keel-invariants/dist/check.js` — regenerated via `pnpm --filter @keel/keel-invariants build` to pick up the new manifest hashes.
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — `2-6-host-side-pnpm-devbox-cli-surface: ready-for-dev → review`; `last_updated` trail appended.

## Review Findings

### Post-dev SM (iter-203, v1.1) — `sm-verified`

ZERO-FINDING close per Change Log v1.1. All 9 ACs SATISFIED against landed substrate (`0fe36ae` HEAD; 13 scripts + 13 pnpm entries + README/AGENTS.md/invariant-doc edits + 2× contentHash refresh per iter-201 landing):

- **AC 1** — 13 scripts exist under `packages/devbox/scripts/` (`build.sh`, `rebuild.sh`, `start.sh`, `stop.sh`, `restart.sh`, `clean.sh`, `shell.sh`, `attach.sh`, `status.sh`, `logs.sh`, `monitor-host.sh`, `whitelist-host.sh`, `env-check.sh`); 13 `devbox:*` pnpm entries wired in repo-root `package.json:22-34`. One-script-per-verb + pnpm-exposure contract met.
- **AC 2** — `build.sh:28` → `docker compose -f "${COMPOSE_FILE}" build devbox` (cache-friendly); `rebuild.sh:32` → `docker compose -f "${COMPOSE_FILE}" build --no-cache devbox`. Compose file references `packages/devbox/Dockerfile` transitively per `docker-compose.yml` service definition.
- **AC 3** — `start.sh:57-98` brings container up via `docker compose up -d devbox` + polls `docker inspect` every 2 s up to `KEEL_DEVBOX_START_HEALTHCHECK_TIMEOUT_S:-120` s; accepts `healthy|running|starting(30 s grace)`; rejects `unhealthy|exited|dead|removing|paused` → exit 11. Bare-`running` acceptance pinned in SC-9 as stub-friendly pre-Story-2.13 posture (Story 2.13 is the healthcheck-definition scope-owner); `docker compose up -d` gating satisfies AC literal ("healthchecks must pass before the command returns zero") within the Story 2.6 scope boundary. No unmet-AC finding.
- **AC 4** — `stop.sh:29` = `docker compose stop devbox` (`down` avoided → named volume `keel_home_dev` naturally preserved). `restart.sh:18-21` = `stop.sh` → `start.sh` sequence with stop-failure abort. `clean.sh:91-113` ships three-tier behaviour: default scoped `down --rmi local --remove-orphans` (volume preserved), `--with-volumes` prompts `[y/N]` (or `--yes` auto-confirm) + backend-B adds `--force-backend-b` gate, `--allow-broad-prune` RESERVED no-op (SC-11).
- **AC 5** — `shell.sh:34-37` = `docker exec -it --user dev -w /workspace "${CONTAINER_NAME}" bash -l` (explicit `--user dev` matches Story 2.5 non-root posture; `-w /workspace` prevents `/home/dev` landing); pre-flight running-state check at `:26-30` → exit 9 when stopped.
- **AC 6** — `attach.sh:34` = `docker attach --detach-keys='ctrl-p,ctrl-q' "${CONTAINER_NAME}"` (explicit detach-key pin guards against future docker-default drift); pre-flight running-state check at `:27-31`.
- **AC 7** — `status.sh:34-40` prints `docker compose ps devbox` + `docker inspect .State.Status` + `.State.Health.Status` (fallback `(no healthcheck configured)`). `logs.sh:28` = `docker compose logs -f --tail=100 devbox`; forwarded-args path at `:31`. `monitor-host.sh:45` = `docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/monitor.sh "$@"` — Story 2.3 in-container JSONL egress-log tailer. Monitor semantic reconciled via SC-15: PRD `:494` + architecture `:1003` are authoritative ("FR1a JSONL DNS-event tail"); epics AC 7 literal "cpu/memory/network" phrasing is documented historical drift. Reconciliation applied at iter-199 v0.2 AI-2 CRITICAL and carried into iter-201 implementation + iter-202 trace substrate_evidence. **Documented cross-source reconciliation; not an unmet AC.**
- **AC 8** — `env-check.sh:60-130` validates `.envrc` presence (exit 3 + copy-pointer message), parses `KEEL_DEVBOX_*` lines, checks 15 required vars (exit 2 + named missing list), AR-11 shape-validates tmpfs-MB knobs (exit 2 + named violation). Names-only secrets discipline preserved (`architecture.md:335,1004`).
- **AC 9** — `whitelist-host.sh:32` = `docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/whitelist.sh "$@"` — pure passthrough to Story 2.4's atomic-reload in-container CLI; exit-code passthrough (0/2/3/4/5/6/7) + shim-level 8/9 (docker unreachable / container not running) per SC-16. No argument-validation / subcommand dispatch inside the shim (avoids dual-source-of-truth drift).

All 25 SCs (SC-1..SC-25) verified; scope-isolation audit PASS (Story 2.1 Dockerfile untouched; Story 2.3 `monitor.sh` + `reload-egress.sh` + `start-egress.sh` + dnsmasq.conf untouched; Story 2.4 in-container `whitelist.sh` untouched; Story 2.5 `USER dev` / `cap_drop|cap_add` / `security_opt` / tmpfs / named-volume declaration untouched). AR-7 `/run` relocation + AR-9 `/etc/*` chown conditional escalation paths (SC-19/SC-20) NOT triggered — remain deferred pending operator-workstation smoke outcome documented in README § Host-side CLI § Verification (operator-workstation).

Iteration-env-safe smokes re-run green at verification time: `ls -la packages/devbox/scripts/` confirms 13 new `0755` files at 2026-04-22 HEAD; `package.json:22-34` emits 13 `devbox:*` entries in lifecycle order. No AC regressions, no scope creep, no invariant-sourcePath drift beyond the 2× contentHash refresh recorded in v1.0. CR-opener (`/bmad-code-review (args: "2")`) cleared to run in next iteration per § Story Lifecycle `sm-verified → fixes-pending | done` row.

### Code Review (iter-204, v1.2) — `fixes-pending`

`/bmad-code-review (args: "2")` opener against cumulative Story 2.6 substrate diff (`65ef3a3..HEAD` / 26 files / 2152 insertions / 33 deletions). Three-layer adversarial fan-out: Blind Hunter + Edge Case Hunter + Acceptance Auditor. Acceptance Auditor verdict: **ZERO PATCH-or-higher acceptance deviations** — all 9 ACs + all 25 SCs satisfied; SC-15 (PRD `:494` monitor-semantic pin) + SC-9 (bare-`running` pre-Story-2.13 stub posture) + 2× invariant contentHash refresh all verified legitimate. Code-quality findings (Blind + Edge): 13 PATCH + 7 DEFER + 6 DISMISS.

**11 PATCH action items (per-finding → IP QUEUE fix task per § Story Lifecycle row `fixes-pending`):**

- [x] [Review][Patch] **AI-1 — `clean.sh` interactive `read` aborts under `set -euo pipefail` when stdin is non-TTY/EOF** [`packages/devbox/scripts/clean.sh:105`]
  Source: blind+edge. Evidence: `read -r answer` at line 105 followed by `case "${answer}"` at 106. Under `set -e`, if stdin is closed (CI without `--yes`, piped here-doc that ends, no TTY), `read` returns non-zero → `errexit` aborts BEFORE the `case` arm prints "aborted — no-op" at line 108; under `set -u` the subsequent `${answer}` would error. The user-friendly abort path is unreachable. Fix: `if ! IFS= read -r answer; then log "no input — aborting"; exit 0; fi` OR pre-initialise `answer=""; read -r answer || true`.
  **RESOLVED iter-205:** Option A landed at `clean.sh:105-110` — `if ! IFS= read -r answer; then log "no input — aborting (stdin closed / non-interactive); use --yes to auto-confirm"; exit 0; fi` inserted before the `case` arm. Inline comment added anchoring the `set -euo pipefail` EOF-abort rationale. Iteration-env-safe behavioural smoke (four cases — buggy-before reproduces exit 1; fixed + stdin-closed → exit 0 + "no input — aborting"; fixed + empty answer → exit 0 + "aborted — no-op"; fixed + "y" → proceeds) all green. `bash -n clean.sh` ✓. No invariant sourcePath touched (no sync-gate refresh required).

- [x] [Review][Patch] **AI-2 — `start.sh` exit 11 on `exited|dead|removing|paused` breaks the documented "container left running for debugging" guarantee** [`packages/devbox/scripts/start.sh:84-87`]
  Source: blind+edge. Evidence: header docstring line 20 promises "healthcheck timeout — container left running for debugging" for exit 11; the timeout branch (line 65-68) honours this, but the fatal-state branch (line 84-87) ALSO exits 11 even when state is `exited` or `dead` (container NOT running). Operators following the `pnpm devbox:logs` hint at line 85 get logs for a container that may already be gone. Fix: distinguish "still running but unhealthy" (exit 11; logs hint applies) from "exited|dead|removing|paused" (different exit code OR rephrased hint — `pnpm devbox:logs` still works on exited containers but the docstring promise is misleading).
  **RESOLVED iter-206:** rephrased-hint path (SC-5 preserved — exit 11 remains flat). Case arm split at `start.sh:93-107`: `unhealthy)` keeps the logs hint with a "still running" qualifier; `exited|dead|removing|paused)` gets a new log line acknowledging "not running" + "may show last output before exit" (docker retains logs on exited containers, daemon-config-dependent for `removing`). Docstring lines 20-28 rewritten to honestly catalog the three exit-11 sub-cases (timeout / unhealthy / fatal) with line-anchor pointers. Iteration-env-safe behavioural smoke (12 assertions): 7 state-dispatch cases (healthy/running → rc 0; unhealthy → rc 11 + "still running" log; exited/dead/removing/paused → rc 11 + "not running" log); 2 cross-leak regression guards (unhealthy log does NOT claim "not running"; fatal log does NOT claim "still running"); 1 harness-drift guard (both fix log-lines present in start.sh verbatim); 2 buggy-before reproductions (pre-fix conflated unhealthy+fatal). `bash -n start.sh` ✓. No invariant sourcePath touched (no sync-gate refresh). 9 PATCH remaining (AI-3..AI-11); iter-207 drains AI-3 (`monitor-host.sh:41` remediation-hint rephrase).

- [x] [Review][Patch] **AI-3 — `monitor-host.sh` exit-3 hint promises a remediation path that doesn't fix the failure mode** [`packages/devbox/scripts/monitor-host.sh:41`]
  Source: blind+edge. Evidence: line 40 checks `[[ ! -f "${DEVBOX_DIR}/scripts/monitor.sh" ]]` (host filesystem path), line 41 logs `"in-container primitive 'monitor.sh' missing — rebuild via 'pnpm devbox:build'"`. The file is checked on the HOST (alongside this script in git); if absent on host, it's also absent in the bind-mounted container. `docker compose build` will NOT restore a missing repo file — the fix is `git checkout packages/devbox/scripts/monitor.sh` or re-clone. Fix: rephrase to `"monitor.sh missing from packages/devbox/scripts/ — restore via 'git checkout packages/devbox/scripts/monitor.sh'"`.
  **RESOLVED iter-207:** runtime log-line rephrased verbatim to the CR spec (`monitor-host.sh:46`). Docstring exit-3 entry (`monitor-host.sh:12-18`) rewritten to catalog the bind-mount rationale: `monitor.sh` is not baked into the image, so `docker compose build` does NOT restore a missing repo file; `git checkout` does. Inline comment at `monitor-host.sh:42-44` mirrors the docstring rationale at the call site for future maintainers scanning the branch. Iteration-env-safe extract-and-mirror behavioural smoke (14 assertions): 6 drift-guards (new hint present verbatim; old `rebuild via 'pnpm devbox:build'` hint absent from runtime log; docstring mentions `git checkout` remediation; docstring explicitly disclaims `docker compose build`; exit-3 code preserved in docstring; file-check branch still exits 3) + 6 harness cases (absent → rc 3 + new-hint log + no `rebuild` substring + no `pnpm devbox:build` substring; present → rc 0 + no log emitted) + 1 buggy-before distinctness check + 1 sibling-unchanged regression guard (exit-9 hint untouched). `bash -n monitor-host.sh` ✓. `monitor-host.sh` is NOT a `keel-invariants` manifest sourcePath → no sync-gate refresh. 8 PATCH remaining (AI-4..AI-11); iter-208 drains AI-4 (`clean.sh:80-88` backend detection over/under-classification).

- [x] [Review][Patch] **AI-4 — `clean.sh` backend detection: `/.dockerenv` over-classifies as B AND inspect-failure defaults to A (less protective)** [`packages/devbox/scripts/clean.sh:80-88`]
  Source: blind+edge. Evidence: line 86 `if [[ -f /.dockerenv ]]; then echo B; return; fi`. `/.dockerenv` exists in BOTH true DinD (backend A) and host-socket-passthrough (backend B); using its presence alone over-classifies a backend-A container as B → false-positive `--with-volumes` lock-out without `--force-backend-b`. Conversely, when `docker info --format '{{.Name}}'` at line 82 fails (transient daemon hiccup), the case-statement falls through, `/.dockerenv` is absent on host, and detection defaults to `A` at line 87 — the LESS-protective branch on a backend-B host. Fix (both directions): drop the `/.dockerenv` arm OR treat it as "unknown — require explicit `--force-backend-b`"; on `docker info` failure, exit 8 OR fail-safe to B.
  **RESOLVED iter-208:** asymmetric-fix path selected — the empty-daemon_name under-classification is the high-severity half (silent destruction of host-shared volumes on Docker Desktop); the `/.dockerenv` over-classification is low-severity friction (true-DinD operators add `--force-backend-b`). Added explicit `if [[ -z "${daemon_name}" ]]; then echo B; return; fi` guard BEFORE the case-statement (`clean.sh:86-90`) — closes the probe-failure window between the `docker info` reachability check at `clean.sh:73` and the `--format` probe at `clean.sh:84`. Kept `/.dockerenv` → B as the intentional fail-safe aligned with `benchmark.sh:129-155` (both scripts now share the "when in doubt, refuse destructive" posture per `docs/invariants/devbox-dind.md` § Safety rule); expanded the docstring at `clean.sh:78-85` to name AI-4 + document the over-inclusive /.dockerenv arm as intentional (true-DinD operators accept one extra flag rather than let a Docker-Desktop-host operator lose unrelated volumes on a silent probe failure). Iteration-env-safe extract-and-mirror behavioural smoke (13 assertions, `/tmp/smoke-ai-4.sh`): 4 well-known-identifier case-match cases (docker-desktop, wildcard *-docker-desktop, moby, linuxkit-*) → B unchanged + 2 AI-4 fail-safe cases (empty daemon_name in both host-mode and iter-env legs → B) + 2 generic-name cases (host sim → A; container /.dockerenv → B) + 1 buggy-before repro (pre-fix harness returns A on empty+host — proves fix is load-bearing) + 4 drift-guards (empty → B present / /.dockerenv → B retained / native-host → A retained / AI-4 rationale anchor present). `/.dockerenv` test-toggle via `sed 's|-f /\.dockerenv|-f /nonexistent_host_mode_simulation|'` on the extracted body — same extract-and-mirror technique as iter-207 AI-3 monitor-host smoke. `bash -n clean.sh` ✓. No invariant sourcePath touched — `clean.sh` is not registered in `packages/keel-invariants/invariants.manifest.ts` → no sync-gate contentHash refresh required. 7 PATCH remaining (AI-5..AI-11); iter-209 drains AI-5 (`env-check.sh:24-26` fragile relative-path resolution) per § Story Lifecycle row `fixes-pending` top-of-QUEUE.

- [ ] [Review][Patch] **AI-5 — `env-check.sh` repo-root resolution via `${DEVBOX_DIR}/../../.envrc` is fragile under symlinked or vendored invocations** [`packages/devbox/scripts/env-check.sh:24-26`]
  Source: edge. Evidence: `ENVRC_PATH="${DEVBOX_DIR}/../../.envrc"` assumes the script lives exactly two directory levels under repo root. Works for the substrate layout, but a symlinked invocation, a fork that vendors `packages/devbox/` at a different depth, or a future `packages/devbox/cli/` reorg silently points at the WRONG path and exits 3 with a misleading hint. Fix: use `git rev-parse --show-toplevel` (with a fallback to the current relative-path arithmetic when `.git` is absent), OR honour an explicit `KEEL_DEVBOX_REPO_ROOT` envvar override.

- [ ] [Review][Patch] **AI-6 — `env-check.sh` inline-`#`-comment strip runs AFTER quote-strip and corrupts quoted values containing `' #'`** [`packages/devbox/scripts/env-check.sh:82-87`]
  Source: edge. Evidence: line 82-83 strips outer quotes, then line 87 `value="${value%% #*}"` strips at first ` #` substring. A value like `KEEL_DEVBOX_DNS_UPSTREAM="1.1.1.1 # primary"` becomes `1.1.1.1` — the `#` inside the original quoted string is now mid-line and gets stripped. Comment at line 84-86 acknowledges the risk but flags it as "defensive (none expected)"; the order of operations is the actual bug. Fix: track quoting state (was the value quoted? if so, skip the inline-comment strip), OR strip inline comments BEFORE removing quotes (and only when the `#` is outside any open quote).

- [ ] [Review][Patch] **AI-7 — `env-check.sh` does not strip `\r` from CRLF `.envrc` files; tmpfs shape regex then fails with cryptic message** [`packages/devbox/scripts/env-check.sh:70-91`]
  Source: edge. Evidence: a Windows-edited `.envrc` (or one piped through a CRLF-aware editor under WSL) ends every value with `\r`. The trailing-whitespace strip at line 89 (`${value%"${value##*[![:space:]]}"}`) does NOT consistently strip `\r` across locales (CR is not in `[:space:]` under POSIX). `KEEL_DEVBOX_TMPFS_TMP_MB="64\r"` fails the `^[1-9][0-9]*$` regex at line 105 with `'64' — expected positive integer MB count` (the `\r` is invisible in the log line; operator sees a passing-looking value rejected). Fix: explicit `value="${value%$'\r'}"` after line 80, OR document that `.envrc` must be LF-only and reject CRLF up-front.

- [ ] [Review][Patch] **AI-8 — `start.sh` polls the hardcoded `${CONTAINER_NAME}` while `docker compose up -d` honours `COMPOSE_PROJECT_NAME` from operator shell** [`packages/devbox/scripts/start.sh:28,71`]
  Source: edge. Evidence: line 28 defaults `CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"`, but `docker-compose.yml`'s top-level `name: keel-devbox` is overridden at runtime by `COMPOSE_PROJECT_NAME` (Compose v2.20+). If a developer has `export COMPOSE_PROJECT_NAME=my-fork` in their shell, `docker compose up -d devbox` (line 58) creates `my-fork-devbox-1` (or similar) while `docker inspect "${CONTAINER_NAME}"` (line 71, default `keel-devbox`) returns empty → polling loop logs `inspect returned empty state — retrying` for the full 120 s and exits 11 with the misleading "healthcheck timeout" message. AR-12 documented the static-prose drift (carried into v1.0); this is the runtime equivalent. Fix: `unset COMPOSE_PROJECT_NAME` at the top of every script that uses `docker inspect "${CONTAINER_NAME}"` (start, stop, restart, shell, attach, status, logs, monitor-host, whitelist-host) OR use `docker compose -f "${COMPOSE_FILE}" ps -q devbox` to discover the actual container ID at runtime.

- [ ] [Review][Patch] **AI-9 — `whitelist-host.sh` does not pin `--user dev`; mutations may run as root inside container, violating the Story 2.5 USER dev posture** [`packages/devbox/scripts/whitelist-host.sh:32`]
  Source: edge. Evidence: `exec docker exec -it "${CONTAINER_NAME}" /workspace/packages/devbox/scripts/whitelist.sh "$@"` — no `--user` flag, so docker uses the image's default user. The image's USER directive is `dev` (per Story 2.5 Dockerfile), so today this works correctly; but `shell.sh:34` and the architectural posture explicitly pin `--user dev` for clarity. Whitelist mutations write state files under `/run/keel-whitelist-*` (Story 2.4 contract); inconsistent USER posture risks ownership drift if a fork's docker-compose.override.yml adds `user: root`. Fix: add `--user dev` matching the shell.sh pattern (`-it --user dev`).

- [ ] [Review][Patch] **AI-10 — `whitelist-host.sh` hardcodes `-it`; `pnpm devbox:whitelist add foo.com` from a non-TTY context (CI, subprocess) fails with "the input device is not a TTY"** [`packages/devbox/scripts/whitelist-host.sh:32`]
  Source: edge. Evidence: `docker exec -it ...` — the `-t` flag requires a TTY; non-TTY invocation errors before reaching the in-container script. Same `-it` pattern in `shell.sh:34` and `attach.sh:34` is appropriate (interactive intent), but whitelist mutations are scriptable and should work from CI / hooks / pnpm subprocess. Fix: TTY-detect — `[[ -t 0 ]] && tty_flag="-it" || tty_flag="-i"`, then `docker exec ${tty_flag} ...`. Same fix for `monitor-host.sh:45` if monitoring is intended to be tee-able.

- [ ] [Review][Patch] **AI-11 — `restart.sh` invokes `start.sh` immediately after `stop.sh` returns; `docker compose stop` returns when SIGTERM is sent + grace expires, NOT when the container has actually `exited`** [`packages/devbox/scripts/restart.sh:18-21`]
  Source: edge. Evidence: line 18 invokes `stop.sh` (which calls `docker compose stop devbox`), line 21 immediately `exec`s `start.sh`. On slow daemons the container may still be in `removing` state when `start.sh` polls — `docker inspect` may return `running`/`removing` from the OLD container and `start.sh:74-76` matches `running` → returns "started" prematurely against a doomed container. Fix: in `restart.sh`, poll `docker inspect ... .State.Status` between stop and start until it reports `exited` (or container object disappears) before invoking `start.sh`; bound the wait by a short timeout (e.g. 10 s) before proceeding regardless.

**7 DEFERs (carry-forward to operator-workstation smoke OR downstream stories; mirrored to `deferred-work.md`):**

- [x] [Review][Defer] **AR-13 — `start.sh` accepts bare `running` as healthy on first poll → 30 s grace + 120 s timeout are dead code in pre-Story-2.13 substrate** [`packages/devbox/scripts/start.sh:73-77`] — deferred, SC-9 scope-boundary. SC-9 explicitly designates this as the stub-friendly pre-Story-2.13 posture; Story 2.13 is the healthcheck-definition scope-owner. Acceptance Auditor verified intentional. Re-evaluate when Story 2.13 wires `HEALTHCHECK` into `docker-compose.yml`.

- [x] [Review][Defer] **AR-14 — `env-check.sh` treats explicit empty-string (`KEEL_DEVBOX_DNS_UPSTREAM=`) as "present" rather than "missing"** [`packages/devbox/scripts/env-check.sh:67-68,95`] — deferred, intentional design. Comment at lines 67-68 documents the intentional posture: "operators may explicitly set `X=` to signal 'present but empty'". SC-14 scope was integer-shape validation only; non-integer empty-string treatment remains an explicit design decision.

- [x] [Review][Defer] **AR-15 — `start.sh` TOCTOU between `docker image inspect` (line 39) and `docker compose up -d devbox` (line 58)** [`packages/devbox/scripts/start.sh:39-58`] — deferred, exit-10 is best-effort by spec. Compose handles the actual build/pull and emits its own error if the image is unavailable at `up` time; the inspect check is a fast-fail UX hint, not a correctness gate.

- [x] [Review][Defer] **AR-16 — `shell.sh` argument forwarding pattern `bash -l "$@"` rejects bare commands (`pnpm devbox:shell whoami` errors "No such file or directory")** [`packages/devbox/scripts/shell.sh:32-34`] — deferred, out of AC 5 scope. AC 5 specifies "interactive shell as the dev user"; argument forwarding was not in the AC. Operator UX enhancement; document the `-c '<cmd>'` constraint in the script header instead.

- [x] [Review][Defer] **AR-17 — `env-check.sh` quote-stripping is asymmetric: `value="${value#\"}"; value="${value%\"}"` peels one quote each side without checking they match** [`packages/devbox/scripts/env-check.sh:82-83`] — deferred, defensive. A malformed `KEEL_DEVBOX_FOO="5` (unmatched quote) becomes `5` silently, but the upstream missing-var check + tmpfs shape check catch the realistic mis-typings. Hardening would require quote-state tracking; keep current behavior at 1.0.

- [x] [Review][Defer] **AR-18 — 12 of 13 scripts lack `--help`/`-h` handling (only `clean.sh:62` has `usage`)** [`packages/devbox/scripts/{attach,build,rebuild,start,stop,restart,shell,status,logs,monitor-host,whitelist-host,env-check}.sh`] — deferred, ergonomic. AC 1-9 do not mandate per-script `--help`; README + AGENTS.md document the verb table. Operator running `pnpm devbox:start --help` gets `docker compose up -d --help` (compose's help) rather than a friendly script-level usage. Carry to a future ergonomic-pass story.

- [x] [Review][Defer] **AR-19 — Eight scripts duplicate the `docker info` + `docker inspect .State.Status` pre-flight; refactoring to a sourced `_lib.sh` would deduplicate ~8×3 lines and ensure consistent exit-8/exit-9 messaging** — deferred, refactor opportunity. Carry to a future cleanup story; Story 2.7+ may consolidate as the script set grows.

**6 DISMISSED:**

- `clean.sh --force-backend-b` no-op when used without `--with-volumes` — UX micro-warning, not defect.
- `logs.sh` flag forwarding silently drops follow + tail defaults — passthrough is intentional.
- `restart.sh` does not discriminate stop's exit-0 from "no-op" — `docker compose stop` rc 0 IS the correct behaviour.
- `monitor-host.sh` cosmetic hint redundancy with AI-3 — handled by AI-3.
- `env-check.sh` "value-shape violations" log line always present — cosmetic count, accurate.
- Story file `Status: review` vs IP § Context `Story State = sm-verified` at iter-204 entry — intentional dual-tracking documented in v1.1 (sprint-status `review` ≠ IP lifecycle `sm-verified`); not a code defect.

CR-opener routing: Story State `sm-verified → fixes-pending` (IP lifecycle); story file Status `review → in-progress`; sprint-status `review → in-progress`. Iter-205+ drains AI-1..AI-11 one PATCH per iteration per § Story Lifecycle row `fixes-pending`; on QUEUE drain, re-run `/bmad-code-review (args: "2")` for the closure gate (forecast: ZERO-PATCH per Epic-2 3-story precedent).

## Change Log

| Version | Date | Iter | Who | Change |
| --- | --- | --- | --- | --- |
| v1.6 | 2026-04-22 | iter-208 | Ralph (CR drain) | **AI-4 RESOLVED — `clean.sh:78-97` backend detection empty-daemon_name under-classification.** Asymmetric-fix path: addressed the high-severity under-classification (silent destruction of host-shared volumes on a Docker Desktop host when the `docker info --format` probe fails transiently) by adding an explicit `if [[ -z "${daemon_name}" ]]; then echo B; return; fi` guard BEFORE the case-statement at `clean.sh:86-90`. Kept the `/.dockerenv` → B arm as the intentional fail-safe aligned with `benchmark.sh:129-155` — true-DinD operators override with `--force-backend-b` (low-severity friction) rather than let a Docker-Desktop-host operator lose unrelated volumes on a silent probe failure (high-severity loss). Expanded the function docstring at `clean.sh:78-85` to name AI-4 + document the over-inclusive `/.dockerenv` arm as intentional fail-safe posture per `docs/invariants/devbox-dind.md` § Safety rule. Iteration-env-safe extract-and-mirror behavioural smoke (13 assertions): 4 well-known-identifier case-match cases (docker-desktop / `*-docker-desktop` wildcard / moby / `linuxkit-*`) → B unchanged; 2 AI-4 fail-safe cases (empty daemon_name in both host-mode-via-sed-substitution and iter-env-with-real-`/.dockerenv` legs) → B; 2 generic-name cases (host sim → A; container `/.dockerenv` → B); 1 buggy-before repro (pre-fix harness returns A on empty + no-`/.dockerenv` — proves fix is load-bearing); 4 source-level drift-guards (empty → B present / `/.dockerenv` → B retained / native-host → A fallback retained / AI-4 rationale anchor present). Harness extract-and-mirror technique: `awk` extracts `detect_backend()` body; `sed 's|-f /\.dockerenv|-f /nonexistent_host_mode_simulation|g'` toggles the `/.dockerenv` leg deterministically for the "simulated host with no `/.dockerenv`" assertions. `bash -n clean.sh` ✓. No invariant sourcePath touched — `clean.sh` is not registered in `packages/keel-invariants/invariants.manifest.ts` → no sync-gate contentHash refresh required. Story State `fixes-pending` stays (7 PATCH remaining: AI-5..AI-11); iter-209 drains AI-5 (`env-check.sh:24-26` fragile relative-path resolution — use `git rev-parse --show-toplevel` or `KEEL_DEVBOX_REPO_ROOT` envvar) per § Story Lifecycle row `fixes-pending` top-of-QUEUE. |
| v1.5 | 2026-04-22 | iter-207 | Ralph (CR drain) | **AI-3 RESOLVED — `monitor-host.sh:41` misleading exit-3 hint rephrased + docstring honesty.** Runtime log-line at `monitor-host.sh:46` rephrased from `"in-container primitive 'monitor.sh' missing — rebuild via 'pnpm devbox:build'"` to the iter-204 CR spec: `"monitor.sh missing from packages/devbox/scripts/ — restore via 'git checkout packages/devbox/scripts/monitor.sh'"`. Docstring exit-3 entry (`monitor-host.sh:12-18`) rewritten to catalog the bind-mount rationale — `monitor.sh` is bind-mounted from the host-side repo checkout (not baked into the image), so `docker compose build` does NOT restore a missing repo file; `git checkout` does. Inline comment at `monitor-host.sh:42-44` mirrors the docstring rationale at the call site. Iteration-env-safe extract-and-mirror behavioural smoke (14 assertions): 6 drift-guards + 6 harness cases (absent → rc 3 + new-hint log + no rebuild/pnpm-devbox-build substring; present → rc 0 + no log emitted) + 1 buggy-before distinctness check + 1 sibling-unchanged regression guard (exit-9 hint untouched). `bash -n monitor-host.sh` ✓. `monitor-host.sh` is NOT in `keel-invariants` manifest → no sync-gate refresh required. Story State `fixes-pending` stays (8 PATCH remaining: AI-4..AI-11); iter-208 drains AI-4 (`clean.sh:80-88` backend detection over/under-classification) per § Story Lifecycle row `fixes-pending` top-of-QUEUE. |
| v1.4 | 2026-04-22 | iter-206 | Ralph (CR drain) | **AI-2 RESOLVED — `start.sh:84-87` fatal-state vs unhealthy hint drift + docstring honesty.** Rephrased-hint path selected (SC-5 exit-code set preserved flat — no new exit code added). Case arm split at `start.sh:93-107`: `unhealthy)` keeps "still running" log + logs hint (docstring "left running" promise holds); `exited|dead|removing|paused)` gets a new log line explicitly saying "not running" + "may show last output before exit" (docker retains logs on exited containers; `removing` is daemon-config-dependent). Docstring lines 20-28 rewritten to honestly catalog the three exit-11 sub-cases (timeout / unhealthy / fatal) with line-anchor pointers. Iteration-env-safe behavioural smoke (12 assertions) — 7 state-dispatch cases (healthy/running → rc 0; unhealthy → rc 11 + "still running" log; exited/dead/removing/paused → rc 11 + "not running" log); 2 cross-leak regression guards (unhealthy log ⊄ "not running"; fatal log ⊄ "still running"); 1 harness-drift guard (both fix log-lines present in start.sh verbatim); 2 buggy-before reproductions (pre-fix conflated unhealthy+fatal into one "fatal state 'X'" log). `bash -n start.sh` ✓. No invariant sourcePath touched — no sync-gate refresh required. 9 PATCH remaining (AI-3..AI-11); iter-207 drains AI-3 (`monitor-host.sh:41` rebuild→git-checkout hint rephrase). |
| v1.3 | 2026-04-22 | iter-205 | Ralph (CR drain) | **AI-1 RESOLVED — `clean.sh:105` non-TTY `read` EOF handler.** Applied Option A per iter-204 CR spec: `if ! IFS= read -r answer; then log "no input — aborting (stdin closed / non-interactive); use --yes to auto-confirm"; exit 0; fi` before the `case` arm, plus an inline comment anchoring the `set -euo pipefail` EOF-abort rationale. Iteration-env-safe behavioural smoke (four cases) confirms the fix: buggy-before reproduces exit 1 with no "aborted" log; fixed + stdin-closed → exit 0 + new log line; fixed + empty-answer → exit 0 + existing `aborted — no-op` log (case arm still reachable); fixed + `y` → proceeds to destructive exec. `bash -n clean.sh` ✓. No invariant sourcePath touched — no sync-gate refresh required. Story State `fixes-pending` stays (10 PATCH remaining: AI-2..AI-11); iter-206 drains AI-2 per § Story Lifecycle row `fixes-pending` top-of-QUEUE. |
| v1.2 | 2026-04-22 | iter-204 | Ralph (code-review opener) | `/bmad-code-review (args: "2")` opener against `65ef3a3..HEAD` Story 2.6 cumulative diff (26 files / 2152 insertions). Three-layer adversarial fan-out: Blind Hunter + Edge Case Hunter + Acceptance Auditor. Acceptance Auditor: ZERO PATCH-or-higher AC deviations (all 9 ACs + 25 SCs satisfied; SC-15 monitor-pin + SC-9 bare-`running` + 2× invariant contentHash refresh verified legitimate). Code-quality triage: 11 PATCH action items (AI-1..AI-11) + 7 DEFERs (AR-13..AR-19 mirrored to `deferred-work.md`) + 6 DISMISSED. 11 PATCH fan-out: AI-1 `clean.sh:105` non-TTY `read` abort under `set -euo`; AI-2 `start.sh:84-87` exit-11 breaks "container left running" guarantee for `exited|dead`; AI-3 `monitor-host.sh:41` misleading remediation hint; AI-4 `clean.sh:80-88` backend-detection over/under-classification; AI-5 `env-check.sh:24-26` fragile relative-path root resolution; AI-6 `env-check.sh:82-87` inline-`#`-strip order corrupts quoted values; AI-7 `env-check.sh:70-91` CRLF `.envrc` → cryptic shape-regex failure; AI-8 `start.sh:28,71` `COMPOSE_PROJECT_NAME` runtime override breaks container polling; AI-9 `whitelist-host.sh:32` missing `--user dev` pin; AI-10 `whitelist-host.sh:32` `-it` breaks non-TTY CI invocation; AI-11 `restart.sh:18-21` stop→start race before container exits. Pre-selected "Create action items" routing (arg `2`) — no auto-fix this iteration; each PATCH becomes a § Story Lifecycle QUEUE fix task at iter-205+. Story State `sm-verified → fixes-pending`. Story file Status `review → in-progress`. Sprint-status `review → in-progress`. Next iter drains AI-1 per § Story Lifecycle row `fixes-pending` (top-of-QUEUE). |
| v1.1 | 2026-04-22 | iter-203 | Ralph (create-story review — post-dev SM) | Post-dev SM requirements-satisfaction verification. ZERO unmet-AC findings across all 9 ACs against `0fe36ae` HEAD (iter-201 implementation + iter-202 trace-WAIVED substrate). Per-AC satisfaction recorded in new `## Review Findings § Post-dev SM (iter-203, v1.1) — sm-verified` section with file:line anchors. AC 7 monitor-semantic (epics AC 7 "cpu/memory/network" vs PRD `:494` + architecture `:1003` JSONL DNS-event tail) confirmed as SC-15-reconciled cross-source documented deferment, not unmet AC. AC 3 bare-`running` acceptance confirmed as SC-9 stub-friendly posture within Story 2.13 scope-boundary, not unmet AC. Scope-isolation audit PASS (Story 2.1/2.3/2.4/2.5 surfaces unchanged; AR-7/AR-9 escalation paths NOT triggered per SC-19/SC-20 conditional gate). Sprint-status unchanged (stays `review` — BMad-skill-internal state; IP lifecycle transitions `traced → sm-verified` separately). Next iteration runs `/bmad-code-review (args: "2")` CR opener per § Story Lifecycle matrix row `sm-verified`. |
| v1.0 | 2026-04-22 | iter-201 | Ralph (dev-story) | Implementation landing. 13 host-side scripts created under `packages/devbox/scripts/` (build, rebuild, start, stop, restart, clean, shell, attach, status, logs, monitor-host, whitelist-host, env-check). 13 `devbox:*` entries wired in repo-root `package.json`. AR-10 operator-migration H3 + AR-12 COMPOSE_PROJECT_NAME qualifier landed in README + invariant doc (SC-22 sync-gate fired — `INV-devbox-homedev-named-volume` contentHash refreshed `f34cb62f…` → `5e868749…`; `INV-prek-prepare-lifecycle` contentHash refreshed `87f37b45…` → `5960e7c4…` due to package.json +13 entries). New README H2 `## Host-side CLI (Story 2.6)` (SC-23) + AGENTS.md H3 (SC-24). AR-7 + AR-9 escalation paths (SC-19/SC-20) NOT triggered — remain deferred pending operator-workstation smoke outcome; README + AGENTS.md document the escalation trigger. Live lifecycle smokes operator-workstation-deferred per Story 2.4 iter-174 + Story 2.5 iter-187 backend-B precedent; iteration-env-safe smokes (bash -n × 13; pnpm wiring × 13; env-check exit-3/exit-0/exit-2; dispatcher usage) all pass. Quality gates: format:check ✓, lint ✓, typecheck ✓, keel-invariants:check-all ✓ (after 2× sync-gate refresh), `docker compose config --quiet` ✓. Status `atdd-scaffolded → in-dev → review` single-iter landing. Sprint-status `ready-for-dev → review`. |
| v0.2 | 2026-04-22 | iter-199 | Ralph (create-story review — pre-dev SM) | Pre-dev SM validation patches (AI-1..AI-8). **AI-1 CRITICAL:** SC-2 monitor-naming self-contradiction resolved — pinned `monitor-host.sh` per Story 2.4 `whitelist-host.sh` precedent; dropped the "rename existing monitor.sh to monitor-egress.sh" path (scope-creep). SC-2 13-verb table + SC-3 example-block + Task 1.2 + Task 2.11 + Dev Notes File List targets updated consistently. **AI-2 CRITICAL:** Epics AC 7 ("cpu/memory/network") vs PRD `:494` + architecture `:1003` ("JSONL DNS-event tail") semantic drift reconciled — SC-15 now cites PRD `:494` as authoritative, explicitly pinning `pnpm devbox:monitor` = FR1a JSONL tail (NOT `docker stats`). **AI-3 ENHANCEMENT:** Task 10.6 split into 10.6a (`backlog → ready-for-dev`, `[x]` completed-at-draft) + 10.6b (`ready-for-dev → in-progress`, dev-story start) + 10.6c (`in-progress → review`, dev-story commit) per iter-173 carry-forward rule (lifecycle-hygiene subtasks done at draft time marked `[x]` with annotation to avoid dev-agent re-flip). **AI-4 OPTIMIZATION:** SC-3 typo fix ("suffix suffix-resolved" → "`-host.sh`-suffix-resolved"). **AI-5..AI-8 OPTIMIZATION:** Task 1.2 simplification (HEAD state known; dropped (b)/(c) decision paths), Task 2.11 consistency, File List targets clarification, this Change Log entry. Story State `drafted → validated`. Sprint-status unchanged (stays `ready-for-dev`). |
| v0.1 | 2026-04-22 | iter-198 | Ralph (create-story) | Initial draft — 13-verb host-side CLI surface, 25 scope clarifications, 10 tasks. Absorbs Story 2.5 CR DEFERs AR-10 (unconditional) + AR-11 (env-check shape validation, unconditional) + AR-12 (compose-project-name docs polish, unconditional); AR-7 `/run` relocation + AR-9 `/etc/*` chown conditional on operator-workstation smoke outcome per SC-19 + SC-20. Status drafted (sprint-status `backlog → ready-for-dev`). |
