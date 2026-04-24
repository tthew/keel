# INVARIANTS.md — agent-readable index of machine-enforced rules

**Audience:** any AI agent or human contributor needing to know which substrate rules are _machine-enforced_ (and where their enforcement source lives).

This file is the human-readable companion to `packages/keel-invariants/` (FR42). Every entry here has a stable ID (`INV-<category>-<slug>`) pinned by `invariants.manifest.ts` (Story 1.8) with a content hash, drift-checked at pre-merge by the sync-gate (Story 1.9, FR43).

## Promotion rules

| Audience / scope                            | File                                          |
| ------------------------------------------- | --------------------------------------------- |
| Applies to every AI agent (ops + truth)     | `AGENTS.md`                                   |
| Claude-Code-specific (skills, settings)     | `CLAUDE.md`                                   |
| Ralph-gotchas (iteration-loop lessons)      | `RALPH.md`                                    |
| Machine-enforced (config/rule/gate in code) | `INVARIANTS.md` + `packages/keel-invariants/` |

## Invariants index

Each entry: stable ID + one-line description + source-file pointer.

### Shared TypeScript / lint / format / commit-lint configs (Story 1.2)

- **`INV-tsconfig-base`** — strict TS + project-reference contract extended by every workspace member. Source: `packages/keel-invariants/tsconfig.base.json`.
- **`INV-eslint-shared`** — shared ESLint flat-config baseline extended by every workspace member: global `ignores` + `js.configs.recommended` + `tseslint.configs.recommended` (spread) + `languageOptions.globals` (node + browser). Source: `packages/keel-invariants/eslint.config.keel-invariants.js` (default export; the `no-restricted-imports` and `keel-invariants/no-verify-bypass` entries in the same file carry separate IDs — see `INV-eslint-import-boundary` and `INV-no-verify-bypass`).
- **`INV-prettier-shared`** — 9-key keel house style (printWidth 100, singleQuote, trailingComma all, lf EOL, …). Source: `packages/keel-invariants/prettier.config.keel-invariants.js`.
- **`INV-commitlint-shared`** — conventional-commits + 3-key rule overrides (subject-case off, header-max-length 120, body-max-line-length off). Source: `packages/keel-invariants/commitlint.config.keel-invariants.js`.

### Import-boundary rules (Story 1.3)

- **`INV-eslint-import-boundary`** — `no-restricted-imports` denies cross-package relative imports (AC 1), `@keel/*/internal/*` deep imports (AC 2), and per-package self-import via alias (AC 3 via `forPackage(ownName)` overlay). Source: `packages/keel-invariants/eslint.config.keel-invariants.js` (the `no-restricted-imports` rule block in `sharedBase` covers ACs 1–2; `forPackage(ownName)`'s own `no-restricted-imports` override adds AC 3's `@keel/${ownName}` self-import pattern).

### prek pre-commit config (Story 1.4)

- **`INV-prek-pre-commit-config`** — 3 local hooks (`typecheck` / `lint` / `format-check`) wired at repo root; each `language: system`, `pass_filenames: false`, `always_run: true`. Source: `{repo-root}/.pre-commit-config.yaml` (rows 1–3).
- **`INV-prek-prepare-lifecycle`** — root `package.json` `prepare` script installs `prek` shims for both `pre-commit` and `commit-msg` stages via `prek install -t pre-commit -t commit-msg`. Source: `{repo-root}/package.json` (`scripts.prepare`).

### prek commit-msg config (Story 1.5)

- **`INV-prek-commit-msg-config`** — 4th hook entry `id: commitlint`, `stages: [commit-msg]`, `entry: pnpm exec commitlint --edit`, `language: system`, default `pass_filenames: true` so prek passes `<COMMIT_EDITMSG>` as trailing positional. Source: `{repo-root}/.pre-commit-config.yaml` (row 4).

### Hook-bypass prevention (Story 1.6)

