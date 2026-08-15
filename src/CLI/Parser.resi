/**
 * Parser — thin facade re-exporting modular sub-modules.
 *
 * Sub-modules (flat, no subdirectory):
 *   ParserTypes      — parseResult, parserConfig, parser types
 *   ParserShared     — isWhitespace, parseJsonObject, keyForColumn helpers
 *   ParserDetect     — detectFormat
 *   ParserNdjson     — createNdjsonParser
 *   ParserCsv        — createCsvParser
 *   ParserJsonArray   — createJsonArrayParser
 */

open CliTypes

// Types from ParserTypes
type parseResult<'a> =
  | Ok('a)
  | Error(string)

type parserConfig = {
  maxRows?: int,
  onRow?: row => unit,
}

type parser = {
  pushChunk: string => unit,
  finish: unit => parseResult<array<row>>,
  rowCount: unit => int,
}

// Re-export format detection
let detectFormat: string => Bindings.Util.inputFormat

// Re-export individual parsers
let createCsvParser: (~cfg: parserConfig, ~noHeader: bool) => parser
let createNdjsonParser: (~cfg: parserConfig) => parser
let createJsonArrayParser: (~cfg: parserConfig) => parser

let defaultConfig: parserConfig

let create: (~format: Bindings.Util.inputFormat, ~noHeader: bool, ~cfg: parserConfig=?) => parser
