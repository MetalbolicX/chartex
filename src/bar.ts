import {
  PADDING_CHARACTER,
  centerTextInWidth,
  validateChartData,
  EOL,
} from "./utils/utils.ts";

import type { BarChartDataItem, BarChartOptions } from "./types/types.ts";

/**
 * Creates a vertical bar chart representation from the provided data.
 * @param data - Array of chart data items to visualize.
 * @param options - Configuration options for the bar chart appearance.
 * @returns A string representation of the bar chart.
 * @throws TypeError if data is invalid.
 */
const createBarChart = (
  data: BarChartDataItem[],
  options?: BarChartOptions
): string => {
  validateChartData(data);

  const chartOptions: Required<BarChartOptions> = {
    barWidth: 3,
    left: 1,
    height: 6,
    padding: 3,
    style: "*",
    ...options,
  };

  const { barWidth, left, height, padding, style } = chartOptions;

  let result = PADDING_CHARACTER.repeat(left);

  const values = data.flatMap((item) => item.value);
  const maximumValue = Math.max(...values);
  const dataLength = data.length;

  for (let rowIndex = 0; rowIndex < height + 2; rowIndex++) {
    for (let columnIndex = 0; columnIndex < dataLength; columnIndex++) {
      const currentItem = data[columnIndex];
      const valueString = currentItem.value.toString();
      const normalizedRatio =
        height - (height * currentItem.value) / maximumValue;

      const paddingCharacter = getPaddingCharacter(
        normalizedRatio,
        rowIndex,
        valueString,
        currentItem.style || style
      );

      if (paddingCharacter === valueString) {
        result += `${centerTextInWidth(
          valueString,
          barWidth
        )}${PADDING_CHARACTER.repeat(padding)}`;
        continue;
      }

      if (rowIndex !== height + 1) {
        result += `${paddingCharacter.repeat(
          barWidth
        )}${PADDING_CHARACTER.repeat(padding)}`;
      } else {
        result += formatKeyLabel(currentItem.key, barWidth, padding);
      }
    }

    if (rowIndex !== height + 1) {
      result += `${EOL}${PADDING_CHARACTER.repeat(left)}`;
    }
  }

  return result;
};

/**
 * Determines the appropriate padding character for a specific position in the bar chart.
 * @param ratio - The normalized ratio for the current value.
 * @param currentRow - The current row index being processed.
 * @param valueString - The string representation of the value.
 * @param styleCharacter - The character to use for the bar style.
 * @returns The appropriate character to display at this position.
 */
const getPaddingCharacter = (
  ratio: number,
  currentRow: number,
  valueString: string,
  styleCharacter: string
): string => {
  if (ratio > currentRow + 2) {
    return PADDING_CHARACTER;
  }

  if (Math.round(ratio) === currentRow) {
    return valueString;
  }

  if (Math.round(ratio) < currentRow) {
    return styleCharacter;
  }

  return PADDING_CHARACTER;
};

/**
 * Formats the key label for display at the bottom of each bar.
 * @param key - The key text to format.
 * @param barWidth - The width of each bar.
 * @param padding - The padding between bars.
 * @returns Formatted key string with appropriate padding.
 */
const formatKeyLabel = (
  key: string,
  barWidth: number,
  padding: number
): string => {
  if (key.length > barWidth) {
    return key.padEnd(barWidth + padding);
  }

  return `${centerTextInWidth(key, barWidth)}${PADDING_CHARACTER.repeat(
    padding
  )}`;
};

export { createBarChart };
