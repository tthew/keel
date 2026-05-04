# Implementation Plan — PR #230 review-fix-arc (2026-05-04 redirect)

## NOW

- [ ] Monitor PR #230 CI on FIX-3 push — queue fix tasks for any failures; advance to FIX-4 if green.

## QUEUE (Epic 2 PR #230 review-fix-arc; landing-summary `IC_kwDOSAH0488AAAABBMCAuQ`)

- [ ] FIX-4: Substrate↔seed byte-parity in invariants.manifest.ts — pair-link `INV-claude-hook-secret-denylist` ↔ `-seed`; `byte-parity` kind OR pair-check in sync-gate. **L1-protected**. ~medium
- [ ] FIX-5: docker-compose.yml:294-303 healthcheck — append `nft list chain inet keel_egress output_v4` probe; root-gate or sentinel-file fallback. ~small

### RESOLVE-only (8 landed threads — reply + `resolveReviewThread`)

- [ ] Thread-resolve sweep (per-thread closing commit; full IDs prefix `PRRT_kwDOSAH0485…`):
  - rN6F→`27d4c7b` (legacy-branch:128); rN8s→`d3aecde` (ralph-build-host:89)
  - eiOE→`THIS-COMMIT` (hook:178 case-glob refactor); ejlV→`33aca2d` (hook:171); ejoe→`33aca2d` (hook:79-84)
  - eloF→`33aca2d` (dnsmasq:32-53); elpv→`33aca2d` (resolver:153-165)
  - +4 DEFERRED-fix threads same-iter as FIX-N commit lands.

### Final close-out

- [ ] Final pre-push CI gate post FIX-5 → monitor green per § PR Lifecycle.
- [ ] EPIC_DONE halt — note "12 threads addressed; await human merge → § Cross-epic transition".

## DONE (current PR-fix-arc phase)

- [iter-pr230-fix-1] FIX-1 landed: D-38 refactor of L231-237 case-glob arm → bash-regex with token-boundary tolerance (whitespace/quote/paren/path-sep/redirect/backslash-escape). interp_verb_re flag-class widened to `[a-zA-Z0-9]*[ec]` (catches `perl -0ne`). 7-vector fixture suite under positive/ (quoted, chained, trailing-ws, python3-c-stringlit, node-e-stringlit, awk-quoted, bash-c-ansi-c). Substrate + seed byte-parity preserved (manifest hash 8b10e266 → both `INV-claude-hook-secret-denylist` + `-seed`). Fixture suite 81/81 pass; typecheck 16/16; lint 16/16; vitest 52/52.
- [iter-pr230-monitor-fix-1] CI green at `a4c7bad` (4/4 SUCCESS: node x2 ~40s, python x2 ~11s). Local `8b600f4` IP-advance staged for co-push with FIX-2 to avoid CI retrigger (RALPH.md `Monitor-bookkeeping-loop-break`).
- [iter-pr230-fix-2] FIX-2 landed: Bash-arm verb-gated token-scan + per-token `readlink -f` mirroring D-22 Read-arm. Closes `cat /tmp/symlink-to-/home/dev/.claude/x` bypass class. 6 new match-strings under `secret-access-denylist`: `bash-resolved-to-{oauth-token,ssh-key,proc-environ,env-file,envrc-file,secrets-file}`. `[ -L ]` per-token gate keeps cost bounded (typical command 0 hits). Substrate + seed byte-parity preserved (manifest hash `8b10e266 → 8350baf2` in lockstep). New positive fixture `secret-access-denylist-bash-resolved-to-oauth-token.sh` builds /tmp symlink → asserts block. Local edge-probe 13/13: canonical/quoted-double/quoted-single/chained/piped/symlink-to-ssh/symlink-to-env-file all block; `[ -L ]` gate correctly approves broken-symlink + non-symlink-token. Known residual: symlink path inside interpreter-string-literal (`python3 -c "open('$SL').read()"`) — symlink is buried inside script-token, not exposed at top-level; out-of-scope per FIX-2 spec (canonical example was raw `cat /tmp/symlink-to-secret`). Hook fixture suite 82/82; typecheck 16/16; lint 16/16; vitest 52/52.
- [iter-pr230-monitor-fix-2] CI green at `14f875e` (4/4 SUCCESS: node x2 ~45-53s, python x2 ~11-12s). 11 unresolved threads remain (8 landed-ready + 3 deferred-fix pending FIX-3..5). IP-advance staged for co-push with FIX-3 to avoid CI retrigger (RALPH.md `Monitor-bookkeeping-loop-break`).
- [iter-pr230-fix-3] FIX-3 landed: `EXPECTED_INVARIANT_IDS` out-of-band fail-closed snapshot in L1-protected `packages/keel-invariants/src/sync-gate.ts` (43 IDs at landing). Closes drop+anchor-remove bypass class — attacker who drops both the manifest entry AND its INVARIANTS.md anchor in one commit no longer slips through the symmetric for-loops; `expected-id-missing` drift fires. New `DriftKind = 'expected-id-missing'`; check loop in `runSyncGate` after `manifestIds` build. Maintenance contract: legitimate add/remove must touch `EXPECTED_INVARIANT_IDS` in same commit; L1 hook denies in-session AI agent edits, so changes transit human review. Test: dedicated `expected-id-missing` integration case in `__tests__/sync-gate.test.ts` (mocks empty `invariants` array; asserts every snapshot ID surfaces drift). Existing `clean baseline` test relaxed to filter `expected-id-missing` (mocked manifests can't include the real snapshot; canonical drift kinds remain absent assertion is what the test means). Gates: typecheck 16/16, lint 16/16, vitest 53/53 (was 52, +1 dedicated FIX-3 test), `pnpm keel-invariants:check-all` clean against real 43-entry manifest. Sync-gate.ts is NOT itself manifest-tracked, so no contentHash bump required.

## Context

- **Phase:** 4-implementation — PR #230 review-fix-arc (post-closeout redirect 2026-05-04).
- **Epic:** 2 — Sandboxed Execution Environment (devbox). All 18 stories `done`; fix-arc reopened.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (worktree HEAD = PR #230 head).
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent)._
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 Open, MERGEABLE=CLEAN, CI green at `14f875e` pre-FIX-3 push. 10 unresolved threads expected after FIX-3 push lands (`PRRT_kwDOSAH0485_ell8` resolves under FIX-3); 7 deferred close-out + 2 deferred-fix pending FIX-4..5.

### Recipe references

- Sparring-partner discipline: AGENTS.md rule 6 + RALPH.md `iter:pr-review-multi-vector`. Artefacts at `/tmp/pr230_review/<fix-N>_*.md`.
- L1 install-boundary workaround (FIX-3/FIX-4): RALPH.md § Gotchas `install-boundary-protection`.
- `resolveReviewThread`: `gh api graphql -f query='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { id isResolved } } }' -F id=…`. Sequence: reply → resolve.

## Halt criterion

`{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR #230 review-fix-arc complete; await human merge → § Cross-epic transition."}` after FIX-5 push + CI green + 12-thread-resolve.
