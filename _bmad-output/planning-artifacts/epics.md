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
  - NEW NFR5a - Claude Code hooks + committed `.claude/settings.json` deny rules form a secret-access barrier inside the devbox (complement to NFR5 devbox isolation); barrier is non-toggle-able at config layer; the ONLY in-session defense when Ralph runs with --dangerously-skip-permissions since permissions layer is bypassed; forks can extend denylist but cannot weaken substrate
  - NEW NFR5b - Hook + settings bypass-resistance: the in-session hook self-protects by denying Edit/Write to `.claude/settings*.json`, `.claude/hooks/**`, `.git/hooks/**` and Bash mutations (rm/mv/chmod/tee/sed -i/echo >) against those paths; git-layer catches tampering via `INV-claude-hook-secret-denylist` content-hash in the invariants manifest (Story 1.8/1.9); S4 prompt-injection scan flags suspicious diffs touching hook/settings files; N hook-self-protection blocks per iteration (default N=3) trigger `SECURITY_CRITICAL` halt
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

#### Stories

##### Story 1.1: Monorepo scaffold + TypeScript project references

As a fork operator,
I want a hand-authored 14-package pnpm + Turborepo monorepo with working TypeScript project references,
So that `pnpm install` runs green, package builds are cacheable, and I have a typed substrate to extend.

**Acceptance Criteria:**

**Given** a fresh clone of the Keel repo,
**When** I run `pnpm install` from the root,
**Then** the install completes without errors
**And** workspace resolution finds `apps/web` and `packages/{db, contracts, config, core, billing, email, jobs, flags, audit, ui, keel-invariants, devbox, keel-generator, keel-templates}` + `create-keel-app`.

**Given** the scaffold,
**When** I inspect `pnpm-workspace.yaml`, `turbo.json`, and `tsconfig.base.json`,
**Then** each file is hand-authored (not emitted by `create-turbo`)
**And** `tsconfig.base.json` defines the `@keel/<pkg>` path alias for every workspace package
**And** each package has its own `tsconfig.json` extending the base with `composite: true` + `references` entries for its dependencies.

**Given** the project-references graph,
**When** I run `pnpm -w typecheck` (`tsc -b`),
**Then** the build succeeds and Turborepo caches the result
**And** a second invocation hits the cache with no rebuilds.

**Given** the file-structure invariants,
**When** a linter walks the tree,
**Then** sources live under `src/`, exports are `src/index.ts`-only, tests are colocated, and no top-level `__tests__/` exists
**And** naming obeys kebab-case files, PascalCase components, camelCase TS symbols, snake_case DB singular.

##### Story 1.2: `packages/keel-invariants` bootstrap + shared ESLint/Prettier/commitlint configs

As a fork operator,
I want a versioned `packages/keel-invariants/` package exporting shared ESLint (flat config), Prettier, and commitlint configurations,
So that every downstream package consumes one canonical ruleset and drift cannot hide (FR41).

**Acceptance Criteria:**

**Given** the scaffold from Story 1.1,
**When** `packages/keel-invariants/` is added with `package.json`, `src/index.ts`, and config exports (`eslint.config.keel-invariants.js`, `prettier.config.keel-invariants.js`, `commitlint.config.keel-invariants.js`),
**Then** the package publishes these configs under stable named subpath exports
**And** the `exports` field resolves each config.

**Given** the shared configs,
**When** another workspace package's `eslint.config.js` imports and extends `@keel/keel-invariants/eslint`,
**Then** lint runs use the shared rules
**And** removing the extension triggers the Story 1.6 bypass-prevention check.

**Given** the package is present,
**When** a developer runs `pnpm lint` at the root,
**Then** every package that extends the shared config passes lint against the canonical ruleset
**And** the lint config resolves in both ESM and TypeScript contexts.

##### Story 1.3: ESLint `no-restricted-imports` import-boundary rules

As a fork operator,
I want ESLint `no-restricted-imports` rules layered on the shared config that enforce `@keel/<pkg>`-only imports across package boundaries,
So that compile-time package boundaries cannot be violated by relative-path end-runs or `internal/*` imports (FR34).

**Acceptance Criteria:**

**Given** a file in `packages/<A>/src/` trying to import `../../<B>/src/foo`,
**When** `pnpm lint` runs,
**Then** ESLint reports `no-restricted-imports` with a message pointing to the `@keel/<B>` alias.

**Given** a file importing `@keel/<B>/internal/*`,
**When** `pnpm lint` runs,
**Then** ESLint rejects the import
**And** the rule message explains `internal/*` subpaths are forbidden across packages.

**Given** a file inside `packages/<A>/src/` importing `@keel/<A>/...` (self-import via alias),
**When** `pnpm lint` runs,
**Then** ESLint rejects the self-import with a "use relative path within same package" message.

**Given** rules run alongside TypeScript project references,
**When** both checks execute,
**Then** lint catches string-based violations and TS project-refs catch graph-level ones (belt-and-braces).

##### Story 1.4: Pre-commit quality gates via prek (type-check, lint, format)

As a fork operator,
I want prek-managed pre-commit hooks that run TypeScript type-check, ESLint, and Prettier on every commit,
So that no local commit lands with a type error, lint error, or unformatted file (FR28).

**Acceptance Criteria:**

