# Story 2.18: Devbox network whitelist DNS-rotation fix (dnsmasq nftset= + GitHub CIDR fallback)

Status: backlog

## Story

As a fork operator running Ralph inside the devbox,
I want whitelisted multi-A DNS rotating-IP services (`github.com`, `api.github.com`) to remain reachable across DNS rotation,
So that `gh` / `git fetch` / `git push` / `curl` to GitHub do not intermittently time out at the firewall layer mid-iteration.

## Acceptance Criteria

**AC1 — `dnsmasq nftset=` directive emission per rotating-IP whitelist entry.**

**Given** the `dnsmasq.conf` template + rotating-flagged whitelist entries,
**When** `reload-egress.sh` renders the dnsmasq config,
**Then** one `nftset=` directive is emitted per rotating-flagged domain
- IPv4: `nftset=/<domain>/4#inet#keel_egress#gh_v4`
- IPv6: `nftset=/<domain>/6#inet#keel_egress#gh_v6`
**And** non-rotating domains keep the existing static-pin path (no behavioural regression for stable-IP services).

**AC2 — Named accept sets in `egress.nft` + chain accept rules.**

**Given** `egress.nft` on a clean container,
**When** `start-egress.sh` applies the rendered nft ruleset,
**Then** named sets `gh_v4` and `gh_v6` exist with `flags timeout` and a sane default TTL (proposed 600s),
**And** the `output_v4` chain contains `ip daddr @gh_v4 accept` BEFORE the existing static-pin marker block,
**And** the `output_v6` chain contains `ip6 daddr @gh_v6 accept` BEFORE the existing static-pin marker block,
**And** the chain `policy drop` rule remains the final fall-through.

**AC3 — Set fills naturally as DNS upstream returns rotating IPs.**

**Given** a clean container with `github.com` resolving to N rotating IPs,
**When** N+1 distinct `curl https://github.com/` probes complete over a short window,
**Then** `nft list set inet keel_egress gh_v4` shows N+1 distinct IPs accumulated in the set,
**And** no static `ip daddr <addr> accept` rule is added to the chain for `github.com` (set replaces snapshot),
**And** the set self-prunes via `flags timeout` (default 600s) — entries expire after the timeout if not renewed by subsequent DNS replies.

**AC4 — Static GitHub CIDR fallback baked into `egress.nft`.**

**Given** GitHub's published public IP ranges (per `https://api.github.com/meta`),
**When** `start-egress.sh` applies the rendered nft ruleset,
**Then** the `output_v4` chain contains static fallback rules with comments citing this story:
- `ip daddr 140.82.112.0/20 accept comment "Story 2.18 GitHub web/api CIDR fallback (Option B)"`
- `ip daddr 192.30.252.0/22 accept comment "Story 2.18 GitHub legacy CIDR fallback (Option B)"`
**And** these rules apply BEFORE the marker block to short-circuit any in-flight requests during the dnsmasq-to-nftset propagation window,
**And** the static CIDR ranges are sourced from a comment block in `egress.nft` citing the GitHub Meta API endpoint as authority.

**AC5 — Replay-fixture / smoke coverage for the rotating-DNS scenario.**

**Given** the operator-workstation smoke recipe (or replay-fixture suite when one lands at Epic 13),
**When** a fixture / smoke simulates multiple `getent` returns over time + sequential `curl` probes against `github.com`,
**Then** the named set fills correctly across multiple rotation rounds,
**And** the accept rule short-circuits the would-be drop,
**And** no static IP is added to the chain for those domains (set replaces snapshot),
**And** an inline-bake-prone smoke (under iteration env) at minimum verifies the `nftset=` directives are emitted by `reload-egress.sh` (config-render-only verification — full kernel-state verification deferred to operator workstation per Story 2.3 backend-B precedent).

## Tasks / Subtasks

