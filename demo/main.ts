import {
  bg,
  fg,
  scatter,
  bar,
  bullet,
  gauge,
  pie,
  sparkline,
  type ScatterPlotDatum,
} from "../src/index.ts";

const scatterData: ScatterPlotDatum[] = [
  ...Array.from({ length: 5 }, (_, i) => ({
    key: "A",
    value: [i + 1, i + 1] as [number, number],
    style: fg("red", "*"),
  })),
  ...Array.from({ length: 11 }, (_, i) => ({
    key: "A",
    value: [i + 6, 6] as [number, number],
    style: fg("red", "*"),
  })),
  // { key: "B", value: [2, 6], style: fg("blue", "# "), sides: [2, 2] },
  { key: "B", value: [2, 6], style: fg("blue", "# ") },
  { key: "C", value: [6, 9], style: bg("cyan", 2) },
];

console.log(`${scatter(scatterData)}\n`);

const squareData: ScatterPlotDatum[] = [
  { key: "A", value: [-2, 4], style: fg("red", "*") },
  { key: "A", value: [-1, 1], style: fg("red", "* ") },
  { key: "A", value: [0, 0], style: fg("red", "* ") },
  { key: "A", value: [1, 1], style: fg("red", "* ") },
  { key: "A", value: [2, 4], style: fg("red", "* ") },
];

console.log(`${scatter(squareData, { width: 20, height: 10 })}\n`);
// console.log(`${scatter(squareData)}\n`);

const barData = [
  { key: "A", value: 5, style: "*" },
  { key: "B", value: 3, style: "+" },
  { key: "C", value: 11 },
  { key: "D", value: 1, style: bg("red") },
  { key: "E", value: 5, style: bg("green") },
  { key: "F", value: 7, style: bg("blue"), padding: 1 },
  { key: "G", value: 0, style: bg("yellow") },
];

console.log(
  bar(barData, {
    barWidth: 3,
    left: 1,
    // height: 6,
    padding: 3,
    style: "*",
  })
);

// Bullet chart data
const bulletData = [
  { key: "Month", value: 5 },
  { key: "Week", value: 3, style: fg("red", "*") },
  { key: "Day", value: 20, style: bg("blue"), barWidth: 1 },
  { key: "Now", value: 15, style: bg("cyan"), barWidth: 1 },
];

console.log(bullet(bulletData, { style: "+", barWidth: 2 }));

// Gauge chart data
const gaugeData1 = [{ key: "A", value: 0.5 }];

const gaugeData2 = [{ key: "PR", value: 0.3 }];

console.log(gauge(gaugeData1, { radius: 7 }));
console.log(
  gauge(gaugeData2, {
    radius: 7,
    style: bg("green", 2),
    bgStyle: bg("magenta", 2),
  })
);

// Pie chart data
const pieData1 = [
  { key: "A", value: 5, style: "* " },
  { key: "B", value: 10, style: "+ " },
  { key: "C", value: 10, style: "# " },
  { key: "D", value: 10, style: "O " },
];

const pieData2 = [
  { key: "A", value: 5, style: bg("cyan", 2) },
  { key: "B", value: 5, style: bg("yellow", 2) },
  { key: "C", value: 5, style: bg("magenta", 2) },
  { key: "D", value: 5, style: bg("white", 2) },
];

console.log(pie(pieData1, { left: 1 }));
console.log(pie(pieData2, { left: 1 }));

// Sparkline data
const sparklineData = [
  { key: "A", value: 10, style: "*" },
  { key: "B", value: 20, style: "*" },
  { key: "C", value: 15, style: "*" },
  { key: "D", value: 25, style: "*" },
  { key: "E", value: 30, style: "*" },
  { key: "F", value: 50, style: "*" },
];

console.log(
  sparkline(sparklineData, {
    width: 30,
    // height: 10,
    tolerance: 1,
    style: "*",
  })
);
