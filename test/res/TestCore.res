/**
 * F002-core — Unit tests for Core Utilities
 *
 * Covers all 14 public functions across 4 modules:
 * - Json: variant constructors + accessor extraction + mismatch throws
 * - Ansi: bg/fg color output + cursor CSI sequences
 * - Terminal: TTY/non-TTY dimension detection
 * - Validate: chart data structure validation
 */

open Test
open Assertions

open Ansi
open Json
open Terminal
open Validate
open Types

// ─────────────────────────────────────────────────────────────
// Json variant constructor & accessor tests
// ─────────────────────────────────────────────────────────────

let testJsonConstructors = () => {
  // JString
  let jStr = JString("hello")
  isTextEqualTo("hello", string(jStr), ~message="Json.string extracts JString inner value")

  // JNumber
  let jNum = JNumber(42.5)
  isIntEqualTo(42, number(jNum)->Float.toInt, ~message="Json.number extracts JNumber inner value")

  // JBool
  let jTrue = JBool(true)
  if bool(jTrue) {
    passWith("Json.bool extracts JBool inner value (true)")
  } else {
    failWith("Json.bool should return true for JBool(true)")
  }

  let jFalse = JBool(false)
  if !bool(jFalse) {
    passWith("Json.bool extracts JBool inner value (false)")
  } else {
    failWith("Json.bool should return false for JBool(false)")
  }

  // JArray
  let jArr = JArray([JString("a"), JNumber(1.0)])
  let arr = array(jArr)
  isIntEqualTo(2, arr->Array.length, ~message="Json.array extracts JArray with correct length")

  // JObject
  let dict = Dict.make()
  let _ = dict->Dict.set("key", JString("val"))
  let jObj = JObject(dict)
  let obj = object_(jObj)
  switch obj->Dict.get("key") {
  | Some(JString("val")) => passWith("Json.object_ extracts JObject and dict lookup works")
  | _ => failWith("Json.object_ dict lookup failed")
  }

  // JNull
  let _jNull = JNull
  passWith("Json: all 6 variant constructors created and verified")
}

let testJsonAccessorThrows = () => {
  // string() on non-JString should throw Invalid_argument
  try {
    let _ = string(JNumber(42.0))
    failWith("Json.string() should have thrown on JNumber input")
  } catch {
  | Invalid_argument(msg) =>
    isTextEqualTo("Expected JString", msg, ~message="Json.string throws Invalid_argument on JNumber")
  }

  // number() on non-JNumber should throw
  try {
    let _ = number(JString("hello"))
    failWith("Json.number() should have thrown on JString input")
  } catch {
  | Invalid_argument(msg) =>
    isTextEqualTo("Expected JNumber", msg, ~message="Json.number throws Invalid_argument on JString")
  }

  // bool() on non-JBool should throw
  try {
    let _ = bool(JNull)
    failWith("Json.bool() should have thrown on JNull input")
  } catch {
  | Invalid_argument(msg) =>
    isTextEqualTo("Expected JBool", msg, ~message="Json.bool throws Invalid_argument on JNull")
  }

  // array() on non-JArray should throw
  try {
    let _ = array(JString("no-array"))
    failWith("Json.array() should have thrown on JString input")
  } catch {
  | Invalid_argument(msg) =>
    isTextEqualTo("Expected JArray", msg, ~message="Json.array throws Invalid_argument on JString")
  }

  // object_() on non-JObject should throw
  try {
    let _ = object_(JString("no-object"))
    failWith("Json.object_() should have thrown on JString input")
  } catch {
  | Invalid_argument(msg) =>
    isTextEqualTo("Expected JObject", msg, ~message="Json.object_ throws Invalid_argument on JString")
  }
}

// ─────────────────────────────────────────────────────────────
// Ansi module tests
// ─────────────────────────────────────────────────────────────

let testAnsiBg = () => {
  let result = bg(~color=Black, ~length=5)
  // Should contain: \x1b[40m, 5 spaces, \x1b[0m
  if result->String.includes("\x1b[40m") && result->String.includes("\x1b[0m") {
    passWith("Ansi.bg contains color escape \\x1b[40m and reset \\x1b[0m")
  } else {
    failWith("Ansi.bg missing expected escape codes")
  }
  // Verify spaces are present (check length > escape codes alone)
  if result->String.length > 10 {
    passWith("Ansi.bg output contains spaces between escape codes")
  } else {
    failWith("Ansi.bg output too short — missing spaces")
  }
}

