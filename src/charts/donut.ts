import pie from "./pie.ts";
import type { DonutChartOptions, DonutChartDatum } from "../types/types.ts";

/**
 * Creates a donut chart by calling the pie function with donut flag enabled
 * @param data - The data array for the donut chart
 * @param opts - Configuration options for the chart
 * @param opts.radius - Radius of the donut chart (default: 50% of terminal width)
 * @param opts.left - Left offset position (default: 1)
 * @param opts.innerRadius - Inner radius for the donut hole (default: 0)
 * @returns The formatted donut chart string
 * @example
 * ```typescript
 * const donutData = [
 *   { key: "A", value: 10, style: "*" },
 *   { key: "B", value: 20, style: "#" },
 *   { key: "C", value: 30, style: "-" },
 * ];
 * const chart = donut(donutData, { radius: 15, innerRadius: 5 });
 * console.log(chart);
 * // Outputs a donut chart with the specified data and options
 * ```
 */
const donut = (data: DonutChartDatum[], opts?: DonutChartOptions): string => pie(data, opts, true);

export default donut;
