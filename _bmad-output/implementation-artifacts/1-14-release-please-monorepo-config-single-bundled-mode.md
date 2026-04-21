# Story 1.14: release-please monorepo config — single-bundled mode

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a substrate maintainer,
I want `release-please-monorepo` wired in **single-bundled release mode** via two committed JSON files (`.github/release-please-config.json` + `.github/.release-please-manifest.json`), driven by conventional-commit messages (FR31, architecture.md § Commit / PR / Knowledge-file Patterns, `BREAKING CHANGE:` footer → major bump), and registered as enforced invariants in the Story-1.8 manifest (`INV-release-please-config` + `INV-release-please-manifest`) so the Story-1.9 sync-gate drift-detects any ad-hoc edits,
So that (a) a rolling Release PR auto-accumulates a changelog + version bumps across all 17 workspace packages in lockstep, (b) `feat:` commits trigger minor bumps + `fix:` triggers patch bumps + `feat!:` or `BREAKING CHANGE:` triggers major bumps, (c) merging the Release PR tags the release on `main` + publishes GitHub Release notes + the next conventional-commit starts a fresh Release PR, (d) the single-bundled choice is documented with a pointer to architecture's per-package deferral rationale (architecture.md:1342), and (e) the config files are drift-detected on every commit so a silent edit to release discipline is impossible (closes FR31 substrate authoring; Story 13.5 lands the GitHub Actions workflow consumer later in Epic 13).

## Acceptance Criteria

