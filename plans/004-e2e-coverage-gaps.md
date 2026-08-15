# Plan 004: Close E2E coverage gaps for bullet, pie, donut, gauge, and boundary cases

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 2435cb5..HEAD -- test/e2e/`
> On any change, re-count per-file `it(` blocks and adjust the baseline table
> below before adding tests.

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW (test-only; no production edits)
- **Depends on**: none (independent of Plans 001–003, though running after 001
  exercises the final dispatch path)
- **Category**: tests
- **Planned at**: commit `2435cb5`, 2026-08-14

## Why this matters

The E2E suite (36 cases across 7 files) has strong bar/scatter coverage and
golden snapshots for all seven charts, but four chart types (bullet, pie,
donut, gauge) have ZERO dedicated behavioral E2E cases — they appear only in
the 7 snapshot tests, which assert full-output equality, not flags, field
mapping, or format interaction. If a flag like `--value` breaks gauge
rendering but happens to still match a stale baseline, nothing catches the
semantic regression. The validation work shipped in `2ed7af6` (NaN rejection,
empty-data rejection) also has no E2E representation — only unit tests.

## Current state

Per-file case counts at planning time (`grep -c "it(" test/e2e/*.test.mjs`):

| File | Cases | Covers |
|---|---|---|
| `test/e2e/bar.test.mjs` | 5 | bar × 3 input formats, `--key/--value`, `--no-header` |
| `test/e2e/scatter.test.mjs` | 5 | scatter happy paths + field mapping |
| `test/e2e/sparkline.test.mjs` | 4 | sparkline rendering + options |
| `test/e2e/flags.test.mjs` | 6 | `--width/--height/--style` style flags |
| `test/e2e/snapshots.test.mjs` | 7 | one golden per chart (bar, bullet, donut, gauge, pie, scatter, sparkline) vs `test/e2e/baselines/*.txt` |
| `test/e2e/errors.test.mjs` | 6 | error exits |
| `test/e2e/stdin.test.mjs` | 3 | stdin piping |

Gaps: no dedicated bullet/pie/donut/gauge files; no E2E for
empty-data/NaN-input rejection; no BOM-prefixed-input E2E (the fix shipped in
`34fe1e9` is covered only by unit assertions in `test/res/TestParser.res`).

Harness pattern (from `bar.test.mjs:1-17`):

```js
import { runCli, example, fixture, assertContains, assertExitCode } from './helpers.mjs';
// …
const r = runCli(['--file', example('sales.ndjson'), '--format', 'ndjson',
                  '--chart', 'bar', '--key', 'department', '--value', 'revenue']);
assertExitCode(r, 0);
assertContains(r.stdout, 'Engineering', 'message');
```

Helpers live in `test/e2e/helpers.mjs`; example fixtures under
`test/e2e/examples/` (check dir; `example('sales.ndjson')` implies it).
Unit-test baseline: `npm run res:test` → 161 tests. E2E baseline: 36.

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| E2E | `npm run test:e2e` | `fail 0`, count grows as tests land |
| Unit (sanity, untouched) | `npm run res:test` | 161 passed |
| Count cases | `grep -c "it(" test/e2e/<file>` | matches expected per-file count |

## Scope

**In scope** (create only):
- `test/e2e/circular.test.mjs` (or `pie.test.mjs` + `donut.test.mjs` if you
  prefer per-chart files — pick one convention and note it in the commit)
- `test/e2e/gauge.test.mjs`
- `test/e2e/bullet.test.mjs`
- New fixture files under the e2e examples dir as needed (e.g. a
  BOM-prefixed NDJSON fixture — create with printf so the BOM bytes are
  exact: `printf '\xEF\xBB\xBF…' > file`)

**Out of scope**:
- ANY file under `src/` — if a new test exposes a production bug, that is a
  STOP condition with a bug report, not an in-plan fix.
- Existing test files (no edits to bar/scatter/flags/snapshots/errors/stdin).
- Baselines in `test/e2e/baselines/` (do not regenerate).

## Git workflow

- One commit: `test(e2e): add bullet/pie/donut/gauge coverage + validation and BOM cases`

## Steps

### Step 1: Baseline the suite

**Verify**: `npm run test:e2e` → `fail 0` before touching anything.

### Step 2: Add per-chart happy-path + flag tests

For each of bullet, pie, donut, gauge: 2 cases — (a) happy path asserting a
known key/label appears (model after `bar.test.mjs:6-17`), (b) one
chart-specific option interaction (gauge: percentage of a 100% value renders
`100` — this was a real bug, see commit `ed12ffc`; pie/donut: legend contains
all keys; bullet: value labels render). That is 8 cases.

**Verify**: `npm run test:e2e` → fail 0, per-file counts +8.

### Step 3: Add validation-path E2E cases

3 cases modeled on `errors.test.mjs` (exit code + stderr assert): empty input
file → rejection; NDJSON with a NaN value (`{"v":"nan"}`? — no: pass a JSON
value that fails float parsing, or a literal large number is fine; check how
`Adapter.jsonToFloat` fails and craft the simplest input that reaches the
chart's NaN guard) → rejection with `NaN` in output; wrong-data-shape
(`--chart scatter` on categorical input) → the scatter-dispatch error.
**Verify**: `npm run test:e2e` → fail 0, +3.

### Step 4: Add BOM E2E case

Create `test/e2e/examples/bom-sales.ndjson` whose first line is prefixed with
the exact UTF-8 BOM (`\xEF\xBB\xBF`) followed by a normal NDJSON row. One
case: `--format auto` (or omit `--format`) + `--chart bar` → exit 0, keys
render. This pins the `34fe1e9` fix end-to-end.

**Verify**: `npm run test:e2e` → fail 0, +1 → total 48 cases (36 + 12).

## Test plan

The plan IS tests. Final count check: 36 → 48 (8 chart + 3 validation + 1
BOM). If you land fewer because a case folded into another, state the final
count in the commit body.

## Done criteria

- [ ] `npm run test:e2e` → fail 0, ≥ 48 cases
- [ ] `grep -c "it(" test/e2e/gauge.test.mjs` ≥ 2 (and equivalents for pie/donut/bullet)
- [ ] `git status` shows only new files under `test/e2e/`
- [ ] `npm run res:test` still 161 passed (proves no src/ drift)
- [ ] `plans/README.md` status row updated

## STOP conditions

- A new test fails against current `src/` — that is a discovered bug; write
  the failing case down, do not patch src/, do not weaken the assertion.
- `helpers.mjs` lacks a primitive you need (e.g. stderr capture) — extend the
  plan via a report rather than refactoring the harness silently.
- The examples fixture directory has a different layout than implied — adapt
  paths, but flag the mismatch in the commit body.

## Maintenance notes

- These tests intentionally duplicate some snapshot coverage at the
  behavioral level — snapshots catch byte drift, these catch semantic drift;
  both are wanted.
- When Plan 003 changes error strings, the 3 validation cases from Step 3
  will need expectation updates — listed here so whoever executes 003 greps
  for this file.
