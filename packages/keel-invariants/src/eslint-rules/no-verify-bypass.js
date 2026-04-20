// Flags hook-bypass tokens (e.g. --no-verify, --dangerously-skip-permissions)
// appearing as string literals or template-literal quasis in committed JS/TS.
// Complements the Story 1.9 sync-gate which detects hook-dir tampering at pre-merge.
// Scope: JS/TS/JSX/MJS/CJS only. Shell/YAML/JSON coverage is the prompt-injection
// regex (S4)'s job — see architecture.md §679 and FR40.
const BYPASS_PATTERNS = [
  { pattern: /(?<![\w-])--no-verify(?![\w-])/, name: '--no-verify' },
  {
    pattern: /(?<![\w-])--dangerously-skip-permissions(?![\w-])/,
    name: '--dangerously-skip-permissions',
  },
];

const rule = {
  meta: {
    type: 'problem',
    docs: {
      description: 'Disallow hook-bypass tokens in committed scripts (FR32; Story 1.6).',
      recommended: true,
    },
    schema: [],
    messages: {
      bypass:
        "'{{token}}' is a hook-bypass token and is forbidden in committed scripts (FR32; Story 1.6). If you need to fork the substrate, change packages/keel-invariants/ at source and update invariants.manifest.ts + INVARIANTS.md together.",
    },
  },
  create(context) {
    function check(node, value) {
      if (typeof value !== 'string') return;
      for (const { pattern, name } of BYPASS_PATTERNS) {
        if (pattern.test(value)) {
          context.report({ node, messageId: 'bypass', data: { token: name } });
          return;
        }
      }
    }
    return {
      Literal(node) {
        check(node, node.value);
      },
      TemplateElement(node) {
        check(node, node.value && node.value.cooked);
      },
    };
  },
};

export default rule;
