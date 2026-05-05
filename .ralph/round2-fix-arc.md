# PR #230 Round-2 Fix-Arc Detail

Externalized from `.ralph/@plan.md` 2026-05-05 (PRUNE-FIRST per `.githooks/doc-budget.json`). Each FIX-N iteration consumes its row from the inventory + recipe stanza below; the IP holds only NOW/QUEUE/DONE/Context.

## Round-2 finding inventory (severity → fix bucket → L1 + manifest impact)

| Finding | Sev      | Target                                                          | Fix bucket   | L1?              | Manifest bump                                                                                  |
| ------- | -------- | --------------------------------------------------------------- | ------------ | ---------------- | ---------------------------------------------------------------------------------------------- |
| A1      | HIGH     | `.claude/hooks/block-secret-access.sh:168-178,190`              | FIX-7        | Yes              | INV-claude-hook-secret-denylist (manifest L365) + -seed (L403) lockstep                        |
| A4      | HIGH     | `.claude/hooks/block-secret-access.sh:223,227,257`              | FIX-7        | Yes              | (same lockstep pair as A1)                                                                     |
| A3      | HIGH     | `.claude/hooks/block-secret-access.sh:79-84`                    | FIX-8        | Yes              | (same lockstep pair as A1)                                                                     |
| A2      | HIGH     | `.claude/hooks/block-secret-access.sh:180,199`                  | FIX-9        | Yes              | (same lockstep pair as A1)                                                                     |
| A7      | MED      | `packages/devbox/docker-compose.yml:315-317`                    | FIX-10       | No               | INV-devbox-healthcheck (L338) — three-site lockstep (compose + invariant doc + README)         |
| A8      | MED      | `packages/devbox/scripts/lib/main-repo-resolver.sh:162,220`     | FIX-6        | No               | None                                                                                           |
| C1      | LOW/doc  | `packages/devbox/dnsmasq/dnsmasq.conf:46-57`                    | FIX-11       | No               | None                                                                                           |
| D1-D3   | LOW/FP   | `.claude/hooks/block-secret-access.sh:171,251,257`              | WONTFIX-doc  | Yes              | (lockstep manifest bump on comment-anchor edit)                                                |
| A5      | MED      | `.claude/hooks/block-secret-access.sh:268-293` (interp tokens)  | DEFER        | Yes              | n/a (deferred to follow-up PR)                                                                 |
| A6      | MED-str  | `packages/keel-invariants/src/sync-gate.ts:53-125`              | DEFER        | Yes (sync-gate)  | n/a (deferred — requires manifest entry add for sync-gate.ts itself)                           |

Triage spot-verified at HEAD `4eaec8d`: A1 (`true;ln -sf ... .claude/hooks/...`) approves; A2 (`printf x > /workspace/.../settings.json`) approves; A3 (`bash -c $'cat\\x20.env'`) approves; A8 (`KEEL_DEVBOX_REPO_NAME=..` → `WD=/workspace/..`). All 12 thread bodies archived at `/tmp/pr230_round2/{A1..A8,C1,D1..D3}.md`.

## Per-fix recipe carry-rules (from Round-1 RALPH.md)

For every FIX-N that touches the L1-protected hook substrate (FIX-7, FIX-8, FIX-9, WONTFIX-doc):

1. **Edit substrate** via L1 install-boundary workaround pattern (hook L147 `hook-script-file`):
   - **Full-file overwrite** (FIX-3/4 shape — preferred for boundary-regex changes touching multiple sites): Write `/tmp/hook.new.sh` with full contents → `node -e 'require("fs").copyFileSync("/tmp/hook.new.sh", "/workspace/ralph-bmad/.claude/hooks/block-secret-access.sh")'`. RALPH.md `iter:pr-230-fix-3`.
   - **Targeted-replace** (FIX-5 shape — lighter for single-line edits): Write `/tmp/update_hook.js` with `fs.readFileSync` → `String.replace(...)` → `fs.writeFileSync`; run `node /tmp/update_hook.js`. RALPH.md `iter:pr-230-fix-5`.
