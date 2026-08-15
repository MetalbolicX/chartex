open Test
open Assertions
open CliTypes

type barData = {product: string, sales: float, barStyle: string}
type bulletData = {product: string, sales: float, bulletStyle: string}
type pieData = {category: string, amount: float, pieStyle: string}
type gaugeData = {label: string, percentage: float, gaugeStyle: string}
type scatterData = {seriesName: string, coordX: float, coordY: float, pointStyle: string}
type sparklineData = {time: string, value: float, lineStyle: string}

// ─── Bar Chart Tests ───

let testBarHappyPath = () => {
  let data: array<barData> = [
    {product: "Widget", sales: 30.0, barStyle: "*"},
    {product: "Gadget", sales: 50.0, barStyle: "#"},
    {product: "Doodad", sales: 20.0, barStyle: "+"},
  ]
  let config: Types.barConfig<barData> = {key: d => d.product, value: d => d.sales, style: d => d.barStyle}
  let result = Bar.make(data, ~config, ())
  if result->String.includes("Widget") && result->String.includes("Gadget") && result->String.includes("Doodad") {
    passWith("Bar: contains all key names")
  } else { failWith("Bar: missing key names") }
  if result->String.includes("*") || result->String.includes("#") || result->String.includes("+") {
    passWith("Bar: contains style chars")
  } else { failWith("Bar: missing style chars") }
}

let testBarEmptyRejected = () => {
  try {
    let _ = Bar.make([], ~config={key: _ => "", value: _ => 0.0}, ())
    failWith("Bar: should have thrown")
  } catch {
  | JsExn(_) => passWith("Bar: empty data rejected")
  | _ => failWith("Bar: unexpected error")
  }
}

// ─── Bullet Chart Tests ───

let testBulletHappyPath = () => {
  let data: array<bulletData> = [
    {product: "Alpha", sales: 10.0, bulletStyle: "*"},
    {product: "Beta", sales: 20.0, bulletStyle: "#"},
  ]
  let config: Types.bulletConfig<bulletData> = {key: d => d.product, value: d => d.sales, style: d => d.bulletStyle}
  let result = Bullet.make(data, ~config, ())
  if result->String.includes("Alpha") && result->String.includes("Beta") { passWith("Bullet: contains key names") }
  else { failWith("Bullet: missing key names") }
  if result->String.includes("[10]") && result->String.includes("[20]") { passWith("Bullet: contains value labels") }
  else { failWith("Bullet: missing value labels") }
}

// ─── Pie Chart Tests ───

let testPieHappyPath = () => {
  let data: array<pieData> = [
    {category: "Food", amount: 30.0, pieStyle: "*"},
    {category: "Rent", amount: 50.0, pieStyle: "#"},
    {category: "Fun", amount: 20.0, pieStyle: "+"},
  ]
  let config: Types.pieConfig<pieData> = {key: d => d.category, value: d => d.amount, style: d => d.pieStyle}
  let opts: Types.pieOptions = {radius: 8}
  let result = Pie.make(data, ~config, ~options=opts, ())
  if result->String.includes("*") && result->String.includes("#") { passWith("Pie: contains style chars") }
  else { failWith("Pie: missing style chars") }
  if result->String.includes("Food") && result->String.includes("Rent") { passWith("Pie: legend contains key names") }
  else { failWith("Pie: legend missing key names") }
}

// ─── Donut Chart Tests ───

let testDonutHappyPath = () => {
  let data: array<pieData> = [
    {category: "A", amount: 50.0, pieStyle: "*"},
    {category: "B", amount: 30.0, pieStyle: "#"},
    {category: "C", amount: 20.0, pieStyle: "+"},
  ]
  let config: Types.donutConfig<pieData> = {key: d => d.category, value: d => d.amount, style: d => d.pieStyle}
  let opts: Types.donutOptions = {radius: 8, innerRadius: 3}
  let result = Donut.make(data, ~config, ~options=opts, ())
  if result->String.includes("*") && result->String.includes("#") { passWith("Donut: contains style chars") }
  else { failWith("Donut: missing style chars") }
  if result->String.includes("A") { passWith("Donut: legend contains key names") }
  else { failWith("Donut: legend missing key names") }
}

