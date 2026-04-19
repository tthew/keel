---
stepsCompleted:
  - step-01-validate-prerequisites
  - step-02-design-epics
  - step-02-party-mode-amendments
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
  - _bmad-output/planning-artifacts/ux-design-directions.html
epicCount: 16
partyModeAmendments:
  - W1-tokens-into-epic-1 (Winston + Sally, Round 1)
  - W2-sync-gate-tooling-into-epic-1 (Winston, Round 1)
  - W3-generated-migration-contract-story (Winston, Round 1)
  - E7-pattern-recipes (Sally, Round 1)
  - M1-mutation-defer-enforcement (Murat, Round 1)
  - M2-security-evidence-contract-v1-story (Murat, Round 1)
  - M3-flake-log-schema-freeze-story (Murat, Round 1)
  - M4-ux-matrix-budget-envelope-story (Murat, Round 1)
  - V2-matrix-18-combos-rtl-kept-dark-deferred (Sally counter to Victor, Round 1)
  - V4-skip-trigger-tripwire-condition (Victor, Round 1)
  - E15-split-into-15a-early-15b-late (Tthew answer #3, Round 1)
  - RS1-3-layer-safe-set-auto-validation (Round 2 Ralph-builds-Ralph)
  - RS2-packages-ralph-snapshot-install (Round 2)
  - RS3-L2-auto-merge-on-bootstrap-pass (Round 2)
  - RS4-schema-parse-plus-smoke-at-1.0 (Round 2)
  - RS5-pre-merge-slow-path-filtered (Round 2)
  - RS6-lint-guardrails-plus-append-only-plan (Round 2)
  - RS7-hybrid-manifest-ralph-self-aware (Round 2)
  - RS8-new-FR14m-plus-NFR (Round 2)
  - RS9-amend-epic-3-and-13 (Round 2)
  - RS10-policy-and-min-validation-at-1.0 (Round 2)
prdClarificationsRaised:
  - FR14a3 contract at 1.0, threshold enforcement deferred to 1.x after NFR28b empirical baseline
  - Password reset flow explicit coverage under FR54+FR55 + PRD baseline reset email template
  - Absorption-tripwire skip-trigger (two consecutive skipped sprints = absorption by default, pivot to Invariant Pack within 30 days)
  - UX spec clarification - matrix scope at 1.0 is 18 combos (RTL kept, dark visual verification deferred to 1.1; dark tokens + class-toggle still ship at 1.0)
  - NEW FR14m - Ralph three-layer safe-set self-modification policy (L1 install-boundary-snapshot; L2 auto-merge on bootstrap-validation pass; L3 lint-guarded Ralph-editable); .ralph-safe-set.yaml manifest + pre-commit hook + Ralph-orient-reads-manifest self-awareness
  - NEW NFR - Ralph harness runs from install-boundary-snapshot (packages/ralph installed as non-editable via uv tool install --from packages/ralph ralph-harness==pin); source edits in packages/ralph do not affect current iteration; stage-upgrade requires bootstrap-validation pass before stage-N+1 runs
---

# Keel - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Keel, decomposing the requirements from the PRD, UX Design Specification, and Architecture Decision Document into implementable stories.

## Requirements Inventory

### Functional Requirements

#### Execution Environment Management

FR1: Developer can manage devbox lifecycle (start, stop, shell, attach) via pnpm-exposed commands.
FR1a: System can provide deterministic fail-closed domain whitelisting for container egress — atomic reload semantics, IPv4 + IPv6 default-deny parity, single repo-tracked source-of-truth whitelist file, and structured JSONL query-log output suitable for FR37 security-evidence persistence. Mechanism choice resolved at architecture phase (see Additional Requirements S5).
FR2: Developer can invoke Ralph (`pnpm ralph:build` / `pnpm ralph:plan`) with the devbox auto-starting if not already running.
FR3: Developer can authenticate Claude Code and `gh` CLI once per devbox via browser OAuth flows surfaced to the host terminal; tokens persist in the devbox named volume.
FR4: Developer can select between per-fork devbox (default) and shared devbox mode via `.envrc` configuration (`KEEL_DEVBOX_SHARED`).
FR5: System can enforce prerequisites (Docker runtime, Claude Code authentication, `gh` CLI authentication) on fresh-fork first-run and on every Ralph invocation, failing with install-pointer or auth-pointer errors for missing items. Ralph cannot execute autonomously until all prerequisites are satisfied.
FR6: Developer can run substrate-internal tooling (tests, lints, RLS debugger) inside the devbox.

#### Autonomous Agent Loop

FR7: Agent can execute a multi-iteration loop against a committed plan (`.ralph/@plan.md`) inside the devbox, invoking `claude -p` with adaptive thinking and an explicit `effort` setting (default `xhigh` for build iterations, `high` for plan iterations). Each iteration follows the orient → execute → commit → gate → push → exit spine defined by FR14f–FR14k with the halt, backpressure, and budget behaviours of FR8–FR14e.
FR8: System can halt the Ralph loop on a configurable threshold of consecutive test failures or security-verification failures.
FR9: System can halt the Ralph loop on task-budget exhaustion per iteration, using the model-visible `task_budget` advisory counter (beta header `task-budgets-2026-03-13`, ≥ 20K) where available and `max_tokens` as the hard invisible ceiling.
FR9a: System can branch halt handling between `max_tokens` and `model_context_window_exceeded` stop reasons, persisting which applied to each iteration for budget-re-baseline analysis.
FR10: Developer can detach from a running Ralph loop (loop continues executing) and later re-attach to observe state.
FR11: Developer can query Ralph state without attaching via `pnpm ralph:status`.
FR12: Developer can halt the Ralph loop cleanly via `pnpm ralph:stop`.
FR13: System can persist Ralph iteration logs in `stream-json` format for replay and debugging, with `thinking.display = "summarized"` enabled.
FR14: System can require conventional-commit format for all commit messages, regardless of authorship.
FR14a: System requires the Ralph plan file to enumerate a `Required tests:` list per task, derived from story/spec acceptance criteria by `bmad-create-story` and `bmad-agent-dev` planning skills. A build iteration cannot mark a task done until every listed test passes on an unmodified checkout.
FR14a1: The skill that authors a task's `Required tests:` list MUST NOT be the skill that implements the task (authorship separation). Build-mode agents are read-only consumers; any mid-task addition is logged as an `expand:` event requiring planning-skill signature on the next iteration.
FR14a2: `Required tests:` is append-only within a task-open → task-done window. Each entry carries a stable `test-id` (path + fully-qualified test name) and a content hash of the assertion body captured at task-open. Pre-merge-fast fails the build if any `test-id` is removed, renamed, or its hash shrinks without a signed `expand:` annotation countersigned by the planning skill.
FR14a3: For slices tagged `high-risk` (RLS policies, generator `expand` paths, webhook signature verification, auth/session, billing-state transitions), `Required tests:` MUST include at least one mutation-sampled assertion; nightly job applies a fixed mutation catalogue and fails suite if <80% of mutants are killed.
FR14b: System can detect plan staleness (older than configured threshold or same task advanced across N consecutive iterations without progress) and automatically schedule a plan-mode regeneration. Default: 5 no-progress iterations OR 72 hours of plan-artefact age.
FR14c: System can configure a substrate-default subagent fan-out cap (Sonnet-class read/search subagents) with default 250, ceiling 500. **Non-toggle-able invariant**: at most one Sonnet subagent for any build, test, or lint command per iteration.
FR14d: Agent can emit structured context-utilisation metrics per iteration to `.ralph/logs/<iteration-id>/context-meter.json` (advertised-vs-usable context window, specs load, orient load, execute load, output load, percentage utilisation). Triggers: exit cleanly above 80% utilisation; flag above 60% for drift observability.
FR14e: Developer can opt a task into LLM-as-judge acceptance via a fixture (pattern-named `lib/llm-review.ts`) that runs a scoped Opus-class subagent against the diff with the task's subjective acceptance criteria and returns pass/fail. Failure counts as test failure under FR8 backpressure. Growth-tier default; 1.0 ships the pattern contract.
FR14f: Agent can execute a pinned eight-step orient sequence (epic/story, plan file, knowledge files, phase-gate, application source, budget headroom, native task list, PR/CI state) before the execute phase. Skipping any step fails the iteration self-check.
FR14g: Agent can execute exactly one task per iteration along the orient → execute → commit → update IP → pre-push quality gate → pre-push CI gate → push → exit spine. Compound NOW tasks containing "AND" are rejected at orient and decomposed. Each BMad-workflow invocation consumes one full iteration. Stories with ≥ 3 tasks invoked via `/bmad-dev-story` are rejected and decomposed per-iteration.
FR14h: Agent can apply a schema-versioned six-row PR-state × Epic-state × CI-state decision matrix to select the next action per iteration. Three anti-constraints are non-toggle-able invariants: never mark EPIC_DONE while PR is Draft; never transition Draft→Open until all implementation tasks complete; never address PR review feedback while Draft.
FR14i: System can block `git push` while any check on the current PR is in-progress or pending. Ralph queues "Monitor PR CI" at QUEUE top, commits the plan-file update locally, and exits without pushing; unpushed commits carry to the next iteration. CI failures produce a triage entry at QUEUE top with failing-check name, root-cause note, and fix approach.
FR14j: Agent can maintain three audience-scoped knowledge files (`RALPH.md` private journal, `AGENTS.md` shared operational, `CLAUDE.md` Claude-Code-specific) with pinned promotion rules. Iterations producing non-obvious learnings update at least one file alongside the work.
FR14k: System can use the native Claude Code task list as the iteration's crash journal (max 3 active tasks; survives hard kills); agent can hydrate in-flight work via Orient step 7. `.ralph/@plan.md` follows pinned schema (NOW/QUEUE/BLOCKED/DONE/Context; fix tasks enter QUEUE at TOP). `.ralph/halt` sentinel carries pinned JSON schema `{reason, epic, pr}` with closed reason-set at 1.0 (`EPIC_DONE`, `AWAIT_MERGE`, `BUDGET_EXHAUSTED`, `CI_BLOCKED`, `SECURITY_CRITICAL`).
FR14l: Ralph halts the loop on N consecutive failures of the *same* test (identified by stable test-ID, counted across iterations within a single session), where N is configurable per-fork via `.ralph/config.toml` (`halt_on_same_test_fails`). Default N=3; reviewed at M9 against observed false-halt / missed-halt rates.

#### Tenant Isolation

FR15: System can enforce tenant data isolation at the database layer via Row Level Security policies on all tenant-scoped tables, parameterised over the shape's tenancy template (team for B2B, user for B2C). Templates emitted by the generator from `keel.config.ts`; a third `org` template is Growth-tier.
FR16: Developer can set the current tenant context via `tenantGuard()` session-variable setter (keyed on `app.current_tenant_id`) inside request transactions; setter's tenant-resolution logic is emitted from the shape's tenancy template.
FR17: Developer can debug RLS policy decisions for a given query and tenant context via `pnpm rls:explain`.
FR18: System can enforce that new tenant-scoped tables ship with an RLS policy matching the fork's tenancy template, via CI check.

#### Platform Services

FR19: Developer can register typed background jobs via pg-boss, running in the same Postgres database as the app.
FR20: Developer can send transactional emails via Resend using baseline templates.
FR21: Developer can define and evaluate server-side feature flags in TanStack Start route loaders.
FR22: System can emit OpenTelemetry traces for all request paths.
FR23: System can record append-only audit log entries for security-relevant events.

#### Internationalization & Localization

FR24: Developer can author user-facing content using i18n keys resolved to typed translations, not bare strings.
FR25: System can detect locale from the `Accept-Language` header with explicit user-preference override.
FR26: Developer can ship baseline locales (English at minimum) with a documented path for adding additional locales.
FR27: System can enforce i18n-key usage via lint or CI check that prevents bare user-facing strings from shipping.

#### Quality & Governance

FR28: System can run pre-commit quality gates (type-check, lint, format, conventional-commit format) via prek.
FR29: System can run pre-merge quality gates (unit + integration tests, RLS policy tests, import boundaries, dependency audit).
FR30: System can run the release-gated CI tier (manual trigger): `git clone` → shape-edit → signup → tenant formation → paid Paddle sandbox subscription → teardown. Exercised on both shapes (B2B team + B2C user) before release tag.
FR31: System can maintain a rolling release-please Release PR with conventional-commit-based versioning.
FR32: System can prevent quality-gate bypass via configuration; removal requires a source-level fork.
FR33: Developer can record M4 checkpoint decisions as committed markdown artefacts in the repo.
FR34: System can enforce import boundaries at compile time via ESLint `no-restricted-imports` + TypeScript project references.

#### Security Verification & Evidence

FR35: System can run per-iteration security verification (secret scan, dependency audit, SAST, prompt-injection scan) on every Ralph iteration diff before commit.
FR36: System can block a Ralph iteration commit when any security scan reports a finding above the configured severity threshold.
FR37: Agent can persist security evidence (scanner outputs, test results, timestamps) to `.ralph/logs/<iteration-id>/security-evidence.json` for every iteration.
FR38: System can halt the Ralph loop on consecutive security-scan failures equivalent to the test-failure backpressure policy.
FR39: System can enforce OWASP ASVS Level 1 as the substrate security baseline; ASVS Level 2+ is a documented Tier-2 deviation path.
FR40: System can scan committed agent-context-loader files (`CLAUDE.md`, skill files, `.ralph/PROMPT_*.md`, `docs/**/*.md`) for prompt-injection patterns as part of pre-commit quality gates.

#### Invariants

FR41: System can ship a versioned invariants package (`packages/keel-invariants/`) consumed by lint, format, type-check, commit, and merge gates across all substrate and product code.
FR42: System can expose invariants to agents via `INVARIANTS.md` at repo root, referenced by `CLAUDE.md`, providing an agent-readable index of machine-enforced rules.
FR43: System can enforce sync between machine-enforced (`packages/keel-invariants/`) and agent-readable (`INVARIANTS.md`) layers via a pre-merge gate that reads an exported `invariants.manifest.ts` (stable-ID + content-hash per rule) and fails the build on addition drift, removal drift, or edit drift.
FR44: Developer can extend invariants via extension configs that build on `packages/keel-invariants/` (e.g., `eslint.config.fork.js extends eslint.config.keel-invariants.js`) without modifying substrate files.
FR45: *(Growth-tier)* Developer can scaffold a fork-specific `INVARIANTS.fork.md` referenced alongside the upstream `INVARIANTS.md` by `CLAUDE.md`.

#### Forkability & Upgradability

FR46: Developer can fork Keel, rename, and configure project-specific values via a one-line edit to `keel.config.ts` (shape, tenancy, projectIdentity, OTel endpoint) without modifying substrate package internals.
FR47: Developer can bootstrap a fresh Keel-forked project via `pnpm dlx create-keel-app <project-name>` — non-interactive: clones latest substrate tag, strips upstream planning artefacts, runs `pnpm install`, commits the first commit. No wizard. No prompts.
FR48: Developer can change a fork's shape (`b2b` ↔ `b2c`) via literal edit to `keel.config.ts` followed by `pnpm generate` (invoked by pre-commit hook). Typecheck rejects invalid values; generator emits matching RLS tenancy template + Paddle billing preset; sync-enforcement pre-merge gate catches drift.
FR49: *(Growth-tier)* When a second implementation enters an axis (e.g., Next.js alongside TanStack Start), that axis ships a CI-tested migration guide from the hardwired default. At 1.0 there are no migration guides because there is nothing to migrate between.
FR50: Maintainer can cut a Keel major version with the tested model/tooling generation combination documented in release notes. A breaking upstream model upgrade triggers a new major version test-run.
FR51: System can wipe residual `_bmad-output/` and `.ralph/` state on fork-scaffolding, seeding empty per-project state from templates in `packages/keel-templates/`.
FR52: Maintainer can archive per-version planning artifacts to `docs/archive/keel-<version>-planning/` before each major-version tag cut.
FR53: System can distinguish substrate-territory commits from product-territory commits via path-based CI rules, triggering different gate profiles (full decomposed-CI pyramid including nightly shape × tenancy matrix on substrate paths; pre-merge-fast + pre-merge-slow tests only on `apps/web/features/*` paths).

#### Baseline Product Capabilities — Identity & Access

FR54: End user can sign up via email+password or Google OAuth (better-auth implementation).
FR55: End user can verify their email address via a Resend-delivered link.
FR56: End user can create, join, leave, and be invited to teams (B2B shape) — or manage their individual account profile (B2C shape).
FR57: End user can maintain DB-backed sessions with revocation support.
FR58: System can require recent auth (step-up) for sensitive actions.
FR59: End user can log out of all active sessions.

#### Baseline Product Capabilities — Commerce

FR60: End user can subscribe to a paid plan via Paddle. B2B shape uses team-seats preset (per-seat pricing, team-owner billing contact); B2C shape uses individual-subscription preset (single-user pricing). Both presets hardwired in `packages/billing/paddle/`, selected via shape value in `keel.config.ts`.
FR61: System can process Paddle webhooks for lifecycle events (subscription creation, cancellation, dunning, upgrade, downgrade) with signature verification and idempotent handling.
FR62: System can enforce subscription-gated access to premium capabilities. Usage-quota-gated access is deferred to the API-first shape in 1.2.
FR63: *(Growth-tier)* A second billing provider (e.g., Stripe standard or Stripe Connect) enters via thin adapter + migration guide when a real product forces it.

#### End-User Localization

FR64: End user can select a preferred locale; system persists and honors selection across sessions. English baseline always present; additional locales added by scaffolding empty translation files.

#### Configuration & Generator

FR65: Developer can declare per-fork configuration via a typed `keel.config.ts` module at repo root carrying four fields: `shape` (literal union `"b2b" | "b2c"`), `tenancy` (literal union `"team" | "user"` — defaults derived from shape but user-overridable), `projectIdentity` (name, slug, optional domain placeholder), `otelExporter` (endpoint URL, default `"localhost"`). Invalid field values fail at typecheck. No `schemaVersion` field at 1.0.
FR66: Developer can regenerate per-fork artefacts via `pnpm generate`, which reads `keel.config.ts` and emits the shape's RLS tenancy template to `packages/core/rls/*.generated.ts`, the shape's Paddle billing preset to `packages/billing/paddle/preset.generated.ts`, and the `invariants.manifest.ts` content-hash manifest entries covering these artefacts. Idempotent.
FR67: Generator output satisfies a pinned external contract: (a) **pure** — `expand(policy, config) → Rule[]` is a total function, no I/O, no clock, no randomness; (b) **deterministic** — identical inputs produce byte-identical canonicalised output; (c) **idempotent** — re-expanding an already-expanded manifest is a no-op; (d) **order-independent** — merge output invariant under input reordering; (e) **canonical form exists** — every rule set has a unique serialised representation suitable for content-addressed hashing; (f) **stable rule identity** — every emitted rule carries a deterministic, collision-resistant identifier.
FR68: System can enforce sync between `keel.config.ts` and generated artefacts at the pre-merge-fast gate. Any edit to `shape` or `tenancy` without a matching regeneration fails the build; any edit to generated files without a matching `keel.config.ts` source-of-truth change also fails the build.

### NonFunctional Requirements

#### Performance

NFR1: The decomposed CI pyramid hits wall-clock budgets on standard GitHub Actions runner: pre-commit ≤10s, pre-merge-fast ≤3min (must be deterministic — no live-network hits), pre-merge-slow ≤10min, nightly ≤60min (live-network sandbox hits quarantined here), release-gated (manual) bounded only by live-network path. Non-toggle-able. Any tier exceeding its budget fails the build.
NFR2: Devbox cold-start (first-run build) completes within 5 minutes on Apple-Silicon-class hardware; warm-start (container reuse) within 30 seconds. Targets validated during M0.5.
NFR3: RLS query overhead is measurable and monitored against a PRD-placeholder target band of < 15% of query wall-clock for typical tenant-scoped reads. Measured via pre-merge-slow RLS integration suite on ephemeral Postgres using NFR28b empirical-baseline methodology (first-cut benchmark pins final value). Architecture refines at §RLS-Performance-Budget.
NFR4: Ralph iteration startup (context load, task parse, agent spawn) completes within 20 seconds; iteration task-budget enforced. Token budgets (`max_tokens`, execution ceiling, compaction triggers) are tokenizer-aware and re-baselined per tested model version — Opus 4.7's tokenizer emits up to ~35% more tokens per byte than Opus 4.6 for the same text.
NFR4a: Ralph iterations aim for 40–60% utilisation of the advertised context window (200K advertised ≈ 176K usable for Opus 4.7; 117K execution budget target). Iterations exceeding 80% trigger clean-exit budget signal; iterations below 30% flagged as under-utilised for potential task-batching review.
NFR4b: Ralph iterations reserve a 25K push-buffer on top of the task estimate within ~117K execution budget; iteration with less than 25K remaining exits cleanly rather than starting new work. Tasks estimated at ≥ 60K ("XL") are decomposed into smaller QUEUE entries before start. Context-exhaustion signals (repeated tool-call failures, truncated/incoherent subagent responses, same operation retried ≥ 3 times) trigger immediate clean-exit regardless of advertised headroom.

#### Security

NFR5: All agent execution runs inside the devbox; `--dangerously-skip-permissions` is never invoked on the host. Non-toggle-able at config layer; bypass requires a source-level fork.
NFR6: Container network egress is default-deny; reachable hosts limited to whitelist. Expanding whitelist is explicit user action, logged. Container resolver fail-closed (no public-DNS fallback); IPv4 and IPv6 default-deny policies maintained in parity; whitelist reload atomic.
NFR7: Container runs as non-root user (uid/gid ≠ 0). Kernel capabilities limited to NET_ADMIN and NET_RAW — no other capabilities added; container runs with `no-new-privileges`.
NFR8: `/tmp`, `/var/tmp`, and `/workspace/logs` are mounted tmpfs with `noexec,nosuid`. All sizes parameterised via `.envrc` and carry reference defaults empirically validated against the project's canonical workload envelope. Reference defaults live in `packages/devbox/.envrc.example`, retunable without PRD amendment.
NFR8a: Numeric devbox defaults (tmpfs sizes, shm, CPU/memory caps, nofile) are architecture-owned reference config, not PRD requirements. Live in `packages/devbox/.envrc.example`, retunable by substrate maintenance when workload envelope evolves. PRD requirement: devbox remains reproducible across the documented arch/CPU/memory envelope and fails closed on unknown egress.
NFR9: Secrets must never be committed. Pre-commit gate rejects commits matching known secret patterns (API keys, bearer tokens, private keys).
NFR10: Claude Code and `gh` CLI authentication tokens are persisted only inside the devbox volume (`/home/dev/.claude/` and `/home/dev/.config/gh/`); host's `~/.claude/` and `~/.config/gh/` never bind-mounted. Persistence via a named Docker volume, not a host bind-mount.
NFR11: Tenant isolation is enforced at the database layer (RLS), not the application layer.
NFR12: All authenticated sessions are DB-backed with revocation support. Stateless-JWT sessions are a documented Tier-2 deviation path only.
NFR13: All audit log entries are append-only. Application code cannot delete or modify past entries.
NFR14: Dependency audit (Dependabot or equivalent) runs on every PR; critical vulnerabilities block merge.
NFR15: Every Ralph iteration produces structured security evidence (secret scan + dep audit + SAST + prompt-injection scan + test coverage) persisted to `.ralph/logs/<iteration-id>/security-evidence.json` before commit.
NFR16: Security-verification failures are equivalent-priority to test-verification failures for the Ralph loop's halt behaviour.
NFR17: Keel adopts OWASP Top 10:2025, ASVS Level 1, and OWASP Top 10 for Agentic Applications (2026) as substrate security baseline. Level 2+ is Tier-2 deviation path for compliance-bound forks.
NFR18: Critical-severity security findings (hardcoded production secrets, CVSS ≥ 9 vulnerabilities, known RCE patterns) trigger immediate Ralph halt without retry.

#### Scalability

NFR19: The substrate imposes no artificial scalability ceiling beyond what the underlying runtime (Node.js, Postgres, pg-boss) imposes — no hardcoded rate limits, connection caps, or throughput throttles live in substrate code itself. Testable by code inspection (CI grep-gate for hardcoded limits in `packages/core/**`, `packages/jobs/**`, `packages/billing/**`). Horizontal scaling via worker-process extraction is a Tier-2 deviation path.

#### Accessibility

NFR20: Baseline UI components shipped with Keel (signup, login, billing, locale selector, team management) meet WCAG 2.1 Level AA for keyboard navigation, colour contrast, and screen-reader semantics.
NFR21: The i18n framework supports RTL languages at the layout level (logical properties, directional CSS) so right-to-left locales render correctly without component rewrites.

#### Integration

NFR22: Paddle webhook processing is idempotent — repeated delivery of the same event produces the same end state.
NFR23: Paddle webhook signatures are verified against Paddle's public key; unsigned or mis-signed webhooks are rejected.
NFR24: Failed external-service calls (Paddle, Resend) surface through pg-boss job retry semantics with exponential backoff and a dead-letter queue.
NFR25: OAuth flows (Google) enforce PKCE and state-parameter verification to prevent authorization-code injection.

#### Reliability

NFR26: Ralph iteration commits are atomic — an iteration commits a green-test-and-green-security-evidence state or leaves the repo unchanged. Partial-state commits rejected at pre-commit gate.
NFR27: Quality gates (pre-commit, pre-merge, pre-deploy) fail closed — any gate unreachable or misconfigured rejects the commit, PR, or deploy. No silent-success mode.
NFR28: Flake-rate budgets are tier-specific. **Pre-merge-fast + pre-merge-slow gates must be deterministic — flake rate > 0.1% across 30-day window triggers immediate CI-hardening.** Nightly tier (live-network) tolerates up to 2% flake across 30-day window; sustained > 2% triggers a review.
NFR28a: When Ralph runs inside a git worktree (default path `.claude/worktrees/…`, gitignored), the iteration never removes or cleans up the worktree on exit. Worktree removal destroys work-in-progress that survives across iterations. Enforcement at prompt-contract layer with source-layer invariant in `packages/keel-templates/PROMPT_*.template.md`. Non-toggle-able.
NFR28b: The ≤10s / ≤3min / ≤10min / ≤60min tier budgets are provisional target-SLOs until a two-week baseline of real pipeline runs establishes p95 wall-clock per tier. First post-baseline PR pins each tier's NFR budget to `max(stated-target, ceil(p95 × 1.25))`, documented in the architecture doc.
NFR28c: Each tier's p95 wall-clock reviewed monthly. A tier exceeding its NFR budget on p95 for two consecutive months triggers mandatory amendment PR — either re-baseline the budget with documented cause or split the tier.

#### Maintainability

NFR29: Substrate steady-state maintenance (triage, fixes, upgrades) stays at 5-10 hours per month. Sustained > 15 hours/month triggers scope-cut or archive per the Business Success kill criterion.
NFR29a: Keel's Ralph prompt templates (`.ralph/PROMPT_build.md`, `.ralph/PROMPT_plan.md`, and `packages/keel-templates/PROMPT_*.template.md`) are pinned to a specific model generation per major Keel version. Minor Keel versions inherit prompt-set unchanged; major versions may diverge and must record tested model generation + prompt delta in release notes.
NFR30: Every Keel major version documents tested model generation (e.g., Opus 4.7), Claude Code CLI version, BMad version, and Ralph version. A breaking upstream model upgrade triggers a new major version test-run. "Breaking" evaluated against delta catalogue including extended-thinking API changes, thinking-display default flips, sampling-knob removals, tokenizer re-baselines, prefill-handling changes, instruction-following literality shifts, default subagent/tool-call spawn-rate changes, and new stop-reason introductions. Defaults to "treat as breaking" if delta is ambiguous.
NFR31: The Invariants stack's three layers (machine-enforced, agent-readable, documented) are kept in sync by a pre-merge gate; drift between layers fails the build.

#### Observability

NFR32: Every request handled by a Keel-forked app emits OpenTelemetry traces correlated by request ID. Sampling rate configurable per-deploy; exporter endpoint read from `keel.config.ts → otelExporter` at build time.
NFR33: Ralph iterations emit structured stream-json logs to `.ralph/logs/` with per-iteration ID, start/stop timestamps, claude subprocess exit status, and test results.
NFR33a: The `.ralph/halt` sentinel is a JSON file with pinned schema `{reason: <closed enum>, epic: <N | null>, pr: <url | null>}`; presence halts the loop cleanly. Closed reason enum at 1.0: `EPIC_DONE`, `AWAIT_MERGE`, `BUDGET_EXHAUSTED`, `CI_BLOCKED`, `SECURITY_CRITICAL`. `ralph.py` is the 1.0 reference runtime.

#### Configuration & Generator UX

NFR34: The minimal bootstrap (`pnpm dlx create-keel-app <name>`) completes in under 2 minutes wall-clock excluding devbox cold-start. No interactive prompts. No wizard.
NFR35: Shape edits to `keel.config.ts` that produce invalid values fail at typecheck — not silently at first test. Shape + tenancy literal-union types rule out invalid combinations at compile time; no runtime validator because no user-facing wizard presents invalid combinations.
NFR36: *(Reserved.)* The pre-wizard-reversal NFR36 (wizard-schema versioning) is deleted. `keel.config.ts` carries no `schemaVersion` field at 1.0; a field added only when a breaking schema change earns it.
NFR37: The `keel.config.ts` → generated-artefact pipeline is idempotent — running `pnpm generate` repeatedly against already-synchronised repo produces no diff. Idempotency verified by pre-merge-fast test that regenerates and diffs. Content-hashing each generated artefact guards against silent divergence.

### Additional Requirements

Architecture-derived technical requirements that materially shape story creation. These extend the FRs/NFRs with specific implementation contracts pinned at the architecture phase.

#### Starter + Monorepo Topology

- **Hybrid starter**: `@tanstack/cli` minimal (zero add-ons: no clerk, no drizzle, no shadcn add-on, no --router-only) for `apps/web` only; manual scaffold for monorepo root + all other packages.
- **14-package topology** (PRD-pinned): `apps/web` + `packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui, keel-invariants, devbox, keel-generator, keel-templates}` + `create-keel-app`.
- **Public surface enforcement**: only `src/index.ts` exports; internal paths via `@keel/<pkg>/internal/*` ESLint-forbidden; cross-package imports via `@keel/<pkg>` alias; no relative imports crossing `src/` boundary.
- **Test colocation**: `.test.ts` / `.integration.test.ts` / `.fixtures.ts` next to source; no top-level `__tests__/`; E2E only in `apps/web/e2e/*.e2e.test.ts`.

#### Data / RLS (D1–D4)

- **D1 tenantGuard mechanism**: Prisma Client Extension (`$extends`) with query-interception + transaction-wrapped `SET LOCAL app.current_tenant_id`. Per-request tx opens in tRPC middleware, sets session-local, runs handler, commits. PgBouncer-compatible.
- **D2 migration strategy**: `prisma migrate deploy` (forward-only, snapshot-based). Ephemeral-pg CI applies full migration chain on each pre-merge-slow run (≤10min). Generator-emitted RLS policies land as SQL via `prisma db execute` inside companion migrations whose filenames encode the generator content-hash.
- **D3 synthetic-schema tiered strategy**: Pre-merge-fast RLS unit tests against `@electric-sql/pglite` (WASM in-memory Postgres); pre-merge-slow RLS integration tests against Docker-backed ephemeral Postgres via `testcontainers-node`.
- **D4 §RLS-Performance-Budget**: Budget is p95 wall-clock delta measured via benchmark harness. Seed: 10k rows × 100 tenants (team template) + 10k rows × 10k tenants (user template). Benchmark lives in nightly (≤60min). Monthly review via NFR28c; p95 delta > 20% for two consecutive baselines flags NFR3 breach.

#### Authentication & Security (S1–S6)

- **S1 session storage & cleanup**: better-auth DB-backed sessions → Prisma schema adds `Session` + `Account` tables. pg-boss scheduled job `session-cleanup` runs daily to delete expired sessions.
- **S2 step-up middleware**: tRPC middleware `requireRecentAuth({ maxAge: '5m' })` checks session `lastActivity` + `mfaVerifiedAt`. On expiry returns `UNAUTHORIZED` with `code: 'STEP_UP_REQUIRED'`; client catches, redirects to re-auth flow. Applied to all billing routes + tenant-admin routes.
- **S3 per-iteration security-evidence schema**: Structured JSON with fields `iteration_id`, `diff_sha`, `timestamp`, `scans.{secrets,deps,sast,prompt_injection}` (each with `tool`, `findings[]`, `severity_max`), `overall_severity_max`, `halt_required`. Severity enum: `none|low|medium|high|critical`. Ralph halt-logic reads `halt_required` + `overall_severity_max`; critical → immediate halt via `.ralph/halt` with `reason: "SECURITY_CRITICAL"`.
- **S4 prompt-injection scan tier**: Regex + AST at pre-commit (≤10s budget). Rules detect: (a) zero-width Unicode in committed files, (b) known jailbreak trigger strings in agent-reachable markdown, (c) suspicious git-diff patterns (new `--dangerously-skip-permissions` outside `packages/devbox`, `rm -rf /` in scripts, new shell-eval from agent-authored docs). LLM-based deep scan deferred to nightly tier.
- **S5 §Egress-Policy Mechanism**: Belt-and-braces: repaired dnsmasq (DNS authority + JSONL query log for FR1a observability) + nftables (layer-3 egress enforcement for IPv4 + IPv6 default-deny). Atomic reload via `pnpm devbox:whitelist sync` rewriting `whitelist.default.txt` + `nft` table + reloading dnsmasq under file-locked shell-script. Repo-tracked whitelist.
- **S6 release-gated money path**: Paddle sandbox + Google OAuth live money path runs at release-gated only at 1.0. Weekly synthetic money path in nightly deferred post-M9.

#### API & Communication Patterns (A1–A4)

- **A1 tRPC transport**: HTTP with `httpBatchLink` (TanStack Start SSR-native). WebSocket deferred to Growth-tier.
- **A2 tRPC middleware order**: `openTelemetry` → `loggerContext` → `tenantGuard` → `requireAuth` → `requireRecentAuth` → handler. OTel first so all downstream middleware is traced.
- **A3 error-handling standard**: tRPC errors with code enum `UNAUTHORIZED | FORBIDDEN | NOT_FOUND | BAD_REQUEST | INTERNAL_SERVER_ERROR | STEP_UP_REQUIRED | TENANT_MISMATCH`. Zod validation errors auto-map to `BAD_REQUEST`. Human-readable messages are i18n-keyed.
- **A4 webhook signature-verification pattern**: Paddle webhook handler validates via Paddle's official SDK `verifyWebhookSignature()`. Per-handler idempotency key persisted in Postgres: table `webhook_events`, PK `(provider, event_id)` unique.

#### Frontend Architecture (F1–F4)

- **F1 component library**: shadcn/ui + Radix primitives. Vendor-in-repo: zero external-dependency drift. Composition-pattern references from Tailwind UI / Catalyst.
- **F2 design-token manifest**: Single source `packages/ui/tokens.json` (DTCG format). Emits at build time: (i) Tailwind v4 `@theme` config; (ii) Textual `app.tcss` theme. Sync-enforced pre-merge via content-hash. Categories: color semantics, type scale, spacing rhythm, motion, density, focus ring.
- **F3 routing & data-loading**: TanStack Router file-based routes + `loader` functions for server-side data + `defer` / `Await` for streamed SSR. Per-route `loader` carries tRPC server-side calls. Route-loader-scoped feature-flag evaluation per FR21.
- **F4 Zustand posture**: Client-only ephemeral UI state. Server state is tRPC query cache. **No Zustand state hydrated from SSR.** Persistence exception: `persist` middleware targeting `sessionStorage` (default) or `localStorage` (rare) only where delivers real user benefit; never persist PII, auth tokens, tenant IDs, or billing state (Gitleaks + Semgrep enforced at pre-commit); every persisted store carries `version` + `migrate()` fn.

#### Infrastructure & Deployment (I1–I7)

- **I1 hosting**: None pinned at 1.0. Keel ships fork-and-use; deploy-target fork-chosen. Optional `Dockerfile.<target>` presets (Vercel, Fly, Railway) deferred to Growth-tier.
- **I2 CI/CD pipeline**: GitHub Actions with five workflows matching 5-tier CI pyramid. Path-based gate-profile split per FR53 (`packages/**/*` vs `docs/**/*` vs `_bmad-output/**/*` receive different gate profiles). Matrix-driven for shape × tenancy in nightly (2×2 = 4 cells). NFR28b honesty reframe: at 1.0 (M9), minute budgets are **modelled targets** labelled as such; at M10, re-baseline against empirical p95.
- **I3 environment configuration**: `.envrc` (direnv-compatible) at repo root + `.envrc.example` committed. Loads per-fork: Postgres URL, Paddle API key, Resend API key, Google OAuth secret, `ANTHROPIC_API_KEY` (Tier-2 deviation path only), devbox resource knobs. Never committed: `.env`, `.envrc` (local).
- **I4 OTel exporter defaults**: OpenTelemetry SDK with console-exporter default when `OTEL_EXPORTER_OTLP_ENDPOINT` unset (prevents network errors in dogfood / CI); OTLP exporter when set. Sampling: 100% for errors, 10% for non-error traces in production forks (override via `packages/config`). Trace propagation through tRPC middleware.
- **I5 §Devbox-Reference-Config**: `packages/devbox/.envrc.example` holds retunable defaults calibrated to Apple-Silicon M4-Pro baseline (`KEEL_DEVBOX_ARCH=linux/arm64`, `CPUS=8`, `MEMORY_GB=12`, `SHM_GB=2`, `NOFILE=65536`, `TMPFS_TMP_GB=2`, `TMPFS_VAR_TMP_GB=1`, `TMPFS_LOGS_MB=500`, `PORT_WEB=3000`, `PORT_API=3001`, `PORT_STORYBOOK=6006`, `PORT_VITE_HMR=24679`, `SSH=false`, `SHARED=false`).
- **I6 dev container secrets & env var management**: Single dotfile → devbox, Vite-native `VITE_`-prefix for client-runtime, typed `getSecret()` for server-side access, boot-time Zod validation. No pluggable provider shim. `.envrc` (gitignored) + `.envrc.example` (committed) as canonical schema. `packages/devbox/docker-compose.yml` uses `env_file: ../../.envrc`. `packages/config/src/env.ts` (two Zod schemas `ServerEnv`, `ClientEnv`) parsed at module load; `packages/config/src/secrets.ts` exports `getSecret<K extends ServerSecretName>(name: K)`. Structured logger redacts secret patterns. Gitleaks + Semgrep rules. GH Actions step-level secrets (never job-level). `act` local runner with `.secrets.example` committed. M9 audit ships as `pnpm keel:audit-env`.
- **I7 version pinning at M0**: Vitest exact minor; OpenTelemetry JS SDK exact versions of `@opentelemetry/sdk-node`, `@opentelemetry/api`, instrumentations (`pnpm.overrides` to prevent transitive drift); Postgres image tag `ghcr.io/fboulnois/pg_uuidv7:<version>` + bake `CREATE EXTENSION pg_uuidv7;` into compose init SQL. Renovate configuration at `.github/renovate.json` with grouped-update rules + integration-test-passing-required-before-merge for pinned deps.

#### Research Corpus Architecture (RC1–RC3)

- **RC1 corpus layout**: `docs/research/` append-only corpus home. Subdirectories: `sprint-logs/` (`YYYY-MM.md` + `.json`), `checkpoints/` (absorbs existing `docs/checkpoints/`), `tripwire/` (JSON primary + markdown companion), `README.md`. Amendment ceremony matches vertical-slice-acceptance (PR + rationale in changelog + 24h cooling-off).
- **RC2 typed schemas**: Three JSON Schemas in `packages/keel-invariants/src/schemas/`: `sprint-log.schema.json` (month, slice_id, model_version, keel_*/blank_* metrics, delta_percent, notes); `checkpoint.schema.json` (quarter, date, decision_enum, evidence_paths[], next_evaluation_date, rationale); `tripwire.schema.json` (month, verdict_enum, source_sprint_log_id, consecutive_breach_count, pivot_recommended, raw_datapoints[]).
- **RC3 aggregation tooling**: `pnpm research:aggregate` CLI at M9 — reads `docs/research/**/*.json`, validates against RC2 schemas, emits flattened `docs/research/corpus.jsonl`. Idempotent + deterministic. Runs as nightly CI step.

#### Ralph Loop Contracts (R1–R6)

- **R1 halt schema extensions**: Pinned JSON: `{"reason": "<enum>", "epic": <N|null>, "pr": "<url|null>", "iteration_id": "<uuid>", "timestamp": "<ISO8601>"}`. Closed enum per NFR33a.
- **R2 Required tests: manifest format**: Content-hashed, append-only fenced block per-task in `.ralph/@plan.md` with `<!-- task:auto:<id> -->` delimiters, `id`/`path`/`hash` per entry, and `manifest_hash` footer. Pre-merge-fast rejects tasks where `manifest_hash` shrank or `id` list shrank without signed `expand:` annotation naming removed IDs + signer + rationale. Content-similarity measure: stable-test-id primary, Levenshtein secondary.
- **R3 PR-lifecycle state machine**: Authoritative state lives in GitHub PR (`gh pr view --json state,isDraft,reviewDecision,statusCheckRollup`); mirrored to `.ralph/@plan.md`. Pure function `transition(pr_state, epic_state) → action` implemented in `.ralph/lib/pr-state.ts` (TypeScript, invoked via `tsx`).
- **R4 knowledge-file upkeep contract**: Every iteration's commit includes a diff to at least one of `AGENTS.md` / `CLAUDE.md` / `RALPH.md` OR a justification comment in the commit body. Pre-commit hook emits warning (not hard fail) if all three untouched AND no justification found.
- **R5 headless Ralph --no-tui**: Promoted from Growth-tier to M0/M1 research infrastructure. Flag `ralph.py --no-tui` suppresses Textual UI, writes structured JSON to `.ralph/logs/<iteration-id>/` and concluding summary line to stdout. Use cases: monthly blank-starter-sprint runs, scheduled GitHub Actions / cron-driven sprint re-runs, reproducible RC3 aggregation runs. Output contract: structured JSON matching RC2 sprint-log schema.
- **R6 flake measurement layer**: Per-test outcome logging to `.ralph/flake-log/YYYY-MM/<date>.jsonl` — one JSON line per test execution with `{ test_id, iteration_id, outcome (pass|fail|skip), duration_ms, attempt_number, timestamp }`. Vitest custom reporter + GH Actions workflow hook emit same shape. Enforcement deferred to M10 or first empirical breach.

#### Generator Normalization Algorithm (G1–G6)

- **G1 signature**: `expand(policy: TenancyPolicy, config: KeelConfig) → Rule[]` — pure TypeScript, no I/O, no `Date.now()`, no `Math.random()`.
- **G2 ordering lattice**: Output sorted by `(rule.target.table, rule.target.op, rule.id)` lexicographically — stable under input permutation.
- **G3 merge precedence**: `KeelConfig.overrides?.rls?.<table>.<op>` > `policy.rules` > `template.defaultRules`. Conflicts resolved by highest-precedence source silently; no deep merge of rule fields.
- **G4 canonical form**: JSON array of `Rule` objects with keys in fixed order (`id`, `target`, `predicate`, `using`, `with_check`); whitespace-stable via `JSON.stringify(arr, null, 2)`; trailing newline. Content-hash is `sha256(canonical_form)`.
- **G5 stable rule identity**: `rule.id` is `<table>_<op>_<tenancy>_<version>` (e.g., `users_select_team_v1`) — collision-free by construction. Increment version on semantic change; rename alone (same hash) is not semantic change.
- **G6 idempotence proof**: Pre-merge-fast runs `expand(expand(policy, config)) === expand(policy, config)` (content-hash equality).

#### Hygiene Items (C1–C4)

- **C1 pg-boss retry / idempotency / DLQ posture**: pg-boss defaults at 1.0: 3 retries with exponential backoff (250ms × 2^n). Idempotency caller-owned: every job payload either carries a natural idempotency key (e.g., `(provider, event_id)`) or is structurally idempotent. DLQ = manual inspection of `pgboss.job_archive` at 1.0. Poison-message handling leaves row in `archive` with `state='failed'`; OTel span records failure with `error: true`.
- **C2 generator reorder-stability**: Dedicated invariant test in `packages/keel-generator/reorder-stability.test.ts` permutes policy inputs through structural rewrites and asserts content-hash equality. Part of M0.7 acceptance criteria for G6.
- **C3 OTel trace + tenant context propagation across pg-boss boundary**: Job payloads include `tenant_id` (top-level, required) + `traceparent` (W3C trace-context header, required). Worker middleware re-applies `tenantGuard()` to establish `app.current_tenant_id` before handler runs; OTel SDK restores parent trace context from `traceparent`. Lint rule enforces no job reads tenant data without `tenantGuard()`. Cross-boundary integration tests deferred to Growth-tier; smoke test at M4 only.
- **C4 test-ID stability convention**: Every test uses explicit IDs matching `^T-\d{4}$` in the test title, e.g., `test('T-0042: inviteWithVerification_creates_token', ...)`. Manifest keys on `T-\d{4}` only. IDs allocated from monotonically increasing counter in `docs/research/test-ids.md` (append-only). Enforced via ESLint `keel/stable-test-id` rule at pre-commit.

#### Naming + Structure Patterns

- **Database (Postgres/Prisma)**: tables `snake_case` singular; columns `snake_case`; FKs `<parent>_id`; indexes `idx_<table>_<column(s)>`; RLS policy names `policy_<table>_<op>_<tenancy>_<version>` matching G5; enums singular snake_case; session vars `app.<name>` prefix.
- **TypeScript / tRPC**: types/classes/components `PascalCase`; variables/functions `camelCase`; constants `SCREAMING_SNAKE_CASE` (module-global immutables only); tRPC procedures `camelCase` verb-first; Zod schemas `<Name>Schema` suffix with inferred type same name without suffix; hooks `useXxx`.
- **Files & directories**: React components `PascalCase.tsx`; non-component TS modules `kebab-case.ts`; route files `kebab-case.tsx`; test files `<source>.test.ts[x]` colocated; integration tests `<source>.integration.test.ts`; fixtures `<source>.fixtures.ts`; markdown docs `kebab-case.md`.
- **Communication**: pg-boss job names `<domain>.<action>` dotted; audit-log event types `<resource>.<verb>` past-tense; OTel span names `<package>.<operation>`; OTel attribute keys `keel.<namespace>.<attr>`.
- **IDs**: UUIDv7 for all new-row PKs (sortable by time; `pg_uuidv7` extension); Prisma default via `@default(dbgenerated("uuidv7()"))`. Typed IDs at TS layer via Zod branded types.
- **Dates & times**: Wire format ISO 8601 UTC with Z suffix; database `timestamptz`; in-code `Date`; no Moment/Luxon/date-fns as cross-package exports — use `packages/keel-invariants/dates.ts` helpers.

#### Commit / PR / Knowledge-file Patterns

- **Conventional commits** (commitlint via prek): types `feat|fix|docs|chore|refactor|test|build|ci|perf`; scopes are package names or `prd`/`arch`; subject lowercase imperative no period; `BREAKING CHANGE:` footer triggers release-please major bump.
- **PR titles** match primary commit's subject.
- **Knowledge-file voice**: `AGENTS.md` authoritative normative imperative; `CLAUDE.md` Claude-Code specifics only + pointer to AGENTS.md; `RALPH.md` private journal first-person-plural.

#### 1.0 Cut Ritual

- Move `_bmad-output/*` to `docs/archive/keel-1.0-planning/`.
- Retire `cc-devbox`; absorbed `packages/devbox/` is canonical.
- Empty `apps/web/features/*` (Launchpad seed only).
- Seed `packages/keel-templates/PROMPT_*.template.md` from current `.ralph/PROMPT_*.md`.
- Tag `v1.0.0` on substrate.

### UX Design Requirements

#### Design System Foundation

UX-DR1: Adopt shadcn/ui + Radix primitives vendored in `packages/ui/src/components/` (copy-into-repo model, not npm dependency). Each primitive carries a stable Keel catalog ID (`ui.<kind>.01`).
UX-DR2: DTCG-format `packages/ui/tokens.json` as single source of truth for every downstream token consumer. Light + dark modes carried in a single file via `modes`.
UX-DR3: Token generator `packages/ui/scripts/generate-tokens.ts` — pure, deterministic, idempotent, content-hashed per FR67 contract. Emits `packages/ui/src/tokens.css` (web), `packages/ui/tailwind.preset.ts` (Tailwind), `packages/devbox/tui/theme.py` (Textual TUI) with provenance header `generated from tokens.json — do not edit`.
UX-DR4: `packages/ui/tokens.schema.json` JSON-Schema validates DTCG structure at pre-commit (malformed structure, missing `$type`, unresolved `{reference}`, duplicate paths fail).
UX-DR5: WCAG AA contrast assertion at build time for semantic token pairs tagged `text-on-surface` (< 4.5:1 fails, < 3:1 for large text).
UX-DR6: Pre-merge sync gate fails if `tokens.json` changes without matching regenerated outputs (same pattern as FR43 / FR68).
UX-DR7: Catalog at `docs/design/catalog.md` enumerates every primitive + screen template + composition pattern with stable IDs (`ui.button.01`, `ui.screen.team-invite.01`). Referenced by `INVARIANTS.md §ui`; participates in FR43 manifest sync gate. Format: purpose / shape / primitives / template / required tests.
UX-DR8: Design-token fork overrides via `apps/web/tokens.fork.json` (DTCG format, keys mergeable with substrate `tokens.json`). Generator merges substrate + fork tokens before emission. Sync-gate rejects body edits to generated files or primitive components.
UX-DR9: Motion + density scales as global tokens (`motion.scale` default 1 with 0 = reduced-motion respecting OS preference; `density.scale` default 1 with 0.875 tight / 1.125 airy).

#### Visual Design Foundation

UX-DR10: Color palette — OKLCH neutral ramp `neutral.50` oklch(99% 0 0) → `neutral.950` oklch(8% 0 0) across 11 stops (chroma = 0 throughout); single accent `accent.500` oklch(62% 0.16 245) used only on primary buttons, link text, focus rings, selected-row indicators; semantic state vocabulary (`status.info|success|warning|error|critical`, `severity.{low|medium|high|critical}` aliases, `state.pending|in-progress|blocked|done`). No gradients; one semantic token per surface; no color-only hover states.
UX-DR11: Typography — `font.sans` = Inter + system fallbacks; `font.mono` = JetBrains Mono + system fallbacks (shared with TUI); no separate display face at 1.0. Modular 1.125 ratio type scale: `type.xs` 12/16 · `sm` 14/20 · `base` 16/24 · `lg` 18/28 · `xl` 20/28 · `2xl` 24/32 · `3xl` 30/36 · `4xl` 36/40. Weights 400/500/600 only (no 700+). Headings all `font.sans` weight 600 `tracking-tight`. Body 16px minimum base. Line-heights 1.5 body, 1.25 headings, 1.7 long-form. Tabular figures everywhere digits appear in columns.
UX-DR12: Spacing scale — 4px base (Tailwind default); `space.0`–`space.24` at usual Tailwind stops; no arbitrary values allowed (lint-fail on `p-[19px]` patterns). Radius scale: `radius.none` · `sm` 4px · `md` 8px · `lg` 12px · `full` pill.
UX-DR13: Breakpoints (mobile-first, `min-width` only): `sm` 640 · `md` 768 · `lg` 1024 · `xl` 1280 · `2xl` 1536. Minimum viewport 360×640. Container queries for nested composition. Logical CSS properties only (ESLint rule forbids physical).
UX-DR14: Grid — app shell sidebar 240px default (collapsible under `md` via drawer, state persisted per-user) + main column `max-w-5xl` at `lg`, full-bleed below; forms single-column by default (two-column only above `lg` for semantically paired fields); tables horizontal scroll below `md` (no column collapse), sticky header; TUI fixed panels: top status ribbon, left kanban ~40%, right log + DONE ~60%, bottom context-meter.

#### Design Direction

UX-DR15: Substrate default tokens = **Direction A "The Instrument"** (density scale 1.0, accent oklch 54% 0.18 245, true neutral, 6px corners) — matches `k9s`/`lazygit` references; cleanest TUI+web parity; lowest trend-aging risk. Directions B (GOV.UK-adjacent: density 1.125, accent oklch 35% 0.15 240 navy with amber focus, heavy borders, square corners) and C (Developer-notebook: density 0.95, accent oklch 56% 0.17 265 violet-blue, warm-tinted neutral chroma 0.005, 8px corners) shipped as first-class reference fork presets at `docs/design/presets/gov-uk-adjacent.tokens.json` and `docs/design/presets/developer-notebook.tokens.json`. CI-tested for contrast + schema validity at pre-merge.

#### Component Library (24 shadcn primitives + 4 custom web + 6 TUI widgets)

UX-DR16: Lift 24 primitives from shadcn/ui into `packages/ui/src/components/` token-bound to DTCG manifest, each with stable catalog ID: `ui.button.01`, `ui.input.text.01`, `ui.input.textarea.01`, `ui.input.checkbox.01`, `ui.input.radio.01`, `ui.select.01`, `ui.label.01`, `ui.form.01`, `ui.dialog.01`, `ui.drawer.01`, `ui.dropdown-menu.01`, `ui.popover.01`, `ui.tooltip.01`, `ui.toast.01` (sonner), `ui.tabs.01`, `ui.switch.01`, `ui.card.01`, `ui.badge.01`, `ui.separator.01`, `ui.skeleton.01`, `ui.avatar.01`, `ui.scroll-area.01`, `ui.table.01`. Growth-tier deferred: `ui.command.01` (web palette).
UX-DR17: Custom web primitives authored by Keel: `ui.chip.01` (shared TUI + web status chip — tones info/success/warning/error/critical; never color-alone, always icon + label + chip-bg; `role="status"` or `role="alert"` per severity); `ui.empty-state.01` (title + one-line description + 0–1 action; enforces "no marketing copy" at component level); `ui.app-shell.01` (responsive chrome, sidebar + main, build-time shape-aware nav resolution, sidebar collapsible under `md` via drawer, state persisted per-user); `ui.form-field.01` (one-right-way wrapper bundling Label + Input + help + error into one a11y-correct block; `aria-describedby` auto-wired; `aria-invalid` binds to Zod state).
UX-DR18: TUI widgets (Python Textual, consume shared DTCG tokens via `theme.py`): `tui.ribbon.01` (top status ribbon with iter/shape/project + halt banner), `tui.kanban.01` (four-column NOW/QUEUE/BLOCKED/DONE with chip-tagged tasks), `tui.context-meter.01` (bottom readout: ctx percent + budget used + evidence path), `tui.log-tail.01` (autoscroll-unless-user-scrolled-up stream; `font.mono`), `tui.halt-banner.01` (color-coded halt reason bound to halt JSON schema), `tui.command-palette.01` (`:` palette for halt / plan-mode-switch / log-grep actions).

#### Scaffolded Screen Templates (shape-partitioned)

UX-DR19: Shared scaffolded screens at `packages/ui/src/templates/shared/*`: `ui.screen.signup.01`, `ui.screen.login.01`, `ui.screen.verify-email.01`, `ui.screen.verify-expired.01`, `ui.screen.billing.01`, `ui.screen.sessions.01`, `ui.screen.locale.01`, `ui.screen.audit-log.01`, `ui.screen.settings-shell.01`.
UX-DR20: B2B-only screens at `packages/ui/src/templates/_b2b/*`: `ui.screen.onboarding-team.01`, `ui.screen.team-members.01`, `ui.screen.team-invite.01`.
UX-DR21: B2C-only screens at `packages/ui/src/templates/_b2c/*`: `ui.screen.onboarding-profile.01`, `ui.screen.profile.01`.
UX-DR22: Shape-aware page-template resolution at **build time** (not runtime branching): `apps/web/app/routes/*.tsx` import shims pull from `packages/ui/src/templates/_${shape}/*`; keel-generator stitches active-shape templates into routes on regen. ESLint rule forbids cross-shape template imports. No `if (shape === 'b2b')` in product code.

#### Interaction Patterns

UX-DR23: Button hierarchy — **primary** (≤ 1 per visible region, `accent.500` filled), **secondary** (transparent with ring, 0–2 per region), **ghost** (transparent with hover surface-2, unbounded for toolbars), **destructive** (`status.error` filled, always paired with confirm Dialog, 0–1 per region), **link** (accent.500 underlined, unbounded in body copy). Sizes `sm` 28px · `md` 36px default · `lg` 44px · `icon` 36×36. Minimum hit target 44×44px. Label is always imperative verb + noun ("Save changes," never "OK"); `loading` replaces label with spinner (`aria-busy`, label preserved in `aria-label`).
UX-DR24: Form patterns — RHF + Zod is the only contract (no bespoke validation). Label above input. Help text between label and input; error text replaces help text on validation failure (same slot — reduces layout shift). Validation on-blur + on-submit (never on-every-keystroke). `aria-invalid` on error; `aria-describedby` wires to error slot. Zod errors map to typed i18n keys. Primary button goes `loading` with `aria-busy` during mutation; no form-level "Please wait" text. Every input carries correct `autocomplete` attribute (lint fails on password fields without it). Long forms (> 8 fields) split into `h3`-headed sections with `<Separator>`; no accordion collapses for mandatory fields.
UX-DR25: Feedback channels — (1) **inline field error** (RHF/Zod, in `ui.form-field.01` error slot, auto-clears on valid input); (2) **inline block error** (section-level tRPC mutation error as Alert above submit row); (3) **toast** `ui.toast.01` (transient success 5s auto, or non-blocking error manual dismiss; only for actions affecting state *outside* current view; critical-severity never uses toasts); (4) **full-page error route** at `/error/403|404|500` with recovery option; (5) **halt banner** (TUI only, `tui.halt-banner.01` bound to halt JSON, manual dismiss via `.ralph/halt` removal). Success is silent by default (no toast for current-view state changes); errors never leak stack traces / paths / version info.
UX-DR26: Empty state format — `ui.empty-state.01` enforces title (names resource) + one-line description (where it'll appear) + 0–1 primary CTA + optional icon. No marketing copy; no two CTAs. Example: "No members yet · Invited members will appear here. · [Invite member]".
UX-DR27: Loading state — matching-shape skeleton via `ui.skeleton.01` with 200ms delay before render. Never full-screen spinners; never "Loading..." text banners. `<Delayed>` primitive wraps skeleton for <200ms operations.
UX-DR28: Table patterns — sticky header · `type.xs` uppercase labels · `text.muted`; `tabular-nums` on numeric + date columns; row actions in last (logical-end) column via `ui.dropdown-menu.01` triggered by ellipsis icon-button; selection checkboxes at logical-start, header checkbox toggles all visible, selected rows get `surface-2`; sort via clickable headers + arrow icon + `aria-sort` (one active sort column max); pagination below table centered with page-size selector at end (URL reflects state); horizontal scroll below `md` (never column-collapse); empty state renders inside table region.
UX-DR29: Navigation — sidebar at logical-start (collapsible under `md` via `ui.drawer.01`, expanded state persisted per user); topbar minimal (logo + avatar menu); breadcrumbs at top of depth ≥ 2 routes (generated, not hand-authored); current-section indicator via `accent.500` + `surface-2` + `aria-current="page"`; Tab in visual order (no `tabindex > 0`); Escape closes overlays; route transitions preserve scroll for back/forward, reset for forward; no global shortcuts at 1.0; route-nested tabs (each tab has URL); under `md` tabs collapse to vertical list. Cross-shape nav: B2B exposes Dashboard · Team · Billing · Settings; B2C exposes Dashboard · Profile · Billing · Settings. Nav-item set derived at build time from active shape template; product code never branches on shape.
UX-DR30: Modal & overlay — `ui.dialog.01` confirmations only (title + description + max two actions; destructive uses destructive primary variant; focus trap + Escape-to-close + focus-return; `role="dialog"` + `aria-labelledby` + `aria-describedby`); `ui.drawer.01` mobile sidebar + temporary compact views (never for editing state); `ui.popover.01` contextual info only (never for critical action prompts); toast per UX-DR25. NOT shipped: multi-step modal wizards, sticky banners, cookie banners beyond legal necessity, support-chat widgets.
UX-DR31: Copy & voice — short sentences, active voice, imperative mood on actions; no hedging ("might"/"could try"/"perhaps"); no marketing copy ("Welcome!"/"Great job!"/emojis in UI copy); no AI-writing tells (tricolons, "not X — it's Y," rhetorical em-dashes, manufactured vividness); no apologies ("Couldn't send invite," not "Sorry, we couldn't send the invite"). Error format: `<what> — <field name or where> — <expected or next action>` on one line. Empty-state format: `<name resource> · <say where it'll appear> · [CTA verb]`. Button format: imperative verb + noun. Help text: plain language, one sentence.

#### Accessibility (WCAG 2.1 AA floor + opportunistic AAA)

UX-DR32: Contrast enforcement at build (fail = red): `text.default` on `bg.surface` 7:1 (AAA body); `text.muted` on `bg.surface` 4.5:1 (AA secondary); `accent.500` on `bg.surface` 4.5:1 (AA interactive); any `status.*` on its backing surface 4.5:1; icon-only controls 3:1. Failing pair = pre-commit fail.
UX-DR33: Keyboard navigation — all interactive reachable via Tab; `:focus-visible` ring (2px `accent.400`, never removed, not `:focus`); Escape closes overlays; focus returns; Playwright `page.keyboard` traversal per scaffolded screen verifies order.
UX-DR34: Screen-reader semantics — Radix defaults wherever available; custom primitives declare roles; `eslint-plugin-jsx-a11y` fails on custom components missing roles/names; single `<h1>` per route; no skipped heading levels (lint-enforced).
UX-DR35: Labels + errors — every input associated via RHF + Radix Label; lint fails on unlabeled inputs. Error association `aria-describedby` + `aria-invalid` wired automatically by `ui.form-field.01`.
UX-DR36: Touch targets 44×44px minimum (WCAG 2.5.5 AAA) via padding in primitive.
UX-DR37: Motion — `prefers-reduced-motion: reduce` → `motion.scale = 0`; transitions wrapped in `@media (prefers-reduced-motion: no-preference)`.
UX-DR38: Color-scheme — `prefers-color-scheme` respected for initial theme; user preference stored in `localStorage`; dark-mode inherited by every fork, class toggle on `<html>`, no opt-out.
UX-DR39: Contrast-independent signals — every color signal pairs with icon + text label.
UX-DR40: Skip link "Skip to main content" as first tabbable; shipped in `ui.app-shell.01`.
UX-DR41: Error prevention — destructive actions require confirm-Dialog + explicit button press.
UX-DR42: Session timeout — warn + a11y-live announcement before forced logout (WCAG 2.2.5).
UX-DR43: Autocomplete attribute on every input; lint fails on missing for known field types.
UX-DR44: Form validation timing — on-blur + on-submit; never on-every-keystroke.

#### i18n / RTL

UX-DR45: Typed i18n keys via codegen from English baseline locale; bare strings in `.tsx` fail the build (FR27). Key path format: dot-separated `<domain>.<surface>.<key>` (`auth.signup.title`, `billing.checkout.confirm_button`, `error.auth.step_up_required`). Never concatenate keys at runtime; use interpolation params.
UX-DR46: `<html lang="{BCP-47}">` server-rendered from active locale.
UX-DR47: `<html dir="rtl">` when RTL locale; layout flips via logical CSS properties only (no component rewrites). ESLint rule forbids physical `margin-left` / `padding-right` in `className`.
UX-DR48: `Intl.NumberFormat` / `Intl.DateTimeFormat` — no hardcoded date/number strings.
UX-DR49: Baseline locales at 1.0: `en.json` (full English), `ar.json` (scaffolded empty — RTL test), `de.json` (scaffolded empty — LTR test).
UX-DR50: Locale selector `ui.screen.locale.01` — persists preference; `Accept-Language` as initial default (FR25). Translator notes embedded as JSON-schema comments on non-trivial keys.
UX-DR51: RTL snapshots at 360/768/1280 for every scaffolded screen.

#### Testing & Snapshots

UX-DR52: `axe-core` per scaffolded screen at pre-merge — critical violations = 0.
UX-DR53: Playwright snapshot matrix — 360 × 768 × 1280 px × LTR + RTL × light + dark = **48 combinations per scaffolded screen**, generated via helper.
UX-DR54: Lighthouse CI per PR — a11y score ≥ 95; degradation blocks merge.
UX-DR55: `pa11y` nightly on release-gated tier (catches what axe misses).
UX-DR56: i18n-key parity check at pre-commit (ensures every locale has keys present in baseline English).
UX-DR57: Manual a11y checklist before each major version cut (at `docs/design/a11y-manual-checklist.md`): VoiceOver + macOS Safari; NVDA + Windows Firefox; keyboard-only end-to-end J1/J3/J4/J5; zoom to 400% without horizontal scroll; Windows High Contrast mode; Chrome DevTools color-blindness simulation (deuteranopia, protanopia, tritanopia).

#### Ralph TUI Specifics (Python Textual)

UX-DR58: Textual TUI layout — fixed panels: top status ribbon (iter/shape/project + halt banner), left kanban ~40% width (NOW / QUEUE / BLOCKED), right ~60% width (log tail + DONE), bottom context-meter. Ctrl+P Ctrl+Q detach without killing. Minimum 80 × 24 cols (below 80 cols kanban collapses to single column; below 24 rows log tail hides). No mouse; keyboard-only. Resize only via keyboard bindings at 1.0. Color semantic invariants shared with web (blue = info, yellow = warning, red = error, green = success).
UX-DR59: TUI halt banner — color-coded (red for critical, amber for budget, green for EPIC_DONE), bound to halt JSON schema; banner reason + one-line summary + path-to-evidence with no scrolling; manual dismiss via `.ralph/halt` removal.
UX-DR60: TUI log tail — autoscroll-unless-user-scrolled-up stream; `font.mono`; re-attach preserves scroll position.
UX-DR61: TUI `:` command palette for power actions (halt / plan-mode-switch / log-grep).
UX-DR62: TUI context-meter footer — advertised-vs-usable context + budget used + evidence path; updated each iteration per FR14d.

#### Catalog-ID Citation + Novel Patterns

UX-DR63: Every agent-authored component includes catalog-ID citation in file header (e.g., `/* catalog: ui.form.01 */` or `/* catalog: ui.screen.team-invite.01 */`). Target citation rate ≥ 95%; participates in invariants manifest sync gate. Enables traceability; makes components first-class members of the invariants manifest.
UX-DR64: `docs/design/patterns.md` alongside `docs/design/catalog.md`; both participate in FR43 invariants manifest sync-gate (pattern additions require PR + catalog entry + `INVARIANTS.md` anchor).
UX-DR65: Shape-aware page-template selection at build time (not runtime branching) — resolved by the keel-generator per FR66, never by runtime `if (shape === …)`. Routes under `apps/web/app/routes/*.tsx` are thin shims that import from `packages/ui/src/templates/_${shape}/*`; ESLint rule violates cross-shape template imports.
UX-DR66: Design-system failures trigger Ralph-halt-worthy backpressure (per FR14a): token drift, a11y violations, missing i18n keys, contrast failures can fail `Required tests:` and escalate to halts via FR14l.

#### Implementation Guidelines (authoring checklist)

UX-DR67: Twelve rules the agent applies when authoring a new screen:
1. Start from the catalog template; never from scratch.
2. Use tokens for every value; arbitrary values fail lint.
3. Wrap Radix primitives for Dialog/DropdownMenu/Popover/Select/Toast/Tooltip.
4. Use RHF + Zod for every form (no bespoke validation).
5. Use logical CSS properties only.
6. Wire a11y via `ui.form-field.01` defaults; don't override.
7. Reference i18n keys; add to `en.json` in the same PR.
8. Cite catalog ID in file header.
9. Respect `prefers-reduced-motion` via the `motion` helper.
10. Preserve route URLs for multi-step; no modal-first flows.
11. Add Playwright snapshot test (360/768/1280 × LTR/RTL × light/dark) generated via helper.
12. Commit test + screen + locale keys + catalog entry together; partial landings fail pre-merge.

### FR Coverage Map

Every FR (including FR14a–l sub-FRs and FR9a) maps to exactly one primary-owning epic. Cross-cutting concerns (NFRs, architecture decisions, UX-DRs) are listed under each epic's "Implementation notes."

| FR | Primary Epic | Summary |
|----|--------------|---------|
| FR1 | Epic 2 | devbox lifecycle via pnpm |
| FR1a | Epic 2 | fail-closed DNS whitelist |
| FR2 | Epic 2 | Ralph auto-starts devbox |
| FR3 | Epic 2 | Claude Code + gh OAuth in devbox volume |
| FR4 | Epic 2 | per-fork vs shared devbox mode |
| FR5 | Epic 2 | prerequisites enforcement |
| FR6 | Epic 2 | substrate tooling inside devbox |
| FR7 | Epic 3 | multi-iteration Ralph loop |
| FR8 | Epic 3 | halt on consecutive test/security failures |
| FR9 | Epic 3 | halt on task-budget exhaustion |
| FR9a | Epic 3 | branch halt on max_tokens vs model_context_window_exceeded |
| FR10 | Epic 3 | detach/re-attach Ralph |
| FR11 | Epic 3 | query Ralph state via pnpm ralph:status |
| FR12 | Epic 3 | pnpm ralph:stop clean halt |
| FR13 | Epic 3 | stream-json iteration logs |
| FR14 | Epic 1 | conventional-commit format enforcement |
| FR14a | Epic 3 | Required tests: list per task |
| FR14a1 | Epic 3 | authorship separation (planning vs build skill) |
| FR14a2 | Epic 3 | Required tests: append-only manifest immutability |
| FR14a3 | Epic 3 | assertion-shape floor contract for high-risk slices (≥80% mutant-kill — **contract at 1.0 as warn-mode; enforcement threshold deferred to 1.x after NFR28b empirical baseline** per party-mode M1) |
| FR14b | Epic 3 | plan-staleness trigger (5 no-progress / 72h) |
| FR14c | Epic 3 | subagent fan-out budget (1 Sonnet per build/test invariant) |
| FR14d | Epic 3 | per-iteration context meter JSON |
| FR14e | Epic 3 | LLM-as-judge scaffold (Growth-tier default) |
| FR14f | Epic 3 | orient-phase contract (8 steps) |
| FR14g | Epic 3 | execute-phase contract (one task per iteration) |
| FR14h | Epic 3 | PR-lifecycle decision matrix + 3 anti-constraints |
| FR14i | Epic 3 | pre-push CI gate (never push while CI in-flight) |
| FR14j | Epic 3 | knowledge-file upkeep (AGENTS/CLAUDE/RALPH) |
| FR14k | Epic 3 | crash-journal + plan-file + halt schemas |
| FR14l | Epic 3 | halt-on-same-test-fails threshold (default N=3) |
| FR15 | Epic 6 | RLS policies parameterised over tenancy template |
| FR16 | Epic 6 | tenantGuard() session-variable setter |
| FR17 | Epic 6 | pnpm rls:explain CLI |
| FR18 | Epic 6 | CI check new tenant-scoped tables ship with RLS |
| FR19 | Epic 8 | typed pg-boss background jobs |
| FR20 | Epic 8 | Resend transactional emails + baseline templates |
| FR21 | Epic 11 | server-side feature flags in route loaders |
| FR22 | Epic 11 | OpenTelemetry traces for all request paths |
| FR23 | Epic 8 | append-only audit log |
| FR24 | Epic 11 | typed i18n keys (no bare strings) |
| FR25 | Epic 11 | locale detection from Accept-Language + user override |
| FR26 | Epic 11 | baseline locales (English minimum) |
| FR27 | Epic 11 | lint/CI prevents bare user-facing strings |
| FR28 | Epic 1 | pre-commit quality gates (type-check, lint, format, commitlint) |
| FR29 | Epic 13 | pre-merge gates (tests, RLS, import boundaries, dep audit) |
| FR30 | Epic 13 | release-gated CI tier (both shapes) |
| FR31 | Epic 1 | rolling release-please PR |
| FR32 | Epic 1 | prevent quality-gate bypass via config |
| FR33 | Epic 14 | M4 checkpoint decisions as committed markdown |
| FR34 | Epic 1 | compile-time import boundaries (ESLint + TS project refs) |
| FR35 | Epic 4 | per-iteration security verification |
| FR36 | Epic 4 | block commit on finding above severity threshold |
| FR37 | Epic 4 | persist security-evidence.json |
| FR38 | Epic 4 | halt on consecutive security failures |
| FR39 | Epic 4 | OWASP ASVS L1 baseline |
| FR40 | Epic 4 | prompt-injection scan on agent-context files |
| FR41 | Epic 1 | versioned invariants package |
| FR42 | Epic 1 | INVARIANTS.md agent-readable layer |
| FR43 | Epic 1 | sync gate via invariants.manifest.ts |
| FR44 | Epic 1 | fork extension configs |
| FR45 | Epic 1 | *(Growth)* fork-specific INVARIANTS.fork.md |
| FR46 | Epic 5 | fork with one-line keel.config.ts edit |
| FR47 | Epic 15a | pnpm dlx create-keel-app non-interactive bootstrap (early-landing Tthew test-fork tool) |
| FR48 | Epic 5 | change shape via config edit + pnpm generate |
| FR49 | Epic 15b | *(Growth)* second-impl axes ship with migration guide |
| FR50 | Epic 15b | major-version cut with tested model/tooling combo |
| FR51 | Epic 15a | wipe residual state on fork-scaffolding (early; needed for Tthew test forks) |
| FR52 | Epic 15b | archive per-version planning artifacts on major cut |
| FR53 | Epic 13 | path-based CI gate-profile routing |
| FR54 | Epic 9 | signup via email+password or Google OAuth |
| FR55 | Epic 9 | email verification via Resend link |
| FR56 | Epic 12 | team CRUD + invites (B2B) / individual profile (B2C) |
| FR57 | Epic 9 | DB-backed sessions with revocation |
| FR58 | Epic 9 | require recent auth (step-up) for sensitive actions |
| FR59 | Epic 9 | log out of all active sessions |
| FR60 | Epic 10 | Paddle subscribe with shape-specific hardwired preset |
| FR61 | Epic 10 | Paddle webhook signature-verified + idempotent |
| FR62 | Epic 10 | subscription-gated access to premium capabilities |
| FR63 | Epic 10 | *(Growth)* second billing provider adapter |
| FR64 | Epic 11 | end-user locale selection persists across sessions |
| FR65 | Epic 5 | typed keel.config.ts schema |
| FR66 | Epic 5 | pnpm generate emits RLS + Paddle preset + manifest |
| FR67 | Epic 5 | 6-property generator contract |
| FR68 | Epic 5 | pre-merge-fast config ↔ generated-artefact sync gate |

**Coverage totals per epic**

- Epic 1: 9 FRs (FR14, FR28, FR31, FR32, FR34, FR41–FR45)
- Epic 2: 7 FRs (FR1, FR1a, FR2–FR6)
- Epic 3: 23 FRs (FR7–FR14 sub-FRs inclusive of FR9a and FR14a–l)
- Epic 4: 6 FRs (FR35–FR40)
- Epic 5: 6 FRs (FR46, FR48, FR65–FR68)
- Epic 6: 4 FRs (FR15–FR18)
- Epic 7: 0 FRs (UX-DR-driven cross-cutting design-system epic; referenced by every UI epic downstream)
- Epic 8: 3 FRs (FR19, FR20, FR23)
- Epic 9: 5 FRs (FR54, FR55, FR57–FR59)
- Epic 10: 4 FRs (FR60–FR63)
- Epic 11: 7 FRs (FR21, FR22, FR24–FR27, FR64)
- Epic 12: 1 FR (FR56)
- Epic 13: 3 FRs (FR29, FR30, FR53)
- Epic 14: 1 FR (FR33)
- Epic 15a: 2 FRs (FR47, FR51) — early-landing create-keel-app as Tthew test-fork tool
- Epic 15b: 3 FRs (FR49, FR50, FR52) — late-landing 1.0-cut ritual + distribution policies

**Total: 84 FRs covered; every FR has one primary owner; no duplicates; no orphans.**

## Party-Mode Round 1 Amendments

Amendments folded into each epic's implementation notes below. Summary:

- **W1 (tokens into Epic 1)** — Design-token contract (semantic names + scales + design-rationale) + emitter pipeline (tokens.css + tailwind.preset.ts + devbox/tui/theme.py) land in Epic 1 as substrate. Components + catalog + patterns stay in Epic 7. Sally's amendment: Epic 1 ships the token *contract*, not just CSS-var plumbing — catalog header in Epic 1 references token DR so Epic 7 doesn't inherit a time bomb.
- **W2 (sync-gate tooling into Epic 1)** — Invariant-enforcement runtime tooling (manifest reader + anchor walker + drift detector) lands in Epic 1. Epic 13 extends with CI workflow wiring. FR43 teeth from day 1.
- **W3 (generated-migration contract)** — Epic 5 owns an explicit "generated-migration contract" artefact (schema + filename convention + assertion spec). Epic 6's tests assert against it. Closes producer/consumer seam.
- **E7-patterns (pattern recipes)** — Epic 7 adds ~8 interaction-pattern recipes (destructive-confirm, empty-state-with-CTA, error-state taxonomy, loading-state choreography, form-with-validation, table-with-row-actions, modal-confirm, nav-states) as first-class catalog entries.
- **M1 (mutation defer-enforcement)** — Epic 3 ships FR14a3 as contract only at 1.0: manifest flag parses, scanner runs + emits report, enforcement is `warn` not `fail`. ≥80% threshold enforcement deferred to 1.x after NFR28b empirical baseline. PRD clarification raised.
- **M2 / M3 / M4 (three contract-freeze stories)** — Explicit stories at epic seams: Epic 4 "Security-evidence contract v1"; Epic 14 "Flake-log schema freeze" jointly owned with Epic 13 emitters; Epic 13 "Nightly UX-matrix budget envelope" with sharding + axis-collapse policy.
- **V2 (matrix 18 combos)** — Screenshot matrix at 1.0 = 360/768/1280 × LTR/RTL × light = **18 combos** (was 48 in UX spec; was 24 in prior compromise). RTL kept non-negotiable (Sally); dark tokens + class-toggle still ship at 1.0 but dark VISUAL verification moves to 1.1. UX spec clarification raised.
- **V4 (skip-trigger tripwire)** — Epic 14 pre-registers monthly sprint dates in `docs/research/sprint-logs/schedule.md`. Two consecutive skipped monthly sprints = absorption by default → pivot to Invariant Pack within 30 days. PRD clarification raised (absorption-tripwire § Business Success).
- **E15-split (Epic 15 split)** — Epic 15a lands early (near Epic 2-3) as basic `create-keel-app` CLI + fork-scaffolding-state-wipe (Tthew's mid-build test-fork tool). Epic 15b lands late (pre-1.0-cut) with 1.0-cut ritual + correlated-library policy + Ralph upstream diff workflow + Invariant Pack pivot scaffold.

**Declined party-mode proposals (with rationale):**

- V1 (Promote Epic 14 before Epic 8) — Declined. Ralph-first-user framing supersedes sunk-cost argument. Corpus richness comes from Ralph iteration quality, not schema timing.
- V3 (Collapse schemas to markdown) — Declined. JSON Schemas are ~100 lines total; RC3 aggregation CLI + flake-reporter need them for machine parseability.
- John-Epic-3-relocation (Move Epic 3 to position 6/7) — Declined per Tthew affirmation: Ralph is first-class user (executes the implementation of all epics); not infrastructure in search of a user.
- John-Epic-14-1.0-scope-cut — Declined per Tthew affirmation: research corpus is first-class at 1.0.
- John-Epic-15-peer-operator-scope — Declined per Tthew answer #3: `create-keel-app` is Tthew's own mid-build test-fork tool, not peer-operator scope.
- Victor-Epic-14-earlier-positioning (promote before Epic 8) — Declined per V1 above.
- Winston-separate-repo-for-ralph.py — Declined per Tthew RS2: monorepo package `packages/ralph/` + non-editable snapshot install via `uv tool install --from packages/ralph` achieves same physical barrier with better monorepo ergonomics.
- Winston-skip-bootstrap-validation-at-N=1 — Declined per Tthew's automation constraint: manual smoke violates "no human-in-the-loop where feasible." Replaced with schema-parse + minimum smoke iteration at 1.0 (RS4); full structural-invariants oracle deferred to 1.1.
- Murat-defer-full-validation-apparatus-to-N=10 — Partially accepted: full structural-invariants oracle (k=3 / 2-of-3 / tool-call graph / state-transition assertions) deferred to 1.1. But schema-parse + minimum smoke iteration ships at 1.0 because Tthew's automation constraint requires an autonomous L2 auto-merge oracle.
- Winston-TUI-approval-gate-for-knowledge-file-diffs — Declined per Tthew's automation constraint (RS6). Replaced with lint guardrails + append-only `@plan.md` schema as the mitigation.

## Party-Mode Round 2: Ralph-Builds-Ralph (self-modification safety)

Round 2 addressed the elephant raised by Tthew mid-Step 2: if Ralph executes the implementation of all 16 epics AND Epic 3 itself is Ralph harness, how does Ralph iterate on its own source without catastrophic self-corruption (compiler-bootstrap problem)?

Participants: Winston (architectural barriers), Murat (validation test design), Dr. Quinn (TRIZ systems thinking), Amelia (implementer lens). Synthesised resolution: **3-layer safe-set + install-boundary-snapshot + auto-merge-on-validation-pass**. Full folding in Epic 3 amendment (RS1–RS10).

**Key insights worth preserving:**

- **Dr. Quinn's root cause**: Keel was conflating the execution-harness with the execution-target. No type distinction between "code Keel runs" and "code that runs Keel." Fix the type boundary (install snapshot + manifest + CI gates) and the paradox evaporates.
- **Dr. Quinn's sharper question**: "What is the minimum viable type-boundary between harness and target such that Ralph-the-researcher can still learn from Ralph-the-subject failing?" Research value lives in the *controlled blast radius*, not its absence.
- **Winston's failure class flag**: context-window poisoning — Ralph editing `@plan.md` or RALPH.md in ways that parse cleanly but subtly misdirect future-Ralph. Mitigation via append-only schema + lint guardrails (RS6).
- **Amelia's practical insight**: silent prompt corruption is the biggest implementer pain; loud gated handoff is easier to work with than silent breakage.
- **Murat's validation design**: structural-invariants (graph shape of tool calls, file-path writes, state transitions) not record-replay (byte equivalence impossible under LLM non-determinism). Full oracle deferred to 1.1; schema-parse + minimum smoke at 1.0.
- **Tthew's automation constraint**: "automate as much as safely possible; no human-in-the-loop where feasible." Resolution biased toward auto-merge-on-validation-pass over human-gated patch application.

## Epic List

### Epic 1: Substrate Foundation & Machine-Enforced Invariants

**User outcome:** Developer can clone/fork Keel and rely on compile-time package boundaries, version-pinned tooling, and an invariants stack that fails loudly rather than silently drifting. Every AI agent and every human committer hits the same gates.

**FRs covered:** FR14, FR28, FR31, FR32, FR34, FR41, FR42, FR43, FR44, FR45.

**NFRs / Implementation notes:**

- 14-package pnpm+Turborepo monorepo scaffold (`apps/web` + `packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui, keel-invariants, devbox, keel-generator, keel-templates}` + `create-keel-app`).
- Manual scaffold per architecture Starter Template Evaluation (no `create-turbo`; hand-authored `pnpm-workspace.yaml`, `turbo.json`, `tsconfig.base.json`).
- `packages/keel-invariants/` bootstrapped with hardwired ESLint config, Prettier, commitlint, prek hooks, import-boundary rules, and `invariants.manifest.ts` exporter.
- `INVARIANTS.md` + `AGENTS.md` + `CLAUDE.md` + `RALPH.md` seeded with their respective audiences and promotion rules (FR14j baseline lives here; Ralph-run upkeep enforcement is Epic 3).
- Conventional-commit enforcement via commitlint through prek (FR14 scope; same enforcement applies to agent commits in Epic 3).
- release-please-monorepo config with single-bundled release mode (per-package mode deferred per architecture).
- `.github/renovate.json` (I7 version pinning: Vitest exact; `@opentelemetry/sdk-node` + `@opentelemetry/api` + instrumentations pinned in `pnpm.overrides`; grouped-update rules + integration-test-passing gate).
- ESLint `no-restricted-imports` + TypeScript project references for package-boundary enforcement (FR34); `@keel/<pkg>` alias in `tsconfig.base.json`; internal paths via `@keel/<pkg>/internal/*` forbidden; no relative imports crossing `src/`.
- Invariants-manifest sync gate (FR43): pre-merge script walks machine-enforced `packages/keel-invariants/` + `INVARIANTS.md` anchors, fails on addition/removal/edit drift.
- **[W2 party-mode amendment]** Invariant-enforcement sync-gate **runtime tooling** (manifest reader + anchor walker + drift detector) lands in this epic — `packages/keel-invariants/src/sync-gate.ts` + `packages/keel-invariants/src/manifest-reader.ts`. Epic 13 (CI pyramid) extends by wiring this tool into GitHub Actions workflows; FR43 teeth from day 1, not day 22.
- **[W1 party-mode amendment] Design-token contract + emitter pipeline lands here as substrate** (per Winston: tokens are substrate; Ralph TUI theme.py + Epic 5 generator consume them early — waiting for Epic 7 creates retcon debt). Sally's amendment: Epic 1 ships the token *contract* (semantic names + scales + design rationale), not just CSS-var plumbing.
  - **Token source of truth**: `packages/keel-invariants/design-tokens.ts` (typed) OR `packages/ui/tokens.json` (DTCG format) — implementation-level decision deferred to story stage; schema contract lands here either way.
  - **Semantic contract**: design-rationale document at `docs/invariants/tokens.md` defining every semantic token's meaning (e.g., `surface-raised` = X; `status.success` = Y). Referenced by Epic 7 catalog header so there's no "invisible semantic drift" between Epic 1 and Epic 7 (Sally's nightmare story).
  - **Emitter pipeline (UX-DR3)**: `packages/ui/scripts/generate-tokens.ts` — pure, deterministic, idempotent (FR67 contract adapted). Emits `packages/ui/src/tokens.css` (web CSS vars) + `packages/ui/tailwind.preset.ts` (Tailwind config) + `packages/devbox/tui/theme.py` (Textual TUI theme). Provenance header on every emission.
  - **Schema validation (UX-DR4)**: `packages/ui/tokens.schema.json` validated at pre-commit.
  - **WCAG AA contrast check (UX-DR5)**: build-time contrast assertion on `text-on-surface` token pairs.
  - **Sync gate (UX-DR6)**: `tokens.json` changes without matching regenerated outputs fail pre-merge (reuses W2 sync-gate tooling above).
  - **Direction A "The Instrument" as substrate default (UX-DR15)**: pinned here; Directions B (GOV.UK-adjacent) + C (Developer-notebook) land as preset overlays at `docs/design/presets/*.tokens.json` in Epic 7.
  - **Motion + density scales (UX-DR9)**: global `motion.scale` + `density.scale` tokens ship here.
  - 24 shadcn + 4 custom web primitives + 6 TUI widgets + catalog + patterns remain in Epic 7 (gated behind Epic 12 consumer); Epic 7 consumes this epic's emitted token artefacts.
- NFR27 (fail-closed gates), NFR28a (worktree retention — non-toggle-able at prompt-contract + template layer), NFR29/NFR31 (sync-gate discipline across all three invariant layers).
- Naming + structure patterns pinned (snake_case DB singular, camelCase TS, kebab-case files, PascalCase components, test colocation, src/index.ts-only exports, no top-level `__tests__/`).

**Standalone delivery:** The repo can be cloned and `pnpm install` runs green; boundaries hold; commits enforce conventional-commit + lint + type-check; design-token CSS vars + Tailwind preset + Textual theme.py emit deterministically; invariant-enforcement sync-gate runtime executable and testable. No other epics required.

---

### Epic 2: Sandboxed Execution Environment (devbox)

**User outcome:** Tthew can safely run agents under `--dangerously-skip-permissions` inside a fail-closed Docker container; a runtime compromise cannot reach the host; Claude Code + `gh` OAuth tokens persist only in a named Docker volume.

**FRs covered:** FR1, FR1a, FR2, FR3, FR4, FR5, FR6.

**NFRs / Implementation notes:**

- Absorb upstream [`cc-devbox`](https://github.com/tthew/cc-devbox) into `packages/devbox/` per PRD M0.5 five-deliverable sub-scope (image, compose, entrypoint, egress-policy fix, pnpm lifecycle bridge).
- NFR5 (all agent exec in devbox; host never sees `--dangerously-skip-permissions`), NFR6 (fail-closed DNS + IPv4/IPv6 parity + atomic reload), NFR7 (non-root `dev` user + NET_ADMIN/NET_RAW-only caps + `no-new-privileges`), NFR8/NFR8a (tmpfs `noexec,nosuid` + `.envrc`-parameterised sizes), NFR10 (named Docker volume for `/home/dev`, never host bind-mount).
- Ubuntu 24.04 LTS base image; pinned toolchain baked at image build (`node@20-lts`, `pnpm`, `@anthropic-ai/claude-code`, `gh`, `uv`, `aws-cli`, `supabase-cli`, `delta`, Playwright browser deps); no runtime network installs in entrypoint.
- `.envrc` parameterisation: `KEEL_DEVBOX_ARCH`, `KEEL_DEVBOX_CPUS`, `KEEL_DEVBOX_MEMORY_GB`, `KEEL_DEVBOX_SHM_GB`, `KEEL_DEVBOX_NOFILE`, `KEEL_DEVBOX_TMPFS_*`, port knobs, `KEEL_DEVBOX_SSH`, `KEEL_DEVBOX_SHARED`. Reference defaults in `packages/devbox/.envrc.example` (I5; Apple-Silicon M4-Pro baseline; retunable per NFR8a without PRD amendment).
- **§Egress-Policy Mechanism (S5)**: dnsmasq (DNS authority + JSONL query log for FR1a observability) + nftables (layer-3 default-deny IPv4 + IPv6 enforcement). Atomic reload via `pnpm devbox:whitelist sync` under file-lock. Repo-tracked whitelist (`packages/devbox/whitelist.default.txt` + per-category fragments + per-fork override). Upstream divergent-whitelist-script, fail-open resolv.conf, and IPv6 gap all absorbed by this fix.
- Host-side CLI surface: `pnpm devbox:{build,rebuild,clean,status,logs,shell,attach,start,stop,restart,whitelist,monitor,env:check}` scripts in `packages/devbox/scripts/`.
- Ralph auto-start: `pnpm ralph:build` / `pnpm ralph:plan` checks container state and starts if needed (FR2); attaches Textual TUI via `docker attach` with Ctrl+P Ctrl+Q detach.
- One-time auth prerequisites (FR3): `pnpm claude` triggers OAuth (surfaced to host terminal); `pnpm gh:auth` triggers `gh auth login`. Tokens persist in `/home/dev/.claude/` + `/home/dev/.config/gh/` (named volume, not host bind-mount).
- Prerequisite check (FR5): fresh-fork first-run + every Ralph invocation fails with install-pointer or auth-pointer errors on missing Docker runtime, Claude Code auth, or gh auth. Ralph cannot push until `gh` is authed.
- Per-fork vs shared devbox mode (FR4): `KEEL_DEVBOX_SHARED=true` in `.envrc` enables shared workspace mount; default is per-fork.
- Ports bound to `127.0.0.1` (no `0.0.0.0`); opt-in sshd via `KEEL_DEVBOX_SSH=true` (pubkey-only, loopback-bound `127.0.0.1:2222`, host keys auto-generate on first boot).
- Healthcheck on dnsmasq + sshd liveness (upstream's broken `curl :3000` healthcheck is not retained).
- **I6 Secrets & env management** (dev-container bits land here; `packages/config` typed accessors land in Epic 1 scaffold but are wired to devbox here): `packages/devbox/docker-compose.yml` uses `env_file: ../../.envrc`; `.envrc` (gitignored) + `.envrc.example` (committed) as canonical schema; `.secrets.example` for `act` local runner.
- NFR2 (cold-start ≤ 5min Apple-Silicon; warm-start ≤ 30s) validated at epic completion.
- Keep standalone `cc-devbox` functional on a `legacy-devbox` branch until after the M4 checkpoint (mitigation per PRD Technical Risks).

**Standalone delivery:** Developer can `pnpm devbox:start`, get a sandboxed container, authenticate Claude Code + gh once, run `pnpm test` / `pnpm lint` inside. No Ralph or agent loop yet.

---

### Epic 3: Autonomous Agent Loop (Ralph harness)

**User outcome:** Ralph iterations run autonomously against a committed plan, honour non-toggle-able orient/execute/commit/gate/push/exit contracts, halt cleanly with pinned reasons, and preserve state across crashes. Every agent iteration is auditable, budget-bounded, and PR-lifecycle-aware.

**FRs covered:** FR7, FR8, FR9, FR9a, FR10, FR11, FR12, FR13, FR14a, FR14a1, FR14a2, FR14a3, FR14b, FR14c, FR14d, FR14e, FR14f, FR14g, FR14h, FR14i, FR14j, FR14k, FR14l.

**NFRs / Implementation notes:**

- Inherit `ralph.py` (Python Textual TUI) from current `ralph-bmad` repo; place at repo root with `ralphDisposition: fork` (monthly upstream diff review per FR50/Epic 15).
- **Prompt-set layer** (NFR29a pinned per major Keel version): `packages/keel-templates/src/{PROMPT_build,PROMPT_plan}.template.md` seed files; `.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md` materialised on fresh forks (seeding done by Epic 15).
- **Orient-phase contract (FR14f)**: 8-step sequence pinned in PROMPT_build.md — epic/story, plan file, knowledge files, phase-gate, application source, budget headroom, native task list, PR/CI state. Documented in `docs/invariants/ralph-execute.md`.
- **Execute-phase contract (FR14g)**: one task per iteration; orient → execute → commit → update IP → pre-push quality gate → pre-push CI gate → push → exit spine. Compound NOW rejected at orient; XL tasks (≥60K tokens) decomposed before start per NFR4b.
- **PR-lifecycle decision matrix (FR14h)**: schema-versioned six-row matrix pinned in template; 3 anti-constraints (no EPIC_DONE while Draft; no Draft→Open until all tasks complete; no Draft review-feedback) are non-toggle-able invariants.
- **Pre-push CI gate (FR14i)**: `gh pr checks` before every push; any in-progress/pending check routes to "Monitor PR CI" at QUEUE top, commits IP, exits without pushing.
- **Knowledge-file upkeep contract (FR14j)**: pre-commit hook emits warning (not hard fail) if none of `AGENTS.md`/`CLAUDE.md`/`RALPH.md` changed AND no justification in commit body. Enforces `AGENTS.md` = every-agent operational truth; `CLAUDE.md` = Claude-Code specifics + pointer; `RALPH.md` = Ralph private journal.
- **Crash-journal + plan-file + halt schemas (FR14k)**: native Claude Code task list as crash journal (max 3 active; survives hard kills); `.ralph/@plan.md` schema (NOW/QUEUE/BLOCKED/DONE/Context; fix tasks at QUEUE TOP); `.ralph/halt` pinned JSON per R1 (`{reason, epic, pr, iteration_id, timestamp}`; closed enum: `EPIC_DONE | AWAIT_MERGE | BUDGET_EXHAUSTED | CI_BLOCKED | SECURITY_CRITICAL`). Halt schema at `packages/keel-invariants/src/schemas/halt.schema.json`.
- **Required tests: manifest (FR14a/R2)**: content-hashed, append-only fenced block per-task in `.ralph/@plan.md` with `<!-- task:auto:<id> -->` delimiters; entries carry `id`/`path`/`hash`; `manifest_hash` footer. Stored schema at `packages/keel-invariants/src/schemas/plan.schema.json`. Pre-merge-fast rejects manifest shrinkage / rename / hash mutation without countersigned `expand:` annotation.
- **Authorship separation (FR14a1)**: planning skills (`bmad-create-story`, `bmad-agent-dev` in planner role) author manifest; build skills consume read-only; mid-task `expand:` requires planning-skill countersignature.
- **Assertion-shape floor for high-risk slices (FR14a3) — [M1 party-mode amendment: contract at 1.0, enforcement deferred]**: at 1.0 Epic 3 ships the CONTRACT only — (a) manifest flag `mutation_floor: 0.80` exists and parses, (b) `stryker`/`mutmut` scanner runs against high-risk slices (RLS, generator `expand`, webhook-sig, auth/session, billing-state) and emits a report, (c) enforcement mode is `warn`, not `fail`. The ≥80% mutant-kill floor enforcement moves to a dedicated 1.x epic after NFR28b empirical baseline lands — same defer-enforcement precedent as R6 flake measurement layer. **PRD clarification raised**: FR14a3 wording should explicitly split "contract (at 1.0)" from "threshold enforcement (at 1.x)."
- **Plan-staleness trigger (FR14b)**: 5 no-progress iterations OR 72h artefact age auto-schedules plan-mode regeneration.
- **Subagent fan-out budget (FR14c)**: default 250 parallel Sonnet subagents with 500 ceiling; non-toggle-able invariant: **1 Sonnet per build/test/lint command per iteration**, enforced by prompt contract.
- **Per-iteration context meter (FR14d)**: `.ralph/logs/<iter-id>/context-meter.json` with advertised-vs-usable context window, specs/orient/execute/output load, utilisation %. 40-60% target smart zone (NFR4a); >80% exits cleanly; <30% flagged as under-utilised.
- **Execution budget headroom (NFR4b)**: 25K push-buffer; iteration with <25K remaining exits cleanly; XL (≥60K) decomposed pre-start; context-exhaustion signals (repeated tool-call failures, truncated subagent responses, ≥3 retries without progress) trigger immediate clean-exit.
- **Tokenizer-aware budgets (NFR4)**: numeric budgets re-baselined per tested model generation (Opus 4.7 ~35% more tokens/byte than 4.6).
- **Halt on consecutive failures (FR8, FR14l)**: `halt_on_same_test_fails` configurable in `.ralph/config.toml` (default N=3 by stable test-id); halt on test failures, security failures, budget exhaustion.
- **Halt branching (FR9a)**: `max_tokens` vs `model_context_window_exceeded` stop reasons persisted per iteration for budget-re-baseline analysis.
- **Stream-json logs (FR13, NFR33)**: `.ralph/logs/<iter-id>/iteration.jsonl` with `thinking.display = "summarized"` per Opus 4.7 defaults; per-iteration ID + timestamps + claude exit status + test results.
- **Detach/re-attach (FR10)**: Ctrl+P Ctrl+Q detach without killing; `docker attach` re-entry preserves scroll position + TUI state.
- **Status query (FR11)**: `pnpm ralph:status` reads `.ralph/logs/<current>/status.json` without attaching.
- **Clean halt (FR12)**: `pnpm ralph:stop` writes `.ralph/halt` with `reason: "EPIC_DONE"` or agent-specified; next iteration honours and exits.
- **Non-deterministic backpressure (FR14e)**: pattern contract for `lib/llm-review.ts` ships at 1.0; fixture invocation is Growth-tier default.
- **Atomic iteration commits (NFR26)**: pre-commit gate rejects partial-state commits; green-test + green-security-evidence or no commit.
- **PR-lifecycle state machine (R3)**: `.ralph/lib/pr-state.ts` — pure function `transition(pr_state, epic_state) → action` invoked via `tsx`; reads authoritative state from `gh pr view --json state,isDraft,reviewDecision,statusCheckRollup`.
- Ralph TUI widget chrome (`tui.ribbon.01`, `tui.kanban.01`, `tui.context-meter.01`, `tui.log-tail.01`, `tui.halt-banner.01`, `tui.command-palette.01` per UX-DR18, UX-DR58-62) consumes Epic 7's emitted `packages/devbox/tui/theme.py`. Core loop ships with default Textual chrome first; re-themed on Epic 7 landing.

#### [Party-Mode Round 2 amendment] Ralph Self-Modification Safety (three-layer safe-set)

Ralph executes implementation of all 16 epics INCLUDING this one (Epic 3 — Ralph harness itself). Compiler-bootstrap problem: Ralph iterating on a story that breaks Ralph can't complete the iteration to commit the fix. Stage-N is needed to repair stage-N+1 but stage-N was overwritten. Resolution draws on TRIZ time/space/condition separation (Dr. Quinn), structural-invariants validation (Murat), install-boundary barriers (Winston), manifest-driven gating (Amelia). Tthew's operating constraint: **automate as much as safely possible; no human-in-the-loop where feasible.**

**Raises new FR14m** (PRD clarification raised; see epics.md prdClarificationsRaised): Agent can execute a three-layer safe-set policy with layer-specific edit gates enforced via `.ralph-safe-set.yaml` + pre-commit hook + pre-merge-slow bootstrap-validation. **Raises new NFR** (PRD clarification raised): Ralph harness runs from install-boundary-snapshot; source edits do not affect the current iteration; stage-upgrade requires bootstrap-validation pass.

**The three layers (RS1):**

| Layer | Paths | Edit policy | Enforcement |
|-------|-------|-------------|-------------|
| **L1 — Runtime code** | `packages/ralph/` (ralph.py + harness modules), `.ralph/lib/pr-state.ts` | Source is writable as workspace files, but **install-boundary snapshot** means edits don't affect the running harness. Stage-upgrade via dedicated story class. | Non-editable `uv tool install` snapshot at devbox startup. Physical barrier. |
| **L2 — Self-referential surface** | `packages/keel-templates/PROMPT_*.template.md`, `.ralph/PROMPT_*.md`, `.ralph/@plan.md` schema, `packages/keel-invariants/src/schemas/*.schema.json` for halt + plan | **Ralph auto-edits; auto-merges IF bootstrap-validation passes**; fails loudly on parse error or smoke-iteration mismatch. | Pre-merge-slow path-filtered bootstrap-validation. |
| **L3 — Knowledge files** | `AGENTS.md`, `CLAUDE.md`, `RALPH.md`, `.ralph/@plan.md` (entries, not schema) | **Ralph freely edits with lint guardrails**; append-only for `@plan.md` entries. | Pre-commit lint (size caps, H1 protection, URL allowlist, no `## SYSTEM` blocks, append-only @plan.md). |

**RS2 — Install-boundary snapshot mechanism:**

- Source at `packages/ralph/` (monorepo package; full pnpm+turbo+uv integration; CI/lint/test like any other package).
- Devbox entrypoint installs via `uv tool install --from packages/ralph ralph-harness==<pin>` at container startup (non-editable snapshot). Installed tool at `/home/dev/.local/share/uv/tools/ralph-harness/` (named Docker volume per NFR10).
- `packages/devbox/ralph-version.json` pins version + prompt-template content-hash.
- Running harness = installed snapshot. Ralph CAN edit `packages/ralph/` source in workspace, but edits don't affect current iteration.
- **Stage upgrade** = dedicated story class `ralph-stage-upgrade`: bumps `ralph-version.json` → commits → pre-merge-slow runs bootstrap-validation on proposed snapshot → pass → next devbox startup reinstalls from new pin → stage-N+1 runs.

**RS3 — L2 auto-merge on bootstrap-validation pass:**

- Ralph edits L2 files (new halt reason, new orient step, updated `Required tests:` schema, etc.).
- Commit triggers pre-merge-slow path-filtered bootstrap-validation (RS5).
- **Pass** → PR auto-mergeable; Ralph proceeds with next iteration.
- **Fail** → halt with `SECURITY_CRITICAL`-style sentinel (`reason: "RALPH_STAGE_REGRESSION"` — new halt reason pinned in the halt schema as part of this amendment); Tthew reviews.

**RS4 — Bootstrap-validation shape at 1.0 (schema-parse + minimum smoke):**

- (a) **Schema parse**: prompts parse cleanly (markdown + frontmatter); `@plan.md` validates against pinned `plan.schema.json`; halt.schema.json parses.
- (b) **Minimum smoke iteration**: 30s synthetic iteration — Ralph orient reads a fixture `@plan.md` with a trivial task; assertion: first tool call is `Read` or `Bash`; halt reason matches expected on synthetic-halt.
- Full **structural-invariants oracle** (Murat's k=3 / 2-of-3-match / tool-call-graph assertions / file-path-write assertions / state-transition assertions) deferred to 1.1 after first empirical baseline (NFR28b) demonstrates value.

**RS6 — L3 lint guardrails (context-window poisoning mitigation):**

- `tools/lint-knowledge-files.ts` pre-commit hook:
  - RALPH.md size cap (e.g., 500 lines; rotate to `docs/research/ralph-journal/RALPH-archive-YYYY-MM.md`);
  - Reject H1 heading changes (anchor stability);
  - Reject fenced `## SYSTEM` blocks or instruction-like imperatives (`IGNORE PREVIOUS`, `YOU ARE NOW`);
  - URL allowlist (no external URLs in AGENTS.md / CLAUDE.md; RALPH.md only internal doc paths);
  - Diff size cap per commit (flag >200-line edits for review).
- `.ralph/@plan.md` **append-only schema**: new entries append; historical entries immutable (content-hash per entry, same FR14a2 pattern). Prevents "marking a broken invariant as validated" retroactive rewrite.

**RS7 — Hybrid manifest (Ralph self-aware of safety boundary):**

- `.ralph-safe-set.yaml` at repo root enumerates paths per layer:
  ```yaml
  layer1_install_boundary:
    - packages/ralph/**
    - .ralph/lib/**
  layer2_auto_merge_on_validation:
    - packages/keel-templates/PROMPT_*.template.md
    - .ralph/PROMPT_*.md
    - packages/keel-invariants/src/schemas/{halt,plan}.schema.json
    - packages/devbox/ralph-version.json
  layer3_ralph_editable_lint_gated:
    - AGENTS.md
    - CLAUDE.md
    - RALPH.md
    - .ralph/@plan.md
  ```
- `tools/check-safe-set.ts` pre-commit hook diffs staged paths against manifest; rejects L1 edits in non-stage-upgrade commits; routes L2 to bootstrap-validation; allows L3 with lint.
- **Ralph's orient phase (FR14f) reads `.ralph-safe-set.yaml`** as part of context loading — the agent *knows* which files it can edit freely, which require validation, which are off-limits. Self-aware safety boundary.

**Scope at 1.0 (RS10):** install-boundary barrier + manifest + pre-commit hooks + L3 lint + L2 schema-parse + minimum smoke iteration all ship at 1.0. Full structural-invariants bootstrap oracle deferred to 1.1 per Murat's N=10-not-N=1 guidance.

**Ralph TUI widget chrome** (UX-DR18, UX-DR58-62) consumes Epic 7's emitted `packages/devbox/tui/theme.py`. Core loop ships with default Textual chrome first; re-themed on Epic 7 landing.

**Standalone delivery:** Ralph runs autonomously inside the devbox, honours orient/execute/gate contracts + safe-set policy, produces structured logs, halts with pinned reasons (including new `RALPH_STAGE_REGRESSION`). Ralph edits its own L2/L3 surfaces autonomously within the safe-set; L1 runtime is install-boundary-snapshot-protected. No RLS, no auth, no UI — a bounded autonomous loop that safely evolves its own harness.

---

### Epic 4: Per-Iteration Security Verification & Evidence

**User outcome:** Every Ralph iteration produces structured security evidence before commit; scanners block commits on findings above severity threshold; critical-severity halts immediately; every agent-authored change meets OWASP ASVS Level 1 baseline.

**FRs covered:** FR35, FR36, FR37, FR38, FR39, FR40.

**NFRs / Implementation notes:**

- **S3 security-evidence JSON schema** at `packages/keel-invariants/src/schemas/security-evidence.schema.json`: `{iteration_id, diff_sha, timestamp, scans.{secrets, deps, sast, prompt_injection}, overall_severity_max, halt_required}`. Severity enum `none | low | medium | high | critical`. Persisted per iteration to `.ralph/logs/<iter-id>/security-evidence.json` (FR37).
- **[M2 party-mode amendment] Explicit contract-freeze story**: one story at Epic 4 titled "Security evidence contract v1" that freezes (a) JSON schema + `$schema` version, (b) scanner exit-code semantics (zero = clean, non-zero = finding above threshold blocks commit), (c) artefact path convention (`.ralph/logs/<iter-id>/security-evidence.json`). Epic 13 (CI pyramid) workflow-wiring stories depend on this story; single dependency edge collapses cross-epic rework risk when the first false-positive storm hits. Murat: "the contract at the seam" is the critical interface.
- **NFR15 / NFR16**: structured evidence on every iteration; security failures equivalent-priority to test failures for halt policy.
- **Scanner stack at pre-commit / pre-merge-fast (FR35)**: Gitleaks (secrets), `pnpm audit --prod` (deps), Semgrep (SAST), custom prompt-injection rules (S4).
- **S4 prompt-injection scan tier**: regex + AST rules at pre-commit (≤10s budget) — (a) zero-width Unicode, (b) known jailbreak trigger strings in agent-reachable markdown (`AGENTS.md`, `CLAUDE.md`, `RALPH.md`, `.ralph/PROMPT_*.md`, `docs/**/*.md`, story files), (c) suspicious diff patterns (new `--dangerously-skip-permissions` outside `packages/devbox`, `rm -rf /`, shell-eval from agent-authored docs). LLM-based deep scan deferred to nightly tier per architecture.
- **Rule source**: `packages/keel-invariants/prompt-injection-rules/{zero-width.ts, jailbreak-triggers.ts, diff-patterns.ts}`.
- **Semgrep rules** (in `packages/keel-invariants/semgrep-rules/`): `no-env-log.yml`, `no-dynamic-secret.yml`, `no-swallowed-catch.yml`, `no-persist-tenant-id.yml`, `no-raw-fetch.yml` — consumed by pre-commit + pre-merge-fast.
- **Severity threshold blocking (FR36)**: configurable threshold per scanner; any finding above threshold blocks commit via pre-commit hook invoking scanner pipeline.
- **Halt on consecutive security failures (FR38)**: reuses FR14l halt mechanism; 3 consecutive same-security-finding iterations halt via `.ralph/halt` with `reason: "SECURITY_CRITICAL"` or `CI_BLOCKED`.
- **NFR18 critical-severity immediate halt**: hardcoded production secrets, CVSS ≥ 9 vulnerabilities, known RCE patterns halt instantly without retry.
- **FR40 agent-context prompt-injection scan**: enumerated files in pre-commit scope; coverage tested at M9.
- **OWASP ASVS L1 baseline (FR39, NFR17)**: documented in `docs/invariants/security.md`; ASVS L2+ is Tier-2 deviation path (not substrate-surfaced).
- **NFR9 secrets-never-committed**: Gitleaks in pre-commit blocks known secret patterns; `.gitleaksignore` forbidden in `packages/*` (fork-only escape).
- **NFR14 Dependabot** on every PR; critical vulnerabilities block merge (wired in Epic 13 CI workflows; scanner emissions and evidence schema live here).
- **Evidence schema versioned via `$schema`**; consumed by RC3 aggregation (Epic 14) for research-corpus purposes.
- **Crypto correctness + auth-code coverage + error-handling audit** per PRD Security-by-Default checklist — enforced via Semgrep + lint + code review (structured evidence captures each scanner's output).
- **Supply-chain lock**: lockfile committed and unchanged unless iteration intentionally upgrades (called out in commit message).

**Standalone delivery:** Every commit — agent or human — produces a green security-evidence.json or is rejected. Ralph halts on critical findings. Works independently of subsequent feature epics.

---

### Epic 5: Shape-Driven Configuration & Generator

**User outcome:** Developer forks Keel, edits one line in `keel.config.ts` (`shape: "b2b"` ↔ `shape: "b2c"`), and gets correctly-shaped RLS tenancy template + Paddle billing preset. Generator output is pure, deterministic, idempotent, order-independent; drift between config and generated artefacts is caught at pre-merge-fast.

**FRs covered:** FR46, FR48, FR65, FR66, FR67, FR68.

**NFRs / Implementation notes:**

- **FR65 `keel.config.ts` typed schema** at repo root: `{shape: "b2b" | "b2c", tenancy: "team" | "user", projectIdentity: {name, slug, domain?}, otelExporter: string}`. Parsed via Zod in `packages/config/src/schema.ts`. NFR35 (invalid values fail typecheck, not at runtime) — no user-facing wizard. No `schemaVersion` field at 1.0 per NFR36.
- **`packages/keel-generator/`** is the load-bearing substrate package for this epic.
- **G1 signature**: `expand(policy: TenancyPolicy, config: KeelConfig) → Rule[]` — pure TypeScript, no I/O, no `Date.now()`, no `Math.random()`.
- **G2 ordering lattice**: output sorted by `(rule.target.table, rule.target.op, rule.id)` lexicographically.
- **G3 merge precedence**: `KeelConfig.overrides?.rls?.<table>.<op>` > `policy.rules` > `template.defaultRules`. No deep merge of rule fields.
- **G4 canonical form**: JSON array with keys in fixed order (`id`, `target`, `predicate`, `using`, `with_check`); `JSON.stringify(arr, null, 2)`; trailing newline. Content-hash = `sha256(canonical_form)`.
- **G5 stable rule identity**: `<table>_<op>_<tenancy>_<version>` (e.g., `users_select_team_v1`). Rename alone = no semantic change.
- **G6 idempotence proof**: pre-merge-fast test `expand(expand(policy, config)) === expand(policy, config)` (content-hash equality).
- **C2 generator reorder-stability test** at `packages/keel-generator/reorder-stability.test.ts` (permutes inputs through structural rewrites; asserts content-hash equality).
- **FR66 `pnpm generate`**: reads `keel.config.ts`, emits RLS tenancy template to `packages/core/rls/*.generated.ts`, Paddle billing preset to `packages/billing/paddle/preset.generated.ts`, `invariants.manifest.ts` content-hash entries covering generated artefacts. Idempotent.
- **Templates** in `packages/keel-generator/templates/`: `rls-team.ts` (B2B), `rls-user.ts` (B2C), `paddle-team-seats.ts`, `paddle-individual.ts`. Hardwired; `org` template is Growth-tier.
- **FR68 pre-merge-fast sync gate**: any `keel.config.ts` edit without matching regeneration fails; any generated-file edit without matching config change fails. Also covered in Epic 13 CI wiring.
- **FR46 / FR48 fork shape change**: one-line edit to `keel.config.ts` → pre-commit hook invokes `pnpm generate` → emitted files committed alongside; typecheck rejects invalid values; pre-merge-fast catches drift.
- **D2 migration integration**: generator-emitted RLS policies land as SQL via `prisma db execute` inside companion migrations whose filenames encode the generator content-hash; drift becomes a migration-file diff. (Migration plumbing wired in Epic 6.)
- **[W3 party-mode amendment] Generated-migration contract**: Epic 5 owns an explicit contract artefact at `packages/keel-generator/src/migration-contract.ts` defining (a) emitted migration filename schema (`<timestamp>_rls_<shape>_<tenancy>_<content-hash>.sql`), (b) migration SQL shape (pure `prisma db execute` SQL statements; no Prisma schema diffs; self-contained), (c) assertion spec (what Epic 6's tests MUST verify: filename parses, content-hash matches generator output, SQL applies cleanly in pglite + testcontainers Postgres, reverse-idempotency holds on re-run). Epic 6's tests assert against this contract. One file closes the producer/consumer seam so both epics don't end up editing `prisma/migrations/` in coordinated pairs.
- **NFR37 idempotency**: `pnpm generate` repeatedly against synchronised repo produces no diff; verified by pre-merge-fast regenerate-and-diff test.
- **Invariants manifest content-hash entry scope**: generated artefacts (RLS, Paddle preset) participate in FR43 sync gate.
- **NFR30 model-pinning** documents this package's test coverage against the active model generation.

**Standalone delivery:** Developer can run `pnpm generate` and get a correctly-emitted set of per-fork artefacts. Changing shape produces a clean regeneration. CI catches drift. No RLS runtime yet (that's Epic 6), but the contract and generator are ready.

---

### Epic 6: Day-1 Tenant Isolation (RLS)

**User outcome:** Every tenant-scoped table automatically enforces tenant isolation at the database layer. Application-layer bugs cannot cross tenant boundaries. Developers can debug RLS decisions via `pnpm rls:explain`. New tenant-scoped tables without matching RLS fail CI.

**FRs covered:** FR15, FR16, FR17, FR18.

**NFRs / Implementation notes:**

- **`packages/db/`** is the load-bearing substrate package for this epic.
- **D1 `tenantGuard()` mechanism**: Prisma Client Extension (`$extends`) with query-interception + transaction-wrapped `SET LOCAL app.current_tenant_id`. Per-request tx opens in tRPC middleware, sets session-local, runs handler, commits. PgBouncer-compatible (transaction pooling mode). `SET LOCAL` inside tx is the cleanest RLS semantic — no cross-request leak.
- **D2 migration strategy**: `prisma migrate deploy` (forward-only, snapshot-based). Ephemeral-pg CI applies full chain on each pre-merge-slow run. Generator-emitted RLS policies land as SQL via `prisma db execute` inside companion migrations; filename encodes generator content-hash.
- **[W3 party-mode amendment] Assert against Epic 5's generated-migration contract**: Epic 6 tests (`packages/db/test-utils/migration-contract.test.ts`) verify Epic 5's contract at `packages/keel-generator/src/migration-contract.ts` — (a) filename schema parses cleanly, (b) content-hash equals generator output, (c) migrations apply green in pglite (pre-merge-fast) + testcontainers (pre-merge-slow), (d) reverse-idempotency holds on re-run. If Epic 5 breaks the contract, Epic 6 fails the build — producer/consumer seam is tested, not informal.
- **D3 synthetic-schema tiered strategy**:
  - Pre-merge-fast: RLS unit tests against `@electric-sql/pglite` (WASM in-memory Postgres) — millisecond-fast, RLS-compatible.
  - Pre-merge-slow: RLS integration tests against Docker-backed ephemeral Postgres via `testcontainers-node` for faithful PL/pgSQL + extensions.
- **D4 §RLS-Performance-Budget (NFR3)**: benchmark harness measures p95 wall-clock delta with/without RLS on seeded dataset: 10k rows × 100 tenants (team template, 100 rows/tenant) + 10k rows × 10k tenants (user template, 1 row/tenant). Lives in nightly tier. Monthly review per NFR28c; p95 delta > 20% for two consecutive monthly baselines flags NFR3 breach.
- **FR16 `tenantGuard()`**: session-variable setter keyed on `app.current_tenant_id`; tenant-resolution logic emitted per shape's tenancy template.
- **FR15 RLS policies** emitted by Epic 5 generator — this epic wires the runtime to consume them. Both `team` (B2B) and `user` (B2C) templates land at 1.0; `org` is Growth-tier.
- **FR17 `pnpm rls:explain <query> --tenant=<id>`**: structured table output (which policies fired, which rows filtered). Implementation in `packages/db/rls-helpers.ts` + `packages/db/scripts/rls-explain.ts`.
- **FR18 CI check**: new tenant-scoped Prisma model without matching RLS policy in generator output fails pre-merge-slow.
- **NFR11 tenant isolation at DB layer (not application layer)**: architecture-owned invariant; documented in `docs/invariants/backend.md`.
- **`packages/db/src/bench/rls-overhead.bench.ts`** + `bench/seed.ts` for D4 benchmark harness.
- **Prisma schema + migrations**: `packages/db/prisma/schema.prisma` + `prisma/migrations/`. UUIDv7 PKs via `@default(dbgenerated("uuidv7()"))` per I7 `pg_uuidv7` image pinning (base image set in Epic 2).
- **C3 OTel + tenant propagation** (scaffold here; full wiring in Epic 8 async worker): lint rule forbids job reading tenant data without `tenantGuard()`.

**Standalone delivery:** A tenant-scoped table in `packages/db/prisma/schema.prisma` with the correct RLS policy emitted by the generator (from Epic 5) gets physical tenant isolation. `pnpm rls:explain` works. CI catches missing policies.

---

### Epic 7: Design System Components & Patterns

**[W1 party-mode amendment: scope split]** Tokens + emitter pipeline + contract + Direction A/B/C defaults moved to Epic 1 as substrate (consumed by Ralph TUI at Epic 3 time). This epic focuses on components + catalog + patterns that compose the Epic 1 tokens into Loop-D-authorable UI.

**User outcome:** Every agent (or human) authoring UI lands on exactly one primitive per kind AND exactly one interaction-pattern recipe per canonical flow (destructive-confirm, empty-state-with-CTA, error taxonomy, loading choreography, form-with-validation, table-with-row-actions, modal-confirm, nav-states). Catalog entries carry stable IDs; Ralph composes primitives consistently across forks.

**FRs covered:** 0 direct FRs (UX-DR-driven; consumes Epic 1 tokens; referenced by every downstream UI epic 9-12 and by Ralph TUI in Epic 3).

**NFRs / Implementation notes:**

- **`packages/ui/`** is the load-bearing substrate package for this epic (primitives + patterns + catalog — tokens live in Epic 1).
- **Consumes Epic 1 tokens**: imports `packages/ui/src/tokens.css` (CSS vars) + `packages/ui/tailwind.preset.ts` at build time. No token authorship here; only consumption.
- **F1 Component library**: 24 shadcn/ui + Radix primitives vendored in `packages/ui/src/primitives/` — copy-into-repo, not npm dep. Each carries stable Keel catalog ID.
- **UX-DR16 24 shadcn primitives**: `ui.button.01`, `ui.input.{text,textarea,checkbox,radio}.01`, `ui.select.01`, `ui.label.01`, `ui.form.01`, `ui.dialog.01`, `ui.drawer.01`, `ui.dropdown-menu.01`, `ui.popover.01`, `ui.tooltip.01`, `ui.toast.01`, `ui.tabs.01`, `ui.switch.01`, `ui.card.01`, `ui.badge.01`, `ui.separator.01`, `ui.skeleton.01`, `ui.avatar.01`, `ui.scroll-area.01`, `ui.table.01`. `ui.command.01` deferred to Growth-tier.
- **UX-DR17 4 custom web primitives**: `ui.chip.01` (shared TUI+web status chip — tones info/success/warning/error/critical; never colour-alone); `ui.empty-state.01` (title + 0-1 action); `ui.app-shell.01` (responsive sidebar + main, build-time shape-aware nav); `ui.form-field.01` (one-right-way Label+Input+help+error wrapper with `aria-describedby` + `aria-invalid` auto-wired).
- **[E7-patterns party-mode amendment] ~8 interaction-pattern recipes** as first-class catalog entries at `docs/design/patterns.md`, each with stable ID + example + required-tests floor. Closes the seam Sally flagged between Epic 7 primitives and Epic 12 compositions:
  - `pattern.destructive-confirm.01` — Dialog + destructive button variant + focus trap + explicit button press
  - `pattern.empty-state-with-cta.01` — Vercel-restrained (title + one-line description + 0-1 CTA; no marketing copy)
  - `pattern.error-state-taxonomy.01` — inline field / inline block / toast / full-page route / halt banner decision tree per UX-DR25
  - `pattern.loading-state-choreography.01` — skeleton + 200ms delay + `<Delayed>` wrapper per UX-DR27; no full-screen spinners; no "Loading..." text
  - `pattern.form-with-validation.01` — RHF + Zod + `ui.form-field.01` + on-blur + on-submit + aria-invalid per UX-DR24
  - `pattern.table-with-row-actions.01` — sticky header + tabular-nums + dropdown-menu + selection checkboxes + sort per UX-DR28
  - `pattern.modal-confirm.01` — Dialog (confirmations only; max 2 actions; focus return; no multi-step wizards) per UX-DR30
  - `pattern.nav-states.01` — sidebar collapse + breadcrumbs + current-section indicator + Escape-closes per UX-DR29
  - Without explicit pattern-recipe layer, Ralph composes primitives inconsistently across forks and un-scaffolded cases default to spinners + toast-errors (Sally's flag).
- **UX-DR7 Catalog** at `docs/design/catalog.md`: enumerates every primitive + screen template + pattern recipe with stable IDs; format = purpose / shape / primitives / template / required tests. Referenced by `INVARIANTS.md §ui`; participates in FR43 manifest sync gate.
- **UX-DR64 Patterns doc** at `docs/design/patterns.md`; both `catalog.md` + `patterns.md` participate in FR43 sync gate.
- **UX-DR8 Fork token overrides** (applied against Epic 1 tokens): `apps/web/tokens.fork.json` (DTCG) merged with substrate token source before emission; primitive bodies + generated files are not forkable (sync gate rejects direct edits). Direction B/C reference presets at `docs/design/presets/{gov-uk-adjacent,developer-notebook}.tokens.json` (CI-tested for contrast + schema validity at pre-merge).
- **F4 Zustand posture enforcement**: Semgrep rules `no-persist-tenant-id.yml` + lint rules for persist-middleware usage land in this epic (alongside primitive contracts), consumed by every downstream UI epic.
- **TUI widgets (UX-DR18, UX-DR58-62)**: `tui.ribbon.01`, `tui.kanban.01`, `tui.context-meter.01`, `tui.log-tail.01`, `tui.halt-banner.01`, `tui.command-palette.01` — authored in Epic 3 but consume Epic 1's `theme.py` emission.
- **UX-DR66 design-system failures trigger Ralph-halt-worthy backpressure** (token drift, a11y violations, missing i18n keys, contrast failures); escalation via FR14l halt mechanism.
- **Accessibility primitives baked in** (UX-DR32-44): contrast enforcement at build (Epic 1 contract + Epic 7 verification); focus ring (2px accent.400, never removed); `:focus-visible` only; `prefers-reduced-motion` + `prefers-color-scheme` honoured; touch targets 44×44 min; skip link in `ui.app-shell.01`.

**Standalone delivery:** Developer can import any primitive or pattern recipe from `packages/ui`, compose screens, see consistent visuals across web and TUI, and have drift caught by CI. Epic 1's token contract already in place; this epic makes the catalog concrete. No actual screens yet (that's Epic 9/10/12).

---

### Epic 8: Async Platform (Jobs, Email, Audit)

**User outcome:** Developer can register typed background jobs via pg-boss, send transactional emails via Resend baseline templates, and record append-only audit log entries for security-relevant events. Failed external calls retry with exponential backoff; OTel traces and tenant context propagate across the worker boundary.

**FRs covered:** FR19, FR20, FR23.

**NFRs / Implementation notes:**

- **`packages/jobs/`**, **`packages/email/`**, **`packages/audit/`** are the load-bearing substrate packages for this epic.
- **FR19 typed pg-boss jobs**: `packages/jobs/registry.ts` as typed job-name map; agents MUST register here — no ad-hoc job names. Worker bootstrap in `packages/jobs/worker.ts`. Naming convention `<domain>.<action>` dotted (`email.send_verification`, `billing.process_paddle_webhook`, `session.cleanup`).
- **C1 pg-boss retry / idempotency / DLQ posture**: pg-boss defaults — 3 retries with exponential backoff (250ms × 2^n). Idempotency caller-owned: every payload either carries natural idempotency key (e.g., `(provider, event_id)` for webhook-derived work) or is structurally idempotent (e.g., `session-cleanup` deletes where `expired_at < now()`). DLQ = manual inspection of `pgboss.job_archive` at 1.0; automated DLQ routing is Growth-tier. Poison-message handling: leaves row in `archive` with `state='failed'`; OTel span records `error: true`. Documented in `docs/invariants/jobs.md`.
- **C3 OTel trace + tenant context propagation across pg-boss boundary**: payloads include `tenant_id` (top-level, required) + `traceparent` (W3C trace-context header, required). Worker middleware re-applies `tenantGuard()` to establish `app.current_tenant_id` before handler runs; OTel SDK restores parent trace context from `traceparent`. Lint rule enforces no job reads tenant data without `tenantGuard()`.
- **NFR24 failed external-service calls**: retry via pg-boss semantics with exponential backoff + dead-letter archive.
- **FR20 Resend transactional emails**: `packages/email/resend.ts` wrapper; baseline templates in `packages/email/templates/` using react-email: `verify.tsx`, `invite.tsx`, `reset-password.tsx`. Fire-and-forget from `email.send_*` jobs; errors retry with backoff.
- **FR23 append-only audit log**: `packages/audit/log.ts` write-only API; `packages/audit/events.ts` event-type enum; schema column `audit_log.event_type` format `<resource>.<verb>` past-tense (`user.signed_up`, `subscription.created`, `invite.accepted`).
- **NFR13 audit append-only**: application code cannot delete or modify past entries; enforced via Postgres INSERT-only permissions + Prisma client contract.
- **Scheduled jobs scaffold** at `packages/jobs/scheduled/`:
  - `session-cleanup.ts` (daily; consumed by Epic 9 S1)
  - `rls-bench.ts` (nightly; consumed by Epic 6 D4)
  - Additional scheduled jobs land in their owning epics.
- **Other packages call `ctx.jobs.enqueue('<typed-name>', payload)`** via tRPC context (middleware stack from Epic 1 + A2 order from Epic 9); payload schema Zod-validated at enqueue time.
- **Other packages enqueue `email.send_*` jobs** — never call Resend directly. Enforced by `no-restricted-imports` ESLint rule.
- **Other packages write to audit log via `audit.log.write(...)`** — never insert directly into `audit_log` table.

**Standalone delivery:** Developer can `ctx.jobs.enqueue('email.send_verification', {...})` and have it run with retries, tenant context preserved, OTel trace continuation, audit events recorded. No consumers yet (Epic 9 wires verify flow).

---

### Epic 9: Authentication & Identity

**User outcome:** End users can sign up (email+password or Google OAuth), verify email, recover forgotten passwords, maintain revocable DB-backed sessions, step up for sensitive actions, and log out all sessions. Every auth flow is tenant-isolation-aware and OTel-traced.

**FRs covered:** FR54, FR55, FR57, FR58, FR59. (Password reset is in scope under FR54 + FR55 + PRD's baseline-template enumeration; no new FR raised at this stage — flagged for optional PRD clarification at workflow end.)

**NFRs / Implementation notes:**

- **`packages/core/auth/`** is the load-bearing substrate package for this epic.
- **better-auth hardwired**: DB-backed sessions, Google OAuth + email/password providers. Configured in `packages/core/auth/better-auth.ts`. No adapter surface at 1.0.
- **S1 session storage + cleanup**: Prisma schema adds `Session` + `Account` tables (land in Epic 6's schema but filled here); pg-boss scheduled job `session-cleanup` in Epic 8 runs daily to delete expired sessions.
- **S2 step-up middleware**: `packages/core/auth/step-up.ts` exports `requireRecentAuth({ maxAge: '5m' })` tRPC middleware; checks session `lastActivity` + `mfaVerifiedAt`; on expiry returns `TRPCError({code: 'UNAUTHORIZED', message: 'STEP_UP_REQUIRED'})`; client catches, redirects to re-auth flow. Applied to billing routes (Epic 10) + tenant-admin routes.
- **A2 tRPC middleware stack order**: `openTelemetry` → `loggerContext` → `tenantGuard` → `requireAuth` → `requireRecentAuth` → handler. Middleware modules in `packages/contracts/src/middleware/`.
- **A3 error code enum** shipped here: `UNAUTHORIZED | FORBIDDEN | NOT_FOUND | BAD_REQUEST | INTERNAL_SERVER_ERROR | STEP_UP_REQUIRED | TENANT_MISMATCH`. Zod validation errors auto-map to `BAD_REQUEST`; messages are typed i18n keys (consumed from Epic 11).
- **FR54 signup**: email+password + Google OAuth flows; signup tRPC mutation enqueues `email.send_verification` job (Epic 8) after user creation.
- **FR55 email verification**: verify token persisted in DB (single-use, 24h TTL); verification route consumes token and flips `user.email_verified_at`.
- **Password reset flow** (scope per user request + PRD baseline reset template): `/reset-password` route takes email, enqueues `email.send_reset_password` job from Epic 8, returns 204 regardless of user existence (no email-enumeration vector); `/reset-password/confirm` route takes token + new password, validates, updates session. better-auth password-reset primitive wired; UI lands here (signup/login/verify/reset screens) using Epic 7 primitives. Management UI (audit log, session list) lives in Epic 12.
- **FR57 DB-backed sessions + revocation**: session cookie + DB row; revocation via `Session.revokedAt` column; `requireAuth` middleware rejects revoked sessions. NFR12 — stateless-JWT is Tier-2 deviation only.
- **FR58 step-up for sensitive actions**: UI prompt surfaces in sensitive mutations (billing cancel, account deletion, team owner transfer); re-auth via password or step-up factor.
- **FR59 log out all sessions**: tRPC mutation sets `Session.revokedAt = now()` for all sessions of `user.id`.
- **NFR25 OAuth PKCE + state**: `packages/core/auth/google-oauth.ts` enforces PKCE + state-parameter verification to prevent authorization-code injection.
- **Minimal auth UI** (signup/login/verify-email/verify-expired/reset-password) lands in `apps/web/app/routes/{signup,login,verify,reset-password}.tsx` using Epic 7 primitives (`ui.form.01`, `ui.form-field.01`, `ui.button.01`, `ui.input.text.01`). Screen templates vendored from `packages/ui/src/templates/shared/` (from Epic 7's catalog).
- **Catalog-ID citation** (UX-DR63) in every route header: `/* catalog: ui.screen.signup.01 */`.
- **Accessibility checks** per UX-DR32-44 apply: axe-core critical = 0; Playwright keyboard traversal; 48-combo snapshot matrix (360/768/1280 × LTR/RTL × light/dark).
- **Audit events on auth actions** (via Epic 8): `user.signed_up`, `user.logged_in`, `session.revoked`, `password.reset_requested`, `password.reset_completed`.

**Standalone delivery:** End users can complete the full auth loop — signup, verify, login, step-up, password reset, logout all — on either shape. UI is minimal but a11y-compliant + i18n-keyed.

---

### Epic 10: Commerce (Paddle billing)

**User outcome:** End users subscribe to a paid plan via Paddle on either shape (B2B team-seats or B2C individual-subscription). Webhooks are signature-verified + idempotent. Subscription-gated access enforced. Lifecycle events (creation, cancellation, dunning, upgrade, downgrade) flow cleanly.

**FRs covered:** FR60, FR61, FR62, FR63.

**NFRs / Implementation notes:**

- **`packages/billing/`** is the load-bearing substrate package for this epic.
- **FR60 Paddle hardwired** with two shape-specific preset configs: `packages/billing/presets/team-seats.ts` (B2B: per-seat pricing, team-owner billing contact) + `packages/billing/presets/individual-subscription.ts` (B2C: single-user pricing). Presets selected via `keel.config.ts → shape`.
- **Paddle-hosted checkout**: Keel does not author checkout UI; redirects to Paddle-hosted flow. Confirmation + cancel pages live in `apps/web/app/routes/billing.{index,cancel,portal}.tsx` using Epic 7 primitives.
- **FR61 Paddle webhooks**: `apps/web/app/routes/webhooks.paddle.ts` is the external HTTP surface (one of three non-tRPC surfaces along with OAuth callback and tRPC mount). Handler validates signature via Paddle official SDK `verifyWebhookSignature()` (A4).
- **A4 idempotency via `webhook_events` table**: `PK (provider, event_id)` unique; replay is a no-op. Migration lands in Epic 6's schema.
- **Lifecycle handlers** in `packages/billing/lifecycle/`: `subscription.ts` (create/cancel/upgrade/downgrade/dunning), `webhook-events.ts` (idempotency layer).
- **NFR22 idempotent webhooks** + **NFR23 signature verification** — non-negotiable; unsigned or mis-signed webhooks rejected with 400.
- **FR62 subscription-gated access**: middleware in `packages/billing/src/middleware/require-subscription.ts`; premium capabilities check subscription state from DB. Usage-quota-gated access deferred to API-first shape in 1.2.
- **FR63 Growth-tier second billing provider**: thin adapter + migration guide for Stripe standard (API-first) or Stripe Connect (marketplace) when a real product forces it. At 1.0 Paddle is single hardwired impl.
- **Subscription-cancel UI** requires step-up auth (Epic 9 S2): tRPC middleware `requireRecentAuth({maxAge: '5m'})` applied.
- **OTel spans + audit events** on every lifecycle transition (via Epic 8 + Epic 11 observability): `subscription.created`, `subscription.cancelled`, `subscription.upgraded`, etc.
- **Testing**: webhook signature-verification contract tests at pre-merge-fast (deterministic, with recorded fixtures; no live-network hits); shape × tenancy matrix runs billing smoke in nightly (2×2 at 1.0 with Paddle hardwired per shape); **release-gated** (manual, Epic 13) runs the paid Paddle sandbox subscription end-to-end on both shapes.
- Management UI for team-seat assignment (B2B) + billing-history table lives in Epic 12 (Scaffolded Screens).

**Standalone delivery:** End user can subscribe, webhook lifecycle works idempotently, gated routes enforce subscription state. Billing UI is minimal (confirmation + cancel pages); team-seat management UI lands in Epic 12.

---

### Epic 11: Observability, Feature Flags & i18n Framework

**User outcome:** Every request is OpenTelemetry-traced correlated by request ID; developers evaluate server-side feature flags in route loaders; all user-facing content is typed i18n keys (bare strings fail build); end users select their locale and get correct RTL rendering without component rewrites.

**FRs covered:** FR21, FR22, FR24, FR25, FR26, FR27, FR64.

**NFRs / Implementation notes:**

- **Observability (FR22, NFR32)**:
  - `packages/core/otel.ts` — OTel SDK init; console-exporter default when `OTEL_EXPORTER_OTLP_ENDPOINT` unset (prevents network errors in dogfood/CI); OTLP exporter when set.
  - Sampling: 100% for errors, 10% for non-error traces in production forks (override via `packages/config`).
  - `packages/contracts/middleware/opentelemetry.ts` — A2 middleware step [0]; traces all downstream middleware + handlers.
  - Span naming: `<package>.<operation>` (`trpc.team.invite.create`, `db.user.findMany`, `job.email.send_verification`).
  - Attribute keys: `keel.<namespace>.<attr>` (`keel.tenant.id`, `keel.shape`).
  - Exporter endpoint read from `keel.config.ts → otelExporter` at build time.
  - NFR32 (configurable sampling) — per-deploy via `packages/config`.
- **Feature flags (FR21, F3)**:
  - `packages/flags/evaluator.ts` — server-side evaluation; flag source at 1.0 is static code + env var override.
  - `packages/flags/loader-scope.ts` — TanStack Router `loader` integration; flags evaluated at SSR time.
  - No client-side flag flickering; route-loader-scoped evaluation.
- **i18n framework (FR24, FR25, FR26, FR27)**:
  - `apps/web/app/i18n/en.ts` — English baseline locale (full).
  - `apps/web/app/i18n/messages.generated.ts` — typed keys codegen output from baseline.
  - Typed key enumeration enforced via TypeScript: bare strings in `.tsx` fail build (FR27).
  - Key path format: dot-separated `<domain>.<surface>.<key>` (`auth.signup.title`, `billing.checkout.confirm_button`).
  - `Accept-Language` header detection with user-preference override persisted in session (FR25).
  - `<html lang="{BCP-47}">` + `<html dir="rtl">` server-rendered from active locale.
  - Logical CSS properties only (NFR21 — enforced by ESLint rule in Epic 7; RTL tested here via scaffolded `ar.json`).
  - `Intl.NumberFormat` / `Intl.DateTimeFormat` for all date/number rendering.
- **Baseline locales** (FR26 + UX-DR49): `en.json` (full English); `ar.json` (scaffolded empty, RTL test); `de.json` (scaffolded empty, LTR test). Additional locales added by scaffolding empty translation files in fork.
- **End-user locale selection (FR64)**: persists in DB under `user.locale_preference`; consumed on every request; locale selector UI (`ui.screen.locale.01`) chrome lands in Epic 12.
- **i18n-key parity check at pre-commit** (UX-DR56): every locale has keys present in baseline English.
- **Translator notes** embedded as JSON-schema comments on non-trivial keys.
- **Never concatenate keys at runtime**: interpolation params only (`t('billing.receipt.total', { amount: formatted })`).
- **tRPC error messages** (Epic 9 A3) use typed i18n keys end-to-end (`error.auth.step_up_required`).
- **Catalog-ID citation** (UX-DR63) for any UI component authored here (e.g., locale setter affordances).

**Standalone delivery:** Every request traced; feature flags evaluate server-side; authors reference i18n keys for all text; CI fails on bare strings. Locale persistence backend works; UI selector chrome lives in Epic 12.

---

### Epic 12: Scaffolded Management & Onboarding Screens

**User outcome:** End users complete onboarding flows (team or individual), manage teams + invites (B2B), manage profile (B2C), view session list + audit log, select locale, navigate via responsive app shell — all via pre-built scaffolded screens that agent-authored compositions extend.

**FRs covered:** FR56.

**NFRs / Implementation notes:**

- **Composition epic**: every screen here composes Epic 7 primitives + Epic 9 auth context + Epic 10 billing state + Epic 11 i18n keys + data from `packages/db`.
- **Shape-aware template resolution (UX-DR22, UX-DR65)** at build time (not runtime branching): routes under `apps/web/app/routes/*.tsx` import shims from `packages/ui/src/templates/_${shape}/*`; keel-generator (Epic 5) resolves active shape. ESLint rule forbids cross-shape template imports. No `if (shape === 'b2b')` in product code.
- **Shared screen templates** in `packages/ui/src/templates/shared/`:
  - `audit-log.tsx` (audit event viewer with filter + pagination; tied to Epic 8's audit log)
  - `billing.tsx` (billing entry + history + cancel)
  - `sessions.tsx` (session list with "revoke" per row — hits FR57+FR59)
  - `locale.tsx` (locale selector UI chrome — hits FR64)
  - `settings-shell.tsx` (settings section container with nested tabs per UX-DR29)
  - `app-shell.tsx` (responsive sidebar + main + topbar; invokes `ui.app-shell.01`)
- **B2B screens** in `packages/ui/src/templates/_b2b/`:
  - `onboarding-team.tsx` (create team or accept invite post-signup)
  - `team-members.tsx` (team roster with role dropdown + remove action)
  - `team-invite.tsx` (single email + role dropdown; FR56 invite flow; enqueues `email.send_invite` from Epic 8)
  - `billing-team-seats.tsx` (team-seat count + per-seat usage)
- **B2C screens** in `packages/ui/src/templates/_b2c/`:
  - `onboarding-profile.tsx` (name + locale setup)
  - `profile.tsx` (personal profile management)
  - `billing-individual.tsx` (individual plan management)
- **Route files** in `apps/web/app/routes/`: thin shims importing from shape-partitioned templates. Every file carries `/* catalog: ui.screen.<name>.01 */` citation header.
- **FR56 team CRUD** (B2B): create team, join team via invite link, leave team, transfer ownership; all gated by step-up auth (Epic 9 S2) for sensitive operations; OTel-traced; audit-event-logged via Epic 8.
- **FR56 individual profile** (B2C): profile edit, display name, avatar (if present), locale preference.
- **Accessibility** (UX-DR32-44): every screen passes axe-core critical = 0; Playwright keyboard traversal; 48-combo snapshot matrix (360/768/1280 × LTR/RTL × light/dark); skip link in `ui.app-shell.01`; error prevention via confirm Dialog on destructive actions.
- **Shape-aware nav** (UX-DR29): B2B exposes Dashboard · Team · Billing · Settings; B2C exposes Dashboard · Profile · Billing · Settings. Nav derived at build time from active shape template; product code never branches on shape.
- **Responsive** (UX-DR13/14): mobile-first; sidebar → `ui.drawer.01` under md; tables horizontal-scroll below md; touch targets 44×44 min.
- **Zustand posture** (F4) enforced: client ephemeral only; `sessionStorage` default; `localStorage` only with rationale; never persist tenant/billing/auth.
- **UX-DR67 12-rule authoring checklist** applies to every screen authored here.

**Standalone delivery:** A forker running `create-keel-app` + editing `keel.config.ts` shape gets a fully-composed SaaS UI with management screens, onboarding, settings, audit log viewer — all responsive, a11y-compliant, i18n-keyed.

---

### Epic 13: Decomposed CI Pyramid & Quality Gates

**User outcome:** Every commit (agent or human) hits the 5-tier gate pyramid (pre-commit ≤10s / pre-merge-fast ≤3min / pre-merge-slow ≤10min / nightly ≤60min / release-gated). Path-based gate-profile routing separates substrate from product territory. Shape × tenancy matrix exercises both 1.0 shapes in nightly. CI minute budgets are empirically honest (modelled at 1.0, baselined at M10).

**FRs covered:** FR29, FR30, FR53.

**NFRs / Implementation notes:**

- **GitHub Actions workflows** in `.github/workflows/`:
  - `pre-merge-fast.yml` — ≤3min deterministic; typecheck + generator idempotency + RLS pglite unit + webhook contract tests + manifest sync. Zero external secrets per I6.
  - `pre-merge-slow.yml` — ≤10min; RLS testcontainers integration + shape-matrix smoke + migrations. Ephemeral-pg DSN only.
  - `nightly.yml` — ≤60min; full shape × tenancy combinatoric (2×2=4 cells); Paddle sandbox + Google OAuth live-network hits quarantined here; E2E Playwright (48-combo snapshot matrix per scaffolded screen from Epic 12 runs here); pa11y; RLS performance benchmark D4; RC3 `pnpm research:aggregate` (Epic 14).
  - `release-gated.yml` — manual trigger; full `git clone → shape-edit → signup → paid Paddle sandbox subscription → teardown` on both shapes; production adjacents.
  - `release-please.yml` — release-please PR/tag automation (config owned by Epic 1; execution wired here).
  - `path-profile.yml` — FR53 path-based gate-profile router: `packages/**/*` (full pyramid including nightly shape × tenancy), `apps/web/features/**/*` (pre-merge-fast + pre-merge-slow only), `docs/**/*` (pre-commit + pre-merge-fast only), `_bmad-output/**/*` (pre-commit + pre-merge-fast only).
- **Matrix strategy**: nightly workflow uses GH Actions matrix for `shape × tenancy` = {b2b×team, b2c×user}. Growth-tier expansion to N×M cells deferred per PRD validation-polish items.
- **NFR1 wall-clock budgets** — enforced as workflow timeouts; any tier exceeding budget fails the build.
- **NFR28 flake-rate budgets**: pre-merge-fast + pre-merge-slow must be deterministic (> 0.1% flake over 30d triggers CI-hardening); nightly tolerates ≤ 2%. Flake data feeds R6 reporter (Epic 14).
- **NFR28b empirical-baseline honesty reframe**: at 1.0 (M9), budgets are **modelled targets** labelled as such in workflow comments + `docs/invariants/ci-budgets.md`. At M10 (or first 2-week real-traffic window), re-baseline against empirical p95 via amendment PR. Final budget = `max(stated-target, ceil(p95 × 1.25))`.
- **NFR28c monthly CI-budget review**: tier exceeding budget on p95 for two consecutive months triggers mandatory amendment PR (re-baseline with documented cause or split tier). Amendment is routine, not exceptional.
- **FR29 pre-merge gates**: full unit + integration tests + RLS policy tests + import boundaries (via `@keel/<pkg>` enforcement from Epic 1) + dep audit (Dependabot + `pnpm audit`).
- **FR30 release-gated tier**: manual-triggered; exercises `create-keel-app` → shape-edit → full signup → paid Paddle sandbox subscription → teardown on both shapes. Non-toggle-able. Red gate = broken repo.
- **Security scanners run at pre-commit** (from Epic 4) — Gitleaks + Semgrep + prompt-injection regex; severity blocking per FR36.
- **Design-system checks** (UX-DR52-55) wired here: axe-core per screen at pre-merge-fast; Playwright snapshot matrix at nightly; Lighthouse CI per PR (a11y ≥ 95); pa11y nightly on release-gated.
- **[V2 party-mode amendment] Screenshot matrix scope at 1.0 = 18 combos** (not 48): 360/768/1280 × LTR/RTL × **light only**. RTL kept non-negotiable (Sally: "the irreversible one" — logical-property discipline across ~40 files). Dark tokens + class-toggle still ship at 1.0 as invariants; dark VISUAL verification (screenshot matrix) deferred to 1.1. Full 48-combo matrix returns in 1.1.
- **[M4 party-mode amendment] Explicit story: "Nightly UX-matrix budget envelope"** — defines sharding strategy, per-screen time budget, axis-collapse policy (which axes degrade first when budget pressure hits: candidate = drop shape × tenancy duplication for pure-visual checks, keep it for interaction flows). Prevents the Sprint-3 budget-bust Murat flagged.
- **[W2 party-mode amendment] CI-workflow wiring for Epic 1 sync-gate tooling**: this epic extends Epic 1's manifest-reader + anchor-walker + drift-detector by running them in `.github/workflows/pre-merge-fast.yml` as required checks. Epic 1 ships the runtime; Epic 13 wires it to CI. FR43 teeth from day 1 instead of day 22.
- **[RS5 party-mode amendment Round 2] Ralph safe-set bootstrap-validation wiring** (from Epic 3 amendment): path-filtered job in `.github/workflows/pre-merge-slow.yml`. Path filter triggers on PR touching: `packages/ralph/**`, `packages/keel-templates/**`, `.ralph/PROMPT_*.md`, `packages/keel-invariants/src/schemas/{halt,plan}.schema.json`, or `packages/devbox/ralph-version.json`. When triggered, runs:
  - (a) `.ralph-safe-set.yaml` manifest validation (paths categorised correctly; layer boundaries intact);
  - (b) L2 schema-parse check (prompt templates + plan/halt schemas parse cleanly);
  - (c) L2 minimum smoke iteration (30s synthetic iteration against fixture `@plan.md`; asserts first tool call is `Read`/`Bash`; asserts expected halt reason).
  - Failure mode: PR blocked; halt with `RALPH_STAGE_REGRESSION` reason surfaces in TUI. Tthew reviews.
  - Stage-upgrade stories (L1 `packages/ralph/` version bump) ALSO trigger this workflow plus an explicit `ralph-stage-upgrade.yml` workflow that re-installs the snapshot in an ephemeral devbox and re-runs the smoke iteration from the NEW stage.
  - Runtime budget: ≤ 8 min within pre-merge-slow's ≤ 10 min envelope. Full structural-invariants oracle (Murat) deferred to 1.1 — this is schema-parse + smoke only at 1.0 per RS4 + RS10.
- **`tools/check-safe-set.ts` pre-commit hook** (owned jointly with Epic 3 which authors it; wired at pre-commit tier here): diffs staged paths against `.ralph-safe-set.yaml`; rejects L1 violations without `ralph-stage-upgrade` commit scope; routes L2 edits to bootstrap-validation flag; allows L3 with lint gate.
- **Token-drift sync gate** (UX-DR6) + **invariants manifest sync gate** (FR43) + **keel.config.ts sync gate** (FR68) all run at pre-merge-fast.
- **NFR27 fail-closed**: any gate unreachable or misconfigured rejects commit/PR/deploy. No silent-success mode.
- **NFR28a worktree retention**: CI runs never remove `.claude/worktrees/`; enforced by workflow contract.
- **FR53 path-based CI**: substrate (`packages/**/*`) commits get full pyramid including nightly matrix; product (`apps/web/features/**/*`) commits get pre-merge-fast + pre-merge-slow only; docs get minimal gates.
- **`docs/invariants/ci-budgets.md`** — modelled-vs-empirical budget provenance; amendment PR template.
- **CI caching via Turborepo** content-hash + GH Actions cache.
- **`.github/CODEOWNERS` + PR templates** (minimal at N=1; required for any future contributor fork).

**Standalone delivery:** Every commit hits equivalent gates; CI catches regression across all substrate concerns (tests, RLS, tokens, manifest, prompt-injection, type-check, i18n-keys); minute budgets documented honestly.

---

### Epic 14: Research Corpus & Measurement Infrastructure

**User outcome:** Every model-generation's substrate-delta is captured as machine-readable research corpus (sprint logs, checkpoint decisions, tripwire verdicts, flake curves). Research output survives substrate absorption as first-class deliverable; aggregation produces a consumable `corpus.jsonl` suitable for future LLM context or published dataset.

**FRs covered:** FR33.

**NFRs / Implementation notes:**

- **RC1 corpus layout** at `docs/research/` (append-only):
  - `sprint-logs/YYYY-MM.{md,json}` — monthly blank-starter-sprint entries
  - `checkpoints/YYYY-Q#.{md,json}` — quarterly M4 checkpoint entries (absorbs `docs/checkpoints/`)
  - `tripwire/YYYY-MM.{md,json}` — monthly aggregated tripwire verdicts
  - `README.md` — index, schema pointers, aggregation guidance, citation conventions
  - `test-ids.md` — C4 append-only test-ID ledger (`T-0001..T-NNNN`, never reused)
  - `corpus.jsonl` — RC3 aggregated output (regenerated nightly)
- **Amendment ceremony** (per vertical-slice-acceptance pattern): PR + rationale in file's own changelog + 24h cooling-off between PR open and merge. Measurement integrity resists "post-hoc editing to protect the project when the tripwire fires."
- **RC2 typed schemas** at `packages/keel-invariants/src/schemas/`:
  - `sprint-log.schema.json` — `{month, slice_id, model_version, keel_ttg_seconds, blank_ttg_seconds, keel_tokens_total, blank_tokens_total, keel_context_exhausted_count, blank_context_exhausted_count, keel_rework_rate, blank_rework_rate, delta_percent, notes}`
  - `checkpoint.schema.json` — `{quarter, date, decision_enum: continue|pause_and_ship|pivot|archive, evidence_paths[], next_evaluation_date, rationale}`
  - `tripwire.schema.json` — `{month, verdict_enum: pass|warn|breach, source_sprint_log_id, consecutive_breach_count, pivot_recommended, raw_datapoints[]}`
  - `flake-log.schema.json` (R6) — `{test_id, iteration_id, outcome: pass|fail|skip, duration_ms, attempt_number, timestamp}`
  - All schemas versioned via `$schema`.
- **FR33 M4 checkpoint markdown**: committed artefacts in `docs/research/checkpoints/` with matching JSON per schema. Governance trigger (recurring quarterly post-1.0) + markdown + JSON = governance + research artefact both.
- **R5 headless Ralph --no-tui** (promoted from Growth-tier to M0/M1 per architecture):
  - Flag `ralph.py --no-tui` suppresses Textual UI
  - Writes structured JSON to `.ralph/logs/<iter-id>/` + concluding summary line to stdout
  - Known exit code signals outcome
  - Use cases: monthly blank-starter-sprint runs (tripwire harness); scheduled GH Actions or cron-driven sprint re-runs; reproducible RC3 aggregation
  - Output contract: structured JSON matching RC2 sprint-log schema emitted to `docs/research/sprint-logs/YYYY-MM.json` on completion; stdout summary includes a single JSON line for shell-pipe consumption
- **R6 flake measurement layer**:
  - Per-test outcome logging at `.ralph/flake-log/YYYY-MM/<date>.jsonl`
  - Vitest custom reporter at `packages/keel-invariants/src/flake-reporter.ts` — emits same JSON shape whether invoked locally or in CI
  - GH Actions workflow hook in Epic 13 workflows emits equivalent JSON
  - Measurement ships at 1.0; enforcement (quarantine policy, 7-day p95 pass-rate thresholds, PR-fail gates) deferred to M10 or first empirical breach (requires ≥500 iterations for statistical meaning)
- **RC3 aggregation tooling**:
  - `packages/keel-invariants/src/research-aggregate.ts`
  - `pnpm research:aggregate` CLI — reads `docs/research/**/*.json`, validates against RC2 schemas, emits flattened `docs/research/corpus.jsonl`
  - Idempotent + deterministic (same canonical-form discipline as generator G4)
  - Runs as nightly CI step (Epic 13); stale aggregate is a pre-merge-fast warning (not fail — corpus is authoritative source)
- **C4 test-ID stability convention**:
  - Every test uses explicit IDs matching `^T-\d{4}$` in test title: `test('T-0042: inviteWithVerification_creates_token', ...)`
  - Manifest (R2 from Epic 3) keys on `T-\d{4}` only; human description can change freely
  - IDs allocated from monotonically-increasing counter in `docs/research/test-ids.md` (append-only, never reused)
  - Enforced via ESLint `keel/stable-test-id` rule at pre-commit — rule module at `packages/keel-invariants/eslint-rules/stable-test-id.cjs`
- **Monthly blank-starter-sprint harness**:
  - 2-hour timebox; current frontier model; vanilla starter (Next.js + Supabase + Vercel, fresh `pnpm create`) + Keel's invariant manifest as context
  - Build same vertical slice both ways, same time budget; log tokens, context-window exhaustion, rework rate, wall-clock time-to-green
  - Pre-registered acceptance criteria at `docs/absorption-tripwire/vertical-slice-acceptance.md` (already scaffolded); committed before first sprint runs
  - Named owner: Tthew (N=1); amendments require PR review against prior entry with rationale + 24h cooling-off
  - Falsification threshold: blank-starter TTG within 20% of Keel TTG for two consecutive months triggers pivot to Invariant Pack (Epic 15b contingency)
  - **[V4 party-mode amendment] Skip-trigger tripwire condition**: pre-register monthly sprint dates in `docs/research/sprint-logs/schedule.md` (first sprint ~M1; monthly cadence). **Two consecutive skipped sprints = absorption by default → pivot to Invariant Pack within 30 days.** Unused measurement is worse than no measurement; this closes the "discipline Tthew doesn't have" failure mode Victor flagged. **PRD clarification raised**: add this skip-trigger to PRD § Business Success → Absorption-tripwire. Skip-detection tooling: a pre-merge-fast check that reads `schedule.md` + `sprint-logs/`; if two consecutive months past due, emit a warning; if three, fail the build (forcing Tthew to either run the sprint or document the absorption verdict).
- **[M3 party-mode amendment] Explicit story: "Flake-log schema freeze"** jointly owned with Epic 13 emitters. Epic 14 freezes `flake-log.schema.json` (`{test_id, iteration_id, outcome, duration_ms, attempt_number, timestamp}`); Epic 13's Vitest reporter + GH Actions workflow emit records matching this schema. Single dependency edge collapses the risk of flake data being "noise for two sprints" while the producer/consumer seam firms up.
- **Dark-mode visual verification lands here at 1.1 (not Epic 13 nightly at 1.0)**: dark tokens + class-toggle ship at 1.0 per Epic 1 (substrate invariant); visual regression matrix for dark mode is a Growth-tier research concern evaluated against corpus data — promoted from deferred to empirical once tripwire data + dogfood stability demonstrate value.
- **NFR29a per-major prompt-set pinning**: Ralph prompt templates (`.ralph/PROMPT_*.md` + `packages/keel-templates/PROMPT_*.template.md`) pinned to a specific model generation per major Keel version; minor versions inherit unchanged; majors may diverge with recorded delta in release notes.
- **NFR30 breaking-delta catalogue**: every Keel major documents tested model generation, Claude Code CLI version, BMad version, Ralph version. Breaking upstream model upgrade triggers major test-run. Delta catalogue maintained in PRD Domain-Specific Requirements § Model and Tooling Evolution.
- **Research output is first-class deliverable** per PRD dual-posture tie-breaker: survives substrate absorption; Invariant Pack pivot publishes corpus + principle layer to npm within 30 days of tripwire.

**Standalone delivery:** Every month produces a sprint-log entry; quarterly checkpoints commit markdown + JSON; flake data accumulates; aggregation emits consumable corpus. Research survives whether substrate lives or gets absorbed.

---

### Epic 15a: `create-keel-app` Bootstrap CLI (early — Tthew test-fork tool)

**[E15-split party-mode amendment]** Original Epic 15 split into early-landing `create-keel-app` (this epic) and late-landing 1.0-cut ritual + distribution policies (Epic 15b). Rationale (per Tthew answer #3): Tthew needs to fork Keel for downstream testing DURING development (not just at 1.0 cut), which means basic `create-keel-app` must land early — otherwise mid-build test-fork cycles use `git clone + manual strip` with friction.

**User outcome:** Tthew (and later any forker) runs `pnpm dlx create-keel-app <name>` during development and lands in a clean Keel fork ready for test-fork work in under 2 minutes. Non-interactive end-to-end; no wizard; no prompts.

**FRs covered:** FR47, FR51.

**Target timing:** lands near Epic 2–3 completion (alongside devbox + Ralph harness availability), not at M9.

**NFRs / Implementation notes:**

- **`create-keel-app/`** package at repo root (not under `packages/` because it's published to npm as `create-keel-app` for `pnpm dlx`):
  - `src/cli.ts` — non-interactive: git-clone latest substrate tag (or `main` for mid-build test forks), strip upstream planning artefacts, run `pnpm install`, commit first commit (`chore: bootstrap from keel@<ref>`)
  - `src/strip-planning.ts` — file-move logic (`_bmad-output/` → `docs/archive/`; empty `.ralph/@plan.md`; seed `.ralph/PROMPT_*.md` from `packages/keel-templates/`)
  - `README.md` — usage
- **FR47 bootstrap UX**: non-interactive end-to-end — no prompts, no wizard, reads no `stdin`. Exits with plain-text status + specific exit codes (2 = Docker missing; 3 = network failure; 4 = dir conflict; 5 = `pnpm install` failure). NFR34 (< 2 min wall-clock excluding devbox cold-start).
- **FR51 state wipe on fork-scaffolding**: strip `_bmad-output/` → `docs/archive/keel-<ref>-planning/`; empty `.ralph/@plan.md`; seed `.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md` from `packages/keel-templates/` (source templates authored in Epic 3).
- **`packages/keel-templates/`** package (authored in Epic 3, consumed here):
  - `src/PROMPT_build.template.md` — seed for `.ralph/PROMPT_build.md` on fresh forks
  - `src/PROMPT_plan.template.md` — seed for `.ralph/PROMPT_plan.md`
  - Contents codify Epic 3's orient/execute/gate contracts + PR-lifecycle matrix + halt schema + knowledge-file upkeep + Opus 4.7 prompt conventions
- **Mid-build test-fork mode**: `pnpm dlx create-keel-app <name> --from=<branch|tag|sha>` allows Tthew to spin up test forks from any ref during development; strips planning artefacts to the same target so the new fork is clean. This is the "Tthew's test-fork tool" user-outcome.
- **Integration test (pre-merge-slow, Epic 13)**: `create-keel-app` smoke test — `pnpm dlx create-keel-app /tmp/test-fork-<uuid> --from=HEAD → cd /tmp/test-fork-<uuid> → pnpm devbox:start → pnpm test` green end-to-end on both shapes.

**Standalone delivery:** Tthew runs `pnpm dlx create-keel-app test-product-idea --from=main` during mid-build, gets a clean fork, validates a speculative product idea in ~10 minutes without polluting the main Keel workspace. Major-version cut automation + correlated-library policy + Invariant Pack pivot are Epic 15b's scope.

---

### Epic 15b: Fork Lifecycle Discipline & Distribution Policies (late — pre-1.0-cut)

**User outcome:** Major-version cuts document tested model + tooling combinations. Planning artefacts archive cleanly. Correlated-library maintenance signals are monitored. Ralph-fork monthly upstream diff keeps Keel current. Invariant Pack pivot contingency is pre-committed and ready within 30 days of tripwire firing.

**FRs covered:** FR49, FR50, FR52.

**Target timing:** lands pre-1.0-cut (late M9 / M10 window).

**NFRs / Implementation notes:**

- **FR52 archive on major cut**: ritual at `v1.0.0` tag cut:
  1. Move `_bmad-output/*` to `docs/archive/keel-1.0-planning/`
  2. Retire standalone `cc-devbox` on `legacy-devbox` branch; `packages/devbox/` is canonical
  3. Empty `apps/web/features/*` (Launchpad seed only)
  4. Seed `packages/keel-templates/PROMPT_*.template.md` from current `.ralph/PROMPT_*.md`
  5. Tag `v1.0.0` on substrate
  - Automation in `scripts/major-cut.sh` (checkpointed + reviewed before run).
- **FR50 major-version cut discipline**: every major documents tested model generation (e.g., Opus 4.7), Claude Code CLI version, BMad version, Ralph version. Breaking upstream model upgrade triggers a new major test-run. Documented in `docs/upgrades/major-releases.md` + release notes.
- **FR49 Growth-tier migration guides**: `docs/upgrades/` placeholder scaffolded at 1.0; empty because no second-impl axes exist. When a second implementation (e.g., Next.js alongside TanStack Start) enters Growth-tier, its migration guide lands here with codemod + manual steps + CI-tested migration path.
- **Correlated-library maintenance-signal check** (PRD Domain-Specific § Correlated-Library Risk Policy): quarterly review of hardwired libraries (TanStack Start, better-auth at 1.0); demotion threshold (no release in 6 months OR security advisory unpatched > 14 days OR maintainer abandonment signal) triggers next-major replacement. Documented in `docs/upgrades/correlated-library-policy.md`.
- **Ralph monthly upstream diff review**: maintainer-only concern per `ralphDisposition: fork` frontmatter. Workflow documented in `docs/upgrades/ralph-upstream-review.md`. Invisible to forkers in "development with Keel" mode.
- **Invariant Pack pivot contingency** (if absorption tripwire fires per Epic 14 skip-trigger OR 20%-delta-two-months condition):
  - Pre-committed exit: within 30 days of tripwire, publish `packages/keel-invariants/` + research corpus principle layer to npm as versioned Invariant Pack
  - Release-please monorepo reconfiguration deferred; 30-day clock is enough to configure live
  - This epic owns the release-config readiness sketch in `docs/upgrades/invariant-pack-pivot.md`
- **Release-please-monorepo config** (single-bundled release mode at 1.0; per-package mode deferred to if/when Invariant Pack pivots): config in `release-please-config.json` + manifest in `.github/release-please-manifest.json` (scaffold in Epic 1; activation + cut discipline here).
- **No `npm publish` of individual substrate packages at 1.0** per PRD Distribution policy. Fork-and-use only. Exception: Invariant Pack (if tripwire fires) publishes to npm.
- **Per-Keel-major tested-model-generation release notes template** at `.github/PULL_REQUEST_TEMPLATE/major-release.md`.

**Standalone delivery:** 1.0 cut ritual automation ready when `v1.0.0` is tagged; correlated-library monitoring cadence established; Invariant Pack pivot can execute in 30 days if tripwire fires.

---

## Epic-to-Milestone Mapping

PRD milestones map to epics as follows (milestones are execution sequence; epics are user-value deliverables):

| Milestone | Primary epic(s) | Secondary (cross-cutting) |
|-----------|-----------------|---------------------------|
| M0 (Repo foundation & tooling, 2d) | Epic 1 (incl. **design tokens + contract + emitter pipeline** per W1; **sync-gate runtime tooling** per W2); Epic 3 scaffolds `.ralph-safe-set.yaml` + check-safe-set hook per RS7 | Epic 14 (RC1 corpus layout + research schemas + test-ID ledger + `--no-tui` flag plumbing scaffold) |
| M0.5 (Devbox, 3d) | Epic 2 (incl. `uv tool install --from packages/ralph ralph-harness==<pin>` install-boundary snapshot per RS2) | Epic 3 (`packages/ralph/` package scaffold, legacy-devbox branch retention), Epic 15a (create-keel-app scaffolded against devbox) |
| M0.7 (Tenancy-template generator, 2d) | Epic 5 (incl. **generated-migration contract artefact** per W3) | Epic 1 (manifest scaffolding) |
| M1 (Data model + RLS, 3d) | Epic 6 (asserts against Epic 5's generated-migration contract per W3) | Epic 14 (first empirical sprint-log entry + first scheduled monthly sprint per V4 skip-trigger) |
| M1–M2 transition | Epic 15a (create-keel-app lands early for Tthew test-fork cycles during M2–M7 feature work) | — |
| M2 (Auth & Identity, 3d) | Epic 9 (incl. password reset flow via Resend email from Epic 8) | Epic 7 (design-system primitives + patterns must be ready) |
| M3 (Billing, 3d) | Epic 10 | — |
| M4 (Email + Jobs, 2d) | Epic 8 | — |
| M5 (Observability + Audit, 2d) | Epic 11 (OTel part) + Epic 8 (audit) | — |
| M6 (Feature flags, 1d) | Epic 11 | — |
| M7 (Frontend patterns + UI, 3d) | Epic 7 (components + patterns) + Epic 12 (scaffolded screens) | Epic 11 (i18n framework + baseline locales) |
| M9 (Testing & CI hardening, 4d) | Epic 13 (incl. **18-combo matrix**, **UX-matrix budget envelope** per M4, **sync-gate CI wiring** per W2, **Ralph bootstrap-validation path-filtered workflow** per RS5) | Epic 4 (security scanners + **S3 contract-v1 story** per M2 wired), Epic 14 (**flake-schema freeze** per M3, research aggregation CLI), Epic 11 (token audit), Epic 15b (major-cut readiness) |
| M10 (post-1.0 window) | Epic 13 (CI empirical baseline per NFR28b) + Epic 14 (flake enforcement if data warrants; dark-mode visual verification if empirical value demonstrates) | Mutation testing enforcement epic (per M1 deferred-enforcement) |

Ralph harness (Epic 3) is non-milestoned — absorbed from current ralph-bmad repo at M0 and evolves through every subsequent milestone's stories.

**Epic 15a** (`create-keel-app` + fork-scaffolding-state-wipe) lands early near M0.5–M1 as Tthew's mid-build test-fork tool. **Epic 15b** (1.0-cut ritual + correlated-library policy + Ralph upstream diff + Invariant Pack pivot readiness) lands late at M9 pre-1.0-cut.

## PRD / UX-Spec Clarifications Raised (to flag at workflow end)

1. **FR14a3 wording** — should explicitly split "contract at 1.0 (warn-mode)" from "threshold enforcement at 1.x (after NFR28b empirical baseline)". Per party-mode M1.
2. **Absorption-tripwire § Business Success** — add skip-trigger: "two consecutive skipped monthly sprints = absorption by default → pivot to Invariant Pack within 30 days." Per party-mode V4.
3. **Password reset flow** — currently implicit under FR54 + FR55 + PRD Implementation Considerations baseline templates ("verify, invite, **reset**"). Optional PRD clarification: add explicit FR54a for password reset, or leave as story-level scope under Epic 9.
4. **UX spec matrix scope** — full 48-combo matrix in UX-DR53 should be clarified to "18 combos at 1.0 (360/768/1280 × LTR/RTL × light); full 48 returns at 1.1 post-empirical-value-demonstration." Dark tokens + class-toggle ship at 1.0; dark VISUAL verification moves to 1.1 per party-mode V2.
5. **NEW FR14m — Ralph self-modification safe-set policy** (per party-mode Round 2 RS1/RS3/RS7): Agent can execute a three-layer safe-set policy (L1 install-boundary-snapshot runtime code / L2 auto-merge-on-bootstrap-validation-pass self-referential surface / L3 Ralph-editable lint-gated knowledge files) enforced via `.ralph-safe-set.yaml` + `tools/check-safe-set.ts` pre-commit hook + pre-merge-slow path-filtered bootstrap-validation. Ralph's orient phase (FR14f) reads the safe-set manifest so the agent is self-aware of its own safety boundary.
6. **NEW NFR — Ralph install-boundary snapshot** (per party-mode Round 2 RS2): Ralph harness runs from install-boundary-snapshot. `packages/ralph/` (monorepo package) installed as non-editable snapshot at devbox startup via `uv tool install --from packages/ralph ralph-harness==<pin>`; installed tool at `/home/dev/.local/share/uv/tools/ralph-harness/` (named Docker volume per NFR10); `packages/devbox/ralph-version.json` pins version + prompt-template content-hash. Source edits in `packages/ralph/` do not affect the current iteration. Stage-upgrade is a dedicated story class `ralph-stage-upgrade` that bumps the pin + triggers bootstrap-validation before stage-N+1 runs.
7. **Extend FR14k halt schema enum** (per party-mode Round 2 RS3 fail-mode): add `RALPH_STAGE_REGRESSION` to the closed halt-reason enum. Triggered when bootstrap-validation fails on an L2 edit; Tthew reviews via TUI. Updates `.ralph/halt` schema at `packages/keel-invariants/src/schemas/halt.schema.json`.
8. **Extend FR14j knowledge-file upkeep contract** (per party-mode Round 2 RS6): knowledge-file edits are Ralph-auto-editable under layer-3 lint guardrails (size caps, H1 protection, URL allowlist, no fenced `## SYSTEM` blocks, instruction-imperative detection). `.ralph/@plan.md` entries are append-only with per-entry content-hash (FR14a2 pattern); historical entries immutable.

## Select an Option

**[A] Advanced Elicitation** — deeper critique of epic structure (Socratic, first-principles, pre-mortem, red-team)
**[P] Party Mode** — another multi-agent roundtable on a specific topic
**[C] Continue** — proceed to Step 3 (story creation)
