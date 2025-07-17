# API Reference

This page documents the core functions and types of the chartex module, which you can use to plot in the terminal.

## Creational Chart Functions

### `bar`

Creates a vertical bar chart with bars representing data values. The chart displays bars vertically with values shown at the top and labels at the bottom.

#### Signature

```ts
bar(data: BarChartDatum[], opts?: BarChartOptions): string
```

#### Parameters

- `data` (BarChartDatum[]): An array of data points for the bar chart.
- `opts` (BarChartOptions, optional): Configuration options for customizing the chart appearance.

#### Types

```ts
interface BarChartDatum {
  key: string;           // The label for the bar
  value: number;         // The numeric value for the bar height
  style?: string;        // Optional custom style character for this bar
}

interface BarChartOptions {
  barWidth?: number;     // Width of each bar (default: 3)
  left?: number;         // Left offset position (default: 1)
  height?: number;       // Height of the chart (default: 6)
  padding?: number;      // Padding between bars (default: 3)
  style?: string;        // Default style character for bars (default: "*")
}
```

#### Returns

A string representation of the bar chart, which can be printed to the terminal.

#### Examples

##### Basic Bar Chart

```ts
import { bar } from "chartex";

const salesData = [
  { key: "Q1", value: 120 },
  { key: "Q2", value: 150 },
  { key: "Q3", value: 180 },
  { key: "Q4", value: 90 }
];

console.log(bar(salesData));
```

##### Custom Bar Chart with Options

```ts
import { bar } from "chartex";

const customData = [
  { key: "Jan", value: 45, style: "█" },
  { key: "Feb", value: 67 },
  { key: "Mar", value: 82, style: "▓" },
  { key: "Apr", value: 38 }
];

const options = {
  barWidth: 4,
  height: 8,
  padding: 2,
  style: "▒",
  left: 2
};

console.log(bar(customData, options));
```

> [!Note]
> - The chart automatically adjusts the height based on the maximum value in the dataset.
> - Value labels are displayed at the top of each bar when space permits.
> - Labels are shown at the bottom of each bar, truncated if they exceed the bar width.
> - Individual bars can have custom styling by providing a style property in the data.

### `bullet`

Creates a horizontal bullet chart with bars representing data values. The chart displays horizontal bars with labels and values on the left side, making it ideal for comparing performance metrics or progress indicators.

#### Signature

```ts
bullet(data: BulletChartDatum[], opts?: BulletChartOptions): string
```

#### Parameters

- `data` (BulletChartDatum[]): An array of data points for the bullet chart.
- `opts` (BulletChartOptions, optional): Configuration options for customizing the chart appearance.

#### Types

```ts
interface BulletChartDatum {
  key: string;           // The label for the bullet
  value: number;         // The numeric value for the bullet length
  style?: string;        // Optional custom style character for this bullet
}

interface BulletChartOptions {
  bulletWidth?: number;  // Width of each bullet (default: 3)
  left?: number;         // Left offset position (default: 1)
  height?: number;       // Height of the chart (default: 6)
  padding?: number;      // Padding between bullets (default: 3)
  style?: string;        // Default style character for bullets (default: "*")
}
```

#### Returns

A string representation of the bullet chart, which can be printed to the terminal.

#### Examples

##### Basic Bullet Chart

```ts
import { bullet } from "chartex";

const performanceData = [
  { key: "Sales", value: 85 },
  { key: "Marketing", value: 92 },
  { key: "Support", value: 78 },
  { key: "Development", value: 96 }
];

console.log(bullet(performanceData));
```

##### Custom Bullet Chart with Options

```ts
import { bullet } from "chartex";

const projectProgress = [
  { key: "Frontend", value: 80, style: "█" },
  { key: "Backend", value: 65, style: "▓" },
  { key: "Testing", value: 45, style: "▒" },
  { key: "Documentation", value: 30, style: "░" }
];

const options = {
  width: 15,
  barWidth: 2,
  padding: 2,
  left: 2
};

console.log(bullet(projectProgress, options));
```

