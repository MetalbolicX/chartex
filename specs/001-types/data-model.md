# Data Model: F001-types Shared Type System

## Entities

### backgroundColor

**Type**: ReScript variant
**File**: `src/Config/Types.res`

```res
type backgroundColor = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
```

Represents the 8 valid terminal ANSI background colors. Invalid color values are rejected at compile time.

**Validation**: N/A — variant type enforces valid values
**Cross-Feature**: Used by F002-core (Ansi module), F003-charts (all chart styles)

---

### accessor<'data, 'result>

**Type**: ReScript type alias
**File**: `src/Config/Types.res`

```res
type accessor<'data, 'result> = 'data => 'result
```

Generic accessor function type. Represents a function that extracts a typed value from consumer data. Used by all chart config types.

**Cross-Feature**: Used by all chart config types in F003-charts

---

### barConfig<'data>

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type barConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}
```

Configuration for bar chart data accessors. `style` is optional — defaults to `"*"` in `Bar.make`.

**Cross-Feature**: Used by F003-charts (Bar), F004-barrel (re-export)

---

### barOptions

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type barOptions = {
  barWidth?: int,
  left?: int,
  height?: int,
  padding?: int,
  style?: string,
}
```

Visual options for bar chart rendering. All fields optional.

---

### bulletConfig<'data>

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type bulletConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
  barWidth?: accessor<'data, int>,
}
```

Configuration for bullet chart. `barWidth` is optional per-item accessor.

**Cross-Feature**: Used by F003-charts (Bullet), F004-barrel (re-export)

---

### bulletOptions

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type bulletOptions = {
  barWidth?: int,
  style?: string,
  left?: int,
  width?: int,
  padding?: int,
}
```

Visual options for bullet chart.

---

### scatterConfig<'data>

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type scatterConfig<'data> = {
  key: accessor<'data, string>,
  x: accessor<'data, float>,
  y: accessor<'data, float>,
  style?: accessor<'data, string>,
}
```

Configuration for scatter plot. Uses separate `x` and `y` accessors (not a single `value` accessor).

**Cross-Feature**: Used by F003-charts (Scatter), F004-barrel (re-export)

---

### scatterOptions

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type scatterOptions = {
  width?: int,
  height?: int,
  style?: string,
}
```

Visual options for scatter chart.

---

### gaugeConfig<'data>

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type gaugeConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}
```

Configuration for gauge chart. `style` optional (defaults to `"*"`).

**Cross-Feature**: Used by F003-charts (Gauge), F004-barrel (re-export)

---

### gaugeOptions

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type gaugeOptions = {
  radius?: int,
  left?: int,
  style?: string,
  bgStyle?: string,
}
```

Visual options for gauge chart.

---

### pieConfig<'data>

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type pieConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style: accessor<'data, string>,  // REQUIRED
}
```

Configuration for pie chart. **`style` is required** — no default fallback.

**Cross-Feature**: Used by F003-charts (Pie), F004-barrel (re-export)

---

### pieOptions

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type pieOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}
```

Visual options for pie chart.

---

### donutConfig<'data>

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type donutConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style: accessor<'data, string>,  // REQUIRED
}
```

Configuration for donut chart. **`style` is required** — no default fallback.

**Cross-Feature**: Used by F003-charts (Donut), F004-barrel (re-export)

---

### donutOptions

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type donutOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}
```

Visual options for donut chart.

---

### sparklineConfig<'data>

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type sparklineConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}
```

Configuration for sparkline chart. `style` optional (defaults to `"*"`).

**Cross-Feature**: Used by F003-charts (Sparkline), F004-barrel (re-export)

---

### sparklineOptions

**Type**: ReScript record
**File**: `src/Config/Types.res`

```res
type sparklineOptions = {
  width?: int,
  height?: int,
  tolerance?: int,
  style?: string,
  yAxisChar?: string,
}
```

Visual options for sparkline chart.

---

## Eliminated Types

The following TypeScript types are **not carried forward** to ReScript:

| Original Type | Reason |
|--------------|--------|
| `ChartDatum` | Eliminated — replaced by per-chart config records |
| `parseData`, `parseBarData`, etc. | Eliminated — accessor pattern replaces parse helpers |
| `BackgroundColorMap` | Eliminated — F002-core Ansi module handles color→code mapping |

## Registry Alignment

All 16 entities above are documented in `specs/_global/entity-registry.md`. Entity names and types match exactly what was specified in the entity-registry pre-condition.

| Entity | Registry Status |
|--------|---------------|
| backgroundColor | ✅ matches entity-registry |
| accessor<'data, 'result> | ✅ matches entity-registry |
| barConfig | ✅ matches entity-registry |
| barOptions | ✅ matches entity-registry |
| bulletConfig | ✅ matches entity-registry |
| bulletOptions | ✅ matches entity-registry |
| scatterConfig | ✅ matches entity-registry |
| scatterOptions | ✅ matches entity-registry |
| gaugeConfig | ✅ matches entity-registry |
| gaugeOptions | ✅ matches entity-registry |
| pieConfig | ✅ matches entity-registry |
| pieOptions | ✅ matches entity-registry |
| donutConfig | ✅ matches entity-registry |
| donutOptions | ✅ matches entity-registry |
| sparklineConfig | ✅ matches entity-registry |
| sparklineOptions | ✅ matches entity-registry |