# E2E CLI Testing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a comprehensive E2E test suite for the chartex CLI using Node's built-in test runner, covering all chart types, input formats, CLI flags, stdin piping, and error cases.

**Architecture:** E2E tests invoke `bin/ChartexCli.res.mjs` via `child_process.execFileSync` through a shared `helpers.mjs` module. Each test file is a plain ES module using `node:test` + `node:assert`. Assertions are content-based (output includes/excludes strings, exit codes).

**Tech Stack:** Node 22+ built-in `node:test`, `node:assert`, `node:child_process`, `node:path`

---

## Phase 1: Infrastructure

### Task 1: Create test/e2e/helpers.mjs

**Files:**
- Create: `test/e2e/helpers.mjs`

- [ ] **Step 1: Write the helpers module**

```js
import { execFileSync } from 'node:child_process';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '../..');
const CLI = join(ROOT, 'bin/ChartexCli.res.mjs');
const FIXTURES = join(ROOT, 'test/cli/fixtures');

/**
 * Run the CLI with the given arguments.
 * @param {string[]} args
 * @param {{ timeout?: number, stdin?: string }} [opts]
 * @returns {{ stdout: string, stderr: string, exitCode: number }}
 */
export function runCli(args, opts = {}) {
  const { timeout = 5000, stdin } = opts;
  const result = execFileSync('node', [CLI, ...args], {
    encoding: 'utf8',
    timeout,
    stdio: stdin ? ['pipe', 'pipe', 'pipe'] : ['ignore', 'pipe', 'pipe'],
    input: stdin ?? null,
  });
  return result;
}

/** Resolve path to a fixture file under test/cli/fixtures/. */
export function fixture(name) {
  return join(FIXTURES, name);
}

/** Assert stdout contains substring. Throws on failure. */
export function assertContains(stdout, substring, label) {
  if (!stdout.includes(substring)) {
    throw new Error(`${label}: expected stdout to include "${substring}", got: ${stdout.slice(0, 200)}`);
  }
}

/** Assert stdout does NOT contain substring. */
export function assertNotContains(stdout, substring, label) {
  if (stdout.includes(substring)) {
    throw new Error(`${label}: expected stdout NOT to include "${substring}", got: ${stdout.slice(0, 200)}`);
  }
}

/** Assert exit code matches expected. */
export function assertExitCode(result, expectedCode, label) {
  if (result.exitCode !== expectedCode) {
    throw new Error(`${label}: expected exit code ${expectedCode}, got ${result.exitCode}. stderr: ${result.stderr}`);
  }
}

/** Assert stderr contains substring. */
export function assertStderrContains(stderr, substring, label) {
  if (!stderr.includes(substring)) {
    throw new Error(`${label}: expected stderr to include "${substring}", got: ${stderr.slice(0, 200)}`);
  }
}
```

- [ ] **Step 2: Verify helpers module loads without error**

Run: `node --input-type=module --eval "import './test/e2e/helpers.mjs'; console.log('OK')"`
Expected: prints "OK"

- [ ] **Step 3: Commit**

```bash
git add test/e2e/helpers.mjs
git commit -m "test(e2e): add helpers.mjs with runCli and assertion helpers"
```

---

### Task 2: Create E2E fixture files

**Files:**
- Create: `test/cli/fixtures/empty.csv`
- Create: `test/cli/fixtures/bad.ndjson`
- Copy: `examples/data/sales-no-header.csv` → `test/cli/fixtures/sales-no-header.csv`

- [ ] **Step 1: Create empty.csv**

```csv

```

- [ ] **Step 2: Create bad.ndjson** (valid NDJSON with one bad line)

```ndjson
{"key": "good", "value": 10}
NOT JSON
{"key": "also_good", "value": 20}
```

- [ ] **Step 3: Copy sales-no-header.csv**

Run: `cp examples/data/sales-no-header.csv test/cli/fixtures/sales-no-header.csv`

- [ ] **Step 4: Commit**

```bash
git add test/cli/fixtures/empty.csv test/cli/fixtures/bad.ndjson test/cli/fixtures/sales-no-header.csv
git commit -m "test(e2e): add fixture files for error case tests"
```

---

## Phase 2: Chart Type Tests

### Task 3: bar.test.mjs

**Files:**
- Create: `test/e2e/bar.test.mjs`
- Test: Run via `node --test test/e2e/bar.test.mjs`

- [ ] **Step 1: Write bar chart E2E tests**

```js
import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('Bar Chart E2E', () => {
  it('NDJSON bar chart includes keys from data', () => {
    const r = runCli(['--file', fixture('example.ndjson'), '--format', 'ndjson', '--chart', 'bar']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'A', 'NDJSON bar chart includes first key');
    assertContains(r.stdout, 'B', 'NDJSON bar chart includes second key');
  });

  it('CSV bar chart includes keys', () => {
    const r = runCli(['--file', fixture('example.csv'), '--format', 'csv', '--chart', 'bar']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'CSV bar chart includes department names');
  });

  it('JSON bar chart includes keys', () => {
    const r = runCli(['--file', fixture('example.json'), '--format', 'json', '--chart', 'bar']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'JSON bar chart includes department names');
  });

  it('Custom field mapping uses specified fields', () => {
    const r = runCli([
      '--file', fixture('example.csv'),
      '--chart', 'bar',
      '--key', 'department',
      '--value', 'growth',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '15', 'Custom field mapping uses growth values');
  });

  it('No-header CSV uses col_N naming', () => {
    const r = runCli([
      '--file', fixture('sales-no-header.csv'),
      '--format', 'csv',
      '--no-header',
      '--chart', 'bar',
      '--key', 'col_0',
      '--value', 'col_1',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'col_0', 'No-header CSV uses col_N field names');
  });
});
```

