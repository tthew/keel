# Test Debt Catalogue (Pre-Bootstrap ATDD-Skip Sweep)

_Authored at Story 1.21 close-out (2026-04-26 / Epic 1 REOPEN-ARC) per FR14n amendment per issue #233._

## Preamble

This file catalogues coverage gaps from pre-bootstrap stories that ATDD-skipped before the Story 1.17 (Vitest) + Story 1.18 (pytest) test runners landed. The catalogue serves three purposes:

1. **Visibility** — pre-bootstrap skips are no longer invisible accumulating drift; each gap has an explicit row.
2. **Prioritisation** — each row carries effort + risk class fields to drive backfill ordering during Epic 4 (security scanners) / Epic 13 (CI pyramid hardening) / Epic 14 (research corpus) prep.
3. **Boundedness** — the FR14n amendment per issue #233 makes ground-(b) bare-skips insufficient post-bootstrap; new skips MUST cite ground (a) or (c). Pre-bootstrap skips listed below are grandfathered.

### Grandfather clause

Every entry below was authored when no test runner existed at the substrate level. The skip was correct under FR14n at the time. The catalogue does NOT retroactively re-open the originating stories; entries are read-only from the originator's perspective. Backfill happens in Epic 4 / 13 / 14 per the per-row Carry-to field — NOT mid-Story-1.21.

### Net-zero-bare-(b)-skip target

The close-of-Epic-1-reopen-window goal is that NO post-Story-1.21 story carries bare ground-(b) (no-runner). The amendment per issue #233 lands this enforcement: `bmad-create-story (args: "review")` pre-dev gate flags any post-Story-1.21 ATDD-skip with bare ground (b) as an AC-coverage finding. Pre-Story-1.21 skips are NOT touched.

### Audit methodology

Walked 34 stories total: Epic 1 stories 1.1–1.16 (16) + Epic 2 stories 2.1–2.18 (18). Stories 1.17–1.21 are EXCLUDED — they constitute the bootstrap arc that landed AFTER the FR14n amendment per issue #233. Each story's `### ATDD red-phase posture` section + `### Lessons applied` + Dev Notes were inspected for ATDD-skip events. Stories that landed full ATDD red-phase coverage at the time (e.g. Story 1.8's `invariants.manifest.ts` Zod-schema-validation probes; Stories with ephemeral shell-smoke probes verified at time of merge) are listed under § Out-of-Scope below.

### Skip-ground taxonomy (FR14n matrix row 3 lettering)

