import { bg, fg } from "./utils/utils.ts";
import { renderBarChart } from "./bar.ts";
import { renderBulletChart } from "./bullet.ts";
import { renderDonutChart } from "./pie.ts";
import { renderGaugeChart } from "./gauge.ts";
import { renderScatterPlot } from "./scatter.ts";
import { renderPieChart } from "./pie.ts";

import {
  type BackgroundColor,
  type BarChartDatum,
  type BarChartOptions,
  type BulletChartOptions,
  type BulletChartDatum,
  type GaugeChartOptions,
  type GaugeChartDatum,
  type PieChartOptions,
  type PieChartDatum,
  type ScatterPlotDatum,
  type ScatterPlotOptions,
} from "./types/types.ts";

export {
  type BackgroundColor,
  bg,
  renderBarChart,
  renderBulletChart,
  renderDonutChart,
  renderGaugeChart,
  renderPieChart,
  renderScatterPlot,
  fg,
  type BarChartDatum,
  type BarChartOptions,
  type BulletChartOptions,
  type BulletChartDatum,
  type GaugeChartOptions,
  type GaugeChartDatum,
  type PieChartOptions,
  type PieChartDatum,
  type ScatterPlotDatum,
  type ScatterPlotOptions,
};
