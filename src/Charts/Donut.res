/**
 * F003-charts — Donut Chart Renderer
 *
 * Thin wrapper that delegates to Pie.make with an inner radius
 * to create the hollow center. Automatically defaults innerRadius
 * to radius/2 if not specified or zero.
 */
open Types
open Options

let make = (data: array<'data>, ~config: donutConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data (explicit check with message instead of assert)
  let _ = switch data->Array.length == 0 {
  | true => JsError.throwWithMessage("Error: Donut chart requires at least one data point")
  | false => ()
  }

  let options: option<donutOptions> = opts

  let radius = options->getOpt(o => o.radius, 10)
  let left = options->getOpt(o => o.left, 0)
  let innerRadius = options->getOpt(o => o.innerRadius, 4)

  // If innerRadius is 0, default to radius / 2
  let effectiveInnerRadius = if innerRadius == 0 { radius / 2 } else { innerRadius }

  // Convert donutConfig to pieConfig (they have the same shape)
  let pieCfg: pieConfig<'data> = {
    key: config.key,
    value: config.value,
    style: ?config.style,
  }

  let pieOpts: pieOptions = {
    radius: radius,
    left: left,
    innerRadius: effectiveInnerRadius,
  }

  Pie.make(data, ~config=pieCfg, ~options=pieOpts, ())
}
