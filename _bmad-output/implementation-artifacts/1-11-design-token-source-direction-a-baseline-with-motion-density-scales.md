# Story 1.11: Design-token source — Direction A baseline with motion + density scales

Status: ready-for-dev

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a UX designer,
I want the canonical token source populated with Direction A "The Instrument" values and global `motion.scale` + `density.scale` hierarchies in a single DTCG JSON file,
So that the substrate ships with a coherent opinionated visual baseline ready for Story 1.12's emitter pipeline + Epic 7 catalog + Epic 12 page templates + Epic 3 TUI consumption (UX-DR15, UX-DR9).

## Acceptance Criteria

1. **Given** the schema from Story 1.10 (`packages/ui/tokens.schema.json`),
   **When** I open the canonical token source file at `packages/ui/tokens.json`,
   **Then** the file validates against `tokens.schema.json` (every leaf carries `$type` + `$value`; every `$value` is a literal or `{alias}` reference; the eight root semantic groups `color | type | font | space | radius | motion | density | breakpoint` + the required `$modes` overlay with both `light` and `dark` are present; `additionalProperties: false` holds at every level)
   **And** every Direction A semantic-token value from `ux-design-specification.md` § Visual Design Foundation + § Design Direction Decision is populated with an OKLCH literal (colors) or `px` / `ms` / unitless-number literal (dimension / duration / number leaves) or `{alias}` reference (semantic aliases).

   **Story 1.11 scope carve-out — file-format ratification (resolves Story 1.10 § Project Structure Notes:169 variance).** The canonical source is `packages/ui/tokens.json` in DTCG JSON, **not** the typed TS variant `packages/keel-invariants/src/design-tokens.ts` named in architecture.md:915 / :1149 / :1216. Ratification rationale: (a) UX spec § Architecture of the Design System line 358 names `tokens.json` as "SOURCE OF TRUTH (DTCG format)" — the primary recommendation; (b) Story 1.10's schema was authored for the DTCG shape; (c) Story 1.12's emitter consumes DTCG JSON with `{alias}` syntax — LLM-parseable and schema-validatable without TS runtime overhead; (d) DTCG is an open W3C-CG standard consumable by external tooling (Tokens Studio, Style Dictionary) per UX-spec:350. The typed-TS path stays an explicit Growth-tier option; 1.0 ships DTCG JSON. Document this ratification in a top-of-file `$description` or leading comment block inside the JSON (JSON has no comments — use a top-level `"$schema"` + top-level `"$description"` field per DTCG convention, or a `_provenance` sibling object at the root; dev picks the DTCG-canonical form).

   **Story 1.11 scope carve-out — Direction A value precedence when ux-spec sections disagree.** The UX spec § Visual Design Foundation (lines 480–604) and § Design Direction Decision (lines 605–638) carry overlapping token-value guidance for the substrate default. Where the two disagree, **§ Design Direction Decision wins** because ux-spec:621 ratifies Direction A as substrate default. Known concrete disagreement: `accent.500` is `oklch(62% 0.16 245)` in § Visual Design Foundation (line 492; "pilot blue, deliberately desaturated" generic baseline) and `oklch(54% 0.18 245)` in § Design Direction Decision (line 613; Direction A table, "The Instrument" archetype, deeper + more saturated). Use the Direction A value (`54% 0.18 245`) unless WCAG AA contrast against `TOKEN-text-inverse` or `TOKEN-surface-default` rules it out; in that case capture the contrast math in § Dev Agent Record → Debug Log and fall back to the § Visual Design Foundation value (`62% 0.16 245`) as escape hatch. Document the chosen value and the rationale in the Debug Log for the SM-review audit trail.

   **Story 1.11 scope carve-out — font-family value shape.** `leafFontFamily` in `packages/ui/tokens.schema.json:73` uses the string regex pattern `^(\{[a-z][a-z0-9]*(\.[a-z0-9][a-z0-9-]*)+\}|[^{}]+)$`. DTCG additionally permits array-form (`["Inter", "system-ui", "sans-serif"]`) for multi-family stacks; the schema as-shipped rejects arrays. Story 1.11 populates `TOKEN-font-sans` + `TOKEN-font-mono` with comma-separated string values (e.g. `"Inter, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"`). Array-form support is deferred to a later story (already captured in `deferred-work.md` CR re-run iter-52 entry "leafFontFamily string-vs-array portability").

2. **Given** Direction A is the substrate default,
   **When** Directions B (GOV.UK-adjacent) and C (Developer-notebook) are referenced,
   **Then** they are **NOT** in this file
   **And** their preset overlays at `docs/design/presets/gov-uk-adjacent.tokens.json` + `docs/design/presets/developer-notebook.tokens.json` land in Epic 7 (not Epic 1).

   **Story 1.11 scope carve-out — B/C reference-preset deferral.** No files under `docs/design/presets/` are authored, modified, or referenced by this story. The reference-preset machinery (per-preset DTCG overlay file + `extends` fork-merge pattern from UX-spec:621) is Epic 7 scope. This AC is a **negative-space** constraint: verification is a filesystem absence check (`ls docs/design/presets/` returns no-such-directory or an empty directory).

