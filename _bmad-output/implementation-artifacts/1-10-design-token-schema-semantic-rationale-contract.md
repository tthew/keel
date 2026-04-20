# Story 1.10: Design-token schema + semantic-rationale contract

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a UX designer or front-end developer,
I want `packages/ui/tokens.schema.json` defining the DTCG-compatible token-contract shape AND `docs/invariants/tokens.md` documenting every semantic token's meaning with a stable `TOKEN-<slug>` ID,
So that downstream consumers (Story 1.11 source population, Story 1.12 emitter pipeline, Epic 7 catalog, Epic 3 TUI) reference tokens against a shared validated contract — no invisible semantic drift between runtimes (W1 party-mode amendment; UX-DR4).

## Acceptance Criteria

1. **Given** the substrate,
   **When** I inspect `packages/ui/tokens.schema.json`,
   **Then** the JSON Schema defines the shape of the token source (semantic names, scales, primitive references)
   **And** validates DTCG-format-compatible structure.

   **Story 1.10 scope carve-out:** the schema validates **structure** only — it asserts that every token object carries a `$type` ∈ `{color, dimension, duration, number, fontFamily, fontWeight, cubicBezier}`, a `$value` (string literal or `{reference}` alias), and that the top-level object exposes the named semantic groups below (§ Dev Notes → Semantic token inventory). Population of concrete token values is Story 1.11's scope; schema does not constrain numeric ranges, contrast ratios, or value quality (those are Story 1.13's pre-commit gates).

2. **Given** `docs/invariants/tokens.md`,
   **When** I read it,
   **Then** every semantic token (`surface.raised`, `status.success`, `text.primary`, `motion.scale.*`, `density.scale.*`, etc.) has a prose rationale line
   **And** each rationale carries a stable `TOKEN-<slug>` ID (e.g. `TOKEN-surface-raised`, `TOKEN-status-success`, `TOKEN-motion-snap`).

   **Story 1.10 scope carve-out:** `motion.scale.*` / `density.scale.*` in the epic's AC 2 shorthand refer jointly to the global dial (`motion.scale` / `density.scale` — leaf, `$type: number`, reduced-motion respects `= 0`) AND the named tiers that are the dial's siblings (`motion.{instant|snap|swift|smooth|drift}` / `density.{compact|default|comfortable}` — leaves, `$type: duration | number`). Stable IDs therefore resolve as: `TOKEN-motion-scale` (dial) + `TOKEN-motion-{instant|snap|swift|smooth|drift}` (tiers); `TOKEN-density-scale` (dial) + `TOKEN-density-{compact|default|comfortable}` (tiers). Three-segment IDs like `TOKEN-motion-scale-snap` are NOT used — the dial is the scaling multiplier (a leaf, not a group node), the tiers are discrete duration/density leaves, and DTCG does not permit a group node to carry `$type`. The flat two-segment form also matches architecture.md:693 `<category>.<semantic-name>.<modifier?>` ID pattern (category = `motion | density`; semantic-name = `scale | instant | snap | ...`; modifier unused).

