#!/usr/bin/env node
import { resolve } from 'node:path';
import { runSyncGate } from './sync-gate.js';

const repoRoot = resolve(import.meta.dirname, '../../..');
const report = await runSyncGate(repoRoot);

if (report.status === 'drift') {
  process.stderr.write(`${JSON.stringify(report, null, 2)}\n`);
  process.exit(1);
}

process.exit(0);
