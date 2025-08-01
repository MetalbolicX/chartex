import { stdout } from "node:process";
import { EOL } from "node:os";
import type {
  BackgroundColor,
  ChartDatum,
  ScatterPlotDatum,
} from "../types/types.ts";

/**
 * Gets the current terminal width (columns)
 * @returns number of columns or default (80)
 */
const getShellWidth = (): number =>
  typeof stdout !== "undefined" && stdout.columns ? stdout.columns : 80;

/**
 * Gets the current terminal height (rows)
 * @returns number of rows or default (24)
 */
const getShellHeight = (): number =>
  typeof stdout !== "undefined" && stdout.rows ? stdout.rows : 24;

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
  if (!(Array.isArray(data) && data.length > 0)) {
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
const maxKeyLen = (data: ChartDatum[]): number =>
  Math.max(...data.map(({ key }) => key.length));

/**
 * Gets the original length of a string without ANSI escape codes
 * @param str - The string to measure
 * @returns The length without ANSI codes
 */
const getOriginLen = (str: string): number =>
  str.replace(/\\x1b\[[0-9;]*m/g, "").length;

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

/**
 * Transforms data with x/y coordinates into ScatterPlotDatum format with error handling
 * @param data - Array of objects with x, y coordinates and optional category
 * @param categoryKey - Key name for the category field (default: "category")
 * @param xKey - Key name for the x coordinate field (default: "x")
 * @param yKey - Key name for the y coordinate field (default: "y")
 * @param defaultStyle - Default style to apply if none provided
 * @returns Array of ScatterPlotDatum objects
 * @throws TypeError if any item is missing required keys or has invalid coordinates
 */
const parseScatterData = <T extends Record<string, unknown>>(
  data: T[],
  categoryKey: keyof T = "category" as keyof T,
  xKey: keyof T = "x" as keyof T,
  yKey: keyof T = "y" as keyof T,
  defaultStyle?: string
): ScatterPlotDatum[] =>
  data.map((item, idx) => {
    const key = item[categoryKey];
    const x = item[xKey];
    const y = item[yKey];
    if (key == null) {
      throw new TypeError(
        `Missing key '${String(categoryKey)}' at index ${idx}: ${JSON.stringify(
          item
        )}`
      );
    }
    if (x == null || y == null) {
      throw new TypeError(
        `Missing coordinate '${String(xKey)}' or '${String(
          yKey
        )}' at index ${idx}: ${JSON.stringify(item)}`
      );
    }
    if (Number.isNaN(Number(x)) || Number.isNaN(Number(y))) {
      throw new TypeError(
        `Invalid number for '${String(xKey)}' or '${String(
          yKey
        )}' at index ${idx}: ${JSON.stringify(item)}`
      );
    }
    return {
      key: String(key),
      value: [Number(x), Number(y)] as [number, number],
      ...(defaultStyle && { style: defaultStyle }),
    };
  });

/**
 * Transforms data with value field into chart datum format with error handling
 * @param data - Array of objects with value and optional category
 * @param categoryKey - Key name for the category field (default: "category")
 * @param valueKey - Key name for the value field (default: "value")
 * @param defaultStyle - Default style to apply if none provided
 * @returns Array of chart datum objects
 * @throws TypeError if any item is missing required keys or has invalid value
 */
const parseCategoricalData = <T extends Record<string, unknown>>(
  data: T[],
  categoryKey: keyof T = "category" as keyof T,
  valueKey: keyof T = "value" as keyof T,
  defaultStyle?: string
): Array<{ key: string; value: number; style?: string }> =>
  data.map((item, idx) => {
    const key = item[categoryKey];
    const value = item[valueKey];
    if (key == null) {
      throw new TypeError(
        `Missing key '${String(categoryKey)}' at index ${idx}: ${JSON.stringify(
          item
        )}`
      );
    }
    if (value == null) {
      throw new TypeError(
        `Missing value '${String(valueKey)}' at index ${idx}: ${JSON.stringify(
          item
        )}`
      );
    }
    if (Number.isNaN(Number(value))) {
      throw new TypeError(
        `Invalid number for '${String(
          valueKey
        )}' at index ${idx}: ${JSON.stringify(item)}`
      );
    }
    return {
      key: String(key),
      value: Number(value),
      ...(defaultStyle && { style: defaultStyle }),
    };
  });

/**
 * Transforms array of values into chart datum format with auto-generated keys
 * @param values - Array of numeric values
 * @param keyPrefix - Prefix for auto-generated keys (default: "Item")
 * @param defaultStyle - Default style to apply if none provided
 * @returns Array of chart datum objects
 */
const parseList = (
  values: number[],
  keyPrefix: string = "Item",
  defaultStyle?: string
): Array<{ key: string; value: number; style?: string }> => {
  return values.map((value, index) => ({
    key: `${keyPrefix} ${index + 1}`,
    value,
    ...(defaultStyle && { style: defaultStyle }),
  }));
};

/**
 * Transforms key-value pairs object into chart datum format
 * @param data - Object with string keys and numeric values
 * @param defaultStyle - Default style to apply if none provided
 * @returns Array of chart datum objects
 */
const parseFromObject = (
  data: Record<string, number>,
  defaultStyle?: string
): Array<{ key: string; value: number; style?: string }> =>
  Object.entries(data).map(([key, value]) => ({
    key,
    value,
    ...(defaultStyle && { style: defaultStyle }),
  }));

/**
 * Transforms data with custom field mapping
 * @param data - Array of objects to transform
 * @param mapping - Object defining field mappings
 * @param defaultStyle - Default style to apply if none provided
 * @returns Array of chart datum objects
 * @throws TypeError if any item is missing required keys or has invalid value(s)
 */
const parseCustomData = <T extends Record<string, unknown>>(
  data: T[],
  mapping: {
    key: keyof T;
    value: keyof T;
    x?: keyof T;
    y?: keyof T;
  },
  defaultStyle?: string
): Array<{ key: string; value: number | [number, number]; style?: string }> =>
  data.map((item, idx) => {
    const key = item[mapping.key];
    if (key == null) {
      throw new TypeError(
        `Missing key '${String(mapping.key)}' at index ${idx}: ${JSON.stringify(
          item
        )}`
      );
    }

    // Handle scatter plot data (x, y coordinates)
    if (mapping.x && mapping.y) {
      const x = item[mapping.x];
      const y = item[mapping.y];
      if (x == null || y == null) {
        throw new TypeError(
          `Missing coordinate '${String(mapping.x)}' or '${String(
            mapping.y
          )}' at index ${idx}: ${JSON.stringify(item)}`
        );
      }
      if (Number.isNaN(Number(x)) || Number.isNaN(Number(y))) {
        throw new TypeError(
          `Invalid number for '${String(mapping.x)}' or '${String(
            mapping.y
          )}' at index ${idx}: ${JSON.stringify(item)}`
        );
      }
      return {
        key: String(key),
        value: [Number(x), Number(y)] as [number, number],
        ...(defaultStyle && { style: defaultStyle }),
      };
    }

    // Handle regular chart data (single value)
    const value = item[mapping.value];
    if (value == null) {
      throw new TypeError(
        `Missing value '${String(
          mapping.value
        )}' at index ${idx}: ${JSON.stringify(item)}`
      );
    }
    if (Number.isNaN(Number(value))) {
      throw new TypeError(
        `Invalid number for '${String(
          mapping.value
        )}' at index ${idx}: ${JSON.stringify(item)}`
      );
    }
    return {
      key: String(key),
      value: Number(value),
      ...(defaultStyle && { style: defaultStyle }),
    };
  });

/**
 * Transforms data into chart datum format using callback functions for key and value extraction.
 *
 * @example
 * // For categorical data:
 * const data = [
 *   { country: "Mexico", hour: 1, gasoline: 5 },
 *   { country: "USA", hour: 2, gasoline: 7 }
 * ];
 * const keyFn = (item) => String(item.country);
 * const valueFn = (item) => Number(item.gasoline);
 * const result = parseRow(data, keyFn, valueFn);
 * // result: [ { key: "Mexico", value: 5 }, { key: "USA", value: 7 } ]
 *
 * @example
 * // For scatter plot data:
 * const data = [
 *   { country: "Mexico", hour: 1, gasoline: 5 },
 *   { country: "USA", hour: 2, gasoline: 7 }
 * ];
 * const keyFn = (item) => String(item.country);
 * const valueFn = (item) => ({ x: Number(item.hour), y: Number(item.gasoline) });
 * const result = parseRow(data, keyFn, valueFn);
 * // result: [ { key: "Mexico", value: [1, 5] }, { key: "USA", value: [2, 7] } ]
 *
 * @param data - Array of objects to transform
 * @param keyFn - Callback to extract the key (string) from each item
 * @param valueFn - Callback to extract the value (number or {x, y}) from each item
 * @param defaultStyle - Optional style string to apply to each datum
 * @returns Array of chart datum objects
 * @throws TypeError if key or value is missing or invalid
 */
const parseRow = (
  data: Record<string, unknown>[],
  keyFn: (item: Record<string, unknown>, idx: number) => string,
  valueFn: (
    item: Record<string, unknown>,
    idx: number
  ) => number | { x: number; y: number },
  defaultStyle?: string
): Array<{ key: string; value: number | [number, number]; style?: string }> =>
  data.map((item, idx) => {
    const key = keyFn(item, idx);
    if (typeof key !== "string" || !key) {
      throw new TypeError(
        `Invalid key at index ${idx}: ${JSON.stringify(key)}`
      );
    }
    const value = valueFn(item, idx);
    if (typeof value === "number") {
      if (Number.isNaN(value)) {
        throw new TypeError(
          `Invalid number value at index ${idx}: ${JSON.stringify(item)}`
        );
      }
      return {
        key,
        value,
        ...(defaultStyle && { style: defaultStyle }),
      };
    }
    if (
      value &&
      typeof value === "object" &&
      typeof value.x === "number" &&
      typeof value.y === "number"
    ) {
      if (Number.isNaN(value.x) || Number.isNaN(value.y)) {
        throw new TypeError(
          `Invalid x/y value at index ${idx}: ${JSON.stringify(item)}`
        );
      }
      return {
        key,
        value: [value.x, value.y] as [number, number],
        ...(defaultStyle && { style: defaultStyle }),
      };
    }
    throw new TypeError(
      `Invalid value at index ${idx}: ${JSON.stringify(item)}`
    );
  });

export {
  bg,
  curBack,
  curDown,
  curForward,
  curUp,
  EOL,
  fg,
  getOriginLen,
  getShellHeight,
  getShellWidth,
  maxKeyLen,
  PAD,
  padMid,
  parseCategoricalData,
  parseCustomData,
  parseFromObject,
  parseList,
  parseRow,
  parseScatterData,
  verifyData,
};
