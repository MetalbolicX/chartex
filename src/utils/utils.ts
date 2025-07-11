import { EOL } from "node:os";
import { stdout } from "node:process";
import type { BackgroundColor, ChartDatum, ScatterPlotDatum } from "../types/types.ts";

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

/**
 * Transforms data with x/y coordinates into ScatterPlotDatum format
 * @param data - Array of objects with x, y coordinates and optional category
 * @param categoryKey - Key name for the category field (default: "category")
 * @param xKey - Key name for the x coordinate field (default: "x")
 * @param yKey - Key name for the y coordinate field (default: "y")
 * @param defaultStyle - Default style to apply if none provided
 * @returns Array of ScatterPlotDatum objects
 */
const transformScatterData = <T extends Record<string, any>>(
  data: T[],
  categoryKey: keyof T = "category" as keyof T,
  xKey: keyof T = "x" as keyof T,
  yKey: keyof T = "y" as keyof T,
  defaultStyle?: string
): ScatterPlotDatum[] => {
  return data.map((item) => ({
    key: String(item[categoryKey] ?? "Unknown"),
    value: [Number(item[xKey]), Number(item[yKey])] as [number, number],
    ...(defaultStyle && { style: defaultStyle }),
  }));
};

/**
 * Transforms data with value field into chart datum format
 * @param data - Array of objects with value and optional category
 * @param categoryKey - Key name for the category field (default: "category")
 * @param valueKey - Key name for the value field (default: "value")
 * @param defaultStyle - Default style to apply if none provided
 * @returns Array of chart datum objects
 */
const transformChartData = <T extends Record<string, any>>(
  data: T[],
  categoryKey: keyof T = "category" as keyof T,
  valueKey: keyof T = "value" as keyof T,
  defaultStyle?: string
): Array<{ key: string; value: number; style?: string }> => {
  return data.map((item) => ({
    key: String(item[categoryKey] ?? "Unknown"),
    value: Number(item[valueKey]),
    ...(defaultStyle && { style: defaultStyle }),
  }));
};

/**
 * Transforms array of values into chart datum format with auto-generated keys
 * @param values - Array of numeric values
 * @param keyPrefix - Prefix for auto-generated keys (default: "Item")
 * @param defaultStyle - Default style to apply if none provided
 * @returns Array of chart datum objects
 */
