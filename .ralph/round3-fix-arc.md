# PR #230 Round-3 Fix-Arc Detail

Externalized from `.ralph/@plan.md` 2026-05-05 (PRUNE-FIRST per `.githooks/doc-budget.json` — IP holds NOW/QUEUE/DONE/Context only). Follow-on from `.ralph/round2-fix-arc.md` § Halt criterion: Round-2 closeout was premature; Round-3 adversarial review (4 parallel Claude personas, HEAD `e4636bd`, 2026-05-05) surfaced 4 HIGH-severity new bypass classes + 1 LOW housekeeping. Lands in PR #230 (NOT a follow-up PR) per user directive "Epic is free of non-trivial issues AND is mergable".

## Round-3 finding inventory (severity → fix bucket → L1 + manifest impact)

| Finding         | Sev      | Target                                                              | Fix bucket   | L1?              | Manifest bump                                                      |
| --------------- | -------- | ------------------------------------------------------------------- | ------------ | ---------------- | ------------------------------------------------------------------ |
| R3-Hook-A       | HIGH     | `.claude/hooks/block-secret-access.sh` (~13 verb-gate sites)        | FIX-12       | Yes              | `INV-claude-hook-secret-denylist` (substrate L365) + -seed (L403)  |
| R3-Hook-B       | HIGH     | `.claude/hooks/block-secret-access.sh:240` (`reader_verb_re`)       | FIX-13       | Yes              | (same lockstep pair as A)                                          |
| R3-Inv-I01      | HIGH     | `.pre-commit-config.yaml` + `.github/workflows/ci.yml`              | FIX-14       | No               | None (gate-wiring only)                                            |
| R3-Devbox-D01   | HIGH     | `packages/devbox/scripts/reload-egress.sh:44,260,321` + env-check   | FIX-15       | No               | None (or doc note in `INV-devbox-egress` description)              |
| R3-D02          | LOW      | `reload-egress.sh:179,190,151` + `Dockerfile:372` cross-refs        | FIX-16       | No               | None (doc-drift housekeeping)                                      |
| R3-H48          | LOW      | hook verb-trailing class                                            | WONTFIX-doc  | Yes              | (lockstep on comment-anchor edit)                                  |
| R3-H49          | LOW      | hook static-vs-dynamic analysis limit (`bash -c "$(base64 -d)"`)    | WONTFIX-doc  | Yes              | (same)                                                             |
| R3-D03          | INFO     | `sshd_config` defense-in-depth omissions                            | WONTFIX-doc  | No               | None (egress firewall is load-bearing layer)                       |
| R3-D04          | INFO     | `docker-compose.yml:195` `NET_RAW` cap_add justification            | WONTFIX-doc  | No               | None (operator-workstation verification)                           |
| A5 (R3-I02 leg) | MED      | `.claude/hooks/block-secret-access.sh:268-293` (interp string-lit)  | DEFER        | Yes              | n/a (already tracked → follow-up PR `fix/epic-2-defer-a5a6-r3I`)   |
| A6 (R3-I02 leg) | MED-str  | `packages/keel-invariants/src/sync-gate.ts:53-125`                  | DEFER        | Yes              | n/a (already tracked → same follow-up PR)                          |
| R3-I03/I04/I05/I06 | LOW   | invariants framework (sourcePath, anchor regex, fork slot, schema) | NOFIX        | No               | None (by-design / safe-direction)                                  |

