# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story` (Story 2.18 first creation pass — fresh context). Reads `_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md` (course-correction draft v0.1) + `_bmad-output/planning-artifacts/epics.md § Story 2.18` + `_bmad-output/planning-artifacts/sprint-change-proposal-issue-232.md`. Skill auto-flips `epic-2: done → in-progress` + `2-18-…: backlog → ready-for-dev`. Lifecycle transition `_(no story) → drafted`.

## QUEUE (Story 2.18)

- [ ] Monitor PR #235 CI — queue fix tasks for any failures.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures.
- [ ] Run `/bmad-create-story (args: "review")` — Story 2.18 pre-dev SM validation (`drafted → validated`).
- [ ] Run `/bmad-testarch-atdd` OR ATDD-skip via FR14n § Story Lifecycle Decision Matrix ATDD-skip clause — fifteenth cumulative precedent projected (Stories 1.7..1.16 + 2.1 + 2.2 + 2.3 + 2.4 + 2.18). Hybrid ground-(c)+(ii)+(iii) skip applies: Story 2.18 has no authored test-runner; downstream Epic 13 harness owns regression coverage; SM review + CR substitute for adversarial coverage.
- [ ] Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md")`.
- [ ] Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate.
- [ ] Run `/bmad-create-story (args: "review")` — post-dev SM verification (`traced → sm-verified`).
- [ ] Run `/bmad-code-review (args: "2")` — CR opener (`sm-verified → fixes-pending` or `done`).
- [ ] _(if PATCHes)_ Drain CR action items one-per-iter; re-run CR.
- [ ] Transition PR #235 Draft→Open — final CI gate (Epic 2 close-out for Story 2.18).

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty until Story 2.18 atdd-scaffolded; ATDD-skip is the projected outcome.)_

## DONE

- [x] iter-1 (this branch): course-correction setup — branch `chore/devbox-network-whitelist-232` from `origin/feat/epic-2-packaged-devbox` tip (152be87); briefing artifact written at `_bmad-output/planning-artifacts/course-correction-issue-232-briefing.md`; IP reset for course-correction lifecycle.
- [x] iter-2 (this iter): `/bmad-correct-course` executed autonomously per Ralph guardrail #3. Six artefacts written: (1) `_bmad-output/planning-artifacts/sprint-change-proposal-issue-232.md` (full proposal — Issue Summary + Impact Analysis + Path Forward Evaluation + Detailed Change Proposals + Implementation Handoff); (2) `_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md` (Story 2.18 spec — 5 ACs + 12 Tasks/~50 Subtasks + 11 SCs + Dev Notes); (3) `_bmad-output/planning-artifacts/epics.md` Epic 2 stanza for Story 2.18 appended after Story 2.17; (4) `_bmad-output/implementation-artifacts/sprint-status.yaml` `2-18-…: backlog` row + timestamp comment; (5) `_bmad-output/implementation-artifacts/2-3-…md` Change Log v1.9 forward-pointer; (6) `_bmad-output/implementation-artifacts/2-4-…md` Change Log v2.3 forward-pointer.

## Context

- **Phase:** 4-implementation — Epic 2 in COURSE-CORRECTION (Story 2.18 staged via this iter). Epic-2 PR #230 still OPEN, awaiting human merge; this branch stacks the network-whitelist fix on top.
- **Runtime:** cc-devbox iteration env. Network egress to `github.com` is the bug under fix — best-effort push when DNS rotation lands a whitelisted IP.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17/17 stories `done` at iter-345; Story 2.18 appended as backlog via this course-correction. Sprint-status `epic-2: done` stays until Story 2.18 starts dev (next iter's `/bmad-create-story` flips to `in-progress`).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` (PR #230 OPEN).
- **Working Branch:** `chore/devbox-network-whitelist-232` (this branch — course-correction host).
- **Story:** Story 2.18 — Devbox network whitelist DNS-rotation fix (dnsmasq nftset= + GitHub CIDR fallback).
- **Story File:** `_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md` (v0.1 course-correction draft; canonical drafted format produced next iteration via `/bmad-create-story`).
- **Story State:** _(no story)_ — `/bmad-create-story` next iter transitions to `drafted`.
- **GitHub Issue:** [#232](https://github.com/tthew/ralph-bmad/issues/232) — devbox network whitelist DNS-rotation. Issue body unreachable from inside devbox at iter-1 (the bug); body inferred from synthesized live evidence in briefing + this proposal.
- **PR:** [#235](https://github.com/tthew/ralph-bmad/pull/235) Draft — targets `feat/epic-2-packaged-devbox`. Created via `curl --resolve api.github.com:443:140.82.121.5` workaround at iter-1.

## Notes

- **Forecast (Story 2.18 fix-chain).** Per the iter-155 fix-chain forecast equation `(carve-out × 3) + (live-smoke-defer × 3) + (impl-surface-LOC / 100)`: 0 carve-out + backend-B live-smoke defer (+3) + ~200 LOC (+2) → ~5 ceiling → forecast 2–4 PATCH at CR opener, 4–6 iter chain length. Tighter than Story 2.3's 10-iter chain because the change is additive (no algorithmic rewrite of `reload-egress.sh`).
- **Approach selected (Sprint Change Proposal § 4.4):** Direct Adjustment (Option 1) hybrid Option A (`dnsmasq nftset=`) + Option B (static GitHub CIDR fallback) = Option C combo. Belt-and-braces matches Story 2.3's existing two-layer egress posture.
- **Image rebuild required.** Verify Debian's `dnsmasq` package compiled with `--enable-nftset` at first build (Story 2.18 Task 1). Most recent Debian builds are; pin in `VERSIONS.md` if not already locked.
- **DNS-rotation workaround (carry-forward to all course-correction iters until Story 2.18 lands).** When `gh pr create` / `gh api graphql` times out repeatedly at `api.github.com → 140.82.121.6` (or any non-whitelisted IP), bypass via REST API + `curl --resolve api.github.com:443:140.82.121.5` (or `.121.4`). Token via `gh auth token`. Same pattern works for any rotating-IP GitHub endpoint until Story 2.18 ships. **This is the bug actively biting; do not be surprised when it bites.**
- **No conflict with issue #231.** `sprint-change-proposal-2026-04-25.md` exists for issue #231 (doc-budget). New course-correction artefact `sprint-change-proposal-issue-232.md` has the `-issue-232` suffix — no clash.
- **Story 2.3 + 2.4 status unchanged.** Both stay `done`; Change Log entries are forward-pointers per BMad convention. The Story 2.18 implementation iteration will refresh `INV-devbox-egress-contract` contentHash via Story 1.9 sync-gate protocol (one-shot at dev-story landing).
