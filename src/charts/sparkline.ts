import { type SparklineOptions } from "../types/types.ts";

/**
 * Generates a sparkline chart as a string using linear interpolation between points.
 * @param values - Array of y-values to plot
 * @param options - Optional configuration (width, height, tolerance, style)
 * @returns Sparkline as a string
 */
const sparkline = (
  values: number[],
  options?: SparklineOptions
): string => {
  const width = options?.width ?? values.length;
  const height = options?.height ?? 8;
  const tolerance = options?.tolerance ?? 1;
  const style = options?.style ?? "*";

  // Normalize y-values to fit in height
  const min = Math.min(...values);
  const max = Math.max(...values);
  const scale = max === min ? 1 : (height - 1) / (max - min);
  const points = values.map((v, i) => ({
    x: Math.round((i / (values.length - 1)) * (width - 1)),
    y: height - 1 - Math.round((v - min) * scale),
  }));

  // Fill grid with spaces
  const grid = Array.from({ length: height }, () => Array(width).fill(" "));

  // Helper: interpolate between two points
  const interpolate = (a: { x: number; y: number }, b: { x: number; y: number }) => {
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
    grid[a.y][a.x] = style;
    const gap = Math.abs(b.x - a.x) + Math.abs(b.y - a.y);
    if (gap > tolerance) {
      const fillers = interpolate(a, b);
      fillers.forEach(({ x, y }) => {
        grid[y][x] = style;
      });
    }
  }
  // Plot last point
  const last = points.at(-1);
  if (last) grid[last.y][last.x] = style;

  // Convert grid to string
  return grid.map(row => row.join("")).join("\n");
};

export default sparkline;
