# API Reference

This page documents the core functions and types of the chartex module, which you can use to plot in the terminal.

## Creational Chart Functions

### `bar`

Creates a vertical bar chart with bars representing data values. The chart displays bars vertically with values shown at the top and labels at the bottom.

#### Signature

```typescript
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

```typescript
import { bar } from "chartex";

const salesData = [
  { key: "Q1", value: 120 },
  { key: "Q2", value: 150 },
  { key: "Q3", value: 180 },
  { key: "Q4", value: 90 }
];

console.log(bar(salesData));
```

**Output:**

```ts
                  180
                  ***
        150       ***
        ***       ***
        ***       ***
 120    ***       ***
 ***    ***       ***    90
 ***    ***       ***    ***
 Q1     Q2        Q3     Q4
```

##### Custom Bar Chart with Options

```typescript
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

**Note:**

- The chart automatically scales bars proportionally to the maximum value in the dataset.
- Values are displayed at the top of each bar when space permits.
- Labels are shown at the bottom of each bar, truncated if they exceed the bar width.
- Individual bars can have custom styling by providing a style property in the data.
- The function validates input data and throws a TypeError for invalid data formats.

### `bullet`

### `donut`

### `gauge`

### `pie`

### `scatter`

## Data Transformation Functions

### `transformChartData`

### `transformCustomData`

### `transformObjectData`

### `transformScatterData`

### `transformSimpleData`
