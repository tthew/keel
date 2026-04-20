# Story 1.7: Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules

Status: in-progress

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As any AI agent or human contributor working on Keel,
I want four audience-scoped markdown files at the repo root — `INVARIANTS.md`, `AGENTS.md`, `CLAUDE.md`, `RALPH.md` — each with its charter and promotion rules,
so that I know which file to read and which to write to (FR42; baseline for FR14j in Epic 3).

## Acceptance Criteria

1. **Given** a fresh clone,
   **When** I open the repo root,
   **Then** `INVARIANTS.md`, `AGENTS.md`, `CLAUDE.md`, and `RALPH.md` all exist
   **And** each begins with a pinned audience header (`INVARIANTS.md` = agent-readable index of machine-enforced rules; `AGENTS.md` = every AI agent operational truth; `CLAUDE.md` = Claude-Code specifics + pointer; `RALPH.md` = Ralph private journal).

2. **Given** the four files,
   **When** I read each header,
   **Then** the promotion rule is pinned verbatim (applies-to-every-agent → `AGENTS.md`; Claude-Code-specific → `CLAUDE.md`; Ralph-gotchas → `RALPH.md`; machine-enforced → `INVARIANTS.md` + `packages/keel-invariants/`).

3. **Given** `INVARIANTS.md`,
   **When** I read its body,
   **Then** it is an agent-readable index of stable IDs mapping to rules in `packages/keel-invariants/`
   **And** each entry cites the stable ID, a one-line description, and a source-file pointer.
   **Story 1.7 scope carve-out:** Story 1.7 ships a **human-authored, provisional** index of stable IDs for invariants that already exist in `packages/keel-invariants/` (Stories 1.2 / 1.3 / 1.4 / 1.5 / 1.6 outputs). Story 1.8 ships the **canonical** `invariants.manifest.ts` (stable ID + content hash per entry). Story 1.9 runs the sync-gate (FR43) that fails pre-merge when the `INVARIANTS.md` anchor set drifts from the manifest. Story 1.7's entries carry the header `<!-- Provisional: canonical IDs pinned by Story 1.8 manifest; drift-detection lands in Story 1.9. -->` so Story 1.8 has an explicit license to edit IDs/descriptions when it imports the list.

4. **Given** `CLAUDE.md`,
   **When** I read its body,
   **Then** it points at `AGENTS.md` as the source of truth and names only Claude-Code-specific supplements.

5. **Given** `RALPH.md`,
   **When** read by Ralph during orient,
   **Then** its intended scope (private journal; append-only-in-spirit; hard lint enforcement lands in Epic 3 per RS6) is documented in its header.

## Tasks / Subtasks

- [x] **Task 1: Author `INVARIANTS.md` at repo root** (AC: 1, 2, 3)
  - [x] Create `/workspace/ralph-bmad/.claude/worktrees/ralph/INVARIANTS.md` (i.e. `{repo-root}/INVARIANTS.md`). Use the following skeleton:
    ```markdown
    # INVARIANTS.md — agent-readable index of machine-enforced rules

    **Audience:** any AI agent or human contributor needing to know which substrate rules are _machine-enforced_ (and where their enforcement source lives).

    This file is the human-readable companion to `packages/keel-invariants/` (FR42). Every entry here has a stable ID (`INV-<category>-<slug>`) that Story 1.8's `invariants.manifest.ts` will pin with a content hash, and Story 1.9's sync-gate (FR43) will drift-check at pre-merge.

    <!-- Provisional: canonical IDs pinned by Story 1.8 manifest; drift-detection lands in Story 1.9. -->

    ## Promotion rules

    | Audience / scope                            | File                                           |
    | ------------------------------------------- | ---------------------------------------------- |
    | Applies to every AI agent (ops + truth)     | `AGENTS.md`                                    |
    | Claude-Code-specific (skills, settings)     | `CLAUDE.md`                                    |
    | Ralph-gotchas (iteration-loop lessons)      | `RALPH.md`                                     |
    | Machine-enforced (config/rule/gate in code) | `INVARIANTS.md` + `packages/keel-invariants/`  |

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

    ## Consumption

    - **Humans / AI agents:** read this file; cross-reference the listed source files for the machine-enforced form.
    - **Story 1.8 (`invariants.manifest.ts`):** imports this list, pins each ID with a content hash of the source region, exports `const invariants: Invariant[]`.
    - **Story 1.9 (sync-gate):** at pre-merge, asserts every manifest ID has a matching `INVARIANTS.md` anchor AND every anchor has a matching manifest entry AND every content hash matches.

    ## Extension (FR44)

    Forks that disagree with an invariant extend via `eslint.config.fork.js extends eslint.config.keel-invariants.js` (and equivalent for prettier / commitlint / tsconfig). Source-layer changes to `packages/keel-invariants/` itself require a PR that updates the `invariants.manifest.ts` + `INVARIANTS.md` anchor together — this is the "source-level fork" path (FR32; Story 1.6 + 1.9).
    ```
  - [x] Verify the file parses as Markdown (opens cleanly in any viewer) and is under `.prettierignore`-compatible formatting (prettier will format root `.md` — run `pnpm format:check` at Task 3, fix if needed).
  - [x] Verify every `Source:` pointer resolves to an existing file: `packages/keel-invariants/tsconfig.base.json`, `packages/keel-invariants/eslint.config.keel-invariants.js`, `packages/keel-invariants/prettier.config.keel-invariants.js`, `packages/keel-invariants/commitlint.config.keel-invariants.js`, `packages/keel-invariants/src/eslint-rules/no-verify-bypass.js`, `packages/keel-invariants/src/eslint-rules/index.js`, `{repo-root}/.pre-commit-config.yaml`, `{repo-root}/package.json`. If any pointer is stale (e.g. a path renamed since spec authorship), update the pointer before committing.

