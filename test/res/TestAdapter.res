/**
 * F005-adapter — Unit tests for CLI Adapter
 *
 * Covers:
 * - jsonToString: JString extracts, JNumber converts, JBool converts, JNull returns None
 * - jsonToFloat: JNumber extracts, JString parses, JBool returns None
 * - mapCategorical: success, error on missing key, error on missing value, error on non-numeric value
 * - mapScatter: success, error on missing series, error on non-numeric x/y
 * - adapt: delegates to mapScatter for #scatter, mapCategorical for other types
 */

open Test
open Assertions
open Adapter
open CliTypes

// ─── jsonToString ────────────────────────────────────────────────

let testJsonToStringJString = () => {
  let jsonValue = JSON.Encode.string("hello")
  let result = jsonToString(jsonValue)
  switch result {
  | Some(s) => isTextEqualTo("hello", s, ~message="jsonToString: JString extracts correctly")
  | None => failWith("jsonToString: JString should return Some")
  }
}

let testJsonToStringJNumber = () => {
  // Use Obj.magic to set a raw float as JSON number value
  let jsonValue = 42.5->Obj.magic
  let result = jsonToString(jsonValue)
  switch result {
  | Some(s) =>
    if s == "42.5" {
      passWith("jsonToString: JNumber converts to string")
    } else {
      failWith("jsonToString: JNumber converted to unexpected string: " ++ s)
    }
  | None => failWith("jsonToString: JNumber should return Some")
  }
}

let testJsonToStringJBoolTrue = () => {
  let jsonValue = JSON.Encode.bool(true)
  let result = jsonToString(jsonValue)
  switch result {
  | Some(s) => isTextEqualTo("true", s, ~message="jsonToString: JBool(true) converts to \"true\"")
  | None => failWith("jsonToString: JBool should return Some")
  }
}

let testJsonToStringJBoolFalse = () => {
  let jsonValue = JSON.Encode.bool(false)
  let result = jsonToString(jsonValue)
  switch result {
  | Some(s) => isTextEqualTo("false", s, ~message="jsonToString: JBool(false) converts to \"false\"")
  | None => failWith("jsonToString: JBool should return Some")
  }
}

let testJsonToStringJNull = () => {
  let jsonValue = JSON.Encode.null
  let result = jsonToString(jsonValue)
  switch result {
  | Some(_) => failWith("jsonToString: JNull should return None")
  | None => passWith("jsonToString: JNull returns None")
  }
}

// ─── jsonToFloat ─────────────────────────────────────────────────

let testJsonToFloatJNumber = () => {
  // Use Obj.magic to create JSON number value
  let jsonValue: JSON.t = 99.5->Obj.magic
  let result = jsonToFloat(jsonValue)
  switch result {
  | Some(f) =>
    if f == 99.5 {
      passWith("jsonToFloat: JNumber extracts correctly")
    } else {
      failWith("jsonToFloat: JNumber extracted to unexpected value")
    }
  | None => failWith("jsonToFloat: JNumber should return Some")
  }
}

let testJsonToFloatJString = () => {
  let jsonValue = JSON.Encode.string("123.5")
  let result = jsonToFloat(jsonValue)
  switch result {
  | Some(f) =>
    if f == 123.5 {
      passWith("jsonToFloat: JString parses to float")
    } else {
      failWith("jsonToFloat: JString parsed to unexpected value")
    }
  | None => failWith("jsonToFloat: JString should return Some")
  }
}

let testJsonToFloatJBool = () => {
  let jsonValue = JSON.Encode.bool(true)
  let result = jsonToFloat(jsonValue)
  switch result {
  | Some(_) => failWith("jsonToFloat: JBool should return None")
  | None => passWith("jsonToFloat: JBool returns None")
  }
}

let testJsonToFloatJStringInvalid = () => {
  let jsonValue = JSON.Encode.string("not-a-number")
  let result = jsonToFloat(jsonValue)
  switch result {
  | Some(_) => failWith("jsonToFloat: invalid string should return None")
  | None => passWith("jsonToFloat: invalid string returns None")
  }
}

// ─── mapCategorical ──────────────────────────────────────────────

