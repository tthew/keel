# Implementation Plan

## NOW

- [ ] iter-89: `/bmad-create-story (args: "review")` — FR14n row 2 `drafted → validated` pre-dev SM readiness review for Story 1.16 (`_bmad-output/implementation-artifacts/1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold.md`). SIXTH cumulative ZERO-PATCH CR candidate; TENTH cumulative Epic-1 ATDD-skip + TENTH cumulative WAIVED-trace candidate. Target ≤2 PATCH matches Stories 1.11/1.12/1.13/1.14/1.15 1-2 PATCH precedent average. Configuration-surface + documentation-tier class (2 new markdown files + 2 new manifest entries + 2 anchor bullets + 2 knowledge-file edits: AGENTS.md + CLAUDE.md). Seven-layer audit pre-applied at drafting (L1 stable IDs `INV-fork-extension-rationale` + `INV-fork-invariants-scaffold` both regex-passed; L2 AC↔Task bidirectional coverage verified; L3 sprint-status transition `backlog → ready-for-dev` + `last_updated: 2026-04-21 Story-1-16-drafted UTC` landed; L4 cross-file convergence epics.md:1110-1137 + prd.md:141-142 + architecture.md:237/:906/:913/:1010-1011 verified; L5 mechanical counter = Story 1.16 is 10th ATDD-skip + 10th WAIVED-trace + 6th ZERO-PATCH-CR candidate; L6 no-cascade-hash check — AGENTS.md/CLAUDE.md/INVARIANTS.md not sourcePaths so no cross-entry hash bumps; L7 scaffolding-story domain carve-out — novel template-file surface + knowledge-file edits expand Story 1.15's surface slightly but remain within configuration-surface-tier adversarial posture).

## QUEUE (Story 1.16 — fork-extension scaffold + INVARIANTS.fork scaffold)

- [ ] iter-90: `/bmad-testarch-atdd` — FR14n row 3 `validated → atdd-scaffolded` TENTH cumulative Epic-1 ATDD-skip candidate (scaffolding-story class: 2 new markdown + 2 manifest entries + 2 anchors + 2 knowledge-file edits = documentation + template surfaces, no testable runtime behaviour; record ATDD-skip rationale in IP Notes per Decision Matrix row 3 skip-allowed carve-out).
- [ ] iter-91: `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold.md")` — FR14n row 4 `atdd-scaffolded → in-dev` expected SINGLE-PASS at configuration-surface + documentation-tier scale (2 new markdown files + 2 manifest entries + 2 anchor bullets + AGENTS.md insert + CLAUDE.md table-row + precedence-paragraph append).
- [ ] iter-92: `/bmad-testarch-trace (args: "yolo")` — FR14n row 5 `in-dev → traced` TENTH cumulative WAIVED precedent (documentation + template-only surface; no ACs with runtime-executable behaviour).
- [ ] iter-93: `/bmad-create-story (args: "review")` — FR14n row 7 `traced → sm-verified` SIXTH cumulative ZERO-PATCH post-dev SM candidate.
- [ ] iter-94: `/bmad-code-review (args: "2")` — FR14n row 9 `sm-verified → done` SIXTH cumulative ZERO-PATCH CR candidate; Story 1.16 `done` → Epic 1 fully done → EPIC_DONE sequence begins.
- [ ] iter-95: Transition PR #226 Draft → Open — final CI gate via `gh pr ready && gh pr checks --watch --fail-fast`; post-CI-green mark epic-1 `in-progress → done` in sprint-status + EPIC_DONE halt write.

## BLOCKED

_(none)_

## DONE (current epic — trailing iterations only)

- [x] iter-88: **FR14n row 1 `_(no story) → drafted` via `/bmad-create-story`** for Story 1.16 (FINAL open story in Epic 1 + FR44 at 1.0 + FR45 Growth-tier substrate authoring). Drafted `_bmad-output/implementation-artifacts/1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold.md` with 4 ACs (verbatim from epics.md:1110-1137 with Story 1.15-style scope carve-outs) + 7 tasks (template scaffold at `packages/keel-invariants/templates/INVARIANTS.fork.md` + rationale doc at `docs/invariants/fork.md` + manifest entries `INV-fork-extension-rationale` + `INV-fork-invariants-scaffold` + anchor bullets + AGENTS.md § Fork extension (FR44) section + CLAUDE.md knowledge-file-contract table 5th row + substrate verification suite). Seven-layer audit pre-applied. Sprint-status flipped `backlog → ready-for-dev` + `last_updated: 2026-04-21 Story-1-16-drafted UTC`. Manifest growth forecast 22 → 24 (+9%). Story class: scaffolding / configuration-surface / documentation-tier — TENTH cumulative Epic-1 ATDD-skip + TENTH cumulative WAIVED-trace + SIXTH cumulative ZERO-PATCH-CR candidate.
- [x] iter-87: FR14n row 9 `sm-verified → done` via `/bmad-code-review (args: "2")` FIFTH cumulative ZERO-PATCH CR precedent (Stories 1.11/1.12/1.13/1.14/1.15). Full 7-iter lifecycle held exactly.
- [x] iter-86: FR14n row 7 `traced → sm-verified` via `/bmad-create-story (args: "review")` post-dev SM FIFTH cumulative ZERO-PATCH precedent.
- [x] iter-85: FR14n row 5 `in-dev → traced` via `/bmad-testarch-trace (args: "yolo")` NINTH cumulative WAIVED precedent.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1-1.15 done; Story 1.16 final open story — full 6-iter FR14n lifecycle remaining before EPIC_DONE halt: iter-89 → iter-94 `drafted → done`, iter-95 PR Draft→Open + EPIC_DONE).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** Story 1.16 — Fork extension-config pattern + Growth-tier `INVARIANTS.fork.md` scaffold (FR44 + FR45).
- **Story File:** `_bmad-output/implementation-artifacts/1-16-fork-extension-config-pattern-growth-tier-invariants-fork-md-scaffold.md` (iter-88 created).
- **Story State:** `drafted` — iter-89 next FR14n row 2 `drafted → validated` via `/bmad-create-story (args: "review")`.
- **GitHub Issue:** Story 1.16 at **#40** OPEN (`Story 1.16: Fork extension-config pattern + Growth-tier INVARIANTS.fork.md scaffold`; verified `gh issue list --search "Story 1.16" --state all`). Transitions to In Progress automatically at iter-89 start via ralph.py from IP `**Story:**` field. Parent Epic 1 at **#9** OPEN (closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through iter-89..iter-94 Story 1.16 lifecycle; Draft→Open at iter-95 post-Story-1.16 `done`).

