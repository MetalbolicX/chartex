/**
 * F003-charts — Donut Chart Renderer
 *
 * 2D circular grid with atan2 angle-based segment assignment.
 * Uses circular inner radius masking to ensure complete 360° arcs.
 */
open Types
open Options
open ChartValidation
open CircularChart

let make = (data: array<'data>, ~config: donutConfig<'data>, ~options as opts=?, ()): string => {
  ensureNonEmpty(data, "Donut")

  let options: option<donutOptions> = opts

  let radius = options->getOpt(o => o.radius, 10)
  let left = options->getOpt(o => o.left, 0)
  let innerRadius = options->getOpt(o => o.innerRadius, 4)

  // If innerRadius is 0, default to radius / 2
  let effectiveInnerRadius = if innerRadius == 0 { radius / 2 } else { innerRadius }

  let values = data->Array.map(config.value)

  let styles = applyStyles(data, ~defaultStyles=defaultDonutStyles, ~styleFn=config.style)

  values->Array.forEach(v =>
    ensureFinite(
      v,
      "Error: Donut chart data contains NaN values",
      "Error: Donut chart data contains infinite values",
    )
  )

  let (total, ratios, keys, maxKeyLength, gapChar) = computeTotals(
    data,
    ~getKey=config.key,
    ~getValue=config.value,
    ~styles,
  )

  let result = ref("")

  for i in -radius to radius - 1 {
    if i != -radius {
      result := result.contents ++ "\n" ++ Js.String.repeat(left, " ")
    } else {
      result := Js.String.repeat(left, " ")
    }

    for j in -radius to radius - 1 {
      let distSq = i * i + j * j
      let radiusSq = radius * radius

      if distSq < radiusSq {
        let angle = Math.atan2(~y=i->Int.toFloat, ~x=j->Int.toFloat) /. Math.Constants.pi *. 0.5 +. 0.5
        let normalizedAngle = if angle < 0.0 { angle +. 1.0 } else { angle }
        let innerRadiusSq = effectiveInnerRadius * effectiveInnerRadius
        let isOuter = distSq > innerRadiusSq

        if isOuter {
          result := result.contents ++ getPadChar(styles, ratios, normalizedAngle, gapChar)
        } else {
          result := result.contents ++ "  "
        }
      } else {
        result := result.contents ++ "  "
      }
    }
  }

  result := result.contents ++ "\n\n" ++ Js.String.repeat(left, " ")

  result := result.contents ++ legend(
    data,
    ~getValue=config.value,
    ~styles,
    ~keys,
    ~total,
    ~maxKeyLength,
    ~left,
  )

  result.contents
}
