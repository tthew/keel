# Invariant — Gitignored-secret commit-deny

**Scope:** every commit on any Keel-forked repo. Refuses additions of `.envrc`, `.envrc.local`, and `.secrets` files at any path.
**Status:** active at 1.0; machine-enforced via a prek hook.
**Machine-enforced in:** `packages/keel-invariants/src/check-no-committed-dotfiles.ts` + `.pre-commit-config.yaml` (hook `no-committed-dotfiles`).
**Normative reference:** `_bmad-output/planning-artifacts/epics.md` § Epic 2 Story 2.2 AC 5.

## INV-gitignored-secret-commit-deny

Stable ID for the invariant authored by this doc — pinned in `packages/keel-invariants/src/invariants.manifest.ts` (content-hash of this file) and anchored in `INVARIANTS.md` § Gitignored-secret commit-deny (Story 2.2). Story 1.9's pre-merge sync-gate (FR43) detects drift between this doc's on-disk sha256 and the manifest's `contentHash` field, and between the manifest's `anchors: ['INV-gitignored-secret-commit-deny']` entry and the matching `INVARIANTS.md` bullet. The heading is intentionally the bare stable-ID string so `grep '## INV-gitignored-secret-commit-deny' docs/invariants/gitignored-secret-commit-deny.md` makes the manifest's anchor claim self-verifiable without cross-file traversal.

## Intent

`.envrc` and `.secrets` carry per-fork secrets — direnv-sourced environment variables (Postgres DSNs, API keys, OAuth client secrets, devbox resource knobs) and `act`-consumed GitHub-Actions secrets. An accidental commit leaks those values into the git history, where `git filter-branch` / BFG rewrites are the only remediation path and every downstream fork + mirror already has the leak. The Story 2.2 posture is fail-closed: ship committed `*.example` schemas (`packages/devbox/.envrc.example`, `packages/devbox/.secrets.example`) as copy-seeds, gitignore the payloads (`.gitignore:35-48`), AND add a pre-commit guard so a mis-staged payload never reaches HEAD.

The hook is belt-and-braces over `.gitignore`: direct `git add -f <.envrc>` bypasses ignore rules; a developer who stages a secret before the ignore rule lands, or whose local config has `core.excludesFile` shadowing, also escapes `.gitignore`. The guard catches both paths at commit-time with a pointer error explaining where to find the committed schema.

## Mechanism

The guard is a prek hook wired in `.pre-commit-config.yaml` with `pass_filenames: true` — prek passes the set of staged filenames as CLI argv. The hook entry is `pnpm keel-invariants:no-committed-dotfiles`, which executes `packages/keel-invariants/dist/check-no-committed-dotfiles.js` (the compiled form of `src/check-no-committed-dotfiles.ts`).

The script iterates the argv list against an anchored regex denylist:

- `/^(.+\/)?\.envrc$/` — matches any path ending in the literal `.envrc`, at repo root or under any subdirectory. The `$` end-anchor MUST NOT match `.envrc.example`, `.envrc.local` (handled separately), or any other `.envrc*` suffix. Verified by the positive smoke: `pnpm keel-invariants:no-committed-dotfiles packages/devbox/.envrc.example` exits 0.
- `/^(.+\/)?\.envrc\.local$/` — matches `.envrc.local` specifically, the direnv per-environment override. Not required at 1.0 but future-proof.
- `/^(.+\/)?\.secrets$/` — matches `.secrets` at any path; excludes `.secrets.example` via the same `$` end-anchor discipline.

On match, the hook writes a two-line pointer error per violation to stderr and exits 1. On empty violations, it exits 0. The hook's `files:` filter (`(^|/)\.(envrc|envrc\.local|secrets)$`) scopes prek invocation to only commits that stage a matching file — the hook is a no-op for unrelated work.

## Verification

Positive case (committed schema — hook allows):

```sh
pnpm keel-invariants:no-committed-dotfiles packages/devbox/.envrc.example
echo $?   # → 0
```

Negative case (gitignored payload — hook denies):

```sh
echo 'SECRET=abc' > /tmp/fake.envrc
pnpm keel-invariants:no-committed-dotfiles /tmp/fake.envrc
echo $?   # → 1, stderr pointer error naming the match
```

End-to-end against a staged file:

```sh
echo 'SECRET=abc' > .envrc
git add -f .envrc
pnpm exec prek run no-committed-dotfiles --all-files   # → exit 1, hook refuses
git restore --staged .envrc && rm .envrc
pnpm exec prek run no-committed-dotfiles --all-files   # → exit 0, no violations
```

The allow-list contract: `.envrc.example`, `.envrc.local.example`, `.secrets.example`, and `packages/devbox/.{envrc,secrets}.example` are all EXEMPT from the guard via anchored regex end-match. `.gitignore` negation rules (`!.envrc.example`, `!packages/devbox/.envrc.example`, `!.secrets.example`, `!packages/devbox/.secrets.example`) expose these schema companions as committable so forks have a canonical place to enumerate secret keys + devbox knobs without leaking values.
