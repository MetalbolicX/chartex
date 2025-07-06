import { createBulletChart } from "./src/index.ts";

const bulletData = [
  { key: "Month", value: 5 },
  { key: "Week", value: 3 },
  { key: "Day", value: 20, barWidth: 1 },
  { key: "Now", value: 15, barWidth: 1 },
];

console.log(createBulletChart(bulletData));
