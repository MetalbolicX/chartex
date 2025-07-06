import { createPieChart, type PieChartOptions, type PieDataItem } from "./pie.ts";

/**
 * Creates a donut chart visualization from the provided data.
 * @param data - Array of pie chart data items to visualize.
 * @param options - Configuration options for the donut chart appearance.
 * @returns A string representation of the donut chart.
 * @throws TypeError if data is invalid.
 */
const createDonutChart = (
  data: PieDataItem[],
  options?: PieChartOptions
): string => createPieChart(data, options, true);

export { createDonutChart };