- **(a) substrate-verification** — manifest entry + sync-gate output + INVARIANTS.md anchor; substrate-verifiable WITHOUT runtime test.
- **(b) no-runner** — no test runner exists (load-bearing skip ground for many Epic 1 + Epic 2 substrate stories pre-bootstrap; SUNSET at Story 1.17/1.18 land per FR14n amendment per issue #233).
- **(c) hybrid** — downstream-story-covers-integration / spec-declared-CR-substitution / Zod-upstream-owns-correctness / pre-existing-drift-carve-out variant-(ii).

### Risk class

- **P0** — highest-risk substrate enforcement code (sync-gate / hooks / settings policy / secret denylist).
- **P1** — substrate-supporting infrastructure (token gates / commit lint / coverage floor / CI workflows).
- **P2** — UX / docs / minor / style-only.

### Effort

- **S** — ≤ 0.5 day (single test file with 2–5 cases).
- **M** — 0.5–2 days (fixture infra + multi-test).
- **L** — ≥ 2 days (fixture corpus + integration harness).

---

## Per-story catalogue (Epic 1)

### Story 1-2 — `packages/keel-invariants` bootstrap + shared ESLint/Prettier/commitlint configs

- **Skip ground:** (a) substrate-verification — config files + lint rules verifiable via `pnpm lint` shell probe at land-time.
- **AC class skipped:** docs, contract.
- **Back-fill effort:** S — single test file asserting ESLint shared config exports + Prettier preset + commitlint config shape.
- **Risk class:** P2 — config / convention scaffolding; downstream stories enforce the rules.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/1-2-...md` § Lessons applied.
- **Carry-to:** Epic 13 CI-pyramid hardening — fold a `keel-invariants` config-shape test into the package's vitest suite (Story 1.19 wired the runner).

### Story 1-5 — Conventional-commit enforcement via commitlint + prek

- **Skip ground:** (a) substrate-verification — commitlint rule firing verified via prek hook smoke at install time.
- **AC class skipped:** functional, contract.
- **Back-fill effort:** S — assert commitlint rejects non-conventional message + accepts conventional via subprocess spawn.
- **Risk class:** P1 — commit-hygiene gate; if rule unfires silently, conventional-commit policy decays.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/1-5-...md` § ATDD red-phase posture.
- **Carry-to:** Epic 13 CI-pyramid hardening — wire a vitest suite asserting commitlint rule fire + prek hook integration via tmp-repo fixture.

### Story 1-6 — Quality-gate bypass prevention

- **Skip ground:** (a) substrate-verification — ESLint `no-verify-bypass` rule + prek protection asserted via shell probe at install.
- **AC class skipped:** security, functional.
- **Back-fill effort:** S — ESLint rule fire test + prek bypass-block smoke.
- **Risk class:** P1 — bypass-prevention is itself a substrate-supporting gate; if regressed, quality gates can be silently skipped.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/1-6-...md` § Lessons applied.
- **Carry-to:** Epic 13 CI-pyramid hardening — fold ESLint rule + prek bypass-block test fixtures into existing keel-invariants test suite (Story 1.19 baseline).

### Story 1-7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules

- **Skip ground:** (a)+(c) hybrid per SCP § Section 4 line 72 special-case carry-rule (iter-365). Substrate-verification covers file-existence + cross-reference grep; downstream Story 1.8 (manifest exporter) + Story 1.9 (sync-gate) own the runtime contract.
- **AC class skipped:** docs.
- **Back-fill effort:** S — assert each knowledge file exists at canonical path + cross-references resolve.
- **Risk class:** P2 — knowledge files are docs-class; no runtime behaviour to break.
- **Source:** RALPH.md iter-365 hybrid (a)+(c) carry-rule + `_bmad-output/implementation-artifacts/1-7-...md` § Lessons applied.
- **Carry-to:** deferred indefinitely (substrate-not-load-bearing-at-1.0) — knowledge files are read-by-agent and verified by sync-gate's INVARIANTS.md anchor walker; standalone test would duplicate sync-gate coverage.

### Story 1-11 — Design-token source — Direction A baseline with motion + density scales

- **Skip ground:** (a) substrate-verification — JSON token files + schema-validation probe at land time.
- **AC class skipped:** docs, contract.
- **Back-fill effort:** S — schema-parsing probes on the committed token files.
- **Risk class:** P2 — token source files are config; downstream Story 1.12 emitter pipeline + Story 1.13 quality gates enforce correctness.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/1-11-...md` § ATDD red-phase posture.
- **Carry-to:** Epic 7 tokens-to-UI — fold schema-validation probe into token-emitter test corpus when Epic 7 lands.

### Story 1-12 — Token emitter pipeline → web CSS + Tailwind preset + TUI theme

- **Skip ground:** (a) substrate-verification — emitted output files diff-checked against expected baseline at land time.
- **AC class skipped:** functional, contract.
- **Back-fill effort:** M — fixture infra for input tokens + expected emitter output + diff harness.
- **Risk class:** P1 — emitter regression silently corrupts downstream UI; round-trip detection is load-bearing.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/1-12-...md` § Lessons applied.
- **Carry-to:** Epic 7 full-stack token delivery — emitter regression suite is Epic 7 prerequisite.

### Story 1-13 — Token quality gates (schema validation + WCAG AA contrast + source-output sync)

- **Skip ground:** (a) substrate-verification — gates wired into `pnpm tokens:check` shell probe; downstream Story 1.9 sync-gate carries source-output sync.
- **AC class skipped:** contract, functional.
- **Back-fill effort:** M — WCAG contrast checker + schema-validation harness with positive + negative fixtures.
- **Risk class:** P1 — quality gates protect token-output correctness; regression silently degrades accessibility.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/1-13-...md` § Lessons applied.
- **Carry-to:** Epic 13 CI-pyramid hardening — fold `tokens:check` into vitest suite with golden-output corpus.

### Story 1-14 — Release-please-monorepo config (single-bundled mode)

- **Skip ground:** (a) substrate-verification — release-please config schema validated at land time; behaviour exercised on next release.
- **AC class skipped:** docs, contract.
- **Back-fill effort:** S — assert config shape via JSON-schema + smoke-spawn release-please dry-run.
- **Risk class:** P2 — config drives release tooling; misconfiguration surfaces at release time.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/1-14-...md` § ATDD red-phase posture.
- **Carry-to:** Epic 14 release-prep — release-please config exercised at first cut.

### Story 1-15 — Renovate config with version-pinning rules (I7)

- **Skip ground:** (a) substrate-verification — renovate config validated against schema; behaviour exercised on next renovate run.
- **AC class skipped:** docs, contract.
- **Back-fill effort:** M — renovate-config-validator probe + I7 rule-firing fixture.
- **Risk class:** P2 — config drives dependency-update tooling; misconfiguration surfaces in renovate PRs.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/1-15-...md` § Lessons applied.
- **Carry-to:** Epic 13 CI-pyramid hardening — fold `renovate-config-validator` into pre-commit hook.

### Story 1-16 — Fork extension-config pattern + Growth-tier `INVARIANTS.fork.md` scaffold

- **Skip ground:** (a) substrate-verification — fork-extension config pattern + scaffold file presence verified via grep at land time.
- **AC class skipped:** docs, contract.
- **Back-fill effort:** S — assert fork-extension scaffold exists + precedence rules enforced by sync-gate.
- **Risk class:** P2 — fork-extension config; substrate-additive only, runtime behaviour owned by Story 1.9 sync-gate's `INVARIANTS.fork.md` walker.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/1-16-...md` § Lessons applied.
- **Carry-to:** deferred indefinitely (substrate-not-load-bearing-at-1.0) — fork-extension is opt-in and tested when fork operators consume the path.

---

## Per-story catalogue (Epic 2)

### Story 2-1 — `packages/devbox/` absorb from cc-devbox — image + compose + substrate tooling access

- **Skip ground:** (c) hybrid — devbox image + compose validated via `docker compose config` + smoke-up at land time; downstream Story 2.6 host-side CLI + Story 2.13 healthcheck cover runtime contracts.
- **AC class skipped:** docs, contract.
- **Back-fill effort:** M — devbox image-build smoke fixture + compose schema validation + substrate-tooling-access integration probe.
- **Risk class:** P2 — devbox absorb is scaffolding; downstream stories enforce runtime contracts.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-1-...md` § Lessons applied.
- **Carry-to:** Epic 13 CI-pyramid hardening — devbox-image build smoke fixture is Epic 13 substrate.

### Story 2-2 — `.envrc` parameterisation contract

- **Skip ground:** (c) hybrid — `.envrc` shape verified via shell probe; downstream Story 2.3 + 2.4 + 2.11 consume parameters and enforce runtime semantics.
- **AC class skipped:** contract, docs.
- **Back-fill effort:** M — `.envrc` parsing fixture asserting parameter shape + default-fallback semantics across `KEEL_DEVBOX_*` env vars.
- **Risk class:** P2 — config contract; downstream stories enforce semantics.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-2-...md` § Lessons applied.
- **Carry-to:** Epic 13 CI-pyramid hardening — `.envrc` parameter shape regression suite.

### Story 2-3 — Egress policy — dnsmasq + nftables (fail-closed, IPv4 + IPv6 parity, atomic reload)

- **Skip ground:** (a) substrate-verification — nftables rule-loading verified via `nft list ruleset` shell probe + DNS resolution probes against allow + deny domains at land time.
- **AC class skipped:** security, functional.
- **Back-fill effort:** L — fixture corpus with allow + deny domains + IPv4 + IPv6 parity matrix + atomic-reload race-condition harness; requires devbox runtime.
- **Risk class:** P0 — egress policy is fail-closed network gate; regression silently allows arbitrary egress.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-3-...md` § Lessons applied.
- **Carry-to:** Epic 4 hardening (network policies) — egress-policy regression suite extends `keel-invariants` security scanner story arc.

### Story 2-4 — Whitelist source-of-truth + `pnpm devbox:whitelist` atomic-reload CLI

- **Skip ground:** (b) no-runner — CLI surface tested via shell-spawn at land time; pre-bootstrap so no test runner.
- **AC class skipped:** functional, contract.
- **Back-fill effort:** M — CLI subprocess-spawn fixture asserting `whitelist add/remove/check` semantics + atomic-reload behaviour against fixture devbox.
- **Risk class:** P2 — operator-facing CLI; whitelist source-of-truth load-bearing but errors surface at deploy time.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-4-...md` § Lessons applied.
- **Carry-to:** Epic 14 release-prep — `pnpm devbox:whitelist` regression suite paired with Story 2.18 amendment for CIDR-fallback paths.

### Story 2-5 — Container hardening (non-root user + capabilities + tmpfs noexec + named volume)

- **Skip ground:** (a) substrate-verification — container-state inspection via `docker inspect` + smoke-execs in non-root context at land time.
- **AC class skipped:** security, contract.
- **Back-fill effort:** L — container-state matrix fixture asserting non-root uid + dropped capabilities + tmpfs noexec + named-volume mount across compose profiles.
- **Risk class:** P0 — container hardening is fail-closed isolation gate; regression silently grants escape paths.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-5-...md` § Lessons applied.
- **Carry-to:** Epic 4 hardening (kernel capabilities) — container-hardening regression suite paired with secret/SAST scanner story arc.

### Story 2-7 — Ralph auto-start + TUI attach/detach via `pnpm ralph:build` / `pnpm ralph:plan`

- **Skip ground:** (c) hybrid — Ralph TUI exercised via interactive smoke at land time; downstream Story 2.18 (whitelist) + Story 2.10 (prerequisite check) cover runtime contracts.
- **AC class skipped:** functional, docs.
- **Back-fill effort:** M — TUI attach/detach harness against ralph.py + assert auto-start lifecycle from compose-up.
- **Risk class:** P2 — operator-facing TUI; runtime errors surface visibly at iteration start.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-7-...md` § Lessons applied.
- **Carry-to:** Epic 14 release-prep (UX polish) — TUI attach/detach regression suite.

### Story 2-8 — Claude Code OAuth via `pnpm claude`

- **Skip ground:** (b) no-runner — OAuth flow exercised via shell smoke at land time; pre-bootstrap so no test runner; OAuth interaction not unit-testable without mock harness.
- **AC class skipped:** security, functional.
- **Back-fill effort:** M — mock OAuth flow fixture asserting token-storage path + redirect-handling.
- **Risk class:** P1 — auth gate; regression blocks operator onboarding but does not silently weaken security.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-8-...md` § Lessons applied.
- **Carry-to:** Epic 14 release-prep (auth gates) — OAuth flow regression suite paired with Story 2.9.

### Story 2-9 — `gh` CLI OAuth via `pnpm gh:auth`

- **Skip ground:** (b) no-runner — gh CLI auth flow exercised via shell smoke at land time; same OAuth-mock-harness gap as Story 2.8.
- **AC class skipped:** security, functional.
- **Back-fill effort:** M — mock gh-auth flow fixture asserting token-storage path + scope-handling.
- **Risk class:** P1 — auth gate; regression blocks operator onboarding but does not silently weaken security.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-9-...md` § Lessons applied.
- **Carry-to:** Epic 14 release-prep (auth gates) — gh-auth regression suite paired with Story 2.8.

### Story 2-10 — Prerequisite check (Docker runtime + Claude auth + gh auth) with pointer errors

- **Skip ground:** (b) no-runner — prerequisite-check CLI exercised via shell smoke; pre-bootstrap.
- **AC class skipped:** contract, functional.
- **Back-fill effort:** M — prerequisite-check fixture asserting pointer-error format on each missing prereq + happy-path exit-0.
- **Risk class:** P1 — operator-facing entrypoint; pointer-error correctness is install UX-load-bearing.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-10-...md` § Lessons applied.
- **Carry-to:** Epic 14 release-prep (install-pointer errors) — prerequisite-check regression suite asserting pointer-error UX.

### Story 2-11 — Per-fork vs shared devbox mode (`KEEL_DEVBOX_SHARED`)

- **Skip ground:** (c) hybrid — mode-toggle behaviour exercised via shell smoke at land time; downstream Story 2.7 + 2.13 cover runtime contracts in each mode.
- **AC class skipped:** functional, docs.
- **Back-fill effort:** S — mode-toggle fixture asserting `KEEL_DEVBOX_SHARED=1` vs unset selects correct compose profile.
- **Risk class:** P2 — operator-facing mode toggle; misconfiguration surfaces visibly.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-11-...md` § Lessons applied.
- **Carry-to:** deferred indefinitely (substrate-not-load-bearing-at-1.0) — mode toggle is opt-in; per-fork is the default + tested by every iteration.

### Story 2-12 — Loopback-bound port publication + opt-in `KEEL_DEVBOX_SSH` sshd

- **Skip ground:** (a) substrate-verification — loopback binding asserted via `ss -tnlp` shell probe at land time; sshd opt-in toggle verified via env-var-controlled compose profile selection.
- **AC class skipped:** security, contract.
- **Back-fill effort:** M — port-binding fixture asserting only-loopback default + opt-in sshd port-22 publication when `KEEL_DEVBOX_SSH=1`.
- **Risk class:** P0 — port-binding is fail-closed network gate; regression silently exposes services to host network.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-12-...md` § Lessons applied.
- **Carry-to:** Epic 4 hardening (SSH binding) — port-binding regression suite paired with container-hardening Story 2.5.

### Story 2-13 — Healthcheck on dnsmasq + sshd (replaces upstream's broken `curl :3000` healthcheck)

- **Skip ground:** (a) substrate-verification — healthcheck commands verified via `docker inspect` + smoke-spawn at land time.
- **AC class skipped:** contract, functional.
- **Back-fill effort:** S — healthcheck-command-shape fixture + smoke-up assertion that healthchecks transition `starting → healthy`.
- **Risk class:** P1 — healthcheck drives compose orchestration; broken healthcheck cascades to dependent services.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-13-...md` § Lessons applied.
- **Carry-to:** Epic 13 CI-pyramid hardening — healthcheck regression suite asserting compose-up health timing.

### Story 2-14 — Legacy-devbox branch retention policy

- **Skip ground:** (a) substrate-verification — policy doc verified via grep at land time; no runtime behaviour to test.
- **AC class skipped:** docs.
- **Back-fill effort:** S — assert legacy-devbox branch retention doc exists + cross-references resolve.
- **Risk class:** P2 — operational policy; substrate-not-load-bearing.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-14-...md` § Lessons applied.
- **Carry-to:** deferred indefinitely (substrate-not-load-bearing-at-1.0) — operational guideline; no runtime contract.

### Story 2-15 — Committed `.claude/settings.json` with deny/allow permission policies

- **Skip ground:** (a) substrate-verification — settings.json shape verified via JSON-schema + INVARIANTS.md anchor walker at land time; downstream Story 2.17 NFR5a minimum-entry gate enforces deny-list lower bound.
- **AC class skipped:** security, contract.
- **Back-fill effort:** M — settings.json schema fixture + permission policy resolution semantics test (committed deny + local allow extension).
- **Risk class:** P1 — permission policy gate; deny-list weakening surfaces via Story 2.17 NFR5a check + content-hash sync-gate.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-15-...md` § Lessons applied.
- **Carry-to:** Epic 4 hardening (permission policies) — settings.json schema + resolution-semantics regression suite extends Story 2.17 NFR5a coverage.

### Story 2-16 — Claude PreToolUse hooks for secret-file denylist (Ralph-compatible)

- **Skip ground:** (a) substrate-verification — hook script syntax + invocation verified via `pnpm keel-invariants:claude-hook-syntax` shell probe at land time; downstream Story 2.17 manifest entry catches content drift.
- **AC class skipped:** security.
- **Back-fill effort:** M — hook-fire fixture corpus across denied + allowed paths (Read + Edit + Write + Bash arms) + Ralph-compatibility assertion.
- **Risk class:** P0 — secret-file denylist is fail-closed security gate; regression silently allows secret access.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-16-...md` § Lessons applied.
- **Carry-to:** Epic 4 hardening (secret denylist) — hook-fire regression suite extends keel-invariants secret-scanner story arc.

### Story 2-17 — Hook + settings bypass-resistance (git-layer + manifest + S4 + halt)

- **Skip ground:** (a)+(c) hybrid per RALPH.md iter-311 (substrate-verification covers manifest + sync-gate + INVARIANTS.md; hybrid (c) variant covers downstream Epic 4 scanner-binary consumer contract).
- **AC class skipped:** security, contract.
- **Back-fill effort:** L — bypass-resistance regression suite covering manifest contentHash drift + S4 prompt-injection rules + halt-threshold enforcement + fork-hook contract; partial coverage already landed at iter-329 (`hook-settings-tamper.test.ts` 7/7 GREEN per Story 2.17 Task 5).
- **Risk class:** P0 — bypass-resistance is the fail-closed boundary protecting Story 2.16 hooks + Story 2.15 settings; regression silently re-opens the bypass surface.
- **Source:** RALPH.md iter-311 SKIP-WITH-GROUNDS-(ii)+(iii) entry + `_bmad-output/implementation-artifacts/2-17-...md` § ATDD red-phase posture + iter-340 trace-WAIVED entry (gate-decision.json).
- **Carry-to:** Epic 4 hardening (manifest enforcement) — bypass-resistance regression suite extends Story 2.16 secret-scanner coverage with manifest + S4 + halt-threshold matrix.

### Story 2-18 — Devbox network whitelist DNS-rotation fix (dnsmasq nftset= + GitHub CIDR fallback)

- **Skip ground:** (a)+(c) hybrid — dnsmasq nftset= + GitHub CIDR fallback verified via shell probes at land time; hybrid (c) variant covers operational gap surfaced at iter-391/392 (see § Substrate-Adjacent Operational Gaps below).
- **AC class skipped:** security, contract.
- **Back-fill effort:** L — DNS-rotation fixture asserting nftset= dynamic-update + CIDR-fallback path coverage + iter-391 `results-receiver.actions.githubusercontent.com` host whitelisting after the operational gap is closed.
- **Risk class:** P0 — egress-whitelist is fail-closed network gate; regression silently blocks operator workflows OR allows arbitrary egress.
- **Source:** RALPH.md ATDD-skip-precedents inventory + `_bmad-output/implementation-artifacts/2-18-...md` § ATDD red-phase posture + iter-391 + iter-392 RALPH.md entries.
- **Carry-to:** Epic 4 hardening (network policies) — DNS-rotation + CIDR-fallback regression suite paired with Story 2.3 egress-policy coverage; addresses iter-391 operational gap (see § Substrate-Adjacent Operational Gaps).

---

## Substrate-Wide Patterns (inherited DEFER cluster rows)

This section absorbs substrate-wide DEFER classes from the Stories 1.18–1.20 inherited DEFER sweep. Each row represents a CROSS-CUTTING pattern; per-DEFER disposition is recorded in Story 1.21 dev-story Completion Notes.

### Whole-file sha256 fragility (CRLF / whitespace / trailing-newline)

- **Skip ground:** (a) substrate-verification — substrate-wide pattern affecting every whole-file `contentHash` entry in `invariants.manifest.ts`; not Story-specific.
- **AC class skipped:** contract.
- **Back-fill effort:** M — `.gitattributes text eol=lf` enforcement OR `hashScope: 'normalized-utf8'` canonicalization layer + regression fixture across CRLF / trailing-newline / formatter-normalised inputs.
- **Risk class:** P1 — false-positive drift surfaces at pre-merge sync-gate, blocks legitimate commits without semantic regression.
- **Source:** `deferred-work.md` § Story 1.20 CR-pass-1 (2026-04-26) line 846.
- **Carry-to:** Epic 13 CI-pyramid hardening — substrate-wide canonicalization layer + regression suite.

### Whole-file sha256 lacks semantic-clause awareness (AC5 trigger-filter class)

- **Skip ground:** (a) substrate-verification — by-design at Story 1.20 AC1 lock; whole-file hash IS the contract.
- **AC class skipped:** contract, security.
- **Back-fill effort:** M — `hashScope: { yamlPath: '...' }` clause-level lock OR dedicated AC5-clause-guard test fixture (Story 1.20-style).
- **Risk class:** P1 — adversarial semantic regression could pass whole-file hash gate while regressing activation intent.
- **Source:** `deferred-work.md` § Story 1.20 CR-pass-1 (2026-04-26) line 847.
- **Carry-to:** Epic 4 hardening — semantic-content-protection class extension.

### `INV-package-test-coverage-floor` content-hash-mismatch (root-cause investigation)

- **Skip ground:** (a) substrate-verification — pre-existing on `feat/epic-2-packaged-devbox` HEAD pre-Story-1.20-edits per Subtask 9.2 inherited-failure carve-out.
- **AC class skipped:** contract.
- **Back-fill effort:** S — `git log -- packages/keel-invariants/src/check-package-test-coverage-floor.ts` trace + revert-or-rebump decision.
- **Risk class:** P1 — drift surfaces at sync-gate but the manifest entry is supporting infra, not load-bearing security.
- **Source:** `deferred-work.md` § Story 1.20 dev-story (2026-04-26) line 840 + § Story 1.20 CR-pass-1 (2026-04-26) line 848.
- **Carry-to:** Epic 4 hardening — root-cause investigation precedes contentHash re-bump; Story 1.21 dev-story records disposition (c) carry-forward (worktree-only env blocks live `git log` trace; see Completion Notes).

### `INV-git-hooks-preservation*` family worktree-mode drift

- **Skip ground:** (c) hybrid variant-(ii) "pre-existing-drift carve-out" per FR14n § ATDD-skip ground (c) — five-precedent class chain (Story 1.17 SC-9 + 1.18 SC-9 + 1.19 SC-9 + 1.20 AC6 + 1.21 AC5).
- **AC class skipped:** contract, security.
- **Back-fill effort:** L — `sync-gate.ts` `names-and-shebangs` walker rewrite to be worktree-aware; resolves the `<repoRoot>/.git/hooks` hardcoded path to the appropriate hooks dir under worktree mode.
- **Risk class:** P0 — git-hooks-preservation is fail-closed quality gate; if drift is silently dismissed, hook-bypass becomes possible.
- **Source:** RALPH.md iter-358 root cause + `deferred-work.md` § Story 1.20 dev-story (2026-04-26) lines 837–839.
- **Carry-to:** Epic 4 hardening — names-and-shebangs walker rewrite as part of the secret/SAST scanner story arc which extends `keel-invariants`.

### Story 1.18 build-config cluster (Renovate / setup-uv@v6 python-version pin / pythonpath shadowing)

- **Skip ground:** (a) substrate-verification — config files validated at land time per SC-3 / SC-4 by-design.
- **AC class skipped:** docs, contract.
- **Back-fill effort:** S — pythonpath collision fixture + setup-uv pin renovate-handling smoke + python-version drift assertion.
- **Risk class:** P2 — config-class drift; surfaces at next CI run or renovate cycle.
- **Source:** `deferred-work.md` § code review of story-1-18 (2026-04-26) lines 805–810 (4 entries).
- **Carry-to:** Epic 13 CI-pyramid hardening — substrate-wide pythonpath + python-version + renovate pin regression suite.

### Story 1.19 test-hygiene cluster (CR-1/CR-2 loose-stringMatching, CR-3 stdout-empty assertion, CR-8 JSON.parse guard, buildFixture cleanup, hasTestFile node_modules traversal, perf full-recursive-readdir, symlink-loop, REPO_ROOT resolver, EXEMPT_LIST hardcoding, CLI-tests-assume-dist, HAS_BASH_DASH guard, CR-6 jq-subtree branch, EPIPE catch)

- **Skip ground:** (a) substrate-verification — test-hygiene nits surfaced during CR-pass-1 + CR-pass-2; non-load-bearing in current cc-devbox + standard CI runners.
- **AC class skipped:** functional, contract.
- **Back-fill effort:** M — sweep all `check-*` red-tests to JSON.parse + structured shape assertion pattern + add `afterAll(rm)` cleanup + skip `node_modules`/`dist`/`coverage`/`.next`/`.turbo` in `hasTestFile` recursion + add jq-subtree-branch test + EPIPE callback form.
- **Risk class:** P1 — test-hygiene gaps + perf nits + symlink-loop edge case; regression class IS caught (just confusingly).
- **Source:** `deferred-work.md` § code review of story-1-19 (2026-04-26) lines 812–820 (7 entries) + § code review of story-1-19 CR-pass-2 (2026-04-26) lines 822–829 (6 entries).
- **Carry-to:** Epic 13 CI-pyramid hardening — test-hygiene sweep across all `check-*` test files; multi-DEFER cluster row preferable to per-nit row to keep catalogue scannable.

---

## Substrate-Adjacent Operational Gaps

This section captures non-per-story gaps surfaced during the Epic 1 REOPEN-ARC that are operational/runtime (NOT per-story-ATDD-skip class).

### iter-391 devbox-network whitelist gap

- **Missing host(s):** `results-receiver.actions.githubusercontent.com` (GitHub Actions log-results endpoint).
- **Operational impact:** `gh run view --log <run-id>` blocked inside cc-devbox; CI-failure-investigation forced to fall back to GitHub Annotation API (per iter-392 datapoint, after 4 retries — 13th cumulative SSH-egress flake datapoint).
- **Source:** RALPH.md iter-391 § Notes + iter-392 entry ("pivoted from log-fetch path (still blocked by `results-receiver.actions.githubusercontent.com` whitelist gap per iter-391 § Notes) to env-divergence-by-reasoning").
- **Carry-to:** Story 2.18 amendment OR a new Story 2.19 (pick at next substrate-ledger probe — Story 2.18 already covers devbox-network-whitelist DNS-rotation + GitHub CIDR fallback; the `results-receiver.actions.githubusercontent.com` host is currently absent from the whitelist source-of-truth). Locked at create-story: this gap is documentation-only at Story 1.21 — operational substrate fix is OUT of scope.

### api.github.com timeout class (iter-397..401 — 7 cumulative datapoints)

- **Signature:** `dial tcp 140.82.121.6:443: i/o timeout` (immediate fail; distinct from SSH-egress class which manifests as `Connection timed out` ~75s).
- **Operational impact:** `gh pr view` / `gh pr checks` commands fail at step 0h pre-flight; iteration is recoverable — local skill execution proceeds; pre-push gate retries at step 5; defer push if still down.
- **Source:** RALPH.md iter-397..401 entries (7 cumulative datapoints across iter-397/398/399/400/401).
- **Carry-to:** deferred indefinitely (network class — distinct from substrate; OUT of Story 1.21 documentation scope per AC6 lock). Operational/network class is owned by devbox image + host environment, not the BMad substrate.

---

## Out-of-Scope (Stories that landed full ATDD red-phase coverage)

The following 7 stories landed full ATDD red-phase coverage at the time and are excluded from the per-story catalog above:

- **Story 1.1** (Monorepo scaffold): structural verification (pnpm install + typecheck cache + file-invariants) + manual `git ls-files` checks at land time.
- **Story 1.3** (ESLint import-boundary rules): ephemeral smoke probes verifying rule-fire + exit codes before/after rule landing.
- **Story 1.4** (Pre-commit quality gates via prek): hook-fire probes on bad-state files with expected-failure assertions.
- **Story 1.8** (`invariants.manifest.ts` contract + exporter): manifest generation + Zod schema-validation probes.
- **Story 1.9** (Invariant sync-gate runtime): drift-detection smoke tests + round-trip manifest/INVARIANTS.md verification (also expanded by Story 1.19 backfill).
- **Story 1.10** (Design-token schema): schema-parsing probes on valid + invalid token files.
- **Story 2.6** (Host-side `pnpm devbox:*` CLI surface): command-execute smokes on CLI surface.

Stories 1.17–1.21 are EXCLUDED entirely — they constitute the bootstrap arc that landed AFTER the FR14n amendment per issue #233 (Story 1.17 + 1.18 = test runners; Stories 1.19 + 1.20 + 1.21 = backfill + activation + audit).

---

## Cross-link verification

Each per-story entry above carries a back-pointer in the originating story file's § Deferred Work / § Dev Notes / § Lessons Applied / § References section. Verification command (per Story 1.21 AC3):

```
grep -l 'test-debt.md#story-' _bmad-output/implementation-artifacts/*.md
```

Expected return: 27 story files (one per IN-SCOPE Epic 1 + Epic 2 entry above) + this `test-debt.md` itself + Story 1.21 self-reference (29 total `grep -l` matches).

---

## Carry-to consumer contract

Future Epic 4 / 13 / 14 prep iterations consume this catalogue by:

1. Reading the per-story rows + Substrate-Wide Patterns + Substrate-Adjacent Operational Gaps sections.
2. Filtering by Risk class (P0 first) + Effort (S → M → L) to prioritise backfill ordering.
3. Each Carry-to target names a specific epic OR defer-indefinitely classification — no row is "TBD".
4. When backfill lands in the named epic, append `**Resolved at:** Epic X / Story X.Y` line to the row but do NOT delete the row (audit trail preservation per § test-debt.md vs deferred-work.md vs RALPH.md audience separation in Story 1.21 Dev Notes).

This catalogue is a snapshot at Story 1.21 close-out. Future audit + sweep stories (e.g. Epic 4 close-out audit) may amend rows or add Substrate-Wide Patterns.
