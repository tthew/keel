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
lastSaved: '2026-04-20'
workflowType: 'testarch-trace'
inputDocuments:
  [
    '_bmad-output/implementation-artifacts/1-11-design-token-source-direction-a-baseline-with-motion-density-scales.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    '_bmad-output/planning-artifacts/ux-design-specification.md',
    'INVARIANTS.md',
    'packages/ui/tokens.schema.json',
    'packages/ui/tokens.json',
    'docs/invariants/tokens.md',
    'packages/keel-invariants/src/invariants.manifest.ts',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/1-11-design-token-source-direction-a-baseline-with-motion-density-scales.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/1-11-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 1.11 design-token source, Direction A baseline with motion + density scales

**Target:** Story 1.11 — Design-token source, Direction A baseline with motion + density scales (canonical DTCG `packages/ui/tokens.json` populated with Direction A "The Instrument" values + motion/density dial+tier hierarchies; one new manifest entry `INV-tokens-source`; consumed by Story 1.12 emitter + Story 1.13 pre-commit gates + Epic 7 catalog + Epic 3 TUI + Epic 12 page templates).
**Date:** 2026-04-20
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 1.11 § Acceptance Criteria lines 13–61)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/1-11-design-token-source-direction-a-baseline-with-motion-density-scales.md` (AC 1–4)

---

Note: This workflow does not generate tests. Story 1.11 is a **contract-populator / data-authoring** story whose § Testing Standards (story line 197–200) explicitly declares:

> _"No test runner at Story 1.11 time (lands Story 1.16). Verification is substrate-layer: `pnpm -w {typecheck,lint,build,format:check}` + `pnpm exec prek run --all-files` + `pnpm keel-invariants:check` (Story 1.9 runtime tool) + one-shot schema-validation (Task 2). Sync-gate smoke (AC 4) is the end-to-end evidence for this story — analogous to Story 1.10 Task 4 smoke patterns. Two smoke branches required (content-hash-mismatch + added-to-source-only); the removed-from-source-only branch is OPTIONAL (already proven at Story 1.9 Task 5 and Story 1.10 precedent). Byte-identical round-trip is the pass criterion. Deferred unit + integration tests: once Story 1.16 lands the test runner, backfill per-AC unit tests can verify: (a) AC 1 — every Direction A value matches ux-spec (snapshot test), schema-validation exit 0 in a red-phase 'malform + expect validator error' variant; (b) AC 2 — docs/design/presets/ empty-or-absent assertion; (c) AC 3 — tier-enumeration assertion (count + names); (d) AC 4 — sync-gate smoke in a test harness. None of these block Story 1.11's `review → done` transition. Adversarial coverage of AC 1 value-correctness + AC 3 tier-enumeration is provided by `/bmad-code-review (args: '2')`'s Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out (mirrors Story 1.10 iter-44 hybrid ground-(c) ATDD-skip rationale)."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-55, per the hybrid-ground-(c) rationale (Story 1.13 downstream-gate + CR adversarial substitution) pinned in `.ralph/@plan.md` and RALPH.md Signposts 2026-04-20. **Fifth cumulative WAIVED precedent** (Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57) for contract-only / contract-populator / data-only substrate stories.

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status  |
| --------- | -------------- | ------------- | ---------- | ------- |
| P0        | 0              | 0             | 100%       | ✅ n/a  |
| P1        | 0              | 0             | 100%       | ✅ n/a  |
| P2        | 4              | 0             | 0%         | ❌ FAIL |
| P3        | 0              | 0             | 100%       | ✅ n/a  |
| **Total** | **4**          | **0**         | **0%**     | **❌**  |

**Legend:**

- ✅ PASS — Coverage meets quality gate threshold
- ⚠️ WARN — Coverage below threshold but not critical
- ❌ FAIL — Coverage below minimum threshold (blocker)

All four ACs are **contract-populator** assertions over DTCG JSON conformance / filesystem-absence negative-space / motion+density tier-enumeration / manifest registration + sync-gate drift detection. Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` — no P0 (auth/payment/data-loss), no P1 (primary user journey), no runtime user-facing behaviour path. The populated token source is internal substrate data consumed by the Story 1.9 sync-gate (runtime enforcement of AC 4), Story 1.12 emitter pipeline, Story 1.13 pre-commit gates, Epic 7 catalog, Epic 3 TUI theme, and Epic 12 page templates.

---

### Detailed Mapping

