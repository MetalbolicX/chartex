# Tutorials for chartex

## Introduction

Welcome to the world of ASCII charts with **chartex**! Whether you're building dashboards, analyzing data, or just want to add some visual flair to your terminal, chartex makes it easier. In this tutorial, we'll walk through the basics of using chartex to create beautiful charts right in your terminal.

`chartex` is written in **ReScript** and compiled to **JavaScript**. Its API uses **accessor functions** — you tell chartex how to extract data from your objects, rather than pre-transforming your data.

## Installing chartex

First, make sure you have chartex installed. Follow the [Getting Started](getting-started) page to get set up. Once installed, you can start creating charts in your JavaScript projects.

## Creating Your First Bar Chart

Let's create a simple bar chart to visualize some sales data.

```ts
import { Bar } from "chartex";

const data = [
  { region: "North", total: 10 },
  { region: "South", total: 20 },
  { region: "East", total: 15 },
];

// Accessor functions tell chartex how to read your data
const chart = Bar.make(data, {
  key: (d) => d.region,
  value: (d) => d.total,
}, { height: 8 });

console.log(chart);
```

No pre-transforming needed — chartex works with your data as-is.

Step-by-step explanation

- Prepare your data as an array of plain objects.
- Provide a config object with accessors (`key`, `value`, optional `style`): these are simple functions that extract the values from your objects.
- Optionally provide `options` to override chart defaults such as `height`, `barWidth`, `padding`, and `style`.

The return value from `Bar.make` is a string — print it to stdout or capture it for further processing.

## Exploring Other Chart Types

### Scatter Plot

For coordinate data, use a scatter plot:

```ts
import { Scatter } from "chartex";

const points = [
  { label: "A", x: 1, y: 2 },
  { label: "B", x: 3, y: 4 },
  { label: "C", x: 2, y: 5 },
];

// Note: scatter uses `key` to identify series (not `series`) — this lets
// the renderer group points into series and assign per-series styles.
console.log(Scatter.make(points, {
  key: (d) => d.label,
  x: (d) => d.x,
  y: (d) => d.y,
  // optional per-point style accessor
  style: (d) => (d.x > 2 ? "*" : "."),
}, { width: 16, height: 8 }));
```

### Sparkline

For inline trend visualization, use a sparkline:

```ts
import { Sparkline } from "chartex";

const trend = [
  { day: "Mon", value: 10 },
  { day: "Tue", value: 25 },
  { day: "Wed", value: 15 },
];

console.log(Sparkline.make(trend, {
  key: (d) => d.day,
  value: (d) => d.value,
}, { width: 10, height: 6 }));
```

## Advanced: Colors and changing defaults

chartex exposes an Ansi helper for colored text and background blocks. Use `Ansi.fg` / `Ansi.bg` to decorate style characters. Example: per-item coloring for a bar chart.

```ts
import { Bar, Ansi, Terminal } from "chartex";

const data = [
  { name: "Alpha", value: 90 },
  { name: "Beta", value: 60 },
  { name: "Gamma", value: 30 },
];

// Use Terminal.width() to pick a sensible radius or width when available
const cols = Terminal.width() ?? 80;

const chart = Bar.make(data, {
  key: (d) => d.name,
  value: (d) => d.value,
  style: (d) =>
    d.value >= 80
      ? Ansi.fg("Green", "█")
      : d.value >= 50
      ? Ansi.fg("Yellow", "█")
      : Ansi.fg("Red", "█"),
}, {
  // override defaults: choose larger bars and smaller padding
  barWidth: 4,
  padding: 1,
  height: 12,
  // left offset to create margin
  left: 2,
});

console.log(chart);
```

Notes on defaults you can override

- `barWidth`: width of each bar (default in code is 3 for Bar.make; set it to any positive integer).
- `padding`: spacing between bars (default 3 for some charts, 1 for Bullet — consult the API reference).
- `height` / `width`: chart dimensions — chartex falls back to terminal size when these are not provided.
- `style`: default style character used when `config.style` is not provided. You can provide either a static string or a style accessor that returns ANSI-wrapped characters using `Ansi.fg`/`Ansi.bg`.

Per-item and per-series styles

- Provide `config.style` as a function to compute the style for each datum — this supports conditional characters or ANSI-colored characters.
- For scatter plots, the `key` accessor groups points into series; `Scatter` assigns a round-robin default style per series. You can override this by providing a `style` accessor that returns a per-point or per-series char.

If you need more examples or the full list of options, consult the [API Reference](api-reference) and the [CLI guide](cli).
