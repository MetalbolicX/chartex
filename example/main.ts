import { renderScatterPlot, type ScatterPlotDatum } from "../src/index.ts";

// const bulletData = [
//   { key: 'Month', value: 5 },
//   { key: 'Week', value: 3 },
//   { key: 'Day', value: 20, barWidth: 1 },
//   { key: 'Now', value: 15, barWidth: 1 }
// ];

// console.log(renderBulletChart(bulletData));

const salesData: ScatterPlotDatum[] = [
  { key: "Cost", value: [1, 100], style: "+" },
  { key: "Cost", value: [2, 150], style: "+" },
  { key: "Cost", value: [3, 120], style: "+" },
  { key: "Cost", value: [4, 180], style: "+" },
  { key: "Cost", value: [5, 160], style: "+" },
  { key: "Cost", value: [6, 200], style: "+" },
  { key: "Price", value: [1, 120], style: "*" },
  { key: "Price", value: [2, 180], style: "*" },
  { key: "Price", value: [3, 140], style: "*" },
  { key: "Price", value: [4, 200], style: "*" },
  { key: "Price", value: [5, 160], style: "*" },
  { key: "Price", value: [6, 220], style: "*" },
];

console.log(renderScatterPlot(salesData));
