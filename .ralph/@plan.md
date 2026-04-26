# Implementation Plan — `chore/pr-230-review`

> **Branch context:** `chore/pr-230-review` is the synthesizer / PR-review-tracking branch for PR #230 (Epic 2). IP + RALPH.md commits live here; QUEUE-fix code commits land directly on `feat/epic-2-packaged-devbox` (PR #230 head) via `git -C /workspace/ralph-bmad ...` per worktree-locking workaround (RALPH.md § Gotchas).

## NOW

- [ ] **2.14 absorption-SHA reachability** Add sync-gate step `git rev-parse 5278738^{commit} >/dev/null 2>&1 || fail` to guard `docs/invariants/devbox-legacy-branch-retention.md:108-128`. Ref: `discussion_r3143866586`.

## QUEUE (PR #230 review fix-arc)

Sourced from <https://github.com/tthew/ralph-bmad/pull/230#issuecomment-4322595769>. One per iter; commit on `feat/epic-2-packaged-devbox`.
- [ ] **2.12 sshd liveness comment** Add 1-line comment at `packages/devbox/entrypoint.sh:207-211`: "Verify sshd is listening before exec'ing the operator shell."
- [ ] **2.7 arg-passthrough comment (NIT)** Brief comment near `packages/devbox/scripts/ralph-build-host.sh:90` on `"$@"` passthrough contract.

### Out-of-PR follow-ups (track elsewhere)

- 2.13 operator-workstation healthcheck smoke (mid-run service-death) → Epic 13 nightly.
- 2.18 IPv6 static CIDR fallback → revisit if egress-during-boot incidents recur.
- 2.11 manifest description drift at `invariants.manifest.ts:275` → deferred per Epic 2 close-out (SC-17).
- **Pre-existing `INV-package-test-coverage-floor` contentHash drift** (manifest declares `57555cb…`, file hashes `4d24479d…`); present at `fed3161` (iter-390) + every Epic-2 commit since. Not in 2.5b scope. Sync-gate is not yet wired to pre-commit/CI so it doesn't block; Story 1.9 follow-up.

## BLOCKED

_(none — all findings are MINOR/NIT)_

## DONE (PR #230 review iter-1..10 — 2026-04-26)

- [x] [iter-1..7] (pruned for budget — see RALPH.md § Signposts iter-pr-review-4..6 for synthesis).
- [x] [iter-8] 2.7 AC3 Change Log v1.7 — `docker attach → docker exec` evolution (`d3aecde` on feat-2; PR #230).
- [x] [iter-9] **2.13 D-9 closure (`nc -z -w 2`)** — six-site lockstep substrate sweep + Change Log v1.5 + manifest contentHash refresh (`ae0ac4b3 → b8a420a4`); reviewer's `${KEEL_DEVBOX_SSH_PORT:-2222}` half DISMISSED with rationale (host-side-publish vs container-internal-bind semantics) — `350f4cd` on feat-2; PR #230. Sync-gate clean for INV-devbox-healthcheck (pre-existing INV-package-test-coverage-floor drift unchanged).
- [x] [iter-10] **2.13 probe-domain three-site lockstep gate** — new `tools/check-probe-domain-lockstep.sh` extracts dnsmasq probe-domain from `packages/devbox/docker-compose.yml` healthcheck and asserts literal in `docs/invariants/devbox-healthcheck.md` + `packages/devbox/README.md`; wired as `always_run` pre-commit hook in `.pre-commit-config.yaml`; manifest INV-prek-pre-commit-config + INV-prek-commit-msg-config contentHashes refreshed in lockstep (`4d894156 → 9bb763d4`, whole-file sha256 shared per duplicate-sourcePath schema rule). Local commit `24ac971` on feat-2; **push deferred (SSH-egress port-22 timeout, retry also failed) — carry-forward unpushed to next iter retry per iter-5 precedent**.

## Context

- **Phase:** PR-review (Epic 2 close-out, post-implementation).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox); PR #230 Open, awaiting review-feedback resolution + merge.
- **Epic Branch (target of fix iterations):** `feat/epic-2-packaged-devbox` (PR #230 head).
- **Working Branch (this branch):** `chore/pr-230-review` — IP + RALPH.md only.
- **Story:** _(no story — review iteration)._
- **Story State:** _(no story — synthesizer mode)._
- **PR:** #230 **Open**. Iter-9 landed `350f4cd` on feat-2 (2.13 D-9 nc -z -w 2 lockstep) — pushed; at iter-10 orient CI was 4/4 GREEN against `350f4cd`. Iter-10 commit `24ac971` (2.13 probe-domain three-site lockstep gate) is local-only on feat-2 — push deferred (SSH-egress port-22 timeout × 2 attempts). Next iter retries push.

## Halt criterion

When QUEUE empty AND `gh pr view 230 --json reviews,comments` shows all PR threads resolved → write `EPIC_DONE` halt with `note` field per § Halt § Autonomy guardrail: `echo '{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR review feedback addressed"}' > "$RALPH_BASE_DIR/halt"`. Do NOT introduce new halt reasons.
