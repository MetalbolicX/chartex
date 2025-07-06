import { createGaugeChart } from "./src/index.ts";

const gaugeData = [
  { key: 'A', value: 0.5 }
]

console.log(createGaugeChart(gaugeData));
