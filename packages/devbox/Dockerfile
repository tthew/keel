# ---------------------------------------------------------------------------
# Pin rationale: Ubuntu 24.04 LTS (Noble Numbat)
#
# - LTS support runs through April 2029 (5-year standard support window),
#   aligning with the Node 20 LTS maintenance horizon.
# - Matches the architecture.md § Technical Stack choice; upstream cc-devbox's
#   22.04 pin is intentionally superseded so M0.5 ships on the current LTS.
# - A later LTS bump (e.g. 26.04) will re-evaluate the full substrate
#   toolchain in one coordinated step rather than drifting per-tool.
#
# Do NOT add runtime `apt-get install`, `npm install -g`, `pip install`, or
# `curl … | sh` invocations to entrypoint.sh. Every tool baked below must stay
# at image-build time so `pnpm devbox:start` (Story 2.6) is offline-reliable
# and every version is Renovate-trackable (Story 1.15).
# ---------------------------------------------------------------------------
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH="/root/.local/bin:${PATH}"

# ---------------------------------------------------------------------------
# Task 2 — system packages in a single cached layer.
#
# Includes:
# - Build + fetch essentials: curl, git, ca-certificates, gnupg, build-essential,
#   unzip, jq, software-properties-common, lsb-release.
# - Postgres client (`psql`): forward-compatibility for Epic 6 Story 6.5
#   `pnpm rls:explain` without image rebuilds (story AC3 Dev Note).
# - Playwright browser OS-level libraries per
#   https://playwright.dev/docs/browsers#install-browsers — Ubuntu 24.04 deps
#   list kept inline so Renovate (Story 1.15 `.github/renovate.json` custom
#   managers) can track upgrades. `npx playwright install-deps` runs post-apt
#   to reconcile the list with the Playwright version at image-build time.
# ---------------------------------------------------------------------------
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      wget \
      gnupg \
      git \
      jq \
      unzip \
      zip \
      build-essential \
      pkg-config \
      software-properties-common \
      lsb-release \
      sudo \
      tini \
      procps \
      iproute2 \
      dnsutils \
      dnsmasq \
      nftables \
      netcat-openbsd \
      openssh-client \
      vim \
      less \
      locales \
      postgresql-client \
      libnss3 \
      libnspr4 \
      libatk1.0-0t64 \
      libatk-bridge2.0-0t64 \
      libcups2t64 \
      libdrm2 \
      libxkbcommon0 \
      libatspi2.0-0t64 \
      libx11-6 \
      libxcomposite1 \
      libxdamage1 \
      libxext6 \
      libxfixes3 \
      libxrandr2 \
      libgbm1 \
      libpango-1.0-0 \
      libcairo2 \
      libasound2t64 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Node.js 20 LTS via NodeSource (`setup_20.x`).
#
# Root package.json declares `"engines": { "node": ">=20 <21" }`; the
# NodeSource distribution ships the latest Node 20.x at image-build time.
# Exact installed version is recorded by the bake in VERSIONS.md on release
# (Renovate tracks the NodeSource repo URL via custom manager in Story 1.15).
# ---------------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && node --version \
 && npm --version

# pnpm pinned to the root package.json@packageManager value (10.29.2).
RUN npm install -g pnpm@10.29.2 \
 && pnpm --version

# @anthropic-ai/claude-code globally — version pinned to the iter-123 first-bake
# capture (`packages/devbox/VERSIONS.md § Bake log`). Renovate (Story 1.15)
# tracks the npm datasource and raises PRs to bump the pin. The version probe
# is scoped with a parenthesised `||` so a probe failure does not short-circuit
# the pinned install: either `claude --version` succeeds (normal path) or we
# emit a diagnostic to stderr while the RUN step stays exit-0 on `npm install`
# success. Dropping the trailing `|| true` that previously masked a failed
# install (CR fix AI-1, iter-129).
RUN npm install -g @anthropic-ai/claude-code@2.1.116 \
 && (claude --version || echo "claude version probe failed (install succeeded)" >&2)

# ---------------------------------------------------------------------------
# GitHub CLI (`gh`) via the official apt repository.
# Repo URL + signing key pattern per https://github.com/cli/cli — Renovate
# `apt` manager (Story 1.15) tracks the package version.
# ---------------------------------------------------------------------------
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends gh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && gh --version

# ---------------------------------------------------------------------------
# uv (Astral) — Python package/project manager, installed at BUILD time from
# the official install script. Do NOT replicate this in entrypoint.sh.
# ---------------------------------------------------------------------------
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
 && mv /root/.local/bin/uv /usr/local/bin/uv \
 && mv /root/.local/bin/uvx /usr/local/bin/uvx \
 && uv --version

# ---------------------------------------------------------------------------
# AWS CLI v2 — official installer (arch-aware).
# ---------------------------------------------------------------------------
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64)  awscli_arch=x86_64 ;; \
      aarch64) awscli_arch=aarch64 ;; \
      *) echo "Unsupported arch for AWS CLI: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${awscli_arch}.zip" -o /tmp/awscliv2.zip; \
    unzip -q /tmp/awscliv2.zip -d /tmp; \
    /tmp/aws/install; \
    rm -rf /tmp/aws /tmp/awscliv2.zip; \
    aws --version

