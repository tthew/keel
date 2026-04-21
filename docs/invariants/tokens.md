# Invariant — Design-Token Semantic Rationale

**Scope:** every Keel-forked repo consuming the cross-runtime design tokens (web + TUI + catalog).
**Status:** normative. Fork-override path via `apps/web/tokens.fork.json` (DTCG deep-merge).
**Machine-enforced in:** `packages/ui/tokens.schema.json` (structure, Story 1.10) · `packages/keel-invariants/src/invariants.manifest.ts` → `INV-tokens-semantic-rationale` (content-hash drift, Story 1.8 + 1.9) · pre-commit schema-validation + WCAG AA contrast + source/output sync (Story 1.13).
**Normative spec:** this file is the rationale companion to the JSON Schema contract; Sally's "catalog header references rationale" requirement per ux-design-specification.md § Architecture of the Design System.

## Purpose

The JSON Schema at `packages/ui/tokens.schema.json` pins the **shape** of every token — every leaf has a `$type`, every `$value` is a literal or `{alias}`, every semantic group exists. This file pins the **meaning** — why each semantic slot exists, when to use it, and what downstream consumers read. Schema + rationale together defeat the failure mode called out in the UX spec: invisible semantic drift between runtimes when one consumer (say, the Textual TUI) reads `status.success` and another (say, the Tailwind preset) reads `status.success.fg` and both resolve without error but to mutually inconsistent values.

Every semantic token here carries a stable `TOKEN-<slug>` ID. Downstream callers cross-reference the ID, not the path — so renaming a path is a breaking change that the sync-gate catches at pre-commit. Epic 7's component catalog header-row anchors resolve to this file's slugs.

## Promotion rules

| Audience / scope                            | File                                          |
| ------------------------------------------- | --------------------------------------------- |
| Applies to every AI agent (ops + truth)     | `AGENTS.md`                                   |
| Claude-Code-specific (skills, settings)     | `CLAUDE.md`                                   |
| Ralph-gotchas (iteration-loop lessons)      | `RALPH.md`                                    |
| Machine-enforced (config/rule/gate in code) | `INVARIANTS.md` + `packages/keel-invariants/` |

This file is machine-enforced (via its manifest entry + sync-gate), and semantic guidance for design-token consumers.

## Stable-ID convention

Every semantic token slot carries a stable ID: `TOKEN-<slug>`, where `slug` is the token path lowercased with `.` replaced by `-`. Examples: `surface.raised` → `TOKEN-surface-raised`; `status.success.fg` → `TOKEN-status-success-fg`; `motion.snap` → `TOKEN-motion-snap`. Three-segment IDs apply only to tokens that have a `<category>.<semantic-name>.<modifier>` path (e.g. `status.success.fg`). Two-segment tokens (`motion.snap`, `density.compact`) carry two-segment IDs.

## Cross-runtime reminder

Semantic tokens are shared between:

- **Tailwind preset** (`packages/ui/tailwind.preset.ts`, Story 1.12) — CSS custom properties + Tailwind class vocabulary (`text-status-success`, `bg-surface-raised`).
- **Textual TUI theme** (`packages/devbox/tui/theme.py`, Story 1.12) — Textual style variables (`$status-success`, `$surface-raised`).
- **Epic 7 catalog** — per-component header row resolves each token ID to this file's rationale line (no invisible semantic drift between runtimes).

A rationale line speaks to all three consumers. Don't bake CSS- or Textual-specific detail into the semantic meaning; reserve syntactic concerns for the runtime-layer docs (Story 1.12 output).

## Scope carve-out — motion / density tier IDs

The epic's shorthand `motion.scale.*` / `density.scale.*` does **not** imply three-segment IDs. The canonical resolution (mirrored in `packages/ui/tokens.schema.json`):

- Motion: `TOKEN-motion-scale` (global dial, `$type: number`, reduced-motion respects `= 0`) **plus** `TOKEN-motion-instant`, `TOKEN-motion-snap`, `TOKEN-motion-swift`, `TOKEN-motion-smooth`, `TOKEN-motion-drift` (named duration tiers — `$type: duration`, aliasable by the dial).
- Density: `TOKEN-density-scale` (global dial, `$type: number`) **plus** `TOKEN-density-compact`, `TOKEN-density-default`, `TOKEN-density-comfortable` (named number tiers — `$type: number`, scale factors).

Three-segment IDs like `TOKEN-motion-scale-snap` are ruled out: DTCG prohibits group nodes carrying `$type`, and architecture.md:693's `<category>.<semantic-name>.<modifier?>` pattern pins two segments for the dial / tier axis.

