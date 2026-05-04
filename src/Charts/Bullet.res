/**
 * F003-charts — Bullet Chart Renderer
 *
 * Horizontal bullet chart with width-proportional bars.
 */
open Types
open Terminal
open Options
open ChartValidation
open ChartPadding

let make = (data: array<'data>, ~config: bulletConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data
  let _ = switch data->Array.length == 0 {
    | true => JsError.throwWithMessage("Error: Bullet chart requires at least one data point")
    | false => ()
  }

  let options: option<bulletOptions> = opts

  let barWidth = options->getOpt(o => o.barWidth, 1)
  let style = options->getOpt(o => o.style, "*")
  let left = options->getOpt(o => o.left, 1)
  let charWidth = options->getOpt(o => o.width, max(10, width()->Option.getOr(80) * 6 / 10))
  let padding = options->getOpt(o => o.padding, 1)

  let values = data->Array.map(config.value)
  let maxVal = values->Array.reduce(-1.0e308, (acc, v) => if v > acc { v } else { acc })

  // Guard: NaN or Infinity in values
  ensureNoNaN(values, "Error: Bullet chart data contains NaN values")
  ensureNoInfinite(values, "Error: Bullet chart data contains infinite values")

  // Guard: negative values are not supported (bullet charts require positive values)
  ensureNoNegative(values, "Error: Bullet chart does not support negative values. Filter out negative values before rendering.")

  // Guard: all-zero values
  ensureAtLeastOnePositive(maxVal, "Error: Bullet chart requires at least one positive value to render")

  let maxKeyLength = data->Array.reduce(0, (acc, item) => {
    let label = item->config.key ++ " [" ++ item->config.value->Float.toString ++ "]"
    let len = label->String.length
    if len > acc { len } else { acc }
  })

  let result = ref(Js.String.repeat(left, " "))
  let lastIdx = data->Array.length - 1
  let idx = ref(0)

  data->Array.forEach(item => {
    let i = idx.contents
    idx := i + 1
    let val = item->config.value
    let ratioLen = (charWidth->Int.toFloat *. val /. maxVal)->Math.round->Float.toInt
    let padChar = switch config.style {
    | Some(st) => st(item)
    | None => style
    }
    let key = item->config.key
    let label = key ++ " [" ++ val->Float.toString ++ "]"
    result := result.contents ++ padStart(label, maxKeyLength, " ") ++ " "

    let currentBarWidth = switch config.barWidth {
    | Some(bw) => bw(item)
    | None => barWidth
    }

    for j in 0 to currentBarWidth - 1 {
      let offset = if j == 0 {
        Js.String.repeat(ratioLen, padChar) ++ "\n" ++ Js.String.repeat(left, " ")
      } else {
        Js.String.repeat(maxKeyLength + 1, " ") ++ Js.String.repeat(ratioLen, padChar) ++ "\n" ++ Js.String.repeat(left, " ")
      }
      result := result.contents ++ offset
    }

    if i != lastIdx {
      result := result.contents ++ Js.String.repeat(padding, "\n") ++ Js.String.repeat(left, " ")
    }
  })

  result.contents
}
