# Implementation Plan

## NOW

- [ ] Story State `fixes-pending` (fix #2/4) → Correct `INV-eslint-import-boundary` source pointer in `INVARIANTS.md:31` — off-by-one on `sharedBase[6]` (7th) + `forPackage()[9]` (10th); replace with name-based reference ("the `no-restricted-imports` block") or correct indices ~small

## QUEUE (Story 1.7 — CR fix pass + re-gate + PR transition)

- [ ] Story State `fixes-pending` (fix #3/4) → Correct trace JSON values in `_bmad-output/test-artifacts/traceability/1-7-e2e-trace-summary.json` lines 609-614 — `auth_negative_path_status` + `error_path_status` should be `not_applicable` (not `present`) to match md prose for this docs-only / zero-runtime-surface story
- [ ] Story State `fixes-pending` (fix #4/4) → Correct waiver expiry placeholder `2026-XX-XX` in `_bmad-output/test-artifacts/traceability/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md` (YAML snippet near line 1209) — replace with `deferred` or a concrete Story 1.9 landing date
- [ ] Story State `fixes-pending` → Re-run `/bmad-code-review (args: "2")` — confirm `### Review Findings` cleared; Story State `fixes-pending → sm-verified → done` (no new findings) OR `fixes-pending` again (any new finding queues a fresh fix)
- [ ] Story State `done` → Transition PR #224 Draft→Open — rewrite title/body for full spec+iter-1+iter-2+iter-3+Tasks-1-3+trace+SM-review+CR commit range; EPIC_DONE halt (mini-epic convention, 7th story-implementation precedent)

## BLOCKED

_(none)_

## Deferred (CR iter-7 — recorded per `defer: <reason>` rule)

- `1-7-gate-decision.json` lacks structured `waiver: {reason, approver, expiry, remediation_due}` sub-object; `rationale` prose present; structured waiver block IS present in `1-7-e2e-trace-summary.json` — **defer: trace-skill schema concern, not Story 1.7 scope; waiver-bearing file exists in the pair**.
- `architecture.md:891` shows idealised `packages/keel-invariants/src/` layout; on-disk is `packages/keel-invariants/` at package root (no `src/` parent for config files) — **defer: pre-existing architecture-doc gap predating Story 1.7; Story 1.8's manifest import will reconcile**.

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artefact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-8)

- [x] **CR fix #1/4 — `INV-eslint-shared` description rewrite.** Replaced brittle "6-entry flat-config default export (ignores + JS-recommended + 3× tseslint-recommended + globals)" with name-based anchor prose: "shared ESLint flat-config baseline extended by every workspace member: global `ignores` + `js.configs.recommended` + `tseslint.configs.recommended` (spread) + `languageOptions.globals` (node + browser)" + explicit demarcation parenthetical naming `INV-eslint-import-boundary` and `INV-no-verify-bypass` as the IDs carrying the `no-restricted-imports` and `keel-invariants/no-verify-bypass` entries in the same file. Applied to both `INVARIANTS.md:25` (live file) AND story-file skeleton at line 67 (keeps story as faithful record of authored content). Story-file `### Review Findings` item 1/4 flipped `[ ] → [x]` with **Resolved iter-8** addendum capturing the rewrite. FR14n matrix row 10 (`fixes-pending → stays until QUEUE empties → re-run CR`) — 3 more fix passes before re-run. **Lesson carried from iter-7's triage:** the name-based-anchor pattern (vs. counts/indices) is inherently drift-resistant — future INV-* authors (Stories 1.8+) should prefer "the `X` block" / "the `Y` entry" over "6th of N" / "index 5" references, because the latter rot when the source file gains/reshuffles entries. INVARIANTS.md content-hash drift (Story 1.9 sync-gate) will still detect any hash change, but name-based anchors minimise false-positive drift when the human-readable description stays semantically accurate.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 CR-fixes-pending; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** fixes-pending
