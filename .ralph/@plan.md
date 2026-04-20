# Implementation Plan

## NOW

- [ ] CR re-run #7: `/bmad-code-review (args: "2")` adversarial triage against post-Fix-R/S/T/U diff. Expected outcome per FR14n matrix row 10 single-transition edge: zero findings across all 3 layers → `fixes-pending → sm-verified → done`. If new findings surface (eighth round), queue fix tasks and stay `fixes-pending`. Halving hypothesis DECISIVELY falsified across 6 rounds (iter-14 4 → iter-18 2 → iter-21 2 → iter-24 5 → iter-30 5 → iter-36 30 raw → 4 post-triage); residual-risk at CR re-run #7 is EIGHTH-ROUND residue — either (a) DEFER-SET re-surfaces as convergent findings (requiring promotion to fix), or (b) broader-corpus SIBLING-VOCABULARY-CLUSTER residue from Fix R/S/T/U's vocabulary introductions (`load-bearing complement` spreading, `(no automated test)` template-prefix expanding, Fix U's `complements the substrate evidence` phrase — new literal at trace.md:145), or (c) convergent zero-out signalling story closure (low-probability given prior 6-round non-halving trend). ~large

## QUEUE (Story 1.9)

_(empty — CR re-run #7 is sole NOW; if it zero-outs, Story 1.9 → `sm-verified → done` and sprint-status next-open story auto-selected at following iteration)_

## BLOCKED

_(none)_

## DONE (Story 1.9 — iter-36..iter-40, pruned)

- [x] iter-40: Fix U/4 [MEDIUM] landed — `_bmad-output/test-artifacts/traceability/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md` two-site backstop-vocabulary reframe. (a) :105 AC-2 Gaps `CR adversarial pass (Blind Hunter) is the agreed backstop per § Testing Standards.` → `Schema-level uniqueness refine (load-bearing complement per Fix O iter-33) + CR adversarial pass (Blind Hunter) per § Testing Standards.` (introduces Fix-O-aligned "load-bearing complement" vocabulary, acknowledging InvariantsSchema.superRefine uniqueness refine already listed at :101 substrate_verification). (b) :145 AC-5 Recommendation `CR adversarial pass (Blind Hunter) backstops.` → `CR adversarial pass (Blind Hunter) per § Testing Standards complements the substrate evidence.` (swaps "backstops" → "complements" + adds "per § Testing Standards" citation + adds "the substrate evidence" object). Pre-edit grep `agreed backstop|backstops` trace.md-wide: 8 hits. Post-edit: 6 hits (all in AC-3 scope [:112/:118/:205] + § Testing Standards / § Business Justification scope [:260/:311/:486] — scope-preserved). AC-2/AC-5 scope post-edit: 0 hits ✓. SIBLING-VOCABULARY-CLUSTER carry-forward rule (iter-36) fully discharged across Fix R/S/T/U (all 4 PATCH items from CR re-run #6 triage). iter-36 block R/S/T/U checkboxes stay `[ ]` — convention per iter-36 DONE entry is to flip prior-round checkboxes AT the NEXT CR re-run iteration (iter-41 will flip R/S/T/U en-masse). Pure prose — zero substantive-claim change, zero code changes.

- [x] iter-37..iter-39: Fix R + Fix S + Fix T landed per SIBLING-VOCABULARY-CLUSTER sweep. Fix R (coverage-matrix.json:39 `Schema-level backstop:` → `Schema-level load-bearing complement:` sync with Fix O iter-33). Fix S (trace.md:175/:236/:484 bare `runner-hosted` × 3 → `test-runner-hosted`, discharging Fix Q iter-35 AC-7 unbolded carve-out). Fix T (trace.md:112 + :205 AC-3 Coverage header + HP Gaps item-3 template-prefix `(no automated test)` added; preserves `structural only` spec-accurate claim). All pure prose; zero substantive-claim change, zero code changes.

- [x] iter-36: `/bmad-code-review (args: "2")` CR RE-RUN #6 — 3-layer fan-out against post-Fix-M/N/O/P/Q diff (`bcd18e2..HEAD`, 121 lines across 4 artefacts). 30 raw findings (15 Blind Hunter NEW_FINDINGS + 15 Edge Case Hunter NEW_FINDINGS) + Acceptance Auditor PASS (9 positive checks). Triage: 4 PATCH (Fix R/S/T/U) + 6 DEFER + 13 DISMISS. Sixth-round halving hypothesis DECISIVELY falsified; new lesson: SIBLING-VOCABULARY-CLUSTER drift (orthogonal to iter-14..21 vocabulary-variant, iter-24 SYMMETRIC-AC-PARALLEL, iter-30 SIBLING-FIELD-PARALLEL). New carry-forward rule: broader-corpus grep sweep on every vocabulary literal refresh (trace.md + coverage-matrix.json + story-file Dev Agent Record) with pre-edit + post-edit attestation.

- [x] iter-7..iter-35: 6 initial patches + CR rounds #1–#5 (iter-14/18/21/24/30) + 12 fixes (A/B/C/D/E/F/G/H/I/J/K/L/M/N/O/P/Q). Four residue classes identified across 5 rounds: (1) vocabulary-variant within-same-AC-same-field; (2) SYMMETRIC-AC-PARALLEL cross-AC same-field; (3) SIBLING-FIELD-PARALLEL within-AC cross-field; (4) SIBLING-VOCABULARY-CLUSTER broader-corpus-vocabulary-propagation (iter-36). Full per-iteration history in git log.

## Context

- **Phase:** 4-implementation
- **Epic:** Epic 1 — Substrate Foundation & Machine-Enforced Invariants (Stories 1.1–1.8 done; 1.9 fixes-pending → all 4 PATCH fixes R/S/T/U discharged; iter-41 runs CR re-run #7; if zero-outs → `sm-verified → done`; 7 more stories 1.10–1.16 remain before EPIC_DONE)
- **Epic Branch:** `feat/story-1-8-invariants-manifest-ts-contract-exporter` (continues through Epic 1; PR #226 stays Draft until EPIC_DONE per PROMPT_build.md step 5c)
- **Story:** `1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector`
- **Story File:** `_bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md`
- **Story State:** `fixes-pending` (Ralph FR14n matrix row 10) — all 4 PATCH fixes (R/S/T/U) from iter-36 CR re-run #6 triage now landed. iter-41 runs CR re-run #7; flips to `done` only on zero-findings outcome per matrix row 10 single-transition edge.
- **PR:** #226 (Draft, MERGEABLE, no-CI-checks-reported — stays Draft through Epic 1; Draft→Open at EPIC_DONE)

## Notes

- **iter-36 CR re-run #6 surfaced SIBLING-VOCABULARY-CLUSTER residue class (seventh-round):** broader-corpus-vocabulary-propagation where narrow fixes introduced NEW vocabulary (`load-bearing complement`, `test-runner-hosted`, `SUBSTRATE_VERIFIED`, `(no automated test)` template-prefix) that did not grep-sweep through structurally-adjacent paragraphs in trace.md + coverage-matrix.json. Fix R/S/T/U discharged this across iter-37..iter-40 — 8 sites total (1 coverage-matrix.json leaf + 7 trace.md sites across AC-2/AC-3/AC-5/AC-7 scopes).
- **Pattern — SIX CR re-runs (iter-14/18/21/24/30/36) confirm NON-HALVING cumulative compound-drift as the story's defining residue family.** iter-14 4 → iter-18 2 → iter-21 2 → iter-24 5 → iter-30 5 → iter-36 30 raw → 4 PATCH. Each round reveals a new propagation axis. Residual-risk at CR re-run #7 (iter-41): eighth-round residue from Fix U's `complements the substrate evidence` literal propagation + Fix R/S/T vocabulary introductions spreading into uncovered-corpus sites (e.g., Dev Agent Record prose in story file, deferred-work.md entries). If convergent, queue fix tasks; if single-layer adversarial overreach, dismiss.
- **Deferred at iter-36 (6 items — recorded in `_bmad-output/implementation-artifacts/deferred-work.md § Deferred from: code review RE-RUN #6 of story-1.9 (2026-04-20)`):** BH2 (coverage-matrix.json scope_notes vs level_notes posture), BH3 (AC-2 vs AC-5 level_notes asymmetry), EH2 (AC-3 level_notes bare `structural`), EH3 (AC-1 level_notes `runner-hosted`), EH4 (AC-6 level_notes missing `smoke (shell)` prefix), EH10 (AC-2 Recommendation WAIVED posture). Revisit at Story 1.16 test-runner landing or Epic 13 workflow-wiring. If any re-surfaces at CR re-run #7 as convergent (two-layer), promote to fix.
- **Post-iter-40 EPIC-done readiness UNCHANGED.** Even if CR re-run #7 zero-outs Story 1.9, sprint-status shows stories 1.10–1.16 still `backlog` (7 more stories × full FR14n lifecycle). EPIC_DONE halt many iterations away; PR #226 stays Draft.
- **Issue Tracking:** Story 1.9 issue number still unset at iter-40. Parent Epic 1 issue **#9** — `Refs #9` only.