> [!Note]
> - The chart automatically scales bars proportionally to the maximum value in the dataset.
> - Labels and values are displayed on the left side with consistent alignment.
> - Individual bars can have custom styling and width by providing style and barWidth properties.
> - The chart supports multiple lines per bar when barWidth is greater than 1.

### `donut`

Creates a donut chart with a hollow center, representing data as segments around a circle. The chart displays percentages and labels for each data segment, with customizable styling and positioning.

#### Signature

```ts
donut(data: DonutChartDatum[], opts?: DonutChartOptions): string
```

#### Parameters

- `data` (DonutChartDatum[]): An array of data points for the donut chart.
- `opts` (DonutChartOptions, optional): Configuration options for customizing the chart appearance.

#### Types

```ts
interface DonutChartDatum {
  key: string;           // The label for the segment
  value: number;         // The numeric value for the segment
  style?: string;        // Optional custom style character for this segment
}

interface DonutChartOptions {
  radius?: number;       // Radius of the donut (default: 5)
  innerRadius?: number;  // Inner radius for the hollow center (default: 2)
  left?: number;         // Left offset position (default: 1)
  padding?: number;      // Padding around the chart (default: 1)
  style?: string;        // Default style character for segments (default: "*")
  showPercentage?: boolean; // Whether to show percentage values (default: true)
  showLabels?: boolean;  // Whether to show labels (default: true)
}
```

#### Returns

A string representation of the donut chart, which can be printed to the terminal.

#### Examples

##### Basic Donut Chart

```ts
import { donut } from "chartex";

const marketShareData = [
  { key: "Desktop", value: 45 },
  { key: "Mobile", value: 35 },
  { key: "Tablet", value: 20 }
];

console.log(donut(marketShareData));
```

##### Custom Donut Chart with Options

```ts
import { donut } from "chartex";

const budgetData = [
  { key: "Salaries", value: 60, style: "█" },
  { key: "Marketing", value: 25, style: "▓" },
  { key: "Operations", value: 15, style: "▒" }
];

const options = {
  radius: 7,
  innerRadius: 3,
  left: 3,
  padding: 2,
  showPercentage: true,
  showLabels: true
};

console.log(donut(budgetData, options));
```

> [!Note]
> - The chart automatically calculates percentages based on the total sum of all values.
> - Segments are proportionally sized according to their values relative to the total.
> - The hollow center creates the characteristic donut appearance.
> - Individual segments can have custom styling by providing a style property in the data.
> - Labels and percentages are displayed below the chart when enabled.
> - The chart uses ASCII characters to approximate circular shapes in the terminal.

### `gauge`

Creates a gauge chart to display a single value as a semi-circular meter. The chart shows a value as a filled arc within a semi-circle, with percentage display and customizable styling, ideal for showing progress, performance metrics, or completion status.

#### Signature

```ts
gauge(data: GaugeChartDatum[], opts?: GaugeChartOptions): string
```

#### Parameters

- `data` (GaugeChartDatum[]): An array containing a single data point for the gauge chart.
- `opts` (GaugeChartOptions, optional): Configuration options for customizing the gauge appearance.

#### Types

```ts
interface GaugeChartDatum {
  key: string;           // The label for the gauge
  value: number;         // The numeric value (0-1 representing 0-100%)
  style?: string;        // Optional custom style character for the filled portion
}

interface GaugeChartOptions {
  radius?: number;       // Radius of the gauge (default: 5)
  left?: number;         // Left offset position (default: 2)
  style?: string;        // Default style character for filled portion (default: "# ")
  bgStyle?: string;      // Background style character for unfilled portion (default: "+ ")
}
```

#### Returns

A string representation of the gauge chart, which can be printed to the terminal.

#### Examples

##### Basic Gauge Chart

```ts
import { gauge } from "chartex";

const performanceData = [
  { key: "CPU Usage", value: 0.75 }
];

console.log(gauge(performanceData));
```

