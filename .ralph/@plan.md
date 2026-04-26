# Implementation Plan — `chore/pr-230-review`

> **Branch context:** `chore/pr-230-review` is the synthesizer / PR-review-tracking branch for PR #230 (Epic 2). IP + RALPH.md commits live here; QUEUE-fix code commits land directly on `feat/epic-2-packaged-devbox` (PR #230 head) via `git -C /workspace/ralph-bmad ...` per worktree-locking workaround (RALPH.md § Gotchas).

## NOW

- [ ] **2.7 arg-passthrough comment (NIT)** — final QUEUE item. Brief 1-line comment near `packages/devbox/scripts/ralph-build-host.sh:90` on `"$@"` passthrough contract per synthesizer NIT (`#issuecomment-4322595769` § "Story 2.7 — `\"$@\"` arg passthrough undocumented"). **Gate per Guardrail 14:** iter-15 orient (step 0h) — if CI on `e9a0c5d` (iter-14 head) is GREEN, execute directly; else step 0h preempts to monitor before resuming. Per iter-pr-review-4 LESSON Monitor-bookkeeping-loop-break: treat monitor-resolution as precondition gate, not separate task. After 2.7 lands and CI clears, QUEUE empties → write `EPIC_DONE` halt per § Halt criterion.

## QUEUE (PR #230 review fix-arc)

Sourced from <https://github.com/tthew/ralph-bmad/pull/230#issuecomment-4322595769>. One per iter; commit on `feat/epic-2-packaged-devbox`.

_(empty — 2.7 is sole NIT, currently in NOW; halt forecast on closure)_

### Out-of-PR follow-ups (track elsewhere)

- 2.13 operator-workstation healthcheck smoke (mid-run service-death) → Epic 13 nightly.
- 2.18 IPv6 static CIDR fallback → revisit if egress-during-boot incidents recur.
- 2.11 manifest description drift at `invariants.manifest.ts:275` → deferred per Epic 2 close-out (SC-17).
- **Pre-existing `INV-package-test-coverage-floor` contentHash drift** (manifest declares `57555cb…`, file hashes `4d24479d…`); present at `fed3161` (iter-390) + every Epic-2 commit since. Not in 2.5b scope. Sync-gate is not yet wired to pre-commit/CI so it doesn't block; Story 1.9 follow-up.

## BLOCKED

_(none — all findings are MINOR/NIT)_

## DONE (PR #230 review iter-1..14 — 2026-04-26)

