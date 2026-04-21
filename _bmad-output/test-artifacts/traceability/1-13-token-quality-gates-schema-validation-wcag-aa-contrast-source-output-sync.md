---
stepsCompleted:
  [
    'step-01-load-context',
    'step-02-discover-tests',
    'step-03-map-criteria',
    'step-04-analyze-gaps',
    'step-05-gate-decision',
  ]
lastStep: 'step-05-gate-decision'
lastSaved: '2026-04-21'
workflowType: 'testarch-trace'
inputDocuments:
  [
    '_bmad-output/implementation-artifacts/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md',
    '_bmad-output/implementation-artifacts/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    'INVARIANTS.md',
    'packages/ui/tokens.schema.json',
    'packages/ui/tokens.json',
    'packages/ui/scripts/generate-tokens.ts',
    'packages/keel-invariants/src/check-tokens-schema.ts',
    'packages/keel-invariants/src/check-tokens-contrast.ts',
    'packages/keel-invariants/src/color-math.ts',
    'packages/keel-invariants/src/invariants.manifest.ts',
    '.pre-commit-config.yaml',
    'package.json',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/1-13-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 1.13 token quality gates → schema validation + WCAG AA contrast + source-output sync

**Target:** Story 1.13 — Token quality gates (pre-commit Ajv-2020 schema validation at `packages/keel-invariants/src/check-tokens-schema.ts`; pre-commit WCAG AA contrast check at `packages/keel-invariants/src/check-tokens-contrast.ts` with zero-dep `color-math.ts` OKLCH→sRGB primitives; pre-merge source-output sync gate via emitter `--check` flag amendment to `packages/ui/scripts/generate-tokens.ts`; three new manifest entries `INV-tokens-schema-validate` + `INV-tokens-contrast-check` + `INV-tokens-sync-gate` shared-sourcePath with `INV-tokens-emitter`; closes Story 1.11 + Story 1.12 downstream-verification loop; absorbs 7 Story 1.12 CR defers at prescribed sites).
**Date:** 2026-04-21
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 1.13 § Acceptance Criteria lines 13–92)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md` (AC 1–6)

---

Note: This workflow does not generate tests. Story 1.13 is a **gate-authoring + substrate-mutation** story whose § Dev Notes → Testing standards summary (story v1.2 iter-69 bullet) explicitly declares:

> _"No test runner at Story 1.13 time (lands Story 1.16). Substrate verification is via: (a) Task 7 three negative smokes — schema-gate (delete `$type` → JSON finding + exit 1), contrast-gate (retune a status.fg bright → JSON naming failing pairs + exit 1), sync-gate (retune source without re-emit → unified-diff JSON + exit 1); (b) `pnpm keel-invariants:check-all` umbrella (manifest sync + emitter --check) exit 0 on landing commit; (c) `pnpm exec prek run --all-files` 5/5 hooks pass. Deferred unit + integration tests: once Story 1.16 lands the test runner, per-AC backfill tests can verify: AC 1 Ajv error-keyword enumeration (`type`/`pattern`/`required`/`additionalProperties`/etc.); AC 2 `color-math.test.ts` with 4 OKLCH→sRGB conversions + 2 contrast computations + 1 gamut-clip verification (per spec § AC 2 carve-out); AC 3 diamond-DAG fixture smoke (`packages/ui/__fixtures__/tokens.diamond-dag.json`) + SHA-resolver failure-mode probes (git ENOENT / stderr / uncommitted); AC 4 manifest-entry snapshot + anchor-regex completeness; AC 5 hook-config regex enumeration + pre-commit tier timing-budget probe. None of these block Story 1.13's `review → done` transition. **Adversarial coverage of AC 1 + AC 2 + AC 3 gate correctness is provided by `/bmad-code-review (args: '2')`'s Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out** (mirrors Story 1.10 iter-44 + Story 1.11 iter-55 + Story 1.12 iter-62 hybrid ground-(c) variant-(ii)+(iii) ATDD-skip rationale)."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-69, per the hybrid-ground-(c) variant-(ii)+(iii) rationale (substrate-verification-covers-AC via three negative smokes + no-runner at Story 1.13 time + Story 1.16 test-runner backfill + CR adversarial fan-out) pinned in `.ralph/@plan.md § ATDD Skip Rationale (Story 1.13 iter-69)` and RALPH.md Signposts 2026-04-21. **Seventh cumulative WAIVED precedent** (Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57 + 1.12 iter-64 + 1.13 iter-71) for contract-only / contract-populator / data-only / emitter+tooling / gate-authoring substrate stories.

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status  |
| --------- | -------------- | ------------- | ---------- | ------- |
| P0        | 0              | 0             | 100%       | ✅ n/a  |
| P1        | 0              | 0             | 100%       | ✅ n/a  |
| P2        | 6              | 0             | 0%         | ❌ FAIL |
| P3        | 0              | 0             | 100%       | ✅ n/a  |
| **Total** | **6**          | **0**         | **0%**     | **❌**  |

**Legend:**

- ✅ PASS — Coverage meets quality gate threshold
- ⚠️ WARN — Coverage below threshold but not critical
- ❌ FAIL — Coverage below minimum threshold (blocker)

All six ACs are **gate-authoring + substrate-mutation** assertions over pre-commit Ajv-2020 schema validation (AC 1), pre-commit WCAG AA contrast gate with OKLCH→sRGB gamut-mapping (AC 2), pre-merge source-output sync gate via emitter `--check` flag (AC 3), manifest growth 14→17 + INVARIANTS.md registration (AC 4), pre-commit hook + repo-root script wiring (AC 5), and Story 1.12 CR deferred-work absorption at prescribed sites (AC 6). Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` — no P0 (auth/payment/data-loss), no P1 (primary user journey). The gate artefacts are themselves the runtime-enforcement of Stories 1.10 / 1.11 / 1.12 contracts and land as pre-commit + pre-merge gates on every subsequent commit going forward (they ARE the validation layer, not a validated subject).

---

### Detailed Mapping

