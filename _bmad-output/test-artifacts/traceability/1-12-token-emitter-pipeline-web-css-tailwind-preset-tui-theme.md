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
    '_bmad-output/implementation-artifacts/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    '_bmad-output/planning-artifacts/ux-design-specification.md',
    'INVARIANTS.md',
    'packages/ui/tokens.schema.json',
    'packages/ui/tokens.json',
    'packages/ui/scripts/generate-tokens.ts',
    'packages/ui/src/tokens.css',
    'packages/ui/tailwind.preset.ts',
    'packages/devbox/tui/theme.py',
    'packages/keel-invariants/src/invariants.manifest.ts',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/1-12-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 1.12 token emitter pipeline → web CSS + Tailwind preset + TUI theme

**Target:** Story 1.12 — Token emitter pipeline → web CSS + Tailwind preset + TUI theme (pure TypeScript emitter at `packages/ui/scripts/generate-tokens.ts` reading Story 1.11 `packages/ui/tokens.json` and emitting three byte-stable targets: `packages/ui/src/tokens.css` + `packages/ui/tailwind.preset.ts` + `packages/devbox/tui/theme.py`; one new manifest entry `INV-tokens-emitter`; consumed by Epic 7 Story 7-1 + Epic 3 Story 3.33 + Epic 12 shape-aware templates; positive-space consumer of Story 1.11 source; input to Story 1.13 source-output sync gate; forward-contract for Epic 13 reproducibility CI).
**Date:** 2026-04-21
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 1.12 § Acceptance Criteria lines 13–103)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md` (AC 1–6)

---

Note: This workflow does not generate tests. Story 1.12 is a **substrate+tooling emitter** story whose § Testing Standards (story lines 243–246) explicitly declares:

> _"No test runner at Story 1.12 time (lands Story 1.16). Verification is substrate-layer: `pnpm -w {typecheck,lint,build,format:check}` + `pnpm exec prek run --all-files` + `pnpm keel-invariants:check` (Story 1.9 runtime tool) + two determinism smokes (Task 6). Determinism smokes (AC 2) are the end-to-end evidence for this story — analogous to Story 1.10 Task 4 sync-gate smokes + Story 1.11 Task 4 content-hash-mismatch + added-to-source-only smokes. Two smoke branches required (byte-identical round-trip + source-change propagation); the content-hash-mismatch + added-to-source-only manifest smokes are OPTIONAL (already proven at Story 1.10 iter-45 + Story 1.11 iter-56; re-smoke is defense-in-depth if iter budget allows). Deferred unit + integration tests: once Story 1.16 lands the test runner, backfill per-AC unit tests can verify: (a) AC 1 — output paths + provenance header format (snapshot test); (b) AC 2 — byte-identical round-trip in a test harness; (c) AC 3 — CSS var enumeration matches token leaf enumeration (diff test); (d) AC 4 — Tailwind preset shape conforms to `Partial<Config>['theme']['extend']`; (e) AC 5 — theme.py `SimpleNamespace` attribute enumeration matches token leaves; (f) AC 6 — purity sandbox test (deny network + time + RNG + env via runtime proxy + assert emitter succeeds). None of these block Story 1.12's `review → done` transition. **Adversarial coverage of AC 2 determinism + AC 6 purity is provided by `/bmad-code-review (args: '2')`'s Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out** (mirrors Story 1.10 iter-44 + Story 1.11 iter-55 hybrid ground-(c) ATDD-skip rationale)."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-62, per the hybrid-ground-(c) variant-(ii)+(iii) rationale (Story 1.13 downstream-gate for AC 3/4/5 integration + spec-declared CR adversarial substitution for AC 2 + AC 6) pinned in `.ralph/@plan.md` and RALPH.md Signposts 2026-04-21. **Sixth cumulative WAIVED precedent** (Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57 + 1.12 iter-64) for contract-only / contract-populator / data-only / emitter+tooling substrate stories.

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

All six ACs are **emitter+tooling substrate** assertions over pure-TS emitter command / determinism / web CSS custom properties / Tailwind v4 preset / TUI Python theme / FR67-adapted purity contract. Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` — no P0 (auth/payment/data-loss), no P1 (primary user journey), no runtime user-facing behaviour path. The emitted artefacts are internal substrate data consumed by Story 1.9 sync-gate (runtime enforcement of `INV-tokens-emitter`), Story 1.13 pre-commit gates (schema-validation + WCAG-AA contrast + source-output sync), Epic 7 Story 7-1 catalog (Tailwind preset import + CSS vars), Epic 3 Story 3.33 TUI (Python theme import), Epic 12 shape-aware templates (Tailwind class generation), and Epic 13 reproducibility CI (content-hash-diff check on emitter outputs).

---

### Detailed Mapping

