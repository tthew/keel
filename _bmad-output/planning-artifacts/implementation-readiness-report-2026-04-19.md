---
stepsCompleted:
  - step-01-document-discovery
  - step-02-prd-analysis
  - step-03-epic-coverage-validation
  - step-04-ux-alignment
  - step-05-epic-quality-review
  - step-06-final-assessment
filesIncluded:
  prd: _bmad-output/planning-artifacts/prd.md
  architecture: _bmad-output/planning-artifacts/architecture.md
  epics: _bmad-output/planning-artifacts/epics.md
  ux: _bmad-output/planning-artifacts/ux-design-specification.md
  supporting:
    - _bmad-output/planning-artifacts/prfaq-ralph-bmad.md
    - _bmad-output/planning-artifacts/prfaq-ralph-bmad-distillate.md
    - _bmad-output/planning-artifacts/research/technical-keel-ralph-bmad-research-2026-04-17.md
    - _bmad-output/planning-artifacts/prd-validation-report.md
    - _bmad-output/planning-artifacts/prd-validation-report-pre-pivot-2026-04-17.md
    - _bmad-output/planning-artifacts/prd-validation-report-pre-wizard-reversal-2026-04-17.md
    - _bmad-output/planning-artifacts/ux-design-directions.html
---

# Implementation Readiness Assessment Report

**Date:** 2026-04-19
**Project:** ralph-bmad

## Step 1 — Document Discovery

### Documents Selected for Assessment

| Type | Path | Size |
| --- | --- | --- |
| PRD | `_bmad-output/planning-artifacts/prd.md` | 172 KB |
| Architecture | `_bmad-output/planning-artifacts/architecture.md` | 120 KB |
| Epics & Stories | `_bmad-output/planning-artifacts/epics.md` | 419 KB |
| UX Design | `_bmad-output/planning-artifacts/ux-design-specification.md` | 75 KB |

### Supporting Artifacts (context)

- `prfaq-ralph-bmad.md`, `prfaq-ralph-bmad-distillate.md` — product framing
- `research/technical-keel-ralph-bmad-research-2026-04-17.md` — technical research
- `prd-validation-report*.md` — prior validation passes (historical context, not primary PRDs)
- `ux-design-directions.html` — visual directions companion

### Issues

- **Duplicates:** None. No sharded-vs-whole conflicts.
- **Missing:** None. All four required document types located.

## Step 2 — PRD Analysis

PRD read in full (1,061 lines, 172 KB). Classification: `developer_tool` / `cli_tool`, `multi-shape-hardwired` content shape (B2B + B2C hardwired at 1.0), `n-equals-one` persona, `research-plus-boilerplate` dual posture. All FRs and NFRs extracted below with numbering preserved.

### Functional Requirements

**Execution Environment Management (7)**

- **FR1** — Developer can manage devbox lifecycle (start, stop, shell, attach) via pnpm-exposed commands.
- **FR1a** — System can provide deterministic fail-closed domain whitelisting for container egress: atomic reload, IPv4 + IPv6 default-deny parity, repo-tracked whitelist source-of-truth, structured JSONL query-log output for FR37 security-evidence. Mechanism (dnsmasq-repaired vs nftables vs alternative) deferred to architecture.
- **FR2** — Developer can invoke Ralph (`pnpm ralph:build` / `pnpm ralph:plan`) with devbox auto-start.
- **FR3** — Developer can authenticate Claude Code and `gh` CLI once per devbox via OAuth surfaced to host; tokens persist in devbox volume.
- **FR4** — Developer can select per-fork vs shared devbox via `.envrc` (`KEEL_DEVBOX_SHARED`).
- **FR5** — System enforces prerequisites (Docker, Claude Code auth, `gh` auth) on first-run + every Ralph invocation; Ralph halts until satisfied.
- **FR6** — Developer can run substrate-internal tooling (tests, lints, RLS debugger) inside the devbox.

**Autonomous Agent Loop (25)**

- **FR7** — Agent executes multi-iteration loop against `.ralph/@plan.md` inside devbox, invoking `claude -p` with adaptive thinking + explicit `effort` (default `xhigh` build, `high` plan). Spine defined by FR14f–FR14k.
- **FR8** — Halt loop on configurable threshold of consecutive test-failures or security-verification failures.
- **FR9** — Halt on task-budget exhaustion using `task_budget` advisory (`task-budgets-2026-03-13`, ≥20K) where available and `max_tokens` as hard invisible ceiling.
- **FR9a** — Branch halt handling between `max_tokens` and `model_context_window_exceeded` stop reasons; persist which applied per iteration.
- **FR10** — Developer can detach from running loop and re-attach later.
- **FR11** — Developer can query Ralph state without attaching (`pnpm ralph:status`).
- **FR12** — Developer can halt cleanly (`pnpm ralph:stop`).
- **FR13** — Persist iteration logs in `stream-json` format with `thinking.display = "summarized"`.
- **FR14** — Require conventional-commit format for all commits regardless of authorship.
- **FR14a (Acceptance-Driven Backpressure)** — Plan file enumerates `Required tests:` per task, derived from story/spec AC by `bmad-create-story` + `bmad-agent-dev` planning skills. Build iteration cannot mark task done until every listed test passes on an unmodified checkout; list covers functional + integration + RLS + security uniformly (FR35-40).
- **FR14a1 (Authorship separation)** — Planning skill authors list; build skill is read-only consumer; mid-task additions logged as `expand:` with planning-skill signature.
- **FR14a2 (Manifest immutability)** — `Required tests:` append-only within task-open→done; stable `test-id` + assertion-body content hash; pre-merge-fast fails the build if removed/renamed/hash-shrinks without countersigned `expand:`.
- **FR14a3 (Assertion-shape floor for high-risk slices)** — High-risk slices (RLS, generator expand, webhook sig, auth/session, billing-state) MUST include ≥1 mutation-sampled assertion with ≥80% mutant-kill floor nightly; regression blocks release-gated promotion.
- **FR14b (Plan-staleness trigger)** — Detect staleness (plan-artefact age or same-task-no-progress across N iterations); auto-schedule plan-mode regen. Defaults: 5 no-progress iterations or 72 hrs.
- **FR14c (Subagent fan-out budget)** — Configurable Sonnet-class fan-out cap, default 250, ceiling 500. **At most 1 Sonnet subagent per build/test/lint command** is a non-toggle-able invariant.
- **FR14d (Per-iteration context meter)** — Emit context-utilisation metrics per iteration to `.ralph/logs/<id>/context-meter.json`. Clean-exit at >80%; flag at >60%.
- **FR14e (Non-Deterministic Backpressure scaffold)** — Opt-in LLM-as-judge fixture `lib/llm-review.ts` runs Opus-class subagent against diff with subjective AC; failure counts as test failure. Growth-tier default; 1.0 ships the pattern contract.
- **FR14f (Orient-phase contract)** — Eight-step orient sequence (epic/story, plan file, knowledge files, phase-gate, app source, budget, native tasks, PR/CI) before execute. Skipping any step fails self-check.
- **FR14g (Execute-phase contract)** — Exactly one task per iteration on orient → execute → commit → update IP → pre-push quality gate → pre-push CI gate → push → exit spine. Compound "AND" tasks rejected/decomposed. Each BMad workflow consumes one full iteration. `/bmad-dev-story` on stories ≥3 tasks rejected and decomposed.
- **FR14h (PR-lifecycle decision matrix)** — Schema-versioned six-row PR-state × Epic-state × CI-state matrix. Three anti-constraints: never EPIC_DONE while Draft; never Draft→Open until all impl tasks done; never address review feedback while Draft. Shipped in `packages/keel-templates/PROMPT_build.template.md`.
- **FR14i (Pre-push CI gate)** — Block `git push` while any PR check is in-progress/pending; queue "Monitor PR CI" at QUEUE top, commit IP locally, exit without pushing; CI failures produce triage entry at QUEUE top.
- **FR14j (Knowledge-file upkeep contract)** — Maintain `AGENTS.md`, `CLAUDE.md`, `RALPH.md` with pinned promotion rules; iterations producing non-obvious learnings update ≥1 file + commit.
- **FR14k (Crash-journal + plan-file + halt schemas)** — Native Claude Code task list = crash journal (max 3 active). `.ralph/@plan.md` pinned schema (NOW/QUEUE/BLOCKED/DONE/Context; fix tasks at QUEUE TOP as priority stack). `.ralph/halt` JSON schema `{reason: <closed enum>, epic, pr}`.
- **FR14l (Halt-on-same-test-fails threshold)** — Halt on N consecutive failures of *same* test (stable test-ID, counted across iterations within session). Configurable per-fork via `.ralph/config.toml` (`halt_on_same_test_fails`); default N=3; reviewed at M9.

**Tenant Isolation (4)**