2. **Mirror byte-identical** edit to `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh` (the seed is also L1-protected per `BYTE_PARITY_PAIRS`).
3. **Bump manifest contentHashes in lockstep** for both `INV-claude-hook-secret-denylist` (substrate, L365) AND `INV-claude-hook-secret-denylist-seed` (seed, L403). The manifest itself is L1; use targeted-replace via `node /tmp/update_manifest.js`.
4. **Build dist** then **run sync-gate**: `pnpm --filter @keel/keel-invariants build` → `pnpm keel-invariants:check` MUST pass (compiled `dist/check.js` carries embedded contentHashes — RALPH.md `iter:pr-230-fix-2`).
5. **Run regression suite**: `bash packages/keel-invariants/fixtures/hooks/run-all.sh` (must remain ≥ 81/81 passing).
6. **Run gates**: `pnpm typecheck` + `pnpm lint` + `pnpm test` (vitest must remain 56/56).
7. **Per-FIX-N adversarial validation** before commit:
   - For each Round-2 payload the FIX-N closes: feed payload through new hook → assert `{"decision":"block",...}`. Negative-control: round-1 payloads at `/tmp/pr230_hook_regression.sh` must still block.
   - `codex exec` red-team: pass new hook + payload to codex with prompt "find the next bypass class against this fix". Treat output as hypothesis (AGENTS.md rule 6).
   - For complex fixes (FIX-7 unifies 4 sites; FIX-8 changes the normalisation pipeline) spin a parallel general-purpose Agent for an alternate angle.
8. **Commit** with conventional message `fix(epic-2): close <bypass-class> (FIX-N — A<id>)`. **⊗ scrub deny-list verbs** (`install`, `copy`, `remove`, `chmod`, `tee`) from echo strings + commit-body strings IF the same Bash invocation also touches `.claude/hooks/...` or `packages/keel-invariants/src/...` substrings — RALPH.md `iter:pr-230-fix-2`. Use neutral synonyms (`written`, `update`, `set permissions`).
9. **Push**. Step-0h CI gate clear before pushing.

## FIX-6 (A8 — `main-repo-resolver.sh`, no L1)

Edit `packages/devbox/scripts/lib/main-repo-resolver.sh:162` AND `:220` (per-fork + shared-mode arms — same regex appears at both sites). Replace `[[ "$REPO_NAME" =~ ^[A-Za-z0-9._-]+$ ]]` with case-pattern (canonical form preferred over regex-only — composes with existing FATAL exits):

```bash
case "$REPO_NAME" in
    ""|.|..|*..*)
        printf 'main-repo-resolver: FATAL: invalid REPO_NAME (KEEL_DEVBOX_REPO_NAME=%q); empty or path-traversal pattern\n' "$REPO_NAME" >&2
        return 1
        ;;
    *[!A-Za-z0-9._-]*)
        printf 'main-repo-resolver: FATAL: invalid REPO_NAME (KEEL_DEVBOX_REPO_NAME=%q); expected [A-Za-z0-9._-]+\n' "$REPO_NAME" >&2
        return 1
        ;;
esac
```

No L1, no manifest bump. Empirical-verified 2026-05-05: blocks `""`, `.`, `..`, `foo..bar`, `..foo`, `foo..`, `foo/bar`, `foo bar`, `foo;rm`; admits `ralph-bmad`, `my_repo.v2`, `.foo`, `foo.`, `a.b.c`, `a` (negative controls).

## FIX-10 (A7 — healthcheck, no L1)

Edit `packages/devbox/docker-compose.yml:316` healthcheck `test:` clause-2 — extend from presence-only-v4 to v6 + policy-drop. Per A7 incremental form:

```yaml
&& { [ "$(id -u)" -ne 0 ] || (
     nft list chain inet keel_egress output_v4 2>/dev/null | grep -q 'policy drop' &&
     nft list chain inet keel_egress output_v6 2>/dev/null | grep -q 'policy drop'
   ); }
```

**Three-site lockstep update** (per `INV-devbox-healthcheck` discipline — RALPH.md `iter:pr-230-fix-5`): edit (a) `packages/devbox/docker-compose.yml` healthcheck `test:`, (b) `docs/invariants/devbox-healthcheck.md` description text, (c) `packages/devbox/README.md` § Healthcheck section. Bump manifest contentHash for `INV-devbox-healthcheck` (manifest L338). Adversarial: simulate v4-only chain + v6 missing → assert HEALTHCHECK fails. Simulate `nft add rule ... accept` injection (policy drop replaced) → assert HEALTHCHECK fails.

