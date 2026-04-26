# Implementation Plan — `chore/pr-230-review`

> **Branch context:** `chore/pr-230-review` is the synthesizer / PR-review-tracking branch for PR #230 (Epic 2). IP + RALPH.md commits live here; QUEUE-fix code commits land directly on `feat/epic-2-packaged-devbox` (PR #230 head) via `git -C /workspace/ralph-bmad ...` per worktree-locking workaround (RALPH.md § Gotchas).

## NOW

- [ ] **2.5b doc/spec hygiene — `docs/invariants/devbox-hardening.md` § Capability bounding set 5-cap reconciliation** ~medium

  Edit lines 13, 28-32, 76-77, 156, 160 to enumerate all 5 caps (`NET_ADMIN, NET_RAW, NET_BIND_SERVICE, SETUID, SETGID`) per iter-238 reconciliation. **Heavier:** updating the doc changes its contentHash → manifest entry contentHash MUST update in lockstep (Story 2.3 SC-10 protocol). Run `pnpm keel-invariants:check` post-edit to verify. Commit on `feat/epic-2-packaged-devbox` per worktree-locking workaround.

## QUEUE (PR #230 review fix-arc)

Sourced from <https://github.com/tthew/ralph-bmad/pull/230#issuecomment-4322595769>. One per iter; commit on `feat/epic-2-packaged-devbox`.

- [ ] **2.5c** Add `## Change Log` entry to `_bmad-output/implementation-artifacts/2-5-…md` pinning iter-238 SETUID/SETGID extension; cross-link to AC2 + `docs/invariants/devbox-hardening.md`. ~small.
- [ ] **2.7 AC3 docker-exec semantics** Amend AC3 in `_bmad-output/implementation-artifacts/2-7-…md` OR add Change Log entry. Inline rationale already at `packages/devbox/scripts/ralph-build-host.sh:6-12`. Ref: `discussion_r3143866791`.
- [ ] **2.13 healthcheck timeout** `packages/devbox/docker-compose.yml:282`: `nc -z 127.0.0.1 2222` → `nc -z -w 2 127.0.0.1 ${KEEL_DEVBOX_SSH_PORT:-2222}`. Ref: `discussion_r3143864797`.
- [ ] **2.13 probe-domain three-site lockstep** `api.github.com` hardcoded in 3 files; add pre-commit grep asserting literal matches across `docker-compose.yml:281`, `docs/invariants/devbox-healthcheck.md`, `packages/devbox/README.md` § Healthcheck.
- [ ] **2.14 absorption-SHA reachability** Add sync-gate step `git rev-parse 5278738^{commit} >/dev/null 2>&1 || fail` to guard `docs/invariants/devbox-legacy-branch-retention.md:108-128`. Ref: `discussion_r3143866586`.
- [ ] **2.12 sshd liveness comment** Add 1-line comment at `packages/devbox/entrypoint.sh:207-211`: "Verify sshd is listening before exec'ing the operator shell."
- [ ] **2.7 arg-passthrough comment (NIT)** Brief comment near `packages/devbox/scripts/ralph-build-host.sh:90` on `"$@"` passthrough contract.

### Out-of-PR follow-ups (track elsewhere)

- 2.13 operator-workstation healthcheck smoke (mid-run service-death) → Epic 13 nightly.
- 2.18 IPv6 static CIDR fallback → revisit if egress-during-boot incidents recur.
- 2.11 manifest description drift at `invariants.manifest.ts:275` → deferred per Epic 2 close-out (SC-17).

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

## Context

- **Phase:** PR-review (Epic 2 close-out, post-implementation).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox); PR #230 Open, awaiting review-feedback resolution + merge.
- **Epic Branch (target of fix iterations):** `feat/epic-2-packaged-devbox` (PR #230 head).
- **Working Branch (this branch):** `chore/pr-230-review` — IP + RALPH.md only.
- **Story:** _(no story — review iteration)._
- **Story State:** _(no story — synthesizer mode)._
- **PR:** #230 **Open**, mergeStateStatus=**CLEAN** at iter-4 orient (no new pushes since iter-3 `e555425`; CI was 4/4 SUCCESS at 17:54). Re-poll `gh pr view 230 --json reviews,comments` periodically; humans may add findings while QUEUE drains.

## Halt criterion

When QUEUE empty AND `gh pr view 230 --json reviews,comments` shows all PR threads resolved → write `EPIC_DONE` halt with `note` field per § Halt § Autonomy guardrail: `echo '{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR review feedback addressed"}' > "$RALPH_BASE_DIR/halt"`. Do NOT introduce new halt reasons.
