"use strict";

import { PAD, verifyData, EOL } from "./utils.mjs";

/**
 * @typedef {Object} BulletChartOptions
 * @property {number} [barWidth=1] - Width of each bar
 * @property {string} [style="*"] - Default style character for bars
 * @property {number} [left=1] - Left offset position
 * @property {number} [width=10] - Width of the chart
 * @property {number} [padding=1] - Padding between bars
 */

/**
 * @typedef {Object} BulletChartDatum
 * @property {string} key - The key/label for the data point
 * @property {number} value - The numeric value for the bar
 * @property {string} [style] - Custom style character for this bar
 * @property {number} [barWidth] - Custom bar width for this specific bar
 */

/**
 * Creates a bullet chart with horizontal bars representing data values
 * @param {BulletChartDatum[]} data - The data array for the bullet chart
 * @param {BulletChartOptions} [opts] - Configuration options for the chart
 * @returns {string} The formatted bullet chart string
 */
const bullet = (data, opts) => {
  verifyData(data);

  const newOpts = {
    barWidth: 1,
    style: "*",
    left: 1,
    width: 10,
    padding: 1,
    ...opts
  };

  const {
    barWidth, left, width,
    padding, style
  } = newOpts;

  let result = PAD.repeat(left);

  const values = data.map(item => item.value);
  const max = Math.max(...values);
  const maxKeyLength = Math.max(...data.map(item => `${item.key} [${item.value}]`.length));

  // Generate bullet chart bars
  data.forEach((item, index) => {
    const ratioLength = Math.round(width * (item.value / max));
    const padChar = item.style || style;
    const { key } = item;
    const line = `${padChar.repeat(ratioLength)}${EOL}${PAD.repeat(left)}`;

    result += `${`${key} [${item.value}]`.padStart(maxKeyLength)}${PAD}`;

    // Generate multiple bar lines based on barWidth
    const currentBarWidth = item.barWidth || barWidth;
    for (let j = 0; j < currentBarWidth; j++) {
      result += j > 0
        ? `${PAD.repeat(maxKeyLength + 1)}${line}`
        : line;
    }

    // Add padding between items (except for the last item)
    if (index !== data.length - 1) {
      result += `${EOL.repeat(padding)}${PAD.repeat(left)}`;
    }
  });

  return result;
};

export default bullet;
