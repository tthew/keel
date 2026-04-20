# Implementation Plan

## NOW

- [ ] Story State `validated` → decide ATDD path per FR14n matrix: run `/bmad-testarch-atdd` OR record skip rationale in IP and transition `validated → in-dev` (docs-only story; ACs are static-content checks — no runtime behaviour to probe) ~small

## QUEUE (Story 1.7 — lifecycle gates)

- [ ] Story State `atdd-scaffolded` (or `in-dev` via skip) → Run `/bmad-dev-story (args: "_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md")` — executes spec Tasks 1/2/3: author `INVARIANTS.md` at repo root + align promotion-rule tables (verbatim) in `AGENTS.md` / `CLAUDE.md` / `RALPH.md` + extend CLAUDE.md's Knowledge-file contract table + add RALPH.md scope note + quality gates + sprint-status bump (`1-7 → done`)
- [ ] Story State `in-dev` → Run `/bmad-testarch-trace (args: "yolo")` — AC→test coverage gate + traceability matrix (expected: empty coverage matrix with documented rationale since ACs are static-content; fix tasks queued if unexpected gaps — unlikely for docs-only story)
- [ ] Story State `traced` → Run `/bmad-create-story (args: "review")` post-dev — SM requirements-satisfaction verification (confirms Tasks 1/2/3 satisfied all 5 ACs)
- [ ] Story State `sm-verified` → Run `/bmad-code-review (args: "2")` — adversarial triage (Blind Hunter + Edge Case Hunter + Acceptance Auditor); one CR action item per iteration until QUEUE empty
- [ ] Story State `done` → Transition PR #224 Draft→Open — rewrite title/body for full spec+iter-1+iter-2+lifecycle+Tasks-1-3 commit range; EPIC_DONE halt (mini-epic convention, 7th story-implementation precedent)

## BLOCKED

_(none)_

## DONE (Story 1.7 iter-2)

- [x] Pre-dev validation per `/bmad-create-story (args: "review")` semantics — audited story file against `.claude/skills/bmad-create-story/checklist.md`: 8 source pointers resolve (`ls packages/keel-invariants/{tsconfig.base.json,eslint.config.keel-invariants.js,prettier.config.keel-invariants.js,commitlint.config.keel-invariants.js,src/eslint-rules/{no-verify-bypass.js,index.js}} .pre-commit-config.yaml package.json`), 5 ACs well-formed in BDD shape, architecture.md:771 (`INVARIANTS.md` at repo root) + :901–902 (existing `INV-ralph-safe-set-layering` / `INV-claude-hook-secret-denylist` anchor convention) + prd.md FR42/FR43 citations accurate verbatim, Scope Carve-Out for AC 3 (canonical list deferred to Story 1.8's `invariants.manifest.ts` + Story 1.9's FR43 sync-gate) documented with provisional-ID HTML comment, Dev Notes cite all 9 invariants from Stories 1.2–1.6 with correct source-file pointers, no critical gaps, no enhancement opportunities blocking dev
- [x] Story State transition `drafted → validated` (per FR14n matrix row 2)

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.6 done; 1.7 in flight; 1.8–1.16 backlog)
- **Epic Branch:** `feat/story-1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules`
- **Story:** 1.7 — Invariants knowledge files (INVARIANTS/AGENTS/CLAUDE/RALPH) with promotion rules
- **Story File:** `_bmad-output/implementation-artifacts/1-7-invariants-knowledge-files-invariants-agents-claude-ralph-with-promotion-rules.md`
- **Story State:** validated
