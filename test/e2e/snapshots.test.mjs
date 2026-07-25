import { describe, it } from 'node:test';
import assert from 'node:assert';
import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { runCli, example } from './helpers.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const BASELINES = join(__dirname, 'baselines');

/**
 * Read a baseline file.
 * @param {string} name - chart type name (bar, scatter, etc.)
 * @returns {string}
 */
function readBaseline(name) {
  return readFileSync(join(BASELINES, `${name}.txt`), 'utf8');
}

/**
 * Normalize output for comparison (trim trailing whitespace, normalize line endings).
 * @param {string} s
 * @returns {string}
 */
function normalize(s) {
  return s.replace(/\r\n/g, '\n').trim();
}

describe('Chart Type Snapshot E2E', () => {
  describe('bar', () => {
    it('output matches baseline for bar chart with sales.csv', () => {
      const r = runCli([
        '--file', example('sales.csv'),
        '--chart', 'bar',
        '--key', 'department',
        '--value', 'revenue',
      ]);
      assertExitCode(r, 0);
      assert.strictEqual(normalize(r.stdout), normalize(readBaseline('bar')));
    });
  });

  describe('scatter', () => {
    it('output matches baseline for scatter chart with scatter.csv', () => {
      const r = runCli([
        '--file', example('scatter.csv'),
        '--chart', 'scatter',
      ]);
      assertExitCode(r, 0);
      assert.strictEqual(normalize(r.stdout), normalize(readBaseline('scatter')));
    });
  });

  describe('sparkline', () => {
    it('output matches baseline for sparkline chart with sales.csv', () => {
      const r = runCli([
        '--file', example('sales.csv'),
        '--chart', 'sparkline',
        '--key', 'department',
        '--value', 'growth',
      ]);
      assertExitCode(r, 0);
      assert.strictEqual(normalize(r.stdout), normalize(readBaseline('sparkline')));
    });
  });

  describe('pie', () => {
    it('output matches baseline for pie chart with sales.csv', () => {
      const r = runCli([
        '--file', example('sales.csv'),
        '--chart', 'pie',
        '--key', 'department',
        '--value', 'revenue',
      ]);
      assertExitCode(r, 0);
      assert.strictEqual(normalize(r.stdout), normalize(readBaseline('pie')));
    });
  });

  describe('donut', () => {
    it('output matches baseline for donut chart with sales.csv', () => {
      const r = runCli([
        '--file', example('sales.csv'),
        '--chart', 'donut',
        '--key', 'department',
        '--value', 'revenue',
      ]);
      assertExitCode(r, 0);
      assert.strictEqual(normalize(r.stdout), normalize(readBaseline('donut')));
    });
  });

  describe('gauge', () => {
    it('output matches baseline for gauge chart with sales.csv (growth values 0-100)', () => {
      const r = runCli([
        '--file', example('sales.csv'),
        '--chart', 'gauge',
        '--key', 'department',
        '--value', 'growth',
      ]);
      assertExitCode(r, 0);
      assert.strictEqual(normalize(r.stdout), normalize(readBaseline('gauge')));
    });
  });

  describe('bullet', () => {
    it('output matches baseline for bullet chart with sales.csv', () => {
      const r = runCli([
        '--file', example('sales.csv'),
        '--chart', 'bullet',
        '--key', 'department',
        '--value', 'revenue',
      ]);
      assertExitCode(r, 0);
      assert.strictEqual(normalize(r.stdout), normalize(readBaseline('bullet')));
    });
  });
});

function assertExitCode(result, expectedCode, label = 'exit code') {
  if (result.exitCode !== expectedCode) {
    throw new Error(`${label}: expected ${expectedCode}, got ${result.exitCode}. stderr: ${result.stderr}`);
  }
}
