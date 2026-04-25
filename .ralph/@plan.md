# Implementation Plan

## NOW

- [ ] Run `/bmad-correct-course` (issue #232 — devbox network whitelist DNS-rotation regression). Input: `_bmad-output/planning-artifacts/course-correction-issue-232-briefing.md`. Expected output: sprint-change proposal at `_bmad-output/planning-artifacts/sprint-change-proposal-issue-232.md` + Story 2.18 spec + Story 2.3/2.4 Change Log amendments + sprint-status.yaml entry.

## QUEUE (Story 2.18 — pending /bmad-correct-course refinement)

- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures.
- [ ] Run `/bmad-create-story` — Story 2.18 first creation pass (post-correction; lifecycle `_(no story) → drafted`).

## BLOCKED

_(none)_

## ATDD Red Phase

_(empty until Story 2.18 atdd-scaffolded.)_

## DONE

- [x] iter-1 (this branch): course-correction setup — branch `chore/devbox-network-whitelist-232` from `origin/feat/epic-2-packaged-devbox` tip (152be87); briefing artifact written at `_bmad-output/planning-artifacts/course-correction-issue-232-briefing.md`; IP reset for course-correction lifecycle.

## Context

- **Phase:** 4-implementation — Epic 2 in COURSE-CORRECTION (Story 2.18 staged). Epic-2 PR #230 still OPEN, awaiting human merge; this branch stacks the network-whitelist fix on top.
- **Runtime:** cc-devbox iteration env. Network egress to `github.com` is the bug under fix — best-effort push when DNS rotation lands a whitelisted IP.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17/17 stories `done` at iter-345; Story 2.18 will be appended via this course-correction.
- **Epic Branch (parent):** `feat/epic-2-packaged-devbox` (PR #230 OPEN).
- **Working Branch:** `chore/devbox-network-whitelist-232` (this branch — course-correction host).
- **Story:** _(none — pre-correction; `/bmad-correct-course` runs first to draft Story 2.18 + amendments)._
- **Story File:** _(n/a until Story 2.18 spec produced.)_
- **Story State:** _(no story — course-correction phase precedes Story 2.18 lifecycle entry.)_
- **GitHub Issue:** [#232](https://github.com/tthew/ralph-bmad/issues/232) — devbox network whitelist DNS-rotation. Issue body unreachable from inside devbox at iteration 1 (the bug); body inferred from synthesized live evidence.
- **PR:** TBD — this iteration creates a draft PR targeting `feat/epic-2-packaged-devbox`.

## Notes

- **Root cause (issue #232).** `reload-egress.sh` snapshots whitelisted-domain IPs at boot via `getent ahostsv4/v6` + pins them as static `ip daddr <addr> accept` rules in nftables. `github.com` round-robin DNS rotates beyond the snapshot. dnsmasq's `nftset=` directive (Option A in briefing) is the load-bearing fix — every DNS reply for `/github.com/` adds the resolved IP to a named nftables set; `output_v4` accepts on `ip daddr @gh_v4`. Static GitHub CIDR fallback (Option B) covers the bootstrap window. Combo = Option C, recommended.
- **Briefing handoff.** `course-correction-issue-232-briefing.md` is the durable input artifact for `/bmad-correct-course`. It survives loop interruption — next iteration reads + feeds verbatim.
- **Push-fail intermittence.** Even WITHIN this iteration, `github.com:443` worked at 2026-04-25 11:46 UTC (200 in 146ms); the prior iteration saw an 8s timeout. Window is non-deterministic — push when it lands.
- **No conflict with issue #231.** `sprint-change-proposal-2026-04-25.md` exists for issue #231 (doc-budget). New course-correction artifact filename uses `-issue-232` suffix — no clash.
