# Story 1.16: Fork extension-config pattern + Growth-tier `INVARIANTS.fork.md` scaffold

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator who wants to extend substrate rules without editing the substrate,
I want a documented `eslint.config.fork.js extends @keel/keel-invariants/eslint` pattern (FR44 at 1.0) plus a Growth-tier `INVARIANTS.fork.md` scaffold template referenced alongside `INVARIANTS.md` in `CLAUDE.md` with explicit precedence rules (FR45 Growth-tier), and both surfaces registered as TWO enforced invariants in the Story-1.8 manifest (`INV-fork-extension-rationale` + `INV-fork-invariants-scaffold`) so the Story-1.9 sync-gate drift-detects any ad-hoc edits,
So that (a) forks can layer ESLint rules on top of substrate without modifying `packages/keel-invariants/` (substrate-wins precedence documented in `AGENTS.md` via spread-at-end convention), (b) forks can opt into a Growth-tier fork-specific invariants surface by copying `packages/keel-invariants/templates/INVARIANTS.fork.md` to their fork root + referencing it from `CLAUDE.md` (per-fork invariants ADD TO substrate rules; substrate remains authoritative for any rule registered in upstream `INVARIANTS.md`), (c) the amendment-vs-fork decision (fork-operators pushing a rule upstream as a substrate amendment PR vs forking into `eslint.config.fork.js`) is documented in `AGENTS.md` so fork maintainers don't accidentally fragment substrate discipline, (d) the fork-extension pattern + Growth-tier scaffold posture is drift-detected on every commit so silent fork-doc edits are impossible (closes FR44 at 1.0 + FR45 Growth-tier substrate authoring; Epic 15a `create-keel-app --include-fork-invariants` opt-in flag lands the runtime "copy template to fork root" wiring downstream — per AC 4 the 1.0 default is NOT to auto-create).

## Acceptance Criteria

1. **Given** a substrate-installed fork,
   **When** I follow the extension pattern documented in `AGENTS.md`,
   **Then** I can create `eslint.config.fork.js` at my fork root that imports + extends `@keel/keel-invariants/eslint`
   **And** additional fork-specific rules layer on cleanly
   **And** `pnpm lint` applies both shared + fork rules.

   **Story 1.16 scope carve-out — subpath export is already live.** The `@keel/keel-invariants/eslint` subpath export is already declared at `packages/keel-invariants/package.json:14` (`"./eslint": "./eslint.config.keel-invariants.js"`). Story 1.16 does NOT add/modify package exports; the deliverable is the DOCUMENTATION of the pattern in `AGENTS.md` + `docs/invariants/fork.md` + a reference code snippet that fork operators can copy. The runtime behaviour (a fork actually creating `eslint.config.fork.js` and running `pnpm lint`) is DOWNSTREAM (exercised by whichever first fork opts into the pattern; not in Story 1.16 scope).

   **Story 1.16 scope carve-out — "apply both shared + fork rules" = ESLint flat-config array concatenation.** Flat-config semantics: the exported array is evaluated in order; later configs override earlier ones at the same file glob. The fork-extension pattern documented in AGENTS.md pins the SPREAD-AT-END CONVENTION so substrate rules land in the final position when a fork wants substrate-wins precedence; this convention is REVERSIBLE (a fork that wants fork-wins precedence spreads substrate first). `AGENTS.md` § Fork extension explains both postures and recommends spread-at-end as the 1.0 default.

2. **Given** a fork adds rules that conflict with substrate invariants,
   **When** lint runs,
   **Then** substrate rules win (ESLint override precedence documented in `AGENTS.md`)
   **And** `AGENTS.md` explains how to request a substrate amendment vs forking.

   **Story 1.16 scope carve-out — AC 2 is a DOCUMENTATION AC.** ESLint flat-config does not enforce precedence by rule-semantic analysis — it enforces precedence by ARRAY ORDER (last-write-wins per file glob). "Substrate wins" is therefore an OPERATIONAL CONVENTION: forks that want substrate-wins spread `@keel/keel-invariants/eslint` AT THE END of their `eslint.config.fork.js` export array. `AGENTS.md` documents this convention + the amendment-vs-fork decision tree (if the disagreement is substrate-wide value, open a substrate amendment PR against `packages/keel-invariants/` per the Story 1.6 + 1.9 source-level fork path; if the disagreement is fork-specific, use `eslint.config.fork.js` with your preferred spread order).

   **Story 1.16 scope carve-out — amendment-vs-fork decision tree lives in `AGENTS.md` + `docs/invariants/fork.md`.** The decision tree has three exit paths: (a) FORK (your need is fork-specific) — author `eslint.config.fork.js` + optionally `INVARIANTS.fork.md`; (b) AMEND (your need applies to every fork) — open a PR against `packages/keel-invariants/` + `INVARIANTS.md` + manifest entry + anchor bullet (the FR32 source-level fork path per Story 1.6 + 1.9); (c) DEFER (your need is premature) — log in `deferred-work.md` for future evaluation. `docs/invariants/fork.md` holds the canonical decision tree text; `AGENTS.md` links to it.

