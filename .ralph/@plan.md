# Implementation Plan

## NOW

- [ ] `/bmad-code-review (args: "2")` CR opener — FR14n `sm-verified → fixes-pending` (default; adversarial-triage is the default) OR `sm-verified → done` (ZERO-PATCH close variant). **First Epic-2 infrastructure-security class CR.** Three-layer Ralph-hosted adversarial fan-out (Blind Hunter + Edge Case Hunter + Acceptance Auditor) against cumulative Story 2.3 substrate diff filtered to in-scope files (exclude `_bmad-output/` + `.ralph/` + `RALPH.md` + `_bmad/` per Story 2.2 iter-154 pattern; use `:(exclude)<path>` long-form pathspec — NOT `:^pattern` which fails with "Unimplemented pathspec magic" on literal-underscore prefixes). Forecast envelope per iter-151/154/155 equation: 0 source-carve-out + backend-B live-smoke defer (+3 because pervasive across all 5 ACs) + ~650 LOC / 100 = 9-ish ceiling → 6–9 iter fix-chain projected; LOOSER than Story 2.2's 4-iter TIGHTER than Story 2.1's 16-iter. Opener projected 2–6 PATCH. Pre-flight: argument `"2"` = "Leave as action items" per iter-154 lesson (CR opener = per-PATCH fix-drain iters; housekeeping defers to separate drain iterations unless single-commit closure). Budget: ~60K tokens (3 parallel subagents + triage + Story-file § Review Findings subsection insert between Tasks/Subtasks and Dev Notes per iter-151 GOTCHA + deferred-work.md append + IP carry-forward).

## QUEUE (Story 2.3 lifecycle — post-SM-verified)

- [ ] _(conditional, post-CR-opener)_ Fix-drain iterations per PATCH/AR — one fix task per iter; each carries `/bmad-code-review` `## Action Items` reference (file, line, requested change) at TOP of QUEUE; `Story State` stays `fixes-pending` until QUEUE empties → re-run `/bmad-code-review (args: "2")` to confirm `done`.
- [ ] _(conditional, post-CR-closure `fixes-pending → done`)_ `/bmad-code-review (args: "2")` re-run — verdict `done` (ZERO-PATCH close) OR cycle continues (forecast 1-2 AI cycle). Precedent: Story 2.1 iter-128..iter-144 3-cycle chain (9 → 5 → 0 AIs); Story 2.2 iter-151..iter-154 single fix-drain + re-run close. Story 2.3 forecast 1–2 cycles per iter-159 6–9 iter envelope.
- [ ] _(conditional, post-Story-2.3 done)_ `/bmad-create-story` for Story 2.4 (whitelist CLI: `packages/devbox/scripts/whitelist.sh` user-facing with add/remove/list/sync + per-fork override + diff summary + invocation of `reload-egress.sh`) per § Story Lifecycle Decision Matrix row `done` → auto-advance within-epic. Story 2.4 is infrastructure-CLI class (new class for Epic 2; may or may not inherit ATDD-skip / WAIVED-trace precedents depending on whether Epic 13 has landed a test runner by then).
- [ ] _(conditional, post-Story-2.17 done, ~Epic 2 completion)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion.
- [ ] _(conditional, post-Epic-2 merged)_ § Cross-epic transition → Epic 3 Story 3.1 OR halt EPIC_DONE awaiting merge.

## BLOCKED

_(none — Story 2.3 SM-verified landed iter-160 ZERO-PATCH; no carry-forward blockers.)_

## ATDD Red Phase

_(none — ATDD-skipped at iter-157; no red-phase failures to carry.)_

## DONE (current story 2.3 lifecycle)

