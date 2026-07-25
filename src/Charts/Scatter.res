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

/**
 * Computes min/max for X and Y, validates finiteness.
 * Returns (minX, maxX, minY, maxY, xVals, yVals).
 */
let computeRanges = (data: array<'data>, ~config: scatterConfig<'data>): (float, float, float, float, array<float>, array<float>) => {
  let xVals = data->Array.map(config.x)
  let yVals = data->Array.map(config.y)

  let minX = xVals->Array.reduce(1e308, (a, v) => if v < a { v } else { a })
  let maxX = xVals->Array.reduce(-1e308, (a, v) => if v > a { v } else { a })
  let minY = yVals->Array.reduce(1e308, (a, v) => if v < a { v } else { a })
  let maxY = yVals->Array.reduce(-1e308, (a, v) => if v > a { v } else { a })

  // Guard: NaN or Infinity in computed ranges
  ensureFinite(minX, "Error: Scatter chart data contains NaN values", "Error: Scatter chart data contains infinite values")
  ensureFinite(maxX, "Error: Scatter chart data contains NaN values", "Error: Scatter chart data contains infinite values")
  ensureFinite(minY, "Error: Scatter chart data contains NaN values", "Error: Scatter chart data contains infinite values")
  ensureFinite(maxY, "Error: Scatter chart data contains NaN values", "Error: Scatter chart data contains infinite values")

  (minX, maxX, minY, maxY, xVals, yVals)
}

/**
 * Linear scale helper (local to module, not exported).
 */
let linearScale = (value: float, min: float, max: float, outMin: float, outMax: float): float =>
  if min == max { outMin } else {
    if Float.isNaN(value) || Float.isNaN(min) || Float.isNaN(max) { outMin }
    else if !Float.isFinite(value) || !Float.isFinite(min) || !Float.isFinite(max) { outMin }
    else { outMin +. (value -. min) /. (max -. min) *. (outMax -. outMin) }
  }

/**
 * Builds the grid array given data, ranges, and style accessors.
 * Returns the populated grid (array of arrays of chars).
 */
let buildGrid = (
  data: array<'data>,
  ~config: scatterConfig<'data>,
  ~minX: float, ~maxX: float, ~minY: float, ~maxY: float,
  ~charWidth: int, ~charHeight: int,
  ~seriesIndexMap: dict<int>, ~globalStyle: string,
): array<array<string>> => {
  let defaultStyles = ["*", "#", "+", "o", ".", "x", "@"]
  let defaultStylesLen = Array.length(defaultStyles)

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

  let yScale = switch maxY == minY {
  | true => 1.0
  | false => (charHeight - 1)->Int.toFloat /. (maxY -. minY)
  }

  let grid = Array.make(~length=charHeight, [])
  for i in 0 to charHeight - 1 { grid[i] = Array.make(~length=charWidth, " ") }
  data->Array.forEach(d => {
    let xCol = linearScale(d->config.x, minX, maxX, 0.0, (charWidth - 1)->Int.toFloat)->Math.round->Float.toInt
    let yRow = charHeight - 1 - ((d->config.y -. minY) *. yScale)->Math.round->Float.toInt
    let pStyle = switch config.style { | Some(st) => st(d) | None => getSeriesStyle(config.key(d)) }
    if yRow >= 0 && yRow < charHeight && xCol >= 0 && xCol < charWidth {
      switch grid[yRow] { | Some(row) => row[xCol] = pStyle | None => () }
    }
  })

  grid
}

/**
 * Formats a Y-axis label value with decimal rounding and trailing-zero stripping.
 */
