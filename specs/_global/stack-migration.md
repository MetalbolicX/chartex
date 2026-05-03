# Stack Migration — TypeScript → ReScript v12

## Migration Overview

| Category | Current | New | Migration Complexity |
|----------|---------|-----|---------------------|
| Language | TypeScript 5.x | ReScript v12.2.0 | High — different paradigm (ML-family functional) |
| Build Tool | tsdown | rolldown + rollup-plugin-esbuild | Medium — already configured |
| Module System | ESModule (.mjs) | ESModule (.res.mjs) | Low — same output format |
| Type System | TypeScript interfaces | ReScript records + variants | Medium — structural → nominal |
| Runtime | Node.js | @rescript/runtime | Low — ReScript compiles to JS |
| Testing | None | rescript-test v8.0.0 | Low — already installed |
| Bundler | tsdown | rolldown | Low — already configured |

## Per-Component Migration Map

### Types Migration

| TypeScript | ReScript | Notes |
|------------|----------|-------|
| `interface BarChartDatum` | `type barConfig<'data> = { key: accessor<'data, string>, ... }` | Generic over input data |
| `interface BarChartOptions` | `type barOptions = { barWidth?: int, ... }` | Optional fields with `?` |
| `type BackgroundColor = "black" \| "red" \| ...` | `type backgroundColor = Black \| Red \| ...` | String union → variant |
| `interface ChartDatum` | Eliminated | Replaced by accessor pattern |

### API Design Migration

| TypeScript | ReScript | Notes |
|------------|----------|-------|
| `bar(data: BarChartDatum[], opts?)` | `Bar.make(data, ~config, ~options?, ())` | d3-style accessors |
| `parseCategoricalData(data, key, value, style)` | Eliminated | Accessors replace all parse helpers |
| `parseScatterData(data, cat, x, y, style)` | Eliminated | Scatter uses x/y accessors |
| `parseList(values, prefix, style)` | Eliminated | User provides accessors |
| `parseFromObject(data, style)` | Eliminated | User provides accessors |
| `parseCustomData(data, mapping, style)` | Eliminated | User provides accessors |
| `parseRow(data, keyFn, valueFn, style)` | Eliminated | Native accessor pattern |

### Utility Migration

| TypeScript | ReScript | Notes |
|------------|----------|-------|
| `bg(color, length)` | `Ansi.bg(~color, ~length)` | Named arguments |
| `fg(color, str)` | `Ansi.fg(~color, ~str)` | Named arguments |
| `getShellWidth()` | `Terminal.width()` | Simplified name |
| `getShellHeight()` | `Terminal.height()` | Simplified name |
| `verifyData(data)` | `Validate.data(data)` | Moved to Config module |
| `padMid(str, width)` | Internal helper in chart modules | Not exported |
| `maxKeyLen(data)` | Internal helper | Not exported |
| `curForward/Up/Down/Back` | `Ansi.cursorForward/Up/Down/Back` | Namespaced |
| `getOriginLen(str)` | Internal helper | Not exported |

### Chart Migration

| Chart | Source | Target | Key Changes |
|-------|--------|--------|-------------|
| Bar | `src/charts/bar.ts` | `src/Charts/Bar.res` | Accessor config, immutable loop → recursion/fold |
| Bullet | `src/charts/bullet.ts` | `src/Charts/Bullet.res` | Accessor config, same algorithm |
| Pie | `src/charts/pie.ts` | `src/Charts/Pie.res` | Recursive `getPadChar` → natural in ReScript |
| Donut | `src/charts/donut.ts` | `src/Charts/Donut.res` | Delegates to Pie (same pattern) |
| Gauge | `src/charts/gauge.ts` | `src/Charts/Gauge.res` | Accessor config, atan2 math preserved |
| Scatter | `src/charts/scatter.ts` | `src/Charts/Scatter.res` | x/y accessors, grid rendering |
| Sparkline | `src/charts/sparkline.ts` | `src/Charts/Sparkline.res` | Linear interpolation preserved |

## Data Input Transformation

### Current (Pre-formatted)

```typescript
const data = [
  { key: "A", value: 10, style: "*" },
  { key: "B", value: 20, style: "#" },
];
bar(data, { height: 10 });
```

### New (d3-style accessors)

```res
let salesData = [
  {"product": "Laptop", "sales": 150, "region": "US"},
  {"product": "Phone", "sales": 300, "region": "EU"},
]

let chart = Bar.make(
  salesData,
  ~config={
    key: d => d["product"]->Json.string,
    value: d => d["sales"]->Json.number,
    style: d => d["region"]->Json.string == "US" ? "*" : "#",
  },
  ~options={height: 10, barWidth: 3},
  (),
)
```

## Eliminated Functions

The following TypeScript functions are **eliminated** by the accessor pattern:

| Function | Replacement | Rationale |
|----------|-------------|-----------|
| `parseCategoricalData` | Accessor callbacks | No data transformation needed |
| `parseScatterData` | x/y accessors | Native scatter config |
| `parseList` | User provides accessors | No auto-key generation |
| `parseFromObject` | User provides accessors | No object→array transform |
| `parseCustomData` | User provides accessors | No field mapping needed |
| `parseRow` | User provides accessors | Callbacks are native |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| ReScript learning curve | Medium — ML-family syntax unfamiliar | ReScript v12 has excellent error messages; rescript-lang.org docs |
| JSON variant ergonomics | Medium — users must pattern match | Provide `Json.string`, `Json.number` accessor helpers |
| Imperative → Functional | Medium — for-loops become recursion/fold | ReScript compiles efficient loops; use `Array.reduce` |
| ANSI string handling | Low — same string concatenation | ReScript string interpolation with template literals |
| Build configuration | Low — rolldown already configured | Existing `rolldown.config.mjs` works with .res.mjs files |