const transformSimpleData = (
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
const transformObjectData = (
  data: Record<string, number>,
  defaultStyle?: string
): Array<{ key: string; value: number; style?: string }> => {
  return Object.entries(data).map(([key, value]) => ({
    key,
    value,
    ...(defaultStyle && { style: defaultStyle }),
  }));
};

/**
 * Transforms data with custom field mapping
 * @param data - Array of objects to transform
 * @param mapping - Object defining field mappings
 * @param defaultStyle - Default style to apply if none provided
 * @returns Array of chart datum objects
 */
const transformCustomData = <T extends Record<string, any>>(
  data: T[],
  mapping: {
    key: keyof T;
    value: keyof T;
    x?: keyof T;
    y?: keyof T;
  },
  defaultStyle?: string
): Array<{ key: string; value: number | [number, number]; style?: string }> => {
  return data.map((item) => {
    const baseData = {
      key: String(item[mapping.key] ?? "Unknown"),
      ...(defaultStyle && { style: defaultStyle }),
    };

    // Handle scatter plot data (x, y coordinates)
    if (mapping.x && mapping.y) {
      return {
        ...baseData,
        value: [Number(item[mapping.x]), Number(item[mapping.y])] as [number, number],
      };
    }

    // Handle regular chart data (single value)
    return {
      ...baseData,
      value: Number(item[mapping.value]),
    };
  });
};

/**
 * Calculates the domain (min and max values) for a dataset
 * @param data - Array of chart data items
 * @param valueAccessor - Optional function to access specific value from data
 * @returns Object with min and max values
 */
const calculateDomain = <T extends ChartDatum | number | [number, number]>(
  data: T[],
  valueAccessor?: (item: T) => number | [number, number]
): { min: number; max: number } => {
  if (!data.length) {
    return { min: 0, max: 0 };
  }

  const values = data.map((item) => {
    if (valueAccessor) {
      return valueAccessor(item);
    }

    if (typeof item === "number") {
      return item;
    }

    if (Array.isArray(item)) {
      return item;
    }

    return (item as ChartDatum).value;
  });

  // Handle both single values and coordinate pairs
  const allNumbers: number[] = values.flatMap((value) =>
    Array.isArray(value) ? value : [value]
  );

  const min = Math.min(...allNumbers);
  const max = Math.max(...allNumbers);

  return { min, max };
};

/**
 * Creates a "nice" rounded domain with appropriate intervals
 * @param domain - Object with min and max values
 * @param tickCount - Desired number of ticks/intervals
 * @returns Object with nice min and max values and suggested tick interval
 */
const niceDomain = (
  domain: { min: number; max: number },
  tickCount: number = 5
): { min: number; max: number; tickInterval: number } => {
  const { min, max } = domain;

  // Handle edge cases
  if (min === max) {
    return {
      min: min === 0 ? 0 : Math.floor(min * 0.8),
      max: max === 0 ? 10 : Math.ceil(max * 1.2),
      tickInterval: 1
    };
  }

  const range = max - min;
  const unroundedTickSize = range / (tickCount - 1);
  // const x = Math.pow(10, Math.floor(Math.log10(unroundedTickSize)));
  const x = 10 ** Math.floor(Math.log10(unroundedTickSize));
  const xMultiples = [0.1, 0.2, 0.25, 0.5, 1, 2, 2.5, 5, 10];

  const tickInterval = xMultiples
    .map(multiple => multiple * x)
    .find(interval => interval >= unroundedTickSize) || x;

  const niceMin = Math.floor(min / tickInterval) * tickInterval;
  const niceMax = Math.ceil(max / tickInterval) * tickInterval;

  return { min: niceMin, max: niceMax, tickInterval };
};

/**
 * Determines optimal chart dimensions based on data characteristics
 * @param data - Array of chart data
 * @param options - Chart configuration options
 * @returns Optimal dimensions object
 */
const calculateOptimalDimensions = (
  data: ChartDatum[],
  options: {
    terminalWidth?: number;
    terminalHeight?: number;
    aspectRatio?: number;
    minWidth?: number;
    maxWidth?: number;
  } = {}
): { width: number; height: number; ratio: [number, number] } => {
  const terminalWidth = options.terminalWidth || stdout.columns || 80;
  const terminalHeight = options.terminalHeight || stdout.rows || 24;
  const aspectRatio = options.aspectRatio || 2.5; // Default width:height ratio
  const minWidth = options.minWidth || 10;
  const maxWidth = options.maxWidth || Math.min(80, terminalWidth - 10);

  // For single value data (bar charts, etc.)
  const singleValueData = data.filter(({ value }) => typeof value === "number");
  if (singleValueData.length > 0) {
    // Determine width based on number of items and key length
    const keyLength = maxKeyLen(singleValueData);
    const suggestedWidth = Math.max(
      minWidth,
      Math.min(maxWidth, Math.floor((terminalWidth - keyLength - 5) * 0.8))
    );

    // Calculate height based on aspect ratio
    const suggestedHeight = Math.max(
      5,
      Math.min(
        Math.floor(terminalHeight * 0.6),
        Math.floor(suggestedWidth / aspectRatio)
      )
    );

    return {
      width: suggestedWidth,
      height: suggestedHeight,
      ratio: [1, 1]
    };
  }

  // For coordinate data (scatter plots)
  const scatterData = data.filter(({ value }) => Array.isArray(value));
  if (scatterData.length > 0) {
    // Get x and y domains
    const xValues = scatterData.map(d => (d.value as [number, number])[0]);
    const yValues = scatterData.map(d => (d.value as [number, number])[1]);

    const xDomain = { min: Math.min(...xValues), max: Math.max(...xValues) };
    const yDomain = { min: Math.min(...yValues), max: Math.max(...yValues) };

    // Calculate ratio to maintain proportions
    const xRange = xDomain.max - xDomain.min;
    const yRange = yDomain.max - yDomain.min;

    // Prevent division by zero
    const ratio: [number, number] = [
      xRange === 0 ? 1 : xRange,
      yRange === 0 ? 1 : yRange
    ];

    // Normalize ratio
    const maxRatioValue = Math.max(...ratio);
    const normalizedRatio: [number, number] = [
      ratio[0] / maxRatioValue,
      ratio[1] / maxRatioValue
    ];

    // Calculate dimensions
    const suggestedWidth = Math.max(
      minWidth,
      Math.min(maxWidth, Math.floor(terminalWidth * 0.6))
    );

    const suggestedHeight = Math.max(
      5,
      Math.min(
        Math.floor(terminalHeight * 0.6),
        Math.floor(suggestedWidth * (normalizedRatio[1] / normalizedRatio[0]))
      )
    );

    return {
      width: suggestedWidth,
      height: suggestedHeight,
      ratio: normalizedRatio
    };
  }

  // Default fallback values
  return {
    width: 40,
    height: 15,
    ratio: [1, 1]
  };
};

/**
 * Generates appropriate tick values for an axis
 * @param domain - Object with min and max values
 * @param count - Number of ticks to generate
 * @returns Array of tick values
 */
const generateTicks = (
  domain: { min: number; max: number },
  count: number = 5
): number[] => {
  const { min, max, tickInterval } = niceDomain(domain, count);

  const tickCount = Math.floor((max - min) / tickInterval) + 1;
  return Array.from({ length: tickCount }, (_, idx) =>
    Number((min + idx * tickInterval).toFixed(10))
  );
};

/**
 * Automatically formats chart configuration based on dataset
 * @param data - Array of chart data
 * @param userOptions - User-provided chart options (partial)
 * @returns Complete chart configuration with sensible defaults
 */
const autoConfig = <T extends Record<string, any>>(
  data: ChartDatum[],
  userOptions: T
): T => {
  // Calculate domain for values
  let domain;

  if (data.length > 0 && Array.isArray(data[0].value)) {
    // Handle scatter plot data
    const xValues = data.map(d => (d.value as [number, number])[0]);
    const yValues = data.map(d => (d.value as [number, number])[1]);

    domain = {
      x: niceDomain({ min: Math.min(...xValues), max: Math.max(...xValues) }),
      y: niceDomain({ min: Math.min(...yValues), max: Math.max(...yValues) })
    };
  } else {
    // Handle single value data
    const values = data.map(d => Number(d.value));
    domain = niceDomain({ min: Math.min(...values), max: Math.max(...values) });
  }

  // Calculate optimal dimensions
  const dimensions = calculateOptimalDimensions(data, userOptions);

  // Merge everything with user options (user options take precedence)
  return {
    ...dimensions,
    domain,
    ...userOptions
  };
};

export {
  calculateDomain,
  niceDomain,
  calculateOptimalDimensions,
  generateTicks,
  autoConfig,
  bg,
  curBack,
  curDown,
  curForward,
  curUp,
  EOL,
  fg,
  getOriginLen,
  maxKeyLen,
  PAD,
  padMid,
  transformChartData,
  transformCustomData,
  transformObjectData,
  transformScatterData,
  transformSimpleData,
  verifyData,
};

