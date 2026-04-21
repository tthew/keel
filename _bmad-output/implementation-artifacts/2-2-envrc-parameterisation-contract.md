# Story 2.2: `.envrc` parameterisation contract

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a fork operator,
I want a committed `packages/devbox/.envrc.example` that enumerates every tunable `KEEL_DEVBOX_*` knob with Apple-Silicon M4-Pro reference defaults, plus a committed `packages/devbox/.secrets.example` schema for the `act` local GH-Actions runner, plus `docker-compose.yml` wired to consume every tunable via `${KEEL_DEVBOX_*}` through `env_file: ../../.envrc`, plus `.gitignore` + a `packages/keel-invariants/` lint gate that fail-closes if anyone attempts to commit `.envrc` or `.secrets`,
So that I can retune the devbox for my hardware (memory, CPU, tmpfs sizes, ports, SSH/shared toggles) and manage my per-fork secrets by editing one gitignored file at repo root — never `docker-compose.yml`, never `Dockerfile` — and so that the committed example files serve as canonical schemas that survive PRD-free retunes per NFR8a [Source: planning-artifacts/prd.md:1079-1080 NFR8a; planning-artifacts/epics.md:1153 Epic-2 Implementation Note; planning-artifacts/architecture.md:275-295 § I5 §Devbox-Reference-Config; planning-artifacts/architecture.md:299-342 § I6 Dev container secrets & env var management].

## Acceptance Criteria

1. **Given** `packages/devbox/.envrc.example`,
   **When** I read the file,
   **Then** every `KEEL_DEVBOX_*` knob is listed with a default value and inline comment: `KEEL_DEVBOX_ARCH`, `KEEL_DEVBOX_CPUS`, `KEEL_DEVBOX_MEMORY_GB`, `KEEL_DEVBOX_SHM_GB`, `KEEL_DEVBOX_NOFILE`, `KEEL_DEVBOX_TMPFS_TMP_MB`, `KEEL_DEVBOX_TMPFS_VARTMP_MB`, `KEEL_DEVBOX_TMPFS_LOGS_MB`, port knobs (`KEEL_DEVBOX_PORT_WEB`, `KEEL_DEVBOX_PORT_API`, `KEEL_DEVBOX_PORT_STORYBOOK`, `KEEL_DEVBOX_PORT_VITE_HMR`), `KEEL_DEVBOX_SSH`, `KEEL_DEVBOX_SHARED`
   **And** the defaults match an Apple-Silicon M4-Pro baseline (documented in the file header).

   **Story 2.2 scope clarification — authoritative default values.** Architecture § I5 (architecture.md:275-295) is the normative source for defaults. Transcribe verbatim, preserving unit naming exactly — NOTE the unit mismatch between architecture.md (which uses `KEEL_DEVBOX_TMPFS_TMP_GB` / `KEEL_DEVBOX_TMPFS_VAR_TMP_GB`, underscore-separated + GB suffix) and epics.md AC1 / PRD § Devbox-Reference-Config (which use `KEEL_DEVBOX_TMPFS_TMP_MB` / `KEEL_DEVBOX_TMPFS_VARTMP_MB`, MB suffix). The AC text is authoritative for Story 2.2 — ship `_MB` suffixes (`KEEL_DEVBOX_TMPFS_TMP_MB=2048`, `KEEL_DEVBOX_TMPFS_VARTMP_MB=1024`) so compose's `tmpfs` sizing math is straightforward integer-MB (Docker compose accepts plain byte-count ints — `size: ${KEEL_DEVBOX_TMPFS_TMP_MB}m` renders `size: 2048m`). Record the architecture-vs-AC naming drift in the Questions section at the story tail so a future architecture amendment can align naming. **Reference-default values (from architecture.md:275-293; convert GB→MB where naming differs):**

   ```bash
   # Reference defaults (retunable per NFR8a; NOT PRD requirements)
   # Apple-Silicon M4-Pro baseline — forks on other hardware override per §I5a (architecture.md:295)
   KEEL_DEVBOX_ARCH=linux/arm64
   KEEL_DEVBOX_CPUS=8
   KEEL_DEVBOX_MEMORY_GB=12
   KEEL_DEVBOX_SHM_GB=2
   KEEL_DEVBOX_NOFILE=65536
   KEEL_DEVBOX_TMPFS_TMP_MB=2048
   KEEL_DEVBOX_TMPFS_VARTMP_MB=1024
   KEEL_DEVBOX_TMPFS_LOGS_MB=500
   KEEL_DEVBOX_PORT_WEB=3000
   KEEL_DEVBOX_PORT_API=3001
   KEEL_DEVBOX_PORT_STORYBOOK=6006
   KEEL_DEVBOX_PORT_VITE_HMR=24679
   KEEL_DEVBOX_SSH=false
   KEEL_DEVBOX_SHARED=false
   ```

   **Story 2.2 scope clarification — file-header block.** The file MUST open with a 10–15-line block-comment header naming (a) the I5 §Devbox-Reference-Config handoff, (b) the NFR8a retunability posture ("retunable per NFR8a without PRD amendment"), (c) the Apple-Silicon M4-Pro baseline provenance, (d) the copy-seed flow (`cp packages/devbox/.envrc.example .envrc && direnv allow` at repo root — so root `.envrc` then sources the devbox knobs + any additional non-devbox secrets per I3 at architecture.md:271), (e) a cross-reference to `packages/devbox/README.md § Retuning` (new subsection — see Task 6 below).

   **Story 2.2 scope clarification — inline-comment format.** Each knob's inline comment documents the unit, the M4-Pro-envelope rationale, and any cross-story consumer. Example: `KEEL_DEVBOX_CPUS=8  # vCPUs allocated to the devbox container (M4-Pro has 12P+E cores; 8 leaves headroom for host + Docker Desktop). Consumed by docker-compose.yml § cpus (service-level, non-swarm form per AC2).` Keep lines ≤120 chars (Prettier baseline per `packages/keel-invariants/prettier.config.keel-invariants.js`).

   **Story 2.2 scope clarification — existing Story 2.1 compose stubs.** `packages/devbox/docker-compose.yml:61-66` (post-iter-144) already contains TODO comments marking `cpus` / `mem_limit` / `shm_size` as Story 2.2 parameterisation targets. Task 2 of this story replaces those TODO blocks with the active parameterised forms.

