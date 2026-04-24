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
    contentHash: '4ec1758431b105347c6f632ecf35b96114d14133e8e211f9a54eac0374811b1d',
    anchors: ['INV-prek-pre-commit-config'],
  },
  {
    id: 'INV-prek-prepare-lifecycle',
    description:
      'Root package.json prepare script installs prek shims for both pre-commit and commit-msg stages via prek install -t pre-commit -t commit-msg.',
    sourcePath: 'package.json',
    contentHash: 'dc5ed31b8a4d44d79cf5c69d15df43d9279892f6292c3dbb61dc02f6f6b4ddc0',
    anchors: ['INV-prek-prepare-lifecycle'],
  },
  {
    id: 'INV-prek-commit-msg-config',
    description:
      'Hook entry id: commitlint, stages: [commit-msg], entry: pnpm exec commitlint --edit, language: system; prek passes <COMMIT_EDITMSG> as trailing positional. Lives in the commit-msg stage block of .pre-commit-config.yaml (position-independent — the block is identified by stages: [commit-msg], not by row index).',
    sourcePath: '.pre-commit-config.yaml',
    contentHash: '4ec1758431b105347c6f632ecf35b96114d14133e8e211f9a54eac0374811b1d',
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
    contentHash: '78fb480a754d56d3eb0d1fd21fa6e932ce665cd5d894f5e1bfd04888c57809a4',
    anchors: ['INV-ralph-halt-path-resolution'],
  },
  {
    id: 'INV-ralph-halt-reason-enum',
    description:
      '.ralph/halt sentinel reason is a closed 7-reason enum at 1.0 (EPIC_DONE, ALL_EPICS_DONE, AWAIT_MERGE, BUDGET_EXHAUSTED, CI_BLOCKED, SECURITY_CRITICAL, RALPH_STAGE_REGRESSION). Autonomy constraint (non-toggle-able): every reason is bounded — self-resolving or triggered by a concrete external condition; no reason may block on open-ended human input; Ralph does not invoke AskUserQuestion from the runtime loop; inconsistent state falls back to EPIC_DONE with diagnostic note rather than introducing a new waiting reason. A hypothetical AWAITING_USER reason is rejected by design. Normative spec: docs/invariants/ralph-execute.md § Halt schema (FR14k + FR14n 2026-04-21 amendment adding ALL_EPICS_DONE and the autonomy guardrail).',
    sourcePath: 'docs/invariants/ralph-execute.md',
    contentHash: '78fb480a754d56d3eb0d1fd21fa6e932ce665cd5d894f5e1bfd04888c57809a4',
    anchors: ['INV-ralph-halt-reason-enum'],
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
  {
    id: 'INV-release-please-config',
    description:
      'release-please-monorepo single-bundled-mode configuration — .github/release-please-config.json; pins release-type node + linked-versions plugin (groupName keel) + bump-minor-pre-major + bump-patch-for-minor-pre-major + include-v-in-tag + changelog-sections (9 conventional-commit types; 4 visible + 5 hidden) + packages map listing the root component (.) and every workspace member (apps/web + 15 packages/*). Conventional-commit bump mapping: feat: → minor (pre-1.0 minor per bump-minor-pre-major), fix: → patch, feat!:/BREAKING CHANGE: → major. Consumed by Story 13.5 release-please.yml workflow (Epic 13) at every push to main; static drift is detected by Story 1.9 pre-merge sync-gate (FR43).',
    sourcePath: '.github/release-please-config.json',
    contentHash: 'bd7a6c6c1aac702548bb512c0610633fcd84e630586ab91ad2bc78b577239318',
    anchors: ['INV-release-please-config'],
  },
  {
    id: 'INV-release-please-manifest',
    description:
      "release-please state-of-record manifest — .github/.release-please-manifest.json; maps every releasable path (. root component + apps/web + 15 packages/*) to its current semver. Initial state: all 17 entries at 0.0.0 matching every workspace member's current package.json version. Updated atomically (every entry bumps in lockstep per linked-versions plugin) by release-please on Release-PR merge (AC 5). Linked-versions plugin requires key-parity with release-please-config.json packages map; drift between the two files is invalid config and would fail the Epic-13 workflow invocation.",
    sourcePath: '.github/.release-please-manifest.json',
    contentHash: '4df2aacf54a9849e8e550377c5915cec6efe155b33834b200a6e0c81aedc42e8',
    anchors: ['INV-release-please-manifest'],
  },
  {
    id: 'INV-release-please-rationale',
    description:
      "Documentation-layer rationale for the release-please single-bundled choice — docs/invariants/release.md; mirrors Story 1.10's INV-tokens-semantic-rationale pattern (companion doc to a machine-enforced invariant, drift-detected at the doc layer). Explains (a) the single-bundled vs per-package trade-off with a verbatim pointer to architecture.md § Deferred / Post-1.0 line 1342, (b) the feat:/fix:/feat!: → semver mapping table, (c) fork-extension guidance (FR44 — single-bundled → per-package is a source-fork change, not a config toggle), (d) consumption pointer to Story 13.5 release-please.yml workflow. Companion to INV-release-please-config.",
    sourcePath: 'docs/invariants/release.md',
    contentHash: 'c37ac2a89cc14d965f15cf2fe5a7695f0c9c0d1536e704d447f7b0a636ea547c',
    anchors: ['INV-release-please-rationale'],
  },
  {
    id: 'INV-deps-version-pinning',
    description:
      'Renovate I7 dependency-upgrade policy configuration — .github/renovate.json; extends config:recommended + 4 packageRules (Vitest, @opentelemetry/*, @radix-ui/*, ghcr.io/fboulnois/pg_uuidv7) each carrying rangeStrategy: pin + per-ecosystem groupName + automerge: false. Top-level automerge: false forbids Renovate auto-merge at 1.0 until Epic 13 lands the integration-test-passing CI gate + GH branch-protection status-check requirement. Enforces the architecture.md § I7 three-agent-convergence pinning decision (Vitest exact minor + OTEL exact in pnpm.overrides + pg_uuidv7 image tag). Inert substrate until Tthew installs the Renovate GitHub App against the repo (one-time ops action per § Fork extension). Consumed at runtime by the Renovate App + Epic 13 integration-test CI gate; static drift detected by Story 1.9 pre-merge sync-gate (FR43).',
    sourcePath: '.github/renovate.json',
    contentHash: 'c02f2bfe97a7811c3cdabc693e02f0c7b9d6a2a280b1c9701aee0d8d56cc4cd0',
    anchors: ['INV-deps-version-pinning'],
  },
  {
    id: 'INV-renovate-rationale',
    description:
      "Documentation-layer rationale for the Renovate I7 pinning posture — docs/invariants/renovate.md; mirrors Story 1.10's INV-tokens-semantic-rationale + Story 1.14's INV-release-please-rationale pattern (companion doc to a machine-enforced invariant, drift-detected at the doc layer). Explains (a) the I7 posture with a verbatim pointer to architecture.md § I7 line 342 + PRD I7 amendment, (b) per-package pinning rules table (Vitest / OTEL / Radix UI / pg_uuidv7) + groupName rationale, (c) fork-extension guidance (FR44 — per-fork renovate.json edits change automerge posture per group), (d) consumption pointer to Renovate GitHub App runtime + Epic 13 CI gate + Story 2.1 pg_uuidv7 image tag source. Companion to INV-deps-version-pinning.",
    sourcePath: 'docs/invariants/renovate.md',
    contentHash: 'a18a353f3efc1496b208bf84bf5158daf72a0728ef1ada1b9976a300b7f81c56',
    anchors: ['INV-renovate-rationale'],
  },
  {
    id: 'INV-fork-extension-rationale',
    description:
      "Documentation-layer rationale for the FR44 fork-extension pattern + FR45 Growth-tier INVARIANTS.fork.md scaffold — docs/invariants/fork.md; mirrors Story 1.10's INV-tokens-semantic-rationale + Story 1.14's INV-release-please-rationale + Story 1.15's INV-renovate-rationale pattern (companion doc to a machine-enforced substrate surface, drift-detected at the doc layer). Explains (a) the FR44 ESLint-extend pattern — forks author eslint.config.fork.js importing @keel/keel-invariants/eslint via the subpath export already declared at packages/keel-invariants/package.json:14, with spread-at-end convention for substrate-wins precedence, (b) the FR45 Growth-tier INVARIANTS.fork.md scaffold opt-in flow — fork operators copy packages/keel-invariants/templates/INVARIANTS.fork.md to their fork root + reference from their CLAUDE.md, (c) substrate-wins precedence rule + amendment-vs-fork decision tree (FORK / AMEND via Story 1.6 + 1.9 source-level path / DEFER), (d) Growth-tier opt-in — at 1.0 create-keel-app does NOT auto-create; Epic 15a's --include-fork-invariants flag lands downstream per AC 4. Companion to INV-fork-invariants-scaffold.",
    sourcePath: 'docs/invariants/fork.md',
    contentHash: 'be6f3d8919e7bb2b6258d768895d8a1e4d4a37c5fef95f5121f1ca878da192f2',
    anchors: ['INV-fork-extension-rationale'],
  },
  {
    id: 'INV-fork-invariants-scaffold',
    description:
      "Growth-tier INVARIANTS.fork.md scaffold template — packages/keel-invariants/templates/INVARIANTS.fork.md; fork-operator opt-in source for the fork-specific invariants surface (FR45). Ships a canonical template with H1 + § Precedence + § Fork invariants index + § Consumption + § Extension sections + a commented FORK-<fork-slug>-<category>-<slug> naming-convention example. Fork operators copy this file to their fork root (manual cp at 1.0; Epic 15a's create-keel-app --include-fork-invariants flag automates later per AC 4 downstream). Substrate-wins precedence rule pinned verbatim in the template's § Precedence section; fork rules ADD TO substrate rules but CANNOT override them (substrate-wins convention). Inert substrate until a fork operator opts in; static drift detected by Story 1.9 pre-merge sync-gate (FR43).",
    sourcePath: 'packages/keel-invariants/templates/INVARIANTS.fork.md',
    contentHash: '167ba6b2a8f1153df02f7e572b1d1e31415731493b0729415f6573cc1a696218',
    anchors: ['INV-fork-invariants-scaffold'],
  },
  {
    id: 'INV-devbox-dind-available',
    description:
      "Devbox iteration-environment substrate requirement — docs/invariants/devbox-dind.md; asserts that every Ralph iteration environment (cc-devbox or equivalent) provides a FUNCTIONAL Docker runtime — daemon reachability alone is NOT sufficient. Functional criterion: `command -v docker` exits 0; `docker info` succeeds against a reachable daemon; `docker compose` subcommand available; `docker run --rm hello-world` exits 0 (image pull + layer registration + overlayfs mount all succeed). Fork-time requirement, not transitional — Ralph needs DinD to exercise full-stack vertical slices against services, architecture, and infrastructure inside a fork's devbox (Epic 2 Docker-gated tasks, Epic 6 RLS debugger, Epic 13 CI harness smokes). Backend contract: A = true DinD (isolated daemon, broad prune self-contained); B = host socket-passthrough (shares host daemon state, broad prune destroys unrelated host projects). Keel's 2026-04-21 reference environment is backend B (empirical discovery at Story 2.1 iter-122: `docker info` reports `docker-desktop`). Safety rule: broad-mutation scripts (`docker system prune`, `docker volume prune`, etc.) MUST detect backend B at runtime and REFUSE destructive ops unless an explicit override flag accepts the blast radius; scoped ops (`docker image rm keel-devbox:local`, `docker compose down --rmi local --volumes`) are safe under either backend. Canonical install path: docs.docker.com/engine/install/ubuntu/ against the cc-devbox `FROM ubuntu:24.04` base. Forks MAY substitute transports (remote socket, rootless Docker, Podman-compat) so long as daemon reachability + function hold; substitutions that break either pursue the AMEND path against this doc rather than the FORK path (substrate-wins precedence per docs/invariants/fork.md § Precedence). Does NOT change NFR2 authority — AC 4 scope clarification for Story 2.1 keeps M4-Pro native as authoritative; DinD benchmark runs land in packages/devbox/README.md § Benchmarks flagged `host: DinD (cc-devbox, backend=<A|B>) — modelled indicative baseline; AC 4 authoritative run still owed on M4-Pro per scope clarification`. Under backend B, only warm-only measurement is autonomously safe; cold measurement requires an explicit override or a native host. Spec-enforced at 1.0 (this doc is the source of truth); runtime check (hello-world smoke + backend detection) deferred to a dedicated packages/keel-invariants/ rule + unit test on a later Ralph iteration, wired into pnpm keel-invariants:check-all. Drift between manifest and doc detected by Story 1.9 pre-merge sync-gate (FR43).",
    sourcePath: 'docs/invariants/devbox-dind.md',
    contentHash: '8e382a5396b8d4d713cdc76caa3df77fb0d75fea34f1cf995ce868d14c92f723',
    anchors: ['INV-devbox-dind-available'],
  },
  {
    id: 'INV-devbox-egress-contract',
    description:
      'Fail-closed DNS (dnsmasq, default address=/#/ returns 0.0.0.0/::) + IPv4/IPv6 default-deny (nftables inet keel_egress table with output_v4 + output_v6 chains both `policy drop`) + atomic reload (flock + nft -f kernel transaction + dnsmasq SIGHUP). Closes upstream cc-devbox bugs: divergent whitelist tooling (single reload-egress.sh primitive), fail-open resolv.conf fallback to 8.8.8.8 (pinned to 127.0.0.1 only), IPv6 default-deny gap (both families covered). JSONL query log at /workspace/logs/egress-queries.jsonl with 6-field stable schema (timestamp/query/type/result/upstream/client) + 50 MB size-based rotation (5 gzip generations). Source consolidation: one contentHash-bound doc gates the three sub-contracts together so drift surfaces at a single sync-gate target (rationale: Story 2.2 iter-151 AR-2 allow-list asymmetry lesson — splitting contracts across manifest entries grew asymmetry risk).',
    sourcePath: 'docs/invariants/devbox-egress.md',
    contentHash: 'd04b02282eab4e5d1affa9f27646f6f88d1e41434afa00007015ebfbcbba7ff0',
    anchors: ['INV-devbox-egress-contract'],
  },
  {
    id: 'INV-devbox-homedev-named-volume',
    description:
      'Container hardening contract — non-root `dev` user (UID/GID 1000, USER directive before ENTRYPOINT) + capability bounding set (cap_drop: ALL; cap_add: NET_ADMIN, NET_RAW, NET_BIND_SERVICE per Story 2.5 SC-4 — nftables netlink + dnsmasq :53 bind + raw-socket probes) + security_opt: no-new-privileges:true + tmpfs posture (/tmp + /var/tmp with noexec,nosuid; sizes parameterised via NFR8a at KEEL_DEVBOX_TMPFS_{TMP,VARTMP}_MB per Story 2.2 .envrc.example) + /home/dev named volume (keel_home_dev, non-toggle under any KEEL_DEVBOX_* setting — never a host bind-mount). Runtime compose-shape check deferred to Story 2.17 / dedicated packages/keel-invariants/src/check-devbox-compose-shape.ts; Story 2.5 registers the substrate-invariant surface. Companion to INV-devbox-dind-available (fork-time Docker runtime) + INV-devbox-egress-contract (fail-closed egress) — the Epic-2 substrate-security trio.',
    sourcePath: 'docs/invariants/devbox-hardening.md',
    contentHash: '2f9ca6f32f289273439d9b834a40156d106aa0fa655b5cb154d85ada8da7a368',
    anchors: ['INV-devbox-homedev-named-volume'],
  },
  {
    id: 'INV-devbox-mode',
    description:
      'Per-fork vs shared devbox mode contract — KEEL_DEVBOX_SHARED flag branches compose project name, container name, bind source, and named volume between keel-devbox (per-fork, default) and keel-devbox-shared (shared) with orphaned-container warning on mid-use flip (Story 2.11). Resolution lives in packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_mode_specific_state(); every host-side shim sources it after resolve_main_repo_and_workdir. Shared mode is opinionated — operator KEEL_DEVBOX_CONTAINER_NAME override is intentionally ignored (AC 2 requires both forks to attach to the SAME container). Two modes = two separate named volumes (keel-devbox_keel_home_dev vs keel-devbox-shared_keel_home_dev); OAuth tokens do not cross modes. Mid-use flip emits a three-site-lockstep stderr warning via env-check.sh (warning-only posture — exit code unchanged). Concurrency posture: shared mode is single-operator-at-a-time by convention (docker attach concurrent-client I/O corruption), NOT by Docker enforcement; operators needing true-parallel Ralph revert to per-fork mode. Fork-level Growth-tier INVARIANTS.fork.md rules MAY add fork-specific mode constraints but MAY NOT weaken substrate defaults (per-fork default preservation).',
    sourcePath: 'docs/invariants/devbox-mode.md',
    contentHash: '0647445551c8a5ab0d84cc71dca25f96536f5d19f5d3ccaa1350176689e5728a',
    anchors: ['INV-devbox-mode'],
  },
  {
    id: 'INV-devbox-prereq-check',
    description:
      'Prerequisite check for Docker runtime + Claude Code auth + gh auth runs on every host-side shim invocation (pnpm devbox:* + pnpm ralph:* + pnpm claude + pnpm gh:auth) at pre-flight and as a standalone verb (pnpm devbox:prereq:check) per FR5 (Story 2.10). Three-check contract (Docker / Claude token / gh token) with tiered dispatch: Tier 1 (Docker only) gates every auth-capable or pre-auth shim (15 shims); Tier 2 (all three) gates ralph-build-host.sh + ralph-plan-host.sh + standalone invocation. Docker probe uses docker info --format {{.ServerVersion}}; token probes use docker run --rm -v <keel-devbox_keel_home_dev>:/vol:ro alpine:3.19 test -e </vol/.claude/.credentials.json|/.config/gh/hosts.yml> — existence only, not validity. Fresh-fork first-run (volume absent) treated as both tokens missing; no auto-create side-effect. Exit-code schema extends Story 2.6 uniform: 0 pass / 2 tokens missing (composite pointer list, Claude before gh, no partial bypass per AC 5) / 8 docker unreachable (install-URL pointer https://docs.docker.com/desktop/install/ verbatim per AC 1) / 12 other docker-daemon error. Alpine probe image (alpine:3.19) is pinned at 1.0 with manual Renovate tracking (docker regex-manager deferred to FR44 AMEND). No --skip-claude / --force / KEEL_PREREQ_BYPASS escape at 1.0 — fork-level relaxation requires AMEND against this doc. Epic 3 Story 3.7 consumes the contract for in-loop pre-push gate CI_BLOCKED halt writes (per INV-ralph-halt-reason-enum closed enum). Runtime source: packages/devbox/scripts/prereq-check.sh. Sync-gate-drift-detected (Story 1.9).',
    sourcePath: 'docs/invariants/devbox-prereq-check.md',
    contentHash: 'eb5b9db25e0afc77c4caf38c8bf60b37921a76df2ea030c91f66e848b0d8fe40',
    anchors: ['INV-devbox-prereq-check'],
  },
  {
    id: 'INV-devbox-ssh',
    description:
      'Opt-in sshd via KEEL_DEVBOX_SSH=true — pubkey-only, root-disabled, loopback-bound 127.0.0.1:2222, host keys + authorized_keys persisted in keel_home_dev named volume; loopback-bound port publication invariant for ALL ports (no 0.0.0.0 / no bare-port bindings) (Story 2.12). Resolution via packages/devbox/scripts/lib/main-repo-resolver.sh § resolve_ssh_state(); compose override at packages/devbox/docker-compose.ssh.yml is the single site that publishes port 2222; entrypoint.sh first-boot atomic host-key-gen (ed25519 + rsa 4096) into the named volume. Single-layer host-side-publish confinement — container-side ListenAddress INTENTIONALLY unset because container-loopback is disjoint from host-loopback under both Docker userland-proxy modes. Strict true-only normalisation; forks MAY NOT extend the accepted-signal set or weaken pubkey-only / root-disabled / loopback-bound substrate defaults.',
    sourcePath: 'docs/invariants/devbox-ssh.md',
    contentHash: 'e1d693cb0ffa0c7c8d6966b8ce311c2e1daf13d83155d8a0b88028d96112a3c2',
    anchors: ['INV-devbox-ssh'],
  },
  {
    id: 'INV-gitignored-secret-commit-deny',
    description:
      'Pre-commit hook refuses additions of .envrc, .envrc.local, and .secrets at any path. ' +
      'Committed schemas (.envrc.example, .secrets.example) are exempt via anchored regex end-match. ' +
      'Implementation: packages/keel-invariants/src/check-no-committed-dotfiles.ts; ' +
      'wiring: .pre-commit-config.yaml → pnpm keel-invariants:no-committed-dotfiles.',
    sourcePath: 'docs/invariants/gitignored-secret-commit-deny.md',
    contentHash: 'e0c70aa4882a9dcb9b58919a3735357e1c8dfac2a7e925b80ee1c200a07984f1',
    anchors: ['INV-gitignored-secret-commit-deny'],
  },
];

export const invariants: readonly Invariant[] = Object.freeze(InvariantsSchema.parse(raw));
