# Implementation Plan — `chore/pr-230-review`

> **Branch context:** `chore/pr-230-review` is the synthesizer / PR-review-tracking branch for PR #230 (Epic 2). IP + RALPH.md commits live here; QUEUE-fix code commits land directly on `feat/epic-2-packaged-devbox` (PR #230 head) via `git -C /workspace/ralph-bmad ...` per worktree-locking workaround (RALPH.md § Gotchas).

## NOW

- [ ] **2.7 AC3 docker-exec semantics** Amend AC3 in `_bmad-output/implementation-artifacts/2-7-…md` OR add Change Log entry. Inline rationale already at `packages/devbox/scripts/ralph-build-host.sh:6-12`. Ref: `discussion_r3143866791`.

## QUEUE (PR #230 review fix-arc)

Sourced from <https://github.com/tthew/ralph-bmad/pull/230#issuecomment-4322595769>. One per iter; commit on `feat/epic-2-packaged-devbox`.
- [ ] **2.13 healthcheck timeout** `packages/devbox/docker-compose.yml:282`: `nc -z 127.0.0.1 2222` → `nc -z -w 2 127.0.0.1 ${KEEL_DEVBOX_SSH_PORT:-2222}`. Ref: `discussion_r3143864797`.
- [ ] **2.13 probe-domain three-site lockstep** `api.github.com` hardcoded in 3 files; add pre-commit grep asserting literal matches across `docker-compose.yml:281`, `docs/invariants/devbox-healthcheck.md`, `packages/devbox/README.md` § Healthcheck.
- [ ] **2.14 absorption-SHA reachability** Add sync-gate step `git rev-parse 5278738^{commit} >/dev/null 2>&1 || fail` to guard `docs/invariants/devbox-legacy-branch-retention.md:108-128`. Ref: `discussion_r3143866586`.
- [ ] **2.12 sshd liveness comment** Add 1-line comment at `packages/devbox/entrypoint.sh:207-211`: "Verify sshd is listening before exec'ing the operator shell."
- [ ] **2.7 arg-passthrough comment (NIT)** Brief comment near `packages/devbox/scripts/ralph-build-host.sh:90` on `"$@"` passthrough contract.

### Out-of-PR follow-ups (track elsewhere)

- 2.13 operator-workstation healthcheck smoke (mid-run service-death) → Epic 13 nightly.
- 2.18 IPv6 static CIDR fallback → revisit if egress-during-boot incidents recur.
- 2.11 manifest description drift at `invariants.manifest.ts:275` → deferred per Epic 2 close-out (SC-17).
- **Pre-existing `INV-package-test-coverage-floor` contentHash drift** (manifest declares `57555cb…`, file hashes `4d24479d…`); present at `fed3161` (iter-390) + every Epic-2 commit since. Not in 2.5b scope. Sync-gate is not yet wired to pre-commit/CI so it doesn't block; Story 1.9 follow-up.

## BLOCKED

_(none — all findings are MINOR/NIT)_

## DONE (PR #230 review iter-1..4 — 2026-04-26)

- [x] [iter-1] Posted PR #230 review — 6 MINOR + 2 NIT, APPROVE — `20ee582`.
- [x] [iter-2] Re-poll clean + branch posture resolved — `d8cc35c`.
- [x] [iter-2b] Push-defer annotation (SSH-egress timeout) — `6c8cbc1`.
- [x] [iter-3] 2.5 AC2 5-cap enumeration landed on feat-2 — `e555425` (PR #230).
- [x] [iter-3] Close-out + 2.5b/2.5c discovered — `c4aa62d`.
- [x] [iter-4] Prune RALPH.md + @plan.md back under doc-budget cap — `2d156c9`.
- [x] [iter-4b] Push-defer annotation — SSH-egress port-22 timeout (exit 124).
- [x] [iter-5] 2.5b devbox-hardening.md 5-cap + iter-238 narrative — `04858c6` (PR #230; push deferred).
- [x] [iter-5b] Push retry succeeded — feat-2 + chore/pr-230-review both at origin.
- [x] [iter-6] 2.5c Change Log v1.10 — pin iter-238 SETUID/SETGID 5-cap — `7390020` (PR #230).
- [x] [iter-6b] feat-2 push retry resolved — both branches at origin (`04858c6..7390020 feat-2`, `b16113c..7410ca0 chore`).

## Context

- **Phase:** PR-review (Epic 2 close-out, post-implementation).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox); PR #230 Open, awaiting review-feedback resolution + merge.
- **Epic Branch (target of fix iterations):** `feat/epic-2-packaged-devbox` (PR #230 head).
- **Working Branch (this branch):** `chore/pr-230-review` — IP + RALPH.md only.
- **Story:** _(no story — review iteration)._
- **Story State:** _(no story — synthesizer mode)._
- **PR:** #230 **Open**. Iter-6 landed `7390020` (2.5c Change Log v1.10); iter-6b retry resolved both pushes after first SSH:22 silent-block (gotcha re-confirmed; LADDER first-retry-resolves rate held at ~82%). Both branches at origin: feat-2 `04858c6..7390020`, chore `b16113c..7410ca0`. New CI run will trigger on PR #230 from the `7390020` push (HTTPS:443 was timing out at end of iter-6; api.github.com flake LADDER expected to clear by iter-7); iter-7 0h check should re-poll.

## Halt criterion

When QUEUE empty AND `gh pr view 230 --json reviews,comments` shows all PR threads resolved → write `EPIC_DONE` halt with `note` field per § Halt § Autonomy guardrail: `echo '{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR review feedback addressed"}' > "$RALPH_BASE_DIR/halt"`. Do NOT introduce new halt reasons.
