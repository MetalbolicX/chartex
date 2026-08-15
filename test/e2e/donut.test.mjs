import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('Donut Chart E2E', () => {
  it('NDJSON donut chart includes keys from data', () => {
    const r = runCli([
      '--file', fixture('donut.ndjson'),
      '--format', 'ndjson',
      '--chart', 'donut',
      '--key', 'category',
      '--value', 'amount',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'X', 'donut chart includes first category');
    assertContains(r.stdout, 'Y', 'donut chart includes second category');
    assertContains(r.stdout, 'Z', 'donut chart includes third category');
  });

  it('donut chart legend contains all keys', () => {
    const r = runCli([
      '--file', fixture('donut.ndjson'),
      '--format', 'ndjson',
      '--chart', 'donut',
      '--key', 'category',
      '--value', 'amount',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'X', 'legend includes category X');
    assertContains(r.stdout, 'Y', 'legend includes category Y');
    assertContains(r.stdout, 'Z', 'legend includes category Z');
  });
});
