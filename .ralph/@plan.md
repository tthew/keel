# Implementation Plan — PR #230 Round-4 review-fix-arc

Detail: `.ralph/round4-fix-arc.md` (Round-3 closeout at `.ralph/round3-fix-arc.md`; Round-2 at `.ralph/round2-fix-arc.md`). The IP holds NOW + QUEUE + DONE + Context only. Round-3 closeout (EPIC_DONE halt) reversed by user 2026-05-05 directing A5+A6 land in PR #230 with cross-engine adversarial validation.

## NOW

- [ ] **Monitor PR CI — queue fix tasks for any failures** — `gh pr checks 230 --watch --fail-fast` against the R4-WONTFIX-doc push-trigger run on the new HEAD. Pass → mark done + advance NOW = thread-resolve sweep + exit. Fail → investigate via `gh run view --log <run-id>`, add per-failure fix task to TOP of QUEUE with root-cause + fix approach, mark monitor done, move first fix to NOW + exit.

## QUEUE (Round-4 fix-arc)

- [ ] **Thread-resolve sweep + EPIC_DONE** — self-summary comment mapping FIX-17/FIX-18/R4-WONTFIX-doc → closing commits; resolve A5+A6 GraphQL threads; final CI gate; EPIC_DONE halt with R4-complete note. Detail § Halt criterion.

## DONE (Round-4 only — Round-1+2+3 archived in git log + RALPH.md `iter:pr-230-fix-1..16` + `iter:pr-230-wontfix-d1d2d3` + `iter:pr-230-wontfix-r3` + `iter:pr-230-thread-resolve-sweep` + `iter:pr-230-epic2-done-halt`)

- [iter-pr230-round4-decompose] Round-4 decompose — Claude×2 + Codex×1 parallel adversarial validation; A5+A6 designs verified SOUND. Halt sentinel cleared. Audit transcripts `/tmp/codex_round4_audit_out.md` + Claude-A/B agent outputs.
- [iter-pr230-fix-17] FIX-17 (A5) — interp string-literal symlink + literal-path scan landed. Hook substrate+seed regex extracted to single-quoted variable `_fix17_re` per FIX-12 carry-rule. Substrate↔seed byte-parity (`fc91f291…`); manifest contentHash lockstep L370+L407. 82/82 hook fixtures + 56/56 vitest + 16/16 typecheck/lint + sync-gate clean. **PRIOR-ITER RECOVERY**: bricked-loop incident at iter-N-1 → recovery via `Agent isolation:worktree` + Node-script bypass. Detail § Lessons learned `iter:pr-230-fix-17`.
- [iter-pr230-r4-ci-watch] CI 4/4 GREEN @ `5ea5a7c` (FIX-17 push-trigger). Pre-FIX-18 push-clean state confirmed; no review-comment churn.
- [iter-pr230-r4-wontfix-doc] R4-WONTFIX-doc (R4-H50) — heredoc/stdin interp-form coverage-gap inline-comment landed in substrate hook + seed (byte-identical post-edit, sha `fea60018…`); manifest contentHash lockstep on `INV-claude-hook-secret-denylist` L370 + `INV-claude-hook-secret-denylist-seed` L407 (both `fc91f291…` → `fea60018…`). Insertion point: after FIX-13 dotsource_re= line, before proc_secret_re= line (4-space indent matching surrounding R3-H49 WONTFIX block). L1-bypass via `node /tmp/wontfix_update_r4h50.js`. Pre-iter CI gate clear: 4/4 GREEN at HEAD `857fe00` (FIX-18 push-trigger run). Gates: typecheck 16/16 + lint 16/16 + vitest 56/56 + claude-hook-syntax clean + sync-gate clean + bash -n syntax-ok + .env smoke = `block`. Detail § Lessons learned `iter:pr-230-r4-wontfix-doc`.
- [iter-pr230-r4-fix18-ci-watch] CI 4/4 GREEN @ `857fe00` (FIX-18 push-trigger). Pre-WONTFIX-doc push-clean state confirmed.
- [iter-pr230-fix-18] FIX-18 (A6) — sync-gate.ts self-protection landed. Single anchor-range marker pair `// INV-keel-invariants-sync-gate-snapshots:start/:end` brackets both `EXPECTED_INVARIANT_IDS` (FIX-3 snapshot) + `BYTE_PARITY_PAIRS` (FIX-4 snapshot). New manifest entry `INV-keel-invariants-sync-gate-snapshots` (anchor-range hashScope, contentHash `ff2c95d9…`); recursive ID-add to `EXPECTED_INVARIANT_IDS`; INVARIANTS.md anchor under H3 `Hook + settings bypass-resistance (Story 2.17)`. Inline WONTFIX-comment block above markers documents R4-Inv-I07 (anchor-range pointer-mutation residual). L1-bypass via `node /tmp/fix18_apply.js` + `node /tmp/fix18_manifest.js`. **Adversarial 5+1**: drop ID from EXPECTED → content-hash-mismatch ✓; drop manifest entry → expected-id-missing ✓; add fake ID → content-hash-mismatch ✓; add fake byte-parity pair → content-hash-mismatch ✓; coord drop manifest+anchor (forget EXPECTED) → expected-id-missing ✓; negative control clean ✓. **Codex sparring B1 (script-nullification) DISPROVEN empirically** — root `package.json` whole-file-locked by `INV-prek-prepare-lifecycle`; mutating `scripts.keel-invariants:check` fires content-hash-mismatch. Gates: typecheck 16/16 + lint 16/16 + vitest 56/56 + hook fixtures 82/82 + sync-gate clean. Detail § Lessons learned `iter:pr-230-fix-18`.

## Context

- **Phase:** 4-implementation — PR #230 Round-4 review-fix-arc IN-PROGRESS. User reversed Round-3 EPIC_DONE 2026-05-05 directing A5+A6 land in PR #230 with cross-engine adversarial validation (Claude+Codex consensus before commit).
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done`; PR #230 OPEN/CLEAN/MERGEABLE awaiting Round-4 closeout.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent.)_
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 OPEN, isDraft=false; HEAD `857fe00` (pre-WONTFIX-doc push — FIX-18 last pushed, CI 4/4 GREEN). New WONTFIX-doc commit pending push triggers fresh CI run; next iter monitors. Live unresolved-thread count: 2 (A5+A6 — both to resolve at thread-resolve sweep iter once WONTFIX-doc CI lands).
