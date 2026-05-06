/**
 * F003-charts — Gauge Chart Renderer
 *
 * Semi-circular gauge chart using atan2 for percentage-based fill.
 */
open Types
open Terminal
open Options
open ChartValidation
open ChartPadding

let make = (data: array<'data>, ~config: gaugeConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data
  let _ = switch data->Array.length == 0 {
    | true => JsError.throwWithMessage("Error: Gauge chart requires at least one data point")
    | false => ()
  }

  let options: option<gaugeOptions> = opts

  let radius = options->getOpt(o => o.radius, max(4, width()->Option.getOr(80) / 10))
  let left = options->getOpt(o => o.left, 0)
  let style = options->getOpt(o => o.style, "*")
  let bgStyle = options->getOpt(o => o.bgStyle, ".")
  let innerRadius = radius / 2
  let innerRadiusSq = innerRadius * innerRadius

  // Guard: data[0] exists
  let firstItem = switch data[0] {
  | Some(x) => x
  | None => JsError.throwWithMessage("Error: Gauge chart requires at least one data point")
  }

  let rawValue = firstItem->config.value

  // Guard: NaN or Infinity in value
  ensureFinite(rawValue, "Error: Gauge chart data contains NaN values", "Error: Gauge chart data contains infinite values")

  // Guard: value must be 0-100 range (gauge percentage)
  let _ = switch rawValue < 0.0 || rawValue > 100.0 {
  | true => JsError.throwWithMessage("Error: Gauge value must be between 0 and 100")
  | false => ()
  }

  let value = rawValue /. 100.0
  let key = firstItem->config.key
  let itemStyle = switch config.style {
  | Some(st) => st(firstItem)
  | None => style
  }

  let result = ref(Js.String.repeat(left, " "))

  for i in -radius to -1 {
    if i != -radius {
      result := result.contents ++ "\n" ++ Js.String.repeat(left, " ")
    }

    for j in -radius to radius - 1 {
      let distSq = i * i + j * j
      let radiusSq = radius * radius

      if distSq < radiusSq {
        let isOuterRing = distSq > innerRadiusSq

        if isOuterRing {
          let angle = Math.atan2(~y=i->Int.toFloat, ~x=j->Int.toFloat) /. Math.Constants.pi +. 1.0
          if angle <= value { result := result.contents ++ itemStyle ++ " " }
          else { result := result.contents ++ bgStyle ++ " " }
        } else {
          if j == 0 && i == -1 {
            let pct = Math.round(value *. 100.0)->Float.toInt
            let pctStr = pct->Int.toString
            /* Use Js.String.slice which maps to JS String.prototype.slice */
            let pctStr = Js.String.slice(~from=0, ~to_=2, pctStr)
            result := result.contents ++ pctStr
            if pctStr->String.length < 2 {
              result := result.contents ++ " "
            }
          } else {
            result := result.contents ++ "  "
          }
        }
      } else {
        result := result.contents ++ "  "
      }
    }
  }

  result := result.contents ++ "\n" ++ Js.String.repeat(left, " ")
  let gaugeWidth = 4 * radius
  let textContent = "0" ++ padMid(key, 11) ++ "100"
  let textWidth = 1 + 11 + 3
  let totalPadding = gaugeWidth - textWidth
  let leftPad = totalPadding / 2
  let rightPad = totalPadding - leftPad
  result := result.contents ++ Js.String.repeat(leftPad, " ") ++ textContent ++ Js.String.repeat(rightPad, " ")

  result.contents
}
