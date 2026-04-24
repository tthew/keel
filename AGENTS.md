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
- **tmpfs posture**: `/tmp` + `/var/tmp` long-syntax tmpfs mounts with canonical kernel flags `noexec,nosuid` (iter-238 switched from the older Compose-style `exec=false,suid=false` pair, which Docker 29 rejects on `suid=false`). Sizes parameterised via Story 2.2's `KEEL_DEVBOX_TMPFS_TMP_MB` / `KEEL_DEVBOX_TMPFS_VARTMP_MB` knobs per NFR8a. `/var/log` intentionally NOT tmpfs-mounted (dnsmasq/nftables logs live under `/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/` per Story 2.3 SC-17); `KEEL_DEVBOX_TMPFS_LOGS_MB` remains an inert knob at 1.0.
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

### Claude Code authentication (Story 2.8)

`pnpm claude` is the FR3 Claude-side invocation path — a host-side shim (`packages/devbox/scripts/claude-host.sh`) that `docker exec`s `claude` inside the running devbox as UID 1000 (`dev`). First invocation triggers the Anthropic OAuth flow on the operator's terminal; the token writes under `/home/dev/.claude/` inside the `keel_home_dev` named volume (Story 2.5 substrate; NFR10). Agents MUST invoke Claude Code via this wrapper — NEVER call `docker exec … claude` directly (FR1 non-toggle-able invariant extension from Story 2.6's 13-verb + Story 2.7's 2-verb surface to the 16-verb total surface at Story 2.8 landing).

- **Wrapper pattern:** `claude-host.sh` follows Story 2.6's `<verb>-host.sh` naming. Mirrors `shell.sh` / `attach.sh` interactive-exec structure (hardcoded `-it`, no TTY-detect gate per SC-6 — OAuth flow IS the AC, same posture as Story 2.7's `docker attach`). Deliberately does NOT set `SCRIPT_DIR` or sub-invoke `start.sh` (contrast Story 2.7 ralph wrappers which DO auto-start).
- **No auto-start (SC-4):** `pnpm claude` fails-closed with exit `9` if the container is not running. Operator runs `pnpm devbox:start` first. Contrast Story 2.7's `ralph:build`/`ralph:plan` which DO auto-start — auth is a one-off gesture, not a loop-entry gesture.
- **Token persistence contract:** `/home/dev/.claude/` lives inside `keel_home_dev` named volume (Story 2.5 § Named volume). Agents MUST NOT attempt to bind-mount, copy, surface, or inspect the token file outside the named volume. Rotation, filename, and format are upstream Anthropic contract (`@anthropic-ai/claude-code@2.1.116` baked at `Dockerfile:119`).
- **Re-auth pointer:** if Ralph's `gh push`-adjacent tooling reports a Claude Code auth failure, queue `pnpm claude` as a fix task (operator-interactive). Agents SHOULD NOT attempt automated re-auth — OAuth requires a host browser.
- **Scope carve-out:** Story 2.8 ships the host-side invocation envelope only. The OAuth semantics (URL surface, device-code exchange, token file write, refresh-on-expiry) are owned by upstream Claude Code CLI + Anthropic's OAuth endpoint. Egress whitelist covers `api.anthropic.com` + `console.anthropic.com` per Story 2.3/2.4 substrate.
- **Exit-code passthrough:** Story 2.6's uniform schema (`0` / `8` / `9` / `*`) is preserved. Codes `10` / `11` are ralph-wrapper-only (image-build + healthcheck-timeout under sub-invoked `start.sh`) — not applicable to `claude-host.sh` under SC-4 no-auto-start.
- **Cross-reference:** § Host-side CLI (Story 2.6) for shell.sh/attach.sh mirror primitives; § Ralph loop (Story 2.7) for the contrasting auto-start posture; `packages/devbox/README.md § Claude Code authentication (Story 2.8)` for operator-facing quick-start + OAuth flow walkthrough.

### gh CLI authentication (Story 2.9)

