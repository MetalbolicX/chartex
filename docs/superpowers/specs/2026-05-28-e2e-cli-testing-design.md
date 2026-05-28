# E2E CLI Testing Design — chartex

**Date**: 2026-05-28
**Type**: Testing infrastructure

---

## Goal

Exercise the complete chartex CLI pipeline end-to-end: argument parsing → format detection → data parsing → data adaptation → chart rendering → output verification — using the Node built-in test runner with content-based assertions.

---

## Decisions Made

| Decision | Choice | Rationale |
|---|---|---|
| Assertion strategy | Content-based | Stable, fast, no snapshot churn across terminal sizes |
| Test runner | Node built-in (`node:test` + `node:assert`) | No new deps; `node --test` is available in Node 22+ |
| Error coverage | Full | Invalid input, missing files, empty data, bad flags all verified |
| File organization | One test file per chart type + flags/stdin/errors | Focused; easy to locate failures |

---

## Architecture

E2E tests invoke `bin/ChartexCli.res.mjs` via `child_process.execFileSync`, capturing stdout, stderr, and exit code. No mocking — the full stack runs.

Each test file is a plain ES module using `node:test` with `describe`/`it`/`test` blocks and `node:assert` assertions.

**Assertions check**:
- `stdout` contains expected keys, axes, style characters
- `stderr` contains error messages for invalid inputs
- `exitCode` is 0 for success, non-zero for errors

---

## File Structure

```
test/e2e/
├── helpers.mjs           # Shared: runCli(), fixture(), assertion helpers
├── bar.test.mjs          # Bar chart E2E
├── scatter.test.mjs      # Scatter chart E2E
├── sparkline.test.mjs    # Sparkline chart E2E
├── flags.test.mjs        # CLI flag behavior
├── stdin.test.mjs        # Stdin piping
├── errors.test.mjs       # Error and edge cases
└── fixtures/            # Symlink to test/cli/fixtures
```

---

## Shared Helper API (`helpers.mjs`)

```js
/**
 * Run the CLI with the given arguments.
 * @param {string[]} args
 * @param {{ timeout?: number }} [opts]
 * @returns {{ stdout: string, stderr: string, exitCode: number }}
 */
export function runCli(args, opts = {}) { ... }

/** Resolve path to a fixture file. */
export function fixture(name) { ... }

/** Assert stdout contains substring. */
export function assertContains(stdout, substring, label) { ... }

/** Assert stdout does NOT contain substring. */
export function assertNotContains(stdout, substring, label) { ... }

/** Assert exit code matches expected. */
export function assertExitCode(result, expectedCode, label) { ... }

/** Assert stderr contains substring. */
export function assertStderrContains(stderr, substring, label) { ... }
```

`runCli` wraps `execFileSync` with a 5-second timeout, captures `{ stdout, stderr, status }`, and throws on timeout. All CLI invocations route through this helper so timeout and error handling is consistent.

---

## Test Files

### `bar.test.mjs`

| Test | Command | Assertion |
|---|---|---|
| NDJSON bar | `--file example.ndjson --format ndjson --chart bar` | stdout includes keys from data |
| CSV bar | `--file example.csv --format csv --chart bar` | stdout includes keys |
| JSON bar | `--file example.json --format json --chart bar` | stdout includes keys |
| Custom field mapping | `--file example.csv --chart bar --key department --value growth` | stdout includes "growth" values |
| No-header CSV | `--file example.csv --no-header --chart bar` | stdout includes `col_0` labels |

### `scatter.test.mjs`

| Test | Command | Assertion |
|---|---|---|
| NDJSON scatter | `--file scatter.ndjson --format ndjson --chart scatter` | stdout includes series names and axes |
| CSV scatter | `--file scatter.csv --format csv --chart scatter` | stdout includes series names and axes |
| JSON scatter | `--file scatter.json --format json --chart scatter` | stdout includes series names and axes |
| Field mapping | `--file scatter.csv --chart scatter --series series --x-key x --y-key y` | stdout includes series labels |
| Auto-detect | `--file scatter.ndjson --chart scatter` | stdout includes axes |

