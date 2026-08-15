/**
 * ParserShared — internal helpers for parser modules
 *
 * Internal helpers shared by ParserDetect, ParserCsv, ParserNdjson, and
 * ParserJsonArray. Not exposed outside the parser family.
 */

open CliTypes

type jsonParseResult =
  | JsonOk(row)
  | JsonError(string)

let parseJsonObject: string => jsonParseResult
let isWhitespace: string => bool
let keyForColumn: (option<array<string>>, int, bool) => string
