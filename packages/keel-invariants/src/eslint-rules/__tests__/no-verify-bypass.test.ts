// Story 1.19 Task 2 / AC1 — ESLint rule positive + negative coverage for `no-verify-bypass`.
// RED-PHASE SCAFFOLD per /bmad-testarch-atdd: every `it.skip()` asserts the EXPECTED rule
// behaviour; activation (remove `.skip`) by /bmad-dev-story per Story 1.19 Subtask 2.4.
//
// `no-verify-bypass.js` is a JS-source ESLint rule without `.d.ts`. Dynamic-import path
// is held in a const so TS skips the declaration check (treats the resolved module as any).
import { describe, it, expect } from 'vitest';

const RULE_PATH: string = '../no-verify-bypass.js';

describe('eslint-rules/no-verify-bypass (Story 1.19 AC1 RED-phase)', () => {
  it.skip('valid: --verify (different flag, lookahead prevents substring miss)', async () => {
    const { RuleTester } = await import('eslint');
    const { default: rule } = await import(RULE_PATH);
    const tester = new RuleTester({
      languageOptions: { ecmaVersion: 2024, sourceType: 'module' },
    });
    tester.run('no-verify-bypass', rule as never, {
      valid: [{ code: "const x = '--verify';" }],
      invalid: [],
    });
    expect(true).toBe(true);
  });

  it.skip('valid: no-verify (lookbehind prevents partial token match)', async () => {
    const { RuleTester } = await import('eslint');
    const { default: rule } = await import(RULE_PATH);
    const tester = new RuleTester({
      languageOptions: { ecmaVersion: 2024, sourceType: 'module' },
    });
    tester.run('no-verify-bypass', rule as never, {
      valid: [{ code: "const y = 'no-verify';" }],
      invalid: [],
    });
  });

  it.skip('valid: template literal containing no bypass token', async () => {
    const { RuleTester } = await import('eslint');
    const { default: rule } = await import(RULE_PATH);
    const tester = new RuleTester({
      languageOptions: { ecmaVersion: 2024, sourceType: 'module' },
    });
    tester.run('no-verify-bypass', rule as never, {
      valid: [{ code: 'const z = `npm install`;' }],
      invalid: [],
    });
  });

  it.skip('valid: empty string literal', async () => {
    const { RuleTester } = await import('eslint');
    const { default: rule } = await import(RULE_PATH);
    const tester = new RuleTester({
      languageOptions: { ecmaVersion: 2024, sourceType: 'module' },
    });
    tester.run('no-verify-bypass', rule as never, {
      valid: [{ code: "const a = '';" }],
      invalid: [],
    });
  });

  it.skip('invalid: --no-verify literal → reports messageId bypass + token data', async () => {
    const { RuleTester } = await import('eslint');
    const { default: rule } = await import(RULE_PATH);
    const tester = new RuleTester({
      languageOptions: { ecmaVersion: 2024, sourceType: 'module' },
    });
    tester.run('no-verify-bypass', rule as never, {
      valid: [],
      invalid: [
        {
          code: "const x = '--no-verify';",
          errors: [{ messageId: 'bypass', data: { token: '--no-verify' } }],
        },
      ],
    });
  });

  it.skip('invalid: --dangerously-skip-permissions literal → reports bypass + token', async () => {
    const { RuleTester } = await import('eslint');
    const { default: rule } = await import(RULE_PATH);
    const tester = new RuleTester({
      languageOptions: { ecmaVersion: 2024, sourceType: 'module' },
    });
    tester.run('no-verify-bypass', rule as never, {
      valid: [],
      invalid: [
        {
          code: "const y = '--dangerously-skip-permissions';",
          errors: [{ messageId: 'bypass', data: { token: '--dangerously-skip-permissions' } }],
        },
      ],
    });
  });

  it.skip('invalid: template literal cooked-value carries --no-verify', async () => {
    const { RuleTester } = await import('eslint');
    const { default: rule } = await import(RULE_PATH);
    const tester = new RuleTester({
      languageOptions: { ecmaVersion: 2024, sourceType: 'module' },
    });
    tester.run('no-verify-bypass', rule as never, {
      valid: [],
      invalid: [
        {
          code: 'const z = `git commit --no-verify`;',
          errors: [{ messageId: 'bypass', data: { token: '--no-verify' } }],
        },
      ],
    });
  });

  it.skip('invalid: template literal multi-token line carries --dangerously-skip-permissions', async () => {
    const { RuleTester } = await import('eslint');
    const { default: rule } = await import(RULE_PATH);
    const tester = new RuleTester({
      languageOptions: { ecmaVersion: 2024, sourceType: 'module' },
    });
    tester.run('no-verify-bypass', rule as never, {
      valid: [],
      invalid: [
        {
          code: 'const a = `claude --dangerously-skip-permissions test`;',
          errors: [{ messageId: 'bypass', data: { token: '--dangerously-skip-permissions' } }],
        },
      ],
    });
  });
});
