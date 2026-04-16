# Ralph Planning Mode — ralph-bmad

**Study BMad specs. Compare against the repo state. Update IMPLEMENTATION_PLAN.md. NO IMPLEMENTATION.**

## Quick Reference

**Files:** IP=IMPLEMENTATION_PLAN.md | C.md=CLAUDE.md | A.md=AGENTS.md | SS=sprint-status.yaml
**Paths:** $EPICS=\_bmad-output/planning-artifacts/epics/ | $ARTIFACTS=\_bmad-output/implementation-artifacts/
**Output:** Update IP with prioritized gaps and tasks

---

## Orient Phase (0a-0d)

0a. Study `_bmad-output/planning-artifacts/epics/` to understand epics and stories (may be empty — project is still in planning).
0b. Study @IMPLEMENTATION_PLAN.md (if present) to understand current state.
0c. Run `/bmad-help` or read `_bmad/_config/bmad-help.csv` to identify the current BMad phase and the next required gate (PRD, Architecture, Epics & Stories, Implementation Readiness, Sprint Planning, Create Story, Dev Story).
0d. Study source dirs (anything outside `_bmad/`, `_bmad-output/`, `.claude/`, `docs/`) — if any — to understand what's implemented.
0e. Study @AGENTS.md for operational context.

## Analysis Phase (1-2)

1. Compare BMad specs (planning-artifacts) against the repo using subagents. Identify:
   - Missing required artifacts per current phase (e.g., no PRD yet in 2-planning)
   - Stories marked "in-progress" or "pending" in sprint-status.yaml (if present)
   - Gaps between acceptance criteria and actual implementation (once code exists)
   - TODOs, placeholders, minimal implementations
   - Skipped/flaky tests, inconsistent patterns

2. Update @IMPLEMENTATION_PLAN.md with prioritized findings:
   - Current BMad phase and next required gate
   - Epic/Story context (if any)
   - Tasks derived from acceptance criteria
   - Discovered gaps and blockers
   - Notes for future Ralphs

## IMPORTANT Constraints

⊗ **Plan only. Do NOT implement. Do NOT commit code changes.**
⊗ **Confirm functionality is missing before documenting** — don't assume.
⊗ **Search before concluding** — use subagents to verify gaps exist.

---

## IP Format for Planning Mode

```markdown
# Implementation Plan

## Context

- **Phase:** <BMad phase, e.g. "2-planning">
- **Next Required Gate:** <skill code from bmad-help.csv, e.g. "bmad-create-prd">
- **Epic:** Epic {N} - {Title} or "none"
- **Epic Branch:** feat/epic-{N}-{name} or current branch
- **Story:** STORY-ID or "none"
- **Story File:** path or "n/a"

## NOW

- [ ] [Highest priority task with file:line if applicable]

## NEXT

- [ ] Task 2 (derived from acceptance criteria or required gate)
- [ ] Task 3
- [ ] Gap: [description of missing functionality]

## BLOCKED

- [ ] [Issue] - REASON: [why human needed]

## Discovered Gaps

- [Gap 1: what's missing vs what spec requires]
- [Gap 2: ...]

## Notes for Next Ralph

- [Relevant findings, patterns discovered, warnings]
```

---

## Parallel Subagent Usage

```
→ Subagent 1: Verify required artifacts exist per bmad-help.csv for current phase
→ Subagent 2: Search planning-artifacts for acceptance criteria and map to code (if any)
→ Subagent 3: Search for TODOs, FIXMEs, placeholders
→ Subagent 4: Check test coverage for story features (if tests configured)
```

Synthesize findings into @IMPLEMENTATION_PLAN.md.

---

## Exit Conditions

→ IP updated with comprehensive gap analysis
→ Tasks prioritized by importance
→ Context clear for build-mode Ralph
→ NO code changes made

**Exit cleanly. Build-mode Ralph will implement.**