// ─── Gauge Chart Tests ───

let testGaugeHappyPath = () => {
  let data: array<gaugeData> = [{label: "Progress", percentage: 42.0, gaugeStyle: "*"}]
  let config: Types.gaugeConfig<gaugeData> = {key: d => d.label, value: d => d.percentage, style: d => d.gaugeStyle}
  let opts: Types.gaugeOptions = {radius: 10}
  let result = Gauge.make(data, ~config, ~options=opts, ())
  if result->String.includes("42") { passWith("Gauge: center displays 42") }
  else { failWith("Gauge: missing percentage") }
  if result->String.includes("Progress") { passWith("Gauge: bottom axis contains key") }
  else { failWith("Gauge: missing key label") }
}

let testGaugePercentageZero = () => {
  let data: array<gaugeData> = [{label: "Empty", percentage: 0.0, gaugeStyle: "*"}]
  let config: Types.gaugeConfig<gaugeData> = {key: d => d.label, value: d => d.percentage, style: d => d.gaugeStyle}
  let opts: Types.gaugeOptions = {radius: 10}
  let result = Gauge.make(data, ~config, ~options=opts, ())
  if result->String.includes("0") && result->String.includes("100") && result->String.includes("Empty") {
    passWith("Gauge: 0% renders with scale labels")
  } else {
    failWith("Gauge: 0% missing scale/key labels")
  }
}

let testGaugePercentageMid = () => {
  let data: array<gaugeData> = [{label: "Mid", percentage: 50.0, gaugeStyle: "*"}]
  let config: Types.gaugeConfig<gaugeData> = {key: d => d.label, value: d => d.percentage, style: d => d.gaugeStyle}
  let opts: Types.gaugeOptions = {radius: 10}
  let result = Gauge.make(data, ~config, ~options=opts, ())
  if result->String.includes("50") { passWith("Gauge: 50% center displays 50") }
  else { failWith("Gauge: 50% missing center percentage") }
}

let testGaugePercentage99 = () => {
  let data: array<gaugeData> = [{label: "AlmostFull", percentage: 99.0, gaugeStyle: "*"}]
  let config: Types.gaugeConfig<gaugeData> = {key: d => d.label, value: d => d.percentage, style: d => d.gaugeStyle}
  let opts: Types.gaugeOptions = {radius: 10}
  let result = Gauge.make(data, ~config, ~options=opts, ())
  if result->String.includes("99") { passWith("Gauge: 99% center displays 99") }
  else { failWith("Gauge: 99% missing center percentage") }
}

let testGaugePercentage100 = () => {
  let data: array<gaugeData> = [{label: "Full", percentage: 100.0, gaugeStyle: "*"}]
  let config: Types.gaugeConfig<gaugeData> = {key: d => d.label, value: d => d.percentage, style: d => d.gaugeStyle}
  let opts: Types.gaugeOptions = {radius: 10}
  let result = Gauge.make(data, ~config, ~options=opts, ())
  let lines = result->String.split("\n")
  // Center cell is the line that contains neither "0" nor the key suffix pattern;
  // it sits directly above the bottom scale line (which starts with "0   Full").
  let centerLine = switch lines[lines->Array.length - 2] {
  | Some(line) => line
  | None => ""
  }
  // At 100% the center must show "100" (not "10" from the slice truncation).
  if centerLine->String.includes("100") {
    passWith("Gauge: 100% center displays 100 (not truncated)")
  } else {
    failWith("Gauge: 100% center truncated to '10' instead of '100'")
  }
}

// ─── Scatter Chart Tests ───

