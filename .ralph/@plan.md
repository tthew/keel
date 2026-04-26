# Implementation Plan — `chore/pr-230-review`

> **Branch context:** `chore/pr-230-review` is the synthesizer / PR-review-tracking branch for PR #230 (Epic 2 close-out). Its sole purpose is to host the review IP + RALPH.md journal entries for this multi-iteration review run. Code fixes for the QUEUE items below commit directly to `feat/epic-2-packaged-devbox` (PR #230 head; resolved iter-2; see § Notes § Branch posture). This branch never carries code commits.
>
> The pre-existing IP that lives on `feat/epic-2-packaged-devbox` (Story 1.21 / Epic-1-reclose state) is intentionally NOT inherited — it tracks a different concern. Future Ralph iterations on `chore/pr-230-review` read THIS file.

## NOW

- [ ] **Monitor PR #230 CI** — `gh pr checks 230 --watch --fail-fast`. Iter-3 pushed `e555425 docs(epic-2): 2.5 AC2 enumerate 5-cap bounding set per SC-4 + iter-238 reconciliation` to `feat/epic-2-packaged-devbox` (origin: `0e295c0..e555425`) at ~17:55 2026-04-26; fresh CI run triggered. Pass → mark done, promote next QUEUE item (2.5b) to NOW. Fail → root-cause via `gh run view --log <run-id>`, add fix-task to TOP of QUEUE, mark Monitor done, exit. ~small

  Branch posture for fix iterations (iter-3 refinement): per worktree-locking gotcha (RALPH.md § Gotchas iter:pr-review-3), commit on `feat/epic-2-packaged-devbox` via `git -C /workspace/ralph-bmad ...` against the main repo (which has the feat branch checked out) — the current worktree's branch (`chore/pr-230-review`) cannot `git switch` to feat (worktree lock from main-repo checkout). The current worktree handles IP/RALPH.md bookkeeping only. Apply this pattern for ALL subsequent QUEUE-fix iterations.

## QUEUE (PR #230 feedback follow-ups — Epic 2 Sandboxed Execution Environment)

Sourced from the synthesizer's review summary at <https://github.com/tthew/ralph-bmad/pull/230#issuecomment-4322595769> (iter-1, 2026-04-26). Each item is a discrete fix task; one per future iteration. Inline-comment URLs listed where applicable. Branch posture for ALL items: commit on `feat/epic-2-packaged-devbox` (PR #230 head) via `git -C /workspace/ralph-bmad ...` per iter-3 worktree-locking workaround; record DONE on `chore/pr-230-review`.

- [ ] **2.5b doc/spec hygiene (HEAVIER — manifest contentHash impact)** — `docs/invariants/devbox-hardening.md` § Capability bounding set (lines 13, 28-32, 76-77, 156, 160) enumerates only 3 caps (`NET_ADMIN, NET_RAW, NET_BIND_SERVICE`). Implementation has 5 (+ SETUID + SETGID per iter-238 reconciliation, fully rationalised at `docker-compose.yml:197-206`). This is the canonical invariant doc per FR44 — AC2 (fixed iter-3) forward-references this file, so consistency MUST be restored. **Note:** updating the doc changes its contentHash → sync-gate (`pnpm keel-invariants:check`) reports drift → manifest entry contentHash MUST be updated in lockstep (same commit, per Story 2.3 SC-10 + iter-162/182 protocol). Heavier than a plain doc edit; cross-check by running `pnpm keel-invariants:check` post-edit. Discovered iter-3 while applying AC2 fix. Reference: PR summary § MINOR-1 (extended scope).

- [ ] **2.5c doc/spec hygiene** — SC-4 inside `_bmad-output/implementation-artifacts/2-5-container-hardening-non-root-user-capabilities-tmpfs-noexec-named-volume.md` (lines ~50-) still narrates "three-cap reconciliation" for `[NET_ADMIN, NET_RAW, NET_BIND_SERVICE]`. SC-4 is pinned at draft "MUST be honored — not re-negotiable without Change Log entry"; canonical fix is to add a `## Change Log` entry to the IA file pinning the iter-238 SETUID/SETGID extension + cross-link to AC2 (fixed iter-3) and `docs/invariants/devbox-hardening.md` § Capability bounding set (fixed in 2.5b). Optional: amend SC-4's "three narrow caps" wording inline. Discovered iter-3. ~small.