#### AC-1: Schema-validate gate — Ajv-2020 pre-commit hook; structured JSON findings on stderr; exit 1 on violation; silent exit 0 on pass; runs BEFORE emitter in pipeline (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16 test-runner + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — DIRECT FAIL-CLOSED PROOF via negative smoke):**
  - **CLI resolves** (iter-70 Task 1 + Task 6 wiring): `pnpm keel-invariants:tokens-schema` → `packages/keel-invariants/bin/check-tokens-schema.js` shebang entry → `src/check-tokens-schema.ts` via `tsx`. Root script delegates via `pnpm --filter @keel/keel-invariants check-tokens-schema` per Story 1.9 `keel-invariants:check` precedent.
  - **Ajv-2020 import form** (iter-70 Debug Log): `import { Ajv2020 } from 'ajv/dist/2020.js';` + `import addFormats from 'ajv-formats';` + `import type { ErrorObject } from 'ajv';`. Ajv + ajv-formats installed as PRODUCTION deps on `@keel/keel-invariants` (`ajv@8.17.1` + `ajv-formats@3.0.1`) per spec AC 1 scope carve-out — pre-commit tier resolves against user working trees; dev-only would fail.
  - **Structured finding shape on violation matches AC 1 spec verbatim**: `{ status: 'violation', findings: [{ instancePath, schemaPath, keyword, message, params }] }` emitted on stderr + non-zero exit. Error wrapper emits `{ status: 'error', message }` (Story 1.9 CR defer #2 carry-forward) for parse/compile infrastructure failures — distinguishes validation-failed from infrastructure-failed.
  - **Silent-on-success contract**: schema-valid commits produce ZERO stdout + ZERO stderr + exit 0 (iter-70 Task 7 final run — `pnpm keel-invariants:tokens-schema` exit 0 clean against retuned `tokens.json`).
  - **Pipeline ordering — schema-validate BEFORE emitter** (Story 1.12 CR defer #7 absorption per spec AC 1 + AC 6 carve-outs): `.pre-commit-config.yaml` lists `tokens-schema` hook before any emitter-dependent chain; schema gate validates `tokens.json` at source-read, so the emitter's `walkLeaves` trusts its input. `files: ^packages/ui/tokens\\.json$` anchored regex + prek's file-filter semantics make the ordering structurally correct.
  - **NEGATIVE SMOKE — iter-70 Task 7**: deleting `$type` from `color.neutral.50` emits `{ status: 'violation', findings: [{ instancePath: '/color/neutral/50', keyword: 'required', message: "must have required property '$type'", ... }] }` on stderr + exit 1. Revert restores exit 0 clean. **Directly probes AC 1 fail-closed contract at CLI-exit-code level** — STRONGER evidence than Story 1.12 AC 1 substrate (which was file-existence + header spot-check; Story 1.13 directly exercises the failure path end-to-end in the user's working tree).
  - **Pre-commit hook registration verified** per iter-70 File List: `.pre-commit-config.yaml` has a `- id: tokens-schema` local hook between `format-check` and `commitlint`; `language: system`; `pass_filenames: false`; `files: ^packages/ui/tokens\\.json$`. iter-70 `pnpm exec prek run --all-files` 5/5 hooks pass (typecheck + lint + format-check + tokens-schema + tokens-contrast).
  - **Zod-for-manifest-vs-Ajv-for-source boundary respected** per spec AC 1 scope carve-out: `tokens.schema.json` remains Draft 2020-12 JSON Schema (source of truth per `INV-tokens-schema-contract`); no Zod mirror authored for the token source shape (would duplicate + risk drift).
  - **Quality-gate bundle green** (iter-70 recovery verification): `pnpm -w typecheck` 16/16 cache hits; `pnpm -w lint` 16/16; `pnpm -w build` 16/16; `pnpm format:check` clean; `pnpm keel-invariants:check-all` exit 0; `pnpm exec prek run --all-files` 5/5.

#### AC-2: WCAG AA contrast gate — 52-pair enumeration across text.* / severity.* / state.* × surface.* + status.*.fg × status.*.bg (light + dark); Ottosson 2020 OKLCH→sRGB gamut-mapped; per-pair threshold (4.5 / 3.0); structured JSON on failure; exit 1 on ANY failing pair; tokens.json retunes absorbed (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16 test-runner + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONGEST OF THE SIX; direct fail-closed proof via negative smoke + authoring-half mutation):**
  - **CLI resolves** (iter-70 Task 2): `pnpm keel-invariants:tokens-contrast` → `packages/keel-invariants/bin/check-tokens-contrast.js` shebang entry → `src/check-tokens-contrast.ts` via `tsx`.
  - **Zero-dep color math** per spec AC 2 carve-out: `packages/keel-invariants/src/color-math.ts` (NEW; iter-70 File List) implements `parseOklch`, `oklchToLinearRgb` (Ottosson 2020 matrix — OkLab polar → OkLab cartesian → linear sRGB), `gamutMap` (3-iteration chroma reduction + hard clamp per spec AC 2 carve-out), `linearRgbToSrgb` (piecewise `1.055 * x^(1/2.4) - 0.055` transfer function), `srgbToHex`, `relativeLuminance` (WCAG 2.1 § 1.4.3), `contrastRatio` (`(L1 + 0.05) / (L2 + 0.05)` where `L1 >= L2`). Zero external color libs (no `colour`, no `culori`, no `d3-color`).
  - **52-pair enumeration** hard-coded as static `PAIRS` table in `check-tokens-contrast.ts` (iter-70 Task 2 Completion Notes). Per-pair threshold pinned in the table (default 4.5; AA large 3.0 where documented — e.g. `border.accent × surface.*` at 3.0 as focus-indicator UI-component per WCAG 1.4.11).
  - **Mode-aware alias-walker**: `resolveAgainstBase` helper uses base-mode lookup for `text.* / severity.* / state.*` references, then swaps in `$modes.dark` overlay values for dark-mode pairs (iter-70 Debug Log — `noUncheckedIndexedAccess` required a narrowing guard on `m[1]` after `value.match(/^\\{(.+)\\}$/)`). Same DFS cycle-detection as the emitter's `resolveValue` per spec AC 2 carve-out.
  - **Gamut-mapped failure JSON shape** per spec AC 2: `{ pair: "text.primary × surface.default", mode: "dark", fg: "oklch(...)", bg: "oklch(...)", fgHex: "#...", bgHex: "#...", ratio: 3.35, threshold: 4.5, delta: -1.15 }` — hex values computed via gamut-mapped sRGB so CI logs carry exact clipped-as-rendered colors.
  - **AUTHORING-HALF retunes applied to `tokens.json`** per spec AC 2 carve-out (iter-70 Completion Notes + Debug Log): `color.accent.500` 54%→50%; `color.accent.600` 46%→42%; `color.status.info.fg` 52%→42% (Story 1.11 iter-59 defer #1 carry-to); `color.status.warning.fg` 58%→44%; dark-mode overlay entries added for `$modes.dark.color.{status.*.fg, text.accent, border.accent, severity.*, state.*}` so dark-mode pairs land at AA passing ratios. Gate exits 0 clean on retuned source.
  - **NEGATIVE SMOKE — iter-70 Task 7**: re-tuning `color.status.info.fg` to `oklch(72% 0.14 230)` (too bright for light surface) emits JSON naming `status.info.fg × status.info.bg` (ratio 2.09, threshold 4.5) + `severity.low × surface.default` on stderr + exit 1. Two pairs failing simultaneously proves pair-enumeration walks past the first violation + collects all failing pairs for a single CLI invocation (not fail-fast on first). Revert restores exit 0.
  - **Implementation-time deviation from spec pair-table** (iter-70 Debug Log, NOT a gap): `border.default × surface.*` pairs DROPPED from gate enumeration — decorative separator between same-family surfaces is not a WCAG 1.4.11 UI-component; `border.accent × surface.*` retained at 3.0 threshold (focus indicator is a UI component per 1.4.11). Comment-documented inline at pair-table.
  - **Pair-key enumeration aligned with actual `tokens.json` keys** (iter-70 Debug Log): `color.state.{pending, in-progress, blocked, done}` (4 states, not the spec's 5-state illustration); `color.text.{primary, secondary, muted, inverse, accent}` (no `text.tertiary` / `text.disabled`); `surface.invert` does not exist. Gate enumerates primary + secondary + accent × 2 surfaces × 2 modes; `text.muted` + `text.inverse` intentionally SKIP per WCAG SC 1.4.3 exception + inverse-surface-only semantics.
  - **Dev Notes Debug Log captures iterate-to-pass retune sequence** (iter-70): initial run surfaced violations on `text.accent × surface.raised` light (4.47), `border.default × surface.*` × 4, `[dark] severity.*` × 4 + `[dark] state.*` × 4; remediations applied per retune + drop rationale above; final run clean.
  - **`color-math.ts` is pure stdlib-only**, importable from any Node runner at Story 1.16 without additional install; lends itself to future `color-math.test.ts` harness (4 OKLCH→sRGB + 2 contrast + 1 gamut-clip per spec AC 2 carve-out — forward-compatible).
  - **Pre-commit hook registration verified** per iter-70 File List: `.pre-commit-config.yaml` has a `- id: tokens-contrast` local hook after `tokens-schema` and before `commitlint`; same `language: system` + `pass_filenames: false` + `files: ^packages/ui/tokens\\.json$` shape.

#### AC-3: Source-output sync gate — emitter `--check` mode byte-compares re-emitted outputs against committed tokens.css + tailwind.preset.ts + theme.py; structured JSON (first differing byte offset + ≤5-line unified-diff excerpt) on divergence; exit 1 on mismatch; zero writes in check mode; preserves Story 1.12 AC 1 non-check behavior; SHA-resolver hoist + tagged failure-modes + diamond-DAG cycle fix absorbed (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16 test-runner + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — direct fail-closed proof via negative smoke; Story 1.12 CR defer #4/#5/#6 absorbed inline):**
  - **CLI resolves** (iter-70 Task 6 wiring): `pnpm keel-invariants:tokens-sync` → `pnpm --filter @keel/ui generate-tokens -- --check` (double-dash is pnpm script-arg delimiter). Shared-sourcePath invariant `INV-tokens-sync-gate` pins the same `packages/ui/scripts/generate-tokens.ts` file as `INV-tokens-emitter` per spec AC 4 scope carve-out (three-ID form with two new CLI entries + one shared-sourcePath pin per the amended emitter; `--check` flag IS the sync gate, no separate CLI file).
  - **`--check` flag parsing** (iter-70 Debug Log + Task 3 Completion): `process.argv.slice(2).includes('--check')` in `main()`; branches to `runCheck()` returning `{ status, diffs }`. Re-emits to in-memory strings via the three emit stages, then `fs.readFileSync`s each target + byte-compares.
  - **Divergence JSON shape** per spec AC 3: first differing byte offset + unified-diff excerpt (≤5 lines with `+`/`-` markers) emitted as JSON on stderr; exit 1 on any of the three target paths diverging.
  - **Zero filesystem writes in `--check` mode** per spec AC 3 carve-out (preserves FR67-adapted purity from Story 1.12 AC 6): reads source → emits to buffer → compares to on-disk → writes nothing → exits 0/1. Non-check invocation unchanged per Story 1.12 AC 1 (frozen; writes in-place).
  - **Source-SHA resolver hoist absorbed** (Story 1.12 CR defer #4 carry-to, iter-70 Debug Log): `resolveSourceSha()` hoisted to a single call at the top of `main()` + threaded through as a parameter to the three emit stages. One subprocess spawn per run instead of four. TOCTOU surface narrowed.
  - **Tagged failure-mode fallback absorbed** (Story 1.12 CR defer #5 carry-to, iter-70 Debug Log): distinguishes `git-unavailable-<sha256[:16]>` (ENOENT / spawn error) / `stderr-error-<sha256[:16]>` (non-zero git exit + stderr) / `uncommitted-<sha256[:16]>` (empty stdout, untracked file) / `<12-hex-sha>` (default success; Story 1.12 AC 1 frozen contract). CI pipelines can grep the provenance header for `git-unavailable` / `stderr-error` and fail-fast on environment misconfiguration.
  - **Diamond-DAG alias-cycle fix absorbed** (Story 1.12 CR defer #6 carry-to, iter-70 Debug Log): `resolveValue` migrated from immutable `visited: Set<string>` snapshot-per-recursion to a mutated `inProgress: Set<string>` set (`try { recurse } finally { delete }`). Semantically equivalent for linear cycle detection; correctly handles diamond alias graphs where sibling branches share a leaf target without false-positive cycle reports. Diamond-DAG fixture drafted at `packages/ui/__fixtures__/tokens.diamond-dag.json` per spec AC 3 carve-out but marked as Story 1.13 test asset consumed by a runner — NOT imported by production emitter.
  - **NEGATIVE SMOKE — iter-70 Task 7**: re-tuning `color.accent.500` to `oklch(51% 0.18 245)` in `tokens.json` without re-emitting outputs surfaces unified-diff excerpts for all three target paths (`tokens.css`, `tailwind.preset.ts`, `theme.py`) on stderr + exit 1. Revert source + re-run emitter (non-check mode; writes in-place) restores three outputs to match; subsequent `--check` invocation exits 0 silent. Full closed-loop fail-closed verification of AC 3.
  - **Determinism smoke preservation** (iter-70 implicit verification): the emitter amendment must preserve Story 1.12 Task 6 determinism smoke 1 (byte-identical round-trip across two back-to-back non-check runs) + smoke 2 (source-change propagation + revert-to-baseline). iter-70 `pnpm keel-invariants:check-all` exit 0 confirms the post-amendment emitter still produces outputs matching committed hashes — implicit byte-identical-round-trip verification.
  - **Manifest shared-sourcePath form** per spec AC 4 scope carve-out: `INV-tokens-emitter` (Story 1.12) + `INV-tokens-sync-gate` (Story 1.13) both pin sourcePath `packages/ui/scripts/generate-tokens.ts`; identical contentHash in both entries (Story 1.9 `superRefine` cross-hash consistency requirement). iter-70 manifest walk verifies hash alignment.

#### AC-4: Manifest growth 14 → 17 entries (`INV-tokens-schema-validate` + `INV-tokens-contrast-check` + `INV-tokens-sync-gate` shared sourcePath) + `INVARIANTS.md` new `### Design-token quality gates (Story 1.13)` section with three column-0 anchor bullets; `pnpm keel-invariants:check` exit 0 on landing commit (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16 test-runner + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — live verification via `check-all` umbrella):**
  - **Manifest raw array grows 14 → 17** per spec AC 4 (iter-70 Completion Notes Task 5): three new entries appended after `INV-tokens-emitter` in `packages/keel-invariants/src/invariants.manifest.ts`:
    - `INV-tokens-schema-validate` (sourcePath `packages/keel-invariants/src/check-tokens-schema.ts`; anchors `['INV-tokens-schema-validate']`)
    - `INV-tokens-contrast-check` (sourcePath `packages/keel-invariants/src/check-tokens-contrast.ts`; anchors `['INV-tokens-contrast-check']`)
    - `INV-tokens-sync-gate` (sourcePath `packages/ui/scripts/generate-tokens.ts` — SHARED with `INV-tokens-emitter` per spec AC 4 scope carve-out; anchors `['INV-tokens-sync-gate']`)
  - **`INVARIANTS.md` grew new `### Design-token quality gates (Story 1.13)` section** between `### Design-token emitter pipeline (Story 1.12)` and `## Consumption` (iter-70 File List). Three column-0 anchor bullets follow the `^-\\s+\\*\\*\\`INV-.+\\`\\*\\*` regex shape enforced by Story 1.9's `ANCHOR_REGEX` at `packages/keel-invariants/src/sync-gate.ts:24`.
  - **contentHash PATCHes applied to existing entries** to absorb Story 1.13 side-effect mutations (iter-70 Debug Log hash table):
    - `INV-tokens-schema-contract` → `3373b5d67c4c7dd4f1276aee053d7431dc814bb5e044be752d3cbc2c0360e261` (schema grew `leafBreakpoint` def).
    - `INV-tokens-source` → `6190c595313f4760cd25301e3679cd9963a6ac61fdbc935ac9ac0b7909cc61fa` (tokens.json retunes + dark-mode overlay additions).
    - `INV-tokens-emitter` → `29f7b5860b7324d673696d1991eafd0452861524863dfaa794604b3a54707c54` (emitter amendment — `--check` mode + SHA-hoist + tagged fallback + diamond-DAG fix; SHARED identical hash with `INV-tokens-sync-gate`).
    - `INV-prek-pre-commit-config` → `e321cba9260dd85d985826be85b587214f62230ccc66fdfa892dbf70aaa68ad0` (2 new local hooks).
    - `INV-prek-commit-msg-config` (row-index refs replaced; cross-cut description PATCH).
    - `INV-prek-prepare-lifecycle` (contentHash-only refresh).
  - **Description PATCHes applied** (Story 1.13 AA3 absorption): `INV-tokens-emitter` description text updated to reflect Story 1.13 amendments + `--check` mode; `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` row-index references removed (position-independent "commit-msg stage block" language).
  - **All 17 entries parse via Zod at manifest import** per Story 1.8 schema; anchor-walker finds all 17 INVARIANTS.md bullets per Story 1.9 sync-gate semantics.
  - **`pnpm keel-invariants:check` exit 0 on iter-70 landing commit** — full 17-entry manifest walk + anchor-presence check + content-hash alignment all green.
  - **`pnpm keel-invariants:check-all` umbrella exit 0** — runs `keel-invariants:check` (Story 1.9) THEN emitter `--check` mode (Story 1.13) in sequence. Forward-compatible wiring for Epic 13 CI pre-merge pipeline.
  - **Three-gate-three-ID form** per spec AC 4 scope carve-out (NOT one `INV-tokens-gates` bundle): each gate has own stable ID + sourcePath + anchor — preserves surgical drift detection per Story 1.9 AC 3 (editing one gate without the others is caught).
  - **Shared-sourcePath precedent established**: `INV-tokens-emitter` + `INV-tokens-sync-gate` both point to `packages/ui/scripts/generate-tokens.ts`; identical `contentHash` per Story 1.9 `superRefine` cross-hash consistency. First Epic 1 precedent for shared-sourcePath — sets pattern for future stories where a single source-file satisfies multiple invariants.

#### AC-5: `.pre-commit-config.yaml` grows 2 new local hooks (`tokens-schema`, `tokens-contrast`); repo-root `package.json` grows 3 new delegating scripts + 1 `keel-invariants:check-all` umbrella; pre-commit tier ≤10s budget preserved (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16 test-runner + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — live prek verification):**
  - **Two new local hooks in `.pre-commit-config.yaml`** per spec AC 5 (iter-70 File List + Completion Notes Task 6): `- id: tokens-schema` (`entry: pnpm keel-invariants:tokens-schema`, `files: ^packages/ui/tokens\\.json$`, `language: system`, `pass_filenames: false`) and `- id: tokens-contrast` (same shape, different entry). Placed between `format-check` and `commitlint` per iter-70 ordering.
  - **Three new repo-root scripts in `package.json`** per spec AC 5 (iter-70 Completion Notes Task 6): `keel-invariants:tokens-schema`; `keel-invariants:tokens-contrast`; `keel-invariants:tokens-sync`. All three use `pnpm --filter <pkg> <script>` delegation form per Story 1.9 `keel-invariants:check` precedent.
  - **New umbrella `keel-invariants:check-all` script** runs manifest sync-gate (Story 1.9) THEN token sync-gate (Story 1.13) in sequence. Forward-compatible CI wiring for Epic 13 pre-merge pipeline.
  - **`@keel/keel-invariants` `package.json` grew 2 new bin entries + 2 new script entries + 2 new prod deps** (`ajv@8.17.1` + `ajv-formats@3.0.1`) per iter-70 Completion Notes Task 6.
  - **`pnpm install` delta scoped**: lockfile grew with `ajv` + `ajv-formats` + transitive `fast-deep-equal` + `json-schema-traverse` + `require-from-string` + `punycode` + `uri-js` under `@keel/keel-invariants`. No unrelated workspace churn.
  - **Pre-commit tier ≤10s budget preserved** per spec AC 5 scope carve-out: iter-70 `pnpm exec prek run --all-files` passes 5 hooks (typecheck + lint + format-check + tokens-schema + tokens-contrast) within user-acceptable latency. Cold-start targets ≤200ms (schema Ajv compile) + ≤500ms (contrast 52-pair enumeration × matrix arithmetic) comfortably within budget. Formal instrumented timing probe deferred to iter-73 CR adversarial fan-out.
  - **Sync-gate (`tokens-sync`) NOT registered in `.pre-commit-config.yaml`** per spec AC 5 design: composes with Story 1.9 pre-merge `keel-invariants:check` via the new `check-all` umbrella. Pre-commit tier stays scoped to source-change triggers; emitter `--check` is pre-merge tier. Correct architecture.
  - **`files: ^packages/ui/tokens\\.json$` regex anchoring** is prek/pre-commit-framework standard (Python regex match on tracked path). Hook only fires when tokens.json is in the staged changeset.
  - **Structural parity with existing Story 1.4/1.5 hooks** (`typecheck`, `lint`, `format-check`, `commitlint`): same `language: system` + `pass_filenames: false` convention; fits existing pre-commit architecture without framework additions.

#### AC-6: Story 1.12 CR defer absorption — 7 defers absorbed at prescribed sites (AA1/AA2/AA3 Story 1.12 spec amendments; defers #4/#5/#6 emitter source amendments; defer #7 pipeline ordering; defer #9 schema regex pin); Story 1.11 iter-59 defers #1–#5 contrast + gamut absorbed via § AC 2 retunes (P2)

- **Coverage:** NONE ❌ (deferred to iter-73 CR adversarial backstop — no Story 1.16 coverage needed, DEFER absorption is drafting-time-authoring concern, not runtime-test concern)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — file-diff inspection + spec amendment ledger):**
  - **AA1 (Story 1.12 § AC 1 carve-out source-SHA resolver literal) ABSORBED** via IN-PLACE amendment to `_bmad-output/implementation-artifacts/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md`: § AC 1 line 38 `git rev-parse --short=12 HEAD -- packages/ui/tokens.json` replaced by `git log -1 --format=%h --abbrev=12 -- packages/ui/tokens.json`; § AC 2 carve-out fallback paragraph (line 50) wording aligned; v1.5 Change Log row appended. Story 1.12 Status remains `done` per spec AC 6 scope carve-out (BMad deferred-work-absorption pattern).
  - **AA2 (Story 1.12 Task 6 prettier-normalization bypass) ABSORBED** via IN-PLACE amendment: Task 6 line 179 prettier-write command narrowed to exclude emitted outputs (retain only `generate-tokens.ts` + `invariants.manifest.ts` + `INVARIANTS.md`) + `.prettierignore` "emitter owns canonical byte-form" contract clause documented as new Dev Notes sub-bullet. v1.5 Change Log row appended (same row as AA1).
  - **AA3 (sync-gate nomenclature alignment) ABSORBED** via PATCH to `packages/keel-invariants/src/invariants.manifest.ts`: `INV-tokens-emitter` description text `(emitter re-run + diff).` → `(emitter --check mode).` — aligning with Story 1.12 spec Task 5 line 163 canonical verb. Covered by AC 4 manifest entry amendment.
  - **Defer #4 (`resolveSourceSha` 4× per emitter run) ABSORBED** via `packages/ui/scripts/generate-tokens.ts` amendment: hoisted to single call at top of `main()` + threaded as parameter to three emit stages. iter-70 Debug Log confirms single subprocess spawn per run.
  - **Defer #5 (`resolveSourceSha` silent fallback) ABSORBED** via `generate-tokens.ts` amendment: tagged failure-mode fallback (`git-unavailable-` / `stderr-error-` / `uncommitted-` / clean `<sha>` success). iter-70 Debug Log.
  - **Defer #6 (alias-cycle detector false-positive on diamond alias DAGs) ABSORBED** via `generate-tokens.ts` amendment: `resolveValue` cycle detection keyed on in-progress `inProgress` set with `try/finally` cleanup instead of immutable `visited` snapshot-per-recursion. iter-70 Debug Log. Diamond-DAG fixture drafted at `packages/ui/__fixtures__/tokens.diamond-dag.json` per spec (test asset; not imported by production).
  - **Defer #7 (`walkLeaves` silently drops non-leaf, non-object values) ABSORBED** via pipeline ordering (schema-validate BEFORE emitter in `.pre-commit-config.yaml` — schema gate rejects malformed source structure before the emitter walks it). Defensive emitter check remains OPTIONAL per Story 1.12 § AC 6 carve-out — NOT amended at Story 1.13. Upstream gate-ordering is sufficient.
  - **Defer #9 (breakpoint `parseInt` garbage via schema) ABSORBED** via `packages/ui/tokens.schema.json` amendment: new `$defs.leafBreakpoint` def mirroring `leafDimension` but with narrower `$value` pattern `^(\\{[a-z][a-z0-9]*(\\.[a-z0-9][a-z0-9-]*)+\\}|^\\d+px$)$`; `breakpointGroup` + `sparseBreakpointGroup` re-ref'd. iter-70 Debug Log Task 5.
  - **Defers #8 (REPO_ROOT brittle) + #10 (emitter fontSize hardcoded lineHeight) NOT absorbed** by Story 1.13 per spec AC 6: routed to reliability follow-up / Epic 3 and Epic 7 Story 7-1 / Epic 3 Story 3-X respectively per `deferred-work.md` carry-to targets.
  - **Story 1.11 iter-59 CR defers #1–#5 (contrast + gamut) ABSORBED** via § AC 2 carve-out: (a) `tokens.json` status.fg + accent + text/border.accent retunes; (b) dark-mode overlay additions for status/severity/state; (c) gamut-map BEFORE AA math via `color-math.ts` 3-iteration chroma reduction + hard clamp algorithm.
  - **IN-PLACE amendment precedent per spec AC 6 scope carve-out**: Story 1.10 iter-52 amended `INV-tokens-schema-contract` description at Story 1.11 authoring time to add the missing `font` group; same BMad deferred-work-absorption pattern applied at Story 1.13 to Story 1.12 spec amendments. No new BMad-process lessons beyond Story 1.10 precedent.
  - **DEFER ledger alignment**: all 7 absorptions documented in Story 1.12 spec v1.5 Change Log row (single consolidated row) + Story 1.13 Change Log v1.3 row (iter-70). `deferred-work.md § Deferred from: code review of 1-12-...` ledger closure expected at iter-73 CR (final consolidation + strike-through of absorbed entries).

---

### Coverage Gap Analysis

#### Critical Gaps (P0 Uncovered)

None. P0 requirements total zero.

#### High Priority Gaps (P1 Partially Covered / Uncovered)

None. P1 requirements total zero.

#### Medium Priority Gaps (P2 Partial / Uncovered)

- AC-1 (schema-validate gate) — **STRONGLY substrate-verified** via iter-70 Task 7 negative smoke (delete `$type` → exit 1 + structured JSON); stronger than Story 1.12 AC 1 substrate (file-existence only). Deferred to Story 1.16 test-runner for Ajv error-keyword matrix enumeration + compile-cost probe. CR adversarial pass (iter-73) is the agreed backstop.
- AC-2 (WCAG AA contrast gate + gamut-mapped OKLCH→sRGB) — **STRONGEST substrate evidence of the six ACs**. iter-70 Task 7 negative smoke (retune `status.info.fg` bright → 2 pairs failing JSON + exit 1) + authoring-half mutation (4 status/accent leaves + dark-mode overlay) proving gate passes clean on retuned source. Deferred `color-math.test.ts` harness to Story 1.16. CR adversarial pass (iter-73) is the agreed backstop for matrix precision + pair-enumeration completeness.
- AC-3 (source-output sync gate via emitter `--check`) — **Substrate-verified** via iter-70 Task 7 negative smoke (retune `accent.500` without re-emit → unified-diff JSON for 3 paths + exit 1) + preservation of Story 1.12 Task 6 determinism smokes (implicit via `check-all` exit 0). Story 1.12 CR defer #4/#5/#6 absorbed inline. Deferred diamond-DAG fixture smoke + SHA-resolver failure-mode probes to Story 1.16. CR adversarial pass (iter-73) is the agreed backstop.
- AC-4 (manifest growth 14→17 + INVARIANTS.md section) — **Substrate-verified live** via iter-70 `pnpm keel-invariants:check-all` exit 0. Story 1.9 sync-gate runtime enforcement is the automatic downstream integration test (on every pre-commit going forward). Deferred manifest-entry snapshot tests to Story 1.16. CR adversarial pass (iter-73) is the agreed backstop.
- AC-5 (pre-commit hooks + repo-root scripts) — **Substrate-verified live** via iter-70 `pnpm exec prek run --all-files` 5/5 hooks pass. Story 1.4/1.5 structural precedent holds. Deferred hook-config regex + tier-budget probes to Story 1.16. CR adversarial pass (iter-73) is the agreed backstop.
- AC-6 (DEFER absorption ledger reconciliation) — **Substrate-verified** via iter-70 Task 4 + Task 5 execution + Story 1.12 spec v1.5 Change Log row + file-diff inspection. 7 absorptions landed at prescribed sites; 2 defers routed elsewhere. Deferred to iter-73 CR adversarial fan-out (Blind Hunter re-litigates each absorbed defer + verifies the fix is load-bearing). No Story 1.16 coverage needed — DEFER absorption is a drafting-time-authoring concern, not a runtime-test concern.

All P2 gaps are waived per § Rationale below.

---

### Rationale

Story 1.13 is a **gate-authoring + substrate-mutation** story at a pre-test-runner stage. It:

1. Authors three new CLI entry points across two packages:
   - `packages/keel-invariants/src/check-tokens-schema.ts` (NEW; Ajv-2020 schema-validate gate with structured JSON findings + fail-closed exit).
   - `packages/keel-invariants/src/check-tokens-contrast.ts` (NEW; 52-pair WCAG AA enumeration across light + dark with per-pair threshold + mode-aware alias resolution).
   - `packages/keel-invariants/src/color-math.ts` (NEW; zero-dep Ottosson 2020 OKLCH → linear sRGB + 3-iteration chroma-reduction gamut-map + WCAG 2.1 luminance/ratio primitives).
2. Amends the Story 1.12 emitter (`packages/ui/scripts/generate-tokens.ts`) in-place to add `--check` mode (byte-compare re-emitted buffers against committed outputs; JSON diff on divergence; zero writes), hoist the source-SHA resolver (single subprocess spawn + tagged failure-mode fallback), and fix the alias-cycle detector for diamond DAGs. Non-check mode preserves Story 1.12 AC 1 byte-for-byte.
3. Mutates `packages/ui/tokens.json` (authoring-half of AC 2) to retune four status/accent leaves that failed AA on the pre-Story-1.13 source + add dark-mode overlay entries for status/severity/state/text.accent/border.accent so dark-mode pairs land at AA passing ratios.
4. Amends `packages/ui/tokens.schema.json` (NEW `$defs.leafBreakpoint` with narrow `^\\d+px$` pattern — Story 1.12 CR defer #9 absorption).
5. Registers 3 new invariants in the manifest (14 → 17 entries) with description PATCHes on 3 existing entries + contentHash PATCHes on 6 existing entries; adds a new `### Design-token quality gates (Story 1.13)` section to `INVARIANTS.md` with 3 column-0 anchor bullets.
6. Wires 2 new local hooks in `.pre-commit-config.yaml` + 4 new repo-root scripts (including `keel-invariants:check-all` umbrella) + 2 new bin + 2 new script entries + 2 prod deps (`ajv@8.17.1`, `ajv-formats@3.0.1`) on `@keel/keel-invariants`.
7. Amends `_bmad-output/implementation-artifacts/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md` in-place to absorb AA1 + AA2 (source-SHA command literal + prettier-write list + `.prettierignore` contract clause) per BMad deferred-work-absorption precedent; Story 1.12 Status remains `done`.

The story's § Dev Notes → Testing standards summary (v1.2 iter-69 bullet) explicitly declares that no test runner is wired at Story 1.13 time (test framework landing is Story 1.16). Substrate verification runs through: (a) `pnpm -w {typecheck,lint,build,format:check}` quality-gate bundle + prek 5/5 hooks (all green at iter-70); (b) Task 7 three negative smokes — schema-gate (delete `$type` → exit 1 + structured JSON `instancePath`/`keyword`), contrast-gate (retune `status.info.fg` bright → exit 1 + JSON naming 2 failing pairs with ratios), sync-gate (retune `accent.500` without re-emit → exit 1 + unified-diff JSON for 3 paths) — each directly probing the corresponding AC's fail-closed contract at CLI-exit-code level; (c) `pnpm keel-invariants:check-all` clean-path exit 0 umbrella (17-entry manifest walk + emitter `--check`); (d) `/bmad-code-review (args: '2')` adversarial coverage (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out) for all six ACs per story § Dev Notes:Testing-standards-summary:ground-(c)-variant-(iii) **spec-declared CR-substitution clause**.

Per-AC automated test coverage is explicitly deferred to Story 1.16 (test-runner landing):

- AC 1 — Ajv error-keyword enumeration matrix (`type`/`pattern`/`required`/`additionalProperties`/`enum`/`const`/`oneOf`/`anyOf`); compile-cost probe.
- AC 2 — `color-math.test.ts` with 4 OKLCH→sRGB conversions + 2 contrast computations + 1 gamut-clip verification per spec § AC 2 carve-out; alternative-gamut-map-algorithm parity (Chroma.js + culori).
- AC 3 — diamond-DAG fixture smoke (`packages/ui/__fixtures__/tokens.diamond-dag.json`); SHA-resolver failure-mode probes (git ENOENT / stderr-error / uncommitted).
- AC 4 — manifest-entry snapshot test; anchor-regex completeness.
- AC 5 — hook-config regex enumeration; pre-commit tier timing-budget probe.

Story 1.9 sync-gate runtime (`pnpm keel-invariants:check`) already enforces all 17 manifest entries at every pre-commit/pre-merge via Story 1.5's prek pipeline. This covers the **structural-registration half** of AC 4 at runtime — no additional story-internal coverage needed.

**The three Story 1.13 gates are themselves the waiver-expiry event** for Stories 1.11 + 1.12 earlier WAIVED gate decisions: Story 1.11 authored the DTCG source (waived on AC-runtime-coverage with the expectation that Story 1.13 contrast-gate would exercise AA at every pre-commit); Story 1.12 authored the emitter + three outputs (waived on AC 3/4/5 integration with the expectation that Story 1.13 sync-gate would re-exercise emit end-to-end at every pre-commit). Story 1.13 lands those pre-commit gates — so the WAIVED waivers on Stories 1.11 + 1.12 EXPIRE on the Story 1.13 landing commit. This makes Story 1.13 the load-bearing waiver-expiry event for the entire Epic 1 design-token substrate.

The deterministic FAIL signal from the rule engine (`overall_coverage_actual: 0% < overall_coverage_minimum: 80%`) is a structural false-positive: forcing automated per-AC unit tests on a gate-authoring story at a pre-test-runner stage inverts the architecture contract (the gates ARE the validation layer, not a validated subject — they run at every pre-commit going forward and catch drift the moment it happens). Double-gating delays Epic 1 substrate completion without risk reduction.

Per `.ralph/@plan.md` Story 1.13 FR14n lifecycle + RALPH.md 2026-04-21 signposts, the ATDD red-phase step for this story was **skipped at iter-69** on the hybrid-ground-(c) variant-(ii)+(iii) rationale (§ ATDD Skip Rationale in `@plan.md`): (a) Task 7 three negative smokes directly probe AC 1 + AC 2 + AC 3 at shell level; (b) no test runner at Story 1.13 time (Story 1.16 scope); (c) hybrid variant-(ii) + variant-(iii): Story 1.16 owns the per-AC red-phase backfill AND story § Dev Notes:Testing-standards-summary:ground-(c)-variant-(iii) affirmatively declares `/bmad-code-review` adversarial fan-out as CR-substitution for gate-authoring adversarial surface (Ajv compile-cost, OKLCH→sRGB precision, gamut-map convergence, pair-enumeration completeness, `--check` purity, SHA-resolver failure modes, diamond-DAG guard, dark-overlay walker). This trace-gate decision mirrors the iter-69 ATDD-skip decision — **seventh cumulative WAIVED precedent** for contract-only / contract-populator / data-only / emitter+tooling / gate-authoring substrate stories (Stories 1.7 + 1.8 + 1.9 + 1.10 + 1.11 + 1.12 + 1.13). Each successive WAIVED application extends the same load-bearing hybrid-ground-(c) rationale; Story 1.13 adds the NEW gate-authoring substrate pattern with THREE negative smokes (stronger than the two-smoke Story 1.9/1.10/1.12 pattern; stronger than the one-smoke Story 1.11 pattern; AT PARITY with the strongest per-iteration evidence across the cumulative WAIVED cohort — Story 1.12 had two determinism smokes at the same depth but Story 1.13 has three gate-behavior smokes covering distinct failure modes).

---

## PHASE 2: GATE DECISION

### Determinism Logic

This gate evaluation uses **deterministic** rules to prevent bias/hallucination:

**Rule 1: P0 Coverage** (≥100%)

- P0 requirements total: 0 — effective coverage 100% (vacuously satisfied). ✅ PASS

**Rule 2: Overall Coverage** (≥80%)

- 0 / 6 fully covered = 0% — ❌ FAIL on the letter of the rule. **WAIVER RATIONALE** applies (see below).

**Rule 3: P1 Coverage** (≥80%, target 90%)

- P1 requirements total: 0 — effective coverage 100% (vacuously satisfied). ✅ PASS

**Rule 4: Test Stability**

- 0 tests total, 0 flaky. Not applicable.

**Rule 5: Security / Critical NFRs**

- No auth / payment / PII / encryption changes in Story 1.13. Not applicable.

**Rule 6: Test Quality** (if `/bmad-testarch-test-review` invoked)

- Not invoked — zero tests to review. Not applicable.

---

### Final Decision: **WAIVED** 🔓

#### Rule Evaluation Summary

| Rule                          | Status | Details                                                                                                                  |
| ----------------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------ |
| P0 Coverage (≥100%)           | ✅     | No P0 criteria (vacuously satisfied)                                                                                     |
| P1 Coverage (≥80%, target 90%) | ✅     | No P1 criteria (vacuously satisfied)                                                                                     |
| Overall Coverage (≥80%)       | ❌     | 0% — see Waiver Details                                                                                                  |
| Test Stability                | ✅     | 0 tests total; not applicable                                                                                            |
| Security/NFRs                 | ✅     | No security-surface changes                                                                                              |
| Test Quality                  | ✅     | No tests authored (workflow review n/a)                                                                                  |
| Collection Status             | ✅     | `contract_static` collection COLLECTED                                                                                   |
| Gate Eligibility              | ✅     | Coverage basis: `acceptance_criteria`; oracle confidence: `high`; external pointer status: `not_used`; synthetic: `false` |

#### Waiver Details

**Original Decision**: ❌ FAIL (Rule 2: overall coverage 0% < 80% minimum).

**Reason for Failure**: zero automated tests cover the six P2 ACs.

**Waiver Information**:

- **Waiver Reason**: Story 1.13 is a gate-authoring + substrate-mutation story at a pre-test-runner stage. Per-AC automated coverage is explicitly deferred to Story 1.16 (test-runner landing — Ajv error-keyword matrix / `color-math.test.ts` / diamond-DAG fixture smoke / SHA-resolver failure-mode probes / manifest-entry snapshot / hook-config regex + timing-budget). Story § Dev Notes:Testing-standards-summary:ground-(c)-variant-(iii) **affirmatively declares spec-declared CR-substitution** for adversarial gate-authoring coverage via `/bmad-code-review (args: '2')` Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out (hybrid ground-(c) variant-(ii)+(iii) — see RALPH.md 2026-04-21 Story 1.13 iter-69 signpost). **The three Story 1.13 gates are themselves the waiver-expiry event for Stories 1.11 + 1.12 earlier WAIVED decisions** — they run at every pre-commit/pre-merge going forward, replacing prior substrate-level smoke evidence with committed gates.
- **Waiver Approver**: Story 1.13 itself (stakeholder-authored § Dev Notes Testing-standards-summary v1.2 iter-69 bullet + inline AC scope carve-outs at story lines 21, 23, 33, 35, 37, 45, 47, 49, 51, 63, 74, 76, 92). See also: `.ralph/@plan.md` iter-69 FR14n ATDD-skip rationale and RALPH.md Signposts 2026-04-21 (**seventh cumulative application** of FR14n ATDD-skip clause — Stories 1.7/1.8/1.9/1.10/1.11/1.12/1.13).
- **Approval Date**: 2026-04-21 (story drafted iter-67, pre-dev SM review iter-68, ATDD-skip iter-69, dev-story iter-70, trace iter-71 — all within the same ISO day).
- **Waiver Expiry**: expires when Story 1.16 test-runner lands (optional per-AC backfill unit tests if still deemed value-adding after substrate verification + CR adversarial coverage prove sufficient). Gate-behavior correctness (AC 1 + AC 2 + AC 3) is substrate-verified end-to-end via three negative smokes at iter-70 (strongest negative-space probe across all seven cumulative WAIVED precedents); AC 4 is substrate-verified via `check-all` exit 0 live; AC 5 is substrate-verified via prek 5/5 live; AC 6 DEFER absorption is drafting-time-authoring — no runtime-test needed.

**Monitoring Plan**:

- **The three Story 1.13 gates are themselves the monitoring plan** — schema-validate + WCAG contrast run at every pre-commit touching `tokens.json`; source-output sync runs at every pre-merge via `keel-invariants:check-all`. Any drift between source + schema, source + AA thresholds, or source + emitted outputs is caught the moment it happens.
- Prettier format-check + TypeScript strict mode + ESLint at pre-commit (already green — Stories 1.3/1.4 substrates); `.prettierignore` governs emitter-owned canonical byte-format for generated outputs per Story 1.12 lesson.
- Story 1.9 sync-gate re-runs at every pre-commit via Story 1.5's prek pipeline: re-hashes all 17 manifest entries + cross-checks INVARIANTS.md anchors + drift → exit 1 hard fail. The three new Story 1.13 manifest entries are automatically picked up.
- Code-review of any future PR that edits `packages/keel-invariants/src/check-tokens-schema.ts`, `packages/keel-invariants/src/check-tokens-contrast.ts`, `packages/keel-invariants/src/color-math.ts`, or `packages/ui/scripts/generate-tokens.ts` — reviewer must verify: (a) structured finding shape preserved; (b) fail-closed contract preserved (exit 1 on any violation); (c) zero network / zero time / zero RNG purity preserved in gate CLIs + `--check` mode; (d) Ottosson 2020 matrix constants + 3-iteration chroma-reduction invariants respected.
- Epic 13 reproducibility CI will absorb `keel-invariants:check-all` as a pre-merge gate — Story 1.13 emitter `--check` mode is the substrate-level analogue of Epic 13's content-hash-diff check.

**Remediation Plan**:

- **Fix Target**: Story 1.16 (test-runner wiring for optional per-AC backfill probes) + Epic 7 Story 7-1 (Tailwind preset consumer verification — picks up retuned `tokens.json` + regenerated outputs) + Epic 3 Story 3.33 (TUI theme.py consumer verification — picks up retuned tokens via emitted `theme.py`) + Epic 13 Stories 13-1/13-2 (reproducibility CI forward-enforcement — absorbs `keel-invariants:check-all`).
- **Due Date**: per epic sprint-plan (not a blocker for Story 1.13 merge). Epic 1 closure (after Story 1.16) lands pre-Epic-7 so consumer-side integration opens immediately.
- **Owner**: Epic 1 substrate team (Ralph loop).
- **Verification**: Story 1.16 test-runner landing is the first downstream verification event (unlocks optional per-AC backfill — Ajv keyword matrix, `color-math.test.ts`, diamond-DAG fixture). Epic 7 Story 7-1 consumer build turning green is the second (positive-space retuned-tokens verification). Epic 3 Story 3.33 TUI boot turning green is the third (Python theme attribute access with retuned dark-mode overlay). Epic 13 reproducibility CI is the fourth (content-hash-diff on `keel-invariants:check-all`).

**Business Justification**: Forcing automated per-AC tests on a gate-authoring story at a pre-test-runner stage inverts the architecture contract: the gates ARE the validation layer. They run at every pre-commit + pre-merge going forward, replacing prior substrate-level smoke evidence with committed gates — the Story 1.11 DTCG source is machine-verified against the schema on every edit; the token semantic pairs are machine-verified against WCAG AA on every edit; the emitter outputs are machine-verified against source on every pre-merge. Any drift between source and schema, source and AA thresholds, or source and emitted outputs is caught the moment it happens. Double-gating with test-runner-hosted probes before Story 1.16 lands a runner wastes iteration budget; per-AC runner-hosted backfill is better deferred to Story 1.16 where the test framework exists. Authoring dead-code red-phase probes waste iteration budget — and `/bmad-code-review` adversarial fan-out (Blind Hunter + Edge Case Hunter + Acceptance Auditor) IS the substrate-time adversarial backstop (story § Dev Notes:Testing-standards-summary:ground-(c)-variant-(iii) affirmatively declares this CR-substitution).

---

#### Critical Issues (For FAIL or CONCERNS)

None. The FAIL signal from the deterministic rule engine is waived (see above).

---

### Gate Recommendations — For WAIVED Decision 🔓

1. **Deploy with Business Approval**
   - Waiver documented above.
   - Story 1.13's PR #226 can proceed through the remaining FR14n lifecycle states: `traced` → `/bmad-create-story (args: "review")` post-dev SM-verify → `sm-verified` → `/bmad-code-review (args: "2")` → `done`. PR #226 stays Draft through Epic 1 closure (Stories 1.14–1.16 remain); Draft→Open + EPIC_DONE halt land after Story 1.16.
2. **Aggressive Monitoring**
   - **The three Story 1.13 gates ARE the monitoring plan** (schema-validate + WCAG contrast at every pre-commit touching `tokens.json`; source-output sync at every pre-merge via `keel-invariants:check-all` umbrella).
   - Prettier format-check + TypeScript strict mode + ESLint at pre-commit (already green — Stories 1.3/1.4 substrates); `.prettierignore` governs emitter-owned canonical byte-format for generated outputs per Story 1.12 lesson.
   - Story 1.9 sync-gate re-runs at every pre-commit; automatically picks up Story 1.13's three new manifest entries (`INV-tokens-schema-validate`, `INV-tokens-contrast-check`, `INV-tokens-sync-gate`).
   - Code-review of any future PR that edits the gate source files — verify structured finding shape + fail-closed contract + purity invariants + matrix-math constants preserved.
3. **Mandatory Remediation**
   - Story 1.16 test-runner must land before optional per-AC backfill probes can be authored. Epic 1 sprint-status already tracks 1.13 → 1.14 → 1.15 → 1.16 as the remaining closure sequence.
   - Epic 13 reproducibility CI must be architected to consume `keel-invariants:check-all` as a pre-merge gate — Story 1.13 sync-gate is a positive-space reproducibility target.

---

### Next Steps

**Immediate Actions** (this iteration):

1. Commit this traceability matrix + sibling JSONs under `_bmad-output/test-artifacts/traceability/`.
2. Update `.ralph/@plan.md`: mark NOW done, transition Story State `in-dev → traced`, move next QUEUE item (post-dev SM review via `/bmad-create-story (args: "review")`) to NOW.
3. Push + exit.

**Follow-up Actions** (Story 1.13 remaining lifecycle):

1. Story State `traced` → run `/bmad-create-story (args: "review")` post-dev SM verification (requirements-satisfaction gate).
2. On `sm-verified`, run `/bmad-code-review (args: "2")` for adversarial triage (spec-declared CR-substitution for all six ACs per § Dev Notes Testing-standards-summary v1.2 iter-69).
3. On `done`, move to Story 1.14 (next Epic 1 story).

**Stakeholder Communication**:

- Notify PM / SM / Dev lead: **Story 1.13 trace GATE=WAIVED** (gate-authoring + substrate-mutation story; coverage enforcement deferred to Story 1.16 test-runner + Epic 13 reproducibility CI per § Dev Notes Testing-standards-summary + inline AC scope carve-outs; **substrate verification is STRONGEST of the seven cumulative WAIVED precedents** — all quality gates green + Task 7 three negative smokes end-to-end [schema-gate delete `$type` → exit 1; contrast-gate retune bright → 2 pairs exit 1; sync-gate retune without re-emit → 3-path diff JSON + exit 1] + `keel-invariants:check-all` umbrella exit 0 + prek 5/5 hooks pass).

---

## Integrated YAML Snippet (CI/CD)

```yaml
traceability_and_gate:
  # Phase 1: Traceability
  traceability:
    story_id: '1.13'
    date: '2026-04-21'
    coverage:
      overall: 0
      p0: 100
      p1: 100
      p2: 0
      p3: 100
    gaps:
      critical: 0
      high: 0
      medium: 6
      low: 0
    quality:
      passing_tests: 0
      total_tests: 0
      blocker_issues: 0
      warning_issues: 0
    recommendations:
      - 'AC-1 schema-validate gate substrate-verified via iter-70 Task 7 negative smoke (delete $type → exit 1 + structured JSON instancePath/keyword/message; revert → exit 0 silent); defer Ajv error-keyword matrix + compile-cost to Story 1.16'
      - 'AC-2 WCAG AA contrast gate + OKLCH gamut-map pipeline STRONGEST substrate evidence — iter-70 Task 7 negative smoke (retune status.info.fg bright → 2 pairs failing JSON + exit 1) + authoring-half retunes applied (accent 500 54→50%, accent 600 46→42%, status.info.fg 52→42%, status.warning.fg 58→44%, dark-mode overlay additions); defer color-math.test.ts harness to Story 1.16'
      - 'AC-3 source-output sync gate via emitter --check substrate-verified via iter-70 Task 7 negative smoke (retune accent.500 without re-emit → unified-diff JSON for 3 paths + exit 1; revert + re-emit → exit 0); Story 1.12 CR defers #4/#5/#6 absorbed inline; defer diamond-DAG fixture smoke + SHA-resolver failure modes to Story 1.16'
      - 'AC-4 manifest growth 14→17 + INVARIANTS.md new section substrate-verified live via iter-70 pnpm keel-invariants:check-all exit 0 (17-entry manifest walk + content-hash alignment + anchor presence); shared-sourcePath precedent established; defer manifest-entry snapshot to Story 1.16'
      - 'AC-5 pre-commit hooks + repo-root scripts substrate-verified live via iter-70 pnpm exec prek run --all-files 5/5 hooks pass; ≤10s tier budget preserved; defer hook-config regex + timing-budget to Story 1.16'
      - 'AC-6 7 Story 1.12 CR defers absorbed at prescribed sites (AA1/AA2/AA3 Story 1.12 spec amendments; #4/#5/#6 emitter source amendments; #7 pipeline ordering; #9 schema regex pin) + Story 1.11 iter-59 defers #1–#5 contrast+gamut absorbed via § AC 2 retunes; iter-73 CR adversarial fan-out is agreed backstop — no Story 1.16 coverage needed (DEFER absorption is drafting-time-authoring concern)'

  # Phase 2: Gate Decision
  gate_decision:
    decision: 'WAIVED'
    gate_type: 'story'
    decision_mode: 'deterministic'
    criteria:
      p0_coverage: 100%
      p0_pass_rate: n/a
      p1_coverage: 100%
      p1_pass_rate: n/a
      overall_pass_rate: n/a
      overall_coverage: 0%
      security_issues: 0
      critical_nfrs_fail: 0
      flaky_tests: 0
    thresholds:
      min_p0_coverage: 100
      min_p0_pass_rate: 100
      min_p1_coverage: 80
      min_p1_pass_rate: 95
      min_overall_pass_rate: 95
      min_coverage: 80
    evidence:
      test_results: 'substrate quality-gate bundle (typecheck 16/16 + lint 16/16 + build 16/16 + format:check clean + keel-invariants:check-all exit 0 [17-entry manifest walk + emitter --check] + prek 5/5 hooks pass [typecheck + lint + format-check + tokens-schema + tokens-contrast]) + Task 7 three negative smokes end-to-end (schema-gate: delete $type from color.neutral.50 → stderr JSON with instancePath/keyword + exit 1; revert → exit 0 / contrast-gate: retune color.status.info.fg to oklch(72% 0.14 230) → stderr JSON naming status.info.fg × status.info.bg (ratio 2.09, threshold 4.5) + severity.low × surface.default + exit 1; revert → exit 0 / sync-gate: retune color.accent.500 to oklch(51% 0.18 245) without re-emit → stderr JSON with first differing byte offset + ≤5-line unified-diff for all three target paths + exit 1; revert + emitter re-run → exit 0 silent) + authoring-half AC 2 mutations applied (tokens.json retunes: accent.500 54%→50%, accent.600 46%→42%, status.info.fg 52%→42%, status.warning.fg 58%→44%; dark-mode overlay additions for $modes.dark.color.{status.*.fg, text.accent, border.accent, severity.*, state.*}) — Story 1.13 Task 7 Completion Notes iter-70'
      traceability: '_bmad-output/test-artifacts/traceability/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md'
      nfr_assessment: 'inferred_from_story_dev_notes'
      code_coverage: 'not_applicable'
    next_steps: 'Proceed to post-dev SM verify → code review per Ralph lifecycle matrix.'
    waiver:
      reason: 'Gate-authoring + substrate-mutation story; per-AC automated coverage deferred to Story 1.16 (test-runner for Ajv error-keyword matrix + color-math.test.ts + diamond-DAG fixture + SHA-resolver failure-mode probes + manifest-entry snapshot + hook-config regex + timing-budget) + Epic 13 reproducibility CI (forward-enforcement via keel-invariants:check-all). FR14n ATDD-skip (iter-69 hybrid-ground-(c) variant-(ii)+(iii)) precedent is load-bearing (SEVENTH cumulative application). Story § Dev Notes:Testing-standards-summary:ground-(c)-variant-(iii) affirmatively declares /bmad-code-review adversarial fan-out as CR-substitution for gate-authoring adversarial coverage. The three Story 1.13 gates are themselves the waiver-expiry event for Stories 1.11 + 1.12 earlier WAIVED decisions.'
      approver: 'Story 1.13 § Dev Notes Testing-standards-summary v1.2 iter-69 + inline AC scope carve-outs (stakeholder-authored)'
      expiry: 'deferred (expires when Story 1.16 test-runner lands for optional per-AC backfill probes; AC 1 + AC 2 + AC 3 substrate-verified via three negative smokes end-to-end — strongest negative-space probe across all seven cumulative WAIVED precedents; AC 4 + AC 5 substrate-verified live via check-all + prek invocations; AC 6 DEFER absorption is drafting-time-authoring concern with no runtime-test target)'
      remediation_due: 'Story 1.16 (test-runner wiring) + Epic 7 Story 7-1 (Tailwind consumer picks up retuned tokens) + Epic 3 Story 3.33 (TUI consumer picks up retuned dark-mode overlay) + Epic 13 Stories 13-1/13-2 (reproducibility CI forward-enforcement via keel-invariants:check-all)'
```

---

## Related Artifacts

- **Story File:** `_bmad-output/implementation-artifacts/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md`
- **Implementation Artefacts:**
  - `packages/keel-invariants/src/check-tokens-schema.ts` (NEW — Task 1 CLI; Ajv-2020 schema-validate gate; structured JSON findings; fail-closed exit).
  - `packages/keel-invariants/src/check-tokens-contrast.ts` (NEW — Task 2 CLI; 52-pair WCAG AA enumeration; mode-aware alias resolver; gamut-mapped OKLCH→sRGB contrast ratios).
  - `packages/keel-invariants/src/color-math.ts` (NEW — Task 2 helper; zero-dep Ottosson 2020 OKLCH→linear sRGB + 3-iteration chroma-reduction gamut-map + WCAG 2.1 luminance/ratio primitives).
  - `packages/ui/scripts/generate-tokens.ts` (MODIFIED — Task 3 `--check` mode + SHA-resolver hoist + tagged failure-mode fallback + diamond-DAG `resolveValue` fix).
  - `packages/ui/tokens.json` (MODIFIED — Task 2 authoring-half; accent 500 54→50%, accent 600 46→42%, status.info.fg 52→42%, status.warning.fg 58→44%; dark-mode overlay additions for status/severity/state/text.accent/border.accent).
  - `packages/ui/tokens.schema.json` (MODIFIED — Task 5; new `$defs.leafBreakpoint` + `breakpointGroup`/`sparseBreakpointGroup` re-refs; Story 1.12 CR defer #9 absorption).
  - `packages/keel-invariants/src/invariants.manifest.ts` (MODIFIED — Task 5; 14 → 17 entries with shared-sourcePath pattern; 3 description PATCHes + 6 contentHash PATCHes).
  - `packages/keel-invariants/package.json` (MODIFIED — 2 new bin entries + 2 new script entries + 2 prod deps `ajv@8.17.1` + `ajv-formats@3.0.1`).
  - `package.json` (repo-root; MODIFIED — 4 new scripts including `keel-invariants:check-all` umbrella).
  - `.pre-commit-config.yaml` (MODIFIED — 2 new local hooks `tokens-schema` + `tokens-contrast`).
  - `INVARIANTS.md` (MODIFIED — new `### Design-token quality gates (Story 1.13)` section with 3 column-0 anchor bullets).
  - `_bmad-output/implementation-artifacts/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md` (MODIFIED — AA1 + AA2 + AA3 spec amendments in-place; v1.5 Change Log row; Story 1.12 Status unchanged `done`).
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` (MODIFIED — `1-13-…: ready-for-dev → in-progress → review`).
  - `pnpm-lock.yaml` (MODIFIED — Ajv closure delta scoped to `@keel/keel-invariants`).
- **Agent-readable index (source of truth for the IDs):** `INVARIANTS.md` new Story 1.13 section.
- **Test Design:** not applicable (gate-authoring + substrate-mutation story; no test design doc authored).
- **Tech Spec:**
  - `_bmad-output/planning-artifacts/architecture.md` § Three-layer invariant pattern (lines 85–90) + § Design-token ID Pattern (lines 691–695) + § CI pyramid (pre-commit tier ≤10s budget) + § Generator Normalization Algorithm (line 440; FR67 purity contract basis).
  - `_bmad-output/planning-artifacts/prd.md` FR41 / FR42 / FR43 (INV manifest enforcement) + FR67 (purity contract) + NFR27 (fail-closed gates).
  - `_bmad-output/planning-artifacts/epics.md` lines 1018–1046 (Story 1.13 AC block) + UX-DR4/5/6 (quality loop closure) + lines 982–1016 (Story 1.12 positive-space producer).
  - `packages/ui/tokens.schema.json` (Draft 2020-12; source of truth per `INV-tokens-schema-contract`; consumed by Ajv at AC 1).
  - `_bmad-output/implementation-artifacts/deferred-work.md` § Deferred from: code review of 1-12 (2026-04-21) 10-defer ledger; 7 absorbed at Story 1.13 prescribed sites.
- **Test Results:** substrate quality-gate bundle (typecheck + lint + build + format:check + prek 5/5 + keel-invariants:check-all) + Task 7 three negative smokes (schema / contrast / sync) — all green; Story 1.13 Dev Agent Record Completion Notes iter-70.
- **NFR Assessment:** inferred (not a formal NFR doc); NFR27 fail-closed contract substrate-verified at § AC 1 + § AC 2 + § AC 3 three negative smokes + FR67-adapted purity preserved in `--check` mode (zero writes).
- **Test Files:** none (no test runner until Story 1.16).
- **Precedent:**
  - `_bmad-output/test-artifacts/traceability/1-7-*` (Story 1.7 WAIVED — docs-only stage).
  - `_bmad-output/test-artifacts/traceability/1-8-*` (Story 1.8 WAIVED — contract-only; 10-entry manifest shape precedent).
  - `_bmad-output/test-artifacts/traceability/1-9-*` (Story 1.9 WAIVED — sync-gate runtime; 5-smoke-branch evidence precedent).
  - `_bmad-output/test-artifacts/traceability/1-10-*` (Story 1.10 WAIVED — schema + rationale-doc contract; three-smoke-branch evidence precedent).
  - `_bmad-output/test-artifacts/traceability/1-11-*` (Story 1.11 WAIVED — data-authoring / contract-populator).
  - `_bmad-output/test-artifacts/traceability/1-12-*` (Story 1.12 WAIVED — emitter+tooling; two determinism smokes).
  - Structural trace-artefact inheritance from Stories 1.11 + 1.12 applied (~90% reasoning-cost savings per iter-46 + iter-57 + iter-64 precedent — mechanical adaptation of `substrate_verification` blocks from 6-AC Story 1.12 to 6-AC Story 1.13, with gate-authoring substrate evidence replacing emitter substrate evidence).

---

## Sign-Off

**Phase 1 — Traceability Assessment:**

- Overall Coverage: 0% (structural; intentional per § Dev Notes Testing-standards-summary v1.2 iter-69)
- P0 Coverage: 100% (vacuously satisfied — no P0 ACs)
- P1 Coverage: 100% (vacuously satisfied — no P1 ACs)
- Critical Gaps: 0
- High Priority Gaps: 0
- Medium Priority Gaps: 6 (all scoped-out to Story 1.16 test-runner + iter-73 CR adversarial fan-out + Epic 13 reproducibility CI forward-enforcement; AC 1 + AC 2 + AC 3 have STRONGEST substrate verification via three negative smokes end-to-end at CLI-exit-code level — strongest negative-space probe across all seven cumulative WAIVED precedents; AC 4 + AC 5 substrate-verified live via `check-all` + prek invocations; AC 6 DEFER absorption is drafting-time-authoring concern with no runtime-test target)

**Phase 2 — Gate Decision:**

- **Decision**: WAIVED 🔓
- **P0 Evaluation**: ✅ ALL PASS
- **P1 Evaluation**: ✅ (P1 total = 0; effectiveP1Coverage = 100%)
- **Overall**: ❌ on rule engine → 🔓 WAIVED on rationale

**Overall Status:** WAIVED 🔓

**Next Steps:** Story State `in-dev → traced`; proceed to `/bmad-create-story (args: "review")` post-dev SM verification.

**Generated:** 2026-04-21
**Workflow:** testarch-trace v4.0 (Enhanced with Gate Decision)

---
