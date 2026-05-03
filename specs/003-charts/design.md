# Design: F003-charts — Chart Renderers

## Technical Approach

Seven pure modules in `src/Charts/`, each exporting `make(data, ~config, ~options?): string`. Port the TypeScript algorithms 1:1 to ReScript — nested loops become accumulative pattern matching, mutable grids use `array<array<string>>`. Validate via `Validate.data()`, merge options via spread, render via string concatenation or grid join. Donut delegates to Pie internally.

## Architecture Decisions

| Decision | Option | Tradeoff | Choice |
|----------|--------|----------|--------|
| Module count | 7 separate files vs 1 god module | 7 = clear boundaries, 1 = fewer files but violates SRP | **7 modules** — one per chart type |
| Options merging | Spread `{...defaults, ...opts}` vs field-by-field | Spread = concise but only works with records; field-by-field = verbose but explicit | **Spread** — all options are flat records |
| Scale helper location | Inline in Scatter/Sparkline vs shared `Scale.res` | Inline = duplication; shared = extra module for 4-line function | **Inline** — only 2 consumers, trivial |
| Grid mutability | Mutable `array<array<string>>` vs immutable list prepend | Mutable = natural grid assignment; immutable = complex | **Mutable grid** — mirror TS pattern |
| getPadChar visibility | Private in `Pie.res` vs exported | Private = encapsulated; exported = testable | **Private** — only used by pie/donut |
| Donut delegation | `Donut.res` calls `Pie.make` vs merged module | Separate file = clear API; merged = less ceremony | **Separate module** — matches public API |
| Validation trigger | `assert(Validate.data(raw))` throwing vs if/else | assert = concise; if/else = friendlier message | **assert** — same as TS throw pattern |

## Function Signatures

```rescript
// Bar.res
let make: (array<'data>, ~config: barConfig<'data>, ~options: barOptions=?, unit) => string

// Bullet.res
let make: (array<'data>, ~config: bulletConfig<'data>, ~options: bulletOptions=?, unit) => string

// Pie.res
let make: (array<'data>, ~config: pieConfig<'data>, ~options: pieOptions=?, unit) => string

// Donut.res
let make: (array<'data>, ~config: donutConfig<'data>, ~options: donutOptions=?, unit) => string

// Gauge.res
let make: (array<'data>, ~config: gaugeConfig<'data>, ~options: gaugeOptions=?, unit) => string

// Scatter.res
let make: (array<'data>, ~config: scatterConfig<'data>, ~options: scatterOptions=?, unit) => string

// Sparkline.res
let make: (array<'data>, ~config: sparklineConfig<'data>, ~options: sparklineOptions=?, unit) => string
```

## Core Patterns

### Options Merging (all charts)

```rescript
let defaults = {barWidth: 3, left: 1, height: max(6, Terminal.height() * 4 / 10), padding: 3, style: "*"}
let opts = switch options {
  | Some(o) => {...defaults, ...o}
  | None => defaults
}
```

### Scale Helper (Scatter & Sparkline)

```rescript
let linearScale = (value, min, max, outMin, outMax) =>
  if min == max { outMin }
  else { outMin + (value -. min) /. (max -. min) *. (outMax -. outMin) }
```

### Grid Construction (Scatter & Sparkline)

1. `Array.make(height, Array.make(width, " "))` — immutable inner arrays need per-row re-init
2. Iterate points: assign style at `grid[y][x]`
3. Join rows: `grid->Array.map(row => row->Js.Array.joinWith(""))`
4. Join with newlines: `lines->Js.Array.joinWith("\n")`

> **ReScript note**: `Array.make(n, val)` shares the same array reference. Use `Array.init(height, _ => Array.make(width, " "))` to create distinct rows.

### Axis Rendering (Scatter & Sparkline)

**Y-axis**: labels at each row — `maxY - i * (maxY - minY) / (height - 1)`, formatted to 0–2 decimals based on range. Prepend to each row: `label.padStart(yAxisWidth) + " | " + row`.

**X-axis (Scatter)**: min at col 0, max at last col, mid (1 decimal) at center. Render as `" ".repeat(yAxisWidth + 3) + "_".repeat(width)` + label row below.

## Algorithm Pseudocode

### Bar (Bar.res)
```
validate(data) → assert
extract values/styles via config accessors
max = Array.reduce(values, max)
for i = 0 to height+1:
  for j = 0 to length-1:
    ratio = height - (height * value) / max
    if ratio > i+2 → PAD
    elif round(ratio) == i → midPad(value string)
    elif round(ratio) < i → style
    else → PAD
    if i == height+1 → key label (midPadded if short, truncated+padding if long)
  append newline + left padding
```

### Bullet (Bullet.res)
```
validate(data) → assert
max = Array.reduce(values, max)
maxKeyLen = Array.reduce(keys, max length of "key [value]")
for each (item, index) in data:
  ratioLen = round(width * value / max)
  line = style.repeat(ratioLen) + newline + PAD.repeat(left)
  label = padStart("key [value]", maxKeyLen)
  for j in 0..barWidth-1:
    if j == 0 → label + line
    else → PAD.repeat(maxKeyLen+1) + line
  if not last → newline.repeat(padding) + PAD.repeat(left)
```