- [ ] **2.7 doc/spec hygiene** — Amend AC3 in `_bmad-output/implementation-artifacts/2-7-ralph-auto-start-tui-attach-detach-via-pnpm-ralph-build-pnpm-ralph-plan.md` to reflect `docker exec` semantics, OR add a `## Change Log` entry pinning the evolution + rationale. Inline rationale already present at `packages/devbox/scripts/ralph-build-host.sh:6-12`; only the spec lags. Reference: <https://github.com/tthew/ralph-bmad/pull/230#discussion_r3143866791>.

- [ ] **2.13 healthcheck `nc -z` timeout** — In `packages/devbox/docker-compose.yml:282`, change `nc -z 127.0.0.1 2222` to `nc -z -w 2 127.0.0.1 ${KEEL_DEVBOX_SSH_PORT:-2222}` for explicit per-probe timeout consistent with `dig +time=3 +tries=1`. Reference: <https://github.com/tthew/ralph-bmad/pull/230#discussion_r3143864797>.

- [ ] **2.13 probe-domain three-site lockstep** — `api.github.com` is hardcoded in `packages/devbox/docker-compose.yml:281`, `docs/invariants/devbox-healthcheck.md`, and `packages/devbox/README.md` § Healthcheck. Add a tiny pre-commit grep that asserts the literal matches across the three files (lower-risk option vs extracting to env var). Reference: PR summary § MINOR-4.

- [ ] **2.14 absorption-SHA reachability check** — Add a sync-gate / pre-commit step `git rev-parse 5278738^{commit} >/dev/null 2>&1 || fail` to guard `docs/invariants/devbox-legacy-branch-retention.md:108-128` against silent breakage if Story 15b cuts rewrite history. Reference: <https://github.com/tthew/ralph-bmad/pull/230#discussion_r3143866586>.

- [ ] **2.12 sshd liveness comment** — Add a one-line comment at `packages/devbox/entrypoint.sh:207-211` explaining "Verify sshd is listening before exec'ing the operator shell." Reference: PR summary § MINOR-6.

- [ ] **2.7 arg-passthrough comment** — Optional NIT: brief comment near `packages/devbox/scripts/ralph-build-host.sh:90` documenting `"$@"` passthrough contract for future readers (`pnpm ralph:build --iterations 5` etc.). Reference: PR summary § NIT-1.

### Out-of-PR follow-ups (track elsewhere; do NOT add to a PR-#230-followup branch)

- 2.13 operator-workstation healthcheck smoke (mid-run service-death → unhealthy transition). Fold into Epic 13 nightly when CI lands.
- 2.18 IPv6 static CIDR fallback (explicitly omitted at `egress.nft:115-116`; revisit if egress-during-boot incidents recur).
- 2.11 manifest description drift at `invariants.manifest.ts:275`-area (description text references only `KEEL_DEVBOX_CONTAINER_NAME`; sync-gate masks because contentHash-only). Deferred per Epic 2 close-out (SC-17).

## BLOCKED

_(none — all findings are MINOR/NIT; no blockers, no majors)_

## DONE (PR #230 review iter-1..3 — 2026-04-26)

- [x] **iter-1: Epic 2 PR #230 code-review pass.** Three parallel sub-reviewers audited Stories 2.1-2.18 ACs vs implementation; synthesizer re-verified, rejected 4 false positives, posted: 1 summary + 3 inline comments. Findings: 0 blockers / 0 majors / 6 minors / 2 nits — recommendation: APPROVE. (Detail compressed iter-3; see commit `20ee582` for full audit log.)

