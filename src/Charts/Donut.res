/**
 * F003-charts — Donut Chart Renderer
 *
 * 2D circular grid with atan2 angle-based segment assignment.
 * Uses circular inner radius masking to ensure complete 360° arcs.
 */
open Types
open Options
open ChartValidation
open ChartPadding

let make = (data: array<'data>, ~config: donutConfig<'data>, ~options as opts=?, ()): string => {
  // Guard: empty data
  let _ = switch data->Array.length == 0 {
  | true => JsError.throwWithMessage("Error: Donut chart requires at least one data point")
  | false => ()
  }

  let options: option<donutOptions> = opts

  let radius = options->getOpt(o => o.radius, 10)
  let left = options->getOpt(o => o.left, 0)
  let innerRadius = options->getOpt(o => o.innerRadius, 4)

  // If innerRadius is 0, default to radius / 2
  let effectiveInnerRadius = if innerRadius == 0 { radius / 2 } else { innerRadius }

  let dataLen = data->Array.length
  let values = data->Array.map(config.value)

  // Handle optional style: use round-robin defaults if not provided
  let defaultStyles = ["●", "○", "◆", "◇", "■", "□"]
  let styles = switch config.style {
  | Some(styleFn) => data->Array.map(styleFn)
  | None =>
    // Round-robin assignment from default styles
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
  let keys = data->Array.map(config.key)
  let total = values->Array.reduce(0.0, (a, b) => a +. b)

  // Guard: NaN or Infinity in values or total
  ensureNoNaN(values, "Error: Donut chart data contains NaN values")
  ensureNoInfinite(values, "Error: Donut chart data contains infinite values")

  let maxKeyLength = data->Array.reduce(0, (acc, item) => {
    let l = item->config.key->String.length
    if l > acc { l } else { acc }
  })

  // Guard: total == 0.0 means all-zero values, distribute evenly but still render
  let ratios = total == 0.0
    ? data->Array.map(_ => 1.0 /. dataLen->Int.toFloat)
    : data->Array.map(item => item->config.value /. total)

  let gapChar = switch styles[dataLen - 1] { | Some(s) => s | None => " " }

  let rec getPadChar = (styles: array<string>, vals: array<float>, param: float, gap: string): string => {
    if styles->Array.length == 0 || vals->Array.length == 0 { gap }
    else {
      let firstVal = switch vals[0] { | Some(v) => v | None => 0.0 }
      let firstStyle = switch styles[0] { | Some(s) => s | None => gap }
      if param <= firstVal { firstStyle }
      else {
        getPadChar(
          Js.Array.sliceFrom(1, styles),
          Js.Array.sliceFrom(1, vals),
          param -. firstVal,
          gap,
        )
      }
    }
  }

  let result = ref("")
  let innerRadiusSq = effectiveInnerRadius * effectiveInnerRadius

  for i in -radius to radius - 1 {
    if i != -radius {
      result := result.contents ++ "\n" ++ Js.String.repeat(left, " ")
    } else {
      result := Js.String.repeat(left, " ")
    }

    for j in -radius to radius - 1 {
      let distSq = i * i + j * j
      let radiusSq = radius * radius

      if distSq < radiusSq {
        let angle = Math.atan2(~y=i->Int.toFloat, ~x=j->Int.toFloat) /. Math.Constants.pi *. 0.5 +. 0.5
        let normalizedAngle = if angle < 0.0 { angle +. 1.0 } else { angle }
        let isOuter = distSq > innerRadiusSq

        if isOuter {
          result := result.contents ++ getPadChar(styles, ratios, normalizedAngle, gapChar)
        } else {
          result := result.contents ++ "  "
        }
      } else {
        result := result.contents ++ "  "
      }
    }
  }

  result := result.contents ++ "\n\n" ++ Js.String.repeat(left, " ")

  // Legend
  let idx = ref(0)
  data->Array.forEach(item => {
    let i = idx.contents
    idx := i + 1
    let styleChar = switch styles[i] { | Some(s) => s | None => "?" }
    let key = switch keys[i] { | Some(k) => k | None => "?" }
    let val = item->config.value
    let pct = if total == 0.0 { 0.0 } else { val /. total *. 100.0 }
    result := result.contents ++ styleChar ++ " " ++ padStart(key, maxKeyLength, " ") ++ ": " ++ val->Float.toString ++ " (" ++ Math.round(pct)->Float.toInt->Int.toString ++ "%)"
    if i != dataLen - 1 {
      result := result.contents ++ "\n" ++ Js.String.repeat(left, " ")
    }
  })

  result.contents
}
