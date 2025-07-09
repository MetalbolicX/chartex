"use strict";

import { EOL } from "node:os";

/**
 * Padding character used throughout the utility functions
 * @type {string}
 */
const PAD = " ";

/**
 * @typedef {'black'|'red'|'green'|'yellow'|'blue'|'magenta'|'cyan'|'white'} BackgroundColor
 */

/**
 * Background color codes for terminal styling
 * @type {Record<BackgroundColor, string>}
 */
const bgColors = {
  black: "40",
  red: "41",
  green: "42",
  yellow: "43",
  blue: "44",
  magenta: "45",
  cyan: "46",
  white: "47",
};

/**
 * @typedef {Object} ChartDatum
 * @property {string} key - The key/label for the data point
 * @property {number|[number, number]} value - The value(s) for the data point
 */

/**
 * Creates a background colored block
 * @param {BackgroundColor} [color="cyan"] - The background color name
 * @param {number} [length=1] - The length of the colored block
 * @returns {string} The ANSI colored string
 */
const bg = (color = "cyan", length = 1) => {
  const currentBg = bgColors[color];
  if (typeof color !== "string" || !currentBg) {
    throw new TypeError(`Invalid backgroundColor: ${JSON.stringify(color)}`);
  }

  return `\x1b[${currentBg}m${PAD.repeat(length)}\x1b[0m`;
};

/**
 * Creates a foreground colored text
 * @param {BackgroundColor} [color="cyan"] - The foreground color name
 * @param {string} str - The string to color
 * @returns {string} The ANSI colored string
 */
const fg = (color = "cyan", str) => {
  const currentBg = bgColors[color];
  if (typeof color !== "string" || !currentBg) {
    throw new TypeError(`Invalid foregroundColor: ${JSON.stringify(color)}`);
  }

  return `\x1b[${parseInt(bgColors[color] - 10)}m${str}\x1b[0m`;
};

/**
 * Pads a string to center it within a given width
 * @param {string} str - The string to pad
 * @param {number} width - The target width
 * @returns {string} The padded string
 */
const padMid = (str, width) => {
  const mid = Math.round((width - str.length) / 2);
  const length = str.length;

  return length > width
    ? str.padEnd(width)
    : `${PAD.repeat(mid)}${str}${PAD.repeat(
        mid + (mid * 2 + length > width ? -1 : 0)
      )}`;
};

/**
 * Verifies that data is in the correct format for charts
 * @param {ChartDatum[]} data - The data array to verify
 * @throws {TypeError} If data format is invalid
 */
const verifyData = (data) => {
  const { length } = data;

  if (!Array.isArray(data) || length === 0) {
    throw new TypeError(`Invalid data: ${JSON.stringify(data)}`);
  }

  const isValidItem = (item) => {
    if (!item.key) return false;

    const { value } = item;

    // Handle single number values
    if (typeof value === "number") {
      return !Number.isNaN(value);
    }

    // Handle coordinate array values [x, y]
    if (Array.isArray(value) && value.length === 2) {
      return value.every(
        (coord) => typeof coord === "number" && !Number.isNaN(coord)
      );
    }

    return false;
  };

  if (!data.every(isValidItem)) {
    throw new TypeError(`Invalid data: ${JSON.stringify(data)}`);
  }
};

/**
 * Finds the maximum key length in the data array
 * @param {ChartDatum[]} data - The data array
 * @returns {number} The maximum key length
 */
const maxKeyLen = (data) => Math.max(...data.map((item) => item.key.length));

/**
 * Gets the original length of a string without ANSI escape codes
 * @param {string} str - The string to measure
 * @returns {number} The length without ANSI codes
 */
const getOriginLen = (str) => str.replace(/\x1b\[[0-9;]*m/g, "").length;

/**
 * Creates cursor forward movement ANSI code
 * @param {number} step - Number of steps to move forward
 * @returns {string} The ANSI escape code
 */
const curForward = (step = 1) => `\x1b[${step}C`;

/**
 * Creates cursor up movement ANSI code
 * @param {number} step - Number of steps to move up
 * @returns {string} The ANSI escape code
 */
const curUp = (step = 1) => `\x1b[${step}A`;

/**
 * Creates cursor down movement ANSI code
 * @param {number} step - Number of steps to move down
 * @returns {string} The ANSI escape code
 */
const curDown = (step = 1) => `\x1b[${step}B`;

/**
 * Creates cursor backward movement ANSI code
 * @param {number} step - Number of steps to move backward
 * @returns {string} The ANSI escape code
 */
const curBack = (step = 1) => `\x1b[${step}D`;

export {
  PAD,
  EOL,
  bg,
  fg,
  padMid,
  verifyData,
  maxKeyLen,
  getOriginLen,
  curForward,
  curUp,
  curDown,
  curBack,
};
