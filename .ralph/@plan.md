# Implementation Plan

## NOW

- [ ] `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md")` — FR14n state `atdd-scaffolded → in-dev`. Heavy iter expected: 11 new files (`packages/devbox/whitelist.default.txt`, `whitelist/{npm,anthropic,github}.txt`, `nftables/egress.nft`, `dnsmasq/dnsmasq.conf`, `scripts/{start-egress,reload-egress,egress-log-tailer,monitor}.sh`, `docs/invariants/devbox-egress.md`) + 6 modified files (`Dockerfile` apt-append, `docker-compose.yml` `cap_add` + TODO replacement, `entrypoint.sh` single hook, `.envrc.example` `KEEL_DEVBOX_DNS_UPSTREAM` knob, `README.md` § Egress policy, `VERSIONS.md` subsection) + invariant doc with embedded SC-3 JSONL schema verbatim + manifest entry (`InvariantSchema` 5-field: `id/description/sourcePath/contentHash/anchors` with backtick-ID anchor `INV-devbox-egress-contract` + bare 64-hex contentHash) + `INVARIANTS.md` anchor + sync-gate refresh. Budget likely ≥80K; may complete single-iter (Story 2.2 iter-148 precedent) OR split with `in-dev (partial)` marker. Live-smokes (Task 12.1 – 12.8) are backend-B operator-workstation deferred per v1.1 PATCH 4.

## QUEUE (Story 2.3 lifecycle — mid-flight)

- [ ] _(post-Story-2.3-in-dev)_ `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate; WAIVED precedent likely HOLDS (thirteenth cumulative Epic-precedent under ATDD-skip-trace-WAIVED co-application rule — Story 2.1 iter-126 + Story 2.2 iter-149).
- [ ] _(post-Story-2.3-traced)_ `/bmad-create-story (args: "review")` post-dev SM verification — `traced → sm-verified`.
- [ ] _(post-Story-2.3-sm-verified)_ `/bmad-code-review (args: "2")` — CR gate; forecast envelope per iter-151/154/155 equation (carve-out × 3 + live-AC-coverage × 3 + impl-surface-LOC / 100): 0-carve-out + backend-B live-smoke defer (+3) + ~600 LOC impl (+6) → 6–9 iter fix-chain projected; likely LOOSER than Story 2.2's 4-iter + TIGHTER than Story 2.1's 16-iter.
- [ ] _(conditional, post-Story-2.17 done)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion.
- [ ] _(conditional, post-Epic-2 merged)_ § Cross-epic transition → Epic 3 Story 3.1 OR halt EPIC_DONE awaiting merge.

## BLOCKED

_(none — Story 2.3 atdd-scaffolded at iter-157 via ATDD-skip; Epic 2 at 2/17 stories done + 1/17 atdd-scaffolded ready-for-dev-story; no carry-forward blockers from Story 2.2 CR closure.)_

## ATDD Decision (Story 2.3 iter-157 — thirteenth cumulative precedent)

- **Decision:** ATDD-skip via FR14n § Story Lifecycle Decision Matrix row `validated → atdd-scaffolded` — `/bmad-testarch-atdd` skill NOT invoked.
- **Grounds:** (c) hybrid variant-(ii)+(iii).
  - (ii) downstream integration-gate: Story 2.5 hardening re-verifies AC 1/2/4/5 in hardened context; Story 2.4 whitelist CLI exercises AC 4 atomic-reload primitive; Story 2.6 lifecycle CLI + Story 2.13 healthcheck exercise daemon posture; Epic 4 FR37 consumer hard-references SC-3 JSONL schema.
  - (iii) spec-declared adversarial coverage substitution: 17 pinned scope-clarifications (SC-1…SC-17) + 12 Dev-agent Guardrails + forthcoming `/bmad-code-review (args: "2")` Blind/Edge/Auditor fan-out substitute for red-phase scaffolds.
- **Preflight HALT confirmation:** zero test runner anywhere in tree — no `vitest.config.*`, `jest.config.*`, `playwright.config.*`, `cypress.config.*`, `pyproject.toml`, `go.mod`, `Gemfile`, `Cargo.toml`, `csproj`. Epic 13 is formal test-framework landing per PRD RS6.
- **Story class:** infrastructure-security (first Epic 2 security-surface story) — dnsmasq daemon + nftables kernel rules + file-locked atomic-reload + JSONL log-tailer, all outside the Vitest/Playwright idiom. Runtime verification (SC-7 `nft list chain` + AC 5 `curl`-unwhitelisted + AC 4 flock/nft -f transaction + AC 1 `/etc/resolv.conf` pin) is operator-workstation live-smoke (Task 12.1 – 12.8, backend-B deferred per v1.1 PATCH 4).
- **AC-by-AC coverage map:** AC 1 → SC-12/SC-13 + Task 12.1; AC 2 → SC-7 + Task 12.2 – 12.4; AC 3 → SC-2/SC-3/SC-4 + Task 12.5 – 12.7; AC 4 → SC-5 + Task 12.8; AC 5 → SC-12/SC-7 + Task 12.8.
- **Deliverable shape:** ONE Change Log v1.2 entry on the story file; NO test-plan artefact. Sprint-status unchanged. State transition `validated → atdd-scaffolded` recorded in § Context.

## ATDD Red Phase

_(none — ATDD-skipped; no red-phase failures to carry to dev-story.)_

## DONE (current story 2.3 lifecycle)

- [x] iter-157: **ATDD-skip applied — Story State `validated → atdd-scaffolded`.** Thirteenth cumulative Epic ATDD-skip precedent (11 Epic-1 + 2 Epic-2 prior → 2.3 is 13th); third Epic 2; first "infrastructure-security class". Rationale pinned to ground (c) hybrid variant-(ii)+(iii) — downstream Story 2.4/2.5/2.6/2.13 + Epic 4 FR37 integration-gates substitute for Vitest/Playwright red-phase (which don't exist pre-Epic-13 per PRD RS6), PLUS spec-declared adversarial coverage via 17 SCs + 12 Dev-agent Guardrails + forthcoming `/bmad-code-review` Blind/Edge/Auditor triage. AC-by-AC runtime-verification mapping recorded in § ATDD Decision. Story file Change Log v1.2 entry appended (newest-first order per file convention). RALPH.md Signposts updated (iter-157 entry). Sprint-status row UNCHANGED (ATDD-skip is FR14n Ralph-internal, does NOT flip sprint-status — only Change Log records the gate). Budget: ~10K tokens (3 file edits + commit + push). Commit trailer carries `Refs #43`.
- [x] iter-156: **`/bmad-create-story (args: "review")` pre-dev SM validation landed.** Four parallel fresh-context Sonnet subagents independently re-analysed sources; Ralph triage produced **5 PATCH + 1 DEFER + 6 DISMISS** against v1.0 draft. PATCHES applied (5): Task 10.3 manifest 5-field schema drift + anchor backtick-ID + contentHash bare-64-hex; Dev Notes user-account-timeline subsection; Task 10.2 doc structure pin + SC-3 verbatim-embed; Task 12.7 backend-B defer annotation; Dev-agent Guardrail 11 extended. Story Status remains `ready-for-dev`. Story file v1.1 Change Log entry + RALPH.md Decisions entry. Budget: ~55K tokens.
- [x] iter-155: **`/bmad-create-story` Story 2.3 exhaustive-context-engine draft landed.** Four parallel Sonnet subagents produced 5 ACs + 17 scope-clarifications + 13 Tasks (~50 subtasks). Three iter-155 guardrails pinned in RALPH.md Decisions. Sprint-status flip `2-3-…: backlog → ready-for-dev`.

