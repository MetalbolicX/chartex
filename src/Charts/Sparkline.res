/**
 * F003-charts — Sparkline Chart Renderer
 *
 * Grid-based sparkline with linear interpolation between points.
 */
open Types
open Terminal

type sparkPoint = {x: int, y: int, style: string}

let make = (data: array<'data>, ~config: sparklineConfig<'data>, ~options as opts=?, ()): string => {
  assert(data->Array.length > 0)
  let options: option<sparklineOptions> = opts

  let charWidth = switch options {
  | Some(o) => o.width->Option.getOr(width()->Option.getOr(80))
  | None => width()->Option.getOr(80)
  }
  let charHeight = switch options {
  | Some(o) => o.height->Option.getOr(height()->Option.getOr(24))
  | None => height()->Option.getOr(24)
  }
  let tolerance = switch options {
  | Some(o) => o.tolerance->Option.getOr(2)
  | None => 2
  }
  let globalStyle = switch options {
  | Some(o) => o.style->Option.getOr("*")
  | None => "*"
  }
  let yAxisChar = switch options {
  | Some(o) => o.yAxisChar->Option.getOr("|")
  | None => "|"
  }

  let values = data->Array.map(config.value)
  let len = data->Array.length

  let minVal = values->Array.reduce(1e308, (a, v) => if v < a { v } else { a })
  let maxVal = values->Array.reduce(-1e308, (a, v) => if v > a { v } else { a })

  let scale = switch maxVal == minVal {
  | true => 1.0
  | false => (charHeight - 1)->Int.toFloat /. (maxVal -. minVal)
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
    let yPos = charHeight - 1 - ((d->config.value -. minVal) *. scale)->Math.round->Float.toInt
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
  let yRange = Math.abs(maxVal -. minVal)
  let yDecimals = if yRange < 1.0 { 2 } else if yRange < 10.0 { 1 } else { 0 }
  let formatY = (val: float, dec: int): string =>
    if dec == 0 { Math.round(val)->Float.toInt->Int.toString }
    else if dec == 1 { (Math.round(val *. 10.0) /. 10.0)->Float.toString }
    else { (Math.round(val *. 100.0) /. 100.0)->Float.toString }

  let yLabels = Array.make(~length=charHeight, "")
  for i in 0 to charHeight - 1 {
    let yValue = if charHeight > 1 {
      maxVal -. i->Int.toFloat *. (maxVal -. minVal) /. (charHeight - 1)->Int.toFloat
    } else { minVal }
    yLabels[i] = formatY(yValue, yDecimals)
  }

  let padStart = (str: string, targetLen: int, ch: string): string => {
    let sl = str->String.length
    if sl >= targetLen { str } else { Js.String.repeat(targetLen - sl, ch) ++ str }
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