- [x] **iter-2: Re-poll + branch-strategy resolution.** `gh pr view 230 --json reviews,comments` confirmed zero new human-added findings 17:31→17:38. PR #230: Open, CLEAN, 4/4 CI green. Promoted first QUEUE item to NOW. Resolved branching: fix commits land directly on `feat/epic-2-packaged-devbox` (not sub-branches). Step-5 push deferred — SSH-egress port-22 90s timeout (kill-after-hang class). 1 unpushed commit (`d8cc35c`). (Detail compressed iter-3; see commit `d8cc35c` for full resolution.)

- [x] **iter-3: 2.5 AC2 amendment landed + 2.5b/2.5c discovered.** Amended AC2 in `_bmad-output/implementation-artifacts/2-5-container-hardening-non-root-user-capabilities-tmpfs-noexec-named-volume.md:23` to enumerate all 5 caps (`NET_ADMIN, NET_RAW, NET_BIND_SERVICE, SETUID, SETGID`) with rationale + forward-reference to `docs/invariants/devbox-hardening.md` § Capability bounding set. Committed on `feat/epic-2-packaged-devbox` as `e555425 docs(epic-2): 2.5 AC2 enumerate 5-cap bounding set per SC-4 + iter-238 reconciliation`. Pushed `0e295c0..e555425` to origin (iter-2's push-defer batch is on the OTHER branch — `chore/pr-230-review` — and is pushed at iter-3 close-out via this commit). Pre-commit hook initially failed `pnpm typecheck` (vitest module missing — PR #236 merge brought new test files but `node_modules` wasn't re-resolved post-pull); recovered with `pnpm install --frozen-lockfile` (45 packages added). PR CI green pre-push (4/4 SUCCESS at 17:54). **Workflow refinement:** to commit on `feat/epic-2-packaged-devbox` while `chore/pr-230-review` is checked out in this worktree, used `git -C /workspace/ralph-bmad ...` against the main repo (which holds the feat branch checkout) — `git switch feat/...` here would fail (worktree lock). Recorded as RALPH.md § Gotchas iter:pr-review-3. **Discoveries (queued as 2.5b + 2.5c):** `docs/invariants/devbox-hardening.md` § Capability bounding set ALSO enumerates only 3 caps (the canonical FR44 doc — heavier fix because manifest contentHash must update in lockstep); SC-4 inside the IA file ALSO narrates 3-cap reconciliation (Change Log entry recommended per "MUST be honored — not re-negotiable" pinning). Past-Ralph iter-2's claim "Implementation is already correct + extensively rationalised; only the AC text is stale" was incomplete — drift extends to the canonical invariant doc + IA SC-4 narrative.

## Context

