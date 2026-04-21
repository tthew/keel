import { z } from 'zod';

export const InvariantSchema = z.object({
  id: z.string().regex(/^INV-[a-z0-9]+(-[a-z0-9]+)+$/),
  description: z.string().min(1),
  sourcePath: z
    .string()
    .min(1)
    .refine(
      (p) => !p.startsWith('/') && !p.startsWith('\\') && !p.includes('..') && !p.includes('\\'),
      { message: 'sourcePath must be a repo-relative forward-slash path without traversal' },
    ),
  contentHash: z.string().regex(/^[0-9a-f]{64}$/),
  anchors: z.array(z.string().min(1)).min(1),
});

export type Invariant = z.infer<typeof InvariantSchema>;

export const InvariantsSchema = z
  .array(InvariantSchema)
  .superRefine((arr, ctx) => {
    const ids = new Set<string>();
    for (const { id } of arr) {
      if (ids.has(id)) {
        ctx.addIssue({ code: 'custom', message: `duplicate invariant id: ${id}` });
      }
      ids.add(id);
    }
  })
  .superRefine((arr, ctx) => {
    const hashesBySource = new Map<string, Set<string>>();
    for (const entry of arr) {
      if (!hashesBySource.has(entry.sourcePath)) {
        hashesBySource.set(entry.sourcePath, new Set());
      }
      hashesBySource.get(entry.sourcePath)!.add(entry.contentHash);
    }
    for (const [sourcePath, hashes] of hashesBySource) {
      if (hashes.size > 1) {
        ctx.addIssue({
          code: 'custom',
          message: `contentHash mismatch across entries sharing sourcePath ${sourcePath}: ${[...hashes].join(', ')}`,
        });
      }
    }
  });

