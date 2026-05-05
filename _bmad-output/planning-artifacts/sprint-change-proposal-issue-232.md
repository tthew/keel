# Sprint Change Proposal — Devbox Network Whitelist DNS-Rotation Regression (Issue #232)

- **Date:** 2026-04-25
- **Author:** Ralph (autonomous `/bmad-correct-course` invocation, iter-2 of `chore/devbox-network-whitelist-232` branch)
- **Triggering issue:** [#232](https://github.com/tthew/ralph-bmad/issues/232)
- **Input briefing:** [`course-correction-issue-232-briefing.md`](./course-correction-issue-232-briefing.md)
- **Mode:** Batch (autonomous; no human-in-the-loop questions per Ralph guardrail #3)
- **Scope classification:** Moderate — backlog reorganisation (Story 2.18 append) + Change Log amendments on Stories 2.3 & 2.4
- **Status:** Approved for implementation (Ralph autonomous bias; human reviews via PR #235 before merge)

---

## Section 1 — Issue Summary

**Problem statement.** The devbox container's egress whitelist treats DNS-resolved IPs as the unit of enforcement instead of the domain. `packages/devbox/scripts/reload-egress.sh` snapshots whitelisted-domain IPs **once at boot** via `getent ahostsv4` / `getent ahostsv6`, then pins those IPs as static `ip daddr <addr> accept` rules in `inet keel_egress.output_v4` / `output_v6`. Multi-A round-robin DNS hosts (`github.com`, `api.github.com`) rotate beyond that snapshot. When upstream returns an IP not present in the boot-time pin, the chain's `policy drop` short-circuits the packet and the request times out at the firewall.

**Discovery context.** Inside-the-devbox investigation on iter-1 of branch `chore/devbox-network-whitelist-232` (2026-04-25). Issue body itself was unreachable — the bug under investigation blocks `gh issue view`. Live evidence was synthesised inside the runtime (see briefing Section 3 + this proposal Section 2 evidence table).

**Production impact.** The bug is **load-bearing for the autonomous Ralph loop** — every push, `gh pr` invocation, and `gh pr checks --watch` runs through `github.com` / `api.github.com`. Push-fail intermittence from epic-2 iter-281 / 299 / 321 / 340 / 341 (logged as "SSH :22 timeout retry-deferred" in the IP) traces to this same root cause.

**Triage class.** Technical-limitation discovered during implementation (per checklist 1.2 categories). The Story 2.3 design committed to "single-mechanism collapse" (SC-8) of the upstream divergent-whitelist bug, but it inherited the boot-time-snapshot-against-rotating-DNS layering mismatch as a distinct, downstream regression. Story 2.3 as shipped is correct for stable-IP services; Story 2.18 closes the rotating-IP gap.

---

## Section 2 — Live Evidence (synthesised inside iteration runtime, 2026-04-25)

| Probe                                                                  | Result                          | Implication                                                |
| ---------------------------------------------------------------------- | ------------------------------- | ---------------------------------------------------------- |
| `getent ahostsv4 github.com`                                           | `140.82.121.3` (rotates to `.4`) | DNS rotates between calls; boot-time snapshot becomes stale |
| `curl --resolve github.com:443:140.82.121.4 https://github.com/`       | `200 OK in 190ms`               | Whitelist DOES contain `.121.4`; that pinned IP works      |
| `curl https://github.com/` (real DNS)                                  | `timeout 8s`                    | Real DNS returns an IP NOT in the pinned set               |
| `curl https://raw.githubusercontent.com/`                              | `301 in 77ms`                   | Stable Fastly anycast IP works                             |
| `curl https://objects.githubusercontent.com/`                          | `404 in 115ms`                  | Stable Fastly anycast IP works                             |
| `curl https://registry.npmjs.org/`                                     | `200 OK`                        | Stable Cloudflare anycast IP works                         |

**Verdict.** Boot-time IP pin against rotating-IP DNS upstream — not a misconfigured whitelist domain, not a missing entry, not a `:443` block. The whitelist file lists `github.com` correctly; the failure is purely the IP-vs-domain layering mismatch.

---

## Section 3 — Impact Analysis

### 3.1 Epic Impact (per checklist Section 2)

| Question                                                     | Answer                                                                                                                                                                                                                                                              |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Can current epic (Epic 2) still be completed as planned?     | Yes — Stories 2.1–2.17 are all `done`. Epic 2 PR #230 still OPEN, awaiting human merge. This course-correction stacks Story 2.18 on top.                                                                                                                            |
| Required epic-level changes?                                 | **Add new story (2.18) within existing Epic 2.** No re-scope, no removal, no re-define.                                                                                                                                                                             |
| Future epics (3+) impacted?                                  | No structural impact. Epic 3 (Ralph harness) consumes the devbox runtime — the fix lives entirely inside Epic 2's substrate (`packages/devbox/`). Once Story 2.18 ships, Ralph's network primitives become reliable, removing the SSH/HTTPS retry-budget workaround. |
| Epic order or priority change?                               | None. Story 2.18 is the LAST story in Epic 2 and its merge enables the Epic 2 PR to land cleanly without continued network flakiness during human review.                                                                                                            |
| New epics needed?                                            | No.                                                                                                                                                                                                                                                                 |

**Conclusion (Epic Impact):** Direct Adjustment per checklist 4.1 — add Story 2.18 within Epic 2.

### 3.2 Artifact Conflict Analysis (per checklist Section 3)

| Artefact                                                      | Conflict?                                                                                                                                                                                                                                                                                                                       |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **PRD** (`_bmad-output/planning-artifacts/prd.md`)            | No conflict. PRD's "fail-closed devbox egress" + "operator-editable whitelist" intent is preserved. Story 2.18 strengthens enforcement at the *DNS-reply layer* — fully within FR1a / Devbox Implementation Contract.                                                                                                           |
| **Architecture** (`architecture.md`)                          | No structural change. Story 2.3's S5 dual-layer (dnsmasq + nftables) decision stands. Story 2.18 adds a third *binding* between them — the `nftset=` directive — without altering layer responsibilities.                                                                                                                       |
| **UI/UX**                                                     | N/A. This is substrate; no operator-facing UI delta.                                                                                                                                                                                                                                                                            |
| **Stories 2.3 / 2.4 (Change Log only)**                       | Amend each story's Change Log with a "Story 2.18 amendment" entry. Story 2.3's `reload-egress.sh` render step gains `nftset=` directive emission; Story 2.4's whitelist composer gains a "rotating" annotation in its input format.                                                                                              |
| **Other stories (2.5–2.17)**                                  | No impact — none touch DNS resolution or egress whitelist enforcement.                                                                                                                                                                                                                                                          |
| **Invariants** (`packages/keel-invariants/src/`, `INVARIANTS.md`) | The existing `INV-devbox-egress-contract` invariant doc gains a "Rotating-IP services" subsection citing Story 2.18. ContentHash refresh required. No new invariant ID.                                                                                                                                                          |
| **Sprint-status.yaml**                                         | One new row: `2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix: backlog` between `2-17-…` and `epic-2-retrospective`.                                                                                                                                                                                                |
| **Epics.md**                                                   | One new `##### Story 2.18:` stanza appended after Story 2.17, before the Epic 3 horizontal rule at line 1775.                                                                                                                                                                                                                    |
| **Deployment / IaC / CI**                                     | No CI exists yet (Epic 3 Story 3.7 lands `pre-push-ci-gate`). Image rebuild required to verify `dnsmasq` was compiled with `--enable-nftset` (Debian's package is — confirm at first build).                                                                                                                                     |

**Conclusion (Artifact Conflict):** No fundamental conflicts. Six artefact touches: epics.md, sprint-status.yaml, two Change Logs (Stories 2.3 + 2.4), one new story spec (2.18), and the existing invariant doc gets a future amendment when Story 2.18 ships.

### 3.3 Technical Impact

**Files Story 2.18 will touch (substrate):**

- `packages/devbox/dnsmasq/dnsmasq.conf` — emit `nftset=/<domain>/4#inet#keel_egress#gh_v4` (and IPv6 equivalent) per rotating-IP whitelisted domain. Either rendered by `reload-egress.sh` at boot, or listed inline as static directives if the rotating-IP domain set is small + stable (recommendation: render dynamically — preserves Story 2.4's per-fork override path).
- `packages/devbox/nftables/egress.nft` — declare `set gh_v4 { type ipv4_addr; flags timeout; }` and IPv6 equivalent; add `ip daddr @gh_v4 accept` rule above the marker block in both `output_v4` and `output_v6` chains. Add static fallback CIDRs `140.82.112.0/20` + `192.30.252.0/22` (GitHub published ranges) as belt-and-braces per Option C.
- `packages/devbox/scripts/reload-egress.sh` — extend the dnsmasq config render step with `nftset=` directive emission for whitelisted domains flagged "rotating".
- `packages/devbox/whitelist.default.txt` (and Story 2.4's whitelist composer) — annotate rotating-IP domains so the renderer emits `nftset=`. Proposed annotation format: a `# rotating` comment after the domain on the same line, or a `*-rotating` filename suffix on the per-category fragment in `packages/devbox/whitelist/*.txt`.
- `packages/devbox/Dockerfile` — confirm Debian's `dnsmasq` package is compiled with `--enable-nftset`. Verify at first image build; pin the dnsmasq package version in `VERSIONS.md` if not already locked.
- `docs/invariants/devbox-egress.md` — add `## Rotating-IP services` subsection documenting the dynamic accept-set mechanism + static fallback CIDR layer.
- `_bmad-output/implementation-artifacts/2-3-…md` Change Log v1.9 (or v2.0) — append "Story 2.18 amendment" entry.
- `_bmad-output/implementation-artifacts/2-4-…md` Change Log v2.3 — append "Story 2.18 amendment" entry.
- `INVARIANTS.md` — refresh contentHash for `INV-devbox-egress-contract` after `docs/invariants/devbox-egress.md` edit.
- `packages/keel-invariants/src/invariants.manifest.ts` — refresh contentHash for `INV-devbox-egress-contract` to lock the rotating-IP subsection against drift.
- Tests (Epic 13 deferred operator-workstation smoke OR replay-fixture extension) — rotating-DNS scenario validating set fills correctly across multiple DNS rounds.

**Estimated impl surface:** ~150–250 LOC across 4 substrate files + 2 doc files + 2 invariants files. Slightly larger than Story 2.4 (~360 LOC) but smaller than Story 2.3 (~650 LOC). Per the iter-155 fix-chain forecast equation `(carve-out × 3) + (live-smoke-defer × 3) + (impl-surface-LOC / 100)`: 0 carve-out + backend-B live-smoke defer (+3) + ~200 LOC (+2) → ~5 ceiling → **forecast 2–4 PATCH opener, 4–6 iter chain length**. Tighter than Story 2.3's 10-iter chain because the change is additive (no algorithmic rewrite).

---

## Section 4 — Path Forward Evaluation

### 4.1 Option 1: Direct Adjustment (RECOMMENDED)

**Add Story 2.18 to Epic 2.** Keep Stories 2.3 / 2.4 logic intact; Story 2.18 layers `nftset=` integration on top with belt-and-braces static-CIDR fallback.

- **Effort:** Medium (~150–250 LOC + 2 doc edits + manifest refresh)
- **Risk:** Low — additive change; existing static-pin path remains as fallback for non-rotating domains
- **Timeline impact:** ~4–6 Ralph iterations (lifecycle: drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done) within Epic 2's existing PR #235 stack
- **Verdict:** **Viable** ✓

### 4.2 Option 2: Potential Rollback

Revert Stories 2.3 / 2.4 and re-architect from scratch with `nftset=` as a primary mechanism rather than an addition.

- **Effort:** High (~1000+ LOC rework + 6 weeks of CR-drain re-paid)
- **Risk:** High — invalidates all four CR-closure validations + 16 Epic 2 stories that consume the existing scripts
- **Timeline impact:** Catastrophic — 4–6 weeks rework, blocks Epic 3 / 4 / 5 dependencies
- **Verdict:** **Not viable** — no simplification gain; the rollback effort is not justified

### 4.3 Option 3: PRD MVP Review

Reduce scope of devbox to drop multi-A DNS rotating-IP support entirely (e.g., document `github.com` / `api.github.com` as "use stable-IP mirror only" — no clean alternative exists at MVP scale).

- **Effort:** Low (doc-only scope reduction)
- **Risk:** High — Ralph cannot push without `github.com` egress; `gh pr` cannot run; the autonomous loop is fundamentally broken
- **Timeline impact:** Blocks the whole Ralph harness in Epic 3
- **Verdict:** **Not viable** — the bug is load-bearing for the autonomous loop

### 4.4 Selected Approach: Option 1 (Direct Adjustment) — Hybrid

Combine Option A (`dnsmasq nftset=` integration) + Option B (static GitHub CIDR fallback) per briefing Section 4.C "Combo" recommendation. Belt-and-braces matches the existing two-layer egress posture (nftables drop + dnsmasq fail-closed). Static fallback covers (a) the boot-time-to-first-DNS-reply window, and (b) catastrophic dnsmasq failure.

**Justification:**

- Implementation effort is medium and bounded (~250 LOC).
- Technical risk is low — additive change, leaves existing static-pin path as fallback.
- Team morale: closes a known load-bearing bug actively biting iterations 1+ of this very branch.
- Long-term sustainability: `nftset=` generalises to ALL future rotating-IP services (Anthropic API, OpenAI, npm, etc.) — no per-service CIDR maintenance.
- Stakeholder expectations: Tthew (issue reporter + project lead) wants the autonomous loop to be reliable. This unblocks both pending and future iterations.

---

## Section 5 — Detailed Change Proposals

### 5.1 New Story 2.18 (devbox network whitelist DNS-rotation fix)

```
Story: 2.18
Title: Devbox network whitelist DNS-rotation fix (dnsmasq nftset=) + GitHub CIDR fallback
Status: backlog
Class: infrastructure-security (Story 2.3 sibling — extends rather than replaces)
PR Target: feat/epic-2-packaged-devbox (stacks on PR #230)
Working Branch: chore/devbox-network-whitelist-232 (PR #235)
GitHub Issue: #232

User story:
  As a fork operator running Ralph inside the devbox,
  I want whitelisted multi-A DNS rotating-IP services (github.com, api.github.com) to
    remain reachable across DNS rotation,
  So that gh / git-fetch / git-push / curl to GitHub do not intermittently time out
    at the firewall layer mid-iteration.

Acceptance Criteria:

  AC1: dnsmasq nftset= directive emission per rotating-IP whitelist entry.
    Given the dnsmasq.conf template + rotating-flagged whitelist entries,
    When reload-egress.sh renders the dnsmasq config,
    Then one nftset= directive is emitted per rotating-flagged domain
      (IPv4: nftset=/<domain>/4#inet#keel_egress#gh_v4;
       IPv6: nftset=/<domain>/6#inet#keel_egress#gh_v6).

  AC2: Named accept sets in egress.nft + chain accept rules.
    Given egress.nft on a clean container,
    When start-egress.sh applies the rendered nft ruleset,
    Then `gh_v4` and `gh_v6` named sets exist with `flags timeout`,
    And `output_v4` chain contains `ip daddr @gh_v4 accept` BEFORE the static-pin marker block,
    And `output_v6` chain contains `ip6 daddr @gh_v6 accept` BEFORE the static-pin marker block,
    And the chain `policy drop` rule remains the final fall-through.

  AC3: Set fills naturally as DNS upstream returns rotating IPs.
    Given a clean container with `github.com` resolving to N rotating IPs,
    When N+1 distinct curl probes hit github.com over a short window,
    Then `nft list set inet keel_egress gh_v4` shows N+1 distinct IPs accumulated
      (set self-prunes via flags timeout = 600s default).

  AC4: Static GitHub CIDR fallback baked into egress.nft.
    Given GitHub's published public IP ranges (api.github.com/meta),
    When start-egress.sh applies the rendered nft ruleset,
    Then `output_v4` chain contains static fallback rules:
      `ip daddr 140.82.112.0/20 accept` + `ip daddr 192.30.252.0/22 accept`
      with comments citing Story 2.18 + GitHub Meta API as source.

  AC5: Replay-fixture coverage for rotating-DNS scenario.
    Given the replay-fixture suite (or equivalent operator-workstation smoke recipe),
    When a fixture simulates multiple `getent` returns over time + curl probes,
    Then the named set fills + accept rule short-circuits drops + no static IP
      is added to the chain for those domains (set replaces snapshot).

Tasks/Subtasks (12 tasks, projected ~50 subtasks): see Story 2.18 spec file.

Substrate touch list (forecasted at draft):
  - packages/devbox/dnsmasq/dnsmasq.conf
  - packages/devbox/nftables/egress.nft
  - packages/devbox/scripts/reload-egress.sh
  - packages/devbox/whitelist.default.txt + per-fragment annotation contract
  - packages/devbox/Dockerfile (verify --enable-nftset, pin VERSIONS.md)
  - docs/invariants/devbox-egress.md (Rotating-IP services subsection)
  - INVARIANTS.md + packages/keel-invariants/src/invariants.manifest.ts (contentHash refresh)
  - _bmad-output/implementation-artifacts/2-3-…md Change Log
  - _bmad-output/implementation-artifacts/2-4-…md Change Log
  - _bmad-output/implementation-artifacts/sprint-status.yaml
  - _bmad-output/planning-artifacts/epics.md (Story 2.18 stanza, this proposal)
```

Rationale: see this proposal Section 4.4. Story 2.18 spec produced as separate artefact at `_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md` per `output-location` skill convention.

### 5.2 Story 2.3 Change Log Amendment

```
Story: 2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload
Section: Change Log

PREPEND new entry:
  - **v1.9** (2026-04-25 iter-correct-course-issue-232): **Story 2.18 amendment.**
    `/bmad-correct-course` for issue #232 (devbox network whitelist DNS-rotation
    regression) appended Story 2.18 to Epic 2. Story 2.3's reload-egress.sh
    render step is amended at Story 2.18 implementation time to emit `nftset=`
    directives per rotating-flagged whitelist entry; Story 2.3's authoritative
    invariant `INV-devbox-egress-contract` gains a "Rotating-IP services"
    subsection at that time (contentHash refresh). No retroactive Story 2.3
    behaviour change at this entry — this is a forward-pointer amendment per
    BMad change-log convention. See sprint-change-proposal-issue-232.md +
    epics.md § Story 2.18 + 2-18-…md spec.

Rationale: Story 2.3's reload-egress.sh primitive was correct for stable-IP
services. Story 2.18 layers DNS-rotation handling on top without altering
Story 2.3's contracts (SC-1 through SC-17 hold byte-identical post-Story-2.18).
```

### 5.3 Story 2.4 Change Log Amendment

```
Story: 2-4-whitelist-source-of-truth-pnpm-devbox-whitelist-atomic-reload-cli
Section: Change Log

APPEND new row to table (newest at end of v2.x sequence):
  | v2.3    | 2026-04-25 | correct-course-issue-232 | **Story 2.18 amendment.**
    `/bmad-correct-course` for issue #232 (devbox network whitelist DNS-rotation
    regression) appended Story 2.18 to Epic 2. Story 2.4's whitelist composer
    is amended at Story 2.18 implementation time to support a "rotating" flag
    annotation in the per-fragment input format (proposed: filename suffix
    `*-rotating.txt` OR per-line `# rotating` annotation — pinned at Story 2.18
    spec time). The renderer (Story 2.3's reload-egress.sh) reads the flag and
    emits nftset= directives accordingly. No retroactive Story 2.4 behaviour
    change at this entry — forward-pointer amendment per BMad convention.
    See sprint-change-proposal-issue-232.md + epics.md § Story 2.18.

Rationale: Story 2.4's per-fork-override CLI + composition pipeline remains
authoritative; Story 2.18 adds an OPTIONAL annotation that defaults to
"non-rotating" (preserving byte-identical behaviour for existing whitelist
entries until annotated). SC-14 dual-composer parity contract holds because
both composers read the same annotation source.
```

### 5.4 epics.md Amendment

```
File: _bmad-output/planning-artifacts/epics.md
Section: Epic 2 (insert after line 1773 — end of Story 2.17 stanza —
         before line 1775 horizontal rule)

INSERT new stanza:
  ##### Story 2.18: Devbox network whitelist DNS-rotation fix (dnsmasq nftset= + GitHub CIDR fallback)

  As a fork operator running Ralph inside the devbox,
  I want whitelisted multi-A DNS rotating-IP services to remain reachable across DNS rotation,
  So that gh / git-fetch / git-push / curl to GitHub do not intermittently time out
    at the firewall layer mid-iteration.

  **Acceptance Criteria:** [5 ACs verbatim from Section 5.1 above; full
  Given/When/Then bodies in 2-18-…md spec]

Rationale: Direct extension of Story 2.3's egress posture; Story 2.18 closes
the rotating-IP gap left open by the boot-time-IP-pin against multi-A DNS.
```

### 5.5 sprint-status.yaml Amendment

```
File: _bmad-output/implementation-artifacts/sprint-status.yaml

INSERT new key under epic-2 block (after 2-17-… line, before epic-2-retrospective line):
  2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix: backlog

UPDATE last_updated header AND prepend a `# last_updated:` comment line:
  # last_updated: 2026-04-25 Story-2-18-appended-correct-course-issue-232 UTC
  last_updated: 2026-04-25 Story-2-18-appended-correct-course-issue-232 UTC

Note: Epic 2 itself stays `done` — Stories 2.1–2.17 are all done. Story 2.18
is a backlog addition that re-opens Epic 2 conceptually; sprint-status.yaml's
epic-2 row remains `done` until Story 2.18 actually starts dev. Cross-epic
transition logic in PROMPT_build.md handles the re-entry path.
```

---

## Section 6 — Implementation Handoff

### 6.1 Scope Classification

**Moderate** — backlog reorganisation (new story, sprint-status row, epics.md stanza, two Change Log amendments) plus implementation work that fits within Epic 2's existing PR stack (PR #235 → eventually merges to PR #230 → eventually merges to main).

### 6.2 Routing Plan

| Recipient                                                  | Responsibility                                                                                                                                                                                                                                                                                  |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Ralph autonomous loop (current iteration)**              | (a) Write this proposal to disk, (b) write Story 2.18 spec at `_bmad-output/implementation-artifacts/2-18-…md`, (c) append Story 2.18 stanza to epics.md, (d) append `2-18-…: backlog` row to sprint-status.yaml, (e) append Change Log amendments to Stories 2.3 + 2.4, (f) commit + push.    |
| **Ralph autonomous loop (next iteration)**                 | Run `/bmad-create-story` against Story 2.18 — picks up the spec authored this iteration, refines into the canonical drafted format, transitions Story State `_(no story) → drafted`. Lifecycle continues per § Story Lifecycle Decision Matrix in `.ralph/PROMPT_build.md`.                    |
| **Ralph autonomous loop (subsequent iterations, ~4–6)**    | Lifecycle drain: drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done. Implementation lands in `packages/devbox/`. Operator-workstation deferred smoke validates the rotating-DNS scenario. CR opener forecast 2–4 PATCH per the iter-155 fix-chain equation.        |
| **Tthew (human reviewer)**                                 | Reviews PR #235 once all of Epic 2's Story 2.18 lifecycle iterations land. PR #235 targets `feat/epic-2-packaged-devbox` (PR #230). On merge of PR #235 → PR #230 cascade-merges to main.                                                                                                       |
| **Image-build verification (one-off)**                     | At Story 2.18 dev-story landing, verify Debian's `dnsmasq` package is compiled with `--enable-nftset` (most recent Debian builds are; pin in `VERSIONS.md` per Story 2.3 v1.5 SC-14 precedent). If the binary lacks `--enable-nftset`, fall back to Option B (static CIDR) only.               |

### 6.3 Success Criteria

1. **Sprint Change Proposal** committed to `_bmad-output/planning-artifacts/sprint-change-proposal-issue-232.md` ✓ (this artefact).
2. **Story 2.18 spec** committed to `_bmad-output/implementation-artifacts/2-18-devbox-network-whitelist-dnsmasq-nftset-rotating-ip-fix.md` (next deliverable in this iteration).
3. **Epics.md** amended with Story 2.18 stanza after line 1773.
4. **Sprint-status.yaml** amended with `2-18-…: backlog` entry + timestamp comment.
5. **Stories 2.3 + 2.4 Change Logs** amended with forward-pointer entries.
6. **Issue #232** referenced via `Refs #232` trailer in commit messages this iteration; referenced via `Closes #232` in PR #235 body when Story 2.18 implementation lands.
7. **PR #235** stays Draft until Story 2.18's full lifecycle completes per § Story Lifecycle Decision Matrix.
8. **Subsequent iteration** kicks off `/bmad-create-story` for Story 2.18 (next NOW per IP).

### 6.4 Risks Carried Forward

- **Push/PR availability is the bug.** Best-effort `git push` from this iteration; document in IP if blocked. The DNS-rotation workaround (`curl --resolve api.github.com:443:140.82.121.5`) works for `gh pr create` / `gh pr edit` / `gh api` calls when the rotation lands a non-whitelisted IP.
- **dnsmasq `--enable-nftset` compile flag.** Image rebuild required to confirm. Fall back to Option B (static CIDR only) if Debian's binary lacks support.
- **Set lifecycle on reload.** `flush table inet keel_egress` in egress.nft will wipe the named set on every reload. dnsmasq re-fills on next DNS query but a brief in-flight window may drop new connections. Mitigated by the static fallback CIDRs (Option B layered with Option A = Option C).
- **Two-axis course correction.** Issue #232 body could not be fetched (the bug). If Tthew's framing differs from this synthesised briefing, the proposal is editable before merge — Section 4.4 is the de facto recommendation but Section 4.1–4.3 enumerate alternatives.

---

## Section 7 — Approval

**Approval mode:** Autonomous (Ralph guardrail #3 — never wait for user input). The bias is toward the path forward analysis in Section 4 selecting Option 1 (Direct Adjustment, hybrid Option A + B); Tthew has the merge gate at PR #235 review time.

**Signed-off:** Ralph autonomous loop, iter-2 of `chore/devbox-network-whitelist-232`, 2026-04-25.

---

## Section 8 — Next Steps Summary

1. ✓ This iteration: write all 6 deliverables (proposal, story spec, epics.md amendment, sprint-status.yaml row, Stories 2.3 + 2.4 Change Log amendments). Commit + push under `Refs #232` trailer.
2. Next iteration: `/bmad-create-story` for Story 2.18 — Story State `_(no story) → drafted`.
3. Iters +2..+6: Story 2.18 lifecycle drain (drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done) per § Story Lifecycle Decision Matrix.
4. PR #235 transitions Draft→Open at Story 2.18 close (final CI gate per § PR Lifecycle Decision Matrix). On open + merge: PR #230 → main cascade-merges Epic 2 plus the Story 2.18 fix.

**Issue #232 closes** at PR #235 merge via the `Closes #232` trailer in the PR body (added when Story 2.18 implementation lands and the PR is ready for human review).
