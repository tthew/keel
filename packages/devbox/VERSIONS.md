# `@keel/devbox` baked toolchain versions

Source of truth for the pinned tooling installed by the devbox image at build
time. Follow-up edits here travel with Renovate PRs — `.github/renovate.json`
(Story 1.15) ships custom managers that lift the string literals below into
trackable datasources (`npm`, `docker`, `github-releases`, `apt`).

Update this file when a new image is baked.

> **Scope reminder (Story 2.1).** `@anthropic-ai/claude-code`, `gh`, `uv`, the
> AWS CLI, the Supabase CLI, and git-delta are installed via network-accessed
> installers at image-build time; their **exact** pinned versions are
> captured here once the first successful image bake runs (see Story 2.1 AC 2
> scope clarification on version pinning). Nothing below is refreshed by
> entrypoint.sh.

## Baked at image-build (Dockerfile)

| Tool                        | Pin / source                                          | Notes                                                                                       |
| --------------------------- | ----------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| Ubuntu base                 | `ubuntu:24.04`                                        | LTS support through April 2029.                                                             |
| Node.js                     | `20.x` via NodeSource `setup_20.x`                    | Exact minor recorded per bake; `engines.node` in root `package.json`.                       |
| pnpm                        | `10.29.2`                                             | Pinned to match root `package.json@packageManager`.                                         |
| `@anthropic-ai/claude-code` | `2.1.116` (iter-128 CR-pinned; iter-123 bake capture) | `npm install -g @anthropic-ai/claude-code@2.1.116`; Renovate `npm` manager tracks bump PRs. |
| GitHub CLI (`gh`)           | apt via `cli.github.com/packages`                     | Renovate `apt` manager tracks.                                                              |
| `uv` (Astral)               | _recorded-at-bake_                                    | Official installer; captures latest stable at bake.                                         |
| AWS CLI                     | v2 (arch-aware installer)                             | Refresh on every bake.                                                                      |
| Supabase CLI                | latest release `.deb` (arch-aware)                    | Arch-aware fallback; skipped if asset missing for host.                                     |
| git-delta                   | latest release `.deb` (arch-aware)                    | Fail-closed if asset missing (diff pager is mandatory for I8 workflows).                    |
| Playwright OS deps          | `npx --yes playwright@latest install-deps` post-apt   | Reconciles apt list with Playwright's current requirement set.                              |
| `postgresql-client`         | apt (Ubuntu 24.04 default)                            | Provides `psql` for Epic 6 Story 6.5 forward-compat.                                        |

## Upstream-inherited apt extras (cc-devbox provenance)

