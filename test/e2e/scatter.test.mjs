import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, example, assertContains, assertExitCode } from './helpers.mjs';

describe('Scatter Chart E2E', () => {
  it('NDJSON scatter chart includes series names and axes', () => {
    const r = runCli(['--file', example('scatter.ndjson'), '--format', 'ndjson', '--chart', 'scatter']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Group A', 'NDJSON scatter includes first series name');
    assertContains(r.stdout, '|', 'NDJSON scatter includes Y-axis character');
    assertContains(r.stdout, '_', 'NDJSON scatter includes X-axis line');
  });

  it('CSV scatter chart includes series names', () => {
    const r = runCli(['--file', example('scatter.csv'), '--format', 'csv', '--chart', 'scatter']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Group A', 'CSV scatter includes series name');
    assertContains(r.stdout, '|', 'CSV scatter includes Y-axis');
  });

  it('JSON scatter chart includes series names', () => {
    const r = runCli(['--file', example('scatter.json'), '--format', 'json', '--chart', 'scatter']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Group A', 'JSON scatter includes series name');
  });

  it('Field mapping uses specified series/x/y keys', () => {
    const r = runCli([
      '--file', example('scatter.csv'),
      '--chart', 'scatter',
      '--series', 'series',
      '--x-key', 'x',
      '--y-key', 'y',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Group A', 'Field mapping includes series labels');
  });

  it('Auto-detect format from NDJSON file content', () => {
    const r = runCli(['--file', example('scatter.ndjson'), '--chart', 'scatter']);
    assertExitCode(r, 0);
    assertContains(r.stdout, '|', 'Auto-detect NDJSON renders scatter with Y-axis');
    assertContains(r.stdout, 'Group A', 'Auto-detect NDJSON renders scatter with legend');
  });
});
