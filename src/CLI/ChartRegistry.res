/**
 * ChartRegistry — Finite, module-local chart dispatch table
 *
 * Maps each categorical Bindings.Util.chartType variant to its render closure.
 * The config and options construction are closed over inside each entry's render fn.
 *
 * The registry is a finite array (not a dict) so the ReScript compiler
 * can exhaustively verify all chartType variants are covered.
 */

module Impl = {
  /**
   * Each entry is a render closure that already has the chart-specific config
   * and options construction baked in. All entries share the same type signature.
   */
  type chartEntry = (array<Adapter.categoricalDatum>, CliTypes.cliOptions) => string

  let barEntry: chartEntry = (rows, options) => {
    let config = ChartConfigs.barConfig()
    let chartOptions: Types.barOptions = {height: ?options.height}
    Bar.make(rows, ~config, ~options=chartOptions, ())
  }

  let sparklineEntry: chartEntry = (rows, options) => {
    let config = ChartConfigs.sparklineConfig()
    let chartOptions: Types.sparklineOptions = {width: ?options.width, height: ?options.height}
    Sparkline.make(rows, ~config, ~options=chartOptions, ())
  }

  let pieEntry: chartEntry = (rows, options) => {
    let config = ChartConfigs.pieConfig()
    let chartOptions: Types.pieOptions = {radius: ?options.height->Option.map(h => h * 2)}
    Pie.make(rows, ~config, ~options=chartOptions, ())
  }

  let donutEntry: chartEntry = (rows, options) => {
    let config = ChartConfigs.donutConfig()
    let chartOptions: Types.donutOptions = {radius: ?options.height->Option.map(h => h * 2)}
    Donut.make(rows, ~config, ~options=chartOptions, ())
  }

  let gaugeEntry: chartEntry = (rows, options) => {
    let config = ChartConfigs.gaugeConfig()
    let chartOptions: Types.gaugeOptions = {radius: ?options.height->Option.map(h => h / 2)}
    Gauge.make(rows, ~config, ~options=chartOptions, ())
  }

  let bulletEntry: chartEntry = (rows, options) => {
    let config = ChartConfigs.bulletConfig()
    let chartOptions: Types.bulletOptions = {width: ?options.width}
    Bullet.make(rows, ~config, ~options=chartOptions, ())
  }

  /**
   * Finite registry: array so the compiler can exhaustively check coverage.
   * Maps each chartType → its render closure.
   * #auto is handled at call sites (normalizes to #bar).
   */
  let chartRegistry: array<(Bindings.Util.chartType, chartEntry)> = [
    (#bar, barEntry),
    (#sparkline, sparklineEntry),
    (#pie, pieEntry),
    (#donut, donutEntry),
    (#gauge, gaugeEntry),
    (#bullet, bulletEntry),
  ]

  let findEntry = (chartType: Bindings.Util.chartType): option<chartEntry> => {
    chartRegistry->Array.find(((ct, _)) => ct == chartType)->Option.map(((_, entry)) => entry)
  }

  let renderCategorical = (rows: array<Adapter.categoricalDatum>, options: CliTypes.cliOptions): string => {
    let chartType = switch options.chartType {
    | #auto => #bar
    | other => other
    }
    switch findEntry(chartType) {
    | Some(entry) => entry(rows, options)
    | None => JsError.throwWithMessage("Internal error: Unhandled chart type")
    }
  }

  let renderScatter = (rows: array<Adapter.scatterDatum>, options: CliTypes.cliOptions): string => {
    let config = ChartConfigs.scatterConfig()
    Scatter.make(
      rows,
      ~config,
      ~options={
        width: ?options.width,
        height: ?options.height,
      },
      (),
    )
  }
}

let renderCategorical = Impl.renderCategorical
let renderScatter = Impl.renderScatter