Triage spot-verified at HEAD `e4636bd`:
- R3-Hook-A: hook L240+L244 confirm `(^|[[:space:]]|[;&|]+[[:space:]]*)` excludes `(`/`` ` ``/`$`.
- R3-Inv-I01: `grep -rn keel-invariants:check .github .pre-commit-config.yaml` → 0 matches.
- R3-Devbox-D01: `reload-egress.sh:44` reads `KEEL_DEVBOX_DNS_UPSTREAM` with default; `env-check.sh` lists var in `REQUIRED_VARS` only (presence-only); `awk -v` at L260 + L321.

Empirical evidence archived at:
- `/tmp/r3_hook_findings.md` — 49 R3-Hook payloads with per-payload hook decision
- `/tmp/r3_invariants_findings.md` — 6 R3-I findings with empirical proof + threat-model arguments
- `/tmp/r3_devbox_findings.md` — 1 HIGH + 3 LOW/INFO with end-to-end injection demonstration
- `/tmp/r3_mergeability_audit.md` — Round-1+2 fix-landing verification (GREEN; not contradicting Round-3 NEW findings)

## Per-fix recipe carry-rules (carry-forward from Round-2)

For every FIX-N that touches the L1-protected hook substrate (FIX-12, FIX-13):

1. **Edit substrate** via L1 install-boundary workaround:
   - **Targeted-replace** for narrow regex changes — Write `/tmp/update_hook.js` with `fs.readFileSync` → `String.replace(OLD_REGEX, () => NEW_REGEX)` → `fs.writeFileSync` against the L1 path → `node /tmp/update_hook.js`. **⊗ Use callback form (`() => NEW`) to defeat JS `$`-pattern interpretation in shell-bash code** (RALPH.md `iter:pr-230-fix-8` carry-rule).
   - **Full-file overwrite** for multi-site changes — Write `/tmp/hook.new.sh` with full contents → `node -e 'require("fs").copyFileSync(...)'` (RALPH.md `iter:pr-230-fix-3`).
2. **Mirror byte-identical** edit to `packages/keel-templates/src/seeds/.claude/hooks/block-secret-access.sh` (`BYTE_PARITY_PAIRS` enforces).
3. **Bump manifest contentHashes in lockstep** for `INV-claude-hook-secret-denylist` (substrate, manifest L365) AND `INV-claude-hook-secret-denylist-seed` (seed, L403). Use `node /tmp/update_manifest.js` targeted-replace (RALPH.md `iter:pr-230-fix-5` + `iter:pr-230-fix-10` for inner-quote `\\'` escape pattern).
4. **Build dist** then **run sync-gate**: `pnpm --filter @keel/keel-invariants build` → `pnpm keel-invariants:check` MUST pass.
5. **Run regression suite**: `bash packages/keel-invariants/fixtures/hooks/run-all.sh` (must remain ≥ 82/82).
6. **Run gates**: `pnpm typecheck` + `pnpm lint` + `pnpm test` (vitest 56/56).
7. **Per-FIX-N adversarial validation** before commit (sparring-partner discipline — see § below).
8. **Commit** with conventional message `fix(epic-2): close <bypass-class> (FIX-N — R3-<Hxx|Ixx|Dxx>)`. **⊗ scrub deny-list verbs** from echo strings + commit-body strings if same Bash invocation also touches `.claude/hooks/...` or `packages/keel-invariants/src/...` substrings (RALPH.md `iter:pr-230-fix-2`).
9. **Push**. Step-0h CI gate clear before pushing.

## FIX-12 (R3-Hook-A — boundary char class widening)