let testMapCategoricalSuccess = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("key", JSON.Encode.string("A"))
  let _ = dict1->Dict.set("value", 10.0->Obj.magic)
  let dict2 = Dict.make()
  let _ = dict2->Dict.set("key", JSON.Encode.string("B"))
  let _ = dict2->Dict.set("value", 20.0->Obj.magic)

  let rows: array<row> = [dict1, dict2]

  switch mapCategorical(rows, ~keyField="key", ~valueField="value") {
  | Ok(Categorical(data)) =>
    if data->Array.length == 2 {
      passWith("mapCategorical: success returns Categorical with correct count")
    } else {
      failWith("mapCategorical: expected 2 data points, got " ++ Int.toString(data->Array.length))
    }
  | Ok(Scatter(_)) => failWith("mapCategorical: should not return Scatter")
  | Error(msg) => failWith("mapCategorical: should not error: " ++ msg)
  }
}

let testMapCategoricalMissingKey = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("value", 10.0->Obj.magic)
  // key field missing

  let rows: array<row> = [dict1]

  switch mapCategorical(rows, ~keyField="key", ~valueField="value") {
  | Error(msg) =>
    if msg->String.includes("key") {
      passWith("mapCategorical: error when key field missing")
    } else {
      failWith("mapCategorical: wrong error message: " ++ msg)
    }
  | Ok(_) => failWith("mapCategorical: should have returned Error")
  }
}

let testMapCategoricalMissingValue = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("key", JSON.Encode.string("A"))
  // value field missing

  let rows: array<row> = [dict1]

  switch mapCategorical(rows, ~keyField="key", ~valueField="value") {
  | Error(msg) =>
    if msg->String.includes("value") {
      passWith("mapCategorical: error when value field missing")
    } else {
      failWith("mapCategorical: wrong error message: " ++ msg)
    }
  | Ok(_) => failWith("mapCategorical: should have returned Error")
  }
}

let testMapCategoricalNonNumericValue = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("key", JSON.Encode.string("A"))
  let _ = dict1->Dict.set("value", JSON.Encode.string("not-a-number"))

  let rows: array<row> = [dict1]

  switch mapCategorical(rows, ~keyField="key", ~valueField="value") {
  | Error(msg) =>
    if msg->String.includes("Invalid key/value types") {
      passWith("mapCategorical: error when value not numeric")
    } else {
      failWith("mapCategorical: wrong error message: " ++ msg)
    }
  | Ok(_) => failWith("mapCategorical: should have returned Error")
  }
}

// ─── mapScatter ─────────────────────────────────────────────────

let testMapScatterSuccess = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("series", JSON.Encode.string("alpha"))
  let _ = dict1->Dict.set("x", 1.0->Obj.magic)
  let _ = dict1->Dict.set("y", 2.0->Obj.magic)

  let rows: array<row> = [dict1]

  switch mapScatter(rows, ~seriesField="series", ~xField="x", ~yField="y") {
  | Ok(Scatter(data)) =>
    if data->Array.length == 1 {
      passWith("mapScatter: success returns Scatter with correct count")
    } else {
      failWith("mapScatter: expected 1 data point, got " ++ Int.toString(data->Array.length))
    }
  | Ok(Categorical(_)) => failWith("mapScatter: should not return Categorical")
  | Error(msg) => failWith("mapScatter: should not error: " ++ msg)
  }
}

let testMapScatterMissingSeries = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("x", 1.0->Obj.magic)
  let _ = dict1->Dict.set("y", 2.0->Obj.magic)
  // series field missing

  let rows: array<row> = [dict1]

  switch mapScatter(rows, ~seriesField="series", ~xField="x", ~yField="y") {
  | Error(msg) =>
    if msg->String.includes("series") {
      passWith("mapScatter: error when series field missing")
    } else {
      failWith("mapScatter: wrong error message: " ++ msg)
    }
  | Ok(_) => failWith("mapScatter: should have returned Error")
  }
}

let testMapScatterNonNumericX = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("series", JSON.Encode.string("alpha"))
  let _ = dict1->Dict.set("x", JSON.Encode.string("not-a-number"))
  let _ = dict1->Dict.set("y", 2.0->Obj.magic)

  let rows: array<row> = [dict1]

  switch mapScatter(rows, ~seriesField="series", ~xField="x", ~yField="y") {
  | Error(msg) =>
    if msg->String.includes("Invalid scatter field types") {
      passWith("mapScatter: error when x is non-numeric")
    } else {
      failWith("mapScatter: wrong error message: " ++ msg)
    }
  | Ok(_) => failWith("mapScatter: should have returned Error")
  }
}

