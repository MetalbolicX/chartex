/**
 * Background color options for terminal styling
 */
type BackgroundColor =
  | "black"
  | "red"
  | "green"
  | "yellow"
  | "blue"
  | "magenta"
  | "cyan"
  | "white";

/**
 * Chart data point structure
 */
interface ChartDatum {
  key: string;
  value: number | [number, number];
}

/**
 * Configuration options for bullet chart
 */
interface BulletChartOptions {
  /** Width of each bar */
  barWidth?: number;
  /** Default style character for bars */
  style?: string;
  /** Left offset position */
  left?: number;
  /** Width of the chart */
  width?: number;
  /** Padding between bars */
  padding?: number;
}

/**
 * Bullet chart data point structure
 */
interface BulletChartDatum extends Omit<ChartDatum, "value"> {
  /** The numeric value for the bar */
  value: number;
  /** Custom style character for this bar */
  style?: string;
  /** Custom bar width for this specific bar */
  barWidth?: number;
}

/**
 * Configuration options for bar chart
 */
interface BarChartOptions {
  /** Width of each bar */
  barWidth?: number;
  /** Left offset position */
  left?: number;
  /** Height of the chart */
  height?: number;
  /** Padding between bars */
  padding?: number;
  /** Default style character for bars */
  style?: string;
}

/**
 * Bar chart data point structure
 */
interface BarChartDatum extends Omit<ChartDatum, "value"> {
  /** The numeric value for the bar */
  value: number;
  /** Custom style character for this bar */
  style?: string;
}

/**
 * Configuration options for scatter plot
 */
/**
 * Configuration options for scatter plot (refactored for simplicity)
 */
interface ScatterPlotOptions {
  /** Width of the scatter plot */
  width?: number;
  /** Height of the scatter plot */
  height?: number;
  /** Default style character for data points */
  style?: string;
  /** Left offset position (for future use) */
  // left?: number;
}

/**
 * Scatter plot data point structure
 */
/**
 * Scatter plot data point structure (refactored)
 */
interface ScatterPlotDatum extends Omit<ChartDatum, "value"> {
  /** The x,y coordinates for the data point */
  value: [number, number];
  /** Custom style character for this data point */
  style?: string;
}

/**
 * Configuration options for gauge chart
 */
interface GaugeChartOptions {
  /** Radius of the gauge circle */
  radius?: number;
  /** Left offset position */
  left?: number;
  /** Default style character for filled gauge segments */
  style?: string;
  /** Style character for unfilled gauge segments */
  bgStyle?: string;
}

/**
 * Gauge chart data point structure
 */
interface GaugeChartDatum extends Omit<ChartDatum, "value"> {
  /** The numeric value for the gauge (0-1 range for percentage) */
  value: number;
  /** Custom style character for this gauge */
  style?: string;
}

/**
 * Configuration options for pie chart
 */
interface PieChartOptions {
  /** Radius of the pie chart */
  radius?: number;
  /** Left offset position */
  left?: number;
  /** Inner radius for donut charts */
  innerRadius?: number;
}

/**
 * Pie chart data point structure
 */
interface PieChartDatum extends Omit<ChartDatum, "value"> {
  /** The numeric value for the pie slice */
  value: number;
  /** Style character for this pie slice (required) */
  style: string;
}

/**
 * Configuration options for donut chart
 */
interface DonutChartOptions {
  /** Radius of the donut chart */
  radius?: number;
  /** Left offset position */
  left?: number;
  /** Inner radius for the donut hole */
  innerRadius?: number;
}

/**
 * Donut chart data point structure
 */
interface DonutChartDatum {
  /** The key/label for the data point */
  key: string;
  /** The numeric value for the donut slice */
  value: number;
  /** Style character for this donut slice (required) */
  style: string;
}

interface SparklineDatum extends Omit<ChartDatum, "value"> {
  /** The numeric value for the sparkline */
  value: number;
  /** Custom style character for this sparkline */
  style?: string;
}

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

export type {
  BackgroundColor,
  BarChartDatum,
  BarChartOptions,
  BulletChartDatum,
  BulletChartOptions,
  ChartDatum,
  DonutChartDatum,
  DonutChartOptions,
  GaugeChartDatum,
  GaugeChartOptions,
  PieChartDatum,
  PieChartOptions,
  ScatterPlotDatum,
  ScatterPlotOptions,
  SparklineDatum,
  SparklineOptions,
};
