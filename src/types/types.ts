type BackgroundColor =
  | "black"
  | "red"
  | "green"
  | "yellow"
  | "blue"
  | "magenta"
  | "cyan"
  | "white";

interface ChartDataItem {
  key: string;
  value: number | number[]; // Allow both single numbers and arrays
}

interface BarChartOptions {
  barWidth?: number;
  left?: number;
  height?: number;
  padding?: number;
  style?: string;
}

interface BarChartDataItem extends ChartDataItem {
  value: number; // Override to use single numeric values
  style?: string;
}

interface BulletChartOptions {
  barWidth?: number;
  style?: string;
  left?: number;
  width?: number;
  padding?: number;
}

interface BulletDataItem extends ChartDataItem {
  value: number;
  style?: string;
  barWidth?: number;
}

interface PieChartOptions {
  radius?: number;
  left?: number;
  innerRadius?: number;
}

interface PieDataItem extends ChartDataItem {
  value: number;
  style: string; // Required for pie charts
}

interface GaugeChartOptions {
  radius?: number;
  left?: number;
  style?: string;
  bgStyle?: string;
}

interface GaugeDataItem extends ChartDataItem {
  value: number; // Override to use single numeric values (0-1 range for percentage)
  style?: string;
}

interface ScatterPlotOptions {
  width?: number;
  left?: number;
  height?: number;
  style?: string;
  sides?: [number, number];
  hAxis?: [string, string, string];
  vAxis?: [string, string];
  hName?: string;
  vName?: string;
  zero?: string;
  ratio?: [number, number];
  hGap?: number;
  vGap?: number;
  legendGap?: number;
}

interface ScatterDataItem extends ChartDataItem {
  value: [number, number]; // More specific: exactly 2 coordinates
  style?: string;
  sides?: [number, number];
}

export {
  type BackgroundColor,
  type ChartDataItem,
  type BarChartOptions,
  type BarChartDataItem,
  type BulletChartOptions,
  type BulletDataItem,
  type PieChartOptions,
  type PieDataItem,
  type GaugeChartOptions,
  type GaugeDataItem,
  type ScatterPlotOptions,
  type ScatterDataItem,
}