let testMapScatterNonNumericY = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("series", JSON.Encode.string("alpha"))
  let _ = dict1->Dict.set("x", 1.0->Obj.magic)
  let _ = dict1->Dict.set("y", JSON.Encode.string("not-a-number"))

  let rows: array<row> = [dict1]

  switch mapScatter(rows, ~seriesField="series", ~xField="x", ~yField="y") {
  | Error(msg) =>
    if msg->String.includes("Invalid scatter field types") {
      passWith("mapScatter: error when y is non-numeric")
    } else {
      failWith("mapScatter: wrong error message: " ++ msg)
    }
  | Ok(_) => failWith("mapScatter: should have returned Error")
  }
}

// ─── adapt ───────────────────────────────────────────────────────

let testAdaptScatter = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("series", JSON.Encode.string("alpha"))
  let _ = dict1->Dict.set("x", 1.0->Obj.magic)
  let _ = dict1->Dict.set("y", 2.0->Obj.magic)

  let rows: array<row> = [dict1]
  let opts: cliOptions = {
    format: #auto,
    chartType: #scatter,
    seriesField: "series",
    xKey: "x",
    yKey: "y",
    noHeader: false,
  }

  switch adapt(rows, opts) {
  | Ok(Scatter(_)) => passWith("adapt: #scatter delegates to mapScatter")
  | Ok(Categorical(_)) => failWith("adapt: #scatter should return Scatter, not Categorical")
  | Error(msg) => failWith("adapt: #scatter should not error: " ++ msg)
  }
}

let testAdaptBar = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("key", JSON.Encode.string("A"))
  let _ = dict1->Dict.set("value", 10.0->Obj.magic)

  let rows: array<row> = [dict1]
  let opts: cliOptions = {
    format: #auto,
    chartType: #bar,
    keyField: "key",
    valueField: "value",
    noHeader: false,
  }

  switch adapt(rows, opts) {
  | Ok(Categorical(_)) => passWith("adapt: #bar delegates to mapCategorical")
  | Ok(Scatter(_)) => failWith("adapt: #bar should return Categorical, not Scatter")
  | Error(msg) => failWith("adapt: #bar should not error: " ++ msg)
  }
}

let testAdaptSparkline = () => {
  let dict1 = Dict.make()
  let _ = dict1->Dict.set("key", JSON.Encode.string("t1"))
  let _ = dict1->Dict.set("value", 42.0->Obj.magic)

  let rows: array<row> = [dict1]
  let opts: cliOptions = {
    format: #auto,
    chartType: #sparkline,
    keyField: "key",
    valueField: "value",
    noHeader: false,
  }

  switch adapt(rows, opts) {
  | Ok(Categorical(_)) => passWith("adapt: #sparkline delegates to mapCategorical")
  | Ok(Scatter(_)) => failWith("adapt: #sparkline should return Categorical, not Scatter")
  | Error(msg) => failWith("adapt: #sparkline should not error: " ++ msg)
  }
}

// ─── Register tests ─────────────────────────────────────────────

test("jsonToString: JString extracts correctly", () => testJsonToStringJString())
test("jsonToString: JNumber converts to string", () => testJsonToStringJNumber())
test("jsonToString: JBool(true) converts to \"true\"", () => testJsonToStringJBoolTrue())
test("jsonToString: JBool(false) converts to \"false\"", () => testJsonToStringJBoolFalse())
test("jsonToString: JNull returns None", () => testJsonToStringJNull())

test("jsonToFloat: JNumber extracts correctly", () => testJsonToFloatJNumber())
test("jsonToFloat: JString parses to float", () => testJsonToFloatJString())
test("jsonToFloat: JBool returns None", () => testJsonToFloatJBool())
test("jsonToFloat: invalid string returns None", () => testJsonToFloatJStringInvalid())

test("mapCategorical: success returns Categorical with correct count", () => testMapCategoricalSuccess())
test("mapCategorical: error when key field missing", () => testMapCategoricalMissingKey())
test("mapCategorical: error when value field missing", () => testMapCategoricalMissingValue())
test("mapCategorical: error when value not numeric", () => testMapCategoricalNonNumericValue())

test("mapScatter: success returns Scatter with correct count", () => testMapScatterSuccess())
test("mapScatter: error when series field missing", () => testMapScatterMissingSeries())
test("mapScatter: error when x is non-numeric", () => testMapScatterNonNumericX())
test("mapScatter: error when y is non-numeric", () => testMapScatterNonNumericY())

test("adapt: #scatter delegates to mapScatter", () => testAdaptScatter())
test("adapt: #bar delegates to mapCategorical", () => testAdaptBar())
test("adapt: #sparkline delegates to mapCategorical", () => testAdaptSparkline())
