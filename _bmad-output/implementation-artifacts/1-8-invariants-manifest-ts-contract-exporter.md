# Story 1.8: `invariants.manifest.ts` contract + exporter

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a substrate maintainer,
I want `packages/keel-invariants/src/invariants.manifest.ts` exporting a typed list of every substrate invariant with stable IDs and content hashes,
So that the sync-gate tooling has a machine-readable contract to drift-detect against (FR43 contract side).

## Acceptance Criteria

1. **Given** the `keel-invariants` package,
   **When** I read `src/invariants.manifest.ts`,
   **Then** it exports `const invariants: Invariant[]`
   **And** each entry has `{ id: string, description: string, sourcePath: string, contentHash: string, anchors: string[] }`.

2. **Given** the manifest,
   **When** I inspect any entry,
   **Then** `id` follows `INV-<category>-<slug>` (e.g., `INV-commit-conventional-format`, `INV-tokens-sync-gate`)
   **And** `sourcePath` resolves to an existing file under the repo root
   **And** `contentHash` is the sha256 of the source region bounded by declared anchors.
   **Story 1.8 scope carve-out:** Story 1.8 bounds `contentHash` to the **whole sourcePath file** (anchor-bounded region = whole file). Anchor-scoped sub-region hashing is deferred to Story 1.9 (sync-gate) when anchor-walker infrastructure lands. This keeps Story 1.8 a pure data-contract change and leaves Story 1.9's walker free to refine the region semantics.

3. **Given** a typed `Invariant` interface,
   **When** a new rule is added to `keel-invariants`,
   **Then** it MUST register a manifest entry with a fresh stable ID
   **And** Story 1.9 treats unregistered rules as drift.
   **Story 1.8 scope carve-out:** AC 3's "Story 1.9 treats unregistered rules as drift" is the sync-gate's runtime responsibility (FR43 enforcement side). Story 1.8 ships the **contract** side: `Invariant` type + canonical list of the 9 invariants already in `INVARIANTS.md` (Stories 1.2–1.6 outputs) + content hashes + import-time Zod validation. No pre-merge gate, no anchor walker, no source-tree scan — those are Story 1.9's scope.

4. **Given** the exporter,
   **When** consumed by Story 1.9's sync gate,
   **Then** the manifest loads synchronously (no async I/O) and validates against its own Zod (or equivalent) schema at import time.

## Tasks / Subtasks

