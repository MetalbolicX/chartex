import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('BOM Input E2E', () => {
  it('BOM-prefixed NDJSON file renders keys correctly with auto format', () => {
    const r = runCli([
      '--file', fixture('bom-sales.ndjson'),
      '--format', 'auto',
      '--chart', 'bar',
      '--key', 'department',
      '--value', 'revenue',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Eng', 'BOM input renders department key');
    assertContains(r.stdout, '100', 'BOM input renders revenue value');
  });
});
