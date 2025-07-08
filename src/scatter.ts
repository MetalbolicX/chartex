import {
  // bg,
  // centerTextInWidth,
  // fg,
  // getMaximumKeyLength,
  EOL,
  getOriginLen,
  curBack,
  curDown,
  curForward,
  curUp,
  PAD,
  verifyData,
} from "./utils/utils.ts";
import type { ScatterPlotOptions, ScatterPlotDatum } from "./types/types.ts";

type BoxType = "coordinate" | "data";

/**
 * Prints a box with specified dimensions and style.
 * @param width - The width of the box.
 * @param height - The height of the box.
 * @param style - The style string to fill the box with.
 * @param left - The left offset position.
 * @param top - The top offset position.
 * @param type - The type of box (coordinate or data).
 * @returns The formatted box string.
 */
const printBox = (
  width: number,
  height: number,
  style: string = "# ",
  left: number = 0,
  top: number = 0,
  type: BoxType = "coordinate"
): string => {
  let result = curForward(left) + curUp(top);
  const hasSide = width > 1 || height > 1;

  for (let i = 0; i < height; i++) {
    for (let j = 0; j < width; j++) {
      result += style;
    }

    if (hasSide) {
      if (i !== height - 1) {
        result += EOL + curForward(left);
      } else {
        result += EOL;
      }
    }
  }

  if (type === "data") {
    result += curDown(hasSide ? (top - height) : top) +
              curBack(left + getOriginLen(style));
  }

  return result;
};

/**
 * Creates a legend string from the data items.
 * @param data - Array of scatter plot data items.
 * @param defaultStyle - Default style to use if item doesn't have one.
 * @returns The formatted legend string.
 */
const createLegend = (data: ScatterPlotDatum[], defaultStyle: string): string => {
  const keys = new Set(data.map(item => item.key));

  return Array.from(keys)
    .map(key => {
      const item = data.find(dataItem => dataItem.key === key);
      const style = item?.style || defaultStyle;
      return `${key}: ${style}`;
    })
    .join(" | ");
};

/**
 * Draws the vertical axis with scale markers.
 * @param height - The height of the chart.
 * @param left - The left padding.
 * @param vAxis - The vertical axis configuration.
 * @param vGap - The vertical gap between scale markers.
 * @param ratio - The ratio for scaling values.
 * @returns The formatted vertical axis string.
 */
const drawVerticalAxis = (
  height: number,
  left: number,
  vAxis: [string, string],
  vGap: number,
  ratio: [number, number]
): string => {
  let result = PAD.repeat(left + 1) + vAxis[1];

  for (let i = 0; i < height + 1; i++) {
    const scaleValue = ((height - i) % vGap === 0 && i !== height)
      ? ((height - i) * ratio[1]).toString()
      : "";

    result += EOL + scaleValue.padStart(left + 1) + vAxis[0];
  }

  return result;
};

/**
 * Draws the horizontal axis with scale markers.
 * @param width - The width of the chart.
 * @param hAxis - The horizontal axis configuration.
 * @param hGap - The horizontal gap between scale markers.
 * @param ratio - The ratio for scaling values.
 * @param hName - The name of the horizontal axis.
 * @returns The formatted horizontal axis string.
 */
const drawHorizontalAxis = (
  width: number,
  hAxis: [string, string, string],
  hGap: number,
  ratio: [number, number],
  hName: string
): string => {
  let result = "";

  for (let i = 1; i < (width * 2) + hGap; i++) {
    if (!(i % (hGap * 2))) {
      result += hAxis[0];

      // Draw scale of horizontal axis
      const item = (i / 2) * ratio[0];
      const len = item.toString().length;

      result += curDown(1) + curBack(1) + item + curUp(1);
      if (len > 1) {
        result += curBack(len - 1);
      }

      continue;
    }

    result += hAxis[1];
  }

  result += hAxis[2] + PAD + hName + EOL;
  return result;
};

/**
 * Renders data points on the scatter plot.
 * @param data - Array of scatter plot data items.
 * @param defaultStyle - Default style to use if item doesn't have one.
 * @param defaultSides - Default sides to use if item doesn't have them.
 * @param left - The left padding.
 * @returns The formatted data points string.
 */
const renderDataPoints = (
  data: ScatterPlotDatum[],
  defaultStyle: string,
  defaultSides: [number, number],
  left: number
): string => {
  return data
    .map(item => {
      const style = item.style || defaultStyle;
      const sides = item.sides || defaultSides;

      return printBox(
        sides[0],
        sides[1],
        style,
        item.value[0] * 2 + left + 1,
        item.value[1],
        "data"
      );
    })
    .join("");
};

/**
 * Creates a scatter plot chart from the provided data.
 * @param data - Array of scatter plot data items.
 * @param options - Configuration options for the scatter plot.
 * @returns The formatted scatter plot string.
 * @throws TypeError if data is invalid.
 */
const renderScatterPlot = (
  data: ScatterPlotDatum[],
  options: ScatterPlotOptions = {}
): string => {
  verifyData(data);
  const {
    width = 10,
    left = 2,
    height = 10,
    style = "# ",
    sides = [1, 1],
    hAxis = ["+", "-", ">"],
    vAxis = ["|", "A"],
    hName = "X Axis",
    vName = "Y Axis",
    zero = "+",
    ratio = [1, 1],
    hGap = 2,
    vGap = 2,
    legendGap = 0,
  } = options;

  let result = "";

  // Add vertical axis name and legend
  result += PAD.repeat(left) + vName;
  result += PAD.repeat(legendGap);
  result += createLegend(data, style) + EOL.repeat(2);

  // Draw coordinate box
  result += printBox(width + left, height + 1, PAD.repeat(2));

  // Render data points
  result += renderDataPoints(data, style, sides, left);

  // Draw vertical axis
  result += curBack(width * 2) + curUp(height + 1);
  result += drawVerticalAxis(height, left, vAxis, vGap, ratio);

  // Draw origin point
  result += curBack() + zero + curDown(1) +
            curBack(1) + "0" + curUp(1);

  // Draw horizontal axis
  result += drawHorizontalAxis(width, hAxis, hGap, ratio, hName);

  return result;
};

export { renderScatterPlot };