##### Custom Gauge Chart with Options

```ts
import { gauge } from "chartex";

const batteryData = [
  { key: "Battery Level", value: 0.42, style: "█ " }
];

const options = {
  radius: 7,
  left: 3,
  bgStyle: "░ ",
  style: "▓ "
};

console.log(gauge(batteryData, options));
```

##### Multiple Gauge Examples

```ts
import { gauge } from "chartex";

// Low value example
const lowValueData = [{ key: "Progress", value: 0.25 }];
console.log(gauge(lowValueData));

// High value example
const highValueData = [{ key: "Completion", value: 0.90 }];
console.log(gauge(highValueData));

// Custom styling
const customData = [{ key: "Score", value: 0.68, style: "●●" }];
const customOptions = {
  radius: 6,
  bgStyle: "○○",
  left: 4
};
console.log(gauge(customData, customOptions));
```

> [!Note]
> - Values should be between 0 and 1, representing 0% to 100%.
> - The percentage value is automatically calculated and displayed in the center of the gauge.
> - The gauge displays a semi-circular arc with the filled portion representing the current value.
> - Individual gauges can have custom styling by providing a style property in the data.
> - The chart includes scale labels (0 and 100) and the key label at the bottom.

### `pie`

Creates a pie chart representing data as segments of a circle. The chart displays each data value as a proportional slice of the pie, with a legend showing labels, values, and percentages for each segment.

#### Signature

```ts
pie(data: PieChartDatum[], opts?: PieChartOptions): string
```

#### Parameters

- `data` (PieChartDatum[]): An array of data points for the pie chart.
- `opts` (PieChartOptions, optional): Configuration options for customizing the chart appearance.

#### Types

```ts
interface PieChartDatum {
  key: string;           // The label for the pie segment
  value: number;         // The numeric value for the segment
  style?: string;        // Optional custom style character for this segment
}

interface PieChartOptions {
  radius?: number;       // Radius of the pie chart (default: 4)
  left?: number;         // Left offset position (default: 0)
  innerRadius?: number;  // Inner radius (used for donut charts, default: 1)
}
```

#### Returns

A string representation of the pie chart, which can be printed to the terminal.

#### Examples

##### Basic Pie Chart

```ts
import { pie } from "chartex";

const expenseData = [
  { key: "Housing", value: 1200, style: "██" },
  { key: "Food", value: 800, style: "▓▓" },
  { key: "Transport", value: 400, style: "▒▒" },
  { key: "Entertainment", value: 300, style: "░░" }
];

console.log(pie(expenseData));
```

##### Custom Pie Chart with Options

```ts
import { pie } from "chartex";

const surveyData = [
  { key: "Very Satisfied", value: 45, style: "██" },
  { key: "Satisfied", value: 35, style: "▓▓" },
  { key: "Neutral", value: 15, style: "▒▒" },
  { key: "Dissatisfied", value: 5, style: "░░" }
];

const options = {
  radius: 6,
  left: 2
};

console.log(pie(surveyData, options));
```

##### Multiple Pie Chart Examples

```ts
import { pie } from "chartex";

// Market share data
const marketData = [
  { key: "Chrome", value: 65, style: "██" },
  { key: "Firefox", value: 18, style: "▓▓" },
  { key: "Safari", value: 12, style: "▒▒" },
  { key: "Edge", value: 5, style: "░░" }
];

console.log(pie(marketData));

// Small pie chart
const smallData = [
  { key: "Yes", value: 70, style: "██" },
  { key: "No", value: 30, style: "▒▒" }
];

const smallOptions = { radius: 3, left: 1 };
console.log(pie(smallData, smallOptions));
```

> [!Note]
> - The chart automatically calculates percentages based on the total sum of all values.
> - Each segment is proportionally sized according to its value relative to the total.
> - The legend displays the style character, label, value, and percentage for each segment.
> - Individual segments require custom styling through the style property in the data.
> - The chart uses ASCII characters to approximate circular shapes in the terminal.
> - Legend entries are automatically formatted with consistent spacing and alignment.