- **FR15** — Enforce tenant isolation at DB layer via RLS on all tenant-scoped tables, parameterised over shape's tenancy template (team/user); templates emitted by generator; `org` is Growth-tier.
- **FR16** — `tenantGuard()` session-variable setter keyed on `app.current_tenant_id`; emitted from shape's tenancy template.
- **FR17** — Debug RLS policy decisions via `pnpm rls:explain`.
- **FR18** — CI check enforces new tenant-scoped tables ship with matching RLS policy.

**Platform Services (5)**

- **FR19** — Typed background jobs via pg-boss in the same Postgres DB.
- **FR20** — Transactional emails via Resend using baseline templates.
- **FR21** — Server-side feature flags in TanStack Start route loaders.
- **FR22** — Emit OTel traces for all request paths.
- **FR23** — Append-only audit log entries for security events.

**Internationalization & Localization (4)**

- **FR24** — i18n keys resolved to typed translations (no bare strings).
- **FR25** — Detect locale from `Accept-Language` with explicit user-preference override.
- **FR26** — Baseline English locale + documented path for additional locales.
- **FR27** — Lint/CI check preventing bare user-facing strings.

**Quality & Governance (7)**

- **FR28** — Pre-commit gates (typecheck, lint, format, conventional-commit) via prek.
- **FR29** — Pre-merge gates (unit + integration, RLS policy tests, import boundaries, dep audit).
- **FR30** — Release-gated CI tier (manual): `git clone` → shape-edit → signup → tenant → Paddle sandbox paid subscription → teardown; on both shapes; before release tag.
- **FR31** — Rolling release-please Release PR with conventional-commit-based versioning.
- **FR32** — Prevent quality-gate bypass via config; removal requires source-level fork.
- **FR33** — Record M4 checkpoint decisions as committed markdown in repo.
- **FR34** — Import boundaries enforced at compile time (ESLint `no-restricted-imports` + TS project refs).

**Security Verification & Evidence (6)**

- **FR35** — Per-iteration security verification (secret scan, dep audit, SAST, prompt-injection) on every Ralph diff before commit.
- **FR36** — Block commit on any finding above configured severity threshold.
- **FR37** — Persist security evidence to `.ralph/logs/<id>/security-evidence.json` every iteration.
- **FR38** — Halt loop on consecutive security-scan failures equivalent to test-failure backpressure.
- **FR39** — OWASP ASVS Level 1 baseline; Level 2+ Tier-2 deviation.
- **FR40** — Scan agent-context-loader files (`CLAUDE.md`, skill files, `.ralph/PROMPT_*.md`, `docs/**/*.md`) for prompt-injection patterns at pre-commit.

**Invariants (5)**

- **FR41** — Ship versioned invariants package `packages/keel-invariants/` consumed by lint/format/typecheck/commit/merge gates.
- **FR42** — Expose invariants via `INVARIANTS.md` referenced by `CLAUDE.md`.
- **FR43** — Pre-merge sync gate: reads `invariants.manifest.ts` (stable-ID + content-hash); fails on addition/removal/edit drift.
- **FR44** — Forks extend via extension configs building on substrate (e.g., `eslint.config.fork.js extends eslint.config.keel-invariants.js`).
- **FR45** — *(Growth-tier)* Fork-specific `INVARIANTS.fork.md` referenced alongside upstream `INVARIANTS.md`.

**Forkability & Upgradability (8)**

- **FR46** — Fork/rename/configure via one-line edit to `keel.config.ts` (shape, tenancy, projectIdentity, OTel endpoint) without modifying substrate internals.
- **FR47** — Bootstrap via `pnpm dlx create-keel-app <name>` — non-interactive; no wizard.
- **FR48** — Change shape (`b2b` ↔ `b2c`) via literal `keel.config.ts` edit + `pnpm generate`; typecheck rejects invalid values; generator emits matching RLS/billing preset; sync gate catches drift.
- **FR49** — *(Growth-tier)* Second implementations per axis ship with CI-tested migration guide; at 1.0 no migration guides.
- **FR50** — Major version cut documents tested model/tooling generation; breaking model upgrade triggers new major test-run.
- **FR51** — Wipe residual `_bmad-output/` + `.ralph/` on fork-scaffolding, seeding from `packages/keel-templates/`.
- **FR52** — Archive per-version planning to `docs/archive/keel-<version>-planning/` before each major tag cut.
- **FR53** — Distinguish substrate vs product commits via path-based CI rules (full pyramid including nightly shape × tenancy on substrate; pre-merge-fast+slow only on `apps/web/features/*`).

**Identity & Access (6)**

- **FR54** — End user signup via email+password or Google OAuth (better-auth).
- **FR55** — Email verification via Resend link.
- **FR56** — Create/join/leave/invite to teams (B2B) or manage individual profile (B2C).
- **FR57** — DB-backed sessions with revocation.
- **FR58** — Step-up auth for sensitive actions.
- **FR59** — Log out of all active sessions.

**Commerce (4)**

- **FR60** — Paddle subscription: B2B team-seats preset / B2C individual-subscription preset; hardwired in `packages/billing/paddle/`; selected via `keel.config.ts` shape.
- **FR61** — Paddle webhook processing (creation/cancellation/dunning/upgrade/downgrade) with sig verification and idempotency.
- **FR62** — Subscription-gated access to premium capabilities; usage-quota-gated deferred to API-first 1.2.
- **FR63** — *(Growth-tier)* Second billing provider via thin adapter + migration guide on real-product demand.

**End-User Localization (1)**

- **FR64** — End user can select preferred locale; persisted + honoured across sessions; English baseline always present.

**Configuration & Generator (4)**

- **FR65** — Typed `keel.config.ts` at repo root: `shape` (literal `"b2b" | "b2c"`), `tenancy` (literal `"team" | "user"`, shape-default, overridable), `projectIdentity`, `otelExporter`. Invalid values fail at typecheck. No `schemaVersion` at 1.0.
- **FR66** — `pnpm generate` reads `keel.config.ts` → emits shape RLS tenancy template to `packages/core/rls/*.generated.ts`, Paddle preset to `packages/billing/paddle/preset.generated.ts`, + `invariants.manifest.ts` entries for generated artefacts. Idempotent.
- **FR67** — Generator output satisfies pinned external contract: (a) pure, (b) deterministic, (c) idempotent, (d) order-independent, (e) canonical form exists, (f) stable rule identity. Internal algorithm (ordering lattice, merge precedence, canonicalisation) = architecture deliverable (§Generator-Normalization-Algorithm).
- **FR68** — Pre-merge-fast sync gate: edits to `shape`/`tenancy` without matching regen fail; edits to generated files without source-of-truth change fail.

**Total FRs: 74** (FR1, FR1a, FR2–FR9, FR9a, FR10–FR14, FR14a, FR14a1, FR14a2, FR14a3, FR14b–FR14l, FR15–FR68 with FR-numbers contiguous except the gap FR69-FR74 which were deleted in the wizard-reversal pivot — see editHistory 2026-04-17 entry).

### Non-Functional Requirements

**Performance (6)**

- **NFR1** — Decomposed CI pyramid wall-clock: pre-commit ≤10s, pre-merge-fast ≤3min (deterministic, no live net), pre-merge-slow ≤10min, nightly ≤60min (live-net quarantined here), release-gated (manual) bounded by live path. Non-toggle-able; any tier exceeding budget fails the build.
- **NFR2** — Devbox cold-start ≤5min on Apple-Silicon-class; warm-start ≤30s. Validated at M0.5.
- **NFR3** — RLS query overhead <15% of query wall-clock (PRD-placeholder band) on typical tenant-scoped reads. Pinned empirical value at architecture §RLS-Performance-Budget.
- **NFR4** — Ralph iteration startup ≤20s; task-budget enforced; token budgets tokenizer-aware + re-baselined per model version (Opus 4.7 emits ~35% more tokens/byte than 4.6).
- **NFR4a (Context utilisation smart zone)** — Iterations target 40–60% of advertised context (200K ≈ 176K usable Opus 4.7; 117K execution budget). Clean-exit at >80%; flag <30% for batching review. Metrics via FR14d.
- **NFR4b (Execution budget headroom)** — Reserve 25K push-buffer on top of task estimate within 117K budget; exit if <25K remaining. ≥60K "XL" tasks decomposed pre-start. Context-exhaustion signals trigger clean-exit regardless of advertised headroom.

**Security (15)**

