# `block-secret-access.sh` replay fixtures (Story 2.17 Task 15.1)

Persisted impl-time smokes for the Claude Code PreToolUse hook at
`.claude/hooks/block-secret-access.sh` (Story 2.16 substrate + Story 2.17 Task 7/8/10
extensions). Each fixture is a self-contained bash script that crafts a single
PreToolUse payload, pipes it into the hook, and asserts `.decision` / `.reason` /
`.match`. Future-Ralph re-exercises the hook via `run-all.sh` without re-authoring
probe scripts.

## Layout

```
fixtures/hooks/
  _lib.sh                 Shared assertion helpers (expect_block / expect_approve).
  run-all.sh              Iterates positive/ + negative/; exits 0 iff all pass.
  positive/               Payloads the hook MUST block. Named <rule-id>-<match>.sh.
  negative/               Payloads the hook MUST approve. Named <category>-<case>.sh.
```

Positive fixtures cover the three closed-enum rule-ids
(`secret-access-denylist` / `hook-self-protection` / `install-boundary-protection`)
plus the match-token sub-categories defined inline at
[`docs/invariants/claude-hook-denylist.md`](../../../../docs/invariants/claude-hook-denylist.md).
Negative fixtures lock in FP-avoidance for known edge cases: `rmdir` vs `rm*`,
`envsubst` vs `env`, `setup.sh` vs `set`, `*.envrc.example` schema-companion
reads, safe dev paths, etc.

## Running

```sh
# Runs every fixture; prints PASS/FAIL per file + summary. Exit 0 iff all pass.
bash packages/keel-invariants/fixtures/hooks/run-all.sh

# Run a single fixture
bash packages/keel-invariants/fixtures/hooks/positive/secret-access-denylist-cat-oauth-token.sh
```

The helpers in `_lib.sh` locate the hook relative to this file (four parents up),
so the fixtures run from any cwd.

## Rule-id / match reference

| rule-id                        | sample match tokens                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `secret-access-denylist`       | `cat-oauth-token`, `cat-ssh-key`, `cat-envrc-file`, `cat-secrets-file`, `cat-env-file`, `cat-proc-environ`, `env-dump-bare`, `printenv-idiom`, `read-oauth-token`, `read-oauth-token-tilde`, `read-ssh-key`, `read-proc-environ`, `read-envrc-file`, `read-env-file`, `read-secrets-file`, `read-secret-file`, `read-resolved-to-oauth-token`, `read-resolved-to-ssh-key`, `read-resolved-to-proc-environ`, `grep-glob-secret-pattern`, `grep-glob-path-oauth`, `symlink-example-to-secret-dir`, `unknown-tool-raw-secret-dir`, `unknown-tool-raw-proc-kernel`, `unknown-tool-raw-proc-pid` |
| `hook-self-protection`         | `settings-file`, `hook-script-file`, `git-hook-file`, `git-no-verify-bypass`, `rm-against-protected`, `mv-against-protected`, `chmod-against-protected`, `tee-against-protected`, `sed-i-against-protected`, `echo-redirect-against-protected`, `cp-against-protected`, `truncate-against-protected`, `dd-against-protected`, `find-delete-against-protected`                                                                                                                                                                                                                               |
| `install-boundary-protection`  | `install-boundary-file`, `mutation-verb-against-l1`, `sed-i-against-l1`, `echo-redirect-against-l1`, `find-delete-against-l1`                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `fork-hook-contract-violation` | `nonzero-exit`, `invalid-json-shape` (not exercised here — fork-hook not installed; Story 2.17 owns substrate, fork-hook lives at operator install time)                                                                                                                                                                                                                                                                                                                                                                                                                                    |

## Adding a fixture

1. Pick positive or negative. Name `<rule-id>-<short-match>.sh` or `<category>-<case>.sh`.
2. Source `_lib.sh`. Build the payload via the `payload_*` helpers. Call
   `expect_block` / `expect_approve` once.
3. Keep each fixture tiny (≤15 lines); one assertion per file.
4. Re-run `run-all.sh` locally.

## Dominance notes (iter-332 authoring)

- **D-22 Read-tool resolved-path branch dominates direct-path globs in devbox.**
  Hook lines 36-38 run `readlink -f "$file_path"` for every Read payload and
  check the resolved path against secret-dir globs at lines 225-229 BEFORE the
  direct-path case at lines 231-240. In the devbox runtime `/home/dev/.claude/`,
  `/home/dev/.ssh/`, and `/proc/self/` are physical paths, so readlink
  canonicalises to the same prefix and the `read-resolved-to-*` match tokens
  fire first. The direct-path tokens (`read-oauth-token`, `read-ssh-key`,
  `read-proc-environ`) are unreachable in this runtime; fixtures are named and
  matched against the reachable branch.
- **`__unknown__` tool_name fires only on jq-parse failure or missing
  `.tool_name` field.** Hook lines 12-16: a non-empty unrecognised tool_name
  (e.g. `"Bogus"`) falls through every case arm and reaches default approve —
  NOT the D-34 fail-secure scan. Use `payload_notool` (omits `.tool_name`
  entirely) to exercise the fallback.
- **L1 regex requires named files under `src/`, not the directory itself.**
  `find packages/keel-invariants/src -delete` does NOT trigger install-boundary
  protection because the L1 regex enumerates `invariants.manifest.ts`,
  `sync-gate.ts`, `manifest-reader.ts`, `prek-hook-manifest.ts`, and
  `prompt-injection-rules/`. Fixtures use `find packages/keel-invariants/src/invariants.manifest.ts -delete`
  to exercise the reachable branch.
- **Grep/Glob `search_path` case-glob requires trailing content.**
  `/home/dev/.claude` (exact, no slash) doesn't match `/home/dev/.claude/*`.
  Fixtures use `/home/dev/.claude/sub` or similar.

## Regeneration

`_gen-fixtures.py` is the source of truth for the fixture bodies. Re-author by
editing the `POSITIVE` / `STANDALONE_POSITIVE` / `NEGATIVE` tables, then:

```sh
python3 packages/keel-invariants/fixtures/hooks/_gen-fixtures.py
bash packages/keel-invariants/fixtures/hooks/run-all.sh
```

The generator wipes `positive/*.sh` + `negative/*.sh` before re-writing; any
manual edits to generated fixtures are lost on the next run.

## Non-goals

- **No DinD runtime smokes.** Impl-time only; operator-workstation live smokes
  are deferred per Story 2.5 posture.
- **No tampered-hook path.** The `install-boundary-protection` + sync-gate
  backstop lives in `packages/keel-invariants/src/`; this directory exercises
  the live hook as-is and cannot mutate it.
- **No Epic 4 S4 scanner coverage.** The `s4-*` prompt-injection rules are
  exercised by `packages/keel-invariants/src/prompt-injection-rules/hook-settings-tamper.test.ts`
  (iter-329, Story 2.17 Task 5).
