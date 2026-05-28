import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, example, assertContains, assertExitCode } from './helpers.mjs';

describe('Sparkline E2E', () => {
  const baseArgs = ['--chart', 'sparkline', '--key', 'department', '--value', 'growth'];

  it('NDJSON sparkline includes Y-axis character', () => {
    const r = runCli(['--file', example('sales.ndjson'), '--format', 'ndjson', ...baseArgs]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '|', 'NDJSON sparkline includes Y-axis character');
  });

  it('CSV sparkline includes Y-axis character', () => {
    const r = runCli(['--file', example('sales.csv'), '--format', 'csv', ...baseArgs]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '|', 'CSV sparkline includes Y-axis character');
  });

  it('JSON sparkline includes Y-axis character', () => {
    const r = runCli(['--file', example('sales.json'), '--format', 'json', ...baseArgs]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '|', 'JSON sparkline includes Y-axis character');
  });

  it('Custom width and height options render without crashing', () => {
    const r = runCli([
      '--file', example('sales.csv'),
      '--format', 'csv',
      '--chart', 'sparkline',
      '--key', 'department',
      '--value', 'growth',
      '--width', '60',
      '--height', '10',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '|', 'Sparkline with width/height renders Y-axis');
  });
});
