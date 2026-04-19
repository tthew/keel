import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import globals from 'globals';

export default [
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
];
