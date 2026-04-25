# Implementation Plan

## NOW

- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md")` — ATDD-skipped at iter-349; lifecycle transition `atdd-scaffolded → in-dev` (or `in-dev (partial)` carry-forward if Tasks 1–12 don't fit one iter — XL-story landing precedent iter-268, iter-283, iter-312).

## QUEUE (Story 2.18)

- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate.
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (`traced → sm-verified`).
- [ ] Run `/bmad-code-review (args: "2")` — CR opener (`sm-verified → fixes-pending` or `done`).
- [ ] _(if PATCHes)_ Drain CR action items one-per-iter; re-run CR.
- [ ] Transition PR #235 Draft→Open — final CI gate (Epic 2 close-out for Story 2.18).

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty — Story 2.18 took the ATDD-skip route at iter-349 per § ATDD Skip Rationale below; no red-phase scaffolds produced; nothing to clear post-dev.)_

## ATDD Skip Rationale (Story 2.18 — iter-349)

Hybrid ground (a)+(b)+(c) variant-(ii)+(iii) per FR14n § Story Lifecycle Decision Matrix ATDD-skip clause + RALPH.md iter-297 multi-ground requirement (bare ground-(b) INSUFFICIENT):

- **(a) substrate-verifies-AC.** AC1 / AC2 / AC4 + AC5 unit half + AC3 mechanism wiring all reduce to file-content commitments by the dev-agent at `atdd-scaffolded → in-dev`: `nftset=` directive emission in `reload-egress.sh:282-301`; named set declarations + accept rules + static CIDR fallback in `egress.nft:38-100`; `*-rotating.txt` annotation contract + `.classification` classifier sidecar (SC-11 byte-identity) in both `compose_whitelist()` (`start-egress.sh:87-130`) and `compose_whitelist_into()` (`whitelist.sh:87-114`). Iteration-env config-render smokes (Subtasks 9.1 + 9.2 + 9.3 `bash -n`) verify all three.
- **(b) no test runner at substrate.** Zero `vitest.config.*` / `jest.config.*` / `playwright.config.*` / `cypress.config.*` / `pyproject.toml` / `go.mod` / `Gemfile` / `Cargo.toml` / `csproj` anywhere in tree. Epic 13 (PRD RS6) is the formal test-framework landing.
- **(c) variant-(ii) downstream-epic-covers.** Epic 13 formal test-framework owns kernel-state regression coverage for AC3 + AC5 behavioural half (live `nft list set` accumulation across multiple `getent` rotations + `flush table` → re-fill round-trip per SC-7). Until Epic 13 lands, backend-B operator-workstation smokes (Subtasks 9.4 + 9.5) cover the live-kernel surface — this matches Story 2.1 iter-127 + Story 2.3 iter-159 + Story 2.4 iter-176 precedent.
- **(c) variant-(iii) spec-declared-CR-substitution.** 11 pinned scope-clarifications (SC-1 through SC-11) + 4 Dev Notes risk-register entries + the forthcoming `/bmad-code-review (args: "2")` adversarial fan-out (Blind Hunter + Edge Case Hunter + Acceptance Auditor against cumulative Story 2.18 substrate diff) substitute for red-phase scaffolds.
- **PARTIAL-AC ground-(c) variant-(ii) on AC3 + AC5 behavioural half** per RALPH.md iter-299 — substrate-verifies the mechanism wiring; live-kernel state requires hardened operator workstation per Story 2.5 `cap_add: [NET_ADMIN, NET_RAW]` posture + DNS upstream connectivity (the very bug being fixed — chicken-and-egg only at first deployment).

## DONE

