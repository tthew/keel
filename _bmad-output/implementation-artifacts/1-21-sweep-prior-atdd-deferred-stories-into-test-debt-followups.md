# Story 1.21: Sweep prior `ATDD deferred` stories into `test-debt:` follow-ups

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a substrate operator who has accumulated 10+ ATDD-skip precedents across Stories 1.7–1.16 (RALPH.md § ATDD-skip-precedents) plus an unmeasured count across Stories 2.1–2.18,
I want a single audit pass producing `test-debt:` follow-up entries cataloguing each pre-bootstrap story's coverage gap with the ground (a/b/c) it cited at skip time,
So that the test-debt is visible (not invisible accumulating drift), prioritisable (we can rank by risk), and bounded (no further ATDD-skip ground (b) accrues post-bootstrap per FR14n amendment per issue #233).

## Acceptance Criteria

**AC1 — `test-debt.md` catalogue exists with one row per pre-bootstrap story carrying an ATDD-skip; each row records skip-ground + AC class + effort + risk class.**

**Given** the audit walks Stories 1.1–1.16 + 2.1–2.18,
**When** Story 1.21 lands,
**Then** there exists `_bmad-output/implementation-artifacts/test-debt.md` with one entry per story carrying an ATDD-skip
**And** each entry records (a) the skip ground cited (a/b/c per FR14n matrix row 3); (b) the AC class skipped (functional / RLS / security / contract / docs); (c) the back-fill estimated effort (S / M / L); (d) the risk class (P0 highest-risk substrate enforcement code / P1 / P2)
**And** the catalogue order matches the story-id order (1.1 → 1.16 → 2.1 → 2.18) so future readers can skim by epic and pick up entries linearly
**And** stories that did NOT ATDD-skip are explicitly omitted (the file is the catalog of skips, not a complete-story index — count consistency proven via the cross-link assertion in AC3).

**AC2 — FR14n amendment per issue #233 is in effect: bare ground-(b) ATDD-skips are flagged at `bmad-create-story (args: "review")` pre-dev gate.**

**Given** post-bootstrap stories,
**When** any future story drafts an ATDD-skip with bare ground (b),
**Then** the FR14n amendment per issue #233 makes this insufficient (must cite ground (a) or (c))
**And** the `bmad-create-story (args: "review")` pre-dev gate flags the violation per its existing AC-coverage check
**And** the amendment text is verifiable in `_bmad-output/planning-artifacts/prd.md` § FR14n (already landed at issue #233 SCP § Section 4.2 amendment block; Story 1.21 verifies its presence + its cross-reference to test-debt.md as the catalogue artefact for grandfathered pre-bootstrap skips).

**AC3 — Each test-debt entry is referenced from the originating story file's § Deferred Work / § Dev Notes / § Lessons Applied section (cross-link to `test-debt.md` anchor); CR pass verifies the cross-links.**

**Given** Story 1.21 catalogues each pre-bootstrap story's gap,
**When** the test-debt file is committed,
**Then** each entry is referenced from the originating story file's § Deferred Work section (or § Dev Notes / § Lessons Applied / § References — whichever the originating story already uses; the cross-reference shape MUST match the originating story's existing convention)
**And** the cross-link uses the canonical Markdown anchor pattern `_bmad-output/implementation-artifacts/test-debt.md#story-{epic}-{story}` (kebab-case anchor matching the GitHub-flavored Markdown auto-anchor of the test-debt.md row's H3 / H4 header)
**And** Story 1.21's CR pass verifies the cross-links: each test-debt.md entry has a matching back-pointer in its originating story file (verifiable via `grep -l 'test-debt.md#story-X-Y' _bmad-output/implementation-artifacts/*.md` per story-id; absence in the originating story file is a CR finding).

**AC4 — Pre-bootstrap skips are grandfathered; only NEW skips post-Story 1.21 are subject to FR14n amendment.**

**Given** the test-debt file's intended consumer (future epic-planning iterations: Epic 4 prep, Epic 13 prep, Epic 14 prep),
**When** future epic-planning iterations read the file,
**Then** they can prioritise backfill alongside their own scope (effort + risk class fields drive the prioritisation)
**And** the file is not retroactively re-opened mid-epic (pre-bootstrap skips are grandfathered; only NEW skips post-Story 1.21 are subject to the FR14n amendment per AC2's pre-dev-gate flag)
**And** the test-debt.md preamble explicitly documents the grandfather clause + the post-Story-1.21 net-zero-bare-(b)-skip target (locked at create-story: explicit prose statement of the close-of-Epic-1-reopen-window goal so future-Ralph reads the policy without round-tripping the SCP).

**AC5 — Inherited DEFER sweep: Stories 1.18 + 1.19 + 1.20 deferred-work.md entries are categorised in test-debt.md OR resolved in-flight OR explicitly carried forward to a NAMED follow-up story.**

**Given** Stories 1.18 + 1.19 (CR-pass-1 + CR-pass-2) + 1.20 (dev-story + CR-pass-1) accumulated 24 deferred entries during the Epic 1 REOPEN-ARC carrying-`Carry-to: Story 1.21 audit`-rationale (4 from Story 1.18 CR; 7 from Story 1.19 CR-pass-1; 6 from Story 1.19 CR-pass-2; 4 from Story 1.20 dev-story; 3 from Story 1.20 CR-pass-1 — count ground-truthed at SM-validate iter-399 via grep against `deferred-work.md` § headers carrying `(2026-04-26)` dates; H2 sections `## Deferred from: ...` at lines 805 / 812 / 822 / 831 / 842),
**When** Story 1.21 closes,
**Then** every inherited DEFER entry has one of three explicit dispositions (locked at create-story):
- **(a) absorbed-into-test-debt** — the DEFER is recorded as a row in `test-debt.md` (substrate-wide patterns like CRLF fragility / pythonpath shadowing / EPIPE handling become test-debt.md rows in their own right; one row per inherited DEFER that targets pre-bootstrap-class concerns)
- **(b) resolved-in-flight** — the DEFER is fixed in this story (e.g. `INV-git-hooks-preservation` family worktree-resolution if the dev-story can compute the canonical hash from a non-worktree clone OR re-bump the contentHash to the worktree-derived value with a one-line carry-rule note in the manifest description; `INV-package-test-coverage-floor` content-hash-mismatch resolution if the `git log` trace at dev-story shows the file-edit was unintentional and a revert lands cleanly)
- **(c) carried-forward-named** — the DEFER is explicitly re-deferred with a NAMED non-Story-1.21 target (e.g. Epic 4 hardening / Epic 13 perf-pass; the carry-target MUST be named, NOT "TBD")
**And** the dev-story Completion Notes record the disposition per inherited DEFER as a checklist (one bullet per entry: `- [DEFER-id] disposition (a)/(b)/(c) — rationale`)
**And** any DEFER not addressed by close-of-Story-1.21 is itself a CR finding (locked at create-story: the inherited-DEFER scope is enumerable + bounded; no DEFER is allowed to silently slip).

**AC6 — `iter-391 devbox-network whitelist gap` formally captured + named target.**

**Given** RALPH.md iter-391 + iter-392 surfaced a network-whitelist gap blocking `gh run view --log` access — the host `results-receiver.actions.githubusercontent.com` is not in the devbox whitelist per RALPH.md iter-392 entry "log-fetch path (still blocked by `results-receiver.actions.githubusercontent.com` whitelist gap per iter-391 § Notes)",
**When** Story 1.21 closes,
**Then** the gap is captured in `test-debt.md` under a dedicated § Substrate-Adjacent Operational Gaps section (NOT in the per-story catalog because it's not a per-story-ATDD-skip entry — it's a runtime/operational substrate gap surfaced during Epic 1 REOPEN-ARC)
**And** the entry records (a) the missing host(s); (b) the operational impact (`gh run view --log` blocked → CI-failure-investigation must use Annotation API fallback; iter-392 datapoint); (c) NAMED follow-up target (Story 2.18 amendment OR a new Story 2.19 — pick ONE at dev-story per substrate-ledger probe; locked at create-story: defer must cite a NAMED target, not "TBD")
**And** the entry does NOT itself fix the whitelist (Story 1.21 scope is documentation + cataloguing — operational substrate fixes route to Epic 2 follow-up).

## Tasks / Subtasks

- [ ] **Task 1 — Pre-flight ground-truth substrate probe.** (AC: 1, 3, 5 — precondition)
  - [ ] Subtask 1.1: Confirm `_bmad-output/implementation-artifacts/test-debt.md` does NOT yet exist (Story 1.21 creates it; if the file exists from a killed prior iteration, read + treat as in-flight WIP per dev-story recovery semantics — do NOT discard).
  - [ ] Subtask 1.2: Walk `_bmad-output/implementation-artifacts/deferred-work.md` for inherited-DEFER scope ground-truth. Capture the EXACT entry count under each of the 5 Epic-1-REOPEN-ARC H2 sections (`## Deferred from: code review of story-1-18 (2026-04-26)` at line 805; `## Deferred from: code review of story-1-19 (2026-04-26)` at line 812; `## Deferred from: code review of story-1-19 CR-pass-2 (2026-04-26)` at line 822; `## Deferred from: Story 1.20 dev-story (2026-04-26)` at line 831; `## Deferred from: code review of story-1-20 (2026-04-26)` at line 842). Ground-truthed at SM-validate iter-399: 4 + 7 + 6 + 4 + 3 = 24 entries. The exact list drives AC5's per-DEFER disposition decisions.
  - [ ] Subtask 1.3: Walk RALPH.md for the ATDD-skip-precedents inventory. Pinned grep tokens (re-run at dev-story to get live line numbers; create-story refs may have drifted): `ATDD.skip|atdd.skip|skip ground|ground.\(a\)|ground.\(b\)|ground.\(c\)` — capture every occurrence + cross-correlate to per-story file `## Lessons applied` / `## Dev Notes § ATDD red-phase posture` sections. The walk SHOULD surface ~31 ATDD-skip events (per RALPH.md iter-389 entry "31st cumulative project ATDD-skip"); divergence (e.g. 28 or 35) drives an SM-validate finding NOT a halt.
  - [ ] Subtask 1.4: Run `pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check` and capture stderr DriftReport JSON in Completion Notes. Expect 4 inherited drifts UNCHANGED from Story 1.20 dev-story baseline (3 `INV-git-hooks-preservation` family + 1 inherited `INV-package-test-coverage-floor`); the AC5 (b) resolved-in-flight branch decisions key off this output. **Decision criteria for the `INV-git-hooks-preservation*` family:** option-a-resolve (re-bump contentHash from non-worktree clone) requires git-worktree-list access to a non-worktree path; if the dev-story env is worktree-only per AGENTS.md § Worktrees, fall back to (c) carried-forward-named with `Epic 4 hardening` as the named target (Epic 4 will rewrite the names-and-shebangs walker to be worktree-aware as part of the secret/SAST scanner story arc which extends `keel-invariants`).
  - [ ] Subtask 1.5: Capture iter-391/392 RALPH.md whitelist-gap reference (search `RALPH.md` for `results-receiver` — expect 1 hit per iter-392 entry). Confirm iter-392 entry text matches Story 1.21 AC6 quote (`log-fetch path (still blocked by results-receiver.actions.githubusercontent.com whitelist gap per iter-391 § Notes)`); this entry is the canonical reference for the AC6 "operational impact" rationale.

- [ ] **Task 2 — Author `test-debt.md` per-story catalogue (Stories 1.1–1.16).** (AC: 1)
  - [ ] Subtask 2.1: For each Story 1.1–1.16, decide IN / OUT of scope based on Subtask 1.3 ATDD-skip walk + per-story file content. Stories with ATDD-skip events are IN; stories without (e.g. those that landed full ATDD red-phase per Story 1.7's SCP-mandated ground-(a) substrate-verification → in-test fixtures pattern) are OUT. Record the in/out decision rationale in Completion Notes for SM-validate audit.
  - [ ] Subtask 2.2: For each IN-scope Story 1.x, author a row in `test-debt.md` per the canonical schema:
    ```markdown
    ### Story 1.X — <Story title from epics.md or sprint-status row slug>

    - **Skip ground:** (a) substrate-verification | (b) no-runner | (c) hybrid (cite the FR14n matrix row 3 lettering)
    - **AC class skipped:** functional | RLS | security | contract | docs (single value or comma-separated if multiple)
    - **Back-fill effort:** S (≤ 0.5 day) | M (0.5–2 days) | L (≥ 2 days)
    - **Risk class:** P0 (highest-risk substrate enforcement code — security / sync-gate / hooks) | P1 (substrate-supporting infra — token gates / commit lint) | P2 (UX / docs / minor)
    - **Source:** RALPH.md `iter-N` (cite the RALPH.md iter where the skip was recorded) + `_bmad-output/implementation-artifacts/<story-slug>.md` § Lessons Applied / § Dev Notes
    - **Carry-to:** Epic-X follow-up | Story-Y backfill | "deferred indefinitely (substrate-not-load-bearing-at-1.0)"
    ```
    The `### Story 1.X` H3 anchor MUST resolve to the GitHub-flavored Markdown auto-anchor pattern `story-1-x` (lowercase + hyphen + numbers; the leading "story-" is required for AC3's grep assertion to match).
  - [ ] Subtask 2.3: Story 1.7 (knowledge files) gets a special-case row per SCP § Section 4 line 72 ("**No scope change.** ATDD-skip already documented and shipped; Story 1.21 audit sweeps the pre-existing skip into a `test-debt:` entry; no in-place spec edit."). Skip ground = (a)+(c) hybrid per the existing carry-rule in iter-365.

- [ ] **Task 3 — Author `test-debt.md` per-story catalogue (Stories 2.1–2.18).** (AC: 1)
  - [ ] Subtask 3.1: For each Story 2.1–2.18, decide IN / OUT of scope per Subtask 2.1 methodology. Several Epic 2 stories may have stronger substrate-verification grounds than Epic 1 stories (e.g. shell-level smoke probes for nftables / dnsmasq); per SCP § Section 4 line 74, the audit "records the ground per story" — IN-scope rows still get authored, but the skip-ground value is whichever ground actually applied (often (a) or (c), not (b)).
  - [ ] Subtask 3.2: For each IN-scope Story 2.x, author a row matching Subtask 2.2's schema. The H3 anchor pattern is `story-2-x`.
  - [ ] Subtask 3.3: Special-case Story 2.18 (devbox-network-whitelist) — its existing scope has empirical iter-391/392 evidence of a real-world operational gap. Record the test-debt entry pointing at AC6 of Story 1.21 (the substrate-adjacent gap section authored in Task 6).

- [ ] **Task 4 — Author `test-debt.md` preamble (grandfather clause + policy).** (AC: 4)
  - [ ] Subtask 4.1: Lead `test-debt.md` with a § Preamble section explaining (locked at create-story prose template; dev-story may NIT-tighten):
    ```markdown
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
    ```
    The preamble is the artefact's policy header. Subsequent sections are the catalogue body (Tasks 2 + 3 rows) followed by the substrate-adjacent operational gaps section (Task 6).

- [ ] **Task 5 — Cross-link from each originating story file's § Deferred Work / § Dev Notes / § Lessons Applied.** (AC: 3)
  - [ ] Subtask 5.1: For each test-debt.md row authored in Tasks 2 + 3, edit the originating story file (`_bmad-output/implementation-artifacts/<slug>.md`) to add a back-pointer. The back-pointer text shape (locked at create-story; dev-story may NIT-tighten):
    ```markdown
    See [test-debt.md § Story X.Y](./test-debt.md#story-x-y) for the post-Story-1.21 audit catalogue entry — back-fill effort/risk class + carry-to target.
    ```
    The back-pointer placement: append to the originating story's existing § Deferred Work (if present) OR § Dev Notes (subsection § Lessons Applied if present) OR § References (whichever section the originating story already uses; do NOT introduce a new section solely for the back-pointer — preserve the originating story's structure). The cross-reference shape MUST match the originating story's existing convention.
  - [ ] Subtask 5.2: After all back-pointers land, verify AC3's grep assertion: `grep -l 'test-debt.md#story-X-Y' _bmad-output/implementation-artifacts/*.md` MUST return EXACTLY ONE story file per test-debt.md entry (the originating story). Capture the verification command + output in Completion Notes.

- [ ] **Task 6 — Substrate-adjacent operational gaps (iter-391 whitelist + others surfaced at audit).** (AC: 6)
  - [ ] Subtask 6.1: Append `## Substrate-Adjacent Operational Gaps` section to `test-debt.md` AFTER Tasks 2 + 3 catalogue body. This section captures non-per-story gaps surfaced during the Epic 1 REOPEN-ARC that are operational/runtime (NOT per-story-ATDD-skip class). Initial entry per AC6:
    ```markdown
    ## Substrate-Adjacent Operational Gaps

    ### iter-391 devbox-network whitelist gap

    - **Missing host(s):** `results-receiver.actions.githubusercontent.com` (GitHub Actions log-results endpoint).
    - **Operational impact:** `gh run view --log <run-id>` blocked inside cc-devbox; CI-failure-investigation forced to fall back to GitHub Annotation API (per iter-392 datapoint, after 4 retries — 13th cumulative SSH-egress flake datapoint).
    - **Source:** RALPH.md iter-391 § Notes + iter-392 entry ("pivoted from log-fetch path (still blocked by `results-receiver.actions.githubusercontent.com` whitelist gap per iter-391 § Notes) to env-divergence-by-reasoning").
    - **Carry-to:** Story 2.18 amendment OR a new Story 2.19 (pick at dev-story per substrate-ledger probe — Story 2.18 already covers devbox-network-whitelist DNS-rotation + GitHub CIDR fallback; the `results-receiver.actions.githubusercontent.com` host is currently absent from the whitelist source-of-truth). Locked at create-story: this gap is documentation-only at Story 1.21 — operational substrate fix is OUT of scope.
    ```
  - [ ] Subtask 6.2: If the audit walk surfaces additional non-per-story gaps (e.g. additional whitelist gaps, runtime tooling gaps), append additional `### <gap-title>` H3 entries under § Substrate-Adjacent Operational Gaps. Locked at create-story: any such addition MUST cite a RALPH.md iter or sprint-status line as evidence; speculative gaps are OUT of scope.

- [ ] **Task 7 — Inherited DEFER sweep (Stories 1.18 + 1.19 + 1.20 deferred-work.md entries).** (AC: 5)
  - [ ] Subtask 7.1: For each inherited DEFER captured in Subtask 1.2 (predicted 23 entries; actual count drives the per-disposition checklist in Completion Notes), apply the AC5 disposition tree:
    - Substrate-wide patterns (CRLF fragility, EPIPE handling, pythonpath shadowing, recursive-readdir traversal of `node_modules` / `dist`) → disposition (a) absorbed-into-test-debt — author one row per such pattern in `test-debt.md` § Substrate-Wide Patterns (NEW H2 section AFTER per-story catalogue body).
    - `INV-git-hooks-preservation*` family worktree-mode drift → disposition decision per Subtask 1.4 ground-truth: if non-worktree clone access is available, disposition (b) resolved-in-flight (re-bump contentHash to canonical non-worktree value); else disposition (c) carried-forward-named with target Epic 4 hardening (Epic 4 will rewrite the names-and-shebangs walker as part of the secret/SAST scanner extension of `keel-invariants`).
    - `INV-package-test-coverage-floor` content-hash-mismatch → disposition decision per `git log` trace of `packages/keel-invariants/src/check-package-test-coverage-floor.ts`: if the file edit was unintentional (e.g. a stray formatter run between Story 1.19 close + Story 1.20 dev-story), revert via disposition (b) resolved-in-flight; if intentional (e.g. a fix landed under the test-runner-config epic but the manifest contentHash wasn't bumped), re-bump the contentHash to the live file sha256 via disposition (b) — option-b. EITHER disposition lands the inherited drift cleanly.
    - Story 1.18 + 1.19 CR-DEFERs targeting test-hygiene nits (e.g. `buildFixture` tmp dir cleanup, CR-3 stdout-empty assertion, CR-8 JSON.parse guard) → disposition (a) absorbed-into-test-debt as a single § Story 1.19 test-hygiene cluster row in `test-debt.md` § Substrate-Wide Patterns (a multi-DEFER cluster row is preferable to one row per nit — locked at create-story to keep the catalogue scannable).
    - Renovate / `setup-uv@v6` python-version pin / pythonpath shadowing (Story 1.18 CR-DEFERs) → disposition (a) absorbed-into-test-debt as a § Story 1.18 build-config cluster row.
  - [ ] Subtask 7.2: Record per-DEFER disposition in dev-story Completion Notes as a checklist (`- [DEFER-id] disposition (a)/(b)/(c) — rationale`). The checklist count MUST match Subtask 1.2 ground-truth count (no DEFER allowed to silently slip — AC5 lock).
  - [ ] Subtask 7.3: For disposition (b) resolved-in-flight items, run `pnpm --filter @keel/keel-invariants build && pnpm keel-invariants:check` AFTER the resolution lands; expect the count of remaining drifts to drop by the (b)-disposition count. Capture before/after sync-gate output in Completion Notes (consistent with Story 1.20 Subtask 9.4 lockstep verification pattern).

- [ ] **Task 8 — Verify FR14n amendment per issue #233 (AC2 amendment text + pre-dev-gate flag).** (AC: 2)
  - [ ] Subtask 8.1: Read `_bmad-output/planning-artifacts/prd.md` § FR14n. Verify the amendment text from SCP § Section 4.2 is in place (the text covers: ground (b) sunsets at Story 1.17/1.18 land + post-bootstrap stories MUST cite ground (a) or (c) + bare ground (b) is no longer sufficient + pre-bootstrap stories grandfathered (audited by Story 1.21)). If absent or incomplete, halt + raise SM-validate finding (the amendment is upstream context for AC2; Story 1.21 does not author the amendment, only verifies it).
  - [ ] Subtask 8.2: Verify the `bmad-create-story (args: "review")` pre-dev gate (skill at `.claude/skills/bmad-create-story/checklist.md`) carries an AC-coverage check that catches bare ground-(b) ATDD-skips. Read the checklist at the pinned path; the amendment per issue #233 should have updated the AC-coverage check OR the pre-dev gate should naturally catch the violation via its existing AC-coverage pattern. If absent, route to a Subtask 8.3 documentation-only edit — NOT a code/skill change (skill source-of-truth is upstream BMad install; in-repo skill files are committed but skill-logic edits route to a substrate-extension story, not Story 1.21).
  - [ ] Subtask 8.3: If Subtask 8.2 finds the pre-dev gate already catches bare ground-(b) skips, record a Completion Note confirming AC2's enforcement is in place. If not, record an § iter-X (Story 1.21 follow-up) row in `deferred-work.md` referencing the gap + naming Epic 4 / a substrate story for the gate-edit follow-up; this preserves AC2's intent without expanding Story 1.21 scope to include skill-source edits.

- [ ] **Task 9 — Final verification.** (AC: 1, 2, 3, 4, 5, 6)
  - [ ] Subtask 9.1: `pnpm --filter @keel/keel-invariants build && pnpm --filter @keel/keel-invariants test` — full GREEN. Story 1.21 is documentation-class (no code edits expected beyond AC5 disposition (b) resolved-in-flight items if they touch the manifest); the test suite count should remain 52 GREEN per Story 1.20 baseline OR change only via disposition (b) item-count adjustments (e.g. if `INV-package-test-coverage-floor` contentHash re-bump lands, no test count delta).
  - [ ] Subtask 9.2: `pnpm typecheck && pnpm lint && pnpm format:check` — full GREEN across the monorepo. Pre-existing-failure carve-out per Story 1.18 SC-3 / Story 1.19 SC-9 / Story 1.20 Subtask 9.2 inherited-failure-class: if any of these fail with errors that ALSO fail on `feat/epic-2-packaged-devbox` HEAD pre-Story-1.21-edits, the failure is inherited NOT introduced by Story 1.21; record in Completion Notes + queue an § iter-X (Story 1.21 follow-up) row in `deferred-work.md` rather than blocking.
  - [ ] Subtask 9.3: `uv run pytest` — full GREEN (Story 1.18's Python smoke corpus; expected unaffected by Story 1.21 documentation-class edits).
  - [ ] Subtask 9.4: `pnpm keel-invariants:check` — final sync-gate run. Expected outcome:
    - If all AC5 disposition (b) items chose option-b-resolve-in-flight (re-bump contentHashes to live values): exits 0 globally.
    - If any AC5 disposition (b) items chose option-c-carry-forward (e.g. INV-git-hooks-preservation drift remains in worktree-only env): exits non-zero ONLY for the explicitly carried-forward items; all NEW Story-1.21 entries (none expected unless disposition (b) introduced one) are clean. **AC1 + AC5 lockstep:** the sync-gate's drift count after Story 1.21 close-out MUST be ≤ Subtask 1.4 baseline drift count (Story 1.21 does NOT introduce new drift).
  - [ ] Subtask 9.5: AC3 cross-link verification: `grep -l 'test-debt.md#story-' _bmad-output/implementation-artifacts/*.md` returns exactly N files where N = count of test-debt.md per-story entries (AC3 lock). Capture the diff in Completion Notes; CR audit confirms.
  - [ ] Subtask 9.6: Final word-count + section-count audit on `test-debt.md`: count the H3 `### Story X.Y` headers + verify count matches AC1's predicted 30+ entries (10+ pre-bootstrap Epic-1 ATDD-skips per RALPH.md iter-389 baseline + ~20 Epic-2 ATDD-skips per the unmeasured count from SCP § 1.21 AC1). Divergence from prediction is informational — the actual count IS the audit deliverable; the prediction was educated guess only.
  - [ ] Subtask 9.7: Capture all gate outputs (Subtasks 9.1–9.6) in Completion Notes for SM-verify + CR audit trails (consistent with Story 1.20 Subtask 9.5 pattern).

## Dev Notes

### Audit methodology (locked at create-story)

The Story 1.21 audit walks **34 stories** total (Epic 1: 1.1–1.16 = 16 stories; Epic 2: 2.1–2.18 = 18 stories; Stories 1.17–1.20 are EXCLUDED — they are the bootstrap arc that landed AFTER the FR14n amendment per issue #233; their ATDD posture is post-amendment, not pre-bootstrap-grandfathered). The catalog body (the SUBSET that actually ATDD-skipped) is expected to be ~30 entries (per Subtask 9.6 prediction); divergence between walked-count (34) and catalog-count (~30) reflects stories that landed full ATDD red-phase coverage at the time (e.g. Story 1.7's SCP-mandated ground-(a) substrate-verification pattern).

The walk SHOULD surface ~30 ATDD-skip events (per RALPH.md iter-389 entry "31st cumulative project ATDD-skip" — most events correspond 1:1 to a story but some stories may have multi-event skips, e.g. Story 2.6 had 3 CR-RE-RUN passes per `deferred-work.md` headers).

**Classification per row (AC1 sub-fields):**

- **Skip ground (FR14n matrix row 3 lettering):**
  - (a) substrate-verification covers the AC (manifest entry + sync-gate output + INVARIANTS.md anchor — substrate-verifiable WITHOUT runtime test).
  - (b) no test runner exists (the load-bearing skip ground for many Epic-1 + Epic-2 substrate stories pre-bootstrap; SUNSET at Story 1.17/1.18 land per FR14n amendment per issue #233).
  - (c) hybrid (downstream-story-covers-integration / spec-declared-CR-substitution / Zod-upstream-owns-correctness / pre-existing-drift-carve-out variant-(ii)).

- **AC class skipped:** functional (default — no test of behaviour) | RLS (database row-level-security policy gates) | security (auth / authz / hook regex / secret denylist) | contract (API / data shape / schema) | docs (markdown / config-file content). One value or comma-separated if multi.

- **Back-fill effort:** S (≤ 0.5 day — single test file with 2–5 cases) | M (0.5–2 days — fixture infra + multi-test) | L (≥ 2 days — fixture corpus + integration harness).

- **Risk class:** P0 (highest-risk substrate enforcement code — sync-gate / hooks / settings policy / secret denylist) | P1 (substrate-supporting infra — token gates / commit lint / package coverage floor) | P2 (UX / docs / minor / style-only).

### test-debt.md vs deferred-work.md vs RALPH.md (audience separation)

Three distinct files with overlapping content but different audiences:

- **`test-debt.md` (NEW, this story)** — POST-Story-1.21 audience: future epic-planning iterations (Epic 4 / 13 / 14). Read-once-per-epic-prep cadence. Catalogue is enumerable + bounded. Each row has a Carry-to field driving backfill ordering.
- **`deferred-work.md` (existing, Story 1.8 origin)** — IN-FLIGHT audience: code-review iterations between stories. Read-during-CR cadence. Per-story sections accumulate adversarial-triage outcomes (defer + dismiss). Story 1.21 SWEEPS the Epic-1-REOPEN-ARC inherited DEFERs from this file into test-debt.md per AC5; pre-Epic-1-REOPEN-ARC `deferred-work.md` sections (Stories 1.8–2.17) are NOT touched.
- **`RALPH.md` § Lessons learned + § Gotchas + § Decisions** — RALPH-MEMORY audience: next-Ralph-iteration via the prompt's orient phase 0c. Read-every-iteration cadence. Per-iter signposts + lessons. Story 1.21 walks RALPH.md § ATDD-skip-precedents to extract per-story skip events but does NOT edit RALPH.md (RALPH.md is the source-of-truth for the walk; test-debt.md is the consolidated catalogue derived from it).

**Implication:** Story 1.21 does NOT remove or rewrite `deferred-work.md` § Story 1.18-1.20 sections. It absorbs the entries' INTENT into test-debt.md while leaving the originating sections in place (audit trail preservation). The originating sections may be referenced from test-debt.md rows via `[Source: deferred-work.md § <header>]` cross-link.

### L1-protection workaround (carry-rule from RALPH.md iter-374 + iter-378)

Story 1.21 is largely documentation-class. The only file in the L1 5-path regex (`packages/keel-invariants/src/(invariants\.manifest\.ts|sync-gate\.ts|manifest-reader\.ts|prek-hook-manifest\.ts|prompt-injection-rules/)`) that Story 1.21 MIGHT touch is `invariants.manifest.ts` IFF Subtask 7.1's AC5 disposition (b) resolved-in-flight branch lands a contentHash re-bump (e.g. `INV-package-test-coverage-floor` re-bump OR `INV-git-hooks-preservation` re-bump if non-worktree clone access is available).

If touching `invariants.manifest.ts`, use the canonical 2-step workaround:

1. `Write /tmp/invariants.manifest.ts.new` (full new file content; out-of-tree path is permitted).
2. `Bash node -e "require('fs').copyFileSync('/tmp/invariants.manifest.ts.new', 'packages/keel-invariants/src/invariants.manifest.ts')"` (`node` is NOT in the Bash mutation-verb deny list per `block-secret-access.sh` § Bash deny-verb regex).

Iter-378..397 12 consecutive datapoints (Story 1.19 CR-1..CR-8 + Story 1.20 dev-story Tasks 4 + 7.3) confirm `node`-via-Bash routing succeeds.

ALL OTHER FILES touched by Story 1.21 are OUTSIDE the L1 5-path regex (per iter-378 scope-clarification carry-rule):
- `_bmad-output/implementation-artifacts/test-debt.md` (NEW file — `Write` permitted).
- `_bmad-output/implementation-artifacts/<story-slug>.md` × N (Task 5 back-pointers — direct `Edit` permitted).
- `_bmad-output/implementation-artifacts/deferred-work.md` (Subtask 8.3 follow-up if AC2 gap surfaces — direct `Edit` permitted).

### ATDD red-phase posture (FR14n § ATDD-skip ground discrimination)

Story 1.21 is a **pure documentation/audit story** — no behaviour change, no new substrate test surface, no runtime contract.

ATDD-skip ground for Story 1.21: **(a) substrate-verification** — every AC is verifiable via filesystem state (file exists at canonical path; cross-link grep returns N matches; sync-gate output count <= baseline) WITHOUT runtime test execution. The `test-debt.md` artefact IS the deliverable; verifying its contents IS the verification.

This makes Story 1.21 the **second post-bootstrap ATDD-skip ground-(a) story** (after Stories 1.20's hybrid (a)+(c) — Story 1.20 was the first to invoke the post-bootstrap ground-discrimination protocol; Story 1.21 follows with pure ground-(a) since there is no behaviour-side AC to cover).

**Skill-mode-determination prompt incompatible with autonomous Ralph operation per guardrail 3** — past-Ralph practice (iter-358 Story 1.17 + iter-365 Story 1.18 + iter-389 Story 1.20) skips skill invocation entirely, recording rationale in IP § ATDD Skip Rationale only. Story 1.21 follows this precedent.

### Substrate-extension class forecast (RALPH.md iter-364 + iter-371 carry-rule)

Story 1.21 is the **first audit + sweep class story** in the project — no historical baseline. Per IP iter-397 entry: "Forecast envelope: substantial (audit + sweep class — 8+ DEFER items inherited; ~15–25 PATCH at SM-validate per inherited-defer-sweep class precedent — first datapoint of class)."

**Stage-by-stage forecast (locked at create-story; first datapoint of class — wide envelope by definition):**

| Stage          | PATCH range | Rationale                                                                                                                                                                                                                                          |
| -------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SM-validate    | 12–25       | Audit + sweep class with 6 ACs × 9 Tasks; classification methodology + per-row schema details + AC5 inherited-DEFER disposition tree all subject to scope-clarification at SM-validate. Wider than Story 1.20's 8–14 SM-validate due to 23-DEFER inherited list + cross-file scope (test-debt.md preamble + per-row schema + 30 cross-links + manifest re-bump branch). |
| ATDD-scaffold  | 0           | ATDD-skipped via ground (a) substrate-verification per § ATDD red-phase posture. 32nd cumulative project ATDD-skip / 4th post-(b)-sunset / 1st pure-ground-(a)-class skip post-bootstrap.                                                       |
| dev-story      | 0–6         | Audit walk + cataloguing + cross-links + DEFER sweep — substantial substrate work but no code changes. PATCH potential: classification methodology drift between create-story prediction + audit reality (e.g. some Epic 2 stories may not have skipped at all → AC1 in-scope decision adjusts). |
| trace          | 0–2         | Coverage IS the deliverable; traceability expected FULL (AC1↔test-debt.md, AC2↔FR14n verification, AC3↔grep cross-link, AC4↔preamble grandfather clause, AC5↔per-DEFER disposition checklist, AC6↔§ Substrate-Adjacent Operational Gaps row). |
| SM-verify      | 1–4         | Classification methodology second-look + per-row schema compliance + AC5 disposition completeness audit. Matches Story 1.20 SM-verify range scaled for wider AC count.                                                                          |
| CR             | 0–6 across 1–2 iters | Audit + sweep class CR is design-class concerns + classification-correctness; Story 1.20 CR-pass-1 0-PATCH sets the lower-band precedent. Wider envelope than 1.20 due to first-datapoint-of-class uncertainty.                                                                              |
| **Cumulative** | **13–43**   | First datapoint of audit + sweep class; envelope width reflects unknown empirical baseline. Lower bound from "audit-as-pure-add" minimum + SM-validate floor; upper bound from "classification-methodology-disputes-at-SM-validate-and-CR" maximum.                                                                                                                              |

**Test-surface decomposition:** Story 1.21 produces ZERO new test files (audit-class story; no test surface to add). The deliverable is `test-debt.md` itself + ~30 cross-link edits across pre-bootstrap story files + 0–4 manifest contentHash adjustments per AC5 disposition tree.

### Inherited DEFER scope (per IP iter-397; ground-truth at dev-story Subtask 1.2)

Predicted scope of Story 1.21's AC5 sweep (revised upward from IP "~19" to ~23 entries — re-grep at dev-story open):

- **Story 1.18 CR-pass-1** (4 entries): Hardcoded `setup-uv@v6 version: '0.11.7'` pin without renovate handling; CI runner Python-version drift risk; `pythonpath = ["."]` collision risk; future top-level `tui/` shadowing.
- **Story 1.19 CR-pass-1** (7 entries): REPO_ROOT resolver assumption; EXEMPT_LIST hardcoded inline; `buildFixture` tmp-dir leaks; CLI tests assume `dist/`; `hasTestFile` traverses `node_modules`/`dist`; perf full-recursive-readdir; symlink loops in `readdir`.
- **Story 1.19 CR-pass-2** (6 entries): CR-1/CR-2 red-path tests use loose `expect.stringMatching(...)`; CR-6 only exercises absent-`hashScope` branch of `(sourcePath, hashScope)` superRefine; `HAS_BASH_DASH` guard checks `which` not executability; EPIPE in top-level `.catch` `process.stderr.write`; CR-3 red tests missing stdout-empty assertion; CR-8 test crashes with `SyntaxError` if stderr unexpectedly empty.
- **Story 1.20 dev-story** (4 entries): `INV-git-hooks-preservation` `commit-msg` missing; `INV-git-hooks-preservation` `pre-commit` missing; `INV-git-hooks-preservation` `content-hash-mismatch`; inherited `INV-package-test-coverage-floor` `content-hash-mismatch`.
- **Story 1.20 CR-pass-1** (3 entries): Whole-file sha256 fragile to CRLF/whitespace mutations; whole-file sha256 lacks semantic awareness of AC5 trigger-filter clause; inherited `INV-package-test-coverage-floor` content-hash-mismatch root-cause investigation gap.

Total ground-truthed at SM-validate iter-399: **24 inherited DEFERs** (revised upward from create-story prediction "23" — Story 1.19 CR-pass-2 has 6 entries, not 5, per `deferred-work.md:822-829` H2-section walk). Subtask 1.2 re-confirms at dev-story open + drives the per-disposition checklist (AC5 lock).

### iter-371 root cause + iter-358 + iter-391 cross-references

Story 1.21 inherits unresolved substrate gaps from prior Epic 1 REOPEN-ARC iterations. Cross-references to the originating RALPH.md entries:

- **iter-358 root cause:** `sync-gate.ts` `names-and-shebangs` walker hardcodes `<repoRoot>/.git/hooks` for the per-hook walk; in worktree mode `.git` is a file pointer (not a directory) so the walked content is empty/divergent from the manifest's contentHash baked at Story 2.17 landing. THREE drifts persist iter-358 → iter-397 (Story 1.17 SC-9 + Story 1.18 SC-9 + Story 1.19 SC-9 + Story 1.20 AC6 option-b-defer all formally deferred to Story 1.21 audit). Resolution branch per AC5 disposition tree: option (b) re-bump if non-worktree clone available; else option (c) carry-forward to Epic 4 hardening.
- **iter-371 root cause:** CI-workflow-trigger filter gotcha — RESOLVED at Story 1.20 AC5 (`branches: [main, 'feat/epic-*']` expansion). PR #236 first non-vacuous CI GREEN run at iter-394. Carry-rule SUNSET. NO-OP for Story 1.21.
- **iter-391 root cause (NEW, this story):** devbox-network whitelist gap — `results-receiver.actions.githubusercontent.com` blocked → `gh run view --log` access fails → CI-failure-investigation forced to Annotation API fallback. Captured in Story 1.21 § Substrate-Adjacent Operational Gaps section per AC6 (Task 6); resolution deferred to Story 2.18 amendment OR new Story 2.19 (named follow-up target locked at Subtask 6.1 dev-story).

### iter-397 api.github.com timeout class (NEW, captured at Story 1.20 close-out)

Distinct from SSH-egress class (which manifests as `Connection timed out` ~75s). api.github.com class signature: `dial tcp 140.82.121.6:443: i/o timeout` (immediate fail). Carry-rule: when step 0h `gh pr view` / `gh pr checks` fails with this signature, the iter is recoverable — local skill execution proceeds; pre-push gate retries at step 5. Iter-397 step 0h logged 3 consecutive failures; Story 1.21 audit MAY surface additional datapoints — capture in Completion Notes if so but DO NOT itself fix the class (operational/network class is OUT of Story 1.21 documentation scope).

### Lessons applied (RALPH.md iter-356 → iter-397 reopen-arc)

- **iter-374 + iter-378 L1-protection workaround** — Subtask 7.1 disposition (b) branch (IFF resolved-in-flight) uses Write-to-tmp + node-copy.
- **iter-358 INV-git-hooks-preservation drifts** — AC5 disposition tree carries the worktree-vs-non-worktree resolution rationale forward to Epic 4.
- **iter-365 hybrid (a)+(c) carry-rule** — Story 1.21 is the FIRST pure-ground-(a) post-bootstrap story (Story 1.20 was hybrid (a)+(c)).
- **iter-366 substrate-probe gap** — Subtasks 1.1–1.5 do upfront ground-truth probes (test-debt.md absence + deferred-work.md count + RALPH.md walk + sync-gate output + iter-391 reference) to prevent mid-flight surprise.
- **iter-364 substrate-extension subclass yield** — Story 1.21 is the FIRST audit + sweep class story (no historical baseline; envelope wide by first-datapoint-of-class definition).
- **iter-389 Story 1.20 ATDD-skip hybrid (a)+(c) precedent** — confirms the post-bootstrap ATDD-skip protocol; Story 1.21 follows with pure ground (a).
- **iter-385 + iter-388 + iter-395 SSH-egress flake carry-rule** — pre-push gate at Story 1.21 step 5 may produce 14th+ cumulative class datapoint; first-retry-resolves carry-rule does NOT always hold.

### Project Structure Notes

- Files **created**:
  - `_bmad-output/implementation-artifacts/test-debt.md` (NEW; Tasks 2 + 3 + 4 + 6 + 7 cluster rows authored here).
- Files **modified**:
  - `_bmad-output/implementation-artifacts/<story-slug>.md` × ~30 (Task 5 back-pointers; one per test-debt.md per-story entry).
  - `packages/keel-invariants/src/invariants.manifest.ts` (Subtask 7.1 disposition (b) branch IFF resolved-in-flight contentHash re-bump lands; uses L1-protection workaround).
  - `_bmad-output/implementation-artifacts/deferred-work.md` (Subtask 8.3 follow-up IFF AC2 gate-edit gap surfaces).
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` (Step 6 of `bmad-create-story` workflow flips `1-21-...: backlog → ready-for-dev`; subsequent state transitions per FR14n matrix tracked in IP § Context Story State, NOT in sprint-status row).
- Files **NOT touched**: `RALPH.md` (per § test-debt.md vs deferred-work.md vs RALPH.md audience separation), `INVARIANTS.md` (no new substrate invariant), `.github/workflows/ci.yml` (no CI change), `_bmad-output/planning-artifacts/prd.md` (Subtask 8.1 is verification-only; PRD amendment landed at issue #233 SCP).

### References

- [Source: `_bmad-output/planning-artifacts/epics.md#Story-1.21`] — full SCP-spec AC blocks (lines 1272–1298 in post-issue-233 baseline).
- [Source: `_bmad-output/planning-artifacts/sprint-change-proposal-issue-233.md#Story-1.21`] — implementation handoff routing (lines 393–421, 71, 89, 103–105, 158, 213, 251–255).
- [Source: `_bmad-output/planning-artifacts/prd.md#FR14n`] — pre-dev gate AC-coverage check normative spec + issue #233 amendment (the post-bootstrap ground-(b) sunset).
- [Source: `_bmad-output/planning-artifacts/prd.md#FR14a`] — `Required tests:` manifest semantics + post-bootstrap clause per issue #233 amendment.
- [Source: `_bmad-output/implementation-artifacts/deferred-work.md` §§ Story 1.18 / 1.19 CR-pass-1 / 1.19 CR-pass-2 / Story 1.20 dev-story / Story 1.20 CR-pass-1] — 23 inherited DEFER entries (Subtask 1.2 ground-truth).
- [Source: `RALPH.md` iter-358 + iter-359 + iter-367] — `INV-git-hooks-preservation` worktree-mode drift root cause + persistence datapoints (Subtask 7.1 disposition (b) decision input).
- [Source: `RALPH.md` iter-389] — 31st cumulative project ATDD-skip count (Subtask 1.3 ground-truth).
- [Source: `RALPH.md` iter-391 § Notes + iter-392 entry] — `results-receiver.actions.githubusercontent.com` whitelist gap (AC6 + Subtask 6.1 source-of-truth).
- [Source: `RALPH.md` iter-374 + iter-378 + iter-390] — L1-protection workaround for `invariants.manifest.ts` edits.
- [Source: `RALPH.md` iter-365 + iter-389] — hybrid (a)+(c) ATDD-skip carry-rule + post-bootstrap ground-discrimination protocol.
- [Source: `_bmad-output/implementation-artifacts/1-19-backfill-keel-invariants-test-coverage.md` § Success Criteria + § Dev Notes] — sibling story for the Story 1.19 inherited-DEFER sweep + sync-gate test-fixture infrastructure.
- [Source: `_bmad-output/implementation-artifacts/1-20-activate-fr14i-for-real-end-vacuous-pass.md` § Acceptance Criteria + § Dev Notes + § Review Findings] — sibling story for the Story 1.20 inherited-DEFER sweep + L1-protection workaround datapoints.
- [Source: `packages/keel-invariants/src/invariants.manifest.ts:11-31`] — `HashScopeSchema` discriminatedUnion (relevant to Subtask 7.1 disposition (b) re-bump branch IFF lands).
- [Source: `packages/keel-invariants/src/invariants.manifest.ts:63-87`] — duplicate-(sourcePath, hashScope) superRefine clause (relevant to Subtask 7.1 disposition (b) re-bump branch IFF lands).
- [Source: `packages/keel-invariants/src/sync-gate.ts:36`] — ANCHOR_REGEX for INVARIANTS.md anchor-walker (NO-OP for Story 1.21 — no INVARIANTS.md edit).
- [Source: `_bmad-output/implementation-artifacts/sprint-status.yaml`] — `1-21-sweep-prior-atdd-deferred-stories-into-test-debt-followups: backlog → ready-for-dev` transition (post-Subtask 6 of `bmad-create-story` workflow).

## Dev Agent Record

### Agent Model Used

claude-opus-4-7[1m]

### Debug Log References

### Completion Notes List

### File List

## Change Log

- v1.0 — 2026-04-26 — `/bmad-create-story` autonomous discovery from sprint-status first-backlog row at iter-398. FR14n `_(no story) → drafted`. Story file created with 6 ACs (4 SCP-spec verbatim + AC5 IP-extension inherited-DEFER sweep + AC6 IP-extension iter-391 whitelist gap) / 9 Tasks / ~25 subtasks. Substrate verification: `test-debt.md` confirmed absent (NEW file at AC1 lock); `deferred-work.md` 5 Epic-1-REOPEN-ARC sections identified for Subtask 1.2 ground-truth (Stories 1.18 + 1.19 CR-pass-1 + 1.19 CR-pass-2 + 1.20 dev-story + 1.20 CR-pass-1). FR14n amendment per issue #233 verified in SCP § 4.2 (Subtask 8.1 verification target). L1-protection workaround pinned for Subtask 7.1 disposition (b) branch IFF resolved-in-flight contentHash re-bump lands. **First datapoint of audit + sweep class** — forecast envelope 13–43 cumulative pre-merge PATCH (wide by first-datapoint-of-class definition; SM-validate floor 12 from 6-AC × 9-Task surface; CR floor 0 from Story 1.20 CR-pass-1 0-PATCH precedent extension). Next NOW = `/bmad-create-story (args: "review")` (`drafted → validated`); forecast 12–25 PATCH at SM-validate per audit + sweep class first datapoint.
- v1.1 — 2026-04-26 — `/bmad-create-story (args: "review")` SM-validate pass at iter-399. FR14n `drafted → validated`. **7 PATCH applied** (within 12–25 forecast envelope lower-band): (1) AC5 Given clause "19 deferred entries" → "24" + "5 from CR-pass-2" → "6"; (2) Subtask 1.2 predicted "23 entries" → ground-truthed "24 entries" + H2-section line refs (805 / 812 / 822 / 831 / 842) for dev-story re-grep; (3) § Audit methodology "30 stories" → "34 stories" (16+18, internal math fix) + clarification of walked-count vs catalog-count divergence; (4) § Inherited DEFER scope Story 1.19 CR-pass-2 "(5 entries)" → "(6 entries)" + 6th item added to inline list; (5) § Inherited DEFER scope total "23 inherited DEFERs" → "24 inherited DEFERs"; (6) § Project Structure Notes "Subtask 11 of bmad-create-story workflow" → "Step 6" (workflow has 6 steps, not 11); (7) Add this v1.1 Change Log entry. **0 ENHANCEMENT applied** (anchor patterns `epics.md#Story-1.21` etc. are NIT — line refs are operative source-of-truth; deferred). **0 OPTIMIZATION applied** (story file is dense but functional; cutting verbosity would lose context). Story State `drafted → validated`; sprint-status row UNCHANGED at `ready-for-dev`. Lower-band of 12–25 forecast — fewer findings than envelope upper-bound because the create-story author (iter-398 Ralph) caught most ground-truth-vs-prediction divergences at create time; only Story 1.19 CR-pass-2 entry-count off-by-one and the 30-vs-34 stories-walked math survived to SM-validate. Next NOW = `/bmad-testarch-atdd` (FR14n `validated → atdd-scaffolded`); skip-via-ground-(a) per § ATDD red-phase posture; record rationale in IP § ATDD Skip Rationale.
