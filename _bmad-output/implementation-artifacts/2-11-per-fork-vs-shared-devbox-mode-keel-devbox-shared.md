# Story 2.11: Per-fork vs shared devbox mode (`KEEL_DEVBOX_SHARED`)

Status: ready-for-dev <!-- Ralph-internal `Story State` = `drafted` at create-story landing (iter-254); transitions to `validated` after `/bmad-create-story (args: "review")` pre-dev gate. Sprint-row `backlog → ready-for-dev` per § Story Lifecycle row `_(no story) → drafted`. -->

<!-- Note: Validation is optional. Run `/bmad-create-story (args: "review")` for pre-dev quality check before `/bmad-testarch-atdd` / `/bmad-dev-story`. -->

## Story

As a fork operator running multiple worktrees or forks,
I want `.envrc`'s `KEEL_DEVBOX_SHARED` flag to switch between per-fork devbox (default) and shared-devbox mode,
So that I can choose between strict isolation per fork and a shared long-running devbox across forks (FR4).

## Acceptance Criteria

1. **Per-fork mode (default) — isolated container + isolated named volume.** Given `KEEL_DEVBOX_SHARED=false` (or unset, defaulting to false per `.envrc.example:41`) in each fork's `.envrc`, when I run `pnpm devbox:start` from fork A and then from fork B, then each fork gets its own container AND its own named volume — the bind source is the fork's main-repo root, the container name is `keel-devbox` (Story 2.1/2.5 default), the Compose project name is `keel-devbox`, and the named volume is `keel-devbox_keel_home_dev` (Story 2.5 substrate; `INV-devbox-homedev-named-volume`). Two forks cannot share state under per-fork mode — a second `pnpm devbox:start` from fork B while fork A's container is running triggers a Compose "container name already in use" collision unless fork B overrides `KEEL_DEVBOX_CONTAINER_NAME` in its own `.envrc` (Story 2.1 per-fork override path). The two devboxes are isolated at the container, volume, bind-source, and OAuth-token layers.

2. **Shared mode — single shared container + single shared named volume across forks.** Given `KEEL_DEVBOX_SHARED=true` in the `.envrc` of BOTH fork A and fork B, when I run `pnpm devbox:start` from fork A and then from fork B, then both forks attach to a single shared container named `keel-devbox-shared` (Compose project name `keel-devbox-shared`; named volume `keel-devbox-shared_keel_home_dev`). The bind source flips from `<fork-root>` to `<dirname-of-fork-root>` (the PARENT directory, matching upstream `cc-devbox`'s `/Users/tthew/Development:/workspace:delegated` pattern — see `architecture.md:547`), producing `/workspace/<parent-basename>/{fork-a,fork-b,...}/` inside the container. Fork B's `pnpm devbox:start` detects the existing `keel-devbox-shared` container (via `docker inspect`) and becomes a no-op health-poll that exits 0 without recreating the container. The shared workspace mount strategy is documented verbatim in `AGENTS.md § Per-fork vs shared devbox mode (Story 2.11)` per the AC 2 clause "a shared workspace mount strategy is documented in `AGENTS.md`."

3. **Mid-use flip — `pnpm devbox:env:check` warns about orphaned cross-mode containers.** Given I flip `KEEL_DEVBOX_SHARED` from `false` to `true` (or `true` to `false`) mid-use while a container from the PRIOR mode still exists on the host daemon (e.g., `keel-devbox` present after flipping to `true`; `keel-devbox-shared` present after flipping to `false`), when I run `pnpm devbox:env:check`, then env-check probes the OTHER-mode's container via `docker inspect` and surfaces a stderr warning naming the orphaned container AND pointing at `pnpm devbox:clean` as the resolution path. The warning is informational — env-check exits 0 (or whatever its env-var-validation outcome would otherwise be) without failing the command. Operator remediation flow: (a) optionally re-flip `.envrc` to the orphan's mode; (b) run `pnpm devbox:clean`; (c) re-flip `.envrc` back to the desired mode; (d) re-run `pnpm devbox:start`.

4. **Concurrent-Ralph behaviour in shared mode — serialised Ralph TUI with per-fork working-tree isolation for non-Ralph operations.** Given shared mode is active (`KEEL_DEVBOX_SHARED=true` in both forks) and both forks have started the shared container, when two forks invoke Ralph simultaneously (`pnpm ralph:build` from fork A AND from fork B in overlapping wall-clock windows), then the behaviour is **serialised at the Ralph TUI level**: the container runs exactly ONE Ralph TUI process at a time (one `CMD` PID 1); both forks' `docker attach` invocations target the same PID; Docker's attach-single-writer semantics mean only one operator's stdin/stdout actively drives the TUI at any moment (second attach detaches the first — standard Docker attach contention). Non-Ralph operations (`pnpm devbox:shell`, `pnpm claude`, `pnpm gh:auth`) use `docker exec` which spawns independent PIDs; those ARE parallel-safe across forks (each fork's exec session lands at its own `/workspace/<parent>/<fork>/` path per CONTAINER_WORKDIR resolver). Conflicting writes to `/home/dev/` are avoided by design: (a) Claude OAuth token is single-writer-multi-reader (one `pnpm claude` at a time; all subsequent reads share the same token); (b) gh OAuth token same posture; (c) bash history is append-only; (d) Claude Code's `CLAUDE_CODE_TASK_LIST_ID` scopes per-exec-session (independent task lists across concurrent exec sessions). Decision rationale pinned in this AC's ADR-style note below (§ Dev Notes § Concurrency decision). Operators needing TRUE parallel Ralph across forks MUST revert to per-fork mode (each fork gets its own container + its own TUI PID 1 — the default posture).

## Tasks / Subtasks

