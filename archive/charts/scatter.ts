import { getShellWidth, getShellHeight, verifyData } from "../utils/utils.ts";
import type { ScatterPlotDatum, ScatterPlotOptions } from "../types/types.ts";

/**
 * Creates a scatter plot chart (grid-based, sparkline style)
 * @param data - The data array for the scatter plot
 * @param options - Configuration options for the chart
 * @param options.width - Width of the chart (default: 60% of terminal width)
 * @param options.height - Height of the chart (default: 30% of terminal height)
 * @param options.style - Default style for points (default: "*")
 * @returns The formatted scatter plot string
 * @example
 * ```typescript
 * const scatterData = [
 *   { key: "A", value: [1, 2], style: "*" },
 *   { key: "B", value: [2, 3], style: "*" },
 *   { key: "C", value: [3, 1], style: "*" },
 * ];
 * const chart = scatter(scatterData, { width: 20, height: 10 });
 * console.log(chart);
 * // Outputs a grid-based scatter plot with the specified data and options
 * ```
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


  // d3-style linear scale for x
  const minX = Math.min(...xVals);
  const maxX = Math.max(...xVals);
  const colCount = width;
  const xScale = maxX === minX ? () => 0 : (x: number) => Math.round((x - minX) / (maxX - minX) * (colCount - 1));

  // y scaling as before
  const minY = Math.min(...yVals);
  const maxY = Math.max(...yVals);
  const yScale = maxY === minY ? 1 : (height - 1) / (maxY - minY);

  // Map data points to grid positions
  const points = data.map((d, i) => ({
    x: xScale(d.value[0]),
    y: height - 1 - Math.round((d.value[1] - minY) * yScale),
    style: styles[i],
    xVal: d.value[0],
  }));

  // Build grid
  const grid = Array.from({ length: height }, () => Array(colCount).fill(" "));
  points.forEach(({ x, y, style }) => {
    if (grid[y] && grid[y][x]) grid[y][x] = style;
  });


  // Dynamic decimal precision for y axis
  let yDecimals = 0;
  const yRange = Math.abs(maxY - minY);
  if (yRange < 1) yDecimals = 2;
  else if (yRange < 10) yDecimals = 1;
  else yDecimals = 0;

  // Helper to remove unnecessary trailing zeros
  const formatY = (val: number, decimals: number) => {
    let s = val.toFixed(decimals);
    if (decimals > 0) s = s.replace(/\.0+$/, '').replace(/(\.[1-9]*)0+$/, '$1');
    return s;
  };

  // Compute y axis width for alignment
  const yLabels = Array.from({ length: height }, (_, i) => {
    const yValue = maxY - i * (height > 1 ? (maxY - minY) / (height - 1) : 1);
    return formatY(yValue, yDecimals);
  });
  const yAxisWidth = Math.max(...yLabels.map(l => l.length));
  const yAxisChar = "|";
  // const yLabelStep = height > 1 ? (maxY - minY) / (height - 1) : 1;

  // Build lines with y-axis
  const lines = grid.map((row, i) => {
    const label = yLabels[i].padStart(yAxisWidth);
    return `${label} ${yAxisChar} ${row.join("")}`;
  });

  // Build x axis (continuous line of '_')
  const xAxisLine = "_".repeat(colCount);

  // Build x value labels: min at left, mid at center, max at right
  const xLabelList = Array(colCount).fill(" ");
  const minLabel = String(minX);
  const maxLabel = String(maxX);
  const midX = minX + (maxX - minX) / 2;
  const midLabel = String(Number.isInteger(midX) ? midX : midX.toFixed(1));
  // Place min at col 0, max at last col, mid at center
  xLabelList[0] = minLabel;
  xLabelList[Math.floor(colCount / 2) - Math.floor(midLabel.length / 2)] = midLabel;
  xLabelList[colCount - maxLabel.length] = maxLabel;
  const xLabelRow = xLabelList.join("");

  // Compose final output: grid, x axis, then x labels
  return `${lines.join("\n")}`
    + `\n${" ".repeat(yAxisWidth + 3)}${xAxisLine}`
    + `\n${" ".repeat(yAxisWidth + 3)}${xLabelRow}`;
};

export default scatter;
