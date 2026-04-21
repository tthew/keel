# Implementation Plan

## NOW

- [ ] `/bmad-testarch-trace (args: "yolo")` — FR14n state `in-dev → traced` (or `trace-fixes-pending`). AC→test coverage gate + traceability matrix. **Fourteenth cumulative Epic-precedent under ATDD-skip-trace-WAIVED co-application rule** (11 Epic-1 + 3 Epic-2 prior: 2.1 iter-126 + 2.2 iter-149 + 2.3 iter-157-ATDD; this trace on 2.3 iter-159 closes the skip-trace pairing). Expected verdict WAIVED — zero test runner in tree (Epic 13 formal test-framework landing per PRD RS6); spec-declared SC coverage + 12 Dev-agent Guardrails + operator-workstation AC verification substitute. Live-smokes (Task 12.1 – 12.8) are backend-B operator-workstation deferred per v1.1 PATCH 4. Budget: ~15K tokens.

## QUEUE (Story 2.3 lifecycle — mid-flight, post-dev-story)

- [ ] _(post-Story-2.3-traced)_ `/bmad-create-story (args: "review")` post-dev SM verification — FR14n `traced → sm-verified`.
- [ ] _(post-Story-2.3-sm-verified)_ `/bmad-code-review (args: "2")` — CR gate opener. Forecast envelope per iter-151/154/155 equation (carve-out × 3 + live-AC-coverage × 3 + impl-surface-LOC / 100): 0-carve-out + backend-B live-smoke defer (+3) + ~650 LOC impl (+6) → 6–9 iter fix-chain projected; likely LOOSER than Story 2.2's 4-iter + TIGHTER than Story 2.1's 16-iter.
- [ ] _(conditional, post-Story-2.17 done)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion.
- [ ] _(conditional, post-Epic-2 merged)_ § Cross-epic transition → Epic 3 Story 3.1 OR halt EPIC_DONE awaiting merge.

## BLOCKED

_(none — Story 2.3 dev-story landed iter-158; 13/13 tasks done with full Dev-agent Guardrail compliance; sync-gate green; sprint-status flipped to `review`; no carry-forward blockers from Story 2.2 CR closure.)_

## ATDD Red Phase

_(none — ATDD-skipped at iter-157; no red-phase failures to carry into dev-story.)_

## DONE (current story 2.3 lifecycle)

- [x] iter-158: **`/bmad-dev-story` Story 2.3 landed — FR14n state `atdd-scaffolded → in-dev`; sprint-status `ready-for-dev → review`.** All 13 tasks / ~50 subtasks completed in a single iteration per Story 2.2 iter-148 precedent. 11 new files (`whitelist.default.txt`, `whitelist/{npm,anthropic,github}.txt`, `nftables/egress.nft`, `dnsmasq/dnsmasq.conf`, 4 scripts under `scripts/`, `docs/invariants/devbox-egress.md`) + 11 modified (Dockerfile apt-append, docker-compose.yml cap_add + TODO replacement, entrypoint.sh single hook, .envrc.example KEEL_DEVBOX_DNS_UPSTREAM knob, README.md § Egress policy, VERSIONS.md subsection, invariants.manifest.ts new entry, INVARIANTS.md anchor, sprint-status.yaml row flip + timestamp, story file Change Log v1.3 + Status + File List + Dev Agent Record, .ralph/@plan.md). Sync-gate protocol executed cleanly (placeholder → actual `aad16a51aa1dc7527c0312e6b99217966d7f3f3478fb677dd347792e9cb6889b` → exit 0 green). 12 Dev-agent Guardrails all ✅. SC-10 honoured — ONE consolidated `INV-devbox-egress-contract` invariant registered (not three split). SC-3 JSONL schema embedded verbatim in invariant doc per iter-156 PATCH 3 — contentHash locks the 6-field contract against drift. Backend-B live-smokes (Task 12.1 – 12.8) deferred to operator workstation with SC-7 verbatim commands + AC-mapped `docker exec` recipes pinned in README + invariant doc. **Non-obvious decision applied:** nftables chain-scope via `meta nfproto != <family> accept` first-rule short-circuit (not a policy-level filter). In `inet`-family tables with two chains hooked at identical priority, both chains evaluate every packet from both families — the scope-via-`meta nfproto` pattern the v1.1 draft implied would accidentally double-drop non-target-family packets via each chain's `policy drop`. Accept-fast first rule preserves per-chain family scope while SC-7 verbatim `grep -q 'policy drop'` assertion still passes. Budget: ~70K tokens (reads + 11 new files + 10 edits + sync-gate roundtrip + story-file close + sprint-status flip + commit + push).
- [x] iter-157: **ATDD-skip applied — Story State `validated → atdd-scaffolded`.** Thirteenth cumulative Epic ATDD-skip precedent. Third Epic 2; first "infrastructure-security class". Rationale pinned to ground (c) hybrid variant-(ii)+(iii). Budget: ~10K tokens.
- [x] iter-156: **`/bmad-create-story (args: "review")` pre-dev SM validation landed.** 5 PATCH + 1 DEFER + 6 DISMISS against v1.0 draft. Budget: ~55K tokens.
- [x] iter-155: **`/bmad-create-story` Story 2.3 exhaustive-context-engine draft landed.** 5 ACs + 17 scope-clarifications + 13 Tasks (~50 subtasks).