- [x] **Task 2: Align audience headers + promotion rules in `AGENTS.md` / `CLAUDE.md` / `RALPH.md`** (AC: 1, 2, 4, 5)
  - [x] Ensure `AGENTS.md`'s header already names its audience ("provider-neutral guide for any AI coding agent") and has the four-line promotion rule verbatim. Current `AGENTS.md` has a partial mapping under "How to work here" / related prose but does NOT yet include the machine-enforced → `INVARIANTS.md` + `packages/keel-invariants/` line. **Action:** add a top-level `## Promotion rules` section (near the top, after the "What this project is" section) with the four-line mapping table verbatim (same table shape as `INVARIANTS.md`). This is the AC 2 verbatim anchor; the existing "When you discover something new" prose in `CLAUDE.md` is separate and can remain as is.
  - [x] Ensure `CLAUDE.md`'s header names its audience ("guidance to Claude Code ... when working with code in this repository") and the body points at `AGENTS.md` as source of truth (already does — Story 1.7 only needs to verify + add the INVARIANTS.md promotion-rule line). **Action:** extend the existing "Knowledge-file contract" table in `CLAUDE.md` to include an `INVARIANTS.md` row: `| INVARIANTS.md | Any AI agent or human — machine-enforced rules | Agent-readable index of stable IDs mapping to packages/keel-invariants/ (FR42; drift-detected by Story 1.9 sync-gate per FR43) |`. Also add the four-line promotion rule in the same verbatim form as `INVARIANTS.md` (either as a new section or merged into the existing promotion-rule prose).
  - [x] Ensure `RALPH.md`'s header names its audience ("notes from Ralph, to Ralph") and documents its scope (private journal; append-only-in-spirit; hard lint enforcement lands in Epic 3 per RS6). Current header has audience + "Rules:" prose covering append-don't-rewrite / keep terse / date-every-entry / prune. **Action:** add a one-line pinned scope note right after the audience sentence: `_Scope: Ralph's private journal. Append-only-in-spirit (hard lint enforcement lands in Epic 3 per RS6 — until then, discipline is self-policed)._` This satisfies AC 5. Also add the four-line promotion rule (same verbatim form) — place it as a sibling to the existing "Rules:" block, since the existing rule is about RALPH.md's own upkeep while the promotion rule is about which file OTHER content belongs in.
  - [x] Verify the four promotion-rule blocks are textually identical across the four files (character-exact). Use a diff tool or grep to confirm. The canonical form:
    ```markdown
    | Audience / scope                            | File                                           |
    | ------------------------------------------- | ---------------------------------------------- |
    | Applies to every AI agent (ops + truth)     | `AGENTS.md`                                    |
    | Claude-Code-specific (skills, settings)     | `CLAUDE.md`                                    |
    | Ralph-gotchas (iteration-loop lessons)      | `RALPH.md`                                     |
    | Machine-enforced (config/rule/gate in code) | `INVARIANTS.md` + `packages/keel-invariants/`  |
    ```
  - [x] After edits, run `pnpm format` (or `pnpm format:write` if that's the shim) on the four files — Prettier will normalize table column widths. Commit any format-fix in this task (see Story 1.2 Task 7 precedent for markdown format reflow being turbo-cache-safe).

- [x] **Task 3: Quality gates + sprint-status bump** (no AC — substrate verification)
  - [x] `pnpm install` at repo root. Should report `Lockfile is up to date` / `Already up to date`. `prepare` re-runs `prek install -t pre-commit -t commit-msg` idempotently (both shims already installed from Stories 1.4/1.5 Task 1).
  - [x] `pnpm -w typecheck` — expect 16/16 `>>> FULL TURBO` on first invocation (no TS inputs touched; INVARIANTS.md / AGENTS.md / CLAUDE.md / RALPH.md are not turbo typecheck inputs — same property as Stories 1.2–1.6 verification iterations).
  - [x] `pnpm -w lint` — expect 16/16 `>>> FULL TURBO` on first invocation (no ESLint inputs touched; `.md` files aren't lint inputs).
  - [x] `pnpm format:check` — must exit 0. If markdown files failed format-check, loop back to Task 2's `pnpm format` step (Prettier-fmt is the source of truth).
  - [x] `pnpm exec commitlint --from origin/main --to HEAD --verbose` — 0 problems across the full branch (spec + iter-1 + Tasks 1–3). Warnings OK (`footer-leading-blank` is warn severity per Story 1.6 Task 3 precedent).
  - [x] `pnpm exec prek run --all-files` — all 3 pre-commit-stage hooks `Passed` (TypeScript type-check / ESLint / Prettier format:check). Confirms git-hook-path parity.
  - [x] Bump `_bmad-output/implementation-artifacts/sprint-status.yaml`: `1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules: ready-for-dev → done`, `last_updated: 2026-04-20 Task-3 UTC`. **Co-land in Task 3's commit** (preemptive-orphan-prevention — Stories 1.1–1.6 precedent; seventh story-implementation confirmation).
  - [x] Flip this story file's Status to `done` + mark all Task subtasks `[x]` + populate `## Dev Agent Record` (Agent Model Used / Debug Log References / Completion Notes List / File List).

## Dev Notes

- Relevant architecture patterns and constraints:
  - [Source: architecture.md#Complete Project Directory Structure] `INVARIANTS.md` lives at repo root (line 771, alongside `AGENTS.md` / `CLAUDE.md` / `RALPH.md`). Role: "Agent-readable invariants narrative (FR42)".
  - [Source: architecture.md#Complete Project Directory Structure] `packages/keel-invariants/` at line 886 onward is the machine-enforced home for FR42–FR44. Source files referenced by INVARIANTS.md anchors live under `packages/keel-invariants/src/` (eslint-rules, schemas, etc.) and the keel-invariants package root (shared configs from Story 1.2).
  - [Source: prd.md FR42] "System can expose invariants to agents via `INVARIANTS.md` at repo root, referenced by `CLAUDE.md`, providing an agent-readable index of machine-enforced rules." — confirms INVARIANTS.md MUST be referenced from CLAUDE.md (Story 1.7 Task 2 adds the row to CLAUDE.md's Knowledge-file contract table).
  - [Source: prd.md FR43] "System can enforce sync between the machine-enforced layer (`packages/keel-invariants/`) and the agent-readable layer (`INVARIANTS.md`) via a pre-merge gate that reads an exported `invariants.manifest.ts` ..." — the sync gate is Story 1.9's scope; Story 1.7's scope carve-out acknowledges this.
  - [Source: architecture.md:901–902] Example of established anchor-ID conventions already referenced in architecture: `INV-ralph-safe-set-layering` and `INV-claude-hook-secret-denylist`. Pattern is `INV-<category>-<slug>` with hyphen-delimited snake-case (verified against Story 1.8's template in architecture.md:874: `INV-commit-conventional-format`, `INV-tokens-sync-gate`).
- Source tree components to touch:
  - **NEW:** `INVARIANTS.md` at repo root.
  - **EDIT:** `AGENTS.md`, `CLAUDE.md`, `RALPH.md` at repo root (add promotion-rule table + INVARIANTS.md row + RALPH.md scope note).
  - **EDIT:** `_bmad-output/implementation-artifacts/sprint-status.yaml` (status bump + last_updated).
- Testing standards summary:
  - This is a documentation-artifact story — no unit tests, no integration tests.
  - "Testing" here is the Story 1.4/1.5 quality-gate bundle: typecheck + lint + format:check + commitlint + prek-runner parity. All MUST pass at Task 3.
  - No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands.

### Project Structure Notes

- **Alignment with unified project structure:** `INVARIANTS.md` at repo root matches architecture.md line 771. No variance.
- **§ Scope Carve-Out — AC 3's canonical list lives in Story 1.8, not Story 1.7.** Rationale: AC 3 says "index of stable IDs mapping to rules in `packages/keel-invariants/`". The **authoritative** list (with content hashes that drift-detect against source) is what Story 1.8's `invariants.manifest.ts` emits. Story 1.7 ships the HUMAN-readable scaffold — IDs + descriptions + source-file pointers only (no hashes, no Zod schema, no runtime loading). Story 1.8 imports the list, pins hashes, and becomes authoritative; Story 1.7's INVARIANTS.md gets updated by Story 1.8 if any ID needs renaming. Story 1.9's sync-gate makes the cross-file contract load-bearing (addition-drift / removal-drift / edit-drift per architecture.md FR43 definition).
  - **Provisional-ID header:** INVARIANTS.md carries `<!-- Provisional: canonical IDs pinned by Story 1.8 manifest; drift-detection lands in Story 1.9. -->` at the top of the invariants index. This gives Story 1.8 explicit license to edit IDs without treating it as a behavioural regression of Story 1.7.
  - **Seven invariants captured at Story 1.7 authorship:** `INV-tsconfig-base` / `INV-eslint-shared` / `INV-prettier-shared` / `INV-commitlint-shared` / `INV-eslint-import-boundary` / `INV-prek-pre-commit-config` / `INV-prek-prepare-lifecycle` / `INV-prek-commit-msg-config` / `INV-no-verify-bypass`. (Count: 9.) Any invariant authored by Stories 1.8+ gets appended to the index as part of the authoring story.
- **§ Promotion-rule canonical form lives in INVARIANTS.md first; other three files mirror it.** Rationale: INVARIANTS.md is brand-new in Story 1.7; authoring it fixes the table's column widths / wording / row order. AGENTS.md / CLAUDE.md / RALPH.md mirror that exact form (character-exact copy) — verbatim-match is AC 2's literal requirement. Any future edit to the promotion rule MUST update all four files in the same PR (Story 1.9's sync-gate would catch this structurally once it pattern-matches INVARIANTS.md anchors, though the promotion-rule table isn't an `INV-*` entry — just a human convention).
- **§ RALPH.md scope-note placement.** AC 5 requires the scope note in the "header". "Header" here is interpreted as the top-of-file prose BEFORE any `##` section. RALPH.md currently has "notes from Ralph, to Ralph" as the H1, one prose paragraph explaining scope, then a "Rules:" bullet list. Task 2 adds a single italicised line between the prose paragraph and the Rules bullets — this is the "header scope note" per AC 5.
- **§ AGENTS.md does NOT currently have the full promotion rule in one place.** It has "Keep responses terse" style prose under § Project conventions and partial promotion-rule prose inline. Task 2 adds an explicit `## Promotion rules` section near the top (after "What this project is") with the four-line table verbatim. This is load-bearing for AC 2's "pinned verbatim" clause.
- **§ CLAUDE.md already has a "Knowledge-file contract" table (3 rows: AGENTS.md / CLAUDE.md / RALPH.md). Task 2 adds a 4th row for INVARIANTS.md** — this is what FR42 ("referenced by CLAUDE.md") formally requires, and it's also the natural location for the promotion rule. No new section needed; extend the existing table.
- **§ Source-file pointers use the canonical repo-root form.** All INVARIANTS.md source-file pointers use `packages/...` / `{repo-root}/...` paths (not absolute paths inside the worktree). This matches architecture.md conventions and is portable across fork clones (FR44).

### References

- [Source: `_bmad-output/planning-artifacts/epics.md` § Story 1.7 (lines 829–857)] — AC text pasted verbatim above.
- [Source: `_bmad-output/planning-artifacts/architecture.md` § Complete Project Directory Structure (line 771)] — INVARIANTS.md at repo root.
- [Source: `_bmad-output/planning-artifacts/architecture.md` § Complete Project Directory Structure (lines 886–926)] — `packages/keel-invariants/` source layout.
- [Source: `_bmad-output/planning-artifacts/architecture.md` (lines 901–902)] — Existing `INV-*` anchor examples (`INV-ralph-safe-set-layering`, `INV-claude-hook-secret-denylist`).
- [Source: `_bmad-output/planning-artifacts/prd.md` FR42 (line 1004)] — "expose invariants to agents via INVARIANTS.md at repo root, referenced by CLAUDE.md".
- [Source: `_bmad-output/planning-artifacts/prd.md` FR43 (line 1005)] — Sync-gate contract (Story 1.9's runtime; Story 1.7's spec acknowledges via scope carve-out).
- [Source: `_bmad-output/implementation-artifacts/1-6-quality-gate-bypass-prevention.md`] — Scope-Carve-Out pattern precedent (AC 1/3/4 deferred to Stories 1.8/1.9).
- [Source: `_bmad-output/implementation-artifacts/1-2-packages-keel-invariants-bootstrap-shared-eslint-prettier-commitlint-configs.md` Task 7 Completion Notes] — Markdown format-fixes are turbo-cache-safe (applies to Task 3's expected FULL TURBO property).

## Dev Agent Record

### Agent Model Used

Claude Opus 4.7 (1M context) — invoked as `/bmad-dev-story` per Ralph lifecycle state `atdd-scaffolded → in-dev` (with ATDD skip per FR14n matrix row 3; rationale pinned in `.ralph/@plan.md` § ATDD Skip Rationale and Story file § Testing Standards line 141).

### Debug Log References

- `pnpm install` → `Lockfile is up to date` / `Already up to date`; `prepare` re-ran `prek install -t pre-commit -t commit-msg` idempotently (756–856ms).
- `pnpm -w typecheck` → 16/16 `>>> FULL TURBO` (228ms; no TS inputs touched this iteration).
- `pnpm -w lint` → 16/16 `>>> FULL TURBO` (179ms; no ESLint inputs touched).
- `pnpm format:check` → exit 0 (`All matched files use Prettier code style!` — Prettier normalized CLAUDE.md's Knowledge-file contract table column widths to fit the new INVARIANTS.md row; AGENTS.md / RALPH.md / INVARIANTS.md unchanged by `prettier --write`).
- `pnpm exec commitlint --from origin/main --to HEAD --verbose` → 0 problems, 0 warnings across the 4 in-flight branch commits prior to this commit (spec + iter-1 + iter-2 + iter-3). Will rise to 5 once this commit lands; AC-check deferred to post-push `commit-msg` hook invocation.
- `pnpm exec prek run --all-files` → all 3 pre-commit-stage hooks `Passed` (TypeScript type-check / ESLint / Prettier format:check); confirms git-hook-path parity (Stories 1.4/1.5 gate).
- All 8 INVARIANTS.md `Source:` pointers `ls`-verified before authoring: `packages/keel-invariants/{tsconfig.base.json,eslint.config.keel-invariants.js,prettier.config.keel-invariants.js,commitlint.config.keel-invariants.js,src/eslint-rules/no-verify-bypass.js,src/eslint-rules/index.js}` + `{repo-root}/{.pre-commit-config.yaml,package.json}`.
- Promotion-rule table verbatim-match verified via `Grep` across the four knowledge files (`INVARIANTS.md` / `AGENTS.md` / `CLAUDE.md` / `RALPH.md`) — all four contain the canonical 4-row form + the `Machine-enforced (config/rule/gate in code) | INVARIANTS.md + packages/keel-invariants/` row (AC 2 pinned-verbatim requirement).

### Completion Notes List

- **Task 1 complete.** `INVARIANTS.md` authored at repo root using the spec skeleton verbatim (lines 43–97 of the story file). 9 invariants indexed across 5 categories (Shared configs / Import-boundary / prek pre-commit / prek commit-msg / Hook-bypass). Provisional-ID HTML comment included under index header giving Story 1.8's manifest emitter explicit license to rename IDs. All source-file pointers use the canonical repo-root form (no absolute worktree paths).
- **Task 2 complete.** All three existing knowledge files now carry the canonical `## Promotion rules` table verbatim. AGENTS.md: new `## Promotion rules` section inserted between "What this project is" and "Where things live". CLAUDE.md: Knowledge-file contract table extended from 3 → 4 rows (added INVARIANTS.md row per FR42's "referenced by CLAUDE.md" requirement); "When you discover something new" prose extended with a 4th bullet for machine-enforced → INVARIANTS.md + packages/keel-invariants/; new `## Promotion rules` section with the canonical 4-row table. RALPH.md: single italicised scope note inserted after the audience paragraph (AC 5: "private journal; append-only-in-spirit; hard lint enforcement lands in Epic 3 per RS6 — until then, discipline is self-policed"); `## Promotion rules` section added before Signposts as sibling to the existing "Rules:" upkeep block. Prettier normalized CLAUDE.md's column widths; other three files were already Prettier-clean.
- **Task 3 complete.** All 6 quality gates pass (install / typecheck / lint / format:check / commitlint / prek). Sprint-status bumped `1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules: in-progress → done` with `last_updated: 2026-04-20 Task-3 UTC`. Co-landed in this commit per Stories 1.1–1.6 precedent (preemptive-orphan-prevention; seventh consecutive story-implementation confirmation).
- **ATDD skip rationale (FR14n matrix row 3) — pinned.** Story 1.7 is a documentation-artifact story with no runtime behaviour to probe. All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). Story file § Testing Standards line 141 pre-declares: _"no runtime assertion needed until Story 1.9's sync-gate lands."_ Quality gates (typecheck / lint / format:check / commitlint / prek) remain mandatory and are NOT ATDD probes — they are substrate verification.
- **Scope carve-out (second application of Story 1.6's pattern).** AC 3's canonical list (content hashes, Zod schema, runtime load) ships in Story 1.8's `invariants.manifest.ts`. Story 1.9's sync-gate (FR43) drift-checks INVARIANTS.md anchors vs manifest IDs at pre-merge. Story 1.7 delivers the HUMAN-readable scaffold only — IDs + descriptions + source-file pointers.
- **Verification-only iteration property holds.** Typecheck + lint hit FULL TURBO on first invocation because the only source changes this iteration are `.md` and `.yaml` artefacts — not turbo typecheck or ESLint inputs. Seventh consecutive story-implementation confirmation of this property.

### File List

- **NEW:** `INVARIANTS.md` — agent-readable index of 9 machine-enforced invariants with provisional IDs + promotion-rule table (repo root).
- **EDIT:** `AGENTS.md` — added `## Promotion rules` section with canonical 4-row table.
- **EDIT:** `CLAUDE.md` — extended Knowledge-file contract table with INVARIANTS.md row; added 4th bullet to "When you discover something new" prose; added `## Promotion rules` section with canonical 4-row table.
- **EDIT:** `RALPH.md` — added italicised scope note after audience paragraph; added `## Promotion rules` section before Signposts.
- **EDIT:** `_bmad-output/implementation-artifacts/sprint-status.yaml` — bumped `1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules: in-progress → done`; `last_updated: 2026-04-20 Task-3 UTC`.
- **EDIT:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md` — flipped Status `ready-for-dev → done`; ticked all Task/subtask checkboxes; populated Dev Agent Record.

### Review Findings

Post-dev adversarial code review — iter-7 via `/bmad-code-review (args: "2")` — three parallel layers (Blind Hunter / Edge Case Hunter / Acceptance Auditor). Acceptance Auditor: APPROVED (all 5 ACs PASS). Blind + Edge surfaced content-accuracy defects in INVARIANTS.md descriptions and trace artefact metadata. Triage: 4 patch / 2 defer / 11 dismissed (false positives, cosmetic, narrative noise, user-handle false alarm).

**Re-review iter-12 via `/bmad-code-review (args: "2")` — same three-layer fan-out on the POST-FIX diff.** Acceptance Auditor: APPROVED (all 5 ACs still PASS post-fix; the iter-8/9/10/11 fixes did not regress any AC). Blind + Edge surfaced 2 NEW trace-artefact consistency defects (waiver-expiry phrasing drift JSON vs md YAML; AC-4 recommendation omitted from trace md YAML snippet). Triage: 2 patch / 0 new defer / 3 dismissed (sprint-status `in-progress` is expected lifecycle state not a defect; `forPackage()` "adds" vs "replaces" verb-wording nuance is semantically equivalent — name-based anchor stable; `line 141` story-file § Testing Standards citation verified current post-iter-7+ edits — edits were appended to Dev Agent Record section at end, did not shift line 141).

**Re-review iter-15 via `/bmad-code-review (args: "2")` — same three-layer fan-out on the POST-iter-13/14-fix diff.** Acceptance Auditor: APPROVED (all 5 ACs still PASS post-fix; iter-13 JSON waiver-expiry flip + iter-14 md YAML AC-4 insertion did not regress any AC — iter-13 touched only `1-7-e2e-trace-summary.json:107` and iter-14 touched only the trace md YAML `recommendations:` block, both non-AC surfaces). Blind + Edge surfaced 2 NEW trace-artefact consistency defects + 1 prose miscount. Triage: 2 patch / 0 new defer / 4 dismissed (sprint-status + story-file `Status: in-progress` are expected lifecycle states pending `fixes-pending → done`, will flip at Draft→Open transition per Story 1.5 precedent; `source_sha: 7b39060` on trace summary is intentionally the Task 3 authoring SHA not regenerated on every CR patch per iter-10/11/13/14 precedent — Story 1.9 sync-gate will reconcile; md YAML lacking `priority:` / `requirements:` sub-keys vs sibling JSON object shape is a projection-level structural difference not a wording drift, Edge Case self-deferred to Story 1.9 FR43 scope). Fix #1/2 (md YAML qualifier drop `automated`/`hard`) is MEDIUM — same drift-class as iter-12 #1/2 (sibling wording not surveyed when iter-11 canonicalised `expiry`). Fix #2/2 (prose miscount) is LOW — one-word edit.

- [x] [Review][Patch] INV-eslint-shared description states "6-entry flat-config default export" but the actual default export has 9 entries [`INVARIANTS.md:25`] — HIGH; Story 1.9 sync-gate will trip on the content-hash drift once it lands. Fix by rewriting to name-based anchors or correcting the count + enumeration. **Resolved iter-8 (fix #1/4):** rewrote to name-based anchors (`ignores` + `js.configs.recommended` + `tseslint.configs.recommended` + `languageOptions.globals`); explicitly demarcates that `no-restricted-imports` and `keel-invariants/no-verify-bypass` entries in the same file carry separate INV IDs. Applied to both `INVARIANTS.md:25` and story-file skeleton line 67.
- [x] [Review][Patch] INV-eslint-import-boundary source pointer "7th entry + `forPackage()` 8th entry" is off-by-one; `no-restricted-imports` is index 6 (7th) of `sharedBase` but the `forPackage()` overlay lands at index 9 (10th) [`INVARIANTS.md:31`] — MEDIUM; replace with name-based reference or correct indices. **Resolved iter-9 (fix #2/4):** replaced positional-index reference with name-based anchors following iter-8's drift-resistance lesson — "the `no-restricted-imports` rule block in `sharedBase` covers ACs 1–2; `forPackage(ownName)`'s own `no-restricted-imports` override adds AC 3's `@keel/${ownName}` self-import pattern." Applied to both `INVARIANTS.md:31` (live file) and story-file skeleton line 73. Name-based form decouples from future `sharedBase` reshuffles — Story 1.9's sync-gate content-hash will still detect any drift, but AC-aligned prose no longer rots on positional changes.
- [x] [Review][Patch] Trace JSON `auth_negative_path_status` / `error_path_status` values say `"present"` but the accompanying md declares "not applicable" for this docs-only story [`_bmad-output/test-artifacts/traceability/1-7-e2e-trace-summary.json:609-614`] — LOW; update JSON values to `"not_applicable"` to match md prose. **Resolved iter-10 (fix #3/4):** set both heuristic fields to `"not_applicable"` in `1-7-e2e-trace-summary.json` (actual lines 64-65; CR's `609-614` pointer was drifted — the live file is only 116 lines). JSON now aligns with the md prose at lines 190/194/198/202 which declare auth/error/ui paths all "Not applicable — Story 1.7 introduces zero runtime endpoints / zero auth/session/permission surface / zero flows with happy/error paths / zero UI." Story 1.9's sync-gate will lean on heuristic consistency; keeping JSON ↔ md prose in lockstep now avoids a gratuitous drift trip later.
- [x] [Review][Patch] Waiver expiry YAML snippet carries the unfilled placeholder `expiry: '2026-XX-XX'` [`_bmad-output/test-artifacts/traceability/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:~1209`] — LOW; replace with `deferred` or a concrete expiry date tied to Story 1.9's landing. **Resolved iter-11 (fix #4/4):** set `expiry: 'deferred (expires when Story 1.9 sync-gate lands)'` at actual line 514 (CR's `~1209` pointer drifted per iter-10 lesson — live trace md is 540 lines). `deferred` chosen over an arbitrary concrete date because Story 1.9's landing date isn't fixed; the parenthetical preserves the remediation trigger. Semantics match `remediation_due: 'Stories 1.8 + 1.9 (Epic 1 backlog)'` already present in the same waiver block. Final CR fix complete → next iteration re-runs `/bmad-code-review` to confirm `### Review Findings` cleared → Story State `fixes-pending → sm-verified → done` (or new fix if any finding surfaces).
- [x] [Review][Defer] `1-7-gate-decision.json` lacks structured `waiver: {reason, approver, expiry, remediation_due}` sub-object; `rationale` prose is present; the structured waiver block IS present in `1-7-e2e-trace-summary.json` [`_bmad-output/test-artifacts/traceability/1-7-gate-decision.json`] — deferred, trace-skill schema concern not Story 1.7 scope.
- [x] [Review][Defer] `architecture.md:891` shows an idealised `packages/keel-invariants/src/` layout but on-disk is `packages/keel-invariants/` at package root (no `src/` parent for config files) [`_bmad-output/planning-artifacts/architecture.md:891`] — deferred, pre-existing architecture-doc gap predating Story 1.7; Story 1.8's manifest will reconcile.
- [x] [Review-iter-12][Patch] Waiver `expiry` field in `1-7-e2e-trace-summary.json:107` reads `"On Story 1.9 sync-gate landing"` but iter-11 canonicalised the md YAML to `'deferred (expires when Story 1.9 sync-gate lands)'` [`_bmad-output/test-artifacts/traceability/1-7-e2e-trace-summary.json:107`] — MEDIUM; iter-11's scope was the md YAML only, leaving the sibling JSON stale. Fix by normalising JSON to the canonical form so the trace bundle is consistent (Story 1.9's sync-gate would otherwise content-hash-drift on the JSON field). **Resolved iter-13 (fix #1/2):** flipped JSON string at `1-7-e2e-trace-summary.json:107` to `"deferred (expires when Story 1.9 sync-gate lands)"` — character-verbatim match with md YAML L515 modulo JSON-vs-YAML quote style. Confirmed by iter-15 Blind + Edge hunters (cross-triplet probe UNIFIED).
- [x] [Review-iter-12][Patch] Trace md YAML `recommendations:` list at lines 478-481 enumerates only 3 items (AC-1/2, AC-3, AC-5) and omits AC-4 ("Accept manual + Prettier review for AC-4; no planned automated coverage"), whereas both sibling JSONs (`1-7-coverage-matrix.json:125-146` + `1-7-e2e-trace-summary.json:70-91`) include all 4 [`_bmad-output/test-artifacts/traceability/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:478-481`] — LOW; pre-existing authoring gap in iter-5's trace md (not introduced by CR fixes). Fix by adding the AC-4 line to the YAML snippet. **Resolved iter-14 (fix #2/2):** inserted `- 'Accept manual + Prettier review for AC-4; no planned automated coverage'` at line 481 between AC-3 and AC-5 entries. All 3 files now enumerate 4 items in canonical order (AC-1/2 → AC-3 → AC-4 → AC-5). Confirmed by iter-15 Acceptance Auditor (4 entries verified across all 3 files at md:478-482 / coverage-matrix.json:126-145 / e2e-trace-summary.json:71-90).
- [x] [Review-iter-15][Patch] Trace md YAML `recommendations:` list at lines 479/480/482 drops qualifier words (`automated` / `hard`) that BOTH sibling JSONs retain: md says `"Defer AC-1 / AC-2 coverage to Story 1.9 FR43 sync-gate"` / `"Defer AC-3 coverage to Story 1.8 invariants.manifest.ts"` / `"Defer AC-5 enforcement to Epic 3 RS6 lint"` whereas JSONs say `"automated coverage"` (AC-1/2, AC-3) and `"hard enforcement"` (AC-5). AC-4 bullet (added iter-14) matches verbatim [`_bmad-output/test-artifacts/traceability/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:479-482` + `_bmad-output/test-artifacts/traceability/1-7-coverage-matrix.json:128/134/143` + `_bmad-output/test-artifacts/traceability/1-7-e2e-trace-summary.json:73/79/88`] — MEDIUM; same drift class as iter-12 #1/2 (sibling wording not normalised when iter-11 canonicalised `expiry`); semantically `coverage` ≠ `automated coverage` (Story 1.7 explicitly has manual Prettier coverage for AC-4), `enforcement` ≠ `hard enforcement` (soft-warn RS6 is the carve-out). Fix by restoring `automated` / `hard` qualifiers in md YAML bullets so all three files speak verbatim — mirroring iter-13's JSON→md alignment approach. **Resolved iter-16 (fix #1/2):** restored qualifiers in `1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:479-482` — line 479 `Defer AC-1 / AC-2 automated coverage to Story 1.9 FR43 sync-gate`; line 480 `Defer AC-3 automated coverage to Story 1.8 invariants.manifest.ts`; line 482 `Defer AC-5 hard enforcement to Epic 3 RS6 lint`. All three trace files (md YAML + coverage-matrix.json + e2e-trace-summary.json) now use the canonical wording for the four `recommendations:` items.
- [ ] [Review-iter-15][Patch] Story-file narrative at line 148 reads `**Seven invariants captured at Story 1.7 authorship:**` but enumerates 9 INV-IDs (`INV-tsconfig-base` / `INV-eslint-shared` / `INV-prettier-shared` / `INV-commitlint-shared` / `INV-eslint-import-boundary` / `INV-prek-pre-commit-config` / `INV-prek-prepare-lifecycle` / `INV-prek-commit-msg-config` / `INV-no-verify-bypass`) and closes with `(Count: 9.)` [`_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md:148`] — LOW; pre-existing prose miscount authored at Story 1.7 skeleton creation (the initial "Seven" predates the Story 1.4 two-INV split of eslint into `INV-eslint-shared` + `INV-eslint-import-boundary` and the Story 1.5 four-INV prek enumeration). Prose contradiction is load-bearing-free today (no parser ingests this sentence) but could mislead a Story 1.8+ agent heuristically counting from the prose rather than the enumeration. Fix by `s/Seven invariants/Nine invariants/`.
