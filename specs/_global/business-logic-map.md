# Business Logic Map — chartex

## Business Rules

### BR-001: Terminal Dimension Detection (F002-core)

**Rule**: Terminal width and height are detected from `process.stdout.columns`/`rows`. If unavailable (non-TTY environment), default to 80 columns × 24 rows.

**Validation**: Runtime check — `typeof stdout !== "undefined" && stdout.columns`
**Source**: `src/utils/utils.ts` → `getShellWidth()`, `getShellHeight()`
**ReScript**: `Terminal.width()`, `Terminal.height()`

---

### BR-002: ANSI Color Code Mapping (F002-core)

**Rule**: Background colors map to ANSI codes 40-47. Foreground colors map to codes 30-37 (bg code - 10). Invalid colors throw TypeError.

**Validation**: Color name must be one of: black, red, green, yellow, blue, magenta, cyan, white
**Source**: `src/utils/utils.ts` → `bgColors`, `bg()`, `fg()`
**ReScript**: `Ansi.bg()`, `Ansi.fg()`

---

### BR-003: Data Validation (F002-core)

**Rule**: Chart data must be a non-empty array. Each item must have a string `key` and a valid `value` (number or [number, number] tuple). NaN values are rejected.

**Validation**: Array.isArray + length > 0, key truthy, value type check, !isNaN
**Source**: `src/utils/utils.ts` → `verifyData()`
**ReScript**: `Validate.data()`

---

### BR-004: Bar Chart Height Ratio (F003-charts)

**Rule**: Bar height is calculated as `height - (height * value) / max`. Value labels appear at the ratio position. Key labels appear at the bottom row.

**Source**: `src/charts/bar.ts` → `bar()`
**Algorithm**: For each row i and column j, determine if position is above/at/below the bar ratio.

---

### BR-005: Pie/Donut Segment Assignment (F003-charts)

**Rule**: Each point in the circular grid is assigned to a segment based on its `atan2(i, j) * 1/π * 0.5 + 0.5` angle. The segment is determined by cumulative ratio comparison using recursive `getPadChar`.

**Source**: `src/charts/pie.ts` → `pie()`, `getPadChar()`
**Note**: Donut adds inner radius exclusion — points within innerRadius are empty.

---

### BR-006: Gauge Arc Calculation (F003-charts)

**Rule**: Gauge renders a semi-circle (top half only: i from -radius to 0). Fill percentage is determined by `atan2(i, j) * 1/π + 1` compared to the data value. Center displays the percentage integer.

**Source**: `src/charts/gauge.ts` → `gauge()`

---

### BR-007: Scatter Plot Scaling (F003-charts)

**Rule**: X values are linearly scaled to column positions (0 to width-1). Y values are linearly scaled to row positions (height-1 to 0, inverted). Grid positions are filled with style characters.

**Source**: `src/charts/scatter.ts` → `scatter()`
**Axis**: Y-axis labels show dynamic decimal precision (0-2 decimals based on range). X-axis shows min/mid/max labels.

---

### BR-008: Sparkline Interpolation (F003-charts)

**Rule**: Points are connected by linear interpolation when the gap exceeds the tolerance threshold. Y values are normalized to fit within the height. Each point is mapped to grid coordinates.

**Source**: `src/charts/sparkline.ts` → `sparkline()`
**Axis**: Y-axis with dynamic decimal precision, same as scatter.

---

### BR-009: Default Style Fallback (F003-charts)

**Rule**: When no style accessor is provided in the config, all charts default to `"*"` as the style character. Pie and Donut require explicit style accessors (no default).

**Source**: All chart modules
**ReScript**: Optional `style` field with default in `Bar.make()`, `Bullet.make()`, etc.

---

### BR-010: JSON Accessor Helpers (F002-core)

**Rule**: The Json module provides convenience functions for extracting typed values from the json variant: `Json.string(json)`, `Json.number(json)`, `Json.bool(json)`, `Json.array(json)`, `Json.object_(json)`. These throw on type mismatch.

**Source**: New in ReScript migration — replaces TypeScript's direct property access