### `scatter`

Creates a scatter plot chart to display data points as coordinates on a two-dimensional plane. The chart shows individual data points with customizable styling and includes labeled axes with scales, making it ideal for visualizing correlations and distributions.

#### Signature

```ts
scatter(data: ScatterPlotDatum[], opts?: ScatterPlotOptions): string
```

#### Parameters

- `data` (ScatterPlotDatum[]): An array of data points for the scatter plot.
- `opts` (ScatterPlotOptions, optional): Configuration options for customizing the chart appearance.

#### Types

```ts
interface ScatterPlotDatum {
  key: string;           // The label/category for the data point
  value: [number, number]; // The [x, y] coordinates for the point
  style?: string;        // Optional custom style character for this point
  sides?: [number, number]; // Optional custom size [width, height] for this point
}

interface ScatterPlotOptions {
  width?: number;        // Width of the plot area (default: 10)
  height?: number;       // Height of the plot area (default: 10)
  left?: number;         // Left offset position (default: 2)
  style?: string;        // Default style character for points (default: "# ")
  sides?: [number, number]; // Default size for points (default: [1, 1])
  hAxis?: [string, string, string]; // Horizontal axis characters [tick, line, arrow] (default: ["+", "-", ">"])
  vAxis?: [string, string]; // Vertical axis characters [line, arrow] (default: ["|", "A"])
  hName?: string;        // Horizontal axis label (default: "X Axis")
  vName?: string;        // Vertical axis label (default: "Y Axis")
  zero?: string;         // Origin point character (default: "+")
  ratio?: [number, number]; // Scale ratio for [x, y] axes (default: [1, 1])
  hGap?: number;         // Gap between horizontal scale marks (default: 2)
  vGap?: number;         // Gap between vertical scale marks (default: 2)
  legendGap?: number;    // Gap between axis label and legend (default: 0)
}
```

#### Returns

A string representation of the scatter plot chart, which can be printed to the terminal.

#### Examples

##### Basic Scatter Plot

```ts
import { scatter } from "chartex";

const temperatureData = [
  { key: "Jan", value: [1, 2] },
  { key: "Feb", value: [2, 3] },
  { key: "Mar", value: [3, 5] },
  { key: "Apr", value: [4, 7] },
  { key: "May", value: [5, 8] }
];

console.log(scatter(temperatureData));
```

##### Custom Scatter Plot with Options

```ts
import { scatter } from "chartex";

const performanceData = [
  { key: "Team A", value: [3, 4], style: "██", sides: [1, 1] },
  { key: "Team B", value: [5, 6], style: "▓▓", sides: [1, 1] },
  { key: "Team C", value: [2, 8], style: "▒▒", sides: [1, 1] },
  { key: "Team D", value: [7, 5], style: "░░", sides: [1, 1] }
];

const options = {
  width: 12,
  height: 8,
  left: 3,
  hName: "Experience (years)",
  vName: "Performance Score",
  ratio: [1, 10],
  hGap: 3,
  vGap: 2,
  legendGap: 2
};

console.log(scatter(performanceData, options));
```

##### Multiple Data Series Example

```ts
import { scatter } from "chartex";

const salesData = [
  { key: "Q1", value: [1, 120], style: "●●" },
  { key: "Q1", value: [2, 150], style: "●●" },
  { key: "Q2", value: [3, 180], style: "▲▲" },
  { key: "Q2", value: [4, 160], style: "▲▲" },
  { key: "Q3", value: [5, 200], style: "■■" },
  { key: "Q3", value: [6, 190], style: "■■" }
];

const salesOptions = {
  width: 15,
  height: 10,
  hName: "Month",
  vName: "Sales ($k)",
  ratio: [1, 20],
  hGap: 2,
  vGap: 3,
  left: 4
};

console.log(scatter(salesData, salesOptions));
```

