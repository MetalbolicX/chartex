# Plan 003: Unify user-visible error messages into one structured shape

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 2435cb5..HEAD -- src/ src/CLI/Main.res test/e2e/errors.test.mjs`
> If the error-throwing sites listed below changed, re-inventory with
> `grep -rn "throwWithMessage\|Error:" src/` before proceeding.

## Status

- **Priority**: P2
- **Effort**: M
- **Risk**: MED (changes user-visible strings; E2E error tests and unit tests
  assert exact text)
- **Depends on**: plans/001-wire-main-to-chart-registry.md (Main.res shape),
  plans/002-cli-resi-coverage.md (interfaces pin the validation surface)
- **Category**: dx
- **Planned at**: commit `2435cb5`, 2026-08-14

## Why this matters

The CLI's error output is the product's UX, and today it is inconsistent:
most chart errors carry an `Error: ` prefix, one dispatcher error does not,
parser errors read like log lines, and the reason vocabulary varies per chart
("contains NaN values" vs "contains non-finite value" style drift). Anyone
scripting against `chartex` (checking exit codes + stderr text) has to know a
dozen one-off formats. A single shape — `Error: <Origin> <reason>` — makes
output greppable, docs writable, and future messages predictable. This was
proposed in the original spec-007 draft and deliberately deferred; this plan
is that deferred item.

## Current state

Inventory of user-visible error strings (throw sites at planning time):

**Charts** (all via `JsError.throwWithMessage`):
- `src/Charts/ChartValidation.res:8` — `"Error: " ++ chartName ++ " chart requires at least one data point"` (shared; the ONE already-structured message)
- Bar/Pie/Donut/Gauge/Bullet/Sparkline/Scatter — per-chart pairs:
  `"Error: <Chart> chart data contains NaN values"` and
  `"Error: <Chart> chart data contains infinite values"` (call sites in each
  chart's value loop; Scatter validates x and y arrays, Sparkline validates
  the values array — added in commit `2ed7af6`)
- Bullet/Bar negative & all-zero guards (via `ensureNoNegative` /
  `ensureAtLeastOnePositive` in ChartValidation) — callers pass bespoke
  messages; check `src/Charts/Bar.res` / `Bullet.res` call sites for exact
  text
- `src/Charts/Gauge.res:33` — `"Error: Gauge value must be between 0 and 100"`
  — user-reachable live throw site, discovered during execution; missing the
  `chart` infix that all other chart errors carry. **AMENDED 2026-08-14**:
  conform to `Error: Gauge chart value must be between 0 and 100`.
- `src/CLI/Main.res:99` — `"Scatter chart requires scatter data"` — **no
  `Error:` prefix** (the known inconsistency; string preserved verbatim by
  Plan 001). REMOVED by Plan 001 — Adapter catches the case earlier with
  `"Missing scatter fields 'series', 'x' or 'y'"`.

**Parser / stream path** (returned as `Error(...)` values or thrown):
- `"Row limit exceeded"`, `"Unterminated quoted CSV field"`,
  `"Malformed JSON array payload"`, `"Incomplete JSON array input"`,
  `"Unknown input format"`, `"No input received"` — produced in
  `src/CLI/Parser*.res`, surfaced by `Main.runWithOptions`'s catch-all
  (`"Renderer error"` for anonymous exceptions).

**Tests that pin current text** (must be updated in lockstep):
- `test/e2e/errors.test.mjs` — 6 E2E cases asserting stderr/stdout content
- `test/res/TestParser.res` — error-path tests assert exact messages
  (e.g. the CSV unterminated-quote test asserts the exact string)
- `test/res/TestChartValidation.res` — 16 helper tests
- `test/res/TestCharts.res` — the 2026-08 validation tests added in
  `2ed7af6` catch `JsExn(_)` generically (do NOT assert text — safe)

**Target shape** (decision recorded in the 007 exploration, revived here):

```
Error: <Origin> <reason>
```

- `<Origin>` ∈ { chart name, `Parser`, `CLI` } — e.g.
  `Error: Pie chart data contains NaN values` (already matches),
  `Error: Parser unterminated quoted CSV field`,
  `Error: CLI scatter chart requires scatter data`.

## Commands you will need

| Purpose | Command | Expected on success |
|---|---|---|
| Inventory | `grep -rn "throwWithMessage" src/` | full throw-site list |
| Build | `npm run res:build` | exit 0, zero warnings |
| Unit tests | `npm run res:test` | all pass (count may move if you add tests) |
| E2E tests | `npm run test:e2e` | `fail 0` |

## Scope

**In scope**:
- `src/Charts/ChartValidation.res` (+ `.resi` if signatures change)
- `src/Charts/{Bar,Pie,Donut,Gauge,Bullet,Sparkline,Scatter}.res` — call-site
  message strings only
- `src/CLI/Main.res` — the scatter-dispatch error and `"Renderer error"`
- `src/CLI/ChartRegistry.res:79` — `"Internal error: Unhandled chart type"` is
  OUT OF SCOPE: dead code (Adapter rejects scatter-on-categorical earlier),
  not user-visible. Cleaned up in a future dead-code pass.
- `src/CLI/Parser*.res` — error strings only
- `test/e2e/errors.test.mjs`, `test/res/TestParser.res`,
  `test/res/TestChartValidation.res` — assertion updates in lockstep

**Out of scope**:
- Exit codes / process behavior (`Main.runWithOptions` result plumbing).
- Any structural error API (typed error variants, error codes) — strings only.
- `bin/ChartexCli.res` unless it hardcodes a message (check; expect not).

## Git workflow

- One commit: `feat(cli): unify error messages to 'Error: <Origin> <reason>' shape`
- Tests and source MUST land in the same commit (repo rule: tests stay with
  the code they verify).

## Steps

### Step 1: Freeze the inventory as a table

Run the inventory grep; write the current string → target string mapping as a
table in the commit message body (or PR description). Every mapping must keep
`<reason>` lowercase and end without punctuation.

**Verify**: table covers every grep hit — count matches.

### Step 2: Update ChartValidation helpers first

`ensureNonEmpty` already produces the target shape — leave it. Extend the
other helpers so callers pass only `<reason>` fragments where practical, or
keep explicit full strings at call sites if touching helper signatures would
ripple (prefer the smaller diff; this plan does not mandate helper redesign).

**Verify**: `npm run res:build` → zero warnings.

### Step 3: Update all call sites + the two known outliers

Apply the mapping: every chart NaN/infinite message stays as-is (already
shaped); `Main.res`'s `"Scatter chart requires scatter data"` becomes
`"Error: CLI scatter chart requires scatter data"`; parser errors gain the
`Error: Parser ` prefix; `"Renderer error"` becomes
`"Error: CLI renderer error"`. Update `test/e2e/errors.test.mjs` and the
asserting unit tests in the same pass.

**Verify**: `npm run res:build && npm run res:test && npm run test:e2e` →
all green; `grep -rn "throwWithMessage(\"" src/ | grep -v "Error: "` → empty
(no unprefixed throw sites left).

### Step 4: Add regression coverage for the shape

Add ONE unit test that iterates representative throw paths (empty data → any
chart; NaN value → Sparkline; scatter+categorical → Main) and asserts each
message matches `/^Error: [A-Z][a-zA-Z]+ /` style prefixing (use
`String.startsWith("Error: ")`). Model after `testCharts.res`'s
`testSparklineFiniteValidation` helper pattern (try/catch `JsExn(_)`).

**Verify**: `npm run res:test` → all pass including the new shape test.

## Test plan

- Lockstep updates listed in Step 3.
- One new shape-regression test (Step 4).
- E2E `errors.test.mjs` remains 6 cases, updated expectations.

## Done criteria

- [ ] `grep -rn "throwWithMessage(\"" src/ | grep -v "Error: "` → empty
- [ ] `npm run res:build` → zero warnings
- [ ] `npm run res:test` → all pass
- [ ] `npm run test:e2e` → fail 0
- [ ] `git status` confined to in-scope files
- [ ] `plans/README.md` status row updated

## STOP conditions

- A consumer outside the repo (published npm package docs, README examples)
  pins an old string you cannot update here — flag for a semver decision.
  (`package.json` is at `2.0.0`; message changes are user-visible → the
  maintainer may want to batch this into a minor bump.)
- An asserting test cannot be updated without changing what it tests
  structurally.
- The inventory in Step 1 reveals throw sites not listed above (new drift) —
  re-plan rather than improvise.

## Maintenance notes

- This is a user-visible string change on a published package — worth a line
  in release notes: "CLI error output now consistently starts with
  `Error: <Origin> …`".
- Future rule (enforce in review, not code): every new `throwWithMessage`
  starts with `"Error: "`. The Step 4 test only samples — it cannot enforce
  globally.
- Plans 001/002 must land first: 001 moves the scatter error's home, 002 pins
  interfaces so this plan's diff stays string-only.
