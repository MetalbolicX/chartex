import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, example, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('Bar Chart E2E', () => {
  it('NDJSON bar chart includes keys from data', () => {
    const r = runCli([
      '--file', example('sales.ndjson'),
      '--format', 'ndjson',
      '--chart', 'bar',
      '--key', 'department',
      '--value', 'revenue',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'NDJSON bar chart includes department name');
    assertContains(r.stdout, 'Sales', 'NDJSON bar chart includes second department');
  });

  it('CSV bar chart includes keys', () => {
    const r = runCli([
      '--file', example('sales.csv'),
      '--format', 'csv',
      '--chart', 'bar',
      '--key', 'department',
      '--value', 'revenue',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'CSV bar chart includes department name');
  });

  it('JSON bar chart includes keys', () => {
    const r = runCli([
      '--file', example('sales.json'),
      '--format', 'json',
      '--chart', 'bar',
      '--key', 'department',
      '--value', 'revenue',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'JSON bar chart includes department name');
  });

  it('Custom field mapping uses specified fields', () => {
    const r = runCli([
      '--file', example('sales.csv'),
      '--chart', 'bar',
      '--key', 'department',
      '--value', 'growth',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '15', 'Custom field mapping uses growth values');
  });

  it('No-header CSV renders with first-column values as keys', () => {
    const r = runCli([
      '--file', fixture('sales-no-header.csv'),
      '--format', 'csv',
      '--no-header',
      '--chart', 'bar',
      '--key', 'col_0',
      '--value', 'col_1',
    ]);
    assertExitCode(r, 0);
    // col_0 contains Q1, Q2, Q3, Q4 — bar charts render key labels at bottom
    assertContains(r.stdout, 'Q1', 'No-header CSV uses first-column values as keys');
  });
});