- [x] iter-160: **`/bmad-create-story (args: "review")` post-dev SM verification landed — FR14n state `traced → sm-verified`; ZERO-PATCH + ZERO-CARVE-OUT-with-operator-workstation-defer-acknowledgment variant.** Second Epic 2 post-dev SM precedent (Story 2.1 iter-127 → Story 2.2 iter-150 → Story 2.3 iter-160); **first infrastructure-security class post-dev SM**. Three parallel fresh-context Sonnet subagents (AC-by-AC substrate evidence + SC-10 consolidated-invariant consistency + scope-isolation vs 2.4/2.5/2.6/2.13/Epic 4) converged on ZERO PATCH / ZERO DEFER / 0 DISMISS. AC-by-AC SATISFIED ×5 with file:line evidence (dnsmasq.conf L28/29/36/48/49 + start-egress.sh L38-44 resolv.conf pin SC-13 + entrypoint.sh L106-111 fail-hard + egress.nft L32/61 `policy drop` dual chains + L46 `ct state established,related accept` for SC-5 in-flight preservation + docker-compose.yml L98-100 `cap_add [NET_ADMIN, NET_RAW]` + egress-log-tailer.sh L23/24/25 + SC-3 schema embedded verbatim at invariant doc L48-63 + reload-egress.sh L71/72/154/207/214 + L12-21 8 documented exit codes + manifest entry L257-263 5-field + INVARIANTS.md L96-100 anchor bullet + sync-gate exit 0 green). SC-10 all 5 checks PASS. Scope-isolation all 5 PASS. Operator-workstation-defer-acknowledgment EXPLICITLY ACCEPTED: Task 12.1 – 12.8 are substrate commitments not runtime-proof requirements; `docker exec` recipes pinned at iter-158 in both invariant doc § Verification + README § Egress policy § Verification for operator close-out. SC-5 fallible-seam residual-risk language already documented at reload-egress.sh L20-21 + Dev Notes § Atomic reload contract — no enhancement-level drift needed. Story Status stays `review`; sprint-status unchanged (SM gate does NOT flip sprint-status). Story file v1.5 Change Log entry prepended above v1.4 (newest-first per 2.3 convention established iter-155). Budget: ~35K tokens (orient + 3 parallel subagents + sync-gate re-run + Change Log v1.5 + IP + RALPH.md + commit).
- [x] iter-159: `/bmad-testarch-trace (args: "yolo")` WAIVED — FR14n state `in-dev → traced`. THIRTEENTH cumulative Epic trace-WAIVED; FOURTEENTH under ATDD-skip-trace-WAIVED co-application. First infrastructure-security class trace-WAIVED. Four artefacts authored + sync-gate exit 0 green + bash -n exit 0 on 4 new scripts + modified entrypoint.sh. CR-forecast envelope 6–9 iter fix-chain per iter-151/154/155 equation. Budget: ~25K tokens.
- [x] iter-158: `/bmad-dev-story` Story 2.3 landed — FR14n state `atdd-scaffolded → in-dev`; sprint-status `ready-for-dev → review`. All 13 tasks / ~50 subtasks in a single iteration. 11 new files + 11 modified. Sync-gate protocol executed cleanly (placeholder → `aad16a51…` → exit 0 green). 12 Dev-agent Guardrails all ✅. SC-10 ONE consolidated `INV-devbox-egress-contract`. SC-3 JSONL schema embedded verbatim in invariant doc. Non-obvious decision: nftables chain-scope via `meta nfproto != <family> accept` first-rule short-circuit. Budget: ~70K tokens.
- [x] iter-157: ATDD-skip applied — Story State `validated → atdd-scaffolded`. Thirteenth cumulative Epic ATDD-skip precedent; third Epic 2; first infrastructure-security class. Budget: ~10K tokens.
- [x] iter-156: `/bmad-create-story (args: "review")` pre-dev SM validation landed. 5 PATCH + 1 DEFER + 6 DISMISS against v1.0 draft. Budget: ~55K tokens.
- [x] iter-155: `/bmad-create-story` Story 2.3 exhaustive-context-engine draft landed. 5 ACs + 17 scope-clarifications + 13 Tasks (~50 subtasks).

## Context

- **Phase:** 4-implementation — Epic 2 at 2/17 stories `done` (2.1 iter-144 + 2.2 iter-154) + 1/17 `review` + `sm-verified` (2.3; SM-verified iter-160).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Story 2.3 live smokes (Task 12.1 – 12.8) operator-workstation deferred; SM review EXPLICITLY ACCEPTED the deferral as non-AC-blocking per `/bmad-create-story (args: "review")` adjudication at iter-160.
- **Baked image:** `keel-devbox:local` (iter-123 first bake; 848 MB, linux/arm64). Story 2.3 Task 1 appended `dnsmasq` + `nftables` → re-bake needed at operator-workstation close-out.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; 2.1 + 2.2 done; 2.3 `review` + `sm-verified` (iter-160); 2.4..2.17 in `backlog`.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2; PR #230 transitions to Open at Story 2.17 completion).
- **Story:** 2.3 — egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.
- **Story File:** `_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md` (v1.5 at iter-160; SM-verified; Status `review`).
- **Story State:** `sm-verified` — SM verification landed iter-160 ZERO-PATCH; next transition is `sm-verified → fixes-pending` (default, adversarial-triage) or `sm-verified → done` (ZERO-PATCH close variant) via `/bmad-code-review (args: "2")` CR opener.
- **GitHub Issue:** Story 2.3 → #43; Epic 2 → #10.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (stays Draft across Epic 2).

## Notes

- **DinD is fork-time substrate, not transitional.** `INV-devbox-dind-available` — every fork's cc-devbox-equivalent must provide Docker. Story 2.3 live smokes are operator-workstation deferred; SC-7 verbatim + AC-mapped `docker exec` recipes pinned in `docs/invariants/devbox-egress.md § Verification` + `packages/devbox/README.md § Egress policy § Verification` for the operator close-out.
- **Backend B is the reference env at 2026-04-21.** Broad-state-mutation scripts MUST detect backend + refuse destructive ops by default.
- **NFR2 authority unchanged.** Cold ≤ 300s / warm ≤ 30s remains authoritative on M4-Pro native; DinD runs are indicative only.
- **Cumulative Epic-2 CR metrics (Stories 2.1 + 2.2):** 2.1 = 9 patches across 3 gates (16-iter fix-chain); 2.2 = 2 patches across 1 gate (4-iter fix-chain). Story 2.3 forecast: 6–9 iter fix-chain likely (0-carve-out + backend-B live-smoke defer + ~650 LOC impl).
- **iter-160 SM outcome:** ZERO-PATCH + ZERO-CARVE-OUT-with-operator-workstation-defer-acknowledgment variant. Second Epic 2 post-dev SM precedent; first infrastructure-security class SM-verified. **Lesson** — three-layer parallel Sonnet subagent adjudication (AC-by-AC + SC-10 + scope-isolation) is the right fan-out for post-dev SM verification on an infrastructure-security class story; convergence across three independent fresh contexts strengthens the ZERO-PATCH verdict. Operator-workstation-defer-acknowledgment is the distinguishing axis from Story 2.2's pure ZERO-CARVE-OUT-ZERO-PATCH close — the SM review accepts runtime-smoke deferral on the grounds that the ACs are substrate commitments + `docker exec` recipes are pinned verbatim for operator close-out (iter-158 pre-commit pin closes the Story 2.1 iter-144 / Story 2.2 iter-148 gap of deferring without pinning commands).