## Notes

- **Story 1.15 iter-87 CR closed ZERO-PATCH — FIFTH cumulative precedent across 5 consecutive stories (1.11/1.12/1.13/1.14/1.15).** Full 7-iteration `drafted → done` lifecycle held. Story 1.16 targets the SIXTH cumulative ZERO-PATCH CR precedent with the same seven-layer audit discipline pre-staged.
- **Story 1.16 drafting decisions (iter-88):**
  - **Surface class: scaffolding / configuration-surface / documentation-tier.** 2 new markdown files (template + rationale doc) + 2 manifest entries + 2 anchor bullets + 2 knowledge-file edits (AGENTS.md new H2 section + CLAUDE.md knowledge-file-contract table 5th row + precedence paragraph). IP forecast was "1 new markdown + 1-2 manifest + 1-2 anchors" — actual authored surface is 2 new markdown (template AND rationale doc — not combined because template needs clean byte-stable hash pin without rationale-doc content co-mingling). +1 markdown expansion from IP forecast noted in Dev Notes § Previous story intelligence.
  - **Manifest IDs (epic-free — epics.md Story 1.16 does NOT pin IDs verbatim, contrast Story 1.15 AC 4 `INV-deps-version-pinning`):** selected by convention — `INV-fork-extension-rationale` (matches Story 1.10 `INV-tokens-semantic-rationale` + Story 1.14 `INV-release-please-rationale` + Story 1.15 `INV-renovate-rationale` `INV-<domain>-rationale` pattern); `INV-fork-invariants-scaffold` (`INV-<domain>-<surface>` pattern; "scaffold" names the substrate-ships-template-for-fork-to-copy surface class, no prior precedent).
  - **AGENTS.md + CLAUDE.md edits — NOT hash-pinned.** Knowledge files evolve frequently; hashing them creates churn without signal. The machine-enforced anchor for the fork-extension pattern is `docs/invariants/fork.md` (rationale) + `packages/keel-invariants/templates/INVARIANTS.fork.md` (template) — both hash-pinned. AGENTS.md + CLAUDE.md are consumption-layer pointers to the rationale doc.
  - **ATDD-skip posture pre-decided for iter-90.** Story 1.16 has no testable runtime behaviour (documentation + template-only surface); ACs 1-4 are all documentation-ACs + scope-carve-out-ACs. ATDD-skip rationale will be recorded in IP Notes at iter-90.
  - **Novel surface: AGENTS.md new H2 section.** First post-Story-1.7 AGENTS.md edit adding a new H2 section. Dev-story should use surgical Edit (NOT full rewrite) per Dev Notes § Previous story intelligence.
- **Carry-forward rules INTO iter-89 `/bmad-create-story (args: "review")` for Story 1.16 pre-dev SM review:**
  - Pre-dev SM review validates readiness: (a) ACs are testable (each AC has Given/When/Then + scope carve-outs per Story 1.15 precedent); (b) Tasks cover every AC (L2 bidirectional coverage verified at drafting); (c) Dev Notes cite source paths (References block enumerates 18 source refs per L7 carry-forward); (d) Manifest IDs match regex (L1 verified); (e) Previous story intelligence carries forward; (f) File list is complete; (g) sprint-status correctly reflects `ready-for-dev`.
  - Expected patch surface: 0-2 PATCH (matches Story 1.11/1.12/1.13/1.14/1.15 1-2 PATCH pre-dev average). Any PATCH ≥3 indicates a drafting defect requiring Story 1.16 re-drafting (fall-through to iter-88 delta-patch iteration).
  - Target: ZERO-PATCH preferred (Story 1.11-1.15 held 1-2 PATCH pre-dev; Story 1.16's configuration-surface + documentation-tier class with seven-layer audit pre-applied is the cleanest drafting posture; ZERO-PATCH pre-dev would be the first Epic-1 story to achieve it).
- **Issue Tracking carry-forward.** Story 1.16 at **#40** OPEN — on iter-89 start the story issue transitions automatically via ralph.py based on IP `**Story:**` field (now `Story 1.16 — Fork extension-config pattern + Growth-tier INVARIANTS.fork.md scaffold (FR44 + FR45)`). Parent Epic 1 at **#9** OPEN — closes at EPIC_DONE halt after iter-95.
