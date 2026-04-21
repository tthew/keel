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
