/**
 * F003-charts — Bullet Chart Renderer
 *
 * Horizontal bullet chart with width-proportional bars.
 */
open Types
open Terminal

let make = (data: array<'data>, ~config: bulletConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data
  let _ = switch data->Array.length == 0 {
    | true => JsError.throwWithMessage("Error: Bullet chart requires at least one data point")
    | false => ()
  }

  let options: option<bulletOptions> = opts

  let barWidth = switch options {
  | Some(o) => o.barWidth->Option.getOr(1)
  | None => 1
  }
  let style = switch options {
  | Some(o) => o.style->Option.getOr("*")
  | None => "*"
  }
  let left = switch options {
  | Some(o) => o.left->Option.getOr(1)
  | None => 1
  }
  let charWidth = switch options {
  | Some(o) => o.width->Option.getOr(max(10, width()->Option.getOr(80) * 6 / 10))
  | None => max(10, width()->Option.getOr(80) * 6 / 10)
  }
  let padding = switch options {
  | Some(o) => o.padding->Option.getOr(1)
  | None => 1
  }

let values = data->Array.map(config.value)
  let maxVal = values->Array.reduce(-1.0e308, (acc, v) => if v > acc { v } else { acc })

  // Guard: NaN or Infinity in values
  let hasNaN = values->Array.some(v => Float.isNaN(v))
  let hasInf = values->Array.some(v => !Float.isFinite(v))
  let _ = switch hasNaN {
  | true => JsError.throwWithMessage("Error: Bullet chart data contains NaN values")
  | false => ()
  }
  let _ = switch hasInf {
  | true => JsError.throwWithMessage("Error: Bullet chart data contains infinite values")
  | false => ()
  }

  // Guard: negative values are not supported (bullet charts require positive values)
  let hasNegative = values->Array.some(v => v < 0.0)
  let _ = switch hasNegative {
  | true => JsError.throwWithMessage("Error: Bullet chart does not support negative values. Filter out negative values before rendering.")
  | false => ()
  }

  // Guard: all-zero values
  let _ = switch maxVal <= 0.0 {
  | true => JsError.throwWithMessage("Error: Bullet chart requires at least one positive value to render")
  | false => ()
  }

  let padStart = (str: string, len: int, ch: string): string => {
    let sl = str->String.length
    if sl >= len { str } else { Js.String.repeat(len - sl, ch) ++ str }
  }

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