# Story 1.9: Invariant sync-gate runtime tooling (reader + walker + drift detector)

Status: drafted

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a substrate maintainer,
I want `packages/keel-invariants/src/sync-gate.ts` + `manifest-reader.ts` that read the manifest, walk machine-enforced sources + `INVARIANTS.md` anchors, and fail loudly on drift,
So that FR43 has teeth from day 1 (Party-Mode Round 2 / W2 amendment).

## Acceptance Criteria

1. **Given** the manifest from Story 1.8 and `INVARIANTS.md` anchors,
   **When** I run `pnpm keel-invariants:check`,
   **Then** the tool exits zero if every manifest entry has a matching `INVARIANTS.md` anchor AND every anchor has a matching entry AND every content hash matches
   **And** exits non-zero with a structured drift report otherwise.

2. **Given** a new rule added to `packages/keel-invariants/src/` (or any `sourcePath`) without a manifest entry (addition drift),
   **When** the gate runs,
   **Then** it reports `added-to-source-only` with the source path and exits non-zero.
   **Story 1.9 scope carve-out:** "Addition drift" at Story 1.9 is realised as **anchor-side drift only** — an `INV-*` anchor in `INVARIANTS.md` with no matching manifest entry (the `removed-from-docs-only` branch already catches orphan anchors; this AC's "added-to-source-only" shape is the symmetrical case where a source file referenced from a new anchor has no manifest row). Source-tree scanning (walking `packages/keel-invariants/src/**` to auto-discover un-registered rules) is deferred to a later hardening story — the current substrate has 10 invariants all intentionally registered, and auto-discovery would require rule-file introspection heuristics beyond FR43's 1.0 remit. Story 1.9 ships the anchor-side and hash-side branches; source-tree auto-discovery is optional follow-up.

3. **Given** a manifest entry whose `sourcePath` file is deleted (removal drift),
   **When** the gate runs,
   **Then** it reports `removed-from-source-only` and exits non-zero.

4. **Given** a source edit that doesn't update the manifest's `contentHash` (edit drift),
   **When** the gate runs,
   **Then** it reports `content-hash-mismatch` naming the manifest ID and the offending file
   **And** exits non-zero.

5. **Given** an `INVARIANTS.md` anchor removed without a manifest entry removal,
   **When** the gate runs,
   **Then** it reports `removed-from-docs-only` and exits non-zero.

6. **Given** the tool's exit codes,
   **When** Epic 13 wires it into GitHub Actions,
   **Then** non-zero reliably fails the workflow and the drift report renders in CI logs.
   **Story 1.9 scope carve-out:** the CI workflow itself lands with Epic 13 (F/E pipeline story). Story 1.9 delivers the CLI + exit-code contract (0 = clean; non-zero = drift, with the structured report on stdout); Epic 13 wires the `.github/workflows/*.yml` step that invokes `pnpm keel-invariants:check`. Verification at Story 1.9 time is via local CLI invocation (clean repo → exit 0; induced drift → exit non-zero with structured JSON report on stdout).

7. **Given** the tool is callable locally,
   **When** run on the baseline repo,
   **Then** it completes in under 2 seconds.

## Tasks / Subtasks

- [ ] **Task 1: Author `packages/keel-invariants/src/manifest-reader.ts` + `sync-gate.ts` core** (AC: 1, 2, 3, 4, 5, 7)
  - [ ] Create `packages/keel-invariants/src/manifest-reader.ts` as ESM TypeScript. Thin module that re-exports the canonical manifest list from `./invariants.manifest.js` plus two helpers: `readSourceFile(absPath: string): Promise<string>` (uses `node:fs/promises.readFile` utf-8) and `computeSha256(content: string): string` (uses `node:crypto.createHash('sha256').update(content).digest('hex')`). No Zod re-validation needed — `invariants.manifest.ts` already parses at import time.
  - [ ] Create `packages/keel-invariants/src/sync-gate.ts` as ESM TypeScript. Exports `runSyncGate(repoRoot: string): Promise<DriftReport>`. The `DriftReport` type (exported) carries `{ status: 'clean' | 'drift', drifts: Drift[] }` where `Drift = { kind: 'added-to-source-only' | 'removed-from-source-only' | 'content-hash-mismatch' | 'removed-from-docs-only', id?: string, sourcePath?: string, expectedHash?: string, actualHash?: string, anchor?: string }`.
  - [ ] Implement the anchor walker: read `INVARIANTS.md` at `${repoRoot}/INVARIANTS.md`, enumerate every `**\`INV-<category>-<slug>\`**` bold-code heading, return a `Set<string>` of discovered anchor IDs. Parser: regex `/^-\s+\*\*`([A-Z][A-Z0-9-]+)`\*\*/gm` (matches the bullet-style anchors used in the current `INVARIANTS.md § Invariants index`). See `INVARIANTS.md:24-48` for the 10 current anchors.
  - [ ] Implement the drift detector: for each `Invariant` entry in `invariants`: (a) check that the entry's `id` exists in the anchor set (else → no drift — the manifest is the contract source; manifest-only IDs without an anchor are implicitly handled by AC 5's inverse check + FR43's symmetric-orphan rule — **this case does not exist when the gate is clean**); (b) read the `sourcePath` file (if missing → `removed-from-source-only`); (c) re-compute sha256; (d) compare against `contentHash` (mismatch → `content-hash-mismatch`). For anchors in `INVARIANTS.md` with no matching manifest entry → `removed-from-docs-only`. The symmetric "added-to-source-only" case (anchor exists, manifest row exists, source file exists, but a NEW `INV-*` bullet was added to the docs without a manifest row) is the `removed-from-docs-only` flow observed from the docs side.
  - [ ] Hash shared-source files ONCE (not per sibling invariant). Deduplicate by `sourcePath` before reading: the current manifest has two shared-source pairs (`eslint.config.keel-invariants.js` hosts `INV-eslint-shared` + `INV-eslint-import-boundary`; `.pre-commit-config.yaml` hosts `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config`). Reading each distinct source once + comparing against every sibling's expected hash is both (a) faster and (b) automatically flags any cross-entry `contentHash` inconsistency (Story 1.8 CR defer #4 — if two entries share a `sourcePath` but disagree on `contentHash`, at least one fails the comparison; distinct-path-hash-map surfaces the mismatch trivially).
  - [ ] Performance: target <500ms for 10 invariants on the baseline repo (AC 7 budget is 2s; leaves 4x headroom for later substrate growth). `Promise.all()` the file reads. Do not parse markdown beyond the bullet-anchor regex.

- [ ] **Task 2: Add `INV-ralph-halt-path-resolution` to the manifest (close existing drift)** (AC: 5; partial AC 1)
  - [ ] The current `INVARIANTS.md` at line 48 registers `INV-ralph-halt-path-resolution` as the 10th invariant (added by the halt-path-resolution fix commit `5cfa055`, merged via PR #225), but Story 1.8's `invariants.manifest.ts` only includes 9 entries. This is a live `removed-from-docs-only` drift that Story 1.9's gate would report on first run. Close it by appending a 10th entry to `invariants.manifest.ts`'s `raw` array:
    ```typescript
    {
      id: 'INV-ralph-halt-path-resolution',
      description:
        'ralph.py resolves .ralph/{halt,@plan.md,PROMPT_*.md,logs/} against the worktree path when --worktree X is set (else cwd-relative .ralph/); absolute path exported as RALPH_BASE_DIR. Normative spec in docs/invariants/ralph-execute.md § Path Resolution (FR14k + NFR33a).',
      sourcePath: 'docs/invariants/ralph-execute.md',
      contentHash:
        '8c679cdabcccb8ac122b8da82d4bcb8198451f0cc0a19b3d13b4b2695b6cba8b',
      anchors: ['INV-ralph-halt-path-resolution'],
    },
    ```
  - [ ] sourcePath = `docs/invariants/ralph-execute.md` (the normative spec per INVARIANTS.md:48) rather than `ralph.py` (the runtime). Rationale: the normative spec is the contract; the runtime implements it; drift-detection on the spec catches intent changes. If a future iteration decides runtime drift-detection is also wanted, a second entry `INV-ralph-halt-path-resolution-runtime` pointing at `ralph.py` can be added (follow-up, not Story 1.9 scope).
  - [ ] contentHash = `8c679cdabcccb8ac122b8da82d4bcb8198451f0cc0a19b3d13b4b2695b6cba8b` (sha256 of `docs/invariants/ralph-execute.md` captured at spec-authoring time 2026-04-20; Dev: re-verify with `sha256sum docs/invariants/ralph-execute.md` and bake whatever the current value is — if it differs, the spec has drifted; update the spec's hash literal).

- [ ] **Task 3: Absorb Story 1.8 CR defers — Zod schema hardening + `readonly` / `Object.freeze`** (AC: 1, 2, 3, 4, 5; tightens the contract)
  - [ ] Tighten `InvariantSchema` in `invariants.manifest.ts` (defer #2 — sourcePath traversal guard). Change `sourcePath: z.string().min(1)` to `sourcePath: z.string().min(1).refine(p => !p.startsWith('/') && !p.startsWith('\\') && !p.includes('..') && !p.includes('\\'), { message: 'sourcePath must be a repo-relative forward-slash path without traversal' })`. The current 10 entries all satisfy this — the refine is future-proofing.
  - [ ] Tighten `InvariantsSchema` with uniqueness refine (defer #3). Change `z.array(InvariantSchema)` to `z.array(InvariantSchema).superRefine((arr, ctx) => { const ids = new Set(); for (const { id } of arr) { if (ids.has(id)) { ctx.addIssue({ code: 'custom', message: \`duplicate invariant id: ${id}\` }); } ids.add(id); } })`. Guards against accidental copy-paste duplication of an ID.
  - [ ] Cross-entry `contentHash` consistency per shared `sourcePath` (defer #4). Add a second `superRefine` pass: group entries by `sourcePath`; for each group with >1 entry, assert all `contentHash` values are identical (else `ctx.addIssue`). Current shared-source pairs satisfy this; the refine is future-proofing.
  - [ ] `readonly` + `Object.freeze` on the `invariants` export (defer #5). Change `export const invariants: Invariant[] = InvariantsSchema.parse(raw);` to `export const invariants: readonly Invariant[] = Object.freeze(InvariantsSchema.parse(raw));`. Prevents misbehaving consumers from mutating the shared module-level singleton. Downstream type consumers (Story 1.9's sync-gate + future FR43 consumers) will see `readonly Invariant[]` — iteration works, mutation is a TS error.
  - [ ] Schema-evolution metadata (`schemaVersion` / `deprecated` / `since` — defer #6) is **NOT** absorbed by Story 1.9. Rationale: the current substrate has 0 deprecated invariants; adding the fields now is speculative. The deferred-work.md entry stays in place for a future substrate-hardening story (tentatively 1.16 scope or adjacent, when a concrete deprecation need arises).

- [ ] **Task 4: Wire the CLI entry + `pnpm keel-invariants:check`** (AC: 1, 6, 7)
  - [ ] Create `packages/keel-invariants/src/check.ts` as the CLI entry point. Imports `runSyncGate` from `./sync-gate.js`, resolves `repoRoot` via `path.resolve(import.meta.dirname, '../../..')` (walks out of `dist/` back to the repo root at runtime; for local non-built invocations, the path works identically). Calls `runSyncGate(repoRoot)`. Prints a structured JSON drift report on `stderr` when drifts are found. Exits with `0` on `status === 'clean'`, `1` on `status === 'drift'`.
  - [ ] Add `"bin": { "keel-invariants-check": "./dist/check.js" }` to `packages/keel-invariants/package.json`. Also add a top-level script: `"check": "node dist/check.js"` to `packages/keel-invariants/package.json`'s `scripts` block. The `dist/check.js` path requires the file to be emitted by `tsc -b` — no separate bundler; the existing `keel-invariants#build` turbo task already covers it.
  - [ ] Add `"keel-invariants:check": "pnpm --filter @keel/keel-invariants check"` to the repo-root `package.json` `scripts` block. This is the entry point Story 1.9 AC 1 references (`pnpm keel-invariants:check`).
  - [ ] Re-export `runSyncGate` + `DriftReport` + `Drift` from `packages/keel-invariants/src/index.ts` alongside the existing `invariants` / `Invariant` / `InvariantSchema` / `InvariantsSchema` re-exports. Consumers that want programmatic access to the gate (not just CLI) can import via `@keel/keel-invariants`.

- [ ] **Task 5: Quality gates + runtime smoke + sprint-status bump** (no AC — substrate verification)
  - [ ] `pnpm install` at repo root. Lockfile is already up-to-date (no new deps needed — `node:fs/promises` + `node:crypto` are stdlib; Story 1.8 already added `zod`).
  - [ ] `pnpm -w typecheck` — expect 16/16 green. New `.ts` files in `packages/keel-invariants/src/` are covered by the package's existing `tsconfig.json`.
  - [ ] `pnpm -w lint` — expect 16/16 green. ESLint flat-config covers `packages/keel-invariants/src/**` per Story 1.2 baseline; no new `ignores` needed.
  - [ ] `pnpm -w build` — expect 16/16 green. `tsc -b` emits `dist/{manifest-reader,sync-gate,check}.{js,d.ts}` alongside the existing `dist/{index,invariants.manifest}.{js,d.ts}`.
  - [ ] `pnpm format:check` — expect 0 problems. If prettier rewrites any new file, re-run `pnpm exec prettier --write` and commit.
  - [ ] `pnpm exec commitlint --from origin/main --to HEAD --verbose` — expect 0 problems on the branch commits.
  - [ ] `pnpm exec prek run --all-files` — expect all 3 hooks `Passed`.
  - [ ] **Runtime smoke test (clean path):** `pnpm keel-invariants:check` on the current repo (with Task 2's 10th entry landed). Expect exit code 0, no stderr output. This is AC 1 end-to-end — contract side (Story 1.8) + enforcement side (Story 1.9) compose.
  - [ ] **Runtime smoke test (drift path):** temporarily modify `packages/keel-invariants/tsconfig.base.json` by one character, re-run `pnpm keel-invariants:check`. Expect exit code 1 + a JSON drift report on stderr naming `INV-tsconfig-base` as `content-hash-mismatch`. Revert the change. This is AC 4 end-to-end.
  - [ ] **Runtime smoke test (performance):** `time pnpm keel-invariants:check` on the clean repo. Expect wall-clock under 2 seconds (AC 7). Baseline substrate has 7 distinct source files to hash; budget is generous.
  - [ ] Bump `_bmad-output/implementation-artifacts/sprint-status.yaml`: `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector: ready-for-dev → done`. `last_updated: 2026-04-20 Story-1-9-done UTC`.
  - [ ] Flip this story file's Status to `done`, mark all Task subtasks `[x]`, populate `## Dev Agent Record` with File List + Completion Notes.

## Dev Notes

- Relevant architecture patterns and constraints:
  - [Source: architecture.md:942] `packages/keel-invariants/src/invariants.manifest.ts` lives under the package's `src/` tree. Story 1.9 adds sibling files: `manifest-reader.ts`, `sync-gate.ts`, `check.ts`. All ESM TypeScript, consistent with `invariants.manifest.ts`'s module style.
  - [Source: prd.md FR43] "System can enforce sync between the machine-enforced layer (`packages/keel-invariants/`) and the agent-readable layer (`INVARIANTS.md`) via a pre-merge gate that reads an exported `invariants.manifest.ts` (stable-ID + content-hash per rule) and fails the build on addition drift (manifest ID missing an `INVARIANTS.md` anchor), removal drift (orphaned `INVARIANTS.md` anchor), or edit drift (manifest hash change without matching `INVARIANTS.md` edit in the same PR)." Story 1.9 is the **enforcement side** of FR43; Story 1.8 shipped the **contract side**.
  - [Source: epics.md:888–924] Story 1.9 ACs specify 7 scenarios: clean exit, 4 drift classes (addition / removal-source / content-hash / removal-docs), CI exit-code contract, <2s performance.
  - [Source: `INVARIANTS.md:48`] `INV-ralph-halt-path-resolution` is the 10th invariant in `INVARIANTS.md` but is NOT in Story 1.8's manifest. Story 1.9 Task 2 closes this drift by adding the entry to the manifest.
  - [Source: `_bmad-output/implementation-artifacts/deferred-work.md` § Deferred from: code review of story-1.8] Six Story 1.8 CR defers. Story 1.9 absorbs four (sourcePath traversal guard, id uniqueness refine, cross-entry hash consistency, readonly/freeze) as Task 3 schema hardening. Two remain deferred (contentHash drift validation — that IS Task 1's sync-gate scope, so functionally absorbed at the tool level even without a schema change; schema-evolution metadata — left in `deferred-work.md` for a future substrate-hardening story).
- Source tree components to touch:
  - **NEW:** `packages/keel-invariants/src/manifest-reader.ts` (file-read + sha256 helpers + manifest re-export).
  - **NEW:** `packages/keel-invariants/src/sync-gate.ts` (anchor walker + drift detector + `runSyncGate` export).
  - **NEW:** `packages/keel-invariants/src/check.ts` (CLI entry point).
  - **EDIT:** `packages/keel-invariants/src/invariants.manifest.ts` (append 10th entry; tighten `InvariantSchema` + `InvariantsSchema` per Task 3; add `readonly` + `Object.freeze`).
  - **EDIT:** `packages/keel-invariants/src/index.ts` (re-export `runSyncGate` + `DriftReport` + `Drift`).
  - **EDIT:** `packages/keel-invariants/package.json` (`bin` field + `check` script).
  - **EDIT:** `{repo-root}/package.json` (`keel-invariants:check` script alias).
  - **EDIT:** `_bmad-output/implementation-artifacts/sprint-status.yaml` (status bump + last_updated).
- Testing standards summary:
  - **§ Testing Standards:** No dedicated unit-test file for `sync-gate.ts` in Story 1.9 scope. Rationale: (a) no test runner is wired at substrate level yet (Story 1.16 scope); (b) Task 5's two runtime smoke tests (clean path + drift path + performance path) exercise the tool end-to-end — AC 1 / AC 4 / AC 7 fully covered at the shell-invocation level; (c) the manifest's Zod parse + the gate's anchor-regex + the hash comparison are all small pure functions that a future test-runner story (Story 1.16) can add coverage for without structural changes. Story 1.9's CR pass (iter-N) will exercise the adversarial path — Blind Hunter / Edge Case Hunter / Acceptance Auditor should surface any remaining drift-detection gaps before Task 5 closes.
  - Quality-gate bundle from Stories 1.4–1.8 applies: typecheck + lint + format:check + commitlint + prek-runner parity. All MUST pass at Task 5.

### Project Structure Notes

- **Alignment with unified project structure:** `packages/keel-invariants/src/{manifest-reader,sync-gate,check}.ts` match architecture.md:942's generated-manifest vicinity. No variance.
- **§ Scope Carve-Out — Story 1.9 is enforcement-side (runtime tooling); contract side is Story 1.8.** Story 1.9 ships: (a) `sync-gate.ts` with `runSyncGate()` export and structured `DriftReport` type; (b) `manifest-reader.ts` with file-read + sha256 helpers; (c) `check.ts` CLI with 0/1 exit codes per AC 6 + structured JSON stderr report; (d) 10th manifest entry (`INV-ralph-halt-path-resolution`) closing the pre-existing docs-only drift; (e) Zod schema hardening (4 Story 1.8 CR defers); (f) `pnpm keel-invariants:check` script wired through repo-root `package.json`. Story 1.9 does NOT ship: (a) the GitHub Actions workflow wiring — that is Epic 13 scope (F/E pipeline story); (b) source-tree auto-discovery of unregistered rules — AC 2's "added-to-source-only" branch is realised anchor-side only (see AC 2 carve-out); (c) schema-evolution metadata (`schemaVersion` / `deprecated` / `since`) — stays deferred per `deferred-work.md`.
- **§ Anchor parser semantics.** The `INVARIANTS.md` anchor format is the bullet-bold-code pattern `- **\`INV-<category>-<slug>\`**` (see `INVARIANTS.md:24-48` for all 10 current anchors). Story 1.9's walker uses regex `/^-\s+\*\*\`([A-Z][A-Z0-9-]+)\`\*\*/gm` to enumerate anchors. Non-anchor content in `INVARIANTS.md` (narrative prose, section headings, extension notes) is ignored. Multiple anchors referencing the same slug (e.g., the hypothetical case of one entry splitting into two with the same stable ID) would produce duplicate Set entries — harmless; the uniqueness refine on `InvariantsSchema` (Task 3) catches manifest-side duplicates; anchor-side duplicates are flagged as drift only if a matching manifest row is missing. If future `INVARIANTS.md` formats introduce a new anchor style (e.g., a markdown table row), the regex needs updating — that would be a spec change, not a silent drift.
- **§ `removed-from-docs-only` vs `added-to-source-only` symmetry.** Per AC 2's carve-out, Story 1.9 realises both AC 2 (addition drift) and AC 5 (removal drift) via the **anchor-side** branch: (a) manifest-ID with no anchor → `added-to-source-only` (symmetric to "new rule in source-tree without manifest row" but realised via the anchor-absence signal); (b) anchor with no manifest-ID → `removed-from-docs-only`. Source-tree introspection for "new JS file in `src/eslint-rules/` without manifest row" is NOT implemented at 1.9 — adding that would require rule-kind discovery heuristics (what counts as an "invariant rule file" vs a helper module?) that exceed FR43's 1.0 remit. The substrate's 10 invariants are intentionally registered; a new rule author writing a new `src/eslint-rules/foo.cjs` MUST add an `INV-*` anchor to `INVARIANTS.md` + a manifest entry in the same PR — that's the contract. The sync-gate catches the manifest-vs-anchor asymmetry; source-tree auto-discovery is an optional follow-up.
- **§ `INV-ralph-halt-path-resolution` sourcePath choice (`docs/invariants/ralph-execute.md` not `ralph.py`).** INVARIANTS.md:48 explicitly cites `docs/invariants/ralph-execute.md` as the normative spec + `ralph.py` as the runtime implementation. The contract is the spec; the runtime implements it. Hashing the spec catches intent changes (the normative behaviour is modified); hashing the runtime catches implementation edits (the implementation evolves within the spec's envelope). For FR43's 1.0 posture — "agent-readable vs machine-enforced sync" — the spec is the authoritative reference. A follow-up entry `INV-ralph-halt-path-resolution-runtime` pointing at `ralph.py` is a natural extension if runtime drift-detection is wanted; it's out-of-scope at 1.9.
- **§ Performance posture.** AC 7 budget is 2 seconds. Baseline substrate: 7 distinct source files (the 10 invariants dedupe to 7 after shared-source collapse). File-read IO is the hot path; `Promise.all()` parallelises. sha256 on files of this size (largest is ~8KB) is <1ms per file. Total expected wall-clock: <100ms cold (disk IO dominates), <20ms warm (OS page cache). The 2s budget leaves 20x headroom for growth to ~200 invariants before performance pressure surfaces.
- **§ Provisional-ID header discharge.** `INVARIANTS.md`'s `<!-- Provisional: canonical IDs pinned by Story 1.8 manifest; drift-detection lands in Story 1.9. -->` header (Story 1.7 scope carve-out) is fully DISCHARGED by Story 1.9: both halves (canonical IDs pinned by 1.8; drift-detection by 1.9) are now landed. Task 5 should remove the provisional header as part of the `INVARIANTS.md` edit when the 10th entry-via-Task-2 is visible in the manifest. (Actually — Task 2 edits `invariants.manifest.ts`, not `INVARIANTS.md`; `INVARIANTS.md` stays as-is since the 10th anchor is already there since commit `5cfa055`. The provisional header removal is a cosmetic docs edit; wire it into Task 5 alongside sprint-status bump.)

## Change Log

| Date       | Version | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Author |
| ---------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 2026-04-20 | 1.0     | Initial story authoring (Ralph; spec via `/bmad-create-story` inline-realisation per Stories 1.6/1.7/1.8 precedent — skill HITL-halts at step checkpoints). Spec absorbs 4 of 6 Story 1.8 CR defers (sourcePath traversal guard + id uniqueness refine + cross-entry hash consistency + readonly/freeze) into Task 3 schema hardening. Closes pre-existing `INV-ralph-halt-path-resolution` docs-only drift (10th entry into manifest). CLI entry wired via `pnpm keel-invariants:check`. Scope carve-outs: AC 2 anchor-side-only; AC 6 CI workflow → Epic 13; schema-evolution metadata stays deferred. | Ralph |