- **NFR5** — All agent execution inside devbox; `--dangerously-skip-permissions` never on host. Non-toggle-able.
- **NFR6** — Container network egress default-deny; whitelist-limited. Fail-closed resolver (no public-DNS fallback); IPv4+IPv6 parity; atomic reload. Mechanism at architecture per FR1a.
- **NFR7** — Non-root container user; caps limited to NET_ADMIN+NET_RAW; `no-new-privileges`.
- **NFR8** — `/tmp`, `/var/tmp`, `/workspace/logs` tmpfs `noexec,nosuid`; sizes `.envrc`-parameterised; reference defaults in `packages/devbox/.envrc.example`.
- **NFR8a** — Devbox numeric defaults (tmpfs, shm, CPU/memory, nofile) = architecture-owned reference config, not PRD; retunable without PRD amendment.
- **NFR9** — Pre-commit gate rejects known secret patterns.
- **NFR10** — Claude + `gh` tokens persist only in devbox named volume; host `~/.claude/` + `~/.config/gh/` never bind-mounted.
- **NFR11** — Tenant isolation at DB layer (RLS), not app layer.
- **NFR12** — All sessions DB-backed with revocation; stateless-JWT = Tier-2 deviation only.
- **NFR13** — Audit log append-only; app code cannot delete/modify.
- **NFR14** — Dep audit (Dependabot/equivalent) on every PR; critical vulns block merge.
- **NFR15** — Every iteration produces structured security evidence persisted to `.ralph/logs/<id>/security-evidence.json` before commit.
- **NFR16** — Security failures = test failures for halt behaviour.
- **NFR17** — OWASP Top 10:2025 + ASVS Level 1 + OWASP Top 10 for Agentic Applications 2026; Level 2+ Tier-2 deviation.
- **NFR18** — Critical findings (hardcoded production secrets, CVSS ≥9, known RCE patterns) trigger immediate halt, no retry.

**Scalability (1)**

- **NFR19** — No artificial scalability ceiling in substrate code (no hardcoded rate limits, conn caps, throughput throttles). CI grep-gate on `packages/core/**`, `packages/jobs/**`, `packages/billing/**`. Horizontal-scaling via worker-process extraction = Tier-2 deviation.

**Accessibility (2)**

- **NFR20** — Baseline UI (signup, login, billing, locale selector, team mgmt) meets WCAG 2.1 AA (keyboard, colour contrast, screen reader).
- **NFR21** — i18n framework supports RTL at layout level (logical properties, directional CSS).

**Integration (4)**

- **NFR22** — Paddle webhook processing idempotent.
- **NFR23** — Paddle webhook signatures verified against Paddle public key; mis-signed rejected.
- **NFR24** — Failed external calls (Paddle, Resend) surface via pg-boss retry + exponential backoff + dead-letter queue.
- **NFR25** — Google OAuth enforces PKCE + state-parameter verification.

**Reliability (6)**

- **NFR26** — Iteration commits atomic — all-green or no-change. Partial-state commits rejected at pre-commit.
- **NFR27** — Gates fail closed — unreachable/misconfigured = reject. No silent-success.
- **NFR28** — Tier-specific flake budget: pre-merge-fast + pre-merge-slow deterministic (>0.1% / 30d triggers immediate CI-hardening); nightly tolerates ≤2% / 30d.
- **NFR28a (Worktree retention)** — Ralph worktree (`.claude/worktrees/…`, gitignored) never cleaned up on exit. Source-layer invariant in `packages/keel-templates/PROMPT_*.template.md`.
- **NFR28b (CI-budget empirical baseline)** — Tier budgets provisional until 2-week p95 baseline; first post-baseline PR pins budgets to `max(stated-target, ceil(p95 × 1.25))`.
- **NFR28c (Monthly CI-budget review)** — p95 reviewed monthly; 2 consecutive months p95 breach triggers mandatory amendment PR.

**Maintainability (4)**

- **NFR29** — Substrate steady-state 5–10 hrs/month; >15 hrs/month triggers scope-cut or archive.
- **NFR29a (Model-version-pinned prompt-set)** — Ralph prompt templates pinned per major Keel version; major may diverge and must record tested model generation + prompt delta in release notes.
- **NFR30** — Every major documents tested model generation + Claude Code CLI + BMad + Ralph versions; breaking model upgrade triggers new-major test-run.
- **NFR31** — Three-layer invariants stack kept in sync by pre-merge gate; drift fails build.

**Observability (3)**

- **NFR32** — Every request emits OTel traces correlated by request ID; sampling rate per-deploy config; exporter endpoint from `keel.config.ts → otelExporter`.
- **NFR33** — Ralph iterations emit structured stream-json logs to `.ralph/logs/` with per-iteration ID + timestamps + exit status + test results.
- **NFR33a (Ralph loop halt schema)** — `.ralph/halt` JSON schema `{reason: <closed enum>, epic, pr}`; closed enum at 1.0: `EPIC_DONE`, `AWAIT_MERGE`, `BUDGET_EXHAUSTED`, `CI_BLOCKED`, `SECURITY_CRITICAL`.

**Configuration & Generator UX (4)**

- **NFR34** — `pnpm dlx create-keel-app <name>` completes <2min wall-clock (excluding devbox cold-start). No prompts. No wizard.
- **NFR35** — Invalid shape values fail at typecheck, not silently at first test. Literal-union types rule out invalid combinations at compile time.
- **NFR36** — *(Reserved.)* Pre-wizard-reversal wizard-schema-versioning NFR deleted. No `schemaVersion` at 1.0.
- **NFR37** — `keel.config.ts` → generated-artefact pipeline idempotent — re-running `pnpm generate` on synchronised repo produces no diff. Verified by pre-merge-fast regen-and-diff test. Content-hashing each artefact per FR67 canonical form.

**Total NFRs: 45** (NFR1–NFR37 + letter-suffix variants NFR4a, NFR4b, NFR8a, NFR28a, NFR28b, NFR28c, NFR29a, NFR33a, with NFR36 Reserved).

### Additional Requirements (constraints, invariants, governance)

- **Four-layer quality gates** (pre-commit / pre-merge / pre-deploy / release) non-toggle-able at config layer; bypass = fork.
- **Devbox Implementation Contract** pins 11 substrate-level design decisions: base image Ubuntu 24.04 LTS + `.envrc`-parameterised arch/CPU/memory/shm, non-root `dev` user with NOPASSWD sudo (no public ssh password retained), attach UX (`docker exec/attach` default, opt-in sshd via `KEEL_DEVBOX_SSH=true` loopback-bound), toolchain baked at image-build (`node@20-lts`, `pnpm@<pinned>`, Claude Code CLI `<pinned>`, `gh`, `uv`, AWS CLI, Supabase CLI, `delta@0.17.0`, Playwright deps), named-Docker-volume auth persistence, per-fork vs shared workspace mount, tmpfs policy, network policy (fail-closed resolver, IPv4+IPv6 parity, atomic whitelist reload, repo-tracked whitelist state), healthcheck on dnsmasq + sshd-when-enabled liveness (not `curl :3000`), ports bound to `127.0.0.1`, lifecycle scripts under `packages/devbox/scripts/`.
- **Invariants stack (three layers + sync gate)** pinned: (1) machine-enforced `packages/keel-invariants/` — tsconfig-base, ESLint, Prettier, commitlint, prek hooks, import-boundary rules; (2) agent-readable `INVARIANTS.md` referenced by `CLAUDE.md`; (3) human narrative under `docs/invariants/*.md`. Manifest contract: `invariants.manifest.ts` exports typed record per rule (stable ID, title, enforcement layer, content hash over canonical output form per FR67(e)).
- **Decomposed CI pyramid** tier content specified: pre-commit (prek + ESLint-on-changed + commitlint + prompt-injection scan); pre-merge-fast (full typecheck + generator idempotency content-hash round-trip + RLS unit tests on synthetic schemas + webhook sig contract tests on recorded fixtures + invariants-manifest sync FR43); pre-merge-slow (RLS integration on ephemeral Postgres + generator e2e against both shapes + one smoke-per-shape e2e); nightly (full shape × tenancy 2×2 = 4 cells with Paddle hardwired per shape + live-net Paddle sandbox + Google OAuth; flake budget resets daily); release-gated manual (1.0-readiness: `git clone` → shape-edit → signup → tenant → paid Paddle sandbox → teardown on both shapes).
- **Hardwired stack at 1.0 (no adapter surface):** better-auth (DB-backed sessions, Google OAuth + email/password, step-up middleware, `requireRecentAuth`), Prisma + Postgres, TanStack Start + tRPC + RHF + Zod + Zustand + Tailwind, Paddle (B2B team-seats + B2C individual-subscription presets), pg-boss typed job registry, Resend (verify/invite/reset baseline templates), OpenTelemetry.
- **Monthly blank-starter-sprint absorption tripwire** with pre-registered acceptance criteria in `docs/absorption-tripwire/vertical-slice-acceptance.md` (vertical-slice definition, binary acceptance checklist, measurement rules, aggregation policy, sprint-log convention, amendment changelog). Named owner: Tthew. Amendments via PR + rationale changelog + 24-hour cooling-off.
- **Correlated-library risk policy** — TanStack Start + better-auth quarterly maintenance-signal check; thresholds (no release 6mo, unpatched security advisory >14 days, maintainer abandonment) trigger next-major-replacement with one-axis codemod migration.
- **Terminology contract** — Growth-tier migration (on-demand per-axis additions with CI-tested migration path) vs Tier-2 deviation path (exits outside substrate supported posture: ASVS L2+, stateless-JWT, signed attestation, horizontal scaling, raw `ANTHROPIC_API_KEY` pass-through).
- **Fork initialisation** — `pnpm dlx create-keel-app <name>` bootstrap (clone + strip + install, non-interactive) OR `git clone` of tagged release; shape selection is a one-line `keel.config.ts` edit; no wizard UI.
- **Three Keel modes** — Development with Keel (product code in `apps/web/features/*`), Keel development via fork (substrate code on own fork), Keel development proper (substrate changes upstreamed).
- **1.0 cut ritual** — move `_bmad-output/*` → `docs/archive/keel-1.0-planning/`; retire cc-devbox; empty `apps/web/features/*`; seed `packages/keel-templates/PROMPT_*.template.md`; tag `v1.0.0`.

