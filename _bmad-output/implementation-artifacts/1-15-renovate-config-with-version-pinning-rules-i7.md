# Story 1.15: Renovate config with version-pinning rules (I7)

Status: review

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a substrate maintainer,
I want `.github/renovate.json` with version-pinning rules — I7 pinned packages carry `rangeStrategy: pin`, OTEL + Vitest packages are grouped into a single PR per family, PRs default to `automerge: false` until the Epic-13 integration-test gate lands, and the config is registered as TWO enforced invariants in the Story-1.8 manifest (`INV-deps-version-pinning` + `INV-renovate-rationale`) so the Story-1.9 sync-gate drift-detects any ad-hoc edits,
So that (a) when the Renovate GitHub App is installed against the repo it proposes pin-mode updates for I7-critical deps (Vitest exact, `@opentelemetry/sdk-node` + `@opentelemetry/api` + instrumentations, `ghcr.io/fboulnois/pg_uuidv7:<version>`), (b) related packages in the same ecosystem (all OTEL / all Vitest / all `@radix-ui/*`) bundle into one Renovate PR (grouped-update rule) rather than 20 separate PRs, (c) auto-merge is forbidden at 1.0 until Epic-13's integration-test-passing CI gate lands (the rule ships here as a policy; the GH branch-protection wiring is downstream), (d) the single-bundled ↔ grouped-updates + I7 pin posture is documented with a pointer to architecture.md § I7 line 342 + PRD I7 amendment, and (e) the config file is drift-detected on every commit so a silent edit to Renovate discipline is impossible (closes FR I7 substrate authoring; Epic 13 lands the CI integration-test gate consumer later; the Renovate GitHub App install + `pnpm.overrides` content authorship lands alongside whichever downstream story first installs OTEL / Vitest, OR a dedicated post-M0 "renovate bootstrap" story).

## Acceptance Criteria

1. **Given** `.github/renovate.json`,
   **When** I inspect it,
   **Then** it is valid JSON that `renovate-config-validator` (or the canonical `$schema` reference) would accept
   **And** it declares `"$schema": "https://docs.renovatebot.com/renovate-schema.json"` (canonical discovery aid matching Story 1.14 `release-please-config.json` precedent at AC 1 scope carve-out)
   **And** it extends a conservative base preset (`["config:recommended"]` — the Renovate canonical baseline)
   **And** Vitest's `rangeStrategy` is `pin` (encoded as a `packageRules` entry matching `matchPackageNames: ["vitest"]` + any `vitest/*` sub-packages via `matchPackagePatterns: ["^vitest($|/)","^@vitest/"]`)
   **And** `@opentelemetry/*` packages have `rangeStrategy: pin` (via `matchPackagePatterns: ["^@opentelemetry/"]`)
   **And** grouped-update rules bundle related packages into one PR per ecosystem (all OTEL → `groupName: "opentelemetry"`; all Vitest → `groupName: "vitest"`; all `@radix-ui/*` → `groupName: "radix-ui"` per epics.md:3984 Story 7.2 AC "`@radix-ui/*` deps are pinned (Story 1.15 renovate covers)").

   **Story 1.15 scope carve-out — file location.** The file lives at `.github/renovate.json` per AC 1's Given-clause + architecture.md:649 (Dev-time / tooling manifest enumerates `.github/renovate.json`) + architecture.md:810 (Source-tree shows `.github/renovate.json`). All three converge on `.github/renovate.json`. No architecture-vs-epic drift here (contrast Story 1.14 AC 1 where `.github/release-please-config.json` drifted vs architecture.md:807's root-level layout — RALPH.md 2026-04-19 lesson epics.md-AC-wins applied once; no such drift arises for Story 1.15).

   **Story 1.15 scope carve-out — Renovate GitHub App install is NOT in scope.** Renovate executes against a repo only when the Renovate GitHub App (hosted by WhiteSource / Mend) is installed with repo access; that is a one-time repo-admin action (Tthew's manual operation). Story 1.15 authors the config; until the App is installed, the config is inert substrate (same posture as Story 1.14 release-please-config.json awaiting Story 13.5's workflow). The `install Renovate GitHub App` action is an OPERATIONAL concern carved out to a post-M0 ops runbook (`docs/ops/renovate-install.md` — deferred; not authored by Story 1.15).

   **Story 1.15 scope carve-out — `pnpm.overrides` content is NOT authored here.** AC 1's Renovate rules apply `rangeStrategy: pin` when the named packages are resolved in the repo's dependency graph. At Story 1.15 landing time, NO Vitest / OTEL / `@radix-ui/*` package is yet installed (`grep -R 'vitest\|@opentelemetry/\|@radix-ui/' --include=package.json` returns zero matches across all 16 workspace members; verified at drafting time). Story 1.15's renovate.json is a POLICY CONFIG that applies to whichever downstream story first installs these deps — the `pnpm.overrides` block authoring lands there, NOT here. Expected consumers: Story 1.16 or the first apps/web PR that adds `@tanstack/start` (which transitively may pull Vitest); Epic-2 stories introduce OTEL; Story 2.1 adds the `pg_uuidv7` image tag pin. Story 1.15's AC 1 Renovate rules survive as inert config until the matching packages appear in `package.json`.

2. **Given** a Renovate PR is opened (scenario materializes only once the Renovate GitHub App is installed per AC 1 scope carve-out),
   **When** CI runs,
   **Then** the integration-test-passing gate is required before Renovate can auto-merge.

   **Story 1.15 scope carve-out — AC 2 is DOWNSTREAM (Epic 13 + GH branch-protection).** Renovate auto-merge is gated by the repo's GitHub branch-protection rule "require status checks to pass before merging" — that is a REPO-SETTINGS concern (authored once in the repo admin UI OR via a one-time `gh api` call as part of Epic 13's CI setup), NOT a `renovate.json` config field. Renovate itself respects this automatically: even if `"automerge": true` is set in renovate.json, Renovate waits for required status checks before merging via `platformAutomerge`. Story 1.15 ships the POLICY SIDE of the gate (`"automerge": false` at top-level + per-I7-pinned-group `"automerge": false` explicit, so auto-merge is forbidden by default until Epic 13 lands the CI gate + branch protection); the RUNTIME SIDE (actual CI workflow + branch-protection status-check requirement) is Epic 13 scope. Substrate verification (Task 7 below) asserts the renovate.json `automerge: false` default holds and that per-group overrides do not weaken it for I7-pinned groups.

   **Story 1.15 scope carve-out — AC 2 wording "the gate reuses Epic 13's CI when it lands; at 1.0 the rule itself ships here even if Epic 13 wiring is partial".** This is the epic-spec's intentional partial-landing carve-out: Story 1.15 ships the CONFIG that would gate auto-merge (via `"automerge": false`); Epic 13 ships the WORKFLOW that implements the gate logic. Story 1.15's deliverable is complete once the config is drift-detected; Epic 13's deliverable is complete once the gate is enforced on Renovate PRs.

