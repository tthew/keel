# Implementation Plan — PR #230 Round-3 review-fix-arc

Detail: `.ralph/round3-fix-arc.md` (Round-2 closeout at `.ralph/round2-fix-arc.md`). The IP holds NOW + QUEUE + DONE + Context only.

## NOW

- [ ] **Monitor PR CI** — queue fix tasks for any failures. FIX-13 push `d3c127a` triggered fresh CI run; gate must clear before FIX-14 starts.

## QUEUE (Round-3 fix-arc; pull from `.ralph/round3-fix-arc.md`)
- [ ] **FIX-14** (R3-Inv-I01) — wire `pnpm keel-invariants:check` to BOTH `.pre-commit-config.yaml` (operator-side, ~0.77s) AND `.github/workflows/ci.yml` (CI backstop). Adversarial: drop one ID from `EXPECTED_INVARIANT_IDS` → must fail; mutate `BYTE_PARITY_PAIRS` substrate file → must fail. No L1, no manifest bump. ~small.
- [ ] **FIX-15** (R3-Devbox-D01) — three-leg awk-injection shape gates: (a) case-pattern shape gate on `KEEL_DEVBOX_DNS_UPSTREAM` (mirror FIX-6 REPO_NAME); (b) post-mapfile domain shape gate (closes supply-chain leg); (c) doc note in `docs/invariants/devbox-egress.md` § Threat-model. Adversarial: end-to-end `KEEL_DEVBOX_DNS_UPSTREAM='1.1.1.1\nip daddr 0.0.0.0/0 accept'` injection → FATAL exit. ~medium.
- [ ] **FIX-16** (R3-D02 — OPTIONAL) — doc-drift housekeeping at 4 cross-reference sites in `reload-egress.sh` + `Dockerfile`; replace literal line numbers with file/function-name refs. ~small. Land if budget permits; else defer.
- [ ] **WONTFIX-doc** (R3-H48, R3-H49, R3-D03, R3-D04) — 4 inline `# WONTFIX (PR #230 R3-<id>)` comment blocks acknowledging accepted-residual classes (verb-trailing no-space, base64-decode dynamic analysis limit, sshd defense-in-depth gaps, NET_RAW unused). Substrate↔seed + manifest lockstep on hook anchors. ~small.
- [ ] **Round-3 thread-resolve sweep** — for each Round-3 PR review thread (TBD count post next-tthew-review), reply-with-commit-ref + `resolveReviewThread` mutation via Node-script pattern (RALPH.md `iter:pr-230-closeout` recipe).
- [ ] **Final CI watch + EPIC_DONE halt** — step-0h CI gate clear → write `EPIC_DONE` per `.ralph/round3-fix-arc.md § Halt criterion`.

## DONE (Round-3 only — Round-1+2 archived in git log, RALPH.md `iter:pr-230-fix-1..11` + `iter:pr-230-wontfix-d1d2d3` + `iter:pr-230-thread-resolve-sweep` + `iter:pr-230-epic2-halt`)

- [iter-pr230-round3-decompose] Round-3 (4 HIGH + 1 LOW) decomposed FIX-12..16 + WONTFIX + DEFER-continue
- [iter-pr230-fix-12] FIX-12 (R3-Hook-A) verb-gate left-boundary widening landed via `verb_left_re`/`subshell_left_re` shared vars; +secret_left/right_re backtick admit; +env-dump-bare subshell-narrowed; 23/23 R3-Hook-A flip; 82/82 hook fixtures + 56/56 vitest preserved
- [iter-pr230-fix-12-ci] FIX-12 push `4420c3f` CI monitored GREEN (4/4 checks pass — node × 2, python × 2)
- [iter-pr230-fix-13] FIX-13 (R3-Hook-B + sub-agent C1/C2/C3/C4 broadening) landed; reader_verb_re widened 14→50 verbs, dotsource_re added (asymmetric verb_left_re/subshell_left_re for FP avoidance), wrapper-strip extended `eval` arm to also strip `builtin|command|exec`. example_read_re lockstep extension. substrate↔seed byte-parity + manifest contentHash lockstep substrate L370 + seed L407 (`27cfc8a9…` → `d6b5c6be…`). 77/77 adversarial pass + 82/82 hook fixtures + 56/56 vitest + typecheck + lint green

## Context

- **Phase:** 4-implementation — PR #230 Round-3 review-fix-arc IN-PROGRESS (Round-1 + Round-2 landed; Round-3 decomposed this iter, fix iters next).
- **Epic:** 2 — Sandboxed Execution Environment. All 18 stories `done` in sprint-status.yaml; PR #230 OPEN/CLEAN/MERGEABLE awaiting Round-3 fixes + final CI + merge.
- **Epic Branch:** `feat/epic-2-packaged-devbox`.
- **Story:** _(none — PR-fix-arc bypasses § Story Lifecycle per landing-summary intent.)_
- **Story File:** _(n/a)._
- **Story State:** _(no story)._
- **PR:** #230 OPEN, isDraft=false; HEAD post-FIX-13 ready-to-push; CI 4/4 GREEN at FIX-12. Live unresolved-thread count: 2 at decompose time (A5, A6 DEFER-by-design); Round-3 NEW threads will land when next reviewer pass posts (or could be self-posted as R3-self-review summary comment per Round-2 pattern at `iter:pr-230-round2-decompose`).
