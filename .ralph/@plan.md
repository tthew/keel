# Implementation Plan — PR #230 review-fix-arc (2026-05-04 redirect)

## NOW

- [ ] FIX-1: Refactor hook case-glob arm L231-237 → bash-regex w/ word-boundary + quote-tolerance + interpreter-string-literal scan; 7-vector fixture suite. Verify per-vector via `printf %s "<cmd>" | jq -Rs '{tool_name:"Bash",tool_input:{command:.}}' | .claude/hooks/block-secret-access.sh` BEFORE/AFTER (AGENTS.md rule 6 sparring-verify). ~large

## QUEUE (Epic 2 PR #230 review-fix-arc)

### DEFERRED-fixes (5; landing-summary `IC_kwDOSAH0488AAAABBMCAuQ`)

- [ ] FIX-2: Hook Bash-arm symlink-deref — token-scan + per-token `readlink -f` against secret-dir denylist; fixture `cat /tmp/symlink-to-secret`. ~medium
- [ ] FIX-3: sync-gate.ts manifest-removal — expected-IDs snapshot so dropping entry + INVARIANTS.md anchor fails closed. **L1-protected**. ~medium
- [ ] FIX-4: Substrate↔seed byte-parity in invariants.manifest.ts — pair-link `INV-claude-hook-secret-denylist` ↔ `-seed`; `byte-parity` kind OR pair-check in sync-gate. **L1-protected**. ~medium
- [ ] FIX-5: docker-compose.yml:294-303 healthcheck — append `nft list chain inet keel_egress output_v4` probe; root-gate or sentinel-file fallback. ~small

### RESOLVE-only (7 landed threads — reply + `resolveReviewThread`)

- [ ] Thread-resolve sweep (per-thread closing commit; full IDs prefix `PRRT_kwDOSAH0485…`):
  - rN6F→`27d4c7b` (legacy-branch:128); rN8s→`d3aecde` (ralph-build-host:89)
  - eiOE→`33aca2d` (hook:178); ejlV→`33aca2d` (hook:171); ejoe→`33aca2d` (hook:79-84)
  - eloF→`33aca2d` (dnsmasq:32-53); elpv→`33aca2d` (resolver:153-165)
  - +5 DEFERRED-fix threads same-iter as FIX-N commit lands.

### Final close-out

- [ ] Final pre-push CI gate post FIX-5 → monitor green per § PR Lifecycle.
- [ ] EPIC_DONE halt — note "12 threads addressed; await human merge → § Cross-epic transition".

## DONE (this iteration)

- [iter-pr230-monitor] CI green on `e63a671` (`gh pr checks --watch --fail-fast` exit 0; node 47-52s ×2 + python 8s ×2). 12 unresolved review threads confirmed via GraphQL `reviewThreads` — match IP RESOLVE-only (7) + DEFERRED-fixes (FIX-1..FIX-5).

## Context

- **Phase:** 4-implementation — PR #230 review-fix-arc (post-closeout redirect 2026-05-04).
- **Epic:** 2 — Sandboxed Execution Environment (devbox). All 18 stories `done`; fix-arc reopened.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (worktree HEAD = PR #230 head).
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent)._
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 Open, MERGEABLE=UNSTABLE→CLEAN, CI green at `e63a671` (verified iter-pr230-monitor). 12 unresolved threads (7 landed-but-unresolved, 5 deferred per `IC_kwDOSAH0488AAAABBMCAuQ`).

### Recipe references

- Sparring-partner discipline: AGENTS.md rule 6 + RALPH.md `iter:pr-review-multi-vector`. Artefacts at `/tmp/pr230_review/<fix-N>_*.md`.
- L1 install-boundary workaround (FIX-3/FIX-4): RALPH.md § Gotchas `install-boundary-protection`.
- `resolveReviewThread`: `gh api graphql -f query='mutation($id: ID!) { resolveReviewThread(input: {threadId: $id}) { thread { id isResolved } } }' -F id=…`. Sequence: reply → resolve.

## Halt criterion

`{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR #230 review-fix-arc complete; await human merge → § Cross-epic transition."}` after FIX-5 push + CI green + 12-thread-resolve.
