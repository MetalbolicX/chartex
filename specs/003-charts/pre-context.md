# Pre-Context — F003-charts

## Runtime Exploration Results

Skipped — library project, no UI to explore.

## Source Reference

| File Path | Role | Rebuild Target |
|-----------|------|---------------|
| `src/charts/bar.ts` | Vertical bar chart renderer | `src/Charts/Bar.res` |
| `src/charts/bullet.ts` | Horizontal bullet chart renderer | `src/Charts/Bullet.res` |
| `src/charts/pie.ts` | Pie chart renderer + recursive segment assignment | `src/Charts/Pie.res` |
| `src/charts/donut.ts` | Donut chart (delegates to pie) | `src/Charts/Donut.res` |
| `src/charts/gauge.ts` | Semi-circular gauge renderer | `src/Charts/Gauge.res` |
| `src/charts/scatter.ts` | 2D scatter plot with axes | `src/Charts/Scatter.res` |
| `src/charts/sparkline.ts` | Sparkline with linear interpolation | `src/Charts/Sparkline.res` |

## Source Behavior Inventory

| ID | Source File | Function/Method | Behavior Description | Priority | Origin |
|----|-------------|----------------|---------------------|----------|--------|
| B020 | `src/charts/bar.ts` | `bar(data, opts)` | Renders vertical bar chart string with ratio-based height | P1 | extracted |
| B021 | `src/charts/bullet.ts` | `bullet(data, opts)` | Renders horizontal bullet chart with width-proportional bars | P1 | extracted |
| B022 | `src/charts/pie.ts` | `pie(data, opts, isDonut?)` | Renders pie/donut chart with atan2 segment assignment | P1 | extracted |
| B023 | `src/charts/pie.ts` | `getPadChar(styles, values, param, gapChar)` | Recursive function to determine segment style by angle | P2 | extracted |
| B024 | `src/charts/donut.ts` | `donut(data, opts)` | Delegates to pie with isDonut=true | P1 | extracted |
| B025 | `src/charts/gauge.ts` | `gauge(data, opts)` | Renders semi-circular gauge with percentage display | P1 | extracted |
| B026 | `src/charts/scatter.ts` | `scatter(data, options)` | Renders 2D scatter plot with linear scale and axes | P1 | extracted |
| B027 | `src/charts/sparkline.ts` | `sparkline(data, options)` | Renders sparkline with linear interpolation between points | P1 | extracted |

## UI Component Features

N/A — library project, no UI components.

## Interaction Behavior Inventory

N/A — library project, no interactive UI.

## Foundation Decisions

N/A — custom framework, no Foundation module.

## Foundation Dependencies

None — this Feature has no Foundation dependencies.

## Naming Remapping

None — project name unchanged.

## Static Resources

None.

## Environment Variables

None.

## Feature Contracts

F001-types provides:
- All config types (barConfig, bulletConfig, scatterConfig, gaugeConfig, pieConfig, donutConfig, sparklineConfig)
- All options types (barOptions, bulletOptions, etc.)
- `accessor<'data, 'result>` generic type
- `backgroundColor` variant

F002-core provides:
- `Ansi.bg()`, `Ansi.fg()` — color rendering
- `Terminal.width()`, `Terminal.height()` — dimension defaults
- `Validate.data()` — input validation
- `Json.string()`, `Json.number()` — accessor helpers

## For /speckit.specify

### Existing Feature Summary

F003-charts contains 7 chart implementations. Each chart follows the same pattern: validate data → merge options with defaults → render grid/string. The rendering algorithms use nested loops (bar, gauge, pie) or linear interpolation (sparkline, scatter).

### Migration Notes

**Per-chart migration:**

| Chart | Lines (TS) | Key Algorithm | ReScript Notes |
|-------|-----------|---------------|----------------|
| Bar | 99 | Nested loop: height × columns, ratio-based fill | `Array.reduce` or recursive helper |
| Bullet | 78 | forEach with repeat, multi-line bars | `Array.forEach` with accumulator |
| Pie | 94 | Nested loop + atan2 + recursive getPadChar | Natural recursion in ReScript |
| Donut | 26 | Delegates to pie | Same pattern |
| Gauge | 75 | Nested loop, semi-circle (i < 0), atan2 | Similar to pie |
| Scatter | 120 | Grid fill + axis labels + linear scale | `Array.from` for grid, `Array.forEach` for points |
| Sparkline | 119 | Grid fill + linear interpolation + axis | `Array.from` for grid, interpolation helper |

**API change (all charts):**
```typescript
// Current
bar(data: BarChartDatum[], opts?: BarChartOptions): string

// New
Bar.make(data: array<'data>, ~config: barConfig<'data>, ~options: barOptions=?, unit): string
```

**Imperative → Functional:**
- `for` loops → `Array.reduce` or recursive helpers
- `let result = ""; result += ...` → accumulator pattern
- `let grid = Array.from(...)` → same pattern in ReScript

### Edge Cases

- **Empty data**: `Validate.data()` throws on empty array — same behavior as current `verifyData()`
- **Single data point**: Scatter/sparkline handle single point (min === max, scale = 1)
- **Zero values**: Bar chart handles value=0 (no bar rendered), gauge handles value=0 (empty gauge)
- **Large values**: No overflow concern — all calculations use float
- **ANSI in style**: Style strings can contain ANSI escape codes (from `Ansi.bg`/`Ansi.fg`) — must preserve raw string

## For /speckit.plan

### Architecture Decisions

- One module per chart type (7 modules)
- Each module exports a single `make` function
- Internal helpers (getPadChar, padMid, maxKeyLen) are private to each module
- Grid-based charts (scatter, sparkline) use `array<array<string>>` for the grid
- String-based charts (bar, bullet) use string concatenation with accumulator

### Dependencies

- F001-types: All config and options types
- F002-core: Ansi, Terminal, Validate, Json
- Js.Math: `atan2`, `pow`, `round`, `floor`, `max`, `min`, `abs`
- Js.Array: `reduce`, `forEach`, `map`, `from`, `length`
- Js.String: `repeat`, `padStart`, `padEnd`

## For /speckit.analyze

### Key Observations

- 7 chart types with ~600 lines total (TypeScript) → ~400-500 lines (ReScript)
- Pie and Donut share the same rendering algorithm — Donut is a thin wrapper
- Scatter and Sparkline share axis rendering logic — potential for shared helper
- All charts are pure functions: data + config + options → string
- No side effects except terminal dimension detection (via Terminal module)
