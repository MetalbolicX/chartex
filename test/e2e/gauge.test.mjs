import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('Gauge Chart E2E', () => {
  it('JSON gauge chart renders with label', () => {
    const r = runCli([
      '--file', fixture('gauge.json'),
      '--format', 'json',
      '--chart', 'gauge',
      '--key', 'label',
      '--value', 'value',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'CPU', 'gauge chart includes label');
    assertContains(r.stdout, '75', 'gauge chart includes value');
  });

  it('gauge 100% value renders as 100', () => {
    const r = runCli([
      '--file', fixture('gauge-100.json'),
      '--format', 'json',
      '--chart', 'gauge',
      '--key', 'label',
      '--value', 'value',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '100', 'gauge renders 100 for full percentage');
  });
});