let testAnsiFg = () => {
  let result = fg(~color=Red, ~str="test")
  if result->String.includes("\x1b[31m") && result->String.includes("\x1b[0m") {
    passWith("Ansi.fg contains fg escape \\x1b[31m (Red) and reset \\x1b[0m")
  } else {
    failWith("Ansi.fg missing expected fg escape codes")
  }
  if result->String.includes("test") {
    passWith("Ansi.fg output contains the input string")
  } else {
    failWith("Ansi.fg output missing input string")
  }
}

let testAnsiCursor = () => {
  isTextEqualTo("\x1b[3C", curForward(~step=3), ~message="Ansi.curForward(3) returns \\x1b[3C")
  isTextEqualTo("\x1b[2A", curUp(~step=2), ~message="Ansi.curUp(2) returns \\x1b[2A")
  isTextEqualTo("\x1b[1B", curDown(~step=1), ~message="Ansi.curDown(1) returns \\x1b[1B")
  isTextEqualTo("\x1b[4D", curBack(~step=4), ~message="Ansi.curBack(4) returns \\x1b[4D")
}

// ─────────────────────────────────────────────────────────────
// Terminal module tests
// ─────────────────────────────────────────────────────────────

let testTerminalDimensions = () => {
  let w = width()
  let h = height()

  switch (w, h) {
  | (Some(wVal), Some(hVal)) =>
    if wVal >= 0 {
      passWith("Terminal.width returns non-negative integer")
    } else {
      failWith("Terminal.width returned negative value")
    }

    if hVal >= 0 {
      passWith("Terminal.height returns non-negative integer")
    } else {
      failWith("Terminal.height returned negative value")
    }
  | _ =>
    failWith("Terminal.width/height returned None (non-TTY environment)")
  }
}

// ─────────────────────────────────────────────────────────────
// Validate module tests
// ─────────────────────────────────────────────────────────────

let testValidateData = () => {
  // Valid: non-empty JArray of valid objects
  let validDict = Dict.make()
  let _ = validDict->Dict.set("key", JString("label"))
  let _ = validDict->Dict.set("value", JNumber(42.0))
  let validInput = JArray([JObject(validDict)])
  if data(validInput) {
    passWith("Validate.data returns true for valid JArray of objects")
  } else {
    failWith("Validate.data should return true for valid chart data")
  }

  // Invalid: JString
  let strInput = JString("not-an-array")
  if !data(strInput) {
    passWith("Validate.data returns false for JString input")
  } else {
    failWith("Validate.data should return false for JString")
  }

  // Invalid: empty JArray
  let emptyInput = JArray([])
  if !data(emptyInput) {
    passWith("Validate.data returns false for empty JArray")
  } else {
    failWith("Validate.data should return false for empty array")
  }

  // Invalid: JArray with non-object element
  let badInput = JArray([JString("bad")])
  if !data(badInput) {
    passWith("Validate.data returns false for JArray containing JString")
  } else {
    failWith("Validate.data should return false for invalid array element")
  }

  // Invalid: JObject with missing "key" field
  let noKeyDict = Dict.make()
  let _ = noKeyDict->Dict.set("value", JNumber(10.0))
  let noKeyInput = JArray([JObject(noKeyDict)])
  if !data(noKeyInput) {
    passWith("Validate.data returns false when key field is missing")
  } else {
    failWith("Validate.data should detect missing key field")
  }

  // Invalid: JObject with wrong value type
  let wrongValueDict = Dict.make()
  let _ = wrongValueDict->Dict.set("key", JString("label"))
  let _ = wrongValueDict->Dict.set("value", JString("not-a-number"))
  let wrongValueInput = JArray([JObject(wrongValueDict)])
  if !data(wrongValueInput) {
    passWith("Validate.data returns false when value is not JNumber")
  } else {
    failWith("Validate.data should detect non-numeric value field")
  }
}

// ─── Register tests with rescript-test runner ───

test("Json: constructors create variants and accessors extract values", () =>
  testJsonConstructors()
)

test("Json: accessors throw Invalid_argument on variant mismatch", () =>
  testJsonAccessorThrows()
)

test("Ansi: bg produces background-colored spaces with reset", () =>
  testAnsiBg()
)

test("Ansi: fg produces foreground-colored text with reset", () =>
  testAnsiFg()
)

test("Ansi: cursor functions return correct CSI sequences", () =>
  testAnsiCursor()
)

test("Terminal: width and height return non-negative integers", () =>
  testTerminalDimensions()
)

test("Validate: data() returns true/false for valid/invalid structures", () =>
  testValidateData()
)
