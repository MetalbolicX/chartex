/**
 * F003-parser — Unit tests for CLI Parsers
 *
 * Covers all 5 public functions / factory combinators:
 * - P.detectFormat: CSV, NDJSON, JSON array format detection from first char
 * - P.createCsvParser: header/no-header, quoted fields, missing final newline
 * - P.createNdjsonParser: basic line parsing, buffering across chunk boundaries
 * - P.createJsonArrayParser: simple, nested objects, trailing whitespace
 * - P.create: factory that delegates to the above three by format
 */

open Test
open Assertions
module P = Parser
open CliTypes
// CliTypes.row and Parser.row both exist (same underlying dict<JSON.t>).
// Alias CliTypes row to avoid shadowing confusion in pattern matches.
type cliRow = CliTypes.row

// ─── Helpers ───────────────────────────────────────────────────────

/**
 * Compares two dict<JSON.t> by serializing to JSON strings.
 * Safe for structural equality checks where dict reference differs.
 */
let dictsEqual = (a: row, b: row): bool =>
  JSON.stringify(a->Obj.magic) == JSON.stringify(b->Obj.magic)

let rowInArray = (rows: array<row>, expected: row): bool =>
  rows->Array.some(r => dictsEqual(r, expected))

// ─────────────────────────────────────────────────────────────────
// detectFormat
// ─────────────────────────────────────────────────────────────────

let testDetectFormat = () => {
  // CSV: unquoted
  isTextEqualTo(
    #csv->Obj.magic->Obj.magic,
    P.detectFormat("name,value\nfoo,1")->Obj.magic->Obj.magic,
    ~message="detectFormat: plain CSV returns #csv",
  )

  // NDJSON: starts with {
  isTextEqualTo(
    #ndjson->Obj.magic->Obj.magic,
    P.detectFormat("{\"key\":\"val\"}")->Obj.magic->Obj.magic,
    ~message="detectFormat: NDJSON returns #ndjson",
  )

  // JSON array: starts with [
  isTextEqualTo(
    #json->Obj.magic->Obj.magic,
    P.detectFormat("[1,2,3]")->Obj.magic->Obj.magic,
    ~message="detectFormat: JSON array returns #json",
  )

  // CSV: leading whitespace ignored
  isTextEqualTo(
    #csv->Obj.magic->Obj.magic,
    P.detectFormat("  name,value")->Obj.magic->Obj.magic,
    ~message="detectFormat: leading whitespace is ignored",
  )

  // NDJSON: leading whitespace ignored
  isTextEqualTo(
    #ndjson->Obj.magic->Obj.magic,
    P.detectFormat("  {\"key\":\"val\"}")->Obj.magic->Obj.magic,
    ~message="detectFormat: leading whitespace before { returns #ndjson",
  )

  // JSON array: leading whitespace ignored
  isTextEqualTo(
    #json->Obj.magic->Obj.magic,
    P.detectFormat("  [1,2,3]")->Obj.magic->Obj.magic,
    ~message="detectFormat: leading whitespace before [ returns #json",
  )

  // UTF-8 BOM: NDJSON prefixed with BOM (\uFEFF) returns #ndjson
  isTextEqualTo(
    #ndjson->Obj.magic->Obj.magic,
    P.detectFormat("\u{FEFF}{\"key\":\"val\"}")->Obj.magic->Obj.magic,
    ~message="detectFormat: BOM-prefixed NDJSON returns #ndjson",
  )

  // UTF-8 BOM: JSON array prefixed with BOM returns #json
  isTextEqualTo(
    #json->Obj.magic->Obj.magic,
    P.detectFormat("\u{FEFF}[1,2,3]")->Obj.magic->Obj.magic,
    ~message="detectFormat: BOM-prefixed JSON array returns #json",
  )

  // UTF-8 BOM: CSV prefixed with BOM returns #csv
  isTextEqualTo(
    #csv->Obj.magic->Obj.magic,
    P.detectFormat("\u{FEFF}name,value\nfoo,1")->Obj.magic->Obj.magic,
    ~message="detectFormat: BOM-prefixed CSV returns #csv",
  )
}

// ─────────────────────────────────────────────────────────────────
// P.createCsvParser
// ─────────────────────────────────────────────────────────────────

