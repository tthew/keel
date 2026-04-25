import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'node',
    include: ['src/**/*.test.ts'],
    exclude: [
      '**/dist/**',
      '**/node_modules/**',
      // node:test legacy file (Story 1.6 / 2.16 substrate); migrated to vitest in Story 1.19
      // keel-invariants backfill — exclude until then to avoid double-discovery + node:test API
      // conflict with vitest.
      '**/prompt-injection-rules/*.test.ts',
    ],
  },
});