- **`INV-no-verify-bypass`** — ESLint rule `keel-invariants/no-verify-bypass` flags `--no-verify` / `--dangerously-skip-permissions` hook-bypass tokens appearing as string literals or static template-literal quasis in committed JS/TS. Source: `packages/keel-invariants/src/eslint-rules/no-verify-bypass.js` (rule) + `packages/keel-invariants/src/eslint-rules/index.js` (plugin aggregator) + `packages/keel-invariants/eslint.config.keel-invariants.js` (registration in `sharedBase` + `forPackage()`).

### Ralph loop contracts (halt-schema + path-resolution)

- **`INV-ralph-halt-path-resolution`** — `ralph.py` (and fork-replacement runtimes) resolve `.ralph/halt`, `.ralph/@plan.md`, `.ralph/PROMPT_*.md`, and `.ralph/logs/` against the worktree path (`.claude/worktrees/<name>/.ralph/`) when `--worktree <name>` is set, else against cwd-relative `.ralph/`. The resolved absolute path is exported to the subprocess env as `RALPH_BASE_DIR` so agent + orchestrator address the same directory. Agents MUST use `$RALPH_BASE_DIR` or relative `.ralph/*` — never hardcoded main-repo absolutes. Normative spec: `docs/invariants/ralph-execute.md` § Path Resolution (FR14k + NFR33a). Runtime source: `ralph.py` `resolve_ralph_base()` + `RalphConfig.ralph_base` + env injection at subprocess spawn. Machine-enforcement of drift between source + spec + manifest lands in Story 1.9's sync-gate (FR43); at 1.0 this invariant is spec-enforced only.
- **`INV-ralph-halt-reason-enum`** — `.ralph/halt` sentinel's `reason` field is a closed 7-reason enum at 1.0 (`EPIC_DONE`, `ALL_EPICS_DONE`, `AWAIT_MERGE`, `BUDGET_EXHAUSTED`, `CI_BLOCKED`, `SECURITY_CRITICAL`, `RALPH_STAGE_REGRESSION`). **Autonomy constraint (non-toggle-able):** every reason is bounded — either self-resolving (e.g. `EPIC_DONE` clears on re-entry via FR14n's cross-epic branch once the PR merges; `AWAIT_MERGE` clears on merge; `ALL_EPICS_DONE` is terminal) or triggered by a concrete external condition (budget/CI/security/stage regression). No reason may block on open-ended human input. Ralph does NOT invoke `AskUserQuestion` from the runtime loop; a hypothetical `AWAITING_USER` reason is explicitly rejected by this invariant. When state is inconsistent, Ralph falls back to an existing bounded reason (typically `EPIC_DONE` with a diagnostic `note` field) rather than introducing a new waiting state. Any new reason must be added to PRD FR14k + architecture § R1 + `docs/invariants/ralph-execute.md` § Halt schema + the invariants manifest in the same PR (source-level fork path per FR32 + FR43). Normative spec: `docs/invariants/ralph-execute.md` § Halt schema (FR14k + FR14n 2026-04-21 amendment). Runtime source: `.ralph/PROMPT_build.md` § Halt + § Cross-epic transition; `ralph.py` `_handle_epic_done_transition` (ALL_EPICS_DONE no-op). Machine-enforcement of drift lands in Story 1.9's sync-gate at 1.0.

### Design-token schema + semantic rationale (Story 1.10)

- **`INV-tokens-schema-contract`** — DTCG-compatible JSON Schema defining the shape of every semantic + primitive token group (color / type / font / space / radius / motion / density / breakpoint) plus optional `$modes` overlays. Story 1.10 scope is structure-only (every leaf carries `$type` + `$value`; every `$value` is a literal or `{alias}` reference; named semantic groups are required at the root); value population is Story 1.11, pre-commit quality gates (schema-validation + WCAG AA contrast + source-output sync) are Story 1.13. Source: `packages/ui/tokens.schema.json`.
- **`INV-tokens-semantic-rationale`** — semantic-rationale doc pairing every `TOKEN-<slug>` with a prose line explaining why the slot exists, when to use it, and how cross-runtime consumers (Tailwind preset + Textual TUI theme + Epic 7 catalog) reference it. Companion to `INV-tokens-schema-contract`; Sally's "catalog header references rationale" requirement (UX-DR4; ux-design-specification.md § Architecture of the Design System). Source: `docs/invariants/tokens.md`.

