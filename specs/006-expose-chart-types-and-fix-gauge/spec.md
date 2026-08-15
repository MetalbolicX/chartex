# Feature Specification: 006 — Expose Chart Types & Fix Gauge Truncation

**Feature Branch**: `006-expose-chart-types-and-fix-gauge`
**Created**: 2026-07-23
**Status**: Implemented
**Source commit**: `ed12ffc` on `main`
**Input**: Audit findings recorded under Engram topic `audit/rescript-maintainability` and the refactor plan topic `refactor/chartex-phases-plan`.

---

## User Scenarios & Testing

### User Story 1 — Request any chart type from the CLI (Priority: P1)

A developer running `node bin/ChartexCli.res.mjs --chart pie|donut|gauge|bullet --file data.csv --key label --value amount` gets the requested chart type instead of silently receiving a bar chart.

**Why this priority**: The four chart types existed and were tested but were unreachable from the CLI. Users either assumed the types were broken or worked around the gap manually.

**Independent Test**: Each of `pie`, `donut`, `gauge`, `bullet` can be requested via `--chart` and produces output distinct from a bar chart for the same input.

**Acceptance Scenarios**:

1. **Given** a CSV with key/value columns, **When** the user runs `--chart pie`, **Then** the output contains a pie-shaped legend with percentages.
2. **Given** a CSV with key/value columns, **When** the user runs `--chart donut`, **Then** the output contains a donut-shaped legend with percentages.
3. **Given** a CSV with one row whose percentage is 75, **When** the user runs `--chart gauge`, **Then** the output contains the 0 and 100 scale labels and the configured key.
4. **Given** a CSV with two rows, **When** the user runs `--chart bullet`, **Then** the output contains both keys with bracketed values (e.g. `[80]`).
5. **Given** `--help` is invoked, **When** the help text is displayed, **Then** the `--chart` option lists `bar|scatter|sparkline|pie|donut|gauge|bullet`.

---

### User Story 2 — Gauge renders the full percentage at every boundary (Priority: P1)

A developer rendering a gauge with any percentage between 0 and 100 inclusive sees the correct numeric value at the gauge center, including 100%.

**Why this priority**: A gauge that truncates 100% to "10" is a silent data corruption bug — the same percentage was visible in the scale label below, so a casual viewer would notice the inconsistency.

**Independent Test**: Render a gauge at 0%, 50%, 99%, and 100% and inspect the center cell on each output. Every cell must display the requested percentage as digits.

**Acceptance Scenarios**:

1. **Given** a gauge value of 0.0, **When** the gauge is rendered, **Then** the center cell displays "0" and the scale labels show "0" and "100".
2. **Given** a gauge value of 50.0, **When** the gauge is rendered, **Then** the center cell displays "50".
3. **Given** a gauge value of 99.0, **When** the gauge is rendered, **Then** the center cell displays "99".
4. **Given** a gauge value of 100.0, **When** the gauge is rendered, **Then** the center cell displays "100" (not "10" from a slice truncation).

---

### User Story 3 — Chart code is easier to maintain (Priority: P2)

A developer reading `src/Charts/` or `src/CLI/Parser.res` finds validation logic and buffer-clearing logic in one place instead of duplicated across modules.

**Why this priority**: Lower priority than user-visible defects, but the duplication was the root cause that allowed the dispatch gap to slip past review — five chart modules each carried their own copy of the empty-data guard, none of which triggered a compiler warning when the dispatch gap existed.

**Independent Test**: `grep` for the literal string `"requires at least one data point"` returns exactly one production-code location (inside `ChartValidation.ensureNonEmpty`).

**Acceptance Scenarios**:

1. **Given** the empty-data guard, **When** the codebase is searched, **Then** the message `"chart requires at least one data point"` appears exactly once in production code.
2. **Given** parser buffer clearing, **When** the codebase is searched, **Then** `Array.splice(~start=0, ~remove=` appears zero times in production code.
3. **Given** `sparklineOptions`, **When** the type is referenced, **Then** it has no `tolerance` field.

---

### Edge Cases

- `--chart scatter` against categorical (key/value) input throws `"Scatter chart requires scatter data"` rather than silently rendering as bar.
- `--chart auto` (default) against categorical input falls back to bar.
- Empty input arrays still throw `Error: <ChartName> chart requires at least one data point` through the centralized `ensureNonEmpty`.
- Gauge with value < 0 or > 100 still throws `Error: Gauge value must be between 0 and 100`.
- Gauge at 100% renders "100" with a one-column right-side shift; this is the accepted tradeoff for correct percentage display.

