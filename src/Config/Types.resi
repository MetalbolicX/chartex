/**
 * F001-types — Public Type Definitions
 *
 * All shared types for the chartex library.
 */

// ─────────────────────────────────────────────────────────────
// Core shared types
// ─────────────────────────────────────────────────────────────

type backgroundColor =
  | Black
  | Red
  | Green
  | Yellow
  | Blue
  | Magenta
  | Cyan
  | White

type accessor<'data, 'result> = 'data => 'result

// ─────────────────────────────────────────────────────────────
// Bar chart
// ─────────────────────────────────────────────────────────────

type barConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

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

type bulletConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
  barWidth?: accessor<'data, int>,
}

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

type scatterConfig<'data> = {
  key: accessor<'data, string>,
  x: accessor<'data, float>,
  y: accessor<'data, float>,
  style?: accessor<'data, string>,
}

type scatterOptions = {
  width?: int,
  height?: int,
  style?: string,
  showLegend?: bool,
}

// ─────────────────────────────────────────────────────────────
// Gauge
// ─────────────────────────────────────────────────────────────

type gaugeConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

type gaugeOptions = {
  radius?: int,
  left?: int,
  style?: string,
  bgStyle?: string,
}

// ─────────────────────────────────────────────────────────────
// Pie
// ─────────────────────────────────────────────────────────────

type pieConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

type pieOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}

// ─────────────────────────────────────────────────────────────
// Donut
// ─────────────────────────────────────────────────────────────

type donutConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

type donutOptions = {
  radius?: int,
  left?: int,
  innerRadius?: int,
}

// ─────────────────────────────────────────────────────────────
// Sparkline
// ─────────────────────────────────────────────────────────────

type sparklineConfig<'data> = {
  key: accessor<'data, string>,
  value: accessor<'data, float>,
  style?: accessor<'data, string>,
}

type sparklineOptions = {
  width?: int,
  height?: int,
  style?: string,
  yAxisChar?: string,
  showLegend?: bool,
}
