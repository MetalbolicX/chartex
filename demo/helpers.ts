import {
  scatter,
  bar,
  pie,
  transformScatterData,
  transformChartData,
  transformSimpleData,
  transformObjectData,
  transformCustomData,
} from "../src/index.ts";

// Example 1: Common JSON structure with x/y coordinates
const commonScatterData = [
  { x: 1, y: 2, category: "A" },
  { x: 3, y: 4, category: "B" },
  { x: 5, y: 6, category: "C" },
];

// Transform and use directly
const scatterChart = scatter(transformScatterData(commonScatterData), {
  width: 15,
});
console.log(scatterChart);

// Example 2: Common JSON structure with value field
const salesData = [
  { product: "Laptop", sales: 150 },
  { product: "Phone", sales: 300 },
  { product: "Tablet", sales: 75 },
];

// Transform using custom field names
const barChart = bar(
  transformChartData(salesData, "product", "sales"),
  { barWidth: 3, height: 6 }
);
console.log(barChart);

// Example 3: Simple array of values
const simpleValues = [10, 20, 15, 25, 30];
const simpleChart = bar(transformSimpleData(simpleValues, "Month"), {
  barWidth: 2,
  height: 8,
});
console.log(simpleChart);

// Example 4: Object with key-value pairs
const monthlyData = {
  "Jan": 100,
  "Feb": 150,
  "Mar": 120,
  "Apr": 180,
};

const pieChart = pie(
  transformObjectData(monthlyData).map((item, index) => ({
    ...item,
    style: ["* ", "+ ", "# ", "O "][index % 4],
  })),
  { left: 1 }
);
console.log(pieChart);

// Example 5: Custom field mapping
const customData = [
  { name: "Server A", load: 0.8, region: "US" },
  { name: "Server B", load: 0.6, region: "EU" },
  { name: "Server C", load: 0.9, region: "Asia" },
];

const customChart = bar(
  transformCustomData(customData, { key: "name", value: "load" }) as Array<{
    key: string;
    value: number;
    style?: string;
  }>,
  { barWidth: 3, height: 6 }
);
console.log(customChart);
