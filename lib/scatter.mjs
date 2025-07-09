"use strict";

import {
  EOL,
  PAD,
  verifyData,
  curForward,
  curUp,
  curDown,
  curBack,
  getOriginLen
} from "./utils.mjs";

/**
 * @typedef {Object} ScatterPlotOptions
 * @property {number} [width=10] - Width of the scatter plot
 * @property {number} [left=2] - Left offset position
 * @property {number} [height=10] - Height of the scatter plot
 * @property {string} [style="# "] - Default style character for data points
 * @property {[number, number]} [sides=[1, 1]] - Default size of data points [width, height]
 * @property {[string, string, string]} [hAxis=["+", "-", ">"]] - Horizontal axis characters [mark, line, arrow]
 * @property {[string, string]} [vAxis=["|", "A"]] - Vertical axis characters [line, arrow]
 * @property {string} [hName="X Axis"] - Horizontal axis name
 * @property {string} [vName="Y Axis"] - Vertical axis name
 * @property {string} [zero="+"] - Character for origin point
 * @property {[number, number]} [ratio=[1, 1]] - Scale ratio for [x, y] axes
 * @property {number} [hGap=2] - Gap between horizontal axis marks
 * @property {number} [vGap=2] - Gap between vertical axis marks
 * @property {number} [legendGap=0] - Gap between axis name and legend
 */

/**
 * @typedef {Object} ScatterPlotDatum
 * @property {string} key - The key/label for the data point
 * @property {[number, number]} value - The x,y coordinates for the data point
 * @property {string} [style] - Custom style character for this data point
 * @property {[number, number]} [sides] - Custom size for this data point [width, height]
 */

/**
 * Prints a box with specified dimensions and style
 * @param {number} width - The width of the box
 * @param {number} height - The height of the box
 * @param {string} style - The style character for the box
 * @param {number} left - Left offset position
 * @param {number} top - Top offset position
 * @param {"coordinate" | "data"} type - Type of box
 * @returns {string} The formatted box string
 */
const printBox = (width, height, style = "# ", left = 0, top = 0, type = "coordinate") => {
  let result = `${curForward(left)}${curUp(top)}`;
  const hasSide = width > 1 || height > 1;

  for (let i = 0; i < height; i++) {
    for (let j = 0; j < width; j++) {
      result += style;
    }

    if (hasSide) {
      result += i !== height - 1
        ? `${EOL}${curForward(left)}`
        : EOL;
    }
  }

  if (type === "data") {
    result += `${curDown(hasSide ? (top - height) : top)}${curBack(left + getOriginLen(style))}`;
  }
  return result;
};

/**
 * Creates a scatter plot chart
 * @param {ScatterPlotDatum[]} data - The data array for the scatter plot
 * @param {ScatterPlotOptions} [opts] - Configuration options for the chart
 * @returns {string} The formatted scatter plot string
 */
const scatter = (data, opts) => {
  verifyData(data);

  const newOpts = {
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
    ...opts
  };

  const {
    left, height, style, sides, width, zero, hAxis, vAxis, ratio,
    hName, vName, hGap, vGap, legendGap
  } = newOpts;

  let tmp;
  let result = "";

  const styles = data.map(item => item.style || style);
  const allSides = data.map(item => item.sides || sides);
  const keys = new Set(data.map(item => item.key));

  // Build legend
  result += `${PAD.repeat(left)}${vName}`;
  result += PAD.repeat(legendGap);
  result += `${Array.from(keys)
    .map(key => `${key}: ${data.find(item => item.key === key).style || style}`)
    .join(" | ")}${EOL.repeat(2)}`;

  // Print coordinate box
  result += printBox(width + left, height + 1, PAD.repeat(2));

  // Plot data points
  data.map((item, index) => {
    result += printBox(
      allSides[index][0],
      allSides[index][1],
      styles[index],
      item.value[0] * 2 + left + 1,
      item.value[1],
      "data"
    );
  });

  // Draw vertical axis
  result += `${curBack(width * 2)}${curUp(height + 1)}${PAD.repeat(left + 1)}${vAxis[1]}`;

  // Draw vertical scale
  for (let i = 0; i < height + 1; i++) {
    tmp = ((height - i) % vGap === 0 && i !== height)
      ? ((height - i) * ratio[1]).toString()
      : "";
    result += `${EOL}${tmp.padStart(left + 1)}${vAxis[0]}`;
  }

  // Draw origin and horizontal axis
  result += `${curBack()}${zero}${curDown(1)}${curBack(1)}0${curUp(1)}`;

  // Draw horizontal scale
  for (let i = 1; i < (width * 2) + hGap; i++) {
    if (!(i % (hGap * 2))) {
      result += hAxis[0];

      // Draw scale of horizontal axis
      const item = (i / 2) * ratio[0];
      const len = item.toString().length;

      result += `${curDown(1)}${curBack(1)}${item}${curUp(1)}`;
      if (len > 1) {
        result += curBack(len - 1);
      }

      continue;
    }

    result += hAxis[1];
  }

  result += `${hAxis[2]}${PAD}${hName}${EOL}`;

  return result;
};

export default scatter;
