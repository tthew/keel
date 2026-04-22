# Implementation Plan

## NOW

- [ ] **Drain AI-2 — pre-create `/var/log/dnsmasq.log` as dev-owned in `packages/devbox/Dockerfile`.** Add `RUN install -m 0644 -o dev -g dev /dev/null /var/log/dnsmasq.log` after the useradd chain (:261-263) and before `COPY entrypoint.sh` (:265). Preserves Story 2.3 egress-log-tailer.sh path (tails /var/log/dnsmasq.log); no tailer or script edits required. ~small.

## QUEUE (Story 2.5 CR drain → Story 2.5 CR re-run closure → Epic 2 Story 2.6..2.17 → Epic 2 close-out)

- [ ] _(after AI-2)_ **Drain AI-6 — add `libcap2-bin` to `packages/devbox/Dockerfile` apt install list** (between `libcap2-bin \` alphabetical position — after `libcairo2 \` or after `lsb-release \`; sort by package name if that's the existing convention). `setcap` at :231-232 fails `command not found` at build time without it; Ubuntu 24.04 base does not ship libcap2-bin by default. ~small.
- [ ] _(after AI-6)_ **Drain AI-3 — add `name: keel-devbox` as the first top-level key of `packages/devbox/docker-compose.yml`** so the project name matches the `keel-devbox` container-name prefix; documented `keel-devbox_keel_home_dev` volume identity now holds. ~small.
- [ ] _(after AI-3)_ **Drain AI-4 — replace Smoke B `sudo --help` in `packages/devbox/README.md:348-349` + `docs/invariants/devbox-hardening.md:135-139`** with `docker exec keel-devbox sh -c 'grep ^NoNewPrivs /proc/self/status'` (expect `NoNewPrivs:\t1`); version-independent kernel-flag inspection. Update both surfaces consistently. ~small.
- [ ] _(after AI-4)_ **Drain AI-5 — remove "or 'exec format error'" from Smoke A expected-output prose in `packages/devbox/README.md:345` + `docs/invariants/devbox-hardening.md:127`** — noexec produces EACCES only; ENOEXEC is a distinct error class. ~small.
- [ ] _(after AI-5, QUEUE empty)_ **Re-run `/bmad-code-review (args: "2")` for the `fixes-pending → sm-verified` CR-closure gate** per § Story Lifecycle Decision Matrix. Expected ZERO-PATCH close per Story 2.3 iter-171 + Story 2.4 iter-183 precedent; all 6 drained fixes adjudicated; sprint-status `2-5: review → done`; Story State `fixes-pending → sm-verified → done`.
- [ ] _(conditional, post-Story-2.5 done)_ `/bmad-create-story` for Story 2.6 (host-side `pnpm devbox:*` CLI surface) per § Story Lifecycle + § Cross-epic within-epic path. 12 backlog stories remaining in Epic 2 (2.6..2.17) after 2.5 done. Story 2.6 is the scope-owner for AR-7 /run relocation (SC-14 branch (ii)) + AR-9 /etc writes + AR-10 operator-migration docs.
- [ ] _(conditional, post-Story-2.17 done)_ Transition PR #230 Draft→Open — final CI gate; monitor; merge. Epic 2 completion.
- [ ] _(conditional, post-Epic-2 merged)_ § Cross-epic transition → Epic 3 Story 3.1 OR halt EPIC_DONE awaiting merge.
- [ ] _(after push)_ Monitor PR CI — queue fix tasks for any failures.

## BLOCKED

_(none)_

## ATDD Red Phase

_(none — Story 2.5 ATDD-skipped at iter-186 per § Story Lifecycle `validated → atdd-scaffolded` (skip branch). All 5 ACs are `docker inspect` compose-shape assertions (AC 1-4) + kernel-enforcement `docker exec` smokes (AC 5). No red-phase scaffolds warranted.)_

## DONE (Story 2.5 lifecycle — keep current story chain, prune after Story 2.6 starts)

- [x] iter-191: **Drain AI-1 — removed `user=nobody` + `group=nogroup` from dnsmasq.conf + replaced Story-2.5-revisit TODO with pin-rationale.** First of six CR drain iters (iter-191..iter-196). FR14n Story State stays `fixes-pending`; sprint-status `2-5` stays `review` per Story 2.4 iter-183 precedent. Single-file edit: `packages/devbox/dnsmasq/dnsmasq.conf` — removed directives (prev :36-37); replaced six-line TODO block (prev :33-35) with 17-line pin-rationale explaining both (a) `cap_drop: [ALL]` strips CAP_SETUID/SETGID so setuid(2)/setgid(2) would EPERM, AND (b) USER dev means dnsmasq execs as UID 1000 from PID-1 — nothing to drop to. Ambient CAP_NET_BIND_SERVICE (SC-15) cross-referenced. Quality gates GREEN: `pnpm keel-invariants:check-all` (21 manifest entries, no contentHash drift), `pnpm run format:check`. Change Log v1.3 appended; Review Findings AI-1 checkbox `[x]` with drain-narrative prepended. Next QUEUE AI-2 advanced to NOW.
- [x] iter-190: **`/bmad-code-review (args: "2")` CR opener → `fixes-pending` — 6 PATCH + 4 DEFER + ~17 DISMISS.** First Epic-2 architecture-security / container-hardening class CR opener. Acceptance Auditor ZERO AC violations (confirms iter-189 SM ZERO-PATCH); Blind + Edge Case Hunter surfaced 31 raw → triaged to 6 PATCH (AI-1 dnsmasq user/group; AI-2 dnsmasq log-facility; AI-3 compose project-name; AI-4 Smoke B NNP probe; AI-5 Smoke A error-class; AI-6 libcap2-bin setcap dep) + 4 DEFER (AR-7 /run; AR-8 compose-override runtime; AR-9 /etc writes; AR-10 volume re-use migration) + ~17 DISMISS. PATCH mid-forecast (4-8 per iter-188 trace; 6 actual). Change Log v1.2; defers appended to deferred-work.md.
- [x] iter-189: **`/bmad-create-story (args: "review")` post-dev SM → `sm-verified` — ZERO-PATCH + ZERO-DEFER close.** Fifth Epic-2 post-dev SM precedent; FIRST architecture-security class. AC 1-5 all SATISFIED; 19 SCs PASS; scope-isolation PASS. Change Log v1.1 appended.
- [x] iter-188: **`/bmad-testarch-trace (args: "yolo")` → WAIVED — `in-dev → traced`.** 15th cumulative trace-WAIVED; FIRST architecture-security class at Epic 2. Four trace artifacts authored. SIMILAR to Story 2.3 (zero-runtime-assertions) + `docker compose config` parse-smoke GREEN.
- [x] iter-187: **`/bmad-dev-story` landed Story 2.5 — `atdd-scaffolded → in-dev → review`.** Eight files per SC-19. Quality gates green end-to-end (sync-gate + check-all + typecheck + lint + format:check + compose parse).

## Context

- **Phase:** 4-implementation — Epic 2 at 4/17 stories `done` (2.1 + 2.2 + 2.3 + 2.4) + 1/17 `fixes-pending` (2.5) + 12/17 `backlog` (2.6..2.17).
- **Runtime:** cc-devbox iteration env with Docker via host socket-passthrough (backend B per `INV-devbox-dind-available`). Story 2.5 live smokes operator-workstation-deferred per Story 2.4 SC-17 precedent. Story 2.5 CR drain iters (iter-191..iter-196) run entirely docs-and-Dockerfile-and-compose-edit surface; no live-container verification required for drain itself. Sync-gate + typecheck + lint + format:check are the quality-gate chain per drain iter.
- **Baked image:** `keel-devbox:local` (iter-123 first bake; 848 MB, linux/arm64). Story 2.5 substrate introduces USER directive + setcap + cap_drop/security_opt/tmpfs/volumes + named volume — operator-workstation rebuild required to materialise. AI-6 libcap2-bin addition is REQUIRED before the next rebuild succeeds (current Dockerfile would fail at setcap RUN).
- **Epic:** Epic 2 — Sandboxed Execution Environment (devbox). 17 stories total; 2.1-2.4 done; 2.5 fixes-pending (CR drain); 2.6..2.17 backlog. Epic 2 closes at Story 2.17 (PR #230 Draft→Open transition at that point).
- **Epic Branch:** `feat/epic-2-packaged-devbox` (stays Draft across full Epic 2).
- **Story:** 2.5 — Container hardening (non-root user + capabilities + tmpfs noexec + named volume).
- **Story File:** `_bmad-output/implementation-artifacts/2-5-container-hardening-non-root-user-capabilities-tmpfs-noexec-named-volume.md`
- **Story State:** `fixes-pending` — CR opener landed at iter-190 with 6 PATCH + 4 DEFER. Drain order AI-1 → AI-2 → AI-6 → AI-3 → AI-4 → AI-5 across iter-191..iter-196 (one fix per iter per § Story Lifecycle). After QUEUE empties, re-run `/bmad-code-review (args: "2")` for `fixes-pending → sm-verified → done` CR-closure gate.
- **GitHub Issue:** Story 2.5 → #45; Epic 2 → #10.
- **PR:** #230 **Draft** — https://github.com/tthew/ralph-bmad/pull/230 (stays Draft across Epic 2).

## Notes

- **CR opener triage outcome (iter-190):** 31 raw findings (Blind Hunter ~15 + Edge Case Hunter ~16 + Acceptance Auditor 0) → 6 PATCH + 4 DEFER + ~17 DISMISS after normalization + de-duplication. All 6 PATCH are integration-class (not AC-class) — confirms iter-189 post-dev SM ZERO-PATCH AC verdict while surfacing runtime-integration concerns the spec-pure SM reduction could not. LESSON: for architecture-security class stories, SM ZERO-PATCH is compatible with CR >0 PATCH — the bars are different (AC-satisfaction under declared-spec-surface vs AC-satisfaction under FULL-runtime-integration-chain). See Change Log v1.2.
- **Ralph-hosted CR-workflow agent-type:** `bmad-review-adversarial-general` + `bmad-review-edge-case-hunter` subagent types are NOT exposed in the runtime Agent-tool catalog; invocation MUST route through `general-purpose` subagents with role-specific Blind Hunter / Edge Case Hunter / Acceptance Auditor framing. Three parallel subagents worked end-to-end at iter-190 ~80K tokens (orient 8K + diff prep 10K + fan-out 45K + triage + IP + RALPH + commit + push 17K). Under 117K budget.
- **Drain cadence and scope-boundary:** AI-1 (dnsmasq.conf — Story 2.3 file but carries explicit Story-2.5-revisit TODO; in-scope per handoff); AI-2 (Dockerfile — in scope per SC-19); AI-3 (docker-compose.yml — in scope per SC-19); AI-4/AI-5 (README + invariant doc — in scope per SC-19); AI-6 (Dockerfile — in scope per SC-19). All six fit SC-19 boundary with the Story-2.3-TODO-handoff carve-out for dnsmasq.conf. No scope creep into scripts/ or .envrc.example.
- **Sprint-status flip gate:** sprint-status.yaml `2-5` row stays `review` through iter-191..iter-196 drain iters; flips `review → done` ONLY at iter-197 (or wherever CR re-run closure lands) per Story 2.4 iter-183 + Story 2.3 iter-171 precedent. Do NOT flip sprint-status during drain iterations.
- **AI-6 is build-blocking — land before any operator-workstation rebuild attempt.** Current Dockerfile at HEAD fails `docker build` at :231 setcap RUN with `setcap: command not found` (libcap2-bin not in apt install list). iter-187 used `docker compose config` parse-smoke only — no full build. After AI-6 lands, operator-workstation rebuild succeeds.
- **Defers to Story 2.6 + 2.17:** AR-7 (SC-14 branch (ii) /run relocation) + AR-9 (/etc writes under USER dev) + AR-10 (pre-Story-2.5 volume migration docs) all carry to Story 2.6 scope-owner (host-side CLI + operator-migration); AR-8 (compose-override volume-replacement runtime gate) carries to Story 2.17 `check-devbox-compose-shape.ts`. No defer is Story 2.5 scope; all four are spec-justified or scope-extension.
- **Iter-192 budget estimate:** ~25K tokens for AI-2 (orient 6K + Dockerfile read + single-RUN insert 3K + `docker compose config` parse-smoke + quality-gate chain 3K + Change Log + IP + RALPH.md + commit + push 13K). Under 117K. Similar envelopes for AI-3..AI-6. iter-191 actual came in at ~22K per Change Log v1.3 (orient ~6K + edit ~2K + gates ~2K + docs/commit/push ~12K).