- [ ] **Step 2: Run bar tests to verify they pass**

Run: `node --test test/e2e/bar.test.mjs`
Expected: 5 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/e2e/bar.test.mjs
git commit -m "test(e2e): add bar chart E2E tests"
```

---

### Task 4: scatter.test.mjs

**Files:**
- Create: `test/e2e/scatter.test.mjs`

- [ ] **Step 1: Write scatter chart E2E tests**

```js
import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('Scatter Chart E2E', () => {
  it('NDJSON scatter chart includes series names and axes', () => {
    const r = runCli(['--file', fixture('scatter.ndjson'), '--format', 'ndjson', '--chart', 'scatter']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Group A', 'NDJSON scatter includes series name');
    assertContains(r.stdout, '|', 'NDJSON scatter includes Y-axis');
    assertContains(r.stdout, '_', 'NDJSON scatter includes X-axis');
  });

  it('CSV scatter chart includes series names', () => {
    const r = runCli(['--file', fixture('scatter.csv'), '--format', 'csv', '--chart', 'scatter']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Group A', 'CSV scatter includes series name');
    assertContains(r.stdout, '|', 'CSV scatter includes Y-axis');
  });

  it('JSON scatter chart includes series names', () => {
    const r = runCli(['--file', fixture('scatter.json'), '--format', 'json', '--chart', 'scatter']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Group A', 'JSON scatter includes series name');
  });

  it('Field mapping uses specified series/x/y keys', () => {
    const r = runCli([
      '--file', fixture('scatter.csv'),
      '--chart', 'scatter',
      '--series', 'series',
      '--x-key', 'x',
      '--y-key', 'y',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Group A', 'Field mapping includes series labels');
  });

  it('Auto-detect format from file content', () => {
    const r = runCli(['--file', fixture('scatter.ndjson'), '--chart', 'scatter']);
    assertExitCode(r, 0);
    assertContains(r.stdout, '|', 'Auto-detect NDJSON renders scatter with Y-axis');
  });
});
```

- [ ] **Step 2: Run scatter tests**

Run: `node --test test/e2e/scatter.test.mjs`
Expected: 5 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/e2e/scatter.test.mjs
git commit -m "test(e2e): add scatter chart E2E tests"
```

---

### Task 5: sparkline.test.mjs

**Files:**
- Create: `test/e2e/sparkline.test.mjs`

- [ ] **Step 1: Write sparkline E2E tests**

```js
import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertContains, assertExitCode } from './helpers.mjs';

describe('Sparkline E2E', () => {
  const baseArgs = ['--chart', 'sparkline', '--key', 'department', '--value', 'growth'];

  it('NDJSON sparkline includes Y-axis', () => {
    const r = runCli(['--file', fixture('example.ndjson'), '--format', 'ndjson', ...baseArgs]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '|', 'NDJSON sparkline includes Y-axis character');
  });

  it('CSV sparkline includes Y-axis', () => {
    const r = runCli(['--file', fixture('example.csv'), '--format', 'csv', ...baseArgs]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '|', 'CSV sparkline includes Y-axis character');
  });

  it('JSON sparkline includes Y-axis', () => {
    const r = runCli(['--file', fixture('example.json'), '--format', 'json', ...baseArgs]);
    assertExitCode(r, 0);
    assertContains(r.stdout, '|', 'JSON sparkline includes Y-axis character');
  });

  it('Custom width and height options do not crash', () => {
    const r = runCli([
      '--file', fixture('example.csv'),
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
```

- [ ] **Step 2: Run sparkline tests**

Run: `node --test test/e2e/sparkline.test.mjs`
Expected: 4 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/e2e/sparkline.test.mjs
git commit -m "test(e2e): add sparkline E2E tests"
```

---

## Phase 3: Flags, Stdin, and Errors

### Task 6: flags.test.mjs

**Files:**
- Create: `test/e2e/flags.test.mjs`

- [ ] **Step 1: Write CLI flags E2E tests**

```js
import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertContains, assertExitCode } from './helpers.mjs';

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
    // Version matches package.json semver pattern
    assert.match(r.stdout, /\d+\.\d+\.\d+/, '--version outputs semver');
  });

  it('--no-header uses col_N field naming', () => {
    const r = runCli([
      '--file', fixture('sales-no-header.csv'),
      '--format', 'csv',
      '--no-header',
      '--chart', 'bar',
      '--key', 'col_0',
      '--value', 'col_1',
    ]);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'col_0', '--no-header uses col_N naming');
  });

  it('--max-rows limits rows rendered', () => {
    const rFull = runCli(['--file', fixture('example.csv'), '--format', 'csv', '--chart', 'bar']);
    const rLimited = runCli(['--file', fixture('example.csv'), '--format', 'csv', '--chart', 'bar', '--max-rows', '1']);
    assertExitCode(rFull, 0);
    assertExitCode(rLimited, 0);
    if (rLimited.stdout.length >= rFull.stdout.length) {
      throw new Error('--max-rows=1 should produce shorter output than full');
    }
  });

  it('auto-detect format from CSV file content', () => {
    const r = runCli(['--file', fixture('example.csv'), '--chart', 'bar']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', 'Auto-detect CSV renders bar chart');
  });

  it('-f short flag works same as --file', () => {
    const r = runCli(['-f', fixture('example.csv'), '--format', 'csv', '--chart', 'bar']);
    assertExitCode(r, 0);
    assertContains(r.stdout, 'Engineering', '-f flag works same as --file');
  });
});
```

- [ ] **Step 2: Run flags tests**

Run: `node --test test/e2e/flags.test.mjs`
Expected: 6 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/e2e/flags.test.mjs
git commit -m "test(e2e): add CLI flags E2E tests"
```

