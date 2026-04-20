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
      '3 local hooks (typecheck / lint / format-check) wired at repo root; each language: system, pass_filenames: false, always_run: true.',
    sourcePath: '.pre-commit-config.yaml',
    contentHash: '0e8e353f9564c6c278e44c19ba636a0e31bad5ac1e10b58e6da9e0cc36b93bb1',
    anchors: ['INV-prek-pre-commit-config'],
  },
  {
    id: 'INV-prek-prepare-lifecycle',
    description:
      'Root package.json prepare script installs prek shims for both pre-commit and commit-msg stages via prek install -t pre-commit -t commit-msg.',
    sourcePath: 'package.json',
    contentHash: 'c83420f2bb52cb9e8097a4268bed952c217f83052612292200d65bc116f3d76e',
    anchors: ['INV-prek-prepare-lifecycle'],
  },
  {
    id: 'INV-prek-commit-msg-config',
    description:
      '4th hook entry id: commitlint, stages: [commit-msg], entry: pnpm exec commitlint --edit, language: system; prek passes <COMMIT_EDITMSG> as trailing positional.',
    sourcePath: '.pre-commit-config.yaml',
    contentHash: '0e8e353f9564c6c278e44c19ba636a0e31bad5ac1e10b58e6da9e0cc36b93bb1',
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
];

export const invariants: readonly Invariant[] = Object.freeze(InvariantsSchema.parse(raw));