let formatYAxisLabel = (val: float, dec: int): string => {
  let factor = switch dec {
    | 0 => 1.0
    | 1 => 10.0
    | _ => 100.0
  }
  // Round-half-away-from-zero: floor for positive, ceil for negative
  let rounded = if val < 0.0 {
    Js.Math.ceil(val *. factor -. 0.5) -> Int.toFloat /. factor
  } else {
    Js.Math.floor(val *. factor +. 0.5) -> Int.toFloat /. factor
  }
  let s = dec == 0
    ? Float.toInt(rounded)->Int.toString
    : rounded->Float.toString
  // Strip trailing zeros
  let s = if s->String.includes(".") {
    let parts = s->String.split(".")
    switch parts[0] {
    | Some(intPart) => {
        switch parts[1] {
        | Some(fracPart) => {
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

/**
 * Renders the chart body: Y-axis labels + grid rows.
 * Returns the assembled chart string up to (but not including) the X-axis line.
 */
let renderAxes = (
  ~grid: array<array<string>>,
  ~yLabels: array<string>,
  ~yAxisWidth: int,
  ~charHeight: int,
): string => {
  let result = ref("")
  for i in 0 to charHeight - 1 {
    if i > 0 { result := result.contents ++ "\n" }
    let label = switch yLabels[i] { | Some(l) => l | None => "?" }
    result := result.contents ++ padStart(label, yAxisWidth, " ") ++ " | "
    switch grid[i] { | Some(row) => result := result.contents ++ Js.Array.joinWith("", row) | None => () }
  }
  result.contents
}

/**
 * Renders the X-axis line and value labels.
 * Appends to the input string.
 */
let renderXAxis = (
  ~result: string,
  ~minX: float, ~maxX: float,
  ~yAxisWidth: int,
  ~charWidth: int,
): string => {
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

  result ++ "\n" ++ Js.String.repeat(yAxisWidth + 3, " ") ++ xAxisLine ++ "\n" ++ Js.String.repeat(yAxisWidth + 3, " ") ++ Js.Array.joinWith("", xRow)
}

/**
 * Renders the legend block, appending to the input string.
 * Returns the string with legend appended (or unchanged if legend is hidden).
 */
let renderLegend = (
  ~result: string,
  ~numSeries: int,
  ~seriesNameArr: array<string>,
  ~legendStyleArr: array<string>,
  ~globalStyle: string,
  ~showLegend: bool,
  ~yAxisWidth: int,
): string => {
  if showLegend && numSeries > 0 {
    let legendParts = Array.make(~length=numSeries, "")
    for i in 0 to numSeries - 1 {
      let name = switch seriesNameArr[i] { | Some(n) => n | None => "" }
      let styleChar = switch legendStyleArr[i] { | Some(s) => s | None => globalStyle }
      legendParts[i] = `${name}: ${styleChar}`
    }
    let legendLine = Js.Array.joinWith("   ", legendParts)
    result ++ "\n" ++ Js.String.repeat(yAxisWidth + 3, " ") ++ legendLine
  } else {
    result
  }
}

// ─── Public API ───────────────────────────────────────────────────────────────

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

  // Collect series: seriesIndexMap is needed later for buildGrid style lookup
  let seriesCount = ref(0)
  let seriesIndexMap: dict<int> = Dict.make()
  let seriesNameArr: array<string> = Array.make(~length=Array.length(data), "")
  data->Array.forEach(d => {
    let name = config.key(d)
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

  // Round-robin default styles (used for legend style chars)
  let defaultStyles = ["*", "#", "+", "o", ".", "x", "@"]
  let defaultStylesLen = Array.length(defaultStyles)

  // Legend style chars: first data point per series
  let legendStyleArr: array<string> = Array.make(~length=numSeries, globalStyle)
  let legendStyleSet: dict<bool> = Dict.make()
  data->Array.forEach(d => {
    let name = config.key(d)
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

  // Compute ranges
  let (minX, maxX, minY, maxY, _xVals, _yVals) = computeRanges(data, ~config)

  // Build grid
  let grid = buildGrid(
    data, ~config,
    ~minX, ~maxX, ~minY, ~maxY,
    ~charWidth, ~charHeight,
    ~seriesIndexMap, ~globalStyle,
  )

  // Format Y-axis labels
  let yRange = Math.abs(maxY -. minY)
  let yDecimals = if yRange < 1.0 { 2 } else if yRange < 10.0 { 1 } else { 0 }
  let yLabels = Array.make(~length=charHeight, "")
  for i in 0 to charHeight - 1 {
    let yValue = if charHeight > 1 {
      maxY -. i->Int.toFloat *. (maxY -. minY) /. (charHeight - 1)->Int.toFloat
    } else { minY }
    yLabels[i] = formatYAxisLabel(yValue, yDecimals)
  }

  let yAxisWidth = ref(0)
  for i in 0 to charHeight - 1 {
    switch yLabels[i] { | Some(l) => { let len = l->String.length; if len > yAxisWidth.contents { yAxisWidth := len } } | None => () }
  }

  // Render axes
  let result = renderAxes(~grid, ~yLabels, ~yAxisWidth=yAxisWidth.contents, ~charHeight)

  // Render X-axis
  let result = renderXAxis(
    ~result, ~minX, ~maxX, ~yAxisWidth=yAxisWidth.contents, ~charWidth,
  )

  // Render legend
  renderLegend(
    ~result, ~numSeries, ~seriesNameArr, ~legendStyleArr,
    ~globalStyle, ~showLegend, ~yAxisWidth=yAxisWidth.contents,
  )
}
