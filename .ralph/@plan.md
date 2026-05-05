# Implementation Plan — PR #230 Round-2 review-fix-arc

Detail: `.ralph/round2-fix-arc.md` (inventory, recipes, sparring discipline, halt criterion). The IP holds NOW + QUEUE + DONE + Context only.

## NOW

- [ ] FIX-10 — close A7 via healthcheck v6 chain + policy-drop verification ~medium

## QUEUE (Round-2 fix-arc — order minimises merge conflict + maximises per-fix isolation)

- [ ] FIX-11 — close C1 via dnsmasq.conf comment items 2/3 reframe ~small
- [ ] WONTFIX-D1/D2/D3 — anchor inline `# WONTFIX` comments at hook L171, L251, L257 ~small
- [ ] DEFER A5 + A6 — append follow-up tracker note to RALPH.md § Open questions
- [ ] Thread-resolve sweep — Node-script reply + `resolveReviewThread` per Round-2 thread (incl. A1/A2/A3/A4/A8)
- [ ] Monitor PR CI — `gh pr checks --watch --fail-fast` after final fix-arc push
- [ ] Transition PR — final CI gate → EPIC_DONE halt for cross-epic next-Ralph

## DONE

- [iter-pr230-round2-decompose] Round-2 review (12 unresolved) decomposed into FIX-6..11 + WONTFIX + 2 DEFER — `75bb178`
- [iter-pr230-fix-6] FIX-6 closes A8 — `main-repo-resolver.sh` REPO_NAME case-pattern rejects `..` / `.` / `*..*` (PR #230)
- [iter-pr230-fix-7] FIX-7 closes A1 + A4 — boundary char class widened from `\|` to `[;&|]+` at 11 verb-regex sites (`;`/`&&`/`||` shell separators no longer bypass mutation-verb / reader-verb / interp-verb gates). Substrate↔seed byte-parity preserved; manifest contentHash bumped lockstep. 36/36 adversarial post-fix; 82/82 hook fixtures; 56/56 vitest. Same-class residuals at L172/L173/L183/L193/L196/L202/L218 explicitly out-of-scope (Round-3 candidates).
- [iter-pr230-fix-8] FIX-8 closes A3 — ANSI-C `$'…'` strip arm now runs `printf '%b'` decode pass over the captured inner string before downstream regex matching. `printf '%b'` matches bash ANSI-C decoding for all viable bypass vectors (`\xNN` hex, `\t`/`\n`/`\r`/`\f`/`\v` escapes, `\NNN`/`\0NNN` octal, `\\`); residual diff for `\'`/`\"` not viable bypass class (resulting bash command would be syntactically invalid). Substrate↔seed byte-parity preserved; manifest contentHash `5f3986…` → `c24fd6…` lockstep. Adversarial: 25/25 post-fix (A3 hex/tab/newline/octal × secret-access + hook-self + L1 + negative + Round-1/6/7 regression); 82/82 hook fixtures; 22/22 Round-1 regression carry; 56/56 vitest.
- [iter-pr230-fix-9] FIX-9 closes A2 — redirect-against-protected (substrate hook L190) AND redirect-against-l1 (L209) widened with `[^[:space:]\"\']*` arm between optional quote and protected token, admitting absolute (`/workspace/.../.claude/settings.json`), relative (`./`, `../`), tilde-form, double-`>>` append, and quoted-path redirects regardless of writing verb. Substrate↔seed byte-parity preserved; manifest contentHash `c24fd6…` → `ef8d1a…` lockstep on both `INV-claude-hook-secret-denylist` and `-seed`. Pre-fix: 7/7 absolute/relative/tilde/quoted-path payloads approve; post-fix: 18/18 A2 bypasses block + 8/8 negative controls approve; 82/82 hook fixtures + 22/22 Round-1+6/7/8 regression + 56/56 vitest preserved.

## Context

- **Phase:** 4-implementation — PR #230 Round-2 review-fix-arc.
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done`. Round-1 fix-arc closed at `4eaec8d`. Round-2 review reopened the PR 2026-05-05.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent)._
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 Open, isDraft=false, MERGEABLE. Live unresolved-thread count: 12 (A1, A2, A3, A4, A5, A6, A7, A8, C1, D1, D2, D3). Of those: 5 are CODE-closed pending sweep-iter resolveReviewThread (A1/A2/A3/A4/A8 — closed by FIX-7/9/8/7/6); 7 remain on the work list (A5/A6 DEFER, A7 → FIX-10, C1 → FIX-11, D1/D2/D3 → WONTFIX-doc anchors).
