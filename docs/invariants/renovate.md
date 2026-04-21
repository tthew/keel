# Dependency upgrade discipline — Renovate I7 version pinning (Story 1.15)

**Scope:** every Keel-forked repo authoring a Renovate config for dependency upgrades.
**Status:** normative. Fork-override path: edit `.github/renovate.json` as a source-fork change (see § Fork extension).
**Machine-enforced in:** `.github/renovate.json` (`INV-deps-version-pinning`, Story 1.8 + 1.9) · this file (`INV-renovate-rationale`).
**Runtime consumer:** Renovate GitHub App (Mend-hosted; one-time repo-admin install) + Epic 13 integration-test-passing CI gate + GH branch-protection status-check requirement (Story 13.x — future).

## Overview

PRD § I7 pins a version-pinning posture across three concrete surfaces: Vitest pinned exact (test runner reproducibility), `@opentelemetry/sdk-node` + `@opentelemetry/api` + every instrumentation pinned exact in `pnpm.overrides` (observability SDK API stability), and the `ghcr.io/fboulnois/pg_uuidv7` Postgres image tag pinned (devbox container reproducibility). Story 1.15 encodes the corresponding policy in `.github/renovate.json`: four `packageRules` entries, each carrying `rangeStrategy: pin` + a per-ecosystem `groupName` + explicit `automerge: false`. Top-level `automerge: false` forbids Renovate auto-merge at 1.0 until Epic 13 lands the integration-test-passing CI gate + GH branch-protection status-check requirement; substrate ships the policy side of the gate, Epic 13 ships the runtime side.

