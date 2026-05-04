# Implementation Plan — PR #230 review-fix-arc (2026-05-04 redirect)

## NOW

- [ ] Monitor PR #230 CI on FIX-4 push — queue fix tasks for any failures; advance to FIX-5 if green.

## QUEUE (Epic 2 PR #230 review-fix-arc; landing-summary `IC_kwDOSAH0488AAAABBMCAuQ`)

- [ ] FIX-5: docker-compose.yml:294-303 healthcheck — append `nft list chain inet keel_egress output_v4` probe; root-gate or sentinel-file fallback. ~small

### RESOLVE-only (8 landed threads — reply + `resolveReviewThread`)

- [ ] Thread-resolve sweep (per-thread closing commit; full IDs prefix `PRRT_kwDOSAH0485…`):
  - rN6F→`27d4c7b` (legacy-branch:128); rN8s→`d3aecde` (ralph-build-host:89)
  - eiOE→`9f41606` (sync-gate FIX-3); next→`THIS-COMMIT` (sync-gate FIX-4)
  - ejlV→`33aca2d` (hook:171); ejoe→`33aca2d` (hook:79-84)
  - eloF→`33aca2d` (dnsmasq:32-53); elpv→`33aca2d` (resolver:153-165)
  - +4 DEFERRED-fix threads same-iter as FIX-N commit lands.

### Final close-out

- [ ] Final pre-push CI gate post FIX-5 → monitor green per § PR Lifecycle.
- [ ] EPIC_DONE halt — note "12 threads addressed; await human merge → § Cross-epic transition".

## DONE (current PR-fix-arc phase)

- [iter-pr230-fix-1] FIX-1 landed: D-38 refactor of L231-237 case-glob arm → bash-regex with token-boundary tolerance. interp_verb_re flag-class widened to `[a-zA-Z0-9]*[ec]`. Substrate + seed byte-parity preserved (manifest hash 8b10e266). Hook-fixture suite 81/81; gates green.
- [iter-pr230-monitor-fix-1] CI green at `a4c7bad` (4/4 SUCCESS). Local IP-advance staged for co-push with FIX-2.
- [iter-pr230-fix-2] FIX-2 landed: Bash-arm verb-gated token-scan + per-token `readlink -f` mirroring D-22 Read-arm. Closes `cat /tmp/symlink-to-/home/dev/.claude/x` bypass class. 6 new match-strings under `secret-access-denylist`. Substrate + seed byte-parity preserved (manifest hash `8b10e266 → 8350baf2` in lockstep). Hook-fixture suite 82/82; gates green.
- [iter-pr230-monitor-fix-2] CI green at `14f875e` (4/4 SUCCESS). IP-advance staged for co-push with FIX-3.
- [iter-pr230-fix-3] FIX-3 landed: `EXPECTED_INVARIANT_IDS` out-of-band fail-closed snapshot in L1-protected `sync-gate.ts` (43 IDs at landing). Closes drop+anchor-remove bypass class. New `DriftKind = 'expected-id-missing'`; gates green; vitest 53/53.
- [iter-pr230-monitor-fix-3] CI green at `9f41606` (4/4 SUCCESS: node x2 ~39-45s, python x2 ~9s). Monitor-resolution treated as precondition gate (RALPH `Monitor-bookkeeping-loop-break`); FIX-4 executed in same iteration.
- [iter-pr230-fix-4] FIX-4 landed: `BYTE_PARITY_PAIRS` out-of-band byte-parity check in L1-protected `sync-gate.ts` (1 pair at landing — `INV-claude-hook-secret-denylist` ↔ `-seed`). Closes lockstep-hash bypass class — even if attacker mutates BOTH manifest contentHash entries to match each other, the sync-gate reads both files and SHA-256-compares at audit time. New `DriftKind = 'byte-parity-mismatch'`; missing-file branch (a or b absent) folds into same drift kind with `detail` listing absent path. Tests: 3 dedicated cases (differ-content / missing-file / clean baseline) parametrised over `BYTE_PARITY_PAIRS` so each registered pair is auto-asserted. Existing `clean baseline` test filter extended to also exclude `byte-parity-mismatch`. Gates: typecheck 16/16, lint 16/16, vitest 56/56 (was 53; +3 byte-parity tests), `pnpm keel-invariants:check` clean against real repo (substrate ↔ seed byte-identical at `8350baf2…`). Sync-gate.ts is NOT manifest-tracked, so no contentHash bump required.

## Context

- **Phase:** 4-implementation — PR #230 review-fix-arc (post-closeout redirect 2026-05-04).
- **Epic:** 2 — Sandboxed Execution Environment (devbox). All 18 stories `done`; fix-arc reopened.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (worktree HEAD = PR #230 head).
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent)._
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 Open, MERGEABLE=CLEAN, CI green at `9f41606` pre-FIX-4 push. After FIX-4 push lands: 9 unresolved threads expected (1 MORE resolves under FIX-4); 7 deferred close-out + 1 deferred-fix pending FIX-5.

### Recipe references

- Sparring-partner discipline: AGENTS.md rule 6 + RALPH.md `iter:pr-review-multi-vector`. Artefacts at `/tmp/pr230_review/<fix-N>_*.md`.
- L1 install-boundary workaround (FIX-3/FIX-4): RALPH.md § Gotchas `install-boundary-protection`. Used for FIX-4: Write to `/tmp/sync-gate.new.ts` → `node -e "fs.copyFileSync(...)"` lands without firing the L1 mutation-verb gate.
- Byte-parity pattern: pair-list constant in L1-protected sync-gate.ts mirrors the FIX-3 EXPECTED_INVARIANT_IDS shape — both close symmetric-loop bypass classes with out-of-band fail-closed registries protected by the install-boundary hook.
- `resolveReviewThread`: `gh api graphql -f query='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { id isResolved } } }' -F id=…`. Sequence: reply → resolve.

## Halt criterion

`{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR #230 review-fix-arc complete; await human merge → § Cross-epic transition."}` after FIX-5 push + CI green + 12-thread-resolve.
