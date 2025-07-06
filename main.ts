import { createBarChart } from "./src/index.ts";

// Bar
const barData = [
  { key: 'A', value: 5, style: '*' },
  { key: 'B', value: 3, style: '+' },
  { key: 'C', value: 11 },
  { key: 'D', value: 1 },
  { key: 'E', value: 5 },
  { key: 'F', value: 7, padding: 1 },
  { key: 'G', value: 0 }
];

console.log(createBarChart(barData));
