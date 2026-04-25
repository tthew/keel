# Story 1.18: Bootstrap Python test runner (pytest under uv) + root pyproject.toml

Status: ready-for-dev

## Story

As a substrate operator with Python tooling (`ralph.py`, `scripts/bootstrap-bmad-agents.py`, `packages/devbox/tui/`) currently bootstrapped only via PEP 723 inline-script metadata,
I want a root `pyproject.toml` + `uv.lock` declaring shared dev deps (pytest, pytest-asyncio, ruff, mypy) and pytest test scaffolds for each Python module,
So that Python code has the same test-validation discipline as TypeScript code (FR14o; new architectural decision per `architecture.md § M0 substrate developer-productivity floor` at lines 198–240; resolves issue #233 for the Python runtime).

## Acceptance Criteria

**AC1 — `uv sync && uv run pytest` discovers and runs the three test scaffolds.**

**Given** the root `pyproject.toml` declaring `[tool.pytest.ini_options] testpaths` listing all three scaffold directories,
**When** I run `uv sync && uv run pytest` from the worktree root,
**Then** pytest discovers and runs `tests/test_ralph.py` + `scripts/tests/test_bootstrap_bmad_agents.py` + `packages/devbox/tui/tests/test_theme.py`
**And** all three scaffolds pass
**And** the exit code is 0.

**AC2 — `uv.lock` resolves deterministically + Story 1.9 sync-gate stays green.**

**Given** the `uv.lock` produced by `uv sync` against root `pyproject.toml`,
**When** `uv sync --frozen` re-runs (in CI or any subsequent operator workstation),
**Then** the lockfile resolves to identical versions across runs (no drift)
**And** Story 1.9's sync-gate (`pnpm keel-invariants:check`) does NOT regress on any pre-existing manifest entry attributable to this story's edits (see SC-9 for the Python-dep coverage deferral; pre-existing `INV-git-hooks-preservation` drifts carved out).

(Diverges from epics.md:1194's "Story 1.9's sync-gate (extended in Story 1.20 to cover Python deps if applicable)" clause: Story 1.18 does NOT extend the sync-gate to cover `uv.lock` drift. Per SC-9 the "if applicable" deferral resolves DEFER — Python-dep manifest extension lands in Story 1.20 alongside `INV-fr14i-ci-workflow-presence` registration, OR Story 1.21 audit if Story 1.20 declines the surface.)

**AC3 — `.github/workflows/ci.yml` extended with `python` job; no rewrite of existing `node` job.**

**Given** the existing `.github/workflows/ci.yml` (Story 1.17 substrate; `name:` + `on:` + `permissions:` + `concurrency:` at lines 1–14 + `jobs:` header at line 16 + single `node` job at lines 17–29),
**When** Story 1.18 lands,
**Then** the workflow contains a second job `python` running `uv sync && uv run pytest` on `ubuntu-latest` with `astral-sh/setup-uv@v6` (latest stable major; pinned per I7 first-party action policy)
**And** the `node` job (lines 17–29 pre-edit) is byte-identical post-edit (additive YAML, no rewrite per SC-5)
**And** the workflow YAML is syntactically valid (`actionlint .github/workflows/ci.yml` exits 0; falls back to GitHub Actions YAML-ingestion validation at PR-open time — the workflow's `pull_request: branches: [main]` trigger per `.github/workflows/ci.yml:4-5` — if `actionlint` is unavailable in the iter env, per Story 1.17 Subtask 10.4 precedent).

(Diverges from epics.md:1188's "the job is marked as a required check on `main` alongside the `node` job from Story 1.17" clause per SC-6: branch-protection / required-check configuration is GitHub UI-side + admin-scope. This story SHIPS the `python` job. FR14i activation + `INV-fr14i-ci-workflow-presence` invariant registration land in Story 1.20.)

**AC4 — CLAUDE.md common-commands table documents `uv run pytest`.**

**Given** the CLAUDE.md `## Common commands` table at lines 11–25 (post-Story-1.17 footer; the table currently runs through line 25 with rows for `pnpm test` / `pnpm typecheck` / `pnpm lint` added by Story 1.17 Task 8),
**When** I open CLAUDE.md after Story 1.18 lands,
**Then** the table has a new row `| Run Python tests | \`uv run pytest\` |` appended after the existing `Run lint` row, immediately before the prose paragraph that follows the table.
**And** line 23's "Run all tests" wording stays byte-identical — retitling to "Run TS tests" is out-of-scope per SC-5 byte-identical-Story-1.17-substrate clause; the asymmetry is intentional.

**AC5 — AGENTS.md `## Testing` section updated to active-tense `uv run pytest` language.**

**Given** the AGENTS.md `## Testing` section at lines 43–45 (Story 1.17 substrate; carries the forward-pointer "Python tests under `uv run pytest` arrive with Story 1.18"),
**When** Story 1.18 lands,
**Then** the section's second sentence is rewritten in active tense to this EXACT byte-pinned wording (locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule): "Run `uv run pytest` from the worktree root for the workspace-wide pytest suite covering `ralph.py` (`tests/`), `scripts/bootstrap-bmad-agents.py` (`scripts/tests/`), and `packages/devbox/tui/` (`packages/devbox/tui/tests/`); dev deps + Python 3.10+ are pinned in root `pyproject.toml` + `uv.lock` (D6)."
**And** the cross-reference to `architecture.md § M0 substrate developer-productivity floor` (third sentence) is byte-identical (preserved unchanged)
**And** prettier idempotence holds (`pnpm format:check` exits 0 against AGENTS.md per Story 1.17 SC-10 precedent).

## Tasks / Subtasks

- [ ] **Task 1 — Create root `pyproject.toml` with `[project]` metadata, dev deps, pytest config.** (AC: 1, 2)
  - [ ] Subtask 1.1: Create `/workspace/ralph-bmad/.claude/worktrees/test-env/pyproject.toml` (worktree root; ABSENT pre-edit per substrate ledger). Content shape:
    - `[project]` table — `name = "keel-python"`, `version = "0.0.0"`, `requires-python = ">=3.10"` (matches `ralph.py:3` PEP 723 metadata exactly per SC-2), `dependencies = []` (no shared runtime deps; per-script PEP 723 carries runtime deps per D6 coexistence).
    - `[project.optional-dependencies]` — `dev = ["pytest", "pytest-asyncio", "ruff", "mypy"]` per SCP-233 § 4.1 FR14o + § 4.2 D6 shared dev deps list (verbatim list — no additions, no removals at this scope).
    - `[tool.pytest.ini_options]` — `testpaths = ["tests", "scripts/tests", "packages/devbox/tui/tests"]` (three directories per AC1 + Subtask 3/4/5 scaffolds; ordering doesn't affect pytest collection but list in alphabetical-by-leading-segment order for consistency); `pythonpath = [".", "scripts", "packages/devbox"]` (`.` for `ralph.py` import, `scripts` for hyphen-named `bootstrap-bmad-agents.py` via importlib in Subtask 4.1, `packages/devbox` for `tui` package import via `__init__.py` at `packages/devbox/tui/__init__.py:1` per substrate ledger); `addopts = "-ra --strict-markers"` (standard pytest hardening — `-ra` shows summary of skipped/xfailed/failed; `--strict-markers` rejects unregistered markers, paying down ATDD-skip ground (b) sunset risk per FR14n amendment).
  - [ ] Subtask 1.2: Resolve exact pytest 8.x patch + pytest-asyncio 0.x + ruff 0.x + mypy 1.x version literals at dev-story time via `uv pip compile --python 3.10 --resolution=highest --extra dev pyproject.toml` (verified against `uv 0.11.7` at SM-validate; `--extra dev` ensures the dev optional-deps group is resolved). Pin the resolved literals exactly (no `^` / `~` / `>=`) in `[project.optional-dependencies] dev`. Record the resolved versions in Dev Agent Record § Completion Notes BEFORE commit so post-dev SM can verify the pins per SC-3 + I7 exact-version policy.
  - [ ] Subtask 1.3: Verify the file passes a TOML round-trip (`python -c "import tomllib; tomllib.load(open('pyproject.toml','rb'))"`) — guards against syntax errors before Subtask 2.1's `uv sync` runs.

- [ ] **Task 2 — Run `uv sync` to materialize `.venv` + generate `uv.lock`; commit `uv.lock`.** (AC: 1, 2)
  - [ ] Subtask 2.1: From the worktree root run `uv sync --extra dev`. The command (a) creates `.venv/` (gitignored per `.gitignore:66` `.venv/`), (b) installs the dev deps resolved in Subtask 1.2, (c) emits `uv.lock` at the worktree root. Verify exit code 0; capture `uv sync --frozen` re-run exit code 0 in Completion Notes per AC2's deterministic-resolution clause.
  - [ ] Subtask 2.2: Add `uv.lock` to git index alongside `pyproject.toml`. Both files are committed (the lockfile IS the pin source per SC-3 — analogue of `pnpm-lock.yaml` for the TS half). `.venv/` stays gitignored; `.python-version` is NOT shipped (uv reads `requires-python` from `pyproject.toml`; no separate `.python-version` file is needed at this scope per SC-7).

- [ ] **Task 3 — Create `tests/test_ralph.py` smoke covering `ralph.py:format_duration`.** (AC: 1)
  - [ ] Subtask 3.1: Create directory `tests/` at worktree root (ABSENT pre-edit per substrate ledger). Author `tests/test_ralph.py` as a single-module pytest file:
    - `import ralph` (importable because `pythonpath` includes `.` per Subtask 1.1 + because `ralph.py:2015-2016` guards Textual app instantiation behind `if __name__ == "__main__":` so module-level import has no side-effects per substrate probe).
    - One `def test_format_duration_basic():` asserting `ralph.format_duration(0.0) == "0s"` (or whatever the function returns for zero seconds — exact return-shape verified at dev-story time via reading `ralph.py:89-98` and capturing the canonical zero-input output in Completion Notes BEFORE the assertion is written).
    - Optionally a second assertion that `ralph.format_duration(3725.0).endswith("s")` (a one-hour-plus input still produces a string ending in `s` — minimal smoke shape per SC-1 NOT a behavioural test).
  - [ ] Subtask 3.2: Verify the test passes locally: `uv run pytest tests/test_ralph.py -v`.

- [ ] **Task 4 — Create `scripts/tests/test_bootstrap_bmad_agents.py` smoke.** (AC: 1)
  - [ ] Subtask 4.1: Create directory `scripts/tests/` (ABSENT pre-edit per substrate ledger). Author `scripts/tests/test_bootstrap_bmad_agents.py`. Because the source filename `scripts/bootstrap-bmad-agents.py` carries hyphens (not a valid Python module identifier), use `importlib.util.spec_from_file_location` to load the module:
    - `from pathlib import Path; import importlib.util`
    - `spec = importlib.util.spec_from_file_location("bootstrap_bmad_agents", Path(__file__).resolve().parent.parent / "bootstrap-bmad-agents.py")`
    - `module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)`
    - One `def test_module_loads_with_constants():` asserting `"Edit" in module.EXECUTION_TOOLS` AND `"Read" in module.ADVISORY_TOOLS` (both lists declared at `scripts/bootstrap-bmad-agents.py:24-25` per substrate probe — pure module-level constants, no I/O at import time per `bootstrap-bmad-agents.py:1-7` PEP 723 metadata + module body).
    - Note: `tests/__init__.py`, `scripts/tests/__init__.py`, and `packages/devbox/tui/tests/__init__.py` are NOT required and NOT shipped at this scope — pytest 8.x `--import-mode=prepend` (default) collects test files by unique basename, and the three test basenames (`test_ralph.py`, `test_bootstrap_bmad_agents.py`, `test_theme.py`) do not collide. Locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule. If a future smoke addition introduces a basename collision, that story adds `__init__.py` markers — Story 1.18 does NOT preempt.
  - [ ] Subtask 4.2: Verify the test passes locally: `uv run pytest scripts/tests/test_bootstrap_bmad_agents.py -v`.

- [ ] **Task 5 — Create `packages/devbox/tui/tests/test_theme.py` smoke.** (AC: 1)
  - [ ] Subtask 5.1: Create directory `packages/devbox/tui/tests/` (ABSENT pre-edit per substrate ledger). Author `packages/devbox/tui/tests/test_theme.py`:
    - `from tui.theme import theme` (importable because `pythonpath` includes `packages/devbox` per Subtask 1.1 + `packages/devbox/tui/__init__.py` exists as an empty package marker per substrate ledger making `tui` a proper Python package).
    - One `def test_theme_neutral_500():` asserting `theme.colors.neutral_500 == "oklch(52% 0 0)"` — exact literal verified at substrate ledger via reading `packages/devbox/tui/theme.py:15`. Locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule (no `from tui import theme` + `theme.theme.colors...` alternative — picked the cleaner direct-import shape).
    - The `theme.py` file is `AUTOGENERATED from packages/ui/tokens.json` per its header comment (`theme.py:1`); the smoke test asserts a pinned literal that survives token regeneration (neutral_500 has been stable since Story 1.13). If a future token regen changes the literal, the smoke test fails — that's correct fail-loud behaviour, not a fragility bug.
  - [ ] Subtask 5.2: Verify the test passes locally: `uv run pytest packages/devbox/tui/tests/test_theme.py -v`.

- [ ] **Task 6 — Extend `.github/workflows/ci.yml` with `python` job.** (AC: 3)
  - [ ] Subtask 6.1: Edit `.github/workflows/ci.yml` (lines 1–29 pre-edit per substrate ledger; Story 1.17 substrate; convention: `node` job = lines 17–29). The edit is ADDITIVE per SC-5 — the existing `node` job (lines 17–29) is byte-identical post-edit; a new `python` job is appended at the same `jobs:` indentation level. Pre-edit `jobs:` block ends at line 29 (`- run: pnpm turbo run test lint typecheck`); post-edit, the `python` job follows on a new line after the `node:` job's last step.
  - [ ] Subtask 6.2: `python` job shape: `runs-on: ubuntu-latest`; steps in this exact order — (1) `actions/checkout@v4` (matches Story 1.17's `node` job major-pin per SC-4), (2) `astral-sh/setup-uv@v6` with `version: "0.11.7"` (exact-version pin per I7 + SC-3 — matches iter-env `uv` per substrate ledger; do NOT use `latest`/floating tag — locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule), (3) `uv sync --extra dev --frozen` (uses `uv.lock` deterministically per AC2), (4) `uv run pytest` (the canonical entry point per FR14o). Pin all GitHub Action versions per I7 using `@v4` / `@v6` major-pin for first-party + verified-publisher actions; avoid third-party actions (Story 1.17 CR iter-362 deferred SHA-pinning of third-party actions to Story 1.20/1.21 per its Change Log v1.6).
  - [ ] Subtask 6.3: Verify `actionlint .github/workflows/ci.yml` exits 0 if `actionlint` is available in the iter env. If absent (per RALPH.md iter-359 — `actionlint` was unavailable for Story 1.17), fall back to GH Actions ingestion-side validation post-push per AC3 + Story 1.17 Subtask 10.4 precedent. Branch protection / required-check is GH-UI / admin-scope (out of substrate per SC-6).

- [ ] **Task 7 — Update CLAUDE.md `## Common commands` table with `uv run pytest` row.** (AC: 4)
  - [ ] Subtask 7.1: Edit `CLAUDE.md` `## Common commands` table — currently spans lines 11–25 post-Story-1.17 (the three rows added by Story 1.17 Task 8 are at lines 23–25 for `pnpm test` / `pnpm typecheck` / `pnpm lint`; verified at create-story time against current substrate). Append a new row `| Run Python tests | \`uv run pytest\` |` immediately after line 25, preserving the blank line before the prose paragraph that follows. Maintain alignment via prettier-friendly spacing (Subtask 9.4 confirms idempotence).

- [ ] **Task 8 — Update AGENTS.md `## Testing` section to active-tense `uv run pytest` language.** (AC: 5)
  - [ ] Subtask 8.1: Edit `AGENTS.md § Testing` (currently at lines 43–45 post-Story-1.17 per substrate ledger). Replace the existing forward-pointer sentence ("Python tests under `uv run pytest` arrive with Story 1.18.") with this EXACT byte-pinned wording (locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule — no dev-story-time wording slack): "Run `uv run pytest` from the worktree root for the workspace-wide pytest suite covering `ralph.py` (`tests/`), `scripts/bootstrap-bmad-agents.py` (`scripts/tests/`), and `packages/devbox/tui/` (`packages/devbox/tui/tests/`); dev deps + Python 3.10+ are pinned in root `pyproject.toml` + `uv.lock` (D6)." The first sentence (re `pnpm test`) is BYTE-IDENTICAL — Story 1.18 only edits the second sentence. Cross-reference to `architecture.md § M0 substrate developer-productivity floor` (the third sentence) is BYTE-IDENTICAL.
  - [ ] Subtask 8.2: Verify prettier idempotence (`pnpm format:check` exits 0 against AGENTS.md) per AC5 + Story 1.17 SC-10 precedent.

- [ ] **Task 9 — Iter-env smoke validation.** (AC: 1, 2, 3, 4, 5)
  - [ ] Subtask 9.1: `uv sync --extra dev && uv run pytest` produces exit code 0 in the iteration environment + the three smoke tests are reported in pytest output. Capture the pytest summary line (e.g., `===== 3 passed in 0.12s =====`) as evidence in Dev Agent Record § Completion Notes per AC1.
  - [ ] Subtask 9.2: `uv sync --frozen` exits 0 (lockfile-pin verified deterministic) per AC2.
  - [ ] Subtask 9.3: `pnpm keel-invariants:check` (Story 1.9 sync-gate) exits 0 — no NEW manifest drift introduced by Story 1.18's edits. **Note (PARTIAL):** the three pre-existing `INV-git-hooks-preservation` drifts on `feat/epic-2-packaged-devbox` head (RALPH.md iter-358 gotcha; out-of-scope per "Address before Story 1.20 close-out") persist unchanged — Story 1.18 does NOT inadvertently touch the prek-hook surface. AC2 satisfied (the AC's specific check is "no NEW drift attributable to Story 1.18 edits"); pre-existing drifts are explicitly carved out per SC-9.
  - [ ] Subtask 9.4: `pnpm typecheck && pnpm lint && pnpm format:check` all exit 0 (Story 1.18's TS-side surface is null — `pyproject.toml`, `uv.lock`, `tests/`, `scripts/tests/`, `packages/devbox/tui/tests/` are all .py / .toml / .lock; `format:check` covers the `.github/workflows/ci.yml` YAML edit + the AGENTS / CLAUDE markdown edits per Story 1.17 precedent).
  - [ ] Subtask 9.5: `actionlint .github/workflows/ci.yml` if available (else GH ingestion-side validation per AC3 fallback) — Subtask 6.3.

- [ ] **Task 10 — Sprint-status flip + Change Log v1.0 (lifecycle hygiene at story creation).** (no direct AC — process; executed at `/bmad-create-story` iter — DO NOT re-execute at dev-story time)
  - [x] Subtask 10.1: Sprint-status flip `1-18-bootstrap-python-test-runner-pytest-under-uv: backlog → ready-for-dev` lands at `/bmad-create-story` iter (this iteration; skill-handled per `workflow.md` step 6).
  - [x] Subtask 10.2: Change Log v1.0 entry lands at create-story iter (see § Change Log).
  - [ ] Subtask 10.3 (informational, no dev-story action): subsequent versions follow Story 1.17 precedent — v1.1 pre-dev SM-validate, v1.2 ATDD-skip-or-scaffold, v1.3 dev-story landing, v1.4 trace, v1.5 post-dev SM, v1.6+ CR.

## Dev Notes

### Scope clarifications (pinned at draft, MUST be honored — not re-negotiable without Change Log entry)

- **SC-1: Story 1.18 is BOOTSTRAP, not coverage.** Three test scaffolds wire the runner against three Python module families (`ralph.py`, `scripts/bootstrap-bmad-agents.py`, `packages/devbox/tui/`). Each scaffold is a SMOKE — module loads + one pinned-literal assertion. Behavioural / property-based / branch-coverage tests are deferred to Story 1.21 audit / Epic 4 prep / future per-module backfill. The three smokes exist ONLY to satisfy AC1 + the FR14n § ground-(a) substrate-verification clause for ATDD-skip — they are NOT a stand-in for keel-invariants-style adversarial test passes (that pattern is Story 1.19 territory but for the TS side; Python equivalent is post-bootstrap follow-up).
- **SC-2: Python version pin = `>=3.10` matching `ralph.py:3` PEP 723.** The root `pyproject.toml` `requires-python` field MUST equal `">=3.10"` byte-for-byte to match `ralph.py`'s existing PEP 723 inline-script metadata block (`ralph.py:3`). This avoids divergence between the per-script PEP 723 path (`uv run ralph.py`) and the root-project path (`uv run pytest`). Locked at SM-validate per RALPH.md iter-357 lesson: do not defer this decision to dev-story time. Future bumps (Python 3.11 / 3.12 / 3.13 floor) require a separate amendment.
- **SC-3: Dev-dep exact-version pinning per I7.** All four dev deps in `[project.optional-dependencies] dev` (pytest, pytest-asyncio, ruff, mypy) MUST be pinned to exact patch versions (no `^` / `~` / `>=` / `==X.Y.*`). Resolution at dev-story time via `uv pip compile --resolution=highest pyproject.toml` (or equivalent — verified against `uv 0.11.7`). Resolved literals captured in Completion Notes BEFORE commit per Subtask 1.2 + SC-2 of Story 1.17 precedent. The `uv.lock` is the secondary lock (transitive deps); `pyproject.toml` is the primary author-stated pin (top-level deps). Both are committed per Subtask 2.2.
- **SC-4: GitHub Action pinning per I7 first-party-major / verified-publisher policy.** `actions/checkout@v4` + `astral-sh/setup-uv@v6` (or whichever stable major exists at dev-story time — `astral-sh` is verified-publisher; major-pin is sufficient). Avoid third-party actions; if dev-story time discovers an unavoidable third-party action, exact-SHA pin it (Story 1.17 CR iter-362 deferred SHA-pinning of existing first-party actions to Story 1.20/1.21 per its Change Log v1.6 — Story 1.18 does NOT escalate to SHA-pinning at this scope).
- **SC-5: CI workflow extension is ADDITIVE, not a rewrite.** The existing Story 1.17 `node` job (`.github/workflows/ci.yml:17-29` per substrate ledger) is BYTE-IDENTICAL post-edit. Story 1.18 appends a new `python` job at the same `jobs:` indentation level. The top-level `name:` / `on:` / `permissions:` / `concurrency:` blocks (lines 1–14) are BYTE-IDENTICAL — they are workflow-scoped (not job-scoped) and the Story 1.17 CR iter-362 hardening (`permissions: contents: read` + `concurrency: { group: ci-${{ github.ref }}, cancel-in-progress: true }`) carries forward as-is.
- **SC-6: Branch protection / required-check configuration is OUT OF SCOPE.** Story 1.18 ships the `python` job; FR14i activation (workflow file presence + content-hash registered in `invariants.manifest.ts` as `INV-fr14i-ci-workflow-presence`) lands in Story 1.20 per SCP § 4.6 D3. Marking the `python` job as a required check in GH branch protection is a separate UI / admin operation, not a substrate file edit. AC3's "required check" clause (epics.md:1188) explicitly diverges per this SC.
- **SC-7: `.python-version` file is NOT shipped.** uv reads `requires-python` from `pyproject.toml`; a separate `.python-version` file (uv's optional pin file) is unnecessary at this scope and would create a second source of truth (drift risk). If a future story decides operator-workstations need `.python-version` for tooling integration, it is an additive amendment — Story 1.18 does NOT preempt it. `.python-version` is NOT currently in `.gitignore` but adding it is also OUT OF SCOPE.
- **SC-8: No new INV-* invariants registered.** Story 1.18 does NOT register `INV-pytest-pin`, `INV-pyproject-toml`, `INV-uv-lock-determinism`, or any Python-specific invariant in `packages/keel-invariants/src/invariants.manifest.ts`. Each is a separate story's territory (Story 1.20 may register `INV-fr14i-ci-workflow-presence` covering the workflow file as a whole including the `python` job; Story 1.21 audit may codify per-package coverage-floor extension). Day-1 manifest registration here would flap the Story 1.9 sync-gate against in-flight stories per SCP § Artifact Conflicts pattern (same rationale as Story 1.17 SC-8).
- **SC-9: Story 1.20 deferral of `uv.lock` → sync-gate coverage.** Story 1.18 AC2's "extended in Story 1.20 to cover Python deps if applicable" clause (per epics.md:1194) resolves DEFER at this story's scope — Story 1.18 does NOT extend `INV-deps-version-pinning`'s scope to cover `uv.lock` drift detection. Two paths exist for Story 1.20: (a) extend `INV-deps-version-pinning` to drift-detect `uv.lock` content-hash (analogue of `pnpm-lock.yaml` coverage), OR (b) leave `uv.lock` outside the manifest because uv's own `--frozen` flag already provides deterministic resolution at CI time (the AC2 second clause). Story 1.20 picks the path; Story 1.21 audit cleans up if Story 1.20 declines. **Pre-existing 3× `INV-git-hooks-preservation` drifts on `feat/epic-2-packaged-devbox` head (RALPH.md iter-358 gotcha) are out-of-scope for Story 1.18** — same carve-out as Story 1.17. Resolution-scope deferred to RALPH.md iter-358 gotcha guidance + Story 1.20 close-out (NOT a Story 1.18 Subtask).
- **SC-10: PEP 723 coexistence is the long-term shape, not transitional.** Per architecture.md D6 (line 196): "coexists with existing PEP 723 inline-metadata (uv reads both — root `pyproject.toml` for shared deps; per-script blocks for runtime deps)." `ralph.py:2-6` PEP 723 block (carrying `textual>=1.0.0` runtime dep + `requires-python = ">=3.10"`) is BYTE-IDENTICAL post-Story-1.18. The migration plan recorded in Dev Agent Record per AC5 of SCP-233 § 4.6 (epics.md:1203) is: **no migration**. Root `pyproject.toml` carries SHARED DEV deps only; per-script PEP 723 carries RUNTIME deps. This is the pinned shape going forward; future scripts adding runtime deps use PEP 723 inline-metadata; future shared dev deps go in root `pyproject.toml`. Locked at SM-validate per RALPH.md iter-357 lesson — do NOT defer the migration-direction decision to dev-story time.
- **SC-11: Test scaffold assertion = pinned literal, not behavioural.** Each of the three smokes asserts ONE pinned literal that survives upstream regeneration without semantic change: `format_duration(0.0)` deterministic return-shape (Subtask 3.1), `EXECUTION_TOOLS` / `ADVISORY_TOOLS` membership (Subtask 4.1), `theme.colors.neutral_500 == "oklch(52% 0 0)"` (Subtask 5.1; pin since Story 1.13 token landing). These are SMOKE shapes per SC-1 — discovery + import + minimal sanity check. They are NOT branch-coverage / property-based / mutation-tolerance tests; those land in Story 1.21 audit / Epic 14 corpus work per NFR28b empirical-baseline methodology.

### Forecast — fix-chain envelope

Per RALPH.md iter-286 lifecycle PATCH forecast bands + iter-357 course-correction-author origin re-baseline:

- **Pre-dev SM-validate** (`drafted → validated`): 8–14 PATCHes forecast (course-correction-author origin per RALPH.md iter-348 + iter-357; substrate-verification at create-story time should reduce drift class but cannot eliminate dev-time-decision under-specification). Story 1.18's narrower scope vs Story 1.17 (10 Tasks / ~22 subtasks vs 11 / ~25; no `pnpm.overrides` lockstep; no legacy-test-API exclusion; 3 smoke tests vs 1) suggests lower yield than Story 1.17's 16 PATCHes, but course-correction-author origin compounds. Probable class breakdown: 3–5 substrate citation drift (line ranges + cross-refs), 4–6 dev-time decision under-specification (Python version, dev-dep pinning, action versions, smoke target literals — many already pre-locked at SC-2/3/4/11), 1–3 prose density.
- **ATDD** (`validated → atdd-scaffolded`): SKIP via FR14n § ground-(a) substrate-verification covers AC. The three smoke scaffolds ARE the bootstrap red-phase per AC1 (analogous to Story 1.17's smoke); per FR14n § ATDD-skip ground-(b) sunset (issue #233 amendment), Story 1.18 cannot cite ground (b) "no test runner" (because Story 1.17 IS the test runner — for TS, AND uv exists in cc-devbox). Cite ground-(a) only OR (a)+(c) variant-(iii) hybrid (spec-declared-CR-substitution at AC1 verbatim).
- **Dev-story** (`atdd-scaffolded → in-dev`): single iter expected (substrate-extension class per RALPH.md iter-344 counter-example + iter-359 Story 1.17 second confirmation; 10 Tasks / ~22 subtasks; mostly additive edits, no algorithmic rewrites, no multi-site hook-surface lockstep). Risk: pytest 8.x default import-mode interaction with the `pythonpath` shape — may require `__init__.py` files at any of the three test directories (Subtask 4.1 records the dev-story decision in Completion Notes if required).
- **Trace** (`in-dev → traced`): WAIVED expected (PARTIAL ACs; substrate-verifies-AC ground per ATDD-skip rationale). Story 1.18 IS the Python test infrastructure being verified — no external test corpus to enforce coverage against. 0 fix-task QUEUE entries forecast. Hybrid (a)+(c) variant-(ii)+(iii) per Story 1.17 iter-360 trace-WAIVED precedent.
- **Post-dev SM** (`traced → sm-verified`): 1–4 PATCH at gate per RALPH.md iter-352 narrow-substrate-extension empirical (vs forecast envelope 0–3). Likely class: line-range drift on table/section anchors after dev-story extends them (same residual as Story 1.17 iter-361's 4-PATCH cluster).
- **CR** (`sm-verified → done`): 0–3 PATCH inline-bundle-close per RALPH.md iter-342 mid-arc narrow-band recipe + iter-362 Story 1.17 precedent. Story 1.18 inherits the "first-CI-workflow-job security defense gap" residual class (RALPH.md iter-362) — though Story 1.17 already added top-level `permissions:` + `concurrency:` blocks, the new `python` job MAY surface job-level hardening opportunities (e.g., `permissions:` per-job override if Story 1.20's invariant later restricts further; `timeout-minutes:` on the job; `runs-on:` matrix considerations). Forecast 1–2 of these as plausible PATCHes. Inline-bundle-close still applies if PATCH band stays narrow + no decision_needed + L1-safe per iter-342 conditions.
- **Cumulative pre-merge PATCH band:** 10–24 across the lifecycle (vs Story 1.17's 22 cumulative final — Story 1.18 forecast slightly below Story 1.17's empirical because narrower scope per RALPH.md iter-344 substrate-extension class definition, but course-correction-author origin holds). Re-baseline at SM-validate per iter-357 pattern (forecast may shift up if SM-validate yield exceeds 14 PATCHes).

### Substrate verification ledger (RALPH.md iter-347 mandate)

Each Task's file/symbol/marker target was probed at create-story time. Findings:

| Target | File | Status | Drift |
| --- | --- | --- | --- |
| Root `pyproject.toml` | (worktree root) | ABSENT (no `pyproject.toml` at root or any subdirectory; verified via Glob `*.toml`) | none — story creates |
| Root `uv.lock` | (worktree root) | ABSENT | none — story creates (via `uv sync` per Subtask 2.1) |
| `.python-version` | (worktree root) | ABSENT (and NOT in `.gitignore`) | none — story does NOT ship per SC-7 |
| Existing Python files | `ralph.py` (root, 2016 lines), `scripts/bootstrap-bmad-agents.py`, `packages/devbox/tui/__init__.py` + `theme.py` | EXISTS (3 substrate Python files; ~11 internal `.claude/skills/*/scripts/*.py` are not substrate) | none |
| `ralph.py` smoke target | `ralph.py:89-98` `format_duration` (pure function, no I/O at module load; module guarded by `ralph.py:2015-2016` `if __name__ == "__main__":`) | EXISTS | none |
| `bootstrap-bmad-agents.py` smoke target | `scripts/bootstrap-bmad-agents.py:24-25` `ADVISORY_TOOLS` + `EXECUTION_TOOLS` lists (module-level, no I/O at import) | EXISTS (pure list literals; PEP 723 metadata at lines 1–7 declares `requires-python = ">=3.10"` + empty `dependencies = []`) | none |
| `theme.py` smoke target | `packages/devbox/tui/theme.py:15` `neutral_500="oklch(52% 0 0)"` | EXISTS (autogenerated from `packages/ui/tokens.json`; commit SHA pinned in `theme.py:2`) | none |
| `tui` Python package marker | `packages/devbox/tui/__init__.py` | EXISTS (makes `tui` an importable Python package per Subtask 5.1's `from tui import theme`) | none |
| `.github/workflows/ci.yml` | `.github/workflows/ci.yml:1-30` (Story 1.17 substrate) | EXISTS (post-Story-1.17 + iter-362 CR-hardening: `name:` + `on:` + `permissions:` + `concurrency:` + single `node` job) | none — story extends additively |
| CLAUDE.md `## Common commands` table | `CLAUDE.md:11-25` (post-Story-1.17 footer) | EXISTS (9 rows post-Story-1.17 — adds `pnpm test` / `pnpm typecheck` / `pnpm lint` rows at lines 23–25) | none — story extends |
| AGENTS.md `## Testing` section | `AGENTS.md:43-45` (post-Story-1.17) | EXISTS (3-line section: 1 sentence on `pnpm test`, 1 sentence on `uv run pytest` forward-pointer, 1 cross-ref to architecture.md § M0) | none — story rewrites second sentence per AC5 |
| `uv` CLI availability | `/usr/local/bin/uv` (cc-devbox iter env) | EXISTS (`uv 0.11.7 (aarch64-unknown-linux-gnu)`) | none |
| `astral-sh/setup-uv` GitHub Action | (external, on actions marketplace) | verified-publisher GH Action; major-pin `@v6` is the I7 path per SC-4 | none |
| FR14o source | `_bmad-output/planning-artifacts/prd.md:969` (full text of FR14o) | EXISTS verbatim | none |
| NFR1a source | `_bmad-output/planning-artifacts/prd.md:1068` | EXISTS verbatim | none |
| FR14a manifest-real-files clause | `_bmad-output/planning-artifacts/prd.md:948` | EXISTS verbatim | none |
| FR14i pre-bootstrap-degradation amendment | `_bmad-output/planning-artifacts/prd.md:959` | EXISTS verbatim | none |
| Architecture § M0 substrate developer-productivity floor | `_bmad-output/planning-artifacts/architecture.md:198-240` | EXISTS verbatim (Python runtime substrate sub-section at lines 210–215; CI integration at 216–223; bootstrap arc at 225–231) | none |
| Architecture D6 (Python project shape) | `_bmad-output/planning-artifacts/architecture.md:196` | EXISTS verbatim | none |
| Architecture Testing Framework decision | `_bmad-output/planning-artifacts/architecture.md:154` (was "Deferred" pre-issue-#233; now resolved to Vitest+pytest) | EXISTS | none |
| epics.md Story 1.18 entry | `_bmad-output/planning-artifacts/epics.md:1172-1204` (User story + 5 ACs verbatim from SCP-233) | EXISTS | none |
| sprint-status row | `_bmad-output/implementation-artifacts/sprint-status.yaml:143` (`1-18-bootstrap-python-test-runner-pytest-under-uv: ready-for-dev`) | EXISTS (status `ready-for-dev` post-Subtask-10.1; flipped at create-story iter-363) | none |
| Story 1.17 reference (sibling) | `_bmad-output/implementation-artifacts/1-17-bootstrap-typescript-test-runner-vitest-minimal-ci.md` (`Status: done`) | EXISTS | none |

Mismatches surfaced at substrate verification: **0 drifts** — all substrate citations probed cleanly (vs Story 1.17 create-story iter-356 which surfaced 1 SCP-side drift on `release-please.yml` path). Improvement attributable to (a) Story 1.18 inheriting Story 1.17's CI workflow already-shipped substrate (no first-creation hazard) + (b) RALPH.md iter-347 substrate-verification mandate now fully internalised at create-story time.

### Project Structure Notes

Aligns with `architecture.md § Complete Project Directory Structure` (lines 876+) + § M0 substrate developer-productivity floor (lines 198–237). New file additions:

- `pyproject.toml` (worktree root; new) — Python project root with `[project]` + `[project.optional-dependencies]` + `[tool.pytest.ini_options]` blocks per SC-2/3.
- `uv.lock` (worktree root; new) — generated by `uv sync` per Subtask 2.1; deterministic dev-dep + transitive resolution per AC2.
- `tests/test_ralph.py` (new) — bootstrap smoke covering `ralph.py:format_duration` per AC1.
- `scripts/tests/test_bootstrap_bmad_agents.py` (new) — bootstrap smoke covering `scripts/bootstrap-bmad-agents.py` `EXECUTION_TOOLS` / `ADVISORY_TOOLS` constants via importlib (hyphen filename) per AC1.
- `packages/devbox/tui/tests/test_theme.py` (new) — bootstrap smoke covering `packages/devbox/tui/theme.py` `theme.colors.neutral_500` literal per AC1.

Modified files:

- `.github/workflows/ci.yml` — additive: appends `python` job after existing `node` job per AC3 + SC-5.
- `CLAUDE.md` — appends 1 row to `## Common commands` table (`uv run pytest`) per AC4.
- `AGENTS.md` — rewrites second sentence of `## Testing` section to active-tense `uv run pytest` documentation per AC5.

No conflicts with `pnpm-workspace.yaml` (Python is OUT of pnpm workspace). No conflicts with `.gitignore` (Python patterns at lines 61–72 already cover `.venv/` + `__pycache__/` + caches). No conflicts with prek hook config (`.pre-commit-config.yaml` carries TS-only hooks at lines 7–66; Python hooks ruff/mypy/pytest are out-of-scope for Story 1.18 per SC-1 + SC-8 — added if/when Story 1.21 audit codifies them).

### References

- [Source: `_bmad-output/planning-artifacts/sprint-change-proposal-issue-233.md` § Section 4.6 Story 1.18 + § Section 4.1 PRD FR14o + § Section 4.2 Architecture amendments + § Decisions Resolved D4 + D6]
- [Source: `_bmad-output/planning-artifacts/epics.md:1172-1204` Story 1.18 user-story + 5 ACs (verbatim from SCP-233)]
- [Source: `_bmad-output/planning-artifacts/epics.md:1140-1170` Story 1.17 (TS sibling) — structural mirror]
- [Source: `_bmad-output/planning-artifacts/epics.md:1205-1241` Story 1.19 — references Story 1.18 outcome (root pyproject.toml + scaffolds present)]
- [Source: `_bmad-output/planning-artifacts/epics.md:1243-1270` Story 1.20 — Story 1.18 `.github/workflows/ci.yml` python-job extension is precondition for `INV-fr14i-ci-workflow-presence` registration]
- [Source: `_bmad-output/planning-artifacts/prd.md:969` FR14o (Test runner mandate) — normative]
- [Source: `_bmad-output/planning-artifacts/prd.md:1068` NFR1a (Test coverage floor) — context]
- [Source: `_bmad-output/planning-artifacts/prd.md:948` FR14a manifest-real-files clause amendment]
- [Source: `_bmad-output/planning-artifacts/prd.md:959` FR14i pre-bootstrap-degradation amendment]
- [Source: `_bmad-output/planning-artifacts/architecture.md:198-240` § M0 substrate developer-productivity floor — Python runtime substrate sub-section + CI integration + bootstrap arc]
- [Source: `_bmad-output/planning-artifacts/architecture.md:196` D6 (Python project shape) — root pyproject.toml + uv.lock decision + PEP 723 coexistence]
- [Source: `_bmad-output/planning-artifacts/architecture.md:154` Testing Framework decision (post-issue-#233 resolution: Vitest TS + pytest Python)]
- [Source: `_bmad-output/planning-artifacts/architecture.md:390` I7 (Version pinning at M0) — exact-version policy applied to Python dev deps per SC-3]
- [Source: `ralph.py:1-7` PEP 723 inline-script metadata — `requires-python = ">=3.10"` + `textual>=1.0.0` (SC-2 + SC-10 anchor)]
- [Source: `ralph.py:89-98` `format_duration` smoke target (Subtask 3.1)]
- [Source: `ralph.py:2015-2016` `if __name__ == "__main__":` guard (safe-import condition for Subtask 3.1)]
- [Source: `scripts/bootstrap-bmad-agents.py:1-7` PEP 723 inline-script metadata]
- [Source: `scripts/bootstrap-bmad-agents.py:24-25` `ADVISORY_TOOLS` + `EXECUTION_TOOLS` smoke targets (Subtask 4.1)]
- [Source: `packages/devbox/tui/__init__.py` + `packages/devbox/tui/theme.py:1-15` smoke targets (Subtask 5.1)]
- [Source: `.github/workflows/ci.yml:1-30` Story 1.17 substrate (Subtask 6.1 anchor)]
- [Source: `package.json:5` packageManager pin (`pnpm@10.29.2`)]
- [Source: `package.json:6-8` Node engines pin (`>=20 <21`)]
- [Source: `pnpm-workspace.yaml:1-4` workspace globs (Python OUT of workspace)]
- [Source: `.gitignore:61-72` Python patterns (already cover Subtask 2.1's `.venv/` + caches)]
- [Source: `CLAUDE.md:11-25` § Common commands table (post-Story-1.17 footer)]
- [Source: `AGENTS.md:43-45` § Testing section (Story 1.17 substrate; Subtask 8.1 anchor)]
- [Source: `RALPH.md` iter-286 lifecycle PATCH forecast bands; iter-344 substrate-extension class + iter-359 Story 1.17 second confirmation; iter-347 substrate-verification mandate; iter-348 + iter-357 course-correction-author origin yield; iter-352 narrow-substrate-extension SM yield; iter-358 `INV-git-hooks-preservation` carve-out; iter-362 first-CI-workflow security defense gap residual class]

## Dev Agent Record

### Agent Model Used

(populated at `/bmad-dev-story` time)

### Debug Log References

(populated at `/bmad-dev-story` time)

### Completion Notes List

(populated at `/bmad-dev-story` time per Subtasks 1.2 / 4.1 / 5.1 decision-records)

### File List

(populated at `/bmad-dev-story` time)

## Change Log

- **v1.1** (2026-04-25, iter-364) — Story SM-validated via `/bmad-create-story (args: "review")`; FR14n state transition `drafted → validated`. Two-subagent SM review (technical-correctness + prose-density per RALPH.md iter-235 narrow-surface; iter-352 post-dev recipe). Subagent A: 2 MUST-FIX + 2 SHOULD-FIX (sprint-status row drift 142→143 + state, architecture.md § M0 line range 198-237→198-240 ×6 sites, `__init__.py:1` empty-file citation, AC3/Subtask 6.1 line-range 16-29 vs 17-29 internal contradiction). Subagent B: 5 MUST-FIX + 5 SHOULD-FIX + 3 NIT/PASS — all course-correction-author "decide at dev-story time" deferrals locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule (Subtask 1.2 `uv pip compile --extra dev` exact command, Subtask 4.1 NO `__init__.py` ship, Subtask 5.1 `from tui.theme import theme` direct-import shape, Subtask 6.2 `version: "0.11.7"` exact-pin, Subtask 8.1 + AC5 byte-pinned AGENTS.md replacement string). 14 PATCHes applied inline at gate (7 MUST-FIX + 7 SHOULD-FIX/LLM-OPT; 1 SHOULD-FIX bundled with MUST-FIX) — within iter-363 forecast envelope 8–14 (slight overshoot consistent with iter-357's 16-PATCH course-correction-author baseline). 2 deferred (LLM-OPT C.1 Forecast density compression + D.2 Lessons-applied bullet — both deferrable per Subagent B). Sprint-status row unchanged (SM-validate is Ralph-internal per FR14n; row already at `ready-for-dev` from create-story iter-363).
- **v1.0** (2026-04-25, iter-363) — Story created via `/bmad-create-story` autonomous discovery from `_bmad-output/implementation-artifacts/sprint-status.yaml` first-backlog row (`1-18-bootstrap-python-test-runner-pytest-under-uv`); FR14n state transition `_(no story) → drafted`; sprint-status row `backlog → ready-for-dev`. Substrate verification per RALPH.md iter-347 against Story 1.18 SCP-233 § 4.6 + epics.md:1172-1204 Tasks: **0 SCP-side drifts** (improvement vs Story 1.17 iter-356's 1 drift — Story 1.18 inherits already-shipped CI workflow substrate, no first-creation hazard). 10 Tasks / ~22 subtasks scaffolded. SC-1 through SC-11 pinned (course-correction-author origin yield mitigation per RALPH.md iter-357 — Python version + dev-dep pinning + action versions + smoke targets + PEP 723 coexistence direction all locked at SM-validate, NOT deferred to dev-story time). Forecast envelope: 10–24 cumulative pre-merge PATCH (vs Story 1.17's 22 — narrower scope at substrate-extension class but course-correction-author origin holds). ATDD-skip forecast: ground-(a) substrate-verification (the three smoke scaffolds ARE the bootstrap red-phase per AC1; FR14n § ground-(b) sunset post-Story-1.17 per issue #233 amendment; cite (a) only OR (a)+(c) variant-(iii) hybrid).
