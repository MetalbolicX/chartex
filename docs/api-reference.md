# API Reference

This page documents the core modules and types of chartex — a terminal ASCII data visualization library written in ReScript and compiled to TypeScript.

## Accessor Functions

Since chartex is built with ReScript, the API uses **accessor functions** instead of plain key-value objects. Accessors are functions that extract values from your data items at render time.

Instead of passing `{ key: "A", value: 10 }`, you pass a **config** with functions:

```ts
// Tell chartex HOW to get the key and value from YOUR data shape
const config = {
  key: (item) => item.category,  // extract label
  value: (item) => item.sales,   // extract number
}
```

This means chartex works with **any data shape** — you never need to pre-transform your data.

### Basic Example

```ts
import { Bar } from "chartex";

const salesData = [
  { country: "Mexico", amount: 10 },
  { country: "USA", amount: 20 },
  { country: "Canada", amount: 15 },
];

const chart = Bar.make(salesData, {
  key: (d) => d.country,
  value: (d) => d.amount,
});

console.log(chart);
```

### Optional Style Accessor

You can also provide a style accessor for per-item styling:

```ts
const chart = Bar.make(data, {
  key: (d) => d.category,
  value: (d) => d.sales,
  style: (d) => d.sales > 15 ? "█" : "▒",
});
```

### Why Accessors?

Accessors give you **type safety** and **flexibility** — your data stays in its natural shape, and the compiler verifies the accessors match your data at compile time.

---

## Categorical Charts

### Bar

Creates a vertical bar chart. Bars display vertically with values at the top and labels at the bottom.

#### Signature

```ts
Bar.make(data, config, options?): string
```

#### Parameters

- `data` (`T[]`): Array of data items of any shape.
- `config` (`barConfig<T>`): Accessor functions for your data.
- `options` (`barOptions`, optional): Configuration for chart appearance.

#### Types

```ts
type barConfig<T> = {
  key: (item: T) => string,   // Extract the label
  value: (item: T) => number, // Extract the numeric value
  style?: (item: T) => string, // Optional per-item style
}

type barOptions = {
  barWidth?: number,  // Width of each bar (default: 3)
  left?: number,      // Left offset (default: 1)
  height?: number,    // Chart height (default: 40% of terminal height, min 6)
  padding?: number,   // Padding between bars (default: 3)
  style?: string,     // Default style character (default: "*")
}
```

#### Returns

A string representation of the bar chart.

#### Examples

```ts
import { Bar } from "chartex";

const data = [
  { name: "Jan", total: 45 },
  { name: "Feb", total: 67 },
  { name: "Mar", total: 82 },
];

// Basic usage
console.log(Bar.make(data, {
  key: (d) => d.name,
  value: (d) => d.total,
}));

// With options
console.log(Bar.make(data, {
  key: (d) => d.name,
  value: (d) => d.total,
  style: (d) => d.total > 60 ? "█" : "▒",
}, { height: 10, padding: 2 }));
```

---

### Bullet

Creates a horizontal bullet chart. Displays horizontal bars with labels and values on the left side — ideal for comparing performance metrics or progress indicators.

#### Signature

```ts
Bullet.make(data, config, options?): string
```

#### Types

```ts
type bulletConfig<T> = {
  key: (item: T) => string,     // Extract the label
  value: (item: T) => number,   // Extract the numeric value
  style?: (item: T) => string,  // Optional per-item style
  barWidth?: (item: T) => number, // Optional per-item bar width
}

type bulletOptions = {
  barWidth?: number, // Width of each bar (default: 3)
  style?: string,    // Default style character (default: "*")
  left?: number,     // Left offset (default: 1)
  width?: number,    // Total width
  padding?: number,  // Padding between bars (default: 3)
}
```

#### Example

```ts
import { Bullet } from "chartex";

const data = [
  { dept: "Sales", score: 85 },
  { dept: "Marketing", score: 92 },
  { dept: "Support", score: 78 },
];

console.log(Bullet.make(data, {
  key: (d) => d.dept,
  value: (d) => d.score,
}, { width: 20 }));
```

---

### Donut

