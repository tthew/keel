# Implementation Plan

## NOW

- [ ] **PATCH-5 fix task:** refactor 15 sites across 8 scripts (`build/rebuild/start/stop/status/clean/logs/benchmark.sh`) from unquoted `${VAR:+-f "${VAR}"}` to bash array idiom via NEW `packages/devbox/scripts/lib/compose-args.sh` helper. Crosses Story 2.6 AR-19 / Story 2.7 SC-14 deferred `_lib.sh` extraction threshold for the compose-args concern specifically. Update Story 2.12 Dev Notes DEFER-6 to remove misapplied AR-9 citation (different word-splitting hazard class). Larger refactor (~1 hour wall + smoke verification across all 8 shims); pre-budget per Guardrail 12 XL-task decomposition rule — may decompose into helper-create + per-shim-update sub-PATCHes.

## QUEUE (Story 2.12 fixes-pending → 1 PATCH remaining from iter-271 CR after PATCH-4 landed at iter-275)
- [ ] _(post-QUEUE-empty)_ **Re-run `/bmad-code-review (args: "2")`** for `fixes-pending → done | fixes-pending` confirmation gate. Per iter-264 LESSON Story 2.6 / 2.11 multi-pass CR cycle (Story ≥10-scripts-class), budget TWO closure re-runs at worst case. Forecast at re-run: 0-2 PATCH (CR-fix-introduced regression class — Story 2.6 iter-216 + 2.11 iter-264 precedents) + 0-3 LOW DEFER cosmetic carry-forwards.
- [ ] _(Stories 2.13..2.17)_ Iterate through full lifecycle — 5 remaining substrate stories spanning healthcheck (2.13) + legacy branch retention (2.14) + committed settings (2.15) + hooks (2.16) + bypass-resistance (2.17). Each runs full lifecycle; no cross-epic transitions until Epic 2 final story (2.17) completes.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured at 2026-04-24 per iter-219..273 confirmation; iter-274 re-verified `statusCheckRollup: []` at orient — push via SSH unaffected per iter-263 asymmetric-recovery LESSON).

## BLOCKED

_(none — branch in sync with origin at iter-275 orient at `0d83fae`; no SSH :22 carry-forward.)_

## ATDD Red Phase

_(none — iter-267 ATDD-skip-with-grounds-(c)+(ii)+(iii) per FR14n; 22nd-cumulative ATDD-skip precedent. Impl-time smokes at iter-268 dev-story cover ACs 1-3; ACs 4-5 operator-workstation-deferred.)_

## DONE (iter-275 Story 2.12 PATCH-4 LANDING — `fixes-pending` stays)

