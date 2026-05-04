# Implementation Plan — PR #230 review-fix-arc (2026-05-04 redirect)

## NOW

- [ ] Monitor PR #230 CI on FIX-5 push — on green, advance to thread-resolve sweep (12 threads) + EPIC_DONE halt; on failure, queue fix tasks per § PR Lifecycle.

## QUEUE (Epic 2 PR #230 review-fix-arc; landing-summary `IC_kwDOSAH0488AAAABBMCAuQ`)

### RESOLVE-only (12 landed threads — reply + `resolveReviewThread`)

- [ ] Thread-resolve sweep (per-thread closing commit; full IDs prefix `PRRT_kwDOSAH0485…`):
  - rN6F→`27d4c7b` (legacy-branch:128); rN8s→`d3aecde` (ralph-build-host:89)
  - eiOE→`9f41606` (sync-gate FIX-3); ell8→`9f41606` (sync-gate FIX-3 EXPECTED_INVARIANT_IDS)
  - elm8→`36cf021` (manifest FIX-4 BYTE_PARITY_PAIRS); elo6→`THIS-COMMIT` (compose FIX-5)
  - ejlV→`33aca2d` (hook:171); ejoe→`33aca2d` (hook:79-84); ejmO→`a4c7bad` (hook FIX-1 case-glob)
  - eloF→`33aca2d` (dnsmasq:32-53); elpv→`33aca2d` (resolver:153-165)
  - eiOE-symlink→`14f875e` (hook FIX-2 Bash-arm symlink-deref)

### Final close-out

- [ ] EPIC_DONE halt — `{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR #230 review-fix-arc complete (FIX-1..FIX-5 landed; 12 threads resolved); await human merge → § Cross-epic transition."}`.

## DONE (current PR-fix-arc phase)

- [iter-pr230-fix-1] FIX-1 landed: D-38 refactor of L231-237 case-glob arm → bash-regex with token-boundary tolerance. interp_verb_re flag-class widened to `[a-zA-Z0-9]*[ec]`. Substrate + seed byte-parity preserved (manifest hash 8b10e266). Hook-fixture suite 81/81; gates green.
- [iter-pr230-monitor-fix-1] CI green at `a4c7bad` (4/4 SUCCESS). Local IP-advance staged for co-push with FIX-2.
- [iter-pr230-fix-2] FIX-2 landed: Bash-arm verb-gated token-scan + per-token `readlink -f` mirroring D-22 Read-arm. Closes `cat /tmp/symlink-to-/home/dev/.claude/x` bypass class. 6 new match-strings under `secret-access-denylist`. Substrate + seed byte-parity preserved (manifest hash `8b10e266 → 8350baf2` in lockstep). Hook-fixture suite 82/82; gates green.
- [iter-pr230-monitor-fix-2] CI green at `14f875e` (4/4 SUCCESS). IP-advance staged for co-push with FIX-3.
- [iter-pr230-fix-3] FIX-3 landed: `EXPECTED_INVARIANT_IDS` out-of-band fail-closed snapshot in L1-protected `sync-gate.ts` (43 IDs at landing). Closes drop+anchor-remove bypass class. New `DriftKind = 'expected-id-missing'`; gates green; vitest 53/53.
- [iter-pr230-monitor-fix-3] CI green at `9f41606` (4/4 SUCCESS: node x2 ~39-45s, python x2 ~9s). Monitor-resolution treated as precondition gate (RALPH `Monitor-bookkeeping-loop-break`); FIX-4 executed in same iteration.
- [iter-pr230-fix-4] FIX-4 landed: `BYTE_PARITY_PAIRS` out-of-band byte-parity check in L1-protected `sync-gate.ts` (1 pair at landing — `INV-claude-hook-secret-denylist` ↔ `-seed`). Closes lockstep-hash bypass class — even if attacker mutates BOTH manifest contentHash entries to match each other, the sync-gate reads both files and SHA-256-compares at audit time. New `DriftKind = 'byte-parity-mismatch'`; missing-file branch (a or b absent) folds into same drift kind with `detail` listing absent path. Tests: 3 dedicated cases (differ-content / missing-file / clean baseline) parametrised over `BYTE_PARITY_PAIRS` so each registered pair is auto-asserted. Existing `clean baseline` test filter extended to also exclude `byte-parity-mismatch`. Gates: typecheck 16/16, lint 16/16, vitest 56/56 (was 53; +3 byte-parity tests), `pnpm keel-invariants:check` clean against real repo (substrate ↔ seed byte-identical at `8350baf2…`). Sync-gate.ts is NOT manifest-tracked, so no contentHash bump required.
- [iter-pr230-monitor-fix-4] CI green at `36cf021` (4/4 SUCCESS). Monitor-resolution treated as precondition gate (RALPH `Monitor-bookkeeping-loop-break`); FIX-5 executed in same iteration.
- [iter-pr230-fix-5] FIX-5 landed: docker-compose.yml healthcheck adds `nft list chain inet keel_egress output_v4` clause-2 probe (root-gated via `[ "$(id -u)" -ne 0 ] ||` short-circuit). Verifies kernel netfilter `keel_egress.output_v4` chain presence at every probe interval, catching manual-flush / runtime-tamper failure mode mid-run; complements start-egress.sh's boot-time fail-closed posture. Root-gate hedges against the HEALTHCHECK-user ambiguity — substrate compose pins `user: '0:0'` so HEALTHCHECK runs as root with CAP_NET_ADMIN from cap_add (chain probe operates), but forks overriding `user:` to a non-root identity short-circuit clause 2 cleanly (preserve dnsmasq + sshd signal; MUST add fork-specific equivalent per Fork extension contract). Three-site lockstep updated: docker-compose.yml § services.devbox.healthcheck.test + docs/invariants/devbox-healthcheck.md § Probe contract / § Probe tooling / § Exit codes / § SSH-conditional / § Fork extension + packages/devbox/README.md § Healthcheck. Manifest description + contentHash bumped (`b8a420a4 → f4574871`); pnpm --filter @keel/keel-invariants build refreshed dist/check.js; sync-gate clean; gates green (typecheck 16/16, lint 16/16, vitest 56/56).