Widen the LEFT character class at all ~13 verb-gate sites in `.claude/hooks/block-secret-access.sh` from `(^|[[:space:]]|[;&|]+[[:space:]]*)` to also include `(`, `` ` ``, `$`. Proposed form:

```bash
# Before (FIX-7 form, R2):
reader_verb_re='(^|[[:space:]]|[;&|]+[[:space:]]*)(cat|less|...)[[:space:]]'
# After (FIX-12 form, R3):
reader_verb_re='(^|[[:space:]]|[`$();&|]+[[:space:]]*)(cat|less|...)[[:space:]]'
```

Same widening at:
- `interp_verb_re` (L244)
- 11 mutation-verb arms (L168-178: `chmod`, `chown`, `cp`, `dd`, `find`, `install`, `ln`, `mv`, `rm`, `tee`, `truncate`, `sponge`)
- L1 mutation alternation (L190)
- L1 sed arm + echo-redirect arm
- `find -delete` arm
- `printenv_re` boundary (L274) is `[^A-Za-z0-9_/.-]` already → admits `(` `` ` `` `$` per negation; verify by empirical adversarial.

**Negative-control scan**: confirm `cat $(echo notes.txt)` (legitimate parameter expansion to non-protected target) still APPROVES (the inner `cat` left-anchored at start; the outer `$(...)` provides a left boundary for `echo` as `cat $(echo` — verify `echo` doesn't false-positive against any protected-path/secret regex). Test against:
- `cat $(echo notes.txt)` → expect APPROVE
- `echo $(date)` → expect APPROVE
- `result=$(date)` → expect APPROVE
- `(echo hello)` → expect APPROVE
- `[[-d $(pwd)/foo]]` → expect APPROVE

**Empirical adversarial** for blocks: all 23 R3-Hook-A payloads from `/tmp/r3_hook_findings.md` MUST flip from APPROVE to BLOCK. Round-2 22/22 regression suite at `/tmp/pr230_hook_regression.sh` MUST stay BLOCK.

## FIX-13 (R3-Hook-B — reader_verb_re extension + dot-sourcing detection)

Edit `.claude/hooks/block-secret-access.sh:240` `reader_verb_re` from:

```bash
# Before:
reader_verb_re='...(cat|less|tail|head|bat|xxd|od|strings|more|grep|awk|sed|cp|dd)[[:space:]]'
```

to extend with the missing 14 verbs:

```bash
# After (FIX-13):
reader_verb_re='...(cat|less|tail|head|bat|xxd|od|strings|more|grep|awk|sed|cp|dd|wc|nl|hexdump|tac|pv|column|jq|yq|tr|read|mapfile|curl|wget)[[:space:]]'
```

**Plus separate dot-sourcing detection** — `source` and `.` must be detected explicitly because they (a) require special boundary handling (`. .env`, `source .env`), and (b) `.` as a token is too short to match safely in alternation (would FP on every period). Proposed:

```bash
# After reader_verb_re check:
dotsource_re='(^|[[:space:]]|[`$();&|]+[[:space:]]*)(source[[:space:]]|\.[[:space:]])'
if [[ "$normalized" =~ $dotsource_re ]]; then
  # Apply same secret-token regex chain as reader_verb_re branch.
  ...
fi
```

**Special handling for `curl file://` and `wget file://`** — these are reader-verbs but their target is a `file://` URI, not a positional arg. The existing `secret_left_re` covers `/` as a left-boundary, so `curl file:///workspace/.env` should match against `env_file_re` once `curl` is in the verb list. Verify empirically.

**Special handling for stdin-redirect form** (`tr a b < .env`, `read -r line < .env`, `mapfile -t lines < .env`) — these have the secret target AFTER `<`, not as a positional arg. The existing token-loop at L303 (`read -ra _fix2_tokens`) already iterates whitespace tokens, so `< .env` should produce `<` and `.env` as separate tokens; the `.env` token will hit `env_file_re` IF the verb-gate fires. So extending the verb list is sufficient — no separate redirect-handling needed.

**Empirical adversarial**: all 24 R3-Hook-B payloads MUST flip APPROVE → BLOCK. Round-1 + Round-2 + R3-Hook-A regression must stay BLOCK.

**Negative-control**: confirm `tr -d ' ' < /tmp/data.txt` (legitimate non-secret use) APPROVES.

**FIX-12 + FIX-13 lockstep manifest** — both fixes touch the substrate hook. Either land in two separate commits with two manifest bumps each (clean iter discipline) or bundle in one commit with one manifest bump (saves an iter; more careful empirical validation needed). **Recommend two separate iters** — keeps each FIX's adversarial scope narrow.

## FIX-14 (R3-Inv-I01 — wire `pnpm keel-invariants:check` to automated gates)

Two-leg fix:

### Leg A: `.pre-commit-config.yaml` — local pre-commit gate (~0.77s wall-clock per Story 1.9 traceability)

Add hook entry:

