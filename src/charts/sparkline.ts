import { type SparklineOptions, type SparklineDatum } from "../types/types.ts";
import { getShellWidth, getShellHeight } from "../utils/utils.ts";

/**
 * Generates a sparkline chart as a string using linear interpolation between points.
 * @param data - Array of SparklineDatum to plot
 * @param options - Configuration options for the sparkline
 * @param options.width - Width of the sparkline (default: 60% of terminal width)
 * @param options.height - Height of the sparkline (default: 30% of terminal height)
 * @param options.tolerance - Tolerance for point interpolation (default: 1)
 * @param options.style - Default style character for the sparkline (default: "*")
 * @param options.yAxisChar - Character for the y-axis (default: "|")
 * @returns Sparkline as a string
 * @example
 * ```typescript
 * const sparklineData = [
 *   { key: "A", value: 10, style: "*" },
 *   { key: "B", value: 20, style: "*" },
 *   { key: "C", value: 15, style: "*" },
 * ];
 * const chart = sparkline(sparklineData, { width: 30, height: 10, style: "#" });
 * console.log(chart);
 * // Outputs a sparkline chart with the specified data and options
 * ```
 */
const sparkline = (
  data: SparklineDatum[],
  options?: SparklineOptions
): string => {
  // Dynamically calculate width and height if not provided
  const shellWidth = getShellWidth();
  const shellHeight = getShellHeight();
  const width = options?.width ?? Math.max(data.length, Math.floor(shellWidth * 0.6));
  const height = options?.height ?? Math.max(8, Math.floor(shellHeight * 0.3));
  const tolerance = options?.tolerance ?? 1;
  const globalStyle = options?.style ?? "*";

  // Extract values and styles from data
  const values = data.map((d) => d.value);
  const styles = data.map((d) => d.style ?? globalStyle);

  // Normalize y-values to fit in height
  const min = Math.min(...values);
  const max = Math.max(...values);
  const scale = max === min ? 1 : (height - 1) / (max - min);
  const points = values.map((v, i) => ({
    x: Math.round((i / (values.length - 1)) * (width - 1)),
    y: height - 1 - Math.round((v - min) * scale),
    style: styles[i],
  }));

  // Fill grid with spaces
  const grid = Array.from({ length: height }, () => Array(width).fill(" "));

  // Helper: interpolate between two points
  const interpolate = (
    a: { x: number; y: number },
    b: { x: number; y: number }
  ) => {
    const dx = b.x - a.x;
    const dy = b.y - a.y;
    const steps = Math.max(Math.abs(dx), Math.abs(dy));
    return Array.from({ length: steps - 1 }, (_, i) => {
      const t = i + 1;
      const x = Math.round(a.x + (dx * t) / steps);
      const y = Math.round(a.y + (dy * t) / steps);
      return { x, y };
    });
  };

  // Plot points and interpolate
  for (let i = 0; i < points.length - 1; i++) {
    const a = points[i];
    const b = points[i + 1];
    grid[a.y][a.x] = a.style;
    const gap = Math.abs(b.x - a.x) + Math.abs(b.y - a.y);
    if (gap > tolerance) {
      const fillers = interpolate(a, b);
      fillers.forEach(({ x, y }) => {
        grid[y][x] = a.style;
      });
    }
  }
  // Plot last point
  const last = points.at(-1);
  if (last) grid[last.y][last.x] = last.style;

  // Dynamic decimal precision for y axis
  let yDecimals = 0;
  const yRange = Math.abs(max - min);
  if (yRange < 1) yDecimals = 2;
  else if (yRange < 10) yDecimals = 1;
  else yDecimals = 0;

  // Helper to remove unnecessary trailing zeros
  const formatY = (val: number, decimals: number): string => {
    let s = val.toFixed(decimals);
    if (decimals > 0) s = s.replace(/\.0+$/, '').replace(/(\.[1-9]*)0+$/, '$1');
    return s;
  };

  // Compute y axis width for alignment
  const yLabels = Array.from({ length: height }, (_, i) => {
    const yValue = max - i * (height > 1 ? (max - min) / (height - 1) : 1);
    return formatY(yValue, yDecimals);
  });
  const yAxisWidth = Math.max(...yLabels.map(l => l.length));
  const axisChar = options?.yAxisChar ?? "|";
  // const labelStep = height > 1 ? (max - min) / (height - 1) : 1;

  // Build lines with y-axis
  const lines = grid.map((row, i) => {
    const label = yLabels[i].padStart(yAxisWidth);
    return `${label} ${axisChar} ${row.join("")}`;
  });
  return lines.join("\n");
};

export default sparkline;
