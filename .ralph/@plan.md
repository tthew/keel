# Implementation Plan

## NOW

- [ ] Story State `traced` → Run `/bmad-create-story (args: "review")` post-dev — SM requirements-satisfaction verification (audit against checklist — Story 1.7 story file + impl evidence: 5 ACs satisfied by INVARIANTS.md existence + 4-row promotion-rule table verbatim-match across 4 files + 9-entry stable-ID index + CLAUDE.md audience pointer + RALPH.md scope note; expected: sm-verified with no unmet ACs given all 5 are static-content checks already evidenced by dev-story File List + Completion Notes) ~small

## QUEUE (Story 1.7 — lifecycle gates)

- [ ] Story State `sm-verified` → Run `/bmad-code-review (args: "2")` — adversarial triage (Blind Hunter + Edge Case Hunter + Acceptance Auditor); one CR action item per iteration until QUEUE empty
- [ ] Story State `done` → Transition PR #224 Draft→Open — rewrite title/body for full spec+iter-1+iter-2+iter-3+Tasks-1-3+trace+lifecycle commit range; EPIC_DONE halt (mini-epic convention, 7th story-implementation precedent)

## BLOCKED

_(none)_

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artefact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-5)

- [x] `/bmad-testarch-trace (args: "yolo")` executed (iter 5) — oracle resolved as `formal_requirements` / `acceptance_criteria` / confidence `high` (Story 1.7 AC 1–5 are well-formed BDD criteria). Produced 3 artefacts under `_bmad-output/test-artifacts/traceability/`: (a) `1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md` — full trace-template report with 5 AC rows, per-AC gap analysis citing downstream enforcement, Phase 1 coverage summary, Phase 2 gate decision with rationale + waiver block; (b) `1-7-coverage-matrix.json` — Phase 1 JSON (matches step-04 schema: `phase=PHASE_1_COMPLETE`, trace_target, 5 requirements all `coverage=NONE` priority `P2`, gap_analysis 5 medium_gaps, empty test_inventory); (c) `1-7-e2e-trace-summary.json` + `1-7-gate-decision.json` — machine-readable exports matching step-05 schema. **Gate Decision: WAIVED** (not FAIL). Rationale: deterministic rule-2 (overall 0% < 80%) would emit FAIL, but Story 1.7 is a documentation-artefact story whose § Testing Standards explicitly defers per-AC coverage to Stories 1.8 (`invariants.manifest.ts` Zod schema + content hashes) + 1.9 (FR43 sync-gate pre-merge drift-check) + Epic 3 (RS6 RALPH.md lint). Waiver is stakeholder-authored in the story file itself. Substrate quality gates (typecheck 16/16 FULL TURBO + lint 16/16 FULL TURBO + format:check + commitlint 0p/0w + prek all 3 hooks Passed) landed green at dev-story (Story 1.7 Task 3 Completion Notes). Waiver expires when Story 1.9 sync-gate lands. Story State transition `in-dev → traced`.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 tasks-complete / traced / lifecycle-in-flight; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** traced
