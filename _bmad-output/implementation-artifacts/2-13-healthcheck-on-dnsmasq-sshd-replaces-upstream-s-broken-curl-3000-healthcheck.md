# Story 2.13: Healthcheck on dnsmasq + sshd (replaces upstream's broken `curl :3000` healthcheck)

Status: ready-for-dev

<!-- Note: Validation is optional. Run `/bmad-create-story (args: "review")` for pre-dev quality check before `/bmad-testarch-atdd` / `/bmad-dev-story`. -->

## Story

As a substrate maintainer,
I want `packages/devbox/docker-compose.yml`'s `healthcheck:` block to probe dnsmasq liveness (and sshd when `KEEL_DEVBOX_SSH=true`) rather than upstream cc-devbox's broken `curl :3000` healthcheck,
So that the container's `State.Health.Status` reflects actual in-container service health — `pnpm devbox:status` (Story 2.6 AC 2.6.9) and `pnpm devbox:start`'s healthcheck poll (Story 2.6 AC 2.6.4 / `start.sh:92-120`) report meaningful state instead of a persistent `unhealthy` noise (upstream) or a perpetual `starting` stub (Story 2.13 unblocks the `.State.Health.Status` branch that `start.sh:103` and `status.sh:54` already consume).

## Acceptance Criteria

1. **No `curl localhost:3000` in the healthcheck.** Given `packages/devbox/docker-compose.yml`, when I inspect the `services.devbox.healthcheck` block, then it does NOT invoke `curl localhost:3000` (the upstream cc-devbox carry-over referenced in `packages/devbox/README.md § cc-devbox upstream provenance § Known upstream bugs fixed → "Broken `curl :3000` healthcheck"`). The TODO marker at `docker-compose.yml:263` (`# TODO(Story 2.13): healthcheck dnsmasq + sshd liveness.`) is removed and replaced by a real `healthcheck:` block.