`pnpm gh:auth` is the FR3 gh-side invocation path — a host-side shim (`packages/devbox/scripts/gh-auth-host.sh`) that `docker exec`s `gh auth login` inside the running devbox as UID 1000 (`dev`). First invocation triggers the GitHub OAuth device-code flow on the operator's terminal; the URL + one-time code surface on stdout, operator opens URL in a host browser, pastes the code, and `gh` writes the token under `/home/dev/.config/gh/` inside the `keel_home_dev` named volume (Story 2.5 substrate; NFR10). Agents MUST invoke `gh auth login` via this wrapper — NEVER call `docker exec … gh auth login` directly (FR1 non-toggle-able invariant extension from Story 2.6's 13-verb + Story 2.7's 2-verb + Story 2.8's 1-verb surface to the 17-verb total surface at Story 2.9 landing).

- **Wrapper pattern:** `gh-auth-host.sh` follows Story 2.6's `<verb>-host.sh` naming and mirrors `claude-host.sh` (Story 2.8) verbatim with gh-specific substitutions (invoked subcommand `gh auth login` instead of `claude`; `[gh-auth]` log prefix; `/home/dev/.config/gh/` token path). Hardcoded `-it`, no TTY-detect gate per SC-6 — OAuth flow IS the AC, same posture as Story 2.7's `docker attach` + Story 2.8's `claude` exec. Deliberately does NOT set `SCRIPT_DIR` or sub-invoke `start.sh`.
- **No auto-start (SC-4):** `pnpm gh:auth` fails-closed with exit `9` if the container is not running. Operator runs `pnpm devbox:start` first. Mirrors Story 2.8's `pnpm claude` posture; contrast Story 2.7's `ralph:build`/`ralph:plan` which DO auto-start — auth is a one-off gesture, not a loop-entry gesture.
- **Args passthrough scope:** `"$@"` reaches `gh auth login` only — the wrapper hardcodes the `auth login` subcommand. Operators can compose `pnpm gh:auth --web`, `pnpm gh:auth --hostname github.com`, `pnpm gh:auth --scopes "repo,workflow"`, etc. For general `gh` composition (`gh pr list`, `gh pr view`, …), agents reach `gh` inside the container via `pnpm devbox:shell` first or via in-container runtime paths (Epic 3 Ralph TUI), NOT via `pnpm gh:auth`.
- **Token persistence contract:** `/home/dev/.config/gh/` lives inside `keel_home_dev` named volume (Story 2.5 § Named volume). Agents MUST NOT attempt to bind-mount, copy, surface, or inspect the token file outside the named volume. Token filename, format, and rotation are upstream GitHub-CLI contract (`gh` apt-installed at `Dockerfile:123-136`; Renovate `apt` manager-tracked per Story 1.15).
- **Re-auth pointer:** if Ralph's `gh push` / `gh pr view` / `gh pr checks` tooling reports a gh auth failure, queue `pnpm gh:auth` as a fix task (operator-interactive). Agents SHOULD NOT attempt automated re-auth — OAuth requires a host browser.
- **Ralph pre-push gate halt-able (Epic 3 scope):** when Ralph's pre-push gate (Story 3.7) detects an auth-broken gh invocation, it writes halt sentinel `{"reason":"CI_BLOCKED","note":"gh not authed — run 'pnpm gh:auth'"}` per the closed halt-reason enum (PRD FR14k + `docs/invariants/ralph-execute.md` § Halt schema). Agents inheriting Epic 3 scope MUST NOT retry the push silently or invent a new halt reason (§ Halt § Autonomy guardrail applies). Story 2.9 pins the contract; Epic 3 Story 3.7 implements the halt-write.
- **Scope carve-out:** Story 2.9 ships the host-side invocation envelope only. The OAuth semantics (URL surface, device-code exchange, token file write under `/home/dev/.config/gh/hosts.yml`, refresh-on-expiry) are owned by upstream `gh` CLI + GitHub's OAuth endpoint. Egress whitelist covers all 7 entries in `packages/devbox/whitelist/github.txt` (`api.github.com`, `github.com`, `raw.githubusercontent.com`, `objects.githubusercontent.com`, `codeload.github.com`, `ghcr.io`, `pkg-containers.githubusercontent.com`) per Story 2.3/2.4 substrate.
- **Exit-code passthrough:** Story 2.6's uniform schema (`0` / `8` / `9` / `*`) is preserved. Codes `10` / `11` are ralph-wrapper-only (image-build + healthcheck-timeout under sub-invoked `start.sh`) — not applicable to `gh-auth-host.sh` under SC-4 no-auto-start. Mirrors Story 2.8 claude-host.sh exit-code surface.
- **Cross-reference:** § Host-side CLI (Story 2.6) for shell.sh/attach.sh mirror primitives; § Ralph loop (Story 2.7) for the contrasting auto-start posture; § Claude Code authentication (Story 2.8) for the structurally-identical sibling auth verb; `packages/devbox/README.md § gh CLI authentication (Story 2.9)` for operator-facing quick-start + OAuth flow walkthrough + halt-able pointer.

