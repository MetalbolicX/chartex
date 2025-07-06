import { createPieChart } from "./src/index.ts";

// Pie
const pieData = [
  { key: 'A', value: 5, style: '* ' },
  { key: 'B', value: 10, style: '+ ' },
  { key: 'C', value: 10, style: '# ' },
  { key: 'D', value: 10, style: 'O ' }
]

console.log(createPieChart(pieData));
