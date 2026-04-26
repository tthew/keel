# Implementation Plan — `chore/pr-230-review`

> **Branch context:** `chore/pr-230-review` is the synthesizer / PR-review-tracking branch for PR #230 (Epic 2 close-out). Its sole purpose is to host the review IP + RALPH.md journal entries for this multi-iteration review run. Code fixes for the QUEUE items below land on **separate `fix/pr-230-*` branches** off `origin/feat/epic-2-packaged-devbox`, NOT here.
>
> The pre-existing IP that lives on `feat/epic-2-packaged-devbox` (Story 1.21 / Epic-1-reclose state) is intentionally NOT inherited — it tracks a different concern. Future Ralph iterations on `chore/pr-230-review` read THIS file.

## NOW

- [ ] Re-poll PR #230 review state (`gh pr view 230 --json reviews,comments`); merge any human-added findings into QUEUE (preserve existing items, append new) ~small

## QUEUE (PR #230 feedback follow-ups — Epic 2 Sandboxed Execution Environment)

Sourced from the synthesizer's review summary at <https://github.com/tthew/ralph-bmad/pull/230#issuecomment-4322595769> (iter-1, 2026-04-26). Each item is a discrete fix task; one per future iteration. Inline-comment URLs listed where applicable.

- [ ] **2.5 doc/spec hygiene** — Amend AC2 in `_bmad-output/implementation-artifacts/2-5-container-hardening-non-root-user-capabilities-tmpfs-noexec-named-volume.md` to read "cap_add lists `NET_ADMIN, NET_RAW, NET_BIND_SERVICE, SETUID, SETGID` per SC-4 reconciliation" (or move precise list to `docs/invariants/devbox-hardening.md` § Capability bounding set with AC2 forward-referencing). Implementation is already correct + extensively rationalised at `packages/devbox/docker-compose.yml:171-220`; only the AC text is stale. Reference: PR summary § MINOR-1.

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

## DONE (PR #230 review iter-1 — 2026-04-26)

- [x] **iter-1: Epic 2 PR #230 code-review pass.** Branched from `origin/feat/epic-2-packaged-devbox` to `chore/pr-230-review`. Three parallel sub-reviewers (Stories 2.1-2.6, 2.7-2.12, 2.13-2.18) audited each story's ACs against `packages/devbox/` + `.claude/{settings.json,hooks/}` + invariants manifest with file:line proofs. Synthesizer re-verified every BLOCKER + MAJOR claim against the merged tree; **rejected 4 false positives** (`INV-git-hooks-preservation` IS at `invariants.manifest.ts:419`; case-sensitivity hook bypass is a misread — `shopt -s nocasematch` covers both `[[ =~ ]]` AND POSIX `case`; Story 2.18 orphan-sidecar IS already fixed at `whitelist.sh:279-281`; Story 2.15 deny-rules count is within the "at minimum 13" AC contract). Posted: 1 summary comment (<https://github.com/tthew/ralph-bmad/pull/230#issuecomment-4322595769>) + 3 inline comments (`docker-compose.yml:282`, `devbox-legacy-branch-retention.md:128`, `ralph-build-host.sh:88`). Findings: 0 blockers / 0 majors / 6 minors / 2 nits — recommendation: APPROVE.

## Context

- **Phase:** PR-review (Epic 2 close-out, post-implementation).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox) — implementation done at `origin/feat/epic-2-packaged-devbox`; PR #230 Open, awaiting review-feedback resolution + merge.
- **Epic Branch (target of fix iterations):** `feat/epic-2-packaged-devbox` (PR #230 head).
- **Working Branch (this branch):** `chore/pr-230-review` — synthesizer's IP + RALPH.md journal commits live here; QUEUE items target the EPIC branch via separate `fix/pr-230-*` branches.
- **Story:** _(no story — review iteration; QUEUE items are mostly doc/spec hygiene, not lifecycle stories)._
- **Story File:** _(n/a)_
- **Story State:** _(no story — synthesizer mode)._
- **PR:** #230 **Open** — review summary + 3 inlines posted iter-1 (2026-04-26). No human reviewers had commented at iter-1 time; future iterations should re-poll `gh pr view 230 --json reviews,comments` for added feedback before processing the QUEUE.

## Notes

- **Multi-iteration shape (this run).** User instruction (iter-1 prompt): "in a further iteration: review PR code review feedback and breakdown required fixes into IP queue for future ralph's to iterate through and resolve PR feedback issues. Keep going / breaking down into IP until satisfied that the PR feedback has been addressed and then halt." Iter-1 (this one) posted the review. Iter-2's NOW is to re-poll the PR for any new comments (humans may add findings between iterations) and merge them into QUEUE before any fix iterations begin. Iter-3..N execute QUEUE fixes one-per-iteration on `fix/pr-230-*` branches off the epic head. Final iter writes a halt once QUEUE empties + all PR threads are resolved.

- **Branch posture for fix iterations.** Each QUEUE fix lands on a fresh `fix/pr-230-<slug>` branched from `origin/feat/epic-2-packaged-devbox`, NOT here. Apply fix → push → comment on the PR thread closing the inline → mark QUEUE item DONE on `chore/pr-230-review`. This branch (`chore/pr-230-review`) is review-tracking only; never push fix code here.

- **Synthesizer-rejected sub-reviewer claims (audit-trail discipline).** Sub-reviewers occasionally raise BLOCKER/MAJOR findings that don't survive verification. Each of the 4 rejections in iter-1 is documented in the PR summary § "Verified-not-issues" so future readers can audit the synthesizer's judgment. Do not retroactively delete the rejections from the summary; they're load-bearing for trust calibration.

- **No story-lifecycle workflow this iteration.** QUEUE items don't run through `/bmad-create-story → /bmad-testarch-atdd → /bmad-dev-story → /bmad-testarch-trace → /bmad-create-story (review) → /bmad-code-review → done` — they are PR-feedback fixes, not new stories. Treat each as a small atomic commit on a fresh `fix/*` branch off the epic head.

- **Halt criterion.** When (a) the QUEUE has been emptied AND (b) `gh pr view 230 --json reviews,comments` shows all PR threads as resolved (or only contains items already addressed in QUEUE-done), the next-iteration NOW is to write the halt sentinel: `echo '{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR review feedback addressed"}' > "$RALPH_BASE_DIR/halt"` and exit. Do NOT introduce a new halt reason — `EPIC_DONE` with a `note` field is the bounded fall-back per § Halt § Autonomy guardrail in PROMPT_build.md.