### Prerequisite check (Story 2.10)

`pnpm devbox:prereq:check` is the FR5 prerequisite-check invocation path — a host-side primitive (`packages/devbox/scripts/prereq-check.sh`) that gates every host-side shim with a three-check contract (Docker runtime reachable + Claude Code authed + gh CLI authed). Runs at pre-flight on every `pnpm devbox:*` / `pnpm ralph:*` / `pnpm claude` / `pnpm gh:auth` invocation and as a standalone operator verb. Machine-enforced contract: `INV-devbox-prereq-check` (`docs/invariants/devbox-prereq-check.md`). Agents MUST invoke via the `pnpm devbox:prereq:check` verb — NEVER call `prereq-check.sh` directly from agent contexts (FR1 non-toggle-able invariant; standalone shim invocation reserved for host-side orchestrator composition).

- **Three-check contract:** (1) Docker reachable — `docker info --format '{{.ServerVersion}}'`; (2) Claude token — `alpine:3.19` read-only probe of `/home/dev/.claude/.credentials.json` inside `keel_home_dev`; (3) gh token — same probe for `/home/dev/.config/gh/hosts.yml`. Existence only, not validity (SC-15; validity is upstream CLI's concern, surfaces at actual invocation time).
- **Tier contract:** Tier 1 (Docker only) gates 15 shims (13 devbox verbs + `claude-host.sh` + `gh-auth-host.sh` — the auth-establishing verbs themselves must be runnable pre-token or Tier 2 would be circular). Tier 2 (all three) gates `ralph-build-host.sh` + `ralph-plan-host.sh` + standalone `pnpm devbox:prereq:check`. Full enumeration pinned in `docs/invariants/devbox-prereq-check.md § Tier contract`.
- **Exit-code schema:** `0` all pass (silent) / `2` one or more tokens missing (composite pointer list, Claude before gh; no partial bypass per AC 5) or unknown-arg usage / `8` Docker unreachable (install-URL pointer `https://docs.docker.com/desktop/install/` verbatim) / `12` other docker-daemon error. Extends Story 2.6 uniform schema; `9`/`10`/`11` are downstream-of-prereq-check concerns owned by individual shims.
- **Fail-mode guidance — fix-task queueing:** when `prereq-check` exits `8`, agents queue a Docker-install fix task (operator-interactive; agents do NOT attempt to install Docker autonomously). When exits `2` with Claude-missing pointer, queue `pnpm claude` as a fix task. When exits `2` with gh-missing pointer, queue `pnpm gh:auth`. When exits `2` with both pointers (fresh-fork first-run), queue `pnpm devbox:start` first (to auto-init `keel_home_dev`), then `pnpm claude`, then `pnpm gh:auth`. Agents SHOULD NOT attempt to bypass the check or inspect the probed token files directly.
- **No-bypass posture:** there is NO `--skip-claude` / `--force` / `KEEL_PREREQ_BYPASS` escape at 1.0 (AC 5). Agents MUST NOT advise operators to relax the check; fork-level relaxation requires an AMEND path (source-level PR against `docs/invariants/devbox-prereq-check.md` + manifest + `INVARIANTS.md` anchor).
- **Ralph pre-push gate halt-able (Epic 3 scope):** when Ralph's in-loop pre-push gate (Story 3.7) fires a prereq-check and it exits `8` or `2`, the gate writes halt sentinel `{"reason":"CI_BLOCKED","note":"<exact pointer string from prereq-check>"}` per the closed halt-reason enum (`INV-ralph-halt-reason-enum`; PRD FR14k). Stories 2.8 SC-10 and 2.9 SC-10 already pin `CI_BLOCKED` for Claude/gh-specific halts; Story 2.10 generalises to the composite prereq-check surface. Agents inheriting Epic 3 scope MUST NOT retry silently or invent a new halt reason.
- **Probe-image pin:** `alpine:3.19` (SC-4 + SC-7) — manually Renovate-tracked at 1.0 (default `docker` manager scans Dockerfile + docker-compose.yml only). Three source-of-truth sites must update in lockstep: `prereq-check.sh`, `docs/invariants/devbox-prereq-check.md § Alpine probe image`, `packages/devbox/README.md § Prerequisite check § Alpine probe image`.
- **Scope carve-out:** Story 2.10 ships the host-side invocation envelope + machine-enforced contract only. Docker Desktop install + OAuth flows (Claude + gh) + named-volume persistence are owned by their respective upstream concerns (Docker / Anthropic / GitHub / Story 2.5 substrate). Egress whitelist is orthogonal — the alpine pull traverses the host Docker daemon's network namespace, NOT the devbox in-container namespace.
- **Cross-reference:** § Host-side CLI (Story 2.6) for the 13-verb surface composing on Tier 1; § Claude Code authentication (Story 2.8) + § gh CLI authentication (Story 2.9) for the auth verbs whose tokens Tier 2 probes; `packages/devbox/README.md § Prerequisite check (Story 2.10)` for operator-facing quick-start + fresh-fork first-run walkthrough + exit-code reference; `INV-devbox-prereq-check` for the machine-enforced contract.

### Per-fork vs shared devbox mode (Story 2.11)

`KEEL_DEVBOX_SHARED` in `.envrc` branches the devbox between per-fork (default; strict isolation per fork root) and shared mode (`KEEL_DEVBOX_SHARED=true`; single container + single volume across forks under a common parent) per FR4. Resolution site: `packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_mode_specific_state()` — invoked AFTER `resolve_main_repo_and_workdir` by every host-side shim in the 17-verb surface + the new orphan-container warning path in `env-check.sh`. Machine-enforced contract: `INV-devbox-mode` (`docs/invariants/devbox-mode.md`).

- **Two modes, two containers, two volumes.** Per-fork: `keel-devbox` + `keel-devbox_keel_home_dev`. Shared: `keel-devbox-shared` + `keel-devbox-shared_keel_home_dev`. Bind source flips from the fork root (per-fork) to the fork root's parent directory (shared). OAuth tokens do NOT cross modes — switching modes re-auths (expected by AC 3's orphan warning).
- **Operator override:** `KEEL_DEVBOX_CONTAINER_NAME` and `KEEL_DEVBOX_REPO_NAME` are both respected in per-fork mode (Story 2.1 collision path + per-fork container-path customisation); **both INTENTIONALLY IGNORED in shared mode** (shared is opinionated — both forks must attach to the SAME container name AND resolve to the SAME `/workspace/<parent>/` bind target for AC 2; a per-fork override of either would silently break cross-fork attach or produce divergent container paths).
- **Concurrency decision (AC 4):** shared mode is single-operator-at-a-time BY CONVENTION, NOT by Docker enforcement. Concurrent `docker attach` against the same running container produces interleaved stdin/stdout I/O corruption (NOT an auto-detach-the-first behaviour). Non-Ralph operations (`pnpm devbox:shell`, `pnpm claude`, `pnpm gh:auth`) use `docker exec` which spawns independent PIDs — parallel-safe across forks. Operators needing true-parallel Ralph across forks MUST revert to per-fork mode.
- **Agent guardrail (mid-Ralph-loop flips):** agents MUST NOT advise operators to flip `KEEL_DEVBOX_SHARED` mid-Ralph-loop. Flipping requires container teardown; the AC 3 orphan warning surfaces but remediation is operator-gated (`pnpm devbox:clean`). Agents SHOULD NOT attempt to auto-detect mode from container state — the authoritative signal is `.envrc` (parsed by `env-check.sh`; exported by direnv).
- **Agent guardrail (attach semantics):** agents MUST NOT implement a "second-attach-auto-detaches-first" feature — Docker does not expose that semantic. Shared mode's concurrency story is convention-first, not machinery-first. Under Epic 3 scope, a detach during operator-shared Ralph is NOT a halt condition — operator re-attaches via `pnpm devbox:attach` (Story 2.6) or a fresh `pnpm ralph:build` (Story 2.7).
- **Mid-use flip orphan warning:** `pnpm devbox:env:check` probes `docker inspect <other-mode-container>` and emits a single stderr warning pointing at `pnpm devbox:clean` when an orphan is detected. Warning-only posture — exit code unchanged (stderr augments the `0`/`2`/`3`/`8` schema; no new exit code). Three-site lockstep: env-check emit + `docs/invariants/devbox-mode.md § Mid-use flip warning` + `packages/devbox/README.md § Per-fork vs shared mode § Mid-use flip`.
- **Cross-reference:** § Host-side CLI (Story 2.6) for the shim pattern all 18 shims extend; § Ralph loop (Story 2.7) for the attach + concurrency context; § Container hardening (Story 2.5) for the `keel_home_dev` volume substrate; `packages/devbox/README.md § Per-fork vs shared devbox mode (Story 2.11)` for operator-facing quick-start + walkthroughs; `INV-devbox-mode` for the machine-enforced contract.

