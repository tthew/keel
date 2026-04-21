# Release management — release-please single-bundled monorepo (Story 1.14)

**Scope:** every Keel-forked repo releasing via conventional-commit-driven semver bumps.
**Status:** normative. Fork-override path: replace single-bundled with per-package mode as a source-fork change (see § Fork extension).
**Machine-enforced in:** `.github/release-please-config.json` (`INV-release-please-config`, Story 1.8 + 1.9) · `.github/.release-please-manifest.json` (`INV-release-please-manifest`) · this file (`INV-release-please-rationale`).
**Runtime consumer:** `.github/workflows/release-please.yml` (Story 13.5, Epic 13 — future).

## Overview

- **`INV-release-please-rationale`**: Single-bundled release-please-monorepo choice rationale + bump mapping + fork-extension pointer.

PRD FR31 requires a rolling `release-please` Release PR that auto-accumulates a changelog and semver bumps from conventional-commit messages on `main`. Story 1.14 authors the two config files (`.github/release-please-config.json` + `.github/.release-please-manifest.json`) that encode the release discipline. Story 13.5 lands the GitHub Actions workflow that invokes `googleapis/release-please-action` against those files on every push to `main`. Until Story 13.5 ships, the config files exist as substrate (drift-detected by the Story 1.9 sync-gate) but produce no Release PRs.

Bump mapping follows conventional-commit semantics: `feat: X` → minor, `fix: Y` → patch, `feat!: Z` or `BREAKING CHANGE: <reason>` footer → major. At pre-1.0 (every workspace currently sits at `0.0.0`) the `bump-minor-pre-major` + `bump-patch-for-minor-pre-major` config flags pin `feat:` to minor and `fix:` to patch rather than release-please's default pre-1.0 patch collapse.

## Single-bundled choice

Release-please supports two shapes for a monorepo: **single-bundled** (one release group across every package; one Release PR tracks every workspace member; all members bump in lockstep) and **per-package** (one release group per package; one Release PR per package; members bump independently). Story 1.14 pins single-bundled.

The choice is anchored verbatim in architecture.md § Deferred / Post-1.0 line 1342:

> **release-please-monorepo per-package release mode** — deferred; single-bundled release is the N=1 choice.

**Trade-off.** Single-bundled simplifies the 1.0 cut ritual (one tag, one Release PR, one changelog section) and keeps the 17-path version state (1 root `.` + 16 workspace members) atomic. Cross-package drift is impossible because every package carries the same version. Per-package mode offers finer-grained independence (a fix to `@keel/audit` does not bump `@keel/web`) but adds 17× Release-PR overhead and introduces the cross-package version-skew failure mode — untenable at the 1-human scale Keel targets at 1.0.

Per-package mode can be revisited at Growth-tier if a package is extracted (see architecture.md:597 on package-extraction posture); a fork that wants per-package release today edits `release-please-config.json` as a source-fork change (see § Fork extension).

## Files

- **`.github/release-please-config.json`** (`INV-release-please-config`) — the release-please config. Pins `release-type: node`, `bump-minor-pre-major: true`, `bump-patch-for-minor-pre-major: true`, `include-v-in-tag: true`, `separate-pull-requests: false`, a `linked-versions` plugin grouping every workspace member under `groupName: keel`, a `changelog-sections` array mapping 9 conventional-commit types to display sections (4 visible + 5 hidden), and a `packages` map listing the root `.` component plus every `apps/web` + `packages/*` path.
- **`.github/.release-please-manifest.json`** (`INV-release-please-manifest`) — the state-of-record manifest. Maps every releasable path (`.` root + 16 workspace members = 17 entries) to its current semver. Release-please updates this file atomically on Release-PR merge; every entry bumps in lockstep per the linked-versions plugin. Initial state: all 17 entries at `0.0.0` matching every workspace member's current `package.json:version`.
- **`docs/invariants/release.md`** (`INV-release-please-rationale`) — this file. Companion to `INV-release-please-config` (mirrors the `INV-tokens-semantic-rationale` ↔ `INV-tokens-schema-contract` pattern from Story 1.10). Explains the single-bundled choice + commit-type → semver mapping + fork-extension guidance.

## Commit-type → semver mapping

| Commit form                                              | Pre-1.0 bump                              | Post-1.0 bump     | Changelog section                       |
| -------------------------------------------------------- | ----------------------------------------- | ----------------- | --------------------------------------- |
| `feat: X`                                                | minor (`0.0.0 → 0.1.0`)                   | minor (`N.x.y → N.(x+1).0`) | `### Features`                          |
| `fix: Y`                                                 | patch (`0.0.0 → 0.0.1`)                   | patch (`N.x.y → N.x.(y+1)`) | `### Bug Fixes`                         |
| `feat!: Z` or `<type>: <desc>` with `BREAKING CHANGE:` footer | major (`0.x.y → 1.0.0`)               | major (`N.x.y → (N+1).0.0`) | `### ⚠ BREAKING CHANGES`                |
| `perf:`, `refactor:`, `docs:`                            | patch (per `changelog-sections` visible)  | patch             | `### Performance Improvements` / `### Code Refactoring` / `### Documentation` |
| `chore:`, `test:`, `build:`, `ci:`                       | no user-visible bump (hidden in changelog) | same              | hidden                                  |

Pre-1.0 `feat:` → minor (not patch) is driven by `bump-minor-pre-major: true`; pre-1.0 `fix:` → patch is driven by `bump-patch-for-minor-pre-major: true`. At the 1.0 cut Tthew either commits with a `BREAKING CHANGE:` footer (triggers the `0.x.y → 1.0.0` transition) or sets `release-as: "1.0.0"` in the config once; the config does not pre-pin the 1.0 cut (it is a manual ritual per FR31).

Commitlint (`INV-commitlint-shared`) accepts both the `!` shorthand and the `BREAKING CHANGE:` footer form; release-please's bump classifier handles both intrinsically (no extra config flag needed for major-on-breaking — it is part of conventional-commit parsing).

## Fork extension

Forks extend release discipline the same way they extend any substrate file (FR44): by editing `.github/release-please-config.json` in the fork's branch and letting the Story 1.9 sync-gate re-hash the file at pre-merge. A fork that wants per-package release mode (instead of single-bundled) edits the config file to re-author the `plugins` block — drop the `linked-versions` entry, split the `packages` map into per-component groupings, and re-tune `separate-pull-requests: true` — which is a source-fork-level change (the new shape produces per-package Release PRs going forward). The manifest file's shape is unchanged (per-path version keys still); release-please handles both modes against the same manifest format.

## Consumption

The `.github/workflows/release-please.yml` workflow in Story 13.5 (Epic 13) invokes `googleapis/release-please-action` on every push to `main`, pointing at `.github/release-please-config.json` + `.github/.release-please-manifest.json` via explicit `config-file` + `manifest-file` workflow inputs (overriding the action's default repo-root paths). The workflow authors the rolling Release PR, updates the manifest on Release-PR merge, tags `main` with `v<semver>`, and publishes GitHub Release notes copying the changelog section. Story 1.14's substrate is inert until that workflow lands.
