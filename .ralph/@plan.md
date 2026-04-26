# Implementation Plan — `chore/pr-230-review`

> **Branch context:** `chore/pr-230-review` is the synthesizer / PR-review-tracking branch for PR #230 (Epic 2). IP + RALPH.md commits live here; QUEUE-fix code commits land directly on `feat/epic-2-packaged-devbox` (PR #230 head) via `git -C /workspace/ralph-bmad ...` per worktree-locking workaround (RALPH.md § Gotchas).

## NOW

- [ ] **Monitor PR CI on PR #230** — verify `27d4c7b` (iter-13 absorption-SHA reachability gate) clears 4/4 SUCCESS before landing 2.12. Per Guardrail 14, do NOT push the next fix while CI is in-progress.

## QUEUE (PR #230 review fix-arc)

Sourced from <https://github.com/tthew/ralph-bmad/pull/230#issuecomment-4322595769>. One per iter; commit on `feat/epic-2-packaged-devbox`.

- [ ] **2.12 sshd liveness comment** Add 1-line comment at `packages/devbox/entrypoint.sh:207-211`: "Verify sshd is listening before exec'ing the operator shell." (gate on CI GREEN for `27d4c7b`)
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
- [x] [iter-10] **2.13 probe-domain three-site lockstep gate** — new `tools/check-probe-domain-lockstep.sh` extracts dnsmasq probe-domain from `packages/devbox/docker-compose.yml` healthcheck and asserts literal in `docs/invariants/devbox-healthcheck.md` + `packages/devbox/README.md`; wired as `always_run` pre-commit hook in `.pre-commit-config.yaml`; manifest INV-prek-pre-commit-config + INV-prek-commit-msg-config contentHashes refreshed in lockstep (`4d894156 → 9bb763d4`, whole-file sha256 shared per duplicate-sourcePath schema rule). LANDED `350f4cd..24ac971` on feat-2 after two SSH-egress port-22 timeouts (3rd attempt succeeded — network flake, not sustained block). PR #230 push retriggers CI.
- [x] [iter-11] **CI-monitor deferred on api.github.com flake** — gh-CLI HTTPS:443 graphql + REST both timed out (3 attempts × 2 backoff windows; LADDER steps 1+2+3 exhausted). Independent SSH:22 reachability verified via `git ls-remote origin chore/pr-230-review` (returned head SHA, exit 0) — origin still pushable, only api.github.com path blocked. Per LADDER step 4: defer to next iter. NOW rotated to "Monitor PR CI on PR #230"; original NOW (2.14 absorption-SHA reachability) demoted to top of QUEUE — only land after CI on `24ac971` is GREEN per Guardrail 14. RALPH.md gh-CLI flake LADDER gotcha refreshed with iter-11 datapoint (step-2 REST can also fail when api.github.com path is fully blocked, not just graphql-overloaded).
- [x] [iter-12] **Monitor PR CI on PR #230 — CLEARED.** LADDER step 1 succeeded on first attempt (`gh pr checks 230` returned 4/4 SUCCESS in <2s). Independent confirmation via `gh pr view 230 --json headRefOid,statusCheckRollup,state,isDraft,mergeable`: head=`24ac9719` (matches iter-10's `24ac971` ✓), state=OPEN, mergeable=MERGEABLE, draft=false, all 4 checks (node ×2, python ×2) conclusion=SUCCESS, status=COMPLETED. api.github.com HTTPS:443 flake from iter-11 self-resolved (~1 iteration of latency). 2.14 absorption-SHA reachability rotated NOW; QUEUE → 2.12 sshd liveness comment, 2.7 arg-passthrough comment NIT.
- [x] [iter-13] **2.14 absorption-SHA reachability gate LANDED `27d4c7b` on feat-2** — closes reviewer comment `discussion_r3143866586`. New `tools/check-absorption-sha-reachable.sh` runs `git rev-parse --verify --quiet "${ABSORPTION_SHA}^{commit}"` against inline constant `5278738`; fails loud with three-line diagnostic + AMEND-path guidance if unreachable. Wired in `.pre-commit-config.yaml` as `id: absorption-sha-reachable`, `language: system`, `always_run: true` (whole-file sha256 `9bb763d4 → ba264ac9`). Both `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` contentHashes refreshed in lockstep (shared sourcePath per duplicate-sourcePath schema rule). Story 2.14 implementation-artifact Change Log v1.4 row pins the closure. Quality gates GREEN: typecheck/lint/format:check/probe-domain-lockstep/ralph-doc-budget/**absorption-sha-reachable** all PASS at commit-time; sync-gate drift only on pre-existing `INV-package-test-coverage-floor` (out-of-PR). Push first-attempt success (no retry — contra iter-10 SSH-egress flake). PR #230 push retriggers CI.

## Context

- **Phase:** PR-review (Epic 2 close-out, post-implementation).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox); PR #230 Open, awaiting review-feedback resolution + merge.
- **Epic Branch (target of fix iterations):** `feat/epic-2-packaged-devbox` (PR #230 head).
- **Working Branch (this branch):** `chore/pr-230-review` — IP + RALPH.md only.
- **Story:** _(no story — review iteration)._
- **Story State:** _(no story — synthesizer mode)._
- **PR:** #230 **Open**, MERGEABLE, head=`27d4c7b` (was `24ac9719`); iter-13 landed 2.14 absorption-SHA reachability gate. CI re-running on push; iter-14 monitors per Guardrail 14 before landing 2.12. Iter-9 landed `350f4cd` (2.13 D-9 nc -z -w 2 lockstep). Iter-10 landed `24ac971` (2.13 probe-domain three-site lockstep gate). Iter-12 monitor-cleared CI on `24ac971`.

## Halt criterion

When QUEUE empty AND `gh pr view 230 --json reviews,comments` shows all PR threads resolved → write `EPIC_DONE` halt with `note` field per § Halt § Autonomy guardrail: `echo '{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR review feedback addressed"}' > "$RALPH_BASE_DIR/halt"`. Do NOT introduce new halt reasons.