- **Phase:** PR-review (Epic 2 close-out, post-implementation).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox) — implementation done at `origin/feat/epic-2-packaged-devbox`; PR #230 Open, awaiting review-feedback resolution + merge.
- **Epic Branch (target of fix iterations):** `feat/epic-2-packaged-devbox` (PR #230 head).
- **Working Branch (this branch):** `chore/pr-230-review` — synthesizer's IP + RALPH.md journal commits live here; QUEUE items commit directly to the EPIC branch (`feat/epic-2-packaged-devbox`) per branch-posture decision iter-2.
- **Story:** _(no story — review iteration; QUEUE items are mostly doc/spec hygiene, not lifecycle stories)._
- **Story File:** _(n/a)_
- **Story State:** _(no story — synthesizer mode)._
- **PR:** #230 **Open**, mergeStateStatus=**CLEAN** as of pre-push iter-3 verify (4/4 CI checks SUCCESS at 17:54 2026-04-26). Iter-3 push (`0e295c0..e555425`) triggers fresh CI run on SHA `e555425`; iter-4 NOW = monitor that run via `gh pr checks 230 --watch --fail-fast`. Future iterations should still re-poll `gh pr view 230 --json reviews,comments` + `gh api repos/tthew/ralph-bmad/pulls/230/comments` periodically (humans may add findings asynchronously while the QUEUE drains).

## Notes

- **Multi-iteration shape (this run).** User instruction (iter-1 prompt): "in a further iteration: review PR code review feedback and breakdown required fixes into IP queue for future ralph's to iterate through and resolve PR feedback issues. Keep going / breaking down into IP until satisfied that the PR feedback has been addressed and then halt." Iter-1 posted the review. Iter-2 re-polled (no new findings) and resolved the branch posture for fix iterations. Iter-3..N execute QUEUE fixes one-per-iteration directly on `feat/epic-2-packaged-devbox` (PR #230 head). Final iter writes a halt once QUEUE empties + all PR threads are resolved.

- **Branch posture for fix iterations (resolved iter-2; iter-3 mechanic refinement).** Each QUEUE fix is committed directly to `feat/epic-2-packaged-devbox` (PR #230 head) — the canonical GitHub PR-feedback flow. Each fix is a single small commit with `docs(epic-2):` or `fix(epic-2):` scope; pushing updates PR #230 in place and triggers PR CI re-run. After the fix push, switch back to `chore/pr-230-review` (this branch) to record DONE in this IP and (where applicable) reply on the PR thread closing the inline comment. This branch (`chore/pr-230-review`) remains review-tracking only — IP + RALPH.md commits live here, no code commits.

  **Iter-3 mechanic refinement:** "switch back to chore/pr-230-review" is misleading — Ralph operating from this worktree NEVER actually switches the worktree's branch (worktree lock prevents `git switch feat/epic-2-packaged-devbox` while the feat branch is checked out in `/workspace/ralph-bmad`). Actual mechanic: `git -C /workspace/ralph-bmad pull --ff-only origin feat/epic-2-packaged-devbox` → Edit/Write the target file at `/workspace/ralph-bmad/...` (NOT the worktree path) → `git -C /workspace/ralph-bmad commit ...` → `git -C /workspace/ralph-bmad push origin feat/epic-2-packaged-devbox`. CWD stays in this worktree throughout (env instruction prohibits `cd` to main repo). All IP/RALPH.md edits operate on the worktree's `chore/pr-230-review` checkout. See RALPH.md § Gotchas iter:pr-review-3 for the canonical recipe + the `pnpm install` step that may be needed post-pull.

  ⊗ The earlier "fresh `fix/pr-230-<slug>` branched from `origin/feat/epic-2-packaged-devbox` per fix" idea (iter-1 IP) was over-engineered for trivial doc/spec hygiene — abandoned at iter-2. Each sub-branch would have required its own PR (against `feat/epic-2-packaged-devbox`, since it's the PR head; or a separate PR-to-main that conflicts with #230) — that ceremony isn't justified for 6 MINOR + 2 NIT findings, all of which are already approved-with-minor-doc-hygiene per iter-1 verdict.

- **Synthesizer-rejected sub-reviewer claims (audit-trail discipline).** Sub-reviewers occasionally raise BLOCKER/MAJOR findings that don't survive verification. Each of the 4 rejections in iter-1 is documented in the PR summary § "Verified-not-issues" so future readers can audit the synthesizer's judgment. Do not retroactively delete the rejections from the summary; they're load-bearing for trust calibration.

- **No story-lifecycle workflow this iteration.** QUEUE items don't run through `/bmad-create-story → /bmad-testarch-atdd → /bmad-dev-story → /bmad-testarch-trace → /bmad-create-story (review) → /bmad-code-review → done` — they are PR-feedback fixes, not new stories. Treat each as a small atomic commit on the epic head (`feat/epic-2-packaged-devbox`); update PR #230 in place. After each commit, switch back to `chore/pr-230-review` to record DONE in this IP and (where applicable) reply on the PR thread.

- **Halt criterion.** When (a) the QUEUE has been emptied AND (b) `gh pr view 230 --json reviews,comments` shows all PR threads as resolved (or only contains items already addressed in QUEUE-done), the next-iteration NOW is to write the halt sentinel: `echo '{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR review feedback addressed"}' > "$RALPH_BASE_DIR/halt"` and exit. Do NOT introduce a new halt reason — `EPIC_DONE` with a `note` field is the bounded fall-back per § Halt § Autonomy guardrail in PROMPT_build.md.
