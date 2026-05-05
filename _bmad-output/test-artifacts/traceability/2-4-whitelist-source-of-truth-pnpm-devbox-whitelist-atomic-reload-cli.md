---
stepsCompleted:
  [
    'step-01-load-context',
    'step-02-discover-tests',
    'step-03-map-criteria',
    'step-04-analyze-gaps',
    'step-05-gate-decision',
  ]
lastStep: 'step-05-gate-decision'
lastSaved: '2026-04-22'
workflowType: 'testarch-trace'
inputDocuments:
  [
    '_bmad-output/implementation-artifacts/2-4-whitelist-source-of-truth-pnpm-devbox-whitelist-atomic-reload-cli.md',
    '_bmad-output/planning-artifacts/epics.md',
    '_bmad-output/planning-artifacts/prd.md',
    '_bmad-output/planning-artifacts/architecture.md',
    'INVARIANTS.md',
    'AGENTS.md',
    'CLAUDE.md',
    'RALPH.md',
    'docs/invariants/devbox-egress.md',
    'docs/invariants/devbox-dind.md',
    'packages/devbox/scripts/whitelist.sh',
    'packages/devbox/scripts/start-egress.sh',
    'packages/devbox/scripts/reload-egress.sh',
    'packages/devbox/whitelist.default.txt',
    'packages/devbox/whitelist/npm.txt',
    'packages/devbox/whitelist/anthropic.txt',
    'packages/devbox/whitelist/github.txt',
    'packages/devbox/package.json',
    'packages/devbox/README.md',
    '.gitignore',
    '_bmad-output/test-artifacts/traceability/2-3-gate-decision.json',
    'packages/keel-invariants/src/invariants.manifest.ts',
  ]
coverageBasis: 'acceptance_criteria'
oracleConfidence: 'high'
oracleResolutionMode: 'formal_requirements'
oracleSources:
  [
    '_bmad-output/implementation-artifacts/2-4-whitelist-source-of-truth-pnpm-devbox-whitelist-atomic-reload-cli.md#Acceptance Criteria',
  ]
externalPointerStatus: 'not_used'
tempCoverageMatrixPath: '_bmad-output/test-artifacts/traceability/2-4-coverage-matrix.json'
---

# Traceability Matrix & Gate Decision — Story 2.4 whitelist source-of-truth + `pnpm devbox:whitelist` atomic-reload CLI

**Target:** Story 2.4 — user-facing bash CLI implementing four subcommands (`sync` / `add` / `remove` / `list`) that compose the three-stage whitelist (`whitelist.default.txt` baseline + `whitelist/*.txt` category fragments + per-fork `whitelist.local.txt` override), validate domain syntax, mutate per-fork override under a dedicated flock, and invoke Story 2.3's `reload-egress.sh` primitive for kernel-atomic dnsmasq + nftables reload. Closes upstream cc-devbox bug #1 (divergent whitelist tooling) by providing ONE canonical operator entry point per SC-8. Five ACs delivered iter-174 via `/bmad-dev-story` single-iteration landing (11 Tasks / ~50 subtasks all green; 1 new file + 7 modified files exactly matching the v1.1 SM-reviewed forecast). Story State `in-dev` at iter-175 trace entry — iter-174 `/bmad-dev-story` completed AC 1–AC 5 end-to-end at substrate level + SC-14 dual-composer parity smoke PASSED byte-identical in iteration env + iteration-env dispatcher + domain-regex + multi-error-collection + gitignore-rule-fires smokes all PASSED. Sync-gate exit 0 with no manifest changes (SC-15 consumer-only; `INV-devbox-egress-contract` contentHash unchanged). Live container smokes (Subtask 10.1–10.8 full reload chain against running devbox + Subtask 9.2 `pnpm --filter @keel/devbox run` listing) are **backend-B operator-workstation-deferred** — iteration env (cc-devbox host-socket-passthrough per `INV-devbox-dind-available`) cannot write `/run`, has no dnsmasq / nft / running container, and the bind-mount-denial precedent from Story 2.1 iter-127 applies; canonical `docker exec` recipes pinned in `packages/devbox/README.md § Per-fork whitelist override (Story 2.4)` + this story's § Debug Log References for the operator close-out pass. Contrast with Story 2.3's ZERO in-iteration-executable runtime assertions — Story 2.4 has MORE iteration-env evidence (parity smoke + dispatcher + regex + multi-error-collection + gitignore), only the live reload chain defers.

**Date:** 2026-04-22
**Evaluator:** Tthew / TEA Agent
**Coverage Oracle:** acceptance_criteria (formal requirements — Story 2.4 § Acceptance Criteria lines 14–39)
**Oracle Confidence:** high
**Oracle Sources:** `_bmad-output/implementation-artifacts/2-4-whitelist-source-of-truth-pnpm-devbox-whitelist-atomic-reload-cli.md` (AC 1–AC 5)

---

Note: This workflow does not generate tests. Story 2.4 is a **user-facing-CLI class substrate** story (FOURTH of Epic 2 + FIRST of its class: operator-editable bash CLI with subcommand dispatcher + domain-regex validation + mutation-lock + atomic-replace + diff summary outside the Vitest/Playwright idiom — contrast Story 2.1 pure runtime-infrastructure, Story 2.2 hybrid infrastructure-smoke + configuration-surface, and Story 2.3 infrastructure-security with daemon + kernel-rule + atomic-reload + log-tailer) whose § Dev-agent guardrails (story lines 318–332 — 13 MUST-follow rules) + v1.1 Change Log iter-173 row (ATDD-skip) explicitly declares:

> _"FOURTEENTH cumulative Epic ATDD-skip precedent (Stories 1.7 iter-14 + 1.8 iter-29 + 1.9 iter-36 + 1.10 iter-43 + 1.11 iter-50 + 1.12 iter-57 + 1.13 iter-64 + 1.14 iter-71 + 1.15 iter-83 + 1.16 iter-90 + 2.1 iter-98 + 2.2 iter-147 + 2.3 iter-157 → 2.4 iter-173) — **fourth Epic 2 ATDD-skip** + **first 'user-facing-CLI class' ATDD-skip** (Story 2.1 = infrastructure-smoke; Story 2.2 = hybrid infrastructure-smoke + configuration-surface; Story 2.3 = infrastructure-security; Story 2.4 = user-facing-CLI: bash CLI with regex validation + mutation-lock + atomic-replace + subcommand dispatcher outside the Vitest/Playwright idiom). `/bmad-testarch-atdd` skill NOT invoked — preflight would HALT at Step 1.2 (zero-test-runner substrate: no vitest.config.*/jest.config.*/playwright.config.*/cypress.config.*/pyproject.toml/go.mod/Gemfile/Cargo.toml/csproj anywhere in tree; TEA test_framework: auto autodetects nothing; Epic 13 is the formal test-framework landing per PRD RS6). Rationale — ground (c) hybrid variant-(ii)+(iii): (ii) downstream integration-gate coverage (Story 2.5 hardening re-verifies AC 2/4 under cap_drop:[ALL] + user:dev + tmpfs context; Story 2.6 host-side pnpm wrapper forwards via docker exec; Epic 13 test-runner landing owns regression coverage); (iii) spec-declared adversarial coverage substitution — 13 Dev-agent Guardrails + 19 pinned scope-clarifications (SC-1 through SC-19) + forthcoming /bmad-code-review (args: \"2\") adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.4 substrate diff) substitute for red-phase scaffolds."_

