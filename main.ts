import { createScatterPlot } from "./src/index.ts";

// Scatter Plot
const scatterData = [
  { key: "Series A", value: [2, 3], style: "* " },
  { key: "Series A", value: [4, 6], style: "* " },
  { key: "Series A", value: [6, 2], style: "* " },
  { key: "Series A", value: [8, 7], style: "* " },
  { key: "Series B", value: [1, 5], style: "+ " },
  { key: "Series B", value: [3, 8], style: "+ " },
  { key: "Series B", value: [5, 4], style: "+ " },
  { key: "Series B", value: [7, 9], style: "+ " },
  { key: "Series C", value: [2, 7], style: "o " },
  { key: "Series C", value: [9, 3], style: "o " },
  { key: "Series C", value: [6, 8], style: "o " },
];

console.log(createScatterPlot(scatterData));