### Design-token source (Story 1.11)

- **`INV-tokens-source`** — DTCG JSON file populated with every Direction A semantic + primitive token value per ux-design-specification.md § Visual Design Foundation + § Design Direction Decision. Ships the 11-step neutral ramp, accent primitives + semantic aliases, surface/text/border aliases into the ramp, 5-tier status families with fg+bg pairs, severity + kanban-state alias vocabularies, 8-stop modular type scale (1.125 ratio), sans + mono font stacks, 13-stop 4px space scale, 5-stop radius scale, motion dial + 5 duration tiers (instant/snap/swift/smooth/drift), density dial + 3 scale tiers (compact/default/comfortable), 5 breakpoint stops, and light + dark `$modes` overlays (light empty since base = light; dark re-maps surface/text/border/accent.fg + status.bg variants). Consumed by Story 1.12 emitter (web CSS custom properties + Tailwind preset + Textual theme) and validated against `INV-tokens-schema-contract` by Story 1.13's pre-commit schema-validation + WCAG AA contrast + source-output sync gates. Source: `packages/ui/tokens.json`.

### Design-token emitter pipeline (Story 1.12)

- **`INV-tokens-emitter`** — deterministic TypeScript emitter that reads `packages/ui/tokens.json` (`INV-tokens-source`) and emits three byte-stable cross-runtime artefacts per FR67-adapted purity contract: `packages/ui/src/tokens.css` (web CSS custom properties under `:root { }` base + `[data-theme="dark"] { }` overlay), `packages/ui/tailwind.preset.ts` (Tailwind v4 preset exporting `keelTailwindPreset` with flat-kebab keys under `theme.extend.{colors,fontSize,fontFamily,spacing,borderRadius,transitionDuration,motionScale,densityScale,screens}`), and `packages/devbox/tui/theme.py` (Textual Python `SimpleNamespace` constants under `theme.colors.*` + `theme.{type,font,space,radius,motion,density,breakpoint}.*` + sparse `theme.dark.colors.*`). Flattens DTCG `{alias}` references at emit-time (cycle-detected DFS with a mutated in-progress set so diamond-DAG alias graphs resolve without false positives); no network / no time / no RNG / no env vars; reads only `packages/ui/tokens.json`; writes only the three target paths. Source-SHA resolver for the provenance header uses `git log -1 --format=%h --abbrev=12 -- packages/ui/tokens.json` and is hoisted to a single per-run call threaded into the three emit stages, with tagged `git-unavailable-` / `stderr-error-` / `uncommitted-` fallback prefixes when git fails. Invocation: `pnpm --filter @keel/ui generate-tokens`. `--check` mode (Story 1.13) re-emits to in-memory buffers and byte-compares against committed output paths without writing. Consumed by Epic 7 Story 7-1 (Tailwind preset + CSS vars), Epic 3 Story 3.33 (TUI theme.py re-theme seam), Epic 12 shape-aware templates. Validated end-to-end by the Story 1.13 pre-merge source-output sync gate (`INV-tokens-sync-gate`, `--check` mode). Source: `packages/ui/scripts/generate-tokens.ts`.

### Design-token quality gates (Story 1.13)

- **`INV-tokens-schema-validate`** — pre-commit gate validating `packages/ui/tokens.json` against `packages/ui/tokens.schema.json` via Ajv-2020 (JSON Schema Draft 2020-12); rejects schema-violating commits with a structured JSON error on stderr naming `instancePath` + `schemaPath` + `keyword` + expected/received values. Runs before the token-contrast + sync gates so downstream stages can trust source shape. Source: `packages/keel-invariants/src/check-tokens-schema.ts`.
- **`INV-tokens-contrast-check`** — pre-commit gate computing WCAG 2.1 AA contrast ratios for every semantic `text × surface`, `status.fg × status.bg`, `severity × surface`, `state × surface`, `accent × surface`, and `border.accent × surface` pair in light + dark overlay modes; gamut-maps OKLCH → in-gamut sRGB (3-iteration chroma reduction + hard clamp) before relative-luminance math; threshold `4.5` for normal text / `3.0` for UI components per WCAG 1.4.11. Source: `packages/keel-invariants/src/check-tokens-contrast.ts`.
- **`INV-tokens-sync-gate`** — pre-merge gate invoking the emitter in `--check` mode to byte-compare re-emitted outputs against committed `packages/ui/src/tokens.css` + `packages/ui/tailwind.preset.ts` + `packages/devbox/tui/theme.py`; shares `sourcePath` with `INV-tokens-emitter` (additive `--check` flag on the existing writer). Source: `packages/ui/scripts/generate-tokens.ts`.

