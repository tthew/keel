# Implementation Plan

## NOW

- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md")` — implement Tasks 1–3 (atdd-scaffolded → in-dev) ~large

## QUEUE (Story 1.8 — invariants-manifest-ts-contract-exporter)

- [ ] Run `/bmad-testarch-trace (args: "yolo")` — coverage gate (in-dev → traced); expect WAIVED per Story 1.7 iter-5 precedent (no test runner; Zod parse IS the runtime check)
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (traced → sm-verified)
- [ ] Run `/bmad-code-review (args: "2")` — quality gate (sm-verified → done)
- [ ] After Story 1.8 done: `/bmad-create-story` for Story 1.9 (`invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`)

## BLOCKED

_(none)_

## DONE (Story 1.8 — spec authoring + pre-dev SM review + ATDD skip)

- [x] Ralph-hosted `/bmad-create-story` — Story 1.8 spec authored at `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`; 3-task decomposition (Task 1 `invariants.manifest.ts` contract + 9-entry data + architecture.md:922 dot-form normalisation; Task 2 zod dep + import-time validation; Task 3 quality gates + sprint-status bump). Sprint-status bumped `1-8: backlog → ready-for-dev` with `last_updated: 2026-04-20 Story-1-8-spec UTC`. Story State: `(no story) → drafted`.
- [x] Pre-dev SM review (iter-2; `drafted → validated` per FR14n matrix row 2). Inline checklist.md audit against spec file. **Audit trail (9 checks):** (1) 9/9 INV-\* IDs match `INVARIANTS.md` entries verbatim; (2) 7/7 distinct `sourcePath` files exist on disk; (3) 9/9 `contentHash` values byte-match freshly-computed `sha256sum` (shared-source cases `eslint.config.keel-invariants.js`=10ac60… + `.pre-commit-config.yaml`=0e8e35… correctly produce identical hashes across sibling invariants — by-design cross-cutting detection); (4) ACs 1–4 well-formed BDD shape with Given/When/Then; (5) scope carve-outs double-anchored (AC 2 + AC 3 inline + § Project Structure Notes § Scope Carve-Out + § ContentHash anchor-bounding) per iter-1 carry-forward rule; (6) Zod pin posture aligns with I7; (7) Provisional-ID header discharge noted in § Project Structure Notes; (8) quality-gate bundle enumerated verbatim from Stories 1.4/1.5/1.6/1.7 precedent; (9) Testing Standards rationale present. **One critical finding applied:** spec Task 1's last subtask claimed architecture.md:922 hyphen→dot normalisation as a Dev action, but iter-1's spec-authoring commit (`8991214`) already co-landed the edit; current line is `architecture.md:942` dot-form. Fix applied in three spec locations: (a) Task 1 subtask marked `[x]` with discharge note + commit reference; (b) Dev Notes `[Source: architecture.md:922 (post-normalisation)]` → `:942`; (c) Source tree components `EDIT architecture.md:922` line removed; (d) Change Log v1.1 row added. Story file Status remains `ready-for-dev` (BMad-native); FR14n Story State advances via IP. Story State: `drafted → validated`.
- [x] FR14n ATDD-skip applied (iter-3; `validated → atdd-scaffolded` via matrix row 3 skip clause). Rationale pinned in § ATDD Skip Rationale below. Second application of the skip clause (after Story 1.7 iter-4 precedent); differs from Story 1.7 (docs-only / no runtime behaviour) in that Story 1.8 has runtime behaviour (Zod parse at import time) — but that behaviour is covered end-to-end by Task 3's `node -e "import('@keel/keel-invariants')…"` substrate smoke check + Zod's own upstream test suite, and no test runner is wired at substrate level yet (Story 1.16 scope). Story State: `validated → atdd-scaffolded`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.7 done; 1.8 in flight)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter`
- **Story:** 1.8 — invariants-manifest-ts-contract-exporter (PRD FR42; consumed by Story 1.9 sync-gate per FR43)
- **Story File:** `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`
- **Story State:** atdd-scaffolded
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16)

## ATDD Skip Rationale (Story 1.8 iter-3; FR14n matrix row 3)

Per the Story-Lifecycle Decision Matrix, `validated → in-dev` skip is permitted when a story has no testable ACs requiring red-phase probing (record rationale in IP). Story 1.8 invokes the clause on the following grounds:

1. **AC 4 runtime validation is covered end-to-end by Task 3's substrate smoke.** AC 4 specifies "manifest loads synchronously (no async I/O) and validates against its own Zod (or equivalent) schema at import time" — this behaviour is realised by the inline `InvariantsSchema.parse(raw)` call at the bottom of `invariants.manifest.ts`, and is exercised end-to-end by Task 3's runtime smoke: `node --input-type=module -e "import('@keel/keel-invariants').then(m => { if (m.invariants.length !== 9) throw new Error('expected 9 invariants, got ' + m.invariants.length); console.log('OK:', m.invariants.length, 'invariants'); })"`. A bad entry (malformed `id`, empty `anchors`, bad `contentHash` length) throws `ZodError` → the import rejects → the node script exits non-zero. A separate ATDD red-phase scaffold asserting the same behaviour would be a duplicate probe.

2. **No test runner is wired at substrate level yet (Story 1.16 scope).** A red-phase Vitest/Jest file asserting Zod-schema rejection of malformed entries cannot execute — there is nowhere to run it. Authoring a scaffold to stash in `_bmad-output/test-artifacts/` without an execution target is dead weight (reference Story 1.7 iter-4 for the same reasoning applied to docs-only ACs). Story 1.16 delivers the test-runner substrate + CI pipeline; integration-level ATDD for the manifest belongs in Story 1.9 (sync-gate), which will exercise the manifest end-to-end (anchor-walk vs INVARIANTS.md; file-read vs `contentHash` re-computation).

3. **The Zod schema IS the validator; schema correctness is Zod's own test suite's responsibility.** `InvariantSchema` uses composable Zod primitives (`z.string().regex(...)`, `z.array(...).min(1)`, `z.object({...})`). Red-phase probes for "bad-id format / empty-anchors / bad-hash-length" would re-test Zod's ~1000+ upstream unit tests (covering `string.regex`, `array.min`, `object.strict`, etc.) without adding substrate-level coverage. The substrate's contribution is the **shape declaration + hand-authored data**, both of which are lint-validated at `pnpm -w typecheck` (shape) and Zod-validated at module import (data).

4. **Follows Story 1.7 FR14n skip precedent (line 115 RALPH.md).** Story 1.7 established: the skip is legitimate iff the story's own § Testing Standards explicitly declares the no-runtime stance. Story 1.8's § Testing Standards (line 179 of the spec file) declares: "No dedicated unit-test file for `invariants.manifest.ts` in Story 1.8 scope. Rationale: (a) the Zod schema IS the test … (b) no test runner is wired at substrate level yet (Story 1.16 scope); (c) … Zod's own test suite covers [shape]. Story 1.9's sync-gate tests will exercise the manifest end-to-end." Pre-dev SM review (iter-2) implicitly accepted the § Testing Standards as-is (no flag on ATDD status).

**State transition:** per matrix, skip → `atdd-scaffolded` (state label captures "ATDD step discharged; ready for dev-story"). Next iteration invokes `/bmad-dev-story` per matrix row 4 (`atdd-scaffolded → in-dev`).

**Precedent extension:** Story 1.7 applied skip on docs-only / no-runtime-behaviour grounds. Story 1.8 extends the clause to "runtime behaviour present BUT (a) substrate has no test runner AND (b) the runtime check is already embedded in a substrate-verification task AND (c) downstream story (Story 1.9) covers integration-level probing". Future stories invoking the skip clause on these grounds must pin equivalent three-pointed rationale in IP — bare "no test runner exists" is insufficient justification on its own.

## Notes

- Spec authored inline (Ralph-hosted) per Stories 1.6/1.7 precedent — `/bmad-create-story` skill would HITL-halt on user-input checkpoints; Ralph uses the skill's `template.md` + prior-story skeleton as the authoring template.
- Architecture.md:922 hyphen→dot normalisation carried the Story 1.7 iter-20 deferred finding into a Task-1 subtask (not a separate story) — single-character correction, not behavioural.
- Issue Tracking: parent Epic 1 issue **#9**, Story 1.8 issue **#32**. Every commit carries `Refs #32` + `Refs #9` trailers; `Closes #32` reserved for PR body at EPIC_DONE transition.
