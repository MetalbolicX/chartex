/**
 * F003-charts — Gauge Chart Renderer
 *
 * Semi-circular gauge chart using atan2 for percentage-based fill.
 */
open Types
open Terminal

let make = (data: array<'data>, ~config: gaugeConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data
  let _ = switch data->Array.length == 0 {
    | true => JsError.throwWithMessage("Error: Gauge chart requires at least one data point")
    | false => ()
  }

  let options: option<gaugeOptions> = opts

  let radius = switch options {
  | Some(o) => o.radius->Option.getOr(max(4, width()->Option.getOr(80) / 10))
  | None => max(4, width()->Option.getOr(80) / 10)
  }
  let left = switch options {
  | Some(o) => o.left->Option.getOr(0)
  | None => 0
  }
  let style = switch options {
  | Some(o) => o.style->Option.getOr("*")
  | None => "*"
  }
  let bgStyle = switch options {
  | Some(o) => o.bgStyle->Option.getOr(".")
  | None => "."
  }

  // Guard: data[0] exists
  let firstItem = switch data[0] {
    | Some(x) => x
    | None => JsError.throwWithMessage("Error: Gauge chart requires at least one data point")
  }

  let rawValue = firstItem->config.value

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
        let isOuterRing = Math.Int.abs(i) > 2 || Math.Int.abs(j) > 2

        if isOuterRing {
          let angle = Math.atan2(~y=i->Int.toFloat, ~x=j->Int.toFloat) /. Math.Constants.pi +. 1.0
          if angle <= value { result := result.contents ++ itemStyle }
          else { result := result.contents ++ bgStyle }
        } else {
          if j == 0 && i == -1 {
            let pct = Math.round(value *. 100.0)->Float.toInt
            let pctStr = pct->Int.toString
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

  let padMid = (str: string, width: int): string => {
    let sLen = str->String.length
    if sLen >= width { str } else {
      let totalPad = width - sLen
      let leftPad = totalPad / 2
      let rightPad = totalPad - leftPad
      Js.String.repeat(leftPad, " ") ++ str ++ Js.String.repeat(rightPad, " ")
    }
  }

  result := result.contents ++ "\n" ++ Js.String.repeat(left, " ")
  result := result.contents ++ Js.String.repeat(radius - 2, " ") ++ "0" ++ Js.String.repeat(radius - 4, " ") ++ padMid(key, 11) ++ Js.String.repeat(radius - 4, " ") ++ "100"

  result.contents
}