3. **Given** motion + density,
   **When** I read the file,
   **Then** `motion.scale` defines at least the five tiers `instant | snap | swift | smooth | drift` with numeric duration values referenced by name
   **And** `density.scale` defines at least the three tiers `compact | default | comfortable` with numeric scale-factor values referenced by name
   **And** each tier has a numeric value (literal, not alias).

   **Story 1.11 scope carve-out — tier value sources.** Pin numeric defaults from `docs/invariants/tokens.md` § Motion (lines 116–125) and § Density (lines 127–134) rationale:
   - `TOKEN-motion-scale`: `$type: number` `$value: "1"` (dial default; `0` = reduced-motion at runtime via OS preference query, clamped in the emitter pipeline Story 1.12 — not in the source).
   - `TOKEN-motion-instant`: `$type: duration` `$value: "60ms"` (`≈ 60ms × scale`).
   - `TOKEN-motion-snap`: `$type: duration` `$value: "120ms"` (`≈ 120ms × scale`).
   - `TOKEN-motion-swift`: `$type: duration` `$value: "200ms"` (`≈ 200ms × scale`).
   - `TOKEN-motion-smooth`: `$type: duration` `$value: "320ms"` (`≈ 320ms × scale`).
   - `TOKEN-motion-drift`: `$type: duration` `$value: "500ms"` (`≈ 500ms × scale`).
   - `TOKEN-density-scale`: `$type: number` `$value: "1"` (reference; runtime-switchable per user preference or viewport class).
   - `TOKEN-density-compact`: `$type: number` `$value: "0.875"` (< 1.0; TUI default + data-heavy web views; ux-spec:555).
   - `TOKEN-density-default`: `$type: number` `$value: "1"` (reference).
   - `TOKEN-density-comfortable`: `$type: number` `$value: "1.125"` (> 1.0; reading views + accessibility-preferred; ux-spec:555).

   The dial (`motion.scale` / `density.scale`) is stored as a `leafNumber` literal per schema (`packages/ui/tokens.schema.json:295`, `:308`); tiers are literals (not aliases) because the tier × dial product is Story 1.12's emitter responsibility, not source-time pre-computation. This preserves dial independence across modes.

4. **Given** this file is the canonical input to Story 1.12's emitter,
   **When** Story 1.9's sync gate walks it,
   **Then** the file is registered under manifest ID `INV-tokens-source` at `packages/keel-invariants/src/invariants.manifest.ts`
   **And** both sides of the sync-gate contract (clean-path exit 0 on matched content-hash + anchor presence; drift-path exit 1 on content-hash-mismatch OR added-to-source-only OR removed-from-docs-only) are smoke-verified end-to-end
   **And** `INVARIANTS.md` carries a new `### Design-token source (Story 1.11)` section with a column-0 `- **\`INV-tokens-source\`**` anchor bullet.

   **Story 1.11 scope carve-out — "changes without matching emitted outputs fail pre-merge" is Story 1.13's scope, not this story's.** The epic AC 4 phrase "changes without matching emitted outputs fail pre-merge (Story 1.13)" spans two substrates: (a) the manifest-content-hash drift-detection (Story 1.9 — already shipped; this story exercises it with one new entry), and (b) the source-output-sync pre-commit gate that validates `tokens.json` matches emitted `tokens.css` / `tailwind.preset.ts` / `theme.py` byte-for-byte (Story 1.13 — not yet shipped; no emitter exists at Story 1.11 time because Story 1.12 authors it). Story 1.11 scope closes at (a): registers the source file in the manifest, verifies both clean-path and drift-path round-trips via the Story 1.9 sync-gate runtime, and leaves the output-sync gate for Stories 1.12 + 1.13 to wire.

   **Story 1.11 scope carve-out — single-entry manifest registration.** One manifest entry (`INV-tokens-source`) covers `packages/ui/tokens.json`. This differs from Story 1.10's two-entries-for-two-files pattern (`INV-tokens-schema-contract` + `INV-tokens-semantic-rationale`) because Story 1.11 ships exactly one new source file — the DTCG token source. The schema and rationale both already have entries from Story 1.10; Story 1.11 adds the third sibling.

## Tasks / Subtasks