let testCsvNoHeader = () => {
  let p = P.createCsvParser(~cfg={}, ~noHeader=false)
  p.pushChunk("name,value\n")
  p.pushChunk("foo,42\n")
  p.pushChunk("bar,99\n")

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(2, rows->Array.length, ~message="CSV with header: 2 data rows (3 lines - 1 header)")
      isTextEqualTo(
        "foo",
        rows[0]->Obj.magic->Dict.get("name")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="CSV with header: first row key is 'foo'",
      )
      isTextEqualTo(
        "42",
        rows[0]->Obj.magic->Dict.get("value")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="CSV with header: first row value is '42'",
      )
    }
  | Error(msg) => failWith("CSV with header should parse successfully: " ++ msg)
  }
}

let testCsvNoHeaderFlag = () => {
  let p = P.createCsvParser(~cfg={}, ~noHeader=true)
  p.pushChunk("foo,42\n")
  p.pushChunk("bar,99\n")

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(2, rows->Array.length, ~message="CSV noHeader: 2 rows from 2 lines")
      isTextEqualTo(
        "foo",
        rows[0]->Obj.magic->Dict.get("col_0")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="CSV noHeader: first row first col is 'foo'",
      )
      isTextEqualTo(
        "col_1",
        rows[0]->Obj.magic->Dict.get("col_1")->Option.map(_ => "col_1")->Option.getOr(""),
        ~message="CSV noHeader: column 1 named col_1",
      )
    }
  | Error(msg) => failWith("CSV noHeader should parse successfully: " ++ msg)
  }
}

let testCsvQuotedFields = () => {
  let p = P.createCsvParser(~cfg={}, ~noHeader=false)
  // Quoted field containing a comma
  p.pushChunk("name,desc\n")
  p.pushChunk("\"foo bar\",\"value,with,commas\"\n")
  p.pushChunk("baz,qux\n")

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(2, rows->Array.length, ~message="CSV quoted: 2 data rows")
      isTextEqualTo(
        "foo bar",
        rows[0]->Obj.magic->Dict.get("name")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="CSV quoted: name field preserved as 'foo bar'",
      )
      isTextEqualTo(
        "value,with,commas",
        rows[0]->Obj.magic->Dict.get("desc")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="CSV quoted: commas inside quotes preserved",
      )
    }
  | Error(msg) => failWith("CSV quoted fields should parse successfully: " ++ msg)
  }
}

let testCsvEscapedQuotes = () => {
  let p = P.createCsvParser(~cfg={}, ~noHeader=false)
  p.pushChunk("name,text\n")
  // Doubled quote inside quotes: "foo""bar"
  p.pushChunk("\"foo\"\"\"\"bar\",hello\n")

  switch p.finish() {
  | Ok(rows) => {
      isTextEqualTo(
        "foo\"\"bar",
        rows[0]->Obj.magic->Dict.get("name")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="CSV escaped quotes: doubled quotes become single quote",
      )
    }
  | Error(msg) => failWith("CSV escaped quotes should parse successfully: " ++ msg)
  }
}

let testCsvMissingFinalNewline = () => {
  let p = P.createCsvParser(~cfg={}, ~noHeader=false)
  p.pushChunk("name,value\n")
  p.pushChunk("foo,42") // no trailing \n

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(1, rows->Array.length, ~message="CSV missing final newline: row still emitted")
      isTextEqualTo(
        "foo",
        rows[0]->Obj.magic->Dict.get("name")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="CSV missing final newline: last row parsed",
      )
    }
  | Error(msg) => failWith("CSV should emit final row even without trailing newline: " ++ msg)
  }
}

let testCsvUnterminatedQuote = () => {
  let p = P.createCsvParser(~cfg={}, ~noHeader=false)
  p.pushChunk("name,value\n")
  p.pushChunk("\"unterminated,hello\n")

  switch p.finish() {
  | Error("Unterminated quoted CSV field") =>
    passWith("CSV unterminated quote: returns Error with correct message")
  | Error(msg) =>
    failWith("CSV unterminated quote: wrong error message: " ++ msg)
  | Ok(_) =>
    failWith("CSV unterminated quote: should have returned Error, got Ok")
  }
}