# ---------------------------------------------------------------------------
# Supabase CLI via the official .deb (arch-aware). Renovate tracks the
# GitHub-release URL. The else-branch is FAIL-CLOSED (exit 1) rather than
# silent-skip — AC 2 enumerates `supabase-cli` unconditionally, so an image
# that ships without it would advertise tooling it doesn't have. Supabase's
# release matrix covers linux/amd64 + linux/arm64 (the only archs Ralph
# targets), so this gate is defensive fail-fast for exotic host archs (e.g.
# linux/arm/v7, linux/riscv64) where the bake would otherwise produce a
# misleading artefact. Pattern matches the git-delta block below (iter-128
# CR AI-6 consistency finding).
# ---------------------------------------------------------------------------
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    deb_url="$(curl -fsSL https://api.github.com/repos/supabase/cli/releases/latest \
                 | jq -r --arg a "$arch" '.assets[] | select(.name | test("linux_" + $a + "\\.deb$")) | .browser_download_url' \
                 | head -n1)"; \
    if [ -n "$deb_url" ] && [ "$deb_url" != "null" ]; then \
      curl -fsSL "$deb_url" -o /tmp/supabase.deb; \
      apt-get update; \
      apt-get install -y --no-install-recommends /tmp/supabase.deb; \
      apt-get clean; \
      rm -rf /var/lib/apt/lists/* /tmp/supabase.deb; \
      supabase --version; \
    else \
      echo "supabase-cli: no matching release asset for arch=$arch" >&2; \
      exit 1; \
    fi

# ---------------------------------------------------------------------------
# git-delta — Rust-based diff pager. Uses the GitHub release `.deb` for a
# reliably pinned version (apt's Ubuntu 24.04 package is typically behind).
# ---------------------------------------------------------------------------
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    deb_url="$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest \
                 | jq -r --arg a "$arch" '.assets[] | select(.name | test("_" + $a + "\\.deb$")) | .browser_download_url' \
                 | head -n1)"; \
    if [ -n "$deb_url" ] && [ "$deb_url" != "null" ]; then \
      curl -fsSL "$deb_url" -o /tmp/delta.deb; \
      apt-get update; \
      apt-get install -y --no-install-recommends /tmp/delta.deb; \
      apt-get clean; \
      rm -rf /var/lib/apt/lists/* /tmp/delta.deb; \
      delta --version; \
    else \
      echo "git-delta: no matching release asset for arch=$arch" >&2; \
      exit 1; \
    fi

# ---------------------------------------------------------------------------
# Playwright browser OS-level dependencies — runs against the latest
# Playwright release so the apt list above stays reconciled at bake time.
# `playwright install-deps` is expected to be a no-op if apt list is
# already complete; any additional packages it needs go into the apt list
# above on the next image bake.
# ---------------------------------------------------------------------------
RUN npx --yes playwright@latest install-deps \
 && rm -rf /root/.npm /root/.cache/ms-playwright

# ---------------------------------------------------------------------------
# Story 2.5 setcap — defense-in-depth portability fallback for the three
# substrate-operational capabilities. Under Docker ≥19.03 + `no-new-privileges:
# true` + `cap_add: [NET_ADMIN, NET_RAW, NET_BIND_SERVICE]` with USER dev, the
# load-bearing mechanism is Docker's ambient-capability propagation via
# prctl(PR_CAP_AMBIENT, PR_CAP_AMBIENT_RAISE, ...) on PID 1 — ambient caps
# survive exec() regardless of NNP (capabilities(7) kernel design). File
# caps via `setcap +eip` are masked by NNP on exec (`F(effective)` bit
# kernel-disabled), making this a harmless no-op on the primary path. It
# provides a working fallback for runtimes without Docker's automated
# ambient-cap handling (older Docker, some Podman-compat forks), which
# would ALSO need to disable `no-new-privileges` for the file-caps to
# activate — an explicit fork-time posture decision, not a substrate
# concern. Sudo is intentionally NOT setcap'd (AC 2 intent: no sudo under
# cap_drop + NNP; dev cannot sudo regardless per SC-13 Smoke B).
# ---------------------------------------------------------------------------
RUN setcap cap_net_admin,cap_net_raw,cap_net_bind_service+eip /usr/sbin/dnsmasq \
 && setcap cap_net_admin+eip /usr/sbin/nft

# ---------------------------------------------------------------------------
# Workspace mount + named-volume directories.
#
# - `/workspace` is the compose bind-mount target (docker-compose.yml);
#   entrypoint.sh does not create it, but the chown path must exist.
# - `/home/dev/.claude/` + `/home/dev/.config/gh/` are placeholders for the
#   named-volume mounts that Stories 2.8 / 2.9 populate via OAuth; Story 2.5
#   adds the non-root `dev` user. Story 2.1 pre-creates the directories so
#   entrypoint.sh's chown succeeds regardless of whether the volume is empty.
# ---------------------------------------------------------------------------
RUN mkdir -p /workspace /home/dev/.claude /home/dev/.config/gh \
 && chmod 0755 /workspace /home/dev /home/dev/.claude /home/dev/.config /home/dev/.config/gh

# ---------------------------------------------------------------------------
# Story 2.5 non-root `dev` user (AC 1, SC-1).
#
# UID/GID 1000 matches the Linux first-human-user convention and maps cleanly
# to most non-root host UIDs on macOS + Apple-Silicon Docker Desktop. Stable
# UID/GID is load-bearing for first-boot `keel_home_dev` named-volume
# auto-init: Docker populates an empty volume from the image layer preserving
# image ownership (docs.docker.com/storage/volumes/#populate-a-volume-using-a-
# container), so /home/dev must exist + be dev-owned at image-build time.
# Shell /bin/bash (not /bin/sh → dash on Ubuntu 24.04) for operator-shell
# consistency with entrypoint.sh's `#!/usr/bin/env bash` shebang. Do NOT raise
# UID — host-UID alignment minimises bind-mount chown friction under dropped
# CAP_CHOWN (SC-5 known-limitation).
# ---------------------------------------------------------------------------
RUN groupadd --gid 1000 dev \
 && useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home dev \
 && chown -R dev:dev /home/dev

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER dev

WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
