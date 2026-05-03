import * as Chartex from "../dist/main.mjs";

const { bg, fg } = Chartex.Ansi;

const scatterData = [
  ...Array.from({ length: 5 }, (_, i) => ({
    key: "A",
    value: [i + 1, i + 1] as [number, number],
    style: fg("Red", "*"),
  })),
  ...Array.from({ length: 11 }, (_, i) => ({
    key: "A",
    value: [i + 6, 6] as [number, number],
    style: fg("Red", "*"),
  })),
  { key: "B", value: [2, 6], style: fg("Blue", "# ") },
  { key: "C", value: [6, 9], style: bg("Cyan", 2) },
];

const scatterConfig = {
  key: (d: { key: string }) => d.key,
  x: (d: { value: [number, number] }) => d.value[0],
  y: (d: { value: [number, number] }) => d.value[1],
  style: (d: { style: string }) => d.style,
};

console.log(`${Chartex.Scatter.make(scatterData, scatterConfig, {})}\n`);

const scatterData3 = [
  { key: "A", value: [0, -0.9], style: fg("Red", "*") },
  { key: "A", value: [1, -0.8], style: fg("Red", "*") },
  { key: "B", value: [2, -0.7], style: fg("Blue", "#") },
  { key: "B", value: [3, -0.6], style: fg("Blue", "#") },
  { key: "C", value: [6, -0.5], style: fg("Green", "@") },
  { key: "C", value: [7, -0.4], style: fg("Green", "@") },
  { key: "D", value: [8, 0.5], style: fg("Yellow", "$") },
  { key: "D", value: [9, 0.6], style: fg("Yellow", "$") },
];

console.log(Chartex.Scatter.make(scatterData3, scatterConfig, {}));

const salesData = [
  { key: "Q1", value: [1, 12], style: "●●" },
  { key: "Q1", value: [2, 15], style: "●●" },
  { key: "Q2", value: [3, 18], style: "▲▲" },
  { key: "Q2", value: [4, 16], style: "▲▲" },
  { key: "Q3", value: [5, 20], style: "■■" },
  { key: "Q3", value: [6, 19], style: "■■" }
];

const salesOptions = {
  legendGap: 18,
  left: 4,
};

console.log(Chartex.Scatter.make(salesData, scatterConfig, salesOptions));

const squareData = [
  { key: "A", value: [-2, 4], style: fg("Red", "*") },
  { key: "A", value: [-1, 1], style: fg("Red", "*") },
  { key: "A", value: [0, 0], style: fg("Red", "*") },
  { key: "A", value: [1, 1], style: fg("Red", "*") },
  { key: "A", value: [2, 4], style: fg("Red", "*") },
];

const squareOptions = {
  width: 2,
  height: 4,
  vAxis: ["|", "A"],
  hName: "X Axis",
  vName: "Y Axis",
  zero: "+",
  ratio: [1, 1],
  hGap: 1,
  vGap: 1,
  legendGap: 2,
};

console.log(Chartex.Scatter.make(squareData, scatterConfig, squareOptions));

const barData = [
  { key: "A", value: 5, style: "*" },
  { key: "B", value: 3, style: "+" },
  { key: "C", value: 11 },
  { key: "D", value: 1, style: bg("Red") },
  { key: "E", value: 5, style: bg("Green") },
  { key: "F", value: 7, style: bg("Blue") },
  { key: "G", value: 0, style: bg("Yellow") },
];

const barConfig = {
  key: (d: { key: string }) => d.key,
  value: (d: { value: number; style?: string }) => d.value,
};

const barOptions = {
  barWidth: 3,
  left: 1,
  padding: 3,
  style: "*",
};

console.log(Chartex.Bar.make(barData, barConfig, barOptions));

const bulletData = [
  { key: "Month", value: 5 },
  { key: "Week", value: 3, style: fg("Red", "*") },
  { key: "Day", value: 20, style: bg("Blue") },
  { key: "Now", value: 15, style: bg("Cyan") },
];

const bulletConfig = {
  key: (d: { key: string }) => d.key,
  value: (d: { value: number; style?: string }) => d.value,
};

console.log(Chartex.Bullet.make(bulletData, bulletConfig, { style: "+", barWidth: 2 }));

const gaugeData1 = [{ key: "A", value: 0.5 }];
const gaugeData2 = [{ key: "PR", value: 0.3 }];

const gaugeConfig = {
  key: (d: { key: string }) => d.key,
  value: (d: { value: number }) => d.value,
};

console.log(Chartex.Gauge.make(gaugeData1, gaugeConfig, { radius: 7 }));
console.log(Chartex.Gauge.make(gaugeData2, gaugeConfig, {
  radius: 7,
  style: bg("Green", 2),
  bgStyle: bg("Magenta", 2),
}));

const pieData1 = [
  { key: "A", value: 5, style: "* " },
  { key: "B", value: 10, style: "+ " },
  { key: "C", value: 10, style: "# " },
  { key: "D", value: 10, style: "O " },
];

const pieData2 = [
  { key: "A", value: 5, style: bg("Cyan", 2) },
  { key: "B", value: 5, style: bg("Yellow", 2) },
  { key: "C", value: 5, style: bg("Magenta", 2) },
  { key: "D", value: 5, style: bg("White", 2) },
];

const pieConfig = {
  key: (d: { key: string }) => d.key,
  value: (d: { value: number }) => d.value,
  style: (d: { style?: string }) => d.style,
};

console.log(Chartex.Pie.make(pieData1, pieConfig, { left: 1 }));
console.log(Chartex.Pie.make(pieData2, pieConfig, { left: 1 }));

const sparklineData = [
  { key: "A", value: 10, style: "*" },
  { key: "B", value: 20, style: "*" },
  { key: "C", value: 15, style: "*" },
  { key: "D", value: 25, style: "*" },
  { key: "E", value: 30, style: "*" },
  { key: "F", value: 50, style: "*" },
];

const sparklineConfig = {
  key: (d: { key: string }) => d.key,
  value: (d: { value: number }) => d.value,
  style: (d: { style?: string }) => d.style,
};

console.log(Chartex.Sparkline.make(sparklineData, sparklineConfig, {
  width: 30,
  tolerance: 1,
  style: "*",
}));