### Release management (Story 1.14)

Single-bundled release-please config + per-workspace manifest + companion rationale doc; conventional-commits → semver bumps → rolling Release PR.

- **`INV-release-please-config`**: .github/release-please-config.json — single-bundled monorepo config (release-type node + linked-versions plugin + bump-minor-pre-major + 17-key `packages:` map).
- **`INV-release-please-manifest`**: .github/.release-please-manifest.json — per-path version state-of-record (17 entries; initial 0.0.0 everywhere).
- **`INV-release-please-rationale`**: docs/invariants/release.md — single-bundled vs per-package trade-off rationale + commit-type semver mapping + fork-extension guidance.

### Dependency upgrade discipline (Story 1.15)

I7 version-pinning policy authored in `.github/renovate.json` + companion rationale doc; Vitest + OTEL + Radix UI + pg_uuidv7 pin-mode + grouped-update rules; inert until the Renovate GitHub App is installed.

- **`INV-deps-version-pinning`**: .github/renovate.json — 4 packageRules (Vitest + @opentelemetry/\* + @radix-ui/\* + pg_uuidv7) with rangeStrategy pin + per-ecosystem groupName + automerge false.
- **`INV-renovate-rationale`**: docs/invariants/renovate.md — I7 posture + per-package pinning rules table + grouping rationale + fork-extension guidance.

### Fork extension (Story 1.16)