let testCsvEmptyField = () => {
  let p = P.createCsvParser(~cfg={}, ~noHeader=false)
  p.pushChunk("a,b,c\n")
  p.pushChunk(",missing,value\n")

  switch p.finish() {
  | Ok(rows) => {
      isTextEqualTo(
        "",
        rows[0]->Obj.magic->Dict.get("a")->Option.flatMap(JSON.Decode.string)->Option.getOr("X"),
        ~message="CSV empty field: empty string preserved",
      )
      isTextEqualTo(
        "missing",
        rows[0]->Obj.magic->Dict.get("b")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="CSV empty field: non-empty fields intact",
      )
    }
  | Error(msg) => failWith("CSV empty fields should parse successfully: " ++ msg)
  }
}

// ─────────────────────────────────────────────────────────────────
// P.createNdjsonParser
// ─────────────────────────────────────────────────────────────────

let testNdjsonBasic = () => {
  let p = P.createNdjsonParser(~cfg={})
  p.pushChunk("{\"key\":\"A\",\"value\":10}\n")
  p.pushChunk("{\"key\":\"B\",\"value\":20}\n")

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(2, rows->Array.length, ~message="NDJSON basic: 2 rows parsed")
      isTextEqualTo(
        "A",
        rows[0]->Obj.magic->Dict.get("key")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="NDJSON basic: first row key is 'A'",
      )
      isIntEqualTo(
        10,
        rows[0]->Obj.magic->Dict.get("value")->Option.flatMap(JSON.Decode.float)->Option.map(Float.toInt)->Option.getOr(-1),
        ~message="NDJSON basic: first row value is 10",
      )
    }
  | Error(msg) => failWith("NDJSON basic should parse successfully: " ++ msg)
  }
}

let testNdjsonBufferingAcrossChunks = () => {
  let p = P.createNdjsonParser(~cfg={})
  // Second line split across two chunks
  p.pushChunk("{\"key\":\"A\",\"value\":10}\n{\"key\":\"B\"")
  p.pushChunk(",\"value\":20}\n")

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(2, rows->Array.length, ~message="NDJSON buffering: 2 rows parsed across chunks")
      isTextEqualTo(
        "B",
        rows[1]->Obj.magic->Dict.get("key")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="NDJSON buffering: second row key is 'B'",
      )
    }
  | Error(msg) => failWith("NDJSON buffering should parse successfully: " ++ msg)
  }
}

let testNdjsonSkipsEmptyLines = () => {
  let p = P.createNdjsonParser(~cfg={})
  p.pushChunk("{\"key\":\"A\",\"value\":10}\n")
  p.pushChunk("\n")
  p.pushChunk("{\"key\":\"B\",\"value\":20}\n")

  switch p.finish() {
  | Ok(rows) =>
    isIntEqualTo(2, rows->Array.length, ~message="NDJSON skips empty lines")
  | Error(msg) => failWith("NDJSON should skip empty lines: " ++ msg)
  }
}

let testNdjsonInvalidJson = () => {
  let p = P.createNdjsonParser(~cfg={})
  p.pushChunk("not json\n")

  switch p.finish() {
  | Error(_) => passWith("NDJSON invalid JSON: returns Error")
  | Ok(_) => failWith("NDJSON invalid JSON: should have returned Error")
  }
}

// ─────────────────────────────────────────────────────────────────
// P.createJsonArrayParser
// ─────────────────────────────────────────────────────────────────

let testJsonArraySimple = () => {
  let p = P.createJsonArrayParser(~cfg={})
  p.pushChunk(" [ {\"key\":\"p1\",\"value\":1} , {\"key\":\"p2\",\"value\":2} ] ")

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(2, rows->Array.length, ~message="JSON array simple: 2 rows parsed")
      isTextEqualTo(
        "p1",
        rows[0]->Obj.magic->Dict.get("key")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="JSON array simple: first row key is 'p1'",
      )
    }
  | Error(msg) => failWith("JSON array simple should parse successfully: " ++ msg)
  }
}

