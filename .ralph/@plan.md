# Implementation Plan

## NOW

- [ ] Re-run `/bmad-code-review (args: "2")` — Story 2.12 closure re-run #2 (`fixes-pending → done | fixes-pending` per § Story Lifecycle Decision Matrix). Diff scope: iter-278 PATCH-6 landing only (`HEAD~1..HEAD` = `packages/devbox/entrypoint.sh` rc-capture rewrite + comment block rewrite + absorbed iter-277 DEFERs; spec + deferred-work + IP + RALPH.md cosmetic). Forecast ZERO-PATCH per iter-264 LESSON Story 2.6/2.11 multi-pass CR cycle (single-region rewrite convergence); iter-277 already surfaced + triaged the underlying bash `||`-LHS mechanism class. Three-layer Ralph-hosted adversarial fan-out (Blind Hunter `general-purpose` diff-only + Edge Case Hunter `general-purpose` diff+project-read + Acceptance Auditor `bmad-agent-architect` Winston diff+spec+context) pattern — no deviation.

## QUEUE (Story 2.12 closure re-run #2 outcome paths)
- [ ] _(if iter-279 ZERO-PATCH: Story State `fixes-pending → done`)_ Flip sprint-status row Story 2.12 `review → done`, commit + push, advance QUEUE. Per iter-258 Story 2.11 precedent, sprint-status row flips to `done` only at CR closure with ZERO remaining PATCHes. Auto-advances to Story 2.13 row `backlog → ready-for-dev` via next-iter `/bmad-create-story` when QUEUE reaches it.
- [ ] _(if iter-279 lands ≥1 PATCH: Story State stays `fixes-pending`)_ Land each PATCH in its own iteration per Guardrail 5; re-run `/bmad-code-review (args: "2")` as closure re-run #3. Budget ceiling per iter-264 LESSON: TWO closure re-runs at worst case for Story 2.6/2.11 precedent — iter-279 would be re-run #2, a third closure re-run would exceed precedent band and warrant ultrathink diagnostic.
- [ ] _(after Story 2.12 done)_ Stories 2.13..2.17 — full-lifecycle iteration through 5 remaining substrate stories (healthcheck 2.13 + legacy branch retention 2.14 + committed settings 2.15 + hooks 2.16 + bypass-resistance 2.17). Each story full lifecycle; no cross-epic transitions until Epic 2 final story (2.17) completes.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured at 2026-04-24 per iter-219..278 confirmation; iter-278 orient `gh pr view` GREEN — no HTTPS :443 timeout this iter; push via SSH :22 expected clean; `statusCheckRollup: []` continues).

## BLOCKED

_(none — branch in sync with origin at iter-278 orient at `3eadcff`.)_

## ATDD Red Phase

_(none — iter-267 ATDD-skip-with-grounds-(c)+(ii)+(iii) per FR14n; 22nd-cumulative ATDD-skip precedent. Impl-time smokes at iter-268 dev-story cover ACs 1-3; ACs 4-5 operator-workstation-deferred.)_

## DONE (iter-278 Story 2.12 PATCH-6 LANDING — rc-capture subshell rewrite; closure re-run #1 findings drained)