- [x] [iter-1..7] (pruned for budget — see RALPH.md § Signposts iter-pr-review-4..6 for synthesis).
- [x] [iter-8] 2.7 AC3 Change Log v1.7 — `docker attach → docker exec` evolution (`d3aecde` on feat-2; PR #230).
- [x] [iter-9] **2.13 D-9 closure (`nc -z -w 2`)** — six-site lockstep substrate sweep + Change Log v1.5 + manifest contentHash refresh (`ae0ac4b3 → b8a420a4`); reviewer's `${KEEL_DEVBOX_SSH_PORT:-2222}` half DISMISSED with rationale (host-side-publish vs container-internal-bind semantics) — `350f4cd` on feat-2; PR #230. Sync-gate clean for INV-devbox-healthcheck (pre-existing INV-package-test-coverage-floor drift unchanged).
- [x] [iter-10] **2.13 probe-domain three-site lockstep gate** — new `tools/check-probe-domain-lockstep.sh` extracts dnsmasq probe-domain from `packages/devbox/docker-compose.yml` healthcheck and asserts literal in `docs/invariants/devbox-healthcheck.md` + `packages/devbox/README.md`; wired as `always_run` pre-commit hook in `.pre-commit-config.yaml`; manifest INV-prek-pre-commit-config + INV-prek-commit-msg-config contentHashes refreshed in lockstep (`4d894156 → 9bb763d4`, whole-file sha256 shared per duplicate-sourcePath schema rule). LANDED `350f4cd..24ac971` on feat-2 after two SSH-egress port-22 timeouts (3rd attempt succeeded — network flake, not sustained block). PR #230 push retriggers CI.
- [x] [iter-11] **CI-monitor deferred on api.github.com flake** — gh-CLI HTTPS:443 graphql + REST both timed out (3 attempts × 2 backoff windows; LADDER steps 1+2+3 exhausted). Independent SSH:22 reachability verified via `git ls-remote origin chore/pr-230-review` (returned head SHA, exit 0) — origin still pushable, only api.github.com path blocked. Per LADDER step 4: defer to next iter. NOW rotated to "Monitor PR CI on PR #230"; original NOW (2.14 absorption-SHA reachability) demoted to top of QUEUE — only land after CI on `24ac971` is GREEN per Guardrail 14. RALPH.md gh-CLI flake LADDER gotcha refreshed with iter-11 datapoint (step-2 REST can also fail when api.github.com path is fully blocked, not just graphql-overloaded).
- [x] [iter-12] **Monitor PR CI on PR #230 — CLEARED.** LADDER step 1 succeeded on first attempt (`gh pr checks 230` returned 4/4 SUCCESS in <2s). Independent confirmation via `gh pr view 230 --json headRefOid,statusCheckRollup,state,isDraft,mergeable`: head=`24ac9719` (matches iter-10's `24ac971` ✓), state=OPEN, mergeable=MERGEABLE, draft=false, all 4 checks (node ×2, python ×2) conclusion=SUCCESS, status=COMPLETED. api.github.com HTTPS:443 flake from iter-11 self-resolved (~1 iteration of latency). 2.14 absorption-SHA reachability rotated NOW; QUEUE → 2.12 sshd liveness comment, 2.7 arg-passthrough comment NIT.
- [x] [iter-13] **2.14 absorption-SHA reachability gate LANDED `27d4c7b` on feat-2** — closes reviewer comment `discussion_r3143866586`. New `tools/check-absorption-sha-reachable.sh` runs `git rev-parse --verify --quiet "${ABSORPTION_SHA}^{commit}"` against inline constant `5278738`; fails loud with three-line diagnostic + AMEND-path guidance if unreachable. Wired in `.pre-commit-config.yaml` as `id: absorption-sha-reachable`, `language: system`, `always_run: true` (whole-file sha256 `9bb763d4 → ba264ac9`). Both `INV-prek-pre-commit-config` + `INV-prek-commit-msg-config` contentHashes refreshed in lockstep (shared sourcePath per duplicate-sourcePath schema rule). Story 2.14 implementation-artifact Change Log v1.4 row pins the closure. Quality gates GREEN: typecheck/lint/format:check/probe-domain-lockstep/ralph-doc-budget/**absorption-sha-reachable** all PASS at commit-time; sync-gate drift only on pre-existing `INV-package-test-coverage-floor` (out-of-PR). Push first-attempt success (no retry — contra iter-10 SSH-egress flake). PR #230 push retriggers CI.
- [x] [iter-14] **CI cleared on `27d4c7b` + 2.12 sshd liveness comment LANDED `e9a0c5d` on feat-2** (monitor + execute collapsed per iter-pr-review-4 LESSON Monitor-bookkeeping-loop-break — ~small task gated on precondition, not separate task). LADDER step 1 returned 4/4 SUCCESS in <2s on `27d4c7b` (no api.github.com flake this iter); confirmation via `gh pr view 230 --json` showed head=`27d4c7b23d…6f098d6`, state=OPEN, mergeable=MERGEABLE, mergeStateStatus=CLEAN, isDraft=false. 2.12 NIT add: 1-line `# Verify sshd is listening before exec'ing the operator shell.` at `packages/devbox/entrypoint.sh:237` directly before the post-spawn liveness probe (`sleep 0.5` → `kill -0 "${SSHD_PID}"`); reviewer's wording preserved verbatim. Reviewer cited `:207-211` referenced iter-268 file shape pre-PATCH-6; iter-278 rc-capture rewrite shifted block to `:235-242` — comment placed at the actual probe site. Story 2.12 implementation-artifact Change Log v1.9 row pins closure. `entrypoint.sh` is NOT contentHash-tracked (only `docs/invariants/devbox-ssh.md` is) — no sync-gate recompute. All pre-commit hooks PASSED at commit-time including probe-domain-lockstep + absorption-sha-reachable + ralph-doc-budget; pre-existing `INV-package-test-coverage-floor` drift unchanged. Push first-attempt success. PR #230 push retriggers CI on `e9a0c5d`. QUEUE → 2.7 arg-passthrough NIT (sole final item).

## Context

- **Phase:** PR-review (Epic 2 close-out, post-implementation).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox); PR #230 Open, awaiting review-feedback resolution + merge.
- **Epic Branch (target of fix iterations):** `feat/epic-2-packaged-devbox` (PR #230 head).
- **Working Branch (this branch):** `chore/pr-230-review` — IP + RALPH.md only.
- **Story:** _(no story — review iteration)._
- **Story State:** _(no story — synthesizer mode)._
- **PR:** #230 **Open**, MERGEABLE, head=`e9a0c5d` (was `27d4c7b`); iter-14 collapsed CI-monitor on `27d4c7b` (4/4 SUCCESS, CLEAN) + 2.12 sshd liveness comment landing per iter-pr-review-4 LESSON Monitor-bookkeeping-loop-break (~small NIT gated on precondition). CI re-running on push; iter-15 orient (step 0h) gates 2.7 NIT on `e9a0c5d` GREEN per Guardrail 14. Iter-9 `350f4cd` (2.13 D-9). Iter-10 `24ac971` (2.13 probe-domain). Iter-12 monitor-cleared `24ac971`. Iter-13 `27d4c7b` (2.14). Iter-14 `e9a0c5d` (2.12).

## Halt criterion

When QUEUE empty AND `gh pr view 230 --json reviews,comments` shows all PR threads resolved → write `EPIC_DONE` halt with `note` field per § Halt § Autonomy guardrail: `echo '{"reason":"EPIC_DONE","epic":2,"pr":230,"note":"PR review feedback addressed"}' > "$RALPH_BASE_DIR/halt"`. Do NOT introduce new halt reasons.
