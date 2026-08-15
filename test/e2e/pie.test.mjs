import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('Pie Chart E2E', () => {
  it('NDJSON pie chart includes keys from data', () => {
    const r = runCli([
      '--file', fixture('pie.ndjson'),
      '--format', 'ndjson',
      '--chart', 'pie',
      '--key', 'category',
      '--value', 'amount',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'A', 'pie chart includes first category');
    assertContains(r.stdout, 'B', 'pie chart includes second category');
    assertContains(r.stdout, 'C', 'pie chart includes third category');
  });

  it('pie chart legend contains all keys', () => {
    const r = runCli([
      '--file', fixture('pie.ndjson'),
      '--format', 'ndjson',
      '--chart', 'pie',
      '--key', 'category',
      '--value', 'amount',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'A', 'legend includes category A');
    assertContains(r.stdout, 'B', 'legend includes category B');
    assertContains(r.stdout, 'C', 'legend includes category C');
  });
});