### Opt-in SSH (Story 2.12)

`KEEL_DEVBOX_SSH=true` in `.envrc` opts into a pubkey-only sshd bound to `127.0.0.1:2222` inside the devbox (Story 2.12 substrate; default is `false` = no sshd, port 2222 not published). Strict-true-only normalisation (`true` case-folded; any other value fail-closes to no-SSH) via `resolve_ssh_state()` at `packages/devbox/scripts/lib/main-repo-resolver.sh`. Machine-enforced contract: `INV-devbox-ssh` (`docs/invariants/devbox-ssh.md`).

- **Loopback-bound port publication invariant.** Every published devbox port MUST use `127.0.0.1:<host>:<container>` form. New port additions in any compose override file must follow this contract. Bare `<host>:<container>` and `0.0.0.0:...` are forbidden (Docker silently binds bare-form to `0.0.0.0`).
- **SSH opt-in resolver + compose-override idiom.** The resolver exports `KEEL_DEVBOX_COMPOSE_FILE_SSH` (absolute path to `docker-compose.ssh.yml` when opt-in, empty string when no-SSH). Every compose-invoking shim (build/rebuild/start/stop/status/logs/clean/benchmark — 15 call sites across 8 files) sources `packages/devbox/scripts/lib/compose-args.sh`, calls `resolve_compose_args` to populate the `COMPOSE_ARGS` bash array, then invokes `docker compose "${COMPOSE_ARGS[@]}" <subcommand>` (Story 2.12 PATCH-5, iter-276 — superseded the prior unquoted `${KEEL_DEVBOX_COMPOSE_FILE_SSH:+-f "${KEEL_DEVBOX_COMPOSE_FILE_SSH}"}` inline form which word-split under fork repo paths containing whitespace). Agents MUST NOT inline `if [[ $KEEL_DEVBOX_SSH == true ]]` checks outside the resolver and `entrypoint.sh`.
- **Compose override file is the SINGLE site that publishes 2222.** `packages/devbox/docker-compose.ssh.yml` is included in the compose CLI only when `KEEL_DEVBOX_SSH=true`. The base `docker-compose.yml` MUST NOT have a `2222` entry in `ports:`.
- **Token persistence.** Host keys (`/home/dev/.ssh/host_keys/ssh_host_{ed25519,rsa}_key`) + `authorized_keys` (`/home/dev/.ssh/authorized_keys`) live INSIDE the `keel_home_dev` named volume (Story 2.5 substrate; NFR10). Mirrors Story 2.8/2.9 OAuth-token-persistence posture. Agents MUST NOT bind-mount, copy, surface, or inspect these files outside the named volume.
- **Re-auth pointer.** If a Ralph subagent reports an SSH connection failure to `127.0.0.1:2222`, queue `pnpm devbox:shell` + manual `~/.ssh/authorized_keys` append as a fix task (operator-interactive). Agents SHOULD NOT auto-modify `authorized_keys` from outside the container — pubkey registration is an operator-interactive gesture.
- **Container-side `ListenAddress` is INTENTIONALLY unset.** Container-loopback is disjoint from host-loopback under Docker's userland-proxy: inbound packets arrive on container `eth0`, not `127.0.0.1`. Loopback confinement is enforced solely by the host-side `127.0.0.1:2222:2222` publish in `docker-compose.ssh.yml`. Future port-publishing stories MUST single-layer host-side-confine only.
- **Mode-flip discipline.** Flipping `KEEL_DEVBOX_SSH` between `false`/`true` requires container teardown (`pnpm devbox:stop && pnpm devbox:start`) — entrypoint.sh reads the env var ONCE at container start. Mid-session flips have no effect until restart.
- **No CAP_NET_BIND_SERVICE.** Port 2222 > 1024; sshd runs as UID 1000 (`dev`) with no extra capability. The Story 2.5 `cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE]` set is unchanged; sshd does NOT consume the bind-service cap.
- **Scope carve-out.** Story 2.12 ships the opt-in sshd + loopback-bound invariant. Healthcheck-on-sshd-liveness is Story 2.13's delivery; operator lockout/revoke flow is deferred to Epic 2 close-out docs polish (Story 2.17). Agents inheriting downstream scope MUST NOT pre-emptively add a sshd healthcheck or an auto-revoke path.
- **Cross-reference:** § Container hardening (Story 2.5) for the named volume substrate; § Per-fork vs shared devbox mode (Story 2.11) for the orthogonal resolver invocation order (`resolve_main_repo_and_workdir → resolve_mode_specific_state → resolve_ssh_state`); § Claude Code authentication (Story 2.8) + § gh CLI authentication (Story 2.9) for the token-persistence pattern parallel; `packages/devbox/README.md § Opt-in SSH (Story 2.12)` for operator-facing walkthroughs; `INV-devbox-ssh` for the machine-enforced contract.