let testScatterHappyPath = () => {
  let data: array<scatterData> = [
    {seriesName: "alpha", coordX: 1.0, coordY: 2.0, pointStyle: "*"},
    {seriesName: "alpha", coordX: 2.0, coordY: 4.0, pointStyle: "*"},
    {seriesName: "beta", coordX: 3.0, coordY: 1.0, pointStyle: "#"},
  ]
  let config: Types.scatterConfig<scatterData> = {key: d => d.seriesName, x: d => d.coordX, y: d => d.coordY, style: d => d.pointStyle}
  let opts: Types.scatterOptions = {width: 30, height: 10, showLegend: false}
  let result = Scatter.make(data, ~config, ~options=opts, ())
  if result->String.includes("|") { passWith("Scatter: contains Y-axis bar") }
  else { failWith("Scatter: missing Y-axis bar") }
  if result->String.includes("_") { passWith("Scatter: contains X-axis line") }
  else { failWith("Scatter: missing X-axis line") }
}

let testScatterLegend = () => {
  let data: array<scatterData> = [
    {seriesName: "temperature", coordX: 1.0, coordY: 22.5, pointStyle: "*"},
    {seriesName: "temperature", coordX: 2.0, coordY: 23.1, pointStyle: "*"},
    {seriesName: "CO2", coordX: 1.0, coordY: 400.0, pointStyle: "#"},
    {seriesName: "CO2", coordX: 2.0, coordY: 405.0, pointStyle: "#"},
  ]
  let config: Types.scatterConfig<scatterData> = {key: d => d.seriesName, x: d => d.coordX, y: d => d.coordY, style: d => d.pointStyle}
  let opts: Types.scatterOptions = {width: 30, height: 10, showLegend: true}
  let result = Scatter.make(data, ~config, ~options=opts, ())
  if result->String.includes("temperature") { passWith("Scatter legend: contains first series name") }
  else { failWith("Scatter legend: missing first series name") }
  if result->String.includes("CO2") { passWith("Scatter legend: contains second series name") }
  else { failWith("Scatter legend: missing second series name") }
}

let testScatterEmptyRejected = () => {
  try {
    let _ = Scatter.make([], ~config={key: _ => "", x: _ => 0.0, y: _ => 0.0}, ())
    failWith("Scatter: should have thrown")
  } catch {
  | JsExn(_) => passWith("Scatter: empty data rejected")
  | _ => failWith("Scatter: unexpected error")
  }
}

let testScatterFiniteValidation = (label: string, coord: scatterData) => {
  let data: array<scatterData> = [
    {seriesName: "s1", coordX: 1.0, coordY: 1.0, pointStyle: "*"},
    coord,
    coord,
  ]
  let config: Types.scatterConfig<scatterData> = {key: d => d.seriesName, x: d => d.coordX, y: d => d.coordY, style: d => d.pointStyle}
  try {
    let _ = Scatter.make(data, ~config, ())
    failWith(`Scatter ${label}: should have thrown`)
  } catch {
  | JsExn(_) => passWith(`Scatter ${label}: rejected`)
  | _ => failWith(`Scatter ${label}: unexpected error type`)
  }
}

let testScatterNaNOnlyRejected = () =>
  testScatterFiniteValidation("NaN-only", {seriesName: "s2", coordX: 0.0 /. 0.0, coordY: 1.0, pointStyle: "*"})
let testScatterMixedNaNRejected = () =>
  testScatterFiniteValidation("mixed-NaN", {seriesName: "s2", coordX: 2.0, coordY: 0.0 /. 0.0, pointStyle: "*"})
let testScatterPositiveInfinityRejected = () =>
  testScatterFiniteValidation("+Infinity", {seriesName: "s2", coordX: 1.0 /. 0.0, coordY: 1.0, pointStyle: "*"})
let testScatterNegativeInfinityRejected = () =>
  testScatterFiniteValidation("-Infinity", {seriesName: "s2", coordX: -1.0 /. 0.0, coordY: 1.0, pointStyle: "*"})

