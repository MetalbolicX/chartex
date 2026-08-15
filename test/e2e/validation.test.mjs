import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, example, assertExitCode, assertStderrContains } from './helpers.mjs';

describe('Validation Path E2E', () => {
  it('empty input file returns non-zero exit and error message', () => {
    const r = runCli(['--file', fixture('empty.csv'), '--format', 'csv', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'empty data should fail');
    assertStderrContains(r.stderr, 'at least one data point', 'empty data error message');
  });

  it('NaN-producing input returns non-zero with NaN in output', () => {
    const r = runCli([
      '--file', fixture('nan.ndjson'),
      '--format', 'ndjson',
      '--chart', 'bar',
      '--key', 'department',
      '--value', 'revenue',
    ]);
    assert.notStrictEqual(r.exitCode, 0, 'NaN input should fail');
    assertStderrContains(r.stderr, 'Invalid key/value types', 'NaN error message');
  });

  it('scatter chart with categorical input returns scatter field error', () => {
    // sales.csv has department/revenue/growth, not series/x/y
    const r = runCli(['--file', example('sales.csv'), '--format', 'csv', '--chart', 'scatter']);
    assert.notStrictEqual(r.exitCode, 0, 'missing scatter fields should fail');
    assertStderrContains(r.stderr, 'Missing scatter fields', 'stderr includes missing fields error');
  });
});
