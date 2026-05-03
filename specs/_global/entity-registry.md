# Entity Registry — chartex

## Entities

### BackgroundColor (F001-types)

**Type**: ReScript variant
**Description**: Terminal ANSI background color names

```res
type backgroundColor = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
```

**Fields**:
| Field | Type | Description |
|-------|------|-------------|
| (variant) | `backgroundColor` | 8 terminal color options |

**Validation**: N/A — variant type enforces valid values at compile time
**Cross-Feature**: Used by F002-core (Ansi module), F003-charts (all chart styles)

---

### json (F002-core)

**Type**: ReScript recursive variant
**Description**: Custom JSON data type for untyped input

```res
type rec json =
  | JObject(dict<json>)
  | JArray(array<json>)
  | JString(string)
  | JNumber(float)
  | JBool(bool)
  | JNull
```

**Fields**:
| Variant | Payload | Description |
|---------|---------|-------------|
| JObject | `dict<json>` | JSON object with string keys |
| JArray | `array<json>` | JSON array |
| JString | `string` | String value |
| JNumber | `float` | Numeric value |
| JBool | `bool` | Boolean value |
| JNull | (none) | Null value |

**Validation**: Variant type — all valid JSON shapes covered
**Cross-Feature**: Used by F003-charts (all chart input data), F004-barrel (re-export)

---

### accessor<'data, 'result> (F001-types)

**Type**: ReScript function type
**Description**: Generic accessor function for d3-style data extraction

```res
type accessor<'data, 'result> = 'data => 'result
```

**Cross-Feature**: Used by all chart config types in F003-charts

---

### barConfig<'data> (F001-types)

**Type**: ReScript record
**Description**: Configuration for bar chart data accessors

```res
type barConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}
```

**Cross-Feature**: Used by F003-charts (Bar), F004-barrel (re-export)

---

### barOptions (F001-types)

**Type**: ReScript record
**Description**: Visual options for bar chart rendering

```res
type barOptions = {
  barWidth?: int,
  left?: int,
  height?: int,
  padding?: int,
  style?: string,
}
```

---

### bulletConfig<'data> (F001-types)

**Type**: ReScript record
**Description**: Configuration for bullet chart data accessors

```res
type bulletConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
  barWidth?: accessor<'data, int>,
}
```

---

### bulletOptions (F001-types)

**Type**: ReScript record

```res
type bulletOptions = {
  barWidth?: int,
  style?: string,
  left?: int,
  width?: int,
  padding?: int,
}
```

---

### scatterConfig<'data> (F001-types)

**Type**: ReScript record
**Description**: Configuration for scatter plot data accessors (x/y)

```res
type scatterConfig<'data> = {
  key: accessor<'data, string>,
  x: accessor<'data, float>,
  y: accessor<'data, float>,
  style?: accessor<'data, string>,
}
```

---

### scatterOptions (F001-types)

**Type**: ReScript record

```res
type scatterOptions = {
  width?: int,
  height?: int,
  style?: string,
}
```

---

### gaugeConfig<'data> (F001-types)

**Type**: ReScript record

```res
type gaugeConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}
```

---

### gaugeOptions (F001-types)

**Type**: ReScript record

```res
type gaugeOptions = {
  radius?: int,
  left?: int,
  style?: string,
  bgStyle?: string,
}
```

---

### pieConfig<'data> (F001-types)

**Type**: ReScript record

```res
type pieConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style: accessor<'data, string>,  // required for pie
}
```

---

### pieOptions (F001-types)

**Type**: ReScript record

```res
type pieOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}
```

---

### donutConfig<'data> (F001-types)

**Type**: ReScript record

```res
type donutConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style: accessor<'data, string>,  // required for donut
}
```

---

### donutOptions (F001-types)

**Type**: ReScript record

```res
type donutOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}
```

---

### sparklineConfig<'data> (F001-types)

**Type**: ReScript record

```res
type sparklineConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}
```

---

### sparklineOptions (F001-types)

**Type**: ReScript record

```res
type sparklineOptions = {
  width?: int,
  height?: int,
  tolerance?: int,
  style?: string,
  yAxisChar?: string,
}
```