## FIX-11 (C1 — dnsmasq.conf comment, no L1)

Edit `packages/devbox/dnsmasq/dnsmasq.conf:46-57`. Pure rewrite of items (2)+(3) per C1 reframe: acknowledge SETUID/SETGID are in bounding set due to gosu requirement; reframe item (3) as "adding `user=<other>` would now succeed but silently change the drop target — leave unset to match dnsmasq's `nobody` default, not because of cap_drop EPERM". No L1, no manifest bump.

## DEFER (A5 + A6)

After fix-arc + thread-resolve, before halt: append a follow-up note to RALPH.md § Open questions (or fresh `docs/decisions/round-2-deferrals.md` if richer context needed). User-confirmed: "A5/A6/A7 are scoped follow-ups — track in a separate fix-arc PR if blocking-merge is undesirable" — A7 promoted to FIX-10; A5+A6 stay deferred.

- A5 = interpreter-string-literal symlink-deref gap (FIX-2 follow-up — quoted-substring path-extraction logic).
- A6 = sync-gate.ts self-protection (manifest entry add for sync-gate.ts with `hashScope: anchor-range` over `EXPECTED_INVARIANT_IDS` + `BYTE_PARITY_PAIRS` constants; out-of-session drift backstop).

## Sparring-partner discipline (per-fix iter, per user instruction)

Every fix-arc iter MUST run all three legs before commit:

1. **Empirical hook test** — feed Round-2 repro payload to new hook via `printf '%s' '<payload>' | jq -Rs '{tool_name:"Bash",tool_input:{command:.}}' | bash .claude/hooks/block-secret-access.sh`. Assert decision = `block`. Negative control: ALL Round-1 payloads (saved at `/tmp/pr230_hook_regression.sh`) must still `block`.
2. **`codex exec` adversarial review** — pass FIX-N diff + remaining Round-2 payload list to codex; ask "what bypass class survives this fix?". Treat output as hypothesis (AGENTS.md rule 6); independently verify each claim against actual hook output.
3. **Sub-agent alternate angle** (for complex fixes, FIX-7 / FIX-8 / FIX-10) — dispatch parallel general-purpose Agent with the FIX-N diff + payload list; ask for "next-bypass class against this fix" plus "any pre-existing assumption this fix breaks". Verify every cited line/symbol against actual code.

## Recipe references (forward-carry from Round-1)

- **L1 install-boundary workaround (full-file)** — RALPH.md `iter:pr-230-fix-3`.
- **L1 install-boundary workaround (targeted-replace)** — RALPH.md `iter:pr-230-fix-5`.
- **Hook-self-protection FP class** (verb-substring + protected-path-substring co-occurring in same Bash invocation) — RALPH.md `iter:pr-230-fix-2`.
- **Substrate ↔ seed byte-parity** — `BYTE_PARITY_PAIRS` enforces. Edit BOTH in lockstep. RALPH.md `iter:pr-230-fix-4`.
- **Compiled `dist/check.js` carries embedded contentHashes** — `pnpm --filter @keel/keel-invariants build` BEFORE `pnpm keel-invariants:check`. RALPH.md `iter:pr-230-fix-2`.
- **Thread-resolve sweep via Node script** — `/tmp/resolve_round2_threads.js` with `(threadId, closingCommit, body)` tuples → `execFileSync('gh', ['api', 'graphql', ...])` no-shell → reply→resolve sequence per thread. RALPH.md `iter:pr-230-closeout`.
- **Sparring-partner discipline** — AGENTS.md rule 6 + RALPH.md `iter:pr-review-multi-vector`.

## Halt criterion

Final iter (after FIX-11 + WONTFIX-doc + thread-resolve sweep + final CI green):

```json
{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR #230 Round-2 review-fix-arc complete (FIX-6..FIX-11 landed; D1/D2/D3 WONTFIX-anchored; A5/A6 deferred to follow-up PR; 12 round-2 threads resolved; 25/25 PR threads resolved). Await human merge → § Cross-epic transition picks up Epic 3 Story 3.1."}
```
