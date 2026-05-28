import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, example, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('CLI Flags E2E', () => {
  it('--help displays usage and flag descriptions', () => {
    const r = runCli(['--help']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Usage:', '--help shows usage');
    assertContains(r.stdout, '--file', '--help includes --file flag');
    assertContains(r.stdout, '--chart', '--help includes --chart flag');
    assertContains(r.stdout, '--format', '--help includes --format flag');
  });

  it('--version displays version string', () => {
    const r = runCli(['--version']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'chartex cli', '--version outputs CLI name');
  });

  it('--no-header parses CSV with auto-generated col_N field names', () => {
    const r = runCli([
      '--file', fixture('sales-no-header.csv'),
      '--format', 'csv',
      '--no-header',
      '--chart', 'bar',
      '--key', 'col_0',
      '--value', 'col_1',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Q1', 'No-header CSV uses first-column values as keys');
  });

  it('--max-rows returns error when row count exceeds limit', () => {
    const r = runCli([
      '--file', example('sales.csv'),
      '--format', 'csv',
      '--chart', 'bar',
      '--key', 'department',
      '--value', 'revenue',
      '--max-rows', '2',
    ]);
    if (r.exitCode !== 2) {
      throw new Error(`expected exit code 2, got ${r.exitCode}. stderr: ${r.stderr}`);
    }
    if (!r.stderr.includes('Row limit exceeded')) {
      throw new Error(`expected "Row limit exceeded" in stderr, got: ${r.stderr}`);
    }
  });

  it('auto-detect format from CSV file content renders bar chart', () => {
    const r = runCli(['--file', example('sales.csv'), '--chart', 'bar', '--key', 'department', '--value', 'revenue']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'Auto-detect CSV renders bar chart');
  });

  it('-f short flag works same as --file', () => {
    const r = runCli(['-f', example('sales.csv'), '--format', 'csv', '--chart', 'bar', '--key', 'department', '--value', 'revenue']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', '-f flag works same as --file');
  });
});
