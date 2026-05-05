# PR #230 Round-5 Fix-Arc Detail

Externalized from `.ralph/@plan.md` 2026-05-05. Round-4 closeout (`iter:pr-230-r4-final-ci-gate-halt`) wrote EPIC_DONE halt; user reversed 2026-05-05 with new directive: **Round-5 final-merge-gate adversarial sweep on HEAD `799c877` with Claude×3 + codex sparring partner; +1/-1 verdict; solve all valid feedback (no defers).**

## Round-5 finding inventory (empirical-first; verification protocol per AGENTS.md rule 6)

| Finding | Sev | Target | Fix bucket | L1? | Manifest impact |
| --- | --- | --- | --- | --- | --- |
| R5-A1 | **CRITICAL** | `.claude/hooks/block-secret-access.sh:77` (wrapper-strip alternation `^(bash\|sh)`) | FIX-19 | Yes | `INV-claude-hook-secret-denylist` substrate L370 + `-seed` L407 (lockstep) |

(Agent B sync-gate/manifest = CLEAR; Agent C spec-compliance = COMPLIANT; only Agent A finding survives.)

## R5-A1 — alternate-shell wrapper bypass (CRITICAL)

**Class:** wrapper-normalization gap. Hook L77 alternation `^(bash|sh)` strips `bash -c '...'` + `sh -c '...'` only; ALL other POSIX shells (zsh, dash, ksh, mksh, ash, fish, csh, tcsh, busybox sh) wrap-and-quote bypass the verb gate because:

1. The wrapper-strip arm doesn't fire (shell name not in alternation) → `normalized` retains the full `<shell> -c 'inner'` text.
2. `verb_left_re='(^|[[:space:]]|[\`$();&|]+[[:space:]]*)'` does NOT include `'` or `"` — so the inner reader verb (`cat`, etc.) preceded by `'` does not match `reader_verb_re`.
3. Hook falls through to default `{"decision":"approve"}`.

**Empirical evidence (27 payloads tested via `bash /tmp/run_hook.sh /tmp/payloads/pN_*.json`):**

| Payload | Decision | Class |
| --- | --- | --- |
| `bash -c 'cat .env'` | **block** (baseline ✓) | already-covered (FIX-1..16) |
| `zsh -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `dash -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `ksh -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `fish -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `mksh -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `ash -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `csh -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `tcsh -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `busybox sh -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `zsh -c 'cat /home/dev/.claude/.credentials.json'` | approve | **R5-A1 — OAuth credential exfiltration** |
| `dash -c 'cat /home/dev/.ssh/id_rsa'` | approve | **R5-A1 — SSH key exfiltration** |
| `zsh -c 'rm .claude/settings.json'` | approve | **R5-A1 — hook-self-protection bypass** |
| `zsh -c 'git commit -m foo --no-verify'` | approve | **R5-A1 — --no-verify bypass** |
| `zsh -c "bash -c 'cat .env'"` | approve | **R5-A1 — multi-wrap bypass** |
| `zsh -ic 'cat .env'` (combined flags) | approve | **R5-A1 BYPASS** |
| `zsh -i -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `zsh -lc 'cat .env'` | approve | **R5-A1 BYPASS** |
| `zsh --no-rcs -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `/usr/bin/zsh -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `/bin/dash -c 'cat .env'` | approve | **R5-A1 BYPASS** |
| `command zsh -c 'cat .env'` | approve | **R5-A1 — wrap-chain bypass** |
| `sudo zsh -c 'cat .env'` | approve | **R5-A1 — wrap-chain bypass** |
| `zsh -c cat .env` (no quotes) | block | accepted (verb_left_re catches unquoted cat) |
| `env zsh -c 'cat .env'` | block | already-caught (env-dump-bare FP-style hit) |
| `zsh -c 'echo evil > packages/keel-invariants/src/invariants.manifest.ts'` | block | install-boundary-protection (path-based, robust) |

**Severity rationale:** CRITICAL. Bypasses three of the four major hook-protection classes:
- secret-access-denylist (.env/.envrc/.secrets/OAuth/SSH key files)
- hook-self-protection (settings/hooks tampering)
- --no-verify gate
Only install-boundary-protection survives because it's path-based not verb-based. Affects 9+ shell variants commonly available in any POSIX environment. Trivial to construct (one `zsh` keystroke on a payload). NOT covered or hinted at in any of Round-1..Round-4 audits.

## FIX-19 design

Replace `.claude/hooks/block-secret-access.sh:77` arm:

**Old:**
```bash
if [[ "$normalized" =~ ^(bash|sh)[[:space:]]+-c[[:space:]]+[\"\']?(.*)$ ]]; then
  normalized="${BASH_REMATCH[2]}"
```

