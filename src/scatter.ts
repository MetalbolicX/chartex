import {
  EOL,
  PADDING_CHARACTER,
  validateChartData,
  moveCursorForward,
  moveCursorUp,
  moveCursorDown,
  moveCursorBackward,
  getOriginalTextLength,
} from "./utils/utils.ts";

import type { ScatterPlotDatum, ScatterPlotOptions } from "./types/types.ts";

type BoxType = "coordinate" | "data";

/**
 * Creates a scatter plot visualization from the provided coordinate data.
 * @param data - Array of scatter plot data items with coordinate pairs.
 * @param options - Configuration options for the scatter plot appearance.
 * @returns A string representation of the scatter plot.
 * @throws TypeError if data is invalid.
 * @example
 * ```typescript
 * import { renderScatterPlot } from "chartex";
 * const data = [
 *  { key: "A", value: [1, 2], style: "#" },
 *  { key: "B", value: [3, 4], style: "*" },
 *  { key: "C", value: [5, 6], style: "+" },
 * ];
 * const options = { width: 10, height: 10, left: 2, style: "# " };
 * const chart = renderScatterPlot(data, options);
 * console.log(chart);
 * ```
 */
const renderScatterPlot = (
  data: ScatterPlotDatum[],
  options?: ScatterPlotOptions
): string => {
  validateChartData(data);

  const plotOptions: Required<ScatterPlotOptions> = {
    width: 10,
    left: 2,
    height: 10,
    style: "# ",
    sides: [1, 1],
    hAxis: ["+", "-", ">"],
    vAxis: ["|", "A"],
    hName: "X Axis",
    vName: "Y Axis",
    zero: "+",
    ratio: [1, 1],
    hGap: 2,
    vGap: 2,
    legendGap: 0,
    ...options,
  };

  const {
    left,
    height,
    style,
    sides,
    width,
    zero,
    hAxis,
    vAxis,
    ratio,
    hName,
    vName,
    hGap,
    vGap,
    legendGap,
  } = plotOptions;

  let result = "";

  // Generate legend
  result += generateLegend(data, style, left, vName, legendGap);

  // Create coordinate system background
  result += createCoordinateBox(width + left, height + 1);

  // Plot data points
  result += plotDataPoints(data, style, sides, left);

  // Draw vertical axis
  result += drawVerticalAxis(width, height, left, vAxis, vGap, ratio, zero);

  // Draw horizontal axis
  result += drawHorizontalAxis(width, height, hAxis, hGap, ratio, hName);

  return result;
};

/**
 * Generates the legend section for the scatter plot.
 * @param data - Array of scatter plot data items.
 * @param defaultStyle - Default style character.
 * @param left - Left padding amount.
 * @param vName - Vertical axis name.
 * @param legendGap - Gap between legend items.
 * @returns Formatted legend string.
 */
const generateLegend = (
  data: ScatterPlotDatum[],
  defaultStyle: string,
  left: number,
  vName: string,
  legendGap: number
): string => {
  const uniqueKeys = new Set(data.map((item) => item.key));
  const legendItems = Array.from(uniqueKeys).map((key) => {
    const item = data.find((dataItem) => dataItem.key === key);
    return `${key}: ${item?.style || defaultStyle}`;
  });

  return `${PADDING_CHARACTER.repeat(left)}${vName}${PADDING_CHARACTER.repeat(
    legendGap
  )}${legendItems.join(" | ")}${EOL.repeat(2)}`;
};

/**
 * Creates a box for drawing charts with specified dimensions and style.
 * @param width - The width of the box.
 * @param height - The height of the box.
 * @param style - The style character to use for drawing.
 * @param left - Left offset position.
 * @param top - Top offset position.
 * @param type - The type of box being created.
 * @returns Formatted box string with cursor positioning.
 */
const createBox = (
  width: number,
  height: number,
  style: string = "# ",
  left: number = 0,
  top: number = 0,
  type: BoxType = "coordinate"
): string => {
  let result = moveCursorForward(left) + moveCursorUp(top);
  const hasSides = width > 1 || height > 1;

  for (let rowIndex = 0; rowIndex < height; rowIndex++) {
    for (let columnIndex = 0; columnIndex < width; columnIndex++) {
      result += style;
    }

    if (hasSides) {
      if (rowIndex !== height - 1) {
        result += `${EOL}${moveCursorForward(left)}`;
      } else {
        result += EOL;
      }
    }
  }

  if (type === "data") {
    result += `${moveCursorDown(
      hasSides ? top - height : top
    )}${moveCursorBackward(left + getOriginalTextLength(style))}`;
  }

  return result;
};

