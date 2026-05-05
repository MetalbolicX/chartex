// import { bg, fg, scatter, bar, pie, type ScatterPlotDatum } from "../src/index.ts";

// const scatterData: ScatterPlotDatum[] = [
//   { key: "A", value: [1, 2], style: fg("red", "*") },
//   { key: "B", value: [3, 4], style: fg("blue", "#") },
//   { key: "C", value: [5, 6], style: fg("green", "+") },
// ];

// console.log(scatter(scatterData, { width: 15 }));
// console.log("");
import * as Chartex from "../dist/main.mjs";

const { Bar, Ansi, Bullet, Pie, Donut } = Chartex;

const salesData = [
  { country: "MX", amount: 5, style: Ansi.fg("Red", "*") },
  { country: "US", amount: 7, style: Ansi.fg("Blue", "+") },
  { country: "CA", amount: 4, style: Ansi.fg("Green", "#") },
];

const barChartSales = Bar.make(
  salesData,
  {
    key: ({ country }: { country: string }) => country,
    value: ({ amount }: { amount: number }) => amount,
    style: ({ style }: { style: string }) => style,
  },
);

console.log(barChartSales + "\n");

const departmentScores = [
  { dept: "Sales", score: 85, style: Ansi.fg("Red", "█") },
  { dept: "Marketing", score: 92, style: Ansi.fg("Blue", "+") },
  { dept: "Support", score: 78, style: Ansi.fg("Green", "#") },
];

const bulletChartCO2 = Bullet.make(
  departmentScores,
  {
    key: ({ dept }: { dept: string }) => dept,
    value: ({ score }: { score: number }) => score,
    style: ({ style }: { style: string }) => style,
  },
);

console.log(bulletChartCO2 + "\n");

const monthlyData = [
  { month: "Jan", value: 100, style: "* " },
  { month: "Feb", value: 150, style: "+ " },
  { month: "Mar", value: 120, style: "# " },
  { month: "Apr", value: 180, style: "O " },
];

const pieChartMonthly = Pie.make(
  monthlyData,
  {
    key: ({ month }: { month: string }) => month,
    value: ({ value }: { value: number }) => value,
    style: ({ style }: { style: string }) => style,
  },
);

console.log(pieChartMonthly + "\n");

const electronicData = [
  { segment: "Desktop", pct: 45, style: Ansi.fg("Red", "*") },
  { segment: "Mobile", pct: 35, style: Ansi.fg("Blue", "+") },
  { segment: "Tablet", pct: 20, style: Ansi.fg("Green", "#") },
];

const donutChartElectronic = Donut.make(
  electronicData,
  {
    key: ({ segment }: { segment: string }) => segment,
    value: ({ pct }: { pct: number }) => pct,
    style: ({ style }: { style: string }) => style,
  },
);

console.log(donutChartElectronic + "\n");

// const serverData = [
//   { key: "Server A", value: 80, style: bg("green", 2) },
//   { key: "Server B", value: 60, style: bg("yellow", 2) },
//   { key: "Server C", value: 90, style: bg("red", 2) },
// ];

// console.log(bar(serverData, { barWidth: 3, height: 6 }));
// console.log("");

// const categorical = [
//   { key: "Mexico", value: 5, style: "*" },
//   { key: "USA", value: 7, style: "+" },
//   { key: "Canada", value: 4, style: "#" },
// ];
// console.log("categorical:", bar(categorical, { height: 6 }));
// console.log("");

// const scatterRow: ScatterPlotDatum[] = [
//   { key: "Mexico", value: [1, 5], style: fg("red", "*") },
//   { key: "USA", value: [2, 7], style: fg("blue", "#") },
//   { key: "Canada", value: [3, 4], style: fg("green", "+") },
// ];
// console.log("scatter:", scatter(scatterRow, { width: 15 }));
