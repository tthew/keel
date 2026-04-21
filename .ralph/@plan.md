# Implementation Plan

## NOW

- [ ] `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-14-release-please-monorepo-config-single-bundled-mode.md")` — FR14n row 4 `atdd-scaffolded → in-dev`. Single-pass dev forecast (configuration-surface only: 2 new JSON files + 1 new markdown file + 3 manifest entries + 3 anchor bullets + sprint-status bump; zero runtime code). Expected files touched per § Project Structure Notes: 3 NEW (`.github/release-please-config.json`, `.github/.release-please-manifest.json`, `docs/invariants/release.md`), 2 MODIFIED (`packages/keel-invariants/src/invariants.manifest.ts`, `INVARIANTS.md`), 1 MODIFIED (`sprint-status.yaml` ready-for-dev → in-progress → review).

## QUEUE (Story 1.14 — release-please monorepo config)

_(empty — trace / SM / CR fix tasks will be re-seeded only if findings emerge at iter-78 / iter-79 / iter-80.)_

## BLOCKED

_(none)_

## DONE (current story/phase only)

- [x] iter-75: **FR14n row 2 `drafted → validated` via `/bmad-create-story (args: "review")`.** Pre-dev SM review landed **2 PATCH** (third cumulative ≤2 PATCH precedent). PATCH 1 (L5 residual): systemic packages-count off-by-one corrected across 12 sites (17 workspace / 16 packages/* / 18-key map / 18 entries → 16 / 15 / 17 / 17). PATCH 2 (§ References citation drift): architecture.md § 1.0 distribution line 532 wrong; corrected to § Technical Constraints & Dependencies line 80. Task 7 smokes now expect 17 (would otherwise have THROWN on dev-story). L1/L2/L3/L6/L7 layers: clean.
- [x] iter-76: **FR14n row 3 `validated → atdd-scaffolded` via hybrid ground-(c) variant-(ii)+(iii) ATDD-skip clause.** EIGHTH cumulative Epic 1 ATDD-skip precedent (Stories 1.7 iter-2 / 1.8 iter-3 / 1.9 iter-4 / 1.10 iter-44 / 1.11 iter-55 / 1.12 iter-62 / 1.13 iter-69 → 1.14 iter-76). Skill `/bmad-testarch-atdd` NOT invoked (preflight HALT confirmed — recursive `find` for `vitest.config.*` / `jest.config.*` / `playwright.config.*` / `cypress.config.*` anywhere in tree returns zero matches; Story 1.16 is the formal test-runner landing). § Testing Standards ATDD Skip Rationale subsection pre-staged at iter-74 drafting — no new prose needed. Single in-situ PATCH correcting drafting + SM-review count-drift residual: `seventh → eighth` at 3 sites (line 234 twice + line 289). Story 1.13 iter-69 was canonically SEVENTH (Stories 1.7-1.13 inclusive); Story 1.14 is EIGHTH. Story 1.14 § Change Log v1.2 row appended. Sprint-status unchanged (workflow-state `ready-for-dev` persists; FR14n lifecycle is Ralph-internal). No code changes; no quality-gate reruns (prose-only commit — iter-67/iter-68/iter-69 precedent).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.13 done; 1.14 atdd-scaffolded; 1.15 + 1.16 backlog — 2 more stories × full FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** 1.14 — release-please monorepo config (single-bundled mode). Key: `1-14-release-please-monorepo-config-single-bundled-mode`.
- **Story File:** `_bmad-output/implementation-artifacts/1-14-release-please-monorepo-config-single-bundled-mode.md`.
- **Story State:** `atdd-scaffolded` — FR14n matrix row 4 next at iter-77 (`/bmad-dev-story` single-pass forecast; configuration-surface only).
- **GitHub Issue:** Story 1.14 at **#38** (OPEN). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.14 + 1.15 + 1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.14 forecast updated post-iter-76.** ATDD-skip ceremony clean (no prose PATCH beyond the count-drift correction). Trajectory for iter-77..iter-80: single-pass dev-story (iter-77, state `atdd-scaffolded → in-dev`), trace WAIVED-with-substrate-evidence (iter-78, state `in-dev → traced`), post-dev SM review ZERO-PATCH-target (iter-79, state `traced → sm-verified`), CR ZERO-PATCH + 5-8 DEFER (iter-80, state `sm-verified → done`). 7-iteration `drafted → done` target holds (iter-74..iter-80 inclusive).
- **Carry-forward rules INTO iter-77 `/bmad-dev-story`:**
  - Dev-story skill reads story file + produces the 5 file changes (`.github/release-please-config.json` NEW, `.github/.release-please-manifest.json` NEW, `docs/invariants/release.md` NEW, `invariants.manifest.ts` +3 entries, `INVARIANTS.md` +1 H3 section + 3 bullets) + sprint-status bump (`ready-for-dev → in-progress` at start; `in-progress → review` at end).
  - Task 7 six smokes run inline: static JSON parse (both files), single-bundled-mode shape (expects 17 packages), config-manifest key-parity (expects 17 entries), manifest-version parity (all entries at `0.0.0`), manifest-load smoke (`@keel/keel-invariants` exports 20 entries), sync-gate clean (`pnpm keel-invariants:check` exit 0 <2s).
  - Full quality-gate suite runs: `pnpm typecheck && pnpm lint && pnpm format:check && pnpm keel-invariants:check-all`. All must pass.
  - Dev-story is expected single-pass (no partial completion). Configuration-surface + manifest entries + anchor bullets are a proven low-risk shape (Stories 1.10/1.11/1.12/1.13 all landed single-pass dev-story).
- **L5 enhancement candidate for post-retrospective RALPH.md Lessons.** Cumulative-precedent count drift at iter-74 drafting (claimed "seventh" when actually "eighth") is a NEW sub-class of L5 count drift: not cross-file collection cardinality (packages / manifest entries / lines) but iteration-chain sequence numbers carried over from prior-story drafts. Post-Epic-1 retrospective candidate: promote an **L5c — increment-not-carry-over-sequence-counts** sub-layer to RALPH.md Lessons. iter-74 inherited "seventh" from Story 1.13 iter-67's drafting without incrementing; iter-75 pre-dev SM review didn't catch it either (SM-review checklist focuses on AC-vs-Task + cross-file + collection cardinality, not sequence-counter math).
- **Story 1.14 NOT absorbing** (route elsewhere):
  - Story 13.5 `.github/workflows/release-please.yml` — Epic 13 scope (AC 5 carve-out).
  - Story 1.15 `.github/renovate.json` — Epic 1 Story 1.15 scope.
  - Story 1.16 fork-extension pattern — Epic 1 Story 1.16 scope; Story 1.14 only notes the fork-extension pointer in `docs/invariants/release.md` § Fork extension.
- **Issue Tracking carry-forward.** Story 1.14 at **#38** OPEN; parent Epic 1 at **#9** OPEN. iter-76 commit trailer uses `Refs #38`.
