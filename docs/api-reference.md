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

> [!Note]
> - The chart automatically scales the y-values to fit the specified height.
> - Each point can have a custom style character via the `style` property.
> - The y-axis is labeled with numeric values and uses the specified axis character.
> - The function supports linear interpolation between points for smoother lines.
> - The `key` property in `SparklineDatum` is optional and not used for rendering.

## Data Transformation Functions

### `transformChartData`

### `transformCustomData`

### `transformObjectData`

### `transformScatterData`

### `transformSimpleData`