Renovate executes against a repo only once the Renovate GitHub App (Mend-hosted) is installed with repo access — a one-time repo-admin action (Tthew's manual operation) carved out of Story 1.15 scope. Until the App is installed, the config is inert substrate drift-detected by the Story 1.9 sync-gate but never observed by the Renovate runtime. `pnpm.overrides` content is authored by whichever downstream story first installs a pinned dependency (Vitest, OTEL, Radix, or pg_uuidv7); Story 1.15 does not pre-author an empty `pnpm.overrides` block.

- **`INV-renovate-rationale`**: I7 version-pinning posture + per-package rules + fork-extension guidance.

## I7 posture

The I7 pinning decision is anchored verbatim in architecture.md § I7 line 342 (three-agent-convergence outcome — Winston + Sally + Mary converged on the same pinning answer):

> Vitest exact minor + OTEL exact in `pnpm.overrides` + `pg_uuidv7` image tag; integration-test-passing-required-before-merge for pinned deps; Renovate configuration at `.github/renovate.json` with grouped-update rules (all OTEL in one PR, all Vitest in one PR, all `@radix-ui/*` in one PR).

Architecture.md line 305 (§ Party-Mode-driven Implementation Invariants) indexes I7 with the same text. PRD § I7 derives the policy from reproducibility-serves-research-output-richness: irreproducible substrate produces a corrupted research corpus, so every surface that a test harness exercises must be bit-stable across rebuilds. Architecture.md line 649 (§ Repository layout / Dev-time tooling) names `.github/renovate.json` as the authoritative location; architecture.md line 810 (§ Source-tree) agrees. Story 1.15 is the 1.0 substrate delivery of that commitment; Epic 13 lands the CI side.

## Files

- **`.github/renovate.json`** (`INV-deps-version-pinning`) — the Renovate config. Extends `config:recommended`, declares `$schema: https://docs.renovatebot.com/renovate-schema.json`, pins `automerge: false` at top level, and ships four `packageRules` entries (one per ecosystem: Vitest / OpenTelemetry / Radix UI / pg_uuidv7). Each entry carries `rangeStrategy: pin` + a distinct `groupName` + redundant `automerge: false` (defense-in-depth). Lock-file maintenance runs monthly (`lockFileMaintenance.enabled: true`) without auto-merge.
- **`docs/invariants/renovate.md`** (`INV-renovate-rationale`) — this file. Companion to `INV-deps-version-pinning` (mirrors the `INV-tokens-semantic-rationale` ↔ `INV-tokens-schema-contract` pattern from Story 1.10 and the `INV-release-please-rationale` ↔ `INV-release-please-config` pattern from Story 1.14). Explains the I7 posture, the per-package rules, the grouping rationale, and the fork-extension path.

## Per-package pinning rules

| Ecosystem      | `matchPackagePatterns` / `matchPackageNames`                                  | `groupName`     | `rangeStrategy` | `automerge` | Architecture anchor                                                                                                                     |
| -------------- | ----------------------------------------------------------------------------- | --------------- | --------------- | ----------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Vitest         | `matchPackageNames: ["vitest"]` + `matchPackagePatterns: ["^vitest($\|/)", "^@vitest/"]` | `vitest`        | `pin`           | `false`     | architecture.md § I7 (Vitest exact minor for test-runner reproducibility; Epic 13 integration-test gate consumes).                      |
| OpenTelemetry  | `matchPackagePatterns: ["^@opentelemetry/"]`                                  | `opentelemetry` | `pin`           | `false`     | architecture.md § I7 (OTEL SDK API stability — `@opentelemetry/sdk-node` + `@opentelemetry/api` + every instrumentation in one PR).     |
| Radix UI       | `matchPackagePatterns: ["^@radix-ui/"]`                                       | `radix-ui`      | `pin`           | `false`     | epics.md:3984 Story 7.2 AC (`@radix-ui/*` deps pinned — Story 1.15 renovate covers); architecture.md § F1 Component library (line 240). |
| pg_uuidv7      | `matchDatasources: ["docker"]` + `matchPackageNames: ["ghcr.io/fboulnois/pg_uuidv7"]` | `pg-uuidv7`     | `pin`           | `false`     | Story 2.1 devbox docker-compose consumer; architecture.md § I7 (image tag pin for devbox reproducibility).                               |

## Grouping rationale

Ecosystem-grouping (`groupName` per family) bundles related-package upgrades into one Renovate PR rather than 20 separate PRs. For OpenTelemetry in particular, the SDK + API + instrumentations are co-versioned by upstream (the JS SDK ships every package under a single semver); splitting them across PRs introduces cross-PR drift and makes the integration-test gate non-deterministic. Vitest + `@vitest/*` follow the same co-versioning discipline. `@radix-ui/*` primitives version independently per component but share a shadcn/ui vendoring posture; grouping them collapses vendored-primitive churn into one predictable PR cadence.

`automerge: false` at 1.0 is a policy-not-a-limit: the Renovate App respects per-PR status-check requirements via `platformAutomerge`, so even if a fork flips `automerge: true` on a group, GitHub branch protection holds the merge until the required integration-test CI check passes. The belt-and-suspenders per-group `automerge: false` + top-level `automerge: false` ensures substrate cannot land an auto-merging PR accidentally via a per-rule override omission.

## Fork extension

Forks extend the Renovate pinning policy the same way they extend any substrate config file (FR44): by editing `.github/renovate.json` in the fork's branch. A fork that wants a different pin set (e.g. pin `react` + `@tanstack/start` in addition to the four ecosystems here) adds a new `packageRules` entry with its own `groupName` + `rangeStrategy: pin`; a fork that wants per-group auto-merge at 1.0 flips that entry's `automerge: false` to `automerge: true` (and must then install the branch-protection status-check requirement separately — Renovate honors the config but the CI side of the gate is not substrate-level).

This is the same source-fork-level change pattern Story 1.14's release-please-rationale documents — the per-fork edit updates the manifest hash on the fork's next PR; the Story 1.9 sync-gate then re-pins the new file-byte state on the fork's landing.

## Consumption

The Renovate GitHub App (Mend-hosted) is the runtime consumer: on install, it reads `.github/renovate.json` from the default branch and proposes PRs per the configured `packageRules` on its scheduled cadence (here, `before 9am on monday` in `Europe/Berlin`). The integration-test-passing CI gate that substrate pins as `automerge: false`-gated lands in Epic 13 (the CI workflow + the GH branch-protection status-check requirement). Story 2.1's devbox docker-compose is the runtime consumer of the `pg_uuidv7` image tag pin; whichever story first installs OTEL / Vitest / `@radix-ui/*` authors the corresponding `pnpm.overrides` entries (Story 1.15 pre-authors none — the policy applies to the dependency graph whenever those packages appear, regardless of whether they exist at Story 1.15 landing time).

Until both (a) Tthew installs the Renovate App against the repo and (b) Epic 13 lands the CI gate + branch-protection requirement, `.github/renovate.json` is inert substrate — present, drift-detected, and awaiting runtime.
