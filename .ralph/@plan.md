# Implementation Plan

## NOW

- [ ] Story State `in-dev` → Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability matrix (expected: empty coverage matrix with documented rationale since ACs are static-content; fix tasks queued if unexpected gaps — unlikely for docs-only story) ~small

## QUEUE (Story 1.7 — lifecycle gates)

- [ ] Story State `traced` → Run `/bmad-create-story (args: "review")` post-dev — SM requirements-satisfaction verification (confirms Tasks 1/2/3 satisfied all 5 ACs)
- [ ] Story State `sm-verified` → Run `/bmad-code-review (args: "2")` — adversarial triage (Blind Hunter + Edge Case Hunter + Acceptance Auditor); one CR action item per iteration until QUEUE empty
- [ ] Story State `done` → Transition PR #224 Draft→Open — rewrite title/body for full spec+iter-1+iter-2+iter-3+Tasks-1-3+lifecycle commit range; EPIC_DONE halt (mini-epic convention, 7th story-implementation precedent)

## BLOCKED

_(none)_

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artifact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-4)

- [x] Pre-dev validation (iter 2) per `/bmad-create-story (args: "review")` semantics — audited story file against checklist; 8 source pointers resolve; 5 ACs well-formed; architecture + PRD citations accurate verbatim; Scope Carve-Out documented; Dev Notes cite all 9 invariants from Stories 1.2–1.6; no blocking gaps. Story State transition `drafted → validated` (FR14n matrix row 2).
- [x] ATDD-path decision (iter 3) per FR14n matrix row 3 — resolved as SKIP. Rationale recorded in IP § ATDD Skip Rationale above AND visible inline at story file line 141. Precedent established for future documentation-artifact / spec-only stories: skip is legitimate iff story's § Testing Standards declares "no runtime assertion needed". Story State transition `validated → in-dev` (via skip, not ATDD scaffolding).
- [x] `/bmad-dev-story` executed Tasks 1/2/3 (iter 4) — authored `INVARIANTS.md` at repo root (9 provisional-ID invariants from Stories 1.2–1.6); added `## Promotion rules` canonical 4-row table verbatim to `AGENTS.md` / `CLAUDE.md` / `RALPH.md`; extended `CLAUDE.md`'s Knowledge-file contract table with INVARIANTS.md row (FR42 satisfied); added `RALPH.md` scope note (AC 5); all 6 quality gates green (install / typecheck FULL TURBO / lint FULL TURBO / format:check / commitlint 0p/0w / prek all 3 hooks Passed); sprint-status bumped `1-7: in-progress → done` with `last_updated: 2026-04-20 Task-3 UTC` (co-landed per preemptive-orphan-prevention precedent — 7th story-implementation confirmation); story file Status flipped `ready-for-dev → done`; all Task/subtask checkboxes ticked; Dev Agent Record populated.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 tasks-complete / lifecycle-in-flight; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** in-dev