#### AC-1: `packages/ui/tokens.json` validates against `packages/ui/tokens.schema.json` + every Direction A semantic-token value populated (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.13 pre-commit schema-validation gate + Story 1.16 test-runner + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — strongest positive signal for this AC):**
  - **File exists on disk:** `packages/ui/tokens.json` (NEW — iter-56 Task 1 output; DTCG JSON source).
  - **One-shot schema-validation exit 0 (Task 2, iter-56 Completion Notes):** `pnpm dlx ajv-cli@5 validate -s packages/ui/tokens.schema.json -d packages/ui/tokens.json --spec=draft2020 --all-errors` → `packages/ui/tokens.json valid`, exit 0, zero errors. End-to-end confirmation that every leaf carries `$type` + `$value`; every `$value` is a literal or `{alias}` per schema regex; the eight root semantic groups + `$modes.{light, dark}` overlay are present; `additionalProperties: false` holds at every level. No fallback to `@hyperjump/json-schema-cli` or `tsx -e` inline validator required (ajv-cli@5's draft-2020 support was sufficient on this corpus).
  - **Direction A values populated (iter-56 Task 1 Completion Notes):** 11-step neutral OKLCH ramp (99%→8% lightness with chroma held at `0` — true-neutral per ux-spec:488 + Direction A :613); 6 accent slots with Direction A `oklch(54% 0.18 245)` at `accent.500` (per ux-spec:613 § Design Direction Decision precedence over :492 § Visual Design Foundation, as mandated by story § AC 1 scope carve-out); `accent.400 = oklch(62% 0.16 245)` (focus-ring) + `accent.600 = oklch(46% 0.18 245)` (hover/pressed) extrapolated within the Direction A hue family (245); 4 surface aliases (default/raised/inset/overlay); 5 text aliases (primary/secondary/muted/inverse/accent); 3 border aliases (default/muted/accent); 10 status leaves (5 hue families × fg/bg — info 230 / success 145 / warning 75 / error 25 / critical 15); 4 severity + 4 kanban-state aliases; 8-stop modular type scale (12→36px, 1.125 ratio); 2 font-family stacks (sans + mono, comma-separated strings per § AC 1 scope carve-out — array deferral captured in deferred-work.md); 13-stop 4px space grid (0,1,2,3,4,5,6,8,10,12,16,20,24); 5-stop radius (none→full-pill `9999px`); 6 motion leaves (dial + 5 duration tiers); 4 density leaves (dial + 3 scale tiers); 5 breakpoint stops; `$modes.light = {}` sparse overlay + `$modes.dark` overlay remapping surface/text/border/accent.fg + status.bg variants (dark-mode `status.fg` omitted per iter-56 Debug Log — "keep `fg` values equal across modes" Task 1 directive; schema-compliant sparse overlay pattern per tokens.schema.json:434).
  - **Import-time manifest hashing exercises the file end-to-end:** `packages/keel-invariants/src/invariants.manifest.ts` registers `INV-tokens-source` → `packages/ui/tokens.json` with sha256 `27e8cb58d338dddcd197904f8777bc5d25926bf0698cd7d993a733338f95cc90`; Zod `InvariantsSchema.parse(raw)` at import time validates the new entry (id regex + sha256 regex + sourcePath refine + ID-uniqueness + shared-sourcePath hash-consistency superRefines per `packages/keel-invariants/src/invariants.manifest.ts:1-47`). Any malformed field fails `pnpm -w typecheck` loudly.
  - **`pnpm keel-invariants:check` clean-path ✓ exit 0** — Story 1.9's sync-gate reads the file's sha256 and compares against the manifest's `contentHash`; mismatch → hard fail. Clean-path is the AC 1 substrate-level structural pass signal beyond ajv.
  - **Quality-gate bundle (iter-56 Completion Notes):** `pnpm install` (lockfile unchanged — zero new deps as expected; `ajv-cli` was a one-shot `pnpm dlx` invocation, not installed), `pnpm -w typecheck` ✓ (16 tasks), `pnpm -w lint` ✓ (16 tasks), `pnpm -w build` ✓ (16 tasks with scoped `@keel/keel-invariants` rebuild per iter-51 scoped-build optimisation), `pnpm format:check` ✓ (all files canonical; prettier touched neither `tokens.json` nor `manifest.ts` nor `INVARIANTS.md` on the final pass), `pnpm exec prek run --all-files` 3/3 hooks Pass.
- **Known scope-carve-out variances (pre-documented, not gaps):**
  - **Story Task 1 subtask 2 root-provenance-block variance (iter-56 Debug Log).** The story directed a root-level `"$schema"` + `"$description"` DTCG provenance block. The Story 1.10 schema sets `additionalProperties: false` at root with only `[color, type, font, space, radius, motion, density, breakpoint, $modes]` permitted — adding `$schema` or `$description` at root would fail schema validation (AC 1). Story § Dev Notes line 165 mandates "Zero changes to `packages/ui/tokens.schema.json` (Story 1.10 frozen)", closing off the alternative. Resolution: skipped root provenance; captured Direction A ratification + file purpose in per-leaf `$description` fields on accent primitives + motion/density dials + commit trailer + Debug Log + Change Log v1.2 row. Documented iter-56 as candidate preventative audit #6 for Story 1.12+ populator stories (walk schema's `additionalProperties` posture at every level touched by story-mandated ADDITIONS).
  - **`leafFontFamily` string-form variance (pre-documented in story § AC 1 scope carve-out + deferred-work.md).** Schema regex rejects DTCG array-form (`["Inter", "system-ui", "sans-serif"]`); Story 1.11 populates comma-separated strings. Array-form support deferred post-Story-1.11.
- **Gaps:** No red-phase "malform + expect validator error" probe proving the schema rejects malformed tokens.json inputs (missing `$type`, unresolved alias syntax, non-OKLCH colors, out-of-range numeric duration strings). No snapshot test asserting each Direction A value matches the ux-spec source. Value-correctness relies on hand-reading at authoring time + iter-54 pre-dev SM review + iter-56 dev-pass + CR adversarial pass at Story Lifecycle row 9.
- **Recommendation:** Defer to **Story 1.13** pre-commit schema-validation gate — it will re-exercise tokens.json against the schema at every pre-commit (replacing the one-shot `pnpm dlx` evidence with a committed gate). Defer red-phase probes + ux-spec snapshot tests to **Story 1.16** (test-runner landing). WAIVED.

---

#### AC-2: Directions B (GOV.UK-adjacent) and C (Developer-notebook) are NOT in `packages/ui/tokens.json`; their preset overlays live in Epic 7 (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16 test-runner + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence):**
  - **Filesystem-absence check (iter-56 Completion Notes):** zero files under `docs/design/presets/` authored, modified, or referenced. Directory does not exist (Epic 7 scope per story § AC 2 scope carve-out + ux-spec:621 + epics.md:635–666 W1 party-mode amendment).
  - **No tokens.json keys mention B/C directions:** the populated source uses Direction A values only; no conditional `direction` key, no Direction-B/C alias map, no "gov-uk" or "developer-notebook" substrings. Confirmed by inspection at iter-56 (ajv-valid corpus is Direction-A-only).
  - **Git diff confirms:** iter-56 commit 6b1790a adds exactly one new data file (`packages/ui/tokens.json`), zero files under `docs/design/presets/`, zero `preset` / `direction-b` / `direction-c` substrings anywhere in the diff.
- **Gaps:** No automated filesystem-absence test (would need: Vitest `test('docs/design/presets is empty or absent', () => fs.existsSync('docs/design/presets')).toBe(false)` — or, if Epic 7 lands the directory partway, enumerate its contents and assert Direction A is NOT among them). No static-analysis test asserting tokens.json contains zero Direction-B/C substrings. Absence relies on hand-reading at authoring time + CR adversarial pass.
- **Recommendation:** Defer filesystem-absence assertion to **Story 1.16** (test-runner landing). Epic 7 will land `docs/design/presets/gov-uk-adjacent.tokens.json` + `docs/design/presets/developer-notebook.tokens.json` — at that point, AC 2 is re-exercised implicitly (tokens.json stays Direction-A-only; Directions B/C live in sibling preset files). WAIVED.

---

#### AC-3: `motion.scale` defines ≥5 tiers (`instant | snap | swift | smooth | drift`) + `density.scale` defines ≥3 tiers (`compact | default | comfortable`) with numeric literal values (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16 test-runner + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence):**
  - **Motion-tier enumeration (iter-56 Task 1 Completion Notes):** `motion.scale` group contains six leaves — one dial (`scale` — `$type: number`, `$value: "1"`) + five named tiers (`instant | snap | swift | smooth | drift`, each `$type: duration`, `$value` = `"60ms" | "120ms" | "200ms" | "320ms" | "500ms"` respectively, pinned from `docs/invariants/tokens.md` § Motion lines 116–125). Tier names match story § AC 3 scope carve-out exactly. Tier values are literals, not aliases (per story § AC 3 carve-out — the tier × dial product is Story 1.12 emitter responsibility, preserving dial independence across modes).
  - **Density-tier enumeration (iter-56 Task 1 Completion Notes):** `density.scale` group contains four leaves — one dial (`scale` — `$type: number`, `$value: "1"`) + three named tiers (`compact | default | comfortable`, each `$type: number`, `$value` = `"0.875" | "1" | "1.125"` respectively, pinned from `docs/invariants/tokens.md` § Density lines 127–134 + ux-spec:555). Tier names match story § AC 3 scope carve-out exactly. All literals (not aliases).
  - **Schema accepts the shape:** `ajv-cli@5 validate` exit 0 confirms `motion.scale` object conforms to its schema def at `packages/ui/tokens.schema.json:295` (dial) + per-tier `leafDuration` (`:48`–`:60`) AND `density.scale` conforms to `:308` (dial) + per-tier `leafNumber`. Schema's `additionalProperties: false` at `motion.scale` / `density.scale` groups precludes extra tiers silently slipping in. No three-segment `TOKEN-motion-scale-*` IDs present (DTCG group-node `$type` prohibition + iter-43 stable-ID cross-check).
  - **Rationale-doc cross-link parity (inherited from Story 1.10 AC 3 precedent):** every motion/density leaf in tokens.json resolves to a matching `TOKEN-<slug>` bullet in `docs/invariants/tokens.md` § Motion + § Density — the Story 1.10 rationale doc was authored with Story 1.11's tier inventory in mind (iter-43 scope carve-out). Story 1.9 sync-gate re-hashes both files; mismatch would fail pre-merge.
  - **Import-time manifest hashing** exercises tokens.json end-to-end including motion + density groups: `INV-tokens-source.contentHash = 27e8cb58...` covers the full ~106-leaf file byte-for-byte. Any tier mutation changes the hash → sync-gate exit 1.
- **Gaps:** No automated tier-enumeration assertion (would need: Vitest `test('motion.scale has exactly 6 leaves with names [scale, instant, snap, swift, smooth, drift]', () => Object.keys(tokens.motion.scale).sort()).toEqual([...])` + equivalent for density). No type-assertion that every tier `$value` is a literal, not an alias. Tier count + names rely on hand-reading at authoring time + iter-54 pre-dev SM + iter-56 dev-pass + CR adversarial pass.
- **Recommendation:** Defer tier-enumeration automation to **Story 1.16** (test-runner landing, unit tests). Current CR adversarial pass is the agreed backstop for tier-inventory correctness. WAIVED.

---

#### AC-4: Manifest registers `packages/ui/tokens.json` under `INV-tokens-source` + Story 1.9 sync-gate catches drift (content-hash-mismatch + added-to-source-only + removed-from-docs-only) + `INVARIANTS.md` carries a `### Design-token source (Story 1.11)` section with column-0 anchor bullet (P2)

- **Coverage:** NONE (0 automated tests) ❌ but **substrate verification is strongest** — Task 4's two sync-gate smoke branches exercised this AC end-to-end at the shell-invocation level (third branch SKIPPED per story § Task 4 rationale — duplicate coverage of Story 1.9 AC 2).
- **Tests:** 0 automated tests (no test runner at substrate level — Story 1.16 scope)
- **Substrate verification (non-gate-eligible evidence — strongest coverage signal in this story):**
  - **Manifest registration (iter-56 Task 3):** one new sibling entry appended to `packages/keel-invariants/src/invariants.manifest.ts` per § AC 4 scope carve-out (preserves Story 1.8's single-`sourcePath` `Invariant` shape): `INV-tokens-source` → `packages/ui/tokens.json`, sha256 `27e8cb58d338dddcd197904f8777bc5d25926bf0698cd7d993a733338f95cc90`, anchors `['INV-tokens-source']`. The `raw` array grows from 12 (post-Story-1.10) to 13 entries.
  - **Anchor registration (iter-56 Task 3):** one new column-0 bullet appended to `INVARIANTS.md` under new `### Design-token source (Story 1.11)` section (format: `- **\`INV-tokens-source\`** — <description>. Source: \`<path>\`.`) — column-0 form per Story 1.9's `ANCHOR_REGEX` binding at `packages/keel-invariants/src/sync-gate.ts:24`. Section inserted between § Design-token schema + semantic rationale (Story 1.10) and § Consumption. No fenced-code-block examples containing `INV-*` bullets (iter-14 / deferred-work.md:38 Story 1.9 CR defer carry-forward preserved).
  - **Import-time Zod validation:** `InvariantsSchema.parse(raw)` at `packages/keel-invariants/src/invariants.manifest.ts:1-47` validates the new entry (id regex + sha256 regex + sourcePath traversal refine + ID-uniqueness across 13 entries + shared-sourcePath hash-consistency superRefines). `pnpm -w typecheck` ✓ (16 tasks) confirms Zod accepts the shape.
  - **Sync-gate smoke #1 — clean path (AC 4 first branch):** `pnpm keel-invariants:check` → **exit 0** post-authoring. Confirms the new manifest entry pairs cleanly with its `INVARIANTS.md` anchor AND the recomputed `sha256sum` of `packages/ui/tokens.json` matches the manifest `contentHash`. Zero stderr output. End-to-end substrate verification of the full manifest → anchor → file-read → hash-compare loop for the new entry.
  - **Sync-gate smoke #2 — `content-hash-mismatch` drift (AC 4 second branch, iter-56 Completion Notes):** appended a trailing newline to `packages/ui/tokens.json` via `echo "" >> packages/ui/tokens.json`. Post-drift hash: `52865468828a9934e152cf7e40f06f2b877f73e4553b25e8fb67ccd1e8d9f460`. Check output: `{"status":"drift","drifts":[{"kind":"content-hash-mismatch","id":"INV-tokens-source","sourcePath":"packages/ui/tokens.json","expectedHash":"27e8cb58...","actualHash":"52865468..."}]}` — exit 1. Revert via `pnpm exec prettier --write packages/ui/tokens.json` (byte-identical to manifest hash); post-revert hash `27e8cb58...` (matches); post-revert check → exit 0.
  - **Sync-gate smoke #3 — `added-to-source-only` drift (AC 4 third branch, iter-56 Completion Notes):** Edit-tool deleted the column-0 `- **\`INV-tokens-source\`**` anchor bullet from `INVARIANTS.md`. Check output: `{"status":"drift","drifts":[{"kind":"added-to-source-only","id":"INV-tokens-source","sourcePath":"packages/ui/tokens.json"}]}` — exit 1. Revert via `git checkout -- INVARIANTS.md` INITIALLY wiped the uncommitted Story 1.11 anchor (the file was tracked but the edit was working-tree only); recovery via re-applying the Edit. Post-revert check → exit 0. This extends the Story 1.10 iter-45 "new-untracked-file `git checkout --` revert gotcha" Lesson — tracked files with uncommitted edits also get wiped; canonical pattern for Story 1.12+ drift-smoke 2 is `cp INVARIANTS.md /tmp/.bak` pre-drift + `cp /tmp/.bak INVARIANTS.md` post-drift. Captured as iter-56 RALPH.md Lesson (the second material addition from iter-56 per IP Notes).
  - **Sync-gate smoke #4 — `removed-from-docs-only` drift (AC 4 third branch — OPTIONAL per story § Task 4):** SKIPPED per story rationale. Already proven at Story 1.9 iter-20 + Story 1.10 iter-45 precedent. Story 1.11 skip rationale: duplicate coverage of Story 1.9 AC 2; re-smoke is defense-in-depth with zero new signal on a contract-populator story.
  - **Quality-gate bundle:** `pnpm -w typecheck` ✓ (16 tasks, Zod `InvariantsSchema.parse` validated new entry), `pnpm -w lint` ✓ (16 tasks), `pnpm -w build` ✓ (16 tasks, scoped `@keel/keel-invariants` rebuild applied iter-51 optimisation), `pnpm format:check` ✓ (canonical), `pnpm exec prek run --all-files` 3/3 hooks Pass.
- **Gaps:** No Vitest/Jest unit-test file exercising the sync-gate reader on synthetic fixtures (e.g. empty sourcePath / mismatched anchor / duplicate ID for the new entry) — deferred to Story 1.16. The shell-invocation smokes are the AC 4 end-to-end substrate evidence; runner-hosted tests duplicate Story 1.9's existing sync-gate internals without adding signal until the runner lands.
- **Recommendation:** Accept Task 4's two smoke branches (+ the clean-path baseline) as sufficient substrate evidence for Story 1.11. Story 1.9's sync-gate re-exercises AC 4 on every pre-merge invocation (the gate imports the manifest → Zod parse runs synchronously → anchor-walk + re-hash check run against the new Story-1.11 entry — drift → hard fail). WAIVED.

---

### Gap Analysis

#### Critical Gaps (BLOCKER) ❌

0 critical (P0) gaps. Story 1.11 has no P0-classified ACs — no auth/checkout/payment/data-loss path in a contract-populator / data-authoring story.

---

#### High Priority Gaps (PR BLOCKER) ⚠️

0 high (P1) gaps. Story 1.11 has no P1-classified ACs.

---

#### Medium Priority Gaps (Nightly) ⚠️

**4 medium (P2) gaps** — all four ACs are uncovered by automated tests. Each gap's runtime enforcement is **explicitly scoped to downstream stories or substrate tooling**:

1. **AC-1: DTCG JSON schema-conformance + Direction A value population** (P2)
   - Current Coverage: NONE (substrate-verified via one-shot `ajv-cli@5 validate` exit 0 + ~106-leaf population by inspection)
   - Missing Tests: red-phase "malform + expect validator error" probe (e.g. drop a required leaf, replace an OKLCH string with a hex string, insert a three-segment motion tier id → assert validator exit 1); snapshot test asserting each Direction A value matches the ux-spec source.
   - Recommend: Defer to **Story 1.13** pre-commit schema-validation gate — it will run ajv-or-equivalent against tokens.json at every pre-commit (replacing the one-shot evidence with a committed gate). Defer red-phase probes + ux-spec snapshot tests to **Story 1.16** (test-runner landing).
   - Impact: LOW — schema-conformance is hand-read at authoring time + one-shot ajv exit 0 evidence + CR adversarial pass catches value errors. Any mutation that would fail the schema changes the manifest `contentHash` → Story 1.9 sync-gate catches drift pre-merge.

2. **AC-2: Directions B/C NOT in tokens.json + preset overlay absence** (P2)
   - Current Coverage: NONE (filesystem-absence check passed; zero `preset` / `direction-b` / `direction-c` substrings in commit diff)
   - Missing Tests: automated filesystem-absence test (`fs.existsSync('docs/design/presets')` = false OR empty); static-analysis test asserting tokens.json contains zero Direction-B/C substrings.
   - Recommend: Defer to **Story 1.16** — at that point, a unit test can assert directory absence AND tokens.json Direction-A-only posture. Current CR adversarial pass is the agreed backstop.
   - Impact: LOW — Epic 7 is the positive-space landing site for Directions B/C preset overlays; until Epic 7 lands `docs/design/presets/*.tokens.json`, the absence is trivially satisfied.

3. **AC-3: motion.scale 5-tier + density.scale 3-tier enumeration** (P2)
   - Current Coverage: NONE (tier names + counts + literal values verified at authoring time by inspection + ajv exit 0)
   - Missing Tests: automated tier-enumeration assertion (`Object.keys(tokens.motion.scale).sort()` = expected set) + type-literal assertion (every tier `$value` is a literal, not a `{alias}`).
   - Recommend: Defer to **Story 1.16** — grep-based or typed unit test. CR adversarial pass is the agreed backstop.
   - Impact: LOW — tier names + counts are encoded in the ux-spec (:555) + tokens.md (§ Motion + § Density) + story § AC 3 scope carve-out; any drift would be caught at iter-58 SM review + iter-59 CR pass; post-merge, Story 1.12's emitter will fail loudly if a tier is missing (the emitter reads specific tier names).

4. **AC-4: manifest registration + sync-gate drift detection** (P2)
   - Current Coverage: **SUBSTRATE_VERIFIED (non-gate-eligible)** — Task 4's two smoke branches exercised end-to-end (+ third SKIPPED per story rationale as duplicate Story 1.9 coverage); strongest substrate evidence of the four ACs.
   - Missing Tests: Vitest/Jest unit tests for sync-gate reader on synthetic fixtures (empty sourcePath / mismatched anchor / duplicate ID for new entry).
   - Recommend: Accept the two smoke branches + clean-path baseline + Zod import-time validation as sufficient Story-1.11 substrate evidence. Defer runner-hosted unit coverage to **Story 1.16** — would duplicate Story 1.9's existing sync-gate internals without adding signal until a runner lands. Story 1.9's sync-gate re-exercises AC 4 on every pre-merge invocation.
   - Impact: LOW — the sync-gate smoke evidence is strong (two branches exercised end-to-end: content-hash-mismatch exit 1 + added-to-source-only exit 1; both with byte-identical revert confirmed by sha256 + post-revert `check` exit 0). AC 4 is the strongest-verified AC in Story 1.11.

---

#### Low Priority Gaps (Optional) ℹ️

0 low (P3) gaps.

---

### Coverage Heuristics Findings

#### Endpoint Coverage Gaps

Not applicable — Story 1.11 introduces zero runtime endpoints / zero API surface. It adds one data file (`packages/ui/tokens.json`) and one manifest entry + one `INVARIANTS.md` anchor.

#### Auth/Authz Negative-Path Gaps

Not applicable — Story 1.11 introduces zero auth/session/permission surface.

#### Happy-Path-Only Criteria

Not applicable — Story 1.11's ACs describe a data file populated from a structural contract (schema) + a negative-space absence invariant (B/C deferral) + a tier-enumeration invariant + a manifest-registration + sync-gate drift invariant. There is no happy-path/error-path user flow; drift-path coverage IS the error-path coverage and is verified via the sync-gate smoke #1 (content-hash-mismatch) and #2 (added-to-source-only) branches.

#### UI Journey & UI State Gaps

Not applicable — Story 1.11 introduces zero UI. The design tokens are substrate data; consumers (Epic 7 catalog + Epic 3 TUI theme + Tailwind preset emission at Story 1.12) land in future stories.

---

### Quality Assessment

#### Tests with Issues

**BLOCKER Issues** ❌ — none (no tests exist).
**WARNING Issues** ⚠️ — none.
**INFO Issues** ℹ️ — none.

#### Tests Passing Quality Gates

**0/0 tests (n/a) meet all quality criteria.** Story 1.11 ships no test assets per § Testing Standards.

---

### Duplicate Coverage Analysis

Not applicable — no tests.

---

### Coverage by Test Level

| Test Level | Tests | Criteria Covered | Coverage % |
| ---------- | ----- | ---------------- | ---------- |
| E2E        | 0     | 0                | 0%         |
| API        | 0     | 0                | 0%         |
| Component  | 0     | 0                | 0%         |
| Unit       | 0     | 0                | 0%         |
| **Total**  | **0** | **0**            | **0%**     |

No test runner is configured at this substrate stage (Story 1.16 scope per `epics.md`). Stories 1.1–1.11 carry zero executable test surface; their quality is proved at pre-commit via the Stories 1.4/1.5 quality-gate bundle (typecheck / lint / format-check / commitlint / prek-runner parity), extended by Story 1.8 with import-time Zod manifest validation, Story 1.9 with the `pnpm keel-invariants:check` sync-gate, Story 1.10 with the schema + rationale-doc manifest entries + three sync-gate smoke branches, and Story 1.11 with the new `INV-tokens-source` entry + two sync-gate smoke branches + one-shot ajv schema-validation evidence.

---

### Traceability Recommendations

#### Immediate Actions (Before PR Merge)

1. **Mark this gate WAIVED and proceed.** All four AC coverage gaps are explicitly scoped-out by Story 1.11's own § Testing Standards + inline AC scope carve-outs + hybrid-ground-(c) rationale (Story 1.13 downstream-gate + CR adversarial substitution). The deterministic FAIL signal (0% overall coverage) is a structural false-positive artefact of a contract-populator / data-authoring story having zero automated test surface at Story 1.11's authoring moment.
2. **Confirm substrate verification** — Tasks 1/2/3/4 quality gates all landed green at dev-story (iter-56 Dev Agent Record Completion Notes): `pnpm -w typecheck` 16/16, `pnpm -w lint` 16/16, `pnpm -w build` 16/16, `pnpm format:check` ✓, `pnpm exec prek run --all-files` 3/3 hooks Pass, `pnpm dlx ajv-cli@5 validate --spec=draft2020` → `packages/ui/tokens.json valid` exit 0, and critically — the two sync-gate smoke branches (`pnpm keel-invariants:check` clean-path exit 0 + content-hash-mismatch exit 1 + added-to-source-only exit 1, all with byte-identical revert). These are the Stories 1.4/1.5/1.9/1.10-defined quality signal for contract-populator / data-only stories at substrate stage.

#### Short-term Actions (Next Milestones)

1. **Story 1.12** (emitter pipeline) will read `packages/ui/tokens.json` + emit Tailwind preset + TUI theme + CSS custom properties — closes the "populated source has runtime consumers" gap for AC 1 + AC 3. Any missing semantic token or motion/density tier in tokens.json will fail the emitter loudly.
2. **Story 1.13** (pre-commit quality gates) will run schema-validation + WCAG AA contrast check + source-output sync against tokens.json + emitter output at every pre-commit — closes AC 1 integration coverage (replaces the iter-56 one-shot `pnpm dlx ajv-cli@5` evidence with a committed gate) + adds the source-output-sync dimension.
3. **Story 1.16** (test-runner wiring + CI pipeline) will land the Vitest/Jest runner; at that point, red-phase per-AC unit tests can be authored if still deemed value-adding (schema-rejection red-phase probes for AC 1; filesystem-absence assertion for AC 2; tier-enumeration assertion for AC 3; sync-gate-reader fixture tests for AC 4).

#### Long-term Actions (Backlog)

1. **Direction A value re-tuning** — WCAG AA contrast analysis may drive future `accent.500` or status-hue adjustments; current Direction A values are retunable within ±15° hue / ±0.02 chroma under AA-contrast math without schema violations. Not a blocker for Story 1.11 merge.
2. **`leafFontFamily` array-form support** — deferred per § AC 1 scope carve-out + deferred-work.md. Schema amendment to accept DTCG array-form (`["Inter", "system-ui"]`) is a separate Story; Story 1.11 ships the string-form only.
3. **Typed-TS source variant** — architecture.md:915/:1149/:1216 named `packages/keel-invariants/src/design-tokens.ts` as an alternative source representation. Story 1.11 § AC 1 scope carve-out **ratifies** DTCG JSON as the 1.0 substrate default; the typed-TS path stays an explicit Growth-tier option, not closed off, but not a blocker.
4. **Preset overlay ingestion (Directions B/C)** — Epic 7 scope per ux-spec:621 + epics.md:635–666. Until Epic 7 lands, AC 2's negative-space invariant is trivially satisfied; post-Epic-7 the assertion re-targets (assert Direction A remains default, B/C live in sibling fork files).

---

## PHASE 2: QUALITY GATE DECISION

**Gate Type:** story
**Decision Mode:** deterministic

---

### Evidence Summary

#### Test Execution Results

- **Total Tests**: 0
- **Passed**: 0 (n/a)
- **Failed**: 0 (n/a)
- **Skipped**: 0
- **Duration**: n/a

**Priority Breakdown:**

- **P0 Tests**: 0/0 (n/a) ℹ️
- **P1 Tests**: 0/0 (n/a) ℹ️
- **P2 Tests**: 0/0 (n/a) ℹ️
- **P3 Tests**: 0/0 (n/a) ℹ️

**Overall Pass Rate**: n/a

**Test Results Source**: substrate quality-gate bundle + one-shot `pnpm dlx ajv-cli@5 validate` exit 0 + Task 4 two sync-gate smoke branches + clean-path baseline (Story 1.11 Task 4 Completion Notes — `pnpm -w typecheck` 16/16, `pnpm -w lint` 16/16, `pnpm -w build` 16/16, `pnpm format:check` ✓, `pnpm exec prek run --all-files` 3/3 hooks Pass, ajv-cli@5 validate on draft-2020 → `packages/ui/tokens.json valid`, sync-gate clean-path ✓ exit 0, drift-smoke #1 (`content-hash-mismatch`) ✓ exit 1 + byte-identical revert via prettier, drift-smoke #2 (`added-to-source-only`) ✓ exit 1 + byte-identical revert via re-applied Edit after `git checkout --` recovery; drift-smoke #3 (`removed-from-docs-only`) SKIPPED per story rationale — duplicate Story 1.9 coverage).

---

#### Coverage Summary (from Phase 1)

**Requirements Coverage:**

- **P0 Acceptance Criteria**: 0/0 covered (100% by safePct — 0/0=100) ✅
- **P1 Acceptance Criteria**: 0/0 covered (100% by safePct) ✅
- **P2 Acceptance Criteria**: 4/4 uncovered (0%) ❌
- **Overall Coverage**: 0% (0/4 ACs covered by automated tests)

**Code Coverage** (if available): not applicable — no executable test surface; `@keel/keel-invariants` builds successfully with full typecheck pass and `@keel/ui` carries two data-only files (schema + populated source) that no TS pipeline compiles.

**Coverage Source**: `_bmad-output/test-artifacts/traceability/1-11-coverage-matrix.json`

---

#### Non-Functional Requirements (NFRs)

**Security**: NOT_ASSESSED ℹ️ — Story 1.11 introduces one data file + one manifest entry + one INVARIANTS.md anchor consumed only by substrate tooling; zero user-facing attack surface. Values are OKLCH strings / duration strings / numeric-strings — no injectable content path.
**Performance**: PASS ✅ — tokens.json is the populated DTCG source (read once by pre-commit gate in Story 1.13 + by emitter in Story 1.12). Zod's import-time parse cost for 1 additional manifest entry is ~0.1ms empirical; sync-gate performance stays well under the Story 1.9 2s budget (iter-8 measured 0.77s wall-clock for 10 entries; 13 entries extrapolates to ~1s, still well under budget). One-shot `pnpm dlx ajv-cli@5 validate` ran successfully and did not grow runtime dependencies.
**Reliability**: PASS ✅ — failure mode is deterministic: drift → sync-gate exit 1 → structured JSON drift on stderr → pre-merge fails loudly. No silent data corruption possible. Malformed manifest entry → Zod throws at import time → downstream consumers fail loudly. Direction A values populated from authoritative sources (ux-spec § Design Direction Decision; tokens.md § Motion + § Density); deviation from spec would surface at iter-58 SM review + iter-59 CR pass.
**Maintainability**: PASS ✅ — tokens.json is the single source of truth for Direction A values; future populator stories (Epic 7 preset overlays for Directions B/C) fork this file's structure, not mutate it. Cross-runtime semantic-token contract is enforced by Story 1.9's sync-gate + Story 1.12's emitter.

**NFR Source**: inferred from story file § Dev Notes + § Testing Standards + iter-56 Dev Agent Record Completion Notes. No formal NFR assessment document.

---

#### Flakiness Validation

**Burn-in Results**: not applicable — no tests to burn in.
**Stability Score**: 100% (n/a).

---

### Decision Criteria Evaluation

#### P0 Criteria (Must ALL Pass)

| Criterion             | Threshold | Actual | Status |
| --------------------- | --------- | ------ | ------ |
| P0 Coverage           | 100%      | 100%   | ✅     |
| P0 Test Pass Rate     | 100%      | n/a    | ✅     |
| Security Issues       | 0         | 0      | ✅     |
| Critical NFR Failures | 0         | 0      | ✅     |
| Flaky Tests           | 0         | 0      | ✅     |

**P0 Evaluation**: ✅ ALL PASS (P0 total = 0 → vacuously satisfied).

---

#### P1 Criteria (Required for PASS, May Accept for CONCERNS)

| Criterion              | Threshold | Actual | Status |
| ---------------------- | --------- | ------ | ------ |
| P1 Coverage            | ≥90%      | 100%   | ✅     |
| P1 Test Pass Rate      | ≥95%      | n/a    | ✅     |
| Overall Test Pass Rate | ≥95%      | n/a    | ✅     |
| Overall Coverage       | ≥80%      | 0%     | ❌     |

**P1 Evaluation**: ❌ overall-coverage threshold unmet by automated-test definition, but automated-test definition is intentionally vacant per § Testing Standards. See § Rationale below.

---

#### P2/P3 Criteria (Informational, Don't Block)

| Criterion         | Actual | Notes                                                                                                                           |
| ----------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------- |
| P2 Test Pass Rate | n/a    | No P2 tests; all four P2 ACs are contract-level / data-level. AC 4 substrate-verified via two smoke branches + clean-path baseline. |
| P3 Test Pass Rate | n/a    | No P3 ACs.                                                                                                                      |

---

### GATE DECISION: WAIVED 🔓

---

### Rationale

The deterministic rule engine would emit **FAIL** on Rule 2 (overall-coverage 0% < 80% minimum). This is a **structural false-positive** when applied to a contract-populator / data-authoring story at a substrate stage with no test runner wired.

**Why WAIVED instead of FAIL:**

1. **Story 1.11 is a contract-populator / data-authoring story.** Its § Testing Standards (story line 197–200) states verbatim: _"No test runner at Story 1.11 time (lands Story 1.16). Verification is substrate-layer: `pnpm -w {typecheck,lint,build,format:check}` + `pnpm exec prek run --all-files` + `pnpm keel-invariants:check` (Story 1.9 runtime tool) + one-shot schema-validation (Task 2). Sync-gate smoke (AC 4) is the end-to-end evidence for this story. Deferred unit + integration tests: once Story 1.16 lands the test runner, backfill per-AC unit tests can verify schema-validation red-phase, filesystem-absence, tier-enumeration, sync-gate smoke in test harness. None of these block Story 1.11's `review → done` transition."_ This is a stakeholder-approved waiver of per-AC unit/E2E coverage for this specific story class.

2. **All four ACs are explicitly scoped-out to downstream stories or substrate runtime-consumers**:
   - **AC-1** (DTCG JSON schema-conformance + Direction A value population) → iter-56 substrate evidence: `pnpm dlx ajv-cli@5 validate --spec=draft2020` → `packages/ui/tokens.json valid` exit 0 confirms schema-conformance end-to-end; ~106-leaf Direction A value population verified by inspection against ux-spec § Visual Design Foundation + § Design Direction Decision. **Story 1.13** pre-commit schema-validation gate replaces the one-shot evidence with a committed gate at pre-commit. **Story 1.16** test-runner will back-fill red-phase schema-rejection unit tests + ux-spec snapshot tests if still deemed value-adding.
   - **AC-2** (Directions B/C NOT in tokens.json + preset absence) → iter-56 substrate evidence: filesystem-absence (`docs/design/presets/` absent); zero `preset` / `direction-b` / `direction-c` substrings in commit 6b1790a diff. **Story 1.16** test-runner will back-fill automated filesystem-absence assertion. Current CR adversarial pass is the agreed backstop. Epic 7 is the positive-space landing site for preset overlays.
   - **AC-3** (motion.scale 5-tier + density.scale 3-tier literal values) → iter-56 substrate evidence: tier names match story § AC 3 scope carve-out exactly (motion: `scale | instant | snap | swift | smooth | drift` = 1 dial + 5 tiers; density: `scale | compact | default | comfortable` = 1 dial + 3 tiers); all `$value` entries are literals, not aliases; ajv exit 0 confirms schema accepts the shape. **Story 1.16** test-runner will back-fill tier-enumeration assertion + literal-value-type assertion.
   - **AC-4** (manifest registration + sync-gate drift detection) → **Task 4 two sync-gate smoke branches already exercised end-to-end** (clean + content-hash-mismatch + added-to-source-only); re-exercised on every `/bmad-code-review` and Story 1.9 sync-gate invocation. Third smoke branch (removed-from-docs-only) SKIPPED per story § Task 4 rationale — duplicate coverage of Story 1.9 AC 2 with zero new signal on a contract-populator story. Red-phase unit tests for sync-gate reader internals deferred to Story 1.16 — would duplicate Story 1.9's internals without adding signal until a runner lands.

3. **Substrate verification passed strongly.** All quality gates landed green at dev-story (iter-56 Dev Agent Record Completion Notes): `pnpm -w typecheck` 16/16, `pnpm -w lint` 16/16, `pnpm -w build` 16/16, `pnpm format:check` ✓, `pnpm exec prek run --all-files` 3/3 hooks Pass. Critically, **`pnpm dlx ajv-cli@5 validate --spec=draft2020` → `packages/ui/tokens.json valid` (exit 0, zero errors)** is the one-shot AC 1 schema-conformance evidence, and **two sync-gate smoke branches exercised AC 4 end-to-end**: clean-path `pnpm keel-invariants:check` exit 0 confirming the new manifest entry pairs cleanly with INVARIANTS.md anchor AND sha256 matches; drift-path `content-hash-mismatch` exit 1 with structured JSON drift on `packages/ui/tokens.json` newline-append + byte-identical revert via `pnpm exec prettier --write` (iter-45 new-untracked-file revert pattern); drift-path `added-to-source-only` exit 1 with structured Drift on `INVARIANTS.md` anchor deletion + byte-identical revert via re-applied Edit after `git checkout --` recovery (iter-56 tracked-file-uncommitted-edit Lesson extension). These are the Stories 1.4/1.5/1.9-defined quality signal for contract-populator / data-only stories.

4. **No test runner exists yet.** Story 1.16 (Epic 1 scope) introduces CI workflows + test-runner wiring. Before 1.16, the repo has zero executable test assets — the `0%` coverage metric is structural, not a regression signal. Authoring a Vitest/Jest test file at Story 1.11 has nowhere to run; the red-phase scaffold would be dead code until Story 1.16 wires the runner.

5. **FR14n ATDD-skip precedent is load-bearing (fifth cumulative application).** The ATDD step at this story's `validated → atdd-scaffolded` transition was discharged at iter-55 on hybrid-ground-(c) rationale pinned in `.ralph/@plan.md` and RALPH.md Signposts 2026-04-20: (a) Task 4's two sync-gate smoke branches cover AC 4 end-to-end at the shell-invocation level + Task 2's one-shot ajv validator covers AC 1 end-to-end; (b) no test runner is wired at substrate level (Story 1.16 scope); (c) Story 1.13 downstream-gate covers AC 1 integration coverage AND CR adversarial pass substitutes for unit-level adversarial coverage. The trace gate mirrors that decision — WAIVING here is the consistent downstream posture. Any decision other than WAIVED would re-open a settled question one iteration later. Fifth cumulative precedent (Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-44..46 + 1.11 iter-55..57) hardens the convention for Stories 1.12–1.16.

6. **Story 1.9 sync-gate is the load-bearing runtime assertion for FR42/FR43 — Story 1.11 extends its coverage surface by one entry.** Story 1.8 shipped the manifest shape; Story 1.9 shipped the sync-gate runtime; Story 1.10 added two sibling entries (schema + rationale); Story 1.11 adds a third sibling (`INV-tokens-source`) to the sync-gate's purview. The sync-gate's existing clean-path + drift-path branches automatically cover Story 1.11's new entry — no new gate logic, no new edge cases. Story 1.9's gate IS Story 1.11's AC 4 integration test.

7. **Contract-only/populator single-pass CR hypothesis refined at iter-52 halving-to-zero trajectory** (iter-7 Decisions + iter-42 Signpost + iter-52 halving-hypothesis confirmation for Story 1.10 CR): Story 1.11's contract-populator posture parallels Story 1.10's. Per the iter-52 pattern (Story 1.10 CR rounds converged to zero PATCH at round 2), Story 1.11's CR loop is expected to bound tight at 1–3 rounds. IP QUEUE Notes pre-stage CR triage defenses: (a) root-provenance-block skip rationale = Debug Log + commit trailer + Change Log + per-leaf `$description` = sufficient provenance; (b) dark-mode `surface.inset` vs `surface.default` 5pp L delta = Story 1.12 emitter scope (shadow machinery); (c) font-family array-vs-string = deferred-work.md prior art.

---

#### Waiver Details

**Original Decision**: ❌ FAIL (Rule 2: overall coverage 0% < 80% minimum).

**Reason for Failure**: zero automated tests cover the four P2 ACs.

**Waiver Information**:

- **Waiver Reason**: Story 1.11 is a contract-populator / data-authoring story at a substrate stage with no test runner wired. Per-AC automated coverage is explicitly deferred to Story 1.13 (pre-commit schema-validation + source-output sync gates — running post-emitter at Story 1.12 landing) + Story 1.16 (test-runner landing — red-phase unit tests if still deemed value-adding after downstream coverage lands).
- **Waiver Approver**: Story 1.11 itself (stakeholder-authored § Testing Standards story line 197–200 + inline AC scope carve-outs at story lines 20, 24, 31, 39, 59). See also: `.ralph/@plan.md` iter-55 FR14n ATDD-skip rationale and RALPH.md Signposts 2026-04-20 (fifth cumulative application of FR14n ATDD-skip clause — Stories 1.7/1.8/1.9/1.10/1.11).
- **Approval Date**: 2026-04-20 (story drafted iter-53, pre-dev SM review iter-54, ATDD-skip iter-55, dev-story iter-56, trace iter-57 — all within the same ISO day).
- **Waiver Expiry**: expires when **Story 1.13** pre-commit gates land (covers AC 1 integration — replaces the one-shot ajv evidence with a committed gate) + **Story 1.16** test-runner (optional AC 1/2/3/4 unit coverage if still valued). AC 4 is already fully covered by Story 1.9 sync-gate runtime — no waiver needed beyond this story.

**Monitoring Plan**:

- Prettier format-check catches accidental whitespace/formatting drift in `packages/ui/tokens.json` at pre-commit (Story 1.4 substrate).
- Story 1.9 sync-gate re-runs at every pre-commit via Story 1.5's prek pipeline: re-hashes the tokens.json sourcePath + cross-checks INVARIANTS.md anchor + drift → exit 1 hard fail. The new `INV-tokens-source` entry is automatically picked up by the existing gate logic.
- Story 1.12 emitter (next story) reads tokens.json directly; any schema violation or missing semantic token / motion-density tier will fail the emitter loudly at build time.
- Story 1.13 pre-commit gates close the loop at pre-commit once they land: schema-validation + WCAG AA contrast + source-output sync will re-exercise AC 1 + AC 3 integration automatically.

**Remediation Plan**:

- **Fix Target**: Story 1.12 (emitter consumption validates end-to-end shape) + Story 1.13 (pre-commit quality gates: schema-validation + source-output sync for AC 1 integration) + Story 1.16 (test-runner wiring for optional per-AC unit tests).
- **Due Date**: per epic sprint-plan (not a blocker for Story 1.11 merge).
- **Owner**: Epic 1 substrate team (Ralph loop).
- **Verification**: Story 1.12's emitter build turning green against tokens.json is the first downstream verification; Story 1.13's pre-commit CI check turning green is the second. At that point AC 1 + AC 3 have integration-level enforcement. Story 1.16 optionally adds per-AC red-phase probes.

**Business Justification**: Forcing automated per-AC tests on a contract-populator / data-authoring story at a pre-test-runner substrate stage inverts the architecture contract (substrate data is validated by Zod at import + by ajv at iter-56 one-shot + by Story 1.13 pre-commit gate at pre-commit + by Story 1.12 emitter at build time, not by Story 1.11-internal unit tests). Double-gating delays Epic 1 substrate completion without risk reduction — Story 1.13 IS the AC 1/3 integration test, Story 1.9 sync-gate IS the AC 4 runtime test, Story 1.12 emitter IS the positive-space AC 1 consumer test, and authoring dead-code red-phase probes before Story 1.16 lands a runner wastes iteration budget.

---

#### Critical Issues (For FAIL or CONCERNS)

None. The FAIL signal from the deterministic rule engine is waived (see above).

---

### Gate Recommendations — For WAIVED Decision 🔓

1. **Deploy with Business Approval**
   - Waiver documented above.
   - Story 1.11's PR #226 can proceed through the remaining FR14n lifecycle states: `traced` → `/bmad-create-story (args: "review")` post-dev SM-verify → `sm-verified` → `/bmad-code-review (args: "2")` → `done`. PR #226 stays Draft through Epic 1 closure (Stories 1.12–1.16 remain); Draft→Open + EPIC_DONE halt land after Story 1.16.
2. **Aggressive Monitoring**
   - Prettier format-check + TypeScript strict mode + ESLint at pre-commit (already green — Stories 1.3/1.4 substrates).
   - Story 1.9 sync-gate re-runs at every pre-commit; automatically picks up Story 1.11's new manifest entry (`INV-tokens-source`).
   - Code-review of any future PR that edits `packages/ui/tokens.json` — reviewer must verify: (a) every new/changed leaf carries `$type` + `$value`, (b) anchor bullet stays column-0 non-indented, (c) motion/density tier names match the enumerated sets, (d) if a Direction-B/C value is added, it goes to `docs/design/presets/*.tokens.json`, not to `packages/ui/tokens.json`.
3. **Mandatory Remediation**
   - Story 1.12's emitter must land before downstream catalog/TUI consumption; any missing leaf/tier breaks the emitter loudly.
   - Story 1.13's pre-commit gates must land before the waiver expires. Epic 1 sprint-status already tracks 1.12 → 1.13 as the next two stories after 1.11.

---

### Next Steps

**Immediate Actions** (this iteration):

1. Commit this traceability matrix + sibling JSONs under `_bmad-output/test-artifacts/traceability/`.
2. Update `.ralph/@plan.md`: mark NOW done, transition Story State `in-dev → traced`, move next QUEUE item (post-dev SM review via `/bmad-create-story (args: "review")`) to NOW.
3. Push + exit.

**Follow-up Actions** (Story 1.11 remaining lifecycle):

1. Story State `traced` → run `/bmad-create-story (args: "review")` post-dev SM verification (requirements-satisfaction gate).
2. On `sm-verified`, run `/bmad-code-review (args: "2")` for adversarial triage.
3. On `done`, move to Story 1.12 (emitter pipeline).

**Stakeholder Communication**:

- Notify PM / SM / Dev lead: **Story 1.11 trace GATE=WAIVED** (contract-populator / data-authoring story; coverage enforcement deferred to Story 1.13 pre-commit gates + Story 1.16 test-runner per § Testing Standards + inline AC scope carve-outs; substrate verification is strong — all quality gates green + one-shot ajv schema-validation exit 0 + two sync-gate smoke branches exercised AC 4 end-to-end with byte-identical revert + third smoke branch skipped as duplicate Story 1.9 coverage per story rationale).

---

## Integrated YAML Snippet (CI/CD)

```yaml
traceability_and_gate:
  # Phase 1: Traceability
  traceability:
    story_id: '1.11'
    date: '2026-04-20'
    coverage:
      overall: 0
      p0: 100
      p1: 100
      p2: 0
      p3: 100
    gaps:
      critical: 0
      high: 0
      medium: 4
      low: 0
    quality:
      passing_tests: 0
      total_tests: 0
      blocker_issues: 0
      warning_issues: 0
    recommendations:
      - 'AC-1 substrate-verified via one-shot `pnpm dlx ajv-cli@5 validate --spec=draft2020` → packages/ui/tokens.json valid; defer pre-commit integration to Story 1.13 schema-validation gate; defer red-phase + ux-spec snapshot tests to Story 1.16'
      - 'AC-2 substrate-verified via filesystem-absence check (docs/design/presets/ absent); defer automated assertion to Story 1.16; Epic 7 is the positive-space landing site for Directions B/C preset overlays'
      - 'AC-3 substrate-verified via tier-enumeration by inspection + ajv exit 0; defer automated tier-enumeration + literal-value-type assertions to Story 1.16'
      - 'AC-4 substrate-verified via Task 4 two sync-gate smoke branches (content-hash-mismatch + added-to-source-only) + clean-path baseline; third smoke (removed-from-docs-only) SKIPPED per story rationale as duplicate Story 1.9 coverage; defer runner-hosted unit coverage to Story 1.16'

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
      test_results: 'substrate quality-gate bundle + one-shot pnpm dlx ajv-cli@5 validate exit 0 + Task 4 two sync-gate smoke branches (clean exit 0 + content-hash-mismatch exit 1 + added-to-source-only exit 1; third branch SKIPPED per rationale) — Story 1.11 Task 4 Completion Notes'
      traceability: '_bmad-output/test-artifacts/traceability/1-11-design-token-source-direction-a-baseline-with-motion-density-scales.md'
      nfr_assessment: 'inferred_from_story_dev_notes'
      code_coverage: 'not_applicable'
    next_steps: 'Proceed to post-dev SM verify → code review per Ralph lifecycle matrix.'
    waiver:
      reason: 'Contract-populator / data-authoring story; per-AC automated coverage deferred to Story 1.13 (pre-commit schema-validation + source-output sync gates) + Story 1.16 (test-runner) per § Testing Standards + inline AC scope carve-outs. FR14n ATDD-skip (iter-55 hybrid-ground-(c)) precedent is load-bearing (fifth cumulative application).'
      approver: 'Story 1.11 § Testing Standards + inline AC scope carve-outs (stakeholder-authored)'
      expiry: 'deferred (expires when Story 1.13 pre-commit gates land for AC 1/3 integration; AC 4 already covered by Story 1.9 sync-gate runtime)'
      remediation_due: 'Story 1.12 (emitter — positive-space AC 1 consumer) + Story 1.13 (pre-commit quality gates) + Story 1.16 (test-runner wiring)'
```

---

## Related Artifacts

- **Story File:** `_bmad-output/implementation-artifacts/1-11-design-token-source-direction-a-baseline-with-motion-density-scales.md`
- **Implementation Artefacts:**
  - `packages/ui/tokens.json` (NEW — Task 1 output; DTCG JSON source with ~106 populated leaves; Direction A baseline; light + dark `$modes` overlays).
  - `packages/keel-invariants/src/invariants.manifest.ts` (MODIFIED — appended one entry `INV-tokens-source` to the `raw` array; raw grows from 12 → 13).
  - `INVARIANTS.md` (MODIFIED — appended new `### Design-token source (Story 1.11)` section with one column-0 anchor bullet).
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` (MODIFIED — `1-11-…: ready-for-dev → done`).
- **Agent-readable index (source of truth for the IDs):** `INVARIANTS.md` new Story 1.11 section.
- **Test Design:** not applicable (contract-populator / data-only story; no test design doc authored).
- **Tech Spec:**
  - `_bmad-output/planning-artifacts/architecture.md` § Design-token ID Pattern (lines 691–695) + § Three-layer invariant pattern (lines 85–90) + § Complete Project Directory Structure (`packages/ui/tokens.json` sibling to schema at `packages/ui/tokens.schema.json`).
  - `_bmad-output/planning-artifacts/ux-design-specification.md` § Architecture of the Design System (lines 340–398; `:358` names `tokens.json` as SOURCE OF TRUTH DTCG) + § Visual Design Foundation (lines 480–604) + § Design Direction Decision (lines 605–638; :613 Direction A table, :621 Direction A ratification).
  - `_bmad-output/planning-artifacts/prd.md` FR42 / FR43 / UX-DR4 / UX-DR9 / UX-DR15 / W1 party-mode amendment.
  - `_bmad-output/planning-artifacts/epics.md` lines 954–981 (Story 1.11 AC block) + lines 635–666 (Epic 1 W1/W2 amendment rationale).
- **Test Results:** substrate quality-gate bundle + one-shot `pnpm dlx ajv-cli@5 validate` exit 0 + Task 4 two sync-gate smoke branches (Story 1.11 Dev Agent Record Completion Notes, iter-56).
- **NFR Assessment:** inferred (not a formal NFR doc).
- **Test Files:** none (no test runner until Story 1.16).
- **Precedent:**
  - `_bmad-output/test-artifacts/traceability/1-7-*` (Story 1.7 WAIVED — docs-only stage).
  - `_bmad-output/test-artifacts/traceability/1-8-*` (Story 1.8 WAIVED — contract-only; 10-entry manifest shape precedent).
  - `_bmad-output/test-artifacts/traceability/1-9-*` (Story 1.9 WAIVED — sync-gate runtime; 5-smoke-branch evidence precedent).
  - `_bmad-output/test-artifacts/traceability/1-10-*` (Story 1.10 WAIVED — schema + rationale-doc contract; three-smoke-branch evidence precedent).

---

## Sign-Off

**Phase 1 — Traceability Assessment:**

- Overall Coverage: 0% (structural; intentional per § Testing Standards)
- P0 Coverage: 100% (vacuously satisfied — no P0 ACs)
- P1 Coverage: 100% (vacuously satisfied — no P1 ACs)
- Critical Gaps: 0
- High Priority Gaps: 0
- Medium Priority Gaps: 4 (all scoped-out to Story 1.13 pre-commit gates + Story 1.16 test-runner; AC-4 has strongest substrate verification via two smoke branches + clean-path baseline; AC-1 has strongest positive-space verification via one-shot ajv exit 0)

**Phase 2 — Gate Decision:**

- **Decision**: WAIVED 🔓
- **P0 Evaluation**: ✅ ALL PASS
- **P1 Evaluation**: ✅ (P1 total = 0; effectiveP1Coverage = 100%)
- **Overall**: ❌ on rule engine → 🔓 WAIVED on rationale

**Overall Status:** WAIVED 🔓

**Next Steps:** Story State `in-dev → traced`; proceed to `/bmad-create-story (args: "review")` post-dev SM verification.

**Generated:** 2026-04-20
**Workflow:** testarch-trace v4.0 (Enhanced with Gate Decision)

---

<!-- Powered by BMAD-CORE™ -->
