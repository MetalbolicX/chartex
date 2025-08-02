# Tutorials for chartex

## Introduction

Welcome to the world of ASCII charts with **chartex**! 📊 Whether you're building dashboards, analyzing data, or just want to add some visual flair to your terminal, chartex makes it easy and fun. In this tutorial, we'll walk through the basics of using chartex to create beautiful charts right in your terminal. Let's get started! 🚀

## Installing chartex

First, make sure you have chartex installed. Follow the [Getting Started](getting-started) to get set up. Once installed, you can start creating charts in your TypeScript projects.

## Creating Your First Bar Chart

Let's create a simple bar chart to visualize some sales data. 📈

```ts
import { bar } from "chartex";

const data = [
  { key: "A", value: 10 },
  { key: "B", value: 20 },
  { key: "C", value: 15 }
];

console.log(bar(data, { height: 8 }));
```

This will print a vertical bar chart in your terminal, making your data pop! 🌟

### Using Helper Functions for Data Transformation

chartex comes with handy utilities to transform your data into the right format. For example, you can use `parseCategoricalData` to convert raw objects into chart data:

```ts
import { parseCategoricalData, bar } from "chartex";

const rawData = [
  { section: "A", sales: 10 },
  { section: "B", sales: 20 },
  { section: "C", sales: 15 }
];

const chartData = parseCategoricalData(rawData, "section", "sales");
console.log(bar(chartData));
```

No more manual mapping—just transform and visualize! 🔄

## Exploring Other Chart Types

### Bullet Chart with parseFromObject

You can quickly turn an object of values into a bullet chart using `parseFromObject`. This is great for comparing metrics side by side! 📏

```ts
import { parseFromObject, bullet } from "chartex";

const metrics = {
  Sales: 85,
  Marketing: 92,
  Support: 78,
  Development: 96
};

const bulletData = parseFromObject(metrics, "▓");
console.log(bullet(bulletData, { style: "▓" }));
```

### Donut Chart with parseList

If you have a simple list of numbers, use `parseList` to create a donut chart. Add a custom style for extra flair! 🍩

```ts
import { parseList, donut } from "chartex";

const expenses = [45, 35, 20];
const donutData = parseList(expenses, "Segment", "█");
console.log(donut(donutData, { style: "█" }));
```

### Scatter Plot with parseScatterData

For visualizing coordinates, `parseScatterData` makes it easy to prepare your data for a scatter plot. Try using a unique style for each point! 🎯

```ts
import { parseScatterData, scatter } from "chartex";

const points = [
  { group: "A", x: 1, y: 2 },
  { group: "B", x: 3, y: 4 },
  { group: "C", x: 2, y: 5 }
];
const scatterData = parseScatterData(points, "group", "x", "y", "●");
console.log(scatter(scatterData, { width: 16, height: 8, style: "●" }));
```

### Sparkline with parseRow

You can use `parseRow` to flexibly map any data structure to a sparkline. This is perfect for showing trends! 📈

```ts
import { parseRow, sparkline } from "chartex";

const trendData = [
  { day: "Mon", value: 10 },
  { day: "Tue", value: 25 },
  { day: "Wed", value: 15 }
];
const sparkData = parseRow(trendData, item => item.day, item => item.value, "░");
console.log(sparkline(sparkData, { width: 10 }));
```

With chartex, creating terminal charts is a breeze! 🌬️ From bar charts to sparklines, you can visualize your data in seconds. Explore the API, try out different chart types, and make your terminal come alive with data. Happy charting! 🥳
