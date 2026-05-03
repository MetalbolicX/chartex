open Test
open Assertions

module C = Chartex

type categoricalData = {label: string, value: float, style: string}
type gaugeData = {label: string, percentage: float, style: string}
type scatterData = {seriesName: string, x: float, y: float, style: string}
type sparklineData = {time: string, value: float, style: string}

@module("../../src/Chartex.res.mjs")
external parseCategoricalData: Nullable.t<'a> = "parseCategoricalData"

@module("../../src/Chartex.res.mjs")
external parseCustomData: Nullable.t<'a> = "parseCustomData"

@module("../../src/Chartex.res.mjs")
external parseFromObject: Nullable.t<'a> = "parseFromObject"

@module("../../src/Chartex.res.mjs")
external parseList: Nullable.t<'a> = "parseList"

@module("../../src/Chartex.res.mjs")
external parseRow: Nullable.t<'a> = "parseRow"

@module("../../src/Chartex.res.mjs")
external parseScatterData: Nullable.t<'a> = "parseScatterData"

let testBarrelChartsResolve = () => {
  let categorical: array<categoricalData> = [
    {label: "A", value: 10.0, style: "*"},
    {label: "B", value: 20.0, style: "#"},
  ]
  let categoricalCfg: C.Types.barConfig<categoricalData> = {
    key: d => d.label,
    value: d => d.value,
    style: d => d.style,
  }

  let barOutput = C.Bar.make(categorical, ~config=categoricalCfg, ())
  if barOutput->String.length > 0 {
    passWith("Chartex.Bar alias resolves and make() returns output")
  } else {
    failWith("Chartex.Bar alias did not produce output")
  }

  let bulletCfg: C.Types.bulletConfig<categoricalData> = {
    key: d => d.label,
    value: d => d.value,
    style: d => d.style,
  }
  let bulletOutput = C.Bullet.make(categorical, ~config=bulletCfg, ())
  if bulletOutput->String.length > 0 {
    passWith("Chartex.Bullet alias resolves and make() returns output")
  } else {
    failWith("Chartex.Bullet alias did not produce output")
  }

  let pieCfg: C.Types.pieConfig<categoricalData> = {
    key: d => d.label,
    value: d => d.value,
    style: d => d.style,
  }
  let pieOutput = C.Pie.make(categorical, ~config=pieCfg, ~options={radius: 4}, ())
  if pieOutput->String.includes("A") {
    passWith("Chartex.Pie alias resolves and output includes legend")
  } else {
    failWith("Chartex.Pie alias did not produce expected legend")
  }

  let donutCfg: C.Types.donutConfig<categoricalData> = {
    key: d => d.label,
    value: d => d.value,
    style: d => d.style,
  }
  let donutOutput = C.Donut.make(categorical, ~config=donutCfg, ~options={radius: 5, innerRadius: 2}, ())
  if donutOutput->String.includes("A") {
    passWith("Chartex.Donut alias resolves and output includes legend")
  } else {
    failWith("Chartex.Donut alias did not produce expected legend")
  }

  let gaugeInput: array<gaugeData> = [{label: "Load", percentage: 42.0, style: "*"}]
  let gaugeCfg: C.Types.gaugeConfig<gaugeData> = {
    key: d => d.label,
    value: d => d.percentage,
    style: d => d.style,
  }
  let gaugeOutput = C.Gauge.make(gaugeInput, ~config=gaugeCfg, ~options={radius: 6}, ())
  if gaugeOutput->String.includes("Load") {
    passWith("Chartex.Gauge alias resolves and make() renders key")
  } else {
    failWith("Chartex.Gauge alias did not produce expected output")
  }

  let scatterInput: array<scatterData> = [
    {seriesName: "series1", x: 1.0, y: 1.0, style: "*"},
    {seriesName: "series2", x: 2.0, y: 3.0, style: "#"},
  ]
  let scatterCfg: C.Types.scatterConfig<scatterData> = {
    series: d => d.seriesName,
    x: d => d.x,
    y: d => d.y,
    style: d => d.style,
  }
  let scatterOutput = C.Scatter.make(scatterInput, ~config=scatterCfg, ~options={width: 20, height: 6}, ())
  if scatterOutput->String.includes("|") {
    passWith("Chartex.Scatter alias resolves and make() renders axes")
  } else {
    failWith("Chartex.Scatter alias did not render expected axes")
  }

  let sparklineInput: array<sparklineData> = [
    {time: "t1", value: 1.0, style: "*"},
    {time: "t2", value: 3.0, style: "#"},
    {time: "t3", value: 2.0, style: "+"},
  ]
  let sparklineCfg: C.Types.sparklineConfig<sparklineData> = {
    key: d => d.time,
    value: d => d.value,
    style: d => d.style,
  }
  let sparklineOutput = C.Sparkline.make(sparklineInput, ~config=sparklineCfg, ~options={width: 20, height: 6}, ())
  if sparklineOutput->String.includes("|") {
    passWith("Chartex.Sparkline alias resolves and make() renders y-axis")
  } else {
    failWith("Chartex.Sparkline alias did not render expected y-axis")
  }
}

let testBarrelCoreAndTypesResolve = () => {
  let color: C.Types.backgroundColor = C.Types.Red
  let ansiOut = C.Ansi.fg(~color, ~str="ok")
  if ansiOut->String.includes("ok") {
    passWith("Chartex.Ansi alias resolves and fg() is callable")
  } else {
    failWith("Chartex.Ansi alias did not return expected output")
  }

  let terminalWidth = C.Terminal.width()
  switch terminalWidth {
  | Some(_w) => passWith("Chartex.Terminal alias resolves and width() returns non-negative")
  | None => failWith("Chartex.Terminal width() returned None (non-TTY)")
  }

  let j = C.Json.JString("hello")
  isTextEqualTo("hello", C.Json.string(j), ~message="Chartex.Json alias resolves and string() accessor works")

  let dict = Dict.make()
  let _ = dict->Dict.set("key", C.Json.JString("k"))
  let _ = dict->Dict.set("value", C.Json.JNumber(1.0))
  let input = C.Json.JArray([C.Json.JObject(dict)])
  if C.Validate.data(input) {
    passWith("Chartex.Validate alias resolves and data() validates expected structure")
  } else {
    failWith("Chartex.Validate data() returned false for valid structure")
  }

  let _opts: C.Types.barOptions = {height: 8}
  passWith("Chartex.Types alias resolves and type access compiles")
}

let testBarrelDoesNotExportParseHelpers = () => {
  let hasParseCategoricalData = parseCategoricalData->Nullable.toOption->Option.isSome
  let hasParseCustomData = parseCustomData->Nullable.toOption->Option.isSome
  let hasParseFromObject = parseFromObject->Nullable.toOption->Option.isSome
  let hasParseList = parseList->Nullable.toOption->Option.isSome
  let hasParseRow = parseRow->Nullable.toOption->Option.isSome
  let hasParseScatterData = parseScatterData->Nullable.toOption->Option.isSome

  if !hasParseCategoricalData && !hasParseCustomData && !hasParseFromObject && !hasParseList && !hasParseRow && !hasParseScatterData {
    passWith("Chartex barrel does not expose legacy parse* helpers")
  } else {
    failWith("Chartex barrel unexpectedly exposes one or more parse* helpers")
  }
}

test("Barrel: chart module aliases resolve and are usable", () => testBarrelChartsResolve())
test("Barrel: core/types aliases resolve and are usable", () => testBarrelCoreAndTypesResolve())
test("Barrel: parse* helpers remain excluded from public API", () => testBarrelDoesNotExportParseHelpers())
