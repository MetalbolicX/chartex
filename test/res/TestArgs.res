/**
 * F006-args — Unit tests for CLI Args seam
 *
 * Covers parseWith directly so CLI parsing can be tested without Process.argv.
 */

open Test
open Assertions
module A = Args
open CliTypes

let assertParseError = (parsed: parsedArgs, expected: string): unit =>
  switch parsed.parseError {
  | Some(message) =>
    if message == expected {
      ()
    } else {
      failWith("parseError mismatch: expected '" ++ expected ++ "', got '" ++ message ++ "'")
    }
  | None => failWith("expected parseError but got None")
  }

let testParseDefaults = () => {
  let parsed = A.parseWith([])

  if parsed.options.format == #auto && parsed.options.chartType == #auto && !parsed.options.noHeader {
    switch (parsed.inputPath, parsed.help, parsed.version, parsed.parseError) {
    | (None, false, false, None) => passWith("parseWith: defaults resolve to auto/false/none")
    | _ => failWith("parseWith: default booleans, inputPath, or parseError were wrong")
    }
  } else {
    failWith("parseWith: default format/chart/noHeader were wrong")
  }
}

let testParseNumericFlags = () => {
  let parsed = A.parseWith(["--width", "80", "--height", "24", "--max-rows", "10"])

  switch (parsed.options.width, parsed.options.height, parsed.options.maxRows, parsed.parseError) {
  | (Some(80), Some(24), Some(10), None) => passWith("parseWith: numeric flags parse as integers")
  | _ => failWith("parseWith: numeric flags did not parse as expected")
  }
}

let testParseInvalidIntsFirstError = () => {
  let parsed = A.parseWith(["--width", "abc", "--height", "12", "--max-rows", "oops"])

  assertParseError(parsed, "Invalid value for --width: 'abc' is not an integer")
}

let testParsePositionalInput = () => {
  let parsed = A.parseWith(["input.csv"])

  switch parsed.inputPath {
  | Some(path) => isTextEqualTo("input.csv", path, ~message="positional input becomes inputPath")
  | None => failWith("parseWith: positional input should populate inputPath")
  }
}

let testParseNoHeader = () => {
  let parsed = A.parseWith(["--no-header"])
  if parsed.options.noHeader {
    passWith("parseWith: --no-header is parsed as true")
  } else {
    failWith("parseWith: --no-header should set noHeader=true")
  }
}

let testParseHelp = () => {
  let parsed = A.parseWith(["--help"])
  switch (parsed.help, parsed.version, parsed.parseError) {
  | (true, false, None) => passWith("parseWith: --help sets help=true")
  | _ => failWith("parseWith: --help did not parse as expected")
  }
}

let testParseVersion = () => {
  let parsed = A.parseWith(["--version"])
  switch (parsed.help, parsed.version, parsed.parseError) {
  | (false, true, None) => passWith("parseWith: --version sets version=true")
  | _ => failWith("parseWith: --version did not parse as expected")
  }
}

test("parseWith: defaults resolve to auto/false/none", () => testParseDefaults())
test("parseWith: numeric flags parse as integers", () => testParseNumericFlags())
test("parseWith: invalid ints surface first parse error", () => testParseInvalidIntsFirstError())
test("parseWith: positional input becomes inputPath", () => testParsePositionalInput())
test("parseWith: --no-header is parsed as true", () => testParseNoHeader())
test("parseWith: --help sets help=true", () => testParseHelp())
test("parseWith: --version sets version=true", () => testParseVersion())