## Context

- **Phase:** 4-implementation — Epic 2 at 2/17 stories `done` (2.1 iter-144 + 2.2 iter-154) + 1/17 `atdd-scaffolded` (2.3 iter-157; sprint-status = ready-for-dev).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Story 2.3 dev-story live smokes deferred to operator workstation (backend-B iteration-context kernel-nftables-privilege absent).
- **Baked image:** `keel-devbox:local` (iter-123 first bake; 848 MB, linux/arm64). Story 2.3 Task 1 appends `dnsmasq` + `nftables` apt packages → re-bake needed at dev-story close.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; 2.1 + 2.2 done; 2.3 atdd-scaffolded ready for dev-story; 2.4..2.17 in `backlog`.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2; PR #230 transitions to Open at Story 2.17 completion).
- **Story:** 2.3 — egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.
- **Story File:** `_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md` (v1.2 at iter-157; ATDD-skip Change Log entry appended; story Status still `ready-for-dev`).
- **Story State:** `atdd-scaffolded` — ATDD-skip landed iter-157; next transition is `atdd-scaffolded → in-dev` via `/bmad-dev-story`.
- **GitHub Issue:** Story 2.3 → #43; Epic 2 → #10.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (stays Draft across Epic 2).

## Notes

- **DinD is fork-time substrate, not transitional.** `INV-devbox-dind-available` — every fork's cc-devbox-equivalent must provide Docker. Story 2.3's nftables/dnsmasq entrypoint-init + live smokes exercise the daemon path; iteration-env lacks kernel-nftables privilege so Task 12.1 – 12.8 smokes are operator-workstation deferred.
- **Backend B is the reference env at 2026-04-21.** Broad-state-mutation scripts MUST detect backend + refuse destructive ops by default (Story 2.1 `benchmark.sh` is the reference implementation).
- **NFR2 authority unchanged.** Cold ≤ 300s / warm ≤ 30s remains authoritative on M4-Pro native; DinD runs are indicative only.
- **Cumulative Epic-2 CR metrics (Story 2.1 + 2.2):** Story 2.1 = 9 patches across 3 gates (16-iter fix-chain); Story 2.2 = 2 patches across 1 gate (4-iter fix-chain). Story 2.3 forecast per iter-151/154/155 equation: 6–9 iter fix-chain likely (0-carve-out + backend-B live-smoke defer + ~600 LOC impl).
- **iter-156 SM pre-dev validation outcome:** 5 PATCH / 1 DEFER / 6 DISMISS against v1.0 draft; HIGH-severity finding = manifest schema drift (5-field, not 6) — dev-agent MUST cite `InvariantSchema` verbatim when authoring manifest entries.
- **iter-157 ATDD-skip outcome:** THIRTEENTH cumulative Epic ATDD-skip precedent; first infrastructure-security class; ground (c) hybrid variant-(ii)+(iii); zero test runner preflight halts `/bmad-testarch-atdd` — precedent load-bearing through Epic 13 per iter-98 carry-forward.
- **Validated patterns at iter-157:** ATDD-skip shortcut for Epic 2+ infrastructure-class stories (iter-98 carry-forward); Change Log newest-first ordering in this story file (v1.2 above v1.1 above v1.0); sprint-status row NOT flipped on ATDD gate (FR14n Ralph-internal lifecycle).
