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

| Tool                        | Pin / source                                        | Notes                                                                    |
| --------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------ |
| Ubuntu base                 | `ubuntu:24.04`                                      | LTS support through April 2029.                                          |
| Node.js                     | `20.x` via NodeSource `setup_20.x`                  | Exact minor recorded per bake; `engines.node` in root `package.json`.    |
| pnpm                        | `10.29.2`                                           | Pinned to match root `package.json@packageManager`.                      |
| `@anthropic-ai/claude-code` | _recorded-at-bake_                                  | `npm install -g`; Renovate `npm` manager tracks.                         |
| GitHub CLI (`gh`)           | apt via `cli.github.com/packages`                   | Renovate `apt` manager tracks.                                           |
| `uv` (Astral)               | _recorded-at-bake_                                  | Official installer; captures latest stable at bake.                      |
| AWS CLI                     | v2 (arch-aware installer)                           | Refresh on every bake.                                                   |
| Supabase CLI                | latest release `.deb` (arch-aware)                  | Arch-aware fallback; skipped if asset missing for host.                  |
| git-delta                   | latest release `.deb` (arch-aware)                  | Fail-closed if asset missing (diff pager is mandatory for I8 workflows). |
| Playwright OS deps          | `npx --yes playwright@latest install-deps` post-apt | Reconciles apt list with Playwright's current requirement set.           |
| `postgresql-client`         | apt (Ubuntu 24.04 default)                          | Provides `psql` for Epic 6 Story 6.5 forward-compat.                     |

## Epic 6 forward-compatibility roster (Story 2.1 AC 3 Dev Note)

Story 2.1 bakes every tool Epic 6's `pnpm rls:explain` (Story 6.5) will invoke
so the Epic 6 landing requires **no image rebuild**:

- `psql` ← `postgresql-client`.
- `delta` ← git-delta release asset.
- Workspace tooling (`pnpm`, `turbo`, etc.) stays on the bind-mounted
  `/workspace` and needs no image changes.

## Bake log

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
