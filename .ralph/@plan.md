# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story (args: "review")` — Story 2.18 pre-dev SM validation. Reads `_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md` v1.0 (canonical drafted spec from iter-347). Lifecycle transition `drafted → validated`. Forecast: 0–3 PATCH at gate (course-correction-author had Sprint Change Proposal in fresh context; iter-347 canonicalisation already corrected path drift).

## QUEUE (Story 2.18)

- [ ] Run `/bmad-testarch-atdd` OR ATDD-skip via FR14n § Story Lifecycle Decision Matrix ATDD-skip clause — fifteenth cumulative precedent projected (10 Epic-1 + 2.1 + 2.2 + 2.3 + 2.4 + 2.18). Hybrid ground-(c)+(ii)+(iii) skip applies: no test runner at substrate; downstream Epic 13 harness owns regression coverage; SM review + CR substitute for adversarial coverage.
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

- [x] iter-345 (course-correction): `/bmad-correct-course` for issue #232 — Sprint Change Proposal + Story 2.18 v0.1 spec + epics.md stanza + sprint-status row + Story 2.3/2.4 Change Log forward-pointers staged.
- [x] iter-347 (this iter): `/bmad-create-story` canonical drafted pass — Status `backlog → ready-for-dev`; sprint-status `2-18-…: backlog → ready-for-dev` + `epic-2: done → in-progress` (manual since /bmad-create-story only auto-flips epic on first story); path-drift corrections at Tasks 3 + 4 (`KEEL_EGRESS_ALLOWLIST_MARKER_{START,END}` in `dnsmasq.conf:70-72` not inline `# === BEGIN dnsmasq dynamic block ===`; `nftables/egress.nft` not `templates/egress.nft`; chain-injection sites pinned at `egress.nft:68` + `:96`); Task 2 Subtask 2.4 sharpened with classifier-sidecar primitive (`.classification` byte-identical across both composers — SC-11 extending Story 2.4 SC-14); Project Structure Notes + canonical References (line-range pinned) + Dev Agent Record skeleton added; Change Log v1.0 entry recorded the canonicalisation pass.

## Context

- **Phase:** 4-implementation — Epic 2 in COURSE-CORRECTION (Story 2.18 active development). Epic-2 PR #230 still OPEN, awaiting human merge; this branch stacks the network-whitelist fix on top.
- **Runtime:** cc-devbox iteration env. Network egress to `github.com` is the bug under fix — `gh`/`git push` use `curl --resolve api.github.com:443:140.82.121.5` workaround until Story 2.18 lands.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17/17 prior stories `done`; Story 2.18 in active dev. Sprint-status `epic-2: in-progress` (flipped iter-347 from `done` since story 2.18 work has begun).
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` (PR #230 OPEN).
- **Working Branch:** `chore/devbox-network-whitelist-232` (course-correction host; PR #235 Draft).
- **Story:** Story 2.18 — Devbox network whitelist DNS-rotation fix (dnsmasq nftset= + GitHub CIDR fallback).
- **Story File:** `_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md` (v1.0 canonical drafted form via `/bmad-create-story` iter-347).
- **Story State:** `drafted` — `/bmad-create-story (args: "review")` next iter transitions to `validated`.
- **GitHub Issue:** [#232](https://github.com/tthew/ralph-bmad/issues/232) — devbox network whitelist DNS-rotation.
- **PR:** [#235](https://github.com/tthew/ralph-bmad/pull/235) Draft — targets `feat/epic-2-packaged-devbox`. Stays Draft until Story 2.18 done.

## Notes

- **Forecast (Story 2.18 fix-chain).** Per the iter-155 fix-chain forecast equation: 0 carve-out + backend-B live-smoke defer (+3) + ~200 LOC (+2) → ~5 ceiling → 2–4 PATCH at CR opener, 4–6 iter chain length. Tighter than Story 2.3's 10-iter chain (additive change, no algorithmic rewrite of `reload-egress.sh`).
- **Approach selected (Sprint Change Proposal § 4.4):** Direct Adjustment (Option 1) hybrid Option A (`dnsmasq nftset=`) + Option B (static GitHub CIDR fallback) = Option C combo. Belt-and-braces matches Story 2.3's existing two-layer egress posture.
- **Image rebuild required.** Verify Debian's `dnsmasq` package compiled with `--enable-nftset` at first build (Story 2.18 Task 1). Most recent Debian builds are; pin in `VERSIONS.md` if not already locked.
- **DNS-rotation workaround (carry-forward to all course-correction iters until Story 2.18 lands).** When `gh pr ...` / `gh api graphql` times out at `api.github.com → 140.82.121.6` (or any non-whitelisted IP), bypass via REST API + `curl --resolve api.github.com:443:140.82.121.5` (or `.121.4`). Token via `gh auth token`. **This is the bug actively biting; do not be surprised when it bites.**
- **No conflict with issue #231.** Doc-budget course-correction artefact lives at `sprint-change-proposal-2026-04-25.md`; Story 2.18 artefact has `-issue-232` suffix.
- **Story 2.3 + 2.4 status unchanged.** Both stay `done`; Change Log entries are forward-pointers per BMad convention. Story 2.18 implementation iteration will refresh `INV-devbox-egress-contract` contentHash via Story 1.9 sync-gate protocol (one-shot at dev-story landing).