3. **Given** an OTEL version bump,
   **When** Renovate proposes it (scenario materializes only after Renovate App install + OTEL packages landing in the repo per AC 1 scope carve-out),
   **Then** all related OTEL packages are upgraded together in one PR
   **And** `pnpm.overrides` is updated atomically with `package.json`.

   **Story 1.15 scope carve-out — AC 3 first-half SUBSTRATE-COVERED, second-half DOWNSTREAM.** First half ("all related OTEL packages upgraded together in one PR") is satisfied at substrate level by Story 1.15's `groupName: "opentelemetry"` packageRules entry matching `matchPackagePatterns: ["^@opentelemetry/"]`; Task 7 asserts this statically. Second half ("`pnpm.overrides` updated atomically with `package.json`") is RENOVATE-RUNTIME behaviour + depends on `pnpm.overrides` existing in the first place — at Story 1.15 landing no OTEL packages are installed so there are no `pnpm.overrides` entries to update. Once the downstream story that first installs OTEL authors the `pnpm.overrides` block, Renovate's pnpm manager handles `package.json` + `pnpm.overrides` together by default (Renovate's `pnpm` manager understands both `dependencies/devDependencies` + the `pnpm.overrides` field; it patches them atomically in a single PR). No Story-1.15-level config flag is needed; substrate verification covers the grouping contract only.

4. **Given** a new package added without a required pin,
   **When** the manifest tracks pinning policy under `INV-deps-version-pinning`,
   **Then** Story 1.9's sync-gate surfaces the drift.

   **Story 1.15 scope carve-out — AC 4 is fully satisfied at substrate level via TWO invariant entries.** The epic's `INV-deps-version-pinning` ID is pinned verbatim at AC 4 → this IS the stable ID for `.github/renovate.json` (sourcePath pin). When a contributor edits renovate.json (adds a new pinned-package rule, changes `rangeStrategy`, renames a groupName, etc.), the sha256 content-hash of the file changes; Story 1.9's sync-gate flags the mismatch between the pinned manifest hash and the live file hash at pre-commit → drift surfaced. The literal text "a new package added without a required pin" describes the RENOVATE-RUNTIME behaviour (when a new transitive dep surfaces via dependency graph walk and no matching `packageRules` entry applies, Renovate's default `rangeStrategy` handling decides what to do — at Story 1.15 the default is `pin` for I7-critical matched patterns only, normal range-bump for everything else); Story 1.9's sync-gate is the FILE-LEVEL drift detector, NOT a runtime policy walker. This two-layer story — substrate pins policy, runtime Renovate enforces — mirrors Story 1.14's "substrate pins config, runtime workflow enforces" pattern exactly.

   **Story 1.15 scope carve-out — 2 new invariants, NOT 3, NOT 1.** Following the Story 1.14 precedent (2 or 3 IDs per substrate story based on surface count), Story 1.15 registers TWO invariants:
   - `INV-deps-version-pinning` — sourcePath `.github/renovate.json`; anchors `['INV-deps-version-pinning']`. The primary machine-enforced invariant matching the epic AC 4 literal ID.
   - `INV-renovate-rationale` — sourcePath `docs/invariants/renovate.md`; anchors `['INV-renovate-rationale']`. Companion rationale doc mirroring Story 1.10 `INV-tokens-semantic-rationale` pattern + Story 1.14 `INV-release-please-rationale` pattern. Explains (a) I7 posture + architecture.md § I7 pointer, (b) the per-package pinning rules + grouping rationale, (c) fork-extension guidance (FR44 — forks that want different pin sets edit renovate.json as a source-fork change), (d) consumption pointer to Renovate GitHub App runtime.
   Manifest grows **20 → 22** entries.

## Tasks / Subtasks

- [x] **Task 1: Author `.github/renovate.json` (I7 pinning rules + groupName per-ecosystem + `automerge: false` safe default)** (AC: 1, 2, 3, 4)
  - [x] Author the JSON file at `.github/renovate.json`. Canonical shape (pinned here so dev-story does not drift; all fields required unless labelled `optional`):
    ```json
    {
      "$schema": "https://docs.renovatebot.com/renovate-schema.json",
      "extends": ["config:recommended"],
      "timezone": "Europe/Berlin",
      "schedule": ["before 9am on monday"],
      "dependencyDashboard": true,
      "labels": ["dependencies", "renovate"],
      "automerge": false,
      "rangeStrategy": "replace",
      "packageRules": [
        {
          "description": "I7: Vitest pinned exact; grouped as one PR per ecosystem bump.",
          "matchPackageNames": ["vitest"],
          "matchPackagePatterns": ["^vitest($|/)", "^@vitest/"],
          "groupName": "vitest",
          "rangeStrategy": "pin",
          "automerge": false
        },
        {
          "description": "I7: OpenTelemetry JS SDK pinned exact; @opentelemetry/sdk-node + @opentelemetry/api + every instrumentation grouped into one PR.",
          "matchPackagePatterns": ["^@opentelemetry/"],
          "groupName": "opentelemetry",
          "rangeStrategy": "pin",
          "automerge": false
        },
        {
          "description": "I7: Radix UI primitives grouped; pin mode matches the substrate-wide UI-primitive discipline (epics.md:3984 Story 7.2 AC — Story 1.15 renovate covers).",
          "matchPackagePatterns": ["^@radix-ui/"],
          "groupName": "radix-ui",
          "rangeStrategy": "pin",
          "automerge": false
        },
        {
          "description": "pg_uuidv7 Postgres image pin (Story 2.1 devbox docker-compose consumer); flagged for manual review on any tag change.",
          "matchDatasources": ["docker"],
          "matchPackageNames": ["ghcr.io/fboulnois/pg_uuidv7"],
          "groupName": "pg-uuidv7",
          "rangeStrategy": "pin",
          "automerge": false
        }
      ],
      "lockFileMaintenance": {
        "enabled": true,
        "schedule": ["before 9am on the first day of the month"],
        "automerge": false
      }
    }
    ```
  - [x] Prettier-format the file via `pnpm exec prettier --write .github/renovate.json` before commit so it matches Story 1.6 formatting baseline (consistent with Story 1.14 `release-please-config.json` prettier treatment).
  - [x] Compute the sha256 content hash of the prettier-formatted file for the manifest entry (see Task 3). Command: `sha256sum .github/renovate.json` (post-prettier).
  - [x] **Validity sanity-check at author-time (pre-dev-story).** `node -e "const c=JSON.parse(require('fs').readFileSync('.github/renovate.json','utf8')); if (!c.packageRules || c.packageRules.length !== 4) throw new Error('expected 4 packageRules; got ' + (c.packageRules ? c.packageRules.length : 'undefined')); if (c.automerge !== false) throw new Error('top-level automerge must be false'); console.log('OK: ' + c.packageRules.length + ' packageRules + automerge: false');"` must print `OK: 4 packageRules + automerge: false`.

- [x] **Task 2: Author `docs/invariants/renovate.md` (I7 posture + per-package pinning rationale + fork-operator pointer)** (AC: 4)
  - [x] Author `docs/invariants/renovate.md` as a plain markdown documentation file (mirrors `docs/invariants/release.md` Story 1.14 + `docs/invariants/tokens.md` Story 1.10 + `docs/invariants/ralph-execute.md` Story 1.9 precedents). Structure:
    - H1: `# Dependency upgrade discipline — Renovate I7 version pinning (Story 1.15)`
    - Header block (4 lines): Scope + Status + Machine-enforced-in + Runtime consumer (same shape as `release.md:3-6`).
    - § Overview — one paragraph summarizing I7 + bump-mapping + GitHub-App-install dependency (carves out runtime from substrate).
    - § I7 posture — points at architecture.md § I7 line 342 VERBATIM (the three-agent-convergence decision: Vitest exact + OTEL pinned in `pnpm.overrides` + Postgres image tag pin; integration-test-gate + grouped-update rules; `.github/renovate.json` is the authority) + PRD FR I7 amendment.
    - § Files — lists the one config file + two new manifest invariants + the `INV-renovate-rationale` self-reference.
    - § Per-package pinning rules — table with 4 rows (Vitest / OpenTelemetry / Radix UI / pg_uuidv7) × 4 columns (matchPackagePatterns | groupName | rangeStrategy | automerge); each row cites the architecture.md section that motivated the pin.
    - § Grouping rationale — 2–3 sentences on why ecosystem-grouping (one PR per ecosystem bump) + why `automerge: false` at 1.0.
    - § Fork extension — 2 sentences pointing at FR44 (forks that want different pin sets edit `.github/renovate.json` as a source-fork change, same pattern as release-please-config.json); fork operators who want per-package automerge rules flip the per-group `automerge` field in their fork's renovate.json.
    - § Consumption — points at the Renovate GitHub App (runtime) + Epic-13 integration-test-passing CI gate (branch-protection consumer) + Story 2.1 (pg_uuidv7 image tag source).
    - § Anchor — add the `- **\`INV-renovate-rationale\`**: I7 version-pinning posture + per-package rules + fork-extension guidance.` anchor bullet at the end of the § Overview section so the Story 1.9 walker (column-0 bullet matching `packages/keel-invariants/src/sync-gate.ts:24` ANCHOR_REGEX) detects it.
  - [x] Prettier-format: `pnpm exec prettier --write docs/invariants/renovate.md`.
  - [x] Compute the sha256 content hash for the manifest entry.

- [x] **Task 3: Add 2 new invariant entries to `packages/keel-invariants/src/invariants.manifest.ts` → `raw` array** (AC: 4)
  - [x] Add two entries to the `raw: Invariant[]` array at the end (post the existing `INV-release-please-rationale` at line 200-207; preserve the existing 20 entries in their current order). Shape of each entry matches the Story 1.10/1.11/1.12/1.13/1.14 precedents:
    ```ts
    {
      id: 'INV-deps-version-pinning',
      description:
        'Renovate I7 dependency-upgrade policy configuration — .github/renovate.json; extends config:recommended + 4 packageRules (Vitest, @opentelemetry/*, @radix-ui/*, ghcr.io/fboulnois/pg_uuidv7) each carrying rangeStrategy: pin + per-ecosystem groupName + automerge: false. Top-level automerge: false forbids Renovate auto-merge at 1.0 until Epic 13 lands the integration-test-passing CI gate + GH branch-protection status-check requirement. Enforces the architecture.md § I7 three-agent-convergence pinning decision (Vitest exact minor + OTEL exact in pnpm.overrides + pg_uuidv7 image tag). Inert substrate until Tthew installs the Renovate GitHub App against the repo (one-time ops action per § Fork extension). Consumed at runtime by the Renovate App + Epic 13 integration-test CI gate; static drift detected by Story 1.9 pre-merge sync-gate (FR43).',
      sourcePath: '.github/renovate.json',
      contentHash: '<sha256 from Task 1>',
      anchors: ['INV-deps-version-pinning'],
    },
    {
      id: 'INV-renovate-rationale',
      description:
        "Documentation-layer rationale for the Renovate I7 pinning posture — docs/invariants/renovate.md; mirrors Story 1.10's INV-tokens-semantic-rationale + Story 1.14's INV-release-please-rationale pattern (companion doc to a machine-enforced invariant, drift-detected at the doc layer). Explains (a) the I7 posture with a verbatim pointer to architecture.md § I7 line 342 + PRD I7 amendment, (b) per-package pinning rules table (Vitest / OTEL / Radix UI / pg_uuidv7) + groupName rationale, (c) fork-extension guidance (FR44 — per-fork renovate.json edits change automerge posture per group), (d) consumption pointer to Renovate GitHub App runtime + Epic 13 CI gate + Story 2.1 pg_uuidv7 image tag source. Companion to INV-deps-version-pinning.",
      sourcePath: 'docs/invariants/renovate.md',
      contentHash: '<sha256 from Task 2>',
      anchors: ['INV-renovate-rationale'],
    },
    ```
  - [x] Verify the schema refinement (`superRefine` uniqueness + cross-sourcePath contentHash parity) holds after the additions. The two new entries have unique IDs + unique sourcePaths; no shared-sourcePath cross-entry check fires.
  - [x] **Build + runtime-smoke.** `cd packages/keel-invariants && pnpm build && node -e "import('./dist/invariants.manifest.js').then(m => console.log('OK: ' + m.invariants.length + ' invariants'))"` from `packages/keel-invariants/` to confirm the manifest parses + exports **22** entries (20 current + 2 new). **IMPORTANT** per Story 1.14 iter-77 Gotcha — the `pnpm keel-invariants:check` script reads `dist/check.js` which imports the COMPILED manifest, NOT the TS source; editing `invariants.manifest.ts` requires a `pnpm --filter @keel/keel-invariants build` before `pnpm keel-invariants:check` observes the new entries.

- [x] **Task 4: Add 2 anchor bullets to `INVARIANTS.md` under a new `### Dependency upgrade discipline (Story 1.15)` section** (AC: 4)
  - [x] Insert a new `### Dependency upgrade discipline (Story 1.15)` H3 section in `INVARIANTS.md` between the existing `### Release management (Story 1.14)` section (ends at line 73) and the `## Consumption` H2 at line 75. The section opens with a one-sentence summary ("I7 version-pinning policy authored in `.github/renovate.json` + companion rationale doc; Vitest + OTEL + Radix UI + pg_uuidv7 pin-mode + grouped-update rules; inert until the Renovate GitHub App is installed.") and lists two column-0 bullets (matching the Story 1.9 `ANCHOR_REGEX` shape `^-\s+\*\*\`INV-[a-z0-9]+(?:-[a-z0-9]+)+\`\*\*`):
    - `- **\`INV-deps-version-pinning\`**: .github/renovate.json — 4 packageRules (Vitest + @opentelemetry/* + @radix-ui/* + pg_uuidv7) with rangeStrategy pin + per-ecosystem groupName + automerge false.`
    - `- **\`INV-renovate-rationale\`**: docs/invariants/renovate.md — I7 posture + per-package pinning rules table + grouping rationale + fork-extension guidance.`
  - [x] Re-compute the contentHash of `INVARIANTS.md` is NOT needed — INVARIANTS.md is not a `sourcePath` in the manifest (it is the ANCHOR DOC walked by Story 1.9 via `ANCHOR_REGEX`; the walker re-reads the doc on every sync-gate invocation, so the doc's content hash is recomputed at runtime rather than pinned as a manifest field) — same contract as Story 1.14 Task 5.
  - [x] Prettier-format: `pnpm exec prettier --write INVARIANTS.md`.

- [x] **Task 5: Add 0 new scripts to root `package.json` + 0 new hooks to `.pre-commit-config.yaml`** (AC: 4)
  - [x] **Explicit no-op confirmation.** Story 1.15's substrate is one JSON file + one markdown file + two manifest entries + two anchor bullets. No new pnpm scripts are required at root `package.json`; `pnpm keel-invariants:check` (Story 1.9) already walks the manifest + compares sha256 hashes per sourcePath, so the two new entries are automatically covered. Similarly, no `.pre-commit-config.yaml` hook addition is needed — the existing Story 1.9 sync-gate + the Story 1.4 format-check hook jointly cover the files (format-check fails on unprettier'd JSON; sync-gate fails on contentHash drift).
  - [x] **IMPORTANT:** any edit to `package.json` WOULD require updating the `INV-prek-prepare-lifecycle` entry's `contentHash` at `packages/keel-invariants/src/invariants.manifest.ts:97-103` per Story 1.9 iter-4 lesson 2026-04-20 ("Substrate packages consuming substrate sourcePath'd files must recompute hashes when the PR edits those files"). Task 5's explicit no-op is protective: not editing `package.json` means no cascade hash update. Same protective posture for `.pre-commit-config.yaml` (covers `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config`).

- [x] **Task 6: Substrate verification — JSON validity, renovate-config shape, 4 packageRules enumeration, manifest-load clean** (AC: 1, 2, 3, 4)
  - [x] **Static JSON parse:** `node -e "JSON.parse(require('fs').readFileSync('.github/renovate.json','utf8'))"` must exit 0. Validates the file is well-formed.
  - [x] **Extends + schema smoke:** `node -e "const c=JSON.parse(require('fs').readFileSync('.github/renovate.json','utf8')); if (c['$schema'] !== 'https://docs.renovatebot.com/renovate-schema.json') throw new Error('wrong \$schema'); if (!Array.isArray(c.extends) || !c.extends.includes('config:recommended')) throw new Error('missing config:recommended'); console.log('OK: renovate schema + config:recommended extends');"` must print `OK: renovate schema + config:recommended extends`.
  - [x] **4-packageRules + automerge default smoke:** `node -e "const c=JSON.parse(require('fs').readFileSync('.github/renovate.json','utf8')); if (c.automerge !== false) throw new Error('top-level automerge must be false'); if (!Array.isArray(c.packageRules) || c.packageRules.length !== 4) throw new Error('expected 4 packageRules; got ' + (c.packageRules||[]).length); const groups = c.packageRules.map(r => r.groupName).sort(); const expected = ['opentelemetry','pg-uuidv7','radix-ui','vitest']; if (JSON.stringify(groups) !== JSON.stringify(expected)) throw new Error('groupName mismatch: got ' + JSON.stringify(groups) + ' expected ' + JSON.stringify(expected)); console.log('OK: 4 packageRules; groups=' + JSON.stringify(groups) + '; automerge=false');"` must print `OK: 4 packageRules; groups=["opentelemetry","pg-uuidv7","radix-ui","vitest"]; automerge=false`.
  - [x] **I7 rangeStrategy pin smoke:** `node -e "const c=JSON.parse(require('fs').readFileSync('.github/renovate.json','utf8')); const nonPin = c.packageRules.filter(r => r.rangeStrategy !== 'pin'); if (nonPin.length) throw new Error('non-pin rules: ' + JSON.stringify(nonPin.map(r => r.groupName))); console.log('OK: all 4 I7 groups pin-mode');"` must print `OK: all 4 I7 groups pin-mode`.
  - [x] **Manifest load smoke:** `cd packages/keel-invariants && pnpm build && node -e "import('./dist/invariants.manifest.js').then(m => console.log('OK: ' + m.invariants.length + ' invariants'))"` — must print `OK: 22 invariants` (20 pre-Story-1.15 + 2 new). Per Story 1.14 iter-77 Gotcha, the `pnpm build` step is MANDATORY before runtime smoke.
  - [x] **Sync-gate clean smoke:** from repo root, `pnpm keel-invariants:check` must exit 0 with no drift. This is the Story 1.9 AC 1 clean-path behaviour. If the gate emits drift (e.g. a stale contentHash, a missing anchor, a missing source file), FIX in the same iteration BEFORE commit — iteration budget is a blocker (drift under own PR is a quality-gate violation per NFR27).
  - [x] **Full quality-gate suite:** `pnpm typecheck && pnpm lint && pnpm format:check && pnpm keel-invariants:check-all`. All must pass. `keel-invariants:check-all` runs the Story 1.9 sync-gate + Story 1.13 token-sync gate in sequence; the two new invariants should register clean at the former; the latter is unaffected (no token-layer change in Story 1.15).
  - [x] **Record measurements** in § Dev Agent Record → Debug Log: sha256 values computed at Tasks 1/2, wall-clock of each smoke test, `pnpm keel-invariants:check` duration (Story 1.9 pinned <2s per AC 7; should hold comfortably — manifest grows from 20 → 22 entries, +10% vs Story 1.14's +17%; walker is O(n+m) so negligible).

## Dev Notes

### Carry-forward from Story 1.14 (iter-80 ZERO-PATCH CR precedent — FOURTH cumulative)

Story 1.14 completed a 7-iteration `drafted → done` lifecycle (iter-74 → iter-80) with the FOURTH cumulative ZERO-PATCH CR outcome (Stories 1.11/1.12/1.13/1.14). The compound discipline that held is pre-staged here verbatim (NINTH cumulative Epic-1 ATDD-skip precedent candidate + FIFTH cumulative ZERO-PATCH CR candidate for Story 1.15):

- **Seven preventative audit layers pre-applied at drafting time** (iter-53/54/56/59/60/67/74 compound — see RALPH.md § Lessons for the framing):
  - **L1 — stable IDs for new enforced invariants.** Two new IDs registered here: `INV-deps-version-pinning` (epic-verbatim per AC 4), `INV-renovate-rationale`. Both match the Zod regex `^INV-[a-z0-9]+(-[a-z0-9]+)+$` at `invariants.manifest.ts:4` (verified at drafting-time by mentally parsing each against the regex): `INV-deps-version-pinning` = 3 segments (deps / version / pinning); `INV-renovate-rationale` = 2 segments (renovate / rationale); all lowercase; no uppercase; no underscores; ≥ 2 hyphenated segments each.
  - **L2 — task-enumeration-vs-consumer-requirement diff.** Every AC has ≥1 Task: AC 1 → Tasks 1, 3, 4 + Task 6 (static JSON parse + $schema + 4-packageRules shape); AC 2 → Task 1 top-level `automerge: false` + Task 6 smoke 3; AC 3 → Task 1 `groupName: "opentelemetry"` + Task 6 smoke 3; AC 4 → Tasks 2, 3, 4 + Task 6 (manifest load + sync-gate clean). Every Task serves ≥1 AC. Task 5 is an explicit no-op (confirms no script / hook cascade) protecting against Story 1.9-iter-4-class hash-cascade regressions (same pattern as Story 1.14 Task 6).
  - **L3 — sprint-status transition wording.** At drafting-time, this iteration flips `1-15-renovate-config-with-version-pinning-rules-i7: backlog → ready-for-dev` in `_bmad-output/implementation-artifacts/sprint-status.yaml:60` + bumps `last_updated` to `2026-04-21 Story-1-15-drafted UTC` (matches Story 1.14 iter-74 wording pattern).
  - **L4 — internal-consistency drift (design-convergence residuals).** Cross-AC check: "pin-mode" appears in AC 1 + AC 4 (scope carve-outs) + Task 1 `rangeStrategy: "pin"` (× 4 entries) + Task 6 smokes 2, 4 — all sites converge on the same answer. "4 packageRules" appears in User Story + AC 1 + Task 1 count-check + Task 6 smoke 3 explicit `length !== 4` + Task 6 smoke 3 groupName-sort — all 5 converge. "`.github/renovate.json`" appears in User Story + AC 1 Given + Task 1 file path + Task 3 `sourcePath` + Task 4 anchor + Task 6 smoke command paths — all 6 converge; architecture.md:810 source-tree agrees (no drift here — contrast Story 1.14's `.github/release-please-config.json` vs architecture.md:807 root-level drift). "`config:recommended`" preset appears in AC 1 Given + Task 1 `extends` + Task 6 smoke 2 explicit inclusion check — all 3 converge. "`automerge: false`" appears in Task 1 top-level + 4× per-group + Task 6 smoke 3 explicit `c.automerge !== false` check + Story narrative "forbids Renovate auto-merge at 1.0" — all sites converge.
  - **L5 — cross-file line-number staleness + collection cardinality (MECHANICALLY-DERIVED per iter-76 LESSON).** Collection counts mechanically-derived via shell command (NOT copy-pasted from Story 1.14): 4 packageRules entries (Vitest + OTEL + Radix UI + pg_uuidv7 = 4 groups → 4 `groupName` values: `["opentelemetry","pg-uuidv7","radix-ui","vitest"]` sorted); current manifest entry count 20 pre-Story-1.15 (verified by `grep -c "^    id:" packages/keel-invariants/src/invariants.manifest.ts` at drafting time = 20); Story 1.15 grows manifest to **22** entries. **Cumulative-precedent sequence counters MECHANICALLY-DERIVED per iter-76 LESSON:** Story 1.7 iter-2 ATDD-skip = 1st precedent; 1.8 iter-3 = 2nd; 1.9 iter-4 = 3rd; 1.10 iter-44 = 4th; 1.11 iter-55 = 5th; 1.12 iter-62 = 6th; 1.13 iter-69 = 7th; 1.14 iter-76 = 8th; → **1.15 iter-(TBD) = NINTH cumulative ATDD-skip**. ZERO-PATCH-CR counter: 1.11 iter-59 = 1st; 1.12 iter-66 = 2nd; 1.13 iter-73 = 3rd; 1.14 iter-80 = 4th; → **1.15 iter-(TBD) = FIFTH cumulative ZERO-PATCH CR candidate**. WAIVED-trace counter: same 8-story chain → **1.15 = NINTH cumulative WAIVED trace candidate**.
  - **L6 — schema-permission diff.** Files edited by Story 1.15: `.github/renovate.json` (NEW), `docs/invariants/renovate.md` (NEW), `packages/keel-invariants/src/invariants.manifest.ts` (ADD 2 entries), `INVARIANTS.md` (ADD 1 section + 2 bullets). Files NOT edited: `package.json` (explicit Task 5 no-op — protects `INV-prek-prepare-lifecycle` hash at `invariants.manifest.ts:97-103`); `.pre-commit-config.yaml` (no new hook — protects `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` hash at `invariants.manifest.ts:89-95` + `:104-110`); `tokens.json` / schema files / emitter / gates (zero token-layer touch — protects `INV-tokens-source`, `INV-tokens-schema-contract`, `INV-tokens-emitter`, `INV-tokens-schema-validate`, `INV-tokens-contrast-check`, `INV-tokens-sync-gate` hashes); `.github/release-please-config.json` + `.github/.release-please-manifest.json` + `docs/invariants/release.md` (zero release-layer touch — protects `INV-release-please-config`, `INV-release-please-manifest`, `INV-release-please-rationale` hashes). No cascade hash updates triggered.
  - **L7 — domain-specific carve-out (Renovate config-shape contract).** Renovate canonical config schema: `$schema` URL `https://docs.renovatebot.com/renovate-schema.json` (standard discovery aid); `extends` preset inheritance (`config:recommended` is the conservative baseline); `packageRules` array of per-package overrides keyed on `matchPackageNames` / `matchPackagePatterns` / `matchDatasources` etc.; `groupName` groups matched packages into a single PR; `rangeStrategy: pin` pins the matched packages exactly; `automerge: false` at top-level + per-rule ensures no auto-merge at 1.0; `lockFileMaintenance.enabled: true` with monthly schedule keeps the lockfile fresh without triggering dep bumps. The Renovate GitHub App (Mend-hosted) is the runtime consumer; install is a one-time repo-admin action carved out of Story 1.15.

- **Target ≤2 PATCH pre-dev SM review.** Any L1-L7 residual that slips past drafting should land as ≤2 PATCHes at SM review. Story 1.11 iter-54 + Story 1.12 iter-61 + Story 1.13 iter-68 + Story 1.14 iter-75 all landed exactly 2 PATCHes; Story 1.15 should match.

- **Target single-pass dev.** Story 1.15 is configuration-surface only (1 new JSON file + 1 markdown file + 2 manifest entries + 2 anchor bullets; zero runtime code); single-pass dev-story should hold (matches Story 1.14 single-pass precedent at the same surface scale).

- **Target ZERO-PATCH trace/SM/CR across the trace + post-dev-SM + CR iterations.** Stories 1.11 iter-57..59 + 1.12 iter-64..66 + 1.13 iter-71..73 + 1.14 iter-78..80 all held ZERO-PATCH across trace + SM + CR; Story 1.15 is configuration-surface at the same lower-complexity substrate scale as Story 1.14 — expected DEFER count at CR: 5–8 range (Story 1.14 landed at 10, slightly above 5-8 forecast due to config-vs-workflow carve-outs; Story 1.15's simpler 4-packageRules surface + no manifest file + no hash-cascade concerns should land at the lower end of 5–8).

- **ATDD-skip prelim — hybrid ground-(c) variant-(ii)+(iii) [NINTH precedent candidate].** Story 1.15 has NO runtime behaviour at substrate level (the config file exists; the Renovate GitHub App that consumes it is an operational install carved out; until then the JSON file is drift-detected via Story 1.9 but is not "executed" anywhere). (a) substrate-verification-covers-ACs: Task 6 enumerates 6 smoke tests — static JSON parse + extends + schema + 4-packageRules + I7 pin-mode + manifest-load + sync-gate — that exercise AC 1 + AC 4 end-to-end at substrate level; AC 2 (automerge gate) + AC 3 (grouped-update runtime) describe downstream Renovate-runtime + Epic-13-CI behaviour explicitly carved out of Story 1.15 scope. (b) no test runner at Story 1.15 time — per Story 1.16 + Epic 13 test runner not yet landed; `grep -R 'vitest.config' .` returns zero; `/bmad-testarch-atdd` Step 1.2 (test-framework preflight) hard-prerequisite would HALT. (c) **HYBRID variant-(ii)+(iii)**: variant (ii) downstream-story-covers-integration — Renovate GitHub App install + Epic 13 CI gate own the runtime auto-merge + grouped-update assertions (AC 2, AC 3 runtime halves); variant (iii) spec-declared CR-substitution — § Testing Standards below affirmatively declares adversarial coverage to the CR pass (Blind Hunter / Edge Case Hunter / Acceptance Auditor) for AC 1 + AC 4 substrate + AC 2 + AC 3 scope-carves. Ninth precedent following Stories 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14.

### Story 1.15 architecture + PRD references

- **Architecture § I7 line 342** (`_bmad-output/planning-artifacts/architecture.md:342-350`): three-agent-convergence pinning decision (Vitest exact minor + OTEL exact in `pnpm.overrides` + `pg_uuidv7` image tag) + Renovate configuration at `.github/renovate.json` as the authority with grouped-update rules + mandatory integration-test-passing-required-before-merge for pinned deps. Pinned verbatim at AC 1 + Task 2.
- **Architecture line 305** (§ Party-Mode-driven Implementation Invariants): I7 enumerated in the Implementation Invariants index — same text as line 342.
- **Architecture line 649** (§ Repository layout / Dev-time tooling): `.github/renovate.json` listed as "(I7 version pinning: Vitest exact; `@opentelemetry/sdk-node` + `@opentelemetry/api` + instrumentations pinned in `pnpm.overrides`; grouped-update rules + integration-test-passing gate)" — matches Story 1.15 AC 1 scope exactly.
- **Architecture line 810** (§ Source-tree): `│   ├── renovate.json                      # I7 grouped-update rules + integration-test gates` — file-path convergence with AC 1 Given-clause (no drift).
- **Epic 7 Story 7.2 AC (epics.md:3984)** (§ shadcn/ui components vendored): `**Then** \`@radix-ui/*\` deps are pinned (Story 1.15 renovate covers)` — Radix UI groupName is called out by-name as a cross-story dependency; Task 1 packageRules entry 3 satisfies. (Architecture.md § F1 Component library at line 240 agrees on the shadcn/ui + Radix vendoring posture; the explicit "pinned via Renovate" delegation-to-Story-1.15 lives in epics.md not architecture.md.)
- **PRD § I7** (`_bmad-output/planning-artifacts/prd.md` — specifically the I7 amendment): Reproducibility serves research-output richness directly; irreproducible substrate produces a corrupted research corpus. Story 1.15 delivers the policy surface; Renovate + Epic 13 deliver the runtime enforcement.
- **Epic 1 Story 1.15** (epics.md:1082-1108): 4 ACs + the "`INV-deps-version-pinning`" stable-ID verbatim.
- **Architecture § Deferred / Post-1.0 / Technical Constraints**: no explicit deferral entry for Renovate at architecture.md (I7 is committed at 1.0); Story 1.15 IS the 1.0 delivery of that commitment.
- **Story 1.9 sync-gate downstream** (`packages/keel-invariants/src/sync-gate.ts`): walks `INVARIANTS.md` for column-0 `- **\`INV-*\`**` bullets; cross-references with the manifest; emits drift per `added-to-source-only` / `removed-from-source-only` / `added-to-docs-only` / `removed-from-docs-only` / `content-hash-mismatch` classes. Two new manifest entries require two corresponding anchor bullets (Task 4) + two correct contentHash values (Tasks 1/2 compute them; Task 3 pins them).

### Invariants manifest integration

- **Story 1.8 canonical shape** (`packages/keel-invariants/src/invariants.manifest.ts:3-15`): each entry has `id` + `description` + `sourcePath` + `contentHash` + `anchors`. Two new entries follow this shape exactly.
- **Story 1.9 sync-gate performance** (AC 7, pinned <2s): walker is O(n + m) in manifest entries × doc lines. Story 1.15 grows manifest from 20 → 22 entries (+10%) and INVARIANTS.md by ~4 lines (one H3 + two bullets + one-sentence summary, ~+6% of current ~82 lines). Performance impact: negligible; <2s budget held with comfortable margin (Story 1.14 observed 0.63s at 20 entries = 69% margin; 22 entries stays well inside).

### Stable-ID convention

Two new IDs match the `^INV-[a-z0-9]+(-[a-z0-9]+)+$` regex at `packages/keel-invariants/src/invariants.manifest.ts:4`:

- `INV-deps-version-pinning` — 3 lowercase-hyphenated segments after `INV-` prefix (deps / version / pinning). Epic-verbatim ID per AC 4.
- `INV-renovate-rationale` — 2 lowercase-hyphenated segments (renovate / rationale).

No uppercase, no underscores, no segment shorter than 1 char. Regex self-verified at drafting-time by mental-parse.

### Stable-IDs do NOT use three-segment TOKEN-style slugs

Per Story 1.10 AC 2 scope carve-out convention + Story 1.14 precedent: stable IDs are in `packages/keel-invariants/src/invariants.manifest.ts`'s `raw[].id` field (e.g. `INV-deps-version-pinning`), NOT three-segment `TOKEN-<domain>-<slug>` design-token-slot slugs. Story 1.15 adds no design-token slots; the `TOKEN-*` naming convention does not apply here.

### Project Structure Notes

- **New files** (2):
  - `.github/renovate.json` (JSON; Task 1).
  - `docs/invariants/renovate.md` (markdown; Task 2). Mirrors `docs/invariants/release.md` (Story 1.14) + `docs/invariants/tokens.md` (Story 1.10) + `docs/invariants/ralph-execute.md` (Story 1.9) precedents.
- **Edited files** (2):
  - `packages/keel-invariants/src/invariants.manifest.ts` — add 2 entries at end of `raw` array (Task 3). Preserve entries 1–20 in current order.
  - `INVARIANTS.md` — add 1 new H3 section (`### Dependency upgrade discipline (Story 1.15)`) between existing `### Release management (Story 1.14)` and `## Consumption` (Task 4). 2 column-0 bullets.
- **UN-touched** (explicit no-op confirmed at Task 5 for hash-cascade protection):
  - `package.json` (root) — no new scripts; protects `INV-prek-prepare-lifecycle` hash at `invariants.manifest.ts:97-103`.
  - `.pre-commit-config.yaml` — no new hook; protects `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` hash at `invariants.manifest.ts:89-95` + `:104-110`.
  - `packages/ui/tokens.json` — zero token-layer change; protects `INV-tokens-source` hash.
  - `packages/ui/scripts/generate-tokens.ts` — zero emitter change; protects `INV-tokens-emitter` + `INV-tokens-sync-gate` hash.
  - `tsconfig.base.json`, prettier config, ESLint config, commitlint config — zero shared-config touch; protects `INV-tsconfig-base` + `INV-eslint-shared` + `INV-prettier-shared` + `INV-commitlint-shared` hash.
  - `.github/release-please-config.json`, `.github/.release-please-manifest.json`, `docs/invariants/release.md` — zero release-layer touch; protects `INV-release-please-config` + `INV-release-please-manifest` + `INV-release-please-rationale` hash.

#### Variances

- **No architecture-vs-epic drift for Story 1.15.** AC 1 `.github/renovate.json` path matches architecture.md:649 + architecture.md:810 + epics.md:1090; all three converge. Contrast Story 1.14 AC 1 where `.github/release-please-config.json` drifted vs architecture.md:807's root-level layout — that drift was inherited; Story 1.15 is clean.
- **`pnpm.overrides` content deferred to downstream consumer stories.** Per AC 1 scope carve-out, the `pnpm.overrides` OTEL pins are authored when the first downstream story installs OTEL — Story 1.15 does NOT pre-emptively author an empty `pnpm.overrides` block in `package.json` because that would be (a) a speculative edit without a consumer, (b) a cascade hash update to `INV-prek-prepare-lifecycle` (Story 1.9 iter-4 lesson), and (c) Renovate's pnpm manager handles `pnpm.overrides` dynamically regardless of whether it is pre-authored.
- **Renovate GitHub App install deferred to ops runbook.** Carved out at AC 1. This is consistent with the substrate-vs-ops split that Stories 1.1–1.14 have established (substrate ships the config; ops runbooks ship the install ritual).
- **Manifest entry ordering** (Story 1.8 precedent): new entries appended in AC-order (`config` → `rationale`), NOT inserted mid-array. Story 1.14's 3 new entries appended after `INV-tokens-sync-gate`; Story 1.15's 2 new entries append after `INV-release-please-rationale` (current last entry at line 200-207).

### Testing Standards

**ATDD Skip Rationale (Story 1.15; FR14n matrix row 3; hybrid ground-(c) variant-(ii)+(iii); NINTH cumulative precedent candidate).**

`/bmad-testarch-atdd` will NOT be invoked for Story 1.15 for three conjoint grounds:

- **(a) substrate-verification-covers-ACs.** Task 6 enumerates 6 smoke tests — static JSON parse + `$schema` + `extends: config:recommended` + 4-packageRules enumeration with groupName-sort match + I7 `rangeStrategy: pin` for all 4 entries + manifest-load (22 invariants) + sync-gate clean — that exercise AC 1 + AC 4 end-to-end at substrate level. These are inline `node -e "..."` shell commands (matching Story 1.8 iter-3 pattern + Story 1.13 + Story 1.14 Task 7 pattern); no test runner needed to run them.
- **(b) no test runner at Story 1.15 time.** No `vitest.config.*` / `jest.config.*` / `playwright.config.*` exists anywhere in the tree (verified at drafting via shell probe); `/bmad-testarch-atdd` Step 1.2 (test-framework preflight) hard-prerequisite would HALT. Test runner landing is an Epic 13 / post-Epic-1 concern.
- **(c) HYBRID variant-(ii)+(iii) — downstream-story + CR-substitution.** 2 of 4 ACs (AC 2, AC 3) describe downstream-consumer behaviour that materializes only after (i) Tthew installs the Renovate GitHub App against the repo (ops action) AND (ii) Epic 13 lands the integration-test-passing CI gate + GH branch-protection status-check requirement. Renovate-runtime + Epic 13 CI are the formal integration gates for the auto-merge-gating + grouped-update-PR-shape assertions (variant ii). Additionally, Story 1.15's adversarial coverage of AC 1 + AC 4 (config shape integrity, 4-packageRules enumeration, I7 pin-mode invariance, groupName partition, automerge-false safety, fork-extension pointer validity) is delegated to the `/bmad-code-review (args: "2")` CR pass's three-layer adversarial fan-out (Blind Hunter diff-only + Edge Case Hunter diff + repo-read + Acceptance Auditor AC-verification) per variant (iii) spec-declared-CR-substitution pattern — same as Story 1.9/1.12/1.13/1.14. The hybrid is strictly stronger than either variant alone.

**Consistency rule carry-forward to Story 1.15 trace gate:** Epic-1-substrate stories with ATDD-skip at iter-N → trace gate at iter-(N+2) emits WAIVED (or analogous partial-coverage verdict) per the Story 1.7/1.8/1.9/1.10/1.11/1.12/1.13/1.14 precedent. Story 1.15 will emit NINTH cumulative WAIVED-with-substrate-evidence (Task 6 smokes are the substrate backstop; adversarial Wave-2 coverage is delegated to CR).

**Quality gates (mandatory — substrate verification):**

- `pnpm typecheck` (Turbo) — must be green. No TS code added by Story 1.15; a regression would be existing-package cross-reference drift.
- `pnpm lint` (ESLint) — must be green. No JS/TS edits trigger new lint rules.
- `pnpm format:check` (Prettier) — must be green post-`prettier --write` on the two new files (Tasks 1/2).
- `pnpm keel-invariants:check` — must exit 0 with no drift on the Story 1.15 landing commit. This validates (a) two new entries parse via Zod, (b) two sha256s match the file bytes on disk, (c) two anchors resolve in `INVARIANTS.md`, (d) existing 20 entries remain stable (no regressed hash).
- `pnpm keel-invariants:check-all` — composition of the Story 1.9 sync-gate (`keel-invariants:check`) + Story 1.13 token-sync gate (`keel-invariants:tokens-sync`). Both must exit 0. Story 1.15 does not touch tokens so `tokens-sync` is untouched.

**Adversarial coverage (deferred to CR pass):**

- **AC 1 (renovate.json shape + 4 packageRules + I7 pin-mode + grouped-update rules).** Blind Hunter / Edge Case Hunter / Acceptance Auditor examine the packageRules array for: correct `matchPackageNames` / `matchPackagePatterns` coverage (no typos — `^vitest($|/)` matches `vitest` exact + `vitest/foo` but not `vitest-something-else`; `^@vitest/` catches `@vitest/ui` + `@vitest/browser`; `^@opentelemetry/` catches all OTEL ecosystem without accidentally catching non-OTEL `@opent…`; `^@radix-ui/` catches all Radix primitives; `matchDatasources: ["docker"]` + `matchPackageNames: ["ghcr.io/fboulnois/pg_uuidv7"]` correctly scopes pg_uuidv7 to Docker datasource only, not npm), correct `groupName` partition (4 distinct names: `opentelemetry` / `pg-uuidv7` / `radix-ui` / `vitest` — no merge accidents), `rangeStrategy: pin` consistency across all 4 groups (smoke 4 asserts), `extends: ["config:recommended"]` is present (not overridden accidentally by a per-rule `extends`), `$schema` URL is canonical Renovate documentation URL, `automerge: false` at top-level AND per-rule (belt-and-suspenders — smoke 3 asserts top-level; per-rule is redundant-safe).
- **AC 2 (integration-test gate / automerge: false posture).** Variant (ii) downstream: Renovate runtime (respects branch-protection status-check requirement) + Epic 13 CI workflow (provides the required status check) validate this end-to-end. Story 1.15 only pins `automerge: false` at substrate; the rest is runtime behaviour. Acceptance Auditor verifies the `automerge: false` setting survives any future per-rule override (each of the 4 packageRules entries also has `automerge: false` — defense in depth).
- **AC 3 (OTEL grouped-update + pnpm.overrides atomicity).** Variant (ii) downstream: Renovate-runtime `pnpm` manager handles `pnpm.overrides` atomic-update via its pnpm package manager when the first downstream story authors the `pnpm.overrides` block. Story 1.15 ships the groupName; Renovate runtime handles the atomicity. Acceptance Auditor verifies `groupName: "opentelemetry"` with `matchPackagePatterns: ["^@opentelemetry/"]` — no misspellings, no accidental over/under-matching.
- **AC 4 (manifest + sync-gate drift detection on `INV-deps-version-pinning`).** Acceptance Auditor verifies: `INV-deps-version-pinning` is the literal ID used in manifest + anchor (matching epic verbatim per AC 4 literal text); sourcePath is exactly `.github/renovate.json`; contentHash matches `sha256sum .github/renovate.json` post-prettier; anchor in INVARIANTS.md column-0 format matches `ANCHOR_REGEX`; `INV-renovate-rationale` companion entry is present + sourcePath `docs/invariants/renovate.md` + contentHash matches.

### References

- Epic 1 Story 1.15: [Source: _bmad-output/planning-artifacts/epics.md#story-115-renovate-config-with-version-pinning-rules-i7](../planning-artifacts/epics.md) (lines 1082-1108)
- Architecture § I7 Implementation Invariant: [Source: _bmad-output/planning-artifacts/architecture.md#i7-version-pinning](../planning-artifacts/architecture.md) (lines 305 + 342-350; 3-agent-convergence pinning decision — Vitest exact minor + OTEL exact in `pnpm.overrides` + pg_uuidv7 image tag; `.github/renovate.json` authority)
- Architecture § Source-tree (renovate.json location): [Source: _bmad-output/planning-artifacts/architecture.md#source-tree](../planning-artifacts/architecture.md) (line 810; `.github/renovate.json` — I7 grouped-update rules + integration-test gates)
- Architecture § Repository layout: [Source: _bmad-output/planning-artifacts/architecture.md](../planning-artifacts/architecture.md) (line 649; `.github/renovate.json` Dev-time / tooling manifest enumeration)
- Epic 7 Story 7.2 AC (Radix pinning cross-story dependency): [Source: _bmad-output/planning-artifacts/epics.md#story-72-shadcnui-components-vendored](../planning-artifacts/epics.md) (line 3984; `@radix-ui/*` deps pinned — Story 1.15 renovate covers)
- PRD § I7 (Reproducibility / version pinning): [Source: _bmad-output/planning-artifacts/prd.md](../planning-artifacts/prd.md) (I7 amendment — reproducibility serves research-output richness; irreproducible substrate → corrupted research corpus)
- Story 1.8 (manifest contract + `InvariantSchema`): [Source: _bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md](./1-8-invariants-manifest-ts-contract-exporter.md)
- Story 1.9 (sync-gate + walker — consumer of new manifest entries): [Source: _bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md](./1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md)
- Story 1.14 (prior FR14n cycle — FOURTH ZERO-PATCH CR precedent; configuration-surface pattern): [Source: _bmad-output/implementation-artifacts/1-14-release-please-monorepo-config-single-bundled-mode.md](./1-14-release-please-monorepo-config-single-bundled-mode.md)
- Invariants manifest source: [Source: packages/keel-invariants/src/invariants.manifest.ts](../../packages/keel-invariants/src/invariants.manifest.ts)
- Sync-gate regex: [Source: packages/keel-invariants/src/sync-gate.ts](../../packages/keel-invariants/src/sync-gate.ts) (line 24: `ANCHOR_REGEX`)
- INVARIANTS.md (anchor doc): [Source: INVARIANTS.md](../../INVARIANTS.md)
- Renovate canonical config schema: https://docs.renovatebot.com/renovate-schema.json (cited as `$schema` in Task 1 JSON)
- Renovate preset `config:recommended`: https://docs.renovatebot.com/presets-config/#configrecommended (cited as `extends` baseline in Task 1 JSON)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.7 (1M context) via Ralph iter-84 `/bmad-dev-story` invocation.

### Debug Log References

**Content hashes (post-prettier):**

- `.github/renovate.json`: `c02f2bfe97a7811c3cdabc693e02f0c7b9d6a2a280b1c9701aee0d8d56cc4cd0`
- `docs/invariants/renovate.md`: `a18a353f3efc1496b208bf84bf5158daf72a0728ef1ada1b9976a300b7f81c56`

**Task 6 substrate smoke outputs (all PASS):**

1. Static JSON parse → `OK: static parse`.
2. Extends + schema → `OK: renovate schema + config:recommended extends`.
3. 4-packageRules + automerge default → `OK: 4 packageRules; groups=["opentelemetry","pg-uuidv7","radix-ui","vitest"]; automerge=false`.
4. I7 rangeStrategy pin → `OK: all 4 I7 groups pin-mode`.
5. Manifest load (post `pnpm --filter @keel/keel-invariants build` per iter-77 Gotcha) → `OK: 22 invariants` (20 pre-Story-1.15 + 2 new).
6. Sync-gate clean → `pnpm keel-invariants:check` exit 0; wall-clock 0.644s (comfortably inside Story 1.9 AC 7 <2s budget; 68% margin).

**Full quality-gate suite (all PASS):**

- `pnpm typecheck` → 16/16 tasks successful, 1.676s total.
- `pnpm lint` → 16/16 tasks successful, 10.296s total.
- `pnpm format:check` → `All matched files use Prettier code style!`.
- `pnpm keel-invariants:check-all` → composition (`keel-invariants:check` + `keel-invariants:tokens-sync`) exit 0, no drift.

### Completion Notes List

- Single-pass dev-story at configuration-surface scale, matching Story 1.14 iter-77 precedent. 4 files landed (2 NEW + 2 MODIFIED); no runtime code; no cascade hash updates (Task 5 no-op protected `INV-prek-*` + `INV-tokens-*` + `INV-release-please-*` entries).
- Iter-77 Gotcha honored: `pnpm --filter @keel/keel-invariants build` executed before runtime manifest-load smoke (dist/ cache staleness would otherwise surface 20 entries instead of 22).
- Manifest grew 20 → 22 entries (AC 4). Both new IDs conform to the `^INV-[a-z0-9]+(-[a-z0-9]+)+$` regex (`invariants.manifest.ts:4`). Both sourcePaths are unique (no cross-entry contentHash-parity concern).
- `packageRules` array enumerates the 4 I7 ecosystems exactly (Vitest, OpenTelemetry, Radix UI, pg_uuidv7); sorted `groupName` values match the expected `["opentelemetry","pg-uuidv7","radix-ui","vitest"]` partition.
- Top-level `automerge: false` + per-group `automerge: false` (belt-and-suspenders) ensures no Renovate PR can auto-merge until Epic 13 lands the CI gate + GH branch-protection status-check requirement.
- `INVARIANTS.md` grew by 7 lines (1 H3 + 1 summary + 2 column-0 bullets + formatting); column-0 bullet shape matches `ANCHOR_REGEX` at `packages/keel-invariants/src/sync-gate.ts:24` (confirmed via `pnpm keel-invariants:check` clean exit).
- AC coverage summary: AC 1 satisfied via `.github/renovate.json` shape + Task 6 smokes 1–4; AC 2 substrate half satisfied via top-level `automerge: false` + Task 6 smoke 3 (runtime half is Epic 13 consumer per scope carve-out); AC 3 substrate half satisfied via `groupName: "opentelemetry"` + `matchPackagePatterns: ["^@opentelemetry/"]` (runtime atomicity is Renovate pnpm-manager behaviour per scope carve-out); AC 4 satisfied via 2 manifest entries + 2 anchor bullets + Task 6 smokes 5–6.

### File List

**New (2):**

- `.github/renovate.json` — Renovate I7 policy config (Task 1).
- `docs/invariants/renovate.md` — companion rationale doc (Task 2).

**Modified (2):**

- `packages/keel-invariants/src/invariants.manifest.ts` — 2 new entries appended (Task 3).
- `INVARIANTS.md` — 1 new H3 `### Dependency upgrade discipline (Story 1.15)` section + 2 column-0 bullets inserted between `### Release management (Story 1.14)` and `## Consumption` (Task 4).

**Ralph bookkeeping (2):**

- `_bmad-output/implementation-artifacts/sprint-status.yaml` — story `ready-for-dev → in-progress → review`; header + data `last_updated: 2026-04-21 Story-1-15-review UTC`.
- `_bmad-output/implementation-artifacts/1-15-renovate-config-with-version-pinning-rules-i7.md` — this file; Tasks marked [x], Status → review, Dev Agent Record populated, Change Log v1.3 appended.

**Untouched (explicit no-op per Task 5):**

- `package.json` (root) — no new scripts; `INV-prek-prepare-lifecycle` hash preserved.
- `.pre-commit-config.yaml` — no new hook; `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` hashes preserved.
- `packages/ui/tokens.json`, `packages/ui/scripts/generate-tokens.ts`, token-layer configs — no token touch; `INV-tokens-*` hashes preserved.
- `.github/release-please-config.json`, `.github/.release-please-manifest.json`, `docs/invariants/release.md` — no release-layer touch; `INV-release-please-*` hashes preserved.

## Change Log

| Date       | Version | Description                                                                                                                                                                                                                                                           | Author |
| ---------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 2026-04-21 | v1.0    | Initial drafting — 4 ACs + 6 Tasks + seven preventative audit layers pre-applied per iter-80 compound-ZERO-PATCH carry-forward; hybrid ground-(c) variant-(ii)+(iii) ATDD-skip pre-staged (NINTH cumulative Epic-1 ATDD-skip + NINTH WAIVED-trace + FIFTH ZERO-PATCH-CR candidates). Story State: `_(no story) → drafted`. Sprint-status: `1-15-...: backlog → ready-for-dev` + `last_updated: 2026-04-21 Story-1-15-drafted UTC`. | Ralph  |
| 2026-04-21 | v1.1    | Pre-dev SM review (`/bmad-create-story (args: "review")`) — FR14n matrix row 2 `drafted → validated`. Three parallel fresh-context audits (L1 stable-ID regex + L2 Task↔AC bidirectional coverage + L3 sprint-status wording + L4 cross-AC convergence + L5 mechanical-counter discipline + L6 schema-permission diff + L7 Renovate config-shape contract) ran. **1 PATCH applied** (L4-class cross-file citation drift): 4 sites cited `architecture.md:3984` for the `@radix-ui/*` pinning cross-story dependency, but the actual source is `epics.md:3984` (Epic 7 Story 7.2 AC). Fixed all 4 sibling sites per RALPH.md 2026-04-20 drift-survey-scope rule: (a) AC 1 Given-clause narrative at line 22; (b) Task 1 JSON packageRules entry 3 description at line 87; (c) Dev Notes § Architecture references at line 201; (d) References section at line 281. Architecture.md § F1 Component library (line 240) is noted as the vendoring-posture source; the delegation-to-Story-1.15 literal lives in epics.md only. **Residual count 1 PATCH (below 2-PATCH 4-story precedent average Stories 1.11/1.12/1.13/1.14)** — configuration-surface + epic-verbatim-ID discipline reduced drafting-time drift. L1/L2/L3/L5/L6/L7 all clean. Story State: `drafted → validated`. Sprint-status `last_updated: 2026-04-21 Story-1-15-validated UTC`. | Ralph  |
| 2026-04-21 | v1.2    | `/bmad-testarch-atdd` hybrid ground-(c) variant-(ii)+(iii) ATDD-SKIP — FR14n matrix row 3 `validated → atdd-scaffolded`. **NINTH cumulative Epic-1 ATDD-skip precedent** (Stories 1.7 iter-14 + 1.8 iter-29 + 1.9 iter-36 + 1.10 iter-43 + 1.11 iter-50 + 1.12 iter-57 + 1.13 iter-64 + 1.14 iter-71 → 1.15 iter-83). Skill preflight HALTs at Step 1.2 (no test runner — `vitest.config.*` / `jest.config.*` / `playwright.config.*` absent; landing is Epic 13 / post-Epic-1). Three-ground rationale honored verbatim per § Testing Standards lines 250–258: **(a)** substrate-verification-covers-ACs at CLI-exit-code level — Task 6 six smokes (static JSON parse + `$schema` + `extends: config:recommended` + 4-packageRules enumeration with groupName-sort match + I7 `rangeStrategy: pin` invariance + manifest-load 22 entries + sync-gate clean) exercise AC 1 + AC 4 end-to-end; **(b)** no-runner — framework prerequisite unmet; **(c)** HYBRID variant-(ii)+(iii) — AC 2 auto-merge-gating + AC 3 OTEL grouped-update-atomicity owned by Renovate runtime + Epic 13 CI gate (variant ii); adversarial AC 1 + AC 4 coverage (config-shape integrity + 4-packageRules enumeration + I7 pin-mode invariance + groupName partition + automerge-false safety + fork-extension pointer validity) delegated to iter-87 `/bmad-code-review (args: "2")` three-layer fan-out (variant iii). Mirrors Story 1.14 iter-76 v1.2 pattern exactly. No test-plan artefacts authored (variant-(ii)+(iii) substitution pattern). Story State: `validated → atdd-scaffolded`. | Ralph  |
| 2026-04-21 | v1.3    | `/bmad-dev-story` single-pass implementation — FR14n matrix row 4 `atdd-scaffolded → in-dev → review`. 4 files landed: 2 NEW (`.github/renovate.json` with 4 packageRules + `automerge: false` + `config:recommended` extends + Renovate canonical `$schema`; `docs/invariants/renovate.md` with H1 + 4-line header + § Overview anchor bullet + § I7 posture + § Files + § Per-package pinning rules 4×4 table + § Grouping rationale + § Fork extension + § Consumption) + 2 MODIFIED (`packages/keel-invariants/src/invariants.manifest.ts` +2 entries → 22 total; `INVARIANTS.md` +1 H3 `### Dependency upgrade discipline (Story 1.15)` + 2 column-0 bullets between Release management and Consumption). Content hashes post-prettier: `.github/renovate.json: c02f2bfe97a7811c3cdabc693e02f0c7b9d6a2a280b1c9701aee0d8d56cc4cd0`; `docs/invariants/renovate.md: a18a353f3efc1496b208bf84bf5158daf72a0728ef1ada1b9976a300b7f81c56`. All 6 Task 6 substrate smokes PASS: (1) static JSON parse; (2) `$schema` + `extends: config:recommended`; (3) 4-packageRules enumeration with groupName-sort match `["opentelemetry","pg-uuidv7","radix-ui","vitest"]` + `automerge: false`; (4) all 4 I7 groups `rangeStrategy: pin`; (5) manifest-load `OK: 22 invariants` (post `pnpm --filter @keel/keel-invariants build` per iter-77 Gotcha); (6) `pnpm keel-invariants:check` exit 0 in 0.644s (68% margin vs Story 1.9 AC 7 <2s budget). Full quality-gate suite PASS: `pnpm typecheck` 16/16 in 1.676s; `pnpm lint` 16/16 in 10.296s; `pnpm format:check` clean; `pnpm keel-invariants:check-all` clean. Single-pass at configuration-surface scale matches Story 1.14 iter-77 precedent. Task 5 explicit no-op protected all cascade hashes (`INV-prek-*` + `INV-tokens-*` + `INV-release-please-*`); no sibling invariant entries required hash updates. Story State: `atdd-scaffolded → in-dev → review`. Sprint-status `1-15-...: ready-for-dev → in-progress → review`; `last_updated: 2026-04-21 Story-1-15-review UTC`. | Ralph  |
