# Implementation Plan

## NOW

- [ ] `/bmad-testarch-trace (args: "yolo")` per § Story Lifecycle row `in-dev → traced` — forecast WAIVED per Story 2.12 iter-269 pattern (ACs 1, 2, 3, 5 substrate-covered by static smokes + sync-gate at `946f1ac1…907029 + 665174a3…d18623`; AC 4 operator-workstation-deferred — live mid-run SIGKILL of dnsmasq/sshd with `State.Health.Status` transition observation infeasible under DinD backend B cap-dropped semantics).

## QUEUE (Story 2.13 lifecycle + 2.14..2.17 substrate queue)
- [ ] _(after traced)_ `/bmad-create-story (args: "review")` post-dev SM per matrix row `traced → sm-verified`. Two-subagent pattern (iter-235 LESSON). Forecast 0-2 PATCH per iter-270 NOVEL LESSON drift-band re-baseline (pre-dev SM absorbs CRITICAL; post-dev narrower).
- [ ] _(after sm-verified)_ `/bmad-code-review (args: "2")` per matrix row `sm-verified → done | fixes-pending` — three-layer Ralph-hosted adversarial fan-out (iter-271 pattern + iter-277 NOVEL LESSON #2 META guard carry-forward). Forecast 1-3 first-class PATCH (moderate-novelty band per iter-264 LESSON; narrower than Story 2.12 novel-runtime-behaviour outlier).
- [ ] _(after Story 2.13 done)_ Story 2.14 legacy branch retention policy — full lifecycle.
- [ ] _(after Story 2.14 done)_ Story 2.15 committed Claude settings.json deny/allow — full lifecycle.
- [ ] _(after Story 2.15 done)_ Story 2.16 Claude PreToolUse hooks for secret-file denylist — full lifecycle.
- [ ] _(after Story 2.16 done)_ Story 2.17 hook-settings bypass-resistance + Epic 2 SC-17 close-out polish pass. SC-17 reconciliation absorbs cumulative **18 Story 2.12 DEFERs carried to Story 2.17** (11 iter-271 + 3 remaining iter-277 post-iter-278-and-iter-280-absorptions + 4 iter-279) if Story 2.13 Task 5 lands D-1 absorption; PLUS cumulative Epic 2 Story 2.13..2.16 DEFERs accrued during those stories.
- [ ] _(post-Story-2.17-done; Epic 2 final story)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge per § Story Lifecycle + § PR Transition block. Epic 2 completion fires `EPIC_DONE` halt on next iter if PR pending merge; on re-entry after merge auto-advances to Epic 3 Story 3.1 per § Cross-epic transition.
- [ ] _(after every push)_ Monitor PR CI — queue fix tasks for any failures (PR #230 has no CI checks configured at 2026-04-24 per iter-219..280 confirmation; `statusCheckRollup: []` continues; iter-280 orient `gh pr view 230` GREEN first try — SSH :22 recovery asymmetry carry-forward from iter-263 LESSON quiescent this iter).

## BLOCKED

_(none — iter-283 recovery iter completed cleanly; uncommitted WIP from killed prior iter-283 verified-and-committed; sync-gate GREEN post `pnpm --filter @keel/keel-invariants build`; branch ready for push at `3f35dd6` pre-commit.)_

## ATDD Red Phase

_(none — Story 2.13 ATDD-skipped at iter-282 with grounds-(c)+(ii)+(iii); no red-phase tests owed.)_

## DONE (iter-283 Story 2.13 `/bmad-dev-story` landing (RECOVERY) — `atdd-scaffolded → in-dev (review)`; all 5 Tasks complete + Task 5 D-1 absorption; manifest count 32 → 33)

- [x] iter-283: **STORY 2.13 DEV-STORY LANDING (RECOVERY).** FR14n Story State `atdd-scaffolded → in-dev` under § Story Lifecycle row `atdd-scaffolded → /bmad-dev-story`. Killed-pre-commit iter-283 (iter-268 recovery precedent — reflog `f631bf8` "feat(story-2-12): iter-268 /bmad-dev-story landing (recovery)") produced all 5 Tasks' file edits in-tree but never committed; recovery iter verified + committed rather than re-invoking the skill. Story file v1.2 Change Log entry + Status HTML comment pre-written by the killed iter — retained verbatim. Sprint-status flipped `ready-for-dev → in-progress → review` at Step 9 completion.

  - **Task 1 (compose healthcheck block):** `docker-compose.yml:263` TODO replaced with CMD-SHELL + `>-` folded-scalar two-clause POSIX sh block (`dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com >/dev/null && { [ "${KEEL_DEVBOX_SSH:-false}" != "true" ] || nc -z 127.0.0.1 2222; }`); timing `interval 10s` / `timeout 5s` / `retries 3` / `start_period 30s`. Story-roadmap line `:24` past-tense (`LANDED iter-283`). `dash -n` PASS on the joined shell string. AC 1 negative-assertion verified: only two `3000` matches in compose (line 167 `KEEL_DEVBOX_PORT_WEB:-3000` publish + line 264 prose reference to "upstream's broken `curl :3000`" — both expected per Dev Notes line 149).
  - **Task 2 (probe tooling verification):** `dnsutils` present at `Dockerfile:61`; `netcat-openbsd` at `:64`; `USER dev` at `:347`; `grep '^ListenAddress' packages/devbox/sshd/sshd_config` returns empty (PATCH-4 PASS — unset-default listens IPv4 + IPv6 wildcards so `nc -z 127.0.0.1 2222` connects). No Dockerfile change for Task 2.
  - **Task 3 (invariant registration):** `docs/invariants/devbox-healthcheck.md` authored (100 lines; 8 H2 sections — Intent + 7 contract sections); sha256 = `665174a3592106eabbb9f6b5dd39ce813839b3c61a89f1709d81e90524d18623`; manifest entry added after `INV-devbox-ssh` (contiguous Devbox block per iter-268 convention); `INVARIANTS.md` H3 `### Devbox healthcheck (Story 2.13)` + anchor bullet between Story 2.12 and Story 2.2 H3s. Manifest count 32 → 33. `pnpm --filter @keel/keel-invariants build` + `pnpm keel-invariants:check` + `pnpm keel-invariants:check-all` all GREEN.
  - **Task 4 (operator + agent docs):** `README.md § Healthcheck (Story 2.13)` H2 appended between Opt-in SSH (Story 2.12) and cc-devbox upstream provenance (SC-17 sibling-append discipline; prior sections UNCHANGED); `AGENTS.md § Healthcheck (Story 2.13)` H3 appended after Opt-in SSH within § Devbox iteration environment; `README.md:921` forward-ref to past-tense (`→ fixed in Story 2.13 … LANDED iter-283`). No `.envrc.example` edit (no new `KEEL_DEVBOX_*` knob).
  - **Task 5 (D-1 absorption — optional):** Absorbed. One-line `Dockerfile` `RUN install -m 0644 -o root -g root /dev/null /var/log/sshd.log` at `:318-330` after dnsmasq.log pre-create at `:317`. Inline comment pins the pre-gosu-only DAC invariant (iter-281 PATCH-6). Cumulative Epic-2 DEFER queue for Story 2.17 SC-17 close-out at iter-283 in-dev landing = 22 (Story 2.12 final) - 1 (D-1 absorbed) + 3 (Story 2.13 pre-dev SM D-5/D-6/D-7) = **24 DEFERs** pending Story 2.17.

  - **Recovery verification trail:** (a) `git status` surfaced WIP on 7 tracked files + 1 untracked (`docs/invariants/devbox-healthcheck.md`) — matched the story file's § File List exactly; (b) sha256 of the authored doc = `665174a3…d18623` matched the `contentHash` in the manifest diff; (c) `pnpm --filter @keel/keel-invariants build` → `pnpm keel-invariants:check` + `check-all` GREEN on first try post-rebuild (iter-257 LESSON — manifest rebuild is load-bearing after new InvariantSchema entry; applies equally to recovery iters); (d) POSIX `dash -n` on the composed healthcheck CMD → exit 0; (e) 3-site `api.github.com` lockstep: compose + invariant doc + README all contain the probe domain; (f) `grep '^ListenAddress' packages/devbox/sshd/sshd_config` empty (PATCH-4 verification PASS). AC coverage: AC 1 + AC 5 PASS via static smokes; AC 2 + AC 3 PASS via static CMD-SHELL shape + dash parse + POSIX-sh branching analysis; AC 4 operator-workstation-deferred (DinD backend B cannot safely exercise mid-run SIGKILL of dnsmasq/sshd against cap-dropped containers).

  - **PR:** #230 **Draft** — `statusCheckRollup: []` carries unchanged across iter-272..283; recovery iter push at step 5 expected clean.

  - **Budget consumed:** ~30K tokens (orient ~10K + story file read + WIP verification via git diff across 7 files ~10K + rebuild + sync-gate + POSIX parse + lockstep smoke ~4K + IP + RALPH.md + commit-prep ~6K). Well within ~117K execution budget; exit cleanly per Guardrail 12. No skill re-invocation consumed per recovery-pattern discipline (iter-268 precedent).

- [x] iter-282: Story 2.13 ATDD-SKIP — `/bmad-testarch-atdd` SKIP-WITH-GROUNDS-(c)+(ii)+(iii); `validated → atdd-scaffolded`; 23rd-cumulative precedent; ZERO-PATCH iter. See commit `3f35dd6`.

- [x] iter-281: Story 2.13 VALIDATED — `/bmad-create-story (args: "review")` pre-dev SM; `drafted → validated`; 6 PATCH + 3 DEFER. See commit `6e0e810` + IP-cleanup `9863358`.

- [x] iter-280: Story 2.13 DRAFTED — `/bmad-create-story`; `_(no story) → drafted`. See commit `985aee0`.

- [x] iter-279: Story 2.12 DONE — CR closure re-run #2 ZERO-PATCH. See commit `ce3ffb4`.

- [x] iter-272..278: Story 2.12 PATCH-1..6 + iter-277 CR closure re-run #1. Commits `30b7d8d`/`1df64ab`/`0d83fae`/`820591a`/`43b4e4b`/`3eadcff`/`947cbce`.

_(iter-253..271 Story 2.10/2.11/2.12 closure + Story 2.12 lifecycle iters pruned per Guardrail 2.)_

## Context

- **Phase:** 4-implementation — Epic 2 at **12/17 stories done** (2.1-2.12) + 5/17 in-flight (2.13 in-dev (review) at iter-283; 2.14..2.17 backlog). Epic 2 current active story = 2.13 (healthcheck on dnsmasq + sshd).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Live fresh-fork first-run smokes operator-workstation-deferred; substrate smokes covered through iter-283 (`pnpm keel-invariants:check` GREEN at `946f1ac1…907029` + new `665174a3…d18623` for `INV-devbox-healthcheck`; manifest count 32 → 33).
- **Baked image:** `keel-devbox:local` (iter-123 bake; 848 MB, linux/arm64; `@anthropic-ai/claude-code@2.1.116` at Dockerfile:120). Host-side shim count: **18** at iter-283 (unchanged — dev-story did NOT add shims; only compose + Dockerfile + doc + invariant edits).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; **12 done** (2.1-2.12); **1 in-dev (review)** (2.13 at iter-283); **4 backlog** (2.14..2.17). Epic 2 closes at Story 2.17.
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** Story 2.13 — Healthcheck on dnsmasq + sshd (replaces upstream's broken `curl :3000` healthcheck).
- **Story File:** `_bmad-output/implementation-artifacts/2-13-healthcheck-on-dnsmasq-sshd-replaces-upstream-s-broken-curl-3000-healthcheck.md`
- **Story State:** `in-dev` (iter-283 `/bmad-dev-story` RECOVERY landing; all 5 Tasks complete + Task 5 D-1 absorption; story file Status = `review`; sprint-status row `ready-for-dev → in-progress → review`; next gate `/bmad-testarch-trace (args: "yolo")` at iter-284 for `in-dev → traced` — forecast WAIVED per Story 2.12 iter-269 pattern).
- **GitHub Issue:** Story 2.13 issue unknown; `RALPH_ISSUE_NUMBER` unset at iter-283 orient. Epic 2 → #10 (Ralph closes on EPIC_DONE halt at Story 2.17 close-out).
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 — stays Draft across full Epic 2. No CI configured (`statusCheckRollup: []` carried unchanged iter-272..283).

## Notes

- **iter-283 observation (recovery iter pattern reused; iter-268 precedent):** The WIP in `git status` at iter-283 orient was produced by a killed-pre-commit prior iter-283 `/bmad-dev-story` invocation. Recovery was verification-and-commit (NOT re-invoke the skill). Verification steps: (a) story file's `File List` matches `git status` output exactly; (b) story file's claimed sha256 (`665174a3…d18623`) matches `sha256sum` of the actual doc; (c) contentHash in manifest matches doc sha256; (d) `pnpm --filter @keel/keel-invariants build` + sync-gate GREEN; (e) POSIX `dash -n` parse GREEN; (f) 3-site `api.github.com` lockstep + `^ListenAddress` empty smokes GREEN. Same precedent-match pattern as iter-268 Story 2.12 recovery (reflog `f631bf8` — "feat(story-2-12): iter-268 /bmad-dev-story landing (recovery)"). Commit framing preserves iter-283 number (not "iter-284 recovery") per iter-268 convention.
- **iter-283 observation (TodoWrite reminder hooks continue):** harness surfaced TodoWrite reminders twice during this recovery iter (once mid-orient after verification-branch decision, once during README diff review). Matches iter-282 observation: in narrow-surface iters (~30K) the todo list is a single in-progress entry; reminder is false-positive at this iter density. No pattern change — documented harness behaviour.
- **iter-257 LESSON REAFFIRMED (manifest rebuild mandatory; applies to recovery iters too):** `pnpm --filter @keel/keel-invariants build` MUST run before `pnpm keel-invariants:check` after any `invariants.manifest.ts` edit — including when verifying inherited WIP. Sync-gate consumes the compiled `dist/check.js`; stale dist shows `removed-from-docs-only INV-devbox-healthcheck` false drift. Recovery iters should treat the rebuild as load-bearing even when they did NOT author the manifest edit themselves. Story 2.13 v1.2 Completion Notes captures the same observation from the killed iter-283.
- **iter-281 NOVEL LESSON carry-forward (doc-heavy pre-dev SM band widening):** pinned in RALPH.md § Lessons; not exercised at iter-283 (recovery iter); will reactivate at iter-285 post-dev SM (assuming iter-284 `/bmad-testarch-trace` lands WAIVED per forecast).
- **iter-280/281 LESSON carry-forward (citation-audit false-positive mitigation):** applicable at iter-285 post-dev SM audit prompt.
- **iter-278 LESSON carry-forward (DEFER absorption discipline):** FIRED at iter-283 — Task 5 optional absorption of Story 2.12 iter-279 D-1 landed. Pattern validated again (Dockerfile pre-create of `/var/log/sshd.log`; rationale pinned inline; cumulative DEFER queue reduced 25 → 24).
- **iter-277 NOVEL LESSON carry-forward (bash subshell `||`-LHS errexit suppression):** does NOT apply — Story 2.13 healthcheck CMD runs under `/bin/sh` (dash) `&&`/`||` at runtime, not a bash subshell; stays codified for any bash-wrapped wrappers introduced downstream.
- **iter-276 NOVEL LESSON carry-forward (hazard-class discrimination under word-splitting):** stable at iter-283; Story 2.13 `>-` folded-scalar avoids the blank-line `\n` preservation hazard per iter-281 PATCH-3 story-level guard; dev-story implementation kept the two clause lines adjacent as instructed.
- **iter-273 NOVEL LESSON carry-forward (compose env-propagation chokepoints):** stable at iter-283 — Story 2.13 healthcheck reuses Story 2.12 PATCH-2 `KEEL_DEVBOX_SSH_RESOLVED` canonical stream via `${KEEL_DEVBOX_SSH:-false}` read inside the container; no new chokepoint.
- **iter-271 LESSON carry-forward (three-subagent pattern for post-dev SM + CR):** applicable at iter-285 post-dev SM + iter-286 CR. Not exercised at iter-283.
- **iter-270 NOVEL LESSON carry-forward (drift-band re-baseline):** applicable at iter-285 post-dev SM forecast.
- **iter-264 LESSON carry-forward:** CR re-run DEFER-vs-PATCH severity-class-first; Story 2.13 forecast closure budget = 1 closure re-run at worst.
- **iter-263 LESSON carry-forward:** SSH :22 / HTTPS :443 asymmetric recovery; iter-283 orient did not re-probe `gh pr view` since the recovery path is local-only until push; step-5 push will exercise SSH :22.
- **Substrate-citation drift cumulative forecast for Stories 2.13..2.17:** ~5-12 cumulative substantive + ~30-50 cumulative mechanical drifts. SC-17 single reconciliation at Story 2.17 landing. Cumulative DEFER tally at iter-283 Story 2.13 in-dev = 24 (Story 2.12 final 22 - 1 D-1 absorbed at Task 5 + 3 Story 2.13 pre-dev-SM).