## Rationale index

### Neutral (primitive ramp)

The neutral palette is the primitive scale from which semantic surfaces, text, and borders draw. Rationale is group-level — per-stop values are Story 1.11's scope. Stops follow the Tailwind / Radix 11-step convention.

- **`TOKEN-neutral-{N}`** — *perceptually-even 11-step neutral ramp (`50|100|200|300|400|500|600|700|800|900|950`)*. Semantic surfaces (`TOKEN-surface-default`, `TOKEN-surface-raised`, `TOKEN-surface-inset`, `TOKEN-surface-overlay`), text (`TOKEN-text-primary`, `TOKEN-text-secondary`, `TOKEN-text-muted`), and borders (`TOKEN-border-default`, `TOKEN-border-muted`) alias into this ramp at mode-specific stops. Individual slugs: `TOKEN-neutral-50`, `TOKEN-neutral-100`, `TOKEN-neutral-200`, `TOKEN-neutral-300`, `TOKEN-neutral-400`, `TOKEN-neutral-500`, `TOKEN-neutral-600`, `TOKEN-neutral-700`, `TOKEN-neutral-800`, `TOKEN-neutral-900`, `TOKEN-neutral-950`.

### Surfaces

- **`TOKEN-surface-default`** — *base window / page background surface*. The neutral backdrop every container settles against; below `raised` and `overlay` in stacking order. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-surface-raised`** — *elevated surface (cards, panels, popovers anchored to the viewport)*. One z-step above `default`; reads as "this sits above content, not beside it". Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-surface-inset`** — *recessed surface (inputs, code blocks, scroll wells)*. Reads as "content lives inside this well"; usually a slightly darker tone than `default` in light mode. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-surface-overlay`** — *floating surface over interactive content (modals, command-k, notification toasts)*. Higher z-step than `raised`; usually paired with `color.border.default`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.

### Text

- **`TOKEN-text-primary`** — *dominant reading colour on `surface.default` and `surface.raised`*. Story 1.13 pre-commit gate enforces WCAG AA contrast against both surfaces. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-text-secondary`** — *supporting / metadata text (timestamps, byline, scaffold copy)*. One contrast-step below `primary`; still AA against `default`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-text-muted`** — *subdued text (placeholders, disabled labels, hint copy)*. AA-optional; Story 1.13 logs a warning, not an error, for contrast below AA for this slot only. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-text-inverse`** — *text on solid dark / accent backgrounds*. Used inside filled buttons and inverse surfaces; contrast-tested against `color.accent.500`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-text-accent`** — *hyperlink-style text inside body copy*. Matches `color.accent.500`; underlined by default in web, distinguished by colour-only in the TUI. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.

### Borders

- **`TOKEN-border-default`** — *standard separator / outline between content regions*. Low-contrast against `surface.default`; used for table rows, card outlines. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-border-muted`** — *very-low-contrast divider (nested hierarchies, secondary separators)*. Half-step below `default`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-border-accent`** — *focus ring, selection outline, active-tab underline*. Matches `color.accent.400` for a visible-at-glance focus indicator. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.

### Accent

The accent group mixes three primitive ramp stops (`400|500|600`) with three semantic aliases (`default|fg|focus`). Consumers reach for the semantic form (`TOKEN-accent-default`) first; the ramp stops are for bespoke needs where the three semantic slots don't fit.

- **`TOKEN-accent-400`** — *focus-ring primitive (lighter of the three accent stops)*. Story 1.13 enforces 3:1 non-text contrast against `surface.default`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-accent-500`** — *default interactive accent primitive (link, button fill, active tab)*. The single most-consumed accent ramp stop; AA against `text.inverse`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-accent-600`** — *hover / pressed accent primitive (darker of the three ramp stops)*. Paired with `accent-500` via Tailwind's `hover:` modifier. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-accent-default`** — *semantic default accent (aliases the ramp's `500` stop)*. Canonical name for "the accent" — use this, not the ramp stop, in component code. Value: aliases `{color.accent.500}` at Story 1.11 time.
- **`TOKEN-accent-fg`** — *text / glyph colour on accent-filled surfaces*. AA-tested against `TOKEN-accent-default`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-accent-focus`** — *focus-ring semantic alias (aliases the ramp's `400` stop)*. Referenced by `TOKEN-border-accent` for keyboard-focus outlines. Value: aliases `{color.accent.400}` at Story 1.11 time.

### Status

Each status slot exposes `fg` + `bg` modifiers: `fg` is the readable foreground (AA against `bg`); `bg` is the tinted surface. The unmodified slug (`TOKEN-status-success`) is reserved — downstream consumers always address `-fg` or `-bg`. See Severity (below) for the aliased four-level severity taxonomy.

- **`TOKEN-status-info-fg`** / **`TOKEN-status-info-bg`** — *informational notices (non-blocking; "here's some context")*. Neutral-cool hue; paired with the info icon. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-status-success-fg`** / **`TOKEN-status-success-bg`** — *successful completion (test pass, merge, deploy green)*. Green-adjacent; AA-tested against `bg`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-status-warning-fg`** / **`TOKEN-status-warning-bg`** — *cautionary state (degraded, approaching quota, unusual)*. Amber-adjacent; holds AA without relying on colour alone (pairs with warning icon in both runtimes). Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-status-error-fg`** / **`TOKEN-status-error-bg`** — *recoverable error (validation fail, retryable operation fail)*. Red-adjacent; AA against `bg`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-status-critical-fg`** / **`TOKEN-status-critical-bg`** — *non-recoverable / blocking critical state (loss-of-data, hard failure)*. Red-adjacent but stronger chroma; reserved for the rare "stop everything" signal. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.

### Severity (alias of status)

Severity vocabulary is the CVSS-style four-level classification. Each severity slot aliases the matching `status` foreground — the alias indirection lets a fork re-map severity independently of status.

- **`TOKEN-severity-low`** — *low-severity finding (informational, advisory)*. Aliases `TOKEN-status-info-fg`. Value: alias resolved at build time.
- **`TOKEN-severity-medium`** — *medium-severity finding (needs attention, not blocking)*. Aliases `TOKEN-status-warning-fg`. Value: alias resolved at build time.
- **`TOKEN-severity-high`** — *high-severity finding (blocking, must-fix-before-ship)*. Aliases `TOKEN-status-error-fg`. Value: alias resolved at build time.
- **`TOKEN-severity-critical`** — *critical-severity finding (blocks all forward progress, pages someone)*. Aliases `TOKEN-status-critical-fg`. Value: alias resolved at build time.

### State (kanban vocabulary)

Shared vocabulary between Ralph's TUI kanban (`packages/devbox/tui/`) and any web-side kanban / task-list. The state tokens are semantic labels on task lifecycle; one hue per state so the cross-runtime UI is stable at a glance.

- **`TOKEN-state-pending`** — *task queued but not started (QUEUE item in `@plan.md`)*. Neutral-cool hue. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-state-in-progress`** — *task actively being worked (NOW item; matches GitHub Projects "In Progress" column)*. Accent-family hue. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-state-blocked`** — *task cannot proceed (BLOCKED item with human-needed reason)*. Warning-family hue. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-state-done`** — *task complete (DONE item; matches GitHub Projects "Done" column)*. Success-family hue. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.

### Motion

The motion system exposes one global dial (`scale`) and five named duration tiers. Reduced-motion-respects systems clamp the dial to `0`; every `duration` tier multiplies by the dial before emission. The tiers are semantic ("snap feels instantaneous-but-visible") rather than numeric ("150ms").

- **`TOKEN-motion-scale`** — *global motion multiplier (`$type: number`; `0` = reduced-motion, `1` = default)*. Runtime sets via the user's OS `prefers-reduced-motion` query; design-time override lands in Story 1.11. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-motion-instant`** — *perceptually instantaneous (state flips, checkbox toggle)*. Shortest tier; usually `≈ 60ms × scale`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-motion-snap`** — *quick, mechanical feedback (button press, tab switch)*. Second tier; usually `≈ 120ms × scale`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-motion-swift`** — *standard UI transition (menu open, toast enter)*. Default-feeling tier; usually `≈ 200ms × scale`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-motion-smooth`** — *considered easing (page transition, drawer slide)*. Perceptibly longer; usually `≈ 320ms × scale`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-motion-drift`** — *background / atmospheric motion (subtle hover reveal, ambient state change)*. Longest tier; usually `≈ 500ms × scale`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.

### Density

The density system exposes one global dial (`scale`) and three named tiers. Tiers are scale factors (`$type: number`) multiplied into `space.*` at emission time — tuning density does not require re-authoring per-component spacing.

- **`TOKEN-density-scale`** — *global density multiplier (`$type: number`)*. Runtime-switchable (user preference or viewport class); design-time default is `1.0`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-density-compact`** — *tight density (data-heavy views, TUI default)*. Scale factor `< 1.0`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-density-default`** — *baseline density (standard web default)*. Scale factor `= 1.0` — the reference. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-density-comfortable`** — *generous density (reading views, accessibility-preferred)*. Scale factor `> 1.0`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.

### Type scale

One modular scale with 1.125 ratio anchors (ux-design-specification.md § Visual Design Foundation). Leaves are `$type: dimension`. The scale defines eight stops; `base` is the anchor.

- **`TOKEN-type-xs`** — *fine-print / metadata tier*. Two steps below `base`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-type-sm`** — *small body / secondary text tier*. One step below `base`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-type-base`** — *body-text anchor (web: `16px`, TUI: `1 cell`)*. Reference stop. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-type-lg`** — *emphasised body / small heading tier*. One step above `base`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-type-xl`** — *section heading tier*. Two steps above `base`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-type-2xl`** — *page heading tier*. Three steps above `base`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-type-3xl`** — *hero heading tier (marketing / landing)*. Four steps above `base`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.
- **`TOKEN-type-4xl`** — *display tier (rare; splash / presentation)*. Five steps above `base`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.

### Font

The font group exposes two typographic role slots (`sans` / `mono`) whose values are DTCG `fontFamily` stacks (arrays of family names with ordered fallbacks). Cross-runtime consumers address the semantic role, not a specific family — a fork re-maps the stack once at source-time without editing component code.

- **`TOKEN-font-{name}`** — *typographic font stack roles (sans / mono)*. Cross-runtime: the Tailwind preset exposes `font-sans` / `font-mono` utility classes; the Textual TUI uses `$font-sans` / `$font-mono` style vars. Individual slugs: `TOKEN-font-sans`, `TOKEN-font-mono`. Value: see ux-design-specification.md § Visual Design Foundation; Story 1.11 populates.

### Spacing / radius / breakpoints

Primitive scales — rationale is the ratio + base unit, not per-stop meaning. Stable IDs exist for per-stop traceability but each bullet here covers the scale.

- **`TOKEN-space-{N}`** — *4px-base spacing scale (Tailwind stops `0 1 2 3 4 5 6 8 10 12 16 20 24`)*. `1` = `4px`; each stop multiplied by `density.scale` at emission (ux-design-specification.md § Visual Design Foundation). Individual slugs: `TOKEN-space-0`, `TOKEN-space-1`, `TOKEN-space-2`, `TOKEN-space-3`, `TOKEN-space-4`, `TOKEN-space-5`, `TOKEN-space-6`, `TOKEN-space-8`, `TOKEN-space-10`, `TOKEN-space-12`, `TOKEN-space-16`, `TOKEN-space-20`, `TOKEN-space-24`.
- **`TOKEN-radius-{name}`** — *border-radius scale (`none|sm|md|lg|full`)*. `none` = `0`; `full` = pill. Individual slugs: `TOKEN-radius-none`, `TOKEN-radius-sm`, `TOKEN-radius-md`, `TOKEN-radius-lg`, `TOKEN-radius-full`.
- **`TOKEN-breakpoint-{name}`** — *viewport breakpoints for the web runtime (`sm|md|lg|xl|2xl`)*. TUI runtime ignores breakpoints (single-pane layout); web runtime uses them for Tailwind responsive modifiers. Individual slugs: `TOKEN-breakpoint-sm`, `TOKEN-breakpoint-md`, `TOKEN-breakpoint-lg`, `TOKEN-breakpoint-xl`, `TOKEN-breakpoint-2xl`.

## Consumption

- **Humans / AI agents:** read this file for the semantic meaning of every `TOKEN-<slug>`; cross-reference `packages/ui/tokens.schema.json` for the shape.
- **Story 1.11 (source population):** consumes this file's slugs as the authoritative inventory; populates concrete values in the DTCG source (`apps/web/tokens.json` or equivalent).
- **Story 1.12 (emitter pipeline):** reads this file's cross-runtime reminder + generates `tokens.css` / `tailwind.preset.ts` / `theme.py` with semantic names preserved.
- **Story 1.13 (pre-commit quality gates):** enforces schema-validation + WCAG AA contrast + source-output sync against the contract + rationale.
- **Epic 7 (component catalog):** per-component header row resolves each token ID to this file's rationale; prevents invisible semantic drift.

## Extension (FR44)

Forks override via `apps/web/tokens.fork.json` (DTCG deep-merge into the upstream source). Adding a new semantic slot requires: (a) a new `$def` in `packages/ui/tokens.schema.json`; (b) a new `TOKEN-<slug>` bullet in this file under the appropriate group; (c) a synchronous PR updating both files plus `packages/keel-invariants/src/invariants.manifest.ts` `contentHash` fields + `INVARIANTS.md` anchors (the sync-gate catches skew). Removing a slot is a breaking change — follow the same FR32 source-level-fork path.
