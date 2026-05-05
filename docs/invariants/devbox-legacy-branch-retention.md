# devbox-legacy-branch-retention — Legacy-devbox branch retention policy + cherry-pick / triage / retirement workflows

**Invariant ID:** `INV-devbox-legacy-branch-retention`
**Source of truth:** `origin/legacy-devbox` branch (pre-absorption cc-devbox layout) + this document (policy + workflows).
**Story:** 2.14 (Epic 2 — Sandboxed Execution Environment)
**Companion docs:** `docs/invariants/devbox-dind.md` (fork-time Docker substrate the canary inherits), `docs/invariants/devbox-egress.md` (fail-closed egress the canary inherits), `docs/invariants/devbox-hardening.md` + `docs/invariants/devbox-ssh.md` + `docs/invariants/devbox-healthcheck.md` (substrate contracts the canary DOES NOT inherit — upstream cc-devbox pre-dates all of them).

## Intent

The `legacy-devbox` branch retains the pre-absorption standalone [`cc-devbox`](https://github.com/tthew/cc-devbox) layout as a fallback canary during the M0.5 → M4 critical-path window. PRD § Technical Risks (`prd.md:617`) names the bootstrap-handoff risk explicitly: the `cc-devbox → packages/devbox/` absorption lands mid-build; if the absorbed substrate regresses, Keel's own build stalls. Retention mitigates that risk by keeping a working reference devbox reachable via `origin/legacy-devbox` until the M4 checkpoint passes without devbox regressions — at which point Story 15b.1's `scripts/major-cut.sh` (`epics.md:6293-6314`) retires the branch at the 1.0 cut ritual.

Retention is NOT a feature-parity commitment. The branch tracks upstream cc-devbox at the SHA captured at Story 2.14 landing; security-critical upstream patches MAY be manually cherry-picked per § Cherry-pick workflow, but the canonical devbox lives at `packages/devbox/` on `main`. Operators default to the substrate; the legacy branch is the fallback.

## Branch creation contract

One-time gesture executed by Story 2.14 Task 1. The branch is created by FETCHING upstream cc-devbox `main` directly into a local ref named `legacy-devbox` — preserving upstream commit history for `git bisect` / `git blame` posture on the canary (§ Triage path depends on bisect lineage).

Canonical recipe (run from the substrate repo root):

```bash
# 1. Fetch upstream cc-devbox main into local ref `legacy-devbox`.
#    Egress: github.com + codeload.github.com — both in
#    packages/devbox/whitelist/github.txt per Story 2.3 + Story 2.9
#    default-whitelist substrate.
git fetch https://github.com/tthew/cc-devbox.git main:legacy-devbox
UPSTREAM_SHA=$(git rev-parse legacy-devbox)

# 2. Scratch worktree for the retention banner edit (gitignored per
#    .gitignore .claude/worktrees/*). NOT Ralph's iteration worktree;
#    cleanup at end of bootstrap is intentional.
WT=".claude/worktrees/legacy-devbox-bootstrap-2-14"
git worktree add "$WT" legacy-devbox

# 3. Prepend Story 2.14 retention banner to $WT/README.md. Banner is
#    additive — upstream README content remains visible below the banner.
#    Resolve <UPSTREAM_SHA> placeholder mechanically:
sed -i "s|<UPSTREAM_SHA>|$UPSTREAM_SHA|g" "$WT/README.md"
grep UPSTREAM_SHA "$WT/README.md" && echo "ERROR: placeholder not resolved" >&2 && exit 1

# 4. Commit + push. Legacy-devbox is orphan-toolchain — upstream cc-devbox
#    does not carry keel's prek/eslint config. If the commit's pre-commit
#    hooks complain, PRE_COMMIT_ALLOW_NO_CONFIG=1 is acceptable HERE ONLY.
#    SCOPE GUARDRAIL: hook-bypass is forbidden on main-targeting commits
#    per Story 1.6's `INV-no-verify-bypass`. Do NOT transfer this pattern.
cd "$WT"
git add README.md
git commit -m "docs(legacy-devbox): Story 2.14 retention banner over cc-devbox@${UPSTREAM_SHA:0:7}"
git push -u origin legacy-devbox
cd -
git worktree remove "$WT"
```

**Idempotence.** Re-running this recipe once `origin/legacy-devbox` already exists is a no-op for the branch creation (step 1 fast-forwards to the same SHA; steps 2-4 short-circuit because the banner is already present). Replacing or force-pushing `origin/legacy-devbox` requires an AMEND PR against this document with an explicit rationale — the branch is substrate-canonical at the SHA captured at Story 2.14 landing, and drift against that SHA degrades the triage path's `git bisect` anchor.

**Egress whitelist coverage.** `git fetch https://github.com/tthew/cc-devbox.git` hits `github.com` (HTTPS index) + `codeload.github.com` (pack stream). Both domains are in `packages/devbox/whitelist/github.txt` per Story 2.3 + Story 2.9 substrate. No whitelist amendment required.

## Cherry-pick workflow

Manual, minimal-drift, security-critical ONLY. The paths on `main` (`packages/devbox/<file>`) differ from the paths on `legacy-devbox` (`<file>` at branch root) — `git cherry-pick` fails against that path difference, so the canonical workflow uses `git format-patch | sed | git am`:

```bash
# 1. On main, identify a security-critical commit affecting packages/devbox/.
MAIN_SHA="<sha>"

# 2. Generate a patch with packages/devbox/ stripped from path prefixes.
git format-patch -1 "$MAIN_SHA" -- packages/devbox/ -o /tmp/legacy-patches/

# 3. Rewrite paths: `a/packages/devbox/<file>` → `a/<file>` and
#    `b/packages/devbox/<file>` → `b/<file>`. The sed pair below handles
#    ~80% of patches mechanically; structurally complex patches (renames,
#    mode changes, binary files) require manual review before `git am`.
sed -i 's|a/packages/devbox/|a/|g; s|b/packages/devbox/|b/|g' /tmp/legacy-patches/*.patch

# 4. Apply on legacy-devbox via a scratch worktree.
git fetch origin legacy-devbox
git worktree add ../legacy-devbox-cherry legacy-devbox
cd ../legacy-devbox-cherry
git am /tmp/legacy-patches/*.patch
git push origin legacy-devbox
cd -
git worktree remove ../legacy-devbox-cherry
```

**Scope discipline — load-bearing.** The cherry-pick scope is narrow by design:

- **IN SCOPE:** CVE-class fixes affecting the devbox substrate. Fail-closed-egress regressions (nftables / dnsmasq / resolv.conf contracts). Secret-leakage regressions (token exposure via bind-mount or log). Network-exposure regressions (port publication to `0.0.0.0` / bare-port bindings).
- **OUT OF SCOPE:** Feature additions (e.g. backporting Story 2.13's healthcheck — upstream cc-devbox never had a working healthcheck; the legacy branch documenting that state is intentional, not a cherry-pick candidate). Cosmetic refactors. Dependency bumps (upstream cc-devbox's own Renovate / apt sources handle those; the retention branch follows upstream, not `main`). README / docs edits (substrate documentation lives on `main`).

The "minimal-drift, not feature parity" framing defends against scope-creep pressure — without it, the legacy branch accretes parallel-maintenance burden that contradicts the retention-only intent. Operators wanting feature-parity are consuming the wrong branch; they should use `packages/devbox/` on `main`.

**Documented-but-not-automated by design.** FR44 AMEND against this document would be required to script the cherry-pick workflow (for example, a `pnpm devbox:legacy-cherry-pick` verb). At 1.0 the workflow is manual operator-invoked; automation is out of scope.

## Triage path

Canary-then-bisect pattern. Executed by anyone (Ralph subagent, operator, fork maintainer) investigating a devbox regression reported against `packages/devbox/` on `main`:

```bash
# 1. Clone the legacy-devbox branch as a canary worktree.
git fetch origin legacy-devbox
git worktree add ../legacy-devbox-canary legacy-devbox

# 2. Reproduce the regression in the canary.
cd ../legacy-devbox-canary
# ... operator-specific reproduction steps using the upstream cc-devbox layout ...
cd -

# 3a. If the regression is ABSENT on the canary: it was introduced between
#     Story 2.1 absorption (commit 5278738) and the regression-reporting
#     commit. Enumerate candidate commits affecting packages/devbox/ only:
git log 5278738..HEAD -- packages/devbox/
# Bisect to find the introducing commit:
git bisect start HEAD 5278738 -- packages/devbox/
# ... operator runs git bisect good / git bisect bad per reproduction ...
git bisect reset

# 3b. If the regression is PRESENT on the canary: it pre-existed the
#     absorption. Escalate to upstream cc-devbox, OR fix in-place on
#     packages/devbox/ (substrate-canonical — the canary is the reporter,
#     not the target of the fix). Note: "fix in-place" means editing
#     packages/devbox/ on main, NOT cherry-picking a fix back to the
#     legacy-devbox branch (that belongs to § Cherry-pick workflow scope
#     only when the fix is CVE-class).

# 4. Cleanup canary worktree.
git worktree remove ../legacy-devbox-canary
```

**Why bisect from `5278738`.** Commit `5278738` is Story 2.1's `packages/devbox/` landing commit ("feat(devbox): Story 2.1 iter-99 /bmad-dev-story source-level (atdd-scaffolded → in-dev partial)" — verify via `git log --oneline --diff-filter=A -- packages/devbox/Dockerfile | tail -1`). Any `packages/devbox/` regression introduced post-absorption lives between that commit and `HEAD`; bisecting with the `-- packages/devbox/` path-filter narrows the search space to commits that actually touched the substrate.

**Triage-path narrative is load-bearing.** Without it, regression-reporters waste cycles fault-isolating in `packages/devbox/` when the actual cause might be a pre-existing upstream cc-devbox bug carried over by Story 2.1 absorption. The canary discriminates the pre-existing-vs-post-absorption case in one reproduction cycle.

## Sunset criteria

The M4 checkpoint is the recurring quarterly post-1.0 falsification ritual per `prd.md:143`. The FIRST M4 (mid-build, ~Day 18-21 of the 28-day critical path) is the canonical sunset gate: if NO devbox regressions surfaced during the M0.5 → M4 window AND no cherry-picks landed on the legacy branch during that window, retire the branch per § Retirement gate.

**Fallback criteria** if the first M4 closes with one or more devbox regressions reported or cherry-picks landed: defer sunset to the SECOND M4 checkpoint (3 months later). The sunset rule is then "no devbox regressions in two consecutive M4 windows." This fallback is not automated; Tthew records the decision in `RALPH.md § Decisions` at each M4 close.

Sunset criteria are deliberately NOT date-pinned. The story does not commit to a specific sunset date; the decision belongs to Tthew at M4 close, recorded in `RALPH.md` per § Retirement gate step 4 and AC 3 (a).

## Retirement gate

Story 15b.1's `scripts/major-cut.sh` (`epics.md:6293-6314`) owns the EXECUTION of this procedure as part of the 1.0 cut ritual. Story 2.14 owns the recipe-contract that 15b.1 binds against.

Step sequence (executed by Story 15b.1; NOT by operators ad-hoc):

1. **Tag the snapshot:** `git tag legacy-devbox-final origin/legacy-devbox` — permanent reference preserved post-retirement.
2. **Publish the tag:** `git push origin legacy-devbox-final` — archaeology remains reachable.
3. **Delete the active branch:** `git push origin --delete legacy-devbox` — removes the active-tracking target; operators who accidentally run `git fetch origin legacy-devbox` post-retirement get a clean miss.
4. **Record the decision:** `RALPH.md § Decisions` entry dated, referencing the M4 checkpoint doc path (`docs/research/checkpoints/YYYY-Q#.{md,json}` per FR33 + `architecture.md:361`).
5. **Flip the AGENTS.md pointer:** § Devbox iteration environment H3 `### Legacy-devbox branch retention (Story 2.14)` updates from "active retention branch" phrasing to "retired; preserved at `legacy-devbox-final` tag for archaeology only." This is a same-commit edit with the retirement action.

**Lockstep contract.** If a future iter modifies the retirement procedure (e.g. tag-name changes, additional cleanup steps, alternative retention horizons), BOTH this document's § Retirement gate AND Story 15b.1's `scripts/major-cut.sh` acceptance criteria MUST update in the same PR. Drift between the two is an INV-devbox-legacy-branch-retention violation.

## Fork extension contract

Forks operating their own absorbed devbox MAY:

- **(a)** Follow this same pattern with their own upstream + retention naming. Recommended: preserve the `legacy-<upstream-name>` slug convention (e.g. a fork absorbing `tthew/cc-devbox` via its own upstream would name the branch `legacy-cc-devbox-<fork>` or retain `legacy-devbox` if the fork inherits keel's naming). The canary-then-bisect triage path narrative is branch-name-agnostic and carries cleanly.
- **(b)** Skip retention entirely if the fork lacks the bootstrap-handoff risk. A fork that started post-1.0 with substrate-canonical devbox from day one has no pre-absorption upstream to retain — the retention invariant is substrate-scope-only in that case. Substrate documentation still carries the recipe for forks that may encounter the same risk later.

Substrate-wins precedence per `docs/invariants/fork.md § Precedence` applies. Forks MAY NOT:

- Remove the substrate-side documentation of this policy from their fork (the policy lives here on `main`; fork-local amendments are additive per FR44).
- Weaken the "no-feature-parity" framing in § Cherry-pick workflow (forks preferring feature-parity retention run a different maintenance model; substrate forbids conflating the two).
- Automate the cherry-pick workflow without an FR44 AMEND (see § Cherry-pick workflow "Documented-but-not-automated by design" clause).

Growth-tier `INVARIANTS.fork.md` (per FR45 + `docs/invariants/fork.md § INVARIANTS.fork.md scaffold`) MAY register a fork-specific rule pinning the fork's retention choices, but substrate rules registered in this document take precedence.