---

### Task 7: stdin.test.mjs

**Files:**
- Create: `test/e2e/stdin.test.mjs`

- [ ] **Step 1: Write stdin piping E2E tests**

```js
import { describe, it } from 'node:test';
import assert from 'node:assert';
import { readFileSync } from 'node:fs';
import { runCli, assertContains, assertExitCode } from './helpers.mjs';

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
    assertContains(r.stdout, '|', 'NDJSON stdin renders bar with Y-axis');
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
```

- [ ] **Step 2: Run stdin tests**

Run: `node --test test/e2e/stdin.test.mjs`
Expected: 3 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/e2e/stdin.test.mjs
git commit -m "test(e2e): add stdin piping E2E tests"
```

---

### Task 8: errors.test.mjs

**Files:**
- Create: `test/e2e/errors.test.mjs`

- [ ] **Step 1: Write error case E2E tests**

```js
import { describe, it } from 'node:test';
import assert from 'node:assert';
import { runCli, fixture, assertExitCode, assertStderrContains } from './helpers.mjs';

describe('Error Cases E2E', () => {
  it('missing file returns non-zero exit and error message', () => {
    const r = runCli(['--file', 'nonexistent.csv', '--format', 'csv', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'missing file should fail');
    assertStderrContains(r.stderr, 'ENOENT', 'stderr includes ENOENT');
  });

  it('invalid format (CSV as NDJSON) returns parse error', () => {
    const r = runCli(['--file', fixture('example.csv'), '--format', 'ndjson', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'wrong format should fail');
  });

  it('empty data file returns non-zero with "at least one data point"', () => {
    const r = runCli(['--file', fixture('empty.csv'), '--format', 'csv', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'empty data should fail');
    assertStderrContains(r.stderr, 'at least one data point', 'empty data error message');
  });

  it('invalid --max-rows value returns parse error', () => {
    const r = runCli(['--file', fixture('example.csv'), '--format', 'csv', '--max-rows', 'notanumber', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'invalid max-rows should fail');
    assertStderrContains(r.stderr, '--max-rows', 'parse error mentions the flag name');
  });

  it('bad NDJSON line returns parse error', () => {
    const r = runCli(['--file', fixture('bad.ndjson'), '--format', 'ndjson', '--chart', 'bar']);
    assert.notStrictEqual(r.exitCode, 0, 'bad NDJSON should fail');
  });

  it('missing scatter required fields returns error', () => {
    const r = runCli([
      '--file', fixture('scatter.csv'),
      '--chart', 'scatter',
      '--series', 'series',
    ]);
    assert.notStrictEqual(r.exitCode, 0, 'missing x-key/y-key should fail');
  });
});
```

- [ ] **Step 2: Run error tests**

Run: `node --test test/e2e/errors.test.mjs`
Expected: 6 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/e2e/errors.test.mjs
git commit -m "test(e2e): add error case E2E tests"
```

---

## Phase 4: Integration

### Task 9: Add npm script and final verification

**Files:**
- Modify: `package.json`

- [ ] **Step 1: Add test:e2e script to package.json**

Read `package.json` lines 26-36 (scripts section), then add `"test:e2e": "node --test test/e2e/*.test.mjs"` to the scripts object.

Run: `node --test test/e2e/*.test.mjs`
Expected: all ~29 tests pass

- [ ] **Step 2: Run full E2E suite**

Run: `npm run test:e2e`
Expected: all tests pass

- [ ] **Step 3: Run existing unit tests to ensure nothing broke**

Run: `npm run res:test`
Expected: all unit tests still pass

- [ ] **Step 4: Run existing CLI integration check**

Run: `node test/cli/cli.integration.js`
Expected: "CLI integration checks passed"

- [ ] **Step 5: Commit package.json change**

```bash
git add package.json
git commit -m "test(e2e): add test:e2e npm script for full E2E suite"
```
