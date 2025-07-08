"use strict";

import { PAD, verifyData, maxKeyLen, EOL } from "./utils.mjs";

/**
 * Creates a bullet chart with horizontal bars representing data values
 * @param {Array} data - The data array for the bullet chart
 * @param {Object} opts - Configuration options for the chart
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
