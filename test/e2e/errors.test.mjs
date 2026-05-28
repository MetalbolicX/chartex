import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, example, fixture, assertExitCode, assertStderrContains } from './helpers.mjs';

describe('Error Cases E2E', () => {
  it('missing file returns non-zero exit and error message', () => {
    const r = runCli(['--file', 'nonexistent.csv', '--format', 'csv', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'missing file should fail');
    assertStderrContains(r.stderr, 'Failed to read input stream', 'stderr includes stream error');
  });

  it('invalid format (CSV as NDJSON) returns parse error', () => {
    const r = runCli(['--file', example('sales.csv'), '--format', 'ndjson', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'wrong format should fail');
  });

  it('empty data file returns non-zero with "at least one data point"', () => {
    const r = runCli(['--file', fixture('empty.csv'), '--format', 'csv', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'empty data should fail');
    assertStderrContains(r.stderr, 'at least one data point', 'empty data error message');
  });

  it('invalid --max-rows value returns parse error mentioning the flag name', () => {
    const r = runCli([
      '--file', example('sales.csv'),
      '--format', 'csv',
      '--max-rows', 'notanumber',
      '--chart', 'bar',
    ]);
    assert.notStrictEqual(r.exitCode, 0, 'invalid max-rows should fail');
    assertStderrContains(r.stderr, '--max-rows', 'parse error mentions the flag name');
  });

  it('bad NDJSON line returns parse error', () => {
    const r = runCli(['--file', fixture('bad.ndjson'), '--format', 'ndjson', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'bad NDJSON should fail');
  });

  it('missing scatter required fields returns error', () => {
    // sales.csv has department/revenue/growth, not series/x/y
    const r = runCli(['--file', example('sales.csv'), '--format', 'csv', '--chart', 'scatter']);
    assert.notStrictEqual(r.exitCode, 0, 'missing scatter fields should fail');
    assertStderrContains(r.stderr, 'Missing scatter fields', 'stderr includes missing fields error');
  });
});
