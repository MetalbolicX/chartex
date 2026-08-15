/**
 * F003-charts — Pie Chart Renderer
 *
 * 2D circular grid with atan2 angle-based segment assignment.
 */
open Types
open Terminal
open Options
open ChartValidation
open CircularChart

let make = (data: array<'data>, ~config: pieConfig<'data>, ~options as opts=?, ()): string => {
  ensureNonEmpty(data, "Pie")

  let options: option<pieOptions> = opts

  let radius = options->getOpt(o => o.radius, max(4, height()->Option.getOr(24) * 4 / 10))
  let left = options->getOpt(o => o.left, 0)
  let innerRadius = options->getOpt(o => o.innerRadius, 0)

  let values = data->Array.map(config.value)

  let styles = applyStyles(data, ~defaultStyles=defaultPieStyles, ~styleFn=config.style)

  values->Array.forEach(v =>
    ensureFinite(
      v,
      "Error: Pie chart data contains NaN values",
      "Error: Pie chart data contains infinite values",
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
        let isOuter = Math.Int.abs(i) > innerRadius || Math.Int.abs(j) > innerRadius

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