1. **Given** `.github/release-please-config.json` and `.github/.release-please-manifest.json`,
   **When** I inspect them,
   **Then** the config is **single bundled release** (not per-package — all 17 workspace packages share a single component + move in lockstep)
   **And** every workspace package appears in the manifest with its current version (17 entries — `.`, `apps/web`, and every `packages/*` — see § Task 2 enumeration; initial manifest value is `0.0.0` matching every workspace member's current `package.json:version` value).

   **Story 1.14 scope carve-out — file locations (architecture drift acknowledged).** The two files live under `.github/` per AC 1's Given-clause (`.github/release-please-config.json` + `.github/.release-please-manifest.json`). Architecture.md's § Source-tree (line 791 onwards) shows `release-please-config.json` at repo root (line 807) with only `release-please-manifest.json` inside `.github/` (line 809) — that drafting is stale vs Epic 1 Story 1.14 sprint-decomposed AC. Sprint-decomposed AC wins per RALPH.md 2026-04-19 Lesson ("epics.md AC wins (sprint-decomposed source of truth); record variances in Project Structure Notes"). Both files under `.github/` keeps release-infrastructure co-located (consistent with `.github/renovate.json` — architecture.md:810 — and the workflow-file consumers landing in Epic 13 under `.github/workflows/`). The release-please-action defaults (`config-file: release-please-config.json`, `manifest-file: .release-please-manifest.json`) are overridden in Story 13.5's workflow via explicit inputs pointing at `.github/`-prefixed paths; Story 1.14 does NOT author the workflow (scope carve-out — see AC 6 below).

   **Story 1.14 scope carve-out — manifest `.` entry represents the monorepo root component.** The manifest contains ONE entry per releasable package path. In single-bundled mode, a root-level `.` entry represents the shared release component; the per-workspace entries (`apps/web`, `packages/audit`, etc.) also exist but all share the same group so a single Release PR covers them. Concrete initial shape: `{ ".": "0.0.0", "apps/web": "0.0.0", "packages/audit": "0.0.0", ... }` — 18 entries total (1 root + 17 workspace members — 1 `apps/web` + 16 `packages/*`). Versions bump atomically via the `linked-versions` plugin (see § Task 1 config shape).

2. **Given** a merged PR with `feat: X` on `main`,
   **When** the release-please Action runs (once wired in Story 13.5),
   **Then** the existing Release PR is updated with a **minor-bump** entry in the changelog under `### Features`
   **And** no Release PR is yet merged (the Release PR accumulates entries until Tthew merges it — AC 5 below).

   **Story 1.14 scope carve-out — pre-1.0 bump discipline.** Every workspace package currently sits at `0.0.0` (pre-release; see `apps/web/package.json:version` + every `packages/*/package.json:version`). Release-please treats pre-1.0 (`0.x.y`) versions specially by default: `feat:` commits would normally be MINOR bumps but at pre-1.0 `feat:` can be either MINOR or PATCH depending on the `bump-minor-pre-major` / `bump-patch-for-minor-pre-major` config flags. Story 1.14 PINS both flags to `true` so pre-1.0 `feat:` → MINOR (`0.0.0 → 0.1.0`) and pre-1.0 `fix:` → PATCH (`0.0.0 → 0.0.1`), matching the intent of AC 2 + AC 3 semantic labels. At 1.0 cut, Tthew can set `release-as: "1.0.0"` or commit with a `BREAKING CHANGE:` body to trigger the major transition; the config does NOT pre-pin the 1.0 cut (that's a manual ritual per FR31).

3. **Given** a merged PR with `fix: Y` on `main`,
   **When** the Action runs,
   **Then** the Release PR is updated with a **patch-bump** entry under `### Bug Fixes`
   **And** the Release PR tracks accumulating `feat:` + `fix:` + `perf:` + `refactor:` + docs-change entries per the release-please `changelog-types` contract (see § Task 1 config shape for the `changelog-types` array pinning — same set architecture.md § Commit / PR / Knowledge-file Patterns line 677 enumerates: `feat | fix | docs | chore | refactor | test | build | ci | perf`).

4. **Given** a merged PR with `feat!: Z` OR a commit body containing `BREAKING CHANGE: <reason>`,
   **When** the Action runs,
   **Then** the Release PR escalates to a **major bump** (`0.x.y → 1.0.0` if pre-1.0; `N.x.y → (N+1).0.0` if post-1.0)
   **And** release-please emits the breaking-change note under `### ⚠ BREAKING CHANGES` in the changelog
   **And** commitlint already enforces the `!` + `BREAKING CHANGE:` syntax (Story 1.5 `INV-commitlint-shared` — `@commitlint/config-conventional` accepts both forms; `BREAKING CHANGE:` footer triggers release-please major bump per architecture.md:681).

5. **Given** Tthew merges the accumulated Release PR on `main`,
   **When** it lands,
   **Then** release-please (running via Story 13.5's workflow — see AC 6 scope carve-out) **tags the release** on `main` (format: `v<semver>` by default, configurable via config's `include-v-in-tag: true`) AND **publishes GitHub Release notes** (copy of the changelog section) AND **the next conventional-commit to `main` starts a fresh Release PR**.

   **Story 1.14 scope carve-out — tag + release-notes format.** release-please's default GitHub Release includes a `v`-prefix on the tag (`v0.1.0`, `v1.0.0`). The config pins `include-v-in-tag: true` explicitly to prevent Renovate or any upstream tooling that auto-detects versions from disagreeing on the prefix convention. The Release Notes body is the changelog section for the newly-released version (release-please populates it automatically — no custom template needed at 1.0).

   **Story 1.14 scope carve-out — the release-please WORKFLOW is Story 13.5 scope, NOT Story 1.14.** This story authors ONLY the two JSON config files + manifest entries. The GitHub Actions workflow (`.github/workflows/release-please.yml`) that invokes `googleapis/release-please-action` on every push to `main` lands in Epic 13 Story 13.5 (`release-please.yml (release-please PR/tag automation)` — epics.md:5585-5602). Until Story 13.5 lands, the config files exist as substrate but produce no Release PRs (no workflow invokes them). This is intentional: the config is a contract (drift-detected by Story 1.9 sync-gate) that the Epic-13 workflow consumes. AC 5 + AC 2/3/4's "When the Action runs" wording describes downstream Story-13.5 consumer behaviour; Story 1.14's substrate verification (Task 7) only confirms static JSON validity + single-bundled-mode shape + manifest parity with workspace members + drift-detection wiring — NOT runtime release-please execution (that's Epic 13's acceptance probe).

6. **Given** per-package release mode was considered,
   **When** I read the `release-please-config.json` top-level `$schema` + an inline comment-equivalent pointer (release-please's config JSON does not permit `//`-style comments — the pointer lives in a `notes` field under the `keel` component AND in the § Dev Notes docblock adjacent to the file in `docs/invariants/release.md` if authored; see § Task 3),
   **Then** the single-bundled choice is documented with a **pointer to architecture.md § Deferred / Post-1.0 line 1342** ("release-please-monorepo per-package release mode — deferred; single-bundled release is the N=1 choice").

   **Story 1.14 scope carve-out — `notes` vs inline comment.** JSON specification forbids `//` comments; release-please-config.json is strict JSON (NOT JSON5 / JSONC). The architectural-rationale pointer lives in:
   - (a) `release-please-config.json` top-level `"$schema"` reference (canonical release-please schema URL — standard discovery aid, not a documentation field);
   - (b) a companion `docs/invariants/release.md` markdown file (NEW at Story 1.14) that explains the single-bundled choice + points at architecture.md:1342 + describes the `feat: / fix: / feat!:` bump mapping for fork operators — this file is ALSO a new invariant in the manifest (`INV-release-please-rationale` — see § Task 2 below; anchor bullet added to INVARIANTS.md under a new `### Release management (Story 1.14)` section inserted between the existing `### Design-token quality gates (Story 1.13)` section (line 61–65) and the `## Consumption` section at line 67);
   - (c) the § Dev Notes in this story file pin the pointer verbatim so dev-story does not drift.

   **Story 1.14 scope carve-out — 2 new invariants, NOT 3, NOT 1.** Following the Story 1.8 convention (one stable ID per enforced invariant, per-file content-hash), Story 1.14 registers TWO primary invariants plus ONE documentation-invariant (see § Task 2 enumeration):
   - `INV-release-please-config` — sourcePath `.github/release-please-config.json`; anchors `['INV-release-please-config']`
   - `INV-release-please-manifest` — sourcePath `.github/.release-please-manifest.json`; anchors `['INV-release-please-manifest']`
   - `INV-release-please-rationale` — sourcePath `docs/invariants/release.md`; anchors `['INV-release-please-rationale']`
   The three-ID shape keeps per-file drift surgical (a silent edit to config is distinct drift from a silent edit to the manifest, which is distinct from a silent edit to the rationale doc; the Story-1.9 sync-gate emits separate drift entries for each). An alternative single `INV-release-please-bundle` collapsing all three is rejected for the same reason Story 1.13 rejected bundling its 3 gates (AC 4 § carve-out line 63): bundling collapses drift detection. Manifest grows **17 → 20** entries.

## Tasks / Subtasks

- [ ] **Task 1: Author `.github/release-please-config.json` (single-bundled mode; all 17 workspace packages + root component)** (AC: 1, 2, 3, 4, 5)
  - [ ] Author the JSON file at `.github/release-please-config.json`. Canonical shape (pinned here so dev-story does not drift; all fields required unless labelled `optional`):
    ```json
    {
      "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
      "release-type": "node",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": true,
      "include-v-in-tag": true,
      "separate-pull-requests": false,
      "plugins": [
        { "type": "linked-versions", "groupName": "keel", "components": ["keel"] }
      ],
      "changelog-sections": [
        { "type": "feat", "section": "Features" },
        { "type": "fix", "section": "Bug Fixes" },
        { "type": "perf", "section": "Performance Improvements" },
        { "type": "refactor", "section": "Code Refactoring" },
        { "type": "docs", "section": "Documentation" },
        { "type": "chore", "section": "Miscellaneous Chores", "hidden": true },
        { "type": "test", "section": "Tests", "hidden": true },
        { "type": "build", "section": "Build System", "hidden": true },
        { "type": "ci", "section": "Continuous Integration", "hidden": true }
      ],
      "packages": {
        ".": { "component": "keel", "package-name": "keel" },
        "apps/web": { "component": "keel", "package-name": "@keel/web" },
        "packages/audit": { "component": "keel", "package-name": "@keel/audit" },
        "packages/billing": { "component": "keel", "package-name": "@keel/billing" },
        "packages/config": { "component": "keel", "package-name": "@keel/config" },
        "packages/contracts": { "component": "keel", "package-name": "@keel/contracts" },
        "packages/core": { "component": "keel", "package-name": "@keel/core" },
        "packages/create-keel-app": { "component": "keel", "package-name": "@keel/create-keel-app" },
        "packages/db": { "component": "keel", "package-name": "@keel/db" },
        "packages/devbox": { "component": "keel", "package-name": "@keel/devbox" },
        "packages/email": { "component": "keel", "package-name": "@keel/email" },
        "packages/flags": { "component": "keel", "package-name": "@keel/flags" },
        "packages/jobs": { "component": "keel", "package-name": "@keel/jobs" },
        "packages/keel-generator": { "component": "keel", "package-name": "@keel/keel-generator" },
        "packages/keel-invariants": { "component": "keel", "package-name": "@keel/keel-invariants" },
        "packages/keel-templates": { "component": "keel", "package-name": "@keel/keel-templates" },
        "packages/ui": { "component": "keel", "package-name": "@keel/ui" }
      }
    }
    ```
  - [ ] Verify all 17 workspace packages are listed (1 root component `.` + 1 `apps/web` + 15 `packages/*` listed above — note: 16 `packages/*` directories exist; the `packages/create-keel-app` is included as a workspace member that is ALSO release-tracked alongside the substrate packages per architecture.md:791-821 § Source-tree). Count check at author-time: `ls -d apps/*/ packages/*/ | wc -l` must equal `17`; the `packages:` object must have `18` keys (17 workspace + 1 root `.` entry).
  - [ ] Prettier-format the file via `pnpm exec prettier --write .github/release-please-config.json` before commit so it matches Story 1.6 formatting baseline.
  - [ ] Compute the sha256 content hash of the prettier-formatted file for the manifest entry (see Task 2). Command: `sha256sum .github/release-please-config.json` (post-prettier).

- [ ] **Task 2: Author `.github/.release-please-manifest.json` (initial versions = 0.0.0 for every workspace package + root component)** (AC: 1)
  - [ ] Author the JSON file at `.github/.release-please-manifest.json`. Shape (all 18 keys; values match current `package.json:version` of each workspace member — which is `0.0.0` everywhere per Task 1 enumeration check):
    ```json
    {
      ".": "0.0.0",
      "apps/web": "0.0.0",
      "packages/audit": "0.0.0",
      "packages/billing": "0.0.0",
      "packages/config": "0.0.0",
      "packages/contracts": "0.0.0",
      "packages/core": "0.0.0",
      "packages/create-keel-app": "0.0.0",
      "packages/db": "0.0.0",
      "packages/devbox": "0.0.0",
      "packages/email": "0.0.0",
      "packages/flags": "0.0.0",
      "packages/jobs": "0.0.0",
      "packages/keel-generator": "0.0.0",
      "packages/keel-invariants": "0.0.0",
      "packages/keel-templates": "0.0.0",
      "packages/ui": "0.0.0"
    }
    ```
  - [ ] Cross-verify every key matches a `packages:` key in `release-please-config.json` from Task 1 (18-key parity — the linked-versions plugin requires this parity on every run; missing-key drift would fail the first real release-please action invocation once Story 13.5 lands).
  - [ ] Cross-verify every value matches the current `version` field in each referenced `package.json`. Command: `for d in apps/web packages/*; do node -p "require('./$d/package.json').version" | xargs -I{} echo $d={}; done` — every line must read `<path>=0.0.0`.
  - [ ] Prettier-format the manifest file: `pnpm exec prettier --write .github/.release-please-manifest.json`.
  - [ ] Compute the sha256 content hash of the prettier-formatted file for the manifest entry.

- [ ] **Task 3: Author `docs/invariants/release.md` (single-bundled choice rationale + fork-operator pointer)** (AC: 6)
  - [ ] Author `docs/invariants/release.md` as a plain markdown documentation file (mirrors `docs/invariants/tokens.md` + `docs/invariants/ralph-execute.md` precedents from Stories 1.10 + 1.9). Structure:
    - H1: `# Release management — release-please single-bundled monorepo (Story 1.14)`
    - § Overview — one paragraph summarizing FR31 + the `feat:/fix:/feat!:` → semver mapping
    - § Single-bundled choice — points at `_bmad-output/planning-artifacts/architecture.md` § Deferred / Post-1.0 line 1342 verbatim (`release-please-monorepo per-package release mode — deferred; single-bundled release is the N=1 choice`), explains the trade-off (lockstep versioning simplifies the 1.0 cut ritual; per-package mode can be revisited at Growth-tier if a package is extracted per architecture.md:597)
    - § Files — lists the two config files (location + purpose) + two new manifest invariants + the `INV-release-please-rationale` self-reference
    - § Commit-type → semver mapping — table with 4 rows (`feat:` → minor pre-major / patch pre-major depending on flags, `fix:` → patch, `feat!:` or `BREAKING CHANGE:` → major, other types per `changelog-sections`)
    - § Fork extension — 2 sentences pointing at FR44 (forks can extend by editing `.github/release-please-config.json` per-fork, same as any substrate file) and noting that replacing single-bundled with per-package is a source-fork-level change (re-author the plugin block + split `packages:` into per-component groupings)
    - § Consumption — points at Story 13.5's `.github/workflows/release-please.yml` (future) as the runtime consumer
    - § Anchor — add the `- **\`INV-release-please-rationale\`**: Single-bundled release-please-monorepo choice rationale + bump mapping + fork-extension pointer.` anchor bullet at the end of the § Overview section so the Story 1.9 walker (column-0 bullet, `^-\s+\*\*\`INV-[a-z0-9]+(?:-[a-z0-9]+)+\`\*\*` per `packages/keel-invariants/src/sync-gate.ts:24`) detects it. Matches the Story 1.9 iter-8 anchor-regex contract.
  - [ ] Prettier-format: `pnpm exec prettier --write docs/invariants/release.md`.
  - [ ] Compute the sha256 content hash for the manifest entry.

- [ ] **Task 4: Add 3 new invariant entries to `packages/keel-invariants/src/invariants.manifest.ts` → `raw` array** (AC: 1, 6)
  - [ ] Add three entries to the `raw: Invariant[]` array at the end (post the existing `INV-tokens-sync-gate` at line 176-183; preserve the existing 17 entries in their current order). Shape of each entry matches the Story 1.10/1.11/1.12/1.13 precedents:
    ```ts
    {
      id: 'INV-release-please-config',
      description:
        'release-please-monorepo single-bundled-mode configuration — .github/release-please-config.json; pins release-type node + linked-versions plugin (groupName keel) + bump-minor-pre-major + bump-patch-for-minor-pre-major + include-v-in-tag + changelog-sections (9 conventional-commit types; 4 visible + 5 hidden) + packages map listing the root component (.) and every workspace member (apps/web + 16 packages/*). Conventional-commit bump mapping: feat: → minor (pre-1.0 minor per bump-minor-pre-major), fix: → patch, feat!:/BREAKING CHANGE: → major. Consumed by Story 13.5 release-please.yml workflow (Epic 13) at every push to main; static drift is detected by Story 1.9 pre-merge sync-gate (FR43).',
      sourcePath: '.github/release-please-config.json',
      contentHash: '<sha256 from Task 1>',
      anchors: ['INV-release-please-config'],
    },
    {
      id: 'INV-release-please-manifest',
      description:
        'release-please state-of-record manifest — .github/.release-please-manifest.json; maps every releasable path (. root component + apps/web + 16 packages/*) to its current semver. Initial state: all 18 entries at 0.0.0 matching every workspace member\'s current package.json version. Updated atomically (every entry bumps in lockstep per linked-versions plugin) by release-please on Release-PR merge (AC 5). Linked-versions plugin requires key-parity with release-please-config.json packages map; drift between the two files is invalid config and would fail the Epic-13 workflow invocation.',
      sourcePath: '.github/.release-please-manifest.json',
      contentHash: '<sha256 from Task 2>',
      anchors: ['INV-release-please-manifest'],
    },
    {
      id: 'INV-release-please-rationale',
      description:
        'Documentation-layer rationale for the release-please single-bundled choice — docs/invariants/release.md; mirrors Story 1.10\'s INV-tokens-semantic-rationale pattern (companion doc to a machine-enforced invariant, drift-detected at the doc layer). Explains (a) the single-bundled vs per-package trade-off with a verbatim pointer to architecture.md § Deferred / Post-1.0 line 1342, (b) the feat:/fix:/feat!: → semver mapping table, (c) fork-extension guidance (FR44 — single-bundled → per-package is a source-fork change, not a config toggle), (d) consumption pointer to Story 13.5 release-please.yml workflow. Companion to INV-release-please-config.',
      sourcePath: 'docs/invariants/release.md',
      contentHash: '<sha256 from Task 3>',
      anchors: ['INV-release-please-rationale'],
    },
    ```
  - [ ] Verify the schema refinement (`superRefine` uniqueness + cross-sourcePath contentHash parity) holds after the additions. The three new entries have unique IDs + unique sourcePaths; no shared-sourcePath cross-entry check fires.
  - [ ] Run `node -e "import('@keel/keel-invariants').then(m => console.log('OK: ' + m.invariants.length + ' invariants'))"` from `packages/keel-invariants/` to confirm the manifest parses + exports 20 entries (17 current + 3 new).

- [ ] **Task 5: Add 3 anchor bullets to `INVARIANTS.md` under a new `### Release management (Story 1.14)` section** (AC: 1, 6)
  - [ ] Insert a new `### Release management (Story 1.14)` H3 section in `INVARIANTS.md` between the existing `### Design-token quality gates (Story 1.13)` section (ends at line 65) and the `## Consumption` H2 at line 67. The section opens with a one-sentence summary sentence ("Single-bundled release-please config + per-workspace manifest + companion rationale doc; conventional-commits → semver bumps → rolling Release PR.") and lists three column-0 bullets (matching the Story-1.9 `ANCHOR_REGEX` shape `^-\s+\*\*\`INV-[a-z0-9]+(?:-[a-z0-9]+)+\`\*\*`):
    - `- **\`INV-release-please-config\`**: .github/release-please-config.json — single-bundled monorepo config (release-type node + linked-versions plugin + bump-minor-pre-major + 18-package `packages:` map).`
    - `- **\`INV-release-please-manifest\`**: .github/.release-please-manifest.json — per-path version state-of-record (18 entries; initial 0.0.0 everywhere).`
    - `- **\`INV-release-please-rationale\`**: docs/invariants/release.md — single-bundled vs per-package trade-off rationale + commit-type semver mapping + fork-extension guidance.`
  - [ ] Re-compute the contentHash of `INVARIANTS.md` is NOT needed — INVARIANTS.md is not a `sourcePath` in the manifest (it is the ANCHOR DOC walked by Story 1.9 via `ANCHOR_REGEX`; the walker re-reads the doc on every sync-gate invocation, so the doc's content hash is recomputed at runtime rather than pinned as a manifest field).
  - [ ] Prettier-format: `pnpm exec prettier --write INVARIANTS.md`.

- [ ] **Task 6: Add 0 new scripts to root `package.json`** (AC: 1, 5)
  - [ ] **Explicit no-op confirmation.** Story 1.14's substrate is two JSON files + one markdown file + three manifest entries + three anchor bullets. No new pnpm scripts are required at root `package.json`; `pnpm keel-invariants:check` (Story 1.9) already walks the manifest + compares sha256 hashes per sourcePath, so the three new entries are automatically covered. Similarly, no `.pre-commit-config.yaml` hook addition is needed — the existing Story 1.9 sync-gate + the Story 1.4 format-check hook jointly cover the files (format-check fails on unprettier'd JSON; sync-gate fails on contentHash drift).
  - [ ] **IMPORTANT:** any edit to `package.json` WOULD require updating the `INV-prek-prepare-lifecycle` entry's `contentHash` at `packages/keel-invariants/src/invariants.manifest.ts:97-103` per Story 1.9 iter-4 lesson 2026-04-20 ("Substrate packages consuming substrate sourcePath'd files must recompute hashes when the PR edits those files"). Task 6's explicit no-op is protective: not editing `package.json` means no cascade hash update.

- [ ] **Task 7: Substrate verification — JSON validity, single-bundled-mode shape, manifest parity, sync-gate clean** (AC: 1, 2, 3, 4, 5, 6)
  - [ ] **Static JSON parse:** `node -e "JSON.parse(require('fs').readFileSync('.github/release-please-config.json','utf8'))"` must exit 0. Same for the manifest. Validates both files are well-formed.
  - [ ] **Single-bundled mode shape smoke:** `node -e "const c=JSON.parse(require('fs').readFileSync('.github/release-please-config.json','utf8')); if (c['separate-pull-requests'] !== false) throw new Error('config is not single-bundled'); if (!c.plugins.some(p => p.type === 'linked-versions' && p.groupName === 'keel')) throw new Error('missing linked-versions plugin with groupName keel'); const pkgs = Object.keys(c.packages); if (pkgs.length !== 18) throw new Error('expected 18 packages; got ' + pkgs.length); console.log('OK: single-bundled mode; ' + pkgs.length + ' packages');"` must print `OK: single-bundled mode; 18 packages`.
  - [ ] **Manifest key-parity smoke:** `node -e "const c=JSON.parse(require('fs').readFileSync('.github/release-please-config.json','utf8')); const m=JSON.parse(require('fs').readFileSync('.github/.release-please-manifest.json','utf8')); const cKeys=Object.keys(c.packages).sort(); const mKeys=Object.keys(m).sort(); if (JSON.stringify(cKeys) !== JSON.stringify(mKeys)) throw new Error('config-manifest key drift: config=' + JSON.stringify(cKeys) + ' manifest=' + JSON.stringify(mKeys)); console.log('OK: config-manifest key parity; ' + cKeys.length + ' entries');"` must print `OK: config-manifest key parity; 18 entries`.
  - [ ] **Version-parity smoke:** loop every manifest key against the corresponding `package.json` version (the `.` root has no `version` in `package.json` — current root `package.json` is version-less per Story 1.1 authoring, skip the `.` entry in the per-package check; verify root entry separately just equals `"0.0.0"`). Pseudo-command:
    ```
    node -e "const m=JSON.parse(require('fs').readFileSync('.github/.release-please-manifest.json','utf8')); const errs=[]; for (const [p,v] of Object.entries(m)) { if (p === '.') { if (v !== '0.0.0') errs.push('root expected 0.0.0 got ' + v); continue; } const pkg=JSON.parse(require('fs').readFileSync(p + '/package.json','utf8')); if (pkg.version !== v) errs.push(p + ': manifest=' + v + ' package.json=' + pkg.version); } if (errs.length) throw new Error(errs.join('; ')); console.log('OK: manifest-version parity across ' + Object.keys(m).length + ' entries');"
    ```
  - [ ] **Manifest load smoke:** `cd packages/keel-invariants && node -e "import('./src/manifest-reader.ts').then(m => m.default()).then(r => console.log('OK: ' + r.length + ' invariants'))"` — must print `OK: 20 invariants` (17 pre-Story-1.14 + 3 new). This is the Story 1.8 Task 3 pattern; if the TS manifest file imports via `.ts`-not-yet-resolved, fall back to the Story 1.8 runtime-smoke form: `node -e "import('@keel/keel-invariants').then(m => console.log('OK: ' + m.invariants.length + ' invariants'))"`.
  - [ ] **Sync-gate clean smoke:** from repo root, `pnpm keel-invariants:check` must exit 0 with no drift. This is the Story 1.9 AC 1 clean-path behaviour. If the gate emits drift (e.g. a stale contentHash, a missing anchor, a missing source file), FIX in the same iteration BEFORE commit — iteration budget is a blocker (drift under own PR is a quality-gate violation per NFR27).
  - [ ] **Full quality-gate suite:** `pnpm typecheck && pnpm lint && pnpm format:check && pnpm keel-invariants:check-all`. All must pass. `keel-invariants:check-all` runs the Story 1.9 sync-gate + Story 1.13 token-sync gate in sequence; the three new invariants should register clean at the former; the latter is unaffected (no token-layer change in Story 1.14).
  - [ ] **Record measurements** in § Dev Agent Record → Debug Log: sha256 values computed at Tasks 1/2/3, wall-clock of each smoke test, `pnpm keel-invariants:check` duration (Story 1.9 pinned <2s per AC 7; should hold). If sync-gate exceeds 2s, investigate — likely a regression from the manifest growing to 20 entries, but the Story 1.9 walker is O(n+m) in entries × doc lines so 20 entries stays comfortably under budget.

## Dev Notes

### Carry-forward from Story 1.13 (iter-73 ZERO-PATCH precedent)

Story 1.13 completed a 7-iteration `drafted → done` lifecycle (iter-67 → iter-73) with the fourth cumulative ZERO-PATCH CR outcome. The compound discipline that held is pre-staged here verbatim:

- **Seven preventative audit layers pre-applied at drafting time** (iter-53/54/56/59/60/67 compound — see RALPH.md § Lessons for the framing):
  - **L1 — stable IDs for new enforced invariants.** Three new IDs registered here: `INV-release-please-config`, `INV-release-please-manifest`, `INV-release-please-rationale`. All three match the Zod regex `^INV-[a-z0-9]+(-[a-z0-9]+)+$` at `invariants.manifest.ts:4` (verified at drafting-time by mentally parsing each against the regex). No uppercase; no underscores; at least 2 hyphenated segments each; all lowercase-after `INV-` prefix.
  - **L2 — task-enumeration-vs-consumer-requirement diff.** Every AC has ≥1 Task: AC 1 → Tasks 1, 2, 4, 5 + Task 7 (static shape + parity); AC 2 → Task 1 `bump-minor-pre-major` + Task 7 shape smoke; AC 3 → Task 1 `bump-patch-for-minor-pre-major` + Task 7; AC 4 → Task 1 `changelog-sections` (implicitly `feat!:` major — release-please default behaviour with breaking footer parsing — no explicit config option needed for major-on-breaking; it is intrinsic to conventional-commit bump classification); AC 5 → Task 1 `include-v-in-tag: true` + Task 6 (scope-carve-out: workflow is Story 13.5); AC 6 → Tasks 3, 4, 5. Every Task serves ≥1 AC. Task 6 is an explicit no-op (confirms no script / config cascade) protecting against Story-1.9-iter-4-class hash-cascade regressions.
  - **L3 — sprint-status transition wording.** At drafting-time, this iteration flips `1-14-release-please-monorepo-config-single-bundled-mode: backlog → ready-for-dev` in `_bmad-output/implementation-artifacts/sprint-status.yaml:59` + bumps `last_updated` to `2026-04-21 Story-1-14-drafted UTC` (matches Story 1.13 iter-67 wording pattern).
  - **L4 — internal-consistency drift (design-convergence residuals; iter-68 SM-review enhancement).** Cross-AC check: "single-bundled" appears in AC 1 + AC 6 (scope carve-outs) + Task 1 `separate-pull-requests: false` + Task 1 `linked-versions` plugin — all four sites converge on the same answer. "17 workspace packages" appears in AC 1 + Task 1 count-check + Task 2 17-keys + Task 4 manifest-size-20 claim (17 + 3 new) — all converge. `.github/release-please-config.json` location appears in AC 1 Given + Task 1 + Task 4 `sourcePath` + Task 5 anchor + Story 1.9 sync-gate coverage — all converge; architecture.md § Source-tree line 807 drift is noted in AC 1 scope carve-out (sprint-decomposed AC wins). Decision-architecture residuals (the `.github/` vs repo-root for `release-please-config.json`): pinned to `.github/` at 5 sites (AC 1 Given, Task 1 file path, Task 4 sourcePath, Task 5 anchor-bullet text, Task 7 smoke command paths); the architecture drift is recorded in § Project Structure Notes Variances.
  - **L5 — cross-file line-number staleness + collection cardinality (iter-61 enhancement; grep-count per collection).** Collection counts pinned: 17 workspace packages (1 apps/web + 16 packages/*, verified at drafting-time via the `ls -d` count mental-check: `apps/web, packages/audit, packages/billing, packages/config, packages/contracts, packages/core, packages/create-keel-app, packages/db, packages/devbox, packages/email, packages/flags, packages/jobs, packages/keel-generator, packages/keel-invariants, packages/keel-templates, packages/ui` = 16 packages + `apps/web` = 17 total members → `packages:` map has 18 keys with root `.`); current manifest entry count 17 pre-Story-1.14 (enumerated: 10 from Story 1.8 + 1 from Story 1.10 `INV-tokens-schema-contract` at :128 + 1 from Story 1.10 `INV-tokens-semantic-rationale` at :136 + 1 from Story 1.11 `INV-tokens-source` at :144 + 1 from Story 1.12 `INV-tokens-emitter` at :152 + 3 from Story 1.13 at :160/:168/:176 = 17 total); Story 1.14 grows manifest to 20 entries.
  - **L6 — schema-permission diff.** Files edited by Story 1.14: `.github/release-please-config.json` (NEW), `.github/.release-please-manifest.json` (NEW), `docs/invariants/release.md` (NEW), `packages/keel-invariants/src/invariants.manifest.ts` (ADD 3 entries), `INVARIANTS.md` (ADD 1 section + 3 bullets). Files NOT edited: `package.json` (explicit Task 6 no-op — protects `INV-prek-prepare-lifecycle` hash); `.pre-commit-config.yaml` (no new hook — protects `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` hash); `tokens.json` / schema files / emitter / gates (zero token-layer touch). No cascade hash updates triggered.
  - **L7 — domain-specific carve-out (release-please for Story 1.14).** Release-please-monorepo config shape validation — `packages:` map form pinned in Task 1 (object with per-path keys each having `component` + `package-name`); manifest shape pinned in Task 2 (flat object string→version); `linked-versions` plugin shape pinned in Task 1 (one array element with `type` + `groupName` + `components`); changelog-types customization pinned in Task 1 (9-row `changelog-sections` array mapping conventional-commit types to display sections + hidden flag). pnpm workspace integration: the `packages:` map keys are workspace-member directories (same as `pnpm-workspace.yaml:1-3` glob values `apps/*` + `packages/*`); no extra pnpm integration needed — release-please reads `package.json` at each path.

- **Target ≤2 PATCH pre-dev SM review at iter-75.** Any L1-L7 residual that slips past drafting should land as ≤2 PATCHes at SM review. Story 1.11 iter-54 + Story 1.12 iter-61 + Story 1.13 iter-68 all landed exactly 2 PATCHes; Story 1.14 should match.

- **Target single-pass dev at iter-77.** Story 1.14 is configuration-surface only (2 new JSON files + 1 markdown file + 3 manifest entries + 3 anchor bullets; zero runtime code); single-pass dev-story should hold.

- **Target ZERO-PATCH trace/SM/CR across iter-78..iter-80.** Four consecutive ZERO-PATCH CR cycles (Stories 1.10 iter-52 re-run + 1.11 iter-59 + 1.12 iter-66 + 1.13 iter-73) is the carry-forward; Story 1.14 is configuration-surface + toolchain-wiring which IP forecast placed at 5-8 DEFER at CR (lower complexity surface than the 10-13-DEFER gate-authoring stories).

- **ATDD-skip prelim — hybrid ground-(c) variant-(ii)+(iii) [seventh precedent].** Story 1.14 has NO runtime behaviour at substrate level (the files exist; the workflow that consumes them is Story 13.5; until then the JSON files are drift-detected via Story 1.9 but are not "executed"). (a) substrate-verification-covers-ACs: Task 7 static JSON parse + single-bundled-mode shape + config-manifest key-parity + manifest-version parity + manifest-load smoke + sync-gate clean — covers AC 1 + AC 6 at substrate level; AC 2/3/4/5 all describe downstream Story-13.5 consumer behaviour explicitly carved out of Story 1.14 scope. (b) no test runner at Story 1.14 time — Story 1.16 scope. (c) **HYBRID variant-(ii)+(iii)**: variant (ii) downstream-story-covers-integration — Story 13.5 owns the runtime release-please-action invocation + Release PR lifecycle + tag/release-notes assertion; variant (iii) spec-declared CR-substitution — § Testing Standards below affirmatively declares adversarial coverage to the CR pass (Blind Hunter / Edge Case Hunter / Acceptance Auditor) for the 4 downstream-consumer ACs. Seventh precedent following Stories 1.7/1.8/1.9/1.10/1.11/1.12/1.13.

### Story 1.14 architecture + PRD references

- **PRD FR31** (`_bmad-output/planning-artifacts/prd.md:991`): *"System can maintain a rolling release-please Release PR with conventional-commit-based versioning."* Story 1.14 delivers the config substrate; Story 13.5 delivers the workflow consumer.
- **Architecture § Deferred / Post-1.0 line 1342**: *"release-please-monorepo per-package release mode — deferred; single-bundled release is the N=1 choice."* Pinned verbatim at AC 6 + Task 3.
- **Architecture § Commit / PR / Knowledge-file Patterns line 677-684**: conventional-commit type enum (`feat | fix | docs | chore | refactor | test | build | ci | perf`) + `BREAKING CHANGE:` footer convention — pinned at Task 1 `changelog-sections` (9 entries matching the enum).
- **Architecture § Source-tree lines 791-821**: shows `release-please-config.json` at repo root (line 807) + `release-please-manifest.json` inside `.github/` (line 809 — WITHOUT leading dot). Story 1.14 aligns with Epic 1 Story 1.14 AC 1 Given-clause (both under `.github/`; manifest WITH leading dot per release-please canonical form). Architecture.md drift recorded at AC 1 scope carve-out + § Project Structure Notes Variances.
- **Architecture § Deployment (line 1293)**: *"release-please manages version bumps + changelogs; tag merge triggers GitHub release + optional fork-CD."* + § 1.0 distribution (line 532): *"Distribution: zero npm-publish at 1.0; GitHub release via release-please is the distribution channel."* Pins the zero-npm-publish posture; Task 1 does NOT add any `"publish": true` / npm-registry key.
- **Epic 13 Story 13.5 downstream** (epics.md:5585-5602): `.github/workflows/release-please.yml` is the runtime consumer — out of Story 1.14 scope per AC 5 carve-out.
- **PRD FR44 (Forkability)**: forks extend substrate invariants without editing the substrate (Story 1.16 pattern). For release config, a fork that wants per-package mode (vs single-bundled) edits `release-please-config.json` directly as a source-fork change — documented in Task 3 § Fork extension.

### Invariants manifest integration

- **Story 1.8 canonical shape** (`packages/keel-invariants/src/invariants.manifest.ts:3-15`): each entry has `id` + `description` + `sourcePath` + `contentHash` + `anchors`. Three new entries follow this shape exactly.
- **Story 1.9 sync-gate** (`packages/keel-invariants/src/sync-gate.ts`): walks `INVARIANTS.md` for column-0 `- **\`INV-*\`**` bullets; cross-references with the manifest; emits drift per `added-to-source-only` / `removed-from-source-only` / `added-to-docs-only` / `removed-from-docs-only` / `content-hash-mismatch` classes. Three new manifest entries require three corresponding anchor bullets (Task 5) + three correct contentHash values (Tasks 1/2/3 compute them; Task 4 pins them).
- **Story 1.9 sync-gate performance** (AC 7, pinned <2s): walker is O(n + m) in manifest entries × doc lines. Story 1.14 grows manifest from 17 → 20 entries (+17%) and INVARIANTS.md by ~4 lines (one H3 + three bullets, ~+6% of current ~65 lines). Performance impact: negligible; <2s budget held with comfortable margin.

### Stable-ID convention

Three new IDs match the `^INV-[a-z0-9]+(-[a-z0-9]+)+$` regex at `packages/keel-invariants/src/invariants.manifest.ts:4`:

- `INV-release-please-config` — 4 lowercase-hyphenated segments after `INV-` prefix (release / please / config).
- `INV-release-please-manifest` — 4 segments (release / please / manifest).
- `INV-release-please-rationale` — 4 segments (release / please / rationale).

No uppercase, no underscores, no segment shorter than 1 char. Regex self-verified at drafting-time by mental-parse.

### Stable-IDs do NOT use three-segment TOKEN-style slugs

Per Story 1.10 AC 2 scope carve-out convention: stable IDs are in `packages/keel-invariants/src/invariants.manifest.ts`'s `raw[].id` field (e.g. `INV-release-please-config`), NOT three-segment `TOKEN-<domain>-<slug>` design-token-slot slugs. Story 1.14 adds no design-token slots; the `TOKEN-*` naming convention does not apply here.

### Project Structure Notes

- **New files** (3):
  - `.github/release-please-config.json` (JSON; Task 1).
  - `.github/.release-please-manifest.json` (JSON; Task 2).
  - `docs/invariants/release.md` (markdown; Task 3). Mirrors `docs/invariants/tokens.md` (Story 1.10) + `docs/invariants/ralph-execute.md` (Story 1.9) precedents.
- **Edited files** (2):
  - `packages/keel-invariants/src/invariants.manifest.ts` — add 3 entries at end of `raw` array (Task 4). Preserve entries 1-17 in current order.
  - `INVARIANTS.md` — add 1 new H3 section (`### Release management (Story 1.14)`) between existing `### Design-token quality gates (Story 1.13)` and `## Consumption` (Task 5). 3 column-0 bullets.
- **UN-touched** (explicit no-op confirmed at Task 6 for hash-cascade protection):
  - `package.json` (root) — no new scripts; protects `INV-prek-prepare-lifecycle` hash at `invariants.manifest.ts:97-103`.
  - `.pre-commit-config.yaml` — no new hook; protects `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` hash at `invariants.manifest.ts:89-95` + `:104-110`.
  - `packages/ui/tokens.json` — zero token-layer change; protects `INV-tokens-source` hash.
  - `packages/ui/scripts/generate-tokens.ts` — zero emitter change; protects `INV-tokens-emitter` + `INV-tokens-sync-gate` hash.
  - `tsconfig.base.json`, prettier config, ESLint config, commitlint config — zero shared-config touch; protects `INV-tsconfig-base` + `INV-eslint-shared` + `INV-prettier-shared` + `INV-commitlint-shared` hash.

#### Variances

- **Architecture.md § Source-tree drift (line 807 vs AC 1 Given-clause).** Architecture places `release-please-config.json` at repo root; Epic 1 Story 1.14 AC 1 places it under `.github/`. Story 1.14 aligns with the Epic per the RALPH.md 2026-04-19 lesson on epic-wins-over-architecture ("epics.md AC wins — sprint-decomposed source of truth"). Architecture.md is not amended by Story 1.14 (would be architecture-scope edit outside this story's domain); flag as a pre-1.0 cleanup candidate for the Epic 1 retrospective OR as a Story-1.15/1.16 opportunistic spec amendment alongside other architectural refinements.
- **Manifest entry ordering** (Story 1.8 precedent): new entries appended in AC-order (`config` → `manifest` → `rationale`), NOT inserted mid-array. Story 1.13's 3 new entries appended after `INV-tokens-emitter`; Story 1.14's 3 new entries append after `INV-tokens-sync-gate` (current last entry).

### Testing Standards

**ATDD Skip Rationale (Story 1.14 iter-75; FR14n matrix row 3; hybrid ground-(c) variant-(ii)+(iii); seventh cumulative precedent).**

`/bmad-testarch-atdd` will NOT be invoked for Story 1.14 for three conjoint grounds:

- **(a) substrate-verification-covers-ACs.** Task 7 enumerates 6 smoke tests — static JSON parse (both files), single-bundled-mode shape, config-manifest key-parity, manifest-version parity, manifest-load smoke, sync-gate clean smoke — that exercise AC 1 + AC 6 end-to-end at substrate level. These are inline `node -e "..."` shell commands (matching Story 1.8 iter-3 pattern + Story 1.13 Task 7 pattern); no test runner needed to run them.
- **(b) no test runner at Story 1.14 time.** Story 1.16 scope. No `vitest.config.*` / `jest.config.*` / `playwright.config.*` exists anywhere in the tree; `/bmad-testarch-atdd` Step 1.2 (test-framework preflight) hard-prerequisite would HALT.
- **(c) HYBRID variant-(ii)+(iii) — downstream-story + CR-substitution.** 4 of 6 ACs (AC 2, 3, 4, 5) describe downstream-consumer behaviour that materializes only after Story 13.5's `.github/workflows/release-please.yml` lands. Story 13.5 is the formal integration gate for the Release-PR lifecycle (variant ii). Additionally, Story 1.14's adversarial coverage of AC 1 + AC 6 (config shape integrity, manifest integrity, single-bundled-mode invariance, FR31 bump-mapping correctness, fork-extension pointer validity) is delegated to the `/bmad-code-review (args: "2")` CR pass's three-layer adversarial fan-out (Blind Hunter diff-only + Edge Case Hunter diff + repo-read + Acceptance Auditor AC-verification) per variant (iii) spec-declared-CR-substitution pattern — same as Story 1.9/1.12/1.13. The hybrid is strictly stronger than either variant alone.

**Consistency rule carry-forward to Story 1.14 trace gate (iter-78):** Epic-1-substrate stories with ATDD-skip at iter-N → trace gate at iter-(N+2) emits WAIVED (or analogous partial-coverage verdict) per the Story 1.7/1.8/1.9/1.10/1.11/1.12/1.13 precedent. Story 1.14 will emit WAIVED-with-substrate-evidence (Task 7 smokes are the substrate backstop; adversarial Wave-2 coverage is delegated to CR).

**Quality gates (mandatory — substrate verification):**

- `pnpm typecheck` (Turbo) — must be green. No TS code added by Story 1.14; a regression would be existing-package cross-reference drift.
- `pnpm lint` (ESLint) — must be green. No JS/TS edits trigger new lint rules.
- `pnpm format:check` (Prettier) — must be green post-`prettier --write` on the three new files (Tasks 1/2/3).
- `pnpm keel-invariants:check` — must exit 0 with no drift on the Story 1.14 landing commit. This validates (a) three new entries parse via Zod, (b) three sha256s match the file bytes on disk, (c) three anchors resolve in `INVARIANTS.md`, (d) existing 17 entries remain stable (no regressed hash).
- `pnpm keel-invariants:check-all` — composition of the Story 1.9 sync-gate (`keel-invariants:check`) + Story 1.13 token-sync gate (`keel-invariants:tokens-sync`). Both must exit 0. Story 1.14 does not touch tokens so `tokens-sync` is untouched.

**Adversarial coverage (deferred to CR pass at iter-80):**

- **AC 2 (feat: → minor bump).** Blind Hunter / Edge Case Hunter / Acceptance Auditor examine the `changelog-sections` array + `bump-minor-pre-major: true` config flag + the `feat` → `Features` mapping for drift vs release-please canonical behaviour. No runtime execution possible until Story 13.5.
- **AC 3 (fix: → patch bump).** Same layer set examines `bump-patch-for-minor-pre-major: true` + `fix` → `Bug Fixes` mapping.
- **AC 4 (feat!: / BREAKING CHANGE: → major bump).** Acceptance Auditor verifies commitlint config (`INV-commitlint-shared`) accepts both `feat!: X` AND `BREAKING CHANGE:` footer forms; release-please's bump classifier handles both intrinsically (no config flag needed for major-on-breaking). Flag ANY residual drift between commitlint `breaking` acceptance and release-please `breaking-change-bump` — either a spec clarification (add a "commitlint → release-please parse parity" explanatory bullet under § Commit / PR / Knowledge-file Patterns) or a Task 1 config flag amendment if a non-default release-please setting is needed for BREAKING CHANGE: footer detection.
- **AC 5 (Release PR merge → tag + release notes + fresh Release PR).** Variant (ii) downstream: Story 13.5's integration test (Release-PR merge smoke + tag emission smoke + release-notes body smoke) validates this end-to-end. Story 1.14 only pins `include-v-in-tag: true` in config; the rest is runtime behaviour.
- **AC 6 (single-bundled choice documented with pointer).** Acceptance Auditor verifies `docs/invariants/release.md` literally contains the architecture.md:1342 verbatim string + the architecture-path cite + the commit-type → semver mapping table. Blind Hunter flags any drift in the mapping table vs AC 2/3/4 numeric-bump claims.

### References

- Epic 1 Story 1.14: [Source: _bmad-output/planning-artifacts/epics.md#story-114-release-please-monorepo-config-single-bundled-mode](../planning-artifacts/epics.md) (lines 1047-1080)
- Epic 13 Story 13.5 (downstream consumer): [Source: _bmad-output/planning-artifacts/epics.md#story-135-release-pleaseyml-release-please-prtag-automation](../planning-artifacts/epics.md) (lines 5585-5602)
- PRD FR31 (rolling Release PR + conventional-commit versioning): [Source: _bmad-output/planning-artifacts/prd.md#fr31](../planning-artifacts/prd.md) (line 991)
- Architecture § Deferred line 1342 (single-bundled N=1 choice): [Source: _bmad-output/planning-artifacts/architecture.md#deferred-post-10](../planning-artifacts/architecture.md) (line 1342)
- Architecture § Commit / PR / Knowledge-file Patterns (conventional-commit enum + BREAKING CHANGE: → major): [Source: _bmad-output/planning-artifacts/architecture.md#commit--pr--knowledge-file-patterns](../planning-artifacts/architecture.md) (lines 673-684)
- Architecture § Source-tree (layout of release-please files): [Source: _bmad-output/planning-artifacts/architecture.md#source-tree](../planning-artifacts/architecture.md) (lines 791-821; § Project Structure Notes Variances records the `.github/` vs root drift)
- Architecture § Deployment (release-please manages version bumps + tag → release): [Source: _bmad-output/planning-artifacts/architecture.md#deployment](../planning-artifacts/architecture.md) (line 1293)
- Architecture § 1.0 distribution (zero npm-publish; GitHub release is the channel): [Source: _bmad-output/planning-artifacts/architecture.md#shape-mechanism](../planning-artifacts/architecture.md) (line 532)
- Story 1.8 (manifest contract + `InvariantSchema`): [Source: _bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md](./1-8-invariants-manifest-ts-contract-exporter.md)
- Story 1.9 (sync-gate + walker — consumer of new manifest entries): [Source: _bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md](./1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md)
- Story 1.13 (prior FR14n cycle — ZERO-PATCH precedent): [Source: _bmad-output/implementation-artifacts/1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md](./1-13-token-quality-gates-schema-validation-wcag-aa-contrast-source-output-sync.md)
- Invariants manifest source: [Source: packages/keel-invariants/src/invariants.manifest.ts](../../packages/keel-invariants/src/invariants.manifest.ts)
- Sync-gate regex: [Source: packages/keel-invariants/src/sync-gate.ts](../../packages/keel-invariants/src/sync-gate.ts) (line 24: `ANCHOR_REGEX`)
- INVARIANTS.md (anchor doc): [Source: INVARIANTS.md](../../INVARIANTS.md)
- Release-please canonical config schema: https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json (cited as `$schema` in Task 1 JSON)

## Dev Agent Record

### Agent Model Used

_To be filled by dev-story iteration._

### Debug Log References

_To be filled by dev-story iteration. Capture:_
- _sha256 hashes computed for the 3 new sourcePath files (Tasks 1/2/3)._
- _Task 7 smoke outputs (6 smokes: static JSON parse, single-bundled-mode shape, config-manifest key-parity, manifest-version parity, manifest-load smoke, sync-gate clean smoke)._
- _`pnpm keel-invariants:check` wall-clock duration (expect <2s; AC 7 pinned by Story 1.9)._
- _`pnpm keel-invariants:check-all` composition pass (Story 1.9 sync-gate + Story 1.13 tokens-sync gate)._
- _Any drift flagged by the quality-gate suite (expected: zero)._

### Completion Notes List

_To be filled by dev-story iteration. Should include:_
- _AC 1 (config + manifest shape) — MET / NOT-MET + evidence._
- _AC 2-5 (feat:/fix:/feat!:/merge-tag Release-PR behaviour) — DEFERRED to Story 13.5 per scope carve-out; substrate config pins bump-mapping config flags correctly (verified at Task 7)._
- _AC 6 (rationale docs pointer) — MET / NOT-MET + file-path evidence._
- _Seven preventative audit layers L1-L7 — held / residual at SM review._
- _Task 7 smoke results with wall-clock timings._

### File List

_To be filled by dev-story iteration. Expected:_
- `.github/release-please-config.json` (NEW)
- `.github/.release-please-manifest.json` (NEW)
- `docs/invariants/release.md` (NEW)
- `packages/keel-invariants/src/invariants.manifest.ts` (MODIFIED — 3 entries added)
- `INVARIANTS.md` (MODIFIED — 1 H3 section + 3 bullets added)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (MODIFIED — `1-14-release-please-monorepo-config-single-bundled-mode: ready-for-dev → in-progress` at dev-story start; `→ review` at dev-story end)

## Change Log

| Date       | Version | Description                                                                                                                                                                         | Author |
| ---------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 2026-04-21 | v1.0    | Initial drafting — 6 ACs + 7 Tasks + seven preventative audit layers pre-applied per iter-73 compound-ZERO-PATCH carry-forward; hybrid ground-(c) variant-(ii)+(iii) ATDD-skip set. | Ralph  |
