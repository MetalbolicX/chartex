/**
 * F003-charts — Bar Chart Renderer
 *
 * Vertical bar chart with ratio-based column height.
 */
open Types
open Terminal
open Options

let make = (data: array<'data>, ~config: barConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data
  let _ = switch data->Array.length == 0 {
    | true => JsError.throwWithMessage("Error: Bar chart requires at least one data point")
    | false => ()
  }

  let options: option<barOptions> = opts

  let barWidth = options->getOpt(o => o.barWidth, 3)
  let left = options->getOpt(o => o.left, 1)
  let chartHeight = options->getOpt(o => o.height, max(6, height()->Option.getOr(24) * 4 / 10))
  let padding = options->getOpt(o => o.padding, 3)
  let style = options->getOpt(o => o.style, "*")

  let values = data->Array.map(config.value)
  let maxVal = values->Array.reduce(-1.0e308, (acc, v) => if v > acc { v } else { acc })

  // Guard: NaN or Infinity in values
  let hasNaN = values->Array.some(v => Float.isNaN(v))
  let hasInf = values->Array.some(v => !Float.isFinite(v))
  let _ = switch hasNaN {
  | true => JsError.throwWithMessage("Error: Bar chart data contains NaN values")
  | false => ()
  }
  let _ = switch hasInf {
  | true => JsError.throwWithMessage("Error: Bar chart data contains infinite values")
  | false => ()
  }

  // Guard: negative values are not supported (bar charts require positive values)
  let hasNegative = values->Array.some(v => v < 0.0)
  let _ = switch hasNegative {
  | true => JsError.throwWithMessage("Error: Bar chart does not support negative values. Filter out negative values before rendering.")
  | false => ()
  }

  // Guard: all-zero values
  let _ = switch maxVal <= 0.0 {
  | true => JsError.throwWithMessage("Error: Bar chart requires at least one positive value to render")
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