let testJsonArrayNestedObjects = () => {
  let p = P.createJsonArrayParser(~cfg={})
  // Nested object with braces inside the string value
  p.pushChunk("[{\"key\":\"a\",\"meta\":{\"id\":1}},{\"key\":\"b\",\"meta\":{\"id\":2}}]")

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(2, rows->Array.length, ~message="JSON array nested: 2 rows parsed")
      isIntEqualTo(
        1,
        rows[0]->Obj.magic->Dict.get("meta")->Option.flatMap(JSON.Decode.object)
          ->Option.flatMap(d => d->Dict.get("id")->Option.flatMap(JSON.Decode.float))
          ->Option.map(Float.toInt)
          ->Option.getOr(-1),
        ~message="JSON array nested: meta.id is 1",
      )
    }
  | Error(msg) => failWith("JSON array nested should parse successfully: " ++ msg)
  }
}

let testJsonArrayChunkedStreaming = () => {
  let p = P.createJsonArrayParser(~cfg={})
  p.pushChunk("[\n")
  p.pushChunk("  {\"key\":\"A\",\"value\":1},\n")
  p.pushChunk("  {\"key\":\"B\",\"value\":2}\n")
  p.pushChunk("]")

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(2, rows->Array.length, ~message="JSON array chunked: 2 rows across 4 chunks")
      isTextEqualTo(
        "B",
        rows[1]->Obj.magic->Dict.get("key")->Option.flatMap(JSON.Decode.string)->Option.getOr(""),
        ~message="JSON array chunked: second row key is 'B'",
      )
    }
  | Error(msg) => failWith("JSON array chunked should parse successfully: " ++ msg)
  }
}

let testJsonArrayTrailingWhitespace = () => {
  let p = P.createJsonArrayParser(~cfg={})
  p.pushChunk("[{\"key\":\"A\",\"value\":1}]  \n  ")

  switch p.finish() {
  | Ok(rows) => {
      isIntEqualTo(1, rows->Array.length, ~message="JSON array trailing whitespace: row parsed")
    }
  | Error(msg) => failWith("JSON array trailing whitespace should be ignored: " ++ msg)
  }
}

let testJsonArrayMustStartWithBracket = () => {
  let p = P.createJsonArrayParser(~cfg={})
  p.pushChunk("{\"key\":\"A\",\"value\":1}")

  switch p.finish() {
  | Error("JSON array input must start with '['") =>
    passWith("JSON array wrong start: correct error message")
  | Error(msg) =>
    failWith("JSON array wrong start: wrong error message: " ++ msg)
  | Ok(_) =>
    failWith("JSON array wrong start: should have returned Error")
  }
}

let testJsonArrayEmptyInput = () => {
  let p = P.createJsonArrayParser(~cfg={})

  switch p.finish() {
  | Error("Empty input") => passWith("JSON array empty input: returns Error")
  | Error(msg) => failWith("JSON array empty input: wrong error: " ++ msg)
  | Ok(_) => failWith("JSON array empty input: should have returned Error")
  }
}

let testJsonArrayUnterminatedQuote = () => {
  let p = P.createJsonArrayParser(~cfg={})
  p.pushChunk("[{\"key\":\"unterminated")

  switch p.finish() {
  | Error("Incomplete JSON array input") =>
    passWith("JSON array unterminated quote: returns Error")
  | Error(msg) => failWith("JSON array unterminated quote: wrong error: " ++ msg)
  | Ok(_) => failWith("JSON array unterminated quote: should have returned Error")
  }
}

let testJsonArrayMissingClosingBracket = () => {
  let p = P.createJsonArrayParser(~cfg={})
  p.pushChunk("[{\"key\":\"A\",\"value\":1}")

  switch p.finish() {
  | Error("Incomplete JSON array input") =>
    passWith("JSON array missing closing bracket: returns Error")
  | Error(msg) =>
    failWith("JSON array missing closing bracket: wrong error: " ++ msg)
  | Ok(_) =>
    failWith("JSON array missing closing bracket: should have returned Error")
  }
}

// ─────────────────────────────────────────────────────────────────
// P.create (factory)
// ─────────────────────────────────────────────────────────────────