// ─── Sparkline Chart Tests ───

let testSparklineHappyPath = () => {
  let data: array<sparklineData> = [
    {time: "t1", value: 1.0, lineStyle: "*"},
    {time: "t2", value: 3.0, lineStyle: "*"},
    {time: "t3", value: 2.0, lineStyle: "*"},
    {time: "t4", value: 5.0, lineStyle: "*"},
    {time: "t5", value: 4.0, lineStyle: "*"},
  ]
  let config: Types.sparklineConfig<sparklineData> = {key: d => d.time, value: d => d.value, style: d => d.lineStyle}
  let opts: Types.sparklineOptions = {width: 40, height: 8}
  let result = Sparkline.make(data, ~config, ~options=opts, ())
  if result->String.includes("*") { passWith("Sparkline: contains style chars") }
  else { failWith("Sparkline: missing style chars") }
  if result->String.includes("|") { passWith("Sparkline: contains Y-axis bar") }
  else { failWith("Sparkline: missing Y-axis bar") }
}

let testSparklineSinglePoint = () => {
  let data: array<sparklineData> = [{time: "solo", value: 10.0, lineStyle: "S"}]
  let config: Types.sparklineConfig<sparklineData> = {key: d => d.time, value: d => d.value, style: d => d.lineStyle}
  let opts: Types.sparklineOptions = {width: 10, height: 5}
  let result = Sparkline.make(data, ~config, ~options=opts, ())
  if result->String.includes("S") { passWith("Sparkline: single point contains style char") }
  else { failWith("Sparkline: single point missing style char") }
}

let testSparklineFiniteValidation = (label: string, value: float) => {
  let data: array<sparklineData> = [
    {time: "t1", value: 1.0, lineStyle: "*"},
    {time: "t2", value, lineStyle: "*"},
    {time: "t3", value, lineStyle: "*"},
  ]
  let config: Types.sparklineConfig<sparklineData> = {key: d => d.time, value: d => d.value, style: d => d.lineStyle}
  try {
    let _ = Sparkline.make(data, ~config, ())
    failWith(`Sparkline ${label}: should have thrown`)
  } catch {
  | JsExn(_) => passWith(`Sparkline ${label}: rejected`)
  | _ => failWith(`Sparkline ${label}: unexpected error type`)
  }
}

let testSparklineNaNOnlyRejected = () =>
  testSparklineFiniteValidation("NaN-only", 0.0 /. 0.0)
let testSparklineMixedNaNRejected = () =>
  testSparklineFiniteValidation("mixed-NaN", 0.0 /. 0.0)
let testSparklinePositiveInfinityRejected = () =>
  testSparklineFiniteValidation("+Infinity", 1.0 /. 0.0)
let testSparklineNegativeInfinityRejected = () =>
  testSparklineFiniteValidation("-Infinity", -1.0 /. 0.0)

// ─── Register tests ───

