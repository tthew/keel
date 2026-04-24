import type { ExpectedHook } from './manifest-reader.js';

// Enumeration of prek-installed hooks preserved by INV-git-hooks-preservation (Story 2.17).
// Names + shebang patterns pin the CONTRACT; byte-bodies drift across prek upgrades and
// `.pre-commit-config.yaml` changes, so `.git/hooks/<name>` files are NOT hashed directly.
// The sync-gate walker reads these names, reads each hook file's first line, and hashes
// `sort(name + "\t" + first-line)` — catching hook removals or shebang swaps while tolerating
// prek-emitted body drift.
//
// Adding or removing an entry is an AMEND-path change: substrate PR against this file +
// invariants.manifest.ts contentHash refresh + INVARIANTS.md anchor update + .pre-commit-config.yaml
// alignment. Forks cannot mutate this list (enforced by INV-git-hooks-preservation-enumeration
// whole-file sha256 covering this module).
//
// Shebang pattern is a conservative regex: matches the current prek-emitted `#!/bin/sh` plus
// common alternates (`#!/bin/bash`, `#!/usr/bin/env python`, `#!/usr/bin/env bash`). If a future
// prek release swaps shebang convention, amend both this pattern AND the recorded
// `content-hash` (names+shebangs hash) in lockstep.
export const EXPECTED_HOOKS: readonly ExpectedHook[] = Object.freeze([
  {
    name: 'commit-msg',
    shebangPattern: /^#!\/(bin|usr\/bin\/env)\/?\s*(sh|bash|python3?)/,
  },
  {
    name: 'pre-commit',
    shebangPattern: /^#!\/(bin|usr\/bin\/env)\/?\s*(sh|bash|python3?)/,
  },
]);