## Context

- **Phase:** 4-implementation — Epic 2 at 2/17 stories `done` (2.1 iter-144 + 2.2 iter-154) + 1/17 `review` (2.3 iter-158; sprint-status = review).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Story 2.3 live smokes operator-workstation deferred (backend-B iteration-context kernel-nftables-privilege absent + Docker Desktop bind-mount allow-list).
- **Baked image:** `keel-devbox:local` (iter-123 first bake; 848 MB, linux/arm64). Story 2.3 Task 1 appended `dnsmasq` + `nftables` apt packages → re-bake needed at operator-workstation close-out (Task 1.2 + 1.3 deferred version capture).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; 2.1 + 2.2 done; 2.3 `review` at iter-158; 2.4..2.17 in `backlog`.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2; PR #230 transitions to Open at Story 2.17 completion).
- **Story:** 2.3 — egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.
- **Story File:** `_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md` (v1.3 at iter-158; dev-story landed; Status `review`).
- **Story State:** `in-dev` — dev-story landed iter-158; next transition is `in-dev → traced` via `/bmad-testarch-trace (args: "yolo")`.
- **GitHub Issue:** Story 2.3 → #43; Epic 2 → #10.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (stays Draft across Epic 2).

## Notes

- **DinD is fork-time substrate, not transitional.** `INV-devbox-dind-available` — every fork's cc-devbox-equivalent must provide Docker. Story 2.3 live smokes are operator-workstation deferred; SC-7 verbatim + AC-mapped `docker exec` recipes pinned in `docs/invariants/devbox-egress.md § Verification` + `packages/devbox/README.md § Egress policy § Verification` for the operator close-out.
- **Backend B is the reference env at 2026-04-21.** Broad-state-mutation scripts MUST detect backend + refuse destructive ops by default (Story 2.1 `benchmark.sh` is the reference implementation).
- **NFR2 authority unchanged.** Cold ≤ 300s / warm ≤ 30s remains authoritative on M4-Pro native; DinD runs are indicative only.
- **Cumulative Epic-2 CR metrics (Story 2.1 + 2.2):** Story 2.1 = 9 patches across 3 gates (16-iter fix-chain); Story 2.2 = 2 patches across 1 gate (4-iter fix-chain). Story 2.3 forecast per iter-151/154/155 equation: 6–9 iter fix-chain likely (0-carve-out + backend-B live-smoke defer + ~650 LOC impl).
- **iter-156 SM pre-dev validation outcome:** 5 PATCH / 1 DEFER / 6 DISMISS against v1.0 draft; HIGH-severity finding = manifest schema drift (5-field, not 6).
- **iter-157 ATDD-skip outcome:** THIRTEENTH cumulative Epic ATDD-skip precedent; first infrastructure-security class.
- **iter-158 dev-story outcome:** single-iteration landing (Story 2.2 iter-148 precedent held); sync-gate green on first manifest-entry roundtrip; non-obvious nftables chain-scope correction recorded — `meta nfproto != <family> accept` first-rule short-circuit is the idiomatic pattern for two same-priority chains in an `inet` family table.
- **iter-158 validated patterns:** single-iter dev-story landing for ~650 LOC stories with heavy file proliferation (11 new files); sync-gate protocol for placeholder→actual contentHash capture (initial run with 64-zero placeholder surfaces the expected hash, paste, re-run → exit 0); per-file Change Log convention (Story 2.3 = newest-first v1.3 above v1.2 above v1.1; Story 2.2 = chronological-append).
