import { bg, fg, scatter, bar, pie, type ScatterPlotDatum } from "../src/index.ts";

const scatterData: ScatterPlotDatum[] = [
  { key: "A", value: [1, 2], style: fg("red", "*") },
  { key: "B", value: [3, 4], style: fg("blue", "#") },
  { key: "C", value: [5, 6], style: fg("green", "+") },
];

console.log(scatter(scatterData, { width: 15 }));
console.log("");

const salesData = [
  { key: "Laptop", value: 150, style: "*" },
  { key: "Phone", value: 300, style: "+" },
  { key: "Tablet", value: 75, style: "#" },
];

console.log(bar(salesData, { barWidth: 3, height: 6 }));
console.log("");

const simpleData = [
  { key: "Jan", value: 10, style: "*" },
  { key: "Feb", value: 20, style: "*" },
  { key: "Mar", value: 15, style: "*" },
  { key: "Apr", value: 25, style: "*" },
  { key: "May", value: 30, style: "*" },
];

console.log(bar(simpleData, { barWidth: 2, height: 8 }));
console.log("");

const monthlyData = [
  { key: "Jan", value: 100, style: "* " },
  { key: "Feb", value: 150, style: "+ " },
  { key: "Mar", value: 120, style: "# " },
  { key: "Apr", value: 180, style: "O " },
];

console.log(pie(monthlyData, { left: 1 }));
console.log("");

const serverData = [
  { key: "Server A", value: 80, style: bg("green", 2) },
  { key: "Server B", value: 60, style: bg("yellow", 2) },
  { key: "Server C", value: 90, style: bg("red", 2) },
];

console.log(bar(serverData, { barWidth: 3, height: 6 }));
console.log("");

const categorical = [
  { key: "Mexico", value: 5, style: "*" },
  { key: "USA", value: 7, style: "+" },
  { key: "Canada", value: 4, style: "#" },
];
console.log("categorical:", bar(categorical, { height: 6 }));
console.log("");

const scatterRow: ScatterPlotDatum[] = [
  { key: "Mexico", value: [1, 5], style: fg("red", "*") },
  { key: "USA", value: [2, 7], style: fg("blue", "#") },
  { key: "Canada", value: [3, 4], style: fg("green", "+") },
];
console.log("scatter:", scatter(scatterRow, { width: 15 }));