---

## Functional Requirements

### FR-001 — Chart Type Variants

The `Bindings.Util.chartType` polymorphic variant MUST include `#pie`, `#donut`, `#gauge`, and `#bullet` in addition to `#auto`, `#bar`, `#scatter`, `#sparkline`.

### FR-002 — CLI Argument Parsing

`Args.parseChartType` MUST map the strings `"pie"`, `"donut"`, `"gauge"`, and `"bullet"` to their respective variants. Any unknown string MUST map to `#auto`.

### FR-003 — Help Text

`Args.helpText` MUST advertise the four new chart types in the `--chart` option's value list.

### FR-004 — Render Dispatch

`Main.render` MUST contain an exhaustive match on the chart-type variant for `Adapter.Categorical` data. Each variant MUST route to the corresponding chart module with a categorical config object.

### FR-005 — Gauge Percentage Display

`Gauge.make` MUST render the center cell with the full percentage integer (0-100), not a two-character slice.

### FR-006 — Shared Empty-Data Validation

`ChartValidation.ensureNonEmpty(data, chartName)` MUST exist and replace the duplicated empty-data guard in every chart renderer module.

### FR-007 — Finite-Value Validation Unification

`Bar`, `Pie`, `Donut`, and `Bullet` MUST use `ChartValidation.ensureFinite` for NaN/Infinity checks.

### FR-008 — Parser Buffer Clearing

`Parser.res` MUST clear `lineChars`, `fieldChars`, and `currentChunks` via `while … pop` loops rather than `Array.splice(~start=0, ~remove=len, ~insert=[])`.

### FR-009 — Remove Dead Sparkline Tolerance

The `tolerance` field MUST be removed from `sparklineOptions` in both `.res` and `.resi`. The `_tolerance` binding in `Sparkline.res` MUST be removed.

### FR-010 — Remove Unreachable Gauge Branch

The unreachable `None` arm of the `data[0]` pattern match in `Gauge.res` MUST be replaced with `Option.getExn`.

---

## Success Criteria

| ID | Criterion | Measured By |
|----|-----------|-------------|
| SC-001 | All 7 chart types reachable from CLI | `Args.parseChartType` covers every variant string |
| SC-002 | Gauge renders 100% correctly | `TestCharts.testGaugePercentage100` passes |
| SC-003 | Build is clean | `npm run res:build` exits 0 with only pre-existing deprecation warnings |
| SC-004 | Unit tests pass | `npm run res:test` reports 141/141 passing |
| SC-005 | E2E tests pass | `npm run test:e2e` reports 29/29 passing |
| SC-006 | Empty-data validation centralized | `grep -rn "requires at least one data point" src/` returns exactly one production-code hit |
| SC-007 | Parser splice clear removed | `grep -rn "Array.splice" src/` returns zero hits in `Parser.res` |
| SC-008 | `tolerance` removed from sparklineOptions | `grep -rn "tolerance" src/Config/` returns zero hits |

---

## Key Entities

| Entity | Owner | Change |
|--------|-------|--------|
| `chartType` variant | `Bindings.Util` | Extended with 4 variants |
| `chartType` parser | `Args.parseChartType` | Extended with 4 cases |
| `helpText` | `Args` | Extended `--chart` value list |
| `*Config` records | `Main.res` | Added `pieConfig`, `donutConfig`, `gaugeConfig`, `bulletConfig` |
| `render` function | `Main.res` | Replaced wildcard arm with exhaustive dispatch |
| `ensureNonEmpty` | `ChartValidation` | New helper |
| `gauge` renderer | `Gauge.res` | Removed `Js.String.slice(~from=0, ~to_=2, pctStr)` |
| `sparklineOptions` | `Config.Types.{res,resi}` | Removed `tolerance` field |

## Out of Scope

- Structured parser error variant (`parseResult` → `Error({ message, category })`)
- `.resi` interface design for CLI modules
- Relocating parser types to `CliTypes.res`
- Pie/Donut rendering allocation optimization (deferred)
- Parser character-iteration optimization (deferred)
- Removing `ensureNoNaN` / `ensureNoInfinite` helpers (still directly tested; safe in a follow-up)
- Major-version bump for the `tolerance` removal (internal-only scope accepted)