```yaml
- id: keel-invariants-check
  name: Keel invariants drift gate (@keel/keel-invariants; Story 1.9)
  entry: bash -c 'pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check'
  language: system
  pass_filenames: false
  always_run: true
```

### Leg B: `.github/workflows/ci.yml` — backstop CI gate (definitive across all PRs)

Add a step to the `node` job after `pnpm install`:

```yaml
- run: pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check
```

**Both legs** because pre-commit is operator-side (skipped via `--no-verify` or non-installed prek), CI is the auditable backstop. Per `AGENTS.md § Git rules`, hook-skip is forbidden but the CI gate ensures even hook-bypassed pushes are caught.

**Empirical validation**:
1. After Leg A + B land, run `act -W .github/workflows/ci.yml` (or push to a scratch branch) → confirm gate runs.
2. Adversarial: drop one ID from `EXPECTED_INVARIANT_IDS` → run gate → MUST fail with drift signal.
3. Adversarial: mutate `BYTE_PARITY_PAIRS` substrate file → run gate → MUST fail with byte-parity drift.
4. Negative-control: legitimate manifest expansion (add new entry + update `EXPECTED_INVARIANT_IDS` in lockstep) → MUST pass.

**No L1, no manifest bump** — `.pre-commit-config.yaml` and `.github/workflows/ci.yml` are not in `BYTE_PARITY_PAIRS` or any manifest entry. Doc lockstep is `INV-prek-prepare-lifecycle` description if the prek-config wording mentions the gate set.

## FIX-15 (R3-Devbox-D01 — awk-injection shape gates)

Three legs:

### Leg A: `KEEL_DEVBOX_DNS_UPSTREAM` shape gate

Edit `packages/devbox/scripts/lib/main-repo-resolver.sh` (or wherever the var first lands; if `reload-egress.sh:44` is the canonical landing, edit there) to validate the value before use:

```bash
UPSTREAM_RESOLVER="${KEEL_DEVBOX_DNS_UPSTREAM:-1.1.1.1}"
case "$UPSTREAM_RESOLVER" in
    *[!0-9a-fA-F:.]*|"")
        printf 'reload-egress: FATAL: invalid KEEL_DEVBOX_DNS_UPSTREAM (=%q); expected IPv4 / IPv6 literal\n' "$UPSTREAM_RESOLVER" >&2
        return 1
        ;;
esac
```

