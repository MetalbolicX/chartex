"use strict";

import pie from "./pie.mjs";

/**
 * @typedef {Object} DonutChartOptions
 * @property {number} [radius=4] - Radius of the donut chart
 * @property {number} [left=0] - Left offset position
 * @property {number} [innerRadius=1] - Inner radius for the donut hole
 */

/**
 * @typedef {Object} DonutChartDatum
 * @property {string} key - The key/label for the data point
 * @property {number} value - The numeric value for the donut slice
 * @property {string} style - Style character for this donut slice (required)
 */

/**
 * Creates a donut chart by calling the pie function with donut flag enabled
 * @param {DonutChartDatum[]} data - The data array for the donut chart
 * @param {DonutChartOptions} [opts] - Configuration options for the chart
 * @returns {string} The formatted donut chart string
 */
const donut = (data, opts) => pie(data, opts, true);

export default donut;