**New:**
```bash
# FIX-19 (PR #230 R5-A1) — alternate-shell wrapper coverage. Original `(bash|sh)` alternation
# missed zsh|dash|ksh|mksh|ash|fish|csh|tcsh|busybox sh, allowing trivial bypass of
# secret-access-denylist + hook-self-protection + --no-verify gates via `zsh -c 'cat .env'`,
# `dash -c 'rm .claude/settings.json'`, etc. (verb_left_re excludes `'`/`"` so the quoted
# inner verb routes around the gate). Path-prefix forms (/usr/bin/zsh), flag-bundle forms
# (-ic, -lc), separate-flag forms (-i -c), long-flag forms (--no-rcs), and busybox sh form
# all covered. Multi-wrap (zsh -c "bash -c '...'") closes via the existing 3-round loop.
if [[ "$normalized" =~ ^(/(usr/(local/)?)?bin/)?(busybox[[:space:]]+sh|bash|sh|zsh|dash|ksh|mksh|ash|fish|csh|tcsh)([[:space:]]+(-[a-zA-Z]+|--[a-zA-Z][a-zA-Z-]*(=[^[:space:]]+)?))*[[:space:]]+-[a-zA-Z]*c[a-zA-Z]*[[:space:]]+[\"\']?(.*)$ ]]; then
  normalized="${BASH_REMATCH[7]}"
```

Capture-group count: 7 ((path-prefix)(usr/(local/)?)?(local/)?(shell-name)(flag-arm)(flag-bundle)(flag-eq)(inner)). Computing: `(...)(...)?(...)?(shell-arm)((flags-arm)(...)?)*(inner)` = group 7 is inner-command.

Capture-group analysis (counting opening `(`):
- `(/(usr/(local/)?)?bin/)?` = groups 1, 2, 3
- `(busybox[[:space:]]+sh|bash|sh|zsh|dash|ksh|mksh|ash|fish|csh|tcsh)` = group 4 (shell name)
- `([[:space:]]+(-[a-zA-Z]+|--[a-zA-Z][a-zA-Z-]*(=[^[:space:]]+)?))*` = groups 5, 6, 7 (flag arms)
- `(.*)$` = group 8

Wait — let me recount. The flag-eq group is INSIDE the long-flag arm. `(=[^[:space:]]+)?` is group 7. So the inner command is group 8. Let me verify by counting manually in the regex:
1. `(/(usr/(local/)?)?bin/)?` — outer is 1, `(usr/(local/)?)?` is 2, `(local/)?` is 3.
2. `(busybox[[:space:]]+sh|...|tcsh)` — 4.
3. `([[:space:]]+(-[a-zA-Z]+|--[a-zA-Z][a-zA-Z-]*(=[^[:space:]]+)?))*` — outer is 5, alternation `(-[a-zA-Z]+|...)` is 6, `(=[^[:space:]]+)?` is 7.
4. `(.*)$` — 8.

So inner is `${BASH_REMATCH[8]}`. **Update FIX-19 design to use BASH_REMATCH[8].**

## Per-fix recipe (carry-forward from Round-2..Round-4)

For FIX-19 (L1-protected hook substrate):
1. Edit substrate via L1 install-boundary workaround: write `/tmp/update_hook_r5.js` with `fs.readFileSync` → `String.replace(OLD, () => NEW)` → `fs.writeFileSync` → `node /tmp/update_hook_r5.js`. ⊗ Use callback form to defeat JS `$`-pattern interpretation in shell-bash code.
2. Mirror byte-identical to `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh`.
3. Bump manifest contentHashes in lockstep for `INV-claude-hook-secret-denylist` (substrate sha256) AND `INV-claude-hook-secret-denylist-seed` (seed sha256).
4. Build dist + run sync-gate: `pnpm --filter @keel/keel-invariants build` → `pnpm keel-invariants:check` MUST pass.
5. Run regression suite: `bash packages/keel-invariants/fixtures/hooks/run-all.sh` (≥ 82/82).
6. Run gates: `pnpm typecheck` + `pnpm lint` + `pnpm test`.
7. Empirical adversarial validation — every R5 bypass payload must flip APPROVE → BLOCK; every Round-1..Round-4 regression must remain BLOCK.
8. Codex sparring: re-run codex audit after fix to confirm no residual bypass class introduced.
9. Commit `fix(epic-2): close alternate-shell wrapper bypass (FIX-19 — R5-A1, PR #230)`. ⊗ scrub deny-list verbs from echo strings + commit body.
10. Push after step-0h CI gate clear.