### `sparkline.test.mjs`

| Test | Command | Assertion |
|---|---|---|
| NDJSON sparkline | `--file sales.ndjson --chart sparkline --key department --value growth` | stdout includes `|` Y-axis |
| CSV sparkline | `--file sales.csv --chart sparkline --key department --value growth` | stdout includes `|` Y-axis |
| JSON sparkline | `--file sales.json --chart sparkline --key department --value growth` | stdout includes `|` Y-axis |
| Custom width/height | `--file sales.csv --chart sparkline --key department --value growth --width 60 --height 10` | stdout renders without crashing |

### `flags.test.mjs`

| Test | Command | Assertion |
|---|---|---|
| `--help` | `--help` | stdout includes "Usage:" and flag descriptions |
| `--version` | `--version` | stdout includes version string matching `package.json` |
| `--no-header` | `--file sales-no-header.csv --format csv --no-header --chart bar --key col_0 --value col_1` | stdout includes `col_0` labels (sales-no-header.csv is copied to test/cli/fixtures/) |
| `--max-rows` | `--file sales.csv --format csv --max-rows 2 --chart bar` | output is shorter than full data |
| Auto-detect CSV | `--file example.csv --chart bar` | stdout includes bar chart output |
| `-f` short flag | `-f example.csv --format csv --chart bar` | same as `--file` |

### `stdin.test.mjs`

| Test | Command | Assertion |
|---|---|---|
| NDJSON stdin | `cat sales.ndjson \| node ... --chart bar --key department --value revenue` | stdout includes bar chart |
| CSV stdin | `cat sales.csv \| node ... --format csv --chart bar --key department --value revenue` | stdout includes bar chart |
| Auto-detect stdin | `cat sales.ndjson \| node ... --chart bar` | stdout includes bar chart (no --format) |

### `errors.test.mjs`

| Test | Command | Assertion |
|---|---|---|
| Missing file | `--file nonexistent.csv --format csv --chart bar` | exitCode ≠ 0, stderr includes error |
| Invalid format | `--file example.csv --format ndjson --chart bar` | exitCode ≠ 0, stderr includes parse/format error |
| Empty data | `--file empty.csv --format csv --chart bar` | exitCode ≠ 0, stderr includes "at least one data point" |
| Invalid max-rows | `--file sales.csv --format csv --max-rows notanumber` | exitCode ≠ 0, stderr includes parse error |
| Bad NDJSON line | `--file bad.ndjson --format ndjson --chart bar` | exitCode ≠ 0, stderr includes parse error |
| Missing required fields | `--file scatter.csv --chart scatter --series series` (no x-key/y-key) | exitCode ≠ 0, stderr includes missing field error |

---

## Fixtures

Reuse `test/cli/fixtures/` directly via `helpers.fixture()`:
- `example.csv` — categorical with header
- `example.json` — same data as JSON array
- `example.ndjson` — same data as NDJSON
- `scatter.csv` — scatter data with header

Additional fixtures to create in `test/cli/fixtures/`:
- `empty.csv` — empty file (for empty-data error test)
- `bad.ndjson` — valid NDJSON with one invalid JSON line (for bad-NDJSON error test)
- `sales-no-header.csv` — categorical data without header (for `--no-header` test; same as `examples/data/sales-no-header.csv`)

---

## package.json Integration

```json
"test:e2e": "node --test test/e2e/*.test.mjs"
```

Run: `npm run test:e2e`

The existing `test/cli/cli.integration.js` can be retired or kept as a smoke check — E2E tests supersede it.

---

## What This Does NOT Cover

- **Visual regression**: No snapshot testing; chart output character-by-character not verified
- **Terminal rendering**: ANSI codes may not render identically in CI/non-TTY environments
- **Library API**: The Node API (if any) for programmatic use
- **Performance**: Benchmarks or latency tests

---

## Out of Scope

- Refactoring the existing unit test suite
- Adding coverage reports
- CI/CD pipeline configuration