- [x] iter-278: **STORY 2.12 PATCH-6 LANDED — `packages/devbox/entrypoint.sh:141-211` rewritten to rc-capture subshell pattern per Fix option A; 2 iter-277 DEFERs absorbed.** Single NOW task per Guardrail 5.

  - **Mechanism:** replaced the PATCH-3 `( ... ) || diagnostic` shape (empirically disconfirmed at iter-277 — bash(1) `||`-LHS rule recursively suppresses errexit inside the subshell even under explicit `set -e` re-enable / `if !` form / `shopt -s inherit_errexit`) with the canonical `set +e; ( set -e; ... ); ssh_init_status=$?; set -e; [[ ${ssh_init_status} -ne 0 ]] && diag` pattern. Removes the `||` token → escapes `||`-LHS suppression → inner `set -e` actually scoped → pre-spawn failure no longer cascades into PATCH-4's `gosu dev rm -rf /home/dev/.ssh/host_keys` destructive wipe.

  - **Empirical verification in-iter:**
    - `bash -c 'set +e; ( set -e; false; echo X ); rc=$?; set -e; [[ $rc -ne 0 ]] && echo "DIAG rc=$rc"; echo OK'` → `DIAG rc=1\nOK` (failure path: AFTER-FALSE does NOT print; diagnostic fires; entrypoint continues).
    - Happy path `true; echo "inner work ran"` → `inner work ran\nOK rc=0` (happy path: no diagnostic; entrypoint continues).
    - Baseline PATCH-3 disconfirmation re-reproduced: `bash -c 'set -euo pipefail; ( false; echo X ) || echo Y'` → `X` (NOT Y); confirms iter-277 finding.
  - **bash -n syntax check:** GREEN on `packages/devbox/entrypoint.sh` post-edit.

  - **Comment block rewrite (L141-170):** replaced the PATCH-3 comment that claimed "subshell scopes `set -e` so a non-zero inner exit is swallowed by `|| <diagnostic>` at close" (materially false) with a block that (a) describes the actual rc-capture mechanism; (b) explains WHY `( ) || diag` doesn't work (bash(1) `||`-LHS recursive rule into subshells, explicit `set -e` re-enable, and `if !` form ALL fail); (c) references iter-277 spec § Review Findings § PATCH-6 empirical reproduction; (d) documents the PATCH-3 historical cascade (destructive `rm -rf host_keys` under keygen-failure path); (e) records operator-recovery cost under the old mechanism (`pnpm devbox:clean --with-volumes` wipes Claude/gh tokens). PATCH-4 inner comment block also rewritten to reference "immediately above" instead of brittle L155 line-number.

  - **Absorbed iter-277 DEFERs:** (1) "Cosmetic — entrypoint.sh subshell body not re-indented" (Blind Hunter LOW) → subshell body re-indented +2 inside `(`, class-closed at Story 2.12 landing; (2) "PATCH-4 comment line ref drift — claims mkdir at L155 but L155 is host_keys.tmp mkdir" (Blind Hunter LOW) → PATCH-4 comment rewritten to "immediately above" reference, line-pin drift class pre-emptively addressed. Both absorptions marked in story spec § Review Findings § iter-277 DEFER list + `deferred-work.md § iter-277 confirmation gate`. Remaining 7 iter-277 DEFERs carry to Story 2.17 close-out (unchanged scope).

  - **Non-edits / non-concerns:**
    - `entrypoint.sh` is NOT contentHash-tracked in `packages/keel-invariants/src/invariants.manifest.ts` (grep-confirmed: only `docs/invariants/devbox-ssh.md` entry at L289-294 has contentHash `946f1ac1…907029`, matching the file unchanged at iter-278).
    - `pnpm keel-invariants:check` carried GREEN from iter-276; no recompute needed.
    - Manifest entry count **32** unchanged.
    - Host-side shim count **18** unchanged (no shim edits this iter).
    - No sibling doc edits (`INVARIANTS.md` / `AGENTS.md` / `README.md` / `devbox-ssh.md`) — PATCH-6 is a code-internal mechanism fix, not a doc-spec change. `devbox-ssh.md` § Mechanism already describes the substrate contract at the correct abstraction level (port-publishing invariant + sshd + named-volume persistence); bash `set -e` propagation is an implementation detail below that.
    - Live container verification operator-workstation-deferred per Story 2.5 iter-186 posture (DinD backend B cannot safely exercise the rewritten cap_drop:[ALL] path; live smoke requires M4-Pro native Docker Desktop).

  - **Story State:** `fixes-pending → fixes-pending` (iter-277 closure re-run #1 queued PATCH-6; iter-278 lands PATCH-6; closure re-run #2 pending at iter-279). Sprint-status row UNCHANGED at `review` per iter-202 + iter-260 + iter-271 precedent. Cumulative Story 2.12 PATCH count = 5 (iter-271) + 1 (iter-277/278) = 6 — within iter-271 LESSON 4-7 PATCH band for novel-runtime-behaviour stories.

  - **Budget consumed:** ~40K tokens (orient ~8K + spec read ~4K + entrypoint read ~3K + Edit x5 including patch + comment block + defer absorptions + story Status line + IP + Change Log entry + bash empirical tests ~3K + commit-prep stacking ~18K). Well within ~117K execution budget; exit cleanly per Guardrail 12.

  - **PR:** #230 **Draft** — `statusCheckRollup: []` carries unchanged across iter-272..278; iter-278 orient `gh pr view 230` GREEN (no HTTPS :443 timeout this iter). Branch in sync with origin at `3eadcff`. Pre-push state: about to commit + push entrypoint.sh rewrite + story spec iter-278 updates + deferred-work defer-absorption notes + IP + RALPH.md update.

- [x] iter-277: **STORY 2.12 CR CLOSURE RE-RUN #1 LANDED** — `/bmad-code-review (args: "2")` (`fixes-pending → fixes-pending`; 1 PATCH (PATCH-6) + 9 DEFER + 3 DISMISS). Three-layer Ralph-hosted adversarial fan-out. See commit `3eadcff`. PATCH-6 now landed at iter-278.
- [x] iter-276: **STORY 2.12 PATCH-5 LANDED** — bash-array compose-args helper + 15-site refactor across 8 scripts. See commit `43b4e4b`.
- [x] iter-275: **STORY 2.12 PATCH-4 LANDED** — partial-keypair recovery via `rm -rf host_keys` before `mv -T`. See commit `820591a`. _(NOTE iter-278: PATCH-4's destructive cascade under PATCH-3's broken `set -e` is now resolved — PATCH-6 re-establishes errexit so the `rm` only reaches on keygen-success regen branch.)_
- [x] iter-274: **STORY 2.12 PATCH-3 LANDED** — subshell-wrap opt-in block for SC-10 non-fatal posture. See commit `0d83fae`. _(NOTE iter-278: PATCH-3's `( ) || diag` mechanism EMPIRICALLY DISCONFIRMED at iter-277; PATCH-6 at iter-278 rewrites to rc-capture pattern which actually propagates errexit.)_
- [x] iter-273: **STORY 2.12 PATCH-2 LANDED** — compose env via KEEL_DEVBOX_SSH_RESOLVED. See commit `1df64ab`.
- [x] iter-272: **STORY 2.12 PATCH-1 LANDED** — chmod under cap_drop via gosu dev. See commit `30b7d8d`.
- [x] iter-271: `/bmad-code-review (args: "2")` — `sm-verified → fixes-pending`; 5 PATCH + 11 DEFER + ~10 DISMISS. See commit `a777224`.

_(iter-253..270 Story 2.10/2.11/2.12 closure + Story 2.12 drafting/pre-dev-SM/ATDD/dev-story/trace-gate/post-dev-SM iters pruned per Guardrail 2.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **11/17 stories done** (2.1-2.11) + 1/17 fixes-pending (2.12, all 6 PATCHes LANDED at iter-278; closure re-run #2 at iter-279 forecast ZERO-PATCH) + 5/17 backlog (2.13..2.17).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live fresh-fork first-run smokes operator-workstation-deferred; substrate smokes covered through iter-278 (entrypoint.sh bash -n GREEN; `pnpm keel-invariants:check` GREEN at `946f1ac1…907029`; bash empirical rc-capture verification GREEN both failure + happy paths).
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:120). Host-side shim count: **18** at iter-278 (unchanged — PATCH-6 edited existing entrypoint.sh, no shim count change).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **11 done** (2.1-2.11); 1 fixes-pending-CR (2.12); 5 backlog (2.13..2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.12 — Loopback-bound port publication + opt-in `KEEL_DEVBOX_SSH` sshd
- **Story File:** `_bmad-output/implementation-artifacts/2-12-loopback-bound-port-publication-opt-in-keel-devbox-ssh-sshd.md`
- **Story State:** `fixes-pending` — PATCH-1..5 LANDED iter-272..276; iter-277 CR re-run #1 queued PATCH-6 (4-of-4 convergent + empirical bash disconfirmation of Winston ZERO-PATCH verdict); iter-278 LANDED PATCH-6 (rc-capture rewrite + comment block rewrite + 2 DEFER absorptions); iter-279 closure re-run #2 forecast ZERO-PATCH.
- **GitHub Issue:** Story 2.12 issue unknown; `RALPH_ISSUE_NUMBER` unset at iter-278 orient. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` carried unchanged iter-272..278; iter-278 orient `gh pr view 230` GREEN).

## Notes

- **iter-278 meta-observation (PATCH-6 landing pattern — DEFER absorption discipline):** a PATCH that re-touches a region with queued cosmetic DEFERs should ABSORB those DEFERs into the patch rather than leaving them for Story 2.17 close-out. Iter-278 absorbed 2 iter-277 DEFERs (subshell body indent + PATCH-4 comment line-pin drift) because the rc-capture rewrite reformatted that region anyway. Saves a downstream edit pass; reduces Story 2.17 SC-17 polish surface. Reaffirmed iter-278; formalise as a Ralph convention when next patch re-touches a DEFERred region.
- **iter-277 NOVEL LESSON #1 carry-forward (bash subshell `||`-LHS errexit suppression is recursive):** `( ... ) || diag` does NOT scope `set -e` in bash 5.2. Four broken forms: `( ) || diag`, `( set -e; ) || diag`, `if ! ( ) ; then diag; fi`, `shopt -s inherit_errexit; ( ) || diag`. Only `bash -c '...' || diag` subprocess and `set +e; (set -e; ...); rc=$?; set -e` rc-capture patterns work. iter-278 verified both the diagnosis AND the canonical fix empirically. Generalises to ALL future Story 2.13..2.17 / Epic 6 / Epic 13 "wrap risky block for non-fatal posture" patterns.
- **iter-277 NOVEL LESSON #2 carry-forward (META — empirical disconfirmation of Acceptance Auditor):** when an Auditor verdict CONTRADICTS Blind+Edge convergent finding on a runtime-semantics question, FAVOUR the convergent finding + RUN AN EMPIRICAL TEST before triaging. iter-278 PATCH-6 landing is the CONSEQUENCE of this LESSON firing at iter-277. Generalises: future CR findings on `set -e` scope, signal handling, race conditions, IPC ordering MUST have in-iter empirical reproduction before the Auditor verdict overrides Blind/Edge.
- **iter-276 NOVEL LESSON carry-forward (hazard-class discrimination under word-splitting):** `${VAR:+-f "${VAR}"}` alt-value expansion re-tokenises by word-splitting BEFORE embedded double-quote chars re-parse. AR-9 citation removed at iter-276 PATCH-5 landing; compose-args helper threaded across 15 sites idiomatically.
- **iter-276 observation carry-forward (contentHash edit cost model):** editing a contentHash-tracked source forces a 4-step cost (edit → sha256sum → manifest patch → `pnpm --filter @keel/keel-invariants build` → `pnpm keel-invariants:check`). iter-278 did NOT touch any contentHash-tracked source (entrypoint.sh is NOT tracked; only `docs/invariants/devbox-ssh.md` is).
- **iter-275 / 274 observations:** GNU `mv -T` over non-empty target dir refuses (rm-then-mv recovery is idiomatic); subshell-wrap-with-`||`-diagnostic was formerly considered canonical NON-FATAL pattern under `set -euo pipefail` — REVISED at iter-277: the canonical pattern is the rc-capture form, NOT `(...) || diag` (the latter silently breaks errexit propagation per iter-277 NOVEL LESSON #1). iter-278 LANDED the correction.
- **iter-273 NOVEL LESSON carry-forward (compose env-propagation sites are normalisation chokepoints):** any `docker-compose.yml` env var sourced from `.envrc` via `${VAR:-default}` MUST source the RESOLVED host-side value when a case-folding resolver exists.
- **iter-272 LESSON carry-forward (orient-time PATCH order decision framework):** evaluate (a) verification-bar parity, (b) Guardrail 5 clean-ness, (c) downstream reduction, (d) independence. iter-277+278 confirms linear PATCH-1..5 → PATCH-6 order was correct (PATCH-6 emerged at re-run, downstream of PATCH-3 + PATCH-4 landing — could not have been forecast at iter-272).
- **iter-271 NOVEL LESSON carry-forward (forecast band breach via novel-runtime-behaviour surface):** 4-7 PATCH band for novel-runtime-behaviour stories; Story 2.12 cumulative count: 5 + 1 = 6 (within band). iter-278 landing holds the cumulative count at 6; iter-279 re-run #2 at ZERO-PATCH would close the band cleanly.
- **iter-271 LESSON carry-forward (three-subagent pattern):** Blind / Edge / Auditor parallel-fan-out; convergence-signal-high-confidence-triage; iter-279 closure re-run #2 will re-use the SAME pattern. Pattern evolution from iter-277: three-subagent + empirical-test override when Auditor disconfirms Blind+Edge.
- **iter-270 NOVEL LESSON carry-forward (drift-band re-baseline):** substrate-citation drift BIMODAL — substantive 0-2 + mechanical 8-12 per dev-pass-touches-≥4-cited-files story. iter-278 added 0 new substantive (code-internal fix; no doc-spec change) — within band.
- **iter-264 LESSON carry-forward:** CR re-run DEFER-vs-PATCH severity-class-first; 0-3 first-class PATCH band for STATIC-SUBSTRATE stories; 4-7 band for NOVEL-RUNTIME-BEHAVIOUR stories. Story 2.12 cumulative 6 within band. iter-279 ZERO-PATCH re-run #2 would hold at 6.
- **iter-263 LESSON carry-forward:** SSH :22 / HTTPS :443 asymmetric recovery; iter-278 HTTPS :443 GREEN (no asymmetric recovery this iter).
- **iter-257 LESSON reaffirmed (no contentHash edit at iter-278):** no sync-gate recompute; `pnpm keel-invariants:check` GREEN carried from iter-276.
- **iter-244/246 audit-findings carry-forward:** restart.sh transitive-delegate; benchmark.sh OUT-OF-SCOPE (SC-11) threading compose-override; Manifest entry count **32** at iter-278 (unchanged).
- **Substrate-citation drift cumulative forecast for Stories 2.13..2.17:** ~5-12 cumulative substantive + ~40-60 cumulative mechanical drifts. SC-17 single reconciliation at Story 2.17 landing. Story 2.12 cumulative drift count post-iter-278: ZERO new substantive; 7 remaining iter-277 DEFERs queued for Story 2.17 close-out (iter-278 ABSORBED 2 of the original 9: cosmetic indent + line-pin drift).