- [x] iter-349 (this iter): **ATDD-skip via FR14n § Story Lifecycle Decision Matrix row `validated → atdd-scaffolded`.** 28th cumulative Epic ATDD-skip precedent / 18th Epic-2 / **first course-correction-origin ATDD-skip** (every prior Epic-2 ATDD-skip was `/bmad-create-prd` + `/bmad-create-epics-and-stories` then refined by `/bmad-create-story`; Story 2.18 was authored by `/bmad-correct-course` for issue #232 then canonicalised + SM-validated through identical lifecycle gates). Hybrid ground (a)+(b)+(c) variant-(ii)+(iii) — substrate-verifies-AC for AC1/2/4 + AC5 unit + AC3 mechanism wiring; PARTIAL-AC (c)-(ii) on AC3 + AC5 behavioural half (live-kernel state operator-workstation-deferred per Story 2.5 hardened posture chicken-and-egg). `/bmad-testarch-atdd` skill NOT invoked (preflight HALT at Step 1.2 — zero-test-runner substrate). Story 2.18 Change Log v1.2 entry added (single bullet — variant-(ii)+(iii) substitution template). Story `Status` remains `ready-for-dev`; sprint-status row at `:153` unchanged (ATDD-skip is FR14n Ralph-internal lifecycle — does NOT flip sprint-status). FR14n `Story State` transitions `validated → atdd-scaffolded`. Forecast carried forward unchanged (2–4 PATCH at CR opener, 4–6 iter chain length per iter-155 fix-chain equation).
- [x] iter-345 (course-correction): `/bmad-correct-course` for issue #232 — Sprint Change Proposal + Story 2.18 v0.1 spec + epics.md stanza + sprint-status row + Story 2.3/2.4 Change Log forward-pointers staged.
- [x] iter-347: `/bmad-create-story` canonical drafted pass — Status `backlog → ready-for-dev`; sprint-status `2-18-…: backlog → ready-for-dev` + `epic-2: done → in-progress` (manual since /bmad-create-story only auto-flips epic on first story); path-drift corrections at Tasks 3 + 4 (`KEEL_EGRESS_ALLOWLIST_MARKER_{START,END}` in `dnsmasq.conf:70-72` not inline `# === BEGIN dnsmasq dynamic block ===`; `nftables/egress.nft` not `templates/egress.nft`; chain-injection sites pinned at `egress.nft:68` + `:96`); Task 2 Subtask 2.4 sharpened with classifier-sidecar primitive (`.classification` byte-identical across both composers — SC-11 extending Story 2.4 SC-14); Project Structure Notes + canonical References (line-range pinned) + Dev Agent Record skeleton added; Change Log v1.0 entry recorded the canonicalisation pass.
- [x] iter-348 (this iter): `/bmad-create-story (args: "review")` pre-dev SM validation pass — FR14n `Story State drafted → validated`. Two-subagent SM-review fan-out (technical-correctness + prose-density) returned 21 substrate citations checked / 19 OK / 2 MINOR drift, plus 14 prose findings (2 must-fix, 7 should-fix, 5 nit). Nine PATCHes applied at gate (must-fix + should-fix + MINOR drift; 5 nits deferred): AC2 marker token drift, AC3 N+1 ambiguity, AC4 three-way ordering, AC5 recipe pointer, Task 2.4 `.classification` schema, Task 3.1 awk render sample, Task 5 simplification, Task 9.5 SC-7 reload-round-trip smoke, SC-6 CIDR-inclusion cross-ref, sprint-status line pins `:151→:153` + `:133→:135`. Story file Change Log v1.1 entry added. Forecast carried forward unchanged (2–4 PATCH at CR opener, 4–6 iter chain length).

## Context

- **Phase:** 4-implementation — Epic 2 in COURSE-CORRECTION (Story 2.18 active development). Epic-2 PR #230 still OPEN, awaiting human merge; this branch stacks the network-whitelist fix on top.
- **Runtime:** cc-devbox iteration env. Network egress to `github.com` is the bug under fix — `gh`/`git push` use `curl --resolve api.github.com:443:140.82.121.5` workaround until Story 2.18 lands.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17/17 prior stories `done`; Story 2.18 in active dev. Sprint-status `epic-2: in-progress` (flipped iter-347 from `done` since story 2.18 work has begun).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` (PR #230 OPEN).
- **Working Branch:** `chore/devbox-network-whitelist-232` (course-correction host; PR #235 Draft).
- **Story:** Story 2.18 — Devbox network whitelist DNS-rotation fix (dnsmasq nftset= + GitHub CIDR fallback).
- **Story File:** `_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md` (v1.1 SM-validated form via `/bmad-create-story (args: "review")` iter-348).
- **Story State:** `atdd-scaffolded` — ATDD-skipped at iter-349 per § ATDD Skip Rationale. Next iter runs `/bmad-dev-story` for `atdd-scaffolded → in-dev` (or `in-dev (partial)` carry-forward if Tasks 1–12 don't fit one iter).
- **GitHub Issue:** [#232](https://github.com/tthew/ralph-bmad/issues/232) — devbox network whitelist DNS-rotation.
- **PR:** [#235](https://github.com/tthew/ralph-bmad/pull/235) Draft — targets `feat/epic-2-packaged-devbox`. Stays Draft until Story 2.18 done.

## Notes

- **Forecast (Story 2.18 fix-chain).** Per the iter-155 fix-chain forecast equation: 0 carve-out + backend-B live-smoke defer (+3) + ~200 LOC (+2) → ~5 ceiling → 2–4 PATCH at CR opener, 4–6 iter chain length. Tighter than Story 2.3's 10-iter chain (additive change, no algorithmic rewrite of `reload-egress.sh`).
- **Approach selected (Sprint Change Proposal § 4.4):** Direct Adjustment (Option 1) hybrid Option A (`dnsmasq nftset=`) + Option B (static GitHub CIDR fallback) = Option C combo. Belt-and-braces matches Story 2.3's existing two-layer egress posture.
- **Image rebuild required.** Verify Debian's `dnsmasq` package compiled with `--enable-nftset` at first build (Story 2.18 Task 1). Most recent Debian builds are; pin in `VERSIONS.md` if not already locked.
- **DNS-rotation workaround (carry-forward to all course-correction iters until Story 2.18 lands).** When `gh pr ...` / `gh api graphql` times out at `api.github.com → 140.82.121.6` (or any non-whitelisted IP), bypass via REST API + `curl --resolve api.github.com:443:140.82.121.5` (or `.121.4`). Token via `gh auth token`. **This is the bug actively biting; do not be surprised when it bites.**
- **No conflict with issue #231.** Doc-budget course-correction artefact lives at `sprint-change-proposal-2026-04-25.md`; Story 2.18 artefact has `-issue-232` suffix.
- **Story 2.3 + 2.4 status unchanged.** Both stay `done`; Change Log entries are forward-pointers per BMad convention. Story 2.18 implementation iteration will refresh `INV-devbox-egress-contract` contentHash via Story 1.9 sync-gate protocol (one-shot at dev-story landing).
- **Pre-existing sync-gate drift (iter-349 observation; NOT introduced this iter).** `pnpm keel-invariants:check-all` reports two drift items at iter-349 orient: (a) `.pre-commit-config.yaml` content-hash-mismatch (expected `8f603ec5…` actual `4d894156…`) — introduced at commit `9716ca5 feat(ralph): doc-budget orient-gate + pre-commit hook (issue #231)` which appended the `ralph-doc-budget` hook (lines 56-61) without refreshing `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` manifest hashes; (b) `INV-git-hooks-preservation` reports `git-hook-missing` for pre-commit + commit-msg + content-hash-mismatch — likely the worktree-prek-walker interaction (hooks live at main-repo `.git/hooks/` via `core.hooksPath`, but the walker checks the worktree's `.git/hooks/`). Pre-commit hooks (typecheck + lint + format:check + claude-hook-syntax + nfr5a-minimum + ralph-doc-budget + commitlint) are GREEN; sync-gate (`pnpm keel-invariants:check-all`) is NOT in the pre-commit chain — only runs pre-merge. **Forward-fix:** Story 2.18 dev-story iter (next NOW) is going to refresh `INV-devbox-egress-contract` contentHash anyway via the python3 atomic-replace L1 routing per iter-315/iter-325/iter-329 precedent — bundle the `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` hash refresh in the same atomic write. The `INV-git-hooks-preservation` walker-vs-worktree interaction is a known iter-312 issue (prek-binary-cache eviction or `core.hooksPath` divergence); recovery is `prek install --hook-type pre-commit --hook-type commit-msg` from worktree root if the walker assertion needs to clear, or accept as a worktree-context known-limit.
