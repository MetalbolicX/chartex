import scatter, { type ScatterPlotDatum } from "../lib/scatter.ts";

const data: ScatterPlotDatum[] = [
  { key: "A", value: [1, 2] },
  { key: "B", value: [3, 4], style: "# ", sides: [1, 1] },
  { key: "C", value: [5, 6], style: "* ", sides: [2, 2] },
  { key: "D", value: [7, 8], style: "@ ", sides: [1, 2] },
];

console.log(
  scatter(data, {
    left: 2,
  })
);
