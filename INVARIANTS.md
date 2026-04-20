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

### Design-token schema + semantic rationale (Story 1.10)

- **`INV-tokens-schema-contract`** — DTCG-compatible JSON Schema defining the shape of every semantic + primitive token group (color / type / font / space / radius / motion / density / breakpoint) plus optional `$modes` overlays. Story 1.10 scope is structure-only (every leaf carries `$type` + `$value`; every `$value` is a literal or `{alias}` reference; named semantic groups are required at the root); value population is Story 1.11, pre-commit quality gates (schema-validation + WCAG AA contrast + source-output sync) are Story 1.13. Source: `packages/ui/tokens.schema.json`.
- **`INV-tokens-semantic-rationale`** — semantic-rationale doc pairing every `TOKEN-<slug>` with a prose line explaining why the slot exists, when to use it, and how cross-runtime consumers (Tailwind preset + Textual TUI theme + Epic 7 catalog) reference it. Companion to `INV-tokens-schema-contract`; Sally's "catalog header references rationale" requirement (UX-DR4; ux-design-specification.md § Architecture of the Design System). Source: `docs/invariants/tokens.md`.

## Consumption

- **Humans / AI agents:** read this file; cross-reference the listed source files for the machine-enforced form.
- **Story 1.8 (`invariants.manifest.ts`):** imports this list, pins each ID with a content hash of the source region, exports `const invariants: Invariant[]`.
- **Story 1.9 (sync-gate):** at pre-merge, asserts every manifest ID has a matching `INVARIANTS.md` anchor AND every anchor has a matching manifest entry AND every content hash matches.

## Extension (FR44)

Forks that disagree with an invariant extend via `eslint.config.fork.js extends eslint.config.keel-invariants.js` (and equivalent for prettier / commitlint / tsconfig). Source-layer changes to `packages/keel-invariants/` itself require a PR that updates the `invariants.manifest.ts` + `INVARIANTS.md` anchor together — this is the "source-level fork" path (FR32; Story 1.6 + 1.9).
