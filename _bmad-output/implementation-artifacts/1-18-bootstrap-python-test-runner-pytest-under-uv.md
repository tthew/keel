# Story 1.18: Bootstrap Python test runner (pytest under uv) + root pyproject.toml

Status: review

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

- [x] **Task 1 — Create root `pyproject.toml` with `[project]` metadata, dev deps, pytest config.** (AC: 1, 2)
  - [x] Subtask 1.1: Create `/workspace/ralph-bmad/.claude/worktrees/test-env/pyproject.toml` (worktree root; ABSENT pre-edit per substrate ledger). Content shape:
    - `[project]` table — `name = "keel-python"`, `version = "0.0.0"`, `requires-python = ">=3.10"` (matches `ralph.py:3` PEP 723 metadata exactly per SC-2), `dependencies = []` (no shared runtime deps; per-script PEP 723 carries runtime deps per D6 coexistence).
    - `[project.optional-dependencies]` — `dev = ["pytest", "pytest-asyncio", "ruff", "mypy", "textual"]` per SCP-233 § 4.1 FR14o + § 4.2 D6 shared dev deps list, plus `textual` added at dev-story per Subtask 3.1 substrate-probe-gap correction (Completion Notes document the +1 deviation; SC-3 policy ["exact-version pinning per I7"] preserved on all five deps).
    - `[tool.pytest.ini_options]` — `testpaths = ["tests", "scripts/tests", "packages/devbox/tui/tests"]` (three directories per AC1 + Subtask 3/4/5 scaffolds; ordering doesn't affect pytest collection but list in alphabetical-by-leading-segment order for consistency); `pythonpath = [".", "scripts", "packages/devbox"]` (`.` for `ralph.py` import, `scripts` for hyphen-named `bootstrap-bmad-agents.py` via importlib in Subtask 4.1, `packages/devbox` for `tui` package import via `__init__.py` at `packages/devbox/tui/__init__.py:1` per substrate ledger); `addopts = "-ra --strict-markers"` (standard pytest hardening — `-ra` shows summary of skipped/xfailed/failed; `--strict-markers` rejects unregistered markers, paying down ATDD-skip ground (b) sunset risk per FR14n amendment).
  - [x] Subtask 1.2: Resolve exact pytest 8.x patch + pytest-asyncio 0.x + ruff 0.x + mypy 1.x version literals at dev-story time via `uv pip compile --python 3.10 --resolution=highest --extra dev pyproject.toml` (verified against `uv 0.11.7` at SM-validate; `--extra dev` ensures the dev optional-deps group is resolved). Pin the resolved literals exactly (no `^` / `~` / `>=`) in `[project.optional-dependencies] dev`. Record the resolved versions in Dev Agent Record § Completion Notes BEFORE commit so post-dev SM can verify the pins per SC-3 + I7 exact-version policy.
  - [x] Subtask 1.3: Verify the file passes a TOML round-trip (`python -c "import tomllib; tomllib.load(open('pyproject.toml','rb'))"`) — guards against syntax errors before Subtask 2.1's `uv sync` runs.

- [x] **Task 2 — Run `uv sync` to materialize `.venv` + generate `uv.lock`; commit `uv.lock`.** (AC: 1, 2)
  - [x] Subtask 2.1: From the worktree root run `uv sync --extra dev`. The command (a) creates `.venv/` (gitignored per `.gitignore:66` `.venv/`), (b) installs the dev deps resolved in Subtask 1.2, (c) emits `uv.lock` at the worktree root. Verify exit code 0; capture `uv sync --frozen` re-run exit code 0 in Completion Notes per AC2's deterministic-resolution clause.
  - [x] Subtask 2.2: Add `uv.lock` to git index alongside `pyproject.toml`. Both files are committed (the lockfile IS the pin source per SC-3 — analogue of `pnpm-lock.yaml` for the TS half). `.venv/` stays gitignored; `.python-version` is NOT shipped (uv reads `requires-python` from `pyproject.toml`; no separate `.python-version` file is needed at this scope per SC-7).

- [x] **Task 3 — Create `tests/test_ralph.py` smoke covering `ralph.py:format_duration`.** (AC: 1)
  - [x] Subtask 3.1: Create directory `tests/` at worktree root (ABSENT pre-edit per substrate ledger). Author `tests/test_ralph.py` as a single-module pytest file:
    - `import ralph` (importable because `pythonpath` includes `.` per Subtask 1.1 + because `ralph.py:2015-2016` guards Textual app instantiation behind `if __name__ == "__main__":` so module-level import has no side-effects per substrate probe).
    - One `def test_format_duration_basic():` asserting `ralph.format_duration(0.0) == "0s"` (or whatever the function returns for zero seconds — exact return-shape verified at dev-story time via reading `ralph.py:89-98` and capturing the canonical zero-input output in Completion Notes BEFORE the assertion is written).
    - Optionally a second assertion that `ralph.format_duration(3725.0).endswith("s")` (a one-hour-plus input still produces a string ending in `s` — minimal smoke shape per SC-1 NOT a behavioural test).
  - [x] Subtask 3.2: Verify the test passes locally: `uv run pytest tests/test_ralph.py -v`.

- [x] **Task 4 — Create `scripts/tests/test_bootstrap_bmad_agents.py` smoke.** (AC: 1)
  - [x] Subtask 4.1: Create directory `scripts/tests/` (ABSENT pre-edit per substrate ledger). Author `scripts/tests/test_bootstrap_bmad_agents.py`. Because the source filename `scripts/bootstrap-bmad-agents.py` carries hyphens (not a valid Python module identifier), use `importlib.util.spec_from_file_location` to load the module:
    - `from pathlib import Path; import importlib.util`
    - `spec = importlib.util.spec_from_file_location("bootstrap_bmad_agents", Path(__file__).resolve().parent.parent / "bootstrap-bmad-agents.py")`
    - `module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)`
    - One `def test_module_loads_with_constants():` asserting `"Edit" in module.EXECUTION_TOOLS` AND `"Read" in module.ADVISORY_TOOLS` (both lists declared at `scripts/bootstrap-bmad-agents.py:24-25` per substrate probe — pure module-level constants, no I/O at import time per `bootstrap-bmad-agents.py:1-7` PEP 723 metadata + module body).
    - Note: `tests/__init__.py`, `scripts/tests/__init__.py`, and `packages/devbox/tui/tests/__init__.py` are NOT required and NOT shipped at this scope — pytest 8.x `--import-mode=prepend` (default) collects test files by unique basename, and the three test basenames (`test_ralph.py`, `test_bootstrap_bmad_agents.py`, `test_theme.py`) do not collide. Locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule. If a future smoke addition introduces a basename collision, that story adds `__init__.py` markers — Story 1.18 does NOT preempt.
  - [x] Subtask 4.2: Verify the test passes locally: `uv run pytest scripts/tests/test_bootstrap_bmad_agents.py -v`.

- [x] **Task 5 — Create `packages/devbox/tui/tests/test_theme.py` smoke.** (AC: 1)
  - [x] Subtask 5.1: Create directory `packages/devbox/tui/tests/` (ABSENT pre-edit per substrate ledger). Author `packages/devbox/tui/tests/test_theme.py`:
    - `from tui.theme import theme` (importable because `pythonpath` includes `packages/devbox` per Subtask 1.1 + `packages/devbox/tui/__init__.py` exists as an empty package marker per substrate ledger making `tui` a proper Python package).
    - One `def test_theme_neutral_500():` asserting `theme.colors.neutral_500 == "oklch(52% 0 0)"` — exact literal verified at substrate ledger via reading `packages/devbox/tui/theme.py:15`. Locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule (no `from tui import theme` + `theme.theme.colors...` alternative — picked the cleaner direct-import shape).
    - The `theme.py` file is `AUTOGENERATED from packages/ui/tokens.json` per its header comment (`theme.py:1`); the smoke test asserts a pinned literal that survives token regeneration (neutral_500 has been stable since Story 1.13). If a future token regen changes the literal, the smoke test fails — that's correct fail-loud behaviour, not a fragility bug.
  - [x] Subtask 5.2: Verify the test passes locally: `uv run pytest packages/devbox/tui/tests/test_theme.py -v`.

- [x] **Task 6 — Extend `.github/workflows/ci.yml` with `python` job.** (AC: 3)
  - [x] Subtask 6.1: Edit `.github/workflows/ci.yml` (lines 1–29 pre-edit per substrate ledger; Story 1.17 substrate; convention: `node` job = lines 17–29). The edit is ADDITIVE per SC-5 — the existing `node` job (lines 17–29) is byte-identical post-edit; a new `python` job is appended at the same `jobs:` indentation level. Pre-edit `jobs:` block ends at line 29 (`- run: pnpm turbo run test lint typecheck`); post-edit, the `python` job follows on a new line after the `node:` job's last step.
  - [x] Subtask 6.2: `python` job shape: `runs-on: ubuntu-latest`; steps in this exact order — (1) `actions/checkout@v4` (matches Story 1.17's `node` job major-pin per SC-4), (2) `astral-sh/setup-uv@v6` with `version: "0.11.7"` (exact-version pin per I7 + SC-3 — matches iter-env `uv` per substrate ledger; do NOT use `latest`/floating tag — locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule), (3) `uv sync --extra dev --frozen` (uses `uv.lock` deterministically per AC2), (4) `uv run pytest` (the canonical entry point per FR14o). Pin all GitHub Action versions per I7 using `@v4` / `@v6` major-pin for first-party + verified-publisher actions; avoid third-party actions (Story 1.17 CR iter-362 deferred SHA-pinning of third-party actions to Story 1.20/1.21 per its Change Log v1.6).
  - [x] Subtask 6.3: Verify `actionlint .github/workflows/ci.yml` exits 0 if `actionlint` is available in the iter env. If absent (per RALPH.md iter-359 — `actionlint` was unavailable for Story 1.17), fall back to GH Actions ingestion-side validation post-push per AC3 + Story 1.17 Subtask 10.4 precedent. Branch protection / required-check is GH-UI / admin-scope (out of substrate per SC-6).

- [x] **Task 7 — Update CLAUDE.md `## Common commands` table with `uv run pytest` row.** (AC: 4)
  - [x] Subtask 7.1: Edit `CLAUDE.md` `## Common commands` table — currently spans lines 11–25 post-Story-1.17 (the three rows added by Story 1.17 Task 8 are at lines 23–25 for `pnpm test` / `pnpm typecheck` / `pnpm lint`; verified at create-story time against current substrate). Append a new row `| Run Python tests | \`uv run pytest\` |` immediately after line 25, preserving the blank line before the prose paragraph that follows. Maintain alignment via prettier-friendly spacing (Subtask 9.4 confirms idempotence).

- [x] **Task 8 — Update AGENTS.md `## Testing` section to active-tense `uv run pytest` language.** (AC: 5)
  - [x] Subtask 8.1: Edit `AGENTS.md § Testing` (currently at lines 43–45 post-Story-1.17 per substrate ledger). Replace the existing forward-pointer sentence ("Python tests under `uv run pytest` arrive with Story 1.18.") with this EXACT byte-pinned wording (locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule — no dev-story-time wording slack): "Run `uv run pytest` from the worktree root for the workspace-wide pytest suite covering `ralph.py` (`tests/`), `scripts/bootstrap-bmad-agents.py` (`scripts/tests/`), and `packages/devbox/tui/` (`packages/devbox/tui/tests/`); dev deps + Python 3.10+ are pinned in root `pyproject.toml` + `uv.lock` (D6)." The first sentence (re `pnpm test`) is BYTE-IDENTICAL — Story 1.18 only edits the second sentence. Cross-reference to `architecture.md § M0 substrate developer-productivity floor` (the third sentence) is BYTE-IDENTICAL.
  - [x] Subtask 8.2: Verify prettier idempotence (`pnpm format:check` exits 0 against AGENTS.md) per AC5 + Story 1.17 SC-10 precedent.

- [x] **Task 9 — Iter-env smoke validation.** (AC: 1, 2, 3, 4, 5)
  - [x] Subtask 9.1: `uv sync --extra dev && uv run pytest` produces exit code 0 in the iteration environment + the three smoke tests are reported in pytest output. Capture the pytest summary line (e.g., `===== 3 passed in 0.12s =====`) as evidence in Dev Agent Record § Completion Notes per AC1.
  - [x] Subtask 9.2: `uv sync --frozen` exits 0 (lockfile-pin verified deterministic) per AC2.
  - [x] Subtask 9.3: `pnpm keel-invariants:check` (Story 1.9 sync-gate) exits 0 — no NEW manifest drift introduced by Story 1.18's edits. **Note (PARTIAL):** the three pre-existing `INV-git-hooks-preservation` drifts on `feat/epic-2-packaged-devbox` head (RALPH.md iter-358 gotcha; out-of-scope per "Address before Story 1.20 close-out") persist unchanged — Story 1.18 does NOT inadvertently touch the prek-hook surface. AC2 satisfied (the AC's specific check is "no NEW drift attributable to Story 1.18 edits"); pre-existing drifts are explicitly carved out per SC-9.
  - [x] Subtask 9.4: `pnpm typecheck && pnpm lint && pnpm format:check` all exit 0 (Story 1.18's TS-side surface is null — `pyproject.toml`, `uv.lock`, `tests/`, `scripts/tests/`, `packages/devbox/tui/tests/` are all .py / .toml / .lock; `format:check` covers the `.github/workflows/ci.yml` YAML edit + the AGENTS / CLAUDE markdown edits per Story 1.17 precedent).
  - [x] Subtask 9.5: `actionlint .github/workflows/ci.yml` if available (else GH ingestion-side validation per AC3 fallback) — Subtask 6.3.

- [x] **Task 10 — Sprint-status flip + Change Log v1.0 (lifecycle hygiene at story creation).** (no direct AC — process; executed at `/bmad-create-story` iter — DO NOT re-execute at dev-story time)
  - [x] Subtask 10.1: Sprint-status flip `1-18-bootstrap-python-test-runner-pytest-under-uv: backlog → ready-for-dev` lands at `/bmad-create-story` iter (this iteration; skill-handled per `workflow.md` step 6).
  - [x] Subtask 10.2: Change Log v1.0 entry lands at create-story iter (see § Change Log).
  - [ ] Subtask 10.3 (informational, no dev-story action): subsequent versions follow Story 1.17 precedent — v1.1 pre-dev SM-validate, v1.2 ATDD-skip-or-scaffold, v1.3 dev-story landing, v1.4 trace, v1.5 post-dev SM, v1.6+ CR.

## Dev Notes

### Scope clarifications (pinned at draft, MUST be honored — not re-negotiable without Change Log entry)

- **SC-1: Story 1.18 is BOOTSTRAP, not coverage.** Three test scaffolds wire the runner against three Python module families (`ralph.py`, `scripts/bootstrap-bmad-agents.py`, `packages/devbox/tui/`). Each scaffold is a SMOKE — module loads + one pinned-literal assertion. Behavioural / property-based / branch-coverage tests are deferred to Story 1.21 audit / Epic 4 prep / future per-module backfill. The three smokes exist ONLY to satisfy AC1 + the FR14n § ground-(a) substrate-verification clause for ATDD-skip — they are NOT a stand-in for keel-invariants-style adversarial test passes (that pattern is Story 1.19 territory but for the TS side; Python equivalent is post-bootstrap follow-up).
- **SC-2: Python version pin = `>=3.10` matching `ralph.py:3` PEP 723.** The root `pyproject.toml` `requires-python` field MUST equal `">=3.10"` byte-for-byte to match `ralph.py`'s existing PEP 723 inline-script metadata block (`ralph.py:3`). This avoids divergence between the per-script PEP 723 path (`uv run ralph.py`) and the root-project path (`uv run pytest`). Locked at SM-validate per RALPH.md iter-357 lesson: do not defer this decision to dev-story time. Future bumps (Python 3.11 / 3.12 / 3.13 floor) require a separate amendment.
- **SC-3: Dev-dep exact-version pinning per I7.** All five dev deps in `[project.optional-dependencies] dev` (pytest, pytest-asyncio, ruff, mypy, textual — `textual` added at dev-story per Subtask 3.1 substrate-probe-gap correction; see Completion Notes) MUST be pinned to exact patch versions (no `^` / `~` / `>=` / `==X.Y.*`). Resolution at dev-story time via `uv pip compile --resolution=highest pyproject.toml` (or equivalent — verified against `uv 0.11.7`). Resolved literals captured in Completion Notes BEFORE commit per Subtask 1.2 + SC-2 of Story 1.17 precedent. The `uv.lock` is the secondary lock (transitive deps); `pyproject.toml` is the primary author-stated pin (top-level deps). Both are committed per Subtask 2.2. SC-3 policy ("exact-version pinning per I7") preserved on all 5 deps; the original "four" wording (pre-iter-368 SM-verify) was forecast, not policy.
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
- **Empirical vs forecast (iter-368 SM-verify retrospective):** SM-validate landed at TOP of forecast envelope (14 actual vs 8–14 — course-correction-author origin pattern held, consistent with RALPH.md iter-357's 16-PATCH baseline at the same author class; narrower scope discount of ~12% applied per iter-364 yield-trend datapoint). ATDD-skip / dev-story / trace all landed at 0 PATCH (clean substrate-extension landing — third confirmation of the substrate-extension subclass per RALPH.md iter-344 + iter-359 precedent; matches Story 1.17 zero-PATCH triple at the same gates). Substrate-probe gap (textual top-level import at `ralph.py:66`) surfaced at dev-story per RALPH.md iter-366 lessons-learned — single-root impact (5th dev dep added, downstream wording in SC-3 + Subtask 1.1 patched at SM-verify per iter-368 PATCH-(a)+(b)). SM-verify yield: **4 PATCH at gate** (within iter-352 narrow-substrate-extension envelope 1–4; matches Story 1.17 iter-361 4-PATCH SM-verify datapoint exactly — third confirmation of post-dev SM-verify residual class for course-correction-author origin = downstream-reference debt + Forecast empirical block + Change Log block-reorder). Cumulative pre-merge PATCH count Story 1.18 lifecycle through SM-verify: 18 (14 SM-validate + 0 ATDD-skip + 0 dev + 0 trace + 4 SM-verify); CR forecast 0–3 inline-bundle-close per iter-342 + iter-362 first-CI-workflow-job security defense gap residual class (the new `python` job MAY surface job-level hardening — see Forecast bullet § CR above).

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

claude-opus-4-7 (Ralph build-mode iter-366; single-iter dev-story landing per RALPH.md iter-344 substrate-extension class + iter-359 Story 1.17 second confirmation).

### Debug Log References

- `uv pip compile --python 3.10 --resolution=highest --extra dev pyproject.toml` (Subtask 1.2 resolution; Python 3.10 download from python-build-standalone failed network — fell back to system Python 3.12.3 for compile-time resolution; runtime `requires-python = ">=3.10"` constraint preserved)
- `UV_PYTHON_PREFERENCE=only-system uv sync --extra dev` (Subtask 2.1; exit 0; installed 12 dev-extras packages + transitive deps + textual transitive deps after Subtask 3.1 deviation)
- `UV_PYTHON_PREFERENCE=only-system uv sync --frozen --extra dev` (Subtask 9.2; exit 0; deterministic re-resolution per AC2)
- `UV_PYTHON_PREFERENCE=only-system uv run pytest` — `4 passed in 0.97s` (Subtask 9.1; AC1 satisfied; pytest 9.0.3 / pluggy 1.6.0 / asyncio-1.3.0)
- `pnpm typecheck` exit 0 (Subtask 9.4; 16/16 cached tasks)
- `pnpm lint` exit 0 (Subtask 9.4; 16/16 cached tasks)
- `pnpm format:check` initial fail on `.github/workflows/ci.yml` (single-quote vs double-quote on `version: "0.11.7"` line); resolved via `pnpm exec prettier --write .github/workflows/ci.yml` (prettier converted to single-quotes per repo convention); `format:check` re-run exit 0 (Subtask 9.4 + 8.2)
- `pnpm keel-invariants:check` exit 1 (Subtask 9.3 PARTIAL per SC-9 + AC2 carve-out — three pre-existing `INV-git-hooks-preservation` drifts on `feat/epic-2-packaged-devbox` head per RALPH.md iter-358 gotcha; verified via direct comparison: identical contentHash mismatch `cb27263d… → 42a42b16…` + same two `git-hook-missing` entries observed pre-Story-1.18 at iter-359; ZERO new drifts attributable to Story 1.18)
- `actionlint .github/workflows/ci.yml` not available in iter env (`command not found`; Subtask 9.5 falls back to GH Actions ingestion-side validation per AC3 + Story 1.17 Subtask 10.4 precedent — workflow's `pull_request: branches: [main]` trigger remains unfired because PR #236 targets `feat/epic-2-packaged-devbox`)

### Completion Notes List

**Subtask 1.2 — Resolved dev-dep version pins (captured BEFORE commit per SC-3 + I7 exact-version policy):**

| Dep | Resolved-highest version | Story-spec forecast | Drift class |
| --- | --- | --- | --- |
| `pytest` | `9.0.3` | `8.x patch` | major-version drift (story spec was 8.x-stable as of SCP authoring; pytest 9 GA released after SCP) |
| `pytest-asyncio` | `1.3.0` | `0.x` | major-version drift (1.0 GA released after SCP) |
| `ruff` | `0.15.12` | `0.x` | within-major (forecast holds) |
| `mypy` | `1.20.2` | `1.x` | within-major (forecast holds) |
| `textual` | `8.2.4` | (NOT in spec — see deviation note below) | added at dev-story per substrate-probe gap |

The two major-version drifts (pytest, pytest-asyncio) are explicit consequences of `--resolution=highest` per Subtask 1.2's literal command. SC-3 is policy ("exact-version pinning per I7"); the version values themselves are not policy. pytest 9.x default `--import-mode=prepend` matches Subtask 4.1's pinned assumption (no `__init__.py` files shipped; basenames are unique across `test_ralph.py` / `test_bootstrap_bmad_agents.py` / `test_theme.py`). All four smoke tests collected + passed cleanly under pytest 9.0.3.

**Subtask 3.1 — Substrate-probe gap (textual top-level import deviation from SC-3 four-dev-deps clause):**

Substrate ledger entry "ralph.py smoke target" probed `if __name__ == "__main__":` guard at `ralph.py:2015-2016` (App instantiation guarded) but did NOT probe the unconditional top-level `from textual.app import App, ComposeResult` at `ralph.py:66` (verified at dev-story time via `Grep "^from textual\|^import textual" ralph.py` — five textual imports at lines 66/67/68/71/72, all top-level, none lazy). Importing `ralph` therefore requires `textual` at test time.

Resolution: added `textual==8.2.4` to `[project.optional-dependencies] dev` (5th dev dep — SC-3 clause stated "four dev deps"; this is a +1 deviation). Resolved-highest 8.2.4 imports cleanly against `ralph.py`'s textual usage surface (App / ComposeResult / Container / RichLog / Static / get_current_worker / work — all backward-compatible from textual 1.x to 8.x per the GREEN smoke run). The PEP 723 floor at `ralph.py:5` is `textual>=1.0.0`; pinning textual==8.2.4 in dev deps does NOT mutate the per-script PEP 723 metadata (preserved BYTE-IDENTICAL per SC-10 — root pyproject carries TEST-TIME deps only; per-script PEP 723 carries RUNTIME deps).

This is a substrate-verification correction at dev-story time per Subtask 3.1's "verified at dev-story time" clause — exactly what dev-story is for. SC-3's "four dev deps" wording was forecast, not policy; the policy ("exact-version pinning per I7") is preserved on all five deps. Future Story 1.21 audit may codify a separate `[project.optional-dependencies] tests` group if test-time deps want isolation from lint/type-check deps; Story 1.18 does NOT preempt.

**Subtask 3.1 — Canonical zero-input output for `format_duration` (captured BEFORE assertion per spec):**

`ralph.py:89-96` `format_duration(0.0)` returns `"0s"` — falls through `h>0` and `m>0` branches (both 0); reaches the bare `return f"{s}s"` at line 96 with `s=0`. Smoke test asserts equality against this literal. Second smoke (`format_duration(3725.0).endswith("s")` = `"1h02m05s".endswith("s")` = True) is a one-hour-plus-input shape check per Subtask 3.1's "optionally a second assertion" clause.

**Subtask 4.1 — `__init__.py` decision held (no markers shipped):**

Verified pytest 9.0.3 default `--import-mode=prepend` collects unique-basename test files cleanly without `__init__.py` markers. The four-collected smoke tests (one each in `tests/`, `scripts/tests/`, `packages/devbox/tui/tests/` plus the second `format_duration` assertion in `tests/test_ralph.py`) all collected + passed in a single pytest run. Decision pinned at SM-validate per RALPH.md iter-357 lock-don't-defer rule held in practice.

**Subtask 5.1 — `from tui.theme import theme` direct-import shape held:**

Verified at dev-story time: `pythonpath = ["packages/devbox", ...]` makes `tui` importable as a package; `from tui.theme import theme` resolves to the `theme = SimpleNamespace(...)` at `theme.py:8`; `theme.colors.neutral_500 == "oklch(52% 0 0)"` literal at `theme.py:15` matches assertion. Decision pinned at SM-validate per RALPH.md iter-357 lock-don't-defer rule held in practice.

**Subtask 6.1 — Pre-edit ci.yml line range corrected at dev-story time:**

Substrate ledger cited `.github/workflows/ci.yml:1-30` as Story 1.17 substrate (post-iter-362-CR); verified at dev-story time line ranges are: `name:` line 1; `on:` lines 3-7; `permissions:` lines 9-10; `concurrency:` lines 12-14; `jobs:` line 16; `node:` job lines 17-29 (matches ledger). The append landed at line 30 (post-edit), with prettier-normalized `version: '0.11.7'` (single-quote per repo convention; spec said double-quote in line with story-spec language but prettier configures single-quote — non-blocking).

**Subtask 9.3 — Sync-gate PARTIAL per SC-9 carve-out (AC2 satisfied):**

Pre-existing 3× `INV-git-hooks-preservation` drifts on `feat/epic-2-packaged-devbox` head (RALPH.md iter-358 + iter-359 gotcha). Verified pre-existing by comparing against last-clean-state baseline: contentHash `42a42b16…` matches what was observed at Story 1.17 iter-359 dev-story; `git-hook-missing: commit-msg` + `git-hook-missing: pre-commit` matches (sync-gate hardcodes `<repoRoot>/.git/hooks` empty in worktree mode). ZERO new drifts attributable to Story 1.18 edits — AC2's "no NEW drift attributable to this story's edits" clause satisfied. Address before Story 1.20 close-out per SC-9 + RALPH.md iter-358 carry-rule.

**Subtask 9.5 — actionlint unavailable per RALPH.md iter-359 carry-rule:**

`actionlint` not installed in cc-devbox iter env (`command not found`). Falls back to GH Actions ingestion-side validation per AC3 + Story 1.17 Subtask 10.4 precedent. Workflow `pull_request:branches:[main]` trigger does NOT fire on PR #236 (base: `feat/epic-2-packaged-devbox`); ingestion validation will fire on the eventual base-flip-to-main at PR #230 / #235 / #236 merge cascade.

### File List

**Created:**

- `pyproject.toml` (worktree root; 28 lines; `[project]` + `[project.optional-dependencies]` + `[tool.pytest.ini_options]`)
- `uv.lock` (worktree root; 70159 bytes; deterministic dev-extras + transitive resolution per AC2)
- `tests/test_ralph.py` (8 lines; 2 smoke assertions on `format_duration`)
- `scripts/tests/test_bootstrap_bmad_agents.py` (12 lines; importlib-load pattern for hyphen-named source; 1 smoke assertion on `EXECUTION_TOOLS` + `ADVISORY_TOOLS` membership)
- `packages/devbox/tui/tests/test_theme.py` (5 lines; 1 smoke assertion on `theme.colors.neutral_500` literal)

**Modified:**

- `.github/workflows/ci.yml` (additive; `python` job appended after `node` job per AC3 + SC-5; existing `node` job byte-identical pre/post; prettier auto-normalized `version` to single-quotes)
- `CLAUDE.md` (additive; `| Run Python tests | \`uv run pytest\` |` row appended to `## Common commands` table per AC4)
- `AGENTS.md` (rewrites second sentence of `## Testing` section to byte-pinned active-tense wording per AC5; first + third sentences byte-identical pre/post)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (row 143 `1-18-…: ready-for-dev → in-progress → review`; `last_updated` field bumped to iter-366)

**Sprint-status flow:** `ready-for-dev → in-progress` at Step 4 (dev-story start); `in-progress → review` at Step 9 (dev-story end). Both transitions in-iter; final state `review` post-commit.

## Change Log

- **v1.0** (2026-04-25, iter-363) — Story created via `/bmad-create-story` autonomous discovery from `_bmad-output/implementation-artifacts/sprint-status.yaml` first-backlog row (`1-18-bootstrap-python-test-runner-pytest-under-uv`); FR14n state transition `_(no story) → drafted`; sprint-status row `backlog → ready-for-dev`. Substrate verification per RALPH.md iter-347 against Story 1.18 SCP-233 § 4.6 + epics.md:1172-1204 Tasks: **0 SCP-side drifts** (improvement vs Story 1.17 iter-356's 1 drift — Story 1.18 inherits already-shipped CI workflow substrate, no first-creation hazard). 10 Tasks / ~22 subtasks scaffolded. SC-1 through SC-11 pinned (course-correction-author origin yield mitigation per RALPH.md iter-357 — Python version + dev-dep pinning + action versions + smoke targets + PEP 723 coexistence direction all locked at SM-validate, NOT deferred to dev-story time). Forecast envelope: 10–24 cumulative pre-merge PATCH (vs Story 1.17's 22 — narrower scope at substrate-extension class but course-correction-author origin holds). ATDD-skip forecast: ground-(a) substrate-verification (the three smoke scaffolds ARE the bootstrap red-phase per AC1; FR14n § ground-(b) sunset post-Story-1.17 per issue #233 amendment; cite (a) only OR (a)+(c) variant-(iii) hybrid).
- **v1.1** (2026-04-25, iter-364) — Story SM-validated via `/bmad-create-story (args: "review")`; FR14n state transition `drafted → validated`. Two-subagent SM review (technical-correctness + prose-density per RALPH.md iter-235 narrow-surface; iter-352 post-dev recipe). Subagent A: 2 MUST-FIX + 2 SHOULD-FIX (sprint-status row drift 142→143 + state, architecture.md § M0 line range 198-237→198-240 ×6 sites, `__init__.py:1` empty-file citation, AC3/Subtask 6.1 line-range 16-29 vs 17-29 internal contradiction). Subagent B: 5 MUST-FIX + 5 SHOULD-FIX + 3 NIT/PASS — all course-correction-author "decide at dev-story time" deferrals locked at SM-validate per RALPH.md iter-357 lock-don't-defer rule (Subtask 1.2 `uv pip compile --extra dev` exact command, Subtask 4.1 NO `__init__.py` ship, Subtask 5.1 `from tui.theme import theme` direct-import shape, Subtask 6.2 `version: "0.11.7"` exact-pin, Subtask 8.1 + AC5 byte-pinned AGENTS.md replacement string). 14 PATCHes applied inline at gate (7 MUST-FIX + 7 SHOULD-FIX/LLM-OPT; 1 SHOULD-FIX bundled with MUST-FIX) — within iter-363 forecast envelope 8–14 (slight overshoot consistent with iter-357's 16-PATCH course-correction-author baseline). 2 deferred (LLM-OPT C.1 Forecast density compression + D.2 Lessons-applied bullet — both deferrable per Subagent B). Sprint-status row unchanged (SM-validate is Ralph-internal per FR14n; row already at `ready-for-dev` from create-story iter-363).
- **v1.2** (2026-04-25, iter-365) — ATDD-skip applied per FR14n § ATDD-skip clause; FR14n state transition `validated → atdd-scaffolded`. Bare ground-(a) substrate-verification sufficiency (precedent: Story 1.17 iter-358 — 1st post-(b)-sunset ATDD-skip; Story 1.18 is 2nd post-(b)-sunset / 30th cumulative project ATDD-skip / 3rd course-correction-origin ATDD-skip). Rationale: every AC ↔ substrate file 1:1 — AC1 literally declares the three smoke scaffolds (`tests/test_ralph.py`, `scripts/tests/test_bootstrap_bmad_agents.py`, `packages/devbox/tui/tests/test_theme.py`) AS the bootstrap red-phase ("all three scaffolds pass / exit code 0"); AC2 substrate-verifiable via `uv sync --frozen` exit-code 0 + Story 1.9 sync-gate green; AC3 substrate-verifiable via `actionlint` (or GH ingestion-side fallback per Story 1.17 Subtask 10.4 precedent); AC4 + AC5 substrate-verifiable via `pnpm format:check` + structural diff. Ground (b) "no test runner" sunset under issue #233 amendment per FR14n (Story 1.17 IS the test runner for TS; uv exists at `/usr/local/bin/uv` per substrate ledger). Ground (c)-(iii) cross-referenced (AC1's "all three scaffolds pass" is spec-declared CR-substitution) but not primary per Story 1.17 iter-358 IP directive. No skill invocation (matches Story 1.17 iter-358 pattern — FR14n § ATDD-skip authorizes direct rationale-pinning in IP/Change Log without `/bmad-testarch-atdd` execution). 0 fix-task QUEUE entries — direct promotion to `atdd-scaffolded`. Sprint-status row unchanged (ATDD-skip is Ralph-internal per FR14n).
- **v1.3** (2026-04-26, iter-366) — Story dev-story landed via `/bmad-dev-story`; FR14n state transition `atdd-scaffolded → in-dev → review` (single-iter same-iteration per RALPH.md iter-344 substrate-extension class + iter-359 Story 1.17 second confirmation; this is the third confirmation in the substrate-extension subclass — after Story 2.18 iter-350 + Story 1.17 iter-359). All 10 Tasks / 22 subtasks complete; all 5 ACs satisfied (AC1: 4 pytest smokes pass — 2 in `tests/test_ralph.py` + 1 each in the two sibling test files; AC2: `uv sync --frozen --extra dev` exit 0 + sync-gate carve-out per SC-9; AC3: `python` job appended additively + node-job byte-identical + actionlint fallback per Subtask 9.5; AC4: CLAUDE.md row appended; AC5: AGENTS.md byte-pinned sentence rewrite + prettier idempotent). **Substrate-probe gap surfaced + corrected at dev-story time:** SM-validate Subtask 3.1 substrate probe missed `ralph.py:66` top-level `from textual.app import ...` (verified at dev-story via `Grep "^from textual"` = 5 textual imports at `:66/67/68/71/72` all top-level). Resolution: added `textual==8.2.4` as 5th dev dep (SC-3 wording was "four dev deps"; this is a +1 deviation justified by AC1 satisfaction; SC-3 policy ["exact-version pinning per I7"] preserved on all 5; SC-3 + Subtask 1.1 wording patched at iter-368 SM-verify). **Resolved-highest version drift vs spec forecast:** pytest 9.0.3 (vs forecast 8.x), pytest-asyncio 1.3.0 (vs forecast 0.x); ruff 0.15.12 + mypy 1.20.2 within forecast. Both major drifts are explicit consequences of `--resolution=highest` per Subtask 1.2's command. 0 fix-task QUEUE entries — direct promotion to `review`. Sprint-status row `ready-for-dev → in-progress → review`; last_updated bumped to iter-366. Cumulative pre-merge PATCH count Story 1.18 lifecycle to date: 14 (unchanged from SM-validate iter-364 — clean dev-story landing, 0 PATCHes at gate; matches Story 1.17 iter-359 zero-PATCH dev-story baseline).
- **v1.4** (2026-04-26, iter-367) — Story trace landed via `/bmad-testarch-trace (args: "yolo")`; FR14n state transition `in-dev → traced`. Gate **WAIVED** — 30th cumulative trace-WAIVED + 2nd Epic-1-reopen-arc + 3rd course-correction-origin (after Story 2.18 iter-351 + Story 1.17 iter-360). Coverage 1/5 FULL (20%); P0 50% (AC1 FULL via 4 pytest smokes — `tests/test_ralph.py::test_format_duration_basic` + `::test_format_duration_hour_plus_ends_with_s` + `scripts/tests/test_bootstrap_bmad_agents.py::test_module_loads_with_constants` + `packages/devbox/tui/tests/test_theme.py::test_theme_neutral_500`; AC2 PARTIAL — `INV-deps-version-pinning` sync-gate green for new drift, manifest registration deferred to Story 1.20 / 1.21 per SC-8 + SC-9; pre-existing 3× `INV-git-hooks-preservation` drifts carved out per SC-9); P1 0% (AC3 PARTIAL — `actionlint` unavailable in iter env, GH ingestion fallback deferred to PR base-flip-to-main per SC-6); P2 0% (AC4 + AC5 doc-substrate PARTIAL — prettier-idempotent, no automated prose-quality assertion). Hybrid grounds (a) substrate-verification covers AC + (c) variant-(ii)+(iii) per IP § NOW directive; deterministic FAIL → WAIVED per structural-artefact rationale (Story 1.18 IS the Python test runner being authored — no pre-existing pytest corpus). 0 fix-task QUEUE entries → direct promotion to `traced`. Trace artefacts at `_bmad-output/test-artifacts/traceability/1-18-bootstrap-python-test-runner-pytest-under-uv.md` + `…-e2e-trace-summary.json` + `…-gate-decision.json`. Cumulative pre-merge PATCH count Story 1.18 lifecycle: 14 (unchanged — WAIVED applies no patches; matches Story 1.17 iter-360 zero-PATCH trace baseline). Sprint-status row unchanged (trace is Ralph-internal). Residual risks tracked in gate-decision.json: Python-dep manifest registration (Story 1.20 / 1.21 per SC-9 two-path), `actionlint` behavioural half (PR base-flip), 3× `INV-git-hooks-preservation` (RALPH.md iter-358 gotcha; address before Story 1.20 close-out), substrate-probe-gap carry-rule (RALPH.md iter-366 lessons-learned).
- **v1.5** (2026-04-26, iter-368) — Story post-dev SM-verified via `/bmad-create-story (args: "review")`; FR14n state transition `traced → sm-verified`. Two-subagent review (technical-correctness + prose-density per RALPH.md iter-235 narrow-surface; iter-352 post-dev recipe). **Subagent A (technical-correctness): GREEN** — every AC verified against landed substrate (`pyproject.toml` testpaths matches; `uv run pytest` 4 passed; sync-gate carve-out exact match `42a42b16…`; `.github/workflows/ci.yml` node job byte-identical to Story 1.17 substrate per `git show 58a183f:.github/workflows/ci.yml` diff; `python` job exact-shape per Subtask 6.2 with prettier-normalized single-quote `version: '0.11.7'`; CLAUDE.md row appended; AGENTS.md byte-pinned sentence verbatim; all 5 substrate ledger sample anchors exact). 0 MUST-FIX + 1 SHOULD-FIX (SC-3 "four dev deps" → "five" downstream-reference debt — convergent with Subagent B). **Subagent B (prose-density): YELLOW-LEAN-GREEN** — convergent on the SC-3 SHOULD-FIX (S1) + 3 additional SHOULD-FIX (S2 Subtask 1.1 dev list update; S3 § Forecast empirical-vs-forecast deltas block per iter-361 residual class; S4 Change Log block re-order to ASCENDING per iter-361 PATCH M1-established convention) + 1 NIT (AC4 line-range parenthetical drift; defer) + 1 LLM-OPT (textual-import rationale 2× redundancy across Completion Notes + Change Log; defer). **4 PATCHes applied inline at gate** (within RALPH.md iter-352 forecast envelope 1–4; matches Story 1.17 iter-361 4-PATCH SM-verify datapoint exactly): (1) S1 — SC-3 line 122 "four" → "five" with textual rationale + policy-preservation note; (2) S2 — Subtask 1.1 line 60 dev list updated to 5-element array with substrate-probe-gap correction note; (3) S3 — § Forecast envelope appended empirical-vs-forecast deltas block (iter-368 SM-verify retrospective; SM-validate landed at TOP of forecast envelope; ATDD/dev/trace all 0 PATCH; substrate-probe gap surfaced at iter-366 with single-root downstream impact; SM-verify yield 4 within band); (4) S4 — Change Log block reordered v1.4→v1.0 (reverse-chrono) → v1.0→v1.4 (ASCENDING) per iter-361 PATCH M1 + Story 1.17 sibling convention (third precedent of post-dev SM-verify Change Log reorder). **Post-dev SM-verify yield empirical (course-correction-author origin, narrow-substrate-extension class, post-clean-dev-landing — third datapoint after Story 2.18 iter-352 = 5 PATCH + Story 1.17 iter-361 = 4 PATCH):** **Story 1.18 = 4 PATCH** — re-confirms iter-352 narrow-band 1–4 envelope; iter-361 4-PATCH cluster reproduces exactly; downstream-reference debt + Forecast empirical + Change Log reorder are now a CONFIRMED 3-class residual signature for course-correction-author origin post-dev SM-verify (not 2-class as iter-361 lessons-learned suggested). **Pattern carry-rule extension (NEW, supersedes iter-361 carry-rule):** post-dev SM-verify probe order should be (1) dev-story-time additions / deviations not folded back into spec wording (iter-368 textual=5th-dep case; pytest version drift case earlier); (2) line-range drift on table/section anchors after dev-story extends them (iter-361 case); (3) Forecast empirical-vs-forecast historical block missing (iter-361 + iter-368 confirmed); (4) Change Log block-reorder check vs sibling-story convention (iter-361 + iter-368 confirmed). 0 NIT applied / 0 LLM-OPT applied (both deferred per Subagent B recommendation; not blocking). Story file `Status: review` unchanged; sprint-status row unchanged (SM-verify is Ralph-internal per FR14n). 0 fix-task QUEUE entries → direct promotion to `sm-verified`. Cumulative pre-merge PATCH count Story 1.18 lifecycle to date: 18 (14 SM-validate + 4 SM-verify; 0 dev / 0 trace / 0 ATDD-skip).
