import pie from "./pie.ts";
import type { DonutChartOptions, DonutChartDatum } from "../types/types.ts";

/**
 * Creates a donut chart by calling the pie function with donut flag enabled
 * @param data - The data array for the donut chart
 * @param opts - Configuration options for the chart
 * @returns The formatted donut chart string
 */
const donut = (data: DonutChartDatum[], opts?: DonutChartOptions): string => pie(data, opts, true);

export default donut;
