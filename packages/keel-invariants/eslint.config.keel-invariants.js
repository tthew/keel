import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import globals from 'globals';

const sharedBase = [
  {
    ignores: [
      '**/dist/**',
      '**/node_modules/**',
      '**/.turbo/**',
      '**/*.tsbuildinfo',
      '**/pnpm-lock.yaml',
      '_bmad/**',
      '_bmad-output/**',
      '.claude/**',
      'docs/**',
      '.ralph/**',
      'ralph.py',
      'pyproject.toml',
      'uv.lock',
    ],
  },
  {
    files: ['**/*.{js,jsx,mjs,cjs}'],
    ...js.configs.recommended,
  },
  ...tseslint.configs.recommended.map((config) => ({
    ...config,
    files: ['**/*.{ts,tsx}'],
  })),
  {
    files: ['**/*.{ts,tsx,js,jsx,mjs,cjs}'],
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.browser,
      },
    },
  },
  {
    files: ['**/*.{ts,tsx,js,jsx,mjs,cjs}'],
    rules: {
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: [
                '**/packages/*/src',
                '**/packages/*/src/**',
                '**/apps/*/src',
                '**/apps/*/src/**',
              ],
              message:
                'No relative imports crossing a package src/ boundary. Use the @keel/<pkg> alias for cross-package imports (architecture.md § Public surface enforcement).',
            },
            {
              group: ['@keel/*/internal', '@keel/*/internal/**'],
              message:
                '@keel/<pkg>/internal/* is forbidden across packages. Public surface is src/index.ts only (architecture.md § Public surface enforcement).',
            },
          ],
        },
      ],
    },
  },
];

export default sharedBase;

export function forPackage(ownName) {
  return [
    ...sharedBase,
    {
      files: ['**/*.{ts,tsx,js,jsx,mjs,cjs}'],
      rules: {
        'no-restricted-imports': [
          'error',
          {
            patterns: [
              {
                group: [
                  '**/packages/*/src',
                  '**/packages/*/src/**',
                  '**/apps/*/src',
                  '**/apps/*/src/**',
                ],
                message:
                  'No relative imports crossing a package src/ boundary. Use the @keel/<pkg> alias for cross-package imports (architecture.md § Public surface enforcement).',
              },
              {
                group: ['@keel/*/internal', '@keel/*/internal/**'],
                message:
                  '@keel/<pkg>/internal/* is forbidden across packages. Public surface is src/index.ts only (architecture.md § Public surface enforcement).',
              },
              {
                group: [`@keel/${ownName}`, `@keel/${ownName}/**`],
                message: `Self-import: use a relative path within the same package ('${ownName}'), not the @keel/${ownName} alias.`,
              },
            ],
          },
        ],
      },
    },
  ];
}
