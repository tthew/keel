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
    '_bmad-output/implementation-artifacts/1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold.md',
    '_bmad-output/implementation-artifacts/1-15-renovate-config-with-version-pinning-rules-i7.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    'INVARIANTS.md',
    'AGENTS.md',
    'CLAUDE.md',
    'docs/invariants/fork.md',
    'packages/keel-invariants/templates/INVARIANTS.fork.md',
    'packages/keel-invariants/src/invariants.manifest.ts',
    'packages/keel-invariants/package.json',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/1-16-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 1.16 Fork extension-config pattern + Growth-tier `INVARIANTS.fork.md` scaffold (FR44 + FR45)

**Target:** Story 1.16 — FR44 fork-extension-config pattern (`eslint.config.fork.js` importing `@keel/keel-invariants/eslint` subpath export) + FR45 Growth-tier `INVARIANTS.fork.md` scaffold template. Substrate ships two new authored files (`packages/keel-invariants/templates/INVARIANTS.fork.md` Growth-tier scaffold template + `docs/invariants/fork.md` 10-section rationale doc) + two new manifest entries (`INV-fork-extension-rationale` + `INV-fork-invariants-scaffold` → manifest 22 → 24) + two new column-0 INVARIANTS.md anchors under a new `### Fork extension (Story 1.16)` H3 section (inserted between `### Dependency upgrade discipline (Story 1.15)` at line 80 and `## Consumption` H2 at line 82) + one new `## Fork extension (FR44)` H2 section in AGENTS.md (between `## Git / PR conventions` and `## Ralph loop`) + one new 5th row for `INVARIANTS.fork.md` in CLAUDE.md § Knowledge-file contract table + precedence paragraph. Zero runtime code. Epic 15a's future `create-keel-app --include-fork-invariants` CLI flag (default `false` at 1.0 per AC 4) lands the runtime automation of manual template copy in a downstream epic.
**Date:** 2026-04-21
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 1.16 § Acceptance Criteria lines 13–48)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold.md` (AC 1–4)

---

Note: This workflow does not generate tests. Story 1.16 is a **documentation-surface substrate** story whose § Dev Notes + v1.2 Change Log row (iter-90 ATDD-skip) explicitly declares:

> _"/bmad-testarch-atdd will NOT be invoked for Story 1.16 for three conjoint grounds: (a) substrate-verification-covers-ACs — Task 7 enumerates six smokes (scaffold-template shape, rationale-doc shape, AGENTS.md update, CLAUDE.md update, manifest-load 24 invariants, sync-gate clean) that exercise AC 1–AC 4 end-to-end at substrate CLI-exit-code level; (b) no test runner at Story 1.16 time — Epic 13 scope; no vitest.config.* / jest.config.* / playwright.config.* / cypress.config.* exists anywhere in the tree; (c) HYBRID variant-(ii)+(iii) — downstream-story + CR-substitution: AC 4's runtime carve-out (Epic 15a's `create-keel-app --include-fork-invariants` flag defaulting `false` at 1.0) is DOWNSTREAM runtime-class behaviour owned by Epic 15a's CLI tests when that package is authored (variant ii); adversarial AC 1 + AC 2 + AC 3 coverage (ESLint-extend documentation fidelity + precedence-rule prose accuracy + amendment-vs-fork decision tree completeness + template-file shape integrity + CLAUDE.md contract-table row accuracy + manifest-entry description faithfulness) delegated to iter-94 `/bmad-code-review (args: \"2\")` three-layer fan-out (variant iii). The hybrid is strictly stronger than either variant alone."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-90, per the hybrid ground-(c) variant-(ii)+(iii) rationale (substrate-verification-covers-AC via six smokes + no-runner at Story 1.16 time + Epic 15a CLI downstream consumer + Epic 13 test-runner backfill + CR adversarial fan-out) pinned in `.ralph/@plan.md § Context` and RALPH.md Signposts 2026-04-21. **Tenth cumulative WAIVED precedent** (Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57 + 1.12 iter-64 + 1.13 iter-71 + 1.14 iter-78 + 1.15 iter-85 + 1.16 iter-92) for contract-only / contract-populator / data-only / emitter+tooling / gate-authoring / configuration-surface / dependency-upgrade-policy-config / documentation-surface substrate stories.

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

All four ACs are **documentation-surface** assertions over the FR44 ESLint-extend pattern + FR45 Growth-tier INVARIANTS.fork.md scaffold (AC 1: ESLint-extend pattern documented in AGENTS.md + code block; AC 2: substrate-wins via flat-config last-write-wins + amendment-vs-fork decision tree; AC 3: Growth-tier scaffold template + CLAUDE.md contract-table row + precedence rule; AC 4: 1.0 default `--include-fork-invariants=false` + manual opt-in documented). Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` — no P0 (auth/payment/data-loss), no P1 (primary user journey). The Story-1.16 substrate IS the documentation + template contract that downstream fork operators consume when they opt into the extension pattern (eslint.config.fork.js at fork root) or the Growth-tier scaffold (manual `cp` at 1.0; Epic 15a's `--include-fork-invariants` flag automates later). Story 1.16 does NOT create any fork or author any `eslint.config.fork.js` at its own landing commit (AC 1 carve-out).

---

### Detailed Mapping

#### AC-1: Fork follows AGENTS.md-documented extension pattern to create `eslint.config.fork.js` importing `@keel/keel-invariants/eslint` (subpath export at `packages/keel-invariants/package.json:14`); additional fork rules layer cleanly; `pnpm lint` applies both shared + fork rules (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16-test-runner-landing + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; smokes 2 + 3 directly probe AC 1 at CLI-exit-code level):**
  - **AGENTS.md update (smoke 3 — iter-91 authored)**: `node -e "const s=require('fs').readFileSync('AGENTS.md','utf8'); if (!/## Fork extension \(FR44\)/.test(s)) throw new Error('missing AGENTS.md § Fork extension'); if (!/@keel\/keel-invariants\/eslint/.test(s)) throw new Error('missing subpath-export reference'); if (!/amendment/i.test(s) || !/decision/i.test(s)) throw new Error('missing amendment-vs-fork decision tree keywords'); console.log('OK: AGENTS.md § Fork extension + subpath-export + decision-tree present');"` exits 0 with `OK: AGENTS.md § Fork extension + subpath-export + decision-tree present`. Re-verified LIVE at iter-92.
  - **Rationale doc shape (smoke 2 — iter-91 authored)**: `node -e "const s=require('fs').readFileSync('docs/invariants/fork.md','utf8'); const sections=['# Fork extension','## Overview','## ESLint-extend pattern','## INVARIANTS.fork.md scaffold','## Precedence','## Amendment-vs-fork decision tree','## Growth-tier opt-in','## Files','## Fork extension','## Consumption']; const missing=sections.filter(sec => !s.includes(sec)); if (missing.length) throw new Error('missing sections: ' + missing.join(', ')); if (!/INV-fork-extension-rationale/.test(s)) throw new Error('missing anchor bullet'); console.log('OK: rationale doc all 10 sections + anchor bullet present');"` exits 0 with `OK: rationale doc all 10 sections + anchor bullet present`. Re-verified LIVE at iter-92. **Directly probes AC 1 § ESLint-extend pattern (FR44) section existence at file level.**
  - **Subpath export reference pinned verbatim.** AGENTS.md § Fork extension (FR44) references `@keel/keel-invariants/eslint` — this is the exact subpath export declared at `packages/keel-invariants/package.json:14` (`"./eslint": "./eslint.config.keel-invariants.js"`) since Story 1.2. Story 1.16 did NOT modify `package.json` (documentation-only scope); the subpath export is a pre-existing substrate artefact referenced but not authored by Story 1.16.
  - **Copy-ready code block appears verbatim in TWO surfaces for consistency**: AGENTS.md § Fork extension (FR44) + `docs/invariants/fork.md` § ESLint-extend pattern (FR44). Both show the spread-at-end convention (`...sharedConfig` LAST → substrate-wins precedence per ESLint flat-config last-write-wins semantics):
    ```js
    import sharedConfig from '@keel/keel-invariants/eslint';

    export default [
      { rules: { /* fork-specific rules */ } },
      ...sharedConfig, // substrate LAST → substrate wins (docs/invariants/fork.md § Precedence)
    ];
    ```
    Fork operators reading either surface reach the same implementation pattern.
  - **Substrate-wins convention canonicalized across FIVE surfaces** (per story Completion Notes List bullet 3): AGENTS.md § Fork extension (FR44) precedence rule + `docs/invariants/fork.md` § Precedence three-layer hierarchy + `packages/keel-invariants/templates/INVARIANTS.fork.md` § Precedence (ships in fork copies) + CLAUDE.md § Knowledge-file contract precedence paragraph + INVARIANTS.md § Fork extension (Story 1.16) summary line. Consistent language ('substrate rules are AUTHORITATIVE; fork rules ADD TO substrate; conflicts via amendment-or-scope-narrowing') across all five.
  - **File-location convergence**: `packages/keel-invariants/package.json:14` subpath export (Story 1.2, pre-existing) + `AGENTS.md` § Fork extension (FR44) (Story 1.16 NEW) + `docs/invariants/fork.md` (Story 1.16 NEW) + `packages/keel-invariants/templates/INVARIANTS.fork.md` (Story 1.16 NEW). **No architecture-vs-epic drift** (contrast Story 1.14 AC 1 where `.github/release-please-config.json` drifted vs architecture.md:807's root-level layout — RALPH.md 2026-04-19 lesson does not apply here; the subpath export + fork-extension documentation align on the existing package exports contract).
  - **ESLint flat-config precedence semantic**. As of ESLint 9 (flat-config default), the exported `eslint.config.*.js` is an array evaluated in order; later entries override earlier entries at the same file glob. This is the semantic AGENTS.md § Fork extension + docs/invariants/fork.md § Precedence document verbatim. No ESLint version-update concern for Story 1.16 — flat config is the 1.0 baseline per `packages/keel-invariants/eslint.config.keel-invariants.js` + root `eslint.config.js`.
  - **Zero runtime behaviour at Story 1.16 substrate stage**. No fork currently uses `eslint.config.fork.js` at ralph-bmad level; the documented pattern is for DOWNSTREAM fork operators. Until a fork opts in (post-M0 ops / Epic 15a's `--include-fork-invariants` flag automating template copy at downstream runtime), `docs/invariants/fork.md` + AGENTS.md § Fork extension are inert drift-detected substrate (same posture as Story 1.14 `.github/release-please-config.json` awaiting Story 13.5 workflow + Story 1.15 `.github/renovate.json` awaiting Renovate App install).
  - **Adversarial AC-1 coverage delegated to iter-94 CR** per § Testing Standards hybrid ground-(c) variant-(iii) spec-declared-CR-substitution: Blind Hunter examines AGENTS.md § Fork extension code block for typos in `@keel/keel-invariants/eslint` + spread-at-end convention correctness; Edge Case Hunter probes docs/invariants/fork.md § ESLint-extend pattern for flat-config semantic accuracy + reverse-spread-order edge case; Acceptance Auditor verifies the subpath-export reference matches `packages/keel-invariants/package.json:14` exactly + the copy-ready code block is consistent across AGENTS.md + docs/invariants/fork.md.

#### AC-2: Fork adds rules conflicting with substrate invariants → substrate wins via ESLint flat-config last-write-wins + spread-at-end convention (operational, not semantic-analysis); AGENTS.md explains amendment-vs-fork (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16-test-runner-landing + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence; AGENTS.md + docs/invariants/fork.md precedence + decision-tree documentation):**
  - **AGENTS.md § Fork extension (FR44) Precedence rule bullet** (iter-91 surgical Edit). Verbatim: "Substrate rules take precedence over fork rules at the same file glob via ESLint flat-config last-write-wins semantics + the spread-at-end convention. Forks that want the opposite posture (fork-wins) spread substrate FIRST; this is unusual and should carry a comment in the fork's `eslint.config.fork.js` explaining why." Re-verified LIVE at iter-92 via grep on AGENTS.md.
  - **AGENTS.md § Fork extension (FR44) Amendment-vs-fork decision bullet** (iter-91 surgical Edit). Three exit paths pinned: (a) FORK — fork-specific need, use `eslint.config.fork.js`; (b) AMEND — substrate-wide need, open PR against `packages/keel-invariants/` + `INVARIANTS.md` + manifest entry + anchor bullet (the Story 1.6 + 1.9 source-level fork path); (c) DEFER — premature need, log in `_bmad-output/implementation-artifacts/deferred-work.md`.
  - **docs/invariants/fork.md § Amendment-vs-fork decision tree** holds the CANONICAL three-exit-path text with 2-3 sentences of concrete example per path (Task 2 spec line 118). AGENTS.md links to the fuller rationale doc via the `docs/invariants/fork.md § Amendment-vs-fork decision tree` pointer.
  - **docs/invariants/fork.md § Precedence** contains the THREE-LAYER precedence rule verbatim (substrate authoritative → fork additive → conflicts via amendment-or-scope-narrowing). Mirrors the INVARIANTS.md § Fork extension (Story 1.16) summary line + AGENTS.md § Fork extension precedence rule bullet for cross-surface consistency.
  - **Reverse-spread-order edge case** documented in both AGENTS.md + docs/invariants/fork.md. Forks that want fork-wins precedence spread `@keel/keel-invariants/eslint` FIRST (not LAST); both surfaces note this variant is unusual and recommend spread-at-end as the 1.0 default. Fork operators who deliberately depart from the convention are advised to document the reason in their fork's `eslint.config.fork.js`.
  - **Operational-convention-not-semantic-analysis clarification**. AC 2 is NOT "ESLint semantically analyzes rule conflict and picks substrate" — ESLint flat-config only cares about array order per file glob. The OPERATIONAL equivalent of "substrate wins" is "spread substrate LAST". Story 1.16's AGENTS.md § Fork extension + docs/invariants/fork.md § Precedence make this OPERATIONAL nature explicit so fork operators do not misinterpret the convention as a rule-semantic override.
  - **Amendment-vs-fork decision tree three paths** (iter-91 dev-story documentation):
    - **(a) FORK (fork-specific need).** Author `eslint.config.fork.js` at fork root importing `@keel/keel-invariants/eslint`; optionally copy `INVARIANTS.fork.md` scaffold template. Example: a b2b SaaS fork with EU-only residency requirements authors a region-lock rule in `eslint.config.fork.js` + registers `FORK-acme-tenancy-region-lock` in its `INVARIANTS.fork.md`.
    - **(b) AMEND (substrate-wide need).** Open a PR against `packages/keel-invariants/` + `INVARIANTS.md` + add a manifest entry + add an anchor bullet. This is the Story 1.6 + 1.9 source-level fork path — it changes substrate for every downstream fork. Example: a fork discovers that a specific ESLint rule SHOULD be substrate (not fork-specific); the fork operator contributes the rule upstream via a substrate amendment PR.
    - **(c) DEFER (premature need).** Log the need in `_bmad-output/implementation-artifacts/deferred-work.md` for future evaluation. Example: a rule is conceptually cross-cutting but the substrate's current milestone scope doesn't yet cover the enforcement surface; log for later.
  - **Adversarial AC-2 coverage delegated to iter-94 CR** per § Testing Standards: Blind Hunter examines the precedence-rule prose for semantic accuracy (flat-config last-write-wins is indeed the mechanism; not some rule-semantic-analyzer); Edge Case Hunter probes the amendment-vs-fork decision tree for exhaustiveness (3 exit paths cover all fork-disagreement scenarios); Acceptance Auditor verifies the amendment-vs-fork decision tree appears in both AGENTS.md + docs/invariants/fork.md + the INVARIANTS.md anchor bullets reference it.

#### AC-3: Growth-tier `INVARIANTS.fork.md` scaffold — fork operator opts in, `INVARIANTS.fork.md` template is created at fork root, `CLAUDE.md` updated to reference both `INVARIANTS.md` and `INVARIANTS.fork.md` with precedence rules (P2)

- **Coverage:** NONE ❌ (deferred to Story 1.16-test-runner-landing + CR adversarial backstop; fork-opt-in runtime is Epic 15a scope)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; smokes 1 + 4 directly probe AC 3 at CLI-exit-code level):**
  - **`packages/keel-invariants/templates/INVARIANTS.fork.md` exists** (Growth-tier scaffold template; sha256 `167ba6b2a8f1153df02f7e572b1d1e31415731493b0729415f6573cc1a696218`). Hash matches iter-91 dev-story pinned value exactly (re-verified LIVE at iter-92 via `sha256sum packages/keel-invariants/templates/INVARIANTS.fork.md`). Template is the FIRST substrate-shipped template file — distinct from the rationale-doc category (`docs/invariants/*.md`).
  - **Smoke 1 — scaffold template shape smoke (iter-91 authored)**: `node -e "const s=require('fs').readFileSync('packages/keel-invariants/templates/INVARIANTS.fork.md','utf8'); const sections=['# INVARIANTS.fork.md','## Precedence','## Fork invariants index','## Consumption','## Extension']; const missing=sections.filter(sec => !s.includes(sec)); if (missing.length) throw new Error('missing sections: ' + missing.join(', ')); if (!/FORK-<fork-slug>/.test(s)) throw new Error('missing FORK-<fork-slug> naming convention example'); console.log('OK: scaffold template all 5 sections + naming example present');"` exits 0 with `OK: scaffold template all 5 sections + naming example present`. Re-verified LIVE at iter-92. **Directly probes AC 3 substrate-template-shape at CLI-exit-code level.**
  - **Template shape** (iter-91 Task 1): H1 `# INVARIANTS.fork.md — fork-specific machine-enforced rules` + 2-line audience/companion attribution block + § Precedence (three-layer substrate/fork/conflict hierarchy) + § Fork invariants index (with commented `FORK-<fork-slug>-<category>-<slug>` naming example) + § Consumption (agents read alongside upstream INVARIANTS.md) + § Extension (naming convention + commit-alongside-source rule). Design intent: frictionless opt-in for forks that want to add FORK-prefixed invariants without inventing a new doc structure.
  - **Template shape mirrors upstream INVARIANTS.md shape** (Section headers + anchor bullets) so fork operators see structural continuity when comparing upstream-to-fork. This is the design intent: the substrate-shipped template is a drop-in authoring surface for fork-specific invariants.
  - **docs/invariants/fork.md § INVARIANTS.fork.md scaffold (FR45 Growth-tier)** (iter-91 Task 2) explains the opt-in flow: (1) fork operator copies `packages/keel-invariants/templates/INVARIANTS.fork.md` to their fork root (`cp packages/keel-invariants/templates/INVARIANTS.fork.md ./INVARIANTS.fork.md`); (2) adds fork-specific `FORK-<fork-slug>-<category>-<slug>` invariants under the appropriate H3 section; (3) updates their fork's CLAUDE.md to reference both upstream INVARIANTS.md + new INVARIANTS.fork.md.
  - **Smoke 4 — CLAUDE.md update smoke (iter-91 authored)**: `node -e "const s=require('fs').readFileSync('CLAUDE.md','utf8'); if (!/INVARIANTS\.fork\.md/.test(s)) throw new Error('missing CLAUDE.md INVARIANTS.fork.md reference'); if (!/precedence/i.test(s)) throw new Error('missing precedence keyword'); console.log('OK: CLAUDE.md INVARIANTS.fork.md + precedence reference present');"` exits 0 with `OK: CLAUDE.md INVARIANTS.fork.md + precedence reference present`. Re-verified LIVE at iter-92.
  - **CLAUDE.md § Knowledge-file contract 5th row** (iter-91 surgical Edit). Row: `| INVARIANTS.fork.md` (Growth-tier, optional) `| Fork-specific agent/human — machine-enforced rules | Fork-owned additive rules to upstream INVARIANTS.md; substrate rules take precedence (FR45; docs/invariants/fork.md § Precedence). Not present at 1.0 — fork operators opt in by copying packages/keel-invariants/templates/INVARIANTS.fork.md to repo root. |`. Re-verified LIVE at iter-92 via grep on CLAUDE.md.
  - **CLAUDE.md precedence paragraph appended after the contract table**: "Precedence: upstream INVARIANTS.md is authoritative for every rule registered in invariants.manifest.ts; INVARIANTS.fork.md (when a fork opts in) is additive — fork rules ADD TO substrate but cannot override it. See docs/invariants/fork.md § Precedence + § Amendment-vs-fork decision tree for the opt-in flow + conflict-resolution paths."
  - **FORK-naming-convention example in template**. Commented-out example block shows `FORK-<fork-slug>-<category>-<slug>` with concrete sample: `FORK-acme-tenancy-region-lock — b2b fork with EU-only residency pins app.current_region = 'eu-west' in tenancy middleware. Source: packages/contracts/middleware/region-lock.ts.` Fork operators copy the convention directly; the pattern enforces ≥ 2 hyphen-separated segments after `FORK-<slug>-` prefix, all lowercase, no underscores (mirrors upstream `INV-` naming convention at `invariants.manifest.ts:4`).
  - **Adversarial AC-3 coverage delegated to iter-94 CR** per § Testing Standards: Blind Hunter examines the scaffold template for section-header typos + missing sections + FORK-naming-example shape; Edge Case Hunter probes the CLAUDE.md contract-table row for column alignment + column-1 wording consistency with the other 4 rows; Acceptance Auditor verifies the opt-in flow in docs/invariants/fork.md references the EXACT template path (`packages/keel-invariants/templates/INVARIANTS.fork.md`) + the CLAUDE.md row exists at the 5th row position.

#### AC-4: At 1.0 the Growth-tier scaffold is non-essential — Epic 15a's `create-keel-app` does NOT auto-create `INVARIANTS.fork.md`; pattern + template documented for manual opt-in (P2)

- **Coverage:** NONE ❌ (downstream Epic-15a CLI test scope; deferred to Story 1.16-test-runner-landing + CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; smokes 5 + 6 directly probe AC 4 at CLI-exit-code level):**
  - **docs/invariants/fork.md § Growth-tier opt-in section authored** (iter-91 Task 2). Two-sentence content per Task 2 spec: "(1) At 1.0 `create-keel-app` does NOT auto-create `INVARIANTS.fork.md` per AC 4 — the scaffold template ships in substrate at `packages/keel-invariants/templates/INVARIANTS.fork.md` but is not bootstrapped into new forks by default. (2) Epic 15a ships the `--include-fork-invariants` flag (default `false`) when it lands; forks that want the scaffold today copy the template manually via `cp packages/keel-invariants/templates/INVARIANTS.fork.md ./INVARIANTS.fork.md`." Re-verified LIVE at iter-92 via `Grep "Growth-tier opt-in" docs/invariants/fork.md`.
  - **`packages/create-keel-app/` does NOT exist at Story 1.16 landing time**. Verified at drafting (iter-88 L4 audit) via `ls packages/` returning `keel-invariants` only. Re-verified at iter-92 — the Epic 15a CLI package has not yet been authored; the `--include-fork-invariants` flag is a FUTURE behavioural commitment Story 1.16 pins verbally in docs/invariants/fork.md § Growth-tier opt-in.
  - **Epic 15a regression-test mandate**. Story 1.16 scope carve-out (story line 48) pins: "When Epic 15a lands, its AC/tests must include a regression check that `create-keel-app` does NOT copy the scaffold by default (the `--include-fork-invariants` flag must default to `false` at 1.0)." This pushes the runtime enforcement DOWNSTREAM to Epic 15a's CLI tests; Story 1.16's substrate deliverable is the TEMPLATE + the DOC describing the expected opt-in flow.
  - **2 new manifest entries** at `packages/keel-invariants/src/invariants.manifest.ts` raw array tail (post-`INV-renovate-rationale` at lines 217-223; iter-91 Task 3):
    - **`INV-fork-extension-rationale`** — sourcePath `docs/invariants/fork.md`, contentHash `be6f3d8919e7bb2b6258d768895d8a1e4d4a37c5fef95f5121f1ca878da192f2`, anchors `['INV-fork-extension-rationale']`. Documentation-layer rationale for FR44 ESLint-extend pattern + FR45 Growth-tier INVARIANTS.fork.md scaffold; mirrors Story 1.10's `INV-tokens-semantic-rationale` + Story 1.14's `INV-release-please-rationale` + Story 1.15's `INV-renovate-rationale` rationale-doc convention.
    - **`INV-fork-invariants-scaffold`** — sourcePath `packages/keel-invariants/templates/INVARIANTS.fork.md`, contentHash `167ba6b2a8f1153df02f7e572b1d1e31415731493b0729415f6573cc1a696218`, anchors `['INV-fork-invariants-scaffold']`. Growth-tier scaffold template — substrate source for fork-operator opt-in.
  - **Smoke 5 — manifest load**: `cd packages/keel-invariants && pnpm build && node -e "import('./dist/invariants.manifest.js').then(m => console.log('OK: ' + m.invariants.length + ' invariants'))"` prints `OK: 24 invariants`. Re-verified LIVE at iter-92 (post-`pnpm --filter @keel/keel-invariants build` which compiled `src/invariants.manifest.ts` → `dist/invariants.manifest.js` per iter-77 Gotcha: the `@keel/keel-invariants` export reads the compiled `dist/` variant, NOT the TS source).
  - **Smoke 6 — sync-gate clean**: `pnpm keel-invariants:check` exits 0 silent. LIVE at iter-92: clean exit (wall-clock within <2s AC 7 budget; iter-91 recorded 0.776s = 61.2% margin). Validates (a) 24 entries parse via Zod `InvariantSchema`; (b) 24 sha256 content-hashes match the file bytes on disk (including the 2 new Story 1.16 hashes); (c) 24 INVARIANTS.md anchors resolve via the `ANCHOR_REGEX` walker (including the 2 new column-0 anchors under `### Fork extension (Story 1.16)`); (d) the Story 1.13 tokens-sync gate + Story 1.14 release-please entries + Story 1.15 renovate entries remain clean (no cascade hash update triggered by Story 1.16 per L6 no-cascade-hash check — knowledge files are consumption-layer pointers not sourcePaths).
  - **2 new column-0 anchor bullets** in `INVARIANTS.md` under a new `### Fork extension (Story 1.16)` H3 section inserted between existing `### Dependency upgrade discipline (Story 1.15)` H3 (ends at line 80) and `## Consumption` H2 (line 82). Each bullet matches the Story 1.9 walker's `ANCHOR_REGEX` shape `^-\s+\*\*\`INV-[a-z0-9]+(?:-[a-z0-9]+)+\`\*\*`.
  - **Stable-ID regex verification** (L1 preventative layer): both IDs match the Zod regex `^INV-[a-z0-9]+(-[a-z0-9]+)+$` at `invariants.manifest.ts:4` — `INV-fork-extension-rationale` (3 lowercase-hyphenated segments: fork / extension / rationale), `INV-fork-invariants-scaffold` (3 lowercase-hyphenated segments: fork / invariants / scaffold). No uppercase, no underscores, no segment shorter than 1 char.
  - **Pattern-match ID discipline**. Epic 1.16 ACs do NOT pin specific IDs (contrast Story 1.15 AC 4 which pinned `INV-deps-version-pinning` verbatim), so these are PATTERN-MATCH IDs selected by the Story 1.10/1.14/1.15 rationale-doc + scaffold-surface conventions. Pattern-match ID discipline is still epic-traceable (both IDs appear in the iter-91 dev-story record + are externally citable via the manifest).
  - **Manifest growth 22 → 24 (+9%)**. Slightly smaller than Story 1.15's +10% (20 → 22); well within Story 1.9 walker O(n+m) perf budget. Sync-gate wall-clock 0.776s at iter-91 (+147ms vs iter-86's 0.629s baseline for +2 entries + 2 new sourcePath file reads + 2 new hash computations) = 61.2% margin under the <2s AC 7 budget. Re-verified LIVE at iter-92.
  - **2-ID shape per AC 3 + AC 4 scope carve-out**. Per-file drift is surgical (a silent edit to `packages/keel-invariants/templates/INVARIANTS.fork.md` is distinct drift from a silent edit to `docs/invariants/fork.md`). An alternative single `INV-fork-bundle` collapsing both was rejected for the same reason Stories 1.13 + 1.14 + 1.15 rejected bundling their multiple files: bundling collapses drift detection. Two separate IDs preserve surgical fault localization.
  - **Adversarial AC-4 coverage delegated to iter-94 CR** per § Testing Standards: Acceptance Auditor verifies (a) `INV-fork-extension-rationale` sourcePath is exactly `docs/invariants/fork.md` (no path drift); (b) contentHash matches `sha256sum docs/invariants/fork.md` post-prettier (no hash drift); (c) `INV-fork-invariants-scaffold` sourcePath is exactly `packages/keel-invariants/templates/INVARIANTS.fork.md`; (d) both IDs appear as column-0 anchor bullets in INVARIANTS.md under `### Fork extension (Story 1.16)`; (e) docs/invariants/fork.md § Growth-tier opt-in contains the two-sentence content verbatim per Task 2 spec. Blind Hunter flags any hash drift or anchor missing from INVARIANTS.md; Edge Case Hunter probes INVARIANTS.md column-0 formatting edge cases.

---

## PHASE 2: GAP ANALYSIS

### Critical gaps

_none_

### High-priority gaps

_none_

### Medium-priority gaps

All four AC gaps (AC 1, 2, 3, 4) categorized as MEDIUM per the gap-analysis step. Each gap reflects the absence of automated runner-hosted tests. Substrate-verification bundle (6 Task 7 smokes — scaffold-template shape + rationale-doc shape + AGENTS.md update + CLAUDE.md update + manifest-load + sync-gate — all exit 0 byte-identical from iter-91 → iter-92) covers the substrate-contract half of AC 1-4 end-to-end at CLI-exit-code level; runtime downstream coverage (a fork actually authoring `eslint.config.fork.js` + running `pnpm lint` + layering rules; a fork actually copying the scaffold template; Epic 15a's `create-keel-app --include-fork-invariants` flag default-`false` enforcement) is explicitly carved out of Story 1.16 scope per the story's § Acceptance Criteria scope carve-outs.

### Low-priority gaps

_none_

---

## PHASE 3: GATE DECISION

### Verdict: **WAIVED** (10th cumulative precedent)

**Rationale (verbatim from `_bmad-output/test-artifacts/traceability/1-16-gate-decision.json`):**

> Documentation-surface substrate story whose § Dev Notes → Testing Standards (story v1.2 iter-90 ATDD-skip Change Log row) explicitly defers per-AC automated coverage to Story 1.16-test-runner-landing (Epic 13 scope) + Epic 15a CLI tests (AC 4 runtime enforcement) via hybrid ground-(c) variant-(ii)+(iii) ATDD-skip clause.

**Three grounds, in conjunction:**

- **(a) substrate-verification-covers-ACs** — Task 7 enumerates 6 smokes authored at iter-91 dev-story and re-verified byte-identical LIVE at iter-92 trace-time. Each smoke directly probes one or more ACs at CLI-exit-code level (scaffold-template shape → AC 3; rationale-doc shape → AC 1 + AC 3 + AC 4; AGENTS.md update → AC 1 + AC 2; CLAUDE.md update → AC 3; manifest-load → AC 4; sync-gate clean → AC 4). Story 1.9 sync-gate walks 24-entry manifest + drift-detects 2 new sha256 content-hashes + 2 new INVARIANTS.md anchors on every commit via content-hash pinning.
- **(b) no test runner at Story 1.16 time** — Epic 13 delivers; confirmed at iter-92 trace-time via recursive probe for `vitest.config.*` / `jest.config.*` / `playwright.config.*` / `cypress.config.*` returning zero matches.
- **(c) HYBRID variant-(ii)+(iii)** — (ii) downstream-story-covers-integration — Epic 15a's `create-keel-app --include-fork-invariants` CLI flag (default `false` at 1.0 per AC 4) is the runtime consumer + formal integration gate for the auto-template-copy behaviour; `packages/create-keel-app/` does not yet exist (verified iter-92); AC 4 describes DOWNSTREAM consumer behaviour EXPLICITLY CARVED OUT of Story 1.16 scope. First-half of AC 3 (scaffold template + CLAUDE.md contract row) is substrate-covered + drift-detected; second-half (fork-operator opts in by copying template) is an operational ACTION that materializes when a fork actually copies the template — post-M0 ops + Epic 15a runtime. (iii) spec-declared-CR-substitution — § Testing Standards "Adversarial coverage (deferred to CR pass)" subsection affirmatively declares AC 1 + AC 2 + AC 3 + AC 4 adversarial coverage is delegated to `/bmad-code-review (args: "2")` Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out at iter-94.

**Deterministic FAIL signal is a structural false-positive.** The overall 0% coverage reported in Phase 1 is accurate (zero runner-hosted tests exist; overall_coverage_minimum 80% per `test-priorities-matrix.md`), but the coverage-gap is NOT a design defect — it reflects the absence of a test runner at Story 1.16 substrate landing time. The WAIVED verdict is the correct gate outcome per the three-ground rationale above; the FAIL bit on Phase 1 is a mechanical artefact of the coverage calculator, not a quality-gate blocker.

**Tenth cumulative WAIVED precedent for substrate stories in Epic 1:**

| Story | Iter | Surface class                                                       |
| ----- | ---- | ------------------------------------------------------------------- |
| 1.7   | 4    | Knowledge-files substrate                                           |
| 1.8   | 3    | Contract-only (INVARIANTS.md + manifest.ts pre-authoring)           |
| 1.9   | 3    | Data-only (Zod schema + raw-array contract populator)               |
| 1.10  | 46   | Emitter+tooling (design-token schema + rationale)                   |
| 1.11  | 57   | Gate-authoring (design-token source direction A baseline)           |
| 1.12  | 64   | Gate-authoring (token emitter pipeline)                             |
| 1.13  | 71   | Gate-authoring (token quality-gates)                                |
| 1.14  | 78   | Configuration-surface (release-please monorepo config)              |
| 1.15  | 85   | Configuration-surface (Renovate I7 dependency-upgrade policy)       |
| 1.16  | 92   | Documentation-surface (fork-extension pattern + INVARIANTS.fork.md) |

Story 1.16's documentation-surface class is NEW vs prior substrate stories (scaffold-template + rationale-doc + 3 knowledge-file edits across 5 surfaces vs 1.15's 1 JSON-config + 1 rationale-doc), but the substrate-authoring + drift-detection + WAIVED-rationale posture is identical. The 10-story WAIVED streak reflects substrate authoring as the dominant Epic-1 work class; Story 1.16 closes Epic 1's substrate authoring.

### Post-Story-1.16 forward paths

- **iter-93**: `/bmad-create-story (args: "review")` — post-dev SM requirements-satisfaction review. SIXTH cumulative ZERO-PATCH precedent candidate (Stories 1.11/1.12/1.13/1.14/1.15 → 1.16).
- **iter-94**: `/bmad-code-review (args: "2")` — SIXTH cumulative ZERO-PATCH CR precedent candidate. Three-layer adversarial fan-out (Blind Hunter + Edge Case Hunter + Acceptance Auditor) validates AC 1-4 adversarially across the scaffold template + rationale doc + AGENTS.md + CLAUDE.md + INVARIANTS.md + manifest entries.
- **iter-95**: Transition PR #226 Draft → Open + final CI gate via `gh pr ready && gh pr checks --watch --fail-fast` + EPIC_DONE halt. Story 1.16 is the FINAL open story in Epic 1 — post-done, Epic 1 = done and PR #226 transitions from Draft (20+ commits across Stories 1.8-1.16) to Open for final CI gate review.

### Story 1.16 test-runner unlocks optional per-AC probes

When Epic 13 lands the test runner (vitest/jest), Story 1.16's ACs unlock optional probes:

- **AC 1 probe** — code-review-driven documentation-fidelity probe (currently CR-delegated; runner-hosted variant would parse AGENTS.md § Fork extension + assert the code-block shape + subpath-export reference present).
- **AC 2 probe** — amendment-vs-fork decision-tree exhaustiveness check + flat-config precedence accuracy check (currently CR-delegated).
- **AC 3 probe** — scaffold-template shape unit test via fixture-fork that copies the template + asserts all 5 sections exist + FORK-naming-convention example present (currently covered by iter-91 smoke 1 at substrate level).
- **AC 4 probe** — Epic 15a CLI test (when `packages/create-keel-app/` is authored) asserting `--include-fork-invariants=false` is the 1.0 default + scaffold NOT copied unless flag explicitly set.

None of these block Story 1.16 `review → done` transition.

---

## PHASE 4: RECOMMENDATIONS

### Medium priority

- **Accept WAIVED posture.** Four P2 ACs cover a documentation-surface substrate story with no live test runner. Task 7 six-smoke bundle covers AC 1-4 at substrate CLI-exit-code level; all six smokes re-verified LIVE at iter-92 trace-time byte-identical to iter-91 dev-story record. Per-AC runner-hosted coverage deferred to Story 1.16-test-runner-landing + Epic 13 CI gate + Epic 15a CLI tests.
- **Story 1.16 authors the FR44 fork-extension pattern + FR45 Growth-tier INVARIANTS.fork.md scaffold substrate as a drift-detected contract** via 2 new manifest entries (`INV-fork-extension-rationale` + `INV-fork-invariants-scaffold`) at content-hash level. Any silent edit to `docs/invariants/fork.md` or `packages/keel-invariants/templates/INVARIANTS.fork.md` triggers sync-gate FAIL at pre-commit. Downstream fork operators consume the pattern by authoring `eslint.config.fork.js` at fork root + (optionally) copying the INVARIANTS.fork.md template to their fork root; Epic 15a's `--include-fork-invariants` flag (default `false` at 1.0) automates the copy when landed. AGENTS.md + CLAUDE.md knowledge-file edits are consumption-layer pointers (not manifest sourcePaths) — they evolve freely without triggering sync-gate cascade.
- **Story 1.16 test-runner landing** (Epic 13 scope) will unlock the optional per-AC probes listed above. None of these block Story 1.16 `review → done` transition.

### Low priority

- Run `/bmad-testarch-test-review` to assess test quality (no tests exist — no-op; recorded for parity with downstream pipelines).

---

## LIVE iter-92 re-verification evidence

All six Task 7 smokes re-run at iter-92 trace-time BYTE-IDENTICAL to iter-91 dev-story record:

| Smoke | Command (elided to essentials)                         | iter-91 result                                                       | iter-92 result (LIVE)                                               |
| ----- | ------------------------------------------------------ | -------------------------------------------------------------------- | ------------------------------------------------------------------- |
| 1     | Scaffold template shape (5 sections + FORK-example)    | `OK: scaffold template all 5 sections + naming example present`     | Byte-identical (Template unchanged — sha256 `167ba6b2…6218`)        |
| 2     | Rationale doc shape (10 sections + anchor)             | `OK: rationale doc all 10 sections + anchor bullet present`        | Byte-identical (Rationale doc unchanged — sha256 `be6f3d89…92f2`)   |
| 3     | AGENTS.md update (§ Fork extension + subpath + decision) | `OK: AGENTS.md § Fork extension + subpath-export + decision-tree present` | Byte-identical (AGENTS.md unchanged at iter-92)                     |
| 4     | CLAUDE.md update (INVARIANTS.fork.md + precedence)     | `OK: CLAUDE.md INVARIANTS.fork.md + precedence reference present`   | Byte-identical (CLAUDE.md unchanged at iter-92)                     |
| 5     | Manifest load (24 invariants)                          | `OK: 24 invariants`                                                  | `OK: 24 invariants` (LIVE re-verified at iter-92)                   |
| 6     | Sync-gate clean (`pnpm keel-invariants:check`)         | Exit 0 silent in **0.776s** (61.2% margin under AC 7 <2s budget)    | Exit 0 silent (LIVE re-verified at iter-92)                         |

**File hashes (`sha256sum` at iter-92 trace-time):**

- `packages/keel-invariants/templates/INVARIANTS.fork.md` → `167ba6b2a8f1153df02f7e572b1d1e31415731493b0729415f6573cc1a696218` (byte-identical to iter-91 pinned value)
- `docs/invariants/fork.md` → `be6f3d8919e7bb2b6258d768895d8a1e4d4a37c5fef95f5121f1ca878da192f2` (byte-identical to iter-91 pinned value)

**Sync-gate NFR-budget compliance (AC 7 of Story 1.9):** the walker traverses 24 manifest entries + reads 24 sourcePath file bytes + computes 24 content-hashes + re-reads INVARIANTS.md + walks 24 anchor bullets via `ANCHOR_REGEX`. Iter-91 recorded 0.776s wall-clock = 61.2% margin under the <2s AC 7 budget. Story 1.9's O(n+m) performance guarantee holds for the 24-entry manifest (n=24 entries, m=INVARIANTS.md line count) — manifest growth from Stories 1.7-1.15 aggregated to 22 pre-Story-1.16 entries; Story 1.16 adds 2 more to 24.

---

## TRACE REPORT SUMMARY

- **Gate verdict:** WAIVED (10th cumulative precedent)
- **Coverage oracle:** acceptance_criteria (formal requirements)
- **Oracle confidence:** high
- **Story class:** documentation-surface substrate (2 new authored files + 4 MODIFIED files across 3 knowledge-file edits + 1 manifest edit + 1 INVARIANTS.md edit)
- **Manifest growth:** 22 → 24 (+9%)
- **Sync-gate wall-clock:** 0.776s (iter-91 recorded; LIVE re-verified clean at iter-92 within <2s AC 7 budget)
- **New invariant IDs:** `INV-fork-extension-rationale` + `INV-fork-invariants-scaffold`
- **New INVARIANTS.md section:** `### Fork extension (Story 1.16)` H3 (between `### Dependency upgrade discipline (Story 1.15)` and `## Consumption`)
- **New AGENTS.md section:** `## Fork extension (FR44)` H2 (between `## Git / PR conventions` and `## Ralph loop`)
- **New CLAUDE.md row:** 5th row for `INVARIANTS.fork.md` in § Knowledge-file contract table + precedence paragraph
- **New directory:** `packages/keel-invariants/templates/` (first-time sibling to `src/`)
- **ATDD-skip precedent:** 10th cumulative (Stories 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14/1.15/1.16)
- **WAIVED-trace precedent:** 10th cumulative (same cohort)
- **ZERO-PATCH-CR candidate:** 6th cumulative (Stories 1.11/1.12/1.13/1.14/1.15 → 1.16)
- **Story State transition:** `in-dev → traced` (FR14n row 5)
- **Next iter-93:** `/bmad-create-story (args: "review")` — post-dev SM review (6th cumulative ZERO-PATCH candidate)
- **Next iter-94:** `/bmad-code-review (args: "2")` — 6th cumulative ZERO-PATCH CR candidate → `done`
- **Next iter-95:** PR #226 Draft → Open + final CI gate + EPIC_DONE halt
