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

// Re-export types from sub-module
include ParserTypes

// Re-export format detection
let detectFormat = ParserDetect.detectFormat

// Re-export individual parsers
let createCsvParser = ParserCsv.createCsvParser
let createNdjsonParser = ParserNdjson.createNdjsonParser
let createJsonArrayParser = ParserJsonArray.createJsonArrayParser

let defaultConfig: parserConfig = {}

let create = (~format: Bindings.Util.inputFormat, ~noHeader: bool, ~cfg: parserConfig=defaultConfig): parser =>
  switch format {
  | #json => ParserJsonArray.createJsonArrayParser(~cfg)
  | #ndjson => ParserNdjson.createNdjsonParser(~cfg)
  | #csv => ParserCsv.createCsvParser(~cfg, ~noHeader)
  | #auto => {
      let chosen = ref(None)
      let createFromChunk = (chunk: string): parser =>
        switch ParserDetect.detectFormat(chunk) {
        | #json => ParserJsonArray.createJsonArrayParser(~cfg)
        | #ndjson => ParserNdjson.createNdjsonParser(~cfg)
        | _ => ParserCsv.createCsvParser(~cfg, ~noHeader)
        }

      {
        pushChunk: chunk => {
          switch chosen.contents {
          | Some(parser) => parser.pushChunk(chunk)
          | None => {
              let parser = createFromChunk(chunk)
              chosen := Some(parser)
              parser.pushChunk(chunk)
            }
          }
        },
        finish: () =>
          switch chosen.contents {
          | Some(parser) => parser.finish()
          | None => Error("Error: Parser no input received")
          },
        rowCount: () =>
          switch chosen.contents {
          | Some(parser) => parser.rowCount()
          | None => 0
          },
      }
    }
  }
