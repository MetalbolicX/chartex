import { EOL } from "@std/fs";

const PADDING_CHARACTER = " ";

type BackgroundColor =
  | "black"
  | "red"
  | "green"
  | "yellow"
  | "blue"
  | "magenta"
  | "cyan"
  | "white";

interface ChartDataItem {
  key: string;
  value: number | number[]; // Allow both single numbers and arrays
}

const BACKGROUND_COLORS: Record<BackgroundColor, string> = {
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
 * Creates a colored background block with specified color and length.
 * @param color - The background color to use.
 * @param length - The number of padding characters to repeat.
 * @returns ANSI escape sequence for colored background.
 * @throws TypeError if color is invalid.
 */
const createColoredBackground = (
  color: BackgroundColor = "cyan",
  length: number = 1
): string => {
  const ansiColorCode = BACKGROUND_COLORS[color];

  if (!ansiColorCode) {
    throw new TypeError(`Invalid backgroundColor: ${JSON.stringify(color)}`);
  }

  return `\x1b[${ansiColorCode}m${PADDING_CHARACTER.repeat(length)}\x1b[0m`;
};

/**
 * Creates colored foreground text with specified color.
 * @param color - The foreground color to use.
 * @param text - The text to colorize.
 * @returns ANSI escape sequence for colored text.
 * @throws TypeError if color is invalid.
 */
const createColoredText = (
  color: BackgroundColor = "cyan",
  text: string
): string => {
  const backgroundColorCode = BACKGROUND_COLORS[color];

  if (!backgroundColorCode) {
    throw new TypeError(`Invalid foregroundColor: ${JSON.stringify(color)}`);
  }

  const foregroundColorCode = parseInt(backgroundColorCode) - 10;
  return `\x1b[${foregroundColorCode}m${text}\x1b[0m`;
};

/**
 * Centers text within a specified width by adding padding.
 * @param text - The text to center.
 * @param width - The total width to center within.
 * @returns Centered text with appropriate padding.
 */
const centerTextInWidth = (text: string, width: number): string => {
  const textLength = text.length;

  if (textLength > width) {
    return text.padEnd(width);
  }

  const paddingLength = Math.round((width - textLength) / 2);
  const extraPadding = paddingLength * 2 + textLength > width ? -1 : 0;

  return `${PADDING_CHARACTER.repeat(
    paddingLength
  )}${text}${PADDING_CHARACTER.repeat(paddingLength + extraPadding)}`;
};

/**
 * Validates chart data array structure and content.
 * @param data - Array of chart data items to validate.
 * @throws TypeError if data is invalid.
 */
const validateChartData = (data: ChartDataItem[]): void => {
  if (
    !Array.isArray(data) ||
    data.length === 0 ||
    !data.every((item) => item.key && !Number.isNaN(item.value))
  ) {
    throw new TypeError(`Invalid data: ${JSON.stringify(data)}`);
  }
};

/**
 * Finds the maximum key length in chart data array.
 * @param data - Array of chart data items.
 * @returns The length of the longest key.
 */
const getMaximumKeyLength = (data: ChartDataItem[]): number =>
  Math.max(...data.map((item) => item.key.length));

/**
 * Gets the original length of a string without ANSI escape sequences.
 * @param text - The text to measure.
 * @returns The length without escape sequences.
 */
const getOriginalTextLength = (text: string): number =>
  text.replace(/\x1b\[[0-9;]*m/g, "").length;

/**
 * Creates ANSI escape sequence to move cursor forward.
 * @param steps - Number of steps to move forward.
 * @returns ANSI escape sequence for cursor movement.
 */
const moveCursorForward = (steps: number = 1): string => `\x1b[${steps}C`;

/**
 * Creates ANSI escape sequence to move cursor up.
 * @param steps - Number of steps to move up.
 * @returns ANSI escape sequence for cursor movement.
 */
const moveCursorUp = (steps: number = 1): string => `\x1b[${steps}A`;

/**
 * Creates ANSI escape sequence to move cursor down.
 * @param steps - Number of steps to move down.
 * @returns ANSI escape sequence for cursor movement.
 */
const moveCursorDown = (steps: number = 1): string => `\x1b[${steps}B`;

/**
 * Creates ANSI escape sequence to move cursor backward.
 * @param steps - Number of steps to move backward.
 * @returns ANSI escape sequence for cursor movement.
 */
const moveCursorBackward = (steps: number = 1): string => `\x1b[${steps}D`;

export {
  PADDING_CHARACTER,
  EOL,
  createColoredBackground,
  createColoredText,
  centerTextInWidth,
  validateChartData,
  getMaximumKeyLength,
  getOriginalTextLength,
  moveCursorForward,
  moveCursorUp,
  moveCursorDown,
  moveCursorBackward,
  type BackgroundColor,
  type ChartDataItem,
};
