/**
 * F003-charts — Sparkline Chart Renderer
 *
 * Grid-based sparkline with linear interpolation between points.
 */
open Types
open Terminal
open Options
open ChartValidation
open ChartPadding

type sparkPoint = {x: int, y: int, style: string}

let make = (data: array<'data>, ~config: sparklineConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data
  let _ = switch data->Array.length == 0 {
    | true => JsError.throwWithMessage("Error: Sparkline chart requires at least one data point")
    | false => ()
  }

  let options: option<sparklineOptions> = opts

  let charWidth = options->getOpt(o => o.width, width()->Option.getOr(80))
  let charHeight = options->getOpt(o => o.height, height()->Option.getOr(24))
  let tolerance = options->getOpt(o => o.tolerance, 2)
  let globalStyle = options->getOpt(o => o.style, "*")
  let yAxisChar = options->getOpt(o => o.yAxisChar, "|")

  let values = data->Array.map(config.value)
  let len = data->Array.length

  let minVal = values->Array.reduce(1e308, (a, v) => if v < a { v } else { a })
  let maxVal = values->Array.reduce(-1e308, (a, v) => if v > a { v } else { a })

  // Guard: NaN or Infinity values
  ensureFinite(minVal, "Error: Sparkline chart data contains NaN values", "Error: Sparkline chart data contains infinite values")
  ensureFinite(maxVal, "Error: Sparkline chart data contains NaN values", "Error: Sparkline chart data contains infinite values")

  // Handle degenerate case: all values identical
  let effectiveMin = switch maxVal == minVal {
  | true => minVal -. 1.0  // Shift min down by 1 to create a usable range
  | false => minVal
  }
  let effectiveMax = switch maxVal == minVal {
  | true => maxVal +. 1.0  // Shift max up by 1
  | false => maxVal
  }

  let scale = switch maxVal == minVal {
  | true => 1.0
  | false => (charHeight - 1)->Int.toFloat /. (effectiveMax -. effectiveMin)
  }

  // Build points list manually (avoid mapWithIndex)
  let points = Array.make(~length=len, {x: 0, y: 0, style: " "})
  let idx = ref(0)
  data->Array.forEach(d => {
    let i = idx.contents
    idx := i + 1
    let xPos = if len > 1 {
      (i->Int.toFloat /. (len - 1)->Int.toFloat *. (charWidth - 1)->Int.toFloat)->Math.round->Float.toInt
    } else { 0 }
    let yPos = charHeight - 1 - ((d->config.value -. effectiveMin) *. scale)->Math.round->Float.toInt
    let pStyle = switch config.style { | Some(st) => st(d) | None => globalStyle }
    points[i] = {x: xPos, y: yPos, style: pStyle}
  })

  // Build grid
  let grid = Array.make(~length=charHeight, [])
  for i in 0 to charHeight - 1 { grid[i] = Array.make(~length=charWidth, " ") }

  let setCell = (y: int, x: int, s: string): unit => {
    if y >= 0 && y < charHeight && x >= 0 && x < charWidth {
      switch grid[y] { | Some(row) => row[x] = s | None => () }
    }
  }

  // Plot points and interpolate
  for i in 0 to len - 2 {
    switch (points[i], points[i + 1]) {
    | (Some(a), Some(b)) =>
      setCell(a.y, a.x, a.style)
      let dx = b.x - a.x
      let dy = b.y - a.y
      let gap = Math.Int.abs(dx) + Math.Int.abs(dy)
      if gap > tolerance {
        let steps = max(Math.Int.abs(dx), Math.Int.abs(dy))
        for t in 1 to steps - 1 {
          let x = Math.round(a.x->Int.toFloat +. dx->Int.toFloat *. t->Int.toFloat /. steps->Int.toFloat)->Float.toInt
          let y = Math.round(a.y->Int.toFloat +. dy->Int.toFloat *. t->Int.toFloat /. steps->Int.toFloat)->Float.toInt
          setCell(y, x, a.style)
        }
      }
    | _ => ()
    }
  }
  switch points[len - 1] { | Some(p) => setCell(p.y, p.x, p.style) | None => () }

  // Y-axis labels
  let yRange = Math.abs(effectiveMax -. effectiveMin)
  let yDecimals = if yRange < 1.0 { 2 } else if yRange < 10.0 { 1 } else { 0 }
  let formatY = (val: float, dec: int): string =>
    if dec == 0 { Math.round(val)->Float.toInt->Int.toString }
    else if dec == 1 { (Math.round(val *. 10.0) /. 10.0)->Float.toString }
    else { (Math.round(val *. 100.0) /. 100.0)->Float.toString }

  let yLabels = Array.make(~length=charHeight, "")
  for i in 0 to charHeight - 1 {
    let yValue = if charHeight > 1 {
      effectiveMax -. i->Int.toFloat *. (effectiveMax -. effectiveMin) /. (charHeight - 1)->Int.toFloat
    } else { effectiveMin }
    yLabels[i] = formatY(yValue, yDecimals)
  }

  let yAxisWidth = ref(0)
  for i in 0 to charHeight - 1 {
    switch yLabels[i] { | Some(l) => { let llen = l->String.length; if llen > yAxisWidth.contents { yAxisWidth := llen } } | None => () }
  }

  let result = ref("")
  for i in 0 to charHeight - 1 {
    if i > 0 { result := result.contents ++ "\n" }
    let label = switch yLabels[i] { | Some(l) => l | None => "?" }
    result := result.contents ++ padStart(label, yAxisWidth.contents, " ") ++ " " ++ yAxisChar ++ " "
    switch grid[i] { | Some(row) => result := result.contents ++ Js.Array.joinWith("", row) | None => () }
  }

  result.contents
}