#### AC-1: `pnpm --filter @keel/ui generate-tokens` emits three outputs with provenance header; single source read (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16 test-runner + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — strongest positive signal for this AC):**
  - **Emitter command resolves** (iter-63 Task 1): `pnpm --filter @keel/ui generate-tokens` → `tsx scripts/generate-tokens.ts` per `packages/ui/package.json` `scripts.generate-tokens` entry. `tsx@4.21.0` devDep added to `@keel/ui`; `pnpm install` delta: 5 packages scoped (`tsx` + `esbuild` + `get-tsconfig` + `tinyglobby` + `fdir`); no unrelated workspace churn.
  - **Three output paths emitted at canonical locations** (iter-63 File List): `packages/ui/src/tokens.css` (NEW; 118 lines), `packages/ui/tailwind.preset.ts` (NEW; 119 lines), `packages/devbox/tui/theme.py` (NEW; 135 lines) + sibling zero-byte `packages/devbox/tui/__init__.py`. Paths match § AC 1 + UX-DR3 + `ux-design-specification.md:362` exactly (emitter-location variance with `architecture.md:916-917` resolved via § AC 1 scope carve-out per Story 1.11 Direction A precedence pattern).
  - **Provenance header shape matches § AC 1 scope carve-out verbatim** at all three targets: `AUTOGENERATED from packages/ui/tokens.json — DO NOT EDIT` + `Source file commit SHA: <short-sha>` + `Emitter: packages/ui/scripts/generate-tokens.ts @ v1.0.0` + `Regenerate via: pnpm --filter @keel/ui generate-tokens`. Comment syntax adapted per-target (`/* */` for CSS, `//` for TS, `#` for Python).
  - **Source-SHA resolver uses `git log -1 --format=%h --abbrev=12 -- <path>`** (intent-matching correction per iter-63 Debug Log — the story's literal `git rev-parse --short=12 HEAD -- <path>` returns repo HEAD which violates the same carve-out's `NOT HEAD of the repo` constraint). Resolver returns `6b1790a02adb` at dev-story time (Story 1.11 commit — the file's latest commit SHA); stable across smoke runs. Uncommitted-state fallback `uncommitted-<content-sha256-16>` is implemented + code-path-verified but untested at Story 1.12 time (source file is committed).
  - **Single source read verified**: emitter uses `node:fs.readFileSync('packages/ui/tokens.json', 'utf-8')` — one and only one source read. Optional schema validation (§ AC 6 carve-out default-skip) NOT implemented; `packages/ui/tokens.schema.json` NOT read. Emitter writes three target outputs + one optional sibling `__init__.py` (idempotent write-if-absent) + one `mkdirSync` for the new `packages/devbox/tui/` directory.
  - **`EMITTER_VERSION` literal constant** pinned at `packages/ui/scripts/generate-tokens.ts` top: `export const EMITTER_VERSION = '1.0.0';`. Bumping ownership deferred to future emitter-evolution stories.
  - **Quality-gate bundle green first pass** (iter-63 Completion Notes): `pnpm -w typecheck` ✓ (16 tasks), `pnpm -w lint` ✓ (16 tasks), `pnpm -w build` ✓ (16 tasks with scoped `@keel/keel-invariants` rebuild per iter-51 optimisation), `pnpm -w format:check` ✓ (emitter source prettier-conformant; three generated outputs ignored via `.prettierignore`), `pnpm exec prek run --all-files` 3/3 hooks Pass.
- **Known scope-carve-out variances (pre-documented, not gaps):**
  - **Source-SHA resolver command deviation from story § AC 1 literal** (iter-63 Debug Log + Change Log v1.2). Story proposed `git rev-parse --short=12 HEAD -- packages/ui/tokens.json`; emitter uses `git log -1 --format=%h --abbrev=12 -- packages/ui/tokens.json`. Functional equivalence verifiable by inspection: `rev-parse --short=12 HEAD` returns the repo HEAD SHA unconditionally (the `--` is a rev/path separator, not a log filter); the story's same-paragraph constraint (`NOT HEAD of the repo, which drifts as soon as the emitter commits the outputs`) mandates the per-file commit SHA, which `git log -1 --format=%h --abbrev=12 -- <path>` returns. Deviation documented in emitter source-file header + iter-63 Debug Log + commit trailer + Story 1.12 file Change Log v1.2. Carry-forward lesson: when a story-pinned command contradicts the surrounding prose constraints, prefer intent over literal + document the deviation.
  - **Emitter-owned canonical byte-format for generated outputs** (iter-63 Debug Log + `.prettierignore` modification). Prettier would normalize OKLCH decimal `0.20 → 0.2`, convert `[data-theme="dark"] → [data-theme='dark']`, convert TS/Python double-quotes → single-quotes — all transformations the emitter does NOT reproduce natively. Resolution: added `packages/ui/src/tokens.css` + `packages/ui/tailwind.preset.ts` to `.prettierignore` (Python already ignored via `*.py`); declared emitter's native byte-output as canonical for generated files; prettier continues to own the emitter source file. Byte-stability owned by emitter determinism alone (no prettier round-trip in the loop) — makes smoke 1 + Story 1.13 source-output sync gate reason about a single byte-level invariant per file. Pattern: prettier owns emitter SOURCE; emitter owns GENERATED OUTPUTS. Apply at Story 1.13+ gate-emitter + Story 5+ `@keel/keel-generator` output formats + any future emit-target pair.
- **Gaps:** No automated snapshot test asserting provenance header byte-exactness. No automated path-enumeration assertion (would need: Vitest `test('emitter writes exactly three outputs at canonical paths', () => ...)` post-Story-1.16). No automated `EMITTER_VERSION` literal assertion. Command-resolvability + output-path-exactness rely on hand-reading at authoring time + iter-61 pre-dev SM + iter-63 dev-pass + CR adversarial pass at Story Lifecycle row 9.
- **Recommendation:** Defer snapshot + path-enumeration probes to **Story 1.16** (test-runner landing). Substrate-level iter-63 execution evidence + CR adversarial pass are the agreed substrate evidence. WAIVED.

---

#### AC-2: Determinism — byte-identical round-trip (same input → same output, no time/RNG/network) (P2)

- **Coverage:** NONE ❌ (substrate-verified end-to-end; runner-hosted coverage deferred to Story 1.16)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONGEST substrate evidence of the six ACs):**
  - **Determinism smoke 1 (byte-identical round-trip, primary substrate evidence)** (iter-63 Debug Log + Completion Notes): run 1 hashes — CSS `4b59cb679c76a5cad3211061c49e1a450feb3d296b7c647607b2bd17a36d19f9` / Tailwind `c7bd57fa7b73f1f6b0288363152d2363e606c9504789b8e57c3d1069e123b130` / Python `7776b448a49d111ff266999627bdaea3283e481940df016d386984f19475a8c7`. Run 2 hashes: IDENTICAL byte-for-byte across all three targets. `git status --porcelain packages/ui/src/tokens.css packages/ui/tailwind.preset.ts packages/devbox/tui/theme.py` after run 2: only `??` (untracked — newly-added at iter-63; no diffs-since-last-write). Byte-stability confirmed; smoke 1 is the positive-space proof of determinism.
  - **Determinism smoke 2 (source-change propagation + revert-to-baseline, secondary substrate evidence)** (iter-63 Debug Log + Completion Notes): edit = `sed -i 's/"oklch(54% 0.18 245)"/"oklch(55% 0.18 245)"/' packages/ui/tokens.json` (1-percentage-point lightness bump on `color.accent.500`). Post-edit `sha256sum` DIFFERS from run-1 across all three outputs. Value propagates verbatim to all three targets: CSS `--color-accent-500: oklch(55% 0.18 245);`, Tailwind `'accent-500': 'oklch(55% 0.18 245)'`, Python `accent_500 = 'oklch(55% 0.18 245)'`. **Alias-downstream propagation CONFIRMED (multi-hop DFS flattening proven end-to-end)**: `color.accent.default = {color.accent.500}` → new value reaches `--color-accent-default`; `color.text.accent = {color.accent.default}` → new value reaches `--color-text-accent`; `color.state.in-progress = {color.accent.default}` → new value reaches `--color-state-in-progress`. Revert via `git checkout -- packages/ui/tokens.json`; re-run emitter; post-revert hashes MATCH run-1 baseline byte-for-byte (all three outputs). Source-change-propagation → revert → byte-identical confirms full determinism modulo source content.
  - **Alias walker boundary behaviour** (iter-63 Debug Log): DFS + visited-set implementation successfully traverses 2-hop chains (`{color.accent.default} → {color.accent.500} → oklch(...)`) and 3-hop chains (`{color.state.in-progress} → {color.accent.default} → {color.accent.500} → oklch(...)`) during smoke 2 value-propagation verification. Cycle detection is defensive — no cycles exist in Story 1.11 source; the detector is a guard for future source evolution per § AC 3 carve-out.
  - **FR67 purity substrate evidence** (iter-63 code inspection; full accounting at AC 6 below): emitter uses `node:fs` / `node:path` / `node:url` / `node:crypto` / `node:child_process` stdlib only; zero third-party runtime imports; zero network; zero `Date.now()` / `new Date()` / `process.hrtime()`; zero RNG; zero `process.env` reads. One source read + three writes + one-time directory create + one idempotent `__init__.py` write.
  - **`pnpm keel-invariants:check` clean-path ✓ exit 0** on first sync-gate invocation post scoped `@keel/keel-invariants` build — no drift; `INV-tokens-emitter` manifest entry (sha256 `6ee7731efb65d1cecd9aa35a51d377cf6a25c3543dc8433f74a761cc71442796`) + `INVARIANTS.md` column-0 anchor bullet + emitter source hash all aligned on first pass.
- **Gaps:** No automated negative-space cycle-input probe (would need: Vitest `test('emitter fails loudly on cycle input', () => ...)` — deferred to Story 1.13 schema-validation gate per § AC 2 scope carve-out; Story 1.13 owns the formal "reject malformed tokens.json" gate). No automated purity-sandbox test (deny network/time/RNG/env via runtime proxy + assert emitter still succeeds) — deferred to Story 1.16.
- **Recommendation:** SUBSTRATE_VERIFIED end-to-end via iter-63 Task 6 two determinism smokes — strongest substrate evidence of the six ACs. Defer runner-hosted unit coverage to **Story 1.16** (would duplicate substrate smokes); defer negative-space cycle-input probe to **Story 1.13** schema-validation gate per § AC 2 scope carve-out. WAIVED.

---

