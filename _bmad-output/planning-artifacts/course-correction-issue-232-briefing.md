# Course-Correction Briefing — devbox network whitelist DNS-rotation regression (issue #232)

- **Date:** 2026-04-25
- **Trigger:** [Issue #232](https://github.com/tthew/ralph-bmad/issues/232) — devbox container egress to `github.com` drops intermittently; `gh`/SSH/HTTPS to GitHub fails inside the iteration runtime.
- **Authoring skill (next iteration):** `/bmad-correct-course` consumes this briefing as input.
- **Target branch for delivery:** stacks on `feat/epic-2-packaged-devbox` (PR #230 still OPEN, awaiting human merge).
- **Working branch:** `chore/devbox-network-whitelist-232`.
- **Status:** Draft briefing produced from prior-iteration live investigation. `/bmad-correct-course` will refine into a sprint-change proposal.

---

## Section 1 — Issue Summary (synthesized from inside-the-devbox repro; issue #232 body unreachable due to the bug being investigated)

`gh api`, `gh issue view`, `git fetch origin`, and direct `curl https://github.com/` from inside the devbox iteration runtime fail intermittently with timeouts to `:443` and `:22`. `raw.githubusercontent.com`, `objects.githubusercontent.com`, and `registry.npmjs.org` continue to work. Recent epic-2 iteration history (iter-281 / 299 / 321 / 340 / 341) shows recurring `push-fail` notes in the IP captured as "SSH :22 timeout retry-deferred" — same root cause, surfaced as flaky pushes rather than full outages.

The bug is **load-bearing for the autonomous loop**: every push, every `gh pr` call, every `gh pr checks --watch` runs through `github.com` / `api.github.com`, both of which are subject to the failure mode.

---

## Section 2 — Root Cause (mechanism, not symptom)

`packages/devbox/scripts/reload-egress.sh` resolves whitelisted hostnames **once at container boot** via `getent ahostsv4` / `getent ahostsv6`, then pins the resolved IPs as static `ip daddr <addr> accept` rules in `inet keel_egress.output_v4` / `output_v6`. The corresponding `dnsmasq.conf` marker block emits `server=/<domain>/${KEEL_DEVBOX_DNS_UPSTREAM}` directives that simply forward DNS — they do NOT update the nftables accept set.

`github.com` and `api.github.com` use **round-robin DNS** with multiple A-record IPs in `140.82.0.0/16`. The boot-time `getent` snapshot captures one or two IPs; subsequent DNS responses can return any IP from the rotating pool. When the upstream DNS returns an IP not present in the boot-time snapshot, the nftables `policy drop` short-circuits the egress packet — the request times out at the firewall layer.

Symptoms cluster on `github.com` (multi-A round-robin, ~6+ rotating IPs in `140.82.121.x` / `140.82.112.x` / `140.82.114.x` ranges) and `api.github.com` (same backend pool). Stable single-IP-per-region anycast hosts (`raw.githubusercontent.com` / `objects.githubusercontent.com` on Fastly, `registry.npmjs.org` on Cloudflare) work because the boot-time snapshot remains valid for the lifetime of the container.

---

## Section 3 — Live Evidence (gathered from iteration 1, inside this devbox runtime)

| Probe | Result | Implication |
| --- | --- | --- |
| `getent ahostsv4 github.com` | `140.82.121.3` (then `.4` minutes later) | DNS rotates between calls |
| `curl --resolve github.com:443:140.82.121.4 https://github.com/` | `200 OK in 190ms` | The whitelist DOES contain `.121.4`; that IP works |
| `curl https://github.com/` (real DNS) | `timeout 8s` | Real DNS returns an IP not in the pinned set |
| `curl https://raw.githubusercontent.com/` | `301 in 77ms` | Stable anycast IP works |
| `curl https://objects.githubusercontent.com/` | `404 in 115ms` | Stable anycast IP works |
| `curl https://registry.npmjs.org/` | `200 OK` | Stable anycast IP works |

The mechanism is conclusively a boot-time IP pin against a rotating-IP DNS upstream — not a misconfigured whitelist domain, not a missing entry, not a `:443` block. The whitelist file lists `github.com` correctly; the failure is purely the IP-vs-domain layering mismatch.

---

## Section 4 — Fix Options

### Option A (preferred) — `dnsmasq nftset=` integration

`dnsmasq` was designed for exactly this scenario. Adding `nftset=/<domain>/4#inet#keel_egress#<setname>` directives causes each DNS reply for that domain to insert the resolved IPv4 into the named nftables set; an IPv6 variant (`nftset=/<domain>/6#inet#keel_egress#<setname_v6>`) handles AAAA. The set then participates in the `output_v4` / `output_v6` chains via `ip daddr @<setname> accept`.

The set accumulates IPs naturally as the DNS upstream returns new addresses — no boot-time snapshot, no rotation gap. Pin TTLs to a sane value (e.g. 600s) so the set self-prunes stale entries; or use `nftset=/<domain>/<flags>#table#name` with timeout-aware sets.

**Pros.** One-shot fix; ergonomic (uses dnsmasq the way it was designed); naturally handles all multi-A round-robin domains, not just `github.com`; preserves existing static-pin path as fallback for domains that don't transit dnsmasq.

**Cons.** Requires `dnsmasq` binary version with `nftset=` support (compiled in; check current image build); the nftables chain rule needs `ip daddr @<setname> accept` added per-chain; new state in the firewall (a named set) needs lifecycle management on container restart (set is anonymous → recreated; set is persistent → may carry stale IPs across reboots).

**Files touched.**

- `packages/devbox/dnsmasq/dnsmasq.conf` — add `nftset=/github.com/4#inet#keel_egress#gh_v4` (and equivalent IPv6 + per-rotating-IP-domain). Inject via `reload-egress.sh` per-domain rendering, OR list inline as static directives if the rotating-IP set is small + stable.
- `packages/devbox/nftables/egress.nft` — declare `set gh_v4 { type ipv4_addr; flags timeout; }` (and IPv6); add `ip daddr @gh_v4 accept` rule above the marker block; same for output_v6.
- `packages/devbox/scripts/reload-egress.sh` — render the `nftset=` directives during the dnsmasq config render step.
- Tests — extend `replay-fixtures` with a "rotating-DNS upstream" scenario validating the set fills correctly across multiple DNS rounds.

### Option B (fallback) — hardcoded GitHub CIDR ranges

GitHub publishes its public IP ranges via [`https://api.github.com/meta`](https://api.github.com/meta) (which requires the very network we're trying to fix to fetch — chicken/egg). The ranges are reasonably stable: `140.82.112.0/20` (web/api), `192.30.252.0/22` (legacy), `185.199.108.0/22` (Pages/raw — already implicitly covered).

**Pros.** Simple, no new dnsmasq feature dependency, fully static.

**Cons.** Stale-prone (GitHub adds/removes ranges over multi-quarter timescales without strong notice); doesn't generalize to other rotating-IP services we'll inevitably whitelist later (Anthropic API, npm, OpenAI, etc.); the maintenance burden grows linearly with whitelisted services.

**Files touched.**

- `packages/devbox/nftables/egress.nft` — add static `ip daddr 140.82.112.0/20 accept`, `ip daddr 192.30.252.0/22 accept` to `output_v4`.
- `packages/devbox/scripts/reload-egress.sh` — no change (CIDR rules are static, not derived from whitelist).
- Documentation — `packages/devbox/README.md` § "Whitelisted Services" gets a "manual CIDR maintenance" note.

### Option C (combo, recommended for completeness) — Option A primary + Option B fallback

Wire `nftset=` for the dynamic path; ALSO bake in the published GitHub CIDR ranges as a static safety net. The fallback covers (a) the moment between container boot and the first DNS reply that adds the active IP, and (b) catastrophic dnsmasq failure mode. This is `belt-and-braces` matching the existing two-layer egress posture (nftables drop + dnsmasq fail-closed).

---

## Section 5 — Recommended Scope (subject to /bmad-correct-course refinement)

- **New Story 2.18** — devbox egress: `dnsmasq nftset=` integration for rotating-IP services (issue #232).
  - AC1: `dnsmasq.conf` template carries one `nftset=` directive per rotating-IP whitelist entry; `reload-egress.sh` renders them per current whitelist.
  - AC2: `egress.nft` declares `gh_v4` / `gh_v6` named sets with `flags timeout` and a sane default TTL; `output_v4` / `output_v6` chains accept on `ip daddr @gh_v4` (and equivalent v6) BEFORE the static-pin marker block.
  - AC3: Boot from a clean container with `github.com` resolving to N rotating IPs; assert N+1 distinct IPs accumulate in `gh_v4` after a series of `curl https://github.com/` round-robin probes; assert no static `ip daddr` is added to the chain for these domains (set replaces snapshot).
  - AC4: Static fallback CIDRs for `140.82.112.0/20` + `192.30.252.0/22` baked into `egress.nft` with a comment citing this story; tested via `nft list chain` assertions.
  - AC5: Replay-fixture coverage: rotating-DNS scenario (multiple `getent` returns over time) validates set fills correctly + queue does not require restart.
- **Amended Story 2.3** (egress reload primitive) — Change Log entry referencing Story 2.18 + brief rationale (no functional Story 2.3 change; its render-step now emits `nftset=` directives).
- **Amended Story 2.4** (whitelist composer) — Change Log entry noting which whitelist domains are flagged "rotating" (annotation in the composer's input format) so the renderer knows when to emit `nftset=`.
- **No epic re-numbering.** Story 2.18 appended after existing 2.17. `sprint-status.yaml` gets one new key under `epic-2:`.
- **PR target:** `feat/epic-2-packaged-devbox` (stacks on PR #230). The course-correction lands in the same merge window as Epic 2 close so iteration 3 picks up the fix immediately.

---

## Section 6 — Risks + Constraints

- **Push/PR availability is itself the bug.** Best-effort push from this iteration; document in IP if blocked. (This iteration's push was attempted at 2026-04-25 11:46 UTC — github.com:443 currently returns 200 in 146ms, so the rotation window is favorable.)
- **Image rebuild required.** `dnsmasq` `nftset=` support depends on the dnsmasq binary compile flags. The current `packages/devbox/Dockerfile` installs dnsmasq via apt — verify Debian's dnsmasq is built with `--enable-nftset` (most recent Debian builds are; pinned VERSION in `VERSIONS.md` covers this).
- **Set lifecycle on reload.** `flush table inet keel_egress` in `egress.nft` line 39 will wipe the named set on every reload — acceptable since dnsmasq re-fills on the next DNS query, BUT means a brief in-flight window where new connections to rotating-IP services may drop. Mitigated by the static fallback CIDRs (Option C).
- **Two-axis course correction.** Issue #232 was untriaged when iteration 1 began; the body could not be fetched (the bug). If the human's framing in the issue body differs from this synthesized briefing, `/bmad-correct-course` produces a draft proposal that the human reviews / edits before merge.

---

## Section 7 — Briefing Handoff to /bmad-correct-course

The next iteration's NOW task is `Run /bmad-correct-course (issue #232)`. Feed this briefing as the input. Expected output: `_bmad-output/planning-artifacts/sprint-change-proposal-issue-232.md` (avoid filename clash with `sprint-change-proposal-2026-04-25.md` from issue #231) plus a Story 2.18 spec under `_bmad-output/planning-artifacts/stories/` and amended Change Log entries on Stories 2.3 + 2.4.

After `/bmad-correct-course` lands, the lifecycle continues `drafted → validated → atdd-scaffolded → in-dev → traced → sm-verified → done` per § Story Lifecycle Decision Matrix in `.ralph/PROMPT_build.md`.
