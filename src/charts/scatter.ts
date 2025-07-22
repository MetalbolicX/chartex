import {
  EOL,
  PAD,
  verifyData,
  curForward,
  curUp,
  curDown,
  curBack,
  getOriginLen,
  getShellWidth,
  getShellHeight,
} from "../utils/utils.ts";
import type { ScatterPlotDatum, ScatterPlotOptions } from "../types/types.ts";

/**
 * Box type for positioning
 */
type BoxType = "coordinate" | "data";

/**
 * Prints a box with specified dimensions and style
 * @param width - The width of the box
 * @param height - The height of the box
 * @param style - The style character for the box
 * @param left - Left offset position
 * @param top - Top offset position
 * @param type - Type of box
 * @returns The formatted box string
 */
const printBox = (
  width: number,
  height: number,
  style: string = "# ",
  left: number = 0,
  top: number = 0,
  type: BoxType = "coordinate"
): string => {
  let result = `${curForward(left)}${curUp(top)}`;
  const hasSide = width > 1 || height > 1;

  for (let i = 0; i < height; i++) {
    for (let j = 0; j < width; j++) {
      result += style;
    }

    if (hasSide) {
      result += i !== height - 1 ? `${EOL}${curForward(left)}` : EOL;
    }
  }

  if (type === "data") {
    result += `${curDown(hasSide ? top - height : top)}${curBack(
      left + getOriginLen(style)
    )}`;
  }

  return result;
};

const buildYAxis = ({
  width,
  height,
  left,
  vAxis,
  vGap,
  ratio,
  EOL,
  PAD,
}: {
  width: number;
  height: number;
  left: number;
  vAxis: [string, string];
  vGap: number;
  ratio: [number, number];
  EOL: string;
  PAD: string;
}): string => {
  let result = "";
  // Draw vertical axis arrow
  result += `${curBack(width * 2)}${curUp(height + 1)}${PAD.repeat(left + 1)}${
    vAxis[1]
  }`;
  // Draw vertical scale
  for (let i = 0; i < height + 1; i++) {
    const label =
      (height - i) % vGap === 0 && i !== height
        ? ((height - i) * ratio[1]).toString()
        : "";
    result += `${EOL}${label.padStart(left + 1)}${vAxis[0]}`;
  }
  return result;
};

/**
 * Builds the X axis, origin, and its scale
 */
const buildXAxis = ({
  width,
  // left,
  zero,
  hAxis,
  hGap,
  ratio,
  hName,
  EOL,
  PAD,
}: {
  width: number;
  // left: number;
  zero: string;
  hAxis: [string, string, string];
  hGap: number;
  ratio: [number, number];
  hName: string;
  EOL: string;
  PAD: string;
}): string => {
  let result = "";
  // Draw origin and horizontal axis
  result += `${curBack()}${zero}${curDown(1)}${curBack(1)}0${curUp(1)}`;
  // Draw horizontal scale
  for (let i = 1; i < width * 2 + hGap; i++) {
    if (!(i % (hGap * 2))) {
      result += hAxis[0];
      // Draw scale of horizontal axis
      const item = (i / 2) * ratio[0];
      const len = item.toString().length;
      result += `${curDown(1)}${curBack(1)}${item}${curUp(1)}`;
      if (len > 1) {
        result += curBack(len - 1);
      }
      continue;
    }
    result += hAxis[1];
  }
  result += `${hAxis[2]}${PAD}${hName}${EOL}`;
  return result;
};

/**
 * Creates a scatter plot chart
 * @param data - The data array for the scatter plot
 * @param opts - Configuration options for the chart
 * @returns The formatted scatter plot string
 */
const scatter = (
  data: ScatterPlotDatum[],
  opts?: ScatterPlotOptions
): string => {
  verifyData(data);

  // Dynamically calculate width and height if not provided
  const shellWidth = getShellWidth();
  const shellHeight = getShellHeight();

  const newOpts: Required<ScatterPlotOptions> = {
    width: Math.max(10, Math.floor(shellWidth * 0.4)),
    left: 2,
    height: Math.max(10, Math.floor(shellHeight * 0.4)),
    style: "# ",
    sides: [1, 1],
    hAxis: ["+", "-", ">"],
    vAxis: ["|", "A"],
    hName: "X Axis",
    vName: "Y Axis",
    zero: "+",
    ratio: [1, 1],
    hGap: 2,
    vGap: 2,
    legendGap: 0,
    ...opts,
  };

  const {
    left,
    height,
    style,
    sides,
    width,
    zero,
    hAxis,
    vAxis,
    ratio,
    hName,
    vName,
    hGap,
    vGap,
    legendGap,
  } = newOpts;

  let result = "";

  const styles = data.map((item) => item.style ?? style);
  const allSides = data.map((item) => item.sides ?? sides);
  const keys = new Set(data.map((item) => item.key));

  // Build legend
  result += `${PAD.repeat(left)}${vName}`;
  result += PAD.repeat(legendGap);
  result += `${Array.from(keys)
    .map(
      (key) =>
        `${key}: ${data.find((item) => item.key === key)?.style ?? style}`
    )
    .join(" | ")}${EOL.repeat(2)}`;

  // Print coordinate box
  result += printBox(width + left, height + 1, PAD.repeat(2));

  // Plot data points
  data.map((item, index) => {
    result += printBox(
      allSides[index][0],
      allSides[index][1],
      styles[index],
      item.value[0] * 2 + left + 1,
      item.value[1],
      "data"
    );
  });

  // Draw Y axis and scale
  result += buildYAxis({
    width,
    height,
    left,
    vAxis,
    vGap,
    ratio,
    EOL,
    PAD,
  });

  // Draw origin and X axis
  result += buildXAxis({
    width,
    // left,
    zero,
    hAxis,
    hGap,
    ratio,
    hName,
    EOL,
    PAD,
  });

  return result;
};

export default scatter;