- [ ] **Task 1: Extend `packages/devbox/scripts/lib/main-repo-resolver.sh` with `resolve_mode_specific_state()`** (AC 1, AC 2, AC 4)
  - [ ] Add new sourced function `resolve_mode_specific_state()` that runs AFTER `resolve_main_repo_and_workdir()` (existing function; same file). Callers invoke both in sequence: `resolve_main_repo_and_workdir; resolve_mode_specific_state`.
  - [ ] Read `KEEL_DEVBOX_SHARED` from the process env (operator's `.envrc` is sourced by direnv OR by host-wrapper's pre-flight; value is one of `true` / `false` / unset-treated-as-false per `.envrc.example:41`).
  - [ ] Normalise: `SHARED=$(echo "${KEEL_DEVBOX_SHARED:-false}" | tr '[:upper:]' '[:lower:]')`; accept exactly `"true"` as shared-mode signal; any other value (`false`, `0`, `no`, `False`, empty, unset) resolves to per-fork mode. This normalisation is deliberate — operator typo `KEEL_DEVBOX_SHARED=TRUE` (uppercase) vs `True` (titlecase) MUST route to shared mode; everything else defaults to the safe per-fork posture (fail-closed doctrine).
  - [ ] Branch:
    - **Per-fork mode (default):** leave `MAIN_REPO`, `WORKTREE_ROOT`, `REPO_NAME`, `CONTAINER_WORKDIR` as `resolve_main_repo_and_workdir()` set them. Additionally export: `KEEL_DEVBOX_COMPOSE_PROJECT="keel-devbox"` and `KEEL_DEVBOX_CONTAINER_NAME_RESOLVED="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"` (preserves operator's existing per-fork `KEEL_DEVBOX_CONTAINER_NAME` override path from Story 2.1).
    - **Shared mode:** flip `WORKTREE_ROOT`, `MAIN_REPO`, `REPO_NAME`, `CONTAINER_WORKDIR`:
      - `local shared_parent="$(dirname "$MAIN_REPO")"`
      - `local shared_parent_name="$(basename "$shared_parent")"`
      - `MAIN_REPO="$shared_parent"; export MAIN_REPO`
      - `WORKTREE_ROOT="$shared_parent"; export WORKTREE_ROOT`
      - `REPO_NAME="${KEEL_DEVBOX_REPO_NAME:-$shared_parent_name}"; export REPO_NAME` — operator override preserved.
      - `CONTAINER_WORKDIR` re-derives: if the caller's `$PWD` is under the original per-fork `MAIN_REPO`, the container path now lands at `/workspace/<parent-basename>/<fork-basename>/<relative-subpath>`. Compute via the existing `case` arm pattern against the NEW `WORKTREE_ROOT`.
      - `KEEL_DEVBOX_COMPOSE_PROJECT="keel-devbox-shared"; export KEEL_DEVBOX_COMPOSE_PROJECT`
      - `KEEL_DEVBOX_CONTAINER_NAME_RESOLVED="keel-devbox-shared"; export KEEL_DEVBOX_CONTAINER_NAME_RESOLVED` — shared mode HARDCODES the container name regardless of operator's `KEEL_DEVBOX_CONTAINER_NAME` setting. Rationale: AC 2 requires fork A and fork B to attach to the SAME container; if operator A sets `KEEL_DEVBOX_CONTAINER_NAME=keel-devbox-custom` in fork A's `.envrc` and operator B does not, the two forks would resolve to different container names and AC 2 fails silently. Shared mode is opinionated — the operator-override escape-hatch is gated at the per-fork mode only.
  - [ ] Under `set -u` (every shim enforces it), unset `KEEL_DEVBOX_SHARED` access with default-substitution (`${KEEL_DEVBOX_SHARED:-false}`) MUST NOT trip set-u. Validate via bash lint smoke.
  - [ ] Header comment block updates: amend the existing `WORKTREE_ROOT / REPO_NAME / CONTAINER_WORKDIR` doc-block (`lib/main-repo-resolver.sh:9-28`) with a NEW `Mode-specific state (Story 2.11)` paragraph enumerating the two modes and the four resolver outputs (`KEEL_DEVBOX_COMPOSE_PROJECT`, `KEEL_DEVBOX_CONTAINER_NAME_RESOLVED`, mode-adjusted `WORKTREE_ROOT`, mode-adjusted `REPO_NAME`).

- [ ] **Task 2: Parameterise `packages/devbox/docker-compose.yml` top-level `name:` + propagate compose-project to container** (AC 1, AC 2)
  - [ ] Edit `docker-compose.yml:39` — change `name: keel-devbox` to `name: ${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}`. This is the ONLY compose-file edit Story 2.11 makes. All other interpolations (`KEEL_DEVBOX_WORKSPACE`, `KEEL_DEVBOX_REPO_NAME`, `KEEL_DEVBOX_CONTAINER_NAME`) are already parameterised by Stories 2.1/2.2 + iter-239 mount-path mirroring.
  - [ ] The existing `container_name: ${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}` at `docker-compose.yml:54` composes on top: host wrappers set `KEEL_DEVBOX_CONTAINER_NAME=keel-devbox-shared` in shared mode (via resolver's `KEEL_DEVBOX_CONTAINER_NAME_RESOLVED` export + an `export KEEL_DEVBOX_CONTAINER_NAME="$KEEL_DEVBOX_CONTAINER_NAME_RESOLVED"` shim-side export — see Task 3).
  - [ ] Amend the Story-roadmap comment (`docker-compose.yml:22`) from `Story 2.11 : shared-workspace mode (KEEL_DEVBOX_SHARED=true).` to a past-tense landed note: `Story 2.11 : shared-workspace mode (KEEL_DEVBOX_SHARED=true). LANDED iter-<this>.` matching Stories 2.2 / 2.3 / 2.5 landed-note pattern.
  - [ ] Remove the `TODO(Story 2.11)` marker at `docker-compose.yml:239` (now resolved).
  - [ ] Amend the workspace-mount doc-block (`docker-compose.yml:80-107`) to reflect the landed shared-mode contract: the paragraph starting `Story 2.11 forward-compat: shared-workspace mode flips…` (L103-107) becomes past-tense `Story 2.11 shared-workspace mode: flips KEEL_DEVBOX_WORKSPACE to the parent directory + KEEL_DEVBOX_REPO_NAME to that parent's basename, producing /workspace/Development/{ralph-bmad,fork-A,fork-B}/ in the container. Resolution lives in lib/main-repo-resolver.sh § resolve_mode_specific_state().`

- [ ] **Task 3: Wire `resolve_mode_specific_state()` into all 18 host-side shims + export `KEEL_DEVBOX_CONTAINER_NAME` for compose interpolation** (AC 1, AC 2, AC 4)
  - [ ] Affected shims (18 total): the 17 shims enumerated in Story 2.10 § Task 4 (13 Story 2.6 devbox verbs + `claude-host.sh` + `gh-auth-host.sh` + `ralph-build-host.sh` + `ralph-plan-host.sh`) + `prereq-check.sh` (new Story 2.10 shim; MUST also become mode-aware because its Tier 2 probe of `${VOLUME_NAME}_keel_home_dev` depends on the compose project name).
  - [ ] For each shim, at the site where `resolve_main_repo_and_workdir` is invoked (after `source "${SCRIPT_DIR}/lib/main-repo-resolver.sh"`), ADD a following line: `resolve_mode_specific_state`. Then add two exports after the resolver runs:
    - `export KEEL_DEVBOX_COMPOSE_PROJECT` (already exported by resolver; this line is defensive — some shims `unset COMPOSE_PROJECT_NAME` but do NOT re-export downstream resolver outputs).
    - `export KEEL_DEVBOX_CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"` — this is the new load-bearing line. Compose's `container_name: ${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}` interpolation reads the env var at compose-up time; in shared mode the resolver has already forced `KEEL_DEVBOX_CONTAINER_NAME_RESOLVED=keel-devbox-shared`, overriding any operator `.envrc` setting.
  - [ ] Shims that currently compute `CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}"` inline (e.g., `start.sh:42`, `shell.sh`, `attach.sh`, `stop.sh`, `status.sh`, `logs.sh`, `clean.sh`) MUST switch to `CONTAINER_NAME="${KEEL_DEVBOX_CONTAINER_NAME_RESOLVED}"` (consuming the resolver's authoritative output, NOT re-computing from env with an obsolete per-fork default).
  - [ ] Shims that pass `-e "KEEL_DEVBOX_REPO_NAME=${REPO_NAME}"` to `docker exec` (e.g., `claude-host.sh:73`, `ralph-build-host.sh:86`, `ralph-plan-host.sh:86`, `shell.sh:51,56`, `gh-auth-host.sh:78`, `monitor-host.sh:78`, `whitelist-host.sh:64`) automatically pick up the mode-adjusted `REPO_NAME` from the resolver — no further edit required IF resolver is invoked first.
  - [ ] Shim ordering contract: `source lib/main-repo-resolver.sh` → `resolve_main_repo_and_workdir` → `resolve_mode_specific_state` → `export KEEL_DEVBOX_CONTAINER_NAME=…` → any downstream `docker inspect` / `docker compose` / `docker exec` call. `prereq-check.sh` is invoked AFTER this ordering so its Tier-2 volume probe uses the correct `${KEEL_DEVBOX_COMPOSE_PROJECT}_keel_home_dev` volume name.
  - [ ] **`prereq-check.sh` specific edit:** line 34 `VOLUME_NAME="${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}_keel_home_dev"` already consumes the resolver's export if resolver ran first. Add resolver invocation at the top of `prereq-check.sh` (BEFORE the existing Tier 1/Tier 2 dispatch) — mirror pattern with other shims but note that `prereq-check.sh` is self-sourcing (not sourced by callers); invoking the resolver internally is the right call here.
  - [ ] **`restart.sh` special case:** `restart.sh` transitively delegates to `stop.sh` + `start.sh`, both of which will have resolver invocations. `restart.sh` itself still prepends resolver invocation for fail-fast consistency (Story 2.10 AI-14 precedent: `restart.sh` gets its own prereq-check despite transitive coverage).
  - [ ] **`env-check.sh` special case:** env-check does NOT need resolver output for its own `.envrc` validation (it reads `.envrc` as a file, not from env). BUT env-check DOES need resolver output for Task 4's AC 3 orphan-container probe. Invoke resolver after the `.envrc` parse + before the orphan probe.

- [ ] **Task 4: Extend `env-check.sh` with AC 3 orphan-container warning** (AC 3)
  - [ ] After the existing env-var validation passes (L162 onwards), invoke `resolve_main_repo_and_workdir + resolve_mode_specific_state` (Task 1 functions).
  - [ ] Determine current mode: `CURRENT_MODE=$([[ "${parsed[KEEL_DEVBOX_SHARED]}" == "true" ]] && echo shared || echo per-fork)`. Respect the `.envrc` value parsed in the earlier loop, NOT the process env (operator's `direnv allow` may lag `.envrc` edits — the authoritative signal is the file content, which env-check already parses).
  - [ ] Compute the OTHER-mode's container name: if current is per-fork, `OTHER_CONTAINER="keel-devbox-shared"`; if current is shared, `OTHER_CONTAINER="keel-devbox"`.
  - [ ] Probe: `docker inspect "${OTHER_CONTAINER}" >/dev/null 2>&1` — rc capture per Story 2.10 PATCH-1 lesson (rc=0 → exists; rc=1 → absent; rc>1 → daemon error → silently skip warning rather than fail; Tier 1 prereq-check already gated Docker reachability upstream).
  - [ ] On rc=0: emit stderr warning verbatim — `env-check: warning: orphaned ${OTHER_MODE}-mode container '${OTHER_CONTAINER}' detected from a previous KEEL_DEVBOX_SHARED=${OTHER_BOOL} session; run 'pnpm devbox:clean' (after re-flipping .envrc to KEEL_DEVBOX_SHARED=${OTHER_BOOL} if needed) or 'docker rm -f ${OTHER_CONTAINER}' to remove it. See packages/devbox/README.md § Per-fork vs shared mode § Mid-use flip.` where `${OTHER_MODE}` is literal `shared` or `per-fork` and `${OTHER_BOOL}` is literal `true` or `false`.
  - [ ] Warning-only posture (AC 3): do NOT alter exit code. The existing env-check exit schema (`0` all pass, `2` missing var / shape violation, `3` `.envrc` unreadable, `8` docker unreachable via Story 2.10 prereq-check) is preserved; the orphan-container probe augments stderr with at most one extra line.
  - [ ] If `docker inspect` rc>1 (daemon error beyond reachability — rare; Tier 1 prereq-check already cleared basic reachability via `docker info`), silently skip the warning. Do NOT exit non-zero on orphan-probe failure — env-check's primary contract is `.envrc` validation; the orphan warning is a secondary convenience.
  - [ ] **Shape lockstep:** the exact warning string above is pinned here + MUST appear verbatim in `docs/invariants/devbox-mode.md § Mid-use flip warning` (Task 5) + `packages/devbox/README.md § Per-fork vs shared mode § Mid-use flip` (Task 6). Three-site drift hazard per Story 2.10 DEFER-4 — deferred substrate-lockstep lint enforcement — convention-enforced at 1.0.

- [ ] **Task 5: Register `INV-devbox-mode` + author `docs/invariants/devbox-mode.md`** (AC 1–4 machine-enforced contract)
  - [ ] Add new entry to `packages/keel-invariants/src/invariants.manifest.ts`:
    - `id: 'INV-devbox-mode'`
    - `description: 'Per-fork vs shared devbox mode contract — KEEL_DEVBOX_SHARED flag branches compose project name, container name, bind source, and named volume between keel-devbox (per-fork, default) and keel-devbox-shared (shared) with orphaned-container warning on mid-use flip (Story 2.11).'`
    - `sourcePath: 'docs/invariants/devbox-mode.md'`
    - `contentHash: '<sha256 of the authored md file content>'`
    - `anchors: ['INV-devbox-mode']`
  - [ ] **InvariantSchema five-field compliance** (Story 2.3 iter-156 LESSON): `InvariantSchema` at `packages/keel-invariants/src/invariants.manifest.ts:3-15` requires exactly `{id, description, sourcePath, contentHash, anchors}` — NO `name` field; `anchors` entries are backtick-wrapped ID literals NOT H3-header strings; `contentHash` is bare 64-char lowercase hex NOT `sha256:<hex>` prefixed. Story 2.11 compliance is mandatory.
  - [ ] Author `docs/invariants/devbox-mode.md` with the following H2-structured sections (Story 2.3 iter-156 LESSON — multi-faceted contracts embed sub-schemas verbatim in the `sourcePath` doc so each sub-rule is hashed into `contentHash`):
    - `## Mode signal` — `KEEL_DEVBOX_SHARED=true|false|unset`; normalisation rules (lowercase comparison; non-`true` defaults to per-fork; fail-closed to per-fork on unrecognised values).
    - `## Per-fork mode contract` — Compose project name `keel-devbox`; container name `keel-devbox` (or `KEEL_DEVBOX_CONTAINER_NAME` operator override); volume `keel-devbox_keel_home_dev`; bind source = fork root; bind target = `/workspace/<fork-basename>`.
    - `## Shared mode contract` — Compose project name `keel-devbox-shared`; container name `keel-devbox-shared` (NO operator override — shared mode is opinionated); volume `keel-devbox-shared_keel_home_dev`; bind source = parent of fork root; bind target = `/workspace/<parent-basename>` (e.g. `/workspace/Development`).
    - `## Resolver contract` — `packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_mode_specific_state()` is the single resolution site; every host-side shim invokes it after `resolve_main_repo_and_workdir`; exports `KEEL_DEVBOX_COMPOSE_PROJECT` + `KEEL_DEVBOX_CONTAINER_NAME_RESOLVED` + mode-adjusted `WORKTREE_ROOT` / `MAIN_REPO` / `REPO_NAME` / `CONTAINER_WORKDIR`.
    - `## Concurrency decision (AC 4)` — serialised Ralph TUI (one Ralph per container; `docker attach` single-writer); parallel non-Ralph operations (`docker exec`-based `shell`/`claude`/`gh-auth` spawn independent PIDs). Operator-facing rule: TRUE parallel Ralph across forks → revert to per-fork mode.
    - `## Mid-use flip warning` — `env-check.sh` orphan-container probe; exact verbatim warning string (three-site lockstep with this doc, README § Mid-use flip, and env-check.sh emit site); warning-only posture (exit code unchanged).
    - `## Named volume relationship to INV-devbox-homedev-named-volume` — SC-1: Story 2.5's `INV-devbox-homedev-named-volume` pins the NAME `keel_home_dev` (unqualified) under whichever compose project is active; Story 2.11 does NOT relax that invariant — the fully-qualified volume name is `${KEEL_DEVBOX_COMPOSE_PROJECT}_keel_home_dev` which resolves to `keel-devbox_keel_home_dev` (per-fork) or `keel-devbox-shared_keel_home_dev` (shared). Two modes = two separate volumes; OAuth tokens do NOT cross modes. Operator switching modes re-auths (expected by AC 3's orphan warning).
    - `## Invariant stability` — per-fork mode is the SUBSTRATE DEFAULT; shared mode is an opt-in operator escape hatch. Forks MAY NOT remove or re-default the per-fork mode. Fork-level growth-tier `INVARIANTS.fork.md` rules MAY add fork-specific mode constraints (e.g., "disable shared mode for compliance reasons") but MAY NOT weaken substrate defaults (fork-to-remove forbidden; Story 1.16 § Amendment-vs-fork decision tree).
  - [ ] Compute `contentHash`: `sha256sum docs/invariants/devbox-mode.md | awk '{print $1}'`. Paste the 64-char lowercase hex into the manifest entry. `pnpm keel-invariants:check` MUST pass after manifest + doc both land (Story 1.9 sync-gate verification).
  - [ ] Append entry to `INVARIANTS.md` under the devbox section (after `INV-devbox-prereq-check` — Story 2.10 anchor bullet) as: `- **\`INV-devbox-mode\`** — Per-fork vs shared devbox mode contract (`KEEL_DEVBOX_SHARED` branches compose project + container + volume + bind). Source: \`docs/invariants/devbox-mode.md\`.` Index-only, no body (`INVARIANTS.md` is an agent-readable index per FR42).
  - [ ] Dev-agent guardrail: anchor bullet MUST match verbatim regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` per `packages/keel-invariants/src/sync-gate.ts:24` (Story 1.9 sync-gate). Lowercase-after-`INV-` prefix is MANDATORY (Story 1.9 iter-7 LESSON).

- [ ] **Task 6: Operator + agent documentation** (AC 1–4 comprehension)
  - [ ] **`packages/devbox/README.md`** — append new H2 `## Per-fork vs shared devbox mode (Story 2.11)` AFTER the existing `## Prerequisite check (Story 2.10)` H2 and BEFORE `## cc-devbox upstream provenance`. Content:
    - (a) Two-mode enumeration with the exact contract from `docs/invariants/devbox-mode.md § Per-fork mode contract` + `§ Shared mode contract`.
    - (b) `.envrc` snippet showing `KEEL_DEVBOX_SHARED=false` (default) and `KEEL_DEVBOX_SHARED=true` (opt-in).
    - (c) Three operator walkthroughs:
      - **Default per-fork walkthrough:** fresh fork, `.envrc` default, `pnpm devbox:start` → lands at `/workspace/<fork-basename>/` inside container `keel-devbox`.
      - **Shared-mode walkthrough:** operator with multiple forks under `~/Development/`, sets `KEEL_DEVBOX_SHARED=true` in EACH fork's `.envrc`, `pnpm devbox:start` from fork A creates shared container, `pnpm devbox:start` from fork B is a no-op (already running), `pnpm devbox:shell` from either fork lands at its own fork subdirectory under `/workspace/Development/`.
      - **Mid-use flip walkthrough:** operator starts per-fork container, flips `.envrc` to `KEEL_DEVBOX_SHARED=true`, runs `pnpm devbox:env:check` which surfaces the orphan warning, operator follows `pnpm devbox:clean` pointer (after re-flipping `.envrc` if needed), re-flips to shared, re-runs `pnpm devbox:start`.
    - (d) Concurrency doctrine (verbatim from AC 4): serialised Ralph TUI; parallel non-Ralph operations; operator-facing rule for true-parallel-Ralph falls back to per-fork.
    - (e) `INV-devbox-mode` citation for the machine-enforced contract.
    - (f) `## Mid-use flip` sub-H3: reproduces the exact env-check warning string verbatim (three-site lockstep with Task 4 emit + `docs/invariants/devbox-mode.md § Mid-use flip warning`).
  - [ ] **DO NOT modify existing `## Host-side CLI (Story 2.6)`, `## Ralph loop (Story 2.7)`, `## Claude Code authentication (Story 2.8)`, `## gh CLI authentication (Story 2.9)`, or `## Prerequisite check (Story 2.10)` sections** — append a NEW sibling H2 only. Rewriting prior stories' sections is scope-creep (SC-17 inherited from Story 2.9 → 2.10).
  - [ ] **`AGENTS.md`** — append new H3 `### Per-fork vs shared devbox mode (Story 2.11)` AFTER the existing `### Prerequisite check (Story 2.10)` H3 under § Devbox iteration environment. Content:
    - (a) Mode contract one-line summary + `.envrc` knob (`KEEL_DEVBOX_SHARED`).
    - (b) Resolver site citation: `packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_mode_specific_state()`.
    - (c) Concurrency decision: serialised Ralph TUI; parallel non-Ralph exec; per-fork mode is the only path to true-parallel-Ralph across forks.
    - (d) Agent guardrail: agents MUST NOT advise operators to flip `KEEL_DEVBOX_SHARED` mid-Ralph-loop (container teardown required; AC 3 warning surfaces but remediation is operator-gated). Agents SHOULD NOT attempt to auto-detect mode from container state — the authoritative signal is `.envrc`.
    - (e) `INV-devbox-mode` citation.
    - (f) AC 4 concurrency note: when Ralph operates under shared mode, `pnpm ralph:build` from a second fork will detach the first operator's attach session (standard `docker attach` single-writer semantics). Agents inheriting Epic 3 scope MUST NOT treat a detach as a halt condition — operator re-attaches via `pnpm devbox:attach` (Story 2.6) or a fresh `pnpm ralph:build` (Story 2.7).
  - [ ] **DO NOT modify existing `### Host-side CLI (Story 2.6)`, `### Ralph loop (Story 2.7)`, `### Claude Code authentication (Story 2.8)`, `### gh CLI authentication (Story 2.9)`, or `### Prerequisite check (Story 2.10)` sections** — append a NEW sibling H3 only (SC-17).
  - [ ] **Change Log v1.0 entry** — record 4 ACs + 6 tasks + ~17 SCs (see § Success Criteria); initial draft; dev-ready; ATDD forecast under FR14n matrix row 3 ground-(a)+(b)+(c) conjunction per § Testing Standards — testable ACs exist (mode-flip smokes via `KEEL_DEVBOX_SHARED` env overrides on static `.envrc` → `docker compose config` assertions; volume-name assertion via `docker volume ls`; orphan warning via stubbed `docker inspect`); trace forecast NON-WAIVED (multi-site implementation with distinct code-path branches per AC); CR PATCH forecast 0–3 opener (moderate novel surface — resolver function extension + compose project parameterisation + env-check warning are structurally mirrored on Story 2.6/2.10 precedents but the SHARED-mode path is genuinely novel; iter-253 LESSON forecast-carry: ~1/1000/year operator-edge SECOND-class DEFERs likely).
  - [ ] **Sprint-status housekeeping:** `/bmad-create-story` workflow's step 6 flips `2-11-…: backlog → ready-for-dev` at iter-254 landing (this iteration). `/bmad-dev-story` Step 4 flips `ready-for-dev → in-progress`; Step 9 flips `in-progress → review`. `/bmad-code-review (args: "2")` closure flips `review → done`.

## Dev Notes

### Relevant architecture patterns and constraints

- **Substrate authority: `packages/devbox/`.** All 18 host-side shims + `lib/main-repo-resolver.sh` + `docker-compose.yml` live under this package. Story 2.11 changes are scoped to this directory (plus new invariant at `docs/invariants/devbox-mode.md` + `INVARIANTS.md` anchor + manifest entry + operator docs at `packages/devbox/README.md` + `AGENTS.md`).
- **Mode resolution pattern.** Resolver function in `lib/main-repo-resolver.sh` — single site; host shims source the library and invoke the function. Mirrors Story 2.6 precedent (the existing `resolve_main_repo_and_workdir` pattern) with one-function-per-concern: `resolve_main_repo_and_workdir` handles git-layout + paths; new `resolve_mode_specific_state` handles mode + compose-project + container-name. Functions compose sequentially in every caller.
- **`set -euo pipefail` discipline.** Every shim enforces strict bash flags. Resolver function's `KEEL_DEVBOX_SHARED` read MUST use `${KEEL_DEVBOX_SHARED:-false}` default-substitution (NOT bare `$KEEL_DEVBOX_SHARED`) to survive `set -u`. Mirror Story 2.10 PATCH-1 LESSON on rc-capture under `set -e` (not applicable here — resolver is assignment-only, not command-invocation).
- **`INV-devbox-homedev-named-volume` interaction.** Story 2.5's invariant pins the volume's UNQUALIFIED name as `keel_home_dev`. Story 2.11 does NOT touch that name; it changes the COMPOSE PROJECT PREFIX from `keel-devbox` to `keel-devbox-shared` in shared mode, yielding `keel-devbox-shared_keel_home_dev` (fully-qualified). The SC-1 clause (§ Success Criteria) pins that Story 2.5's invariant survives Story 2.11 unchanged — the unqualified name is unchanged; only the compose-project prefix varies. Two modes = two separate named volumes = two separate OAuth-token stores.
- **Mid-use flip orphan semantics.** Fork operator A runs per-fork mode → container `keel-devbox` + volume `keel-devbox_keel_home_dev` exist on host daemon. Operator flips `.envrc` to SHARED=true → subsequent `pnpm devbox:start` creates container `keel-devbox-shared` + volume `keel-devbox-shared_keel_home_dev`. Old per-fork container/volume remain intact (orphaned). Operator runs `pnpm devbox:env:check` in the NEW (shared) mode → env-check probes `docker inspect keel-devbox` → exists → emits warning pointing at `pnpm devbox:clean`. Operator resolution: re-flip `.envrc` to per-fork, run `pnpm devbox:clean` (tears down per-fork container + image; named volume preserved by Story 2.6 AC 4 default), re-flip `.envrc` to shared. Volume preservation is intentional — the old OAuth tokens may be needed if the operator re-flips again.
- **Shared mode parent-dir bind — security posture.** Shared mode binds the PARENT directory of the fork root. Example: fork at `/Users/tthew/Development/ralph-bmad`; shared mode binds `/Users/tthew/Development` to `/workspace/Development`. Any OTHER project under `~/Development/` becomes visible inside the container. This is BY DESIGN (matches upstream cc-devbox's `/Users/tthew/Development` pattern; N=1 dogfood). Security implication: fork operators MUST understand that shared mode extends the bind source's blast radius. Substrate documentation SHOULD call this out (see `packages/devbox/README.md § Per-fork vs shared mode § Shared-mode bind scope`).
- **No PRD amendment required.** FR4 (`prd.md:930`) verbatim matches AC 1+2; architecture § Workspace mount (`architecture.md:547`) verbatim matches the bind-source contract. Story 2.11 is substrate-only; no PRD/architecture edits needed.

### Concurrency decision (AC 4 implementation note)

**Pinned decision: serialised Ralph TUI with parallel non-Ralph operations.**

Alternatives considered:
- **A (serialised via lockfile):** write a `/home/dev/.ralph.lock` when Ralph starts; second Ralph invocation checks lock + fails with "Ralph already running; detach from current session via Ctrl+P Ctrl+Q then `pnpm devbox:attach`". Rejected: adds a substrate-level lock mechanism that must handle stale-lock cleanup (crash recovery), lock-directory persistence (named volume vs tmpfs), and cross-Ralph-process signalling. Too much machinery for an operator-facing concern.
- **B (parallel via per-fork-name subdir):** run N Ralph TUIs, each CMD'd to a different `/home/dev/.ralph/<fork-basename>/` scratch dir. Rejected: Ralph's `CMD` is set at image-layer time; multi-Ralph-per-container requires runtime PID spawning which is Epic 3's domain (currently `CMD: [sleep, infinity]` — one PID 1, one Ralph).
- **C (serialised at Docker-attach layer; pinned):** leverage `docker attach`'s natural single-writer semantics. Container PID 1 runs Ralph TUI (once Epic 3 lands); two operators attach → second detaches first. First operator sees terminal disconnect; can re-attach. Conflict detection is implicit. Operators needing true parallelism fall back to per-fork mode. Chosen as the minimum-machinery path consistent with Epic 3's PID-1 architecture.

Consequences:
- Shared mode is a DOGFOOD-class operator convenience, not a production-grade multi-tenancy substrate.
- Operators inheriting this mode MUST understand the attach contention. Documentation (Task 6) SHOULD highlight this in the shared-mode walkthrough.
- Epic 3 deliverables unchanged — the Ralph TUI implementation does NOT need concurrency primitives to satisfy AC 4.

### Source tree components to touch

- `packages/devbox/scripts/lib/main-repo-resolver.sh` — extend (new function).
- `packages/devbox/docker-compose.yml` — one-line `name:` parameterisation + comment-block amendments.
- `packages/devbox/scripts/{build,rebuild,start,stop,restart,clean,shell,attach,status,logs,monitor-host,whitelist-host,env-check,claude-host,gh-auth-host,ralph-build-host,ralph-plan-host,prereq-check}.sh` — resolver invocation + exports (18 shims).
- `packages/devbox/scripts/env-check.sh` — orphan-container probe + warning emit (Task 4).
- `packages/keel-invariants/src/invariants.manifest.ts` — new `INV-devbox-mode` entry.
- `docs/invariants/devbox-mode.md` — new authoritative contract doc.
- `INVARIANTS.md` — one-line anchor bullet under devbox section.
- `packages/devbox/README.md` — new `## Per-fork vs shared devbox mode (Story 2.11)` H2.
- `AGENTS.md` — new `### Per-fork vs shared devbox mode (Story 2.11)` H3.

### Testing standards summary

- **ATDD forecast: NON-SKIP.** Story 2.11 has testable ACs at the resolver + compose-interpolation + warning-emit layers. Red-phase scaffolds candidate:
  - AC 1: smoke — `KEEL_DEVBOX_SHARED=false <resolver-invoke>; echo $KEEL_DEVBOX_COMPOSE_PROJECT` → `keel-devbox`. Similar for CONTAINER_NAME_RESOLVED.
  - AC 2: smoke — `KEEL_DEVBOX_SHARED=true <resolver-invoke>; echo $KEEL_DEVBOX_COMPOSE_PROJECT` → `keel-devbox-shared`; `REPO_NAME` → basename of `$(dirname $MAIN_REPO)`; `WORKTREE_ROOT` → `$(dirname $MAIN_REPO)`.
  - AC 3: smoke — stub `docker inspect keel-devbox` to rc=0; run env-check under `KEEL_DEVBOX_SHARED=true`; grep stderr for warning substring "orphaned per-fork-mode container 'keel-devbox'".
  - AC 4: no red-phase scaffold feasible (concurrency decision is documentation-only; no harness exists for cross-fork simulation). ATDD for AC 4 is out of scope — trace-gate waive candidate for AC 4 only (Story 2.7 precedent for doc-only ACs).
- **Trace-gate forecast: NON-WAIVED for ACs 1-3; partial-waive for AC 4 per above.** Story 2.9 + 2.10 precedent: docs-only ACs with no mechanical verification earn per-AC `defer:` in IP during trace fix-loop, not full-story waive.
- **CR forecast: 0-3 PATCH opener.** Novel surface (mode resolver, parent-dir bind, compose-project parameterisation) is moderate. Precedents: Stories 2.1 (compose) + 2.6 (shim pattern) + 2.10 (sync-gate-bound invariant doc) cover all implementation sites. Per iter-251/253 LESSON, adversarial CR catches what narrow-AC verification cannot; forecast 0-1 first-class PATCH + 2-4 second-class operator-edge DEFERs is band-aligned.
- **No harness infrastructure deferred to this story.** Resolver function + env-check probe both testable via bash functional tests invoked from any shell; no new test framework needed.

### Success Criteria (SCs)

1. **Volume-name invariant preserved.** `INV-devbox-homedev-named-volume` (Story 2.5) remains unchanged; the UNQUALIFIED volume name is `keel_home_dev` in both modes; only the compose-project prefix varies.
2. **Resolver single-site discipline.** `resolve_mode_specific_state` is the ONLY site that decides mode. No shim re-computes mode independently; no inline `if [[ $KEEL_DEVBOX_SHARED == true ]]` blocks outside the resolver.
3. **Compose-project-name single-source.** `KEEL_DEVBOX_COMPOSE_PROJECT` is set by the resolver; consumed by compose's `name:` key; consumed by `prereq-check.sh`'s `VOLUME_NAME`. Three sites, one source.
4. **Shared mode container-name opinionation.** Shared mode's container name is HARDCODED `keel-devbox-shared`; operator's `KEEL_DEVBOX_CONTAINER_NAME` override is INTENTIONALLY IGNORED in shared mode. Per-fork mode's override path from Story 2.1 is preserved.
5. **Exit-code preservation.** No new exit codes. Story 2.6's uniform schema (0/2/3/8/9/10/11/12) + Story 2.10's additions apply unchanged. Env-check's warning is stderr-only; exit code unaltered.
6. **Named-volume persistence across mode flips.** When operator runs `pnpm devbox:clean` in one mode, ONLY that mode's volume/container is affected (Story 2.6 AC 4 preserves volume by default; `--with-volumes` scopes to the current mode's volume). The OTHER mode's state is untouched.
7. **Parent-directory bind scope documentation.** Shared mode's bind source is the parent of the fork root; ANY file/project under that parent becomes container-visible. Documented verbatim in `packages/devbox/README.md § Per-fork vs shared mode § Shared-mode bind scope` and `docs/invariants/devbox-mode.md § Shared mode contract`.
8. **Warning string three-site lockstep.** The exact env-check warning string is pinned in `env-check.sh` (emit site) + `docs/invariants/devbox-mode.md § Mid-use flip warning` + `packages/devbox/README.md § Per-fork vs shared mode § Mid-use flip`. A typo in one site silently drifts the others (Story 2.10 DEFER-4 pattern — convention-enforced at 1.0; substrate lockstep lint is SC-17 candidate).
9. **No PRD amendment.** FR4 (`prd.md:930`) + architecture § Workspace mount (`architecture.md:547`) are unchanged. Story 2.11 is substrate-only.
10. **No CI impact.** Substrate CI (sync-gate verification, prek) exercises the manifest + INV doc sync via the existing Story 1.9 harness. No new CI jobs; no new test frameworks.
11. **Mode-detection ordering.** Resolver invocation sequence is `resolve_main_repo_and_workdir` → `resolve_mode_specific_state` → export. Any reversal breaks the `MAIN_REPO`-dependent flip logic. Pinned in every shim.
12. **Operator-interactive affordances preserved.** `pnpm devbox:shell` from fork B under shared mode lands at `/workspace/<parent>/<fork-b-basename>/` (not `/workspace/<fork-a-basename>/`) because CONTAINER_WORKDIR re-derives against the NEW `WORKTREE_ROOT`. Operator's muscle-memory `cd /workspace/<my-fork>` works as expected.
13. **Compose-config smoke reproducible.** `KEEL_DEVBOX_SHARED=true KEEL_DEVBOX_WORKSPACE=$(dirname /path/to/fork) KEEL_DEVBOX_REPO_NAME=$(basename $(dirname /path/to/fork)) KEEL_DEVBOX_COMPOSE_PROJECT=keel-devbox-shared docker compose -f packages/devbox/docker-compose.yml config` emits the correct resolved YAML with `name: keel-devbox-shared` + parent-bind source + parent-name target. Story 2.6 `docker compose config` precedent.
14. **Three-tier resolver fallback preserved.** Story 2.11 does NOT touch `resolve_main_repo_and_workdir`'s three-tier fallback (git → env override → tarball). Mode resolution composes on top; the fallback tier handling is unchanged.
15. **`.envrc.example` comment update.** `packages/devbox/.envrc.example:41` comment currently reads `Active Story 2.11; Story 2.2 publishes the knob only.` Update to past tense: `Active at Story 2.11 (landed iter-<this>). Resolver: packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_mode_specific_state().`
16. **Architecture/PRD contract alignment.** Shared mode's parent-dir bind matches architecture.md:547 verbatim — fork root's parent as bind source. No architecture drift introduced.
17. **SC-17 close-out scope carry-forward.** Inherit from Stories 2.6/2.8/2.9/2.10: DO NOT modify prior stories' docs sections in README.md / AGENTS.md; append NEW sibling sections only. Rewriting prior sections is scope-creep for Epic 2 close-out polish.

### Project Structure Notes

- **Alignment with unified project structure.** Story 2.11 lives entirely under `packages/devbox/` + `docs/invariants/devbox-mode.md` + `INVARIANTS.md` + `packages/keel-invariants/src/invariants.manifest.ts` + `packages/devbox/README.md` + `AGENTS.md`. No cross-package leakage. Source tree follows architecture.md:975-999 (packages/devbox/scripts layout, packages/keel-invariants/src/invariants.manifest.ts).
- **No detected conflicts or variances.** The change set composes cleanly on Story 2.1 (compose) + Story 2.2 (KEEL_DEVBOX_SHARED knob publication) + Story 2.5 (named volume + hardening) + Story 2.6 (shim pattern + env-check + clean.sh) + Story 2.7 (ralph shims) + Story 2.8/2.9 (auth shims) + Story 2.10 (prereq-check). Iter-239 mount-path mirroring is preserved; the resolver extension is additive.

### References

- [Source: _bmad-output/planning-artifacts/prd.md#930] FR4: Developer can select between per-fork devbox (default) and shared devbox mode via `.envrc` configuration.
- [Source: _bmad-output/planning-artifacts/prd.md#65] Executive summary FR4 paragraph: `KEEL_DEVBOX_SHARED` in `.envrc` enables shared workspace mount; default is per-fork.
- [Source: _bmad-output/planning-artifacts/prd.md#504] CLI-Tool Surface § Devbox scope: "Per-fork by default … `KEEL_DEVBOX_SHARED=true` in `.envrc` enables shared-devbox mode (one container, parent-directory mount) for N=1 dogfood."
- [Source: _bmad-output/planning-artifacts/epics.md#1512-1538] Story 2.11 epic block: 4 acceptance criteria verbatim (per-fork isolation + shared-mode attach + env-check orphan warning + concurrency doctrine).
- [Source: _bmad-output/planning-artifacts/architecture.md#547] Workspace mount contract: "Per-fork mode (default) binds `<fork-root>:/workspace:delegated`; shared mode (`KEEL_DEVBOX_SHARED=true` in `.envrc`) binds the parent directory (matches upstream's `/Users/tthew/Development:/workspace:delegated` pattern for N=1 dogfood)."
- [Source: _bmad-output/planning-artifacts/architecture.md#663] Decisions matrix: "Devbox runtime → container volume → Per-fork → `KEEL_DEVBOX_SHARED=true` override for N=1 dogfood."
- [Source: _bmad-output/planning-artifacts/architecture.md#169] Core Architectural Decisions: compose-form reference; `upstream's hardcoded /Users/tthew/Development parent-dir mount collapses into a .envrc-driven per-fork vs shared-workspace mount contract`.
- [Source: packages/devbox/.envrc.example#41] KEEL_DEVBOX_SHARED knob published by Story 2.2; Story 2.11 activates.
- [Source: packages/devbox/.envrc.example#48-49] KEEL_DEVBOX_WORKSPACE + KEEL_DEVBOX_REPO_NAME knobs; inline comment names Story 2.11 as the consumer that flips both in shared mode.
- [Source: packages/devbox/docker-compose.yml#22] Story-roadmap comment: `Story 2.11 : shared-workspace mode (KEEL_DEVBOX_SHARED=true).`
- [Source: packages/devbox/docker-compose.yml#39] Top-level `name: keel-devbox` — Task 2 parameterises to `${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}`.
- [Source: packages/devbox/docker-compose.yml#103-107] Workspace-mount doc-block Story 2.11 forward-compat paragraph — Task 2 converts to past-tense landed note.
- [Source: packages/devbox/docker-compose.yml#112-118] Volumes block: bind + named volume (Story 2.5) — Story 2.11 does NOT edit the volumes block; resolver drives the bind source/target via env var interpolation at compose-up time.
- [Source: packages/devbox/docker-compose.yml#239] TODO marker for Story 2.11 — Task 2 removes.
- [Source: packages/devbox/scripts/lib/main-repo-resolver.sh#56-100] `resolve_main_repo_and_workdir()` — Task 1 adds sibling `resolve_mode_specific_state()` in same file.
- [Source: packages/devbox/scripts/env-check.sh#77] REQUIRED_VARS includes `KEEL_DEVBOX_SHARED` (published by Story 2.2); Story 2.11 activates.
- [Source: packages/devbox/scripts/env-check.sh#89] env-check's `.envrc` file-unreadable exit 3; Story 2.11 does NOT alter exit schema.
- [Source: packages/devbox/scripts/prereq-check.sh#34] `VOLUME_NAME="${KEEL_DEVBOX_COMPOSE_PROJECT:-keel-devbox}_keel_home_dev"` — consumes resolver output; Task 3 ensures resolver runs first.
- [Source: packages/devbox/scripts/clean.sh#40-44] clean.sh current behaviour: tears down CURRENT compose project; preserves volume by default. Story 2.11 relies on this behaviour unchanged — no edits.
- [Source: packages/devbox/scripts/start.sh#52-55] start.sh sources main-repo-resolver + exports WORKSPACE + REPO_NAME; Task 3 adds `resolve_mode_specific_state` invocation + `KEEL_DEVBOX_CONTAINER_NAME` export after the existing calls.
- [Source: packages/keel-invariants/src/invariants.manifest.ts#3-15] InvariantSchema five-field shape — Task 5 compliance.
- [Source: packages/keel-invariants/src/sync-gate.ts#24] Anchor regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` — Task 5 INVARIANTS.md bullet compliance.
- [Source: docs/invariants/devbox-hardening.md (Story 2.5)] INV-devbox-homedev-named-volume authoritative doc; Story 2.11 doc cross-references for named-volume relationship.
- [Source: docs/invariants/devbox-prereq-check.md (Story 2.10)] INV-devbox-prereq-check; Story 2.11 Task 5 INV doc is sibling + Tier 1/Tier 2 probe of `${KEEL_DEVBOX_COMPOSE_PROJECT}_keel_home_dev` depends on resolver output.
- [Source: docs/invariants/fork.md § Amendment-vs-fork decision tree (Story 1.16)] Substrate default preservation; fork-level `INVARIANTS.fork.md` additive rules; Task 5 § Invariant stability.

## Dev Agent Record

### Agent Model Used

_(filled by `/bmad-dev-story` at dev-story landing; canonical form e.g. `claude-opus-4-7[1m] via bmad-agent-dev subagent`)_

### Debug Log References

_(filled by dev-story)_

### Completion Notes List

_(filled by dev-story)_

### File List

_(filled by dev-story — anticipated list per Tasks 1-6: `packages/devbox/scripts/lib/main-repo-resolver.sh` (edit), `packages/devbox/docker-compose.yml` (edit), `packages/devbox/scripts/*.sh` (18 edits), `packages/devbox/scripts/env-check.sh` (edit — also in the 18), `packages/keel-invariants/src/invariants.manifest.ts` (edit), `docs/invariants/devbox-mode.md` (new), `INVARIANTS.md` (edit — append anchor bullet), `packages/devbox/README.md` (edit — append H2), `AGENTS.md` (edit — append H3), `packages/devbox/.envrc.example` (edit — comment update per SC-15))._

## Change Log

### v1.0 — 2026-04-23 Story 2.11 create-story landing (iter-254)

- **Initial draft** authored by `/bmad-create-story` fresh-context (iter-254; Ralph auto-advance routing per § Cross-epic within-epic path after Story 2.10 closure at iter-253).
- **4 ACs** transcribed verbatim from `_bmad-output/planning-artifacts/epics.md:1512-1538` (Story 2.11 block) with expansion on AC 4 concurrency decision (serialised Ralph TUI pinned as the implementation choice; alternatives A/B/C documented in § Dev Notes § Concurrency decision).
- **6 Tasks** spanning resolver extension (Task 1) + compose parameterisation (Task 2) + 18-shim wire-in (Task 3) + env-check orphan warning (Task 4) + INV manifest + doc (Task 5) + operator + agent documentation + Change Log housekeeping (Task 6).
- **17 SCs** pinning the non-functional invariants (volume-name preservation, resolver single-site discipline, exit-code schema stability, warning string three-site lockstep, no PRD amendment, etc.).
- **Forecast carry-forward from iter-253 LESSON:** CR PATCH forecast 0-1 first-class PATCH + 2-4 second-class operator-edge DEFERs; chain reset per Story 2.10 post-close (Stories 2.11..2.17 begin fresh ZERO-PATCH-CR forecast cycle with the iter-251/253 LESSONS baked into impl-time discipline).
- **Substrate composition.** Story 2.11 depends on Stories 2.1 (compose), 2.2 (`.envrc.example` knob publication), 2.5 (named volume), 2.6 (shim pattern + env-check), 2.7 (ralph shims), 2.8 (claude-host), 2.9 (gh-auth-host), 2.10 (prereq-check). Resolver extension pattern, Compose `name:` parameterisation, and env-check orphan-container warning all compose cleanly on precedent patterns.
- **No PRD amendment.** FR4 at `prd.md:930` + architecture § Workspace mount at `architecture.md:547` verbatim matches Story 2.11's contract; substrate-only delivery.
- **Status:** `ready-for-dev` (sprint-row); Ralph-internal Story State `drafted`. Next iter: pre-dev `/bmad-create-story (args: "review")` gate (`drafted → validated`).
