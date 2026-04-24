# Implementation Plan

## NOW

- [ ] **Story 2.15 `/bmad-create-story (args: "review")` pre-dev SM** (`drafted → validated`). Iter-295 landed `/bmad-create-story` — Story State is now `drafted` with ~286-line story file at `_bmad-output/implementation-artifacts/2-15-committed-claude-settings-json-with-deny-allow-permission-policies.md` (7 ACs + 6 Tasks + "Scope boundaries" § Dev Notes subsection enumerating 8 deferred items with Story 2.16/2.17 forward-refs). Per § Story Lifecycle Decision Matrix row `drafted`: invoke `/bmad-create-story (args: "review")` — pre-dev validation of readiness. Forecast per RALPH.md iter-295 signpost: 1-3 PATCH concentrated on AGENTS.md H3 length + cross-ref density + CLAUDE.md two-bullet wording (JSON portion is zero-judgment verbatim from epics.md AC 2/3; doc-heavy stories carry higher pre-dev SM band per iter-281 LESSON, BUT Story 2.15 is narrower than 2.13/2.14 in file count, so lower end of band). Two-subagent pattern (iter-235/iter-288) sufficient for this narrow surface; four-subagent (iter-281) only if Ralph judges doc-density-risk-class re-triggers at sizing.

## QUEUE (Story 2.15 lifecycle + 2.16..2.17 substrate queue)

- [ ] _(after Story 2.15 validated)_ Story 2.15 `/bmad-testarch-atdd` — likely SKIP-WITH-GROUNDS-(ii) single-ground waiver per iter-295 forecast (FIRST single-ground precedent in the 24-chain; watch for META guard firing if post-dev SM suggests grounds-(ii) alone insufficient — fall back to (ii)+(iii) in that case). Would be 25th cumulative ATDD-skip precedent.
- [ ] _(after Story 2.15 atdd-scaffolded)_ Story 2.15 `/bmad-dev-story` — JSON authoring + 3 doc touches + 1 seed + sprint-status flip; forecast single-iter landing (no novel surface; no invariant doc; no manifest entry).
- [ ] _(after Story 2.15 in-dev)_ Story 2.15 `/bmad-testarch-trace (args: "yolo")` — likely WAIVED outcome per Story 2.14 precedent (configuration-only delta; ACs 1-4 + 7 substrate-covered by static smokes; AC 5 operator-workstation-deferred; AC 6 forward-ref to Story 2.16). Would be 25th cumulative trace-WAIVED precedent.
- [ ] _(after Story 2.15 traced)_ Story 2.15 `/bmad-create-story (args: "review")` post-dev SM (`traced → sm-verified`) — two-subagent pattern per iter-235/iter-270 LESSON; forecast 0-2 PATCH per iter-270 drift-band re-baseline (post-dev SM narrower when pre-dev SM absorbs substantive findings).
- [ ] _(after Story 2.15 sm-verified)_ Story 2.15 `/bmad-code-review (args: "2")` CR — three-layer adversarial fan-out (Blind + Edge Case + Acceptance Auditor) per iter-271/iter-277/iter-294 pattern; forecast 0-2 PATCH (narrow diff; bundled close per iter-264/iter-294 precedent if fixes are trivial cross-doc lockstep prose edits).
- [ ] _(after Story 2.15 done)_ Story 2.16 Claude PreToolUse hooks for secret-file denylist — full lifecycle (drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done). Story 2.16 adds `.claude/hooks/block-secret-access.sh` + `hooks` block registration in `.claude/settings.json` + `INV-claude-hook-secret-denylist` manifest entry + N=3 halt-threshold wiring.
- [ ] _(after Story 2.16 done)_ Story 2.17 hook-settings bypass-resistance + Epic 2 SC-17 close-out polish pass. SC-17 reconciliation absorbs cumulative **47 DEFERs at iter-294 Story 2.14 CR landing** (31 pre-CR + 16 iter-294 CR additions) PLUS Stories 2.15..2.16 accrued DEFERs.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured; `statusCheckRollup: []` carried unchanged iter-219..295).

## BLOCKED

_(none — Story 2.15 drafted cleanly at iter-295; no push-transport or prereq issues encountered.)_

## ATDD Red Phase

_(none — Story 2.14 ATDD-skipped at iter-289 with grounds-(ii)+(iii); Story 2.15 ATDD forecast to skip with grounds-(ii) at iter-297. No red-phase tests owed.)_

## DONE (iter-295 `/bmad-create-story` — Story State `_(no story) → drafted`)

