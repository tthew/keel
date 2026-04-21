# Implementation Plan

## NOW

- [ ] Run `/bmad-create-story` for Epic 2 Story 2.3 (dnsmasq + nftables egress policy; fail-closed). Per § Story Lifecycle Decision Matrix row `done`: Story 2.2 done at iter-154 + Epic 2 continuing (15 stories remain in backlog) + PR #230 stays Draft across Epic 2 → auto-advance within-epic to next backlog story without halt. Skill auto-flips `2-3-egress-policy-…: backlog → ready-for-dev` + `last_updated` + produces the story file. Budget: ~100K tokens per create-story convention (exhaustive-context-engine pattern per iter-145 Story 2.2 precedent).

## QUEUE (Story 2.3 lifecycle — begin)

- [ ] _(post-Story-2.3-draft)_ `/bmad-create-story (args: "review")` pre-dev SM validation — `drafted → validated`.
- [ ] _(post-Story-2.3-validated)_ `/bmad-testarch-atdd` — red-phase scaffolds OR ATDD-skip (thirteenth cumulative precedent if so — infrastructure-security class = nftables + dnsmasq sidecar).
- [ ] _(post-Story-2.3-atdd-scaffolded)_ `/bmad-dev-story (args: "{story_file_path}")` — `atdd-scaffolded → in-dev`.
- [ ] _(post-Story-2.3-in-dev)_ `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate; WAIVED precedent likely HOLDS (thirteenth cumulative).
- [ ] _(post-Story-2.3-traced)_ `/bmad-create-story (args: "review")` post-dev SM verification — `traced → sm-verified`.
- [ ] _(post-Story-2.3-sm-verified)_ `/bmad-code-review (args: "2")` — CR gate; ZERO-PATCH close OR `fixes-pending` + drain.
- [ ] _(conditional, post-Story-2.17 done)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge.
- [ ] _(conditional, post-Epic-2 merged)_ § Cross-epic transition → Epic 3 Story 3.1 OR halt EPIC_DONE awaiting merge.

## BLOCKED

_(none — Story 2.2 `done` at iter-154 with 4-iter fix-chain + ZERO-PATCH re-run close; Epic 2 advances to Story 2.3.)_

## DONE (Story 2.2 complete; full lifecycle iter-145..iter-154)

- [x] iter-154: **`/bmad-code-review (args: "2")` re-run — verdict `done`; Story State `fixes-pending → done`; 0 new PATCH + 1 new DEFER + 2 DISMISS (2 iter-151 PATCHes confirmed DRAINED; 4 iter-151 defers re-surfaced and HOLD).** **First Epic-2 post-fix-drain CR re-run closure** (vs Story 2.1 iter-144 first-ever Epic-2 ZERO-PATCH close precedent on third gate). Three-layer Ralph-hosted adversarial fan-out (Blind Hunter diff-only + Edge Case Hunter with repo-read + Acceptance Auditor with spec+context docs) against cumulative Story 2.2 substrate diff `ff8121a^..HEAD` filtered to 12 substrate files / 341-line delta. Raw: Blind 3 LOW after self-withdrawals + Edge 7 LOW + 1 MEDIUM + Auditor CLEAN on code + 2 spec-hygiene observations. Dedup → 15 raw → 9 unique. **Genuinely new DEFER:** `.envrc.local.example` manifest-description schema-companion asymmetry (cross-layer convergent blind+edge — strongest signal; carry to Story 2.16 or Epic 15a). **Re-surfaced iter-151 defers confirmed HOLD (4):** `12gg`/`unlimited` compose fallback → Story 2.6 preflight; `.envrc~`/whitespace regex escape → Epic 15a + Epic 13 Vitest; AC 5 argv=∅ no test pin → Epic 13; `127.0.0.1` hardcoded host_ip → Story 2.12. **DISMISS (2):** README "landed iter-148" annotation is CORRECT (Story 2.2 dev-story DID land iter-148; iter-151..154 are CR + fix-chain iterations); tmpfs knobs orphan BY DESIGN per AC 1 scope-clarification + inline "Active Story 2.5. Story 2.2 publishes the knob only." Auditor spec-hygiene applied in-commit as natural CR-closure housekeeping: flip v1.5 patch checkboxes `[ ]` → `[x]` at story:328-329; append v1.6 iter-152 AR-1 + v1.7 iter-153 AR-2 + v1.8 iter-154 CR closure Change Log entries. Live end-to-end smokes re-confirm both iter-151 PATCHes DRAINED: AR-1 (`/tmp/.envrc` regex match + stderr pointer + exit 1); AR-2 (allow-list-sentence narrowing + positive+negative smokes green). Scope-creep audit CLEAN; all 14 iter-151 defers HOLD under re-triage. Story-file Status `in-progress → done`; sprint-status `2-2-…: in-progress → done`; Story State `fixes-pending → done`. **Forecast-envelope validation:** iter-150 v1.4 SM projection landed on schedule at iter-154 (4-iter fix-chain: iter-151 opener + iter-152 AR-1 + iter-153 AR-2 + iter-154 re-run close; vs Story 2.1's 16-iter chain — **4× tighter envelope for hybrid infrastructure-smoke + configuration-surface class with ZERO operator-owned carve-out**). Deferred-work re-run section appended at `deferred-work.md § Re-run from: code review of story-2-2-envrc-parameterisation-contract (2026-04-21 iter-154)`. Budget: ~55K tokens (3 parallel subagents + triage + multi-file edits). Next: auto-advance within-epic to Story 2.3 via `/bmad-create-story` (no halt — PR stays Draft across Epic 2).

- [x] iter-153: AR-2 drained — `.envrc.local.example` off allow-list + contentHash `54ef4340… → e0c70aa4…` + sync-gate green + positive+negative smokes. Commit `f1f54b4`.
- [x] iter-152: AR-1 drained — `/tmp/fake.envrc → /tmp/.envrc` + contentHash `22448b33… → 54ef4340…` + sync-gate green + negative-smoke exit 1. Commit `1006dbf`.
- [x] iter-151: `/bmad-code-review (args: "2")` opener — 2 PATCH + 14 DEFER + 5 DISMISS; first Epic-2-infrastructure-smoke CR opener with only 2 patches (4.5× tighter than Story 2.1 iter-128). Commit `64ebdb3` + story v1.5.
- [x] iter-150: `/bmad-create-story (args: "review")` post-dev SM — verdict `sm-verified`; ZERO-PATCH + ZERO-CARVE-OUT. Commit `fefb6f5`.
- [x] iter-149: `/bmad-testarch-trace (args: "yolo")` WAIVED — twelfth cumulative Epic precedent. Commit `f349dd7`.
- [x] iter-148: `/bmad-dev-story` single-iteration landing (all 8 Tasks; AC 1–AC 5 green). Commit `ff8121a`.
- [x] iter-147: `/bmad-testarch-atdd` ATDD-SKIP — twelfth cumulative precedent. Commit `44e4ce2`.
- [x] iter-146: `/bmad-create-story (args: "review")` pre-dev SM — 9 fixes applied. Commit `cc9aee8` + story v1.1.
- [x] iter-145: `/bmad-create-story` produced exhaustive story file draft. Commit `fd03e1d`.

## Context

- **Phase:** 4-implementation — Epic 2 open at 2/17 stories done (2.1 iter-144 + 2.2 iter-154).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Story 2.3 is infrastructure-security (nftables + dnsmasq sidecar) — Docker substrate required for any runtime verification once dev-story lands; iteration-context bind-mount denial persists for workspace-mounted commands.
- **Baked image:** `keel-devbox:local` (iter-123 first bake; 848 MB, linux/arm64). Version matrix in `packages/devbox/VERSIONS.md § Bake log`.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; 2.1+2.2 done; 2.3..2.17 in `backlog`.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2; PR #230 transitions to Open at Story 2.17 completion).
- **Story:** _(no story)_ — Story 2.2 closed at iter-154; Story 2.3 draft queued for next iter.
- **Story File:** _(n/a until `/bmad-create-story` runs next iter)_.
- **Story State:** _(no story)_ — fresh start for Story 2.3 lifecycle per § Story Lifecycle Decision Matrix row `done → _(no story)_`.
- **GitHub Issue:** Flips to Story 2.3's issue once `/bmad-create-story` next iter updates sprint-status; parent Epic 2 → #10.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (stays Draft across Epic 2).

## Notes

- **DinD is fork-time substrate, not transitional.** `INV-devbox-dind-available` — every fork's cc-devbox-equivalent must provide Docker. Story 2.3's nftables/dnsmasq verification will exercise the daemon path.
- **Backend B is the reference env at 2026-04-21.** Broad-state-mutation scripts MUST detect backend + refuse destructive ops by default.
- **NFR2 authority unchanged.** Cold ≤ 300s / warm ≤ 30s remains authoritative on M4-Pro native; DinD runs are indicative only.
- **Cumulative Epic-2 CR metrics (Story 2.1 + 2.2):** Story 2.1 = 9 patches across 3 gates (16-iter fix-chain); Story 2.2 = 2 patches across 1 gate (4-iter fix-chain). **4× tighter envelope for hybrid-class + ZERO-carve-out stories vs multi-component-class + operator-carve-out stories.** Forecast equation per iter-151 lesson: (carve-out-count × 3) + (live-AC-coverage-at-trace ? 0 : 3) + (impl-surface-LOC / 100).
- **Validated patterns at iter-154:** Ralph-hosted three-layer CR fan-out + re-run ZERO-PATCH close (iter-154 second Epic-2 instance after iter-144); cross-layer convergent-finding adversarial signal (blind+edge at 100% agreement = strongest defect signal per iter-151 lesson, validated at iter-154 for `.envrc.local.example` asymmetry); forecast-envelope from (carve-out / AC-coverage / impl-surface) tuple (iter-150 projection landed exactly at iter-154); in-commit spec-hygiene housekeeping for CR-closure commits (flip checkboxes + append Change Log entries in same commit as closure, not as separate fix-drain iters).