3. **Given** schema + rationale,
   **When** Epic 7's catalog or Epic 3's TUI references a semantic token,
   **Then** the reference can be cross-linked back to `tokens.md`'s rationale via the stable `TOKEN-<slug>` ID
   **And** `tokens.md` is the source-of-truth rationale (Sally's "catalog header references rationale" requirement met — see UX spec § Architecture of the Design System).

4. **Given** the schema is the contract,
   **When** the manifest (Story 1.8) tracks it,
   **Then** an entry `INV-tokens-schema-contract` registers `packages/ui/tokens.schema.json` (schema contract), plus a companion entry `INV-tokens-semantic-rationale` registers `docs/invariants/tokens.md` (rationale contract)
   **And** drift between either file and its manifest `contentHash` is caught by Story 1.9's `pnpm keel-invariants:check`.

   **Story 1.10 scope carve-out:** Story 1.8's `Invariant` shape carries one `sourcePath` per entry (`packages/keel-invariants/src/invariants.manifest.ts:6-11`). Per-file registration is the established pattern (see Story 1.8's 10 existing entries + Story 1.9's `INV-ralph-halt-path-resolution` close-out); the two tokens-contract files get two sibling IDs. The epic's single-entry phrasing at `epics.md:951` (`entry INV-tokens-schema-contract registers tokens.schema.json + tokens.md`) is collapsed here to match the existing manifest shape without changing the `Invariant` schema. If a future story wants multi-file bundles, `InvariantSchema` extension lands there.

## Tasks / Subtasks

- [ ] **Task 1: Author `packages/ui/tokens.schema.json`** (AC: 1)
  - [ ] Create `packages/ui/tokens.schema.json` at repo-relative path (not under `src/` — it's a data contract consumed at lint / build time, not TS-compiled; parallels `packages/keel-invariants/src/schemas/*.schema.json` location pattern from architecture.md:920-927, adjusted for the `ui` package's data layout per ux-design-specification.md:358).
  - [ ] Use JSON Schema draft-2020-12 (`"$schema": "https://json-schema.org/draft/2020-12/schema"`) — matches the `InvariantSchema` Zod-generated JSON Schema convention implicit in `packages/keel-invariants/src/schemas/` architecture handoff.
  - [ ] Define DTCG-compatible token-node shape. Every leaf token MUST have:
    - `$type`: enum (`"color" | "dimension" | "duration" | "number" | "fontFamily" | "fontWeight" | "cubicBezier"`) — DTCG type classifier.
    - `$value`: string — either a literal (e.g. `"oklch(62% 0.16 245)"`, `"16px"`, `"150ms"`) OR a `{path.to.token}` alias. Regex: `/^(\{[a-z][a-z0-9]*(\.[a-z0-9][a-z0-9-]*)+\}|[^{}]+)$/`.
    - `$description` (optional): string — human-readable prose. OPTIONAL at schema level; AC 2 pins the rationale prose in `tokens.md`, not in the schema.
  - [ ] Define top-level semantic groups as required `object` properties of the root schema. Minimum set (extracted from ux-design-specification.md § Visual Design Foundation):
    - `color.neutral.{50..950}` (primitive ramp)
    - `color.accent.{400|500|600}` (accent ramp; 400 for focus ring, 500 default, 600 hover)
    - `color.surface.{default|raised|inset|overlay}` (semantic surface)
    - `color.text.{primary|secondary|muted|inverse|accent}` (semantic text)
    - `color.border.{default|muted|accent}` (semantic border)
    - `color.status.{info|success|warning|error|critical}.{fg|bg}` (semantic status — fg/bg variants per architecture.md:693 modifier pattern)
    - `color.severity.{low|medium|high|critical}` (alias of status — see tokens.md rationale block)
    - `color.state.{pending|in-progress|blocked|done}` (Ralph kanban vocabulary; shared TUI + web)
    - `type.{xs|sm|base|lg|xl|2xl|3xl|4xl}` (modular type scale, 1.125 ratio — ux-design-specification.md:530)
    - `font.{sans|mono}` (font stack)
    - `space.{0..24}` (4px-base Tailwind stops — ux-design-specification.md:547)
    - `radius.{none|sm|md|lg|full}` (radius scale — ux-design-specification.md:551)
    - `motion.scale` (global dial, `$type: number`) + `motion.{instant|snap|swift|smooth|drift}` (named tiers — epics.md:973, stored as `$type: duration` leaves aliasable by `motion.scale`)
    - `density.scale` (global dial, `$type: number`) + `density.{compact|default|comfortable}` (named tiers — epics.md:974)
    - `breakpoint.{sm|md|lg|xl|2xl}` (viewport breakpoints — ux-design-specification.md:560)
  - [ ] DTCG `modes` support: root schema accepts an optional `$modes` object keyed by mode name (`light | dark | high-contrast`). Mode overlays have the same shape as the base but may override any subset of leaf tokens. Story 1.10 declares the two required modes (`light`, `dark`) per ux-design-specification.md:484; Story 1.11 populates the values.
  - [ ] Duplicate-path rejection: schema uses `additionalProperties: false` at every level so misspelled keys fail validation (AC 1 + UX-DR4 intent: "Malformed structure, missing `$type`, unresolved `{reference}`, or duplicate paths fail" — ux-design-specification.md:375).
  - [ ] Unresolved-`{reference}` check: the literal/alias regex ensures `{...}` aliases are syntactically well-formed; full transitive-alias resolution is runtime (Story 1.12 emitter) not schema. Schema catches shape, not semantics.

- [ ] **Task 2: Author `docs/invariants/tokens.md`** (AC: 2, 3)
  - [ ] Create `docs/invariants/tokens.md` parallel to the established `docs/invariants/knowledge-files.md` + `docs/invariants/ralph-execute.md` pattern (same folder; same audience — normative spec for humans + AI agents).
  - [ ] Header structure:
    - Title + one-paragraph purpose statement (why a separate rationale doc: Sally's "catalog header references rationale" requirement — prevents invisible semantic drift when Epic 7 catalog / Epic 3 TUI references tokens by name).
    - Promotion-rule pointer (same 4-row table used in `INVARIANTS.md` + `AGENTS.md` + `RALPH.md`; reference not duplicate).
    - Stable-ID convention: `TOKEN-<slug>` where `slug` is the token path lowercased with `.` → `-` (e.g. `surface.raised` → `TOKEN-surface-raised`; `motion.scale.snap` → `TOKEN-motion-scale-snap`; `status.success.fg` → `TOKEN-status-success-fg`).
    - Cross-runtime reminder: semantic tokens are shared between the Tailwind preset (`packages/ui/tailwind.preset.ts`, Story 1.12) + Textual TUI theme (`packages/devbox/tui/theme.py`, Story 1.12); rationale lines therefore speak to both runtimes (architecture.md:90 — cross-runtime semantic tokens).
  - [ ] Rationale sections (one `###` per semantic group; one bullet per semantic token). Required groups + anchor bullet form:
    - `### Surfaces` — `TOKEN-surface-default`, `TOKEN-surface-raised`, `TOKEN-surface-inset`, `TOKEN-surface-overlay`.
    - `### Text` — `TOKEN-text-primary`, `TOKEN-text-secondary`, `TOKEN-text-muted`, `TOKEN-text-inverse`, `TOKEN-text-accent`.
    - `### Borders` — `TOKEN-border-default`, `TOKEN-border-muted`, `TOKEN-border-accent`.
    - `### Accent` — `TOKEN-accent-default`, `TOKEN-accent-fg`, `TOKEN-accent-focus`.
    - `### Status` — `TOKEN-status-info`, `TOKEN-status-success`, `TOKEN-status-warning`, `TOKEN-status-error`, `TOKEN-status-critical` (with `-fg` / `-bg` modifier variants enumerated explicitly).
    - `### Severity (alias of status)` — `TOKEN-severity-low|medium|high|critical` (rationale notes each aliases the matching `TOKEN-status-*`).
    - `### State (kanban vocabulary)` — `TOKEN-state-pending|in-progress|blocked|done` (rationale cites Ralph TUI origin + web-side parity).
    - `### Motion` — `TOKEN-motion-scale` (global dial; 0 = reduced-motion) + `TOKEN-motion-instant|snap|swift|smooth|drift`.
    - `### Density` — `TOKEN-density-scale` (global dial) + `TOKEN-density-compact|default|comfortable`.
    - `### Type scale` — `TOKEN-type-xs|sm|base|lg|xl|2xl|3xl|4xl`.
    - `### Spacing / radius / breakpoints` — one consolidated section is acceptable (primitive scales; rationale is the scale ratio + base unit, not per-stop); stable IDs `TOKEN-space-{N}`, `TOKEN-radius-{name}`, `TOKEN-breakpoint-{name}`.
  - [ ] Each rationale line follows a consistent template: `- **\`TOKEN-<slug>\`** — *<semantic purpose>*. <one-sentence why this token exists / when to use it>. Value: <source citation — "see ux-design-specification.md § …" OR literal note that value lands in Story 1.11>.` Terse; one line per token. Rationale is *semantic* (why the slot exists), not *syntactic* (the schema covers shape).
  - [ ] Closing section — § Consumption (same pattern as `INVARIANTS.md:52-54`): who reads this file + how Stories 1.11, 1.12, 1.13, and Epic 7 cross-reference it. Keep under 10 lines.
  - [ ] Closing section — § Extension (FR44 pattern): forks override via `apps/web/tokens.fork.json` (DTCG merge; ux-design-specification.md:387). Keep under 5 lines.

- [ ] **Task 3: Register both files in the invariants manifest + `INVARIANTS.md`** (AC: 4)
  - [ ] Compute `sha256sum` of the two authored files post-Task 1 + Task 2:
    - `sha256sum packages/ui/tokens.schema.json`
    - `sha256sum docs/invariants/tokens.md`
  - [ ] Append two entries to `packages/keel-invariants/src/invariants.manifest.ts` → `raw` array (after the last entry `INV-ralph-halt-path-resolution`; maintain trailing comma + array closure):
    ```typescript
    {
      id: 'INV-tokens-schema-contract',
      description:
        'Design-token JSON Schema contract — DTCG-compatible; defines shape of every semantic + primitive token group (color / type / space / radius / motion / density / breakpoint) plus optional $modes overlays. Validated at pre-commit (Story 1.13); consumed by the Story 1.11 source + Story 1.12 emitter.',
      sourcePath: 'packages/ui/tokens.schema.json',
      contentHash: '<sha256 from sha256sum invocation above>',
      anchors: ['INV-tokens-schema-contract'],
    },
    {
      id: 'INV-tokens-semantic-rationale',
      description:
        'Semantic-rationale doc pairing every TOKEN-<slug> with a prose line explaining why the slot exists + how cross-runtime consumers reference it. Companion to INV-tokens-schema-contract; Sally "catalog header references rationale" requirement.',
      sourcePath: 'docs/invariants/tokens.md',
      contentHash: '<sha256 from sha256sum invocation above>',
      anchors: ['INV-tokens-semantic-rationale'],
    },
    ```
  - [ ] Append two sibling anchors to `INVARIANTS.md` under a new `### Design-token schema + semantic rationale (Story 1.10)` section (insert between the existing `### Ralph loop contracts` section at `INVARIANTS.md:48` and the § Consumption section). Anchor format MUST match the existing bullet shape (`- **\`INV-tokens-schema-contract\`** — <description>. Source: \`packages/ui/tokens.schema.json\`.`) — Story 1.9's anchor regex binds column 0 `-\s+\*\*\`INV-[a-z0-9]+(?:-[a-z0-9]+)+\`\*\*` per `packages/keel-invariants/src/sync-gate.ts:24`, so the two new bullets must be column-0 non-indented.
  - [ ] **Forbidden**: adding anchors inside triple-backtick code fences (Story 1.9 CR defer iter-14 flagged this as a latent footgun — `deferred-work.md:38`). The rationale doc for the anchor format should use inline backticks (e.g. `` `INV-tokens-schema-contract` `` in prose), not fenced block examples with bare `INV-*` bullets.
  - [ ] Verify: run `pnpm -w typecheck` — Zod `InvariantsSchema.parse(raw)` at import time validates both new entries (id regex, sha256-hex-length regex, anchors non-empty, sourcePath traversal refine, ID-uniqueness superRefine, shared-sourcePath cross-hash consistency superRefine — per `packages/keel-invariants/src/invariants.manifest.ts:1-47`). Any malformed field fails the typecheck loudly at first import.

- [ ] **Task 4: Quality gates + sync-gate smoke + sprint-status bump** (no AC — substrate verification)
  - [ ] `pnpm install` at repo root (no new deps expected — schema is static JSON, doc is markdown; confirm lockfile unchanged with `git diff --stat pnpm-lock.yaml`).
  - [ ] `pnpm -w typecheck` — green (existing passes + the Task 3 import-time Zod validation covers the two new manifest entries).
  - [ ] `pnpm -w lint` — green (no new TS source; ESLint walks JSON only if JSON plugin is wired — it isn't at Story 1.10 time; lint scope unchanged).
  - [ ] `pnpm -w build` — green (no new TS → no dist change in `@keel/ui`; `@keel/keel-invariants` dist reflects the 2 new manifest entries).
  - [ ] `pnpm format:check` — green (run `pnpm exec prettier --write packages/ui/tokens.schema.json docs/invariants/tokens.md packages/keel-invariants/src/invariants.manifest.ts INVARIANTS.md` first to normalise).
  - [ ] `pnpm exec commitlint --from origin/main --to HEAD --verbose` — green on any commits made during this story.
  - [ ] `pnpm exec prek run --all-files` — 3 hooks Pass (typecheck / lint / format-check).
  - [ ] **Sync-gate smoke (clean path, AC 4 end-to-end):** `pnpm keel-invariants:check` → exit 0 on the post-Task-3 state. Zero stderr output. Confirms both new manifest entries pair cleanly with their `INVARIANTS.md` anchors AND the recomputed `sha256sum` of the two files matches the manifest `contentHash` fields.
  - [ ] **Sync-gate smoke (drift path, AC 4 end-to-end):** append a single trailing newline to `packages/ui/tokens.schema.json`; rerun `pnpm keel-invariants:check` → exit 1 + structured JSON drift report on stderr naming `INV-tokens-schema-contract` as `content-hash-mismatch`; revert with `git checkout -- packages/ui/tokens.schema.json`; post-revert rerun → exit 0 + byte-identical restore (`git diff --stat packages/ui/tokens.schema.json` empty). Capture evidence in the Dev Agent Record § Completion Notes. Mirrors Story 1.9 Task 5's drift-smoke convention at `1-9-...md:95`.
  - [ ] **Sync-gate smoke (anchor drift, AC 4 second branch):** delete the `INV-tokens-schema-contract` anchor line from `INVARIANTS.md`; rerun `pnpm keel-invariants:check` → exit 1 + `added-to-source-only` Drift entry naming `INV-tokens-schema-contract` + `sourcePath packages/ui/tokens.schema.json`; revert with `git checkout -- INVARIANTS.md`; post-revert rerun → exit 0. Confirms the sync-gate's anchor-walker branch realises the second half of drift detection (Story 1.9 AC 2 / AC 5 symmetric coverage). Capture evidence in § Completion Notes.
  - [ ] Bump `_bmad-output/implementation-artifacts/sprint-status.yaml`: `1-10-design-token-schema-semantic-rationale-contract: ready-for-dev → done` (direct jump at `/bmad-dev-story` completion; skipped the `in-progress → review` BMad intermediate per Story 1.7 / 1.8 precedent — Ralph's FR14n lifecycle owns the trace / SM-review / CR gates that follow this dev-completion commit). `last_updated: 2026-04-20 Story-1-10-done UTC` (or current date). Preserve all existing comments + structure + STATUS DEFINITIONS block. The `backlog → ready-for-dev` hop already landed at `/bmad-create-story` time (iter-42); this Task covers only the `ready-for-dev → done` side.
  - [ ] Flip this story file's Status to `done` at `/bmad-dev-story` completion (per Story 1.8 precedent — BMad `Status: done` is the terminal state in the story file; Ralph's FR14n `atdd-scaffolded → in-dev → traced → sm-verified → done` intermediates run in parallel via IP § Context state tracking, not story-file Status). All Task subtasks `[x]`. `## Dev Agent Record` populated with File List + Completion Notes.

## Dev Notes

- **Relevant architecture patterns:**
  - **Three-layer invariant pattern applied to design tokens** (architecture.md:85). This story ships the *source-layer* (schema) + *agent-readable-layer* (rationale doc); Story 1.12 ships the *runtime-layer* (generated `tokens.css` + `tailwind.preset.ts` + `theme.py`); Story 1.13 ships the machine-enforced gates (schema validation + contrast check + source-output sync).
  - **Cross-runtime semantic tokens** (architecture.md:90). Token names must work in both the Tailwind class vocabulary (`text-status-success`, `bg-surface-raised`) and the Textual style vocabulary (`$status-success`, `$surface-raised`). The rationale doc is the shared contract — UX designers + front-end devs + Ralph read the same file.
  - **Design-token ID pattern** (architecture.md:693). Format: `<category>.<semantic-name>.<modifier?>`. Examples: `color.status.success`, `color.status.success.bg`, `space.density.compact`, `motion.duration.fast`. Schema + rationale doc both follow this pattern; primitives (`color.neutral.500`, `type.base`) and semantics (`color.surface.raised`, `status.success.fg`) coexist in the same tree.
  - **W1 party-mode amendment** (epics.md:653-661). Design tokens are substrate, not Epic 7 scope — Ralph's TUI (`theme.py`) + Epic 5 generator consume them early; waiting for Epic 7 creates retcon debt. The *schema contract* (this story) and the *source population* (Story 1.11) and the *emitter pipeline* (Story 1.12) all land in Epic 1 so the three-layer invariants pattern has token-layer teeth from 1.0.

- **Source-tree components to touch:**
  - `packages/ui/tokens.schema.json` — NEW. JSON Schema contract. No `dist/` counterpart — this is a data file, not TS.
  - `docs/invariants/tokens.md` — NEW. Rationale doc. Joins the existing `docs/invariants/{knowledge-files.md, ralph-execute.md}` family.
  - `packages/keel-invariants/src/invariants.manifest.ts` — APPEND 2 entries. `raw` array grows from 10 → 12 invariants.
  - `INVARIANTS.md` — APPEND 1 new `###` section with 2 anchor bullets.
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` — state bump (backlog → review via in-progress).

- **Semantic token inventory** (authoritative source: ux-design-specification.md § Visual Design Foundation, lines 480-604). Dev MUST enumerate every token in both the schema AND the rationale doc. Tokens explicitly named in AC 2 as canonical examples:
  - `surface.raised`, `status.success`, `text.primary` (three AC-named exemplars — MUST appear in `tokens.md`).
  - `motion.scale.*` — at least five tiers per epics.md:973: `instant | snap | swift | smooth | drift`.
  - `density.scale.*` — at least three tiers per epics.md:974: `compact | default | comfortable`.
  - Full inventory is enumerated by Task 1 subtasks (see § Tasks → Task 1 bullet list for the top-level semantic groups). Primitive scales (`neutral.50..950`, `type.xs..4xl`, `space.0..24`) are registered as contract shape but carry terser group-level rationale; semantic tokens (`surface.*`, `text.*`, `status.*`, `severity.*`, `state.*`) each get a dedicated bullet line with stable ID.

- **DTCG format refresher** (ux-design-specification.md:350-376):
  - Each leaf: `{ "$type": "...", "$value": "..." }` OR `{ "$type": "...", "$value": "{path.to.other.token}" }` for aliases.
  - Groups nest naturally: `"color": { "status": { "success": { "fg": { "$type": "color", "$value": "..." } } } }`.
  - `$type` enum used here: `color | dimension | duration | number | fontFamily | fontWeight | cubicBezier`. Full DTCG spec also supports `strokeStyle | border | transition | shadow | gradient | typography` — not needed at Story 1.10.
  - Modes: top-level `"$modes": { "light": {...overlay}, "dark": {...overlay} }` per ux-design-specification.md:484.

- **Testing standards summary** (architecture.md:650-652 + Story 1.8 / 1.9 precedent):
  - **No test runner at Story 1.10 time** (lands Story 1.16). Verification is substrate-layer: `pnpm -w {typecheck,lint,build,format:check}` + `pnpm exec prek run --all-files` + `pnpm keel-invariants:check` (Story 1.9 runtime tool).
  - **Sync-gate smoke** (AC 4) is the end-to-end evidence for this story — analogous to Story 1.9 Task 5 smoke patterns at `1-9-...md:94-97`. Two smoke branches required: `content-hash-mismatch` (modify schema file → exit 1 → revert) + `added-to-source-only` (delete anchor → exit 1 → revert). Byte-identical round-trip is the pass criterion.
  - **Deferred unit + integration tests**: once Story 1.16 lands the test runner, backfill per-AC unit tests can verify schema-structural validation (AC 1 schema rejects malformed inputs), rationale-doc completeness (AC 2 every token has a rationale ID — grep-based assertion), cross-link integrity (AC 3 every schema token ID ≡ a `TOKEN-<slug>` in the doc). None of these block Story 1.10's `review → done` transition.

### Project Structure Notes

- **Alignment with unified project structure.** `packages/ui/tokens.schema.json` follows architecture.md:358 exactly (`packages/ui/tokens.schema.json ← JSON Schema for validation`). `docs/invariants/tokens.md` matches the existing `docs/invariants/*.md` family (architecture.md:858 — `tokens.md ← Design-token manifest explainer`).
- **Variance from architecture handoff**: architecture.md:915 and :1216 name the token source as `packages/keel-invariants/src/design-tokens.ts` (typed variant); the UX spec and epics.md:963 carry the **DTCG JSON variant** as the preferred source with the typed variant listed as a deferred decision. Story 1.10 ships the schema for the DTCG variant per the UX spec's primary recommendation (ux-design-specification.md:358 + :373). The typed-variant path is not closed off — Story 1.11 ratifies the source-file choice (schema validates either representation since DTCG is portable). No blocking variance.
- **No conflict** with Story 1.8 manifest shape — per § AC 4 scope carve-out, the two-files-two-entries convention preserves the single-`sourcePath` `Invariant` contract pinned at `packages/keel-invariants/src/invariants.manifest.ts:6-11`. No manifest schema extension required.
- **Ralph L1/L2 layering** (architecture.md:786-788 + `.ralph-safe-set.yaml` — not yet landed; Story 3.24 scope). `packages/ui/tokens.schema.json` + `docs/invariants/tokens.md` are L3 lint-guarded at Story 1.10 time (standard substrate files; no Ralph self-modification risk). When Story 3.24's safe-set manifest lands, these files can be registered as L3 if desired.

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story-1.10-Design-token-schema--semantic-rationale-contract] — lines 926-952 — primary ACs + W1 amendment context.
- [Source: _bmad-output/planning-artifacts/epics.md#Epic-1-Substrate-Foundation] — lines 635-666 — W1/W2 amendment rationale; token-contract positioning as substrate.
- [Source: _bmad-output/planning-artifacts/architecture.md#Design-token-ID-Pattern] — lines 691-695 — `<category>.<semantic-name>.<modifier?>` ID format; cross-runtime stable-ID contract.
- [Source: _bmad-output/planning-artifacts/architecture.md#Three-layer-invariant-pattern] — lines 85-90 — cross-runtime semantic tokens invariant.
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Architecture-of-the-Design-System] — lines 340-398 — DTCG source-of-truth decision; emitter pipeline diagram; customization + extension strategy.
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Visual-Design-Foundation] — lines 480-604 — complete semantic token inventory (color / typography / spacing / radius / density / motion / breakpoints).
- [Source: _bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md] — `Invariant` interface + `InvariantSchema` precedent; 10-entry canonical list.
- [Source: _bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md] — sync-gate runtime tool + smoke-test pattern; `pnpm keel-invariants:check` entry point.
- [Source: packages/keel-invariants/src/invariants.manifest.ts] — `raw` array append site; Zod schema (regex + refine + superRefine layers).
- [Source: packages/keel-invariants/src/sync-gate.ts:24] — `ANCHOR_REGEX` column-0 bullet form — required anchor shape in `INVARIANTS.md`.
- [Source: INVARIANTS.md] — section-heading convention (`### <topic> (Story N.M)`); anchor bullet shape; § Consumption + § Extension patterns.
- [Source: docs/invariants/knowledge-files.md + docs/invariants/ralph-execute.md] — sibling normative-spec format for `docs/invariants/*.md` files; purpose statement + stable-ID convention + cross-reference footer.
- [Source: _bmad-output/implementation-artifacts/deferred-work.md] — lines 36-40 — Story 1.9 carry-forward: anchor-regex column-0 binding + code-fence footgun (avoid both in the new `INVARIANTS.md` section).

## Dev Agent Record

### Agent Model Used

_(populated by /bmad-dev-story at implementation time)_

### Debug Log References

### Completion Notes List

### File List

## Change Log

| Date       | Version | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Author |
| ---------- | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------ |
| 2026-04-20 | 1.0     | Initial story authoring (Ralph, iter-42; `_(no story)_ → drafted` per FR14n matrix row 1). `/bmad-create-story` drafted the file with 4 ACs, 4 Tasks (schema author / rationale-doc author / manifest+INVARIANTS register / quality gates+sync-gate smokes+sprint-status bump), Dev Notes, Project Structure Notes (alignment + DTCG-vs-typed-source variance documented), 13 References. AC 4 scope carve-out collapses epic's single-`INV-tokens-schema-contract` entry into two sibling entries (`INV-tokens-schema-contract` + `INV-tokens-semantic-rationale`) to preserve Story 1.8's single-`sourcePath`-per-`Invariant` shape. Sprint-status `1-10: backlog → ready-for-dev`.                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Ralph  |
| 2026-04-20 | 1.1     | Pre-dev SM review (Ralph, iter-43; `drafted → validated` per FR14n matrix row 2). Applied two critical fixes: (a) **AC 2 stable-ID alignment** — example ID corrected `TOKEN-motion-scale-snap` → `TOKEN-motion-snap` + added scope carve-out clarifying the epic's `motion.scale.*` / `density.scale.*` shorthand resolves to the dial (`TOKEN-motion-scale` / `TOKEN-density-scale`, leaves with `$type: number`) and tier siblings (`TOKEN-motion-{instant|snap|swift|smooth|drift}` / `TOKEN-density-{compact|default|comfortable}`, not nested three-segment IDs), matching architecture.md:693's two-segment `<category>.<semantic-name>` pattern and DTCG's group-node restriction. (b) **Task 4 sprint-status transition** — rewrote the `backlog → in-progress → review` phrasing to the canonical Ralph direct-jump pattern `ready-for-dev → done` at `/bmad-dev-story` completion (per Story 1.7 / 1.8 precedent — Ralph's FR14n owns the trace/SM-review/CR intermediates; BMad `in-progress → review` stage is skipped). Story-file Status terminal state corrected `review → done` in the same subtask. ACs 1, 3, 4 well-formed; scope carve-outs (AC 1 schema-vs-value separation + AC 4 two-entry manifest carve-out) intact; 13 References spot-validated. | Ralph  |
