# Fork extension — eslint.config.fork.js + INVARIANTS.fork.md scaffold (Story 1.16)

**Scope:** every Keel-forked repo extending substrate rules with fork-specific additions.
**Status:** normative. Fork-override path: edit `packages/keel-invariants/` in a source-fork PR (see § Amendment-vs-fork decision tree) or layer fork-specific rules via `eslint.config.fork.js` + optional `INVARIANTS.fork.md`.
**Machine-enforced in:** `packages/keel-invariants/templates/INVARIANTS.fork.md` (`INV-fork-invariants-scaffold`, Story 1.8 + 1.9) · this file (`INV-fork-extension-rationale`).
**Runtime consumer:** each fork's ESLint runtime (`pnpm lint` resolving `eslint.config.fork.js`) + each fork's agent-reading discipline (`INVARIANTS.fork.md` alongside upstream `INVARIANTS.md`) + Epic 15a's future `create-keel-app --include-fork-invariants` flag.

## Overview

FR44 pins the 1.0 fork-extension contract at the ESLint layer: forks that want to add lint rules on top of substrate author `eslint.config.fork.js` at the fork root and import `@keel/keel-invariants/eslint` via the subpath export declared at `packages/keel-invariants/package.json:14`. FR45 pins the 1.0 Growth-tier scaffold template: forks that want a fork-specific invariants surface copy `packages/keel-invariants/templates/INVARIANTS.fork.md` to their fork root and populate it with `FORK-<fork-slug>-<category>-<slug>` entries. Both surfaces ship `automerge false` for their ops path — the runtime wiring (a fork actually creating `eslint.config.fork.js`, a fork actually copying the scaffold) is the fork operator's opt-in action, not a substrate default. Story 1.16 canonicalizes (a) the ESLint-extend pattern, (b) the Growth-tier scaffold template, (c) the substrate-wins precedence convention, and (d) the amendment-vs-fork decision tree across `AGENTS.md` + `docs/invariants/fork.md` + the Story-1.8 manifest — everything a fork operator needs to extend substrate without fragmenting substrate discipline.

ESLint flat-config precedence is ARRAY-ORDER-based: the exported `eslint.config.*.js` array is evaluated in order and later entries override earlier entries at the same file glob. Substrate-wins is therefore an OPERATIONAL CONVENTION, not a semantic guarantee — forks that want substrate-wins spread `@keel/keel-invariants/eslint` AT THE END of their `eslint.config.fork.js` export array; forks that want fork-wins spread substrate FIRST. At 1.0 the default posture is substrate-wins; forks choosing otherwise should document the reversal in a comment alongside the flip.

- **`INV-fork-extension-rationale`**: FR44 ESLint-extend pattern + FR45 Growth-tier INVARIANTS.fork.md scaffold + substrate-wins precedence + amendment-vs-fork decision tree.

## ESLint-extend pattern (FR44)

`packages/keel-invariants/package.json:14` declares `"./eslint": "./eslint.config.keel-invariants.js"`. Fork operators extend the substrate ESLint baseline by importing that subpath into a fork-root `eslint.config.fork.js`:

```js
import sharedConfig from '@keel/keel-invariants/eslint';

export default [
  // fork-specific rules first (overridden by substrate at same glob)
  {
    rules: {
      // your fork-specific rules here
    },
  },
  // substrate LAST (substrate-wins convention per docs/invariants/fork.md § Precedence)
  ...sharedConfig,
];
```

