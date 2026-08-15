import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('Bullet Chart E2E', () => {
  it('NDJSON bullet chart renders with title', () => {
    const r = runCli([
      '--file', fixture('bullet.ndjson'),
      '--format', 'ndjson',
      '--chart', 'bullet',
      '--key', 'title',
      '--value', 'value',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Revenue', 'bullet chart includes title');
  });

  it('bullet chart value labels render', () => {
    const r = runCli([
      '--file', fixture('bullet.ndjson'),
      '--format', 'ndjson',
      '--chart', 'bullet',
      '--key', 'title',
      '--value', 'value',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '85000', 'bullet chart renders value label');
  });
});
