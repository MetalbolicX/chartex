/**
 * F003-charts — Bar Chart Renderer
 *
 * Vertical bar chart with ratio-based column height.
 */
open Types
open Terminal

let make = (data: array<'data>, ~config: barConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data
  let _ = switch data->Array.length == 0 {
    | true => JsError.throwWithMessage("Error: Bar chart requires at least one data point")
    | false => ()
  }

  let options: option<barOptions> = opts

  let barWidth = switch options {
  | Some(o) => o.barWidth->Option.getOr(3)
  | None => 3
  }
  let left = switch options {
  | Some(o) => o.left->Option.getOr(1)
  | None => 1
  }
  let chartHeight = switch options {
  | Some(o) => o.height->Option.getOr(max(6, height()->Option.getOr(24) * 4 / 10))
  | None => max(6, height()->Option.getOr(24) * 4 / 10)
  }
  let padding = switch options {
  | Some(o) => o.padding->Option.getOr(3)
  | None => 3
  }
  let style = switch options {
  | Some(o) => o.style->Option.getOr("*")
  | None => "*"
  }

  let values = data->Array.map(config.value)
  let maxVal = values->Array.reduce(-1.0e308, (acc, v) => if v > acc { v } else { acc })

  // Guard: all-negative or zero values
  let _ = switch maxVal <= 0.0 {
    | true => JsError.throwWithMessage("Error: Bar chart requires positive values")
    | false => ()
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

  let result = ref(Js.String.repeat(left, " "))

  for i in 0 to chartHeight + 1 {
    if i > 0 {
      result := result.contents ++ "\n" ++ Js.String.repeat(left, " ")
    }

    data->Array.forEach(item => {
      let val = item->config.value
      let valStr = val->Float.toString
      let ratio = chartHeight->Int.toFloat -. (chartHeight->Int.toFloat *. val /. maxVal)

      let padChar =
        if ratio > (i + 2)->Int.toFloat { " " }
        else if Math.round(ratio) == i->Int.toFloat { valStr }
        else if Math.round(ratio) < i->Int.toFloat {
          switch config.style {
          | Some(st) => st(item)
          | None => style
          }
        } else { " " }

      if padChar == valStr {
        result := result.contents ++ padMid(valStr, barWidth) ++ Js.String.repeat(padding, " ")
      } else if i != chartHeight + 1 {
        result := result.contents ++ Js.String.repeat(barWidth, padChar) ++ Js.String.repeat(padding, " ")
      } else {
        let key = item->config.key
        let keyDisplay =
          if key->String.length > barWidth { key ++ Js.String.repeat(padding, " ") }
          else { padMid(key, barWidth) ++ Js.String.repeat(padding, " ") }
        result := result.contents ++ keyDisplay
      }
    })
  }

  result.contents
}