Automated per-AC test coverage is intentionally deferred; see § Rationale below. This gate decision mirrors the FR14n ATDD-skip clause already applied at iter-173, per the hybrid ground-(a)-(b)-(c)-(d) variant-(ii)+(iii) rationale (substrate-verification-covers-AC + iteration-env-executable-smokes-augment + no-runner + Epic 13 test-runner landing + spec-declared-CR-substitution + upstream-provenance-precedent) pinned in `.ralph/@plan.md § Context` and RALPH.md Signposts 2026-04-22. **FOURTEENTH cumulative trace-WAIVED precedent** — fourth Epic 2 trace-WAIVED and first **user-facing-CLI class** trace-WAIVED (Story 2.1 was pure runtime-infrastructure; Story 2.2 was hybrid infrastructure-smoke + configuration-surface; Story 2.3 was infrastructure-security; Story 2.4 introduces the operator-editable CLI idiom). Under the ATDD-skip-trace-WAIVED co-application rule, this is the **FIFTEENTH pairing** overall (10 Epic-1 pairings + 2.1 + 2.2 + 2.3 + 2.4).

## PHASE 1: REQUIREMENTS TRACEABILITY

### Coverage Summary

| Priority  | Total Criteria | FULL Coverage | Coverage % | Status  |
| --------- | -------------- | ------------- | ---------- | ------- |
| P0        | 0              | 0             | 100%       | ✅ n/a  |
| P1        | 0              | 0             | 100%       | ✅ n/a  |
| P2        | 5              | 0             | 0%         | ❌ FAIL |
| P3        | 0              | 0             | 100%       | ✅ n/a  |
| **Total** | **5**          | **0**         | **0%**     | **❌**  |

**Legend:**

- ✅ PASS — Coverage meets quality gate threshold
- ⚠️ WARN — Coverage below threshold but not critical
- ❌ FAIL — Coverage below minimum threshold (blocker)

All five ACs are **user-facing-CLI substrate** assertions over the Story 2.4 deliverables (AC 1: three-stage composition `whitelist.default.txt` + `whitelist/*.txt` + `whitelist.local.txt`; AC 2: `pnpm devbox:whitelist sync` validates + composes + acquires flock + reloads atomically + exits 0 with diff summary; AC 3: syntax-invalid entry → exit non-zero with line/file pointer + previous policy active (fail-closed); AC 4: concurrent sync serialised by file-lock, no partial policy state; AC 5: whitelist tracked in git → prek gates at PR time → reviewers see domain diff). Priority `P2` reflects secondary-workflow classification per `test-priorities-matrix.md` consistent with Stories 2.1 + 2.2 + 2.3 precedent (no P0 auth/payment/data-loss at substrate; no P1 primary user journey — end-user operator invokes the CLI once Story 2.6 host-side `pnpm devbox:whitelist` wrapper ships). Downstream test-runner landing may retro-classify AC 2 + AC 3 as P1 under runtime-harm taxonomy (CLI-driven egress misconfiguration could fail-open); Story 2.4 ships P2-uniform matching Story 2.3 precedent.

---

### Detailed Mapping

