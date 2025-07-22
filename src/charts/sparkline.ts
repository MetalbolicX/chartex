import { type SparklineOptions, type SparklineDatum } from "../types/types.ts";
import { getShellWidth, getShellHeight } from "../utils/utils.ts";

/**
 * Generates a sparkline chart as a string using linear interpolation between points.
 * @param data - Array of SparklineDatum to plot
 * @param options - Optional configuration (width, height, tolerance, style)
 * @returns Sparkline as a string
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

  // Prepare y-axis labels
  const yAxisWidth = Math.max(String(max).length, String(min).length);
  const axisChar = options?.yAxisChar ?? "|";
  const labelStep = height > 1 ? (max - min) / (height - 1) : 1;

  // Build lines with y-axis
  const lines = grid.map((row, i) => {
    const yValue = max - i * labelStep;
    const label = yValue.toFixed(1).padStart(yAxisWidth);
    return `${label} ${axisChar} ${row.join("")}`;
  });
  return lines.join("\n");
};

export default sparkline;
