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



With chartex, creating terminal charts is a breeze! 🌬️ From bar charts to sparklines, you can visualize your data in seconds. Explore the API, try out different chart types, and make your terminal come alive with data. Happy charting! 🥳