### PRD Completeness Assessment

**Strengths:**

- Requirements are well-numbered, grouped by capability, and cross-referenced. FR14 series explicitly splits authorship (FR14a1), immutability (FR14a2), and mutation floor (FR14a3).
- Traceability chains are documented — e.g., FR14f–FR14k → J3 + Technical Success backpressure; FR14i → Technical Success decomposed CI pyramid; NFR4b → FR14d context meter.
- All FRs FR65–FR68 and FR-section headers have been rewritten to `[Actor] can [capability]` format where possible (fixing a prior measurability warning).
- NFRs carry empirical-baseline methodology (NFR28b/c) explicitly addressing the earlier measurability gap where fixed numbers were unfalsifiable.

**Areas the epic coverage check must verify:**

1. **Growth-tier / Reserved items** — FR45, FR49, FR63, FR14e (Non-Deterministic Backpressure scaffold), NFR36 (Reserved). Epics must not accidentally pull these into 1.0 scope; PRD-prescribed deferral must be honoured.
2. **Architecture handoffs** — FR1a (whitelist mechanism), FR67 (generator normalization algorithm internals), NFR3 (RLS perf budget), NFR8/NFR8a (devbox reference config). Epics should cite architecture stub/section rather than re-specifying internals.
3. **Cross-cutting invariants** — FR14a/a1/a2/a3 (backpressure), FR14f–l (loop contracts), FR28-32 (four-layer gates), FR43 (sync gate), FR67 (generator contract), NFR28a (worktree retention). These thread through multiple epics; coverage check must confirm no single epic "owns" them without the others wiring them in.
4. **Deferred validation-polish items (8-item list in § Risk Mitigation Strategy → Technical Risks)** — flake-budget enforcer owner, weekly money-path promotion, 2×2 → N×M cell policy, pre-merge-fast empirical-baseline confirmation, synthetic schemas definition, security-evidence schema parseability, prompt-injection scan tier, product #2 concreteness. Scheduled for re-run Party Mode with Murat+John after M9 empirical-evidence window; epics should not try to resolve these prematurely.

## Step 3 — Epic Coverage Validation

Epics doc (6,481 lines, 419 KB) declares 16 epics (Epic 1–14, 15a, 15b) across four BMad workflow phases and contains an explicit `## FR Coverage Map` table at line 477 that assigns every FR to exactly one primary-owning epic. The doc's frontmatter also enumerates `partyModeAmendments` (Rounds 1 + 2) and `prdClarificationsRaised` (four PRD-delta items).

### Coverage Matrix

Full table comparing PRD FRs against epic coverage. All ✓ Covered; zero ❌ Missing. PRD-deferred items flagged as `(Growth)` retain that status in the epic assignment.

| FR | PRD scope | Epic Coverage | Status |
| --- | --- | --- | --- |
| FR1 | Devbox lifecycle via pnpm | Epic 2 | ✓ Covered |
| FR1a | Fail-closed DNS whitelist | Epic 2 (mechanism pinned in Additional Reqs S5 — dnsmasq + nftables belt-and-braces) | ✓ Covered |
| FR2 | Ralph auto-starts devbox | Epic 2 | ✓ Covered |
| FR3 | Claude + gh OAuth in devbox volume | Epic 2 | ✓ Covered |
| FR4 | Per-fork vs shared devbox | Epic 2 | ✓ Covered |
| FR5 | Prerequisites enforcement | Epic 2 | ✓ Covered |
| FR6 | Substrate tooling inside devbox | Epic 2 | ✓ Covered |
| FR7 | Multi-iteration Ralph loop | Epic 3 | ✓ Covered |
| FR8 | Halt on consecutive test/security fails | Epic 3 | ✓ Covered |
| FR9 | Halt on task-budget exhaustion | Epic 3 | ✓ Covered |
| FR9a | Branch halt max_tokens vs context_window_exceeded | Epic 3 | ✓ Covered |
| FR10 | Detach/reattach Ralph | Epic 3 | ✓ Covered |
| FR11 | `pnpm ralph:status` | Epic 3 | ✓ Covered |
| FR12 | `pnpm ralph:stop` | Epic 3 | ✓ Covered |
| FR13 | stream-json iteration logs | Epic 3 | ✓ Covered |
| FR14 | Conventional-commit format | Epic 1 | ✓ Covered |
| FR14a | Required tests: list per task | Epic 3 | ✓ Covered |
| FR14a1 | Authorship separation | Epic 3 | ✓ Covered |
| FR14a2 | Manifest immutability | Epic 3 | ✓ Covered |
| FR14a3 | Assertion-shape floor for high-risk slices | Epic 3 | ✓ Covered *(contract at 1.0 as warn-mode; ≥80% enforcement deferred to 1.x after NFR28b empirical baseline — Party-Mode M1)* |
| FR14b | Plan-staleness trigger | Epic 3 | ✓ Covered |
| FR14c | Subagent fan-out budget | Epic 3 | ✓ Covered |
| FR14d | Per-iteration context meter | Epic 3 | ✓ Covered |
| FR14e | LLM-as-judge scaffold | Epic 3 | ✓ Covered *(Growth-tier default; 1.0 ships the pattern contract)* |
| FR14f | Orient-phase contract | Epic 3 | ✓ Covered |
| FR14g | Execute-phase contract | Epic 3 | ✓ Covered |
| FR14h | PR-lifecycle decision matrix + 3 anti-constraints | Epic 3 | ✓ Covered |
| FR14i | Pre-push CI gate | Epic 3 | ✓ Covered |
| FR14j | Knowledge-file upkeep | Epic 3 | ✓ Covered |
| FR14k | Crash-journal + plan-file + halt schemas | Epic 3 | ✓ Covered |
| FR14l | Halt-on-same-test-fails threshold | Epic 3 | ✓ Covered |
| FR15 | RLS parameterised over tenancy | Epic 6 | ✓ Covered |
| FR16 | `tenantGuard()` session-var setter | Epic 6 | ✓ Covered |
| FR17 | `pnpm rls:explain` | Epic 6 | ✓ Covered |
| FR18 | CI check new tables ship with RLS | Epic 6 | ✓ Covered |
| FR19 | Typed pg-boss jobs | Epic 8 | ✓ Covered |
| FR20 | Resend transactional emails | Epic 8 | ✓ Covered |
| FR21 | Server-side feature flags | Epic 11 | ✓ Covered |
| FR22 | OpenTelemetry traces | Epic 11 | ✓ Covered |
| FR23 | Append-only audit log | Epic 8 | ✓ Covered |
| FR24 | Typed i18n keys | Epic 11 | ✓ Covered |
| FR25 | Accept-Language detection | Epic 11 | ✓ Covered |
| FR26 | Baseline locales | Epic 11 | ✓ Covered |
| FR27 | Lint/CI prevents bare strings | Epic 11 | ✓ Covered |
| FR28 | Pre-commit quality gates | Epic 1 | ✓ Covered |
| FR29 | Pre-merge gates | Epic 13 | ✓ Covered |
| FR30 | Release-gated CI tier | Epic 13 | ✓ Covered |
| FR31 | Rolling release-please PR | Epic 1 | ✓ Covered |
| FR32 | Prevent gate bypass | Epic 1 | ✓ Covered |
| FR33 | M4 checkpoint markdown | Epic 14 | ✓ Covered |
| FR34 | Compile-time import boundaries | Epic 1 | ✓ Covered |
| FR35 | Per-iteration security verification | Epic 4 | ✓ Covered |
| FR36 | Block commit on finding above threshold | Epic 4 | ✓ Covered |
| FR37 | Persist security-evidence.json | Epic 4 | ✓ Covered |
| FR38 | Halt on consecutive security fails | Epic 4 | ✓ Covered |
| FR39 | OWASP ASVS L1 baseline | Epic 4 | ✓ Covered |
| FR40 | Prompt-injection scan on agent-context files | Epic 4 | ✓ Covered |
| FR41 | Versioned invariants package | Epic 1 | ✓ Covered |
| FR42 | INVARIANTS.md agent-readable layer | Epic 1 | ✓ Covered |
| FR43 | Sync gate via invariants.manifest.ts | Epic 1 | ✓ Covered |
| FR44 | Fork extension configs | Epic 1 | ✓ Covered |
| FR45 | Fork-specific INVARIANTS.fork.md | Epic 1 | ✓ Covered *(Growth-tier)* |
| FR46 | Fork with one-line keel.config.ts edit | Epic 5 | ✓ Covered |
| FR47 | `pnpm dlx create-keel-app` bootstrap | Epic 15a | ✓ Covered *(split out as early-landing Tthew test-fork tool per E15-split amendment)* |
| FR48 | Change shape via config edit + `pnpm generate` | Epic 5 | ✓ Covered |
| FR49 | Second-impl axes ship with migration guide | Epic 15b | ✓ Covered *(Growth-tier)* |
| FR50 | Major-version cut with tested model/tooling combo | Epic 15b | ✓ Covered |
| FR51 | Wipe residual state on fork-scaffolding | Epic 15a | ✓ Covered |
| FR52 | Archive per-version planning on major cut | Epic 15b | ✓ Covered |
| FR53 | Path-based CI gate routing | Epic 13 | ✓ Covered |
| FR54 | Signup via email+pw / Google OAuth | Epic 9 | ✓ Covered |
| FR55 | Email verification via Resend link | Epic 9 | ✓ Covered |
| FR56 | Team CRUD + invites (B2B) / profile (B2C) | Epic 12 | ✓ Covered |
| FR57 | DB-backed sessions with revocation | Epic 9 | ✓ Covered |
| FR58 | Require recent auth (step-up) | Epic 9 | ✓ Covered |
| FR59 | Log out of all sessions | Epic 9 | ✓ Covered |
| FR60 | Paddle subscribe with shape preset | Epic 10 | ✓ Covered |
| FR61 | Paddle webhook sig + idempotent | Epic 10 | ✓ Covered |
| FR62 | Subscription-gated access | Epic 10 | ✓ Covered |
| FR63 | Second billing provider adapter | Epic 10 | ✓ Covered *(Growth-tier)* |
| FR64 | End-user locale selection | Epic 11 | ✓ Covered |
| FR65 | Typed `keel.config.ts` schema | Epic 5 | ✓ Covered |
| FR66 | `pnpm generate` emits artefacts | Epic 5 | ✓ Covered |
| FR67 | 6-property generator contract | Epic 5 (internal algorithm pinned G1–G6 Additional Reqs) | ✓ Covered |
| FR68 | Pre-merge-fast sync gate | Epic 5 | ✓ Covered |