Creates a donut chart with a hollow center, representing data as segments around a circle. Displays percentages and labels in a legend.

#### Signature

```ts
Donut.make(data, config, options?): string
```

#### Types

```ts
type donutConfig<T> = {
  key: (item: T) => string,     // Extract the label
  value: (item: T) => number,   // Extract the numeric value
  style?: (item: T) => string,  // Optional per-item style
}

type donutOptions = {
  radius?: number,      // Radius of the donut (default: 5)
  left?: number,        // Left offset (default: 1)
  innerRadius?: number, // Inner radius for hollow center (default: 2)
}
```

#### Example

```ts
import { Donut } from "chartex";

const data = [
  { segment: "Desktop", pct: 45 },
  { segment: "Mobile", pct: 35 },
  { segment: "Tablet", pct: 20 },
];

console.log(Donut.make(data, {
  key: (d) => d.segment,
  value: (d) => d.pct,
}, { radius: 6 }));
```

---

### Gauge

Creates a semi-circular gauge meter to display a single value. Shows the value as a filled arc with percentage display — ideal for progress, performance metrics, or completion status.

#### Signature

```ts
Gauge.make(data, config, options?): string
```

#### Types

```ts
type gaugeConfig<T> = {
  key: (item: T) => string,     // Extract the label
  value: (item: T) => number,   // Extract the numeric value (0–1)
  style?: (item: T) => string,  // Optional per-item style
}

type gaugeOptions = {
  radius?: number,  // Radius of the gauge (default: 5)
  left?: number,    // Left offset (default: 2)
  style?: string,   // Style for filled portion (default: "# ")
  bgStyle?: string, // Style for unfilled portion (default: "+ ")
}
```

#### Example

```ts
import { Gauge } from "chartex";

const data = [
  { metric: "CPU Usage", value: 0.75 },
];

console.log(Gauge.make(data, {
  key: (d) => d.metric,
  value: (d) => d.value,
}, { radius: 6 }));
```

---

### Pie

Creates a pie chart representing data as segments of a circle. Displays each value as a proportional slice with a legend showing labels, values, and percentages.

#### Signature

```ts
Pie.make(data, config, options?): string
```

#### Types

```ts
type pieConfig<T> = {
  key: (item: T) => string,     // Extract the label
  value: (item: T) => number,   // Extract the numeric value
  style?: (item: T) => string,  // Optional per-item style
}

type pieOptions = {
  radius?: number,      // Radius of the pie (default: 4)
  left?: number,        // Left offset (default: 0)
  innerRadius?: number, // Inner radius for donut effect (default: 0)
}
```

#### Example

```ts
import { Pie } from "chartex";

const data = [
  { category: "Housing", amount: 1200 },
  { category: "Food", amount: 800 },
  { category: "Transport", amount: 400 },
];

console.log(Pie.make(data, {
  key: (d) => d.category,
  value: (d) => d.amount,
}, { radius: 5 }));
```

---

## Numerical Charts

### Scatter

Creates a scatter plot displaying data points as coordinates on a two-dimensional grid. Includes labeled axes with scales.

#### Signature

```ts
Scatter.make(data, config, options?): string
```

#### Types

```ts
type scatterConfig<T> = {
  key: (item: T) => string,     // Extract the series label
  x: (item: T) => number,       // Extract the X coordinate
  y: (item: T) => number,       // Extract the Y coordinate
  style?: (item: T) => string,  // Optional per-item style
}

type scatterOptions = {
  width?: number,      // Width of the plot area (default: 60% of terminal width, min 10)
  height?: number,     // Height of the plot area (default: 30% of terminal height, min 8)
  style?: string,      // Default style for points (default: "*")
  showLegend?: boolean, // Whether to show the legend
}
```

#### Example

```ts
import { Scatter } from "chartex";

const data = [
  { group: "A", x: 1, y: 2 },
  { group: "B", x: 3, y: 4 },
  { group: "C", x: 2, y: 5 },
];

console.log(Scatter.make(data, {
  series: (d) => d.group,
  x: (d) => d.x,
  y: (d) => d.y,
}, { width: 20, height: 10 }));
```

---

