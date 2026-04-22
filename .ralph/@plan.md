# Implementation Plan

## NOW

- [ ] **Run `/bmad-testarch-trace (args: "yolo")`** per § Story Lifecycle `in-dev → traced`. Fresh context. Story file `_bmad-output/implementation-artifacts/2-5-container-hardening-non-root-user-capabilities-tmpfs-noexec-named-volume.md`. Projected 16th-cumulative ATDD-skip-trace-WAIVED pairing per Story 2.4 iter-175 precedent + Story 2.1/2.2/2.3/2.4 precedent-chain: trace on an ATDD-skipped story with no test runner configured converges to WAIVED (no AC→test map exists because no tests exist; coverage gap recording is inapplicable; static-drift invariant doc + SM review + CR opener are the substitute adversarial-coverage surface). Expected envelope: single-iteration close with WAIVED traceability matrix + Story State `in-dev → traced` + IP QUEUE next item (post-dev SM review) advanced to NOW. ~small.

## QUEUE (Story 2.5 lifecycle → Epic 2 Story 2.6..2.17 → Epic 2 close-out)

- [ ] _(after 2.5 traced)_ `/bmad-create-story (args: "review")` post-dev SM per § Story Lifecycle `traced → sm-verified`. Fresh context. Verify every AC is satisfied by the landed implementation (Dockerfile + compose + entrypoint + invariant doc + manifest + README + AGENTS). Expected near-ZERO-PATCH per Epic-2 post-dev SM precedent (Stories 2.1-2.4 all closed near-ZERO-PATCH at post-dev SM).
- [ ] _(after 2.5 sm-verified)_ `/bmad-code-review (args: "2")` CR opener per § Story Lifecycle `sm-verified → (fixes-pending | done)`. Three-layer Ralph-hosted adversarial fan-out. Expected 6-10 PATCH drain envelope for infrastructure-security class (Story 2.3 precedent 9-PATCH; Story 2.4 precedent 5-PATCH).
- [ ] _(conditional, post-Story-2.5 done)_ `/bmad-create-story` for Story 2.6 (host-side `pnpm devbox:*` CLI surface) per § Story Lifecycle + § Cross-epic within-epic path. 12 backlog stories remaining in Epic 2 (2.6..2.17) after 2.5 done.
- [ ] _(conditional, post-Story-2.17 done)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion.
- [ ] _(conditional, post-Epic-2 merged)_ § Cross-epic transition → Epic 3 Story 3.1 OR halt EPIC_DONE awaiting merge.
- [ ] _(after push)_ Monitor PR CI — queue fix tasks for any failures.

## BLOCKED

_(none)_

## ATDD Red Phase

_(none — Story 2.5 ATDD-skipped at iter-186 per § Story Lifecycle `validated → atdd-scaffolded` (skip branch). All 5 ACs are `docker inspect` compose-shape assertions (AC 1-4) + kernel-enforcement `docker exec` smokes (AC 5). No red-phase scaffolds warranted.)_

## DONE (Story 2.5 lifecycle — keep current story chain, prune after Story 2.6 starts)