### Missing Requirements

**Zero missing FRs.** Every PRD FR maps to an epic per the explicit Coverage Map. PRD-deferred items (`Growth-tier`, `Reserved`, `contract-only`, `warn-mode`) are preserved as deferrals in the epic assignments — they are covered *in scope* rather than over-scoped into 1.0 implementation.

### Epics → PRD Delta (epics introduce new requirements not in PRD)

The epics frontmatter `prdClarificationsRaised` field declares four items the epics author knew would require PRD updates:

1. **FR14a3 contract at 1.0 + enforcement threshold deferral to 1.x** — PRD states hard ≥80% mutant-kill floor; epics ship warn-mode at 1.0, full threshold post-NFR28b empirical baseline. **PRD clarification recommended.**
2. **Password-reset flow explicit coverage under FR54+FR55** — The PRD's baseline email templates list includes `reset`, but no FR explicitly names "password reset" as a capability. Epic 9 adds explicit coverage. **PRD clarification recommended** (minor — already implicit via FR20/FR54/FR55).
3. **Absorption-tripwire skip-trigger (two consecutive skipped sprints = absorption by default)** — PRD's absorption tripwire only fires on *delta-within-20%-for-two-consecutive-months*; Party Mode Round 1 V4 adds a *skipped-for-two-consecutive-months* trigger. **PRD clarification recommended** (absorption-tripwire § Business Success).
4. **UX spec clarification — matrix scope at 1.0 = 18 combos (not 48)** — UX spec specifies 48 snapshot combos (360×768×1280 × LTR+RTL × light+dark). Party Mode V2 reduces to 18 at 1.0 (RTL kept; dark visual verification deferred to 1.1; dark tokens + class-toggle still ship at 1.0). **UX spec clarification recommended.**

Additionally, the frontmatter lists **new requirements introduced by the epics that are NOT in the PRD**:

5. **NEW FR14m** — Ralph three-layer safe-set self-modification policy (L1 install-boundary-snapshot; L2 auto-merge on bootstrap-validation pass; L3 lint-guarded Ralph-editable); `.ralph-safe-set.yaml` manifest + pre-commit hook + Ralph-orient-reads-manifest self-awareness. Introduced in Party Mode Round 2 to solve compiler-bootstrap problem (Ralph builds Ralph).
6. **NEW NFR (unnumbered in frontmatter, implied NFR34 series)** — Ralph harness runs from install-boundary-snapshot (`packages/ralph` installed non-editable via `uv tool install --from packages/ralph ralph-harness==pin`); source edits in `packages/ralph` do not affect current iteration; stage-upgrade requires bootstrap-validation pass before stage-N+1 runs.
7. **NEW NFR5a** — Claude Code hooks + committed `.claude/settings.json` deny rules form secret-access barrier inside devbox (complement to NFR5 devbox isolation); barrier non-toggle-able at config layer; ONLY in-session defense when Ralph runs with `--dangerously-skip-permissions`; forks can extend denylist but not weaken substrate.
8. **NEW NFR5b** — Hook + settings bypass-resistance: in-session hook self-protects by denying Edit/Write to `.claude/settings*.json`, `.claude/hooks/**`, `.git/hooks/**`, and Bash mutations (`rm/mv/chmod/tee/sed -i/echo >`) against those paths; git-layer catches tampering via `INV-claude-hook-secret-denylist` content-hash in the invariants manifest (Story 1.8/1.9); S4 prompt-injection scan flags suspicious diffs; N hook-self-protection blocks per iteration (default N=3) trigger `SECURITY_CRITICAL` halt.

**Assessment of deltas:**