let testCreateAutoDelegatesCsv = () => {
  let p = P.create(~format=#auto, ~noHeader=false)
  p.pushChunk("a,b\n1,2\n")

  switch p.finish() {
  | Ok(rows) =>
    isIntEqualTo(1, rows->Array.length, ~message="P.create(auto): delegates CSV")
  | Error(msg) => failWith("P.create(auto) CSV should succeed: " ++ msg)
  }
}

let testCreateAutoDelegatesNdjson = () => {
  let p = P.create(~format=#auto, ~noHeader=false)
  p.pushChunk("{\"key\":\"A\",\"value\":1}\n")

  switch p.finish() {
  | Ok(rows) =>
    isIntEqualTo(1, rows->Array.length, ~message="P.create(auto): delegates NDJSON")
  | Error(msg) => failWith("P.create(auto) NDJSON should succeed: " ++ msg)
  }
}

let testCreateAutoDelegatesJson = () => {
  let p = P.create(~format=#auto, ~noHeader=false)
  p.pushChunk("[{\"key\":\"A\",\"value\":1}]")

  switch p.finish() {
  | Ok(rows) =>
    isIntEqualTo(1, rows->Array.length, ~message="P.create(auto): delegates JSON array")
  | Error(msg) => failWith("P.create(auto) JSON array should succeed: " ++ msg)
  }
}

let testCreateNoInput = () => {
  let p = P.create(~format=#auto, ~noHeader=false)

  switch p.finish() {
  | Error("No input received") =>
    passWith("P.create with no input: returns Error 'No input received'")
  | Error(msg) => failWith("P.create with no input: wrong error: " ++ msg)
  | Ok(_) => failWith("P.create with no input: should have returned Error")
  }
}

// ─── Register tests ─────────────────────────────────────────────

test("detectFormat: returns correct format variant from first non-whitespace char", () =>
  testDetectFormat()
)

test("P.createCsvParser: header row becomes column names", () =>
  testCsvNoHeader()
)

test("P.createCsvParser: noHeader=true uses col_N naming", () =>
  testCsvNoHeaderFlag()
)

test("P.createCsvParser: quoted fields preserve commas and spaces", () =>
  testCsvQuotedFields()
)

test("P.createCsvParser: doubled double-quotes inside quotes become single quote", () =>
  testCsvEscapedQuotes()
)

test("P.createCsvParser: last row emitted without trailing newline", () =>
  testCsvMissingFinalNewline()
)

test("P.createCsvParser: unterminated quoted field returns Error", () =>
  testCsvUnterminatedQuote()
)

test("P.createCsvParser: empty fields preserved as empty string", () =>
  testCsvEmptyField()
)

test("P.createNdjsonParser: basic parsing of newline-delimited JSON", () =>
  testNdjsonBasic()
)

test("P.createNdjsonParser: buffers lines split across pushChunk calls", () =>
  testNdjsonBufferingAcrossChunks()
)

test("P.createNdjsonParser: skips empty lines", () =>
  testNdjsonSkipsEmptyLines()
)

test("P.createNdjsonParser: invalid JSON returns Error", () =>
  testNdjsonInvalidJson()
)

test("P.createJsonArrayParser: simple JSON array parses correctly", () =>
  testJsonArraySimple()
)

test("P.createJsonArrayParser: handles nested objects with inner braces", () =>
  testJsonArrayNestedObjects()
)

test("P.createJsonArrayParser: streams objects across multiple pushChunk calls", () =>
  testJsonArrayChunkedStreaming()
)

test("P.createJsonArrayParser: trailing whitespace after closing ] is ignored", () =>
  testJsonArrayTrailingWhitespace()
)

test("P.createJsonArrayParser: input not starting with [ returns Error", () =>
  testJsonArrayMustStartWithBracket()
)

test("P.createJsonArrayParser: empty input returns Error", () =>
  testJsonArrayEmptyInput()
)

test("P.createJsonArrayParser: unterminated string inside array returns Error", () =>
  testJsonArrayUnterminatedQuote()
)

test("P.createJsonArrayParser: missing closing bracket returns Error", () =>
  testJsonArrayMissingClosingBracket()
)

test("P.create: #auto format delegates to CSV when input looks like CSV", () =>
  testCreateAutoDelegatesCsv()
)

test("P.create: #auto format delegates to NDJSON when input looks like NDJSON", () =>
  testCreateAutoDelegatesNdjson()
)

test("P.create: #auto format delegates to JSON when input looks like JSON array", () =>
  testCreateAutoDelegatesJson()
)

test("P.create: finish called before any push returns Error", () =>
  testCreateNoInput()
)
