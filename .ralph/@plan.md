# Implementation Plan

## NOW

- [ ] Run `/bmad-testarch-atdd` — red-phase scaffolds (validated → atdd-scaffolded); likely skip-to-in-dev since AC 4 is validated by Task 3's runtime smoke (no separate runner-probe needed) ~small

## QUEUE (Story 1.8 — invariants-manifest-ts-contract-exporter)

- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md")` — implement Tasks 1–3 (atdd-scaffolded → in-dev)
- [ ] Run `/bmad-testarch-trace (args: "yolo")` — coverage gate (in-dev → traced); expect WAIVED per Story 1.7 iter-5 precedent (no test runner; Zod parse IS the runtime check)
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (traced → sm-verified)
- [ ] Run `/bmad-code-review (args: "2")` — quality gate (sm-verified → done)
- [ ] After Story 1.8 done: `/bmad-create-story` for Story 1.9 (`invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`)

## BLOCKED

_(none)_

## DONE (Story 1.8 — spec authoring + pre-dev SM review)

- [x] Ralph-hosted `/bmad-create-story` — Story 1.8 spec authored at `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`; 3-task decomposition (Task 1 `invariants.manifest.ts` contract + 9-entry data + architecture.md:922 dot-form normalisation; Task 2 zod dep + import-time validation; Task 3 quality gates + sprint-status bump). Sprint-status bumped `1-8: backlog → ready-for-dev` with `last_updated: 2026-04-20 Story-1-8-spec UTC`. Story State: `(no story) → drafted`.
- [x] Pre-dev SM review (iter-2; `drafted → validated` per FR14n matrix row 2). Inline checklist.md audit against spec file. **Audit trail (9 checks):** (1) 9/9 INV-\* IDs match `INVARIANTS.md` entries verbatim; (2) 7/7 distinct `sourcePath` files exist on disk; (3) 9/9 `contentHash` values byte-match freshly-computed `sha256sum` (shared-source cases `eslint.config.keel-invariants.js`=10ac60… + `.pre-commit-config.yaml`=0e8e35… correctly produce identical hashes across sibling invariants — by-design cross-cutting detection); (4) ACs 1–4 well-formed BDD shape with Given/When/Then; (5) scope carve-outs double-anchored (AC 2 + AC 3 inline + § Project Structure Notes § Scope Carve-Out + § ContentHash anchor-bounding) per iter-1 carry-forward rule; (6) Zod pin posture aligns with I7; (7) Provisional-ID header discharge noted in § Project Structure Notes; (8) quality-gate bundle enumerated verbatim from Stories 1.4/1.5/1.6/1.7 precedent; (9) Testing Standards rationale present. **One critical finding applied:** spec Task 1's last subtask claimed architecture.md:922 hyphen→dot normalisation as a Dev action, but iter-1's spec-authoring commit (`8991214`) already co-landed the edit; current line is `architecture.md:942` dot-form. Fix applied in three spec locations: (a) Task 1 subtask marked `[x]` with discharge note + commit reference; (b) Dev Notes `[Source: architecture.md:922 (post-normalisation)]` → `:942`; (c) Source tree components `EDIT architecture.md:922` line removed; (d) Change Log v1.1 row added. Story file Status remains `ready-for-dev` (BMad-native); FR14n Story State advances via IP. Story State: `drafted → validated`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.7 done; 1.8 in flight)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter`
- **Story:** 1.8 — invariants-manifest-ts-contract-exporter (PRD FR42; consumed by Story 1.9 sync-gate per FR43)
- **Story File:** `_bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md`
- **Story State:** validated

## Notes

- Spec authored inline (Ralph-hosted) per Stories 1.6/1.7 precedent — `/bmad-create-story` skill would HITL-halt on user-input checkpoints; Ralph uses the skill's `template.md` + prior-story skeleton as the authoring template.
- Architecture.md:922 hyphen→dot normalisation carried the Story 1.7 iter-20 deferred finding into a Task-1 subtask (not a separate story) — single-character correction, not behavioural.
- Issue Tracking: parent Epic 1 issue **#9**, Story 1.8 issue **#32**. Every commit carries `Refs #32` + `Refs #9` trailers; `Closes #32` reserved for PR body at EPIC_DONE transition.