- [ ] **Task 1: Author `packages/ui/tokens.json`** (AC: 1, 2, 3)
  - [ ] Create `packages/ui/tokens.json` at the repo-relative path named in ux-design-specification.md:358 — sibling to `packages/ui/tokens.schema.json` (Story 1.10), **not** under `packages/ui/src/`. Both files are data contracts consumed pre-TS-compilation; `src/` is reserved for TS source compiled into `dist/` via `tsc -b`.
  - [ ] Top-of-file provenance block (DTCG-canonical form): include at the JSON root a `"$schema"` pointer (`"./tokens.schema.json"` — relative self-reference validators recognise) plus a `"$description"` root-level string noting: file purpose, Direction A ratification (`"Direction A substrate default per ux-design-specification.md:621; file-format choice DTCG JSON per UX-spec:358 primary recommendation (Story 1.11 ratification)"`), Story 1.10's schema contract pointer, and a note that this file is consumed by Story 1.12's emitter and tracked by Story 1.9's sync-gate via `INV-tokens-source`.
  - [ ] Populate base (light-mode-default) values for every schema-required group + leaf. Use OKLCH literals for `$type: color` leaves (per ux-spec:484-497 + :613 Direction A table); `<N>px` literals for `$type: dimension` leaves; `<N>ms` literals for `$type: duration` leaves; unitless numeric strings for `$type: number` leaves (DTCG requires string `$value`); comma-separated-string literals for `$type: fontFamily` leaves (single-string per schema regex; array deferred per § AC 1 carve-out); `<N>` numeric-string literals (no unit) for `$type: fontWeight` leaves (unused at Story 1.11 — schema declares the leaf type but the default `font` group in the schema root does not require fontWeight tokens; only `sans` + `mono` `fontFamily` leaves are schema-required); cubic-bezier literals for `$type: cubicBezier` leaves (unused at Story 1.11 for same reason).
  - [ ] **Color group inventory** (per `packages/ui/tokens.schema.json:112-232` + `docs/invariants/tokens.md` § Rationale index):
    - `color.neutral.{50..950}` — 11-step true-neutral OKLCH ramp per ux-spec:486-488 + Direction A "true neutral" per :613. Light end `oklch(99% 0 0)` → dark end `oklch(8% 0 0)`; chroma held at `0` throughout (Direction A specifies true-neutral, not warm-tinted). Intermediate stops (100, 200, ..., 900) interpolate monotonically; use perceptually-even spacing (ux-spec:488 "perceptually uniform steps"). Reference stop-to-lightness mapping: `50`→99%, `100`→96%, `200`→90%, `300`→80%, `400`→65%, `500`→52%, `600`→42%, `700`→30%, `800`→20%, `900`→13%, `950`→8%. Literal form: `"oklch(99% 0 0)"`.
    - `color.accent.{400|500|600|default|fg|focus}` — Direction A ratifies `accent.500 = oklch(54% 0.18 245)` per ux-spec:613 (see § AC 1 carve-out for precedence rule vs foundation:492's `oklch(62% 0.16 245)`). Extrapolate `accent.400` (focus ring, lighter primitive — target `≈ oklch(62% 0.16 245)` with hue held at 245) and `accent.600` (hover / pressed primitive, darker — target `≈ oklch(46% 0.18 245)`). Semantic aliases: `accent.default = {color.accent.500}`, `accent.focus = {color.accent.400}`, `accent.fg = oklch(99% 0 0)` (white-on-accent foreground; AA-tested against `accent.500`).
    - `color.surface.{default|raised|inset|overlay}` — light-mode aliases into the neutral ramp per tokens.md § Surfaces (lines 56–61): `surface.default = {color.neutral.50}`, `surface.raised = {color.neutral.100}`, `surface.inset = {color.neutral.100}` (tokens.md:60 "slightly darker than default in light mode" — interpret as `neutral.100` vs `default`'s `neutral.50`), `surface.overlay = {color.neutral.50}` (overlay reads floats-above-everything; visual separation supplied by `border.default` + shadow). Dark-mode overrides land in `$modes.dark` below.
    - `color.text.{primary|secondary|muted|inverse|accent}` — light-mode: `text.primary = {color.neutral.950}` (AAA 7:1 body copy per tokens.md:65), `text.secondary = {color.neutral.700}` (AA 4.5:1), `text.muted = {color.neutral.500}` (AA-optional per tokens.md:67), `text.inverse = {color.neutral.50}` (white-on-dark surfaces), `text.accent = {color.accent.default}`.
    - `color.border.{default|muted|accent}` — light-mode: `border.default = {color.neutral.200}`, `border.muted = {color.neutral.100}`, `border.accent = {color.accent.focus}`.
    - `color.status.{info|success|warning|error|critical}.{fg|bg}` — each status slot has a foreground (higher-chroma, AA-tested against its bg) + a background (lightweight tint). OKLCH hue targets per ux-spec:497: info ≈ blue (hue 220), success ≈ green (hue 145), warning ≈ amber (hue 75), error ≈ red (hue 25), critical ≈ deep red (hue 15, stronger chroma than error). Representative light-mode values (dev picks exact OKLCH with AA-math as the gate): `status.info.fg = oklch(52% 0.14 230)`, `status.info.bg = oklch(95% 0.03 230)`, `status.success.fg = oklch(50% 0.15 145)`, `status.success.bg = oklch(94% 0.04 145)`, `status.warning.fg = oklch(58% 0.14 75)`, `status.warning.bg = oklch(95% 0.06 75)`, `status.error.fg = oklch(52% 0.18 25)`, `status.error.bg = oklch(94% 0.04 25)`, `status.critical.fg = oklch(45% 0.20 15)`, `status.critical.bg = oklch(92% 0.05 15)`. Any AA-miss captured in Debug Log with a specific-pair contrast-math note; use the fallback pattern from § AC 1 Direction-A carve-out.
    - `color.severity.{low|medium|high|critical}` — aliases per tokens.md:102-105: `severity.low = {color.status.info.fg}`, `severity.medium = {color.status.warning.fg}`, `severity.high = {color.status.error.fg}`, `severity.critical = {color.status.critical.fg}`. These are alias-only leaves (`$value` is `{color.status.<X>.fg}`; no literal).
    - `color.state.{pending|in-progress|blocked|done}` — kanban vocabulary per tokens.md:107-114. Aliases into status/accent families: `state.pending = {color.status.info.fg}` (neutral-cool; "queued"), `state.in-progress = {color.accent.default}` (accent; "actively being worked"), `state.blocked = {color.status.warning.fg}` (warning-family; "cannot proceed"), `state.done = {color.status.success.fg}` (success-family; "complete").
  - [ ] **Typography group inventory** (schema `packages/ui/tokens.schema.json:234-247` + ux-spec:528-530):
    - `type.xs = "12px"`, `type.sm = "14px"`, `type.base = "16px"`, `type.lg = "18px"`, `type.xl = "20px"`, `type.2xl = "24px"`, `type.3xl = "30px"`, `type.4xl = "36px"`. Each `$type: dimension`. Ratio is 1.125 (modular major-second per ux-spec:528).
  - [ ] **Font group inventory** (schema `:249-257` + ux-spec:524-525):
    - `font.sans = "Inter, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Helvetica Neue', sans-serif"` (comma-separated string per § AC 1 carve-out).
    - `font.mono = "'JetBrains Mono', 'Fira Code', 'SF Mono', Menlo, Consolas, monospace"`.
  - [ ] **Space group inventory** (schema `:258-277` + ux-spec:547):
    - 4px-base Tailwind default. `space.0 = "0px"`, `space.1 = "4px"`, `space.2 = "8px"`, `space.3 = "12px"`, `space.4 = "16px"`, `space.5 = "20px"`, `space.6 = "24px"`, `space.8 = "32px"`, `space.10 = "40px"`, `space.12 = "48px"`, `space.16 = "64px"`, `space.20 = "80px"`, `space.24 = "96px"`. Each `$type: dimension`.
  - [ ] **Radius group inventory** (schema `:278-289` + ux-spec:551):
    - `radius.none = "0px"`, `radius.sm = "4px"`, `radius.md = "8px"`, `radius.lg = "12px"`, `radius.full = "9999px"` (pill). Each `$type: dimension`.
  - [ ] **Motion group inventory** (schema `:290-301` + § AC 3 values + tokens.md:116-125):
    - `motion.scale = "1"` (`$type: number`; dial default; `0` = reduced-motion set at runtime).
    - `motion.instant = "60ms"`, `motion.snap = "120ms"`, `motion.swift = "200ms"`, `motion.smooth = "320ms"`, `motion.drift = "500ms"`. Each `$type: duration`.
  - [ ] **Density group inventory** (schema `:303-312` + § AC 3 values + tokens.md:127-134):
    - `density.scale = "1"` (`$type: number`; dial default).
    - `density.compact = "0.875"`, `density.default = "1"`, `density.comfortable = "1.125"`. Each `$type: number`.
  - [ ] **Breakpoint group inventory** (schema `:314-324` + ux-spec:560):
    - `breakpoint.sm = "640px"`, `breakpoint.md = "768px"`, `breakpoint.lg = "1024px"`, `breakpoint.xl = "1280px"`, `breakpoint.2xl = "1536px"`. Each `$type: dimension`.
  - [ ] **`$modes.light` overlay** — per schema `:326-334`, `light` is required. Light is the base per file design; therefore `$modes.light` is an **empty-ish** sparse overlay (e.g. `{}` or omit it — but the schema `:329` requires the key). Populate with an empty `{}` to satisfy the required property; the base-file values ARE the light-mode values (this is the canonical DTCG pattern where the base file is one mode and `$modes.<other>` carries deltas).
  - [ ] **`$modes.dark` overlay** — re-map only the color slots that differ from light. Mandatory remaps (per tokens.md § Surfaces + § Text rationales + ux-spec:484 "Light + dark modes carried in a single DTCG file via modes"):
    - `color.surface.default = {color.neutral.950}` (dark base)
    - `color.surface.raised = {color.neutral.900}`
    - `color.surface.inset = {color.neutral.900}` (inset in dark mode reads slightly *lighter* than default per raised-vs-inset contrast logic — if dev maths differently with contrast constraints, capture in Debug Log)
    - `color.surface.overlay = {color.neutral.900}`
    - `color.text.primary = {color.neutral.50}`
    - `color.text.secondary = {color.neutral.200}`
    - `color.text.muted = {color.neutral.400}`
    - `color.text.inverse = {color.neutral.950}`
    - `color.border.default = {color.neutral.800}`
    - `color.border.muted = {color.neutral.900}`
    - `color.accent.fg = {color.neutral.50}` (white-on-accent holds in dark mode against `accent.500`)
    - Status `bg` variants (light-tinted in light mode) need dark-mode equivalents (dark-tinted — higher chroma against dark surface); keep `fg` values equal across modes (they're saturated enough to hold AA against either light or dark surface, but dev verifies contrast per pair).
  - [ ] Do NOT populate an `$modes.high-contrast` overlay at Story 1.11; the schema permits it optionally (`:330`) but Story 1.11's scope is light + dark only. A later story can add high-contrast.

- [ ] **Task 2: Validate `packages/ui/tokens.json` against `packages/ui/tokens.schema.json`** (AC: 1, substrate verification)
  - [ ] Run schema validation as a **one-shot evidence capture** during dev: `pnpm dlx ajv-cli@5 validate -s packages/ui/tokens.schema.json -d packages/ui/tokens.json --spec=draft2020 --all-errors`. Expected: `packages/ui/tokens.json valid`. Zero errors. Any validation failure blocks Story 1.11's `in-dev → traced` transition.
  - [ ] If `ajv-cli` draft-2020 support is incomplete in the latest release (known upstream lag), fall back to a one-shot Node inline validator: `pnpm dlx tsx -e "..."` with `@apidevtools/json-schema-ref-parser` + manual draft-2020 walk — or `pnpm dlx @hyperjump/json-schema-cli` (supports draft-2020). Capture the exact tooling invocation + output in § Dev Agent Record → Completion Notes.
  - [ ] **Do NOT add `ajv` or `ajv-cli` to `package.json` devDependencies** at Story 1.11 time. The formal pre-commit schema-validation gate lands in Story 1.13 and will pin its own validator (`ajv` + `ajv-formats` or `@hyperjump/json-schema`, decided by Story 1.13). Story 1.11's one-shot `pnpm dlx` invocation is evidence-only — no dependency growth, no package.json churn.
  - [ ] **Do NOT commit a schema-validation script or npm script** to this story. Story 1.13 owns the pre-commit gate + the committed validator invocation + the `pnpm tokens:validate` (or equivalent) npm script name. Keeping the validator evidence-only here avoids pre-specifying Story 1.13's interface.

- [ ] **Task 3: Register `INV-tokens-source` in the invariants manifest + `INVARIANTS.md`** (AC: 4)
  - [ ] Compute `sha256sum packages/ui/tokens.json` post-Task 1 (and post-prettier-format, since prettier may touch JSON formatting — run `pnpm exec prettier --write packages/ui/tokens.json` BEFORE computing the hash to lock the canonical byte-form).
  - [ ] Append one entry to `packages/keel-invariants/src/invariants.manifest.ts` → `raw` array (after the last entry `INV-tokens-semantic-rationale` at line 136; maintain trailing comma + array closure):
    ```typescript
    {
      id: 'INV-tokens-source',
      description:
        'Direction A design-token source — DTCG JSON file populated with every semantic + primitive token value per ux-design-specification.md § Visual Design Foundation + § Design Direction Decision. Light + dark mode overlays; motion + density tier hierarchies; aliases into neutral ramp + accent ramp + status/severity/state families. Consumed by Story 1.12 emitter (web CSS + Tailwind preset + TUI theme); validated against INV-tokens-schema-contract by Story 1.13 pre-commit gate.',
      sourcePath: 'packages/ui/tokens.json',
      contentHash: '<sha256 from sha256sum invocation above>',
      anchors: ['INV-tokens-source'],
    },
    ```
  - [ ] Append one sibling anchor to `INVARIANTS.md` under a new `### Design-token source (Story 1.11)` section (insert between the existing `### Design-token schema + semantic rationale (Story 1.10)` section at `INVARIANTS.md:48-51` and the `## Consumption` section at `INVARIANTS.md:53`). Anchor format MUST match the existing Story-1.10 bullet shape (`- **\`INV-tokens-source\`** — <description>. Source: \`packages/ui/tokens.json\`.`) at **column 0** (non-indented — Story 1.9's `ANCHOR_REGEX` at `packages/keel-invariants/src/sync-gate.ts:24` binds column-0 opening bullets per tokens-schema-contract iter-14 defer).
  - [ ] **Forbidden** — same rules as Story 1.10 Task 3: no anchors inside triple-backtick code fences (Story 1.9 CR defer iter-14; `deferred-work.md:38`); use inline backticks (`` `INV-tokens-source` ``) in prose anywhere outside the column-0 anchor bullet.
  - [ ] Verify: `pnpm -w typecheck` — Zod `InvariantsSchema.parse(raw)` at import time validates the new entry (id regex / sha256-hex-length regex / anchors non-empty / sourcePath-traversal refine / ID-uniqueness superRefine / shared-sourcePath cross-hash consistency superRefine). Any malformed field fails the typecheck loudly at first import.
  - [ ] **Scoped build before sync-gate check** (Story 1.10 iter-51 lesson): after manifest mutation, run `pnpm --filter @keel/keel-invariants build` to regenerate `packages/keel-invariants/dist/check.js` BEFORE `pnpm keel-invariants:check` (`pnpm keel-invariants:check` runs the compiled `dist/check.js`, not the TS source — without the rebuild the gate reports stale hash drift for the OLD manifest state). This is ~10× faster than full-workspace `pnpm -w build` when only the invariants package changed.

- [ ] **Task 4: Quality gates + sync-gate smokes + sprint-status bump** (no AC — substrate verification)
  - [ ] `pnpm install` at repo root — **expect zero new deps** (JSON file + manifest entry only; schema validator is `pnpm dlx` one-shot per Task 2). Confirm lockfile unchanged: `git diff --stat pnpm-lock.yaml` → empty.
  - [ ] `pnpm -w typecheck` — green (existing passes + Task 3 import-time Zod validation covers the new manifest entry).
  - [ ] `pnpm -w lint` — green (no new TS source; ESLint walks JSON only if a JSON plugin is wired — not at Story 1.11 time; lint scope unchanged).
  - [ ] `pnpm -w build` — green (rebuilds `@keel/keel-invariants` `dist/check.js` with the new manifest entry; `@keel/ui` dist unchanged since `tokens.json` is data not TS).
  - [ ] `pnpm format:check` — green (run `pnpm exec prettier --write packages/ui/tokens.json packages/keel-invariants/src/invariants.manifest.ts INVARIANTS.md` first to normalise formatting — then re-compute the `sha256sum packages/ui/tokens.json` from Task 3 if prettier touched it, and update the manifest `contentHash` if it changed; re-run typecheck + build after the hash update; do NOT commit two separate "re-hash" commits — landing the final settled hash in one atomic commit is the pattern).
  - [ ] `pnpm exec commitlint --from origin/main --to HEAD --verbose` — green on any commits made during this story.
  - [ ] `pnpm exec prek run --all-files` — 3 hooks Pass (typecheck / lint / format-check).
  - [ ] **Sync-gate smoke (clean path, AC 4 end-to-end):** `pnpm keel-invariants:check` → exit 0 on the post-Task-3 state. Zero stderr output. Confirms the new `INV-tokens-source` entry pairs cleanly with its `INVARIANTS.md` anchor AND the recomputed `sha256sum packages/ui/tokens.json` matches the manifest `contentHash`.
  - [ ] **Sync-gate smoke (content-hash-mismatch drift, AC 4 first branch):** append a single trailing newline to `packages/ui/tokens.json` (`echo "" >> packages/ui/tokens.json`); re-run `pnpm keel-invariants:check` → exit 1 + structured JSON drift report on stderr naming `INV-tokens-source` as `content-hash-mismatch` with the `{expected, actual}` hash pair. Revert with `pnpm exec prettier --write packages/ui/tokens.json` (restores canonical byte-form; `git checkout -- packages/ui/tokens.json` also works here because the file is committed at this point, unlike Story 1.10's new-untracked-file case). Post-revert: `sha256sum` equals manifest `contentHash`; re-run `pnpm keel-invariants:check` → exit 0. Capture evidence (pre-drift hash, post-drift hash, drift JSON excerpt, post-revert exit code) in § Completion Notes.
  - [ ] **Sync-gate smoke (added-to-source-only drift, AC 4 second branch):** delete the `INV-tokens-source` anchor bullet from `INVARIANTS.md` (use a targeted `sed -i '/\*\*`INV-tokens-source`\*\*/d' INVARIANTS.md` OR a targeted Edit-tool call — Story 1.10 iter-45 Lesson: the literal-string `node -e filter` pattern is over-broad if another bullet mentions the ID in prose; use a stricter anchor-pattern match OR temporarily `cp INVARIANTS.md /tmp/INVARIANTS.md.bak` as revert insurance). Re-run `pnpm keel-invariants:check` → exit 1 + `added-to-source-only` drift naming `INV-tokens-source` + `sourcePath packages/ui/tokens.json`. Revert via `git checkout -- INVARIANTS.md` (file is tracked). Post-revert rerun → exit 0. Capture evidence in § Completion Notes.
  - [ ] **Sync-gate smoke (removed-from-source-only drift, AC 4 third branch — OPTIONAL, skip if iter time-budget tight):** comment out the `INV-tokens-source` entry in `packages/keel-invariants/src/invariants.manifest.ts` (leave the file valid TS); re-run `pnpm --filter @keel/keel-invariants build` + `pnpm keel-invariants:check` → exit 1 + `removed-from-source-only` drift naming `INV-tokens-source`. Revert with `git checkout -- packages/keel-invariants/src/invariants.manifest.ts`. This branch is already covered by Story 1.9's sync-gate AC 2 per the 1-9 trace artefact; Story 1.11 re-covers it for defense-in-depth if iter budget allows. Skip-rationale (if skipped): "sync-gate removed-from-source-only branch already proven at Story 1.9 iter-20 drift-smoke; Story 1.11 re-smoke is duplicate coverage; captured in § Completion Notes."
  - [ ] Bump `_bmad-output/implementation-artifacts/sprint-status.yaml`: `1-11-design-token-source-direction-a-baseline-with-motion-density-scales: ready-for-dev → done` (direct jump at `/bmad-dev-story` completion; skipped the `in-progress → review` BMad intermediate per Story 1.7 / 1.8 / 1.10 precedent — Ralph's FR14n lifecycle owns the trace / SM-review / CR gates that follow this dev-completion commit). `last_updated: 2026-04-20 Story-1-11-done UTC` (both the header-comment at `:2` AND the data-field at `:38`; Story 1.10 iter-48 Lesson — both sites must update or Story 1.9 sync-gate reports mismatched timestamps indirectly via file staleness heuristics). Preserve all existing comments + structure + STATUS DEFINITIONS block. The `backlog → ready-for-dev` hop already landed at `/bmad-create-story` time (iter-53); this Task covers only the `ready-for-dev → done` side.
  - [ ] Flip this story file's `Status:` to `done` at `/bmad-dev-story` completion (per Story 1.7 / 1.8 / 1.10 precedent — BMad `Status: done` is the terminal state in the story file; Ralph's FR14n `atdd-scaffolded → in-dev → traced → sm-verified → done` intermediates run in parallel via IP § Context state tracking, not story-file Status). All Task subtasks `[x]`. `## Dev Agent Record` populated with File List + Completion Notes + Debug Log References.

## Dev Notes

- **Relevant architecture patterns:**
  - **Three-layer invariant pattern applied to design tokens** (architecture.md:85 + Story 1.10 Dev Notes). Story 1.11 ships the *source-layer value population* (this file) that consumes Story 1.10's *source-layer contract* (schema + rationale). Story 1.12 ships the *runtime-layer* (generated `tokens.css` + `tailwind.preset.ts` + `theme.py`). Story 1.13 ships the *machine-enforced gates* (schema validation + contrast check + source-output sync).
  - **Cross-runtime semantic tokens** (architecture.md:90). Token names must work in both the Tailwind class vocabulary (`text-status-success`, `bg-surface-raised`) AND the Textual style vocabulary (`$status-success`, `$surface-raised`) AND Epic 7's component catalog header rows. Values populated here flow into all three runtimes via Story 1.12's emitter. Story 1.11 does NOT pick Tailwind class names or Textual style variable names — the emitter owns that mapping; this story populates semantic *values* against the schema's *shape*.
  - **DTCG format specifically** (ux-design-specification.md:350). W3C-CG standard; consumable by external tooling (Tokens Studio, Style Dictionary, Specify, Figma plugins — Keel does not pick a tool; Keel picks a format). Story 1.11 ratifies DTCG JSON as the 1.0 source format (per § AC 1 scope carve-out).
  - **Design-token ID pattern** (architecture.md:693). Format: `<category>.<semantic-name>.<modifier?>`. Schema + rationale doc both follow this; this story preserves both conventions in the `tokens.json` path structure. Primitives (`color.neutral.500`, `type.base`) and semantics (`color.surface.raised`, `color.status.success.fg`) coexist in the same tree — schema already declares this at Story 1.10 time.
  - **W1 party-mode amendment** (epics.md:653-661). Design tokens are substrate, not Epic 7 scope. The source-population step (Story 1.11) lands in Epic 1 so Ralph's TUI + Epic 5 generator + Epic 12 shape-aware templates consume values from day one — no retcon.

- **Source-tree components to touch:**
  - `packages/ui/tokens.json` — **NEW**. DTCG JSON file with every Direction A value + light/dark modes.
  - `packages/keel-invariants/src/invariants.manifest.ts` — APPEND 1 entry. `raw` array grows from 12 → 13 invariants.
  - `INVARIANTS.md` — APPEND 1 new `###` section with 1 anchor bullet.
  - `_bmad-output/implementation-artifacts/sprint-status.yaml` — state bump (`1-11-...: ready-for-dev → done`; `last_updated` both header-comment + data-field).
  - `_bmad-output/implementation-artifacts/1-11-design-token-source-direction-a-baseline-with-motion-density-scales.md` (this file) — Status flip + Dev Agent Record population + Change Log row.
  - Zero changes to: `packages/ui/tokens.schema.json` (Story 1.10 frozen), `docs/invariants/tokens.md` (Story 1.10 frozen — Story 1.11 consumes, does not mutate), `packages/keel-invariants/src/sync-gate.ts` (Story 1.9 frozen), any other package source. Mutating those would be a scope violation captured at § SM review.

- **Direction A value precedence — resolution trace** (iter-43 three-point audit, preventative):
  - **Stable-ID cross-check** (iter-43 Lesson): every AC-named token ID cross-checks against Task 1 subtask schema structure AND architecture.md:693's `<category>.<semantic-name>.<modifier?>` ID pattern AND tokens.md § Rationale index. Two-segment IDs for motion/density tiers (`TOKEN-motion-snap`, `TOKEN-density-compact`) — three-segment forms like `TOKEN-motion-scale-snap` are ruled out per tokens.md:39-46 + Story 1.10 AC 2 carve-out. Status fg/bg modifiers are three-segment (`TOKEN-status-success-fg`); matches the `<category>.<semantic-name>.<modifier>` pattern with `modifier ∈ {fg, bg}`.
  - **Task-enumeration-vs-schema-enumeration diff** (iter-47 Lesson): Task 1 subtasks enumerate every schema-required group + leaf. Cross-check the schema's root-object `required` array (`packages/ui/tokens.schema.json:8` — 8 top-level groups) AND every nested `required` array (color.{neutral|accent|surface|text|border|status|severity|state} + status.{info|success|warning|error|critical}.{fg|bg} + status/surface/text/border leaves + space stops + type stops + font.{sans|mono} + motion/density tiers + radius stops + breakpoint stops + $modes.{light|dark}) — Task 1 subtask list (~170 lines) covers every schema-required leaf. If a schema-required leaf is missing from Task 1, flag as pre-dev-review fix (raised by `/bmad-create-story (args: "review")` at iter-54; not a post-dev SM finding).
  - **Sprint-status transition wording correction** (iter-43 Lesson): Task 4 uses the direct-jump wording `ready-for-dev → done` (NOT BMad template's `in-progress → review`). BMad template default is pre-corrected here at drafting time — no iter-54 pre-dev fix needed for this class.

- **Semantic token inventory recap** (authoritative: `docs/invariants/tokens.md` § Rationale index + `packages/ui/tokens.schema.json`; re-stated here compactly for dev-agent ergonomics):
  - **11 neutral-ramp stops** (50..950).
  - **6 accent** slots (3 primitive ramp: 400/500/600 + 3 semantic: default/fg/focus; semantic aliases reference primitives).
  - **4 surface** slots (default/raised/inset/overlay).
  - **5 text** slots (primary/secondary/muted/inverse/accent).
  - **3 border** slots (default/muted/accent).
  - **5 status** slots × **2 modifiers** (fg/bg) = **10 status leaves**.
  - **4 severity** alias slots.
  - **4 state** alias slots.
  - **8 type-scale** stops.
  - **2 font-family** slots (sans/mono).
  - **13 space** stops (0,1,2,3,4,5,6,8,10,12,16,20,24).
  - **5 radius** slots (none/sm/md/lg/full).
  - **1 motion-scale dial + 5 motion tiers** (instant/snap/swift/smooth/drift) = 6 motion leaves.
  - **1 density-scale dial + 3 density tiers** (compact/default/comfortable) = 4 density leaves.
  - **5 breakpoint** stops (sm/md/lg/xl/2xl).
  - **2 mode overlays** (light + dark; light is empty since base = light).
  - **Total: ~86 populated value leaves** (approximate; primitive ramps + semantic aliases count; aliases resolve at emission time in Story 1.12). The count is approximate because some slots are aliases (severity / state / $modes.light), which carry a `$value` string but not a literal.

- **Schema validation strategy at Story 1.11 time** (iter-54 may surface an AC-1 evidence-capture completeness question):
  - Story 1.11's AC 1 requires the file to "validate against `tokens.schema.json`". No ajv-family validator is installed at Story 1.11 time (package.json devDependencies: commitlint / eslint / prek / prettier / turbo / typescript / tseslint; ajv not present).
  - **Dev approach**: one-shot `pnpm dlx ajv-cli@5 validate ...` (Task 2) captures evidence in § Completion Notes without growing `devDependencies`. The formal pre-commit schema-validation gate is Story 1.13 — it pins its own validator + npm script interface.
  - **Fallback**: if `ajv-cli@5` fails on draft-2020 (known upstream lag as of 2026-Q1), fall back to `pnpm dlx @hyperjump/json-schema-cli` or a one-shot `pnpm dlx tsx -e "..."` with `@apidevtools/json-schema-ref-parser`. Document whichever works in § Completion Notes (Story 1.13 will revisit the validator choice at its pre-commit-gate authoring time).
  - **Non-goal**: no committed npm script (`"tokens:validate": "..."`), no committed validator dependency, no pre-commit hook wire-up. Those land in Story 1.13. Story 1.11 is **evidence-only** for the validation side.

- **Testing standards summary** (Story 1.10 precedent + architecture.md:650-652):
  - **No test runner at Story 1.11 time** (lands Story 1.16). Verification is substrate-layer: `pnpm -w {typecheck,lint,build,format:check}` + `pnpm exec prek run --all-files` + `pnpm keel-invariants:check` (Story 1.9 runtime tool) + one-shot schema-validation (Task 2).
  - **Sync-gate smoke** (AC 4) is the end-to-end evidence for this story — analogous to Story 1.10 Task 4 smoke patterns. Two smoke branches required (content-hash-mismatch + added-to-source-only); the removed-from-source-only branch is OPTIONAL (already proven at Story 1.9 Task 5 and Story 1.10 precedent; re-smoke is defense-in-depth if iter budget allows). Byte-identical round-trip is the pass criterion.
  - **Deferred unit + integration tests**: once Story 1.16 lands the test runner, backfill per-AC unit tests can verify: (a) AC 1 — every Direction A value matches ux-spec (snapshot test), schema-validation exit 0 in a red-phase "malform + expect validator error" variant; (b) AC 2 — `docs/design/presets/` empty-or-absent assertion; (c) AC 3 — tier-enumeration assertion (count + names); (d) AC 4 — sync-gate smoke in a test harness. None of these block Story 1.11's `review → done` transition. Adversarial coverage of AC 1 value-correctness + AC 3 tier-enumeration is provided by `/bmad-code-review (args: "2")`'s Blind Hunter / Edge Case Hunter / Acceptance Auditor fan-out (mirrors Story 1.10 iter-44 hybrid ground-(c) ATDD-skip rationale).

### Project Structure Notes

- **Alignment with unified project structure.** `packages/ui/tokens.json` follows ux-design-specification.md:358 exactly (`tokens.json ← SOURCE OF TRUTH (DTCG format)`). Sibling to Story 1.10's `packages/ui/tokens.schema.json`.
- **Resolved variance from Story 1.10 § Project Structure Notes.** Story 1.10 flagged the architecture.md:915 / :1216 / :1149 typed-TS-variant path (`packages/keel-invariants/src/design-tokens.ts`) as a deferred decision. Story 1.11 AC 1 scope carve-out **ratifies** the DTCG JSON path (`packages/ui/tokens.json`) as the 1.0 substrate default — the typed-TS path is explicitly *not* closed off; Growth-tier forks can add a typed-TS companion, but 1.0 ships DTCG JSON. Documented in the file's top-level `$description` per Task 1 provenance block.
- **No conflict** with Story 1.8 manifest shape — per § AC 4 scope carve-out, the one-new-file-one-new-entry convention preserves the single-`sourcePath` `Invariant` contract pinned at `packages/keel-invariants/src/invariants.manifest.ts:6-11`. The manifest grows from 12 (post-Story-1.10) to 13 entries.
- **Ralph L1/L2 layering** (architecture.md:786-788 + `.ralph-safe-set.yaml` — not yet landed; Story 3.24 scope). `packages/ui/tokens.json` is L3 lint-guarded at Story 1.11 time (standard substrate data file; no Ralph self-modification risk). When Story 3.24's safe-set manifest lands, this file can be registered as L3 if desired (candidate class — mutation velocity is low once populated; Epic 7 preset overlays mutate separate fork files, not this one).

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story-1.11-Design-token-source] — lines 954–981 — primary ACs + dial-vs-tier shape.
- [Source: _bmad-output/planning-artifacts/epics.md#Epic-1-Substrate-Foundation] — lines 635–666 — W1/W2 amendment rationale; token-source-population positioning as substrate.
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Architecture-of-the-Design-System] — lines 340–398 — DTCG source-of-truth decision; file-path table; customization + extension strategy.
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Visual-Design-Foundation] — lines 480–604 — complete semantic token inventory (color / typography / spacing / radius / density / motion / breakpoints) + Direction A generic-baseline values.
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Design-Direction-Decision] — lines 605–638 — Direction A ratification as substrate default; per-direction accent/density/corner values; reference-preset handoff (Epic 7).
- [Source: _bmad-output/planning-artifacts/architecture.md#Design-token-ID-Pattern] — lines 691–695 — `<category>.<semantic-name>.<modifier?>` ID format; cross-runtime stable-ID contract.
- [Source: _bmad-output/planning-artifacts/architecture.md#Three-layer-invariant-pattern] — lines 85–90 — cross-runtime semantic tokens invariant.
- [Source: _bmad-output/implementation-artifacts/1-10-design-token-schema-semantic-rationale-contract.md] — Story 1.10 schema contract shape + INV-tokens-schema-contract / INV-tokens-semantic-rationale manifest entries that Story 1.11 consumes; § Dev Agent Record Debug Log + iter-45..52 precedent patterns (drift-smoke conventions, scoped-build optimisation, content-hash sync pattern).
- [Source: _bmad-output/implementation-artifacts/1-9-invariant-sync-gate-runtime-tooling-reader-walker-drift-detector.md] — sync-gate runtime tool + smoke-test pattern; `pnpm keel-invariants:check` entry point; three drift branches proven.
- [Source: _bmad-output/implementation-artifacts/1-8-invariants-manifest-ts-contract-exporter.md] — `Invariant` interface + `InvariantSchema` precedent; 10-entry canonical list (grown to 12 at Story 1.10, 13 at Story 1.11).
- [Source: packages/ui/tokens.schema.json] — the schema this file validates against; every required leaf + group listed above.
- [Source: docs/invariants/tokens.md] — rationale index with every `TOKEN-<slug>` + semantic purpose + "Story 1.11 populates" placeholder per token; Story 1.11's authoring traces rationale-intended values into DTCG `$value` literals or aliases.
- [Source: packages/keel-invariants/src/invariants.manifest.ts] — `raw` array append site; Zod `InvariantSchema` + `InvariantsSchema` validation (regex + refine + superRefine layers).
- [Source: packages/keel-invariants/src/sync-gate.ts:24] — `ANCHOR_REGEX` column-0 bullet form — required anchor shape in `INVARIANTS.md`.
- [Source: INVARIANTS.md] — section-heading convention (`### <topic> (Story N.M)`); anchor bullet shape; `### Design-token schema + semantic rationale (Story 1.10)` precedent (lines 48-51).
- [Source: _bmad-output/implementation-artifacts/deferred-work.md] — Story 1.9 + Story 1.10 carry-forward defers: anchor-regex column-0 binding + code-fence footgun (avoid both in the new `INVARIANTS.md` section); `leafFontFamily` string-vs-array portability deferred to post-Story-1.11.
- [Source: RALPH.md] — iter-42..52 Story 1.10 signposts establishing authoring + dev + trace + SM-review + CR patterns that Story 1.11 inherits (iter-43 three-point audit; iter-47 Task-enumeration-vs-schema-enumeration diff; iter-51 scoped-build optimisation; iter-52 halving-to-zero CR trajectory hypothesis for contract-populator stories).

## Change Log

| Version | Date       | Author         | Change                                                                                                                                                                                                     |
| ------- | ---------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| v1.0    | 2026-04-20 | Ralph (iter-53) | Initial draft via `/bmad-create-story`. 4 ACs (schema-valid Direction A population / Directions B+C excluded / motion + density tier numerics / `INV-tokens-source` manifest registration + sync-gate). 4 Tasks (author `packages/ui/tokens.json` / schema-validate one-shot / register in manifest + INVARIANTS / quality gates + 2-3 sync-gate smokes + sprint-status bump). Preventative three-point pre-dev audit applied at drafting time: stable-IDs cross-checked (motion/density two-segment forms; status fg/bg three-segment modifiers); Task 1 subtask list mirrors every schema-required leaf (86-leaf enumeration); sprint-status transition wording pre-corrected to `ready-for-dev → done` direct-jump. File-format ratification DTCG JSON @ `packages/ui/tokens.json` per AC 1 scope carve-out (resolves Story 1.10 § Project Structure Notes:169 variance). Direction A value precedence rule pinned (Chosen Direction wins when it disagrees with Visual Design Foundation; concrete known case is `accent.500` = `oklch(54% 0.18 245)` per :613). Sprint-status: `1-11-...: backlog → ready-for-dev`; `last_updated: 2026-04-20 Story-1-11-ready-for-dev UTC`. |

## Dev Agent Record

### Agent Model Used

_(to be populated at `/bmad-dev-story` execution time)_

### Debug Log References

_(to be populated at `/bmad-dev-story` execution time — expected entries: Direction A value-precedence resolution for `accent.500` + any other foundation-vs-direction-A disagreements; `ajv-cli@5` vs `@hyperjump/json-schema-cli` validator tool choice rationale; WCAG AA contrast math for any status `fg`/`bg` pair that fails the reference-value targets and needs OKLCH retuning; dark-mode `$modes.dark` overlay scope decisions where tokens.md rationale is ambiguous; drift-smoke evidence captures per Task 4)_

### Completion Notes List

_(to be populated at `/bmad-dev-story` execution time — expected entries: schema-validator tool + command + output; sync-gate smoke evidence blocks (pre-drift hash, post-drift hash, drift JSON excerpt, post-revert exit code) for each of the 2-3 smoke branches)_

### File List

_(to be populated at `/bmad-dev-story` execution time)_
