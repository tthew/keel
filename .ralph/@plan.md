# Implementation Plan

## NOW

- [ ] `/bmad-create-story (args: "review")` post-dev SM verification — FR14n `traced → sm-verified` (or `sm-fixes-pending`). Adjudicates the 5 SM-reviewed ACs vs Task 12.1 – 12.8 operator-workstation live-smoke deferral + SC-10 consolidated-invariant consistency + scope-isolation vs Stories 2.4/2.5/2.6/2.13/Epic 4. **First Epic-2 infrastructure-security class SM-verification post-trace** — ZERO-CARVE-OUT-with-operator-workstation-defer-acknowledgment variant. Expected ZERO-PATCH (mirrors Story 2.2 iter-150 ZERO-CARVE-OUT-ZERO-PATCH precedent when no new-class concerns arise; infrastructure-security AC adjudication may add one ENHANCEMENT-level wording drift on the SC-5 fallible-seam residual-risk acknowledgment language). Budget: ~35K tokens.

## QUEUE (Story 2.3 lifecycle — mid-flight, post-trace)

- [ ] _(post-Story-2.3-sm-verified)_ `/bmad-code-review (args: "2")` — CR gate opener. Forecast envelope per iter-151/154/155 equation (0-carve-out + backend-B live-smoke defer (+3) + ~650 LOC impl (+6) → 6–9 iter fix-chain projected); LOOSER than Story 2.2's 4-iter + TIGHTER than Story 2.1's 16-iter. First Epic-2 infrastructure-security class CR; three-layer Ralph-hosted adversarial fan-out (Blind Hunter + Edge Case Hunter + Acceptance Auditor) against cumulative Story 2.3 substrate diff filtered to in-scope files (exclude `_bmad-output/` + `.ralph/` + `RALPH.md` + `_bmad/` per Story 2.2 iter-154 pattern with `:(exclude)<path>` long-form).
- [ ] _(conditional, post-Story-2.17 done)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion.
- [ ] _(conditional, post-Epic-2 merged)_ § Cross-epic transition → Epic 3 Story 3.1 OR halt EPIC_DONE awaiting merge.

## BLOCKED

_(none — Story 2.3 trace landed iter-159 WAIVED; sync-gate green; no carry-forward blockers from Story 2.2 CR closure.)_

## ATDD Red Phase

_(none — ATDD-skipped at iter-157; no red-phase failures to carry.)_

## DONE (current story 2.3 lifecycle)

- [x] iter-159: **`/bmad-testarch-trace (args: "yolo")` WAIVED — FR14n state `in-dev → traced`.** THIRTEENTH cumulative Epic trace-WAIVED precedent; FOURTEENTH under the ATDD-skip-trace-WAIVED co-application rule. First infrastructure-security class trace-WAIVED (2.1 pure runtime-infrastructure; 2.2 hybrid infrastructure-smoke + configuration-surface; 2.3 introduces daemon + kernel-rule + atomic-reload + JSONL log-tailer idiom). Four artefacts in `_bmad-output/test-artifacts/traceability/`: coverage-matrix JSON (5 P2 ACs; 0% automated; STRONG substrate evidence per-AC), e2e-trace-summary JSON (schema-v1 portable), gate-decision JSON (WAIVED verdict), markdown trace report. Structural inheritance from Story 2.2 iter-149 template ~95%. **Live substrate re-verification at iter-159:** sync-gate exit 0 green (20 manifest entries valid including new INV-devbox-egress-contract contentHash `aad16a51aa1dc7527c0312e6b99217966d7f3f3478fb677dd347792e9cb6889b` locks consolidated invariant doc); bash -n exit 0 on all 4 new scripts + modified entrypoint.sh; all 5 ACs with STRONG template-level substrate evidence (file presence + content-signal greps + line-numbers + 3 invariant-anchor sites + compose cap_add + Dockerfile apt-append + dual-layer dnsmasq `address=/#/` + nftables `policy drop` + SC-13 resolv.conf pin + SC-5 atomic-reload verbatim + SC-3 6-field JSONL schema drift-locked). **Unlike Story 2.2 (zero carve-out), Story 2.3 inherits Story 2.1's operator-owned carve-out pattern** for runtime smokes: backend-B iteration-env kernel-nftables-privilege absence + bind-mount denial force Task 12.1 – 12.8 smokes (resolv.conf pin probe + `nft list chain` IPv4/IPv6 parity + positive/negative curl + atomic-reload preservation + JSONL round-trip + log-rotation) to operator workstation. SC-7 verbatim commands + AC-mapped `docker exec` recipes pinned at iter-158 in invariant doc + README for operator close-out. CR-forecast envelope 6–9 iter fix-chain per iter-151/154/155 equation. Story Status stays `review`; sprint-status unchanged (trace gate does NOT flip sprint-status). Budget: ~25K tokens.
- [x] iter-158: **`/bmad-dev-story` Story 2.3 landed — FR14n state `atdd-scaffolded → in-dev`; sprint-status `ready-for-dev → review`.** All 13 tasks / ~50 subtasks completed in a single iteration per Story 2.2 iter-148 precedent. 11 new files + 11 modified; sync-gate protocol executed cleanly (placeholder → actual `aad16a51…` → exit 0 green); 12 Dev-agent Guardrails all ✅; SC-10 ONE consolidated `INV-devbox-egress-contract`; SC-3 JSONL schema embedded verbatim in invariant doc. Non-obvious decision: nftables chain-scope via `meta nfproto != <family> accept` first-rule short-circuit. Budget: ~70K tokens.
- [x] iter-157: **ATDD-skip applied — Story State `validated → atdd-scaffolded`.** Thirteenth cumulative Epic ATDD-skip precedent; third Epic 2; first infrastructure-security class. Budget: ~10K tokens.
- [x] iter-156: **`/bmad-create-story (args: "review")` pre-dev SM validation landed.** 5 PATCH + 1 DEFER + 6 DISMISS against v1.0 draft. Budget: ~55K tokens.
- [x] iter-155: **`/bmad-create-story` Story 2.3 exhaustive-context-engine draft landed.** 5 ACs + 17 scope-clarifications + 13 Tasks (~50 subtasks).