The Dockerfile's Task 2 `apt-get install` block (L49-60) inherits a set of
general-purpose system packages verbatim from upstream
[cc-devbox](https://github.com/tthew/cc-devbox) rather than subtracting them:
`software-properties-common`, `sudo`, `tini`, `procps`, `iproute2`,
`dnsutils`, `netcat-openbsd`, `openssh-client`, `vim`, `less`, `locales`.
Their inclusion is deliberate upstream provenance, not Story 2.1 scope creep.
Each serves one of three roles: (a) it supports the baked toolchain itself
— `software-properties-common` manages the NodeSource and `cli.github.com`
apt repositories the Dockerfile wires up further down the build, and
`locales` underpins the `LANG=C.UTF-8` / `LC_ALL=C.UTF-8` normalisation so
every shell the operator drops into produces stable UTF-8 output; (b) it
is a load-bearing dependency of a named downstream Epic 2 story —
`tini` is the PID-1 signal forwarder the Story 2.5 hardening pass (non-root
`dev` user + `no-new-privileges` + `cap_drop`) relies on for clean ^C/stop
handling, `iproute2` + `dnsutils` + `netcat-openbsd` are the debugging surface
for Stories 2.3 + 2.4's egress whitelist + DNS policy work, and
`openssh-client` supports Story 2.13's sshd liveness + remote-agent flows;
or (c) it is in-container operator ergonomics at M0.5 — `sudo` for the
bind-mount ownership workaround, `vim` + `less` for on-demand edit + pager
surface, `procps` for `ps` / `top` visibility when diagnosing build hangs.
Removing any would either break a planned downstream story or silently
degrade the operator-ergonomics surface the M0.5 deliverable advertises.
Renovate tracks upstream apt bumps for this set alongside the main baked
tooling via `.github/renovate.json`'s `apt` custom manager (Story 1.15);
no additional Dockerfile structure is needed to keep the pins in review.
Scope-clarification source: Story 2.1 review cycle CR AI-9 (iter-128
Acceptance Auditor Finding 4; closed iter-137).

## Host Compose floor

`packages/devbox/docker-compose.yml` uses one feature that has a hard lower
bound on the operator's Docker Compose release:

- **`env_file:` object-form shorthand** (`path:` + `required:`) landed in
  Docker Compose **v2.20** (February 2024 — see
  [docker/compose#11365](https://github.com/docker/compose/pull/11365)).
  Story 2.1's compose file relies on `required: false` so the file parses
  even before Story 2.2 ships `.envrc.example`.

Forks running older Compose releases can either (a) upgrade Compose to
v2.20+ (recommended — current Docker Desktop + the buildx-bundled CLI both
exceed this floor at 2026-04-21), or (b) rewrite the `env_file:` block to
the v1-compatible flat-list form:

```yaml
env_file:
  - ../../.envrc
```

Fallback caveat: the flat-list form loses the `required: false` opt-out,
so a missing `.envrc` hardens into a compose-parse error rather than being
tolerated. This only matters between Story 2.1 and Story 2.2 — once
`.envrc.example` ships, the fallback is fine because forks seed their own
`.envrc` from the example. Recorded as Story 2.1 CR AI-2 (iter-128 Blind
Hunter + Edge Case Hunter).

## Epic 6 forward-compatibility roster (Story 2.1 AC 3 Dev Note)

Story 2.1 bakes every tool Epic 6's `pnpm rls:explain` (Story 6.5) will invoke
so the Epic 6 landing requires **no image rebuild**:

- `psql` ← `postgresql-client`.
- `delta` ← git-delta release asset.
- Workspace tooling (`pnpm`, `turbo`, etc.) stays on the bind-mounted
  `/workspace` and needs no image changes.

## Bake log

- **2026-04-21 (iter-129)** — **Dockerfile pin hardening (CR fix AI-1).** Not a
  bake; captures a Dockerfile edit landing in Story 2.1 review cycle.
  - `packages/devbox/Dockerfile:104-105` (pre-edit line range) — replaced the
    unpinned `npm install -g @anthropic-ai/claude-code` with the pinned
    `npm install -g @anthropic-ai/claude-code@2.1.116` based on the iter-123
    first-bake capture. Rationale: unpinned runtime tool drifts across bakes;
    Renovate (Story 1.15) raises bump PRs so the pin advances deliberately.
  - Same line pair — replaced the ambiguous `&& claude --version || true`
    (which masked a failed `npm install` because `|| true` applied to the whole
    `&& …` chain in shell-form) with the parenthesised
    `&& (claude --version || echo "claude version probe failed (install succeeded)" >&2)`
    so install failures surface as RUN exit-1 while probe flakiness stays a
    diagnostic. Rationale: CR AI-1 High verdict at iter-128.
  - Next bake re-verifies the pin resolves. Version-matrix table above already
    reflects the pinned value.

- **2026-04-21 (iter-123)** — **First successful image bake.** Safe-subset path
  (`docker compose build` only — no broad prune) on backend B
  (`INV-devbox-dind-available` § Backend contract; host socket-passthrough to
  Docker Desktop on the M4-Pro operator workstation). Closes the iter-100..120
  detection-gated wait pattern.
  - Image: `keel-devbox:local` — 848 MB, image ID `e7e91f1537f1`, platform
    `linux/arm64`.
  - Build time: ~4.5 min aggregate stage time (272.7 s across 22 build stages;
    Ubuntu base pulled locally before the run, so registry metadata latency is
    not included in this number).
  - Pinned tool versions captured from the baked image:

    | Tool                         | Version at 2026-04-21                   |
    | ---------------------------- | --------------------------------------- |
    | Ubuntu base                  | 24.04.4 LTS (Noble Numbat)              |
    | Node.js                      | 20.20.2                                 |
    | pnpm                         | 10.29.2                                 |
    | `@anthropic-ai/claude-code`  | 2.1.116                                 |
    | GitHub CLI (`gh`)            | 2.90.0 (2026-04-16)                     |
    | `uv` (Astral)                | 0.11.7                                  |
    | AWS CLI v2                   | 2.34.33 (Python 3.14.4)                 |
    | Supabase CLI                 | 2.90.0                                  |
    | git-delta                    | 0.19.2                                  |
    | `postgresql-client` (`psql`) | 16.13 (Ubuntu `16.13-0ubuntu0.24.04.1`) |

  - Scope: bake + version capture only. `pnpm test` + `pnpm lint` + NFR2
    `benchmark.sh --skip-cold` run in the next iteration (decomposed from the
    iter-123 NOW task per `.ralph/@plan.md` § Notes guardrail-9 ceiling).
  - NFR2 authority unchanged: cold-start measurement remains the M4-Pro native
    path per AC 4 scope clarification. Backend-B warm-only numbers (landing
    next iter) are modelled-indicative baselines flagged accordingly by
    `scripts/benchmark.sh` at iter-122.

- **2026-04-21 (iter-99 — superseded by iter-123)** — Story 2.1 source-level
  landing recorded that the image was not baked in the Ralph container
  environment (Docker unavailable at that point). Docker landed iter-121, the
  backend-B safety gate landed iter-122, the safe-subset bake landed above at
  iter-123. Kept as history for the timeline.