2. **Given** `packages/devbox/docker-compose.yml`,
   **When** I inspect it,
   **Then** it uses `env_file: ../../.envrc` to consume the top-level `.envrc`
   **And** every tunable value in compose is referenced via `${KEEL_DEVBOX_*}`.

   **Story 2.2 scope clarification — `env_file:` wiring is already correct from Story 2.1.** Post-iter-144 `packages/devbox/docker-compose.yml:49-51` already carries:

   ```yaml
   env_file:
     - path: ../../.envrc
       required: false
   ```

   Keep this block intact — it is the I6 contract from architecture.md:299-304. Story 2.2 does NOT change `required: false → required: true`; the devbox must continue to parse before the operator creates `.envrc` (the file is gitignored per AC5, so fresh-clone forks will legitimately lack it until they `cp .envrc.example .envrc`). Enforcement of "`.envrc` present" is Story 2.6's `pnpm devbox:env:check` responsibility, not Story 2.2's.

   **Story 2.2 scope clarification — what gets parameterised (exhaustive list).** Every Story-2.2-owned tunable must swap from literal to `${KEEL_DEVBOX_*}` with a default-fallback. Complete mapping (ADD to the existing compose service block):

   | `.envrc.example` knob             | `docker-compose.yml` field (service-level, non-swarm)             | Default-fallback syntax                                                                                 |
   | --------------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
   | `KEEL_DEVBOX_ARCH`                | `platform:`                                                       | `platform: ${KEEL_DEVBOX_ARCH:-linux/arm64}`                                                            |
   | `KEEL_DEVBOX_CPUS`                | `cpus:` (service-level; NOT `deploy.resources.limits.cpus`)       | `cpus: "${KEEL_DEVBOX_CPUS:-8}"`                                                                        |
   | `KEEL_DEVBOX_MEMORY_GB`           | `mem_limit:` (service-level; NOT `deploy.resources.limits.memory`)| `mem_limit: ${KEEL_DEVBOX_MEMORY_GB:-12}g`                                                              |
   | `KEEL_DEVBOX_SHM_GB`              | `shm_size:` (service-level)                                       | `shm_size: ${KEEL_DEVBOX_SHM_GB:-2}g`                                                                   |
   | `KEEL_DEVBOX_NOFILE`              | `ulimits.nofile.soft:` + `.hard:` (service-level)                 | `nofile: { soft: ${KEEL_DEVBOX_NOFILE:-65536}, hard: ${KEEL_DEVBOX_NOFILE:-65536} }`                    |
   | `KEEL_DEVBOX_TMPFS_TMP_MB`        | (deferred to Story 2.5)                                          | Leave TODO comment — tmpfs mount lands with hardening in Story 2.5 per PRD § Tmpfs Policy line 548.     |
   | `KEEL_DEVBOX_TMPFS_VARTMP_MB`     | (deferred to Story 2.5)                                          | Leave TODO comment — same as above.                                                                     |
   | `KEEL_DEVBOX_TMPFS_LOGS_MB`       | (deferred to Story 2.5)                                          | Leave TODO comment — same as above.                                                                     |
   | `KEEL_DEVBOX_PORT_WEB`            | `ports:` (list entry)                                            | `"${KEEL_DEVBOX_PORT_WEB:-3000}:3000"` — bound to `127.0.0.1` per PRD line 551 (Story 2.12).            |
   | `KEEL_DEVBOX_PORT_API`            | `ports:` (list entry)                                            | `"${KEEL_DEVBOX_PORT_API:-3001}:3001"`                                                                  |
   | `KEEL_DEVBOX_PORT_STORYBOOK`      | `ports:` (list entry)                                            | `"${KEEL_DEVBOX_PORT_STORYBOOK:-6006}:6006"`                                                            |
   | `KEEL_DEVBOX_PORT_VITE_HMR`       | `ports:` (list entry)                                            | `"${KEEL_DEVBOX_PORT_VITE_HMR:-24679}:24679"`                                                           |
   | `KEEL_DEVBOX_SSH`                 | (deferred to Story 2.12)                                         | Leave TODO comment — opt-in SSH port `2222` gated by `KEEL_DEVBOX_SSH=true` is Story 2.12 scope.        |
   | `KEEL_DEVBOX_SHARED`              | (deferred to Story 2.11)                                         | Leave TODO comment — shared-workspace mount path switch is Story 2.11 scope.                            |
   | `KEEL_DEVBOX_WORKSPACE` (pre-existing from Story 2.1) | `volumes.[0].source:`                        | Existing `${KEEL_DEVBOX_WORKSPACE:-../..}` preserved — no edit needed.                                  |
   | `KEEL_DEVBOX_CONTAINER_NAME` (pre-existing from Story 2.1) | `container_name:`                        | Existing `${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}` preserved — no edit needed.                       |

   Story 2.2 lands rows marked with concrete compose-field destinations AND leaves TODO comments for the deferred rows (tmpfs / SSH / shared). Do NOT partially implement tmpfs / SSH / shared — they are strictly out of scope per `_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md:261-269` ("NFRs explicitly DEFERRED to later Epic 2 stories" posture).

   **Story 2.2 scope clarification — `127.0.0.1` loopback binding for ports.** PRD line 551 mandates loopback binding (`127.0.0.1:<port>:<port>` form) not `0.0.0.0:<port>:<port>` for host-only exposure. Story 2.12 is the authoritative owner of loopback-bound port publication (`2-12-loopback-bound-port-publication-opt-in-keel-devbox-ssh-sshd` per sprint-status). Story 2.2 SHOULD publish ports with the loopback form (`"127.0.0.1:${KEEL_DEVBOX_PORT_WEB:-3000}:3000"`) to avoid Story 2.12 having to re-edit the same four port lines. If the dev agent prefers to defer loopback-binding entirely to Story 2.12, leave ports as literals-with-TODO — but publishing in the loopback form is the lower-rework path.

   **Story 2.2 scope clarification — `deploy.resources` on non-swarm Compose.** Docker Compose ignores `deploy.resources.limits` outside swarm mode. Use the compose-file-level `cpus:` / `mem_limit:` / `shm_size:` form instead (per Story 2.1's original compose stub TODO list at docker-compose.yml:61-66). Canonical form for non-swarm:

   ```yaml
   cpus: "${KEEL_DEVBOX_CPUS:-8}"
   mem_limit: ${KEEL_DEVBOX_MEMORY_GB:-12}g
   shm_size: ${KEEL_DEVBOX_SHM_GB:-2}g
   ```

   Keep `deploy:` blocks out of the compose file — they add swarm-only noise. The AC2 mapping table above is already expressed in this canonical non-swarm shape (service-level `cpus:`, `mem_limit:`, `shm_size:` siblings of `image:`, `env_file:`, `volumes:`).

3. **Given** a fork operator who wants to retune memory,
   **When** they edit `.envrc` (not compose) and run `pnpm devbox:restart` (from Story 2.6),
   **Then** the new memory value takes effect
   **And** no PRD amendment is required (NFR8a).

   **Story 2.2 scope clarification — `pnpm devbox:restart` is Story 2.6's deliverable.** Same posture as Story 2.1's AC3/AC4 — verify via the equivalent raw compose command: `cp packages/devbox/.envrc.example .envrc && echo 'KEEL_DEVBOX_MEMORY_GB=16' >> .envrc && docker compose -f packages/devbox/docker-compose.yml config | grep 'memory: 16g'` must show the override taking effect (the `docker compose config` command renders the fully-expanded YAML, which is how compose parses `${KEEL_DEVBOX_*}` substitutions). AC3 is verified structurally via `compose config` without needing the daemon — the substitution is a pre-daemon YAML-time operation.

   **Story 2.2 scope clarification — retune-without-PRD-amendment verification.** Add an append to `packages/devbox/README.md § Retuning` (new subsection — see Task 6) documenting the retune flow: (1) `cp packages/devbox/.envrc.example .envrc` at repo root, (2) edit `.envrc`, (3) `pnpm devbox:restart` (Story 2.6) OR raw `docker compose -f packages/devbox/docker-compose.yml down && docker compose ... up -d`. The README § Retuning subsection is the human-operator flow; NFR8a retunability is the structural guarantee (Story 2.2 AC3) that compose reads `.envrc` dynamically at every invocation.

4. **Given** `packages/devbox/.secrets.example`,
   **When** I read it,
   **Then** it lists env vars that `act` (local GitHub-Actions runner) needs
   **And** it serves as the committed schema for the gitignored `.secrets` file.

   **Story 2.2 scope clarification — `.secrets.example` location.** AC4 text places the file at `packages/devbox/.secrets.example`. Architecture.md:802 places it at the repo root (`.secrets.example` under the project root). Ship the file at `packages/devbox/.secrets.example` per AC-literal reading. Record the architecture-vs-AC location drift in the Questions section at the story tail. (The `act` runner reads `.secrets` from its CWD; if a future story needs a repo-root `.secrets.example` for `act`-from-repo-root invocation, a symlink or copy under M9 CI hardening can resolve it without blocking Story 2.2.)

   **Story 2.2 scope clarification — contents of `.secrets.example`.** The `act` runner needs the same repo-level secrets that GitHub Actions uses (architecture.md:328). At M0.5 stage the full list is not yet consumed (no `.github/workflows/*.yml` exist yet — those land in Epic 13). Ship a MINIMAL scaffold listing the known-required keys per architecture.md:328 with scrubbed values + inline comments pointing at the eventual GH-secret consumers:

   ```bash
   # act local GitHub-Actions runner secrets.
   # Copy to .secrets (gitignored; see Story 2.2 AC5) and fill with your dev values.
   # Production / CI secret sources: GitHub repo → Settings → Secrets and variables → Actions.
   # One-line format: <KEY>=<value>  (no quotes, no leading whitespace per act's parser).

   # Paddle (billing — Epic 10)
   PADDLE_SANDBOX_API_KEY=
   PADDLE_PROD_API_KEY=

   # Resend (transactional email — Epic 8)
   RESEND_API_KEY=

   # OAuth (authentication — Epic 9)
   GOOGLE_OAUTH_CLIENT_SECRET=

   # Anthropic (Tier-2 deviation path; see PRD NFR28b honesty posture)
   ANTHROPIC_API_KEY=

   # Ephemeral Postgres DSN (pre-merge-slow CI tier — Epic 13)
   DATABASE_URL_EPHEMERAL=
   ```

   Six keys match architecture.md:328 verbatim. Add a file-header block-comment naming `act` + `.github/workflows/*.yml` future consumers + the pre-merge-slow / release-gated tier scoping (architecture.md:329). Forks extend with their own keys via a per-fork `.secrets.example` overlay IF Growth-tier adds that mechanism — not Story 2.2 scope.

5. **Given** `.envrc` is gitignored,
   **When** a PR tries to commit it,
   **Then** `.gitignore` rejects the addition
   **And** a lint rule in `keel-invariants` (from Story 1.2) flags any attempt to commit `.envrc` or `.secrets`.

   **Story 2.2 scope clarification — `.gitignore` entries.** Current `.gitignore` covers `.env*` + `!.env.example` (repo-root `.gitignore:36-37`) but does NOT cover `.envrc` or `.secrets` explicitly. Extend the `# Environment / secrets` block at `.gitignore:35-39` with EXPLICIT rules:

   ```gitignore
   # Environment / secrets
   .env*
   !.env.example
   .envrc
   .envrc.local
   !.envrc.example
   !packages/devbox/.envrc.example
   .secrets
   !.secrets.example
   !packages/devbox/.secrets.example
   *.pem
   *.key
   ```

   The positive-glob-plus-negation pattern is the canonical `.gitignore` shape — the bare file (e.g. `.envrc`) is ignored anywhere in the tree; the `!…example` rules explicitly un-ignore the committed schema copies. Including `packages/devbox/.envrc.example` + `packages/devbox/.secrets.example` as explicit un-ignored paths is belt-and-braces against any future `.gitignore` tightening that makes path-scoped rules override bare globs. Note `.envrc.local` is included as a direnv convention — a per-environment override file that direnv reads if present; not required by Story 2.2 but future-proof.

   **Story 2.2 scope clarification — `keel-invariants` lint rule design.** AC5 says "a lint rule in `keel-invariants` (from Story 1.2)". The canonical `keel-invariants` pattern (see `packages/keel-invariants/src/eslint-rules/no-verify-bypass.js` — Story 1.6's pattern) is one of two mechanisms:

   (i) **ESLint rule** — scans JS/TS/JSX/MJS/CJS files for literal filenames / patterns in source code. Fits "don't hardcode `.envrc` path inside substrate code" but does NOT catch `git add .envrc` attempts at commit time. Wrong tool for Story 2.2 AC5.

   (ii) **Pre-commit hook (prek)** — runs `packages/keel-invariants/src/check-no-committed-dotfiles.ts` → `dist/check-no-committed-dotfiles.js` as a `bin` entry (`keel-invariants:no-committed-dotfiles`) that scans staged files for committed `.envrc` / `.secrets` and exits non-zero if found. Matches existing `keel-invariants:tokens-schema` + `keel-invariants:tokens-contrast` pattern at `packages/keel-invariants/package.json:21-22`. Right tool for Story 2.2 AC5.

   Ship mechanism (ii). Concrete shape:

   - New file `packages/keel-invariants/src/check-no-committed-dotfiles.ts` — reads staged filenames via `git diff --cached --name-only --diff-filter=A` (added files only) or `process.argv.slice(2)` (the prek filenames arg passed via `pass_filenames: true`), matches each against a denylist regex (`/^(.+\/)?\.envrc$/`, `/^(.+\/)?\.envrc\.local$/`, `/^(.+\/)?\.secrets$/`), exits 1 with a pointer-error per match: `"Refusing to commit gitignored secret file: <path>. See Story 2.2 AC5 + packages/devbox/.envrc.example for the schema."` Do NOT match `*.example` suffixes (those are intentionally committed).
   - New `bin` entry in `packages/keel-invariants/package.json:21`: `"keel-invariants:no-committed-dotfiles": "./dist/check-no-committed-dotfiles.js"`.
   - New prek hook in `.pre-commit-config.yaml` (before `commitlint`, after `format-check`):

     ```yaml
     - id: no-committed-dotfiles
       name: Refuse committed .envrc / .secrets (@keel/keel-invariants; Story 2.2 AC5)
       entry: pnpm keel-invariants:no-committed-dotfiles
       language: system
       pass_filenames: true
       files: '(^|/)\.(envrc|envrc\.local|secrets)$'
     ```

     Use `pass_filenames: true` (not `false`) so prek passes the staged filenames as argv — more performant than re-invoking `git` and matches the `check-added-large-files` prek idiom. The `files:` regex matches the existing keel-invariants hook pattern (`.pre-commit-config.yaml:31,37` — `tokens-schema` / `tokens-contrast` both scope invocation with `files:` so the hook only runs when a matching file is staged). The regex intentionally EXCLUDES `.example` suffixes via anchor absence of `.example` after `$` end-anchor — `(^|/)\.envrc$` matches `packages/devbox/.envrc` and bare `.envrc` but NOT `packages/devbox/.envrc.example`.

   - Register the rule under a stable invariant ID: `INV-gitignored-secret-commit-deny`. Add an entry to `packages/keel-invariants/src/invariants.manifest.ts` (after the last existing entry) with `sourcePath` pointing at `packages/keel-invariants/src/check-no-committed-dotfiles.ts`, `description` naming the story + rule + covered-filename-set, `contentHash` computed via `sha256sum` of the TS source (regenerate the hash after the file is in its final form), `anchors: ['INV-gitignored-secret-commit-deny']`. Run `pnpm -C packages/keel-invariants build && node packages/keel-invariants/dist/check.js` to verify the sync-gate accepts the new entry.
   - Add an `INVARIANTS.md` anchor line under the existing rules — format matches the current file's convention: ID is backtick-wrapped inside the bold markers (e.g. `INVARIANTS.md:22` ships `- **`INV-tsconfig-base`** — strict TS + project-reference contract extended by every workspace member. Source: packages/keel-invariants/tsconfig.base.json.`). Shape for Story 2.2's anchor: `` - **`INV-gitignored-secret-commit-deny`** — pre-commit hook refuses `.envrc` / `.envrc.local` / `.secrets` file additions. Source: `docs/invariants/gitignored-secret-commit-deny.md`. `` Add a new `### Gitignored-secret commit-deny (Story 2.2)` section heading above the anchor line, matching the per-story `### …` grouping convention established by every other anchor block (see `INVARIANTS.md:20-94`). The anchor's ID substring (`INV-gitignored-secret-commit-deny`) must byte-match the `anchors` field in the manifest entry or the sync-gate fails per FR43.
   - Add `docs/invariants/gitignored-secret-commit-deny.md` with front-matter metadata + `## INV-gitignored-secret-commit-deny` body section (matches AI-7 iter-135's pattern for `INV-devbox-dind-available`) — see Task 4 subtask list below.

   **Story 2.2 scope clarification — pre-commit hook budget.** Prek config caps total hook time at ~10s (`.pre-commit-config.yaml:3`). The new hook must complete well under 1s (it reads argv + pattern-matches — no filesystem traversal, no network). Benchmark on a warm cache: invoke `pnpm keel-invariants:no-committed-dotfiles packages/devbox/.envrc` (should exit 0 — extension is `.envrc` but path has `.example` → wait that's not `.example`. Correct test: `pnpm keel-invariants:no-committed-dotfiles packages/devbox/.envrc.example` → exit 0; `pnpm keel-invariants:no-committed-dotfiles packages/devbox/.envrc` → exit 1 with pointer). If the hook exceeds 200ms on a cold start, the implementation is off-shape (most likely doing unnecessary `git` invocations when argv is already provided).

## Tasks / Subtasks

- [ ] **Task 1: Author `packages/devbox/.envrc.example`** (AC: 1)
  - [ ] Create `packages/devbox/.envrc.example` with a 10–15-line block-comment header per AC1 scope-clarification (I5 handoff, NFR8a retunability, M4-Pro provenance, copy-seed flow, cross-reference to README § Retuning).
  - [ ] Add every `KEEL_DEVBOX_*` knob from the AC1 reference-default table verbatim with `_MB` suffix for tmpfs rows (`KEEL_DEVBOX_TMPFS_TMP_MB=2048`, `KEEL_DEVBOX_TMPFS_VARTMP_MB=1024`, `KEEL_DEVBOX_TMPFS_LOGS_MB=500`). Inline comment on each line documents unit + M4-Pro rationale + cross-story consumer per AC1 scope-clarification ("inline-comment format").
  - [ ] Group knobs by scope using `# --- group label ---` section dividers: `# --- Platform/architecture ---` (ARCH), `# --- Compute limits ---` (CPUS, MEMORY_GB, SHM_GB, NOFILE), `# --- Tmpfs sizes (Story 2.5 consumer) ---` (TMPFS_TMP_MB, TMPFS_VARTMP_MB, TMPFS_LOGS_MB), `# --- Ports (127.0.0.1 loopback-bound per Story 2.12) ---` (PORT_WEB, PORT_API, PORT_STORYBOOK, PORT_VITE_HMR), `# --- Toggles ---` (SSH, SHARED). Grouping improves scanability for operators retuning the file.
  - [ ] Verify no trailing whitespace + trailing newline present (Prettier baseline). Run `pnpm exec prettier --check packages/devbox/.envrc.example` — Prettier may not recognise `.envrc.example` as a known extension; if not, add a `.prettierignore` entry exempting the file OR format by hand.

- [ ] **Task 2: Parameterise `packages/devbox/docker-compose.yml`** (AC: 2)
  - [ ] Replace the existing TODO-commented literal stubs at `packages/devbox/docker-compose.yml:61-66` with the active parameterised forms per AC2 scope-clarification ("what gets parameterised" mapping table). Use the non-swarm form (`cpus:`, `mem_limit:`, `shm_size:` at the service level) — NOT `deploy.resources.limits.*`.
  - [ ] Add `platform: ${KEEL_DEVBOX_ARCH:-linux/arm64}` at the top of the `devbox` service block (sibling of `container_name:` / `image:`). This instructs BuildKit to bake + run for the declared arch; forks on x86 operators override via `.envrc`.
  - [ ] Add `ulimits:` block with `nofile.soft` + `nofile.hard` — per the AC2 table mapping. Hard + soft set to the same value simplifies operator-mental-model; most operators never need to raise the hard cap above the soft cap.
  - [ ] Add `ports:` block with the 4 port mappings in `127.0.0.1:<host>:<container>` loopback-bound form per AC2 scope-clarification. Example line: `"127.0.0.1:${KEEL_DEVBOX_PORT_WEB:-3000}:3000"`. Quote each entry.
  - [ ] PRESERVE the existing Story 2.1 contract surfaces: `env_file: [path: ../../.envrc, required: false]` block, `container_name: ${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}` line, `volumes: [{type: bind, source: ${KEEL_DEVBOX_WORKSPACE:-../..}, target: /workspace}]` block, `working_dir: /workspace`, `restart: 'no'`, `tty: true`, `stdin_open: true`. Do NOT touch these — they are Story 2.1 scope.
  - [ ] Replace each pre-existing Story 2.1 TODO comment (`# TODO(Story 2.2): parameterise the following knobs via `.envrc`.`) with a closed-out marker: `# Story 2.2: parameterised below.` or delete the TODO line — keeping it visible after landing the parameterisation creates dead-code-smell. Replace Story 2.5 / 2.8 / 2.9 / 2.11 / 2.13 TODOs with themselves (they are still accurate — those stories remain open).
  - [ ] Verify structural parse: `docker compose -f packages/devbox/docker-compose.yml config` exits 0 on the parameterised file WITHOUT `.envrc` present (`required: false` must keep compose tolerant). Verify default-fallback substitution: `docker compose -f packages/devbox/docker-compose.yml config | grep -E 'mem_limit|cpus|shm_size|nofile|3000|3001|6006|24679'` must show every default value substituted (e.g. `mem_limit: 12g`, `cpus: '8'`, `shm_size: 2g`). Verify override substitution: `KEEL_DEVBOX_MEMORY_GB=16 docker compose -f packages/devbox/docker-compose.yml config | grep 'mem_limit: 16g'` must match.

- [ ] **Task 3: Author `packages/devbox/.secrets.example`** (AC: 4)

  `.secrets.example` is the COMMITTED schema; each fork must `cp packages/devbox/.secrets.example .secrets` (gitignored per Task 5) and populate with per-fork values before invoking `act`. The example file ships with empty values + inline Epic-consumer pointers so fork operators know which secrets unlock which downstream feature. Document this copy-seed flow in the `.secrets.example` header AND in `packages/devbox/README.md § Retuning § Secrets` (Task 6).

  - [ ] Create `packages/devbox/.secrets.example` with the 6-key scaffold per AC4 scope-clarification. Keys (verbatim, alphabetised within their category, scrubbed values): `PADDLE_SANDBOX_API_KEY=`, `PADDLE_PROD_API_KEY=`, `RESEND_API_KEY=`, `GOOGLE_OAUTH_CLIENT_SECRET=`, `ANTHROPIC_API_KEY=`, `DATABASE_URL_EPHEMERAL=`.
  - [ ] Add a block-comment header naming (a) `act` as the primary consumer, (b) architecture.md:328-330 as the source-of-truth for the key list, (c) the GitHub → Settings → Secrets and variables production source, (d) the pre-merge-slow / nightly / release-gated CI tier scoping per architecture.md:329. Inline comment each key with its consuming Epic (Epic 8 / 9 / 10 / 13 / etc.).
  - [ ] Match the `.envrc.example` style: group by section (`# --- Billing ---`, `# --- Email ---`, `# --- OAuth ---`, `# --- Anthropic ---`, `# --- Database ---`). Keep lines ≤120 chars. Trailing newline.

- [ ] **Task 4: Implement the `keel-invariants` lint rule** (AC: 5)
  - [ ] Create `packages/keel-invariants/src/check-no-committed-dotfiles.ts` per AC5 scope-clarification ("keel-invariants lint rule design — mechanism (ii)"). Entry point:

    ```ts
    #!/usr/bin/env node
    const denylist: Array<{ pattern: RegExp; name: string }> = [
      { pattern: /^(.+\/)?\.envrc$/, name: '.envrc' },
      { pattern: /^(.+\/)?\.envrc\.local$/, name: '.envrc.local' },
      { pattern: /^(.+\/)?\.secrets$/, name: '.secrets' },
    ];
    const stagedFiles = process.argv.slice(2);
    const violations = stagedFiles.flatMap((file) => {
      for (const { pattern, name } of denylist) {
        if (pattern.test(file)) return [{ file, matched: name }];
      }
      return [];
    });
    if (violations.length > 0) {
      for (const { file, matched } of violations) {
        process.stderr.write(
          `Refusing to commit gitignored secret file: ${file} (matches ${matched}).\n` +
            `  See Story 2.2 AC5 + packages/devbox/.envrc.example / packages/devbox/.secrets.example for the committed schema.\n`,
        );
      }
      process.exit(1);
    }
    process.exit(0);
    ```

    Hard-deny `*.example` suffix exclusion is already handled by the regex anchoring — `/^(.+\/)?\.envrc$/` does not match `packages/devbox/.envrc.example` because of the `$` end-anchor. Add a brief docstring + a `// See INV-gitignored-secret-commit-deny` tag for sync-gate traceability. No dependencies beyond Node built-ins (avoid adding `zod` — this check is leaf, not reused).

  - [ ] Add `bin` entry to `packages/keel-invariants/package.json`: `"keel-invariants:no-committed-dotfiles": "./dist/check-no-committed-dotfiles.js"`. Keep alphabetical order in the `bin` block if the maintainer prefers (existing order is insertion-order; match that).
  - [ ] Verify `tsc -b` compiles the new file to `dist/check-no-committed-dotfiles.js` with executable bit (shebang auto-executes under Node; the `bin` entry handles OS-level execution).
  - [ ] Add prek hook to `.pre-commit-config.yaml` per AC5 scope-clarification. Place it BETWEEN `format-check` and `tokens-schema` (logical adjacency — secret-file guard runs before the token validators). Use `pass_filenames: true` so prek passes staged filenames as argv.
  - [ ] Register `INV-gitignored-secret-commit-deny` in `packages/keel-invariants/src/invariants.manifest.ts` — append a new entry at the tail (after the last existing entry `INV-devbox-dind-available` at `invariants.manifest.ts:248-255`) with `sourcePath` pointing at the INVARIANT DOC (not the TS impl), matching the AI-7 precedent verified at `invariants.manifest.ts:252` (`sourcePath: 'docs/invariants/devbox-dind.md'`):

    ```ts
    {
      id: 'INV-gitignored-secret-commit-deny',
      description:
        'Pre-commit hook refuses additions of .envrc, .envrc.local, and .secrets at any path. ' +
        'Committed schemas (.envrc.example, .secrets.example) are exempt via anchored regex end-match. ' +
        'Implementation: packages/keel-invariants/src/check-no-committed-dotfiles.ts; ' +
        'wiring: .pre-commit-config.yaml → pnpm keel-invariants:no-committed-dotfiles.',
      sourcePath: 'docs/invariants/gitignored-secret-commit-deny.md',
      contentHash: '<REGENERATE — sha256sum of the final docs/invariants/gitignored-secret-commit-deny.md>',
      anchors: ['INV-gitignored-secret-commit-deny'],
    },
    ```

  - [ ] Compute `sha256sum docs/invariants/gitignored-secret-commit-deny.md` AFTER the doc's final content is in place (Task 4's `docs/invariants/gitignored-secret-commit-deny.md` authoring step below); paste the 64-hex-char digest into the `contentHash` field. Hash the DOC, not the TS source — the manifest `sourcePath` field drives which file the sync-gate hashes. Rebuild: `pnpm -C packages/keel-invariants build`. Run sync-gate: `node packages/keel-invariants/dist/check.js` exits 0. If drift is reported, re-read the manifest entry — the hash must byte-match the on-disk doc after any final edits.
  - [ ] Add the anchor to `INVARIANTS.md` at the repo root — a one-line entry under the existing invariant anchors matching the Story 1.7 convention. The anchor text must byte-match the `anchors: ['INV-gitignored-secret-commit-deny']` field in the manifest entry (sync-gate drift-detects anchor mismatch per FR43 + Story 1.9).
  - [ ] Create `docs/invariants/gitignored-secret-commit-deny.md` with YAML front-matter (matches AI-7 iter-135's shape for `INV-devbox-dind-available`):

    ```markdown
    ---
    id: INV-gitignored-secret-commit-deny
    status: active
    normative-reference: _bmad-output/planning-artifacts/epics.md § Epic 2 Story 2.2 AC5
    machine-enforced-via: packages/keel-invariants/src/check-no-committed-dotfiles.ts + .pre-commit-config.yaml
    ---

    ## INV-gitignored-secret-commit-deny

    [4-sentence paragraph: what the invariant guarantees; what happens on violation; the allow-list (committed .example schemas); the sync-gate self-verifiability criterion.]

    ## Intent
    [Why: .envrc/.secrets hold per-fork secrets; accidental commit leaks; schema copies live committed.]

    ## Mechanism
    [How: prek hook; pass_filenames: true; regex denylist anchored with $ end-match; exits 1 with pointer on match.]

    ## Verification
    [How to test: stage a .envrc file; attempt commit; hook fails with pointer. Stage .envrc.example; attempt commit; succeeds.]
    ```

    Compute `sha256sum docs/invariants/gitignored-secret-commit-deny.md` AFTER authoring the doc, and paste the digest into the manifest entry's `contentHash` field (the entry created in the previous substep with `sourcePath: 'docs/invariants/gitignored-secret-commit-deny.md'`). Doc-first `sourcePath` matches the AI-7 precedent at `invariants.manifest.ts:252`.
  - [ ] Smoke-test end-to-end: (a) stage a fake `.envrc` at repo root (`echo 'SECRET=abc' > .envrc && git add -f .envrc`); (b) run `pnpm exec prek run no-committed-dotfiles --all-files` — hook exits 1 with the pointer error; (c) `git restore --staged .envrc && rm .envrc`; (d) re-run hook — exits 0. Verify `.envrc.example` / `.secrets.example` additions do NOT trigger: `git add packages/devbox/.envrc.example && pnpm exec prek run no-committed-dotfiles --all-files` exits 0.

- [ ] **Task 5: Extend `.gitignore` coverage** (AC: 5)
  - [ ] Edit `.gitignore` at the repo root per AC5 scope-clarification. Replace the existing `# Environment / secrets` block (`.gitignore:35-39`) with the expanded block listing `.env*`, `!.env.example`, `.envrc`, `.envrc.local`, `!.envrc.example`, `!packages/devbox/.envrc.example`, `.secrets`, `!.secrets.example`, `!packages/devbox/.secrets.example`, `*.pem`, `*.key`.
  - [ ] Verify `.gitignore` rules via `git check-ignore -v`. **Exit codes drive the semantic, not stdout content.** Expected behaviour:
    - `git check-ignore -v packages/devbox/.envrc.example` → exit 1, NO output (file is NOT ignored — no rule prevents tracking; this is the desired outcome for committed schema files).
    - `git check-ignore -v packages/devbox/.envrc` → exit 0, prints the matching `.envrc` rule (file IS ignored).
    - Repeat for `.secrets` / `.secrets.example` counterparts: `.secrets.example` → exit 1 no output; `.secrets` → exit 0 prints matching rule.
    - If the `!<path>` negation rules are malformed, `check-ignore -v` on `.envrc.example` may print a matching `!` rule AND exit 0 — treat that as a regression; the correct state is exit 1.
  - [ ] Verify no regression to existing rules: `git status` after the edit still matches the pre-edit baseline — no newly-tracked files accidentally appear.

- [ ] **Task 6: Extend `packages/devbox/README.md` with § Retuning** (AC: 1, 3)
  - [ ] Add a new `## Retuning` section to `packages/devbox/README.md` (between existing `## NFR2 cold-/warm-start budget` and `## cc-devbox upstream provenance` — positional choice keeps operator-facing content grouped by frequency of interaction).
  - [ ] Section body documents the retune flow per AC3 scope-clarification: (1) `cp packages/devbox/.envrc.example .envrc` at repo root, (2) `direnv allow` (if using direnv) OR `source .envrc` manually, (3) edit `.envrc` to override values, (4) `pnpm devbox:restart` (Story 2.6 — until then use raw `docker compose -f packages/devbox/docker-compose.yml down && docker compose ... up -d`).
  - [ ] Link to `packages/devbox/.envrc.example` with a "see file header for I5 context" callout. Link to I5 §Devbox-Reference-Config anchor in architecture.md (`_bmad-output/planning-artifacts/architecture.md:275`). Link to PRD NFR8a retunability posture (`_bmad-output/planning-artifacts/prd.md:1079-1080`).
  - [ ] Add a `### Secrets` subsection under § Retuning (NOT a top-level `##` heading — secrets are a sub-case of retuning from the operator's mental model). Document the `.secrets` / `.secrets.example` copy-seed flow for `act` local runner, linking to architecture.md:328-330.
  - [ ] Add an entry to the "What this story does NOT deliver" list (Story 2.1 README Task 6 convention) striking through Story 2.2 — one-liner closed-out marker.

- [ ] **Task 7: Structural verification + forbidden-pattern sweep** (AC: 1, 2, 4, 5)
  - [ ] Run the pre-commit hook on a clean workspace: `pnpm exec prek run --all-files`. All hooks including the new `no-committed-dotfiles` must exit 0.
  - [ ] Run full sync-gate: `pnpm -C packages/keel-invariants build && node packages/keel-invariants/dist/check.js` exits 0 (no manifest drift).
  - [ ] Run `docker compose -f packages/devbox/docker-compose.yml config` — exits 0, every default `${KEEL_DEVBOX_*:-<default>}` resolves to its default. Confirm `mem_limit: 12g`, `cpus: '8'`, `shm_size: 2g`, `platform: linux/arm64`, `ulimits.nofile.soft: 65536`, and 4 port mappings with `127.0.0.1` loopback prefix are all present in the rendered YAML.
  - [ ] Run `docker compose -f packages/devbox/docker-compose.yml config` with an override: `KEEL_DEVBOX_MEMORY_GB=16 KEEL_DEVBOX_CPUS=4 docker compose -f packages/devbox/docker-compose.yml config | grep -E 'mem_limit|cpus:'` — must show `mem_limit: 16g` + `cpus: '4'`.
  - [ ] Verify `.envrc.example` enumerates every knob referenced in compose: `grep -oE 'KEEL_DEVBOX_[A-Z_]+' packages/devbox/docker-compose.yml | sort -u > /tmp/compose-knobs.txt; grep -oE 'KEEL_DEVBOX_[A-Z_]+' packages/devbox/.envrc.example | sort -u > /tmp/envrc-knobs.txt; diff /tmp/compose-knobs.txt /tmp/envrc-knobs.txt` — every compose-referenced knob must appear in `.envrc.example`. The reverse direction (knobs in `.envrc.example` but NOT yet referenced in compose) is expected — tmpfs / SSH / shared knobs land in Stories 2.5 / 2.11 / 2.12. Record the asymmetry in Dev Notes.
  - [ ] Smoke-test the lint rule's negative case: `echo 'SECRET=abc' > /tmp/fake.envrc; pnpm keel-invariants:no-committed-dotfiles /tmp/fake.envrc; echo $?` must print `1`. Positive case: `pnpm keel-invariants:no-committed-dotfiles packages/devbox/.envrc.example; echo $?` must print `0`.
  - [ ] Verify no runtime-install regressions: `grep -E 'npm install|pip install|curl[^|]*\|[[:space:]]*sh|wget[^|]*\|[[:space:]]*sh' packages/devbox/entrypoint.sh` must return exit 1 (preserves Story 2.1 Task 7.1).

- [ ] **Task 8: Update `_bmad-output/implementation-artifacts/sprint-status.yaml`** (post-dev hygiene; Ralph-automated)
  - [ ] `/bmad-create-story` (current iteration) transitioned `2-2-envrc-parameterisation-contract: backlog → ready-for-dev` + `last_updated` field. Confirm at dev-story start that sprint-status still shows `ready-for-dev`; if a preceding iteration has already bumped past, do NOT reset.
  - [ ] `/bmad-dev-story` transitions `ready-for-dev → in-progress` at its Step 4 per the skill's contract. No manual edit needed.
  - [ ] `done` lands only after trace + SM-review + CR gates per PROMPT_build.md § Story Lifecycle Decision Matrix — do NOT mark `done` in this task.

## Dev Notes

### Architecture decisions consumed by Story 2.2

- **I5 §Devbox-Reference-Config (architecture-owned retunable defaults)** — `packages/devbox/.envrc.example` holds the numeric reference defaults calibrated to Apple-Silicon M4-Pro baseline; NFR8a pins these as retunable without PRD amendment [Source: planning-artifacts/architecture.md:275-295; planning-artifacts/prd.md:1079-1080 NFR8a].
- **I6 Dev container secrets & env var management (simplest-workable posture)** — Single dotfile → devbox; `packages/devbox/docker-compose.yml` uses plain `env_file: ../../.envrc` — no allow-list codegen, no `env-passthrough.ts`. Whatever's in `.envrc` flows to the devbox. Maintenance surface: one file. [Source: planning-artifacts/architecture.md:299-342].
- **I3 Environment configuration** — `.envrc` (gitignored) at repo root; `.envrc.example` committed. Loads per-fork: Postgres URL, Paddle API key, Resend API key, Google OAuth secret, `ANTHROPIC_API_KEY` (Tier-2 deviation path only), devbox resource knobs. Never committed: `.env`, `.envrc` (local). [Source: planning-artifacts/architecture.md:271].
- **Story 2.2 anchors the `packages/devbox/` scope of `.envrc.example`** — architecture has TWO `.envrc.example` files: (a) repo-root `.envrc.example` (I3/I6 global secrets — Postgres/Paddle/Resend/OAuth/ANTHROPIC_API_KEY — lands in Epic 8/9/10 when those integrations arrive) and (b) `packages/devbox/.envrc.example` (I5 devbox knobs — Story 2.2 scope). Do NOT land the root `.envrc.example` in this story — it is out of scope. [Source: planning-artifacts/architecture.md:801-802 repo-root tree vs 978-979 packages/devbox tree].

### NFRs in scope for Story 2.2

- **NFR8a** — Numeric devbox defaults (tmpfs sizes, shm, CPU/memory caps, nofile) are architecture-owned reference config, not PRD requirements. Retunable via `.envrc.example` without PRD amendment [Source: planning-artifacts/prd.md:1079-1080 NFR8a]. AC3 verifies this structurally.
- **NFR8** — Tmpfs `noexec,nosuid` policy — Story 2.2 provides the `.envrc` knobs (`KEEL_DEVBOX_TMPFS_*_MB`); Story 2.5 wires them into the tmpfs mount stanzas. Story 2.2 MUST NOT partially implement the tmpfs mount itself — that is Story 2.5 scope.

### NFRs explicitly DEFERRED to later Epic 2 stories

- **NFR7 (non-root + capabilities + no-new-privileges)** — Story 2.5.
- **NFR10 (named volume for Claude + gh tokens)** — Stories 2.5 + 2.8 + 2.9.
- **FR4 shared-workspace-mount flip under `KEEL_DEVBOX_SHARED=true`** — Story 2.11. Story 2.2 lands the knob in `.envrc.example` only; the compose-level wiring is Story 2.11's contract.
- **Loopback-bound port publication + SSH opt-in** — Story 2.12. Story 2.2 publishes ports in the `127.0.0.1:<host>:<container>` form to reduce Story 2.12's edit surface (see AC2 scope-clarification "loopback-bound binding").
- **`pnpm devbox:*` lifecycle CLI surface (including `pnpm devbox:restart` / `pnpm devbox:env:check`)** — Story 2.6. Story 2.2 verifies AC3 via the equivalent raw `docker compose` commands.

Story 2.2's validation bar is AC1-AC5 literally. The remaining items above are out of scope; Story 2.2 MUST NOT partially implement them in ways that drift from the dedicated story's scope.

### Source-layer provenance

- `packages/devbox/.envrc.example` mirrors the architecture.md:275-295 §I5 block verbatim (with the `_MB` naming adjustment per AC1 scope-clarification); the file IS the §I5 handoff target.
- `packages/devbox/.secrets.example` key list is architecture.md:328 verbatim (`PADDLE_SANDBOX_API_KEY`, `PADDLE_PROD_API_KEY`, `RESEND_API_KEY`, `GOOGLE_OAUTH_CLIENT_SECRET`, `ANTHROPIC_API_KEY`, `DATABASE_URL_EPHEMERAL`).
- `packages/devbox/docker-compose.yml` parameterisation mapping follows architecture.md:977 + PRD M0.5(b) ("all resource limits parameterised via `.envrc`"; PRD line 169).
- `.gitignore` pattern for `.envrc` / `.secrets` matches direnv + act convention (no canonical substrate-owned document — direnv's upstream `.envrc` gitignore guidance is the lineage).
- `keel-invariants` lint rule pattern follows Story 1.6's `no-verify-bypass.js` (ESLint rule) + Story 1.4's prek hook pattern — Story 2.2's rule is a prek-only hook (no AST scan needed; file-path match suffices).

### Testing standards

- Story 2.2's deliverables are infrastructure artefacts (dotfile schemas, compose changes, gitignore, prek hook + TS script). Substrate-level Vitest unit tests do not apply to the dotfile schemas. Verification is via:
  - **Structural tests** — `docker compose config` exits 0, `.envrc.example` / `.secrets.example` pass prettier/manual review, `.gitignore` rules verified via `git check-ignore`.
  - **Functional tests** — compose substitution verified via `docker compose config` grep assertions (AC2 + AC3 verification path).
  - **Sync-gate tests** — `packages/keel-invariants/dist/check.js` accepts the new manifest entry.
  - **Lint-rule tests** — positive/negative smoke tests per Task 7.
- **ATDD red-phase posture.** The testable ACs are AC1-AC5. A TS unit test for the lint rule is natural (spec: `check-no-committed-dotfiles.test.ts` with stringified argv cases and exit-code assertions) and follows the Vitest pattern from Epic 1's token pipeline (`packages/keel-invariants/src/check-tokens-contrast.ts` style). If the `/bmad-testarch-atdd` step prefers shell-level smoke tests over Vitest for the lint rule (matching Story 2.1's posture), record the rationale. Compose-file parsing + `.gitignore` behaviour are infrastructure-smoke and SHOULD skip ATDD per FR14n — document the skip rationale in IP if elected.

### Project Structure Notes

- `packages/devbox/` (post-Story-2.1) contains `Dockerfile`, `docker-compose.yml`, `entrypoint.sh`, `scripts/`, `README.md`, `VERSIONS.md`, and the pre-existing TS scaffold (`package.json`, `src/`, `tsconfig.json`, `eslint.config.js`). Story 2.2 ADDS `.envrc.example` + `.secrets.example` as dotfile siblings — coexistence is fine; `tsconfig.json` / `eslint.config.js` already exclude dotfiles from TS compile / ESLint scope.
- `packages/keel-invariants/src/` (post-Epic-1) contains the ESLint rules plugin (`eslint-rules/`), the sync-gate (`sync-gate.ts` + `manifest-reader.ts` + `invariants.manifest.ts`), and token validators (`check-tokens-*.ts`). Story 2.2 ADDS `check-no-committed-dotfiles.ts` as a peer validator, wired as a `bin` entry + prek hook per the existing pattern at `packages/keel-invariants/package.json:21-23`.
- Repo root `.gitignore` is edited in place — one block edit, no new files at repo root. The root `.envrc.example` / `.secrets.example` files are NOT introduced in this story.
- `.pre-commit-config.yaml` gets one new hook definition (8 lines including blank separators). Place between `format-check` and `tokens-schema` for logical grouping.
- `INVARIANTS.md` gets one new line anchor. The file is append-oriented — add at the tail of the existing anchor list preserving alphabetical (or insertion) order per the file's house style.
- `docs/invariants/gitignored-secret-commit-deny.md` is a new single-page invariant doc — follows AI-7's `docs/invariants/devbox-dind.md` shape (front-matter + H2 anchor + § Intent / § Mechanism / § Verification).

### Git intelligence summary (iter-128..iter-144 Story 2.1 CR chain)

Recent iterations established these patterns that Story 2.2 should reuse:

- **Invariant doc + manifest entry pattern** — AI-7 iter-135 wrote `docs/invariants/devbox-dind.md` with `## INV-<id>` stable-heading + front-matter; Story 2.2's `INV-gitignored-secret-commit-deny` follows the same shape. The manifest `sourcePath` can reference either the doc OR the impl — AI-7 referenced the doc; match that precedent for Story 2.2 UNLESS the impl-first shape fits better (e.g. the TS source is more stable than the doc). Decide at implementation time; consistency with AI-7 is the default.
- **Sync-gate hash regen workflow** — AI-7 iter-135 established the `pnpm -C packages/keel-invariants build && node dist/check.js` workflow for re-verification after any invariant-doc edit. Story 2.2 Task 4 + Task 7 call this out explicitly.
- **Prek hook ordering** — existing order is `typecheck → lint → format-check → tokens-schema → tokens-contrast → commitlint`. Story 2.2 inserts `no-committed-dotfiles` between `format-check` and `tokens-schema`. Rationale: secret-file guard is a safety-invariant hook (like `no-verify-bypass` at source-level); grouping with the other `keel-invariants` hooks is natural.
- **`container_name:` + `env_file:` parameterisation precedent** — Story 2.1 iter-130 AI-2 established the `${KEEL_DEVBOX_CONTAINER_NAME:-keel-devbox}` + `env_file: [path: ../../.envrc, required: false]` pattern. Story 2.2 extends this to the remaining compose fields without re-touching those two.
- **Avoid `deploy:` stanza on non-swarm Compose** — Story 2.1's compose was structured at the service level (`container_name:`, `image:`, `volumes:` as siblings). Story 2.2 MUST NOT introduce a `deploy:` block — `cpus:`, `mem_limit:`, `shm_size:` at the service level work on non-swarm Compose and match Story 2.1's shape.
- **Line-pointer staleness** — CR findings in the iter-128 + iter-138 cycles cited line numbers that drifted as fixes landed. Task definitions in this story use "at or near line N" phrasing OR `grep`-friendly literals; prefer grep-based location of edits over hard-coded line numbers at implementation time.

### References

- Epic 2 Story 2.2 AC + Implementation Notes: `_bmad-output/planning-artifacts/epics.md:1200-1231`
- FR4: `_bmad-output/planning-artifacts/prd.md:930` (`.envrc` configuration of per-fork vs shared devbox mode)
- FR1 Epic 2 coverage: `_bmad-output/planning-artifacts/epics.md:485-491`
- NFR8a retunability: `_bmad-output/planning-artifacts/prd.md:1079-1080`
- NFR8 tmpfs policy: `_bmad-output/planning-artifacts/prd.md:548`
- §I3 environment configuration: `_bmad-output/planning-artifacts/architecture.md:271`
- §I5 §Devbox-Reference-Config + §I5a Docker-in-Docker substrate requirement: `_bmad-output/planning-artifacts/architecture.md:275-297`
- §I6 secrets & env var management (canonical I6 block): `_bmad-output/planning-artifacts/architecture.md:299-342`
- PRD § CLI-Tool Surface (port list + loopback binding): `_bmad-output/planning-artifacts/prd.md:547-551`
- Story 2.1 story file (patterns to reuse): `_bmad-output/implementation-artifacts/2-1-packages-devbox-absorb-from-cc-devbox-image-compose-substrate-tooling-access.md`
- `packages/devbox/docker-compose.yml` (starting state post-iter-144): lines 1-77
- `packages/keel-invariants/src/eslint-rules/no-verify-bypass.js` (ESLint rule precedent — Story 1.6)
- `packages/keel-invariants/src/invariants.manifest.ts` (manifest entry shape — Story 1.8)
- `packages/keel-invariants/src/sync-gate.ts` (drift-detector — Story 1.9)
- `.pre-commit-config.yaml` (prek hook config — Story 1.4)
- AI-7 closure at iter-135 (doc + manifest pattern): `_bmad-output/implementation-artifacts/2-1-*.md` § Review Findings AI-7

### Open questions (resolve during implementation; not blocking)

- **Tmpfs-naming drift** — `_bmad-output/planning-artifacts/architecture.md:284-286` uses `KEEL_DEVBOX_TMPFS_TMP_GB` / `KEEL_DEVBOX_TMPFS_VAR_TMP_GB` (GB suffix, underscore-separated); `_bmad-output/planning-artifacts/epics.md:1210` + AC1 uses `KEEL_DEVBOX_TMPFS_TMP_MB` / `KEEL_DEVBOX_TMPFS_VARTMP_MB` (MB suffix). Story 2.2 ships the AC-literal `_MB` form; a future architecture amendment should align naming. Not blocking — the naming decision is frozen for Story 2.2.
- **`.secrets.example` location** — `_bmad-output/planning-artifacts/architecture.md:802` places at repo root; `_bmad-output/planning-artifacts/epics.md:1223` AC4 places at `packages/devbox/.secrets.example`. Story 2.2 ships at `packages/devbox/.secrets.example` per AC-literal reading. A future story (likely Epic 13 CI harness) may add a root-level `.secrets.example` if `act` invocation from repo root requires it.
- **Manifest `sourcePath` for the new invariant — RESOLVED: doc-first.** `invariants.manifest.ts:252` ships `sourcePath: 'docs/invariants/devbox-dind.md'` for `INV-devbox-dind-available` (AI-7's invariant, closed at iter-135) — primary-documentary invariants whose machine-enforcement is a thin prek hook follow doc-first `sourcePath`. Story 2.2's `INV-gitignored-secret-commit-deny` matches this shape: the denylist regex is thin glue; the normative statement of what's refused + why lives in `docs/invariants/gitignored-secret-commit-deny.md`. Task 4 manifest template uses `sourcePath: 'docs/invariants/gitignored-secret-commit-deny.md'` + `sha256sum` of the doc for `contentHash`.

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### File List
