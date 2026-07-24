/**
 * F003-charts — Bar Chart Renderer
 *
 * Vertical bar chart with ratio-based column height.
 */
open Types
open Terminal
open Options
open ChartValidation
open ChartPadding

let make = (data: array<'data>, ~config: barConfig<'data>, ~options as opts=?, ()): string => {
  ensureNonEmpty(data, "Bar")

  let options: option<barOptions> = opts

  let barWidth = options->getOpt(o => o.barWidth, 3)
  let left = options->getOpt(o => o.left, 1)
  let chartHeight = options->getOpt(o => o.height, max(6, height()->Option.getOr(24) * 4 / 10))
  let padding = options->getOpt(o => o.padding, 3)
  let style = options->getOpt(o => o.style, "*")

  let values = data->Array.map(config.value)
  let maxVal = values->Array.reduce(-1.0e308, (acc, v) => if v > acc { v } else { acc })

  values->Array.forEach(v =>
    ensureFinite(
      v,
      "Error: Bar chart data contains NaN values",
      "Error: Bar chart data contains infinite values",
    )
  )

  // Guard: negative values are not supported (bar charts require positive values)
  ensureNoNegative(values, "Error: Bar chart does not support negative values. Filter out negative values before rendering.")

  // Guard: all-zero values
  ensureAtLeastOnePositive(maxVal, "Error: Bar chart requires at least one positive value to render")

  let result = ref(Js.String.repeat(left, " "))

  for i in 0 to chartHeight + 1 {
    if i > 0 {
      result := result.contents ++ "\n" ++ Js.String.repeat(left, " ")
    }

    data->Array.forEach(item => {
      let key = item->config.key
      let visibleKeyLen = stripAnsi(key)->String.length
      let colWidth = max(barWidth, visibleKeyLen)
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
        result := result.contents ++ padMidVisual(valStr, colWidth, ~visibleLen=valStr->String.length, ()) ++ Js.String.repeat(padding, " ")
      } else if i != chartHeight + 1 {
        let barBodyRaw = Js.String.repeat(barWidth, padChar)
        result := result.contents ++ padMidVisual(barBodyRaw, colWidth, ~visibleLen=barWidth, ()) ++ Js.String.repeat(padding, " ")
      } else {
        result := result.contents ++ padMidVisual(key, colWidth, ~visibleLen=visibleKeyLen, ()) ++ Js.String.repeat(padding, " ")
      }
    })
  }

  result.contents
}