const raw: Invariant[] = [
  {
    id: 'INV-tsconfig-base',
    description: 'Strict TS + project-reference contract extended by every workspace member.',
    sourcePath: 'packages/keel-invariants/tsconfig.base.json',
    contentHash: '4c80ad75308b9b98aa3dfa288f2f124de2aa7da982ce9e509fc7d6b830c2c855',
    anchors: ['INV-tsconfig-base'],
  },
  {
    id: 'INV-eslint-shared',
    description:
      'Shared ESLint flat-config baseline: global ignores + js.configs.recommended + tseslint.configs.recommended (spread) + languageOptions.globals (node + browser).',
    sourcePath: 'packages/keel-invariants/eslint.config.keel-invariants.js',
    contentHash: '10ac60e693c32566971eecd52341d6f5b9b42047843812fd8f8153310112afe2',
    anchors: ['INV-eslint-shared'],
  },
  {
    id: 'INV-prettier-shared',
    description:
      '9-key keel house style (printWidth 100, singleQuote, trailingComma all, lf EOL, ...).',
    sourcePath: 'packages/keel-invariants/prettier.config.keel-invariants.js',
    contentHash: '17a4520e3538ec82e4e80e04252711cb7641717adfe2d9c1bda03b87b5a48311',
    anchors: ['INV-prettier-shared'],
  },
  {
    id: 'INV-commitlint-shared',
    description:
      'Conventional-commits + 3-key rule overrides (subject-case off, header-max-length 120, body-max-line-length off).',
    sourcePath: 'packages/keel-invariants/commitlint.config.keel-invariants.js',
    contentHash: '4f9d3b263e73ebac518c0c42fa4b17b37cb252d3cacce76947a102c382b60f41',
    anchors: ['INV-commitlint-shared'],
  },
  {
    id: 'INV-eslint-import-boundary',
    description:
      'no-restricted-imports denies cross-package relative imports (AC 1), @keel/*/internal/* deep imports (AC 2), and per-package self-import via alias (AC 3 via forPackage(ownName) overlay).',
    sourcePath: 'packages/keel-invariants/eslint.config.keel-invariants.js',
    contentHash: '10ac60e693c32566971eecd52341d6f5b9b42047843812fd8f8153310112afe2',
    anchors: ['INV-eslint-import-boundary'],
  },
  {
    id: 'INV-prek-pre-commit-config',
    description:
      '3 repo-wide local hooks (typecheck / lint / format-check) wired at repo root; each language: system, pass_filenames: false, always_run: true. Post-Story-1.13 the file also hosts the 2 source-scoped token gates (tokens-schema / tokens-contrast) + commitlint; those carry separate invariant IDs.',
    sourcePath: '.pre-commit-config.yaml',
    contentHash: 'e321cba9260dd85d985826be85b587214f62230ccc66fdfa892dbf70aaa68ad0',
    anchors: ['INV-prek-pre-commit-config'],
  },
  {
    id: 'INV-prek-prepare-lifecycle',
    description:
      'Root package.json prepare script installs prek shims for both pre-commit and commit-msg stages via prek install -t pre-commit -t commit-msg.',
    sourcePath: 'package.json',
    contentHash: 'b8c4e777e8c36f002d3b886131d44839b5362ffc7e3285f1d67b10eb00fec022',
    anchors: ['INV-prek-prepare-lifecycle'],
  },
  {
    id: 'INV-prek-commit-msg-config',
    description:
      'Hook entry id: commitlint, stages: [commit-msg], entry: pnpm exec commitlint --edit, language: system; prek passes <COMMIT_EDITMSG> as trailing positional. Lives in the commit-msg stage block of .pre-commit-config.yaml (position-independent — the block is identified by stages: [commit-msg], not by row index).',
    sourcePath: '.pre-commit-config.yaml',
    contentHash: 'e321cba9260dd85d985826be85b587214f62230ccc66fdfa892dbf70aaa68ad0',
    anchors: ['INV-prek-commit-msg-config'],
  },
  {
    id: 'INV-no-verify-bypass',
    description:
      'ESLint rule keel-invariants/no-verify-bypass flags FR32 hook-bypass CLI flag tokens (bypass patterns enumerated in the rule source at src/eslint-rules/no-verify-bypass.js BYPASS_PATTERNS) appearing as string literals or static template-literal quasis in committed JS/TS.',
    sourcePath: 'packages/keel-invariants/src/eslint-rules/no-verify-bypass.js',
    contentHash: '08bf6e89c0936ce5106e9d24f22ef61ca3e8198ce005041b10e2989fa92ba674',
    anchors: ['INV-no-verify-bypass'],
  },
  {
    id: 'INV-ralph-halt-path-resolution',
    description:
      'ralph.py resolves .ralph/{halt,@plan.md,PROMPT_*.md,logs/} against the worktree path when --worktree X is set (else cwd-relative .ralph/); absolute path exported as RALPH_BASE_DIR. Normative spec in docs/invariants/ralph-execute.md § Path Resolution (FR14k + NFR33a).',
    sourcePath: 'docs/invariants/ralph-execute.md',
    contentHash: '8c679cdabcccb8ac122b8da82d4bcb8198451f0cc0a19b3d13b4b2695b6cba8b',
    anchors: ['INV-ralph-halt-path-resolution'],
  },
  {
    id: 'INV-tokens-schema-contract',
    description:
      'Design-token JSON Schema contract — DTCG-compatible; defines shape of every semantic + primitive token group (color / type / space / radius / motion / density / breakpoint) plus optional $modes overlays. Validated at pre-commit (Story 1.13); consumed by the Story 1.11 source + Story 1.12 emitter. Story 1.13 added a leafBreakpoint $def that narrows the breakpoint-group $value pattern to ^\\d+px$ (absorbing Story 1.12 CR defer #9).',
    sourcePath: 'packages/ui/tokens.schema.json',
    contentHash: '3373b5d67c4c7dd4f1276aee053d7431dc814bb5e044be752d3cbc2c0360e261',
    anchors: ['INV-tokens-schema-contract'],
  },
  {
    id: 'INV-tokens-semantic-rationale',
    description:
      'Semantic-rationale doc pairing every TOKEN-<slug> with a prose line explaining why the slot exists + how cross-runtime consumers reference it. Companion to INV-tokens-schema-contract; Sally "catalog header references rationale" requirement.',
    sourcePath: 'docs/invariants/tokens.md',
    contentHash: 'efd5fa0d84d3478cd4af530f3cc57c734f9b4e23415d0c7085fb8e6296d1a82c',
    anchors: ['INV-tokens-semantic-rationale'],
  },
  {
    id: 'INV-tokens-source',
    description:
      'Direction A design-token source — DTCG JSON file populated with every semantic + primitive token value per ux-design-specification.md § Visual Design Foundation + § Design Direction Decision. Light + dark mode overlays; motion + density tier hierarchies; aliases into neutral ramp + accent ramp + status/severity/state families. Consumed by Story 1.12 emitter (web CSS + Tailwind preset + TUI theme); validated against INV-tokens-schema-contract by Story 1.13 pre-commit gate; WCAG AA contrast of every semantic pair enforced by Story 1.13 contrast gate. Story 1.13 retuned color.accent.500 (54% → 50%), color.accent.600 (46% → 42%), color.status.info.fg (light L=52% → 42%), color.status.warning.fg (light L=58% → 44%), and added $modes.dark overlay entries for status.*.fg, text.accent, border.accent, severity.*, and state.* to clear the AA pair-enumeration table.',
    sourcePath: 'packages/ui/tokens.json',
    contentHash: '6190c595313f4760cd25301e3679cd9963a6ac61fdbc935ac9ac0b7909cc61fa',
    anchors: ['INV-tokens-source'],
  },
  {
    id: 'INV-tokens-emitter',
    description:
      'Deterministic design-token emitter — pure TypeScript script that reads packages/ui/tokens.json (Direction A source) and emits three byte-stable outputs per FR67-adapted purity contract: packages/ui/src/tokens.css (web CSS custom properties under :root + [data-theme="dark"]), packages/ui/tailwind.preset.ts (Tailwind v4 preset exporting keelTailwindPreset under theme.extend), packages/devbox/tui/theme.py (Textual Python constants under theme.colors.* + theme.motion.* + theme.density.* + theme.dark.colors.*). Flattens DTCG aliases at emit-time; uses no network / no time / no RNG / no env vars. Consumed by Epic 7 Story 7-1 (Tailwind preset import + CSS vars), Epic 3 Story 3.33 (TUI theme.py re-theme seam), Epic 12 shape-aware templates (Tailwind class generation). Validated end-to-end by Story 1.13 pre-merge source-output sync gate (emitter --check mode). Story 1.13 added --check mode, hoisted resolveSourceSha to a single per-run call threaded into the three emit stages, split the resolver fallback into tagged git-unavailable / stderr-error / uncommitted branches, and migrated resolveValue cycle-detection to a mutated in-progress set so diamond-DAG alias graphs resolve without false positives.',
    sourcePath: 'packages/ui/scripts/generate-tokens.ts',
    contentHash: '29f7b5860b7324d673696d1991eafd0452861524863dfaa794604b3a54707c54',
    anchors: ['INV-tokens-emitter'],
  },
  {
    id: 'INV-tokens-schema-validate',
    description:
      'Pre-commit gate that validates packages/ui/tokens.json against the Story-1.10 contract (packages/ui/tokens.schema.json) via Ajv-2020 (JSON Schema Draft 2020-12). Rejects commits that introduce schema violations with a structured JSON error on stderr naming the offending instancePath + schema keyword + expected-vs-received value. Runs before the token-contrast + sync gates in the pre-commit pipeline so emitter + contrast stages can trust source shape. Invocation: pnpm keel-invariants:tokens-schema.',
    sourcePath: 'packages/keel-invariants/src/check-tokens-schema.ts',
    contentHash: '2fbf971015728375a047e837e9a75acc81bf8524f092fd3240ee1448da983a9a',
    anchors: ['INV-tokens-schema-validate'],
  },
  {
    id: 'INV-tokens-contrast-check',
    description:
      'Pre-commit gate that computes WCAG 2.1 AA contrast ratios for every semantic text × surface / status.fg × status.bg / severity × surface / state × surface / accent × surface / border.accent × surface pair in light + dark overlay modes. OKLCH values are resolved via a mode-aware walker (dark overlay wins when present, else base; aliases then flatten against base), gamut-mapped to in-gamut sRGB via a 3-iteration chroma reduction before relative-luminance math (per Story 1.11 CR defer #5 absorption), then compared to threshold 4.5 (normal text) or 3.0 (UI components per WCAG 1.4.11) per pair. Failing pairs emit structured JSON on stderr with pair label + mode + fg/bg OKLCH + gamut-mapped hex + ratio + threshold + delta. Invocation: pnpm keel-invariants:tokens-contrast.',
    sourcePath: 'packages/keel-invariants/src/check-tokens-contrast.ts',
    contentHash: 'f7ea371c6774547daedc817a8f2d3325f97df3dc5e96be062ac1a919bdca782a',
    anchors: ['INV-tokens-contrast-check'],
  },
  {
    id: 'INV-tokens-sync-gate',
    description:
      'Pre-merge gate that re-invokes the Story 1.12 emitter in --check mode (packages/ui/scripts/generate-tokens.ts --check) to byte-compare the re-emitted three outputs (packages/ui/src/tokens.css + packages/ui/tailwind.preset.ts + packages/devbox/tui/theme.py) against the committed files. Any byte-level divergence between "what would be emitted now" and "what is committed" fails the gate with unified-diff excerpts on stderr + non-zero exit. Source file is the emitter itself (--check mode is additive to the writer mode); shares sourcePath with INV-tokens-emitter (both invariants pin the same file). Invocation: pnpm keel-invariants:tokens-sync (which runs pnpm --filter @keel/ui generate-tokens -- --check); composed into pnpm keel-invariants:check-all alongside Story 1.9 manifest sync-gate.',
    sourcePath: 'packages/ui/scripts/generate-tokens.ts',
    contentHash: '29f7b5860b7324d673696d1991eafd0452861524863dfaa794604b3a54707c54',
    anchors: ['INV-tokens-sync-gate'],
  },
];

export const invariants: readonly Invariant[] = Object.freeze(InvariantsSchema.parse(raw));
