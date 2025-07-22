import { getShellWidth, getShellHeight, verifyData } from "../utils/utils.ts";
import type { ScatterPlotDatum, ScatterPlotOptions } from "../types/types.ts";


/**
 * Creates a scatter plot chart (grid-based, sparkline style)
 * @param data - The data array for the scatter plot
 * @param options - Configuration options for the chart
 * @returns The formatted scatter plot string
 */
const scatter = (
  data: ScatterPlotDatum[],
  options?: ScatterPlotOptions
): string => {
  verifyData(data);

  // Dynamically calculate width and height if not provided
  const shellWidth = getShellWidth();
  const shellHeight = getShellHeight();
  const width = options?.width ?? Math.max(10, Math.floor(shellWidth * 0.6));
  const height = options?.height ?? Math.max(8, Math.floor(shellHeight * 0.3));
  const style = options?.style ?? "*";

  // Extract x and y values
  const xVals = data.map((d) => d.value[0]);
  const yVals = data.map((d) => d.value[1]);
  const styles = data.map((d) => d.style ?? style);

  // Normalize x and y to grid
  const minX = Math.min(...xVals);
  const maxX = Math.max(...xVals);
  const minY = Math.min(...yVals);
  const maxY = Math.max(...yVals);
  const xScale = maxX === minX ? 1 : (width - 1) / (maxX - minX);
  const yScale = maxY === minY ? 1 : (height - 1) / (maxY - minY);

  // Map data points to grid positions
  const points = data.map((d, i) => ({
    x: Math.round((d.value[0] - minX) * xScale),
    y: height - 1 - Math.round((d.value[1] - minY) * yScale),
    style: styles[i],
  }));

  // Build grid
  const grid = Array.from({ length: height }, () => Array(width).fill(" "));
  points.forEach(({ x, y, style }) => {
    if (grid[y] && grid[y][x]) grid[y][x] = style;
  });

  // Prepare y-axis labels
  const yAxisWidth = Math.max(String(maxY).length, String(minY).length);
  const yAxisChar = "|";
  const yLabelStep = height > 1 ? (maxY - minY) / (height - 1) : 1;

  // Prepare x-axis labels (top)
  const xLabelStep = width > 1 ? (maxX - minX) / (width - 1) : 1;
  const xLabels = Array.from({ length: width }, (_, i) =>
    (minX + i * xLabelStep).toFixed(1)
  );
  // Only show every Nth label for readability
  const xLabelEvery = Math.ceil(width / 8);
  const xLabelRow = xLabels
    .map((lbl, i) => (i % xLabelEvery === 0 ? lbl.padStart(4) : "    "))
    .join("");
  const xSepRow = Array.from({ length: width }, () => "____").join("");

  // Build lines with y-axis
  const lines = grid.map((row, i) => {
    const yValue = maxY - i * yLabelStep;
    const label = yValue.toFixed(1).padStart(yAxisWidth);
    return `${label} ${yAxisChar} ${row.join("")}`;
  });

  // Compose final output: x labels, separator, then grid
  return `${" ".repeat(yAxisWidth + 3)}${xLabelRow}\n${" ".repeat(yAxisWidth + 3)}${xSepRow}\n${lines.join("\n")}`;
};

export default scatter;
