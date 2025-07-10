import { EOL } from "node:os";
import type { BackgroundColor, ChartDatum } from "../types/types.ts";

/**
 * Padding character used throughout the utility functions
 */
const PAD = " ";

/**
 * Background color codes for terminal styling
 */
const bgColors: Record<BackgroundColor, string> = {
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
 * Creates a background colored block
 * @param color - The background color name
 * @param length - The length of the colored block
 * @returns The ANSI colored string
 */
const bg = (color: BackgroundColor = "cyan", length: number = 1): string => {
  const currentBg = bgColors[color];
  if (typeof color !== "string" || !currentBg) {
    throw new TypeError(`Invalid backgroundColor: ${JSON.stringify(color)}`);
  }

  return `\x1b[${currentBg}m${PAD.repeat(length)}\x1b[0m`;
};

/**
 * Creates a foreground colored text
 * @param color - The foreground color name
 * @param str - The string to color
 * @returns The ANSI colored string
 */
const fg = (color: BackgroundColor = "cyan", str: string): string => {
  const currentBg = bgColors[color];
  if (typeof color !== "string" || !currentBg) {
    throw new TypeError(`Invalid foregroundColor: ${JSON.stringify(color)}`);
  }

  return `\x1b[${parseInt(bgColors[color]) - 10}m${str}\x1b[0m`;
};

/**
 * Pads a string to center it within a given width
 * @param str - The string to pad
 * @param width - The target width
 * @returns The padded string
 */
const padMid = (str: string, width: number): string => {
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
 * @param data - The data array to verify
 * @throws TypeError if data format is invalid
 */
const verifyData = (data: ChartDatum[]): void => {
  const { length } = data;

  if (!Array.isArray(data) || length === 0) {
    throw new TypeError(`Invalid data: ${JSON.stringify(data)}`);
  }

  const isValidItem = (item: ChartDatum): boolean => {
    if (!item.key) return false;

    const { value } = item;

    // Handle single number values
    if (typeof value === "number") {
      return !Number.isNaN(value);
    }

    // Handle coordinate array values [x, y]
    if (Array.isArray(value) && value.length === 2) {
      return value.every(
        (coord: number) => typeof coord === "number" && !Number.isNaN(coord)
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
 * @param data - The data array
 * @returns The maximum key length
 */
const maxKeyLen = (data: ChartDatum[]): number => Math.max(...data.map((item) => item.key.length));

/**
 * Gets the original length of a string without ANSI escape codes
 * @param str - The string to measure
 * @returns The length without ANSI codes
 */
const getOriginLen = (str: string): number => str.replace(/\x1b\[[0-9;]*m/g, "").length;

/**
 * Creates cursor forward movement ANSI code
 * @param step - Number of steps to move forward
 * @returns The ANSI escape code
 */
const curForward = (step: number = 1): string => `\x1b[${step}C`;

/**
 * Creates cursor up movement ANSI code
 * @param step - Number of steps to move up
 * @returns The ANSI escape code
 */
const curUp = (step: number = 1): string => `\x1b[${step}A`;

/**
 * Creates cursor down movement ANSI code
 * @param step - Number of steps to move down
 * @returns The ANSI escape code
 */
const curDown = (step: number = 1): string => `\x1b[${step}B`;

/**
 * Creates cursor backward movement ANSI code
 * @param step - Number of steps to move backward
 * @returns The ANSI escape code
 */
const curBack = (step: number = 1): string => `\x1b[${step}D`;

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

