# Keel

An opinionated SaaS substrate for one person shipping products through agentic workflows (BMad planning, the Ralph loop, Claude Code).

> Your agents are only as good as the decisions you've already frozen for them.

Keel is the substrate those agents execute against. The stack is hardwired in committed code. Tenant isolation, import boundaries, and quality gates are enforced at build time, not left as convention. An agent iterating on a Keel fork re-litigates nothing.

## Status

Pre-1.0. Planning artefacts complete — [PRD](_bmad-output/planning-artifacts/prd.md), [Architecture](_bmad-output/planning-artifacts/architecture.md), [UX Spec](_bmad-output/planning-artifacts/ux-design-specification.md), [Epics & Stories](_bmad-output/planning-artifacts/epics.md), [PRFAQ](_bmad-output/planning-artifacts/prfaq-ralph-bmad.md). Substrate implementation in progress across 16 epics; target 1.0 cut on a 28-day milestone plan (M0 → M9). N=1 project — Tthew is the sole user; peer-audience framing is hypothetical and does not drive scope.

## What's hardwired

Single implementation per axis. No wizard, no runtime toggles, no adapter surfaces at 1.0. Second implementations enter post-1.0 on a consumption-driven basis.

| Axis                | Choice                                                                    |
| ------------------- | ------------------------------------------------------------------------- |
| Framework           | TanStack Start on Vite                                                    |
| Language            | TypeScript end-to-end (pnpm workspaces + Turborepo)                       |
| Database            | Postgres + Prisma with Row-Level Security                                 |
| Contracts           | tRPC + Zod                                                                |
| Auth                | better-auth (email/password + Google OAuth, DB-backed sessions)           |
| Billing             | Paddle (Merchant of Record) — B2B team-seats or B2C individual            |
| Jobs                | pg-boss (in-process, same Postgres)                                       |
| Email               | Resend with baseline templates                                            |
| UI                  | Tailwind v4 + shadcn-vendored components                                  |
| Observability       | OpenTelemetry traces + append-only audit log                              |
| Release             | prek + commitlint + release-please                                        |

## Shapes (1.0)

Per-fork configuration lives in a typed `keel.config.ts` with four fields: `shape`, `tenancy`, `projectIdentity`, `otelExporter`. Shape selection is a one-line edit; a pure deterministic generator emits the matching RLS tenancy template and Paddle billing preset.

- `shape: "b2b"` + `tenancy: "team"` — team-scoped RLS, team-seats billing (default)
- `shape: "b2c"` + `tenancy: "user"` — user-scoped RLS, individual-subscription billing

Marketplace (Stripe Connect) and API-first (Stripe standard, quota-based) shapes are deferred to 1.1 and 1.2.

## What's enforced

- **Day-1 RLS** on every tenant-scoped table, generated from the shape's tenancy template. Physical prevention, not a middleware wrapper.
- **Import boundaries** via ESLint `no-restricted-imports` + TypeScript project references. Compile-time.
- **Decomposed CI pyramid** — pre-commit (≤10s) / pre-merge-fast (≤3min, deterministic) / pre-merge-slow (≤10min, ephemeral Postgres) / nightly (≤60min, live-network) / release-gated (manual clone → signup → tenant → paid Paddle sandbox subscription → teardown).
- **Three-layer invariants** — machine-enforced (`packages/keel-invariants/`), agent-readable (`INVARIANTS.md`), human-readable docs. Sync enforced by a pre-merge content-hash gate.
- **Agent loop contracts** — Ralph's orient → execute → commit → gate → push → exit spine, acceptance-driven backpressure (`Required tests:` schema, append-only within a task), pre-push CI gate, pinned halt schema.
- **Per-iteration security evidence** — secret scan, dependency audit, SAST, prompt-injection scan; artefacts persisted to `.ralph/logs/<iteration-id>/security-evidence.json`.

Gates are non-toggle-able at the config layer. Removing them requires forking the substrate.

## Execution environment

All agent execution runs inside a Docker devbox (absorbed from [cc-devbox](https://github.com/tthew/cc-devbox)) — Ubuntu 24.04, non-root user, fail-closed DNS whitelist with IPv4/IPv6 parity, `noexec,nosuid` tmpfs, named-volume auth persistence. The sandbox is what makes `--dangerously-skip-permissions` safe. Host surface is `pnpm <subcommand>`; users never invoke Docker, docker-compose, or SSH directly.

## Layout

```
apps/
  web/                              TanStack Start — sole 1.0 app
packages/
  db/ contracts/ config/ core/      Domain layer
  billing/ email/ jobs/ flags/      Platform services
  audit/ ui/                        Cross-cutting
  keel-invariants/                  Machine-enforced rules (ESLint, TS, hooks)
  keel-generator/                   Pure expand(config) → Rule[] generator
  keel-templates/                   Per-fork scaffolding seeds
  devbox/                           Docker image + lifecycle scripts
  ralph/                            Agent-loop harness (Python Textual TUI)
_bmad-output/
  planning-artifacts/               PRD, architecture, UX, epics, PRFAQ
  implementation-artifacts/         Stories, sprint plans
.ralph/                             Loop state (gitignored except @plan.md)
.claude/                            Skills, settings, hooks
```

## Getting started

Keel 1.0 has not shipped yet. Once it does, a new fork will start with:

```bash
pnpm dlx create-keel-app <project-name>   # clone tagged release + first install
# edit keel.config.ts → shape / tenancy / projectIdentity / otelExporter
pnpm devbox:build && pnpm devbox:start    # build + start the sandbox
pnpm claude && pnpm gh:auth               # one-time OAuth inside the devbox
pnpm ralph:build                          # start the loop against .ralph/@plan.md
```

Until 1.0, this repository is the planning + implementation workspace for Keel itself. See [CLAUDE.md](./CLAUDE.md) and [AGENTS.md](./AGENTS.md) for agent-facing conventions, and [docs/ralph.md](./docs/ralph.md) for the Ralph TUI reference.

## Thesis, in one paragraph

Three principles, taken together: **YAGNI** on features you don't need, **DRY** on decisions you'd otherwise re-make every project, and a deliberate **no to Not Invented Here**. Nothing in the stack is novel — Postgres, Prisma, Tailwind, Paddle are boring on purpose. What's new is that every cross-component decision is already made, documented, and enforced at the layer where it actually bites (the database, the compiler, the commit hook). If the next frontier model can absorb that coordination without a curated substrate, Keel pivots to an **Invariant Pack** — a versioned, LLM-consumable contract manifest — and ships to npm within 30 days. The monthly [absorption tripwire](_bmad-output/planning-artifacts/prd.md) is the falsification test.

## License

MIT.
