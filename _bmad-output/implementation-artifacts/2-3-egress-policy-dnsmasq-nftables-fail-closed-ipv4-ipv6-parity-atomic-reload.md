# Story 2.3: Egress Policy — dnsmasq + nftables (fail-closed, IPv4/IPv6 parity, atomic reload)

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a substrate maintainer,
I want the devbox egress enforced by dnsmasq (DNS authority + JSONL query log) and nftables (layer-3 default-deny IPv4 + IPv6) with atomic reload semantics,
so that a runtime compromise inside the container cannot reach arbitrary external hosts (FR1a, NFR6).

## Acceptance Criteria

1. **Given** the baked image from Story 2.1,
   **When** the container starts,
   **Then** dnsmasq runs as the in-container DNS authority
   **And** the container's `/etc/resolv.conf` points only at `127.0.0.1:53`
   **And** upstream's fail-open `resolv.conf` gap is closed.

2. **Given** nftables is configured at entrypoint,
   **When** I inspect the ruleset,
   **Then** the default policy is `DROP` for both IPv4 (`ip`) and IPv6 (`ip6`) filter output chains
   **And** upstream's IPv6 gap is closed (policy parity verified by an in-container test).

3. **Given** dnsmasq's JSONL query log,
   **When** DNS queries execute,
   **Then** each query is written to a structured JSONL file at a pinned path suitable for FR37 security-evidence persistence (Epic 4)
   **And** log rotation is configured to prevent unbounded growth.

