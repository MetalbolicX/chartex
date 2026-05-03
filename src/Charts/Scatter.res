/**
 * F003-charts — Scatter Plot Renderer
 *
 * 2D scatter chart using grid-based rendering with axes.
 */
open Types
open Terminal

let make = (data: array<'data>, ~config: scatterConfig<'data>, ~options as opts=?, ()): string => {
  assert(data->Array.length > 0)
  let options: option<scatterOptions> = opts

  let defaultWidth = switch width() {
    | Some(w) => max(10, Float.toInt(Int.toFloat(w) *. 0.6))
    | None => 48
    }
  let defaultHeight = switch height() {
    | Some(h) => max(8, Float.toInt(Int.toFloat(h) *. 0.3))
    | None => 8
    }
  let charWidth = switch options {
  | Some(o) => o.width->Option.getOr(defaultWidth)
  | None => defaultWidth
  }
  let charHeight = switch options {
  | Some(o) => o.height->Option.getOr(defaultHeight)
  | None => defaultHeight
  }
  let globalStyle = switch options {
  | Some(o) => o.style->Option.getOr("*")
  | None => "*"
  }

  let linearScale = (value: float, min: float, max: float, outMin: float, outMax: float): float =>
    if min == max { outMin } else { outMin +. (value -. min) /. (max -. min) *. (outMax -. outMin) }

  let xVals = data->Array.map(config.x)
  let yVals = data->Array.map(config.y)

  let rec findMin = (arr: array<float>, i: int, cur: float): float =>
    switch arr[i] { | Some(v) => findMin(arr, i + 1, if v < cur { v } else { cur }) | None => cur }
  let rec findMax = (arr: array<float>, i: int, cur: float): float =>
    switch arr[i] { | Some(v) => findMax(arr, i + 1, if v > cur { v } else { cur }) | None => cur }

  let firstVal = switch xVals[0] { | Some(v) => v | None => 0.0 }
  let minX = findMin(xVals, 1, firstVal)
  let maxX = findMax(xVals, 1, firstVal)
  let firstYVal = switch yVals[0] { | Some(v) => v | None => 0.0 }
  let minY = findMin(yVals, 1, firstYVal)
  let maxY = findMax(yVals, 1, firstYVal)

  let yScale = switch maxY == minY {
  | true => 1.0
  | false => (charHeight - 1)->Int.toFloat /. (maxY -. minY)
  }

  // Build grid
  let grid = Array.make(~length=charHeight, [])
  for i in 0 to charHeight - 1 { grid[i] = Array.make(~length=charWidth, " ") }
  data->Array.forEach(d => {
    let xCol = linearScale(d->config.x, minX, maxX, 0.0, (charWidth - 1)->Int.toFloat)->Math.round->Float.toInt
    let yRow = charHeight - 1 - ((d->config.y -. minY) *. yScale)->Math.round->Float.toInt
    let pStyle = switch config.style { | Some(st) => st(d) | None => globalStyle }
    if yRow >= 0 && yRow < charHeight && xCol >= 0 && xCol < charWidth {
      switch grid[yRow] { | Some(row) => row[xCol] = pStyle | None => () }
    }
  })

  // Format y axis
  let yRange = Math.abs(maxY -. minY)
  let yDecimals = if yRange < 1.0 { 2 } else if yRange < 10.0 { 1 } else { 0 }
  // Mirrors TypeScript's toFixed-based rounding (round-half-away-from-zero):
  // val.toFixed(dec) uses round-half-away-from-zero, then regex-strips trailing zeros.
  // ReScript implementation: manual ceil/floor for half-away-from-zero, then strip
  // trailing zeros the same way TS does using string ops instead of regex.
  let formatY = (val: float, dec: int): string => {
    let factor = switch dec {
      | 0 => 1.0
      | 1 => 10.0
      | _ => 100.0
    }
    // Round-half-away-from-zero: floor for positive, ceil for negative (bias away from 0)
    let rounded = if val < 0.0 {
      Js.Math.ceil(val *. factor -. 0.5) -> Int.toFloat /. factor
    } else {
      Js.Math.floor(val *. factor +. 0.5) -> Int.toFloat /. factor
    }
    let s = dec == 0
      ? Float.toInt(rounded)->Int.toString
      : rounded->Float.toString
    // Strip trailing zeros the same way TS scatter.ts does:
    // /\.0+$/  → whole-number trailing .0 removed
    // (\.[1-9]*)0+$ → fractional trailing zeros removed, mantissa kept
    let s = if s->String.includes(".") {
      let parts = s->String.split(".")
      switch parts[0] {
      | Some(intPart) => {
          switch parts[1] {
          | Some(fracPart) => {
              // Strip trailing zeros from fractional part — reverse chars, drop leading '0's, re-reverse
              let charArr = fracPart->String.split("")
              let charLen = charArr->Array.length
              let rec findFirstNonZero = (i: int): int =>
                if i >= charLen { i }
                else if charArr[i] == Some("0") { findFirstNonZero(i + 1) }
                else { i }
              let firstNZ = findFirstNonZero(0)
              if firstNZ >= charLen { intPart } else {
                let rec collect = (j: int, acc: string): string =>
                  if j >= charLen { acc }
                  else {
                    let c = charArr[j]
                    switch c { | Some(cv) => collect(j + 1, acc ++ cv) | None => acc }
                  }
                let kept = collect(firstNZ, "")
                intPart ++ "." ++ kept
              }
            }
          | None => s
          }
        }
      | None => s
      }
    } else { s }
    s
  }

  let yLabels = Array.make(~length=charHeight, "")
  for i in 0 to charHeight - 1 {
    let yValue = if charHeight > 1 {
      maxY -. i->Int.toFloat *. (maxY -. minY) /. (charHeight - 1)->Int.toFloat
    } else { minY }
    yLabels[i] = formatY(yValue, yDecimals)
  }

  let padStart = (str: string, len: int, ch: string): string => {
    let sl = str->String.length
    if sl >= len { str } else { Js.String.repeat(len - sl, ch) ++ str }
  }

  let yAxisWidth = ref(0)
  for i in 0 to charHeight - 1 {
    switch yLabels[i] { | Some(l) => { let len = l->String.length; if len > yAxisWidth.contents { yAxisWidth := len } } | None => () }
  }

  let result = ref("")
  for i in 0 to charHeight - 1 {
    if i > 0 { result := result.contents ++ "\n" }
    let label = switch yLabels[i] { | Some(l) => l | None => "?" }
    result := result.contents ++ padStart(label, yAxisWidth.contents, " ") ++ " | "
    switch grid[i] { | Some(row) => result := result.contents ++ Js.Array.joinWith("", row) | None => () }
  }

  // X-axis
  let xAxisLine = Js.String.repeat(charWidth, "_")
  let minLabel = minX->Float.toString
  let maxLabel = maxX->Float.toString
  let midX = minX +. (maxX -. minX) /. 2.0
  let midLabel = if midX == Math.round(midX) {
    Math.round(midX)->Float.toInt->Int.toString
  } else {
    (Math.round(midX *. 10.0) /. 10.0)->Float.toString
  }

  let xRow = Array.make(~length=charWidth, " ")
  xRow[0] = minLabel
  let midPos = max(0, min(charWidth / 2 - midLabel->String.length / 2, charWidth - midLabel->String.length))
  xRow[midPos] = midLabel
  let maxPos = max(0, charWidth - maxLabel->String.length)
  xRow[maxPos] = maxLabel

  result := result.contents ++ "\n" ++ Js.String.repeat(yAxisWidth.contents + 3, " ") ++ xAxisLine ++ "\n" ++ Js.String.repeat(yAxisWidth.contents + 3, " ") ++ Js.Array.joinWith("", xRow)

  result.contents
}