## Context

- **Phase:** 4-implementation — Epic 2 at 2/17 stories `done` (2.1 iter-144 + 2.2 iter-154) + 1/17 `review` (2.3; traced iter-159).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Story 2.3 live smokes (Task 12.1 – 12.8) operator-workstation deferred.
- **Baked image:** `keel-devbox:local` (iter-123 first bake; 848 MB, linux/arm64). Story 2.3 Task 1 appended `dnsmasq` + `nftables` → re-bake needed at operator-workstation close-out.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; 2.1 + 2.2 done; 2.3 `review` (traced iter-159); 2.4..2.17 in `backlog`.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2; PR #230 transitions to Open at Story 2.17 completion).
- **Story:** 2.3 — egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.
- **Story File:** `_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md` (v1.4 at iter-159; trace landed WAIVED; Status `review`).
- **Story State:** `traced` — trace landed iter-159 WAIVED; next transition is `traced → sm-verified` (or `sm-fixes-pending`) via `/bmad-create-story (args: "review")` post-dev SM verification.
- **GitHub Issue:** Story 2.3 → #43; Epic 2 → #10.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (stays Draft across Epic 2).

## Notes

- **DinD is fork-time substrate, not transitional.** `INV-devbox-dind-available` — every fork's cc-devbox-equivalent must provide Docker. Story 2.3 live smokes are operator-workstation deferred; SC-7 verbatim + AC-mapped `docker exec` recipes pinned in `docs/invariants/devbox-egress.md § Verification` + `packages/devbox/README.md § Egress policy § Verification` for the operator close-out.
- **Backend B is the reference env at 2026-04-21.** Broad-state-mutation scripts MUST detect backend + refuse destructive ops by default.
- **NFR2 authority unchanged.** Cold ≤ 300s / warm ≤ 30s remains authoritative on M4-Pro native; DinD runs are indicative only.
- **Cumulative Epic-2 CR metrics (Story 2.1 + 2.2):** 2.1 = 9 patches across 3 gates (16-iter fix-chain); 2.2 = 2 patches across 1 gate (4-iter fix-chain). Story 2.3 forecast: 6–9 iter fix-chain likely (0-carve-out + backend-B live-smoke defer + ~650 LOC impl).
- **iter-159 trace outcome:** THIRTEENTH cumulative trace-WAIVED; FOURTEENTH cumulative ATDD-skip-trace-WAIVED pairing; first infrastructure-security class trace. Structural inheritance from Story 2.2 iter-149 template ~95%. Sync-gate exit 0 green; bash -n exit 0 on all 4 new scripts + entrypoint. Unlike Story 2.2 (zero carve-out), 2.3 inherits 2.1's operator-owned carve-out pattern for runtime smokes. **Lesson** — operator-workstation-defer-acknowledgment is the key SM-review adjudication for the forthcoming `traced → sm-verified` gate; the 5 SM-reviewed ACs must explicitly accept Task 12.1 – 12.8 deferral as non-AC-blocking + confirm SC-10 consolidated-invariant consistency + scope-isolation vs downstream stories.
