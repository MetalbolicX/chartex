import {
  bg,
  fg,
  parseCategoricalData,
  parseFromObject,
  parseCustomData,
  parseScatterData,
  parseList,
} from "./utils/utils.ts";
import bar from "./charts/bar.ts";
import bullet from "./charts/bullet.ts";
import donut from "./charts/donut.ts";
import gauge from "./charts/gauge.ts";
import pie from "./charts/pie.ts";
import scatter from "./charts/scatter.ts";
import sparkline from "./charts/sparkline.ts";

import type {
  BackgroundColor,
  BarChartDatum,
  BarChartOptions,
  BulletChartDatum,
  BulletChartOptions,
  ChartDatum,
  DonutChartDatum,
  DonutChartOptions,
  GaugeChartDatum,
  GaugeChartOptions,
  PieChartDatum,
  PieChartOptions,
  ScatterPlotDatum,
  ScatterPlotOptions,
  SparklineDatum,
  SparklineOptions,
} from "./types/types.ts";

export {
  bar,
  bg,
  bullet,
  donut,
  fg,
  gauge,
  pie,
  scatter,
  sparkline,
  parseCategoricalData,
  parseCustomData,
  parseFromObject,
  parseScatterData,
  parseList,
  type BackgroundColor,
  type BarChartDatum,
  type BarChartOptions,
  type BulletChartDatum,
  type BulletChartOptions,
  type ChartDatum,
  type DonutChartDatum,
  type DonutChartOptions,
  type GaugeChartDatum,
  type GaugeChartOptions,
  type PieChartDatum,
  type PieChartOptions,
  type ScatterPlotDatum,
  type ScatterPlotOptions,
  type SparklineDatum,
  type SparklineOptions,
};