- [x] iter-295: **STORY 2.15 DRAFTED** (`_(no story) → drafted`). Routine drafting iter per iter-280 Story 2.13 pattern — no novel lesson produced. Story file `2-15-committed-claude-settings-json-with-deny-allow-permission-policies.md` authored at 286 lines with 7 ACs (committed `.claude/settings.json` + 13-entry deny + 6-entry allow + gitignore-verify + permission-prompt session behaviour + Ralph-path forward-ref to Story 2.16 + keel-templates seed) + 6 Tasks (JSON authoring with copy-ready content + `.gitignore` verification-only + AGENTS.md H3 honour-system + CLAUDE.md bullet touch + packages/devbox/README.md H2 pointer + packages/keel-templates/src/seeds/.claude/settings.json byte-identical seed). Scope-boundary discipline: "Scope boundaries — what Story 2.15 does NOT ship" § Dev Notes subsection enumerates 8 deferred artifacts (hook scripts / `hooks` block / manifest entry / INVARIANTS.md H3 / `docs/invariants/claude-hook-denylist.md` / halt wiring / S4 rules / content-hash bypass-resistance) with Story 2.16/2.17 forward-refs. Sprint-status row `2-15-…: backlog → ready-for-dev`; `last_updated:` flipped + history comment appended. NFR5a mapping explicit in Dev Notes § NFR5a mapping (13-entry deny covers Read + Bash axes; Write-path axis is Story 2.16 hook-based defense). Commit candidate: `docs(story-2-15): iter-295 /bmad-create-story — _(no story) → drafted; 7 ACs + 6 Tasks; scope-boundary § Dev Notes subsection as first-class asset`.

_(iter-287..294 Story 2.14 full lifecycle pruned per Guardrail 2; full detail in commit trail + RALPH.md signposts + story-file Change Log.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **14/17 stories done** (2.1-2.14) + 2.15 DRAFTED at iter-295 + 2.16-2.17 backlog.
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live smokes operator-workstation-deferred.
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:121). Host-side shim count: **18** at iter-295 (unchanged — drafting iter).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **14 done** (2.1-2.14); **1 ready-for-dev** (2.15); **2 backlog** (2.16-2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.15 — Committed `.claude/settings.json` with deny/allow permission policies.
- **Story File:** `_bmad-output/implementation-artifacts/2-15-committed-claude-settings-json-with-deny-allow-permission-policies.md`
- **Story State:** `drafted` — next iter invokes `/bmad-create-story (args: "review")` pre-dev SM per § Story Lifecycle Decision Matrix row `drafted`.
- **GitHub Issue:** Story 2.15 issue unknown; `RALPH_ISSUE_NUMBER` unset (no GitHub Project configured for this repo). Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` unchanged iter-272..295).

## Notes

- **iter-295 observation (scope-boundary as first-class story asset):** Story 2.15 introduces a "Scope boundaries — what Story 2.15 does NOT ship" § Dev Notes subsection enumerating 8 deferred artifacts with forward-refs. Sharper than Story 2.14's scattered "Story 15b.1 owns execution" prose. Pattern candidate for Stories 2.16/2.17 and any future trio-scope-boundary gymnastics. If post-dev SM + CR validate this discipline, promote to § Lessons at Story 2.17 close-out. Documented at RALPH.md § Signposts iter-295.
- **iter-295 observation (narrower-than-2.14 doc-story precedent):** Story 2.15 drafting surface is narrower than Story 2.14 (no invariant doc + no manifest entry + no INVARIANTS.md append). This is the first Epic-2 story where the dev-pass produces NO `packages/keel-invariants/` manifest edit. Downstream implication: Story 1.9 sync-gate has nothing to verify at Story 2.15 landing — the `pnpm keel-invariants:check` GREEN check is unchanged at 34 entries. Story 2.16 will re-introduce a manifest entry (+1 → 35); Story 2.17 may expand the Story 2.16 entry's coverage (same entry; new contentHash only).
- **iter-294 observation (bundled close precedent reinforced):** Story 2.14 CR PATCH-2 bundled close matches iter-264 Story 2.11 PATCH-1 bundled close pattern — controlling factor is `fix narrowness + convergent reviewer signal`, not PATCH count. Carry-forward for Story 2.15 CR if fixes are trivial cross-doc lockstep prose edits (pre-dev SM / post-dev SM may still prefer fixes-pending multi-iter path for complex fixes).
- **Cumulative DEFER forecast for Stories 2.15..2.17 Epic-2 close-out:** 47 pending at iter-294 carry-forward. Story 2.15 forecast adds 0-4 accruals (narrow surface; scope-boundary discipline pre-answers most "why wasn't X landed?" polish-class findings). Story 2.16 + 2.17 remaining accruals unknown. Absorption at Story 2.17 SC-17 close-out.
- **iter-292 NOVEL LESSON (narrower-grounds trace-WAIVED precedent) carry-forward:** Story 2.14 applied grounds-(ii)+(iii) dropping (c). Story 2.15 ATDD forecast extends to grounds-(ii) alone (FIRST single-ground waiver in the 24-chain if it holds) — watch for META guard firing at iter-297.
- **iter-291 NOVEL LESSON (initial-connection fetch-timeout budget under post-outage recovery) carry-forward:** default 120s `timeout` wrapping `git fetch` INSUFFICIENT; 240s required. Story 2.15 iter-296 (pre-dev SM) expected not to require network fetches; LESSON retains readiness posture for any transient surface that emerges.