#### AC-3: Web CSS custom properties — full 8-group coverage under `:root { }` + `[data-theme="dark"] { }`; kebab full-path naming; alias-flatten at emit (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.13 source-output sync gate + Story 1.16 test-runner)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence):**
  - **`:root { }` base block present** (iter-63 File List): 90 emitted CSS custom properties covering all 8 token groups. Determinism smoke 2 confirmed var-enumeration survives targeted source edits + reverts (CSS output byte-identical to run-1 baseline post-revert).
  - **`[data-theme="dark"] { }` overlay block present**: 16 dark-mode overrides matching `$modes.dark` entries from `packages/ui/tokens.json` — surface + text + border + accent.fg + status.bg variant re-remaps per Story 1.11 dark-overlay shape (sparse-overlay pattern; dark-mode `status.fg` values omitted per iter-56 "keep `fg` equal across modes" directive).
  - **Kebab full-path CSS var naming** per § AC 3 scope carve-out: `color.surface.raised` → `--color-surface-raised`; `color.status.success.fg` → `--color-status-success-fg`; `color.accent.500` → `--color-accent-500`; `color.state.in-progress` → `--color-state-in-progress` (dash preserved in CSS); `motion.swift` → `--motion-swift`; `density.compact` → `--density-compact`; `breakpoint.2xl` → `--breakpoint-2xl`. Path split via `path.split('.').join('-')` + `--` prefix.
  - **Alias flattening** per § AC 3 scope carve-out (iter-63 Debug Log smoke-2 value-propagation verification): `{color.accent.500}` resolves at emit-time to leaf literal `oklch(54% 0.18 245)`; multi-hop chains (`{color.state.in-progress}` → `{color.accent.default}` → `{color.accent.500}` → `oklch(...)`) flatten through all hops. Every emitted CSS var carries RESOLVED leaf literal — zero `var()` chains per § AC 3 strategy pin.
  - **All 8 token groups covered** (no omissions): `color.*` (neutral 11-step + accent 6-slot + surface + text + border + status 5-family × fg/bg + severity + state) ✓ / `type.*` (8 stops) ✓ / `font.*` (sans + mono) ✓ / `space.*` (13 stops) ✓ / `radius.*` (5 stops) ✓ / `motion.*` (dial + 5 tiers) ✓ / `density.*` (dial + 3 tiers) ✓ / `breakpoint.*` (5 stops) ✓. iter-63 File List confirms 90-base-token emission.
  - **Leaf-value formatting** per § Task 2: OKLCH literals pass-through unchanged (`oklch(54% 0.18 245)`); dimension literals (`16px`) pass-through; duration literals (`200ms`) pass-through; number literals emitted as-is (`1`, `0.875`); fontFamily comma-separated strings pass-through. No unit-stripping, no value transformation, no hex conversion.
  - **Output ordering** (determinism-critical): canonical source order preserved per V8 ES2015 `JSON.parse` iteration rules. Determinism smoke 1 byte-identical round-trip proves ordering stability across runs.
- **Known scope-carve-out variances (pre-documented, not gaps):**
  - **Emitter-owned canonical byte-format** for emitted CSS (iter-63 Debug Log `.prettierignore` addition). Prettier would normalize OKLCH decimal `0.20 → 0.2` and attribute-selector quotes `"dark" → 'dark'`; emitter output declared canonical via `.prettierignore`.
  - **AC 3 prose example `var(--surface-raised)` (epics.md:1002) vs Task 2 kebab-rule output `var(--color-surface-raised)`** — Layer 4 drift identified at iter-60 drafting + resolved at § AC 3 "Known concrete pairs" table (full-path form wins; epic-prose example is descriptive shorthand, not normative).
- **Gaps:** No automated CSS-var-enumeration snapshot test (would need: Vitest `test('emitted CSS vars match tokens.json leaf enumeration', () => ...)` post-Story-1.16). No automated alias-flatten correctness probe (would need: assertion that every emitted `var()` reference is absent from `--color-*` values). Leaf enumeration + alias correctness rely on hand-reading at authoring time + iter-61 pre-dev SM + iter-63 smoke-2 value-propagation + CR adversarial pass.
- **Recommendation:** Defer CSS-var enumeration + alias-flatten probes to **Story 1.16** (test-runner landing). **Story 1.13** source-output sync gate re-exercises AC 3 integration at every pre-commit (re-runs emitter in `--check` mode + diffs vs checked-in `packages/ui/src/tokens.css`). CR adversarial pass is the agreed substrate-time backstop. WAIVED.

---

#### AC-4: Tailwind v4 preset — flat-kebab keys under `theme.extend.{colors,fontSize,fontFamily,spacing,borderRadius,transitionDuration,motionScale,densityScale,screens}`; base-only mode (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.13 source-output sync gate + Story 1.16 test-runner + Epic 7 Story 7-1 consumer-side integration)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence):**
  - **Named export `keelTailwindPreset` present** (iter-63 File List + Completion Notes): single `export const keelTailwindPreset = { theme: { extend: { ... } } } as const;` per § Task 3 specification. `packages/ui/tailwind.preset.ts` lives at package root (sibling to `tokens.json` + `tokens.schema.json` — NOT under `src/`) per § Task 3 scope carve-out.
  - **Flat-kebab key shape under `theme.extend.colors`** per § AC 4 scope carve-out: `'surface-raised'` (group-stripped from `color.surface.raised`), `'status-success-fg'`, `'accent-500'`, `'state-in-progress'` etc. — NO nested objects. Group prefix `color.` stripped since keys live under `colors` already; divergence from CSS full-path naming per AC 3 is intentional (per carve-out rationale — matches Tailwind class-name generation vocabulary `bg-surface-raised`, `text-status-success-fg`, `border-accent-500`).
  - **9 `theme.extend.*` namespaces populated** (iter-63 Completion Notes AC 4): `colors` (all color groups flat-stripped) / `fontSize` (type.* → tuples with lineHeight default) / `fontFamily` (font.sans + font.mono) / `spacing` (space.* px strings) / `borderRadius` (radius.* px strings + `'full': '9999px'`) / `transitionDuration` (motion tier durations in `ms` strings) / `motionScale` (custom — motion.scale dial unitless) / `densityScale` (custom — density tiers + dial) / `screens` (breakpoint.* px strings).
  - **Color values land as OKLCH literals** (flattened per § AC 3), NOT as `var(--color-*)` references per § AC 4 scope carve-out. Rationale: Tailwind JIT consumes at consumer-build time; literals avoid dual-source-of-truth at source-output-sync gate time (Story 1.13).
  - **Type-shape compatibility** (§ AC 4 scope carve-out): `as const` narrowing; no `import type { Config } from 'tailwindcss'` in the emitted file (Tailwind NOT a `@keel/ui` devDependency at Story 1.12 time per § Task 1 stance). Consumer apps at Epic 7 Story 7-1 time will import Tailwind types at their own build. `pnpm -w typecheck` ✓ — emitted TS preset passes strict TS under shared tsconfig.
  - **Base-only mode overlay** (no dark-mode values in preset per § Task 3 mode-overlay rule): dark consumed via consumer-side `dark:` class modifier + CSS-var cascade from `tokens.css` `[data-theme="dark"] { }` block. Preset carries only base-mode literal values.
  - **Non-color group mapping verified** per § Task 3 (iter-63 Completion Notes AC 4): `type.xl2` → `fontSize.xl2` tuple `[value, { lineHeight: '1.5' }]` (Python-identifier-safe name `xl2` preserved in Tailwind since Tailwind accepts arbitrary strings); `density.*` under custom `densityScale` namespace (Tailwind has no native density vocabulary; custom key preserves grep-visibility).
- **Known scope-carve-out variances (pre-documented, not gaps):**
  - **Emitter-owned canonical byte-format** for emitted Tailwind preset (iter-63 Debug Log `.prettierignore` addition). Prettier would convert TS double-quotes → single-quotes; emitter output declared canonical.
