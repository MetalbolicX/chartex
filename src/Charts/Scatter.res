/**
 * F003-charts — Scatter Plot Renderer
 *
 * 2D scatter chart using grid-based rendering with axes.
 * Supports multiple series with auto-assigned styles and an optional legend.
 */
open Types
open Terminal
open Options
open ChartValidation
open ChartPadding

let make = (data: array<'data>, ~config: scatterConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data
  let _ = switch data->Array.length == 0 {
    | true => JsError.throwWithMessage("Error: Scatter chart requires at least one data point")
    | false => ()
  }

  let options: option<scatterOptions> = opts

  let defaultWidth = switch width() {
    | Some(w) => max(10, Float.toInt(Int.toFloat(w) *. 0.6))
    | None => 48
    }
  let defaultHeight = switch height() {
    | Some(h) => max(8, Float.toInt(Int.toFloat(h) *. 0.3))
    | None => 8
    }
  let charWidth = options->getOpt(o => o.width, defaultWidth)
  let charHeight = options->getOpt(o => o.height, defaultHeight)
  let globalStyle = options->getOpt(o => o.style, "*")
  let showLegend = options->getOpt(o => o.showLegend, true)

  // Collect unique series names in order of first occurrence.
  // seriesIndexMap: series name → insertion index (used for round-robin style lookup).
  // seriesNameArr: ordered series names (index → name).
  let seriesCount = ref(0)
  let seriesIndexMap: dict<int> = Dict.make()
  let seriesNameArr: array<string> = Array.make(~length=Array.length(data), "")
  data->Array.forEach(d => {
    let name = config.series(d)
    switch Dict.get(seriesIndexMap, name) {
    | None =>
      let idx = seriesCount.contents
      Dict.set(seriesIndexMap, name, idx)
      seriesNameArr[idx] = name
      seriesCount := idx + 1
    | Some(_) => ()
    }
  })
  let numSeries = seriesCount.contents

  // Round-robin default styles assigned by series insertion order.
  let defaultStyles = ["*", "#", "+", "o", ".", "x", "@"]
  let defaultStylesLen = Array.length(defaultStyles)

  // Returns the round-robin style char for a series name.
  let getSeriesStyle = (seriesName: string): string =>
    switch Dict.get(seriesIndexMap, seriesName) {
    | Some(idx) => {
        let styleIdx = idx - defaultStylesLen * (idx / defaultStylesLen)
        switch defaultStyles[styleIdx] {
        | Some(s) => s
        | None => globalStyle
        }
      }
    | None => globalStyle
    }

  // Build legend style chars: first data point per series determines the legend char.
  // If config.style is provided, its value for the first point wins.
  // Otherwise, the round-robin series default is used.
  let legendStyleArr: array<string> = Array.make(~length=numSeries, globalStyle)
  let legendStyleSet: dict<bool> = Dict.make()
  data->Array.forEach(d => {
    let name = config.series(d)
    switch Dict.get(legendStyleSet, name) {
    | None =>
      switch Dict.get(seriesIndexMap, name) {
      | Some(idx) =>
        let styleChar = switch config.style {
        | Some(st) => st(d)
        | None => {
            let styleIdx = idx - defaultStylesLen * (idx / defaultStylesLen)
            switch defaultStyles[styleIdx] {
            | Some(s) => s
            | None => globalStyle
            }
          }
        }
        legendStyleArr[idx] = styleChar
        Dict.set(legendStyleSet, name, true)
      | None => ()
      }
    | Some(_) => ()
    }
  })

  let linearScale = (value: float, min: float, max: float, outMin: float, outMax: float): float =>
    if min == max { outMin } else {
      // Guard: NaN/Infinity in input
      if Float.isNaN(value) || Float.isNaN(min) || Float.isNaN(max) { outMin }
      else if !Float.isFinite(value) || !Float.isFinite(min) || !Float.isFinite(max) { outMin }
      else { outMin +. (value -. min) /. (max -. min) *. (outMax -. outMin) }
    }

  let xVals = data->Array.map(config.x)
  let yVals = data->Array.map(config.y)

  // Single-pass min+max for xVals and yVals (4 reduce calls → 2)
  let minX = xVals->Array.reduce(1e308, (a, v) => if v < a { v } else { a })
  let maxX = xVals->Array.reduce(-1e308, (a, v) => if v > a { v } else { a })
  let minY = yVals->Array.reduce(1e308, (a, v) => if v < a { v } else { a })
  let maxY = yVals->Array.reduce(-1e308, (a, v) => if v > a { v } else { a })

  // Guard: NaN or Infinity in computed ranges
  ensureFinite(minX, "Error: Scatter chart data contains NaN values", "Error: Scatter chart data contains infinite values")
  ensureFinite(maxX, "Error: Scatter chart data contains NaN values", "Error: Scatter chart data contains infinite values")
  ensureFinite(minY, "Error: Scatter chart data contains NaN values", "Error: Scatter chart data contains infinite values")
  ensureFinite(maxY, "Error: Scatter chart data contains NaN values", "Error: Scatter chart data contains infinite values")

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
    // Per-point style overrides series default when config.style is provided.
    let pStyle = switch config.style { | Some(st) => st(d) | None => getSeriesStyle(config.series(d)) }
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

  // Legend: one entry per series — "{seriesName}: {styleChar}", separated by 3 spaces.
  if showLegend && numSeries > 0 {
    let legendParts = Array.make(~length=numSeries, "")
    for i in 0 to numSeries - 1 {
      let name = switch seriesNameArr[i] { | Some(n) => n | None => "" }
      let styleChar = switch legendStyleArr[i] { | Some(s) => s | None => globalStyle }
      legendParts[i] = `${name}: ${styleChar}`
    }
    let legendLine = Js.Array.joinWith("   ", legendParts)
    result := result.contents ++ "\n" ++ Js.String.repeat(yAxisWidth.contents + 3, " ") ++ legendLine
  }

  result.contents
}
