/**
 * F005-clitypes — Compile-time smoke tests for CliTypes
 *
 * Verifies that cliOptions, parsedArgs, row, and runResult records
 * can be constructed and have their fields accessed. Since these are
 * type-level constructs, construction success is the verification.
 */

open Test
open Assertions
open CliTypes

// ─── cliOptions smoke test ───────────────────────────────────────

let testCliOptionsConstruction = () => {
  let opts: cliOptions = {
    format: #auto,
    chartType: #bar,
    noHeader: false,
  }
  // Verify basic field access
  if opts.format == #auto && opts.chartType == #bar && opts.noHeader == false {
    passWith("cliOptions: minimal construction and field access works")
  } else {
    failWith("cliOptions: field access returned unexpected values")
  }
}

let testCliOptionsWithOptionals = () => {
  let opts: cliOptions = {
    format: #csv,
    chartType: #scatter,
    maxRows: 100,
    width: 80,
    height: 24,
    keyField: "name",
    valueField: "amount",
    xKey: "x",
    yKey: "y",
    seriesField: "series",
    noHeader: true,
  }
  // Verify optional fields are accessible
  switch (opts.maxRows, opts.width, opts.height, opts.keyField) {
  | (Some(mr), Some(w), Some(h), Some(kf)) =>
    if mr == 100 && w == 80 && h == 24 && kf == "name" {
      passWith("cliOptions: optional fields accessible via Some")
    } else {
      failWith("cliOptions: optional field values unexpected")
    }
  | _ => failWith("cliOptions: optional fields not Some")
  }
}

// ─── parsedArgs smoke test ──────────────────────────────────────

let testParsedArgsConstruction = () => {
  let args: parsedArgs = {
    options: {
      format: #json,
      chartType: #bar,
      noHeader: false,
    },
    help: false,
    version: false,
  }
  if args.help == false && args.version == false {
    passWith("parsedArgs: construction and field access works")
  } else {
    failWith("parsedArgs: unexpected field values")
  }
}

let testParsedArgsWithInputPath = () => {
  let args: parsedArgs = {
    options: {
      format: #ndjson,
      chartType: #sparkline,
      noHeader: true,
    },
    inputPath: "data.ndjson",
    help: false,
    version: false,
  }
  switch args.inputPath {
  | Some(path) =>
    if path == "data.ndjson" {
      passWith("parsedArgs: inputPath accessible via Some")
    } else {
      failWith("parsedArgs: inputPath value unexpected")
    }
  | None => failWith("parsedArgs: inputPath should be Some")
  }
}

// ─── row smoke test ──────────────────────────────────────────────

let testRowConstruction = () => {
  let r: row = Dict.make()
  let _ = r->Dict.set("key", JSON.Encode.string("label"))
  let _ = r->Dict.set("value", 42.0->Obj.magic)
  // Construction success is verification
  passWith("row: dict<JSON.t> construction works")
}

// ─── runResult smoke test ────────────────────────────────────────

let testRunResultSuccess = () => {
  let result: runResult = {
    success: true,
    output: "chart output here",
  }
  if result.success == true && result.output == "chart output here" {
    passWith("runResult: success record construction and field access works")
  } else {
    failWith("runResult: success record unexpected field values")
  }
}

let testRunResultFailure = () => {
  let result: runResult = {
    success: false,
    output: "",
    error: "something went wrong",
  }
  switch result.error {
  | Some(msg) =>
    if msg == "something went wrong" {
      passWith("runResult: error field accessible via Some")
    } else {
      failWith("runResult: error message unexpected")
    }
  | None => failWith("runResult: error should be Some")
  }
}

// ─── Register tests ─────────────────────────────────────────────

test("cliOptions: minimal construction and field access works", () =>
  testCliOptionsConstruction()
)

test("cliOptions: optional fields accessible via Some", () =>
  testCliOptionsWithOptionals()
)

test("parsedArgs: construction and field access works", () =>
  testParsedArgsConstruction()
)

test("parsedArgs: inputPath accessible via Some", () =>
  testParsedArgsWithInputPath()
)

test("row: dict<JSON.t> construction works", () =>
  testRowConstruction()
)

test("runResult: success record construction and field access works", () =>
  testRunResultSuccess()
)

test("runResult: error field accessible via Some", () =>
  testRunResultFailure()
)
