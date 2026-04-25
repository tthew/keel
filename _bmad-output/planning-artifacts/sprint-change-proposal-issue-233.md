# Sprint Change Proposal — Bootstrap test runner + minimal CI for TS (Vitest) and Python (pytest under uv) (issue #233)

- **Date:** 2026-04-25
- **Trigger:** [Issue #233](https://github.com/tthew/ralph-bmad/issues/233) — repo has zero test framework, zero test files, zero CI workflow YAML across either runtime; FR14i pre-push CI gate has been operating vacuously through Stories 1.1–1.16 + Stories 2.1–2.18; merge-gating code (`packages/keel-invariants/`) is itself untested
- **Scope:** Major (introduces test runtime substrate across both TS and Python; reopens Epic 1; adds new FR + NFR; amends architecture decision deferral that has been settled-by-action since 2026-04-19)
- **Urgency:** High (do-not-defer; every additional Epic 2 story compounds the retrofit cost; FR14i is theatre until activated)
- **Mode:** Batch (Ralph autonomous; no human-in-the-loop per § Recommended Approach)
- **Target branch for delivery:** `feat/epic-2-packaged-devbox` (stacks via `chore/correct-course-test-runner-233`)
- **Authoring skill:** `/bmad-correct-course` (autonomous Ralph build mode; one workflow per iteration)

---

## Section 1 — Issue Summary

The repo has shipped 16 Epic-1 stories + 18 Epic-2 stories with **no test framework, no test files, and no CI workflow YAML** for either the TypeScript monorepo or the Python tooling (`ralph.py`, `scripts/`, `packages/devbox/tui/`).

**TypeScript surface (verified):**

- Root `package.json:12` declares `"test": "turbo run test"` — no workspace package implements it.
- No test framework dep across all 16+ workspace `package.json` files (no `vitest`, `jest`, `mocha`, `playwright`).
- Zero `*.test.ts` / `*.spec.ts` / `*.e2e.ts` files in `packages/` or `apps/`.
- `packages/keel-invariants/` ships ESLint rules, a sync-gate CLI, prompt-injection scanner rules, and per-rule `check-*.ts` enforcers — **with no test asserting rule X fires on input Y** — and this package gates merges via FR42 / FR43 / FR43a.

**Python surface (verified):**

- `ralph.py` (~67 KB), `scripts/bootstrap-bmad-agents.py`, `packages/devbox/tui/{__init__,theme}.py` exist.
- **No root `pyproject.toml`, no `uv.lock`.** Python is currently bootstrapped only via PEP 723 inline-script metadata.
- Zero pytest/unittest test files for project Python code. (`.claude/skills/*/scripts/tests/` are BMad skill-bundle tests authored upstream, not project-substrate tests.)

**CI surface (verified):**

- `.github/workflows/` contains only `release-please.yml` + `renovate.json5`. **No CI workflow YAML exists** for typecheck, lint, or test execution.
- FR14i's pre-push CI gate has been passing vacuously across every story — `gh pr checks` against PR #226 / #229 / #230 / #234 / #235 returned `[]` because no checks are registered.

**Why this is harmful now (and not deferrable to Epic 13 at M9):**

1. **Merge-gating code is untested.** `packages/keel-invariants/` enforces FR42 (anchor-walker), FR43 (sync gate), and per-rule check enforcers — this is the highest-priority untested code in the repo because every Story 1.x impl-bug in invariants logic ships under-validated.
2. **FR14i is theatre.** Every Ralph iteration since iter-22 of Story 1.7 (the first iteration after the pre-push CI gate landed in PROMPT_build.md) has reinforced a false-confidence signal.
3. **Cultural debt.** "ATDD deferred" has appeared on Stories 1.7 / 1.8 / 1.9 / 1.10 / 1.11 / 1.12 / 1.13 / 1.14 / 1.15 / 1.16 (10 cumulative — see `RALPH.md § ATDD-skip precedents`) and is now the dominant exit pattern. By Epic 13 / M9 the cost of retrofitting tests onto ~50+ stories will be 3–5× the cost of writing them in-flight.
4. **Retrofit tests encode current behaviour, not intended behaviour** — the spec-as-test signal is lost.
5. **Ship-the-smallest-thing requires *validation*.** The current loop ships the smallest thing and *asserts* it works. That's not validation.

**Discovery.** Surfaced via `/bmad-party-mode` 4-agent roundtable on 2026-04-24 (Murat / Winston / John / Amelia — strong consensus on bootstrap-first), captured in issue #233 with grep-verified evidence and file-line citations. The architecture-side root cause is the unresolved `architecture.md:154` deferral ("Testing Framework: Deferred — to be decided in architectural decisions phase"); the decision was never recorded. The PRD-side root cause is that FR14a's `Required tests:` manifest semantics presumed a runner exists and the runner-bootstrap was buried inside I7 version-pinning at M0 with no standalone story.

---

## Section 2 — Impact Analysis

### Epic Impact

| Epic    | Status                              | Impact                                                                                                                                                                                                                                  |
| ------- | ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Epic 1  | DONE (PR #226 merged)               | **REOPEN** as `in-progress`. Five new stories appended (1.17–1.21). Existing Stories 1.1–1.16 untouched (already shipped + merged). The ATDD-skip precedents that accrued across 10 stories will be swept by Story 1.21 retrospective audit. |
| Epic 2  | IN PROGRESS (PR #230, awaiting merge; Stories 2.1–2.18 done) | **Hosting branch.** This proposal lands on `feat/epic-2-packaged-devbox` so it ships in the same merge window as Epic 2. **No Epic 2 spec changes.** Story 1.17–1.21 implementation iterations may opportunistically backfill Epic 2 ATDD scaffolds where cheap, but full backfill is out of scope (scoped into Story 1.21). |
| Epic 3  | Backlog                             | None. Epic 3 (Ralph harness) consumes test infra; bootstrap precedes it cleanly.                                                                                                                                                        |
| Epic 4  | Backlog                             | **Hard dependency on Story 1.19.** Epic 4 (Per-iteration security verification) extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners. Story 1.19 backfill is a precondition — Epic 4 cannot start with the substrate enforcement layer untested. Recorded as a sequencing note in `epics.md` Epic 4 frontmatter, not as a story-level dependency. |
| Epic 13 | Backlog (M9)                        | **No scope change.** Epic 13 remains the consumer of test infra (full CI pyramid: pre-merge-fast / pre-merge-slow / nightly / release-gated). Bootstrap does NOT collapse the CI pyramid into M0/M1 — minimal CI in Story 1.17/1.18 is one workflow file (`ci.yml`) running `pnpm turbo run test lint typecheck` + `uv run pytest`; the per-tier decomposition stays at M9. |
| Epic 14 | Backlog (M10)                       | **No scope change.** Epic 14 (research corpus + flake-log measurement) consumes mature test infra. Bootstrap does NOT pull C4 (`T-\d{4}` test-id ESLint rule) or M3 (flake-log schema freeze) forward.                                  |
| Epics 5–12, 15a, 15b | Backlog                  | None. All consumers; bootstrap is upstream.                                                                                                                                                                                            |

**Net Epic 1 story count:** 16 → **21**. Re-numbering not required (1.17–1.21 appended after 1.16; sprint-status.yaml gets five new keys under `epic-1:`).

### Story Impact

| Story                                                                               | Existing scope                                          | Change                                                                                                                                                                                              |
| ----------------------------------------------------------------------------------- | ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **NEW Story 1.17** — Bootstrap TypeScript test runner + minimal CI                 | —                                                       | Vitest pinned exactly per I7 in `packages/config` + root `pnpm.overrides`; root `vitest.workspace.ts`; one smoke test wiring `packages/keel-invariants/`; `turbo.json` `test` task; `.github/workflows/ci.yml` running `pnpm install --frozen-lockfile && pnpm turbo run test lint typecheck`; AGENTS.md / CLAUDE.md command-table updates. **Small** (~1 day; ~5 files touched). |
| **NEW Story 1.18** — Bootstrap Python test runner under uv                          | —                                                       | Root `pyproject.toml` + `uv.lock` declaring shared dev deps (pytest, pytest-asyncio, ruff, mypy); test scaffolds for `ralph.py` (arg-parser sanity), `scripts/bootstrap-bmad-agents.py`, `packages/devbox/tui/`; CI workflow extended with a `python` job (`uv run pytest`); AGENTS.md / CLAUDE.md updates. **Small** (~1 day; ~6 files touched). NEW — not previously in any epic. |
| **NEW Story 1.19** — Backfill `keel-invariants` test coverage                       | —                                                       | Tests for each ESLint rule (positive + negative); tests for the sync-gate CLI (`packages/keel-invariants/src/check.ts`, `manifest-reader.ts`, `sync-gate.ts`, per-rule `check-*.ts` enforcers); tests for `invariants.manifest.ts` shape contract (Zod parse rejection cases). **Medium** (~2 days; ~20 test files). Highest-risk untested code in repo. |
| **NEW Story 1.20** — Activate FR14i for real (end vacuous-pass)                     | —                                                       | After Story 1.17 / 1.18 land `ci.yml`, FR14i's pre-push gate becomes non-vacuous. RALPH.md execute-spine documentation update; new invariant: "If `.github/workflows/ci.yml` is absent, FR14i is in the known-incomplete state — Ralph MAY push (gate degrades to no-op) but the orient phase MUST surface a notice." Registered in `invariants.manifest.ts` as `INV-fr14i-ci-workflow-presence`. **Small** (~half day). |
| **NEW Story 1.21** — Sweep prior `ATDD deferred` stories into `test-debt:` follow-ups | —                                                     | Audit Stories 1.1–1.16 + 2.1–2.18 for ATDD-skip notes; open `test-debt:` follow-ups per affected story; sequence into Epic 1 backlog (parallel to Story 1.19 — does NOT block Epic 2 close-out). Goal: net-zero ATDD-skip entries by close of Epic 1's reopen window. **Medium** (~2 days; mostly audit + spec edits, no impl). |
| Story 1.7 (knowledge files)                                                          | Cross-reference to FR14j upkeep contract                | **No scope change.** ATDD-skip already documented and shipped; Story 1.21 audit sweeps the pre-existing skip into a `test-debt:` entry; no in-place spec edit.                                       |
| Stories 1.1–1.6 / 1.8–1.16                                                          | Various ATDD postures                                   | **No scope change.** Story 1.21 audit catalogues each per pattern; backfill follow-ups land as test-debt items (deferred work — not gating Epic 1 reopen close-out).                                  |
| Stories 2.1–2.18                                                                     | Various ATDD postures                                   | **No scope change.** Same audit pattern as 1.x. Some Epic 2 stories may have stronger substrate-verification grounds (e.g., shell-level smoke probes for nftables / dnsmasq) — Story 1.21 records the ground per story.                                                                                                              |
| Stories 2.18+ (future Epic 2 work)                                                   | Pre-bootstrap ATDD skip via FR14n matrix row 3          | **Material change.** Once Story 1.17 / 1.18 land, the FR14n § matrix row-3 ATDD-skip clause's ground (b) ("no test runner exists") narrows materially. Spec amendment pinned in PRD FR14n carry-forward note (see § Artifact Conflicts → PRD). |
| Story 3.34 (Ralph doc-budget)                                                        | Already shipped (PR #234 merged; issue #231)            | **No scope change.** This proposal does not amend doc-budget enforcement; the two course-corrections are independent.                                                                                |
| Story 2.18 (devbox network)                                                          | Already shipped (PR #235 merged; issue #232)            | **No scope change.** Devbox network whitelist is independent.                                                                                                                                       |

### Artifact Conflicts

| Artifact                                                                                       | Conflict                                                                                                                                                                                                                                                                | Resolution                                                                                                                                                                                                                                                                                                                                                                       |
| ---------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **PRD** `_bmad-output/planning-artifacts/prd.md` § FR14a (Acceptance-Driven Backpressure) | `Required tests:` manifest semantics presume a runner exists; vacuous-pass mode unrecoverable from the spec text                                                                                                                                                       | **AMEND FR14a** with a clause: "Once a test runner is wired (Story 1.17 / 1.18), `Required tests:` entries MUST reference real files; an entry that does not resolve to a discoverable test in the configured runner fails the FR14a2 manifest-immutability gate. Pre-runner stories (1.1–1.16 + 2.1–2.18) are grandfathered — the audit lands as Story 1.21." |
| PRD § FR14i (Pre-push CI gate)                                                                  | Currently passes vacuously when no checks are registered                                                                                                                                                                                                              | **AMEND FR14i** with a clause: "When `.github/workflows/ci.yml` is absent (pre-Story 1.20 substrate state), the gate degrades to a no-op pass — Ralph MAY push, but the orient phase MUST surface a notice that FR14i is in the known-incomplete state. Story 1.20 lands the activation."                                                                                |
| PRD § FR14n (Story-lifecycle matrix) ATDD-skip clause (matrix row 3)                            | Ground (b) "no test runner exists" is the load-bearing skip ground for many Epic-1 + Epic-2 substrate stories                                                                                                                                                          | **AMEND FR14n** with a sunset clause: "Ground (b) (no-runner) sunsets when Story 1.17 / 1.18 land. Post-bootstrap stories MUST cite ground (a) substrate-verification or ground (c) hybrid; bare ground (b) is no longer sufficient. Pre-bootstrap stories are grandfathered (Story 1.21 audit)."                                                                          |
| **NEW PRD entry: FR14o (Test runner mandate)**                                                  | No FR currently mandates a test runner exists                                                                                                                                                                                                                          | **ADD FR14o** under § Agent Workflow Contracts (sibling to FR14j, FR14n): mandate Vitest at root for TS workspace + pytest under uv at root for Python, with `pnpm test` + `uv run pytest` as canonical entry points. Non-toggle-able at substrate level; forks may add additional runners but cannot remove these.                                                          |
| **NEW PRD entry: NFR1a (Test coverage floor)**                                                  | NFR1 covers wall-clock budgets; no NFR mandates per-package coverage minimum                                                                                                                                                                                          | **ADD NFR1a** under § Performance: "Every package with `src/` MUST have at least one passing test. Enforced at substrate level by `INV-package-test-coverage-floor` (registered in `packages/keel-invariants/src/invariants.manifest.ts` by Story 1.19); drift-detected by Story 1.9's sync-gate. Pre-bootstrap packages are exempt until Story 1.21 audit lands their backfill." |
| **Architecture** `_bmad-output/planning-artifacts/architecture.md:154` (Testing Framework deferral) | Says "Deferred — to be decided in architectural decisions phase. Natural fits: Vitest, Playwright" — decision never recorded                                                                                                                                            | **REPLACE** the deferral with the recorded decision: "Testing Framework: **Vitest** for TypeScript (aligned with Vite + TS workspace; Story 1.17). **pytest under uv** for Python (`ralph.py`, `scripts/`, `packages/devbox/tui/`; Story 1.18). Playwright deferred to Epic 13 (E2E + visual regression at M9)."                                                                                              |
| **NEW Architecture section: M0 substrate developer-productivity floor**                         | Architecture has no section listing minimum testable-state requirements                                                                                                                                                                                                | **ADD** new sub-section under § Core Architectural Decisions, after § Data Architecture: lists Vitest + pytest + minimal `ci.yml` as M0 substrate floor; cites Stories 1.17 / 1.18 / 1.19 / 1.20 / 1.21 as the bootstrap arc; confirms D3 (RLS pglite + testcontainers strategy) and C4 (`T-\d{4}` ESLint rule) and D4 (RLS perf benchmark) all remain at M9 — bootstrap does NOT pull them forward. |
| **Epics** `_bmad-output/planning-artifacts/epics.md` Epic 1                                     | 16 stories; no test-runner bootstrap stories                                                                                                                                                                                                                            | **APPEND Stories 1.17–1.21** between Story 1.16 (line 1138) and Epic 2 heading (line 1142) with full user-story format + AC blocks matching the prevailing Epic 1 style.                                                                                                                                                                                                       |
| **Epics** Epic 4 frontmatter                                                                     | Epic 4 (security verification) extends `packages/keel-invariants/` — Story 1.19 backfill is a hard precondition                                                                                                                                                       | **ADD** sequencing note to Epic 4 § Implementation Notes: "Hard dependency on Story 1.19 — Epic 4 cannot start with the substrate enforcement layer untested."                                                                                                                                                                                                              |
| **Sprint status** `_bmad-output/implementation-artifacts/sprint-status.yaml`                    | `epic-1: done`; no rows for 1.17–1.21                                                                                                                                                                                                                                  | **REOPEN**: `epic-1: done → in-progress`. **APPEND** five new rows under `epic-1:`: `1-17-...: backlog`, `1-18-...: backlog`, `1-19-...: backlog`, `1-20-...: backlog`, `1-21-...: backlog`. Update `last_updated` line.                                                                                                                                                |
| `RALPH.md`, `.ralph/PROMPT_build.md`                                                            | FR14i pre-push gate currently treated as load-bearing in PROMPT_build.md while CI is in fact absent; § ATDD-skip-precedents in RALPH.md ground-(b) clauses                                                                                                              | **Out of scope** for this proposal — these update in the implementation iterations of Story 1.20 (RALPH.md execute-spine) and Story 1.21 (RALPH.md ATDD-skip-precedents sweep). PROMPT_build.md text is stable across this proposal; the substrate change activates the previously-vacuous gate.                                                                              |
| `INVARIANTS.md` + `packages/keel-invariants/src/invariants.manifest.ts`                          | No `INV-package-test-coverage-floor` and no `INV-fr14i-ci-workflow-presence` rows                                                                                                                                                                                     | **Out of scope** for this proposal — registration lands in Story 1.19 (the floor invariant) + Story 1.20 (the FR14i activation invariant). Neither is a Day-1 manifest entry on this branch (would flap the Story 1.9 sync-gate against in-flight stories).                                                                                                                  |
| `AGENTS.md` / `CLAUDE.md` common-commands table                                                  | No `pnpm test` / `uv run pytest` rows                                                                                                                                                                                                                                | **Out of scope** for this proposal — added in Story 1.17 (TS) + Story 1.18 (Python) impl iterations.                                                                                                                                                                                                                                                                       |

### Technical Impact

- **No code shipped by this proposal.** Spec deltas only across PRD + Architecture + Epics + sprint-status.
- **Implementation footprint** (forecast across Stories 1.17–1.21, recorded for handoff fidelity):
  - Story 1.17: `packages/config/package.json` (Vitest pin), root `package.json` `pnpm.overrides`, root `vitest.workspace.ts`, `packages/keel-invariants/vitest.config.ts`, `packages/keel-invariants/src/__tests__/smoke.test.ts`, `turbo.json` `test` task, `.github/workflows/ci.yml`, `AGENTS.md` + `CLAUDE.md` command tables.
  - Story 1.18: root `pyproject.toml`, `uv.lock`, test scaffolds at `tests/test_ralph.py` + `scripts/tests/test_bootstrap_bmad_agents.py` + `packages/devbox/tui/tests/test_theme.py`, `.github/workflows/ci.yml` extension (python job), AGENTS / CLAUDE updates.
  - Story 1.19: ~20 test files under `packages/keel-invariants/src/__tests__/` (one per ESLint rule + one per check-*.ts enforcer + sync-gate CLI integration tests + manifest Zod-shape tests).
  - Story 1.20: `RALPH.md` execute-spine update, `INV-fr14i-ci-workflow-presence` registration in `invariants.manifest.ts` + `INVARIANTS.md` index entry, sync-gate re-run.
  - Story 1.21: spec-only edits to `_bmad-output/implementation-artifacts/test-debt.md` (NEW file) cataloguing ATDD-skip backfill candidates per Story 1.x + Story 2.x; references in each story file's § Deferred Work.
- **Risk classification:** Major scope. Five new stories touch substrate (`packages/keel-invariants/`, root `package.json`, `.github/workflows/`, root `pyproject.toml`); blast radius is "substrate test infra" for the entire repo; failure mode is "Vitest / pytest pinning mismatch trips Story 1.9 sync-gate or breaks pre-merge-fast" caught by the per-story implementation iteration's quality-gate suite.

---

## Section 3 — Recommended Approach

**Direct Adjustment** — modify/add stories within existing plan.

Rationale:

1. **Rollback path is closed.** Epic 1 PR #226 has merged; rolling back substrate-side ATDD postures is mechanically impossible without rewriting merged history.
2. **MVP review path is overkill.** The MVP scope (Stories 1.1–1.16 + Epic 2 Sandboxed Execution) is correct; the gap is purely substrate floor missing, not product-scope wrong.
3. **Direct adjustment fits the precedent.** Two prior course-corrections (#231 doc-budget, #232 devbox-network) used direct-adjustment by appending stories to existing/next epics. This proposal extends the pattern to a *closed* epic (a precedent-extension, but materially the same shape).

**Effort estimate:** 5 stories × ~1.4 days average = ~7 days of Ralph build-mode iteration time, parallelizable along two axes: Stories 1.17 + 1.18 can run in parallel (no shared files except CI workflow YAML); Story 1.19 starts after 1.17 lands; Stories 1.20 + 1.21 start after 1.19 lands. Total wall-clock with parallelism: ~4–5 days.

**Risk assessment:**

- **Low** — Vitest + pytest are mature; the integration risk is package-pin mismatch (mitigated by I7 exact-version policy + Story 1.9 sync-gate).
- **Medium** — Story 1.19 backfill exposes pre-existing impl bugs in `keel-invariants`. Fix-loop iterations expected per the FR14n CR cycle. Budget 4–6 CR iterations for Story 1.19 (vs the 1–2 typical for substrate-stage stories).
- **Low** — Story 1.20 gate activation may surface latent vacuous-pass behaviours in PR #230 / future Epic 2 PRs; mitigated by the FR14i degradation clause (no behavioural change pre-CI-workflow-existence).
- **Medium** — Story 1.21 audit may surface ATDD-skip patterns that are weaker than recorded in RALPH.md § ATDD-skip-precedents; the audit may identify backfill candidates that would have been better tested in-flight. Mitigation: backfill is queued as `test-debt:` follow-ups (deferred), not as required gating work.

**Timeline impact:** Adds ~5 days to the Epic 1-and-2 close-out window (PR #226 already merged; PR #230 awaiting merge with Stories 2.1–2.18; this proposal stacks via PR #236 targeting `feat/epic-2-packaged-devbox`). Epic 3 (Ralph harness) start moves out by the same window. Epics 4–15b are unaffected (all backlog).

---

## Section 4 — Detailed Change Proposals

### 4.1 — PRD amendments (`_bmad-output/planning-artifacts/prd.md`)

**Add FR14o** under § Agent Workflow Contracts, immediately after FR14n (line 968):

```
- **FR14o (Test runner mandate)**: System ships a test runner for both substrate runtimes. **TypeScript:** Vitest pinned exactly per I7 in `packages/config` + `pnpm.overrides`; root `vitest.workspace.ts` discovers per-package `vitest.config.ts`; `pnpm test` is the canonical entry point. **Python:** pytest under uv (root `pyproject.toml` declaring shared dev deps including pytest, pytest-asyncio, ruff, mypy; `uv.lock` pinned); `uv run pytest` is the canonical entry point. **CI integration:** `.github/workflows/ci.yml` runs `pnpm install --frozen-lockfile && pnpm turbo run test lint typecheck` plus a `python` job running `uv run pytest`; required check on `main`. Non-toggle-able at substrate level; forks may add additional runners (e.g., Playwright at Epic 13) but cannot remove these. Implementation lands in Story 1.17 (TS) + Story 1.18 (Python) + Story 1.20 (FR14i activation). Normative spec: § Agent Workflow Contracts → Test runner mandate.
```

**Amend FR14a** (line 948): append the following sentence to the existing prose:

```
**Once a test runner is wired (FR14o; Stories 1.17 / 1.18 land):** `Required tests:` entries MUST reference real files in the configured runner; an entry that does not resolve to a discoverable test fails the FR14a2 manifest-immutability gate at pre-merge-fast. Pre-bootstrap stories (1.1–1.16 + 2.1–2.18) are grandfathered — the manifest semantics tighten only for stories drafted post-bootstrap. Story 1.21 audits prior stories and produces `test-debt:` follow-ups; Story 1.21 does NOT retroactively rename or delete pre-bootstrap manifest entries.
```

**Amend FR14i** (line 959): append the following sentence:

```
**Pre-bootstrap degradation:** When `.github/workflows/ci.yml` is absent (pre-Story 1.20 substrate state), the gate degrades to a no-op pass — Ralph MAY push, but the orient phase MUST surface a `FR14i: vacuous-pass mode` notice. Story 1.20 lands the activation invariant `INV-fr14i-ci-workflow-presence` registering the workflow's presence in `packages/keel-invariants/src/invariants.manifest.ts`; once registered, FR14i operates as specified above (real CI checks block the push).
```

**Amend FR14n** (line 968): append the following sentence after the existing "Ninth anti-constraint" prose:

```
**ATDD-skip ground-(b) sunset (2026-04-25 amendment per issue #233):** Matrix row 3's ATDD-skip clause has three grounds — (a) substrate-verification covers AC, (b) no test runner exists, (c) hybrid (downstream-story-covers-integration / spec-declared-CR-substitution / Zod-upstream-owns-correctness). Ground (b) sunsets when Story 1.17 / 1.18 land — post-bootstrap stories MUST cite ground (a) or ground (c); bare ground (b) is no longer sufficient. Pre-bootstrap stories are grandfathered (audited by Story 1.21). The matrix-state-transition (validated → atdd-scaffolded) is unchanged; only the ground-justification narrows.
```

**Add NFR1a** under § Performance, immediately after NFR1 (line 1066):

```
- **NFR1a (Test coverage floor)**: Every workspace package with a `src/` directory MUST have at least one passing test. Enforced at substrate level by `INV-package-test-coverage-floor` (registered in `packages/keel-invariants/src/invariants.manifest.ts` by Story 1.19); drift-detected by Story 1.9's sync-gate. Pre-bootstrap packages (`packages/keel-invariants`, `packages/keel-templates`, `packages/devbox`) are exempt until Story 1.19 (keel-invariants) / Story 1.21 (audit + backfill follow-ups for keel-templates / devbox) land their coverage. The floor is "≥ 1 test passes," not a percentage — percentage thresholds are deferred to Epic 14 (research corpus + flake-log measurement) per NFR28b's empirical-baseline methodology. Non-toggle-able at substrate level; forks may add additional coverage gates but cannot weaken the floor.
```

### 4.2 — Architecture amendments (`_bmad-output/planning-artifacts/architecture.md`)

**Replace line 154** (Testing Framework deferral):

OLD:

```
**Testing Framework:** Deferred — to be decided in architectural decisions phase. Natural fits: Vitest (aligns with Vite+TS workspace), Playwright (PRD pins it for end-to-end + devbox bakes browser deps at image build).
```

NEW:

```
**Testing Framework:** **Vitest** for TypeScript (aligned with Vite + TS workspace; pinned per I7 in `packages/config` + `pnpm.overrides`; Story 1.17 implementation). **pytest under uv** for Python tooling (`ralph.py`, `scripts/`, `packages/devbox/tui/`; root `pyproject.toml` + `uv.lock`; Story 1.18 implementation). **Playwright** is deferred to Epic 13 / M9 (E2E + visual-regression tier; devbox already bakes browser deps at image build per PRD M0.5). See § M0 substrate developer-productivity floor for the bootstrap arc.
```

**Add new section** § M0 substrate developer-productivity floor, immediately after § Data Architecture (insert before line 196 § Authentication & Security):

```
### M0 substrate developer-productivity floor

The minimum testable substrate state below which all FRs / NFRs that depend on test execution operate vacuously (FR14a, FR14a2, FR14a3, FR14i, FR29, FR42-side enforcement). Bootstrapped via the issue #233 course correction (Stories 1.17–1.21 reopened Epic 1 cleanup pass).

**TypeScript runtime substrate:**
- **Runner:** Vitest, pinned exactly per I7 in `packages/config` + root `pnpm.overrides`.
- **Workspace discovery:** root `vitest.workspace.ts` globbing `packages/*/vitest.config.ts`.
- **Per-package configuration:** each workspace package with `src/` ships `vitest.config.ts` (node env or jsdom env per package needs) + a `"test": "vitest run"` script.
- **Turbo orchestration:** `turbo.json` `test` task with `dependsOn: ["^build"]` + `outputs: ["coverage/**"]`.
- **Canonical entry point:** `pnpm test` (resolves to `pnpm turbo run test`).

**Python runtime substrate:**
- **Project shape:** root `pyproject.toml` + `uv.lock` declaring shared dev deps (pytest, pytest-asyncio, ruff, mypy). Resolves the per-script PEP 723 inline-metadata pattern's discovery + dep-sharing limits.
- **Discovery:** pytest's default `tests/` + `*_test.py` + `test_*.py` collection across the repo (with explicit `[tool.pytest.ini_options]` `testpaths` block in `pyproject.toml` listing project test roots).
- **Canonical entry point:** `uv run pytest`.

**CI integration:**
- **Workflow:** single `.github/workflows/ci.yml` running on PR + push-to-main. Two jobs: (a) `node` — `pnpm install --frozen-lockfile && pnpm turbo run test lint typecheck`; (b) `python` — `uv sync && uv run pytest`. Required check on `main`.
- **Tier scope:** this is the **minimal** CI workflow — single tier, deterministic, no live-network. The full decomposed CI pyramid (pre-merge-fast / pre-merge-slow / nightly / release-gated per NFR1) lands in Epic 13 / M9. Bootstrap does NOT pull the pyramid forward.

**Coverage floor:** NFR1a (≥ 1 passing test per package with `src/`); enforced via `INV-package-test-coverage-floor` invariant registered in Story 1.19. Percentage thresholds deferred to Epic 14 / M10 per NFR28b empirical-baseline methodology.

**Stories 1.17–1.21** form the bootstrap arc:
- Story 1.17 — TS runner + minimal CI;
- Story 1.18 — Python runner + uv project shape;
- Story 1.19 — `keel-invariants` test backfill (highest-risk untested code, gates merges via FR42 / FR43 / FR43a);
- Story 1.20 — activate FR14i for real (end vacuous-pass mode);
- Story 1.21 — audit + sweep prior ATDD-deferred stories into `test-debt:` follow-ups.

**Decisions held at M9 / M10 (not pulled forward by bootstrap):**
- D3 (synthetic-schema strategy: pglite at pre-merge-fast + testcontainers at pre-merge-slow) — M9.
- D4 (RLS p95 perf-budget benchmark harness) — M9 nightly.
- C4 (`T-\d{4}` stable test-id ESLint rule + `packages/keel-invariants/eslint-rules/stable-test-id.cjs`) — M9.
- M3 (flake-log schema freeze; Murat's Round 1 amendment) — M10 (Epic 14).

**Affects:** PRD § FR14a / FR14i / FR14n / FR14o / NFR1a; this section consolidates the substrate-floor handoff for the Stories 1.17–1.21 implementation arc.
```

### 4.3 — Epics amendments (`_bmad-output/planning-artifacts/epics.md`)

**Append Stories 1.17–1.21** between line 1141 (`---`) and line 1142 (`### Epic 2`). Full user-story format with AC blocks (see Section 4.6 below for the rendered story content; insert verbatim before the `### Epic 2:` heading).

**Amend Epic 4 § Implementation Notes** (frontmatter): add a sequencing note: "Hard dependency on Story 1.19 — Epic 4 cannot start with the substrate enforcement layer untested. The `packages/keel-invariants/` package (which Epic 4 extends with secret/SAST/prompt-injection scanners per FR35–FR40) MUST have its Story 1.19 backfill landed before Story 4.1 starts."

### 4.4 — Sprint status amendment (`_bmad-output/implementation-artifacts/sprint-status.yaml`)

```yaml
# last_updated: 2026-04-25 Epic-1-reopened-for-issue-233-bootstrap UTC
# (existing last_updated lines preserved)

development_status:
  epic-1: in-progress  # was: done — reopened by issue #233 SCP for Stories 1.17–1.21 (test runner bootstrap pass)
  # (existing 1-1 .. 1-16 rows unchanged)
  1-17-bootstrap-typescript-test-runner-vitest-minimal-ci: backlog
  1-18-bootstrap-python-test-runner-pytest-under-uv: backlog
  1-19-backfill-keel-invariants-test-coverage: backlog
  1-20-activate-fr14i-for-real-end-vacuous-pass: backlog
  1-21-sweep-prior-atdd-deferred-stories-into-test-debt-followups: backlog
  epic-1-retrospective: optional
  # (Epic 2 .. Epic 15b rows unchanged)
```

### 4.5 — Out-of-scope (carried into per-story implementation iterations)

- `RALPH.md` execute-spine update (Story 1.20).
- `RALPH.md § ATDD-skip-precedents` audit + amendment (Story 1.21).
- `AGENTS.md` / `CLAUDE.md` common-commands table additions (Stories 1.17 + 1.18).
- `INVARIANTS.md` index entries for `INV-package-test-coverage-floor` + `INV-fr14i-ci-workflow-presence` (Stories 1.19 + 1.20).
- `packages/keel-invariants/src/invariants.manifest.ts` registration of the same two invariants (Stories 1.19 + 1.20).
- Test-debt follow-up file at `_bmad-output/implementation-artifacts/test-debt.md` (Story 1.21).

### 4.6 — Story content for epics.md insertion

(Full story bodies — to be inserted verbatim into `epics.md` between line 1141 and line 1142.)

##### Story 1.17: Bootstrap TypeScript test runner (Vitest) + minimal CI workflow

As a substrate operator who needs Ralph's pre-push CI gate (FR14i) to be non-vacuous and `Required tests:` (FR14a) to reference real files,
I want Vitest installed at the workspace root, pinned per I7, with one smoke test wiring `packages/keel-invariants/` and a `.github/workflows/ci.yml` running `pnpm turbo run test lint typecheck`,
So that every subsequent Ralph iteration can validate behaviour against running tests rather than against vacuous "no checks reported" CI passes (FR14o; closes the architecture.md:154 deferral; resolves issue #233 for the TS runtime).

**Acceptance Criteria:**

**Given** a fresh devbox checkout of `feat/epic-2-packaged-devbox` post-Story 1.17,
**When** I run `pnpm install --frozen-lockfile && pnpm test`,
**Then** Vitest discovers and runs `packages/keel-invariants/src/__tests__/smoke.test.ts`
**And** the smoke test passes
**And** the exit code is 0.

**Given** the Vitest pin in `packages/config/package.json` and `pnpm.overrides` in root `package.json`,
**When** Story 1.9's sync-gate runs (`pnpm keel-invariants:check`),
**Then** the manifest's `INV-deps-version-pinning` row remains green (Vitest + transitive deps version-pinned per I7 exact-version policy).

**Given** the `.github/workflows/ci.yml` workflow,
**When** a PR is opened against `main`,
**Then** the `node` job runs `pnpm install --frozen-lockfile && pnpm turbo run test lint typecheck`
**And** the workflow is marked as a required check on `main`.

**Given** the `turbo.json` `test` task,
**When** `pnpm test` runs,
**Then** the task uses `dependsOn: ["^build"]` (build prerequisites resolve first)
**And** declares `outputs: ["coverage/**"]` for Turbo cache fidelity.

**Given** the AGENTS.md + CLAUDE.md common-commands tables,
**When** I run `pnpm test` from the repo root,
**Then** the table row exists documenting the command.

##### Story 1.18: Bootstrap Python test runner (pytest under uv) + project shape

As a substrate operator with Python tooling (`ralph.py`, `scripts/`, `packages/devbox/tui/`) currently bootstrapped only via PEP 723 inline-script metadata,
I want a root `pyproject.toml` + `uv.lock` declaring shared dev deps (pytest, pytest-asyncio, ruff, mypy) and pytest test scaffolds for each Python module,
So that Python code has the same test-validation discipline as TypeScript code (FR14o; new architectural decision per architecture.md § M0 substrate developer-productivity floor; resolves issue #233 for the Python runtime).

**Acceptance Criteria:**

**Given** the root `pyproject.toml` declaring `[tool.pytest.ini_options]` testpaths,
**When** I run `uv sync && uv run pytest`,
**Then** pytest discovers and runs the test scaffolds (`tests/test_ralph.py` + `scripts/tests/test_bootstrap_bmad_agents.py` + `packages/devbox/tui/tests/test_theme.py`)
**And** all scaffolds pass
**And** the exit code is 0.

**Given** the `.github/workflows/ci.yml` workflow extension,
**When** a PR is opened against `main`,
**Then** a `python` job runs `uv sync && uv run pytest`
**And** the job is marked as a required check on `main` alongside the `node` job from Story 1.17.

**Given** the `uv.lock` pinning,
**When** `uv sync` runs,
**Then** the lockfile resolves deterministically (identical versions across CI runs)
**And** Story 1.9's sync-gate (extended in Story 1.20 to cover Python deps if applicable) does not flag drift.

**Given** the AGENTS.md + CLAUDE.md common-commands tables,
**When** I run `uv run pytest` from the repo root,
**Then** the table row exists documenting the command.

**Given** existing PEP 723 inline-metadata in `ralph.py` (declaring `textual>=1.0.0` etc.),
**When** root `pyproject.toml` declares overlapping deps,
**Then** the test scaffolds run successfully under both invocation paths
**And** the migration plan (single source vs dual source) is recorded in the story's Dev Agent Record.

##### Story 1.19: Backfill `keel-invariants` test coverage

As a substrate operator who relies on `packages/keel-invariants/` to gate merges via FR42 / FR43 / FR43a,
I want test coverage for every ESLint rule, every per-rule `check-*.ts` enforcer, the sync-gate CLI, and the `invariants.manifest.ts` Zod-shape contract,
So that the highest-priority untested code in the repo is no longer untested before Epic 4 (per-iteration security verification) starts extending it (NFR1a; closes issue #233 D2 sequencing decision).

**Acceptance Criteria:**

**Given** each ESLint rule in `packages/keel-invariants/src/`,
**When** Story 1.19 lands,
**Then** there exists at least one positive test (rule fires on offending input) AND one negative test (rule does NOT fire on compliant input) per rule
**And** all tests pass via `pnpm --filter @keel/keel-invariants test`.

**Given** each per-rule `check-*.ts` enforcer (`check-claude-hook-syntax.ts`, `check-nfr5a-minimum.ts`, `check-no-committed-dotfiles.ts`),
**When** Story 1.19 lands,
**Then** there exists at least one integration test invoking the enforcer's CLI entry point against a fixture directory tree
**And** the test asserts both the green-path exit-code-0 and the red-path exit-code-1 + structured JSON drift report.

**Given** the sync-gate CLI (`packages/keel-invariants/src/check.ts` + `manifest-reader.ts` + `sync-gate.ts`),
**When** Story 1.19 lands,
**Then** there exists at least one integration test exercising each of the four drift classes (added-to-source-only / removed-from-source-only / removed-from-docs-only / content-hash-mismatch)
**And** each drift class produces the expected exit-code-1 + DriftReport JSON shape.

**Given** the `invariants.manifest.ts` Zod schema,
**When** Story 1.19 lands,
**Then** there exists at least one schema-rejection test per malformed-input class (bad ID format, missing required field, content-hash regex violation, empty anchors, non-existent sourcePath)
**And** each malformed input produces a Zod parse error.

**Given** the new invariant `INV-package-test-coverage-floor`,
**When** Story 1.19 registers it in `invariants.manifest.ts` + `INVARIANTS.md` index,
**Then** Story 1.9's sync-gate passes against the registered manifest entry
**And** the invariant's check-*.ts enforcer (or sync-gate built-in check) walks workspace packages and reports `coverage-floor-violation` for any `src/`-bearing package without ≥ 1 passing test.

**Given** Story 1.19's CR pass,
**When** `/bmad-code-review (args: "2")` runs,
**Then** all action items are addressed in QUEUE fix iterations OR explicitly deferred with `defer:` rationale
**And** Story 1.19 transitions `sm-verified → done` with no un-addressed CR findings.

##### Story 1.20: Activate FR14i for real (end vacuous-pass mode)

As a Ralph operator whose pre-push CI gate (FR14i) has been passing vacuously across every Story 1.x and 2.x iteration,
I want the gate to operate as specified once `.github/workflows/ci.yml` exists, with explicit substrate-side verification that the workflow file is registered in the invariants manifest,
So that future Ralph iterations cannot regress the gate to vacuous-pass mode by accidentally deleting or renaming the workflow file (FR14i amendment per issue #233; new invariant `INV-fr14i-ci-workflow-presence`).

**Acceptance Criteria:**

**Given** Story 1.17 + 1.18 have landed (`.github/workflows/ci.yml` exists),
**When** Story 1.20 registers `INV-fr14i-ci-workflow-presence` in `packages/keel-invariants/src/invariants.manifest.ts`,
**Then** the manifest entry's `sourcePath` is `.github/workflows/ci.yml`
**And** the entry's `contentHash` matches the file's sha256
**And** Story 1.9's sync-gate passes.

**Given** the workflow file is deleted or moved,
**When** the sync-gate runs,
**Then** the gate fails with `content-hash-mismatch` OR `source-not-found` per the manifest semantics
**And** the failure blocks pre-merge-fast.

**Given** RALPH.md's execute-spine documentation (orient step 0h, execute step 5),
**When** Story 1.20 amends the doc,
**Then** the orient step explicitly references "FR14i operates non-vacuously when `INV-fr14i-ci-workflow-presence` is green"
**And** the execute step references the activation as in-effect post-Story 1.20.

**Given** the `INVARIANTS.md` index entry for `INV-fr14i-ci-workflow-presence`,
**When** Story 1.20 lands,
**Then** the entry references the manifest row + the docs/invariants/fr14i.md note (or inline anchor in docs/invariants/ralph-execute.md if no dedicated doc exists)
**And** Story 1.9's sync-gate's anchor-walker resolves the entry.

##### Story 1.21: Sweep prior `ATDD deferred` stories into `test-debt:` follow-ups

As a substrate operator who has accumulated 10+ ATDD-skip precedents across Stories 1.7–1.16 (RALPH.md § ATDD-skip-precedents) plus an unmeasured count across Stories 2.1–2.18,
I want a single audit pass producing `test-debt:` follow-up entries cataloguing each pre-bootstrap story's coverage gap with the ground (a/b/c) it cited at skip time,
So that the test-debt is visible (not invisible accumulating drift), prioritisable (we can rank by risk), and bounded (no further ATDD-skip ground (b) accrues post-bootstrap per FR14n amendment per issue #233).

**Acceptance Criteria:**

**Given** the audit walks Stories 1.1–1.16 + 2.1–2.18,
**When** Story 1.21 lands,
**Then** there exists `_bmad-output/implementation-artifacts/test-debt.md` with one entry per story carrying an ATDD-skip
**And** each entry records (a) the skip ground cited (a/b/c per FR14n matrix row 3); (b) the AC class skipped (functional / RLS / security / contract / docs); (c) the back-fill estimated effort (S / M / L); (d) the risk class (P0 highest-risk substrate enforcement code / P1 / P2).

**Given** post-bootstrap stories,
**When** any future story drafts an ATDD-skip with bare ground (b),
**Then** the FR14n amendment per issue #233 makes this insufficient (must cite ground (a) or (c))
**And** the `bmad-create-story (args: "review")` pre-dev gate flags the violation per its existing AC-coverage check.

**Given** Story 1.21 catalogues each pre-bootstrap story's gap,
**When** the test-debt file is committed,
**Then** each entry is referenced from the originating story file's § Deferred Work section (cross-link to `test-debt.md` anchor)
**And** Story 1.21's CR pass verifies the cross-links.

**Given** the test-debt file's intended consumer,
**When** future epic-planning iterations (Epic 4 prep, Epic 13 prep) read the file,
**Then** they can prioritise backfill alongside their own scope
**And** the file is not retroactively re-opened mid-epic (pre-bootstrap skips are grandfathered; only NEW skips post-Story 1.21 are subject to the FR14n amendment).

---

## Section 5 — Implementation Handoff

**Scope classification:** Major.

**Routed to:** Ralph build-mode loop, autonomous self-paced execution.

**Per-story routing:**

1. **Story 1.17** — Ralph queues `/bmad-create-story` next iteration (FR14n state `_(no story) → drafted`). Standard FR14n lifecycle (drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done). ATDD subtask: Vitest installation lands its OWN smoke test as the bootstrap red-phase; FR14n matrix row 3 ground (a) substrate-verification covers AC.
2. **Story 1.18** — Ralph queues `/bmad-create-story` next iteration after 1.17 closes. Same lifecycle. ATDD subtask: pytest scaffolds land alongside the runner install; ground (a) substrate-verification covers AC.
3. **Story 1.19** — Ralph queues `/bmad-create-story` next iteration after 1.18 closes. Same lifecycle, but with full ATDD red-phase scaffolding (the runner now exists; Story 1.19's AC class is exactly the kind that ground-(b) was hiding). Budget 4–6 CR iterations for adversarial coverage of impl bugs surfacing under test.
4. **Story 1.20** — Ralph queues `/bmad-create-story` next iteration after 1.19 closes. Lightweight (RALPH.md edit + manifest registration + INVARIANTS.md index). Likely single-pass CR.
5. **Story 1.21** — Ralph queues `/bmad-create-story` next iteration after 1.20 closes. Audit-only; spec edits across `test-debt.md` + per-story-file cross-links. Likely 1–2 CR iterations.

**Deliverables (per story):**

- Story file at `_bmad-output/implementation-artifacts/stories/{N-M}-{slug}.md`.
- Code + test artifacts as described in § 4.6 AC blocks.
- Sprint-status row transition: `backlog → ready-for-dev → in-progress → review → done`.
- Trace artifact at `_bmad-output/test-artifacts/traceability/{N-M}-*` per FR14n state `traced`.
- CR action-items addressed or `defer:` rationale recorded.

**Success criteria:**

- All five stories reach `done` state.
- `epic-1: in-progress → done` (re-close) recorded in sprint-status.yaml after Story 1.21.
- PR (this proposal's PR + the Story 1.17–1.21 implementation PRs as stacked branches) merges into `feat/epic-2-packaged-devbox`.
- `feat/epic-2-packaged-devbox` final merge into `main` carries Stories 1.17–1.21 as part of the Epic 2 close-out window.
- Post-merge: FR14i operates non-vacuously; FR14a `Required tests:` references real files for all post-bootstrap stories; NFR1a coverage floor enforced via sync-gate.

**Rollback plan:** None — each story is incremental + reversible at the PR-revert level. Story 1.17 can be reverted without affecting the rest of the repo (deletes `vitest.workspace.ts` + workflow YAML; package.json reverts cleanly). Story 1.20 can be reverted by removing the manifest entry. The substrate-floor amendment to architecture.md is a documentation-side decision; reverting it does not touch code.

---

## Decisions Resolved

### D1 — Halt timing

**Decision:** No halt required.

**Rationale:** Ralph's autonomous build loop runs at clean iteration boundaries by construction (FR14g one-task-per-iteration spine). Epic 1 PR #226 has already merged; this proposal is a forward-step course correction, not an in-flight halt-and-replan. The Sprint Change Proposal is authored in one Ralph build iteration; Stories 1.17–1.21 are queued for subsequent iterations per § Implementation Handoff.

**Counterposition (John):** Halt now (recorded in issue body).

**Why John's position was not adopted:** Halt-and-replan is appropriate when a sprint is mid-execution and the change invalidates active stories. This proposal does not invalidate Stories 2.1–2.18 (they ship without bootstrap; ATDD-skip is grandfathered for them); it adds new Stories 1.17–1.21 to a closed epic. Halting Ralph mid-Epic-2 would burn the Story 2.18 ZERO-PATCH lifecycle progress and force a re-orient on next invocation. Epic 2 was already at clean boundary at iter-354 EPIC_DONE.

### D2 — Backfill sequencing

**Decision:** Story 1.19 (`keel-invariants` backfill) is **parallelizable** with Stories 1.17 / 1.18 (in dependency order: 1.17 + 1.18 first → 1.19 second), but **MUST land before Epic 4 (security verification) starts**.

**Rationale:** Murat's "sequence backfill immediately after bootstrap" position is preserved because Epic 4 extends `packages/keel-invariants/` with secret/SAST/prompt-injection scanners (FR35–FR40) — the backfill is a hard precondition. Amelia's "don't block bootstrap on backfill — gate *new* work only" position is preserved because Stories 1.17 / 1.18 do NOT wait on 1.19. Winston's "parallelizable as Story 1.18 (in his numbering)" is preserved by the dependency-order: 1.17 + 1.18 ship the runtime; 1.19 + 1.20 + 1.21 extend it; Epic 2 close-out (PR #230 merge) is unaffected; Epic 4 cannot start until 1.19 lands.

**Recorded as:** sequencing note in `epics.md` Epic 4 § Implementation Notes; cross-referenced from Story 1.19 spec.

### D3 — PRD amendment vs INVARIANTS rule

**Decision:** **Both paths** (PRD AND invariants).

**Rationale:** John's PRD path (FR14j → FR14o here, NFR1a, FR14a manifest-semantics revision) and Amelia's invariants path (`INV-package-test-coverage-floor`) are complementary, not exclusive. The PRD path articulates the substrate's *intent* (every story ships with tests; runner exists; coverage floor enforced); the invariants path articulates the substrate's *enforcement* (sync-gate fails on coverage drift, manifest registers the enforcement code). The issue body's working-draft text already used FR14j; renumbered to FR14o here because FR14j was claimed by the issue #231 doc-budget course-correction (2026-04-25 amendment per issue #231).

**Recorded as:** PRD amendments § 4.1 (FR14o, NFR1a, FR14a / FR14i / FR14n amendments) + Story 1.19 implementation (registers `INV-package-test-coverage-floor` in `invariants.manifest.ts` + `INVARIANTS.md` index).

### D4 — Python project shape

**Decision:** **Root `pyproject.toml` + `uv.lock`** declaring shared dev deps (pytest, pytest-asyncio, ruff, mypy).

**Rationale:**

- **Per-script PEP 723 inline-metadata** (current pattern) extended to test scripts is awkward for pytest discovery (each test script is its own resolution context; no shared deps; `uv run` invocations multiply).
- **Per-Python-package `pyproject.toml`** mirrors the TS workspace shape but is heavyweight for ~3 Python modules (`ralph.py`, `scripts/bootstrap-bmad-agents.py`, `packages/devbox/tui/`).
- **Root `pyproject.toml` + `uv.lock`** is the conventional uv path for multi-script projects; pytest discovers the entire repo from a single root; dev deps shared cleanly. Coexists with existing PEP 723 inline-metadata (uv reads both — root `pyproject.toml` for shared deps; per-script blocks for runtime deps).

**Recorded as:** Architecture § M0 substrate developer-productivity floor; new architectural decision (D6 numbering — appended after D1–D4 in architecture.md); Story 1.18 spec.

### D5 — Architecture revision scope

**Decision:** **Add new section** § M0 substrate developer-productivity floor.

**Rationale:** Architecture currently has no section listing minimum testable-state substrate. Adding it consolidates the bootstrap arc (Stories 1.17–1.21) for future readers, captures the deferred decisions held at M9 / M10 (D3 / C4 / D4 / M3), and provides the canonical handoff between PRD intent and architecture-recorded mechanism.

**Recorded as:** § 4.2 Architecture amendments (new section inserted between § Data Architecture and § Authentication & Security).

### D6 (new) — Python project shape (encoded)

**Decision:** Root `pyproject.toml` + `uv.lock` with shared dev deps; pytest discovers from root; coexists with PEP 723 inline-metadata in individual scripts.

**Rationale:** See D4 above.

**Recorded as:** Architecture § M0 substrate developer-productivity floor (Python runtime substrate sub-section); Story 1.18 implementation lands the artifact.

---

## Approval

**Approved by:** Ralph autonomous build loop on 2026-04-25 (per FR14g one-task-per-iteration spine; FR14n state `_(no story) → drafted` for the next iteration's `/bmad-create-story` queue; user instruction `/bmad-correct-course` on issue #233 with target-branch directive `feat/epic-2-packaged-devbox`).

**Next iteration:** `/bmad-create-story` for Story 1.17 (FR14n state-transition `_(no story) → drafted`).
