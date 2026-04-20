# Implementation Plan

## NOW

- [ ] Story State `sm-verified` → Run `/bmad-code-review (args: "2")` — adversarial triage (Blind Hunter + Edge Case Hunter + Acceptance Auditor); one CR action item per iteration until QUEUE empty ~medium

## QUEUE (Story 1.7 — lifecycle gates)

- [ ] Story State `done` → Transition PR #224 Draft→Open — rewrite title/body for full spec+iter-1+iter-2+iter-3+Tasks-1-3+trace+SM-review+CR commit range; EPIC_DONE halt (mini-epic convention, 7th story-implementation precedent)

## BLOCKED

_(none)_

## ATDD Skip Rationale (FR14n matrix row 3)

Story 1.7 is a documentation-artefact story with no runtime behaviour to probe. Story file § Testing Standards (line 141) states verbatim: _"No ATDD probe task (contrast Stories 1.3/1.4/1.5/1.6 which had runtime behaviour to probe). The AC checks are satisfied by existence + verbatim-match + markdown-parse; no runtime assertion needed until Story 1.9's sync-gate lands."_ All 5 ACs are static-content checks (file existence + audience-header presence + promotion-rule verbatim-match + INVARIANTS.md index entries + RALPH.md scope note). The FR14n matrix row for `validated` explicitly permits `validated → in-dev` skip when the story has no testable ACs, provided rationale is recorded in IP — which this section satisfies. Quality gates (typecheck/lint/format:check/commitlint/prek-runner parity) in Task 3 remain mandatory and are NOT ATDD probes; they are substrate verification from Stories 1.4/1.5.

## DONE (Story 1.7 iter-6)

- [x] **`/bmad-create-story (args: "review")` post-dev SM requirements-satisfaction verification (iter 6) — all 5 ACs PASS; Story State `traced → sm-verified`.** Realised via `.claude/skills/bmad-create-story/checklist.md` fresh-context audit against the implementation (no skill-native review mode; checklist fallback per iter-2 Lessons). Evidence per AC:
  - **AC 1 (4 files exist + audience headers pinned)** — `INVARIANTS.md` line 1 `# INVARIANTS.md — agent-readable index of machine-enforced rules` + line 3 audience clause; `AGENTS.md` line 1 `# Agent instructions — ralph-bmad` + line 3 `provider-neutral guide for any AI coding agent`; `CLAUDE.md` line 1 `# CLAUDE.md` + line 3 `guidance to Claude Code (claude.ai/code)`; `RALPH.md` line 1 `# RALPH.md — notes from Ralph, to Ralph` + line 3 `Ralph's private workspace`. All four audiences match AC 1's expected form verbatim.
  - **AC 2 (promotion rule pinned verbatim across 4 files)** — Character-exact grep confirms the canonical 4-row table present at `INVARIANTS.md:9-16`, `AGENTS.md:13-20`, `CLAUDE.md:57-64`, `RALPH.md:15-22`. Machine-enforced row `| Machine-enforced (config/rule/gate in code) | `INVARIANTS.md` + `packages/keel-invariants/` |` matches character-for-character across all four (including padding). First-row `| Applies to every AI agent (ops + truth)     | `AGENTS.md`                                   |` also matches (including trailing spaces). Prettier-normalised column widths held.
  - **AC 3 (INVARIANTS.md stable-ID index with source pointers)** — 9 `- **`INV-*`** — desc. Source: path` entries under `## Invariants index` (grep count `^- \*\*`INV-` = 9): `INV-tsconfig-base` / `INV-eslint-shared` / `INV-prettier-shared` / `INV-commitlint-shared` (Story 1.2 row); `INV-eslint-import-boundary` (Story 1.3 row); `INV-prek-pre-commit-config` / `INV-prek-prepare-lifecycle` (Story 1.4 row); `INV-prek-commit-msg-config` (Story 1.5 row); `INV-no-verify-bypass` (Story 1.6 row). Each entry has stable ID + one-line description + `Source:` pointer. Story 1.7 § Scope Carve-Out preserves AC 3 intent (provisional; Story 1.8 becomes canonical).
  - **AC 4 (CLAUDE.md points at AGENTS.md + only Claude-specifics)** — Line 5 verbatim: `See [AGENTS.md](./AGENTS.md) for the full agent guide — it is the source of truth for any AI coding agent (Claude Code, Codex, etc.). The notes below are Claude-Code-specific or Ralph-loop-specific supplements.` Body then scopes to Claude-Code-specific content (skill-as-slash-command, settings.local.json, worktrees, memory paths) + Ralph-loop content (per CLAUDE.md's own scope); no non-Claude operational truth duplicated from AGENTS.md.
  - **AC 5 (RALPH.md header scope note)** — Line 5 verbatim: `_Scope: Ralph's private journal. Append-only-in-spirit (hard lint enforcement lands in Epic 3 per RS6 — until then, discipline is self-policed)._` Placement: between H1+audience paragraph and `Rules:` bullets (interpreted as "header" per story file § Project Structure Notes "§ RALPH.md scope-note placement"). All three required clauses present: (a) private journal; (b) append-only-in-spirit; (c) hard lint enforcement Epic 3 / RS6.
  - **Unmet-AC findings: ZERO.** No fix tasks queued. `Story State: traced → sm-verified` on first pass — matches iter-5 Lessons expectation for docs-only stories whose ACs are entirely static-content checks already evidenced by dev-story File List + Completion Notes + visible INVARIANTS.md content.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 tasks-complete / traced / sm-verified / lifecycle-in-flight; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** sm-verified
