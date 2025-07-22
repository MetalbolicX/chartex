import { PAD, verifyData, EOL, getShellWidth } from "../utils/utils.ts";
import type { BulletChartDatum, BulletChartOptions } from "../types/types.ts";

/**
 * Creates a bullet chart with horizontal bars representing data values
 * @param data - The data array for the bullet chart
 * @param opts - Configuration options for the chart
 * @returns The formatted bullet chart string
 */
const bullet = (
  data: BulletChartDatum[],
  opts?: BulletChartOptions
): string => {
  verifyData(data);

  // Dynamically calculate width and height if not provided
  const shellWidth = getShellWidth();

  const newOpts: Required<BulletChartOptions> = {
    barWidth: 1,
    style: "*",
    left: 1,
    width: Math.max(10, Math.floor(shellWidth * 0.6)),
    padding: 1,
    ...opts,
  };

  const { barWidth, left, width, padding, style } = newOpts;

  let result = PAD.repeat(left);

  const values = data.map((item) => item.value);
  const max = Math.max(...values);
  const maxKeyLength = Math.max(
    ...data.map((item) => `${item.key} [${item.value}]`.length)
  );

  // Generate bullet chart bars
  data.forEach((item, index) => {
    const ratioLength = Math.round(width * (item.value / max));
    const padChar = item.style ?? style;
    const { key } = item;
    const line = `${padChar.repeat(ratioLength)}${EOL}${PAD.repeat(left)}`;

    result += `${`${key} [${item.value}]`.padStart(maxKeyLength)}${PAD}`;

    // Generate multiple bar lines based on barWidth
    const currentBarWidth = item.barWidth ?? barWidth;
    for (let j = 0; j < currentBarWidth; j++) {
      result += j > 0 ? `${PAD.repeat(maxKeyLength + 1)}${line}` : line;
    }

    // Add padding between items (except for the last item)
    if (index !== data.length - 1) {
      result += `${EOL.repeat(padding)}${PAD.repeat(left)}`;
    }
  });

  return result;
};

export default bullet;
