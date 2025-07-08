import { EOL } from "node:os";
import { BackgroundColor, ChartDatum } from "../types/types.ts";

const PAD = " ";

const bgColors: Record<BackgroundColor, string> = {
  "black": "40",
  "red": "41",
  "green": "42",
  "yellow": "43",
  "blue": "44",
  "magenta": "45",
  "cyan": "46",
  "white": "47"
};

/**
 * Creates a background color string with specified color and length
 * @param color - The background color to use
 * @param length - The length of the background color block
 * @returns The formatted background color string
 */
const bg = (color: BackgroundColor = "cyan", length: number = 1): string => {
  const currentBg = bgColors[color];
  if (!currentBg) {
    throw new TypeError(`Invalid backgroundColor: ${JSON.stringify(color)}`);
  }

  return `\x1b[${currentBg}m${PAD.repeat(length)}\x1b[0m`;
};

/**
 * Creates a foreground color string with specified color and text
 * @param color - The foreground color to use
 * @param str - The string to color
 * @returns The formatted foreground color string
 */
const fg = (color: BackgroundColor = "cyan", str: string): string => {
  const currentBg = bgColors[color];
  if (!currentBg) {
    throw new TypeError(`Invalid foregroundColor: ${JSON.stringify(color)}`);
  }

  const colorCode = parseInt(currentBg) - 10;
  return `\x1b[${colorCode}m${str}\x1b[0m`;
};

/**
 * Pads a string to center it within a specified width
 * @param str - The string to pad
 * @param width - The target width
 * @returns The padded string
 */
const padMid = (str: string, width: number): string => {
  const mid = Math.round((width - str.length) / 2);
  const length = str.length;

  return length > width
    ? str.padEnd(width)
    : `${PAD.repeat(mid)}${str}${PAD.repeat(mid + ((mid * 2 + length) > width ? -1 : 0))}`;
};

/**
 * Verifies that the data array is valid for chart rendering
 * @param data - The data array to verify
 * @throws TypeError if data is invalid
 */
const verifyData = (data: ChartDatum[]): void => {
  const length = data.length;

  if (!Array.isArray(data) ||
    length === 0 ||
    !data.every(item => item.key && !Number.isNaN(Number(item.value)))
  ) {
    throw new TypeError(`Invalid data: ${JSON.stringify(data)}`);
  }
};

/**
 * Finds the maximum key length in the data array
 * @param data - The data array to analyze
 * @returns The maximum key length
 */
const maxKeyLen = (data: ChartDatum[]): number =>
  Math.max(...data.map(item => item.key.length));

/**
 * Gets the original length of a string without ANSI escape sequences
 * @param str - The string to measure
 * @returns The original string length
 */
const getOriginLen = (str: string): number =>
  str.replace(/\x1b\[[0-9;]*m/g, "").length;

/**
 * Moves cursor forward by specified steps
 * @param step - Number of steps to move forward
 * @returns The cursor movement string
 */
const curForward = (step: number = 1): string => `\x1b[${step}C`;

/**
 * Moves cursor up by specified steps
 * @param step - Number of steps to move up
 * @returns The cursor movement string
 */
const curUp = (step: number = 1): string => `\x1b[${step}A`;

/**
 * Moves cursor down by specified steps
 * @param step - Number of steps to move down
 * @returns The cursor movement string
 */
const curDown = (step: number = 1): string => `\x1b[${step}B`;

/**
 * Moves cursor back by specified steps
 * @param step - Number of steps to move back
 * @returns The cursor movement string
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
  curBack
};
