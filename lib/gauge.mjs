"use strict";

import { padMid, verifyData, PAD, EOL } from "./utils.mjs";

/**
 * @typedef {Object} GaugeChartOptions
 * @property {number} [radius=5] - Radius of the gauge circle
 * @property {number} [left=2] - Left offset position
 * @property {string} [style="# "] - Default style character for filled gauge segments
 * @property {string} [bgStyle="+ "] - Style character for unfilled gauge segments
 */

/**
 * @typedef {Object} GaugeChartDatum
 * @property {string} key - The key/label for the gauge
 * @property {number} value - The numeric value for the gauge (0-1 range for percentage)
 * @property {string} [style] - Custom style character for this gauge
 */

/**
 * Creates a gauge chart to display a single value as a semi-circular meter
 * @param {GaugeChartDatum[]} data - The data array containing one item with key and value
 * @param {GaugeChartOptions} [opts] - Configuration options for the gauge
 * @returns {string} The formatted gauge chart string
 */
const gauge = (data, opts) => {
  verifyData(data);

  const newOpts = {
    radius: 5,
    left: 2,
    style: "# ",
    bgStyle: "+ ",
    ...opts
  };

  const { radius, left, style, bgStyle } = newOpts;
  const [firstDataItem] = data;

  let result = PAD.repeat(left);

  // Generate the semi-circular gauge
  for (let i = -radius; i < 0; i++) {
    for (let j = -radius; j < radius; j++) {
      const isWithinCircle = Math.pow(i, 2) + Math.pow(j, 2) < Math.pow(radius, 2);

      if (isWithinCircle) {
        const isOuterRing = Math.abs(i) > 2 || Math.abs(j) > 2;

        if (isOuterRing) {
          const tmp = Math.atan2(i, j) * 1 / Math.PI + 1;
          result += tmp <= firstDataItem.value
            ? (firstDataItem.style || style)
            : bgStyle;
        } else {
          // Display percentage value at the center
          if (j === 0 && i === -1) {
            result += Math.round(firstDataItem.value * 100);
            continue;
          }

          result += PAD.repeat(2);
        }
      } else {
        result += PAD.repeat(2);
      }
    }

    result += `${EOL}${PAD.repeat(left)}`;
  }

  // Add the scale labels and key
  result += `${PAD.repeat(radius - 2)}0${PAD.repeat(radius - 4)}${padMid(firstDataItem.key, 11)}${PAD.repeat(radius - 4)}100`;

  return result;
};

export default gauge;