- [x] **Task 1: Author `packages/keel-invariants/src/invariants.manifest.ts`** (AC: 1, 2, 3, 4)
  - [x] Create `packages/keel-invariants/src/invariants.manifest.ts` as ESM TypeScript (package is `"type": "module"`; `tsc -b` compiles to `dist/` per `packages/keel-invariants/tsconfig.json` — variance: the rest of `keel-invariants/` uses `.js` ESM source; Story 1.8 introduces `.ts` under `src/` because the contract requires a typed `Invariant` interface. Matches `src/index.ts` which is already `.ts`.)
  - [x] Author the `Invariant` interface + Zod schema + canonical list of 9 entries. Skeleton:
    ```typescript
    import { z } from 'zod';

    export const InvariantSchema = z.object({
      id: z.string().regex(/^INV-[a-z0-9]+(-[a-z0-9]+)+$/),
      description: z.string().min(1),
      sourcePath: z.string().min(1),
      contentHash: z.string().regex(/^[0-9a-f]{64}$/),
      anchors: z.array(z.string().min(1)).min(1),
    });

    export type Invariant = z.infer<typeof InvariantSchema>;

    export const InvariantsSchema = z.array(InvariantSchema);

    const raw: Invariant[] = [
      {
        id: 'INV-tsconfig-base',
        description:
          'Strict TS + project-reference contract extended by every workspace member.',
        sourcePath: 'packages/keel-invariants/tsconfig.base.json',
        contentHash:
          '4c80ad75308b9b98aa3dfa288f2f124de2aa7da982ce9e509fc7d6b830c2c855',
        anchors: ['INV-tsconfig-base'],
      },
      {
        id: 'INV-eslint-shared',
        description:
          'Shared ESLint flat-config baseline: global ignores + js.configs.recommended + tseslint.configs.recommended (spread) + languageOptions.globals (node + browser).',
        sourcePath: 'packages/keel-invariants/eslint.config.keel-invariants.js',
        contentHash:
          '10ac60e693c32566971eecd52341d6f5b9b42047843812fd8f8153310112afe2',
        anchors: ['INV-eslint-shared'],
      },
      {
        id: 'INV-prettier-shared',
        description:
          '9-key keel house style (printWidth 100, singleQuote, trailingComma all, lf EOL, ...).',
        sourcePath: 'packages/keel-invariants/prettier.config.keel-invariants.js',
        contentHash:
          '17a4520e3538ec82e4e80e04252711cb7641717adfe2d9c1bda03b87b5a48311',
        anchors: ['INV-prettier-shared'],
      },
      {
        id: 'INV-commitlint-shared',
        description:
          'Conventional-commits + 3-key rule overrides (subject-case off, header-max-length 120, body-max-line-length off).',
        sourcePath: 'packages/keel-invariants/commitlint.config.keel-invariants.js',
        contentHash:
          '4f9d3b263e73ebac518c0c42fa4b17b37cb252d3cacce76947a102c382b60f41',
        anchors: ['INV-commitlint-shared'],
      },
      {
        id: 'INV-eslint-import-boundary',
        description:
          'no-restricted-imports denies cross-package relative imports (AC 1), @keel/*/internal/* deep imports (AC 2), and per-package self-import via alias (AC 3 via forPackage(ownName) overlay).',
        sourcePath: 'packages/keel-invariants/eslint.config.keel-invariants.js',
        contentHash:
          '10ac60e693c32566971eecd52341d6f5b9b42047843812fd8f8153310112afe2',
        anchors: ['INV-eslint-import-boundary'],
      },
      {
        id: 'INV-prek-pre-commit-config',
        description:
          '3 local hooks (typecheck / lint / format-check) wired at repo root; each language: system, pass_filenames: false, always_run: true.',
        sourcePath: '.pre-commit-config.yaml',
        contentHash:
          '0e8e353f9564c6c278e44c19ba636a0e31bad5ac1e10b58e6da9e0cc36b93bb1',
        anchors: ['INV-prek-pre-commit-config'],
      },
      {
        id: 'INV-prek-prepare-lifecycle',
        description:
          'Root package.json prepare script installs prek shims for both pre-commit and commit-msg stages via prek install -t pre-commit -t commit-msg.',
        sourcePath: 'package.json',
        contentHash:
          '0ba4c6fb37950832c7c132aac36eded95141d372dd93cb507141e031d7c40476',
        anchors: ['INV-prek-prepare-lifecycle'],
      },
      {
        id: 'INV-prek-commit-msg-config',
        description:
          '4th hook entry id: commitlint, stages: [commit-msg], entry: pnpm exec commitlint --edit, language: system; prek passes <COMMIT_EDITMSG> as trailing positional.',
        sourcePath: '.pre-commit-config.yaml',
        contentHash:
          '0e8e353f9564c6c278e44c19ba636a0e31bad5ac1e10b58e6da9e0cc36b93bb1',
        anchors: ['INV-prek-commit-msg-config'],
      },
      {
        id: 'INV-no-verify-bypass',
        description:
          'ESLint rule keel-invariants/no-verify-bypass flags --no-verify / --dangerously-skip-permissions hook-bypass tokens appearing as string literals or static template-literal quasis in committed JS/TS.',
        sourcePath: 'packages/keel-invariants/src/eslint-rules/no-verify-bypass.js',
        contentHash:
          '08bf6e89c0936ce5106e9d24f22ef61ca3e8198ce005041b10e2989fa92ba674',
        anchors: ['INV-no-verify-bypass'],
      },
    ];

    export const invariants: Invariant[] = InvariantsSchema.parse(raw);
    ```
  - [x] Re-export `invariants`, `Invariant`, `InvariantSchema`, `InvariantsSchema` from `packages/keel-invariants/src/index.ts`. Current `index.ts` is `export {};` — replace with the re-exports. Consumers (Story 1.9's sync-gate) import via `@keel/keel-invariants` (the package root; resolves through `./dist/index.js` per `package.json` exports map).
  - [x] Verify that every `sourcePath` resolves to an existing file at the repo root (Task 3's typecheck/lint doesn't cover this — it's a manual `ls` check against the 9 entries; any stale pointer fails AC 2).
  - [x] **Discharged in spec-authoring (commit `8991214`, iter-1).** architecture.md hyphen→dot normalisation was co-landed with this spec; current line is `architecture.md:942` in dot-form (`│   │   ├── invariants.manifest.ts               # FR43 generated manifest (ID+hash)`), matching epic spec + PRD FR43 + this story's file path. RALPH.md 2026-04-20 iter-20 Story-1.7-carry-forward defer is closed — no Dev action needed on this subtask.

- [x] **Task 2: Add `zod` dependency + wire Zod import-time validation** (AC: 4)
  - [x] Add `zod` as a runtime dependency to `packages/keel-invariants/package.json`. Pin exact version (per I7 version-pinning posture from epics.md:650). **Applied pin: `"zod": "3.25.76"`** (latest 3.x patch at dev time 2026-04-20; skipped v4.x major-version line — breaking changes vs 3.x would widen scope beyond Story 1.8's contract-only remit). `pnpm install -w` updated `pnpm-lock.yaml` (+1 package).
  - [x] Verify Zod import-time validation is load-bearing: the `InvariantsSchema.parse(raw)` call at the bottom of `invariants.manifest.ts` runs synchronously at module import. A bad entry (malformed `id`, empty `anchors`, bad `contentHash` length) throws `ZodError` with a structured path, failing any downstream consumer loudly. This is AC 4's "validates against its own Zod (or equivalent) schema at import time" — realised by the `parse` call, not a post-load validator.
  - [x] No separate `validate-manifest.ts` helper needed. The schema + parse call live inline in `invariants.manifest.ts` (single file, one contract). Future Ralph adding a new invariant: append to `raw` array, Zod catches any shape error at next `tsc -b`. Simpler than a separate validator module.

- [x] **Task 3: Quality gates + sprint-status bump** (no AC — substrate verification)
  - [x] `pnpm install` at repo root. `pnpm-lock.yaml` updates with zod + its deps. `prepare` re-runs `prek install -t pre-commit -t commit-msg` idempotently.
  - [x] `pnpm -w typecheck` — 16/16 successful, 0 failures (1.833s; cache miss on new `.ts` input as expected).
  - [x] `pnpm -w lint` — 16/16 successful. **Note (dev-time finding):** first run flagged `INV-no-verify-bypass` description literal for naming the `--no-verify` / `--dangerously-skip-permissions` tokens (the rule catches itself when the flag names appear as string literals in committed JS/TS). Fix: rewrote the description to reference the rule source (`src/eslint-rules/no-verify-bypass.js BYPASS_PATTERNS`) rather than naming the tokens inline — cleaner DRY posture (tokens live in one authoritative place). INVARIANTS.md kept verbatim (markdown is out of rule scope; human-readable layer benefits from naming the tokens explicitly). Consistent with `sharedBase`'s self-exclusion pattern for `eslint-rules/**`.
  - [x] `pnpm -w build` — `keel-invariants#build` emits `dist/index.js` + `dist/invariants.manifest.js` + `.d.ts` files; 16/16 successful.
  - [x] `pnpm format:check` — first pass flagged `invariants.manifest.ts` (line-wrapping); ran `pnpm exec prettier --write` to auto-fix; re-check passes 0 problems.
  - [x] `pnpm exec commitlint --from origin/main --to HEAD --verbose` — 0 problems across the branch.
  - [x] `pnpm exec prek run --all-files` — TypeScript type-check / ESLint / Prettier format:check all `Passed`.
  - [x] Runtime smoke check: `node --input-type=module -e "import('@keel/keel-invariants')…"` prints `OK: 9 invariants`. Zod parse succeeds at import time (AC 4 end-to-end).
  - [x] Bump `_bmad-output/implementation-artifacts/sprint-status.yaml`: `1-8-invariants-manifest-ts-contract-exporter: ready-for-dev → done` (direct jump; skipped the `in-progress → review` BMad intermediate per Story 1.7 precedent — Ralph's FR14n lifecycle owns the gates that follow). `last_updated: 2026-04-20 Story-1-8-done UTC`.
  - [x] Flipped this story file's Status to `done`, marked all Task subtasks `[x]`, populated `## Dev Agent Record`.

## Dev Notes

- Relevant architecture patterns and constraints:
  - [Source: architecture.md:942] `packages/keel-invariants/src/invariants.manifest.ts` lives under the package's `src/` tree alongside schemas + eslint-rules + semgrep-rules. Role in architecture: "FR43 generated manifest (ID+hash)". The hyphen→dot normalisation at this line was co-landed with the iter-1 spec-authoring commit (`8991214`); no further architecture.md edit is required for Story 1.8.
  - [Source: prd.md FR43] "System can enforce sync between the machine-enforced layer (`packages/keel-invariants/`) and the agent-readable layer (`INVARIANTS.md`) via a pre-merge gate that reads an exported `invariants.manifest.ts` (stable-ID + content-hash per rule)". Story 1.8 is the **contract side** (the exporter); Story 1.9 is the **enforcement side** (the gate that reads it).
  - [Source: epics.md:860–886] Story 1.8 ACs specify `{ id, description, sourcePath, contentHash, anchors }` shape, `INV-<category>-<slug>` id format, synchronous load, Zod-or-equivalent import-time validation.
  - [Source: `INVARIANTS.md` (Story 1.7 output)] 9 provisional invariants are already indexed in the agent-readable layer. Story 1.8 imports this list verbatim into `raw`. IDs remain identical (the `<!-- Provisional: … -->` header in INVARIANTS.md explicitly grants Story 1.8 license to edit — Story 1.8 chooses to accept all 9 as-is, no renames).
- Source tree components to touch:
  - **NEW:** `packages/keel-invariants/src/invariants.manifest.ts` (the contract + data).
  - **EDIT:** `packages/keel-invariants/src/index.ts` (re-exports; currently `export {};`).
  - **EDIT:** `packages/keel-invariants/package.json` (add `"dependencies": { "zod": "<pin>" }`).
  - **EDIT:** `pnpm-lock.yaml` (auto-updated by `pnpm install`).
  - **EDIT:** `_bmad-output/implementation-artifacts/sprint-status.yaml` (status bump + last_updated).
  - _(architecture.md:942 hyphen→dot normalisation already discharged in iter-1 spec-authoring commit `8991214`; not a Dev-story edit target.)_
- Testing standards summary:
  - **§ Testing Standards:** No dedicated unit-test file for `invariants.manifest.ts` in Story 1.8 scope. Rationale: (a) the Zod schema IS the test — any malformed entry fails at module import, caught by Task 3's runtime smoke check (`node -e "import('@keel/keel-invariants')…"`) AND by downstream consumer imports (Story 1.9's sync-gate will import it and exercise Zod parse on every pre-merge invocation); (b) no test runner is wired at substrate level yet (Story 1.16 scope); (c) the 9 content-hashes are frozen data — no behaviour to unit-test beyond "Zod accepts the shape", which Zod's own test suite covers. Story 1.9's sync-gate tests will exercise the manifest end-to-end (anchor-walk vs INVARIANTS.md; file-read vs `contentHash` re-computation).
  - Quality-gate bundle from Stories 1.4/1.5/1.6/1.7 applies: typecheck + lint + format:check + commitlint + prek-runner parity. All MUST pass at Task 3.

### Project Structure Notes

- **Alignment with unified project structure:** `packages/keel-invariants/src/invariants.manifest.ts` matches architecture.md:922 (post-Task-1 dot-form normalisation). No variance.
- **§ Scope Carve-Out — Story 1.8 is contract-only; Story 1.9 owns enforcement.** Story 1.8 ships: (a) `Invariant` interface + Zod schema; (b) canonical `invariants` export (9 entries from Story 1.7's INVARIANTS.md); (c) content-hash field populated with sha256 of whole sourcePath file; (d) re-exports from package root. Story 1.8 does NOT ship: (a) anchor-walker that parses `INVARIANTS.md` for `INV-*` headings; (b) source-tree scanner that finds unregistered rules; (c) pre-merge gate invocation; (d) CLI entry point (`pnpm keel-invariants:check`). All four are Story 1.9's scope per FR43 enforcement side + architecture.md W2 party-mode amendment.
- **§ ContentHash anchor-bounding carve-out.** AC 2 specifies `contentHash` as "sha256 of the source region bounded by declared anchors". Story 1.8 interprets "bounded by declared anchors" as the **whole sourcePath file** (one anchor per file, anchor name matches the `INV-*` id). Rationale: (a) the 9 Story-1.7 invariants each cite a distinct source file (or a distinct config-block within a shared file — `eslint.config.keel-invariants.js` hosts both `INV-eslint-shared` and `INV-eslint-import-boundary`; `.pre-commit-config.yaml` hosts both `INV-prek-pre-commit-config` and `INV-prek-commit-msg-config`); for these shared-source cases, whole-file hashing produces identical `contentHash` across sibling invariants (by design — any edit to the shared file drifts all its owning invariants, which is the intended cross-cutting detection behaviour at Story 1.9); (b) sub-region hashing requires an anchor-walker (Story 1.9's scope); (c) this keeps Story 1.8 as a pure data-contract change — no runtime parsing, no async file I/O at authoring time (hashes are pre-computed and baked into source). Future Ralph at Story 1.9 authoring time: refine anchor region semantics if needed; this carve-out gives Story 1.9 explicit license.
- **§ Zod versus hand-authored validator.** Story 1.8 uses Zod (not a bespoke validator) per AC 4's "Zod (or equivalent)" license. Rationale: (a) Zod is canonical in the architecture tech stack (other schemas — `halt.schema.json`, `plan.schema.json`, `rule.schema.json` — will need a TS-layer validator in later stories; Zod is the natural shared choice); (b) Zod's runtime cost at import time is ~1ms for 9 entries (empirically negligible); (c) keeps the manifest file self-contained (no separate validator module). Zod pin version is captured in `package.json` and frozen — future substrate updates bump it as a substrate-wide decision. `keel-invariants` is the ONLY package with zod in `dependencies` at Story 1.8 — downstream consumers (apps/web, packages/core, etc.) will get it transitively via their `@keel/keel-invariants` edge when those packages land.
- **§ `src/index.ts` public-surface change.** Current `index.ts` is `export {};` (empty namespace barrel). Task 1 replaces with `export * from './invariants.manifest.js';` (note the `.js` extension in the import specifier — TS `NodeNext` module resolution requires the runtime `.js` extension even when the source is `.ts`). This is the ONLY public surface of the `keel-invariants` package at Story 1.8 completion; other exports (`./tsconfig`, `./eslint`, `./prettier`, `./commitlint`, `./eslint-plugin`) remain wired through the `package.json` exports map to their respective non-barrel source files.
- **§ Provisional-ID header discharge.** INVARIANTS.md's `<!-- Provisional: canonical IDs pinned by Story 1.8 manifest; drift-detection lands in Story 1.9. -->` header (Story 1.7 scope carve-out) is DISCHARGED by this story for the "canonical IDs pinned" half — all 9 IDs are accepted as-is and now pinned in the manifest. The "drift-detection lands in Story 1.9" half remains an active forward-reference; the header stays in INVARIANTS.md until Story 1.9 lands, at which point Story 1.9's Task will remove the provisional note.

## Dev Agent Record

### Context Reference

_(Ralph-hosted `/bmad-dev-story` executed this story inline; no separate traceability artifact produced at dev-story time. Story 1.9's `/bmad-testarch-trace` (queued in IP) will produce the traceability matrix if applicable.)_

### Agent Model Used

Claude Opus 4.7 (1M context) — via Ralph iteration loop hosting `/bmad-dev-story`.

### Debug Log References

Two dev-time findings, both fixed in-iteration without deferrals:

1. **ESLint self-reference collision on `INV-no-verify-bypass` description** — first lint pass failed because the manifest entry's description literal named the bypass tokens (`--no-verify` / `--dangerously-skip-permissions`) and the `keel-invariants/no-verify-bypass` rule flags those tokens as string literals in committed JS/TS. Considered three options: (a) expand the rule's self-exclusion glob to include `invariants.manifest.{ts,js}` — rejected because it would cascade `eslint.config.keel-invariants.js` hash updates into `INV-eslint-shared` + `INV-eslint-import-boundary` contentHash values; (b) split the tokens via string concatenation — rejected as non-obvious to future maintainers; (c) rewrite the description to reference the rule source's `BYPASS_PATTERNS` constant rather than naming tokens inline — **adopted**: one authoritative place for the tokens (the rule source), DRY, no hash cascade. INVARIANTS.md kept verbatim (markdown is out of the rule's JS/TS scope; human-readable layer benefits from naming tokens explicitly for agent comprehension).

2. **Prettier line-wrapping on authored file** — first `format:check` pass flagged `invariants.manifest.ts`. Ran `pnpm exec prettier --write`; prettier collapsed the multi-line key/value pairs for shorter entries (e.g., `INV-tsconfig-base`) and preserved wrapping for longer descriptions. Re-check passed. No semantic change.

**Zod version pin decision:** spec suggested `3.25.0` with a "bump if a fresher pin lands" clause. At dev time (2026-04-20), `npm view zod version` returned `4.3.6`; `npm view zod@3 version` tip was `3.25.76`. Chose `3.25.76` (latest 3.x patch) over `4.3.6`. Rationale: Zod 4.x is a major-version line with breaking changes from 3.x; jumping majors would widen Story 1.8's scope beyond its contract-only remit. The spec author's `3.25.0` suggestion signalled the 3.x line; `3.25.76` is a patch-level bump within that line, consistent with the spec's intent.

### Completion Notes List

- **Task 1 (AC 1, 2, 3, 4):** authored `packages/keel-invariants/src/invariants.manifest.ts` with the `Invariant` type + `InvariantSchema` + `InvariantsSchema` Zod schemas + canonical list of 9 invariant entries matching INVARIANTS.md. ContentHashes match freshly-computed `sha256sum` for all 7 distinct sourcePath files (verified before authoring). `src/index.ts` replaced with `export * from './invariants.manifest.js';` (NodeNext module resolution requires runtime `.js` extension in the specifier). All 9 sourcePath files exist on disk.
- **Task 2 (AC 4):** added `"dependencies": { "zod": "3.25.76" }` to `packages/keel-invariants/package.json`. `pnpm install -w` added 1 package + updated `pnpm-lock.yaml`. Zod import-time validation is load-bearing: `InvariantsSchema.parse(raw)` runs synchronously at module import; a bad entry throws `ZodError` → downstream consumers fail loudly. Verified via runtime smoke test (see Task 3).
- **Task 3 (substrate verification):** quality-gate bundle all green — `pnpm -w typecheck` 16/16 (1.833s), `pnpm -w lint` 16/16 after description fix (6.87s), `pnpm -w build` 16/16 (2.88s) emitting `dist/invariants.manifest.js` + `.d.ts`, `pnpm format:check` 0 problems after prettier auto-write, `pnpm exec commitlint --from origin/main --to HEAD` 0 problems, `pnpm exec prek run --all-files` all 3 hooks `Passed`. Runtime smoke test: `node --input-type=module -e "import('@keel/keel-invariants')…"` prints `OK: 9 invariants` (AC 4 end-to-end in one shell command). Sprint-status bumped `1-8: ready-for-dev → done`, `last_updated: 2026-04-20 Story-1-8-done UTC` (direct jump past the `in-progress → review` BMad intermediate, per Story 1.7 precedent — Ralph's FR14n lifecycle owns the trace/SM-review/CR gates that follow this dev-completion commit).

### File List

- **NEW:** `packages/keel-invariants/src/invariants.manifest.ts`
- **MODIFIED:** `packages/keel-invariants/src/index.ts` (`export {};` → `export * from './invariants.manifest.js';`)
- **MODIFIED:** `packages/keel-invariants/package.json` (added `"dependencies": { "zod": "3.25.76" }`)
- **MODIFIED:** `pnpm-lock.yaml` (auto-updated by `pnpm install -w`; +1 package)
- **MODIFIED:** `_bmad-output/implementation-artifacts/sprint-status.yaml` (`1-8: ready-for-dev → done`; `last_updated` bumped)
- **MODIFIED:** `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md` (Status `in-progress → done`; Task checkboxes `[x]`; Dev Agent Record populated; Change Log v1.2 added)

## Change Log

| Date       | Version | Description           | Author |
| ---------- | ------- | --------------------- | ------ |
| 2026-04-20 | 1.0     | Initial story authoring (Ralph; spec via /bmad-create-story inline-realisation per Story 1.6/1.7 precedent). | Ralph |
| 2026-04-20 | 1.1     | Pre-dev SM review (Ralph, iter-2; drafted → validated). Applied one critical fix: discharged the stale architecture.md:922 hyphen→dot normalisation subtask (already landed in iter-1 commit 8991214; line is now :942 dot-form). Source-pointer + contentHash + INV-\* ID audit confirmed 9/9 match INVARIANTS.md + on-disk sha256. ACs 1–4 well-formed; double-anchored scope carve-outs (AC inline + § Project Structure Notes) intact. | Ralph |
| 2026-04-20 | 1.2     | Dev-story execution (Ralph-hosted `/bmad-dev-story`, iter-4; atdd-scaffolded → in-dev). All 3 Tasks landed in one iteration: Task 1 authored `invariants.manifest.ts` + updated `src/index.ts`; Task 2 added `zod@3.25.76` (3.x patch, skipped 4.x major); Task 3 ran full quality-gate bundle (all green). Two dev-time findings fixed in-iteration: (a) rewrote `INV-no-verify-bypass` description to reference the rule source rather than naming the flagged tokens inline (avoids ESLint self-reference collision + DRY); (b) prettier auto-write on `invariants.manifest.ts`. Runtime smoke test `OK: 9 invariants`. Status flipped to `done`; sprint-status `1-8: ready-for-dev → done`. | Ralph |
| 2026-04-20 | 1.3     | Post-dev SM review (Ralph, iter-6; traced → sm-verified per FR14n matrix row 7). AC-by-AC requirements-satisfaction audit against implementation: AC 1 ✓ `invariants: Invariant[]` exported with all 5 fields per entry (invariants.manifest.ts:89, 9 entries); AC 2 ✓ regex enforced by Zod schema, 9/9 sourcePaths verified existing on disk, 9/9 sha256 contentHashes re-computed and matched (whole-file carve-out intact); AC 3 ✓ `Invariant` type + canonical 9-entry list delivered (contract side), enforcement carved to Story 1.9; AC 4 ✓ `InvariantsSchema.parse(raw)` at top-level module scope (synchronous; no async I/O), runtime smoke via `import('@keel/keel-invariants')` confirms 9 invariants load and `InvariantSchema` is exported. Zero unmet-AC findings; zero fix tasks queued. Next gate: `/bmad-code-review (args: "2")`. | Ralph |