> [!Note]
> - Each data point is positioned using [x, y] coordinates in the value array.
> - The chart automatically scales based on the specified ratio for both axes.
> - Individual points can have custom styling and size through style and sides properties.
> - The legend displays all unique keys with their corresponding styles.
> - Axes include scale markers based on the specified gap values and ratios.
> - The chart supports multiple data series by using the same key with different coordinates.
> - The coordinate system uses the bottom-left as the origin (0, 0).

### `sparkline`

Creates a compact, inline sparkline chart representing a series of numeric values as a sequence of Unicode bar characters. Sparklines are ideal for visualizing trends or patterns in small spaces, such as tables or dashboards.

#### Signature

```ts
sparkline(values: number[], opts?: SparklineOptions): string
```

#### Parameters

- `data` (number[]): An array of numeric values for the sparkline.
- `opts` (SparklineOptions, optional): Configuration options for customizing the sparkline appearance.

#### Types

```ts
interface SparklineOptions {
  /** Width of the sparkline */
  width?: number;
  /** Height of the sparkline */
  height?: number;
  /** Tolerance for the sparkline */
  tolerance?: number;
  /** Style character for the sparkline */
  style?: string;
  /** Character for the y-axis */
  yAxisChar?: string;
}
```

#### Returns

A string representation of the sparkline, which can be printed inline in the terminal.

#### Examples

##### Basic Sparkline

```ts
import { sparkline } from "chartex";

const trendData = [
  { value: 5 },
  { value: 9 },
  { value: 7 },
  { value: 12 },
  { value: 6 }
];

console.log(sparkline(trendData));
```

## Data Transformation Functions

### `transformChartData`

Transforms an array of chart data objects into the standard chart datum format. This function is useful when you have data with `key` and `value` properties that need to be converted to the format expected by chart functions.

#### Signature

```ts
transformChartData(data: ChartData[]): ChartDatum[]
```

#### Parameters

- `data` (ChartData[]): An array of chart data objects with key and value properties.

#### Returns

An array of standardized chart datum objects that can be used with any chart function.

#### Examples

##### Basic Data Transformation

```ts
import { transformChartData, bar } from "chartex";

const rawData = [
  { key: "Product A", value: 150 },
  { key: "Product B", value: 200 },
  { key: "Product C", value: 175 }
];

const chartData = transformChartData(rawData);
console.log(bar(chartData));
```

##### Processing External Data

```ts
import { transformChartData, pie } from "chartex";

// Data from an API or database
const salesData = [
  { key: "North", value: 45000 },
  { key: "South", value: 32000 },
  { key: "East", value: 38000 },
  { key: "West", value: 41000 }
];

const transformedData = transformChartData(salesData);
console.log(pie(transformedData));
```

> [!Note]
> - This function ensures data consistency across different chart types.
> - The transformation preserves all original properties while standardizing the format.
> - Use this when your data already has the correct `key` and `value` structure.

### `transformCustomData`

Transforms custom data objects by applying user-defined key and value extraction functions. This is the most flexible transformation function, allowing you to specify exactly how to extract the key and value from each data item.

#### Signature

```ts
transformCustomData<T>(data: T[], keyFn: (item: T) => string, valueFn: (item: T) => number): ChartDatum[]
```

#### Parameters

- `data` (T[]): An array of custom data objects of any type.
- `keyFn` ((item: T) => string): A function that extracts the key/label from each data item.
- `valueFn` ((item: T) => number): A function that extracts the numeric value from each data item.

#### Returns

An array of standardized chart datum objects that can be used with any chart function.

#### Examples

##### Transform Complex Objects

