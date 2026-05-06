import * as Chartex from "../dist/main.mjs";

const { Bar, Ansi, Bullet, Pie, Donut, Gauge, Scatter } = Chartex;

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
  { segment: "Desktop", pct: 45, style: Ansi.fg("Red", "* ") },
  { segment: "Mobile", pct: 35, style: Ansi.fg("Blue", "+ ") },
  { segment: "Tablet", pct: 20, style: Ansi.fg("Green", "# ") },
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

const CPUDate = [
  { metric: "CPU Usage", value: 75 },
]

const gaugeChartCPU = Gauge.make(
  CPUDate,
  {
    key: ({ metric }: { metric: string }) => metric,
    value: ({ value }: { value: number }) => value,
  },
  { radius: 7 },
);

console.log(gaugeChartCPU + "\n");

const coordinates = [
  { group: "A", x: 1, y: 2, style: Ansi.fg("Red", "*") },
  { group: "A", x: 2, y: 3, style: Ansi.fg("Red", "*") },
  { group: "B", x: 3, y: 1, style: Ansi.fg("Blue", "+") },
  { group: "B", x: 4, y: 4, style: Ansi.fg("Blue", "+") },
  { group: "C", x: 5, y: 2, style: Ansi.fg("Green", "#") },
  { group: "C", x: 6, y: 3, style: Ansi.fg("Green", "#") },
];

const scatterChartCoordinates = Scatter.make(
  coordinates,
  {
    key: ({ group }: { group: string }) => group,
    x: ({ x }: { x: number }) => x,
    y: ({ y }: { y: number }) => y,
    style: ({ style }: { style: string }) => style,
  },
);

console.log(scatterChartCoordinates + "\n");
