import { padMid, verifyData, PAD, EOL } from "../utils/utils.ts";
import type { GaugeChartDatum, GaugeChartOptions } from "../types/types.ts";

/**
 * Creates a gauge chart to display a single value as a semi-circular meter
 * @param data - The data array containing one item with key and value
 * @param opts - Configuration options for the gauge
 * @returns The formatted gauge chart string
 */
const gauge = (data: GaugeChartDatum[], opts?: GaugeChartOptions): string => {
  verifyData(data);

  const newOpts: Required<GaugeChartOptions> = {
    radius: 5,
    left: 2,
    style: "# ",
    bgStyle: "+ ",
    ...opts,
  };

  const { radius, left, style, bgStyle } = newOpts;
  const [firstDataItem] = data;

  let result = PAD.repeat(left);

  // Generate the semi-circular gauge
  for (let i = -radius; i < 0; i++) {
    for (let j = -radius; j < radius; j++) {
      const isWithinCircle = Math.pow(i, 2) + Math.pow(j, 2) < Math.pow(radius, 2);

      if (isWithinCircle) {
        const isOuterRing = Math.abs(i) > 2 || Math.abs(j) > 2;

        if (isOuterRing) {
          const tmp = Math.atan2(i, j) * 1 / Math.PI + 1;
          result += tmp <= firstDataItem.value
            ? (firstDataItem.style ?? style)
            : bgStyle;
        } else {
          // Display percentage value at the center
          if (j === 0 && i === -1) {
            result += Math.round(firstDataItem.value * 100);
            continue;
          }

          result += PAD.repeat(2);
        }
      } else {
        result += PAD.repeat(2);
      }
    }

    result += `${EOL}${PAD.repeat(left)}`;
  }

  // Add the scale labels and key
  result += `${PAD.repeat(radius - 2)}0${PAD.repeat(radius - 4)}${padMid(firstDataItem.key, 11)}${PAD.repeat(radius - 4)}100`;

  return result;
};

export default gauge;
