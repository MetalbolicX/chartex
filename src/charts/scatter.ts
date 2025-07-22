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

  // Prepare y-axis labels
  const yAxisWidth = Math.max(String(maxY).length, String(minY).length);
  const yAxisChar = "|";
  const yLabelStep = height > 1 ? (maxY - minY) / (height - 1) : 1;


  // Build lines with y-axis
  const lines = grid.map((row, i) => {
    const yValue = maxY - i * yLabelStep;
    const label = yValue.toFixed(0).padStart(yAxisWidth);
    return `${label} ${yAxisChar} ${row.join("")}`;
  });

  // Build x axis (continuous line of '_')
  const xAxisLine = "_".repeat(colCount);

  // Build x value labels spaced at their scaled columns
  const xLabelRowArr = Array(colCount).fill(" ");
  const uniqueX = Array.from(new Set(xVals));
  uniqueX.forEach((x) => {
    const col = xScale(x);
    xLabelRowArr[col] = String(x).padStart(0);
  });
  const xLabelRow = xLabelRowArr.join("");

  // Compose final output: grid, x axis, then x labels
  return `${lines.join("\n")}`
    + `\n${" ".repeat(yAxisWidth + 3)}${xAxisLine}`
    + `\n${" ".repeat(yAxisWidth + 3)}${xLabelRow}`;
};

export default scatter;