### Pie/Donut (Pie.res — Donut.res delegates)
```
validate(data) → assert
values = extract; total = sum(values); ratios = values / total; styles = extract
grid: i from -radius to radius-1, j from -radius to radius-1
  dist² = i² + j²
  if dist² < radius²:
    if isDonut and (|i| <= innerR and |j| <= innerR) → "  " (hollow)
    else:
      angle = atan2(float_of_int(i), float_of_int(j)) / π * 0.5 + 0.5
      if angle < 0 → angle = angle + 1.0
      result += getPadChar(styles, ratios, angle, last_style)
  else: "  "
append legend: style + key + value + (ratio%)
```

### getPadChar (private helper in Pie.res)
```
let rec getPadChar = (styles: array<string>, ratios: array<float>, param: float, gap: string): string =>
  switch (ratios, styles) {
  | ([], _) | (_, []) => gap
  | _ =>
    let firstVal = ratios[0]
    if param <= firstVal { styles[0] }
    else { getPadChar(Js.Array.sliceFrom(styles, 1), Js.Array.sliceFrom(ratios, 1), param -. firstVal, gap) }
  }
```

> **ReScript note**: `Array` stdlib lacks `slice` for arrays; use `Js.Array.slice` or `Array.sub`.

### Gauge (Gauge.res)
```
validate(data) → assert
let first = data[0]; value = config.value(first) / 100.0  // normalize 0..100 → 0..1
grid: i from -radius to -1 (top half only), j from -radius to radius-1
  dist² = i² + j²
  if dist² < radius²:
    if |i| > 2 or |j| > 2:  // outer ring
      angle = atan2(i, j) / π + 1.0
      if angle <= value → style else → bgStyle
    else:
      if j == 0 and i == -1 → center = Int.toString(round(value * 100.0))
      else → "  "
  else: "  "
bottom row: "0" + spaces + key + spaces + "100"
```

### Scatter (Scatter.res)
```
validate(data) → assert
separate xs/ys via config accessors
minX/maxX/minY/maxY = Array.reduce
xScale = linearScale(value, minX, maxX, 0, width-1)
yScale = (maxY-minY == 0) ? 1 : (height-1) / (maxY-minY)
points = data mapped → {x: xScale, y: height-1 - round((y-minY)*yScale), style}
grid = Array.init(height, _ => Array.make(width, " "))
points.forEach(p => grid[p.y][p.x] = p.style)
build Y-axis labels + X-axis labels → final string
```

### Sparkline (Sparkline.res)
```
validate(data) → assert
values/styles extracted
normalize x: position = round(i / (len-1) * (width-1))
normalize y: y = height-1 - round((v-min) * scale)
grid = Array.init(height, _ => Array.make(width, " "))
for each consecutive pair (a, b):
  grid[a.y][a.x] = a.style
  gap = |b.x - a.x| + |b.y - a.y|
  if gap > tolerance:
    interpolate: steps = max(|dx|, |dy|)
    for t = 1 to steps-1:
      x = round(a.x + dx*t/steps), y = round(a.y + dy*t/steps)
      grid[y][x] = a.style
grid[last.y][last.x] = last.style
build Y-axis labels → final string
```

## Error Handling

```
Validate.data() returns bool — call per chart:
  assert(Validate.data(raw), "Invalid or empty chart data")
```

If `Validate.data()` returns `false`, `assert` throws `Assert_failure`, halting rendering. Matches the TypeScript `verifyData()` behavior.

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `src/Charts/Bar.res` | Create | Vertical bar chart renderer with ratio-based height |
| `src/Charts/Bullet.res` | Create | Horizontal bullet chart with width-proportional bars |
| `src/Charts/Pie.res` | Create | Pie chart + private `getPadChar` recursive helper |
| `src/Charts/Donut.res` | Create | Thin wrapper: calls Pie.make with inner radius |
| `src/Charts/Gauge.res` | Create | Semi-circular gauge with atan2 percentage fill |
| `src/Charts/Scatter.res` | Create | 2D scatter plot with linear scale axes |
| `src/Charts/Sparkline.res` | Create | Sparkline with linear interpolation |

All new files. No existing files are modified.

## Testing Strategy

| Layer | Test | Approach |
|-------|------|----------|
| Unit | Each `make()` with fixture data | Set up typed arrays, call `make`, assert output contains expected substrings (style chars, labels, axes) via `Assertions.isTextEqualTo` |
| Unit | Options merging | Pass explicit options, verify overrides in output |
| Edge | Empty data rejected | Call `make` with `[]`, expect `Assert_failure` |
| Edge | Single-point scatter/sparkline | Verify centered output, no NaN |
| Edge | Zero-value bar | Verify no fill, key label present at bottom |
| Edge | ANSI style preservation | Pass style `"\x1b[32m*\x1b[0m"`, verify raw codes in output |