```ts
import { transformCustomData, bullet } from "chartex";

interface Employee {
  name: string;
  department: string;
  performanceScore: number;
  yearsOfService: number;
}

const employees: Employee[] = [
  { name: "Alice", department: "Engineering", performanceScore: 92, yearsOfService: 3 },
  { name: "Bob", department: "Marketing", performanceScore: 87, yearsOfService: 5 },
  { name: "Carol", department: "Sales", performanceScore: 95, yearsOfService: 2 }
];

const performanceData = transformCustomData(
  employees,
  (emp) => emp.name,
  (emp) => emp.performanceScore
);

console.log(bullet(performanceData));
```

##### Transform Nested Data

```ts
import { transformCustomData, bar } from "chartex";

interface Product {
  info: {
    name: string;
    category: string;
  };
  metrics: {
    sales: number;
    revenue: number;
    units: number;
  };
}

const products: Product[] = [
  {
    info: { name: "Laptop", category: "Electronics" },
    metrics: { sales: 450, revenue: 675000, units: 1500 }
  },
  {
    info: { name: "Phone", category: "Electronics" },
    metrics: { sales: 320, revenue: 480000, units: 1600 }
  }
];

const revenueData = transformCustomData(
  products,
  (product) => product.info.name,
  (product) => product.metrics.revenue
);

console.log(bar(revenueData));
```

##### Transform with Calculations

```ts
import { transformCustomData, donut } from "chartex";

interface OrderData {
  month: string;
  orders: number;
  returns: number;
}

const orderData: OrderData[] = [
  { month: "Jan", orders: 1000, returns: 50 },
  { month: "Feb", orders: 1200, returns: 48 },
  { month: "Mar", orders: 950, returns: 42 }
];

// Calculate success rate
const successRateData = transformCustomData(
  orderData,
  (order) => order.month,
  (order) => ((order.orders - order.returns) / order.orders) * 100
);

console.log(donut(successRateData));
```

> [!Note]
> - This is the most flexible transformation function for complex data structures.
> - The key function must return a string, and the value function must return a number.
> - You can perform calculations or data manipulation within the extraction functions.
> - Use this when your data doesn't follow standard key-value patterns.

### `transformObjectData`

Transforms an object with key-value pairs into the standard chart datum format. This function is useful when you have data stored as an object where keys represent labels and values represent numeric data.

#### Signature

```ts
transformObjectData(data: Record<string, number>): ChartDatum[]
```

#### Parameters

- `data` (Record<string, number>): An object where keys are labels and values are numeric data.

#### Returns

An array of standardized chart datum objects that can be used with any chart function.

#### Examples

##### Basic Object Transformation

```ts
import { transformObjectData, bar } from "chartex";

const salesByRegion = {
  "North America": 45000,
  "Europe": 38000,
  "Asia": 52000,
  "South America": 23000
};

const chartData = transformObjectData(salesByRegion);
console.log(bar(chartData));
```

##### Configuration Data

```ts
import { transformObjectData, pie } from "chartex";

// Browser usage statistics
const browserStats = {
  "Chrome": 65.2,
  "Firefox": 18.8,
  "Safari": 12.1,
  "Edge": 3.9
};

const pieData = transformObjectData(browserStats);
console.log(pie(pieData));
```

##### Survey Results

```ts
import { transformObjectData, donut } from "chartex";

const surveyResults = {
  "Very Satisfied": 42,
  "Satisfied": 35,
  "Neutral": 15,
  "Dissatisfied": 6,
  "Very Dissatisfied": 2
};

const surveyData = transformObjectData(surveyResults);
console.log(donut(surveyData));
```

> [!Note]
> - This function is ideal for simple key-value data structures.
> - Object keys become chart labels, and values become chart values.
> - The order of data points may vary depending on JavaScript object key ordering.
> - Use this when your data is already in a simple object format.

### `transformScatterData`

Transforms scatter plot data into the standard scatter datum format. This specialized function handles the conversion of coordinate data and additional properties needed for scatter plots.

#### Signature

```ts
transformScatterData(data: ScatterData[]): ScatterPlotDatum[]
```

#### Parameters

- `data` (ScatterData[]): An array of scatter data objects with coordinates and labels.

