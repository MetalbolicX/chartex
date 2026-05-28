import { describe, it } from 'node:test';
import assert from 'node:assert';
import { readFileSync } from 'node:fs';
import { runCli, example, assertContains, assertExitCode } from './helpers.mjs';

describe('Stdin Piping E2E', () => {
  const ndjsonData = readFileSync('examples/data/sales.ndjson', 'utf8');
  const csvData = readFileSync('examples/data/sales.csv', 'utf8');

  it('NDJSON piped via stdin renders bar chart', () => {
    const r = runCli(
      ['--chart', 'bar', '--key', 'department', '--value', 'revenue'],
      { stdin: ndjsonData }
    );
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'NDJSON stdin renders bar with keys');
    assertContains(r.stdout, 'Sales', 'NDJSON stdin renders second department');
  });

  it('CSV piped via stdin with --format renders bar chart', () => {
    const r = runCli(
      ['--format', 'csv', '--chart', 'bar', '--key', 'department', '--value', 'revenue'],
      { stdin: csvData }
    );
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'CSV stdin renders bar with keys');
  });

  it('Auto-detect NDJSON from stdin without --format', () => {
    const r = runCli(
      ['--chart', 'bar', '--key', 'department', '--value', 'revenue'],
      { stdin: ndjsonData }
    );
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'Auto-detect from stdin works');
  });
});