### Sparkline

Creates a compact, inline sparkline chart representing a series of numeric values as a sequence of bar characters. Ideal for visualizing trends in small spaces like tables or dashboards.

#### Signature

```ts
Sparkline.make(data, config, options?): string
```

#### Types

```ts
type sparklineConfig<T> = {
  key: (item: T) => string,     // Extract the label
  value: (item: T) => number,   // Extract the numeric value
  style?: (item: T) => string,  // Optional per-item style
}

type sparklineOptions = {
  width?: number,      // Width of the sparkline (default: data.length)
  height?: number,     // Height of the sparkline (default: 8)
  tolerance?: number,  // Tolerance for interpolation (default: 1)
  style?: string,      // Default style character (default: "*")
  yAxisChar?: string,  // Character for the y-axis (default: "|")
}
```

#### Example

```ts
import { Sparkline } from "chartex";

const data = [
  { label: "Mon", value: 10 },
  { label: "Tue", value: 25 },
  { label: "Wed", value: 15 },
  { label: "Thu", value: 30 },
  { label: "Fri", value: 20 },
];

console.log(Sparkline.make(data, {
  key: (d) => d.label,
  value: (d) => d.value,
}, { width: 12, height: 6 }));
```

---

## Utility Modules

Utility modules provide terminal detection, ANSI formatting, JSON handling, and validation. They are available alongside chart modules.

---

### Types

```ts
import { Types } from "chartex";
```

All type definitions for chart configs and options.

```ts
// Chart configs (accessor-based)
type barConfig<T>        = { key: (T) => string, value: (T) => number, style?: (T) => string }
type bulletConfig<T>     = { key: (T) => string, value: (T) => number, style?: (T) => string, barWidth?: (T) => number }
type donutConfig<T>      = { key: (T) => string, value: (T) => number, style?: (T) => string }
type gaugeConfig<T>      = { key: (T) => string, value: (T) => number, style?: (T) => string }
type pieConfig<T>        = { key: (T) => string, value: (T) => number, style?: (T) => string }
type scatterConfig<T>    = { series: (T) => string, x: (T) => number, y: (T) => number, style?: (T) => string }
type sparklineConfig<T>  = { key: (T) => string, value: (T) => number, style?: (T) => string }

// Chart options
type barOptions          = { barWidth?: number, left?: number, height?: number, padding?: number, style?: string }
type bulletOptions       = { barWidth?: number, style?: string, left?: number, width?: number, padding?: number }
type donutOptions        = { radius?: number, left?: number, innerRadius?: number }
type gaugeOptions        = { radius?: number, left?: number, style?: string, bgStyle?: string }
type pieOptions          = { radius?: number, left?: number, innerRadius?: number }
type scatterOptions      = { width?: number, height?: number, style?: string, showLegend?: boolean }
type sparklineOptions    = { width?: number, height?: number, tolerance?: number, style?: string, yAxisChar?: string }

// Color palette
type backgroundColor = "Black" | "Red" | "Green" | "Yellow" | "Blue" | "Magenta" | "Cyan" | "White"
```

---

### Ansi

```ts
import { Ansi } from "chartex";
```

ANSI escape code helpers for terminal coloring and cursor movement.

#### Coloring

```ts
Ansi.bg(color: backgroundColor, length: number): string
```

Returns `length` space characters filled with the given ANSI background color.

```ts
Ansi.fg(color: backgroundColor, style: string): string
```

Wraps `style` in the given ANSI foreground color and resets at the end.

**Accepted colors** — use one of:

| Value | Background | Foreground |
|-------|-----------|------------|
| `"Black"` | 40 | 30 |
| `"Red"` | 41 | 31 |
| `"Green"` | 42 | 32 |
| `"Yellow"` | 43 | 33 |
| `"Blue"` | 44 | 34 |
| `"Magenta"` | 45 | 35 |
| `"Cyan"` | 46 | 36 |
| `"White"` | 47 | 37 |

Both functions return raw ANSI escape sequences. The library handles reset (`\x1b[0m`) automatically, so you can safely concatenate outputs with non-colored text.

#### Cursor Movement