#### Returns

An array of standardized scatter plot datum objects that can be used with the scatter chart function.

#### Examples

##### Basic Scatter Data Transformation

```ts
import { transformScatterData, scatter } from "chartex";

const rawScatterData = [
  { key: "Point A", x: 2, y: 3 },
  { key: "Point B", x: 4, y: 7 },
  { key: "Point C", x: 6, y: 2 },
  { key: "Point D", x: 8, y: 9 }
];

const scatterData = transformScatterData(rawScatterData);
console.log(scatter(scatterData));
```

##### Scientific Data Transformation

```ts
import { transformScatterData, scatter } from "chartex";

interface ExperimentData {
  key: string;
  temperature: number;
  pressure: number;
  volume: number;
}

const experimentResults: ExperimentData[] = [
  { key: "Test 1", temperature: 20, pressure: 1.2, volume: 100 },
  { key: "Test 2", temperature: 40, pressure: 1.8, volume: 95 },
  { key: "Test 3", temperature: 60, pressure: 2.4, volume: 88 }
];

// Convert to scatter data format
const scatterInput = experimentResults.map(exp => ({
  key: exp.key,
  x: exp.temperature,
  y: exp.pressure
}));

const scatterData = transformScatterData(scatterInput);
console.log(scatter(scatterData));
```

##### Performance Metrics

```ts
import { transformScatterData, scatter } from "chartex";

const performanceMetrics = [
  { key: "Team Alpha", experience: 3, productivity: 85 },
  { key: "Team Beta", experience: 5, productivity: 92 },
  { key: "Team Gamma", experience: 2, productivity: 78 },
  { key: "Team Delta", experience: 7, productivity: 96 }
];

const scatterInput = performanceMetrics.map(team => ({
  key: team.key,
  x: team.experience,
  y: team.productivity
}));

const scatterData = transformScatterData(scatterInput);
console.log(scatter(scatterData));
```

> [!Note]
> - This function is specifically designed for scatter plot data transformation.
> - Input data should have `key`, `x`, and `y` properties.
> - The transformed data includes the `value` property as a coordinate pair [x, y].
> - Use this when preparing coordinate data for scatter plots.

### `transformSimpleData`

Transforms simple arrays of primitive values into the standard chart datum format by providing automatic key generation. This function is useful when you have just numeric values and need to create basic labels.

#### Signature

```ts
transformSimpleData(data: number[]): ChartDatum[]
```

#### Parameters

- `data` (number[]): An array of numeric values.

#### Returns

An array of standardized chart datum objects with auto-generated keys that can be used with any chart function.

#### Examples

##### Basic Number Array

```ts
import { transformSimpleData, bar } from "chartex";

const monthlyRevenue = [45000, 52000, 48000, 61000, 55000, 58000];
const chartData = transformSimpleData(monthlyRevenue);
console.log(bar(chartData));
```

##### Test Scores

```ts
import { transformSimpleData, bullet } from "chartex";

const testScores = [85, 92, 78, 95, 88, 91, 87];
const scoreData = transformSimpleData(testScores);
console.log(bullet(scoreData));
```

##### Quick Visualization

```ts
import { transformSimpleData, pie } from "chartex";

// Quick data visualization without labels
const values = [25, 35, 15, 20, 5];
const pieData = transformSimpleData(values);
console.log(pie(pieData));
```

##### Processing Calculated Data

```ts
import { transformSimpleData, donut } from "chartex";

const dailySales = [1200, 1450, 1100, 1680, 1520];
const averages = dailySales.map(sale => sale / 100); // Convert to hundreds

const chartData = transformSimpleData(averages);
console.log(donut(chartData));
```

> [!Note]
> - This function automatically generates keys in the format "Item 1", "Item 2", etc.
> - Use this for quick visualizations when you don't need specific labels.
> - The function is ideal for prototyping and simple data visualization.
> - Consider using other transformation functions if you need meaningful labels.