- **Gaps:** No automated type-shape compatibility test (`expectType<Partial<Config>['theme']['extend']>(keelTailwindPreset.theme.extend)`) — would need Vitest + Tailwind v4 type import at Story 1.16. No automated flat-kebab key enumeration assertion (every `colors` key matches `^[a-z][a-z0-9-]*$` and every key flat-strips the group prefix). Consumer-build JIT verification lands at Epic 7 Story 7-1 (positive-space integration — preset-shape violations break consumer build loudly).
- **Recommendation:** Defer type-shape + key-enumeration probes to **Story 1.16**. Consumer-side verification lands at **Epic 7 Story 7-1** when `apps/web` imports `@keel/ui/tailwind.preset` and Tailwind JIT generates utility classes. **Story 1.13** source-output sync gate re-exercises AC 4 at every pre-commit. CR adversarial pass is the agreed substrate-time backstop. WAIVED.

---

#### AC-5: TUI theme.py — SimpleNamespace base + `theme.dark` overlay; snake_case slugs; Python-stdlib-only; breakpoint parity emitted (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16 test-runner + Epic 3 Story 3.33 consumer-side integration)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence):**
  - **Module-level `theme = SimpleNamespace(...)` shape** per § Task 4 + § AC 5 scope carve-out (iter-63 File List + Completion Notes AC 5): single root + 9 nested namespaces — `theme.colors`, `theme.type`, `theme.font`, `theme.space`, `theme.radius`, `theme.motion`, `theme.density`, `theme.breakpoint`, `theme.dark.colors`. Preferred SimpleNamespace default chosen over dataclass / named-tuple / frozen-namespace; zero-cost attribute access.
  - **Snake_case slugs** per § Task 4: `color.surface.raised` → `surface_raised`; `color.status.success.fg` → `status_success_fg`; `color.accent.500` → `accent_500` (digit-suffix valid); `color.state.in-progress` → `state_in_progress` (segment-local hyphen→underscore post-join transform — SM-2 iter-61 PATCH; Python identifier edge case; CSS + Tailwind preserve the `-`, Python-only substitution).
  - **Digit-segment handling** per § Task 4 + iter-63 Completion Notes AC 5: `type.2xl` → `type_xl2` (leading-digit segment swap); `breakpoint.2xl` → `breakpoint_xl2` same rule. Spot-check `theme.type.xl2 == '24px'` passed; spot-check `theme.breakpoint.xl2 == 1536` (int, not string — breakpoint values are unitless int per TUI non-use per § AC 5 scope carve-out) passed.
  - **Leading-digit prefix handling** per iter-63 Completion Notes AC 5: `space.0` → `_0` (underscore prefix for standalone digit segments); spot-check `theme.space._0 == '0px'` passed.
  - **Python-stdlib-only imports** per § AC 5 scope carve-out: `from types import SimpleNamespace` is the sole import in emitted `theme.py`. Zero `numpy` / `colour` / `pydantic` / `attrs` / `dataclasses` imports. Verified by inline `python -c "from theme import theme; print(theme.colors.surface_raised)"` at iter-63 time — imports resolve without `pip install`.
  - **`theme.dark` nested overlay mirrors tokens.json `$modes.dark` sparse shape** (iter-63 Completion Notes AC 5 spot-check): only surface/text/border/accent.fg/status.bg variants present; `theme.dark.colors.surface_default` resolves to dark-mode neutral `oklch(8% 0 0)` (via alias-flatten — `$modes.dark.surface.default = {color.neutral.950}` → `oklch(8% 0 0)`).
  - **8-group parity** per § AC 5 scope carve-out + `architecture.md:90` cross-runtime invariant: `theme.colors`, `type`, `font`, `space`, `radius`, `motion`, `density`, `breakpoint` all emitted. `breakpoint.*` emitted as `int` constants (px values without unit) for TUI-consumption future-proofing (Textual doesn't use breakpoints — dead-weight attribute kept for stable-ID invariance per architecture.md:90 cross-runtime rule).
  - **Value types preserved** per § Task 4 shape rule: `$type: number` source entries emit as Python `int`/`float` literals (`theme.motion.scale == 1`, `theme.density.comfortable == 1.125`); `$type: duration` / `dimension` / `color` / `fontFamily` entries emit as Python string literals (OKLCH pass-through, `px`/`ms` preserved).
  - **Sibling zero-byte `packages/devbox/tui/__init__.py`** (iter-63 File List): emitted at first run (idempotent — not rewritten on re-run per iter-63 Debug Log); makes `from theme import theme` importable via Python-package semantics.
  - **OKLCH → pass-through (not hex conversion)** per § AC 5 scope carve-out default: Textual ≥ 0.80 supports `oklch(...)` natively; emitter emits OKLCH string literals unchanged. Re-litigation deferred to Story 3.33 TUI consumption time.
- **Known scope-carve-out variances (pre-documented, not gaps):**
  - **`*.py` already ignored by prettier** (no additional `.prettierignore` entry needed — Python files are not prettier-targeted).
  - **Zero-byte `__init__.py` emission** (iter-63 Debug Log): idempotent — emitter checks for file existence before writing; no-ops on re-run. Preserves determinism smoke 1 byte-identical round-trip invariant (the file isn't rewritten, so `git status` stays clean).
- **Gaps:** No automated Python import-resolvability test (would need pytest harness at Story 1.16). No automated SimpleNamespace attribute enumeration vs tokens.json leaf enumeration (diff test — deferred to Story 1.16). Attribute-access correctness relies on iter-63 inline spot-checks + CR adversarial pass + Epic 3 Story 3.33 consumer-side integration.
- **Recommendation:** Defer Python theme.py import-resolvability + attribute-enumeration probes to **Story 1.16**. Consumer-side verification lands at **Epic 3 Story 3.33** when Ralph TUI imports `from packages.devbox.tui.theme import theme` — missing attributes break TUI boot loudly. CR adversarial pass + iter-63 inline spot-checks are the agreed substrate-time backstop. WAIVED.

---

#### AC-6: FR67-adapted purity contract — no network / no time / no RNG / no env / single source read / bounded writes; Epic 13 reproducibility forward-reference (P2)

- **Coverage:** NONE ❌ (substrate-verified via code inspection + AC 2 determinism smokes; runner-hosted coverage deferred to Story 1.16)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence):**
  - **Zero network** (iter-63 code inspection): emitter imports `node:fs` / `node:path` / `node:url` / `node:crypto` / `node:child_process` only — zero `fetch` / `https.request` / DNS / `http` module references. Confirmed by full-source grep at iter-63.
  - **Bounded filesystem reads**: emitter reads exactly `packages/ui/tokens.json` (one `readFileSync`). Optional schema validation (§ AC 6 carve-out default-skip) NOT implemented — schema file NOT read at Story 1.12 time.
  - **Bounded filesystem writes**: three target outputs + one optional sibling `packages/devbox/tui/__init__.py` (idempotent — only written if absent) + one `mkdirSync` for new `packages/devbox/tui/` directory. No temp files, no `.cache/` writes, no `git` mutations, no `npm` side effects.
  - **Zero time-dependent values** (iter-63 code inspection): emitter source contains zero `Date.now()` / `new Date()` / `process.hrtime()` references. Sole time-adjacent value is the provenance-header source SHA — resolved via `git log -1 --format=%h --abbrev=12 -- <path>` (deterministic from committed git state) with `uncommitted-<content-sha256-16>` fallback (deterministic from source content).
  - **Zero RNG**: emitter source contains zero `Math.random()` / `crypto.randomBytes()` / `crypto.randomInt()` calls. `crypto` import is used only for sha256 computation in the uncommitted-state fallback path — deterministic function of source content.
  - **Zero `process.env` reads** (iter-63 code inspection): emitter source contains zero `process.env` references. No feature-flag, no config-override via env.
  - **Determinism smoke 1 (AC 2) proves byte-identical round-trip** → purity holds in practice. Two back-to-back runs with zero source changes → matching sha256sum across all three outputs.
  - **Determinism smoke 2 (AC 2) proves same-input → same-output contract**: edit source → outputs change → revert source → outputs match pre-edit hashes byte-for-byte. Proves purity modulo source content.
  - **`pnpm exec prek run --all-files` 3/3 hooks Pass** (iter-63 Completion Notes) — prettier-format + typecheck + lint all green post-emit; implicit evidence of idempotent re-emission (re-emit produces zero diff → zero pre-commit churn).
  - **Epic 13 forward-reference** (§ AC 6 scope carve-out): CI enforcement lands at Stories 13-1 / 13-2 (13 epics downstream). Forward-contract only at Story 1.12 — emitter must SURVIVE Epic 13's content-hash-diff step on landing day. Current byte-identical round-trip smoke is the substrate-level analogue; substrate evidence suggests the emitter will survive (smoke 1 + smoke 2 both green).
- **Known scope-carve-out variances (pre-documented, not gaps):**
  - **Gamut-mapping OPT-OUT default** per § AC 6 scope carve-out (iter-63 Debug Log — NOT implemented at Story 1.12 time). OKLCH literals with slightly-negative linear-RGB components (`status.warning.fg` hue 75, `status.error.fg` hue 25, `status.critical.fg` hue 15) emit as-is; browser clipping accepted; WCAG-AA contrast gate is Story 1.13 scope. Re-defer forecast to Story 1.13 at iter-66 CR (carry-forward from iter-59 CR defer #5).
  - **Shadow-machinery EXPLICIT OUT OF SCOPE** per § AC 6 scope carve-out. Requires source mutation of Story-1.11-frozen `packages/ui/tokens.json` which is outside Story 1.12 authority. Carry-to a new Story-1.17-TBD follow-up that first adds shadow tokens to source (carry-forward from iter-59 CR defer #4).
- **Gaps:** No automated purity-sandbox test (deny network + time + RNG + env via runtime proxy + assert emitter still succeeds) — would need Node `vm` or a test-harness proxy at Story 1.16. Current substrate evidence relies on code inspection + AC 2 determinism smokes (which are empirical rather than enforced sandbox). **Adversarial coverage is the story-declared substitute** — Story 1.12 § Testing Standards:246 affirmatively delegates AC 2 + AC 6 adversarial coverage to `/bmad-code-review (args: '2')` Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out; CR iteration lands at iter-66 per FR14n lifecycle.
- **Recommendation:** Defer runner-hosted purity-sandbox probe to **Story 1.16**. Code-inspection + AC 2 determinism smokes + `/bmad-code-review` adversarial fan-out (§ Testing Standards:246 spec-declared CR-substitution) are the agreed substrate-time evidence. **Epic 13 reproducibility CI** is the load-bearing forward-enforcement layer. WAIVED.

---

### Coverage Gap Analysis

#### Critical Gaps (P0 Uncovered)

None. P0 requirements total zero.

#### High Priority Gaps (P1 Partially Covered / Uncovered)

None. P1 requirements total zero.

#### Medium Priority Gaps (P2 Partial / Uncovered)

- AC-1 (provenance header + output paths + emit command) — deferred to Story 1.16 test-runner. Substrate-verified via iter-63 dev-story execution + CR adversarial pass.
- AC-2 (determinism — byte-identical round-trip) — SUBSTRATE_VERIFIED end-to-end via Task 6 two determinism smokes. Runner-hosted coverage deferred to Story 1.16; negative-space cycle-input probe deferred to Story 1.13 schema-validation gate.
- AC-3 (web CSS custom properties) — deferred to Story 1.13 source-output sync gate (re-exercises integration at every pre-commit) + Story 1.16 test-runner (snapshot + alias-flatten probes).
- AC-4 (Tailwind preset shape) — deferred to Story 1.13 source-output sync gate + Story 1.16 test-runner + Epic 7 Story 7-1 consumer-side integration (Tailwind JIT verifies preset shape at consumer build).
- AC-5 (TUI theme.py shape) — deferred to Story 1.16 test-runner + Epic 3 Story 3.33 consumer-side integration (Ralph TUI import verifies attribute access).
- AC-6 (FR67-adapted purity) — substrate-verified via code inspection + AC 2 determinism smokes. Runner-hosted purity-sandbox deferred to Story 1.16; **adversarial coverage is the story-declared substitute** (§ Testing Standards:246 spec-declared CR-substitution via `/bmad-code-review`). Epic 13 reproducibility CI is the load-bearing forward-enforcement.

All P2 gaps are waived per § Rationale below.

---

### Rationale

Story 1.12 is a **substrate+tooling emitter** story at a pre-test-runner stage. It:

1. Authors a pure TypeScript emitter at `packages/ui/scripts/generate-tokens.ts` (274 lines post-prettier; `tsx@4.21.0` devDep; node stdlib only — `fs` + `path` + `url` + `crypto` + `child_process`).
2. Emits three byte-stable outputs from the Story 1.11 DTCG source:
   - `packages/ui/src/tokens.css` (web CSS custom properties; `:root { }` base + `[data-theme="dark"] { }` overlay; kebab full-path var naming; alias-flatten at emit).
   - `packages/ui/tailwind.preset.ts` (Tailwind v4 preset; `keelTailwindPreset` named export with 9 `theme.extend.*` namespaces; flat-kebab keys; base-only mode).
   - `packages/devbox/tui/theme.py` (Textual Python theme; `SimpleNamespace` base + `theme.dark` overlay; snake_case slugs with segment-local hyphen + digit-segment transforms; Python-stdlib-only; sibling zero-byte `__init__.py`).
3. Registers one new manifest entry `INV-tokens-emitter` (raw array 13 → 14 entries; contentHash `6ee7731efb65d1cecd9aa35a51d377cf6a25c3543dc8433f74a761cc71442796`) + `INVARIANTS.md` new section with column-0 anchor bullet.

The story's § Testing Standards (story lines 243–246) explicitly declares that no test runner is wired at Story 1.12 time (test framework landing is Story 1.16). Substrate verification runs through: (a) `pnpm -w {typecheck,lint,build,format:check}` quality-gate bundle + prek hooks (all green at iter-63); (b) Task 6 two determinism smokes (byte-identical round-trip + source-change propagation with revert-to-baseline) — strongest substrate evidence of the six ACs; (c) `pnpm keel-invariants:check` clean-path exit 0 for the new manifest entry; (d) `/bmad-code-review (args: '2')` adversarial coverage (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out) for AC 2 determinism + AC 6 purity per story line 246 **spec-declared CR-substitution clause**. Per-AC automated test coverage is explicitly deferred to two downstream stories:

- **Story 1.13 (token quality gates)** — pre-commit schema-validation (AC 1 + Story 1.11 AC 1 integration), pre-commit WCAG-AA contrast gate (Story 1.11 + Story 1.12 dark-mode + Story 1.12 gamut-mapping absorption), **pre-commit source-output sync gate** (re-runs emitter in `--check` mode + diffs vs checked-in outputs — covers AC 3 + AC 4 + AC 5 integration end-to-end at every pre-commit). These are the runtime-enforcement probes that ATDD red-phase would produce at Story 1.12 time — deferred to Story 1.13 per explicit epic sequencing (`epics.md:1018-1046`).
- **Story 1.16 (CI pipeline + test runner)** — red-phase per-AC probes if still deemed value-adding after Story 1.13 integration lands: AC 1 provenance-header snapshot + output-path enumeration; AC 2 byte-identical round-trip in a test harness (promotes substrate smokes to gated tests); AC 3 CSS-var enumeration diff test; AC 4 Tailwind preset type-shape + key enumeration test; AC 5 Python SimpleNamespace attribute enumeration test; AC 6 purity sandbox (deny network + time + RNG + env via runtime proxy).

Story 1.9 sync-gate runtime (`pnpm keel-invariants:check`) already enforces `INV-tokens-emitter` at every pre-merge check (exit 1 on any drift between `packages/keel-invariants/src/invariants.manifest.ts` and checked-in `packages/ui/scripts/generate-tokens.ts`). This covers the **structural-registration half** of AC 1 at runtime — no additional story-internal coverage needed.

The **determinism half of AC 2 is substrate-verified end-to-end** via iter-63 Task 6 two smokes — byte-identical round-trip across two back-to-back runs (CSS `4b59cb67...` / Tailwind `c7bd57fa...` / Python `7776b448...` matching sha256sum; all three outputs) + source-change propagation (targeted `sed -i` edit on `color.accent.500` 54%→55%; value reaches all three targets + downstream aliases via multi-hop DFS flattening; revert via `git checkout --` restores byte-identical run-1 baseline). These five consecutive byte-identical runs (smoke 1 run 1 + run 2 + smoke 2 edited + smoke 2 reverted + final verify) provide the strongest substrate evidence of the six ACs.

The deterministic FAIL signal from the rule engine (`overall_coverage_actual: 0% < overall_coverage_minimum: 80%`) is a structural false-positive: forcing automated per-AC unit tests on a substrate+tooling emitter story at a pre-test-runner stage inverts the architecture contract (substrate emit is validated by Zod at manifest import + by `pnpm keel-invariants:check` at every pre-merge + by Story 1.13 source-output sync gate at every pre-commit + by Epic 13 reproducibility CI at CI-time + by consumer-side Epic 7 / Epic 3 / Epic 12 integration — not by Story 1.12-internal unit tests). Double-gating delays Epic 1 substrate completion without risk reduction.

Per `.ralph/@plan.md` Story 1.12 FR14n lifecycle + RALPH.md 2026-04-21 signposts, the ATDD red-phase step for this story was **skipped at iter-62** on the hybrid-ground-(c) variant-(ii)+(iii) rationale (§ ATDD Skip Rationale in @plan.md): (a) Task 6 determinism smokes directly probe AC 2 at shell level + substrate verification covers all six ACs; (b) no test runner at Story 1.12 time (Story 1.16 scope); (c) hybrid variant-(ii) + variant-(iii): Story 1.13 owns the pre-commit schema/contrast/sync gates (runtime-enforcement probes deferred per epic sequencing) AND story § Testing Standards:246 affirmatively declares `/bmad-code-review` adversarial fan-out as CR-substitution for AC 2 + AC 6 coverage. This trace-gate decision mirrors the iter-62 ATDD-skip decision — **sixth cumulative WAIVED precedent** for contract-only / contract-populator / data-only / emitter+tooling substrate stories (Stories 1.7 + 1.8 + 1.9 + 1.10 + 1.11 + 1.12). Each successive WAIVED application extends the same load-bearing hybrid-ground-(c) rationale; Story 1.12 adds NEW ground (c) variant-(ii)+(iii) hybrid emitter coverage per iter-62 lesson (bare variant (ii) alone or variant (iii) alone is weaker than Story 1.9's variant-(iii)-solo; prefer hybrid when spec structure supports it — Story 1.12 does).

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

- No auth / payment / PII / encryption changes in Story 1.12. Not applicable.

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

- **Waiver Reason**: Story 1.12 is a substrate+tooling emitter story at a pre-test-runner stage. Per-AC automated coverage is explicitly deferred to Story 1.13 (pre-commit schema-validation + WCAG-AA contrast gate + **source-output sync gate** — covers AC 3 + AC 4 + AC 5 integration end-to-end at every pre-commit, replacing substrate-level smoke evidence with committed gates) + Story 1.16 (test-runner landing — red-phase unit tests + purity sandbox + snapshot probes if still deemed value-adding after Story 1.13 integration lands). Story § Testing Standards:246 **affirmatively declares spec-declared CR-substitution** for adversarial AC 2 determinism + AC 6 purity coverage via `/bmad-code-review (args: '2')` Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out (hybrid ground-(c) variant-(ii)+(iii) — see RALPH.md 2026-04-21 Story 1.12 iter-62 signpost).
- **Waiver Approver**: Story 1.12 itself (stakeholder-authored § Testing Standards story line 243–246 + inline AC scope carve-outs at story lines 24, 38, 48, 50, 58, 66, 88, 97, 99, 101, 103). See also: `.ralph/@plan.md` iter-62 FR14n ATDD-skip rationale and RALPH.md Signposts 2026-04-21 (**sixth cumulative application** of FR14n ATDD-skip clause — Stories 1.7/1.8/1.9/1.10/1.11/1.12).
- **Approval Date**: 2026-04-21 (story drafted iter-60, pre-dev SM review iter-61, ATDD-skip iter-62, dev-story iter-63, trace iter-64 — all within the same ISO day).
- **Waiver Expiry**: expires when **Story 1.13** pre-commit gates land (covers AC 3 + AC 4 + AC 5 integration — replaces substrate-level smoke evidence with committed source-output sync gate) + **Story 1.16** test-runner (optional per-AC unit + snapshot + purity-sandbox probes if still valued). AC 2 determinism is SUBSTRATE_VERIFIED end-to-end via Task 6 two smokes + Story 1.13 source-output sync will re-exercise byte-identical-round-trip at every pre-commit. AC 6 purity is covered by code-inspection + AC 2 smokes + `/bmad-code-review` spec-declared CR-substitution + Epic 13 reproducibility CI forward-enforcement.

**Monitoring Plan**:

- Prettier format-check catches accidental whitespace / formatting drift in `packages/ui/scripts/generate-tokens.ts` (emitter source) at pre-commit (Story 1.4 substrate). Three generated outputs are `.prettierignore`d (emitter-owned canonical byte-format decision per iter-63 lesson).
- Story 1.9 sync-gate re-runs at every pre-commit via Story 1.5's prek pipeline: re-hashes the emitter sourcePath + cross-checks INVARIANTS.md anchor + drift → exit 1 hard fail. The new `INV-tokens-emitter` entry is automatically picked up by the existing gate logic.
- Story 1.12 emitter outputs are consumed positive-space by Epic 7 Story 7-1 (Tailwind preset + CSS vars) + Epic 3 Story 3.33 (TUI theme) + Epic 12 shape-aware templates — any missing semantic token / output-shape violation breaks consumer build / boot loudly.
- Story 1.13 pre-commit gates close the loop at pre-commit once they land: schema-validation re-exercises AC 1 provenance + AC 6 source-read contract; WCAG-AA contrast re-exercises AC 3 dark-mode cascade; source-output sync re-runs emitter in `--check` mode + diffs vs committed outputs (covers AC 3 + AC 4 + AC 5 + AC 2 determinism + AC 6 purity at every pre-commit).
- Epic 13 reproducibility CI will re-exercise AC 2 byte-identical round-trip + AC 6 FR67-adapted purity at CI time (content-hash-diff check on emitter outputs — Story 1.12 emitter must survive on Epic 13 landing day).

**Remediation Plan**:

- **Fix Target**: Story 1.13 (pre-commit quality gates: schema-validation + WCAG-AA contrast + source-output sync for AC 3/4/5 integration) + Story 1.16 (test-runner wiring for optional per-AC unit + snapshot + purity-sandbox probes) + Epic 7 Story 7-1 (Tailwind preset consumer verification) + Epic 3 Story 3.33 (TUI theme.py consumer verification) + Epic 13 Stories 13-1/13-2 (reproducibility CI forward-enforcement).
- **Due Date**: per epic sprint-plan (not a blocker for Story 1.12 merge). Epic 1 closure (after Story 1.16) lands pre-Epic-7 so consumer-side integration opens immediately.
- **Owner**: Epic 1 substrate team (Ralph loop).
- **Verification**: Story 1.13's pre-commit CI check turning green is the first downstream verification (AC 3/4/5 integration end-to-end). Epic 7 Story 7-1 consumer build turning green is the second (positive-space AC 4 Tailwind preset shape verification + AC 3 CSS-var consumption). Epic 3 Story 3.33 TUI boot turning green is the third (AC 5 Python theme.py import verification). Epic 13 reproducibility CI is the fourth (AC 2 + AC 6 forward-enforcement). Story 1.16 optionally adds per-AC red-phase probes.

**Business Justification**: Forcing automated per-AC tests on a substrate+tooling emitter story at a pre-test-runner stage inverts the architecture contract (substrate emit is validated by Zod at manifest import + by `pnpm keel-invariants:check` at every pre-merge + by Story 1.13 source-output sync gate at every pre-commit + by Epic 13 reproducibility CI at CI time + by consumer-side Epic 7 / Epic 3 / Epic 12 integration — not by Story 1.12-internal unit tests). Double-gating delays Epic 1 substrate completion without risk reduction — Story 1.13 IS the AC 3/4/5 integration test, Story 1.9 sync-gate IS the AC 1 runtime registration test, Epic 7/3/12 consumers ARE the positive-space AC 3/4/5 shape tests, Epic 13 CI IS the AC 2 + AC 6 forward-enforcement, and `/bmad-code-review` adversarial fan-out IS the substrate-time AC 2 + AC 6 backstop (story § Testing Standards:246 affirmatively declares this CR-substitution). Authoring dead-code red-phase probes before Story 1.16 lands a runner wastes iteration budget.

---

#### Critical Issues (For FAIL or CONCERNS)

None. The FAIL signal from the deterministic rule engine is waived (see above).

---

### Gate Recommendations — For WAIVED Decision 🔓

1. **Deploy with Business Approval**
   - Waiver documented above.
   - Story 1.12's PR #226 can proceed through the remaining FR14n lifecycle states: `traced` → `/bmad-create-story (args: "review")` post-dev SM-verify → `sm-verified` → `/bmad-code-review (args: "2")` → `done`. PR #226 stays Draft through Epic 1 closure (Stories 1.13–1.16 remain); Draft→Open + EPIC_DONE halt land after Story 1.16.
2. **Aggressive Monitoring**
   - Prettier format-check + TypeScript strict mode + ESLint at pre-commit (already green — Stories 1.3/1.4 substrates); `.prettierignore` governs emitter-owned canonical byte-format for generated outputs.
   - Story 1.9 sync-gate re-runs at every pre-commit; automatically picks up Story 1.12's new manifest entry (`INV-tokens-emitter`).
   - Code-review of any future PR that edits `packages/ui/scripts/generate-tokens.ts` — reviewer must verify: (a) emitter stays pure (no network / no time / no RNG / no env reads); (b) output paths remain the three canonical locations; (c) determinism is preserved (byte-identical round-trip smoke still passes locally); (d) `EMITTER_VERSION` bump semantics are respected (any byte-format change without version bump is a silent algorithm-drift signal — caught by Story 1.13 source-output sync gate).
3. **Mandatory Remediation**
   - Story 1.13's pre-commit gates must land before the waiver expires. Epic 1 sprint-status already tracks 1.12 → 1.13 → 1.14 → 1.15 → 1.16 as the remaining closure sequence.
   - Epic 13 reproducibility CI must be architected to consume `packages/ui/scripts/generate-tokens.ts` as a reproducibility input — Story 1.12 emitter is a positive-space reproducibility target.

---

### Next Steps

**Immediate Actions** (this iteration):

1. Commit this traceability matrix + sibling JSONs under `_bmad-output/test-artifacts/traceability/`.
2. Update `.ralph/@plan.md`: mark NOW done, transition Story State `in-dev → traced`, move next QUEUE item (post-dev SM review via `/bmad-create-story (args: "review")`) to NOW.
3. Push + exit.

**Follow-up Actions** (Story 1.12 remaining lifecycle):

1. Story State `traced` → run `/bmad-create-story (args: "review")` post-dev SM verification (requirements-satisfaction gate).
2. On `sm-verified`, run `/bmad-code-review (args: "2")` for adversarial triage (spec-declared CR-substitution for AC 2 + AC 6 per § Testing Standards:246).
3. On `done`, move to Story 1.13 (token quality gates — schema-validation + WCAG-AA contrast + source-output sync).

**Stakeholder Communication**:

- Notify PM / SM / Dev lead: **Story 1.12 trace GATE=WAIVED** (substrate+tooling emitter story; coverage enforcement deferred to Story 1.13 pre-commit gates [source-output sync covers AC 3/4/5 integration end-to-end] + Story 1.16 test-runner [optional per-AC probes] + Epic 13 reproducibility CI [forward-enforcement of AC 2 + AC 6] per § Testing Standards + inline AC scope carve-outs; substrate verification is STRONGEST of the six cumulative WAIVED precedents — all quality gates green + Task 6 two determinism smokes end-to-end [byte-identical round-trip + source-change propagation with revert-to-baseline] + sync-gate clean-path exit 0 on first invocation).

---

## Integrated YAML Snippet (CI/CD)

```yaml
traceability_and_gate:
  # Phase 1: Traceability
  traceability:
    story_id: '1.12'
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
      - 'AC-1 substrate-verified via iter-63 dev-story execution (three output paths + provenance header shape + one-line stdout summary); defer snapshot + path-enumeration probes to Story 1.16'
      - 'AC-2 SUBSTRATE_VERIFIED end-to-end via Task 6 two determinism smokes (byte-identical round-trip + source-change propagation with revert-to-baseline); strongest substrate evidence of the six ACs; defer runner-hosted harness to Story 1.16; defer negative-space cycle-input probe to Story 1.13 schema-validation gate'
      - 'AC-3 substrate-verified via emitted packages/ui/src/tokens.css (90 base + 16 dark overrides; kebab full-path naming; alias-flatten at emit; all 8 token groups covered); defer CSS-var enumeration + alias-flatten probes to Story 1.16; Story 1.13 source-output sync gate re-exercises at every pre-commit'
      - 'AC-4 substrate-verified via emitted packages/ui/tailwind.preset.ts (keelTailwindPreset named export; 9 theme.extend.* namespaces; flat-kebab keys; base-only mode); defer type-shape + key-enumeration probes to Story 1.16; Epic 7 Story 7-1 provides positive-space consumer integration'
      - 'AC-5 substrate-verified via emitted packages/devbox/tui/theme.py (SimpleNamespace base + theme.dark overlay; snake_case slugs with segment-local + digit-segment transforms; Python-stdlib-only); defer import-resolvability + attribute-enumeration probes to Story 1.16; Epic 3 Story 3.33 provides positive-space consumer integration'
      - 'AC-6 substrate-verified via code inspection + AC 2 determinism smokes + /bmad-code-review spec-declared CR-substitution (story § Testing Standards:246); defer runner-hosted purity-sandbox to Story 1.16; Epic 13 reproducibility CI is the load-bearing forward-enforcement'

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
      test_results: 'substrate quality-gate bundle (typecheck 16/16 + lint 16/16 + build 16/16 with scoped @keel/keel-invariants rebuild + format:check clean + prek 3/3 hooks Pass) + Task 6 two determinism smokes (byte-identical round-trip: CSS 4b59cb67... / Tailwind c7bd57fa... / Python 7776b448... matching sha256sum; source-change propagation: color.accent.500 54%→55% value-propagates via alias-downstream DFS + revert via git checkout -- restores byte-identical run-1 baseline) + pnpm keel-invariants:check clean-path exit 0 — Story 1.12 Task 6 Completion Notes iter-63'
      traceability: '_bmad-output/test-artifacts/traceability/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md'
      nfr_assessment: 'inferred_from_story_dev_notes'
      code_coverage: 'not_applicable'
    next_steps: 'Proceed to post-dev SM verify → code review per Ralph lifecycle matrix.'
    waiver:
      reason: 'Substrate+tooling emitter story; per-AC automated coverage deferred to Story 1.13 (pre-commit schema-validation + WCAG-AA contrast + source-output sync gates covering AC 3/4/5 integration) + Story 1.16 (test-runner for optional per-AC + purity-sandbox probes) + Epic 13 reproducibility CI (AC 2 + AC 6 forward-enforcement) per § Testing Standards + inline AC scope carve-outs. FR14n ATDD-skip (iter-62 hybrid-ground-(c) variant-(ii)+(iii)) precedent is load-bearing (SIXTH cumulative application); story § Testing Standards:246 affirmatively declares /bmad-code-review adversarial fan-out as CR-substitution for AC 2 + AC 6 coverage.'
      approver: 'Story 1.12 § Testing Standards + inline AC scope carve-outs (stakeholder-authored)'
      expiry: 'deferred (expires when Story 1.13 pre-commit gates land for AC 3/4/5 integration; AC 2 + AC 6 also covered by Epic 13 reproducibility CI forward-enforcement; AC 1 manifest registration already covered by Story 1.9 sync-gate runtime)'
      remediation_due: 'Story 1.13 (pre-commit quality gates) + Story 1.16 (test-runner wiring) + Epic 7 Story 7-1 (Tailwind consumer) + Epic 3 Story 3.33 (TUI consumer) + Epic 13 Stories 13-1/13-2 (reproducibility CI)'
```

---

## Related Artifacts

- **Story File:** `_bmad-output/implementation-artifacts/1-12-token-emitter-pipeline-web-css-tailwind-preset-tui-theme.md`
- **Implementation Artefacts:**
  - `packages/ui/scripts/generate-tokens.ts` (NEW — Task 1 emitter source; 274 lines post-prettier; pure TS; `node:*` stdlib only).
  - `packages/ui/src/tokens.css` (NEW — Task 2 emitted output; 118 lines; `:root { }` base + `[data-theme="dark"] { }` overlay; 90 base + 16 dark overrides).
  - `packages/ui/tailwind.preset.ts` (NEW — Task 3 emitted output; 119 lines; `keelTailwindPreset` named export; 9 `theme.extend.*` namespaces).
  - `packages/devbox/tui/theme.py` (NEW — Task 4 emitted output; 135 lines; SimpleNamespace base + `theme.dark` overlay; Python-stdlib-only).
  - `packages/devbox/tui/__init__.py` (NEW — zero-byte Python package marker; idempotent).
  - `packages/ui/package.json` (MODIFIED — `tsx@4.21.0` devDep + `generate-tokens` script).
  - `packages/keel-invariants/src/invariants.manifest.ts` (MODIFIED — appended `INV-tokens-emitter` entry; raw array grows from 13 → 14).
  - `INVARIANTS.md` (MODIFIED — appended new `### Design-token emitter pipeline (Story 1.12)` section with one column-0 anchor bullet).
  - `.prettierignore` (MODIFIED — added `packages/ui/src/tokens.css` + `packages/ui/tailwind.preset.ts` to ignore list; emitter-owned canonical byte-format decision per iter-63 lesson).
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` (MODIFIED — `1-12-…: ready-for-dev → done`).
  - `pnpm-lock.yaml` (MODIFIED — one-devDep delta; `tsx` + transitive closure `esbuild` + `get-tsconfig` + `tinyglobby` + `fdir` scoped to `@keel/ui`).
- **Agent-readable index (source of truth for the IDs):** `INVARIANTS.md` new Story 1.12 section.
- **Test Design:** not applicable (substrate+tooling emitter story; no test design doc authored).
- **Tech Spec:**
  - `_bmad-output/planning-artifacts/architecture.md` § Design-token ID Pattern (lines 691–695) + § Three-layer invariant pattern (lines 85–90) + § Cross-cutting Design System (lines 1214–1222; variance vs AC 1 carve-out resolved per W1 party-mode amendment precedent) + § Generator Normalization Algorithm (line 440; FR67 purity contract basis).
  - `_bmad-output/planning-artifacts/ux-design-specification.md` § Architecture of the Design System (lines 340–398; UX-DR3 detailed; :362 tailwind.preset.ts path — variance resolved per SM-3 iter-61 DEFER) + § Cross-runtime semantic tokens (line 154).
  - `_bmad-output/planning-artifacts/prd.md` F2 (design-token manifest; line 293) + FR67 (line 27; purity contract) + FR42 / FR43 (INV manifest enforcement).
  - `_bmad-output/planning-artifacts/epics.md` lines 982–1016 (Story 1.12 AC block) + lines 635–666 (Epic 1 W1 party-mode amendment rationale relocating emitter pipeline to Epic 1) + lines 3946–3961 (Epic 7 Story 7-1 consumer) + lines 2925–2950 (Epic 3 Story 3.33 TUI consumer) + lines 1018–1046 (Story 1.13 downstream gates) + lines 1013–1016 (FR67 purity forward-reference).
- **Test Results:** substrate quality-gate bundle (typecheck + lint + build + format:check + prek) + Task 6 two determinism smokes (byte-identical round-trip + source-change propagation with revert-to-baseline) + `pnpm keel-invariants:check` clean-path exit 0 (Story 1.12 Dev Agent Record Completion Notes, iter-63).
- **NFR Assessment:** inferred (not a formal NFR doc); FR67-adapted purity contract substrate-verified at § AC 6 + AC 2 determinism smokes.
- **Test Files:** none (no test runner until Story 1.16).
- **Precedent:**
  - `_bmad-output/test-artifacts/traceability/1-7-*` (Story 1.7 WAIVED — docs-only stage).
  - `_bmad-output/test-artifacts/traceability/1-8-*` (Story 1.8 WAIVED — contract-only; 10-entry manifest shape precedent).
  - `_bmad-output/test-artifacts/traceability/1-9-*` (Story 1.9 WAIVED — sync-gate runtime; 5-smoke-branch evidence precedent).
  - `_bmad-output/test-artifacts/traceability/1-10-*` (Story 1.10 WAIVED — schema + rationale-doc contract; three-smoke-branch evidence precedent).
  - `_bmad-output/test-artifacts/traceability/1-11-*` (Story 1.11 WAIVED — data-authoring / contract-populator; ajv-validate exit 0 + two sync-gate smoke branches + Direction A value population by-inspection).
  - Structural trace-artefact inheritance from Story 1.11 applied (~90% reasoning-cost savings per iter-46 + iter-57 lesson — mechanical adaptation of `substrate_verification` blocks from 4-AC Story 1.11 to 6-AC Story 1.12).

---

## Sign-Off

**Phase 1 — Traceability Assessment:**

- Overall Coverage: 0% (structural; intentional per § Testing Standards)
- P0 Coverage: 100% (vacuously satisfied — no P0 ACs)
- P1 Coverage: 100% (vacuously satisfied — no P1 ACs)
- Critical Gaps: 0
- High Priority Gaps: 0
- Medium Priority Gaps: 6 (all scoped-out to Story 1.13 pre-commit gates + Story 1.16 test-runner + Epic 7 / Epic 3 / Epic 12 consumer-side integration + Epic 13 reproducibility CI forward-enforcement; AC 2 has strongest substrate verification via two determinism smokes end-to-end; AC 6 has spec-declared CR-substitution clause at § Testing Standards:246)

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