Spread-at-end = substrate wins at every file glob the substrate config targets (because ESLint's flat-config array evaluates in order and later entries override earlier entries). Spread-at-start reverses the posture (fork rules layered over substrate rules at the same glob — fork wins). At 1.0 the default is substrate-wins; forks choosing fork-wins should add a comment in `eslint.config.fork.js` explaining why and which fork-specific rules motivate the reversal.

The runtime behaviour (a fork actually running `pnpm lint` and seeing both shared + fork rules apply) is DOWNSTREAM of Story 1.16 — substrate ships the DOCUMENTATION + SUBPATH EXPORT, each fork ships the `eslint.config.fork.js` file when it opts in. The subpath export itself was authored in Story 1.2 and is not modified by Story 1.16.

## INVARIANTS.fork.md scaffold (FR45 Growth-tier)

Story 1.16 ships `packages/keel-invariants/templates/INVARIANTS.fork.md` as the canonical Growth-tier scaffold template. Fork operators opt into the Growth-tier surface by:

1. Copying `packages/keel-invariants/templates/INVARIANTS.fork.md` to the fork root: `cp packages/keel-invariants/templates/INVARIANTS.fork.md ./INVARIANTS.fork.md` (manual at 1.0; Epic 15a's `create-keel-app --include-fork-invariants` flag automates the copy when that package lands per AC 4 — default `false` at 1.0).
2. Editing the copied `INVARIANTS.fork.md` to add `FORK-<fork-slug>-<category>-<slug>` entries (≥ 2 hyphen-separated segments after the `FORK-<slug>-` prefix; all lowercase; no underscores — mirrors the upstream `INV-<category>-<slug>` naming convention at `packages/keel-invariants/src/invariants.manifest.ts:4`).
3. Updating the fork's `CLAUDE.md` to reference both upstream `INVARIANTS.md` AND new `INVARIANTS.fork.md` (the knowledge-file contract table in upstream `CLAUDE.md` already lists `INVARIANTS.fork.md` as the 5th row per Story 1.16 Task 6).
4. Optionally authoring a fork-specific manifest (analogous to `packages/keel-invariants/src/invariants.manifest.ts`) if the fork needs hash-pinning + drift-detection for its own invariants; substrate does NOT provide this scaffolding — it is the fork's choice whether to machine-enforce fork invariants or document-only them.

The template ships with H1 + § Precedence + § Fork invariants index + § Consumption + § Extension sections + a commented `FORK-<fork-slug>-<category>-<slug>` naming example. Forks MUST NOT delete the § Precedence section (that is where substrate-wins is pinned for fork readers); forks MAY expand the § Fork invariants index with per-category H3 subsections.

## Precedence

1. **Substrate rules** (upstream `INVARIANTS.md`; pinned by `packages/keel-invariants/src/invariants.manifest.ts`) are AUTHORITATIVE. Every rule registered in the substrate manifest is drift-detected at pre-merge by the Story 1.9 sync-gate (FR43); forks cannot remove or override substrate rules via `eslint.config.fork.js` or `INVARIANTS.fork.md`.
2. **Fork rules** (`eslint.config.fork.js` + `INVARIANTS.fork.md`) ADD TO substrate rules. The substrate-wins convention means that at any file glob where substrate and fork define the same rule, substrate's value applies (via the spread-at-end ESLint convention + by-design in the document layer — upstream `INVARIANTS.md` is authoritative for any rule-ID registered there).
3. **Conflict resolution:** if a fork rule genuinely conflicts with a substrate rule, the fork operator has two paths — (a) open a substrate amendment PR (see § Amendment-vs-fork decision tree) to update substrate so all forks benefit, or (b) narrow the fork rule's scope (e.g. apply only to a fork-specific file glob that substrate does not target).

## Amendment-vs-fork decision tree

When a fork disagrees with substrate, three exit paths exist:

**(a) FORK — fork-specific need.** Author `eslint.config.fork.js` at the fork root (per § ESLint-extend pattern) and optionally `INVARIANTS.fork.md` (per § INVARIANTS.fork.md scaffold). Use this path when the rule applies ONLY to your fork's domain (e.g. an EU-residency region-lock, a b2b-only tenancy middleware rule, a fork-specific Zustand posture). Example: an acme fork with EU-only residency adds `FORK-acme-tenancy-region-lock` targeting `packages/contracts/middleware/region-lock.ts`.

**(b) AMEND — substrate-wide need.** Open a PR against upstream `packages/keel-invariants/` + upstream `INVARIANTS.md` + upstream `invariants.manifest.ts` + upstream anchor bullet — the Story 1.6 + 1.9 source-level fork path (FR32). Use this path when the rule would apply to every fork (e.g. a new ESLint rule forbidding a class of insecure patterns, a new lint rule enforcing a newly-agreed convention). The upstream review gate ensures every fork picks up the amendment on its next upstream pull.

**(c) DEFER — premature need.** Log the rule in `_bmad-output/implementation-artifacts/deferred-work.md` under a section describing the fork operator's context and the rule's intended scope. Use this path when the need is speculative (no concrete source file to enforce yet), cross-cutting (fork-specific but also partially substrate-applicable), or blocked on downstream (Epic N landing a runtime that the rule would target). A DEFER entry is actionable future work — it is not a veto.

## Growth-tier opt-in

At 1.0, Epic 15a's `create-keel-app` CLI does NOT auto-copy `INVARIANTS.fork.md` to fork roots per AC 4 — the `--include-fork-invariants` flag defaults to `false`. Forks that want the Growth-tier scaffold today use the manual `cp` path documented in § INVARIANTS.fork.md scaffold above; Epic 15a (when it lands) ships the flag so fork operators can opt in at bootstrap time rather than post-hoc. The substrate deliverable at 1.0 is the TEMPLATE FILE + this documentation; Epic 15a owns the CLI wiring.

## Files

- **`packages/keel-invariants/templates/INVARIANTS.fork.md`** (`INV-fork-invariants-scaffold`) — the canonical Growth-tier scaffold template. H1 + § Precedence + § Fork invariants index + § Consumption + § Extension sections + a commented `FORK-<fork-slug>-<category>-<slug>` naming example. Inert substrate until a fork operator copies it to their fork root. Hash-pinned + drift-detected via the Story 1.8 manifest + Story 1.9 sync-gate.
- **`docs/invariants/fork.md`** (`INV-fork-extension-rationale`) — this file. Companion to `INV-fork-invariants-scaffold` (mirrors the `INV-tokens-semantic-rationale` ↔ `INV-tokens-schema-contract` pattern from Story 1.10, the `INV-release-please-rationale` ↔ `INV-release-please-config` pattern from Story 1.14, and the `INV-renovate-rationale` ↔ `INV-deps-version-pinning` pattern from Story 1.15). Explains the FR44 ESLint-extend pattern, the FR45 Growth-tier scaffold opt-in flow, the substrate-wins precedence convention, and the amendment-vs-fork decision tree.
- **`AGENTS.md § Fork extension (FR44)`** — agent-facing operational summary of the ESLint-extend pattern + precedence rule + amendment-vs-fork decision tree. Knowledge-file pointer, not a hash-pinned invariant source (agent operational guide, not substrate rule).
- **`CLAUDE.md § Knowledge-file contract` (5th row)** — references `INVARIANTS.fork.md` alongside upstream `INVARIANTS.md` with a short precedence note. Knowledge-file pointer, not a hash-pinned invariant source.

## Fork extension

Forks that want to change the fork-extension pattern itself (e.g. a fork-of-a-fork nesting pattern, or a new `eslint.config.double-fork.js` layering scheme) edit substrate files as a source-fork change per Story 1.6 + 1.9 — upstream `packages/keel-invariants/package.json` subpath exports + upstream `docs/invariants/fork.md` + upstream `AGENTS.md § Fork extension (FR44)` + upstream manifest entry + upstream anchor bullet. This is meta-recursive (the fork-extension pattern is itself an invariant that forks might want to extend) but the path is the same source-level fork path Stories 1.14 + 1.15 + 1.10 + 1.6 + 1.9 all document — the per-fork edit updates the manifest hash on the fork's next PR; the Story 1.9 sync-gate then re-pins the new file-byte state on the fork's landing.

## Consumption

- **Agents (Claude Code, Codex, etc.)** read `AGENTS.md § Fork extension (FR44)` as the primary operational summary and this file as the normative rationale when deeper detail is needed.
- **Fork operators** reach for the `eslint.config.fork.js` copy-pattern via `AGENTS.md § Fork extension (FR44)` and for the `INVARIANTS.fork.md` copy-pattern via § INVARIANTS.fork.md scaffold above.
- **Epic 15a's future `create-keel-app --include-fork-invariants` flag** is the downstream runtime consumer that automates the manual template copy. At 1.0 the flag does NOT exist (the CLI itself is Epic 15a scope); when Epic 15a lands its regression tests MUST assert the flag defaults to `false` per AC 4.

Until both (a) a fork operator opts into the ESLint-extend pattern by authoring `eslint.config.fork.js` and/or (b) a fork operator opts into the Growth-tier scaffold by copying `INVARIANTS.fork.md` to their fork root, the substrate surfaces shipped by Story 1.16 are inert — present, hash-pinned, drift-detected, and awaiting runtime consumption.