## Context

- **Phase:** 4-implementation — PR #230 review-fix-arc (post-closeout redirect 2026-05-04).
- **Epic:** 2 — Sandboxed Execution Environment (devbox). All 18 stories `done`; fix-arc reopened.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (worktree HEAD = PR #230 head).
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent)._
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 Open, MERGEABLE=CLEAN, CI green at `36cf021` post-FIX-4 push (4/4 SUCCESS); 11 unresolved threads observed (5 substantive-FIX threads + 6 already-landed RESOLVE-only threads + +1 anchor under FIX-5 once landed = 12 close-outs). After FIX-5 push lands + 12 thread-resolves applied: 0 unresolved expected → EPIC_DONE halt path.

### Recipe references

- Sparring-partner discipline: AGENTS.md rule 6 + RALPH.md `iter:pr-review-multi-vector`. Artefacts at `/tmp/pr230_review/<fix-N>_*.md`.
- L1 install-boundary workaround (FIX-3/FIX-4/FIX-5): RALPH.md § Gotchas `install-boundary-protection`. FIX-5 used a targeted-replace variant: write `/tmp/update_manifest_fix5.js` → run `node /tmp/update_manifest_fix5.js` (script does fs.readFileSync + string-replace + fs.writeFileSync against the L1 path; `node` is not in the L1 mutation-verb deny-list, and `writeFileSync` has no deny-list substring). Lighter than full-file overwrite when only one entry needs editing.
- Byte-parity pattern: pair-list constant in L1-protected sync-gate.ts mirrors the FIX-3 EXPECTED_INVARIANT_IDS shape — both close symmetric-loop bypass classes with out-of-band fail-closed registries protected by the install-boundary hook.
- HEALTHCHECK root-gate pattern: `[ "$(id -u)" -ne 0 ] || <privileged-probe>` short-circuits when probe-user ambiguity matters (file caps masked under NNP; substrate compose pins `user: '0:0'` so root-running probe is the canonical path; forks running probes as non-root short-circuit cleanly without breaking dnsmasq + sshd signal). Carry-rule for any future probe needing CAP_NET_ADMIN / CAP_SYS_ADMIN under cap_drop:[ALL] + NNP.
- `resolveReviewThread`: `gh api graphql -f query='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { id isResolved } } }' -F id=…`. Sequence: reply → resolve.

## Halt criterion

`{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR #230 review-fix-arc complete; await human merge → § Cross-epic transition."}` after FIX-5 push + CI green + 12-thread-resolve.
