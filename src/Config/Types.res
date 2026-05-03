/**
 * F001-types — Shared Type System
 *
 * All shared type definitions for the chartex ReScript library.
 * Establishes the accessor-based configuration pattern, constrained color variant,
 * and per-chart options records.
 *
 * These types are used by:
 * - F002-core (backgroundColor in Ansi module)
 * - F003-charts (all chart config and options types)
 * - F004-barrel (re-exports all types)
 */

// ─────────────────────────────────────────────────────────────
// Core shared types
// ─────────────────────────────────────────────────────────────

/**
 * Terminal ANSI background color names.
 * Constrained to 8 valid values — invalid literals are rejected at compile time.
 *
 * Source: src/types/types.ts → BackgroundColor union
 */
type backgroundColor =
  | Black
  | Red
  | Green
  | Yellow
  | Blue
  | Magenta
  | Cyan
  | White

/**
 * Generic accessor function type for d3-style data extraction.
 * Represents a function that extracts a typed value from consumer data.
 *
 * Usage: `key: accessor<'data, string>` means "a function that takes 'data and returns string"
 */
type accessor<'data, 'result> = 'data => 'result

// ─────────────────────────────────────────────────────────────
// Bar chart
// ─────────────────────────────────────────────────────────────

/**
 * Configuration for bar chart data accessors.
 * - `key`: extracts the label/key string from data
 * - `value`: extracts the numeric value from data
 * - `style`: optional — extracts style character, defaults to "*" in Bar.make
 *
 * Source: src/types/types.ts → BarChartDatum + BarChartOptions
 */
type barConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

/**
 * Visual rendering options for bar chart.
 * All fields are optional with library-defined defaults.
 */
type barOptions = {
  barWidth?: int,
  left?: int,
  height?: int,
  padding?: int,
  style?: string,
}

// ─────────────────────────────────────────────────────────────
// Bullet chart
// ─────────────────────────────────────────────────────────────

/**
 * Configuration for bullet chart data accessors.
 * - `key`: extracts the label/key string from data
 * - `value`: extracts the numeric value from data
 * - `style`: optional style accessor
 * - `barWidth`: optional per-item bar width accessor
 *
 * Source: src/types/types.ts → BulletChartDatum + BulletChartOptions
 */
type bulletConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
  barWidth?: accessor<'data, int>,
}

/**
 * Visual rendering options for bullet chart.
 * All fields are optional with library-defined defaults.
 */
type bulletOptions = {
  barWidth?: int,
  style?: string,
  left?: int,
  width?: int,
  padding?: int,
}

// ─────────────────────────────────────────────────────────────
// Scatter plot
// ─────────────────────────────────────────────────────────────

/**
 * Configuration for scatter plot data accessors.
 * Uses SEPARATE x and y accessors (not a single value accessor).
 * `series` identifies which series a data point belongs to — used for
 * grouping, per-series style assignment, and legend rendering.
 *
 * Source: src/types/types.ts → ScatterChartDatum + ScatterChartOptions
 */
type scatterConfig<'data> = {
  series: accessor<'data, string>,
  x: accessor<'data, float>,
  y: accessor<'data, float>,
  style?: accessor<'data, string>,
}

/**
 * Visual rendering options for scatter plot.
 * `showLegend` defaults to true — renders series names and their style chars below the X-axis.
 */
type scatterOptions = {
  width?: int,
  height?: int,
  style?: string,
  showLegend?: bool,
}

// ─────────────────────────────────────────────────────────────
// Gauge
// ─────────────────────────────────────────────────────────────

/**
 * Configuration for gauge chart data accessors.
 * - `key`: extracts the label/key string from data
 * - `value`: extracts the percentage value (0.0–100.0)
 * - `style`: optional style accessor, defaults to "*" in Gauge.make
 *
 * Source: src/types/types.ts → GaugeChartDatum + GaugeChartOptions
 */
type gaugeConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

/**
 * Visual rendering options for gauge chart.
 */
type gaugeOptions = {
  radius?: int,
  left?: int,
  style?: string,
  bgStyle?: string,
}

// ─────────────────────────────────────────────────────────────
// Pie
// ─────────────────────────────────────────────────────────────

/**
 * Configuration for pie chart data accessors.
 * - `key`: extracts the segment label
 * - `value`: extracts the numeric value
 * - `style`: REQUIRED — no default fallback (unlike other charts)
 *
 * Source: src/types/types.ts → PieChartDatum + PieChartOptions
 */
type pieConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style: accessor<'data, string>,  // required — no default
}

/**
 * Visual rendering options for pie chart.
 */
type pieOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}

// ─────────────────────────────────────────────────────────────
// Donut
// ─────────────────────────────────────────────────────────────

/**
 * Configuration for donut chart data accessors.
 * - `key`: extracts the segment label
 * - `value`: extracts the numeric value
 * - `style`: REQUIRED — no default fallback (unlike other charts)
 *
 * Source: src/types/types.ts → DonutChartDatum + DonutChartOptions
 */
type donutConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style: accessor<'data, string>,  // required — no default
}

/**
 * Visual rendering options for donut chart.
 */
type donutOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}

// ─────────────────────────────────────────────────────────────
// Sparkline
// ─────────────────────────────────────────────────────────────

/**
 * Configuration for sparkline chart data accessors.
 * - `key`: extracts the label/key string
 * - `value`: extracts the numeric value
 * - `style`: optional style accessor, defaults to "*" in Sparkline.make
 *
 * Source: src/types/types.ts → SparklineChartDatum + SparklineChartOptions
 */
type sparklineConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

/**
 * Visual rendering options for sparkline chart.
 */
type sparklineOptions = {
  width?: int,
  height?: int,
  tolerance?: int,
  style?: string,
  yAxisChar?: string,
}