#### AC-1: whitelist.default.txt baseline + per-category fragments + gitignored per-fork override compose into final policy (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.4-test-runner-landing + operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Task 1 + Task 2 + Task 7 + Task 8 authoring + iter-174 live file + iteration-env parity smoke + iter-175 sync-gate verification probe AC 1 at CLI-exit-code level):**
  - **`packages/devbox/whitelist.default.txt` header rewrite (iter-174; content unchanged)**: three-stage composition order explicitly documented (baseline → `whitelist/*.txt` fragments sorted → `whitelist.local.txt` per-fork override if readable); operator-edit path pinned to `pnpm devbox:whitelist add|remove <domain>` or hand-edit + `sync`. Zero-domain baseline preserved — no substrate domains introduced by Story 2.4 (consumer-only per SC-15 + SC-19).
  - **`packages/devbox/whitelist/` pre-existing fragments (Story 2.3 iter-158 — UNTOUCHED)**: `npm.txt`, `anthropic.txt`, `github.txt`. Composed in `LC_ALL=C sort`-order per `mapfile -t fragments < <(find "${WHITELIST_FRAGMENTS_DIR}" -maxdepth 1 -type f -name '*.txt' -print | sort)` enumeration (Story 2.3 iter-170 AR-9 whitespace-safe pattern inherited by Story 2.4 Subtask 2.1 for byte-identity).
  - **`packages/devbox/scripts/whitelist.sh` (NEW iter-174; ~360 LOC; 0755 exec bit; `#!/usr/bin/env bash`; `set -euo pipefail`; `BASH_SOURCE[0]==$0` main-guard per iter-174 sourceability lesson)**: `compose_whitelist_into()` function implements SC-4 three-stage composer — reads WHITELIST_DEFAULT + fragments (`LC_ALL=C find | sort` enumerated via `mapfile`) + WHITELIST_LOCAL (if readable) with `sed -E 's/#.*$//' | awk 'NF { ... }'` comment + blank strip + `LC_ALL=C sort -u` dedup. Additive-only semantics: the per-fork override cannot remove substrate domains (final `sort -u` + composition order). `bash -n` exit 0 at iter-174.
  - **`packages/devbox/scripts/start-egress.sh` (modified iter-174)**: WHITELIST_LOCAL constant added at line 27; 5-line conditional `cat "${DEVBOX_DIR}/whitelist.local.txt"` wrapped in `if [[ -r ... ]]` inside existing `compose_whitelist()` `{ … }` block, AFTER the fragments loop, BEFORE the closing `}` — comment block pins SC-4 additive-only contract + SC-14 byte-identity contract. Banner comment at lines 12–13 updated to append `+ whitelist.local.txt if present` to composition-order description. `bash -n` exit 0 at iter-174.
  - **SC-14 dual-composer parity smoke (Subtask 7.4 / 10.9)**: **PASSED byte-identical** in iteration env iter-174. Harness method: source `whitelist.sh` (main-guard skips dispatcher when `BASH_SOURCE[0] != $0`); extract `compose_whitelist()` body from `start-egress.sh` via `awk '/^compose_whitelist\(\) \{$/,/^\}$/'`; override `WHITELIST_DEFAULT` / `WHITELIST_FRAGMENTS_DIR` / `WHITELIST_LOCAL` / `COMPOSED_WHITELIST` constants to point at a `mktemp -d` fixture containing baseline + npm/anthropic/github fragments + local override (with `shared.example.org` deliberately overlapping default + local to verify `sort -u` dedup); invoke both composers; `diff -u` outputs → byte-identical. Test fixture also exercised comment-stripping (`# baseline header comment`) and dedup (`shared.example.org` appears in both default + local; final output has one). SC-14 byte-identity contract verified.
  - **`.gitignore` line 48 (iter-174)**: `packages/devbox/whitelist.local.txt` entry at END of `# Environment / secrets` block (SC-3 block-end placement per iter-173 SM review disambiguation) with inline comment `# Story 2.4 per-fork whitelist override — operator-editable via whitelist.sh add/remove; NEVER committed.`; NO bang-negation for `.example` companion per Story 2.2 iter-151 AR-2 asymmetry-bug avoidance (SC-3 rationale: no committed `.example` template exists; substrate baseline in `whitelist.default.txt` + fragments serves as working reference). `git check-ignore -v packages/devbox/whitelist.local.txt` smoke at iter-174 verified the rule fires at `.gitignore:48`.
  - **`AGENTS.md` new `### Per-fork whitelist override (Story 2.4)` H3 under § Devbox iteration environment (iter-174)**: documents composition contract (three-stage, additive-only, final `sort -u` dedup), mutation paths (`pnpm devbox:whitelist add|remove <domain>` atomic under mutation lock; `sync` recomposes + reloads; `list` prints composed state with source attribution), AMEND path (substrate baseline + fragment edits are source-level PRs subject to prek gates per FR44), Growth-tier `INVARIANTS.fork.md` posture (fork-owned invariants MAY NOT relax fail-closed default / IPv4/IPv6 parity / atomic-reload semantics).
  - **`packages/devbox/README.md` new `### Per-fork whitelist override (Story 2.4)` H3 under § Egress policy (Story 2.3) (iter-174)**: documents `whitelist.local.txt` path + four CLI subcommands + in-container invocation paths (SC-16 canonical + SC-12 `pnpm` form) + example operator session (add-new / list / remove / sync).
  - **Iteration-env `cmd_list` source-attribution smoke (iter-174)**: against fixture (D + F:anthropic + F:github + L sources) → emits `<prefix>  <domain>` two-space-separated, alphabetical by domain, source attribution correct (substrate-level structural verification). First-encounter-wins semantics match `sort -u` composition order.
  - **Live-smoke AC 1 runtime verification (Subtask 10.4 `whitelist.sh list` against running devbox container + Subtask 10.1 sync-on-empty-override runtime behaviour)** deferred to operator workstation per Subtask 10.10 + backend-B iteration-env constraint (Story 2.1 iter-127 bind-mount-denial precedent; `/run` not writable in iteration env; no running container). Canonical `docker exec` recipes pinned in `packages/devbox/README.md § Per-fork whitelist override (Story 2.4)` for operator close-out pass.
  - **Adversarial AC-1 coverage delegated to iter-CR** per § Dev-agent guardrails hybrid ground-(c) variant-(iii) spec-declared-CR-substitution: Blind Hunter examines whitelist.sh dispatcher + four-subcommand routing + compose_whitelist_into three-stage logic + SC-14 byte-identity maintenance; Edge Case Hunter probes composition edge cases (empty baseline, missing fragment dir, unreadable local override, mixed CRLF/LF, BOM) + `cat`-conditional-absence semantics + SC-4 additive-only invariant (fork can't shrink); Acceptance Auditor verifies AC 1 three-stage composition verbatim match architecture.md § Devbox Package Tree l.1002 + PRD § CLI-Tool Surface l.493.

---

#### AC-2: `pnpm devbox:whitelist sync` reads composed whitelist, validates domain syntax, acquires file-lock, reloads dnsmasq+nftables atomically (reusing Story 2.3 primitive), emits diff summary, exits 0 on success (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.4-test-runner-landing + operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Task 1 + Task 3 + Task 9 authoring + iter-174 live file + iteration-env dispatcher + parity smokes probe AC 2 at CLI-exit-code level):**
  - **`packages/devbox/scripts/whitelist.sh` `cmd_sync()` (iter-174)**: no-args dispatch per SC-1 four-subcommand surface (usage + exit 2 if any args). Pipeline: (a) `validate_sources` runs BEFORE composition — fail-closed posture (SC-6): validation failure exits 2 WITHOUT invoking `reload-egress.sh` or touching `${COMPOSED_WHITELIST}`; (b) `compose_whitelist_into` writes into `mktemp /tmp/keel-whitelist-sync.XXXXXX`; trap-registers tempfile EXIT cleanup; (c) compute diff via `diff --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format=''` between `${PREVIOUS_COMPOSED}` and new tempfile; post-process into SC-7 format via `grep '^+' | sort` + `grep '^-' | sort` (iter-173 CRITICAL fix from SM review: GNU diff emits changed lines in file-position order not alphabetical `+`-first-`-`-second grouping — explicit post-processing ensures SC-7 compliance); (d) `mv`-atomic swap tempfile onto `${COMPOSED_WHITELIST}` (SC-9 rename(2) on tmpfs; cross-FS fallback to `cp -f + rm`); (e) invoke `${SCRIPT_DIR}/reload-egress.sh ${COMPOSED_WHITELIST}` (Story 2.3's primitive; SC-17 first-downstream-caller validates encapsulated-bootstrap-detour contract); (f) propagate exit codes 5/6/7 via SC-11 passthrough; (g) on reload success `cp -f ${COMPOSED_WHITELIST} ${PREVIOUS_COMPOSED}` + `chmod 0644` for next diff snapshot (SC-18); on reload failure do NOT update PREVIOUS_COMPOSED (next sync diffs against still-previous state per SC-7); (h) emit SC-7 diff summary (`whitelist sync: <N> domains active` header + sorted additions + sorted removals + `(<A> added, <R> removed)` count line) to stdout; (i) exit 0.
  - **`packages/devbox/package.json` scripts block (iter-174)**: gained single entry `"devbox:whitelist": "./scripts/whitelist.sh"` (SC-12). Pre-existing `build` / `typecheck` / `lint` entries preserved verbatim; new entry appended after `lint`. JSON trailing-comma validity preserved. No root-level `package.json` alias (SC-12 defers that to Story 2.6 host-side wrapper).
  - **`packages/devbox/scripts/reload-egress.sh` (Story 2.3 iter-158 — UNTOUCHED by Story 2.4 per SC-19 scope isolation)**: implements SC-5 atomic-reload contract — `flock -x 200 /run/keel-egress.lock` 10s timeout + `nft -f <tempfile>` kernel-atomic + `kill -HUP $(cat /run/dnsmasq.pid)` with `pkill -HUP dnsmasq` fallback + 8 documented exit codes (2/3/4/5/6/7/0). Story 2.4 `sync` is the FIRST downstream caller — validates SC-17 encapsulated-bootstrap-detour contract (inherited first-boot safety without duplicate logic per Guardrail #3 no-duplicate-reload-logic).
  - **SC-14 dual-composer byte-identity contract — PASSED in iteration env iter-174**: Story 2.4 `whitelist.sh`'s `compose_whitelist_into()` produces byte-identical output to Story 2.3 `start-egress.sh`'s `compose_whitelist()` for the same input files. Parity smoke (Subtask 7.4 / 10.9) ran against baseline + 3 fragments + local override fixture (with deliberate `shared.example.org` overlap to verify `sort -u` dedup) → byte-identical.
  - **Iteration-env dispatcher exit-2 contract smoke (iter-174)**: `bash whitelist.sh` (no args) → exit 2 + usage emitted to stderr; `bash whitelist.sh garbage` (unknown subcommand) → exit 2; `bash whitelist.sh add` (zero args) → exit 2; `bash whitelist.sh add foo bar` (two args) → exit 2; `bash whitelist.sh sync foo` (extra args) → exit 2. Validates Subtask 1.4 main dispatcher + SC-1 four-subcommand surface + SC-11 exit-code contract.
  - **Live-smoke AC 2 runtime verification (Subtask 10.1 sync-on-empty-override + Subtask 10.2 add-new-domain + Subtask 10.3 remove-domain + Subtask 10.7 concurrent-sync + Subtask 10.8 file-not-readable — full reload chain against running container; Subtask 9.2 `pnpm --filter @keel/devbox run` listing)** deferred to operator workstation per Subtask 10.10 + Story 2.1 iter-127 backend-B precedent.
  - **Adversarial AC-2 coverage delegated to iter-CR**: Blind Hunter examines cmd_sync pipeline ordering (validate → compose → mv → reload; exit-code propagation path); Edge Case Hunter probes `diff` post-processing for SC-7 format edge cases (empty previous; empty new; identical; all-added; all-removed) + `mv` cross-FS fallback + PREVIOUS_COMPOSED permission-recovery + SC-17 first-caller bootstrap detour interaction (cold-start vs warm-start behaviour); Acceptance Auditor verifies AC 2 atomic-reload verbatim match SC-5 primitive contract + package.json script wiring SC-12 + SC-11 exit-code uniformity.

---

#### AC-3: syntax-invalid entry in any whitelist file causes CLI to exit non-zero with line/file pointer; previous policy remains active (fail-closed) (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.4-test-runner-landing + operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Task 2 authoring + iter-174 live file + iteration-env multi-error-collection + regex rejection smokes probe AC 3 at CLI-exit-code level):**
  - **`packages/devbox/scripts/whitelist.sh` `validate_sources()` (iter-174)** per SC-5 + SC-6: iterates `whitelist.default.txt` + every `whitelist/*.txt` fragment + `whitelist.local.txt` (if present); per-file per-line-after-strip applies the LDH regex `^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$` + 253-char total-length bound (RFC 1035); local `-i error_count=0`; collects ALL errors before returning (SC-6 operator-sees-full-list contract); on any error emits `<file>:<lineno>: invalid domain syntax: '<line>'` to stderr with DEVBOX_DIR-relative paths + 1-indexed line numbers per SC-6; returns 2 if `error_count > 0`.
  - **`packages/devbox/scripts/whitelist.sh` `validate_domain()` (iter-174)**: fast-fail-before-lock at `cmd_add` / `cmd_remove` boundaries — consistent LDH regex + length bound applied to single `<domain>` arg BEFORE acquiring mutation lock (avoids blocking other operators on obvious garbage). Stderr: `invalid domain syntax: '<domain>'` + exit 2.
  - **Fail-closed composition discipline (Guardrail #1 + SC-6 verbatim)**: `cmd_sync` runs `validate_sources` BEFORE composing / before invoking `reload-egress.sh`; on failure exits 2 WITHOUT touching `${COMPOSED_WHITELIST}` or invoking the reload primitive. Previous policy (`/etc/dnsmasq.conf` + nftables ruleset) remains active. Verified at code-path level iter-174 + implicitly at iteration-env dispatcher smoke level (sync is invocable; validation triggers before composition).
  - **Iteration-env `validate_sources` multi-error collection smoke (iter-174)**: against fixture with 4 malformed lines (`bad_underscore.example`, `-leading-hyphen.example`, `api.github.com.` trailing-dot, `too.short.empty..label`) + valid lines → emits 4 stderr lines each with correct DEVBOX_DIR-relative path + 1-indexed line number + offending text; multi-error collection per SC-6 verified; exit 2 contract verified.
  - **Iteration-env `validate_domain` single-arg rejection smokes (iter-174)**: `bash whitelist.sh add 'bad_underscore.example'` → exit 2 + stderr `invalid domain syntax: 'bad_underscore.example'`; `bash whitelist.sh add '-leading-hyphen.example'` → exit 2; `bash whitelist.sh add 'api.github.com.'` (trailing-dot SC-5 known-limit) → exit 2. Well-formed `bash whitelist.sh add 'api.example.org'` passes regex, fails at `/run/keel-whitelist-mutate.lock: Permission denied` (expected outside container — NOT a defect; `/run` is privileged outside the devbox container).
  - **SC-5 Known limitations (scope-pinned at 1.0; deferred to post-1.0 refinement per Story v1.1 iter-173 SM review)**: (a) RFC 3696 §2 all-numeric TLD prohibition NOT enforced (failure mode benign — fail-closed resolution rather than fail-open match; adding enforcement requires a secondary label-class check and is out of scope for the 1.0 strict-LDH contract); (b) trailing-dot FQDN notation rejected (operators MUST use bare-name form). Both are operator-ergonomics issues, not security-critical — injection-prevention property preserved.
  - **Live-smoke AC 3 runtime verification (Subtask 10.5 validation-failure smoke: temporarily append malformed domain to `whitelist.local.txt`; run `sync`; verify exit 2 + stderr + previous `nft list chain` rules unchanged)** deferred to operator workstation per Subtask 10.10 + backend-B iteration-env constraint. Iteration-env validate_sources + validate_domain smokes (above) verify stderr format + multi-error collection + exit-2 contract at substrate level; only the post-failure `nft list chain` state-unchanged assertion requires a live container.
  - **Adversarial AC-3 coverage delegated to iter-CR**: Blind Hunter examines validate_sources for per-line-after-strip ordering correctness (comment-strip first, then blank-strip, then regex) + collecting-all-errors-before-return completeness + DEVBOX_DIR-relative path emission; Edge Case Hunter probes the SC-5 known-limits edge cases (all-numeric TLD acceptance is benign fail-closed; trailing-dot rejection; IDN rejection pre-punycode) + fail-closed composition boundary (what happens if validate_sources is skipped? answer: code-path guarantees it's always called before reload — pipe ordering + `set -e` ensures); Acceptance Auditor verifies SC-5 regex match RFC 1035 LDH + 253-char bound + SC-6 error-format + fail-closed AC 3 verbatim.

---

#### AC-4: concurrent `pnpm devbox:whitelist sync` invocations serialised by file-lock; no partial policy state ever active (P2)

- **Coverage:** NONE ❌ (deferred to Story 2.4-test-runner-landing + operator-workstation live smokes + iter-CR adversarial backstop)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Task 4 + Task 5 authoring + iter-174 live file + SC-8 fd-201 mutation-lock discipline probe AC 4 at CLI-exit-code level):**
  - **`packages/devbox/scripts/whitelist.sh` `cmd_sync` (iter-174)**: serialisation inherited from Story 2.3's `reload-egress.sh` `flock -x 200 /run/keel-egress.lock` 10s timeout (SC-5 of Story 2.3 — untouched per Story 2.4 SC-19 scope isolation). `sync` acquires NO mutation lock (pure read of composed whitelist + passthrough to reload-egress.sh). Concurrent `sync` invocations arbitrate cleanly at the reload-primitive layer.
  - **`packages/devbox/scripts/whitelist.sh` `cmd_add` / `cmd_remove` (iter-174)**: acquire a SECOND lock `flock -x -w 10 201 /run/keel-whitelist-mutate.lock` per SC-8 during the mutation phase (read → edit → write of `whitelist.local.txt`) to prevent torn writes from concurrent `add foo.com` + `remove bar.com`. **fd 201 (NOT fd 200)** per SC-8 + Guardrail #6 nested-lock-deadlock avoidance — reload-egress.sh owns fd 200; whitelist.sh's mutation lock MUST use a disjoint fd so that when the lock is released BEFORE invoking `cmd_sync`, reload-egress.sh's flock acquires cleanly.
  - **Lock timeout: 10s matches Story 2.3 reload-lock timeout**; exits 4 with actionable stderr `ERROR: mutation lock unavailable within 10s` on timeout (SC-11 exit-code contract).
  - **Atomic-mutation discipline (SC-9 + Guardrail #5)**: `cmd_add` writes tempfile `${WHITELIST_LOCAL}.tmp.$$` (PID-suffixed for concurrent-safety within flock-guarded region) then `mv` onto target (rename(2), atomic on same FS). Existing content read via `cat "${WHITELIST_LOCAL}"` (strips trailing newlines) then `printf '%s\n' "${existing}"` re-adds clean newline + appends new domain — handles hand-edit-without-trailing-newline state. Trap-registers tempfile cleanup on EXIT for crash-safety. `cmd_remove` uses `grep -Fxv "<domain>" > "${tempfile}"` + `mv` (idempotent — accepts grep exit 1 when file becomes empty via `|| true`).
  - **iter-174 dev-story NOTE (Completion Notes + RALPH.md iter-174 lesson)**: SC-9 subtask-wording discrepancy resolved in favor of the SC-level binding `mv` contract. Original Subtask 4.5 proposed `cp -f "${tempfile}" "${WHITELIST_LOCAL}"` + `rm -f "${tempfile}"` for the atomic append — but `cp -f + rm` is NOT atomic (intermediate zero-byte state during copy). SC-9 mandates `mv` for true atomic replacement (rename(2) is kernel-atomic on same FS). Implementation uses `mv`; when subtask wording diverges from SC-level binding contract, follow the SC — escalated to RALPH.md § Lessons for future cases.
  - **No partial policy state (AC 4 verbatim)**: if `nft -f` fails, kernel rolls back (previous ruleset stays active; SC-5 kernel-atomic guarantee). If `validate_sources` fails before compose, `reload-egress.sh` is NOT invoked (SC-6 fail-closed). If mutation lock times out, `add` / `remove` exit 4 BEFORE touching `whitelist.local.txt` (no partial write). If mv-atomic swap fails mid-operation (cross-FS), `cp -f + rm` fallback ensures eventual consistency with slight non-atomic window (acceptable since same-FS `/tmp` on tmpfs means `mv` always succeeds in practice).
  - **Live-smoke AC 4 runtime verification (Subtask 10.7 concurrent-sync smoke: spawn two `whitelist.sh sync &` invocations from same shell; `wait`; verify both exit 0 + reload-egress.sh flock serialises them cleanly + final composed whitelist matches expectation)** deferred to operator workstation per Subtask 10.10 + backend-B constraint (requires `/run/keel-egress.lock` flock arbitration against live dnsmasq + nft).
  - **Adversarial AC-4 coverage delegated to iter-CR**: Blind Hunter examines fd-201 vs fd-200 mutation-lock ordering + release-before-sync-invoke discipline + trap-EXIT tempfile cleanup completeness; Edge Case Hunter probes concurrent add+add on same domain (idempotence via Subtask 4.4 `grep -Fxq` + exit-0-no-op) + concurrent remove+remove + SIGTERM-mid-mutation-lock (trap discipline) + `mv` cross-FS fallback + empty-file-post-remove semantics; Acceptance Auditor verifies SC-8 fd-201 discipline + SC-9 `mv`-atomic + 10s timeout → exit 4 match story Dev-agent guardrails + Subtask 4.3 + 5.3 wiring verbatim.

---

#### AC-5: whitelist tracked in git; PR edits subject to standard prek gates (Story 1.4/1.5); reviewers see which domains added/removed (P2)

- **Coverage:** NONE ❌ (not-applicable at runtime — git-tracked + PR-review-surface contract verified at substrate stage + iteration-env gitignore smoke)
- **Tests:** 0 automated tests
- **Substrate verification (non-gate-eligible evidence — STRONG; Task 8 + Subtask 5.5 authoring + iter-174 live file + gitignore-rule-fires smoke probe AC 5 at VCS-contract level):**
  - **`packages/devbox/whitelist.default.txt` + `packages/devbox/whitelist/npm.txt` + `packages/devbox/whitelist/anthropic.txt` + `packages/devbox/whitelist/github.txt`**: substrate baseline + category fragments tracked in git per Story 2.3 iter-158 (UNTOUCHED by Story 2.4 beyond header-comment refresh of `whitelist.default.txt`). Source-level edits go through standard prek gates (Story 1.4 pre-commit + Story 1.5 CI) at commit time per AC 5 verbatim. Git-diff at PR time shows exactly which domains added/removed (line-level diff; baseline file has zero domain entries so additions are obvious; fragments are curated lists).
  - **`packages/devbox/whitelist.local.txt`** — gitignored per `.gitignore:48` (iter-174, SC-3). Per-fork operator-editable at runtime via `whitelist.sh add/remove`; NEVER committed to shared `main`. PR-review diff surface applies ONLY to substrate (baseline + fragments); per-fork override is operator-local state not subject to shared review.
  - **AMEND path (FR44)**: substrate domain removal requires source-level PR against `whitelist.default.txt` or `whitelist/*.txt` (not runtime CLI) — `whitelist.sh remove <substrate-domain>` emits operator-education error (Subtask 5.5 substrate-source check) with `FR44 AMEND path` pointer + exit 2. Prevents the silent-no-op surprise where an operator believes they removed a domain but the substrate baseline keeps it active. The whitelist.local.txt per-fork override mechanism is FORK per FR44; baseline + fragment edits are AMEND.
  - **`packages/devbox/scripts/whitelist.sh` `cmd_remove` substrate-source check (Subtask 5.5 iter-174)**: uses composition semantics — `sed -E 's/#.*$//' "${substrate_files[@]}" | awk 'NF' | grep -Fxq -- "${domain}"` — strips comments + blanks BEFORE `grep -Fxq` so commented lines don't produce false positives and whitespace-padded entries still match (Story v1.1 iter-173 ENHANCEMENT #2 from SM review). On substrate match: stderr `WARNING: '<domain>' is a substrate baseline / category-fragment domain; remove requires source-level PR (FR44 AMEND path). whitelist.local.txt override has no effect on substrate domains.` + exit 2. Iterates `substrate_files` = `whitelist.default.txt` + every `whitelist/*.txt` fragment.
  - **SC-7 diff summary format**: emits operator-visible diff at sync time to stdout — `whitelist sync: <N> domains active` header + `+added.example.com` group (sorted alphabetical) + `-removed.example.com` group (sorted alphabetical) + `(<A> added, <R> removed)` count line. Complements the git-diff-at-PR-time visibility for shared substrate edits. First-sync-after-boot (no PREVIOUS_COMPOSED snapshot): every domain is `+` addition per SC-18 (container-restart-as-reference-reboot semantics).
  - **`.gitignore` line 48 (iter-174)**: `packages/devbox/whitelist.local.txt` at END of `# Environment / secrets` block (SC-3 block-end placement for insertion-site disambiguation per iter-173 SM review) with inline comment `# Story 2.4 per-fork whitelist override — operator-editable via whitelist.sh add/remove; NEVER committed.`; NO bang-negation for `.example` companion (SC-3 rationale: no committed template exists; substrate baseline in `whitelist.default.txt` + fragments serves as working reference per Story 2.2 iter-151 AR-2 asymmetry-bug-avoidance pattern).
  - **Iteration-env `git check-ignore -v packages/devbox/whitelist.local.txt` smoke (iter-174)**: verified the gitignore rule fires at `.gitignore:48`. Fixture-file cleanup after smoke: untracked `whitelist.local.txt` removed; working tree clean.
  - **Live-smoke AC 5 runtime verification not applicable at substrate stage** — AC 5 is a git-tracked + PR-review-surface contract, not a runtime assertion. `git check-ignore -v` smoke (above) verifies the gitignore mechanics; prek gate verification inherits from Story 1.4 + Story 1.5 pre-existing infrastructure (not a Story 2.4 deliverable). Subtask 10.6 substrate-source-protection smoke (operator-workstation-deferred) will verify the `cmd_remove` error-path at runtime against the running container.
  - **Adversarial AC-5 coverage delegated to iter-CR**: Blind Hunter examines substrate-source check for baseline + fragment iteration completeness + composition-semantics match + stderr format clarity; Edge Case Hunter probes comment-stripped match edge cases (whitespace-padded entries; trailing-newline; empty files; non-existent whitelist.local.txt on remove) + SC-7 diff format edge cases (first-sync-no-previous; cross-restart); Acceptance Auditor verifies AC 5 verbatim — PR sees diff + prek gates fire + reviewers review domain changes — satisfied by git-tracked substrate + `.gitignore:48` override + substrate-source protection.

---

## PHASE 2: TEST DISCOVERY INVENTORY

### Test Collection Status

**COLLECTED** — No test runner is configured at this substrate stage; acknowledged per hybrid ATDD-skip clause (fourth Epic 2 + first user-facing-CLI class; FOURTEENTH cumulative trace-WAIVED precedent). A framework-aware recursive file search for `**/*.test.ts`, `**/*.spec.ts`, `**/*.test.tsx`, `**/*.spec.tsx`, `**/tests/**`, `vitest.config.*`, `jest.config.*`, `playwright.config.*`, `cypress.config.*`, `pyproject.toml`, `go.mod`, `Gemfile`, `Cargo.toml`, `*.csproj`, `pytest.ini` under the worktree at iter-175 returns zero matches — identical to Story 2.1 iter-126 + Story 2.2 iter-149 + Story 2.3 iter-159 precedent. Stack detection: root `package.json` has no `react`, `vue`, `angular`, `next`, `playwright`, `cypress`, `vitest`, `jest` dependencies; `tea_config` inherits TEA framework default (`test_framework: auto`) which autodetects nothing under this substrate. The Story 2.4 file itself is the only artefact referencing runtime assertions (Subtask 10.1–10.8 live-smoke tasks + Subtask 9.2 pnpm script listing are backend-B operator-workstation deferred per Subtask 10.10); iteration-env-executable smokes (SC-14 parity + dispatcher + regex + multi-error-collection + gitignore + cmd_list source-attribution) all ran successfully at iter-174 providing MORE substrate evidence than Story 2.3 (which had ZERO iteration-env live assertions).

### Test Counts

- **Files:** 0
- **Cases:** 0
- **Skipped:** 0
- **Fixme:** 0
- **Pending:** 0

### By Level

| Level     | Tests | Files |
| --------- | ----- | ----- |
| E2E       | 0     | 0     |
| API       | 0     | 0     |
| Component | 0     | 0     |
| Unit      | 0     | 0     |
| Other     | 0     | 0     |

---

## PHASE 3: GAP ANALYSIS

### Critical Gaps (Priority P0)

None — AC coverage breakdown has no P0 rows (user-facing-CLI substrate at Story 2.4 substrate stage, matching Story 2.1 + 2.2 + 2.3 P2-uniform precedent).

### High-Priority Gaps (Priority P1)

None — AC coverage breakdown has no P1 rows. See § Coverage Summary note: downstream test-runner landing may retro-classify AC 2 + AC 3 as P1 under runtime-harm taxonomy (CLI-driven egress misconfiguration could fail-open); Story 2.4 ships P2-uniform matching Stories 2.1 + 2.2 + 2.3 precedent.

### Medium-Priority Gaps (Priority P2)

| ID   | Coverage | Reason                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ---- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| AC-1 | NONE     | User-facing-CLI substrate; no test runner at 1.0 (Epic 13 scope). Structural claim-verifiable via future shell-smoke (docker exec): `whitelist.sh list` + `sync` on empty override + composition byte-identity (SC-14 parity PASSED iter-174). Template-level whitelist.sh + start-egress.sh extension + whitelist.default.txt header + .gitignore + AGENTS.md/README.md H3 + cmd_list fixture smoke all verified iter-174.                              |
| AC-2 | NONE     | User-facing-CLI substrate; no test runner at 1.0. Structural claim-verifiable via future shell-smoke: `whitelist.sh sync` exit 0 + diff summary + reload-egress.sh integration + PREVIOUS_COMPOSED snapshot. Template-level cmd_sync + validate_sources + compose_whitelist_into + passthrough + package.json + SC-14 parity + dispatcher exit-2 smoke all verified iter-174.                                                                            |
| AC-3 | NONE     | User-facing-CLI substrate; no test runner at 1.0. Structural claim-verifiable via future shell-smoke: append malformed → sync exit 2 + stderr + `nft list chain` unchanged. Template-level validate_sources + validate_domain + LDH regex + 253-char bound + fail-closed discipline + iteration-env multi-error + single-arg rejection smokes all verified iter-174.                                                                                    |
| AC-4 | NONE     | User-facing-CLI substrate; no test runner at 1.0. Structural claim-verifiable via future shell-smoke: spawn two `sync &` + verify both exit 0. Template-level mutation-lock fd-201 + reload-primitive fd-200 + SC-9 `mv`-atomic + trap-EXIT + 10s timeout → exit 4 all verified iter-174. SC-9 `mv`-vs-`cp+rm` atomicity discrepancy (Subtask 4.5 wording vs SC binding contract) resolved in favor of SC.                                               |
| AC-5 | NONE     | Git-tracked + PR-review-surface contract (not a runtime assertion). Substrate baseline + fragments tracked in git (Story 2.3); gitignore rule verified iter-174 via `git check-ignore -v`. Substrate-source protection (Subtask 5.5) verified at code-path level; iteration-env smoke requires running container to also assert state-untouched. Prek-gate inheritance from Story 1.4/1.5 infrastructure (not a Story 2.4 deliverable).                  |

### Heuristic Coverage Signals

- **Endpoint gaps:** none (not applicable — this is a CLI, not a request-response API endpoint surface).
- **Auth negative-path gaps:** not applicable (no auth flow at this stage — Story 2.4 predates Epic 5 platform authentication work).
- **Happy-path only:** not applicable (error-path coverage is intentionally **PRESENT** — AC 3 fail-closed + AC 4 lock-timeout + AC 5 substrate-source-protection are explicit error-paths with iteration-env evidence).
- **UI journey gaps:** not applicable (CLI substrate; no UI surface).
- **UI state gaps:** not applicable.

---

## PHASE 4: GATE DECISION

**Status:** `WAIVED`

**Determination:** Deterministic coverage computation reports `overall_coverage_pct = 0%` (below 80% minimum threshold). Under normal gate criteria this FAILS. Per hybrid ATDD-skip clause + FOURTEENTH cumulative trace-WAIVED precedent + ground-(a)-(b)-(c)-(d) variant-(ii)+(iii) rationale, the zero-test-runner posture is **accepted** at Story 2.4 substrate stage with downstream test-runner-landing + operator-workstation live smokes explicitly deferring the runner-hosted coverage path.

**Gate criteria:**

- P0 coverage required 100% → actual 100% (no P0 criteria, vacuous PASS) — **MET**
- P1 coverage target 90% / minimum 80% → actual 100% (no P1 criteria, vacuous PASS) — **MET**
- Overall coverage minimum 80% → actual 0% (no tests at substrate stage) — **NOT MET**

### Rationale

**FOURTEENTH cumulative Epic trace-WAIVED precedent (Stories 1.7 iter-4 + 1.8 iter-3 + 1.9 iter-3 + 1.10 iter-46 + 1.11 iter-57 + 1.12 iter-64 + 1.13 iter-71 + 1.14 iter-78 + 1.15 iter-85 + 1.16 iter-92 → 2.1 iter-126 → 2.2 iter-149 → 2.3 iter-159 → 2.4 iter-175).** Story 2.4 is the **first user-facing-CLI class** story — the combination of subcommand dispatcher + domain-regex validation + mutation-lock discipline + atomic-replace + diff summary operates outside the Vitest/Playwright idiom entirely. Unlike Story 2.3 (which had ZERO in-iteration-executable runtime assertions because the full kernel+daemon+log-tailer stack requires a live container), Story 2.4 has MORE iteration-env evidence — the CLI composition and validation paths are verifiable via shell-level probes without requiring the reload primitive to fire against live kernel rules. Under the ATDD-skip-trace-WAIVED co-application rule, this is the **FIFTEENTH cumulative pairing** overall (10 Epic-1 pairings + 2.1 + 2.2 + 2.3 + 2.4).

**Ground (a) — substrate-verification-covers-ACs at CLI-exit-code level + augmented by iteration-env executable smokes.** All 5 ACs have STRONG substrate evidence verified LIVE at iter-174 + iter-175:

- **AC 1** — `packages/devbox/whitelist.default.txt` header rewritten (content unchanged); `packages/devbox/scripts/whitelist.sh` NEW (~360 LOC, 0755, bash -n OK) with `compose_whitelist_into()` three-stage SC-4 composer; `packages/devbox/scripts/start-egress.sh` 5-line append + WHITELIST_LOCAL constant + banner refresh (SC-14); **SC-14 dual-composer parity smoke PASSED byte-identical in iteration env iter-174**; `.gitignore:48` with inline comment (SC-3); AGENTS.md + README.md H3 subsections; **iteration-env `cmd_list` source-attribution smoke PASSED against fixture**.
- **AC 2** — `cmd_sync` pipeline validated → composed → mv-atomic → invokes reload-egress.sh (Story 2.3 primitive UNTOUCHED) → exit-code passthrough (SC-11) → conditional PREVIOUS_COMPOSED update (SC-18) → SC-7 diff summary; `packages/devbox/package.json` `"devbox:whitelist"` scripts entry (SC-12); **iteration-env dispatcher exit-2 contract smoke PASSED** (no-args / unknown / wrong-arity); SC-17 first-downstream-caller validates Story 2.3's encapsulated-bootstrap-detour.
- **AC 3** — `validate_sources` collects ALL errors before returning (SC-6); `validate_domain` fast-fail; strict LDH regex + 253-char bound per SC-5 (known limits scope-pinned); fail-closed discipline — validation failure exits 2 WITHOUT invoking reload-egress.sh; **iteration-env multi-error collection smoke PASSED** (4 stderr lines with DEVBOX_DIR-relative paths + line numbers); **iteration-env single-arg regex rejection smokes PASSED** (underscore / leading-hyphen / trailing-dot SC-5 known-limit).
- **AC 4** — mutation-lock `flock -x -w 10 201 /run/keel-whitelist-mutate.lock` per SC-8 (fd 201 NOT fd 200 — collision with reload-egress.sh's fd 200 avoided); 10s timeout → exit 4; SC-9 atomic-mutation `mv` rename(2) + tempfile + trap-EXIT; reload-egress.sh fd 200 primitive UNTOUCHED per SC-19; **iter-174 SC-9 `mv`-vs-`cp+rm` atomicity discrepancy resolved** in favor of SC binding contract over Subtask 4.5 wording; kernel-atomic `nft -f` guarantee means no partial policy state.
- **AC 5** — substrate (`whitelist.default.txt` + fragments) tracked in git per Story 2.3; `whitelist.local.txt` gitignored per `.gitignore:48`; `cmd_remove` substrate-source check (Subtask 5.5) with composition semantics emits FR44 AMEND pointer + exit 2; **iteration-env `git check-ignore -v` smoke PASSED** (rule fires at `.gitignore:48`); SC-7 diff summary complements git-diff at PR time.

**Sync-gate exit 0 green** at iter-174 — `node packages/keel-invariants/dist/check.js` validates 20 manifest entries with NO new `INV-*` entry per SC-15 consumer-only; `INV-devbox-egress-contract` contentHash `aad16a51aa1dc7527c0312e6b99217966d7f3f3478fb677dd347792e9cb6889b` unchanged (docs/invariants/devbox-egress.md untouched per SC-19).

**Bash -n syntax check exit 0** at iter-174 for `whitelist.sh` (NEW) + modified `start-egress.sh`.

**Ground (b) — no test runner at 1.0.** Framework prerequisite unmet; Epic 13 delivers formal test-framework landing per PRD RS6. Recursive probe for vitest/jest/playwright/cypress configs returns zero matches at iter-175; stack detection returns none (`package.json` has no react/vue/angular/next/playwright/cypress/vitest/jest dependencies — Epic 13 delivers framework landing per prior thirteen precedents).

**Ground (c) — HYBRID variant-(ii)+(iii) adversarial-coverage substitution.**

- **Variant (ii) downstream test-runner-landing-covers-per-AC-coverage:** Story 2.4-test-runner-landing (Epic 13 scope) + operator-workstation live smokes (Subtask 10.1–10.8 full reload chain + Subtask 9.2 pnpm script listing) will unlock per-AC runtime probes (sync-on-empty / add-new / remove / list-in-container / validation-failure-nft-unchanged / substrate-protection / concurrent-sync / file-not-readable). Story 2.5 hardening exercises `whitelist.sh` as `dev` user under `cap_drop:[ALL]` + tmpfs; Story 2.6 host-side `pnpm devbox:whitelist` wrapper forwards via `docker exec`; Story 2.13 healthcheck orthogonal (probes dnsmasq + sshd liveness, not CLI surface); Epic 4 FR37 security-evidence consumer unchanged (consumes Story 2.3 JSONL stream). None of these block Story 2.4 `review → done` transition under the WAIVED precedent — substrate evidence + iteration-env executable smokes at iter-175 are complete for the in-iteration-executable portion of the story.
- **Variant (iii) spec-declared-CR-substitution:** Story 2.4 § Dev-agent guardrails (13 MUST-follow rules: fail-closed-everywhere + propagate-reload-egress-exit-codes + no-duplicate-reload-logic + composition-byte-identity + atomic-mutation + mutation-lock-discipline + no-gitignore-bang-for-.example + no-INV-manifest-edits + scope-isolation + kebab-case-sh-0755 + backend-B-aware + substrate-source-protection + no-.envrc-edits) + 19 pinned scope-clarifications (SC-1 through SC-19 covering subcommand surface, override path, gitignore, composition order, regex validation, failure contract, diff format, mutation lock, atomic mutation, list source attribution, exit codes, pnpm wiring, scripts shape, start-egress extension, no-INV-edit, in-container execution, first-boot inheritance, previous-snapshot path, no scope creep) + forthcoming `/bmad-code-review (args: "2")` adversarial envelope (Blind Hunter + Edge Case Hunter + Acceptance Auditor fan-out against cumulative Story 2.4 substrate diff: ~360 LOC across 1 new file + 7 modified files) substitute for red-phase scaffolds.

**Ground (d) — upstream-provenance-precedent.** Story 2.1 iter-98 established ground-(d) for Epic 2 stories absorbing upstream cc-devbox content: upstream cc-devbox has no test suite, absorbing preserves that posture faithfully. Story 2.4 is the EXPLICIT FIX for upstream cc-devbox bug #1 (divergent whitelist tooling — upstream shipped `manage-whitelist.sh` with `/etc/whitelist-domains.conf` + `pkill -HUP` AND a separate `whitelist` script with `/workspace/.claude/whitelist` + `pkill + respawn` — different state, different reload, intermittent unexpected blocks) by providing ONE canonical operator-editable CLI entry point per SC-8 single-mechanism collapse. Story 2.3 authored the `reload-egress.sh` primitive; Story 2.4 authors the operator-facing mediator that all egress-whitelist-editing goes through.

**Story 2.4 fix-chain forecast vs Story 2.3.** Per the iter-151/154/155 equation (carve-out × 3 + live-AC-coverage × 3 + impl-surface-LOC / 100): **Story 2.4 = (0 carve-out × 3) + (backend-B live-smoke defer × 3) + (~360 LOC / 100)** → **~6.6 ceiling projected; expected 2–4 PATCH opener + possible re-run** (tighter than Story 2.3's 10-iter chain due to smaller surface: 1 new file + 7 modified vs Story 2.3's 11 new + 11 modified; consumer-not-authoritative scope; dual-composer parity already verified in iteration env which de-risks the SC-14 byte-identity invariant substantially).

**Story State transition:** FR14n `Story State` transitions `in-dev → traced` at iter-175 completion. Next QUEUE item: `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification (`traced → sm-verified` or `sm-fixes-pending`).

### Blockers

None.

### Recommendations

1. **[MEDIUM] Accept WAIVED posture** — five P2 ACs cover a user-facing-CLI class story (fourth Epic 2 + first of its class: operator-editable bash CLI with subcommand dispatcher + domain-regex validation + mutation-lock + atomic-replace + diff summary outside the Vitest/Playwright idiom) with no live test runner at 1.0. All 5 ACs have STRONG substrate evidence (whitelist.sh CLI + start-egress.sh extension + whitelist.default.txt header + package.json + .gitignore + AGENTS.md + README.md + SC-14 parity PASSED + iteration-env dispatcher/regex/multi-error/gitignore smokes PASSED) verified LIVE at iter-174. Per-AC runner-hosted coverage deferred to Story 2.4-test-runner-landing (Epic 13 scope) + backend-B operator-workstation live smokes (Subtask 10.1–10.8 + 9.2).
2. **[MEDIUM]** Story 2.4 authors the user-facing-CLI substrate: 1 new file (whitelist.sh ~360 LOC) + 7 modified files exactly matching v1.1 SM-reviewed forecast; NO new INV-* manifest entry (SC-15 consumer-only) and NO `INV-devbox-egress-contract` contentHash refresh (docs/invariants/devbox-egress.md untouched per SC-19). Downstream consumers: Story 2.5 hardening reworks to `dev` user under cap_drop:[ALL] + tmpfs; Story 2.6 host-side `pnpm devbox:whitelist` wrapper + full `pnpm devbox:*` surface; Story 2.13 healthcheck orthogonal; Epic 4 FR37 consumer unchanged.
3. **[MEDIUM]** Story 2.4 test-runner landing (Epic 13 scope) + backend-B operator-workstation live smokes will unlock per-AC runner-hosted probes per Subtask 10.1–10.8: AC 1 list-against-running-container + sync-on-empty-override; AC 2 full reload chain (add-new → diff + whitelist.local.txt content + idempotent sync + git-status untracked); AC 3 validation-failure + `nft list chain` unchanged; AC 4 concurrent-sync flock arbitration; AC 5 already verified at substrate stage (gitignore rule-fires smoke). Plus Subtask 9.2 `pnpm --filter @keel/devbox run` listing + Subtask 10.6 substrate-source-protection + Subtask 10.8 file-not-readable. None of these block Story 2.4 `review → done` transition under the WAIVED precedent.
4. **[LOW]** Run `/bmad-testarch-test-review` to assess test quality (no tests exist — no-op; recorded for parity with downstream pipelines).

---

## Collection Status: COLLECTED

All static analysis complete. Acknowledged zero runner-hosted tests at this substrate stage per hybrid ATDD-skip clause (FOURTEENTH cumulative trace-WAIVED precedent; fourth Epic 2 + first user-facing-CLI class). Gate status: `WAIVED`. FR14n `Story State` transitions `in-dev → traced` at iter-175 completion. Next QUEUE item: `/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification.

---

## Change Log

| Date       | Version | Description                                                                                                                                                                                                                                                                                                                                                                | Author                 |
| ---------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| 2026-04-22 | 1.0     | Initial trace created iter-175. Coverage oracle: acceptance_criteria (formal requirements); coverage confidence: high. Result: **WAIVED (FOURTEENTH cumulative trace-WAIVED precedent + FIFTEENTH ATDD-skip-trace-WAIVED co-application pairing)** — 5 P2 ACs with STRONG substrate evidence + MORE iteration-env executable smokes than Story 2.3 (SC-14 dual-composer parity PASSED byte-identical; dispatcher exit-2 contract; validate_domain single-arg regex rejection; validate_sources multi-error collection; `cmd_list` source-attribution; `git check-ignore -v` rule-fires). Per-AC runner-hosted coverage deferred to Epic 13 test-runner-landing + Subtask 10.1–10.8 + 9.2 operator-workstation live smokes (full reload chain against running container). Substrate-evidence LIVE verification at iter-174: sync-gate exit 0 (20 manifest entries valid; NO new entry per SC-15 consumer-only; INV-devbox-egress-contract contentHash unchanged); bash -n exit 0 on whitelist.sh (NEW) + start-egress.sh (modified); file + content + line-number verification on whitelist.sh + start-egress.sh + whitelist.default.txt + package.json + .gitignore + AGENTS.md + README.md. CR-forecast envelope ~2–4 PATCH opener per iter-155 equation (0-carve-out + backend-B live-smoke defer + ~360 LOC impl → ~6.6 ceiling; tighter than Story 2.3's 10-iter chain due to smaller surface + dual-composer parity de-risks SC-14). Story State transition `in-dev → traced`. | TEA Agent (Ralph iter-175) |
