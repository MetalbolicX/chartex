import {
  EOL,
  getShellHeight,
  PAD,
  padMid,
  verifyData,
} from "../utils/utils.ts";
import type { BarChartDatum, BarChartOptions } from "../types/types.ts";

/**
 * Creates a vertical bar chart with bars representing data values
 * @param data - The data array for the bar chart
 * @param opts - Configuration options for the chart
 * @param opts.barWidth - Width of each bar (default: 3)
 * @param opts.left - Left offset position (default: 1)
 * @param opts.height - Height of the chart (default: 40% of terminal height)
 * @param opts.padding - Padding between bars (default: 3)
 * @param opts.style - Default style for bars (default: "*")
 * @returns The formatted bar chart string
 * @example
 * ```typescript
 * const barData = [
 *   { key: "A", value: 10, style: "*" },
 *   { key: "B", value: 20, style: "#" },
 *   { key: "C", value: 15, style: "+" },
 * ];
 * const chart = bar(barData, { height: 10 });
 * console.log(chart);
 * // Outputs a vertical bar chart with the specified data and options
 * ```
 */
const bar = (data: BarChartDatum[], opts?: BarChartOptions): string => {
  verifyData(data);

  // Dynamically calculate width and height if not provided
  const shellHeight = getShellHeight();

  const newOpts: Required<BarChartOptions> = {
    barWidth: 3,
    left: 1,
    height: Math.max(6, Math.floor(shellHeight * 0.4)),
    padding: 3,
    style: "*",
    ...opts,
  };

  const { barWidth, left, height, padding, style } = newOpts;

  let result = PAD.repeat(left);

  const values = data.map((item) => item.value);
  const max = Math.max(...values);
  const { length } = data;

  // Generate vertical bar chart
  for (let i = 0; i < height + 2; i++) {
    for (let j = 0; j < length; j++) {
      const item = data[j];
      const valStr = item.value.toString();
      const ratio = height - (height * item.value) / max;

      const padChar =
        ratio > i + 2
          ? PAD
          : Math.round(ratio) === i
          ? valStr
          : Math.round(ratio) < i
          ? item.style ?? style
          : PAD;

      // Handle value display
      if (padChar === valStr) {
        result += `${padMid(valStr, barWidth)}${PAD.repeat(padding)}`;
        continue;
      }

      // Handle bar body and labels
      if (i !== height + 1) {
        result += `${padChar.repeat(barWidth)}${PAD.repeat(padding)}`;
      } else {
        // Display key labels at the bottom
        const keyDisplay =
          item.key.length > barWidth
            ? item.key.padEnd(barWidth + padding)
            : `${padMid(item.key, barWidth)}${PAD.repeat(padding)}`;
        result += keyDisplay;
      }
    }

    // Add line break (except for the last row)
    if (i !== height + 1) {
      result += `${EOL}${PAD.repeat(left)}`;
    }
  }

  return result;
};

export default bar;
