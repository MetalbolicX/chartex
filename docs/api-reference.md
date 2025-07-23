# API Reference

This page documents the core functions and types of the chartex module to build various types of ASCII charts in the terminal and their configuration.

## Categorical Chart

### `bar`

Creates a vertical bar chart with bars representing data values. The chart displays bars vertically with values shown at the top and labels at the bottom.

#### Signature

```ts
bar(data: BarChartDatum[], opts?: BarChartOptions): string
```

#### Parameters

- `data` (`BarChartDatum[]`): An array of data points for the bar chart.
- `opts` (`BarChartOptions`, optional): Configuration options for customizing the chart appearance.

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
  height?: number;       // Height of the chart (default: 40% of terminal height, min 6)
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

const barData = [
  { key: "A", value: 10, style: "*" },
  { key: "B", value: 20, style: "#" },
  { key: "C", value: 15, style: "+" }
];

const chart = bar(barData, { height: 10 });
console.log(chart);
// Outputs a vertical bar chart with the specified data and options
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

## Numerical Chart

### `scatter`

Creates a scatter plot chart to display data points as coordinates on a two-dimensional grid. The chart shows individual data points with customizable styling and includes labeled axes with scales.

#### Signature

```ts
scatter(data: ScatterPlotDatum[], options?: ScatterPlotOptions): string
```

#### Parameters

- `data` (`ScatterPlotDatum[]`): An array of data points for the scatter plot.
- `options` (`ScatterPlotOptions`, optional): Configuration options for customizing the chart appearance.

#### Types

```ts
interface ScatterPlotDatum {
  key: string;             // The label/category for the data point
  value: [number, number]; // The [x, y] coordinates for the point
  style?: string;          // Optional custom style character for this point
}

interface ScatterPlotOptions {
  width?: number;          // Width of the plot area (default: 60% of terminal width, min 10)
  height?: number;         // Height of the plot area (default: 30% of terminal height, min 8)
  style?: string;          // Default style character for points (default: "*")
  // left?: number;        // (reserved for future use)
}
```

#### Returns

A string representation of the scatter plot chart, which can be printed to the terminal.

#### Examples

##### Basic Scatter Plot

```ts
import { scatter } from "chartex";

const scatterData = [
  { key: "A", value: [1, 2], style: "*" },
  { key: "B", value: [2, 3], style: "*" },
  { key: "C", value: [3, 1], style: "*" }
];

const chart = scatter(scatterData, { width: 20, height: 10 });
console.log(chart);
// Outputs a grid-based scatter plot with the specified data and options
```

##### Custom Scatter Plot

```ts
import { scatter } from "chartex";

const performanceData = [
  { key: "Team A", value: [3, 4], style: "██" },
  { key: "Team B", value: [5, 6], style: "▓▓" },
  { key: "Team C", value: [2, 8], style: "▒▒" },
  { key: "Team D", value: [7, 5], style: "░░" }
];

const options = {
  width: 12,
  height: 8,
  style: "●"
};

console.log(scatter(performanceData, options));
```

### `sparkline`

Creates a compact, inline sparkline chart representing a series of numeric values as a sequence of Unicode bar characters. Sparklines are ideal for visualizing trends or patterns in small spaces, such as tables or dashboards.

#### Signature

```ts
sparkline(data: SparklineDatum[], opts?: SparklineOptions): string
```

#### Parameters

- `data` (SparklineDatum[]): An array of data points for the sparkline.
- `opts` (SparklineOptions, optional): Configuration options for customizing the sparkline appearance.

#### Types

```ts
interface SparklineDatum {
  key: string;           // The label for the sparkline point (optional, not used for rendering)
  value: number;         // The numeric value for the sparkline point
  style?: string;        // Optional custom style character for this point
}

interface SparklineOptions {
  width?: number;        // Width of the sparkline (default: data.length)
  height?: number;       // Height of the sparkline (default: 8)
  tolerance?: number;    // Tolerance for interpolation (default: 1)
  style?: string;        // Default style character for points (default: "*")
  yAxisChar?: string;    // Character for the y-axis (default: "|")
}
```

#### Returns

A string representation of the sparkline, which can be printed inline in the terminal.

#### Examples

##### Basic Sparkline

```ts
import { sparkline } from "chartex";

const trendData = [
  { value: 10 },
  { value: 20 },
  { value: 15 },
  { value: 30 },
  { value: 25 },
  { value: 35 },
  { value: 40 },
  { value: 30 },
  { value: 20 },
  { value: 25 }
];

console.log(sparkline(trendData));
```

##### Custom Sparkline with Styles

```ts
import { sparkline } from "chartex";

const customTrend = [
  { value: 10, style: "░" },
  { value: 20, style: "▒" },
  { value: 15, style: "▓" },
  { value: 30, style: "█" },
  { value: 25 },
  { value: 35 },
  { value: 40, style: "█" },
  { value: 30 },
  { value: 20 },
  { value: 25 }
];

const options = {
  width: 12,
  height: 6,
  style: "*",
  yAxisChar: "|"
};

console.log(sparkline(customTrend, options));
```