test("Bar: renders with 3 items, contains keys and styles", () => testBarHappyPath())
test("Bar: empty data rejected with Assert_failure", () => testBarEmptyRejected())
test("Bullet: renders with 2 items, contains keys and value labels", () => testBulletHappyPath())
test("Pie: renders with 3 items, contains styles and legend", () => testPieHappyPath())
test("Donut: renders with 3 items, contains styles and legend", () => testDonutHappyPath())
test("Gauge: renders percentage value and scale labels", () => testGaugeHappyPath())
test("Gauge: 0% renders with scale labels", () => testGaugePercentageZero())
test("Gauge: 50% center displays 50", () => testGaugePercentageMid())
test("Gauge: 99% center displays 99", () => testGaugePercentage99())
test("Gauge: 100% center displays 100 (not truncated)", () => testGaugePercentage100())
test("Scatter: renders with 3 points, contains axes", () => testScatterHappyPath())
test("Scatter: legend shows series names", () => testScatterLegend())
test("Scatter: empty data rejected with Assert_failure", () => testScatterEmptyRejected())
test("Scatter: NaN-only coordinates rejected", () => testScatterNaNOnlyRejected())
test("Scatter: mixed NaN coordinates rejected", () => testScatterMixedNaNRejected())
test("Scatter: +Infinity coordinates rejected", () => testScatterPositiveInfinityRejected())
test("Scatter: -Infinity coordinates rejected", () => testScatterNegativeInfinityRejected())
test("Sparkline: renders with 5 points with interpolation", () => testSparklineHappyPath())
test("Sparkline: single point renders with style char", () => testSparklineSinglePoint())
test("Sparkline: NaN-only values rejected", () => testSparklineNaNOnlyRejected())
test("Sparkline: mixed NaN values rejected", () => testSparklineMixedNaNRejected())
test("Sparkline: +Infinity values rejected", () => testSparklinePositiveInfinityRejected())
test("Sparkline: -Infinity values rejected", () => testSparklineNegativeInfinityRejected())

// ─── Error message shape regression (plan 003) ───

let testErrorMessageShapePrefix = (
  label: string,
  throwFn: unit => unit
) => {
  try {
    throwFn()
    failWith(`${label}: should have thrown`)
  } catch {
  | JsExn(payload) =>
    switch JsExn.message(payload) {
    | Some(msg) =>
      if msg->String.startsWith("Error: ") {
        passWith(`${label}: error message has "Error: " prefix`)
      } else {
        failWith(`${label}: error message missing "Error: " prefix, got: ${msg}`)
      }
    | None => failWith(`${label}: error has no message`)
    }
  | _ => failWith(`${label}: unexpected error type`)
  }
}

let testBarEmptyErrorMessageShape = () =>
  testErrorMessageShapePrefix("Bar empty data", () => {
    let _ = Bar.make([], ~config={key: _ => "", value: _ => 0.0}, ())
    ()
  })

let testSparklineNaNErrorMessageShape = () =>
  testErrorMessageShapePrefix("Sparkline NaN", () => {
    let data: array<sparklineData> = [
      {time: "t1", value: 1.0, lineStyle: "*"},
      {time: "t2", value: 0.0 /. 0.0, lineStyle: "*"},
    ]
    let config: Types.sparklineConfig<sparklineData> = {key: d => d.time, value: d => d.value, style: d => d.lineStyle}
    let _ = Sparkline.make(data, ~config, ())
    ()
  })

let testScatterCategoricalErrorMessageShape = () => {
  let row1: CliTypes.row = Dict.make()
  let _ = row1->Dict.set("department", JSON.Encode.string("Sales"))
  let _ = row1->Dict.set("revenue", JSON.Encode.string("100"))
  let row2: CliTypes.row = Dict.make()
  let _ = row2->Dict.set("department", JSON.Encode.string("Eng"))
  let _ = row2->Dict.set("revenue", JSON.Encode.string("200"))
  let rows: array<CliTypes.row> = [row1, row2]
  let opts: CliTypes.cliOptions = {format: #auto, chartType: #scatter, noHeader: false}
  switch Adapter.adapt(rows, opts) {
  | Adapter.Ok(_) => failWith("Scatter categorical data: should have returned Error")
  | Adapter.Error(msg) =>
    if msg->String.startsWith("Error: ") {
      passWith("Scatter categorical data: error message has \"Error: \" prefix")
    } else {
      failWith("Scatter categorical data: error message missing \"Error: \" prefix, got: " ++ msg)
    }
  }
}

test("Bar empty data: error message has Error: prefix", () => testBarEmptyErrorMessageShape())
test("Sparkline NaN: error message has Error: prefix", () => testSparklineNaNErrorMessageShape())
test("Scatter categorical data: error message has Error: prefix", () => testScatterCategoricalErrorMessageShape())