FR44 ESLint-extend pattern (`eslint.config.fork.js` importing `@keel/keel-invariants/eslint`) + FR45 Growth-tier `INVARIANTS.fork.md` scaffold template; substrate-wins precedence via spread-at-end convention; fork operators opt into the Growth-tier scaffold manually at 1.0 (Epic 15a's `--include-fork-invariants` flag lands later).

- **`INV-fork-extension-rationale`**: docs/invariants/fork.md — FR44 ESLint-extend pattern + FR45 Growth-tier INVARIANTS.fork.md scaffold + substrate-wins precedence + amendment-vs-fork decision tree.
- **`INV-fork-invariants-scaffold`**: packages/keel-invariants/templates/INVARIANTS.fork.md — Growth-tier fork-invariants template with H1 + § Precedence + § Fork invariants index + § Consumption + § Extension + commented FORK-\<fork-slug\>-\<category\>-\<slug\> naming example.

### Devbox iteration substrate (Story 2.1)

Docker-in-Docker as a fork-time substrate requirement: every Ralph iteration environment (cc-devbox or equivalent) must provide a functioning Docker daemon. Spec-enforced at 1.0; runtime check (`command -v docker && docker info`) lands as a `packages/keel-invariants/` rule on a later Ralph iteration.

- **`INV-devbox-dind-available`** — Ralph iteration environment provides `docker` on PATH + reachable daemon (`/var/run/docker.sock` canonical; remote transport permitted) + `docker compose` subcommand. Canonical install path: `docs.docker.com/engine/install/ubuntu/` against the cc-devbox `FROM ubuntu:24.04` base. Does NOT change NFR2 authority — M4-Pro native remains authoritative; DinD entries land in README § Benchmarks flagged `modelled indicative baseline`. Source: `docs/invariants/devbox-dind.md`.

### Devbox egress (Story 2.3)

Fail-closed DNS (dnsmasq) + IPv4/IPv6 default-deny (nftables) + atomic reload consolidated into one substrate-authoritative invariant. Closes upstream cc-devbox's divergent-whitelist + fail-open-resolv.conf + IPv6-gap bugs. JSONL query log at `/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/egress-queries.jsonl` with 6-field stable schema is the FR37 (Epic 4) security-evidence consumer contract.

- **`INV-devbox-egress-contract`** — Fail-closed DNS + IPv4/IPv6 parity + atomic reload; JSONL query log schema is append-only stable. Source: `docs/invariants/devbox-egress.md`.

### Devbox hardening (Story 2.5)

Non-root `dev` user (UID/GID 1000) + capability bounding set (`cap_drop: [ALL]` + `cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE]`) + `no-new-privileges:true` + tmpfs `/tmp` and `/var/tmp` with `noexec,nosuid` + named Docker volume `keel_home_dev` for `/home/dev` (non-toggle-able; never a host bind-mount under any `KEEL_DEVBOX_*` setting). Layered-barrier posture satisfying NFR7 + NFR8 + NFR8a + NFR10. Runtime compose-shape check deferred to Story 2.17 / `packages/keel-invariants/src/check-devbox-compose-shape.ts`; Story 2.5 registers the substrate-invariant surface.

- **`INV-devbox-homedev-named-volume`** — Non-root dev user + cap_drop/add (NET_ADMIN, NET_RAW, NET_BIND_SERVICE) + no-new-privileges + tmpfs noexec/nosuid + named volume for /home/dev. Source: `docs/invariants/devbox-hardening.md`.

### Devbox prerequisite check (Story 2.10)

Prerequisite check for Docker runtime + Claude Code auth + gh auth that runs on every host-side shim invocation (`pnpm devbox:*`, `pnpm ralph:*`, `pnpm claude`, `pnpm gh:auth`) at pre-flight and as a standalone verb (`pnpm devbox:prereq:check`) per FR5. Three-check contract with tiered dispatch (Tier 1 = Docker only, gates 15 shims; Tier 2 = Docker + tokens, gates the two ralph wrappers + standalone verb). Token probes filesystem-based (`alpine:3.19` throwaway container, read-only mount of the `keel_home_dev` named volume, `test -e`); no content validity inspection (SC-15). Composite-message aggregation within Tier 2 per AC 5; no partial-bypass posture at 1.0. Exit-code schema extends Story 2.6 uniform with `2` = tokens missing, `12` = other docker-daemon error; `0`/`8` reused verbatim.

- **`INV-devbox-prereq-check`** — Prerequisite check for Docker runtime + Claude + gh auth on every host-side shim invocation. Source: `docs/invariants/devbox-prereq-check.md`.

### Devbox mode (Story 2.11)

Per-fork vs shared devbox mode contract via `KEEL_DEVBOX_SHARED` in `.envrc` per FR4. Per-fork mode (default) binds the fork root as a single-container single-volume posture (`keel-devbox` + `keel-devbox_keel_home_dev`); shared mode (`KEEL_DEVBOX_SHARED=true`) binds the parent directory and locks in a hardcoded `keel-devbox-shared` container + `keel-devbox-shared_keel_home_dev` volume so two forks attach to the same container. Resolution lives in `packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_mode_specific_state()`, invoked by every host-side shim after `resolve_main_repo_and_workdir`. Mid-use flip between modes surfaces a warning-only stderr line via `env-check.sh` pointing at `pnpm devbox:clean`. Shared-mode concurrency is single-operator-at-a-time by convention (not Docker-enforced); operators needing true-parallel Ralph across forks revert to per-fork mode.

- **`INV-devbox-mode`** — Per-fork vs shared devbox mode contract (`KEEL_DEVBOX_SHARED` branches compose project + container + volume + bind). Source: `docs/invariants/devbox-mode.md`.

### Devbox SSH (Story 2.12)

Opt-in sshd via `KEEL_DEVBOX_SSH=true` (pubkey-only, root-disabled, loopback-bound `127.0.0.1:2222`; host keys + `authorized_keys` persisted in the `keel_home_dev` named volume) + loopback-bound port publication invariant for ALL `ports:` mappings (no `0.0.0.0` / no bare-port bindings). Resolution via `packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_ssh_state()`; single compose override at `packages/devbox/docker-compose.ssh.yml` publishes port 2222.

- **`INV-devbox-ssh`** — Opt-in sshd + loopback-bound port publication contract (`KEEL_DEVBOX_SSH=true` opens 127.0.0.1:2222 pubkey-only; ALL ports must use 127.0.0.1:<host>:<container> form). Source: `docs/invariants/devbox-ssh.md`.

### Devbox healthcheck (Story 2.13)

Compose-level healthcheck probes dnsmasq liveness (always) + sshd liveness (iff `KEEL_DEVBOX_SSH=true`); replaces upstream cc-devbox's broken `curl :3000`. Timing parameters `interval 10s` / `timeout 5s` / `retries 3` / `start_period 30s` are substrate-authoritative with per-knob rationale. Canonical probe: `dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com` (dnsmasq) + `nc -z 127.0.0.1 2222` (sshd; conditional). POSIX sh safe (`/bin/sh` is `dash` on Ubuntu 24.04). Probe domain `api.github.com` is three-site lockstep with `packages/devbox/whitelist/github.txt`. Forks MAY add additive fork-specific probes via compose override; MAY NOT weaken the substrate.

- **`INV-devbox-healthcheck`** — Compose healthcheck probes dnsmasq + sshd liveness; never curl :3000; timing parameters + rationale pinned. Source: `docs/invariants/devbox-healthcheck.md`.

### Devbox legacy-branch retention (Story 2.14)

Legacy-devbox branch retains pre-absorption cc-devbox layout as fallback canary during the M0.5 → M4 critical-path window per PRD § Technical Risks bootstrap-handoff mitigation (`prd.md:617`); retired by Story 15b.1's `scripts/major-cut.sh` at the 1.0 cut ritual (`epics.md:6293-6314`). Four workflow contracts pinned: branch creation (upstream fetch + retention banner), cherry-pick (manual minimal-drift; CVE-class / fail-closed-egress / secret-leakage / network-exposure only — no feature-parity), triage (canary-then-bisect — reproduce the regression on the canary; `git bisect start HEAD 5278738 -- packages/devbox/` if absent on canary, escalate upstream if present), retirement (tag `legacy-devbox-final` + delete active branch + `RALPH.md` decision entry per FR33). Documented-but-not-automated by design; FR44 AMEND required to script cherry-pick. Forks MAY follow the pattern with their own upstream + retention naming OR skip retention if no bootstrap-handoff risk applies; substrate-wins precedence forbids weakening no-feature-parity framing or automating cherry-picks.

- **`INV-devbox-legacy-branch-retention`** — Legacy-devbox branch retains pre-absorption cc-devbox layout for bootstrap-handoff mitigation; cherry-pick + triage + retirement workflows pinned. Source: `docs/invariants/devbox-legacy-branch-retention.md`.

### Gitignored-secret commit-deny (Story 2.2)

Pre-commit hook refuses additions of `.envrc`, `.envrc.local`, and `.secrets` at any path. Committed schema companions (`.envrc.example`, `.secrets.example`) remain exempt via anchored regex end-match. Machine-enforced via prek hook → `pnpm keel-invariants:no-committed-dotfiles` → `packages/keel-invariants/src/check-no-committed-dotfiles.ts`.

- **`INV-gitignored-secret-commit-deny`** — pre-commit hook refuses `.envrc` / `.envrc.local` / `.secrets` file additions. Source: `docs/invariants/gitignored-secret-commit-deny.md`.

## Consumption

- **Humans / AI agents:** read this file; cross-reference the listed source files for the machine-enforced form.
- **Story 1.8 (`invariants.manifest.ts`):** imports this list, pins each ID with a content hash of the source region, exports `const invariants: Invariant[]`.
- **Story 1.9 (sync-gate):** at pre-merge, asserts every manifest ID has a matching `INVARIANTS.md` anchor AND every anchor has a matching manifest entry AND every content hash matches.

## Extension (FR44)

Forks that disagree with an invariant extend via `eslint.config.fork.js extends eslint.config.keel-invariants.js` (and equivalent for prettier / commitlint / tsconfig). Source-layer changes to `packages/keel-invariants/` itself require a PR that updates the `invariants.manifest.ts` + `INVARIANTS.md` anchor together — this is the "source-level fork" path (FR32; Story 1.6 + 1.9).
