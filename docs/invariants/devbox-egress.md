# Invariant — Devbox egress policy (fail-closed, IPv4/IPv6 parity, atomic reload)

**Scope:** every Keel-forked devbox container (`packages/devbox/`) and the Ralph iteration environments that consume it.
**Status:** non-toggle-able at the substrate level; fork-time requirement.
**Machine-enforced in:** spec-enforced at 1.0 via content-hashed manifest entry + pre-merge sync-gate (`packages/keel-invariants/` FR43); runtime check implementation (live `nft list chain` + JSONL schema `jq` probe + dnsmasq `kill -HUP` round-trip) deferred to a dedicated `packages/keel-invariants/` rule + unit test on a later Ralph iteration.
**Normative reference:** `_bmad-output/planning-artifacts/prd.md` § FR1a + § NFR6 + § Devbox Implementation Contract; `_bmad-output/planning-artifacts/architecture.md` § S5 §Egress-Policy Mechanism + § Execution Environment; `AGENTS.md` § Devbox iteration environment.

## INV-devbox-egress-contract

Stable ID for the invariant authored by this doc — pinned in `packages/keel-invariants/src/invariants.manifest.ts` (content-hash of this file) and anchored in `INVARIANTS.md` § Devbox egress (Story 2.3). Story 1.9's pre-merge sync-gate (FR43) detects drift between this doc's on-disk sha256 and the manifest's `contentHash` field, and between the manifest's `anchors: ['INV-devbox-egress-contract']` entry and the matching `INVARIANTS.md` bullet. The heading is intentionally the bare stable-ID string so `grep '## INV-devbox-egress-contract' docs/invariants/devbox-egress.md` makes the manifest's anchor claim self-verifiable without cross-file traversal.

## Intent

The devbox container's egress posture is **fail-closed**, with **IPv4/IPv6 parity**, under **atomic reload** semantics. Any domain that is not explicitly on the composed allow-list is unreachable — the DNS layer returns NXDOMAIN-equivalent answers (`0.0.0.0` / `::`), the packet layer drops the TCP/UDP attempt, and reloading the policy is a single kernel transaction that does not break in-flight connections.

This closes three concrete upstream cc-devbox bugs:

