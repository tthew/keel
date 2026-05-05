# Invariant — Devbox iteration substrate (Docker-in-Docker)

**Scope:** every Ralph iteration on any Keel-forked repo whose iteration environment is a `cc-devbox`-equivalent container.
**Status:** non-toggle-able at the substrate level; fork-time requirement.
**Machine-enforced in:** spec-enforced at 1.0 (this doc is the source of truth); runtime check implementation deferred to a dedicated `packages/keel-invariants/` rule + unit test on a later Ralph iteration.
**Normative reference:** `_bmad-output/planning-artifacts/architecture.md` § I5 §Devbox-Reference-Config; `AGENTS.md` § Where things live.

## INV-devbox-dind-available

Stable ID for the invariant authored by this doc — pinned in `packages/keel-invariants/src/invariants.manifest.ts` (content-hash of this file) and anchored in `INVARIANTS.md` § Devbox iteration substrate (Story 2.1). Story 1.9's pre-merge sync-gate (FR43) detects drift between this doc's on-disk sha256 and the manifest's `contentHash` field, and between the manifest's `anchors: ['INV-devbox-dind-available']` entry and the matching `INVARIANTS.md` bullet. The heading is intentionally the bare stable-ID string so `grep '## INV-devbox-dind-available' docs/invariants/devbox-dind.md` makes the manifest's anchor claim self-verifiable without cross-file traversal.

## The invariant

The Ralph iteration environment MUST provide a **functional** Docker runtime — daemon reachability alone is NOT sufficient.

Concretely:

- `docker` is on PATH (`command -v docker` exits 0).
- `docker info` succeeds against a reachable daemon (unix socket at `/var/run/docker.sock` is the canonical transport; a fork MAY substitute a remote transport so long as `docker info` succeeds).
- `docker compose` is available as a subcommand (Compose v2+).
- `docker run --rm hello-world` exits 0. This is the **functional** criterion: image pull + layer registration + overlayfs mount must all succeed, proving the runtime can actually execute containers — not just that the daemon started. Future-substrate verification MUST include this smoke.

## Why

Ralph executes full-stack vertical slices against services, architecture, and infrastructure inside a fork's devbox. That work — Epic 2 Docker-gated tasks, Epic 6 RLS debugger invocation, Epic 13 CI harness smokes, every story whose AC exercises container behaviour — is predicated on Docker being present in the same subprocess environment that runs `claude -p`.

Prior to 2026-04-21, the Ralph container had no `docker` binary and no socket mount. That produced the Story 2.1 iter-99..iter-120 "detect-delta no-op" holding pattern (see `RALPH.md` § Signposts 2026-04-21): 21 iterations of waiting for an out-of-band operator workstation to run the bake and commit the results. Codifying Docker-in-Docker (DinD) as a fork-time substrate requirement closes that gap and lets Ralph close Docker-gated partials in-iteration.

## Backend contract: isolated DinD vs host socket-passthrough

The invariant asserts reachability + function, NOT which backend. Two patterns satisfy it:

**A. True Docker-in-Docker (isolated daemon).** Inside the iteration container, a separate `dockerd` runs against an inner storage driver. Containers, images, and volumes created from iteration code are ISOLATED from any host Docker state. `docker system prune` affects only the isolated daemon; the blast radius is bounded by the container.

**B. Host socket-passthrough.** `/var/run/docker.sock` is bind-mounted from the host; the `docker` CLI inside the iteration container talks to the HOST daemon. Containers, images, and volumes created from iteration code share state with every other host container — including unrelated projects. `docker system prune` destroys HOST state; the blast radius escapes the container.

