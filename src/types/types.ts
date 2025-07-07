type BackgroundColor =
  | "black"
  | "red"
  | "green"
  | "yellow"
  | "blue"
  | "magenta"
  | "cyan"
  | "white";

interface ChartDatum {
  key: string;
  value: number | [number, number]; // Allow both single numbers and arrays
}

interface BarChartOptions {
  barWidth?: number;
  left?: number;
  height?: number;
  padding?: number;
  style?: string;
}

interface BarChartDatum extends ChartDatum {
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

interface BulletChartDatum extends ChartDatum {
  value: number;
  style?: string;
  barWidth?: number;
}

interface PieChartOptions {
  radius?: number;
  left?: number;
  innerRadius?: number;
}

interface PieChartDatum extends ChartDatum {
  value: number;
  style: string; // Required for pie charts
}

interface GaugeChartOptions {
  radius?: number;
  left?: number;
  style?: string;
  bgStyle?: string;
}

interface GaugeChartDatum extends ChartDatum {
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

interface ScatterPlotDatum extends ChartDatum {
  value: [number, number]; // More specific: exactly 2 coordinates
  style?: string;
  sides?: [number, number];
}

export {
  type BackgroundColor,
  type ChartDatum,
  type BarChartOptions,
  type BarChartDatum,
  type BulletChartOptions,
  type BulletChartDatum,
  type PieChartOptions,
  type PieChartDatum,
  type GaugeChartOptions,
  type GaugeChartDatum,
  type ScatterPlotOptions,
  type ScatterPlotDatum,
}
