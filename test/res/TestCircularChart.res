open Test
open Assertions
open CircularChart

type totalItem = {key: string, value: float}

// ─── applyStyles ─────────────────────────────────────────────────────────────

let testApplyStylesWithStyleFn = () => {
  let data: array<totalItem> = [{key: "a", value: 1.0}, {key: "b", value: 2.0}]
  let result = applyStyles(
    data,
    ~defaultStyles=defaultPieStyles,
    ~styleFn=Some(_ => "X"),
  )
  isTextEqualTo("XX", Js.Array.joinWith("", result), ~message="applyStyles: styleFn applied to every item")
}

let testApplyStylesRoundRobin = () => {
  let data: array<totalItem> = [{key: "a", value: 1.0}, {key: "b", value: 2.0}, {key: "c", value: 3.0}]
  let result = applyStyles(
    data,
    ~defaultStyles=defaultPieStyles,
    ~styleFn=None,
  )
  isTextEqualTo("●○◆", Js.Array.joinWith("", result), ~message="applyStyles: round-robin from defaults")
}

// ─── computeTotals ────────────────────────────────────────────────────────────

let testComputeTotals = () => {
  let data: array<totalItem> = [{key: "a", value: 1.0}, {key: "bb", value: 2.0}, {key: "ccc", value: 3.0}]
  let styles = ["●", "○", "◆"]
  let (total, _ratios, keys, maxKeyLength, gapChar) = computeTotals(
    data,
    ~getKey=d => d.key,
    ~getValue=d => d.value,
    ~styles,
  )
  isTextEqualTo("6", total->Float.toString, ~message="computeTotals: total sums values")
  isIntEqualTo(3, maxKeyLength, ~message="computeTotals: maxKeyLength is longest key length")
  isTextEqualTo("a,bb,ccc", Js.Array.joinWith(",", keys), ~message="computeTotals: keys extracted")
  isTextEqualTo("◆", gapChar, ~message="computeTotals: gapChar is last style")
}

let testComputeTotalsAllZeros = () => {
  let data: array<totalItem> = [{key: "a", value: 0.0}, {key: "b", value: 0.0}]
  let (total, ratios, _keys, _maxKeyLength, _gapChar) = computeTotals(
    data,
    ~getKey=d => d.key,
    ~getValue=d => d.value,
    ~styles=["●", "○"],
  )
  isTextEqualTo("0", total->Float.toString, ~message="computeTotals: total is 0 when all values are 0")
  isTextEqualTo(
    "0.5,0.5",
    Js.Array.joinWith(",", ratios->Array.map(v => v->Float.toString)),
    ~message="computeTotals: equal ratios when total is 0",
  )
}

// ─── getPadChar ──────────────────────────────────────────────────────────────

let testGetPadCharFirstStyle = () => {
  let result = getPadChar(["●", "○", "◆"], [0.3, 0.5, 0.2], 0.1, " ")
  isTextEqualTo("●", result, ~message="getPadChar: picks first style when param <= first val")
}

let testGetPadCharEmptyStyles = () => {
  let result = getPadChar([], [0.5], 0.3, "X")
  isTextEqualTo("X", result, ~message="getPadChar: returns gap when styles empty")
}

let testGetPadCharEmptyVals = () => {
  let result = getPadChar(["●"], [], 0.3, "X")
  isTextEqualTo("X", result, ~message="getPadChar: returns gap when vals empty")
}

// ─── legendRow ────────────────────────────────────────────────────────────────

let testLegendRowLast = () => {
  let result = legendRow(
    ~styleChar="●",
    ~key="foo",
    ~val=2.5,
    ~pct=50.0,
    ~maxKeyLength=5,
    ~left=2,
    ~isLast=true,
  )
  isTextEqualTo(
    "●   foo: 2.5 (50%)",
    result,
    ~message="legendRow: pads key to maxKeyLength with no trailing newline when isLast",
  )
}

let testLegendRowNotLast = () => {
  let result = legendRow(
    ~styleChar="●",
    ~key="a",
    ~val=1.0,
    ~pct=33.0,
    ~maxKeyLength=1,
    ~left=3,
    ~isLast=false,
  )
  isTextEqualTo(
    "● a: 1 (33%)\n   ",
    result,
    ~message="legendRow: appends newline + left padding when not last",
  )
}

// ─── legend ──────────────────────────────────────────────────────────────────

let testLegendMultiRow = () => {
  let data: array<totalItem> = [{key: "a", value: 1.0}, {key: "b", value: 2.0}]
  let result = legend(
    data,
    ~getValue=d => d.value,
    ~styles=["●", "○"],
    ~keys=["a", "b"],
    ~total=3.0,
    ~maxKeyLength=1,
    ~left=0,
  )
  isTextEqualTo(
    "● a: 1 (33%)\n○ b: 2 (67%)",
    result,
    ~message="legend: two-row legend with percentages",
  )
}

let testLegendSingleRow = () => {
  let data: array<totalItem> = [{key: "only", value: 5.0}]
  let result = legend(
    data,
    ~getValue=d => d.value,
    ~styles=["●"],
    ~keys=["only"],
    ~total=5.0,
    ~maxKeyLength=4,
    ~left=0,
  )
  isTextEqualTo("● only: 5 (100%)", result, ~message="legend: single-row has no trailing newline")
}

test("CircularChart: applyStyles uses styleFn when provided", () => testApplyStylesWithStyleFn())
test("CircularChart: applyStyles round-robins defaults when styleFn is None", () => testApplyStylesRoundRobin())
test("CircularChart: computeTotals sums values and computes ratios", () => testComputeTotals())
test("CircularChart: computeTotals distributes evenly when total is 0", () => testComputeTotalsAllZeros())
test("CircularChart: getPadChar picks first style when param <= first val", () => testGetPadCharFirstStyle())
test("CircularChart: getPadChar returns gap when styles empty", () => testGetPadCharEmptyStyles())
test("CircularChart: getPadChar returns gap when vals empty", () => testGetPadCharEmptyVals())
test("CircularChart: legendRow formats row and omits trailing newline when isLast", () => testLegendRowLast())
test("CircularChart: legendRow appends newline and left padding when not last", () => testLegendRowNotLast())
test("CircularChart: legend composes multiple rows with correct newlines", () => testLegendMultiRow())
test("CircularChart: legend handles single-row case", () => testLegendSingleRow())