**Given** a fresh clone and `pnpm install`,
**When** prek initialises hooks on the post-install step,
**Then** a pre-commit hook is registered that invokes `pnpm -w typecheck && pnpm -w lint && pnpm -w format:check` (or prek's orchestration of the same).

**Given** a file with a TS error staged,
**When** I run `git commit`,
**Then** the hook fails surfacing the typecheck error
**And** the commit does not land.

**Given** a file with an ESLint error staged,
**When** I run `git commit`,
**Then** the hook fails surfacing the lint error
**And** the commit does not land.

**Given** an unformatted file staged,
**When** I run `git commit`,
**Then** the hook fails surfacing the Prettier diff
**And** the commit does not land.

**Given** a clean commit,
**When** all three checks pass,
**Then** the commit lands normally and the hook exits zero.

##### Story 1.5: Conventional-commit enforcement via commitlint + prek

As a fork operator,
I want commitlint running via prek on every commit using the shared config from Story 1.2,
So that agent and human commits alike follow conventional-commit format — a non-negotiable substrate invariant (FR14).

**Acceptance Criteria:**

**Given** the prek stack from Story 1.4,
**When** a `commit-msg` hook invoking commitlint against `@keel/keel-invariants/commitlint` is registered,
**Then** commit messages are validated on every `git commit`.

**Given** a commit message `fix: resolve edge case in token emitter`,
**When** the hook runs,
**Then** commitlint accepts and the commit lands.

**Given** a commit message `Fixed stuff`,
**When** the hook runs,
**Then** commitlint rejects the message explaining the `<type>(<scope>): <subject>` convention
**And** the commit does not land.

**Given** a commit authored by Ralph (agent) vs. a human,
**When** each is created,
**Then** both pass or fail by the same rules — no agent bypass
**And** enforcement holds whether commits originate inside the devbox or on the host.

##### Story 1.6: Quality-gate bypass prevention

As a substrate maintainer,
I want a machine check that rejects any configuration change disabling or circumventing the prek quality gates,
So that a one-line config edit cannot turn off substrate teeth (FR32).

**Acceptance Criteria:**

**Given** the prek config in `packages/keel-invariants/`,
**When** a PR removes or disables any pre-commit or commit-msg hook,
**Then** the sync-gate (Story 1.9) detects the removal and fails pre-merge
**And** the PR cannot be merged without a source-level fork (i.e., an explicit `keel-invariants` package change with a manifest update).

**Given** a PR introduces `--no-verify` or similar bypass in any committed script,
**When** a lint rule in `keel-invariants` runs,
**Then** the rule flags the script and the lint gate fails.

**Given** a PR modifies `.husky/`, `.prek/`, or hook-installation directories to point away from the shared configs,
**When** pre-merge runs,
**Then** the deviation is detected via the manifest
**And** the PR is rejected with a message naming the removed/edited invariant.

**Given** Tthew explicitly forks a substrate invariant,
**When** they change `keel-invariants` source and update `invariants.manifest.ts` + `INVARIANTS.md` together,
**Then** the sync gate passes — this is the intended "source-level fork" path.

##### Story 1.7: Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules

As any AI agent or human contributor working on Keel,
I want four audience-scoped markdown files at the repo root — `INVARIANTS.md`, `AGENTS.md`, `CLAUDE.md`, `RALPH.md` — each with its charter and promotion rules,
So that I know which file to read and which to write to (FR42; baseline for FR14j in Epic 3).

**Acceptance Criteria:**

**Given** a fresh clone,
**When** I open the repo root,
**Then** `INVARIANTS.md`, `AGENTS.md`, `CLAUDE.md`, and `RALPH.md` all exist
**And** each begins with a pinned audience header (`INVARIANTS.md` = agent-readable index of machine-enforced rules; `AGENTS.md` = every AI agent operational truth; `CLAUDE.md` = Claude-Code specifics + pointer; `RALPH.md` = Ralph private journal).

**Given** the four files,
**When** I read each header,
**Then** the promotion rule is pinned verbatim (applies-to-every-agent → `AGENTS.md`; Claude-Code-specific → `CLAUDE.md`; Ralph-gotchas → `RALPH.md`; machine-enforced → `INVARIANTS.md` + `packages/keel-invariants/`).

**Given** `INVARIANTS.md`,
**When** I read its body,
**Then** it is an agent-readable index of stable IDs mapping to rules in `packages/keel-invariants/`
**And** each entry cites the stable ID, a one-line description, and a source-file pointer.

**Given** `CLAUDE.md`,
**When** I read its body,
**Then** it points at `AGENTS.md` as the source of truth and names only Claude-Code-specific supplements.

**Given** `RALPH.md`,
**When** read by Ralph during orient,
**Then** its intended scope (private journal; append-only-in-spirit; hard lint enforcement lands in Epic 3 per RS6) is documented in its header.

##### Story 1.8: `invariants.manifest.ts` contract + exporter

As a substrate maintainer,
I want `packages/keel-invariants/src/invariants.manifest.ts` exporting a typed list of every substrate invariant with stable IDs and content hashes,
So that the sync-gate tooling has a machine-readable contract to drift-detect against (FR43 contract side).

**Acceptance Criteria:**

**Given** the `keel-invariants` package,
**When** I read `src/invariants.manifest.ts`,
**Then** it exports `const invariants: Invariant[]`
**And** each entry has `{ id: string, description: string, sourcePath: string, contentHash: string, anchors: string[] }`.

**Given** the manifest,
**When** I inspect any entry,
**Then** `id` follows `INV-<category>-<slug>` (e.g., `INV-commit-conventional-format`, `INV-tokens-sync-gate`)
**And** `sourcePath` resolves to an existing file in `packages/keel-invariants/src/`
**And** `contentHash` is the sha256 of the source region bounded by declared anchors.

**Given** a typed `Invariant` interface,
**When** a new rule is added to `keel-invariants`,
**Then** it MUST register a manifest entry with a fresh stable ID
**And** Story 1.9 treats unregistered rules as drift.

**Given** the exporter,
**When** consumed by Story 1.9's sync gate,
**Then** the manifest loads synchronously (no async I/O) and validates against its own Zod (or equivalent) schema at import time.

##### Story 1.9: Invariant sync-gate runtime tooling (reader + walker + drift detector)

As a substrate maintainer,
I want `packages/keel-invariants/src/sync-gate.ts` + `manifest-reader.ts` that read the manifest, walk machine-enforced sources + `INVARIANTS.md` anchors, and fail loudly on drift,
So that FR43 has teeth from day 1 (W2 party-mode amendment).

**Acceptance Criteria:**

**Given** the manifest from Story 1.8 and `INVARIANTS.md` anchors,
**When** I run `pnpm keel-invariants:check`,
**Then** the tool exits zero if every manifest entry has a matching `INVARIANTS.md` anchor AND every anchor has a matching entry AND every content hash matches
**And** exits non-zero with a structured drift report otherwise.

**Given** a new rule added to `packages/keel-invariants/src/` without a manifest entry (addition drift),
**When** the gate runs,
**Then** it reports `added-to-source-only` with the source path and exits non-zero.

**Given** a manifest entry whose `sourcePath` file is deleted (removal drift),
**When** the gate runs,
**Then** it reports `removed-from-source-only` and exits non-zero.

**Given** a source edit that doesn't update the manifest's `contentHash` (edit drift),
**When** the gate runs,
**Then** it reports `content-hash-mismatch` naming the manifest ID and the offending file
**And** exits non-zero.

**Given** an `INVARIANTS.md` anchor removed without a manifest entry removal,
**When** the gate runs,
**Then** it reports `removed-from-docs-only` and exits non-zero.

**Given** the tool's exit codes,
**When** Epic 13 wires it into GitHub Actions,
**Then** non-zero reliably fails the workflow and the drift report renders in CI logs.

**Given** the tool is callable locally,
**When** run on the baseline repo,
**Then** it completes in under 2 seconds.

##### Story 1.10: Design-token schema + semantic-rationale contract

As a UX designer or front-end developer,
I want `packages/ui/tokens.schema.json` defining the token-contract shape AND `docs/invariants/tokens.md` documenting every semantic token's meaning,
So that Epic 7's catalog and Epic 3's TUI consume tokens against a shared validated contract — no invisible semantic drift (W1 amendment, UX-DR4).

**Acceptance Criteria:**

**Given** the substrate,
**When** I inspect `packages/ui/tokens.schema.json`,
**Then** the JSON Schema defines the shape of the token source (semantic names, scales, primitive references)
**And** validates DTCG-format-compatible structure.

**Given** `docs/invariants/tokens.md`,
**When** I read it,
**Then** every semantic token (`surface.raised`, `status.success`, `text.primary`, `motion.scale.*`, `density.scale.*`, etc.) has a prose rationale line
**And** each rationale carries a stable `TOKEN-<slug>` ID.

**Given** schema + rationale,
**When** Epic 7's catalog or Epic 3's TUI references a semantic token,
**Then** the reference can be cross-linked back to `tokens.md`'s rationale via the stable ID
**And** `tokens.md` is the source-of-truth rationale (Sally's "catalog header references rationale" requirement met).

**Given** the schema is the contract,
**When** the manifest (Story 1.8) tracks it,
**Then** an entry `INV-tokens-schema-contract` registers `tokens.schema.json` + `tokens.md`
**And** drift between them is caught by Story 1.9.

##### Story 1.11: Design-token source — Direction A baseline with motion + density scales

As a UX designer,
I want the canonical token source populated with Direction A "The Instrument" values and global `motion.scale` + `density.scale` hierarchies,
So that the substrate ships with a coherent opinionated visual baseline ready for Epic 7 and Epic 12 consumption (UX-DR15, UX-DR9).

**Acceptance Criteria:**

**Given** the schema from Story 1.10,
**When** I open the canonical token source file (choice between `packages/ui/tokens.json` DTCG or `packages/keel-invariants/design-tokens.ts` typed; decision documented in the file header),
**Then** the file validates against `tokens.schema.json`
**And** every Direction A semantic-token value from `ux-design-specification.md` is populated.

**Given** Direction A is substrate default,
**When** Directions B (GOV.UK-adjacent) and C (Developer-notebook) are referenced,
**Then** they are NOT in this file; their preset overlays at `docs/design/presets/*.tokens.json` land in Epic 7.

**Given** motion + density,
**When** I read the file,
**Then** `motion.scale` defines at least `instant | snap | swift | smooth | drift` tiers
**And** `density.scale` defines at least `compact | default | comfortable` tiers
**And** each tier has a numeric value referenced by name.

**Given** this file is the canonical input to Story 1.12's emitter,
**When** Story 1.9's sync gate walks it,
**Then** the file is registered under manifest ID `INV-tokens-source`
**And** changes without matching emitted outputs fail pre-merge (Story 1.13).

##### Story 1.12: Token emitter pipeline → web CSS + Tailwind preset + TUI theme

As a front-end developer or Ralph (TUI consumer),
I want `packages/ui/scripts/generate-tokens.ts` that reads the source and deterministically emits three artefacts — `packages/ui/src/tokens.css`, `packages/ui/tailwind.preset.ts`, `packages/devbox/tui/theme.py`,
So that every consumer (web, Tailwind, TUI) shares one source and the pipeline is pure, idempotent, and re-runnable (UX-DR3).

**Acceptance Criteria:**

**Given** the token source from Story 1.11,
**When** I run `pnpm --filter @keel/ui generate-tokens`,
**Then** three output files are emitted
**And** every output begins with a provenance header naming the source-file commit SHA and emitter version.

**Given** the emitter is deterministic,
**When** I run it twice with no source changes,
**Then** both runs produce byte-identical outputs
**And** `git diff` after the second run is empty.

**Given** `packages/ui/src/tokens.css`,
**When** consumed in a web app,
**Then** every semantic token is available as a CSS variable (`var(--surface-raised)`, `var(--status-success)`, etc.).

**Given** `packages/ui/tailwind.preset.ts`,
**When** imported into a Tailwind config,
**Then** every semantic token is exposed under theme extension (e.g., `theme.colors['surface-raised']`).

**Given** `packages/devbox/tui/theme.py`,
**When** imported into a Textual app,
**Then** Python constants map 1:1 to semantic tokens
**And** TUI chrome can reference `theme.colors.surface_raised` etc.

**Given** the emitter is pure,
**When** invoked,
**Then** it uses no network, no filesystem side effects beyond the three outputs, and no time-dependent values
**And** passes Epic 13's reproducibility CI check.

##### Story 1.13: Token quality gates (schema validation + WCAG AA contrast + source-output sync)

As a substrate maintainer,
I want three pre-commit/pre-merge quality gates on the token pipeline — schema validation, WCAG AA contrast check, and source-output sync,
So that the token layer cannot drift or ship inaccessible combinations (UX-DR4, UX-DR5, UX-DR6).

**Acceptance Criteria:**

**Given** the token source from Story 1.11,
**When** a commit touches it,
**Then** the pre-commit hook validates it against `tokens.schema.json`
**And** schema-violating commits are rejected with a structured error naming the offending property.

**Given** every `text.*` × `surface.*` semantic pair,
**When** the contrast-check runs,
**Then** each pair's contrast ratio is computed against WCAG AA (4.5:1 normal; 3:1 large)
**And** failing pairs are reported with hex values + computed ratio
**And** the commit is rejected.

**Given** a commit that changes the source but not the emitted outputs,
**When** pre-merge runs (reusing Story 1.9's tooling),
**Then** the emitter is re-run in `--check` mode
**And** divergence between "what would be emitted" vs "what is committed" fails the gate.

**Given** the three gates,
**When** the manifest walks them,
**Then** each has an entry (`INV-tokens-schema-validate`, `INV-tokens-contrast-check`, `INV-tokens-sync-gate`)
**And** `INVARIANTS.md` anchors match.

##### Story 1.14: Release-please-monorepo config (single-bundled mode)

As a substrate maintainer,
I want release-please-monorepo in single-bundled-release mode, driven by conventional-commit messages,
So that a rolling Release PR accumulates changelog + version bumps automatically and 1.0-cut follows a known ritual (FR31).

**Acceptance Criteria:**

**Given** `.github/release-please-config.json` and `.github/.release-please-manifest.json`,
**When** I inspect them,
**Then** the config is single bundled release (not per-package)
**And** every workspace package appears in the manifest with its current version.

**Given** a merged PR with `feat: X`,
**When** the release-please Action runs,
**Then** the existing Release PR is updated with a minor-bump entry
**And** no Release PR is yet merged.

**Given** a merged PR with `fix: Y`,
**When** the Action runs,
**Then** the Release PR updates with a patch-bump entry.

**Given** a merged PR with `feat!:` or `BREAKING CHANGE:` body,
**When** the Action runs,
**Then** the Release PR escalates to a major bump.

**Given** Tthew merges the Release PR,
**When** it lands,
**Then** release-please tags the release on `main` and publishes release notes
**And** the next commit to `main` starts a fresh Release PR.

**Given** per-package release mode was considered,
**When** I read the config comments,
**Then** the single-bundled choice is documented with a pointer to the architecture's deferral rationale.

##### Story 1.15: Renovate config with version-pinning rules (I7)

As a substrate maintainer,
I want `.github/renovate.json` with version-pinning rules — Vitest exact, OTEL pinned in `pnpm.overrides`, grouped-update rules, and an integration-test-passing gate,
So that dependency upgrades flow through Keel deterministically and flaky upgrades never auto-merge (I7 amendment).

**Acceptance Criteria:**

**Given** `.github/renovate.json`,
**When** I read it,
**Then** Vitest's `rangeStrategy` is `pin`
**And** `@opentelemetry/sdk-node`, `@opentelemetry/api`, and instrumentations are listed in `pnpm.overrides` at pinned versions
**And** grouped-update rules bundle related packages (all OTEL, all Vitest) into one PR.

**Given** a Renovate PR is opened,
**When** CI runs,
**Then** the integration-test-passing gate is required before Renovate can auto-merge
**And** the gate reuses Epic 13's CI when it lands; at 1.0 the rule itself ships here even if Epic 13 wiring is partial.

**Given** an OTEL version bump,
**When** Renovate proposes it,
**Then** all related OTEL packages are upgraded together in one PR
**And** `pnpm.overrides` is updated atomically with `package.json`.

**Given** a new package added without a required pin,
**When** the manifest tracks pinning policy under `INV-deps-version-pinning`,
**Then** Story 1.9's sync-gate surfaces the drift.

##### Story 1.16: Fork extension-config pattern + Growth-tier `INVARIANTS.fork.md` scaffold

As a fork operator who wants to extend substrate rules without editing the substrate,
I want a documented `eslint.config.fork.js extends eslint.config.keel-invariants.js` pattern plus a Growth-tier `INVARIANTS.fork.md` scaffold referenced alongside `INVARIANTS.md` in `CLAUDE.md`,
So that forks can layer rules on top of substrate without touching `packages/keel-invariants/` (FR44 at 1.0; FR45 Growth-tier).

**Acceptance Criteria:**

**Given** a substrate-installed fork,
**When** I follow the extension pattern documented in `AGENTS.md`,
**Then** I can create `eslint.config.fork.js` at my fork root that imports + extends `@keel/keel-invariants/eslint`
**And** additional fork-specific rules layer on cleanly
**And** `pnpm lint` applies both shared + fork rules.

**Given** a fork adds rules that conflict with substrate invariants,
**When** lint runs,
**Then** substrate rules win (ESLint override precedence documented in `AGENTS.md`)
**And** `AGENTS.md` explains how to request a substrate amendment vs forking.

**Given** the Growth-tier `INVARIANTS.fork.md` scaffold,
**When** a fork operator opts in,
**Then** an `INVARIANTS.fork.md` template is created at the fork root
**And** `CLAUDE.md` is updated to reference both `INVARIANTS.md` and `INVARIANTS.fork.md` with clear precedence rules.

**Given** at 1.0 the Growth-tier scaffold is non-essential,
**When** Epic 15a's `create-keel-app` runs in 1.0 mode,
**Then** `INVARIANTS.fork.md` is NOT auto-created
**And** the pattern + template are documented for fork operators to opt into manually.

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
- **[NFR5a — NEW, PRD clarification raised]** In-devbox secret-access barrier via committed `.claude/settings.json` (permissions.deny + permissions.allow) and `.claude/hooks/block-secret-access.sh` PreToolUse hooks on Bash/Read/Grep/Glob. Blocks reads of `.envrc*`, `**/.env*`, `.secrets*`, `/home/dev/.claude/**`, `/home/dev/.config/gh/**`, `/proc/*/environ`, and Bash invocations `env`/`printenv*`/`cat .envrc*`/`cat /proc/*/environ*`. Hooks execute regardless of `--dangerously-skip-permissions`, providing the ONLY in-session defense during Ralph iterations. Forks extend via `.claude/hooks/block-secret-access.fork.sh`; cannot weaken substrate denylist. Blocked-call events feed `.ralph/logs/<iter-id>/blocked-tool-calls.jsonl` for FR37 security-evidence consumption (Epic 4). Invariant `INV-claude-hook-secret-denylist` registered in Epic 1's manifest.

**Standalone delivery:** Developer can `pnpm devbox:start`, get a sandboxed container, authenticate Claude Code + gh once, run `pnpm test` / `pnpm lint` inside, and Claude sessions inside the container cannot read secrets or dump env. No Ralph or agent loop yet.

#### Stories

##### Story 2.1: `packages/devbox/` absorb from cc-devbox — image + compose + substrate tooling access

As a fork operator,
I want `packages/devbox/` to absorb the upstream `cc-devbox` per the PRD M0.5 five-deliverable sub-scope (image, compose, entrypoint, egress-policy fix, pnpm lifecycle bridge) with a pinned Ubuntu 24.04 LTS base and baked toolchain,
So that I can run substrate tooling (tests, lints, RLS debugger in Epic 6) inside a reproducible container (FR1, FR6, NFR2).

**Acceptance Criteria:**

**Given** the monorepo scaffold from Epic 1,
**When** I inspect `packages/devbox/`,
**Then** I find `Dockerfile`, `docker-compose.yml`, `entrypoint.sh`, and `scripts/` for the host CLI (wired in Story 2.6)
**And** the Dockerfile `FROM ubuntu:24.04` with a documented pin rationale in a comment header.

**Given** the Dockerfile,
**When** the image builds,
**Then** `node@20-lts`, `pnpm`, `@anthropic-ai/claude-code`, `gh`, `uv`, `aws-cli`, `supabase-cli`, `delta`, and Playwright browser deps are baked at image-build time
**And** no runtime network installs occur in `entrypoint.sh`.

**Given** the baked image,
**When** I run `pnpm test` or `pnpm lint` inside the container (via `pnpm devbox:shell` from Story 2.6),
**Then** both commands execute against the workspace mounted at `/workspace`
**And** the RLS debugger (landing in Epic 6) can be invoked without additional image changes.

**Given** the NFR2 cold-start budget,
**When** I measure first `pnpm devbox:start` on an Apple-Silicon M4-Pro baseline,
**Then** cold start completes in ≤ 5 minutes
**And** a subsequent warm start completes in ≤ 30 seconds
**And** the measurement method + baseline hardware are documented in `packages/devbox/README.md`.

##### Story 2.2: `.envrc` parameterisation contract

As a fork operator,
I want `.envrc` (gitignored) and `.envrc.example` + `.secrets.example` (committed) that parameterise every tunable devbox variable,
So that I can retune the devbox for my hardware and secrets without editing compose or Dockerfile (I5/I6).

**Acceptance Criteria:**

**Given** `packages/devbox/.envrc.example`,
**When** I read the file,
**Then** every `KEEL_DEVBOX_*` knob is listed with a default value and inline comment: `KEEL_DEVBOX_ARCH`, `KEEL_DEVBOX_CPUS`, `KEEL_DEVBOX_MEMORY_GB`, `KEEL_DEVBOX_SHM_GB`, `KEEL_DEVBOX_NOFILE`, `KEEL_DEVBOX_TMPFS_TMP_MB`, `KEEL_DEVBOX_TMPFS_VARTMP_MB`, port knobs, `KEEL_DEVBOX_SSH`, `KEEL_DEVBOX_SHARED`
**And** the defaults match an Apple-Silicon M4-Pro baseline (documented in the file header).

**Given** `packages/devbox/docker-compose.yml`,
**When** I inspect it,
**Then** it uses `env_file: ../../.envrc` to consume the top-level `.envrc`
**And** every tunable value in compose is referenced via `${KEEL_DEVBOX_*}`.

**Given** a fork operator who wants to retune memory,
**When** they edit `.envrc` (not compose) and run `pnpm devbox:restart` (from Story 2.6),
**Then** the new memory value takes effect
**And** no PRD amendment is required (NFR8a).

**Given** `packages/devbox/.secrets.example`,
**When** I read it,
**Then** it lists env vars that `act` (local GitHub-Actions runner) needs
**And** it serves as the committed schema for the gitignored `.secrets` file.

**Given** `.envrc` is gitignored,
**When** a PR tries to commit it,
**Then** `.gitignore` rejects the addition
**And** a lint rule in `keel-invariants` (from Story 1.2) flags any attempt to commit `.envrc` or `.secrets`.

##### Story 2.3: Egress policy — dnsmasq + nftables (fail-closed, IPv4 + IPv6 parity, atomic reload)

As a substrate maintainer,
I want the devbox egress enforced by dnsmasq (DNS authority + JSONL query log) and nftables (layer-3 default-deny IPv4 + IPv6) with atomic reload semantics,
So that a runtime compromise inside the container cannot reach arbitrary external hosts (FR1a, NFR6).

**Acceptance Criteria:**

**Given** the baked image from Story 2.1,
**When** the container starts,
**Then** dnsmasq runs as the in-container DNS authority
**And** the container's `/etc/resolv.conf` points only at `127.0.0.1:53`
**And** upstream's fail-open `resolv.conf` gap is closed.

**Given** nftables is configured at entrypoint,
**When** I inspect the ruleset,
**Then** the default policy is `DROP` for both IPv4 (`ip`) and IPv6 (`ip6`) filter output chains
**And** upstream's IPv6 gap is closed (policy parity verified by an in-container test).

**Given** dnsmasq's JSONL query log,
**When** DNS queries execute,
**Then** each query is written to a structured JSONL file at a pinned path suitable for FR37 security-evidence persistence (Epic 4)
**And** log rotation is configured to prevent unbounded growth.

**Given** an atomic reload is triggered via file-lock (mechanism used by Story 2.4's CLI),
**When** the whitelist is updated,
**Then** dnsmasq + nftables are re-loaded without dropping in-flight connections
**And** the reload is atomic (either both layers apply the new policy, or neither does).

**Given** a container with the policy active,
**When** I attempt to `curl` an unwhitelisted domain,
**Then** the DNS resolution fails (dnsmasq NXDOMAIN) AND the TCP connection is rejected (nftables default-deny)
**And** upstream's divergent-whitelist-script problem is closed (one mechanism, two enforcement layers).

##### Story 2.4: Whitelist source-of-truth + `pnpm devbox:whitelist` atomic-reload CLI

As a fork operator,
I want a repo-tracked whitelist source-of-truth (`packages/devbox/whitelist.default.txt` + per-category fragments + per-fork override) plus a `pnpm devbox:whitelist sync` CLI that reloads atomically under file-lock,
So that egress policy changes are reviewable in git and applied without container restart (FR1a).

**Acceptance Criteria:**

**Given** `packages/devbox/`,
**When** I read the whitelist layout,
**Then** `whitelist.default.txt` holds the substrate baseline
**And** per-category fragments (e.g., `whitelist.github.txt`, `whitelist.npm.txt`, `whitelist.anthropic.txt`) compose into the final policy
**And** a per-fork override file (gitignored path documented in `AGENTS.md`) can add fork-specific domains.

**Given** `pnpm devbox:whitelist sync`,
**When** I run it,
**Then** the CLI reads the composed whitelist, validates domain syntax, acquires a file-lock, and reloads dnsmasq + nftables atomically (reusing Story 2.3's mechanism)
**And** the CLI exits zero on successful reload with a diff summary (domains added/removed).

**Given** a syntax-invalid entry in any whitelist file,
**When** the CLI runs,
**Then** it exits non-zero with a line/file pointer
**And** the previous policy remains active (fail-closed).

**Given** concurrent sync attempts,
**When** two `pnpm devbox:whitelist sync` commands run simultaneously,
**Then** the file-lock serialises them
**And** no partial policy state is ever active.

**Given** the whitelist is tracked in git,
**When** a PR edits any whitelist file,
**Then** the commit is subject to standard prek gates (Story 1.4/1.5)
**And** reviewers see exactly which domains were added/removed.

##### Story 2.5: Container hardening (non-root user + capabilities + tmpfs noexec + named volume)

As a substrate maintainer,
I want the devbox container hardened — non-root `dev` user, `NET_ADMIN` + `NET_RAW`-only caps, `no-new-privileges`, tmpfs mounts with `noexec,nosuid`, named Docker volume for `/home/dev`,
So that a runtime compromise faces meaningful layered barriers to escape or persistence (NFR7, NFR8/8a, NFR10).

**Acceptance Criteria:**

**Given** the Dockerfile from Story 2.1,
**When** the image is built,
**Then** a non-root `dev` user is created with a stable UID/GID
**And** the image `USER` directive switches to `dev` before the entrypoint runs.

**Given** `docker-compose.yml`,
**When** I inspect it,
**Then** `cap_drop: [ALL]` is set
**And** `cap_add` lists only `NET_ADMIN` and `NET_RAW` (required by nftables in Story 2.3)
**And** `security_opt: [no-new-privileges]` is set.

**Given** tmpfs mounts in compose,
**When** I inspect them,
**Then** `/tmp` and `/var/tmp` are tmpfs-mounted with `noexec,nosuid` options
**And** the sizes are parameterised via `KEEL_DEVBOX_TMPFS_TMP_MB` and `KEEL_DEVBOX_TMPFS_VARTMP_MB` (from Story 2.2).

**Given** `/home/dev` persistence,
**When** I inspect the compose volume definition,
**Then** a named Docker volume (e.g., `keel_home_dev`) is mounted at `/home/dev`
**And** no host bind-mount is used for `/home/dev` under any `KEEL_DEVBOX_*` setting
**And** this invariant is non-toggle-able (enforced by a compose-shape check in the invariants manifest).

**Given** the hardening is in place,
**When** I attempt to execute a binary from `/tmp` inside the container,
**Then** execution fails with `noexec`
**And** any attempt to gain privileges via setuid binaries is blocked by `nosuid` + `no-new-privileges`.

##### Story 2.6: Host-side `pnpm devbox:*` CLI surface

As a fork operator,
I want host-side `pnpm devbox:{build,rebuild,clean,status,logs,shell,attach,start,stop,restart,whitelist,monitor,env:check}` commands driving the devbox lifecycle,
So that I never need to learn raw `docker compose` incantations to operate my devbox (FR1).

**Acceptance Criteria:**

**Given** the devbox package,
**When** I inspect `packages/devbox/scripts/`,
**Then** there is one script per command (or a single CLI entry dispatching by subcommand) and `package.json` exposes each as a `pnpm devbox:<cmd>`.

**Given** `pnpm devbox:build`,
**When** I run it,
**Then** the image is built from `packages/devbox/Dockerfile`
**And** `pnpm devbox:rebuild` rebuilds with `--no-cache`.

**Given** `pnpm devbox:start`,
**When** I run it,
**Then** the container comes up via compose (from Story 2.1)
**And** healthchecks (Story 2.13) must pass before the command returns zero.

**Given** `pnpm devbox:stop` / `pnpm devbox:restart` / `pnpm devbox:clean`,
**When** I run each,
**Then** `stop` halts without destroying the named volume, `restart` is `stop && start`, and `clean` removes the container and image but keeps the named volume from Story 2.5 (prompting for explicit confirmation before volume deletion).

**Given** `pnpm devbox:shell`,
**When** I run it,
**Then** it opens an interactive shell as the `dev` user inside the running container.

**Given** `pnpm devbox:attach`,
**When** I run it,
**Then** it attaches to the container's stdout/stderr (for observing Ralph TUI from Story 2.7)
**And** supports `Ctrl+P Ctrl+Q` detach without killing the container (Story 2.7 prereq).

**Given** `pnpm devbox:status` / `pnpm devbox:logs` / `pnpm devbox:monitor`,
**When** I run each,
**Then** `status` prints container state + healthcheck, `logs` tails container stdout/stderr, `monitor` displays a live resource snapshot (cpu/memory/network).

**Given** `pnpm devbox:env:check`,
**When** I run it,
**Then** it validates that `.envrc` is present and every required `KEEL_DEVBOX_*` variable is defined
**And** exits non-zero with a missing-var report if any are absent.

**Given** `pnpm devbox:whitelist`,
**When** I run it (wired in Story 2.4),
**Then** it invokes the atomic-reload flow from Story 2.4.

##### Story 2.7: Ralph auto-start + TUI attach/detach via `pnpm ralph:build` / `pnpm ralph:plan`

As a fork operator,
I want `pnpm ralph:build` and `pnpm ralph:plan` to check container state, auto-start the devbox if needed, and attach the Textual TUI with `Ctrl+P Ctrl+Q` detach preserving the running loop,
So that I can invoke Ralph without manual container lifecycle management (FR2).

**Acceptance Criteria:**

**Given** the devbox is not running,
**When** I run `pnpm ralph:build`,
**Then** the command invokes `pnpm devbox:start` (from Story 2.6) internally
**And** waits for the container to become healthy before attaching.

**Given** the devbox is already running,
**When** I run `pnpm ralph:build` or `pnpm ralph:plan`,
**Then** the command skips the start step and attaches directly.

**Given** the TUI is attached inside the container (Textual-based, consuming `packages/devbox/tui/theme.py` from Story 1.12),
**When** I press `Ctrl+P Ctrl+Q`,
**Then** I detach from the container
**And** the Ralph loop continues running inside.

**Given** a detached Ralph loop is running,
**When** I re-attach via `pnpm devbox:attach` (or re-invoking `pnpm ralph:build`),
**Then** the TUI state is preserved (scroll position, current iteration)
**And** no state is lost.

**Given** build mode vs plan mode,
**When** `pnpm ralph:build` invokes the loop,
**Then** the harness (Epic 3) reads `.ralph/PROMPT_build.md`
**And** `pnpm ralph:plan` reads `.ralph/PROMPT_plan.md`
**And** this Epic 2 story only ensures the invocation path; prompt-file semantics land in Epic 3.

##### Story 2.8: Claude Code OAuth via `pnpm claude`

As a fork operator,
I want `pnpm claude` to trigger the Claude Code browser OAuth flow surfaced to my host terminal, with tokens persisted in the named Docker volume at `/home/dev/.claude/`,
So that I authenticate once per devbox and the token survives container restarts (FR3 Claude side).

**Acceptance Criteria:**

**Given** a fresh devbox,
**When** I run `pnpm claude`,
**Then** the command invokes `claude` inside the container
**And** the OAuth URL is surfaced to my host terminal
**And** following the URL in a host browser completes the flow.

**Given** the flow completes,
**When** tokens are stored,
**Then** they persist at `/home/dev/.claude/` inside the named volume from Story 2.5
**And** the token file is never bind-mounted to the host filesystem.

**Given** a subsequent `pnpm devbox:restart` or `pnpm devbox:stop && start`,
**When** I run any Claude Code invocation,
**Then** the existing token is reused (no re-auth required).

**Given** the token is expired or revoked,
**When** Ralph or a manual `claude` invocation runs,
**Then** the failure surfaces a clear re-auth pointer
**And** `pnpm claude` can be re-run to refresh the token without affecting other devbox state.

**Given** a `pnpm devbox:clean` with volume-deletion confirmed,
**When** I next run the devbox,
**Then** tokens are gone and `pnpm claude` must be re-run (expected per NFR10 / fresh-fork behaviour).

##### Story 2.9: `gh` CLI OAuth via `pnpm gh:auth`

As a fork operator,
I want `pnpm gh:auth` to trigger the `gh auth login` browser flow surfaced to my host terminal, with tokens persisted in the named Docker volume at `/home/dev/.config/gh/`,
So that Ralph can push commits and read PR state without per-iteration re-auth (FR3 gh side).

**Acceptance Criteria:**

**Given** a fresh devbox,
**When** I run `pnpm gh:auth`,
**Then** the command invokes `gh auth login` inside the container
**And** the OAuth URL is surfaced to my host terminal
**And** completing the flow in a host browser returns control to the CLI.

**Given** the flow completes,
**When** tokens are stored,
**Then** they persist at `/home/dev/.config/gh/` inside the named volume
**And** no host bind-mount is involved.

**Given** a subsequent devbox restart,
**When** Ralph runs `gh pr view` or `git push`,
**Then** the token is reused (no re-auth required).

**Given** an expired or revoked token,
**When** `gh` invocations fail,
**Then** the failure surfaces a clear pointer to re-run `pnpm gh:auth`
**And** Ralph's pre-push gate (Epic 3) treats this as a halt-able condition rather than silently retrying.

##### Story 2.10: Prerequisite check (Docker runtime + Claude auth + gh auth) with pointer errors

As a fork operator,
I want a prerequisite check that runs on fresh-fork first-run and on every Ralph invocation, failing with install-pointer or auth-pointer errors if Docker runtime is missing, Claude Code is not authed, or `gh` is not authed,
So that Ralph cannot execute autonomously in a broken environment (FR5).

**Acceptance Criteria:**

**Given** a host without Docker installed,
**When** I run `pnpm ralph:build` or any devbox command,
**Then** the prerequisite check fails with a message pointing at Docker Desktop install instructions (URL in message)
**And** the command exits non-zero before starting the devbox.

**Given** Docker is running but Claude Code is not authed inside the devbox,
**When** `pnpm ralph:build` runs its prerequisite check,
**Then** the check detects the missing token (by probing `/home/dev/.claude/` state)
**And** surfaces a pointer error: `"Claude Code not authed — run 'pnpm claude' first"`
**And** exits non-zero.

**Given** Claude Code is authed but `gh` is not,
**When** `pnpm ralph:build` runs its prerequisite check,
**Then** the check detects the missing gh token
**And** surfaces `"gh CLI not authed — run 'pnpm gh:auth' first"`
**And** exits non-zero.

**Given** all three prerequisites are satisfied,
**When** `pnpm ralph:build` runs,
**Then** the prerequisite check passes silently
**And** the Ralph loop starts normally.

**Given** fresh-fork first-run (no previous devbox state),
**When** a new fork operator runs any `pnpm devbox:*` or `pnpm ralph:*` command,
**Then** the prerequisite check runs and surfaces the missing-item list as a single message
**And** an exit-zero path requires all three to be satisfied (no partial bypass).

##### Story 2.11: Per-fork vs shared devbox mode (`KEEL_DEVBOX_SHARED`)

As a fork operator running multiple worktrees or forks,
I want `.envrc`'s `KEEL_DEVBOX_SHARED` flag to switch between per-fork devbox (default) and shared-devbox mode,
So that I can choose between strict isolation per fork and a shared long-running devbox across forks (FR4).

**Acceptance Criteria:**

**Given** `KEEL_DEVBOX_SHARED=false` (or unset default) in `.envrc`,
**When** I run `pnpm devbox:start` from fork A and fork B,
**Then** each fork gets its own container + named volume (names derived from the fork's path or slug)
**And** the two devboxes are isolated.

**Given** `KEEL_DEVBOX_SHARED=true` in `.envrc` of both forks,
**When** I run `pnpm devbox:start` from fork A and fork B,
**Then** both forks attach to a single shared container
**And** a shared workspace mount strategy is documented in `AGENTS.md`.

**Given** I flip the flag mid-use,
**When** I switch `KEEL_DEVBOX_SHARED` from `false` to `true`,
**Then** `pnpm devbox:env:check` (Story 2.6) surfaces a warning about orphaned containers from the previous mode
**And** points at `pnpm devbox:clean` as the resolution path.

**Given** shared mode is active,
**When** two forks invoke Ralph simultaneously,
**Then** the behaviour is documented (either locked/serialised or parallel with per-fork working-tree isolation — decision pinned in Story 2.11's implementation note)
**And** conflicting writes to `/home/dev/` are avoided by design.

##### Story 2.12: Loopback-bound port publication + opt-in `KEEL_DEVBOX_SSH` sshd

As a substrate maintainer,
I want every published devbox port bound to `127.0.0.1` (no `0.0.0.0`) and an opt-in sshd (enabled via `KEEL_DEVBOX_SSH=true`) that is pubkey-only and loopback-bound at `127.0.0.1:2222`,
So that the devbox's attack surface is limited to the host loopback, never a LAN or internet-reachable interface.

**Acceptance Criteria:**

**Given** `docker-compose.yml`,
**When** I inspect the `ports` section,
**Then** every port mapping uses `127.0.0.1:<host>:<container>` form
**And** no `0.0.0.0:...` or bare-port bindings exist.

**Given** `KEEL_DEVBOX_SSH=false` (default),
**When** the container starts,
**Then** sshd does NOT run inside the container
**And** port 2222 is not published.

**Given** `KEEL_DEVBOX_SSH=true`,
**When** the container starts,
**Then** sshd runs inside the container bound to `127.0.0.1:2222`
**And** password auth is disabled — only pubkey auth is allowed
**And** host keys auto-generate on first boot and persist in the named volume.

**Given** sshd is enabled,
**When** an external (non-loopback) client attempts to connect,
**Then** the connection is refused
**And** only `ssh -p 2222 dev@127.0.0.1` from the host succeeds with a registered pubkey.

**Given** a fork operator wants to add their pubkey,
**When** they follow the documented flow,
**Then** the pubkey is written to `/home/dev/.ssh/authorized_keys` inside the named volume
**And** persists across devbox restarts.

##### Story 2.13: Healthcheck on dnsmasq + sshd (replaces upstream's broken `curl :3000` healthcheck)

As a substrate maintainer,
I want `docker-compose.yml`'s healthcheck to probe dnsmasq liveness (and sshd when enabled) rather than upstream's broken `curl :3000`,
So that container state reflects actual service health and `pnpm devbox:status` is reliable.

**Acceptance Criteria:**

**Given** the compose file,
**When** I inspect the `healthcheck:` block,
**Then** it does NOT invoke `curl localhost:3000`
**And** it probes dnsmasq liveness (e.g., a DNS query against `127.0.0.1:53` that resolves a known-whitelisted domain).

**Given** `KEEL_DEVBOX_SSH=true`,
**When** the healthcheck runs,
**Then** it additionally probes sshd liveness on `127.0.0.1:2222`
**And** the healthcheck fails if either service is down.

**Given** dnsmasq crashes mid-run,
**When** the healthcheck next executes,
**Then** the container status transitions to `unhealthy`
**And** `pnpm devbox:status` (from Story 2.6) surfaces the state.

**Given** the healthcheck interval + timeout,
**When** I inspect compose,
**Then** values are reasonable (e.g., `interval: 10s`, `timeout: 5s`, `retries: 3`, `start_period: 30s`)
**And** values are documented in `packages/devbox/README.md` with rationale.

##### Story 2.14: Legacy-devbox branch retention policy

As Tthew (substrate maintainer carrying PRD technical-risk mitigation),
I want the standalone `cc-devbox` functionality preserved on a `legacy-devbox` branch until after the M4 checkpoint,
So that if the absorbed-into-`packages/devbox/` version hits a regression, there is a working fallback with no scramble (PRD Technical Risks mitigation).

**Acceptance Criteria:**

**Given** the `legacy-devbox` branch exists,
**When** I check it out,
**Then** it carries the pre-absorption standalone `cc-devbox` layout
**And** `README.md` on that branch names its scope and sunset date.

**Given** the absorbed `packages/devbox/` is in main,
**When** the legacy branch is maintained,
**Then** security-critical upstream patches are cherry-picked from `main`'s `packages/devbox/` to `legacy-devbox` (a documented workflow, not an automated one)
**And** the expectation is "minimal drift," not feature parity.

**Given** the M4 checkpoint has passed without regressions,
**When** Tthew decides to retire the branch,
**Then** `RALPH.md` records the decision with the M4 retrospective reference
**And** the branch is tagged (`legacy-devbox-final`) and removed from active tracking.

**Given** the legacy branch exists during the retention window,
**When** anyone opens an issue about devbox regressions,
**Then** the triage path is documented: "try `legacy-devbox` branch as a canary; if the regression is absent there, bisect to find the introducing commit."

##### Story 2.15: Committed `.claude/settings.json` with deny/allow permission policies

As a substrate maintainer,
I want a committed `.claude/settings.json` at the repo root declaring `permissions.deny` rules for secret files and `permissions.allow` for common dev commands,
So that Claude sessions (both interactive and Ralph) inherit a hardened default policy on fresh-fork clone, not opt-in per-user (NFR5a — new PRD clarification).

**Acceptance Criteria:**

**Given** a fresh clone,
**When** I open the repo root,
**Then** `.claude/settings.json` exists and is tracked in git
**And** its schema matches Claude Code's official settings schema (permissions, hooks, env, etc.).

**Given** the `permissions.deny` block,
**When** I read it,
**Then** it lists at minimum: `Read(.envrc*)`, `Read(**/.env*)`, `Read(.secrets*)`, `Read(/home/dev/.claude/**)`, `Read(/home/dev/.config/gh/**)`, `Bash(env)`, `Bash(env:*)`, `Bash(printenv*)`, `Bash(cat .envrc*)`, `Bash(cat **/.env*)`, `Bash(cat /proc/*/environ*)`, `Grep(**/.env*)`, `Glob(**/.env*)`.

**Given** the `permissions.allow` block (positive allowlist to reduce prompts),
**When** I read it,
**Then** it lists common dev commands — `Bash(pnpm *)`, `Bash(git status)`, `Bash(git diff*)`, `Bash(git log*)`, `Bash(ls *)`, `Bash(tsc *)` — per Claude Code's glob syntax.

**Given** `.claude/settings.local.json` is user-specific (gitignored),
**When** a fork operator wants to extend locally,
**Then** `.claude/settings.local.json` overrides the committed settings per Claude Code's precedence rules
**And** `AGENTS.md` documents that fork operators must NOT weaken the committed deny list locally (honour system, lint-flagged where detectable).

**Given** a Claude session (interactive or Ralph),
**When** Claude attempts a denied tool call in a permission-prompt-enabled session (non-Ralph),
**Then** the tool call is rejected by Claude Code's permission layer
**And** the rejection surfaces a deny-rule pointer.

**Given** a Ralph session running with `--dangerously-skip-permissions`,
**When** Claude attempts a denied tool call,
**Then** the permissions layer is bypassed but the Story 2.16 hook catches it
**And** NFR5a holds because hooks are the Ralph-path defense.

**Given** the fresh-fork template path,
**When** `packages/keel-templates/` ships the seed `.claude/settings.json`,
**Then** a fresh `create-keel-app` (Epic 15a) materialises it at the new fork's repo root
**And** no manual setup is required.

##### Story 2.16: Claude PreToolUse hooks for secret-file denylist (Ralph-compatible)

As a substrate maintainer,
I want Claude Code PreToolUse hooks at `.claude/hooks/block-secret-access.sh` that intercept `Bash`, `Read`, `Grep`, `Glob` tool calls and reject patterns matching secret files or environment dumps,
So that the secret-access barrier holds even when Ralph runs with `--dangerously-skip-permissions` — hooks execute regardless of permission mode (NFR5a).

**Acceptance Criteria:**

**Given** the committed `.claude/settings.json` from Story 2.15,
**When** I read its `hooks` block,
**Then** `PreToolUse` hooks are registered for `Bash`, `Read`, `Grep`, `Glob`
**And** each invokes `.claude/hooks/block-secret-access.sh` with the tool name + arguments on stdin (per Claude Code's hook protocol).

**Given** the hook script at `.claude/hooks/block-secret-access.sh`,
**When** it is invoked,
**Then** it reads the tool-call JSON from stdin and rejects calls matching any of:
- **Secret-access denylist:**
  - Bash commands: `env` (bare), `printenv*`, `cat .envrc*`, `cat **/.env*`, `cat /proc/*/environ*`, `export` (bare), `set` (bare)
  - Read paths: `.envrc*`, `**/.env*`, `.secrets*`, `/home/dev/.claude/**`, `/home/dev/.config/gh/**`, `/proc/*/environ`
  - Grep / Glob patterns: anything resolving into the above paths
- **Self-protection denylist (hook + settings cannot be tampered from inside the session):**
  - Edit / Write paths: `.claude/settings.json`, `.claude/settings.local.json`, `.claude/hooks/**`, `.git/hooks/**`
  - Bash commands mutating those paths: `rm .claude/settings*`, `rm .claude/hooks/*`, `rm .git/hooks/*`, `mv .claude/settings*`, `mv .claude/hooks/*`, `chmod * .claude/hooks/*`, `chmod * .git/hooks/*`, `tee .claude/settings*`, `tee .claude/hooks/*`, `sed -i * .claude/settings*`, `sed -i * .claude/hooks/*`, `echo * > .claude/settings*`, `echo * > .claude/hooks/*`, `cp * .claude/settings*`, `cp * .claude/hooks/*`
  - Bash commands that would bypass git gates: `git commit * --no-verify`, `git push * --no-verify`

**And** rejected calls return a structured JSON response `{"decision": "block", "reason": "<rule-id>", "match": "<matched-pattern>"}` where rule-id is one of `secret-access-denylist` or `hook-self-protection`.

**Given** a rejected tool call during a Ralph iteration,
**When** the block occurs,
**Then** the event is appended to `.ralph/logs/<iter-id>/blocked-tool-calls.jsonl`
**And** the line schema is `{timestamp, iteration_id, tool, args_redacted, rule_id}` (args_redacted = args with any secret-ish values replaced by `<redacted>`).

**Given** the Ralph iteration continues after blocks accumulate,
**When** the halt-logic in Epic 3 inspects the blocked-calls log,
**Then** N blocks within a single iteration (default N=3, configurable in `.ralph/config.toml`) halt the iteration with `reason: "SECURITY_CRITICAL"`
**And** this threshold is pinned here; Epic 3 wires the halt path.

**Given** the hook is a non-toggle-able invariant,
**When** Story 1.8's manifest tracks it,
**Then** an entry `INV-claude-hook-secret-denylist` registers `.claude/hooks/block-secret-access.sh` + `.claude/settings.json` hooks block
**And** Story 1.9's sync-gate catches drift.

**Given** a fork operator wants to extend the denylist (add fork-specific secret paths),
**When** they follow the documented pattern in `AGENTS.md`,
**Then** they create `.claude/hooks/block-secret-access.fork.sh` that the main script invokes
**And** they CANNOT weaken the substrate denylist (hook script hard-codes substrate paths; only additions honoured).

**Given** the hook script is the Ralph-only defense when permissions are skipped,
**When** the security-evidence feed (Epic 4 FR37) consumes `.ralph/logs/<iter-id>/blocked-tool-calls.jsonl`,
**Then** each entry is propagated to `security-evidence.json` under `scans.hook_denials[]`
**And** `severity_max` escalates to `high` if N blocks occurred in an iteration (Epic 4 semantics).

##### Story 2.17: Hook + settings bypass-resistance (git-layer + manifest + S4 + halt)

As a substrate maintainer,
I want the Claude hook + `.claude/settings.json` barrier protected at the git-layer (invariants manifest + pre-merge sync-gate + S4 prompt-injection scan + Ralph halt threshold), not just in-session,
So that even if the in-session hook self-protection is somehow circumvented (novel Claude bypass, race condition, hook-script bug), the tampering cannot land in a commit or survive across iterations (NFR5b).

**Acceptance Criteria:**

**Given** the invariants manifest from Story 1.8,
**When** I inspect it,
**Then** entries exist for each bypass-surface file:
- `INV-claude-hook-secret-denylist` → `.claude/hooks/block-secret-access.sh`
- `INV-claude-settings-deny-rules` → `.claude/settings.json` (with an anchor-delimited region containing the non-toggle-able substrate deny rules)
- `INV-git-hooks-preservation` → `.git/hooks/*` (the prek-installed hooks; tracked indirectly via `packages/keel-invariants/src/prek-hook-manifest.ts` which enumerates the expected hook names and shebang patterns)

**And** each entry carries a `contentHash` scoped to the protected region (allowing fork-specific additions outside anchors without triggering drift).

**Given** Story 1.9's sync-gate,
**When** a PR modifies any of those files within protected regions,
**Then** the sync-gate runs on pre-merge and fails with `content-hash-mismatch` naming the specific invariant ID
**And** the PR cannot be merged without a source-level fork of `packages/keel-invariants/` (per Story 1.6 bypass-prevention pattern).

**Given** the S4 prompt-injection scan from Epic 4,
**When** a commit diff touches `.claude/settings*.json`, `.claude/hooks/**`, or `.git/hooks/**`,
**Then** the scan emits a structured finding (severity: `high`) in `security-evidence.json` under `scans.prompt_injection.findings[]`
**And** the commit is blocked at pre-commit per FR36 severity-threshold
**And** Ralph iteration halts with `reason: "SECURITY_CRITICAL"` (Epic 4 feeds the halt decision).

**Given** the Ralph iteration-level halt logic,
**When** in-session hook-self-protection blocks accumulate (rule-id `hook-self-protection`) at N=3 default per `.ralph/config.toml`,
**Then** the halt-logic writes `.ralph/halt` with `reason: "SECURITY_CRITICAL"` + bypass-attempt context
**And** the next iteration refuses to start until Tthew reviews `blocked-tool-calls.jsonl`.

**Given** a fork operator with a legitimate need to modify the denylist (e.g., removing a rule that causes false positives),
**When** they change `packages/keel-invariants/src/`-level source + update `invariants.manifest.ts` content-hash + update `INVARIANTS.md` anchor + author a signed conventional commit with `feat!:` + PR to `packages/keel-invariants/`,
**Then** the sync-gate passes because source + manifest + docs are in sync
**And** this is the ONLY path to weakening the substrate denylist (requires deliberate intent, git history, and human review).

**Given** Ralph is NOT permitted to author that modification under Epic 3's RS1 3-layer safe-set,
**When** Ralph's PreToolUse hook intercepts an attempted `packages/keel-invariants/src/` edit that touches denylist sources,
**Then** the edit is blocked (L1 install-boundary protection)
**And** only a human committer can authorise the change.

**Given** the `.claude/settings.local.json` user-override path,
**When** a PR attempts to commit `.claude/settings.local.json`,
**Then** the pre-commit gate rejects it (file is gitignored)
**And** the hook self-protection (Story 2.16) blocks in-session creation of the file via Write/Edit.

**Given** CI visibility into bypass attempts,
**When** hook-denial events land in `security-evidence.json`,
**Then** a dedicated dashboard panel (or nightly report — Epic 14 research corpus terrain) surfaces the event count trend
**And** an unusually high bypass-attempt rate is a leading signal of Claude-prompt-injection attack or Ralph regression worth investigating.

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

#### Stories

##### Story 3.1: `packages/ralph/` package + install-boundary via `uv tool install`

As a substrate maintainer,
I want Ralph sourced as a monorepo package at `packages/ralph/` (Python via uv) and installed into the devbox as a non-editable snapshot via `uv tool install --from packages/ralph ralph-harness==<pin>` at container startup,
So that the running Ralph is an install-time snapshot and edits to `packages/ralph/` source within the workspace do not affect the current iteration (RS2 compiler-bootstrap-problem solution; Layer 1 safe-set boundary).

**Acceptance Criteria:**

**Given** the monorepo scaffold from Epic 1,
**When** I inspect `packages/ralph/`,
**Then** the package has `pyproject.toml`, `src/ralph_harness/`, and pnpm+turbo integration (package.json script bridges for lint/test)
**And** it is CI-gated + lint-gated + typecheck-gated like any other workspace package.

**Given** `packages/devbox/ralph-version.json`,
**When** I read it,
**Then** it pins `{ "ralph-harness": "<semver>", "prompt-template-hash": "<sha256>" }`
**And** this file is the stage-identity source of truth.

**Given** the devbox entrypoint (Story 2.1),
**When** the container starts,
**Then** `uv tool install --from packages/ralph ralph-harness==<pin-from-ralph-version.json>` runs as a non-editable install
**And** the installed tool lives at `/home/dev/.local/share/uv/tools/ralph-harness/` in the named Docker volume (NFR10).

**Given** Ralph is installed,
**When** `pnpm ralph:build` or `pnpm ralph:plan` runs inside the devbox,
**Then** execution invokes the installed snapshot (not `packages/ralph/src/`)
**And** edits to `packages/ralph/src/` in the workspace have no effect on the current iteration.

**Given** a user attempts editable install (`uv tool install -e`),
**When** the devbox entrypoint detects it,
**Then** the install is rejected and the entrypoint fails with a pointer to the stage-upgrade story (Story 3.27).

##### Story 3.2: Ralph multi-iteration loop with `claude -p` + effort settings

As a fork operator,
I want `ralph.py` (inherited from the current `ralph-bmad` repo) running inside the devbox as a Textual TUI, spawning `claude -p` subprocesses with adaptive thinking and explicit `effort` settings (default `xhigh` for build, `high` for plan),
So that Ralph executes multi-iteration loops against `.ralph/@plan.md` with the foundational harness wiring in place (FR7 base).

**Acceptance Criteria:**

**Given** the installed ralph-harness snapshot (Story 3.1),
**When** I run `pnpm ralph:build` inside the devbox,
**Then** `ralph.py` starts, reads `.ralph/@plan.md`, and spawns `claude -p` as a subprocess
**And** the subprocess receives `--effort xhigh` plus `--permission-mode` set to the documented Ralph-mode default.

**Given** `pnpm ralph:plan`,
**When** I run it,
**Then** `claude -p` is spawned with `--effort high` (not `xhigh`).

**Given** a running iteration,
**When** the subprocess emits stream-json,
**Then** `ralph.py` reads it, renders progress in the TUI (baseline chrome; re-themed in Story 3.33), and writes to `.ralph/logs/<iter-id>/iteration.jsonl`.

**Given** an iteration completes normally,
**When** the subprocess exits zero,
**Then** `ralph.py` loops to the next iteration
**And** the loop continues until a halt condition (Stories 3.17–3.19) or `max_iterations` is reached.

**Given** Ralph is inherited from `ralph-bmad`,
**When** I inspect `packages/ralph/src/ralph_harness/`,
**Then** `ralphDisposition: fork` is documented in `packages/ralph/README.md` with monthly upstream-diff review obligation (Epic 15 territory).

##### Story 3.3: Prompt template seeds (`PROMPT_build.template.md`, `PROMPT_plan.template.md`)

As a substrate maintainer,
I want `packages/keel-templates/src/{PROMPT_build,PROMPT_plan}.template.md` as pinned seed files that Epic 15's `create-keel-app` materialises into `.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md` on fresh forks,
So that every fork starts from the substrate's pinned prompt-set — non-drift-able per major Keel version (NFR29a).

**Acceptance Criteria:**

**Given** `packages/keel-templates/src/`,
**When** I inspect the directory,
**Then** `PROMPT_build.template.md` and `PROMPT_plan.template.md` exist
**And** each file's header names the Keel version + tested Claude model generation (Opus 4.7 at 1.0 cut).

**Given** a templated variable syntax,
**When** I read the template files,
**Then** fork-specific substitutions (e.g., `{{ fork.name }}`, `{{ fork.tenancy }}`) use a documented placeholder convention
**And** `packages/keel-templates/README.md` documents the substitution shape.

**Given** the materialisation contract,
**When** Epic 15's `create-keel-app` runs,
**Then** it copies the templates into `.ralph/` and performs substitutions (Epic 15's job; this story provides the source)
**And** the fork's `.ralph/PROMPT_build.md` + `PROMPT_plan.md` match the templates minus substitutions.

**Given** NFR29a pins prompts per major Keel version,
**When** a minor Keel version ships,
**Then** prompt-set is unchanged (verified by CI against a pinned content-hash in `packages/devbox/ralph-version.json`'s `prompt-template-hash`).

**Given** a major Keel version cuts,
**When** prompts diverge,
**Then** the delta is recorded in release notes with tested-model-generation reference.

##### Story 3.4: Orient-phase contract (8 pinned steps)

As Ralph,
I want a pinned 8-step orient sequence at the top of every iteration — (1) epic/story, (2) plan file, (3) knowledge files, (4) phase-gate, (5) application source, (6) budget headroom, (7) native task list, (8) PR/CI state — documented in `docs/invariants/ralph-execute.md` and hard-coded in `PROMPT_build.md`,
So that every iteration starts from the same authoritative context and skipping any step fails the iteration self-check (FR14f).

**Acceptance Criteria:**

**Given** `PROMPT_build.template.md` from Story 3.3,
**When** I read the orient section,
**Then** the 8 steps are enumerated verbatim
**And** each step has a one-line purpose + required output (e.g., "Step 1: read current epic+story; output: epic id, story id, acceptance criteria summary").

**Given** `docs/invariants/ralph-execute.md`,
**When** I read it,
**Then** the 8-step sequence is documented with rationale for each step
**And** the doc is registered as an invariant (`INV-ralph-orient-8-step`) in Story 1.8's manifest.

**Given** Ralph is mid-iteration,
**When** the orient phase runs,
**Then** each step's output is logged to `.ralph/logs/<iter-id>/orient.jsonl`
**And** any missing step fails the iteration self-check (Ralph halts or surfaces the skip in stream-json for the halt-detection layer).

**Given** orient step 3 reads knowledge files (`AGENTS.md`, `CLAUDE.md`, `RALPH.md`),
**When** Ralph reads them,
**Then** Ralph also reads `.ralph-safe-set.yaml` (Story 3.24) as part of step 3 — self-aware safety boundary.

**Given** orient step 7 reads the native task list,
**When** Ralph hydrates in-flight work (Story 3.10),
**Then** active tasks (max 3) are surfaced as the starting context for this iteration.

##### Story 3.5: Execute-phase contract (one task per iteration; spine; compound NOW rejection; XL decomposition)

As Ralph,
I want a pinned execute-phase spine — orient → execute → commit → update IP → pre-push quality gate → pre-push CI gate → push → exit — enforced as exactly ONE task per iteration, with compound NOW tasks rejected at orient, XL tasks (≥60K tokens) decomposed before start, and each BMad-workflow invocation consuming one full iteration,
So that iteration atomicity + budget predictability hold (FR14g, NFR4b XL decomposition).

**Acceptance Criteria:**

**Given** `PROMPT_build.template.md`,
**When** I read the execute section,
**Then** the 7-step spine is pinned verbatim (orient → execute → commit → update IP → pre-push quality gate → pre-push CI gate → push → exit)
**And** the "ONE task per iteration" rule is pinned as non-toggle-able.

**Given** an iteration's orient reads the NOW task,
**When** the task contains "AND" (compound task),
**Then** Ralph rejects the task at orient
**And** the task is decomposed into separate NOW items in `.ralph/@plan.md` (the iteration exits; decomposition lands in the plan file for the next iteration).

**Given** an iteration estimates task size,
**When** the estimated token cost is ≥60K,
**Then** the task is rejected as XL
**And** decomposed pre-start per NFR4b (iteration exits cleanly; decomposed tasks land in @plan.md).

**Given** a story invoked via `/bmad-dev-story` has ≥3 tasks,
**When** orient reads the story,
**Then** Ralph rejects the bulk invocation
**And** decomposes per-iteration (each task in its own iteration).

**Given** a BMad-workflow skill invocation (e.g., `/bmad-create-story`),
**When** Ralph picks it up,
**Then** the entire invocation consumes one full iteration
**And** no other task executes in that iteration.

**Given** the spine completes successfully,
**When** the commit + push land,
**Then** the iteration exits with `exit 0`
**And** Ralph loops to the next iteration.

##### Story 3.6: PR-lifecycle state machine `.ralph/lib/pr-state.ts` + 3 anti-constraints

As Ralph,
I want a pure TypeScript state-machine function `transition(pr_state, epic_state) → action` at `.ralph/lib/pr-state.ts`, invoked via `tsx`, reading authoritative PR state from `gh pr view --json state,isDraft,reviewDecision,statusCheckRollup`,
So that iteration actions are schema-versioned and the 3 anti-constraints (no EPIC_DONE while Draft; no Draft→Open until all tasks complete; no Draft review-feedback) are non-toggle-able invariants (FR14h, R3).

**Acceptance Criteria:**

**Given** `.ralph/lib/pr-state.ts`,
**When** I inspect it,
**Then** it exports `transition(pr_state, epic_state): Action`
**And** the function is pure (no I/O; no randomness; no Date.now()).

**Given** the function is invoked via `tsx`,
**When** Ralph calls it mid-iteration,
**Then** Ralph first runs `gh pr view --json state,isDraft,reviewDecision,statusCheckRollup` and passes the JSON output as input
**And** the function returns a typed `Action` (e.g., `merge | push-and-continue | monitor-ci | halt-epic-done | await-merge`).

**Given** the 6-row decision matrix,
**When** I read the function's internal switch (or data-driven implementation),
**Then** all 6 rows are documented with input conditions and output actions
**And** the matrix is schema-versioned (`PR_STATE_MATRIX_VERSION = "1.0"` constant).

**Given** the 3 anti-constraints,
**When** the function encounters these inputs, each returns `halt` with the named violation error:
- PR state = Draft AND Ralph intends EPIC_DONE → "anti-constraint-1 violated"
- Implementation tasks incomplete AND Ralph intends Draft→Open → "anti-constraint-2 violated"
- PR state = Draft AND review feedback present AND Ralph intends to address → "anti-constraint-3 violated"

**And** the invariant is registered in Story 1.8's manifest (`INV-ralph-pr-lifecycle-anti-constraints`).

##### Story 3.7: Pre-push CI gate (`gh pr checks` before push; in-progress → queue Monitor PR CI)

As Ralph,
I want every iteration to run `gh pr checks` before `git push`, blocking the push if any check is in-progress or pending, queueing "Monitor PR CI" at QUEUE top, committing the IP update locally, and exiting without pushing,
So that I never race CI with a parallel push (FR14i).

**Acceptance Criteria:**

**Given** the execute-phase spine (Story 3.5),
**When** the "pre-push CI gate" step runs,
**Then** Ralph invokes `gh pr checks <pr-number>` and parses the output.

**Given** all checks are `success` or `neutral`,
**When** the gate passes,
**Then** the push proceeds normally
**And** the iteration exits cleanly.

**Given** any check is `in_progress`, `pending`, or `queued`,
**When** the gate fails-soft,
**Then** Ralph queues a new task "Monitor PR CI" at QUEUE top of `.ralph/@plan.md`
**And** the IP (plan file) update is committed locally
**And** the iteration exits WITHOUT pushing (unpushed commits carry to next iteration).

**Given** any check is `failure` or `cancelled`,
**When** the gate detects failure,
**Then** Ralph queues a triage task at QUEUE top with `{failing_check_name, root_cause_note, fix_approach}`
**And** the iteration exits.

**Given** an unpushed commit from the prior iteration,
**When** the next iteration starts,
**Then** orient step 8 (PR/CI state) detects the unpushed commit
**And** Ralph resumes the Monitor PR CI task.

##### Story 3.8: `.ralph/@plan.md` schema (NOW/QUEUE/BLOCKED/DONE/Context)

As Ralph,
I want `.ralph/@plan.md` to conform to a pinned schema with sections NOW / QUEUE / BLOCKED / DONE / Context (fix tasks at QUEUE top), validated against `packages/keel-invariants/src/schemas/plan.schema.json`,
So that the plan file is machine-parseable and structure drift is rejected at pre-commit (FR14k plan side).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/src/schemas/plan.schema.json`,
**When** I inspect it,
**Then** it defines the plan-file shape: `{ now: Task[], queue: Task[], blocked: Task[], done: Task[], context: string }`
**And** each Task shape includes `{ id, title, required_tests: RequiredTest[], created_at, status }`.

**Given** the plan-file template,
**When** a fresh fork materialises `.ralph/@plan.md`,
**Then** the file has H2 headers for each section in the pinned order (NOW, QUEUE, BLOCKED, DONE, Context)
**And** order cannot be rearranged without schema violation.

**Given** a pre-commit hook validates `@plan.md`,
**When** a commit edits it,
**Then** the hook runs `check-plan-schema.ts` against `plan.schema.json`
**And** schema violations reject the commit.

**Given** fix tasks,
**When** Ralph queues a fix,
**Then** the fix task goes at QUEUE **top** (not bottom)
**And** this ordering rule is encoded in the schema and enforced at validation.

**Given** the context section,
**When** Ralph updates it,
**Then** the section is append-only per the RS6 lint guardrails (Story 3.23)
**And** historical entries are immutable.

##### Story 3.9: `.ralph/halt` pinned JSON schema + closed reason enum

As a substrate maintainer,
I want `.ralph/halt` to carry pinned JSON `{reason, epic, pr, iteration_id, timestamp}` with a closed reason enum (`EPIC_DONE | AWAIT_MERGE | BUDGET_EXHAUSTED | CI_BLOCKED | SECURITY_CRITICAL | RALPH_STAGE_REGRESSION`), schema at `packages/keel-invariants/src/schemas/halt.schema.json`,
So that halt handling is machine-readable and unknown reasons cannot leak into the pipeline (FR14k halt side + RS3 new reason).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/src/schemas/halt.schema.json`,
**When** I inspect it,
**Then** the schema defines the 5 fields (reason, epic, pr, iteration_id, timestamp) with types
**And** `reason` is `enum` with values `EPIC_DONE | AWAIT_MERGE | BUDGET_EXHAUSTED | CI_BLOCKED | SECURITY_CRITICAL | RALPH_STAGE_REGRESSION`.

**Given** Ralph writes `.ralph/halt`,
**When** the JSON is emitted,
**Then** it validates against the schema
**And** an unknown reason causes Ralph to refuse the write and instead emit `SECURITY_CRITICAL` with a sub-reason for visibility.

**Given** the TUI reads `.ralph/halt`,
**When** a halt occurs,
**Then** the TUI's halt banner (Story 3.33) displays the reason + context.

**Given** Ralph is restarted after a halt,
**When** `.ralph/halt` exists,
**Then** Ralph refuses to start a new iteration
**And** exits with the halt reason
**And** the halt sentinel must be explicitly cleared (manual delete, or `pnpm ralph:stop` with a new reason).

**Given** the schema is in the invariants manifest,
**When** Story 1.8 tracks it,
**Then** `INV-ralph-halt-schema` registers it
**And** adding/removing a reason without manifest+docs update fails the sync gate (Story 1.9).

##### Story 3.10: Native Claude Code task list as crash journal

As Ralph,
I want the native Claude Code task list (via `CLAUDE_CODE_TASK_LIST_ID` env) used as a crash journal — max 3 active tasks, survives hard kills, hydrated by orient step 7,
So that if the devbox crashes or Ralph is force-killed, the next iteration recovers in-flight work without state loss (FR14k).

**Acceptance Criteria:**

**Given** the Ralph harness starts,
**When** the first iteration begins,
**Then** `CLAUDE_CODE_TASK_LIST_ID` is set (inherited or generated) and all subsequent iterations in the same session use it
**And** the native task list is scoped to Ralph's session.

**Given** the 3-active-task cap,
**When** Ralph tries to create a 4th active task,
**Then** the oldest "in-progress" task is first marked `pending` or completed
**And** the cap is never exceeded.

**Given** Ralph is force-killed mid-iteration,
**When** Ralph restarts,
**Then** orient step 7 queries the native task list via Claude Code API
**And** in-flight tasks are surfaced as the resumption point for the current iteration.

**Given** a normal iteration completes,
**When** the task is marked done,
**Then** the task-list entry transitions to `completed`
**And** the `done` entry is preserved in the list (not deleted) for audit.

**Given** the task list is long-lived,
**When** it exceeds a size cap (e.g., 100 entries),
**Then** completed entries older than a threshold are archived or pruned per a documented policy.

##### Story 3.11: `Required tests:` manifest (content-hashed, append-only, stable test-ID) in @plan.md

As Ralph,
I want every task in `.ralph/@plan.md` to carry a `Required tests:` manifest as a fenced `<!-- task:auto:<id> -->` block with entries `{id, path, hash}` and a `manifest_hash` footer, content-hashed + append-only within a task-open→task-done window,
So that tests required by a task cannot be silently dropped or weakened (FR14a + FR14a2).

**Acceptance Criteria:**

**Given** a task in `.ralph/@plan.md`,
**When** I inspect it,
**Then** a fenced block `<!-- task:auto:<task-id> -->` wraps a `Required tests:` list
**And** each entry has `{id: "<path>::<fully-qualified-test-name>", path: "<path>", hash: "<sha256-of-assertion-body>"}`.

**Given** the block has a footer,
**When** I read it,
**Then** `<!-- manifest_hash: <sha256-of-all-entries> -->` concludes the block
**And** the manifest_hash is deterministically derivable from the entries.

**Given** the append-only invariant,
**When** Ralph edits a task's manifest mid-iteration (task still open),
**Then** only appending new entries is allowed
**And** removing or renaming an existing entry requires an `expand:` annotation (Story 3.12).

**Given** `plan.schema.json` from Story 3.8,
**When** it validates `@plan.md`,
**Then** the fenced block structure is validated
**And** missing entries or malformed hashes fail schema validation.

**Given** a test's assertion body is modified in source,
**When** the manifest is consulted,
**Then** the stored `hash` is the hash captured at task-open (not real-time) — this enables the pre-merge-fast gate (Story 3.13) to detect mid-task mutation.

##### Story 3.12: Authorship separation + `expand:` countersignature

As a substrate maintainer,
I want the planning skills (`bmad-create-story`, `bmad-agent-dev` in planner role) to be the ONLY authors of the `Required tests:` manifest, with build-mode agents strictly read-only; mid-task additions/removals require an `expand:` annotation countersigned by the planning skill on the next iteration,
So that a build-mode agent cannot quietly weaken its own test requirements (FR14a1).

**Acceptance Criteria:**

**Given** a build-mode iteration (Ralph invoking `bmad-dev-story` or similar),
**When** the agent attempts to modify the `Required tests:` manifest within the fenced block,
**Then** the pre-commit hook rejects the edit
**And** the commit fails with a "manifest-authorship-violation" message.

**Given** a build-mode agent discovers a missing required test mid-iteration,
**When** it needs to add a test,
**Then** it logs an `expand: { reason, proposed_entries[] }` event in `.ralph/logs/<iter-id>/expand-requests.jsonl`
**And** the iteration exits with the request for the next iteration.

**Given** the next iteration runs,
**When** a planning skill (orient detects the expand request) executes,
**Then** the planning skill reviews the request and countersigns by adding the entries to the manifest with a `<!-- countersigned: <planning-skill-id> -->` annotation
**And** the build iteration can resume with the updated manifest.

**Given** an expand request without countersignature,
**When** the following iteration detects it,
**Then** the iteration halts until a planning-skill countersignature is added
**And** this prevents "eventually give up and run without the missing test."

**Given** the invariant is registered,
**When** Story 1.8 tracks it,
**Then** `INV-ralph-manifest-authorship-separation` is in the manifest.

##### Story 3.13: Pre-merge-fast manifest integrity gate

As a substrate maintainer,
I want a pre-merge-fast gate that inspects every task's `Required tests:` manifest, rejecting shrinkage, rename, or hash-mutation without a signed `expand:` annotation countersigned by a planning skill,
So that manifest tampering is impossible during PR review (FR14a2 teeth).

**Acceptance Criteria:**

**Given** a PR modifies `.ralph/@plan.md`,
**When** the pre-merge-fast job runs,
**Then** a script walks every task's fenced manifest block and compares against the base-branch version.

**Given** a manifest entry was removed,
**When** the comparison runs,
**Then** the gate fails unless the change is accompanied by a countersigned `expand:` annotation
**And** the failure message names the removed test ID.

**Given** a manifest entry was renamed,
**When** the comparison runs,
**Then** the gate fails (same rule as removal).

**Given** a manifest entry's `hash` was mutated without a corresponding stable-test-body change,
**When** the comparison runs,
**Then** the gate fails — this catches "silently lowered assertion strength."

**Given** a well-formed expand (new entries added + countersigned),
**When** the comparison runs,
**Then** additions are allowed
**And** the gate passes.

**Given** the gate is part of pre-merge-fast (Epic 13),
**When** Epic 13 wires the CI workflow,
**Then** this gate runs before RLS tests + import-boundary tests
**And** failure blocks PR merge.

##### Story 3.14: Mutation-floor contract at 1.0 (warn-mode; stryker/mutmut scanner + report)

As a substrate maintainer,
I want the `Required tests:` manifest to support a `mutation_floor: 0.80` flag for tasks tagged `high-risk` (RLS policies, generator `expand`, webhook-sig, auth/session, billing-state), with a nightly stryker (TS) / mutmut (Python) scanner emitting a mutation-kill report — enforcement mode `warn` at 1.0, `fail` deferred to 1.x (M1 party-mode amendment),
So that the mutation-testing contract ships at 1.0 without premature fail-mode friction (FR14a3, M1).

**Acceptance Criteria:**

**Given** the manifest schema (Story 3.11),
**When** I add a `mutation_floor` field to the task shape,
**Then** the field is optional; default absent; value is a number 0.0–1.0
**And** tasks tagged `high-risk: true` SHOULD set `mutation_floor: 0.80`.

**Given** a nightly scanner job,
**When** it runs against high-risk slices,
**Then** it invokes `stryker` (TypeScript) or `mutmut` (Python) per file language
**And** emits a report at `.ralph/logs/nightly-<date>/mutation-report.json` with `{task_id, mutant_kill_ratio, killed[], survived[]}`.

**Given** a task's mutation kill ratio is below its `mutation_floor`,
**When** the scanner completes,
**Then** the report records the miss
**And** at 1.0 the scanner exits zero (warn mode) with the miss logged to `security-evidence.json` (Epic 4) as `severity: low`.

**Given** 1.x enforcement is deferred,
**When** NFR28b empirical baseline lands,
**Then** a dedicated 1.x epic flips the enforcement mode to `fail`
**And** this story ships the contract parse path only.

**Given** the `mutation_floor` field lands in `plan.schema.json`,
**When** Story 3.13's pre-merge-fast gate validates,
**Then** malformed values (> 1.0, < 0.0, non-numeric) fail schema validation.

**Given** high-risk slices are enumerated,
**When** I read `docs/invariants/high-risk-slices.md` (part of this story),
**Then** the 5 categories are listed: RLS, generator expand paths, webhook signature verification, auth/session, billing-state.

##### Story 3.15: Per-iteration context meter

As Ralph,
I want structured context-utilisation metrics per iteration written to `.ralph/logs/<iteration-id>/context-meter.json` — advertised-vs-usable context window, specs load, orient load, execute load, output load, percentage utilisation,
So that 40–60% smart-zone targeting (NFR4a) is observable and >80% utilisation triggers clean exit (FR14d).

**Acceptance Criteria:**

**Given** an iteration is mid-execute,
**When** Ralph samples context usage,
**Then** `.ralph/logs/<iter-id>/context-meter.json` is updated with `{advertised_window, usable_window, specs_load, orient_load, execute_load, output_load, utilisation_pct, timestamp}`.

**Given** utilisation exceeds 80%,
**When** the meter updates,
**Then** Ralph triggers a clean exit (finish current task; commit; push; exit; don't start the next task)
**And** the exit reason is logged as budget-driven (not halt; controlled end-of-iteration).

**Given** utilisation is between 60–80%,
**When** the meter updates,
**Then** a flag is raised in the TUI (Story 3.33 halt banner pre-cursor) for drift observability
**And** Ralph continues the iteration.

**Given** utilisation is below 30%,
**When** the meter updates,
**Then** Ralph flags the iteration as under-utilised in `.ralph/logs/<iter-id>/notes.jsonl`
**And** this feeds Epic 14's research corpus for "are we leaving budget on the table?" analysis.

**Given** the meter schema is invariant,
**When** Story 1.8 tracks it,
**Then** `INV-ralph-context-meter-schema` is registered.

##### Story 3.16: Execution budget headroom (25K push-buffer; XL decomposition; exhaustion signals)

As Ralph,
I want a 25K push-buffer reserved at every iteration end; an iteration with <25K remaining exits cleanly; XL tasks (≥60K tokens) are decomposed pre-start; context-exhaustion signals (repeated tool-call failures, truncated subagent responses, ≥3 retries without progress) trigger immediate clean exit,
So that budget exhaustion never strands an iteration mid-commit (NFR4b).

**Acceptance Criteria:**

**Given** the context meter (Story 3.15),
**When** advertised window minus utilisation drops below 25K,
**Then** Ralph exits cleanly — finishes the current sub-step, commits what's safe to commit, pushes, exits.

**Given** an XL task estimate,
**When** orient (Story 3.5) sees a task ≥60K,
**Then** the task is decomposed into smaller tasks in `.ralph/@plan.md`
**And** the current iteration exits without executing the XL task.

**Given** exhaustion signals,
**When** any of these trigger — repeated (≥3) tool-call failures on the same call; truncated subagent responses; ≥3 retries without measurable progress —
**Then** Ralph triggers an immediate clean exit
**And** a note is logged to `.ralph/logs/<iter-id>/notes.jsonl` with the trigger type.

**Given** tokenizer differences (NFR4),
**When** the substrate is retuned for a new model generation (Opus 4.7 vs 4.6: ~35% more tokens/byte),
**Then** the 25K push-buffer and 60K XL threshold are re-baselined per the tested model
**And** the values are configurable in `.ralph/config.toml` with sane defaults for Opus 4.7.

##### Story 3.17: Halt on consecutive same-test failures (default N=3)

As a substrate maintainer,
I want Ralph to halt the loop on N consecutive failures of the SAME test (identified by stable test-ID, counted across iterations within a single session), where N is configurable via `.ralph/config.toml` (`halt_on_same_test_fails`, default N=3),
So that repeated flaky or genuine failures don't burn budget indefinitely (FR8, FR14l).

**Acceptance Criteria:**

**Given** `.ralph/config.toml`,
**When** I inspect it,
**Then** `halt_on_same_test_fails = 3` is set with an inline comment explaining the semantic.

**Given** a test fails in iteration N with stable test-ID `T`,
**When** the same test fails in iterations N+1 and N+2 (all with test-ID `T`),
**Then** after the 3rd consecutive failure, Ralph writes `.ralph/halt` with `reason: "SECURITY_CRITICAL"` if test is tagged high-risk, else a generic budget-exhaustion-adjacent reason
**And** the halt payload includes `{failing_test_id: T, fail_count: 3}`.

**Given** intermittent failures (test fails, passes, fails, passes),
**When** counted,
**Then** the counter resets on a pass
**And** the halt is never triggered.

**Given** different tests failing,
**When** test A fails, then B, then A,
**Then** A's counter is 2 (non-consecutive; counter semantics documented as "consecutive" per test-ID)
**And** halt is not triggered for A until A fails 3 in a row with no intervening pass.

**Given** N is fork-configurable,
**When** a fork operator sets `halt_on_same_test_fails = 5`,
**Then** Ralph honours the fork's value
**And** reviews at M9 against observed false-halt / missed-halt rates (Epic 14 terrain).

##### Story 3.18: Halt on task-budget exhaustion

As Ralph,
I want to halt the loop on task-budget exhaustion per iteration, using the model-visible `task_budget` advisory counter (beta header `task-budgets-2026-03-13`, ≥ 20K) where available and `max_tokens` as the hard invisible ceiling,
So that budget is bounded per iteration and exhaustion is observable (FR9).

**Acceptance Criteria:**

**Given** the Claude API supports the `task-budgets-2026-03-13` beta header,
**When** Ralph spawns `claude -p`,
**Then** the header is passed
**And** `task_budget` is set to a minimum of 20K tokens for build iterations (configurable in `.ralph/config.toml`).

**Given** the `task_budget` is exceeded mid-iteration,
**When** the model-visible counter hits zero,
**Then** the model receives a budget-exhaustion signal
**And** Ralph halts with `reason: "BUDGET_EXHAUSTED"` + metadata on which budget triggered.

**Given** the hard `max_tokens` ceiling,
**When** the iteration exceeds it,
**Then** the subprocess terminates with a `max_tokens` stop reason
**And** Story 3.19 distinguishes this from `model_context_window_exceeded` in halt branching.

**Given** the API does NOT support the beta header,
**When** Ralph detects absence,
**Then** Ralph falls back to `max_tokens` as the only budget mechanism
**And** logs the degraded mode.

**Given** the budget-exhaustion halt,
**When** written,
**Then** `.ralph/halt` contains `{reason: "BUDGET_EXHAUSTED", epic, pr, iteration_id, timestamp, exhaustion_type: "task_budget" | "max_tokens"}`.

##### Story 3.19: Halt branching (`max_tokens` vs `model_context_window_exceeded`)

As a substrate maintainer,
I want Ralph to branch halt handling between `max_tokens` and `model_context_window_exceeded` stop reasons, persisting which applied to each iteration for budget-re-baseline analysis,
So that empirical budget data feeds NFR4 tokenizer-aware re-baselining per model generation (FR9a).

**Acceptance Criteria:**

**Given** the subprocess exits,
**When** the stream-json stop-reason is `max_tokens`,
**Then** Ralph logs `{stop_reason: "max_tokens", iteration_id, advertised_window, used_tokens}` to `.ralph/logs/<iter-id>/stop-reason.json`.

**Given** the subprocess exits,
**When** the stream-json stop-reason is `model_context_window_exceeded`,
**Then** Ralph logs `{stop_reason: "model_context_window_exceeded", iteration_id, advertised_window, used_tokens}`
**And** the two reasons are distinguished in the halt payload and research corpus.

**Given** Epic 14 consumes stop-reason logs,
**When** the research corpus aggregates them,
**Then** the distribution of max_tokens vs model_context_window_exceeded across iterations informs NFR4 re-baselining.

**Given** the branching is in the halt schema,
**When** Story 3.9's halt JSON is written,
**Then** `{reason: "BUDGET_EXHAUSTED", exhaustion_type: "max_tokens" | "model_context_window_exceeded"}` is carried
**And** the enum for `exhaustion_type` is pinned.

##### Story 3.20: Subagent fan-out budget + 1-Sonnet-per-build/test/lint invariant

As a substrate maintainer,
I want a substrate-default subagent fan-out cap of 250 Sonnet-class parallel subagents (ceiling 500), with a non-toggle-able invariant of at most 1 Sonnet subagent per build, test, or lint command per iteration,
So that parallel read/search is leveraged while build/test/lint coherence is preserved (FR14c).

**Acceptance Criteria:**

**Given** `PROMPT_build.template.md`,
**When** I read the subagent section,
**Then** the cap `default_subagent_fan_out: 250` and `ceiling: 500` are pinned in the template
**And** forks can tune down but not above the ceiling.

**Given** the 1-Sonnet invariant,
**When** I read the prompt contract,
**Then** "for each build/test/lint command, exactly one Sonnet subagent" is pinned verbatim
**And** registered in Story 1.8's manifest as `INV-ralph-subagent-build-test-lint-serial`.

**Given** Ralph attempts to spawn 2 parallel `pnpm test` subagents,
**When** the invariant is checked (at prompt contract layer),
**Then** the spawning is rejected
**And** Ralph halts or exits cleanly (prompt contract enforcement).

**Given** parallel read/search subagents,
**When** Ralph spawns 100 Sonnet Read-only subagents,
**Then** they run concurrently up to the 250 default cap
**And** no invariant is violated.

**Given** the cap is configurable,
**When** `.ralph/config.toml` sets a different `default_subagent_fan_out`,
**Then** Ralph honours the fork's value within [1, 500] range
**And** out-of-range values are rejected at config load.

##### Story 3.21: Plan-staleness trigger + auto plan-mode regeneration

As Ralph,
I want to detect plan staleness — 5 no-progress iterations OR 72h since plan-artefact was last updated — and auto-schedule a plan-mode regeneration as the next iteration,
So that stuck build-mode loops don't burn budget on an outdated plan (FR14b).

**Acceptance Criteria:**

**Given** orient step 2 reads `.ralph/@plan.md`,
**When** Ralph tracks progress,
**Then** a counter `no_progress_iterations` increments each iteration where no NOW task transitions to DONE
**And** the counter resets on a DONE transition.

**Given** `no_progress_iterations >= 5`,
**When** the next iteration starts,
**Then** Ralph schedules a plan-mode regeneration as the NOW task
**And** auto-invokes `pnpm ralph:plan` (or equivalent flow within build mode).

**Given** the plan-artefact file's mtime is older than 72 hours,
**When** the next iteration starts,
**Then** Ralph schedules a plan-mode regeneration
**And** the trigger reason is logged as `plan_staleness_age`.

**Given** both triggers are configurable,
**When** `.ralph/config.toml` sets `plan_staleness_no_progress_threshold = 10` or `plan_staleness_age_hours = 96`,
**Then** Ralph honours the fork's values.

**Given** a plan-mode regeneration runs,
**When** it completes,
**Then** the no-progress counter resets
**And** the plan-artefact mtime updates.

##### Story 3.22: Knowledge-file upkeep contract (FR14j warn-on-no-update)

As a substrate maintainer,
I want a pre-commit hook that emits a warning (not a hard fail) if none of `AGENTS.md` / `CLAUDE.md` / `RALPH.md` changed AND no justification is in the commit body,
So that knowledge-file upkeep is prompted but not blocked — preserves agent velocity while building observability into "are we learning?" (FR14j).

**Acceptance Criteria:**

**Given** a commit is made,
**When** the pre-commit hook runs,
**Then** it diffs the commit against HEAD and checks if any of `AGENTS.md`, `CLAUDE.md`, `RALPH.md` were modified.

**Given** no knowledge file was modified AND no `Knowledge-files-no-change: <reason>` trailer in the commit body,
**When** the hook runs,
**Then** a warning is surfaced (stderr; does NOT block the commit)
**And** the warning is logged to `.ralph/logs/<iter-id>/knowledge-warnings.jsonl`.

**Given** a knowledge file WAS modified OR the trailer is present,
**When** the hook runs,
**Then** the hook exits silently (no warning).

**Given** Ralph iterations accumulate warnings,
**When** Epic 14's research corpus aggregates them,
**Then** a metric `knowledge_file_update_rate` tracks iteration-to-update ratio.

**Given** the trailer format,
**When** documented in `AGENTS.md`,
**Then** `Knowledge-files-no-change: <reason>` appears as the canonical form (e.g., `Knowledge-files-no-change: trivial refactor`, `Knowledge-files-no-change: test fix`).

##### Story 3.23: L3 lint guardrails (`tools/lint-knowledge-files.ts`)

As a substrate maintainer,
I want a pre-commit lint `tools/lint-knowledge-files.ts` that enforces RALPH.md size cap (500 lines; rotate to `docs/research/ralph-journal/RALPH-archive-YYYY-MM.md`), rejects H1 heading changes (anchor stability), rejects fenced `## SYSTEM` blocks or instruction-like imperatives, enforces URL allowlist, and caps diff size per commit (flag > 200-line edits),
So that L3 knowledge-file drift cannot poison the Ralph context window (RS6).

**Acceptance Criteria:**

**Given** `tools/lint-knowledge-files.ts`,
**When** I inspect it,
**Then** the script is a pure TypeScript file invoked by pre-commit
**And** it walks `AGENTS.md`, `CLAUDE.md`, `RALPH.md`, `.ralph/@plan.md` (entries only, not schema).

**Given** RALPH.md exceeds 500 lines,
**When** the linter runs,
**Then** it emits a hard error with a pointer: "rotate RALPH.md to `docs/research/ralph-journal/RALPH-archive-<YYYY-MM>.md`"
**And** the commit is rejected.

**Given** a commit modifies an H1 heading in any knowledge file,
**When** the linter runs,
**Then** the commit is rejected with "H1 anchor stability violation" — preserves cross-file anchor links.

**Given** a commit introduces `## SYSTEM` or instruction-imperative patterns like `IGNORE PREVIOUS`, `YOU ARE NOW`,
**When** the linter runs,
**Then** the commit is rejected with "instruction-injection pattern" (feeds the S4 scan from Epic 4).

**Given** an external URL is added to `AGENTS.md` or `CLAUDE.md`,
**When** the linter runs,
**Then** the commit is rejected (knowledge files are internal references only; external URLs live in `RALPH.md` which only accepts internal doc paths).

**Given** a commit's knowledge-file diff exceeds 200 lines,
**When** the linter runs,
**Then** a warning is emitted
**And** the commit continues (warn-only for large diffs; reviewer's discretion).

**Given** `.ralph/@plan.md` entries,
**When** a commit modifies existing entries (not just appends new ones),
**Then** the linter rejects the commit — entries are append-only per FR14a2 pattern.

##### Story 3.24: `.ralph-safe-set.yaml` manifest + `tools/check-safe-set.ts` + orient self-awareness

As Ralph,
I want `.ralph-safe-set.yaml` at the repo root enumerating the 3 safe-set layers (L1 install-boundary / L2 auto-merge-on-validation / L3 lint-gated editable), a `tools/check-safe-set.ts` pre-commit hook that routes staged paths per layer, and orient-step-3 reading the manifest so Ralph knows its own safety boundary,
So that self-modification is machine-enforced and Ralph is self-aware of what it can freely edit (RS7).

**Acceptance Criteria:**

**Given** `.ralph-safe-set.yaml`,
**When** I inspect it,
**Then** three top-level keys exist: `layer1_install_boundary`, `layer2_auto_merge_on_validation`, `layer3_ralph_editable_lint_gated`
**And** each key lists path globs per the RS7 reference.

**Given** `tools/check-safe-set.ts`,
**When** a pre-commit hook invokes it,
**Then** staged paths are classified into L1/L2/L3
**And** L1 edits in non-stage-upgrade commits are rejected (see Story 3.27 for the stage-upgrade escape)
**And** L2 edits are routed to Story 3.25's bootstrap-validation
**And** L3 edits are allowed through Story 3.23's lint.

**Given** Ralph's orient step 3 (Story 3.4),
**When** Ralph reads knowledge files,
**Then** it ALSO reads `.ralph-safe-set.yaml`
**And** surfaces the layer map in the iteration context — Ralph "knows" which files are safe to edit.

**Given** the manifest is an invariant,
**When** Story 1.8 tracks it,
**Then** `INV-ralph-safe-set-manifest` is registered
**And** drift is caught by Story 1.9.

**Given** a fork operator wants to add fork-specific paths to a layer,
**When** they edit `.ralph-safe-set.yaml` within documented additions,
**Then** the manifest accepts the additions
**And** forks cannot downgrade a path from L1 to L3 (only upgrade or leave substrate paths as-is).

##### Story 3.25: L2 auto-merge on bootstrap-validation pass (fail → `RALPH_STAGE_REGRESSION`)

As Ralph,
I want commits that edit L2 files (per Story 3.24's manifest) to trigger a pre-merge-slow path-filtered bootstrap-validation — pass → PR auto-mergeable; fail → halt with new `RALPH_STAGE_REGRESSION` reason for Tthew review,
So that self-referential prompt/schema changes gate on validation automatically without human-in-the-loop friction (RS3).

**Acceptance Criteria:**

**Given** a commit touches any L2 path,
**When** the PR pre-merge-slow workflow runs,
**Then** the workflow path-filters to run ONLY the bootstrap-validation steps (Story 3.26) — not the full pre-merge-slow suite
**And** a pass enables auto-merge per the L2 policy.

**Given** the bootstrap-validation passes,
**When** the PR is otherwise green,
**Then** auto-merge fires (GitHub auto-merge on pass)
**And** Ralph's next iteration continues.

**Given** the bootstrap-validation fails,
**When** the workflow completes,
**Then** Ralph's halt-detection reads the CI result
**And** writes `.ralph/halt` with `reason: "RALPH_STAGE_REGRESSION"`
**And** the halt payload includes the failing validation step.

**Given** `RALPH_STAGE_REGRESSION` is a new halt reason,
**When** Story 3.9's halt schema is consulted,
**Then** it is included in the closed enum
**And** its semantics are documented in `docs/invariants/ralph-halt-reasons.md`.

**Given** Tthew reviews a `RALPH_STAGE_REGRESSION` halt,
**When** they resolve the regression manually,
**Then** they clear `.ralph/halt` and push the fix
**And** a post-mortem entry is added to `RALPH.md` (research corpus).

##### Story 3.26: Bootstrap-validation at 1.0 (schema-parse + 30s minimum smoke iteration)

As a substrate maintainer,
I want bootstrap-validation to consist of (a) schema-parse — prompts/plan/halt all parse cleanly — and (b) minimum smoke iteration — 30s synthetic iteration where Ralph orient reads a fixture `@plan.md` with a trivial task, first tool call is `Read` or `Bash`, halt reason matches expected,
So that L2 auto-merge has a fast, real signal at 1.0 without the full structural-invariants oracle (deferred to 1.1 per Murat) (RS4, RS10).

**Acceptance Criteria:**

**Given** a bootstrap-validation run,
**When** step (a) schema-parse executes,
**Then** `PROMPT_build.md` + `PROMPT_plan.md` parse cleanly as markdown + frontmatter
**And** `@plan.md` validates against `plan.schema.json`
**And** `halt.schema.json` parses as valid JSON Schema.

**Given** step (b) minimum smoke iteration,
**When** it executes,
**Then** a 30-second synthetic Ralph iteration runs with a fixture `@plan.md` containing a trivial task (e.g., "Read this file and exit")
**And** the iteration's first tool call is `Read` or `Bash` (asserted by reading the stream-json log)
**And** the halt reason matches the expected synthetic-halt (e.g., `EPIC_DONE` for a one-task fixture).

**Given** either (a) or (b) fails,
**When** bootstrap-validation completes,
**Then** the workflow exits non-zero
**And** Story 3.25 translates this to `RALPH_STAGE_REGRESSION`.

**Given** the full structural-invariants oracle (Murat's k=3 / 2-of-3-match / tool-call-graph / file-path-write / state-transition assertions),
**When** considered at 1.0,
**Then** it is documented as 1.1-deferred in `docs/invariants/ralph-validation-roadmap.md`
**And** this story ships only the schema-parse + minimum smoke.

**Given** the 30s fixture,
**When** it's maintained,
**Then** the fixture lives at `packages/ralph/tests/bootstrap/fixtures/@plan.md` + expected `halt.json`.

##### Story 3.27: Ralph stage-upgrade story class (ralph-version.json bump; pre-merge-slow; reinstall)

As Tthew (or Ralph under L1 boundary),
I want a dedicated story class `ralph-stage-upgrade` that bumps `ralph-version.json` → commits → pre-merge-slow runs bootstrap-validation on the proposed snapshot → pass → next devbox startup reinstalls from the new pin → stage-N+1 runs,
So that L1 runtime-code upgrades follow a controlled path distinct from L2/L3 iteration work (RS2 stage-upgrade).

**Acceptance Criteria:**

**Given** a story tagged `ralph-stage-upgrade`,
**When** orient (Story 3.4) reads it,
**Then** the task is recognised as an L1-permitted edit
**And** Story 3.24's check-safe-set allows L1 path modifications ONLY in this story class.

**Given** the story's execute phase,
**When** Ralph (or Tthew) runs the upgrade,
**Then** `packages/ralph/src/` is edited + `packages/devbox/ralph-version.json` is bumped + a commit is made
**And** the commit message carries `ralph-stage-upgrade:` prefix for machine identification.

**Given** the PR pre-merge-slow,
**When** it runs,
**Then** bootstrap-validation (Story 3.26) runs against the proposed snapshot (simulated install from `packages/ralph/` at the new version)
**And** a pass allows merge.

**Given** merge lands,
**When** the devbox is next started,
**Then** the entrypoint (Story 3.1) reinstalls from the new pin
**And** stage-N+1 Ralph runs in subsequent iterations.

**Given** a fork operator wants to run a stage-upgrade story,
**When** they follow the documented flow in `AGENTS.md`,
**Then** the flow is unambiguous (single commit style; PR check requirements; devbox-restart trigger).

**Given** bootstrap-validation fails on a stage-upgrade PR,
**When** the result surfaces,
**Then** the PR is blocked and Tthew reviews
**And** the halt reason (if Ralph had been running) would be `RALPH_STAGE_REGRESSION`.

##### Story 3.28: Ralph operator commands (detach / `pnpm ralph:status` / `pnpm ralph:stop`)

As a fork operator,
I want operator commands for Ralph — `Ctrl+P Ctrl+Q` detach (without killing the loop), `pnpm ralph:status` to query state without attaching, `pnpm ralph:stop` to halt cleanly by writing `.ralph/halt` with `reason: "EPIC_DONE"`,
So that I can observe + control the Ralph loop from the host without interrupting it (FR10, FR11, FR12).

**Acceptance Criteria:**

**Given** Ralph is attached via TUI inside the devbox,
**When** I press `Ctrl+P Ctrl+Q`,
**Then** `docker attach`'s detach sequence fires
**And** I return to the host shell without killing the container or the Ralph loop
**And** re-attaching via `pnpm devbox:attach` (or `pnpm ralph:build` with Ralph already running) preserves TUI state.

**Given** `pnpm ralph:status`,
**When** I run it from the host,
**Then** it reads `.ralph/logs/<current>/status.json` (a file Ralph updates each iteration with `{iteration_id, now_task, queue_depth, budget_remaining, last_halt_reason}`)
**And** prints a human-readable summary without requiring container attach.

**Given** `.ralph/logs/<current>/status.json` is written by Ralph,
**When** each iteration exits,
**Then** the file is updated atomically (temp-file + rename)
**And** `pnpm ralph:status` never reads a partial write.

**Given** `pnpm ralph:stop`,
**When** I run it,
**Then** the command writes `.ralph/halt` with `{reason: "EPIC_DONE", iteration_id: <current>, timestamp}` (or `BUDGET_EXHAUSTED` if specified via `--reason`)
**And** the next iteration honours the halt and exits.

**Given** `pnpm ralph:stop --force`,
**When** I run it,
**Then** the current iteration is also force-killed (docker exec SIGKILL)
**And** Ralph's crash journal (Story 3.10) enables the next start to recover.

##### Story 3.29: Stream-json iteration logs (`thinking.display = "summarized"`)

As a substrate maintainer,
I want Ralph to persist iteration logs in `stream-json` format at `.ralph/logs/<iter-id>/iteration.jsonl` with `thinking.display = "summarized"` enabled (per Opus 4.7 defaults), per-iteration ID, timestamps, Claude exit status, and test results,
So that every iteration is replayable and debuggable (FR13, NFR33).

**Acceptance Criteria:**

**Given** a Ralph iteration,
**When** `claude -p` runs,
**Then** `--output-format stream-json` is passed
**And** `--thinking-display summarized` is passed (or equivalent config).

**Given** stream-json lines emit,
**When** Ralph reads stdout,
**Then** each line is written verbatim to `.ralph/logs/<iter-id>/iteration.jsonl`
**And** the file is append-only within an iteration.

**Given** the iteration completes,
**When** the subprocess exits,
**Then** a final metadata entry is appended: `{iteration_id, started_at, ended_at, claude_exit_status, stop_reason, test_results: [...]}`.

**Given** an iteration is force-killed,
**When** Ralph restarts,
**Then** the log is still readable (no corrupt partial lines)
**And** orient step 7 (Story 3.4 / Story 3.10) uses the log to hydrate.

**Given** `thinking.display = "summarized"` per NFR33,
**When** the log is inspected,
**Then** thinking blocks appear in summarized form (concise rather than verbose raw thinking)
**And** this reduces log size without losing the decision trace.

##### Story 3.30: Atomic iteration commits (NFR26 pre-commit green-only gate)

As a substrate maintainer,
I want a pre-commit gate that rejects partial-state commits — an iteration commits ONLY a green-test + green-security-evidence state or leaves the repo unchanged,
So that iteration atomicity is machine-enforced and half-finished work never lands on main (NFR26).

**Acceptance Criteria:**

**Given** a pre-commit hook,
**When** a commit runs,
**Then** the hook verifies:
- Every test in the current iteration's `Required tests:` manifest passes
- `security-evidence.json` has `halt_required: false` and `overall_severity_max` below the threshold

**And** a failure at either check rejects the commit.

**Given** a green state,
**When** the hook completes,
**Then** the commit lands normally.

**Given** an iteration fails mid-execute,
**When** Ralph exits without calling commit,
**Then** the working tree may be dirty but nothing lands — next iteration's orient picks up the stale state and decides recovery (rebase, discard, or fix).

**Given** the invariant `INV-ralph-atomic-iteration-commit`,
**When** Story 1.8 tracks it,
**Then** the hook source + its invocation path are registered
**And** drift is caught by Story 1.9.

**Given** a fork operator wants to override (e.g., for a WIP branch),
**When** they attempt `git commit --no-verify`,
**Then** Story 2.16's hook self-protection intercepts the flag
**And** the commit is blocked (no WIP escape).

##### Story 3.31: LLM-as-judge pattern contract (`lib/llm-review.ts`; Growth-tier default)

As a substrate maintainer,
I want the pattern contract for `lib/llm-review.ts` — a fixture that runs a scoped Opus-class subagent against a diff with subjective acceptance criteria, returning pass/fail — to ship at 1.0; fixture invocation is Growth-tier default (opt-in per task via `llm_review: true` flag); failure counts as test failure under FR8 backpressure,
So that non-deterministic acceptance is available to fork operators without 1.0 incurring the default cost (FR14e).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/patterns/llm-review.ts`,
**When** I inspect it,
**Then** the pattern exports `llmReview(diff, criteria): Promise<{pass: boolean, reasoning: string}>`
**And** the implementation is documented as a reference (not a shipped invocation).

**Given** a task with `llm_review: true` in its `Required tests:` manifest,
**When** Ralph's execute phase reaches the pre-commit gate,
**Then** `llm-review.ts` is invoked with the diff + the task's subjective criteria
**And** a `pass: false` result counts as a test failure under FR8 (contributes to halt threshold).

**Given** 1.0 Growth-tier-default behaviour,
**When** a task does NOT set `llm_review: true`,
**Then** the pattern is NOT invoked
**And** the default behaviour is identical to pre-FR14e iterations.

**Given** the pattern contract is pinned,
**When** Story 1.8 tracks it,
**Then** `INV-ralph-llm-review-pattern` registers the contract
**And** fork operators can implement their own `lib/llm-review.ts` as long as the signature matches.

**Given** the LLM-review fixture's budget,
**When** invoked,
**Then** a scoped subagent with a bounded token budget (documented default) runs
**And** the review cost is logged to `.ralph/logs/<iter-id>/llm-review.jsonl`.

##### Story 3.32: Hook-self-protection halt threshold wire-up

As a substrate maintainer,
I want N=3 hook-self-protection blocks (rule-id `hook-self-protection` from Story 2.16) within a single iteration to trigger a `SECURITY_CRITICAL` halt via Ralph's halt machinery (Story 3.9),
So that Claude attempting to bypass the secret-access barrier halts the loop for Tthew review (NFR5a/5b).

**Acceptance Criteria:**

**Given** `.ralph/config.toml`,
**When** I inspect it,
**Then** `halt_on_hook_self_protection_blocks = 3` is set with an inline comment.

**Given** an iteration accumulates 3 `hook-self-protection` blocks (from Story 2.16's `.ralph/logs/<iter-id>/blocked-tool-calls.jsonl`),
**When** Ralph's halt-detection reads the log,
**Then** `.ralph/halt` is written with `{reason: "SECURITY_CRITICAL", sub_reason: "hook-self-protection-threshold-exceeded", block_count: 3, blocked_tool_calls: [...]}`
**And** the next iteration refuses to start.

**Given** 1 or 2 blocks in an iteration (under the threshold),
**When** the iteration completes normally,
**Then** no halt is written
**And** the counter resets at the next iteration.

**Given** a fork operator tunes the threshold,
**When** `halt_on_hook_self_protection_blocks = 5` is set,
**Then** Ralph honours the value
**And** Tthew's review cadence can be adjusted.

**Given** the halt is audit-critical,
**When** it fires,
**Then** Epic 4's security-evidence feed (`scans.hook_denials[]`) has already logged each block
**And** the halt references those entries by block-ID for audit completeness.

##### Story 3.33: Default Textual TUI chrome + Epic 7 re-theme seam

As a fork operator,
I want Ralph's Textual TUI to ship at 1.0 with a default Textual chrome — ribbon, kanban, context-meter, log-tail, halt-banner, command-palette — with a re-theme seam so Epic 7's emitted `packages/devbox/tui/theme.py` (Story 1.12) swaps colours/motion without touching widget structure,
So that Ralph is operable before Epic 7 lands and Epic 7 re-theming is cosmetic-only (UX-DR18, UX-DR58–62).

**Acceptance Criteria:**

**Given** `packages/ralph/src/ralph_harness/tui/`,
**When** I inspect it,
**Then** widgets `ribbon.py`, `kanban.py`, `context_meter.py`, `log_tail.py`, `halt_banner.py`, `command_palette.py` exist
**And** each widget reads its colours/motion/density from a shared theme object.

**Given** the default chrome at 1.0,
**When** no `packages/devbox/tui/theme.py` is present (pre-Epic-7 or user removed),
**Then** the widgets fall back to a built-in default theme with the Direction A palette (Story 1.11) hard-coded
**And** the TUI renders without error.

**Given** Epic 7's emitted `packages/devbox/tui/theme.py` (from Story 1.12),
**When** it is present,
**Then** the TUI imports it at startup
**And** all widget colours/motion/density resolve via the theme module.

**Given** widget structure is stable,
**When** Epic 7 re-themes,
**Then** the changes are limited to `theme.py` values — NOT to widget layout or behaviour
**And** this is enforced by a lint rule ("no theme-token literals in widget files").

**Given** the ribbon widget (`tui.ribbon.01`),
**When** rendered,
**Then** it shows `{mode: build|plan, epic, now_task_slug, budget_remaining, iteration_id}`.

**Given** the kanban widget (`tui.kanban.01`),
**When** rendered,
**Then** it shows NOW / QUEUE / BLOCKED / DONE columns synced from `.ralph/@plan.md`.

**Given** the halt-banner widget (`tui.halt-banner.01`),
**When** `.ralph/halt` exists,
**Then** it renders the halt reason + context prominently
**And** clears when the halt sentinel is cleared.

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

#### Stories

##### Story 4.1: Security-evidence contract v1 (M2 contract-freeze)

As a substrate maintainer,
I want a frozen v1 contract for security evidence — JSON schema at `packages/keel-invariants/src/schemas/security-evidence.schema.json`, scanner exit-code semantics (zero = clean; non-zero = finding above threshold blocks commit), and artefact path convention `.ralph/logs/<iter-id>/security-evidence.json`,
So that all Epic 13 CI-workflow stories have a single stable contract to bind against (M2 party-mode amendment, FR37).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/src/schemas/security-evidence.schema.json`,
**When** I inspect it,
**Then** the schema carries `$schema: "security-evidence-v1"` and defines `{iteration_id, diff_sha, timestamp, scans: {secrets, deps, sast, prompt_injection, hook_denials?, mutation?}, overall_severity_max, halt_required}`
**And** severity enum is `none | low | medium | high | critical`.

**Given** a scanner script integration,
**When** any scanner (Gitleaks, pnpm audit, Semgrep, prompt-injection) runs,
**Then** zero exit = clean (no findings above threshold); non-zero = at least one finding above threshold
**And** this semantic is documented at `docs/invariants/security-evidence-contract.md`.

**Given** the artefact path convention,
**When** Ralph writes evidence,
**Then** the path is `.ralph/logs/<iter-id>/security-evidence.json` (never elsewhere)
**And** the convention is pinned at `INV-security-evidence-path`.

**Given** the invariants manifest tracks this,
**When** Story 1.8 walks it,
**Then** `INV-security-evidence-contract-v1` registers the schema + path + exit-code semantics
**And** Epic 13 workflow-wiring stories depend on this entry (documented dependency edge).

**Given** a breaking change is proposed (v2),
**When** the contract is updated,
**Then** a major-version bump in `$schema` is required
**And** Epic 14's RC3 aggregation CLI is updated alongside.

##### Story 4.2: Gitleaks scanner integration (secrets category)

As a substrate maintainer,
I want Gitleaks wired into the pre-commit scanner pipeline, emitting findings into `security-evidence.json`'s `scans.secrets` category,
So that committed secrets are blocked before they land and every commit has machine-auditable evidence (NFR9, FR37).

**Acceptance Criteria:**

**Given** Gitleaks is installed in the devbox image,
**When** the pre-commit hook invokes it,
**Then** it scans the staged diff
**And** findings are emitted in a structured format.

**Given** the scanner-output adapter,
**When** Gitleaks reports findings,
**Then** each is transformed into `{tool: "gitleaks", findings: [...], severity_max}` and written to `security-evidence.json`'s `scans.secrets` slot.

**Given** a finding above the configured severity threshold,
**When** the scanner completes,
**Then** it exits non-zero per Story 4.1 contract
**And** the commit is blocked.

**Given** no findings,
**When** the scanner completes,
**Then** `scans.secrets = { tool: "gitleaks", findings: [], severity_max: "none" }` is written
**And** the scanner exits zero.

**Given** `.gitleaksignore` exists,
**When** Story 4.12's lint rule runs,
**Then** `.gitleaksignore` is forbidden in `packages/*` (fork-only at repo root).

##### Story 4.3: `pnpm audit --prod` scanner integration (deps category)

As a substrate maintainer,
I want `pnpm audit --prod` wired into the pre-merge-fast pipeline, emitting findings into `security-evidence.json`'s `scans.deps` category,
So that dependency CVEs surface early and block merge when severity is above threshold (NFR14 wiring, FR37).

**Acceptance Criteria:**

**Given** `pnpm audit --prod` runs as part of pre-merge-fast,
**When** it completes,
**Then** its JSON output is parsed and transformed into `{tool: "pnpm-audit", findings: [...], severity_max}` in `scans.deps`.

**Given** a CVSS ≥ 9 finding,
**When** the scanner runs,
**Then** `severity_max: "critical"` is set
**And** `halt_required: true` triggers the immediate halt per Story 4.9.

**Given** a CVSS in 7–8.9 range (high),
**When** the scanner runs,
**Then** `severity_max: "high"` is set
**And** the commit / merge is blocked per Story 4.7.

**Given** Dependabot is also enabled on every PR (NFR14),
**When** both Dependabot and `pnpm audit` run,
**Then** both feed into evidence (Dependabot at CI layer; `pnpm audit` at pre-merge-fast)
**And** divergence is logged but not fatal.

**Given** `pnpm-lock.yaml` is committed and unchanged,
**When** the scanner runs against the current lockfile,
**Then** results are deterministic
**And** intentional upgrades are flagged in the commit message (supply-chain-lock norm).

##### Story 4.4: Semgrep SAST scanner integration + substrate rules

As a substrate maintainer,
I want Semgrep wired into the pre-commit pipeline with substrate rules at `packages/keel-invariants/semgrep-rules/` — `no-env-log.yml`, `no-dynamic-secret.yml`, `no-swallowed-catch.yml`, `no-persist-tenant-id.yml`, `no-raw-fetch.yml` — emitting findings into `scans.sast`,
So that Keel-specific SAST patterns are enforced uniformly across substrate + product code (FR35, FR37).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/semgrep-rules/`,
**When** I inspect it,
**Then** the 5 rules exist with inline documentation
**And** each rule has at least one test fixture (positive + negative) under `packages/keel-invariants/semgrep-rules/__fixtures__/`.

**Given** Semgrep runs in pre-commit,
**When** a staged file triggers a rule,
**Then** the finding is transformed into `{tool: "semgrep", rule_id, finding_location, severity, findings[]}` and written to `scans.sast`.

**Given** `no-env-log.yml`,
**When** a file contains `console.log(process.env)` or equivalent,
**Then** Semgrep flags the pattern
**And** the commit is blocked.

**Given** `no-dynamic-secret.yml`,
**When** a file contains `getSecret(\`PADDLE_${env}_API_KEY\`)` (template-construction),
**Then** Semgrep flags the pattern (per architecture I6).

**Given** a fork operator adds fork-specific rules,
**When** they follow the documented extension pattern,
**Then** fork rules live at `<fork-root>/semgrep-rules/fork/` and Semgrep invokes both substrate + fork rules.

##### Story 4.5: Prompt-injection scanner rule source (regex + AST)

As a substrate maintainer,
I want `packages/keel-invariants/prompt-injection-rules/` containing `zero-width.ts`, `jailbreak-triggers.ts`, `diff-patterns.ts` — regex + AST rules for zero-width Unicode detection, known jailbreak strings, and suspicious diff patterns,
So that Story 4.6's pre-commit scanner has a pinned rule source tracked by the invariants manifest (S4 rule base, FR40).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/prompt-injection-rules/zero-width.ts`,
**When** I inspect it,
**Then** it exports detection rules for U+200B, U+200C, U+200D, U+FEFF, U+2060 and other zero-width code points
**And** each rule is documented with rationale.

**Given** `jailbreak-triggers.ts`,
**When** I inspect it,
**Then** it exports detection rules for known jailbreak strings (e.g., `IGNORE PREVIOUS`, `YOU ARE NOW`, `DAN mode`)
**And** the list is curated with references.

**Given** `diff-patterns.ts`,
**When** I inspect it,
**Then** it exports rules for suspicious diff patterns: new `--dangerously-skip-permissions` outside `packages/devbox`, `rm -rf /`, `rm -rf ~`, shell-eval from agent-authored markdown, diffs touching `.claude/settings*.json`, `.claude/hooks/**`, `.git/hooks/**` (wired with Story 2.17).

**Given** the rules are tracked,
**When** Story 1.8's manifest walks them,
**Then** each file is registered (`INV-prompt-injection-rules-zero-width`, `-jailbreak`, `-diff-patterns`)
**And** drift is caught by Story 1.9.

**Given** a fork operator wants to extend rules,
**When** they follow the documented pattern,
**Then** fork rules live at `<fork-root>/prompt-injection-rules/fork/`
**And** extension is additive only (fork cannot weaken substrate rules).

##### Story 4.6: Prompt-injection scan invocation at pre-commit (S4, ≤10s)

As a substrate maintainer,
I want the prompt-injection scanner invoked at pre-commit with a ≤10s budget, walking enumerated agent-context files (`AGENTS.md`, `CLAUDE.md`, `RALPH.md`, `.ralph/PROMPT_*.md`, `docs/**/*.md`, story files) plus the staged diff, emitting findings into `scans.prompt_injection`,
So that agent-context files and diffs are scanned every commit without blocking developer velocity (FR40, S4).

**Acceptance Criteria:**

**Given** a commit,
**When** the pre-commit hook invokes the prompt-injection scanner,
**Then** the scanner walks the enumerated file set
**And** the walk completes in ≤10 seconds on the baseline repo.

**Given** a zero-width code point in an agent-context file,
**When** the scanner runs,
**Then** the finding is reported in `scans.prompt_injection.findings[]` with severity `high`
**And** the commit is blocked.

**Given** a jailbreak trigger string appearing in new content,
**When** the scanner runs,
**Then** the finding is reported with severity `high`
**And** the commit is blocked.

**Given** a suspicious diff pattern (e.g., new `--dangerously-skip-permissions` outside `packages/devbox`),
**When** the scanner runs,
**Then** the finding is reported with severity `high`
**And** the commit is blocked per FR36.

**Given** the ≤10s budget is exceeded,
**When** the scanner detects the budget breach,
**Then** it emits `severity: low` with message "budget-exhausted; deep scan deferred to nightly" (Story 4.11)
**And** the scan continues but yields partial results; the commit is NOT blocked on partial results alone.

**Given** coverage is tested,
**When** M9 pre-release review runs,
**Then** every file in the enumerated scope is confirmed covered (per FR40).

##### Story 4.7: Severity threshold blocking at pre-commit (FR36)

As a substrate maintainer,
I want configurable severity thresholds per scanner in `.ralph/config.toml` that block commits when any scanner's `severity_max` exceeds its threshold,
So that fork operators can tune per-scanner strictness without touching scanner code (FR36).

**Acceptance Criteria:**

**Given** `.ralph/config.toml`,
**When** I inspect it,
**Then** a `[security.thresholds]` section exists with keys per scanner: `secrets = "medium"`, `deps = "high"`, `sast = "medium"`, `prompt_injection = "high"`, `hook_denials = "high"`, `mutation = "low"`
**And** defaults lean strict (substrate baseline).

**Given** a commit runs the scanner stack,
**When** any scanner's `severity_max` equals or exceeds its threshold,
**Then** `overall_severity_max` is set to that value
**And** `halt_required` is `true` if severity is `critical`, else `false`
**And** the pre-commit hook exits non-zero, blocking the commit.

**Given** all scanners report below-threshold severity,
**When** the hook completes,
**Then** `overall_severity_max` is the highest observed (e.g., `low`)
**And** the hook exits zero and the commit lands.

**Given** a fork operator raises a threshold,
**When** they change `prompt_injection = "critical"`,
**Then** the fork permits high-severity prompt-injection findings (documented as a known-risk escape)
**And** the change is visible via `.ralph/config.toml` review.

##### Story 4.8: Halt on consecutive security failures (FR38)

As Ralph,
I want to halt the loop on 3 consecutive same-security-finding iterations via `.ralph/halt` with `reason: "SECURITY_CRITICAL"` or `reason: "CI_BLOCKED"`,
So that repeated security failures don't burn budget on a genuinely stuck state (FR38; reuses FR14l mechanism).

**Acceptance Criteria:**

**Given** Story 3.17's halt-on-same-test-fails mechanism,
**When** Epic 4 extends it,
**Then** the same pattern covers `security-evidence` findings keyed by `{scanner, rule_id, finding_location}`.

**Given** iteration N produces a `secrets / rule_A / file_B` finding,
**When** iteration N+1 produces the same triple AND iteration N+2 produces the same triple,
**Then** after the 3rd consecutive match, Ralph writes `.ralph/halt` with `reason: "SECURITY_CRITICAL"`
**And** the halt payload includes `{failing_finding: "secrets/rule_A/file_B", fail_count: 3}`.

**Given** the halt fires for a pre-merge-blocked (not pre-commit-blocked) issue,
**When** the halt reason is chosen,
**Then** `CI_BLOCKED` is used (pre-merge path) vs `SECURITY_CRITICAL` (pre-commit path)
**And** the distinction is documented in `docs/invariants/ralph-halt-reasons.md`.

**Given** the threshold is configurable,
**When** `.ralph/config.toml` sets `halt_on_same_security_fails = 5`,
**Then** Ralph honours the value.

##### Story 4.9: Critical-severity immediate halt (NFR18)

As a substrate maintainer,
I want hardcoded production secrets, CVSS ≥ 9 vulnerabilities, and known RCE patterns to trigger an immediate halt without retry — `halt_required: true` in evidence → `.ralph/halt` written same iteration,
So that critical findings never progress past a single iteration (NFR18).

**Acceptance Criteria:**

**Given** `security-evidence.schema.json`,
**When** `overall_severity_max == "critical"` AND `halt_required == true`,
**Then** Ralph's halt-detection writes `.ralph/halt` with `reason: "SECURITY_CRITICAL"` same iteration
**And** no retry / no counter accumulation.

**Given** a hardcoded production secret (e.g., Paddle prod API key literal),
**When** Gitleaks flags it,
**Then** severity is `critical` and `halt_required: true` is set.

**Given** a CVSS ≥ 9 dependency vulnerability,
**When** `pnpm audit --prod` flags it,
**Then** severity is `critical` and `halt_required: true` is set.

**Given** a known RCE pattern (e.g., `eval(user_input)` in agent-authored code),
**When** Semgrep flags it,
**Then** severity is `critical` and `halt_required: true` is set.

**Given** the halt fires,
**When** Tthew reviews,
**Then** the evidence file at `.ralph/logs/<iter-id>/security-evidence.json` has full context for triage.

##### Story 4.10: OWASP ASVS L1 baseline doc (`docs/invariants/security.md`)

As a substrate maintainer,
I want `docs/invariants/security.md` mapping substrate controls to OWASP ASVS Level 1 requirements, with ASVS L2+ explicitly marked as Tier-2 deviation path (not substrate-surfaced at 1.0),
So that the security baseline is documented, auditable, and scopes the default expectation (FR39, NFR17).

**Acceptance Criteria:**

**Given** `docs/invariants/security.md`,
**When** I read it,
**Then** every ASVS L1 requirement is enumerated
**And** each is mapped to a substrate control (scanner rule, invariant, or architectural decision) OR marked as "not applicable at 1.0 because <reason>".

**Given** ASVS L2+ requirements,
**When** they appear in the doc,
**Then** each is marked `Tier 2 deviation path`
**And** a pointer to how a fork operator uplifts is documented.

**Given** the doc is an invariant,
**When** Story 1.8 tracks it,
**Then** `INV-security-asvs-baseline` is registered
**And** drift (e.g., a substrate control changes without updating the mapping) is caught by Story 1.9.

##### Story 4.11: Nightly LLM-based deep prompt-injection scan

As a substrate maintainer,
I want a nightly LLM-based deep prompt-injection scan that complements the ≤10s pre-commit regex/AST scan, running on a scheduled workflow against agent-context files + recent diffs,
So that subtle injection patterns the fast scan misses are caught within 24 hours (S4 deep-scan deferral).

**Acceptance Criteria:**

**Given** `.github/workflows/nightly-security.yml` (or equivalent),
**When** it runs nightly,
**Then** a scoped Opus-class subagent walks agent-context files + the last 24h of diffs
**And** emits findings into `.ralph/logs/nightly-<date>/prompt-injection-deep-scan.json`.

**Given** a deep-scan finding,
**When** it exceeds severity threshold,
**Then** an issue is auto-filed in GitHub with the finding + pointer to the diff
**And** the finding is also written to the next iteration's `security-evidence.json` for Ralph visibility.

**Given** the scan cost budget,
**When** the subagent runs,
**Then** the token budget is documented and bounded
**And** costs are tracked in Epic 14's research corpus.

**Given** the deep-scan augments, doesn't replace,
**When** both scans run,
**Then** the pre-commit fast scan remains the gating scan
**And** deep-scan findings inform the pre-commit rule corpus over time.

##### Story 4.12: `.gitleaksignore` lint rule (forbidden in `packages/*`)

As a substrate maintainer,
I want a lint rule (Semgrep or custom) that rejects `.gitleaksignore` files inside `packages/*` — fork-only at repo root — enforced via pre-merge-fast,
So that substrate packages cannot silently carve secret-detection escapes (NFR9 teeth).

**Acceptance Criteria:**

**Given** a PR adds `packages/<X>/.gitleaksignore`,
**When** pre-merge-fast runs the lint rule,
**Then** the PR is rejected with a message naming the offending path.

**Given** a PR adds `.gitleaksignore` at the repo root,
**When** pre-merge-fast runs,
**Then** the file is allowed (fork-level escape; deliberate).

**Given** the rule is tracked,
**When** Story 1.8's manifest tracks it,
**Then** `INV-gitleaks-ignore-substrate-forbidden` is registered.

##### Story 4.13: Hook-denials feed wired into `security-evidence.json`

As a substrate maintainer,
I want Story 2.16's `.ralph/logs/<iter-id>/blocked-tool-calls.jsonl` events propagated into `security-evidence.json`'s `scans.hook_denials[]` array,
So that the Claude-secret-barrier (NFR5a/5b) participates in the same severity/halt machinery as every other scanner (wire-up with Epic 2 Story 2.16, Epic 3 Story 3.32).

**Acceptance Criteria:**

**Given** Story 2.16's blocked-tool-calls log,
**When** the end-of-iteration evidence aggregator runs,
**Then** each blocked-tool-call entry is transformed into a finding `{rule_id, tool, args_redacted, timestamp}` in `scans.hook_denials`
**And** severity is `low` for a single block, escalating to `high` at N=3 per iteration.

**Given** `scans.hook_denials.severity_max` is factored into `overall_severity_max`,
**When** the evidence is finalised,
**Then** the overall max reflects hook-denial severity
**And** Story 4.7's threshold check applies.

**Given** hook-denial severity is `high`,
**When** Story 3.32's halt wire-up is also active,
**Then** both mechanisms fire coherently (no double-halt; single halt event)
**And** the halt payload references the evidence file.

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

#### Stories

##### Story 5.1: `keel.config.ts` typed schema + Zod parser

As a fork operator,
I want a typed `keel.config.ts` at the repo root validated by a Zod schema in `packages/config/src/schema.ts` — fields `{shape, tenancy, projectIdentity, otelExporter}` — so invalid values fail typecheck (not at runtime) and no user-facing wizard exists (FR65, NFR35, NFR36).

**Acceptance Criteria:**

**Given** `packages/config/src/schema.ts`,
**When** I inspect it,
**Then** it exports a Zod schema `KeelConfigSchema` defining `{shape: "b2b" | "b2c", tenancy: "team" | "user", projectIdentity: {name: string, slug: string, domain?: string}, otelExporter: string}`
**And** no `schemaVersion` field is present (per NFR36 at 1.0).

**Given** `keel.config.ts` at the repo root,
**When** I inspect it,
**Then** it exports a typed `KeelConfig` literal
**And** invalid values (e.g., `shape: "b2x"`) fail `tsc` at typecheck time, not runtime.

**Given** `KeelConfigSchema.parse(config)` runs at boot,
**When** the config passes,
**Then** a strongly-typed `KeelConfig` object is returned
**And** downstream consumers (generator, runtime) import it via `@keel/config`.

**Given** the schema is the contract,
**When** Story 1.8's manifest tracks it,
**Then** `INV-keel-config-schema` registers the schema file
**And** drift is caught by Story 1.9.

**Given** `shape` and `tenancy` have allowed combinations,
**When** `shape: "b2b"` is set,
**Then** `tenancy` MUST be `"team"` (enforced by a Zod `refine`)
**And** `shape: "b2c"` with `tenancy: "user"` is enforced the same way.

##### Story 5.2: Generator G1-G6 contract in `packages/keel-generator/`

As a substrate maintainer,
I want the generator's core `expand(policy, config) → Rule[]` function (G1) implemented as pure TypeScript with no I/O or non-determinism, output sorted lexicographically by `(target.table, target.op, id)` (G2), merge precedence `overrides > policy.rules > template.defaultRules` (G3), canonical JSON form with fixed key order (G4), stable rule identity `<table>_<op>_<tenancy>_<version>` (G5), and a test proving `expand(expand(p, c)) === expand(p, c)` (G6),
So that generated artefacts are deterministic, idempotent, and hash-stable (FR67).

**Acceptance Criteria:**

**Given** `packages/keel-generator/src/expand.ts`,
**When** I inspect it,
**Then** `expand(policy: TenancyPolicy, config: KeelConfig): Rule[]` is exported
**And** the function uses no `Date.now()`, `Math.random()`, filesystem reads, or network I/O.

**Given** two calls with identical inputs,
**When** I compare `expand(p, c)` and `expand(p, c)`,
**Then** outputs are byte-identical
**And** `JSON.stringify(out)` produces the same string.

**Given** G2 ordering,
**When** I inspect output,
**Then** rules are sorted by `(target.table, target.op, id)` ascending
**And** reordering inputs does not change output order.

**Given** G3 merge precedence,
**When** `config.overrides.rls.<table>.<op>` exists,
**Then** it wins over `policy.rules` which wins over `template.defaultRules`
**And** no deep-merge of rule fields occurs.

**Given** G4 canonical form,
**When** I inspect any emitted file,
**Then** keys appear in fixed order (`id`, `target`, `predicate`, `using`, `with_check`)
**And** the emitted JSON ends with a trailing newline.

**Given** G5 stable identity,
**When** I inspect any rule's `id`,
**Then** it follows `<table>_<op>_<tenancy>_<version>` (e.g., `users_select_team_v1`)
**And** rename-alone (no semantic change) yields the same content-hash.

**Given** G6 idempotence proof test,
**When** `packages/keel-generator/expand.test.ts` runs,
**Then** `expand(expand(policy, config)) === expand(policy, config)` (deep equality + content-hash equality)
**And** the test is part of pre-merge-fast.

##### Story 5.3: Tenancy templates (rls-team B2B, rls-user B2C)

As a substrate maintainer,
I want tenancy templates at `packages/keel-generator/templates/rls-team.ts` (B2B) and `rls-user.ts` (B2C) — hardwired policy definitions consumed by Story 5.2's `expand()` — with `org` template explicitly deferred to Growth-tier,
So that shape-driven RLS emission has a canonical policy source (FR48 base).

**Acceptance Criteria:**

**Given** `packages/keel-generator/templates/`,
**When** I inspect it,
**Then** `rls-team.ts` and `rls-user.ts` exist
**And** `rls-org.ts` does NOT exist at 1.0 (Growth-tier deferral documented).

**Given** `rls-team.ts`,
**When** I read it,
**Then** it exports a `TenancyPolicy` with rules scoped to `app.current_team_id` session variable
**And** every tenant-scoped table's SELECT/INSERT/UPDATE/DELETE ops are covered.

**Given** `rls-user.ts`,
**When** I read it,
**Then** it exports a `TenancyPolicy` scoped to `app.current_user_id`
**And** the shape is structurally parallel to `rls-team.ts`.

**Given** Story 5.2's `expand()` consumes these templates,
**When** invoked with `{shape: "b2b", tenancy: "team"}`,
**Then** `rls-team.ts` is used
**And** `{shape: "b2c", tenancy: "user"}` uses `rls-user.ts`.

**Given** fork operators want custom tenancy rules,
**When** they use `KeelConfig.overrides.rls`,
**Then** overrides layer on per G3 precedence (Story 5.2).

##### Story 5.4: Billing presets (paddle-team-seats, paddle-individual)

As a substrate maintainer,
I want billing presets at `packages/keel-generator/templates/paddle-team-seats.ts` (B2B) and `paddle-individual.ts` (B2C) — consumed by the generator to emit `packages/billing/paddle/preset.generated.ts`,
So that shape change also rewires the billing preset without manual intervention (FR48 base).

**Acceptance Criteria:**

**Given** `packages/keel-generator/templates/paddle-team-seats.ts`,
**When** I read it,
**Then** it exports a Paddle preset for seat-based team billing
**And** the shape includes plan IDs (parameterised), proration rules, and a webhook schema reference.

**Given** `packages/keel-generator/templates/paddle-individual.ts`,
**When** I read it,
**Then** it exports a Paddle preset for individual subscriptions
**And** the shape is structurally parallel.

**Given** Story 5.5's `pnpm generate`,
**When** `shape: "b2b"` is active,
**Then** `paddle-team-seats.ts` is emitted as `packages/billing/paddle/preset.generated.ts`
**And** `shape: "b2c"` emits from `paddle-individual.ts`.

**Given** the presets are stable at 1.0,
**When** Epic 10's Paddle commerce integration consumes them,
**Then** the shape-specific preset is available without Epic 10 re-implementing it.

##### Story 5.5: `pnpm generate` emission pipeline

As a fork operator,
I want `pnpm generate` to read `keel.config.ts`, invoke Story 5.2's `expand()`, and emit RLS tenancy template to `packages/core/rls/*.generated.ts`, Paddle preset to `packages/billing/paddle/preset.generated.ts`, and invariants.manifest.ts content-hash entries for each emitted artefact — all idempotent,
So that one command regenerates all per-fork artefacts consistently (FR66).

**Acceptance Criteria:**

**Given** a fork with `keel.config.ts` set,
**When** I run `pnpm generate`,
**Then** the command emits `packages/core/rls/policies.generated.ts` (or equivalent) with content derived from the active tenancy template
**And** emits `packages/billing/paddle/preset.generated.ts` with the active billing preset
**And** emits / updates content-hash entries in `packages/keel-invariants/src/invariants.manifest.ts` covering each generated file.

**Given** idempotence (NFR37),
**When** I run `pnpm generate` twice in a row,
**Then** `git diff` shows no changes
**And** the second run exits zero with no output changes.

**Given** every emitted file,
**When** I inspect it,
**Then** a provenance header names the config-source SHA + generator version
**And** the file is marked `// Generated — do not edit directly` with a pointer to the source.

**Given** the command runs inside the devbox,
**When** invoked,
**Then** output is written to the workspace (host-visible)
**And** no network I/O occurs.

##### Story 5.6: Reorder-stability test (C2) + idempotence proof (G6)

As a substrate maintainer,
I want `packages/keel-generator/reorder-stability.test.ts` permuting inputs through structural rewrites and asserting content-hash equality, plus Story 5.2's G6 idempotence proof test,
So that generator determinism is machine-enforced (FR67 teeth).

**Acceptance Criteria:**

**Given** `packages/keel-generator/reorder-stability.test.ts`,
**When** it runs,
**Then** multiple permutations of the input policy are fed through `expand()`
**And** all outputs have identical content-hashes.

**Given** the idempotence proof (G6),
**When** `expand(expand(p, c))` is computed,
**Then** deep equality AND content-hash equality hold against `expand(p, c)`
**And** failures surface specific difference paths.

**Given** both tests,
**When** pre-merge-fast runs,
**Then** they execute within the pre-merge-fast budget
**And** failure blocks merge.

##### Story 5.7: Pre-merge-fast config ↔ generated-artefact sync gate

As a substrate maintainer,
I want a pre-merge-fast gate that regenerates from the PR's `keel.config.ts` and diffs against committed generated artefacts — any drift fails,
So that editing config without regenerating OR editing generated files without config change both fail (FR68).

**Acceptance Criteria:**

**Given** a PR edits `keel.config.ts` without running `pnpm generate`,
**When** pre-merge-fast runs,
**Then** the gate regenerates, diffs, detects missing changes in `*.generated.ts`
**And** the PR is rejected with a pointer to `pnpm generate`.

**Given** a PR edits `*.generated.ts` without changing `keel.config.ts`,
**When** pre-merge-fast runs,
**Then** the gate regenerates, diffs, detects the emitted file drift
**And** the PR is rejected.

**Given** a PR edits both `keel.config.ts` AND the corresponding `*.generated.ts` coherently,
**When** pre-merge-fast runs,
**Then** the regenerate-and-diff yields no delta
**And** the gate passes.

**Given** the gate reuses Story 1.9's sync-gate tooling,
**When** Story 1.8's manifest tracks generated artefacts,
**Then** content-hash entries for each `*.generated.ts` are registered
**And** drift is caught even without PR-level diff (commit-level coverage).

##### Story 5.8: Generated-migration contract (W3 party-mode amendment)

As a substrate maintainer,
I want an explicit contract at `packages/keel-generator/src/migration-contract.ts` defining (a) emitted migration filename schema `<timestamp>_rls_<shape>_<tenancy>_<content-hash>.sql`, (b) migration SQL shape (pure `prisma db execute` statements; self-contained), (c) assertion spec for Epic 6 tests,
So that the producer/consumer seam between generator (Epic 5) and RLS runtime (Epic 6) is closed with one contract artefact (W3).

**Acceptance Criteria:**

**Given** `packages/keel-generator/src/migration-contract.ts`,
**When** I read it,
**Then** it exports three constants/types: `FilenameSchema` (regex/zod for `<timestamp>_rls_<shape>_<tenancy>_<content-hash>.sql`), `SQLShapeRules` (pure `prisma db execute`; no Prisma schema diffs; self-contained), `AssertionSpec` (what Epic 6 tests must verify).

**Given** `AssertionSpec` lists 4 assertions,
**When** Epic 6 wires its tests,
**Then** filename parses per schema; content-hash equals generator output; SQL applies cleanly in both pglite and testcontainers Postgres; reverse-idempotency holds on re-run are all verified.

**Given** the contract is invariant,
**When** Story 1.8 tracks it,
**Then** `INV-generator-migration-contract` is registered
**And** Epic 6's test code depends on this entry for assertion coverage.

**Given** a fork operator extends migrations,
**When** they add custom migration rules,
**Then** they MUST conform to `SQLShapeRules` or fail Epic 6's assertion tests.

##### Story 5.9: One-line shape-change workflow validated (FR46, FR48)

As a fork operator,
I want to change my fork's shape via a one-line edit to `keel.config.ts` followed by `pnpm generate` (pre-commit hook auto-invokes or rejects) with pre-merge-fast catching any drift,
So that shape change is a documented, CI-enforced workflow rather than tribal knowledge (FR46, FR48).

**Acceptance Criteria:**

**Given** a fork with `shape: "b2b"`,
**When** I change `keel.config.ts` to `shape: "b2c", tenancy: "user"`,
**Then** `pnpm generate` regenerates all emitted artefacts
**And** a single commit captures the config change + regenerated files together.

**Given** the pre-commit hook,
**When** I forget to run `pnpm generate`,
**Then** the pre-commit hook rejects the commit with a pointer to `pnpm generate`
**And** the behaviour is documented (reject-not-auto-invoke decision pinned here).

**Given** the shape change lands,
**When** Epic 6's migration runs,
**Then** the new tenancy policies are applied to the DB via the migration contract (Story 5.8)
**And** the application continues to typecheck and pass tests.

**Given** a failed shape change (typecheck error or generator fail),
**When** the commit is rejected,
**Then** the fork returns to the prior shape with a clear error message
**And** no partial state lands.

**Given** the workflow is documented,
**When** I read `AGENTS.md`,
**Then** the shape-change flow is enumerated with commands + expected CI checks.

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

#### Stories

##### Story 6.1: Prisma schema baseline + UUIDv7 PKs

As a substrate maintainer,
I want `packages/db/prisma/schema.prisma` with the baseline Prisma schema using UUIDv7 PKs via `@default(dbgenerated("uuidv7()"))` (backed by pg_uuidv7 extension pinned in Epic 2's base image),
So that every table has time-ordered UUID PKs without collision risk (NFR substrate baseline).

**Acceptance Criteria:**

**Given** `packages/db/prisma/schema.prisma`,
**When** I inspect it,
**Then** every `@id` column uses `@default(dbgenerated("uuidv7()"))`
**And** the snake_case-singular table-naming convention is enforced via `@@map`.

**Given** the devbox Postgres image from Epic 2 with `pg_uuidv7` extension,
**When** Prisma migrations run,
**Then** the extension is available and `uuidv7()` resolves.

**Given** `prisma/migrations/`,
**When** I inspect the initial migration,
**Then** `CREATE EXTENSION IF NOT EXISTS pg_uuidv7;` is the first statement.

##### Story 6.2: `tenantGuard()` Prisma Client Extension with tx-wrapped `SET LOCAL`

As a fork operator,
I want `tenantGuard()` implemented as a Prisma Client Extension (`$extends`) that opens a per-request transaction in tRPC middleware, sets `app.current_tenant_id` via `SET LOCAL`, runs the handler, and commits,
So that RLS semantics are cross-request-leak-proof and PgBouncer-compatible (FR16, D1).

**Acceptance Criteria:**

**Given** `packages/db/src/tenant-guard.ts`,
**When** I inspect it,
**Then** it exports a Prisma `$extends` configuration that wraps every query in a transaction
**And** inside the transaction, `SET LOCAL app.current_tenant_id = <id>` is executed before the query.

**Given** a tRPC middleware,
**When** a request arrives,
**Then** `tenantGuard(ctx.tenantId)` opens the tx and sets the session variable
**And** the handler runs inside the same tx
**And** the tx commits on handler success (rolls back on error).

**Given** PgBouncer transaction-pooling mode,
**When** the extension is used,
**Then** `SET LOCAL` scope is confined to the tx (no cross-request leak)
**And** connection reuse across requests is safe.

**Given** the tenancy template is shape-specific,
**When** `tenancy: "team"`,
**Then** `current_tenant_id` maps to `current_team_id`; for `tenancy: "user"` it maps to `current_user_id`
**And** the mapping is emitted by Epic 5's generator.

##### Story 6.3: RLS policies consumed from Epic 5 generator

As a substrate maintainer,
I want the generator-emitted RLS SQL (via Epic 5 Story 5.5) applied to the DB through companion migrations whose filenames encode the generator content-hash (per the migration contract in Epic 5 Story 5.8),
So that RLS policies in the DB always match the generated source-of-truth (FR15).

**Acceptance Criteria:**

**Given** the generator emitted RLS SQL,
**When** `prisma migrate deploy` runs,
**Then** the companion migration file at `prisma/migrations/<timestamp>_rls_<shape>_<tenancy>_<content-hash>.sql` executes via `prisma db execute`
**And** the DB has the policies applied.

**Given** the filename encodes the content-hash,
**When** the hash in the filename differs from the generator's current output,
**Then** the pre-merge-fast sync gate from Epic 5 Story 5.7 detects drift
**And** the PR is rejected.

**Given** Epic 5's `AssertionSpec`,
**When** Story 6.4's tests run,
**Then** each of the 4 assertions holds.

##### Story 6.4: Migration strategy + generated-migration-contract assertion tests (W3)

As a substrate maintainer,
I want `packages/db/test-utils/migration-contract.test.ts` asserting the 4 assertions from Epic 5 Story 5.8's `AssertionSpec` — filename parses, content-hash matches, SQL applies in pglite + testcontainers, reverse-idempotency — as part of pre-merge-slow,
So that the producer/consumer seam between Epic 5 and Epic 6 is tested, not informal (W3 + D2).

**Acceptance Criteria:**

**Given** `packages/db/test-utils/migration-contract.test.ts`,
**When** the test runs,
**Then** assertion 1: every migration file in `prisma/migrations/` matching the `_rls_*_*.sql` pattern parses against Epic 5 Story 5.8's `FilenameSchema`.

**Given** the content-hash in each filename,
**When** assertion 2 runs,
**Then** the hash equals `sha256` of the generator output for the fork's current config.

**Given** assertion 3 (apply cleanly),
**When** the migration SQL runs against pglite (pre-merge-fast tier),
**Then** no errors
**And** the same SQL runs against testcontainers Postgres in pre-merge-slow with the same result.

**Given** assertion 4 (reverse-idempotency),
**When** the migration is re-run on a DB already having it applied,
**Then** it is a no-op (no duplicate-policy errors; guarded by `CREATE POLICY IF NOT EXISTS` or equivalent).

**Given** all 4 assertions fail-closed,
**When** Epic 5 breaks its contract,
**Then** Epic 6's CI fails immediately with a pointer to Epic 5 Story 5.8.

##### Story 6.5: `pnpm rls:explain` debugging CLI

As a fork operator,
I want `pnpm rls:explain <query> --tenant=<id>` that returns a structured table showing which policies fired and which rows filtered for a given query + tenant context,
So that RLS decisions are debuggable without raw DB spelunking (FR17).

**Acceptance Criteria:**

**Given** `packages/db/scripts/rls-explain.ts`,
**When** I run `pnpm rls:explain "SELECT * FROM users" --tenant=abc123`,
**Then** the CLI opens a tx, sets `SET LOCAL app.current_tenant_id = 'abc123'`, runs `EXPLAIN (ANALYZE, VERBOSE)` on the query, and prints a structured table
**And** the table shows each policy that evaluated + filter impact.

**Given** an invalid tenant ID,
**When** I run the command,
**Then** the CLI exits non-zero with a pointer error.

**Given** `packages/db/rls-helpers.ts`,
**When** I inspect it,
**Then** helper functions for policy introspection are exported
**And** the CLI consumes them.

##### Story 6.6: CI check — new tenant-scoped tables must ship with RLS

As a substrate maintainer,
I want a CI check at pre-merge-slow that scans `packages/db/prisma/schema.prisma` for tenant-scoped tables without matching RLS policies in the generator output, failing the PR if any are missing,
So that new tenant-scoped tables cannot land without RLS (FR18 teeth).

**Acceptance Criteria:**

**Given** a new tenant-scoped table added to `schema.prisma` (identified by a `@@tenant-scoped` directive or convention documented in `docs/invariants/backend.md`),
**When** pre-merge-slow runs the check,
**Then** the check verifies that the generator's output (Epic 5 Story 5.5) contains RLS rules for that table
**And** the PR is rejected if any are missing.

**Given** a non-tenant-scoped table (e.g., reference data),
**When** the check runs,
**Then** it is skipped (not flagged).

**Given** the check is invariant,
**When** Story 1.8 tracks it,
**Then** `INV-rls-new-tenant-scoped-table-coverage` is registered.

##### Story 6.7: D3 synthetic-schema testing (pglite pre-merge-fast + testcontainers pre-merge-slow)

As a substrate maintainer,
I want RLS unit tests against `@electric-sql/pglite` (WASM in-memory Postgres; pre-merge-fast) and integration tests against Docker-backed ephemeral Postgres via `testcontainers-node` (pre-merge-slow) for faithful PL/pgSQL + extensions,
So that RLS assertions are tiered by fidelity + speed (D3).

**Acceptance Criteria:**

**Given** `packages/db/test/pglite-setup.ts`,
**When** pre-merge-fast tests run,
**Then** pglite is initialised with the full migration chain
**And** RLS unit tests execute in milliseconds.

**Given** `packages/db/test/testcontainers-setup.ts`,
**When** pre-merge-slow tests run,
**Then** a Docker-backed Postgres container with pg_uuidv7 starts
**And** the full migration chain applies
**And** integration tests run against it.

**Given** the two tiers,
**When** a test is written,
**Then** the test file naming convention (`*.pg.test.ts` for testcontainers, `*.test.ts` for pglite) is documented in `AGENTS.md`.

**Given** D3 is a tiered strategy,
**When** an RLS policy is validated,
**Then** pglite-tier proves correctness on a simple model and testcontainers-tier proves PL/pgSQL-specific features (row-level policies, session variables).

##### Story 6.8: D4 RLS performance budget benchmark harness (NFR3)

As a substrate maintainer,
I want `packages/db/src/bench/rls-overhead.bench.ts` + `bench/seed.ts` measuring p95 wall-clock delta with/without RLS on seeded datasets (B2B: 10k rows × 100 tenants team, 100 rows/tenant; B2C: 10k rows × 10k tenants user, 1 row/tenant), running in the nightly tier; p95 delta > 20% for two consecutive monthly baselines flags NFR3 breach,
So that RLS overhead is tracked with empirical evidence (D4, NFR3, NFR28c).

**Acceptance Criteria:**

**Given** `packages/db/bench/seed.ts`,
**When** invoked,
**Then** it seeds both B2B dataset (100 tenants × 100 rows) and B2C dataset (10k tenants × 1 row) into a testcontainers Postgres instance.

**Given** `rls-overhead.bench.ts`,
**When** it runs against the seeded DB,
**Then** it measures p95 wall-clock for representative queries with and without RLS enabled
**And** the delta is emitted to `.ralph/logs/nightly-<date>/rls-overhead.json`.

**Given** two consecutive monthly baselines show p95 delta > 20%,
**When** the monthly review runs (Epic 14 terrain),
**Then** an NFR3 breach is flagged
**And** the flag is documented in the monthly sprint log.

**Given** the nightly workflow,
**When** it runs,
**Then** the harness invocation is bounded by a documented time budget
**And** the results are archived per Epic 14's research corpus.

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

#### Stories

##### Story 7.1: `packages/ui/` scaffolding + Epic 1 token consumption

As a fork operator,
I want `packages/ui/` set up as the load-bearing substrate package for primitives + patterns + catalog, consuming Epic 1's emitted `tokens.css` + `tailwind.preset.ts`,
So that all UI elements share a single token source (Epic 7 owns composition; Epic 1 owns tokens).

**Acceptance Criteria:**

**Given** `packages/ui/`,
**When** I inspect it,
**Then** it has `src/primitives/`, `src/tokens.css` (emitted by Epic 1 Story 1.12), `tailwind.preset.ts` (emitted by Story 1.12), and `package.json` with `@keel/ui` export.

**Given** `apps/web/tailwind.config.ts`,
**When** I inspect it,
**Then** it imports `@keel/ui/tailwind.preset` (so Tailwind theme extends the Keel token preset).

**Given** any primitive in `packages/ui/src/primitives/`,
**When** I inspect it,
**Then** CSS references use Tailwind classes that resolve to `var(--*)` tokens
**And** no hex values appear in primitive source (lint-enforced in Story 1.13 extended).

##### Story 7.2: 24 shadcn/ui + Radix primitives vendored (UX-DR16)

As a fork operator,
I want 24 shadcn/ui + Radix primitives vendored into `packages/ui/src/primitives/` (copy-into-repo, not npm dep), each with stable Keel catalog ID (e.g., `ui.button.01`, `ui.input.text.01`, etc.),
So that primitives are forkable, visible in git history, and stamped with stable IDs that survive shadcn upstream churn (UX-DR16).

**Acceptance Criteria:**

**Given** `packages/ui/src/primitives/`,
**When** I inspect it,
**Then** 24 primitives exist per the UX-DR16 enumeration (`button`, `input.{text,textarea,checkbox,radio}`, `select`, `label`, `form`, `dialog`, `drawer`, `dropdown-menu`, `popover`, `tooltip`, `toast`, `tabs`, `switch`, `card`, `badge`, `separator`, `skeleton`, `avatar`, `scroll-area`, `table`)
**And** `ui.command.01` is NOT present (Growth-tier deferral documented).

**Given** each primitive file,
**When** I inspect the header,
**Then** a stable catalog ID is documented (e.g., `// @catalog: ui.button.01`)
**And** the ID is cross-referenced in `docs/design/catalog.md` (Story 7.4).

**Given** primitives are vendored,
**When** I check `package.json`,
**Then** `@radix-ui/*` deps are pinned (Story 1.15 renovate covers)
**And** no `shadcn-ui` runtime dependency is present.

**Given** a fork operator wants to update a primitive,
**When** they edit the file,
**Then** the edit is visible in git
**And** any downstream breakage is caught by usage sites (typecheck).

##### Story 7.3: 4 custom web primitives (UX-DR17)

As a fork operator,
I want 4 custom web primitives — `ui.chip.01` (shared TUI+web status chip; tones info/success/warning/error/critical; never colour-alone), `ui.empty-state.01` (title + 0-1 action), `ui.app-shell.01` (responsive sidebar + main, build-time shape-aware nav), `ui.form-field.01` (Label+Input+help+error wrapper with aria-describedby + aria-invalid auto-wired),
So that Keel has one canonical primitive per custom pattern (UX-DR17).

**Acceptance Criteria:**

**Given** `packages/ui/src/primitives/chip.tsx`,
**When** I inspect it,
**Then** it accepts `tone: 'info' | 'success' | 'warning' | 'error' | 'critical'`
**And** each tone carries an icon (never colour-alone for a11y).

**Given** `packages/ui/src/primitives/empty-state.tsx`,
**When** I inspect it,
**Then** it enforces: 1 title, 1 optional description line, 0-1 CTA
**And** rejects marketing-heavy copy patterns.

**Given** `packages/ui/src/primitives/app-shell.tsx`,
**When** I inspect it,
**Then** it renders a responsive sidebar + main layout
**And** nav structure is build-time shape-aware (different for b2b vs b2c per `keel.config.ts`).

**Given** `packages/ui/src/primitives/form-field.tsx`,
**When** I inspect it,
**Then** it wraps Label + Input (or other form primitive) + help text + error text
**And** `aria-describedby` + `aria-invalid` are auto-wired based on props.

**Given** all 4 primitives are catalog entries,
**When** `docs/design/catalog.md` (Story 7.4) tracks them,
**Then** each has a stable ID (`ui.chip.01`, `ui.empty-state.01`, `ui.app-shell.01`, `ui.form-field.01`).

##### Story 7.4: Catalog doc at `docs/design/catalog.md` (UX-DR7)

As a fork operator or agent,
I want `docs/design/catalog.md` enumerating every primitive + screen template + pattern recipe with stable IDs; format = purpose / shape / primitives / template / required tests; referenced by `INVARIANTS.md §ui`; participates in FR43 manifest sync gate,
So that there is one canonical reference for "which primitive for what" with machine-enforced drift detection (UX-DR7).

**Acceptance Criteria:**

**Given** `docs/design/catalog.md`,
**When** I read it,
**Then** every primitive from Stories 7.2 and 7.3 has an entry with `{id, purpose, shape, primitives, template, required_tests}`
**And** the doc is valid markdown with a TOC.

**Given** `INVARIANTS.md §ui`,
**When** I read it,
**Then** it points at `docs/design/catalog.md` as the canonical reference
**And** each catalog entry has a matching invariant ID in Story 1.8's manifest.

**Given** the catalog participates in FR43 sync gate,
**When** Story 1.9 walks invariants,
**Then** missing or extra catalog entries relative to `packages/ui/src/primitives/` fail the gate.

**Given** a fork operator adds a new primitive,
**When** they commit,
**Then** the catalog entry MUST be updated in the same PR
**And** the sync gate catches omissions.

##### Story 7.5: 8 interaction-pattern recipes at `docs/design/patterns.md` (E7, UX-DR64)

As a fork operator or agent,
I want 8 interaction-pattern recipes — `destructive-confirm`, `empty-state-with-cta`, `error-state-taxonomy`, `loading-state-choreography`, `form-with-validation`, `table-with-row-actions`, `modal-confirm`, `nav-states` — as first-class catalog entries at `docs/design/patterns.md`, each with stable ID + example + required-tests floor,
So that Ralph composes primitives consistently across forks and un-scaffolded cases don't default to spinners + toast-errors (E7-patterns party-mode amendment, UX-DR64).

**Acceptance Criteria:**

**Given** `docs/design/patterns.md`,
**When** I read it,
**Then** the 8 patterns from the E7 amendment are documented
**And** each pattern has a stable ID (`pattern.destructive-confirm.01`, etc.).

**Given** each pattern,
**When** I inspect it,
**Then** it documents: primitives used, example code, required-tests floor (minimum assertions for any implementation).

**Given** `pattern.error-state-taxonomy.01`,
**When** I read it,
**Then** the decision tree per UX-DR25 is documented: inline field / inline block / toast / full-page route / halt banner.

**Given** `pattern.loading-state-choreography.01`,
**When** I read it,
**Then** the skeleton + 200ms delay + `<Delayed>` wrapper per UX-DR27 is documented
**And** full-screen spinners + "Loading..." text are explicitly forbidden.

**Given** `patterns.md` is an invariant,
**When** Story 1.9 walks it,
**Then** drift with `packages/ui/` implementations fails the sync gate.

##### Story 7.6: Fork token overrides + Direction B/C preset overlays (UX-DR8)

As a fork operator,
I want `apps/web/tokens.fork.json` (DTCG) merged with Epic 1's substrate token source before emission, plus Direction B/C preset overlays at `docs/design/presets/{gov-uk-adjacent,developer-notebook}.tokens.json` (CI-tested for contrast + schema validity),
So that forks can override colours/motion without editing substrate and alternative aesthetic directions are available as drop-ins (UX-DR8).

**Acceptance Criteria:**

**Given** a fork with `apps/web/tokens.fork.json`,
**When** Epic 1's emitter (Story 1.12) runs,
**Then** the fork overrides merge with the substrate token source before emission
**And** the emitted `tokens.css` + `tailwind.preset.ts` reflect the merge.

**Given** `docs/design/presets/gov-uk-adjacent.tokens.json` + `developer-notebook.tokens.json`,
**When** I inspect each,
**Then** they validate against the token schema from Story 1.10
**And** the emitter can use either as a base (alternative to Direction A).

**Given** a preset is used,
**When** pre-merge runs the contrast check (Story 1.13),
**Then** the preset's text-on-surface pairs pass WCAG AA
**And** any preset failing the check is rejected.

**Given** primitive bodies are NOT forkable,
**When** a fork edits `packages/ui/src/primitives/button.tsx` directly,
**Then** Story 1.9's sync gate rejects the edit (primitive is a substrate invariant)
**And** forks must override via tokens, not primitive surgery.

##### Story 7.7: F4 Zustand posture enforcement (no-persist-tenant-id + persist-middleware lint)

As a substrate maintainer,
I want Semgrep rule `no-persist-tenant-id.yml` + a lint rule for Zustand persist-middleware usage, rejecting any persistence of tenant-scoped state keys (e.g., `tenantId`, `teamId`, `userId` when used as tenant),
So that tenant data cannot leak across sessions via client-side persistence (F4).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/semgrep-rules/no-persist-tenant-id.yml`,
**When** the rule runs,
**Then** it flags `create(persist(..., { name: ..., partialize: ... }))` patterns where `partialize` returns an object containing `tenantId`/`teamId`/`userId` keys.

**Given** a lint rule for Zustand persist middleware,
**When** I inspect `packages/keel-invariants/eslint.config.keel-invariants.js`,
**Then** a rule flags `import { persist } from 'zustand/middleware'` in any file that also imports tenant-context types.

**Given** a false positive (e.g., non-tenant `userId` like a settings form),
**When** a developer needs to suppress,
**Then** an explicit `// keel-invariants-allow: no-persist-tenant-id` comment with reason is required
**And** the comment must reference a documented rationale.

**Given** downstream UI epics (9, 10, 11, 12) consume this rule,
**When** they add state management,
**Then** the rule applies automatically.

##### Story 7.8: Accessibility primitives baked in (UX-DR32–44)

As a fork operator,
I want accessibility primitives baked into every component — contrast enforcement at build (Epic 1 contract + Epic 7 verification); focus ring (2px accent.400, never removed); `:focus-visible` only; `prefers-reduced-motion` + `prefers-color-scheme` honoured; touch targets 44×44 min; skip link in `ui.app-shell.01`,
So that a11y is a property of the substrate, not a per-fork concern (UX-DR32–44).

**Acceptance Criteria:**

**Given** any primitive's styles,
**When** I inspect,
**Then** a focus ring with 2px solid `--accent-400` is applied on `:focus-visible` (not plain `:focus`)
**And** removing the focus ring is lint-rejected.

**Given** motion-bearing components,
**When** I inspect,
**Then** `prefers-reduced-motion` is honoured (no animation when user prefers reduced)
**And** lint catches `animation:` without a reduced-motion fallback.

**Given** `prefers-color-scheme`,
**When** the user switches,
**Then** dark tokens apply (tokens ship at 1.0 per V2 amendment; dark VISUAL verification deferred to 1.1).

**Given** touch targets,
**When** I inspect any interactive primitive,
**Then** the minimum touch area is 44×44 px
**And** smaller visual elements have extended hit areas via padding.

**Given** `ui.app-shell.01`,
**When** I inspect it,
**Then** a skip link "Skip to main content" is rendered at the top of the DOM
**And** it is the first focusable element.

**Given** UX-DR66 design-system failures triggering halt-worthy backpressure,
**When** token drift, a11y violations, missing i18n keys, or contrast failures occur,
**Then** FR14l halt mechanism escalates per Epic 3 Story 3.17.

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

#### Stories

##### Story 8.1: `packages/jobs/` typed pg-boss registry + worker bootstrap

As a fork operator,
I want `packages/jobs/registry.ts` as a typed job-name map with naming convention `<domain>.<action>` dotted (e.g., `email.send_verification`, `billing.process_paddle_webhook`, `session.cleanup`) plus a worker bootstrap at `packages/jobs/worker.ts`,
So that every background job is type-safe and ad-hoc job names are impossible (FR19).

**Acceptance Criteria:**

**Given** `packages/jobs/registry.ts`,
**When** I inspect it,
**Then** it exports a typed `JobRegistry` map where keys follow `<domain>.<action>` convention
**And** payload types are Zod-validated per job name.

**Given** enqueuing `ctx.jobs.enqueue('<name>', payload)`,
**When** the name is not in the registry,
**Then** typecheck fails
**And** runtime also validates payload against registered Zod schema.

**Given** `packages/jobs/worker.ts`,
**When** it bootstraps,
**Then** it initialises pg-boss against the Postgres DB (same DB as app per Keel decision)
**And** registers handlers from the registry.

##### Story 8.2: pg-boss retry + idempotency + DLQ posture (C1)

As a substrate maintainer,
I want pg-boss configured with 3 retries at exponential backoff (250ms × 2^n), caller-owned idempotency (natural keys or structurally idempotent handlers), and DLQ at 1.0 = manual inspection of `pgboss.job_archive` (automated DLQ routing is Growth-tier) with OTel `error: true` on poison-message handling,
So that failed jobs behave predictably and are observable (NFR24).

**Acceptance Criteria:**

**Given** a job handler throws,
**When** pg-boss catches,
**Then** the job is retried with 250ms × 2^n backoff up to 3 retries
**And** after 3 failures, the row lands in `pgboss.job_archive` with `state='failed'`.

**Given** `docs/invariants/jobs.md`,
**When** I read the idempotency section,
**Then** it documents: webhook-derived work uses natural keys `(provider, event_id)`; structurally-idempotent handlers (e.g., `session.cleanup` = `DELETE WHERE expired_at < now()`) need no key.

**Given** a poison message,
**When** it exhausts retries,
**Then** OTel span records `error: true` + exception details
**And** Tthew can inspect `pgboss.job_archive` at 1.0.

**Given** Growth-tier automated DLQ routing,
**When** a fork wants it,
**Then** the extension pattern is documented (not shipped at 1.0).

##### Story 8.3: OTel + tenant propagation across pg-boss boundary (C3)

As a substrate maintainer,
I want job payloads to carry `tenant_id` (top-level, required) and `traceparent` (W3C trace-context, required); worker middleware re-applies `tenantGuard()` to establish `app.current_tenant_id` before handler runs; OTel SDK restores parent trace context from `traceparent`; lint rule forbids any job handler reading tenant data without `tenantGuard()`,
So that tenant isolation + OTel traces traverse the async boundary (C3).

**Acceptance Criteria:**

**Given** any job payload schema,
**When** I inspect it,
**Then** `tenant_id: string` and `traceparent: string` are required fields.

**Given** a worker handler executes,
**When** it starts,
**Then** `tenantGuard(payload.tenant_id)` runs before any DB access
**And** OTel `context.with(extractTraceparent(payload.traceparent))` wraps the handler.

**Given** a lint rule `no-job-without-tenant-guard.yml`,
**When** a handler accesses `ctx.db` without prior `tenantGuard()`,
**Then** the lint fails.

**Given** the pattern is invariant,
**When** Story 1.8 tracks it,
**Then** `INV-jobs-tenant-propagation` is registered.

##### Story 8.4: `packages/email/` Resend wrapper + baseline templates

As a fork operator,
I want `packages/email/resend.ts` wrapping Resend with fire-and-forget from `email.send_*` jobs, plus baseline react-email templates at `packages/email/templates/` — `verify.tsx`, `invite.tsx`, `reset-password.tsx`,
So that transactional email is uniform and the baseline flows (verify/invite/reset) have canonical templates (FR20).

**Acceptance Criteria:**

**Given** `packages/email/resend.ts`,
**When** I inspect it,
**Then** it exposes `sendEmail(template, payload)` that dispatches via Resend
**And** callers MUST enqueue an `email.send_*` job rather than call directly.

**Given** `packages/email/templates/`,
**When** I inspect it,
**Then** `verify.tsx`, `invite.tsx`, `reset-password.tsx` exist as react-email components
**And** each template accepts typed props.

**Given** a job `email.send_verification`,
**When** the worker processes,
**Then** it renders `verify.tsx` with the payload, sends via Resend, and on error retries per pg-boss policy.

**Given** a lint rule prevents direct Resend usage outside `packages/email/`,
**When** any other package imports Resend,
**Then** the lint rejects.

##### Story 8.5: `packages/audit/` append-only log API

As a substrate maintainer,
I want `packages/audit/log.ts` write-only API + `packages/audit/events.ts` event-type enum with format `<resource>.<verb>` past-tense (e.g., `user.signed_up`, `subscription.created`, `invite.accepted`), backed by Postgres INSERT-only permissions + Prisma client contract,
So that security-relevant events are recorded append-only and application code cannot modify past entries (FR23, NFR13).

**Acceptance Criteria:**

**Given** `packages/audit/log.ts`,
**When** I inspect it,
**Then** the only exported function is `auditLog.write(event, payload)` — no update/delete.

**Given** the Postgres DB,
**When** I inspect `audit_log` table permissions,
**Then** application role has INSERT + SELECT only (no UPDATE/DELETE)
**And** superuser privileges are required to modify entries.

**Given** `packages/audit/events.ts`,
**When** I inspect it,
**Then** it exports an enum of allowed event types
**And** every event key follows `<resource>.<verb>` past-tense.

**Given** a lint rule prevents direct `audit_log` table inserts from other packages,
**When** any other code imports Prisma and inserts into `audit_log`,
**Then** the lint rejects.

##### Story 8.6: Scheduled jobs scaffold (session-cleanup, rls-bench)

As a substrate maintainer,
I want scheduled job scaffolds at `packages/jobs/scheduled/` — `session-cleanup.ts` (daily; consumed by Epic 9 S1) and `rls-bench.ts` (nightly; consumed by Epic 6 D4) — with additional scheduled jobs landing in their owning epics,
So that recurring work has a canonical home and scheduling conventions are pinned (FR19 extension).

**Acceptance Criteria:**

**Given** `packages/jobs/scheduled/session-cleanup.ts`,
**When** I inspect it,
**Then** it registers a daily cron via pg-boss
**And** the handler deletes sessions where `expired_at < now()`.

**Given** `packages/jobs/scheduled/rls-bench.ts`,
**When** I inspect it,
**Then** it registers a nightly cron
**And** invokes Epic 6 Story 6.8's benchmark harness.

**Given** new scheduled jobs,
**When** added in subsequent epics,
**Then** they land in `packages/jobs/scheduled/`
**And** follow the convention established here.

##### Story 8.7: Enforcement lint rules (no-direct-resend, no-direct-audit-table, no-ad-hoc-job-names)

As a substrate maintainer,
I want enforcement lint rules preventing: direct Resend imports outside `packages/email/`, direct `audit_log` inserts outside `packages/audit/`, ad-hoc `pgBoss.send()` outside the typed registry,
So that the platform abstractions are enforced, not convention (structural constraints).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/eslint.config.keel-invariants.js`,
**When** I inspect it,
**Then** `no-restricted-imports` rules forbid: `resend` outside `packages/email/`, `pg-boss` direct use outside `packages/jobs/`.

**Given** a Semgrep rule `no-direct-audit-insert.yml`,
**When** it runs,
**Then** direct Prisma `audit_log.create()` or raw INSERT SQL against `audit_log` fails outside `packages/audit/`.

**Given** violations,
**When** pre-commit runs,
**Then** commits are rejected with a pointer to the canonical API.

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

#### Stories

##### Story 9.1: `packages/core/auth/` + better-auth config

As a fork operator,
I want `packages/core/auth/better-auth.ts` configuring better-auth with DB-backed sessions, email/password, and Google OAuth providers,
So that auth is hardwired with no adapter surface at 1.0 (FR54 foundation, FR57 foundation).

**Acceptance Criteria:**

**Given** `packages/core/auth/better-auth.ts`,
**When** I inspect it,
**Then** better-auth is configured with Prisma adapter, `Session`/`Account` models, email+password provider, Google OAuth provider
**And** no adapter abstraction layer exists (NFR: hardwired at 1.0).

**Given** a test suite,
**When** auth init runs,
**Then** better-auth initialises without errors
**And** a stub user can be created via the library API.

##### Story 9.2: Session + Account Prisma schema + session-cleanup wire-up (S1)

As a substrate maintainer,
I want `Session` and `Account` tables added to `packages/db/prisma/schema.prisma` (tenant-scoped where applicable) plus wiring for Epic 8's `session-cleanup` scheduled job to daily-delete expired sessions,
So that session storage is canonical and expired rows don't accumulate (S1).

**Acceptance Criteria:**

**Given** `schema.prisma`,
**When** I inspect it,
**Then** `Session { id, user_id, expired_at, last_activity, mfa_verified_at, revoked_at }` and `Account { id, user_id, provider, provider_account_id, ... }` exist
**And** each has UUIDv7 PK.

**Given** Epic 8 Story 8.6's `session-cleanup` job,
**When** it runs daily,
**Then** it deletes sessions where `expired_at < now()` AND `revoked_at < now() - interval '30 days'`.

**Given** Epic 6's CI check for RLS on tenant-scoped tables,
**When** Session references a tenant context,
**Then** RLS policies from Epic 5 generator cover it.

##### Story 9.3: A2 tRPC middleware stack order

As a substrate maintainer,
I want a pinned tRPC middleware stack order in `packages/contracts/src/middleware/` — `openTelemetry` → `loggerContext` → `tenantGuard` → `requireAuth` → `requireRecentAuth` → handler,
So that all requests are traced, logged, tenant-scoped, auth-gated, and step-up-checked in the same order (A2).

**Acceptance Criteria:**

**Given** `packages/contracts/src/middleware/`,
**When** I inspect it,
**Then** 5 middleware modules exist in separate files with the order documented in `index.ts`.

**Given** a tRPC procedure,
**When** it applies the default middleware stack,
**Then** the 5 middlewares execute in the pinned order
**And** any reordering is caught by a test in `packages/contracts/test/middleware-order.test.ts`.

**Given** the invariant is registered,
**When** Story 1.8 tracks it,
**Then** `INV-trpc-middleware-order` is in the manifest.

##### Story 9.4: A3 error code enum + i18n key mapping

As a substrate maintainer,
I want `packages/contracts/src/errors.ts` exporting an error code enum `UNAUTHORIZED | FORBIDDEN | NOT_FOUND | BAD_REQUEST | INTERNAL_SERVER_ERROR | STEP_UP_REQUIRED | TENANT_MISMATCH` with Zod validation auto-mapping to `BAD_REQUEST` and messages typed as i18n keys (Epic 11 consumer),
So that error handling is uniform across the app (A3).

**Acceptance Criteria:**

**Given** `packages/contracts/src/errors.ts`,
**When** I inspect it,
**Then** the enum is exported with the 7 codes
**And** every code maps to an i18n key (e.g., `errors.unauthorized`).

**Given** a Zod validation error inside a tRPC handler,
**When** it throws,
**Then** the middleware catches and converts to `BAD_REQUEST` with the validation detail preserved.

**Given** i18n keys are consumed,
**When** Epic 11's i18n framework resolves them,
**Then** the code displays localised messages.

##### Story 9.5: Signup flow (email+password) + email verification

As a user,
I want to sign up via email+password and receive a verification email with a single-use 24h-TTL token that flips `user.email_verified_at` when clicked,
So that verified identity is a prerequisite for full access (FR54, FR55).

**Acceptance Criteria:**

**Given** a signup tRPC mutation,
**When** I submit email+password,
**Then** better-auth creates the user and enqueues `email.send_verification` (Epic 8 Story 8.4)
**And** the mutation returns success with session established.

**Given** a verification email,
**When** the user clicks the link,
**Then** `/verify?token=...` consumes the token, flips `user.email_verified_at`, redirects to app.

**Given** an expired token (24h TTL),
**When** the user clicks,
**Then** the route shows "verification link expired — resend?" with a resend button that enqueues a new `email.send_verification`.

**Given** a single-use token,
**When** the token is reused,
**Then** the second attempt shows "already verified".

##### Story 9.6: Google OAuth + PKCE + state

As a user,
I want Google OAuth as an alternative signup/login method with PKCE + state-parameter verification preventing authorization-code injection,
So that OAuth is secure-by-default (FR54, NFR25).

**Acceptance Criteria:**

**Given** `packages/core/auth/google-oauth.ts`,
**When** I inspect it,
**Then** the flow enforces PKCE (code_challenge + code_verifier) and state parameter.

**Given** the `/auth/google/callback` route,
**When** state does not match,
**Then** the callback rejects with `UNAUTHORIZED` (no code injection).

**Given** a successful Google OAuth,
**When** the user returns,
**Then** better-auth creates `Account { provider: 'google', ... }` linked to the user
**And** subsequent logins via Google reuse the account.

##### Story 9.7: Password reset flow (PRD clarification)

As a user,
I want to reset my password via `/reset-password` (takes email; returns 204 regardless of user existence to avoid enumeration; enqueues `email.send_reset_password`) and `/reset-password/confirm` (takes token + new password; validates; updates session),
So that a forgotten password is recoverable without leaking which emails are users (PRD clarification per user request + baseline template).

**Acceptance Criteria:**

**Given** `/reset-password`,
**When** I POST email,
**Then** the route enqueues `email.send_reset_password` if the user exists; otherwise silently proceeds
**And** returns 204 in both cases (no email-enumeration vector).

**Given** `/reset-password/confirm`,
**When** I submit a valid token + new password,
**Then** better-auth updates the password, revokes existing sessions, creates a fresh session
**And** `password.reset_completed` audit event fires (Story 9.12).

**Given** an invalid / expired token,
**When** I submit,
**Then** the route responds with `BAD_REQUEST` i18n-keyed message
**And** no password change occurs.

##### Story 9.8: DB-backed session revocation (FR57)

As a fork operator,
I want sessions backed by a DB `Session` row + cookie; revocation via `Session.revokedAt`; `requireAuth` middleware rejects revoked sessions,
So that sessions are revocable server-side (FR57; stateless-JWT is Tier-2 deviation only per NFR12).

**Acceptance Criteria:**

**Given** a valid session,
**When** `requireAuth` runs,
**Then** it queries `Session` by cookie, checks `revoked_at IS NULL` AND `expired_at > now()`
**And** proceeds if valid, else returns `UNAUTHORIZED`.

**Given** a revoked session,
**When** `requireAuth` runs,
**Then** the request is rejected.

**Given** stateless-JWT is Tier-2,
**When** `docs/invariants/auth.md` is read,
**Then** NFR12 is documented as "substrate = DB sessions; JWT = fork-level deviation requiring documented rationale."

##### Story 9.9: Step-up middleware for sensitive actions (S2)

As a fork operator,
I want `requireRecentAuth({ maxAge: '5m' })` tRPC middleware at `packages/core/auth/step-up.ts` checking `session.lastActivity` + `session.mfaVerifiedAt`; on expiry returns `TRPCError({ code: 'STEP_UP_REQUIRED' })`; client catches, redirects to re-auth,
So that sensitive actions (billing cancel, account deletion, team owner transfer) require recent auth (FR58, S2).

**Acceptance Criteria:**

**Given** `requireRecentAuth({ maxAge: '5m' })`,
**When** a handler applies it and the session's `last_activity` is > 5 min old,
**Then** the middleware throws `TRPCError({ code: 'UNAUTHORIZED', message: 'STEP_UP_REQUIRED' })`.

**Given** billing routes (Epic 10) + tenant-admin routes,
**When** they declare the middleware,
**Then** step-up is enforced consistently.

**Given** the client receives `STEP_UP_REQUIRED`,
**When** it catches,
**Then** the UI redirects to a re-auth prompt (password or step-up factor)
**And** on success, `last_activity` is refreshed.

##### Story 9.10: Log out all sessions (FR59)

As a user,
I want a tRPC mutation that sets `Session.revokedAt = now()` for every session of `user.id`,
So that I can revoke access across devices with one action (FR59).

**Acceptance Criteria:**

**Given** `auth.revokeAllSessions` tRPC mutation,
**When** called,
**Then** every Session of `current_user_id` has `revoked_at = now()`
**And** the current request's session is also revoked (user is logged out).

**Given** a revoked session attempts the next request,
**When** `requireAuth` runs (Story 9.8),
**Then** the request is rejected.

**Given** the UI exposes the action,
**When** a user clicks "Log out all devices" in settings (lands in Epic 12),
**Then** the mutation fires and the user is redirected to login.

##### Story 9.11: Auth UI screens (signup/login/verify/reset-password)

As a user,
I want minimal auth UI screens at `apps/web/app/routes/{signup,login,verify,reset-password}.tsx` using Epic 7 primitives (`ui.form.01`, `ui.form-field.01`, `ui.button.01`, `ui.input.text.01`) with catalog-ID citation in every route header,
So that auth flows are operable with a11y baseline + i18n keys (FR54/FR55 UI side, UX-DR63).

**Acceptance Criteria:**

**Given** each route file,
**When** I inspect the header,
**Then** a catalog-ID comment appears (e.g., `/* catalog: ui.screen.signup.01 */`).

**Given** axe-core critical violations,
**When** tests run against the routes,
**Then** zero critical violations
**And** Playwright keyboard traversal completes all actions.

**Given** the 48-combo snapshot matrix (360/768/1280 × LTR/RTL × light/dark),
**When** M9 runs the screenshot matrix,
**Then** every combo renders cleanly (dark VISUAL verification deferred to 1.1 per V2 amendment; dark tokens still ship).

**Given** all copy is i18n-keyed,
**When** the i18n framework (Epic 11) loads,
**Then** English strings render; bare strings are lint-rejected per FR27.

##### Story 9.12: Auth audit events wire-up

As a substrate maintainer,
I want auth actions recording audit events via Epic 8 Story 8.5 — `user.signed_up`, `user.logged_in`, `session.revoked`, `password.reset_requested`, `password.reset_completed`,
So that security-relevant auth events are append-only logged (FR23 consumer).

**Acceptance Criteria:**

**Given** signup succeeds,
**When** the user is created,
**Then** `auditLog.write('user.signed_up', { user_id, method: 'email' | 'google' })` fires.

**Given** login succeeds,
**When** the session is established,
**Then** `auditLog.write('user.logged_in', { user_id, session_id })` fires.

**Given** session revocation (manual, all-logout, or password reset),
**When** `revoked_at` is set,
**Then** `auditLog.write('session.revoked', { session_id, reason })` fires.

**Given** password-reset flow,
**When** the email is enqueued,
**Then** `password.reset_requested` fires; on confirm, `password.reset_completed` fires.

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

#### Stories

##### Story 10.1: `packages/billing/` Paddle integration + two shape presets

As a fork operator,
I want `packages/billing/` integrating Paddle via the official SDK, with two shape-specific preset configs (`packages/billing/presets/team-seats.ts` for B2B; `packages/billing/presets/individual-subscription.ts` for B2C) selected from `keel.config.ts → shape`,
So that billing behaviour adapts to shape without manual per-fork wiring (FR60).

**Acceptance Criteria:**

**Given** `packages/billing/`,
**When** I inspect it,
**Then** `paddle.ts` wraps the Paddle SDK with typed accessors
**And** `presets/team-seats.ts` and `presets/individual-subscription.ts` exist.

**Given** the fork's `keel.config.ts` shape,
**When** the billing module loads,
**Then** the matching preset is active
**And** preset values (plan IDs, proration rules) are typed at build time.

**Given** Epic 5 Story 5.4 emits `packages/billing/paddle/preset.generated.ts`,
**When** Epic 10 consumes it,
**Then** runtime uses the emitted preset (not hand-edited source).

##### Story 10.2: Paddle webhook endpoint + signature verification (FR61, NFR23)

As a substrate maintainer,
I want `apps/web/app/routes/webhooks.paddle.ts` as a non-tRPC external HTTP surface validating signatures via Paddle official SDK `verifyWebhookSignature()`,
So that only genuine Paddle webhooks reach lifecycle handlers (FR61, NFR23).

**Acceptance Criteria:**

**Given** a POST to `/webhooks/paddle`,
**When** the handler validates the signature,
**Then** on success, the payload is dispatched to lifecycle handlers
**And** on failure, the route responds `400` with no side effects.

**Given** unsigned or tampered webhooks,
**When** the route receives them,
**Then** the signature verification fails
**And** no DB write occurs.

**Given** the route is one of 3 non-tRPC surfaces (per architecture),
**When** a lint rule enforces this list,
**Then** any new non-tRPC HTTP surface is rejected outside the allowlist.

##### Story 10.3: `webhook_events` idempotency table + layer (A4, NFR22)

As a substrate maintainer,
I want a `webhook_events` Prisma table with `PK (provider, event_id)` that the webhook handler writes before dispatching lifecycle logic — replay becomes a no-op,
So that duplicate webhook deliveries do not double-process (A4, NFR22).

**Acceptance Criteria:**

**Given** `schema.prisma`,
**When** I inspect it,
**Then** `WebhookEvent { provider, event_id, received_at, processed_at, payload_hash }` exists with `@@unique([provider, event_id])`.

**Given** a duplicate webhook,
**When** the handler attempts to insert,
**Then** the unique constraint violation is caught
**And** the handler returns 200 without re-dispatching.

**Given** a new webhook,
**When** inserted successfully,
**Then** lifecycle handlers run; `processed_at` is set on success.

**Given** pathological races,
**When** two deliveries arrive simultaneously,
**Then** exactly one wins the insert; the other no-ops.

##### Story 10.4: Lifecycle handlers (subscription + webhook-events)

As a fork operator,
I want lifecycle handlers at `packages/billing/lifecycle/subscription.ts` (create/cancel/upgrade/downgrade/dunning) and `webhook-events.ts` (idempotency layer),
So that every Paddle lifecycle event has a typed handler (FR61 extension).

**Acceptance Criteria:**

**Given** `subscription.ts`,
**When** I inspect it,
**Then** typed handlers exist per event: `onCreated`, `onCancelled`, `onUpgraded`, `onDowngraded`, `onDunning`
**And** each writes an audit event (`subscription.created`, etc.) and persists subscription state.

**Given** `webhook-events.ts`,
**When** it receives a dispatched event,
**Then** it invokes the matching subscription handler
**And** wraps in OTel span for observability.

**Given** a handler fails,
**When** the error propagates,
**Then** the webhook responds 500 to trigger Paddle's retry
**And** `processed_at` stays null so the next retry re-enters the handler.

##### Story 10.5: Subscription-gated middleware (FR62)

As a substrate maintainer,
I want `packages/billing/src/middleware/require-subscription.ts` — tRPC middleware checking subscription state from DB — applied to premium routes,
So that free-tier users cannot reach premium features (FR62).

**Acceptance Criteria:**

**Given** a premium tRPC procedure,
**When** it applies `requireSubscription({ plan: 'pro' })`,
**Then** the middleware checks `subscription.status == 'active'` AND `subscription.plan >= 'pro'`
**And** rejects with `FORBIDDEN` otherwise.

**Given** a grace-period (dunning) state,
**When** the middleware runs,
**Then** access is granted if within configured grace window, else denied.

**Given** usage-quota-gated access,
**When** considered,
**Then** it is deferred to 1.2 API-first shape (documented).

##### Story 10.6: Billing UI (confirmation/cancel/portal) with step-up on cancel

As a user,
I want minimal billing UI at `apps/web/app/routes/billing.{index,cancel,portal}.tsx` using Epic 7 primitives, with step-up auth (Epic 9 Story 9.9) required on cancel,
So that I can subscribe, cancel, and access the Paddle portal without Keel authoring full checkout UI (FR60 UI side, FR58 application).

**Acceptance Criteria:**

**Given** `/billing`,
**When** a user visits,
**Then** the page shows current subscription + a "Manage in Paddle" link + a Cancel button.

**Given** the Cancel button,
**When** clicked,
**Then** the tRPC mutation applies `requireRecentAuth({maxAge: '5m'})`; if step-up fails, UI prompts for re-auth.

**Given** `/billing/portal`,
**When** a user clicks "Manage in Paddle",
**Then** they redirect to Paddle-hosted portal
**And** return to `/billing` after.

**Given** `/billing/cancel`,
**When** reached post-cancel,
**Then** a confirmation page shows + an option to re-subscribe.

##### Story 10.7: Webhook contract tests at pre-merge-fast (recorded fixtures)

As a substrate maintainer,
I want webhook signature-verification contract tests at pre-merge-fast using deterministic recorded fixtures (no live-network hits),
So that webhook handling is verified on every PR without flake (testing discipline).

**Acceptance Criteria:**

**Given** `packages/billing/test/webhook-contract.test.ts`,
**When** it runs,
**Then** it verifies signature validation against recorded Paddle fixtures
**And** tests cover: valid signature (accept), tampered payload (reject), wrong signature (reject), replay (no-op via idempotency).

**Given** fixture maintenance,
**When** Paddle updates signature format,
**Then** fixtures are re-recorded + committed
**And** the update is captured in a PR.

##### Story 10.8: Release-gated live Paddle sandbox end-to-end test

As a substrate maintainer,
I want a release-gated (manual, Epic 13 tier) test running paid Paddle sandbox subscription end-to-end on both shapes (2×2 matrix at 1.0),
So that a real-network billing flow is verified before a cut (release gating).

**Acceptance Criteria:**

**Given** Epic 13's release-gated CI tier,
**When** triggered manually,
**Then** the test runs against Paddle sandbox
**And** both B2B team-seats + B2C individual flows are exercised.

**Given** the test completes,
**When** results surface,
**Then** pass/fail is recorded in the release notes
**And** failure blocks the release cut.

**Given** sandbox API-key rotation,
**When** secrets are rotated per architecture I6,
**Then** the test continues to work via `act` `.secrets` (Epic 2 Story 2.2) for local + GitHub secrets for CI.

##### Story 10.9: Growth-tier second billing provider (FR63 migration guide)

As a substrate maintainer,
I want a documented migration guide for Growth-tier fork operators who need a second billing provider (Stripe standard for API-first or Stripe Connect for marketplace), with a thin adapter pattern sketched,
So that non-Paddle forks have a clear path without blocking 1.0 (FR63, Growth-tier).

**Acceptance Criteria:**

**Given** `docs/forks/billing-second-provider.md`,
**When** I read it,
**Then** the adapter pattern is documented (interface shape, touchpoints, test obligations)
**And** migration steps are enumerated (new preset, new webhook handler, replace `@keel/billing` imports).

**Given** the 1.0 substrate,
**When** a fork operator adopts the pattern,
**Then** they fork `packages/billing/` and implement the second provider
**And** their fork's `INVARIANTS.fork.md` (Story 1.16) captures the deviation.

**Given** 1.0 does NOT ship this adapter,
**When** I inspect `packages/billing/`,
**Then** only Paddle impl exists
**And** the migration guide is forward-compatible.

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

#### Stories

##### Story 11.1: `packages/core/otel.ts` OTel SDK init + middleware

As a substrate maintainer,
I want `packages/core/otel.ts` initialising the OTel SDK with console-exporter default (prevents network errors when `OTEL_EXPORTER_OTLP_ENDPOINT` unset) and OTLP exporter when set, plus `packages/contracts/middleware/opentelemetry.ts` as A2 middleware step [0],
So that every request is traced without forcing OTel infrastructure on every fork (FR22 foundation, NFR32).

**Acceptance Criteria:**

**Given** `packages/core/otel.ts`,
**When** I inspect it,
**Then** the SDK initialises with `ConsoleSpanExporter` when `OTEL_EXPORTER_OTLP_ENDPOINT` is unset
**And** switches to `OTLPTraceExporter` when set.

**Given** `packages/contracts/middleware/opentelemetry.ts`,
**When** applied as A2 step [0],
**Then** every tRPC request creates a root span
**And** downstream middleware (loggerContext → tenantGuard → requireAuth → requireRecentAuth → handler) become child spans.

**Given** the exporter endpoint,
**When** read from `keel.config.ts → otelExporter` at build time,
**Then** the value is baked into the app
**And** runtime cannot change it (NFR: build-time only for this shape field).

##### Story 11.2: Span naming conventions + attribute keys

As a substrate maintainer,
I want span names following `<package>.<operation>` (e.g., `trpc.team.invite.create`, `db.user.findMany`, `job.email.send_verification`) and attribute keys following `keel.<namespace>.<attr>` (e.g., `keel.tenant.id`, `keel.shape`),
So that Keel's observability output is consistent across forks and searchable (observability contract).

**Acceptance Criteria:**

**Given** a tRPC handler,
**When** the OTel span is created,
**Then** the name is `trpc.<router>.<procedure>`
**And** `keel.tenant.id` + `keel.shape` attributes are set.

**Given** Prisma-side spans,
**When** queries execute,
**Then** span name is `db.<model>.<op>` (e.g., `db.user.findMany`).

**Given** job handlers,
**When** pg-boss runs,
**Then** span name is `job.<domain>.<action>`
**And** parent trace context from `traceparent` is restored per Epic 8 Story 8.3.

**Given** naming conventions are invariant,
**When** Story 1.8 tracks them,
**Then** `INV-otel-span-naming` is registered
**And** a Semgrep rule flags non-conforming span names (best-effort; runtime wrapping ensures most cases).

##### Story 11.3: Configurable sampling (100% errors, 10% non-error)

As a substrate maintainer,
I want sampling configured via `packages/config` — 100% for error-bearing traces, 10% for non-error traces in production forks,
So that errors are always captured while non-error overhead is bounded (NFR32).

**Acceptance Criteria:**

**Given** `packages/core/otel.ts` sampling configuration,
**When** I inspect it,
**Then** a parent-based sampler with error-priority logic is configured
**And** defaults are `error_rate: 1.0, non_error_rate: 0.1`.

**Given** fork operators want to override,
**When** they set `OTEL_SAMPLER_NON_ERROR_RATE=0.5` in `.envrc`,
**Then** the override is honoured.

**Given** a trace contains an error span,
**When** sampling evaluates,
**Then** the whole trace is retained (100% error policy).

##### Story 11.4: `packages/flags/` feature-flag evaluator (server-side, route-loader-scoped)

As a fork operator,
I want `packages/flags/evaluator.ts` evaluating feature flags server-side with static-code + env-var override at 1.0, plus `packages/flags/loader-scope.ts` integrating with TanStack Router `loader`,
So that flags are evaluated at SSR time with no client flicker (FR21, F3).

**Acceptance Criteria:**

**Given** `packages/flags/evaluator.ts`,
**When** I inspect it,
**Then** flags are typed constants with `evaluator.isEnabled(flagName, context)` returning boolean
**And** env-var override (`KEEL_FLAG_<NAME>=true`) is honoured.

**Given** a TanStack Router `loader`,
**When** it uses `packages/flags/loader-scope.ts`,
**Then** flag state is resolved server-side before render
**And** the component receives evaluated flag values as typed props.

**Given** client-side code,
**When** it attempts to access `packages/flags/` at runtime,
**Then** a build-time constraint (bundler config) excludes it from client bundle.

##### Story 11.5: i18n framework baseline (`en.json`, typed keys codegen)

As a fork operator,
I want `apps/web/app/i18n/en.ts` as the English baseline, `apps/web/app/i18n/messages.generated.ts` as typed-keys codegen output, with key-path format `<domain>.<surface>.<key>` (dot-separated),
So that all user-facing content is typed and autocomplete-friendly (FR24, FR26).

**Acceptance Criteria:**

**Given** `apps/web/app/i18n/en.ts`,
**When** I inspect it,
**Then** all baseline English strings are present
**And** keys follow `<domain>.<surface>.<key>` (e.g., `auth.signup.title`).

**Given** `messages.generated.ts`,
**When** a codegen step runs,
**Then** the file contains a typed enum of all keys from `en.ts`
**And** TypeScript can autocomplete `t('<key>')`.

**Given** translator notes,
**When** I inspect non-trivial keys,
**Then** JSON-schema comments describe the context
**And** translators have guidance per UX-DR translator-notes requirement.

##### Story 11.6: Bare-strings lint rule (FR27 teeth)

As a substrate maintainer,
I want a TypeScript + ESLint rule rejecting bare user-facing strings in `.tsx` files, forcing `t('<key>')` usage,
So that missing translations cannot slip through (FR27).

**Acceptance Criteria:**

**Given** a `.tsx` file with `<Button>Click me</Button>`,
**When** the lint rule runs,
**Then** it flags the bare string
**And** the commit is rejected.

**Given** `<Button>{t('action.click_me')}</Button>`,
**When** the lint runs,
**Then** it passes.

**Given** exceptions (e.g., non-user-facing strings in comments or test fixtures),
**When** allowed via `// i18n-exempt: <reason>` inline comment,
**Then** the rule honours the exemption
**And** the reason is documented.

##### Story 11.7: Accept-Language detection + user-preference override (FR25)

As a user,
I want my locale detected from the `Accept-Language` header on first visit and overridden by my persisted `user.locale_preference` after I set one,
So that the app respects my language without re-prompting (FR25).

**Acceptance Criteria:**

**Given** a request without `user.locale_preference`,
**When** the app loads,
**Then** the locale is parsed from `Accept-Language` and matched against available locales (`en`, `ar`, `de`, plus fork additions)
**And** falls back to English if no match.

**Given** a request with `user.locale_preference = 'ar'`,
**When** the app loads,
**Then** Arabic is used
**And** `<html lang="ar" dir="rtl">` is server-rendered.

**Given** a logged-out user,
**When** they browse,
**Then** locale state lives in a session cookie until login
**And** post-login, `user.locale_preference` takes precedence.

##### Story 11.8: RTL + logical CSS + `<html lang/dir>` (UX-DR49)

As a fork operator,
I want logical CSS properties only (`margin-inline-start` not `margin-left`), `<html lang={BCP-47}>` + `<html dir="rtl">` server-rendered from active locale, and scaffolded `ar.json` (RTL test) + `de.json` (LTR test) locales alongside full `en.json`,
So that RTL rendering works without component rewrites (UX-DR49, NFR21).

**Acceptance Criteria:**

**Given** every primitive's CSS (Epic 7),
**When** I inspect styles,
**Then** logical properties are used (`inline-start`/`inline-end`/`block-start`/`block-end`)
**And** physical properties (`margin-left`, etc.) are lint-rejected.

**Given** a user with `locale = "ar"`,
**When** the app SSRs,
**Then** `<html lang="ar" dir="rtl">` renders
**And** all primitives flip cleanly.

**Given** `apps/web/app/i18n/ar.json`,
**When** I inspect it,
**Then** the file exists as a scaffolded empty skeleton with every baseline key
**And** the same for `de.json` (LTR test).

**Given** a 360/768/1280 × LTR/RTL × light matrix snapshot at M9,
**When** screenshots render,
**Then** all 18 combos pass (dark visual deferred to 1.1 per V2).

##### Story 11.9: i18n-key parity check at pre-commit (UX-DR56)

As a substrate maintainer,
I want a pre-commit check comparing each locale file against the baseline English, failing the commit if any locale is missing keys or has orphan keys,
So that translation drift is caught early (UX-DR56).

**Acceptance Criteria:**

**Given** `apps/web/app/i18n/en.json` is baseline,
**When** the check runs,
**Then** every other locale file (`ar.json`, `de.json`, fork additions) is diffed against it.

**Given** a missing key in `ar.json`,
**When** the check runs,
**Then** it fails with a pointer naming the missing key.

**Given** an orphan key (present in a locale but not in baseline),
**When** the check runs,
**Then** it fails with a pointer to the orphan.

**Given** scaffolded empty locales at 1.0,
**When** the check runs,
**Then** empty-value keys are allowed (translator placeholders) but the key MUST exist
**And** missing keys always fail.

##### Story 11.10: End-user locale persistence (FR64)

As a user,
I want my locale preference persisted in DB at `user.locale_preference` and consumed on every request,
So that my language choice survives logins + devices (FR64).

**Acceptance Criteria:**

**Given** `schema.prisma`,
**When** I inspect the User model,
**Then** `locale_preference: String?` column exists
**And** defaults to null (fall back to Accept-Language).

**Given** a locale-selector UI in Epic 12,
**When** the user changes locale,
**Then** a tRPC mutation updates `user.locale_preference`
**And** subsequent requests honour it.

**Given** an unauthenticated user,
**When** they set a locale,
**Then** it's stored in a session cookie until login
**And** copied to `user.locale_preference` on first login if not already set.

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

#### Stories

##### Story 12.1: Shape-aware template resolution (build-time; no runtime branching)

As a substrate maintainer,
I want routes in `apps/web/app/routes/*.tsx` to import from `packages/ui/src/templates/_${shape}/*` with resolution at build time via keel-generator (Epic 5); an ESLint rule forbids cross-shape template imports; no `if (shape === 'b2b')` in product code,
So that shape switching regenerates imports rather than adding runtime branches (UX-DR22, UX-DR65).

**Acceptance Criteria:**

**Given** a route file,
**When** I inspect it,
**Then** imports come from `@keel/ui/templates/_<current-shape>/...`
**And** no `if (shape === 'b2b')` or equivalent runtime branching exists.

**Given** the ESLint rule,
**When** a route imports from `_b2c` in a B2B fork,
**Then** the rule flags the cross-shape import.

**Given** shape change,
**When** the fork switches from b2b to b2c (Epic 5 Story 5.9 workflow),
**Then** `pnpm generate` rewrites imports
**And** the app builds cleanly.

##### Story 12.2: Shared screen templates (audit-log, billing, sessions, locale, settings-shell, app-shell)

As a fork operator,
I want shared screen templates in `packages/ui/src/templates/shared/` — `audit-log.tsx`, `billing.tsx`, `sessions.tsx`, `locale.tsx`, `settings-shell.tsx`, `app-shell.tsx`,
So that shape-neutral screens have one canonical implementation (composition epic).

**Acceptance Criteria:**

**Given** each template,
**When** I inspect it,
**Then** it composes Epic 7 primitives + Epic 9 auth context + Epic 10 billing state (where relevant) + Epic 11 i18n keys.

**Given** `audit-log.tsx`,
**When** rendered,
**Then** it shows filtered + paginated audit events (Epic 8 audit log).

**Given** `sessions.tsx`,
**When** rendered,
**Then** a list of the user's sessions shows with per-row "Revoke" hitting FR57 revocation + FR59 log-out-all.

**Given** `locale.tsx`,
**When** rendered,
**Then** a locale selector hits the FR64 mutation from Epic 11 Story 11.10.

**Given** `app-shell.tsx`,
**When** rendered,
**Then** it invokes `ui.app-shell.01` (Epic 7 Story 7.3) with shape-aware nav structure.

##### Story 12.3: B2B screen templates (onboarding-team, team-members, team-invite, billing-team-seats)

As a B2B fork operator,
I want B2B-specific screen templates in `packages/ui/src/templates/_b2b/` — `onboarding-team.tsx` (create/accept-invite post-signup), `team-members.tsx` (roster + role + remove), `team-invite.tsx` (email + role), `billing-team-seats.tsx`,
So that a B2B fork has a complete team-lifecycle UI (FR56 B2B).

**Acceptance Criteria:**

**Given** a signup completes,
**When** `onboarding-team.tsx` renders,
**Then** the user can create a new team or accept a pending invite by token.

**Given** `team-members.tsx`,
**When** I render it,
**Then** the roster table (using `pattern.table-with-row-actions.01` from Epic 7) shows members + roles + a dropdown action (change role / remove).

**Given** `team-invite.tsx`,
**When** the owner submits a new invite,
**Then** an email+role is captured + the `email.send_invite` job fires (Epic 8).

**Given** `billing-team-seats.tsx`,
**When** rendered,
**Then** current seat count + per-seat usage + upgrade/downgrade actions are shown.

##### Story 12.4: B2C screen templates (onboarding-profile, profile, billing-individual)

As a B2C fork operator,
I want B2C-specific templates in `packages/ui/src/templates/_b2c/` — `onboarding-profile.tsx` (name + locale), `profile.tsx` (personal profile mgmt), `billing-individual.tsx`,
So that a B2C fork has a complete individual-account UI (FR56 B2C).

**Acceptance Criteria:**

**Given** signup completes in B2C mode,
**When** `onboarding-profile.tsx` renders,
**Then** the user sets display name + locale (FR64 consumer).

**Given** `profile.tsx`,
**When** rendered,
**Then** editable fields for name, avatar (if present), locale, and password-change entry point exist.

**Given** `billing-individual.tsx`,
**When** rendered,
**Then** current plan + upgrade/downgrade/cancel actions are shown.

##### Story 12.5: Route shims + catalog-ID citations

As a substrate maintainer,
I want every route file in `apps/web/app/routes/` as a thin shim importing from the shape-partitioned template + a catalog-ID citation in the header (e.g., `/* catalog: ui.screen.team-members.01 */`),
So that product code has no logic and catalog references are queryable (UX-DR63).

**Acceptance Criteria:**

**Given** any route file,
**When** I inspect it,
**Then** it is under ~15 lines
**And** starts with a `/* catalog: ui.screen.<name>.01 */` comment
**And** re-exports from the template module.

**Given** catalog references,
**When** `docs/design/catalog.md` (Story 7.4) is consulted,
**Then** every `ui.screen.*` referenced by a route exists in the catalog
**And** Story 1.9 sync gate catches missing entries.

##### Story 12.6: Shape-aware nav (UX-DR29)

As a fork operator,
I want `ui.app-shell.01`'s navigation derived at build time from active shape template: B2B exposes Dashboard · Team · Billing · Settings; B2C exposes Dashboard · Profile · Billing · Settings,
So that nav reflects shape without runtime branching (UX-DR29).

**Acceptance Criteria:**

**Given** a B2B fork,
**When** the app shell renders,
**Then** top-level nav items are Dashboard · Team · Billing · Settings.

**Given** a B2C fork,
**When** the app shell renders,
**Then** top-level nav items are Dashboard · Profile · Billing · Settings.

**Given** the nav structure is defined in shape templates,
**When** Story 12.1's generator resolution runs,
**Then** the correct nav config is imported.

**Given** a lint rule,
**When** I attempt `if (shape === '...')` in `app-shell.tsx`,
**Then** the rule rejects.

##### Story 12.7: Team CRUD + invite flow (FR56 B2B)

As a B2B user,
I want full team lifecycle — create team, join via invite, leave team, transfer ownership — with step-up auth (Epic 9 Story 9.9) for sensitive ops, OTel tracing, audit events via Epic 8 Story 8.5,
So that team management is complete and audit-safe (FR56 B2B).

**Acceptance Criteria:**

**Given** a team create mutation,
**When** called,
**Then** a new Team row is created with the user as owner
**And** `team.created` audit event fires.

**Given** an invite link with token,
**When** a new user signs up through it,
**Then** they join the team as the invited role
**And** `invite.accepted` audit event fires.

**Given** leave team,
**When** a member calls the mutation,
**Then** they're removed
**And** `team.member_removed` audit event fires.

**Given** transfer ownership,
**When** the owner calls the mutation,
**Then** step-up auth (5-min `requireRecentAuth`) gates the call
**And** ownership transfers to the named member
**And** `team.ownership_transferred` audit event fires.

##### Story 12.8: Individual profile flow (FR56 B2C)

As a B2C user,
I want profile edit (display name, avatar if present, locale preference, password-change entry point),
So that I can manage my account without team concepts (FR56 B2C).

**Acceptance Criteria:**

**Given** `profile.tsx`,
**When** I update display name,
**Then** the tRPC mutation writes `User.display_name` + `user.profile_updated` audit event fires.

**Given** avatar upload,
**When** provided,
**Then** the image is stored (presigned URL flow documented; storage backend fork-decided at 1.0)
**And** `User.avatar_url` is updated.

**Given** locale change,
**When** made,
**Then** Epic 11 Story 11.10 persists `user.locale_preference`.

##### Story 12.9: Accessibility + responsive + 48-combo snapshot matrix

As a substrate maintainer,
I want every Epic 12 screen passing axe-core critical = 0; Playwright keyboard traversal; 18-combo snapshot matrix (360/768/1280 × LTR/RTL × light) at 1.0 per V2 amendment (dark visual deferred to 1.1),
So that scaffolded screens set the a11y + responsive baseline (UX-DR32–44, UX-DR13/14).

**Acceptance Criteria:**

**Given** axe-core runs on every Epic 12 route,
**When** tests execute at pre-merge-slow,
**Then** zero critical violations
**And** fail threshold rejects PR.

**Given** keyboard traversal (Playwright),
**When** simulated across each screen,
**Then** every interactive element is reachable + operable via keyboard only.

**Given** 18 combos (360/768/1280 × LTR/RTL × light),
**When** the nightly snapshot matrix runs (Epic 13 tier),
**Then** all screens render correctly
**And** dark visual verification is deferred to 1.1 per V2 amendment (but dark tokens + class-toggle ship at 1.0).

**Given** touch targets,
**When** inspected,
**Then** all interactive elements are ≥ 44×44 px.

##### Story 12.10: Zustand posture enforcement (F4 consumer)

As a substrate maintainer,
I want Epic 12 screens demonstrating F4 Zustand posture — client ephemeral only; `sessionStorage` default; `localStorage` only with rationale; never persist tenant/billing/auth state,
So that Epic 12 validates the Epic 7 lint rules in practice (F4).

**Acceptance Criteria:**

**Given** any Zustand store in Epic 12 templates,
**When** inspected,
**Then** it uses no persistence for tenant-scoped keys
**And** `sessionStorage` is the default for any persisted slice.

**Given** `localStorage` use,
**When** present,
**Then** a documented rationale comment accompanies the usage
**And** the key is enumerable + auditable.

**Given** Epic 7 Story 7.7's lint rules,
**When** they run against Epic 12 templates,
**Then** zero violations.

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

#### Stories

##### Story 13.1: `pre-merge-fast.yml` (≤3min; deterministic; zero external secrets)

As a substrate maintainer,
I want `.github/workflows/pre-merge-fast.yml` running typecheck + generator idempotency + RLS pglite unit + webhook contract tests + manifest sync — all deterministic, zero external secrets per I6,
So that every PR has a fast, reliable signal (FR29 fast tier).

**Acceptance Criteria:**

**Given** a PR,
**When** `pre-merge-fast.yml` runs,
**Then** it completes in ≤3 min wall-clock (workflow `timeout-minutes: 3`)
**And** no step requires secrets from the environment.

**Given** failed typecheck, generator drift, or manifest drift,
**When** the gate runs,
**Then** the gate fails
**And** PR merge is blocked.

**Given** `pnpm audit --prod` (Epic 4 Story 4.3),
**When** it runs here,
**Then** dependency findings participate in the gate.

##### Story 13.2: `pre-merge-slow.yml` (≤10min; ephemeral-pg DSN)

As a substrate maintainer,
I want `.github/workflows/pre-merge-slow.yml` running RLS testcontainers integration + shape-matrix smoke + migrations within ≤10min, with the ephemeral-pg DSN secret only,
So that heavier integration signal still lands before merge (FR29 slow tier).

**Acceptance Criteria:**

**Given** the workflow,
**When** it runs,
**Then** `timeout-minutes: 10` bounds execution
**And** only `DATABASE_URL_EPHEMERAL` secret is injected.

**Given** RLS integration tests (Epic 6 Story 6.7),
**When** they run here,
**Then** testcontainers Postgres starts + migrations apply + integration tests execute.

**Given** shape-matrix smoke (2-cell at 1.0),
**When** it runs,
**Then** both `{b2b, team}` and `{b2c, user}` configs smoke-test
**And** cross-shape regressions are caught.

##### Story 13.3: `nightly.yml` (≤60min; full shape × tenancy + live-network-quarantined + E2E + pa11y + D4 + RC3)

As a substrate maintainer,
I want `.github/workflows/nightly.yml` running full shape × tenancy combinatoric (2×2=4 cells at 1.0), Paddle sandbox + Google OAuth live-network hits quarantined here, E2E Playwright, pa11y, RLS D4 benchmark, RC3 aggregation in ≤60min,
So that the breadth of integration + research corpus aggregation runs daily without blocking PRs.

**Acceptance Criteria:**

**Given** the workflow,
**When** scheduled,
**Then** it runs nightly on a documented cron
**And** `timeout-minutes: 60` bounds execution.

**Given** the 4-cell shape × tenancy matrix,
**When** the workflow fans out,
**Then** each cell runs isolated
**And** failure in any cell is visible + triaged.

**Given** E2E Playwright + pa11y + RLS D4 + RC3,
**When** they run,
**Then** each produces a structured artefact archived in the workflow run
**And** Epic 14's research corpus consumes them.

##### Story 13.4: `release-gated.yml` (manual; full lifecycle on both shapes; production adjacents)

As a substrate maintainer,
I want `.github/workflows/release-gated.yml` — manual trigger, full `create-keel-app → shape-edit → signup → paid Paddle sandbox subscription → teardown` on both shapes, production adjacents,
So that a release cut exercises the full end-to-end flow (FR30).

**Acceptance Criteria:**

**Given** a manual trigger from GitHub Actions,
**When** the workflow runs,
**Then** both B2B and B2C complete flows execute
**And** success is required for a release cut (documented in release checklist).

**Given** production-adjacent secrets (Paddle prod API key, Resend),
**When** they are injected,
**Then** step-level (not job-level) env bounding per architecture I6.

**Given** a red release-gated result,
**When** it surfaces,
**Then** the release is blocked
**And** Tthew triages with evidence preserved.

##### Story 13.5: `release-please.yml` (release-please PR/tag automation)

As a substrate maintainer,
I want `.github/workflows/release-please.yml` executing release-please-monorepo config from Epic 1 Story 1.14 on every push to main,
So that the rolling Release PR auto-accumulates changelog + bump (FR31 consumer).

**Acceptance Criteria:**

**Given** a push to main,
**When** the workflow runs,
**Then** release-please parses new conventional-commit messages
**And** updates the Release PR accordingly.

**Given** release-please PR merged,
**When** the workflow re-runs,
**Then** a tag is created on main
**And** GitHub Release notes are published.

##### Story 13.6: `path-profile.yml` (FR53 path-based gate-profile router)

As a substrate maintainer,
I want `.github/workflows/path-profile.yml` routing PR checks by path: `packages/**/*` (full pyramid including nightly matrix), `apps/web/features/**/*` (pre-merge-fast + pre-merge-slow only), `docs/**/*` + `_bmad-output/**/*` (pre-commit + pre-merge-fast only),
So that doc edits don't waste 60-min nightly shape × tenancy budget (FR53).

**Acceptance Criteria:**

**Given** a PR touching only `docs/**`,
**When** path-profile routes,
**Then** only pre-commit + pre-merge-fast tiers run
**And** nightly is skipped.

**Given** a PR touching `packages/**`,
**When** path-profile routes,
**Then** the full pyramid runs
**And** the nightly matrix is scheduled for the next night.

**Given** mixed PR touching `docs/` + `packages/`,
**When** path-profile routes,
**Then** the union profile runs (full pyramid).

##### Story 13.7: W2 sync-gate CI wiring (manifest reader + anchor walker + drift detector)

As a substrate maintainer,
I want the runtime tooling from Epic 1 Story 1.9 (`pnpm keel-invariants:check`) wired into `pre-merge-fast.yml` as a required check,
So that FR43 teeth land from day 1 in CI (W2 party-mode amendment).

**Acceptance Criteria:**

**Given** `pre-merge-fast.yml`,
**When** I inspect it,
**Then** a step invokes `pnpm keel-invariants:check`
**And** non-zero exit fails the workflow.

**Given** the drift report,
**When** a failure occurs,
**Then** the structured JSON surfaces in the CI logs
**And** Tthew (or Ralph) sees the specific manifest IDs in drift.

##### Story 13.8: RS5 safe-set bootstrap-validation path-filtered wiring

As a substrate maintainer,
I want a path-filtered job in `pre-merge-slow.yml` triggering bootstrap-validation (Epic 3 Story 3.26) when a PR touches L1/L2 paths (packages/ralph/**, packages/keel-templates/**, .ralph/PROMPT_*.md, packages/keel-invariants/src/schemas/{halt,plan}.schema.json, packages/devbox/ralph-version.json),
So that Ralph self-modification failures surface at pre-merge-slow with `RALPH_STAGE_REGRESSION` (RS5, ≤8min budget).

**Acceptance Criteria:**

**Given** a PR touches any listed path,
**When** `pre-merge-slow.yml` routes,
**Then** the bootstrap-validation job is triggered
**And** runs within ≤8 min.

**Given** validation passes,
**When** checks complete,
**Then** the PR is mergeable (auto-merge on pass per Epic 3 Story 3.25).

**Given** validation fails,
**When** the job reports,
**Then** the PR is blocked
**And** Ralph writes `.ralph/halt` with `RALPH_STAGE_REGRESSION` for Tthew review.

##### Story 13.9: `ralph-stage-upgrade.yml` workflow

As a substrate maintainer,
I want a dedicated `.github/workflows/ralph-stage-upgrade.yml` that — on `ralph-stage-upgrade:`-prefixed commits — re-installs the snapshot in an ephemeral devbox and re-runs the smoke iteration from the NEW stage (Epic 3 Story 3.27),
So that stage upgrades are fully validated before merge.

**Acceptance Criteria:**

**Given** a PR with `ralph-stage-upgrade:` commit prefix,
**When** the workflow triggers,
**Then** it spins up an ephemeral devbox
**And** installs the new ralph-version.json pin
**And** runs the Story 3.26 smoke iteration from the fresh stage.

**Given** validation passes,
**When** the workflow completes,
**Then** the PR is mergeable.

**Given** validation fails,
**When** the workflow reports,
**Then** the PR is blocked and Tthew reviews.

##### Story 13.10: Design-system CI checks (axe-core, Lighthouse, pa11y)

As a substrate maintainer,
I want design-system checks wired in CI: axe-core per screen at pre-merge-fast; Playwright snapshot matrix at nightly; Lighthouse CI per PR (a11y ≥ 95); pa11y nightly on release-gated,
So that a11y + visual regressions are caught (UX-DR52–55).

**Acceptance Criteria:**

**Given** pre-merge-fast,
**When** axe-core runs on every Epic 12 route,
**Then** zero critical violations fails the gate.

**Given** Lighthouse CI,
**When** it runs per PR,
**Then** a11y score ≥ 95 is required.

**Given** nightly,
**When** pa11y runs on release-gated flows,
**Then** findings archive to the workflow artefacts.

##### Story 13.11: 18-combo screenshot matrix at nightly (V2 scope adjustment)

As a substrate maintainer,
I want the nightly Playwright snapshot matrix running 18 combos (360/768/1280 × LTR/RTL × light only at 1.0; dark VISUAL verification deferred to 1.1 per V2 amendment),
So that visual regression coverage ships at 1.0 within budget (V2).

**Acceptance Criteria:**

**Given** the nightly workflow,
**When** the snapshot matrix runs,
**Then** 18 combos are exercised per Epic 12 screen
**And** failures archive screenshots for Tthew review.

**Given** RTL combos,
**When** they run,
**Then** logical-CSS discipline (Epic 11 Story 11.8) is verified visually.

**Given** dark combos,
**When** considered for 1.0,
**Then** dark tokens + class-toggle still ship at 1.0 (Epic 1)
**But** dark visual verification is explicitly deferred to 1.1 (documented in `docs/invariants/ux-matrix-scope.md`).

##### Story 13.12: M4 Nightly UX-matrix budget envelope (sharding + axis-collapse)

As a substrate maintainer,
I want an explicit budget-envelope design for the nightly UX matrix: sharding strategy, per-screen time budget, axis-collapse policy (which axes degrade first when budget pressure hits),
So that Sprint-3-budget-bust risk is mitigated upfront (M4 party-mode amendment).

**Acceptance Criteria:**

**Given** `docs/invariants/ux-matrix-scope.md`,
**When** I read it,
**Then** sharding strategy is documented (e.g., by screen, by viewport, or by locale)
**And** per-screen time budget is explicit (e.g., 30s/screen).

**Given** budget pressure,
**When** the envelope nears exceeding,
**Then** the axis-collapse policy kicks in: candidate = drop shape × tenancy duplication for pure-visual checks; keep it for interaction flows
**And** the policy is documented with rationale.

**Given** actual usage,
**When** the matrix runs nightly,
**Then** it stays within the overall 60-min nightly budget
**And** exceedances trigger the NFR28c monthly-review amendment path.

##### Story 13.13: NFR28b empirical budget reframe + NFR28c monthly review

As a substrate maintainer,
I want `docs/invariants/ci-budgets.md` documenting modelled-vs-empirical budget provenance at 1.0 (M9) with an amendment-PR template for M10 (or first 2-week real-traffic window) to re-baseline against p95 (NFR28b) and a monthly review process (NFR28c),
So that CI budgets are empirically honest over time (NFR28b, NFR28c).

**Acceptance Criteria:**

**Given** `docs/invariants/ci-budgets.md`,
**When** I read it,
**Then** every tier's budget is labelled "modelled (M9)" or "empirical (M10+)"
**And** the amendment PR template is included.

**Given** workflow comments in each `.github/workflows/*.yml`,
**When** I inspect them,
**Then** each `timeout-minutes:` is annotated with "modelled" or "empirical <date>".

**Given** monthly review cadence,
**When** p95 exceeds budget for 2 consecutive months,
**Then** a mandatory amendment PR is opened
**And** the re-baseline or tier-split is documented.

**Given** the formula `max(stated-target, ceil(p95 × 1.25))`,
**When** a re-baseline happens,
**Then** the formula is applied
**And** the new budget is annotated.

##### Story 13.14: `.github/CODEOWNERS` + PR templates

As a substrate maintainer,
I want minimum `.github/CODEOWNERS` + a PR template at `.github/pull_request_template.md`,
So that future contributors have a baseline structure even though N=1 at 1.0.

**Acceptance Criteria:**

**Given** `.github/CODEOWNERS`,
**When** I inspect it,
**Then** Tthew owns all paths at 1.0
**And** the file is documented as "extend when contributor count warrants it."

**Given** `.github/pull_request_template.md`,
**When** I inspect it,
**Then** sections for Summary / Risk / Test plan / Security evidence reference exist
**And** agent-authored PRs can fill it via a documented convention.

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

#### Stories

##### Story 14.1: RC1 corpus directory layout + README + test-ids ledger

As a substrate maintainer,
I want `docs/research/` with `sprint-logs/`, `checkpoints/`, `tripwire/`, `README.md`, `test-ids.md` (append-only), and `corpus.jsonl` (regenerated nightly),
So that the research corpus has a canonical filesystem layout from day 1 (RC1).

**Acceptance Criteria:**

**Given** `docs/research/`,
**When** I inspect it,
**Then** subdirectories `sprint-logs/`, `checkpoints/`, `tripwire/` exist with `.gitkeep`
**And** `README.md` documents the layout, schemas, aggregation, citation conventions.

**Given** `test-ids.md`,
**When** I inspect it,
**Then** it is append-only (enforced via Story 3.23 lint)
**And** every test ID (`T-0001` onward) maps to a human-readable title + current path.

**Given** `corpus.jsonl`,
**When** I inspect it,
**Then** it is git-tracked but regenerated nightly by RC3 (Story 14.6).

##### Story 14.2: RC2 typed schemas (sprint-log, checkpoint, tripwire)

As a substrate maintainer,
I want typed JSON schemas at `packages/keel-invariants/src/schemas/` for sprint-log, checkpoint, tripwire with `$schema` version headers,
So that every research artefact validates against a canonical shape (RC2).

**Acceptance Criteria:**

**Given** `sprint-log.schema.json`,
**When** I inspect it,
**Then** it defines `{month, slice_id, model_version, keel_ttg_seconds, blank_ttg_seconds, keel_tokens_total, blank_tokens_total, keel_context_exhausted_count, blank_context_exhausted_count, keel_rework_rate, blank_rework_rate, delta_percent, notes}`.

**Given** `checkpoint.schema.json`,
**When** I inspect it,
**Then** it defines `{quarter, date, decision_enum: continue|pause_and_ship|pivot|archive, evidence_paths[], next_evaluation_date, rationale}`.

**Given** `tripwire.schema.json`,
**When** I inspect it,
**Then** it defines `{month, verdict_enum: pass|warn|breach, source_sprint_log_id, consecutive_breach_count, pivot_recommended, raw_datapoints[]}`.

**Given** schemas are invariants,
**When** Story 1.8 tracks them,
**Then** each has a registered invariant ID
**And** version bumps follow the `$schema` versioning rule.

##### Story 14.3: M3 Flake-log schema freeze

As a substrate maintainer,
I want `packages/keel-invariants/src/schemas/flake-log.schema.json` frozen at 1.0 with `{test_id, iteration_id, outcome: pass|fail|skip, duration_ms, attempt_number, timestamp}` — jointly owned with Epic 13 Vitest reporter + workflow emitters,
So that flake data has a single stable schema from day 1 (M3 party-mode amendment).

**Acceptance Criteria:**

**Given** `flake-log.schema.json`,
**When** I inspect it,
**Then** the 6 fields are present
**And** `outcome` enum is strictly `pass | fail | skip`.

**Given** Epic 13's Vitest reporter emits records,
**When** they're validated,
**Then** every record conforms to this schema
**And** schema drift is caught by Story 1.9.

##### Story 14.4: R5 Headless Ralph `--no-tui`

As a substrate maintainer,
I want `ralph.py --no-tui` suppressing Textual UI, writing structured JSON to `.ralph/logs/<iter-id>/`, concluding-summary single-line JSON to stdout, and a known exit code signalling outcome,
So that monthly blank-starter-sprint harness, scheduled GH Actions, and RC3 aggregation runs can be shell-scripted (R5).

**Acceptance Criteria:**

**Given** `ralph.py --no-tui`,
**When** I run it,
**Then** no Textual UI renders
**And** iteration logs still write to `.ralph/logs/<iter-id>/iteration.jsonl`
**And** a final summary JSON line is emitted to stdout matching `sprint-log.schema.json` fields.

**Given** a completed headless run,
**When** I inspect the exit code,
**Then** known codes signal outcome: 0 (EPIC_DONE), 1 (generic halt), 2 (SECURITY_CRITICAL), 3 (BUDGET_EXHAUSTED), 4 (RALPH_STAGE_REGRESSION).

**Given** the `docs/research/sprint-logs/<YYYY-MM>.json` output,
**When** a monthly sprint runs,
**Then** the file is written on completion
**And** schema-validates per Story 14.2.

##### Story 14.5: R6 Flake measurement layer (Vitest reporter + workflow hook)

As a substrate maintainer,
I want `packages/keel-invariants/src/flake-reporter.ts` as a Vitest custom reporter emitting per-test JSON records to `.ralph/flake-log/YYYY-MM/<date>.jsonl` (schema per Story 14.3), with Epic 13 GH Actions workflows emitting the same shape — measurement at 1.0; enforcement (quarantine policy, pass-rate thresholds, PR gates) deferred until ≥500 iterations accrue,
So that flake data exists from day 1 without premature policy overhead (R6).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/src/flake-reporter.ts`,
**When** Vitest runs with the reporter registered,
**Then** per-test records emit matching `flake-log.schema.json`
**And** records stream to `.ralph/flake-log/YYYY-MM/<date>.jsonl`.

**Given** GH Actions workflows (Epic 13),
**When** they run Vitest,
**Then** the reporter is active
**And** records upload as workflow artefacts.

**Given** 1.0 enforcement mode,
**When** a test is flaky (e.g., pass-rate < 99%),
**Then** no action is taken automatically
**And** the data accumulates for M10 baseline.

**Given** M10 (or first ≥500-iteration breach),
**When** enforcement is activated,
**Then** a dedicated 1.x epic flips thresholds
**And** this story does NOT ship enforcement.

##### Story 14.6: RC3 Aggregation tooling — `pnpm research:aggregate`

As a substrate maintainer,
I want `packages/keel-invariants/src/research-aggregate.ts` + `pnpm research:aggregate` CLI reading `docs/research/**/*.json`, validating against RC2 schemas, emitting flattened `docs/research/corpus.jsonl` — idempotent + deterministic — running as nightly CI step,
So that the corpus is a consumable single-file feed (RC3).

**Acceptance Criteria:**

**Given** `pnpm research:aggregate`,
**When** I run it,
**Then** all JSON artefacts in `docs/research/**/*.json` are validated per RC2 schemas
**And** a flattened `corpus.jsonl` is emitted.

**Given** deterministic output,
**When** I run twice,
**Then** `git diff docs/research/corpus.jsonl` is empty
**And** canonical-form discipline (same as Epic 5 G4) holds.

**Given** the nightly workflow,
**When** it runs,
**Then** `pnpm research:aggregate` runs
**And** a stale `corpus.jsonl` (differs from regen output) triggers a pre-merge-fast warning (not fail).

##### Story 14.7: C4 Test-ID stability convention + ESLint rule

As a substrate maintainer,
I want every test using explicit `T-\d{4}` IDs in the title (e.g., `test('T-0042: inviteWithVerification_creates_token', ...)`) + IDs allocated from an append-only counter in `docs/research/test-ids.md` + ESLint rule `keel/stable-test-id` enforcing the pattern at pre-commit,
So that test identity is stable even when test descriptions change (C4).

**Acceptance Criteria:**

**Given** `packages/keel-invariants/eslint-rules/stable-test-id.cjs`,
**When** the rule runs,
**Then** a `test('<description>')` without a `T-\d{4}` prefix is flagged
**And** the commit is rejected.

**Given** `docs/research/test-ids.md`,
**When** I inspect it,
**Then** IDs are append-only
**And** each entry maps `T-NNNN` → `<path>` + `<current description>`
**And** IDs are never reused.

**Given** Story 3.11's Required-tests manifest,
**When** it stores test IDs,
**Then** only `T-\d{4}` prefixes are used
**And** human descriptions change freely.

##### Story 14.8: Monthly blank-starter-sprint harness

As Tthew,
I want a monthly blank-starter-sprint harness: 2-hour timebox; same vertical slice built on vanilla starter (Next.js + Supabase + Vercel) AND on Keel + Invariant Pack; measured tokens, context exhaustion, rework, time-to-green; acceptance criteria pre-registered at `docs/absorption-tripwire/vertical-slice-acceptance.md` (already scaffolded); committed before first sprint,
So that delta measurement is disciplined, not anecdotal (vertical-slice-acceptance).

**Acceptance Criteria:**

**Given** the harness scripts,
**When** invoked,
**Then** a 2-hour timeboxed run executes against both environments
**And** structured telemetry is captured per `sprint-log.schema.json`.

**Given** the amendment ceremony,
**When** acceptance criteria need updating,
**Then** a PR with rationale + 24h cooling-off is required
**And** post-hoc editing to protect the project is structurally resisted.

**Given** the falsification threshold,
**When** blank-starter TTG falls within 20% of Keel TTG for two consecutive months,
**Then** Epic 15b's Invariant Pack pivot is triggered
**And** the decision is recorded in `docs/research/checkpoints/<quarter>.json`.

##### Story 14.9: V4 Skip-trigger tripwire + `schedule.md` + skip-detection

As Tthew,
I want `docs/research/sprint-logs/schedule.md` pre-registering monthly sprint dates (first sprint ~M1; monthly cadence) plus a skip-detection check at pre-merge-fast — two consecutive skipped sprints = absorption by default → pivot to Invariant Pack within 30 days; three consecutive skipped sprints fails the build,
So that unused measurement is worse than no measurement (V4 party-mode amendment; PRD clarification raised).

**Acceptance Criteria:**

**Given** `docs/research/sprint-logs/schedule.md`,
**When** I inspect it,
**Then** monthly sprint dates are pre-registered from M1 onward
**And** each row has `{scheduled_date, completed_date?, verdict?}`.

**Given** the pre-merge-fast check,
**When** it runs,
**Then** it compares `schedule.md` against `sprint-logs/*.json`
**And** emits a warning if 2 months past due; fails the build if 3 months.

**Given** a documented absorption verdict,
**When** Tthew records it in `docs/research/checkpoints/<quarter>.md`,
**Then** the skip-detection honours the decision
**And** the Invariant Pack pivot path activates (Epic 15b).

##### Story 14.10: FR33 M4 Checkpoint markdown template + schema consumer

As a substrate maintainer,
I want a committed template for quarterly M4 checkpoints at `docs/research/checkpoints/<YYYY-Q#>.md` with matching JSON per `checkpoint.schema.json` (Story 14.2), governance trigger (recurring quarterly post-1.0),
So that governance + research artefact are captured together (FR33).

**Acceptance Criteria:**

**Given** a quarterly template,
**When** a checkpoint is written,
**Then** matching `.md` and `.json` files land in `docs/research/checkpoints/`
**And** JSON validates per schema.

**Given** the four decision types (`continue | pause_and_ship | pivot | archive`),
**When** a checkpoint is written,
**Then** exactly one is selected
**And** evidence paths back the decision.

**Given** `next_evaluation_date` is required,
**When** the current quarter's checkpoint is written,
**Then** the next review is scheduled 3 months later
**And** it appears in `docs/research/sprint-logs/schedule.md`.

##### Story 14.11: NFR29a per-major prompt-set pinning + NFR30 breaking-delta catalogue

As a substrate maintainer,
I want `docs/invariants/model-pinning.md` documenting NFR29a (Ralph prompts pinned per major Keel version; minor versions inherit unchanged; majors may diverge with recorded delta) + NFR30 breaking-delta catalogue (tested Claude model, Claude Code CLI version, BMad version, Ralph version per major),
So that model evolution is tracked as research corpus metadata (NFR29a, NFR30).

**Acceptance Criteria:**

**Given** `docs/invariants/model-pinning.md`,
**When** I read it,
**Then** the prompt-pinning rule is pinned
**And** the breaking-delta catalogue has one row per Keel major.

**Given** a minor Keel version cut,
**When** release notes are generated,
**Then** they confirm "prompts unchanged; pinned to <generation>".

**Given** a major Keel version cut,
**When** prompts diverge,
**Then** the delta is recorded in release notes + `model-pinning.md`
**And** NFR30 catalogue is updated with the new row.

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

#### Stories

##### Story 15a.1: `create-keel-app/` package + non-interactive CLI

As Tthew (mid-build) and later forkers,
I want `create-keel-app/` at the repo root (published to npm as `create-keel-app` for `pnpm dlx`) with `src/cli.ts` — non-interactive end-to-end; no prompts; specific exit codes — completing in < 2 min wall-clock (excluding devbox cold-start),
So that fork scaffolding is fast and fully scriptable (FR47, NFR34).

**Acceptance Criteria:**

**Given** `create-keel-app/`,
**When** I inspect it,
**Then** `package.json` is configured for npm publish (bin = `src/cli.js`; name = `create-keel-app`)
**And** `README.md` documents usage.

**Given** `pnpm dlx create-keel-app <name>`,
**When** I run it,
**Then** it reads zero stdin
**And** completes in < 2 min wall-clock on baseline hardware
**And** returns specific exit codes on failure: 2 (Docker missing), 3 (network failure), 4 (dir conflict), 5 (`pnpm install` failure).

**Given** success,
**When** the command completes,
**Then** a plain-text summary prints
**And** the new fork is at `<name>/` with a first commit `chore: bootstrap from keel@<ref>`.

##### Story 15a.2: `src/strip-planning.ts` fork-scaffolding state wipe (FR51)

As Tthew,
I want `src/strip-planning.ts` that strips `_bmad-output/` → `docs/archive/keel-<ref>-planning/`, empties `.ralph/@plan.md`, seeds `.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md` from `packages/keel-templates/`,
So that forks start with a clean slate (FR51).

**Acceptance Criteria:**

**Given** a fresh fork,
**When** `strip-planning.ts` runs,
**Then** `_bmad-output/` contents move to `docs/archive/keel-<ref>-planning/`
**And** `.ralph/@plan.md` is emptied to a minimal skeleton conforming to `plan.schema.json` (Epic 3 Story 3.8).

**Given** `packages/keel-templates/PROMPT_*.template.md`,
**When** seeding runs,
**Then** substitution per Story 3.3 placeholder convention is applied
**And** `.ralph/PROMPT_build.md` + `.ralph/PROMPT_plan.md` materialise.

**Given** the archive convention,
**When** I inspect `docs/archive/keel-<ref>-planning/`,
**Then** the ref used (tag/branch/SHA) is preserved in the directory name.

##### Story 15a.3: Mid-build `--from=<branch|tag|sha>` flag (Tthew test-fork mode)

As Tthew mid-build,
I want `pnpm dlx create-keel-app <name> --from=<branch|tag|sha>` that clones from any ref (not just the latest substrate tag),
So that I can spin up test forks from any in-progress branch without manual git-clone + strip (FR47 extension).

**Acceptance Criteria:**

**Given** `--from=main`,
**When** I run the command,
**Then** the CLI clones `main` (not the latest tag)
**And** strip-planning still runs.

**Given** `--from=<sha>`,
**When** I run the command,
**Then** the CLI clones the exact commit
**And** the archive directory name reflects the SHA.

**Given** no `--from=`,
**When** I run the command,
**Then** the CLI clones the latest substrate tag (default behaviour).

##### Story 15a.4: `packages/keel-templates/` consumer seeding

As a substrate maintainer,
I want `create-keel-app` to consume `packages/keel-templates/` for `.ralph/PROMPT_*.md` seeding — the templates authored in Epic 3 Story 3.3 with substitutions materialised here,
So that every fresh fork's Ralph prompts are generated from the substrate's pinned templates (NFR29a consumer).

**Acceptance Criteria:**

**Given** Epic 3 Story 3.3's templates,
**When** `create-keel-app` reads them,
**Then** substitution variables (`{{ fork.name }}`, `{{ fork.tenancy }}`) resolve from CLI input
**And** the emitted `.ralph/PROMPT_*.md` file has NO unresolved placeholders.

**Given** the content-hash pinning in `packages/devbox/ralph-version.json`,
**When** `create-keel-app` materialises templates,
**Then** the fork's `ralph-version.json` inherits the substrate's pinned hash
**And** stage identity is preserved.

##### Story 15a.5: Integration test (pre-merge-slow smoke)

As a substrate maintainer,
I want an integration test at pre-merge-slow exercising `pnpm dlx create-keel-app /tmp/test-fork-<uuid> --from=HEAD → cd /tmp/test-fork-<uuid> → pnpm devbox:start → pnpm test` end-to-end green on both shapes,
So that `create-keel-app` regressions are caught before they ship (FR47 verification).

**Acceptance Criteria:**

**Given** a PR touching `create-keel-app/`,
**When** pre-merge-slow runs,
**Then** the integration test fires
**And** both `{b2b, team}` and `{b2c, user}` scaffolds complete green.

**Given** the test uses ephemeral temp dir,
**When** it completes,
**Then** the temp dir is cleaned up
**And** no state bleeds into the CI workspace.

**Given** the test is part of Epic 13's matrix,
**When** failure occurs,
**Then** the PR is blocked
**And** the failure includes which shape + which step failed.

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
