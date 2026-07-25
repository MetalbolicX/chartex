/**
 * F003-charts — Circular Chart Shared Logic
 */
open ChartPadding

let defaultPieStyles = ["●", "○", "◆", "◇", "■", "□"]
let defaultDonutStyles = ["● ", "○ ", "◆ ", "◇ ", "■ ", "□ "]

let applyStyles = (
  data: array<'data>,
  ~defaultStyles: array<string>,
  ~styleFn: option<('data) => string>,
): array<string> => {
  let dataLen = data->Array.length
  switch styleFn {
  | Some(fn) => data->Array.map(fn)
  | None =>
    let defaultStylesLen = Array.length(defaultStyles)
    let arr = Array.make(~length=dataLen, "●")
    for i in 0 to dataLen - 1 {
      let styleIdx = i % defaultStylesLen
      switch defaultStyles[styleIdx] {
      | Some(s) => arr[i] = s
      | None => arr[i] = "●"
      }
    }
    arr
  }
}

let computeTotals = (
  data: array<'data>,
  ~getKey: 'data => string,
  ~getValue: 'data => float,
  ~styles: array<string>,
): (float, array<float>, array<string>, int, string) => {
  let dataLen = data->Array.length
  let values = data->Array.map(getValue)
  let keys = data->Array.map(getKey)
  let total = values->Array.reduce(0.0, (a, b) => a +. b)

  let maxKeyLength = data->Array.reduce(0, (acc, item) => {
    let l = item->getKey->String.length
    if l > acc { l } else { acc }
  })

  let ratios = total == 0.0
    ? data->Array.map(_ => 1.0 /. dataLen->Int.toFloat)
    : data->Array.map(item => item->getValue /. total)

  let gapChar = switch styles[dataLen - 1] { | Some(s) => s | None => " " }

  (total, ratios, keys, maxKeyLength, gapChar)
}

let getPadChar = (
  styles: array<string>,
  vals: array<float>,
  param: float,
  gap: string,
): string => {
  let rec go = (styles, vals, param, gap) => {
    if styles->Array.length == 0 || vals->Array.length == 0 { gap }
    else {
      let firstVal = switch vals[0] { | Some(v) => v | None => 0.0 }
      let firstStyle = switch styles[0] { | Some(s) => s | None => gap }
      if param <= firstVal { firstStyle }
      else {
        go(
          Js.Array.sliceFrom(1, styles),
          Js.Array.sliceFrom(1, vals),
          param -. firstVal,
          gap,
        )
      }
    }
  }
  go(styles, vals, param, gap)
}

let legendRow = (
  ~styleChar: string,
  ~key: string,
  ~val: float,
  ~pct: float,
  ~maxKeyLength: int,
  ~left: int,
  ~isLast: bool,
): string => {
  let line = styleChar ++ " " ++ padStart(key, maxKeyLength, " ") ++ ": " ++ val->Float.toString ++ " (" ++ Math.round(pct)->Float.toInt->Int.toString ++ "%)"
  if isLast { line } else { line ++ "\n" ++ Js.String.repeat(left, " ") }
}

let legend = (
  data: array<'data>,
  ~getValue: 'data => float,
  ~styles: array<string>,
  ~keys: array<string>,
  ~total: float,
  ~maxKeyLength: int,
  ~left: int,
): string => {
  let dataLen = data->Array.length
  let idx = ref(0)
  let result = ref("")
  data->Array.forEach(item => {
    let i = idx.contents
    idx := i + 1
    let styleChar = switch styles[i] { | Some(s) => s | None => "?" }
    let key = switch keys[i] { | Some(k) => k | None => "?" }
    let val = item->getValue
    let pct = if total == 0.0 { 0.0 } else { val /. total *. 100.0 }
    let isLast = i == dataLen - 1
    result := result.contents ++ legendRow(
      ~styleChar,
      ~key,
      ~val,
      ~pct,
      ~maxKeyLength,
      ~left,
      ~isLast,
    )
  })
  result.contents
}