Both backends satisfy the invariant's functional criterion (`docker run hello-world` exits 0 under either). Forks pick whichever their host environment supports. Keel's reference cc-devbox iteration environment at 2026-04-21 uses **backend B** (socket-passthrough to Docker Desktop on the operator's macOS host), discovered empirically at Story 2.1 iter-122: `docker info --format '{{.Name}}'` returns `docker-desktop`; `docker ps -a` lists containers belonging to unrelated host projects (supabase instances, mcp servers, the cc-devbox container itself).

### Safety rule (both backends, stricter under B)

Scripts that mutate **broad** Docker state — `docker system prune`, `docker volume prune`, `docker image prune -a`, `docker network prune -f`, `docker rm -f $(docker ps -aq)`, or equivalent compound ops — MUST:

1. **Detect the backend at runtime.** Canonical heuristic: `docker info --format '{{.Name}}'` matches a host-level identifier (`docker-desktop`, `moby`, `linuxkit-*`), OR `/.dockerenv` exists inside the running container AND the daemon's `.Name` does not match the container's `hostname`. Either signal implies backend B.
2. **Refuse destructive ops under backend B** by default. Require an explicit override flag from the caller (the caller accepts that the blast radius escapes the container).
3. **Prefer scoped ops** — `docker image rm keel-devbox:local`, `docker compose down --rmi local --volumes`, `docker builder prune --filter label=project=keel-devbox` — that only touch project-scoped state. Scoped ops are safe under either backend.

`packages/devbox/scripts/benchmark.sh` absorbs this safety rule at 2026-04-21 iter-122: the cold-pass `docker system prune -af --volumes` is gated behind a backend-B refusal (exit 2 with a guidance message), with `--skip-cold` (warm-only; safe everywhere) or `--allow-broad-prune` (explicit blast-radius acceptance) as escape hatches. Under backend B, the only autonomous measurement a Ralph iteration can produce is warm-only; authoritative cold measurement remains native-only per § NFR2 authority.

## Scope: substrate, not fork

This is an upstream substrate rule, not a fork-specific one. `INVARIANTS.fork.md` rules are additive and cannot override substrate rules (per `docs/invariants/fork.md` § Precedence). Every fork's cc-devbox-equivalent environment must provide Docker; a fork that disagrees pursues the AMEND path (source-level fork against this doc + `invariants.manifest.ts` + `INVARIANTS.md` anchor), not the FORK path.

## Reference setup

The canonical installation path is the upstream Docker Engine apt repository for Ubuntu 24.04 LTS:

- Source: [docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/).
- Host: cc-devbox container (itself `FROM ubuntu:24.04` per `packages/devbox/Dockerfile`).
- Backend choice: A (true DinD) where the host supports a nested daemon; B (host socket-passthrough) where it does not. See § Backend contract for the operational difference.

Forks MAY substitute other transports (remote socket, rootless Docker, Podman-compat shim). The invariant asserts daemon reachability + function, not a specific install mechanism.

## NFR2 authority: unchanged by backend

Docker-in-Docker availability does NOT change AC 4 scope clarification for Story 2.1. NFR2 cold/warm benchmarks remain authoritative on the operator's M4-Pro native workstation. Benchmark runs inside the iteration environment (either backend) MAY land in `packages/devbox/README.md § Benchmarks` but MUST be flagged `host: DinD (cc-devbox) — modelled indicative baseline; AC 4 authoritative run still owed on M4-Pro per scope clarification`, carrying a `uname -a` + `docker --version` + backend-detection (`A`/`B`) fingerprint that distinguishes them from native runs (same modelled-vs-empirical-honesty pattern as architecture.md § NFR28b).

Under backend B, the cold measurement is impractical (broad prune is unsafe against the host daemon) — warm-only via `benchmark.sh --skip-cold` is the only measurement a Ralph iteration can produce autonomously; the cold number comes from native bakes only.

Forks running on non-M4-Pro hardware retune via `packages/devbox/.envrc` knobs (Story 2.2) rather than blocking on the baseline budget.

## Enforcement

**At 1.0 (this doc):** spec-enforced only. The invariant is registered in `packages/keel-invariants/src/invariants.manifest.ts` with this doc as `sourcePath`; drift between manifest and this doc is caught by Story 1.9's pre-merge sync-gate (FR43).

**Deferred (future Ralph iteration):** a runtime check in `packages/keel-invariants/src/check-devbox-dind.ts` (or equivalent) that asserts (a) `command -v docker && docker info` exit 0, (b) `docker run --rm hello-world` exits 0, (c) records the detected backend (A/B) for downstream consumers to gate on. Wired into the `pnpm keel-invariants:check-all` composite invocation. That code + unit test lands on a dedicated Ralph iteration after Story 2.1 closes; QUEUE item tracked in `.ralph/@plan.md`.

## Consumption

- **Humans / AI agents:** read this file; when onboarding a fork, ensure the fork's cc-devbox-equivalent has Docker installed before running Ralph. If backend B is the likely environment, understand that broad-state-mutation scripts must be gated per § Safety rule.
- **`AGENTS.md` § Devbox iteration environment:** references `INV-devbox-dind-available` for the one-line operational statement + the § Safety rule for broad-mutation scripts.
- **`RALPH.md` § Signposts:** references this invariant to explain why the iter-99 "no docker" precedent is obsolete + the iter-122 backend-B discovery.
- **`_bmad-output/planning-artifacts/architecture.md` § I5:** references this invariant when the devbox reference config is elaborated.
- **`packages/devbox/scripts/benchmark.sh`:** implements the § Safety rule backend detection + refuse-destructive guard.
- **Story 1.9 sync-gate (`INV-tokens-sync-gate` companion pattern):** at pre-merge, asserts this file's content hash in `invariants.manifest.ts` matches its on-disk hash.

## Extension (FR44)

Fork operators who need a fork-specific override (e.g. Podman instead of Docker) document the substitution in their fork's `INVARIANTS.fork.md` under a `FORK-<fork-slug>-devbox-<slug>` entry and amend their fork's `eslint.config.fork.js` / CI if needed. The substrate invariant remains unchanged; forks extend additively. If the substitution contradicts the assertion (daemon unreachable, or function broken, or safety rule inapplicable), that is an AMEND-path change against this doc, not a fork-local override.
