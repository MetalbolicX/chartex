import {
  EOL,
  getOriginLen,
  curBack,
  curDown,
  curForward,
  curUp,
  PAD,
  verifyData,
} from "./utils/utils.ts";
import type { ScatterPlotOptions, ScatterPlotDatum } from "./types/types.ts";

type BoxType = "coordinate" | "data";

/**
 * Prints a box with specified dimensions and style.
 * @param width - The width of the box.
 * @param height - The height of the box.
 * @param style - The style string to fill the box with.
 * @param left - The left offset position.
 * @param top - The top offset position.
 * @param type - The type of box (coordinate or data).
 * @returns The formatted box string.
 */
const printBox = (
  width: number,
  height: number,
  style: string = "# ",
  left: number = 0,
  top: number = 0,
  type: BoxType = "coordinate"
): string => {
  let result = curForward(left) + curUp(top);
  const hasSide = width > 1 || height > 1;

  for (let i = 0; i < height; i++) {
    for (let j = 0; j < width; j++) {
      result += style;
    }

    if (hasSide) {
      if (i !== height - 1) {
        result += EOL + curForward(left);
      } else {
        result += EOL;
      }
    }
  }

  if (type === "data") {
    result += curDown(hasSide ? (top - height) : top) +
              curBack(left + getOriginLen(style));
  }

  return result;
};

/**
 * Creates a scatter plot chart from the provided data.
 * @param data - Array of scatter plot data items.
 * @param options - Configuration options for the scatter plot.
 * @returns The formatted scatter plot string.
 * @throws TypeError if data is invalid.
 */
const renderScatterPlot = (
  data: ScatterPlotDatum[],
  options: ScatterPlotOptions = {}
): string => {
  verifyData(data);

  const newOpts = {
    width: 10,
    left: 2,
    height: 10,
    style: "# ",
    sides: [1, 1] as [number, number],
    hAxis: ["+", "-", ">"] as [string, string, string],
    vAxis: ["|", "A"] as [string, string],
    hName: "X Axis",
    vName: "Y Axis",
    zero: "+",
    ratio: [1, 1] as [number, number],
    hGap: 2,
    vGap: 2,
    legendGap: 0,
    ...options
  };

  const {
    left, height, style, sides, width, zero, hAxis, vAxis, ratio,
    hName, vName, hGap, vGap, legendGap
  } = newOpts;

  let tmp: string;
  let result = "";
  const styles = data.map(item => item.style || style);
  const allSides = data.map(item => item.sides || sides);
  const keys = new Set(data.map(item => item.key));

  // Calculate min/max values for proper scaling
  const xValues = data.map(item => item.value[0]);
  const yValues = data.map(item => item.value[1]);
  const minX = Math.min(...xValues);
  const maxX = Math.max(...xValues);
  const minY = Math.min(...yValues);
  const maxY = Math.max(...yValues);

  result += PAD.repeat(left) + vName;
  result += PAD.repeat(legendGap);
  result += Array.from(keys)
    .map(key => `${key}: ${data.find(item => item.key === key)?.style || style}`)
    .join(" | ") + EOL.repeat(2);

  result += printBox(width + left, height + 1, PAD.repeat(2));

  // Render data points with proper scaling
  data.forEach((item, index) => {
    // Scale the coordinates to fit within the chart dimensions
    const scaledX = Math.round(((item.value[0] - minX) / (maxX - minX)) * width);
    const scaledY = Math.round(((item.value[1] - minY) / (maxY - minY)) * height);

    result += printBox(
      allSides[index][0],
      allSides[index][1],
      styles[index],
      scaledX * 2 + left + 1,
      height - scaledY, // Invert Y coordinate (0 at bottom)
      "data"
    );
  });

  result += curBack(width * 2) + curUp(height + 1) +
            PAD.repeat(left + 1) + vAxis[1];

  for (let i = 0; i < height + 1; i++) {
    tmp = ((height - i) % vGap === 0 && i !== height)
      ? Math.round(minY + ((height - i) / height) * (maxY - minY)).toString()
      : "";
    result += EOL + tmp.padStart(left + 1) + vAxis[0];
  }

  result += curBack() + zero + curDown(1) + curBack(1) + minX.toString() + curUp(1);

  for (let i = 1; i < (width * 2) + hGap; i++) {
    if (!(i % (hGap * 2))) {
      result += hAxis[0];

      // Draw scale of horizontal axis with proper scaling
      const scaleValue = Math.round(minX + ((i / 2) / width) * (maxX - minX));
      const len = scaleValue.toString().length;

      result += curDown(1) + curBack(1) + scaleValue + curUp(1);
      if (len > 1) {
        result += curBack(len - 1);
      }

      continue;
    }

    result += hAxis[1];
  }

  result += hAxis[2] + PAD + hName + EOL;

  return result;
};

export { renderScatterPlot };