2. **dnsmasq liveness probe — DNS query against `127.0.0.1:53` resolving a known-whitelisted domain.** Given the compose `healthcheck:` block, when a probe runs, then it executes a DNS query against `127.0.0.1:53` that resolves a known-whitelisted domain (canonical: `api.github.com`, permanently present in `packages/devbox/whitelist/github.txt` per Story 2.3 + Story 2.9 substrate — the only whitelist fragment guaranteed to be load-bearing for every fork because `gh auth login` / `gh push` depend on it). The probe exits 0 iff dnsmasq (a) accepts the DNS query, (b) returns a response (NXDOMAIN counts as success for liveness — we're checking dnsmasq IS RESPONSIVE, not that the whitelist contains the domain). Canonical probe: `dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com` (exit 0 on dnsmasq response, exit 9 on timeout).

3. **Conditional sshd liveness probe when `KEEL_DEVBOX_SSH=true`.** Given `KEEL_DEVBOX_SSH=true` is propagated into the container via `docker-compose.yml § environment` per Story 2.12 Task 4 (sources the normalised `KEEL_DEVBOX_SSH_RESOLVED` — iter-273 PATCH-2), when a probe runs, then it ADDITIONALLY probes sshd liveness on `127.0.0.1:2222` (TCP connect via `nc -z 127.0.0.1 2222`) AND the healthcheck fails if EITHER dnsmasq OR sshd is down. Logical: `healthcheck succeeds IFF (dnsmasq responds) AND (KEEL_DEVBOX_SSH != "true" OR sshd port 2222 accepting TCP)`. No healthcheck difference in `KEEL_DEVBOX_SSH=false` mode — single probe (dnsmasq only).

4. **Mid-run service death transitions container to `unhealthy`.** Given the container is running and healthy, when dnsmasq (or sshd under opt-in) crashes mid-run, then the next probe fails, and after `retries: 3` consecutive failures the container's `State.Health.Status` transitions from `healthy` to `unhealthy`. `pnpm devbox:status` (Story 2.6 `status.sh:54` — `docker inspect --format '{{.State.Health.Status}}'`) surfaces the `unhealthy` state to the operator. `start.sh:103-120` already handles the `unhealthy-but-running` case (emits pointer to `pnpm devbox:logs`); Story 2.13 provides the actual probe that trips the transition.

5. **Healthcheck timing parameters documented with rationale.** Given the compose `healthcheck:` block, when I inspect it, then the four timing keys are set to `interval: 10s`, `timeout: 5s`, `retries: 3`, `start_period: 30s`, AND these values are documented in `packages/devbox/README.md § Healthcheck (Story 2.13)` with per-knob rationale (cold-start margin vs detection-latency trade-off; probe frequency vs dnsmasq JSONL log volume; single-probe timeout vs `dig +time=3 +tries=1` + `nc -z` combined worst-case wall time).

## Tasks / Subtasks

- [ ] **Task 1: Add `healthcheck:` block to `packages/devbox/docker-compose.yml`** (AC 1, AC 2, AC 3, AC 5)
  - [ ] **Insertion point.** Replace the TODO marker at `docker-compose.yml:263` (`# TODO(Story 2.13): healthcheck dnsmasq + sshd liveness.`) with a real `healthcheck:` block. Position the block AFTER the existing `tmpfs:` block (ends at `:262`) and BEFORE `restart: 'no'` (`:265`). Match the sibling block indentation (4 spaces under `services.devbox`).
  - [ ] **Healthcheck block contract** (copy-ready; NO placeholders). The `test` value composes dnsmasq-first + optional-sshd-second via a single shell expression. CMD-SHELL form (Compose-normalised to `["CMD-SHELL", "<cmd>"]`); `/bin/sh -c` wraps — POSIX-shell-safe syntax (no bashisms; no `[[ ... ]]`; no arrays):
    ```yaml
    # Story 2.13: dnsmasq liveness (always) + sshd liveness (when KEEL_DEVBOX_SSH=true).
    # Replaces upstream cc-devbox's broken `curl :3000` healthcheck (README §
    # cc-devbox upstream provenance § Known upstream bugs fixed). Probes run as
    # USER dev (Dockerfile:347) via docker exec semantics; `dig` + `nc` ship in
    # the Dockerfile apt layer (dnsutils + netcat-openbsd per Dockerfile:61-64).
    # KEEL_DEVBOX_SSH env var is populated by Story 2.12 § environment
    # propagation (compose:149 sources KEEL_DEVBOX_SSH_RESOLVED — iter-273
    # PATCH-2 — so case-folded true is canonical inside the container).
    # Probe domain `api.github.com` is always whitelisted (Story 2.9 github.txt
    # fragment is load-bearing for every fork's gh-auth flow); `+short` + `+time=3`
    # + `+tries=1` bounds the probe at ~3s even on transient upstream lag.
    # NXDOMAIN counts as success (we're measuring dnsmasq RESPONSIVENESS, not
    # whitelist membership); dig exits non-zero only on timeout / connection
    # refused — the signal we care about.
    healthcheck:
      test:
        - CMD-SHELL
        - >-
          dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com >/dev/null
          && { [ "${KEEL_DEVBOX_SSH:-false}" != "true" ] || nc -z 127.0.0.1 2222; }
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 30s
    ```
  - [ ] **Shell-syntax rationale.** `/bin/sh -c` on Ubuntu 24.04 is `dash` (Debian default), NOT bash. Use `[ ... ]` (POSIX test), `&&`/`||` chaining, `{...;}` grouping (terminal `;` required before `}` per POSIX sh). Do NOT introduce `[[ ... ]]`, `$(...)` trap-setup, or bash-only parameter expansions. The `>-` YAML folded-scalar form joins the two lines with a space — compose normalises this to a single CMD-SHELL string at parse time (`docker compose config` renders the joined form).
  - [ ] **Exit-code semantics.** `dig` exits 0 on successful DNS transaction (including NXDOMAIN responses); exits 9 on resolver timeout / connection refused (dnsmasq down); exits 10 on error. `nc -z <host> <port>` exits 0 on successful TCP connect + immediate close; exits non-zero on refused / timeout. The outer shell exit code is 0 iff both clauses succeed per POSIX `&&` semantics; Docker's HEALTHCHECK consumes `0 = healthy`, `1 = unhealthy`, `2 = reserved` (sh coerces non-zero to `1` for HEALTHCHECK purposes — verified Docker 29.x behaviour).
  - [ ] **No Dockerfile `HEALTHCHECK` directive.** Story 2.13 scope is compose-level ONLY. The Dockerfile deliberately stays HEALTHCHECK-free so that raw `docker run keel-devbox:local` (non-compose path, e.g. fork maintainer image-inspection) does NOT carry the probe — compose is the authoritative harness. Forks that want image-level HEALTHCHECK via Dockerfile MUST open an AMEND PR per FR44 `docs/invariants/fork.md § Amendment-vs-fork decision`.
  - [ ] **Compose-file roadmap comment (SC-15).** Update the Story-roadmap block at `docker-compose.yml:1-28` — the existing line 24 (`#   - Story 2.13 : healthcheck (dnsmasq + sshd liveness).`) converts to past tense: `#   - Story 2.13 : healthcheck (dnsmasq + sshd liveness). LANDED iter-<this>.` matching Stories 2.2 / 2.3 / 2.5 / 2.11 / 2.12 pattern.

- [ ] **Task 2: Verify probe tooling is already baked into the image** (AC 2, AC 3 prerequisite — no Dockerfile change expected; Task confirms)
  - [ ] **`dig` availability.** Confirm `dnsutils` is present at `packages/devbox/Dockerfile:61` in the apt layer (present per iter-123 bake; no change required at 2.13). `dig` is `/usr/bin/dig` on Ubuntu 24.04 apt install; no PATH issue under USER dev.
  - [ ] **`nc` availability.** Confirm `netcat-openbsd` is present at `packages/devbox/Dockerfile:64` (present per iter-123 bake). The OpenBSD `nc` variant supports `-z` (zero-byte probe / scan mode) — the `netcat-traditional` variant does NOT. Do NOT switch to `netcat-traditional`.
  - [ ] **Probe-as-dev permission.** Healthcheck CMD runs with the image's USER (dev per `Dockerfile:347`). `dig` opens a UDP client socket on a high ephemeral port (no CAP_NET_BIND_SERVICE needed); `nc -z` opens a TCP client socket to `127.0.0.1:2222` (no cap needed). Under `cap_drop: [ALL]` + three-cap allow (NET_ADMIN / NET_RAW / NET_BIND_SERVICE — Story 2.5), both probes succeed as dev. Verify at impl time: inside `pnpm devbox:shell`, run `dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com` and `nc -z 127.0.0.1 2222` (when `KEEL_DEVBOX_SSH=true`) — both exit 0 against a healthy container.
  - [ ] **No new apt package.** Task 2 is verification-only; no Dockerfile change; no rebake. If verification reveals a missing tool (unlikely given the known-bake state), land the apt addition under this Task with a one-line commit.

- [ ] **Task 3: Register `INV-devbox-healthcheck` + author `docs/invariants/devbox-healthcheck.md`** (AC 1–5 machine-enforced contract)
  - [ ] Add new entry to `packages/keel-invariants/src/invariants.manifest.ts`:
    - `id: 'INV-devbox-healthcheck'`
    - `description: 'Compose healthcheck probes dnsmasq liveness (always) + sshd liveness (when KEEL_DEVBOX_SSH=true); never curl :3000; timing parameters interval 10s / timeout 5s / retries 3 / start_period 30s documented with rationale (Story 2.13).'`
    - `sourcePath: 'docs/invariants/devbox-healthcheck.md'`
    - `contentHash: '<sha256 of the authored md file content>'`
    - `anchors: ['INV-devbox-healthcheck']`
  - [ ] **InvariantSchema five-field compliance** (Story 2.3 iter-156 LESSON; reaffirmed by Story 2.12 Task 5 iter-268; verified at `packages/keel-invariants/src/invariants.manifest.ts:3-15`): `InvariantSchema` = `{id, description, sourcePath, contentHash, anchors}` — no `name` field; `anchors` entries are bare ID strings; `contentHash` is bare 64-char lowercase hex. Cross-check the sibling `INV-devbox-ssh` entry (Story 2.12) for canonical shape.
  - [ ] Author `docs/invariants/devbox-healthcheck.md` with the following H2 sections (multi-faceted contracts embed sub-schemas verbatim in the `sourcePath` doc, per Story 2.3 iter-156 LESSON):
    - `## Intent` — compose healthcheck reflects actual in-container service health; the container's `State.Health.Status` is the single signal `pnpm devbox:status` (Story 2.6) and `pnpm devbox:start`'s poll (Story 2.6 AC 2.6.4) consume. Upstream cc-devbox's `curl :3000` healthcheck targeted a non-existent service and left every cc-devbox run permanently `unhealthy`; Story 2.13 closes that bug.
    - `## Probe contract` — composed shell expression, POSIX sh safe. Clause 1 (always): `dig @127.0.0.1 -p 53 +short +time=3 +tries=1 api.github.com` — probes dnsmasq. Clause 2 (iff `KEEL_DEVBOX_SSH=true`): `nc -z 127.0.0.1 2222` — probes sshd TCP listener. Liveness semantics: clause 1 success = dnsmasq RESPONSIVE (NXDOMAIN counts); clause 2 success = TCP three-way-handshake completes (does NOT exercise pubkey auth). The probe deliberately does NOT exercise whitelist membership or pubkey auth — both would add fragility without adding health signal (whitelist drift would false-positive the healthcheck; pubkey-auth probing would require committed test keys that weaken the trust model).
    - `## Timing parameters` — `interval: 10s` (probe every 10s; 6 probes/min/service = 8640 dnsmasq queries/day; entries accrue in `/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/egress-queries.jsonl` — expected volume documented for FR37 Epic-4 security-evidence consumer). `timeout: 5s` (kill hung probes at 5s; `dig +time=3 +tries=1` worst case 3s + `nc -z` worst case ~1s = 4s margin). `retries: 3` (container goes `unhealthy` after 3 consecutive failures — 30s detection latency post-start-period; balances transient-glitch tolerance against real-failure detection speed). `start_period: 30s` (entrypoint init budget: start-egress.sh ~3-5s for nftables + dnsmasq + resolv.conf pin; sshd ~1s under opt-in; 30s comfortably covers cold-boot + first-probe latency; failures during this window don't count against `retries`).
    - `## Probe tooling` — baked at image build: `dig` via `dnsutils` apt package (`Dockerfile:61`); `nc` via `netcat-openbsd` apt package (`Dockerfile:64`). The BSD `nc` variant is load-bearing — `netcat-traditional` does NOT support `-z`. Both probes run as USER dev (`Dockerfile:347`); no capability or SUID dependency. Do NOT switch to `curl` / `wget` / `openssl s_client` without updating this invariant.
    - `## SSH-conditional branch` — `KEEL_DEVBOX_SSH` env var is populated inside the container by `docker-compose.yml § environment` sourcing `KEEL_DEVBOX_SSH_RESOLVED` (Story 2.12 iter-273 PATCH-2). The healthcheck's POSIX-sh `[ "${KEEL_DEVBOX_SSH:-false}" != "true" ]` check reads the canonical case-folded value — no case-variant drift. In `KEEL_DEVBOX_SSH=false` mode, clause 2 short-circuits to `|| true` semantics (the first `[...]` test exits 0 for "not true" → chains past `||`), so only dnsmasq probes run. In `true` mode, both probes run; either failure marks unhealthy.
    - `## No curl :3000` — explicit prohibition. The base compose file's `healthcheck.test` MUST NOT reference `curl localhost:3000` under any circumstance — the upstream default is a known bug (no service listens on 3000 at substrate scope; Epic 7+ apps/web MAY later bind 3000, but the devbox healthcheck is NOT an app-layer probe). Forks adding app-layer health probes MUST do so via compose override or the Growth-tier fork-invariants scaffold, not by regressing the base `healthcheck.test`.
    - `## Fork extension contract` — forks MAY add fork-specific probes via compose override file (`docker-compose.fork.yml` or similar), merging into the base `healthcheck.test` array. Forks MAY NOT weaken the substrate probe: no removing the dnsmasq clause; no removing the sshd clause under `KEEL_DEVBOX_SSH=true`; no raising `interval` above 30s (slow-probe regression); no raising `timeout` above 10s (masks real hangs); no disabling retries. Growth-tier `INVARIANTS.fork.md` fork-owned rules are additive per FR45 + `docs/invariants/fork.md § Precedence`.
  - [ ] Compute `contentHash`: `sha256sum docs/invariants/devbox-healthcheck.md | awk '{print $1}'`. Paste the 64-char lowercase hex into the manifest entry. `pnpm keel-invariants:check` MUST pass after manifest + doc both land (Story 1.9 sync-gate verification).
  - [ ] Append entry to `INVARIANTS.md`. Anchor bullet MUST match the verbatim regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` per `packages/keel-invariants/src/sync-gate.ts:24` (Story 1.9 sync-gate). Lowercase-after-`INV-` prefix MANDATORY (Story 1.9 iter-7 LESSON). Anchor line:
    ```
    - **`INV-devbox-healthcheck`** — Compose healthcheck probes dnsmasq + sshd liveness; never curl :3000; timing parameters + rationale pinned. Source: `docs/invariants/devbox-healthcheck.md`.
    ```
  - [ ] Add new `### Devbox healthcheck (Story 2.13)` H3 in `INVARIANTS.md` AFTER the existing `### Devbox SSH (Story 2.12)` H3 body + its `INV-devbox-ssh` anchor bullet (`INVARIANTS.md:120-124` per iter-279), and BEFORE the existing `### Gitignored-secret commit-deny (Story 2.2)` H3 (at `INVARIANTS.md:126`; the Story-2.2 H3 lives AFTER all devbox H3s because the section order is not strictly numerical — Story 2.12 iter-268 LESSON). One-line H3 body mirroring Story 2.11/2.12's one-line shape, then the anchor bullet underneath.

- [ ] **Task 4: Operator + agent documentation** (AC 5 comprehension + operator-visibility of timing rationale)
  - [ ] **`packages/devbox/README.md`** — append new H2 `## Healthcheck (Story 2.13)` AFTER the existing `## Opt-in SSH (Story 2.12)` H2 (current file end: `:923` per iter-279 inventory; the § cc-devbox upstream provenance § already references Story 2.13 at line 921 `Broken curl :3000 healthcheck → Story 2.13 (dnsmasq + sshd liveness).` — this story UPDATES that forward-ref to past tense: `Broken curl :3000 healthcheck → fixed in Story 2.13 (dnsmasq + sshd liveness). LANDED iter-<this>.`) and BEFORE the existing `## cc-devbox upstream provenance` H2 (SC-17 sibling-append; do NOT edit prior story sections). Content:
    - (a) Problem framing: one paragraph explaining upstream cc-devbox's broken `curl :3000` healthcheck (service doesn't exist → container permanently `unhealthy`) and how Story 2.13 replaces it with real service probes.
    - (b) Probe shape: verbatim copy of the `healthcheck:` block from `docker-compose.yml` (AC 1 contract); annotation of which clause covers AC 2 (dnsmasq) and which covers AC 3 (sshd).
    - (c) Timing parameter table — four rows covering `interval` / `timeout` / `retries` / `start_period` with per-row rationale (lifted from `docs/invariants/devbox-healthcheck.md § Timing parameters`).
    - (d) Two operator walkthroughs:
      - **Default mode walkthrough:** fresh fork, `.envrc` default (`KEEL_DEVBOX_SSH=false`), `pnpm devbox:start` → healthcheck runs dnsmasq-only → `pnpm devbox:status` surfaces `healthcheck: healthy` within ~30-40s of container start.
      - **Opt-in sshd walkthrough:** operator sets `KEEL_DEVBOX_SSH=true`, `pnpm devbox:start` → healthcheck runs dnsmasq + sshd → kill sshd manually inside `pnpm devbox:shell` (`pkill sshd` — requires operator privilege OR operator has appended a pubkey and `ssh -p 2222 …` authenticated session with `kill <pid>`) → within ~30s `pnpm devbox:status` surfaces `healthcheck: unhealthy`.
    - (e) JSONL query-log volume note: healthcheck emits ~8640 dnsmasq queries/day to `/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/egress-queries.jsonl`. Operators consuming FR37 security-evidence feeds should expect this baseline. To filter: `jq 'select(.query != "api.github.com")'`.
    - (f) Integration with `pnpm devbox:start` + `pnpm devbox:status`: `start.sh:103-120` polls `State.Health.Status` — Story 2.13 UNBLOCKS the healthy/unhealthy branch (pre-Story-2.13, `start.sh` fell back to `State.Status` which is always `running` post-`up -d`). `status.sh:54` already reports `healthcheck: <status>` — unchanged code, now surfaces meaningful values.
    - (g) `INV-devbox-healthcheck` citation for the machine-enforced contract.
  - [ ] **DO NOT modify existing `## Host-side CLI (Story 2.6)`, `## Ralph loop (Story 2.7)`, `## Claude Code authentication (Story 2.8)`, `## gh CLI authentication (Story 2.9)`, `## Prerequisite check (Story 2.10)`, `## Per-fork vs shared devbox mode (Story 2.11)`, or `## Opt-in SSH (Story 2.12)` sections** — append a NEW sibling H2 only (SC-17).
  - [ ] Update `## cc-devbox upstream provenance § Known upstream bugs fixed` at `README.md:921`: `Broken curl :3000 healthcheck → Story 2.13 (dnsmasq + sshd liveness).` → `Broken curl :3000 healthcheck → fixed in Story 2.13 (dnsmasq + sshd liveness). LANDED iter-<this>.` Past-tense refresh matching SC-15 idiom.
  - [ ] **`AGENTS.md`** — append new H3 `### Healthcheck (Story 2.13)` AFTER the existing `### Opt-in SSH (Story 2.12)` H3 under § Devbox iteration environment. Content:
    - (a) One-line what: "Compose healthcheck probes dnsmasq liveness (always) + sshd liveness (iff `KEEL_DEVBOX_SSH=true`); replaces upstream's broken `curl :3000`."
    - (b) One-line why agents care: if a Ralph subagent sees `State.Health.Status: unhealthy` on the devbox, the diagnostic points at a dnsmasq or sshd failure — queue `pnpm devbox:logs keel-devbox` + inspect `/var/log/dnsmasq.log` / `/var/log/sshd.log` as a fix task.
    - (c) Probe-domain pointer: `api.github.com` is the canonical whitelist-membership probe; if future stories remove `github.txt` from the default whitelist fragments, the probe domain must update in lockstep at three sites (compose healthcheck.test + invariant doc + README § Healthcheck).
    - (d) `INV-devbox-healthcheck` citation for the machine-enforced contract.
    - (e) Cross-references: § Egress policy (dnsmasq; Story 2.3) for dnsmasq substrate; § Opt-in SSH (Story 2.12) for sshd substrate; § Host-side CLI (Story 2.6) for `pnpm devbox:status` consumer.
  - [ ] **DO NOT modify existing `### Host-side CLI (Story 2.6)`, `### Ralph loop (Story 2.7)`, `### Claude Code authentication (Story 2.8)`, `### gh CLI authentication (Story 2.9)`, `### Prerequisite check (Story 2.10)`, `### Per-fork vs shared devbox mode (Story 2.11)`, or `### Opt-in SSH (Story 2.12)` sections** — append a NEW sibling H3 only (SC-17).
  - [ ] **`.envrc.example` comment touch (SC-15 — only if applicable):** no new `KEEL_DEVBOX_*` knob introduced by Story 2.13 (timing parameters are substrate-authoritative; forks amend via source-level PR per FR44 AMEND). SKIP `.envrc.example` edit unless future fork-parameterisation of the timing knobs is scoped in — defer that parameterisation to Story 2.17 close-out polish if operator demand surfaces.

- [ ] **Task 5: Absorb Story 2.12 iter-279 DEFER D-1 — pre-create `/var/log/sshd.log` in Dockerfile** (optional cosmetic absorption; DOES NOT extend AC surface)
  - [ ] **Why in-scope:** Story 2.12 iter-279 CR deferred `D-1: sshd.log first-boot diagnostic gap` to Story 2.17 close-out. Story 2.13 RE-TOUCHES the healthcheck + logs region (README § Healthcheck references `/var/log/sshd.log` for operator diagnostics; invariant doc references the file). Iter-278 LESSON (DEFER absorption discipline): "a PATCH that re-touches a region with queued cosmetic DEFERs should ABSORB those DEFERs into the patch". Story 2.13 TOUCHES the sshd-log-diagnostic surface; absorb D-1.
  - [ ] **Edit.** Add one line to `packages/devbox/Dockerfile` AFTER the existing dnsmasq.log pre-create at `:317` (`RUN install -m 0644 -o root -g root /dev/null /var/log/dnsmasq.log`):
    ```
    RUN install -m 0644 -o root -g root /dev/null /var/log/sshd.log
    ```
    Rationale parallels the dnsmasq.log rationale at `Dockerfile:293-317` (pre-create so `tail -F` never hits the "file doesn't exist" race; root:root 0644 because sshd runs as dev but stderr pipe redirects via `>> /var/log/sshd.log` in entrypoint.sh `:235` which runs as root prior to gosu-drop; mode 0644 so dev can read for `tail` diagnostics).
  - [ ] **Scope carve-out.** Story 2.12 iter-279 DEFERs D-2 (SSHD_PID subshell scoping), D-3 (zombie reaping under exec gosu dev handoff), D-4 (pre-gosu comment vestige at entrypoint.sh:175) are EXPLICITLY NOT in Story 2.13 scope — they remain Story 2.17 close-out items. D-2 is moot for Story 2.13 (healthcheck probes TCP port, not PID — robust to SSHD_PID scoping); D-3/D-4 are orthogonal to healthcheck design.
  - [ ] **Task 5 is optional.** If the dev agent judges Task 5 breaks commit atomicity (one-task-per-iteration discipline), DEFER Task 5 back to Story 2.17 and note the deferral in `_bmad-output/implementation-artifacts/deferred-work.md § Deferred from: dev-story of story-2.13 (<date>)`. Tasks 1-4 remain mandatory.

## Dev Notes

- **No new `.envrc` knob.** Story 2.13 introduces NO new `KEEL_DEVBOX_*` variable. Healthcheck timing values are substrate-authoritative — fork-local adjustment requires an AMEND PR against `docs/invariants/devbox-healthcheck.md § Timing parameters` per FR44 AMEND. Carry-forward advisory from iter-273 LESSON (compose env-propagation sites are normalisation chokepoints): if a future story parameterises timing via `KEEL_DEVBOX_HEALTHCHECK_*`, propagate via `environment:` block following Story 2.12 PATCH-2 posture.

- **Probe-domain stability.** `api.github.com` is load-bearing — in `packages/devbox/whitelist/github.txt` per Story 2.3 Task 2.2; required by Story 2.9 `gh auth login` / `gh push` flow; operator has strong interest in it resolving. Alternative candidates considered and rejected: (a) `api.anthropic.com` — stable per Story 2.8 but fork-specific-probability is lower (some forks may not use Claude Code), (b) synthetic probe via `hostname.bind CHAOS TXT` — dnsmasq-specific, but still logs to egress-queries.jsonl and conveys no whitelist-integration signal, (c) `nc -z 127.0.0.1 53` TCP probe — misses UDP-only dnsmasq configurations and doesn't exercise the DNS response path. `api.github.com` via `dig` is the correct trade-off.

- **Probe-frequency vs JSONL log volume.** 10s interval → 8640 queries/day added to `/workspace/${KEEL_DEVBOX_REPO_NAME}/logs/egress-queries.jsonl`. The log is FR37 Epic-4 security-evidence substrate (6-field stable schema per `docs/invariants/devbox-egress.md § JSONL query log schema`). Epic 4 consumers already filter by query pattern; a uniform healthcheck-origin query is easy to discount (`jq 'select(.query != "api.github.com")'`). Deliberately NOT optimising to `hostname.bind` CHAOS (which IS still logged) — the log volume is trivially filterable, and `api.github.com` matches the AC's "known-whitelisted domain" wording.

- **Docker healthcheck execution context** (iter-273 / Story 2.12 carry-forward applies). Healthcheck CMD runs via an internal `docker exec` equivalent against the running container, with the IMAGE's USER (dev per `Dockerfile:347`). The compose `user: "0:0"` directive scopes only the container's PID 1 (entrypoint); separate exec surfaces default to image USER. `dig` + `nc` don't require root, so dev is correct.

- **POSIX `/bin/sh` semantics.** Ubuntu 24.04 ships `/bin/sh` symlinked to `dash` (not bash). CMD-SHELL unwraps to `/bin/sh -c <cmd>`, so the probe MUST be POSIX-safe. This rules out: `[[ ... ]]` (bash-only); bash arrays; bash `{a,b}` brace expansion; `$()` command substitution with bashisms inside. The contract uses `[ "${KEEL_DEVBOX_SSH:-false}" != "true" ]` + `&&`/`||` + `{...;}` — all POSIX sh.

- **No `curl localhost:3000` anywhere.** AC 1 is a negative assertion. The dev agent MUST verify via `grep -n '3000' packages/devbox/docker-compose.yml` — the only 3000 occurrence should be line 167 (`KEEL_DEVBOX_PORT_WEB:-3000` publish port, unrelated to healthcheck). Do NOT inadvertently leave a commented-out `# curl localhost:3000` note — the invariant doc explicitly prohibits it (see § No curl :3000).

- **SSH-mode branch semantics under `KEEL_DEVBOX_SSH=false`.** POSIX `[ "${KEEL_DEVBOX_SSH:-false}" != "true" ]`: when the var is unset, `${VAR:-false}` expands to `false`; `[ "false" != "true" ]` exits 0; chain past `||` short-circuits the `nc -z` call. When set to `true`, the test exits non-zero; falls through to `nc -z 127.0.0.1 2222`. When set to `True` / `TRUE` / `TrUe`: the raw value would appear inside the container IF compose sourced `${KEEL_DEVBOX_SSH}` directly — but Story 2.12 PATCH-2 (iter-273) sources `${KEEL_DEVBOX_SSH_RESOLVED}` which is case-folded `true` or `false` only; variant case strings NEVER reach the container. This is the same mechanism entrypoint.sh:140 relies on for its opt-in gate; the healthcheck reuses the same canonical stream.

- **Mid-run service death → unhealthy transition timing.** `retries: 3` means 3 consecutive failures after `start_period` elapse to transition. Detection latency: 0-30s (post-crash time until the next probe) + 2 × `interval` (two MORE failures before the 3rd) = up to ~30s worst case (probe hits right at crash = 30s), ~10s best case. Under `start_period`, failures don't count toward `retries` — so a crash WITHIN start_period postpones transition until start_period elapses + 3 failures = ~60s cold-boot-crash detection. Acceptable for AC 4 ("the next healthcheck executes" leaves room for a few retry cycles).

- **Story 2.12 D-1 absorption rationale** (Task 5). Iter-278 LESSON (DEFER absorption): a PATCH re-touching a region with queued DEFERs should absorb them. Story 2.13 re-touches the sshd-log-adjacent surface (README + invariant doc both reference `/var/log/sshd.log`), so absorbing D-1 is the minimum-surprise posture. D-1 is NOT on the AC critical path; if commit-atomicity concerns outweigh, defer to 2.17 (Task 5's own guardrail).

- **start.sh and status.sh UNCHANGED.** Both scripts already consume `State.Health.Status` with graceful fallback (`start.sh:103` — `{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}`; `status.sh:54` — same idiom with `(no healthcheck configured)` fallback). Story 2.13 UNBLOCKS the healthy/unhealthy branch on both scripts; no shim edit required. Verify at impl time: `pnpm devbox:start` should log `container healthy` (from `start.sh:114-116` ELIF branch — lands on `.State.Health.Status == "healthy"`). `pnpm devbox:status` should print `healthcheck: healthy` (from `status.sh:58`).

- **Forecast band (iter-271 LESSON + Story 2.12 carry-forward).** Story 2.13 is SMALLER scope than 2.12 (compose healthcheck + doc + invariant vs opt-in-sshd runtime). Novel-runtime-behaviour surface is MODERATE — healthcheck CMD lifecycle × POSIX-sh × env-var branching; no new entrypoint code path, no new capability interaction. Pre-budget 1-3 first-class PATCH at CR (under iter-264 LESSON 0-3 first-class PATCH band for moderate-novelty stories), with 1-2 closure re-runs. Iter-279 LESSON (ZERO-PATCH CR closure as-expected after single-region PATCH) is forecast-relevant — Story 2.13's narrow diff surface likely closes in one CR round if pre-dev SM catches the structural issues.

- **Previous-story intelligence (Story 2.12 carry-forward).** iter-271 LESSON: static smokes (sha256, bash -n, sync-gate) are structurally unable to catch dynamic-runtime defects. Story 2.13's `dig` / `nc` probes are EXERCISED by docker healthcheck at container start — impl-time smoke is feasible inside the iteration env IF the dev agent can `docker run` the probe commands against a known-good dnsmasq. Even without Docker, `bash -n` + `docker compose config` + sha256 + sync-gate cover the static surface. Live probe semantics verification is operator-workstation-deferred (same posture as Story 2.12 AC 4 / AC 5).

- **ATDD decision forecast** (per § Story Lifecycle row `validated → atdd-scaffolded`). Story 2.13 likely TAKES the `/bmad-testarch-atdd` SKIP-WITH-GROUNDS route per Story 2.12 iter-267 precedent: (c) no test runner wired at substrate stage; (ii) healthcheck CMD exercises only when a real Docker daemon + container runtime execute the probe (AC 2, AC 3, AC 4); (iii) substrate verification via `docker compose config` + invariant content-hash sync-gate covers AC 1 + AC 5. Twenty-second-plus cumulative ATDD-skip precedent.

### Project Structure Notes

- **Files to create.** `docs/invariants/devbox-healthcheck.md` (new invariant doc; contentHash-tracked).
- **Files to edit.** `packages/devbox/docker-compose.yml` (add `healthcheck:` block at `:263` TODO; update Story-roadmap comment at `:24`); `packages/keel-invariants/src/invariants.manifest.ts` (add `INV-devbox-healthcheck` entry; contentHash after doc authored); `INVARIANTS.md` (new H3 + anchor bullet after Story 2.12 H3); `packages/devbox/README.md` (new § Healthcheck H2 + past-tense update at `:921`); `AGENTS.md` (new § Healthcheck H3 under § Devbox iteration environment); `packages/devbox/Dockerfile` (optional Task 5 — one-line sshd.log pre-create after `:317`).
- **Files NOT to edit.** `packages/devbox/entrypoint.sh` (healthcheck runs via docker, not entrypoint); `packages/devbox/scripts/start.sh` + `packages/devbox/scripts/status.sh` (both already consume `.State.Health.Status` with fallback; Story 2.13 unblocks the branch); `packages/devbox/sshd/sshd_config` (sshd hardening is Story 2.12 scope; healthcheck is TCP-only probe); `packages/devbox/docker-compose.ssh.yml` (single-site port-2222 publication is Story 2.12; healthcheck branches on env var, not on compose-file inclusion); `.envrc` / `.envrc.example` (no new knob).
- **Manifest entry count change.** 32 → 33 at Story 2.13 landing (manifest count was 32 at iter-279 per IP § Context). Confirm `pnpm keel-invariants:check` GREEN post-landing.
- **Dev agent MUST follow SC-17 sibling-append discipline** for README.md + AGENTS.md — prior story sections remain untouched; new content lands as NEW sibling H2/H3 only.

### References

- [Source: `_bmad-output/planning-artifacts/epics.md:1574-1600`] — Story 2.13 full AC block (Epic 2 Story 2.13; epic at `:1142-1170`).
- [Source: `_bmad-output/planning-artifacts/epics.md:1161`] — Epic 2 § NFRs "Healthcheck on dnsmasq + sshd liveness (upstream's broken `curl :3000` healthcheck is not retained)" anchor line.
- [Source: `_bmad-output/planning-artifacts/architecture.md:278-281`] — § Core Architectural Decisions § S5 egress mechanism (dnsmasq + nftables — Story 2.3 substrate the healthcheck consumes).
- [Source: `_bmad-output/planning-artifacts/prd.md`] — FR1 (devbox container), FR1a (JSONL observability consumer contract), NFR6 (fail-closed egress).
- [Source: `_bmad-output/implementation-artifacts/2-12-loopback-bound-port-publication-opt-in-keel-devbox-ssh-sshd.md § Tasks 2-4 + iter-273 PATCH-2`] — Story 2.12 PATCH-2 canonical pattern for `KEEL_DEVBOX_SSH` propagation via `KEEL_DEVBOX_SSH_RESOLVED`; Story 2.13 healthcheck reuses the same canonical stream.
- [Source: `_bmad-output/implementation-artifacts/2-12-… § iter-279 CR closure`] — Story 2.12 DEFER D-1 (sshd.log first-boot pre-create); Task 5 absorption rationale.
- [Source: `packages/devbox/docker-compose.yml:24`] — existing Story 2.13 forward-reference in Story-roadmap comment block.
- [Source: `packages/devbox/docker-compose.yml:263`] — existing TODO marker for healthcheck block.
- [Source: `packages/devbox/Dockerfile:61-64`] — `dnsutils` (dig) + `netcat-openbsd` (nc) apt packages baked at image build.
- [Source: `packages/devbox/Dockerfile:347`] — USER dev directive (healthcheck runs as dev).
- [Source: `packages/devbox/Dockerfile:317`] — dnsmasq.log pre-create pattern (Task 5 absorption template).
- [Source: `packages/devbox/scripts/start.sh:92-120`] — healthcheck poll consumer (Story 2.13 unblocks the healthy/unhealthy branch).
- [Source: `packages/devbox/scripts/status.sh:54-58`] — healthcheck status reporter (Story 2.13 unblocks the meaningful-value branch).
- [Source: `packages/devbox/whitelist/github.txt:8`] — `api.github.com` whitelist entry (probe domain).
- [Source: `docs/invariants/devbox-egress.md § JSONL query log schema`] — FR37 Epic-4 consumer contract (healthcheck probe volume note).
- [Source: `docs/invariants/devbox-ssh.md § SSH signal`] — `KEEL_DEVBOX_SSH_RESOLVED` canonical stream the healthcheck reads.
- [Source: `INVARIANTS.md:120-124`] — Story 2.12 `INV-devbox-ssh` H3 + anchor (insertion point predecessor for Story 2.13 H3).
- [Source: `packages/keel-invariants/src/invariants.manifest.ts:3-15`] — `InvariantSchema` five-field contract (no `name`; bare anchor strings; bare hex contentHash).
- [Source: `packages/keel-invariants/src/sync-gate.ts:24`] — anchor regex `/^-\s+\*\*\`(INV-[a-z0-9]+(?:-[a-z0-9]+)+)\`\*\*/gm` (lowercase-after-`INV-` mandatory).
- [Source: `packages/devbox/README.md:921`] — existing forward-reference line for past-tense update.
- [Source: `packages/devbox/README.md:847+`] — § Opt-in SSH (Story 2.12) H2 (insertion-point predecessor for Story 2.13 § Healthcheck H2).

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List