4. **Given** an atomic reload is triggered via file-lock (mechanism used by Story 2.4's CLI),
   **When** the whitelist is updated,
   **Then** dnsmasq + nftables are re-loaded without dropping in-flight connections
   **And** the reload is atomic (either both layers apply the new policy, or neither does).

5. **Given** a container with the policy active,
   **When** I attempt to `curl` an unwhitelisted domain,
   **Then** the DNS resolution fails (dnsmasq NXDOMAIN) AND the TCP connection is rejected (nftables default-deny)
   **And** upstream's divergent-whitelist-script problem is closed (one mechanism, two enforcement layers).

### Scope clarifications (pinned at draft, MUST be honored — not re-negotiable without Change Log entry)

- **SC-1 (runtime location, AC 1/2):** dnsmasq + nftables run as **in-container daemons/rules** inside the `devbox` service, NOT as separate Compose sidecar services. Rationale: AC 1 verbatim "When the container starts, dnsmasq runs as the in-container DNS authority" + architecture.md § S5 (l.224) atomic-reload via single file-locked shell-script inside the container. The `# TODO(Story 2.3): add nftables / dnsmasq sidecar services` comment at `docker-compose.yml:10` is stale shorthand — Story 2.3 replaces it with an in-container wiring comment (not a new Compose service).
- **SC-2 (pinned JSONL log path, AC 3):** `/workspace/logs/egress-queries.jsonl` inside the container. Rationale: `/workspace` is bind-mounted from the host per Story 2.1's compose; `KEEL_DEVBOX_TMPFS_LOGS_MB` (Story 2.2 knob, Story 2.5 consumer) will future-tmpfs this path at 500 MB; FR37 security-evidence emitter (Epic 4) consumes this path. Pin the path AT STORY 2.3 so downstream Epic 4 consumers can hard-reference it.
- **SC-3 (pinned JSONL schema, AC 3):** one JSON object per line, UTF-8, LF-terminated, fields in declared order: `{"timestamp":"<ISO8601 Z>","query":"<domain>","type":"<A|AAAA|CNAME|...>","result":"<allow|block|nxdomain|servfail>","upstream":"<ip-or-null>","client":"<source-ip>"}`. Rationale: `jq`-parseable (already baked in Story 2.1 Dockerfile); stable field order eases append-only log parsers (Epic 4).
- **SC-4 (pinned rotation, AC 3):** size-based, in-process: rotate when `egress-queries.jsonl > 50 MB` (pinned threshold at 1.0) → rename to `egress-queries.jsonl.1.gz` (gzip-compressed), shift older `.N.gz` → `.N+1.gz`, drop anything beyond `.5.gz`. Rationale: avoids external `logrotate` daemon (keeps container single-purpose); `gzip` is stdlib; 50 MB + 5 generations ≈ 250 MB worst-case — well under `KEEL_DEVBOX_TMPFS_LOGS_MB=500` default. DO NOT introduce cron or logrotate; in-process rotation in the JSONL emitter only.
- **SC-5 (atomic-reload mechanism, AC 4):** file-locked single script, two atomic ops in sequence:
  1. `flock -x /run/keel-egress.lock` (blocks concurrent reloads; scoped to container init-writable dir)
  2. `nft -f <new-ruleset-tempfile>` — single atomic transaction (kernel-level atomic swap; preserves established TCP connections because the new ruleset's `ct state established,related accept` rule evaluates AFTER the swap for in-flight packets)
  3. `kill -HUP <dnsmasq-pid>` — dnsmasq re-reads `/etc/dnsmasq.d/*.conf` + whitelist files without restarting (preserves in-flight UDP/TCP DNS queries)
  4. Release flock on exit
  If either step fails: abort, leave previous ruleset + dnsmasq config untouched, exit non-zero with actionable stderr. Rationale: "atomic = either both layers apply or neither does" per AC 4 verbatim.
- **SC-6 (cap_add wiring, AC 2):** Story 2.3 adds `cap_add: [NET_ADMIN, NET_RAW]` to `docker-compose.yml` NOW (defensive-explicit; container is currently root-with-all-caps, so the cap_add is a no-op pre-Story-2.5, but it locks the explicit allowance so Story 2.5's later `cap_drop: [ALL]` reduces to `cap_drop:[ALL] + cap_add:[NET_ADMIN,NET_RAW]` without breaking egress enforcement). DO NOT add `cap_drop: [ALL]`, `user: dev`, or `security_opt: [no-new-privileges:true]` — those belong to Story 2.5 (scope-creep forbidden).
- **SC-7 (IPv4/IPv6 parity test, AC 2):** in-container verification command is pinned as (verbatim, used in both live-smoke and dev-agent verification):
  ```sh
  nft list chain inet keel_egress output_v4 | grep -q 'policy drop'
  nft list chain inet keel_egress output_v6 | grep -q 'policy drop'
  ```
  Rationale: single `inet` table with two chains (`output_v4` filtering IPv4, `output_v6` filtering IPv6 via `meta nfproto`), both with `policy drop` — readable via `nft list`. Alternative single-family tables (`ip filter output` + `ip6 filter output`) are equivalent at kernel level but require two separate table definitions; `inet` family is the modern nftables idiom and yields a single-file ruleset template.
- **SC-8 (whitelist compose boundary vs Story 2.4, AC 4):** Story 2.3 ships the `reload-egress.sh` primitive that takes a **single composed whitelist filepath as argument** and performs the atomic reload. Story 2.3 ships a static baseline composition (concatenation of `whitelist.default.txt` + `whitelist/*.txt` fragments, NO per-fork override) run once at container start. Story 2.4 later produces a `whitelist.sh` user-facing CLI that handles per-fork override + validation + diff summary + invocation of `reload-egress.sh`. Story 2.3 MUST NOT create `scripts/whitelist.sh` — that file belongs to Story 2.4.
- **SC-9 (scripts output-location):** `packages/devbox/scripts/reload-egress.sh`, `packages/devbox/scripts/start-egress.sh`, `packages/devbox/scripts/monitor.sh`, `packages/devbox/scripts/egress-log-tailer.sh` — all kebab-case `.sh`, executable (`0755`), `set -euo pipefail`, match Story 2.1's `scripts/benchmark.sh` shape (shebang `#!/usr/bin/env bash`, `set -euo pipefail`, backend-safe).
- **SC-10 (invariant consolidation, Task 10):** Story 2.3 registers ONE new invariant `INV-devbox-egress-contract` whose `sourcePath` is `docs/invariants/devbox-egress.md` (NEW). The doc consolidates the three sub-contracts (fail-closed resolver + IPv4/IPv6 parity + atomic-reload). Rationale: Story 2.2 CR iter-151 AR-2 taught that `.envrc.local.example` allow-list asymmetry grew from splitting a single contract across manifest entries — one doc, one `contentHash`, one sync-gate target is less fragile. Future Growth-tier forks MAY split into three invariants if their operational model requires per-contract drift detection.
- **SC-11 (entrypoint.sh surgery discipline):** Story 2.3 inserts exactly ONE hook into `packages/devbox/entrypoint.sh` — an invocation of `scripts/start-egress.sh` (new file) placed AFTER the Story 2.1 workspace-owner chown + named-volume dir bring-up, BEFORE the `exec "$@"` / `sleep infinity` tail. DO NOT inline dnsmasq/nftables logic into `entrypoint.sh` (preserves Story 2.1's narrowed scope; failure-isolation: `start-egress.sh` can fail hard without corrupting workspace bring-up).
- **SC-12 (dnsmasq allow-mechanism, AC 1/5):** dnsmasq operates as a **forwarding resolver with explicit allow-list**: default `address=/#/` returns `0.0.0.0`/`::`/NXDOMAIN for everything, and explicit `server=/<domain>/<upstream>` entries forward whitelisted domains to the host-provided upstream resolver (extracted from the host-side resolv.conf at container start via `KEEL_DEVBOX_DNS_UPSTREAM` env, default `1.1.1.1` if unset — see SC-14). Rationale: "fail-closed" = any domain NOT in whitelist yields NXDOMAIN; whitelisted domains resolve via upstream. NO `8.8.8.8` hardcoded fallback (explicitly prohibited per PRD § Devbox Implementation Contract l.549).
- **SC-13 (resolv.conf override, AC 1):** `start-egress.sh` overwrites `/etc/resolv.conf` inside the container to exactly two lines: `nameserver 127.0.0.1` + `options edns0 single-request-reopen` (single-request-reopen mitigates parallel-query races with stateful resolvers). DO NOT write `8.8.8.8`, `1.1.1.1`, or any upstream to `resolv.conf`. The upstream is ONLY reachable via dnsmasq's per-domain `server=` directives.
- **SC-14 (upstream DNS env knob, AC 1):** Story 2.3 introduces ONE new `.envrc.example` knob: `KEEL_DEVBOX_DNS_UPSTREAM=1.1.1.1` (Cloudflare default; operator may retune to corporate resolver). Added to `packages/devbox/.envrc.example` in a new `# --- Egress policy (Story 2.3) ---` section. DO NOT add a whitelist-source knob (Story 2.4 owns per-fork override composition). DO NOT add a rotation-size knob (pinned at 50 MB per SC-4; deferred to post-1.0 if operator pushback).
- **SC-15 (JSONL emitter process model):** `scripts/egress-log-tailer.sh` runs as a **background process** launched from `start-egress.sh` via `nohup … &`. It tails dnsmasq's native query-log file (`/var/log/dnsmasq.log`) and emits JSONL records to `/workspace/logs/egress-queries.jsonl`, performing SC-4 rotation inline. PID captured to `/run/keel-egress-tailer.pid` for clean `kill -TERM` on reload. Rationale: dnsmasq doesn't natively emit JSONL; tailing its text log + transforming is the simplest stable approach without introducing a new daemon.
- **SC-16 (log rotation safety during reload, AC 4):** size-based rotation in the JSONL tailer MUST release the open file handle BEFORE the `nft`/`HUP` reload completes (the reload is orthogonal to rotation — rotation does not drop in-flight queries). Rotation cadence is event-driven per write; the atomic reload script does NOT trigger rotation.
- **SC-17 (workspace-logs directory idempotent pre-create):** `start-egress.sh` calls `mkdir -p /workspace/logs` at start (idempotent; host-side bind-mount may not yet contain the directory). DO NOT rely on a host-side post-install hook to create it.

## Tasks / Subtasks

- [ ] **Task 1 — Dockerfile: install dnsmasq + nftables** (AC 1, AC 2)
  - [ ] Subtask 1.1: append `dnsmasq` + `nftables` to the existing `apt-get install` layer in `packages/devbox/Dockerfile` (same layer as the Story 2.1 system-packages block; preserve `apt-get clean && rm -rf /var/lib/apt/lists/*` discipline). DO NOT create a new RUN block.
  - [ ] Subtask 1.2: verify `nft --version` + `dnsmasq --version` in the baked image via `docker run --rm keel-devbox:local nft --version` and `docker run --rm keel-devbox:local dnsmasq --version` (deferred to operator workstation per backend-B constraint — record the output in `packages/devbox/VERSIONS.md`).
  - [ ] Subtask 1.3: record the pinned versions in `packages/devbox/VERSIONS.md` under a new `### Egress policy (Story 2.3)` section (dnsmasq + nftables apt-provided versions as captured at bake time). Match the Story 2.1 VERSIONS.md format.

- [ ] **Task 2 — Whitelist source-of-truth files** (AC 5, SC-8)
  - [ ] Subtask 2.1: create `packages/devbox/whitelist.default.txt` — empty baseline (a comment header explaining the file's role + composition order: `whitelist.default.txt` > `whitelist/*.txt` fragments; one domain per line, comments with `#`).
  - [ ] Subtask 2.2: create `packages/devbox/whitelist/` directory with three category fragments:
    - `whitelist/npm.txt` — npm registry domains: `registry.npmjs.org`, `registry.yarnpkg.com`, `nodejs.org`, `unpkg.com` (one per line + comment block header).
    - `whitelist/anthropic.txt` — Anthropic API: `api.anthropic.com`, `console.anthropic.com`, `statsig.anthropic.com` (one per line + comment block header).
    - `whitelist/github.txt` — GitHub API + git clone: `api.github.com`, `github.com`, `raw.githubusercontent.com`, `objects.githubusercontent.com`, `codeload.github.com`, `ghcr.io`, `pkg-containers.githubusercontent.com` (one per line + comment block header).
  - [ ] Subtask 2.3: no per-fork override file at Story 2.3 (deferred to Story 2.4). DO NOT create `whitelist.fork.txt` or similar.

- [ ] **Task 3 — dnsmasq config template** (AC 1, AC 3, SC-12, SC-13)
  - [ ] Subtask 3.1: create `packages/devbox/dnsmasq/dnsmasq.conf` with:
    - `domain-needed` + `bogus-priv` + `stop-dns-rebind` (standard hardening)
    - `no-hosts` + `no-resolv` (do NOT read `/etc/resolv.conf` or `/etc/hosts` for upstream)
    - `listen-address=127.0.0.1,::1` + `port=53` + `bind-interfaces`
    - `user=nobody` + `group=nogroup` (drop privileges after binding port 53 — dnsmasq native)
    - `log-queries=extra` + `log-facility=/var/log/dnsmasq.log` (feeds SC-15 JSONL tailer)
    - `address=/#/0.0.0.0` + `address=/#/::` (fail-closed default — any domain returns 0.0.0.0/::)
    - Placeholder marker `# KEEL_EGRESS_ALLOWLIST_MARKER_START` … `# KEEL_EGRESS_ALLOWLIST_MARKER_END` — the range replaced by `reload-egress.sh` with `server=/<domain>/$UPSTREAM` directives per whitelist entry.
  - [ ] Subtask 3.2: dnsmasq config DOES NOT hardcode upstream — `reload-egress.sh` injects `server=/<domain>/${KEEL_DEVBOX_DNS_UPSTREAM}` at reload time from the env.
  - [ ] Subtask 3.3: verify the config is syntactically valid via `dnsmasq --test --conf-file=packages/devbox/dnsmasq/dnsmasq.conf` (deferred to operator workstation; record in Debug Log References at dev-story closure).

- [ ] **Task 4 — nftables rules template** (AC 2, SC-7)
  - [ ] Subtask 4.1: create `packages/devbox/nftables/egress.nft` — single `table inet keel_egress` with:
    - `chain output_v4 { type filter hook output priority 0; policy drop; meta nfproto ipv4; ... }`
    - `chain output_v6 { type filter hook output priority 0; policy drop; meta nfproto ipv6; ... }`
    - Allow loopback egress (to 127.0.0.1:53 and ::1:53 so the devbox itself can reach dnsmasq)
    - Allow established/related connections (`ct state established,related accept`)
    - Allow DNS replies from 127.0.0.1:53 (`udp sport 53 ip saddr 127.0.0.1 accept`)
    - Placeholder marker `# KEEL_EGRESS_ALLOWLIST_MARKER_START` … `# KEEL_EGRESS_ALLOWLIST_MARKER_END` — the range replaced by `reload-egress.sh` with explicit `ip daddr <whitelisted-ip> accept` rules resolved from the whitelist at reload time.
  - [ ] Subtask 4.2: the nftables template is the SINGLE source of atomic-reload truth (`nft -f <rendered-file>` loads the whole table in one transaction). DO NOT split into multiple `.nft` files.
  - [ ] Subtask 4.3: verify the template is syntactically valid via `nft -c -f packages/devbox/nftables/egress.nft` (check-only, no apply) — deferred to operator workstation.

- [ ] **Task 5 — `scripts/start-egress.sh`: entrypoint helper** (AC 1, AC 2, AC 5, SC-11)
  - [ ] Subtask 5.1: create `packages/devbox/scripts/start-egress.sh` (executable, `set -euo pipefail`, `#!/usr/bin/env bash`).
  - [ ] Subtask 5.2: `mkdir -p /workspace/logs` (SC-17) + `mkdir -p /run` (ensure writable).
  - [ ] Subtask 5.3: overwrite `/etc/resolv.conf` to `nameserver 127.0.0.1\noptions edns0 single-request-reopen` (SC-13).
  - [ ] Subtask 5.4: compose the initial whitelist (concatenate `packages/devbox/whitelist.default.txt` + all `packages/devbox/whitelist/*.txt` after stripping comments/blank lines) into `/run/keel-whitelist.composed.txt`.
  - [ ] Subtask 5.5: invoke `scripts/reload-egress.sh /run/keel-whitelist.composed.txt` (first-time rule + config generation + apply).
  - [ ] Subtask 5.6: launch `scripts/egress-log-tailer.sh` in background via `nohup … >/dev/null 2>&1 &` + record PID to `/run/keel-egress-tailer.pid`.
  - [ ] Subtask 5.7: verify dnsmasq is running (single retry loop up to 5s: `pgrep -x dnsmasq` or `ss -lnp | grep ':53'`) — fail-hard (exit 1) if dnsmasq is not up (AC 5 fail-closed; no silent-allow).

- [ ] **Task 6 — `scripts/reload-egress.sh`: atomic reload primitive** (AC 4, SC-5, SC-8)
  - [ ] Subtask 6.1: create `packages/devbox/scripts/reload-egress.sh` (executable, `set -euo pipefail`, `#!/usr/bin/env bash`).
  - [ ] Subtask 6.2: argument contract: `reload-egress.sh <composed-whitelist-path>` — single arg, the path to a composed (and validated) whitelist file. Exit 2 if arg missing; exit 3 if path unreadable.
  - [ ] Subtask 6.3: acquire `flock -x 200` on `/run/keel-egress.lock` (fd 200) — serialize concurrent reloads. If lock unavailable within 10s, exit 4 with actionable stderr.
  - [ ] Subtask 6.4: render the nftables ruleset: copy `packages/devbox/nftables/egress.nft` to a temp file; replace the `# KEEL_EGRESS_ALLOWLIST_MARKER_START` … `END` block with resolved IP allow-rules (for each domain in composed whitelist: resolve via `getent ahostsv4` + `getent ahostsv6` to get IPv4 + IPv6 addresses, emit `ip daddr <addr> accept` + `ip6 daddr <addr6> accept` in the appropriate chain).
  - [ ] Subtask 6.5: render the dnsmasq conf: copy `packages/devbox/dnsmasq/dnsmasq.conf` to `/etc/dnsmasq.conf`; replace the `# KEEL_EGRESS_ALLOWLIST_MARKER_START` … `END` block with `server=/<domain>/${KEEL_DEVBOX_DNS_UPSTREAM:-1.1.1.1}` for each whitelisted domain.
  - [ ] Subtask 6.6: apply the new nftables ruleset via `nft -f <temp-rendered-file>` — single atomic transaction. If it fails, abort reload (previous ruleset stays active); exit 5 with stderr.
  - [ ] Subtask 6.7: reload dnsmasq via `kill -HUP "$(cat /run/dnsmasq.pid)"` — config re-read without restart (established DNS connections preserved). Fallback if pidfile missing: `pkill -HUP dnsmasq`.
  - [ ] Subtask 6.8: release flock on exit via trap.
  - [ ] Subtask 6.9: exit 0 with a one-line summary to stdout (e.g., `reload ok: 12 domains, 24 ipv4 rules, 21 ipv6 rules`).

- [ ] **Task 7 — `scripts/egress-log-tailer.sh`: JSONL emitter + rotation** (AC 3, SC-3, SC-4, SC-15, SC-16)
  - [ ] Subtask 7.1: create `packages/devbox/scripts/egress-log-tailer.sh` (executable, `set -euo pipefail`, `#!/usr/bin/env bash`).
  - [ ] Subtask 7.2: open `/var/log/dnsmasq.log` for tailing via `tail -Fn0` (follow + new-file-on-rotation; start from end so we don't emit historical lines at first run).
  - [ ] Subtask 7.3: parse each dnsmasq query-log line (format: `<timestamp> dnsmasq[<pid>]: query[<type>] <domain> from <client>`; for responses: `<timestamp> dnsmasq[<pid>]: reply <domain> is <answer>`; for blocks: `<timestamp> dnsmasq[<pid>]: config <domain> is <NXDOMAIN|0.0.0.0>`) and synthesize a JSONL record per SC-3 schema.
  - [ ] Subtask 7.4: write to `/workspace/logs/egress-queries.jsonl`. On every write, check filesize; if > 50 MB, rotate inline (SC-4): close the fd, rename `egress-queries.jsonl` → `egress-queries.jsonl.1.tmp`, `gzip` → `egress-queries.jsonl.1.gz`, shift older generations (`.N.gz` → `.N+1.gz`), drop anything beyond `.5.gz`, reopen fd to fresh empty `egress-queries.jsonl`.
  - [ ] Subtask 7.5: on `SIGTERM`/`SIGINT`, flush + close cleanly.
  - [ ] Subtask 7.6: on parse-error (malformed dnsmasq log line), emit a JSONL record with `"result":"parse-error"` + the raw line in a `"raw"` field. DO NOT drop lines silently.

- [ ] **Task 8 — `scripts/monitor.sh`: operator JSONL tail** (AC 3 observability)
  - [ ] Subtask 8.1: create `packages/devbox/scripts/monitor.sh` (executable, `set -euo pipefail`, `#!/usr/bin/env bash`).
  - [ ] Subtask 8.2: `exec tail -Fn0 /workspace/logs/egress-queries.jsonl | jq -c --unbuffered '.'` — simple pretty-print; operator-facing.
  - [ ] Subtask 8.3: Story 2.3 only delivers the raw tail — no filter args, no format flags (those are Story 2.4/2.6 scope).

- [ ] **Task 9 — `packages/devbox/docker-compose.yml`: wire caps + volumes + entrypoint hook** (AC 1, AC 2, SC-6, SC-11)
  - [ ] Subtask 9.1: replace the `# TODO(Story 2.3): add nftables / dnsmasq sidecar services for egress policy.` comment at `docker-compose.yml:10` with a terse factual comment (e.g., `# Egress policy (Story 2.3): in-container dnsmasq + nftables via entrypoint; cap_add NET_ADMIN/NET_RAW; scripts under ./scripts/.`) — NO sidecar service. Preserve all other TODO(Story N.X) comments verbatim.
  - [ ] Subtask 9.2: add `cap_add: ["NET_ADMIN", "NET_RAW"]` to the `devbox` service (SC-6). DO NOT add `cap_drop`.
  - [ ] Subtask 9.3: the existing workspace bind-mount already exposes `packages/devbox/` — NO new volume mounts needed for whitelist/nftables/dnsmasq template files (they live in the repo and are present inside `/workspace/packages/devbox/` via the existing bind). The Dockerfile COPY + image bake exposes them at `/workspace/packages/devbox/` after mount (verify at bake time — script paths are absolute `/workspace/packages/devbox/scripts/…`).
  - [ ] Subtask 9.4: hook `start-egress.sh` from `entrypoint.sh` (Task 11). `docker-compose.yml` itself is not edited for entrypoint wiring (entrypoint path is pinned in Story 2.1 Dockerfile + compose; Story 2.3 modifies the entrypoint script content, not the compose entrypoint directive).
  - [ ] Subtask 9.5: contentHash refresh: `docker-compose.yml` is tracked by an invariant manifest entry (if any) — compute `sha256sum packages/devbox/docker-compose.yml`, update manifest, re-run sync-gate, verify exit 0 before commit. If no manifest entry currently tracks compose.yml, no sync-gate action needed (Story 2.2 iter-153 precedent for contentHash refresh discipline).

- [ ] **Task 10 — `entrypoint.sh` + invariant doc + manifest entry** (AC 1, SC-10, SC-11)
  - [ ] Subtask 10.1: modify `packages/devbox/entrypoint.sh` — insert a single new block AFTER the Story 2.1 workspace-owner chown + named-volume dir bring-up, BEFORE the `exec "$@"` / `sleep infinity` tail:
    ```bash
    # Story 2.3: fail-closed egress policy (dnsmasq + nftables). Hard-fail if init fails.
    if [ -x /workspace/packages/devbox/scripts/start-egress.sh ]; then
      /workspace/packages/devbox/scripts/start-egress.sh
    else
      echo "entrypoint: FATAL: start-egress.sh not executable; fail-closed posture requires egress init" >&2
      exit 1
    fi
    ```
    Rationale: explicit fail-hard if the script is missing (fail-closed default; NFR6). No silent-allow path.
  - [ ] Subtask 10.2: create `docs/invariants/devbox-egress.md` — invariant doc consolidating the three sub-contracts (SC-10):
    - Frontmatter: `id: INV-devbox-egress-contract`, `title: Devbox egress policy contract`, `owner: substrate-maintainer`, `updated: 2026-04-21`.
    - § Intent: paragraph pinning fail-closed DNS + IPv4/IPv6 parity + atomic reload as non-negotiable.
    - § Mechanism: reference architecture § S5; reference `packages/devbox/{dnsmasq,nftables,whitelist*}/…`; reference `scripts/{start,reload}-egress.sh`.
    - § Verification: SC-7 verbatim commands + SC-5 atomic-reload contract + AC 5 fail-closed smoke.
    - § Amendment: this invariant is **substrate-authoritative** (fork-extension via `INVARIANTS.fork.md` MAY ADD per-fork allow-list entries but MUST NOT relax fail-closed default).
  - [ ] Subtask 10.3: add a manifest entry to `packages/keel-invariants/src/invariants.manifest.ts` (format per Story 1.8 precedent):
    ```ts
    {
      id: 'INV-devbox-egress-contract',
      name: 'Devbox egress policy contract',
      description: 'Fail-closed DNS (dnsmasq) + IPv4/IPv6 default-deny (nftables) + atomic reload; upstream cc-devbox divergent-whitelist + fail-open resolv.conf + IPv6 gap closed.',
      sourcePath: 'docs/invariants/devbox-egress.md',
      contentHash: 'sha256:<computed>',
      anchors: ['### Devbox egress (Story 2.3)'],
    }
    ```
  - [ ] Subtask 10.4: add the anchor `### Devbox egress (Story 2.3)` section to `INVARIANTS.md` — bullet list citing `INV-devbox-egress-contract` → `docs/invariants/devbox-egress.md`. Match the existing INVARIANTS.md house style (Story 1.8 + 2.1 precedent — backtick-wrapped ID + one-line description + doc link).
  - [ ] Subtask 10.5: refresh `contentHash` via Story 2.2 iter-153 protocol: `pnpm -C packages/keel-invariants build && node packages/keel-invariants/dist/check.js` → capture the expected hash → paste into manifest → re-run → exit 0 green.

- [ ] **Task 11 — `packages/devbox/README.md` + `.envrc.example` updates** (AC 1, SC-14)
  - [ ] Subtask 11.1: `README.md` — update M0.5 deliverables table row for Story 2.3 (egress policy): strikethrough the `deferred` annotation, append ` *(landed iter-<N>)*` where `<N>` is the dev-story landing iteration (fill at dev-story close, not at this draft).
  - [ ] Subtask 11.2: `README.md` — add a new `## Egress policy (Story 2.3)` section with subsections:
    - § Overview: one paragraph on the dual-layer belt-and-braces (dnsmasq NXDOMAIN + nftables drop).
    - § Files: list the eight new files (`whitelist.default.txt`, `whitelist/{npm,anthropic,github}.txt`, `nftables/egress.nft`, `dnsmasq/dnsmasq.conf`, `scripts/{start,reload,monitor,egress-log-tailer}-egress.sh`).
    - § Verification: the SC-7 IPv4/IPv6 parity command + an AC 5 fail-closed smoke (`docker exec devbox curl -m 3 https://example-unwhitelisted.invalid` → non-zero exit).
    - § Reload: how to trigger atomic reload (`docker exec devbox /workspace/packages/devbox/scripts/reload-egress.sh /run/keel-whitelist.composed.txt`). Note Story 2.4 adds the user-facing `pnpm devbox:whitelist sync` wrapper.
    - § Known upstream bugs fixed: three-line list (divergent whitelist tooling, fail-open resolv.conf fallback, IPv6 gap).
  - [ ] Subtask 11.3: `.envrc.example` — add a new section `# --- Egress policy (Story 2.3) ---` with ONE knob:
    ```
    KEEL_DEVBOX_DNS_UPSTREAM=1.1.1.1  # Upstream resolver for whitelisted domains. Cloudflare default; operator may retune to corporate resolver. Consumed by packages/devbox/scripts/reload-egress.sh (Story 2.3).
    ```
    DO NOT add a whitelist-source knob or a rotation-size knob (SC-14 + SC-4).
  - [ ] Subtask 11.4: verify `docker compose config` parses cleanly after `.envrc.example` + compose changes (deferred to operator workstation — record in Debug Log References at dev-story closure per Story 2.2 precedent).

- [ ] **Task 12 — Live smokes (positive + negative + parity + atomic-reload)** (AC 1–5)
  - [ ] Subtask 12.1: positive smoke (AC 1 + AC 5 allow-path) — inside a freshly-started container, `curl -m 5 -sSf https://registry.npmjs.org/` exits 0 (npm domain is whitelisted). Record in Debug Log References.
  - [ ] Subtask 12.2: negative smoke (AC 5 deny-path) — inside the same container, `curl -m 3 -sSf https://example.com/ 2>&1 | grep -Ei 'could not resolve|refused|timed out'` exits 0 (connection fails; message indicates fail-closed). Record stderr.
  - [ ] Subtask 12.3: IPv4 parity smoke (AC 2) — `nft list chain inet keel_egress output_v4 | grep -q 'policy drop'` exits 0. Record.
  - [ ] Subtask 12.4: IPv6 parity smoke (AC 2) — `nft list chain inet keel_egress output_v6 | grep -q 'policy drop'` exits 0. Record.
  - [ ] Subtask 12.5: atomic-reload smoke (AC 4) — start a long-running `curl --keepalive-time 60 https://api.anthropic.com/` from inside the container in background; invoke `reload-egress.sh` (same whitelist); verify the background curl connection is not broken (exit code 0 on completion) + verify `reload-egress.sh` exits 0 within 2s. Record timing + both exit codes.
  - [ ] Subtask 12.6: JSONL schema smoke (AC 3) — after smokes 12.1 + 12.2, read the last 10 lines of `/workspace/logs/egress-queries.jsonl` + validate each parses as JSON via `jq -c .` + contains all six SC-3 fields. Record.
  - [ ] Subtask 12.7: log-rotation smoke (AC 3) — synthesize 51 MB of test JSONL writes (or reduce the threshold temporarily via an internal constant for the smoke), verify `egress-queries.jsonl.1.gz` appears + original file truncates. Record.
  - [ ] Subtask 12.8: backend-safety note — all smokes run as one-shot `docker exec` invocations against a started container; no `docker compose run` (backend-B iteration-env bind-mount denial per Story 2.1 iter-127 lesson). If iteration env cannot launch the container, defer smokes 12.1–12.7 to operator workstation and document in Blocked section.

- [ ] **Task 13 — Change Log v1.0 + sprint-status flip** (lifecycle hygiene)
  - [ ] Subtask 13.1: add v1.0 entry to this story file's Change Log section (iter number, draft summary, Status transition `backlog → ready-for-dev`, sprint-status transition).
  - [ ] Subtask 13.2: flip `_bmad-output/implementation-artifacts/sprint-status.yaml` row `2-3-egress-policy-…` from `backlog` → `ready-for-dev`.
  - [ ] Subtask 13.3: append a new `# last_updated: 2026-04-21 Story-2-3-ready-for-dev UTC` comment line at the top of sprint-status.yaml (match Story 2.2 precedent format).
  - [ ] Subtask 13.4: ensure no scope creep — this story delivers EXACTLY the egress mechanism (in-container dnsmasq + nftables + reload primitive + JSONL monitor + invariant doc + README + .envrc knob). Stories 2.4 (whitelist CLI), 2.5 (hardening/non-root), 2.6 (host-side pnpm wrappers), 2.13 (healthcheck) remain in `backlog` until their turn.

## Dev Notes

### Architecture pin — S5 §Egress-Policy Mechanism (non-negotiable)

Architecture § S5 (line 224 of `_bmad-output/planning-artifacts/architecture.md`) pins the **dual-layer belt-and-braces** approach:

> Belt-and-braces: repaired dnsmasq (DNS authority + JSONL query log for FR1a observability) + nftables (layer-3 egress enforcement at packet level for IPv4 + IPv6 default-deny, closes the "dnsmasq slow/restarting" and "IPv6 bypasses dnsmasq" holes). Both reload atomically via `pnpm devbox:whitelist sync` which rewrites `whitelist.default.txt` + `nft` table + reloads dnsmasq under a single shell-script guarded by a file lock.

The mechanism choice is NOT "deferred" at story time — architecture has decided. PRD FR1a's "mechanism deferred to architecture" has been satisfied. Story 2.3 implements what architecture pinned.

### File layout (pinned by `architecture.md` lines 975–1004)

```
packages/devbox/
├── Dockerfile                     # Story 2.1 — extended by Task 1
├── docker-compose.yml             # Story 2.1 + Story 2.2 — extended by Task 9
├── entrypoint.sh                  # Story 2.1 — extended by Task 10 (single new block)
├── .envrc.example                 # Story 2.2 — extended by Task 11.3 (one new knob)
├── README.md                      # Story 2.1 — extended by Task 11.1 + 11.2
├── VERSIONS.md                    # Story 2.1 — extended by Task 1.3
├── whitelist.default.txt          # NEW (Task 2.1)
├── whitelist/
│   ├── npm.txt                    # NEW (Task 2.2)
│   ├── anthropic.txt              # NEW (Task 2.2)
│   └── github.txt                 # NEW (Task 2.2)
├── nftables/
│   └── egress.nft                 # NEW (Task 4)
├── dnsmasq/
│   └── dnsmasq.conf               # NEW (Task 3)
└── scripts/
    ├── benchmark.sh               # Story 2.1 — untouched
    ├── start-egress.sh            # NEW (Task 5) — entrypoint helper
    ├── reload-egress.sh           # NEW (Task 6) — atomic reload primitive
    ├── egress-log-tailer.sh       # NEW (Task 7) — JSONL emitter + rotation
    └── monitor.sh                 # NEW (Task 8) — operator JSONL tail
```

Other repo-level touches:
- `docs/invariants/devbox-egress.md` — NEW (Task 10.2)
- `packages/keel-invariants/src/invariants.manifest.ts` — one new entry (Task 10.3)
- `INVARIANTS.md` — new anchor section (Task 10.4)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — row flip + timestamp (Task 13)

### Scope boundary — what Story 2.3 does NOT deliver

| Scope | Owner | Rationale |
|---|---|---|
| `packages/devbox/scripts/whitelist.sh` (user-facing CLI with `add/remove/list/sync` + diff summary + per-fork override composition) | Story 2.4 | Architecture pins this file; Story 2.3 ships the `reload-egress.sh` primitive that Story 2.4's `whitelist.sh sync` invokes. |
| Per-fork override file (gitignored) + AGENTS.md documentation of the path | Story 2.4 | Story 2.3's static composition is baseline + fragments only (SC-8). |
| `user: "dev"` non-root container user | Story 2.5 | Hardening story; Story 2.3 runs as root (egress init needs CAP_NET_ADMIN + port-53 bind). |
| `cap_drop: [ALL]` + `security_opt: [no-new-privileges:true]` | Story 2.5 | Same as above. |
| tmpfs mount stanzas for `/tmp`, `/var/tmp`, `/workspace/logs` consuming `KEEL_DEVBOX_TMPFS_*` | Story 2.5 | Story 2.3's JSONL log path is `/workspace/logs/egress-queries.jsonl` — works on bind-mount today; becomes tmpfs post-Story 2.5. |
| Host-side `pnpm devbox:whitelist sync` wrapper + all other `pnpm devbox:*` CLI verbs | Story 2.6 | Host-side CLI surface; Story 2.3 is entirely in-container. |
| dnsmasq + sshd healthcheck compose stanza | Story 2.13 | Dedicated healthcheck story; Story 2.3 makes dnsmasq available but does NOT wire healthcheck. |
| Epic 4 FR37 security-evidence consumer reading `/workspace/logs/egress-queries.jsonl` | Epic 4 | Story 2.3 PINS the path + schema so Epic 4 can hard-reference it. |
| Per-fork INV-devbox-egress-* split invariants (Growth-tier) | Post-1.0 | SC-10: Story 2.3 registers ONE consolidated `INV-devbox-egress-contract`. |

### Previous story intelligence — patterns Story 2.3 MUST reuse

**From Story 2.1 (landed iter-144):**
- Dockerfile apt-get single-layer discipline: append to the existing `apt-get install` block; end with `apt-get clean && rm -rf /var/lib/apt/lists/*`. DO NOT create a new RUN block.
- Scripts naming: kebab-case `.sh`, `#!/usr/bin/env bash`, `set -euo pipefail`, `0755` perm.
- Entrypoint discipline: narrow scope; each story adds ONE hook (chown from Story 2.1, egress from Story 2.3). DO NOT inline.
- Forbidden-at-runtime pattern: NO `npm install`, `pip install`, `curl | sh`, `wget | sh` in any of the new scripts. Use image-baked tools only.
- VERSIONS.md append-only: new `### Egress policy (Story 2.3)` section records apt versions at bake time.
- README.md "What does NOT deliver" table — update Story 2.3 row: strikethrough + landing-iter annotation.
- Backend-B iteration-env bind-mount denial: `docker compose run` from iteration env FAILS; defer runtime smokes to operator workstation.

**From Story 2.2 (landed iter-148, CR-closed iter-154):**
- `.envrc.example` knob format: `KEEL_DEVBOX_<NAME>=<default>  # <unit+rationale+consumer>` (≤120 chars). Story 2.3 adds exactly one knob (`KEEL_DEVBOX_DNS_UPSTREAM`) in a new `# --- Egress policy (Story 2.3) ---` section.
- contentHash refresh protocol (Task 10.5): build → run sync-gate → capture expected hash → paste into manifest → re-run → verify exit 0. DO NOT hand-compute hashes.
- Allow-list discipline: Story 2.2 CR iter-151 AR-2 taught that allow-list sentences in invariant docs must narrow to files with corresponding `.gitignore` bang-negations. Story 2.3 adds NO committed `.example` companions needing gitignore negations — whitelist fragments are committed plaintext (not secrets).
- Live-smokes dual-assertion convention (positive + negative exit codes + stderr pointer): Task 12 follows this pattern for AC 1 + AC 5.
- Change Log versioning: v1.0 = initial draft, v1.1 = pre-dev SM fixes, v1.2 = ATDD (or skip), v1.3 = dev-story landing, v1.4 = post-dev SM, v1.5 = CR opener, v1.6+ = drain iterations, v1.N = CR re-run close.
- Scope-creep prevention: Completion Notes MUST explicitly list every downstream story whose scope Story 2.3 did NOT touch (Story 2.4 whitelist CLI, Story 2.5 hardening, Story 2.6 host-side pnpm, Story 2.13 healthcheck).
- Story 2.2 CR PATCHED mistakes Story 2.3 MUST NOT repeat:
  - AR-1 (iter-152): negative smoke filenames must match the exact regex under test (`/tmp/fake.envrc` did NOT match; fix was `/tmp/.envrc`). Story 2.3 applies this to any regex-based validation (not anticipated in Story 2.3 — no new regex rules).
  - AR-2 (iter-153): allow-list sentence asymmetry (listing `.envrc.local.example` without `.gitignore` bang-negation). Story 2.3 has no equivalent risk (no `.example` companions introduced).

### JSONL schema (SC-3 verbatim) — FR37 consumer contract

Each line (UTF-8 + LF, one JSON object):

```json
{"timestamp":"2026-04-21T12:34:56.789Z","query":"api.anthropic.com","type":"A","result":"allow","upstream":"1.1.1.1","client":"127.0.0.1"}
```

Field contract (stable, append-only):
- `timestamp` — ISO 8601 UTC with millisecond precision + `Z` suffix
- `query` — queried domain (lowercase, trailing dot stripped)
- `type` — DNS record type: `A`, `AAAA`, `CNAME`, `MX`, `TXT`, `SRV`, `PTR`, `ANY`, or parse-error raw string
- `result` — one of `allow` (whitelisted, forwarded upstream), `block` (nftables dropped the TCP attempt), `nxdomain` (dnsmasq returned NXDOMAIN), `servfail` (upstream failure), `parse-error` (log-line parse failed)
- `upstream` — upstream resolver IP if query was forwarded; `null` if blocked/NXDOMAIN
- `client` — source IP of the query (typically `127.0.0.1` inside the container)

Epic 4 security-evidence consumer (FR37) treats this file as append-only + rotation-aware (reads `egress-queries.jsonl` + all `.N.gz` backups).

### Atomic reload contract (SC-5 verbatim) — the key invariant

Atomic reload = "either both layers apply the new policy, or neither does." Mechanism:

```
flock -x /run/keel-egress.lock → render new nft ruleset → nft -f (kernel-atomic) → kill -HUP dnsmasq → release flock
```

- `nft -f` is **kernel-atomic**: the new ruleset replaces the old in a single transaction; in-flight packets matching the old ruleset's `ct state established` rule continue to match the new ruleset's equivalent rule (the `established,related accept` rule is preserved across reloads).
- `kill -HUP dnsmasq` re-reads config without daemon restart; active DNS queries complete against the old config (UDP is stateless but dnsmasq's answer cache persists).
- Failure modes:
  - `nft -f` fails → previous ruleset stays active (kernel rollback); `reload-egress.sh` exits non-zero before dnsmasq HUP; dnsmasq config unchanged. Atomicity preserved.
  - `nft -f` succeeds but `kill -HUP` fails → new nftables rules active with old dnsmasq config. **This is the fallible seam.** Mitigation: dnsmasq HUP rarely fails; pidfile-read failure falls back to `pkill -HUP dnsmasq` (SC-5 subtask 6.7). If both fail, Story 2.3 emits a stderr pointer + exit non-zero; operator may manually restart dnsmasq (Story 2.4 CLI will surface this via diff-summary). Accepted residual risk at 1.0.

### Runtime location — in-container (SC-1 rationale)

- AC 1 verbatim: "When the container starts, dnsmasq runs as the in-container DNS authority."
- Architecture § S5 line 224: "atomic reload via `pnpm devbox:whitelist sync` … rewrites `whitelist.default.txt` + `nft` table + reloads dnsmasq under a single shell-script guarded by a file lock" — single script, single container.
- Sidecar services would require `network_mode: container:devbox` or service-mesh coupling + cross-container flock (adds complexity + failure modes). In-container daemons are simpler + match AC verbatim.
- The `# TODO(Story 2.3): add nftables / dnsmasq sidecar services` comment at `docker-compose.yml:10` is stale phrasing from early planning (pre-architecture pin); Task 9.1 replaces it with the actual wiring comment.

### Upstream cc-devbox bugs Story 2.3 closes (verbatim from `packages/devbox/README.md` + PRD M0.5)

1. **Divergent whitelist tooling** — upstream ships `manage-whitelist.sh` (uses `/etc/whitelist-domains.conf` + `pkill -HUP`) AND a separate `whitelist` script (uses `/workspace/.claude/whitelist` + `pkill + respawn`). Different state, different reload, intermittent unexpected blocks. **Story 2.3 fix:** single mechanism via `reload-egress.sh`; Story 2.4's `whitelist.sh` is the sole operator entry point.
2. **Fail-open resolv.conf fallback to 8.8.8.8** — upstream's `/etc/resolv.conf` hardcodes `8.8.8.8` as a fallback; if dnsmasq is slow/restarting, queries silently leak to public DNS. **Story 2.3 fix:** SC-13 pins resolv.conf to `nameserver 127.0.0.1` only; no public-DNS fallback; if dnsmasq is down, resolution fails (fail-closed per NFR6).
3. **IPv6 default-deny gap** — upstream's `whitelist.conf` only blocks IPv4 (`address=/#/127.0.0.1`); IPv6 queries (AAAA) bypass. **Story 2.3 fix:** `address=/#/0.0.0.0` + `address=/#/::` in dnsmasq.conf; `chain output_v6 { policy drop }` in nftables.

### Backend-B iteration-env constraint (inherited from Story 2.1)

The cc-devbox iteration env at 2026-04-21 uses Docker backend B (host socket-passthrough per `INV-devbox-dind-available`). Story 2.1 iter-127..iter-144 established that `docker compose run`/`docker compose build` from iteration env FAILS (bind-mount path not in Docker Desktop File Sharing allowlist). Story 2.3 dev-story:
- Writes/edits are safe (text files only).
- Static validation (`nft -c -f ...`, `dnsmasq --test --conf-file=...`) is deferred to operator workstation at iteration close.
- Live smokes (Task 12) are deferred to operator workstation. Document results in Debug Log References at dev-story closure per Story 2.2 v1.3 precedent.
- Dev-story MUST NOT block on running the container from iteration env.

### Required capabilities at runtime (SC-6)

- `CAP_NET_ADMIN` — required for `nft` rule loading (nftables uses netlink with NLM_F_REQUEST that needs NET_ADMIN).
- `CAP_NET_RAW` — required for raw sockets (not strictly needed by nftables, but dnsmasq may use it for DHCP-like probes; defensive-inclusive per architecture § Execution environment (l.73)).
- `CAP_NET_BIND_SERVICE` — required to bind port 53 (<1024). The default root container has this in the full cap set; the explicit `cap_add` list does NOT include it by name — dnsmasq's `user=nobody` directive (Task 3) triggers cap-drop AFTER binding, which is allowed because port 53 bind happens while still root. Post-Story-2.5 with `cap_drop:[ALL]`, we MAY need to add `CAP_NET_BIND_SERVICE` to the cap_add list OR run dnsmasq before the user switch. Story 2.5's story file will decide; Story 2.3 keeps cap_add minimal to NET_ADMIN + NET_RAW and relies on root start → user=nobody drop inside dnsmasq.

### Dev-agent guardrails (MUST-follow list)

1. **Fail-closed everywhere.** If dnsmasq fails to start → `start-egress.sh` exits 1 (entrypoint fails the container). If `nft -f` fails → `reload-egress.sh` exits non-zero (previous rules stay active). If whitelist composition produces zero entries → dnsmasq + nftables still apply (fail-closed default; no domain reachable); log a warning but do not fail the init.
2. **Atomic-reload is kernel-level.** Use `nft -f <single-file>` (not multiple `nft add rule` calls). Use dnsmasq SIGHUP (not restart). File-lock via `flock` (not lockfile-polling).
3. **IPv4/IPv6 parity verbatim.** Both chains, both `policy drop`, both verified by SC-7 commands in Task 12.3 + 12.4.
4. **JSONL schema stable.** SC-3 field order + types + nullability — do not deviate. Epic 4 FR37 depends on stability.
5. **Scope isolation.** No `cap_drop: [ALL]` (Story 2.5). No `user: "dev"` (Story 2.5). No tmpfs stanzas (Story 2.5). No `pnpm devbox:whitelist` host-side CLI (Story 2.6). No `whitelist.sh` user-facing CLI (Story 2.4). No healthcheck (Story 2.13). No per-fork override (Story 2.4). These are all forbidden scope creep.
6. **Entrypoint minimal surgery.** ONE new block inserted; no inlining; call `start-egress.sh` via absolute bind-mount path (`/workspace/packages/devbox/scripts/start-egress.sh`); fail-hard if missing.
7. **Invariant drift discipline.** Task 10.5 sync-gate must exit 0 before commit. Any contentHash mismatch blocks push.
8. **No runtime installs.** Everything baked at image-build time (Task 1). New scripts MUST NOT `apt-get install`, `npm install`, `curl | sh`, `wget | sh`.
9. **Kebab-case + .sh + 0755.** All new scripts follow Story 2.1's benchmark.sh shape.
10. **Backend-B aware.** Defer runtime smokes to operator workstation; document in Debug Log References; do NOT block dev-story on iteration-env container failures.
11. **No `.envrc` edits.** Only `.envrc.example` (the committed template). Story 2.2 deny-list enforces this at prek time.
12. **Single-source-of-truth discipline.** The `docs/invariants/devbox-egress.md` doc is the consolidated contract (SC-10). DO NOT create three separate invariant docs.

### Project Structure Notes

- `packages/devbox/` — owned by the devbox substrate; Story 2.3 adds the `nftables/`, `dnsmasq/`, `whitelist/` subdirectories + 4 new scripts.
- `docs/invariants/` — owned by the invariants-contract family (Stories 1.7 + 1.8 + 1.9 + 2.1 precedent); Story 2.3 adds `devbox-egress.md`.
- `packages/keel-invariants/src/invariants.manifest.ts` — owned by the manifest contract (Story 1.8); Story 2.3 adds ONE entry.
- `INVARIANTS.md` — owned by the agent-readable index (Story 1.7); Story 2.3 adds ONE anchor section.
- `_bmad-output/implementation-artifacts/sprint-status.yaml` — owned by the lifecycle tracker; Story 2.3 flips one row + adds a timestamp comment.
- No other repo areas touched. No new packages, no new module boundaries, no new test frameworks (Epic 13 later).

**Detected conflicts / variances:** none. The architecture tree (l.975–1004) matches the file layout Story 2.3 produces. The TODO comments at `docker-compose.yml:10` and `entrypoint.sh:20` are replaced by actual wiring; other TODO(Story N.X) comments are preserved verbatim.

### References

- [Source: `_bmad-output/planning-artifacts/epics.md` § Epic 2 § Story 2.3] — user-story + AC 1–5 verbatim.
- [Source: `_bmad-output/planning-artifacts/prd.md` § FR1a (l.933)] — fail-closed + IPv4/IPv6 parity + atomic-reload + repo-tracked + JSONL contract.
- [Source: `_bmad-output/planning-artifacts/prd.md` § NFR6 (l.1077)] — binding statement "IPv4 and IPv6 default-deny policies are maintained in parity; whitelist reload is atomic."
- [Source: `_bmad-output/planning-artifacts/prd.md` § Devbox Implementation Contract (l.549)] — fail-closed resolver + no public-DNS fallback + NET_ADMIN/NET_RAW caps.
- [Source: `_bmad-output/planning-artifacts/architecture.md` § S5 (l.224)] — dual-layer belt-and-braces + atomic-reload via file-locked shell-script.
- [Source: `_bmad-output/planning-artifacts/architecture.md` § Execution Environment (l.73)] — fail-closed DNS + IPv4/IPv6 parity + atomic reload + structured JSONL query log.
- [Source: `_bmad-output/planning-artifacts/architecture.md` § Devbox Package Tree (l.975–1004)] — file layout pin.
- [Source: `_bmad-output/planning-artifacts/architecture.md` § I5a Docker-in-Docker (l.295–297)] — DinD substrate requirement → `INV-devbox-dind-available`.
- [Source: `_bmad-output/planning-artifacts/implementation-readiness-report-2026-04-19.md` (l.263 + 286 + 301)] — Story 2.3 scope confirmed; FR1a architecture-phase handoff resolved in epics.md § S5.
- [Source: `packages/devbox/README.md` § M0.5 deliverables table + § Upstream cc-devbox bugs] — three bugs Story 2.3 fixes (divergent whitelist, fail-open resolv.conf, IPv6 gap).
- [Source: `packages/devbox/docker-compose.yml` l.10 + l.86–91] — TODO(Story 2.3) comment to replace + adjacent TODOs for Stories 2.5/2.11/2.12/2.13 to preserve.
- [Source: `packages/devbox/entrypoint.sh` l.20–21] — Story 2.1 narrowed scope + Story 2.3 hook-point.
- [Source: `docs/invariants/devbox-dind.md` § Backend contract + Safety rule] — backend A vs B; Backend B is current; broad-state-mutation discipline.
- [Source: `_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md` § Dev Notes + § File List] — substrate patterns Story 2.3 inherits.
- [Source: `_bmad-output/implementation-artifacts/2-2-envrc-parameterisation-contract.md` § Dev Notes + § Change Log v1.0–v1.8] — .envrc.example knob format + contentHash refresh + sync-gate protocol + live-smokes pattern + Change Log versioning.
- [Source: `_bmad-output/implementation-artifacts/deferred-work.md` § Re-run from: code review of story-2-2-envrc-parameterisation-contract (2026-04-21 iter-154)] — Story 2.2 CR defers; none carry-to Story 2.3 (Story 2.3 is greenfield mechanism).
- [Source: Story 2.2 CR iter-151 AR-1 + AR-2 lessons] — negative-smoke filename discipline + allow-list asymmetry prevention.

## Dev Agent Record

### Agent Model Used

_{to be filled at dev-story landing — expected claude-opus-4-7-1m or sonnet-4-6 per ralph.py subprocess config}_

### Debug Log References

_{to be filled at dev-story landing — record SC-7 commands' output, AC 12.1–12.7 smoke results, sync-gate output, and any backend-B deferrals}_

### Completion Notes List

_{to be filled at dev-story landing — explicit scope-isolation audit vs Stories 2.4 / 2.5 / 2.6 / 2.13 per Guardrail 5; verification of NO creep}_

### File List

_{to be filled at dev-story landing}_

**Expected new files:**

- `packages/devbox/whitelist.default.txt`
- `packages/devbox/whitelist/npm.txt`
- `packages/devbox/whitelist/anthropic.txt`
- `packages/devbox/whitelist/github.txt`
- `packages/devbox/nftables/egress.nft`
- `packages/devbox/dnsmasq/dnsmasq.conf`
- `packages/devbox/scripts/start-egress.sh`
- `packages/devbox/scripts/reload-egress.sh`
- `packages/devbox/scripts/egress-log-tailer.sh`
- `packages/devbox/scripts/monitor.sh`
- `docs/invariants/devbox-egress.md`

**Expected modified files:**

- `packages/devbox/Dockerfile` (apt-get append)
- `packages/devbox/docker-compose.yml` (cap_add + TODO-comment replacement)
- `packages/devbox/entrypoint.sh` (single new block)
- `packages/devbox/.envrc.example` (one new knob section)
- `packages/devbox/README.md` (M0.5 table + new § Egress policy section)
- `packages/devbox/VERSIONS.md` (new § Egress policy subsection)
- `packages/keel-invariants/src/invariants.manifest.ts` (one new entry)
- `INVARIANTS.md` (one new anchor section)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (row flip + timestamp comment)
- `_bmad-output/implementation-artifacts/2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload.md` (Change Log v1.1+)

## Change Log

- **v1.0** (2026-04-21 iter-155): Initial drafting by `/bmad-create-story` (ultimate-context-engine pass). Story Status `backlog → ready-for-dev`. Sprint-status `2-3-egress-policy-dnsmasq-nftables-fail-closed-ipv4-ipv6-parity-atomic-reload: backlog → ready-for-dev` + `# last_updated: 2026-04-21 Story-2-3-ready-for-dev UTC` timestamp. Exhaustive analysis across PRD + architecture + epics + implementation-readiness + Story 2.1 + Story 2.2 dev notes + deferred-work produced 5 ACs (verbatim from epics.md) + 17 scope-clarifications (SC-1 through SC-17 covering runtime location, JSONL path/schema/rotation, atomic-reload mechanism, cap_add wiring, parity verification commands, whitelist boundary vs Story 2.4, scripts output-location, invariant consolidation, entrypoint surgery discipline, dnsmasq allow-mechanism, resolv.conf override, upstream DNS knob, JSONL emitter process model, log-rotation safety, workspace-logs dir) + 13 Tasks with ~50 subtasks. Architecture pin confirmed: S5 dual-layer belt-and-braces (dnsmasq + nftables) is decided; PRD's "mechanism deferred" has been satisfied. Scope boundary pinned vs Story 2.4 (whitelist CLI) + Story 2.5 (hardening + non-root + tmpfs) + Story 2.6 (host-side pnpm CLI) + Story 2.13 (healthcheck) + Epic 4 (FR37 security-evidence consumer). Previous-story patterns captured: contentHash refresh + sync-gate protocol + .envrc.example knob format + live-smokes dual-assertion + Change Log versioning + Story 2.2 CR PATCHED mistakes (AR-1 negative-smoke filename + AR-2 allow-list asymmetry) explicitly guarded against. Backend-B iteration-env constraint carried from Story 2.1. JSONL schema pinned (6 stable fields) for Epic 4 FR37 consumer hard-reference. Atomic-reload mechanism pinned (flock + nft -f kernel-atomic + dnsmasq SIGHUP + release). IPv4/IPv6 parity verification pinned as single `inet keel_egress` table with `output_v4` + `output_v6` chains both `policy drop` (SC-7 verbatim commands in Task 12.3 + 12.4). One consolidated invariant `INV-devbox-egress-contract` registered per SC-10 (vs three split invariants) — per Story 2.2 iter-151 AR-2 lesson that contract-splitting grows asymmetry risk. One new `.envrc.example` knob (`KEEL_DEVBOX_DNS_UPSTREAM`) added (SC-14); no whitelist-source knob (Story 2.4 scope) and no rotation-size knob (pinned at 50 MB per SC-4). Next: `/bmad-create-story (args: "review")` pre-dev SM validation per § Story Lifecycle Decision Matrix row `drafted → validated`.
