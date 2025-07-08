"use strict";

import pie from "./pie.mjs";

/**
 * Creates a donut chart by calling the pie function with donut flag enabled
 * @param {Array} data - The data array for the donut chart
 * @param {Object} opts - Configuration options for the chart
 * @returns {string} The formatted donut chart string
 */
const donut = (data, opts) => pie(data, opts, true);

export default donut;