/**
 * Creates the coordinate system background box.
 * @param width - The width of the coordinate system.
 * @param height - The height of the coordinate system.
 * @returns Formatted coordinate box string.
 */
const createCoordinateBox = (width: number, height: number): string =>
  createBox(width, height, PADDING_CHARACTER.repeat(2));

/**
 * Plots all data points on the scatter plot.
 * @param data - Array of scatter plot data items.
 * @param defaultStyle - Default style character.
 * @param defaultSides - Default dimensions for data points.
 * @param left - Left padding amount.
 * @returns Formatted data points string.
 */
const plotDataPoints = (
  data: ScatterPlotDatum[],
  defaultStyle: string,
  defaultSides: [number, number],
  left: number
): string => {
  const styles = data.map((item) => item.style || defaultStyle);
  const allSides = data.map((item) => item.sides || defaultSides);

  return data
    .map((item, index) => {
      const [x, y] = item.value;
      const [width, height] = allSides[index];
      const style = styles[index];

      return createBox(width, height, style, x * 2 + left + 1, y, "data");
    })
    .join("");
};

/**
 * Draws the vertical axis with labels and scale markers.
 * @param width - The width of the plot area.
 * @param height - The height of the plot area.
 * @param left - Left padding amount.
 * @param vAxis - Vertical axis characters [line, arrow].
 * @param vGap - Vertical gap between scale markers.
 * @param ratio - Scale ratio [horizontal, vertical].
 * @param zero - Zero point character.
 * @returns Formatted vertical axis string.
 */
const drawVerticalAxis = (
  width: number,
  height: number,
  left: number,
  vAxis: [string, string],
  vGap: number,
  ratio: [number, number],
  zero: string
): string => {
  const [vLine, vArrow] = vAxis;
  const [, vRatio] = ratio;

  let result = `${moveCursorBackward(width * 2)}${moveCursorUp(
    height + 1
  )}${PADDING_CHARACTER.repeat(left + 1)}${vArrow}`;

  for (let i = 0; i < height + 1; i++) {
    const scaleValue =
      (height - i) % vGap === 0 && i !== height
        ? ((height - i) * vRatio).toString()
        : "";

    result += `${EOL}${scaleValue.padStart(left + 1)}${vLine}`;
  }

  result += `${moveCursorBackward()}${zero}${moveCursorDown(
    1
  )}${moveCursorBackward(1)}0${moveCursorUp(1)}`;

  return result;
};

/**
 * Draws the horizontal axis with labels and scale markers.
 * @param width - The width of the plot area.
 * @param height - The height of the plot area.
 * @param hAxis - Horizontal axis characters [plus, minus, arrow].
 * @param hGap - Horizontal gap between scale markers.
 * @param ratio - Scale ratio [horizontal, vertical].
 * @param hName - Horizontal axis name.
 * @returns Formatted horizontal axis string.
 */
const drawHorizontalAxis = (
  width: number,
  _height: number,
  hAxis: [string, string, string],
  hGap: number,
  ratio: [number, number],
  hName: string
): string => {
  const [hPlus, hMinus, hArrow] = hAxis;
  const [hRatio] = ratio;

  let result = "";

  for (let i = 1; i < width * 2 + hGap; i++) {
    if (!(i % (hGap * 2))) {
      result += hPlus;

      // Draw scale markers for horizontal axis
      const scaleValue = (i / 2) * hRatio;
      const valueLength = scaleValue.toString().length;

      result += `${moveCursorDown(1)}${moveCursorBackward(
        1
      )}${scaleValue}${moveCursorUp(1)}`;

      if (valueLength > 1) {
        result += moveCursorBackward(valueLength - 1);
      }

      continue;
    }

    result += hMinus;
  }

  result += `${hArrow}${PADDING_CHARACTER}${hName}${EOL}`;

  return result;
};

export { renderScatterPlot };