- [x] iter-187: **`/bmad-dev-story` landed Story 2.5 — FR14n Story State `atdd-scaffolded → in-dev → review`.** Single-iteration landing per Story 2.4 iter-174 precedent. Eight files per SC-19 boundary: Dockerfile (useradd dev UID/GID 1000 + chown -R dev:dev /home/dev + setcap +eip on dnsmasq/nft + USER dev before WORKDIR) + docker-compose.yml (cap_drop: [ALL] + cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE] + security_opt: [no-new-privileges:true] + tmpfs /tmp /var/tmp long-syntax with exec=false,suid=false + service volumes extended with type: volume keel_home_dev → /home/dev + top-level volumes: keel_home_dev: {}) + entrypoint.sh (WORKSPACE_OWNER default dev:dev + comment refresh; chown calls retained per SC-5) + new docs/invariants/devbox-hardening.md (~130-line prose sourcePath doc) + INVARIANTS.md (H3 + anchor) + invariants.manifest.ts (INV-devbox-homedev-named-volume with contentHash 5b2e95462566cc67fe2a575886b0d94cd28a796cd2cf9dce26480598524d67f4 captured via pnpm keel-invariants:check sync-gate protocol) + README.md (## Hardening H2) + AGENTS.md (### Container hardening H3). Quality gates green: sync-gate + check-all + typecheck + lint (16 successful) + format:check + docker compose config parse. SC-14 branch (i) happy path assumed; no edits to whitelist.sh/start-egress.sh/reload-egress.sh. Live smokes operator-workstation-deferred per Story 2.4 SC-17 precedent. sprint-status `2-5: ready-for-dev → in-progress → review`. Story State → `in-dev` at dev-story close, bumped to `review` at Status update per workflow Step 9 (Ralph's § Story Lifecycle row maps this to `in-dev` until trace converges + bumps to `traced`).
- [x] iter-186: **`/bmad-testarch-atdd` → ATDD-skip (FR14n Story State `validated → atdd-scaffolded`).** 15th-cumulative-precedent FR14n ATDD-skip. Grounds (c)+(ii)+(iii); story file untouched. See RALPH.md iter-186 signpost.
- [x] iter-185: **`/bmad-create-story (args: "review")` pre-dev SM validated Story 2.5 — `drafted → validated`; near-ZERO-PATCH closure.** Two surgical polish edits (SC-13 printf, SC-15 ambient-cap mechanism). See story file v0.2 + RALPH.md iter-185 signpost.
- [x] iter-184: **`/bmad-create-story` drafted Story 2.5 — `_(no story)_ → drafted`; sprint-status `2-5: backlog → ready-for-dev`.** 342 LOC / 19 SC / 12 Tasks. See RALPH.md iter-184 signpost.

## Context

- **Phase:** 4-implementation — Epic 2 at 4/17 stories `done` (2.1 + 2.2 + 2.3 + 2.4) + 1/17 `review` (2.5) + 12/17 `backlog` (2.6..2.17).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Story 2.5 live smokes operator-workstation-deferred per Story 2.4 SC-17 precedent. `docker compose config` parse-smoke from DinD-B at iter-187 confirmed compose file parses cleanly with every hardening stanza present.
- **Baked image:** `keel-devbox:local` (iter-123 first bake; 848 MB, linux/arm64). Story 2.5 introduces first Dockerfile USER directive + setcap + compose cap_drop/security_opt/tmpfs/volumes + named volume. Image rebuild required on operator workstation to take effect.
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; 2.1-2.4 done; 2.5 review; 2.6..2.17 backlog. Epic 2 closes at Story 2.17 (PR #230 Draft→Open transition at that point).
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** 2.5 — Container hardening (non-root user + capabilities + tmpfs noexec + named volume).
- **Story File:** `_bmad-output/implementation-artifacts/2-5-container-hardening-non-root-user-capabilities-tmpfs-noexec-named-volume.md`
- **Story State:** `in-dev` — dev-story landed at iter-187; Story file Status `review` (per workflow Step 9). iter-188 `/bmad-testarch-trace (args: "yolo")` transitions `in-dev → traced`.
- **GitHub Issue:** Story 2.5 → #45; Epic 2 → #10.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (stays Draft across Epic 2).

## Notes

- **SC-14 `/run/` empirical gate — happy-path assumed at iter-187.** Subtasks 5.1–5.5 not exercised. If operator-workstation smoke surfaces an ownership problem (tmpfs auto-mount zeros image-layer /run ownership), relocation to `/tmp/keel-state/` is a Story 2.6 carry-over per SC-14 branch (ii). Current posture: no edits to `packages/devbox/scripts/whitelist.sh` / `start-egress.sh` / `reload-egress.sh`. Task 11.8 whitelist.sh parity smoke is operator-workstation-deferred.
- **Live smoke recipes authoritative in invariant doc + README.** Every AC 1-5 smoke + SC-15 cap-exercise smoke is a copy-paste command in `docs/invariants/devbox-hardening.md` § Verification + `packages/devbox/README.md` § Hardening § Verification. M4-Pro native Docker Desktop is the authoritative AC 5 + AC 2 bounding-set verification environment.
- **SC-4 three-cap reconciliation propagated consistently.** Invariant doc + INVARIANTS.md + manifest + compose inline comment + README capability-rationale table + AGENTS.md subsection all carry the same rationale: `cap_drop: [ALL]` strips NET_BIND_SERVICE from the bounding set; kernel rejects :<1024 bind from any process; three narrow caps are minimum viable under Story 2.5's posture.
- **SC-15 ambient-cap mechanism is load-bearing under NNP.** setcap +eip on dnsmasq/nft is preserved as portability fallback but masked by `PR_SET_NO_NEW_PRIVS=1` per capabilities(7); Docker ≥19.03 `prctl(PR_CAP_AMBIENT_RAISE)` is the primary path. Dockerfile pin-rationale comment documents both mechanisms + interaction.
- **Manifest contentHash capture protocol (Story 2.3 iter-162 / Story 2.5 iter-187):** (1) insert entry with `0000...` placeholder; (2) `pnpm keel-invariants:check` reports `actualHash`; (3) replace placeholder + re-run → exit 0. DO NOT hand-compute `sha256sum` — reader canonicalization may differ.
- **Story 2.5 Change Log v1.0 row appended.** v0.1 (drafted) → v0.2 (pre-dev SM) → v1.0 (dev-story landed). No intermediate ATDD-skip row per Story 2.4 iter-173 ATDD-skip-no-Change-Log-row precedent.
- **iter-188 NEXT = `/bmad-testarch-trace (args: "yolo")`**. Projected 16th-cumulative ATDD-skip-trace-WAIVED pairing (Story 2.4 iter-175 precedent).
