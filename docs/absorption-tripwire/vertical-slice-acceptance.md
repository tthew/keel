# Absorption-Tripwire Vertical-Slice Acceptance Criteria

**Status:** Scaffold — awaiting first-run definition before month-1 sprint
**Owner:** Tthew (N=1 per § Project Classification → Persona Model)
**Covenant:** Edits require a PR reviewed against the prior committed entry, with rationale recorded in the changelog at the bottom of this file. No casual in-place edits. The covenant exists to close the measurement-integrity gap where a self-administered kill criterion would otherwise drift to protect the project when the tripwire fires.

---

## Why This File Exists

The Keel PRD (`_bmad-output/planning-artifacts/prd.md`, § Success Criteria → Business Success → Absorption-risk tripwire) commits to a monthly blank-starter-sprint as the falsification instrument for the substrate-as-category thesis. The threshold is numeric: **if blank-starter time-to-green comes within 20% of Keel's time-to-green for two consecutive months, the substrate layer is absorbed and Keel pivots to the Invariant Pack.**

A numeric threshold without a pre-registered definition of "green" is compromised by the measurer. Whoever runs the sprint (here: Tthew) can, consciously or otherwise, drift the acceptance criteria toward whatever favours the preferred outcome. This file exists to pin the definition before the first sprint runs, with a covenant that prevents post-hoc drift.

---

## TODO: Vertical-Slice Definition

**Before month-1 runs**, pin the following in this section. Commit this file as a PR; do not edit in-place once the first sprint has run.

### Slice Scope

<!-- TODO: Define the vertical slice. Suggested shape: the smallest end-to-end user-visible path that exercises every stack axis hardwired in Keel 1.0 (auth, tenancy, billing, jobs, email, observability, UI). -->

**Candidate:** User signup → tenant formation → first billable-event recorded against a Paddle sandbox subscription → audit log entry verified → email sent via Resend.

### Acceptance Binary

A sprint run is **green** when:

<!-- TODO: Enumerate the exact machine-verifiable conditions. These must be binary (pass/fail), not judgment calls. -->

Candidate binary checklist:
- [ ] User can sign up via Google OAuth or email/password (both paths tested)
- [ ] Tenant is formed with matching RLS policy (verified via `pnpm rls:explain`)
- [ ] Paddle sandbox subscription created and webhook processed idempotently (signature verified, lifecycle event persisted)
- [ ] Audit log entry exists for the billable event (append-only, queryable)
- [ ] Verification email sent via Resend (logged, Resend API 2xx)
- [ ] pg-boss job completed without dead-letter
- [ ] OpenTelemetry trace emitted end-to-end
- [ ] No test regressions in the hardwired invariant suite

### Measurement Rules

<!-- TODO: Pin the aggregation method for each of the four metrics. -->

**Time-to-green (wall-clock):** stopwatch from `pnpm dlx create-keel-app <name>` (or `pnpm create next-app <name>` for blank-starter) until all binary checklist items pass. Sprint budget: 2 hours max per side.

**Token count:** sum of input + output tokens across all LLM calls per side. Extract from Claude Code session logs. If the blank-starter side uses a different model or tooling, normalise by stated-per-million-input-token cost rather than raw count, and log both.

**Context-window exhaustion:** count of iterations that exited early due to context utilisation >= 80% (per NFR4a smart zone). Include context-resume/restart-count if multiple sessions needed.

**Rework rate:** count of commits on the sprint branch that were reverted or superseded within the sprint window. Divide by total commits. Report as a percentage.

### Aggregation for the 20% Threshold

<!-- TODO: Pin exactly which metric triggers the 20% threshold and how conflicting signals are resolved. -->

**Primary metric:** wall-clock time-to-green — the externally-bound clock that cannot be inflated by task-granularity gaming (see § Success Criteria → User Success → TTGNA precedent).

**Conflict resolution:** if tokens / context-exhaustion / rework-rate point the opposite direction from wall-clock, note the divergence in the sprint log and escalate to the next M4 quarterly checkpoint for arbitration. Single-metric reads do not fire the tripwire; a full four-metric agreement is required for unambiguous falsification.

---

## First-Run Date

<!-- TODO: Record the first month the sprint runs. Once logged, this is immutable. -->

**First sprint:** TBD (runs once the pre-registration file is committed pre-1.0-cut)

---

## Sprint Log

Each monthly sprint commits an entry to `docs/absorption-tripwire/sprints/YYYY-MM.md` with:
- Model generation tested
- Start / end timestamps for both sides
- Binary checklist results
- Token / context / rework measurements
- Wall-clock time-to-green per side
- Threshold calculation: `blank_starter_time / keel_time` as a percentage
- Sprint-specific observations (drift signals, unexpected blockers, model-behaviour notes)

The sprint log is the research-project output per § Project Classification → Project Posture. It persists as evidence of the agent-capability curve independent of Keel's substrate fate; even if the tripwire never fires, the log is a quarterly-observable research artefact.

---

## Amendment Ceremony

Per the covenant at the top of this file, amendments require:

1. **PR** modifying this file with a clear description of what is being changed and why.
2. **Review against prior committed entry** — the PR reviewer (in an N=1 project, this is a self-review ritual enforced by the 24-hour cooling-off rule) confirms the change is not being made in response to a just-fired tripwire signal.
3. **Changelog entry** appended to the table below, recording the amendment date, the change, and the rationale.
4. **24-hour cooling-off period** between PR open and merge, specifically to prevent amendment-under-pressure.

Amendments that fail the cooling-off rule, or that are proposed in the same calendar week as a tripwire-adjacent signal, must wait until the next M4 quarterly checkpoint for escalated review.

### Changelog

| Date | Amendment | Rationale |
|---|---|---|
| 2026-04-18 | File scaffolded; TODO blocks pending first-run definition | Pre-registration commitment per § Success Criteria → Business Success absorption-tripwire bullet and Top 3 Improvement #1 from 2026-04-18 validation report |
