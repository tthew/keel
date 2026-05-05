# @keel/keel-templates

This package is the consumer contract for substrate-authored seeds — file-tree assets that a fresh-fork scaffolder (`create-keel-app`, Epic 15a Story 15a.4; not yet landed) materialises at a new fork's repo root. Substrate stories author seeds under `src/seeds/<relative-path>`; the consumer copies them verbatim, preserving the directory shape relative to `src/seeds/`.

## Seeded assets

- `src/seeds/.claude/settings.json` — Story 2.15+2.16+2.17 committed Claude Code permissions + PreToolUse hook registration baseline (deny/allow + hooks.PreToolUse per NFR5a/NFR5b). Story 2.17 added byte-identity drift-protection via `INV-claude-settings-seed` whole-file contentHash (substrate ↔ seed lockstep) + the NFR5a minimum-entry gate (`pnpm keel-invariants:nfr5a-minimum`) asserting `.permissions.deny.length ≥ 13` AND `.permissions.allow.length ≥ 6`. `create-keel-app` (Story 15a.4) materialises this at fresh-fork repo root.
- `src/seeds/.claude/hooks/block-secret-access.sh` — Story 2.16+2.17 PreToolUse hook script (denies secret-access + hook-self-protection patterns; per NFR5a/NFR5b). Story 2.17 extended the hook with D-12..D-36 bypass coverage (wrapper-commands, word-boundary-anchored mutation verbs, `.claude/settings.*.json` forward-compat, `.git/hooks/**`, L1 install-boundary for `packages/keel-invariants/src/`) and added byte-identity drift-protection via `INV-claude-hook-secret-denylist-seed` whole-file contentHash (substrate ↔ seed lockstep). `create-keel-app` (Story 15a.4) materialises this at fresh-fork repo root.