(Authored at `/bmad-create-story` time per FR14n § Story Lifecycle. Forecast 12 tasks / ~50 subtasks per Story 2.3 / 2.4 precedent. Listed here as scaffolding for the next iteration's `/bmad-create-story` invocation.)

- [ ] **Task 1 — Confirm `dnsmasq` `--enable-nftset` compile flag in image build.**
  - [ ] Subtask 1.1: `docker run --rm <devbox-image> dnsmasq --version | grep -i 'nftset'` returns the feature in the build flags list. If not present, escalate per Section 6.4 risk: fall back to Option B (static CIDR only).
  - [ ] Subtask 1.2: pin `dnsmasq` package version in `VERSIONS.md` per Story 2.3 v1.5 SC-14 precedent.

- [ ] **Task 2 — Define the "rotating" annotation contract for whitelist entries.**
  - [ ] Subtask 2.1: pin annotation format. Two candidates: (a) per-line `# rotating` comment after the domain, or (b) per-fragment filename suffix `*-rotating.txt`. Recommendation: (b) — clean separation, no per-line parsing, composable with Story 2.4's per-fork override.
  - [ ] Subtask 2.2: rename `packages/devbox/whitelist/github.txt` → `packages/devbox/whitelist/github-rotating.txt` (and any other rotating-IP fragments — `anthropic.txt` if Anthropic API rotates, etc.).
  - [ ] Subtask 2.3: document the contract in `packages/devbox/whitelist.default.txt` header.
  - [ ] Subtask 2.4: extend Story 2.4's `compose_whitelist()` (in `start-egress.sh`) and `compose_whitelist_into()` (in `whitelist.sh`) to track which fragment a domain came from — needed at directive-render time to flag rotating vs static.

- [ ] **Task 3 — Extend `dnsmasq.conf` rendering in `reload-egress.sh`.**
  - [ ] Subtask 3.1: between marker `# === BEGIN dnsmasq dynamic block ===` and `# === END dnsmasq dynamic block ===`, emit `nftset=/<domain>/4#inet#keel_egress#gh_v4` (and IPv6 equivalent) for every domain sourced from a `*-rotating.txt` fragment.
  - [ ] Subtask 3.2: continue emitting existing `server=/<domain>/${KEEL_DEVBOX_DNS_UPSTREAM}` for ALL domains (rotating + static) — DNS forwarding posture is unchanged.
  - [ ] Subtask 3.3: ensure rendering is deterministic + alphabetical by domain (matches existing render convention).

- [ ] **Task 4 — Extend `egress.nft` template with named sets + accept rules + static CIDR fallback.**
  - [ ] Subtask 4.1: declare `set gh_v4 { type ipv4_addr; flags timeout; }` and `set gh_v6 { type ipv6_addr; flags timeout; }` in the `inet keel_egress` table block.
  - [ ] Subtask 4.2: add `ip daddr @gh_v4 accept comment "Story 2.18 dnsmasq nftset= dynamic accept (Option A)"` to `output_v4` BEFORE the static-pin marker.
  - [ ] Subtask 4.3: add `ip6 daddr @gh_v6 accept comment "Story 2.18 dnsmasq nftset= dynamic accept (Option A)"` to `output_v6` BEFORE the static-pin marker.
  - [ ] Subtask 4.4: add static CIDR fallback rules per AC4 with citing comments.
  - [ ] Subtask 4.5: verify `nft -c -f egress.nft` syntax check passes (deferred to operator workstation per Story 2.3 backend-B carve-out).

- [ ] **Task 5 — Set lifecycle on reload.**
  - [ ] Subtask 5.1: confirm that `flush table inet keel_egress` in `egress.nft` wipes the named set on every reload (acceptable — dnsmasq re-fills on next DNS query, plus Option B static-CIDR fallback covers the gap).
  - [ ] Subtask 5.2: document the brief in-flight window risk in `docs/invariants/devbox-egress.md § Rotating-IP services` + cite Option B mitigation.

- [ ] **Task 6 — Update `docs/invariants/devbox-egress.md` with Rotating-IP services subsection.**
  - [ ] Subtask 6.1: add `## Rotating-IP services` section under the existing Mechanism heading, citing Story 2.18.
  - [ ] Subtask 6.2: document the `nftset=` mechanism + named set declaration + static CIDR fallback layer.
  - [ ] Subtask 6.3: refresh `INV-devbox-egress-contract` contentHash in `packages/keel-invariants/src/invariants.manifest.ts` per Story 1.9 sync-gate protocol.

- [ ] **Task 7 — Refresh `INVARIANTS.md` agent-readable bullet for the rotating-IP addition.**
  - [ ] Subtask 7.1: extend the `INV-devbox-egress-contract` bullet under § Devbox egress (Story 2.3) — now reads "+ Story 2.18 rotating-IP fix".

- [ ] **Task 8 — Story 2.3 + Story 2.4 Change Log amendments (forward-pointers).**
  - [ ] Subtask 8.1: prepend Story 2.3 Change Log entry per Sprint Change Proposal § 5.2.
  - [ ] Subtask 8.2: append Story 2.4 Change Log row per Sprint Change Proposal § 5.3.

- [ ] **Task 9 — Smoke validation (operator-workstation-deferred for live tests; iteration-env config-render verification only).**
  - [ ] Subtask 9.1: iteration-env smoke — render `dnsmasq.conf` from a `*-rotating.txt` fragment, grep for `nftset=` directive presence + correct format.
  - [ ] Subtask 9.2: iteration-env smoke — render `egress.nft` and grep for `set gh_v4`, `@gh_v4 accept`, and the static CIDR fallback rules.
  - [ ] Subtask 9.3: iteration-env smoke — `bash -n reload-egress.sh` syntax check.
  - [ ] Subtask 9.4: operator-workstation smoke — full live container test: boot clean container, hit `github.com` repeatedly, verify `nft list set inet keel_egress gh_v4` accumulates IPs, verify static-CIDR-fallback rules are present.

- [ ] **Task 10 — `packages/devbox/README.md` + `AGENTS.md` documentation updates.**
  - [ ] Subtask 10.1: extend README § Egress policy with a `### Rotating-IP services` H3 documenting the `nftset=` mechanism + the `*-rotating.txt` annotation contract + the static CIDR fallback.
  - [ ] Subtask 10.2: extend `AGENTS.md § Devbox iteration environment` with a brief pointer to the same.

- [ ] **Task 11 — Sprint-status.yaml flip + cross-reference Story 2.18 in story file.**
  - [ ] Subtask 11.1: at story open: `2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix: backlog → ready-for-dev`.
  - [ ] Subtask 11.2: timestamp comment line added per existing convention.

- [ ] **Task 12 — Change Log v1.0 + sprint-status flip (lifecycle hygiene at story creation).**
  - [ ] Subtask 12.1: add v1.0 entry to this story file's Change Log section (iter number, draft summary, Status transition `backlog → ready-for-dev`, sprint-status transition).
  - [ ] Subtask 12.2: subsequent versions (v1.1 pre-dev SM, v1.2 ATDD-skip, v1.3 dev-story landing, v1.4 trace, v1.5 post-dev SM, v1.6+ CR) follow Story 2.3 / 2.4 precedent.

## Dev Notes

### Scope clarifications (pinned at draft, MUST be honored — not re-negotiable without Change Log entry)

- **SC-1: Story 2.18 is additive, not replacement.** Existing static-pin path in `reload-egress.sh` for non-rotating domains stays intact. Only rotating-flagged domains route through `nftset=`.
- **SC-2: Rotating-flag annotation = filename suffix `*-rotating.txt`.** Per Task 2 Subtask 2.1 recommendation. Per-line annotation is REJECTED to avoid SC-5 LDH regex surface area changes in `whitelist.sh validate_sources` (Story 2.4's regex line-bound contract holds byte-identical).
- **SC-3: dnsmasq nftset directive format.** `nftset=/<domain>/4#inet#keel_egress#gh_v4` (IPv4); `nftset=/<domain>/6#inet#keel_egress#gh_v6` (IPv6). Both directives emit BOTH per domain — dnsmasq fills based on which A/AAAA record the upstream returns.
- **SC-4: Set names are STATIC per family.** `gh_v4` / `gh_v6` regardless of how many rotating-IP services we whitelist. All rotating domains share the same set per family. Trade-off: simpler nft rules + Option C static-CIDR fallback covers GitHub specifically; if a future rotating service has its own published CIDR ranges, that gets a sibling set in a future story (e.g., `INV-anthropic-rotating` with `anthropic_v4` set + Anthropic CIDR).
- **SC-5: Set timeout default = 600s** (10 minutes). Overridable via `${KEEL_DEVBOX_NFTSET_TIMEOUT}` retunable knob in `.envrc.example` per Story 2.3 v1.5 SC-14 precedent.
- **SC-6: Static CIDR fallback ranges.** `140.82.112.0/20` (GitHub web/api) + `192.30.252.0/22` (GitHub legacy). `185.199.108.0/22` (Pages/raw) intentionally NOT added because Story 2.3's existing static-pin path covers it via stable-IP host whitelist (`raw.githubusercontent.com`).
- **SC-7: Set lifecycle.** `flags timeout` self-prunes stale entries. `flush table` on reload wipes the set; dnsmasq re-fills on next DNS query (typical < 1s); Option B static-CIDR covers the propagation gap.
- **SC-8: Single consolidated invariant.** `INV-devbox-egress-contract` extends to cover Story 2.18 — does NOT split. Story 2.3's iter-151 AR-2 lesson (split-invariant asymmetry risk) carries forward.
- **SC-9: No new contentHash refresh hot-path.** ContentHash refresh required ONCE at Story 2.18 dev-story landing per Story 1.9 sync-gate protocol. After landing, Story 2.18 substrate is locked.
- **SC-10: Verification command pinned.** `nft list set inet keel_egress gh_v4` reads the dynamic accept set; `nft list chain inet keel_egress output_v4 | grep -E '@gh_v4|140\\.82\\.112\\.0/20'` verifies both Option A + Option B layers are present.
- **SC-11: Story 2.4 dual-composer parity contract MUST hold.** Both `compose_whitelist()` (in `start-egress.sh`) and `compose_whitelist_into()` (in `whitelist.sh`) MUST produce byte-identical composed output AND identically classify rotating-vs-static domains. Smoke harness extension: assert the rotating-classification metadata is identical across both composers.

### Forecast — fix-chain envelope

Per the iter-155 fix-chain forecast equation `(carve-out × 3) + (live-smoke-defer × 3) + (impl-surface-LOC / 100)`:
- 0 source carve-out
- backend-B live-smoke defer (+3)
- ~200 LOC impl (+2) — dnsmasq.conf render extension + egress.nft set declarations + static CIDR rules + reload-egress.sh annotation parsing
- = ~5 ceiling → **forecast 2–4 PATCH at CR opener, 4–6 iter chain length**

Tighter than Story 2.3's 10-iter chain because (a) the change is additive (no algorithmic rewrite of `reload-egress.sh`), (b) no IPv6 parity surprise (Story 2.3 already established IPv4 + IPv6 set declaration patterns), (c) the dual-composer parity invariant is an extension of Story 2.4's existing SC-14 contract (not a new contract).

### Backend-B carve-out

Live smokes (Subtask 9.4 full container test) deferred to operator workstation per Story 2.1 iter-127 + Story 2.3 iter-159 + Story 2.4 iter-176 precedent. Iteration-env evidence (Subtasks 9.1–9.3 config-render verification + bash -n) verifies syntactic correctness; live kernel-state verification requires a hardened container with `cap_add: [NET_ADMIN, NET_RAW]` (Story 2.5 posture) plus DNS upstream connectivity (which is the very bug being fixed — chicken-and-egg only at first deployment).

### Verification commands (operator-workstation)

```bash
# Confirm dnsmasq is running with nftset support
docker exec <devbox> dnsmasq --version | grep -i nftset

# Trigger DNS queries to populate the set
docker exec <devbox> getent ahostsv4 github.com  # repeat 3-5 times to see rotation
docker exec <devbox> getent ahostsv4 api.github.com  # repeat 3-5 times

# Verify the set fills (expect multiple distinct IPs)
docker exec <devbox> nft list set inet keel_egress gh_v4

# Verify chain accept rules
docker exec <devbox> nft list chain inet keel_egress output_v4 | grep -E '@gh_v4|140\.82\.112\.0/20'

# End-to-end smoke
docker exec <devbox> curl -sS -o /dev/null -w '%{http_code}\n' https://github.com/  # 200
docker exec <devbox> curl -sS -o /dev/null -w '%{http_code}\n' https://api.github.com/zen  # 200
```

### Architectural rationale

**Why `nftset=` over hardcoded CIDRs alone (Option B alone)?**
Maintenance burden grows linearly with whitelisted services. Anthropic API, OpenAI, npm registry, etc. all have rotating-IP backends. A static-CIDR-only solution requires per-service CIDR maintenance with quarterly stale-prone updates. `nftset=` generalises to any future rotating-IP whitelist entry without per-service CIDR work.

**Why static CIDRs as belt-and-braces (Option C: A + B)?**
Two narrow but real failure modes: (1) the boot-time-to-first-DNS-reply window between container start and dnsmasq populating the set; (2) catastrophic dnsmasq failure mode (process death / config corruption). Static CIDRs cover both — at the cost of one extra rule per chain. This matches Story 2.3's existing two-layer egress posture (nftables drop + dnsmasq fail-closed) — a third belt-and-braces layer is consistent with the established design philosophy.

**Why not modify Story 2.3's reload-egress.sh boot-time getent loop instead?**
The boot-time loop was correct as designed for stable-IP services. Removing it would regress non-rotating domains. The cleanest separation is: keep the static-pin path for stable-IP, add `nftset=` for rotating-IP, classify domains via Story 2.4's whitelist composer.

### Cross-story scope boundary

| Story    | Status | Story 2.18 scope-impact                                                                                                                                                                                                       |
| -------- | ------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2.3      | done   | Forward-pointer Change Log amendment (Sprint Change Proposal § 5.2). `reload-egress.sh` gains `nftset=` directive emission; `INV-devbox-egress-contract` gains a Rotating-IP services subsection. Existing contracts hold.    |
| 2.4      | done   | Forward-pointer Change Log amendment (Sprint Change Proposal § 5.3). Whitelist composer gains rotating-vs-static classification metadata. SC-14 dual-composer parity contract extended (still byte-identical post-extension). |
| 2.5–2.17 | done   | No impact — none touch DNS resolution or egress whitelist enforcement.                                                                                                                                                        |
| Epic 3+  | backlog | Forward consumer — `gh pr` + `git push` + Anthropic API calls become reliable post-Story-2.18. No structural epic change.                                                                                                     |

### Risk register

- **Image rebuild required.** `dnsmasq --enable-nftset` compile flag must be present. Most recent Debian builds are; verify at first build.
- **Brief in-flight window on reload.** `flush table` wipes the set; dnsmasq re-fills < 1s typical. Static CIDR fallback covers.
- **Push availability is the bug under fix.** Best-effort `git push` from the iteration that lands Story 2.18; document in IP if blocked. Dual mechanism — `curl --resolve api.github.com:443:140.82.121.5` workaround for `gh` calls — recorded in IP § Notes.
- **Story 2.4 SC-14 dual-composer parity extension.** New classification metadata MUST be byte-identical across both composers; Subtask 7.4 (Story 2.4) parity-smoke harness extension required at impl time.

### Source citations

- `_bmad-output/planning-artifacts/sprint-change-proposal-issue-232.md` — full proposal authority.
- `_bmad-output/planning-artifacts/course-correction-issue-232-briefing.md` — synthesised root-cause + evidence + fix options briefing.
- `_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md` — sibling story; reload-egress.sh primitive author + IPv4/IPv6 chain pattern + atomic-reload contract.
- `_bmad-output/implementation-artifacts/2-4-whitelist-source-of-truth-pnpm-devbox-whitelist-atomic-reload-cli.md` — sibling story; whitelist composer + per-fork override pattern.
- `_bmad-output/planning-artifacts/epics.md § Story 2.18` — epic-level user-outcome statement (added by this course-correction).
- `docs/invariants/devbox-egress.md` — invariant doc destination for rotating-IP services subsection.
- `https://api.github.com/meta` — authoritative source for GitHub published CIDR ranges (Option B).

## Dev Agent Record

(Empty until `/bmad-dev-story` lands at Story State `atdd-scaffolded → in-dev`.)

## File List

(Empty until `/bmad-dev-story` lands.)

## Change Log

- **v0.1** (2026-04-25 iter-correct-course-issue-232): **Initial spec drafted by `/bmad-correct-course`.** Issue #232 course-correction produced this spec from the synthesised briefing + sprint-change-proposal. Status `backlog`. ACs (5) + Tasks (12 / ~50 subtasks) + Dev Notes (11 SCs) authored. Forecast 2–4 PATCH opener, 4–6 iter chain length per the iter-155 fix-chain equation. Next: `/bmad-create-story` invocation in fresh context per § Story Lifecycle Decision Matrix `_(no story) → drafted` to refine into the canonical drafted format. Substrate not touched at this entry; this is the planning artefact only.
