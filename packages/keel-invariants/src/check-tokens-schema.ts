#!/usr/bin/env node
/**
 * Story 1.13 — Design-token schema validation gate.
 *
 * Validates packages/ui/tokens.json against packages/ui/tokens.schema.json
 * (JSON Schema Draft 2020-12) via Ajv v8. Rejects schema-violating commits
 * with a structured JSON error on stderr naming the offending instancePath,
 * schema keyword, and expected-vs-received value. Runs before the token
 * contrast + sync gates so emitter + contrast stages can trust source shape.
 *
 * Invocation: pnpm keel-invariants:tokens-schema.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { Ajv2020 } from 'ajv/dist/2020.js';
import addFormats from 'ajv-formats';
import type { ErrorObject } from 'ajv';

const FILE = fileURLToPath(import.meta.url);
const DIR = path.dirname(FILE);
// packages/keel-invariants/{dist,src}/ → packages/keel-invariants/ → packages/ → repo-root
const REPO_ROOT = path.resolve(DIR, '..', '..', '..');
const SCHEMA_PATH = path.join(REPO_ROOT, 'packages/ui/tokens.schema.json');
const TOKENS_PATH = path.join(REPO_ROOT, 'packages/ui/tokens.json');

try {
  const schemaRaw = fs.readFileSync(SCHEMA_PATH, 'utf-8');
  const tokensRaw = fs.readFileSync(TOKENS_PATH, 'utf-8');
  const schema = JSON.parse(schemaRaw);
  const tokens = JSON.parse(tokensRaw);

  const ajv = new Ajv2020({ allErrors: true, strict: true });
  addFormats(ajv);
  const validate = ajv.compile(schema);
  const ok = validate(tokens);

  if (!ok) {
    const findings = (validate.errors ?? []).map((e: ErrorObject) => ({
      instancePath: e.instancePath,
      schemaPath: e.schemaPath,
      keyword: e.keyword,
      message: e.message,
      params: e.params,
    }));
    process.stderr.write(`${JSON.stringify({ status: 'violation', findings }, null, 2)}\n`);
    process.exit(1);
  }

  process.exit(0);
} catch (err) {
  const message = err instanceof Error ? err.message : String(err);
  process.stderr.write(`${JSON.stringify({ status: 'error', message })}\n`);
  process.exit(1);
}
