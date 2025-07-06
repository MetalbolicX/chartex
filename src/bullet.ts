import {
  PADDING_CHARACTER,
  validateChartData,
  getMaximumKeyLength,
  EOL,
  type ChartDataItem,
} from "./utils.ts";

interface BulletChartOptions {
  barWidth?: number;
  style?: string;
  left?: number;
  width?: number;
  padding?: number;
}

interface BulletDataItem extends ChartDataItem {
  value: number;
  style?: string;
  barWidth?: number;
}

/**
 * Creates a horizontal bullet chart representation from the provided data.
 * @param data - Array of bullet chart data items to visualize.
 * @param options - Configuration options for the bullet chart appearance.
 * @returns A string representation of the bullet chart.
 * @throws TypeError if data is invalid.
 */
const createBulletChart = (
  data: BulletDataItem[],
  options?: BulletChartOptions
): string => {
  validateChartData(data);

  const chartOptions: Required<BulletChartOptions> = {
    barWidth: 1,
    style: "*",
    left: 1,
    width: 10,
    padding: 1,
    ...options,
  };

  const { barWidth, left, width, padding, style } = chartOptions;

  const result = PADDING_CHARACTER.repeat(left);

  const values = data.map(({ value }) => value);
  const maximumValue = Math.max(...values);
  const maximumKeyLength = getMaximumKeyLength(data);

  return data.reduce((accumulator, currentItem, index) => {
    const chartLine = createChartLine(
      currentItem,
      maximumValue,
      width,
      style,
      maximumKeyLength,
      barWidth,
      left
    );

    const isLastItem = index === data.length - 1;
    const lineSeparator = isLastItem
      ? ""
      : `${EOL.repeat(padding)}${PADDING_CHARACTER.repeat(left)}`;

    return `${accumulator}${chartLine}${lineSeparator}`;
  }, result);
};

/**
 * Creates a single chart line with key label and horizontal bar.
 * @param item - The data item to render.
 * @param maximumValue - The maximum value in the dataset.
 * @param width - The maximum width for bars.
 * @param defaultStyle - The default style character.
 * @param maximumKeyLength - The maximum key length for alignment.
 * @param defaultBarWidth - The default bar width.
 * @param left - The left padding amount.
 * @returns Formatted chart line string.
 */
const createChartLine = (
  item: BulletDataItem,
  maximumValue: number,
  width: number,
  defaultStyle: string,
  maximumKeyLength: number,
  defaultBarWidth: number,
  left: number
): string => {
  const { value, key, style: itemStyle, barWidth: itemBarWidth } = item;

  const ratioLength = Math.round(width * (value / maximumValue));
  const barCharacter = itemStyle || defaultStyle;
  const currentBarWidth = itemBarWidth || defaultBarWidth;

  const barLine = `${barCharacter.repeat(ratioLength)}${EOL}${PADDING_CHARACTER.repeat(left)}`;
  const keyLabel = `${key.padStart(maximumKeyLength)}${PADDING_CHARACTER}`;

  return Array.from({ length: currentBarWidth }, (_, barIndex) => {
    const isFirstBar = barIndex === 0;
    const linePrefix = isFirstBar
      ? keyLabel
      : `${PADDING_CHARACTER.repeat(maximumKeyLength + 1)}`;

    return `${linePrefix}${barLine}`;
  }).join("");
};

export { createBulletChart, type BulletChartOptions, type BulletDataItem };
