import { verifyData, PAD, maxKeyLen, EOL } from "../utils/utils.ts";
import type { PieChartOptions, PieChartDatum } from "../types/types.ts";

/**
 * Recursively determines the padding character based on styles and values
 * @param styles - Array of style characters
 * @param values - Array of normalized values
 * @param param - Parameter to compare against
 * @param gapChar - Default gap character
 * @returns The appropriate padding character
 */
const getPadChar = (styles: string[], values: number[], param: number, gapChar: string): string => {
  const [firstVal] = values;
  if (!values.length) return gapChar;
  return param <= firstVal
    ? styles[0]
    : getPadChar(styles.slice(1), values.slice(1), param - firstVal, gapChar);
};

/**
 * Creates a pie chart or donut chart
 * @param data - The data array for the chart
 * @param opts - Configuration options for the chart
 * @param isDonut - Whether to create a donut chart
 * @returns The formatted pie/donut chart string
 */
const pie = (data: PieChartDatum[], opts?: PieChartOptions, isDonut: boolean = false): string => {
  verifyData(data);

  const newOpts: Required<PieChartOptions> = {
    radius: 4,
    left: 0,
    innerRadius: 1,
    ...opts,
  };

  const { radius, left, innerRadius } = newOpts;

  let result = PAD.repeat(left);

  const values = data.map(item => item.value);
  const total = values.reduce((a, b) => a + b);
  const ratios = values.map(value => Number((value / total).toFixed(2)));
  const styles = data.map(item => item.style);
  const keys = data.map(item => item.key);
  const maxKeyLength = maxKeyLen(data);
  const limit = isDonut ? innerRadius : 0;
  const gapChar = styles.at(-1) ?? "";

  // Generate the pie/donut chart
  for (let i = -radius; i < radius; i++) {
    for (let j = -radius; j < radius; j++) {
      const isWithinCircle = Math.pow(i, 2) + Math.pow(j, 2) < Math.pow(radius, 2);

      if (isWithinCircle) {
        const tmp = Math.atan2(i, j) * 1 / Math.PI * 0.5 + 0.5;
        const isWithinInnerRadius = Math.abs(i) > limit || Math.abs(j) > limit;

        result += isDonut
          ? (isWithinInnerRadius ? getPadChar(styles, ratios, tmp, gapChar) : PAD.repeat(2))
          : getPadChar(styles, ratios, tmp, gapChar);
      } else {
        result += PAD.repeat(2);
      }
    }

    result += `${EOL}${PAD.repeat(left)}`;
  }

  result += `${EOL}${PAD.repeat(left)}`;

  // Generate legend
  const legend = styles.map((style, i) =>
    `${style}${PAD}${keys[i].padStart(maxKeyLength)}: ${values[i]}${PAD}(${(ratios[i] * 100).toFixed(0)}%)${EOL}${PAD.repeat(left)}`
  ).join("");

  result += legend;

  return result;
};

export default pie;