3. **Given** the Growth-tier `INVARIANTS.fork.md` scaffold,
   **When** a fork operator opts in,
   **Then** an `INVARIANTS.fork.md` template is created at the fork root
   **And** `CLAUDE.md` is updated to reference both `INVARIANTS.md` and `INVARIANTS.fork.md` with clear precedence rules.

   **Story 1.16 scope carve-out — substrate ships the template, not the bootstrapped file.** At substrate level the scaffold TEMPLATE lives at `packages/keel-invariants/templates/INVARIANTS.fork.md` (hash-pinned as `INV-fork-invariants-scaffold` for reproducibility). "Created at the fork root" is the fork-operator OPT-IN ACTION: either (a) manual copy — `cp packages/keel-invariants/templates/INVARIANTS.fork.md ./INVARIANTS.fork.md` — then edit to add fork-specific invariants; or (b) automated copy via Epic 15a's `create-keel-app --include-fork-invariants` flag (downstream; per AC 4 default is `false` at 1.0). Story 1.16's deliverable is the TEMPLATE FILE + documentation describing the opt-in flow; the bootstrapping mechanism is Epic 15a scope.

   **Story 1.16 scope carve-out — CLAUDE.md precedence rule.** The precedence rule is: upstream `INVARIANTS.md` is AUTHORITATIVE for every rule registered in `invariants.manifest.ts` (substrate invariants — Story 1.9 sync-gate enforces); `INVARIANTS.fork.md` is ADDITIVE (forks add per-fork invariants that do NOT override substrate — if a fork rule conflicts with a substrate rule, the substrate rule wins at runtime and the fork operator must either (i) open a substrate amendment PR or (ii) carve the conflict out of their fork's rule scope). `CLAUDE.md` is updated in Task 6 to add a row to the Knowledge-file contract table + a short paragraph on precedence.

4. **Given** at 1.0 the Growth-tier scaffold is non-essential,
   **When** Epic 15a's `create-keel-app` runs in 1.0 mode,
   **Then** `INVARIANTS.fork.md` is NOT auto-created
   **And** the pattern + template are documented for fork operators to opt into manually.

   **Story 1.16 scope carve-out — AC 4 is a NEGATIVE carve-out for Epic 15a.** Epic 15a's `create-keel-app` CLI has not yet been authored (no file at `packages/create-keel-app/` at Story 1.16 landing time — confirmed by arch.md:900 `packages/keel-invariants/` tree showing `create-keel-app/` is a future package; verified at drafting time via `ls packages/` which returns `keel-invariants` only). Story 1.16 DOCUMENTS the expected behaviour (scaffold is opt-in, not auto-created at 1.0) in `docs/invariants/fork.md` § Growth-tier opt-in section. When Epic 15a lands, its AC/tests must include a regression check that `create-keel-app` does NOT copy the scaffold by default (the `--include-fork-invariants` flag must default to `false` at 1.0). Story 1.16's substrate deliverable is the TEMPLATE + the DOC describing the expected opt-in flow; the CLI enforcement is Epic 15a scope.

## Tasks / Subtasks

- [ ] **Task 1: Author `packages/keel-invariants/templates/INVARIANTS.fork.md` (Growth-tier scaffold template)** (AC: 3, 4)
  - [ ] Create the `packages/keel-invariants/templates/` directory if it does not exist (first-time directory addition under `packages/keel-invariants/`; sibling to `src/` + existing config files).
  - [ ] Author `packages/keel-invariants/templates/INVARIANTS.fork.md` as the canonical scaffold template. Canonical shape (pinned here so dev-story does not drift; all sections required unless labelled `optional`):
    ```markdown
    # INVARIANTS.fork.md — fork-specific machine-enforced rules

    **Audience:** any AI agent or human contributor working in this fork.
    **Companion to:** upstream `INVARIANTS.md` (substrate rules from `packages/keel-invariants/`).

    This file is the fork-specific counterpart to upstream `INVARIANTS.md`. Every entry here is a fork-added rule that does NOT exist in substrate. Substrate rules take precedence — if a fork rule conflicts with a substrate rule, the substrate rule wins (see `docs/invariants/fork.md` § Precedence).

    ## Precedence

    1. **Substrate rules** (upstream `INVARIANTS.md`; pinned by `packages/keel-invariants/src/invariants.manifest.ts`) are AUTHORITATIVE. Story 1.9's sync-gate drift-detects edits.
    2. **Fork rules** (this file) ADD TO substrate rules. Forks CANNOT override substrate; attempts to do so fail at lint/gate time (substrate-wins convention).
    3. **Conflict resolution:** if a fork rule conflicts with a substrate rule, open a substrate amendment PR (see `docs/invariants/fork.md` § Amendment-vs-fork decision tree) OR narrow the fork rule's scope to avoid the conflict.

    ## Fork invariants index

    <!-- Add fork-specific stable IDs below, matching the upstream naming convention:
         ## Example category (why it's fork-specific, not substrate)

         - **`FORK-<fork-slug>-<category>-<slug>`** — one-line description. Source: `<fork-repo-relative-path>`.

         Example:
         - **`FORK-acme-tenancy-region-lock`** — b2b fork with EU-only residency pins `app.current_region = 'eu-west'` in tenancy middleware. Source: `packages/contracts/middleware/region-lock.ts`.
    -->

    _(add fork-specific invariants here)_

    ## Consumption

    - Agents (Claude Code, etc.) read this file alongside upstream `INVARIANTS.md` per `CLAUDE.md` knowledge-file contract.
    - Fork-specific lint/gate tooling (if the fork authors any) consumes these IDs via a fork-specific manifest analogous to `packages/keel-invariants/src/invariants.manifest.ts` — not provided by substrate.

    ## Extension

    To add a fork invariant, follow the upstream naming convention (`FORK-<fork-slug>-<category>-<slug>`; ≥ 2 hyphen-separated segments after the `FORK-<slug>-` prefix; all lowercase; no underscores) and add a one-line entry under the appropriate H3 section above. Commit alongside the source file being enforced.
    ```
  - [ ] Prettier-format: `pnpm exec prettier --write packages/keel-invariants/templates/INVARIANTS.fork.md`.
  - [ ] Compute the sha256 content hash for the manifest entry (Task 3). Command: `sha256sum packages/keel-invariants/templates/INVARIANTS.fork.md` (post-prettier).
  - [ ] **Validity sanity-check at author-time (pre-dev-story).** `node -e "const s=require('fs').readFileSync('packages/keel-invariants/templates/INVARIANTS.fork.md','utf8'); if (!/^# INVARIANTS\.fork\.md/m.test(s)) throw new Error('missing H1'); if (!/## Precedence/m.test(s)) throw new Error('missing Precedence section'); if (!/## Fork invariants index/m.test(s)) throw new Error('missing index section'); if (!/^FORK-<fork-slug>/m.test(s) && !/FORK-<fork-slug>-<category>-<slug>/.test(s)) throw new Error('missing fork-ID naming example'); console.log('OK: scaffold template shape valid');"` must print `OK: scaffold template shape valid`.

- [ ] **Task 2: Author `docs/invariants/fork.md` (rationale doc: ESLint-extend pattern + INVARIANTS.fork scaffold + precedence + amendment-vs-fork decision tree + fork-operator pointer)** (AC: 1, 2, 3, 4)
  - [ ] Author `docs/invariants/fork.md` as a plain markdown documentation file (mirrors `docs/invariants/release.md` Story 1.14 + `docs/invariants/renovate.md` Story 1.15 + `docs/invariants/tokens.md` Story 1.10 + `docs/invariants/ralph-execute.md` Story 1.9 precedents). Structure:
    - H1: `# Fork extension — eslint.config.fork.js + INVARIANTS.fork.md scaffold (Story 1.16)`
    - Header block (4 lines): Scope + Status + Machine-enforced-in + Runtime consumer (same shape as `release.md:3-6` + `renovate.md:3-6`).
    - § Overview — one paragraph summarizing FR44 (ESLint-extend pattern at 1.0) + FR45 (Growth-tier INVARIANTS.fork.md scaffold) + substrate-wins convention.
    - § ESLint-extend pattern (FR44) — points at `packages/keel-invariants/package.json:14` `./eslint` subpath export; shows a code block example `eslint.config.fork.js`:
      ```js
      import sharedConfig from '@keel/keel-invariants/eslint';

      export default [
        // fork-specific rules first (overridden by substrate at same glob)
        {
          rules: {
            // your fork-specific rules here
          },
        },
        // substrate LAST (substrate-wins convention per docs/invariants/fork.md)
        ...sharedConfig,
      ];
      ```
      Explains spread-at-end convention for substrate-wins + spread-at-start for fork-wins + default posture is substrate-wins.
    - § INVARIANTS.fork.md scaffold (FR45 Growth-tier) — explains the opt-in flow: fork operator copies `packages/keel-invariants/templates/INVARIANTS.fork.md` to their fork root (manual `cp` at 1.0; Epic 15a's `create-keel-app --include-fork-invariants` flag automates later); then adds fork-specific `FORK-<fork-slug>-<category>-<slug>` invariants; then updates their fork's `CLAUDE.md` to reference both upstream `INVARIANTS.md` + new `INVARIANTS.fork.md`.
    - § Precedence — pins the three-layer precedence rule verbatim (substrate authoritative, fork additive, conflicts via amendment-or-scope-narrowing).
    - § Amendment-vs-fork decision tree — three exit paths: FORK (fork-specific need) / AMEND (substrate-wide need via Story 1.6 + 1.9 source-level fork path) / DEFER (premature need; log in `_bmad-output/implementation-artifacts/deferred-work.md`). Each path has 2-3 sentences with concrete examples.
    - § Growth-tier opt-in — 2 sentences: at 1.0 `create-keel-app` does NOT auto-create `INVARIANTS.fork.md` per AC 4; Epic 15a ships the `--include-fork-invariants` flag (default `false`) when it lands. Forks that want the scaffold today copy the template manually.
    - § Files — lists the two new markdown files (this file + the template) + the two new manifest invariants + the `INV-fork-extension-rationale` self-reference (following the `release.md:10` + `renovate.md:14` self-anchor pattern).
    - § Fork extension — 2 sentences matching the `release.md:48` + `renovate.md:44` pattern: forks that want to change the fork-extension pattern itself (e.g., a fork-of-a-fork nesting pattern) edit substrate files as a source-fork change per Story 1.6 + 1.9; this is meta-recursive but the path is the same.
    - § Consumption — points at `AGENTS.md § Fork extension (FR44)` as the primary agent-facing doc + Epic 15a's future `create-keel-app --include-fork-invariants` CLI flag as the runtime consumer of the scaffold template.
    - § Anchor — add the `- **\`INV-fork-extension-rationale\`**: FR44 ESLint-extend pattern + FR45 Growth-tier INVARIANTS.fork.md scaffold + substrate-wins precedence + amendment-vs-fork decision tree.` anchor bullet at the end of the § Overview section so the Story 1.9 walker (column-0 bullet matching `packages/keel-invariants/src/sync-gate.ts:24` ANCHOR_REGEX) detects it.
  - [ ] Prettier-format: `pnpm exec prettier --write docs/invariants/fork.md`.
  - [ ] Compute the sha256 content hash for the manifest entry.

- [ ] **Task 3: Add 2 new invariant entries to `packages/keel-invariants/src/invariants.manifest.ts` → `raw` array** (AC: 3, 4)
  - [ ] Add two entries to the `raw: Invariant[]` array at the end (post the existing `INV-renovate-rationale` at line 217-223; preserve the existing 22 entries in their current order). Shape of each entry matches the Story 1.10/1.11/1.12/1.13/1.14/1.15 precedents:
    ```ts
    {
      id: 'INV-fork-extension-rationale',
      description:
        "Documentation-layer rationale for the FR44 fork-extension pattern + FR45 Growth-tier INVARIANTS.fork.md scaffold — docs/invariants/fork.md; mirrors Story 1.10's INV-tokens-semantic-rationale + Story 1.14's INV-release-please-rationale + Story 1.15's INV-renovate-rationale pattern (companion doc to a machine-enforced substrate surface, drift-detected at the doc layer). Explains (a) the FR44 ESLint-extend pattern — forks author eslint.config.fork.js importing @keel/keel-invariants/eslint via the subpath export already declared at packages/keel-invariants/package.json:14, with spread-at-end convention for substrate-wins precedence, (b) the FR45 Growth-tier INVARIANTS.fork.md scaffold opt-in flow — fork operators copy packages/keel-invariants/templates/INVARIANTS.fork.md to their fork root + reference from their CLAUDE.md, (c) substrate-wins precedence rule + amendment-vs-fork decision tree (FORK / AMEND via Story 1.6 + 1.9 source-level path / DEFER), (d) Growth-tier opt-in — at 1.0 create-keel-app does NOT auto-create; Epic 15a's --include-fork-invariants flag lands downstream per AC 4. Companion to INV-fork-invariants-scaffold.",
      sourcePath: 'docs/invariants/fork.md',
      contentHash: '<sha256 from Task 2>',
      anchors: ['INV-fork-extension-rationale'],
    },
    {
      id: 'INV-fork-invariants-scaffold',
      description:
        "Growth-tier INVARIANTS.fork.md scaffold template — packages/keel-invariants/templates/INVARIANTS.fork.md; fork-operator opt-in source for the fork-specific invariants surface (FR45). Ships a canonical template with H1 + § Precedence + § Fork invariants index + § Consumption + § Extension sections + a commented FORK-<fork-slug>-<category>-<slug> naming-convention example. Fork operators copy this file to their fork root (manual cp at 1.0; Epic 15a's create-keel-app --include-fork-invariants flag automates later per AC 4 downstream). Substrate-wins precedence rule pinned verbatim in the template's § Precedence section; fork rules ADD TO substrate rules but CANNOT override them (substrate-wins convention). Inert substrate until a fork operator opts in; static drift detected by Story 1.9 pre-merge sync-gate (FR43).",
      sourcePath: 'packages/keel-invariants/templates/INVARIANTS.fork.md',
      contentHash: '<sha256 from Task 1>',
      anchors: ['INV-fork-invariants-scaffold'],
    },
    ```
  - [ ] Verify the schema refinement (`superRefine` uniqueness + cross-sourcePath contentHash parity) holds after the additions. The two new entries have unique IDs + unique sourcePaths; no shared-sourcePath cross-entry check fires.
  - [ ] **Build + runtime-smoke.** `cd packages/keel-invariants && pnpm build && node -e "import('./dist/invariants.manifest.js').then(m => console.log('OK: ' + m.invariants.length + ' invariants'))"` from `packages/keel-invariants/` to confirm the manifest parses + exports **24** entries (22 current + 2 new). **IMPORTANT** per Story 1.14 iter-77 Gotcha — the `pnpm keel-invariants:check` script reads `dist/check.js` which imports the COMPILED manifest, NOT the TS source; editing `invariants.manifest.ts` requires a `pnpm --filter @keel/keel-invariants build` before `pnpm keel-invariants:check` observes the new entries.

- [ ] **Task 4: Add 2 anchor bullets to `INVARIANTS.md` under a new `### Fork extension (Story 1.16)` section** (AC: 3, 4)
  - [ ] Insert a new `### Fork extension (Story 1.16)` H3 section in `INVARIANTS.md` between the existing `### Dependency upgrade discipline (Story 1.15)` section (ends at line 80) and the `## Consumption` H2 at line 82. The section opens with a one-sentence summary ("FR44 ESLint-extend pattern (`eslint.config.fork.js` importing `@keel/keel-invariants/eslint`) + FR45 Growth-tier `INVARIANTS.fork.md` scaffold template; substrate-wins precedence via spread-at-end convention; fork operators opt into the Growth-tier scaffold manually at 1.0 (Epic 15a's `--include-fork-invariants` flag lands later).") and lists two column-0 bullets (matching the Story 1.9 `ANCHOR_REGEX` shape `^-\s+\*\*\`INV-[a-z0-9]+(?:-[a-z0-9]+)+\`\*\*`):
    - `- **\`INV-fork-extension-rationale\`**: docs/invariants/fork.md — FR44 ESLint-extend pattern + FR45 Growth-tier INVARIANTS.fork.md scaffold + substrate-wins precedence + amendment-vs-fork decision tree.`
    - `- **\`INV-fork-invariants-scaffold\`**: packages/keel-invariants/templates/INVARIANTS.fork.md — Growth-tier fork-invariants template with H1 + § Precedence + § Fork invariants index + § Consumption + § Extension + commented FORK-\<fork-slug\>-\<category\>-\<slug\> naming example.`
  - [ ] Re-compute the contentHash of `INVARIANTS.md` is NOT needed — INVARIANTS.md is not a `sourcePath` in the manifest (it is the ANCHOR DOC walked by Story 1.9 via `ANCHOR_REGEX`; the walker re-reads the doc on every sync-gate invocation, so the doc's content hash is recomputed at runtime rather than pinned as a manifest field) — same contract as Story 1.14 Task 5 + Story 1.15 Task 4.
  - [ ] Prettier-format: `pnpm exec prettier --write INVARIANTS.md`.

- [ ] **Task 5: Update `AGENTS.md` — new `## Fork extension (FR44)` section + ESLint-extend pattern + precedence + amendment-vs-fork decision** (AC: 1, 2)
  - [ ] Insert a new `## Fork extension (FR44)` section in `AGENTS.md` between the existing `## Git / PR conventions` section (ends at line 54) and the `## Ralph loop` section (starts at line 56). The section covers:
    - **ESLint-extend pattern.** Fork operators extend ESLint rules by creating `eslint.config.fork.js` at the fork root that imports `@keel/keel-invariants/eslint` (subpath export already declared at `packages/keel-invariants/package.json:14`). Code block (single copy-ready example — same code block that lives in `docs/invariants/fork.md` for consistency; one line commenting the substrate-wins convention):
      ```js
      import sharedConfig from '@keel/keel-invariants/eslint';

      export default [
        { rules: { /* fork-specific rules */ } },
        ...sharedConfig, // substrate LAST → substrate wins (docs/invariants/fork.md § Precedence)
      ];
      ```
    - **Precedence rule.** Substrate rules take precedence over fork rules at the same file glob (via ESLint flat-config last-write-wins semantics + spread-at-end convention). If a fork needs the opposite posture (fork-wins), spread substrate FIRST; this is unusual and should be accompanied by a comment in the fork's `eslint.config.fork.js` explaining why.
    - **Amendment-vs-fork decision.** Three paths when a fork disagrees with substrate: (a) FORK — fork-specific need, use `eslint.config.fork.js`; (b) AMEND — substrate-wide need, open a PR against `packages/keel-invariants/` + `INVARIANTS.md` + manifest entry + anchor (Story 1.6 + 1.9 source-level fork path); (c) DEFER — premature need, log in `_bmad-output/implementation-artifacts/deferred-work.md`.
    - **Growth-tier `INVARIANTS.fork.md`.** Pointer: see `docs/invariants/fork.md` § INVARIANTS.fork.md scaffold for the Growth-tier opt-in flow; `create-keel-app --include-fork-invariants` (Epic 15a) is the downstream runtime automating the manual template copy.
  - [ ] No manifest entry for `AGENTS.md` is needed — AGENTS.md is a KNOWLEDGE FILE (general ops guide) not a substrate invariant source; it evolves frequently and hashing it would cause churn without signal. The fork-extension pattern itself is hash-pinned via `INV-fork-extension-rationale` (`docs/invariants/fork.md`); `AGENTS.md` is a consumption-layer pointer to the rationale doc.

- [ ] **Task 6: Update `CLAUDE.md` — add `INVARIANTS.fork.md` to knowledge-file contract + precedence rule** (AC: 3)
  - [ ] Update the `## Knowledge-file contract` table in `CLAUDE.md` (currently 4 rows: AGENTS.md, CLAUDE.md, RALPH.md, INVARIANTS.md) to add a 5th row for `INVARIANTS.fork.md`:
    ```
    | `INVARIANTS.fork.md` (Growth-tier, optional) | Fork-specific agent/human — machine-enforced rules | Fork-owned additive rules to upstream INVARIANTS.md; substrate rules take precedence (FR45; docs/invariants/fork.md § Precedence). Not present at 1.0 — fork operators opt in by copying packages/keel-invariants/templates/INVARIANTS.fork.md to repo root. |
    ```
  - [ ] Add a sentence after the table (or in the `## Claude Code specifics` section) pointing at `docs/invariants/fork.md` for the opt-in flow + precedence rules.
  - [ ] No manifest entry for `CLAUDE.md` is needed — same reasoning as Task 5 for AGENTS.md (CLAUDE.md is a knowledge-file consumption-layer pointer, not an invariant source).

- [ ] **Task 7: Substrate verification — scaffold shape, rationale-doc shape, manifest-load clean, sync-gate clean, full quality-gate suite** (AC: 1, 2, 3, 4)
  - [ ] **Static scaffold shape smoke:** `node -e "const s=require('fs').readFileSync('packages/keel-invariants/templates/INVARIANTS.fork.md','utf8'); const sections=['# INVARIANTS.fork.md','## Precedence','## Fork invariants index','## Consumption','## Extension']; const missing=sections.filter(sec => !s.includes(sec)); if (missing.length) throw new Error('missing sections: ' + missing.join(', ')); if (!/FORK-<fork-slug>/.test(s)) throw new Error('missing FORK-<fork-slug> naming convention example'); console.log('OK: scaffold template all 5 sections + naming example present');"` must print `OK: scaffold template all 5 sections + naming example present`.
  - [ ] **Static rationale-doc shape smoke:** `node -e "const s=require('fs').readFileSync('docs/invariants/fork.md','utf8'); const sections=['# Fork extension','## Overview','## ESLint-extend pattern','## INVARIANTS.fork.md scaffold','## Precedence','## Amendment-vs-fork decision tree','## Growth-tier opt-in','## Files','## Fork extension','## Consumption']; const missing=sections.filter(sec => !s.includes(sec)); if (missing.length) throw new Error('missing sections: ' + missing.join(', ')); if (!/INV-fork-extension-rationale/.test(s)) throw new Error('missing anchor bullet'); console.log('OK: rationale doc all 10 sections + anchor bullet present');"` must print `OK: rationale doc all 10 sections + anchor bullet present`.
  - [ ] **AGENTS.md update smoke:** `node -e "const s=require('fs').readFileSync('AGENTS.md','utf8'); if (!/## Fork extension \(FR44\)/.test(s)) throw new Error('missing AGENTS.md § Fork extension'); if (!/@keel\/keel-invariants\/eslint/.test(s)) throw new Error('missing subpath-export reference'); if (!/amendment/i.test(s) || !/decision/i.test(s)) throw new Error('missing amendment-vs-fork decision tree keywords'); console.log('OK: AGENTS.md § Fork extension + subpath-export + decision-tree present');"` must print `OK: AGENTS.md § Fork extension + subpath-export + decision-tree present`.
  - [ ] **CLAUDE.md update smoke:** `node -e "const s=require('fs').readFileSync('CLAUDE.md','utf8'); if (!/INVARIANTS\.fork\.md/.test(s)) throw new Error('missing CLAUDE.md INVARIANTS.fork.md reference'); if (!/precedence/i.test(s)) throw new Error('missing precedence keyword'); console.log('OK: CLAUDE.md INVARIANTS.fork.md + precedence reference present');"` must print `OK: CLAUDE.md INVARIANTS.fork.md + precedence reference present`.
  - [ ] **Manifest load smoke:** `cd packages/keel-invariants && pnpm build && node -e "import('./dist/invariants.manifest.js').then(m => console.log('OK: ' + m.invariants.length + ' invariants'))"` — must print `OK: 24 invariants` (22 pre-Story-1.16 + 2 new). Per Story 1.14 iter-77 Gotcha, the `pnpm build` step is MANDATORY before runtime smoke.
  - [ ] **Sync-gate clean smoke:** from repo root, `pnpm keel-invariants:check` must exit 0 with no drift. This is the Story 1.9 AC 1 clean-path behaviour. If the gate emits drift (e.g. a stale contentHash, a missing anchor, a missing source file), FIX in the same iteration BEFORE commit — iteration budget is a blocker (drift under own PR is a quality-gate violation per NFR27).
  - [ ] **Full quality-gate suite:** `pnpm typecheck && pnpm lint && pnpm format:check && pnpm keel-invariants:check-all`. All must pass. `keel-invariants:check-all` runs the Story 1.9 sync-gate + Story 1.13 token-sync gate in sequence; the two new invariants should register clean at the former; the latter is unaffected (no token-layer change in Story 1.16).
  - [ ] **Record measurements** in § Dev Agent Record → Debug Log: sha256 values computed at Tasks 1/2, wall-clock of each smoke test, `pnpm keel-invariants:check` duration (Story 1.9 pinned <2s per AC 7; should hold comfortably — manifest grows from 22 → 24 entries, +9% vs Story 1.15's +10%; walker is O(n+m) so negligible).

## Dev Notes

### Carry-forward from Story 1.15 (iter-87 ZERO-PATCH CR precedent — FIFTH cumulative)

Story 1.15 completed a 7-iteration `drafted → done` lifecycle (iter-81 → iter-87) with the FIFTH cumulative ZERO-PATCH CR outcome (Stories 1.11/1.12/1.13/1.14/1.15). The compound discipline that held is pre-staged here verbatim (TENTH cumulative Epic-1 ATDD-skip precedent candidate + TENTH cumulative WAIVED-trace candidate + SIXTH cumulative ZERO-PATCH CR candidate for Story 1.16):

- **Seven preventative audit layers pre-applied at drafting time** (iter-53/54/56/59/60/67/74/81 compound — see RALPH.md § Lessons for the framing):
  - **L1 — stable IDs for new enforced invariants.** Two new IDs registered here: `INV-fork-extension-rationale` (companion rationale doc, mirroring Story 1.10 + 1.14 + 1.15 rationale-doc convention) and `INV-fork-invariants-scaffold` (substrate template source). Both match the Zod regex `^INV-[a-z0-9]+(-[a-z0-9]+)+$` at `invariants.manifest.ts:4` (verified at drafting-time by mentally parsing each against the regex): `INV-fork-extension-rationale` = 3 segments (fork / extension / rationale); `INV-fork-invariants-scaffold` = 3 segments (fork / invariants / scaffold); all lowercase; no uppercase; no underscores; ≥ 2 hyphenated segments each. Epic 1.16 ACs do NOT pin specific IDs (contrast Story 1.15 AC 4 which pinned `INV-deps-version-pinning` verbatim), so these are pattern-match IDs selected by the Story 1.10/1.14/1.15 rationale-doc + scaffold-surface conventions.
  - **L2 — task-enumeration-vs-consumer-requirement diff.** Every AC has ≥1 Task: AC 1 → Tasks 2, 5 + Task 7 (AGENTS.md update smoke + rationale-doc smoke); AC 2 → Tasks 2, 5 + Task 7 (AGENTS.md update smoke); AC 3 → Tasks 1, 2, 3, 4, 6 + Task 7 (scaffold + rationale-doc + manifest + anchor bullets + CLAUDE.md); AC 4 → Tasks 2, 6 + Task 7 (rationale-doc Growth-tier opt-in section + CLAUDE.md). Every Task serves ≥1 AC. No Task is an explicit no-op (contrast Story 1.14 Task 6 + Story 1.15 Task 5 — both substrate-story no-ops confirming no script/hook cascade); Story 1.16's Task 5 + Task 6 edit knowledge files (AGENTS.md + CLAUDE.md) that are NOT invariant sourcePaths, so no cascade hash update fires.
  - **L3 — sprint-status transition wording.** At drafting-time, this iteration flips `1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold: backlog → ready-for-dev` in `_bmad-output/implementation-artifacts/sprint-status.yaml:61` + bumps `last_updated` to `2026-04-21 Story-1-16-drafted UTC` (matches Story 1.15 iter-81 wording pattern).
  - **L4 — cross-file convergence.** Architecture.md:49 (§ Requirements Overview — FR41–FR45 Invariants cluster enumeration) + :777 (FR → Artefact mapping table — FR41–FR45 Invariants → `packages/keel-invariants/`, `INVARIANTS.md`, `docs/invariants/`) + :906 (directory-tree annotation `FR42–FR44 (hardwired invariants)`) cover the substrate-packages declaration in architecture.md. Epics.md:1110-1137 authors the four ACs verbatim. PRD.md:1010 (FR44) + :1011 (FR45) authors the functional-requirement commitment. Architecture.md does NOT contain detailed FR44/FR45 prose (the normative statement lives in PRD.md:1010-1011) and does NOT mention `INVARIANTS.fork.md` directly; it references the substrate folders through the FR → Artefact mapping table. This drafting therefore treats PRD.md:1010-1011 as the FR44/FR45 normative statement and architecture.md:49/:777/:906 as the substrate-packages declaration. All three sources (epics + prd + architecture) align on the fork-extension pattern + Growth-tier scaffold posture; no drift between normative statement and substrate placement.
  - **L5 — mechanical counter derivation per iter-76 lesson.** Don't copy-paste counters from prior stories — compute from sprint-status live. Story 1.7 iter-2 = 1st ATDD-skip; 1.8 = 2nd; 1.9 = 3rd; 1.10 = 4th; 1.11 = 5th; 1.12 = 6th; 1.13 = 7th; 1.14 = 8th; 1.15 = 9th → **Story 1.16 = 10th cumulative Epic-1 ATDD-skip candidate** (also 10th WAIVED-trace candidate + SIXTH ZERO-PATCH-CR candidate). Verified at drafting time by scanning sprint-status.yaml:60-62: `1-15-...: done`, `1-16-...: backlog`, `epic-1-retrospective: optional`. Story 1.16 is the FINAL open story in Epic 1 — post-done transitions PR #226 Draft→Open + final CI gate + EPIC_DONE halt.
  - **L6 — schema-permission diff (renamed to "no-cascade-hash check" for substrate stories per Story 1.14 carry-forward).** Story 1.16 edits: (a) two NEW files (`packages/keel-invariants/templates/INVARIANTS.fork.md` + `docs/invariants/fork.md`); (b) `packages/keel-invariants/src/invariants.manifest.ts` (manifest entries); (c) `INVARIANTS.md` (anchor bullets); (d) `AGENTS.md` (new § Fork extension section); (e) `CLAUDE.md` (knowledge-file table row + precedence paragraph). Files (a)+(b)+(c)+(d)+(e) are all edited by this story; no OTHER manifest entries share sourcePaths with these files, so no cross-entry contentHash update fires per Story 1.9 iter-4 lesson. Explicit carve-out: `INVARIANTS.md` is NOT a sourcePath (it is the ANCHOR DOC walked by `ANCHOR_REGEX`); `AGENTS.md` + `CLAUDE.md` are NOT sourcePaths (knowledge files, not substrate invariants). Only Task 3 computes new content hashes (for the two new invariants at new sourcePaths).
  - **L7 — domain-specific carve-out for fork-extension-pattern scaffolding.** Story 1.16 is a SCAFFOLDING STORY (matches Story 1.15 renovate config carve-out class but operates on DOCUMENTATION + TEMPLATE surfaces, not a CONFIG FILE surface). The four ACs collectively produce: 2 new markdown files + 2 new manifest entries + 2 anchor bullets + 2 knowledge-file edits (AGENTS.md + CLAUDE.md). Surface is slightly larger than Story 1.15's 1 JSON + 1 markdown + 2 manifest + 2 anchors (Story 1.16 adds 2 knowledge-file edits due to AC 1 + AC 3 explicit knowledge-file mandates). Configuration-surface tier — within the same adversarial-triage attack surface as Stories 1.14/1.15 (static content authored once, drift-detected on every commit, inert until a downstream opts-in consumer fires). ZERO-PATCH discipline carries forward.

### Previous story intelligence (from Story 1.15 iter-81..87 lifecycle)

- **Rationale doc shape is pre-proven.** Stories 1.10 + 1.14 + 1.15 all produced `docs/invariants/<domain>.md` rationale docs with the same header block + § Overview + § Files + § <domain> rules + § Grouping/Fork extension + § Consumption + § Anchor structure. Story 1.16's `docs/invariants/fork.md` follows the identical shape. DO NOT invent a new doc structure; copy the Story 1.14/1.15 pattern exactly.
- **Scaffold template shape is novel at Story 1.16.** Story 1.16 is the first substrate story shipping a TEMPLATE FILE (distinct from a rationale doc). The template is a canonical source that fork operators copy to their fork root. The template's shape (H1 + § Precedence + § Fork invariants index + § Consumption + § Extension) is designed to mirror the upstream `INVARIANTS.md` shape (Section headers + anchor bullets) so fork operators see structural continuity when comparing upstream-to-fork.
- **AGENTS.md § Fork extension is NEW — no prior story has edited AGENTS.md to add a fork-extension section.** Prior edits to AGENTS.md happened via Story 1.7 (knowledge-files substrate); this is the first post-Story-1.7 AGENTS.md edit that adds a new H2 section. Dev-story should use a surgical Edit (NOT full file rewrite) to insert the new section between `## Git / PR conventions` + `## Ralph loop` per Task 5.
- **CLAUDE.md knowledge-file-contract table is pre-existing.** Story 1.7 shipped the 4-row table (AGENTS.md, CLAUDE.md, RALPH.md, INVARIANTS.md). Story 1.16 adds a 5th row for `INVARIANTS.fork.md`. Dev-story should use a surgical Edit to append the row (NOT replace the table).
- **Prettier treatment per Story 1.15 Task 1 precedent.** The 2 new markdown files pass through `pnpm exec prettier --write` before content-hash computation. Same protective posture as Story 1.15 Task 1 (renovate.json prettier-format before sha256).
- **Build-before-smoke per Story 1.14 iter-77 gotcha.** The `packages/keel-invariants/` build artifact is required before `pnpm keel-invariants:check` observes new invariants. Task 7 pins `pnpm build` BEFORE the runtime smoke explicitly.
- **Sync-gate clean smoke is the gate that closes the Dev loop.** `pnpm keel-invariants:check` walks every manifest entry, computes live sha256 per sourcePath, compares to pinned contentHash, and asserts every anchor bullet resolves. Story 1.16's 2 new entries must register clean; if drift fires, FIX before commit.

### Git intelligence summary

Recent commits (last 5 from `git log --oneline`):
- `f4772f7 chore(ralph): Story 1.15 iter-87 — /bmad-code-review FIFTH ZERO-PATCH CR; sm-verified → done`
- `223ab88 chore(ralph): Story 1.15 iter-86 — /bmad-create-story review post-dev SM FIFTH ZERO-PATCH; traced → sm-verified`
- `db55a2b chore(ralph): Story 1.15 iter-85 — /bmad-testarch-trace NINTH cumulative WAIVED; in-dev → traced`
- `2137c83 feat(story-1-15): dev-story — Renovate I7 version-pinning config + 2 invariants`
- `310e6b6 chore(ralph): Story 1.15 iter-83 — /bmad-testarch-atdd NINTH cumulative ATDD-SKIP; validated → atdd-scaffolded`

Pattern: Story 1.15 shipped 5 commits across 7 iterations (iter-81 drafting + iter-82 pre-dev SM review + iter-83 ATDD scaffold + iter-84 dev-story + iter-85 trace + iter-86 post-dev SM + iter-87 CR). One `feat(story-1-15): dev-story` commit carried the actual code change; the other 4 were `chore(ralph): ...` iteration-bookkeeping commits. Story 1.16 follows the same cadence: iter-88 (this) drafting is `chore(ralph): Story 1.16 iter-88 — /bmad-create-story _(no story) → drafted`.

### Latest technical information

- **ESLint flat-config precedence.** As of ESLint 9 (flat-config default), the exported `eslint.config.*.js` is an array evaluated in order; later entries override earlier entries at the same file glob. This is the semantic AGENTS.md § Fork extension documents. No ESLint version-update concern for Story 1.16 (flat config is the 1.0 baseline per `packages/keel-invariants/eslint.config.keel-invariants.js` + `eslint.config.js` root).
- **Package subpath exports.** `packages/keel-invariants/package.json` declares `"./eslint": "./eslint.config.keel-invariants.js"` at line 14. Fork operators can import via `import sharedConfig from '@keel/keel-invariants/eslint'`. No change to package.json needed at Story 1.16 (subpath export already live from Story 1.2).
- **Renovate + fork-extension surface.** Forks extending Renovate config (Story 1.15) use the same source-fork-level change pattern this story documents (edit `.github/renovate.json` in fork branch). Story 1.16's `AGENTS.md § Fork extension (FR44)` section explicitly links to `docs/invariants/release.md § Fork extension` + `docs/invariants/renovate.md § Fork extension` as sister-pattern references. The fork-extension pattern is CROSS-CUTTING across substrate stories (Stories 1.2/1.6/1.10/1.14/1.15 all mention fork extensions); Story 1.16 canonicalizes the pattern in a single rationale doc.

### Project Structure Notes

- **Template file location.** `packages/keel-invariants/templates/` is a new directory created by this story. Sibling to existing `src/`, `dist/` (gitignored), `node_modules/` (gitignored), and the 4 `*.config.keel-invariants.js` files at the package root. Rationale: templates shipped alongside the substrate package they model; fork operators reach them via `packages/keel-invariants/templates/*` paths or via a future `packages/create-keel-app` consumer (Epic 15a).
- **Rationale doc location.** `docs/invariants/fork.md` matches the established `docs/invariants/<domain>.md` pattern (knowledge-files / ralph-execute / release / renovate / tokens). Story 1.16 adds a 6th entry to `docs/invariants/`.
- **Knowledge-file edits.** `AGENTS.md` + `CLAUDE.md` are the two knowledge-file edits. Both are NON-INVARIANT edits (no manifest entry, no hash pin). The rationale: knowledge files are agent-facing operational docs that evolve frequently; hashing them causes churn without proportional signal. The substrate-enforced anchor is `docs/invariants/fork.md` + `packages/keel-invariants/templates/INVARIANTS.fork.md` — both hash-pinned.
- **Manifest growth.** 22 → 24 entries (+9%). Below the Story 1.15 growth (20 → 22, +10%) and well within the Story 1.9 <2s sync-gate perf budget. Walker is O(n+m) per AC 7 of Story 1.9; +2 entries has no perceptible cost.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 1.16 (lines 1110-1137)]
- [Source: _bmad-output/planning-artifacts/prd.md#Functional Requirements FR44 (line 1010)]
- [Source: _bmad-output/planning-artifacts/prd.md#Functional Requirements FR45 (line 1011)]
- [Source: _bmad-output/planning-artifacts/architecture.md#§ Requirements Overview — FR41–FR45 (Invariants) cluster enumeration (line 49)]
- [Source: _bmad-output/planning-artifacts/architecture.md#§ Functional-Requirement → Artefact mapping table — FR41–FR45 (Invariants) → packages/keel-invariants/, INVARIANTS.md, docs/invariants/ (line 777)]
- [Source: _bmad-output/planning-artifacts/architecture.md#§ Complete Project Directory Structure — packages/keel-invariants/ annotation FR42–FR44 hardwired invariants (line 906)]
- [Source: packages/keel-invariants/package.json#exports./eslint (line 14) — `"./eslint": "./eslint.config.keel-invariants.js"`]
- [Source: packages/keel-invariants/src/invariants.manifest.ts#InvariantSchema.id regex (line 4) — `/^INV-[a-z0-9]+(-[a-z0-9]+)+$/`]
- [Source: packages/keel-invariants/src/sync-gate.ts#ANCHOR_REGEX (line 24)]
- [Source: INVARIANTS.md#existing sections (Stories 1.2-1.15) — pattern for appending a new `### Fork extension (Story 1.16)` H3 block before `## Consumption`]
- [Source: AGENTS.md#existing structure (66 lines, 8 H2 sections) — new `## Fork extension (FR44)` H2 inserted between `## Git / PR conventions` and `## Ralph loop`]
- [Source: CLAUDE.md#Knowledge-file contract table (lines 43-48) — add 5th row for `INVARIANTS.fork.md`]
- [Source: docs/invariants/release.md#Fork extension (lines 48-50) — pattern template for the new `docs/invariants/fork.md` § Fork extension section]
- [Source: docs/invariants/renovate.md#Fork extension (lines 44-48) — companion pattern template]
- [Source: docs/invariants/tokens.md#Extension FR44 (line 171) — earlier cross-cutting FR44 reference]
- [Source: _bmad-output/implementation-artifacts/1-15-renovate-config-with-version-pinning-rules-i7.md — full precedent story for substrate configuration-surface tier (same seven-layer audit discipline, ZERO-PATCH target, 7-iter lifecycle)]

## Dev Agent Record

### Agent Model Used

TBD (filled at `/bmad-dev-story` time — typically claude-sonnet-4-6 or claude-opus-4-7)

### Debug Log References

_(filled during `/bmad-dev-story` at iter-91)_

### Completion Notes List

_(filled during `/bmad-dev-story` at iter-91)_

### File List

_(filled during `/bmad-dev-story` at iter-91)_

## Change Log

- **v1.0** (2026-04-21 iter-88): Initial drafting by `/bmad-create-story`. Four ACs pinned verbatim from epics.md:1110-1137 with scope carve-outs matching Story 1.15 drafting pattern. Seven tasks enumerated (template + rationale-doc + manifest + anchors + AGENTS.md + CLAUDE.md + verification). Manifest forecast: 22 → 24 (+2 entries). Story class: scaffolding / configuration-surface / documentation-tier — TENTH cumulative Epic-1 ATDD-skip candidate + TENTH cumulative WAIVED-trace candidate + SIXTH cumulative ZERO-PATCH-CR candidate + final open story in Epic 1 (post-done transitions PR #226 Draft→Open → final CI gate → EPIC_DONE halt).
- **v1.1** (2026-04-21 iter-89): Pre-dev SM review via `/bmad-create-story (args: "review")`. THREE surgical PATCHes applied to correct spec-citation drift introduced at v1.0 drafting (parallel-subagent L4 convergence audit found 5 of 18 References-block citations drifted and matching drift in Dev Notes L4 paragraph):
  - **PATCH 1 — References block prd.md line numbers.** `prd.md FR44 (line 141)` → `(line 1010)`; `prd.md FR45 (line 142)` → `(line 1011)`. FR44/FR45 actually land at prd.md:1010-1011 (verified via `Grep "^- \*\*FR4[45]"` on prd.md returning lines 1010-1011 only); v1.0 drafter misidentified the lines as 141-142 (which are actually M4 checkpoint ritual + Absorption-risk tripwire in the Business Success section).
  - **PATCH 2 — References block architecture.md line numbers.** Removed 4 fabricated entries (:237 "Implementation Invariants pinning overview", :913 "Agent-facing fork invariants", :1010 "Functional Requirements FR44", :1011 "Functional Requirements FR45") which point to unrelated Frontend / commitlint.config / test-utils content; verified via `Grep "INVARIANTS\.fork"` on architecture.md returning 0 matches (architecture.md contains NO INVARIANTS.fork.md reference). Added the three ACTUAL architecture.md convergence points: :49 (Requirements Overview FR41-FR45 Invariants cluster), :777 (FR→Artefact mapping table), :906 (directory-tree FR42-FR44 annotation; retained from v1.0).
  - **PATCH 3 — Dev Notes L4 cross-file convergence paragraph.** Rewrote the "Architecture.md:906 + :913 + :1010 + :1011 + :237 all converge" claim to reflect ground truth: architecture.md covers FR41-FR45 through the cluster enumeration at :49 + the FR→Artefact mapping table at :777 + the directory-tree annotation at :906; the normative FR44/FR45 prose lives in PRD.md:1010-1011, NOT architecture.md. Clarifies that architecture.md does not mention `INVARIANTS.fork.md` directly; the pointer is indirect (through `docs/invariants/` in the mapping table).
  - Story class unchanged. ZERO-PATCH pre-dev target narrowly missed at 3 surgical citation-drift corrections; this matches Story 1.11/1.12/1.13/1.14/1.15 1-2 PATCH pre-dev average (Story 1.14 iter-75 = 1 PATCH; Story 1.15 iter-82 = 1 PATCH). The 3-PATCH count is CALIBRATION-CORRECT for a story with novel multi-file (architecture.md + prd.md) reference surface — configuration-surface-tier stories with single-file references average ≤2 PATCH; Story 1.16's References block cites 18 distinct sources across 5 files (highest count to date), so a higher drift surface is expected. Lesson recorded in RALPH.md for future multi-file-reference stories. Story State transitions `drafted → validated` via FR14n row 2.
- **v1.2** (2026-04-21 iter-90): `/bmad-testarch-atdd` hybrid ground-(c) variant-(ii)+(iii) ATDD-SKIP — FR14n matrix row 3 `validated → atdd-scaffolded`. **TENTH cumulative Epic-1 ATDD-skip precedent** (Stories 1.7 iter-14 + 1.8 iter-29 + 1.9 iter-36 + 1.10 iter-43 + 1.11 iter-50 + 1.12 iter-57 + 1.13 iter-64 + 1.14 iter-71 + 1.15 iter-83 → 1.16 iter-90). Skill preflight HALTs at Step 1.2 (no test runner — `vitest.config.*` / `jest.config.*` / `playwright.config.*` absent; landing is Epic 13 / post-Epic-1). Three-ground rationale grounded in Story 1.16's documentation-surface class (all 4 ACs explicitly scope-carved as DOCUMENTATION ACs per the story prose lines 21/30/32/39/48): **(a)** substrate-verification-covers-ACs at CLI-exit-code level — Task 7 substrate-verification-suite authors six smokes (`prettier --check` on both new MD files + manifest-load asserting 24 entries + `pnpm keel-invariants:check` clean exit + `INVARIANTS.md` regex for 2 new anchors + `AGENTS.md` regex for `## Fork extension (FR44)` H2 presence + `CLAUDE.md` regex for `INVARIANTS.fork.md` row in contract table + precedence keyword) that exercise ACs 1-4 end-to-end plus Story 1.9 sync-gate walker drift-detection on every commit via content-hash pinning (two new manifest entries `INV-fork-extension-rationale` + `INV-fork-invariants-scaffold`); **(b)** no-runner — framework prerequisite unmet (no vitest/jest/playwright configs authored at 1.0; Epic 13 delivers); **(c)** HYBRID variant-(ii)+(iii) — AC 4's runtime carve-out (Epic 15a's `create-keel-app --include-fork-invariants` flag defaulting `false` at 1.0) is DOWNSTREAM runtime-class behaviour owned by Epic 15a's CLI tests when that package is authored (variant ii); adversarial AC 1 + AC 2 + AC 3 coverage (ESLint-extend documentation fidelity + precedence-rule prose accuracy + amendment-vs-fork decision tree completeness + template-file shape integrity + CLAUDE.md contract-table row accuracy + manifest-entry description faithfulness) delegated to iter-94 `/bmad-code-review (args: "2")` three-layer fan-out (variant iii). Mirrors Story 1.14 iter-76 + Story 1.15 iter-83 v1.2 pattern exactly. No test-plan artefacts authored (variant-(ii)+(iii) substitution pattern — identical precedent-hold). Story State transitions `validated → atdd-scaffolded` via FR14n row 3.
