# Tutorials for chartex

## Introduction

Welcome to the world of ASCII charts with **chartex**! Whether you're building dashboards, analyzing data, or just want to add some visual flair to your terminal, chartex makes it easy and fun. In this tutorial, we'll walk through the basics of using chartex to create beautiful charts right in your terminal.

chartex is written in **ReScript** and compiled to **TypeScript**. Its API uses **accessor functions** — you tell chartex how to extract data from your objects, rather than pre-transforming your data.

## Installing chartex

First, make sure you have chartex installed. Follow the [Getting Started](getting-started) page to get set up. Once installed, you can start creating charts in your TypeScript projects.

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

## Exploring Other Chart Types

### Bullet Chart

Bullet charts are great for comparing metrics side by side:

```ts
import { Bullet } from "chartex";

const metrics = [
  { dept: "Sales", pct: 85 },
  { dept: "Marketing", pct: 92 },
  { dept: "Support", pct: 78 },
];

console.log(Bullet.make(metrics, {
  key: (d) => d.dept,
  value: (d) => d.pct,
}, { width: 20 }));
```

### Donut Chart

For proportional data, use a donut chart:

```ts
import { Donut } from "chartex";

const expenses = [
  { item: "Rent", amount: 45 },
  { item: "Food", amount: 35 },
  { item: "Transport", amount: 20 },
];

console.log(Donut.make(expenses, {
  key: (d) => d.item,
  value: (d) => d.amount,
}));
```

### Scatter Plot

For coordinate data, use a scatter plot:

```ts
import { Scatter } from "chartex";

const points = [
  { label: "A", x: 1, y: 2 },
  { label: "B", x: 3, y: 4 },
  { label: "C", x: 2, y: 5 },
];

console.log(Scatter.make(points, {
  series: (d) => d.label,
  x: (d) => d.x,
  y: (d) => d.y,
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

With chartex, creating terminal charts is a breeze! From bar charts to sparklines, you can visualize your data in seconds. Explore the [API Reference](api-reference) for all available chart types and options, and make your terminal come alive with data. Happy charting!
