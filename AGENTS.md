# Agent instructions — ralph-bmad

This file is the provider-neutral guide for any AI coding agent working in this repo (Claude Code, Codex, etc.). Claude Code reads `CLAUDE.md`, which points here.

## What this project is

`ralph-bmad` is scaffolded with the [BMad Method](https://docs.bmad-method.org) — a skill-driven workflow that takes a software idea through analysis, planning, solutioning, and implementation using AI agents.

The install is fresh. There is no product code yet. The first real work is a planning artifact (PRD, product brief, or PRFAQ), not code.

## Promotion rules

Where content belongs, by audience and scope. When you learn something new during a session, promote to the correct file.

| Audience / scope                            | File                                          |
| ------------------------------------------- | --------------------------------------------- |
| Applies to every AI agent (ops + truth)     | `AGENTS.md`                                   |
| Claude-Code-specific (skills, settings)     | `CLAUDE.md`                                   |
| Ralph-gotchas (iteration-loop lessons)      | `RALPH.md`                                    |
| Machine-enforced (config/rule/gate in code) | `INVARIANTS.md` + `packages/keel-invariants/` |

## Where things live

| Path                                     | What's there                                             |
| ---------------------------------------- | -------------------------------------------------------- |
| `_bmad/`                                 | BMad installation: modules, configs, skill manifests     |
| `_bmad/_config/manifest.yaml`            | Installed module versions                                |
| `_bmad/_config/bmad-help.csv`            | Catalog of every skill, phase, and menu code             |
| `_bmad-output/planning-artifacts/`       | PRDs, architecture, epics, UX specs (committed)          |
| `_bmad-output/implementation-artifacts/` | Stories, sprint plans (committed)                        |
| `_bmad-output/test-artifacts/`           | Test plans, traceability, gate decisions (committed)     |
| `.claude/skills/`                        | Skill definitions — the source of `/skill-name` commands |
| `docs/`                                  | Human-curated project knowledge base                     |

## How to work here

1. **Orient first.** Run `/bmad-help` (or read `_bmad/_config/bmad-help.csv`) to see what phase the project is in and what the next required step is.
2. **One skill per context window.** BMad skills assume a clean context. Don't chain several skills in one session — start a fresh conversation for each.
3. **Artifacts belong in `_bmad-output/`.** Don't scatter PRDs, stories, or test plans elsewhere. Follow the `output-location` declared in each skill.
4. **Respect required gates.** The `required=true` rows in `bmad-help.csv` are blocking — don't skip Create PRD, Create Architecture, Create Epics & Stories, Implementation Readiness, Sprint Planning, Create Story, or Dev Story unless the user explicitly opts out.
5. **Don't invent skills.** Only invoke skills listed in the Claude Code `available-skills` block or explicitly typed as `/<name>` by the user.

## Project conventions

- Communication language: **English**
- Document output language: **English**
- User: Tthew, intermediate skill level (see `_bmad/bmm/config.yaml`)
- Keep responses terse; the user prefers signal over ceremony.

## Git / PR conventions

- `main` is the default branch and the PR target.
- Branch names: `chore/*`, `feat/*`, `fix/*`, or `docs/*` — match the scope.
- Never force-push to `main`. Never skip hooks or signing.

## Fork extension (FR44)

Forks extend substrate ESLint rules without editing `packages/keel-invariants/` by creating `eslint.config.fork.js` at the fork root and importing `@keel/keel-invariants/eslint` (subpath export declared at `packages/keel-invariants/package.json:14`). Canonical copy-ready example:

```js
import sharedConfig from '@keel/keel-invariants/eslint';

export default [
  {
    rules: {
      /* fork-specific rules */
    },
  },
  ...sharedConfig, // substrate LAST → substrate wins (docs/invariants/fork.md § Precedence)
];
```

- **Precedence rule.** Substrate rules take precedence over fork rules at the same file glob via ESLint flat-config last-write-wins semantics + the spread-at-end convention. Forks that want the opposite posture (fork-wins) spread substrate FIRST; this is unusual and should carry a comment in the fork's `eslint.config.fork.js` explaining why.
- **Amendment-vs-fork decision.** Three paths when a fork disagrees with substrate: (a) FORK — fork-specific need, use `eslint.config.fork.js`; (b) AMEND — substrate-wide need, open a PR against `packages/keel-invariants/` + `INVARIANTS.md` + manifest entry + anchor bullet (the Story 1.6 + 1.9 source-level fork path); (c) DEFER — premature need, log in `_bmad-output/implementation-artifacts/deferred-work.md`.
- **Growth-tier `INVARIANTS.fork.md`.** See `docs/invariants/fork.md` § INVARIANTS.fork.md scaffold for the Growth-tier opt-in flow; Epic 15a's `create-keel-app --include-fork-invariants` flag is the downstream runtime automating the manual template copy.

## Devbox iteration environment

The `cc-devbox` container has Docker installed per [`docs.docker.com/engine/install/ubuntu/`](https://docs.docker.com/engine/install/ubuntu/). `docker`, `docker compose`, and the Docker socket are available to the Ralph subprocess. Docker availability is a **fork-time substrate requirement** codified by `INV-devbox-dind-available` (`docs/invariants/devbox-dind.md`) — every fork's cc-devbox-equivalent environment must provide it so Ralph can exercise full-stack vertical slices against services, architecture, and infrastructure (Epic 2 Docker-gated tasks, Epic 6 RLS debugger, Epic 13 CI harness smokes). NFR2 cold/warm benchmarks remain authoritative on the M4-Pro operator workstation; DinD runs are indicative baselines only.

**Two backends satisfy the invariant** (see `docs/invariants/devbox-dind.md` § Backend contract): **A** = true Docker-in-Docker (isolated daemon), **B** = host socket-passthrough (`/var/run/docker.sock` bind-mounted; daemon is the host's). Keel's reference environment at 2026-04-21 uses backend B. **Safety rule — critical under B:** broad-state-mutation scripts (`docker system prune`, `docker volume prune`, `docker image prune -a`, `docker rm -f $(docker ps -aq)`) MUST detect the backend and refuse destructive ops by default; they destroy unrelated host projects otherwise. Prefer scoped ops (`docker image rm keel-devbox:local`, `docker compose down --rmi local --volumes`) that are safe under either backend. `packages/devbox/scripts/benchmark.sh` is the reference implementation of this gate.

### Per-fork whitelist override (Story 2.4)

The egress allow-list composes from three sources in order: `packages/devbox/whitelist.default.txt` (substrate baseline), `packages/devbox/whitelist/*.txt` (sorted category fragments — npm, anthropic, github), and `packages/devbox/whitelist.local.txt` (per-fork override; gitignored per Story 2.4 SC-3). Composition is **additive-only**: the override CANNOT remove substrate domains. Final `sort -u` dedupes; fail-closed default + IPv4/IPv6 parity + atomic-reload semantics from `INV-devbox-egress-contract` are unchanged.

- **Mutation:** `pnpm devbox:whitelist add <domain>` / `remove <domain>` edit `whitelist.local.txt` atomically under a mutation lock (fd 201 — disjoint from reload-egress.sh's fd 200) then invoke `sync`. `pnpm devbox:whitelist sync` recomposes + validates + reloads (no mutation). `pnpm devbox:whitelist list` prints composed state with source attribution (`D` = default, `F:<name>` = fragment, `L` = local override).
- **AMEND path (substrate edits):** baseline + fragment edits go through source-level PRs subject to prek gates (FR44 AMEND), not the runtime CLI. `whitelist.sh remove <substrate-domain>` errors with operator education; substrate domains are immutable from the override.
- **Growth-tier `INVARIANTS.fork.md`:** if a fork opts into the Growth-tier scaffold (`docs/invariants/fork.md` § INVARIANTS.fork.md scaffold), fork-owned invariants MAY NOT relax the fail-closed default, IPv4/IPv6 parity, or atomic-reload semantics — the per-fork path is strictly additive.

### Container hardening (Story 2.5)

Codified as `INV-devbox-homedev-named-volume` (`docs/invariants/devbox-hardening.md`). Layered-barrier posture satisfying NFR7 + NFR8 + NFR8a + NFR10; static drift detected by the Story 1.9 sync-gate. Runtime compose-shape check deferred to Story 2.17 / `packages/keel-invariants/src/check-devbox-compose-shape.ts`.

- **Non-root `dev` user** (UID/GID 1000): Dockerfile emits `groupadd --gid 1000 dev && useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home dev` + `chown -R dev:dev /home/dev` + `USER dev` before `ENTRYPOINT`. Stable UID 1000 is load-bearing for first-boot `keel_home_dev` named-volume auto-init (Docker populates empty volumes from image-layer ownership).
- **Capability bounding set**: `cap_drop: [ALL]` + `cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE]` (three narrow caps). `NET_ADMIN` for nftables netlink (Story 2.3); `NET_RAW` for dnsmasq raw-socket probes; `NET_BIND_SERVICE` for dnsmasq port 53 bind under `cap_drop: [ALL]` (the bounding set without this cap rejects `:<1024` bind even from root-equivalent processes — SC-4 reconciles AC 2's drafted two-cap list with the port-bind interaction). `CAP_CHOWN` is NOT added; entrypoint's runtime chown calls fail-tolerant under dropped CAP_CHOWN.
- **`no-new-privileges:true`**: `security_opt: [no-new-privileges:true]` sets `PR_SET_NO_NEW_PRIVS=1` on PID 1 — kernel masks file-cap `F(effective)` on exec + disables setuid-bit elevation. Capability propagation uses Docker ≥19.03 ambient-cap automation via `prctl(PR_CAP_AMBIENT_RAISE)`, surviving exec() regardless of NNP (capabilities(7) design). `setcap +eip` on `/usr/sbin/dnsmasq` + `/usr/sbin/nft` in the Dockerfile remains as a portability fallback for older Docker / Podman-compat runtimes without automated ambient-cap handling.
- **tmpfs posture**: `/tmp` + `/var/tmp` long-syntax tmpfs mounts with `exec=false,suid=false` (kernel `noexec,nosuid`). Sizes parameterised via Story 2.2's `KEEL_DEVBOX_TMPFS_TMP_MB` / `KEEL_DEVBOX_TMPFS_VARTMP_MB` knobs per NFR8a. `/var/log` intentionally NOT tmpfs-mounted (dnsmasq/nftables logs live under `/workspace/logs/` per Story 2.3 SC-17); `KEEL_DEVBOX_TMPFS_LOGS_MB` remains an inert knob at 1.0.
- **Named volume `keel_home_dev` for `/home/dev`**: substrate-authoritative, non-toggle-able — no `KEEL_DEVBOX_*` setting can flip this to a host bind-mount. Claude Code tokens (Story 2.8), `gh` tokens (Story 2.9), shell history live only inside this volume. NFR10 supersedes upstream cc-devbox's `./dev-home:/home/dev:delegated` bind-mount pattern.
- **Runtime chown best-effort**: entrypoint.sh's `chown` calls on `/workspace`, `/home/dev/.claude`, `/home/dev/.config/gh` are expected to fail under dropped CAP_CHOWN. Failures capture stderr + continue (harmless no-op on most hosts where bind-mount UID passthrough already aligns workspace with dev UID 1000). Operators align their host UID with container UID 1000 for seamless workspace permissions.
- **Live smokes operator-workstation-deferred**: AC 1–5 + capability-exercise smokes run on M4-Pro native Docker Desktop. DinD backend B cannot safely exercise `docker exec` sequences against cap-dropped containers (risk of poisoning host docker state) — substrate CI + operator smoke handle AC verification together.
- **Story 2.4 whitelist.sh compatibility**: state files under `/run/` require Docker's tmpfs auto-mount to preserve image-layer ownership under USER dev. Happy path (SC-14 branch (i)) requires no code change; empirical verification deferred to operator smoke.

### Host-side CLI (Story 2.6)

Canonical devbox invocation surface is `pnpm devbox:<verb>` at the repo root — 13 verbs (`build`, `rebuild`, `start`, `stop`, `restart`, `clean`, `shell`, `attach`, `status`, `logs`, `monitor`, `whitelist`, `env:check`). Never call `docker`, `docker compose`, or `docker exec` directly (FR1). Host-side scripts live under `packages/devbox/scripts/`; `monitor-host.sh` and `whitelist-host.sh` are thin shims that `docker exec` into Story 2.3 + Story 2.4 in-container primitives.

- **Pre-flight:** `pnpm devbox:env:check` validates `.envrc` presence + every required `KEEL_DEVBOX_*` var + tmpfs-int shape. Fail-closed exit 2 on missing var or shape violation, exit 3 on `.envrc` absent. `pnpm devbox:start` runs env-check as its own pre-flight unless `KEEL_DEVBOX_START_SKIP_ENV_CHECK=true`.
- **Named-volume preservation:** `pnpm devbox:clean` preserves `keel_home_dev` (NFR10) by default. `--with-volumes` gates on `[y/N]` prompt (or `--yes`); under backend B an additional `--force-backend-b` flag is required to prevent surprise destruction of a host-shared volume.
- **Uniform exit codes:** `8` = docker unreachable (`docker info` failed; hint: is the daemon running?); `9` = container not running (hint: `pnpm devbox:start`); `10` = image not built (hint: `pnpm devbox:build`); `11` = `start` healthcheck timeout (container left running for `pnpm devbox:logs` debug). Codes `2`/`3`/`4`/`5–7` mirror Story 2.3/2.4's in-container primitives where the shim passes through.
- **Monitor semantic:** `pnpm devbox:monitor` is the FR1a JSONL DNS-event tail (PRD `:494`, architecture `:1003`), NOT `docker stats`. Epics AC 7's "cpu/memory/network" phrasing is historical drift; PRD is authoritative.
- **Cross-reference:** § Per-fork whitelist override (Story 2.4) for `pnpm devbox:whitelist` subcommand semantics; § Container hardening (Story 2.5) for the substrate contracts every host-side script composes on top of.

### Ralph loop (Story 2.7)

`pnpm ralph:build` and `pnpm ralph:plan` are the FR2 invocation path for the Ralph iteration loop. Each is a host-side shim under `packages/devbox/scripts/` (`ralph-build-host.sh` + `ralph-plan-host.sh`) that auto-starts the devbox if stopped, then `docker attach`es the operator terminal to the container's PID 1. Agents MUST invoke Ralph via these wrappers — NEVER call `docker attach`, `docker compose`, or `ralph.py` directly (FR1 non-toggle-able invariant, extended from Story 2.6's 13-verb surface to the 2-verb ralph surface).

- **Wrapper pattern:** `ralph-build-host.sh` + `ralph-plan-host.sh` follow Story 2.6's `<verb>-host.sh` naming. Both scripts are structural mirrors — only the `RALPH_MODE` value (`build` vs `plan`) and the log-prefix token differ. `_lib.sh` extraction is deferred (Story 2.6 AR-19; Story 2.7 SC-14) until the shim count crosses the substrate-wide refactor threshold.
- **Mode signal:** each wrapper exports `KEEL_RALPH_MODE=build|plan` before `exec docker attach`. Epic 3's in-container Ralph runtime reads this env var at startup to select `.ralph/PROMPT_build.md` or `.ralph/PROMPT_plan.md`. Mode is a container-lifecycle attribute — one mode per container-start; switching modes requires `pnpm devbox:stop && pnpm ralph:<mode>`.
- **Exit-code passthrough:** Story 2.6's uniform schema (`0`/`8`/`9`/`10`/`11`/`*`) is preserved unchanged. No new exit codes. Post-auto-start `status` re-inspect emits exit `9` if the container exited between `start.sh`'s success and the attach call (rare race); otherwise exit `9` is unused for the ralph wrappers.
- **Scope carve-out:** Story 2.7 ships the invocation path only. The in-container Ralph TUI process (long-running Textual app consuming `packages/devbox/tui/theme.py` from Story 1.12, rendering kanban + log + context-meter panels, preserving state across attach/detach) is Epic 3's delivery. Under the current `CMD: [sleep, infinity]`, AC 3 reduces to "container keeps running after detach" and AC 4 reduces to "no state to preserve"; both are trivially satisfied until Epic 3 materializes.

## Ralph loop

- `ralph.py` is the TUI loop orchestrator. Run with `uv run ralph.py [build|plan] [N]`.
- Loop prompts live at `.ralph/PROMPT_build.md` and `.ralph/PROMPT_plan.md`.
- `RALPH.md` is Ralph's private journal — signposts, lessons, gotchas, decisions. Ralph reads it on orient and updates it before committing.
- Halt + plan-file + PROMPT + logs resolve to `$RALPH_BASE_DIR` (an absolute path ralph.py exports to every subprocess). When `--worktree X` is set, `$RALPH_BASE_DIR = <main_repo>/.claude/worktrees/X/.ralph/`; otherwise cwd-relative `.ralph/`. Write halt via `$RALPH_BASE_DIR/halt` — never a hardcoded main-repo absolute path.
- **Cross-epic transitions auto-advance in build-mode** (FR14n 2026-04-21): when the current epic's last story is `done` and the PR has merged, Ralph queues `/bmad-create-story` for the next epic's first story — no plan-mode roundtrip, no re-halt loop. See `.ralph/PROMPT_build.md` § Cross-epic transition.
- **Halt autonomy guardrail** (`INV-ralph-halt-reason-enum`): every halt reason is bounded; Ralph never halts waiting for open-ended human input; `AskUserQuestion` is not invoked from the runtime loop. Closed reason-set at 1.0: `EPIC_DONE`, `ALL_EPICS_DONE`, `AWAIT_MERGE`, `BUDGET_EXHAUSTED`, `CI_BLOCKED`, `SECURITY_CRITICAL`, `RALPH_STAGE_REGRESSION`.
- Full reference: [docs/ralph.md](./docs/ralph.md) — see § Halt path resolution + § Halt schema.

## When you're unsure

Prefer `/bmad-help` over guessing. If that doesn't resolve it, read the relevant `SKILL.md` under `.claude/skills/` — every skill is self-describing.
