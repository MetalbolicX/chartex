import {
  PAD,
  verifyData,
  padMid,
  EOL,
} from "./utils/utils.ts";

import type { GaugeChartDatum, GaugeChartOptions } from "./types/types.ts";

/**
 * Creates a gauge chart visualization from the provided data.
 * @param data - Array containing a single gauge data item to visualize.
 * @param options - Configuration options for the gauge chart appearance.
 * @returns A string representation of the gauge chart.
 * @throws TypeError if data is invalid or contains more than one item.
 * @example
 * ```typescript
 * import { renderGaugeChart } from "chartex";
 * const data = [{ key: "Speed", value: 0.75, style: "#" }];
 * const options = { radius: 5, left: 2, style: "# ", bgStyle: "+ " };
 * const chart = renderGaugeChart(data, options);
 * console.log(chart);
 * ```
 */
const renderGaugeChart = (
  data: GaugeChartDatum[],
  options?: GaugeChartOptions
): string => {
  verifyData(data);

  if (data.length !== 1) {
    throw new TypeError("Gauge chart requires exactly one data item");
  }

  const chartOptions: Required<GaugeChartOptions> = {
    radius: 5,
    left: 2,
    style: "# ",
    bgStyle: "+ ",
    ...options,
  };

  const { radius, left, style, bgStyle } = chartOptions;
  const [gaugeData] = data;

  let result = PAD.repeat(left);

  // Generate the semicircular gauge visualization
  result += generateGaugeVisualization(
    radius,
    left,
    gaugeData,
    style,
    bgStyle
  );

  // Add the bottom scale and label
  result += generateGaugeScale(radius, gaugeData.key);

  return result;
};

/**
 * Generates the visual representation of the gauge chart.
 * @param radius - The radius of the gauge.
 * @param left - Left padding amount.
 * @param gaugeData - The gauge data item.
 * @param defaultStyle - Default style character for filled areas.
 * @param backgroundStyle - Style character for unfilled areas.
 * @returns The formatted gauge visualization string.
 */
const generateGaugeVisualization = (
  radius: number,
  left: number,
  gaugeData: GaugeChartDatum,
  defaultStyle: string,
  backgroundStyle: string
): string => {
  let visualization = "";

  for (let rowIndex = -radius; rowIndex < 0; rowIndex++) {
    for (let columnIndex = -radius; columnIndex < radius; columnIndex++) {
      const distanceFromCenter = Math.pow(rowIndex, 2) + Math.pow(columnIndex, 2);
      const radiusSquared = Math.pow(radius, 2);

      if (distanceFromCenter < radiusSquared) {
        const shouldShowCenterArea = Math.abs(rowIndex) <= 2 && Math.abs(columnIndex) <= 2;

        if (shouldShowCenterArea) {
          visualization += generateCenterContent(
            rowIndex,
            columnIndex,
            gaugeData.value
          );
        } else {
          visualization += generateGaugeSegment(
            rowIndex,
            columnIndex,
            gaugeData,
            defaultStyle,
            backgroundStyle
          );
        }
      } else {
        visualization += PAD.repeat(2);
      }
    }

    visualization += `${EOL}${PAD.repeat(left)}`;
  }

  return visualization;
};

/**
 * Generates content for the center area of the gauge.
 * @param rowIndex - Current row position.
 * @param columnIndex - Current column position.
 * @param value - The gauge value (0-1).
 * @returns The appropriate content for the center position.
 */
const generateCenterContent = (
  rowIndex: number,
  columnIndex: number,
  value: number
): string => {
  const isPercentagePosition = columnIndex === 0 && rowIndex === -1;

  return isPercentagePosition
    ? Math.round(value * 100).toString()
    : PAD.repeat(2);
};

/**
 * Generates a gauge segment based on the current position and value.
 * @param rowIndex - Current row position.
 * @param columnIndex - Current column position.
 * @param gaugeData - The gauge data item.
 * @param defaultStyle - Default style character for filled areas.
 * @param backgroundStyle - Style character for unfilled areas.
 * @returns The appropriate style character for this segment.
 */
const generateGaugeSegment = (
  rowIndex: number,
  columnIndex: number,
  gaugeData: GaugeChartDatum,
  defaultStyle: string,
  backgroundStyle: string
): string => {
  const angleParameter = Math.atan2(rowIndex, columnIndex) * (1 / Math.PI) + 1;
  const shouldFillSegment = angleParameter <= gaugeData.value;

  return shouldFillSegment
    ? (gaugeData.style || defaultStyle)
    : backgroundStyle;
};

/**
 * Generates the bottom scale and label for the gauge.
 * @param radius - The radius of the gauge.
 * @param label - The label text to display.
 * @returns The formatted scale string.
 */
const generateGaugeScale = (radius: number, label: string): string => {
  const leftPadding = PAD.repeat(radius - 2);
  const centerLabel = padMid(label, 11);
  const rightPadding = PAD.repeat(radius - 4);

  return `${leftPadding}0${PAD.repeat(radius - 4)}${centerLabel}${rightPadding}100`;
};

export { renderGaugeChart };
