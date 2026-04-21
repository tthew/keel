# Implementation Plan

## NOW

- [ ] `/bmad-create-story (args: "review")` — FR14n row 2 `drafted → validated`; pre-dev SM review of Story 1.14 (`_bmad-output/implementation-artifacts/1-14-release-please-monorepo-config-single-bundled-mode.md`). Target ≤2 PATCH per iter-54/61/68 precedent.

## QUEUE (Story 1.14 — release-please monorepo config)

_(empty — fix tasks will be re-seeded only if SM review, trace, or CR emit findings.)_

## BLOCKED

_(none)_

## DONE (current story/phase only)

- [x] iter-74: **FR14n row 1 `_(no story) → drafted` via `/bmad-create-story`.** Story 1.14 (`release-please monorepo config — single-bundled mode`) picked from sprint-status + drafted. 6 ACs + 7 Tasks + seven preventative audit layers pre-applied per iter-67/73 compound-ZERO-PATCH carry-forward. Three new invariants registered: `INV-release-please-config` (`.github/release-please-config.json`) + `INV-release-please-manifest` (`.github/.release-please-manifest.json`) + `INV-release-please-rationale` (`docs/invariants/release.md`); manifest grows 17 → 20. Scope carve-outs pinned: (a) `.github/workflows/release-please.yml` is Story 13.5 / Epic 13 scope — 4 of 6 ACs (2/3/4/5) describe downstream consumer behaviour; (b) architecture.md § Source-tree line 807 drift (`release-please-config.json` at repo root) resolved in favor of epic AC (both files in `.github/`) per RALPH.md 2026-04-19 lesson "epics.md AC wins"; (c) Task 6 explicit no-op on root `package.json` + `.pre-commit-config.yaml` protects `INV-prek-prepare-lifecycle` + `INV-prek-*-config` hash-cascade; (d) zero token-layer touch protects Stories 1.10-1.13 hashes. Hybrid ground-(c) variant-(ii)+(iii) ATDD-skip pre-staged in § Testing Standards (seventh precedent). sprint-status: `1-14-...: backlog → ready-for-dev` + `last_updated: 2026-04-21 Story-1-14-drafted UTC`. Story State: `_(no story) → drafted`. Budget: ~40K (orient ~8K + sprint-status + epic/architecture/PRD reads ~12K + story authorship ~20K).

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.13 done; 1.14 drafted; 1.15 + 1.16 backlog — 2 more stories × full FR14n lifecycle remaining before EPIC_DONE halt).
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c).
- **Story:** 1.14 — release-please monorepo config (single-bundled mode). Key: `1-14-release-please-monorepo-config-single-bundled-mode`.
- **Story File:** `_bmad-output/implementation-artifacts/1-14-release-please-monorepo-config-single-bundled-mode.md`.
- **Story State:** `drafted` — FR14n matrix row 2 next at iter-75 (`/bmad-create-story (args: "review")` pre-dev SM verification).
- **GitHub Issue:** Story 1.14 issue TBD (ralph.py resolves on next iter start via sprint-status → Story field wiring). Parent Epic 1 at **#9** (OPEN — closes at EPIC_DONE halt).
- **PR:** #226 (Draft, empty statusCheckRollup — stays Draft through Epic 1; Draft→Open at EPIC_DONE after Stories 1.14 + 1.15 + 1.16 all complete FR14n lifecycle).

## Notes

- **Story 1.14 forecast.** IP Notes (iter-73 carry-forward) predicted 7-iteration drafted→done lifecycle target + ZERO-PATCH ceiling + ≈5-8 DEFER at CR (configuration-surface + toolchain-wiring has lower attack surface than gate-authoring at 10-13 DEFER). iter-74 drafting shipped all 7 preventative audit layers pre-staged — ready for iter-75 SM review at target ≤2 PATCH.
- **Carry-forward rules INTO iter-75 `/bmad-create-story (args: "review")`:**
  - **L1-L7 preventative audits** applied at drafting. Any SM-review finding that slips past is either (a) a new failure mode not covered by the 7 layers (promote to RALPH.md Lessons as an 8th layer candidate), or (b) a genuine L1-L7 residual (PATCH in-place per Story 1.13 iter-68 pattern, count ≤2).
  - **Architecture.md § Source-tree drift on `release-please-config.json` location.** AC 1 scope carve-out + Project Structure Notes Variances both record the drift + the epic-wins-over-architecture resolution. SM reviewer may flag this as a layer-4 internal-consistency concern — the answer is the carve-out language is authoritative; no PATCH needed unless the carve-out language itself has drift.
  - **Manifest grows 17 → 20.** L5 grep-count: `grep -c "id: 'INV-" packages/keel-invariants/src/invariants.manifest.ts` should equal `17` pre-Story-1.14 (verify at SM review); + 3 new entries from Story 1.14 Task 4 = 20 post.
  - **Commit trailer.** `Refs #9` (parent-epic fallback; Story 1.14 issue TBD until ralph.py resolves it on next iter start).
- **Story 1.14 NOT absorbing** (route elsewhere):
  - Story 13.5 `.github/workflows/release-please.yml` — Epic 13 scope (AC 5 carve-out).
  - Story 1.15 `.github/renovate.json` — Epic 1 Story 1.15 scope.
  - Story 1.16 fork-extension pattern — Epic 1 Story 1.16 scope; Story 1.14 only notes the fork-extension pointer in `docs/invariants/release.md` § Fork extension.
- **Issue Tracking carry-forward.** Parent Epic 1 at **#9** OPEN. iter-74 commit trailer uses `Refs #9` (Story 1.14 issue TBD).
