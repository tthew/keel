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

- **2026-04-21** — Story 2.1 iter-99 landing: image not baked in the Ralph
  container environment (Docker unavailable). First bake will run on an
  operator workstation per NFR2 baseline; versions above become concrete at
  that point.