- [x] iter-275: **STORY 2.12 PATCH-4 LANDED — `packages/devbox/entrypoint.sh:176-187` partial-keypair recovery via `rm -rf host_keys` before `mv -T`.** Single surgical edit: inserted 10-line PATCH-4 rationale comment + `gosu dev rm -rf /home/dev/.ssh/host_keys` above the existing `gosu dev mv -T` at L187. Closes the `mv -T` "Directory not empty" abort path — when a prior keygen run was killed after writing only one of the two final key filenames to `host_keys/`, the outer `if` catches it (both-present short-circuits) and we re-enter the regenerate branch. The pre-PATCH mv refused to overwrite the non-empty target; under `set -e` inside the SC-10 subshell (landed iter-274) that abort fired the `||` diagnostic — sshd never started. `rm -rf` first clears any stray survivor; the mv then succeeds in BOTH fresh-fork (empty host_keys just mkdir'd at L155) and partial-keypair (non-empty host_keys) cases.
  - **Verification:** `bash -n packages/devbox/entrypoint.sh` syntax-clean (SYNTAX OK). `pnpm keel-invariants:check` GREEN (exit 0, zero output — no manifest drift; entrypoint.sh is NOT manifest-tracked, only `docs/invariants/devbox-ssh.md` is, and that file was not touched). Visual review at L170-188 confirms both rm + mv sit inside the regenerate branch guarded by the both-keys-check `if` at L170-171, and both are inside the SC-10 subshell landed iter-274 (open `(` at L151, close `) ||` at L199 unchanged by this edit).
  - **Independence from PATCH-3 confirmed at landing:** PATCH-3 (iter-274) is the OUTER halt-propagation fix (subshell swallows inner failures); PATCH-4 (iter-275) is an INNER correctness fix (make the specific mv succeed in the recovery scenario). Without PATCH-4, the recovery scenario still fails but now falls through the SC-10 `||` — operator sees sshd not listening + diagnostic + must manually `rm -rf /home/dev/.ssh/host_keys` inside the volume. With PATCH-4, the recovery is automatic. Orthogonal fixes, both needed.
  - **CR triage precedent honoured:** PATCH-4 is the fourth HIGH/MEDIUM-convergent fix from iter-271 triage, landed linearly after PATCH-1+2+3 per iter-272 orient-time decision. 4 of 5 PATCHes landed; PATCH-5 remaining then re-run CR.
  - **Commit footprint:** 1 file touched (`packages/devbox/entrypoint.sh`), +11 -0 lines (10 comment lines + 1 `gosu dev rm -rf` line). IP + commit alongside. Story file NOT touched per Guardrail 2 — PATCH progress stays in IP; story file updated comprehensively at CR re-run time per Story 2.11 iter-258 precedent.
  - **Next iter (iter-276):** PATCH-5 (compose-args.sh helper + 15-site refactor across 8 scripts) as sole NOW task per Guardrail 5. Per pre-budget concern flagged in NOW text, may decompose into helper-create + per-shim-update sub-PATCHes if budget forecast crosses 60K task estimate.
  - **Budget consumed iter-275:** ~18K tokens (orient ~8K + Edit ×2 IP + verification ~3K + commit ~7K). Well within ~117K execution budget; exit cleanly per Guardrail 12.
  - **PUSH STATUS:** branch in sync with origin at iter-275 orient (`0d83fae`); iter-275 push expected SSH :22 clean per iter-263 asymmetric-recovery + iter-268 keepalive LESSON. PR #230 has no CI configured (`statusCheckRollup: []` carries unchanged since iter-274); push is unblocked at any Story State.

- [x] iter-274: **STORY 2.12 PATCH-3 LANDED** — `packages/devbox/entrypoint.sh:140-200` opt-in block wrapped in subshell with `|| <diagnostic>` at fi-time for SC-10 non-fatal pre-spawn posture. See commit `0d83fae` for full detail.

- [x] iter-273: **STORY 2.12 PATCH-2 LANDED** — `packages/devbox/docker-compose.yml:145` env propagation switched from `${KEEL_DEVBOX_SSH:-false}` to `${KEEL_DEVBOX_SSH_RESOLVED:-false}`; `packages/devbox/entrypoint.sh:132-139` comment reframed to cite RESOLVED-source mapping. See commit `1df64ab` for full detail.

- [x] iter-272: **STORY 2.12 PATCH-1 LANDED** — `packages/devbox/entrypoint.sh:146 + :162` chmod under cap_drop via `gosu dev` prefix. HIGH-convergent Acceptance Auditor finding. See commit `30b7d8d` for full detail.

- [x] iter-271: `/bmad-code-review (args: "2")` — `sm-verified → fixes-pending`; 5 PATCH + 11 DEFER + ~10 DISMISS; three-layer adversarial fan-out. See commit `a777224` for full triage detail.

_(iter-253..270 Story 2.10/2.11/2.12 closure + Story 2.12 drafting/pre-dev-SM/ATDD/dev-story/trace-gate/post-dev-SM iters pruned per Guardrail 2.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **11/17 stories done** (2.1-2.11) + 1/17 fixes-pending (2.12) + 5/17 backlog (2.13..2.17).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live fresh-fork first-run smokes operator-workstation-deferred; substrate smokes covered through iter-275 (PATCH-4 landed; static smokes GREEN).
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:120). Host-side shim count: **18** at iter-275 (unchanged at PATCH-4-landing iter — PATCH-4 touches entrypoint.sh only, not shims).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **11 done** (2.1-2.11); 1 fixes-pending-CR (2.12); 5 backlog (2.13..2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.12 — Loopback-bound port publication + opt-in `KEEL_DEVBOX_SSH` sshd
- **Story File:** `_bmad-output/implementation-artifacts/2-12-loopback-bound-port-publication-opt-in-keel-devbox-ssh-sshd.md`
- **Story State:** `fixes-pending` — PATCH-1+2+3+4 landed at iter-272+273+274+275 (4 of 5); 1 remaining (PATCH-5) then re-run `/bmad-code-review (args: "2")` for `fixes-pending → done | fixes-pending` confirmation gate.
- **GitHub Issue:** Story 2.12 issue unknown; `RALPH_ISSUE_NUMBER` unset at iter-275 orient. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` carries unchanged since iter-274 orient); push is unblocked at any Story State.

## Notes

- **iter-275 observation (`mv -T` over non-empty target dir fails deterministically — rm-then-mv is the idiomatic recovery):** GNU `mv -T` refuses to overwrite a non-empty target directory with "Directory not empty" regardless of source type, even when the intent is atomic replacement. Under `set -e` this aborts the enclosing script; under a SC-10-style subshell it fires the `||` diagnostic without crashing the container, but the feature (sshd) silently fails to start. The recovery idiom is `rm -rf <dst> && mv -T <src> <dst>` — the rm is idempotent (no-op if dst is empty), and the mv then hits the empty-or-missing-dst path where rename semantics apply. Applies to any future atomic-dir-replace sequence inside a set -e script (Story 2.13 healthcheck state-dir recovery, any future opt-in feature that generates state in a scratch dir + moves into place). Not novel enough to promote to RALPH.md — well-known GNU mv behaviour.
- **iter-274 observation (subshell-wrap-with-||-diagnostic is the canonical non-fatal-failure isolation pattern under `set -euo pipefail`):** when a sub-block must be non-fatal (SC-10 class posture), the Bash pattern is `( <commands> ) || <diagnostic>` rather than sprinkling `|| true` on every command inside. The subshell scopes `set -e` so a single `||` at close handles every possible inner failure uniformly. Risk-cost analysis: the inner block still sees `set -e` (no change in behaviour relative to the pre-wrap state) — only the OUTER propagation changes. Generalises to any future opt-in-feature setup (Story 2.13 healthcheck wait-loop with optional diagnostic emission; any future stories 2.14-2.17 opt-in runtime features). Not novel enough to promote to RALPH.md — already a well-known bash idiom, documented by many sources.
- **iter-273 NOVEL LESSON carry-forward (compose env-propagation sites are normalisation chokepoints):** any `docker-compose.yml` env var sourced from `.envrc` via `${VAR:-default}` interpolation MUST source the RESOLVED host-side value when a case-folding resolver exists. Generalises to future resolver-gated knobs (Story 2.11 `KEEL_DEVBOX_SHARED`, Story 2.10 `KEEL_DEVBOX_PREREQ_*`). Promoted to RALPH.md § Lessons.
- **iter-272 LESSON carry-forward (orient-time PATCH order decision framework):** evaluate (a) verification-bar parity, (b) Guardrail 5 clean-ness, (c) downstream reduction, (d) independence. iter-272 chose linear PATCH-1..5. Promoted to RALPH.md § Lessons.
- **iter-271 NOVEL LESSON carry-forward (forecast band breach via novel-runtime-behaviour surface):** 4-7 PATCH band for novel-runtime-behaviour stories (sshd, healthcheck, dynamic resolver-to-runtime propagation). Applies to 2.13 (healthcheck), 6.x (RLS debugger), Epic 13 (CI harness smokes).
- **iter-271 LESSON carry-forward (three-subagent pattern reaffirmed):** Blind / Edge / Auditor parallel-fan-out; convergence-signal-high-confidence-triage (iter-260) — all 5 iter-271 PATCHes ≥2-layer convergent.
- **iter-270 NOVEL LESSON carry-forward (drift-band re-baseline):** substrate-citation drift BIMODAL — substantive 0-2 + mechanical 8-12 per dev-pass-touches-≥4-cited-files story.
- **iter-270 LESSON carry-forward (two-subagent pattern reaffirmed):** post-dev SM AC-verifier (Amelia) + drift-detector (Winston) PROVEN at THIRD cumulative application.
- **iter-269 trace-gate outcome carry-forward:** WAIVED per ground-(a)+(b)+(c) hybrid conjunction.
- **iter-268 NOVEL LESSON carry-forward:** post-crash recovery VERIFY+COMMIT (not re-invoke); 5-check verification.
- **iter-267 precedent-match carry-forward:** 22nd-cumulative ATDD-skip-with-grounds-(c)+(ii)+(iii); Story 2.5 iter-186 canonical pattern.
- **iter-266 NOVEL LESSONS carry-forward:** container-loopback ≠ host-loopback under Docker userland-proxy — pattern TRAP (defence-in-depth `ListenAddress 127.0.0.1` actively broken); pre-dev SM PATCH-count CAN break iter-221 ~5 ceiling for novel-runtime-behaviour stories (band 6-10).
- **iter-264 LESSON carry-forward (EXTENDED by iter-271):** CR re-run DEFER-vs-PATCH severity-class-first; 0-3 first-class PATCH band applies to STATIC-SUBSTRATE stories; 4-7 band applies to NOVEL-RUNTIME-BEHAVIOUR stories.
- **iter-263 LESSON carry-forward:** SSH :22 / HTTPS :443 asymmetric recovery; iter-274 expected SSH :22 clean.
- **iter-257 LESSON reaffirmed at iter-274:** `pnpm keel-invariants:check` runs `dist/check.js`; rebuild required after manifest edit. iter-274 did not modify manifest; no rebuild needed; sync-gate GREEN confirmed.
- **iter-244/246 audit-findings carry-forward:** restart.sh transitive-delegate; benchmark.sh OUT-OF-SCOPE (SC-11) threading compose-override; Manifest entry count **32** at iter-274 (unchanged).
- **Substrate-citation drift cumulative forecast for Stories 2.13..2.17:** ~5-12 cumulative substantive + ~40-60 cumulative mechanical drifts. SC-17 single reconciliation at Story 2.17 landing.
