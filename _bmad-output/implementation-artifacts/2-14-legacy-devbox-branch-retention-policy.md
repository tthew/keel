# Story 2.14: Legacy-devbox branch retention policy

Status: ready-for-dev <!-- Ralph-internal `Story State` = `atdd-scaffolded` at iter-289 `/bmad-testarch-atdd` SKIP-WITH-GROUNDS-(ii)+(iii) per § Story Lifecycle row `validated → /bmad-testarch-atdd`. Twenty-fourth cumulative FR14n ATDD-skip precedent (10 Epic-1 + 14 Epic-2 incl. Story 2.14). Sprint-status row stays `ready-for-dev` (atdd-scaffolded is lifecycle-internal per iter-282 Story 2.13 precedent). ZERO-PATCH iter per Story 2.5 iter-186 canonical pattern (IP + RALPH.md + Status HTML comment only; no story-file Change Log v1.1 entry; no separate ATDD checklist artefact generated — skill HALTed at Step 1 § 2 Prerequisites on missing test framework, clean SKIP exit). **Grounds narrower than Story 2.13 iter-282's (c)+(ii)+(iii)** — Story 2.14 drops (c) because AC 1/2/3/4 are ALL static-smoke-testable via git-state inspection (no operator-workstation-deferred live ACs). Grounds load-bearing for Story 2.14: (ii) No live test runner at 1.0 — zero test framework under repo root (`playwright.config.*`, `cypress.config.*`, `pyproject.toml`, `pom.xml`, `build.gradle`, `go.mod`, `Cargo.toml`, `Gemfile`, `*_test.go`, `conftest.py`, `.rspec` all absent at iter-289 verification; Epic 13 scope); all ACs land as Task-internal impl-time smokes at `/bmad-dev-story` per Task 1-4 dev spec. (iii) Adversarial-coverage substitutes — post-dev SM two-subagent (iter-235 pattern) + CR three-layer fan-out (iter-271/277 pattern) + Story 1.9 sync-gate on new `docs/invariants/devbox-legacy-branch-retention.md` sha256 (manifest 33→34) + INVARIANTS.md anchor parse + `git ls-remote origin legacy-devbox` + `git show origin/legacy-devbox:README.md` content-grep smokes at trace + Epic 13 downstream regression (future test-runner will exercise manifest/doc synchrony). Next iter (iter-290): `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-14-legacy-devbox-branch-retention-policy.md")` per § Story Lifecycle row `atdd-scaffolded → /bmad-dev-story`. -->

<!-- Note: Validation is optional. Run `/bmad-create-story (args: "review")` for pre-dev quality check before `/bmad-testarch-atdd` / `/bmad-dev-story`. -->

## Story

