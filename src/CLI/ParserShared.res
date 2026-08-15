/**
 * Parser shared helpers — extracted from Parser.res for modular decomposition.
 */

open CliTypes

// parseJsonObject uses a local result type to avoid polluting the module scope
// with ParserTypes constructors that would shadow Ok/Error in implementing modules.
type jsonParseResult =
  | JsonOk(row)
  | JsonError(string)

let parseJsonObject = (payload: string): jsonParseResult =>
  try {
    switch payload->JSON.parseOrThrow->JSON.Decode.object {
    | Some(obj) => JsonOk(obj)
    | None => JsonError("Expected JSON object")
    }
  } catch {
  | JsExn(exnPayload) =>
    switch JsExn.message(exnPayload) {
    | Some(message) => JsonError("Invalid JSON object: " ++ message)
    | None => JsonError("Invalid JSON object (parse failed)")
    }
  | _ => JsonError("Invalid JSON object (parse failed)")
  }

let isWhitespace = (ch: string): bool =>
  ch == " " || ch == "\n" || ch == "\r" || ch == "\t" || ch == "\u{FEFF}"

let keyForColumn = (header: option<array<string>>, idx: int, noHeader: bool): string =>
  switch (header, noHeader) {
  | (Some(h), false) => h->Array.get(idx)->Option.getOr("col_" ++ idx->Int.toString)
  | _ => "col_" ++ idx->Int.toString
  }