- Items 1–4 are scope-narrowing or late-bound — the epics *defer* or *soften* PRD items, which is safe but should be reflected in PRD for traceability hygiene.
- Items 5–8 are scope-*expanding* — the epics introduce substantive new requirements (Ralph-builds-Ralph safety, Claude Code hook barrier) not yet in the PRD. These address real risks (compiler bootstrap, in-session secret exfiltration under `--dangerously-skip-permissions`) but ideally would be folded back into the PRD as FR14m, NFR5a, NFR5b, and an install-boundary-snapshot NFR before implementation starts.
- **Recommendation:** A single PRD edit pass amending the four `prdClarificationsRaised` items + promoting the four new FRs/NFRs into the PRD (with stable IDs matching what's already in the epic stories) would close the traceability gap. **Not a blocker for Step 3 coverage (every PRD FR is in the epics)** but a blocker for "PRD is the source of truth for 1.0 scope."

### Coverage Statistics

- **Total PRD FRs: 85** (FR1, FR1a, FR2–FR9, FR9a, FR10–FR14, FR14a, FR14a1, FR14a2, FR14a3, FR14b–FR14l, FR15–FR68; wizard-era FR69–FR74 deleted per editHistory 2026-04-17).
- **FRs covered in epics: 85.**
- **Coverage percentage: 100%.**
- **Orphaned epic FRs (in epics but not PRD): 0 at FR level** (epics' FR Coverage Map references only PRD-sourced FRs; 4 new FRs/NFRs introduced by the epics are flagged in `prdClarificationsRaised`, not smuggled into the coverage map).
- **Tally note:** The epics doc self-reports "Total: 84 FRs covered" on line 588, while the individual epic subtotals actually sum to 85 (Epic 1's subtotal of "9 FRs" lists 10 items: FR14, FR28, FR31, FR32, FR34, FR41, FR42, FR43, FR44, FR45). Minor cosmetic tally error in the epics doc — does not affect actual coverage.

## Step 4 — UX Alignment

### UX Document Status

**Found.** `_bmad-output/planning-artifacts/ux-design-specification.md` (1,104 lines, 75 KB) is a completed 14-step UX spec dated 2026-04-18, explicitly scoped to three interlocking surfaces: (1) Ralph/Keel TUI (Python Textual inside devbox), (2) scaffolded baseline web UIs inherited by every Keel fork (auth / teams-or-profile / billing / audit / locale), (3) design-system library governing both. Declares three non-negotiable baseline invariants — responsive (mobile-first adaptive), a11y (WCAG 2.1 AA floor), i18n/l10n (typed-key enforced, RTL parity via logical CSS).

Supporting artefact: `ux-design-directions.html` (26 KB) — the three direction candidates (A "The Instrument" default, B GOV.UK-adjacent, C Developer-notebook) rendered as visual previews.

### UX ↔ PRD Alignment

**Strong alignment on explicit PRD surfaces. Minor gap on responsive as PRD-level invariant.**

| UX requirement | PRD anchor | Status |
| --- | --- | --- |
| WCAG 2.1 AA on baseline UI (signup, login, billing, locale selector, team mgmt) | NFR20 | ✓ Aligned |
| RTL support via logical CSS properties | NFR21 | ✓ Aligned |
| Typed i18n keys (no bare strings) | FR24, FR27 | ✓ Aligned |
| Accept-Language detection + user override | FR25 | ✓ Aligned |
| Baseline English locale + documented add-locale path | FR26 | ✓ Aligned |
| End-user locale selection persists | FR64 | ✓ Aligned |
| B2B team CRUD + invites / B2C individual profile | FR56 | ✓ Aligned |
| Signup email+pw + Google OAuth | FR54 | ✓ Aligned |
| Email verification via Resend | FR55 | ✓ Aligned |
| Paddle subscription (shape-specific hardwired preset) | FR60 | ✓ Aligned |
| DB-backed sessions with revocation | FR57 | ✓ Aligned |
| Step-up auth sensitive actions | FR58 | ✓ Aligned |
| Log out of all sessions | FR59 | ✓ Aligned |
| Halt banner reason + closed-enum rendering (TUI) | FR14k, NFR33a | ✓ Aligned |
| Context-meter footer (TUI) | FR14d | ✓ Aligned |
| Kanban NOW/QUEUE/BLOCKED/DONE panel (TUI) | FR14k | ✓ Aligned |
| tRPC middleware error-handling (STEP_UP_REQUIRED, TENANT_MISMATCH codes) | FR58, FR15 | ✓ Aligned |
| **Responsive / mobile-first / minimum 360×640 viewport** | *No explicit PRD FR/NFR* | ⚠ **Gap (see below)** |

**Responsive-design gap (minor).** The UX spec declares responsive + adaptive + mobile-first as one of the three non-negotiable baseline invariants and pins concrete breakpoints (`sm 640 / md 768 / lg 1024 / xl 1280 / 2xl 1536` with 360×640 minimum viewport). The PRD mentions responsive design implicitly via TanStack Start + Tailwind + UX deliverables, but carries no dedicated FR or NFR specifying responsive/mobile-first as a baseline invariant the way NFR20 (a11y) and NFR21 (RTL) do. This creates a traceability asymmetry: a11y and i18n are PRD-anchored invariants, responsive is a UX-anchored invariant without an equivalent PRD home. **Recommendation:** add a PRD NFR (e.g., NFR20a or NFR21b) stating "Baseline UI shipped with Keel is mobile-first responsive from a 360×640 minimum viewport through desktop; responsive-correctness is enforced at build time via snapshot matrix." Not a blocker for implementation (epics UX-DR13, UX-DR53 already capture the breakpoints + test matrix), but closes the traceability gap.

### UX ↔ Architecture Alignment

Architecture.md explicitly names UX Design Specification as an input document and flows UX spec decisions into pinned architecture decisions. Strong alignment; zero architectural obstacles to UX requirements.

| UX decision (UX spec ref) | Architecture anchor |
| --- | --- |
| shadcn/ui + Radix primitives vendored in-repo | F1 (architecture.md line 240): "matches UX spec's canonical reference: copy-into-repo, CSS-variable tokens, Radix a11y primitives, AA-first" |
| DTCG-format `tokens.json` as single source | F2 (line 9-10 design-token manifest), UX-DR2/3 |
| Shared semantic tokens consumed by both TanStack Start (Tailwind) and Textual TUI (`theme.py`) | "Cross-runtime semantic tokens" (line 90); `packages/keel-invariants/emit-tailwind-theme.ts` + `emit-textual-theme.ts` (lines 1196–1198) |
| Pre-merge sync gate for tokens | "Cross-layer sync enforcement" (c) (line 93); reuses FR43 / FR68 sync-gate pattern |
| Zustand: no SSR hydration; never persist PII/tokens/tenant-IDs | F4 (line 251): Gitleaks + Semgrep rule enforced at pre-commit |
| tRPC error codes include STEP_UP_REQUIRED + TENANT_MISMATCH | A3 (line 234): enum pinned with i18n-keyed messages |
| TanStack Start + Vite + Router + Tailwind v4 stack | Unified `@tanstack/cli` starter for `apps/web` (line 104) |
| shadcn/ui NOT installed via `--add-ons shadcn` (vendor-in-repo only) | Explicit Out-of-1.0-starter flag (line 164) |
| Ralph TUI stays inside devbox, not user-facing 1.0 surface | Line 79 "TypeScript-only end-to-end; Ralph's internal Python Textual TUI is orchestration-only" |
| `--no-tui` headless Ralph flag for monthly sprints | R5 amendment + line 402 |
| Typed i18n key enforcement | `apps/web/app/i18n/` + `packages/keel-invariants/i18n-keys.ts` (line 754); ESLint `no-bare-strings` rule (line 890) |

**Performance considerations.**

- UX spec demands glanceable-in-one-screenful TUI re-attach; architecture pins `docker attach` + Ctrl+P/Q detach (no TUI re-render tax on re-attach) — aligned.
- UX spec demands responsive matrix (48 combos per scaffolded screen in original UX; 18 combos post-Party-Mode-V2). Architecture doesn't directly constrain but NFR1 pre-merge budgets (≤3min / ≤10min) must accommodate the snapshot count. Epic 13 + Party-Mode M4 address via matrix sharding + axis-collapse policy.
- UX spec demands < 5s re-attach read; CLI commands return "immediate" exit. No architecture anti-patterns; `docker attach` round-trip is sub-second; `gh pr checks` latency is the only wall-clock risk surfaced.

### Alignment Issues

**Item 1 — Responsive-design invariant under-pinned at PRD level.** (see gap table above) *Recommendation:* add NFR declaring mobile-first responsive 360×640 baseline. Non-blocking.

**Item 2 — UX-DR1–67 not formally mapped into PRD FR numbering.** The epics document treats 67 UX-DRs as first-class implementable requirements via the "UX Design Requirements" section and references them throughout story implementation notes, but the PRD does not reference UX-DR numbering directly (it references NFR20/NFR21 and FR24-27/FR64 as the contractual UX anchors). This is a deliberate and acceptable split — PRD stays at the contract layer, UX spec owns the design-decision layer — but it does mean "what exactly does the PRD require about the design system" is not fully answerable from the PRD alone. *Recommendation:* no change; the UX spec's `authoritativeSource: _bmad-output/planning-artifacts/prd.md` frontmatter + architecture.md's explicit UX-spec-cited decisions already close the traceability loop at the planning-artifact level.

**Item 3 — Matrix scope reduction flagged as PRD/UX clarification.** Party Mode V2 reduced the snapshot matrix from 48 → 18 combinations at 1.0. This is tracked in the epics `prdClarificationsRaised` frontmatter (item 4) but the UX spec itself still shows the 48-combo matrix (UX-DR53). *Recommendation:* update UX spec UX-DR53 to reflect the 18-combo 1.0 scope with the explicit RTL-retained / dark-visual-deferred-to-1.1 policy. Non-blocking.

### Warnings

- **None critical.** No UX implied-but-missing; UX spec is complete and authoritative.
- **Minor:** responsive-design gap (Item 1) and matrix-scope docs drift (Item 3) should land as PRD/UX edits before sprint planning to prevent stale-docs rot during implementation, but neither blocks story execution.

## Step 5 — Epic Quality Review

16 epics, 189 stories total. Every epic carries explicit **User outcome**, **FRs covered**, and **Standalone delivery** blocks. Stories use Given/When/Then BDD-style acceptance criteria consistently.

### Epic structure snapshot

| # | Epic | Stories | FRs | User-centric title? | Standalone delivery? |
| --- | --- | --- | --- | --- | --- |
| 1 | Substrate Foundation & Machine-Enforced Invariants | 16 | 10 | ✓ Developer outcome | ✓ Clone + `pnpm install` green, gates enforce |
| 2 | Sandboxed Execution Environment (devbox) | 17 | 7 | ✓ Tthew-outcome (safe agent execution) | ✓ Sandboxed container + Claude+gh OAuth |
| 3 | Autonomous Agent Loop (Ralph harness) | 33 | 23 | ✓ Agent outcome (bounded autonomous loop) | ✓ Ralph runs, honours contracts, halts cleanly |
| 4 | Per-Iteration Security Verification & Evidence | 13 | 6 | ✓ Every-iteration outcome | ✓ Every commit green-evidence or rejected |
| 5 | Shape-Driven Configuration & Generator | 9 | 6 | ✓ Developer outcome (one-line shape edit) | ✓ `pnpm generate` works; CI catches drift |
| 6 | Day-1 Tenant Isolation (RLS) | 8 | 4 | ✓ End-user isolation outcome | ✓ Tenant-scoped table gets physical isolation |
| 7 | Design System Components & Patterns | 8 | 0 direct (UX-DR-driven) | ✓ Agent-authoring outcome | ✓ Import primitive/pattern, compose screens |
| 8 | Async Platform (Jobs, Email, Audit) | 7 | 3 | ✓ Developer outcome (typed jobs, emails) | ✓ Enqueue job with tenant+OTel preserved |
| 9 | Authentication & Identity | 12 | 5 | ✓ End-user outcome (full auth loop) | ✓ Complete signup/verify/login/step-up/logout |
| 10 | Commerce (Paddle billing) | 9 | 4 | ✓ End-user subscription outcome | ✓ Subscribe on either shape, webhooks idempotent |
| 11 | Observability, Feature Flags & i18n Framework | 10 | 7 | ✓ Every-request outcome | ✓ Traced, flags evaluate, i18n keys enforced |
| 12 | Scaffolded Management & Onboarding Screens | 10 | 1 (FR56) + UX-DR | ✓ End-user mgmt outcome | ✓ Forker gets composed SaaS UI |
| 13 | Decomposed CI Pyramid & Quality Gates | 14 | 3 | ✓ Every-commit outcome | ✓ Equivalent gates across authors |
| 14 | Research Corpus & Measurement Infrastructure | 11 | 1 (FR33) | ✓ Research-output outcome | ✓ Monthly sprint-log + corpus emitted |
| 15a | `create-keel-app` Bootstrap CLI (early) | 5 | 2 | ✓ Tthew test-fork outcome | ✓ `pnpm dlx create-keel-app` clean fork <2min |
| 15b | Fork Lifecycle Discipline & Distribution Policies (late) | 7 | 3 | ✓ Maintainer outcome | ✓ 1.0 cut ritual + library-monitor ready |

### User Value Focus Check

**✓ PASS — zero technical-milestone epics.** Every epic headline frames a user outcome rather than a technology deliverable:

- Epic 1 names "Developer can clone/fork Keel and rely on ..." (developer outcome), not "Setup Database" or "Monorepo scaffolding."
- Epic 2 names "Tthew can safely run agents under `--dangerously-skip-permissions`" (Tthew outcome), not "Install Docker."
- Epic 5 names "Developer forks Keel, edits one line in `keel.config.ts` ..." (developer outcome), not "Build code generator."
- Epic 7 names "Every agent (or human) authoring UI lands on exactly one primitive per kind ..." (agent outcome), not "Vendor shadcn/ui."
- Epic 13 names "Every commit (agent or human) hits the 5-tier gate pyramid" (every-committer outcome), not "Set up CI/CD."
- Epic 14 names "Every model-generation's substrate-delta is captured as machine-readable research corpus" (research outcome).

Three actor classes served: end users of products (Epics 6, 9, 10, 11, 12), developer/maintainer/forker (Epics 1, 2, 5, 13, 14, 15a, 15b), agent (Epics 3, 4, 7, 8). No silent "technical-plumbing-only" epic.

### Epic Independence Validation

**✓ PASS — clean dependency topology; no forward dependencies; no circular dependencies.**

Topological order honoured: Epic 1 (substrate) → Epic 2 (devbox) → Epic 3 (Ralph, depends on 1+2) → Epic 4 (security, layered on Ralph) → Epic 5 (generator) → Epic 6 (RLS, consumes generator) → Epic 7 (UI primitives, consumes Epic 1 tokens) → Epic 8 (jobs/email/audit) → Epic 9 (auth, consumes 8 for email + 6 for RLS) → Epic 10 (billing, consumes 9 for step-up) → Epic 11 (obs/flags/i18n) → Epic 12 (scaffolded screens, consumes 7/9/10/11) → Epic 13 (CI pyramid, validates all prior) → Epic 14 (research corpus, consumes Ralph logs from Epic 3) → Epic 15a (bootstrap CLI, uses Epic 1+2 seed+devbox) → Epic 15b (1.0-cut ritual, pre-tag all prior).

**Forward-reference inspection.** Several epics mention future epics narratively (e.g., Epic 1 Story 1.13 says "passes Epic 13's reproducibility CI check"; Epic 1 Story 1.15 says "gate reuses Epic 13's CI when it lands; at 1.0 the rule itself ships here even if Epic 13 wiring is partial"). These are **not forward dependencies** — they are documentation of how later epics will consume this epic's output, explicitly paired with "at 1.0 the rule itself ships here even if Epic N wiring is partial" wording that preserves Epic 1's standalone delivery. **✓ OK.**

**E15-split evidence of dependency-discipline.** The Party-Mode E15-split amendment split Epic 15 into 15a (early-landing basic bootstrap) and 15b (late-landing 1.0-cut ritual) precisely because the original Epic 15 would have introduced timing-ambiguity between early-fork-test-tool (Tthew mid-build need) and end-of-sprint maintainer rituals. The split preserves each half's standalone delivery and places them at the correct topological position.

### Story Quality Assessment

**✓ PASS — stories are appropriately sized with strong BDD acceptance criteria.**

Sampled Stories 1.1–1.15 (Epic 1) manually:

- Each story has a clear single-sentence user-role + capability + so-that (INVEST-compatible Role/Goal/Benefit framing).
- Acceptance criteria use `Given … When … Then …` BDD format consistently with 3–7 scenarios per story covering happy path + error + edge cases.
- No "Setup all models" or "Create login UI (depends on Story 1.3)" anti-patterns observed.
- Story 1.4 (pre-commit quality gates) has 4 scenarios: happy path + TS error + lint error + format error. Covers failure modes explicitly.
- Story 1.6 (quality-gate bypass prevention) has 4 scenarios covering config-removal bypass, `--no-verify` bypass, hook-directory pointing away, and the intentional source-fork path. Thorough.
- Story 1.9 (sync-gate runtime tooling) has 6 scenarios covering addition-drift / removal-drift / edit-drift / docs-only-removal / CI integration / local-call latency. Tests every claimed capability.

**Within-epic dependency inspection.** Stories within each epic build incrementally — e.g., Story 1.1 (monorepo scaffold) → 1.2 (keel-invariants package) → 1.3 (ESLint boundary rules depending on 1.2's ESLint config) → 1.4 (prek hooks wiring 1.3's rules) → 1.5 (commitlint extending 1.4). Linear, not leap-frog. No observed "Story 1.5 requires Story 1.8."

**Database / entity creation timing.** Prisma schema is owned by Epic 6 (Story 6.1: baseline Prisma schema); session/account tables (Epic 9 S1) add rows to that schema when first needed. The epics avoid the "Epic 1 Story 1 creates all tables upfront" anti-pattern — tables land with the feature that needs them.

### Special Implementation Checks

**Starter template.** Architecture specifies `@tanstack/cli` (minimal, zero add-ons) as the `apps/web` starter; monorepo root + all non-`apps/web` packages hand-authored. Epic 1 Story 1.1 is "Monorepo scaffold + TypeScript project references" and includes `@tanstack/cli` invocation for `apps/web`; Story 1.2 bootstraps `packages/keel-invariants`. **✓ Epic 1 Story 1 correctly aligns with starter-template requirements.**

**Greenfield indicators present:**

- ✓ Initial project setup: Epic 1 Story 1.1 (monorepo scaffold) + 1.2 (keel-invariants bootstrap).
- ✓ Development environment configuration: Epic 2 (devbox).
- ✓ CI/CD pipeline setup early *enough*: Epic 1 Story 1.14 (release-please config) + Story 1.15 (Renovate); Epic 13 (full decomposed CI pyramid landing at M9). Classic CI/CD lands late intentionally per the architecture's "build gates incrementally, pre-merge-fast first" plan — documented Risk Mitigation in PRD.
- ✓ Greenfield + absorbing-brownfield-Ralph-harness: Epic 3 explicitly handles the cc-devbox absorption at M0.5 with a `legacy-devbox` branch kept green until M4 per PRD bootstrap sequence.

### Quality Assessment — Findings

#### 🔴 Critical Violations

**None.** No technical epics, no forward dependencies, no epic-sized stories that cannot be completed.

#### 🟠 Major Issues

**None.** All epics deliver standalone value; all stories sampled carry clear testable ACs; dependencies flow backward only.

#### 🟡 Minor Concerns

1. **Epic 3 (Autonomous Agent Loop) is oversized at 33 stories and 23 FRs.** Justified — Ralph harness is the project's largest single concern and Party-Mode Round 2 added the 3-layer safe-set scope (RS1–RS10) which produced ~10 new stories for self-modification safety. Risk: under FR14g's `/bmad-dev-story` ≥3-task decomposition rule, many Epic 3 stories will need per-iteration decomposition during execution. *Recommendation:* no epic-level restructuring, but sprint planning should budget extra iterations for Epic 3 stories (2–3× the nominal count). Not a blocker.
2. **Epic 7 covers 0 direct PRD FRs.** This is the design-system catalog epic driven entirely by UX-DR requirements (UX-DR1–67). The epic's "FRs covered: 0 direct FRs (UX-DR-driven; consumes Epic 1 tokens; referenced by every downstream UI epic 9–12 and by Ralph TUI in Epic 3)" statement is transparent, but it creates a subtle traceability asymmetry: UX-DRs are the contract, not PRD FRs. *Recommendation:* the UX-alignment Item 2 recommendation above (no change — `authoritativeSource` frontmatter + architecture citations close the loop) applies here. Not a blocker.
3. **Party-Mode Round 1 + Round 2 amendments introduce 4 new FRs/NFRs not in the PRD (FR14m + install-boundary NFR + NFR5a + NFR5b).** Already flagged in Step 3. The epics use the PRD clarifications frontmatter field to track this explicitly. *Recommendation:* close the loop with a single PRD edit pass after this readiness check. Not a blocker for implementation since the stories carry full AC detail.
4. **Cosmetic tally error in epics doc.** Epic 1 subtotal says "9 FRs" but lists 10 items. Already flagged in Step 3.
5. **UX spec still shows 48-combo snapshot matrix (UX-DR53), contradicting Party-Mode V2's 18-combo 1.0 reduction.** Already flagged in Step 4. Epics-level amendment captures the 18-combo scope; UX spec should update.

### Best-Practices Compliance Checklist

| Check | Status | Notes |
| --- | --- | --- |
| Epic delivers user value | ✓ | All 16 framed as user-outcome |
| Epic can function independently | ✓ | Standalone delivery documented per epic |
| Stories appropriately sized | ✓ | 3–7 ACs typical; Given/When/Then BDD format |
| No forward dependencies | ✓ | Narrative references to later epics paired with "rule ships here at 1.0 even if wiring is partial" |
| Database tables created when needed | ✓ | Prisma schema lands in Epic 6; session/account tables added in Epic 9 with the feature |
| Clear acceptance criteria | ✓ | BDD Given/When/Then; specific + testable |
| Traceability to FRs maintained | ✓ | Per-epic FR list + global FR Coverage Map; 100% coverage |

## Summary and Recommendations

### Overall Readiness Status

**READY — with 7 minor PRD/UX hygiene items recommended before sprint planning.**

The PRD, Architecture, UX spec, and Epics + Stories documents are *implementation-ready*. All four document types are present, current, and internally consistent. Every PRD FR maps to exactly one owning epic (100% coverage). Every epic delivers a user outcome rather than a technical milestone. Every epic claims standalone delivery without forward dependencies. Every story sampled uses Given/When/Then acceptance criteria. The architecture explicitly cites the UX spec as an input and flows its decisions into pinned architecture contracts. No critical or major defects were identified.

The items below are **traceability and doc-hygiene improvements** that would close the loop between epic-introduced amendments and the PRD/UX source-of-truth documents. They do not block story execution — each story carries enough detail for Ralph/Claude Code to implement against.

### Critical Issues Requiring Immediate Action

**None.** Zero critical violations. Zero major issues. The planning stack can proceed to `bmad-sprint-planning` and `bmad-create-story` as-is.

### Recommended Next Steps (before or during sprint planning)

**Documentation-hygiene pass (recommended, not blocking):**

1. **PRD edit pass — promote 4 epics-introduced requirements into the PRD with stable IDs.** The epics frontmatter `prdClarificationsRaised` declares four new FRs/NFRs introduced during Party-Mode Rounds 1 & 2 that are not yet in the PRD:
   - **FR14m** — Ralph three-layer safe-set self-modification policy (L1 install-boundary snapshot, L2 auto-merge on bootstrap-validation pass, L3 lint-guarded Ralph-editable); `.ralph-safe-set.yaml` manifest + pre-commit hook + Ralph-orient self-awareness. *(Epic 3 scope.)*
   - **New NFR (install-boundary-snapshot)** — Ralph harness runs from `uv tool install --from packages/ralph ralph-harness==pin` non-editable snapshot; source edits in `packages/ralph` do not affect current iteration; stage-upgrade requires bootstrap-validation pass. *(Epic 3 scope.)*
   - **NFR5a** — Claude Code hooks + committed `.claude/settings.json` deny rules as a secret-access barrier complementing NFR5 devbox isolation; non-toggle-able; the only in-session defense when Ralph runs with `--dangerously-skip-permissions`. *(Epic 4 / Epic 2 scope.)*
   - **NFR5b** — Hook + settings bypass-resistance: in-session hook self-protects against Edit/Write + Bash mutations on `.claude/settings*.json`, `.claude/hooks/**`, `.git/hooks/**`; N=3 blocks trigger `SECURITY_CRITICAL` halt. *(Epic 4 scope.)*

2. **PRD amendment for 4 existing-FR clarifications** already captured in epics but not reflected in the PRD:
   - FR14a3 — contract at 1.0 as warn-mode; enforcement threshold ≥80% mutant-kill deferred to 1.x after NFR28b empirical baseline.
   - FR54+FR55 — password-reset flow explicit coverage under the baseline email templates already named (verify, invite, reset).
   - Absorption-tripwire skip-trigger — two consecutive skipped monthly sprints = absorption by default → pivot to Invariant Pack within 30 days (complements the delta-within-20%-for-two-consecutive-months trigger).
   - UX-DR53 matrix scope reduction from 48 combos → 18 combos at 1.0 (RTL kept, dark visual verification deferred to 1.1; dark tokens + class-toggle still ship at 1.0).

3. **PRD add responsive-design NFR.** Add an NFR anchoring the UX spec's mobile-first / 360×640-minimum-viewport baseline alongside NFR20 (a11y) and NFR21 (RTL) as the third PRD-level UX invariant. Current state: UX spec + epics UX-DR13/UX-DR53 cover responsive; PRD references it only indirectly. Elevates responsive to traceable-invariant parity with a11y and i18n.

4. **UX spec edit** — update UX-DR53 snapshot matrix from 48 combos to the 18-combo 1.0 scope with explicit RTL-retained + dark-visual-deferred-to-1.1 policy per Party-Mode V2. Keep dark tokens + class-toggle in 1.0 scope (already is).

5. **Epics doc cosmetic fix** — Epic 1 FR-coverage subtotal says "9 FRs" but lists 10. Update to "10 FRs" and correct `epicCount` / `Total: 84` → `Total: 85` if a separate tally line is maintained.

6. **Sprint planning budget guidance** — Epic 3 (Autonomous Agent Loop) is oversized at 33 stories and 23 FRs due to Party-Mode Round 2 safe-set scope. Under FR14g's `/bmad-dev-story` ≥3-task decomposition rule, expect Epic 3 stories to consume 2–3× the nominal iteration count. Sprint-planning output should reflect this headroom.

7. **Surface `prdClarificationsRaised` items to the PRD edit workflow** — consider running `bmad-edit-prd` with the four clarification items in one batch pass to keep PRD authoritative.

### Final Note

This assessment identified **0 critical issues** and **0 major issues** across all 5 review dimensions (discovery, PRD extraction, FR coverage, UX alignment, epic quality). **7 minor hygiene items** are recommended as non-blocking doc-traceability cleanups before sprint planning.

The PRD, Architecture, UX spec, and Epics + Stories are **ready for implementation**. `bmad-sprint-planning` and `bmad-create-story` can proceed without prerequisite changes. Running the 7 hygiene items above in a single PRD + UX edit pass would close the traceability loop between the planning artefacts and the source-of-truth PRD before Ralph starts iterating, but is not a blocker.

---

**Date:** 2026-04-19
**Assessor:** Implementation-Readiness review (bmad-check-implementation-readiness workflow)
**PRD version:** `prd.md` lastEdited 2026-04-18
**Epics version:** `epics.md` stepsCompleted through step-04-final-validation
**Architecture version:** `architecture.md` (current)
**UX spec version:** `ux-design-specification.md` completedAt 2026-04-18