As Tthew (substrate maintainer carrying PRD technical-risk mitigation),
I want a `legacy-devbox` git branch carrying the pre-absorption standalone [`cc-devbox`](https://github.com/tthew/cc-devbox) layout — kept reachable via `origin/legacy-devbox` until after the M4 checkpoint and retired by Story 15b.1's `scripts/major-cut.sh` at the 1.0 cut ritual — alongside committed retention policy + cherry-pick workflow + triage path + sunset criteria,
So that if the absorbed `packages/devbox/` substrate (Stories 2.1-2.13 + 2.15-2.17) hits a regression mid-build, there is a working fallback Ralph + operators can compare against without scrambling — closing the PRD § Technical Risks bootstrap-handoff mitigation gap (`prd.md:617`).

## Acceptance Criteria

1. **`legacy-devbox` branch exists with pre-absorption cc-devbox layout + retention README.** Given remote `origin/legacy-devbox` exists, when I `git fetch origin legacy-devbox && git checkout legacy-devbox`, then the working tree carries the pre-absorption standalone [`cc-devbox`](https://github.com/tthew/cc-devbox) layout (top-level `Dockerfile`, `docker-compose.yml`, `Makefile`, `entrypoint.sh`, `README.md`, etc. — NOT nested under `packages/devbox/`). The branch's `README.md` opens with a Story-2.14 retention banner naming (a) scope ("retention-only snapshot of upstream cc-devbox; substrate-canonical devbox lives at `packages/devbox/` on `main`"), (b) sunset criteria ("retired by Story 15b.1's `scripts/major-cut.sh` at the 1.0 cut ritual; tagged `legacy-devbox-final` then removed from active tracking"), (c) the operator pointer back to the substrate (`packages/devbox/README.md` on `main`).

2. **Cherry-pick workflow documented as manual (not automated) with minimal-drift expectation.** Given the legacy branch is in retention, when a security-critical upstream patch lands in `main`'s `packages/devbox/`, then `docs/invariants/devbox-legacy-branch-retention.md § Cherry-pick workflow` documents the manual diff-application recipe (paths differ — `packages/devbox/<file>` on main vs `<file>` at branch root; `git format-patch -1 <main-sha> -- packages/devbox/ | sed 's|^.*packages/devbox/|a/|; s|^.*packages/devbox/|b/|' | git apply` is canonical) and explicitly frames the expectation as "minimal-drift retention, not feature parity" — the legacy branch tracks security-critical fixes ONLY (CVE-class, fail-closed-egress regressions, secret-leakage), not feature additions or cosmetic refactors. The workflow is documented-but-not-automated by design (FR44 AMEND would be required to script it; out of scope at 1.0).

3. **Retirement procedure documented (executed by Story 15b.1).** Given the M4 checkpoint passes without devbox regressions reported, when Tthew decides to retire the branch, then the documented procedure in `docs/invariants/devbox-legacy-branch-retention.md § Retirement gate` requires: (a) an `RALPH.md § Decisions` entry recording the decision with the M4 checkpoint reference (date + checkpoint-doc path under `docs/research/checkpoints/YYYY-Q#.md` per FR33), (b) `git tag legacy-devbox-final origin/legacy-devbox` to preserve a permanent reference, (c) `git push origin --delete legacy-devbox` to remove the branch from active tracking, (d) the tag MUST remain pushed (`git push origin legacy-devbox-final`) so the snapshot stays reachable post-retirement. **Story 15b.1's `scripts/major-cut.sh` (epics.md:6293-6314) owns the EXECUTION** of this procedure as part of the 1.0 cut ritual; Story 2.14 owns the documented-recipe contract that 15b.1 binds against.

4. **Triage path documented.** Given anyone (Ralph subagent, operator, fork maintainer) opens an issue about a devbox regression on `main`, when they consult `docs/invariants/devbox-legacy-branch-retention.md § Triage path` (and the AGENTS.md + `packages/devbox/README.md` pointers to it), then the documented first-step is: "(1) clone the legacy-devbox branch as a canary fork — `git fetch origin legacy-devbox && git worktree add ../legacy-devbox-canary legacy-devbox`. (2) Reproduce the regression against the canary. (3) If the regression is ABSENT on legacy-devbox, the regression was introduced by an absorbed-into-`packages/devbox/` change between Story 2.1's landing (commit `5278738`) and the regression-reporting commit — `git log 5278738..HEAD -- packages/devbox/` enumerates candidate commits; bisect via `git bisect start HEAD 5278738 -- packages/devbox/` finds the introducing commit. (4) If the regression IS PRESENT on legacy-devbox, it pre-existed the absorption — escalate to upstream cc-devbox or fix in-place on `packages/devbox/`."

## Tasks / Subtasks

- [ ] **Task 1: Create + push the `legacy-devbox` git branch with retention README banner** (AC 1)
  - [ ] **Branch-creation method.** Use `git fetch <upstream> main:legacy-devbox` to bring upstream cc-devbox `main` into a local ref `legacy-devbox`, preserving upstream commit history for `git bisect` / `git blame` purposes on the canary (AC 4 triage path consumes `git bisect` on the canary). Canonical recipe (run from inside the iteration env at `/workspace/ralph-bmad/`):
    ```bash
    # 1. Fetch upstream cc-devbox main into local ref `legacy-devbox`.
    #    Egress: github.com + codeload.github.com (both in
    #    packages/devbox/whitelist/github.txt per Story 2.3 + 2.9 substrate).
    git fetch https://github.com/tthew/cc-devbox.git main:legacy-devbox
    UPSTREAM_SHA=$(git rev-parse legacy-devbox)

    # 2. Add a scratch worktree for the legacy-devbox branch — gitignored
    #    per .gitignore .claude/worktrees/* (CLAUDE.md § Worktrees). NOT
    #    Ralph's iteration worktree — Guardrail 16 retention rule does NOT
    #    apply; cleanup at end of Task 1 is intentional.
    WT=".claude/worktrees/legacy-devbox-bootstrap-2-14"
    git worktree add "$WT" legacy-devbox
    ```
  - [ ] **README retention banner.** Edit `$WT/README.md` to PREPEND a Story-2.14 retention banner at the top of the existing upstream README. Insert ABOVE the existing H1 (do NOT delete or replace upstream content; the banner is additive — fork operators consulting the canary should still see upstream's README context). Banner template:
    ```markdown
    > # ⚠ Legacy-devbox retention branch (Story 2.14)
    >
    > **This branch is a retention-only snapshot of upstream [`tthew/cc-devbox`](https://github.com/tthew/cc-devbox)** captured at upstream `main@<UPSTREAM_SHA>` for the Keel project's bootstrap-handoff mitigation per PRD Technical Risks (`_bmad-output/planning-artifacts/prd.md:617`). It carries the pre-absorption standalone cc-devbox layout (top-level `Dockerfile`, `docker-compose.yml`, etc.) — distinct from the absorbed-into-`packages/devbox/` substrate that lives on `main`.
    >
    > **Canonical substrate:** `packages/devbox/` on `main` (Stories 2.1-2.13 + 2.15-2.17). Operators should default to that — this branch is a fallback canary, not the active devbox.
    >
    > **Retention scope:** security-critical upstream patches MAY be cherry-picked to this branch via the manual workflow at `docs/invariants/devbox-legacy-branch-retention.md § Cherry-pick workflow` on `main`. Feature parity with the substrate is NOT a goal — minimal drift only.
    >
    > **Sunset:** retired by Story 15b.1's `scripts/major-cut.sh` at the 1.0 cut ritual. The branch will be tagged `legacy-devbox-final` (kept reachable post-retirement) then removed from active tracking via `git push origin --delete legacy-devbox`. The retirement decision is recorded in `RALPH.md § Decisions` post-M4 checkpoint per Story 2.14 AC 3.
    >
    > **Triage path** (when investigating a devbox regression on `main`): see `docs/invariants/devbox-legacy-branch-retention.md § Triage path` on `main` — TL;DR: clone this branch as a canary, reproduce the regression here, bisect `main` between commit `5278738` (Story 2.1 absorption) and the regression-reporting commit if absent here.

    ---

    ```
    **Placeholder resolution is mechanical, not manual.** After writing the banner to `$WT/README.md`, substitute the placeholder in-place with the captured SHA:
    ```bash
    sed -i "s|<UPSTREAM_SHA>|$UPSTREAM_SHA|g" "$WT/README.md"
    # Verify placeholder fully resolved — grep should return empty.
    grep UPSTREAM_SHA "$WT/README.md" && echo "ERROR: placeholder not resolved" >&2 && exit 1
    ```
    Rationale: a hand-edit misses the substitution and lands `<UPSTREAM_SHA>` verbatim in the banner; the `grep` guard fails-loudly if substitution was skipped.
  - [ ] **Commit + push.**
    ```bash
    cd "$WT"
    git add README.md
    git commit -m "docs(legacy-devbox): Story 2.14 retention banner over cc-devbox@${UPSTREAM_SHA:0:7}"
    # Note: this commit's pre-commit hooks may complain about the prek/eslint
    # toolchain not being installed on this branch — UPSTREAM cc-devbox does
    # not have keel's prek setup. If prek hooks fire and fail, use:
    #   PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit ...
    # The legacy branch is intentionally orphan-toolchain — quality gates
    # don't apply (substrate-canonical lives on `main`).
    #
    # **SCOPE GUARDRAIL**: hook-bypass is ONLY acceptable for legacy-devbox
    # branch commits (scratch worktree bootstrapping upstream snapshot). On
    # `main`-targeting commits this pattern is FORBIDDEN per Story 1.6's
    # `INV-no-verify-bypass`. Do NOT transfer this pattern to substrate commits.
    git push -u origin legacy-devbox
    cd -
    git worktree remove "$WT"
    ```
  - [ ] **Verification.** Confirm the branch landed at origin: `git ls-remote origin refs/heads/legacy-devbox` returns the new commit SHA. Confirm the README banner is present: `git show origin/legacy-devbox:README.md | head -20` shows the retention banner. Confirm the working main worktree is unchanged: `git status` on `feat/epic-2-packaged-devbox` shows only the Story 2.14 file additions (not the legacy worktree contents).
  - [ ] **Iteration env caveat.** If `git fetch` from `https://github.com/tthew/cc-devbox.git` is blocked by the egress filter (it should NOT be — `github.com` + `codeload.github.com` are both in `packages/devbox/whitelist/github.txt`), confirm via `dig @127.0.0.1 -p 53 +short codeload.github.com` (Story 2.13 healthcheck-tooling reuse). If genuinely blocked, document as a fix-task and DEFER Task 1 execution to the operator (operator runs the recipe on host workstation, then Ralph picks up Task 2-4 in the next iter).

- [ ] **Task 2: Author `docs/invariants/devbox-legacy-branch-retention.md`** (AC 2, AC 3, AC 4 — machine-enforced contract)
  - [ ] **File path + structure.** Create `docs/invariants/devbox-legacy-branch-retention.md`. H2 sections (matches Story 2.13's invariant-doc shape):
    - `## Intent` — one paragraph framing PRD Technical Risk mitigation (`prd.md:617`) + bootstrap-handoff bridge: standalone cc-devbox functional during M0.5 → M4 critical path so a regression in absorbed `packages/devbox/` does NOT stall Keel's own build.
    - `## Branch creation contract` — pinned recipe (mirrors Task 1 commands — `git fetch <upstream> main:legacy-devbox` + worktree-bootstrap + README banner + push); upstream-SHA capture for traceability; one-time gesture (idempotent re-execution is a no-op once `origin/legacy-devbox` exists).
    - `## Cherry-pick workflow` (AC 2 — manual, minimal-drift). Recipe:
      ```bash
      # On main, identify a security-critical commit affecting packages/devbox/.
      MAIN_SHA="<sha>"

      # Generate a patch with packages/devbox/ stripped from paths.
      git format-patch -1 "$MAIN_SHA" -- packages/devbox/ -o /tmp/legacy-patches/

      # Edit the .patch file: change `a/packages/devbox/<file>` → `a/<file>`
      # and `b/packages/devbox/<file>` → `b/<file>` (sed if mechanical;
      # manual review if structurally complex). Then apply on legacy-devbox:

      git fetch origin legacy-devbox
      git worktree add ../legacy-devbox-cherry legacy-devbox
      cd ../legacy-devbox-cherry
      sed -i 's|a/packages/devbox/|a/|g; s|b/packages/devbox/|b/|g' /tmp/legacy-patches/*.patch
      git am /tmp/legacy-patches/*.patch
      git push origin legacy-devbox
      cd -
      git worktree remove ../legacy-devbox-cherry
      ```
      Frame the cherry-pick scope explicitly: CVE-class fixes / fail-closed-egress regressions / secret-leakage / network-exposure regressions ONLY. Feature additions, cosmetic refactors, dependency bumps — DEFER to "live with the drift" or "fork upstream and resolve in 1.0 cut" decisions. The `git format-patch | sed | git am` pattern works for ~80% of patches mechanically; complex restructures require manual diff-application.
    - `## Triage path` (AC 4) — pinned recipe (mirrors AC 4 prose):
      ```bash
      # 1. Clone the legacy-devbox branch as a canary worktree.
      git fetch origin legacy-devbox
      git worktree add ../legacy-devbox-canary legacy-devbox

      # 2. Reproduce the regression in the canary.
      cd ../legacy-devbox-canary
      # ... operator-specific reproduction steps ...
      cd -

      # 3a. If regression ABSENT on canary: bisect main from Story 2.1 absorption.
      #     5278738 = Story 2.1 iter-99 absorption commit (verify via
      #     `git log --oneline -- packages/devbox/Dockerfile | tail -1`).
      git bisect start HEAD 5278738 -- packages/devbox/
      # ... operator runs git bisect good/bad ...
      git bisect reset

      # 3b. If regression PRESENT on canary: pre-existed absorption.
      #     Escalate upstream OR fix in-place on packages/devbox/ (substrate-canonical).

      # 4. Cleanup canary worktree.
      git worktree remove ../legacy-devbox-canary
      ```
    - `## Sunset criteria` — explicit gate: M4 checkpoint passes WITHOUT devbox regressions reported during the M0.5 → M4 window (mid-build period). M4 is the recurring quarterly post-1.0 falsification checkpoint per `prd.md:143`; the FIRST M4 (mid-build, ~Day 18-21 of the 28-day build path) is the canonical sunset gate. If devbox regressions surfaced and required the canary during that window, defer sunset to the SECOND M4 checkpoint (3 months later) — sunset criteria is "no devbox regressions in two consecutive M4 windows" as a fallback. Decision is recorded in `RALPH.md § Decisions` per AC 3 (a).
    - `## Retirement gate` (AC 3) — Story 15b.1 (`scripts/major-cut.sh` per epics.md:6293-6314) owns the execution. Step sequence:
      1. `git tag legacy-devbox-final origin/legacy-devbox` — permanent reference tag (history preserved post-retirement).
      2. `git push origin legacy-devbox-final` — publish the tag.
      3. `git push origin --delete legacy-devbox` — remove the active branch.
      4. RALPH.md entry: dated decision with M4-checkpoint-doc path (`docs/research/checkpoints/YYYY-Q#.md`).
      5. AGENTS.md edit: § Devbox iteration environment H3 update — flip "active retention branch" → "retired; preserved at `legacy-devbox-final` tag for archaeology only".
    - `## Fork extension contract` — forks operating their own absorbed devbox MAY (a) follow this same pattern with their own upstream + retention naming (recommended: same `legacy-<upstream-name>` slug convention so the triage path narrative carries), OR (b) skip retention entirely if their fork lacks the bootstrap-handoff risk (e.g., a fork that started post-1.0 with substrate-canonical devbox from day one). Substrate forbids: removing the substrate-side documentation, weakening the "no-feature-parity" framing, or automating cherry-picks (FR44 AMEND would be required).
  - [ ] **Compute `contentHash`.** `sha256sum docs/invariants/devbox-legacy-branch-retention.md | awk '{print $1}'`. Paste the 64-char lowercase hex into the manifest entry (Task 3).
  - [ ] **Length target.** ~150-250 lines — on par with `docs/invariants/devbox-mode.md` (~237 lines; multi-section recipe-heavy invariant) and denser than `docs/invariants/devbox-healthcheck.md` (~100 lines; single-probe contract). The four-recipe shape (creation / cherry-pick / triage / retirement) is the structural backbone; individual recipes dominate line count.

- [ ] **Task 3: Register `INV-devbox-legacy-branch-retention` + INVARIANTS.md anchor** (AC 1-4 machine-enforced contract)
  - [ ] **Manifest entry.** Add new entry to `packages/keel-invariants/src/invariants.manifest.ts` AFTER the existing `INV-devbox-healthcheck` entry (Story 2.13) — Devbox block is contiguous per Story 2.12 iter-268 LESSON; numerical Story-order is the convention within the block:
    - `id: 'INV-devbox-legacy-branch-retention'`
    - `description: 'Legacy-devbox branch carries pre-absorption cc-devbox layout for bootstrap-handoff mitigation; retained until M4 checkpoint passes without regressions; cherry-pick + triage + retirement workflows pinned (Story 2.14).'`
    - `sourcePath: 'docs/invariants/devbox-legacy-branch-retention.md'`
    - `contentHash: '<sha256 from Task 2>'`
    - `anchors: ['INV-devbox-legacy-branch-retention']`
  - [ ] **InvariantSchema five-field compliance** (Story 2.3 iter-156 LESSON; reaffirmed at Story 2.12 + Story 2.13). Cross-check the sibling `INV-devbox-healthcheck` entry shape — `{id, description, sourcePath, contentHash, anchors}` — no `name` field, bare anchor strings, bare 64-char lowercase hex contentHash.
  - [ ] **INVARIANTS.md H3 + anchor bullet.** Append a NEW H3 `### Devbox legacy-branch retention (Story 2.14)` AFTER the existing `### Devbox healthcheck (Story 2.13)` H3 (`INVARIANTS.md:126-130`) and BEFORE the existing `### Gitignored-secret commit-deny (Story 2.2)` H3 (`INVARIANTS.md:132`). Per Story 2.12 iter-268 LESSON: Devbox block is contiguous; the Story-2.2 H3 lives AFTER all devbox H3s because section order is not strictly numerical (Story-2.2 was authored before the devbox block was structured). Anchor bullet (verbatim regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` per `packages/keel-invariants/src/sync-gate.ts:24` Story 1.9 sync-gate; lowercase-after-`INV-` prefix MANDATORY per Story 1.9 iter-7 LESSON):
    ```
    - **`INV-devbox-legacy-branch-retention`** — Legacy-devbox branch retains pre-absorption cc-devbox layout for bootstrap-handoff mitigation; cherry-pick + triage + retirement workflows pinned. Source: `docs/invariants/devbox-legacy-branch-retention.md`.
    ```
  - [ ] **Sync-gate verification.** `pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check && pnpm keel-invariants:check-all` MUST be GREEN post-landing. Manifest entry count 33 → 34. **Iter-257 LESSON reaffirmed at iter-283 + iter-285:** the `pnpm --filter @keel/keel-invariants build` is load-bearing — sync-gate consumes the compiled `dist/check.js`; stale dist shows `removed-from-docs-only INV-devbox-legacy-branch-retention` false drift.

- [ ] **Task 4: Operator + agent documentation pointers** (AC 1, AC 4 visibility)
  - [ ] **`packages/devbox/README.md`** — append a NEW H2 `## Legacy-devbox branch retention (Story 2.14)` AFTER the existing `## Healthcheck (Story 2.13)` H2 and BEFORE the existing `## cc-devbox upstream provenance` H2 (SC-17 sibling-append discipline; do NOT edit prior story sections). Brief content (this is meta-substrate — the bulk lives in the invariant doc):
    - (a) One paragraph: "An `origin/legacy-devbox` branch carries the pre-absorption standalone [`cc-devbox`](https://github.com/tthew/cc-devbox) layout as a fallback canary during the M0.5 → M4 critical path. If you encounter a devbox regression on `main`, see § Triage path below + the canonical recipe at `docs/invariants/devbox-legacy-branch-retention.md` on this branch."
    - (b) Triage TL;DR (one bash block from invariant doc § Triage path; AC 4):
      ```bash
      git fetch origin legacy-devbox
      git worktree add ../legacy-devbox-canary legacy-devbox
      # Reproduce the regression in ../legacy-devbox-canary.
      # If absent: git bisect HEAD 5278738 -- packages/devbox/
      # If present: pre-existed absorption — escalate upstream.
      git worktree remove ../legacy-devbox-canary
      ```
    - (c) Sunset pointer: "Branch is retired by Story 15b.1's `scripts/major-cut.sh` at the 1.0 cut ritual; tagged `legacy-devbox-final` for archaeology. Full retirement gate at `docs/invariants/devbox-legacy-branch-retention.md § Retirement gate`."
    - (d) `INV-devbox-legacy-branch-retention` citation for the machine-enforced contract.
  - [ ] **DO NOT modify existing `## Host-side CLI (Story 2.6)` through `## Healthcheck (Story 2.13)` H2 sections** — append NEW sibling H2 only (SC-17).
  - [ ] **`AGENTS.md`** — append a NEW H3 `### Legacy-devbox branch retention (Story 2.14)` AFTER the existing `### Healthcheck (Story 2.13)` H3 within § Devbox iteration environment. Brief content:
    - (a) One-line what: "An `origin/legacy-devbox` branch retains the pre-absorption standalone cc-devbox layout for bootstrap-handoff mitigation per PRD Technical Risks (`prd.md:617`); retired by Story 15b.1 at the 1.0 cut ritual."
    - (b) One-line why agents care: "When investigating a devbox regression on `main`, the canary-then-bisect triage path at `docs/invariants/devbox-legacy-branch-retention.md § Triage path` is the documented first-step. Agents MUST consult that doc before opening a fix task on `packages/devbox/` — the canary may show the regression pre-existed absorption (escalate upstream) or post-dates absorption (bisect on `main`)."
    - (c) Cherry-pick pointer: "Security-critical upstream patches are cherry-picked manually via the workflow at `docs/invariants/devbox-legacy-branch-retention.md § Cherry-pick workflow`; agents SHOULD NOT attempt automated cherry-picks (FR44 AMEND would be required)."
    - (d) `INV-devbox-legacy-branch-retention` citation for the machine-enforced contract.
    - (e) Cross-references: § Devbox iteration environment intro for the Docker-in-Docker substrate the canary inherits; § Healthcheck (Story 2.13) for the dnsmasq probe the canary's own healthcheck would mirror (legacy-devbox inherits UPSTREAM's healthcheck as-fetched — at time of Story 2.14 drafting upstream ships the broken `curl :3000` healthcheck, but dev agent MUST grep `$WT/docker-compose.yml` at Task 1 execution to record the actual state in Completion Notes; whatever the upstream state is, it's a known-divergence NOT a cherry-pick candidate per § Cherry-pick workflow scope).
  - [ ] **DO NOT modify existing `### Host-side CLI (Story 2.6)` through `### Healthcheck (Story 2.13)` H3 sections** — append NEW sibling H3 only (SC-17).
  - [ ] **`.envrc.example` comment touch (SC-15 — only if applicable):** no new `KEEL_DEVBOX_*` knob introduced by Story 2.14 (retention is git-branch-level, not container-runtime-level). SKIP `.envrc.example` edit.
  - [ ] **`RALPH.md § Decisions` (optional pre-record).** Story 2.14 may PRE-RECORD an entry in `RALPH.md § Decisions` framing the eventual M4-passes-clean retirement-decision (form: "DECISION-PENDING (M4 checkpoint clean): retire legacy-devbox per Story 15b.1; tag `legacy-devbox-final`; record M4 checkpoint reference inline."). This is a DEFERrable subtask — the actual decision belongs to Tthew at M4 close. If the dev agent judges the placeholder helpful as a forcing-function, land it; if not, defer to Story 15b.1 execution. Iter-285 LESSON: same-commit citation drift — if RALPH.md is touched, audit `RALPH.md` cross-references to Story 2.14 in this same commit.

## Dev Notes

- **Why this is a policy + branch-creation story (not a substrate-code story).** Story 2.14 introduces NO runtime substrate code on `main` — the substrate impact is one new invariant doc + one new branch + AGENTS.md/README.md pointers + one INVARIANTS.md anchor + one manifest entry. The "running code" is the GIT BRANCH itself, hosted at `origin/legacy-devbox`, which Ralph creates one-time and Story 15b.1 retires. This pattern is novel for Epic 2 (Stories 2.1-2.13 all touched runtime code under `packages/devbox/`); the closest precedent is Story 1.16 fork-extension (config-pattern story, also documentation-heavy with one template scaffold). Dev agent should NOT expect to edit any file under `packages/devbox/` for Story 2.14 — only `docs/invariants/`, `INVARIANTS.md`, `AGENTS.md`, the manifest, the README pointer, and the legacy-devbox branch itself.

- **Branch-creation method choice — `git fetch <upstream>` not orphan-snapshot.** Two viable methods existed: (a) `git fetch https://github.com/tthew/cc-devbox.git main:legacy-devbox` brings ~3500 upstream commits into local pack-files (preserves history; supports `git bisect` on the canary per AC 4 triage path); (b) orphan branch with single-snapshot commit (`git checkout --orphan legacy-devbox` + `git rm -rf .` + copy upstream files + commit) — minimal pack-file impact but loses upstream commit lineage. **Decision: method (a).** Pack-file bloat is a one-time cost (~30MB extra) for the lifetime of the branch (ends at Story 15b.1 retirement); the upstream commit history is load-bearing for AC 4's `git bisect` posture on the canary AND for any future archaeology against `legacy-devbox-final` tag post-retirement. Pack-file impact is acceptable per dev-substrate philosophy.

- **Egress whitelist already covers the upstream fetch.** `https://github.com/tthew/cc-devbox.git` clone hits `github.com` (HTTPS index) + `codeload.github.com` (pack stream); both entries are in `packages/devbox/whitelist/github.txt` per Story 2.3 default-whitelist substrate (Story 2.9 reaffirmed: "Egress whitelist covers all 7 entries in github.txt — `api.github.com`, `github.com`, `raw.githubusercontent.com`, `objects.githubusercontent.com`, `codeload.github.com`, `ghcr.io`, `pkg-containers.githubusercontent.com`"). No whitelist amendment required for Story 2.14.

- **Worktree usage in Task 1 is scratch, NOT Ralph's iteration worktree.** Guardrail 16 ("when running in a worktree-based iteration, NEVER remove or clean up the worktree on exit") applies to Ralph's own iteration worktree (the `.claude/worktrees/<iter-name>/` if Ralph was invoked with `--worktree X`). Task 1's `.claude/worktrees/legacy-devbox-bootstrap-2-14` is a SCRATCH worktree created INSIDE the iteration for the one-time branch-bootstrap purpose; cleanup at end of Task 1 (`git worktree remove "$WT"`) is intentional and correct. The path is gitignored per `.gitignore .claude/worktrees/*` per CLAUDE.md § Worktrees, so no commit-pollution risk.

- **Pre-commit hooks on the legacy-devbox branch — INTENTIONALLY orphan.** When Task 1's `git commit` fires inside the scratch worktree, prek hooks may attempt to install or invoke against the upstream cc-devbox layout (no `package.json`, no `prek` config, no ESLint at the upstream root). Two outcomes are acceptable: (a) prek hooks silently no-op because no config is present (most likely — prek's `language: system` hooks just don't fire if their target files don't match); (b) hooks complain and the commit needs `PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit` or `git commit -n` (verify FIRST that the hook is genuinely orphan-toolchain — substrate-canonical commits NEVER skip hooks per Story 1.6's `INV-no-verify-bypass`). The legacy-devbox branch is OUTSIDE substrate-canonical scope (it's a third-party upstream snapshot retained for fallback); FR44 AMEND would be required to bring quality gates to it (out of scope at 1.0). If prek hook bypass is needed for Task 1's commit, document it explicitly in the dev-story Completion Notes — DO NOT establish precedent for hook-bypass on `main`-targeting commits. Iter-281 PATCH-6 reasoning carries: hook gates exist for substrate code; legacy snapshot is not substrate code.

- **Cherry-pick workflow scope discipline (AC 2).** The "minimal-drift, security-critical-only" framing is load-bearing — without it, the legacy-devbox branch becomes a parallel maintenance burden that contradicts the retention-only intent. Document the scope explicitly in § Cherry-pick workflow: CVE-class, fail-closed-egress regressions, secret-leakage. NOT in scope: feature additions (e.g. backporting Story 2.13's healthcheck to the legacy branch), cosmetic refactors, dependency bumps (let upstream cc-devbox handle those — that's why we retained the upstream lineage). This framing also defends against scope-creep pressure from operators who might want feature-parity for "convenience".

- **Triage path narrative (AC 4) is the load-bearing UX.** The canary-then-bisect pattern is the documented first-step for ANYONE (Ralph subagent, operator, fork maintainer) who reports a devbox regression on `main`. Without it, regression-reporters waste cycles fault-isolating in `packages/devbox/` when the actual cause might be (a) a pre-existing upstream cc-devbox bug carried over by Story 2.1 absorption, OR (b) a clean introduction post-absorption. The canary discriminates these two cases in one `git bisect` cycle. DEV AGENT NOTE: ensure the triage recipe is COPY-READY in three sites — invariant doc § Triage path (full recipe), README § Triage TL;DR (compressed), AGENTS.md § Legacy-devbox H3 (one-line pointer + AC-4 cite).

- **Sunset criteria are fuzzy on purpose.** PRD says "after the M4 checkpoint" without naming a specific date. M4 is the recurring quarterly post-1.0 falsification checkpoint per `prd.md:143`; the FIRST M4 (the mid-build checkpoint, ~Day 18-21 of the 28-day path) is the natural sunset gate IF clean. If devbox regressions surface during M0.5 → M4 and require the canary, defer sunset to the SECOND M4 (3 months later); decision criteria is "no devbox regressions in two consecutive M4 windows" as the fallback. The story DOES NOT pin a specific sunset date — that's Tthew's decision at M4 close, recorded in RALPH.md per AC 3 (a). Dev agent should NOT pre-pin a date in any of the deliverables.

- **Story 15b.1 binds against this contract — read both stories together.** Story 15b.1 (`scripts/major-cut.sh`; epics.md:6293-6314) executes the retirement at the 1.0 cut ritual: it tags `legacy-devbox-final` and removes the active branch. Story 2.14 spec'd the procedure; Story 15b.1 implements the execution. The two stories' contracts MUST be consistent — if a future iter modifies the retirement procedure (e.g. tag-name changes, additional cleanup steps), BOTH `docs/invariants/devbox-legacy-branch-retention.md § Retirement gate` AND Story 15b.1's `scripts/major-cut.sh` AC must update in lockstep. Cross-reference the two stories explicitly in Task 2's invariant doc and (when Story 15b.1 lands) in Story 15b.1's source-of-truth references.

- **Forecast band (iter-286 NOVEL LESSON #1).** Story 2.14 is narrow-diff documentation-heavy — closest precedents are Story 1.16 (fork-extension config-pattern) and Story 2.13 (healthcheck doc + invariant + brief substrate touch). Cumulative PATCH band per iter-286 NOVEL LESSON for narrow-diff moderate-novelty: ~6-10 across full lifecycle (drafted → done). At pre-dev SM forecast: 3-6 PATCH likely. At trace: WAIVED-likely (no test runner; ground-(c) precedent extends to documentation-heavy stories). At post-dev SM: 0-2 PATCH per iter-270 LESSON ("pre-dev SM absorbs novel surface → post-dev gates clean-advance dominant"). At CR: 0-2 first-class PATCH per iter-279 + iter-286 ZERO-PATCH precedent for narrow-diff stories.

- **Previous-story intelligence — Story 2.13 carry-forward (most relevant).** Iter-281 NOVEL LESSON: documentation-heavy stories' pre-dev SM band is wider than runtime-code-heavy at same novelty (Story 2.13 saw 6 PATCH at pre-dev SM vs novel-runtime 2.12's 8). For Story 2.14 (similar shape), forecast 3-6 PATCH at pre-dev SM. Iter-285 NOVEL LESSON: same-commit citation-drift from DEFER absorption — Story 2.14 doesn't currently absorb DEFERs (Tasks 1-4 are AC-driven), but if the dev agent adds an optional Task 5 absorbing one of the cumulative 30 DEFERs from the SC-17 queue, watch for citation-drift from any line-number-shifting edit. Iter-286 NOVEL LESSON #3 (adversarial convergence on spec-endorsed claim → DEFER-verify-later): for any claim in this story file that's spec-endorsed without empirical validation (e.g. "git fetch from upstream cc-devbox succeeds under default whitelist"), pre-validate at impl time inside the iteration env to catch surprises early.

- **ATDD decision forecast** (per § Story Lifecycle row `validated → atdd-scaffolded`). Story 2.14 will likely TAKE the `/bmad-testarch-atdd` SKIP-WITH-GROUNDS route per Story 2.12/2.13 precedent: (c) no test runner wired at substrate stage; (ii) git-branch state + remote-ref state are inspectable via `git ls-remote` + `git show <branch>:<file>` static smokes — no dynamic-runtime semantics to ATDD against; (iii) substrate verification via sha256 contentHash sync-gate + INVARIANTS.md anchor parse + manifest entry-count post-rebuild covers AC 1 (branch existence verifiable via `git ls-remote`) + AC 2-4 (doc content satisfies via grep + structural assertion). Twenty-fourth+ cumulative ATDD-skip precedent expected.

### Project Structure Notes

- **Files to create on `main`** (this branch — `feat/epic-2-packaged-devbox`):
  - `docs/invariants/devbox-legacy-branch-retention.md` — new invariant doc (contentHash-tracked).
- **Files to edit on `main`:**
  - `packages/keel-invariants/src/invariants.manifest.ts` — add `INV-devbox-legacy-branch-retention` entry after `INV-devbox-healthcheck` (manifest count 33 → 34).
  - `INVARIANTS.md` — new H3 `### Devbox legacy-branch retention (Story 2.14)` + anchor bullet between `### Devbox healthcheck (Story 2.13)` (`:126-130`) and `### Gitignored-secret commit-deny (Story 2.2)` (`:132`).
  - `packages/devbox/README.md` — new H2 `## Legacy-devbox branch retention (Story 2.14)` AFTER `## Healthcheck (Story 2.13)` (currently `:909`) and BEFORE `## cc-devbox upstream provenance` (currently `:985`; EOF `:1001`). Use H2 names as the structural anchor; line numbers are drift-prone and indicative only.
  - `AGENTS.md` — new H3 `### Legacy-devbox branch retention (Story 2.14)` under § Devbox iteration environment, AFTER `### Healthcheck (Story 2.13)`.
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` — `2-14-…: ready-for-dev → in-progress → review` lifecycle ledger.
- **Files to create on `legacy-devbox` branch** (separate worktree, separate push):
  - `README.md` — PREPENDED retention banner (additive — does NOT delete upstream README content).
- **Files NOT to edit on `main`:**
  - `packages/devbox/Dockerfile` / `docker-compose.yml` / `entrypoint.sh` / `scripts/*.sh` / `whitelist*` / `sshd/sshd_config` (substrate runtime is unchanged by Story 2.14 — retention is git-branch-level, not container-runtime-level).
  - `.envrc` / `.envrc.example` (no new `KEEL_DEVBOX_*` knob).
  - `_bmad/_config/manifest.yaml` (no module change).
  - Prior story sections in `packages/devbox/README.md` and `AGENTS.md` (SC-17 sibling-append discipline).
- **Manifest entry count change.** 33 → 34 at Story 2.14 landing. Confirm `pnpm keel-invariants:check` GREEN post-landing.
- **Optional touch:** `RALPH.md § Decisions` pre-record placeholder (Task 4 final subtask) — DEFERrable to Story 15b.1.

### References

- [Source: `_bmad-output/planning-artifacts/epics.md:1602-1627`] — Story 2.14 full AC block (Epic 2 Story 2.14; epic at `:1142-1170`).
- [Source: `_bmad-output/planning-artifacts/prd.md:617`] — § Technical Risks: "Bootstrap handoff at M0.5 — the cc-devbox → packages/devbox/ migration lands mid-build. If the absorbed devbox fails, Keel's own build stalls. Mitigation: keep standalone cc-devbox functional on a legacy-devbox branch until after the M4 checkpoint."
- [Source: `_bmad-output/planning-artifacts/prd.md:676`] — § Migration Sequence: "M0.5 landing: packages/devbox/ takes over; standalone cc-devbox becomes deprecated-but-still-functional on a legacy-devbox branch until after the M4 checkpoint."
- [Source: `_bmad-output/planning-artifacts/prd.md:668`] — § 1.0 cut ritual: "Retire cc-devbox; the absorbed packages/devbox/ is canonical."
- [Source: `_bmad-output/planning-artifacts/prd.md:143`] — § M4 checkpoint ritual: "explicit decision at end of critical path… Promoted from one-time M4 ritual to recurring quarterly falsification checkpoint post-1.0."
- [Source: `_bmad-output/planning-artifacts/prd.md:997`] — FR33: "Developer can record M4 checkpoint decisions as committed markdown artefacts in the repo." (Path convention `docs/research/checkpoints/YYYY-Q#.{md,json}` is established by architecture.md:361 — FR33 itself specifies the capability, not the path.)
- [Source: `_bmad-output/planning-artifacts/architecture.md:131-134`] — § Source-tree absorption: `git clone https://github.com/tthew/cc-devbox packages/devbox` (the absorption recipe Story 2.1 executed).
- [Source: `_bmad-output/planning-artifacts/architecture.md:361`] — § Quarterly M4 checkpoint entries `docs/research/checkpoints/YYYY-Q#.{md,json}` (RALPH.md decision-citation target per AC 3 (a)).
- [Source: `_bmad-output/planning-artifacts/epics.md:6268-6314`] — Story 15b.1 `scripts/major-cut.sh` retirement ritual (epics.md `:6293` Story 15b.1 statement; `:6312-6314` AC for `legacy-devbox` retirement step).
- [Source: `_bmad-output/planning-artifacts/epics.md:6446`] — § Epic-to-Milestone Mapping M0.5: "Epic 2 (incl. uv tool install --from packages/ralph ralph-harness==<pin> install-boundary snapshot per RS2)… Epic 3 (packages/ralph/ package scaffold, legacy-devbox branch retention), Epic 15a (create-keel-app scaffolded against devbox)." Note the milestone-mapping line ATTRIBUTES legacy-devbox retention to Epic 3, but the Story-level allocation in Epic 2 (Story 2.14) is the operative truth — Epic 3 lists "packages/ralph/" scope, not legacy-devbox; the milestone-table prose is historical drift.
- [Source: `_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md`] — Story 2.1 absorbed cc-devbox into `packages/devbox/`; commit `5278738` ("feat(devbox): Story 2.1 iter-99 /bmad-dev-story source-level (atdd-scaffolded → in-dev partial)") per `git log --diff-filter=A -- packages/devbox/` is the absorption-landing commit (AC 4 triage-bisect anchor).
- [Source: `_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md`] — Story 2.13 invariant-doc shape + manifest-registration pattern (Story 2.14's Task 2 + Task 3 mirror this template).
- [Source: `INVARIANTS.md:120-130`] — Story 2.12 + Story 2.13 H3s + anchor bullets (insertion-point predecessors for Story 2.14 H3).
- [Source: `INVARIANTS.md:132-136`] — Story 2.2 H3 (insertion-point successor; Devbox-block-then-Story-2.2 ordering per iter-268 LESSON).
- [Source: `packages/keel-invariants/src/invariants.manifest.ts`] — `InvariantSchema` five-field contract; sibling Story 2.13 entry as canonical shape reference for Story 2.14 entry.
- [Source: `packages/keel-invariants/src/sync-gate.ts:24`] — anchor regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` (lowercase-after-`INV-` mandatory; Story 1.9 iter-7 LESSON).
- [Source: `packages/devbox/whitelist/github.txt`] — egress whitelist already covers `github.com` + `codeload.github.com` (Task 1 `git fetch` from upstream is whitelist-clean).
- [Source: `packages/devbox/README.md`] — current EOF at line 1001; `## Healthcheck (Story 2.13)` at `:909` is current last H2 before `## cc-devbox upstream provenance` at `:985` (insertion-point predecessor for Story 2.14 § Legacy-devbox branch retention H2 — structural H2-name anchoring preferred over line numbers).
- [Source: `AGENTS.md`] — § Devbox iteration environment current last H3 is `### Healthcheck (Story 2.13)` (insertion-point predecessor for Story 2.14 H3).
- [Source: `CLAUDE.md § Worktrees`] — `.claude/worktrees/` is gitignored; scratch worktrees for one-time operations are appropriate; Guardrail 16 retention rule applies to Ralph's iteration worktree only.
- [Source: upstream `https://github.com/tthew/cc-devbox`] — canonical pre-absorption layout source; Task 1 fetches `main` directly into local ref `legacy-devbox`.

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List