### Healthcheck (Story 2.13)

Compose-level healthcheck probes dnsmasq liveness (always) + sshd liveness (iff `KEEL_DEVBOX_SSH=true`); replaces upstream cc-devbox's broken `curl :3000` healthcheck. Canonical probe: `dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com >/dev/null && { [ "${KEEL_DEVBOX_SSH:-false}" != "true" ] || nc -z 127.0.0.1 2222; }`. POSIX sh safe (`/bin/sh` is `dash` on Ubuntu 24.04, not bash). Timing: `interval 10s` / `timeout 5s` / `retries 3` / `start_period 30s`. Machine-enforced contract: `INV-devbox-healthcheck` (`docs/invariants/devbox-healthcheck.md`).

- **Agent diagnostic pointer.** If a Ralph subagent sees `State.Health.Status: unhealthy` on the devbox, the diagnostic points at a dnsmasq or sshd failure — queue `pnpm devbox:logs keel-devbox` + inspect `/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/dnsmasq.log` and `/var/log/sshd.log` as a fix task. Agents SHOULD NOT silence the healthcheck (e.g. by editing `docker-compose.yml § healthcheck.test` to `["CMD", "true"]` — that masks real failures and is a substrate-regression).
- **Probe tooling is baked.** `dig` via `dnsutils` (`Dockerfile:61`) + `nc` via `netcat-openbsd` (`Dockerfile:64`). The BSD `nc` variant is load-bearing — `netcat-traditional` does NOT support `-z`. Do NOT switch to `curl` / `wget` / `openssl s_client` without amending `INV-devbox-healthcheck`.
- **Probe-domain lockstep.** `api.github.com` is the canonical probe domain (Story 2.9 load-bearing for every fork's `gh auth login`). If a future story removes `github.txt` from the default whitelist fragments or renames the probe domain, THREE sites must update in lockstep: (1) `packages/devbox/docker-compose.yml § services.devbox.healthcheck.test`, (2) `docs/invariants/devbox-healthcheck.md § Probe contract + § Probe domain stability`, (3) `packages/devbox/README.md § Healthcheck (Story 2.13)`. Automated drift lint deferred to Story 2.17 close-out (D-5).
- **SSH-conditional branch.** `KEEL_DEVBOX_SSH` is populated inside the container by compose-env propagation sourcing `KEEL_DEVBOX_SSH_RESOLVED` (Story 2.12 iter-273 PATCH-2 canonical stream); raw case variants (`True` / `TRUE` / `tRuE`) NEVER reach the container. Agents MAY NOT bypass the resolver and source `KEEL_DEVBOX_SSH` directly — case-folding is load-bearing.
- **Timing is substrate-authoritative.** No `KEEL_DEVBOX_HEALTHCHECK_*` knob at 1.0. Fork-local adjustment requires an AMEND PR per FR44 AMEND, not a per-fork `.envrc` override.
- **Scope carve-out.** Healthcheck scope is compose-level ONLY. The Dockerfile has no `HEALTHCHECK` directive so raw `docker run keel-devbox:local` (non-compose fork maintainer image-inspection) does NOT carry the probe — compose is the authoritative harness. Forks that want image-level `HEALTHCHECK` via Dockerfile MUST open an AMEND PR per `docs/invariants/fork.md § Amendment-vs-fork decision`.
- **Cross-reference:** § Egress policy (Story 2.3) for dnsmasq substrate; § Opt-in SSH (Story 2.12) for sshd substrate; § Host-side CLI (Story 2.6) for the `pnpm devbox:status` consumer; `packages/devbox/README.md § Healthcheck (Story 2.13)` for operator-facing walkthroughs + timing rationale table; `INV-devbox-healthcheck` for the machine-enforced contract.

### Legacy-devbox branch retention (Story 2.14)

An `origin/legacy-devbox` branch retains the pre-absorption standalone cc-devbox layout for bootstrap-handoff mitigation per PRD § Technical Risks (`prd.md:617`); retired by Story 15b.1's `scripts/major-cut.sh` at the 1.0 cut ritual (`epics.md:6293-6314`). Machine-enforced contract: `INV-devbox-legacy-branch-retention` (`docs/invariants/devbox-legacy-branch-retention.md`).

- **Triage-first discipline.** When investigating a devbox regression on `main`, the canary-then-bisect triage path at `docs/invariants/devbox-legacy-branch-retention.md § Triage path` is the documented first-step. Agents MUST consult that doc before opening a fix task on `packages/devbox/` — the canary reveals whether the regression pre-existed Story 2.1 absorption (escalate upstream) or post-dates absorption (bisect on `main` with `git bisect start HEAD 5278738 -- packages/devbox/`).
- **Cherry-pick pointer.** Security-critical upstream patches are cherry-picked manually via the workflow at `docs/invariants/devbox-legacy-branch-retention.md § Cherry-pick workflow` (CVE-class / fail-closed-egress / secret-leakage / network-exposure ONLY — NOT feature additions, NOT dependency bumps). Agents SHOULD NOT attempt automated cherry-picks — FR44 AMEND against the invariant doc would be required.
- **Retirement gate is Story 15b.1's execution, not ad-hoc.** The tag + delete + RALPH.md-decision sequence lives at `docs/invariants/devbox-legacy-branch-retention.md § Retirement gate`; Story 2.14 owns the recipe-contract that Story 15b.1's `scripts/major-cut.sh` binds against. Agents MUST NOT pre-emptively retire the branch or invent alternative retirement procedures — the contract requires post-M4-checkpoint authorisation and lockstep doc + script updates.
- **Cross-reference:** § Devbox iteration environment intro for the Docker-in-Docker substrate the canary inherits; § Healthcheck (Story 2.13) for the healthcheck contract the canary does NOT inherit — legacy-devbox carries upstream's healthcheck as-fetched (at time of Story 2.14 drafting upstream ships the broken `curl :3000` healthcheck, but dev agent MUST grep `$WT/docker-compose.yml` at Task 1 execution to record the actual state in Completion Notes); whatever the upstream state is, it's a known-divergence NOT a cherry-pick candidate per § Cherry-pick workflow scope; `packages/devbox/README.md § Legacy-devbox branch retention (Story 2.14)` for operator-facing walkthrough + triage TL;DR; `INV-devbox-legacy-branch-retention` for the machine-enforced contract.

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
