import {
  verifyData,
  PAD,
  maxKeyLen,
  EOL,
} from "./utils/utils.ts";

import type { PieChartDatum, PieChartOptions } from "./types/types.ts";

/**
 * Creates a pie chart or donut chart visualization from the provided data.
 * @param data - Array of pie chart data items to visualize.
 * @param options - Configuration options for the pie chart appearance.
 * @param isDonut - Whether to render as a donut chart with inner hole.
 * @returns A string representation of the pie chart.
 * @throws TypeError if data is invalid.
 * @example
 * ```typescript
 * import { renderPieChart } from "chartex";
 * const data = [
 *  { key: "A", value: 10, style: "#" },
 *  { key: "B", value: 20, style: "*" },
 *  { key: "C", value: 15, style: "+" },
 * ];
 * const options = { radius: 4, left: 2, innerRadius: 1 };
 * const chart = renderPieChart(data, options);
 * console.log(chart);
 * ```
 */
const renderPieChart = (
  data: PieChartDatum[],
  options?: PieChartOptions,
  isDonut: boolean = false
): string => {
  verifyData(data);

  const chartOptions: Required<PieChartOptions> = {
    radius: 4,
    left: 0,
    innerRadius: 1,
    ...options,
  };

  const { radius, left, innerRadius } = chartOptions;

  const values = data.map(({ value }) => value);
  const totalValue = values.reduce((total, value) => total + value, 0);
  const ratios = values.map((value) => value / totalValue);
  const styles = data.map(({ style }) => style);
  const keys = data.map(({ key }) => key);
  const maximumKeyLength = maxKeyLen(data);
  const [, , ..._restStyles] = styles; // Get gap character from last style
  const gapCharacter = styles.at(-1) ?? "";
  const radiusLimit = isDonut ? innerRadius : 0;

  let result = PAD.repeat(left);

  // Generate pie chart visualization
  result += generatePieVisualization(
    radius,
    radiusLimit,
    left,
    ratios,
    styles,
    gapCharacter,
    isDonut
  );

  // Generate legend
  result += generatePieLegend(
    data,
    styles,
    keys,
    values,
    ratios,
    maximumKeyLength,
    left
  );

  return result;
};

/**
 * Determines the appropriate style character for a given parameter position in the pie.
 * @param styles - Array of style characters for each slice.
 * @param ratios - Array of ratio values for each slice.
 * @param parameter - The current position parameter (0-1).
 * @param gapCharacter - Character to use for gaps between slices.
 * @returns The appropriate style character for this position.
 */
const getStyleCharacter = (
  styles: string[],
  ratios: number[],
  parameter: number,
  gapCharacter: string
): string => {
  if (!ratios.length) return gapCharacter;

  const [firstRatio, ...remainingRatios] = ratios;
  const [firstStyle, ...remainingStyles] = styles;

  return parameter <= firstRatio
    ? firstStyle
    : getStyleCharacter(
        remainingStyles,
        remainingRatios,
        parameter - firstRatio,
        gapCharacter
      );
};

/**
 * Generates the visual representation of the pie chart.
 * @param radius - The radius of the pie chart.
 * @param radiusLimit - The inner radius limit for donut charts.
 * @param left - Left padding amount.
 * @param ratios - Array of ratio values for each slice.
 * @param styles - Array of style characters for each slice.
 * @param gapCharacter - Character to use for gaps.
 * @param isDonut - Whether this is a donut chart.
 * @returns The formatted pie chart visualization string.
 */
const generatePieVisualization = (
  radius: number,
  radiusLimit: number,
  left: number,
  ratios: number[],
  styles: string[],
  gapCharacter: string,
  isDonut: boolean
): string => {
  let visualization = "";

  for (let rowIndex = -radius; rowIndex < radius; rowIndex++) {
    for (let columnIndex = -radius; columnIndex < radius; columnIndex++) {
      const distanceFromCenter =
        Math.pow(rowIndex, 2) + Math.pow(columnIndex, 2);
      const radiusSquared = Math.pow(radius, 2);

      if (distanceFromCenter < radiusSquared) {
        const angleParameter =
          Math.atan2(rowIndex, columnIndex) * (1 / Math.PI) * 0.5 + 0.5;

        const shouldShowInnerHole =
          isDonut &&
          (Math.abs(rowIndex) <= radiusLimit ||
            Math.abs(columnIndex) <= radiusLimit);

        visualization += shouldShowInnerHole
          ? PAD.repeat(2)
          : getStyleCharacter(styles, ratios, angleParameter, gapCharacter);
      } else {
        visualization += PAD.repeat(2);
      }
    }

    visualization += `${EOL}${PAD.repeat(left)}`;
  }

  return `${visualization}${EOL}${PAD.repeat(left)}`;
};

/**
 * Generates the legend section for the pie chart.
 * @param data - Array of pie chart data items.
 * @param styles - Array of style characters.
 * @param keys - Array of key labels.
 * @param values - Array of numeric values.
 * @param ratios - Array of ratio values.
 * @param maximumKeyLength - Maximum length among all keys.
 * @param left - Left padding amount.
 * @returns The formatted legend string.
 */
const generatePieLegend = (
  data: PieChartDatum[],
  styles: string[],
  keys: string[],
  values: number[],
  ratios: number[],
  maximumKeyLength: number,
  left: number
): string => {
  const legendItems = data.map((_, index) => {
    const style = styles[index];
    const key = keys[index].padStart(maximumKeyLength);
    const value = values[index];
    const percentage = (ratios[index] * 100).toFixed(0);

    return `${style}${PAD}${key}: ${value}${PAD}(${percentage}%)`;
  });

  return legendItems
    .map((item) => `${item}${EOL}${PAD.repeat(left)}`)
    .join("");
};

/**
 * Creates a donut chart visualization from the provided data.
 * @param data - Array of pie chart data items to visualize.
 * @param options - Configuration options for the donut chart appearance.
 * @returns A string representation of the donut chart.
 * @throws TypeError if data is invalid.
 * @example
 * ```typescript
 * import { renderDonutChart } from "chartex";
 * const data = [
 *  { key: "A", value: 10, style: "#" },
 *  { key: "B", value: 20, style: "*" },
 *  { key: "C", value: 15, style: "+" },
 * ];
 * const options = { radius: 4, left: 2, innerRadius: 1 };
 * const chart = renderDonutChart(data, options);
 * console.log(chart);
 * ```
 */
const renderDonutChart = (
  data: PieChartDatum[],
  options?: PieChartOptions
): string => renderPieChart(data, options, true);

export {
  renderPieChart,
  renderDonutChart,
};