1. **Divergent whitelist tooling** — upstream shipped two independent reload paths (`manage-whitelist.sh` against `/etc/whitelist-domains.conf`; a separate `whitelist` script against `/workspace/.claude/whitelist`) with different state and different reload behaviour, yielding intermittent unexpected blocks. The Keel substrate collapses both onto a single `reload-egress.sh` primitive (Story 2.3) with a single user-facing CLI on top (Story 2.4's `whitelist.sh`).
2. **Fail-open `/etc/resolv.conf` fallback to `8.8.8.8`** — upstream hardcoded a public-DNS fallback, so queries silently leaked to the host resolver whenever dnsmasq was slow or restarting. Keel pins `/etc/resolv.conf` to `nameserver 127.0.0.1` only; if dnsmasq is down, resolution fails (NFR6).
3. **IPv6 default-deny gap** — upstream's `whitelist.conf` only blocked IPv4 (`address=/#/127.0.0.1`); AAAA queries bypassed the policy entirely. Keel emits both `address=/#/0.0.0.0` and `address=/#/::` in dnsmasq, and both `output_v4` + `output_v6` chains carry `policy drop` at the nftables layer.

The three sub-contracts are registered as ONE consolidated invariant (one `contentHash`, one `sourcePath`, one manifest entry) so that drift between any aspect of the contract and the source doc is detected by a single sync-gate target. Growth-tier forks MAY split into per-contract invariants if their operational model requires independent drift detection.

## Mechanism

Two cooperating layers inside the `devbox` service (no Compose sidecar; both run as in-container daemons per AC 1 verbatim):

- **dnsmasq** — in-container DNS authority. Config rendered from `packages/devbox/dnsmasq/dnsmasq.conf` at container start (`scripts/start-egress.sh` → `scripts/reload-egress.sh`). Default rule `address=/#/0.0.0.0` + `address=/#/::` returns fail-closed answers for every domain; explicit `server=/<domain>/${KEEL_DEVBOX_DNS_UPSTREAM}` entries forward whitelisted domains to the operator-chosen upstream (default `1.1.1.1`; retunable via `packages/devbox/.envrc.example`). dnsmasq runs as `user=nobody` after binding port 53; its native query log at `/var/log/dnsmasq.log` feeds the JSONL tailer.
- **nftables** — layer-3 egress filter. Single `table inet keel_egress` with `chain output_v4` + `chain output_v6`, both `policy drop`. Rendered from `packages/devbox/nftables/egress.nft`; applied via `nft -f <tempfile>` — a single kernel atomic transaction. In-flight connections survive reload because the new ruleset's `ct state established,related accept` rule continues matching packets already associated with a flow.

Scripts (`packages/devbox/scripts/`):

- `start-egress.sh` — one-shot bootstrap invoked from `entrypoint.sh`: pins `/etc/resolv.conf` to `127.0.0.1`, composes the baseline whitelist (`whitelist.default.txt` + `whitelist/*.txt` fragments), runs the first atomic reload, launches the JSONL tailer in background, verifies dnsmasq is serving.
- `reload-egress.sh <composed-whitelist-path>` — atomic reload primitive; single arg is the composed whitelist file. `flock -x /run/keel-egress.lock` serialises concurrent reloads; `nft -f <tempfile>` applies the nftables transaction; `kill -HUP <dnsmasq-pid>` (fallback `pkill -HUP dnsmasq`) reloads dnsmasq without restart. Consumed by Story 2.4's user-facing `whitelist.sh sync` CLI.
- `egress-log-tailer.sh` — background JSONL emitter. Tails `/var/log/dnsmasq.log` via `tail -Fn0`, parses each query/response line, emits one JSONL record per event to `/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/egress-queries.jsonl`, rotates in-process at 50 MB (5 generations, gzip-compressed).
- `monitor.sh` — operator-facing live tail of the JSONL file via `jq -c`.

Whitelist composition (static baseline at Story 2.3; per-fork override lands in Story 2.4):

- `packages/devbox/whitelist.default.txt` — substrate baseline (empty at 1.0; comment header explains composition order).
- `packages/devbox/whitelist/{npm,anthropic,github}.txt` — category fragments covering the substrate's required egress surface.

Capability contract (`docker-compose.yml`):

- `cap_add: [NET_ADMIN, NET_RAW]` — required for `nft` rule loading + raw-socket probes. Story 2.5's `cap_drop: [ALL]` reduces to `cap_drop: [ALL] + cap_add: [NET_ADMIN, NET_RAW]` without breaking egress enforcement.
- `CAP_NET_BIND_SERVICE` (implicit while running as root) — required to bind port 53. Story 2.5's non-root handoff re-evaluates whether this cap needs to be explicit or whether dnsmasq is started before the user switch.

## Rotating-IP services (Story 2.18)

The static-pin path described in § Mechanism resolves each whitelisted domain to one or more IPs at reload-time and emits per-IP `ip daddr <ip> accept` rules into `output_v4` / `output_v6`. That contract holds for stable-IP services. **Multi-A rotating-IP services** (`github.com`, `api.github.com`, and the GitHub-class hosts grouped in `packages/devbox/whitelist/github-rotating.txt`) defeat it: GitHub's edge serves a different rotation of IPs across responses, the static-pin snapshot captures only the IPs returned during the reload's `getent`, and any subsequent GitHub IP that falls outside that snapshot is dropped at the nftables layer mid-iteration (Issue #232 / Story 2.18).

Story 2.18 layers a dynamic-accept mechanism on top of the static-pin path WITHOUT replacing it. Three cooperating layers:

- **dnsmasq `nftset=` directive emission (Option A — primary).** Whitelist fragments named with the filename suffix `*-rotating.txt` (SC-2) classify their domains as `rotating` in the `.classification` sidecar emitted by both composers (`packages/devbox/scripts/start-egress.sh` `compose_whitelist()` and `packages/devbox/scripts/whitelist.sh` `compose_whitelist_into()` — byte-identical per SC-11, extending Story 2.4 SC-14 dual-composer parity). `reload-egress.sh` reads the sidecar and renders one extra pair of `nftset=` directives per rotating domain alongside the existing `server=` line in the dnsmasq config: `nftset=/<domain>/4#inet#keel_egress#gh_v4` (IPv4) + `nftset=/<domain>/6#inet#keel_egress#gh_v6` (IPv6). dnsmasq combines forwarding (`server=`) + population (`nftset=`) in a single resolution pass; every observed A/AAAA reply lands in the matching named set with the per-set TTL applied.
- **nftables named-set accept rules (Option A — kernel side).** `packages/devbox/nftables/egress.nft` declares `set gh_v4 { type ipv4_addr; flags timeout; timeout 600s; }` and `set gh_v6 { type ipv6_addr; flags timeout; timeout 600s; }` at table scope. Each chain gains one rule: `output_v4` adds `ip daddr @gh_v4 accept`; `output_v6` adds `ip6 daddr @gh_v6 accept`. The set self-prunes via `flags timeout`; entries expire after 600s if not renewed by subsequent DNS replies. Set names are STATIC per family (SC-4) — every rotating-flagged domain shares the same `gh_v<family>` pair regardless of how many GitHub-class services are added.
- **Static GitHub CIDR fallback (Option B — belt-and-braces).** `egress.nft` `output_v4` carries two static CIDR rules BEFORE the dynamic `@gh_v4` accept: `ip daddr 140.82.112.0/20 accept` (GitHub web/api per `https://api.github.com/meta`) and `ip daddr 192.30.252.0/22 accept` (GitHub legacy). Three-way ordering inside `output_v4` is therefore `static-CIDR → @gh_v4 accept → KEEL_EGRESS_V4_MARKER_START` so the static layer short-circuits during (a) the boot-time-to-first-DNS-reply window and (b) catastrophic dnsmasq failure modes. `185.199.108.0/22` (Pages/raw) is intentionally NOT here — Story 2.3's static-pin path already covers it via `raw.githubusercontent.com`.

**Set lifecycle (SC-7).** `flush table inet keel_egress` at the top of `egress.nft` wipes the named sets on every reload; dnsmasq re-fills on the next DNS query (typical < 1s). The brief in-flight window during reload is covered by the Option B static CIDR fallback rules in `output_v4` (no IPv6 static fallback — GitHub's IPv6 ranges are CDN-fronted, and the static-pin path already resolves AAAA records into per-IP accept rules during reload). Per-set timeout default is 600s (SC-5); operators retuning via a future `${KEEL_DEVBOX_NFTSET_TIMEOUT}` knob inherit the override path for the timeout literal in `egress.nft`.

**Architectural rationale.** `nftset=` over hardcoded CIDRs alone generalises to any future rotating-IP whitelist entry without per-service CIDR maintenance. Static CIDRs as belt-and-braces narrow two real failure modes (boot-window + dnsmasq-death). Story 2.4's whitelist composer is extended additively via the `.classification` sidecar — the regex-bound LDH validation surface (Story 2.4 SC-5) remains byte-identical because the rotating annotation rides on the FILENAME, not the line content. Story 2.3's atomic-reload contract holds — `flush table` + `nft -f <tempfile>` + `kill -HUP dnsmasq` is the same single kernel transaction.

## JSONL query log schema

`/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/egress-queries.jsonl` — one JSON object per line, UTF-8, LF-terminated. Field order is stable (append-only) so Epic 4's FR37 security-evidence consumer can hard-reference it:

```json
{"timestamp":"2026-04-21T12:34:56.789Z","query":"api.anthropic.com","type":"A","result":"allow","upstream":"1.1.1.1","client":"127.0.0.1"}
```

Fields:

- `timestamp` — ISO 8601 UTC with millisecond precision + `Z` suffix.
- `query` — queried domain (lowercase, trailing dot stripped).
- `type` — DNS record type: `A`, `AAAA`, `CNAME`, `MX`, `TXT`, `SRV`, `PTR`, `ANY`, or parse-error raw string.
- `result` — one of `allow` (whitelisted, forwarded upstream), `block` (nftables dropped the TCP attempt), `nxdomain` (dnsmasq returned NXDOMAIN / fail-closed default), `servfail` (upstream failure), `parse-error` (log-line parse failed — raw payload emitted in an extra `raw` field).
- `upstream` — upstream resolver IP if the query was forwarded; `null` if blocked/nxdomain/parse-error.
- `client` — source IP of the query (typically `127.0.0.1` inside the container); `null` for synthesized records.

Rotation: when `egress-queries.jsonl` exceeds 50 MB (threshold pinned at 1.0 — committed code MUST NOT lower this), the tailer rotates inline:

1. Close the open fd.
2. Rename `egress-queries.jsonl` → `egress-queries.jsonl.1.tmp`.
3. `gzip` → `egress-queries.jsonl.1.gz`.
4. Shift older generations: `.N.gz` → `.N+1.gz`, dropping anything beyond `.5.gz`.
5. Reopen a fresh `egress-queries.jsonl` and resume writing.

Worst-case disk use: 50 MB active + 5 × (≤ 50 MB compressed ≈ 5 – 15 MB) gzip backups ≈ 125 MB, well under the `KEEL_DEVBOX_TMPFS_LOGS_MB=500` default that Story 2.5 will tmpfs-back the path with.

## Verification

Backend-B iteration-env cannot exercise these smokes (kernel-nftables privilege denied + Docker Desktop bind-mount allow-list); they run on an operator workstation (backend A or native M4-Pro) with the bake-refreshed image.

- **AC 1 (dnsmasq authority + resolv.conf):**
  ```sh
  docker exec keel-devbox cat /etc/resolv.conf
  # Expect exactly:
  # nameserver 127.0.0.1
  # options edns0 single-request-reopen
  docker exec keel-devbox bash -c '[[ -s /run/dnsmasq.pid ]] && kill -0 "$(cat /run/dnsmasq.pid)" && timeout 1 bash -c "</dev/tcp/127.0.0.1/53"'
  # Expect exit 0: pidfile non-empty + pid alive + 127.0.0.1:53 accepting TCP.
  # (Positive-serving probe matching start-egress.sh step 6; `pgrep -x dnsmasq`
  # would match any process named "dnsmasq" regardless of socket-bind state.)
  ```
- **AC 2 (IPv4/IPv6 parity — SC-7 verbatim):**
  ```sh
  docker exec keel-devbox nft list chain inet keel_egress output_v4 | grep -q 'policy drop'
  docker exec keel-devbox nft list chain inet keel_egress output_v6 | grep -q 'policy drop'
  ```
- **AC 3 (JSONL schema):**
  ```sh
  docker exec keel-devbox tail -n 1 /workspace/${KEEL_DEVBOX_REPO_NAME}/logs/egress-queries.jsonl | jq -e '
    has("timestamp") and has("query") and has("type") and
    has("result") and has("upstream") and has("client")'
  ```
- **AC 4 (atomic reload):**
  ```sh
  # In one shell, start a long-running connection through a whitelisted domain:
  docker exec keel-devbox curl -sS --keepalive-time 60 https://api.anthropic.com/v1/models &
  # In a second shell, reload the policy with the same composed whitelist:
  docker exec keel-devbox /workspace/${KEEL_DEVBOX_REPO_NAME}/packages/devbox/scripts/reload-egress.sh /run/keel-whitelist.composed.txt
  # Expect: reload exits 0 within 2s; the long-running curl does NOT break.
  ```
- **AC 5 (fail-closed unwhitelisted curl):**
  ```sh
  docker exec keel-devbox curl -m 3 -sSf https://example-unwhitelisted.invalid
  # Expect non-zero exit; stderr message of "Could not resolve host" OR "Connection refused" OR timeout.
  ```

## Amendment

This invariant is **substrate-authoritative**. Fork-extension via `INVARIANTS.fork.md` (FR45; `docs/invariants/fork.md` § Precedence) MAY add per-fork domains to the composed allow-list AND MAY override `KEEL_DEVBOX_DNS_UPSTREAM` at runtime. Fork overrides MUST NOT relax the fail-closed default, the IPv4/IPv6 parity, or the atomic-reload semantics.

A fork that needs to weaken any of those three sub-contracts pursues the AMEND path (source-level PR against this doc + `invariants.manifest.ts` + `INVARIANTS.md` anchor together — the Story 1.6 + 1.9 source-level fork path), not the FORK path. Substrate-wins precedence per `docs/invariants/fork.md` § Precedence.

## Consumption

- **Humans / AI agents:** read this file; when authoring Story 2.4 (whitelist CLI) or Story 2.5 (hardening), verify that the new code honours the contract surface here rather than introducing a parallel allow-list or a silent-allow path.
- **`AGENTS.md` § Devbox iteration environment:** references `INV-devbox-egress-contract` when the egress policy is elaborated.
- **`RALPH.md` § Signposts:** references this invariant to explain why Story 2.3's dev-story output lands in the canonical file layout + single-reload primitive + JSONL schema freeze.
- **`_bmad-output/planning-artifacts/architecture.md` § S5:** references this invariant in the dual-layer belt-and-braces mechanism pin.
- **Epic 4 FR37 security-evidence consumer:** reads `/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/egress-queries.jsonl` + all `.N.gz` backups; hard-references the JSONL schema pinned in § JSONL query log schema above.
- **Story 2.4 (`whitelist.sh` user-facing CLI):** invokes `packages/devbox/scripts/reload-egress.sh` with the composed whitelist argument.
- **Story 2.5 (hardening):** re-evaluates `cap_add`/`cap_drop`/`user` posture against the capability contract in § Mechanism.
- **Story 2.13 (healthcheck):** probes dnsmasq liveness as part of the compose healthcheck.
- **Story 1.9 sync-gate (`INV-tokens-sync-gate` companion pattern):** at pre-merge, asserts this file's content hash in `invariants.manifest.ts` matches its on-disk hash AND that the `INVARIANTS.md` anchor bullet names the matching backtick-wrapped stable ID.

## Extension (FR44)

Fork operators who need a fork-specific allow-list additive document the per-fork domains in their fork's `INVARIANTS.fork.md` under a `FORK-<fork-slug>-egress-<slug>` entry and add matching lines to their fork's `packages/devbox/whitelist/` fragment (or a new per-fork fragment once Story 2.4 lands the override path). The substrate invariant remains unchanged; forks extend additively. If a fork substitution contradicts the contract surface (different atomic-reload mechanism, mixed-family rulesets, fail-open default), that is an AMEND-path change against this doc + `invariants.manifest.ts` + `INVARIANTS.md` anchor.
