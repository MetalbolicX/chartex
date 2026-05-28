/**
 * F005-options — Unit tests for Options.getOpt
 *
 * Covers:
 * - Some(record) with field present → returns field value
 * - Some(record) with field absent → returns default
 * - None → returns default
 */

open Test
open Assertions
open Options

// Helper record type for testing
type exampleOpts = {
  name?: string,
  count?: int,
  active?: bool,
}

let testGetOptSomeFieldPresent = () => {
  let opts: exampleOpts = {name: "Charlie", count: 10}
  let result = getOpt(Some(opts), o => o.name, "anonymous")
  isTextEqualTo("Charlie", result, ~message="getOpt: Some(record) with field present returns field value")
}

let testGetOptSomeFieldAbsent = () => {
  let opts: exampleOpts = {count: 5}
  let result = getOpt(Some(opts), o => o.name, "anonymous")
  isTextEqualTo("anonymous", result, ~message="getOpt: Some(record) with field absent returns default")
}

let testGetOptNone = () => {
  let result: string = getOpt(None, o => o.name, "anonymous")
  isTextEqualTo("anonymous", result, ~message="getOpt: None returns default")
}

let testGetOptIntSomePresent = () => {
  let opts: exampleOpts = {count: 42}
  let result = getOpt(Some(opts), o => o.count, 0)
  isIntEqualTo(42, result, ~message="getOpt: int field present returns field value")
}

let testGetOptIntNone = () => {
  let result: int = getOpt(None, o => o.count, -1)
  isIntEqualTo(-1, result, ~message="getOpt: int None returns default")
}

let testGetOptBoolSomePresent = () => {
  let opts: exampleOpts = {active: true}
  let result = getOpt(Some(opts), o => o.active, false)
  if result == true {
    passWith("getOpt: bool field present returns field value")
  } else {
    failWith("getOpt: bool field present should return true")
  }
}

let testGetOptBoolSomeAbsent = () => {
  let opts: exampleOpts = {count: 1}
  let result = getOpt(Some(opts), o => o.active, true)
  if result == true {
    passWith("getOpt: bool field absent returns default true")
  } else {
    failWith("getOpt: bool field absent should return default true")
  }
}

// ─── Register tests ─────────────────────────────────────────────

test("getOpt: Some(record) with field present returns field value", () =>
  testGetOptSomeFieldPresent()
)

test("getOpt: Some(record) with field absent returns default", () =>
  testGetOptSomeFieldAbsent()
)

test("getOpt: None returns default", () =>
  testGetOptNone()
)

test("getOpt: int field present returns field value", () =>
  testGetOptIntSomePresent()
)

test("getOpt: int None returns default", () =>
  testGetOptIntNone()
)

test("getOpt: bool field present returns field value", () =>
  testGetOptBoolSomePresent()
)

test("getOpt: bool field absent returns default", () =>
  testGetOptBoolSomeAbsent()
)
