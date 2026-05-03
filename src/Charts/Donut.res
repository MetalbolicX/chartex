/**
 * F003-charts — Donut Chart Renderer
 *
 * Thin wrapper that delegates to Pie.make with an inner radius
 * to create the hollow center. Automatically defaults innerRadius
 * to radius/2 if not specified or zero.
 */
open Types

let make = (data: array<'data>, ~config: donutConfig<'data>, ~options as opts=?, ()): string => {
  assert(data->Array.length > 0)

  let defaultRadius = 10
  let defaultLeft = 0
  let defaultInnerRadius = 4

  let options: option<donutOptions> = opts

  let radius = switch options {
  | Some(o) => o.radius->Option.getOr(defaultRadius)
  | None => defaultRadius
  }
  let left = switch options {
  | Some(o) => o.left->Option.getOr(defaultLeft)
  | None => defaultLeft
  }
  let innerRadius = switch options {
  | Some(o) => o.innerRadius->Option.getOr(defaultInnerRadius)
  | None => defaultInnerRadius
  }

  // If innerRadius is 0, default to radius / 2
  let effectiveInnerRadius = if innerRadius == 0 { radius / 2 } else { innerRadius }

  // Convert donutConfig to pieConfig (they have the same shape)
  let pieCfg: pieConfig<'data> = {
    key: config.key,
    value: config.value,
    style: config.style,
  }

  let pieOpts: pieOptions = {
    radius: radius,
    left: left,
    innerRadius: effectiveInnerRadius,
  }

  Pie.make(data, ~config=pieCfg, ~options=pieOpts, ())
}