| Function | Signature | Output | Description |
|----------|-----------|--------|-------------|
| `curForward` | `(step: number) => string` | `\x1b[{n}C` | Move cursor right by `step` columns |
| `curBack` | `(step: number) => string` | `\x1b[{n}D` | Move cursor left by `step` columns |
| `curUp` | `(step: number) => string` | `\x1b[{n}A` | Move cursor up by `step` rows |
| `curDown` | `(step: number) => string` | `\x1b[{n}B` | Move cursor down by `step` rows |

#### Example — Colored Chart

```ts
import { Bar, Ansi } from "chartex";

const data = [
  { label: "High",   value: 90 },
  { label: "Medium", value: 60 },
  { label: "Low",    value: 30 },
];

const chart = Bar.make(data, {
  key:   (d) => d.label,
  value: (d) => d.value,
  style: (d) =>
    d.value >= 80 ? Ansi.fg("Green", "█") :
    d.value >= 50 ? Ansi.fg("Yellow", "█") :
                   Ansi.fg("Red", "█"),
});

console.log(chart);
```

---

### Terminal

```ts
import { Terminal } from "chartex";
```

Terminal dimension detection.

```ts
Terminal.width(): number | undefined
```

Returns the terminal width in columns (characters), or `undefined` if stdout is not a TTY.

```ts
Terminal.height(): number | undefined
```

Returns the terminal height in rows (lines), or `undefined` if stdout is not a TTY.

#### Example

```ts
import { Terminal } from "chartex";

const cols = Terminal.width();   // e.g. 80
const rows = Terminal.height();  // e.g. 24
```

Chart functions use these automatically to set default dimensions — you usually do not need to call them directly.

---

### Json

```ts
import { Json } from "chartex";
```

ReScript JSON variant type and accessors. Useful for type-safe JSON traversal in ReScript contexts.

#### Type

```ts
type json =
  | JObject(Dict<json>)
  | JArray(json[])
  | JString(string)
  | JNumber(number)
  | JBool(boolean)
  | JNull
```

#### Accessors

Each accessor extracts the value from a specific variant. Throws if the variant does not match.

| Function | Signature | Returns | Throws If |
|----------|-----------|---------|-----------|
| `Json.string` | `(j: json) => string` | The inner string | `j` is not `JString` |
| `Json.number` | `(j: json) => number` | The inner number | `j` is not `JNumber` |
| `Json.bool` | `(j: json) => boolean` | The inner boolean | `j` is not `JBool` |
| `Json.array` | `(j: json) => json[]` | The inner array | `j` is not `JArray` |
| `Json.object_` | `(j: json) => Dict<json>` | The inner dictionary | `j` is not `JObject` |

> Note: `object_` has a trailing underscore because `object` is a reserved word in JavaScript.

---

### Validate

```ts
import { Validate } from "chartex";
```

JSON data structure validation.

```ts
Validate.data(json: Json.json): boolean
```

Validates that a `Json.json` value is a well-structured chart dataset — specifically, that it is a `JArray` of `JObject` entries. Returns `true` if valid, `false` otherwise.

#### Example

```ts
import { Validate, Json } from "chartex";

const raw = JSON.parse(`[{"name":"A","value":10}]`);
// In ReScript flows where data enters as Json.json:
if (Validate.data(raw)) {
  // safe to access raw via Json.array(raw), etc.
}
```

---

### CLI Modules

```ts
import { CliTypes, CliArgs, CliStreamIO, CliParser, CliAdapter, CliMain } from "chartex";
```

Internal modules used by the CLI (`npx chartex`). Exported for programmatic use but primarily intended for CLI operation.

| Module | Purpose |
|--------|---------|
| `CliTypes` | Type definitions for CLI options and parsed args |
| `CliArgs` | Argument parsing using `parseArgs` from `node:util` |
| `CliStreamIO` | Stdin/stdout stream I/O with event-based reading |
| `CliParser` | Input format detection and parsing (JSON, NDJSON, CSV) |
| `CliAdapter` | Adapts parsed rows into chart module data structures |
| `CliMain` | Entry point routing adapted data to the appropriate renderer |
