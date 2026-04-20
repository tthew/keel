# Implementation Plan

## NOW

- [ ] Run `/bmad-testarch-atdd` — red-phase scaffolds for Story 1.9 runtime-behaviour OR apply FR14n matrix row 3 skip clause (`validated → atdd-scaffolded`). IP-Notes prediction: skip UNLIKELY — Story 1.9 has runtime walker + drift-detector + CLI; RALPH.md guardrail requires all three grounds (substrate-coverage + no-test-runner + upstream-covered); Story 1.9 satisfies only the middle. ~medium

## QUEUE (Story 1.9 — invariant-sync-gate-runtime-tooling-reader-walker-drift-detector)

- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md")` — executes 5 Tasks (`atdd-scaffolded → in-dev`).
- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability matrix (`in-dev → traced`). Expect PASS (not WAIVED) — Story 1.9 runtime smoke-tests in Task 5 materially cover ACs 1/4/7; ACs 2/3/5 are schema-level covered by manifest Zod refines + walker regex.
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (`traced → sm-verified`).
- [ ] Run `/bmad-code-review (args: "2")` — adversarial triage (`sm-verified → done` OR `fixes-pending`).

## BLOCKED

_(none)_

## DONE (Story 1.9 — pre-dev SM validation)

- [x] Ralph-hosted `/bmad-create-story (args: "review")` inline realisation (iter-2; `drafted → validated` per FR14n matrix row 2). Sonnet subagent ran `.claude/skills/bmad-create-story/checklist.md` against the 135-line spec. Overall verdict PASS with zero critical findings. Checklist steps 1/2.1/2.2/2.3/2.4/3.1/3.2/3.3/3.4/3.5/4 all PASS; steps 5–8 N/A (interactive-improvement mode not applicable). References verified: 5 NEW/EDIT paths (`manifest-reader.ts`, `sync-gate.ts`, `check.ts` correctly NEW; `invariants.manifest.ts`, `index.ts`, `package.json` correctly EDIT) + PRD FR42/FR43 at prd.md:1008/1009 + architecture.md:942 + epics.md:888–924 (7 ACs verbatim-match) + sprint-status.yaml (1.1–1.8 done, 1.9 ready-for-dev) + Story 1.8 deferred-work.md:9–14 (4-of-6 absorbed, 2 correctly deferred). Pre-baked `contentHash` literal `8c679cdabcccb8ac122b8da82d4bcb8198451f0cc0a19b3d13b4b2695b6cba8b` for `INV-ralph-halt-path-resolution` re-verified via live `sha256sum docs/invariants/ralph-execute.md` (Ralph in-line, not subagent — Bash not available to the analyst subagent) — byte-identical match, zero drift between spec-auth iter-1 commit `ec9eb4e` and SM-review iter-2. Story file Status flipped `drafted → validated`; Change Log v1.1 row appended documenting the review pass + hash re-verification. Zero fix tasks queued (Story 1.8 iter-2's inline-fix pattern did not apply — no architecture.md hyphen/dot drift or co-landed-in-spec tasks to retcon). Story State: `drafted → validated`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 validated)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues — PR #226 stays Draft until EPIC_DONE of Epic 1 per PROMPT_build.md step 5c "if all epic stories are done"; prior per-story-PR pattern (1.1–1.7) is superseded by current step-5c semantics)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `validated`
- **PR:** #226 (Draft, MERGEABLE, empty CI rollup — expected pre-Story-1.16; stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **Story 1.9 is enforcement-side of FR43** — first Epic-1-substrate story with genuine runtime behaviour (walker + drift-detector + CLI), NOT pure data-contract. Expect a hotter trace gate than Stories 1.7/1.8 (both WAIVED on ATDD-skip grounds); Story 1.9's runtime smoke tests in Task 5 materially cover ACs 1/4/7 at the shell level. ATDD skip clause (FR14n matrix row 3) is unlikely to apply — RALPH.md guardrail requires all three grounds (substrate-coverage + no-test-runner + upstream-covered); Story 1.9 satisfies only the middle one.
- **10th manifest entry (`INV-ralph-halt-path-resolution`) closes pre-existing drift.** The halt-path-resolution fix (commit `5cfa055`, PR #225) added the 10th anchor to `INVARIANTS.md` at line 48 but did NOT update Story 1.8's manifest. Story 1.9 Task 2 closes this gap — without it, Story 1.9's own sync-gate would report `removed-from-docs-only` on first run (ironic: the enforcement tool would catch itself-being-unfinished). Dev-story MUST land Task 2 before Task 5's clean-path smoke test. Pre-baked hash literal re-verified at iter-2 — no drift; Dev may trust the literal verbatim (but MUST still run `sha256sum` at dev-story time per RALPH.md's Story 1.9 Signpost carry-forward rule, in case the file drifts between iter-2 and dev-story iteration).
- **Four-of-six Story 1.8 CR defers absorbed in Task 3** — sourcePath traversal guard + id uniqueness refine + cross-entry hash consistency + readonly/freeze. Two remain deferred: contentHash drift validation (IS Task 1's sync-gate scope, functionally absorbed at tool level without needing schema change) + schema-evolution metadata (`schemaVersion`/`deprecated`/`since`; stays in `deferred-work.md` until a concrete deprecation need arises).
- Issue Tracking: Story 1.9 issue number still unset at iter-2 (`RALPH_ISSUE_NUMBER` empty — no GH project auto-creation, or timing-gap with ralph.py's env injection). Parent Epic 1 issue **#9** — `Refs #9` only; closed by ralph.py EPIC_DONE halt handler at Epic 1 completion. If `RALPH_ISSUE_NUMBER` lands at iter-3+, add `Refs #N` trailer to subsequent commits alongside `Refs #9`.