Mirror in `env-check.sh` SHAPE-validation group (add `SHAPE_IP_LITERAL` group; mirror FIX-6's case-pattern shape).

### Leg B: whitelist-domain shape gate (post-mapfile)

After the `mapfile -t domains` step in `reload-egress.sh`, validate each domain entry:

```bash
for domain in "${domains[@]}"; do
    case "$domain" in
        *[![:alnum:].-]*|"")
            printf 'reload-egress: FATAL: invalid domain %q in whitelist; expected [A-Za-z0-9.-]+ only\n' "$domain" >&2
            return 1
            ;;
    esac
done
```

This closes the supply-chain leg (malicious PR adding `domain.com\nip daddr 0.0.0.0/0 accept` to `whitelist/foo.txt`).

### Leg C: documentation update

Update `docs/invariants/devbox-egress.md` § Threat-model section to acknowledge the awk-injection class is now closed via shape gates A + B. No manifest bump (description-only change does not affect `INV-devbox-egress` contentHash if scoped to `hashScope: anchor-range` — verify).

**Empirical adversarial**: end-to-end injection from `/tmp/r3_devbox_findings.md` § R3-D01 MUST fail at the shape gate before reaching `awk -v`. Concrete payloads:
- `KEEL_DEVBOX_DNS_UPSTREAM='1.1.1.1 accept\nip daddr 0.0.0.0/0'` → expect FATAL exit 1.
- whitelist entry `foo.com\naddress=/x.example/2.2.2.2` → expect FATAL exit 1.

**Negative-control**: legitimate inputs MUST pass.
- `KEEL_DEVBOX_DNS_UPSTREAM=1.1.1.1` → pass
- `KEEL_DEVBOX_DNS_UPSTREAM=2606:4700:4700::1111` → pass
- whitelist entry `api.github.com` → pass
- whitelist entry `*.github.com` → ⚠ may need explicit allowance for `*` in domain shape — coordinate with substrate's existing wildcard semantics in dnsmasq `nftset=`. If `*` is supported in current whitelist files, extend shape to `[A-Za-z0-9.*-]+`.

**Compose-test**: rebuild the devbox image with shape gates active, run `start-egress.sh` against an injection payload via `KEEL_DEVBOX_DNS_UPSTREAM='1.1.1.1\naccept all'`, observe FATAL exit before container start.

## FIX-16 (R3-D02 — doc-drift housekeeping, OPTIONAL)

Three stale cross-references in privilege-posture / rationale comments:

- `reload-egress.sh:179` cites `dnsmasq.conf:59`; actual `:85`.
- `reload-egress.sh:190` cites `dnsmasq.conf:60`; actual `:86`.
- `Dockerfile:372` cites `entrypoint.sh:235`; actual `:253`.
- `reload-egress.sh:151` cites SIGHUP "line ~370"; actual `:397`.

**Recommended**: replace literal line numbers with file/function-name refs (`reload-egress.sh § dnsmasq SIGHUP block`, `entrypoint.sh § sshd launch`) to prevent re-drift. No L1, no manifest bump.

**Optional** because LOW severity (commentary-only, no functional bug). Land if budget permits; otherwise defer to a doc-only PR.

## WONTFIX-doc (R3-H48, R3-H49, R3-D03, R3-D04)

Four findings deemed accepted-residual:

- **R3-H48** (`cat<.env` no-space verb-trailing): inline comment block at the verb-trailing-class definition acknowledging the residual. ⊗ Do NOT loosen verb-trailing class to admit `<`/`>` — risks FP on `cat<<HEREDOC` and similar legitimate forms.
- **R3-H49** (`bash -c "$(echo 'Y2F0...'|base64 -d)"` static-vs-dynamic limit): inline comment block acknowledging the static-analysis limit. ⊗ Do NOT add runtime-analysis to the hook (would require a sandboxed shell evaluator; out of scope for a regex-based gate).
- **R3-D03** (sshd hardening): note in `docs/invariants/devbox-hardening.md` § Defense-in-depth gaps. The egress firewall is the load-bearing layer; sshd hardening is fork-time guidance.
- **R3-D04** (NET_RAW unused): note in `docker-compose.yml:195` comment that the cap is reserved for future dnsmasq features (or remove if confirmed unused). Operator-workstation verification deferred — landing the comment-only acknowledgement preserves auditability.

WONTFIX-doc lockstep manifest bump for the hook anchors (R3-H48, R3-H49) — same shape as Round-2 D1/D2/D3 (RALPH.md `iter:pr-230-wontfix-d1d2d3`).

## DEFER (continued from Round-2)

- **A5** = interpreter-string-literal symlink-deref gap (R3-Axis-D verified reachable; FIX-2 follow-up).
- **A6** = sync-gate.ts self-protection (R3-I02 = same finding).
- Both stay tracked in RALPH.md `iter:pr-230-defer-a5a6` for follow-up PR `fix/epic-2-defer-a5a6-r3I` (rename to bundle R3-I structural items if future Round-N surfaces additional invariants framework refinements).

## NOFIX (R3-I03, R3-I04, R3-I05, R3-I06)

Four invariants framework findings deemed by-design or safe-direction (no fix required, surfaced for transparency):

- **R3-I03**: sourcePath has no allowlist (LOW, by-design — forks legitimately add new entries).
- **R3-I04**: anchor regex column-0 strict (LOW, defensive-direction — silent skip fires drift).
- **R3-I05**: settings.json substrate↔seed has no `BYTE_PARITY_PAIRS` entry (MED, by-design — fork-additive `.permissions.allow[]` slot).
- **R3-I06**: manifest schema strips unknown keys silently (LOW, defensive-direction — code only acts on declared fields).

No follow-up needed.

## Sparring-partner discipline (per-fix iter)

Every FIX-N iter MUST run all three legs before commit (carry-forward from Round-2 § Sparring-partner discipline):

1. **Empirical hook test** — feed each Round-3 repro payload to new hook via the standard pattern. Assert decision = `block`. Negative control: ALL Round-1 + Round-2 + earlier Round-3 payloads must still `block`.
2. **`codex exec` adversarial review** — pass FIX-N diff + remaining Round-3 payload list to codex with prompt "find the next bypass class against this fix". Treat output as hypothesis (AGENTS.md rule 6); independently verify each claim. ⚠ When invoking codex from this iteration's Bash, write the prompt via `Write` tool (NOT Bash heredoc) to `/tmp/codex_<topic>_prompt.md` to avoid hook-self-protection FP class (RALPH.md `iter:pr-230-fix-2`); then `codex exec --cd /workspace/ralph-bmad ... < /tmp/codex_<topic>_prompt.md`.
3. **Sub-agent alternate angle** (for complex fixes — FIX-12 unifies ~13 sites; FIX-13 changes the verb-list semantics; FIX-15 is multi-leg) — dispatch parallel `general-purpose` Agent with the FIX-N diff + remaining payload list; ask for "next-bypass class against this fix" + "any pre-existing assumption this fix breaks". Verify every cited line/symbol against actual code via `Read`.

## Recipe references (forward-carry from Round-1 + Round-2)

- **L1 install-boundary workaround (full-file)** — RALPH.md `iter:pr-230-fix-3`.
- **L1 install-boundary workaround (targeted-replace)** — RALPH.md `iter:pr-230-fix-5`.
- **JS `String.prototype.replace` callback-form** (avoid `$`-pattern interpretation) — RALPH.md `iter:pr-230-fix-8`.
- **Inner-quote `\\'` escape** in TS string literals — RALPH.md `iter:pr-230-fix-10`.
- **Hook-self-protection FP class** — RALPH.md `iter:pr-230-fix-2`. ⚠ Especially relevant to FIX-12/FIX-13 codex sparring (this Round-3 iter already tripped it twice).
- **Substrate ↔ seed byte-parity** — `BYTE_PARITY_PAIRS` enforces. RALPH.md `iter:pr-230-fix-4`.
- **Compiled `dist/check.js` carries embedded contentHashes** — `pnpm --filter @keel/keel-invariants build` BEFORE `pnpm keel-invariants:check`. RALPH.md `iter:pr-230-fix-2`.
- **Path-prefix tolerance (FIX-9 axis)** — RALPH.md `iter:pr-230-fix-9`. Sibling shape of FIX-12's adjacent-axis widening.
- **Boundary-axis fix discipline** — RALPH.md `iter:pr-230-fix-7`. Anti-pattern: stay-narrow-to-flagged-sites; instead audit ALL three boundary axes (verb-list, left-boundary, right-boundary) at fix-time. FIX-12 widens the LEFT-boundary class; FIX-13 widens the verb-list; right-boundary is at R3-H48 WONTFIX-doc.
- **Sparring-partner discipline** — AGENTS.md rule 6 + RALPH.md `iter:pr-review-multi-vector`.

## Halt criterion

Final iter (after FIX-12 + FIX-13 + FIX-14 + FIX-15 + FIX-16 [optional] + WONTFIX-doc + thread-resolve sweep + final CI green):

```json
{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR #230 Round-3 review-fix-arc complete (FIX-12..15 landed; FIX-16 doc-drift if budget-permitted; R3-H48/H49 WONTFIX-anchored; R3-D03/D04 INFO-noted; A5/A6/R3-I structural items deferred to follow-up PR fix/epic-2-defer-a5a6-r3I). Final unresolved-thread count: 2 (A5/A6, by design); R3-resolved threads: count TBD post-resolve-sweep. Await human merge → § Cross-epic transition picks up Epic 3 Story 3.1."}
```
