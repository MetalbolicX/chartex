import { createColoredBackground, createColoredText } from "./utils/utils.ts";
import { createBarChart } from "./bar.ts";
import { createScatterPlot } from "./scatter.ts";
import { createBulletChart } from "./bullet.ts";
import { createPieChart } from "./pie.ts";
import { createDonutChart } from "./pie.ts";
import { createGaugeChart } from "./gauge.ts";

import {
  type BackgroundColor,
  type ChartDataItem,
  type BarChartOptions,
  type BarChartDataItem,
  type BulletChartOptions,
  type BulletDataItem,
  type PieChartOptions,
  type PieDataItem,
  type GaugeChartOptions,
  type GaugeDataItem,
  type ScatterPlotOptions,
  type ScatterDataItem,
} from "./types/types.ts";

export {
  createColoredBackground,
  createColoredText,
  createBarChart,
  createScatterPlot,
  createBulletChart,
  createPieChart,
  createGaugeChart,
  createDonutChart,
  BackgroundColor,
  type ChartDataItem,
  type BarChartOptions,
  type BarChartDataItem,
  type BulletChartOptions,
  type BulletDataItem,
  type PieChartOptions,
  type PieDataItem,
  type GaugeChartOptions,
  type GaugeDataItem,
  type ScatterPlotOptions,
  type ScatterDataItem,
};
